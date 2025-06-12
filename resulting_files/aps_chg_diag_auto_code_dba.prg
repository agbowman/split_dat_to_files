CREATE PROGRAM aps_chg_diag_auto_code:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET number_to_del = size(request->del_auto_code_qual,5)
 SET number_to_add = size(request->add_auto_code_qual,5)
 SET reqinfo->commit_ind = 0
 IF (number_to_del > 0)
  DELETE  FROM ap_diag_auto_code adac,
    (dummyt d  WITH seq = value(number_to_del))
   SET adac.seq = 1
   PLAN (d)
    JOIN (adac
    WHERE (adac.task_assay_cd=request->del_auto_code_qual[d.seq].task_assay_cd)
     AND (adac.catalog_cd=request->del_auto_code_qual[d.seq].catalog_cd))
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_DIAG_AUTO_CODE"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (number_to_add > 0)
  INSERT  FROM ap_diag_auto_code adac,
    (dummyt d  WITH seq = value(number_to_add))
   SET adac.catalog_cd = request->add_auto_code_qual[d.seq].catalog_cd, adac.task_assay_cd = request
    ->add_auto_code_qual[d.seq].task_assay_cd, adac.updt_cnt = 0,
    adac.updt_dt_tm = cnvtdatetime(curdate,curtime3), adac.updt_id = reqinfo->updt_id, adac.updt_task
     = reqinfo->updt_task,
    adac.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (adac)
   WITH nocounter
  ;end insert
  IF (curqual != number_to_add)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_DIAG_AUTO_CODE"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
