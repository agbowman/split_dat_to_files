CREATE PROGRAM bhs_ma_fn_genv_ed_vital
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\f0 \fs18 \cb2 "
 SET wb = "{\b\cb2"
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
 SET weight = uar_get_code_by("displaykey",72,"WEIGHT")
 RECORD pt_info(
   1 patient_id = f8
   1 encounter_id = f8
   1 patient_name = vc
   1 patient_birth = dq8
   1 last_charted = vc
   1 dta = f8
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
   1 weight_val = vc
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
   AND ce.event_end_dt_tm >= cnvtlookbehind("240,MIN",cnvtdatetime(curdate,curtime3))
   AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
   AND ((ce.event_cd+ 0) IN (pulse_rate, temperature, temp_route, resp_rate, o2_sat,
  l_per_min, mode_delivery, systolic, diastolic, map,
  weight, blood_p_site))
  ORDER BY ce.clinsig_updt_dt_tm
  HEAD ce.event_cd
   IF (ce.event_cd=temperature)
    pt_info->temperature_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=temp_route)
    pt_info->temp_route_val = build2(trim(ce.result_val),"    (  ",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=pulse_rate)
    pt_info->pulse_rate_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=resp_rate)
    pt_info->resp_rate_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=o2_sat)
    pt_info->o2_sat_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=l_per_min)
    pt_info->l_per_min_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=mode_delivery)
    pt_info->mode_delivery_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=systolic)
    pt_info->systolic_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=diastolic)
    pt_info->diastolic_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=map)
    pt_info->map_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=blood_p_site)
    pt_info->blood_p_site_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ELSEIF (ce.event_cd=weight)
    pt_info->weight_val = build2(trim(ce.result_val),"     (",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;;D")," ) ")
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET reply->text = build2(displays,wb,"Temp:  ",uf,pt_info->temperature_val,
  reol,wb,"Route: ",uf,pt_info->temp_route_val,
  reol,wb,"Pulse: ",uf,pt_info->pulse_rate_val,
  reol,wb,"Resp. Rate: ",uf,pt_info->resp_rate_val,
  reol,wb,"O2 Sat: ",uf,pt_info->o2_sat_val,
  reol,wb,"L/Min: ",uf,pt_info->l_per_min_val,
  reol,wb,"Mode of Delivery: ",uf,pt_info->mode_delivery_val,
  reol,wb,"Systolic B/P: ",uf,pt_info->systolic_val,
  reol,wb,"Diastolic B/P: ",uf,pt_info->diastolic_val,
  reol,wb,"MAP: ",uf,pt_info->map_val,
  reol,wb,"B/P Site: ",uf,pt_info->blood_p_site_val,
  reol,wb,"Weight: ",uf,pt_info->weight_val,
  reol,reply->text,"}}")
END GO
