CREATE PROGRAM bed_ens_problem_results:dba
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
 RECORD temp_delete(
   1 results[*]
     2 event_set_name = vc
     2 concept_cki = vc
 )
 RECORD temp_update(
   1 results[*]
     2 event_set_name = vc
     2 sequence = i4
     2 concept_cki = vc
 )
 RECORD temp_insert(
   1 results[*]
     2 event_set_name = vc
     2 sequence = i4
     2 concept_cki = vc
     2 entity_id = f8
 )
 DECLARE cki_cnt = i4 WITH noconstant(0)
 DECLARE result_cnt = i4 WITH noconstant(0)
 DECLARE ins_cnt = i4 WITH noconstant(0)
 DECLARE del_cnt = i4 WITH noconstant(0)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 SET probresult_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PROBRESULT"
   AND cv.active_ind=1
   AND cv.code_set=29753
  DETAIL
   probresult_cd = cv.code_value
  WITH nocounter
 ;end select
 SET activestatus_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
   AND cv.code_set=48
  DETAIL
   activestatus_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET cki_cnt = size(request->concept_cki,5)
 FOR (j = 1 TO cki_cnt)
  SET result_cnt = size(request->concept_cki[j].results,5)
  FOR (i = 1 TO result_cnt)
    IF ((request->concept_cki[j].results[i].action_flag=3))
     SET del_cnt = (del_cnt+ 1)
     SET stat = alterlist(temp_delete->results,del_cnt)
     SET temp_delete->results[del_cnt].event_set_name = request->concept_cki[j].results[i].
     event_set_name
     SET temp_delete->results[del_cnt].concept_cki = request->concept_cki[j].concept_cki
    ENDIF
    IF ((request->concept_cki[j].results[i].action_flag=2))
     SET updt_cnt = (updt_cnt+ 1)
     SET stat = alterlist(temp_update->results,updt_cnt)
     SET temp_update->results[updt_cnt].event_set_name = request->concept_cki[j].results[i].
     event_set_name
     SET temp_update->results[updt_cnt].sequence = request->concept_cki[j].results[i].sequence
     SET temp_update->results[updt_cnt].concept_cki = request->concept_cki[j].concept_cki
    ENDIF
    IF ((request->concept_cki[j].results[i].action_flag=1))
     SET ins_cnt = (ins_cnt+ 1)
     SET stat = alterlist(temp_insert->results,ins_cnt)
     SET temp_insert->results[ins_cnt].event_set_name = request->concept_cki[j].results[i].
     event_set_name
     SET temp_insert->results[ins_cnt].sequence = request->concept_cki[j].results[i].sequence
     SET temp_insert->results[ins_cnt].concept_cki = request->concept_cki[j].concept_cki
    ENDIF
  ENDFOR
 ENDFOR
 IF (del_cnt > 0)
  DELETE  FROM concept_cki_entity_r c,
    (dummyt d  WITH seq = value(del_cnt))
   SET c.seq = 1
   PLAN (d)
    JOIN (c
    WHERE (c.concept_cki=temp_delete->results[d.seq].concept_cki)
     AND (c.event_set_name=temp_delete->results[d.seq].event_set_name)
     AND c.reltn_type_cd=probresult_cd)
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from concept_cki_entity_r table")
 ENDIF
 IF (updt_cnt > 0)
  UPDATE  FROM concept_cki_entity_r c,
    (dummyt d  WITH seq = value(updt_cnt))
   SET c.group_seq = temp_update->results[d.seq].sequence, c.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), c.updt_id = reqinfo->updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (c
    WHERE (c.concept_cki=temp_update->results[d.seq].concept_cki)
     AND (c.event_set_name=temp_update->results[d.seq].event_set_name)
     AND c.reltn_type_cd=probresult_cd)
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating concept_cki_entity_r table")
 ENDIF
 IF (ins_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ins_cnt)),
    v500_event_set_code v
   PLAN (d)
    JOIN (v
    WHERE (v.event_set_name=temp_insert->results[d.seq].event_set_name))
   DETAIL
    temp_insert->results[d.seq].entity_id = v.event_set_cd
   WITH nocounter
  ;end select
  INSERT  FROM concept_cki_entity_r c,
    (dummyt d  WITH seq = value(ins_cnt))
   SET c.active_ind = 1, c.active_status_cd = activestatus_cd, c.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    c.active_status_prsnl_id = reqinfo->updt_id, c.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), c.cki_sequence = 0,
    c.concept_cki = temp_insert->results[d.seq].concept_cki, c.concept_cki_entity_r_id = seq(
     entity_reltn_seq,nextval), c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    c.entity_id = temp_insert->results[d.seq].entity_id, c.entity_name = "CODE_VALUE", c.group_seq =
    temp_insert->results[d.seq].sequence,
    c.reltn_type_cd = probresult_cd, c.event_set_name = temp_insert->results[d.seq].event_set_name, c
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
    updt_applctx,
    c.updt_cnt = 0
   PLAN (d)
    JOIN (c)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into concept_cki_entity_r table")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
