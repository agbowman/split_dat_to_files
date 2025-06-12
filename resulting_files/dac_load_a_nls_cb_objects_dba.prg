CREATE PROGRAM dac_load_a_nls_cb_objects:dba
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
 SET readme_data->message = "Starting dac_load_a_nls_cb_objects..."
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list[*]
     2 index_name = vc
     2 table_name = vc
     2 exists_ind = i2
 )
 DECLARE exists_ind = i2 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE rec_size = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE rec_idx = i4 WITH protect, noconstant(0)
 DECLARE nls_question_nbr = i4 WITH protect, constant(1)
 SET stat = alterlist(copy_requestin->list,rec_size)
 FOR (rec_idx = 1 TO rec_size)
   SET copy_requestin->list[rec_idx].index_name = requestin->list_0[rec_idx].index_name
   SET copy_requestin->list[rec_idx].table_name = requestin->list_0[rec_idx].table_name
   SET copy_requestin->list[rec_idx].exists_ind = 0
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_cb_objects dco,
   (dummyt d  WITH seq = rec_size)
  PLAN (d)
   JOIN (dco
   WHERE (dco.object_name=copy_requestin->list[d.seq].index_name)
    AND dco.object_type="INDEX")
  DETAIL
   copy_requestin->list[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (error(err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Select failed:",err_msg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_cb_objects dco,
   (dummyt d  WITH seq = rec_size)
  SET dco.object_name = copy_requestin->list[d.seq].index_name, dco.object_type = "INDEX", dco
   .table_name = copy_requestin->list[d.seq].table_name,
   dco.question_nbr = nls_question_nbr, dco.active_ind = 1, dco.updt_applctx = reqinfo->updt_applctx,
   dco.updt_task = reqinfo->updt_task, dco.updt_id = reqinfo->updt_id, dco.updt_cnt = 0,
   dco.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (copy_requestin->list[d.seq].exists_ind=0))
   JOIN (dco)
  WITH nocounter
 ;end insert
 IF (error(err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Insert failed:",err_msg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 FREE RECORD copy_requestin
END GO
