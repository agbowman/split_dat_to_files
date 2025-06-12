CREATE PROGRAM dfr_tpn
 SET prt_loc = "MINE"
 SET echo_ind = 1
 SET run_dttm = concat(format(curdate,"mm/dd/yy;;d")," - ",format(curtime3,"hh:mm;;m"))
 RECORD pat_data(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pat_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 mrn = vc
     2 fin = vc
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 building_cd = f8
     2 build_disp = vc
     2 facility_cd = f8
     2 facility_disp = vc
     2 nurse_sta_cd = f8
     2 nurse_disp = vc
     2 room_cd = f8
     2 room_disp = vc
     2 bed_cd = f8
     2 bed_disp = vc
     2 order_cnt = i4
     2 order_qual[*]
       3 order_id = f8
       3 catalog_cd = f8
       3 cat_disp = vc
       3 order_mnemonic = vc
       3 order_action_cd = f8
       3 order_action_disp = vc
       3 order_status_cd = f8
       3 order_status_disp = vc
       3 catalog_type_cd = f8
       3 catalog_type_disp = vc
       3 ordering_doc = vc
       3 dept_status_cd = f8
       3 dept_stat_disp = vc
       3 hna_mnemonic = vc
       3 med_ord_type_cd = f8
       3 m_ord_type_disp = vc
       3 need_doc_cosign_ind = i4
       3 doc_cosign = vc
       3 need_nurse_review_ind = i4
       3 nurse_review = vc
       3 need_physician_val_ind = i4
       3 phy_validate = vc
       3 need_rx_verify_ind = i4
       3 need_rx_verify = vc
       3 ord_detail_display_line = vc
       3 ordered_as_mnemonic = vc
       3 orig_order_dt_tm = dq8
       3 prn_ind = i4
       3 action_type_cd = f8
       3 action_type_disp = vc
       3 doc_needs_to_review = vc
       3 review_status_flag = i4
       3 review_status = vc
       3 review_dt_tm = dq8
       3 name_of_reviewer = vc
       3 review_type_flag = i4
       3 rev_type_flag_disp = vc
 )
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 DECLARE ordered_cd = f8
 DECLARE on_hold_cd = f8
 DECLARE pending_cd = f8
 DECLARE pending_rev_cd = f8
 DECLARE in_process_cd = f8
 DECLARE future_cd = f8
 DECLARE completed_cd = f8
 SET ordered_cd = 0.0
 SET on_hold_cd = 0.0
 SET pending_cd = 0.0
 SET pending_rev_cd = 0.0
 SET in_process_cd = 0.0
 SET future_cd = 0.0
 SET completed_cd = 0.0
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=6004
  DETAIL
   CASE (d_key)
    OF "ORDERED":
     ordered_cd = cv
    OF "ONHOLDMEDSTUDENT":
     on_hold_cd = cv
    OF "PENDINGCOMPLETE":
     pending_cd = cv
    OF "PENDINGREVIEW":
     pending_rev_cd = cv
    OF "INPROCESS":
     in_process_cd = cv
    OF "FUTURE":
     future_cd = cv
    OF "COMPLETED":
     future_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 DECLARE rad_cd = f8
 DECLARE consult_cd = f8
 DECLARE diet_cd = f8
 SET rad_cd = 0.0
 SET consult_cd = 0.0
 SET diet_cd = 0.0
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=16389
  DETAIL
   CASE (d_key)
    OF "DIAGNOSTICIMAGING":
     rad_cd = cv
    OF "CONSULTS":
     consult_cd = cv
    OF "DIETNUTRITIONSERVICES":
     diet_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 IF (echo_ind)
  CALL echo(build("run_dttm =",run_dttm))
  CALL echo(build("mrn_cd =",mrn_cd))
  CALL echo(build("fin_cd =",fin_cd))
  CALL echo(build("ordered_cd =",ordered_cd))
  CALL echo(build("on_hold_cd =",on_hold_cd))
  CALL echo(build("pending_cd =",pending_cd))
  CALL echo(build("pending_rev_cd =",pending_rev_cd))
  CALL echo(build("in_process_cd =",in_process_cd))
  CALL echo(build("future_cd =",future_cd))
  CALL echo(build("rad_cd =",rad_cd))
  CALL echo(build("consult_cd =",consult_cd))
  CALL echo(build("diet_cd =",diet_cd))
 ENDIF
 SELECT INTO value(prt_loc)
  p.name_full_formatted, ed.person_id, ed.encntr_id,
  p1.name_full_formatted, ed.loc_building_cd, ed_loc_building_disp = uar_get_code_display(ed
   .loc_building_cd),
  ed.loc_facility_cd, ed_loc_facility_disp = uar_get_code_display(ed.loc_facility_cd), ed
  .loc_nurse_unit_cd,
  ed_loc_nurse_unit_disp = uar_get_code_display(ed.loc_nurse_unit_cd), ed.loc_bed_cd, ed_loc_bed_disp
   = uar_get_code_display(ed.loc_bed_cd),
  ed.loc_room_cd, ed_loc_room_disp = uar_get_code_display(ed.loc_room_cd), ea.alias,
  pa.alias, o.catalog_cd, o_catalog_disp = uar_get_code_display(o.catalog_cd),
  o.catalog_type_cd, o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.dept_status_cd,
  o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o.med_order_type_cd,
  o_med_order_type_disp = uar_get_code_display(o.med_order_type_cd),
  o.need_doctor_cosign_ind, doc_cosign =
  IF (o.need_doctor_cosign_ind=0) "Does not need doctor cosign"
  ELSEIF (o.need_doctor_cosign_ind=1) "Needs doctor cosign"
  ELSE "Cosign notification is refused by doctor"
  ENDIF
  , o.need_nurse_review_ind,
  nurse_review =
  IF (o.need_nurse_review_ind=1) "Nurse Review Required"
  ELSE "Nurse Review Not Required"
  ENDIF
  , o.need_physician_validate_ind, doc_validate =
  IF (o.need_physician_validate_ind=0) "Physician Validation Not Required"
  ELSE "Physician Validation Required"
  ENDIF
  ,
  o.need_rx_verify_ind, rx_verify =
  IF (o.need_rx_verify_ind=0) "Rx Verification Not Required"
  ELSEIF (o.need_rx_verify_ind=1) "Rx Verification Required"
  ELSE "Rx Rejected or Halted "
  ENDIF
  , o.order_detail_display_line,
  o.order_mnemonic, o.order_status_cd, o_order_status_disp = uar_get_code_display(o.order_status_cd),
  o.ordered_as_mnemonic, o.orig_order_dt_tm"mm/dd/yyyy hh:mm:ss;;q", o.prn_ind,
  oa.action_type_cd, oa_action_type = uar_get_code_display(oa.action_type_cd), orev.provider_id,
  p3.name_full_formatted, orev.reviewed_status_flag, rev_status =
  IF (orev.reviewed_status_flag=0) "Not Reviewed"
  ELSEIF (orev.reviewed_status_flag=1) "Accepted"
  ELSEIF (orev.reviewed_status_flag=2) "Rejected"
  ELSEIF (orev.reviewed_status_flag=3) "No longer needing review"
  ELSEIF (orev.reviewed_status_flag=4) "Superseded"
  ELSE "Reviewed"
  ENDIF
  ,
  orev.review_dt_tm"mm/dd/yyyy hh:mm:ss;;q", orev.review_personnel_id, rev_by = p2
  .name_full_formatted,
  orev.review_type_flag, type_flag =
  IF (orev.review_type_flag=1) "Nurse Review"
  ELSEIF (orev.review_type_flag=2) "Doctor Cosign"
  ELSEIF (orev.review_type_flag=3) "Pharmacist Verify"
  ELSE "Physician Activate"
  ENDIF
  FROM encntr_domain ed,
   person p,
   encntr_alias ea,
   person_alias pa,
   orders o,
   dummyt d1,
   order_action oa,
   prsnl p1,
   dummyt d2,
   order_review orev,
   dummyt d3,
   prsnl p2,
   dummyt d4,
   prsnl p3
  PLAN (ed
   WHERE ed.beg_effective_dt_tm >= cnvtdatetime("01-nov-2003 00:00:00.00")
    AND ed.person_id=858241
    AND ed.encntr_id=2443872)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.person_id=ed.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.person_id=ed.person_id
    AND o.encntr_id=ed.encntr_id
    AND o.orig_order_dt_tm >= cnvtdatetime((curdate - 1),0000)
    AND o.catalog_type_cd=2516)
   JOIN (d1)
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (p1
   WHERE p1.person_id=o.last_update_provider_id)
   JOIN (d2)
   JOIN (orev
   WHERE orev.order_id=o.order_id
    AND orev.action_sequence=o.last_core_action_sequence)
   JOIN (d3)
   JOIN (p2
   WHERE p2.person_id=orev.review_personnel_id)
   JOIN (d4)
   JOIN (p3
   WHERE p3.person_id=orev.provider_id)
  ORDER BY ed.loc_building_cd, ed.loc_facility_cd, ed.loc_nurse_unit_cd,
   ed.loc_room_cd, ed.loc_bed_cd, o.order_id
  HEAD REPORT
   title1 = "BAYSTATE HEALTH SYSTEMS", prg_nm = "dfr_tpn", x_pos = 43,
   y_pos = 20, jump = 9, font10 = "{f/24}{cpi/10}{lpi/6}",
   font10i = "{f/26}{cpi/10}{lpi/6}", font12tr = "{f/4}{cpi/12}{lpi/8}", font12tri =
   "{f/6}{cpi/12}{lpi/8}",
   font12nc = "{f/24}{cpi/12}{lpi/8}", font12nci = "{f/26}{cpi/12}{lpi/8}", font17 =
   "{f/24}{cpi/15^}{lpi/8}",
   font17i = "{f/26}{cpi/15^}{lpi/8}"
  HEAD PAGE
   row + 1, font12tr,
   CALL print(calcpos((x_pos+ 180),y_pos)),
   title1, row + 1, y_pos = (y_pos+ jump),
   CALL print(calcpos(x_pos,y_pos)), prt_loc,
   CALL print(calcpos((x_pos+ 220),y_pos)),
   "dfr_tpn", row + 1, y_pos = (y_pos+ jump),
   CALL print(calcpos(x_pos,y_pos)), run_dttm
  HEAD ed.loc_building_cd
   x = 1
  HEAD ed.loc_facility_cd
   x = 1
  HEAD ed.loc_nurse_unit_cd
   x = 1
  HEAD ed.loc_room_cd
   x = 1
  DETAIL
   loc_t = ed.loc_bed_cd, x = 1
  WITH maxrec = 1000, dio = postscript, skipreport = 1,
   outerjoin = d1, outerjoin = d2, outerjoin = d3,
   outerjoin = d4
 ;end select
END GO
