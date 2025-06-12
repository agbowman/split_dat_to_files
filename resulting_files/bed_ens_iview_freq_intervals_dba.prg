CREATE PROGRAM bed_ens_iview_freq_intervals:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
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
 SET error_flag = "N"
 SET pcnt = size(request->positions,5)
 IF (pcnt > 0)
  FOR (p = 1 TO pcnt)
   SET fcnt = size(request->positions[p].frequency_intervals,5)
   IF (fcnt > 0)
    INSERT  FROM working_view_freq_interval w,
      (dummyt d  WITH seq = value(fcnt))
     SET w.working_view_freq_interval_id = seq(carenet_seq,nextval), w.working_view_interval_cd =
      request->positions[p].frequency_intervals[d.seq].code_value, w.position_cd = request->
      positions[p].code_value,
      w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
      reqinfo->updt_task,
      w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0
     PLAN (d
      WHERE (request->positions[p].frequency_intervals[d.seq].action_flag=1))
      JOIN (w)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into working_view_freq_interval table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    DELETE  FROM working_view_freq_interval w,
      (dummyt d  WITH seq = value(fcnt))
     SET w.seq = 1
     PLAN (d
      WHERE (request->positions[p].frequency_intervals[d.seq].action_flag=3))
      JOIN (w
      WHERE (w.position_cd=request->positions[p].code_value)
       AND (w.working_view_interval_cd=request->positions[p].frequency_intervals[d.seq].code_value))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error deleting from working_view_freq_interval table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
