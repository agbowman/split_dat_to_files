CREATE PROGRAM bhs_rpt_pharm_renal:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Start Date:" = "CURDATE",
  "Enter End Date:" = "CURDATE",
  "Choose Facility:" = 0,
  "Choose Nurse Unit(s):" = 0,
  "Choose Medication(s);" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility_cd, f_nurse_unit, f_med_cat_cd
 FREE RECORD m_info
 RECORD m_info(
   1 encntrs[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_location = vc
     2 n_incl_encntr = i2
     2 n_incl_rpt = i2
     2 ords[*]
       3 n_incl_ord = i2
       3 f_order_id = f8
       3 s_mnemonic = vc
       3 s_dose = vc
       3 s_freq = vc
       3 s_route = vc
     2 labs[*]
       3 f_order_id = f8
       3 s_res_dt_tm = vc
       3 s_lab_name = vc
       3 s_result = vc
 )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_beg_dt = vc WITH protect, constant( $S_BEG_DT)
 DECLARE ms_end_dt = vc WITH protect, constant( $S_END_DT)
 DECLARE mf_facility_cd = f8 WITH protect, constant( $F_FACILITY_CD)
 DECLARE mn_nurse_unit_param = i2 WITH protect, constant(5)
 DECLARE mn_med_cd_param = i2 WITH protect, constant(6)
 DECLARE mf_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE mf_ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_dose_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE"))
 DECLARE mf_dose_unit_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSEUNIT"))
 DECLARE mf_vol_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"VOLUMEDOSE"))
 DECLARE mf_vol_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "VOLUMEDOSEUNIT"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_pharm_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE mf_c_disp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,
   "CDISPENSABLEDRUGNAMES"))
 DECLARE mf_gen_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE mf_creat_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CREATININE"))
 DECLARE mf_gfr_afr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRAFRICANAMERICAN"))
 DECLARE mf_gfr_nonafr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRNONAFRICANAMERICAN"))
 DECLARE mf_creat_bld_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"Creatinine-Blood")
  )
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_nurse_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_med_cd_list = vc WITH protect, noconstant(" ")
 DECLARE ms_meds = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_max_results = i4 WITH protect, noconstant(0)
 DECLARE mf_base_val = f8 WITH protect, noconstant(0.0)
 DECLARE ms_base_time = vc WITH protect, noconstant(" ")
 CALL echo("verify dates")
 IF (cnvtdatetime(ms_beg_dt) > cnvtdatetime(ms_end_dt))
  SET ms_log = "Begin date must come BEFORE end date"
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_dt),cnvtdatetime(ms_beg_dt)) > 31)
  SET ms_log = "Time interval is greater than 31 days.  Please choose a smaller date range"
  GO TO exit_script
 ENDIF
 CALL echo("get nurse unit cds")
 SET ms_data_type = reflect(parameter(mn_nurse_unit_param,0))
 IF (substring(1,1,ms_data_type)="C")
  SET ms_nurse_unit = parameter(mn_nurse_unit_param,1)
  IF (ms_nurse_unit=char(42))
   SET ms_nurse_unit = " 1=1"
  ENDIF
 ELSEIF (substring(1,1,ms_data_type) IN ("I", "F"))
  SET ms_nurse_unit = trim(cnvtstring(parameter(mn_nurse_unit_param,1)))
  CALL echo(build2("ms_nurse_unit: ",ms_nurse_unit))
  IF ( NOT (trim(ms_nurse_unit) IN (null, "", " ", "0")))
   SET ms_nurse_unit = concat(" ed.loc_nurse_unit_cd = ",trim(ms_nurse_unit))
  ELSE
   SET ms_log = "No nurse unit chosen"
   GO TO exit_script
  ENDIF
 ELSEIF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp = trim(cnvtstring(parameter(mn_nurse_unit_param,ml_cnt)))
   IF (ml_cnt=1)
    SET ms_nurse_unit = concat(" ed.loc_nurse_unit_cd in (",trim(ms_tmp))
   ELSE
    SET ms_nurse_unit = concat(ms_nurse_unit,", ",trim(ms_tmp))
   ENDIF
  ENDFOR
  SET ms_nurse_unit = concat(ms_nurse_unit,")")
 ENDIF
 CALL echo(build2("ms_nurse_unit: ",ms_nurse_unit))
 CALL echo("get meds cds")
 SET ms_data_type = reflect(parameter(mn_med_cd_param,0))
 SET ms_tmp = "0"
 CALL echo(build2("ms_data_type: ",ms_data_type))
 IF (substring(1,1,ms_data_type)="C")
  SET ms_tmp = parameter(mn_med_cd_param,1)
  IF (ms_tmp=char(42))
   SET ms_tmp = "1"
  ENDIF
 ENDIF
 CALL echo("create meds string")
 CALL echo(build2("ms_tmp: ",ms_tmp))
 IF (ms_tmp="1")
  SET ms_meds = "All"
  SELECT DISTINCT INTO "nl:"
   oc.catalog_cd
   FROM order_catalog oc,
    order_catalog_synonym ocs
   PLAN (oc
    WHERE oc.catalog_type_cd=mf_pharm_cat_cd
     AND ((cnvtupper(oc.primary_mnemonic)="ABACAVIR-LAMIVUDINE") OR (((cnvtupper(oc.primary_mnemonic)
    ="ACYCLOVIR") OR (((cnvtupper(oc.primary_mnemonic)="AMIKACIN") OR (((cnvtupper(oc
     .primary_mnemonic)="AMOXICILLIN") OR (((cnvtupper(oc.primary_mnemonic)="AMOXICILLIN-CLAVULANATE"
    ) OR (((cnvtupper(oc.primary_mnemonic)="AMPICILLIN") OR (((cnvtupper(oc.primary_mnemonic)=
    "AMPICILLIN-SULBACTAM") OR (((cnvtupper(oc.primary_mnemonic)="AZTREONAM") OR (((cnvtupper(oc
     .primary_mnemonic)="CEFAZOLIN") OR (((cnvtupper(oc.primary_mnemonic)="CEFEPIME") OR (((cnvtupper
    (oc.primary_mnemonic)="CEFOXITIN") OR (((cnvtupper(oc.primary_mnemonic)="CEFPODOXIME") OR (((
    cnvtupper(oc.primary_mnemonic)="CEPHALEXIN") OR (((cnvtupper(oc.primary_mnemonic)="CIPROFLOXACIN"
    ) OR (((cnvtupper(oc.primary_mnemonic)="DAPTOMYCIN") OR (((cnvtupper(oc.primary_mnemonic)=
    "EMTRICITABINE") OR (((cnvtupper(oc.primary_mnemonic)="EMTRICITABINE-TENOFOVIR") OR (((cnvtupper(
     oc.primary_mnemonic)="ENOXAPARIN") OR (((cnvtupper(oc.primary_mnemonic)="EPZICOM") OR (((
    cnvtupper(oc.primary_mnemonic)="ERTAPENEM") OR (((cnvtupper(oc.primary_mnemonic)="ETHAMBUTOL")
     OR (((cnvtupper(oc.primary_mnemonic)="FAMOTIDINE") OR (((cnvtupper(oc.primary_mnemonic)=
    "FLUCONAZOLE") OR (((cnvtupper(oc.primary_mnemonic)="GANCICLOVIR") OR (((cnvtupper(oc
     .primary_mnemonic)="GENTAMICIN") OR (((cnvtupper(oc.primary_mnemonic)="LAMIVUDINE") OR (((
    cnvtupper(oc.primary_mnemonic)="LAMIVUDINE-ZIDOVUDINE") OR (((cnvtupper(oc.primary_mnemonic)=
    "LEVOFLOXACIN") OR (((cnvtupper(oc.primary_mnemonic)="METFORMIN") OR (((cnvtupper(oc
     .primary_mnemonic)="MEROPENEM") OR (((cnvtupper(oc.primary_mnemonic)="NITROFURANTOIN") OR (((
    cnvtupper(oc.primary_mnemonic)="PENICILLIN*") OR (((cnvtupper(oc.primary_mnemonic)=
    "PIPERACILLIN-TAZOBACTAM") OR (((cnvtupper(oc.primary_mnemonic)="SULFAMETHOXAZOLE/TRIMETHOPRIM")
     OR (((cnvtupper(oc.primary_mnemonic)="TENOFOVIR") OR (((cnvtupper(oc.primary_mnemonic)=
    "TOBRAMYCIN") OR (((cnvtupper(oc.primary_mnemonic)="TRUVADA*") OR (((cnvtupper(oc
     .primary_mnemonic)="VALACYCLOVIR") OR (((cnvtupper(oc.primary_mnemonic)="VALGANCICLOVIR") OR (
    cnvtupper(oc.primary_mnemonic)="VANCOMYCIN")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
    )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
     AND cnvtupper(oc.dept_display_name) != "ZZ*"
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.mnemonic_type_cd=mf_c_disp_cd)
   HEAD REPORT
    pl_cnt = 0, ms_med_cd_list = " o.catalog_cd in ("
   HEAD oc.catalog_cd
    pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > 1)
     ms_med_cd_list = concat(trim(ms_med_cd_list),",")
    ENDIF
    ms_med_cd_list = concat(trim(ms_med_cd_list),trim(cnvtstring(oc.catalog_cd)))
   FOOT REPORT
    ms_med_cd_list = concat(trim(ms_med_cd_list),")"),
    CALL echo(build2("pl_cnt: ",pl_cnt))
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $F_MED_CAT_CD)
     AND cv.code_value > 0
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm > sysdate)
   ORDER BY cv.display
   HEAD cv.display
    CALL echo(build("here: ",cv.display))
    IF (trim(ms_meds) <= " ")
     ms_med_cd_list = concat(" o.catalog_cd in (",trim(cnvtstring(cv.code_value))), ms_meds = trim(cv
      .display)
    ELSE
     ms_med_cd_list = concat(", ",trim(cnvtstring(cv.code_value))), ms_meds = concat(ms_meds,", ",
      trim(cv.display))
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_log = "No medications chosen"
   GO TO exit_script
  ENDIF
  SET ms_med_cd_list = concat(ms_med_cd_list,")")
 ENDIF
 CALL echo(build2("meds cd list: ",ms_med_cd_list))
 CALL echo("get encounters")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.loc_facility_cd=mf_facility_cd
    AND parser(ms_nurse_unit)
    AND ed.active_status_cd=mf_active_cd
    AND ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=mf_inpatient_cd
    AND ((e.disch_dt_tm >= cnvtdatetime(ms_beg_dt)
    AND e.disch_dt_tm <= cnvtdatetime(ms_end_dt)) OR (e.disch_dt_tm = null
    AND e.reg_dt_tm <= cnvtdatetime(ms_end_dt))) )
  ORDER BY ed.encntr_id
  HEAD REPORT
   pl_enc_cnt = 0, pl_ord_cnt = 0
  HEAD ed.encntr_id
   pl_enc_cnt = (pl_enc_cnt+ 1)
   IF (pl_enc_cnt > size(m_info->encntrs,5))
    stat = alterlist(m_info->encntrs,(pl_enc_cnt+ 10))
   ENDIF
   m_info->encntrs[pl_enc_cnt].f_encntr_id = ed.encntr_id, m_info->encntrs[pl_enc_cnt].f_person_id =
   ed.person_id, m_info->encntrs[pl_enc_cnt].s_location = trim(uar_get_code_display(ed
     .loc_nurse_unit_cd)),
   pl_ord_cnt = 0
  FOOT REPORT
   stat = alterlist(m_info->encntrs,pl_enc_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No encounters found"
  GO TO exit_script
 ENDIF
 CALL echo("get orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND parser(ms_med_cd_list)
    AND o.activity_type_cd=mf_pharm_act_cd
    AND o.catalog_type_cd=mf_pharm_cat_cd
    AND o.order_status_cd=mf_ordered_cd
    AND o.template_order_id=0)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (mf_dose_cd, mf_dose_unit_cd, mf_vol_dose_cd, mf_vol_dose_unit_cd,
   mf_freq_cd,
   mf_route_cd))
  ORDER BY o.encntr_id
  HEAD REPORT
   pl_ord_cnt = 0
  HEAD o.encntr_id
   pl_ord_cnt = 0
  HEAD o.order_id
   m_info->encntrs[d.seq].n_incl_encntr = 1, pl_ord_cnt = (pl_ord_cnt+ 1)
   IF (pl_ord_cnt > size(m_info->encntrs[d.seq].ords,5))
    stat = alterlist(m_info->encntrs[d.seq].ords,(pl_ord_cnt+ 10))
   ENDIF
   m_info->encntrs[d.seq].ords[pl_ord_cnt].f_order_id = o.order_id, m_info->encntrs[d.seq].ords[
   pl_ord_cnt].s_mnemonic = trim(o.order_mnemonic)
  DETAIL
   CASE (od.oe_field_id)
    OF mf_dose_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = trim(od.oe_field_display_value)
    OF mf_dose_unit_cd:
     ms_tmp = trim(od.oe_field_display_value)
    OF mf_vol_dose_cd:
     IF (trim(m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose) < " ")
      m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = trim(od.oe_field_display_value)
     ENDIF
    OF mf_vol_dose_unit_cd:
     IF (trim(ms_tmp) < " ")
      ms_tmp = trim(od.oe_field_display_value)
     ENDIF
    OF mf_freq_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_freq = trim(od.oe_field_display_value)
    OF mf_route_cd:
     m_info->encntrs[d.seq].ords[pl_ord_cnt].s_route = trim(od.oe_field_display_value)
   ENDCASE
  FOOT  o.order_id
   m_info->encntrs[d.seq].ords[pl_ord_cnt].s_dose = concat(m_info->encntrs[d.seq].ords[pl_ord_cnt].
    s_dose," ",trim(ms_tmp))
  FOOT  o.encntr_id
   stat = alterlist(m_info->encntrs[d.seq].ords,pl_ord_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "no orders found"
  GO TO exit_script
 ENDIF
 CALL echo("get names")
 SELECT INTO "nl:"
  p.person_id
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   person p
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_incl_encntr=1))
   JOIN (p
   WHERE (p.person_id=m_info->encntrs[d.seq].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
  HEAD p.person_id
   m_info->encntrs[d.seq].s_pat_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 CALL echo("get FINs")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   encntr_alias ea
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_incl_encntr=1))
   JOIN (ea
   WHERE (ea.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  DETAIL
   m_info->encntrs[d.seq].s_fin = trim(ea.alias)
  WITH nocounter
 ;end select
 CALL echo("get labs")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   orders o,
   clinical_event ce
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_incl_encntr=1))
   JOIN (o
   WHERE (o.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND o.catalog_cd=mf_creat_cat_cd
    AND o.activity_type_cd=mf_gen_lab_cd
    AND o.catalog_type_cd=mf_lab_cd
    AND o.order_status_cd=mf_completed_cd
    AND o.template_order_id=0)
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.order_id=o.order_id
    AND ce.event_cd IN (mf_creat_bld_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_val > " "
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
  ORDER BY o.encntr_id, ce.event_end_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_prev_cnt = 0, pf_num_res = 0.0,
   pn_exclude = 0
  HEAD o.encntr_id
   pl_cnt = 0
  HEAD o.order_id
   pn_exclude = 0, pl_prev_cnt = pl_cnt,
   CALL echo(build2("head order_id; pl_prev_cnt: ",pl_prev_cnt))
  DETAIL
   pf_num_res = 0.0
   IF (pl_cnt < 4)
    IF (isnumeric(ce.result_val) > 0)
     pf_num_res = cnvtreal(ce.result_val)
    ELSE
     IF (findstring(">",ce.result_val) > 0)
      pf_num_res = cnvtreal(replace(ce.result_val,">",""))
     ENDIF
    ENDIF
    CALL echo(build2("num_res: ",pf_num_res)),
    CALL echo(build2("event cd: ",uar_get_code_display(ce.event_cd)))
    IF (pl_cnt=0)
     ms_base_time = trim(format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d")), mf_base_val = pf_num_res,
     pl_cnt = (pl_cnt+ 1),
     stat = alterlist(m_info->encntrs[d.seq].labs,pl_cnt), m_info->encntrs[d.seq].labs[pl_cnt].
     f_order_id = o.order_id, m_info->encntrs[d.seq].labs[pl_cnt].s_res_dt_tm = trim(format(ce
       .event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
     m_info->encntrs[d.seq].labs[pl_cnt].s_lab_name = trim(uar_get_code_display(ce.event_cd)), m_info
     ->encntrs[d.seq].labs[pl_cnt].s_result = concat(trim(ce.result_val)," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ELSE
     IF (datetimediff(ce.event_end_dt_tm,cnvtdatetime(ms_base_time),4) >= 1440)
      IF ((((pf_num_res <= (mf_base_val/ 2))) OR ((pf_num_res >= (mf_base_val * 1.5)))) )
       ms_base_time = trim(format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d")), mf_base_val =
       pf_num_res, m_info->encntrs[d.seq].n_incl_rpt = 1,
       pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->encntrs[d.seq].labs,pl_cnt), m_info->encntrs[d
       .seq].labs[pl_cnt].f_order_id = o.order_id,
       m_info->encntrs[d.seq].labs[pl_cnt].s_res_dt_tm = trim(format(ce.event_end_dt_tm,
         "dd-mmm-yyyy hh:mm;;d")), m_info->encntrs[d.seq].labs[pl_cnt].s_lab_name = trim(
        uar_get_code_display(ce.event_cd)), m_info->encntrs[d.seq].labs[pl_cnt].s_result = concat(
        trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  o.order_id
   CALL echo("foot order_id")
   IF (pn_exclude=1)
    CALL echo("exclude labs"),
    CALL echo(build2("prev_cnt: ",pl_prev_cnt," pl_cnt: ",pl_cnt)),
    CALL echo(build2("encntr_id: ",m_info->encntrs[d.seq].f_encntr_id)),
    CALL echo(build2("order_id: ",o.order_id)),
    CALL echo(build2("lab_cnt: ",size(m_info->encntrs[d.seq].labs,5))), stat = alterlist(m_info->
     encntrs[d.seq].labs,pl_prev_cnt),
    pl_cnt = pl_prev_cnt
   ENDIF
   CALL echo("foot order_id end")
  FOOT  o.encntr_id
   IF (pl_cnt > ml_max_results)
    ml_max_results = pl_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL echo("no lab results found")
  GO TO exit_script
 ENDIF
 IF (ml_max_results > 4)
  SET ml_max_results = 4
 ENDIF
 FOR (ml_cnt = 1 TO size(m_info->encntrs,5))
   IF (size(m_info->encntrs[ml_cnt].ords,5) > 0)
    SELECT DISTINCT INTO "nl:"
     ps_mnemonic = m_info->encntrs[ml_cnt].ords[d.seq].s_mnemonic, ps_dose = m_info->encntrs[ml_cnt].
     ords[d.seq].s_dose, ps_freq = m_info->encntrs[ml_cnt].ords[d.seq].s_freq,
     ps_route = m_info->encntrs[ml_cnt].ords[d.seq].s_route
     FROM (dummyt d  WITH seq = value(size(m_info->encntrs[ml_cnt].ords,5)))
     PLAN (d
      WHERE (m_info->encntrs[ml_cnt].n_incl_encntr=1))
     ORDER BY ps_mnemonic, ps_dose, ps_freq,
      ps_route
     DETAIL
      m_info->encntrs[ml_cnt].ords[d.seq].n_incl_ord = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SELECT INTO value(ms_output)
  pf_encntr_id = m_info->encntrs[d.seq].f_encntr_id
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5)))
  PLAN (d
   WHERE (m_info->encntrs[d.seq].n_incl_rpt=1))
  HEAD REPORT
   pl_col = 0, pl_res = 0, col pl_col,
   "Patient_Name", pl_col = (pl_col+ 50), col pl_col,
   "FIN", pl_col = (pl_col+ 50), col pl_col,
   "Location", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Drug", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Dose", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Freq", pl_col = (pl_col+ 50), col pl_col,
   "Trigger_Route", pl_col = (pl_col+ 50)
   FOR (ml_cnt = 1 TO ml_max_results)
     ms_tmp = concat("Lab_",trim(cnvtstring(ml_cnt))), col pl_col, ms_tmp,
     pl_col = (pl_col+ 50), ms_tmp = concat("Lab_",trim(cnvtstring(ml_cnt)),"_Result"), col pl_col,
     ms_tmp, pl_col = (pl_col+ 50), ms_tmp = concat("Lab_",trim(cnvtstring(ml_cnt)),"_Date"),
     col pl_col, ms_tmp, pl_col = (pl_col+ 50)
   ENDFOR
  HEAD pf_encntr_id
   pl_res = size(m_info->encntrs[d.seq].labs,5)
   IF (pl_res > 0)
    FOR (ml_cnt = 1 TO size(m_info->encntrs[d.seq].ords,5))
      IF ((m_info->encntrs[d.seq].ords[ml_cnt].n_incl_ord=1))
       row + 1, pl_col = 0, col pl_col,
       m_info->encntrs[d.seq].s_pat_name, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].s_fin, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].s_location, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_mnemonic, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_dose, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_freq, pl_col = (pl_col+ 50), col pl_col,
       m_info->encntrs[d.seq].ords[ml_cnt].s_route, pl_col = (pl_col+ 50)
       IF (pl_res > ml_max_results)
        pl_res = ml_max_results
       ENDIF
       FOR (ml_cnt2 = 1 TO pl_res)
         col pl_col, m_info->encntrs[d.seq].labs[ml_cnt2].s_lab_name, pl_col = (pl_col+ 50),
         col pl_col, m_info->encntrs[d.seq].labs[ml_cnt2].s_result, pl_col = (pl_col+ 50),
         col pl_col, m_info->encntrs[d.seq].labs[ml_cnt2].s_res_dt_tm, pl_col = (pl_col+ 50)
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
 SET ms_log = ""
#exit_script
 CALL echorecord(m_info)
 IF (trim(ms_log) > " ")
  CALL echo(ms_log)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    ms_tmp = build2("size: ",size(m_info->encntrs,5)), col 0, ms_tmp,
    ms_tmp = build2("med list: ",ms_meds), col 0, row + 1,
    ms_tmp, col 0, row + 1,
    ms_log
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
