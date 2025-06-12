CREATE PROGRAM ams_pcm_close:dba
 PROMPT
  "Person" = 0
  WITH person_id
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp_child
 RECORD temp_child(
   1 qual[*]
     2 baby = vc
     2 delivery_dt_tm = dq8
     2 ce_dynamic_label_id = f8
     2 weight = f8
     2 temp_weight = f8
     2 gender_result_val = vc
     2 gender_cd = f8
 )
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 problem_id = f8
   1 prsnl_id = f8
   1 gravida_cnt = i4
   1 para_full_term_cnt = i4
   1 para_premature_cnt = i4
   1 para_abortion_cnt = i4
   1 para_living_cnt = i4
   1 live_child_comment = c32000
   1 pregnancies[*]
     2 pregnancy_instance_id = f8
     2 pregnancy_id = f8
     2 ensure_type = i2
     2 problem_id = f8
     2 sensitive_ind = i2
     2 preg_start_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 override_comment = c255
     2 confirmation_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 pregnancy_entities[*]
       3 pregnancy_entity_id = f8
       3 delete_flag = i2
       3 parent_entity_name = c30
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
       3 child_name = c60
       3 person_id = f8
       3 restrict_person_id_ind = i2
       3 father_name = c60
       3 delivery_method_cd = f8
       3 delivery_hospital = c60
       3 labor_duration = i4
       3 gestation_age = i4
       3 weight_amt = f8
       3 weight_unit_cd = f8
       3 anesthesia_txt = c60
       3 preterm_labor_txt = c255
       3 delivery_dt_tm = dq8
       3 delivery_tz = i4
       3 neonate_outcome_cd = f8
       3 child_comment = c32000
       3 child_entities[*]
         4 pregnancy_child_entity_id = f8
         4 delete_flag = i2
         4 parent_entity_name = c30
         4 parent_entity_id = f8
         4 component_type_cd = f8
         4 entity_text = c32000
       3 delivery_date_precision_flag = i2
       3 delivery_date_qualifier_flag = i2
     2 org_id = f8
   1 classification_cd = f8
   1 nomen_source_id = vc
   1 nomen_vocab_mean = c12
 )
 DECLARE close_action_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",4002114,"CLOSE"))
 DECLARE delivery_method_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",4002119,"UNKNOWN"
   ))
 DECLARE gravida_cnt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDAPCM"))
 DECLARE para_full_term_cnt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PARAFULLTERM"))
 DECLARE para_premature_cnt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PARAPREMATURE"))
 DECLARE para_abortion_cnt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PARAABORTIONS"))
 DECLARE para_living_cnt_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LIVINGCHILDRENPREGNANCYHISTORY"))
 DECLARE result_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE record_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE gram_weight_unit_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",54,"G"))
 DECLARE male_gender_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE female_gender_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE unspecified_gender_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",57,
   "UNSPECIFIED"))
 DECLARE baby_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BABY"))
 DECLARE baby_gender_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BABYGENDER"))
 DECLARE pregnancy_id = f8 WITH protect
 DECLARE pregnancy_instance_id = f8 WITH protect
 DECLARE problem_id = f8 WITH protect
 DECLARE sensitive_ind = i4 WITH protect
 DECLARE preg_start_dt_tm = dq8 WITH protect
 DECLARE confirmed_dt_tm = dq8 WITH protect
 DECLARE organization_id = f8 WITH protect
 DECLARE classification_cd = f8 WITH protect
 DECLARE nomen_source_id = vc WITH protect
 DECLARE nomen_vocab_mean = c12 WITH protect
 DECLARE gravida_cnt = i4 WITH protect
 DECLARE para_full_term_cnt = i4 WITH protect
 DECLARE para_premature_cnt = i4 WITH protect
 DECLARE para_abortion_cnt = i4 WITH protect
 DECLARE para_living_cnt = i4 WITH protect
 DECLARE cntx = i4 WITH protect
 SELECT INTO "nl:"
  FROM pregnancy_instance pi
  PLAN (pi
   WHERE pi.person_id=value( $1)
    AND pi.preg_end_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY pi.person_id
  HEAD pi.person_id
   pregnancy_id = pi.pregnancy_id, pregnancy_instance_id = pi.pregnancy_instance_id, problem_id = pi
   .problem_id,
   sensitive_ind = pi.sensitive_ind, preg_start_dt_tm = pi.preg_start_dt_tm, confirmed_dt_tm = pi
   .confirmed_dt_tm,
   organization_id = pi.organization_id
  WITH nocounter
 ;end select
 CALL echo(build("pregnancy_id=",pregnancy_id))
 CALL echo(build("pregnancy_instance_id=",pregnancy_instance_id))
 CALL echo(build("problem_id=",problem_id))
 CALL echo(build("sensitive_ind=",sensitive_ind))
 CALL echo(build("preg_start_dt_tm=",preg_start_dt_tm))
 CALL echo(build("confirmed_dt_tm=",confirmed_dt_tm))
 CALL echo(build("organization_id=",organization_id))
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n,
   clinical_event ce
  PLAN (p
   WHERE p.person_id=value( $1)
    AND p.problem_id=problem_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE p.nomenclature_id=n.nomenclature_id
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ce
   WHERE ce.person_id=value( $1)
    AND ce.event_cd IN (gravida_cnt_cd, para_full_term_cnt_cd, para_premature_cnt_cd,
   para_abortion_cnt_cd, para_living_cnt_cd)
    AND ce.record_status_cd=record_status_cd
    AND ce.result_status_cd=result_status_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ce.event_cd, ce.performed_dt_tm DESC
  HEAD p.person_id
   classification_cd = p.classification_cd
  HEAD n.nomenclature_id
   nomen_source_id = n.source_identifier, nomen_vocab_mean = uar_get_code_display(n
    .source_vocabulary_cd)
  HEAD ce.event_cd
   IF (ce.event_cd=gravida_cnt_cd)
    gravida_cnt = cnvtint(ce.result_val)
   ELSEIF (ce.event_cd=para_full_term_cnt_cd)
    para_full_term_cnt = cnvtint(ce.result_val)
   ELSEIF (ce.event_cd=para_premature_cnt_cd)
    para_premature_cnt = cnvtint(ce.result_val)
   ELSEIF (ce.event_cd=para_abortion_cnt_cd)
    para_abortion_cnt = cnvtint(ce.result_val)
   ELSEIF (ce.event_cd=para_living_cnt_cd)
    para_living_cnt = cnvtint(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("classification_cd=",classification_cd))
 CALL echo(build("nomen_source_id=",nomen_source_id))
 CALL echo(build("nomen_vocab_mean=",nomen_vocab_mean))
 CALL echo(build("gravida_cnt=",gravida_cnt))
 CALL echo(build("para_full_term_cnt=",para_full_term_cnt))
 CALL echo(build("para_premature_cnt=",para_premature_cnt))
 CALL echo(build("para_abortion_cnt=",para_abortion_cnt))
 CALL echo(build("para_living_cnt=",para_living_cnt))
 SELECT INTO "nl:"
  FROM clinical_event ce1
  PLAN (ce1
   WHERE ce1.person_id=value( $1)
    AND ce1.event_cd=baby_cd
    AND ce1.record_status_cd=record_status_cd
    AND ce1.result_status_cd=result_status_cd
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ce1.performed_dt_tm
  HEAD ce1.person_id
   cntc = 0, stat = alterlist(temp_child->qual,10)
  DETAIL
   cntc = (cntc+ 1)
   IF (mod(cntc,10)=1
    AND cntc > 10)
    stat = alterlist(temp_child->qual,(cntc+ 9))
   ENDIF
   temp_child->qual[cntc].baby = ce1.result_val, temp_child->qual[cntc].ce_dynamic_label_id = ce1
   .ce_dynamic_label_id
  FOOT  ce1.person_id
   stat = alterlist(temp_child->qual,cntc)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(temp_child->qual,5))),
   clinical_event ce2,
   ce_date_result cd
  PLAN (d1)
   JOIN (ce2
   WHERE ce2.person_id=value( $1)
    AND (ce2.ce_dynamic_label_id=temp_child->qual[d1.seq].ce_dynamic_label_id)
    AND ce2.event_cd IN (6243420.00, 344224794.00, baby_gender_cd)
    AND ce2.record_status_cd=record_status_cd
    AND ce2.result_status_cd=result_status_cd
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (cd
   WHERE cd.event_id=outerjoin(ce2.event_id))
  ORDER BY ce2.performed_dt_tm, ce2.ce_dynamic_label_id
  DETAIL
   IF (ce2.performed_dt_tm > cnvtdatetime(preg_start_dt_tm))
    IF (ce2.event_cd=344224794.00)
     temp_child->qual[d1.seq].temp_weight = cnvtreal(ce2.result_val)
    ELSEIF (ce2.event_cd=baby_gender_cd)
     temp_child->qual[d1.seq].gender_result_val = ce2.result_val
    ELSEIF (ce2.event_cd=6243420.00)
     temp_child->qual[d1.seq].delivery_dt_tm = cd.result_dt_tm
    ENDIF
    IF ((temp_child->qual[d1.seq].gender_result_val="Male"))
     temp_child->qual[d1.seq].gender_cd = male_gender_cd
    ELSEIF ((temp_child->qual[d1.seq].gender_result_val="Female"))
     temp_child->qual[d1.seq].gender_cd = female_gender_cd
    ELSE
     temp_child->qual[d1.seq].gender_cd = unspecified_gender_cd
    ENDIF
    IF ((temp_child->qual[d1.seq].temp_weight < 100))
     temp_child->qual[d1.seq].weight = (temp_child->qual[d1.seq].temp_weight * 1000)
    ELSE
     temp_child->qual[d1.seq].weight = temp_child->qual[d1.seq].temp_weight
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp_child)
 DECLARE current_gestation_age = i4 WITH protect
 RECORD temp_request(
   1 patient_list[*]
     2 patient_id = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
 )
 SET stat = alterlist(temp_request->patient_list,1)
 SET temp_request->patient_list[1].patient_id = value( $1)
 EXECUTE dcp_get_final_ega  WITH replace(request,temp_request)
 SET current_gestation_age = reply->gestation_info[1].gest_age_at_delivery
 CALL echo(build("current_gestation_age = ",current_gestation_age))
 SET request->person_id = value( $1)
 SET request->problem_id = problem_id
 SET request->prsnl_id = reqinfo->updt_id
 SET request->gravida_cnt = gravida_cnt
 SET request->para_full_term_cnt = para_full_term_cnt
 SET request->para_living_cnt = para_living_cnt
 SET request->para_premature_cnt = para_premature_cnt
 SET request->para_abortion_cnt = para_abortion_cnt
 SET request->classification_cd = classification_cd
 SET request->nomen_source_id = nomen_source_id
 SET request->nomen_vocab_mean = nomen_vocab_mean
 SET stat = alterlist(request->pregnancies,1)
 SET request->pregnancies[1].sensitive_ind = sensitive_ind
 SET request->pregnancies[1].updt_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->pregnancies[1].ensure_type = 4
 SET request->pregnancies[1].pregnancy_id = pregnancy_id
 SET request->pregnancies[1].pregnancy_instance_id = pregnancy_instance_id
 SET request->pregnancies[1].problem_id = problem_id
 SET request->pregnancies[1].preg_start_dt_tm = cnvtdatetime(preg_start_dt_tm)
 SET request->pregnancies[1].preg_end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->pregnancies[1].confirmation_dt_tm = cnvtdatetime(confirmed_dt_tm)
 SET request->pregnancies[1].org_id = organization_id
 FOR (j = 1 TO size(temp_child->qual,5))
   IF ((temp_child->qual[j].delivery_dt_tm != null))
    SET cntx = (cntx+ 1)
    SET stat = alterlist(request->pregnancies[1].pregnancy_children,cntx)
    SET request->pregnancies[1].pregnancy_children[cntx].delete_flag = 0
    SET request->pregnancies[1].pregnancy_children[cntx].updt_dt_tm = cnvtdatetime(curdate,curtime3)
    SET request->pregnancies[1].pregnancy_children[cntx].delivery_method_cd = delivery_method_cd
    SET request->pregnancies[1].pregnancy_children[cntx].delivery_dt_tm = cnvtdatetime(temp_child->
     qual[j].delivery_dt_tm)
    SET request->pregnancies[1].pregnancy_children[cntx].weight_amt = temp_child->qual[j].weight
    SET request->pregnancies[1].pregnancy_children[cntx].weight_unit_cd = gram_weight_unit_cd
    SET request->pregnancies[1].pregnancy_children[cntx].gender_cd = temp_child->qual[j].gender_cd
    SET request->pregnancies[1].pregnancy_children[cntx].gestation_age = current_gestation_age
   ENDIF
 ENDFOR
 IF (size(request->pregnancies[1].pregnancy_children,5)=0)
  SET stat = alterlist(request->pregnancies[1].pregnancy_children,1)
  SET request->pregnancies[1].pregnancy_children[1].delete_flag = 0
  SET request->pregnancies[1].pregnancy_children[1].updt_dt_tm = cnvtdatetime(curdate,curtime3)
  SET request->pregnancies[1].pregnancy_children[1].delivery_method_cd = delivery_method_cd
  SET request->pregnancies[1].pregnancy_children[1].gestation_age = current_gestation_age
 ENDIF
 SET stat = alterlist(request->pregnancies[1].pregnancy_actions,1)
 SET request->pregnancies[1].pregnancy_actions[1].action_type_cd = close_action_cd
 SET request->pregnancies[1].pregnancy_actions[1].action_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->pregnancies[1].pregnancy_actions[1].action_tz = 399
 SET request->pregnancies[1].pregnancy_actions[1].prsnl_id = reqinfo->updt_id
 CALL echorecord(request)
 EXECUTE dcp_ens_phx
 COMMIT
 FREE RECORD temp_child
 FREE RECORD request
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
