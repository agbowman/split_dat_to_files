CREATE PROGRAM bhs_rpt_fn_down_tareportjrw:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "select a patient" = 0
  WITH outdev, f_name
 SET esi_acuity = uar_get_code_by("displaykey",72,"EDTRACKINGACUITY")
 SET stated_complaint = uar_get_code_by("displaykey",72,"STATEDCOMPLAINT")
 SET duration_onset = uar_get_code_by("displaykey",72,"DURATIONONSET")
 SET duration_sysmtoms = uar_get_code_by("displaykey",72,"DURATIONOFSYMPTOMS")
 SET comm_barriers = 885518.00
 SET language_spoken = uar_get_code_by("displaykey",72,"LANGUAGESPOKENV001")
 SET temperature = uar_get_code_by("displaykey",72,"TEMPERATURE")
 SET temperature_route = uar_get_code_by("displaykey",72,"TEMPERATUREROUTE")
 SET pulse_rate = uar_get_code_by("displaykey",72,"PULSERATE")
 SET respiratory_rate = uar_get_code_by("displaykey",72,"RESPIRATORYRATE")
 SET oxygen_satur = uar_get_code_by("displaykey",72,"OXYGENSATURATION")
 SET l_p_min = uar_get_code_by("displaykey",72,"LITERSPERMINUTE")
 SET mode_of_deli = uar_get_code_by("displaykey",72,"MODEOFDELIVERYOXYGEN")
 SET systolic_blood_p = uar_get_code_by("displaykey",72,"SYSTOLICBLOODPRESSURE")
 SET diastolic_blood_p = uar_get_code_by("displaykey",72,"DIASTOLICBLOODPRESSURE")
 SET blood_p_sites = uar_get_code_by("displaykey",72,"BLOODPRESSURESITES")
 SET weight = uar_get_code_by("displaykey",72,"WEIGHT")
 SET pmh = uar_get_code_by("displaykey",72,"PMH")
 SET pat_arr_amb = uar_get_code_by("displaykey",72,"ARRIVEDBYAMBULANCE")
 SET initial_treat = uar_get_code_by("displaykey",72,"INITIALTREATMENTSED")
 SET acetaminophen_dose_route = uar_get_code_by("displaykey",72,"ACETAMINIPHENDOSEROUTE")
 SET emla_dose_route = uar_get_code_by("displaykey",72,"EMLADOSEROUTE")
 SET ibuprofen_dose_r = uar_get_code_by("displaykey",72,"IBUPROFENDOSEROUTE")
 SET let_dose_r = uar_get_code_by("displaykey",72,"LETDOSEROUTE")
 SET porparicaine_dose_r = uar_get_code_by("displaykey",72,"PROPARICAINEDOSEROUTE")
 SET ambulatroy_o_scen = uar_get_code_by("displaykey",72,"AMBULATORYONSCENE")
 SET pt_on_b_w_cerv_collar = uar_get_code_by("displaykey",72,"PTONBACKBOARDWITHCERVICALCOLLAR")
 SET c_sp_his_powergrid = uar_get_code_by("displaykey",72,"CSPINEHISTORYGRID")
 SET c_sp_clin_cleared = uar_get_code_by("displaykey",72,"CSPINECLINICALLYCLEARED")
 SET c_sp_phy_exam_pg = uar_get_code_by("displaykey",72,"CSPINEPHYSICALEXAM")
 SET c_sp_clin_cleared = uar_get_code_by("displaykey",72,"CSPINECLINICALLYCLEARED")
 SET c_sp_cleared_by = uar_get_code_by("displaykey",72,"CSPINECLEAREDBY")
 SET pat_clear_f_triage = uar_get_code_by("displaykey",72,"PATIENTCLEAREDFORTRIAGE")
 SET ed_add_info = uar_get_code_by("displaykey",72,"EDADDITIONALINFORMATION")
 SET neck_pain = uar_get_code_by("displaykey",72,"NECKPAIN")
 SET extremity_weakness = uar_get_code_by("displaykey",72,"EXTREMITYWEAKNESS")
 SET parasthesia = uar_get_code_by("displaykey",72,"PARASTHESIAORNUMBNESS")
 SET hx_loss = uar_get_code_by("displaykey",72,"HXLOSSOFCONSCIOUSNESS")
 SET pt_has_distracting = uar_get_code_by("displaykey",72,"PTHASDISTRACTINGINJURY")
 SET mental_status = uar_get_code_by("displaykey",72,"MENTALSTATUSCHANGE")
 SET neurological_deficit = uar_get_code_by("displaykey",72,"NEUROLOGICALDEFICIT")
 SET distracting_pain = uar_get_code_by("displaykey",72,"DISTRACTINGPAINFULINJURY")
 SET tenderness_on_neck = uar_get_code_by("displaykey",72,"TENDERNESSONNECKPALPATION")
 SET palpable_defor = uar_get_code_by("displaykey",72,"PALPABLEDEFORMITY")
 SET pain_tenderness = uar_get_code_by("displaykey",72,"PAINTENDERNESSONPALPATION")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET mod_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET alter_cd = uar_get_code_by("MEANING",8,"ALTERED")
 SET operation = 0
 DECLARE active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
 DECLARE proposed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"PROPOSED"))
 DECLARE it_cnt = i2
 DECLARE ac_cnt = i2
 DECLARE em_cnt = i2
 DECLARE ib_cnt = i2
 DECLARE let_cnt = i2
 DECLARE por_cnt = i2
 DECLARE l_cnt = i2
 DECLARE tmp_remove = vc
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD pat(
   1 pat_name = vc
   1 pat_p_id = f8
   1 pat_dob = vc
   1 pat_age = vc
   1 pat_encnt = f8
   1 allergy_cnt = i2
   1 allergy[*]
     2 alergy_info = vc
   1 esi_acuity_val = vc
   1 stated_complaint_val = vc
   1 dt_tm_charted = vc
   1 duration_onset_val = vc
   1 duration_sysmtoms_val = vc
   1 comm_barriers = vc
   1 language_spoken = vc
   1 pat_mrn = vc
   1 pat_fn = vc
   1 pat_info[*]
     2 pat_type = f8
   1 temperature_cnt = i2
   1 temp_dt_tm = dq8
   1 temperature_f_result_val = vc
   1 temperature_l_result_val = vc
   1 temp_route_dt_tm = dq8
   1 tempature_route_f_result_val = vc
   1 tempature_route_l_result_val = vc
   1 pulse_dt_tm = dq8
   1 pulse_rate_f_val = vc
   1 pulse_rate_l_val = vc
   1 resp_dt_tm = dq8
   1 respiratory_rate_f_val = vc
   1 respiratory_rate_l_val = vc
   1 oxygen_dt_tm = dq8
   1 oxygen_satur_f_val = vc
   1 oxygen_satur_l_val = vc
   1 l_dt_tm = dq8
   1 l_p_min_f_val = vc
   1 l_p_min_l_val = vc
   1 mode_dt_tm = dq8
   1 mode_of_deli_f_val = vc
   1 mode_of_deli_l_val = vc
   1 sys_blood_dt_tm = dq8
   1 systolic_blood_p_f_val = vc
   1 systolic_blood_p_l_val = vc
   1 diastolic_dt_tm = dq8
   1 diastolic_blood_p_f_val = vc
   1 diastolic_blood_p_l_val = vc
   1 blood_dt_tm = dq8
   1 blood_p_sites_f_val = vc
   1 blood_p_sites_l_val = vc
   1 weight_val = vc
   1 pmh_val = vc
   1 pat_arr_amb_val = vc
   1 ambulatroy_o_scen_val = vc
   1 pt_on_b_w_cerv_collar_val = vc
   1 c_sp_his_powergrid_val = vc
   1 c_sp_phy_exam_pg_val = vc
   1 c_sp_clin_cleared_val = vc
   1 c_sp_cleared_by_val = vc
   1 pat_clear_f_triage_val = vc
   1 ed_add_info_val = vc
   1 no_data = vc
   1 initial_treatment_cnt = i2
   1 initial_treatment[*]
     2 dta_cd = f8
     2 result_val = vc
     2 display[*]
       3 display_line = vc
     2 dta_dt_tm = vc
   1 acetaminophen_dose_route_cnt = i2
   1 acetaminophen_dose_route[*]
     2 dta_cd = f8
     2 result_val = vc
     2 display[*]
       3 display_line = vc
     2 dta_dt_tm = vc
   1 emla_dose_route_cnt = i2
   1 emla_dose_rout[*]
     2 dta_cd = f8
     2 result_val = vc
     2 dta_dt_tm = vc
   1 ibuprofen_dose_route_cnt = i2
   1 ibuprofen_dose_route[*]
     2 dta_cd = f8
     2 result_val = vc
     2 dta_dt_tm = vc
   1 let_dose_route_cnt = i2
   1 let_dose_route[*]
     2 dta_cd = f8
     2 result_val = vc
     2 dta_dt_tm = vc
   1 porparicaine_dose_route_cnt = i2
   1 porparicaine_dose_route[*]
     2 dta_cd = f8
     2 result_val = vc
     2 dta_dt_tm = vc
   1 neck_pain_val = vc
   1 extremity_weakness_val = vc
   1 parasthesia_val = vc
   1 hx_loss_val = vc
   1 pt_has_distracting_val = vc
   1 mental_status_val = vc
   1 neurological_deficit_val = vc
   1 distracting_pain_val = vc
   1 tenderness_on_neck_val = vc
   1 palpable_defor_val = vc
   1 pain_tenderness_val = vc
 )
 RECORD loc(
   1 opjob_ind = i2
   1 nurse_unit = vc
   1 unit_cd = f8
   1 encounter_cnt = i2
   1 encounter_info[*]
     2 encounter_id = f8
     2 file_name = vc
 )
 IF (validate(request->batch_selection))
  SET operation = 1
  SET loc->nurse_unit = trim( $2,3)
 ELSE
  SET operation = 0
 ENDIF
 IF (operation=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.display_key=loc->nurse_unit)
     AND cv.code_set=220
     AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
     AND cv.active_ind=1)
   DETAIL
    loc->unit_cd = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   ed.encntr_id, p.person_id
   FROM person p,
    encntr_domain ed
   PLAN (ed
    WHERE (ed.loc_nurse_unit_cd=loc->unit_cd)
     AND ((ed.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
    JOIN (p
    WHERE ed.person_id=p.person_id)
   DETAIL
    l_cnt = (l_cnt+ 1), loc->encounter_cnt = l_cnt, stat = alterlist(loc->encounter_info,loc->
     encounter_cnt),
    loc->encounter_info[l_cnt].file_name = build(trim(substring(1,14,trim(cnvtlower(cnvtalphanum(p
          .name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p
          .name_first_key,2)),4)),3),".ps"), loc->encounter_info[l_cnt].encounter_id = ed.encntr_id
   WITH nocounter
  ;end select
  FOR (li = 1 TO loc->encounter_cnt)
    SET pat->pat_encnt = loc->encounter_info[li].encounter_id
    SELECT INTO "nl:"
     FROM person p,
      encntr_domain ed,
      encntr_alias ea
     PLAN (ed
      WHERE (ed.encntr_id=pat->pat_encnt)
       AND ((ed.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
      JOIN (p
      WHERE p.person_id=ed.person_id)
      JOIN (ea
      WHERE ea.encntr_id=ed.encntr_id
       AND ((ea.encntr_alias_type_cd+ 0) IN (fin_cd, mrn_cd))
       AND ea.end_effective_dt_tm > sysdate
       AND ea.active_ind=1)
     DETAIL
      pat->pat_name = p.name_full_formatted, pat->pat_encnt = ed.encntr_id, pat->pat_p_id = ed
      .person_id,
      pat->pat_age = cnvtage(p.birth_dt_tm), pat->pat_dob = format(p.birth_dt_tm,"MM/DD/YY ;;;;;D")
      IF (ea.encntr_alias_type_cd=fin_cd)
       pat->pat_fn = ea.alias
      ELSEIF (ea.encntr_alias_type_cd=mrn_cd)
       pat->pat_mrn = ea.alias
      ENDIF
     WITH nocounter
    ;end select
    IF ((pat->pat_encnt < 1))
     GO TO exit_program
    ENDIF
    SELECT INTO "nl:"
     FROM encounter e,
      allergy a,
      nomenclature n
     PLAN (e
      WHERE (e.encntr_id=pat->pat_encnt))
      JOIN (a
      WHERE a.person_id=e.person_id
       AND ((a.active_ind+ 0)=1)
       AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
       AND a.reaction_status_cd IN (active, proposed))
      JOIN (n
      WHERE n.nomenclature_id=a.substance_nom_id)
     HEAD REPORT
      a_cnt = 0
     HEAD a.allergy_instance_id
      a_cnt = (a_cnt+ 1), pat->allergy_cnt = a_cnt, stat = alterlist(pat->allergy,a_cnt),
      pat->allergy[a_cnt].alergy_info = n.source_string
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ce.event_cd, ce.result_val
     FROM clinical_event ce
     WHERE (ce.encntr_id=pat->pat_encnt)
      AND ce.result_status_cd IN (25.00, 34.00, 35.00)
      AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
      AND ((ce.event_cd+ 0) IN (esi_acuity, stated_complaint, duration_onset, duration_sysmtoms,
     comm_barriers,
     language_spoken, temperature, temperature_route, pulse_rate, respiratory_rate,
     oxygen_satur, l_p_min, mode_of_deli, systolic_blood_p, diastolic_blood_p,
     blood_p_sites, weight, pat_arr_amb, pmh, initial_treat,
     acetaminophen_dose_route, emla_dose_route, ibuprofen_dose_r, let_dose_r, ambulatroy_o_scen,
     porparicaine_dose_r, pt_on_b_w_cerv_collar, c_sp_his_powergrid, c_sp_phy_exam_pg,
     c_sp_clin_cleared,
     c_sp_cleared_by, pat_clear_f_triage))
     ORDER BY ce.clinsig_updt_dt_tm DESC
     HEAD REPORT
      it_cnt = 0, ac_cnt = 0, em_cnt = 0,
      ib_cnt = 0, let_cnt = 0, por_cnt = 0
     HEAD ce.event_cd
      IF (ce.event_cd=temperature)
       pat->temp_dt_tm = ce.event_end_dt_tm, pat->temperature_f_result_val = build2(trim(ce
         .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=temperature_route)
       pat->temp_route_dt_tm = ce.event_end_dt_tm, pat->tempature_route_f_result_val = build2(trim(ce
         .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pulse_rate)
       pat->pulse_dt_tm = ce.event_end_dt_tm, pat->pulse_rate_f_val = build2(trim(ce.result_val),
        "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=respiratory_rate)
       pat->resp_dt_tm = ce.event_end_dt_tm, pat->respiratory_rate_f_val = build2(trim(ce.result_val),
        "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=oxygen_satur)
       pat->oxygen_dt_tm = ce.event_end_dt_tm, pat->oxygen_satur_f_val = build2(trim(ce.result_val),
        "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=l_p_min)
       pat->l_dt_tm = ce.event_end_dt_tm, pat->l_p_min_f_val = build2(trim(ce.result_val),"     (",
        format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=mode_of_deli)
       pat->mode_dt_tm = ce.event_end_dt_tm, pat->mode_of_deli_f_val = build2(trim(ce.result_val),
        "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=systolic_blood_p)
       pat->sys_blood_dt_tm = ce.event_end_dt_tm, pat->systolic_blood_p_f_val = build2(trim(ce
         .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=diastolic_blood_p)
       pat->diastolic_dt_tm = ce.event_end_dt_tm, pat->diastolic_blood_p_f_val = build2(trim(ce
         .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=blood_p_sites)
       pat->blood_dt_tm = ce.event_end_dt_tm, pat->blood_p_sites_f_val = build2(trim(ce.result_val),
        "    (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")")
      ENDIF
     DETAIL
      IF (ce.event_cd=initial_treat)
       it_cnt = (it_cnt+ 1), pat->initial_treatment_cnt = it_cnt, stat = alterlist(pat->
        initial_treatment,it_cnt),
       pat->initial_treatment[it_cnt].dta_cd = ce.event_id, pat->initial_treatment[it_cnt].result_val
        = trim(ce.result_val), pat->initial_treatment[it_cnt].dta_dt_tm = format(ce.event_end_dt_tm,
        "MM/DD/YY HH:MM;;;D")
      ELSEIF (ce.event_cd=acetaminophen_dose_route)
       ac_cnt = (pat->acetaminophen_dose_route_cnt+ 1), pat->acetaminophen_dose_route_cnt = ac_cnt,
       stat = alterlist(pat->acetaminophen_dose_route,ac_cnt),
       pat->acetaminophen_dose_route[ac_cnt].dta_cd = ce.event_id, pat->acetaminophen_dose_route[
       ac_cnt].result_val = trim(ce.result_val), pat->acetaminophen_dose_route[ac_cnt].dta_dt_tm =
       format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
      ELSEIF (ce.event_cd=emla_dose_route)
       em_cnt = (em_cnt+ 1), pat->emla_dose_route_cnt = em_cnt, stat = alterlist(pat->emla_dose_rout,
        em_cnt),
       pat->emla_dose_rout[em_cnt].result_val = trim(ce.result_val), pat->emla_dose_rout[em_cnt].
       dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
      ELSEIF (ce.event_cd=ibuprofen_dose_r)
       ib_cnt = (ib_cnt+ 1), pat->ibuprofen_dose_route_cnt = ib_cnt, stat = alterlist(pat->
        ibuprofen_dose_route,ib_cnt),
       pat->ibuprofen_dose_route[ib_cnt].result_val = trim(ce.result_val), pat->ibuprofen_dose_route[
       ib_cnt].dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
      ELSEIF (ce.event_cd=let_dose_r)
       let_cnt = (let_cnt+ 1), pat->let_dose_route_cnt = let_cnt, stat = alterlist(pat->
        let_dose_route,let_cnt),
       pat->let_dose_route[let_cnt].result_val = trim(ce.result_val), pat->let_dose_route[let_cnt].
       dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
      ELSEIF (ce.event_cd=porparicaine_dose_r)
       por_cnt = (por_cnt+ 1), pat->porparicaine_dose_route_cnt = por_cnt, stat = alterlist(pat->
        porparicaine_dose_route,por_cnt),
       pat->porparicaine_dose_route[por_cnt].result_val = trim(ce.result_val), pat->
       porparicaine_dose_route[por_cnt].dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
      ENDIF
     WITH nocounter
    ;end select
    CALL echorecord(pat)
    FOR (x = 1 TO size(pat->initial_treatment,5))
      SET pt->line_cnt = 0
      SET max_length = 150
      SET cnt = 0
      SET line_cnt = 0
      SET tempstring = fillstring(500,"")
      SET tempstring = build2(trim(pat->initial_treatment[x].result_val)," (",pat->initial_treatment[
       x].dta_dt_tm,")")
      EXECUTE dcp_parse_text value(tempstring), value(max_length)
      SET stat = alterlist(pat->initial_treatment[x].display,pt->line_cnt)
      FOR (line_cnt = 1 TO pt->line_cnt)
       SET cnt = (cnt+ 1)
       SET pat->initial_treatment[x].display[line_cnt].display_line = trim(pt->lns[line_cnt].line)
      ENDFOR
    ENDFOR
    CALL echorecord(pat)
    SELECT INTO "nl:"
     ce.event_cd, ce.result_val
     FROM clinical_event ce
     WHERE (ce.encntr_id=pat->pat_encnt)
      AND ce.result_status_cd IN (25.00, 34.00, 35.00)
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ((ce.event_cd+ 0) IN (esi_acuity, stated_complaint, duration_onset, duration_sysmtoms,
     comm_barriers,
     language_spoken, temperature, temperature_route, pulse_rate, respiratory_rate,
     oxygen_satur, l_p_min, mode_of_deli, systolic_blood_p, diastolic_blood_p,
     blood_p_sites, weight, pat_arr_amb, pmh, initial_treat,
     acetaminophen_dose_route, emla_dose_route, ibuprofen_dose_r, let_dose_r, ambulatroy_o_scen,
     porparicaine_dose_r, pt_on_b_w_cerv_collar, c_sp_his_powergrid, c_sp_phy_exam_pg,
     c_sp_clin_cleared,
     c_sp_cleared_by, pat_clear_f_triage, extremity_weakness, parasthesia, hx_loss,
     pt_has_distracting, mental_status, neurological_deficit, distracting_pain, tenderness_on_neck,
     palpable_defor, pain_tenderness))
     ORDER BY ce.clinsig_updt_dt_tm
     HEAD ce.event_cd
      IF (ce.event_cd=esi_acuity)
       pat->esi_acuity_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=stated_complaint)
       pat->stated_complaint_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=duration_onset)
       pat->duration_onset_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=duration_sysmtoms)
       pat->duration_sysmtoms_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=comm_barriers)
       pat->comm_barriers = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=language_spoken)
       pat->language_spoken = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=temperature
       AND (pat->temp_dt_tm != ce.event_end_dt_tm))
       pat->temperature_l_result_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=temperature_route
       AND (pat->temp_route_dt_tm != ce.event_end_dt_tm))
       pat->tempature_route_l_result_val = build2(trim(ce.result_val),"     (",format(ce
         .event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pulse_rate
       AND (pat->pulse_dt_tm != ce.event_end_dt_tm))
       pat->pulse_rate_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=respiratory_rate
       AND (pat->resp_dt_tm != ce.event_end_dt_tm))
       pat->respiratory_rate_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=oxygen_satur
       AND (pat->oxygen_dt_tm != ce.event_end_dt_tm))
       pat->oxygen_satur_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=l_p_min
       AND (pat->l_dt_tm != ce.event_end_dt_tm))
       pat->l_p_min_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=mode_of_deli
       AND (pat->mode_dt_tm != ce.event_end_dt_tm))
       pat->mode_of_deli_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=systolic_blood_p
       AND (pat->sys_blood_dt_tm != ce.event_end_dt_tm))
       pat->systolic_blood_p_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=diastolic_blood_p
       AND (pat->diastolic_dt_tm != ce.event_end_dt_tm))
       pat->diastolic_blood_p_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=blood_p_sites
       AND (pat->blood_dt_tm != ce.event_end_dt_tm))
       pat->blood_p_sites_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=weight)
       pat->weight_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pat_arr_amb)
       pat->pat_arr_amb_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pmh)
       pat->pmh_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=ambulatroy_o_scen)
       pat->ambulatroy_o_scen_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pt_on_b_w_cerv_collar)
       pat->pt_on_b_w_cerv_collar_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=c_sp_his_powergrid)
       pat->c_sp_his_powergrid_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=c_sp_phy_exam_pg)
       pat->c_sp_phy_exam_pg_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=c_sp_clin_cleared)
       pat->c_sp_clin_cleared_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=c_sp_cleared_by)
       pat->c_sp_cleared_by_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pat_clear_f_triage)
       pat->pat_clear_f_triage_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=neck_pain)
       pat->neck_pain_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=extremity_weakness)
       pat->extremity_weakness_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=parasthesia)
       pat->parasthesia_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=hx_loss)
       pat->hx_loss_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pt_has_distracting)
       pat->pt_has_distracting_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=mental_status)
       pat->mental_status_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=neurological_deficit)
       pat->neurological_deficit_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=distracting_pain)
       pat->distracting_pain_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=tenderness_on_neck)
       pat->tenderness_on_neck_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=palpable_defor)
       pat->palpable_defor_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ELSEIF (ce.event_cd=pain_tenderness)
       pat->pain_tenderness_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
         "MM/DD/YY HH:MM;;;D")," ) ")
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO value(loc->encounter_info[li].file_name)
     FROM dummyt d
     PLAN (d)
     HEAD REPORT
      y_break = 40, y_pos = 18, x_pos = 20,
      y = (y_pos+ 10), a_cnt = 0, no_data = null,
      xd = 20, b = "{B}", eb = "{ENDB}",
      printpsheader = 0, col 0, "{PS/792 0 }",
      row + 1
     HEAD PAGE
      row + 1,
      CALL print(calcpos(225,20)), "{F/5}{CPI/10}{U}",
      "FirstNet Triage / Assessment Report", "{endu}", row + 1,
      CALL print(calcpos(20,30)), "{F/4}{CPI/14}", b,
      "Patient Name: ", eb, pat->pat_name,
      row + 1,
      CALL print(calcpos(400,30)), b,
      "Date & Time: ", eb, curdate,
      " ", curtime, row + 1,
      CALL print(calcpos(20,40)), b, "DOB: ",
      eb, pat->pat_dob, "( Age ",
      pat->pat_age, " )", row + 1,
      CALL print(calcpos(170,40)), b, "ACCT # : ",
      eb, pat->pat_fn, row + 1,
      CALL print(calcpos(320,40)), b, "MRN :",
      eb, pat->pat_mrn, y_pos = (y_pos+ 10)
     HEAD d.seq
      x_pos = 20, y_pos = 50,
      CALL print(calcpos(x_pos,y_pos)),
      b, "Allergy : ", eb,
      y_pos = (y_pos+ 10)
      IF ((pat->allergy_cnt=0))
       CALL print(calcpos(x_pos,y_pos)), "No Allergy Information Documented ", y_pos = (y_pos+ 10)
      ELSE
       FOR (i = 1 TO pat->allergy_cnt)
         CALL print(calcpos(x_pos,y_pos)), pat->allergy[i].alergy_info, y_pos = (y_pos+ 10),
         row + 1
       ENDFOR
      ENDIF
     DETAIL
      IF ((pat->esi_acuity_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "ESI/Acuity: ", eb,
       pat->esi_acuity_val
      ENDIF
      IF ((pat->stated_complaint_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Stated Complaint: ", eb,
       pat->stated_complaint_val
      ENDIF
      IF ((pat->duration_onset_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Duration Onset: ", eb,
       pat->duration_onset_val
      ENDIF
      IF ((pat->duration_sysmtoms_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Duration Symptoms: ", eb,
       pat->duration_sysmtoms_val
      ENDIF
      IF ((pat->comm_barriers=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Communication Barrier : ", eb,
       pat->comm_barriers
      ENDIF
      IF ((pat->language_spoken=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Language Spoken: ", eb,
       pat->language_spoken
      ENDIF
      IF ((pat->pat_arr_amb_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Patient Arrived By Ambulance: ", eb,
       pat->pat_arr_amb_val
      ENDIF
      IF ((pat->weight_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Weight: ", eb,
       pat->weight_val
      ENDIF
      IF ((pat->pmh_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "PMH:", eb,
       pat->pmh_val
      ENDIF
      IF ((pat->temperature_f_result_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Temp: ", eb,
       pat->temperature_f_result_val, " ", pat->temperature_l_result_val
      ENDIF
      IF ((pat->tempature_route_f_result_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Temp Route: ", eb,
       pat->tempature_route_f_result_val, " ", pat->tempature_route_l_result_val
      ENDIF
      IF ((pat->pulse_rate_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Pulse Rate: ", eb,
       pat->pulse_rate_f_val, " ", pat->pulse_rate_l_val
      ENDIF
      IF ((pat->respiratory_rate_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Resp Rate: ", eb,
       pat->respiratory_rate_f_val, " ", pat->respiratory_rate_l_val
      ENDIF
      IF ((pat->oxygen_satur_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Oxygen Saturation: ", eb,
       pat->oxygen_satur_f_val, " ", pat->oxygen_satur_l_val
      ENDIF
      IF ((pat->l_p_min_l_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Liters per Minute: ", eb,
       pat->l_p_min_f_val, " ", pat->l_p_min_l_val
      ENDIF
      IF ((pat->mode_of_deli_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Mode of Delivery (Oxygen): ", eb,
       pat->mode_of_deli_f_val, " ", pat->mode_of_deli_l_val
      ENDIF
      IF ((pat->systolic_blood_p_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Systolic Blood Pressure: ", eb,
       pat->systolic_blood_p_f_val, " ", pat->systolic_blood_p_l_val
      ENDIF
      IF ((pat->diastolic_blood_p_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Diastolic Blood Pressure: ", eb,
       pat->diastolic_blood_p_f_val, " ", pat->diastolic_blood_p_l_val
      ENDIF
      IF ((pat->blood_p_sites_f_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Blood pressure sites: ", eb,
       pat->blood_p_sites_f_val, " ", pat->blood_p_sites_l_val
      ENDIF
      IF ((pat->initial_treatment_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Inital Treatment (ED):", eb
       FOR (ai = 1 TO pat->initial_treatment_cnt)
         FOR (ar = 1 TO size(pat->initial_treatment[ai].display,5))
           y_pos = (y_pos+ 10)
           IF (y_pos > 550)
            BREAK, y_pos = 50, x_pos = 18
           ENDIF
           CALL print(calcpos((x_pos+ xd),y_pos)),
           CALL print(build2(pat->initial_treatment[ai].display[ar].display_line)), row + 1
         ENDFOR
       ENDFOR
      ENDIF
      IF ((pat->acetaminophen_dose_route_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Acetaminophen Dose Route: ", eb
       FOR (ci = 1 TO pat->acetaminophen_dose_route_cnt)
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18
         ENDIF
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->acetaminophen_dose_route[ci].result_val," (",pat->
          acetaminophen_dose_route[ci].dta_dt_tm,")")), row + 1
       ENDFOR
      ENDIF
      IF ((pat->emla_dose_route_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "EMLA Dose Route : ", eb
       FOR (di = 1 TO pat->emla_dose_route_cnt)
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18
         ENDIF
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->emla_dose_rout[di].result_val," (",pat->emla_dose_rout[di].dta_dt_tm,
          ")")), row + 1
       ENDFOR
      ENDIF
      IF ((pat->ibuprofen_dose_route_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Ibuprofen Dose Route : ", eb
       FOR (ei = 1 TO pat->ibuprofen_dose_route_cnt)
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18
         ENDIF
         row + 1,
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->ibuprofen_dose_route[ei].result_val," (",pat->ibuprofen_dose_route[ei
          ].dta_dt_tm,")")),
         row + 1
       ENDFOR
      ENDIF
      IF ((pat->let_dose_route_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "LET Dose Route : ", eb
       FOR (fi = 1 TO pat->let_dose_route_cnt)
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18,
          "page con"
         ENDIF
         row + 1,
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->let_dose_route[fi].result_val," (",pat->let_dose_route[fi].dta_dt_tm,
          ")")),
         row + 1
       ENDFOR
      ENDIF
      IF ((pat->porparicaine_dose_route_cnt=0))
       no_data
      ELSE
       y_pos = (y_pos+ 10), row + 1,
       CALL print(calcpos(x_pos,y_pos)),
       b, "Proparicaine Dose Route: ", eb
       FOR (gi = 1 TO pat->porparicaine_dose_route_cnt)
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18
         ENDIF
         row + 1,
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->porparicaine_dose_route[gi].result_val," (",pat->
          porparicaine_dose_route[gi].dta_dt_tm,")")),
         row + 1
       ENDFOR
      ENDIF
      IF ((pat->ambulatroy_o_scen_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "Ambulatory On Scene: ", eb, pat->ambulatroy_o_scen_val
      ENDIF
      IF ((pat->pt_on_b_w_cerv_collar_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "Pt. on Backboard W/ Cervical Collar:", eb, pat->pt_on_b_w_cerv_collar_val
      ENDIF
      IF ((pat->c_sp_his_powergrid_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "C-Spine History Powergrid: ", eb, pat->c_sp_his_powergrid_val
      ENDIF
      IF ((pat->neck_pain_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Neck Pain:",
       pat->neck_pain_val
      ENDIF
      IF ((pat->extremity_weakness_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Extremity Weakness: ",
       pat->extremity_weakness_val
      ENDIF
      IF ((pat->parasthesia_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Parasthesia Or Numbness:",
       pat->parasthesia_val
      ENDIF
      IF ((pat->hx_loss_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Hx. Loss of Consciousness:",
       pat->hx_loss_val
      ENDIF
      IF ((pat->pt_has_distracting_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Pt.Has Distracting Injury: ",
       pat->pt_has_distracting_val
      ENDIF
      IF ((pat->c_sp_phy_exam_pg_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "C-Spine Physical Exam powergrid: ", eb, pat->c_sp_phy_exam_pg_val
      ENDIF
      IF ((pat->mental_status_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Mental Status Change:",
       pat->mental_status_val
      ENDIF
      IF ((pat->neurological_deficit_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Neurological Deficit:",
       pat->neurological_deficit_val
      ENDIF
      IF ((pat->distracting_pain_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Distracting Painful Injury:",
       pat->distracting_pain_val
      ENDIF
      IF ((pat->tenderness_on_neck_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Tenderness On Neck Palpation:",
       pat->tenderness_on_neck_val
      ENDIF
      IF ((pat->palpable_defor_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Palpable Deformity:",
       pat->palpable_defor_val
      ENDIF
      IF ((pat->pain_tenderness_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)), "Pain/Tenderness on Palpation:",
       pat->pain_tenderness_val
      ENDIF
      IF ((pat->c_sp_clin_cleared_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "C-spine Clinically Cleared: ", eb, pat->c_sp_clin_cleared_val
      ENDIF
      IF ((pat->c_sp_cleared_by_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "C-spine Cleared by: ", eb, pat->c_sp_cleared_by_val
      ENDIF
      IF ((pat->pat_clear_f_triage_val=null))
       no_data
      ELSE
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos(x_pos,y_pos)), b,
       "Patient Cleared for Triage: ", eb, pat->pat_clear_f_triage_val
      ENDIF
     FOOT REPORT
      y_pos = (y_pos+ 20), x_pos = (x_pos+ 100), row + 1,
      CALL print(calcpos(x_pos,y_pos)), b, "End Of The Report",
      eb
     FOOT PAGE
      y_pos = (y_pos+ 20), x_pos = (x_pos+ 50), row + 1,
      CALL print(calcpos(x_pos,y_pos)), b,
"***  Report does not include any EMS information and includes only select information from Triage/Assessment/Reassessment \
***\
", eb, y_pos = (y_pos+ 20), x_pos = (x_pos+ 50),
      row + 1,
      CALL print(calcpos(225,y_pos)), b,
      "Page#:", curpage, eb
     WITH dio = 08, time = 30, maxcol = 500
    ;end select
    SET spool value(loc->encounter_info[li].file_name)  $OUTDEV
    SET tmp_remove = build2('set stat = remove("',loc->encounter_info[li].file_name,'") go')
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
  ENDFOR
 ENDIF
 IF (operation=0)
  SELECT INTO "nl:"
   ed.encntr_id, p.person_id
   FROM person p,
    encntr_domain ed,
    encntr_alias ea
   PLAN (ed
    WHERE (ed.encntr_id= $F_NAME)
     AND ((ed.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
    JOIN (p
    WHERE p.person_id=ed.person_id)
    JOIN (ea
    WHERE ea.encntr_id=ed.encntr_id
     AND ((ea.encntr_alias_type_cd+ 0) IN (fin_cd, mrn_cd))
     AND ea.end_effective_dt_tm > sysdate
     AND ea.active_ind=1)
   ORDER BY p.person_id
   DETAIL
    pat->pat_name = p.name_full_formatted, pat->pat_encnt = ed.encntr_id, pat->pat_p_id = ed
    .person_id,
    pat->pat_age = cnvtage(p.birth_dt_tm), pat->pat_dob = format(p.birth_dt_tm,"MM/DD/YY ;;;;;D")
    IF (ea.encntr_alias_type_cd=fin_cd)
     pat->pat_fn = ea.alias
    ELSEIF (ea.encntr_alias_type_cd=mrn_cd)
     pat->pat_mrn = ea.alias
    ENDIF
   WITH nocounter
  ;end select
  IF ((pat->pat_encnt < 1))
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM encounter e,
    allergy a,
    nomenclature n
   PLAN (e
    WHERE (e.encntr_id=pat->pat_encnt))
    JOIN (a
    WHERE a.person_id=e.person_id
     AND ((a.active_ind+ 0)=1)
     AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
     AND a.reaction_status_cd IN (active, proposed))
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id)
   HEAD REPORT
    a_cnt = 0
   HEAD a.allergy_instance_id
    a_cnt = (a_cnt+ 1), pat->allergy_cnt = a_cnt, stat = alterlist(pat->allergy,a_cnt),
    pat->allergy[a_cnt].alergy_info = n.source_string
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ce.event_cd, ce.result_val
   FROM clinical_event ce
   WHERE (ce.encntr_id=pat->pat_encnt)
    AND ce.result_status_cd IN (25.00, 34.00, 35.00)
    AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
    AND ((ce.event_cd+ 0) IN (esi_acuity, stated_complaint, duration_onset, duration_sysmtoms,
   comm_barriers,
   language_spoken, temperature, temperature_route, pulse_rate, respiratory_rate,
   oxygen_satur, l_p_min, mode_of_deli, systolic_blood_p, diastolic_blood_p,
   blood_p_sites, weight, pat_arr_amb, pmh, initial_treat,
   acetaminophen_dose_route, emla_dose_route, ibuprofen_dose_r, let_dose_r, ambulatroy_o_scen,
   porparicaine_dose_r, pt_on_b_w_cerv_collar, c_sp_his_powergrid, c_sp_phy_exam_pg,
   c_sp_clin_cleared,
   c_sp_cleared_by, pat_clear_f_triage))
   ORDER BY ce.clinsig_updt_dt_tm DESC
   HEAD REPORT
    it_cnt = 0, ac_cnt = 0, em_cnt = 0,
    ib_cnt = 0, let_cnt = 0, por_cnt = 0
   HEAD ce.event_cd
    IF (ce.event_cd=temperature)
     pat->temp_dt_tm = ce.event_end_dt_tm, pat->temperature_f_result_val = build2(trim(ce.result_val),
      "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=temperature_route)
     pat->temp_route_dt_tm = ce.event_end_dt_tm, pat->tempature_route_f_result_val = build2(trim(ce
       .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pulse_rate)
     pat->pulse_dt_tm = ce.event_end_dt_tm, pat->pulse_rate_f_val = build2(trim(ce.result_val),
      "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=respiratory_rate)
     pat->resp_dt_tm = ce.event_end_dt_tm, pat->respiratory_rate_f_val = build2(trim(ce.result_val),
      "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=oxygen_satur)
     pat->oxygen_dt_tm = ce.event_end_dt_tm, pat->oxygen_satur_f_val = build2(trim(ce.result_val),
      "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=l_p_min)
     pat->l_dt_tm = ce.event_end_dt_tm, pat->l_p_min_f_val = build2(trim(ce.result_val),"     (",
      format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=mode_of_deli)
     pat->mode_dt_tm = ce.event_end_dt_tm, pat->mode_of_deli_f_val = build2(trim(ce.result_val),
      "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=systolic_blood_p)
     pat->sys_blood_dt_tm = ce.event_end_dt_tm, pat->systolic_blood_p_f_val = build2(trim(ce
       .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=diastolic_blood_p)
     pat->diastolic_dt_tm = ce.event_end_dt_tm, pat->diastolic_blood_p_f_val = build2(trim(ce
       .result_val),"     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=blood_p_sites)
     pat->blood_dt_tm = ce.event_end_dt_tm, pat->blood_p_sites_f_val = build2(trim(ce.result_val),
      "    (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")")
    ENDIF
   DETAIL
    IF (ce.event_cd=initial_treat)
     it_cnt = (it_cnt+ 1), pat->initial_treatment_cnt = it_cnt, stat = alterlist(pat->
      initial_treatment,it_cnt),
     pat->initial_treatment[it_cnt].dta_cd = ce.event_id, pat->initial_treatment[it_cnt].result_val
      = trim(ce.result_val), pat->initial_treatment[it_cnt].dta_dt_tm = format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")
    ELSEIF (ce.event_cd=acetaminophen_dose_route)
     ac_cnt = (pat->acetaminophen_dose_route_cnt+ 1), pat->acetaminophen_dose_route_cnt = ac_cnt,
     stat = alterlist(pat->acetaminophen_dose_route,ac_cnt),
     pat->acetaminophen_dose_route[ac_cnt].dta_cd = ce.event_id, pat->acetaminophen_dose_route[ac_cnt
     ].result_val = trim(ce.result_val), pat->acetaminophen_dose_route[ac_cnt].dta_dt_tm = format(ce
      .event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
    ELSEIF (ce.event_cd=emla_dose_route)
     em_cnt = (em_cnt+ 1), pat->emla_dose_route_cnt = em_cnt, stat = alterlist(pat->emla_dose_rout,
      em_cnt),
     pat->emla_dose_rout[em_cnt].result_val = trim(ce.result_val), pat->emla_dose_rout[em_cnt].
     dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
    ELSEIF (ce.event_cd=ibuprofen_dose_r)
     ib_cnt = (ib_cnt+ 1), pat->ibuprofen_dose_route_cnt = ib_cnt, stat = alterlist(pat->
      ibuprofen_dose_route,ib_cnt),
     pat->ibuprofen_dose_route[ib_cnt].result_val = trim(ce.result_val), pat->ibuprofen_dose_route[
     ib_cnt].dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
    ELSEIF (ce.event_cd=let_dose_r)
     let_cnt = (let_cnt+ 1), pat->let_dose_route_cnt = let_cnt, stat = alterlist(pat->let_dose_route,
      let_cnt),
     pat->let_dose_route[let_cnt].result_val = trim(ce.result_val), pat->let_dose_route[let_cnt].
     dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
    ELSEIF (ce.event_cd=porparicaine_dose_r)
     por_cnt = (por_cnt+ 1), pat->porparicaine_dose_route_cnt = por_cnt, stat = alterlist(pat->
      porparicaine_dose_route,por_cnt),
     pat->porparicaine_dose_route[por_cnt].result_val = trim(ce.result_val), pat->
     porparicaine_dose_route[por_cnt].dta_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(pat)
  FOR (x = 1 TO size(pat->initial_treatment,5))
    SET pt->line_cnt = 0
    SET max_length = 150
    SET cnt = 0
    SET line_cnt = 0
    SET tempstring = fillstring(500,"")
    SET tempstring = build2(trim(pat->initial_treatment[x].result_val)," (",pat->initial_treatment[x]
     .dta_dt_tm,")")
    EXECUTE dcp_parse_text value(tempstring), value(max_length)
    SET stat = alterlist(pat->initial_treatment[x].display,pt->line_cnt)
    FOR (line_cnt = 1 TO pt->line_cnt)
     SET cnt = (cnt+ 1)
     SET pat->initial_treatment[x].display[line_cnt].display_line = trim(pt->lns[line_cnt].line)
    ENDFOR
  ENDFOR
  CALL echorecord(pat)
  SELECT INTO "nl:"
   ce.event_cd, ce.result_val
   FROM clinical_event ce
   WHERE (ce.encntr_id=pat->pat_encnt)
    AND ce.result_status_cd IN (25.00, 34.00, 35.00)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ((ce.event_cd+ 0) IN (esi_acuity, stated_complaint, duration_onset, duration_sysmtoms,
   comm_barriers,
   language_spoken, temperature, temperature_route, pulse_rate, respiratory_rate,
   oxygen_satur, l_p_min, mode_of_deli, systolic_blood_p, diastolic_blood_p,
   blood_p_sites, weight, pat_arr_amb, pmh, initial_treat,
   acetaminophen_dose_route, emla_dose_route, ibuprofen_dose_r, let_dose_r, ambulatroy_o_scen,
   porparicaine_dose_r, pt_on_b_w_cerv_collar, c_sp_his_powergrid, c_sp_phy_exam_pg,
   c_sp_clin_cleared,
   c_sp_cleared_by, pat_clear_f_triage, extremity_weakness, parasthesia, hx_loss,
   pt_has_distracting, mental_status, neurological_deficit, distracting_pain, tenderness_on_neck,
   palpable_defor, pain_tenderness))
   ORDER BY ce.clinsig_updt_dt_tm
   HEAD ce.event_cd
    IF (ce.event_cd=esi_acuity)
     pat->esi_acuity_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=stated_complaint)
     pat->stated_complaint_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=duration_onset)
     pat->duration_onset_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=duration_sysmtoms)
     pat->duration_sysmtoms_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=comm_barriers)
     pat->comm_barriers = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=language_spoken)
     pat->language_spoken = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=temperature
     AND (pat->temp_dt_tm != ce.event_end_dt_tm))
     pat->temperature_l_result_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=temperature_route
     AND (pat->temp_route_dt_tm != ce.event_end_dt_tm))
     pat->tempature_route_l_result_val = build2(trim(ce.result_val),"     (",format(ce
       .event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pulse_rate
     AND (pat->pulse_dt_tm != ce.event_end_dt_tm))
     pat->pulse_rate_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=respiratory_rate
     AND (pat->resp_dt_tm != ce.event_end_dt_tm))
     pat->respiratory_rate_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=oxygen_satur
     AND (pat->oxygen_dt_tm != ce.event_end_dt_tm))
     pat->oxygen_satur_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=l_p_min
     AND (pat->l_dt_tm != ce.event_end_dt_tm))
     pat->l_p_min_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=mode_of_deli
     AND (pat->mode_dt_tm != ce.event_end_dt_tm))
     pat->mode_of_deli_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=systolic_blood_p
     AND (pat->sys_blood_dt_tm != ce.event_end_dt_tm))
     pat->systolic_blood_p_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=diastolic_blood_p
     AND (pat->diastolic_dt_tm != ce.event_end_dt_tm))
     pat->diastolic_blood_p_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=blood_p_sites
     AND (pat->blood_dt_tm != ce.event_end_dt_tm))
     pat->blood_p_sites_l_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=weight)
     pat->weight_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pat_arr_amb)
     pat->pat_arr_amb_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pmh)
     pat->pmh_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=ambulatroy_o_scen)
     pat->ambulatroy_o_scen_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pt_on_b_w_cerv_collar)
     pat->pt_on_b_w_cerv_collar_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=c_sp_his_powergrid)
     pat->c_sp_his_powergrid_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=c_sp_phy_exam_pg)
     pat->c_sp_phy_exam_pg_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=c_sp_clin_cleared)
     pat->c_sp_clin_cleared_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=c_sp_cleared_by)
     pat->c_sp_cleared_by_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pat_clear_f_triage)
     pat->pat_clear_f_triage_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=neck_pain)
     pat->neck_pain_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=extremity_weakness)
     pat->extremity_weakness_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=parasthesia)
     pat->parasthesia_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=hx_loss)
     pat->hx_loss_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pt_has_distracting)
     pat->pt_has_distracting_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=mental_status)
     pat->mental_status_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=neurological_deficit)
     pat->neurological_deficit_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=distracting_pain)
     pat->distracting_pain_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=tenderness_on_neck)
     pat->tenderness_on_neck_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=palpable_defor)
     pat->palpable_defor_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ELSEIF (ce.event_cd=pain_tenderness)
     pat->pain_tenderness_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
       "MM/DD/YY HH:MM;;;D")," ) ")
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    y_break = 40, y_pos = 18, x_pos = 20,
    y = (y_pos+ 10), a_cnt = 0, no_data = null,
    xd = 20, b = "{B}", eb = "{ENDB}",
    printpsheader = 0, col 0, "{PS/792 0 }",
    row + 1
   HEAD PAGE
    row + 1,
    CALL print(calcpos(225,20)), "{F/5}{CPI/10}{U}",
    "FirstNet Triage / Assessment Report", "{endu}", row + 1,
    CALL print(calcpos(20,40)), "{F/4}{CPI/14}", b,
    "Patient Name: ", eb, pat->pat_name,
    row + 1,
    CALL print(calcpos(400,40)), b,
    "Date & Time: ", eb, curdate,
    " ", curtime, row + 1,
    CALL print(calcpos(20,50)), b, "DOB: ",
    eb, pat->pat_dob, "( Age ",
    pat->pat_age, " )", row + 1,
    CALL print(calcpos(170,50)), b, "ACCT # : ",
    eb, pat->pat_fn, row + 1,
    CALL print(calcpos(320,50)), b, "MRN :",
    eb, pat->pat_mrn, y_pos = (y_pos+ 10)
   HEAD d.seq
    x_pos = 20, y_pos = 80,
    CALL print(calcpos(x_pos,y_pos)),
    b, "Allergy : ", eb,
    y_pos = (y_pos+ 10)
    IF ((pat->allergy_cnt=0))
     CALL print(calcpos(x_pos,y_pos)), "No Allergy Information Documented ", y_pos = (y_pos+ 10)
    ELSE
     FOR (i = 1 TO pat->allergy_cnt)
       CALL print(calcpos(x_pos,y_pos)), pat->allergy[i].alergy_info, y_pos = (y_pos+ 10),
       row + 1
     ENDFOR
    ENDIF
   DETAIL
    IF ((pat->esi_acuity_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "ESI/Acuity: ", eb,
     pat->esi_acuity_val
    ENDIF
    IF ((pat->stated_complaint_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Stated Complaint: ", eb,
     pat->stated_complaint_val
    ENDIF
    IF ((pat->duration_onset_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Duration Onset: ", eb,
     pat->duration_onset_val
    ENDIF
    IF ((pat->duration_sysmtoms_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Duration Symptoms: ", eb,
     pat->duration_sysmtoms_val
    ENDIF
    IF ((pat->comm_barriers=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Communication Barrier : ", eb,
     pat->comm_barriers
    ENDIF
    IF ((pat->language_spoken=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Language Spoken: ", eb,
     pat->language_spoken
    ENDIF
    IF ((pat->pat_arr_amb_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Patient Arrived By Ambulance: ", eb,
     pat->pat_arr_amb_val
    ENDIF
    IF ((pat->weight_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Weight: ", eb,
     pat->weight_val
    ENDIF
    IF ((pat->pmh_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "PMH:", eb,
     pat->pmh_val
    ENDIF
    IF ((pat->temperature_f_result_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Temp: ", eb,
     pat->temperature_f_result_val, " ", pat->temperature_l_result_val
    ENDIF
    IF ((pat->tempature_route_f_result_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Temp Route: ", eb,
     pat->tempature_route_f_result_val, " ", pat->tempature_route_l_result_val
    ENDIF
    IF ((pat->pulse_rate_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Pulse Rate: ", eb,
     pat->pulse_rate_f_val, " ", pat->pulse_rate_l_val
    ENDIF
    IF ((pat->respiratory_rate_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Resp Rate: ", eb,
     pat->respiratory_rate_f_val, " ", pat->respiratory_rate_l_val
    ENDIF
    IF ((pat->oxygen_satur_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Oxygen Saturation: ", eb,
     pat->oxygen_satur_f_val, " ", pat->oxygen_satur_l_val
    ENDIF
    IF ((pat->l_p_min_l_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Liters per Minute: ", eb,
     pat->l_p_min_f_val, " ", pat->l_p_min_l_val
    ENDIF
    IF ((pat->mode_of_deli_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Mode of Delivery (Oxygen): ", eb,
     pat->mode_of_deli_f_val, " ", pat->mode_of_deli_l_val
    ENDIF
    IF ((pat->systolic_blood_p_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Systolic Blood Pressure: ", eb,
     pat->systolic_blood_p_f_val, " ", pat->systolic_blood_p_l_val
    ENDIF
    IF ((pat->diastolic_blood_p_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Diastolic Blood Pressure: ", eb,
     pat->diastolic_blood_p_f_val, " ", pat->diastolic_blood_p_l_val
    ENDIF
    IF ((pat->blood_p_sites_f_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Blood pressure sites: ", eb,
     pat->blood_p_sites_f_val, " ", pat->blood_p_sites_l_val
    ENDIF
    IF ((pat->initial_treatment_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Inital Treatment (ED):", eb
     FOR (ai = 1 TO pat->initial_treatment_cnt)
       FOR (ar = 1 TO size(pat->initial_treatment[ai].display,5))
         y_pos = (y_pos+ 10)
         IF (y_pos > 550)
          BREAK, y_pos = 50, x_pos = 18
         ENDIF
         CALL print(calcpos((x_pos+ xd),y_pos)),
         CALL print(build2(pat->initial_treatment[ai].display[ar].display_line)), row + 1
       ENDFOR
     ENDFOR
    ENDIF
    IF ((pat->acetaminophen_dose_route_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Acetaminophen Dose Route: ", eb
     FOR (ci = 1 TO pat->acetaminophen_dose_route_cnt)
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       CALL print(calcpos((x_pos+ xd),y_pos)),
       CALL print(build2(pat->acetaminophen_dose_route[ci].result_val," (",pat->
        acetaminophen_dose_route[ci].dta_dt_tm,")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->emla_dose_route_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "EMLA Dose Route : ", eb
     FOR (di = 1 TO pat->emla_dose_route_cnt)
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       CALL print(calcpos((x_pos+ xd),y_pos)),
       CALL print(build2(pat->emla_dose_rout[di].result_val," (",pat->emla_dose_rout[di].dta_dt_tm,
        ")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->ibuprofen_dose_route_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Ibuprofen Dose Route : ", eb
     FOR (ei = 1 TO pat->ibuprofen_dose_route_cnt)
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)),
       CALL print(build2(pat->ibuprofen_dose_route[ei].result_val," (",pat->ibuprofen_dose_route[ei].
        dta_dt_tm,")")),
       row + 1
     ENDFOR
    ENDIF
    IF ((pat->let_dose_route_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "LET Dose Route : ", eb
     FOR (fi = 1 TO pat->let_dose_route_cnt)
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18,
        "page con"
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)),
       CALL print(build2(pat->let_dose_route[fi].result_val," (",pat->let_dose_route[fi].dta_dt_tm,
        ")")),
       row + 1
     ENDFOR
    ENDIF
    IF ((pat->porparicaine_dose_route_cnt=0))
     no_data
    ELSE
     y_pos = (y_pos+ 10), row + 1,
     CALL print(calcpos(x_pos,y_pos)),
     b, "Proparicaine Dose Route: ", eb
     FOR (gi = 1 TO pat->porparicaine_dose_route_cnt)
       y_pos = (y_pos+ 10)
       IF (y_pos > 550)
        BREAK, y_pos = 50, x_pos = 18
       ENDIF
       row + 1,
       CALL print(calcpos((x_pos+ xd),y_pos)),
       CALL print(build2(pat->porparicaine_dose_route[gi].result_val," (",pat->
        porparicaine_dose_route[gi].dta_dt_tm,")")),
       row + 1
     ENDFOR
    ENDIF
    IF ((pat->ambulatroy_o_scen_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "Ambulatory On Scene: ", eb, pat->ambulatroy_o_scen_val
    ENDIF
    IF ((pat->pt_on_b_w_cerv_collar_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "Pt. on Backboard W/ Cervical Collar:", eb, pat->pt_on_b_w_cerv_collar_val
    ENDIF
    IF ((pat->c_sp_his_powergrid_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "C-Spine History Powergrid: ", eb, pat->c_sp_his_powergrid_val
    ENDIF
    IF ((pat->neck_pain_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Neck Pain:",
     pat->neck_pain_val
    ENDIF
    IF ((pat->extremity_weakness_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Extremity Weakness: ",
     pat->extremity_weakness_val
    ENDIF
    IF ((pat->parasthesia_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Parasthesia Or Numbness:",
     pat->parasthesia_val
    ENDIF
    IF ((pat->hx_loss_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Hx. Loss of Consciousness:",
     pat->hx_loss_val
    ENDIF
    IF ((pat->pt_has_distracting_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Pt.Has Distracting Injury: ",
     pat->pt_has_distracting_val
    ENDIF
    IF ((pat->c_sp_phy_exam_pg_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "C-Spine Physical Exam powergrid: ", eb, pat->c_sp_phy_exam_pg_val
    ENDIF
    IF ((pat->mental_status_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Mental Status Change:",
     pat->mental_status_val
    ENDIF
    IF ((pat->neurological_deficit_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Neurological Deficit:",
     pat->neurological_deficit_val
    ENDIF
    IF ((pat->distracting_pain_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Distracting Painful Injury:",
     pat->distracting_pain_val
    ENDIF
    IF ((pat->tenderness_on_neck_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Tenderness On Neck Palpation:",
     pat->tenderness_on_neck_val
    ENDIF
    IF ((pat->palpable_defor_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Palpable Deformity:",
     pat->palpable_defor_val
    ENDIF
    IF ((pat->pain_tenderness_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos)), "Pain/Tenderness on Palpation:",
     pat->pain_tenderness_val
    ENDIF
    IF ((pat->c_sp_clin_cleared_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "C-spine Clinically Cleared: ", eb, pat->c_sp_clin_cleared_val
    ENDIF
    IF ((pat->c_sp_cleared_by_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "C-spine Cleared by: ", eb, pat->c_sp_cleared_by_val
    ENDIF
    IF ((pat->pat_clear_f_triage_val=null))
     no_data
    ELSE
     y_pos = (y_pos+ 10)
     IF (y_pos > 550)
      BREAK, y_pos = 50, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos)), b,
     "Patient Cleared for Triage: ", eb, pat->pat_clear_f_triage_val
    ENDIF
   FOOT REPORT
    y_pos = (y_pos+ 20), x_pos = (x_pos+ 100), row + 1,
    CALL print(calcpos(x_pos,y_pos)), b, "End Of The Report",
    eb
   FOOT PAGE
    y_pos = (y_pos+ 20), x_pos = (x_pos+ 50), row + 1,
    CALL print(calcpos(x_pos,y_pos)), b,
    "***  Report does not include any EMS information and includes only select information from Triage/Assessment/Reassessment ***"
,
    eb, y_pos = (y_pos+ 20), x_pos = (x_pos+ 50),
    row + 1,
    CALL print(calcpos(225,y_pos)), b,
    "Page#:", curpage, eb
   WITH dio = 08, time = 30, maxcol = 500
  ;end select
 ENDIF
#exit_program
END GO
