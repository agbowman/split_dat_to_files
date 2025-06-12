CREATE PROGRAM aps_chg_diag_source_vocabs:dba
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
 SET number_to_del = size(request->del_source_vocab_qual,5)
 SET number_to_add = size(request->add_source_vocab_qual,5)
 SET reqinfo->commit_ind = 0
 IF (number_to_del > 0)
  DELETE  FROM ap_source_vocabulary_r asvr,
    (dummyt d  WITH seq = value(number_to_del))
   SET asvr.seq = 1
   PLAN (d)
    JOIN (asvr
    WHERE (asvr.source_vocabulary_cd=request->del_source_vocab_qual[d.seq].source_vocab_cd)
     AND (asvr.include_source_vocabulary_cd=request->del_source_vocab_qual[d.seq].include_vocab_cd))
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_SOURCE_VOCABULARY_R"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (number_to_add > 0)
  INSERT  FROM ap_source_vocabulary_r asvr,
    (dummyt d  WITH seq = value(number_to_add))
   SET asvr.include_source_vocabulary_cd = request->add_source_vocab_qual[d.seq].include_vocab_cd,
    asvr.source_vocabulary_cd = request->add_source_vocab_qual[d.seq].source_vocab_cd, asvr.updt_cnt
     = 0,
    asvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), asvr.updt_id = reqinfo->updt_id, asvr.updt_task
     = reqinfo->updt_task,
    asvr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (asvr)
   WITH nocounter
  ;end insert
  IF (curqual != number_to_add)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_SOURCE_VOCABULARY_R"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
