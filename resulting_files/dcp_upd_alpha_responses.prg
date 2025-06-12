CREATE PROGRAM dcp_upd_alpha_responses
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD version_request(
   1 task_assay_cd = f8
 )
 RECORD version_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal_task_assay_cds(
   1 qual[*]
     2 task_assay_cd = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  r.task_assay_cd
  FROM reference_range_factor r,
   (dummyt d  WITH seq = value(request->qual_cnt))
  PLAN (d)
   JOIN (r
   WHERE (r.reference_range_factor_id=request->qual[d.seq].reference_range_factor_id))
  ORDER BY r.task_assay_cd
  HEAD r.task_assay_cd
   count1 = (count1+ 1), stat = alterlist(internal_task_assay_cds->qual,count1),
   internal_task_assay_cds->qual[count1].task_assay_cd = r.task_assay_cd
  WITH nocounter
 ;end select
 IF (checkprg("DCP_ADD_DTA_VERSION"))
  FOR (x = 1 TO count1)
    SET version_request->task_assay_cd = internal_task_assay_cds->qual[x].task_assay_cd
    EXECUTE dcp_add_dta_version  WITH replace(request,version_request), replace(reply,version_reply)
    IF ((version_reply->status_data.status="F"))
     GO TO versioning_failed
    ENDIF
  ENDFOR
 ENDIF
 FOR (i = 1 TO request->qual_cnt)
   UPDATE  FROM alpha_responses ar
    SET ar.result_value = request->qual[i].result_value, ar.updt_task = reqinfo->updt_task, ar
     .updt_id = reqinfo->updt_id,
     ar.updt_cnt = (ar.updt_cnt+ 1), ar.updt_applctx = reqinfo->updt_applctx
    WHERE (ar.reference_range_factor_id=request->qual[i].reference_range_factor_id)
     AND (ar.nomenclature_id=request->qual[i].nomenclature_id)
    WITH nocounter
   ;end update
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 GO TO exit_script
#versioning_failed
 SET reply->status_data.subeventstatus[1].operationname = "upd"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_add_dta_version"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
  "Update aborted.  DTA Versioning failed:",version_reply->status_data.targetobjectvalue)
 SET reply->status_data.status = "F"
 GO TO exit_script
#exit_script
 FREE RECORD internal_task_assay_cds
 FREE RECORD version_request
 FREE RECORD version_reply
END GO
