CREATE PROGRAM dcp_get_prsnl_notify:dba
 RECORD reply(
   1 person_id = f8
   1 qual[*]
     2 task_activity_cd = f8
     2 prsnl_notify_id = f8
     2 notify_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,10)
 SET knt = 0
 IF ((request->task_activity_cd != 0))
  SET knt = (knt+ 1)
  SELECT INTO "nl:"
   pn.person_id
   FROM prsnl_notify pn
   PLAN (pn
    WHERE (pn.person_id=request->person_id)
     AND (pn.task_activity_cd=request->task_activity_cd))
   DETAIL
    reply->person_id = request->person_id, reply->qual[knt].task_activity_cd = request->
    task_activity_cd, reply->qual[knt].prsnl_notify_id = pn.prsnl_notify_id,
    reply->qual[knt].notify_flag = pn.notify_flag, reply->qual[knt].active_ind = pn.active_ind, reply
    ->qual[knt].active_status_cd = pn.active_status_cd,
    reply->qual[knt].active_status_dt_tm = pn.active_status_dt_tm, reply->qual[knt].
    active_status_prsnl_id = pn.active_status_prsnl_id, reply->qual[knt].beg_effective_dt_tm = pn
    .beg_effective_dt_tm,
    reply->qual[knt].end_effective_dt_tm = pn.end_effective_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,knt)
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_notify table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "query"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "not in table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   pn.person_id
   FROM prsnl_notify pn
   PLAN (pn
    WHERE (pn.person_id=request->person_id))
   HEAD REPORT
    knt = 0
   HEAD pn.person_id
    reply->person_id = pn.person_id
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].task_activity_cd = pn.task_activity_cd, reply->qual[knt].prsnl_notify_id = pn
    .prsnl_notify_id, reply->qual[knt].notify_flag = pn.notify_flag,
    reply->qual[knt].active_ind = pn.active_ind, reply->qual[knt].active_status_cd = pn
    .active_status_cd, reply->qual[knt].active_status_dt_tm = pn.active_status_dt_tm,
    reply->qual[knt].active_status_prsnl_id = pn.active_status_prsnl_id, reply->qual[knt].
    beg_effective_dt_tm = pn.beg_effective_dt_tm, reply->qual[knt].end_effective_dt_tm = pn
    .end_effective_dt_tm
   FOOT REPORT
    stat = alterlist(reply->qual,knt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_notify table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "query"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "not in table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
