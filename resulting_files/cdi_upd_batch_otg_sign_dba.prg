CREATE PROGRAM cdi_upd_batch_otg_sign:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 batch_sign_qual[*]
      2 cdi_batch_otg_sign_id = f8
      2 event_id = f8
      2 blob_event_id = f8
      2 result_status_cd = f8
      2 event_cd = f8
      2 event_prsnl_id = f8
      2 blob_handle = vc
      2 action_prsnl_id = f8
      2 action_dt_tm = dq8
      2 action_type_cd = f8
      2 action_type_disp = c40
      2 action_type_mean = c12
      2 action_status_cd = f8
      2 action_status_disp = c40
      2 action_status_mean = c12
      2 status_cd = f8
      2 status_disp = c40
      2 status_mean = c12
      2 action_comment = vc
      2 proxy_prsnl_id = f8
      2 request_comment = vc
      2 action_tz = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE pending_cd = f8 WITH public, noconstant(0.0)
 DECLARE opened_cd = f8 WITH public, noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH public, noconstant(0.0)
 DECLARE complete_cd = f8 WITH public, noconstant(0.0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE selectedrows = i4 WITH public, noconstant(0)
 DECLARE insertedrows = i4 WITH public, noconstant(0)
 DECLARE index_num = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(79,"PENDING",1,pending_cd)
 SET stat = uar_get_meaning_by_codeset(79,"OPENED",1,opened_cd)
 SET stat = uar_get_meaning_by_codeset(79,"INPROCESS",1,inprocess_cd)
 SET stat = uar_get_meaning_by_codeset(79,"COMPLETE",1,complete_cd)
 SELECT INTO "nl:"
  cbos.*
  FROM cdi_batch_otg_sign cbos,
   ce_event_prsnl cep
  PLAN (cbos
   WHERE cbos.status_cd IN (pending_cd, opened_cd))
   JOIN (cep
   WHERE cep.event_prsnl_id=cbos.event_prsnl_id
    AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
  ORDER BY cbos.cdi_batch_otg_sign_id, cep.ce_event_prsnl_id DESC
  HEAD REPORT
   count = 0, stat = alterlist(reply->batch_sign_qual,10)
  HEAD cbos.cdi_batch_otg_sign_id
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 1)
    stat = alterlist(reply->batch_sign_qual,(count+ 9))
   ENDIF
   reply->batch_sign_qual[count].cdi_batch_otg_sign_id = cbos.cdi_batch_otg_sign_id, reply->
   batch_sign_qual[count].event_id = cbos.event_id, reply->batch_sign_qual[count].result_status_cd =
   cbos.result_status_cd,
   reply->batch_sign_qual[count].event_cd = cbos.event_cd, reply->batch_sign_qual[count].
   blob_event_id = cbos.blob_event_id, reply->batch_sign_qual[count].event_prsnl_id = cbos
   .event_prsnl_id,
   reply->batch_sign_qual[count].blob_handle = cbos.blob_handle, reply->batch_sign_qual[count].
   action_prsnl_id = cep.action_prsnl_id, reply->batch_sign_qual[count].action_dt_tm = cep
   .action_dt_tm,
   reply->batch_sign_qual[count].action_type_cd = cep.action_type_cd, reply->batch_sign_qual[count].
   action_status_cd = cep.action_status_cd, reply->batch_sign_qual[count].status_cd = cbos.status_cd,
   reply->batch_sign_qual[count].action_comment = cep.action_comment, reply->batch_sign_qual[count].
   proxy_prsnl_id = cep.proxy_prsnl_id, reply->batch_sign_qual[count].request_comment = cep
   .request_comment,
   reply->batch_sign_qual[count].action_tz = cep.action_tz
  FOOT REPORT
   stat = alterlist(reply->batch_sign_qual,count)
  WITH forupdate(cbos), nocounter, maxrec = 500
 ;end select
 SET selectedrows = size(reply->batch_sign_qual,5)
 UPDATE  FROM cdi_batch_otg_sign cbos
  SET cbos.seq = 1, cbos.status_cd = inprocess_cd, cbos.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cbos.updt_id = reqinfo->updt_id, cbos.updt_task = reqinfo->updt_task, cbos.updt_applctx = reqinfo
   ->updt_applctx,
   cbos.updt_cnt = (cbos.updt_cnt+ 1)
  WHERE expand(index_num,1,selectedrows,cbos.cdi_batch_otg_sign_id,reply->batch_sign_qual[index_num].
   cdi_batch_otg_sign_id)
  WITH nocounter
 ;end update
 SET insertedrows = curqual
 IF (selectedrows=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_BATCH_OTG_SIGN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Zero rows qualified for select."
  SET reqinfo->commit_ind = 1
 ELSEIF (selectedrows=insertedrows)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_BATCH_OTG_SIGN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Same number of rows were updated and read."
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_BATCH_OTG_SIGN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "A different number of rows were updated as read."
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
