CREATE PROGRAM add_messaging_notify:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE messaging_notify_id = f8 WITH protect, noconstant(0.0)
 DECLARE failed = vc WITH protect, noconstant("F")
 SET reply->status_data.status = failed
 SET reqinfo->commit_ind = 0
 IF ((request->task_id < 0))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   messaging_notify_id = cnvtreal(nextseqnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM messaging_notify msgn
  SET msgn.messaging_notify_id = messaging_notify_id, msgn.task_id = request->task_id, msgn
   .notify_prsnl_id = request->notify_prsnl_id,
   msgn.notify_prsnl_group_id = request->notify_prsnl_group_id, msgn.notify_type_cd = request->
   notify_type_cd, msgn.notify_priority_cd = request->notify_priority_cd,
   msgn.assign_prsnl_id = request->assign_prsnl_id, msgn.assign_prsnl_group_id = request->
   assign_prsnl_group_id, msgn.assign_person_id = request->assign_person_id,
   msgn.active_ind = 1, msgn.updt_dt_tm = cnvtdatetime(curdate,curtime3), msgn.updt_cnt = 0,
   msgn.updt_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
