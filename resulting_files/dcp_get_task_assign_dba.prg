CREATE PROGRAM dcp_get_task_assign:dba
 RECORD reply(
   1 qual_assign[*]
     2 assign_prsnl_id = f8
     2 assign_prsnl_disp = vc
     2 updt_id = f8
     2 updt_prsnl_disp = vc
     2 assign_dt_tm = dq8
     2 assign_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt1 = 0
 SELECT INTO "nl:"
  FROM task_activity_assignment ta,
   long_text lt,
   prsnl p,
   prsnl p2
  PLAN (ta
   WHERE (ta.task_id=request->task_id)
    AND ta.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=ta.msg_text_id)
   JOIN (p
   WHERE p.person_id=ta.assign_prsnl_id)
   JOIN (p2
   WHERE p2.person_id=ta.updt_id)
  DETAIL
   cnt1 = (cnt1+ 1)
   IF (cnt1 > size(reply->qual_assign,5))
    stat = alterlist(reply->qual_assign,(cnt1+ 10))
   ENDIF
   reply->qual_assign[cnt1].assign_prsnl_id = ta.assign_prsnl_id, reply->qual_assign[cnt1].updt_id =
   ta.updt_id, reply->qual_assign[cnt1].assign_dt_tm = ta.updt_dt_tm,
   reply->qual_assign[cnt1].assign_msg = lt.long_text, reply->qual_assign[cnt1].assign_prsnl_disp = p
   .name_full_formatted, reply->qual_assign[cnt1].updt_prsnl_disp = p2.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_assign,cnt1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
