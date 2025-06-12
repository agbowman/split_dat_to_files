CREATE PROGRAM dm_cmb_add_det_generic2:dba
 SET dcadg_dm_entity_cnt = 0
 SET dcadg_dm_child_table = rcmblist->qual[maincount1].cmb_entity
 SET dcadg_pknum = size(rcmblist->qual[maincount1].cmb_entity_pk,5)
 SET rcmblist->qual[maincount1].execute_flag = 0
 SET dcadg_dm_data_type = fillstring(9," ")
 FREE SET rpkdet
 SET p_buf[1] = "record rPkDet"
 SET p_buf[2] = "(    1 qual[*]"
 SET p_buf[3] = "       2 entity_id = f8"
 FOR (dcadg_cnt1 = 1 TO dcadg_pknum)
  SET dcadg_dm_data_type = rcmblist->qual[maincount1].cmb_entity_pk[dcadg_cnt1].data_type
  CASE (dcadg_dm_data_type)
   OF "VARCHAR":
   OF "CHAR":
   OF "VARCHAR2":
    SET p_buf[(dcadg_cnt1+ 3)] = concat("       2 pk",build(dcadg_cnt1),"= vc")
   OF "TIMESTAMP":
    SET p_buf[(dcadg_cnt1+ 3)] = concat("       2 pk",build(dcadg_cnt1),"= dm12")
   OF "TIME":
   OF "DATE":
    SET p_buf[(dcadg_cnt1+ 3)] = concat("       2 pk",build(dcadg_cnt1),"= dq8")
   OF "INTEGER":
   OF "DOUBLE":
   OF "BIGINT":
   OF "NUMBER":
   OF "FLOAT":
    SET p_buf[(dcadg_cnt1+ 3)] = concat("       2 pk",build(dcadg_cnt1),"= f8")
  ENDCASE
 ENDFOR
 SET p_buf[(dcadg_cnt1+ 4)] = ") go"
 FOR (dcadg_buf_cnt = 1 TO (dcadg_cnt1+ 4))
  CALL parser(p_buf[dcadg_buf_cnt])
  SET p_buf[dcadg_buf_cnt] = fillstring(132," ")
 ENDFOR
 SET p_buf[1] = "select into 'nl:' x.seq, y = seq(COMBINE_SEQ, nextval)"
 SET p_buf[2] = concat("from   ",trim(dcadg_dm_child_table)," x")
 SET p_buf[3] = concat("where  x.",trim(rcmblist->qual[maincount1].cmb_entity_fk)," = CMB_FROM_ID")
 SET p_buf[4] = "detail"
 SET p_buf[5] = "       dcadg_dm_entity_cnt = dcadg_dm_entity_cnt + 1"
 SET p_buf[6] = "       stat = alterlist(rPkDet->qual, dcadg_dm_entity_cnt)"
 SET p_buf[7] = "       rPkDet->qual[dcadg_dm_entity_cnt]->entity_id = y"
 FOR (dcadg_cnt1 = 1 TO dcadg_pknum)
   SET p_buf[(dcadg_cnt1+ 7)] = concat("       rPkDet->qual[dcadg_dm_entity_cnt]->pk",build(
     dcadg_cnt1)," = x.",trim(rcmblist->qual[maincount1].cmb_entity_pk[dcadg_cnt1].col_name))
 ENDFOR
 SET p_buf[(dcadg_cnt1+ 8)] = "with   nocounter go"
 FOR (dcadg_buf_cnt = 1 TO (dcadg_cnt1+ 8))
   IF (dm_debug_cmb=1)
    CALL echo(p_buf[dcadg_buf_cnt])
   ENDIF
   CALL parser(p_buf[dcadg_buf_cnt])
   SET p_buf[dcadg_buf_cnt] = fillstring(132," ")
 ENDFOR
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  GO TO det_generic2_err
 ENDIF
 IF (dcadg_dm_entity_cnt > 0)
  SET rcmblist->qual[maincount1].execute_flag = 1
 ENDIF
 INSERT  FROM combine_detail cd,
   (dummyt d  WITH seq = value(dcadg_dm_entity_cnt))
  SET cd.combine_detail_id = rpkdet->qual[d.seq].entity_id, cd.combine_id = request->xxx_combine[
   icombine].xxx_combine_id, cd.entity_name = dcadg_dm_child_table,
   cd.entity_id = rpkdet->qual[d.seq].entity_id, cd.combine_action_cd = cmb_action, cd.attribute_name
    = rcmblist->qual[maincount1].cmb_entity_fk,
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
  GO TO det_generic2_err
 ENDIF
 SET count_of_inserts += curqual
 IF (dm_debug_cmb=1)
  CALL echo(build(trim(dcadg_dm_child_table),": count_of_inserts=",count_of_inserts))
 ENDIF
 FOR (dcadg_cnt2 = 1 TO dcadg_pknum)
   IF ((rcmblist->qual[maincount1].cmb_entity_pk[dcadg_cnt2].data_type != patstring("TIMESTAMP*")))
    SET p_buf[1] = "insert into ENTITY_DETAIL ed, (dummyt d with seq=value(dcadg_dm_entity_cnt)) set"
    SET p_buf[2] = "ed.entity_id = rPkDet->qual[d.seq]->entity_id,"
    SET p_buf[3] =
    "ed.column_name = rCmbList->qual[maincount1]->cmb_entity_pk[dcadg_cnt2]->col_name,"
    SET p_buf[4] =
    "ed.data_type   = rCmbList->qual[maincount1]->cmb_entity_pk[dcadg_cnt2]->data_type,"
    CASE (rcmblist->qual[maincount1].cmb_entity_pk[dcadg_cnt2].data_type)
     OF "VARCHAR":
     OF "CHAR":
     OF "VARCHAR2":
      SET p_buf[5] = concat("ed.data_char = rPkDet->qual[d.seq]->pk",build(dcadg_cnt2))
     OF "TIME":
     OF "DATE":
      SET p_buf[5] = concat("ed.data_date = cnvtdatetime(rPkDet->qual[d.seq]->pk",build(dcadg_cnt2),
       ")")
     OF "INTEGER":
     OF "DOUBLE":
     OF "BIGINT":
     OF "NUMBER":
     OF "FLOAT":
      SET p_buf[5] = concat("ed.data_number = rPkDet->qual[d.seq]->pk",build(dcadg_cnt2))
    ENDCASE
    SET p_buf[6] = "plan d where rPkDet->qual[d.seq]->entity_id > 0 join ed with nocounter go"
    FOR (dcadg_buf_cnt = 1 TO 6)
     CALL parser(p_buf[dcadg_buf_cnt])
     SET p_buf[dcadg_buf_cnt] = fillstring(132," ")
    ENDFOR
    SET ecode = error(emsg,1)
    IF (ecode != 0)
     SET failed = ccl_error
     GO TO det_generic2_err
    ENDIF
   ENDIF
 ENDFOR
#det_generic2_err
 FREE RECORD rpkdet
END GO
