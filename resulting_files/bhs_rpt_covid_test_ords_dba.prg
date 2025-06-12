CREATE PROGRAM bhs_rpt_covid_test_ords:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0
  WITH outdev, f_facility, f_unit
 FREE RECORD m_rec
 RECORD m_rec(
   1 fac[*]
     2 f_fac = f8
     2 s_disp = vc
   1 nu[*]
     2 f_nu = f8
     2 s_disp = vc
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_room_bed = vc
     2 s_fin = vc
     2 s_order = vc
     2 s_order_dt_tm = vc
 ) WITH protect
 DECLARE mf_cs69_inpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_obs = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"))
 DECLARE mf_cs200_c19 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COVID192019NOVELCORONAVIRUSPCR"))
 DECLARE mf_cs200_c19_rapid = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COVID19RSVANDFLUABRAPIDPCR"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs6000_lab = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 CALL echo(build2("mf_CS69_INPAT: ",mf_cs69_inpat))
 CALL echo(build2("mf_CS69_OBS: ",mf_cs69_obs))
 CALL echo(build2("mf_CS200_C19: ",mf_cs200_c19))
 CALL echo(build2("mf_CS200_C19_RAPID: ",mf_cs200_c19_rapid))
 CALL echo(build2("mf_CS6000_LAB: ",mf_cs6000_lab))
 CALL echo(build2("mf_CS6004_ORDERED: ",mf_cs6004_ordered))
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 IF (( $F_FACILITY=0.0))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.cdf_meaning="FACILITY"
   ORDER BY cv.display
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].f_fac = cv.code_value,
    m_rec->fac[pl_cnt].disp = trim(cv.display,3)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $F_FACILITY)
   ORDER BY cv.display
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].f_fac = cv.code_value,
    m_rec->fac[pl_cnt].s_disp = trim(cv.display,3)
   WITH nocounter
  ;end select
 ENDIF
 IF (( $F_UNIT=0.0))
  SELECT INTO "nl:"
   ps_disp = uar_get_code_display(nu.location_cd)
   FROM nurse_unit nu,
    code_value cv
   PLAN (nu
    WHERE expand(ml_exp1,1,size(m_rec->fac,5),nu.loc_facility_cd,m_rec->fac[ml_exp1].f_fac)
     AND nu.active_ind=1
     AND nu.end_effective_dt_tm > sysdate)
    JOIN (cv
    WHERE cv.code_value=nu.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND cv.data_status_cd=25
     AND  NOT (cv.display_key IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE di.info_domain="BHS_INACTIVE_NURSE_UNIT")))
     AND ((((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND ((cv.display_key IN (
    (SELECT
     di2.info_name
     FROM dm_info di2
     WHERE di2.info_domain="BHS_AMBULATORY_UNIT"))) OR (nu.loc_facility_cd=2159646)) )) ) OR (((cv
    .cdf_meaning="AMBULATORY"
     AND cv.display_key="BFMCONCOLOGY"
     AND nu.loc_facility_cd=673937) OR (cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="S15MED"
     AND nu.loc_facility_cd=673936)) )) )
   ORDER BY ps_disp
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->nu,5))
     CALL alterlist(m_rec->nu,(pl_cnt+ 50))
    ENDIF
    m_rec->nu[pl_cnt].f_nu = nu.location_cd, m_rec->nu[pl_cnt].s_disp = trim(uar_get_code_display(nu
      .location_cd),3)
   FOOT REPORT
    CALL alterlist(m_rec->nu,pl_cnt)
   WITH nocounter, expand = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $F_UNIT)
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->nu,5))
     CALL alterlist(m_rec->nu,(pl_cnt+ 50))
    ENDIF
    m_rec->nu[pl_cnt].f_nu = cv.code_value, m_rec->nu[pl_cnt].s_disp = trim(cv.display,3)
   FOOT REPORT
    CALL alterlist(m_rec->nu,pl_cnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SELECT INTO "nl:"
  facility = trim(uar_get_code_display(e.loc_facility_cd),3), unit = trim(uar_get_code_display(e
    .loc_nurse_unit_cd),3), room_bed = concat(trim(uar_get_code_display(e.loc_room_cd),3),"/",trim(
    uar_get_code_display(e.loc_bed_cd),3))
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   person p,
   orders o
  PLAN (ed
   WHERE expand(ml_exp1,1,size(m_rec->fac,5),ed.loc_facility_cd,m_rec->fac[ml_exp1].f_fac)
    AND expand(ml_exp2,1,size(m_rec->nu,5),ed.loc_nurse_unit_cd,m_rec->nu[ml_exp2].f_nu)
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_class_cd IN (mf_cs69_inpat, mf_cs69_obs)
    AND e.disch_dt_tm=null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_cs6000_lab
    AND o.catalog_cd IN (mf_cs200_c19, mf_cs200_c19_rapid)
    AND o.order_status_cd=mf_cs6004_ordered)
  ORDER BY facility, unit, room_bed,
   e.encntr_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 100))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->enc[pl_cnt].s_room_bed = room_bed, m_rec->enc[pl_cnt].s_fin = trim(ea.alias,3), m_rec->enc[
   pl_cnt].s_order = trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->enc[pl_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value( $OUTDEV)
  patient_name = substring(1,100,m_rec->enc[d.seq].s_pat_name), room_bed = substring(1,20,m_rec->enc[
   d.seq].s_room_bed), fin = m_rec->enc[d.seq].s_fin,
  test_ordered = substring(1,100,m_rec->enc[d.seq].s_order), order_dt_tm = m_rec->enc[d.seq].
  s_order_dt_tm
  FROM (dummyt d  WITH seq = value(size(m_rec->enc,5)))
  PLAN (d)
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec->enc)
 FREE RECORD m_rec
END GO
