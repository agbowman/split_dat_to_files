CREATE PROGRAM bhs_mp_pa_pressure_json:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID" = 0
  WITH outdev, f_person_id
 FREE RECORD pa_pressure_data
 RECORD pa_pressure_data(
   1 f_person_id = f8
   1 l_pa_pressure_monitoring_enrollment_ind = i4
   1 l_readings_cnt = i4
   1 qual[*]
     2 d_ce_dt_tm = dq8
     2 s_ce_date = vc
     2 s_ce_time = vc
     2 s_time_classification = vc
     2 f_ce_parent_event_id = f8
     2 s_reading_source = vc
     2 s_reading_status = vc
     2 s_pa_diastolic_pressure = vc
     2 s_pa_mean_pressure = vc
     2 s_pa_systolic_pressure = vc
     2 s_heart_rate = vc
     2 s_primary_metric = vc
     2 s_pa_diastolic_pressure_goal = vc
     2 s_pa_mean_pressure_goal = vc
     2 s_pa_diastolic_upper_bound = vc
     2 s_pa_diastolic_lower_bound = vc
     2 s_pa_mean_pressure_lower_bound = vc
     2 s_pa_mean_pressure_upper_bound = vc
     2 s_pa_systolic_lower_bound = vc
     2 s_pa_systolic_upper_bound = vc
     2 s_heart_rate_lower_bound = vc
     2 s_heart_rate_upper_bound = vc
 )
 DECLARE mf_cs8_auth_verified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs72_primary_metric_used_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRIMARYMETRICUSEDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_dia_pres_goal_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PADIASTOLICPRESSUREGOALPAIMPLANT")), protect
 DECLARE mf_cs72_pa_dia_lower_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPDIASTOLICLOWERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_dia_upper_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPDIASTOLICUPPERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_mean_pres_goal_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAMEANPRESSUREGOALPAIMPLANT")), protect
 DECLARE mf_cs72_mean_pres_lwr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPMEANLOWERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_mean_pres_uppr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPMEANUPPERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_sys_lower_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPSYSTOLICLOWERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_sys_upper_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAPSYSTOLICUPPERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_hr_lower_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEARTRATELOWERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_hr_upper_bnd_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEARTRATEUPPERBOUNDPAIMPLANT")), protect
 DECLARE mf_cs72_pa_systolic_pressure_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PASYSTOLICPRESSUREPAIMPLANT")), protect
 DECLARE mf_cs72_pa_diastolic_pressure_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PADIASTOLICPRESSUREPAIMPLANT")), protect
 DECLARE mf_cs72_pa_mean_pressure_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PAMEANPRESSUREPAIMPLANT")), protect
 DECLARE mf_cs72_heart_rate_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEARTRATEPAIMPLANT")), protect
 DECLARE mf_cs72_reading_source_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "READINGSOURCEPAIMPLANT")), protect
 DECLARE mf_cs72_reading_status_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "READINGSTATUSPAIMPLANT")), protect
 DECLARE mf_cs72_pa_press_mntr_enrl_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PULMONARYARTERYPRESSUREMONITORINGENR")), protect
 DECLARE mf_cs72_canceled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED")),
 protect
 CALL echo(build2("mf_CS8_AUTH_VERIFIED_CD = ",mf_cs8_auth_verified_cd))
 CALL echo(build2("mf_CS8_ALTERED_CD = ",mf_cs8_altered_cd))
 CALL echo(build2("mf_CS8_MODIFIED_CD = ",mf_cs8_modified_cd))
 CALL echo(build2("mf_CS72_PRIMARY_METRIC_USED_CD = ",mf_cs72_primary_metric_used_cd))
 CALL echo(build2("mf_CS72_PA_DIA_PRES_GOAL_CD = ",mf_cs72_pa_dia_pres_goal_cd))
 CALL echo(build2("mf_CS72_PA_DIA_LOWER_BND_CD = ",mf_cs72_pa_dia_lower_bnd_cd))
 CALL echo(build2("mf_CS72_PA_DIA_UPPER_BND_CD = ",mf_cs72_pa_dia_upper_bnd_cd))
 CALL echo(build2("mf_CS72_PA_MEAN_PRES_GOAL_CD = ",mf_cs72_pa_mean_pres_goal_cd))
 CALL echo(build2("mf_CS72_MEAN_PRES_LWR_CD = ",mf_cs72_mean_pres_lwr_cd))
 CALL echo(build2("mf_CS72_MEAN_PRES_UPPR_CD = ",mf_cs72_mean_pres_uppr_cd))
 CALL echo(build2("mf_CS72_PA_SYS_LOWER_BND_CD = ",mf_cs72_pa_sys_lower_bnd_cd))
 CALL echo(build2("mf_CS72_PA_SYS_UPPER_BND_CD = ",mf_cs72_pa_sys_upper_bnd_cd))
 CALL echo(build2("mf_CS72_HR_LOWER_BND_CD = ",mf_cs72_hr_lower_bnd_cd))
 CALL echo(build2("mf_CS72_HR_UPPER_BND_CD = ",mf_cs72_hr_upper_bnd_cd))
 CALL echo(build2("mf_CS72_PA_SYSTOLIC_PRESSURE_CD = ",mf_cs72_pa_systolic_pressure_cd))
 CALL echo(build2("mf_CS72_PA_DIASTOLIC_PRESSURE_CD = ",mf_cs72_pa_diastolic_pressure_cd))
 CALL echo(build2("mf_CS72_PA_MEAN_PRESSURE_CD = ",mf_cs72_pa_mean_pressure_cd))
 CALL echo(build2("mf_CS72_HEART_RATE_CD = ",mf_cs72_heart_rate_cd))
 CALL echo(build2("mf_CS72_READING_SOURCE_CD = ",mf_cs72_reading_source_cd))
 CALL echo(build2("mf_CS72_READING_STATUS_CD = ",mf_cs72_reading_status_cd))
 CALL echo(build2("mf_CS72_PA_PRESS_MNTR_ENRL_CD = ",mf_cs72_pa_press_mntr_enrl_cd))
 CALL echo(build2("mf_CS72_CANCELED_CD = ",mf_cs72_canceled_cd))
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id= $F_PERSON_ID)
    AND o.order_status_cd != mf_cs72_canceled_cd
    AND o.catalog_cd=mf_cs72_pa_press_mntr_enrl_cd)
  ORDER BY o.person_id
  HEAD o.person_id
   pa_pressure_data->l_pa_pressure_monitoring_enrollment_ind = 1,
   CALL echo("Patient has PA Pressure Monitoring Enrollment")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.encntr_id, ce.person_id, ce.event_cd,
  ce_event_disp = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.event_end_dt_tm >= cnvtlookbehind("90,D")
    AND (ce.person_id= $F_PERSON_ID)
    AND ce.result_status_cd IN (mf_cs8_auth_verified_cd, mf_cs8_altered_cd, mf_cs8_modified_cd)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.result_val > " "
    AND ce.event_cd IN (mf_cs72_pa_systolic_pressure_cd, mf_cs72_pa_diastolic_pressure_cd,
   mf_cs72_pa_mean_pressure_cd, mf_cs72_heart_rate_cd, mf_cs72_reading_status_cd,
   mf_cs72_reading_source_cd))
  ORDER BY ce.person_id, ce.event_end_dt_tm DESC, ce.parent_event_id
  HEAD REPORT
   pl_cnt = 0, pl_differenceindaysrounded = 0
  HEAD ce.person_id
   pa_pressure_data->f_person_id = ce.person_id,
   CALL echo("Inside Head ce.person_id")
  HEAD ce.parent_event_id
   pl_cnt += 1
   IF (mod(pl_cnt,10)=1)
    stat = alterlist(pa_pressure_data->qual,(pl_cnt+ 9))
   ENDIF
   CALL echo("Inside head ce.parent_event_id"), pa_pressure_data->qual[pl_cnt].f_ce_parent_event_id
    = ce.parent_event_id, pl_differenceindaysrounded = cnvtint(datetimediff(cnvtdatetime(sysdate),
     cnvtdatetime(cnvtdate(ce.event_end_dt_tm),0)))
   IF (pl_differenceindaysrounded <= 14)
    pa_pressure_data->qual[pl_cnt].s_time_classification = "fourteendays"
   ELSEIF (pl_differenceindaysrounded > 14
    AND pl_differenceindaysrounded <= 30)
    pa_pressure_data->qual[pl_cnt].s_time_classification = "thirtydays"
   ELSEIF (pl_differenceindaysrounded > 30
    AND pl_differenceindaysrounded <= 90)
    pa_pressure_data->qual[pl_cnt].s_time_classification = "ninetydays"
   ENDIF
  DETAIL
   CASE (ce.event_cd)
    OF mf_cs72_pa_diastolic_pressure_cd:
     pa_pressure_data->qual[pl_cnt].s_pa_diastolic_pressure = ce.result_val,pa_pressure_data->qual[
     pl_cnt].d_ce_dt_tm = ce.event_end_dt_tm,pa_pressure_data->qual[pl_cnt].s_ce_date = format(ce
      .event_end_dt_tm,"mm/dd/yyyy;;d"),
     pa_pressure_data->qual[pl_cnt].s_ce_time = format(ce.event_end_dt_tm,"hh:mm;;d")
    OF mf_cs72_pa_systolic_pressure_cd:
     pa_pressure_data->qual[pl_cnt].s_pa_systolic_pressure = ce.result_val
    OF mf_cs72_pa_mean_pressure_cd:
     pa_pressure_data->qual[pl_cnt].s_pa_mean_pressure = ce.result_val
    OF mf_cs72_heart_rate_cd:
     pa_pressure_data->qual[pl_cnt].s_heart_rate = ce.result_val
    OF mf_cs72_reading_status_cd:
     pa_pressure_data->qual[pl_cnt].s_reading_status = ce.result_val
    OF mf_cs72_reading_source_cd:
     pa_pressure_data->qual[pl_cnt].s_reading_source = ce.result_val
   ENDCASE
  FOOT REPORT
   stat = alterlist(pa_pressure_data->qual,pl_cnt), pa_pressure_data->l_readings_cnt = pl_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d1  WITH seq = size(pa_pressure_data->qual,5))
  PLAN (d1)
   JOIN (ce
   WHERE ce.event_end_dt_tm <= cnvtdatetime(pa_pressure_data->qual[d1.seq].d_ce_dt_tm)
    AND (ce.person_id=pa_pressure_data->f_person_id)
    AND ce.result_status_cd IN (mf_cs8_auth_verified_cd, mf_cs8_altered_cd, mf_cs8_modified_cd)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.result_val > " "
    AND ce.event_cd IN (mf_cs72_primary_metric_used_cd, mf_cs72_pa_dia_pres_goal_cd,
   mf_cs72_pa_dia_lower_bnd_cd, mf_cs72_pa_dia_upper_bnd_cd, mf_cs72_pa_mean_pres_goal_cd,
   mf_cs72_mean_pres_lwr_cd, mf_cs72_mean_pres_uppr_cd, mf_cs72_pa_sys_lower_bnd_cd,
   mf_cs72_pa_sys_upper_bnd_cd, mf_cs72_hr_lower_bnd_cd,
   mf_cs72_hr_upper_bnd_cd))
  ORDER BY ce.person_id, ce.event_end_dt_tm, ce.event_cd
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.person_id
   null
  HEAD ce.event_end_dt_tm
   null
  DETAIL
   CASE (ce.event_cd)
    OF mf_cs72_primary_metric_used_cd:
     pa_pressure_data->qual[d1.seq].s_primary_metric = ce.result_val
    OF mf_cs72_pa_dia_pres_goal_cd:
     pa_pressure_data->qual[d1.seq].s_pa_diastolic_pressure_goal = ce.result_val
    OF mf_cs72_pa_dia_lower_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_pa_diastolic_lower_bound = ce.result_val
    OF mf_cs72_pa_dia_upper_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_pa_diastolic_upper_bound = ce.result_val
    OF mf_cs72_pa_mean_pres_goal_cd:
     pa_pressure_data->qual[d1.seq].s_pa_mean_pressure_goal = ce.result_val
    OF mf_cs72_mean_pres_lwr_cd:
     pa_pressure_data->qual[d1.seq].s_pa_mean_pressure_lower_bound = ce.result_val
    OF mf_cs72_mean_pres_uppr_cd:
     pa_pressure_data->qual[d1.seq].s_pa_mean_pressure_upper_bound = ce.result_val
    OF mf_cs72_pa_sys_lower_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_pa_systolic_lower_bound = ce.result_val
    OF mf_cs72_pa_sys_upper_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_pa_systolic_upper_bound = ce.result_val
    OF mf_cs72_hr_lower_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_heart_rate_lower_bound = ce.result_val
    OF mf_cs72_hr_upper_bnd_cd:
     pa_pressure_data->qual[d1.seq].s_heart_rate_upper_bound = ce.result_val
   ENDCASE
  WITH nocounter
 ;end select
 SET _memory_reply_string = cnvtrectojson(pa_pressure_data)
#exit_script
 FREE RECORD pa_pressure_data
END GO
