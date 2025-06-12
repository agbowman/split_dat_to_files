CREATE PROGRAM dcp_add_prsnl_notify:dba
 RECORD reply(
   1 prsnl_notify_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET prsnl_notify_id = 0.0
 SELECT INTO "nl:"
  y = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   prsnl_notify_id = y
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "get sequence number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "reference_seq"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to select next value"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM prsnl_notify pn
  SET pn.prsnl_notify_id = prsnl_notify_id, pn.person_id = request->person_id, pn.task_activity_cd =
   request->task_activity_cd,
   pn.notify_flag = request->notify_flag, pn.active_ind = request->active_ind, pn.beg_effective_dt_tm
    = cnvtdatetime(curdate,curtime),
   pn.end_effective_dt_tm = cnvtdatetime("1-jan-2100 00:00:01"), pn.updt_dt_tm = cnvtdatetime(curdate,
    curtime), pn.updt_id = reqinfo->updt_id,
   pn.updt_task = reqinfo->updt_task, pn.updt_applctx = reqinfo->updt_applctx, pn.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_notify table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->prsnl_notify_id = prsnl_notify_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
