CREATE PROGRAM dcp_inact_nomen_entity_reltn:dba
 IF (validate(reply->status_data.status,null)=null)
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
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_of_entities = cnvtint(value(size(request->nomen_entity_inact_qual,5)))
 SELECT INTO "nl:"
  ner.nomen_entity_reltn_id
  FROM nomen_entity_reltn ner,
   (dummyt d  WITH seq = value(nbr_of_entities))
  PLAN (d)
   JOIN (ner
   WHERE (ner.nomen_entity_reltn_id=request->nomen_entity_inact_qual[d.seq].nomen_entity_reltn_id))
  WITH nocounter, forupdate(ner)
 ;end select
 IF (curqual != nbr_of_entities)
  GO TO ner_lock_failed
 ENDIF
 UPDATE  FROM nomen_entity_reltn ner,
   (dummyt d  WITH seq = value(nbr_of_entities))
  SET ner.active_ind = 0, ner.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ner.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ner.updt_id = reqinfo->updt_id, ner.updt_task = reqinfo->updt_task, ner.updt_applctx = reqinfo->
   updt_applctx,
   ner.updt_cnt = (ner.updt_cnt+ 1)
  PLAN (d)
   JOIN (ner
   WHERE (ner.nomen_entity_reltn_id=request->nomen_entity_inact_qual[d.seq].nomen_entity_reltn_id))
  WITH nocounter
 ;end update
 IF (curqual != nbr_of_entities)
  GO TO ner_upd_failed
 ENDIF
 GO TO exit_script
#ner_lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMEN_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#ner_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMEN_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
