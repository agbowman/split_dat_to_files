CREATE PROGRAM bed_copy_mdro_parameters:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
 FREE RECORD get_mdro_params_req
 RECORD get_mdro_params_req(
   1 category_type_ind = i2
   1 mdro_code_value = f8
   1 mdro_type_ind = i2
   1 facility_code_value = f8
 ) WITH protect
 FREE RECORD get_mdro_params_rep
 RECORD get_mdro_params_rep(
   1 mdro_code_value = f8
   1 mdro_display = vc
   1 mdro_description = vc
   1 mdro_type_ind = i2
   1 category_id = f8
   1 category_name = vc
   1 category_type_ind = i2
   1 drug_groups[*]
     2 drg_grp_id = f8
     2 name = vc
     2 drug_resistant_nbr = i4
     2 drugs[*]
       3 drug_code_value = f8
       3 display = vc
       3 description = vc
       3 interp_results[*]
         4 interp_code_value = f8
         4 display = vc
         4 description = vc
   1 group_resistant_nbr = i4
   1 normalcy_codes[*]
     2 normalcy_code_value = f8
     2 display = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 mdro_id = f8
   1 mdro_name_display = vc
   1 antibiotics_text = vc
   1 drug_relation_id = f8
   1 lookback_setting_nbr = i4
   1 lookback_setting_unit
     2 display = vc
     2 lookback_setting_unit_cd = f8
 ) WITH protect
 FREE RECORD ensure_mdro_params_req
 RECORD ensure_mdro_params_req(
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
 ) WITH protect
 FREE RECORD ensure_mdro_params_rep
 RECORD ensure_mdro_params_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE populateorganismsfordeletion(dummyvar=i2) = i2
 DECLARE populateeventsfordeletion(dummyvar=i2) = i2
 DECLARE populateorganismsforcopy(dummyvar=i2) = i2
 DECLARE populateeventsforcopy(dummyvar=i2) = i2
 DECLARE callensuremdroparameters(dummyvar=i2) = i2
 DECLARE organism_count = i4 WITH protect, constant(size(request->to_organism,5))
 DECLARE event_count = i4 WITH protect, constant(size(request->to_events,5))
 DECLARE error = i4 WITH protect, constant(1)
 DECLARE no_error = i4 WITH protect, constant(0)
 DECLARE event_type_ind = i2 WITH protect, constant(1)
 DECLARE organism_type_ind = i2 WITH protect, constant(2)
 DECLARE insert_flag = i2 WITH protect, constant(1)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE index3 = i4 WITH protect, noconstant(0)
 DECLARE index4 = i4 WITH protect, noconstant(0)
 DECLARE index5 = i4 WITH protect, noconstant(0)
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
 IF (validate(request->frm_organism_code_value,0)
  AND (request->frm_organism_code_value > 0.0)
  AND organism_count > 0)
  IF (populateorganismsfordeletion(0)=error)
   CALL bederror("ERROR 001: Error while preparing organisms for deletion.")
  ENDIF
  IF (callensuremdroparameters(0)=error)
   CALL bederror("ERROR 002: Error while deleting organisms.")
  ENDIF
  IF (populateorganismsforcopy(0)=error)
   CALL bederror("ERROR 003: Error while preparing organisms for copy.")
  ENDIF
  IF (callensuremdroparameters(0)=error)
   CALL bederror("ERROR 004: Error while copying organisms.")
  ENDIF
 ENDIF
 IF (validate(request->frm_event_cd,0)
  AND (request->frm_event_cd > 0.0)
  AND event_count > 0)
  IF (populateeventsfordeletion(0)=error)
   CALL bederror("ERROR 005: Error while preparing events for deletion.")
  ENDIF
  IF (callensuremdroparameters(0)=error)
   CALL bederror("ERROR 006: Error while deleting events.")
  ENDIF
  IF (populateeventsforcopy(0)=error)
   CALL bederror("ERROR 007: Error while preparing events for copy.")
  ENDIF
  IF (callensuremdroparameters(0)=error)
   CALL bederror("ERROR 008: Error while copying events.")
  ENDIF
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
 SUBROUTINE populateorganismsfordeletion(dummyvar)
   DECLARE category_count = i4 WITH protect, noconstant(0)
   DECLARE delete_organism_count = i4 WITH protect, noconstant(0)
   DECLARE delete_drug_group_count = i4 WITH protect, noconstant(0)
   DECLARE delete_drug_count = i4 WITH protect, noconstant(0)
   DECLARE delete_results_count = i4 WITH protect, noconstant(0)
   FOR (index1 = 1 TO organism_count)
     SET category_count = 0
     FREE RECORD org_cat
     RECORD org_cat(
       1 categories[*]
         2 br_mdro_cat_organism_id = f8
     ) WITH protect
     SELECT INTO "nl:"
      FROM br_mdro_cat_organism cat_org
      PLAN (cat_org
       WHERE (cat_org.organism_cd=request->to_organism[index1].organism_code_value)
        AND (cat_org.location_cd=request->frm_location_code_value))
      ORDER BY cat_org.br_mdro_cat_organism_id
      DETAIL
       category_count = (category_count+ 1), stat = alterlist(org_cat->categories,category_count),
       org_cat->categories[category_count].br_mdro_cat_organism_id = cat_org.br_mdro_cat_organism_id
      WITH counter
     ;end select
     FOR (index2 = 1 TO category_count)
       SET get_mdro_params_req->category_type_ind = request->category_type_ind
       SET get_mdro_params_req->mdro_code_value = org_cat->categories[index2].br_mdro_cat_organism_id
       SET get_mdro_params_req->mdro_type_ind = organism_type_ind
       SET get_mdro_params_req->facility_code_value = request->frm_location_code_value
       EXECUTE bed_get_mdro_parameters  WITH replace("REQUEST",get_mdro_params_req), replace("REPLY",
        get_mdro_params_rep)
       IF (cnvtupper(cnvtstring(get_mdro_params_rep->status_data.status))="F")
        RETURN(error)
       ENDIF
       SET delete_organism_count = (delete_organism_count+ 1)
       SET stat = alterlist(ensure_mdro_params_req->organisms,delete_organism_count)
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_action_flag =
       delete_flag
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_id = org_cat->
       categories[index2].br_mdro_cat_organism_id
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_category_id =
       get_mdro_params_rep->category_id
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_code_value = request->
       to_organism[index1].organism_code_value
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_location_code_value =
       request->frm_location_code_value
       SET ensure_mdro_params_req->organisms[delete_organism_count].organism_mdro_id =
       get_mdro_params_rep->mdro_id
       SET ensure_mdro_params_req->organisms[delete_organism_count].group_resistant_cnt =
       get_mdro_params_rep->group_resistant_nbr
       SET ensure_mdro_params_req->organisms[delete_organism_count].antibiotics_text =
       get_mdro_params_rep->antibiotics_text
       SET ensure_mdro_params_req->organisms[delete_organism_count].lookback_time_span_nbr =
       get_mdro_params_rep->lookback_setting_nbr
       SET ensure_mdro_params_req->organisms[delete_organism_count].lookback_time_span_unit_cd =
       get_mdro_params_rep->lookback_setting_unit.lookback_setting_unit_cd
       SET delete_drug_group_count = 0
       FOR (index3 = 1 TO size(get_mdro_params_rep->drug_groups,5))
         SET delete_drug_group_count = (delete_drug_group_count+ 1)
         SET stat = alterlist(ensure_mdro_params_req->organisms[delete_organism_count].drug_groups,
          delete_drug_group_count)
         SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
         delete_drug_group_count].drug_group_action_flag = delete_flag
         SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
         delete_drug_group_count].drug_group_id = get_mdro_params_rep->drug_groups[index3].drg_grp_id
         SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
         delete_drug_group_count].drug_resistant_cnt = get_mdro_params_rep->drug_groups[index3].
         drug_resistant_nbr
         SET delete_drug_count = 0
         FOR (index4 = 1 TO size(get_mdro_params_rep->drug_groups[index3].drugs,5))
           SET delete_drug_count = (delete_drug_count+ 1)
           SET stat = alterlist(ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
            delete_drug_group_count].drugs,delete_drug_count)
           SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
           delete_drug_group_count].drugs[delete_drug_count].drug_code_value = get_mdro_params_rep->
           drug_groups[index3].drugs[index4].drug_code_value
           SET delete_results_count = 0
           FOR (index5 = 1 TO size(get_mdro_params_rep->drug_groups[index3].drugs[index4].
            interp_results,5))
             SET delete_results_count = (delete_results_count+ 1)
             SET stat = alterlist(ensure_mdro_params_req->organisms[delete_organism_count].
              drug_groups[delete_drug_group_count].drugs[delete_drug_count].results,
              delete_results_count)
             SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
             delete_drug_group_count].drugs[delete_drug_count].results[delete_results_count].
             result_action_flag = delete_flag
             SET ensure_mdro_params_req->organisms[delete_organism_count].drug_groups[
             delete_drug_group_count].drugs[delete_drug_count].results[delete_results_count].
             result_code_value = get_mdro_params_rep->drug_groups[index3].drugs[index4].
             interp_results[index5].interp_code_value
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   RETURN(no_error)
 END ;Subroutine
 SUBROUTINE populateeventsfordeletion(dummyvar)
   DECLARE category_count = i4 WITH protect, noconstant(0)
   DECLARE delete_event_count = i4 WITH protect, noconstant(0)
   DECLARE delete_normalcy_count = i4 WITH protect, noconstant(0)
   FOR (index1 = 1 TO event_count)
     SET category_count = 0
     FREE RECORD event_cat
     RECORD event_cat(
       1 categories[*]
         2 br_mdro_cat_event_id = f8
     ) WITH protect
     SELECT INTO "nl:"
      FROM br_mdro_cat_event event_cat
      PLAN (event_cat
       WHERE (event_cat.event_cd=request->to_events[index1].event_cd)
        AND (event_cat.location_cd=request->frm_location_code_value))
      ORDER BY event_cat.br_mdro_cat_event_id
      DETAIL
       category_count = (category_count+ 1), stat = alterlist(event_cat->categories,category_count),
       event_cat->categories[category_count].br_mdro_cat_event_id = event_cat.br_mdro_cat_event_id
      WITH counter
     ;end select
     IF (category_count > 0)
      FOR (index2 = 1 TO category_count)
        SET get_mdro_params_req->category_type_ind = request->category_type_ind
        SET get_mdro_params_req->mdro_code_value = event_cat->categories[index2].br_mdro_cat_event_id
        SET get_mdro_params_req->mdro_type_ind = event_type_ind
        SET get_mdro_params_req->facility_code_value = request->frm_location_code_value
        EXECUTE bed_get_mdro_parameters  WITH replace("REQUEST",get_mdro_params_req), replace("REPLY",
         get_mdro_params_rep)
        IF (cnvtupper(cnvtstring(get_mdro_params_rep->status_data.status))="F")
         RETURN(error)
        ENDIF
        SET delete_event_count = (delete_event_count+ 1)
        SET stat = alterlist(ensure_mdro_params_req->events,delete_event_count)
        SET ensure_mdro_params_req->events[delete_event_count].event_action_flag = delete_flag
        SET ensure_mdro_params_req->events[delete_event_count].event_id = event_cat->categories[
        index2].br_mdro_cat_event_id
        SET ensure_mdro_params_req->events[delete_event_count].event_category_id =
        get_mdro_params_rep->category_id
        SET ensure_mdro_params_req->events[delete_event_count].event_code_value = request->to_events[
        index1].event_cd
        SET ensure_mdro_params_req->events[delete_event_count].event_location_code_value = request->
        frm_location_code_value
        SET ensure_mdro_params_req->events[delete_event_count].event_mdro_id = get_mdro_params_rep->
        mdro_id
        SET ensure_mdro_params_req->events[delete_event_count].lookback_time_span_nbr =
        get_mdro_params_rep->lookback_setting_nbr
        SET ensure_mdro_params_req->events[delete_event_count].lookback_time_span_unit_cd =
        get_mdro_params_rep->lookback_setting_unit.lookback_setting_unit_cd
        SET delete_normalcy_count = 0
        FOR (index3 = 1 TO size(get_mdro_params_rep->normalcy_codes,5))
          SET delete_normalcy_count = (delete_normalcy_count+ 1)
          SET stat = alterlist(ensure_mdro_params_req->events[delete_event_count].normalcy_codes,
           delete_normalcy_count)
          SET ensure_mdro_params_req->events[delete_event_count].normalcy_codes[delete_normalcy_count
          ].normalcy_code_action_flag = delete_flag
          SET ensure_mdro_params_req->events[delete_event_count].normalcy_codes[delete_normalcy_count
          ].normalcy_code_value = get_mdro_params_rep->normalcy_codes[index3].normalcy_code_value
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(no_error)
 END ;Subroutine
 SUBROUTINE populateorganismsforcopy(dummyvar)
   DECLARE category_count = i4 WITH protect, noconstant(0)
   DECLARE new_organism_count = i4 WITH protect, noconstant(0)
   DECLARE new_drug_group_count = i4 WITH protect, noconstant(0)
   DECLARE new_drug_count = i4 WITH protect, noconstant(0)
   DECLARE new_results_count = i4 WITH protect, noconstant(0)
   FREE RECORD org_cat
   RECORD org_cat(
     1 categories[*]
       2 br_mdro_cat_organism_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_mdro_cat_organism cat_org
    PLAN (cat_org
     WHERE (cat_org.organism_cd=request->frm_organism_code_value)
      AND (cat_org.location_cd=request->frm_location_code_value))
    ORDER BY cat_org.br_mdro_cat_organism_id
    DETAIL
     category_count = (category_count+ 1), stat = alterlist(org_cat->categories,category_count),
     org_cat->categories[category_count].br_mdro_cat_organism_id = cat_org.br_mdro_cat_organism_id
    WITH counter
   ;end select
   IF (category_count > 0)
    FOR (index1 = 1 TO category_count)
      SET get_mdro_params_req->category_type_ind = request->category_type_ind
      SET get_mdro_params_req->mdro_code_value = org_cat->categories[index1].br_mdro_cat_organism_id
      SET get_mdro_params_req->mdro_type_ind = organism_type_ind
      SET get_mdro_params_req->facility_code_value = request->frm_location_code_value
      EXECUTE bed_get_mdro_parameters  WITH replace("REQUEST",get_mdro_params_req), replace("REPLY",
       get_mdro_params_rep)
      IF (cnvtupper(cnvtstring(get_mdro_params_rep->status_data.status))="F")
       RETURN(error)
      ENDIF
      FOR (index2 = 1 TO organism_count)
        SET new_organism_count = (new_organism_count+ 1)
        SET stat = alterlist(ensure_mdro_params_req->organisms,new_organism_count)
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_action_flag = insert_flag
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_id = 0.0
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_category_id =
        get_mdro_params_rep->category_id
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_code_value = request->
        to_organism[index2].organism_code_value
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_location_code_value =
        request->frm_location_code_value
        SET ensure_mdro_params_req->organisms[new_organism_count].organism_mdro_id =
        get_mdro_params_rep->mdro_id
        SET ensure_mdro_params_req->organisms[new_organism_count].group_resistant_cnt =
        get_mdro_params_rep->group_resistant_nbr
        SET ensure_mdro_params_req->organisms[new_organism_count].antibiotics_text =
        get_mdro_params_rep->antibiotics_text
        SET ensure_mdro_params_req->organisms[new_organism_count].lookback_time_span_nbr =
        get_mdro_params_rep->lookback_setting_nbr
        SET ensure_mdro_params_req->organisms[new_organism_count].lookback_time_span_unit_cd =
        get_mdro_params_rep->lookback_setting_unit.lookback_setting_unit_cd
        SET new_drug_group_count = 0
        FOR (index3 = 1 TO size(get_mdro_params_rep->drug_groups,5))
          SET new_drug_group_count = (new_drug_group_count+ 1)
          SET stat = alterlist(ensure_mdro_params_req->organisms[new_organism_count].drug_groups,
           new_drug_group_count)
          SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[new_drug_group_count]
          .drug_group_action_flag = insert_flag
          SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[new_drug_group_count]
          .drug_group_id = get_mdro_params_rep->drug_groups[index3].drg_grp_id
          SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[new_drug_group_count]
          .drug_resistant_cnt = get_mdro_params_rep->drug_groups[index3].drug_resistant_nbr
          SET new_drug_count = 0
          FOR (index4 = 1 TO size(get_mdro_params_rep->drug_groups[index3].drugs,5))
            SET new_drug_count = (new_drug_count+ 1)
            SET stat = alterlist(ensure_mdro_params_req->organisms[new_organism_count].drug_groups[
             new_drug_group_count].drugs,new_drug_count)
            SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[
            new_drug_group_count].drugs[new_drug_count].drug_code_value = get_mdro_params_rep->
            drug_groups[index3].drugs[index4].drug_code_value
            SET new_results_count = 0
            FOR (index5 = 1 TO size(get_mdro_params_rep->drug_groups[index3].drugs[index4].
             interp_results,5))
              SET new_results_count = (new_results_count+ 1)
              SET stat = alterlist(ensure_mdro_params_req->organisms[new_organism_count].drug_groups[
               new_drug_group_count].drugs[new_drug_count].results,new_results_count)
              SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[
              new_drug_group_count].drugs[new_drug_count].results[new_results_count].
              result_action_flag = insert_flag
              SET ensure_mdro_params_req->organisms[new_organism_count].drug_groups[
              new_drug_group_count].drugs[new_drug_count].results[new_results_count].
              result_code_value = get_mdro_params_rep->drug_groups[index3].drugs[index4].
              interp_results[index5].interp_code_value
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   RETURN(no_error)
 END ;Subroutine
 SUBROUTINE populateeventsforcopy(dummyvar)
   DECLARE category_count = i4 WITH protect, noconstant(0)
   DECLARE new_event_count = i4 WITH protect, noconstant(0)
   DECLARE new_normalcy_count = i4 WITH protect, noconstant(0)
   FREE RECORD event_cat
   RECORD event_cat(
     1 categories[*]
       2 br_mdro_cat_event_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_mdro_cat_event event_cat
    PLAN (event_cat
     WHERE (event_cat.event_cd=request->frm_event_cd)
      AND (event_cat.location_cd=request->frm_location_code_value))
    ORDER BY event_cat.br_mdro_cat_event_id
    DETAIL
     category_count = (category_count+ 1), stat = alterlist(event_cat->categories,category_count),
     event_cat->categories[category_count].br_mdro_cat_event_id = event_cat.br_mdro_cat_event_id
    WITH counter
   ;end select
   IF (category_count > 0)
    FOR (index1 = 1 TO category_count)
      SET get_mdro_params_req->category_type_ind = request->category_type_ind
      SET get_mdro_params_req->mdro_code_value = event_cat->categories[index1].br_mdro_cat_event_id
      SET get_mdro_params_req->mdro_type_ind = event_type_ind
      SET get_mdro_params_req->facility_code_value = request->frm_location_code_value
      EXECUTE bed_get_mdro_parameters  WITH replace("REQUEST",get_mdro_params_req), replace("REPLY",
       get_mdro_params_rep)
      IF (cnvtupper(cnvtstring(get_mdro_params_rep->status_data.status))="F")
       RETURN(error)
      ENDIF
      FOR (index2 = 1 TO event_count)
        SET new_event_count = (new_event_count+ 1)
        SET stat = alterlist(ensure_mdro_params_req->events,new_event_count)
        SET ensure_mdro_params_req->events[new_event_count].event_action_flag = insert_flag
        SET ensure_mdro_params_req->events[new_event_count].event_id = 0.0
        SET ensure_mdro_params_req->events[new_event_count].event_category_id = get_mdro_params_rep->
        category_id
        SET ensure_mdro_params_req->events[new_event_count].event_code_value = request->to_events[
        index2].event_cd
        SET ensure_mdro_params_req->events[new_event_count].event_location_code_value = request->
        frm_location_code_value
        SET ensure_mdro_params_req->events[new_event_count].event_mdro_id = get_mdro_params_rep->
        mdro_id
        SET ensure_mdro_params_req->events[new_event_count].lookback_time_span_nbr =
        get_mdro_params_rep->lookback_setting_nbr
        SET ensure_mdro_params_req->events[new_event_count].lookback_time_span_unit_cd =
        get_mdro_params_rep->lookback_setting_unit.lookback_setting_unit_cd
        SET new_normalcy_count = 0
        FOR (index3 = 1 TO size(get_mdro_params_rep->normalcy_codes,5))
          SET new_normalcy_count = (new_normalcy_count+ 1)
          SET stat = alterlist(ensure_mdro_params_req->events[new_event_count].normalcy_codes,
           new_normalcy_count)
          SET ensure_mdro_params_req->events[new_event_count].normalcy_codes[new_normalcy_count].
          normalcy_code_action_flag = insert_flag
          SET ensure_mdro_params_req->events[new_event_count].normalcy_codes[new_normalcy_count].
          normalcy_code_value = get_mdro_params_rep->normalcy_codes[index3].normalcy_code_value
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   RETURN(no_error)
 END ;Subroutine
 SUBROUTINE callensuremdroparameters(dummyvar)
  IF (((size(ensure_mdro_params_req->organisms,5) > 0) OR (size(ensure_mdro_params_req->events,5) > 0
  )) )
   EXECUTE bed_ens_mdro_params  WITH replace("REQUEST",ensure_mdro_params_req), replace("REPLY",
    ensure_mdro_params_rep)
   IF (cnvtupper(cnvtstring(ensure_mdro_params_rep->status_data.status))="F")
    RETURN(error)
   ENDIF
  ENDIF
  RETURN(no_error)
 END ;Subroutine
END GO
