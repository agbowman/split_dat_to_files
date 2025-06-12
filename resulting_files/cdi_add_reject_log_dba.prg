CREATE PROGRAM cdi_add_reject_log:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE new_rows = i4 WITH noconstant(value(size(request->document_list,5))), protect
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (new_rows > 0)
  INSERT  FROM (dummyt d  WITH seq = new_rows),
    cdi_reject_log rl
   SET rl.cdi_reject_log_id = seq(cdi_seq,nextval), rl.contributor_system_cd = request->
    document_list[d.seq].contributor_system_cd, rl.match_event_id = request->document_list[d.seq].
    match_event_id,
    rl.match_status_cd = request->document_list[d.seq].match_status_cd, rl.match_updt_dt_tm =
    cnvtdatetime(request->document_list[d.seq].match_updt_dt_tm), rl.reference_nbr = request->
    document_list[d.seq].reference_nbr,
    rl.reject_birth_dt_tm = cnvtdatetime(request->document_list[d.seq].reject_birth_dt_tm), rl
    .reject_doc_type = request->document_list[d.seq].reject_doc_type, rl.reject_dt_tm = cnvtdatetime(
     request->document_list[d.seq].reject_dt_tm),
    rl.reject_fin = request->document_list[d.seq].reject_fin, rl.reject_mrn = request->document_list[
    d.seq].reject_mrn, rl.reject_patient_name = request->document_list[d.seq].reject_patient_name,
    rl.reject_provider = request->document_list[d.seq].reject_provider, rl.reject_service_dt_tm =
    cnvtdatetime(request->document_list[d.seq].reject_service_dt_tm), rl.reject_status = request->
    document_list[d.seq].reject_status,
    rl.reject_subject = request->document_list[d.seq].reject_subject, rl.reject_updt_dt_tm =
    cnvtdatetime(request->document_list[d.seq].reject_updt_dt_tm), rl.reject_user_id = request->
    document_list[d.seq].reject_user_id,
    rl.updt_applctx = reqinfo->updt_applctx, rl.updt_cnt = 0, rl.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    rl.updt_id = reqinfo->updt_id, rl.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (rl)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=new_rows)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
