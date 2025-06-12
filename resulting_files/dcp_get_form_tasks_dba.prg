CREATE PROGRAM dcp_get_form_tasks:dba
 RECORD reply(
   1 form_cnt = i4
   1 form_qual[*]
     2 dcp_forms_ref_id = f8
     2 form_description = vc
     2 task_cnt = i4
     2 task_qual[*]
       3 reference_task_id = f8
       3 task_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET form_cnt = 0
 SET task_cnt = 0
 SELECT INTO "nl:"
  dfr.description, dfr.dcp_forms_ref_id, ot.dcp_forms_ref_id,
  ot.reference_task_id, ot.task_description
  FROM dcp_forms_ref dfr,
   (dummyt d1  WITH seq = 1),
   order_task ot
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id != 0
    AND dfr.active_ind=1)
   JOIN (d1)
   JOIN (ot
   WHERE ot.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
  ORDER BY dfr.dcp_forms_ref_id
  HEAD REPORT
   form_cnt = 0
  HEAD dfr.dcp_forms_ref_id
   form_cnt = (form_cnt+ 1)
   IF (form_cnt > size(reply->form_qual,5))
    stat = alterlist(reply->form_qual,(form_cnt+ 5))
   ENDIF
   reply->form_qual[form_cnt].dcp_forms_ref_id = dfr.dcp_forms_ref_id, reply->form_qual[form_cnt].
   form_description = dfr.description, task_cnt = 0
  DETAIL
   IF (ot.reference_task_id > 0)
    task_cnt = (task_cnt+ 1)
    IF (task_cnt > size(reply->form_qual[form_cnt].task_qual,5))
     stat = alterlist(reply->form_qual[form_cnt].task_qual,(task_cnt+ 5))
    ENDIF
    reply->form_qual[form_cnt].task_qual[task_cnt].reference_task_id = ot.reference_task_id, reply->
    form_qual[form_cnt].task_qual[task_cnt].task_description = ot.task_description
   ENDIF
  FOOT  dfr.dcp_forms_ref_id
   reply->form_qual[form_cnt].task_cnt = task_cnt, stat = alterlist(reply->form_qual[form_cnt].
    task_qual,task_cnt)
  WITH outerjoin = d1
 ;end select
 SET reply->form_cnt = form_cnt
 SET stat = alterlist(reply->form_qual,form_cnt)
 IF (curqual=0)
  SET reqinfo->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
