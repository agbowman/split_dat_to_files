CREATE PROGRAM bhs_rpt_fn_down_tareport:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "select a patient" = 0
  WITH outdev, f_name
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD pat
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
   1 s_hist_pres_illness = vc
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
   1 s_ems_chief_complaint = vc
   1 s_vital_signs_glucose = vc
   1 s_ems_treatments_pta = vc
   1 s_prn_angio_size_site = vc
   1 s_iv_fluids_amount_infused = vc
   1 s_oxygen_saturation = vc
   1 s_liters_per_min = vc
   1 s_mode_delivery_oxy = vc
   1 s_handover_oxygen_saturation = vc
   1 s_handover_liters_per_min = vc
   1 s_handover_mode_delivery_oxy = vc
   1 s_ems_meds_admin_pta = vc
   1 s_ed_addl_info = vc
   1 s_ems_addl_info = vc
   1 s_pa_type = vc
   1 s_referral_source = vc
   1 s_location = vc
   1 s_expect_callback_to = vc
   1 s_callback_num = vc
   1 s_transport_mode = vc
   1 s_arrival_time = vc
   1 s_other_notes = vc
 )
 FREE RECORD loc
 RECORD loc(
   1 opjob_ind = i2
   1 nurse_unit = vc
   1 unit_cd = f8
   1 encounter_cnt = i2
   1 encounter_info[*]
     2 encounter_id = f8
     2 file_name = vc
     2 reg_dt_tm = vc
 )
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_date = vc WITH protect, noconstant("")
 DECLARE ms_result = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_string_old = vc WITH protect, noconstant("")
 DECLARE ms_handover_title_text = vc WITH protect, constant("ED EMS Handover")
 DECLARE ms_handover_form_desc = vc WITH protect, constant("ED EMS Handover")
 DECLARE ms_ed_title_text = vc WITH protect, constant("ED Vital Signs/Pain")
 DECLARE ms_ed_form_desc = vc WITH protect, constant("ED Assessment Form")
 DECLARE ms_init_treatment_title_text = vc WITH protect, constant("Initial Treatments")
 DECLARE ms_triage_form_desc = vc WITH protect, constant("ED Triage Form")
 DECLARE ms_vital_signs_title_text = vc WITH protect, constant("Vital Signs")
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_hist_pres_illness_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYOFPRESENTILLNESS"))
 DECLARE mf_ems_chief_complaint_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHIEFCOMPLAINT"))
 DECLARE mf_vital_signs_glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VITALSIGNSGLUCOSEPOC"))
 DECLARE mf_ems_treatments_pta_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EMSTREATMENTSPTA"))
 DECLARE mf_prn_angio_size_site_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PRNANGIOSIZEANDSITE"))
 DECLARE mf_iv_fluids_amount_infused_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "IVFLUIDSAMOUNTINFUSED"))
 DECLARE mf_ems_meds_admin_pta_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EMSMEDSADMINSTEREDPTA"))
 DECLARE mf_ed_addl_info_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EDADDITIONALINFORMATION"))
 DECLARE mf_ems_addl_info_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EMSADDITIONALINFORMATION"))
 DECLARE mf_oxygen_saturation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATION"))
 DECLARE mf_liters_per_min_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LITERSPERMINUTE"))
 DECLARE mf_mode_delivery_oxy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 SET esi_acuity = uar_get_code_by("displaykey",72,"EDTRACKINGACUITY")
 SET stated_complaint = uar_get_code_by("displaykey",72,"STATEDCOMPLAINT")
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
 DECLARE it_cnt = i2
 DECLARE ac_cnt = i2
 DECLARE em_cnt = i2
 DECLARE ib_cnt = i2
 DECLARE let_cnt = i2
 DECLARE por_cnt = i2
 DECLARE l_cnt = i2
 DECLARE tmp_remove = vc
 DECLARE active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
 DECLARE proposed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"PROPOSED"))
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
    encntr_domain ed,
    encounter e
   PLAN (ed
    WHERE (ed.loc_nurse_unit_cd=loc->unit_cd)
     AND ((ed.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
     AND ed.beg_effective_dt_tm < sysdate
     AND ed.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ed.encntr_id
     AND e.disch_dt_tm=null)
    JOIN (p
    WHERE ed.person_id=p.person_id)
   DETAIL
    IF (((e.reg_dt_tm >= cnvtlookbehind("36,H",sysdate)
     AND (loc->nurse_unit IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
    "ESB", "ESC", "ESD", "ESP", "ESX",
    "ESW"))) OR ( NOT ((loc->nurse_unit IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
    "ESB", "ESC", "ESD", "ESP", "ESX",
    "ESW"))))) )
     l_cnt += 1, loc->encounter_cnt = l_cnt, stat = alterlist(loc->encounter_info,loc->encounter_cnt),
     loc->encounter_info[l_cnt].reg_dt_tm = format(e.reg_dt_tm,";;Q"), loc->encounter_info[l_cnt].
     file_name = build(trim(substring(1,5,trim(cnvtlower(cnvtalphanum(p.name_last_key,2)),4)),3),"_",
      trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p.name_first_key,2)),4)),3),".ps"), loc->
     encounter_info[l_cnt].encounter_id = ed.encntr_id
    ENDIF
   WITH nocounter
  ;end select
  FOR (li = 1 TO loc->encounter_cnt)
    SET time_marker = format(cnvtlookahead("1,S",cnvtdatetime(sysdate)),"YYYYMMDDHHMMSS;;D")
    WHILE (format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;D") < time_marker)
      SET x = 1
    ENDWHILE
    SET pat->pat_encnt = loc->encounter_info[li].encounter_id
    CALL sub_get_person_info(pat->pat_encnt)
    CALL sub_get_prearrival_info(pat->pat_encnt)
    CALL sub_get_allergy_info(pat->pat_encnt)
    CALL sub_get_clinical_info(pat->pat_encnt)
    CALL sub_build_intitial_treatment(0)
    CALL sub_print_report(loc->encounter_info[li].file_name)
    SET spool value(loc->encounter_info[li].file_name)  $OUTDEV
    SET tmp_remove = build2('set stat = remove("',loc->encounter_info[li].file_name,'") go')
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
    SET stat = initrec(pat)
    SET stat = initrec(pt)
  ENDFOR
 ENDIF
 IF (operation=0)
  SET mf_encntr_id = cnvtreal( $F_NAME)
  CALL sub_get_person_info(mf_encntr_id)
  CALL sub_get_prearrival_info(pat->pat_encnt)
  CALL sub_get_allergy_info(pat->pat_encnt)
  CALL sub_get_clinical_info(pat->pat_encnt)
  CALL sub_build_intitial_treatment(0)
  CALL echorecord(pat)
  CALL sub_print_report( $OUTDEV)
 ENDIF
 FREE RECORD pat
 FREE RECORD pt
 FREE RECORD loc
 SUBROUTINE (sub_get_person_info(mf_encntr_id=f8) =null)
   SELECT INTO "nl:"
    FROM person p,
     encntr_domain ed,
     encntr_alias ea
    PLAN (ed
     WHERE ed.encntr_id=mf_encntr_id
      AND ((ed.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
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
     pat->pat_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)), pat->pat_dob
      = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YY ;;;;;D")
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
   RETURN
 END ;Subroutine
 SUBROUTINE (sub_get_prearrival_info(mf_encntr_id=f8) =null)
   SELECT INTO "nl:"
    tp.prearrival_type_cd, tp.estimated_arrive_dt_tm, tp.last_name,
    tp.first_name, tp.sex_cd, tp.birth_dt_tm,
    tp.age_txt, tp.referring_source_name
    FROM tracking_prearrival tp,
     tracking_prearrival_userfields tpu,
     track_prearrival_field tpf
    PLAN (tp
     WHERE tp.attached_encntr_id=mf_encntr_id)
     JOIN (tpu
     WHERE tpu.tracking_prearrival_id=tp.tracking_prearrival_id)
     JOIN (tpf
     WHERE tpf.track_prearrival_field_id=tpu.track_prearrival_field_id)
    HEAD REPORT
     pat->s_pa_type = uar_get_code_display(tp.prearrival_type_cd), pat->s_referral_source = tp
     .referring_source_name
    DETAIL
     CASE (tpf.default_label)
      OF "Location":
       pat->s_location = uar_get_code_display(tpu.user_data_value)
      OF "Expect Call Back To:":
       pat->s_expect_callback_to = tpu.user_data_text
      OF "Call Back #:":
       pat->s_callback_num = tpu.user_data_text
      OF "Transport Mode:":
       pat->s_transport_mode = tpu.user_data_text
      OF "Arrival Time:":
       pat->s_arrival_time = tpu.user_data_text
     ENDCASE
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM clinical_event ce,
      ce_blob cb
     PLAN (ce
      WHERE ce.encntr_id=mf_encntr_id
       AND ce.event_title_text="PreArrival Note")
      JOIN (cb
      WHERE cb.event_id=ce.event_id)
     HEAD REPORT
      pn_index = 0, pn_ord_grp = 0
     DETAIL
      blob_size = cnvtint(cb.blob_length), blob_out_detail = fillstring(64000," "),
      blob_compressed_trimmed = fillstring(64000," "),
      blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
      fillstring(64000," "),
      blob_compressed_trimmed = trim(cb.blob_contents), blob_return_len = 0, blob_return_len2 = 0
      IF (cb.compression_cd=mf_comp_cd)
       CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
       blob_uncompressed,size(blob_uncompressed),blob_return_len),
       CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
       eventval = trim(blob_rtf,3)
      ELSEIF (cb.compression_cd=mf_no_comp_cd)
       eventval = trim(cb.blob_contents)
       IF (findstring("rtf",eventval) > 0)
        CALL uar_rtf2(eventval,textlen(eventval),blob_rtf,size(blob_rtf),blob_return_len2,1),
        eventval = trim(blob_rtf,3)
       ENDIF
       IF (findstring("ocf_blob",eventval) > 0)
        eventval = trim(substring(1,(findstring("ocf_blob",eventval) - 1),eventval))
       ENDIF
      ENDIF
      newval = replace(eventval,char(10),""), newval = replace(newval,char(13)," "), beg_pos =
      findstring("Baystate Emergency Department",newval),
      newval = substring(beg_pos,(textlen(newval) - beg_pos),newval), pat->s_other_notes = trim(
       newval)
     WITH nocounter
    ;end select
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (sub_get_allergy_info(mf_encntr_id=f8) =null)
  SELECT INTO "nl:"
   FROM encounter e,
    allergy a,
    nomenclature n
   PLAN (e
    WHERE e.encntr_id=mf_encntr_id)
    JOIN (a
    WHERE a.person_id=e.person_id
     AND ((a.active_ind+ 0)=1)
     AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
     AND a.reaction_status_cd IN (active, proposed))
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id)
   HEAD REPORT
    a_cnt = 0
   HEAD a.allergy_instance_id
    a_cnt += 1, pat->allergy_cnt = a_cnt, stat = alterlist(pat->allergy,a_cnt),
    pat->allergy[a_cnt].alergy_info = n.source_string
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SUBROUTINE (sub_get_clinical_info(mf_encntr_id=f8) =null)
  SELECT INTO "nl:"
   ce.event_cd, ce.result_val
   FROM clinical_event ce,
    clinical_event ce1,
    dcp_forms_activity dfa,
    dcp_forms_activity_comp dfac
   PLAN (ce
    WHERE ce.encntr_id=mf_encntr_id
     AND ce.result_status_cd IN (25.00, 34.00, 35.00)
     AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(sysdate))
     AND ((ce.event_cd+ 0) IN (esi_acuity, stated_complaint, mf_hist_pres_illness_cd, comm_barriers,
    language_spoken,
    temperature, temperature_route, pulse_rate, respiratory_rate, oxygen_satur,
    l_p_min, mode_of_deli, systolic_blood_p, diastolic_blood_p, blood_p_sites,
    weight, pat_arr_amb, pmh, initial_treat, acetaminophen_dose_route,
    emla_dose_route, ibuprofen_dose_r, let_dose_r, ambulatroy_o_scen, porparicaine_dose_r,
    pt_on_b_w_cerv_collar, c_sp_his_powergrid, c_sp_phy_exam_pg, c_sp_clin_cleared, c_sp_cleared_by,
    pat_clear_f_triage, extremity_weakness, parasthesia, hx_loss, pt_has_distracting,
    mental_status, neurological_deficit, distracting_pain, tenderness_on_neck, palpable_defor,
    pain_tenderness, mf_ems_chief_complaint_cd, mf_vital_signs_glucose_cd, mf_ems_treatments_pta_cd,
    mf_prn_angio_size_site_cd,
    mf_iv_fluids_amount_infused_cd, mf_oxygen_saturation_cd, mf_liters_per_min_cd,
    mf_mode_delivery_oxy_cd, mf_ems_meds_admin_pta_cd,
    mf_ems_addl_info_cd)))
    JOIN (ce1
    WHERE ce1.event_id=ce.parent_event_id)
    JOIN (dfac
    WHERE dfac.parent_entity_id=ce1.parent_event_id)
    JOIN (dfa
    WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
     AND dfa.active_ind=1
     AND dfa.description IN (ms_triage_form_desc, ms_ed_form_desc, ms_handover_form_desc,
    ms_vital_signs_title_text))
   ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm
   HEAD REPORT
    it_cnt = 0, ac_cnt = 0, em_cnt = 0,
    ib_cnt = 0, let_cnt = 0, por_cnt = 0
   HEAD ce.event_cd
    CALL echo(concat(trim(ce1.event_title_text)," ",trim(ce.event_title_text)," ",trim(ce.result_val)
     )), ms_date = format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"), ms_result = trim(ce.result_val)
    CASE (ce.event_cd)
     OF temperature:
      pat->temp_dt_tm = ce.event_end_dt_tm,pat->temperature_f_result_val = ms_result
     OF temperature_route:
      pat->temp_route_dt_tm = ce.event_end_dt_tm,pat->tempature_route_f_result_val = ms_result
     OF pulse_rate:
      pat->pulse_dt_tm = ce.event_end_dt_tm,pat->pulse_rate_f_val = ms_result
     OF respiratory_rate:
      pat->resp_dt_tm = ce.event_end_dt_tm,pat->respiratory_rate_f_val = ms_result
     OF systolic_blood_p:
      pat->sys_blood_dt_tm = ce.event_end_dt_tm,pat->systolic_blood_p_f_val = ms_result
     OF diastolic_blood_p:
      pat->diastolic_dt_tm = ce.event_end_dt_tm,pat->diastolic_blood_p_f_val = ms_result
     OF blood_p_sites:
      pat->blood_dt_tm = ce.event_end_dt_tm,pat->blood_p_sites_f_val = ms_result
    ENDCASE
    pd_previous_date = ce.clinsig_updt_dt_tm
   DETAIL
    ms_result = trim(ce.result_val)
    IF (ce.event_cd=esi_acuity
     AND isnumeric(ce.result_val) != 0)
     pat->esi_acuity_val = trim(ce.result_val)
    ENDIF
    IF (ce.clinsig_updt_dt_tm >= pd_previous_date)
     CASE (ce.event_cd)
      OF stated_complaint:
       pat->stated_complaint_val = ms_result
      OF mf_hist_pres_illness_cd:
       pat->s_hist_pres_illness = ms_result
      OF comm_barriers:
       pat->comm_barriers = ms_result
      OF language_spoken:
       pat->language_spoken = ms_result
      OF temperature:
       IF ((pat->temp_dt_tm != ce.event_end_dt_tm))
        pat->temperature_l_result_val = ms_result
       ENDIF
      OF temperature_route:
       IF ((pat->temp_route_dt_tm != ce.event_end_dt_tm))
        pat->tempature_route_l_result_val = ms_result
       ENDIF
      OF pulse_rate:
       IF ((pat->pulse_dt_tm != ce.event_end_dt_tm))
        pat->pulse_rate_l_val = ms_result
       ENDIF
      OF respiratory_rate:
       IF ((pat->resp_dt_tm != ce.event_end_dt_tm))
        pat->respiratory_rate_l_val = ms_result
       ENDIF
      OF oxygen_satur:
       CALL echo("here 1")pat->oxygen_dt_tm = ce.event_end_dt_tm,
       IF (ce1.event_title_text=ms_init_treatment_title_text)
        CALL echo("here 2"), pat->oxygen_satur_f_val = ms_result
       ELSEIF (ce1.event_title_text=ms_handover_title_text)
        CALL echo("here 3"), pat->s_handover_oxygen_saturation = ms_result
       ELSEIF (ce1.event_title_text IN (ms_vital_signs_title_text, ms_ed_title_text))
        CALL echo("here 4"), pat->oxygen_satur_l_val = ms_result
       ENDIF
      OF l_p_min:
       pat->l_dt_tm = ce.event_end_dt_tm,
       IF (ce1.event_title_text=ms_init_treatment_title_text)
        pat->l_p_min_f_val = ms_result
       ELSEIF (ce1.event_title_text=ms_handover_title_text)
        pat->s_handover_liters_per_min = ms_result
       ELSEIF (ce1.event_title_text IN (ms_vital_signs_title_text, ms_ed_title_text))
        pat->l_p_min_l_val = ms_result
       ENDIF
      OF mode_of_deli:
       pat->mode_dt_tm = ce.event_end_dt_tm,
       IF (ce1.event_title_text=ms_init_treatment_title_text)
        pat->mode_of_deli_f_val = ms_result
       ELSEIF (ce1.event_title_text=ms_handover_title_text)
        pat->s_handover_mode_delivery_oxy = ms_result
       ELSEIF (ce1.event_title_text IN (ms_vital_signs_title_text, ms_ed_title_text))
        pat->mode_of_deli_l_val = ms_result
       ENDIF
      OF systolic_blood_p:
       IF ((pat->sys_blood_dt_tm != ce.event_end_dt_tm))
        pat->systolic_blood_p_l_val = ms_result
       ENDIF
      OF diastolic_blood_p:
       IF ((pat->diastolic_dt_tm != ce.event_end_dt_tm))
        pat->diastolic_blood_p_l_val = ms_result
       ENDIF
      OF blood_p_sites:
       IF ((pat->blood_dt_tm != ce.event_end_dt_tm))
        pat->blood_p_sites_l_val = ms_result
       ENDIF
      OF weight:
       pat->weight_val = ms_result
      OF pat_arr_amb:
       pat->pat_arr_amb_val = ms_result
      OF pmh:
       pat->pmh_val = ms_result
      OF ambulatroy_o_scen:
       pat->ambulatroy_o_scen_val = ms_result
      OF pt_on_b_w_cerv_collar:
       pat->pt_on_b_w_cerv_collar_val = ms_result
      OF c_sp_his_powergrid:
       pat->c_sp_his_powergrid_val = ms_result
      OF c_sp_phy_exam_pg:
       pat->c_sp_phy_exam_pg_val = ms_result
      OF c_sp_clin_cleared:
       pat->c_sp_clin_cleared_val = ms_result
      OF c_sp_cleared_by:
       pat->c_sp_cleared_by_val = ms_result
      OF pat_clear_f_triage:
       pat->pat_clear_f_triage_val = ms_result
      OF neck_pain:
       pat->neck_pain_val = ms_result
      OF extremity_weakness:
       pat->extremity_weakness_val = ms_result
      OF parasthesia:
       pat->parasthesia_val = ms_result
      OF hx_loss:
       pat->hx_loss_val = ms_result
      OF pt_has_distracting:
       pat->pt_has_distracting_val = ms_result
      OF mental_status:
       pat->mental_status_val = ms_result
      OF neurological_deficit:
       pat->neurological_deficit_val = ms_result
      OF distracting_pain:
       pat->distracting_pain_val = ms_result
      OF tenderness_on_neck:
       pat->tenderness_on_neck_val = ms_result
      OF palpable_defor:
       pat->palpable_defor_val = ms_result
      OF pain_tenderness:
       pat->pain_tenderness_val = ms_result
      OF mf_ems_chief_complaint_cd:
       pat->s_ems_chief_complaint = ms_result
      OF mf_vital_signs_glucose_cd:
       pat->s_vital_signs_glucose = ms_result
      OF mf_ems_treatments_pta_cd:
       pat->s_ems_treatments_pta = ms_result
      OF mf_prn_angio_size_site_cd:
       pat->s_prn_angio_size_site = ms_result
      OF mf_iv_fluids_amount_infused_cd:
       pat->s_iv_fluids_amount_infused = ms_result
      OF mf_ems_meds_admin_pta_cd:
       pat->s_ems_meds_admin_pta = ms_result
      OF mf_ems_addl_info_cd:
       pat->s_ems_addl_info = ms_result
     ENDCASE
    ENDIF
    pd_previous_date = ce.clinsig_updt_dt_tm
    IF (ce.event_cd=initial_treat
     AND ce1.valid_until_dt_tm > sysdate)
     it_cnt += 1, pat->initial_treatment_cnt = it_cnt, stat = alterlist(pat->initial_treatment,it_cnt
      ),
     pat->initial_treatment[it_cnt].dta_cd = ce.event_id, pat->initial_treatment[it_cnt].result_val
      = trim(ce.result_val), pat->initial_treatment[it_cnt].dta_dt_tm = ms_date
    ELSEIF (ce.event_cd=acetaminophen_dose_route)
     ac_cnt = (pat->acetaminophen_dose_route_cnt+ 1), pat->acetaminophen_dose_route_cnt = ac_cnt,
     stat = alterlist(pat->acetaminophen_dose_route,ac_cnt),
     pat->acetaminophen_dose_route[ac_cnt].dta_cd = ce.event_id, pat->acetaminophen_dose_route[ac_cnt
     ].result_val = trim(ce.result_val), pat->acetaminophen_dose_route[ac_cnt].dta_dt_tm = ms_date
    ELSEIF (ce.event_cd=emla_dose_route)
     em_cnt += 1, pat->emla_dose_route_cnt = em_cnt, stat = alterlist(pat->emla_dose_rout,em_cnt),
     pat->emla_dose_rout[em_cnt].result_val = trim(ce.result_val), pat->emla_dose_rout[em_cnt].
     dta_dt_tm = ms_date
    ELSEIF (ce.event_cd=ibuprofen_dose_r)
     ib_cnt += 1, pat->ibuprofen_dose_route_cnt = ib_cnt, stat = alterlist(pat->ibuprofen_dose_route,
      ib_cnt),
     pat->ibuprofen_dose_route[ib_cnt].result_val = trim(ce.result_val), pat->ibuprofen_dose_route[
     ib_cnt].dta_dt_tm = ms_date
    ELSEIF (ce.event_cd=let_dose_r)
     let_cnt += 1, pat->let_dose_route_cnt = let_cnt, stat = alterlist(pat->let_dose_route,let_cnt),
     pat->let_dose_route[let_cnt].result_val = trim(ce.result_val), pat->let_dose_route[let_cnt].
     dta_dt_tm = ms_date
    ELSEIF (ce.event_cd=porparicaine_dose_r)
     por_cnt += 1, pat->porparicaine_dose_route_cnt = por_cnt, stat = alterlist(pat->
      porparicaine_dose_route,por_cnt),
     pat->porparicaine_dose_route[por_cnt].result_val = trim(ce.result_val), pat->
     porparicaine_dose_route[por_cnt].dta_dt_tm = ms_date
    ENDIF
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SUBROUTINE (sub_build_intitial_treatment(mi_val=i4) =null)
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
     SET cnt += 1
     SET pat->initial_treatment[x].display[line_cnt].display_line = trim(pt->lns[line_cnt].line)
    ENDFOR
  ENDFOR
  RETURN
 END ;Subroutine
 SUBROUTINE (sub_print_report(ms_output_file=vc) =null)
  SELECT INTO value(ms_output_file)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    y_break = 40, y_pos = 18, x_pos = 20,
    pn_page_break = 600, y = (y_pos+ 10), a_cnt = 0,
    no_data = null, xd = 20, b = "{B}",
    eb = "{ENDB}", printpsheader = 0, col 0,
    "{PS/792 0 }", row + 1,
    MACRO (mcr_inc_y_xd_break_row_inc)
     y_pos += 10
     IF (y_pos > pn_page_break)
      BREAK, y_pos = 70, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos((x_pos+ xd),y_pos))
    ENDMACRO
    ,
    MACRO (mcr_inc_y_xd_break)
     y_pos += 10
     IF (y_pos > pn_page_break)
      BREAK, y_pos = 70, x_pos = 18
     ENDIF
     CALL print(calcpos((x_pos+ xd),y_pos))
    ENDMACRO
    ,
    MACRO (mcr_inc_y_break)
     y_pos += 10
     IF (y_pos > pn_page_break)
      BREAK, y_pos = 70, x_pos = 18
     ENDIF
     row + 1,
     CALL print(calcpos(x_pos,y_pos))
    ENDMACRO
    ,
    MACRO (mcr_inc_y)
     y_pos += 10, row + 1,
     CALL print(calcpos(x_pos,y_pos))
    ENDMACRO
    ,
    MACRO (print_text)
     mi_loop_ind = 1, mn_max_print_len = 80
     WHILE (mi_loop_ind > 0)
       mn_space_pos = 0, mn_tmp_pos = 0, mn_end_pos = 0,
       mn_beg_pos = 1, mn_rem_len = 0
       IF (findstring("Baystate Emergency Department: PreArrival Form",ms_string) > 0)
        ms_tmp_str = "Baystate Emergency Department: PreArrival Form", mcr_inc_y, ms_string = trim(
         substring((textlen(ms_tmp_str)+ 1),((textlen(ms_string) - textlen(ms_tmp_str))+ 1),ms_string
          ),3),
        ms_tmp_str = ""
       ENDIF
       IF (findstring("Arriving From:",ms_string) > 0)
        mi_loop_ind = 2, mn_end_pos = findstring("Report:",ms_string)
        IF (mn_end_pos > 0)
         ms_string_old = ms_string, ms_string = trim(substring(1,(mn_end_pos - 1),ms_string),3)
        ENDIF
        IF (textlen(trim(substring(14,(textlen(ms_string) - 14),ms_string)))=0)
         ms_string = ""
        ENDIF
       ELSEIF (findstring("Report:",ms_string) > 0)
        mi_loop_ind = 3, mn_end_pos = findstring("Suggested Action to be taken:",ms_string)
        IF (mn_end_pos > 0)
         ms_string_old = ms_string, ms_string = trim(substring(1,(mn_end_pos - 1),ms_string),3)
        ENDIF
        IF (textlen(trim(substring(7,(textlen(ms_string) - 7),ms_string)))=0)
         ms_string = ""
        ENDIF
       ELSEIF (findstring("Suggested Action to be taken:",ms_string) > 0)
        mi_loop_ind = 4, mn_end_pos = findstring("Addendum Notes:",ms_string)
        IF (mn_end_pos > 0)
         ms_string_old = ms_string, ms_string = trim(substring(1,(mn_end_pos - 1),ms_string),3)
        ENDIF
        IF (textlen(trim(substring(29,(textlen(ms_string) - 29),ms_string)))=0)
         ms_string = ""
        ENDIF
       ELSEIF (findstring("Addendum Notes:",ms_string) > 0)
        mi_loop_ind = 1
        IF (textlen(trim(substring(15,(textlen(ms_string) - 15),ms_string)))=0)
         ms_string = ""
        ENDIF
       ENDIF
       IF (textlen(ms_string) < mn_max_print_len
        AND textlen(trim(ms_string)) > 0)
        ms_string
       ELSEIF (textlen(ms_string) > 0)
        mn_rem_len = textlen(ms_string)
        WHILE (mn_rem_len >= mn_max_print_len)
          mn_tmp_pos = mn_beg_pos, mn_space_pos = 0
          WHILE (mn_space_pos < mn_max_print_len)
           mn_space_pos = findstring(" ",ms_string,mn_tmp_pos),
           IF (mn_space_pos > 0
            AND mn_space_pos <= mn_max_print_len)
            mn_tmp_pos = (mn_space_pos+ 1)
           ELSEIF (((mn_space_pos=0) OR (mn_space_pos > mn_max_print_len)) )
            IF (mn_tmp_pos=mn_beg_pos)
             mn_tmp_pos = mn_max_print_len
            ENDIF
            mn_space_pos = (mn_max_print_len+ 1)
           ENDIF
          ENDWHILE
          mn_space_pos = mn_tmp_pos
          IF (textlen(trim(ms_tmp_str)) > 0)
           mcr_inc_y_break
          ENDIF
          ms_tmp_str = trim(substring(mn_beg_pos,(mn_space_pos - mn_beg_pos),ms_string)), ms_tmp_str,
          mn_beg_pos = mn_space_pos,
          ms_string = substring(mn_beg_pos,((textlen(ms_string) - mn_beg_pos)+ 1),ms_string),
          mn_beg_pos = 1, mn_rem_len = (textlen(ms_string) - mn_beg_pos)
          IF (mn_rem_len <= mn_max_print_len)
           ms_tmp_str = ms_string, mcr_inc_y_break, ms_tmp_str
          ENDIF
        ENDWHILE
       ENDIF
       ms_tmp_str = ""
       CASE (mi_loop_ind)
        OF 1:
         mi_loop_ind = 0
        OF 2:
         mn_beg_pos = findstring("Report:",ms_string_old),
         IF (mn_beg_pos > 0)
          IF (textlen(trim(ms_string)) > 0)
           mcr_inc_y_break
          ENDIF
          ms_string = substring(mn_beg_pos,((textlen(ms_string_old) - mn_beg_pos)+ 1),ms_string_old)
         ENDIF
        OF 3:
         mn_beg_pos = findstring("Suggested Action to be taken:",ms_string_old),
         IF (mn_beg_pos > 0)
          IF (textlen(trim(ms_string)) > 0)
           mcr_inc_y_break
          ENDIF
          ms_string = substring(mn_beg_pos,((textlen(ms_string_old) - mn_beg_pos)+ 1),ms_string_old)
         ENDIF
        OF 4:
         mn_beg_pos = findstring("Addendum Notes:",ms_string_old),
         IF (mn_beg_pos > 0)
          IF (textlen(trim(ms_string)) > 0)
           mcr_inc_y_break
          ENDIF
          ms_string = substring(mn_beg_pos,((textlen(ms_string_old) - mn_beg_pos)+ 1),ms_string_old)
         ENDIF
       ENDCASE
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    row + 1,
    CALL print(calcpos(225,20)), "{F/5}{CPI/10}{U}",
    "Downtime ED Triage/Assessment Report", "{endu}", row + 1,
    CALL print(calcpos(20,40)), "{F/4}{CPI/12}", b,
    "Patient Name: ", eb, pat->pat_name,
    row + 1,
    CALL print(calcpos(400,40)), b,
    "Date & Time: ", eb, curdate,
    " ", curtime, row + 1,
    CALL print(calcpos(20,50)), b, "DOB: ",
    eb, pat->pat_dob, "( Age ",
    pat->pat_age, " )", row + 1,
    CALL print(calcpos(220,50)), b, "ACCT # : ",
    eb, pat->pat_fn, row + 1,
    CALL print(calcpos(400,50)), b, "MRN :",
    eb, pat->pat_mrn, y_pos += 10
   HEAD d.seq
    x_pos = 20, y_pos = 70,
    CALL print(calcpos(x_pos,y_pos)),
    b, "Allergy : ", eb,
    y_pos += 10
    IF ((pat->allergy_cnt=0))
     CALL print(calcpos(x_pos,y_pos)), "No Allergy Information Documented ", y_pos += 10
    ELSE
     FOR (i = 1 TO pat->allergy_cnt)
       CALL print(calcpos(x_pos,y_pos)), pat->allergy[i].alergy_info, y_pos += 10,
       row + 1
     ENDFOR
    ENDIF
   DETAIL
    y_pos += 10,
    CALL print(calcpos(x_pos,y_pos)), b,
    "Pre-Arrival", eb, mcr_inc_y_break,
    "-------------------------------------------------------------------"
    IF ((pat->s_pa_type != null))
     mcr_inc_y, b, "PA Type: ",
     eb, pat->s_pa_type
    ENDIF
    IF ((pat->s_referral_source != null))
     mcr_inc_y, b, "Referral Source: ",
     eb, pat->s_referral_source
    ENDIF
    IF ((pat->s_location != null))
     mcr_inc_y, b, "Location: ",
     eb, pat->s_location
    ENDIF
    IF ((pat->s_expect_callback_to != null))
     mcr_inc_y, b, "Expect Callback To: ",
     eb, pat->s_expect_callback_to
    ENDIF
    IF ((pat->s_callback_num != null))
     mcr_inc_y, b, "Call Back #: ",
     eb, pat->s_callback_num
    ENDIF
    IF ((pat->s_transport_mode != null))
     mcr_inc_y, b, "Transport Mode: ",
     eb, pat->s_transport_mode
    ENDIF
    IF ((pat->s_arrival_time != null))
     mcr_inc_y, b, "Arrival Time: ",
     eb, pat->s_arrival_time
    ENDIF
    IF ((pat->s_other_notes != null))
     mcr_inc_y, b, "Other Notes: ",
     eb, ms_string = pat->s_other_notes, print_text
    ENDIF
    y_pos += 10,
    CALL print(calcpos(x_pos,y_pos)), b,
    "EMS Handover", eb, mcr_inc_y_break,
    "-------------------------------------------------------------------"
    IF ((pat->s_ems_chief_complaint != null))
     mcr_inc_y, b, "EMS Chief Complaint/Mechanism of Injury: ",
     eb, ms_string = pat->s_ems_chief_complaint, print_text
    ENDIF
    IF ((pat->s_vital_signs_glucose != null))
     mcr_inc_y, b, "Vital Signs/Glucose POC: ",
     eb, pat->s_vital_signs_glucose
    ENDIF
    IF ((pat->s_ems_treatments_pta != null))
     mcr_inc_y, b, "EMS Treatments PTA: ",
     eb, ms_string = pat->s_ems_treatments_pta, print_text
    ENDIF
    IF ((pat->s_iv_fluids_amount_infused != null))
     mcr_inc_y, b, "IV Fluids Hung and Amount Infused: ",
     eb, pat->s_iv_fluids_amount_infused
    ENDIF
    IF ((pat->s_prn_angio_size_site != null))
     mcr_inc_y, b, "PRN Angio Size and Site: ",
     eb, pat->s_prn_angio_size_site
    ENDIF
    IF ((pat->s_handover_oxygen_saturation != null))
     mcr_inc_y, b, "Oxygen Saturation: ",
     eb, pat->s_handover_oxygen_saturation
    ENDIF
    IF ((pat->s_handover_liters_per_min != null))
     mcr_inc_y, b, "Liters per Minute: ",
     eb, pat->s_handover_liters_per_min
    ENDIF
    IF ((pat->s_handover_mode_delivery_oxy != null))
     mcr_inc_y, b, "Mode of Delivery (Oxygen): ",
     eb, pat->s_handover_mode_delivery_oxy
    ENDIF
    IF ((pat->s_ems_meds_admin_pta != null))
     mcr_inc_y, b, "EMS Meds Administered PTA: ",
     eb, ms_string = pat->s_ems_meds_admin_pta, print_text
    ENDIF
    IF ((pat->s_ems_addl_info != null))
     mcr_inc_y, b, "EMS Additional Information: ",
     eb, ms_string = pat->s_ems_addl_info, print_text
    ENDIF
    y_pos += 20,
    CALL print(calcpos(x_pos,y_pos)), b,
    "ED Triage/Assessment", eb, mcr_inc_y_break,
    "-------------------------------------------------------------------"
    IF ((pat->esi_acuity_val != null))
     mcr_inc_y, b, "ESI/Acuity: ",
     eb, pat->esi_acuity_val
    ENDIF
    IF ((pat->stated_complaint_val != null))
     mcr_inc_y, b, "Stated Complaint: ",
     eb, ms_string = pat->stated_complaint_val, print_text
    ENDIF
    IF ((pat->s_hist_pres_illness != null))
     mcr_inc_y, b, "History of Present Illness: ",
     eb, ms_string = pat->s_hist_pres_illness, print_text
    ENDIF
    IF ((pat->pmh_val != null))
     mcr_inc_y, b, "PMH:",
     eb, ms_string = pat->pmh_val, print_text
    ENDIF
    IF ((pat->comm_barriers != null))
     mcr_inc_y, b, "Communication Barrier : ",
     eb, pat->comm_barriers
    ENDIF
    IF ((pat->language_spoken != null))
     mcr_inc_y, b, "Language Spoken: ",
     eb, pat->language_spoken
    ENDIF
    IF ((pat->pat_arr_amb_val != null))
     mcr_inc_y, b, "Patient Arrived By Ambulance: ",
     eb, pat->pat_arr_amb_val
    ENDIF
    IF ((pat->weight_val != null))
     mcr_inc_y, b, "Weight: ",
     eb, pat->weight_val
    ENDIF
    IF ((pat->temperature_f_result_val != null))
     mcr_inc_y, b, "Temp: ",
     eb, pat->temperature_f_result_val
    ENDIF
    IF ((pat->tempature_route_f_result_val != null))
     mcr_inc_y, b, "Temp Route: ",
     eb, pat->tempature_route_f_result_val
    ENDIF
    IF ((pat->pulse_rate_f_val != null))
     mcr_inc_y, b, "Pulse Rate: ",
     eb, pat->pulse_rate_f_val
    ENDIF
    IF ((pat->respiratory_rate_f_val != null))
     mcr_inc_y, b, "Resp Rate: ",
     eb, pat->respiratory_rate_f_val
    ENDIF
    IF ((pat->oxygen_satur_l_val != null))
     mcr_inc_y, b, "Oxygen Saturation: ",
     eb, pat->oxygen_satur_l_val
    ENDIF
    IF ((pat->l_p_min_l_val != null))
     mcr_inc_y, b, "Liters per Minute: ",
     eb, pat->l_p_min_l_val
    ENDIF
    IF ((pat->mode_of_deli_l_val != null))
     mcr_inc_y, b, "Mode of Delivery (Oxygen): ",
     eb, pat->mode_of_deli_l_val
    ENDIF
    IF ((pat->systolic_blood_p_f_val != null))
     mcr_inc_y, b, "Systolic Blood Pressure: ",
     eb, pat->systolic_blood_p_f_val
    ENDIF
    IF ((pat->diastolic_blood_p_f_val != null))
     mcr_inc_y, b, "Diastolic Blood Pressure: ",
     eb, pat->diastolic_blood_p_f_val
    ENDIF
    IF ((pat->blood_p_sites_f_val != null))
     mcr_inc_y, b, "Blood pressure sites: ",
     eb, pat->blood_p_sites_f_val
    ENDIF
    pn_printed_initial_treatment = 0
    IF ((pat->initial_treatment_cnt != 0))
     mcr_inc_y_break, b, "Initial Treatment (ED):",
     eb, pn_printed_initial_treatment = 1
     FOR (ai = 1 TO pat->initial_treatment_cnt)
       FOR (ar = 1 TO size(pat->initial_treatment[ai].display,5))
         mcr_inc_y_xd_break,
         CALL print(build2(pat->initial_treatment[ai].display[ar].display_line)), row + 1
       ENDFOR
     ENDFOR
    ENDIF
    IF (pn_printed_initial_treatment=0
     AND (((pat->oxygen_satur_f_val != null)) OR ((((pat->l_p_min_f_val != null)) OR ((pat->
    mode_of_deli_f_val != null))) )) )
     mcr_inc_y_break, b, "Initial Treatment (ED):",
     eb
    ENDIF
    IF ((pat->oxygen_satur_f_val != null))
     mcr_inc_y, b, "Oxygen Saturation: ",
     eb, pat->oxygen_satur_f_val
    ENDIF
    IF ((pat->l_p_min_f_val != null))
     mcr_inc_y, b, "Liters per Minute: ",
     eb, pat->l_p_min_f_val
    ENDIF
    IF ((pat->mode_of_deli_f_val != null))
     mcr_inc_y, b, "Mode of Delivery (Oxygen): ",
     eb, pat->mode_of_deli_f_val
    ENDIF
    IF ((pat->acetaminophen_dose_route_cnt != 0))
     mcr_inc_y, b, "Acetaminophen Dose Route: ",
     eb
     FOR (ci = 1 TO pat->acetaminophen_dose_route_cnt)
       mcr_inc_y_xd_break,
       CALL print(build2(pat->acetaminophen_dose_route[ci].result_val," (",pat->
        acetaminophen_dose_route[ci].dta_dt_tm,")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->emla_dose_route_cnt != 0))
     mcr_inc_y, b, "EMLA Dose Route : ",
     eb
     FOR (di = 1 TO pat->emla_dose_route_cnt)
       mcr_inc_y_xd_break,
       CALL print(build2(pat->emla_dose_rout[di].result_val," (",pat->emla_dose_rout[di].dta_dt_tm,
        ")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->ibuprofen_dose_route_cnt != 0))
     mcr_inc_y, b, "Ibuprofen Dose Route : ",
     eb
     FOR (ei = 1 TO pat->ibuprofen_dose_route_cnt)
       mcr_inc_y_xd_break_row_inc,
       CALL print(build2(pat->ibuprofen_dose_route[ei].result_val," (",pat->ibuprofen_dose_route[ei].
        dta_dt_tm,")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->let_dose_route_cnt != 0))
     mcr_inc_y, b, "LET Dose Route : ",
     eb
     FOR (fi = 1 TO pat->let_dose_route_cnt)
       mcr_inc_y_xd_break_row_inc,
       CALL print(build2(pat->let_dose_route[fi].result_val," (",pat->let_dose_route[fi].dta_dt_tm,
        ")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->porparicaine_dose_route_cnt != 0))
     mcr_inc_y, b, "Proparicaine Dose Route: ",
     eb
     FOR (gi = 1 TO pat->porparicaine_dose_route_cnt)
       mcr_inc_y_xd_break_row_inc,
       CALL print(build2(pat->porparicaine_dose_route[gi].result_val," (",pat->
        porparicaine_dose_route[gi].dta_dt_tm,")")), row + 1
     ENDFOR
    ENDIF
    IF ((pat->ambulatroy_o_scen_val != null))
     mcr_inc_y_break, b, "Ambulatory On Scene: ",
     eb, pat->ambulatroy_o_scen_val
    ENDIF
    IF ((pat->pt_on_b_w_cerv_collar_val != null))
     mcr_inc_y_break, b, "Pt. on Backboard W/ Cervical Collar:",
     eb, pat->pt_on_b_w_cerv_collar_val
    ENDIF
    IF ((pat->c_sp_his_powergrid_val != null))
     mcr_inc_y_break, b, "C-Spine History Powergrid: ",
     eb, pat->c_sp_his_powergrid_val
    ENDIF
    IF ((pat->neck_pain_val != null))
     mcr_inc_y_xd_break_row_inc, "Neck Pain:", pat->neck_pain_val
    ENDIF
    IF ((pat->extremity_weakness_val != null))
     mcr_inc_y_xd_break_row_inc, "Extremity Weakness: ", pat->extremity_weakness_val
    ENDIF
    IF ((pat->parasthesia_val != null))
     mcr_inc_y_xd_break_row_inc, "Parasthesia Or Numbness:", pat->parasthesia_val
    ENDIF
    IF ((pat->hx_loss_val != null))
     mcr_inc_y_xd_break_row_inc, "Hx. Loss of Consciousness:", pat->hx_loss_val
    ENDIF
    IF ((pat->pt_has_distracting_val != null))
     mcr_inc_y_xd_break_row_inc, "Pt.Has Distracting Injury: ", pat->pt_has_distracting_val
    ENDIF
    IF ((pat->c_sp_phy_exam_pg_val != null))
     mcr_inc_y_break, b, "C-Spine Physical Exam powergrid: ",
     eb, pat->c_sp_phy_exam_pg_val
    ENDIF
    IF ((pat->mental_status_val != null))
     mcr_inc_y_xd_break_row_inc, "Mental Status Change:", pat->mental_status_val
    ENDIF
    IF ((pat->neurological_deficit_val != null))
     mcr_inc_y_xd_break_row_inc, "Neurological Deficit:", pat->neurological_deficit_val
    ENDIF
    IF ((pat->distracting_pain_val != null))
     mcr_inc_y_xd_break_row_inc, "Distracting Painful Injury:", pat->distracting_pain_val
    ENDIF
    IF ((pat->tenderness_on_neck_val != null))
     mcr_inc_y_xd_break_row_inc, "Tenderness On Neck Palpation:", pat->tenderness_on_neck_val
    ENDIF
    IF ((pat->palpable_defor_val != null))
     mcr_inc_y_xd_break_row_inc, "Palpable Deformity:", pat->palpable_defor_val
    ENDIF
    IF ((pat->pain_tenderness_val != null))
     mcr_inc_y_xd_break_row_inc, "Pain/Tenderness on Palpation:", pat->pain_tenderness_val
    ENDIF
    IF ((pat->c_sp_clin_cleared_val != null))
     mcr_inc_y_break, b, "C-spine Clinically Cleared: ",
     eb, pat->c_sp_clin_cleared_val
    ENDIF
    IF ((pat->c_sp_cleared_by_val != null))
     mcr_inc_y_break, b, "C-spine Cleared by: ",
     eb, pat->c_sp_cleared_by_val
    ENDIF
    IF ((pat->pat_clear_f_triage_val != null))
     mcr_inc_y_break, b, "Patient Cleared for Triage: ",
     eb, pat->pat_clear_f_triage_val
    ENDIF
   FOOT REPORT
    y_pos += 10, x_pos += 100, row + 1,
    CALL print(calcpos(x_pos,y_pos)), b, "End Of The Report",
    eb
   FOOT PAGE
    y_pos += 20, x_pos += 50, row + 1,
    CALL print(calcpos(225,y_pos)), b, "Page#:",
    curpage, eb, y_pos += 10,
    x_pos = 20,
    CALL print(calcpos(x_pos,y_pos)), b,
    "*** Report includes only select information from the above forms ***", eb, y_pos += 10,
    x_pos = 20,
    CALL print(calcpos(x_pos,y_pos)), b,
    "*** and no information from the Recheck or Reassessment Forms ***", eb
   WITH dio = 08, time = 30, maxcol = 500
  ;end select
  RETURN
 END ;Subroutine
#exit_program
END GO
