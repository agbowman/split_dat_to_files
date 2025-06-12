CREATE PROGRAM dcp_get_ref_task_def:dba
 RECORD reply(
   1 reference_task_id = f8
   1 description = c100
   1 event_cd = f8
   1 dcp_forms_ref_id = f8
   1 task_type_cd = f8
   1 task_type_meaning = vc
   1 capture_bill_info_ind = i2
   1 ignore_req_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  ot.reference_task_id, c.cdf_meaning
  FROM order_task ot,
   code_value c
  WHERE (ot.reference_task_id=request->reference_task_id)
   AND c.code_set=6026
   AND c.code_value=ot.task_type_cd
  DETAIL
   reply->description = ot.task_description, reply->reference_task_id = ot.reference_task_id, reply->
   event_cd = ot.event_cd,
   reply->dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->task_type_cd = ot.task_type_cd, reply->
   task_type_meaning = c.cdf_meaning,
   reply->capture_bill_info_ind = ot.capture_bill_info_ind, reply->ignore_req_ind = ot.ignore_req_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_TASK"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
