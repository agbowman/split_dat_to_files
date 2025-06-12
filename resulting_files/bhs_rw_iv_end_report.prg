CREATE PROGRAM bhs_rw_iv_end_report
 FREE RECORD work
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 patient_name = vc
     2 cmrn = vc
     2 acct_nbr = vc
     2 birth_dt_tm = dq8
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 ce_m_cnt = i4
     2 m_cnt = i4
     2 meds[*]
       3 o_cnt = i4
       3 orders[*]
         4 order_id = f8
       3 order_desc = vc
       3 ordered_by = vc
       3 order_phys = vc
       3 med_type = f8
       3 template_ind = i2
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 beg_dt_tm_disp = vc
       3 end_dt_tm_disp = vc
       3 total_hrs = f8
       3 d_cnt = i4
       3 details[*]
         4 desc = vc
         4 type = vc
         4 text = vc
         4 num = f8
         4 dt_tm = dq8
       3 error_ind = i2
       3 e_cnt = i4
       3 errors[*]
         4 bag_slot = i4
         4 action_slot = i4
         4 desc = vc
         4 lvl = i4
       3 b_cnt = i4
       3 bags[*]
         4 bag_num = i4
         4 infuse_ind = i2
         4 total_hrs = f8
         4 error_ind = i2
         4 ba_cnt = i4
         4 bag_actions[*]
           5 action_slot = i4
       3 a_cnt = i4
       3 actions[*]
         4 desc = vc
         4 dose = f8
         4 dose_unit = vc
         4 rate = f8
         4 rate_unit = vc
         4 site = vc
         4 d_cnt = i4
         4 diluents[*]
           5 event_id = f8
           5 desc = vc
           5 dose = f8
           5 dose_unit = vc
           5 volume = f8
           5 volume_unit = vc
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 beg_dt_tm_disp = vc
         4 end_dt_tm_disp = vc
         4 beg_not_done_ind = i2
         4 end_not_done_ind = i2
         4 total_hrs = f8
         4 print_hrs_ind = i2
         4 error_ind = i2
         4 action_dt_tm = dq8
         4 username = vc
 )
 DECLARE temp_str = vc
 DECLARE beg_pos = i4
 DECLARE end_pos = i4
 RECORD wrap_return(
   1 l_cnt = i4
   1 lines[*]
     2 text = vc
 )
 DECLARE rw_wrap(orig_str=vc,line_len=i4,indent_size=i4) = null
 SUBROUTINE rw_wrap(orig_str,line_len,indent_size)
   SET temp_str = trim(orig_str,1)
   SET beg_pos = 1
   SET end_pos = 0
   SET wrap_return->l_cnt = 0
   SET stat = alterlist(wrap_return->lines,0)
   WHILE (beg_pos > 0
    AND beg_pos <= size(temp_str))
     IF (findstring(char(10),substring(beg_pos,line_len,temp_str),1,0) > 0)
      SET end_pos = findstring(char(10),substring(beg_pos,line_len,temp_str),1,0)
     ELSEIF (substring((beg_pos+ line_len),1,temp_str)=" ")
      SET end_pos = (line_len+ 1)
     ELSEIF (findstring(" ",substring(beg_pos,line_len,temp_str),1,1)=0)
      SET end_pos = line_len
     ELSE
      SET end_pos = findstring(" ",substring(beg_pos,line_len,temp_str),1,1)
     ENDIF
     SET wrap_return->l_cnt = (wrap_return->l_cnt+ 1)
     SET stat = alterlist(wrap_return->lines,wrap_return->l_cnt)
     SET wrap_return->lines[wrap_return->l_cnt].text = trim(substring(beg_pos,end_pos,temp_str))
     IF (beg_pos=1)
      SET line_len = (line_len - indent_size)
     ELSE
      FOR (rw_x = 1 TO indent_size)
        SET wrap_return->lines[wrap_return->l_cnt].text = build2(" ",wrap_return->lines[wrap_return->
         l_cnt].text)
      ENDFOR
     ENDIF
     SET beg_pos = (beg_pos+ end_pos)
   ENDWHILE
 END ;Subroutine
 DECLARE err_msg = vc
 DECLARE var_output = vc
 IF (validate(request->visit[1].encntr_id,0.00) <= 0.00)
  IF (reflect(parameter(1,0)) > " ")
   SET var_output = parameter(1,0)
  ELSE
   SET err_msg = build2("No output location found ($1 = ",parameter(1,0),"). Exitting Script")
   GO TO exit_script
  ENDIF
  IF (reflect(parameter(2,0)) > " "
   AND cnvtreal(parameter(2,0)) > 0.00)
   SET work->e_cnt = 1
   SET stat = alterlist(work->encntrs,1)
   SET work->encntrs[1].encntr_id = cnvtreal(parameter(2,0))
  ELSE
   SET err_msg = build2("No ENCNTR_ID given ($2 = ",parameter(2,0),"). Exitting Script")
   GO TO exit_script
  ENDIF
  IF (reflect(parameter(3,0)) > " "
   AND cnvtdatetime(parameter(3,0),0) > 0.00)
   SET work->beg_dt_tm = cnvtdatetime(parameter(3,0),0)
  ELSE
   SET err_msg = build2("No Begin Date given ($3 = ",parameter(3,0),"). Exitting Script")
   GO TO exit_script
  ENDIF
  IF (reflect(parameter(4,0)) > " "
   AND cnvtdatetime(parameter(4,0),235959) > 0.00)
   SET work->end_dt_tm = cnvtdatetime(parameter(4,0),235959)
  ELSE
   SET err_msg = build2("No End Date given ($4 = ",parameter(4,0),"). Exitting Script")
   GO TO exit_script
  ENDIF
 ELSE
  IF (trim(request->output_device,3) > " ")
   SET var_output = request->output_device
  ELSE
   SET err_msg = build2("No output location found ($1 = ",parameter(1,0),"). Exitting Script")
   GO TO exit_script
  ENDIF
  IF (validate(request->visit[1].encntr_id,0.00) <= 0.00)
   IF (reflect(parameter(2,0)) > " ")
    SET work->e_cnt = (work->e_cnt+ 1)
    SET stat = alterlist(work->encntrs,work->e_cnt)
    SET work->encntrs[work->e_cnt].encntr_id = cnvtreal(parameter(2,0))
   ELSE
    SET err_msg = build2("No ENCNTR_ID given ($2 = ",parameter(2,0),"). Exitting Script")
    GO TO exit_script
   ENDIF
   IF (reflect(parameter(3,0)) > " "
    AND cnvtdatetime(parameter(3,0),0) > 0.00)
    SET work->beg_dt_tm = cnvtdatetime(parameter(3,0),0)
   ELSE
    SET err_msg = build2("No Begin Date given ($3 = ","). Exitting Script")
    GO TO exit_script
   ENDIF
   IF (reflect(parameter(4,0)) > " "
    AND cnvtdatetime(parameter(4,0),235959) > 0.00)
    SET work->end_dt_tm = cnvtdatetime(parameter(4,0),235959)
   ELSE
    SET err_msg = build2("No End Date given ($4 = ",parameter(4,0),"). Exitting Script")
    GO TO exit_script
   ENDIF
  ELSE
   FOR (e = 1 TO size(request->visit,5))
     IF ((request->visit[e].encntr_id > 0.00))
      SET work->e_cnt = (work->e_cnt+ 1)
      SET stat = alterlist(work->encntrs,work->e_cnt)
      SET work->encntrs[work->e_cnt].encntr_id = request->visit[e].encntr_id
     ENDIF
   ENDFOR
   IF ((work->e_cnt <= 0))
    SET err_msg = build2("No ENCNTR_ID given. Exitting Script")
    GO TO exit_script
   ENDIF
   IF (size(request->nv,5) <= 0)
    SET err_msg = "No Begin or End Date given. Exitting Script"
    GO TO exit_script
   ELSE
    FOR (nv = 1 TO size(request->nv,5))
      IF ((request->nv[nv].pvc_name="BEG_DT_TM"))
       IF (cnvtdatetime(build2(request->nv[nv].pvc_value," 00:00:00")) > 0.00)
        SET work->beg_dt_tm = cnvtdatetime(build2(request->nv[nv].pvc_value," 00:00:00"))
       ELSE
        SET err_msg = build2("Invalid Begin Date given (BEG_DT_TM = ",request->nv[nv].pvc_value,
         "). Exitting Script")
        GO TO exit_script
       ENDIF
      ELSEIF ((request->nv[nv].pvc_name="END_DT_TM"))
       IF (cnvtdatetime(build2(request->nv[nv].pvc_value," 23:59:59")) > 0.00)
        SET work->end_dt_tm = cnvtdatetime(build2(request->nv[nv].pvc_value," 23:59:59"))
       ELSE
        SET err_msg = build2("Invalid End Date given (END_DT_TM = ",request->nv[nv].pvc_value,
         "). Exitting Script")
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 DECLARE cs4_cmrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SELECT INTO "NL:"
  e.encntr_id
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (d)
   JOIN (e
   WHERE (work->encntrs[d.seq].encntr_id=e.encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE outerjoin(p.person_id)=pa.person_id
    AND pa.person_alias_type_cd=outerjoin(cs4_cmrn_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ea
   WHERE outerjoin(e.encntr_id)=ea.encntr_id
    AND ea.encntr_alias_type_cd=outerjoin(cs319_fin_cd)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD e.encntr_id
   work->encntrs[d.seq].patient_name = p.name_full_formatted, work->encntrs[d.seq].birth_dt_tm = p
   .birth_dt_tm, work->encntrs[d.seq].cmrn = trim(pa.alias),
   work->encntrs[d.seq].acct_nbr = build2(trim(ea.alias)," (",trim(uar_get_code_display(e.location_cd
      ),3)," - ",trim(uar_get_code_display(e.encntr_type_cd),3),
    ")"), work->encntrs[d.seq].admit_dt_tm = e.reg_dt_tm, work->encntrs[d.seq].disch_dt_tm = e
   .disch_dt_tm
  WITH nocounter
 ;end select
 DECLARE cs6000_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE cs6003_order_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6004_pending_rev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE cs14003_ivpb_end_dt_tm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "IVPBENDORTRANSFERDATETIME"))
 DECLARE cs14003_ivpb_status_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"IVPBSTATUS"))
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   orders o,
   order_detail od,
   order_action oa1,
   prsnl pr1,
   prsnl pr2,
   order_action oa2
  PLAN (d1)
   JOIN (o
   WHERE (work->encntrs[d1.seq].encntr_id=o.encntr_id)
    AND o.catalog_type_cd=cs6000_pharmacy_cd
    AND o.orig_order_dt_tm <= cnvtdatetime(work->end_dt_tm)
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag IN (0, 2, 8, 32))
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.action_sequence >= 0
    AND od.detail_sequence >= 0
    AND od.oe_field_meaning="RXROUTE"
    AND od.oe_field_display_value IN ("IV Infusion", "IVPB"))
   JOIN (oa1
   WHERE o.order_id=oa1.order_id
    AND oa1.action_sequence=1)
   JOIN (pr1
   WHERE oa1.action_personnel_id=pr1.person_id)
   JOIN (pr2
   WHERE oa1.order_provider_id=pr2.person_id)
   JOIN (oa2
   WHERE o.order_id=oa2.order_id
    AND ((oa2.order_status_cd IN (cs6004_ordered_cd, cs6004_inprocess_cd, cs6004_pending_cd,
   cs6004_pending_rev_cd)) OR (oa2.order_status_cd IN (cs6004_completed_cd, cs6004_discontinued_cd)
    AND oa2.action_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm))) )
  ORDER BY d1.seq, o.order_mnemonic, o.orig_order_dt_tm,
   o.order_id, oa2.action_sequence DESC
  HEAD REPORT
   m_cnt = 0
  HEAD d1.seq
   m_cnt = 0
  HEAD o.order_id
   m_cnt = (work->encntrs[d1.seq].m_cnt+ 1), work->encntrs[d1.seq].m_cnt = m_cnt, stat = alterlist(
    work->encntrs[d1.seq].meds,m_cnt),
   work->encntrs[d1.seq].meds[m_cnt].o_cnt = 1, stat = alterlist(work->encntrs[d1.seq].meds[m_cnt].
    orders,1), work->encntrs[d1.seq].meds[m_cnt].orders[1].order_id = o.order_id,
   work->encntrs[d1.seq].meds[m_cnt].template_ind = o.template_order_flag, work->encntrs[d1.seq].
   meds[m_cnt].order_desc = trim(o.ordered_as_mnemonic,3), work->encntrs[d1.seq].meds[m_cnt].
   ordered_by = trim(pr1.name_full_formatted,3),
   work->encntrs[d1.seq].meds[m_cnt].order_phys = trim(pr2.name_full_formatted,3), work->encntrs[d1
   .seq].meds[m_cnt].beg_dt_tm = o.orig_order_dt_tm, work->encntrs[d1.seq].meds[m_cnt].beg_dt_tm_disp
    = format(o.orig_order_dt_tm,"MM/DD/YY HH:MM;;D")
   IF (oa2.order_status_cd IN (cs6004_completed_cd, cs6004_discontinued_cd))
    work->encntrs[d1.seq].meds[m_cnt].end_dt_tm = oa2.action_dt_tm
    IF (o.discontinue_ind > 0)
     work->encntrs[d1.seq].meds[m_cnt].end_dt_tm_disp = build2(format(oa2.action_dt_tm,
       "MM/DD/YY HH:MM;;D"),"  (",trim(uar_get_code_display(o.discontinue_type_cd),3),")")
    ELSE
     work->encntrs[d1.seq].meds[m_cnt].end_dt_tm_disp = build2(format(oa2.action_dt_tm,
       "MM/DD/YY HH:MM;;D"),"  (",trim(uar_get_code_display(oa2.order_status_cd),3),")")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  o.order_id
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].template_ind=1))
   JOIN (o
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id=o.template_order_id))
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (work->encntrs[d1.seq].meds[d2.seq].o_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].o_cnt =
   o_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].orders,o_cnt),
   work->encntrs[d1.seq].meds[d2.seq].orders[o_cnt].order_id = o.order_id
  WITH nocounter
 ;end select
 DECLARE cs16449_med_diluent_type_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "MEDICATIONDILUENT"))
 DECLARE cs16449_limited_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"LIMITATIONS"))
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (od
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id=od.order_id)
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE", "DURATION", "DURATIONUNIT", "SCH/PRN", "DISPENSEQTY",
   "DISPENSEQTYUNIT", "SPECINX")) OR (od.oe_field_id IN (cs16449_med_diluent_type_cd,
   cs16449_limited_cd))) )
  ORDER BY d1.seq, d2.seq, od.action_sequence,
   od.detail_sequence
  HEAD REPORT
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d1.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d2.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  DETAIL
   IF (od.oe_field_meaning="STRENGTHDOSE")
    strength_ind = 1
   ENDIF
   IF ((work->encntrs[d1.seq].meds[d2.seq].d_cnt > 0))
    d_cnt = 0, stat = locateval(d_cnt,1,work->encntrs[d1.seq].meds[d2.seq].d_cnt,od.oe_field_meaning,
     work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].desc)
   ENDIF
   IF (((d_cnt=0) OR ((od.oe_field_meaning != work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].desc)
   )) )
    d_cnt = (work->encntrs[d1.seq].meds[d2.seq].d_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].d_cnt
     = d_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].details,d_cnt)
   ENDIF
   work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].desc = od.oe_field_meaning, work->encntrs[d1.seq
   ].meds[d2.seq].details[d_cnt].text = trim(od.oe_field_display_value,3), work->encntrs[d1.seq].
   meds[d2.seq].details[d_cnt].num = od.oe_field_value,
   work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].dt_tm = od.oe_field_dt_tm_value
   IF (od.oe_field_dt_tm_value > 0.00)
    work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].type = "DQ8"
   ELSEIF (trim(od.oe_field_display_value,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].type = "VC"
   ELSE
    IF (((abs(od.oe_field_value) - abs(cnvtint(od.oe_field_value))) > 0.00))
     work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].type = "F8"
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].details[d_cnt].type = "I4"
    ENDIF
   ENDIF
  FOOT  d2.seq
   FOR (d = 1 TO work->encntrs[d1.seq].meds[d2.seq].d_cnt)
     detail_ind = 1
     IF ((work->encntrs[d1.seq].meds[d2.seq].details[d].desc IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT")))
      IF (strength_ind=0)
       work->encntrs[d1.seq].meds[d2.seq].order_desc = build2(work->encntrs[d1.seq].meds[d2.seq].
        order_desc," ",trim(work->encntrs[d1.seq].meds[d2.seq].details[d].text,3))
      ENDIF
      detail_ind = 0
     ENDIF
     IF (detail_ind=1
      AND (work->encntrs[d1.seq].meds[d2.seq].details[d].desc="SCH/PRN"))
      IF ((work->encntrs[d1.seq].meds[d2.seq].details[d].text="Yes"))
       work->encntrs[d1.seq].meds[d2.seq].order_desc = build2(work->encntrs[d1.seq].meds[d2.seq].
        order_desc," PRN")
      ENDIF
      detail_ind = 0
     ENDIF
     IF (detail_ind=1)
      work->encntrs[d1.seq].meds[d2.seq].order_desc = build2(work->encntrs[d1.seq].meds[d2.seq].
       order_desc," ",trim(work->encntrs[d1.seq].meds[d2.seq].details[d].text,3))
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cs53_med_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE cs53_placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE cs72_ivparent_cd = f8 WITH constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cs180_begin_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE cs180_bolus_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE cs180_infuse_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE cs180_ratechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE cs180_sitechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"SITECHG"))
 DECLARE cs180_waste_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"WASTE"))
 SELECT INTO "NL:"
  cmr1.substance_lot_number, ce1_collating_seq = cnvtint(substring(13,3,ce1.collating_seq)),
  ce2_collating_seq = cnvtint(substring(13,3,ce2.collating_seq))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   ce_med_result cmr1,
   clinical_event ce2,
   prsnl pr,
   ce_med_result cmr2
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE maxrec(d3,work->encntrs[d1.seq].meds[d2.seq].o_cnt))
   JOIN (d3)
   JOIN (ce1
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id=ce1.order_id)
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce1.event_title_text="IVPARENT"
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr1
   WHERE ce1.event_id=cmr1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.event_end_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm)
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE ce2.performed_prsnl_id=pr.person_id)
   JOIN (cmr2
   WHERE ce2.event_id=cmr2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ce1.encntr_id, ce1.order_id, ce1.event_end_dt_tm,
   ce2.event_end_dt_tm, ce1_collating_seq, ce2_collating_seq
  HEAD REPORT
   b_cnt = 0, ba_cnt = 0, a_cnt = 0,
   d_cnt = 0
  HEAD ce1.order_id
   work->encntrs[d1.seq].meds[d2.seq].med_type = 1, work->encntrs[d1.seq].ce_m_cnt = (work->encntrs[
   d1.seq].ce_m_cnt+ 1), b_cnt = 0,
   ba_cnt = 0, a_cnt = 0, d_cnt = 0
  HEAD cmr1.substance_lot_number
   b_cnt = (work->encntrs[d1.seq].meds[d2.seq].b_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].bags,b_cnt), work->encntrs[d1.seq].meds[d2.seq].b_cnt = b_cnt,
   work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].bag_num = cnvtint(cmr1.substance_lot_number)
  HEAD ce1.event_id
   ba_cnt = 0, a_cnt = 0, d_cnt = 0
  HEAD ce2.event_end_dt_tm
   a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].actions,a_cnt), work->encntrs[d1.seq].meds[d2.seq].a_cnt = a_cnt,
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = uar_get_code_display(cmr2.iv_event_cd),
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].action_dt_tm = ce2.performed_dt_tm, work->
   encntrs[d1.seq].meds[d2.seq].actions[a_cnt].username = trim(pr.name_full_formatted,3),
   ba_cnt = (work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].ba_cnt+ 1), stat = alterlist(work->
    encntrs[d1.seq].meds[d2.seq].bags[b_cnt].bag_actions,ba_cnt), work->encntrs[d1.seq].meds[d2.seq].
   bags[b_cnt].ba_cnt = ba_cnt,
   work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].bag_actions[ba_cnt].action_slot = a_cnt
   IF (cmr2.iv_event_cd=cs180_begin_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr1.initial_volume, work->encntrs[d1
    .seq].meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr1.infused_volume_unit_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate = cmr1.infusion_rate,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate_unit = uar_get_code_display(cmr1
     .infusion_unit_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site =
    uar_get_code_display(cmr2.admin_site_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].
    beg_dt_tm = ce2.event_end_dt_tm,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A"
    IF (((ce2.event_end_dt_tm=null) OR (ce2.event_end_dt_tm <= 0.00)) )
     work->encntrs[d1.seq].meds[d2.seq].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}", work->encntrs[d1
     .seq].meds[d2.seq].actions[a_cnt].error_ind = 1, e_cnt = (work->encntrs[d1.seq].meds[d2.seq].
     e_cnt+ 1),
     stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt), work->encntrs[d1.seq].meds[d2
     .seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].bag_slot = b_cnt,
     work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a_cnt, work->encntrs[d1.seq].
     meds[d2.seq].errors[e_cnt].desc = "Begin Bag without date/time", work->encntrs[d1.seq].meds[d2
     .seq].errors[e_cnt].lvl = 0
    ENDIF
   ELSEIF (cmr2.iv_event_cd=cs180_sitechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm, work->encntrs[
    d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A"
   ELSEIF (cmr2.iv_event_cd=cs180_ratechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].rate = cmr1.infusion_rate, work->encntrs[d1.seq
    ].meds[d2.seq].actions[a_cnt].rate_unit = uar_get_code_display(cmr1.infusion_unit_cd), work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2.event_end_dt_tm,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_end_dt_tm,
     "MM/DD/YY HH:MM;;D"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = "N/A"
   ELSEIF (cmr2.iv_event_cd IN (cs180_infuse_cd, cs180_bolus_cd))
    work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].infuse_ind = 1, work->encntrs[d1.seq].meds[d2.seq]
    .actions[a_cnt].print_hrs_ind = 1, work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr2
    .admin_dosage,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr2
     .dosage_unit_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(
     cmr2.admin_site_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce2
    .event_start_dt_tm,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm, work->encntrs[
    d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce2.event_start_dt_tm,
     "MM/DD/YY HH:MM;;D"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = format(
     ce2.event_end_dt_tm,"MM/DD/YY HH:MM;;D")
    IF (((ce2.event_start_dt_tm=null) OR (((ce2.event_start_dt_tm <= 0.00) OR (ce2.event_start_dt_tm=
    ce2.event_end_dt_tm)) )) )
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}",
     work->encntrs[d1.seq].meds[d2.seq].error_ind = 1, work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt]
     .error_ind = 1,
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].error_ind = 1, e_cnt = (work->encntrs[d1.seq].
     meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt),
     work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[
     e_cnt].bag_slot = b_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a_cnt,
     work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].desc = "Infuse without Start date/time", work->
     encntrs[d1.seq].meds[d2.seq].errors[e_cnt].lvl = 1
    ENDIF
    IF (((ce2.event_end_dt_tm=null) OR (ce2.event_end_dt_tm <= 0.00)) )
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}",
     work->encntrs[d1.seq].meds[d2.seq].error_ind = 1, work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt]
     .error_ind = 1,
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].error_ind = 1, e_cnt = (work->encntrs[d1.seq].
     meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt),
     work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[
     e_cnt].bag_slot = b_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a_cnt,
     work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].desc = "Infuse without End date/time", work->
     encntrs[d1.seq].meds[d2.seq].errors[e_cnt].lvl = 1
    ENDIF
    IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].error_ind=0))
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].total_hrs = datetimediff(ce2.event_end_dt_tm,
      ce2.event_start_dt_tm,3)
     IF ((work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].error_ind=0))
      work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].total_hrs = (work->encntrs[d1.seq].meds[d2.seq].
      bags[b_cnt].total_hrs+ work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].total_hrs)
      IF ((work->encntrs[d1.seq].meds[d2.seq].error_ind=0))
       work->encntrs[d1.seq].meds[d2.seq].total_hrs = (work->encntrs[d1.seq].meds[d2.seq].total_hrs+
       work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].total_hrs)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (cmr2.iv_event_cd=cs180_waste_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].dose = cmr2.remaining_volume, work->encntrs[d1
    .seq].meds[d2.seq].actions[a_cnt].dose_unit = uar_get_code_display(cmr2.remaining_volume_unit_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].site = uar_get_code_display(cmr2.admin_site_cd),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm = ce2.event_end_dt_tm, work->encntrs[
    d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = "N/A", work->encntrs[d1.seq].meds[d2.seq].
    actions[a_cnt].end_dt_tm_disp = format(ce2.event_end_dt_tm,"MM/DD/YY HH:MM;;D")
   ENDIF
  HEAD ce2.event_id
   d_cnt = (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].d_cnt+ 1), stat = alterlist(work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents,d_cnt), work->encntrs[d1.seq].meds[d2.seq].
   actions[a_cnt].d_cnt = d_cnt,
   work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(cmr2
    .diluent_type_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume =
   cmr2.initial_volume, work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume_unit
    = uar_get_code_display(cmr2.infused_volume_unit_cd)
   IF (cmr2.dosage_unit_cd != cmr2.infused_volume_unit_cd)
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose = cmr2.initial_dosage,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose_unit =
    uar_get_code_display(cmr2.dosage_unit_cd)
   ENDIF
  FOOT  cmr1.substance_lot_number
   IF ((work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].infuse_ind=0))
    work->encntrs[d1.seq].meds[d2.seq].error_ind = 1, work->encntrs[d1.seq].meds[d2.seq].bags[b_cnt].
    error_ind = 1, e_cnt = (work->encntrs[d1.seq].meds[d2.seq].e_cnt+ 1),
    stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt), work->encntrs[d1.seq].meds[d2
    .seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].bag_slot = b_cnt,
    work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a_cnt, work->encntrs[d1.seq].meds[
    d2.seq].errors[e_cnt].desc = "Bag without Infusion", work->encntrs[d1.seq].meds[d2.seq].errors[
    e_cnt].lvl = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ce1.event_id, ce1_sort =
  IF (ce1.task_assay_cd=0.00
   AND ce1.event_start_dt_tm != null) format(ce1.event_start_dt_tm,"YYYYMMDDHHMMSSCC;;D")
  ELSEIF (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd
   AND ce1.result_status_cd != cs8_not_done_cd) substring(3,16,ce1.result_val)
  ELSE format(ce1.event_end_dt_tm,"YYYYMMDDHHMMSSCC;;D")
  ENDIF
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   prsnl pr,
   clinical_event ce2,
   ce_med_result cmr
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].med_type=0.00)
    AND maxrec(d3,work->encntrs[d1.seq].meds[d2.seq].o_cnt))
   JOIN (d3)
   JOIN (ce1
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id=ce1.order_id)
    AND ((ce1.event_class_cd=cs53_med_cd) OR (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd))
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_not_done_cd)
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE ce1.performed_prsnl_id=pr.person_id)
   JOIN (ce2
   WHERE outerjoin(ce1.parent_event_id)=ce2.parent_event_id
    AND ce2.task_assay_cd=outerjoin(cs14003_ivpb_status_cd)
    AND ce2.result_status_cd=outerjoin(ce1.result_status_cd)
    AND ce2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (cmr
   WHERE outerjoin(ce1.event_id)=cmr.event_id
    AND cmr.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d1.seq, d2.seq, ce1_sort,
   ce1.event_id
  HEAD REPORT
   tmp_a1 = 0, tmp_a2 = 0, a_cnt = 0,
   d_cnt = 0, e_cnt = 0
  HEAD d1.seq
   a_cnt = 0, d_cnt = 0, e_cnt = 0
  HEAD d2.seq
   a_cnt = 0, d_cnt = 0, e_cnt = 0
  HEAD ce1_sort
   IF ((work->encntrs[d1.seq].meds[d2.seq].a_cnt <= 0))
    a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
     = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].print_hrs_ind = 1
   ENDIF
   d_cnt = 0, e_cnt = 0
  HEAD ce1.event_id
   work->encntrs[d1.seq].meds[d2.seq].med_type = 2, work->encntrs[d1.seq].ce_m_cnt = (work->encntrs[
   d1.seq].ce_m_cnt+ 1), a_cnt = work->encntrs[d1.seq].meds[d2.seq].a_cnt
   IF (ce1.task_assay_cd <= 0.00)
    IF ((((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm > 0.00)
     AND (ce1.event_end_dt_tm != work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm)) OR ((
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_not_done_ind=1))) )
     a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
      = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt),
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].print_hrs_ind = 1
    ENDIF
    IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm <= 0.00))
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = "Admin", work->encntrs[d1.seq].meds[d2
     .seq].actions[a_cnt].site = uar_get_code_display(cmr.admin_site_cd), work->encntrs[d1.seq].meds[
     d2.seq].actions[a_cnt].action_dt_tm = ce1.performed_dt_tm,
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].username = trim(pr.name_full_formatted,3)
     IF (ce1.result_status_cd=cs8_not_done_cd)
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].print_hrs_ind = 0, work->encntrs[d1.seq].
      meds[d2.seq].actions[a_cnt].beg_not_done_ind = 1, work->encntrs[d1.seq].meds[d2.seq].actions[
      a_cnt].end_not_done_ind = 1,
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = build("{B}",trim(ce1
        .event_tag,3),"{ENDB}"), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp =
      "N/A", work->encntrs[d1.seq].meds[d2.seq].error_ind = 1,
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].error_ind = 1, e_cnt = (work->encntrs[d1.seq]
      .meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt),
      work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[
      e_cnt].action_slot = a_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].desc =
      "Admin Not Done",
      work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].lvl = 1
     ELSE
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm = ce1.event_end_dt_tm, work->
      encntrs[d1.seq].meds[d2.seq].actions[a_cnt].beg_dt_tm_disp = format(ce1.event_end_dt_tm,
       "MM/DD/YY HH:MM;;D")
     ENDIF
    ENDIF
    d_cnt = (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].d_cnt+ 1), work->encntrs[d1.seq].meds[
    d2.seq].actions[a_cnt].d_cnt = d_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].
     actions[a_cnt].diluents,d_cnt),
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].event_id = cmr.event_id, work->
    encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].desc = uar_get_code_display(ce1
     .event_cd), work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose = cmr
    .admin_dosage,
    work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].dose_unit =
    uar_get_code_display(cmr.dosage_unit_cd)
    IF (cmr.dosage_unit_cd != cmr.infused_volume_unit_cd)
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume = cmr.initial_dosage,
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].diluents[d_cnt].volume_unit =
     uar_get_code_display(cmr.infused_volume_unit_cd)
    ENDIF
   ELSEIF (ce1.task_assay_cd=cs14003_ivpb_end_dt_tm_cd)
    IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm > 0.00)
     AND (work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_not_done_ind=0))
     a_cnt = (work->encntrs[d1.seq].meds[d2.seq].a_cnt+ 1), work->encntrs[d1.seq].meds[d2.seq].a_cnt
      = a_cnt, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].actions,a_cnt),
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].desc = "Admin", work->encntrs[d1.seq].meds[d2
     .seq].actions[a_cnt].username = trim(pr.name_full_formatted,3), work->encntrs[d1.seq].meds[d2
     .seq].actions[a_cnt].print_hrs_ind = 1
    ENDIF
    IF (ce1.result_status_cd=cs8_not_done_cd)
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].print_hrs_ind = 0, work->encntrs[d1.seq].meds[
     d2.seq].actions[a_cnt].end_not_done_ind = 1, work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].
     end_dt_tm_disp = build("{B}",trim(ce1.event_tag,3),"{ENDB}"),
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].error_ind = 1, e_cnt = (work->encntrs[d1.seq].
     meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].errors,e_cnt),
     work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[
     e_cnt].action_slot = a_cnt, work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].desc =
     "IVPB End Not Done",
     work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].lvl = 1
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(substring(7,2,ce1
       .result_val),"/",substring(9,2,ce1.result_val),"/",substring(5,2,ce1.result_val),
      " ",substring(11,2,ce1.result_val),":",substring(13,2,ce1.result_val)), work->encntrs[d1.seq].
     meds[d2.seq].actions[a_cnt].end_dt_tm = cnvtdatetime(cnvtdate2(substring(1,10,work->encntrs[d1
        .seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp),"MM/DD/YY"),cnvtint(substring(11,6,ce1
        .result_val)))
     IF (ce2.clinical_event_id > 0.00)
      work->encntrs[d1.seq].meds[d2.seq].actions[a_cnt].end_dt_tm_disp = build2(work->encntrs[d1.seq]
       .meds[d2.seq].actions[a_cnt].end_dt_tm_disp," (",trim(ce2.result_val,3),")")
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce1_sort
   d_cnt = 0, e_cnt = 0
  FOOT  d2.seq
   FOR (a = 1 TO work->encntrs[d1.seq].meds[d2.seq].a_cnt)
     IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_dt_tm <= 0.00)
      AND (work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_not_done_ind=0))
      work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_dt_tm_disp = "{B}*** Missing ***{ENDB}", work
      ->encntrs[d1.seq].meds[d2.seq].error_ind = 1, work->encntrs[d1.seq].meds[d2.seq].actions[a].
      error_ind = 1,
      e_cnt = (work->encntrs[d1.seq].meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
       meds[d2.seq].errors,e_cnt), work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt,
      work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a, work->encntrs[d1.seq].meds[d2
      .seq].errors[e_cnt].desc = "Admin without Start date/time", work->encntrs[d1.seq].meds[d2.seq].
      errors[e_cnt].lvl = 1
     ENDIF
     IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a].end_dt_tm <= 0.00)
      AND (work->encntrs[d1.seq].meds[d2.seq].actions[a].end_not_done_ind=0))
      work->encntrs[d1.seq].meds[d2.seq].actions[a].end_dt_tm_disp = "{B}*** Missing ***{ENDB}", work
      ->encntrs[d1.seq].meds[d2.seq].error_ind = 1, work->encntrs[d1.seq].meds[d2.seq].actions[a].
      error_ind = 1,
      e_cnt = (work->encntrs[d1.seq].meds[d2.seq].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
       meds[d2.seq].errors,e_cnt), work->encntrs[d1.seq].meds[d2.seq].e_cnt = e_cnt,
      work->encntrs[d1.seq].meds[d2.seq].errors[e_cnt].action_slot = a, work->encntrs[d1.seq].meds[d2
      .seq].errors[e_cnt].desc = "Admin without End date/time", work->encntrs[d1.seq].meds[d2.seq].
      errors[e_cnt].lvl = 1
     ENDIF
     IF ((work->encntrs[d1.seq].meds[d2.seq].actions[a].error_ind=0))
      work->encntrs[d1.seq].meds[d2.seq].actions[a].total_hrs = datetimediff(work->encntrs[d1.seq].
       meds[d2.seq].actions[a].end_dt_tm,work->encntrs[d1.seq].meds[d2.seq].actions[a].beg_dt_tm,3)
      IF ((work->encntrs[d1.seq].meds[d2.seq].error_ind=0))
       work->encntrs[d1.seq].meds[d2.seq].total_hrs = (work->encntrs[d1.seq].meds[d2.seq].total_hrs+
       work->encntrs[d1.seq].meds[d2.seq].actions[a].total_hrs)
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#exit_script
 DECLARE line_var = vc
 DECLARE tmp_user = vc
 SELECT INTO "NL:"
  FROM prsnl pr
  WHERE (pr.person_id=reqinfo->updt_id)
  DETAIL
   tmp_user = pr.username
  WITH nocounter
 ;end select
 SELECT INTO value(var_output)
  FROM dummyt d
  HEAD REPORT
   col_1_0 = 36, col_1_1 = (col_1_0+ 12), col_1_2 = (col_1_1+ 12),
   col_1_3 = (col_1_2+ 12), col_2_0 = 396, col_3_0 = (col_2_0+ 108),
   col_4_0 = (col_3_0+ 162), end_page = 560, row_size = 11,
   y_pos = 0, tmp_hrs = 0, tmp_min = 0,
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1
  HEAD PAGE
   IF (curpage > 1)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   MACRO (print_header)
    y_pos = (row_size * 3), col 0, "{F/4}{CPI/15}{LPI/5}",
    row + 1, col + 0,
    CALL print(calcpos(col_1_0,y_pos)),
    col + 0,
    CALL print(build2("{B}Patient Name:{ENDB}  ",work->encntrs[e].patient_name)), row + 1,
    col + 0,
    CALL print(calcpos(col_2_0,y_pos)), col + 0,
    CALL print(build2("{B}Birth Date:{ENDB}  ",format(work->encntrs[e].birth_dt_tm,"MM/DD/YYYY;;D"))),
    row + 1, y_pos = (y_pos+ row_size),
    col + 0,
    CALL print(calcpos(col_1_0,y_pos)), col + 0,
    CALL print(build2("{B}Corporate MRN:{ENDB}  ",work->encntrs[e].cmrn)), row + 1, col + 0,
    CALL print(calcpos(col_2_0,y_pos)), col + 0,
    CALL print(build2("{B}Account Number:{ENDB}  ",work->encntrs[e].acct_nbr)),
    row + 1, y_pos = (y_pos+ (row_size * 2)), col + 0,
    CALL print(calcpos(col_1_0,y_pos)), col + 0, "{B}{U}Order Information{ENDU}{ENDB}",
    row + 1, col + 0,
    CALL print(calcpos(col_2_0,y_pos)),
    col + 0, "{B}{U}Begin Date/Time{ENDU}{ENDB}", row + 1,
    col + 0,
    CALL print(calcpos(col_3_0,y_pos)), col + 0,
    "{B}{U}End Date/Time{ENDU}{ENDB}", row + 1, col + 0,
    CALL print(calcpos(col_4_0,y_pos)), col + 0, "{B}{U}Total Time{ENDU}{ENDB}",
    row + 1, y_pos = (y_pos+ row_size)
   ENDMACRO
   , col 0, "{F/4}{CPI/15}{LPI/5}",
   row + 1
  DETAIL
   IF (err_msg > " ")
    col + 0,
    CALL print(calcpos(col_1_0,300)), col + 0,
    CALL print(build2("{B}Error with report: ",err_msg,"{ENDB}")), row + 1
   ELSE
    FOR (e = 1 TO work->e_cnt)
      IF ((work->encntrs[e].ce_m_cnt > 0))
       IF (e > 1)
        y_pos = 0, BREAK
       ENDIF
       print_header
       FOR (m = 1 TO work->encntrs[e].m_cnt)
         IF (m > 1)
          y_pos = (y_pos+ (row_size * 2))
          IF (y_pos >= end_page)
           y_pos = 0, BREAK, print_header
          ENDIF
         ENDIF
         IF ((work->encntrs[e].meds[m].ordered_by != work->encntrs[e].meds[m].order_phys))
          line_var = build2(work->encntrs[e].meds[m].order_desc," ordered by ",work->encntrs[e].meds[
           m].ordered_by," for ",work->encntrs[e].meds[m].order_phys)
         ELSE
          line_var = build2(work->encntrs[e].meds[m].order_desc," ordered by ",work->encntrs[e].meds[
           m].ordered_by)
         ENDIF
         CALL rw_wrap(line_var,90,0)
         IF (((y_pos+ (row_size * (wrap_return->l_cnt - 1))) >= end_page))
          y_pos = 0, BREAK, print_header
         ENDIF
         col + 0,
         CALL print(calcpos(col_2_0,y_pos)), col + 0,
         work->encntrs[e].meds[m].beg_dt_tm_disp, row + 1, col + 0,
         CALL print(calcpos(col_3_0,y_pos)), col + 0, work->encntrs[e].meds[m].end_dt_tm_disp,
         row + 1, col + 0,
         CALL print(calcpos(col_4_0,y_pos))
         IF ((((work->encntrs[e].meds[m].error_ind=1)) OR ((work->encntrs[e].meds[m].a_cnt <= 0))) )
          col + 0, "{B}Incomplete{ENDB}"
         ELSE
          tmp_hrs = 0, tmp_min = 0
          IF ((round(work->encntrs[e].meds[m].total_hrs,0) > work->encntrs[e].meds[m].total_hrs))
           tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].total_hrs,0)), tmp_min = cnvtint(round((
             60 - (60 * (tmp_hrs - work->encntrs[e].meds[m].total_hrs))),0)), tmp_hrs = (tmp_hrs - 1)
          ELSE
           tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].total_hrs,0)), tmp_min = cnvtint(round((
             60 * (work->encntrs[e].meds[m].total_hrs - tmp_hrs)),0))
          ENDIF
          col + 0,
          CALL print(build2(trim(build2(tmp_hrs),3)," hrs ",trim(build2(tmp_min),3)," min"))
         ENDIF
         row + 1
         FOR (l = 1 TO wrap_return->l_cnt)
           IF (l > 1)
            y_pos = (y_pos+ row_size), col + 0,
            CALL print(calcpos((col_1_0+ 6),y_pos))
           ELSE
            col + 0,
            CALL print(calcpos(col_1_0,y_pos))
           ENDIF
           col + 0, wrap_return->lines[l].text, row + 1
         ENDFOR
         IF ((work->encntrs[e].meds[m].b_cnt > 0))
          FOR (b = 1 TO work->encntrs[e].meds[m].b_cnt)
            y_pos = (y_pos+ row_size)
            IF (y_pos >= end_page)
             y_pos = 0, BREAK, print_header
            ENDIF
            col + 0,
            CALL print(calcpos(col_1_1,y_pos)), col + 0,
            CALL print(build2("Bag # ",cnvtstring(work->encntrs[e].meds[m].bags[b].bag_num))), row +
            1, col + 0,
            CALL print(calcpos(col_4_0,y_pos))
            IF ((work->encntrs[e].meds[m].bags[b].error_ind=1))
             col + 0, "{B}Incomplete{ENDB}"
            ELSE
             tmp_hrs = 0, tmp_min = 0
             IF ((round(work->encntrs[e].meds[m].bags[b].total_hrs,0) > work->encntrs[e].meds[m].
             bags[b].total_hrs))
              tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].bags[b].total_hrs,0)), tmp_min =
              cnvtint(round((60 - (60 * (tmp_hrs - work->encntrs[e].meds[m].bags[b].total_hrs))),0)),
              tmp_hrs = (tmp_hrs - 1)
             ELSE
              tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].bags[b].total_hrs,0)), tmp_min =
              cnvtint(round((60 * (work->encntrs[e].meds[m].bags[b].total_hrs - tmp_hrs)),0))
             ENDIF
             col + 0,
             CALL print(build2(trim(build2(tmp_hrs),3)," hrs ",trim(build2(tmp_min),3)," min"))
            ENDIF
            row + 1
            FOR (ba = 1 TO work->encntrs[e].meds[m].bags[b].ba_cnt)
              tmp_ba = work->encntrs[e].meds[m].bags[b].bag_actions[ba].action_slot, y_pos = (y_pos+
              row_size)
              IF (y_pos >= end_page)
               y_pos = 0, BREAK, print_header
              ENDIF
              line_var = work->encntrs[e].meds[m].actions[tmp_ba].desc
              IF ((work->encntrs[e].meds[m].actions[tmp_ba].dose > 0))
               line_var = build2(line_var," ",trim(build2(work->encntrs[e].meds[m].actions[tmp_ba].
                  dose),3)," ",work->encntrs[e].meds[m].actions[tmp_ba].dose_unit)
              ENDIF
              IF ((work->encntrs[e].meds[m].actions[tmp_ba].rate > 0))
               line_var = build2(line_var," at ",trim(build2(work->encntrs[e].meds[m].actions[tmp_ba]
                  .rate),3)," ",work->encntrs[e].meds[m].actions[tmp_ba].rate_unit)
              ENDIF
              IF ((work->encntrs[e].meds[m].actions[tmp_ba].site > " "))
               line_var = build2(line_var," (",work->encntrs[e].meds[m].actions[tmp_ba].site,")")
              ENDIF
              IF ((work->encntrs[e].meds[m].actions[tmp_ba].username > " "))
               line_var = build2(line_var," by ",work->encntrs[e].meds[m].actions[tmp_ba].username)
              ENDIF
              CALL rw_wrap(line_var,90,0)
              IF (((y_pos+ (row_size * (wrap_return->l_cnt - 1))) >= end_page))
               y_pos = 0, BREAK, print_header
              ENDIF
              col + 0,
              CALL print(calcpos(col_2_0,y_pos)), col + 0,
              work->encntrs[e].meds[m].actions[tmp_ba].beg_dt_tm_disp, row + 1, col + 0,
              CALL print(calcpos(col_3_0,y_pos)), col + 0, work->encntrs[e].meds[m].actions[tmp_ba].
              end_dt_tm_disp,
              row + 1, col + 0,
              CALL print(calcpos(col_4_0,y_pos))
              IF ((work->encntrs[e].meds[m].actions[tmp_ba].print_hrs_ind=1))
               IF ((work->encntrs[e].meds[m].actions[tmp_ba].error_ind=1))
                col + 0, "{B}*** Missing ***{ENDB}"
               ELSE
                tmp_hrs = 0, tmp_min = 0
                IF ((round(work->encntrs[e].meds[m].actions[tmp_ba].total_hrs,0) > work->encntrs[e].
                meds[m].actions[tmp_ba].total_hrs))
                 tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].actions[tmp_ba].total_hrs,0)),
                 tmp_min = cnvtint(round((60 - (60 * (tmp_hrs - work->encntrs[e].meds[m].actions[
                   tmp_ba].total_hrs))),0)), tmp_hrs = (tmp_hrs - 1)
                ELSE
                 tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].actions[tmp_ba].total_hrs,0)),
                 tmp_min = cnvtint(round((60 * (work->encntrs[e].meds[m].actions[tmp_ba].total_hrs -
                   tmp_hrs)),0))
                ENDIF
                col + 0,
                CALL print(build2(trim(build2(tmp_hrs),3)," hrs ",trim(build2(tmp_min),3)," min"))
               ENDIF
              ENDIF
              row + 1
              FOR (l = 1 TO wrap_return->l_cnt)
                IF (l > 1)
                 y_pos = (y_pos+ row_size), col + 0,
                 CALL print(calcpos((col_1_2+ 6),y_pos))
                ELSE
                 col + 0,
                 CALL print(calcpos(col_1_2,y_pos))
                ENDIF
                col + 0, wrap_return->lines[l].text, row + 1
              ENDFOR
            ENDFOR
          ENDFOR
         ELSE
          FOR (a = 1 TO work->encntrs[e].meds[m].a_cnt)
            y_pos = (y_pos+ row_size)
            IF (y_pos >= end_page)
             y_pos = 0, BREAK, print_header
            ENDIF
            line_var = work->encntrs[e].meds[m].actions[a].desc
            IF ((work->encntrs[e].meds[m].actions[a].site > " "))
             line_var = build2(line_var," (",work->encntrs[e].meds[m].actions[a].site,")")
            ENDIF
            IF ((work->encntrs[e].meds[m].actions[a].username > " "))
             line_var = build2(line_var," by ",work->encntrs[e].meds[m].actions[a].username)
            ENDIF
            CALL rw_wrap(line_var,90,0)
            IF (((y_pos+ (row_size * (wrap_return->l_cnt - 1))) >= end_page))
             y_pos = 0, BREAK, print_header
            ENDIF
            col + 0,
            CALL print(calcpos(col_2_0,y_pos)), col + 0,
            work->encntrs[e].meds[m].actions[a].beg_dt_tm_disp, row + 1, col + 0,
            CALL print(calcpos(col_3_0,y_pos)), col + 0, work->encntrs[e].meds[m].actions[a].
            end_dt_tm_disp,
            row + 1, col + 0,
            CALL print(calcpos(col_4_0,y_pos))
            IF ((work->encntrs[e].meds[m].actions[a].print_hrs_ind=1))
             IF ((work->encntrs[e].meds[m].actions[a].error_ind=1))
              col + 0, "{B}Incomplete{ENDB}"
             ELSE
              tmp_hrs = 0, tmp_min = 0
              IF ((round(work->encntrs[e].meds[m].actions[a].total_hrs,0) > work->encntrs[e].meds[m].
              actions[a].total_hrs))
               tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].actions[a].total_hrs,0)), tmp_min =
               cnvtint(round((60 - (60 * (tmp_hrs - work->encntrs[e].meds[m].actions[a].total_hrs))),
                 0)), tmp_hrs = (tmp_hrs - 1)
              ELSE
               tmp_hrs = cnvtint(round(work->encntrs[e].meds[m].actions[a].total_hrs,0)), tmp_min =
               cnvtint(round((60 * (work->encntrs[e].meds[m].actions[a].total_hrs - tmp_hrs)),0))
              ENDIF
              col + 0,
              CALL print(build2(trim(build2(tmp_hrs),3)," hrs ",trim(build2(tmp_min),3)," min"))
             ENDIF
            ENDIF
            row + 1
            FOR (l = 1 TO wrap_return->l_cnt)
              IF (l > 1)
               y_pos = (y_pos+ row_size), col + 0,
               CALL print(calcpos((col_1_1+ 6),y_pos))
              ELSE
               col + 0,
               CALL print(calcpos(col_1_1,y_pos))
              ENDIF
              col + 0, wrap_return->lines[l].text, row + 1
            ENDFOR
            FOR (d = 1 TO work->encntrs[e].meds[m].actions[a].d_cnt)
              y_pos = (y_pos+ row_size)
              IF (y_pos >= end_page)
               y_pos = 0, BREAK, print_header
              ENDIF
              line_var = work->encntrs[e].meds[m].actions[a].diluents[d].desc
              IF ((work->encntrs[e].meds[m].actions[a].diluents[d].dose > 0)
               AND (work->encntrs[e].meds[m].actions[a].diluents[d].volume > 0))
               line_var = build2(line_var," ",trim(build2(work->encntrs[e].meds[m].actions[a].
                  diluents[d].dose),3),"/",trim(build2(work->encntrs[e].meds[m].actions[a].diluents[d
                  ].volume),3),
                " ",work->encntrs[e].meds[m].actions[a].diluents[d].dose_unit,"/",work->encntrs[e].
                meds[m].actions[a].diluents[d].volume_unit)
              ELSEIF ((work->encntrs[e].meds[m].actions[a].diluents[d].dose > 0))
               line_var = build2(line_var," ",trim(build2(work->encntrs[e].meds[m].actions[a].
                  diluents[d].dose),3)," ",work->encntrs[e].meds[m].actions[a].diluents[d].dose_unit)
              ELSEIF ((work->encntrs[e].meds[m].actions[a].diluents[d].volume > 0))
               line_var = build2(line_var," ",trim(build2(work->encntrs[e].meds[m].actions[a].
                  diluents[d].volume),3)," ",work->encntrs[e].meds[m].actions[a].diluents[d].
                volume_unit)
              ENDIF
              CALL rw_wrap(line_var,90,0)
              IF (((y_pos+ (row_size * (wrap_return->l_cnt - 1))) >= end_page))
               y_pos = 0, BREAK, print_header
              ENDIF
              FOR (l = 1 TO wrap_return->l_cnt)
                IF (l > 1)
                 y_pos = (y_pos+ row_size), col + 0,
                 CALL print(calcpos((col_1_2+ 6),y_pos))
                ELSE
                 col + 0,
                 CALL print(calcpos(col_1_2,y_pos))
                ENDIF
                col + 0, wrap_return->lines[l].text, row + 1
              ENDFOR
            ENDFOR
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  FOOT PAGE
   col 0, "{F/4}{CPI/18}{LPI/6}", row + 1,
   y_pos = row_size, col + 0,
   CALL print(calcpos(col_1_0,y_pos)),
   col + 0, "{B}Infusion Tracking/IV End Report{ENDB}", row + 1,
   col + 0,
   CALL print(calcpos((col_3_0+ 122),y_pos)), col + 0,
   CALL print(build2("{B}Report Range:  ",format(work->beg_dt_tm,"MM/DD/YYYY;;D")," thru ",format(
     work->end_dt_tm,"MM/DD/YYYY;;D"),"{ENDB}")), row + 1, col + 0,
   CALL print(calcpos(col_1_0,572)), col + 0,
   CALL print(build2("{B}",curprog,"{ENDB}")),
   row + 1, col + 0,
   CALL print(calcpos(col_2_0,572)),
   col + 0,
   CALL print(build2("{B}Page ",trim(build2(curpage),3),"{ENDB}")), row + 1,
   col + 0,
   CALL print(calcpos((col_3_0+ 126),572)), col + 0,
   CALL print(build2("{B}Printed on ",format(curdate,"MM/DD/YY;;D")," ",cnvtupper(format(curtime,
      "HH:MM;;S"))," by ",
    tmp_user,"{ENDB}")), row + 1
  WITH dio = 08, maxcol = 32000, maxrow = 300,
   format = variable, nocounter
 ;end select
 FREE SET line_var
 CALL echorecord(work,"ryan_iv_end_mockup.rs")
END GO
