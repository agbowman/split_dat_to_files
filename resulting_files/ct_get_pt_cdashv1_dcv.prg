CREATE PROGRAM ct_get_pt_cdashv1_dcv
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 subject_number = vc
    1 birth_dt_tm = dq8
    1 sex_cd = f8
    1 sex_disp = c50
    1 sex_desc = c50
    1 sex_mean = c12
    1 race_cd = f8
    1 race_disp = c50
    1 race_desc = c50
    1 race_mean = c12
    1 consent_dt_tm = dq8
    1 vitals[*]
      2 position = vc
      2 heart_rate = vc
      2 heart_rate_dt_tm = dq8
      2 diastolic = vc
      2 diastolic_dt_tm = dq8
      2 systolic = vc
      2 systolic_dt_tm = dq8
    1 aes[*]
      2 ae_model_name = c20
      2 ae_id = f8
      2 ae_sub_id = f8
      2 description = vc
      2 onset_dt_tm = dq8
      2 onset_prec_flag = i2
      2 resolved_dt_tm = dq8
      2 ongoing_ind = i2
      2 serious_ind = i2
      2 severity_category = vc
      2 severity_flag = i2
      2 outcome = vc
    1 conmeds[*]
      2 med_name = vc
      2 med_dose = vc
      2 med_dose_unit = vc
      2 med_start_dt_tm = dq8
      2 med_end_val = i2
      2 med_end_dt_tm = dq8
      2 order_id = f8
    1 protocol_name = vc
    1 location_id = f8
    1 location_name = vc
    1 user_id = f8
    1 user_name = vc
    1 principal_investigator_id = f8
    1 principal_investigator_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE failedind = c1 WITH noconstant("F")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE systolic_sup = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5836"))
 DECLARE systolic_sit = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5839"))
 DECLARE systolic_stand = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5840"))
 DECLARE systolic = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!75"))
 DECLARE diastolic_sup = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5837"))
 DECLARE diastolic_sit = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5838"))
 DECLARE diastolic_stand = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5841"))
 DECLARE diastolic = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!26"))
 DECLARE pulse_sup = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5844"))
 DECLARE pulse_sit = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5842"))
 DECLARE pulse_stand = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5843"))
 DECLARE pulse = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!5500"))
 RECORD temp_vitals(
   1 vitals[*]
     2 position = vc
     2 heart_rate_cd = f8
     2 heart_rate = vc
     2 heart_rate_dt_tm = dq8
     2 diastolic_cd = f8
     2 diastolic = vc
     2 diastolic_dt_tm = dq8
     2 systolic_cd = f8
     2 systolic = vc
     2 systolic_dt_tm = dq8
     2 delete_ind = i2
 )
 DECLARE bfoundvs = i2 WITH protect
 DECLARE indxvs = i2 WITH protect
 DECLARE vscount = i2 WITH protect
 DECLARE vs_cnt = i2 WITH protect
 DECLARE inerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOTDONE"))
 DECLARE princ_invest_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17441,"PRIMARY"))
 DECLARE med_student_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE process_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPendED"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pharm_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
 DECLARE resolved_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE active_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 DECLARE proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"PROPOSED"))
 DECLARE resolved_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"RESOLVED"))
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE day_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"DAY"))
 DECLARE month_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"MONTH"))
 DECLARE year_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"YEAR"))
 DECLARE tmpconmed = vc WITH protect, noconstant("")
 DECLARE conmeddttm = dq8 WITH protect
 DECLARE tmpcondition = vc WITH protect, noconstant("")
 DECLARE conditiondttm = dq8 WITH protect
 DECLARE strength = vc WITH protect, noconstant("")
 DECLARE strength_unit = vc WITH protect, noconstant("")
 DECLARE med_disp = vc WITH protect, noconstant(" ")
 DECLARE volume = vc WITH protect, noconstant(" ")
 DECLARE volume_unit = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE severityvalue(sev_cd=f8) = i2
 IF ((((request->person_id <= 0.0)) OR ((request->prot_master_id <= 0.0))) )
  CALL report_failure("VALIDATE","P","REQUEST",
   "Request not valid, person_id and prot_master_id are required")
  GO TO exit_script
 ENDIF
 SET reply->location_id = 2800.0
 SET reply->location_name = "HIMMSDemoLocation"
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   reply->user_id = reqinfo->updt_id, reply->user_name = p.username
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment caa,
   prot_role pr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND (ppr.prot_master_id=request->prot_master_id)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (caa
   WHERE ppr.reg_id=caa.reg_id
    AND caa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prot_amendment_id=caa.prot_amendment_id
    AND pr.prot_role_cd=princ_invest_cd
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id)
  DETAIL
   reply->consent_dt_tm = ppr.on_study_dt_tm, reply->subject_number = ppr.prot_accession_nbr, reply->
   principal_investigator_id = p.person_id,
   reply->principal_investigator_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->race_cd = p.race_cd, reply->sex_cd = p
   .sex_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prot_master pm
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   reply->protocol_name = pm.primary_mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_end_dt_tm, ce.event_cd, ce.result_val
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_cd IN (systolic_sup, diastolic_sup, pulse_sup, systolic_sit, diastolic_sit,
   pulse_sit, systolic_stand, diastolic_stand, pulse_stand, systolic,
   pulse, diastolic)
    AND  NOT (ce.result_status_cd IN (inerror, notdone))
    AND ce.result_val > " "
    AND (ce.encntr_id=request->encounter_id))
  ORDER BY ce.parent_event_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   vs_cnt = 0
  HEAD ce.parent_event_id
   vs_cnt = (vs_cnt+ 1)
   IF (vs_cnt > size(temp_vitals->vitals,5))
    stat = alterlist(temp_vitals->vitals,(vs_cnt+ 5))
   ENDIF
   pulseind = 0, sysind = 0, diaind = 0
  HEAD ce.event_cd
   IF (ce.event_cd IN (systolic_sup, systolic_sit, systolic_stand, systolic))
    IF (sysind=0)
     sysind = 1, temp_vitals->vitals[vs_cnt].systolic_cd = ce.event_cd, temp_vitals->vitals[vs_cnt].
     systolic = trim(ce.result_val),
     temp_vitals->vitals[vs_cnt].systolic_dt_tm = ce.event_end_dt_tm
    ENDIF
   ELSEIF (ce.event_cd IN (diastolic_sup, diastolic_sit, diastolic_stand, diastolic))
    IF (diaind=0)
     diaind = 1, temp_vitals->vitals[vs_cnt].diastolic_cd = ce.event_cd, temp_vitals->vitals[vs_cnt].
     diastolic = trim(ce.result_val),
     temp_vitals->vitals[vs_cnt].diastolic_dt_tm = ce.event_end_dt_tm
    ENDIF
   ELSEIF (ce.event_cd IN (pulse_sup, pulse_sit, pulse_stand, pulse))
    IF (pulseind=0)
     pulseind = 1, temp_vitals->vitals[vs_cnt].heart_rate_cd = ce.event_cd, temp_vitals->vitals[
     vs_cnt].heart_rate = trim(ce.result_val),
     temp_vitals->vitals[vs_cnt].heart_rate_dt_tm = ce.event_end_dt_tm
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_vitals->vitals,vs_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(temp_vitals)
 FOR (indxvs = 1 TO vs_cnt)
   SET bfoundvs = 0
   IF ((temp_vitals->vitals[indxvs].systolic_cd=systolic_sup)
    AND (temp_vitals->vitals[indxvs].diastolic_cd=diastolic_sup)
    AND (temp_vitals->vitals[indxvs].heart_rate_cd=pulse_sup))
    SET temp_vitals->vitals[indxvs].position = "SUPINE"
    SET bfoundvs = 1
   ELSEIF ((temp_vitals->vitals[indxvs].systolic_cd=systolic_sit)
    AND (temp_vitals->vitals[indxvs].diastolic_cd=diastolic_sit)
    AND (temp_vitals->vitals[indxvs].heart_rate_cd=pulse_sit))
    SET temp_vitals->vitals[indxvs].position = "SITTING"
    SET bfoundvs = 1
   ELSEIF ((temp_vitals->vitals[indxvs].systolic_cd=systolic_stand)
    AND (temp_vitals->vitals[indxvs].diastolic_cd=diastolic_stand)
    AND (temp_vitals->vitals[indxvs].heart_rate_cd=pulse_stand))
    SET temp_vitals->vitals[indxvs].position = "STANDING"
    SET bfoundvs = 1
   ELSEIF ((temp_vitals->vitals[indxvs].systolic_cd=systolic)
    AND (temp_vitals->vitals[indxvs].diastolic_cd=diastolic)
    AND (temp_vitals->vitals[indxvs].heart_rate_cd=pulse))
    SET temp_vitals->vitals[indxvs].position = ""
    SET bfoundvs = 1
   ENDIF
   SET vscount = (vscount+ 1)
   SET stat = alterlist(reply->vitals,vscount)
   SET reply->vitals[vscount].position = temp_vitals->vitals[indxvs].position
   SET reply->vitals[vscount].heart_rate = temp_vitals->vitals[indxvs].heart_rate
   SET reply->vitals[vscount].heart_rate_dt_tm = temp_vitals->vitals[indxvs].heart_rate_dt_tm
   SET reply->vitals[vscount].diastolic = temp_vitals->vitals[indxvs].diastolic
   SET reply->vitals[vscount].diastolic_dt_tm = temp_vitals->vitals[indxvs].diastolic_dt_tm
   SET reply->vitals[vscount].systolic = temp_vitals->vitals[indxvs].systolic
   SET reply->vitals[vscount].systolic_dt_tm = temp_vitals->vitals[indxvs].systolic_dt_tm
 ENDFOR
 IF ((request->con_med_unit_cd=month_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",M")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->consent_dt_tm)
 ELSEIF ((request->con_med_unit_cd=year_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",Y")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->consent_dt_tm)
 ELSEIF ((request->con_med_unit_cd=day_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",D")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->consent_dt_tm)
 ELSE
  SET conmeddttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conmeddttm > 0)
  SET conmeddttm = datetimefind(conmeddttm,"D","E","B")
 ENDIF
 IF ((request->condition_unit_cd=month_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",M")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->consent_dt_tm)
 ELSEIF ((request->condition_unit_cd=year_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",Y")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->consent_dt_tm)
 ELSEIF ((request->condition_unit_cd=day_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",D")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->consent_dt_tm)
 ELSE
  SET conditiondttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conditiondttm > 0)
  SET conditiondttm = datetimefind(conditiondttm,"D","E","B")
 ENDIF
 CALL echo(build("Finding all AE's since",format(conditiondttm,";;q")))
 SELECT INTO "NL:"
  pr.*
  FROM problem pr,
   nomenclature n
  PLAN (pr
   WHERE (pr.person_id=request->person_id)
    AND pr.active_ind=1
    AND ((pr.life_cycle_status_cd IN (active_cd, inactive_cd, resolved_cd)
    AND pr.onset_dt_tm >= cnvtdatetime(conditiondttm)) OR (pr.life_cycle_status_cd=active_cd)) )
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "PROBLEM", reply->aes[cnt].ae_id = pr.problem_id
   IF (pr.nomenclature_id > 0.0)
    reply->aes[cnt].description = n.source_string
   ELSE
    reply->aes[cnt].description = pr.problem_ftdesc
   ENDIF
   reply->aes[cnt].onset_dt_tm = pr.onset_dt_tm, reply->aes[cnt].onset_prec_flag = pr.onset_dt_flag
   IF (pr.life_cycle_status_cd=resolved_cd)
    reply->aes[cnt].ongoing_ind = 0, reply->aes[cnt].resolved_dt_tm = pr.life_cycle_dt_tm
   ELSE
    reply->aes[cnt].ongoing_ind = 1
   ENDIF
   reply->aes[cnt].severity_flag = severityvalue(pr.severity_cd), reply->aes[cnt].severity_category
    = uar_get_code_display(pr.severity_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND d.active_ind=1
    AND d.diag_dt_tm >= cnvtdatetime(conditiondttm))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "DIAGNOSIS", reply->aes[cnt].ae_id = d.diagnosis_id
   IF (d.nomenclature_id > 0.0)
    reply->aes[cnt].description = n.source_string
   ELSE
    reply->aes[cnt].description = d.diag_ftdesc
   ENDIF
   reply->aes[cnt].onset_dt_tm = d.diag_dt_tm, reply->aes[cnt].onset_prec_flag = 0, reply->aes[cnt].
   severity_flag = severityvalue(d.severity_cd),
   reply->aes[cnt].severity_category = uar_get_code_display(d.severity_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  reaction_found_ind = evaluate(nullind(r.reaction_id),0,1,1,0)
  FROM allergy a,
   nomenclature n_a,
   reaction r,
   nomenclature n_r
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND ((a.reaction_status_cd IN (active_allergy_cd, proposed_cd, resolved_allergy_cd)
    AND a.onset_dt_tm >= cnvtdatetime(conditiondttm)) OR (a.reaction_status_cd=active_allergy_cd)) )
   JOIN (n_a
   WHERE n_a.nomenclature_id=a.substance_nom_id)
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id)
    AND r.active_ind=outerjoin(1))
   JOIN (n_r
   WHERE n_r.nomenclature_id=outerjoin(r.reaction_nom_id))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "ALLERGY", reply->aes[cnt].ae_id = a.allergy_id
   IF (a.substance_nom_id > 0.0)
    reply->aes[cnt].description = n_a.source_string
   ELSE
    reply->aes[cnt].description = a.substance_ftdesc
   ENDIF
   IF (reaction_found_ind=1)
    reply->aes[cnt].ae_sub_id = r.reaction_id
    IF (n_r.nomenclature_id > 0.0)
     reply->aes[cnt].description = concat(reply->aes[cnt].description," - ",n_r.source_string)
    ELSE
     reply->aes[cnt].description = concat(reply->aes[cnt].description," - ",r.reaction_ftdesc)
    ENDIF
   ENDIF
   reply->aes[cnt].onset_dt_tm = a.onset_dt_tm, reply->aes[cnt].onset_prec_flag = a
   .onset_precision_flag, reply->aes[cnt].severity_flag = severityvalue(a.severity_cd),
   reply->aes[cnt].severity_category = uar_get_code_display(a.severity_cd)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->aes,cnt)
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=pharm_cd
    AND o.template_order_flag < 2
    AND o.order_status_cd IN (ordered_cd, completed_cd)
    AND ((o.projected_stop_dt_tm >= cnvtdatetime(conmeddttm)) OR (o.projected_stop_dt_tm=null)) )
   JOIN (od
   WHERE od.order_id=o.order_id)
  ORDER BY o.order_id, od.oe_field_meaning
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   med_disp = "", strength = "", strength_unit = "",
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->conmeds,(cnt+ 9))
   ENDIF
   med_disp = o.hna_order_mnemonic, reply->conmeds[cnt].med_start_dt_tm = o.current_start_dt_tm
   IF (o.projected_stop_dt_tm <= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->conmeds[cnt].med_end_dt_tm = o.projected_stop_dt_tm, reply->conmeds[cnt].med_end_val = 0
   ELSE
    reply->conmeds[cnt].med_end_val = 1
   ENDIF
   reply->conmeds[cnt].order_id = o.order_id
  DETAIL
   CASE (od.oe_field_meaning)
    OF "STRENGTHDOSE":
     strength = trim(od.oe_field_display_value)
    OF "STRENGTHDOSEUNIT":
     strength_unit = trim(od.oe_field_display_value)
   ENDCASE
  FOOT  o.group_order_id
   reply->conmeds[cnt].med_name = med_disp, reply->conmeds[cnt].med_dose = trim(strength), reply->
   conmeds[cnt].med_dose_unit = trim(strength_unit)
  FOOT REPORT
   stat = alterlist(reply->conmeds,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failedind = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SUBROUTINE severityvalue(sev_cd)
   DECLARE sev_cdf = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE sev_flag = i2 WITH protect, noconstant(0)
   SET sev_cdf = uar_get_code_meaning(sev_cd)
   CALL echo(build("sev_cdf :",sev_cdf))
   IF (((sev_cdf="1") OR (((sev_cdf="I") OR (((sev_cdf="LOW") OR (sev_cdf="MILD")) )) )) )
    SET sev_flag = 1
   ELSEIF (((sev_cdf="2") OR (((sev_cdf="II") OR (((sev_cdf="MEDIUM") OR (sev_cdf="MODERATE")) )) ))
   )
    SET sev_flag = 2
   ELSEIF (((sev_cdf="3") OR (((sev_cdf="4") OR (((sev_cdf="HIGH") OR (((sev_cdf="III") OR (((sev_cdf
   ="IV") OR (((sev_cdf="SEVERE") OR (sev_cdf="V")) )) )) )) )) )) )
    SET sev_flag = 3
   ENDIF
   RETURN(sev_flag)
 END ;Subroutine
#exit_script
 IF (failedind="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "September 15, 2010"
END GO
