CREATE PROGRAM bhs_rpt_cls_physstats:dba
 PROMPT
  "Output to File/Printer/MINE/Email Address" = "MINE",
  "Enter Start Date:" = "SYSDATE",
  "Enter End Date:" = "SYSDATE",
  "Orders to Qualify" = "ALL",
  "Encounter Types" = "ALL",
  "Report Type" = "SUMMARY"
  WITH outdev, s_start_date, s_end_date,
  s_order_types, s_encounter_types, s_report_type
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 phys[*]
     2 s_name = vc
     2 s_phys_type = vc
     2 s_facility_disp = vc
     2 s_facility_group = vc
     2 f_facility_cd = f8
     2 f_mdcount = f8
     2 f_prcount = f8
     2 f_pvcount = f8
     2 f_sidcount = f8
     2 f_wrcount = f8
     2 f_otcount = f8
     2 f_totcount = f8
     2 f_cpoecount = f8
     2 f_mdpct = f8
     2 f_prpct = f8
     2 f_pvpct = f8
     2 f_sidpct = f8
     2 f_wrpct = f8
     2 f_cpoerate = f8
   1 phys_summ[*]
     2 s_name = vc
     2 s_phys_type = vc
     2 s_facility_disp = vc
     2 s_mdcount = vc
     2 s_prcount = vc
     2 s_pvcount = vc
     2 s_sidcount = vc
     2 s_wrcount = vc
     2 s_otcount = vc
     2 s_totcount = vc
     2 s_cpoecount = vc
     2 s_mdpct = vc
     2 s_prpct = vc
     2 s_pvpct = vc
     2 s_sidpct = vc
     2 s_wrpct = vc
     2 s_cpoerate = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 DECLARE ms_encntr_types = vc WITH protect, constant(trim(cnvtupper( $S_ENCOUNTER_TYPES),3))
 DECLARE ms_order_types = vc WITH protect, constant(trim(cnvtupper( $S_ORDER_TYPES),3))
 DECLARE ms_report_type = vc WITH protect, constant(trim(cnvtupper( $S_REPORT_TYPE),3))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Observation"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Inpatient"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Daystay"))
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Emergency"))
 DECLARE mf_disch_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch IP"))
 DECLARE mf_disch_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch Obv"))
 DECLARE mf_disch_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch Daystay"
   ))
 DECLARE mf_disch_es_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch ES"))
 DECLARE mf_exp_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired IP"))
 DECLARE mf_exp_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired Obv"))
 DECLARE mf_exp_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired Daystay"
   ))
 DECLARE mf_exp_es_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired ES"))
 DECLARE mf_powerchart_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE mf_pharm_activity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"
   ))
 DECLARE mf_order_action_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_protocol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6006,"PROTOCOL"))
 DECLARE mf_phoneverbal_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6006,
   "PHONEVERBAL"))
 DECLARE mf_secimmundowntime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6006,
   "SECIMMUNDOWNTIME"))
 DECLARE mf_written_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6006,"WRITTEN"))
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE mf_start_dt = f8 WITH protect, noconstant(cnvtdatetime( $S_START_DATE))
 DECLARE mf_end_dt = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_mdcount = f8 WITH protect, noconstant(0)
 DECLARE mf_prcount = f8 WITH protect, noconstant(0)
 DECLARE mf_pvcount = f8 WITH protect, noconstant(0)
 DECLARE mf_sidcount = f8 WITH protect, noconstant(0)
 DECLARE mf_wrcount = f8 WITH protect, noconstant(0)
 DECLARE mf_otcount = f8 WITH protect, noconstant(0)
 DECLARE mf_totcount = f8 WITH protect, noconstant(0)
 DECLARE mf_mdpct = f8 WITH protect, noconstant(0)
 DECLARE mf_prpct = f8 WITH protect, noconstant(0)
 DECLARE mf_pvpct = f8 WITH protect, noconstant(0)
 DECLARE mf_sidpct = f8 WITH protect, noconstant(0)
 DECLARE mf_wrpct = f8 WITH protect, noconstant(0)
 DECLARE mf_cpoerate = f8 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_temp = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_start_dt_disp = vc WITH protect, noconstant("")
 DECLARE ms_end_dt_disp = vc WITH protect, noconstant("")
 DECLARE ms_facility_disp = vc WITH protect, noconstant("")
 DECLARE ms_encntr_type_disp = vc WITH protect, noconstant("")
 DECLARE ms_order_type_disp = vc WITH protect, noconstant("")
 DECLARE ms_order_type_p = vc WITH protect, noconstant("")
 DECLARE ms_encntr_type_p = vc WITH protect, noconstant("")
 DECLARE ms_filename_in = vc WITH protect, noconstant("")
 DECLARE ms_filename_out = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_CLS_PHYSSTATS"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    IF (ml_cnt=0)
     ms_recipients = trim(di.info_name,3), ml_cnt = 1
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((findstring("@", $OUTDEV) > 0) OR (mn_ops=1)) )
  SET mn_email_ind = 1
  SET ms_output = concat(trim(cnvtlower(curprog),3),"_",format(sysdate,"MMDDYYYYHHMMSS;;d"))
  SET ms_filename_out = trim(concat(ms_output,".csv"),3)
 ENDIF
 IF (( $S_START_DATE="BEGOFPREVMONTH"))
  SET mf_start_dt = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
 ENDIF
 IF (( $S_END_DATE="ENDOFPREVMONTH"))
  SET mf_end_dt = cnvtdatetime((curdate - day(curdate)),235959)
 ENDIF
 SET ms_start_dt_disp = trim(format(mf_start_dt,"MM/DD/YYYY;;d"),3)
 SET ms_end_dt_disp = trim(format(mf_end_dt,"MM/DD/YYYY;;d"),3)
 IF (ms_order_types="MED")
  SET ms_order_type_disp = "Pharmacy Orders Only"
  SET ms_order_type_p = build2("o.activity_type_cd = ",mf_pharm_activity_cd)
 ELSEIF (ms_order_types="ALL")
  SET ms_order_type_disp = "All Orders"
  SET ms_order_type_p = "1=1"
 ENDIF
 IF (ms_encntr_types="EXCLUDE")
  SET ms_encntr_type_disp = "Outpatients Excluded"
  SET ms_encntr_type_p = build2("e.encntr_type_cd in (",mf_observation_cd,",",mf_inpatient_cd,",",
   mf_daystay_cd,",",mf_emergency_cd,",",mf_disch_inpatient_cd,
   ",",mf_disch_obs_cd,",",mf_disch_daystay_cd,",",
   mf_disch_es_cd,",",mf_exp_inpatient_cd,",",mf_exp_obs_cd,
   ",",mf_exp_daystay_cd,",",mf_exp_es_cd,")")
 ELSEIF (ms_encntr_types="ALL")
  SET ms_encntr_type_disp = "All Encounter Types"
  SET ms_encntr_type_p = "1=1"
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl p,
   encounter e,
   prsnl p2
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_end_dt)
    AND oa.action_type_cd=mf_order_action_cd)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.template_order_id=0
    AND  NOT (o.orig_ord_as_flag IN (1, 2, 3))
    AND o.contributor_system_cd=mf_powerchart_cd
    AND parser(ms_order_type_p))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND parser(ms_encntr_type_p))
   JOIN (p
   WHERE (p.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(oa.order_provider_id)) )
  ORDER BY e.loc_facility_cd, p.person_id
  HEAD REPORT
   ml_cnt = 0
  HEAD p.person_id
   mf_mdcount = 0, mf_prcount = 0, mf_pvcount = 0,
   mf_sidcount = 0, mf_wrcount = 0, mf_otcount = 0
  DETAIL
   IF (oa.action_personnel_id=oa.order_provider_id)
    IF (oa.action_personnel_id != 1)
     mf_mdcount += 1
    ENDIF
   ELSE
    CASE (oa.communication_type_cd)
     OF mf_protocol_cd:
      mf_prcount += 1
     OF mf_phoneverbal_cd:
      mf_pvcount += 1
     OF mf_secimmundowntime_cd:
      mf_sidcount += 1
     OF mf_written_cd:
      mf_wrcount += 1
     ELSE
      mf_otcount += 1
    ENDCASE
   ENDIF
  FOOT  p.person_id
   mf_totcount = ((((mf_mdcount+ mf_prcount)+ mf_pvcount)+ mf_sidcount)+ mf_wrcount)
   IF (mf_totcount > 0)
    ml_cnt += 1
    IF (mod(ml_cnt,100)=1)
     stat = alterlist(m_rec->phys,(ml_cnt+ 99))
    ENDIF
    m_rec->phys[ml_cnt].f_mdcount = mf_mdcount, m_rec->phys[ml_cnt].f_prcount = mf_prcount, m_rec->
    phys[ml_cnt].f_pvcount = mf_pvcount,
    m_rec->phys[ml_cnt].f_wrcount = mf_wrcount, m_rec->phys[ml_cnt].f_sidcount = mf_sidcount, m_rec->
    phys[ml_cnt].f_otcount = mf_otcount,
    m_rec->phys[ml_cnt].f_totcount = mf_totcount, m_rec->phys[ml_cnt].f_cpoecount = (mf_mdcount+
    mf_wrcount), m_rec->phys[ml_cnt].f_mdpct = (mf_mdcount/ mf_totcount),
    m_rec->phys[ml_cnt].f_prpct = (mf_prcount/ mf_totcount), m_rec->phys[ml_cnt].f_pvpct = (
    mf_pvcount/ mf_totcount), m_rec->phys[ml_cnt].f_sidpct = (mf_sidcount/ mf_totcount),
    m_rec->phys[ml_cnt].f_wrpct = (mf_wrcount/ mf_totcount), m_rec->phys[ml_cnt].f_cpoerate = (
    mf_mdcount/ (mf_mdcount+ mf_wrcount)), m_rec->phys[ml_cnt].f_facility_cd = e.loc_facility_cd,
    m_rec->phys[ml_cnt].s_name = p.name_full_formatted, m_rec->phys[ml_cnt].s_facility_disp =
    evaluate(e.loc_facility_cd,0.00,"Unknown Facility",substring(1,40,uar_get_code_display(e
       .loc_facility_cd)))
    CASE (uar_get_code_display(p.position_cd))
     OF "BHS Anesthesiology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Anesthesiology"
     OF "BHS ER Medicine MD":
      m_rec->phys[ml_cnt].s_phys_type = "Emergency Medicine"
     OF "BHS Cardiac Surgery MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS Urology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS Thoracic MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS Trauma MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS Orthopedics MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS General Surgery MD":
      m_rec->phys[ml_cnt].s_phys_type = "Surgery"
     OF "BHS Resident":
      m_rec->phys[ml_cnt].s_phys_type = "Resident"
     OF "BHS Neonatal MD":
      m_rec->phys[ml_cnt].s_phys_type = "Pediatrics"
     OF "BHS General Pediatrics MD":
      m_rec->phys[ml_cnt].s_phys_type = "Pediatrics"
     OF "BHS OB/GYN MD":
      m_rec->phys[ml_cnt].s_phys_type = "Ob/Gyn"
     OF "BHS Midwife":
      m_rec->phys[ml_cnt].s_phys_type = "Ob/Gyn"
     OF "BHS Psychiatry MD":
      m_rec->phys[ml_cnt].s_phys_type = "Psychiatry"
     OF "BHS Radiology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Radiology"
     OF "BHS Associate Professional":
      m_rec->phys[ml_cnt].s_phys_type = "Associate Provider"
     OF "BHS PCO Associate Professional":
      m_rec->phys[ml_cnt].s_phys_type = "Associate Provider"
     OF "BHS Medical Student":
      m_rec->phys[ml_cnt].s_phys_type = "Medical Student"
     OF "BHS Cardiology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Critical Care MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Infectious Disease MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS GI MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Oncology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Neurology MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Physiatry MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Pulmonary MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Renal MD":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS AMB Platinum Physician":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Physician (General Medicine)":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     OF "BHS Physician -Physician Practices":
      m_rec->phys[ml_cnt].s_phys_type = "Internal Medicine"
     ELSE
      m_rec->phys[ml_cnt].s_phys_type = "Other"
    ENDCASE
    IF (ms_report_type="HBI")
     IF ((m_rec->phys[ml_cnt].s_facility_disp IN ("FMC", "ADULT PHP- FMC", "BEACON RCV",
     "OUTPT PSYCH", "FMC INPT PSYCH",
     "BRAT RETRE", "BFMC", "ADULT PHP- BFMC", "BFMC INPT PSYCH")))
      m_rec->phys[ml_cnt].s_facility_group = "BFMC"
     ELSEIF ((m_rec->phys[ml_cnt].s_facility_disp IN ("MLH", "BMLH")))
      m_rec->phys[ml_cnt].s_facility_group = "BMLH"
     ELSEIF ((m_rec->phys[ml_cnt].s_facility_disp IN ("BWH", "BWH INPT PSYCH")))
      m_rec->phys[ml_cnt].s_facility_group = "BWH "
     ELSEIF ((m_rec->phys[ml_cnt].s_facility_disp IN ("BNH", "BNH INPT PSYCH")))
      m_rec->phys[ml_cnt].s_facility_group = "BNH"
     ELSEIF ((m_rec->phys[ml_cnt].s_facility_disp="MOCK"))
      m_rec->phys[ml_cnt].s_facility_group = "MOCK"
     ELSEIF ((m_rec->phys[ml_cnt].s_facility_disp="Unknown Facility"))
      m_rec->phys[ml_cnt].s_facility_group = "Unknown Facility"
     ELSE
      m_rec->phys[ml_cnt].s_facility_group = "BMC"
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->phys,ml_cnt)
  WITH nocounter
 ;end select
 IF (ms_report_type="SUMMARY")
  SELECT INTO "nl:"
   docname = substring(1,100,m_rec->phys[d.seq].s_name), facility = m_rec->phys[d.seq].
   s_facility_disp
   FROM (dummyt d  WITH seq = value(size(m_rec->phys,5)))
   PLAN (d)
   ORDER BY docname, facility
   HEAD REPORT
    ml_cnt = 0, ml_cnt2 = 0, mf_mdcount = 0,
    mf_prcount = 0, mf_pvcount = 0, mf_sidcount = 0,
    mf_wrcount = 0, mf_otcount = 0, mf_totcount = 0
   HEAD docname
    ml_cnt2 = 0
   DETAIL
    ml_cnt += 1, ml_cnt2 += 1
    IF (ml_cnt > size(m_rec->phys_summ,5))
     CALL alterlist(m_rec->phys_summ,(ml_cnt+ 100))
    ENDIF
    m_rec->phys_summ[ml_cnt].s_name = m_rec->phys[d.seq].s_name, m_rec->phys_summ[ml_cnt].
    s_facility_disp = m_rec->phys[d.seq].s_facility_disp, m_rec->phys_summ[ml_cnt].s_phys_type =
    m_rec->phys[d.seq].s_phys_type,
    m_rec->phys_summ[ml_cnt].s_mdcount = cnvtstring(m_rec->phys[d.seq].f_mdcount), m_rec->phys_summ[
    ml_cnt].s_mdpct = build(format((m_rec->phys[d.seq].f_mdpct * 100),"###.##%;R")), m_rec->
    phys_summ[ml_cnt].s_prcount = cnvtstring(m_rec->phys[d.seq].f_prcount),
    m_rec->phys_summ[ml_cnt].s_prpct = build(format((m_rec->phys[d.seq].f_prpct * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_pvcount = cnvtstring(m_rec->phys[d.seq].f_pvcount), m_rec->phys_summ[
    ml_cnt].s_pvpct = build(format((m_rec->phys[d.seq].f_pvpct * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_sidcount = cnvtstring(m_rec->phys[d.seq].f_sidcount), m_rec->
    phys_summ[ml_cnt].s_sidpct = build(format((m_rec->phys[d.seq].f_sidpct * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_wrcount = cnvtstring(m_rec->phys[d.seq].f_wrcount),
    m_rec->phys_summ[ml_cnt].s_wrpct = build(format((m_rec->phys[d.seq].f_wrpct * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_otcount = cnvtstring(m_rec->phys[d.seq].f_otcount), m_rec->phys_summ[
    ml_cnt].s_totcount = cnvtstring(m_rec->phys[d.seq].f_totcount),
    m_rec->phys_summ[ml_cnt].s_cpoerate = build(format((m_rec->phys[d.seq].f_cpoerate * 100),
      "###.##%;R")), mf_mdcount += m_rec->phys[d.seq].f_mdcount, mf_prcount += m_rec->phys[d.seq].
    f_prcount,
    mf_pvcount += m_rec->phys[d.seq].f_pvcount, mf_sidcount += m_rec->phys[d.seq].f_sidcount,
    mf_wrcount += m_rec->phys[d.seq].f_wrcount,
    mf_otcount += m_rec->phys[d.seq].f_otcount, mf_totcount += m_rec->phys[d.seq].f_totcount,
    mf_mdpct += m_rec->phys[d.seq].f_mdpct,
    mf_prpct += m_rec->phys[d.seq].f_prpct, mf_pvpct += m_rec->phys[d.seq].f_pvpct, mf_sidpct +=
    m_rec->phys[d.seq].f_sidpct,
    mf_wrpct += m_rec->phys[d.seq].f_wrpct, mf_cpoerate += m_rec->phys[d.seq].f_cpoerate
   FOOT  docname
    ml_cnt += 1
    IF (((ml_cnt+ 1) > size(m_rec->phys_summ,5)))
     CALL alterlist(m_rec->phys_summ,(ml_cnt+ 100))
    ENDIF
    m_rec->phys_summ[ml_cnt].s_name = m_rec->phys[d.seq].s_name, m_rec->phys_summ[ml_cnt].s_phys_type
     = m_rec->phys[d.seq].s_phys_type, m_rec->phys_summ[ml_cnt].s_facility_disp = "--- Total ---",
    m_rec->phys_summ[ml_cnt].s_mdcount = cnvtstring(mf_mdcount), m_rec->phys_summ[ml_cnt].s_prcount
     = cnvtstring(mf_prcount), m_rec->phys_summ[ml_cnt].s_pvcount = cnvtstring(mf_pvcount),
    m_rec->phys_summ[ml_cnt].s_sidcount = cnvtstring(mf_sidcount), m_rec->phys_summ[ml_cnt].s_wrcount
     = cnvtstring(mf_wrcount), m_rec->phys_summ[ml_cnt].s_otcount = cnvtstring(mf_otcount),
    m_rec->phys_summ[ml_cnt].s_totcount = cnvtstring(mf_totcount), m_rec->phys_summ[ml_cnt].s_mdpct
     = build(format(((mf_mdpct/ ml_cnt2) * 100),"###.##%;R")), m_rec->phys_summ[ml_cnt].s_prpct =
    build(format(((mf_prpct/ ml_cnt2) * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_pvpct = build(format(((mf_pvpct/ ml_cnt2) * 100),"###.##%;R")), m_rec
    ->phys_summ[ml_cnt].s_sidpct = build(format(((mf_sidpct/ ml_cnt2) * 100),"###.##%;R")), m_rec->
    phys_summ[ml_cnt].s_wrpct = build(format(((mf_wrpct/ ml_cnt2) * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_cpoerate = build(format(((mf_cpoerate/ ml_cnt2) * 100),"###.##%;R")),
    ml_cnt += 1, m_rec->phys_summ[ml_cnt].s_name = m_rec->phys[d.seq].s_name,
    m_rec->phys_summ[ml_cnt].s_phys_type = m_rec->phys[d.seq].s_phys_type, m_rec->phys_summ[ml_cnt].
    s_facility_disp = cnvtstring(mf_totcount), m_rec->phys_summ[ml_cnt].s_mdpct = build(format(((
      mf_mdcount/ mf_totcount) * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_prpct = build(format(((mf_prcount/ mf_totcount) * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_pvpct = build(format(((mf_pvcount/ mf_totcount) * 100),"###.##%;R")),
    m_rec->phys_summ[ml_cnt].s_sidpct = build(format(((mf_sidcount/ mf_totcount) * 100),"###.##%;R")
     ),
    m_rec->phys_summ[ml_cnt].s_wrpct = build(format(((mf_wrcount/ mf_totcount) * 100),"###.##%;R")),
    mf_mdcount = 0, mf_prcount = 0,
    mf_pvcount = 0, mf_sidcount = 0, mf_wrcount = 0,
    mf_otcount = 0, mf_totcount = 0, mf_mdpct = 0,
    mf_prpct = 0, mf_pvpct = 0, mf_sidpct = 0,
    mf_wrpct = 0, mf_cpoerate = 0, ml_cnt += 1
   FOOT REPORT
    CALL alterlist(m_rec->phys_summ,(ml_cnt - 1))
   WITH nocounter
  ;end select
  IF (mn_email_ind=0)
   SELECT INTO value(ms_output)
    docname = substring(1,100,m_rec->phys_summ[d.seq].s_name), specialty = substring(1,100,m_rec->
     phys_summ[d.seq].s_phys_type), facility = substring(1,100,m_rec->phys_summ[d.seq].
     s_facility_disp),
    md_ord = m_rec->phys_summ[d.seq].s_mdcount, md_pct = m_rec->phys_summ[d.seq].s_mdpct, prot_ord =
    m_rec->phys_summ[d.seq].s_prcount,
    prot_pct = m_rec->phys_summ[d.seq].s_prpct, phvb_ord = m_rec->phys_summ[d.seq].s_pvcount,
    phvb_pct = m_rec->phys_summ[d.seq].s_pvpct,
    sid_ord = m_rec->phys_summ[d.seq].s_sidcount, sid_pct = m_rec->phys_summ[d.seq].s_sidpct,
    writ_ord = m_rec->phys_summ[d.seq].s_wrcount,
    writ_pct = m_rec->phys_summ[d.seq].s_wrpct, other_ord = m_rec->phys_summ[d.seq].s_otcount,
    total_ord = m_rec->phys_summ[d.seq].s_totcount,
    cpoe_rate = m_rec->phys_summ[d.seq].s_cpoerate
    FROM (dummyt d  WITH seq = value(size(m_rec->phys_summ,5)))
    PLAN (d)
    WITH nocounter, format, separator = " "
   ;end select
  ELSE
   SET ms_filename_in = trim(concat(ms_output,".csv"),3)
   SET ms_subject = concat(curprog," - Baystate Health CPOE Summary Report ",ms_start_dt_disp," to ",
    ms_end_dt_disp,
    ", ",ms_order_type_disp,", ",ms_encntr_type_disp)
   SET frec->file_name = ms_filename_in
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"DOCNAME",','"SPECIALTY",','"FACILITY",','"MD_ORD",','"MD_PCT",',
    '"PROT_ORD",','"PROT_PCT",','"PHVB_ORD",','"PHVB_PCT",','"SID_ORD",',
    '"SID_PCT",','"WRIT_ORD",','"WRIT_PCT",','"OTHER_ORD",','"TOTAL_ORD",',
    '"CPOE_RATE",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_cnt = 1 TO size(m_rec->phys_summ,5))
    SET frec->file_buf = build('"',trim(m_rec->phys_summ[ml_cnt].s_name,3),'","',trim(m_rec->
      phys_summ[ml_cnt].s_phys_type,3),'","',
     trim(m_rec->phys_summ[ml_cnt].s_facility_disp,3),'","',trim(m_rec->phys_summ[ml_cnt].s_mdcount,3
      ),'","',trim(m_rec->phys_summ[ml_cnt].s_mdpct,3),
     '","',trim(m_rec->phys_summ[ml_cnt].s_prcount,3),'","',trim(m_rec->phys_summ[ml_cnt].s_prpct,3),
     '","',
     trim(m_rec->phys_summ[ml_cnt].s_pvcount,3),'","',trim(m_rec->phys_summ[ml_cnt].s_pvpct,3),'","',
     trim(m_rec->phys_summ[ml_cnt].s_sidcount,3),
     '","',trim(m_rec->phys_summ[ml_cnt].s_sidpct,3),'","',trim(m_rec->phys_summ[ml_cnt].s_wrcount,3),
     '","',
     trim(m_rec->phys_summ[ml_cnt].s_wrpct,3),'","',trim(m_rec->phys_summ[ml_cnt].s_otcount,3),'","',
     trim(m_rec->phys_summ[ml_cnt].s_totcount,3),
     '","',trim(m_rec->phys_summ[ml_cnt].s_cpoerate,3),'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ENDIF
 ELSE
  IF (mn_email_ind=1)
   SET ms_filename_in = trim(concat(ms_output,".dat"),3)
   SET ms_subject = concat(curprog," - Baystate Health CPOE Report ",ms_start_dt_disp," to ",
    ms_end_dt_disp,
    ", ",ms_order_type_disp,", ",ms_encntr_type_disp)
  ENDIF
  SELECT INTO value(ms_output)
   facility = m_rec->phys[d.seq].f_facility_cd, doc_name = substring(1,31,m_rec->phys[d.seq].s_name)
   FROM (dummyt d  WITH seq = value(size(m_rec->phys,5)))
   ORDER BY facility, doc_name
   HEAD REPORT
    IF (ms_report_type="REPORTWRITER")
     IF (mn_email_ind=0)
      col 1, "Date Range: ", ms_start_dt_disp,
      " - ", ms_end_dt_disp, row + 1,
      col 1, ms_order_type_disp, row + 1,
      col 1, ms_encntr_type_disp, row + 1,
      col 002, "DocName", col 034,
      "Specialty", col 054, "MD Ord",
      col 064, "MD Pct", col 074,
      "Prot Ord", col 084, "Prot Pct",
      col 097, "PhVb Ord", col 107,
      "PhVb Pct", col 120, "SID Ord",
      col 130, "SID Pct", col 142,
      "Writ Ord", col 152, "Writ Pct",
      col 163, "Other Ord", col 174,
      "Total Ord", col 186, "CPOE Rate",
      row + 1
     ELSE
      col 1, ',"Date Range: ', ms_start_dt_disp,
      " - ", ms_end_dt_disp, '"',
      row + 1, col 1, ',"',
      ms_order_type_disp, '"', row + 1,
      col 1, ',"', ms_encntr_type_disp,
      '"', row + 1, ms_temp = concat(',"DocName","Specialty","Facility","MD Ord","MD Pct","Prot Ord"',
       ',"Prot Pct","PhVb Ord","PhVb Pct","SID Ord","SID Pct"',
       ',"Writ Ord","Writ Pct","Other Ord","Total Ord","CPOE Rate"'),
      col 1, ms_temp, row + 1
     ENDIF
    ENDIF
   HEAD facility
    IF (ms_report_type="REPORTWRITER"
     AND mn_email_ind=0)
     col 1, m_rec->phys[d.seq].s_facility_disp, row + 1
    ENDIF
   DETAIL
    IF (ms_report_type="REPORTWRITER")
     IF (mn_email_ind=0)
      col 002, doc_name, col 034,
      m_rec->phys[d.seq].s_phys_type, col 055, m_rec->phys[d.seq].f_mdcount"#####;R",
      col 064, m_rec->phys[d.seq].f_mdpct"#.####;R", col 077,
      m_rec->phys[d.seq].f_prcount"#####;R", col 086, m_rec->phys[d.seq].f_prpct"#.####;R",
      col 100, m_rec->phys[d.seq].f_pvcount"#####;R", col 109,
      m_rec->phys[d.seq].f_pvpct"#.####;R", col 122, m_rec->phys[d.seq].f_sidcount"#####;R",
      col 131, m_rec->phys[d.seq].f_sidpct"#.####;R", col 145,
      m_rec->phys[d.seq].f_wrcount"#####;R", col 154, m_rec->phys[d.seq].f_wrpct"#.####;R",
      col 167, m_rec->phys[d.seq].f_otcount"#####;R", col 177,
      m_rec->phys[d.seq].f_totcount"######;R", col 189, m_rec->phys[d.seq].f_cpoerate"#.####;R"
     ELSE
      ms_temp = build(',"',m_rec->phys[d.seq].s_name,'","',m_rec->phys[d.seq].s_phys_type,'","',
       m_rec->phys[d.seq].s_facility_disp,'",',m_rec->phys[d.seq].f_mdcount,",",m_rec->phys[d.seq].
       f_mdpct,
       ",",m_rec->phys[d.seq].f_prcount,",",m_rec->phys[d.seq].f_prpct,",",
       m_rec->phys[d.seq].f_pvcount,",",m_rec->phys[d.seq].f_pvpct,",",m_rec->phys[d.seq].f_sidcount,
       ",",m_rec->phys[d.seq].f_sidpct,",",m_rec->phys[d.seq].f_wrcount,",",
       m_rec->phys[d.seq].f_wrpct,",",m_rec->phys[d.seq].f_otcount,",",m_rec->phys[d.seq].f_totcount,
       ",",m_rec->phys[d.seq].f_cpoerate), col 1, ms_temp
     ENDIF
     row + 1
    ELSE
     ms_temp = build(",",ms_end_dt_disp,',"',doc_name,'","',
      m_rec->phys[d.seq].s_phys_type,'","',m_rec->phys[d.seq].s_facility_disp,'","',m_rec->phys[d.seq
      ].s_facility_group,
      '",',m_rec->phys[d.seq].f_mdcount,",",m_rec->phys[d.seq].f_prcount,",",
      m_rec->phys[d.seq].f_pvcount,",",m_rec->phys[d.seq].f_sidcount,",",m_rec->phys[d.seq].f_wrcount,
      ",",m_rec->phys[d.seq].f_otcount,",",m_rec->phys[d.seq].f_totcount,",",
      m_rec->phys[d.seq].f_cpoecount), col 1, ms_temp,
     row + 1
    ENDIF
   WITH maxcol = 200, maxrow = 1000, format = variable,
    landscape, compress
  ;end select
 ENDIF
 IF (mn_email_ind=1)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out,ms_recipients,ms_subject,1)
  SET ms_dclcom = "rm -f bhs_rpt_cls_physstats*"
  SET stat = 0
  SET stat = dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ENDIF
END GO
