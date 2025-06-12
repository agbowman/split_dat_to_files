CREATE PROGRAM bhs_rpt_vet_scrn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = value(0.0),
  "Unit:" = value(0.0),
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, f_facility_cd, f_unit_cd,
  s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_dob = vc
     2 s_reg_dt_tm = vc
     2 s_sex = vc
     2 s_loc_fac = vc
     2 s_loc_unit = vc
     2 s_loc_rm_bed = vc
   1 fac[*]
     2 f_fac_cd = f8
     2 s_fac_disp = vc
   1 unit[*]
     2 f_unit_cd = f8
     2 s_unit_disp = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs71_inpat = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_cs71_outpat = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_cs71_obs = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_cs71_daystay = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_cs72_veteran = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"AREYOUAVETERAN"
   ))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE ms_parse_fac = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 IF (( $F_FACILITY_CD=0.0))
  SET ms_parse_fac = " ed.loc_facility_cd > 0.0 "
 ELSE
  SELECT INTO "nl:"
   FROM location l
   WHERE (l.location_cd= $F_FACILITY_CD)
    AND l.active_ind=1
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].f_fac_cd = l.location_cd,
    m_rec->fac[pl_cnt].s_fac_disp = trim(uar_get_code_display(l.location_cd),3)
   WITH nocounter
  ;end select
  SET ms_parse_fac =
  " expand(ml_exp1, 1, size(m_rec->fac, 5), ed.loc_facility_cd, m_rec->fac[ml_exp1].f_fac_cd) "
 ENDIF
 IF (( $F_UNIT_CD=0.0))
  SET ms_parse_unit = " ed.loc_nurse_unit_cd > 0.0 "
 ELSE
  SELECT INTO "nl:"
   FROM nurse_unit nu
   WHERE (nu.location_cd= $F_UNIT_CD)
    AND nu.active_ind=1
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->unit,pl_cnt), m_rec->unit[pl_cnt].f_unit_cd = nu.location_cd,
    m_rec->unit[pl_cnt].s_unit_disp = trim(uar_get_code_display(nu.location_cd),3)
   WITH nocounter
  ;end select
  SET ms_parse_unit =
  " expand(ml_exp2, 1, size(m_rec->unit, 5), ed.loc_nurse_unit_cd, m_rec->unit[ml_exp2].f_unit_cd) "
 ENDIF
 SELECT INTO "nl:"
  ps_fac = trim(uar_get_code_display(e.loc_facility_cd),3), ps_unit = trim(uar_get_code_display(e
    .loc_nurse_unit_cd),3), ps_room = trim(uar_get_code_display(e.loc_room_cd),3),
  ps_bed = trim(uar_get_code_display(e.loc_bed_cd),3)
  FROM encntr_domain ed,
   encounter e,
   person p,
   clinical_event ce,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ed
   WHERE ed.active_ind=1
    AND parser(ms_parse_fac)
    AND parser(ms_parse_unit)
    AND ed.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_cs71_inpat, mf_cs71_outpat, mf_cs71_obs, mf_cs71_daystay)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ((e.disch_dt_tm > sysdate) OR (e.disch_dt_tm=null)) )
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.event_cd=mf_cs72_veteran
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd)
    AND trim(cnvtlower(ce.result_val),3)="yes")
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY ps_fac, ps_unit, ps_room,
   ps_bed, e.encntr_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 50))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->enc[pl_cnt].s_mrn = trim(ea2.alias,3), m_rec->enc[pl_cnt].s_fin = trim(ea1.alias,3), m_rec
   ->enc[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3),
   m_rec->enc[pl_cnt].s_reg_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->enc[
   pl_cnt].s_sex = trim(uar_get_code_display(p.sex_cd),3), m_rec->enc[pl_cnt].s_loc_fac = trim(
    uar_get_code_display(e.loc_facility_cd),3),
   m_rec->enc[pl_cnt].s_loc_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->enc[
   pl_cnt].s_loc_rm_bed = concat(trim(uar_get_code_display(e.loc_room_cd),3)," ",trim(
     uar_get_code_display(e.loc_bed_cd),3))
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_rec->enc,5) > 0)
  SELECT INTO value( $OUTDEV)
   facility = substring(1,30,m_rec->enc[d.seq].s_loc_fac), unit = substring(1,30,m_rec->enc[d.seq].
    s_loc_unit), room_bed = substring(1,20,m_rec->enc[d.seq].s_loc_rm_bed),
   patient_name = substring(1,100,m_rec->enc[d.seq].s_pat_name), sex = substring(1,10,m_rec->enc[d
    .seq].s_sex), date_of_birth = m_rec->enc[d.seq].s_dob,
   admit_dt_tm = m_rec->enc[d.seq].s_reg_dt_tm, mrn = substring(1,40,m_rec->enc[d.seq].s_mrn), fin =
   substring(1,40,m_rec->enc[d.seq].s_fin)
   FROM (dummyt d  WITH seq = value(size(m_rec->enc,5)))
   WITH format, separator = " ", maxrow = 1
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "No Records Found"
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
