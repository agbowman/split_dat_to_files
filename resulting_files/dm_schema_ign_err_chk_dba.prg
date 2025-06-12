CREATE PROGRAM dm_schema_ign_err_chk:dba
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
 SET dsie_file = fillstring(132," ")
 SET dsie_cnt = 0
 SET dsie_file_stat = 0
 SET dsie_status = "F"
 SET problem_name = fillstring(255," ")
 FREE RECORD dsie_chk
 RECORD dsie_chk(
   1 data[*]
     2 error_name = vc
 )
 SET dsie_file = "cer_install:dm_sch_ign_err.csv"
 SET dsie_file_stat = findfile(dsie_file)
 IF (dsie_file_stat=0)
  SET dsie_status = "M"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 dsie_file
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dsie_cnt = 0, first_one = "Y", stat = alterlist(dsie_chk->data,10)
  DETAIL
   IF (first_one="N")
    dsie_cnt = (dsie_cnt+ 1)
    IF (mod(dsie_cnt,10)=1
     AND dsie_cnt != 1)
     stat = alterlist(dsie_chk->data,(dsie_cnt+ 9))
    ENDIF
    dsie_chk->data[dsie_cnt].error_name = t.line
   ENDIF
   first_one = "N"
  WITH nocounter
 ;end select
 SET stat = alterlist(dsie_chk->data,dsie_cnt)
 SELECT INTO "nl:"
  dsie_chk->data[d.seq].error_name
  FROM (dummyt d  WITH seq = value(dsie_cnt)),
   dm_info dm
  PLAN (d)
   JOIN (dm
   WHERE dm.info_domain="DATA MANAGEMENT"
    AND (dm.info_name=dsie_chk->data[d.seq].error_name)
    AND dm.info_char="SCHEMA_IGNORED_ERROR")
  HEAD REPORT
   problem_name = fillstring(255," "), first_one = "Y", dsie_status = "S"
  DETAIL
   dsie_status = "F"
   IF (first_one="Y")
    problem_name = dsie_chk->data[d.seq].error_name
   ELSE
    problem_name = build(dsie_chk->data[d.seq].error_name,", ",problem_name)
   ENDIF
   first_one = "N"
  FOOT REPORT
   row + 0
  WITH nullreport, outerjoin = d, dontexist
 ;end select
#exit_script
 IF (dsie_status="M")
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The file Cer_install:dm_schema_ign_err.csv could not be found"
 ELSEIF (dsie_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme Failed.  The following error messages are not on the dm_info table: ",problem_name)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeed.  DM_INFO table was successfully updated."
 ENDIF
 FREE RECORD dsie_chk
 EXECUTE dm_readme_status
END GO
