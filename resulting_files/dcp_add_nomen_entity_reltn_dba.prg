CREATE PROGRAM dcp_add_nomen_entity_reltn:dba
 SET use_reply_internal = 0
 IF (validate(reply->status_data.status,null)=null)
  RECORD reply(
    1 nomen_entity_qual[*]
      2 nomen_entity_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET use_reply_internal = 1
 ENDIF
 FREE RECORD validated_req_internal
 RECORD validated_req_internal(
   1 nomen_entity_qual[*]
     2 diag_priority = i4
 )
 IF ( NOT (validate(req_internal,0)))
  RECORD req_internal(
    1 nomen_entity_qual[*]
      2 nomenclature_id = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 child_entity_name = c32
      2 child_entity_id = f8
      2 reltn_type_cd = i4
      2 freetext_display = vc
      2 person_id = f8
      2 encntr_id = f8
  )
  SET stat = alterlist(req_internal->nomen_entity_qual,size(request->nomen_entity_qual,5))
  SET stat = alterlist(validated_req_internal->nomen_entity_qual,size(request->nomen_entity_qual,5))
  FOR (idx = 1 TO size(request->nomen_entity_qual,5))
    SET req_internal->nomen_entity_qual[idx].nomenclature_id = request->nomen_entity_qual[idx].
    nomenclature_id
    SET req_internal->nomen_entity_qual[idx].parent_entity_name = request->nomen_entity_qual[idx].
    parent_entity_name
    SET req_internal->nomen_entity_qual[idx].parent_entity_id = request->nomen_entity_qual[idx].
    parent_entity_id
    SET req_internal->nomen_entity_qual[idx].child_entity_name = request->nomen_entity_qual[idx].
    child_entity_name
    SET req_internal->nomen_entity_qual[idx].child_entity_id = request->nomen_entity_qual[idx].
    child_entity_id
    SET req_internal->nomen_entity_qual[idx].reltn_type_cd = request->nomen_entity_qual[idx].
    reltn_type_cd
    SET req_internal->nomen_entity_qual[idx].freetext_display = request->nomen_entity_qual[idx].
    freetext_display
    SET req_internal->nomen_entity_qual[idx].person_id = request->nomen_entity_qual[idx].person_id
    SET req_internal->nomen_entity_qual[idx].encntr_id = request->nomen_entity_qual[idx].encntr_id
    SET validated_req_internal->nomen_entity_qual[idx].diag_priority = validate(request->
     nomen_entity_qual[idx].diag_priority,0)
  ENDFOR
 ELSE
  SET stat = alterlist(validated_req_internal->nomen_entity_qual,size(req_internal->nomen_entity_qual,
    5))
  FOR (idx = 1 TO size(req_internal->nomen_entity_qual,5))
    SET validated_req_internal->nomen_entity_qual[idx].diag_priority = validate(req_internal->
     nomen_entity_qual[idx].diag_priority,0)
  ENDFOR
 ENDIF
 IF ( NOT (validate(reply_internal,0)))
  RECORD reply_internal(
    1 nomen_entity_qual[*]
      2 nomen_entity_reltn_id = f8
  )
 ENDIF
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_of_entities = cnvtint(value(size(req_internal->nomen_entity_qual,5)))
 SET stat = alterlist(reply_internal->nomen_entity_qual,nbr_of_entities)
 SET nomen_entity_reltn_id = 0.0
 SET icnt = 0
 FOR (icnt = 1 TO nbr_of_entities)
  SELECT INTO "nl:"
   seq_nbr = seq(entity_reltn_seq,nextval)
   FROM dual
   DETAIL
    nomen_entity_reltn_id = seq_nbr, reply_internal->nomen_entity_qual[icnt].nomen_entity_reltn_id =
    nomen_entity_reltn_id
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO ner_seq_failed
  ENDIF
 ENDFOR
 INSERT  FROM nomen_entity_reltn ner,
   (dummyt d  WITH seq = value(nbr_of_entities))
  SET ner.nomen_entity_reltn_id = reply_internal->nomen_entity_qual[d.seq].nomen_entity_reltn_id, ner
   .nomenclature_id = req_internal->nomen_entity_qual[d.seq].nomenclature_id, ner.parent_entity_name
    = req_internal->nomen_entity_qual[d.seq].parent_entity_name,
   ner.parent_entity_id = req_internal->nomen_entity_qual[d.seq].parent_entity_id, ner
   .child_entity_name = req_internal->nomen_entity_qual[d.seq].child_entity_name, ner.child_entity_id
    = req_internal->nomen_entity_qual[d.seq].child_entity_id,
   ner.reltn_type_cd = req_internal->nomen_entity_qual[d.seq].reltn_type_cd, ner.freetext_display =
   req_internal->nomen_entity_qual[d.seq].freetext_display, ner.person_id = req_internal->
   nomen_entity_qual[d.seq].person_id,
   ner.encntr_id = req_internal->nomen_entity_qual[d.seq].encntr_id, ner.priority =
   validated_req_internal->nomen_entity_qual[d.seq].diag_priority, ner.active_ind = 1,
   ner.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ner.beg_effective_dt_tm =
   cnvtdatetime(sysdate), ner.updt_dt_tm = cnvtdatetime(sysdate),
   ner.updt_id = reqinfo->updt_id, ner.updt_task = reqinfo->updt_task, ner.updt_applctx = reqinfo->
   updt_applctx,
   ner.updt_cnt = 0
  PLAN (d)
   JOIN (ner
   WHERE (ner.parent_entity_name=req_internal->nomen_entity_qual[d.seq].parent_entity_name)
    AND (ner.parent_entity_id=req_internal->nomen_entity_qual[d.seq].parent_entity_id)
    AND (ner.nomenclature_id=req_internal->nomen_entity_qual[d.seq].nomenclature_id)
    AND ner.active_ind=1)
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_of_entities)
  GO TO ner_ins_failed
 ENDIF
 IF (use_reply_internal=0)
  SET stat = alterlist(reply->nomen_entity_qual,nbr_of_entities)
  FOR (idx = 1 TO nbr_of_entities)
    SET reply->nomen_entity_qual[idx].nomen_entity_reltn_id = reply_internal->nomen_entity_qual[idx].
    nomen_entity_reltn_id
  ENDFOR
 ENDIF
 GO TO exit_script
#ner_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "pathnet_seq"
 SET failed = "T"
 GO TO exit_script
#ner_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
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
