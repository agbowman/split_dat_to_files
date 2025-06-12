CREATE PROGRAM bhs_rpt_careset_obv_pats:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Organization" = 0,
  "Select Nursing Unit /s" = 0,
  "Enter Order Start Date" = "SYSDATE",
  "Enter Order End Date" = "SYSDATE",
  "Report Output Type:" = 2
  WITH outdev, f_org, f_nur,
  s_st_dt_tm, s_en_dt_tm, f_otype
 DECLARE ms_order_concat = vc WITH protect, noconstant(" ")
 DECLARE ms_daterange = vc WITH protect, noconstant(" ")
 DECLARE ms_facility_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_print_by = vc WITH protect, noconstant(" ")
 DECLARE ml_printpsheader = i4 WITH protect, noconstant(0)
 DECLARE ml_y_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_x_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_mlen = i4 WITH protect, noconstant(0)
 DECLARE ml_linelen = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_onum = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_footer_line = vc WITH protect, constant(fillstring(130,"_"))
 DECLARE ms_curdatetime = vc WITH protect, constant(concat(format(cnvtdatetime(curdate,curtime3),
    "dd-mmm-yyyy hh:mm:ss;;d")))
 DECLARE ms_curdate = vc WITH protect, constant(concat(format(curdate,"mm/dd/yyyy;;d")," ",format(
    curtime,"hh:mm;;m")))
 DECLARE ms_head_line = vc WITH protect, constant(fillstring(152,"_"))
 DECLARE ms_footer_linedesc1 = vc WITH protect, constant(concat(
   "This document is the property of Baystate Health Systems.  ",
   "the person who printed this document is responsible for the appropriate use and disposal "))
 DECLARE ms_footer_linedesc2 = vc WITH protect, constant(concat(
   "in compliance with corporate policies and state and federal regulations.  ",
   "if you received this in error, please contact the BHS privacy office."))
 DECLARE mf_census_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",339,"CENSUS"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
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
 DECLARE mf_buildings_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"BUILDINGS"))
 DECLARE mf_facilitys_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"FACILITYS"))
 DECLARE mf_nurseunits_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",222,"NURSEUNITS"))
 DECLARE sbr_calclinelen(ms_txt=vc,ml_maxlength=i4) = f8 WITH protect
 DECLARE sbr_parse_text(ms_txt=vc,ml_maxlength=i4) = f8 WITH protect
 IF (validate(reqinfo->updt_id,999) != 999)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   DETAIL
    ms_print_by = trim(p.username,3)
   WITH nocounter
  ;end select
 ENDIF
 IF (ms_print_by=" ")
  SET ms_print_by = "adhoc"
 ENDIF
 FREE RECORD m_pt
 RECORD m_pt(
   1 l_line_cnt = i4
   1 lns[*]
     2 s_line = vc
 ) WITH protect
 FREE RECORD m_patient
 RECORD m_patient(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_unitroombed = vc
     2 s_patient_name = vc
     2 s_diagnosis = vc
     2 s_reg_dt_tm = vc
     2 s_ordercategory = vc
     2 s_order_name_concat = vc
     2 l_ordcnt = i4
     2 oqual[*]
       3 s_order_name = vc
       3 f_order_id = f8
 ) WITH protect
 FREE RECORD m_unit
 RECORD m_unit(
   1 l_cnt = i4
   1 qual[*]
     2 f_codevalue = f8
     2 f_facility_cd = f8
     2 f_building_cd = f8
 ) WITH protect
 FREE RECORD m_orderlist
 RECORD m_orderlist(
   1 l_ordcnt = i4
   1 qual[*]
     2 s_catalog_desc = vc
     2 f_catalog_cd = f8
     2 f_activity_type_cd = f8
     2 f_catalog_type_cd = f8
     2 s_ordercategory = vc
 ) WITH protect
 FREE RECORD m_output
 RECORD m_output(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 s_mrn = vc
     2 l_ordcnt = i4
     2 s_fin = vc
     2 s_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_patient_name = vc
     2 s_reg_dt_tm = vc
     2 s_diagnosis = vc
     2 s_order_name = vc
     2 s_order_name_concat = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM location l1,
   location_group lg1,
   location l2,
   location_group lg2,
   location l3
  PLAN (l1
   WHERE l1.location_type_cd=mf_facilitys_cd
    AND l1.active_ind=1
    AND (l1.location_cd= $F_ORG))
   JOIN (lg1
   WHERE l1.location_cd=lg1.parent_loc_cd
    AND lg1.active_ind=1
    AND lg1.root_loc_cd=0)
   JOIN (l2
   WHERE lg1.child_loc_cd=l2.location_cd
    AND l2.location_type_cd=mf_buildings_cd
    AND l2.active_ind=1)
   JOIN (lg2
   WHERE l2.location_cd=lg2.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.root_loc_cd=0)
   JOIN (l3
   WHERE lg2.child_loc_cd=l3.location_cd
    AND l3.active_ind=1
    AND (l3.location_cd= $F_NUR)
    AND l3.location_type_cd=mf_nurseunits_cd)
  HEAD REPORT
   m_unit->l_cnt = 0
  DETAIL
   m_unit->l_cnt = (m_unit->l_cnt+ 1)
   IF ((size(m_unit->qual,5) < m_unit->l_cnt))
    stat = alterlist(m_unit->qual,(m_unit->l_cnt+ 9))
   ENDIF
   m_unit->qual[m_unit->l_cnt].f_facility_cd = l1.location_cd, m_unit->qual[m_unit->l_cnt].
   f_building_cd = l2.location_cd, m_unit->qual[m_unit->l_cnt].f_codevalue = l3.location_cd,
   ms_facility_disp = uar_get_code_description(m_unit->qual[m_unit->l_cnt].f_facility_cd)
  FOOT REPORT
   stat = alterlist(m_unit->qual,m_unit->l_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ed.encntr_id
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ed
   WHERE expand(ml_num,1,size(m_unit->qual,5),ed.loc_nurse_unit_cd,m_unit->qual[ml_num].f_codevalue)
    AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ed.encntr_domain_type_cd=mf_census_type_cd
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=mf_observation_cd
    AND e.active_ind=1
    AND e.disch_dt_tm = null
    AND e.reg_dt_tm IS NOT null)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm > outerjoin(sysdate)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  ORDER BY e.encntr_id, cnvtdatetime(e.reg_dt_tm) DESC
  HEAD REPORT
   m_patient->l_cnt = 0
  HEAD e.encntr_id
   m_patient->l_cnt = (m_patient->l_cnt+ 1), stat = alterlist(m_patient->qual,m_patient->l_cnt),
   m_patient->qual[m_patient->l_cnt].s_fin = ea1.alias,
   m_patient->qual[m_patient->l_cnt].s_mrn = ea2.alias, m_patient->qual[m_patient->l_cnt].s_reg_dt_tm
    = trim(format(e.reg_dt_tm,"mm/dd/yy ;;q"),3), m_patient->qual[m_patient->l_cnt].f_person_id = p
   .person_id,
   m_patient->qual[m_patient->l_cnt].f_encntr_id = e.encntr_id, m_patient->qual[m_patient->l_cnt].
   s_patient_name = trim(p.name_full_formatted,3), m_patient->qual[m_patient->l_cnt].s_room =
   uar_get_code_display(e.loc_room_cd),
   m_patient->qual[m_patient->l_cnt].s_bed = uar_get_code_display(e.loc_bed_cd), m_patient->qual[
   m_patient->l_cnt].s_unit = uar_get_code_display(e.loc_nurse_unit_cd), m_patient->qual[m_patient->
   l_cnt].s_ordercategory = "careset"
   IF (textlen(trim(m_patient->qual[m_patient->l_cnt].s_bed)) > 0)
    m_patient->qual[m_patient->l_cnt].s_unitroombed = concat(trim(m_patient->qual[m_patient->l_cnt].
      s_unit,3),"/",trim(m_patient->qual[m_patient->l_cnt].s_room,3),"/",trim(m_patient->qual[
      m_patient->l_cnt].s_bed,3))
   ELSEIF (textlen(trim(m_patient->qual[m_patient->l_cnt].s_room)) > 0)
    m_patient->qual[m_patient->l_cnt].s_unitroombed = concat(trim(m_patient->qual[m_patient->l_cnt].
      s_unit,3),"/",trim(m_patient->qual[m_patient->l_cnt].s_room,3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_num,1,size(m_patient->qual,5),d.encntr_id,m_patient->qual[ml_num].f_encntr_id)
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
  ORDER BY d.encntr_id, d.diag_dt_tm DESC, d.nomenclature_id
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  DETAIL
   ml_idx = 0, ml_pos = locateval(ml_idx,1,size(m_patient->qual,5),d.encntr_id,m_patient->qual[ml_idx
    ].f_encntr_id)
   IF (ml_pos > 0)
    IF (n.nomenclature_id > 0)
     m_patient->qual[ml_pos].s_diagnosis = trim(n.source_string,3)
    ELSE
     m_patient->qual[ml_pos].s_diagnosis = trim(d.diag_ftdesc,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
  HEAD REPORT
   m_orderlist->l_ordcnt = 0
  DETAIL
   m_orderlist->l_ordcnt = (m_orderlist->l_ordcnt+ 1)
   IF ((size(m_orderlist->qual,5) < m_orderlist->l_ordcnt))
    stat = alterlist(m_orderlist->qual,(m_orderlist->l_ordcnt+ 9))
   ENDIF
   m_orderlist->qual[m_orderlist->l_ordcnt].s_catalog_desc = trim(uar_get_code_display(oc.catalog_cd),
    3), m_orderlist->qual[m_orderlist->l_ordcnt].f_catalog_cd = oc.catalog_cd, m_orderlist->qual[
   m_orderlist->l_ordcnt].s_ordercategory = "careset",
   m_orderlist->qual[m_orderlist->l_ordcnt].f_catalog_type_cd = oc.catalog_type_cd, m_orderlist->
   qual[m_orderlist->l_ordcnt].f_activity_type_cd = oc.activity_type_cd
  FOOT REPORT
   stat = alterlist(m_orderlist->qual,m_orderlist->l_ordcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_num,1,size(m_patient->qual,5),o.encntr_id,m_patient->qual[ml_num].f_encntr_id,
    o.person_id,m_patient->qual[ml_num].f_person_id)
    AND expand(ml_onum,1,size(m_orderlist->qual,5),o.catalog_cd,m_orderlist->qual[ml_onum].
    f_catalog_cd)
    AND o.order_status_cd IN (mf_completed_cd, mf_inprocess_cd, mf_ordered_cd, mf_pendingcomplete_cd,
   mf_onholdmedstudent_cd,
   mf_pendingreview_cd, mf_hold_cd, mf_future_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime( $S_ST_DT_TM) AND cnvtdatetime( $S_EN_DT_TM))
  ORDER BY o.encntr_id
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  HEAD o.encntr_id
   ms_order_concat = ""
  DETAIL
   ml_idx = 0, ml_pos = locateval(ml_idx,1,size(m_patient->qual,5),o.encntr_id,m_patient->qual[ml_idx
    ].f_encntr_id)
   IF (ml_pos > 0)
    m_patient->qual[ml_pos].l_ordcnt = (m_patient->qual[ml_pos].l_ordcnt+ 1), stat = alterlist(
     m_patient->qual[ml_pos].oqual,m_patient->qual[ml_pos].l_ordcnt), m_patient->qual[ml_pos].oqual[
    m_patient->qual[ml_pos].l_ordcnt].s_order_name = uar_get_code_display(o.catalog_cd),
    m_patient->qual[ml_pos].oqual[m_patient->qual[ml_pos].l_ordcnt].f_order_id = o.order_id
    IF (size(trim(ms_order_concat),1)=0)
     ms_order_concat = trim(uar_get_code_display(o.catalog_cd),3)
    ELSE
     ms_order_concat = concat(ms_order_concat,", ",trim(uar_get_code_display(o.catalog_cd),3))
    ENDIF
    m_output->l_cnt = (m_output->l_cnt+ 1), stat = alterlist(m_output->qual,m_output->l_cnt),
    m_output->qual[m_output->l_cnt].f_encntr_id = m_patient->qual[ml_pos].f_encntr_id,
    m_output->qual[m_output->l_cnt].f_order_id = m_patient->qual[ml_pos].oqual[m_patient->qual[ml_pos
    ].l_ordcnt].f_order_id, m_output->qual[m_output->l_cnt].f_person_id = m_patient->qual[ml_pos].
    f_person_id, m_output->qual[m_output->l_cnt].s_order_name = m_patient->qual[ml_pos].oqual[
    m_patient->qual[ml_pos].l_ordcnt].s_order_name,
    m_output->qual[m_output->l_cnt].s_patient_name = m_patient->qual[ml_pos].s_patient_name, m_output
    ->qual[m_output->l_cnt].s_fin = m_patient->qual[ml_pos].s_fin, m_output->qual[m_output->l_cnt].
    s_diagnosis = m_patient->qual[ml_pos].s_diagnosis,
    m_output->qual[m_output->l_cnt].s_mrn = m_patient->qual[ml_pos].s_mrn, m_output->qual[m_output->
    l_cnt].s_unit = m_patient->qual[ml_pos].s_unit, m_output->qual[m_output->l_cnt].s_room =
    m_patient->qual[ml_pos].s_room,
    m_output->qual[m_output->l_cnt].s_bed = m_patient->qual[ml_pos].s_bed, m_output->qual[m_output->
    l_cnt].s_reg_dt_tm = m_patient->qual[ml_pos].s_reg_dt_tm, m_output->qual[m_output->l_cnt].
    l_ordcnt = m_patient->qual[ml_pos].l_ordcnt
   ENDIF
  FOOT  o.encntr_id
   m_patient->qual[ml_pos].s_order_name_concat = ms_order_concat
  WITH expand = 1
 ;end select
 IF ((m_output->l_cnt=0))
  GO TO exit_script
 ENDIF
 IF (( $F_OTYPE=1))
  SELECT INTO value( $OUTDEV)
   department = substring(1,10,m_output->qual[d.seq].s_unit), room = substring(1,10,m_output->qual[d
    .seq].s_room), bed = substring(1,10,m_output->qual[d.seq].s_bed),
   patient_name = substring(1,100,m_output->qual[d.seq].s_patient_name), fin = substring(1,20,
    m_output->qual[d.seq].s_fin), mrn = substring(1,20,m_output->qual[d.seq].s_mrn),
   admit_date = substring(1,35,m_output->qual[d.seq].s_reg_dt_tm), diagnosis = substring(1,255,
    m_output->qual[d.seq].s_diagnosis), careset = substring(1,255,m_output->qual[d.seq].s_order_name)
   FROM (dummyt d  WITH seq = value(size(m_output->qual,5)))
   PLAN (d
    WHERE (m_output->qual[d.seq].f_encntr_id > 0)
     AND (m_output->qual[d.seq].l_ordcnt > 0))
   ORDER BY department, room, bed
   WITH separator = " ", format
  ;end select
 ELSEIF (( $F_OTYPE=2))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = value(size(m_patient->qual,5)))
   PLAN (d
    WHERE (m_patient->qual[d.seq].f_encntr_id > 0)
     AND (m_patient->qual[d.seq].l_ordcnt > 0))
   ORDER BY m_patient->qual[d.seq].s_patient_name
   HEAD REPORT
    ml_y_pos = 0, ml_x_pos = 0, ml_printpsheader = 0,
    col 0, "{ps/792 0 translate 90 rotate/}", row + 1
   HEAD PAGE
    ml_y_pos = 0
    IF (ml_printpsheader)
     col 0, "{ps/792 0 translate 90 rotate/}", row + 1
    ENDIF
    ml_printpsheader = 1
    IF (curpage > 1)
     ml_y_pos = 10
    ENDIF
    "{f/9}{cpi/10}",
    CALL print(calcpos(330,ml_y_pos)), "Baystate Health System",
    row + 1, "{f/9}{cpi/14}",
    CALL print(calcpos(620,ml_y_pos)),
    "Page:", curpage, row + 1,
    "{f/9}{cpi/10}", ml_y_pos = (ml_y_pos+ 12),
    CALL print(calcpos(330,ml_y_pos)),
    ms_facility_disp, row + 1, ml_y_pos = (ml_y_pos+ 12),
    CALL print(calcpos(300,ml_y_pos)), "Active OBV patients with a Careset(Order)", row + 1,
    ml_y_pos = (ml_y_pos+ 12), ms_daterange = concat("Order Range: ", $S_ST_DT_TM," - ", $S_EN_DT_TM),
    CALL print(calcpos(265,ml_y_pos)),
    ms_daterange, row + 1, ml_y_pos = (ml_y_pos+ 12),
    "{f/8}{cpi/14}", row + 1,
    CALL print(calcpos(625,ml_y_pos)),
    "Date:",
    CALL print(calcpos(665,ml_y_pos)), ms_curdatetime,
    row + 1, ml_y_pos = (ml_y_pos+ 10),
    CALL print(calcpos(45,ml_y_pos)),
    ms_head_line, row + 1, ml_y_pos = (ml_y_pos+ 10),
    "{f/9}{cpi/14}",
    CALL print(calcpos(45,ml_y_pos)), "{u}Unit/Room/Bed{endu}",
    row + 1,
    CALL print(calcpos(120,ml_y_pos)), "{u}Patient{endu}",
    row + 1,
    CALL print(calcpos(245,ml_y_pos)), "{u}MRN{endu}",
    row + 1,
    CALL print(calcpos(280,ml_y_pos)), "{u}FIN{endu}",
    row + 1,
    CALL print(calcpos(330,ml_y_pos)), "{u}Admit Date{endu}",
    row + 1,
    CALL print(calcpos(420,ml_y_pos)), "{u}Diagnosis{endu}",
    row + 1
    IF (curpage > 1)
     ml_y_pos = (ml_y_pos+ 12)
    ENDIF
    "{f/8}{cpi/16}"
   DETAIL
    IF (ml_y_pos > 510)
     BREAK
    ENDIF
    "{f/5}{cpi/16}{lpi/6}", ml_y_pos = (ml_y_pos+ 12),
    CALL print(calcpos(45,ml_y_pos)),
    m_patient->qual[d.seq].s_unitroombed, row + 1,
    CALL print(calcpos(120,ml_y_pos)),
    m_patient->qual[d.seq].s_patient_name, row + 1,
    CALL print(calcpos(245,ml_y_pos)),
    m_patient->qual[d.seq].s_mrn, row + 1,
    CALL print(calcpos(280,ml_y_pos)),
    m_patient->qual[d.seq].s_fin, row + 1,
    CALL print(calcpos(330,ml_y_pos)),
    m_patient->qual[d.seq].s_reg_dt_tm, row + 1,
    CALL print(calcpos(420,ml_y_pos)),
    m_patient->qual[d.seq].s_diagnosis, row + 1, ml_y_pos = (ml_y_pos+ 12)
    IF (ml_y_pos > 520)
     BREAK
    ENDIF
    CALL print(calcpos(45,ml_y_pos)), "{f/8}{cpi/16}Careset(s): ", row + 1,
    CALL sbr_parse_text(m_patient->qual[d.seq].s_order_name_concat,192)
    FOR (ml_loop = 1 TO m_pt->l_line_cnt)
      CALL print(calcpos(90,ml_y_pos)), m_pt->lns[ml_loop].s_line, ml_y_pos = (ml_y_pos+ 12),
      row + 1
      IF (ml_y_pos > 520)
       BREAK
      ENDIF
    ENDFOR
   FOOT PAGE
    "{f/8}{cpi/20}", ml_y_pos = 530, "{f/8}{cpi/12}{lpi/6}{b}",
    ml_x_pos = 30,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), ms_footer_line,
    ml_x_pos = 70, ml_y_pos = (ml_y_pos+ 7), row + 1,
    "{f/8}{cpi/20}",
    CALL print(calcpos(ml_x_pos,ml_y_pos)), ms_footer_linedesc1,
    ml_y_pos = (ml_y_pos+ 8), ml_x_pos = 250, row + 1,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), ms_footer_linedesc2, ml_y_pos = (ml_y_pos+ 12),
    "{f/8}{cpi/16}", ml_x_pos = 45, row + 1,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), curprog, ml_x_pos = 520,
    row + 1,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), "page: ",
    curpage"###", ml_x_pos = 650, row + 1,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), "Printed by:  {b}", ms_print_by,
    ml_y_pos = (ml_y_pos+ 10), ml_x_pos = 650, row + 1,
    CALL print(calcpos(ml_x_pos,ml_y_pos)), "Printed on:  {b}", ms_curdate
    IF (curendreport=0)
     "{f/8}{cpi/16}",
     CALL print(calcpos(520,ml_y_pos)), "Continued.."
    ENDIF
   FOOT REPORT
    ml_y_pos = 530, "{f/8}{cpi/12}",
    CALL print(calcpos(350,ml_y_pos)),
    "***********End of Report***********", row + 1
   WITH maxcol = 3000, maxrow = 720, dio = 8
  ;end select
 ENDIF
 SUBROUTINE sbr_parse_text(ms_txt,ml_maxlength)
   DECLARE ms_holdstr = vc WITH protect, noconstant(" ")
   SET ms_holdstr = ms_txt
   SET m_pt->l_line_cnt = 0
   WHILE (textlen(trim(ms_holdstr)) > 0)
     SET m_pt->l_line_cnt = (m_pt->l_line_cnt+ 1)
     SET stat = alterlist(m_pt->lns,m_pt->l_line_cnt)
     CALL sbr_calclinelen(ms_holdstr,ml_maxlength)
     SET m_pt->lns[m_pt->l_line_cnt].s_line = trim(substring(1,ml_linelen,ms_holdstr),3)
     SET m_pt->lns[m_pt->l_line_cnt].s_line = replace(m_pt->lns[m_pt->l_line_cnt].s_line,"|||","",0)
     SET ms_holdstr = substring((ml_linelen+ 1),(textlen(ms_holdstr) - ml_linelen),ms_holdstr)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE sbr_calclinelen(ms_txt,ml_maxlength)
   DECLARE mn_exit_while = i2 WITH protect, noconstant(0)
   DECLARE ms_tempchar3 = vc WITH protect, noconstant(" ")
   DECLARE ms_tempchar = vc WITH protect, noconstant(" ")
   SET ml_mlen = ml_maxlength
   SET ml_linelen = ml_maxlength
   WHILE ((ml_mlen > (ml_maxlength - 20)))
     SET ms_tempchar = substring(ml_mlen,1,ms_txt)
     IF (((ms_tempchar=" ") OR (((ms_tempchar=",") OR (((ms_tempchar=";") OR (((ms_tempchar="-") OR (
     ms_tempchar="/")) )) )) )) )
      SET ml_linelen = ml_mlen
      SET ml_mlen = 0
     ENDIF
     SET ml_mlen = (ml_mlen - 1)
   ENDWHILE
   SET mn_exit_while = 0
   SET ml_mlen = 1
   WHILE ((ml_mlen < (ml_linelen - 2))
    AND mn_exit_while=0)
     SET ms_tempchar3 = substring(ml_mlen,3,ms_txt)
     IF (ms_tempchar3="|||")
      SET ml_linelen = (ml_mlen+ 2)
      SET mn_exit_while = 1
     ENDIF
     SET ml_mlen = (ml_mlen+ 1)
   ENDWHILE
 END ;Subroutine
#exit_script
 FREE RECORD m_pt
 FREE RECORD m_patient
 FREE RECORD m_unit
 FREE RECORD m_orderlist
 FREE RECORD m_output
END GO
