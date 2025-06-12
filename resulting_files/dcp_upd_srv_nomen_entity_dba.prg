CREATE PROGRAM dcp_upd_srv_nomen_entity:dba
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
 RECORD rec_act(
   1 cnt = i2
   1 qual[*]
     2 add_ind = i2
     2 nomenclature_id = f8
     2 nomen_entity_reltn_id = f8
 )
 RECORD rec_inact(
   1 cnt = i2
   1 qual[*]
     2 nomen_entity_reltn_id = f8
 )
 SET rec_act->cnt = request->child_qual_cnt
 SET stat = alterlist(rec_act->qual,rec_act->cnt)
 FOR (xx = 1 TO rec_act->cnt)
  SET rec_act->qual[xx].add_ind = 1
  IF ((request->child_qual[xx].child_entity_name="NOMENCLATURE"))
   SET rec_act->qual[xx].nomenclature_id = request->child_qual[xx].child_entity_id
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  d.diagnosis_id
  FROM diagnosis d,
   (dummyt d1  WITH seq = value(request->child_qual_cnt))
  PLAN (d1
   WHERE (request->child_qual[d1.seq].child_entity_name="DIAGNOSIS"))
   JOIN (d
   WHERE (d.diagnosis_id=request->child_qual[d1.seq].child_entity_id))
  DETAIL
   rec_act->qual[d1.seq].nomenclature_id = d.nomenclature_id
  WITH nocounter
 ;end select
 SET rec_inact->cnt = 0
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nomen_entity_reltn_id = 0.0
 SELECT INTO "nl:"
  ner.nomen_entity_reltn_id
  FROM nomen_entity_reltn ner
  WHERE ner.parent_entity_name=trim(request->parent_entity_name)
   AND (ner.parent_entity_id=request->parent_entity_id)
   AND ner.active_ind=1
   AND ner.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND ner.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   found_ind = 0, same_reltn_type_ind = 0
   FOR (vv = 1 TO request->child_qual_cnt)
    IF ((request->child_qual[vv].child_entity_name=ner.child_entity_name)
     AND (request->child_qual[vv].child_entity_id=ner.child_entity_id)
     AND (request->child_qual[vv].priority=ner.priority))
     rec_act->qual[vv].add_ind = 0, found_ind = 1
    ENDIF
    ,
    IF ((ner.reltn_type_cd=request->child_qual[vv].reltn_type_cd))
     same_reltn_type_ind = 1
    ENDIF
   ENDFOR
   IF (found_ind=0
    AND same_reltn_type_ind=1)
    rec_inact->cnt = (rec_inact->cnt+ 1), stat = alterlist(rec_inact->qual,rec_inact->cnt), rec_inact
    ->qual[rec_inact->cnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (aa = 1 TO rec_act->cnt)
  IF ((request->child_qual[aa].child_entity_id=0))
   SET rec_act->qual[aa].add_ind = 0
  ENDIF
  IF ((rec_act->qual[aa].add_ind=1)
   AND failed="F")
   SET icnt = 0
   SELECT INTO "nl:"
    seq_nbr = seq(entity_reltn_seq,nextval)
    FROM dual
    DETAIL
     rec_act->qual[aa].nomen_entity_reltn_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "nextval"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "entity_reltn_seq"
    SET failed = "T"
   ENDIF
   IF (failed="F")
    INSERT  FROM nomen_entity_reltn ner
     SET ner.nomen_entity_reltn_id = rec_act->qual[aa].nomen_entity_reltn_id, ner.nomenclature_id =
      rec_act->qual[aa].nomenclature_id, ner.parent_entity_name = request->parent_entity_name,
      ner.parent_entity_id = request->parent_entity_id, ner.order_action_sequence = request->
      order_action_sequence, ner.child_entity_name = request->child_qual[aa].child_entity_name,
      ner.child_entity_id = request->child_qual[aa].child_entity_id, ner.reltn_type_cd = request->
      child_qual[aa].reltn_type_cd, ner.freetext_display = request->child_qual[aa].freetext_display,
      ner.priority = request->child_qual[aa].priority, ner.person_id = request->person_id, ner
      .encntr_id = request->encntr_id,
      ner.active_ind = 1, ner.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ner
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      ner.updt_dt_tm = cnvtdatetime(curdate,curtime3), ner.updt_id = reqinfo->updt_id, ner.updt_task
       = reqinfo->updt_task,
      ner.updt_applctx = reqinfo->updt_applctx, ner.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMEN_ENTITY_RELTN"
     SET failed = "T"
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (failed="T")
  GO TO exit_script
 ENDIF
 IF ((rec_inact->cnt > 0))
  UPDATE  FROM nomen_entity_reltn ner,
    (dummyt d  WITH seq = value(rec_inact->cnt))
   SET ner.active_ind = 0, ner.inactive_order_action_sequence = request->order_action_sequence, ner
    .end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    ner.updt_dt_tm = cnvtdatetime(curdate,curtime3), ner.updt_id = reqinfo->updt_id, ner.updt_task =
    reqinfo->updt_task,
    ner.updt_applctx = reqinfo->updt_applctx, ner.updt_cnt = (ner.updt_cnt+ 1)
   PLAN (d)
    JOIN (ner
    WHERE (ner.nomen_entity_reltn_id=rec_inact->qual[d.seq].nomen_entity_reltn_id))
   WITH nocounter
  ;end update
  IF ((curqual != rec_inact->cnt))
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMEN_ENTITY_RELTN"
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 CALL echo(build("failed ind",failed))
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
