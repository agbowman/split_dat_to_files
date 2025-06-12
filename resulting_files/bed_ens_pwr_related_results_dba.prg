CREATE PROGRAM bed_ens_pwr_related_results:dba
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
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 SET ecnt = size(request->event_sets,5)
 IF (ecnt > 0)
  INSERT  FROM pw_evidence_reltn p,
    (dummyt d  WITH seq = ecnt)
   SET p.pw_evidence_reltn_id = seq(reference_seq,nextval), p.pathway_catalog_id = request->
    powerplan_or_phase_id, p.type_mean = "EVENTSET",
    p.evidence_locator = request->event_sets[d.seq].event_set_name, p.evidence_sequence = request->
    event_sets[d.seq].sequence, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_cnt = 0,
    p.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->event_sets[d.seq].action_flag=1))
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM pw_evidence_reltn p,
    (dummyt d  WITH seq = value(ecnt))
   SET p.evidence_locator = request->event_sets[d.seq].event_set_name, p.evidence_sequence = request
    ->event_sets[d.seq].sequence, p.updt_id = reqinfo->updt_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task = reqinfo->updt_task, p.updt_applctx
     = reqinfo->updt_applctx,
    p.updt_cnt = (p.updt_cnt+ 1)
   PLAN (d
    WHERE (request->event_sets[d.seq].action_flag=2))
    JOIN (p
    WHERE (p.pw_evidence_reltn_id=request->event_sets[d.seq].pw_evidence_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_evidence_reltn p,
    (dummyt d  WITH seq = value(ecnt))
   SET p.seq = 1
   PLAN (d
    WHERE (request->event_sets[d.seq].action_flag=3))
    JOIN (p
    WHERE (p.pw_evidence_reltn_id=request->event_sets[d.seq].pw_evidence_reltn_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
