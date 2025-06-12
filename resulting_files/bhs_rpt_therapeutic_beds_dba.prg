CREATE PROGRAM bhs_rpt_therapeutic_beds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0
  WITH outdev, f_facility_code, f_nurse_unit_cd
 FREE RECORD m_order_cd_rec
 RECORD m_order_cd_rec(
   1 n_ord_cd_cnt = i4
   1 orders[*]
     2 s_display = vc
     2 f_code_value = f8
 )
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_act_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_facility_cd = f8 WITH protect, constant( $F_FACILITY_CODE)
 DECLARE ms_rpt_name = vc WITH protect, constant("Therapeutic Beds (Active Orders)")
 DECLARE ms_prg_name = vc WITH protect, constant(cnvtlower(curprog))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_spaces = vc WITH protect, noconstant(" ")
 DECLARE ms_any_loc_ind = vc WITH protect, noconstant(" ")
 DECLARE ml_expnd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_loc_where = vc WITH protect, noconstant(" ")
 DECLARE ml_nurs_unit_therap_beds_ctr = i4 WITH protect, noconstant(0)
 DECLARE ml_fac_therap_beds_ctr = i4 WITH protect, noconstant(0)
 DECLARE ml_org_therap_beds_ctr = i4 WITH protect, noconstant(0)
 DECLARE ms_date_stamp = vc WITH protect, noconstant(format(curdate,"mm/dd/yyyy;;d"))
 DECLARE ms_time_stamp = vc WITH protect, noconstant(format(curtime,"hh:mm;;m"))
 DECLARE ms_line = vc WITH protect, noconstant(fillstring(85,"_"))
 DECLARE ml_beg_line = i4 WITH protect, noconstant(0)
 DECLARE ml_bw = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_eol = i4 WITH protect, noconstant(0)
 DECLARE ml_len = i4 WITH protect, noconstant(0)
 DECLARE ml_t_len = i4 WITH protect, noconstant(0)
 DECLARE ml_ew = i4 WITH protect, noconstant(0)
 DECLARE ml_line_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_row_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_x_col = i4 WITH protect, noconstant(0)
 DECLARE ml_y_col = i4 WITH protect, noconstant(0)
 DECLARE ml_y_jump = i4 WITH protect, noconstant(0)
 DECLARE ml_lf_xcol = i4 WITH protect, noconstant(0)
 DECLARE ml_ct_xcol = i4 WITH protect, noconstant(0)
 DECLARE ml_rt_xcol = i4 WITH protect, noconstant(0)
 DECLARE ml_new_rm_bd_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_last_fac = vc WITH protect, noconstant(" ")
 DECLARE ms_last_nur_u = vc WITH protect, noconstant(" ")
 DECLARE ms_nu_line = vc WITH protect, noconstant(" ")
 DECLARE ms_fac_line = vc WITH protect, noconstant(" ")
 DECLARE ms_org_line = vc WITH protect, noconstant(" ")
 DECLARE ms_p_temp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key="*THERAPEUTICBED*")
  HEAD REPORT
   m_order_cd_rec->n_ord_cd_cnt = 0
  DETAIL
   m_order_cd_rec->n_ord_cd_cnt += 1, stat = alterlist(m_order_cd_rec->orders,m_order_cd_rec->
    n_ord_cd_cnt), m_order_cd_rec->orders[m_order_cd_rec->n_ord_cd_cnt].s_display = trim(cv.display,3
    ),
   m_order_cd_rec->orders[m_order_cd_rec->n_ord_cd_cnt].f_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET ms_spaces = fillstring(90," ")
 SET ms_tmp = fillstring(90," ")
 SET ms_any_loc_ind = substring(1,1,reflect(parameter(3,0)))
 CALL echo(build("ms_any_loc_ind:",ms_any_loc_ind))
 IF (ms_any_loc_ind="C")
  SET ms_loc_where = build2(" ed.loc_facility_cd = ",mf_facility_cd)
 ELSEIF (( $F_NURSE_UNIT_CD > 0))
  SET ms_loc_where = build2(" ed.loc_nurse_unit_cd = ", $F_NURSE_UNIT_CD)
 ELSE
  SET ms_loc_where = build2(" ed.loc_facility_cd = ",mf_facility_cd)
 ENDIF
 CALL echo(build("Parser: ",ms_loc_where))
 SELECT INTO  $OUTDEV
  o.order_id, o.activity_type_cd, o_act_type_disp = uar_get_code_description(o.activity_type_cd),
  o.ordered_as_mnemonic, o.clinical_display_line, o.orig_order_dt_tm"dd-mmm-yyyy hh:mm:ss;;q",
  oa.action_dt_tm"dd-mmm-yyyy hh:mm:ss;;q", oa.action_type_cd, oa_action_type_cd =
  uar_get_code_display(oa.action_type_cd),
  cat_disp = uar_get_code_display(o.catalog_cd), p.name_full_formatted, p.person_id,
  e.loc_facility_cd, e_loc_facility_cd = uar_get_code_description(e.loc_facility_cd), e
  .loc_nurse_unit_cd,
  e_loc_nurse_unit_cd = uar_get_code_display(e.loc_nurse_unit_cd), e.loc_room_cd, e_loc_room_cd =
  uar_get_code_display(e.loc_room_cd),
  e.loc_bed_cd, e_loc_bed_cd = uar_get_code_display(e.loc_bed_cd), rm_bd = concat(trim(
    uar_get_code_display(e.loc_room_cd)),"/",trim(uar_get_code_display(e.loc_bed_cd))),
  fin = substring(1,10,ea.alias), mrn = substring(1,10,ea1.alias)
  FROM orders o,
   order_action oa,
   person p,
   encounter e,
   encntr_domain ed,
   encntr_alias ea,
   encntr_alias ea1
  PLAN (ed
   WHERE parser(ms_loc_where)
    AND ed.end_effective_dt_tm > sysdate
    AND ed.loc_nurse_unit_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null
    AND e.encntr_type_cd IN (mf_daystay_cd, mf_inpatient_cd, mf_observation_cd, mf_emergency_cd))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.activity_type_cd=mf_act_type_cd
    AND o.order_status_cd IN (mf_ordered_cd)
    AND o.template_order_flag != 2
    AND expand(ml_expnd_cnt,1,size(m_order_cd_rec->orders,5),o.catalog_cd,m_order_cd_rec->orders[
    ml_expnd_cnt].f_code_value))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate))
  ORDER BY e.loc_facility_cd, e.loc_nurse_unit_cd, rm_bd,
   p.person_id, o.order_id
  HEAD REPORT
   MACRO (macro_init_wrap)
    ml_beg_line = 1, ml_bw = 0, ml_pos = 1,
    ml_eol = 0, ml_len = 0, ml_t_len = 1,
    ml_ew = 0, ml_line_cnt = 0
   ENDMACRO
   ,
   MACRO (macro_init_row)
    ml_row_cnt = 16
   ENDMACRO
   ,
   MACRO (macro_ln_feed)
    font0, row + 1, ml_row_cnt += 1,
    row ml_row_cnt
   ENDMACRO
   ,
   ml_row_cnt = 0, ml_x_col = 20, ml_y_col = 45,
   ml_y_jump = 12, ml_new_rm_bd_ind = 0, ms_last_fac = e_loc_facility_cd,
   ms_last_nur_u = e_loc_nurse_unit_cd, font0 = "{f/0}{cpi/12}{lpi/6}", font1 = "{f/8}{cpi/8}",
   font2 = "{f/8}{cpi/15}{lpi/8}", font3 = "{f/8}{cpi/10}{lpi/8}"
  HEAD PAGE
   "{cpi/8}{pos/36/30}{color/20/140}", row + 1, "{cpi/8}{pos/36/37}{color/20/140}",
   row + 1, "{cpi/8}{pos/36/44}{color/20/140}", row + 1,
   "{cpi/8}{pos/36/51}{color/20/140}", row + 1, "{cpi/8}{pos/36/58}{color/20/140}",
   row + 1, "{cpi/8}{pos/36/65}{color/20/140}", row + 1,
   font1, row + 1, col 01,
   CALL print(calcpos(197,20)), "{b/23}BAYSTATE HEALTH SYSTEMS", font3,
   row + 1, col 01,
   CALL print(calcpos(220,49)),
   "{b}", ms_rpt_name, "{endb}",
   row + 1, ml_lf_xcol = 40, ml_y_col = 80,
   ml_y_jump = 10, ml_ct_xcol = 190, ml_rt_xcol = 420,
   font2, row + 1,
   CALL print(calcpos(ml_lf_xcol,ml_y_col)),
   "{b/9}Run Date: ", ms_date_stamp, row + 1,
   CALL print(calcpos(ml_rt_xcol,ml_y_col)), "{b/9}Prg Name: ", ms_prg_name,
   row + 1, ml_y_col += ml_y_jump,
   CALL print(calcpos(ml_lf_xcol,ml_y_col)),
   "{b/9}Run Time: ", ms_time_stamp, row + 1,
   CALL print(calcpos(ml_ct_xcol,ml_y_col)), row + 1,
   CALL print(calcpos(ml_rt_xcol,ml_y_col)),
   "{b/5}Page: ", curpage"###", row + 1,
   ml_row_cnt = 16
  HEAD e.loc_facility_cd
   macro_ln_feed, ml_fac_therap_beds_ctr = 0
   IF (e_loc_facility_cd=ms_last_fac)
    macro_ln_feed, col 005, ms_line,
    macro_ln_feed, macro_ln_feed, col 005,
    "{b/9}Facility: ", col 023, ms_last_fac
   ELSE
    ms_last_fac = e_loc_facility_cd
   ENDIF
  HEAD e.loc_nurse_unit_cd
   ml_nurs_unit_therap_beds_ctr = 0
   IF (e_loc_nurse_unit_cd=ms_last_nur_u)
    macro_ln_feed, col 005, "{b/11}Nurse Unit: ",
    col 024, ms_last_nur_u
   ELSE
    macro_init_row, BREAK, macro_ln_feed,
    col 005, ms_line, macro_ln_feed,
    macro_ln_feed, col 005, "{b/9}Facility: ",
    col 023, ms_last_fac, macro_ln_feed,
    col 005, "{b/11}Nurse Unit: ", col 024,
    e_loc_nurse_unit_cd, ms_last_nur_u = e_loc_nurse_unit_cd
   ENDIF
  HEAD rm_bd
   IF (ml_row_cnt >= 50)
    rm_prtd = 1, ml_new_rm_bd_ind = 1, macro_init_row,
    BREAK
   ENDIF
   IF (ml_new_rm_bd_ind)
    macro_ln_feed, col 005, ms_line,
    macro_ln_feed, macro_ln_feed, col 005,
    "{b/9}Facility: ", col 023, ms_last_fac
   ENDIF
   IF (ml_new_rm_bd_ind)
    macro_ln_feed, col 005, "{b/11}Nurse Unit: ",
    col 024, ms_last_nur_u
   ENDIF
  DETAIL
   macro_ln_feed, macro_ln_feed, pt_name = substring(1,40,p.name_full_formatted),
   col 005, "{b/8}Patient: ", col 023,
   pt_name, col 060, "{b/4}MRN: ",
   mrn, col 080, "{b/4}FIN: ",
   fin, rm_prtd = 1, macro_ln_feed,
   col 005, "{b/9}Room/Bed: ", col 023,
   rm_bd, ml_nurs_unit_therap_beds_ctr += 1, ml_fac_therap_beds_ctr += 1,
   ml_org_therap_beds_ctr += 1, macro_ln_feed, macro_ln_feed,
   mnem = substring(1,200,trim(o.ordered_as_mnemonic,3)), col 005, "{b}Ordered:{endb} ",
   mnem, macro_ln_feed, col 005,
   "{b/18}Date/Time Ordered: ", o.orig_order_dt_tm"mm/dd/yy hh:mm;;q", macro_ln_feed,
   macro_init_wrap
   WHILE ((ml_pos < (size(trim(o.clinical_display_line))+ 1))
    AND substring((ml_pos+ 1),(size(trim(o.clinical_display_line)) - ml_pos),o.clinical_display_line)
    > ms_spaces)
     ml_bw = ml_pos, ml_ew = findstring(" ",trim(o.clinical_display_line),(ml_bw+ 1))
     IF (ml_ew=0)
      ml_ew = (size(trim(o.clinical_display_line))+ 1)
     ENDIF
     ml_len = (ml_ew - ml_bw), ml_t_len = size(trim(ms_tmp))
     IF (((ml_t_len+ ml_len) > 82))
      macro_ln_feed, ms_p_temp = trim(ms_tmp,3), col 005,
      ms_p_temp, ms_tmp = ms_spaces, ml_beg_line = 1,
      ml_t_len = 0
     ENDIF
     ml_pos += ml_len
     IF (ml_row_cnt >= 55)
      macro_init_row, BREAK
     ENDIF
   ENDWHILE
   IF (((ml_t_len > 0) OR (size(trim(ms_tmp)) > 0)) )
    macro_ln_feed, ms_p_temp = trim(ms_tmp,3), col 005,
    ms_p_temp, ms_tmp = ms_spaces, ml_beg_line = 1,
    ml_t_len = 0
   ENDIF
   macro_ln_feed, col 005, ms_line,
   macro_ln_feed
  FOOT  e.loc_nurse_unit_cd
   ml_row_cnt = 64, row ml_row_cnt, ms_nu_line = concat("{b}","****  End of Nurse Unit - ",trim(
     ms_last_nur_u,3),"  ****","{endb}"),
   col 10, ms_nu_line, macro_ln_feed,
   col 16, "Total Therapeutic Beds For This Unit = ", ml_nurs_unit_therap_beds_ctr"##"
  FOOT  e.loc_facility_cd
   macro_ln_feed, row ml_row_cnt, ms_fac_line = concat("{b}","****  End of Facility - ",trim(
     ms_last_fac,3),"  ****","{endb}"),
   col 10, ms_fac_line, macro_ln_feed,
   row ml_row_cnt, col 16, "Total Therapeutic Beds For This Facility = ",
   ml_fac_therap_beds_ctr"##"
  FOOT REPORT
   macro_ln_feed, ms_org_line = concat("{b}","****  END OF REPORT  ****","{endb}"), col 10,
   ms_org_line, macro_ln_feed, col 16,
   "Grand Total For Baystate Health System = ", ml_org_therap_beds_ctr"###"
  WITH nocounter, dio = postscript, maxrow = 70,
   maxcol = 500, nullreport
 ;end select
END GO
