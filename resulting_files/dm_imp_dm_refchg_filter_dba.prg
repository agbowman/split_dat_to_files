CREATE PROGRAM dm_imp_dm_refchg_filter:dba
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
 SET readme_data->message = "Readme failure.  Starting DM_IMP_DM_REFCHG_FILTER script."
 FREE RECORD val_drf_exists
 RECORD val_drf_exists(
   1 list[*]
     2 status = i2
 )
 FREE RECORD dm_error
 RECORD dm_error(
   1 message = vc
 )
 DECLARE v_req_size = i4 WITH protect, noconstant(0)
 SET v_req_size = size(requestin->list_0,5)
 SET stat = alterlist(val_drf_exists->list,v_req_size)
 FOR (didr_for_cnt = 1 TO v_req_size)
  SET requestin->list_0[didr_for_cnt].table_name = cnvtupper(requestin->list_0[didr_for_cnt].
   table_name)
  SET requestin->list_0[didr_for_cnt].filter_type = cnvtupper(requestin->list_0[didr_for_cnt].
   filter_type)
 ENDFOR
 UPDATE  FROM dm_refchg_filter drf,
   (dummyt d  WITH seq = v_req_size)
  SET drf.filter_type = requestin->list_0[d.seq].filter_type, drf.statement_ind = cnvtint(requestin->
    list_0[d.seq].statement_ind), drf.active_ind = cnvtint(requestin->list_0[d.seq].active_ind),
   drf.filter_version_nbr = cnvtint(requestin->list_0[d.seq].filter_version_nbr), drf.updt_applctx =
   reqinfo->updt_applctx, drf.updt_cnt = (drf.updt_cnt+ 1),
   drf.updt_dt_tm = cnvtdatetime(curdate,curtime3), drf.updt_id = reqinfo->updt_id, drf.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (drf
   WHERE (drf.table_name=requestin->list_0[d.seq].table_name))
  WITH nocounter, status(val_drf_exists->list[d.seq].status)
 ;end update
 IF (error(dm_error->message,1) != 0)
  SET readme_data->message = concat("FAIL:",dm_error->message)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_refchg_filter drf,
   (dummyt d  WITH seq = v_req_size)
  SET drf.table_name = requestin->list_0[d.seq].table_name, drf.filter_type = requestin->list_0[d.seq
   ].filter_type, drf.statement_ind = cnvtint(requestin->list_0[d.seq].statement_ind),
   drf.active_ind = cnvtint(requestin->list_0[d.seq].active_ind), drf.filter_version_nbr = cnvtint(
    requestin->list_0[d.seq].filter_version_nbr), drf.updt_applctx = reqinfo->updt_applctx,
   drf.updt_cnt = 0, drf.updt_dt_tm = cnvtdatetime(curdate,curtime3), drf.updt_id = reqinfo->updt_id,
   drf.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (val_drf_exists->list[d.seq].status=0))
   JOIN (drf)
  WITH nocounter
 ;end insert
 IF (error(dm_error->message,1) != 0)
  SET readme_data->message = concat("FAIL:",dm_error->message)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_refchg_filter drf,
   (dummyt d  WITH seq = v_req_size)
  PLAN (d)
   JOIN (drf
   WHERE (drf.table_name=requestin->list_0[d.seq].table_name))
  WITH outerjoin = d, dontexist
 ;end select
 IF (error(dm_error->message,1) != 0)
  SET readme_data->message = concat("FAIL:",dm_error->message)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: all dm_refchg_filter data imported"
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
 FREE RECORD dm_error
 FREE RECORD val_drf_exists
END GO
