CREATE PROGRAM bed_ens_fn_event_loc:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET loc_cnt = 0
 SET event_cnt = size(request->elist,5)
 FOR (x = 1 TO event_cnt)
  SET loc_cnt = size(request->elist[x].llist,5)
  IF (loc_cnt > 0)
   INSERT  FROM track_group tg,
     (dummyt d  WITH seq = loc_cnt)
    SET tg.parent_value = request->elist[x].llist[d.seq].code_value, tg.child_value = request->elist[
     x].track_event_id, tg.child_table = "TRACK_EVENT",
     tg.tracking_rule = request->elist[x].llist[d.seq].rule, tg.tracking_group_cd = request->
     trk_group_code_value, tg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     tg.updt_id = reqinfo->updt_id, tg.updt_task = reqinfo->updt_task, tg.updt_cnt = 0,
     tg.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (request->elist[x].llist[d.seq].action_flag=1))
     JOIN (tg)
    WITH nocounter
   ;end insert
   UPDATE  FROM track_group tg,
     (dummyt d  WITH seq = loc_cnt)
    SET tg.tracking_rule = request->elist[x].llist[d.seq].rule, tg.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), tg.updt_id = reqinfo->updt_id,
     tg.updt_task = reqinfo->updt_task, tg.updt_cnt = (tg.updt_cnt+ 1), tg.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d
     WHERE (request->elist[x].llist[d.seq].action_flag=2))
     JOIN (tg
     WHERE (tg.tracking_group_cd=request->trk_group_code_value)
      AND tg.child_table="TRACK_EVENT"
      AND (tg.child_value=request->elist[x].track_event_id)
      AND (tg.parent_value=request->elist[x].llist[d.seq].code_value))
    WITH nocounter
   ;end update
   DELETE  FROM track_group tg,
     (dummyt d  WITH seq = loc_cnt)
    SET tg.tracking_group_cd = request->trk_group_code_value
    PLAN (d
     WHERE (request->elist[x].llist[d.seq].action_flag=3))
     JOIN (tg
     WHERE (tg.tracking_group_cd=request->trk_group_code_value)
      AND tg.child_table="TRACK_EVENT"
      AND (tg.child_value=request->elist[x].track_event_id)
      AND (tg.parent_value=request->elist[x].llist[d.seq].code_value))
    WITH nocounter
   ;end delete
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_EVENT_LOC","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
