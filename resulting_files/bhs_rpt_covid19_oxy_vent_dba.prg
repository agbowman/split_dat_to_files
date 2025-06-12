CREATE PROGRAM bhs_rpt_covid19_oxy_vent:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 f_sex_cd = f8
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_dob = vc
     2 s_age = vc
     2 s_los = vc
     2 s_encntr_type = vc
     2 s_encntr_class = vc
     2 s_med_service = vc
     2 f_facility_cd = f8
     2 s_facility = vc
     2 f_nurse_unit_cd = f8
     2 s_nurse_unit = vc
     2 s_reg_dt_tm = vc
     2 d_reg_dt_tm = dq8
     2 s_disch_dt_tm = vc
     2 s_disch_disp = vc
     2 s_deceased_disp = vc
     2 s_event_disp = vc
     2 s_event_result = vc
     2 s_event_dt_tm = vc
     2 d_o2_mode_vent_last_dt_tm = dq8
     2 d_o2_mode_vent_first_dt_tm = dq8
     2 s_days_on_vent = vc
     2 n_o2_mode_type = i2
     2 s_fio2 = vc
     2 s_fio2_dt_tm = vc
     2 s_oxy_sat = vc
     2 s_oxy_sat_dt_tm = vc
     2 f_peep = f8
     2 s_peep = vc
     2 s_peep_dt_tm = vc
     2 f_plat_pres = f8
     2 s_plat_pres = vc
     2 s_plat_pres_dt_tm = vc
     2 s_tid_vol_set = vc
     2 s_tid_vol_set_dt_tm = vc
     2 s_vent_set_rt = vc
     2 s_vent_set_rt_dt_tm = vc
     2 s_vent_vis = vc
     2 s_vent_vis_dt_tm = vc
     2 s_vent_mode = vc
     2 s_vent_mode_dt_tm = vc
     2 s_resp_rt = vc
     2 s_resp_rt_dt_tm = vc
     2 f_tid_vol_deliv = f8
     2 s_tid_vol_deliv = vc
     2 s_tid_vol_deliv_dt_tm = vc
     2 f_height_cm = f8
     2 f_ibw_kg = f8
     2 s_adj_vt = vc
     2 s_compliance = vc
     2 modes[*]
       3 s_mode = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE ms_cs6000_pat_care_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCARE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_alter_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs71_er_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_cs71_inpat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_cs72_mode_deliv_oxy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 CALL echo(build2("mf_AUTH_CD: ",mf_auth_cd))
 CALL echo(build2("mf_MOD_CD: ",mf_mod_cd))
 CALL echo(build2("mf_ALTER_CD: ",mf_alter_cd))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_pendingcomplete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE mf_onholdmedstudent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "ONHOLDMEDSTUDENT"))
 DECLARE mf_pendingreview_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGREVIEW"))
 DECLARE mf_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"HOLD"))
 DECLARE mf_future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE mf_cs72_fio2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"FiO2"))
 DECLARE mf_cs72_oxy_sat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATION"))
 DECLARE mf_cs72_peep_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PEEP"))
 DECLARE mf_cs72_plat_pres_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PLATEAUPRESSURE"))
 DECLARE mf_cs72_tid_vol_set_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIDALVOLUMESET"))
 DECLARE mf_cs72_vent_set_rt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VENTILATORSETRATE"))
 DECLARE mf_cs72_vent_vis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VENTILATORVISITS"))
 DECLARE mf_cs72_vent_mode_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VENTILATORMODE"))
 DECLARE mf_cs72_resp_rt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE"))
 DECLARE mf_cs72_tid_vol_deliv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIDALVOLUMEDELIVERED"))
 DECLARE mf_cs72_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 CALL echo(build2("mf_CS72_VENT_MODE_CD: ",mf_cs72_vent_mode_cd))
 CALL echo(build2("mf_CS72_RESP_RT_CD: ",mf_cs72_resp_rt_cd))
 CALL echo(build2("mf_CS72_TID_VOL_DELIV_CD: ",mf_cs72_tid_vol_deliv_cd))
 CALL echo(build2("mf_CS72_HEIGHT_CD: ",mf_cs72_height_cd))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_covid19_oxy_vent/"))
 DECLARE ms_file_name = vc WITH protect, noconstant(concat(ms_loc_dir,"bhs_cov19_oxy_",trim(format(
     sysdate,"mmddyyyy-hhmm;;d"),3),".csv"))
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_res = vc WITH protect, noconstant(" ")
 DECLARE mf_tmp = f8 WITH protect, noconstant(0.0)
 DECLARE ms_dt_tm = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection)=0)
  SET ms_output = "mine"
 ENDIF
 SELECT INTO "nl:"
  pl_result_sort =
  IF (trim(cnvtlower(ce.result_val),3)="ventilator") 1
  ELSE 2
  ENDIF
  FROM encntr_domain ed,
   encounter e,
   clinical_event ce,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.beg_effective_dt_tm > cnvtdatetime("01-jan-2020"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null
    AND e.encntr_type_cd IN (mf_cs71_er_cd, mf_cs71_inpat_cd))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.event_cd=mf_cs72_mode_deliv_oxy_cd
    AND ce.event_end_dt_tm > e.reg_dt_tm
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_mod_cd, mf_alter_cd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.deceased_cd != 681743.00)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=ms_cmrn_cd)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY pa.alias, e.reg_dt_tm DESC, ce.event_end_dt_tm DESC,
   pl_result_sort
  HEAD REPORT
   pn_add = 0, pl_cnt = 0, pl_mode_cnt = 0
  HEAD pa.alias
   pn_add = 0, pl_mode_cnt = 0
   IF (trim(cnvtlower(ce.result_val),3)="ventilator")
    pl_cnt += 1, pn_add = 1
    IF (pl_cnt > size(m_rec->enc,5))
     CALL alterlist(m_rec->enc,(pl_cnt+ 20))
    ENDIF
    m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
    ->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
    m_rec->enc[pl_cnt].f_sex_cd = p.sex_cd, m_rec->enc[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->enc[
    pl_cnt].s_fin = trim(ea.alias,3),
    m_rec->enc[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->enc[pl_cnt].
    s_age = cnvtage(p.birth_dt_tm), m_rec->enc[pl_cnt].s_los = cnvtage(e.reg_dt_tm),
    m_rec->enc[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->enc[
    pl_cnt].s_encntr_class = trim(uar_get_code_display(e.encntr_class_cd),3), m_rec->enc[pl_cnt].
    s_med_service = trim(uar_get_code_display(e.med_service_cd),3),
    m_rec->enc[pl_cnt].f_facility_cd = e.loc_facility_cd, m_rec->enc[pl_cnt].s_facility = trim(
     uar_get_code_display(e.loc_facility_cd),3), m_rec->enc[pl_cnt].f_nurse_unit_cd = e
    .loc_nurse_unit_cd,
    m_rec->enc[pl_cnt].s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->enc[
    pl_cnt].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->enc[pl_cnt].
    d_reg_dt_tm = e.reg_dt_tm
    IF (e.disch_dt_tm != null)
     m_rec->enc[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
    ENDIF
    m_rec->enc[pl_cnt].s_disch_disp = trim(uar_get_code_display(e.disch_disposition_cd),3), m_rec->
    enc[pl_cnt].s_deceased_disp = trim(uar_get_code_display(p.deceased_cd),3), m_rec->enc[pl_cnt].
    s_event_disp = trim(uar_get_code_display(ce.event_cd),3),
    m_rec->enc[pl_cnt].s_event_result = trim(ce.result_val,3), m_rec->enc[pl_cnt].s_event_dt_tm =
    trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->enc[pl_cnt].
    d_o2_mode_vent_last_dt_tm = ce.event_end_dt_tm
   ENDIF
  DETAIL
   IF (pn_add=1)
    IF (trim(cnvtlower(ce.result_val),3)="ventilator")
     m_rec->enc[pl_cnt].d_o2_mode_vent_first_dt_tm = ce.event_end_dt_tm
    ENDIF
    IF (pl_mode_cnt=0)
     pl_mode_cnt += 1,
     CALL alterlist(m_rec->enc[pl_cnt].modes,pl_mode_cnt), m_rec->enc[pl_cnt].modes[pl_mode_cnt].
     s_mode = trim(ce.result_val,3),
     m_rec->enc[pl_cnt].n_o2_mode_type += 1
    ELSEIF (expand(ml_exp,1,size(m_rec->enc[pl_cnt].modes,5),trim(ce.result_val,3),m_rec->enc[pl_cnt]
     .modes[ml_exp].s_mode)=0)
     pl_mode_cnt += 1,
     CALL alterlist(m_rec->enc[pl_cnt].modes,pl_mode_cnt), m_rec->enc[pl_cnt].modes[pl_mode_cnt].
     s_mode = trim(ce.result_val,3),
     m_rec->enc[pl_cnt].n_o2_mode_type += 1
    ENDIF
   ENDIF
  FOOT  pa.alias
   IF (pn_add=1)
    IF ((m_rec->enc[pl_cnt].d_o2_mode_vent_first_dt_tm=m_rec->enc[pl_cnt].d_o2_mode_vent_last_dt_tm))
     m_rec->enc[pl_cnt].s_days_on_vent = "0"
    ELSE
     m_rec->enc[pl_cnt].s_days_on_vent = trim(cnvtstring(datetimediff(cnvtdatetime(m_rec->enc[pl_cnt]
         .d_o2_mode_vent_last_dt_tm),cnvtdatetime(m_rec->enc[pl_cnt].d_o2_mode_vent_first_dt_tm)),5,2
       ),3)
    ENDIF
    IF ((m_rec->enc[pl_cnt].n_o2_mode_type > 1))
     m_rec->enc[pl_cnt].s_days_on_vent = concat(m_rec->enc[pl_cnt].s_days_on_vent,"*")
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE expand(ml_exp,1,size(m_rec->enc,5),e.encntr_id,m_rec->enc[ml_exp].f_encntr_id))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_end_dt_tm >= e.reg_dt_tm
    AND ce.event_cd IN (mf_cs72_fio2_cd, mf_cs72_oxy_sat_cd, mf_cs72_peep_cd, mf_cs72_plat_pres_cd,
   mf_cs72_tid_vol_set_cd,
   mf_cs72_vent_set_rt_cd, mf_cs72_vent_vis_cd, mf_cs72_vent_mode_cd, mf_cs72_resp_rt_cd,
   mf_cs72_tid_vol_deliv_cd,
   mf_cs72_height_cd)
    AND ce.result_status_cd IN (mf_auth_cd, mf_mod_cd, mf_alter_cd)
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx = locateval(ml_loc,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_loc].f_encntr_id)
  HEAD ce.event_cd
   ms_res = concat(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd),3)),
   ms_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   CASE (ce.event_cd)
    OF mf_cs72_fio2_cd:
     m_rec->enc[ml_idx].s_fio2 = ms_res,m_rec->enc[ml_idx].s_fio2_dt_tm = ms_dt_tm
    OF mf_cs72_oxy_sat_cd:
     m_rec->enc[ml_idx].s_oxy_sat = ms_res,m_rec->enc[ml_idx].s_oxy_sat_dt_tm = ms_dt_tm
    OF mf_cs72_peep_cd:
     m_rec->enc[ml_idx].f_peep = cnvtreal(ce.result_val),m_rec->enc[ml_idx].s_peep = ms_res,m_rec->
     enc[ml_idx].s_peep_dt_tm = ms_dt_tm
    OF mf_cs72_plat_pres_cd:
     m_rec->enc[ml_idx].f_plat_pres = cnvtreal(ce.result_val),m_rec->enc[ml_idx].s_plat_pres = ms_res,
     m_rec->enc[ml_idx].s_plat_pres_dt_tm = ms_dt_tm
    OF mf_cs72_tid_vol_set_cd:
     m_rec->enc[ml_idx].s_tid_vol_set = ms_res,m_rec->enc[ml_idx].s_tid_vol_set_dt_tm = ms_dt_tm
    OF mf_cs72_vent_set_rt_cd:
     m_rec->enc[ml_idx].s_vent_set_rt = ms_res,m_rec->enc[ml_idx].s_vent_set_rt_dt_tm = ms_dt_tm
    OF mf_cs72_vent_vis_cd:
     m_rec->enc[ml_idx].s_vent_vis = ms_res,m_rec->enc[ml_idx].s_vent_vis_dt_tm = ms_dt_tm
    OF mf_cs72_vent_mode_cd:
     m_rec->enc[ml_idx].s_vent_mode = ms_res,m_rec->enc[ml_idx].s_vent_mode_dt_tm = ms_dt_tm
    OF mf_cs72_resp_rt_cd:
     m_rec->enc[ml_idx].s_resp_rt = ms_res,m_rec->enc[ml_idx].s_resp_rt_dt_tm = ms_dt_tm
    OF mf_cs72_tid_vol_deliv_cd:
     m_rec->enc[ml_idx].f_tid_vol_deliv = cnvtreal(ce.result_val),m_rec->enc[ml_idx].s_tid_vol_deliv
      = ms_res,m_rec->enc[ml_idx].s_tid_vol_deliv_dt_tm = ms_dt_tm
    OF mf_cs72_height_cd:
     IF (cnvtlower(trim(uar_get_code_display(ce.result_units_cd),3))="cm")
      m_rec->enc[ml_idx].f_height_cm = cnvtreal(ce.result_val)
     ELSEIF (cnvtlower(trim(uar_get_code_display(ce.result_units_cd),3))="in")
      m_rec->enc[ml_idx].f_height_cm = (cnvtreal(ce.result_val) * 2.54)
     ENDIF
     ,
     IF ((m_rec->enc[ml_idx].f_height_cm > 0.0))
      IF ((m_rec->enc[ml_idx].f_sex_cd=mf_male_cd))
       m_rec->enc[ml_idx].f_ibw_kg = (50+ (0.91 * (m_rec->enc[ml_idx].f_height_cm - 152.4)))
      ELSEIF ((m_rec->enc[ml_idx].f_sex_cd=mf_female_cd))
       m_rec->enc[ml_idx].f_ibw_kg = (45.5+ (0.91 * (m_rec->enc[ml_idx].f_height_cm - 152.4)))
      ENDIF
     ENDIF
   ENDCASE
  FOOT  ce.encntr_id
   IF ((m_rec->enc[ml_idx].f_tid_vol_deliv > 0.0)
    AND (m_rec->enc[ml_idx].f_plat_pres > 0.0)
    AND (m_rec->enc[ml_idx].f_peep > 0.0))
    mf_tmp = (m_rec->enc[ml_idx].f_tid_vol_deliv/ (m_rec->enc[ml_idx].f_plat_pres - m_rec->enc[ml_idx
    ].f_peep)), m_rec->enc[ml_idx].s_compliance = trim(cnvtstring(mf_tmp,5,2),3)
   ENDIF
   IF ((m_rec->enc[ml_idx].f_tid_vol_deliv > 0.0)
    AND (m_rec->enc[ml_idx].f_ibw_kg > 0.0))
    m_rec->enc[ml_idx].s_adj_vt = trim(cnvtstring((m_rec->enc[ml_idx].f_tid_vol_deliv/ m_rec->enc[
      ml_idx].f_ibw_kg),5,2),3)
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_output="mine")
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,75,m_rec->enc[d1.seq].s_pat_name), cmrn = substring(1,40,m_rec->enc[d1
    .seq].s_cmrn), fin = substring(1,40,m_rec->enc[d1.seq].s_fin),
   age = substring(1,30,m_rec->enc[d1.seq].s_age), los = substring(1,30,m_rec->enc[d1.seq].s_los),
   encntr_type = substring(1,25,m_rec->enc[d1.seq].s_encntr_type),
   encntr_class = substring(1,25,m_rec->enc[d1.seq].s_encntr_class), med_service = substring(1,25,
    m_rec->enc[d1.seq].s_med_service), facility = substring(1,25,m_rec->enc[d1.seq].s_facility),
   nurse_unit = substring(1,25,m_rec->enc[d1.seq].s_nurse_unit), reg_dt_tm = m_rec->enc[d1.seq].
   s_reg_dt_tm, disch_dt_tm = m_rec->enc[d1.seq].s_disch_dt_tm,
   disch_disp = substring(1,30,m_rec->enc[d1.seq].s_disch_disp), deceased = substring(1,10,m_rec->
    enc[d1.seq].s_deceased_disp), event_display = substring(1,40,m_rec->enc[d1.seq].s_event_disp),
   event_result = substring(1,40,m_rec->enc[d1.seq].s_event_result), event_dt_tm = m_rec->enc[d1.seq]
   .s_event_dt_tm, fio2 = substring(1,40,m_rec->enc[d1.seq].s_fio2),
   fio2_dt_tm = m_rec->enc[d1.seq].s_fio2_dt_tm, oxy_sat = substring(1,40,m_rec->enc[d1.seq].
    s_oxy_sat), oxy_sat_dt_tm = m_rec->enc[d1.seq].s_oxy_sat_dt_tm,
   peep = substring(1,40,m_rec->enc[d1.seq].s_peep), peep_dt_tm = m_rec->enc[d1.seq].s_peep_dt_tm,
   plateau_pressure = substring(1,40,m_rec->enc[d1.seq].s_plat_pres),
   plateau_pressure_dt_tm = m_rec->enc[d1.seq].s_plat_pres_dt_tm, tidal_volume_set = substring(1,40,
    m_rec->enc[d1.seq].s_tid_vol_set), tidal_volume_set_dt_tm = m_rec->enc[d1.seq].
   s_tid_vol_set_dt_tm,
   vent_set_rate = substring(1,40,m_rec->enc[d1.seq].s_vent_set_rt), vent_set_rate_dt_tm = m_rec->
   enc[d1.seq].s_vent_set_rt_dt_tm, vent_visits = substring(1,40,m_rec->enc[d1.seq].s_vent_vis),
   vent_visits_dt_tm = m_rec->enc[d1.seq].s_vent_vis_dt_tm, ventilator_mode = substring(1,10,m_rec->
    enc[d1.seq].s_vent_mode), ventilator_mode_dt_tm = m_rec->enc[d1.seq].s_vent_mode_dt_tm,
   respirator_rate = substring(1,10,m_rec->enc[d1.seq].s_resp_rt), respirator_rate_dt_tm = m_rec->
   enc[d1.seq].s_resp_rt_dt_tm, tidal_vol_delivered = substring(1,10,m_rec->enc[d1.seq].
    s_tid_vol_deliv),
   tidal_vol_delivered_dt_tm = m_rec->enc[d1.seq].s_tid_vol_deliv_dt_tm, adjusted_vt = substring(1,10,
    m_rec->enc[d1.seq].s_adj_vt), days_on_vent = substring(1,10,m_rec->enc[d1.seq].s_days_on_vent)
   FROM (dummyt d1  WITH seq = value(size(m_rec->enc,5)))
   PLAN (d1)
   ORDER BY d1.seq
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
  IF (size(m_rec->enc,5) > 0)
   SET frec->file_name = ms_file_name
   CALL echo(build2("ms_file_name: ",frec->file_name))
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat(
    "PATIENT_NAME|CMRN|FIN|AGE|LOS|ENCNTR_TYPE|ENCNTR_CLASS|MED_SERVICE|FACILITY|",
    "NURSE_UNIT|REG_DT_TM|DISCH_DT_TM|DISCH_DISPOSITION|DECEASED|EVENT_DISPLAY|",
    "EVENT_RESULT|EVENT_DT_TM|FIO2|FIO2_DT_TM|OXY_SAT|OXY_SAT_DT_TM|PEEP|PEEP_DT_TM|",
    "PLATEAU_PRESSURE|PLATEAU_PRESSURE_DT_TM|TIDAL_VOLUME_SET|TIDAL_VOLUME_SET_DT_TM|",
    "VENT_SET_RATE|VENT_SET_RATE_DT_TM|VENT_VISITS|VENT_VISITS_DT_TM|",
    "VENTILATOR_MODE|VENTILATOR_MODE_DT_TM_M|RESPIRATORY_RATE|RESPIRATORY_RATE_DT_TM|",
    "TIDAL_VOLUME_DELIVERED|TIDAL_VOLUME_DELIVERED_DT_TM|ADJUSTED_VT|DAYS_ON_VENT",char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->enc,5))
     SET ms_line = concat(m_rec->enc[ml_loop].s_pat_name,"|",m_rec->enc[ml_loop].s_cmrn,"|",m_rec->
      enc[ml_loop].s_fin,
      "|",m_rec->enc[ml_loop].s_age,"|",m_rec->enc[ml_loop].s_los,"|",
      m_rec->enc[ml_loop].s_encntr_type,"|",m_rec->enc[ml_loop].s_encntr_class,"|",m_rec->enc[ml_loop
      ].s_med_service,
      "|",m_rec->enc[ml_loop].s_facility,"|",m_rec->enc[ml_loop].s_nurse_unit,"|",
      m_rec->enc[ml_loop].s_reg_dt_tm,"|",m_rec->enc[ml_loop].s_disch_dt_tm,"|",m_rec->enc[ml_loop].
      s_disch_disp,
      "|",m_rec->enc[ml_loop].s_deceased_disp,"|",m_rec->enc[ml_loop].s_event_disp,"|",
      m_rec->enc[ml_loop].s_event_result,"|",m_rec->enc[ml_loop].s_event_dt_tm,"|",m_rec->enc[ml_loop
      ].s_fio2,
      "|",m_rec->enc[ml_loop].s_fio2_dt_tm,"|",m_rec->enc[ml_loop].s_oxy_sat,"|",
      m_rec->enc[ml_loop].s_oxy_sat_dt_tm,"|",m_rec->enc[ml_loop].s_peep,"|",m_rec->enc[ml_loop].
      s_peep_dt_tm,
      "|",m_rec->enc[ml_loop].s_plat_pres,"|",m_rec->enc[ml_loop].s_plat_pres_dt_tm,"|",
      m_rec->enc[ml_loop].s_tid_vol_set,"|",m_rec->enc[ml_loop].s_tid_vol_set_dt_tm,"|",m_rec->enc[
      ml_loop].s_vent_set_rt,
      "|",m_rec->enc[ml_loop].s_vent_set_rt_dt_tm,"|",m_rec->enc[ml_loop].s_vent_vis,"|",
      m_rec->enc[ml_loop].s_vent_vis_dt_tm,"|",m_rec->enc[ml_loop].s_vent_mode,"|",m_rec->enc[ml_loop
      ].s_vent_mode_dt_tm,
      "|",m_rec->enc[ml_loop].s_resp_rt,"|",m_rec->enc[ml_loop].s_resp_rt_dt_tm,"|",
      m_rec->enc[ml_loop].s_tid_vol_deliv,"|",m_rec->enc[ml_loop].s_tid_vol_deliv_dt_tm,"|",m_rec->
      enc[ml_loop].s_adj_vt,
      "|",m_rec->enc[ml_loop].s_days_on_vent,char(10))
     SET frec->file_buf = ms_line
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
