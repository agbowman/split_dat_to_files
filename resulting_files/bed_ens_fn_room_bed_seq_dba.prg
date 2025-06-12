CREATE PROGRAM bed_ens_fn_room_bed_seq:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 FOR (x = 1 TO size(request->rlist,5))
   SET ierrcode = 0
   UPDATE  FROM location_group lg
    SET lg.sequence = request->rlist[x].room_sequence, lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (
     lg.updt_cnt+ 1),
     lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_task = reqinfo->updt_task, lg
     .updt_applctx = reqinfo->updt_applctx
    PLAN (lg
     WHERE (lg.child_loc_cd=request->rlist[x].room_code_value)
      AND (lg.root_loc_cd=request->view_code_value)
      AND lg.active_ind=1)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   IF (size(request->rlist[x].blist,5) > 0)
    SET ierrcode = 0
    UPDATE  FROM location_group lg,
      (dummyt d  WITH seq = value(size(request->rlist[x].blist,5)))
     SET lg.seq = 1, lg.sequence = request->rlist[x].blist[d.seq].bed_sequence, lg.updt_id = reqinfo
      ->updt_id,
      lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(curdate,curtime3), lg.updt_task =
      reqinfo->updt_task,
      lg.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (lg
      WHERE (lg.child_loc_cd=request->rlist[x].blist[d.seq].bed_code_value)
       AND (lg.root_loc_cd=request->view_code_value)
       AND lg.active_ind=1)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
