CREATE PROGRAM dfr_ord_sum:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE cclseclogin
 SET echo_ind = 1
 SET echo_ind = 0
 SET echo_pats = 1
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
  SET rpt_name = "ORDER SUMMARY"
 ELSE
  IF (validate(isodbc,0)=0)
   EXECUTE cclseclogin
  ENDIF
  SET rpt_name = "ORDER SUMMARY"
 ENDIF
 SET run_dttm = concat(format(curdate,"mm/dd/yy;;d")," - ",format(curtime,"hh:mm;;m"))
 SET st_date = format((curdate - 1),"mm/dd/yy;;d")
 SET st_time = format(curtime,"hh:mm;;m")
 SET ed_date = format(curdate,"mm/dd/yy;;d")
 SET ed_time = format(curtime,"hh:mm;;m")
 SET run_range = concat("Period Covered: ",st_date," ",st_time," to ",
  ed_date," ",ed_time)
 DECLARE doc_cos = vc
 DECLARE doc_val = vc
 DECLARE nur_rev = vc
 DECLARE rx_ver = vc
 DECLARE no_revs = vc
 DECLARE spaces = c45
 DECLARE temp = c45
 DECLARE dtl_spaces = c100
 DECLARE dtl_temp = c100
 SET spaces = fillstring(45," ")
 SET temp = fillstring(45," ")
 SET dtl_spaces = fillstring(100," ")
 SET dtl_temp = fillstring(100," ")
 RECORD pats(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 pat_name = vc
     2 mrn = vc
     2 fin = vc
     2 facility_cd = f8
     2 nurse_u_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 reg_dt_tm = dq8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 doc_cnt = i4
     2 doc_qual[*]
       3 admit_doc = vc
     2 ord_cnt = i4
     2 ord_qual[*]
       3 person_id = f8
       3 encntr_id = f8
       3 order_id = f8
       3 order_status_cd = f8
       3 ordering_doc = vc
       3 entered_by = vc
       3 communication_type_cd = f8
       3 ordered_as_mnemonic = vc
       3 orig_order_dt_tm = dq8
       3 action_type_cd = f8
       3 last_action_sequence = i4
       3 need_doc_cosign_ind = i4
       3 doc_cosign = vc
       3 need_nurse_review_ind = i4
       3 nurse_review = vc
       3 need_physician_val_ind = i4
       3 doc_validate = vc
       3 need_rx_verify_ind = i4
       3 rx_verify = vc
       3 dtl_cnt = i4
       3 dtl_qual[*]
         4 action_sequence = i4
         4 detail_sequence = i4
         4 oe_field_display_value = vc
         4 prt_fld_display_value = vc
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
         4 parent_action_sequence = i4
         4 display = vc
         4 rsn = c1
         4 quest = c1
         4 dtl_len = i2
         4 prt_dsply_len = i2
       3 rev_cnt = i4
       3 rev_qual[*]
         4 action_sequence = i4
         4 review_sequence = i4
         4 review_reqd_ind = i4
         4 review_type_flag = i2
         4 rev_type_flag_disp = vc
         4 review_status_flag = i2
         4 review_status_disp = vc
         4 review_dt_tm = dq8
         4 provider_id = f8
         4 needs_to_review = vc
         4 review_personnel_id = f8
         4 reviewed_by = vc
 )
 SET curalias pat pats->pat_qual[p]
 SET curalias pat_out pats->pat_qual[d1.seq]
 SET curalias docs pats->pat_qual[p].doc_qual[doc]
 SET curalias ord_in pats->pat_qual[d1.seq].ord_qual[o]
 SET curalias ord_out pats->pat_qual[p].ord_qual[o]
 SET curalias dtls_in pats->pat_qual[d1.seq].ord_qual[d2.seq].dtl_qual[d]
 SET curalias dtls_out pats->pat_qual[p].ord_qual[o].dtl_qual[d]
 SET curalias rev_in pats->pat_qual[d1.seq].ord_qual[d2.seq].rev_qual[r]
 SET curalias rev_out pats->pat_qual[p].ord_qual[o].rev_qual[r]
 DECLARE mrn_cd = f8
 SET mrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
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
 DECLARE verbal_cd = f8
 DECLARE epr_cd = f8
 DECLARE ord_cd = f8
 DECLARE mod_cd = f8
 DECLARE rnew_cd = f8
 SET ordered_cd = 0.0
 SET on_hold_cd = 0.0
 SET pending_cd = 0.0
 SET pending_rev_cd = 0.0
 SET in_process_cd = 0.0
 SET future_cd = 0.0
 SET completed_cd = 0.0
 SET verbal_cd = 0.0
 SET epr_cd = 0.0
 SET ord_cd = 0.0
 SET mod_cd = 0.0
 SET rnew_cd = 0.0
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=6006
   AND c.cdf_meaning="VERBAL"
  DETAIL
   verbal_cd = cv
  WITH nocounter
 ;end select
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
 DECLARE stop_cd = f8
 SET stop_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.active_ind=1
   AND c.display_key="STOP DATE/TIME"
   AND c.code_set=16449
  DETAIL
   stop_cd = c.code_value
  WITH check, nocounter
 ;end select
 SELECT INTO "nl:"
  cv = c.code_value
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=333
   AND c.display_key="ADMITTINGPHYSICIAN"
  DETAIL
   epr_cd = cv
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv = c.code_value, d_key = c.display_key
  FROM code_value c
  WHERE c.active_ind=1
   AND c.code_set=6003
  DETAIL
   CASE (d_key)
    OF "ORDER":
     ord_cd = cv
    OF "MODIFY":
     mod_cd = cv
    OF "RENEW":
     rnew_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 IF (echo_ind)
  CALL echo(build("st_date =",st_date))
  CALL echo(build("st_time =",st_time))
  CALL echo(build("ed_date =",ed_date))
  CALL echo(build("ed_time =",ed_time))
  CALL echo(build("run_dttm =",run_dttm))
  CALL echo(build("run_range =",run_range))
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
  CALL echo(build("stop_cd =",stop_cd))
  CALL echo(build("epr_cd =",epr_cd))
  CALL echo(build("ord_cd =",ord_cd))
  CALL echo(build("mod_cd =",mod_cd))
  CALL echo(build("rnew_cd =",rnew_cd))
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, ed.person_id, ed.encntr_id,
  ed.loc_building_cd, ed_loc_building_disp = uar_get_code_display(ed.loc_building_cd), ed
  .loc_facility_cd,
  ed_loc_facility_disp = uar_get_code_display(ed.loc_facility_cd), ed.loc_nurse_unit_cd,
  ed_loc_nurse_unit_disp = uar_get_code_display(ed.loc_nurse_unit_cd),
  ed.loc_room_cd, ed_loc_room_disp = uar_get_code_display(ed.loc_room_cd), ed.loc_bed_cd,
  ed_loc_bed_disp = uar_get_code_display(ed.loc_bed_cd), e.reg_dt_tm"dd-mmm-yy hh:mm:ss;;q", e
  .disch_dt_tm"dd-mmm-yy hh:mm:ss;;q",
  e.disch_disposition_cd, e_disch_disposition_disp = uar_get_code_display(e.disch_disposition_cd), e
  .encntr_type_cd,
  e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd), p.birth_dt_tm"dd-mmm-yy hh:mm:ss;;q",
  p.sex_cd,
  p_sex_disp = uar_get_code_display(p.sex_cd), ea.alias, ea1.alias,
  p1.name_full_formatted
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   encntr_prsnl_reltn epr,
   prsnl p1
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.person_id IN (763730, 858241)
    AND ed.encntr_id IN (1135587, 2443872))
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (e
   WHERE e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.person_id=ed.person_id
    AND e.encntr_id=e.encntr_id
    AND e.active_ind=1
    AND e.disch_dt_tm=null)
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
   JOIN (epr
   WHERE epr.encntr_id=ed.encntr_id
    AND epr.encntr_prsnl_r_cd=epr_cd)
   JOIN (p1
   WHERE p1.person_id=epr.prsnl_person_id)
  ORDER BY ed.loc_facility_cd, ed.loc_nurse_unit_cd, ed.loc_room_cd,
   ed.loc_bed_cd, epr.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD REPORT
   p = 0, rpt_name = cnvtlower(curprog)
  HEAD ed.person_id
   p = (p+ 1), pats->pat_cnt = p, stat = alterlist(pats->pat_qual,p),
   pat->person_id = ed.person_id, pat->encntr_id = ed.encntr_id, pat->pat_name = p
   .name_full_formatted,
   pat->mrn = ea1.alias, pat->fin = ea.alias, pat->facility_cd = ed.loc_facility_cd,
   pat->nurse_u_cd = ed.loc_nurse_unit_cd, pat->room_cd = ed.loc_room_cd, pat->bed_cd = ed.loc_bed_cd,
   pat->reg_dt_tm = e.reg_dt_tm, pat->sex_cd = p.sex_cd, pat->birth_dt_tm = p.birth_dt_tm,
   doc = 0
  DETAIL
   doc = (doc+ 1), pats->pat_qual[p].doc_cnt = doc, stat = alterlist(pats->pat_qual[p].doc_qual,doc),
   doc_name = substring(1,40,p1.name_full_formatted), docs->admit_doc = doc_name
  WITH nocounter, maxrow = 1000, maxcol = 2000
 ;end select
 SELECT INTO "nl:"
  o.order_id, o.person_id, o.encntr_id,
  p1.name_full_formatted, p1a.name_full_formatted, o.catalog_cd,
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o.catalog_type_cd, o_cat_type_disp =
  uar_get_code_display(o.catalog_type_cd),
  oa.communication_type_cd, type_order = uar_get_code_display(oa.communication_type_cd), o
  .dept_status_cd,
  o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o.order_detail_display_line, o
  .order_mnemonic,
  ord_mnem = trim(o.order_mnemonic,3), o.order_status_cd, o_order_status_disp = uar_get_code_display(
   o.order_status_cd),
  o.ordered_as_mnemonic, o.orig_order_dt_tm"mm/dd/yyyy hh:mm:ss;;q", o.status_dt_tm
  "mm/dd/yyyy hh:mm:ss;;q",
  o.prn_ind, oa.action_type_cd, oa_action_type_disp = uar_get_code_display(oa.action_type_cd),
  o.need_doctor_cosign_ind, o.need_nurse_review_ind, o.need_physician_validate_ind,
  o.need_rx_verify_ind, o.last_action_sequence
  FROM (dummyt d1  WITH seq = pats->pat_cnt),
   orders o,
   prsnl p1,
   prsnl p1a,
   order_action oa
  PLAN (d1)
   JOIN (o
   WHERE (o.person_id=pat_out->person_id)
    AND (o.encntr_id=pat_out->encntr_id)
    AND o.template_order_id=0
    AND o.orig_order_dt_tm > cnvtdatetime("18-dec-2003 00:00:00.00")
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd IN (ord_cd, mod_cd, rnew_cd))
   JOIN (p1
   WHERE p1.person_id=o.last_update_provider_id)
   JOIN (p1a
   WHERE p1a.person_id=o.active_status_prsnl_id)
  ORDER BY o.order_id DESC
  HEAD REPORT
   o = 0, r_cnt = 0, p = 0
  HEAD d1.seq
   o = 0
  DETAIL
   o = (o+ 1), pats->pat_qual[d1.seq].ord_cnt = o, stat = alterlist(pats->pat_qual[d1.seq].ord_qual,o
    ),
   ord_in->person_id = pat->person_id, ord_in->encntr_id = pat->encntr_id, ord_in->person_id = o
   .person_id,
   ord_in->encntr_id = o.encntr_id, ord_in->order_id = o.order_id, ord_in->order_status_cd = o
   .order_status_cd,
   ord_doc = substring(1,40,p1.name_full_formatted), ord_in->ordering_doc = ord_doc, ent_by =
   substring(1,40,p1a.name_full_formatted),
   ord_in->entered_by = ent_by, ord_in->communication_type_cd = oa.communication_type_cd, mnem = trim
   (o.ordered_as_mnemonic,3),
   ord_in->ordered_as_mnemonic = mnem, ord_in->orig_order_dt_tm = o.orig_order_dt_tm, ord_in->
   action_type_cd = oa.action_type_cd,
   ord_in->last_action_sequence = o.last_action_sequence, ord_in->need_doc_cosign_ind = o
   .need_doctor_cosign_ind
   CASE (o.need_doctor_cosign_ind)
    OF 0:
     ord_in->doc_cosign = "No Doctor Cosign, "
    OF 1:
     ord_in->doc_cosign = "Doctor Cosign, "
    ELSE
     ord_in->doc_cosign = "Doctor Refused Cosign, "
   ENDCASE
   ord_in->need_nurse_review_ind = o.need_nurse_review_ind
   CASE (o.need_nurse_review_ind)
    OF 1:
     ord_in->nurse_review = "Nurse Review, "
    ELSE
     ord_in->nurse_review = "Nurse Review Not Required"
   ENDCASE
   ord_in->need_physician_val_ind = o.need_physician_validate_ind
   CASE (o.need_physician_validate_ind)
    OF 0:
     ord_in->doc_validate = "Physician Validation Not Required, "
    ELSE
     ord_in->doc_validate = "Physician Validation Required, "
   ENDCASE
   ord_in->need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     ord_in->rx_verify = "No Pharmacist Verify, "
    OF 1:
     ord_in->rx_verify = "Pharmacist Verify, "
    ELSE
     ord_in->rx_verify = "Rx Rejected or Halted, "
   ENDCASE
  WITH nocounter, maxcol = 1000, maxrow = 200,
   outerjoin = d3
 ;end select
 SELECT
  od.order_id, od.action_sequence, od.detail_sequence,
  od.oe_field_id, cv.display, od.oe_field_display_value,
  od.oe_field_dt_tm_value, od.oe_field_meaning, cv.code_value,
  cv.display_key, od.oe_field_meaning_id, od.oe_field_value,
  od.parent_action_sequence, rsn =
  IF (cv.display_key="*REASON*") "Y"
  ELSE "N"
  ENDIF
  , quest =
  IF (cv.display_key="*PREVIOUS*") "Y"
  ELSE "N"
  ENDIF
  FROM (dummyt d1  WITH seq = pats->pat_cnt),
   (dummyt d2  WITH seq = pats->pat_qual[d1.seq].ord_cnt),
   order_detail od,
   code_value cv,
   dummyt d3
  PLAN (d1)
   JOIN (d3)
   JOIN (d2)
   JOIN (od
   WHERE (od.order_id=pats->pat_qual[d1.seq].ord_qual[d2.seq].order_id)
    AND od.oe_field_id != stop_cd)
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=16449
    AND cv.cdf_meaning="DETAIL"
    AND cv.code_value=od.oe_field_id)
  ORDER BY pats->pat_qual[d1.seq].ord_qual[d2.seq].order_id DESC, od.detail_sequence, od.oe_field_id
  WITH nocounter, outerjoin = d3
 ;end select
 IF (echo_pats)
  CALL echorecord(pats)
 ENDIF
END GO
