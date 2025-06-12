CREATE PROGRAM dm_move_long_data
 RECORD dm_move(
   1 rlist[*]
     2 rowid = c18
     2 long_text_id = f8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_cnt = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i4
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 long_text = vc
     2 long_blob = gc
   1 rlist_count = i4
 )
 SET max_records = 50
 SET last_rowid = fillstring(18," ")
 SET done = 0
 SET first_one = 1
 SET long_text_ind =  $2
 WHILE (done=0)
   SET dm_move->rlist_count = 0
   SELECT
    IF (first_one=1
     AND long_text_ind=1)
     pk_id = lt.long_text_id, lt.updt_id, lt.updt_dt_tm,
     lt.updt_cnt, lt.updt_task, lt.updt_applctx,
     lt.active_ind, lt.active_status_cd, lt.active_status_dt_tm,
     lt.active_status_prsnl_id, lt.parent_entity_name, lt.parent_entity_id,
     lt_fld = lt.long_text
     FROM long_text lt
     WHERE (lt.parent_entity_name= $1)
    ELSEIF (first_one=1)
     pk_id = lt.long_blob_id, lt.updt_id, lt.updt_dt_tm,
     lt.updt_cnt, lt.updt_task, lt.updt_applctx,
     lt.active_ind, lt.active_status_cd, lt.active_status_dt_tm,
     lt.active_status_prsnl_id, lt.parent_entity_name, lt.parent_entity_id,
     lt_fld = lt.long_blob
     FROM long_blob lt
     WHERE (lt.parent_entity_name= $1)
    ELSEIF (first_one=0
     AND long_text_ind=1)
     pk_id = lt.long_text_id, lt.updt_id, lt.updt_dt_tm,
     lt.updt_cnt, lt.updt_task, lt.updt_applctx,
     lt.active_ind, lt.active_status_cd, lt.active_status_dt_tm,
     lt.active_status_prsnl_id, lt.parent_entity_name, lt.parent_entity_id,
     lt_fld = lt.long_text
     FROM long_text lt
     WHERE (lt.parent_entity_name= $1)
      AND lt.rowid > last_rowid
    ELSE
     pk_id = lt.long_blob_id, lt.updt_id, lt.updt_dt_tm,
     lt.updt_cnt, lt.updt_task, lt.updt_applctx,
     lt.active_ind, lt.active_status_cd, lt.active_status_dt_tm,
     lt.active_status_prsnl_id, lt.parent_entity_name, lt.parent_entity_id,
     lt_fld = lt.long_blob
     FROM long_blob lt
     WHERE (lt.parent_entity_name= $1)
      AND lt.rowid > last_rowid
    ENDIF
    INTO "nl:"
    ORDER BY lt.rowid
    DETAIL
     dm_move->rlist_count = (dm_move->rlist_count+ 1), stat = alterlist(dm_move->rlist,dm_move->
      rlist_count), dm_move->rlist[dm_move->rlist_count].rowid = lt.rowid,
     last_rowid = lt.rowid, dm_move->rlist[dm_move->rlist_count].long_text_id = pk_id, dm_move->
     rlist[dm_move->rlist_count].updt_id = lt.updt_id,
     dm_move->rlist[dm_move->rlist_count].updt_dt_tm = lt.updt_dt_tm, dm_move->rlist[dm_move->
     rlist_count].updt_cnt = lt.updt_cnt, dm_move->rlist[dm_move->rlist_count].updt_task = lt
     .updt_task,
     dm_move->rlist[dm_move->rlist_count].updt_applctx = lt.updt_applctx, dm_move->rlist[dm_move->
     rlist_count].active_ind = lt.active_ind, dm_move->rlist[dm_move->rlist_count].active_status_cd
      = lt.active_status_cd,
     dm_move->rlist[dm_move->rlist_count].active_status_dt_tm = lt.active_status_dt_tm, dm_move->
     rlist[dm_move->rlist_count].active_status_prsnl_id = lt.active_status_prsnl_id, dm_move->rlist[
     dm_move->rlist_count].parent_entity_name = lt.parent_entity_name,
     dm_move->rlist[dm_move->rlist_count].parent_entity_id = lt.parent_entity_id
     IF (long_text_ind=1)
      dm_move->rlist[dm_move->rlist_count].long_text = lt_fld
     ELSE
      dm_move->rlist[dm_move->rlist_count].long_blob = lt_fld
     ENDIF
    WITH nocounter, maxqual(lt,value(max_records))
   ;end select
   IF ((dm_move->rlist_count < max_records))
    SET done = 1
   ENDIF
   IF ((dm_move->rlist_count != 0))
    IF (long_text_ind=1)
     INSERT  FROM long_text_reference ltr,
       (dummyt d  WITH seq = value(dm_move->rlist_count))
      SET ltr.long_text_id = dm_move->rlist[d.seq].long_text_id, ltr.updt_id = dm_move->rlist[d.seq].
       updt_id, ltr.updt_dt_tm = cnvtdatetime(dm_move->rlist[d.seq].updt_dt_tm),
       ltr.updt_cnt = dm_move->rlist[d.seq].updt_cnt, ltr.updt_task = dm_move->rlist[d.seq].updt_task,
       ltr.updt_applctx = dm_move->rlist[d.seq].updt_applctx,
       ltr.active_ind = dm_move->rlist[d.seq].active_ind, ltr.active_status_cd = dm_move->rlist[d.seq
       ].active_status_cd, ltr.active_status_dt_tm = cnvtdatetime(dm_move->rlist[d.seq].
        active_status_dt_tm),
       ltr.active_status_prsnl_id = dm_move->rlist[d.seq].active_status_prsnl_id, ltr
       .parent_entity_name = dm_move->rlist[d.seq].parent_entity_name, ltr.parent_entity_id = dm_move
       ->rlist[d.seq].parent_entity_id,
       ltr.long_text = dm_move->rlist[d.seq].long_text
      PLAN (d)
       JOIN (ltr)
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM long_blob_reference lbr,
       (dummyt d  WITH seq = value(dm_move->rlist_count))
      SET lbr.long_blob_id = dm_move->rlist[d.seq].long_text_id, lbr.updt_id = dm_move->rlist[d.seq].
       updt_id, lbr.updt_dt_tm = cnvtdatetime(dm_move->rlist[d.seq].updt_dt_tm),
       lbr.updt_cnt = dm_move->rlist[d.seq].updt_cnt, lbr.updt_task = dm_move->rlist[d.seq].updt_task,
       lbr.updt_applctx = dm_move->rlist[d.seq].updt_applctx,
       lbr.active_ind = dm_move->rlist[d.seq].active_ind, lbr.active_status_cd = dm_move->rlist[d.seq
       ].active_status_cd, lbr.active_status_dt_tm = cnvtdatetime(dm_move->rlist[d.seq].
        active_status_dt_tm),
       lbr.active_status_prsnl_id = dm_move->rlist[d.seq].active_status_prsnl_id, lbr
       .parent_entity_name = dm_move->rlist[d.seq].parent_entity_name, lbr.parent_entity_id = dm_move
       ->rlist[d.seq].parent_entity_id,
       lbr.long_blob = dm_move->rlist[d.seq].long_blob
      PLAN (d)
       JOIN (lbr)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   SET first_one = 0
 ENDWHILE
END GO
