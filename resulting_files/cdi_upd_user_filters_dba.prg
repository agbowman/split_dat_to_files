CREATE PROGRAM cdi_upd_user_filters:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE updated_rows = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_user_filters"
 SET req_size = value(size(request->filters,5))
 IF (req_size > 0)
  SELECT INTO "NL:"
   f.cdi_user_filter_id
   FROM cdi_user_filter f
   WHERE expand(num,1,req_size,f.cdi_user_filter_id,request->filters[num].cdi_user_filter_id)
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1)
   WITH nocounter, forupdatewait(f)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_user_filter f,
     (dummyt d  WITH seq = req_size)
    SET f.filter_name = request->filters[d.seq].filter_name, f.begin_dt_tm = cnvtdatetime(request->
      filters[d.seq].begin_dt_tm), f.end_dt_tm = cnvtdatetime(request->filters[d.seq].end_dt_tm),
     f.document_count = request->filters[d.seq].document_count, f.date_range_months = request->
     filters[d.seq].date_range, f.person_id = request->filters[d.seq].person_id,
     f.updt_cnt = (f.updt_cnt+ 1), f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_task =
     reqinfo->updt_task,
     f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (f
     WHERE (f.cdi_user_filter_id=request->filters[d.seq].cdi_user_filter_id))
    WITH nocounter
   ;end update
   SET updated_rows = curqual
   IF (updated_rows < rows_to_update_count)
    SET ecode = 0
    SET emsg = fillstring(132," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_USER_FILTER"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
