CREATE PROGRAM dcp_chg_mt_template_def:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET temp_cnt = cnvtint(size(request->qual,5))
 IF (temp_cnt > 0)
  UPDATE  FROM message_type_template_reltn mtt,
    (dummyt d  WITH seq = value(temp_cnt))
   SET mtt.default_ind = request->qual[d.seq].default_ind, mtt.updt_dt_tm = cnvtdatetime(curdate,
     curtime), mtt.updt_id = reqinfo->updt_id,
    mtt.updt_task = reqinfo->updt_task, mtt.updt_applctx = reqinfo->updt_applctx, mtt.med_ind =
    request->qual[d.seq].med_ind,
    mtt.updt_cnt = (mtt.updt_cnt+ 1)
   PLAN (d)
    JOIN (mtt
    WHERE (request->qual[d.seq].message_type_cd=mtt.message_type_cd)
     AND (request->qual[d.seq].template_id=mtt.template_id))
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
  SET reqinfo->commit_ind = 0
 ELSE
  IF (temp_cnt <= 0)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
END GO
