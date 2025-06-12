CREATE PROGRAM dm_merge_undo:dba
 SET error_in_undo = 0
 SUBROUTINE write_merge_error(merge_id,action,merge_id_ndx,table_name)
   SET err_num = 1
   SET err_msg = fillstring(132," ")
   WHILE (err_num != 0
    AND (merge_ids->qual[merge_id_ndx].error_cnt < 10))
    SET err_num = error(err_msg,0)
    IF (err_num > 0)
     SET merge_ids->qual[merge_id_ndx].error_cnt = (merge_ids->qual[merge_id_ndx].error_cnt+ 1)
     SET stat = alterlist(merge_ids->qual[merge_id_ndx].equal,merge_ids->qual[merge_id_ndx].error_cnt
      )
     IF ((merge_ids->qual[merge_id_ndx].error_cnt=1))
      INSERT  FROM dm_merge_error dme
       (dme.merge_id, dme.error_seq, dme.error_msg,
       dme.error_num, dme.table_name)
       VALUES(merge_id, merge_ids->qual[merge_id_ndx].error_cnt, action,
       err_num, table_name)
      ;end insert
      SET merge_ids->qual[merge_id_ndx].error_cnt = (merge_ids->qual[merge_id_ndx].error_cnt+ 1)
      SET stat = alterlist(merge_ids->qual[merge_id_ndx].equal,merge_ids->qual[merge_id_ndx].
       error_cnt)
     ENDIF
     INSERT  FROM dm_merge_error dme2
      (dme2.merge_id, dme2.error_seq, dme2.error_msg,
      dme2.error_num, dme2.table_name)
      VALUES(merge_id, merge_ids->qual[merge_id_ndx].error_cnt, err_msg,
      err_num, table_name)
     ;end insert
     SET error_in_undo = 1
     SET merge_ids->qual[merge_id_ndx].merge_status_flag = 6
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE force_merge_error(merge_id,action,merge_id_ndx,table_name,error_msg)
   SET merge_ids->qual[merge_id_ndx].error_cnt = (merge_ids->qual[merge_id_ndx].error_cnt+ 1)
   SET stat = alterlist(merge_ids->qual[merge_id_ndx].equal,merge_ids->qual[merge_id_ndx].error_cnt)
   INSERT  FROM dm_merge_error dme3
    (dme3.merge_id, dme3.error_seq, dme3.error_msg,
    dme3.error_num, dme3.table_name)
    VALUES(merge_id, merge_ids->qual[merge_id_ndx].error_cnt, action,
    0, table_name)
   ;end insert
   SET merge_ids->qual[merge_id_ndx].error_cnt = (merge_ids->qual[merge_id_ndx].error_cnt+ 1)
   INSERT  FROM dm_merge_error dme4
    (dme4.merge_id, dme4.error_seq, dme4.error_msg,
    dme4.error_num, dme4.table_name)
    VALUES(merge_id, merge_ids->qual[merge_id_ndx].error_cnt, error_msg,
    0, table_name)
   ;end insert
   SET error_in_undo = 1
   SET merge_ids->qual[merge_id_ndx].merge_status_flag = 6
 END ;Subroutine
 SUBROUTINE undo_long_row(tname,v_merge_action_id,v_pk_where)
   IF (((tname="LONG_TEXT") OR (tname="LONG_TEXT_REFERENCE")) )
    SELECT INTO "nl:"
     FROM dm_merge_action_log_dtl dmald
     WHERE dmald.merge_action_id=v_merge_action_id
      AND dmald.column_name="LONG_TEXT"
     DETAIL
      str->long = dmald.old_long
     WITH nocounter
    ;end select
   ENDIF
   IF (((tname="LONG_BLOB") OR (tname="LONG_BLOB_REFERENCE")) )
    SELECT INTO "nl:"
     FROM dm_merge_action_blob dmab
     WHERE dmab.merge_action_id=v_merge_action_id
      AND dmab.column_name="LONG_BLOB"
     DETAIL
      str->raw = dmald.old_raw
     WITH nocounter
    ;end select
   ENDIF
   SET v_rowid = fillstring(18," ")
   CALL echo("about to get a rowid")
   CALL echo(v_pk_where)
   CALL parser("select into 'nl:' lt.rowid from ")
   CALL parser(tname)
   CALL parser(" lt ")
   CALL parser(v_pk_where)
   CALL parser("detail v_rowid=lt.rowid with nocounter go")
   IF (tname="LONG_TEXT")
    UPDATE  FROM long_text lt
     SET lt.updt_cnt =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_CNT"), lt.updt_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_DT_TM"), lt.updt_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_ID"),
      lt.updt_task =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_TASK"), lt.updt_applctx =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_APPLCTX"), lt.active_ind =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_IND"),
      lt.active_status_cd =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_CD"), lt.active_status_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_DT_TM"), lt.active_status_prsnl_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_PRSNL_ID"),
      lt.parent_entity_name =
      (SELECT
       old_vc
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_NAME"), lt.parent_entity_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_ID"), lt.long_text = str->long
     WHERE lt.rowid=v_rowid
     WITH nocounter
    ;end update
   ELSEIF (tname="LONG_TEXT_REFERENCE")
    UPDATE  FROM long_text lt
     SET lt.updt_cnt =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_CNT"), lt.updt_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_DT_TM"), lt.updt_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_ID"),
      lt.updt_task =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_TASK"), lt.updt_applctx =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_APPLCTX"), lt.active_ind =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_IND"),
      lt.active_status_cd =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_CD"), lt.active_status_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_DT_TM"), lt.active_status_prsnl_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_PRSNL_ID"),
      lt.parent_entity_name =
      (SELECT
       old_vc
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_NAME"), lt.parent_entity_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_ID"), lt.long_text = str->long
     WHERE lt.rowid=v_rowid
     WITH nocounter
    ;end update
   ELSEIF (tname="LONG_BLOB")
    UPDATE  FROM long_blob lt
     SET lt.updt_cnt =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_CNT"), lt.updt_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_DT_TM"), lt.updt_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_ID"),
      lt.updt_task =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_TASK"), lt.updt_applctx =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_APPLCTX"), lt.active_ind =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_IND"),
      lt.active_status_cd =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_CD"), lt.active_status_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_DT_TM"), lt.active_status_prsnl_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_PRSNL_ID"),
      lt.parent_entity_name =
      (SELECT
       old_vc
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_NAME"), lt.parent_entity_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_ID"), lt.long_blob = str->raw
     WHERE lt.rowid=v_rowid
     WITH nocounter
    ;end update
   ELSEIF (tname="LONG_BLOB_REFERENCE")
    UPDATE  FROM long_blob_reference lt
     SET lt.updt_cnt =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_CNT"), lt.updt_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_DT_TM"), lt.updt_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_ID"),
      lt.updt_task =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_TASK"), lt.updt_applctx =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="UPDT_APPLCTX"), lt.active_ind =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_IND"),
      lt.active_status_cd =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_CD"), lt.active_status_dt_tm =
      (SELECT
       old_dt_tm
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_DT_TM"), lt.active_status_prsnl_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="ACTIVE_STATUS_PRSNL_ID"),
      lt.parent_entity_name =
      (SELECT
       old_vc
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_NAME"), lt.parent_entity_id =
      (SELECT
       old_num
       FROM dm_merge_action_log_dtl dmald
       WHERE dmald.merge_action_id=v_merge_action_id
        AND column_name="PARENT_ENTITY_ID"), lt.long_blob = str->raw
     WHERE lt.rowid=v_rowid
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 merge_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 RECORD merge_ids(
   1 mcnt = i4
   1 qual[*]
     2 merge_id = f8
     2 merge_status_flag = i4
     2 error_cnt = i4
     2 equal[*]
       3 error_msg = vc
       3 error_num = i4
 )
 RECORD undo_actions(
   1 actions_cnt = i4
   1 qual[*]
     2 merge_id = f8
     2 merge_ids_ndx = i4
     2 merge_action_id = f8
     2 pk_where = vc
     2 update_ind = i4
     2 table_name = vc
     2 col_cnt = i4
     2 col_qual[*]
       3 col_name = vc
       3 col_type = vc
 )
 SET undo_actions->actions_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_merge_action_log dmal
  WHERE (dmal.merge_id >= request->merge_id)
  ORDER BY dmal.merge_id DESC, dmal.merge_action_id DESC
  HEAD dmal.merge_id
   merge_ids->mcnt = (merge_ids->mcnt+ 1), stat = alterlist(merge_ids->qual,merge_ids->mcnt),
   merge_ids->qual[merge_ids->mcnt].merge_id = dmal.merge_id,
   merge_ids->qual[merge_ids->mcnt].error_cnt = 0, merge_ids->qual[merge_ids->mcnt].merge_status_flag
    = 5
  DETAIL
   undo_actions->actions_cnt = (undo_actions->actions_cnt+ 1), cur_act = undo_actions->actions_cnt,
   stat = alterlist(undo_actions->qual,undo_actions->actions_cnt),
   undo_actions->qual[cur_act].merge_id = dmal.merge_id, undo_actions->qual[cur_act].merge_ids_ndx =
   merge_ids->mcnt, undo_actions->qual[cur_act].merge_action_id = dmal.merge_action_id,
   undo_actions->qual[cur_act].pk_where = dmal.pk_where, undo_actions->qual[cur_act].update_ind =
   dmal.update_ind, undo_actions->qual[cur_act].table_name = dmal.table_name,
   undo_actions->qual[cur_act].col_cnt = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_action_log_dtl dmald,
   (dummyt d  WITH seq = value(undo_actions->actions_cnt))
  PLAN (d)
   JOIN (dmald
   WHERE (dmald.merge_action_id=undo_actions->qual[d.seq].merge_action_id))
  DETAIL
   undo_actions->qual[d.seq].col_cnt = (undo_actions->qual[d.seq].col_cnt+ 1), col_cnt = undo_actions
   ->qual[d.seq].col_cnt, stat = alterlist(undo_actions->qual[d.seq].col_qual,undo_actions->qual[d
    .seq].col_cnt),
   undo_actions->qual[d.seq].col_qual[col_cnt].col_name = dmald.column_name, undo_actions->qual[d.seq
   ].col_qual[col_cnt].col_type = dmald.data_type
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_merge_action_blob dmab,
   (dummyt d  WITH seq = value(undo_actions->actions_cnt))
  PLAN (d)
   JOIN (dmab
   WHERE (dmab.merge_action_id=undo_actions->qual[d.seq].merge_action_id))
  DETAIL
   undo_actions->qual[d.seq].col_cnt = (undo_actions->qual[d.seq].col_cnt+ 1), col_cnt = undo_actions
   ->qual[d.seq].col_cnt, stat = alterlist(undo_actions->qual[d.seq].col_qual,undo_actions->qual[d
    .seq].col_cnt),
   undo_actions->qual[d.seq].col_qual[col_cnt].col_name = dmab.column_name, undo_actions->qual[d.seq]
   .col_qual[col_cnt].col_type = "LONG RAW"
  WITH nocounter
 ;end select
 RECORD str(
   1 str = vc
   1 long = vc
   1 raw = gc
 )
 SET msgnum = 0
 SET msg = fillstring(132," ")
 SET msgnum = error(msg,1)
 DELETE  FROM dm_merge_error dme,
   (dummyt d  WITH seq = value(merge_ids->mcnt))
  SET dme.seq = 1
  PLAN (d)
   JOIN (dme
   WHERE (dme.merge_id=merge_ids->qual[d.seq].merge_id))
  WITH nocounter
 ;end delete
 SET str->str = "Error deleting dm_merge_error rows"
 CALL write_merge_error(request->merge_id,str->str,merge_ids->mcnt,"dm_merge_error")
 SET i = 0
 WHILE ((i < undo_actions->actions_cnt)
  AND error_in_undo=0)
   SET i = (i+ 1)
   IF ((undo_actions->qual[i].update_ind=0))
    SET msgnum = error(msg,1)
    SET str->str = concat("delete from ",undo_actions->qual[i].table_name," ",undo_actions->qual[i].
     pk_where," go")
    CALL echo(str->str)
    CALL parser(str->str)
    IF (curqual=0)
     CALL force_merge_error(undo_actions->qual[i].merge_id,str->str,undo_actions->qual[i].
      merge_ids_ndx,undo_actions->qual[i].table_name,"DELETE AS PART OF UNDO HAD CURQUAL = 0")
    ENDIF
    CALL write_merge_error(undo_actions->qual[i].merge_id,str->str,undo_actions->qual[i].
     merge_ids_ndx,undo_actions->qual[i].table_name)
   ELSEIF ((((undo_actions->qual[i].table_name="LONG_TEXT")) OR ((((undo_actions->qual[i].table_name=
   "LONG_TEXT_REFERENCE")) OR ((((undo_actions->qual[i].table_name="LONG_BLOB")) OR ((undo_actions->
   qual[i].table_name="LONG_BLOB_REFERENCE"))) )) )) )
    CALL undo_long_row(undo_actions->qual[i].table_name,undo_actions->qual[i].merge_action_id,
     undo_actions->qual[i].pk_where)
   ELSE
    SET msgnum = error(msg,1)
    SET str->str = concat("update into ",undo_actions->qual[i].table_name," tn set ")
    CALL echo(str->str)
    CALL parser(str->str)
    FOR (j = 1 TO undo_actions->qual[i].col_cnt)
      IF (j > 1)
       SET str->str = ","
       CALL echo(str->str)
       CALL parser(str->str)
      ENDIF
      SET str->str = concat(" tn.",undo_actions->qual[i].col_qual[j].col_name)
      CALL echo(str->str)
      CALL parser(str->str)
      IF ((((undo_actions->qual[i].col_qual[j].col_type="VARCHAR")) OR ((((undo_actions->qual[i].
      col_qual[j].col_type="VARCHAR2")) OR ((undo_actions->qual[i].col_qual[j].col_type="CHAR"))) ))
      )
       SET str->str = "= (select dmld.old_vc "
      ELSEIF ((((undo_actions->qual[i].col_qual[j].col_type="NUMBER")) OR ((undo_actions->qual[i].
      col_qual[j].col_type="FLOAT"))) )
       SET str->str = "= (select dmld.old_num "
      ELSE
       SET str->str = "= (select dmld.old_dt_tm "
      ENDIF
      CALL echo(str->str)
      CALL parser(str->str)
      SET str->str = concat(" from dm_merge_action_log_dtl dmld "," where dmld.merge_action_id = ",
       cnvtstring(undo_actions->qual[i].merge_action_id)," and dmld.column_name = '",undo_actions->
       qual[i].col_qual[j].col_name,
       "')")
      CALL echo(str->str)
      CALL parser(str->str)
    ENDFOR
    SET str->str = concat(" ",undo_actions->qual[i].pk_where," go")
    CALL echo(str->str)
    CALL parser(str->str)
    IF (curqual=0)
     SET str->str = concat("UPDATE ",undo_actions->qual[i].table_name," ",undo_actions->qual[i].
      pk_where," go")
     CALL force_merge_error(undo_actions->qual[i].merge_id,str->str,undo_actions->qual[i].
      merge_ids_ndx,undo_actions->qual[i].table_name,"UPDATE AS PART OF UNDO HAD CURQUAL = 0")
    ENDIF
    SET str->str = concat("UPDATE ",undo_actions->qual[i].table_name," ",undo_actions->qual[i].
     pk_where," go")
    CALL write_merge_error(undo_actions->qual[i].merge_id,str->str,undo_actions->qual[i].
     merge_ids_ndx,undo_actions->qual[i].table_name)
   ENDIF
   IF (error_in_undo=0)
    DELETE  FROM dm_merge_action_blob
     WHERE (merge_action_id=undo_actions->qual[i].merge_action_id)
     WITH nocounter
    ;end delete
    DELETE  FROM dm_merge_action_log_dtl
     WHERE (merge_action_id=undo_actions->qual[i].merge_action_id)
     WITH nocounter
    ;end delete
    DELETE  FROM dm_merge_action_log
     WHERE (merge_action_id=undo_actions->qual[i].merge_action_id)
     WITH nocounter
    ;end delete
    SET str->str = concat("deleting for dm_merge_action* where merge_action_id ",cnvtstring(
      undo_actions->qual[i].merge_action_id))
    CALL write_merge_error(undo_actions->qual[i].merge_id,str->str,undo_actions->qual[i].
     merge_ids_ndx,undo_actions->qual[i].table_name)
   ENDIF
   IF (error_in_undo=0)
    SET merge_ids->qual[undo_actions->qual[i].merge_ids_ndx].merge_status_flag = 4
   ENDIF
 ENDWHILE
 DELETE  FROM dm_merge_translate dmt,
   (dummyt d  WITH seq = value(merge_ids->mcnt))
  SET dmt.seq = 1
  PLAN (d
   WHERE (merge_ids->qual[d.seq].merge_status_flag=4))
   JOIN (dmt
   WHERE (dmt.merge_id=merge_ids->qual[d.seq].merge_id))
  WITH nocounter
 ;end delete
 SET str->str = "Error deleting dm_merge_translate rows"
 CALL write_merge_error(request->merge_id,str->str,merge_ids->mcnt,"dm_merge_translate")
 UPDATE  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(merge_ids->mcnt))
  SET dma.merge_status_flag = 4
  PLAN (d
   WHERE (merge_ids->qual[d.seq].merge_status_flag=4))
   JOIN (dma
   WHERE (dma.merge_id=merge_ids->qual[d.seq].merge_id))
  WITH nocounter
 ;end update
 SET str->str = "Error updating the status dm_merge_action rows"
 CALL write_merge_error(request->merge_id,str->str,merge_ids->mcnt,"dm_merge_action")
 UPDATE  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(merge_ids->mcnt))
  SET dma.merge_status_flag = 6
  PLAN (d
   WHERE (merge_ids->qual[d.seq].merge_status_flag=6))
   JOIN (dma
   WHERE (dma.merge_id=merge_ids->qual[d.seq].merge_id))
  WITH nocounter
 ;end update
 UPDATE  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(merge_ids->mcnt))
  SET dma.merge_status_flag = 3
  PLAN (d
   WHERE (merge_ids->qual[d.seq].merge_status_flag=5))
   JOIN (dma
   WHERE (dma.merge_id=merge_ids->qual[d.seq].merge_id))
  WITH nocounter
 ;end update
 SET reply->status_data.status = "S"
 COMMIT
END GO
