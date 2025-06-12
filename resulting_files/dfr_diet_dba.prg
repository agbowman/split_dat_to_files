CREATE PROGRAM dfr_diet:dba
 PROMPT
  "Enter print option (file/printer/MINE): " = "MINE"
 EXECUTE cclseclogin
 SET echo_ind = 1
 SET echo_ind = 0
 IF (validate(request->ops_date,999) != 999)
  RECORD reply(
    1 ops_event = vc
    1 status_date
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET prt_loc = request->output_dist
  SET prg_name = "dfr_diet"
  SET rpt_name = "ORDER SUMMARY"
 ELSE
  IF (validate(isodbc,0)=0)
   EXECUTE cclseclogin
  ENDIF
  SET prt_loc = value( $1)
  SET prg_name = "dfr_diet"
  SET rpt_name = "ORDER SUMMARY"
 ENDIF
 SET run_dttm = concat(format(curdate,"mm/dd/yy;;d")," - ",format(curtime3,"hh:mm;;m"))
 SET run_range = concat("Period Covered: ",format((curdate - 1),"mm/dd/yy;;d")," 00:00"," to ",format
  ((curdate - 1),"mm/dd/yy;;d"),
  " 23:59")
 RECORD data(
   1 fac_cnt = i2
   1 fac_qual[*]
     2 facility_cd = f8
     2 facility_disp = vc
     2 nur_cnt = i2
     2 nur_qual[*]
       3 nurse_sta_cd = f8
       3 nurse_disp = vc
       3 pat_cnt = i2
       3 pat_qual[*]
         4 pat_name = vc
         4 person_id = f8
         4 encntr_id = f8
         4 mrn = vc
         4 fin = vc
         4 reg_dt_tm = dq8
         4 disch_dt_tm = dq8
         4 room_cd = f8
         4 room_disp = vc
         4 bed_cd = f8
         4 bed_disp = vc
         4 pat_type_cd = f8
         4 pat_type_disp = vc
         4 order_cnt = i2
         4 order_qual[*]
           5 order_id = f8
           5 catalog_cd = f8
           5 cat_disp = vc
           5 ord_mnem = vc
           5 order_action_cd = f8
           5 order_action_disp = vc
           5 order_status_cd = f8
           5 order_status_disp = vc
           5 catalog_type_cd = f8
           5 cat_type_disp = vc
           5 ordering_doc = vc
           5 entered_by = vc
           5 dept_status_cd = f8
           5 dept_status_disp = vc
           5 ord_detail_display_line = vc
           5 ordered_as_mnemonic = vc
           5 orig_order_dt_tm = dq8
           5 action_type_cd = f8
           5 action_type_disp = vc
 )
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 DECLARE fin_cd = f8
 SET fin_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 DECLARE diet_cd = f8
 DECLARE dsi_cd = f8
 DECLARE td_cd = f8
 DECLARE supp_cd = f8
 DECLARE inf_cd = f8
 DECLARE infa_cd = f8
 DECLARE tfb_cd = f8
 DECLARE tfc_cd = f8
 DECLARE tfa_cd = f8
 DECLARE high_cd = f8
 DECLARE ncs_cd = f8
 SET diet_cd = 0.0
 SET dsi_cd = 0.0
 SET td_cd = 0.0
 SET supp_cd = 0.0
 SET inf_cd = 0.0
 SET infa_cd = 0.0
 SET tfb_cd = 0.0
 SET tfc_cd = 0.0
 SET tfa_cd = 0.0
 SET high_cd = 0.0
 SET ncs_cd = 0.0
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=106
  DETAIL
   CASE (d_key)
    OF "DIETS":
     diet_cd = cv
    OF "TESTDIET":
     td_cd = cv
    OF "SUPPLEMENTS":
     supp_cd = cv
    OF "INFANTFORMULAS":
     inf_cd = cv
    OF "INFANTFORMULAADDITIVES":
     infa_cd = cv
    OF "TUBEFEEDINGBOLUS":
     tfb_cd = cv
    OF "TUBEFEEDINGCONTINUOUS":
     tfc_cd = cv
    OF "TUBEFEEDINGADDITIVES":
     tfa_cd = cv
    OF "NUTRITIONSERVICESCONSULTS":
     tfc_cd = cv
    OF "TUBEFEEDINGCONTINUOUS":
     ncs_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 RECORD xpns(
   1 tpn_cnt = i2
   1 tpn_qual[*]
     2 catalog_cd = f8
     2 description = vc
   1 ppn_cnt = i2
   1 ppn_qual[*]
     2 catalog_cd = f8
     2 description = vc
 )
 SELECT
  cd = oc.catalog_cd, desc = oc.description
  FROM order_catalog oc
  WHERE oc.active_ind=1
   AND substring(1,3,oc.description) IN ("TPN", "PPN")
  HEAD REPORT
   t = 0, p = 0
  DETAIL
   IF (substring(1,3,desc)="TPN")
    t = (t+ 1), xpn->tpn_cnt = t, stat = alterlist(xpn->tpn_qual,t),
    xpn->tpn_qual[t].catalog_cd = cd, xpn->tpn_qual[t].description = desc
   ELSE
    p = (p+ 1), xpn->ppn_cnt = p, stat = alterlist(xpn->ppn_qual,p),
    xpn->ppn_qual[p].catalog_cd = cd, xpn->ppn_qual[p].description = desc
   ENDIF
  WITH nocounter
 ;end select
 IF (echo_ind)
  CALL echo(build("diet_cd = ",diet_cd))
  CALL echo(build("td_cd = ",td_cd))
  CALL echo(build("supp_cd = ",supp_cd))
  CALL echo(build("inf_cd = ",inf_cd))
  CALL echo(build("infa_cd = ",infa_cd))
  CALL echo(build("tfb_cd = ",tfb_cd))
  CALL echo(build("tfc_cd = ",tfc_cd))
  CALL echo(build("tfa_cd = ",tfa_cd))
  CALL echo(build("tfc_cd = ",tfc_cd))
  CALL echo(build("ncs_cd = ",ncs_cd))
  CALL echorecord(xpn)
 ENDIF
 SELECT DISTINCT
  p.name_full_formatted, ed.person_id, ed.encntr_id,
  p1.name_full_formatted, p1a.name_full_formatted, ed.loc_building_cd,
  ed_loc_building_disp = uar_get_code_display(ed.loc_building_cd), ed.loc_facility_cd,
  ed_loc_facility_disp = uar_get_code_display(ed.loc_facility_cd),
  ed.loc_nurse_unit_cd, ed_loc_nurse_unit_disp = uar_get_code_display(ed.loc_nurse_unit_cd), ed
  .loc_room_cd,
  ed_loc_room_disp = uar_get_code_display(ed.loc_room_cd), ed.loc_bed_cd, ed_loc_bed_disp =
  uar_get_code_display(ed.loc_bed_cd),
  e.reg_dt_tm, e.disch_dt_tm, e.encntr_type_cd,
  e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd), ea.alias, ea1.alias,
  o.order_id, o.catalog_cd, o_catalog_disp = uar_get_code_display(o.catalog_cd),
  o.catalog_type_cd, o_cat_type_disp = uar_get_code_display(o.catalog_type_cd), oa
  .communication_type_cd,
  type_order = uar_get_code_display(oa.communication_type_cd), o.dept_status_cd, o_dept_status_disp
   = uar_get_code_display(o.dept_status_cd),
  o.order_detail_display_line, o.order_mnemonic, ord_mnem = trim(o.order_mnemonic,3),
  o.order_status_cd, o_order_status_disp = uar_get_code_display(o.order_status_cd), o
  .ordered_as_mnemonic,
  o.orig_order_dt_tm"mm/dd/yyyy hh:mm:ss;;q", o.prn_ind, oa.action_type_cd,
  oa_action_type_disp = uar_get_code_display(oa.action_type_cd), o.need_doctor_cosign_ind, doc_cosign
   =
  IF (o.need_doctor_cosign_ind=0) "No Doctor Cosign, "
  ELSEIF (o.need_doctor_cosign_ind=1) "Doctor Cosign, "
  ELSE "Doctor Refused Cosign, "
  ENDIF
  ,
  o.need_nurse_review_ind, nurse_review =
  IF (o.need_nurse_review_ind=1) "Nurse Review, "
  ELSE "Nurse Review Not Required"
  ENDIF
  , o.need_physician_validate_ind,
  doc_validate =
  IF (o.need_physician_validate_ind=0) "Physician Validation Not Required"
  ELSE "Physician Validation Required"
  ENDIF
  , o.need_rx_verify_ind, rx_verify =
  IF (o.need_rx_verify_ind=0) "No Pharmacist Verify, "
  ELSEIF (o.need_rx_verify_ind=1) "Pharmacist Verify, "
  ELSE "Rx Rejected or Halted, "
  ENDIF
  ,
  orev.provider_id, rev_doc = p3.name_full_formatted, orev.reviewed_status_flag,
  review_status =
  IF (orev.reviewed_status_flag=0) "Not Reviewed"
  ELSEIF (orev.reviewed_status_flag=1) "Accepted"
  ELSEIF (orev.reviewed_status_flag=2) "Rejected"
  ELSEIF (orev.reviewed_status_flag=3) "No longer needing review"
  ELSEIF (orev.reviewed_status_flag=4) "Superseded"
  ELSE "Reviewed"
  ENDIF
  , orev.review_reqd_ind, orev.review_dt_tm,
  orev.review_personnel_id, rev_by = p2.name_full_formatted, orev.review_type_flag,
  type_flag =
  IF (orev.review_type_flag=1) "Nurse Review"
  ELSEIF (orev.review_type_flag=2) "Doctor Cosign"
  ELSEIF (orev.review_type_flag=3) "Pharmacist Verify"
  ELSE "Physician Activate"
  ENDIF
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   orders o,
   dummyt d1,
   order_action oa,
   prsnl p1,
   prsnl p1a,
   dummyt d2,
   order_review orev,
   dummyt d3,
   prsnl p2,
   dummyt d4,
   prsnl p3
  PLAN (ed
   WHERE ed.person_id=829421
    AND ed.encntr_id=2415248)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (e
   WHERE e.person_id=ed.person_id
    AND e.encntr_id=e.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (ea1
   WHERE ea1.encntr_id=ed.encntr_id
    AND ea1.encntr_alias_type_cd=mrn_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.person_id=ed.person_id
    AND o.encntr_id=ed.encntr_id
    AND o.template_order_id=0
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd)
    AND o.order_id=1986882)
   JOIN (d1)
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (p1
   WHERE p1.person_id=o.last_update_provider_id)
   JOIN (p1a
   WHERE p1a.person_id=o.active_status_prsnl_id)
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
  ORDER BY ed.loc_facility_cd, ed.loc_nurse_unit_cd, ed.loc_room_cd,
   ed.loc_bed_cd, o.order_id
  HEAD REPORT
   f_cnt = 0, n_cnt = 0, p_cnt = 0,
   o_cnt = 0
  HEAD ed.loc_facility_cd
   f_cnt = (f_cnt+ 1), data->fac_cnt = f_cnt, stat = alterlist(data->fac_qual,f_cnt),
   data->fac_qual[f_cnt].facility_cd = ed.loc_facility_cd, data->fac_qual[f_cnt].facility_disp =
   uar_get_code_description(ed.loc_facility_cd), n_cnt = 0
  HEAD ed.loc_nurse_unit_cd
   n_cnt = (n_cnt+ 1), data->fac_qual[f_cnt].nur_cnt = n_cnt, stat = alterlist(data->fac_qual[f_cnt].
    nur_qual,n_cnt),
   data->fac_qual[f_cnt].nur_qual[n_cnt].nurse_sta_cd = ed.loc_nurse_unit_cd, data->fac_qual[f_cnt].
   nur_qual[n_cnt].nurse_disp = uar_get_code_display(ed.loc_nurse_unit_cd), p_cnt = 0
  HEAD ed.loc_room_cd
   p_cnt = (p_cnt+ 1), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_cnt = p_cnt, stat = alterlist(data->
    fac_qual[f_cnt].nur_qual[n_cnt].pat_qual,p_cnt),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].pat_name = substring(1,40,p
    .name_full_formatted), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].person_id = ed
   .person_id, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].encntr_id = ed.encntr_id,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].mrn = substring(1,9,ea1.alias), data->
   fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].fin = trim(ea.alias), data->fac_qual[f_cnt].
   nur_qual[n_cnt].pat_qual[p_cnt].reg_dt_tm = e.reg_dt_tm,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].disch_dt_tm = e.disch_dt_tm, data->fac_qual[
   f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].pat_type_cd = e.encntr_type_cd, data->fac_qual[f_cnt].
   nur_qual[n_cnt].pat_qual[p_cnt].pat_type_disp = uar_get_code_display(e.encntr_type_cd),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].room_cd = ed.loc_room_cd, data->fac_qual[
   f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].room_disp = uar_get_code_display(ed.loc_room_cd), data->
   fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].bed_cd = ed.loc_bed_cd,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].bed_disp = uar_get_code_display(ed
    .loc_bed_cd), o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_cnt = o_cnt, stat
    = alterlist(data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual,o_cnt),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].order_id = o.order_id,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].catalog_cd = o.catalog_cd,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].cat_disp =
   uar_get_code_display(o.catalog_cd),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].ord_mnem = trim(o
    .order_mnemonic), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   order_action_cd = oa.action_type_cd, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].
   order_qual[o_cnt].order_action_disp = uar_get_code_display(oa.action_type_cd),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].order_status_cd = o
   .order_status_cd, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   order_status_disp = uar_get_code_display(o.order_status_cd), data->fac_qual[f_cnt].nur_qual[n_cnt]
   .pat_qual[p_cnt].order_qual[o_cnt].catalog_type_cd = o.catalog_type_cd,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].cat_type_disp =
   uar_get_code_display(o.catalog_type_cd), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].
   order_qual[o_cnt].ordering_doc = trim(p1.name_full_formatted), data->fac_qual[f_cnt].nur_qual[
   n_cnt].pat_qual[p_cnt].order_qual[o_cnt].entered_by = trim(p1a.name_full_formatted),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].dept_status_cd = o
   .dept_status_cd, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   dept_status_disp = uar_get_code_display(o.dept_status_cd), data->fac_qual[f_cnt].nur_qual[n_cnt].
   pat_qual[p_cnt].order_qual[o_cnt].need_doc_cosign_ind = o.need_doctor_cosign_ind,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].need_nurse_review_ind = o
   .need_nurse_review_ind, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   need_physician_val_ind = o.need_physician_validate_ind, data->fac_qual[f_cnt].nur_qual[n_cnt].
   pat_qual[p_cnt].order_qual[o_cnt].need_rx_verify_ind = o.need_rx_verify_ind,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].ord_detail_display_line =
   o.order_detail_display_line, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[
   o_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, data->fac_qual[f_cnt].nur_qual[n_cnt].
   pat_qual[p_cnt].order_qual[o_cnt].orig_order_dt_tm = o.orig_order_dt_tm,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].name_of_reviewer = trim(p3
    .name_full_formatted), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   review_status_flag = orev.reviewed_status_flag, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[
   p_cnt].order_qual[o_cnt].review_status = review_status,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].review_dt_tm = orev
   .review_dt_tm, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   name_of_reviewer = trim(p2.name_full_formatted), data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[
   p_cnt].order_qual[o_cnt].review_type_flag = orev.review_type_flag,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].rev_type_flag_disp =
   type_flag, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].
   communication_type_cd = oa.communication_type_cd, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[
   p_cnt].order_qual[o_cnt].type_order = uar_get_code_display(oa.communication_type_cd),
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].doc_cosign = doc_cosign,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].nurse_review =
   nurse_review, data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].doc_validate
    = doc_validate,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].rx_verify = rx_verify,
   data->fac_qual[f_cnt].nur_qual[n_cnt].pat_qual[p_cnt].order_qual[o_cnt].review_reqd_ind = orev
   .review_reqd_ind
  WITH maxrec = 1000, nocounter, skipreport = 1,
   maxrow = 1000, maxcol = 2000, outerjoin = d1,
   outerjoin = d2, outerjoin = d3, outerjoin = d4
 ;end select
 IF (echo_ind)
  CALL echorecord(data)
 ENDIF
END GO
