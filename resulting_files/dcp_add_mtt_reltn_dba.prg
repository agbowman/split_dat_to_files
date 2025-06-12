CREATE PROGRAM dcp_add_mtt_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reltn_cd = 0
 SET mtt_cnt = cnvtint(size(request->reltn,5))
 IF (mtt_cnt > 0)
  INSERT  FROM message_type_template_reltn mtt,
    (dummyt d  WITH seq = value(mtt_cnt))
   SET mtt.message_type_template_reltn_id = cnvtreal(seq(reference_seq,nextval)), mtt.template_id =
    request->reltn[d.seq].template_id, mtt.message_type_cd = request->reltn[d.seq].message_type_cd,
    mtt.default_ind = request->reltn[d.seq].default_ind, mtt.updt_dt_tm = cnvtdatetime(curdate,
     curtime), mtt.updt_id = reqinfo->updt_id,
    mtt.updt_task = reqinfo->updt_task, mtt.updt_applctx = reqinfo->updt_applctx, mtt.med_ind =
    request->reltn[d.seq].med_ind,
    mtt.updt_cnt = 0
   PLAN (d)
    JOIN (mtt)
   WITH nocounter, outerjoin = d
  ;end insert
  IF (curqual != mtt_cnt)
   SET failed = "T"
   SET cs_table = "MESSAGE TYPE TEMPLATE RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  IF (mtt_cnt <= 0)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cs_table
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
