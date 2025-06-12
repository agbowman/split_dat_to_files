CREATE PROGRAM bhs_rpt_narcotic_infusion
 PROMPT
  "Enter Output:" = "0.00",
  "Enter ENCNTR_ID" = ""
  WITH var_output, var_encntr_id
 FREE RECORD work
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 e_cnt = i4
   1 encntrs[*]
     2 person_id = f8
     2 encntr_id = f8
     2 pat_name = vc
     2 corp_mrn = vc
     2 acct_nbr = vc
     2 d_cnt = i4
     2 doc_ords[*]
       3 order_id = f8
       3 order_desc = vc
       3 order_dt_tm = dq8
       3 order_comment = vc
       3 med_order_id = f8
       3 med_order_slot = i4
     2 m_cnt = i4
     2 med_ords[*]
       3 order_id = f8
       3 order_desc = vc
       3 order_dt_tm = dq8
       3 drug_form = f8
       3 order_details = vc
     2 i_cnt = i4
     2 ivs[*]
       3 med_order_slot = i4
       3 beg_dt_tm = dq8
       3 beg_dt_tm_disp = vc
       3 beg_doc_by = vc
       3 beg_witness = vc
       3 end_dt_tm = dq8
       3 end_dt_tm_disp = vc
       3 end_doc_by = vc
       3 end_witness = vc
       3 waste_amount = vc
       3 total_hrs = f8
       3 total_str = vc
     2 p_cnt = i4
     2 patches[*]
       3 med_order_slot = i4
       3 beg_dt_tm = dq8
       3 beg_dt_tm_disp = vc
       3 beg_doc_by = vc
       3 beg_witness = vc
       3 end_dt_tm = dq8
       3 end_dt_tm_disp = vc
       3 end_doc_by = vc
       3 end_witness = vc
       3 total_hrs = f8
       3 total_str = vc
 )
 SET work->beg_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00")
 SET work->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 IF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->e_cnt = 1
  SET stat = alterlist(work->encntrs,1)
  SET work->encntrs[1].encntr_id = request->visit[1].encntr_id
 ELSEIF (cnvtreal(parameter(2,0)) > 0.00)
  SET work->e_cnt = 1
  SET stat = alterlist(work->encntrs,1)
  SET work->encntrs[1].encntr_id = cnvtreal(parameter(2,0))
 ELSE
  CALL echo("No valid encntr_id given. Exiting Script")
  GO TO exit_script
 ENDIF
 DECLARE cs4_cmrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs72_infusion_start_time_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INFUSIONSTARTTIME"))
 DECLARE cs72_infusion_end_time_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INFUSIONENDTIME"))
 DECLARE cs72_waste_amount_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WASTEAMOUNT"))
 DECLARE cs72_patch_applied_time_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PATCHAPPLIEDTIME"))
 DECLARE cs72_patch_removal_time_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PATCHREMOVALTIME"))
 DECLARE cs72_nurse_witness_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"NURSEWITNESS"))
 DECLARE cs319_fin_nbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs200_narc_infuse_acct_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICINFUSIONACCOUNTABILITY"))
 DECLARE cs200_narc_shift_doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "NARCOTICSHIFTDOCUMENTATION"))
 DECLARE cs4002_infusion_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,"INFUSION"))
 DECLARE cs4002_patch_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,"PATCH"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   encntr_alias ea,
   person p,
   person_alias pa
  PLAN (d
   WHERE (work->encntrs[d.seq].encntr_id > 0.00))
   JOIN (e
   WHERE (work->encntrs[d.seq].encntr_id=e.encntr_id))
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=cs319_fin_nbr_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=cs4_cmrn_cd
    AND pa.active_ind=1)
  DETAIL
   work->encntrs[d.seq].person_id = p.person_id, work->encntrs[d.seq].pat_name = trim(p
    .name_full_formatted,3), work->encntrs[d.seq].corp_mrn = trim(pa.alias,3),
   work->encntrs[d.seq].acct_nbr = trim(ea.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   orders o,
   order_comment oc,
   long_text lt
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=work->encntrs[d.seq].encntr_id)
    AND o.catalog_cd IN (cs200_narc_infuse_acct_cd, cs200_narc_shift_doc_cd)
    AND o.order_status_cd IN (cs6004_ordered_cd, cs6004_completed_cd))
   JOIN (oc
   WHERE o.order_id=oc.order_id
    AND oc.action_sequence=1)
   JOIN (lt
   WHERE oc.long_text_id=lt.long_text_id)
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   d_cnt = 0, m_cnt = 0, tmp_med_id = 0.0,
   tmp_ret = 0, tmp_slot = 0
  DETAIL
   d_cnt = (work->encntrs[d.seq].d_cnt+ 1), stat = alterlist(work->encntrs[d.seq].doc_ords,d_cnt),
   work->encntrs[d.seq].d_cnt = d_cnt,
   work->encntrs[d.seq].doc_ords[d_cnt].order_id = o.order_id, work->encntrs[d.seq].doc_ords[d_cnt].
   order_desc = trim(o.hna_order_mnemonic,3), work->encntrs[d.seq].doc_ords[d_cnt].order_dt_tm = o
   .orig_order_dt_tm,
   work->encntrs[d.seq].doc_ords[d_cnt].order_comment = trim(lt.long_text,3), work->encntrs[d.seq].
   doc_ords[d_cnt].med_order_id = cnvtreal(substring((findstring("(ORDER_ID:",lt.long_text)+ 10),((
     findstring(")",lt.long_text,0,1) - findstring("(ORDER_ID:",lt.long_text)) - 10),lt.long_text))
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].d_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (work->encntrs[d1.seq].doc_ords[d2.seq].med_order_id=o.order_id))
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.action_sequence=1
    AND od.oe_field_meaning="DRUGFORM")
  ORDER BY o.orig_order_dt_tm, o.order_id, d2.seq
  HEAD REPORT
   m_cnt = 0
  HEAD o.orig_order_dt_tm
   m_cnt = 0
  HEAD o.order_id
   m_cnt = (work->encntrs[d1.seq].m_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].med_ords,m_cnt),
   work->encntrs[d1.seq].m_cnt = m_cnt,
   work->encntrs[d1.seq].med_ords[m_cnt].order_desc = trim(o.ordered_as_mnemonic,3), work->encntrs[d1
   .seq].med_ords[m_cnt].order_dt_tm = o.orig_order_dt_tm, work->encntrs[d1.seq].med_ords[m_cnt].
   order_details = trim(o.clinical_display_line,3),
   work->encntrs[d1.seq].med_ords[m_cnt].drug_form = od.oe_field_value
  DETAIL
   work->encntrs[d1.seq].doc_ords[d2.seq].med_order_slot = m_cnt
  WITH nocounter
 ;end select
 DECLARE tmp_inf_beg = dq8
 DECLARE tmp_inf_beg_by = vc
 DECLARE tmp_inf_end = dq8
 DECLARE tmp_inf_end_by = vc
 DECLARE tmp_waste = vc
 DECLARE tmp_patch_beg = dq8
 DECLARE tmp_patch_beg_by = vc
 DECLARE tmp_patch_end = dq8
 DECLARE tmp_patch_end_by = vc
 DECLARE tmp_witness = vc
 SELECT INTO "NL:"
  med_order_slot = work->encntrs[d1.seq].doc_ords[d2.seq].med_order_slot, form_ref_nbr = cnvtint(
   substring(1,(findstring("!",ce.reference_nbr) - 1),ce.reference_nbr))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   clinical_event ce,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].d_cnt))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND (ce.order_id=work->encntrs[d1.seq].doc_ords[d2.seq].order_id)
    AND ce.event_cd IN (cs72_infusion_start_time_cd, cs72_infusion_end_time_cd, cs72_waste_amount_cd,
   cs72_patch_applied_time_cd, cs72_patch_removal_time_cd,
   cs72_nurse_witness_cd)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
   JOIN (pr
   WHERE ce.performed_prsnl_id=pr.person_id)
  ORDER BY med_order_slot, ce.event_end_dt_tm, form_ref_nbr
  HEAD REPORT
   i_cnt = 0, p_cnt = 0, tmp_inf_beg = 0.00,
   tmp_inf_end = 0.00, tmp_waste = "", tmp_patch_beg = 0.00,
   tmp_patch_end = 0.00, tmp_witness = ""
  HEAD med_order_slot
   tmp_inf_beg = 0.00, tmp_inf_end = 0.00, tmp_waste = "",
   tmp_patch_beg = 0.00, tmp_patch_end = 0.00, tmp_witness = ""
  HEAD ce.event_end_dt_tm
   tmp_inf_beg = 0.00, tmp_inf_end = 0.00, tmp_waste = "",
   tmp_patch_beg = 0.00, tmp_patch_end = 0.00, tmp_witness = ""
  HEAD form_ref_nbr
   tmp_inf_beg = 0.00, tmp_inf_end = 0.00, tmp_waste = "",
   tmp_patch_beg = 0.00, tmp_patch_end = 0.00, tmp_witness = ""
  DETAIL
   CASE (ce.event_cd)
    OF cs72_infusion_start_time_cd:
     tmp_inf_beg = cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD"),cnvtint(substring(
        11,6,ce.result_val))),tmp_inf_beg_by = trim(pr.name_full_formatted,3)
    OF cs72_infusion_end_time_cd:
     tmp_inf_end = cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD"),cnvtint(substring(
        11,6,ce.result_val))),tmp_inf_end_by = trim(pr.name_full_formatted,3)
    OF cs72_waste_amount_cd:
     tmp_waste = build2(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),3))
    OF cs72_patch_applied_time_cd:
     tmp_patch_beg = cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD"),cnvtint(
       substring(11,6,ce.result_val))),tmp_patch_beg_by = trim(pr.name_full_formatted,3)
    OF cs72_patch_removal_time_cd:
     tmp_patch_end = cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD"),cnvtint(
       substring(11,6,ce.result_val))),tmp_patch_end_by = trim(pr.name_full_formatted,3)
    OF cs72_nurse_witness_cd:
     tmp_witness = trim(ce.result_val,3)
   ENDCASE
  FOOT  form_ref_nbr
   IF ((work->encntrs[d1.seq].med_ords[med_order_slot].drug_form=cs4002_infusion_cd))
    IF ((work->encntrs[d1.seq].i_cnt <= 0))
     i_cnt = (work->encntrs[d1.seq].i_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs,i_cnt),
     work->encntrs[d1.seq].i_cnt = i_cnt,
     work->encntrs[d1.seq].ivs[i_cnt].med_order_slot = med_order_slot
    ELSEIF ((work->encntrs[d1.seq].ivs[i_cnt].med_order_slot != med_order_slot))
     i_cnt = (work->encntrs[d1.seq].i_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs,i_cnt),
     work->encntrs[d1.seq].i_cnt = i_cnt,
     work->encntrs[d1.seq].ivs[i_cnt].med_order_slot = med_order_slot
    ENDIF
    IF (tmp_inf_beg > 0.00)
     IF ((work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm > 0.00)
      AND (work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm != tmp_inf_beg))
      i_cnt = (work->encntrs[d1.seq].i_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs,i_cnt),
      work->encntrs[d1.seq].i_cnt = i_cnt,
      work->encntrs[d1.seq].ivs[i_cnt].med_order_slot = med_order_slot
     ENDIF
     work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm = tmp_inf_beg, work->encntrs[d1.seq].ivs[i_cnt].
     beg_dt_tm_disp = format(tmp_inf_beg,"MM/DD/YYYY HH:MM;;D"), work->encntrs[d1.seq].ivs[i_cnt].
     beg_doc_by = tmp_inf_beg_by,
     work->encntrs[d1.seq].ivs[i_cnt].beg_witness = tmp_witness
    ENDIF
    IF (tmp_inf_end > 0.00)
     IF ((work->encntrs[d1.seq].ivs[i_cnt].end_dt_tm > 0.00)
      AND (work->encntrs[d1.seq].ivs[i_cnt].end_dt_tm != tmp_inf_end))
      i_cnt = (work->encntrs[d1.seq].i_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs,i_cnt),
      work->encntrs[d1.seq].i_cnt = i_cnt,
      work->encntrs[d1.seq].ivs[i_cnt].med_order_slot = med_order_slot
     ENDIF
     work->encntrs[d1.seq].ivs[i_cnt].end_dt_tm = tmp_inf_end, work->encntrs[d1.seq].ivs[i_cnt].
     end_dt_tm_disp = format(tmp_inf_end,"MM/DD/YYYY HH:MM;;D"), work->encntrs[d1.seq].ivs[i_cnt].
     end_doc_by = tmp_inf_end_by,
     work->encntrs[d1.seq].ivs[i_cnt].end_witness = tmp_witness, work->encntrs[d1.seq].ivs[i_cnt].
     waste_amount = tmp_waste
    ENDIF
    IF ((work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm > 0.00)
     AND (work->encntrs[d1.seq].ivs[i_cnt].end_dt_tm > 0.00))
     work->encntrs[d1.seq].ivs[i_cnt].total_hrs = datetimediff(work->encntrs[d1.seq].ivs[i_cnt].
      end_dt_tm,work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm,3)
     IF ((work->encntrs[d1.seq].ivs[i_cnt].total_hrs > 24.00))
      work->encntrs[d1.seq].ivs[i_cnt].total_str = format(datetimediff(work->encntrs[d1.seq].ivs[
        i_cnt].end_dt_tm,work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm),"DD days HH hrs MM min;;Z")
     ELSE
      work->encntrs[d1.seq].ivs[i_cnt].total_str = format(datetimediff(work->encntrs[d1.seq].ivs[
        i_cnt].end_dt_tm,work->encntrs[d1.seq].ivs[i_cnt].beg_dt_tm),"HH hrs MM min;;Z")
     ENDIF
    ENDIF
   ENDIF
   IF ((work->encntrs[d1.seq].med_ords[med_order_slot].drug_form=cs4002_patch_cd))
    IF ((work->encntrs[d1.seq].p_cnt <= 0))
     p_cnt = (work->encntrs[d1.seq].p_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].patches,p_cnt),
     work->encntrs[d1.seq].p_cnt = p_cnt,
     work->encntrs[d1.seq].patches[p_cnt].med_order_slot = med_order_slot
    ELSEIF ((work->encntrs[d1.seq].patches[p_cnt].med_order_slot != med_order_slot))
     p_cnt = (work->encntrs[d1.seq].p_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].patches,p_cnt),
     work->encntrs[d1.seq].p_cnt = p_cnt,
     work->encntrs[d1.seq].patches[p_cnt].med_order_slot = med_order_slot
    ENDIF
    IF (tmp_patch_beg > 0.00)
     IF ((work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm > 0.00)
      AND (work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm != tmp_patch_beg))
      p_cnt = (work->encntrs[d1.seq].p_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].patches,p_cnt),
      work->encntrs[d1.seq].p_cnt = p_cnt,
      work->encntrs[d1.seq].patches[p_cnt].med_order_slot = med_order_slot
     ENDIF
     work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm = tmp_patch_beg, work->encntrs[d1.seq].patches[
     p_cnt].beg_dt_tm_disp = format(tmp_patch_beg,"MM/DD/YYYY HH:MM;;D"), work->encntrs[d1.seq].
     patches[p_cnt].beg_doc_by = tmp_patch_beg_by,
     work->encntrs[d1.seq].patches[p_cnt].beg_witness = tmp_witness
    ENDIF
    IF (tmp_patch_end > 0.00)
     IF ((work->encntrs[d1.seq].patches[p_cnt].end_dt_tm > 0.00)
      AND (work->encntrs[d1.seq].patches[p_cnt].end_dt_tm != tmp_patch_end))
      p_cnt = (work->encntrs[d1.seq].p_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].patches,p_cnt),
      work->encntrs[d1.seq].p_cnt = p_cnt,
      work->encntrs[d1.seq].patches[p_cnt].med_order_slot = med_order_slot
     ENDIF
     work->encntrs[d1.seq].patches[p_cnt].end_dt_tm = tmp_patch_end, work->encntrs[d1.seq].patches[
     p_cnt].end_dt_tm_disp = format(tmp_patch_end,"MM/DD/YYYY HH:MM;;D"), work->encntrs[d1.seq].
     patches[p_cnt].end_doc_by = tmp_patch_end_by,
     work->encntrs[d1.seq].patches[p_cnt].end_witness = tmp_witness
    ENDIF
    IF ((work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm > 0.00)
     AND (work->encntrs[d1.seq].patches[p_cnt].end_dt_tm > 0.00))
     work->encntrs[d1.seq].patches[p_cnt].total_hrs = datetimediff(work->encntrs[d1.seq].patches[
      p_cnt].end_dt_tm,work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm,3)
     IF ((work->encntrs[d1.seq].patches[p_cnt].total_hrs > 24.00))
      work->encntrs[d1.seq].patches[p_cnt].total_str = format(datetimediff(work->encntrs[d1.seq].
        patches[p_cnt].end_dt_tm,work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm),
       "DD days HH hrs MM min;;Z")
     ELSE
      work->encntrs[d1.seq].patches[p_cnt].total_str = format(datetimediff(work->encntrs[d1.seq].
        patches[p_cnt].end_dt_tm,work->encntrs[d1.seq].patches[p_cnt].beg_dt_tm),"HH hrs MM min;;Z")
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE SET tmp_inf_beg
 FREE SET tmp_inf_end
 FREE SET tmp_waste
 FREE SET tmp_patch_beg
 FREE SET tmp_patch_end
 FREE SET tmp_witness
 DECLARE tmp_user = vc
 SELECT INTO "NL:"
  FROM prsnl pr
  WHERE (pr.person_id=reqinfo->updt_id)
  DETAIL
   tmp_user = pr.username
  WITH nocounter
 ;end select
 SELECT INTO value( $VAR_OUTPUT)
  FROM dummyt d
  HEAD REPORT
   col_e_1 = 36, col_e_2 = (col_e_1+ 144), col_e_3 = (col_e_2+ 144),
   col_m_1 = (col_e_1+ 18), col_m_2 = (col_m_1+ 18), col_m_3 = (col_m_2+ 108),
   end_page = 756, row_size = 11, y_pos = 0,
   first_iv = 1, first_patch = 1, action_separator = fillstring(185,"-"),
   encntr_separator = fillstring(133,"_"),
   MACRO (macro_pat_info)
    col + 0,
    CALL print(calcpos(col_e_1,y_pos)), col + 0,
    CALL print(build2("{B}",work->encntrs[e].pat_name,"{ENDB}")), row + 1, col + 0,
    CALL print(calcpos(col_e_2,y_pos)), col + 0,
    CALL print(build2("Corp MRN: ",work->encntrs[e].corp_mrn)),
    row + 1, col + 0,
    CALL print(calcpos(col_e_3,y_pos)),
    col + 0,
    CALL print(build2("Acct Nbr: ",work->encntrs[e].acct_nbr)), row + 1,
    y_pos = (y_pos+ row_size)
   ENDMACRO
   ,
   MACRO (macro_med_info)
    col + 0,
    CALL print(calcpos(col_m_1,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].med_ords[m].order_desc," ordered on ",format(work->encntrs[e].
      med_ords[m].order_dt_tm,"MM/DD/YYYY HH:MM;;D"))), row + 1, y_pos = (y_pos+ row_size)
   ENDMACRO
   ,
   MACRO (macro_iv_info)
    col + 0,
    CALL print(calcpos(col_m_2,y_pos)), col + 0,
    CALL print("Infusion Begin Time:"), row + 1
    IF ((work->encntrs[e].ivs[i].beg_dt_tm <= 0.00))
     work->encntrs[e].ivs[i].beg_dt_tm_disp = "{B}Not Entered{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].ivs[i].beg_doc_by,3) <= " ")
     work->encntrs[e].ivs[i].beg_doc_by = "{B}Not Found{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].ivs[i].beg_witness,3) <= " ")
     work->encntrs[e].ivs[i].beg_witness = "{B}Not Entered{ENDB}"
    ENDIF
    col + 0,
    CALL print(calcpos(col_m_3,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].ivs[i].beg_dt_tm_disp," (Documented by ",work->encntrs[e].ivs[
     i].beg_doc_by,", Witnessed by ",work->encntrs[e].ivs[i].beg_witness,
     ")")), row + 1, y_pos = (y_pos+ row_size),
    col + 0,
    CALL print(calcpos(col_m_2,y_pos)), col + 0,
    CALL print("Infusion End Time:"), row + 1
    IF ((work->encntrs[e].ivs[i].end_dt_tm <= 0.00))
     work->encntrs[e].ivs[i].end_dt_tm_disp = "{B}Not Entered{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].ivs[i].end_doc_by,3) <= " ")
     work->encntrs[e].ivs[i].end_doc_by = "{B}Not Found{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].ivs[i].end_witness,3) <= " ")
     work->encntrs[e].ivs[i].end_witness = "{B}Not Entered{ENDB}"
    ENDIF
    col + 0,
    CALL print(calcpos(col_m_3,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].ivs[i].end_dt_tm_disp," (Documented by ",work->encntrs[e].ivs[
     i].end_doc_by,", Witnessed by ",work->encntrs[e].ivs[i].end_witness,
     ")")), row + 1, y_pos = (y_pos+ row_size),
    col + 0,
    CALL print(calcpos(col_m_2,y_pos)), col + 0,
    CALL print("Waste Amount:"), row + 1
    IF (trim(work->encntrs[e].ivs[i].waste_amount,3) <= " ")
     work->encntrs[e].ivs[i].waste_amount = "{B}Not Entered{ENDB}"
    ENDIF
    col + 0,
    CALL print(calcpos(col_m_3,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].ivs[i].waste_amount)), row + 1, y_pos = (y_pos+ row_size),
    col + 0,
    CALL print(calcpos(col_m_2,y_pos)), col + 0,
    CALL print("Total Infusion Time:"), row + 1
    IF ((work->encntrs[e].ivs[i].total_hrs <= 0.00))
     work->encntrs[e].ivs[i].total_hrs = 0.00, work->encntrs[e].ivs[i].total_str =
     "{B}Missing Infusion Begin or Infusion End Time{ENDB}"
    ENDIF
    col + 0,
    CALL print(calcpos(col_m_3,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].ivs[i].total_str)), row + 1, y_pos = (y_pos+ row_size)
   ENDMACRO
   ,
   MACRO (macro_patch_info)
    col + 0,
    CALL print(calcpos(col_m_2,y_pos)), col + 0,
    CALL print("Patch Applied Time:"), row + 1, col + 0,
    CALL print(calcpos(col_m_3,y_pos))
    IF ((work->encntrs[e].patches[p].beg_dt_tm <= 0.00))
     work->encntrs[e].patches[p].beg_dt_tm_disp = "{B}Not Entered{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].patches[p].beg_doc_by,3) <= " ")
     work->encntrs[e].patches[p].beg_doc_by = "{B}Not Found{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].patches[p].beg_witness,3) <= " ")
     work->encntrs[e].patches[p].beg_witness = "{B}Not Entered{ENDB}"
    ENDIF
    col + 0,
    CALL print(build2(work->encntrs[e].patches[p].beg_dt_tm_disp," (Documented by ",work->encntrs[e].
     patches[p].beg_doc_by,", Witnessed by ",work->encntrs[e].patches[p].beg_witness,
     ")")), row + 1,
    y_pos = (y_pos+ row_size), col + 0,
    CALL print(calcpos(col_m_2,y_pos)),
    col + 0,
    CALL print("Patch Removal Time:"), row + 1,
    col + 0,
    CALL print(calcpos(col_m_3,y_pos))
    IF ((work->encntrs[e].patches[p].end_dt_tm <= 0.00))
     work->encntrs[e].patches[p].end_dt_tm_disp = "{B}Not Entered{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].patches[p].end_doc_by,3) <= " ")
     work->encntrs[e].patches[p].end_doc_by = "{B}Not Found{ENDB}"
    ENDIF
    IF (trim(work->encntrs[e].patches[p].end_witness,3) <= " ")
     work->encntrs[e].patches[p].end_witness = "{B}Not Entered{ENDB}"
    ENDIF
    col + 0,
    CALL print(build2(format(work->encntrs[e].patches[p].end_dt_tm,"MM/DD/YYYY HH:MM;;D"),
     " (Documented by ",work->encntrs[e].patches[p].end_doc_by,", Witnessed by ",work->encntrs[e].
     patches[p].end_witness,
     ")")), row + 1,
    y_pos = (y_pos+ row_size), col + 0,
    CALL print(calcpos(col_m_2,y_pos)),
    col + 0,
    CALL print("Total Time:"), row + 1
    IF ((work->encntrs[e].patches[p].total_hrs <= 0.00))
     work->encntrs[e].patches[p].total_hrs = 0.00, work->encntrs[e].patches[p].total_str =
     "{B}Missing Patch Applied or Patch Removal Time{ENDB}"
    ENDIF
    col + 0,
    CALL print(calcpos(col_m_3,y_pos)), col + 0,
    CALL print(build2(work->encntrs[e].patches[p].total_str)), row + 1, y_pos = (y_pos+ row_size)
   ENDMACRO
  HEAD PAGE
   col 0, "{F/4}{CPI/15}{LPI/5}", row + 1,
   y_pos = (row_size * 3), first_iv = 1, first_patch = 1
  DETAIL
   FOR (e = 1 TO work->e_cnt)
     IF (((y_pos+ (row_size * 2)) > end_page))
      BREAK
     ENDIF
     macro_pat_info
     FOR (m = 1 TO work->encntrs[e].m_cnt)
       IF (((y_pos+ (row_size * 3)) > end_page))
        BREAK, macro_pat_info
       ENDIF
       y_pos = (y_pos+ (row_size/ 2)), macro_med_info
       IF ((work->encntrs[e].med_ords[m].drug_form=cs4002_infusion_cd))
        FOR (i = 1 TO work->encntrs[e].i_cnt)
          IF ((work->encntrs[e].ivs[i].med_order_slot=m))
           IF (((y_pos+ (row_size * 5)) > end_page))
            BREAK, macro_pat_info, macro_med_info
           ENDIF
           IF (first_iv=1)
            first_iv = 0
           ELSE
            col + 0,
            CALL print(calcpos(col_m_2,y_pos)), col + 0,
            CALL print(action_separator), row + 1, y_pos = (y_pos+ row_size)
           ENDIF
           macro_iv_info
          ENDIF
        ENDFOR
        y_pos = (y_pos+ row_size)
       ELSEIF ((work->encntrs[e].med_ords[m].drug_form=cs4002_patch_cd))
        FOR (p = 1 TO work->encntrs[e].p_cnt)
          IF ((work->encntrs[e].patches[p].med_order_slot=m))
           IF (((y_pos+ (row_size * 4)) > end_page))
            BREAK, macro_pat_info, macro_med_info
           ENDIF
           IF (first_patch=1)
            first_patch = 0
           ELSE
            col + 0,
            CALL print(calcpos(col_m_2,y_pos)), col + 0,
            CALL print(action_separator), row + 1, y_pos = (y_pos+ row_size)
           ENDIF
           macro_patch_info
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
     y_pos = (y_pos+ row_size)
   ENDFOR
   col + 0,
   CALL print(calcpos(col_e_1,(y_pos - (row_size/ 2)))), col + 0,
   CALL print(encntr_separator), row + 1
  FOOT PAGE
   col 0, "{F/4}{CPI/18}{LPI/6}", row + 1,
   y_pos = row_size, col + 0,
   CALL print(calcpos(36,y_pos)),
   col + 0, "{B}Narcotic Infusion Report{ENDB}", row + 1,
   col + 0,
   CALL print(calcpos(446,y_pos)), col + 0,
   CALL print(build2("{B}Report Range:  ",format(work->beg_dt_tm,"MM/DD/YYYY;;D")," thru ",format(
     work->end_dt_tm,"MM/DD/YYYY;;D"),"{ENDB}")), row + 1, col + 0,
   CALL print(calcpos(36,752)), col + 0,
   CALL print(build2("{B}",curprog,"{ENDB}")),
   row + 1, col + 0,
   CALL print(calcpos(216,752)),
   col + 0,
   CALL print(build2("{B}Page ",trim(build2(curpage),3),"{ENDB}")), row + 1,
   col + 0,
   CALL print(calcpos(450,752)), col + 0,
   CALL print(build2("{B}Printed on ",format(curdate,"MM/DD/YY;;D")," ",cnvtupper(format(curtime,
      "HH:MM;;S"))," by ",
    tmp_user,"{ENDB}")), row + 1
  WITH dio = 08, maxcol = 32000, maxrow = 300,
   format = variable, nocounter
 ;end select
#exit_script
END GO
