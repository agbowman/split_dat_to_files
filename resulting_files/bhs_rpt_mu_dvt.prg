CREATE PROGRAM bhs_rpt_mu_dvt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location" = 0
  WITH outdev, s_beg_date, s_end_date,
  f_facility
 IF (( $OUTDEV="MINE"))
  SET var_output = "bhs_rpt_mu_dvt"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 FREE RECORD dvt_info
 RECORD dvt_info(
   1 s_facility_name = vc
   1 ent[*]
     2 f_encntr_id = f8
     2 s_fin = vc
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_ord_provider = vc
     2 s_dischg_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 s_diagnosis = vc
     2 s_attending_md = vc
     2 s_loc = vc
     2 n_icu_ind = i2
     2 vte1_n = i2
     2 vte1_d = i2
     2 vte2_n = i2
     2 vte2_d = i2
     2 vte3_n = i2
     2 vte3_d = i2
     2 vte4_n = i2
     2 vte4_d = i2
     2 vte5_n = i2
     2 vte5_d = i2
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim(concat( $S_BEG_DATE," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(concat( $S_END_DATE," 23:59:59")))
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_compressionboots_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "PNEUMATICCOMPRESSIONBOOTS"))
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mf_heparin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN"))
 DECLARE mf_heparin_cd1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN10000UNITSIN500MLNACL"))
 DECLARE mf_heparin_cd2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN10000UNITSINNACL09500ML"))
 DECLARE mf_heparin_cd3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN1000UNITSINNACL09500ML"))
 DECLARE mf_heparin_cd4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN250UNITSINNACL09250ML"))
 DECLARE mf_heparin_cd5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN500UNITSINNACL09500ML"))
 DECLARE mf_heparin_cd6 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARIN10000UNITSIN500MLNACL"))
 DECLARE mf_heparin_cd7 = f8 WITH protect, constant(1468856.0)
 DECLARE mf_heparin_cd8 = f8 WITH protect, constant(110059848)
 DECLARE mf_heparin_cd9 = f8 WITH protect, constant(110059952)
 DECLARE mf_heparin_cd10 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HEPARINPF100UNITSML"))
 DECLARE mf_warfarin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN"))
 DECLARE mf_enoxaparin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENOXAPARIN"))
 DECLARE mf_pharmacologicprophylaxisfordvt_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"PHARMACOLOGICPROPHYLAXISFORDVT"))
 DECLARE mf_riskofvenousthromboembolism_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"RISKOFVENOUSTHROMBOEMBOLISM"))
 DECLARE mf_otherreason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERREASON"))
 DECLARE mf_plateletcount_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PLATELETCOUNT"))
 DECLARE mf_coumadin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTEDMEDICATIONINSTRUCTIONDETAIL"))
 DECLARE mf_ldrpa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPA"))
 DECLARE mf_ldrpb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPB"))
 DECLARE mf_ldrpc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPC"))
 DECLARE mf_win2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WIN2"))
 DECLARE mf_bmcpreadmit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"BMCPREADMIT"
   ))
 DECLARE mf_bfmcpreadmit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BFMCPREADMIT"))
 DECLARE mf_obgn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"OBGN"))
 DECLARE ms_line = vc
 SET beg_date_qual = cnvtdatetime(ms_beg_dt_tm)
 SET end_date_qual = cnvtdatetime(ms_end_dt_tm)
 CALL echo(build("starts..."))
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.encntr_type_class_cd=mf_inpatient_cd
    AND e.loc_facility_cd=mf_facility_cd
    AND  NOT (e.loc_nurse_unit_cd IN (mf_ldrpa_cd, mf_ldrpb_cd, mf_ldrpc_cd, mf_bmcpreadmit_cd,
   mf_win2_cd,
   mf_bfmcpreadmit_cd, mf_obgn_cd)))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND ((cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)+ 0) <= cnvtdatetimeutc(
    cnvtagedatetime(18,0,0,0),1))
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt += 1, stat = alterlist(dvt_info->ent,cnt), dvt_info->s_facility_name = uar_get_code_display(
    mf_facility_cd),
   dvt_info->ent[cnt].f_encntr_id = e.encntr_id, dvt_info->ent[cnt].f_person_id = e.person_id,
   dvt_info->ent[cnt].s_dischg_dt_tm = cnvtdatetime(e.disch_dt_tm),
   dvt_info->ent[cnt].s_loc = uar_get_code_display(e.loc_nurse_unit_cd), dvt_info->ent[cnt].
   f_person_id = p.person_id, dvt_info->ent[cnt].s_pat_name = p.name_full_formatted,
   dvt_info->ent[cnt].reg_dt_tm = cnvtdatetime(e.reg_dt_tm), dvt_info->ent[cnt].vte1_d = 1
  DETAIL
   IF (uar_get_code_display(elh.loc_nurse_unit_cd) IN ("CVCU", "CVIC", "ICCU", "ICU", "ICU-A",
   "ICU-B", "ICU-C", "NICU", "PICU", "SICU",
   "MICU", "HVCC"))
    dvt_info->ent[cnt].vte2_d = 1, dvt_info->ent[cnt].n_icu_ind = 1
   ENDIF
  FOOT  e.encntr_id
   row + 0
  FOOT REPORT
   x = 0
  WITH nocounter
 ;end select
 CALL echo(build("for vte1 numerator 1"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd IN (mf_compressionboots_cd, mf_heparin_cd, mf_warfarin_cd, mf_enoxaparin_cd,
   mf_heparin_cd1,
   mf_heparin_cd2, mf_heparin_cd3, mf_heparin_cd4, mf_heparin_cd5, mf_heparin_cd6,
   mf_heparin_cd7, mf_heparin_cd8, mf_heparin_cd9, mf_heparin_cd10,
   mf_pharmacologicprophylaxisfordvt_cd)
    AND o.template_order_id=0
    AND o.current_start_dt_tm BETWEEN cnvtdatetime(dvt_info->ent[d.seq].reg_dt_tm) AND cnvtlookahead(
    "2,D",cnvtdatetime(dvt_info->ent[d.seq].reg_dt_tm)))
  DETAIL
   dvt_info->ent[d.seq].vte1_n = 1
   IF (o.catalog_cd=mf_pharmacologicprophylaxisfordvt_cd)
    CALL echo(build("vte1_n2 = ",concat(cnvtstring(dvt_info->ent[d.seq].vte1_n),cnvtstring(o.order_id
       ))))
   ENDIF
   IF ((dvt_info->ent[d.seq].vte2_d=1))
    dvt_info->ent[d.seq].vte2_n = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("for vte1 numerator 2"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd=mf_riskofvenousthromboembolism_cd
    AND o.template_order_id=0
    AND o.current_start_dt_tm BETWEEN cnvtdatetime(dvt_info->ent[d.seq].reg_dt_tm) AND cnvtlookahead(
    "2,D",cnvtdatetime(dvt_info->ent[d.seq].reg_dt_tm)))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_otherreason_cd
    AND od.oe_field_display_value="LOW Risk")
  DETAIL
   dvt_info->ent[d.seq].vte1_n = 1,
   CALL echo(build("vte1_n22 = ",concat(cnvtstring(dvt_info->ent[d.seq].vte1_n),cnvtstring(o.order_id
      ),od.oe_field_display_value)))
   IF ((dvt_info->ent[d.seq].vte2_d=1))
    dvt_info->ent[d.seq].vte2_n = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   diagnosis diag,
   bhs_nomen_list bnl
  PLAN (d)
   JOIN (diag
   WHERE (diag.encntr_id=dvt_info->ent[d.seq].f_encntr_id))
   JOIN (bnl
   WHERE bnl.nomenclature_id=diag.nomenclature_id
    AND bnl.nomen_list_key="VTE-VENOUSTHROMBOEMBOLISMPROPHYLAXIS")
  DETAIL
   dvt_info->ent[d.seq].s_diagnosis = diag.diagnosis_display, dvt_info->ent[d.seq].vte3_d = 1
  WITH nocounter
 ;end select
 CALL echo(build("for vte3 numerator"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o,
   orders o1
  PLAN (d
   WHERE datetimediff(dvt_info->ent[d.seq].s_dischg_dt_tm,dvt_info->ent[d.seq].reg_dt_tm) >= 5
    AND (dvt_info->ent[d.seq].vte3_d=1))
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd=mf_warfarin_cd
    AND o.template_order_id=0)
   JOIN (o1
   WHERE o.encntr_id=o1.encntr_id
    AND o1.catalog_cd IN (mf_heparin_cd, mf_enoxaparin_cd)
    AND o1.template_order_id=0)
  DETAIL
   IF (o.current_start_dt_tm > o1.current_start_dt_tm)
    start_dt_tm = o.current_start_dt_tm
   ELSE
    start_dt_tm = o1.current_start_dt_tm
   ENDIF
   IF (o.projected_stop_dt_tm > o1.projected_stop_dt_tm)
    end_dt_tm = o.projected_stop_dt_tm
   ELSE
    end_dt_tm = o1.projected_stop_dt_tm
   ENDIF
   IF (datetimediff(end_dt_tm,start_dt_tm) >= 5)
    dvt_info->ent[d.seq].vte3_n = 1,
    CALL echo(build("vte3_n1 = ",concat(cnvtstring(dvt_info->ent[d.seq].vte3_n),cnvtstring(o.order_id
       ),cnvtstring(o1.order_id),cnvtstring(o.encntr_id))))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("for vte3 numerator 2 ..."))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o,
   orders o1
  PLAN (d
   WHERE datetimediff(dvt_info->ent[d.seq].s_dischg_dt_tm,dvt_info->ent[d.seq].reg_dt_tm) < 5
    AND (dvt_info->ent[d.seq].vte3_d=1)
    AND (dvt_info->ent[d.seq].vte3_n=0))
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd=mf_warfarin_cd
    AND o.template_order_id=0
    AND o.orig_ord_as_flag=1)
   JOIN (o1
   WHERE o.encntr_id=o1.encntr_id
    AND o1.catalog_cd IN (mf_heparin_cd, mf_enoxaparin_cd)
    AND o1.template_order_id=0
    AND o1.orig_ord_as_flag=1)
  DETAIL
   dvt_info->ent[d.seq].vte3_n = 1,
   CALL echo(build("vte3_n2 = ",concat(cnvtstring(dvt_info->ent[d.seq].vte3_n),cnvtstring(o.order_id),
     cnvtstring(o1.order_id),cnvtstring(o.encntr_id))))
  WITH nocounter
 ;end select
 CALL echo(build("for vte4 Denominator"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o
  PLAN (d
   WHERE (dvt_info->ent[d.seq].vte3_d=1))
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd IN (mf_heparin_cd, mf_heparin_cd1, mf_heparin_cd2, mf_heparin_cd3,
   mf_heparin_cd4,
   mf_heparin_cd5, mf_heparin_cd6, mf_heparin_cd7, mf_heparin_cd8, mf_heparin_cd9,
   mf_heparin_cd10)
    AND o.template_order_id=0)
  DETAIL
   dvt_info->ent[d.seq].vte4_d = 1
  WITH nocounter
 ;end select
 CALL echo(build("for vte4 Numerator"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o,
   clinical_event ce
  PLAN (d
   WHERE (dvt_info->ent[d.seq].vte4_d=1))
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd IN (mf_heparin_cd, mf_heparin_cd1, mf_heparin_cd2, mf_heparin_cd3,
   mf_heparin_cd4,
   mf_heparin_cd5, mf_heparin_cd6, mf_heparin_cd7, mf_heparin_cd8, mf_heparin_cd9,
   mf_heparin_cd10)
    AND o.template_order_id=0)
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.event_cd=mf_plateletcount_cd
    AND ce.valid_from_dt_tm BETWEEN o.current_start_dt_tm AND o.projected_stop_dt_tm)
  DETAIL
   dvt_info->ent[d.seq].vte4_n = 1
  WITH nocounter
 ;end select
 CALL echo(build("for vte5 Denominator"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   orders o
  PLAN (d
   WHERE (dvt_info->ent[d.seq].vte3_d=1))
   JOIN (o
   WHERE (o.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND o.catalog_cd=mf_warfarin_cd
    AND o.template_order_id=0
    AND o.orig_ord_as_flag=1)
  DETAIL
   dvt_info->ent[d.seq].vte5_d = 1
  WITH nocounter
 ;end select
 CALL echo(build("for vte5 Numerator"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   clinical_event ce
  PLAN (d
   WHERE (dvt_info->ent[d.seq].vte5_d=1))
   JOIN (ce
   WHERE (ce.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND ce.event_cd=mf_coumadin_cd
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1)
  ORDER BY ce.clinical_event_id
  HEAD ce.clinical_event_id
   IF ((dvt_info->ent[d.seq].vte5_n=0))
    IF (findstring("Coumadin booklet",ce.result_val,1,0) != 0)
     dvt_info->ent[d.seq].vte5_n = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   encntr_alias ea1
  PLAN (d)
   JOIN (ea1
   WHERE (ea1.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
  DETAIL
   dvt_info->ent[d.seq].s_fin = trim(ea1.alias)
  WITH nocounter
 ;end select
 CALL echo(build("get attending physician"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5))),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=dvt_info->ent[d.seq].f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_attending_cd
    AND epr.end_effective_dt_tm > sysdate
    AND epr.active_ind=1)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.active_ind=1)
  DETAIL
   dvt_info->ent[d.seq].s_attending_md = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO value(var_output)
  facility = substring(1,4,dvt_info->s_facility_name), fin = dvt_info->ent[d.seq].s_fin, attending_md
   = substring(1,30,dvt_info->ent[d.seq].s_attending_md),
  discharge_dt_tm = format(dvt_info->ent[d.seq].s_dischg_dt_tm,"@SHORTDATETIME"), encounter_loc =
  dvt_info->ent[d.seq].s_loc, diagnosis = substring(1,25,dvt_info->ent[d.seq].s_diagnosis),
  vte1_n = dvt_info->ent[d.seq].vte1_n, vte1_numerator =
  IF ((dvt_info->ent[d.seq].vte1_n=1)) "Yes"
  ELSE " "
  ENDIF
  , vte1_d = dvt_info->ent[d.seq].vte1_d,
  vte1_denominator =
  IF ((dvt_info->ent[d.seq].vte1_d=1)) "Yes"
  ELSE " "
  ENDIF
  , vte2_n = dvt_info->ent[d.seq].vte2_n, vte2_numerator =
  IF ((dvt_info->ent[d.seq].vte2_n=1)) "Yes"
  ELSE " "
  ENDIF
  ,
  vte2_d = dvt_info->ent[d.seq].vte2_d, vte2_denominator =
  IF ((dvt_info->ent[d.seq].vte2_d=1)) "Yes"
  ELSE " "
  ENDIF
  , vte3_n = dvt_info->ent[d.seq].vte3_n,
  vte3_numerator =
  IF ((dvt_info->ent[d.seq].vte3_n=1)) "Yes"
  ELSE " "
  ENDIF
  , vte3_d = dvt_info->ent[d.seq].vte3_d, vte3_denominator =
  IF ((dvt_info->ent[d.seq].vte3_d=1)) "Yes"
  ELSE " "
  ENDIF
  ,
  vte4_n = dvt_info->ent[d.seq].vte4_n, vte4_numerator =
  IF ((dvt_info->ent[d.seq].vte4_n=1)) "Yes"
  ELSE " "
  ENDIF
  , vte4_d = dvt_info->ent[d.seq].vte4_d,
  vte4_denominator =
  IF ((dvt_info->ent[d.seq].vte4_d=1)) "Yes"
  ELSE " "
  ENDIF
  , vte5_n = dvt_info->ent[d.seq].vte5_n, vte5_numerator =
  IF ((dvt_info->ent[d.seq].vte5_n=1)) "Yes"
  ELSE " "
  ENDIF
  ,
  vte5_d = dvt_info->ent[d.seq].vte5_d, vte5_denominator =
  IF ((dvt_info->ent[d.seq].vte5_d=1)) "Yes"
  ELSE " "
  ENDIF
  FROM (dummyt d  WITH seq = value(size(dvt_info->ent,5)))
  PLAN (d)
  HEAD REPORT
   vte1_n_t = 0.0, vte1_d_t = 0.0, vte2_n_t = 0.0,
   vte2_d_t = 0.0, vte3_n_t = 0.0, vte3_d_t = 0.0,
   vte4_n_t = 0.0, vte4_d_t = 0.0, vte5_n_t = 0.0,
   vte5_d_t = 0.0, vte1_percent = 0.00, vte2_percent = 0.00,
   vte3_percent = 0.00, vte4_percent = 0.00, vte5_percent = 0.00,
   ms_line = build("facility_name","~","fin","~","attending_md",
    "~","dischg_dt_tm","~","nursing_loc","~",
    "diagnosis","~","vte1_n","~","vte1_numerator",
    "~","vte1_d","~","vte1_denominator","~",
    "vte2_n","~","vte2_numerator","~","vte2_d",
    "~","vte2_denominator","~","vte3_n","~",
    "vte3_numerator","~","vte3_d","~","vte3_denominator",
    "~","vte4_n","~","vte4_numerator","~",
    "vte4_d","~","vte4_denominator","~","vte5_n",
    "~","vte5_numerator","~","vte5_d","~",
    "vte5_denominator"), col 0, ms_line,
   row + 1
  DETAIL
   vte1_n_t += vte1_n, vte1_d_t += vte1_d, vte2_n_t += vte2_n,
   vte2_d_t += vte2_d, vte3_n_t += vte3_n, vte3_d_t += vte3_d,
   vte4_n_t += vte4_n, vte4_d_t += vte4_d, vte5_n_t += vte5_n,
   vte5_d_t += vte5_d, row 0, ms_line = build(dvt_info->s_facility_name,"~",dvt_info->ent[d.seq].
    s_fin,"~",substring(1,30,dvt_info->ent[d.seq].s_attending_md),
    "~",format(dvt_info->ent[d.seq].s_dischg_dt_tm,"@SHORTDATETIME"),"~",dvt_info->ent[d.seq].s_loc,
    "~",
    substring(1,25,dvt_info->ent[d.seq].s_diagnosis),"~",vte1_n,"~",vte1_numerator,
    "~",vte1_d,"~",vte1_denominator,"~",
    vte2_n,"~",vte2_numerator,"~",vte2_d,
    "~",vte2_denominator,"~",vte3_n,"~",
    vte3_numerator,"~",vte3_d,"~",vte3_denominator,
    "~",vte4_n,"~",vte4_numerator,"~",
    vte4_d,"~",vte4_denominator,"~",vte5_n,
    "~",vte5_numerator,"~",vte5_d,"~",
    vte5_denominator),
   col 0, ms_line, row + 1
  FOOT REPORT
   row + 1, vte1_percent = round(((vte1_n_t/ vte1_d_t) * 100),2), vte2_percent = round(((vte2_n_t/
    vte2_d_t) * 100),2),
   vte3_percent = round(((vte3_n_t/ vte3_d_t) * 100),2), vte4_percent = round(((vte4_n_t/ vte4_d_t)
     * 100),2), vte5_percent = round(((vte5_n_t/ vte5_d_t) * 100),2),
   ms_line = build("VTE1 Percentage: ",vte1_percent), col 0, ms_line,
   row + 1, ms_line = build("VTE2 Percentage: ",vte2_percent), col 0,
   ms_line, row + 1, ms_line = build("VTE3 Percentage: ",vte3_percent),
   col 0, ms_line, row + 1,
   ms_line = build("VTE4 Percentage: ",vte4_percent), col 0, ms_line,
   row + 1, ms_line = build("VTE5 Percentage: ",vte5_percent), col 0,
   ms_line, row + 1
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
#exit_prg
END GO
