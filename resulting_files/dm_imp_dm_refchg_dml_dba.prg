CREATE PROGRAM dm_imp_dm_refchg_dml:dba
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
 DECLARE dml_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_req_size = i4 WITH protect, noconstant(0)
 DECLARE for_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_req_ins_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_req_del_cnt = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting DM_IMP_DM_REFCHG_DML script."
 FREE RECORD rs_exists
 RECORD rs_exists(
   1 list[*]
     2 status = i2
 )
 FREE RECORD dm_error
 RECORD dm_error(
   1 message = vc
 )
 SET v_req_size = size(requestin->list_0,5)
 SET stat = alterlist(rs_exists->list,v_req_size)
 SET v_req_ins_cnt = 0
 FOR (for_cnt = 1 TO v_req_size)
   SET requestin->list_0[for_cnt].table_name = trim(cnvtupper(requestin->list_0[for_cnt].table_name),
    3)
   SET requestin->list_0[for_cnt].column_name = trim(cnvtupper(requestin->list_0[for_cnt].column_name
     ),3)
   SET requestin->list_0[for_cnt].dml_attribute = trim(cnvtupper(requestin->list_0[for_cnt].
     dml_attribute),3)
   IF ((requestin->list_0[for_cnt].delete_ind="0"))
    SET v_req_ins_cnt = (v_req_ins_cnt+ 1)
   ENDIF
 ENDFOR
 IF (v_req_size > 0)
  DELETE  FROM dm_refchg_dml drd,
    (dummyt d  WITH seq = v_req_size)
   SET drd.seq = 1
   PLAN (d
    WHERE (requestin->list_0[d.seq].delete_ind="1"))
    JOIN (drd
    WHERE (drd.table_name=requestin->list_0[d.seq].table_name)
     AND (drd.column_name=requestin->list_0[d.seq].column_name)
     AND (drd.dml_attribute=requestin->list_0[d.seq].dml_attribute))
   WITH nocounter, status(rs_exists->list[d.seq].status)
  ;end delete
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_refchg_dml drd,
    (dummyt d  WITH seq = v_req_size)
   SET drd.dml_value = requestin->list_0[d.seq].dml_value, drd.data_type = cnvtupper(requestin->
     list_0[d.seq].data_type), drd.updt_applctx = reqinfo->updt_applctx,
    drd.updt_cnt = (drd.updt_cnt+ 1), drd.updt_dt_tm = cnvtdatetime(curdate,curtime3), drd.updt_id =
    reqinfo->updt_id,
    drd.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (requestin->list_0[d.seq].delete_ind="0"))
    JOIN (drd
    WHERE (drd.table_name=requestin->list_0[d.seq].table_name)
     AND (drd.column_name=requestin->list_0[d.seq].column_name)
     AND (drd.dml_attribute=requestin->list_0[d.seq].dml_attribute))
   WITH nocounter, status(rs_exists->list[d.seq].status)
  ;end update
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  INSERT  FROM dm_refchg_dml drd,
    (dummyt d  WITH seq = v_req_size)
   SET drd.table_name = requestin->list_0[d.seq].table_name, drd.column_name = requestin->list_0[d
    .seq].column_name, drd.dml_attribute = requestin->list_0[d.seq].dml_attribute,
    drd.dml_value = requestin->list_0[d.seq].dml_value, drd.data_type = cnvtupper(requestin->list_0[d
     .seq].data_type), drd.updt_applctx = reqinfo->updt_applctx,
    drd.updt_cnt = 0, drd.updt_dt_tm = cnvtdatetime(curdate,curtime3), drd.updt_id = reqinfo->updt_id,
    drd.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (rs_exists->list[d.seq].status=0)
     AND (requestin->list_0[d.seq].delete_ind="0"))
    JOIN (drd)
   WITH nocounter
  ;end insert
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  SET dml_cnt = 0
  SELECT INTO "nl:"
   FROM dm_refchg_dml drd,
    (dummyt d  WITH seq = v_req_size)
   PLAN (d)
    JOIN (drd
    WHERE (drd.table_name=requestin->list_0[d.seq].table_name)
     AND (drd.column_name=requestin->list_0[d.seq].column_name)
     AND (drd.dml_attribute=requestin->list_0[d.seq].dml_attribute))
   DETAIL
    dml_cnt = (dml_cnt+ 1)
   WITH nocounter
  ;end select
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  SET v_req_del_cnt = 0
  SELECT INTO "nl:"
   FROM dm_refchg_dml drd,
    (dummyt d  WITH seq = v_req_size)
   PLAN (d
    WHERE (requestin->list_0[d.seq].delete_ind="1"))
    JOIN (drd
    WHERE (drd.table_name=requestin->list_0[d.seq].table_name)
     AND (drd.column_name=requestin->list_0[d.seq].column_name)
     AND (drd.dml_attribute=requestin->list_0[d.seq].dml_attribute))
   DETAIL
    v_req_del_cnt = (v_req_del_cnt+ 1)
   WITH nocounter
  ;end select
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAIL:",dm_error->message)
   GO TO exit_script
  ENDIF
  IF (dml_cnt=v_req_ins_cnt
   AND v_req_del_cnt=0)
   SET readme_data->status = "S"
   SET readme_data->message = "SUCCESS: all dm_refchg_dml data imported"
  ELSE
   IF (dml_cnt=v_req_ins_cnt
    AND v_req_del_cnt > 0)
    SET readme_data->message =
    "FAIL: number of rows deleted from dm_refchg_dml != number of rows in record structure."
   ELSEIF (dml_cnt != v_req_ins_cnt
    AND v_req_del_cnt=0)
    SET readme_data->message =
    "FAIL: number of rows inserted into dm_refchg_dml != number of rows in record structure."
   ELSE
    SET readme_data->message =
    "FAIL: number of rows deleted/inserted in dm_refchg_dml != number of rows in record structure."
   ENDIF
  ENDIF
 ELSE
  SET readme_data->message =
  "FAIL:The request structure has not been popluated with dm_refchg_dml information."
  GO TO exit_script
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD dm_error
 FREE RECORD rs_exists
END GO
