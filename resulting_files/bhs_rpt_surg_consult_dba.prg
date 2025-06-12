CREATE PROGRAM bhs_rpt_surg_consult:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, ms_start_date, ms_end_date
 DECLARE mf_cs200_consultsurgerybmc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTSURGERYBMC"))
 DECLARE mf_cs200_teachingcoverage_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TEACHINGCOVERAGE"))
 DECLARE mf_cs200_consultsurgery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTSURGERY"))
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100")
  )
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224")
  )
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6003_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3094"))
 DECLARE mf_cs16449_ssg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SURGICALSPECIALTYGROUPS"))
 DECLARE mf_cs16449_stt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SURGICALTEACHINGTEAMS"))
 DECLARE mf_cs16449_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERREASON"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cs333_ed_attending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "EDATTENDINGPHYSICIAN"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_email = vc WITH protect, constant(
  "SurgeryConsultOrderDistributionList@baystatehealth.org")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant("")
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (ms_outdev="OPS")
  SET mf_end_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_beg_dt_tm = cnvtlookbehind("1 M",cnvtdatetime(mf_end_dt_tm))
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DATE,"DD-MMM-YYYY"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),235959)
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_order_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_facility = vc
     2 s_attending_physician = vc
     2 s_admit_dt = vc
     2 s_order_prsnl = vc
     2 s_order_dt = vc
     2 s_cat_name = vc
     2 s_order_detail = vc
     2 s_order_service = vc
     2 s_consult_reason = vc
     2 s_order_teaching_coverage = vc
 )
 SELECT INTO "nl:"
  FROM orders o,
   person p,
   encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   order_action oa,
   prsnl pp,
   encntr_prsnl_reltn epr,
   prsnl pp2,
   dummyt d1,
   order_detail od
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND o.catalog_cd IN (mf_cs200_consultsurgerybmc_cd, mf_cs200_consultsurgery_cd,
   mf_cs200_teachingcoverage_cd)
    AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd)
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1
    AND oa.action_type_cd=mf_cs6003_ordered_cd)
   JOIN (pp
   WHERE pp.person_id=oa.action_personnel_id)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_cs333_ed_attending_cd
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pp2
   WHERE pp2.person_id=epr.prsnl_person_id)
   JOIN (d1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (mf_cs16449_ssg_cd, mf_cs16449_stt_cd, mf_cs16449_reason_cd))
  ORDER BY o.encntr_id, o.order_id, od.action_sequence DESC
  HEAD o.encntr_id
   null
  HEAD o.order_id
   m_rec->l_cnt += 1
   IF ((m_rec->l_cnt > size(m_rec->qual,5)))
    stat = alterlist(m_rec->qual,(m_rec->l_cnt+ 99))
   ENDIF
   m_rec->qual[m_rec->l_cnt].f_encntr_id = o.encntr_id, m_rec->qual[m_rec->l_cnt].f_order_id = o
   .order_id, m_rec->qual[m_rec->l_cnt].f_person_id = o.person_id,
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_mrn = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_fin = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_admit_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[
   m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->
   l_cnt].s_attending_physician = trim(pp2.name_full_formatted),
   m_rec->qual[m_rec->l_cnt].s_order_prsnl = trim(pp.name_full_formatted,3), m_rec->qual[m_rec->l_cnt
   ].s_order_dt = trim(format(oa.action_dt_tm,"MM/DD/YYYY HH:mm:ss;;q"),3), m_rec->qual[m_rec->l_cnt]
   .s_order_detail = trim(o.order_detail_display_line,3),
   m_rec->qual[m_rec->l_cnt].s_cat_name = trim(uar_get_code_display(o.catalog_cd),3)
  DETAIL
   IF (od.oe_field_id=mf_cs16449_ssg_cd)
    m_rec->qual[m_rec->l_cnt].s_order_service = trim(od.oe_field_display_value,3)
   ELSEIF (od.oe_field_id=mf_cs16449_stt_cd)
    m_rec->qual[m_rec->l_cnt].s_order_teaching_coverage = trim(od.oe_field_display_value,3)
   ELSEIF (od.oe_field_id=mf_cs16449_reason_cd)
    m_rec->qual[m_rec->l_cnt].s_consult_reason = trim(od.oe_field_display_value,3)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->qual,m_rec->l_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET ms_error = "No data qualified."
  GO TO exit_script
 ENDIF
 IF (ms_outdev="OPS")
  SET frec->file_name = build(logical("bhscust"),
   "/ftp/bhs_rpt_surg_consult/bhs_rpt_consult_teaching_",format(sysdate,"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Facility",','"Admit Date",','"ED Attending Physician",',
   '"Order placed by",','"Order Date",',
   '"Order Name",','"Order Display Line",','"Consult Level",','"Reason for Consultation",',
   '"Teaching Service"',
   char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF (((size(trim(m_rec->qual[ml_idx1].s_order_teaching_coverage,3)) > 0) OR (size(trim(m_rec->
      qual[ml_idx1].s_order_service,3)) > 0)) )
     SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_facility,3),'","',trim(m_rec->qual[
       ml_idx1].s_admit_dt,3),'","',
      trim(m_rec->qual[ml_idx1].s_attending_physician,3),'","',trim(m_rec->qual[ml_idx1].
       s_order_prsnl,3),'","',trim(m_rec->qual[ml_idx1].s_order_dt,3),
      '","',trim(m_rec->qual[ml_idx1].s_cat_name,3),'","',trim(m_rec->qual[ml_idx1].s_order_detail,3),
      '","',
      trim(m_rec->qual[ml_idx1].s_order_service,3),'","',trim(m_rec->qual[ml_idx1].s_consult_reason,3
       ),'","',trim(m_rec->qual[ml_idx1].s_order_teaching_coverage,3),
      '"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("Surgery Consult and Teaching orders: ",format(cnvtdatetime(sysdate),
    "YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,0)
 ELSE
  SELECT INTO  $OUTDEV
   facility = trim(substring(1,15,m_rec->qual[d1.seq].s_facility)), admit_dt = trim(substring(1,15,
     m_rec->qual[d1.seq].s_admit_dt)), ed_attending_physician = trim(substring(1,60,m_rec->qual[d1
     .seq].s_attending_physician)),
   order_placed_by = trim(substring(1,60,m_rec->qual[d1.seq].s_order_prsnl)), order_dt = trim(
    substring(1,20,m_rec->qual[d1.seq].s_order_dt)), order_name = trim(substring(1,60,m_rec->qual[d1
     .seq].s_cat_name)),
   order_display_line = trim(substring(1,200,m_rec->qual[d1.seq].s_order_detail)), consult_level =
   trim(substring(1,50,m_rec->qual[d1.seq].s_order_service)), reason_for_consultation = trim(
    substring(1,50,m_rec->qual[d1.seq].s_consult_reason)),
   teaching_service = trim(substring(1,50,m_rec->qual[d1.seq].s_order_teaching_coverage))
   FROM (dummyt d1  WITH seq = m_rec->l_cnt)
   PLAN (d1
    WHERE ((size(trim(m_rec->qual[d1.seq].s_order_service,3)) > 0) OR (((size(trim(m_rec->qual[d1.seq
      ].s_order_teaching_coverage,3)) > 0) OR (size(trim(m_rec->qual[d1.seq].s_consult_reason,3)) > 0
    )) )) )
   ORDER BY admit_dt
   WITH nocounter, maxcol = 20000, format,
    separator = " "
  ;end select
 ENDIF
#exit_script
 IF (ms_outdev != "OPS"
  AND textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
