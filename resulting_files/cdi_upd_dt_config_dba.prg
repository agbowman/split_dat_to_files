CREATE PROGRAM cdi_upd_dt_config:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE doctype_rows = i4 WITH noconstant(value(size(request->document_type_list,5))), protect
 DECLARE err_msg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (doctype_rows > 0)
  SELECT INTO "NL:"
   cdt.updt_cnt
   FROM cdi_document_type cdt,
    (dummyt d  WITH seq = doctype_rows)
   PLAN (d)
    JOIN (cdt
    WHERE (cdt.cdi_document_type_id=request->document_type_list[d.seq].cdi_document_type_id)
     AND (request->document_type_list[d.seq].cdi_document_type_id > 0)
     AND (cdt.updt_cnt=request->document_type_list[d.seq].updt_cnt))
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1)
   WITH nocounter, forupdate(cdt)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_document_type cdt,
     (dummyt d  WITH seq = doctype_rows)
    SET cdt.event_cd = request->document_type_list[d.seq].event_cd, cdt.cdi_ac_batchclass_id =
     request->document_type_list[d.seq].cdi_ac_batchclass_id, cdt.combine_ind = request->
     document_type_list[d.seq].combine_ind,
     cdt.combine_all_ind = request->document_type_list[d.seq].combine_all_ind, cdt.max_page_cnt =
     request->document_type_list[d.seq].max_page_cnt, cdt.delete_first_ind = request->
     document_type_list[d.seq].delete_first_ind,
     cdt.updt_cnt = (cdt.updt_cnt+ 1), cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdt.updt_task
      = reqinfo->updt_task,
     cdt.updt_id = reqinfo->updt_id, cdt.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cdt
     WHERE (cdt.cdi_document_type_id=request->document_type_list[d.seq].cdi_document_type_id)
      AND (request->document_type_list[d.seq].cdi_document_type_id > 0)
      AND (cdt.updt_cnt=request->document_type_list[d.seq].updt_cnt))
    WITH nocounter
   ;end update
   IF (curqual != rows_to_update_count)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rows_to_update_count < doctype_rows)
   INSERT  FROM cdi_document_type cdt,
     (dummyt d  WITH seq = doctype_rows)
    SET cdt.cdi_document_type_id = seq(cdi_seq,nextval), cdt.event_cd = request->document_type_list[d
     .seq].event_cd, cdt.cdi_ac_batchclass_id = request->document_type_list[d.seq].
     cdi_ac_batchclass_id,
     cdt.combine_ind = request->document_type_list[d.seq].combine_ind, cdt.combine_all_ind = request
     ->document_type_list[d.seq].combine_all_ind, cdt.max_page_cnt = request->document_type_list[d
     .seq].max_page_cnt,
     cdt.delete_first_ind = request->document_type_list[d.seq].delete_first_ind, cdt.updt_cnt = 0,
     cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cdt.updt_task = reqinfo->updt_task, cdt.updt_id = reqinfo->updt_id, cdt.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (cdt
     WHERE (request->document_type_list[d.seq].cdi_document_type_id=0.0))
    WITH nocounter
   ;end insert
   IF ((curqual != (doctype_rows - rows_to_update_count)))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
