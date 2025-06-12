CREATE PROGRAM bed_cpy_pwr_related_results:dba
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
 RECORD delete_temp(
   1 event_sets[*]
     2 event_set_name = vc
 )
 RECORD found_temp(
   1 event_sets[*]
     2 row_exists = i2
     2 seq_correct = i2
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET pcnt = size(request->powerplans,5)
 SET ecnt = size(request->event_sets,5)
 FOR (p = 1 TO pcnt)
   SET delcnt = 0
   SELECT INTO "nl:"
    FROM pw_evidence_reltn per
    WHERE (per.pathway_catalog_id=request->powerplans[p].id)
    DETAIL
     num = 0, found_ind = 0, found_ind = locateval(num,1,ecnt,per.evidence_locator,request->
      event_sets[num].event_set_name)
     IF (found_ind=0)
      delcnt = (delcnt+ 1), stat = alterlist(delete_temp->event_sets,delcnt), delete_temp->
      event_sets[delcnt].event_set_name = per.evidence_locator
     ENDIF
    WITH nocounter
   ;end select
   IF (delcnt > 0)
    DELETE  FROM pw_evidence_reltn per,
      (dummyt d  WITH seq = value(delcnt))
     SET per.seq = 1
     PLAN (d)
      JOIN (per
      WHERE (per.pathway_catalog_id=request->powerplans[p].id)
       AND (per.evidence_locator=delete_temp->event_sets[d.seq].event_set_name))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET stat = alterlist(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error deleting from pw_evidence_reltn")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (ecnt > 0)
    SET stat = initrec(found_temp)
    SET stat = alterlist(found_temp->event_sets,ecnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ecnt),
      pw_evidence_reltn per
     PLAN (d)
      JOIN (per
      WHERE (per.pathway_catalog_id=request->powerplans[p].id)
       AND (per.evidence_locator=request->event_sets[d.seq].event_set_name))
     DETAIL
      found_temp->event_sets[d.seq].row_exists = 1
      IF ((per.evidence_sequence=request->event_sets[d.seq].sequence))
       found_temp->event_sets[d.seq].seq_correct = 1
      ENDIF
     WITH nocounter
    ;end select
    INSERT  FROM pw_evidence_reltn per,
      (dummyt d  WITH seq = ecnt)
     SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = request->
      powerplans[p].id, per.type_mean = "EVENTSET",
      per.evidence_locator = request->event_sets[d.seq].event_set_name, per.evidence_sequence =
      request->event_sets[d.seq].sequence, per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->updt_task, per.updt_cnt = 0,
      per.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (found_temp->event_sets[d.seq].row_exists=0))
      JOIN (per)
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
    UPDATE  FROM pw_evidence_reltn per,
      (dummyt d  WITH seq = value(ecnt))
     SET per.evidence_sequence = request->event_sets[d.seq].sequence, per.updt_id = reqinfo->updt_id,
      per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = (
      per.updt_cnt+ 1)
     PLAN (d
      WHERE (found_temp->event_sets[d.seq].row_exists=1)
       AND (found_temp->event_sets[d.seq].seq_correct=0))
      JOIN (per
      WHERE (per.pathway_catalog_id=request->powerplans[p].id)
       AND (per.evidence_locator=request->event_sets[d.seq].event_set_name))
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
   ENDIF
 ENDFOR
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
