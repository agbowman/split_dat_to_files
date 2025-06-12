CREATE PROGRAM bed_ens_rec_notes:dba
 FREE SET reply
 RECORD reply(
   1 notes[*]
     2 rec_mean = vc
     2 note_id = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 note_dt_tm = dq8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_req
 RECORD temp_req(
   1 notes[*]
     2 action_flag = i2
     2 rec_mean = vc
     2 bnv_id = f8
     2 blt_id = f8
     2 text = vc
 )
 DECLARE temp_user_full = vc
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET req_cnt = size(request->notes,5)
 IF (req_cnt > 0)
  SET stat = alterlist(temp_req->notes,req_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   ORDER BY d.seq
   DETAIL
    temp_req->notes[d.seq].action_flag = request->notes[d.seq].action_flag, temp_req->notes[d.seq].
    rec_mean = request->notes[d.seq].rec_mean, temp_req->notes[d.seq].bnv_id = request->notes[d.seq].
    note_id,
    temp_req->notes[d.seq].text = request->notes[d.seq].text
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   j = seq(bedrock_seq,nextval)"##################;rp0"
   FROM dual du,
    (dummyt d  WITH seq = value(req_cnt))
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=1))
    JOIN (du)
   DETAIL
    temp_req->notes[d.seq].bnv_id = cnvtreal(j)
   WITH format, counter
  ;end select
  SELECT INTO "NL:"
   j = seq(bedrock_seq,nextval)"##################;rp0"
   FROM dual du,
    (dummyt d  WITH seq = value(req_cnt))
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=1))
    JOIN (du)
   DETAIL
    temp_req->notes[d.seq].blt_id = cnvtreal(j)
   WITH format, counter
  ;end select
  SET ierrcode = 0
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.br_name_value_id = temp_req->notes[d.seq].bnv_id, b.br_nv_key1 = "DIAGNOSTICNOTES", b
    .br_name = temp_req->notes[d.seq].rec_mean,
    b.br_value = trim(cnvtstring(temp_req->notes[d.seq].blt_id)), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure inserting notes: ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM br_long_text b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.long_text_id = temp_req->notes[d.seq].blt_id, b.long_text = temp_req->notes[d.seq].text, b
    .parent_entity_name = "BR_NAME_VALUE",
    b.parent_entity_id = temp_req->notes[d.seq].bnv_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
    updt_task
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure inserting notes: ",serrmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    br_name_value b
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=3))
    JOIN (b
    WHERE (b.br_name_value_id=temp_req->notes[d.seq].bnv_id))
   ORDER BY d.seq
   DETAIL
    temp_req->notes[d.seq].blt_id = cnvtint(trim(b.br_value))
   WITH nocounter
  ;end select
  SET ierrcode = 0
  DELETE  FROM br_long_text l,
    (dummyt d  WITH seq = value(req_cnt))
   SET l.seq = 1
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=3))
    JOIN (l
    WHERE (l.long_text_id=temp_req->notes[d.seq].blt_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure deleting notes: ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.seq = 1
   PLAN (d
    WHERE (temp_req->notes[d.seq].action_flag=3))
    JOIN (b
    WHERE (b.br_name_value_id=temp_req->notes[d.seq].bnv_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Failure deleting notes: ",serrmsg)
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
  SET stat = alterlist(reply->notes,req_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   ORDER BY d.seq
   DETAIL
    reply->notes[d.seq].note_id = temp_req->notes[d.seq].bnv_id, reply->notes[d.seq].rec_mean =
    temp_req->notes[d.seq].rec_mean, reply->notes[d.seq].person_id = reqinfo->updt_id,
    reply->notes[d.seq].name_full_formatted = temp_user_full, reply->notes[d.seq].note_dt_tm =
    cnvtdatetime(curdate,curtime3)
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
