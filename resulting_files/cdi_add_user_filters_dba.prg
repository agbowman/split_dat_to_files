CREATE PROGRAM cdi_add_user_filters:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 filters[*]
      2 cdi_user_filter_id = f8
      2 filter_name = vc
      2 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_user_filters"
 SET req_size = value(size(request->filters,5))
 IF (req_size > 0)
  SET stat = alterlist(reply->filters,req_size)
  EXECUTE dm2_dar_get_bulk_seq "reply->filters", req_size, "cdi_user_filter_id",
  1, "CDI_SEQ"
  FOR (i = 1 TO req_size)
   SET reply->filters[i].filter_name = request->filters[i].filter_name
   SET reply->filters[i].person_id = request->filters[i].person_id
  ENDFOR
  INSERT  FROM cdi_user_filter f,
    (dummyt d  WITH seq = req_size)
   SET f.cdi_user_filter_id = reply->filters[d.seq].cdi_user_filter_id, f.filter_name = request->
    filters[d.seq].filter_name, f.begin_dt_tm = cnvtdatetime(request->filters[d.seq].begin_dt_tm),
    f.end_dt_tm = cnvtdatetime(request->filters[d.seq].end_dt_tm), f.document_count = request->
    filters[d.seq].document_count, f.date_range_months = request->filters[d.seq].date_range,
    f.person_id = request->filters[d.seq].person_id, f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    f.updt_task = reqinfo->updt_task, f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (f)
   WITH nocounter
  ;end insert
  SET inserted_rows = curqual
  IF (inserted_rows < req_size)
   SET ecode = 0
   SET emsg = fillstring(132," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_user_filter"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET stat = alterlist(reply->filters,0)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
