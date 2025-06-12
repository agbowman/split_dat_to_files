CREATE PROGRAM dm_size_db_cntl_files:dba
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
 SET dsdf_status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 FREE RECORD dsdf_err
 RECORD dsdf_err(
   1 ind = i2
   1 msg = vc
 )
 SET dsdf_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   dsdf_inhouse = 1
  WITH nocounter
 ;end select
 SET dummy = 0
 CALL dsdf_ccl_err(dummy)
 IF (dsdf_inhouse)
  SET dsdf_status = "I"
  GO TO exit_script
 ENDIF
 SET dsdf_cnt = 0
 SET dsdf_cnt = size(requestin->list_0,5)
 SET dsdf_u_id = 222
 SET dsdf_u_task = 333
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
  WHERE da.synonym_name="DM_SIZE_DB_CNTL_FILES"
   AND da.owner="PUBLIC"
  WITH nocounter
 ;end select
 CALL dsdf_ccl_err(dummy)
 IF (curqual=0)
  SET dsdf_status = "Y"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(dml_chk->qual,dsdf_cnt)
 FOR (dc_cnt = 1 TO dsdf_cnt)
  SET dml_chk->qual[dc_cnt].dml_type = "I"
  SET dml_chk->num_of_inserts = (dml_chk->num_of_inserts+ 1)
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_size_db_cntl_files d,
   (dummyt t  WITH seq = value(dsdf_cnt))
  PLAN (t)
   JOIN (d
   WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version))
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
 CALL dsdf_ccl_err(dummy)
 IF (dm_debug_flag)
  CALL echorecord(requestin)
  CALL echo(build("num_inserts=",dml_chk->num_of_inserts))
  CALL echo(build("num_updates=",dml_chk->num_of_updates))
 ENDIF
 IF ((dml_chk->num_of_inserts >= 1))
  INSERT  FROM dm_size_db_cntl_files d,
    (dummyt t  WITH seq = value(dsdf_cnt))
   SET d.db_version = cnvtint(requestin->list_0[t.seq].db_version), d.cntl_file_num = cnvtint(
     requestin->list_0[t.seq].cntl_file_num), d.file_name = requestin->list_0[t.seq].file_name,
    d.updt_applctx = cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(
     curdate,0), d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt),
    d.updt_id = dsdf_u_id, d.updt_task = dsdf_u_task, d.file_size = cnvtreal(requestin->list_0[t.seq]
     .file_size)
   PLAN (t
    WHERE (dml_chk->qual[t.seq].dml_type="I"))
    JOIN (d)
   WITH nocounter
  ;end insert
  IF (dm_debug_flag=1)
   CALL echo(build("inserted =",curqual))
  ENDIF
  CALL dsdf_ccl_err(dummy)
  COMMIT
 ENDIF
 IF ((dml_chk->num_of_updates >= 1))
  UPDATE  FROM dm_size_db_cntl_files d,
    (dummyt t  WITH seq = value(dsdf_cnt))
   SET d.db_version = cnvtint(requestin->list_0[t.seq].db_version), d.cntl_file_num = cnvtint(
     requestin->list_0[t.seq].cntl_file_num), d.file_name = requestin->list_0[t.seq].file_name,
    d.updt_applctx = cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(
     curdate,0), d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt),
    d.updt_id = dsdf_u_id, d.updt_task = dsdf_u_task, d.file_size = cnvtreal(requestin->list_0[t.seq]
     .file_size)
   PLAN (t
    WHERE (dml_chk->qual[t.seq].dml_type="U"))
    JOIN (d
    WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version))
   WITH nocounter
  ;end update
  IF (dm_debug_flag=1)
   CALL echo(build("updated =",curqual))
  ENDIF
  CALL dsdf_ccl_err(dummy)
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_size_db_cntl_files d,
   (dummyt t  WITH seq = value(dsdf_cnt))
  PLAN (t)
   JOIN (d
   WHERE d.db_version=cnvtint(requestin->list_0[t.seq].db_version)
    AND d.updt_cnt >= cnvtint(requestin->list_0[t.seq].updt_cnt))
  WITH nocounter
 ;end select
 IF (dm_debug_flag=1)
  CALL echo(build("checked =",curqual))
 ENDIF
 CALL dsdf_ccl_err(dummy)
 IF (curqual=dsdf_cnt)
  SET dsdf_status = "S"
 ELSE
  SET dsdf_err->msg = "Not all records from the CSV file are accounted for in the database."
 ENDIF
 SUBROUTINE dsdf_ccl_err(dummy)
  SET dsdf_err->ind = error(dsdf_err->msg,1)
  IF ((dsdf_err->ind > 0))
   SET dsdf_status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF (dsdf_status="Y")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed.  There is no synonym for table DM_SIZE_DB_CNTL_FILES."
 ELSEIF (dsdf_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = dsdf_err->msg
 ELSEIF (dsdf_status="I")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success: Readme does not run INHOUSE."
 ELSEIF (dsdf_status="S")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme Successful.  DM_SIZE_DB_CNTL_FILES table was successfully updated."
 ENDIF
 IF (validate(readme_data->readme_id,0)=0)
  CALL echorecord(readme_data)
 ELSE
  EXECUTE dm_readme_status
 ENDIF
END GO
