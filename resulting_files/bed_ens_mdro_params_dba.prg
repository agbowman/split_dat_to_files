CREATE PROGRAM bed_ens_mdro_params:dba
 RECORD request(
   1 organisms[*]
     2 organism_action_flag = i2
     2 organism_id = f8
     2 organism_category_id = f8
     2 organism_code_value = f8
     2 organism_location_code_value = f8
     2 organism_mdro_id = f8
     2 group_resistant_cnt = i4
     2 antibiotics_text = vc
     2 drug_groups[*]
       3 drug_group_action_flag = i2
       3 drug_group_id = f8
       3 drug_resistant_cnt = i4
       3 drugs[*]
         4 drug_code_value = f8
         4 results[*]
           5 result_action_flag = i2
           5 result_code_value = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
   1 events[*]
     2 event_action_flag = i2
     2 event_id = f8
     2 event_category_id = f8
     2 event_code_value = f8
     2 event_location_code_value = f8
     2 event_mdro_id = f8
     2 normalcy_codes[*]
       3 normalcy_code_action_flag = i2
       3 normalcy_code_value = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
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
 RECORD tempaddorganisms(
   1 organisms[*]
     2 organism_id = f8
     2 category_id = f8
     2 organism_code_value = f8
     2 location_code_value = f8
     2 mdro_id = f8
     2 group_resistant_cnt = i4
     2 antibiotic_text = vc
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 RECORD tempupdateorganisms(
   1 organisms[*]
     2 organism_id = f8
     2 category_id = f8
     2 organism_code_value = f8
     2 location_code_value = f8
     2 mdro_id = f8
     2 group_resistant_cnt = i4
     2 antibiotic_text = vc
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 RECORD tempdeleteorganisms(
   1 organisms[*]
     2 organism_id = f8
 )
 RECORD tempadddruggroup(
   1 drug_groups[*]
     2 drug_group_organism_id = f8
     2 drug_group_id = f8
     2 organism_id = f8
     2 drug_resistant_cnt = i4
 )
 RECORD tempupdatedruggroup(
   1 drug_groups[*]
     2 drug_group_organism_id = f8
     2 drug_group_id = f8
     2 organism_id = f8
     2 drug_resistant_cnt = i4
 )
 RECORD tempdeletedruggroup(
   1 drug_groups[*]
     2 drug_group_organism_id = f8
 )
 RECORD tempadddrugresult(
   1 drug_results[*]
     2 br_drug_group_organism_id = f8
     2 br_drug_group_antibiotic_id = f8
     2 result_code_value = f8
 )
 RECORD tempdeletedrugresult(
   1 drug_results[*]
     2 br_drug_group_organism_id = f8
     2 br_drug_group_antibiotic_id = f8
     2 result_code_value = f8
 )
 RECORD tempaddevents(
   1 events[*]
     2 event_id = f8
     2 category_id = f8
     2 event_code_value = f8
     2 location_code_value = f8
     2 mdro_id = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 RECORD tempupdateevents(
   1 events[*]
     2 event_id = f8
     2 category_id = f8
     2 event_code_value = f8
     2 location_code_value = f8
     2 mdro_id = f8
     2 lookback_time_span_nbr = i4
     2 lookback_time_span_unit_cd = f8
 )
 RECORD tempdeleteevents(
   1 events[*]
     2 event_id = f8
 )
 RECORD tempaddnormalcycodes(
   1 normalcy_codes[*]
     2 normalcy_code_value = f8
     2 event_id = f8
 )
 RECORD tempdeletenormalcycodes(
   1 normalcy_codes[*]
     2 normalcy_code_value = f8
     2 event_id = f8
 )
 DECLARE populatedruggroups(i=i4,organismid=f8) = null
 DECLARE populatedrugresults(i=i4,j=i4,organismid=f8,druggroupid=f8,druggrouporganismid=f8) = null
 DECLARE populatenormalcycodes(i=i4,eventid=f8) = null
 DECLARE tempstring = vc
 SET count = 0
 SET num = 0
 SET addorganismcount = 0
 SET updateorganismcount = 0
 SET deleteorganismcount = 0
 SET adddruggroupcount = 0
 SET updatedruggroupcount = 0
 SET deletedruggroupcount = 0
 SET adddrugresultcount = 0
 SET deletedrugresultcount = 0
 SET addeventcount = 0
 SET updateeventcount = 0
 SET deleteeventcount = 0
 SET addnormalcycodecount = 0
 SET deletenormalcycodecount = 0
 SET organismcount = size(request->organisms,5)
 SET eventcount = size(request->events,5)
 IF (organismcount > 0)
  FOR (i = 1 TO organismcount)
    SET organismid = request->organisms[i].organism_id
    IF ((request->organisms[i].organism_action_flag=1))
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       organismid = cnvtreal(temp)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting new organism id")
     SET addorganismcount = (addorganismcount+ 1)
     SET stat = alterlist(tempaddorganisms->organisms,addorganismcount)
     SET tempaddorganisms->organisms[addorganismcount].antibiotic_text = request->organisms[i].
     antibiotics_text
     SET tempaddorganisms->organisms[addorganismcount].category_id = request->organisms[i].
     organism_category_id
     SET tempaddorganisms->organisms[addorganismcount].group_resistant_cnt = request->organisms[i].
     group_resistant_cnt
     SET tempaddorganisms->organisms[addorganismcount].location_code_value = request->organisms[i].
     organism_location_code_value
     SET tempaddorganisms->organisms[addorganismcount].mdro_id = request->organisms[i].
     organism_mdro_id
     SET tempaddorganisms->organisms[addorganismcount].organism_code_value = request->organisms[i].
     organism_code_value
     SET tempaddorganisms->organisms[addorganismcount].organism_id = organismid
     SET tempaddorganisms->organisms[addorganismcount].lookback_time_span_nbr = request->organisms[i]
     .lookback_time_span_nbr
     SET tempaddorganisms->organisms[addorganismcount].lookback_time_span_unit_cd = request->
     organisms[i].lookback_time_span_unit_cd
    ELSEIF ((request->organisms[i].organism_action_flag=2))
     SET updateorganismcount = (updateorganismcount+ 1)
     SET stat = alterlist(tempupdateorganisms->organisms,updateorganismcount)
     SET tempupdateorganisms->organisms[updateorganismcount].antibiotic_text = request->organisms[i].
     antibiotics_text
     SET tempupdateorganisms->organisms[updateorganismcount].category_id = request->organisms[i].
     organism_category_id
     SET tempupdateorganisms->organisms[updateorganismcount].group_resistant_cnt = request->
     organisms[i].group_resistant_cnt
     SET tempupdateorganisms->organisms[updateorganismcount].location_code_value = request->
     organisms[i].organism_location_code_value
     SET tempupdateorganisms->organisms[updateorganismcount].mdro_id = request->organisms[i].
     organism_mdro_id
     SET tempupdateorganisms->organisms[updateorganismcount].organism_code_value = request->
     organisms[i].organism_code_value
     SET tempupdateorganisms->organisms[updateorganismcount].organism_id = organismid
     SET tempupdateorganisms->organisms[updateorganismcount].lookback_time_span_nbr = request->
     organisms[i].lookback_time_span_nbr
     SET tempupdateorganisms->organisms[updateorganismcount].lookback_time_span_unit_cd = request->
     organisms[i].lookback_time_span_unit_cd
    ELSEIF ((request->organisms[i].organism_action_flag=3))
     SET deleteorganismcount = (deleteorganismcount+ 1)
     SET stat = alterlist(tempdeleteorganisms->organisms,deleteorganismcount)
     SET tempdeleteorganisms->organisms[deleteorganismcount].organism_id = organismid
    ENDIF
    CALL populatedruggroups(i,organismid)
  ENDFOR
 ENDIF
 SUBROUTINE populatedruggroups(i,organismid)
  SET druggroupcount = size(request->organisms[i].drug_groups,5)
  FOR (j = 1 TO druggroupcount)
    SET druggroupid = request->organisms[i].drug_groups[j].drug_group_id
    SET druggrouporganismid = 0.0
    IF ((request->organisms[i].drug_groups[j].drug_group_action_flag=1))
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       druggrouporganismid = cnvtreal(temp)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting new drug group organism id.")
     SET adddruggroupcount = (adddruggroupcount+ 1)
     SET stat = alterlist(tempadddruggroup->drug_groups,adddruggroupcount)
     SET tempadddruggroup->drug_groups[adddruggroupcount].drug_group_id = druggroupid
     SET tempadddruggroup->drug_groups[adddruggroupcount].drug_group_organism_id =
     druggrouporganismid
     SET tempadddruggroup->drug_groups[adddruggroupcount].drug_resistant_cnt = request->organisms[i].
     drug_groups[j].drug_resistant_cnt
     SET tempadddruggroup->drug_groups[adddruggroupcount].organism_id = organismid
    ELSE
     SELECT INTO "nl:"
      FROM br_drug_group_organism dgo
      PLAN (dgo
       WHERE dgo.br_drug_group_id=druggroupid
        AND dgo.br_mdro_cat_organism_id=organismid)
      DETAIL
       druggrouporganismid = dgo.br_drug_group_organism_id
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting existing drug group organism id.")
     IF ((request->organisms[i].drug_groups[j].drug_group_action_flag=2))
      SET updatedruggroupcount = (updatedruggroupcount+ 1)
      SET stat = alterlist(tempupdatedruggroup->drug_groups,updatedruggroupcount)
      SET tempupdatedruggroup->drug_groups[updatedruggroupcount].drug_group_id = druggroupid
      SET tempupdatedruggroup->drug_groups[updatedruggroupcount].drug_resistant_cnt = request->
      organisms[i].drug_groups[j].drug_resistant_cnt
      SET tempupdatedruggroup->drug_groups[updatedruggroupcount].organism_id = organismid
      SET tempupdatedruggroup->drug_groups[updatedruggroupcount].drug_group_organism_id =
      druggrouporganismid
     ELSEIF ((request->organisms[i].drug_groups[j].drug_group_action_flag=3))
      SET deletedruggroupcount = (deletedruggroupcount+ 1)
      SET stat = alterlist(tempdeletedruggroup->drug_groups,deletedruggroupcount)
      SET tempdeletedruggroup->drug_groups[deletedruggroupcount].drug_group_organism_id =
      druggrouporganismid
     ENDIF
    ENDIF
    CALL populatedrugresults(i,j,organismid,druggroupid,druggrouporganismid)
  ENDFOR
 END ;Subroutine
 SUBROUTINE populatedrugresults(i,j,organismid,druggroupid,druggrouporganismid)
  SET drugcount = size(request->organisms[i].drug_groups[j].drugs,5)
  FOR (k = 1 TO drugcount)
   SET drugresultcount = size(request->organisms[i].drug_groups[j].drugs[k].results,5)
   FOR (l = 1 TO drugresultcount)
     SET druggroupantibioticid = 0.0
     SET antibiotic_code_value = request->organisms[i].drug_groups[j].drugs[k].drug_code_value
     SELECT INTO "nl:"
      FROM br_drug_group_antibiotic dga
      PLAN (dga
       WHERE dga.antibiotic_cd=antibiotic_code_value
        AND dga.br_drug_group_id=druggroupid)
      DETAIL
       druggroupantibioticid = dga.br_drug_group_antibiotic_id
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting existing drug antibiotic id.")
     IF ((request->organisms[i].drug_groups[j].drugs[k].results[l].result_action_flag=1))
      SET adddrugresultcount = (adddrugresultcount+ 1)
      SET stat = alterlist(tempadddrugresult->drug_results,adddrugresultcount)
      SET tempadddrugresult->drug_results[adddrugresultcount].br_drug_group_antibiotic_id =
      druggroupantibioticid
      SET tempadddrugresult->drug_results[adddrugresultcount].br_drug_group_organism_id =
      druggrouporganismid
      SET tempadddrugresult->drug_results[adddrugresultcount].result_code_value = request->organisms[
      i].drug_groups[j].drugs[k].results[l].result_code_value
     ELSEIF ((request->organisms[i].drug_groups[j].drugs[k].results[l].result_action_flag=3))
      SET deletedrugresultcount = (deletedrugresultcount+ 1)
      SET stat = alterlist(tempdeletedrugresult->drug_results,deletedrugresultcount)
      SET tempdeletedrugresult->drug_results[deletedrugresultcount].br_drug_group_antibiotic_id =
      druggroupantibioticid
      SET tempdeletedrugresult->drug_results[deletedrugresultcount].br_drug_group_organism_id =
      druggrouporganismid
      SET tempdeletedrugresult->drug_results[deletedrugresultcount].result_code_value = request->
      organisms[i].drug_groups[j].drugs[k].results[l].result_code_value
     ENDIF
   ENDFOR
  ENDFOR
 END ;Subroutine
 IF (eventcount > 0)
  FOR (i = 1 TO eventcount)
    SET eventid = request->events[i].event_id
    IF ((request->events[i].event_action_flag=1))
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       eventid = cnvtreal(temp)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting new event id.")
     SET addeventcount = (addeventcount+ 1)
     SET stat = alterlist(tempaddevents->events,addeventcount)
     SET tempaddevents->events[addeventcount].category_id = request->events[i].event_category_id
     SET tempaddevents->events[addeventcount].event_code_value = request->events[i].event_code_value
     SET tempaddevents->events[addeventcount].event_id = eventid
     SET tempaddevents->events[addeventcount].location_code_value = request->events[i].
     event_location_code_value
     SET tempaddevents->events[addeventcount].mdro_id = request->events[i].event_mdro_id
     SET tempaddevents->events[addeventcount].lookback_time_span_nbr = request->events[i].
     lookback_time_span_nbr
     SET tempaddevents->events[addeventcount].lookback_time_span_unit_cd = request->events[i].
     lookback_time_span_unit_cd
    ELSEIF ((request->events[i].event_action_flag=2))
     SET updateeventcount = (updateeventcount+ 1)
     SET stat = alterlist(tempupdateevents->events,updateeventcount)
     SET tempupdateevents->events[updateeventcount].category_id = request->events[i].
     event_category_id
     SET tempupdateevents->events[updateeventcount].event_code_value = request->events[i].
     event_code_value
     SET tempupdateevents->events[updateeventcount].event_id = eventid
     SET tempupdateevents->events[updateeventcount].location_code_value = request->events[i].
     event_location_code_value
     SET tempupdateevents->events[updateeventcount].mdro_id = request->events[i].event_mdro_id
     SET tempupdateevents->events[updateeventcount].lookback_time_span_nbr = request->events[i].
     lookback_time_span_nbr
     SET tempupdateevents->events[updateeventcount].lookback_time_span_unit_cd = request->events[i].
     lookback_time_span_unit_cd
    ELSEIF ((request->events[i].event_action_flag=3))
     SET deleteeventcount = (deleteeventcount+ 1)
     SET stat = alterlist(tempdeleteevents->events,deleteeventcount)
     SET tempdeleteevents->events[deleteeventcount].event_id = eventid
    ENDIF
    CALL populatenormalcycodes(i,eventid)
  ENDFOR
 ENDIF
 SUBROUTINE populatenormalcycodes(i,eventid)
  SET normalcycodescount = size(request->events[i].normalcy_codes,5)
  FOR (j = 1 TO normalcycodescount)
   SET normalcycodevalue = request->events[i].normalcy_codes[j].normalcy_code_value
   IF ((request->events[i].normalcy_codes[j].normalcy_code_action_flag=1))
    SET addnormalcycodecount = (addnormalcycodecount+ 1)
    SET stat = alterlist(tempaddnormalcycodes->normalcy_codes,addnormalcycodecount)
    SET tempaddnormalcycodes->normalcy_codes[addnormalcycodecount].event_id = eventid
    SET tempaddnormalcycodes->normalcy_codes[addnormalcycodecount].normalcy_code_value =
    normalcycodevalue
   ELSEIF ((request->events[i].normalcy_codes[j].normalcy_code_action_flag=3))
    SET deletenormalcycodecount = (deletenormalcycodecount+ 1)
    SET stat = alterlist(tempdeletenormalcycodes->normalcy_codes,deletenormalcycodecount)
    SET tempdeletenormalcycodes->normalcy_codes[deletenormalcycodecount].event_id = eventid
    SET tempdeletenormalcycodes->normalcy_codes[deletenormalcycodecount].normalcy_code_value =
    normalcycodevalue
   ENDIF
  ENDFOR
 END ;Subroutine
 IF (deletedrugresultcount > 0)
  CALL echorecord(tempdeletedrugresult)
  DELETE  FROM br_organism_drug_result odr,
    (dummyt d  WITH seq = deletedrugresultcount)
   SET odr.seq = 1
   PLAN (d)
    JOIN (odr
    WHERE (odr.br_drug_group_antibiotic_id=tempdeletedrugresult->drug_results[d.seq].
    br_drug_group_antibiotic_id)
     AND (odr.br_drug_group_organism_id=tempdeletedrugresult->drug_results[d.seq].
    br_drug_group_organism_id)
     AND (odr.result_cd=tempdeletedrugresult->drug_results[d.seq].result_code_value))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_organism_drug_result.")
 ENDIF
 IF (deletedruggroupcount > 0)
  DELETE  FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = deletedruggroupcount)
   SET dgo.seq = 1
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_drug_group_organism_id=tempdeletedruggroup->drug_groups[d.seq].
    drug_group_organism_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_drug_group_organism.")
 ENDIF
 IF (deleteorganismcount > 0)
  DELETE  FROM br_mdro_cat_organism mco,
    (dummyt d  WITH seq = deleteorganismcount)
   SET mco.seq = 1
   PLAN (d)
    JOIN (mco
    WHERE (mco.br_mdro_cat_organism_id=tempdeleteorganisms->organisms[d.seq].organism_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_mdro_cat_organism.")
 ENDIF
 IF (deletenormalcycodecount > 0)
  DELETE  FROM br_cat_event_normalcy cen,
    (dummyt d  WITH seq = deletenormalcycodecount)
   SET cen.seq = 1
   PLAN (d)
    JOIN (cen
    WHERE (cen.br_mdro_cat_event_id=tempdeletenormalcycodes->normalcy_codes[d.seq].event_id)
     AND (cen.normalcy_cd=tempdeletenormalcycodes->normalcy_codes[d.seq].normalcy_code_value))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_cat_event_normalcy.")
 ENDIF
 IF (deleteeventcount > 0)
  DELETE  FROM br_mdro_cat_event mce,
    (dummyt d  WITH seq = deleteeventcount)
   SET mce.seq = 1
   PLAN (d)
    JOIN (mce
    WHERE (mce.br_mdro_cat_event_id=tempdeleteevents->events[d.seq].event_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_mdro_cat_event.")
 ENDIF
 IF (updatedruggroupcount > 0)
  UPDATE  FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = updatedruggroupcount)
   SET dgo.drug_resistant_cnt = tempupdatedruggroup->drug_groups[d.seq].drug_resistant_cnt, dgo
    .updt_cnt = (dgo.updt_cnt+ 1), dgo.updt_id = reqinfo->updt_id,
    dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_task = reqinfo->updt_task, dgo
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_drug_group_id=tempupdatedruggroup->drug_groups[d.seq].drug_group_id)
     AND (dgo.br_drug_group_organism_id=tempupdatedruggroup->drug_groups[d.seq].
    drug_group_organism_id)
     AND (dgo.br_mdro_cat_organism_id=tempupdatedruggroup->drug_groups[d.seq].organism_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating into br_drug_group_organism.")
 ENDIF
 IF (updateorganismcount > 0)
  UPDATE  FROM br_mdro_cat_organism mco,
    (dummyt d  WITH seq = updateorganismcount)
   SET mco.br_mdro_cat_id = tempupdateorganisms->organisms[d.seq].category_id, mco
    .group_resistant_cnt = tempupdateorganisms->organisms[d.seq].group_resistant_cnt, mco.location_cd
     = tempupdateorganisms->organisms[d.seq].location_code_value,
    mco.br_mdro_id = tempupdateorganisms->organisms[d.seq].mdro_id, mco.antibiotics_txt =
    tempupdateorganisms->organisms[d.seq].antibiotic_text, mco.lookback_time_span_nbr =
    tempupdateorganisms->organisms[d.seq].lookback_time_span_nbr,
    mco.lookback_time_span_unit_cd = tempupdateorganisms->organisms[d.seq].lookback_time_span_unit_cd,
    mco.updt_cnt = (mco.updt_cnt+ 1), mco.updt_id = reqinfo->updt_id,
    mco.updt_dt_tm = cnvtdatetime(curdate,curtime), mco.updt_task = reqinfo->updt_task, mco
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mco
    WHERE (mco.br_mdro_cat_organism_id=tempupdateorganisms->organisms[d.seq].organism_id)
     AND (mco.organism_cd=tempupdateorganisms->organisms[d.seq].organism_code_value))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating into br_mdro_cat_organism.")
 ENDIF
 IF (updateeventcount > 0)
  UPDATE  FROM br_mdro_cat_event mce,
    (dummyt d  WITH seq = updateeventcount)
   SET mce.br_mdro_cat_id = tempupdateevents->events[d.seq].category_id, mce.location_cd =
    tempupdateevents->events[d.seq].location_code_value, mce.br_mdro_id = tempupdateevents->events[d
    .seq].mdro_id,
    mce.lookback_time_span_nbr = tempupdateevents->events[d.seq].lookback_time_span_nbr, mce
    .lookback_time_span_unit_cd = tempupdateevents->events[d.seq].lookback_time_span_unit_cd, mce
    .updt_cnt = (mce.updt_cnt+ 1),
    mce.updt_id = reqinfo->updt_id, mce.updt_dt_tm = cnvtdatetime(curdate,curtime), mce.updt_task =
    reqinfo->updt_task,
    mce.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mce
    WHERE (mce.br_mdro_cat_event_id=tempupdateevents->events[d.seq].event_id)
     AND (mce.event_cd=tempupdateevents->events[d.seq].event_code_value))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating into br_mdro_cat_event.")
 ENDIF
 IF (addorganismcount > 0)
  CALL echorecord(tempaddorganisms)
  INSERT  FROM br_mdro_cat_organism mco,
    (dummyt d  WITH seq = addorganismcount)
   SET mco.br_mdro_cat_id = tempaddorganisms->organisms[d.seq].category_id, mco.group_resistant_cnt
     = tempaddorganisms->organisms[d.seq].group_resistant_cnt, mco.location_cd = tempaddorganisms->
    organisms[d.seq].location_code_value,
    mco.br_mdro_id = tempaddorganisms->organisms[d.seq].mdro_id, mco.organism_cd = tempaddorganisms->
    organisms[d.seq].organism_code_value, mco.br_mdro_cat_organism_id = tempaddorganisms->organisms[d
    .seq].organism_id,
    mco.antibiotics_txt = tempaddorganisms->organisms[d.seq].antibiotic_text, mco
    .lookback_time_span_nbr = tempaddorganisms->organisms[d.seq].lookback_time_span_nbr, mco
    .lookback_time_span_unit_cd = tempaddorganisms->organisms[d.seq].lookback_time_span_unit_cd,
    mco.updt_cnt = 0, mco.updt_id = reqinfo->updt_id, mco.updt_dt_tm = cnvtdatetime(curdate,curtime),
    mco.updt_task = reqinfo->updt_task, mco.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mco)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_mdro_cat_organism.")
 ENDIF
 IF (adddruggroupcount > 0)
  INSERT  FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = adddruggroupcount)
   SET dgo.br_drug_group_id = tempadddruggroup->drug_groups[d.seq].drug_group_id, dgo
    .br_drug_group_organism_id = tempadddruggroup->drug_groups[d.seq].drug_group_organism_id, dgo
    .drug_resistant_cnt = tempadddruggroup->drug_groups[d.seq].drug_resistant_cnt,
    dgo.br_mdro_cat_organism_id = tempadddruggroup->drug_groups[d.seq].organism_id, dgo.updt_cnt = 0,
    dgo.updt_id = reqinfo->updt_id,
    dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_task = reqinfo->updt_task, dgo
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dgo)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_drug_group_organism.")
 ENDIF
 IF (adddrugresultcount > 0)
  INSERT  FROM br_organism_drug_result odr,
    (dummyt d  WITH seq = adddrugresultcount)
   SET odr.br_drug_group_antibiotic_id = tempadddrugresult->drug_results[d.seq].
    br_drug_group_antibiotic_id, odr.br_drug_group_organism_id = tempadddrugresult->drug_results[d
    .seq].br_drug_group_organism_id, odr.br_organism_drug_result_id = cnvtreal(seq(bedrock_seq,
      nextval)),
    odr.result_cd = tempadddrugresult->drug_results[d.seq].result_code_value, odr.updt_cnt = 0, odr
    .updt_id = reqinfo->updt_id,
    odr.updt_dt_tm = cnvtdatetime(curdate,curtime), odr.updt_task = reqinfo->updt_task, odr
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (odr)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_organism_drug_result.")
 ENDIF
 IF (addeventcount > 0)
  INSERT  FROM br_mdro_cat_event mce,
    (dummyt d  WITH seq = addeventcount)
   SET mce.br_mdro_cat_id = tempaddevents->events[d.seq].category_id, mce.event_cd = tempaddevents->
    events[d.seq].event_code_value, mce.br_mdro_cat_event_id = tempaddevents->events[d.seq].event_id,
    mce.location_cd = tempaddevents->events[d.seq].location_code_value, mce.br_mdro_id =
    tempaddevents->events[d.seq].mdro_id, mce.lookback_time_span_nbr = tempaddevents->events[d.seq].
    lookback_time_span_nbr,
    mce.lookback_time_span_unit_cd = tempaddevents->events[d.seq].lookback_time_span_unit_cd, mce
    .updt_cnt = 0, mce.updt_id = reqinfo->updt_id,
    mce.updt_dt_tm = cnvtdatetime(curdate,curtime), mce.updt_task = reqinfo->updt_task, mce
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mce)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_mdro_cat_event.")
 ENDIF
 IF (addnormalcycodecount > 0)
  INSERT  FROM br_cat_event_normalcy cen,
    (dummyt d  WITH seq = addnormalcycodecount)
   SET cen.br_cat_event_normalcy_id = cnvtreal(seq(bedrock_seq,nextval)), cen.br_mdro_cat_event_id =
    tempaddnormalcycodes->normalcy_codes[d.seq].event_id, cen.normalcy_cd = tempaddnormalcycodes->
    normalcy_codes[d.seq].normalcy_code_value,
    cen.updt_cnt = 0, cen.updt_id = reqinfo->updt_id, cen.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cen.updt_task = reqinfo->updt_task, cen.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cen)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_cat_event_normalcy.")
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
 CALL echorecord(reply)
END GO
