CREATE PROGRAM bhs_rpt_icu_antibiotic:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg date time" = "SYSDATE",
  "End date time" = "SYSDATE",
  "Select unit(s):" = 0
  WITH outdev, s_bed_dt_tm, s_end_dt_tm,
  f_nurse_unit
 FREE RECORD m_info
 RECORD m_info(
   1 l_pat_cnt = i4
   1 pat[*]
     2 s_fin_nbr = vc
     2 s_name_full = vc
     2 s_admit_dt_tm = vc
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_icu_beg_dt_tm = vc
     2 s_icu_days = vc
     2 l_ord_cnt = i4
     2 orders[*]
       3 s_order_mnem = vc
       3 s_order_dt_tm = vc
       3 s_admin_dt_tm = vc
       3 f_dt_tm_diff = f8
 ) WITH protect
 FREE RECORD m_order_cd_rec
 RECORD m_order_cd_rec(
   1 n_ord_cd_cnt = i4
   1 orders[*]
     2 s_display_key = vc
     2 f_code_value = f8
 ) WITH protect
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mn_nurse_unit_param = i2 WITH protect, constant(4)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_administered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4000040,
   "ADMINISTERED"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim( $S_BED_DT_TM))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim( $S_END_DT_TM))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_expnd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_nurse_unit = vc WITH protect, noconstant(" ")
 IF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) > 31)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "Your date range is larger than 31 days. Please retry."
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_beg_dt_tm)) < 0)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "The end date is before the begin date. Please retry."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 CALL echo("get BMC facility cd")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key="BMC"
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  DETAIL
   mf_facility_cd = cv.code_value
  WITH nocounter
 ;end select
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
   SET ms_nurse_unit = concat(" elh.loc_nurse_unit_cd = ",trim(ms_nurse_unit))
  ELSE
   SET ms_log = "No nurse unit chosen"
   GO TO exit_script
  ENDIF
 ELSEIF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp = trim(cnvtstring(parameter(mn_nurse_unit_param,ml_cnt)))
   IF (ml_cnt=1)
    SET ms_nurse_unit = concat(" elh.loc_nurse_unit_cd in (",trim(ms_tmp))
   ELSE
    SET ms_nurse_unit = concat(ms_nurse_unit,", ",trim(ms_tmp))
   ENDIF
  ENDFOR
  SET ms_nurse_unit = concat(ms_nurse_unit,")")
 ENDIF
 CALL echo(build2("ms_nurse_unit: ",ms_nurse_unit))
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key IN ("ACYCLOVIR", "AMPICILLIN", "AZITHROMYCIN", "CEFTRIAXONE", "FLUCONAZOLE",
   "METRONIDAZOLE", "PIPERACILLIN", "VANCOMYCIN"))
  HEAD REPORT
   m_order_cd_rec->n_ord_cd_cnt = 0
  DETAIL
   m_order_cd_rec->n_ord_cd_cnt = (m_order_cd_rec->n_ord_cd_cnt+ 1), stat = alterlist(m_order_cd_rec
    ->orders,m_order_cd_rec->n_ord_cd_cnt), m_order_cd_rec->orders[m_order_cd_rec->n_ord_cd_cnt].
   s_display_key = trim(cv.display_key,3),
   m_order_cd_rec->orders[m_order_cd_rec->n_ord_cd_cnt].f_code_value = cv.code_value
  WITH nocounter
 ;end select
 CALL echo("get patient/encntr info")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p,
   orders o,
   med_admin_event mae
  PLAN (ed
   WHERE ed.loc_facility_cd=mf_facility_cd
    AND ed.active_ind=1
    AND ed.active_status_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=ed.encntr_id
    AND elh.active_ind=1
    AND parser(ms_nurse_unit))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND e.encntr_type_class_cd=mf_inpt_cd
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND expand(ml_expnd_cnt,1,size(m_order_cd_rec->orders,5),o.catalog_cd,m_order_cd_rec->orders[
    ml_expnd_cnt].f_code_value))
   JOIN (mae
   WHERE o.order_id=mae.order_id
    AND mae.event_type_cd=mf_administered_cd)
  ORDER BY elh.encntr_id, mae.template_order_id, mae.end_dt_tm
  HEAD REPORT
   m_info->l_pat_cnt = 0
  HEAD elh.encntr_id
   m_info->l_pat_cnt = (m_info->l_pat_cnt+ 1)
   IF ((m_info->l_pat_cnt > size(m_info->pat,5)))
    stat = alterlist(m_info->pat,(m_info->l_pat_cnt+ 10))
   ENDIF
   m_info->pat[m_info->l_pat_cnt].s_fin_nbr = trim(ea.alias), m_info->pat[m_info->l_pat_cnt].
   s_name_full = trim(p.name_full_formatted), m_info->pat[m_info->l_pat_cnt].s_admit_dt_tm = trim(
    format(ed.beg_effective_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_info->pat[m_info->l_pat_cnt].s_nurse_unit = trim(uar_get_code_display(elh.loc_nurse_unit_cd)),
   m_info->pat[m_info->l_pat_cnt].s_room = trim(uar_get_code_display(elh.loc_room_cd)), m_info->pat[
   m_info->l_pat_cnt].s_bed = trim(uar_get_code_display(elh.loc_bed_cd)),
   m_info->pat[m_info->l_pat_cnt].s_icu_beg_dt_tm = trim(format(elh.beg_effective_dt_tm,
     "dd-mmm-yyyy hh:mm;;d")), m_info->pat[m_info->l_pat_cnt].s_icu_days = cnvtstring(round(cnvtreal(
      datetimediff(sysdate,elh.beg_effective_dt_tm)),1),20,1), m_info->pat[m_info->l_pat_cnt].
   l_ord_cnt = 0
  HEAD mae.template_order_id
   m_info->pat[m_info->l_pat_cnt].l_ord_cnt = (m_info->pat[m_info->l_pat_cnt].l_ord_cnt+ 1)
   IF ((m_info->pat[m_info->l_pat_cnt].l_ord_cnt > size(m_info->pat[m_info->l_pat_cnt].orders,5)))
    stat = alterlist(m_info->pat[m_info->l_pat_cnt].orders,(m_info->pat[m_info->l_pat_cnt].l_ord_cnt
     + 10))
   ENDIF
   m_info->pat[m_info->l_pat_cnt].orders[m_info->pat[m_info->l_pat_cnt].l_ord_cnt].s_order_mnem =
   trim(o.ordered_as_mnemonic), m_info->pat[m_info->l_pat_cnt].orders[m_info->pat[m_info->l_pat_cnt].
   l_ord_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_info->pat[
   m_info->l_pat_cnt].orders[m_info->pat[m_info->l_pat_cnt].l_ord_cnt].s_admin_dt_tm = trim(format(
     mae.end_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_info->pat[m_info->l_pat_cnt].orders[m_info->pat[m_info->l_pat_cnt].l_ord_cnt].f_dt_tm_diff =
   datetimediff(mae.end_dt_tm,o.orig_order_dt_tm,4)
  FOOT  mae.template_order_id
   CALL echo(""), stat = alterlist(m_info->pat[m_info->l_pat_cnt].orders,m_info->pat[m_info->
    l_pat_cnt].l_ord_cnt)
  FOOT REPORT
   stat = alterlist(m_info->pat,m_info->l_pat_cnt)
  WITH nocounter, format, separator = " "
 ;end select
 IF (curqual < 1)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "No Patients Qualified for Report"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_output)
  fin_number = trim(m_info->pat[d1.seq].s_fin_nbr), name_full = trim(m_info->pat[d1.seq].s_name_full),
  admit_dt_tm = trim(m_info->pat[d1.seq].s_admit_dt_tm),
  nurse_unit = trim(m_info->pat[d1.seq].s_nurse_unit), room = trim(m_info->pat[d1.seq].s_room), bed
   = trim(m_info->pat[d1.seq].s_bed),
  icu_beg_dt_tm = trim(m_info->pat[d1.seq].s_icu_beg_dt_tm), icu_days = trim(m_info->pat[d1.seq].
   s_icu_days), order_mnem = trim(m_info->pat[d1.seq].orders[d2.seq].s_order_mnem),
  order_dt_tm = trim(m_info->pat[d1.seq].orders[d2.seq].s_order_dt_tm), admin_dt_tm = trim(m_info->
   pat[d1.seq].orders[d2.seq].s_admin_dt_tm), order_amin_diff_minutes = cnvtstring(round(cnvtreal(
     m_info->pat[d1.seq].orders[d2.seq].f_dt_tm_diff),1),20,1)
  FROM (dummyt d1  WITH seq = value(size(m_info->pat,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_info->pat[d1.seq].orders,5)))
   JOIN (d2)
  ORDER BY m_info->pat[d1.seq].orders[d2.seq].f_dt_tm_diff DESC
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
