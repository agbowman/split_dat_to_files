CREATE PROGRAM ams_vis_update_driver:dba
 EXECUTE ams_define_toolkit_common
 DECLARE vis_cnt = i4 WITH public, noconstant(0)
 DECLARE domain_name = vc WITH public, noconstant("")
 DECLARE script_name = vc WITH protect, constant("AMS_VIS_AUTO_UPDATE")
 DECLARE date_time_meaning = vc WITH protect, constant("CURDATE")
 IF (validate(requestin->list_0[1].cdf_meaning)=0)
  CALL echo("The request didn't get populated!")
  GO TO exit_script
 ENDIF
 SET vis_cnt = size(requestin->list_0,5)
 IF (vis_cnt <= 1)
  CALL echo("There is no VIS data in the CSV file!")
  GO TO exit_script
 ENDIF
 IF ((requestin->list_0[1].cdf_meaning != date_time_meaning))
  CALL echo("The CSV file doesn't contain the CURDATE tag!")
  GO TO exit_script
 ENDIF
 IF (cnvtdatetime(trim(requestin->list_0[1].beg_effective_dt_tm)) < cnvtdatetime((curdate - 1),
  curtime3))
  CALL echo("The CSV file is too old!")
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(vis_cnt))
  SET cv.begin_effective_dt_tm = datetimeadd(cnvtdatetime(trim(requestin->list_0[d.seq].
      beg_effective_dt_tm)),(1/ 2)), cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   cv.updt_id =
   (SELECT
    person_id
    FROM prsnl
    WHERE username="CERNER"), cv.updt_task = 1234
  PLAN (d
   WHERE d.seq > 1)
   JOIN (cv
   WHERE cv.cdf_meaning=trim(requestin->list_0[d.seq].cdf_meaning)
    AND cv.code_set=4002875
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cv.begin_effective_dt_tm != datetimeadd(cnvtdatetime(trim(requestin->list_0[d.seq].
      beg_effective_dt_tm)),(1/ 2)))
  WITH nocounter
 ;end update
 SET mn_error_ind = error(ms_error_msg,0)
 IF (mn_error_ind > 0)
  CALL uar_secgetdomainname(domain_name,100)
  CALL uar_send_mail(nullterm("tyler.cook@cerner.com"),nullterm("VIS Auto Status"),nullterm(build(
     "Failure! ",domain_name)," : ",ms_error_msg),nullterm("Cerner"),5,
   nullterm("IPM.NOTE"))
  ROLLBACK
  GO TO exit_script
 ENDIF
 CALL updtdminfo(script_name,cnvtreal(1))
#exit_script
 SET script_version = "000 11/16/2015 TC017703"
END GO
