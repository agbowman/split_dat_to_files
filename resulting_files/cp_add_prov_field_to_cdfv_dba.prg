CREATE PROGRAM cp_add_prov_field_to_cdfv:dba
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
 SET cnt_done = 0
 SELECT INTO "nl:"
  cdfv.reltn_type_cd
  FROM chart_dist_filter_value cdfv
  WHERE cdfv.type_flag=2
   AND cdfv.reltn_type_cd > 0
  HEAD REPORT
   cnt_done = 0
  DETAIL
   cnt_done += 1
  WITH nocounter
 ;end select
 SET admit_doc_cd = 0.0
 SET successful_cnt = 0
 IF (cnt_done=0)
  CALL echo("updating rows")
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=333
    AND cv.cdf_meaning="ADMITDOC"
    AND cv.active_ind=1
   HEAD REPORT
    do_nothing = 0
   DETAIL
    admit_doc_cd = cv.code_value
   WITH nocounter
  ;end select
  UPDATE  FROM chart_dist_filter_value cdfv
   SET cdfv.reltn_type_cd = cnvtint(admit_doc_cd)
   WHERE cdfv.type_flag=2
    AND cdfv.reltn_type_cd=0.0
   WITH counter
  ;end update
  IF (curqual > 0)
   SET successful_cnt += 1
   CALL echo(build("updated chart_dist_filter_value: ",successful_cnt))
  ENDIF
 ENDIF
#exit_script
 SET errormsg = fillstring(256,"")
 SET error_check = error(errormsg,0)
 IF (successful_cnt > 0)
  COMMIT
  SET readme_data->message =
  "relationship_type_cd updated on chart_dist_filter_value table - SUCCESSFUL"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("successful - committing changes")
  COMMIT
 ELSEIF (error_check != 0)
  ROLLBACK
  SET readme_data->message = "Errors in cp_add_prov_field_to_cdfv - FAILURE"
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  CALL echo("errors in cp_add_prov_field_to_cdfv")
  COMMIT
 ELSE
  ROLLBACK
  SET readme_data->message =
  "No rows updated on chart_dist_filter_value table (reltn_type_cd) - ZERO"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("no rows to update")
  COMMIT
 ENDIF
END GO
