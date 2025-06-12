CREATE PROGRAM acm_rdm_define_ibus_fcelig:dba
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
 SET readme_data->message = "Readme failed: starting script acm_rdm_define_ibus_fcelig..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dfcmedeligcd = f8 WITH protect, noconstant(0.0)
 DECLARE irowfound = i2 WITH protect, noconstant(0)
 DECLARE dibusfceligcd = f8 WITH protect, noconstant(0.0)
 DECLARE iactiveind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="FC_MED_ELIG"
   AND cv.code_set=27144
   AND cv.active_ind=1
  DETAIL
   dfcmedeligcd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error selecting the CODE_VALUE table row for code set 27144: ",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual != 1)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: the CODE_VALUE table for code set 27144 did not have meaning FC_MED_ELIG"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  found = 1
  FROM dual
  WHERE  EXISTS (
  (SELECT
   1
   FROM org_trans_ident
   WHERE transaction_type_cd=dfcmedeligcd))
  DETAIL
   irowfound = found
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the ORG_TRANS_IDENT table for FC_MED_ELIG rows: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->message =
 "Success: the CODE_VALUE table row for code set 207902 did not need to be updated"
 IF (irowfound > 0)
  SELECT INTO "nl:"
   cv.code_value, cv.active_ind
   FROM code_value cv
   WHERE cv.cdf_meaning="IBUSFCELIG"
    AND cv.code_set=207902
   DETAIL
    dibusfceligcd = cv.code_value, iactiveind = cv.active_ind
   WITH nocounter
  ;end select
  IF (error(errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Error selecting the CODE_VALUE table row for code set 207902: ",
    errmsg)
   GO TO exit_script
  ENDIF
  IF (curqual=1
   AND iactiveind=0)
   UPDATE  FROM code_value cv
    SET cv.active_ind = 1, cv.active_type_cd = reqdata->active_status_cd, cv.active_dt_tm =
     cnvtdatetime(sysdate),
     cv.inactive_dt_tm = null, cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_applctx =
     reqinfo->updt_applctx,
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(sysdate), cv.updt_id = reqinfo->
     updt_id,
     cv.updt_task = reqinfo->updt_task
    WHERE cv.code_value=dibusfceligcd
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error updating the CODE_VALUE table row for code set 207902: ",
     errmsg)
    GO TO exit_script
   ELSE
    COMMIT
    SET readme_data->message =
    "Success: the CODE_VALUE table row for code set 207902 was updated to ACTIVE"
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
