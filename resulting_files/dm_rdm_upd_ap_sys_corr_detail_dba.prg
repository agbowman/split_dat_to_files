CREATE PROGRAM dm_rdm_upd_ap_sys_corr_detail:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_upd_ap_sys_corr_detail..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE lnewseq = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 RECORD temp_hold(
   1 qual[*]
     2 sys_corr_id = f8
     2 sys_corr_detail_id = f8
     2 param_name = vc
     2 param_sequence = i4
     2 lookback_ind = i2
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 new_sequence = i4
 )
 SELECT INTO "nl:"
  ascd.sys_corr_id, ascd.sys_corr_detail_id, ascd.param_name,
  ascd.param_sequence, ascd.lookback_ind, ascd.parent_entity_name,
  ascd.parent_entity_id, ascd.updt_dt_tm
  FROM ap_sys_corr_detail ascd
  PLAN (ascd
   WHERE ascd.sys_corr_id > 0
    AND ascd.param_sequence=0)
  ORDER BY ascd.sys_corr_id, ascd.lookback_ind, ascd.param_name,
   ascd.sys_corr_detail_id
  HEAD REPORT
   lcnt = 0
  HEAD ascd.sys_corr_id
   lnewseq = 0
  HEAD ascd.lookback_ind
   lnewseq = 0
  HEAD ascd.param_name
   lnewseq = 0
  DETAIL
   lcnt += 1
   IF (mod(lcnt,10)=1)
    stat = alterlist(temp_hold->qual,(lcnt+ 9))
   ENDIF
   temp_hold->qual[lcnt].sys_corr_id = ascd.sys_corr_id, temp_hold->qual[lcnt].sys_corr_detail_id =
   ascd.sys_corr_detail_id, temp_hold->qual[lcnt].param_name = ascd.param_name,
   temp_hold->qual[lcnt].param_sequence = ascd.param_sequence, temp_hold->qual[lcnt].lookback_ind =
   ascd.lookback_ind, temp_hold->qual[lcnt].parent_entity_name = ascd.parent_entity_name,
   temp_hold->qual[lcnt].parent_entity_id = ascd.parent_entity_id
   CASE (ascd.param_name)
    OF "ALPHA":
     IF (ascd.parent_entity_name="ORDER_CATALOG")
      lnewseq += 1
     ENDIF
    OF "SECTION":
     IF (ascd.parent_entity_name="ORDER_CATALOG")
      lnewseq += 1
     ENDIF
    ELSE
     lnewseq += 1
   ENDCASE
   temp_hold->qual[lcnt].new_sequence = lnewseq
  FOOT REPORT
   stat = alterlist(temp_hold->qual,lcnt)
  WITH nocounter, forupdate(ascd)
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select ap_sys_corr_detail : ",errmsg)
  GO TO exit_script
 ELSEIF (lcnt=0)
  GO TO end_script
 ENDIF
 UPDATE  FROM ap_sys_corr_detail ascd,
   (dummyt d1  WITH seq = lcnt)
  SET ascd.param_sequence = temp_hold->qual[d1.seq].new_sequence, ascd.updt_dt_tm = sysdate, ascd
   .updt_id = reqinfo->updt_id,
   ascd.updt_cnt = (ascd.updt_cnt+ 1), ascd.updt_applctx = reqinfo->updt_applctx, ascd.updt_task =
   reqinfo->updt_task
  PLAN (d1)
   JOIN (ascd
   WHERE (temp_hold->qual[d1.seq].sys_corr_detail_id=ascd.sys_corr_detail_id)
    AND ascd.param_sequence=0)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update ap_sys_corr_detail : ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
#end_script
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
