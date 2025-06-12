CREATE PROGRAM cdi_copy_dt_config:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE batchclass_rows = i4 WITH noconstant(value(size(request->batchclass_list,5))), protect
 DECLARE doctype_rows = i4 WITH noconstant(value(size(request->document_type_list,5))), protect
 DECLARE err_msg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE n = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 IF (batchclass_rows > 0
  AND doctype_rows > 0)
  DELETE  FROM cdi_document_type cdt
   WHERE cdt.cdi_ac_batchclass_id > 0
    AND expand(n,1,batchclass_rows,cdt.cdi_ac_batchclass_id,request->batchclass_list[n].
    cdi_ac_batchclass_id)
    AND expand(n,1,doctype_rows,cdt.event_cd,request->document_type_list[n].event_cd)
  ;end delete
  INSERT  FROM cdi_document_type cdt,
    (dummyt dd  WITH seq = doctype_rows),
    (dummyt db  WITH seq = batchclass_rows)
   SET cdt.cdi_ac_batchclass_id = request->batchclass_list[db.seq].cdi_ac_batchclass_id, cdt
    .cdi_document_type_id = seq(cdi_seq,nextval), cdt.event_cd = request->document_type_list[dd.seq].
    event_cd,
    cdt.combine_ind = request->document_type_list[dd.seq].combine_ind, cdt.combine_all_ind = request
    ->document_type_list[dd.seq].combine_all_ind, cdt.max_page_cnt = request->document_type_list[dd
    .seq].max_page_cnt,
    cdt.delete_first_ind = request->document_type_list[dd.seq].delete_first_ind, cdt.updt_cnt = 0,
    cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cdt.updt_task = reqinfo->updt_task, cdt.updt_id = reqinfo->updt_id, cdt.updt_applctx = reqinfo->
    updt_applctx
   PLAN (db)
    JOIN (dd)
    JOIN (cdt
    WHERE cdt.cdi_document_type_id > 0)
   WITH nocounter
  ;end insert
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
