CREATE PROGRAM bhs_ma_fn_genv_ed_triage
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\f0 \fs12 \cb2 "
 SET wb = "{\b\cb2 "
 SET uf = " }"
 DECLARE displays = vc
 DECLARE eid = f8
 SET eid = request->visit[1].encntr_id
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 39823772.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 SET results = uar_get_code_by("displaykey",72,"STATEDCOMPLAINT")
 SET dur_sympt = uar_get_code_by("displaykey",72,"DURATIONOFSYMPTOMS")
 SET comm_barr = 885518.00
 SET dur_onset = uar_get_code_by("displaykey",72,"DURATIONONSET")
 SET other_comp = uar_get_code_by("displaykey",72,"OTHERCOMPLAINTS")
 SET language = uar_get_code_by("displaykey",72,"LANGUAGESPOKENV001")
 SET patient_arri = uar_get_code_by("displaykey",72,"PATIENTARRIVEDBYAMBULANCE")
 SET abc_stable = uar_get_code_by("displaykey",72,"ABCSTABLE")
 SET esi_acuity = uar_get_code_by("displaykey",72,"EDTRACKINGACUITY")
 SET chief_complnt = uar_get_code_by("displaykey",72,"CHIEFCOMPLAINT")
 SET vs_glucose = uar_get_code_by("displaykey",72,"VITALSIGNSGLUCOSEPOC")
 SET ems_treatment = uar_get_code_by("displaykey",72,"EMSTREATMENTS")
 SET iv_f_hung = uar_get_code_by("displaykey",72,"IVFLUIDSHUNG")
 SET iv_f_amnt_inf = uar_get_code_by("displaykey",72,"IVFLUIDSAMOUNTINFUSED")
 SET oxygen_satur = uar_get_code_by("displaykey",72,"OXYGENSATURATION")
 SET l_per_minute = uar_get_code_by("displaykey",72,"LITERSPERMINUTE")
 SET mod_of_delivery = uar_get_code_by("displaykey",72,"MODEOFDELIVERYOXYGEN")
 SET ems_med_adm_pta = uar_get_code_by("displaykey",72,"EMSMEDSADMINSTEREDPTA")
 SET albuterol_d_r = uar_get_code_by("displaykey",72,"ALBUTEROLDOSEROUTE")
 SET albuterol_w_atro = uar_get_code_by("displaykey",72,"ALBUTEROLWATROVENTDOSEROUTE")
 SET adenosine_d_r = uar_get_code_by("displaykey",72,"ADENOSINEDOSEROUTE")
 SET aspirin_d_r = uar_get_code_by("displaykey",72,"ASPIRINDOSEROUTE")
 SET ativan_d_r = uar_get_code_by("displaykey",72,"ATIVANDOSEROUTE")
 SET cardizem_d_r = uar_get_code_by("displaykey",72,"CARDIZEMDOSEROUTE")
 SET d50_d_r = uar_get_code_by("displaykey",72,"D50DOSEROUTE")
 SET glucose_d_r = uar_get_code_by("displaykey",72,"GLUCOSEORALDOSEROUTE")
 SET lasix_d_r = uar_get_code_by("displaykey",72,"LASIXDOSEROUTE")
 SET lopressor_d_r = uar_get_code_by("displaykey",72,"LOPRESSORDOSEROUTE")
 SET morphine_d_r = uar_get_code_by("displaykey",72,"MORPHINEDOSEROUTE")
 SET narcan_d_r = uar_get_code_by("displaykey",72,"NARCANDOSEROUTE")
 SET nitro_d_r = uar_get_code_by("displaykey",72,"NITRODOSEROUTE")
 SET valium_d_r = uar_get_code_by("displaykey",72,"VALIUMDOSEROUTE")
 SET pmh_d_r = uar_get_code_by("displaykey",72,"PMH")
 SET home_meds = uar_get_code_by("displaykey",72,"HOMEMEDS")
 SET ed_add_info = uar_get_code_by("displaykey",72,"EDADDITIONALINFORMATION")
 DECLARE cs120_ocf_compression_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 RECORD pt_info(
   1 patient_id = f8
   1 encounter_id = f8
   1 patient_name = vc
   1 patient_birth = dq8
   1 last_charted = vc
   1 dta = f8
   1 result_val = vc
   1 dur_symptom = vc
   1 comm_barr_val = vc
   1 dur_onset_val = vc
   1 other_comp_val = vc
   1 other_comp_event_id = f8
   1 language_val = vc
   1 pat_arr_val = vc
   1 abc_stable_val = vc
   1 esi_acuity_val = vc
   1 chief_complnt_val = vc
   1 vs_glucose_val = vc
   1 ems_treatment_val = vc
   1 iv_f_hung_val = vc
   1 iv_f_amnt_inf_val = vc
   1 oxygen_satur_val = vc
   1 l_per_minute_val = vc
   1 mod_of_delivery_val = vc
   1 ems_med_adm_pta_val = vc
   1 albuterol_d_r_val = vc
   1 albuterol_w_atro_val = vc
   1 adenosine_d_r_val = vc
   1 aspirin_d_r_val = vc
   1 ativan_d_r_val = vc
   1 cardizem_d_r_val = vc
   1 d50_d_r_val = vc
   1 glucose_d_r_val = vc
   1 lasix_d_r_val = vc
   1 lopressor_d_r_val = vc
   1 morphine_d_r_val = vc
   1 narcan_d_r_val = vc
   1 nitro_d_r_val = vc
   1 valium_d_r_val = vc
   1 pmh_d_r_val = vc
   1 home_meds_val = vc
   1 ed_add_info_val = vc
 )
 SELECT DISTINCT INTO "nl:"
  e.person_id, e.encntr_id
  FROM encounter e
  WHERE (e.encntr_id=request->visit[1].encntr_id)
  DETAIL
   pt_info->patient_id = e.person_id, pt_info->encounter_id = e.encntr_id,
   CALL echorecord(pt_info)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  age = cnvtage(p.birth_dt_tm), p.person_id, p.name_full_formatted
  FROM person p
  WHERE (p.person_id=pt_info->patient_id)
  DETAIL
   pt_info->patient_name = p.name_full_formatted, pt_info->patient_birth = p.birth_dt_tm, pt_info->
   patient_id = p.person_id,
   CALL echorecord(pt_info)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_cd, ce.result_val
  FROM clinical_event ce
  WHERE (ce.encntr_id=request->visit[1].encntr_id)
   AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
   AND ce.result_status_cd IN (25.00, 34.00, 35.00)
   AND ((ce.event_cd+ 0) IN (results, dur_sympt, comm_barr, dur_onset, other_comp,
  language, patient_arri, abc_stable, esi_acuity, chief_complnt,
  vs_glucose, ems_treatment, iv_f_hung, iv_f_amnt_inf, oxygen_satur,
  l_per_minute, mod_of_delivery, ems_med_adm_pta, albuterol_d_r, albuterol_w_atro,
  adenosine_d_r, aspirin_d_r, ativan_d_r, cardizem_d_r, d50_d_r,
  glucose_d_r, lasix_d_r, lopressor_d_r, morphine_d_r, narcan_d_r,
  nitro_d_r, valium_d_r, pmh_d_r, home_meds, ed_add_info))
  ORDER BY ce.clinsig_updt_dt_tm
  HEAD ce.event_cd
   IF (ce.event_cd=results)
    pt_info->result_val = build2(wb,"Stated Complaint:",uf,trim(ce.result_val)," (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=dur_sympt)
    pt_info->dur_symptom = build2(wb,"Duration of Symptoms: ",uf,trim(ce.result_val)," (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=885518.00)
    pt_info->comm_barr_val = build2(wb,"Communication Barriers:",uf,trim(ce.result_val),"  (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=dur_onset)
    pt_info->dur_onset_val = build2(wb,"Duration Onset:",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=other_comp)
    pt_info->other_comp_event_id = ce.event_id
   ELSEIF (ce.event_cd=language)
    pt_info->language_val = build2(wb,"Language Spoken",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=patient_arri)
    pt_info->pat_arr_val = build2("Patient Arrived by Ambulance: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),
     ") ",reol)
   ELSEIF (ce.event_cd=abc_stable)
    pt_info->abc_stable_val = build2(wb,"ABC Stable:",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=chief_complnt)
    pt_info->chief_complnt_val = build2(wb,"Chief Complaint",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=vs_glucose)
    pt_info->vs_glucose_val = build2(wb,"Vital Signs/Glucose POC:",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=ems_treatment)
    pt_info->ems_med_adm_pta_val = build2(wb,"EMS Treatments PTA: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=iv_f_hung)
    pt_info->iv_f_hung_val = build2(wb,"IV Fluids Hung: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=iv_f_amnt_inf)
    pt_info->iv_f_amnt_inf_val = build2(wb,"IV Fluids Amount Infused: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=oxygen_satur)
    pt_info->oxygen_satur_val = build2(wb,"Oxygen Saturation: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=l_per_minute)
    pt_info->l_per_minute_val = build2(wb,"Liters per Minute: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=mod_of_delivery)
    pt_info->mod_of_delivery_val = build2(wb,"Mode of Delivery (Oxygen): ",uf,trim(ce.result_val),
     "   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=ems_med_adm_pta)
    pt_info->ems_med_adm_pta_val = build2(wb,"EMS Meds Administered PTA: ",uf,trim(ce.result_val),
     "   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),") ",reol)
   ELSEIF (ce.event_cd=albuterol_d_r)
    pt_info->albuterol_d_r_val = build2(wb,"Albuterol Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D"),reol)
   ELSEIF (ce.event_cd=albuterol_w_atro)
    pt_info->albuterol_w_atro_val = build2(wb,"Albuterol w/Atrovent Dose & Route: ",uf,trim(ce
      .result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=adenosine_d_r)
    pt_info->adenosine_d_r_val = build2(wb,"Adenosine Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=aspirin_d_r)
    pt_info->aspirin_d_r_val = build2(wb,"Aspirin Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")"," ",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D"),reol)
   ELSEIF (ce.event_cd=ativan_d_r)
    pt_info->ativan_d_r_val = build2(wb,"Ativan Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=cardizem_d_r)
    pt_info->cardizem_d_r_val = build2(wb,"Cardizem Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=d50_d_r)
    pt_info->d50_d_r_val = build2(wb,"D50 Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=glucose_d_r)
    pt_info->glucose_d_r_val = build2(wb,"Glucose (Oral) dose & Route: ",uf,trim(ce.result_val),
     "   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=lasix_d_r)
    pt_info->lasix_d_r_val = build2(wb,"Lasix Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=lopressor_d_r)
    pt_info->lopressor_d_r_val = build2(wb,"Lopressor Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=morphine_d_r)
    pt_info->morphine_d_r_val = build2(wb,"Morphine Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=narcan_d_r)
    pt_info->narcan_d_r_val = build2(wb,"Narcan Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=nitro_d_r)
    pt_info->nitro_d_r_val = build2(wb,"Nitro Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=valium_d_r)
    pt_info->valium_d_r_val = build2(wb,"Valium Dose & Route: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=pmh_d_r)
    pt_info->pmh_d_r_val = build2(wb,"PMH: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=home_meds)
    pt_info->home_meds_val = build2(wb,"Home Meds: ",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ELSEIF (ce.event_cd=ed_add_info)
    pt_info->ed_add_info_val = build2(wb,"ED Additional Information:",uf,trim(ce.result_val),"   (",
     format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
   ENDIF
  HEAD ce.clinsig_updt_dt_tm
   pt_info->last_charted = format(ce.clinsig_updt_dt_tm,"MM/DD/YY HH:MM;;;D")
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM ce_blob cb
  WHERE (cb.event_id=pt_info->other_comp_event_id)
   AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   blob_size = cnvtint(cb.blob_length), blob_in = fillstring(64000," "), blob_out = fillstring(64000,
    " "),
   blob_rtf = fillstring(64000," "), blob_ret_len = 0, blob_in = cb.blob_contents
   IF (cb.compression_cd=cs120_ocf_compression_cd)
    CALL uar_ocf_uncompress(blob_in,blob_size,blob_out,64000,blob_ret_len),
    CALL uar_rtf2(blob_out,blob_ret_len,blob_rtf,64000,blob_ret_len,1)
   ELSE
    CALL uar_rtf2(blob_in,blob_size,blob_rtf,64000,blob_ret_len,1)
   ENDIF
   pt_info->other_comp_val = build2(wb,"Other Complaints:",uf,blob_rtf,"   (",
    format(cb.valid_from_dt_tm,"MM/DD/YY HH:MM;;;D"),")",reol)
  WITH nocounter
 ;end select
 CALL echorecord(pt_info)
 SET displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET reply->text = build2(displays,
  IF ((pt_info->result_val=null)) null
  ELSE pt_info->result_val
  ENDIF
  ,
  IF ((pt_info->dur_onset_val=null)) null
  ELSE pt_info->dur_onset_val
  ENDIF
  ,
  IF ((pt_info->dur_symptom=null)) null
  ELSE pt_info->dur_symptom
  ENDIF
  ,
  IF ((pt_info->abc_stable_val=null)) null
  ELSE pt_info->abc_stable_val
  ENDIF
  ,
  IF ((pt_info->esi_acuity_val=null)) null
  ELSE pt_info->esi_acuity_val
  ENDIF
  ,
  IF ((pt_info->other_comp_val=null)) null
  ELSE pt_info->other_comp_val
  ENDIF
  ,
  IF ((pt_info->comm_barr_val=null)) null
  ELSE pt_info->comm_barr_val
  ENDIF
  ,
  IF ((pt_info->language_val=null)) null
  ELSE pt_info->language_val
  ENDIF
  ,
  IF ((pt_info->pat_arr_val=null)) null
  ELSE pt_info->pat_arr_val
  ENDIF
  ,
  IF ((pt_info->chief_complnt_val=null)) null
  ELSE pt_info->chief_complnt_val
  ENDIF
  ,
  IF ((pt_info->vs_glucose_val=null)) null
  ELSE pt_info->vs_glucose_val
  ENDIF
  ,
  IF ((pt_info->ems_treatment_val=null)) null
  ELSE pt_info->ems_treatment_val
  ENDIF
  ,
  IF ((pt_info->iv_f_hung_val=null)) null
  ELSE pt_info->iv_f_hung_val
  ENDIF
  ,
  IF ((pt_info->iv_f_amnt_inf_val=null)) null
  ELSE pt_info->iv_f_amnt_inf_val
  ENDIF
  ,
  IF ((pt_info->oxygen_satur_val=null)) null
  ELSE pt_info->oxygen_satur_val
  ENDIF
  ,
  IF ((pt_info->l_per_minute_val=null)) null
  ELSE pt_info->l_per_minute_val
  ENDIF
  ,
  IF ((pt_info->mod_of_delivery_val=null)) null
  ELSE pt_info->mod_of_delivery_val
  ENDIF
  ,
  IF ((pt_info->ems_med_adm_pta_val=null)) null
  ELSE pt_info->ems_med_adm_pta_val
  ENDIF
  ,
  IF ((pt_info->albuterol_d_r_val=null)) null
  ELSE pt_info->albuterol_d_r_val
  ENDIF
  ,
  IF ((pt_info->albuterol_w_atro_val=null)) null
  ELSE pt_info->albuterol_w_atro_val
  ENDIF
  ,
  IF ((pt_info->adenosine_d_r_val=null)) null
  ELSE pt_info->adenosine_d_r_val
  ENDIF
  ,
  IF ((pt_info->aspirin_d_r_val=null)) null
  ELSE pt_info->aspirin_d_r_val
  ENDIF
  ,
  IF ((pt_info->ativan_d_r_val=null)) null
  ELSE pt_info->ativan_d_r_val
  ENDIF
  ,
  IF ((pt_info->cardizem_d_r_val=null)) null
  ELSE pt_info->cardizem_d_r_val
  ENDIF
  ,
  IF ((pt_info->d50_d_r_val=null)) null
  ELSE pt_info->d50_d_r_val
  ENDIF
  ,
  IF ((pt_info->glucose_d_r_val=null)) null
  ELSE pt_info->glucose_d_r_val
  ENDIF
  ,
  IF ((pt_info->lasix_d_r_val=null)) null
  ELSE pt_info->lasix_d_r_val
  ENDIF
  ,
  IF ((pt_info->lopressor_d_r_val=null)) null
  ELSE pt_info->lopressor_d_r_val
  ENDIF
  ,
  IF ((pt_info->morphine_d_r_val=null)) null
  ELSE pt_info->morphine_d_r_val
  ENDIF
  ,
  IF ((pt_info->narcan_d_r_val=null)) null
  ELSE pt_info->narcan_d_r_val
  ENDIF
  ,
  IF ((pt_info->nitro_d_r_val=null)) null
  ELSE pt_info->nitro_d_r_val
  ENDIF
  ,
  IF ((pt_info->valium_d_r_val=null)) null
  ELSE pt_info->valium_d_r_val
  ENDIF
  ,
  IF ((pt_info->pmh_d_r_val=null)) null
  ELSE pt_info->pmh_d_r_val
  ENDIF
  ,
  IF ((pt_info->home_meds_val=null)) null
  ELSE pt_info->home_meds_val
  ENDIF
  ,
  IF ((pt_info->ed_add_info_val=null)) null
  ELSE pt_info->ed_add_info_val
  ENDIF
  ,reply->text,"}}")
END GO
