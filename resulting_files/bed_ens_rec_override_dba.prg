CREATE PROGRAM bed_ens_rec_override:dba
 FREE SET reply
 RECORD reply(
   1 recommendations[*]
     2 rec_meaning = vc
     2 person_id = f8
     2 name_full_formatted = vc
     2 override_dt_tm = dq8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE temp_user_full = vc
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET req_cnt = size(request->recommendations,5)
 IF (req_cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM br_rec b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.override_ind = 1, b.override_dt_tm = cnvtdatetime(curdate,curtime3), b.override_prsnl_id =
    reqinfo->updt_id,
    b.override_mean = request->recommendations[d.seq].reason_mean, b.curr_override_note = request->
    recommendations[d.seq].note_id, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
    reqinfo->updt_applctx,
    b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (request->recommendations[d.seq].action_flag=1))
    JOIN (b
    WHERE (b.rec_mean=request->recommendations[d.seq].rec_meaning))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure updating recommendations: ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM br_rec b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.override_ind = 0, b.override_mean = " ", b.curr_override_note = 0.0,
    b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo
    ->updt_id,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (request->recommendations[d.seq].action_flag=3))
    JOIN (b
    WHERE (b.rec_mean=request->recommendations[d.seq].rec_meaning))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure updating recommendations: ",serrmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   DETAIL
    temp_user_full = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d
    WHERE (request->recommendations[d.seq].action_flag=1))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->recommendations,req_cnt)
   DETAIL
    cnt = (cnt+ 1), reply->recommendations[cnt].rec_meaning = request->recommendations[d.seq].
    rec_meaning, reply->recommendations[cnt].person_id = reqinfo->updt_id,
    reply->recommendations[cnt].name_full_formatted = temp_user_full, reply->recommendations[cnt].
    override_dt_tm = cnvtdatetime(curdate,curtime3)
   FOOT REPORT
    stat = alterlist(reply->recommendations,cnt)
   WITH nocounter
  ;end select
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
