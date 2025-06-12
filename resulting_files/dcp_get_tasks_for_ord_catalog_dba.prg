CREATE PROGRAM dcp_get_tasks_for_ord_catalog:dba
 RECORD reply(
   1 task_cnt = i4
   1 task_qual[*]
     2 task_id = f8
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
     2 order_id = f8
     2 event_cd = f8
     2 catalog_cd = f8
     2 event_id = f8
     2 task_dt_tm = dq8
     2 task_status_cd = f8
     2 task_status_disp = c40
     2 task_status_mean = c12
     2 allpositionchart_ind = i2
     2 ability_ind = i2
     2 task_activity_cd = f8
     2 task_activity_disp = c40
     2 task_activity_mean = c12
     2 updt_cnt = i4
     2 med_order_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET task_cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pending_cd = 0.0
 SET overdue_cd = 0.0
 SET inprocess_cd = 0.0
 SET code_set = 79
 SET cdf_meaning = "PENDING"
 EXECUTE cpm_get_cd_for_cdf
 SET pending_cd = code_value
 SET code_set = 79
 SET cdf_meaning = "OVERDUE"
 EXECUTE cpm_get_cd_for_cdf
 SET overdue_cd = code_value
 SET code_set = 79
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SELECT INTO "nl:"
  ta.person_id, ta.encntr_id, ta.catalog_cd,
  ta.task_dt_tm, ta.task_status_cd, ta.reference_task_id,
  ot.reference_task_id
  FROM task_activity ta,
   order_task ot
  PLAN (ta
   WHERE (ta.person_id=request->person_id)
    AND (ta.encntr_id=request->encntr_id)
    AND (ta.catalog_cd=request->catalog_cd)
    AND ta.task_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ta.active_ind=1
    AND ((ta.task_status_cd=pending_cd) OR (((ta.task_status_cd=overdue_cd) OR (ta.task_status_cd=
   inprocess_cd)) )) )
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
  ORDER BY ta.task_dt_tm
  DETAIL
   task_cnt = (task_cnt+ 1)
   IF (task_cnt > size(reply->task_qual,5))
    stat = alterlist(reply->task_qual,(task_cnt+ 5))
   ENDIF
   reply->task_qual[task_cnt].task_id = ta.task_id, reply->task_qual[task_cnt].reference_task_id = ta
   .reference_task_id, reply->task_qual[task_cnt].task_description = ot.task_description,
   reply->task_qual[task_cnt].dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->task_qual[task_cnt].
   order_id = ta.order_id, reply->task_qual[task_cnt].event_cd = ot.event_cd,
   reply->task_qual[task_cnt].catalog_cd = ta.catalog_cd, reply->task_qual[task_cnt].event_id = ta
   .event_id, reply->task_qual[task_cnt].task_dt_tm = cnvtdatetime(ta.task_dt_tm),
   reply->task_qual[task_cnt].task_status_cd = ta.task_status_cd, reply->task_qual[task_cnt].
   allpositionchart_ind = ot.allpositionchart_ind, reply->task_qual[task_cnt].task_activity_cd = ot
   .task_activity_cd,
   reply->task_qual[task_cnt].updt_cnt = ta.updt_cnt, reply->task_qual[task_cnt].med_order_type_cd =
   ta.med_order_type_cd
   IF (ot.allpositionchart_ind=1)
    reply->task_qual[task_cnt].ability_ind = 1
   ELSE
    reply->task_qual[task_cnt].ability_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET reply->task_cnt = task_cnt
 SET stat = alterlist(reply->task_qual,task_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET nbr_to_check = size(reply->task_qual,5)
 SELECT INTO "nl:"
  otpx.reference_task_id, otpx.position_cd
  FROM (dummyt d1  WITH seq = value(nbr_to_check)),
   order_task_position_xref otpx
  PLAN (d1)
   JOIN (otpx
   WHERE (otpx.reference_task_id=reply->task_qual[d1.seq].reference_task_id)
    AND (otpx.position_cd=request->position_cd))
  DETAIL
   reply->task_qual[d1.seq].ability_ind = 1
  WITH nocounter
 ;end select
END GO
