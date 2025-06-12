CREATE PROGRAM dcp_get_primary_task:dba
 RECORD reply(
   1 task_id = f8
   1 primary_task
     2 task_id = f8
     2 task_desc = vc
     2 task_type_cd = f8
     2 task_type_disp = c40
     2 task_type_desc = c60
     2 task_type_mean = c12
     2 task_dt_tm = dq8
     2 event_id = f8
     2 task_status_cd = f8
     2 task_status_disp = c40
     2 task_status_desc = c60
     2 task_status_mean = c12
     2 med_order_type_cd = f8
     2 med_order_type_disp = c40
     2 med_order_type_desc = c60
     2 med_order_type_mean = c12
     2 task_updt_id = f8
     2 updt_full_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"PERFORM"))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM task_reltn tr,
   task_activity ta,
   order_task ot,
   prsnl p,
   ce_event_prsnl cep
  PLAN (tr
   WHERE (tr.task_id=request->task_id))
   JOIN (ta
   WHERE ta.task_id=tr.prereq_task_id)
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   JOIN (cep
   WHERE ta.event_id=cep.event_id
    AND ((cep.action_type_cd+ 0)=perform_cd)
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00"))
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id)
  DETAIL
   reply->task_id = tr.task_id, reply->primary_task.task_id = tr.prereq_task_id, reply->primary_task.
   event_id = ta.event_id,
   reply->primary_task.task_desc = ot.task_description, reply->primary_task.task_type_cd = ot
   .task_type_cd, reply->primary_task.med_order_type_cd = ta.med_order_type_cd,
   reply->primary_task.task_dt_tm = ta.task_dt_tm, reply->primary_task.task_status_cd = ta
   .task_status_cd, reply->primary_task.task_updt_id = ta.updt_id,
   reply->primary_task.updt_full_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
