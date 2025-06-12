CREATE PROGRAM bhs_rpt_covid19_rel_ord:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 lab[*]
     2 f_cat_cd = f8
     2 s_cat_disp = vc
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_cmrn = vc
     2 s_fin = vc
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
     2 s_disch_dt_tm = vc
     2 s_disch_disp = vc
     2 s_deceased_disp = vc
     2 ord[*]
       3 s_catalog_cd = vc
       3 s_order_status = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_lab_ty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE ms_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
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
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(trim(format(cnvtlookbehind("1,D",sysdate),
    "dd-mmm-yyyy 00:00:00;;d"),3))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim(format(sysdate,"dd-mmm-yyyy 23:59:59;;d"),3)
  )
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (textlen(trim( $S_BEG_DT,3)) > 0
  AND textlen(trim( $S_END_DT,3)) > 0)
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   CALL echo("invalid dates")
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ENDIF
 CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
 CALL echo(build2("ms_end_dt_tm: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key IN ("RSVANDINFLUENZAABPANELPCR", "RSVFLUPCRWITHREFLEXPATHOGENPANEL",
   "RESPIRATORYPATHOGENPANELBYPCR", "RESPIRATORYPATHOGENPCRWRFLXCOVID19",
   "RESPIRATORYPATHOGENPROFILEPCR",
   "COVID192019NOVELCORONAVIRUS", "COVID192019NOVELCORONAVIRUSPCR", "2019NOVELCORONAVIRUSCOVID19NAA",
   "2019NOVELCORONAVIRUSCOVID19RTPCR"))
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt += 1,
   CALL alterlist(m_rec->lab,pl_cnt), m_rec->lab[pl_cnt].f_cat_cd = cv.code_value,
   m_rec->lab[pl_cnt].s_cat_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   orders o,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND o.catalog_type_cd=mf_lab_ty_cd
    AND expand(ml_exp,1,size(m_rec->lab,5),o.catalog_cd,m_rec->lab[ml_exp].f_cat_cd)
    AND o.order_status_cd IN (mf_inprocess_cd, mf_ordered_cd, mf_pendingcomplete_cd,
   mf_onholdmedstudent_cd, mf_pendingreview_cd,
   mf_hold_cd, mf_future_cd))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
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
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = 0, pl_ord_cnt = 0
  HEAD e.encntr_id
   pl_ord_cnt = 0, pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 20))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3),
   m_rec->enc[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->enc[pl_cnt].s_fin = trim(ea.alias,3), m_rec->
   enc[pl_cnt].s_age = cnvtage(p.birth_dt_tm),
   m_rec->enc[pl_cnt].s_los = cnvtage(e.reg_dt_tm), m_rec->enc[pl_cnt].s_encntr_type = trim(
    uar_get_code_display(e.encntr_type_cd),3), m_rec->enc[pl_cnt].s_encntr_class = trim(
    uar_get_code_display(e.encntr_class_cd),3),
   m_rec->enc[pl_cnt].s_med_service = trim(uar_get_code_display(e.med_service_cd),3), m_rec->enc[
   pl_cnt].f_facility_cd = e.loc_facility_cd, m_rec->enc[pl_cnt].s_facility = trim(
    uar_get_code_display(e.loc_facility_cd),3),
   m_rec->enc[pl_cnt].f_nurse_unit_cd = e.loc_nurse_unit_cd, m_rec->enc[pl_cnt].s_nurse_unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->enc[pl_cnt].s_reg_dt_tm = trim(format(e
     .reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   IF (e.disch_dt_tm != null)
    m_rec->enc[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   ENDIF
   m_rec->enc[pl_cnt].s_disch_disp = trim(uar_get_code_display(e.disch_disposition_cd),3), m_rec->
   enc[pl_cnt].s_deceased_disp = trim(uar_get_code_display(p.deceased_cd),3)
  HEAD o.order_id
   pl_ord_cnt += 1,
   CALL alterlist(m_rec->enc[pl_cnt].ord,pl_ord_cnt), m_rec->enc[pl_cnt].ord[pl_ord_cnt].s_catalog_cd
    = trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->enc[pl_cnt].ord[pl_ord_cnt].s_order_status = trim(uar_get_code_display(o.order_status_cd),3
    )
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  patient_name = substring(1,75,m_rec->enc[d1.seq].s_pat_name), cmrn = substring(1,40,m_rec->enc[d1
   .seq].s_cmrn), fin = substring(1,40,m_rec->enc[d1.seq].s_fin),
  age = substring(1,30,m_rec->enc[d1.seq].s_age), los = substring(1,30,m_rec->enc[d1.seq].s_los),
  encntr_type = substring(1,25,m_rec->enc[d1.seq].s_encntr_type),
  encntr_class = substring(1,25,m_rec->enc[d1.seq].s_encntr_class), med_service = substring(1,25,
   m_rec->enc[d1.seq].s_med_service), facility = substring(1,25,m_rec->enc[d1.seq].s_facility),
  nurse_unit = substring(1,25,m_rec->enc[d1.seq].s_nurse_unit), reg_dt_tm = m_rec->enc[d1.seq].
  s_reg_dt_tm, disch_dt_tm = m_rec->enc[d1.seq].s_disch_dt_tm,
  disch_disp = substring(1,30,m_rec->enc[d1.seq].s_disch_disp), deceased = substring(1,10,m_rec->enc[
   d1.seq].s_deceased_disp), order_catalog_display = substring(1,40,m_rec->enc[d1.seq].ord[d2.seq].
   s_catalog_cd),
  order_status = substring(1,20,m_rec->enc[d1.seq].ord[d2.seq].s_order_status)
  FROM (dummyt d1  WITH seq = value(size(m_rec->enc,5))),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->enc[d1.seq].ord,5)))
   JOIN (d2)
  ORDER BY d1.seq, d2.seq
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
