CREATE PROGRAM dm_cmb_add_det_metadata2:dba
 SET dcadm_dm_entity_cnt = 0
 SET dcadm_dm_child_table = rcmbmetadatalist->qual[maincount5].cmb_entity
 FREE SET rpkdet
 SET p_buf[1] = "record rPkDet"
 SET p_buf[2] = "(    1 qual[*]"
 SET p_buf[3] = "       2 entity_id = f8"
 SET p_buf[4] = "       2 pk1 = f8"
 SET p_buf[5] = ") go"
 FOR (dcadm_buf_cnt = 1 TO 5)
  CALL parser(p_buf[dcadm_buf_cnt])
  SET p_buf[dcadm_buf_cnt] = fillstring(132," ")
 ENDFOR
 SET p_buf[1] = "select into 'nl:' x.seq, y = seq(COMBINE_SEQ, nextval)"
 SET p_buf[2] = concat("from   ",trim(dcadm_dm_child_table)," x")
 SET p_buf[3] = concat("where x.",trim(rcmbmetadatalist->qual[maincount5].cmb_entity_attribute),
  " =  CMB_FROM_ID")
 SET p_buf[4] = concat("and ",trim(rcmbmetadatalist->qual[maincount5].where_clause))
 SET p_buf[5] = "detail"
 SET p_buf[6] = "       dcadm_dm_entity_cnt = dcadm_dm_entity_cnt + 1"
 SET p_buf[7] = "       stat = alterlist(rPkDet->qual, dcadm_dm_entity_cnt)"
 SET p_buf[8] = "       rPkDet->qual[dcadm_dm_entity_cnt]->entity_id = y"
 SET p_buf[9] = concat("       rPkDet->qual[dcadm_dm_entity_cnt]->pk1 = x.",trim(rcmbmetadatalist->
   qual[maincount5].cmb_entity_pk))
 SET p_buf[10] = "with   nocounter go"
 IF (dm_debug_cmb=1)
  CALL echo(build("CMB_FROM_ID = ",cmb_from_id))
 ENDIF
 FOR (dcadm_buf_cnt = 1 TO 10)
   IF (dm_debug_cmb=1)
    CALL echo(p_buf[dcadm_buf_cnt])
   ENDIF
   CALL parser(p_buf[dcadm_buf_cnt])
   SET p_buf[dcadm_buf_cnt] = fillstring(132," ")
 ENDFOR
 CALL echorecord(rcmbmetadatalist)
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  GO TO det_metadata2_err
 ENDIF
 IF (dcadm_dm_entity_cnt=0)
  SET rcmbmetadatalist->qual[maincount5].ignore_ind = 1
 ELSE
  SET rcmbmetadatalist->qual[maincount5].ignore_ind = 0
 ENDIF
 INSERT  FROM combine_detail cd,
   (dummyt d  WITH seq = value(dcadm_dm_entity_cnt))
  SET cd.combine_detail_id = rpkdet->qual[d.seq].entity_id, cd.combine_id = request->xxx_combine[
   icombine].xxx_combine_id, cd.entity_name = dcadm_dm_child_table,
   cd.entity_id = rpkdet->qual[d.seq].entity_id, cd.combine_action_cd = rcmbmetadatalist->qual[
   maincount5].cmb_action_cd, cd.attribute_name = rcmbmetadatalist->qual[maincount5].
   cmb_entity_attribute,
   cd.active_ind = active_active_ind, cd.active_status_cd = reqdata->active_status_cd, cd
   .active_status_dt_tm = cnvtdatetime(sysdate),
   cd.active_status_prsnl_id = reqinfo->updt_id, cd.updt_cnt = init_updt_cnt, cd.updt_dt_tm =
   cnvtdatetime(sysdate),
   cd.updt_id = reqinfo->updt_id, cd.updt_task = reqinfo->updt_task, cd.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (rpkdet->qual[d.seq].entity_id > 0))
   JOIN (cd)
  WITH nocounter
 ;end insert
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  GO TO det_metadata2_err
 ENDIF
 SET count_of_inserts += curqual
 IF (dm_debug_cmb=1)
  CALL echo(build(trim(dcadm_dm_child_table),": count_of_inserts=",count_of_inserts))
 ENDIF
 SET p_buf[1] = "insert into ENTITY_DETAIL ed, (dummyt d with seq=value(dcadm_dm_entity_cnt)) set"
 SET p_buf[2] = "ed.entity_id = rPkDet->qual[d.seq]->entity_id,"
 SET p_buf[3] = "ed.column_name = rCmbMetadataList->qual[maincount5]->cmb_entity_pk,"
 SET p_buf[4] = "ed.data_type   = 'FLOAT',"
 SET p_buf[5] = "ed.data_number = rPkDet->qual[d.seq]->pk1"
 SET p_buf[6] = "plan d where rPkDet->qual[d.seq]->entity_id > 0 join ed with nocounter go"
 FOR (dcadm_buf_cnt = 1 TO 6)
  CALL parser(p_buf[dcadm_buf_cnt])
  SET p_buf[dcadm_buf_cnt] = fillstring(132," ")
 ENDFOR
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  GO TO det_generic2_err
 ENDIF
#det_metadata2_err
 FREE RECORD rpkdet
END GO
