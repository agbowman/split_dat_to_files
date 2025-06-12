CREATE PROGRAM dcp_get_forms_browselist:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 beg_activity_dt_tm = dq8
     2 last_activity_dt_tm = dq8
     2 form_dt_tm = dq8
     2 form_tz = i4
     2 dcp_forms_ref_id = f8
     2 description = vc
     2 event_cd = f8
     2 task_assay_cd = f8
     2 dcp_forms_activity_id = f8
     2 task_id = f8
     2 form_status_cd = f8
     2 flags = i4
     2 multi_contributor_ind = i2
     2 contributor_prsnl_id = f8
     2 contributor_prsnl_name = vc
     2 updt_cnt = i4
     2 ignore_req_ind = i2
     2 task_type_cd = f8
     2 contributor_prsnl_info[*]
       3 prsnl_id = f8
       3 prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE adhoc_cd = f8 WITH constant(uar_get_code_by("MEANING",6025,"ADHOC"))
 DECLARE inerror_cd = f8 WITH constant(uar_get_code_by(nullterm("MEANING"),8,nullterm("INERROR")))
 SET reply->status_data.status = "S"
 SET cnt = 0
 SET publish = 0
 SET prsnl_cnt = 0
 SELECT
  IF ((request->encntr_id > 0))
   PLAN (fa
    WHERE (fa.encntr_id=request->encntr_id)
     AND ((fa.person_id+ 0)=request->person_id)
     AND fa.form_dt_tm >= cnvtdatetime(request->start_date)
     AND fa.form_dt_tm <= cnvtdatetime(request->end_date)
     AND fa.active_ind=1)
    JOIN (fap
    WHERE (fap.dcp_forms_activity_id= Outerjoin(fa.dcp_forms_activity_id)) )
    JOIN (ref
    WHERE ref.dcp_forms_ref_id=fa.dcp_forms_ref_id
     AND fa.version_dt_tm >= ref.beg_effective_dt_tm
     AND fa.version_dt_tm < ref.end_effective_dt_tm)
    JOIN (ta
    WHERE (ta.task_id= Outerjoin(fa.task_id)) )
    JOIN (ot
    WHERE (ot.reference_task_id= Outerjoin(ta.reference_task_id)) )
  ELSE
   PLAN (fa
    WHERE fa.form_dt_tm >= cnvtdatetime(request->start_date)
     AND fa.form_dt_tm <= cnvtdatetime(request->end_date)
     AND (fa.person_id=request->person_id)
     AND fa.active_ind=1)
    JOIN (fap
    WHERE (fap.dcp_forms_activity_id= Outerjoin(fa.dcp_forms_activity_id)) )
    JOIN (ref
    WHERE ref.dcp_forms_ref_id=fa.dcp_forms_ref_id
     AND fa.version_dt_tm >= ref.beg_effective_dt_tm
     AND fa.version_dt_tm < ref.end_effective_dt_tm)
    JOIN (ta
    WHERE (ta.task_id= Outerjoin(fa.task_id)) )
    JOIN (ot
    WHERE (ot.reference_task_id= Outerjoin(ta.reference_task_id)) )
  ENDIF
  INTO "nl:"
  FROM dcp_forms_activity fa,
   dcp_forms_activity_prsnl fap,
   dcp_forms_ref ref,
   task_activity ta,
   order_task ot
  ORDER BY fa.dcp_forms_activity_id, fap.prsnl_id
  HEAD REPORT
   cnt = 0
  HEAD fa.dcp_forms_activity_id
   publish = band(fa.flags,4)
   IF (publish=0
    AND validate(request->get_inerror_ind,0)=0
    AND fa.form_status_cd=inerror_cd)
    publish = 1
   ENDIF
   IF (publish=0)
    cnt += 1
    IF (cnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(cnt+ 10))
    ENDIF
    reply->qual[cnt].person_id = fa.person_id, reply->qual[cnt].encntr_id = fa.encntr_id, reply->
    qual[cnt].beg_activity_dt_tm = fa.beg_activity_dt_tm,
    reply->qual[cnt].last_activity_dt_tm = fa.last_activity_dt_tm, reply->qual[cnt].form_dt_tm = fa
    .form_dt_tm, reply->qual[cnt].form_tz = validate(fa.form_tz,0),
    reply->qual[cnt].dcp_forms_ref_id = fa.dcp_forms_ref_id, reply->qual[cnt].description = fa
    .description, reply->qual[cnt].event_cd = ref.event_cd,
    reply->qual[cnt].task_assay_cd = ref.task_assay_cd, reply->qual[cnt].dcp_forms_activity_id = fa
    .dcp_forms_activity_id, reply->qual[cnt].task_id = fa.task_id,
    reply->qual[cnt].form_status_cd = fa.form_status_cd, reply->qual[cnt].flags = fa.flags, reply->
    qual[cnt].updt_cnt = ta.updt_cnt,
    reply->qual[cnt].task_type_cd = ta.task_type_cd, reply->qual[cnt].ignore_req_ind = 0, prsnl_cnt
     = 0
   ENDIF
  HEAD fap.prsnl_id
   IF (publish=0)
    prsnl_cnt += 1
    IF (prsnl_cnt > size(reply->qual[cnt].contributor_prsnl_info,5))
     stat = alterlist(reply->qual[cnt].contributor_prsnl_info,(prsnl_cnt+ 10))
    ENDIF
    reply->qual[cnt].contributor_prsnl_info[prsnl_cnt].prsnl_id = fap.prsnl_id, reply->qual[cnt].
    contributor_prsnl_info[prsnl_cnt].prsnl_name = fap.prsnl_ft
    IF (prsnl_cnt > 1)
     reply->qual[cnt].multi_contributor_ind = 1, reply->qual[cnt].contributor_prsnl_id = 0
    ELSE
     reply->qual[cnt].multi_contributor_ind = 0, reply->qual[cnt].contributor_prsnl_id = fap.prsnl_id,
     reply->qual[cnt].contributor_prsnl_name = fap.prsnl_ft
    ENDIF
    stat = alterlist(reply->qual[cnt].contributor_prsnl_info,prsnl_cnt)
   ENDIF
  DETAIL
   IF (ta.task_class_cd=adhoc_cd
    AND publish=0)
    reply->qual[cnt].ignore_req_ind = ot.ignore_req_ind
   ENDIF
  WITH nocounter, orahintcbo("LEADING(fa ta ot fap) USE_NL(fa ta ot fap)",
    "INDEX(REF XIE1DCP_FORMS_REF)")
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 CALL echo(cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,cnt)
 CALL echorecord(reply)
END GO
