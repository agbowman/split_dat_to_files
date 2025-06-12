CREATE PROGRAM dm_imp_dm_refchg_trg_col:dba
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
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_req_size = i4 WITH protect, noconstant(0)
 DECLARE for_cnt = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting DM_IMP_DM_REFCHG_TRG_COL script."
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
 FOR (for_cnt = 1 TO v_req_size)
  SET requestin->list_0[for_cnt].table_name = trim(cnvtupper(requestin->list_0[for_cnt].table_name),3
   )
  SET requestin->list_0[for_cnt].column_name = trim(cnvtupper(requestin->list_0[for_cnt].column_name),
   3)
 ENDFOR
 IF (v_req_size > 0)
  UPDATE  FROM dm_refchg_trg_col drtc,
    (dummyt d  WITH seq = v_req_size)
   SET drtc.active_ind = cnvtreal(requestin->list_0[d.seq].active_ind), drtc.updt_applctx = reqinfo->
    updt_applctx, drtc.updt_cnt = (drtc.updt_cnt+ 1),
    drtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), drtc.updt_id = reqinfo->updt_id, drtc.updt_task
     = reqinfo->updt_task
   PLAN (d)
    JOIN (drtc
    WHERE (drtc.table_name=requestin->list_0[d.seq].table_name)
     AND (drtc.column_name=requestin->list_0[d.seq].column_name))
   WITH nocounter, status(rs_exists->list[d.seq].status)
  ;end update
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAILED to update:",dm_error->message)
   GO TO exit_script
  ENDIF
  INSERT  FROM dm_refchg_trg_col drtc,
    (dummyt d  WITH seq = v_req_size)
   SET drtc.dm_refchg_trg_col_id = seq(dm_clinical_seq,nextval), drtc.table_name = requestin->list_0[
    d.seq].table_name, drtc.column_name = requestin->list_0[d.seq].column_name,
    drtc.active_ind = cnvtreal(requestin->list_0[d.seq].active_ind), drtc.updt_applctx = reqinfo->
    updt_applctx, drtc.updt_cnt = 0,
    drtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), drtc.updt_id = reqinfo->updt_id, drtc.updt_task
     = reqinfo->updt_task
   PLAN (d
    WHERE (rs_exists->list[d.seq].status=0))
    JOIN (drtc)
   WITH nocounter
  ;end insert
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAILED to insert:",dm_error->message)
   GO TO exit_script
  ENDIF
  SET row_cnt = 0
  SELECT INTO "nl:"
   FROM dm_refchg_trg_col drtc,
    (dummyt d  WITH seq = v_req_size)
   PLAN (d)
    JOIN (drtc
    WHERE (drtc.table_name=requestin->list_0[d.seq].table_name)
     AND (drtc.column_name=requestin->list_0[d.seq].column_name))
   DETAIL
    row_cnt = (row_cnt+ 1)
   WITH nocounter
  ;end select
  IF (error(dm_error->message,1) != 0)
   SET readme_data->message = concat("FAILED to select:",dm_error->message)
   GO TO exit_script
  ENDIF
  IF (row_cnt=v_req_size)
   SET readme_data->status = "S"
   SET readme_data->message = "SUCCESS: all dm_refchg_trg_col data imported"
  ELSE
   SET readme_data->message =
   "FAIL: number of rows in dm_refchg_trg_col != number of rows in record structure."
  ENDIF
 ELSE
  SET readme_data->message =
  "FAIL:The request structure has not been popluated with dm_refchg_trg_col information."
  GO TO exit_script
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 FREE RECORD dm_error
 FREE RECORD rs_exists
END GO
