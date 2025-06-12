CREATE PROGRAM bhs_ma_fn_genv_ed_reassm
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\f0 \fs18 \cb2 "
 SET wb = "{\b\cb2"
 SET uf = " }"
 SET cl = ":"
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
  SET request->visit[1].encntr_id = 42448992.00
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
 SET pulse_rate = uar_get_code_by("displaykey",72,"PULSERATE")
 SET temperature = uar_get_code_by("displaykey",72,"TEMPERATURE")
 SET temp_route = uar_get_code_by("displaykey",72,"TEMPERATUREROUTE")
 SET resp_rate = uar_get_code_by("displaykey",72,"RESPIRATORYRATE")
 SET o2_sat = uar_get_code_by("displaykey",72,"OXYGENSATURATION")
 SET l_per_min = uar_get_code_by("displaykey",72,"LITERSPERMINUTE")
 SET mode_delivery = uar_get_code_by("displaykey",72,"MODEOFDELIVERYOXYGEN")
 SET systolic = uar_get_code_by("displaykey",72,"SYSTOLICBLOODPRESSURE")
 SET diastolic = uar_get_code_by("displaykey",72,"DIASTOLICBLOODPRESSURE")
 SET map = uar_get_code_by("displaykey",72,"MEANARTERIALPRESSURE")
 SET blood_p_site = uar_get_code_by("displaykey",72,"BLOODPRESSURESITES")
 SET stated_comp = uar_get_code_by("displaykey",72,"STATEDCOMPLAINT")
 SET inital_treat = uar_get_code_by("displaykey",72,"INITIALTREATMENTSED")
 SET acetamin_do_rt = uar_get_code_by("displaykey",72,"ACETAMINIPHENDOSEROUTE")
 SET emla_do_rt = uar_get_code_by("displaykey",72,"EMLADOSEROUTE")
 SET ibuprofen_do_rt = uar_get_code_by("displaykey",72,"IBUPROFENDOSEROUTE")
 SET let_do_rt = uar_get_code_by("displaykey",72,"LETDOSEROUTE")
 SET porparicaine_dose_r = uar_get_code_by("displaykey",72,"PROPARICAINEDOSEROUTE")
 SET tra_comments = uar_get_code_by("displaykey",72,"TRACOMMENTS")
 RECORD pt_info(
   1 patient_id = f8
   1 encounter_id = f8
   1 patient_name = vc
   1 patient_birth = dq8
   1 last_charted = vc
   1 dta = f8
   1 stated_comp_val = vc
   1 pulse_rate_val = vc
   1 temperature_val = vc
   1 temp_route_val = vc
   1 resp_rate_val = vc
   1 o2_sat_val = vc
   1 l_per_min_val = vc
   1 mode_delivery_val = vc
   1 systolic_val = vc
   1 diastolic_val = vc
   1 map_val = vc
   1 blood_p_site_val = vc
   1 inital_treat_val = vc
   1 acetamin_do_rt_val = vc
   1 emla_do_rt_val = vc
   1 ibuprofen_do_rt_val = vc
   1 let_do_rt_val = vc
   1 porparicaine_dose_r_val = vc
   1 tra_comments_val = vc
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
   patient_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_cd, ce.result_val
  FROM clinical_event ce
  WHERE (ce.encntr_id=request->visit[1].encntr_id)
   AND ((ce.event_end_dt_tm+ 0) >= cnvtlookbehind("240,MIN",cnvtdatetime(curdate,curtime3)))
   AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
   AND ((ce.result_status_cd+ 0) IN (25.00, 34.00, 35.00))
   AND ((ce.event_cd+ 0) IN (pulse_rate, temperature, temp_route, resp_rate, o2_sat,
  l_per_min, mode_delivery, systolic, diastolic, map,
  blood_p_site, stated_comp, inital_treat, acetamin_do_rt, emla_do_rt,
  ibuprofen_do_rt, let_do_rt, porparicaine_dose_r, tra_comments))
  ORDER BY ce.clinsig_updt_dt_tm
  HEAD ce.event_cd
   IF (ce.event_cd=stated_comp)
    pt_info->stated_comp_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=temperature)
    pt_info->temperature_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=temp_route)
    pt_info->temp_route_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=pulse_rate)
    pt_info->pulse_rate_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=resp_rate)
    pt_info->resp_rate_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=o2_sat)
    pt_info->o2_sat_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce.result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=l_per_min)
    pt_info->l_per_min_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=mode_delivery)
    pt_info->mode_delivery_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=systolic)
    pt_info->systolic_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=diastolic)
    pt_info->diastolic_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=map)
    pt_info->map_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce.result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=blood_p_site)
    pt_info->blood_p_site_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=inital_treat)
    pt_info->inital_treat_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=acetamin_do_rt)
    pt_info->acetamin_do_rt_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=emla_do_rt)
    pt_info->emla_do_rt_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=ibuprofen_do_rt)
    pt_info->ibuprofen_do_rt_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=porparicaine_dose_r)
    pt_info->porparicaine_dose_r_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(
      ce.result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ELSEIF (ce.event_cd=tra_comments)
    pt_info->tra_comments_val = build2(wb,trim(uar_get_code_display(ce.event_cd)),cl,uf,trim(ce
      .result_val),
     "     (",format(ce.event_end_dt_tm,"MM/DD/YY HH:MM;;;D")," ) ",reol)
   ENDIF
  WITH nocounter, time = 30
 ;end select
 CALL echorecord(pt_info)
 SET displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET reply->text = build2(displays,pt_info->stated_comp_val,pt_info->temperature_val,pt_info->
  temp_route_val,pt_info->pulse_rate_val,
  pt_info->resp_rate_val,pt_info->o2_sat_val,pt_info->l_per_min_val,pt_info->mode_delivery_val,
  pt_info->systolic_val,
  pt_info->diastolic_val,pt_info->map_val,pt_info->blood_p_site_val,pt_info->inital_treat_val,pt_info
  ->acetamin_do_rt_val,
  pt_info->emla_do_rt_val,reol,pt_info->ibuprofen_do_rt_val,pt_info->let_do_rt_val,pt_info->
  porparicaine_dose_r_val,
  pt_info->tra_comments_val,reply->text,"}}")
END GO
