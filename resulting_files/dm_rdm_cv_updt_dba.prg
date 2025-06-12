CREATE PROGRAM dm_rdm_cv_updt:dba
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
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE update_ind = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script code_value_readme..."
 SELECT INTO "nl:"
  c.display, c.definition, c.cki
  FROM code_value c
  WHERE c.code_set=6020
   AND c.display="New Results Indicator"
   AND c.definition="DEFPATLIST"
  DETAIL
   IF (c.cki != "CKI.CODEVALUE!2806802")
    update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind)
  UPDATE  FROM code_value c
   SET c.cki = "CKI.CODEVALUE!2806802", c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime
    (curdate,curtime)
   WHERE c.code_set=6020
    AND c.display="New Results Indicator"
    AND c.definition="DEFPATLIST"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed updating DEFPATLIST on code_set 6020:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET update_ind = 0
 SELECT INTO "nl:"
  c.display, c.definition, c.cki
  FROM code_value c
  WHERE c.code_set=6020
   AND c.display="New Results Indicator"
   AND c.definition="SNDUMMY"
  DETAIL
   IF (c.cki != "CKI.CODEVALUE!2807038")
    update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind)
  UPDATE  FROM code_value c
   SET c.cki = "CKI.CODEVALUE!2807038", c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime
    (curdate,curtime)
   WHERE c.code_set=6020
    AND c.display="New Results Indicator"
    AND c.definition="SNDUMMY"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed updating SNDUMMY on code_set 6020:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET update_ind = 0
 SELECT INTO "nl:"
  c.display, c.definition, c.cki
  FROM code_value c
  WHERE c.code_set=6020
   AND c.display="New Results Indicator"
   AND c.definition="TRKPATLIST"
  DETAIL
   IF (c.cki != "CKI.CODEVALUE!2806921")
    update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind)
  UPDATE  FROM code_value c
   SET c.cki = "CKI.CODEVALUE!2806921", c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime
    (curdate,curtime)
   WHERE c.code_set=6020
    AND c.display="New Results Indicator"
    AND c.definition="TRKPATLIST"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed updating TRKPATLIST on code_set 6020:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET update_ind = 0
 SELECT INTO "nl:"
  c.display, c.definition, c.cki
  FROM code_value c
  WHERE c.code_set=6020
   AND c.display="New Results Indicator"
   AND c.definition="SNCASELIST"
  DETAIL
   IF (c.cki != "CKI.CODEVALUE!3450759")
    update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind)
  UPDATE  FROM code_value c
   SET c.cki = "CKI.CODEVALUE!3450759", c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime
    (curdate,curtime)
   WHERE c.code_set=6020
    AND c.display="New Results Indicator"
    AND c.definition="SNCASELIST"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed updating SNCASELIST on code_set 6020:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET update_ind = 0
 SELECT INTO "nl:"
  c.display, c.definition, c.cki
  FROM code_value c
  WHERE c.code_set=6020
   AND c.display="New Results Indicator"
   AND c.definition="TRKBEDLIST"
  DETAIL
   IF (c.cki != "CKI.CODEVALUE!501332")
    update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind)
  UPDATE  FROM code_value c
   SET c.cki = "CKI.CODEVALUE!501332", c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime
    (curdate,curtime)
   WHERE c.code_set=6020
    AND c.display="New Results Indicator"
    AND c.definition="TRKBEDLIST"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed updating TRKBEDLIST on code_set 6020:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Success: Updated code_set 6020 on code_value table"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
