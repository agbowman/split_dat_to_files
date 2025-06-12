CREATE PROGRAM dcp_auto_close_pregnancy:dba
 SET modify = predeclare
 FREE RECORD pregs
 RECORD pregs(
   1 qual[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 problem_id = f8
     2 onset_dt_tm = dq8
     2 life_cycle_status_cd = f8
     2 classification_cd = f8
     2 preg_start_dt_tm = dq8
     2 delivered_ind = i2
     2 org_id = f8
     2 encntr_id = f8
 )
 FREE RECORD deliveredpregs
 RECORD deliveredpregs(
   1 qual[*]
     2 person_id = f8
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 problem_id = f8
     2 onset_dt_tm = dq8
     2 life_cycle_status_cd = f8
     2 classification_cd = f8
     2 preg_start_dt_tm = dq8
     2 delivered_overdue_ind = i2
     2 org_id = f8
     2 encntr_id = f8
 )
 FREE RECORD replystruct
 RECORD replystruct(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD docsetstruct
 RECORD docsetstruct(
   1 label_list[*]
     2 dynamic_label_id = f8
     2 label_name = vc
     2 result_set_id = f8
     2 delivery_dt_tm = dq8
     2 pregnancy_outcome_dt_tm = dq8
     2 delivery_type = vc
     2 pregnancy_outcome = vc
     2 delivery_dt_tm_latest = dq8
     2 pregnancy_outcome_dt_tm_latest = dq8
     2 delivery_type_latest = dq8
     2 pregnancy_outcome_latest = dq8
     2 neonate_outcome = vc
     2 gestation_age_at_delivery = i4
     2 abortion_type = vc
   1 label_template_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD eventsets
 RECORD eventsets(
   1 event_set_list[*]
     2 event_set_name = vc
     2 event_cd = f8
     2 event_set_value = vc
     2 updated_ind = i2
 )
 RECORD eventsetsreply(
   1 concepts[*]
     2 concept_cki = vc
     2 event_sets[*]
       3 event_set_cd = f8
       3 event_set_cd_disp = vc
       3 event_set_name = vc
       3 event_codes[*]
         4 event_cd = f8
         4 event_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD egarequest
 RECORD egarequest(
   1 provider_id = f8
   1 position_cd = f8
   1 cal_ega_multiple_gest = i2
   1 patient_list[*]
     2 patient_id = f8
     2 encntr_id = f8
   1 provider_list[*]
     2 patient_id = f8
     2 encntr_id = f8
     2 provider_patient_reltn_cd = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
   1 multiple_egas = i2
 )
 FREE RECORD egareply
 RECORD egareply(
   1 gestation_info[*]
     2 person_id = f8
     2 encntr_id = f8
     2 pregnancy_id = f8
     2 est_gest_age = i4
     2 current_gest_age = i4
     2 est_delivery_date = dq8
     2 edd_id = f8
     2 gest_age_at_delivery = i4
     2 delivery_date = dq8
     2 delivery_date_tz = i4
     2 delivered_ind = i2
     2 org_id = f8
     2 est_delivery_tz = i4
     2 partial_delivery_ind = i2
     2 multiple_gest_ind = i2
     2 latest_delivery_date = dq8
     2 dynamic_label[*]
       3 label_name = vc
       3 gest_age_at_delivery = i4
       3 delivery_date = dq8
       3 delivery_date_tz = i4
       3 dynamic_label_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD phxensurerequest
 RECORD phxensurerequest(
   1 person_id = f8
   1 prsnl_id = f8
   1 gravida_cnt = i4
   1 para_full_term_cnt = i4
   1 para_premature_cnt = i4
   1 para_abortion_cnt = i4
   1 para_living_cnt = i4
   1 live_child_comment = vc
   1 pregnancies[*]
     2 pregnancy_id = f8
     2 org_id = f8
     2 encntr_id = f8
     2 ensure_type = i2
     2 pregnancy_instance_id = f8
     2 problem_id = f8
     2 sensitive_ind = i2
     2 preg_start_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 override_comment = vc
     2 confirmation_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 pregnancy_entities[*]
       3 pregnancy_entity_id = f8
       3 delete_flag = i2
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 component_type_cd = f8
     2 pregnancy_actions[*]
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_type_cd = f8
       3 prsnl_id = f8
     2 pregnancy_children[*]
       3 pregnancy_child_id = f8
       3 delete_flag = i2
       3 gender_cd = f8
       3 updt_dt_tm = dq8
       3 child_name = vc
       3 person_id = f8
       3 father_name = vc
       3 delivery_method_cd = f8
       3 delivery_hospital = vc
       3 gestation_age = i4
       3 labor_duration = i4
       3 weight_amt = f8
       3 weight_unit_cd = f8
       3 anesthesia_txt = vc
       3 preterm_labor_txt = vc
       3 delivery_dt_tm = dq8
       3 delivery_tz = i4
       3 neonate_outcome_cd = f8
       3 child_comment = vc
       3 child_entities[*]
         4 pregnancy_child_entity_id = f8
         4 delete_flag = i2
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 component_type_cd = f8
         4 entity_text = vc
       3 delivery_date_precision_flag = i2
       3 delivery_date_qualifier_flag = i2
       3 gestation_term_txt = vc
   1 classification_cd = f8
   1 nomen_source_id = vc
   1 nomen_vocab_mean = c12
   1 problem_id = f8
 )
 FREE RECORD deldateeventcds
 RECORD deldateeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD pregoutcomeeventcds
 RECORD pregoutcomeeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD pregnancyoutcomeeventcds
 RECORD pregnancyoutcomeeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD pregnancyoutcomedateeventcds
 RECORD pregnancyoutcomedateeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD abortiontypeeventcds
 RECORD abortiontypeeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD neooutcomeeventcds
 RECORD neooutcomeeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD now_dt_tm
 RECORD now_dt_tm(
   1 dt_tm = dq8
 )
 FREE RECORD deliverydateeventcds
 RECORD deliverydateeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 FREE RECORD pregoutcomedateeventcds
 RECORD pregoutcomedateeventcds(
   1 eventcodes[*]
     2 eventcode = f8
 )
 DECLARE getpregnancypreferences(null) = null
 DECLARE getoverduepregnancies(null) = null
 DECLARE closeundeliveredpregnancies(null) = null
 DECLARE inactivatepregnancylabels(null) = null WITH protect
 DECLARE getallactivepregs(null) = null
 DECLARE getdeliveredoverduepregnancies(null) = null
 DECLARE geteventsetsbyconcept(null) = null
 DECLARE retrievegravidaparadetails(null) = null WITH protect
 DECLARE closedeliveredoverduepregnancies(null) = null WITH protect
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE failureind = i2 WITH protect, noconstant(1)
 DECLARE zeroind = i2 WITH protect, noconstant(0)
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE istat = i4 WITH protect, noconstant(0)
 DECLARE nomenclatureid = f8 WITH protect, noconstant(0.0)
 DECLARE earliestpregnancydt = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100"))
 DECLARE snomenvocabmean = vc WITH protect, noconstant("")
 DECLARE snomensourceid = vc WITH protect, noconstant("")
 DECLARE iautocloseweeks = i4 WITH protect, noconstant(0)
 DECLARE igestationweeks = i4 WITH protect, noconstant(40)
 DECLARE sdocsetname = vc WITH protect, noconstant("")
 DECLARE gpapplicationnum = i4 WITH protect, constant(1000071)
 DECLARE gptasknum = i4 WITH protect, constant(1000071)
 DECLARE gprequestnum = i4 WITH protect, constant(1000071)
 DECLARE eventensurereq = i4 WITH protect, constant(600345)
 DECLARE eventensureapp = i4 WITH protect, constant(600005)
 DECLARE eventensuretask = i4 WITH protect, constant(600108)
 DECLARE person_id = f8 WITH protect, noconstant(0)
 DECLARE livebirthcnt = i4 WITH protect, noconstant(0)
 DECLARE ectopiccnt = i4 WITH protect, noconstant(0)
 DECLARE spontabortioncnt = i4 WITH protect, noconstant(0)
 DECLARE inducedabortioncnt = i4 WITH protect, noconstant(0)
 DECLARE abortioncnt = i4 WITH protect, noconstant(0)
 DECLARE parafulltermcnt = i4 WITH protect, noconstant(0)
 DECLARE parapretermcnt = i4 WITH protect, noconstant(0)
 DECLARE multiplebirthscnt = i4 WITH protect, noconstant(0)
 DECLARE zerodeliveredind = i2 WITH protect, noconstant(0)
 DECLARE pregnancytypecki = vc WITH protect, noconstant("")
 DECLARE neonateoutcomecki = vc WITH protect, noconstant("")
 DECLARE latestresultdt = dq8 WITH protect, noconstant(0)
 DECLARE gestageatdelivery = i4 WITH protect, noconstant(0)
 DECLARE abortiontypecki = vc WITH protect, noconstant("")
 DECLARE abortiontypenomenid = f8 WITH protect, noconstant(0)
 DECLARE sabortion = vc WITH protect, noconstant("")
 DECLARE sectopic = vc WITH protect, noconstant("")
 DECLARE sfullterm = vc WITH protect, noconstant("")
 DECLARE sgravida = vc WITH protect, noconstant("")
 DECLARE sindabortion = vc WITH protect, noconstant("")
 DECLARE sliving = vc WITH protect, noconstant("")
 DECLARE smultbirths = vc WITH protect, noconstant("")
 DECLARE spara = vc WITH protect, noconstant("")
 DECLARE spremature = vc WITH protect, noconstant("")
 DECLARE sspontabortion = vc WITH protect, noconstant("")
 DECLARE sdocreportname = vc WITH protect, noconstant("")
 DECLARE sdocreporttitle = vc WITH protect, noconstant("")
 DECLARE sdoceventsetname = vc WITH protect, noconstant("")
 DECLARE sdoceventsetcd = f8 WITH protect, noconstant(0)
 DECLARE iautoclsdelvrywks = i4 WITH protect, noconstant(0)
 DECLARE iaddpregincgp = i4 WITH protect, noconstant(0)
 DECLARE iclosepregincpara = i4 WITH protect, noconstant(0)
 DECLARE leventsetsidx = i4 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE iret = i4 WITH protect, noconstant(0)
 DECLARE ensuredeventid = f8 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE expcnt = i4 WITH protect, noconstant(0)
 DECLARE loccnt = i4 WITH protect, noconstant(0)
 DECLARE eventcdstotal = i4 WITH protect, noconstant(0)
 DECLARE eventsetscnt = i4 WITH protect, noconstant(0)
 DECLARE eventcdscnt = i4 WITH protect, noconstant(0)
 DECLARE sdocprefset = i2 WITH protect, noconstant(1)
 DECLARE sdocgenerated = i2 WITH protect, noconstant(0)
 DECLARE eventcodescnt = i4 WITH protect, noconstant(0)
 DECLARE perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE action_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE result_format_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14113,"NUMERIC"))
 DECLARE contributor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE event_class_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE event_class_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE event_class_txt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"TXT"))
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE storage_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE format_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE succession_type_cd = f8 WITH constant(uar_get_code_by("MEANING",63,"INTERIM"))
 DECLARE auto_close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,
   "AUTOCLOSE"))
 DECLARE unknown_delivery_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002119,"UNKNOWN")
  )
 DECLARE component_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002108,"RELATEDDOC"
   ))
 DECLARE comp_label_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002108,
   "FETALLABEL"))
 DECLARE no_qualifier = i2 WITH protect, constant(0)
 DECLARE no_precision = i2 WITH protect, constant(3)
 DECLARE day_precision = i2 WITH protect, constant(0)
 DECLARE close_ensure_type = i2 WITH protect, constant(4)
 DECLARE delivery_dt_concept_cki = vc WITH protect, constant("CERNER!ASYr9AEYvUr1YoPTCqIGfQ")
 DECLARE delivery_type_concept_cki = vc WITH protect, constant(
  "CERNER!0B07155E-2E5C-461F-ADE6-CB5768257107")
 DECLARE pregnancy_outcome_dt_tm_concept_cki = vc WITH protect, constant(
  "CERNER!F7246032-54B7-4CCD-AEEF-ADB09BBEF603")
 DECLARE pregnancy_outcome_concept_cki = vc WITH protect, constant(
  "CERNER!5449FC28-EABC-41DF-8EAE-ED1B9341C9E9")
 DECLARE neonate_outcome_concept_cki = vc WITH protect, constant("CERNER!ASYr9AEYvUr1YoRACqIGfQ")
 DECLARE abortion_concept_cki = vc WITH protect, constant(
  "CERNER!FE3F722E-C57A-4136-A6C7-77FD13DFAED1")
 DECLARE abortion_type_concept_cki = vc WITH protect, constant(
  "CERNER!71788347-9148-47A2-ADBB-86CD9A2C6446")
 DECLARE spontaneousabortion_cki = vc WITH protect, constant(
  "CERNER!864A4421-DF41-45E1-A62C-256A3E1D957C")
 DECLARE spontaneousabortionwithdc_cki = vc WITH protect, constant(
  "CERNER!E3CA0090-D779-4859-B458-643E635A71E5")
 DECLARE medicationinducedabortion_cki = vc WITH protect, constant(
  "CERNER!65AA25D2-0AA6-4C5B-A216-DE66AF09E279")
 DECLARE surgicallyinducedabortion_cki = vc WITH protect, constant(
  "CERNER!820982F1-53AC-4C99-86D7-C4B6F06BF047")
 DECLARE therapeuticabortionmedical_cki = vc WITH protect, constant(
  "CERNER!9B84450F-5A19-4D37-86CF-E9946874EE6B")
 DECLARE therapeuticabortionsurgical_cki = vc WITH protect, constant(
  "CERNER!D3F8E433-B5A6-454F-95C1-0A71B3F20C01")
 DECLARE ectopiclaparotomy_cki = vc WITH protect, constant(
  "CERNER!B6B11264-FFF8-4597-A6ED-CEA89274E500")
 DECLARE ectopic_cki = vc WITH protect, constant("CERNER!C0562576-4A20-4FDB-A5AB-64D066EF34F2")
 DECLARE ectopicmedicalmanagement_cki = vc WITH protect, constant(
  "CERNER!9AADA7B7-F276-425D-AB1A-7C3B22FBB555")
 DECLARE livebirth_cki = vc WITH protect, constant("CERNER!ASYr9AEYvUr1YoRYCqIGfQ")
 DECLARE encntr_id_column_exists = i2 WITH public, noconstant(0)
 IF (checkdic("PREGNANCY_INSTANCE.ENCNTR_ID","A",0) > 1)
  SET encntr_id_column_exists = 1
 ENDIF
 SET replystruct->status_data.status = "F"
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   SET debugind = 1
  ENDIF
 ENDIF
 CALL getpregnancypreferences(null)
 SET stat = alterlist(eventsets->event_set_list,10)
 SET eventsets->event_set_list[1].event_set_name = sgravida
 SET eventsets->event_set_list[2].event_set_name = sectopic
 SET eventsets->event_set_list[3].event_set_name = sfullterm
 SET eventsets->event_set_list[4].event_set_name = sabortion
 SET eventsets->event_set_list[5].event_set_name = sindabortion
 SET eventsets->event_set_list[6].event_set_name = sliving
 SET eventsets->event_set_list[7].event_set_name = smultbirths
 SET eventsets->event_set_list[8].event_set_name = spara
 SET eventsets->event_set_list[9].event_set_name = spremature
 SET eventsets->event_set_list[10].event_set_name = sspontabortion
 DECLARE gpeventsetscnt = i4 WITH protect, constant(size(eventsets->event_set_list,5))
 SELECT INTO "nl:"
  FROM v500_event_code vec
  WHERE expand(expcnt,1,gpeventsetscnt,vec.event_cd_disp,eventsets->event_set_list[expcnt].
   event_set_name)
   AND vec.code_status_cd=active_status_cd
  DETAIL
   idx = locateval(loccnt,1,gpeventsetscnt,vec.event_cd_disp,eventsets->event_set_list[loccnt].
    event_set_name)
   IF (idx > 0)
    eventsets->event_set_list[idx].event_cd = vec.event_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_code vec
  WHERE vec.event_cd_disp=sdoceventsetname
  DETAIL
   sdoceventsetcd = vec.event_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_explode es
  WHERE cv.concept_cki=delivery_dt_concept_cki
   AND es.event_set_cd=cv.code_value
  DETAIL
   eventcodescnt += 1, stat = alterlist(deliverydateeventcds->eventcodes,eventcodescnt),
   deliverydateeventcds->eventcodes[eventcodescnt].eventcode = es.event_cd
  WITH nocounter
 ;end select
 SET eventcodescnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_explode es
  WHERE cv.concept_cki=pregnancy_outcome_dt_tm_concept_cki
   AND es.event_set_cd=cv.code_value
  DETAIL
   eventcodescnt += 1, stat = alterlist(pregoutcomedateeventcds->eventcodes,eventcodescnt),
   pregoutcomedateeventcds->eventcodes[eventcodescnt].eventcode = es.event_cd
  WITH nocounter
 ;end select
 IF (iautoclsdelvrywks > 0)
  CALL getallactivepregs(null)
  CALL getdeliveredoverduepregnancies(null)
  CALL geteventsetsbyconcept(null)
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[1].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[1].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(deldateeventcds->eventcodes,eventcdstotal)
     SET deldateeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->concepts[1].
     event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[2].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[2].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(pregoutcomeeventcds->eventcodes,eventcdstotal)
     SET pregoutcomeeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->concepts[2].
     event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[3].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[3].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(neooutcomeeventcds->eventcodes,eventcdstotal)
     SET neooutcomeeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->concepts[3].
     event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[4].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[4].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(pregnancyoutcomeeventcds->eventcodes,eventcdstotal)
     SET pregnancyoutcomeeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->concepts[4].
     event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[5].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[5].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(pregnancyoutcomedateeventcds->eventcodes,eventcdstotal)
     SET pregnancyoutcomedateeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->
     concepts[5].event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  SET eventcdstotal = 0
  SET eventsetscnt = size(eventsetsreply->concepts[6].event_sets,5)
  FOR (idx = 1 TO eventsetscnt)
   SET eventcdscnt = size(eventsetsreply->concepts[6].event_sets[idx].event_codes,5)
   FOR (eventcdidx = 1 TO eventcdscnt)
     SET eventcdstotal += 1
     SET stat = alterlist(abortiontypeeventcds->eventcodes,eventcdstotal)
     SET abortiontypeeventcds->eventcodes[eventcdstotal].eventcode = eventsetsreply->concepts[6].
     event_sets[idx].event_codes[eventcdidx].event_cd
   ENDFOR
  ENDFOR
  CALL closedeliveredoverduepregnancies(null)
 ENDIF
 CALL getoverduepregnancies(null)
 CALL checkfordelivery(null)
 CALL closeundeliveredpregnancies(null)
 SUBROUTINE getpregnancypreferences(null)
   FREE RECORD prefs
   RECORD prefs(
     1 qual[*]
       2 pref_entry_name = vc
   )
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE llocateindex = i4 WITH protect, noconstant(0)
   DECLARE ltermindex = i4 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE hrepgroup = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hattr = i4 WITH private, noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE lentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryidx = i4 WITH private, noconstant(0)
   DECLARE larraysize = i4 WITH private, noconstant(0)
   DECLARE ilen = i4 WITH private, noconstant(255)
   DECLARE lattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattridx = i4 WITH private, noconstant(0)
   DECLARE lvalcnt = i4 WITH private, noconstant(0)
   DECLARE sentryname = c255 WITH private, noconstant("")
   DECLARE sattrname = c255 WITH private, noconstant("")
   DECLARE sval = c255 WITH private, noconstant("")
   DECLARE hsubgroup = i4 WITH private, noconstant(0)
   DECLARE entrycnt = i4 WITH private, noconstant(0)
   DECLARE idxentry = i4 WITH private, noconstant(0)
   DECLARE idxval = i4 WITH private, noconstant(0)
   SET stat = alterlist(prefs->qual,18)
   SET prefs->qual[1].pref_entry_name = "vocabmeaning"
   SET prefs->qual[2].pref_entry_name = "sourceid"
   SET prefs->qual[3].pref_entry_name = "auto_close_pregnancy"
   SET prefs->qual[4].pref_entry_name = "gestational period"
   SET prefs->qual[5].pref_entry_name = "fetus dynamic label docsets"
   SET prefs->qual[6].pref_entry_name = "abortion"
   SET prefs->qual[7].pref_entry_name = "ectopic"
   SET prefs->qual[8].pref_entry_name = "fullterm"
   SET prefs->qual[9].pref_entry_name = "gravida"
   SET prefs->qual[10].pref_entry_name = "induced abortions"
   SET prefs->qual[11].pref_entry_name = "living"
   SET prefs->qual[12].pref_entry_name = "multiple births"
   SET prefs->qual[13].pref_entry_name = "para"
   SET prefs->qual[14].pref_entry_name = "premature"
   SET prefs->qual[15].pref_entry_name = "spontaneous abortions"
   SET prefs->qual[16].pref_entry_name = "auto_close_pregnancy_postdelivery"
   SET prefs->qual[17].pref_entry_name = "gravida para count add pregnancy"
   SET prefs->qual[18].pref_entry_name = "gravida para count close pregnancy"
   SET larraysize = size(prefs->qual,5)
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   SET stat = uar_prefsetsection(hpref,nullterm("component"))
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,nullterm("Pregnancy"))
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm("component"))
   SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm("Pregnancy"))
   SET stat = uar_prefgetgroupentrycount(hrepgroup,lentrycnt)
   FOR (lentryidx = 0 TO (lentrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,lentryidx)
     SET ilen = 255
     SET sentryname = ""
     SET stat = uar_prefgetentryname(hentry,sentryname,ilen)
     SET ltermindex = locateval(llocateindex,1,larraysize,trim(sentryname),prefs->qual[llocateindex].
      pref_entry_name)
     IF (ltermindex > 0)
      SET lattrcnt = 0
      SET stat = uar_prefgetentryattrcount(hentry,lattrcnt)
      FOR (lattridx = 0 TO (lattrcnt - 1))
        SET hattr = uar_prefgetentryattr(hentry,lattridx)
        SET ilen = 255
        SET sattrname = ""
        SET stat = uar_prefgetattrname(hattr,sattrname,ilen)
        IF (sattrname="prefvalue")
         SET lvalcnt = 0
         SET stat = uar_prefgetattrvalcount(hattr,lvalcnt)
         IF (lvalcnt > 0)
          SET sval = ""
          SET ilen = 255
          SET stat = uar_prefgetattrval(hattr,sval,ilen,0)
          IF (debugind=1)
           CALL echo(build2(concat("entry: ",trim(sentryname),"  value: ",trim(sval))))
          ENDIF
          CASE (ltermindex)
           OF 1:
            SET snomenvocabmean = trim(sval)
           OF 2:
            SET snomensourceid = trim(sval)
           OF 3:
            SET iautocloseweeks = cnvtint(trim(sval))
           OF 4:
            SET igestationweeks = cnvtint(trim(sval))
           OF 5:
            SET sdocsetname = trim(sval)
           OF 6:
            SET sabortion = trim(sval)
           OF 7:
            SET sectopic = trim(sval)
           OF 8:
            SET sfullterm = trim(sval)
           OF 9:
            SET sgravida = trim(sval)
           OF 10:
            SET sindabortion = trim(sval)
           OF 11:
            SET sliving = trim(sval)
           OF 12:
            SET smultbirths = trim(sval)
           OF 13:
            SET spara = trim(sval)
           OF 14:
            SET spremature = trim(sval)
           OF 15:
            SET sspontabortion = trim(sval)
           OF 16:
            SET iautoclsdelvrywks = cnvtint(trim(sval))
           OF 17:
            SET iaddpregincgp = cnvtint(trim(sval))
           OF 18:
            SET iclosepregincpara = cnvtint(trim(sval))
          ENDCASE
         ENDIF
         SET lattridx = lattrcnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (((snomenvocabmean="") OR (((snomensourceid="") OR (((iautocloseweeks <= 0) OR (igestationweeks
    <= 0)) )) )) )
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","GetPregnancyPreferences",
     "Prefs are not defined properly")
    GO TO exit_script
   ENDIF
   IF (debugind=1)
    CALL echo(build2("Closing all pregnancies with onset or EGA greater than ",iautocloseweeks,
      " weeks	or delivery date time documented and it crossed ",iautoclsdelvrywks," weeks"))
   ENDIF
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   FREE RECORD prefs
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   SET stat = uar_prefsetsection(hpref,nullterm("component"))
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,nullterm("Pregnancy"))
   SET stat = uar_prefaddsubgroup(hgroup,nullterm("summary document"))
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET idxentry = 0
   SET entrycnt = 0
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm("component"))
   SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm("Pregnancy"))
   SET hsubgroup = uar_prefgetsubgroup(hrepgroup,0)
   SET stat = uar_prefgetgroupentrycount(hsubgroup,entrycnt)
   FOR (idxentry = 0 TO (entrycnt - 1))
     SET lattrcnt = 0
     SET lattridx = 0
     SET ilen = 255
     SET sentryname = ""
     SET hentry = uar_prefgetgroupentry(hsubgroup,idxentry)
     SET stat = uar_prefgetentryname(hentry,sentryname,ilen)
     SET stat = uar_prefgetentryattrcount(hentry,lattrcnt)
     FOR (lattridx = 0 TO (lattrcnt - 1))
       SET idxval = 0
       SET sattrname = ""
       SET lvalcnt = 0
       SET ilen = 255
       SET hattr = uar_prefgetentryattr(hentry,lattridx)
       SET stat = uar_prefgetattrname(hattr,sattrname,ilen)
       SET stat = uar_prefgetattrvalcount(hattr,lvalcnt)
       FOR (idxval = 0 TO (lvalcnt - 1))
         SET sval = ""
         SET ilen = 255
         SET stat = uar_prefgetattrval(hattr,sval,ilen,idxval)
         IF (validate(debug_ind,0) >= 2)
          CALL echo(build(concat("pref entry: ",trim(sentryname),", pref value: ",trim(sval))))
         ENDIF
         IF (trim(sentryname)="summary document report name")
          SET sdocreportname = trim(sval)
         ENDIF
         IF (trim(sentryname)="summary document title")
          SET sdocreporttitle = trim(sval)
         ENDIF
         IF (trim(sentryname)="summary document eventset name")
          SET sdoceventsetname = trim(sval)
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   IF (((sdocreportname="") OR (((sdocreporttitle="") OR (sdoceventsetname="")) )) )
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","GetPregnancyPreferences",
     "Summary document prefs are not defined properly")
    SET sdocprefset = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE getallactivepregs(null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pregnancy_instance pi,
     problem p
    PLAN (pi
     WHERE pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
      AND pi.active_ind=1
      AND pi.historical_ind=0
      AND pi.problem_id > 0)
     JOIN (p
     WHERE p.problem_id=pi.problem_id
      AND p.active_ind=1)
    ORDER BY pi.pregnancy_id
    HEAD pi.pregnancy_id
     cnt += 1
     IF (mod(cnt,10)=1)
      istat = alterlist(deliveredpregs->qual,(cnt+ 9))
     ENDIF
     deliveredpregs->qual[cnt].person_id = pi.person_id, deliveredpregs->qual[cnt].pregnancy_id = pi
     .pregnancy_id, deliveredpregs->qual[cnt].pregnancy_instance_id = pi.pregnancy_instance_id,
     deliveredpregs->qual[cnt].problem_id = p.problem_id, deliveredpregs->qual[cnt].
     life_cycle_status_cd = p.life_cycle_status_cd, deliveredpregs->qual[cnt].classification_cd = p
     .classification_cd,
     deliveredpregs->qual[cnt].onset_dt_tm = p.onset_dt_tm, deliveredpregs->qual[cnt].
     preg_start_dt_tm = pi.preg_start_dt_tm, deliveredpregs->qual[cnt].org_id = pi.organization_id
     IF (encntr_id_column_exists=1)
      deliveredpregs->qual[cnt].encntr_id = pi.encntr_id
     ENDIF
     IF (cnvtdatetime(p.onset_dt_tm) < cnvtdatetime(earliestpregnancydt))
      earliestpregnancydt = p.onset_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (size(deliveredpregs->qual,5) <= 0)
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","Z","GetAllActivePregnancies",
     "No active Pregnancies to close")
    SET zeroind = 1
    SET failureind = 0
    GO TO exit_script
   ENDIF
   SET failureind = 0
   SET istat = alterlist(deliveredpregs->qual,cnt)
   IF (debugind=1)
    CALL echorecord(deliveredpregs)
   ENDIF
 END ;Subroutine
 SUBROUTINE getdeliveredoverduepregnancies(null)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(20)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(20)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE pregnancycnt = i4 WITH public, noconstant(size(deliveredpregs->qual,5))
   DECLARE preg_idx = i4 WITH public, noconstant(0)
   DECLARE temp_preg_idx = i4 WITH public, noconstant(0)
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   DECLARE postdeliverydays = i4 WITH protect, constant((iautoclsdelvrywks * 7))
   DECLARE deliverycutoffdate = dq8 WITH protect, constant(cnvtlookbehind(build(postdeliverydays,",D"
      ),now))
   DECLARE eventcdcnt = i4 WITH protect, noconstant(0)
   DECLARE eventcdcntpregnancy = i4 WITH protect, noconstant(0)
   SET expand_total = (ceil((cnvtreal(pregnancycnt)/ expand_size)) * expand_size)
   SET istat = alterlist(deliveredpregs->qual,expand_total)
   FOR (idx = (pregnancycnt+ 1) TO expand_total)
     SET deliveredpregs->qual[idx].person_id = deliveredpregs->qual[pregnancycnt].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_date_result dr,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (ce
     WHERE expand(num,expand_start,expand_stop,ce.person_id,deliveredpregs->qual[num].person_id)
      AND ((expand(eventcdcnt,1,size(deliverydateeventcds->eventcodes,5),ce.event_cd,
      deliverydateeventcds->eventcodes[eventcdcnt].eventcode)) OR (expand(eventcdcntpregnancy,1,size(
       pregoutcomedateeventcds->eventcodes,5),ce.event_cd,pregoutcomedateeventcds->eventcodes[
      eventcdcntpregnancy].eventcode)))
      AND ce.ce_dynamic_label_id > 0.0
      AND ce.event_cd > 0.0
      AND ce.event_end_dt_tm >= cnvtdatetime(earliestpregnancydt)
      AND ce.publish_flag=1
      AND ce.view_level >= 1
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
      AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd))
     JOIN (dr
     WHERE dr.event_id=ce.event_id
      AND dr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
      AND dr.date_type_flag=0)
    ORDER BY ce.person_id, ce.event_end_dt_tm DESC
    HEAD ce.person_id
     temp_preg_idx = locateval(num,1,pregnancycnt,ce.person_id,deliveredpregs->qual[num].person_id)
     IF (temp_preg_idx > 0
      AND cnvtdatetime(dr.result_dt_tm) >= cnvtdatetime(deliveredpregs->qual[temp_preg_idx].
      onset_dt_tm)
      AND dr.result_dt_tm < deliverycutoffdate)
      deliveredpregs->qual[temp_preg_idx].delivered_overdue_ind = 1
      IF (debugind=1)
       CALL echo(build2("Person id: ",deliveredpregs->qual[temp_preg_idx].person_id,
        " has a qualifying pregnancy with delivery date documented.")),
       CALL echo(build("delivery date = ",cnvtdatetime(dr.result_dt_tm)))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET istat = alterlist(deliveredpregs->qual,pregnancycnt)
   SET preg_idx = locateval(num,1,pregnancycnt,1,deliveredpregs->qual[num].delivered_overdue_ind)
   IF (preg_idx <= 0)
    SET zerodeliveredind = 1
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","Z","GetDeliveredOverduePregnancies",
     "No Pregnancies to close with delivery date documented")
   ENDIF
   IF (debugind=1)
    CALL echorecord(deliveredpregs)
   ENDIF
 END ;Subroutine
 SUBROUTINE geteventsetsbyconcept(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   RECORD eventsetsrequest(
     1 concepts[*]
       2 concept_cki = vc
     1 event_code_ind = i2
     1 retrieve_all_prim_children = i2
   )
   SET lstat = alterlist(eventsetsrequest->concepts,6)
   SET eventsetsrequest->concepts[1].concept_cki = delivery_dt_concept_cki
   SET eventsetsrequest->concepts[2].concept_cki = delivery_type_concept_cki
   SET eventsetsrequest->concepts[3].concept_cki = neonate_outcome_concept_cki
   SET eventsetsrequest->concepts[4].concept_cki = pregnancy_outcome_concept_cki
   SET eventsetsrequest->concepts[5].concept_cki = pregnancy_outcome_dt_tm_concept_cki
   SET eventsetsrequest->concepts[6].concept_cki = abortion_type_concept_cki
   SET eventsetsrequest->event_code_ind = 1
   SET eventsetsrequest->retrieve_all_prim_children = 0
   EXECUTE dcp_get_event_sets_by_concept  WITH replace("REQUEST",eventsetsrequest), replace("REPLY",
    eventsetsreply)
   IF ((eventsetsreply->status_data.status="F"))
    CALL echo("[FAIL]: dcp_get_event_sets_by_concept failed")
    SET replystruct->status_data.status = "F"
    GO TO script_end
   ELSEIF ((eventsetsreply->status_data.status="Z"))
    CALL echo("[ZERO]: No event sets retrieved for Concept CKI")
    SET replystruct->status_data.status = "Z"
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE closedeliveredoverduepregnancies(null)
   DECLARE pregcnt = i4 WITH protect, noconstant(size(deliveredpregs->qual,5))
   DECLARE successcnt = i4 WITH protect, noconstant(0)
   DECLARE pregidx = i4 WITH protect, noconstant(0)
   DECLARE reqfieldscharted = i2 WITH protect, noconstant(0)
   DECLARE failstatus = vc WITH protect, noconstant("")
   DECLARE neonateoutcomecd = f8 WITH protect, noconstant(0)
   DECLARE pregnancytypecd = f8 WITH protect, noconstant(0)
   DECLARE onlyabortionflag = i2 WITH protect, noconstant(0)
   DECLARE abortiontypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002124,
     "ABORTIONTYPE"))
   SET phxensurerequest->nomen_source_id = snomensourceid
   SET phxensurerequest->nomen_vocab_mean = snomenvocabmean
   FOR (pregidx = 1 TO pregcnt)
    SET stat = alterlist(phxensurerequest->pregnancies,0)
    IF ((deliveredpregs->qual[pregidx].delivered_overdue_ind=1))
     SET ectopiccnt = 0
     SET spontabortioncnt = 0
     SET inducedabortioncnt = 0
     SET abortioncnt = 0
     SET livebirthcnt = 0
     SET sdocgenerated = 0
     SET parapretermcnt = 0
     SET parafulltermcnt = 0
     SET multiplebirthscnt = 0
     SET reqfieldscharted = 0
     FOR (leventsetsidx = 1 TO gpeventsetscnt)
      SET eventsets->event_set_list[leventsetsidx].event_set_value = ""
      SET eventsets->event_set_list[leventsetsidx].updated_ind = 0
     ENDFOR
     SET person_id = deliveredpregs->qual[pregidx].person_id
     SET stat = alterlist(docsetstruct->label_list,0)
     CALL getlabelidsbydocsetref(person_id)
     SET lbabycnt = size(docsetstruct->label_list,5)
     IF (lbabycnt > 0)
      IF (sdocprefset=1)
       SET sdocgenerated = generatesummarydocument(person_id)
      ENDIF
      IF (((sdocprefset=0) OR (sdocprefset=1
       AND sdocgenerated=1)) )
       SET lstat = alterlist(egarequest->patient_list,1)
       SET egarequest->patient_list[1].patient_id = person_id
       EXECUTE dcp_get_final_ega  WITH replace("REQUEST",egarequest), replace("REPLY",egareply)
       SET gestageatdelivery = egareply->gestation_info[1].gest_age_at_delivery
       FOR (babyidx = 1 TO lbabycnt)
         SET latestresultdt = deliveredpregs->qual[pregidx].onset_dt_tm
         CALL populatelabelreply(person_id,babyidx,docsetstruct->label_list[babyidx].dynamic_label_id
          )
         IF ((docsetstruct->label_list[babyidx].neonate_outcome != "")
          AND (((docsetstruct->label_list[babyidx].delivery_type != "")) OR ((docsetstruct->
         label_list[babyidx].pregnancy_outcome != "")))
          AND gestageatdelivery > 0)
          SET reqfieldscharted = 1
         ENDIF
       ENDFOR
       SET phxensurerequest->person_id = deliveredpregs->qual[pregidx].person_id
       SET phxensurerequest->problem_id = deliveredpregs->qual[pregidx].problem_id
       SET phxensurerequest->prsnl_id = reqinfo->updt_id
       SET phxensurerequest->classification_cd = deliveredpregs->qual[pregidx].classification_cd
       SET istat = alterlist(phxensurerequest->pregnancies,1)
       SET phxensurerequest->pregnancies[1].pregnancy_id = deliveredpregs->qual[pregidx].pregnancy_id
       SET phxensurerequest->pregnancies[1].pregnancy_instance_id = deliveredpregs->qual[pregidx].
       pregnancy_instance_id
       SET phxensurerequest->pregnancies[1].ensure_type = close_ensure_type
       SET phxensurerequest->pregnancies[1].problem_id = deliveredpregs->qual[pregidx].problem_id
       SET phxensurerequest->pregnancies[1].sensitive_ind = 0
       SET phxensurerequest->pregnancies[1].preg_start_dt_tm = deliveredpregs->qual[pregidx].
       preg_start_dt_tm
       SET phxensurerequest->pregnancies[1].preg_end_dt_tm = cnvtdatetime(sysdate)
       SET phxensurerequest->pregnancies[1].org_id = deliveredpregs->qual[pregidx].org_id
       SET phxensurerequest->pregnancies[1].encntr_id = deliveredpregs->qual[pregidx].encntr_id
       SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_actions,lbabycnt)
       FOR (babyindex = 1 TO lbabycnt)
         SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].action_tz = curtimezonesys
         SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].action_type_cd =
         auto_close_action_cd
         SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].prsnl_id = reqinfo->
         updt_id
       ENDFOR
       SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_children,lbabycnt)
       FOR (babyindex = 1 TO lbabycnt)
         SET neonateoutcomecd = 0
         SET pregnancytypecd = 0
         SET neonateoutcomecki = ""
         SET pregnancytypecki = ""
         SET abortiontypecki = ""
         SET abortiontypenomenid = 0
         SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].pregnancy_child_id = 0
         IF (cnvtdatetime(docsetstruct->label_list[babyindex].delivery_dt_tm_latest) >= cnvtdatetime(
          docsetstruct->label_list[babyindex].pregnancy_outcome_dt_tm_latest))
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_dt_tm =
          docsetstruct->label_list[babyindex].delivery_dt_tm
         ELSE
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_dt_tm =
          docsetstruct->label_list[babyindex].pregnancy_outcome_dt_tm
         ENDIF
         IF ((((docsetstruct->label_list[babyindex].delivery_type != "")) OR ((docsetstruct->
         label_list[babyindex].pregnancy_outcome != "")))
          AND (docsetstruct->label_list[babyindex].neonate_outcome != ""))
          SELECT INTO "nl:"
           FROM nomenclature n,
            code_value c
           PLAN (n
            WHERE n.source_string_keycap=cnvtupper(docsetstruct->label_list[babyindex].
             neonate_outcome))
            JOIN (c
            WHERE c.concept_cki=n.concept_cki
             AND c.code_set=4002121)
           DETAIL
            neonateoutcomecki = n.concept_cki, neonateoutcomecd = c.code_value
           WITH nocounter
          ;end select
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].neonate_outcome_cd =
          neonateoutcomecd
          IF (cnvtdatetime(docsetstruct->label_list[babyindex].delivery_type_latest) >= cnvtdatetime(
           docsetstruct->label_list[babyindex].pregnancy_outcome_latest))
           SELECT INTO "nl:"
            FROM nomenclature n,
             code_value c
            PLAN (n
             WHERE n.source_string_keycap=cnvtupper(docsetstruct->label_list[babyindex].delivery_type
              ))
             JOIN (c
             WHERE c.concept_cki=n.concept_cki
              AND c.code_set=4002119)
            DETAIL
             pregnancytypecki = n.concept_cki, pregnancytypecd = c.code_value
            WITH nocounter
           ;end select
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_method_cd =
           pregnancytypecd
          ELSE
           SELECT INTO "nl:"
            FROM nomenclature n,
             code_value c
            PLAN (n
             WHERE n.source_string_keycap=cnvtupper(docsetstruct->label_list[babyindex].
              pregnancy_outcome))
             JOIN (c
             WHERE c.concept_cki=n.concept_cki
              AND c.code_set=4002119)
            DETAIL
             pregnancytypecki = n.concept_cki, pregnancytypecd = c.code_value
            WITH nocounter
           ;end select
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_method_cd =
           pregnancytypecd
          ENDIF
          IF (reqfieldscharted=1
           AND iclosepregincpara=1)
           SELECT
           ;end select
           CASE (pregnancytypecki)
            OF ectopic_cki:
            OF ectopiclaparotomy_cki:
            OF ectopicmedicalmanagement_cki:
             SET ectopiccnt += 1
            OF spontaneousabortion_cki:
            OF spontaneousabortionwithdc_cki:
             SET spontabortioncnt += 1
            OF therapeuticabortionmedical_cki:
            OF therapeuticabortionsurgical_cki:
             SET inducedabortioncnt += 1
            OF abortion_concept_cki:
             SET onlyabortionflag = 1
             SELECT INTO "nl:"
              FROM nomenclature n
              PLAN (n
               WHERE n.source_string_keycap=cnvtupper(docsetstruct->label_list[babyindex].
                abortion_type)
                AND n.concept_cki IN (medicationinducedabortion_cki, surgicallyinducedabortion_cki,
               therapeuticabortionmedical_cki, therapeuticabortionsurgical_cki,
               spontaneousabortion_cki,
               spontaneousabortionwithdc_cki))
              DETAIL
               abortiontypecki = n.concept_cki, abortiontypenomenid = n.nomenclature_id
              WITH nocounter
             ;end select
             SELECT
             ;end select
             CASE (abortiontypecki)
              OF medicationinducedabortion_cki:
              OF surgicallyinducedabortion_cki:
              OF therapeuticabortionmedical_cki:
              OF therapeuticabortionsurgical_cki:
               SET inducedabortioncnt += 1
               SET onlyabortionflag = 0
              OF spontaneousabortion_cki:
              OF spontaneousabortionwithdc_cki:
               SET spontabortioncnt += 1
               SET onlyabortionflag = 0
             ENDCASE
           ENDCASE
           IF (((ectopiccnt > 0) OR (((spontabortioncnt > 0) OR (((inducedabortioncnt > 0) OR (
           onlyabortionflag=1)) )) )) )
            SET abortioncnt = 1
           ENDIF
           IF (neonateoutcomecki=livebirth_cki)
            SET livebirthcnt += 1
           ENDIF
          ENDIF
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].gestation_age =
          gestageatdelivery
          IF (abortiontypenomenid > 0
           AND onlyabortionflag=0)
           SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_children[babyindex].
            child_entities,1)
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].child_entities[1].
           component_type_cd = abortiontypecd
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].child_entities[1].
           delete_flag = 0
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].child_entities[1].
           pregnancy_child_entity_id = 0
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].child_entities[1].
           parent_entity_id = abortiontypenomenid
           SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].child_entities[1].
           parent_entity_name = "NOMENCLATURE"
          ENDIF
         ELSE
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_method_cd =
          unknown_delivery_cd
         ENDIF
         SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].
         delivery_date_precision_flag = day_precision
         SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].
         delivery_date_qualifier_flag = no_qualifier
         SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].labor_duration = - (1)
       ENDFOR
       SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_entities,lbabycnt)
       FOR (babyindex = 1 TO lbabycnt)
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].pregnancy_entity_id = 0
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].delete_flag = 0
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_id =
         docsetstruct->label_list[babyindex].dynamic_label_id
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_name =
         "CE_DYNAMIC_LABEL"
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].component_type_cd =
         comp_label_type_cd
       ENDFOR
       IF (ensuredeventid != 0)
        SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_entities,(size(
          phxensurerequest->pregnancies[1].pregnancy_entities,5)+ 1))
        SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].pregnancy_entity_id = 0
        SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].delete_flag = 0
        SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_id =
        ensuredeventid
        SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_name =
        "CLINICAL_EVENT"
        SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].component_type_cd =
        component_type_cd
       ENDIF
       SET modify = nopredeclare
       EXECUTE dcp_ens_phx  WITH replace("REQUEST",phxensurerequest), replace("REPLY",phxensurereply)
       IF (lbabycnt > 0)
        CALL inactivatepregnancylabels(null)
       ENDIF
       SET modify = predeclare
       IF ((phxensurereply->status_data.status="S"))
        SET successcnt += 1
        COMMIT
        IF (((reqfieldscharted=1
         AND iclosepregincpara=1) OR (iaddpregincgp != 1)) )
         CALL retrievegravidaparadetails(person_id)
         IF (iaddpregincgp != 1)
          SET eventsets->event_set_list[1].event_set_value = cnvtstring((cnvtint(eventsets->
            event_set_list[1].event_set_value)+ 1))
          SET eventsets->event_set_list[1].updated_ind = 1
         ENDIF
         IF (reqfieldscharted=1
          AND iclosepregincpara=1)
          IF (lbabycnt > 1)
           SET multiplebirthscnt = 1
          ENDIF
          IF (gestageatdelivery >= 259)
           SET parafulltermcnt = 1
          ELSE
           SET parapretermcnt = 1
          ENDIF
          CALL updategravidaparadetails(null)
         ENDIF
         CALL insertgravidaparacntstodb(person_id)
        ENDIF
       ELSE
        CALL copysubeventstatustoreply(phxensurereply)
        SET failureind = 1
        SET failstatus = build2("Pregnancy id: ",deliveredpregs->qual[pregidx].pregnancy_id,
         " was not closed.")
        CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","CloseUndeliveredPregnancies",
         failstatus)
        ROLLBACK
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (populatelabelreply(person_id=f8,llabelidx=i4,label_id=f8) =null WITH protect)
   DECLARE eventcdscnt = i4 WITH private, noconstant(size(deldateeventcds->eventcodes,5))
   DECLARE templatestresultdt = dq8 WITH private, constant(latestresultdt)
   SELECT
    ce.event_cd
    FROM clinical_event ce,
     ce_date_result cdr
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND ce.event_id=cdr.event_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,deldateeventcds->eventcodes[expcnt].eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].delivery_dt_tm_latest =
      latestresultdt, docsetstruct->label_list[llabelidx].delivery_dt_tm = cdr.result_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   SET eventcdscnt = size(pregnancyoutcomedateeventcds->eventcodes,5)
   SET latestresultdt = templatestresultdt
   SELECT
    ce.event_cd
    FROM clinical_event ce,
     ce_date_result cdr
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND ce.event_id=cdr.event_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,pregnancyoutcomedateeventcds->eventcodes[expcnt].
     eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].
      pregnancy_outcome_dt_tm_latest = latestresultdt, docsetstruct->label_list[llabelidx].
      pregnancy_outcome_dt_tm = cdr.result_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   SET eventcdscnt = size(pregoutcomeeventcds->eventcodes,5)
   SET latestresultdt = templatestresultdt
   SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,pregoutcomeeventcds->eventcodes[expcnt].eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].delivery_type_latest =
      latestresultdt, docsetstruct->label_list[llabelidx].delivery_type = ce.result_val
     ENDIF
    WITH nocounter
   ;end select
   SET eventcdscnt = size(pregnancyoutcomeeventcds->eventcodes,5)
   SET latestresultdt = templatestresultdt
   SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,pregnancyoutcomeeventcds->eventcodes[expcnt].
     eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].pregnancy_outcome_latest =
      latestresultdt, docsetstruct->label_list[llabelidx].pregnancy_outcome = ce.result_val
     ENDIF
    WITH nocounter
   ;end select
   SET eventcdscnt = size(neooutcomeeventcds->eventcodes,5)
   SET latestresultdt = templatestresultdt
   SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,neooutcomeeventcds->eventcodes[expcnt].eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].neonate_outcome = ce
      .result_val
     ENDIF
    WITH nocounter
   ;end select
   SET eventcdscnt = size(abortiontypeeventcds->eventcodes,5)
   SET latestresultdt = templatestresultdt
   SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=person_id
     AND ce.ce_dynamic_label_id=label_id
     AND expand(expcnt,1,eventcdscnt,ce.event_cd,abortiontypeeventcds->eventcodes[expcnt].eventcode)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     IF (cnvtdatetime(latestresultdt) < cnvtdatetime(ce.updt_dt_tm))
      latestresultdt = ce.updt_dt_tm, docsetstruct->label_list[llabelidx].abortion_type = ce
      .result_val
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (updategravidaparadetails(null=f8) =null)
   IF (ectopiccnt > 0)
    SET eventsets->event_set_list[2].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      2].event_set_value)+ ectopiccnt))
    SET eventsets->event_set_list[2].updated_ind = 1
   ENDIF
   IF (parafulltermcnt > 0)
    SET eventsets->event_set_list[3].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      3].event_set_value)+ parafulltermcnt))
    SET eventsets->event_set_list[3].updated_ind = 1
   ENDIF
   IF (abortioncnt > 0)
    SET eventsets->event_set_list[4].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      4].event_set_value)+ abortioncnt))
    SET eventsets->event_set_list[4].updated_ind = 1
   ENDIF
   IF (inducedabortioncnt > 0)
    SET eventsets->event_set_list[5].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      5].event_set_value)+ inducedabortioncnt))
    SET eventsets->event_set_list[5].updated_ind = 1
   ENDIF
   IF (livebirthcnt > 0)
    SET eventsets->event_set_list[6].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      6].event_set_value)+ livebirthcnt))
    SET eventsets->event_set_list[6].updated_ind = 1
   ENDIF
   IF (multiplebirthscnt > 0)
    SET eventsets->event_set_list[7].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      7].event_set_value)+ multiplebirthscnt))
    SET eventsets->event_set_list[7].updated_ind = 1
   ENDIF
   IF (((parafulltermcnt > 0) OR (parapretermcnt > 0)) )
    SET eventsets->event_set_list[8].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      8].event_set_value)+ 1))
    SET eventsets->event_set_list[8].updated_ind = 1
   ENDIF
   IF (parapretermcnt > 0)
    SET eventsets->event_set_list[9].event_set_value = cnvtstring((cnvtint(eventsets->event_set_list[
      9].event_set_value)+ parapretermcnt))
    SET eventsets->event_set_list[9].updated_ind = 1
   ENDIF
   IF (spontabortioncnt > 0)
    SET eventsets->event_set_list[10].event_set_value = cnvtstring((cnvtint(eventsets->
      event_set_list[10].event_set_value)+ spontabortioncnt))
    SET eventsets->event_set_list[10].updated_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievegravidaparadetails(person_id)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.person_id=person_id
     AND expand(expcnt,1,gpeventsetscnt,ce.event_cd,eventsets->event_set_list[expcnt].event_cd)
     AND ce.event_cd > 0.0
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
     AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
    ORDER BY ce.updt_dt_tm
    DETAIL
     idx = locateval(loccnt,1,gpeventsetscnt,ce.event_cd,eventsets->event_set_list[loccnt].event_cd)
     IF (idx > 0)
      eventsets->event_set_list[idx].event_set_value = ce.result_val
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (insertgravidaparacntstodb(person_id=f8) =null WITH protect)
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   DECLARE replacementcnt = i4 WITH protect, noconstant(0)
   SET iret = uar_crmbeginapp(gpapplicationnum,happ)
   IF (iret != 0)
    SET failureind = 1
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","InsertGravidaParaCntsToDB",
     "Failed to start App 1000071")
    GO TO exit_script
   ENDIF
   SET iret = uar_crmbegintask(happ,gptasknum,htask)
   IF (iret != 0)
    SET failureind = 1
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","InsertGravidaParaCntsToDB",
     "Failed to start Task 1000071")
    CALL uar_crmendapp(happ)
    GO TO exit_script
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",gprequestnum,hstep)
   IF (iret != 0)
    SET failureind = 1
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","InsertGravidaParaCntsToDB",
     "Failed to start Req 1000071")
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    GO TO exit_script
   ENDIF
   FOR (leventsetsidx = 1 TO gpeventsetscnt)
     IF ((eventsets->event_set_list[leventsetsidx].updated_ind > 0))
      SET hreq = uar_crmgetrequest(hstep)
      SET hreqlist = uar_srvadditem(hreq,"req")
      SET srvstat = uar_srvsetshort(hreqlist,"ensure_type",1)
      SET hstce = uar_srvgetstruct(hreqlist,"clin_event")
      SET srvstat = uar_srvsetdouble(hstce,"person_id",person_id)
      SET srvstat = uar_srvsetshort(hstce,"view_level",1)
      SET srvstat = uar_srvsetdouble(hstce,"contributor_system_cd",contributor_cd)
      SET srvstat = uar_srvsetdouble(hstce,"event_class_cd",event_class_txt_cd)
      SET srvstat = uar_srvsetdouble(hstce,"event_cd",eventsets->event_set_list[leventsetsidx].
       event_cd)
      SET srvstat = uar_srvsetdate(hstce,"event_end_dt_tm",cnvtdatetime(curdate,curtime))
      SET srvstat = uar_srvsetdouble(hstce,"record_status_cd",active_status_cd)
      SET srvstat = uar_srvsetdouble(hstce,"result_status_cd",auth_cd)
      SET srvstat = uar_srvsetshort(hstce,"authentic_flag",1)
      SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
      SET srvstat = uar_srvsetlong(hstce,"event_end_tz",curtimezonesys)
      SET replacementcnt += 1
      SET srvstat = uar_srvsetlong(hstce,"replacement_event_id",replacementcnt)
      SET hstsr = uar_srvadditem(hstce,"string_result")
      SET srvstat = uar_srvsetstring(hstsr,"string_result_text",nullterm(eventsets->event_set_list[
        leventsetsidx].event_set_value))
      SET srvstat = uar_srvsetdouble(hstsr,"string_result_format_cd",result_format_cd)
      SET hstpl = uar_srvadditem(hstsr,"event_prsnl_list")
      SET srvstat = uar_srvsetdouble(hstpl,"action_type_cd",perform_cd)
      SET srvstat = uar_srvsetdate(hstpl,"action_dt_tm",cnvtdatetime(curdate,curtime))
      SET srvstat = uar_srvsetdouble(hstpl,"action_prsnl_id",reqinfo->updt_id)
      SET srvstat = uar_srvsetdouble(hstpl,"action_status_cd",action_status_cd)
      SET srvstat = uar_srvsetlong(hstpl,"action_tz",curtimezonesys)
      SET hstpl1 = uar_srvadditem(hstsr,"event_prsnl_list")
      SET srvstat = uar_srvsetdouble(hstpl1,"action_type_cd",verify_cd)
      SET srvstat = uar_srvsetdate(hstpl1,"action_dt_tm",cnvtdatetime(curdate,curtime))
      SET srvstat = uar_srvsetdouble(hstpl1,"action_prsnl_id",reqinfo->updt_id)
      SET srvstat = uar_srvsetdouble(hstpl1,"action_status_cd",action_status_cd)
      SET srvstat = uar_srvsetlong(hstpl1,"action_tz",curtimezonesys)
     ENDIF
   ENDFOR
   SET iret = uar_crmperform(hstep)
   IF (iret != 0)
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","InsertGravidaParaCntsToDB",
     "Failed to Perform update to Clinical Event")
    SET failureind = 1
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
   ENDIF
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
 END ;Subroutine
 SUBROUTINE getoverduepregnancies(null)
   DECLARE iegadays = i4 WITH protect, constant((iautocloseweeks * 7))
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   DECLARE cutoffdays = i4 WITH protect, constant((iegadays - (igestationweeks * 7)))
   DECLARE eddcutoffdate = dq8 WITH protect, constant(cnvtlookbehind(build(cutoffdays,",D"),now))
   DECLARE onsetcutoffdate = dq8 WITH protect, constant(cnvtlookbehind(build(iegadays,",D"),now))
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pregnancy_instance pi,
     problem p,
     pregnancy_estimate pe
    PLAN (pi
     WHERE pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
      AND pi.active_ind=1
      AND pi.historical_ind=0)
     JOIN (p
     WHERE p.problem_id=pi.problem_id
      AND p.active_ind=1)
     JOIN (pe
     WHERE (pe.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (pe.active_ind= Outerjoin(1)) )
    ORDER BY pi.pregnancy_id, pe.status_flag DESC
    HEAD pi.pregnancy_id
     IF (((pe.pregnancy_estimate_id > 0
      AND pe.est_delivery_dt_tm < cnvtdatetime(eddcutoffdate)) OR (pe.pregnancy_estimate_id=0
      AND p.onset_dt_tm < cnvtdatetime(onsetcutoffdate))) )
      cnt += 1
      IF (mod(cnt,10)=1)
       istat = alterlist(pregs->qual,(cnt+ 9))
      ENDIF
      pregs->qual[cnt].person_id = pi.person_id, pregs->qual[cnt].pregnancy_id = pi.pregnancy_id,
      pregs->qual[cnt].pregnancy_instance_id = pi.pregnancy_instance_id,
      pregs->qual[cnt].problem_id = p.problem_id, pregs->qual[cnt].life_cycle_status_cd = p
      .life_cycle_status_cd, pregs->qual[cnt].classification_cd = p.classification_cd,
      pregs->qual[cnt].onset_dt_tm = p.onset_dt_tm, pregs->qual[cnt].preg_start_dt_tm = pi
      .preg_start_dt_tm, pregs->qual[cnt].org_id = pi.organization_id
      IF (encntr_id_column_exists=1)
       pregs->qual[cnt].encntr_id = pi.encntr_id
      ENDIF
      IF (cnvtdatetime(p.onset_dt_tm) < cnvtdatetime(earliestpregnancydt))
       earliestpregnancydt = p.onset_dt_tm
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (size(pregs->qual,5) <= 0)
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","Z","GetOverduePregnancies",
     "No Pregnancies to close")
    SET zeroind = 1
    SET failureind = 0
    GO TO exit_script
   ENDIF
   SET failureind = 0
   SET istat = alterlist(pregs->qual,cnt)
   IF (debugind=1)
    CALL echorecord(pregs)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkfordelivery(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(20)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(20)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE pregnancycnt = i4 WITH public, noconstant(size(pregs->qual,5))
   DECLARE preg_idx = i4 WITH public, noconstant(0)
   DECLARE temp_preg_idx = i4 WITH public, noconstant(0)
   DECLARE eventcdcnt = i4 WITH protect, noconstant(0)
   DECLARE eventcdcntpregnancy = i4 WITH protect, noconstant(0)
   SET expand_total = (ceil((cnvtreal(pregnancycnt)/ expand_size)) * expand_size)
   SET istat = alterlist(pregs->qual,expand_total)
   FOR (idx = (pregnancycnt+ 1) TO expand_total)
     SET pregs->qual[idx].person_id = pregs->qual[pregnancycnt].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_date_result dr,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (ce
     WHERE expand(num,expand_start,expand_stop,ce.person_id,pregs->qual[num].person_id)
      AND ((expand(eventcdcnt,1,size(deliverydateeventcds->eventcodes,5),ce.event_cd,
      deliverydateeventcds->eventcodes[eventcdcnt].eventcode)) OR (expand(eventcdcntpregnancy,1,size(
       pregoutcomedateeventcds->eventcodes,5),ce.event_cd,pregoutcomedateeventcds->eventcodes[
      eventcdcntpregnancy].eventcode)))
      AND ce.ce_dynamic_label_id > 0.0
      AND ce.event_cd > 0.0
      AND ce.event_end_dt_tm >= cnvtdatetime(earliestpregnancydt)
      AND ce.publish_flag=1
      AND ce.view_level >= 1
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
      AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd))
     JOIN (dr
     WHERE dr.event_id=ce.event_id
      AND dr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00:00")
      AND dr.date_type_flag=0)
    ORDER BY ce.person_id, ce.event_end_dt_tm DESC
    HEAD ce.person_id
     temp_preg_idx = locateval(i,1,pregnancycnt,ce.person_id,pregs->qual[i].person_id)
     IF (temp_preg_idx > 0
      AND dr.result_dt_tm >= cnvtdatetime(pregs->qual[temp_preg_idx].onset_dt_tm))
      pregs->qual[temp_preg_idx].delivered_ind = 1
      IF (debugind=1)
       CALL echo(build2("Person id: ",pregs->qual[temp_preg_idx].person_id,
        " has a qualifying pregnancy but has a delivery date documented."))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET istat = alterlist(pregs->qual,pregnancycnt)
   SET preg_idx = locateval(i,1,pregnancycnt,0,pregs->qual[i].delivered_ind)
   IF (preg_idx <= 0)
    SET zeroind = 1
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","Z","CheckForDelivery",
     "No Pregnancies to close without delivery date")
   ENDIF
 END ;Subroutine
 SUBROUTINE closeundeliveredpregnancies(null)
   DECLARE pregscnt = i4 WITH protect, constant(size(pregs->qual,5))
   DECLARE loopidx = i4 WITH protect, noconstant(0)
   DECLARE failstatus = vc WITH protect, noconstant("")
   DECLARE statusidx = i4 WITH protect, noconstant(0)
   DECLARE successcnt = i4 WITH protect, noconstant(0)
   DECLARE lbabycnt = i4 WITH protect, noconstant(0)
   DECLARE lbabyindex = i4 WITH protect, noconstant(0)
   DECLARE person_id = f8 WITH protect, noconstant(0.0)
   SET stat = alterlist(phxensurerequest->pregnancies,0)
   SET phxensurerequest->nomen_source_id = snomensourceid
   SET phxensurerequest->nomen_vocab_mean = snomenvocabmean
   FOR (loopidx = 1 TO pregscnt)
     IF ((pregs->qual[loopidx].delivered_ind=0))
      SET person_id = pregs->qual[loopidx].person_id
      SET stat = alterlist(docsetstruct->label_list,0)
      CALL getlabelidsbydocsetref(person_id)
      SET lbabycnt = size(docsetstruct->label_list,5)
      SET sdocgenerated = 0
      IF (lbabycnt > 0)
       IF (sdocprefset=1)
        SET sdocgenerated = generatesummarydocument(person_id)
       ENDIF
       IF (((sdocprefset=0) OR (sdocprefset=1
        AND sdocgenerated=1)) )
        SET phxensurerequest->person_id = pregs->qual[loopidx].person_id
        SET phxensurerequest->problem_id = pregs->qual[loopidx].problem_id
        SET phxensurerequest->prsnl_id = reqinfo->updt_id
        SET phxensurerequest->classification_cd = pregs->qual[loopidx].classification_cd
        SET istat = alterlist(phxensurerequest->pregnancies,1)
        SET phxensurerequest->pregnancies[1].pregnancy_id = pregs->qual[loopidx].pregnancy_id
        SET phxensurerequest->pregnancies[1].pregnancy_instance_id = pregs->qual[loopidx].
        pregnancy_instance_id
        SET phxensurerequest->pregnancies[1].ensure_type = close_ensure_type
        SET phxensurerequest->pregnancies[1].problem_id = pregs->qual[loopidx].problem_id
        SET phxensurerequest->pregnancies[1].sensitive_ind = 0
        SET phxensurerequest->pregnancies[1].preg_start_dt_tm = pregs->qual[loopidx].preg_start_dt_tm
        SET phxensurerequest->pregnancies[1].preg_end_dt_tm = cnvtdatetime(sysdate)
        SET phxensurerequest->pregnancies[1].org_id = pregs->qual[loopidx].org_id
        SET phxensurerequest->pregnancies[1].encntr_id = pregs->qual[loopidx].encntr_id
        SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_actions,size(docsetstruct->
          label_list,5))
        FOR (babyindex = 1 TO lbabycnt)
          SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].action_tz =
          curtimezonesys
          SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].action_type_cd =
          auto_close_action_cd
          SET phxensurerequest->pregnancies[1].pregnancy_actions[babyindex].prsnl_id = reqinfo->
          updt_id
        ENDFOR
        SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_children,lbabycnt)
        FOR (babyindex = 1 TO lbabycnt)
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].pregnancy_child_id = 0
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_method_cd =
          unknown_delivery_cd
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].delivery_dt_tm = null
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].
          delivery_date_precision_flag = no_precision
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].
          delivery_date_qualifier_flag = no_qualifier
          SET phxensurerequest->pregnancies[1].pregnancy_children[babyindex].labor_duration = - (1)
        ENDFOR
        SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_entities,size(docsetstruct->
          label_list,5))
        FOR (babyindex = 1 TO lbabycnt)
          SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].pregnancy_entity_id = 0
          SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].delete_flag = 0
          SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_id =
          docsetstruct->label_list[babyindex].dynamic_label_id
          SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_name =
          "CE_DYNAMIC_LABEL"
          SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].component_type_cd =
          comp_label_type_cd
        ENDFOR
        IF (ensuredeventid != 0)
         SET istat = alterlist(phxensurerequest->pregnancies[1].pregnancy_entities,(size(
           phxensurerequest->pregnancies[1].pregnancy_entities,5)+ 1))
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].pregnancy_entity_id = 0
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].delete_flag = 0
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_id =
         ensuredeventid
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].parent_entity_name =
         "CLINICAL_EVENT"
         SET phxensurerequest->pregnancies[1].pregnancy_entities[babyindex].component_type_cd =
         component_type_cd
        ENDIF
        SET modify = nopredeclare
        EXECUTE dcp_ens_phx  WITH replace("REQUEST",phxensurerequest), replace("REPLY",phxensurereply
         )
        IF (lbabycnt > 0)
         CALL inactivatepregnancylabels(null)
        ENDIF
        SET modify = predeclare
        IF (debugind=1)
         CALL echo(build("phxEnsureReply->status_data.status",phxensurereply->status_data.status))
        ENDIF
        IF ((phxensurereply->status_data.status="S"))
         SET successcnt += 1
         COMMIT
         IF (iaddpregincgp != 1)
          SET eventsets->event_set_list[1].event_set_value = ""
          SET eventsets->event_set_list[1].updated_ind = 0
          SELECT
           ce.event_cd
           FROM clinical_event ce
           WHERE ce.person_id=person_id
            AND (ce.event_cd=eventsets->event_set_list[1].event_cd)
           ORDER BY ce.updt_dt_tm
           DETAIL
            eventsets->event_set_list[1].event_set_value = ce.result_val
           WITH nocounter
          ;end select
          SET eventsets->event_set_list[1].event_set_value = cnvtstring((cnvtint(eventsets->
            event_set_list[1].event_set_value)+ 1))
          SET eventsets->event_set_list[1].updated_ind = 1
          CALL insertgravidaparacntstodb(person_id)
         ENDIF
        ELSE
         CALL copysubeventstatustoreply(phxensurereply)
         SET failureind = 1
         SET failstatus = build2("Pregnancy id: ",pregs->qual[loopidx].pregnancy_id,
          " was not closed.")
         CALL fillsubeventstatus("dcp_auto_close_pregnancy","F","CloseUndeliveredPregnancies",
          failstatus)
         ROLLBACK
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (successcnt > 0)
    CALL fillsubeventstatus("dcp_auto_close_pregnancy","S","CloseUndeliveredPregnancies",build2(
      "Successfully closed ",successcnt," pregnancies."))
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlabelidsbydocsetref(person_id=f8) =null WITH protect)
   DECLARE lrescnt = i4 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   RECORD docsetrequest(
     1 person_id = f8
     1 docsetref_list[1]
       2 docsetname = vc
   )
   IF (debugind=1)
    CALL echo(build("sDocsetName = ",sdocsetname))
   ENDIF
   SET docsetrequest->docsetref_list[1].docsetname = sdocsetname
   SET docsetrequest->person_id = person_id
   EXECUTE dcp_get_labels_by_docsetrefs  WITH replace("REQUEST",docsetrequest), replace("REPLY",
    docsetstruct)
   IF ((docsetstruct->status_data.status="F"))
    CALL echo("[FAIL]: dcp_get_labels_by_docsetrefs failed")
    SET replystruct->status_data.status = "F"
    GO TO exit_script
   ELSEIF ((docsetstruct->status_data.status="Z"))
    CALL echo(build("[ZERO]: No label ids retireved for docsetref ",sdocsetname))
    SET replystruct->status_data.status = "Z"
    SET stat = alterlist(docsetstruct->label_list,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivatepregnancylabels(null)
   DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   DECLARE label_cnt = i4 WITH protect, noconstant(0)
   DECLARE counter = i4 WITH protect, noconstant(0)
   DECLARE nextval = f8 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",4002015,"INACTIVE"))
   RECORD dynamic_labels(
     1 labels[*]
       2 pregnancy_entity_id = f8
       2 ce_dynamic_label_id = f8
       2 new_dynamic_label_id = f8
       2 prev_dynamic_label_id = f8
       2 label_name = vc
       2 old_label_prsnl_id = f8
       2 new_label_prsnl_id = f8
       2 label_template_id = f8
       2 label_status_cd = f8
       2 label_comment = vc
       2 person_id = f8
       2 result_set_id = f8
       2 valid_from_dt_tm = dq8
       2 label_seq_nbr = i4
       2 create_dt_tm = dq8
       2 long_text_id = f8
   )
   SELECT DISTINCT INTO "nl:"
    FROM ce_dynamic_label c,
     (dummyt d  WITH seq = size(docsetstruct->label_list,5))
    PLAN (d)
     JOIN (c
     WHERE (c.ce_dynamic_label_id=docsetstruct->label_list[d.seq].dynamic_label_id))
    HEAD REPORT
     label_cnt = 0
    HEAD c.prev_dynamic_label_id
     counter = 0
    DETAIL
     counter += 1
     IF (counter=1)
      label_cnt += 1
      IF (label_cnt > size(dynamic_labels->labels,5))
       stat = alterlist(dynamic_labels->labels,(label_cnt+ 4))
      ENDIF
      dynamic_labels->labels[label_cnt].ce_dynamic_label_id = c.ce_dynamic_label_id, dynamic_labels->
      labels[label_cnt].prev_dynamic_label_id = c.ce_dynamic_label_id, dynamic_labels->labels[
      label_cnt].label_name = c.label_name,
      dynamic_labels->labels[label_cnt].old_label_prsnl_id = c.label_prsnl_id, dynamic_labels->
      labels[label_cnt].new_label_prsnl_id = c.label_prsnl_id, dynamic_labels->labels[label_cnt].
      label_status_cd = c.label_status_cd,
      dynamic_labels->labels[label_cnt].label_template_id = c.label_template_id, dynamic_labels->
      labels[label_cnt].person_id = c.person_id, dynamic_labels->labels[label_cnt].result_set_id = c
      .result_set_id,
      dynamic_labels->labels[label_cnt].valid_from_dt_tm = c.valid_from_dt_tm, dynamic_labels->
      labels[label_cnt].label_seq_nbr = c.label_seq_nbr, dynamic_labels->labels[label_cnt].
      long_text_id = c.long_text_id,
      dynamic_labels->labels[label_cnt].create_dt_tm = c.create_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(dynamic_labels->labels,label_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    new_seq = seq(ocf_seq,nextval)
    FROM (dummyt d1  WITH seq = label_cnt),
     dual d
    PLAN (d1)
     JOIN (d
     WHERE 1=1)
    DETAIL
     dynamic_labels->labels[d1.seq].new_dynamic_label_id = new_seq
    WITH nocounter
   ;end select
   UPDATE  FROM ce_dynamic_label c,
     (dummyt d  WITH seq = size(docsetstruct->label_list,5))
    SET c.label_status_cd = inactive, c.updt_dt_tm = cnvtdatetime(current_dt_tm), c.updt_cnt = (c
     .updt_cnt+ 1),
     c.updt_task = reqinfo->updt_task, c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (c
     WHERE (c.ce_dynamic_label_id=docsetstruct->label_list[d.seq].dynamic_label_id))
   ;end update
   IF (curqual != size(docsetstruct->label_list,5))
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   INSERT  FROM ce_dynamic_label dl,
     (dummyt d  WITH seq = value(label_cnt))
    SET dl.ce_dynamic_label_id = dynamic_labels->labels[d.seq].new_dynamic_label_id, dl
     .prev_dynamic_label_id = dynamic_labels->labels[d.seq].prev_dynamic_label_id, dl.label_name =
     dynamic_labels->labels[d.seq].label_name,
     dl.label_prsnl_id = dynamic_labels->labels[d.seq].old_label_prsnl_id, dl.label_status_cd =
     dynamic_labels->labels[d.seq].label_status_cd, dl.person_id = dynamic_labels->labels[d.seq].
     person_id,
     dl.result_set_id = dynamic_labels->labels[d.seq].result_set_id, dl.label_template_id =
     dynamic_labels->labels[d.seq].label_template_id, dl.valid_from_dt_tm = cnvtdatetime(
      dynamic_labels->labels[d.seq].valid_from_dt_tm),
     dl.valid_until_dt_tm = cnvtdatetimeutc(current_dt_tm), dl.label_seq_nbr = dynamic_labels->
     labels[d.seq].label_seq_nbr, dl.create_dt_tm = cnvtdatetime(dynamic_labels->labels[d.seq].
      create_dt_tm),
     dl.updt_dt_tm = cnvtdatetime(current_dt_tm), dl.updt_task = reqinfo->updt_task, dl.updt_id =
     reqinfo->updt_id,
     dl.updt_applctx = reqinfo->updt_applctx, dl.updt_cnt = 0
    PLAN (d)
     JOIN (dl)
    WITH nocounter
   ;end insert
   IF (curqual != label_cnt)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (generatesummarydocument(person_id=f8) =i2 WITH protect)
   SET modify = nopredeclare
   FREE RECORD request
   RECORD request(
     1 output_device = vc
     1 script_name = vc
     1 person_cnt = i4
     1 person[*]
       2 person_id = f8
     1 visit_cnt = i4
     1 visit[*]
       2 encntr_id = f8
     1 prsnl_cnt = i4
     1 prsnl[*]
       2 prsnl_id = f8
     1 nv_cnt = i4
     1 nv[*]
       2 pvc_name = vc
       2 pvc_value = vc
     1 batch_selection = vc
     1 print_pref = i2
   )
   FREE RECORD reply
   RECORD reply(
     1 text = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
     1 large_text_qual[*]
       2 text_segment = vc
   )
   DECLARE lblobsize = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hblob = i4 WITH protect, noconstant(0)
   DECLARE hstruct = i4 WITH protect, noconstant(0)
   DECLARE hblobitem = i4 WITH protect, noconstant(0)
   DECLARE crmstatus = i4 WITH protect, noconstant(0)
   DECLARE blobscnt = i4 WITH protect, noconstant(0)
   DECLARE long_text = vc WITH protect, noconstant("")
   DECLARE blobsidx = i4 WITH protect, noconstant(0)
   DECLARE repsize = i4 WITH private, noconstant(0)
   SET ensuredeventid = 0.0
   SET now_dt_tm->dt_tm = cnvtdatetime(sysdate)
   DECLARE rtf_text = vc WITH protect, noconstant("")
   DECLARE blob_size = i4 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH private, noconstant(1)
   SET request->script_name = nullterm(sdocreportname)
   SET request->person_cnt = 1
   SET stat = alterlist(request->person,1)
   SET request->person[1].person_id = person_id
   EXECUTE dcp_rpt_driver
   FREE RECORD qual
   IF (size(reply->text)=0)
    IF (debugind=1)
     CALL echo("Could not generate summary document report. Exiting Script.")
    ENDIF
    SET retval = 0
   ENDIF
   SET crmstatus = uar_crmbeginapp(1000012,happ)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin App for application 1000012.")
     CALL echo(build("Crm Status: ",crmstatus))
     CALL echo("Cannot call Event_Ensure. Exiting Script.")
    ENDIF
    SET retval = 0
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,1000012,htask)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin Task for task 1000012.")
     CALL echo(build("Crm Status: ",crmstatus))
     CALL echo("Cannot call Event_Ensure. Exiting Script.")
    ENDIF
    CALL uar_crmendapp(happ)
    SET retval = 0
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,"",1000012,hstep)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin Request for request 1000012.")
     CALL echo(build("Crm Status: ",crmstatus))
    ENDIF
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    SET retval = 0
   ELSE
    SET hreq = uar_crmgetrequest(hstep)
    SET srvstat = uar_srvsetshort(hreq,"ensure_type",1)
    SET hstruct = uar_srvgetstruct(hreq,"clin_event")
    SET srvstat = uar_srvsetlong(hstruct,"view_level",1)
    SET srvstat = uar_srvsetdouble(hstruct,"person_id",person_id)
    SET srvstat = uar_srvsetdouble(hstruct,"contributor_system_cd",contributor_cd)
    SET srvstat = uar_srvsetdouble(hstruct,"event_class_cd",event_class_mdoc_cd)
    SET srvstat = uar_srvsetdouble(hstruct,"event_cd",sdoceventsetcd)
    SET srvstat = uar_srvsetdate2(hstruct,"event_end_dt_tm",now_dt_tm)
    SET srvstat = uar_srvsetdouble(hstruct,"record_status_cd",active_status_cd)
    SET srvstat = uar_srvsetdouble(hstruct,"result_status_cd",auth_cd)
    SET srvstat = uar_srvsetshort(hstruct,"authentic_flag",1)
    SET srvstat = uar_srvsetshort(hstruct,"publish_flag",1)
    SET srvstat = uar_srvsetstring(hstruct,"event_title_text",nullterm(sdocreporttitle))
    SET srvstat = uar_srvsetlong(hstruct,"event_end_tz",curtimezonesys)
    SET hstructepl = uar_srvadditem(hstruct,"event_prsnl_list")
    SET srvstat = uar_srvsetdouble(hstructepl,"action_type_cd",perform_cd)
    SET srvstat = uar_srvsetdate2(hstructepl,"action_dt_tm",now_dt_tm)
    SET srvstat = uar_srvsetdouble(hstructepl,"action_prsnl_id",reqinfo->updt_id)
    SET srvstat = uar_srvsetdouble(hstructepl,"action_status_cd",action_status_cd)
    SET srvstat = uar_srvsetlong(hstructepl,"action_tz",curtimezonesys)
    SET heventtype = uar_srvcreatetypefrom(hreq,"clin_event")
    SET srvstat = uar_srvbinditemtype(hstruct,"child_event_list",heventtype)
    SET hstructcel = uar_srvadditem(hstruct,"child_event_list")
    SET srvstat = uar_srvsetdouble(hstructcel,"person_id",person_id)
    SET srvstat = uar_srvsetdouble(hstructcel,"contributor_system_cd",contributor_cd)
    SET srvstat = uar_srvsetdouble(hstructcel,"event_class_cd",event_class_doc_cd)
    SET srvstat = uar_srvsetdouble(hstructcel,"event_cd",sdoceventsetcd)
    SET srvstat = uar_srvsetdate2(hstructcel,"event_end_dt_tm",now_dt_tm)
    SET srvstat = uar_srvsetdouble(hstructcel,"record_status_cd",active_status_cd)
    SET srvstat = uar_srvsetdouble(hstructcel,"result_status_cd",auth_cd)
    SET srvstat = uar_srvsetshort(hstructcel,"authentic_flag",1)
    SET srvstat = uar_srvsetshort(hstructcel,"publish_flag",1)
    SET srvstat = uar_srvsetstring(hstructcel,"event_title_text",nullterm(sdocreporttitle))
    SET srvstat = uar_srvsetstring(hstructcel,"collating_seq","2")
    SET blobscnt = size(reply->large_text_qual,5)
    IF (blobscnt > 0)
     SET hblobitem = uar_srvadditem(hstructcel,"blob_result")
     SET srvstat = uar_srvsetdouble(hblobitem,"succession_type_cd",succession_type_cd)
     SET srvstat = uar_srvsetdouble(hblobitem,"storage_cd",storage_cd)
     SET srvstat = uar_srvsetdouble(hblobitem,"format_cd",format_cd)
     FOR (blobsidx = 1 TO blobscnt)
       SET lblobsize = size(reply->large_text_qual[blobsidx].text_segment)
       SET long_text = nullterm(reply->large_text_qual[blobsidx].text_segment)
       SET rtf_text = concat(rtf_text,long_text)
       SET rtf_text = trim(rtf_text,2)
       SET blob_size += lblobsize
     ENDFOR
     SET hblob = uar_srvadditem(hblobitem,"blob")
     SET srvstat = uar_srvsetshort(hblob,"blob_contents_ind",0)
     SET srvstat = uar_srvsetasis(hblob,"blob_contents",nullterm(rtf_text),blob_size)
     SET srvstat = uar_srvsetlong(hblob,"blob_length",blob_size)
    ELSE
     SET hblobitem = uar_srvadditem(hstructcel,"blob_result")
     SET srvstat = uar_srvsetdouble(hblobitem,"succession_type_cd",succession_type_cd)
     SET srvstat = uar_srvsetdouble(hblobitem,"storage_cd",storage_cd)
     SET srvstat = uar_srvsetdouble(hblobitem,"format_cd",format_cd)
     SET hblob = uar_srvadditem(hblobitem,"blob")
     SET lblobsize = size(reply->text)
     SET srvstat = uar_srvsetasis(hblob,"blob_contents",nullterm(reply->text),lblobsize)
    ENDIF
    SET iret = uar_crmperform(hstep)
    IF (iret != 0)
     IF (debugind=1)
      CALL echo("Error while executing service call 1000012")
      CALL echo(build("Status: ",iret))
     ENDIF
     CALL uar_crmendreq(hstep)
     CALL uar_crmendtask(htask)
     CALL uar_crmendapp(happ)
     SET retval = 0
    ENDIF
    SET hreply = uar_crmgetreply(hstep)
   ENDIF
   SET crmstatus = uar_crmbeginapp(eventensureapp,happ)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin App for application 600345.")
     CALL echo(build("Crm Status: ",crmstatus))
     CALL echo("Cannot call 600345. Exiting Script.")
    ENDIF
    SET retval = 0
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,eventensuretask,htask)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin Task for task 600345.")
     CALL echo(build("Crm Status: ",crmstatus))
     CALL echo("Cannot call 600345. Exiting Script.")
    ENDIF
    CALL uar_crmendapp(happ)
    SET retval = 0
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,"",eventensurereq,hstep)
   IF (crmstatus != 0)
    IF (debugind=1)
     CALL echo("Error in Begin Request for request 600345.")
     CALL echo(build("Crm Status: ",crmstatus))
    ENDIF
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    SET retval = 0
   ELSE
    SET hreq = uar_crmgetrequest(hstep)
    SET repsize = uar_srvgetitemcount(hreply,"rb_list")
    IF (repsize > 0)
     FOR (x = 1 TO repsize)
       SET hreqlist = uar_srvadditem(hreq,"elist")
       SET hgetlistitemlist = uar_srvgetitem(hreply,"rb_list",(x - 1))
       SET nsrvstat = uar_srvsetdouble(hreqlist,"event_id",uar_srvgetdouble(hgetlistitemlist,
         "event_id"))
       SET ensuredeventid = uar_srvgetdouble(hgetlistitemlist,"event_id")
     ENDFOR
     SET ncrmstat = uar_crmperform(hstep)
     IF (ncrmstat != 0)
      IF (debugind=1)
       CALL echo("Error while executing script 600345")
       CALL echo(build("Status: ",ncrmstat))
      ENDIF
      CALL uar_crmendreq(hstep)
      CALL uar_crmendtask(htask)
      CALL uar_crmendapp(happ)
      SET retval = 0
     ENDIF
    ENDIF
   ENDIF
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(retval)
   SET modify = predeclare
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(replystruct->status_data.
     subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(replystruct->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET replystruct->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET replystruct->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET replystruct->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET replystruct->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL fillsubeventstatus("ERROR","F","dcp_auto_close_pregnancy",serrormsg)
  SET replystruct->status_data.status = "F"
 ELSEIF (zeroind=1
  AND zerodeliveredind=1)
  SET replystruct->status_data.status = "Z"
 ELSEIF (failureind=1)
  SET replystruct->status_data.status = "F"
 ELSE
  SET replystruct->status_data.status = "S"
 ENDIF
 IF (debugind=1)
  CALL echorecord(replystruct)
 ENDIF
 IF (debugind=1)
  CALL echo("Last Mod: 05/19/2021")
 ENDIF
 SET modify = nopredeclare
END GO
