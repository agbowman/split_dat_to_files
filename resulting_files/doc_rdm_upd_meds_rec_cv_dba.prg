CREATE PROGRAM doc_rdm_upd_meds_rec_cv:dba
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
 SET readme_data->message = "Readme doc_rdm_upd_meds_rec_cv failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value c
  SET c.display = "Medications Reconciliation", c.display_key = "MEDICATIONSRECONCILIATION", c
   .definition = "Medications Reconciliation",
   c.cdf_meaning = "MEDS_REC", c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id
  WHERE c.cki="CKI.CODEVALUE!4113756928"
   AND c.display_key="MEDICATIONSRECONCIALTION"
   AND c.display="Medications Reconcialtion"
   AND c.active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = build(errmsg,"Failed updating MEDS_REC codevalue data in codeset 32000."
   )
  GO TO exit_script
 ELSEIF (curqual=0)
  ROLLBACK
  SET readme_data->status = "S"
  SET readme_data->message = build(errmsg,
   "MEDS_REC codevalue data in codeset 32000 has already been changed.")
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme updated MEDS_REC codevalue data in codeset 32000."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
