CREATE PROGRAM dcp_readme_apache_del_rpt32:dba
 IF (validate(readme_data,"0")="0")
  IF ( NOT (validate(readme_data,0)))
   FREE SET readme_data
   RECORD readme_data(
     1 ocd = i4
     1 readme_id = f8
     1 instance = i4
     1 readme_type = vc
     1 description = vc
     1 script = vc
     1 check_script = vc
     1 data_file = vc
     1 par_file = vc
     1 blocks = i4
     1 log_rowid = vc
     1 status = vc
     1 message = c255
     1 options = vc
     1 driver = vc
     1 batch_dt_tm = dq8
   )
  ENDIF
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Failure - Data update failed."
 DECLARE errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET active_cd = 0.0
 SET auth_cd = 0.0
#script_start
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "INACTIVE", cv.active_ind = 0, cv.active_type_cd = active_cd,
   cv.data_status_cd = auth_cd, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm
    = null,
   cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = 99, cv.updt_cnt = 0,
   cv.updt_task = 99, cv.updt_applctx = 99, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
  WHERE cv.cki IN ("CKI.CODEVALUE!3190264", "CKI.CODEVALUE!3190244")
   AND cv.code_set=29241
  WITH nocounter
 ;end update
 SET found_rpt32 = "N"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3190264"
   AND cv.code_set=29241
   AND cv.cdf_meaning="REPORT"
  DETAIL
   found_rpt32 = "Y"
  WITH nocounter
 ;end select
 IF (found_rpt32="Y")
  SET readme_data_staus = "F"
  SET readme_data->message = "FAIL - DCP_ARPT_32_PROMPT found in Code_Value Table"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success - Data inserted successfully."
 CALL echorecord(readme_data)
#exit_script
 EXECUTE dm_readme_status
END GO
