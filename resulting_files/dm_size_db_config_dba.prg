CREATE PROGRAM dm_size_db_config:dba
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
 SET dsdc_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 FREE RECORD dsdc_err
 RECORD dsdc_err(
   1 ind = i2
   1 msg = vc
 )
 SET dsdc_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdc_inhouse = 1
  WITH nocounter
 ;end select
 SET dummy = 0
 CALL dsdc_ccl_err(dummy)
 IF (dsdc_inhouse)
  SET dsdc_status = "I"
  GO TO exit_script
 ENDIF
 SET dsdc_cnt = 0
 SET dsdc_cnt = size(requestin->list_0,5)
 SET dsdc_u_id = 222
 SET dsdc_u_task = 333
 IF (validate(dml_chk->qual[1].dml_type,"@")="@")
  FREE RECORD dml_chk
  RECORD dml_chk(
    1 qual[*]
      2 dml_type = c1
    1 num_of_inserts = i4
    1 num_of_updates = i4
    1 num_of_none = i4
  )
 ENDIF
 SET dm_debug_flag = 0
 SET dm_debug_flag = validate(dm_debug,0)
 SELECT INTO "nl:"
  da.synonym_name, da.owner
  FROM dba_synonyms da
  WHERE da.synonym_name="DM_SIZE_DB_CONFIG"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 CALL dsdc_ccl_err(dummy)
 IF (curqual=0)
  SET dsdc_status = "Y"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(dml_chk->qual,dsdc_cnt)
 FOR (dc_cnt = 1 TO dsdc_cnt)
  SET dml_chk->qual[dc_cnt].dml_type = "I"
  SET dml_chk->num_of_inserts = (dml_chk->num_of_inserts+ 1)
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_size_db_config d,
   (dummyt t  WITH seq = value(dsdc_cnt))
  PLAN (t)
   JOIN (d
   WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version)
    AND (d.config_parm=requestin->list_0[t.seq].config_parm)
    AND (d.parm_type=requestin->list_0[t.seq].parm_type))
  DETAIL
   IF (cnvtint(requestin->list_0[t.seq].updt_cnt) >= d.updt_cnt)
    dml_chk->qual[t.seq].dml_type = "U", dml_chk->num_of_updates = (dml_chk->num_of_updates+ 1),
    dml_chk->num_of_inserts = (dml_chk->num_of_inserts - 1)
   ELSE
    dml_chk->qual[t.seq].dml_type = "N", dml_chk->num_of_none = (dml_chk->num_of_none+ 1), dml_chk->
    num_of_inserts = (dml_chk->num_of_inserts - 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL dsdc_ccl_err(dummy)
 IF (dm_debug_flag)
  CALL echorecord(requestin)
  CALL echo(build("num_inserts=",dml_chk->num_of_inserts))
  CALL echo(build("num_updates=",dml_chk->num_of_updates))
 ENDIF
 IF ((dml_chk->num_of_inserts >= 1))
  INSERT  FROM dm_size_db_config d,
    (dummyt t  WITH seq = value(dsdc_cnt))
   SET d.db_version = cnvtint(requestin->list_0[t.seq].db_version), d.config_parm = requestin->
    list_0[t.seq].config_parm, d.parm_type = requestin->list_0[t.seq].parm_type,
    d.value = requestin->list_0[t.seq].value, d.updt_applctx = cnvtint(requestin->list_0[t.seq].
     updt_applctx), d.updt_dt_tm = cnvtdatetime(curdate,0),
    d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt), d.updt_id = dsdc_u_id, d.updt_task =
    dsdc_u_task
   PLAN (t
    WHERE (dml_chk->qual[t.seq].dml_type="I"))
    JOIN (d)
   WITH nocounter
  ;end insert
  IF (dm_debug_flag=1)
   CALL echo(build("inserted =",curqual))
  ENDIF
  CALL dsdc_ccl_err(dummy)
  COMMIT
 ENDIF
 IF ((dml_chk->num_of_updates >= 1))
  UPDATE  FROM dm_size_db_config d,
    (dummyt t  WITH seq = value(dsdc_cnt))
   SET d.db_version = cnvtint(requestin->list_0[t.seq].db_version), d.config_parm = requestin->
    list_0[t.seq].config_parm, d.parm_type = requestin->list_0[t.seq].parm_type,
    d.value = requestin->list_0[t.seq].value, d.updt_applctx = cnvtint(requestin->list_0[t.seq].
     updt_applctx), d.updt_dt_tm = cnvtdatetime(curdate,0),
    d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt), d.updt_id = dsdc_u_id, d.updt_task =
    dsdc_u_task
   PLAN (t
    WHERE (dml_chk->qual[t.seq].dml_type="U"))
    JOIN (d
    WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version)
     AND (d.config_parm=requestin->list_0[t.seq].config_parm)
     AND (d.parm_type=requestin->list_0[t.seq].parm_type))
   WITH nocounter
  ;end update
  IF (dm_debug_flag=1)
   CALL echo(build("updated =",curqual))
  ENDIF
  CALL dsdc_ccl_err(dummy)
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_size_db_config d,
   (dummyt t  WITH seq = value(dsdc_cnt))
  PLAN (t)
   JOIN (d
   WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version)
    AND (d.config_parm=requestin->list_0[t.seq].config_parm)
    AND (d.parm_type=requestin->list_0[t.seq].parm_type)
    AND d.updt_cnt >= cnvtint(requestin->list_0[t.seq].updt_cnt))
  WITH nocounter
 ;end select
 IF (dm_debug_flag=1)
  CALL echo(build("checked =",curqual))
 ENDIF
 CALL dsdc_ccl_err(dummy)
 IF (curqual=dsdc_cnt)
  SET dsdc_status = "S"
 ELSE
  SET dsdc_err->msg = "Not all records in CSV file are accounted for in the database."
 ENDIF
 SUBROUTINE dsdc_ccl_err(dummy)
  SET dsdc_err->ind = error(dsdc_err->msg,1)
  IF ((dsdc_err->ind > 0))
   SET dsdc_status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF (dsdc_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table DM_SIZE_DB_CONFIG."
 ELSEIF (dsdc_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = dsdc_err->msg
 ELSEIF (dsdc_status="I")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success: Readme does not run INHOUSE."
 ELSEIF (dsdc_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Successful.  DM_SIZE_DB_CONFIG table was successfully updated."
 ENDIF
 IF (validate(readme_data->readme_id,0)=0)
  CALL echorecord(readme_data)
 ELSE
  EXECUTE dm_readme_status
 ENDIF
END GO
