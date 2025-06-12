CREATE PROGRAM da_rdm_upd_groupcodes:dba
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
 SET readme_data->message = "Readme failure starting da_rdm_upd_groupcodes."
 DECLARE errmsg = vc WITH protect
 DECLARE newname = vc WITH protect
 SET newname = "PathNet Lab Management"
 UPDATE  FROM code_value
  SET display = newname, display_key = cnvtupper(cnvtalphanum(newname)), updt_dt_tm = cnvtdatetime(
    sysdate),
   updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
   updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4101479836"
   AND display="Pathnet Lab Management"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update PathNet group code (CKI.CODEVALUE!4101479836) display: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value
  SET definition = newname, updt_dt_tm = cnvtdatetime(sysdate), updt_cnt = (updt_cnt+ 1),
   updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4101479836"
   AND definition="Pathnet Lab Management"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update PathNet group code (CKI.CODEVALUE!4101479836) definition: ",errmsg)
  GO TO exit_script
 ENDIF
 SET newname = "PharmNet"
 UPDATE  FROM code_value
  SET display = newname, display_key = cnvtupper(cnvtalphanum(newname)), updt_dt_tm = cnvtdatetime(
    sysdate),
   updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
   updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4102347833"
   AND display="Pharmnet"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update PharmNet group code (CKI.CODEVALUE!4102347833) display: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value
  SET definition = newname, updt_dt_tm = cnvtdatetime(sysdate), updt_cnt = (updt_cnt+ 1),
   updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4102347833"
   AND definition="Pharmnet"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update PharmNet group code (CKI.CODEVALUE!4102347833) definition: ",errmsg)
  GO TO exit_script
 ENDIF
 SET newname = "RadNet"
 UPDATE  FROM code_value
  SET display = newname, display_key = cnvtupper(cnvtalphanum(newname)), updt_dt_tm = cnvtdatetime(
    sysdate),
   updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
   updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4101827394"
   AND display="Radnet"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update RadNet group code (CKI.CODEVALUE!4101827394) display: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value
  SET definition = newname, updt_dt_tm = cnvtdatetime(sysdate), updt_cnt = (updt_cnt+ 1),
   updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task
  WHERE cki="CKI.CODEVALUE!4101827394"
   AND definition="Radnet"
   AND active_ind=1
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat(
   "Failure to update RadNet group code (CKI.CODEVALUE!4101827394) definition: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "All present code values updated successfully."
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
