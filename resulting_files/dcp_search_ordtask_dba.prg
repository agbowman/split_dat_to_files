CREATE PROGRAM dcp_search_ordtask:dba
 RECORD reply(
   1 ordertask[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET comparetext = concat(trim(cnvtupper(request->searchtext)),"*")
 SELECT INTO "nl:"
  FROM order_task ot
  WHERE cnvtupper(ot.task_description_key)=patstring(comparetext)
  ORDER BY ot.task_description
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->ordertask,5))
    stat = alterlist(reply->ordertask,(ncnt+ 10))
   ENDIF
   reply->ordertask[ncnt].reference_task_id = ot.reference_task_id, reply->ordertask[ncnt].
   task_description = ot.task_description, reply->ordertask[ncnt].dcp_forms_ref_id = ot
   .dcp_forms_ref_id
  FOOT REPORT
   stat = alterlist(reply->ordertask,ncnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.operationname = "SELECT"
 SET reply->status_data.operationstatus = "T"
 SET reply->status_data.status = "S"
END GO
