CREATE PROGRAM dm_rmc_reset_dai_child:dba
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
 SET readme_data->message = "Fail: start of dm_rmc_reset_dai_child.prg"
 DECLARE v_rec_size = i4 WITH protect, noconstant(0)
 DECLARE v_err_msg = c132 WITH protect, noconstant(fillstring(132,""))
 DECLARE v_inhouse_ind = i2 WITH protect, noconstant(0)
 DECLARE v_admin_upd_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_local_upd_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_admin_sel_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_local_sel_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   v_inhouse_ind = 1
  WITH nocounter
 ;end select
 IF (error(v_err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail on inhouse check:",v_err_msg)
  GO TO exit_program
 ENDIF
 IF (v_inhouse_ind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Not executed since we are in inhouse domain."
  GO TO exit_program
 ENDIF
 SET v_rec_size = size(requestin->list_0,5)
 IF (v_rec_size=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Fail: dm_rmc_reset_dai.csv is empty"
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc dcc,
   (dummyt d  WITH seq = value(v_rec_size))
  SET dcc.defining_attribute_ind = 0
  PLAN (d)
   JOIN (dcc
   WHERE (dcc.table_name=requestin->list_0[d.seq].table_name)
    AND (dcc.column_name=requestin->list_0[d.seq].column_name)
    AND dcc.updt_cnt <= cnvtint(requestin->list_0[d.seq].updt_cnt))
  WITH nocounter
 ;end update
 SET v_admin_upd_cnt = curqual
 IF (error(v_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail on update of dm_columns_doc:",v_err_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_columns_doc dcc,
   (dummyt d  WITH seq = v_rec_size)
  PLAN (d)
   JOIN (dcc
   WHERE (dcc.table_name=requestin->list_0[d.seq].table_name)
    AND (dcc.column_name=requestin->list_0[d.seq].column_name)
    AND dcc.updt_cnt <= cnvtint(requestin->list_0[d.seq].updt_cnt)
    AND dcc.defining_attribute_ind=0)
  DETAIL
   v_admin_sel_cnt = (v_admin_sel_cnt+ 1)
  WITH nocounter
 ;end select
 IF (error(v_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail on select of dm_columns_doc:",v_err_msg)
  GO TO exit_program
 ENDIF
 IF (validate(dm_err->debug_flag,0) > 0)
  CALL echo(build("*** v_admin_upd_cnt = ",v_admin_upd_cnt))
  CALL echo(build("*** v_admin_sel_cnt = ",v_admin_sel_cnt))
 ENDIF
 IF (v_admin_upd_cnt != v_admin_sel_cnt)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: not all DM_COLUMNS_DOC rows updated properly"
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_columns_doc_local dccl,
   (dummyt d  WITH seq = value(v_rec_size))
  SET dccl.defining_attribute_ind = 0
  PLAN (d)
   JOIN (dccl
   WHERE (dccl.table_name=requestin->list_0[d.seq].table_name)
    AND (dccl.column_name=requestin->list_0[d.seq].column_name)
    AND dccl.updt_cnt <= cnvtint(requestin->list_0[d.seq].updt_cnt))
  WITH nocounter
 ;end update
 SET v_local_upd_cnt = curqual
 IF (error(v_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail on update of dm_columns_doc_local: ",v_err_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_columns_doc_local dccl,
   (dummyt d  WITH seq = v_rec_size)
  PLAN (d)
   JOIN (dccl
   WHERE (dccl.table_name=requestin->list_0[d.seq].table_name)
    AND (dccl.column_name=requestin->list_0[d.seq].column_name)
    AND dccl.updt_cnt <= cnvtint(requestin->list_0[d.seq].updt_cnt)
    AND dccl.defining_attribute_ind=0)
  DETAIL
   v_local_sel_cnt = (v_local_sel_cnt+ 1)
  WITH nocounter
 ;end select
 IF (error(v_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail on select of dm_columns_doc_local: ",v_err_msg)
  GO TO exit_program
 ENDIF
 IF (validate(dm_err->debug_flag,0) > 0)
  CALL echo(build("*** v_local_upd_cnt = ",v_local_upd_cnt))
  CALL echo(build("*** v_local_sel_cnt = ",v_local_sel_cnt))
 ENDIF
 IF (v_local_upd_cnt != v_local_sel_cnt)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: not all DM_COLUMNS_DOC_LOCAL rows updated properly"
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: defining_attribute_ind column updated"
#exit_program
END GO
