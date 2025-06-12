CREATE PROGRAM afc_rdm_upt_suprvsngprov_cve:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme afc_rdm_upt_suprvsngprov_cve failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value_extension ce
  SET ce.field_value = "PROVLOOKUP", ce.updt_task = reqinfo->updt_task, ce.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_applctx = reqinfo->updt_applctx, ce.updt_id = reqinfo->
   updt_id
  WHERE ce.field_name="TYPE"
   AND ce.field_value="STRING"
   AND ce.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.cki="CKI.CODEVALUE!4200015278"
    AND cv.display_key="SUPERVISINGPROVIDER"
    AND cv.active_ind=1))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = build(errmsg,
   "Failed updating SUPRVSNGPROV codevalue extension Type in codeset 4002352.")
  GO TO exit_script
 ELSEIF (curqual=0)
  ROLLBACK
  SET readme_data->status = "S"
  SET readme_data->message = build(errmsg,
   "SUPRVSNGPROV codevalue extension Type in codeset 4002352 has already been changed.")
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme updated SUPRVSNGPROV codevalue extension Type in codeset 4002352."
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
