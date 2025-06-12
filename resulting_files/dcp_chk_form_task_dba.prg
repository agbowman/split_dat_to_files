CREATE PROGRAM dcp_chk_form_task:dba
 RECORD reply(
   1 task_cnt = i4
   1 order_cnt = i4
   1 tasks[*]
     2 reference_task_id = f8
     2 description = vc
   1 orders[*]
     2 catalog_cd = f8
     2 description = vc
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET task_cnt = 0
 SET order_cnt = 0
 SET stat = 0
 SELECT INTO "nl:"
  FROM order_task ot
  WHERE (ot.dcp_forms_ref_id=request->dcp_forms_ref_id)
  DETAIL
   task_cnt = (task_cnt+ 1), stat = alterlist(reply->tasks,task_cnt), reply->tasks[task_cnt].
   reference_task_id = ot.reference_task_id,
   reply->tasks[task_cnt].description = ot.task_description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog o
  WHERE (o.form_id=request->dcp_forms_ref_id)
  DETAIL
   order_cnt = (order_cnt+ 1), stat = alterlist(reply->orders,order_cnt), reply->orders[order_cnt].
   catalog_cd = o.catalog_cd,
   reply->orders[order_cnt].description = o.description
  WITH nocounter
 ;end select
 SET reply->order_cnt = order_cnt
 SET reply->task_cnt = task_cnt
 SET reply->status_data.status = "S"
 CALL echo(build("Tasks:",reply->task_cnt))
 CALL echo(build("Orders:",reply->order_cnt))
END GO
