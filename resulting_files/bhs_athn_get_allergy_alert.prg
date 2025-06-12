CREATE PROGRAM bhs_athn_get_allergy_alert
 FREE RECORD req3200123
 RECORD req3200123(
   1 person_id = f8
   1 person[*]
     2 person_id = f8
   1 allergy[*]
     2 allergy_id = f8
   1 cancel_ind = i2
 ) WITH protect
 FREE RECORD req680400
 RECORD req680400(
   1 user_criteria
     2 user_id = f8
   1 patient_criteria
     2 patient_id = f8
   1 allergy_drug_checking
     2 allergy_drug_criterias[*]
       3 unique_identifier = vc
       3 subjects[*]
         4 allergy_cki = vc
       3 causes_criteria
         4 retail_interaction_days_ind = i2
         4 retrieve_future_orders_ind = i2
       3 synonym_causes[*]
         4 synonym_id = f8
 ) WITH protect
 FREE RECORD req680204
 RECORD req680204(
   1 orders[*]
     2 order_id = f8
   1 load_indicators
     2 order_indicators
       3 comment_types
         4 load_order_comment_ind = i2
         4 load_administration_note_ind = i2
       3 review_information_criteria
         4 load_review_status_ind = i2
         4 load_renewal_notification_ind = i2
       3 order_set_info_criteria
         4 load_core_ind = i2
         4 load_name_ind = i2
       3 supergroup_info_criteria
         4 load_core_ind = i2
         4 load_components_ind = i2
       3 load_linked_order_info_ind = i2
       3 care_plan_info_criteria
         4 load_core_ind = i2
         4 load_extended_ind = i2
       3 diagnosis_info_criteria
         4 load_core_ind = i2
         4 load_extended_ind = i2
       3 load_encounter_information_ind = i2
       3 load_pending_status_info_ind = i2
       3 load_venue_ind = i2
       3 load_order_schedule_ind = i2
       3 load_order_ingredients_ind = i2
       3 load_last_action_info_ind = i2
       3 load_extended_attributes_ind = i2
       3 load_order_proposal_info_ind = i2
       3 order_relation_criteria
         4 load_core_ind = i2
       3 appointment_criteria
         4 load_core_ind = i2
       3 therapeutic_substitution
         4 load_accepted_ind = i2
       3 accession_criteria
         4 load_core_ind = i2
       3 load_last_populated_action_ind = i2
       3 clinical_intervention_criteria
         4 load_pharmacy_ind = i2
       3 protocol_criteria
         4 load_core_ind = i2
       3 day_of_treatment_criteria
         4 load_extended_ind = i2
       3 load_order_status_reasons_ind = i2
       3 load_referral_information_ind = i2
       3 load_filtered_resp_provider_ind = i2
   1 mnemonic_criteria
     2 load_mnemonic_ind = i2
     2 simple_build_type
       3 reference_ind = i2
       3 reference_clinical_ind = i2
       3 reference_clinical_dept_ind = i2
       3 reference_department_ind = i2
     2 medication_criteria
       3 build_order_level_ind = i2
       3 build_ingredient_level_ind = i2
       3 complex_build_type
         4 reference_ind = i2
         4 clinical_ind = i2
 ) WITH protect
 FREE RECORD req_allergies
 RECORD req_allergies(
   1 qual[*]
     2 allergy_cki = vc
     2 allergy_id = vc
     2 nomenclature_id = vc
 )
 FREE RECORD out_rec
 RECORD out_rec(
   1 qual[*]
     2 audit_uid = vc
     2 allergy_id = vc
     2 alergy_name = vc
     2 allergy_cki = vc
     2 nomenclature_id = vc
     2 order_id = vc
     2 drug_cki = vc
     2 mnemonic = vc
     2 medication = vc
     2 simplified_display_line = vc
     2 clinical_display_line = vc
     2 catalog_cd = vc
     2 catalog_disp = vc
     2 catalog_mean = vc
     2 interaction_text = vc
     2 severity = vc
     2 interaction_type = vc
     2 category = vc
     2 class = vc
 )
 DECLARE readallergies(null) = i4
 DECLARE callperformclinicalchecking(null) = i4
 DECLARE performalertfiltering(null) = i4
 DECLARE getorderdata(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE ocnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE ldx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE alocidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE apos = i4 WITH protect, noconstant(0)
 DECLARE ordercnt = i4 WITH protect, noconstant(0)
 DECLARE allergy_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 IF (size(trim( $4,3)) <= 0)
  SET stat = readallergies(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = callperformclinicalchecking(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = performalertfiltering(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getorderdata(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 EXECUTE bhs_athn_write_json_output
 FREE RECORD req680400
 FREE RECORD rep680400
 FREE RECORD req3200123
 FREE RECORD rep3200123
 FREE RECORD req680204
 FREE RECORD rep680204
 FREE RECORD out_rec
 SUBROUTINE callperformclinicalchecking(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680400)
   DECLARE t_line = vc
   DECLARE t_line2 = vc
   DECLARE done = i2
   DECLARE cnt = i2
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req680400->user_criteria.user_id =  $3
   SET req680400->patient_criteria.patient_id =  $2
   IF (size(trim( $4,3)) > 0)
    SET stat = alterlist(req680400->allergy_drug_checking.allergy_drug_criterias,1)
    SET req680400->allergy_drug_checking.allergy_drug_criterias[1].unique_identifier =
    "INTERACTION_ALLERGYDRUG"
    SET cnt = 0
    SET t_line = trim( $4,3)
    WHILE (done=0)
      IF (findstring(",",t_line)=0)
       SET cnt += 1
       SET stat = alterlist(req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,cnt)
       SET req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[cnt].allergy_cki =
       trim(t_line,3)
       SET done = 1
      ELSE
       SET cnt += 1
       SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
       SET stat = alterlist(req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,cnt)
       SET req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[cnt].allergy_cki =
       trim(t_line2,3)
       SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
      ENDIF
    ENDWHILE
   ENDIF
   CALL echorecord(req680400)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680400,
    "REC",rep680400,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep680400)
   IF ((rep680400->transaction_status.success_ind=1))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE readallergies(null)
   SET req3200123->person_id =  $2
   SET stat = tdbexecute(3200000,3200065,3200123,"REC",req3200123,
    "REC",rep3200123,4)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep3200123)
   IF ((rep3200123->status_data.status="S"))
    SET stat = alterlist(req680400->allergy_drug_checking.allergy_drug_criterias,1)
    SET req680400->allergy_drug_checking.allergy_drug_criterias[1].unique_identifier =
    "INTERACTION_ALLERGYDRUG"
    SET allergy_cnt = 0
    FOR (idx = 1 TO size(rep3200123->person[1].allergy,5))
      IF ((((rep3200123->person[1].allergy[idx].substance_type_mean="DRUG")) OR ((rep3200123->person[
      1].allergy[idx].substance_type_mean="")))
       AND (((rep3200123->person[1].allergy[idx].reaction_status_mean="ACTIVE")) OR ((rep3200123->
      person[1].allergy[idx].reaction_status_mean="PROPOSED")))
       AND size(trim(rep3200123->person[1].allergy[idx].cki,3)) > 0)
       SET allergy_cnt += 1
       SET stat = alterlist(req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,
        allergy_cnt)
       SET req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[allergy_cnt].
       allergy_cki = rep3200123->person[1].allergy[idx].cki
       SET stat = alterlist(req_allergies->qual,allergy_cnt)
       SET req_allergies->qual[allergy_cnt].allergy_id = cnvtstring(rep3200123->person[1].allergy[idx
        ].allergy_id)
       SET req_allergies->qual[allergy_cnt].allergy_cki = rep3200123->person[1].allergy[idx].cki
       SET req_allergies->qual[allergy_cnt].nomenclature_id = cnvtstring(rep3200123->person[1].
        allergy[idx].substance_nom_id)
      ENDIF
    ENDFOR
    IF (size(req680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,5) <= 0)
     RETURN(fail)
    ELSE
     RETURN(success)
    ENDIF
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE performalertfiltering(null)
   IF (size(rep680400->allergy_drug_checking.allergy_drug_criterias,5) > 0
    AND size(rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,5) > 0)
    FOR (jdx = 1 TO size(rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects,5))
      IF (size(rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx].
       allergy_drug_alert.interactions,5) > 0)
       FOR (kdx = 1 TO size(rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx].
        allergy_drug_alert.interactions,5))
         FOR (ldx = 1 TO size(rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx
          ].allergy_drug_alert.interactions[kdx].causing_drug.profile_orders,5))
           SET ocnt += 1
           SET stat = alterlist(out_rec->qual,ocnt)
           SET out_rec->qual[ocnt].order_id = cnvtstring(rep680400->allergy_drug_checking.
            allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug
            .profile_orders[ldx].order_id)
           SET out_rec->qual[ocnt].catalog_cd = cnvtstring(rep680400->allergy_drug_checking.
            allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug
            .profile_orders[ldx].catalog_cd)
           SET out_rec->qual[ocnt].mnemonic = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug.
           drug_name
           SET out_rec->qual[ocnt].drug_cki = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug.
           causing_cki
           SET out_rec->qual[ocnt].category = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug.
           category_name
           SET out_rec->qual[ocnt].class = rep680400->allergy_drug_checking.allergy_drug_criterias[1]
           .subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug.class_name
           SET out_rec->qual[ocnt].audit_uid = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].audit_uid
           SET out_rec->qual[ocnt].interaction_text = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].
           interaction_description
           SET out_rec->qual[ocnt].alergy_name = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].
           subject_allergy.drug_name
           SET out_rec->qual[ocnt].allergy_cki = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_cki
           IF ((rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx].
           allergy_drug_alert.interactions[kdx].interaction_type.drug_ind=1))
            SET out_rec->qual[ocnt].interaction_type = "DRUG"
           ELSEIF ((rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx].
           allergy_drug_alert.interactions[kdx].interaction_type.category_ind=1))
            SET out_rec->qual[ocnt].interaction_type = "CATEGORY"
           ELSEIF ((rep680400->allergy_drug_checking.allergy_drug_criterias[1].subjects[jdx].
           allergy_drug_alert.interactions[kdx].interaction_type.class_ind=1))
            SET out_rec->qual[ocnt].interaction_type = "CLASS"
           ENDIF
           SET apos = locateval(alocidx,1,allergy_cnt,out_rec->qual[ocnt].allergy_cki,req_allergies->
            qual[alocidx].allergy_cki)
           SET out_rec->qual[ocnt].allergy_id = req_allergies->qual[apos].allergy_id
           SET out_rec->qual[ocnt].nomenclature_id = req_allergies->qual[apos].nomenclature_id
           SET stat1 = alterlist(req680204->orders,ocnt)
           SET req680204->orders[ocnt].order_id = rep680400->allergy_drug_checking.
           allergy_drug_criterias[1].subjects[jdx].allergy_drug_alert.interactions[kdx].causing_drug.
           profile_orders[ldx].order_id
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (size(out_rec->qual,5)=0)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getorderdata(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680204)
   IF (size(req680204->orders,5) > 0)
    CALL echorecord(req680204)
    SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680204,
     "REC",rep680204,1)
    IF (stat > 0)
     SET errcode = error(errmsg,1)
     CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
       errmsg))
     RETURN(fail)
    ENDIF
    CALL echorecord(rep680204)
    IF ((rep680204->status_data.status="S"))
     SET ordercnt = size(out_rec->qual,5)
     FOR (idx = 1 TO ordercnt)
       SET pos = locateval(locidx,1,ordercnt,cnvtreal(out_rec->qual[idx].order_id),rep680204->orders[
        locidx].core.order_id)
       SET out_rec->qual[idx].clinical_display_line = rep680204->orders[pos].displays.
       clinical_display_line
       SET out_rec->qual[idx].simplified_display_line = rep680204->orders[pos].displays.
       simplified_display_line
       IF (trim(rep680204->orders[pos].displays.reference_name,3)=trim(rep680204->orders[pos].
        displays.clinical_name,3))
        SET out_rec->qual[idx].medication = rep680204->orders[pos].displays.reference_name
       ELSE
        SET out_rec->qual[idx].medication = concat(rep680204->orders[pos].displays.reference_name,
         " (",rep680204->orders[pos].displays.clinical_name,")")
       ENDIF
     ENDFOR
     RETURN(success)
    ENDIF
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
