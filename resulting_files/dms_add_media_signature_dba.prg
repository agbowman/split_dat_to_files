CREATE PROGRAM dms_add_media_signature:dba
 CALL echo("<==================== Entering DMS_ADD_MEDIA_SIGNATURE Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  dmi.dms_media_instance_id
  FROM dms_media_instance dmi
  WHERE (dmi.dms_media_instance_id=request->dms_media_instance_id)
   AND dmi.dms_media_instance_id > 0
  WITH nocounter, forupdate(dmi)
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_INSTANCE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Media instance not found"
  GO TO end_script
 ENDIF
 DECLARE signaturecount = i4 WITH constant(size(request->signatures,5))
 SELECT INTO "nl:"
  dms.dms_media_signature_id
  FROM dms_media_signature dms,
   (dummyt d  WITH seq = value(signaturecount))
  PLAN (d)
   JOIN (dms
   WHERE (dms.dms_media_instance_id=request->dms_media_instance_id)
    AND (dms.signer=request->signatures[d.seq].signer))
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_SIGNATURE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Redundant signature found."
  GO TO end_script
 ENDIF
 FREE RECORD signature_ids
 RECORD signature_ids(
   1 ids[signaturecount]
     2 blob_id = f8
     2 sig_id = f8
 )
 FOR (index = 1 TO signaturecount)
  SELECT
   blob_id = seq(long_data_seq,nextval), sig_id = seq(dms_seq,nextval)
   FROM dual
   DETAIL
    signature_ids->ids[index].blob_id = cnvtreal(blob_id), signature_ids->ids[index].sig_id =
    cnvtreal(sig_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get sequence ids"
   GO TO end_script
  ENDIF
 ENDFOR
 CALL echorecord(signature_ids)
 DECLARE active_status_cd = f8 WITH constant(uar_get_code_by("MEANING",48,nullterm("ACTIVE")))
 INSERT  FROM long_blob lb,
   (dummyt d  WITH seq = value(signaturecount))
  SET lb.active_ind = 1, lb.active_status_cd = active_status_cd, lb.active_status_dt_tm =
   cnvtdatetime(curdate,curtime),
   lb.active_status_prsnl_id = reqinfo->updt_id, lb.long_blob = request->signatures[d.seq].signature,
   lb.long_blob_id = signature_ids->ids[d.seq].blob_id,
   lb.parent_entity_id = signature_ids->ids[d.seq].sig_id, lb.parent_entity_name =
   "DMS_MEDIA_SIGNATURE", lb.updt_id = reqinfo->updt_id,
   lb.updt_dt_tm = cnvtdatetime(curdate,curtime), lb.updt_task = reqinfo->updt_task, lb.updt_applctx
    = reqinfo->updt_applctx,
   lb.updt_cnt = 0
  PLAN (d)
   JOIN (lb)
  WITH nocounter
 ;end insert
 IF (curqual != signaturecount)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert the signature data"
  GO TO end_script
 ENDIF
 INSERT  FROM dms_media_signature dms,
   (dummyt d  WITH seq = value(signaturecount))
  SET dms.dms_media_signature_id = signature_ids->ids[d.seq].sig_id, dms.dms_media_instance_id =
   request->dms_media_instance_id, dms.signature_blob_id = signature_ids->ids[d.seq].blob_id,
   dms.signer = request->signatures[d.seq].signer, dms.sign_dt_tm = cnvtdatetime(request->signatures[
    d.seq].sign_dt_tm), dms.updt_id = reqinfo->updt_id,
   dms.updt_dt_tm = cnvtdatetime(curdate,curtime), dms.updt_task = reqinfo->updt_task, dms
   .updt_applctx = reqinfo->updt_applctx,
   dms.updt_cnt = 0
  PLAN (d)
   JOIN (dms)
  WITH nocounter
 ;end insert
 IF (curqual != signaturecount)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DMS_MEDIA_SIGNATURE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert the signatures"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 FREE RECORD signature_ids
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_MEDIA_SIGNATURE Script ====================>")
END GO
