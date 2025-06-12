CREATE PROGRAM bed_ens_dgb_prefs:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET treq
 RECORD treq(
   1 req[*]
     2 action_flag = i2
     2 application_number = i4
     2 position_code_value = f8
     2 app_id = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 pref_id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->level,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET tcnt = 0
 SET stat = alterlist(treq->req,100)
 FOR (x = 1 TO req_cnt)
   SET ycnt = size(request->level[x].prefs,5)
   SET temp_app_id = 0.0
   SELECT INTO "nl:"
    FROM app_prefs a
    PLAN (a
     WHERE (a.application_number=request->level[x].application_number)
      AND (a.position_cd=request->level[x].position_code_value)
      AND a.prsnl_id=0
      AND a.active_ind=1)
    ORDER BY a.prsnl_id DESC, a.position_cd DESC
    DETAIL
     temp_app_id = a.app_prefs_id
    WITH nocounter
   ;end select
   IF (temp_app_id=0)
    SELECT INTO "NL:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      temp_app_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET ierrcode = 0
    INSERT  FROM app_prefs a
     SET a.app_prefs_id = temp_app_id, a.active_ind = 1, a.application_number = request->level[x].
      application_number,
      a.position_cd = request->level[x].position_code_value, a.prsnl_id = 0, a.updt_applctx = reqinfo
      ->updt_applctx,
      a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on app_prefs insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (y = 1 TO ycnt)
     SET cnt = (cnt+ 1)
     SET tcnt = (tcnt+ 1)
     IF (cnt > 100)
      SET stat = alterlist(treq->req,(tcnt+ 100))
      SET cnt = 1
     ENDIF
     SET treq->req[tcnt].app_id = temp_app_id
     SET treq->req[tcnt].application_number = request->level[x].application_number
     SET treq->req[tcnt].position_code_value = request->level[x].position_code_value
     SET treq->req[tcnt].action_flag = request->level[x].prefs[y].action_flag
     SET treq->req[tcnt].pvc_name = request->level[x].prefs[y].pvc_name
     SET treq->req[tcnt].pvc_value = request->level[x].prefs[y].pvc_value
     SET treq->req[tcnt].pref_id = request->level[x].prefs[y].pref_id
   ENDFOR
 ENDFOR
 SET stat = alterlist(treq->req,tcnt)
 SET ierrcode = 0
 INSERT  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(tcnt))
  SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.active_ind = 1, n.merge_id = 0,
   n.merge_name = "", n.parent_entity_id = treq->req[d.seq].app_id, n.parent_entity_name =
   "APP_PREFS",
   n.pvc_name = treq->req[d.seq].pvc_name, n.pvc_value = treq->req[d.seq].pvc_value, n.sequence = 0,
   n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (treq->req[d.seq].action_flag=1)
    AND (treq->req[d.seq].app_id > 0))
   JOIN (n)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(tcnt))
  SET n.pvc_value = treq->req[d.seq].pvc_value, n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt =
   (n.updt_cnt+ 1),
   n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo
   ->updt_task
  PLAN (d
   WHERE (treq->req[d.seq].action_flag=2))
   JOIN (n
   WHERE (n.name_value_prefs_id=treq->req[d.seq].pref_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs update")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(tcnt))
  SET n.seq = 1
  PLAN (d
   WHERE (treq->req[d.seq].action_flag=3))
   JOIN (n
   WHERE (n.name_value_prefs_id=treq->req[d.seq].pref_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs delete")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
