CREATE PROGRAM dcp_del_query_templates
 SET modify = predeclare
 RECORD request(
   1 qual[*]
     2 template_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD patient_list(
   1 qual[*]
     2 patient_list_id = f8
 )
 DECLARE i = i4 WITH noconstant(0)
 DECLARE pl_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_pl_query_list ql,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (ql
   WHERE (ql.template_id=request->qual[d.seq].template_id)
    AND (request->qual[d.seq].template_id > 0))
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (mod(pl_cnt,10)=1)
    stat = alterlist(patient_list->qual,(pl_cnt+ 9))
   ENDIF
   patient_list->qual[pl_cnt].patient_list_id = ql.patient_list_id,
   CALL echo(patient_list->qual[pl_cnt].patient_list_id)
  FOOT REPORT
   stat = alterlist(patient_list->qual,pl_cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(patient_list->qual,5))
   IF ((patient_list->qual[i].patient_list_id > 0))
    EXECUTE dcp_del_patient_list value(patient_list->qual[i].patient_list_id)
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(request->qual,5))
   DELETE  FROM dcp_pl_query_temp_access ta
    WHERE (ta.template_id=request->qual[i].template_id)
     AND (request->qual[i].template_id > 0)
    WITH nocounter
   ;end delete
   DELETE  FROM dcp_pl_query_value qv
    WHERE (qv.template_id=request->qual[i].template_id)
     AND (request->qual[i].template_id > 0)
    WITH nocounter
   ;end delete
   DELETE  FROM dcp_pl_query_template qt
    WHERE (qt.template_id=request->qual[i].template_id)
     AND (request->qual[i].template_id > 0)
    WITH nocounter
   ;end delete
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 FREE RECORD patient_list
END GO
