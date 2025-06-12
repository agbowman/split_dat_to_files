CREATE PROGRAM bhs_rpt_missing_meds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location:" = 673937.00,
  "Nurse Unit:" = "",
  "Dispense Category:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility_cd, f_nurse_unit_cd, f_dispense_cat_cd
 FREE RECORD m_info
 RECORD m_info(
   1 encntrs[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_fin_nbr = vc
     2 s_loc_facility = vc
     2 s_loc_nurse_unit = vc
     2 s_loc_room = vc
     2 s_loc_bed = vc
     2 orders[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_display = vc
       3 s_order_start_dt_tm = vc
       3 s_order_stop_dt_tm = vc
       3 s_disp_cat_cd = vc
 ) WITH protect
 DECLARE mn_nurse_unit_param = i2 WITH protect, constant(5)
 DECLARE mn_disp_cat_param = i2 WITH protect, constant(6)
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ORDERED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_disp_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "DISPENSE CATEGORY"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",321,"INPATIENT"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant( $F_FACILITY_CD)
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_nurse_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_disp_cat = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_log_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(trim(concat(format(cnvtdatetime( $S_BEG_DT),
     "dd-mmm-yyyy;;d")," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim(concat(format(cnvtdatetime( $S_END_DT),
     "dd-mmm-yyyy;;d")," 23:59:59")))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_string = vc WITH protect, noconstant("")
 DECLARE mn_max_print_len = i4 WITH protect, noconstant(120)
 DECLARE mn_space_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_tmp_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_rem_len = i4 WITH protect, noconstant(0)
 SET ms_data_type = reflect(parameter(mn_nurse_unit_param,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_nurse_unit = parameter(mn_nurse_unit_param,1)
  IF ( NOT (trim(ms_nurse_unit) IN (null, "", " ", "0")))
   IF (trim(ms_nurse_unit)=char(42))
    SET ms_nurse_unit = " 1=1"
   ELSE
    SET ms_nurse_unit = concat(" e.loc_nurse_unit_cd = ",trim(ms_nurse_unit))
   ENDIF
  ELSE
   SET ms_log_msg = "no nurse unit"
   GO TO exit_script
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(mn_nurse_unit_param,ml_cnt)
   IF (ml_cnt=1)
    SET ms_nurse_unit = concat(" e.loc_nurse_unit_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_nurse_unit = concat(ms_nurse_unit,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_nurse_unit = concat(ms_nurse_unit,")")
 ENDIF
 CALL echo(concat("ms_nurse_unit: ",ms_nurse_unit))
 SET ms_data_type = reflect(parameter(mn_disp_cat_param,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_disp_cat = parameter(mn_disp_cat_param,1)
  IF ( NOT (trim(ms_disp_cat) IN (null, "", " ", "0")))
   IF (trim(ms_disp_cat)=char(42))
    SET ms_disp_cat = concat(" od.order_id = outerjoin(o.order_id)",
     " and od.oe_field_id = outerjoin(",trim(cnvtstring(mf_disp_cat_cd)),")")
   ELSE
    SET ms_disp_cat = concat(" od.order_id = o.order_id"," and od.oe_field_id = ",trim(cnvtstring(
       mf_disp_cat_cd))," and od.oe_field_value = ",ms_disp_cat)
   ENDIF
  ELSE
   SET ms_log_msg = "no dispense cat"
   GO TO exit_script
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(mn_disp_cat_param,ml_cnt)
   IF (ml_cnt=1)
    SET ms_disp_cat = concat(" od.order_id = o.order_id"," and od.oe_field_id = ",mf_disp_cat_cd,
     " and od.oe_field_value in (",trim(ms_tmp_str))
   ELSE
    SET ms_disp_cat = concat(ms_disp_cat,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_disp_cat = concat(ms_disp_cat,")")
 ENDIF
 CALL echo("selecting encounters")
 SELECT DISTINCT INTO "nl:"
  e.encntr_id, e.loc_nurse_unit_cd, nurse = substring(1,10,uar_get_code_display(e.loc_nurse_unit_cd)),
  e.encntr_class_cd, encntr_class = substring(1,15,uar_get_code_display(e.encntr_class_cd))
  FROM ce_med_result cem,
   clinical_event ce,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (cem
   WHERE cem.event_id > 0
    AND cem.valid_until_dt_tm > cem.admin_start_dt_tm
    AND cem.admin_start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (ce
   WHERE ((cem.event_id+ 0)=ce.event_id)
    AND ((ce.valid_until_dt_tm+ 0) >= sysdate))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.disch_dt_tm=null
    AND e.encntr_class_cd=mf_inpatient_cd
    AND e.active_ind=1
    AND parser(ms_nurse_unit))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->encntrs,5))
    stat = alterlist(m_info->encntrs,(pn_cnt+ 10))
   ENDIF
   m_info->encntrs[pn_cnt].f_encntr_id = e.encntr_id, m_info->encntrs[pn_cnt].f_person_id = p
   .person_id, m_info->encntrs[pn_cnt].s_pat_name = trim(p.name_full_formatted),
   m_info->encntrs[pn_cnt].s_loc_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_info->
   encntrs[pn_cnt].s_loc_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)), m_info->
   encntrs[pn_cnt].s_loc_room = trim(uar_get_code_display(e.loc_room_cd)),
   m_info->encntrs[pn_cnt].s_loc_bed = trim(uar_get_code_display(e.loc_bed_cd)), m_info->encntrs[
   pn_cnt].s_fin_nbr = trim(ea.alias)
  FOOT REPORT
   stat = alterlist(m_info->encntrs,pn_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->encntrs,5) <= 0)
  SET ms_log_msg = "No data found"
  GO TO exit_script
 ENDIF
 CALL echo("Selecting orders...")
 SELECT INTO "nl:"
  pf_encntr_id = m_info->encntrs[d.seq].f_encntr_id
  FROM (dummyt d  WITH seq = value(size(m_info->encntrs,5))),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_info->encntrs[d.seq].f_encntr_id)
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.active_status_cd=mf_active_cd
    AND o.template_order_id=0
    AND o.projected_stop_dt_tm >= cnvtdatetime(ms_end_dt_tm))
   JOIN (od
   WHERE parser(ms_disp_cat))
  ORDER BY pf_encntr_id
  HEAD pf_encntr_id
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->encntrs[d.seq].orders,5))
    stat = alterlist(m_info->encntrs[d.seq].orders,(pn_cnt+ 10))
   ENDIF
   m_info->encntrs[d.seq].orders[pn_cnt].f_order_id = o.order_id, m_info->encntrs[d.seq].orders[
   pn_cnt].s_order_mnemonic = trim(o.ordered_as_mnemonic), m_info->encntrs[d.seq].orders[pn_cnt].
   s_order_display = trim(o.order_detail_display_line),
   m_info->encntrs[d.seq].orders[pn_cnt].s_order_start_dt_tm = trim(format(o.current_start_dt_tm,
     "dd-mmm-yyyy hh:mm;;d")), m_info->encntrs[d.seq].orders[pn_cnt].s_order_stop_dt_tm = trim(format
    (o.projected_stop_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_info->encntrs[d.seq].orders[pn_cnt].
   s_disp_cat_cd = trim(uar_get_code_display(od.oe_field_value))
  FOOT  pf_encntr_id
   stat = alterlist(m_info->encntrs[d.seq].orders,pn_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log_msg = "No Orders Found"
  GO TO exit_script
 ENDIF
 CALL echo("Writing report...")
 SELECT INTO value(ms_output)
  ps_nurse_unit = m_info->encntrs[d1.seq].s_loc_nurse_unit, ps_name_full_formatted = m_info->encntrs[
  d1.seq].s_pat_name, pf_person_id = m_info->encntrs[d1.seq].f_person_id
  FROM (dummyt d1  WITH seq = value(size(m_info->encntrs,5))),
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(m_info->encntrs[d1.seq].orders,5)))
   JOIN (d2)
  ORDER BY ps_nurse_unit, ps_name_full_formatted
  HEAD REPORT
   MACRO (print_text)
    mn_max_print_len = pn_max_len, mn_space_pos = 0, mn_tmp_pos = 0,
    mn_end_pos = 0, mn_beg_pos = 1, mn_rem_len = 0
    IF (textlen(ms_string) < mn_max_print_len
     AND textlen(trim(ms_string)) > 0)
     col pn_col, ms_string
    ELSEIF (textlen(ms_string) > 0)
     mn_rem_len = textlen(ms_string)
     WHILE (mn_rem_len >= mn_max_print_len)
       mn_tmp_pos = mn_beg_pos, mn_space_pos = 0
       WHILE (mn_space_pos < mn_max_print_len)
        mn_space_pos = findstring(" ",ms_string,mn_tmp_pos),
        IF (mn_space_pos > 0
         AND mn_space_pos <= mn_max_print_len)
         mn_tmp_pos = (mn_space_pos+ 1)
        ELSEIF (((mn_space_pos=0) OR (mn_space_pos > mn_max_print_len)) )
         IF (mn_tmp_pos=mn_beg_pos)
          mn_tmp_pos = mn_max_print_len
         ENDIF
         mn_space_pos = (mn_max_print_len+ 1)
        ENDIF
       ENDWHILE
       mn_space_pos = mn_tmp_pos
       IF (textlen(trim(ms_tmp_str)) > 0)
        row + 1
       ENDIF
       ms_tmp_str = trim(substring(mn_beg_pos,(mn_space_pos - mn_beg_pos),ms_string)), col pn_col,
       ms_tmp_str,
       mn_beg_pos = mn_space_pos, ms_string = substring(mn_beg_pos,((textlen(ms_string) - mn_beg_pos)
        + 1),ms_string), mn_beg_pos = 1,
       mn_rem_len = (textlen(ms_string) - mn_beg_pos)
       IF (mn_rem_len <= mn_max_print_len)
        ms_tmp_str = ms_string, row + 1, col pn_col,
        ms_tmp_str
       ENDIF
     ENDWHILE
    ENDIF
    ms_tmp_str = ""
   ENDMACRO
   , pn_tmp_ind = 0, pn_col = 0,
   pn_max_len = 0, ps_line1 = fillstring(98,"="), ps_line2 = fillstring(98,"-"),
   "{lpi/6}{CPI/12}",
   CALL center("Baystate Pharmacy Missing Medications Report",0,128), col 0,
   row + 1, ps_line1
  HEAD PAGE
   row + 1, col 0, "Location: ",
   "{B}", m_info->encntrs[d1.seq].s_loc_nurse_unit, "{ENDB}",
   col 95, "Page:", curpage"###;1",
   row + 1, col 0, ps_line1,
   row + 1
  DETAIL
   row + 1, col 0, "{B}",
   m_info->encntrs[d1.seq].s_pat_name, "{ENDB}", col 50,
   "{B}", m_info->encntrs[d1.seq].s_fin_nbr, "{ENDB}",
   ms_tmp = concat(m_info->encntrs[d1.seq].s_loc_facility," ",m_info->encntrs[d1.seq].s_loc_room,"-",
    m_info->encntrs[d1.seq].s_loc_bed), row + 1, col 0,
   ms_tmp, row + 1, col 0,
   ps_line2, row + 1, col 0,
   "*Active Orders*", row + 1, col 0,
   m_info->encntrs[d1.seq].orders[d2.seq].s_order_mnemonic, row + 1, ms_string = m_info->encntrs[d1
   .seq].orders[d2.seq].s_order_display,
   pn_col = 5, pn_max_len = 90, print_text,
   ms_tmp = concat("Start: ",m_info->encntrs[d1.seq].orders[d2.seq].s_order_start_dt_tm,"     End: ",
    m_info->encntrs[d1.seq].orders[d2.seq].s_order_stop_dt_tm), row + 1, col 0,
   "     ", ms_tmp, row + 1,
   col 0, ps_line1
  FOOT REPORT
   ms_tmp = trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")), row + 1, col 0,
   "***END*** Report Date: ", ms_tmp, col 85,
   "Page: ", curpage"###;1"
  WITH nocounter, maxcol = 300, dio = postscript
 ;end select
#exit_script
 IF (size(m_info->encntrs,5) <= 0)
  CALL echo(ms_log_msg)
  SELECT INTO value(ms_output)
   DETAIL
    ms_log_msg, ms_tmp = build2("facility_cd: ",mf_facility_cd), row + 1,
    ms_tmp, ms_tmp = build2("inpatient_cd: ",mf_inpatient_cd), row + 1,
    ms_tmp, row + 1, "ms_nurse_unit: ",
    ms_nurse_unit, row + 1, "ms_disp_cat: ",
    ms_disp_cat, row + 1, "beg_dt_tm: ",
    ms_beg_dt_tm, row + 1, "end_dt_tm: ",
    ms_end_dt_tm
   WITH nocounter, maxcol = 500
  ;end select
 ENDIF
 FREE RECORD m_info
END GO
