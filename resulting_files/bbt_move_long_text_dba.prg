CREATE PROGRAM bbt_move_long_text:dba
 RECORD longtexttable(
   1 rowlist[*]
     2 long_text_id = f8
     2 long_text = vc
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 )
 SET error_ind = 0
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  lt.*
  FROM long_text lt,
   interp_result ir
  PLAN (lt
   WHERE lt.long_text_id > 0)
   JOIN (ir
   WHERE ir.long_text_id=lt.long_text_id)
  ORDER BY lt.long_text_id
  HEAD REPORT
   row_cnt = 0, stat = alterlist(longtexttable->rowlist,5)
  HEAD lt.long_text_id
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,5)=1
    AND row_cnt != 1)
    stat = alterlist(longtexttable->rowlist,(row_cnt+ 4))
   ENDIF
   longtexttable->rowlist[row_cnt].long_text_id = lt.long_text_id, longtexttable->rowlist[row_cnt].
   long_text = lt.long_text, longtexttable->rowlist[row_cnt].parent_entity_name = lt
   .parent_entity_name,
   longtexttable->rowlist[row_cnt].parent_entity_id = lt.parent_entity_id, longtexttable->rowlist[
   row_cnt].active_ind = lt.active_ind, longtexttable->rowlist[row_cnt].active_status_cd = lt
   .active_status_cd,
   longtexttable->rowlist[row_cnt].active_status_dt_tm = cnvtdatetime(lt.active_status_dt_tm),
   longtexttable->rowlist[row_cnt].active_status_prsnl_id = lt.active_status_prsnl_id, longtexttable
   ->rowlist[row_cnt].updt_cnt = lt.updt_cnt,
   longtexttable->rowlist[row_cnt].updt_dt_tm = cnvtdatetime(lt.updt_dt_tm), longtexttable->rowlist[
   row_cnt].updt_id = lt.updt_id, longtexttable->rowlist[row_cnt].updt_task = lt.updt_task,
   longtexttable->rowlist[row_cnt].updt_applctx = lt.updt_applctx
  DETAIL
   row + 0
  FOOT REPORT
   stat = alterlist(longtexttable->rowlist,row_cnt)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  SET row_cnt = value(size(longtexttable->rowlist,5))
  FOR (idx = 1 TO row_cnt)
    INSERT  FROM long_text_reference ltr
     SET ltr.long_text_id = longtexttable->rowlist[idx].long_text_id, ltr.long_text_id =
      longtexttable->rowlist[idx].long_text_id, ltr.long_text = longtexttable->rowlist[idx].long_text,
      ltr.parent_entity_name = longtexttable->rowlist[idx].parent_entity_name, ltr.parent_entity_id
       = longtexttable->rowlist[idx].parent_entity_id, ltr.active_ind = longtexttable->rowlist[idx].
      active_ind,
      ltr.active_status_cd = longtexttable->rowlist[idx].active_status_cd, ltr.active_status_dt_tm =
      cnvtdatetime(longtexttable->rowlist[idx].active_status_dt_tm), ltr.active_status_prsnl_id =
      longtexttable->rowlist[idx].active_status_prsnl_id,
      ltr.updt_cnt = longtexttable->rowlist[idx].updt_cnt, ltr.updt_dt_tm = cnvtdatetime(
       longtexttable->rowlist[idx].updt_dt_tm), ltr.updt_id = longtexttable->rowlist[idx].updt_id,
      ltr.updt_task = longtexttable->rowlist[idx].updt_task, ltr.updt_applctx = longtexttable->
      rowlist[idx].updt_applctx
     WITH nocounter
    ;end insert
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus != 0)
     SET error_ind = 1
     GO TO exit_script
    ENDIF
  ENDFOR
  IF (nerrorstatus=0)
   SELECT INTO "nl:"
    FROM long_text lt,
     (dummyt d  WITH seq = value(size(longtexttable->rowlist,5)))
    PLAN (d)
     JOIN (lt
     WHERE (lt.long_text_id=longtexttable->rowlist[d.seq].long_text_id))
    WITH nocounter, forupdate(lt)
   ;end select
   SET nerrorstatus = error(serrormsg,0)
   IF (nerrorstatus=0)
    UPDATE  FROM long_text lt,
      (dummyt d  WITH seq = value(size(longtexttable->rowlist,5)))
     SET lt.active_ind = 0, lt.active_status_cd = reqdata->inactive_status_cd, lt.active_status_dt_tm
       = cnvtdatetime(curdate,curtime3),
      lt.updt_cnt = (longtexttable->rowlist[d.seq].updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (lt
      WHERE (lt.long_text_id=longtexttable->rowlist[d.seq].long_text_id))
     WITH nocounter
    ;end update
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     SET error_ind = error_ind
    ELSE
     SET error_ind = 1
    ENDIF
   ELSE
    SET error_ind = 1
   ENDIF
  ELSE
   SET error_ind = 1
  ENDIF
 ELSE
  SET error_ind = 1
 ENDIF
#exit_script
 IF (error_ind=1)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
