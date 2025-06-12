CREATE PROGRAM bed_ens_mdro_outbreak:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 outbreak_reply[*]
      2 outbreak_id = f8
      2 parent_entity_type = i2
      2 parent_entity_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempaddoutbreak(
   1 outbreak_result[*]
     2 outbreak_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 facility_occurrence_cnt = i4
     2 facility_time_span = i4
     2 facility_time_span_cd = f8
     2 unit_occurrence_cnt = i4
     2 unit_time_span = i4
     2 unit_time_span_cd = f8
     2 location_cd = f8
     2 facility_probability_flag = i2
 )
 RECORD tempupdateob(
   1 outbreak_result[*]
     2 outbreak_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 facility_occurrence_cnt = i4
     2 facility_time_span = i4
     2 facility_time_span_cd = f8
     2 unit_occurrence_cnt = i4
     2 unit_time_span = i4
     2 unit_time_span_cd = f8
     2 location_cd = f8
     2 facility_probability_flag = i2
 )
 RECORD tempdeleteob(
   1 outbreak_result[*]
     2 outbreak_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 facility_occurrence_cnt = i4
     2 facility_time_span = i4
     2 facility_time_span_cd = f8
     2 unit_occurrence_cnt = i4
     2 unit_time_span = i4
     2 unit_time_span_cd = f8
     2 location_cd = f8
 )
 DECLARE dummy = f8
 DECLARE parent_entity_name = vc
 DECLARE outbreakid = f8
 SET addcnt = 0
 SET updatecnt = 0
 SET deletecnt = 0
 SET outbreakcount = 0
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
 SET outbreakcount = size(request->outbreak_results,5)
 IF (outbreakcount=0)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF (outbreakcount > 0)
  FOR (i = 1 TO outbreakcount)
   IF ((request->outbreak_results[i].parent_entity_type=1))
    SET parent_entity_name = "BR_MDRO"
   ELSEIF ((request->outbreak_results[i].parent_entity_type=2))
    SET parent_entity_name = "BR_MDRO_CAT"
   ELSEIF ((request->outbreak_results[i].parent_entity_type=3))
    SET parent_entity_name = "BR_MDRO_CAT_ORGANISM"
   ELSEIF ((request->outbreak_results[i].parent_entity_type=4))
    SET parent_entity_name = "BR_MDRO_CAT_EVENT"
   ELSE
    CALL bederrorcheck("Error invalid outbreak_result.parent_entity_type.")
   ENDIF
   IF ((request->outbreak_results[i].action_flag=1))
    SELECT INTO "nl:"
     temp = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      outbreakid = cnvtreal(temp)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error selecting new outbreak id.")
    SET addcnt = (addcnt+ 1)
    SET stat = alterlist(tempaddoutbreak->outbreak_result,addcnt)
    SET tempaddoutbreak->outbreak_result[addcnt].outbreak_id = outbreakid
    SET tempaddoutbreak->outbreak_result[addcnt].parent_entity_name = parent_entity_name
    SET tempaddoutbreak->outbreak_result[addcnt].parent_entity_id = request->outbreak_results[i].
    parent_entity_id
    SET tempaddoutbreak->outbreak_result[addcnt].facility_occurrence_cnt = request->outbreak_results[
    i].facility_occurrence_cnt
    SET tempaddoutbreak->outbreak_result[addcnt].facility_time_span = request->outbreak_results[i].
    facility_time_span
    SET tempaddoutbreak->outbreak_result[addcnt].facility_time_span_cd = request->outbreak_results[i]
    .facility_time_span_code_value
    SET tempaddoutbreak->outbreak_result[addcnt].unit_occurrence_cnt = request->outbreak_results[i].
    unit_occurrence_cnt
    SET tempaddoutbreak->outbreak_result[addcnt].unit_time_span = request->outbreak_results[i].
    unit_time_span
    SET tempaddoutbreak->outbreak_result[addcnt].unit_time_span_cd = request->outbreak_results[i].
    unit_time_span_code_value
    SET tempaddoutbreak->outbreak_result[addcnt].location_cd = request->outbreak_results[i].
    location_code_value
    SET tempaddoutbreak->outbreak_result[addcnt].facility_probability_flag = request->
    outbreak_results[i].facility_probability_flag
    SET stat = alterlist(reply->outbreak_reply,addcnt)
    SET reply->outbreak_reply[addcnt].outbreak_id = outbreakid
    SET reply->outbreak_reply[addcnt].parent_entity_type = request->outbreak_results[i].
    parent_entity_type
    SET reply->outbreak_reply[addcnt].parent_entity_id = request->outbreak_results[i].
    parent_entity_id
   ELSEIF ((request->outbreak_results[i].action_flag=2))
    SET updatecnt = (updatecnt+ 1)
    SET stat = alterlist(tempupdateob->outbreak_result,updatecnt)
    SET tempupdateob->outbreak_result[updatecnt].outbreak_id = request->outbreak_results[i].
    outbreak_id
    SET tempupdateob->outbreak_result[updatecnt].parent_entity_name = parent_entity_name
    SET tempupdateob->outbreak_result[updatecnt].parent_entity_id = request->outbreak_results[i].
    parent_entity_id
    SET tempupdateob->outbreak_result[updatecnt].facility_occurrence_cnt = request->outbreak_results[
    i].facility_occurrence_cnt
    SET tempupdateob->outbreak_result[updatecnt].facility_time_span = request->outbreak_results[i].
    facility_time_span
    SET tempupdateob->outbreak_result[updatecnt].facility_time_span_cd = request->outbreak_results[i]
    .facility_time_span_code_value
    SET tempupdateob->outbreak_result[updatecnt].unit_occurrence_cnt = request->outbreak_results[i].
    unit_occurrence_cnt
    SET tempupdateob->outbreak_result[updatecnt].unit_time_span = request->outbreak_results[i].
    unit_time_span
    SET tempupdateob->outbreak_result[updatecnt].unit_time_span_cd = request->outbreak_results[i].
    unit_time_span_code_value
    SET tempupdateob->outbreak_result[updatecnt].location_cd = request->outbreak_results[i].
    location_code_value
    SET tempupdateob->outbreak_result[updatecnt].facility_probability_flag = request->
    outbreak_results[i].facility_probability_flag
   ELSEIF ((request->outbreak_results[i].action_flag=3))
    SET deletecnt = (deletecnt+ 1)
    SET stat = alterlist(tempdeleteob->outbreak_result,deletecnt)
    SET tempdeleteob->outbreak_result[deletecnt].outbreak_id = request->outbreak_results[i].
    outbreak_id
   ENDIF
  ENDFOR
 ENDIF
 IF (deletecnt > 0)
  DELETE  FROM br_mdro_outbreak ob,
    (dummyt d  WITH seq = deletecnt)
   SET ob.seq = 1
   PLAN (d)
    JOIN (ob
    WHERE (ob.br_mdro_outbreak_id=tempdeleteob->outbreak_result[d.seq].outbreak_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from the br_mdro_outbreak table")
 ENDIF
 IF (updatecnt > 0)
  UPDATE  FROM br_mdro_outbreak ob,
    (dummyt d  WITH seq = updatecnt)
   SET ob.parent_entity_name = tempupdateob->outbreak_result[d.seq].parent_entity_name, ob
    .parent_entity_id = tempupdateob->outbreak_result[d.seq].parent_entity_id, ob
    .facility_occurrence_cnt = tempupdateob->outbreak_result[d.seq].facility_occurrence_cnt,
    ob.facility_time_span_nbr = tempupdateob->outbreak_result[d.seq].facility_time_span, ob
    .facility_time_span_unit_cd = tempupdateob->outbreak_result[d.seq].facility_time_span_cd, ob
    .unit_occurrence_cnt = tempupdateob->outbreak_result[d.seq].unit_occurrence_cnt,
    ob.unit_time_span_nbr = tempupdateob->outbreak_result[d.seq].unit_time_span, ob
    .unit_time_span_unit_cd = tempupdateob->outbreak_result[d.seq].unit_time_span_cd, ob.location_cd
     = tempupdateob->outbreak_result[d.seq].location_cd,
    ob.probability_theory_ind = tempupdateob->outbreak_result[d.seq].facility_probability_flag, ob
    .updt_cnt = (ob.updt_cnt+ 1), ob.updt_applctx = reqinfo->updt_applctx,
    ob.updt_dt_tm = cnvtdatetime(curdate,curtime3), ob.updt_id = reqinfo->updt_id, ob.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (ob
    WHERE (ob.br_mdro_outbreak_id=tempupdateob->outbreak_result[d.seq].outbreak_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating the br_mdro_outbreak table")
 ENDIF
 IF (addcnt > 0)
  INSERT  FROM br_mdro_outbreak ob,
    (dummyt d  WITH seq = addcnt)
   SET ob.br_mdro_outbreak_id = tempaddoutbreak->outbreak_result[d.seq].outbreak_id, ob
    .parent_entity_name = tempaddoutbreak->outbreak_result[d.seq].parent_entity_name, ob
    .parent_entity_id = tempaddoutbreak->outbreak_result[d.seq].parent_entity_id,
    ob.facility_occurrence_cnt = tempaddoutbreak->outbreak_result[d.seq].facility_occurrence_cnt, ob
    .facility_time_span_nbr = tempaddoutbreak->outbreak_result[d.seq].facility_time_span, ob
    .facility_time_span_unit_cd = tempaddoutbreak->outbreak_result[d.seq].facility_time_span_cd,
    ob.unit_occurrence_cnt = tempaddoutbreak->outbreak_result[d.seq].unit_occurrence_cnt, ob
    .unit_time_span_nbr = tempaddoutbreak->outbreak_result[d.seq].unit_time_span, ob
    .unit_time_span_unit_cd = tempaddoutbreak->outbreak_result[d.seq].unit_time_span_cd,
    ob.location_cd = tempaddoutbreak->outbreak_result[d.seq].location_cd, ob.probability_theory_ind
     = tempaddoutbreak->outbreak_result[d.seq].facility_probability_flag, ob.updt_cnt = 0,
    ob.updt_applctx = reqinfo->updt_applctx, ob.updt_dt_tm = cnvtdatetime(curdate,curtime3), ob
    .updt_id = reqinfo->updt_id,
    ob.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ob)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_mdro_outbreak table")
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
