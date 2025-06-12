CREATE PROGRAM bhs_rpt_risk_med_elderly
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location" = 0
  WITH outdev, s_beg_date, s_end_date,
  f_facility
 DECLARE mf_ordered_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY))
 DECLARE mf_pharmacy_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")), protect
 DECLARE mf_cdispensabledrugnames_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,
   "CDISPENSABLEDRUGNAMES")), protect
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_daystay_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"DAYSTAY")), protect
 DECLARE mf_observation_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")),
 protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 FREE RECORD med
 RECORD med(
   1 syn[*]
     2 f_catalog_cd = f8
     2 ms_catalog_disp = vc
     2 f_synonym_id = f8
     2 ms_synonym_disp = vc
 )
 FREE RECORD ord
 RECORD ord(
   1 d_beg_dt_tm = dq8
   1 d_end_dt_tm = dq8
   1 qual[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 ms_reg_dt_tm = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_pat_loc = vc
     2 s_pat_fac = vc
     2 s_age = vc
     2 s_pat_bed = vc
     2 med[*]
       3 ms_ord_dt_tm = vc
       3 ms_doc_name = vc
       3 n_med_type = i2
       3 f_ord_id = f8
       3 ms_ord_dose = vc
       3 ms_ord_freq = vc
       3 ms_ord_rte = vc
       3 ms_ord_info = vc
       3 ms_ord_status = vc
       3 ms_cat_disp = vc
       3 mf_cat_cd = f8
       3 s_dose = vc
       3 s_f_dose = vc
       3 s_v_dose = vc
       3 s_v_dose_unit = vc
       3 s_s_dose = vc
       3 s_s_dose_unit = vc
       3 s_rate = vc
       3 s_rate_unit = vc
       3 s_route = vc
       3 s_freq = vc
       3 s_duration = vc
       3 s_duration_unit = vc
       3 s_prn_reason = vc
 )
 DECLARE pl_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ms_beg_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date_disp = vc WITH protect, noconstant(" ")
 DECLARE mf_beg_date_qual = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_date_qual = f8 WITH protect, noconstant(0.0)
 DECLARE mf_s_date = f8 WITH protect, noconstant(0.0)
 DECLARE mf_e_date = f8 WITH protect, noconstant(0.0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 SET ms_output_dest =  $OUTDEV
 SET mf_beg_date_qual = cnvtdatetime(build(trim( $S_BEG_DATE)," 00:00:00"))
 SET mf_end_date_qual = cnvtdatetime(build(trim( $S_END_DATE)," 23:59:59"))
 SET ms_beg_date_disp = format(mf_beg_date_qual,";;q")
 SET ms_end_date_disp = format(mf_end_date_qual,";;q")
 SET ord->d_beg_dt_tm = cnvtdatetime( $S_BEG_DATE)
 SET ord->d_end_dt_tm = cnvtdatetime( $S_END_DATE)
 CALL echo(ms_beg_date_disp)
 CALL echo(ms_end_date_disp)
 IF (datetimediff(mf_end_date_qual,mf_beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(mf_end_date_qual,mf_beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.primary_mnemonic IN ("amiTRIPTYLINE", "Acetaminophen/Butalbital/Caffeine",
   "Atropine / Diphenoxylate", "Baclofen", "Benztropine",
   "Carisoprodol", "Chlordiazepoxide", "Chlordiazepoxide-Methscopolamine", "Clozapine",
   "Cyclobenzaprine",
   "Dantrolene", "Desipramine", "Diazepam", "DiphenhydrAMINE", "Famotidine",
   "Haloperidol", "HydrOXYzine", "Imipramine", "Ketorolac", "Nortriptyline",
   "Orphenadrine", "PROCHLORperazine", "Promethazine", "Promethazine 1.25 mg/Codeine 2 mg/mL",
   "Quetiapine",
   "Scopolamine", "Tizanidine", "Trifluoperazine", "Trihexyphenidyl"))
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd=mf_cdispensabledrugnames_var)
  ORDER BY ocs.catalog_cd, ocs.synonym_id
  HEAD REPORT
   mn_cnt = 0
  HEAD ocs.synonym_id
   mn_cnt += 1, stat = alterlist(med->syn,mn_cnt), med->syn[mn_cnt].f_catalog_cd = ocs.catalog_cd,
   med->syn[mn_cnt].ms_catalog_disp = uar_get_code_display(ocs.catalog_cd), med->syn[mn_cnt].
   f_synonym_id = ocs.synonym_id, med->syn[mn_cnt].ms_synonym_disp = ocs.mnemonic
  WITH nocounter
 ;end select
 CALL echorecord(med)
 SELECT INTO "nl:"
  med_type =
  IF (o.prn_ind=1) 3
  ELSEIF (o.iv_ind=1) 4
  ELSEIF (o.freq_type_flag=5) 2
  ELSE 1
  ENDIF
  FROM orders o,
   order_action oa,
   encounter e,
   person p,
   prsnl p1
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ord->d_beg_dt_tm) AND cnvtdatetime(ord->d_end_dt_tm)
    AND expand(ml_cnt1,1,size(med->syn,5),o.catalog_cd,med->syn[ml_cnt1].f_catalog_cd)
    AND o.template_order_id=0
    AND o.order_status_cd=mf_ordered_var
    AND o.active_ind=1
    AND o.orig_ord_as_flag=0)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.birth_dt_tm <= cnvtdatetimeutc(cnvtagedatetime(64,0,0,0),1)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=mf_facility_cd
    AND e.encntr_type_class_cd IN (mf_inpt_cd, mf_daystay_var, mf_observation_var)
    AND e.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.core_ind=1)
   JOIN (p1
   WHERE p1.person_id=oa.order_provider_id)
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   ml_cnt = 0, pl_cnt += 1, stat = alterlist(ord->qual,pl_cnt),
   ord->qual[pl_cnt].f_person_id = o.person_id, ord->qual[pl_cnt].f_encntr_id = o.encntr_id, ord->
   qual[pl_cnt].s_pat_name = p.name_full_formatted,
   ord->qual[pl_cnt].s_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd), ord->qual[pl_cnt].
   s_pat_bed = uar_get_code_display(e.loc_bed_cd), ord->qual[pl_cnt].s_pat_fac = uar_get_code_display
   (e.loc_facility_cd),
   ord->qual[pl_cnt].s_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1))
  HEAD o.order_id
   ml_cnt += 1, stat = alterlist(ord->qual[pl_cnt].med,ml_cnt), ord->qual[pl_cnt].med[ml_cnt].
   ms_ord_dt_tm = format(o.orig_order_dt_tm,"@SHORTDATETIME"),
   ord->qual[pl_cnt].med[ml_cnt].f_ord_id = o.order_id, ord->qual[pl_cnt].med[ml_cnt].ms_cat_disp =
   uar_get_code_display(o.catalog_cd), ord->qual[pl_cnt].med[ml_cnt].mf_cat_cd = o.catalog_cd,
   ord->qual[pl_cnt].med[ml_cnt].n_med_type = med_type, ord->qual[pl_cnt].med[ml_cnt].ms_ord_status
    = uar_get_code_display(o.order_status_cd), ord->qual[pl_cnt].med[ml_cnt].ms_doc_name = p1
   .name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(ord->qual,5))),
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d1)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(ord->qual[d1.seq].f_encntr_id))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_fin_cd)) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(ord->qual[d1.seq].f_encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  DETAIL
   ord->qual[d1.seq].s_fin = trim(ea1.alias), ord->qual[d1.seq].s_mrn = trim(ea2.alias)
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(ord->qual,5))),
   (dummyt d2  WITH seq = 1),
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,size(ord->qual[d1.seq].med,5)))
   JOIN (d2)
   JOIN (od
   WHERE (od.order_id=ord->qual[d1.seq].med[d2.seq].f_ord_id)
    AND od.oe_field_meaning IN ("FREETXTDOSE", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT",
   "RATE", "RATEUNIT", "RXROUTE", "FREQ", "DURATION",
   "DURATIONUNIT", "PRNREASON"))
  HEAD od.order_id
   null
  DETAIL
   CASE (od.oe_field_meaning)
    OF "FREETXTDOSE":
     ord->qual[d1.seq].med[d2.seq].s_f_dose = trim(od.oe_field_display_value,3)
    OF "VOLUMEDOSE":
     ord->qual[d1.seq].med[d2.seq].s_v_dose = trim(od.oe_field_display_value,3)
    OF "VOLUMEDOSEUNIT":
     ord->qual[d1.seq].med[d2.seq].s_v_dose_unit = trim(od.oe_field_display_value,3)
    OF "STRENGTHDOSE":
     ord->qual[d1.seq].med[d2.seq].s_s_dose = trim(od.oe_field_display_value,3)
    OF "STRENGTHDOSEUNIT":
     ord->qual[d1.seq].med[d2.seq].s_s_dose_unit = trim(od.oe_field_display_value,3)
    OF "RATE":
     ord->qual[d1.seq].med[d2.seq].s_rate = trim(od.oe_field_display_value,3)
    OF "RATEUNIT":
     ord->qual[d1.seq].med[d2.seq].s_rate_unit = trim(od.oe_field_display_value,3)
    OF "RXROUTE":
     ord->qual[d1.seq].med[d2.seq].s_route = trim(od.oe_field_display_value,3)
    OF "FREQ":
     ord->qual[d1.seq].med[d2.seq].s_freq = trim(od.oe_field_display_value,3)
    OF "DURATION":
     ord->qual[d1.seq].med[d2.seq].s_duration = trim(od.oe_field_display_value,3)
    OF "DURATIONUNIT":
     ord->qual[d1.seq].med[d2.seq].s_duration_unit = trim(od.oe_field_display_value,3)
    OF "PRNREASON":
     ord->qual[d1.seq].med[d2.seq].s_prn_reason = trim(od.oe_field_display_value,3)
   ENDCASE
  FOOT  od.order_id
   IF (trim(ord->qual[d1.seq].med[d2.seq].s_v_dose,3) > " "
    AND trim(ord->qual[d1.seq].med[d2.seq].s_s_dose,3) > " ")
    ord->qual[d1.seq].med[d2.seq].s_dose = build2(ord->qual[d1.seq].med[d2.seq].s_s_dose," ",ord->
     qual[d1.seq].med[d2.seq].s_s_dose_unit,"/",ord->qual[d1.seq].med[d2.seq].s_v_dose,
     " ",ord->qual[d1.seq].med[d2.seq].s_v_dose_unit)
   ELSEIF (trim(ord->qual[d1.seq].med[d2.seq].s_s_dose,3) > " ")
    ord->qual[d1.seq].med[d2.seq].s_dose = build2(ord->qual[d1.seq].med[d2.seq].s_s_dose," ",ord->
     qual[d1.seq].med[d2.seq].s_s_dose_unit)
   ELSEIF (trim(ord->qual[d1.seq].med[d2.seq].s_v_dose,3) > " ")
    ord->qual[d1.seq].med[d2.seq].s_dose = build2(ord->qual[d1.seq].med[d2.seq].s_v_dose," ",ord->
     qual[d1.seq].med[d2.seq].s_v_dose_unit)
   ELSE
    ord->qual[d1.seq].med[d2.seq].s_dose = ord->qual[d1.seq].med[d2.seq].s_f_dose
   ENDIF
   CASE (ord->qual[d1.seq].med[d2.seq].n_med_type)
    OF 1:
     ord->qual[d1.seq].med[d2.seq].ms_ord_info = build2("DOSE: ",ord->qual[d1.seq].med[d2.seq].s_dose,
      "  ","ROUTE: ",ord->qual[d1.seq].med[d2.seq].s_route,
      "  ","FREQ: ",ord->qual[d1.seq].med[d2.seq].s_freq," ",ord->qual[d1.seq].med[d2.seq].s_duration,
      " ",ord->qual[d1.seq].med[d2.seq].s_duration_unit)
    OF 2:
     ord->qual[d1.seq].med[d2.seq].ms_ord_info = build2("DOSE: ",ord->qual[d1.seq].med[d2.seq].s_dose,
      "  ","ROUTE: ",ord->qual[d1.seq].med[d2.seq].s_route,
      "  ","FREQ: ",ord->qual[d1.seq].med[d2.seq].s_freq," ",ord->qual[d1.seq].med[d2.seq].s_duration,
      " ",ord->qual[d1.seq].med[d2.seq].s_duration_unit)
    OF 3:
     ord->qual[d1.seq].med[d2.seq].ms_ord_info = build2("DOSE: ",ord->qual[d1.seq].med[d2.seq].s_dose,
      "  ","ROUTE: ",ord->qual[d1.seq].med[d2.seq].s_route,
      "  ","FREQ: ",ord->qual[d1.seq].med[d2.seq].s_freq," ",ord->qual[d1.seq].med[d2.seq].s_duration,
      " ",ord->qual[d1.seq].med[d2.seq].s_duration_unit,"  ","PRN REASON: ",ord->qual[d1.seq].med[d2
      .seq].s_prn_reason)
    OF 4:
     ord->qual[d1.seq].med[d2.seq].ms_ord_info = build2("DOSE: ",ord->qual[d1.seq].med[d2.seq].s_dose,
      "  ","RATE: ",ord->qual[d1.seq].med[d2.seq].s_rate,
      " ",ord->qual[d1.seq].med[d2.seq].s_rate_unit,"  ",ord->qual[d1.seq].med[d2.seq].s_duration," ",
      ord->qual[d1.seq].med[d2.seq].s_duration_unit)
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 CALL echorecord(ord)
 SELECT INTO value(ms_output_dest)
  pt_name = substring(1,100,ord->qual[d1.seq].s_pat_name), mrn = ord->qual[d1.seq].s_mrn, fin = ord->
  qual[d1.seq].s_fin,
  nurse_unit = ord->qual[d1.seq].s_pat_loc, bed = ord->qual[d1.seq].s_pat_bed, age = ord->qual[d1.seq
  ].s_age,
  med = substring(1,50,ord->qual[d1.seq].med[d2.seq].ms_cat_disp), order_dt_tm = ord->qual[d1.seq].
  med[d2.seq].ms_ord_dt_tm, order_status = ord->qual[d1.seq].med[d2.seq].ms_ord_status,
  order_info = substring(1,200,ord->qual[d1.seq].med[d2.seq].ms_ord_info), order_md = substring(1,100,
   ord->qual[d1.seq].med[d2.seq].ms_doc_name)
  FROM (dummyt d1  WITH seq = value(size(ord->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(ord->qual[d1.seq].med,5)))
   JOIN (d2)
  ORDER BY pt_name
  WITH separator = " ", format, skipreport = 1
 ;end select
#exit_script
END GO
