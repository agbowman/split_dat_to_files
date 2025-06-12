CREATE PROGRAM bhs_rpt_downtime_mar2
 PROMPT
  "output:" = "ryan_downtime_mar",
  "Nurse Unit Display Key:" = "",
  "Testing Indicator" = "0"
  WITH outdev, unit_cd_disp_key, test_ind
 FREE RECORD work
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 unit_str = vc
   1 unit_cd = f8
   1 e_cnt = i4
   1 encntrs[*]
     2 reg_dt_tm = vc
     2 filename = vc
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 dob = vc
     2 mrn = vc
     2 fin = vc
     2 unit = vc
     2 room = vc
     2 allergy_text = vc
     2 a_cnt = i4
     2 allergies[*]
       3 text = vc
     2 m_cnt = i4
     2 meds[*]
       3 med_type = i2
       3 o_cnt = i4
       3 orders[*]
         4 order_id = f8
       3 catalog_cd = f8
       3 template_ind = i2
       3 desc = vc
       3 od_line = vc
       3 start_dt_tm = dq8
       3 dose = vc
       3 f_dose = vc
       3 v_dose = vc
       3 v_dose_unit = vc
       3 s_dose = vc
       3 s_dose_unit = vc
       3 rate = vc
       3 rate_unit = vc
       3 route = vc
       3 freq = vc
       3 duration = vc
       3 duration_unit = vc
       3 prn_reason = vc
       3 spec_instr = vc
       3 instructions = vc
       3 hold_for = vc
       3 comments_ind = i2
       3 comment_line = vc
       3 c_cnt = i4
       3 comments[*]
         4 type = vc
         4 text = vc
       3 last_task_dt_tm = dq8
       3 last_task_result = vc
       3 last_task_comments = vc
       3 pt_cnt = i4
       3 pending_tasks[*]
         4 sch_dt_tm = dq8
         4 order_slot = i4
       3 d_cnt = i4
       3 dtas[*]
         4 desc = vc
 )
 DECLARE test_ind = i2
 DECLARE cs4_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_notdone_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cs24_child_cd = f8 WITH constant(uar_get_code_by("MEANING",24,"CHILD"))
 DECLARE cs53_med_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE cs53_placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE cs180_begin_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE cs180_bolus_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE cs180_infuse_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE cs180_ratechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE cs180_sitechg_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"SITECHG"))
 DECLARE cs180_waste_cd = f8 WITH constant(uar_get_code_by("MEANING",180,"WASTE"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cs6000_pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE cs6004_incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs12025_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE cs16449_instructions_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"INSTRUCTIONS"
   ))
 DECLARE cs16449_holdfor_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"HOLDFOR"))
 SET work->unit_str = trim( $UNIT_CD_DISP_KEY,3)
 SET work->beg_dt_tm = cnvtdatetime((curdate - 1),0)
 SET work->end_dt_tm = cnvtdatetime((curdate+ 1),235959)
 IF (cnvtint( $TEST_IND)=1)
  SET test_ind = 1
 ELSE
  SET test_ind = 0
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.display_key=work->unit_str)
    AND cv.code_set=220
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND cv.active_ind=1)
  DETAIL
   work->unit_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((work->unit_cd <= 0.00))
  CALL echo("Nurse Unit not found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_domain ed,
   encntr_alias ea,
   person_alias pa,
   person p
  PLAN (ed
   WHERE (ed.loc_nurse_unit_cd=work->unit_cd)
    AND ed.beg_effective_dt_tm <= sysdate
    AND ed.end_effective_dt_tm >= sysdate
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cs319_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.person_alias_type_cd=cs4_mrn_cd)
  ORDER BY p.person_id, ed.beg_effective_dt_tm DESC
  HEAD p.person_id
   IF (((e.reg_dt_tm >= cnvtlookbehind("36,H",sysdate)
    AND (work->unit_str IN ("EDPEDI", "EDMAIN", "ESHLD", "EDA", "EDGTA"))) OR ( NOT ((work->unit_str
    IN ("EDPEDI", "EDMAIN", "ESHLD", "EDA", "EDGTA"))))) )
    work->e_cnt = (work->e_cnt+ 1), stat = alterlist(work->encntrs,work->e_cnt), work->encntrs[work->
    e_cnt].reg_dt_tm = format(e.reg_dt_tm,";;Q"),
    work->encntrs[work->e_cnt].person_id = p.person_id, work->encntrs[work->e_cnt].encntr_id = e
    .encntr_id, work->encntrs[work->e_cnt].name = build2(trim(p.name_full_formatted,3)," (",trim(
      uar_get_code_display(e.encntr_type_cd),3),")"),
    work->encntrs[work->e_cnt].dob = format(p.birth_dt_tm,"MM-DD-YYYY;;d"), work->encntrs[work->e_cnt
    ].fin = trim(ea.alias,3), work->encntrs[work->e_cnt].mrn = trim(pa.alias,3),
    work->encntrs[work->e_cnt].unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd),3), work->
    encntrs[work->e_cnt].room = trim(uar_get_code_display(ed.loc_room_cd),3), work->encntrs[work->
    e_cnt].allergy_text = "NKA",
    work->encntrs[work->e_cnt].filename = build(trim(substring(1,14,trim(cnvtlower(cnvtalphanum(p
          .name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p
          .name_first_key,2)),4)),3),".ps")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=work->encntrs[d.seq].person_id)
    AND a.reaction_status_cd != cs12025_canceled_cd
    AND a.active_ind=1)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  HEAD REPORT
   a_cnt = 0
  DETAIL
   a_cnt = (work->encntrs[d.seq].a_cnt+ 1), work->encntrs[d.seq].a_cnt = a_cnt, stat = alterlist(work
    ->encntrs[d.seq].allergies,a_cnt)
   IF (n.nomenclature_id > 0.00)
    work->encntrs[d.seq].allergies[a_cnt].text = trim(n.source_string)
   ELSE
    work->encntrs[d.seq].allergies[a_cnt].text = trim(a.substance_ftdesc)
   ENDIF
   IF (a_cnt <= 1)
    work->encntrs[d.seq].allergy_text = work->encntrs[d.seq].allergies[a_cnt].text
   ELSE
    work->encntrs[d.seq].allergy_text = build2(work->encntrs[d.seq].allergy_text,", ",work->encntrs[d
     .seq].allergies[a_cnt].text)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq, med_type =
  IF (o.prn_ind=1) 3
  ELSEIF (o.iv_ind=1) 4
  ELSEIF (o.freq_type_flag=5) 2
  ELSE 1
  ENDIF
  , seq_mnemonic = substring(1,100,cnvtupper(o.hna_order_mnemonic))
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   orders o,
   frequency_schedule f
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=work->encntrs[d.seq].encntr_id)
    AND o.catalog_type_cd=cs6000_pharm_cd
    AND o.template_order_id=0.00
    AND o.orig_ord_as_flag=0
    AND o.order_status_cd IN (cs6004_ordered_cd, cs6004_future_cd, cs6004_incomplete_cd,
   cs6004_inprocess_cd, cs6004_pending_cd)
    AND o.active_ind=1)
   JOIN (f
   WHERE f.frequency_id=outerjoin(o.frequency_id))
  ORDER BY d.seq, med_type, seq_mnemonic,
   o.order_id
  HEAD REPORT
   m_cnt = 0
  HEAD d.seq
   m_cnt = 0
  HEAD seq_mnemonic
   m_cnt = 0
  DETAIL
   m_cnt = (work->encntrs[d.seq].m_cnt+ 1), stat = alterlist(work->encntrs[d.seq].meds,m_cnt), work->
   encntrs[d.seq].m_cnt = m_cnt,
   work->encntrs[d.seq].meds[m_cnt].med_type = med_type, work->encntrs[d.seq].meds[m_cnt].catalog_cd
    = o.catalog_cd, work->encntrs[d.seq].meds[m_cnt].desc = build2(trim(o.hna_order_mnemonic,3)," (",
    trim(o.order_mnemonic,3),")"),
   work->encntrs[d.seq].meds[m_cnt].freq = trim(uar_get_code_display(f.frequency_cd),3), work->
   encntrs[d.seq].meds[m_cnt].comments_ind = o.order_comment_ind, work->encntrs[d.seq].meds[m_cnt].
   o_cnt = 1,
   stat = alterlist(work->encntrs[d.seq].meds[m_cnt].orders,1), work->encntrs[d.seq].meds[m_cnt].
   orders[1].order_id = o.order_id
   IF (o.template_order_flag=1)
    work->encntrs[d.seq].meds[m_cnt].template_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_comment oc,
   long_text lt
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].comments_ind=1))
   JOIN (oc
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id=oc.order_id))
   JOIN (lt
   WHERE oc.long_text_id=lt.long_text_id)
  HEAD REPORT
   c_cnt = 0
  DETAIL
   c_cnt = (work->encntrs[d1.seq].meds[d2.seq].c_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].comments,c_cnt), work->encntrs[d1.seq].meds[d2.seq].comments[c_cnt].type = trim(
    uar_get_code_display(oc.comment_type_cd),3),
   work->encntrs[d1.seq].meds[d2.seq].comments[c_cnt].text = trim(lt.long_text,3)
   IF (c_cnt <= 1)
    work->encntrs[d1.seq].meds[d2.seq].comment_line = build2(work->encntrs[d1.seq].meds[d2.seq].
     comments[c_cnt].type,": ",work->encntrs[d1.seq].meds[d2.seq].comments[c_cnt].text)
   ELSE
    work->encntrs[d1.seq].meds[d2.seq].comment_line = build2(work->encntrs[d1.seq].meds[d2.seq].
     comment_line,char(13),work->encntrs[d1.seq].meds[d2.seq].comments[c_cnt].type,": ",work->
     encntrs[d1.seq].meds[d2.seq].comments[c_cnt].text)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_task_xref otx,
   order_task ot,
   task_discrete_r dt
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (otx
   WHERE (work->encntrs[d1.seq].meds[d2.seq].catalog_cd=otx.catalog_cd))
   JOIN (ot
   WHERE otx.reference_task_id=ot.reference_task_id
    AND ot.active_ind=1)
   JOIN (dt
   WHERE ot.reference_task_id=dt.reference_task_id
    AND dt.active_ind=1)
  ORDER BY d1.seq, d2.seq, dt.sequence
  HEAD REPORT
   d_cnt = 0
  DETAIL
   d_cnt = (work->encntrs[d1.seq].meds[d2.seq].d_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].dtas,d_cnt), work->encntrs[d1.seq].meds[d2.seq].d_cnt = d_cnt,
   work->encntrs[d1.seq].meds[d2.seq].dtas[d_cnt].desc = trim(uar_get_code_display(dt.task_assay_cd),
    3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (od
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id=od.order_id)
    AND ((od.oe_field_meaning IN ("REQSTARTDTTM", "FREETXTDOSE", "VOLUMEDOSE", "VOLUMEDOSEUNIT",
   "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "RATE", "RATEUNIT", "RXROUTE", "DURATION",
   "DURATIONUNIT", "PRNREASON", "SPECINX")) OR (od.oe_field_id IN (cs16449_instructions_cd,
   cs16449_holdfor_cd))) )
  ORDER BY d1.seq, d2.seq, od.action_sequence,
   od.detail_sequence
  HEAD d1.seq
   null
  HEAD d2.seq
   null
  HEAD od.action_sequence
   null
  DETAIL
   IF (od.oe_field_id=cs16449_instructions_cd)
    work->encntrs[d1.seq].meds[d2.seq].instructions = trim(od.oe_field_display_value,3)
   ELSEIF (od.oe_field_id=cs16449_holdfor_cd)
    work->encntrs[d1.seq].meds[d2.seq].hold_for = build2("Hold for ",trim(od.oe_field_display_value,3
      ))
   ELSE
    CASE (od.oe_field_meaning)
     OF "REQSTARTDTTM":
      work->encntrs[d1.seq].meds[d2.seq].start_dt_tm = od.oe_field_dt_tm_value
     OF "FREETXTDOSE":
      work->encntrs[d1.seq].meds[d2.seq].f_dose = trim(od.oe_field_display_value,3)
     OF "VOLUMEDOSE":
      work->encntrs[d1.seq].meds[d2.seq].v_dose = trim(od.oe_field_display_value,3)
     OF "VOLUMEDOSEUNIT":
      work->encntrs[d1.seq].meds[d2.seq].v_dose_unit = trim(od.oe_field_display_value,3)
     OF "STRENGTHDOSE":
      work->encntrs[d1.seq].meds[d2.seq].s_dose = trim(od.oe_field_display_value,3)
     OF "STRENGTHDOSEUNIT":
      work->encntrs[d1.seq].meds[d2.seq].s_dose_unit = trim(od.oe_field_display_value,3)
     OF "RATE":
      work->encntrs[d1.seq].meds[d2.seq].rate = trim(od.oe_field_display_value,3)
     OF "RATEUNIT":
      work->encntrs[d1.seq].meds[d2.seq].rate_unit = trim(od.oe_field_display_value,3)
     OF "RXROUTE":
      work->encntrs[d1.seq].meds[d2.seq].route = trim(od.oe_field_display_value,3)
     OF "DURATION":
      work->encntrs[d1.seq].meds[d2.seq].duration = trim(od.oe_field_display_value,3)
     OF "DURATIONUNIT":
      work->encntrs[d1.seq].meds[d2.seq].duration_unit = trim(od.oe_field_display_value,3)
     OF "PRNREASON":
      work->encntrs[d1.seq].meds[d2.seq].prn_reason = trim(od.oe_field_display_value,3)
     OF "SPECINX":
      work->encntrs[d1.seq].meds[d2.seq].spec_instr = trim(od.oe_field_display_value,3)
    ENDCASE
   ENDIF
  FOOT  od.action_sequence
   null
  FOOT  d2.seq
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].s_dose,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].dose = build2(work->encntrs[d1.seq].meds[d2.seq].s_dose," ",
     work->encntrs[d1.seq].meds[d2.seq].s_dose_unit)
   ELSEIF (trim(work->encntrs[d1.seq].meds[d2.seq].v_dose,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].dose = build2(work->encntrs[d1.seq].meds[d2.seq].v_dose," ",
     work->encntrs[d1.seq].meds[d2.seq].v_dose_unit)
   ELSE
    work->encntrs[d1.seq].meds[d2.seq].dose = work->encntrs[d1.seq].meds[d2.seq].f_dose
   ENDIF
   CASE (work->encntrs[d1.seq].meds[d2.seq].med_type)
    OF 1:
     work->encntrs[d1.seq].meds[d2.seq].od_line = build2("DOSE: ",work->encntrs[d1.seq].meds[d2.seq].
      dose,"  ","ROUTE: ",work->encntrs[d1.seq].meds[d2.seq].route,
      "  ","FREQUENCY: ",work->encntrs[d1.seq].meds[d2.seq].freq," ",work->encntrs[d1.seq].meds[d2
      .seq].duration,
      " ",work->encntrs[d1.seq].meds[d2.seq].duration_unit)
    OF 2:
     work->encntrs[d1.seq].meds[d2.seq].od_line = build2("DOSE: ",work->encntrs[d1.seq].meds[d2.seq].
      dose,"  ","ROUTE: ",work->encntrs[d1.seq].meds[d2.seq].route,
      "  ","FREQUENCY: ",work->encntrs[d1.seq].meds[d2.seq].freq," ",work->encntrs[d1.seq].meds[d2
      .seq].duration,
      " ",work->encntrs[d1.seq].meds[d2.seq].duration_unit)
    OF 3:
     work->encntrs[d1.seq].meds[d2.seq].od_line = build2("DOSE: ",work->encntrs[d1.seq].meds[d2.seq].
      dose,"  ","ROUTE: ",work->encntrs[d1.seq].meds[d2.seq].route,
      "  ","FREQUENCY: ",work->encntrs[d1.seq].meds[d2.seq].freq," ",work->encntrs[d1.seq].meds[d2
      .seq].duration,
      " ",work->encntrs[d1.seq].meds[d2.seq].duration_unit,"  ","PRN REASON: ",work->encntrs[d1.seq].
      meds[d2.seq].prn_reason)
    OF 4:
     work->encntrs[d1.seq].meds[d2.seq].od_line = build2("DOSE: ",work->encntrs[d1.seq].meds[d2.seq].
      dose,"  ","RATE: ",work->encntrs[d1.seq].meds[d2.seq].rate,
      " ",work->encntrs[d1.seq].meds[d2.seq].rate_unit,"  ","DURATION: ",work->encntrs[d1.seq].meds[
      d2.seq].duration,
      " ",work->encntrs[d1.seq].meds[d2.seq].duration_unit)
   ENDCASE
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].hold_for,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].od_line = build2(work->encntrs[d1.seq].meds[d2.seq].od_line,
     char(13),work->encntrs[d1.seq].meds[d2.seq].hold_for)
   ENDIF
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].instructions,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].od_line = build2(work->encntrs[d1.seq].meds[d2.seq].od_line,
     char(13),work->encntrs[d1.seq].meds[d2.seq].instructions)
   ENDIF
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].spec_instr,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].od_line = build2(work->encntrs[d1.seq].meds[d2.seq].od_line,
     char(13),work->encntrs[d1.seq].meds[d2.seq].spec_instr)
   ENDIF
  FOOT  d1.seq
   null
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].template_ind=1))
   JOIN (o
   WHERE (work->encntrs[d1.seq].encntr_id=o.encntr_id)
    AND (work->encntrs[d1.seq].meds[d2.seq].orders[1].order_id=o.template_order_id)
    AND o.order_status_cd IN (cs6004_ordered_cd, cs6004_future_cd, cs6004_incomplete_cd,
   cs6004_inprocess_cd, cs6004_pending_cd,
   cs6004_completed_cd))
  ORDER BY d1.seq, d2.seq, o.current_start_dt_tm
  HEAD REPORT
   o_cnt = 0, pt_cnt = 0
  HEAD d1.seq
   o_cnt = 0, pt_cnt = 0
  HEAD d2.seq
   o_cnt = 0, pt_cnt = 0
  DETAIL
   o_cnt = (work->encntrs[d1.seq].meds[d2.seq].o_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    meds[d2.seq].orders,o_cnt), work->encntrs[d1.seq].meds[d2.seq].o_cnt = o_cnt,
   work->encntrs[d1.seq].meds[d2.seq].orders[o_cnt].order_id = o.order_id
   IF (o.current_start_dt_tm BETWEEN cnvtlookbehind("2,H",sysdate) AND cnvtdatetime(work->end_dt_tm)
    AND o.order_status_cd != cs6004_completed_cd)
    pt_cnt = (work->encntrs[d1.seq].meds[d2.seq].pt_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
     meds[d2.seq].pending_tasks,pt_cnt), work->encntrs[d1.seq].meds[d2.seq].pt_cnt = pt_cnt,
    work->encntrs[d1.seq].meds[d2.seq].pending_tasks[pt_cnt].sch_dt_tm = o.current_start_dt_tm, work
    ->encntrs[d1.seq].meds[d2.seq].pending_tasks[pt_cnt].order_slot = o_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce,
   ce_event_note cen,
   long_blob lb
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].med_type != 4)
    AND maxrec(d3,work->encntrs[d1.seq].meds[d2.seq].o_cnt))
   JOIN (d3)
   JOIN (ce
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id=ce.order_id)
    AND ce.view_level=1
    AND ce.event_reltn_cd=cs24_child_cd
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_notdone_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cen
   WHERE outerjoin(ce.event_id)=cen.event_id)
   JOIN (lb
   WHERE outerjoin(cen.ce_event_note_id)=lb.parent_entity_id
    AND lb.parent_entity_name=outerjoin("ce_event_note"))
  ORDER BY d1.seq, d2.seq, ce.event_end_dt_tm DESC
  HEAD d1.seq
   null
  HEAD d2.seq
   work->encntrs[d1.seq].meds[d2.seq].last_task_dt_tm = ce.event_end_dt_tm, work->encntrs[d1.seq].
   meds[d2.seq].last_task_result = trim(ce.event_tag,3)
   IF (lb.long_blob_id > 0.00)
    work->encntrs[d1.seq].meds[d2.seq].last_task_comments = trim(replace(lb.long_blob,"ocf_blob","",1
      ),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cmr1.substance_lot_number, ce1_collating_seq = cnvtint(substring(13,3,ce1.collating_seq)),
  ce2_collating_seq = cnvtint(substring(13,3,ce2.collating_seq))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   clinical_event ce1,
   ce_med_result cmr1,
   clinical_event ce2,
   ce_med_result cmr2
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2
   WHERE (work->encntrs[d1.seq].meds[d2.seq].med_type=4)
    AND maxrec(d3,work->encntrs[d1.seq].meds[d2.seq].o_cnt))
   JOIN (d3)
   JOIN (ce1
   WHERE (work->encntrs[d1.seq].meds[d2.seq].orders[d3.seq].order_id=ce1.order_id)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_notdone_cd)
    AND ce1.event_title_text="IVPARENT"
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr1
   WHERE ce1.event_id=cmr1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_notdone_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr2
   WHERE ce2.event_id=cmr2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d1.seq, d2.seq, ce1.event_end_dt_tm DESC,
   ce2.event_end_dt_tm DESC, ce1_collating_seq DESC, ce2_collating_seq DESC
  HEAD d1.seq
   null
  HEAD d2.seq
   work->encntrs[d1.seq].meds[d2.seq].last_task_dt_tm = ce2.event_end_dt_tm, work->encntrs[d1.seq].
   meds[d2.seq].last_task_result = trim(uar_get_code_display(cmr2.iv_event_cd),3)
   IF (cmr2.iv_event_cd=cs180_begin_cd)
    work->encntrs[d1.seq].meds[d2.seq].last_task_result = build2(work->encntrs[d1.seq].meds[d2.seq].
     last_task_result," ",trim(build2(cmr1.initial_volume),3)," ",trim(uar_get_code_display(cmr1
       .infused_volume_unit_cd),3))
   ELSEIF (cmr2.iv_event_cd=cs180_sitechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].last_task_result = build2(work->encntrs[d1.seq].meds[d2.seq].
     last_task_result," ",trim(uar_get_code_display(cmr2.admin_site_cd),3))
   ELSEIF (cmr2.iv_event_cd=cs180_ratechg_cd)
    work->encntrs[d1.seq].meds[d2.seq].last_task_result = build2(work->encntrs[d1.seq].meds[d2.seq].
     last_task_result," ",trim(build2(cmr1.infusion_rate),3)," ",trim(uar_get_code_display(cmr1
       .infusion_unit_cd),3))
   ELSEIF (cmr2.iv_event_cd IN (cs180_infuse_cd, cs180_bolus_cd))
    work->encntrs[d1.seq].meds[d2.seq].last_task_result = build2(work->encntrs[d1.seq].meds[d2.seq].
     last_task_result," ",trim(build2(cmr2.admin_dosage),3)," ",trim(uar_get_code_display(cmr2
       .dosage_unit_cd),3),
     " from ",format(ce2.event_start_dt_tm,"mm-dd-yyyy hh:mm;;d")," to ",format(ce2.event_end_dt_tm,
      "mm-dd-yyyy hh:mm;;d"))
   ELSEIF (cmr2.iv_event_cd=cs180_waste_cd)
    work->encntrs[d1.seq].meds[d2.seq].last_task_result = build2(work->encntrs[d1.seq].meds[d2.seq].
     last_task_result," ",trim(build2(cmr2.remaining_volume),3)," ",trim(uar_get_code_display(cmr2
       .remaining_volume_unit_cd),3))
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE e = i4 WITH noconstant(0)
 DECLARE s = i4 WITH noconstant(0)
 DECLARE m = i4 WITH noconstant(0)
 DECLARE becont = i4 WITH noconstant(0)
 DECLARE cur_page = i4 WITH noconstant(0)
 DECLARE cur_end_report = i2 WITH noconstant(0)
 DECLARE tmp_remove = vc
 DECLARE next_dose_cnt = i4 WITH constant(3)
 DECLARE blank_med_cnt = i4 WITH constant(3)
 DECLARE refused_med_cnt = i4 WITH constant(2)
 DECLARE prn_angio_cnt = i4 WITH constant(2)
 DECLARE sig_line_cnt = i4 WITH constant(3)
 DECLARE tmp_work_room = f8
 DECLARE tmp_height = f8
 DECLARE y_page_head = f8 WITH constant(0.5)
 DECLARE y_page_foot = f8 WITH constant(10.5)
 DECLARE page_foot_buffer = f8 WITH constant(0.15)
 DECLARE y_end_of_page = f8
 DECLARE y_end_of_report = f8
 DECLARE report_head_height = f8
 DECLARE report_divider_height = f8
 DECLARE patient_demo_height = f8
 DECLARE patient_allergies_height = f8
 DECLARE site_legends_height = f8
 DECLARE section_head_height = f8
 DECLARE med_next_dose_height = f8
 DECLARE med_addtl_notes_height = f8
 DECLARE med_blank_sch_height = f8
 DECLARE med_blank_prn_height = f8
 DECLARE med_blank_iv_height = f8
 DECLARE refused_med_height = f8
 DECLARE prn_angio_height = f8
 DECLARE allergies_text = vc
 DECLARE section_desc = vc
 DECLARE med_desc = vc
 DECLARE med_details_text = vc
 DECLARE med_instructions_text = vc
 DECLARE med_last_dose_text = vc
 DECLARE next_dose_text = vc
 SET y_end_of_page = (y_page_foot - page_foot_buffer)
 SET y_end_of_report = ((y_end_of_page - page_foot_buffer) - (sig_line_cnt * signature_line(
  rpt_calcheight)))
 SET report_head_height = report_head(rpt_calcheight)
 SET report_divider_height = report_divider(rpt_calcheight)
 SET patient_demo_height = patient_demographics(rpt_calcheight)
 SET patient_allergies_height = patient_allergies(rpt_calcheight,8.5,becont)
 SET site_legends_height = site_legends(rpt_calcheight)
 SET section_head_height = (mar_section_head(rpt_calcheight)+ report_divider_height)
 SET med_next_dose_height = med_next_dose(rpt_calcheight)
 SET med_addtl_notes_height = med_addtl_notes(rpt_calcheight)
 SET med_blank_sch_height = ((((med_description(rpt_calcheight,0.20,becont)+ med_blank_details_sch(
  rpt_calcheight))+ med_next_dose_height)+ med_addtl_notes_height)+ report_divider_height)
 SET med_blank_prn_height = (((((med_description(rpt_calcheight,0.20,becont)+ med_blank_details_sch(
  rpt_calcheight))+ med_blank_details_prn(rpt_calcheight))+ med_next_dose_height)+
 med_addtl_notes_height)+ report_divider_height)
 SET med_blank_iv_height = ((((med_description(rpt_calcheight,0.20,becont)+ med_blank_details_iv(
  rpt_calcheight))+ med_next_dose_height)+ med_addtl_notes_height)+ report_divider_height)
 SET refused_med_height = ((refused_medications(rpt_calcheight)+ (refused_med_cnt * refused_med_notes
 (rpt_calcheight)))+ report_divider_height)
 SET prn_angio_height = (((prn_angio_head(rpt_calcheight)+ report_divider_height)+ (prn_angio_cnt *
 prn_angio_notes(rpt_calcheight)))+ report_divider_height)
 DECLARE sub_head_report(zero1=i2) = null
 DECLARE sub_head_page(beg_report=i2) = null
 DECLARE sub_get_work_room(zero2=i2) = null
 DECLARE sub_foot_page(end_report=i2) = null
 DECLARE sub_foot_report(zero4=i2) = null
 SUBROUTINE sub_head_report(zero1)
   IF (((test_ind=1
    AND e=1) OR (test_ind=0)) )
    SET d0 = initializereport(0)
   ENDIF
   SET cur_page = 0
   SET d0 = sub_head_page(1)
 END ;Subroutine
 SUBROUTINE sub_head_page(beg_report)
  SET _yoffset = y_page_head
  IF (beg_report=1)
   SET d0 = report_head(rpt_render)
   SET d0 = patient_demographics(rpt_render)
   SET allergies_text = work->encntrs[e].allergy_text
   SET d0 = patient_allergies(rpt_render,8.5,becont)
   SET d0 = site_legends(rpt_render)
  ELSEIF (beg_report=0)
   SET d0 = patient_demographics(rpt_render)
   SET d0 = site_legends(rpt_render)
   IF (s > 0)
    SET print_section_desc_ind = 0
    SET d0 = mar_section_head(rpt_render)
    SET d0 = report_divider(rpt_render)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE sub_get_work_room(zero2)
   RETURN((y_end_of_page - _yoffset))
 END ;Subroutine
 SUBROUTINE sub_foot_page(end_report)
   SET cur_page = (cur_page+ 1)
   SET _yoffset = y_page_foot
   SET d0 = page_foot(rpt_render)
   IF (end_report=0)
    SET d0 = pagebreak(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE sub_foot_report(zero4)
   SET cur_end_report = 1
   IF (_yoffset > y_end_of_report)
    SET d0 = pagebreak(0)
   ENDIF
   SET _yoffset = (y_end_of_report+ page_foot_buffer)
   FOR (sl = 1 TO sig_line_cnt)
     SET d0 = signature_line(rpt_render)
   ENDFOR
   IF (test_ind=0)
    SET d0 = sub_foot_page(1)
   ELSE
    IF ((e=work->e_cnt))
     SET d0 = sub_foot_page(1)
    ELSE
     SET d0 = sub_foot_page(0)
    ENDIF
   ENDIF
   IF (test_ind=0)
    SET d0 = finalizereport(work->encntrs[e].filename)
    SET spool value(work->encntrs[e].filename)  $OUTDEV
    SET tmp_remove = build2('set stat = remove("',work->encntrs[e].filename,'") go')
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
   ENDIF
   SET cur_end_report = 0
 END ;Subroutine
 FOR (e = 1 TO work->e_cnt)
   SET time_marker = format(cnvtlookahead("2,S",cnvtdatetime(curdate,curtime3)),"YYYYMMDDHHMMSS;;D")
   WHILE (format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D") < time_marker)
     SET zzz = 1
   ENDWHILE
   SET d0 = sub_head_report(0)
   FOR (s = 1 TO 4)
     SET print_section_desc_ind = 1
     CASE (s)
      OF 1:
       SET section_desc = "SCHEDULED MEDICATIONS"
      OF 2:
       SET section_desc = "UNSCHEDULED MEDICATIONS"
      OF 3:
       SET section_desc = "PRN MEDICATIONS"
      OF 4:
       SET section_desc = "CONTINUOUS INFUSIONS"
     ENDCASE
     FOR (m = 1 TO work->encntrs[e].m_cnt)
      IF (_yoffset >= y_end_of_page)
       SET d0 = sub_foot_page(0)
       SET d0 = sub_head_page(0)
      ENDIF
      IF ((work->encntrs[e].meds[m].med_type=s))
       IF (print_section_desc_ind=1)
        SET print_section_desc_ind = 0
        SET d0 = mar_section_head(rpt_render)
        SET d0 = report_divider(rpt_render)
       ENDIF
       SET med_desc = " "
       SET tmp_get_work_room = sub_get_work_room(0)
       SET med_desc = build2(work->encntrs[e].meds[m].desc," to start at ",format(work->encntrs[e].
         meds[m].start_dt_tm,"mm/dd/yyyy hh:mm;;d"))
       SET tmp_height = med_description(rpt_calcheight,tmp_work_room,becont)
       IF (((_yoffset+ tmp_height) >= y_end_of_page))
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET tmp_get_work_room = sub_get_work_room(0)
       ENDIF
       SET d0 = med_description(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET tmp_get_work_room = sub_get_work_room(0)
         SET d0 = med_description(rpt_render,tmp_work_room,becont)
       ENDWHILE
       SET med_desc = " "
       IF (_yoffset >= y_end_of_page)
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET med_desc = "Continued from Previous Page"
        SET d0 = med_description(rpt_render,0.20,becont)
        SET med_desc = " "
       ENDIF
       IF (trim(work->encntrs[e].meds[m].od_line,3) > " ")
        SET med_details_text = " "
        SET tmp_get_work_room = sub_get_work_room(0)
        SET med_details_text = work->encntrs[e].meds[m].od_line
        SET d0 = med_details(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET d0 = sub_foot_page(0)
          SET d0 = sub_head_page(0)
          SET med_desc = "Continued from Previous Page"
          SET d0 = med_description(rpt_render,0.20,becont)
          SET med_desc = " "
          SET tmp_get_work_room = sub_get_work_room(0)
          SET d0 = med_details(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ENDIF
       SET med_details_text = " "
       IF (_yoffset >= y_end_of_page)
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET med_desc = "Continued from Previous Page"
        SET d0 = med_description(rpt_render,0.20,becont)
        SET med_desc = " "
       ENDIF
       IF (trim(work->encntrs[e].meds[m].comment_line,3) > " ")
        SET med_instructions_text = " "
        SET tmp_get_work_room = sub_get_work_room(0)
        SET med_instructions_text = work->encntrs[e].meds[m].comment_line
        SET d0 = med_instructions(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET d0 = sub_foot_page(0)
          SET d0 = sub_head_page(0)
          SET med_desc = "Continued from Previous Page"
          SET d0 = med_description(rpt_render,0.20,becont)
          SET med_desc = " "
          SET tmp_get_work_room = sub_get_work_room(0)
          SET d0 = med_instructions(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ENDIF
       SET med_instructions_text = " "
       IF (_yoffset >= y_end_of_page)
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
        SET med_desc = "Continued from Previous Page"
        SET d0 = med_description(rpt_render,0.20,becont)
        SET med_desc = " "
       ENDIF
       SET tmp_get_work_room = sub_get_work_room(0)
       SET med_last_dose_text = " "
       IF (trim(work->encntrs[e].meds[m].last_task_result,3) > " ")
        SET med_last_dose_text = build2(work->encntrs[e].meds[m].last_task_result," at ",format(work
          ->encntrs[e].meds[m].last_task_dt_tm,"mm-dd-yyyy hh:mm;;d"))
       ELSE
        SET med_last_dose_text = "Not Previously Given"
       ENDIF
       SET d0 = med_last_dose(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         SET d0 = sub_foot_page(0)
         SET d0 = sub_head_page(0)
         SET med_desc = "Continued from Previous Page"
         SET d0 = med_description(rpt_render,0.20,becont)
         SET med_desc = " "
         SET tmp_get_work_room = sub_get_work_room(0)
         SET d0 = med_last_dose(rpt_render,tmp_work_room,becont)
       ENDWHILE
       SET med_last_dose_text = " "
       IF ((work->encntrs[e].meds[m].pt_cnt > 0))
        FOR (pt = 1 TO work->encntrs[e].meds[m].pt_cnt)
          SET tmp_height = (med_next_dose_height+ med_addtl_notes_height)
          IF (((_yoffset+ tmp_height) >= y_end_of_page))
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET med_desc = "Continued from Previous Page"
           SET d0 = med_description(rpt_render,0.20,becont)
           SET med_desc = " "
          ENDIF
          SET next_dose_text = " "
          SET next_dose_text = format(work->encntrs[e].meds[m].pending_tasks[pt].sch_dt_tm,
           "mm-dd hh:mm;;d")
          SET d0 = med_next_dose(rpt_render)
          IF (_yoffset >= y_end_of_page)
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET med_desc = "Continued from Previous Page"
           SET d0 = med_description(rpt_render,0.20,becont)
           SET med_desc = " "
          ENDIF
          FOR (d = 1 TO work->encntrs[e].meds[m].d_cnt)
           IF (_yoffset >= y_end_of_page)
            SET d0 = sub_foot_page(0)
            SET d0 = sub_head_page(0)
            SET med_desc = "Continued from Previous Page"
            SET d0 = med_description(rpt_render,0.20,becont)
            SET med_desc = " "
           ENDIF
           SET d0 = med_assoc_dtas(rpt_render)
          ENDFOR
          SET d0 = med_addtl_notes(rpt_render)
        ENDFOR
       ENDIF
       SET next_dose_text = " "
       IF (((next_dose_cnt - work->encntrs[e].meds[m].pt_cnt) > 0))
        SET tmp_cnt = (next_dose_cnt - work->encntrs[e].meds[m].pt_cnt)
        FOR (pt = 1 TO tmp_cnt)
          SET tmp_height = (med_next_dose_height+ med_addtl_notes_height)
          IF (((_yoffset+ tmp_height) >= y_end_of_page))
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET med_desc = "Continued from Previous Page"
           SET d0 = med_description(rpt_render,0.20,becont)
           SET med_desc = " "
          ENDIF
          SET next_dose_text = " "
          SET d0 = med_next_dose(rpt_render)
          IF (_yoffset >= y_end_of_page)
           SET d0 = sub_foot_page(0)
           SET d0 = sub_head_page(0)
           SET med_desc = "Continued from Previous Page"
           SET d0 = med_description(rpt_render,0.20,becont)
           SET med_desc = " "
          ENDIF
          FOR (d = 1 TO work->encntrs[e].meds[m].d_cnt)
           IF (_yoffset >= y_end_of_page)
            SET d0 = sub_foot_page(0)
            SET d0 = sub_head_page(0)
            SET med_desc = "Continued from Previous Page"
            SET d0 = med_description(rpt_render,0.20,becont)
            SET med_desc = " "
           ENDIF
           SET d0 = med_assoc_dtas(rpt_render)
          ENDFOR
          SET d0 = med_addtl_notes(rpt_render)
        ENDFOR
       ENDIF
       SET d0 = report_divider(rpt_render)
      ENDIF
     ENDFOR
     SET m = 0
     IF (s IN (1, 2))
      SET tmp_height = med_blank_sch_height
     ELSEIF (s=3)
      SET tmp_height = med_blank_prn_height
     ELSE
      SET tmp_height = med_blank_iv_height
     ENDIF
     FOR (b = 1 TO blank_med_cnt)
       IF (print_section_desc_ind=1)
        SET print_section_desc_ind = 0
        SET d0 = mar_section_head(rpt_render)
        SET d0 = report_divider(rpt_render)
       ENDIF
       IF (((_yoffset+ tmp_height) >= y_end_of_page))
        SET d0 = sub_foot_page(0)
        SET d0 = sub_head_page(0)
       ENDIF
       SET med_desc = " "
       SET d0 = med_description(rpt_render,0.20,becont)
       IF (s IN (1, 2))
        SET d0 = med_blank_details_sch(rpt_render)
       ELSEIF (s=3)
        SET d0 = med_blank_details_sch(rpt_render)
        SET d0 = med_blank_details_prn(rpt_render)
       ELSE
        SET d0 = med_blank_details_iv(rpt_render)
       ENDIF
       SET d0 = med_next_dose(rpt_render)
       SET d0 = med_addtl_notes(rpt_render)
       SET d0 = report_divider(rpt_render)
     ENDFOR
     IF (_yoffset >= y_end_of_page)
      SET d0 = sub_foot_page(0)
      SET d0 = sub_head_page(0)
     ENDIF
   ENDFOR
   SET s = 0
   IF (((_yoffset+ refused_med_height) >= y_end_of_page))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = refused_medications(rpt_render)
   FOR (r = 1 TO refused_med_cnt)
     SET d0 = refused_med_notes(rpt_render)
   ENDFOR
   SET d0 = report_divider(rpt_render)
   IF (((_yoffset+ prn_angio_height) >= y_end_of_page))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
   ENDIF
   SET d0 = prn_angio_head(rpt_render)
   SET d0 = report_divider(rpt_render)
   FOR (p = 1 TO prn_angio_cnt)
     SET d0 = prn_angio_notes(rpt_render)
   ENDFOR
   SET d0 = report_divider(rpt_render)
   SET d0 = sub_foot_report(0)
 ENDFOR
 IF (test_ind=1)
  SET d0 = finalizereport( $OUTDEV)
 ENDIF
#exit_script
 IF (test_ind=1)
  CALL echorecord(work)
 ENDIF
END GO
