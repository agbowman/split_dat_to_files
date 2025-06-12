CREATE PROGRAM bhs_rpt_downtime_mar
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
    AND cv.active_ind=1
    AND cv.data_status_cd=25)
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
    AND (work->unit_str IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
   "ESB", "ESC", "ESD", "ESP", "ESX",
   "ESW"))) OR ( NOT ((work->unit_str IN ("EDPEDI", "EDMAIN", "EDA", "EDGTA", "ESA",
   "ESB", "ESC", "ESD", "ESP", "ESX",
   "ESW"))))) )
    work->e_cnt += 1, stat = alterlist(work->encntrs,work->e_cnt), work->encntrs[work->e_cnt].
    reg_dt_tm = format(e.reg_dt_tm,";;Q"),
    work->encntrs[work->e_cnt].person_id = p.person_id, work->encntrs[work->e_cnt].encntr_id = e
    .encntr_id, work->encntrs[work->e_cnt].name = build2(trim(p.name_full_formatted,3)," (",trim(
      uar_get_code_display(e.encntr_type_cd),3),")"),
    work->encntrs[work->e_cnt].dob = format(p.birth_dt_tm,"MM-DD-YYYY;;d"), work->encntrs[work->e_cnt
    ].fin = trim(ea.alias,3), work->encntrs[work->e_cnt].mrn = trim(pa.alias,3),
    work->encntrs[work->e_cnt].unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd),3), work->
    encntrs[work->e_cnt].room = trim(uar_get_code_display(ed.loc_room_cd),3), work->encntrs[work->
    e_cnt].allergy_text = "NKA",
    work->encntrs[work->e_cnt].filename = build(trim(substring(1,5,trim(cnvtlower(cnvtalphanum(p
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
   WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
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
   WHERE (f.frequency_id= Outerjoin(o.frequency_id)) )
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
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cen
   WHERE (cen.event_id= Outerjoin(ce.event_id)) )
   JOIN (lb
   WHERE (lb.parent_entity_id= Outerjoin(cen.ce_event_note_id))
    AND (lb.parent_entity_name= Outerjoin("ce_event_note")) )
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
    AND ce1.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cmr1
   WHERE ce1.event_id=cmr1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd, cs8_notdone_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cmr2
   WHERE ce2.event_id=cmr2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(sysdate))
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
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remallergies_text = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpatient_allergies = i2 WITH noconstant(0), protect
 DECLARE _remmed_desc = i4 WITH noconstant(1), protect
 DECLARE _bcontmed_description = i2 WITH noconstant(0), protect
 DECLARE _remmed_order_details = i4 WITH noconstant(1), protect
 DECLARE _bcontmed_details = i2 WITH noconstant(0), protect
 DECLARE _remmed_order_instructions = i4 WITH noconstant(1), protect
 DECLARE _bcontmed_instructions = i2 WITH noconstant(0), protect
 DECLARE _remlast_dose = i4 WITH noconstant(1), protect
 DECLARE _bcontmed_last_dose = i2 WITH noconstant(0), protect
 DECLARE _helvetica90 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica13b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica15b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen21s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (report_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (report_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   DECLARE __title_2 = vc WITH noconstant(build2(build2("Printed at ",format(cnvtdatetime(sysdate),
       "mm-dd-yyyy hh:mm;;d")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica15b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Permanent Record",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__title_2)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.500
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Downtime Medication Administration Record",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (patient_demographics(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_demographicsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (patient_demographicsabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.630000), private
   DECLARE __patient_name = vc WITH noconstant(build2(trim(work->encntrs[e].name,3),char(0))),
   protect
   DECLARE __patient_dob = vc WITH noconstant(build2(build2("DOB ",trim(work->encntrs[e].dob,3)),char
     (0))), protect
   DECLARE __patient_location = vc WITH noconstant(build2(build2("Location ",trim(work->encntrs[e].
       unit,3)," ",trim(work->encntrs[e].room,3)),char(0))), protect
   DECLARE __patient_acct_num = vc WITH noconstant(build2(build2("ACCT# ",trim(work->encntrs[e].fin,3
       )),char(0))), protect
   DECLARE __patient_mrn = vc WITH noconstant(build2(build2("MRN# ",trim(work->encntrs[e].mrn,3)),
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.510
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_dob)
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.510
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_location)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_acct_num)
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_mrn)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (patient_allergies(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_allergiesabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (patient_allergiesabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_allergies_text = f8 WITH noconstant(0.0), private
   DECLARE __allergies_text = vc WITH noconstant(build2(trim(allergies_text,3),char(0))), protect
   IF (bcontinue=0)
    SET _remallergies_text = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.198)
   SET rptsd->m_width = 6.802
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremallergies_text = _remallergies_text
   IF (_remallergies_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergies_text,((size(
        __allergies_text) - _remallergies_text)+ 1),__allergies_text)))
    SET drawheight_allergies_text = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remallergies_text = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergies_text,((size(__allergies_text
        ) - _remallergies_text)+ 1),__allergies_text)))))
     SET _remallergies_text += rptsd->m_drawlength
    ELSE
     SET _remallergies_text = 0
    ENDIF
    SET growsum += _remallergies_text
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = 0.229
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.198)
   SET rptsd->m_width = 6.802
   SET rptsd->m_height = drawheight_allergies_text
   IF (ncalc=rpt_render
    AND _holdremallergies_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergies_text,((
       size(__allergies_text) - _holdremallergies_text)+ 1),__allergies_text)))
   ELSE
    SET _remallergies_text = _holdremallergies_text
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (site_legends(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = site_legendsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (site_legendsabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.700000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 0.198),2.771,1.448,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.323),(offsety+ 0.198),4.677,1.448,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 0.573)
    SET rptsd->m_width = 2.646
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("1. INFUSING WELL NO FILTRATION",char(
       0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.740)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NO REDNESS",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 0.573)
    SET rptsd->m_width = 2.646
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("2. SITE RED INFILTRATED AND REMOVED",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.823)
    SET rptsd->m_x = (offsetx+ 0.573)
    SET rptsd->m_width = 2.646
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("3. DISLODGED AND REMOVED",char(0)))
    SET rptsd->m_y = (offsety+ 0.990)
    SET rptsd->m_x = (offsetx+ 0.573)
    SET rptsd->m_width = 2.646
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("4. RESTARTED",char(0)))
    SET rptsd->m_y = (offsety+ 1.146)
    SET rptsd->m_x = (offsetx+ 0.573)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "5. PRN ANGIO IN PLACE AND FLUSHES WELL",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.771
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("IV SITE SCALE",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 3.323)
    SET rptsd->m_width = 4.677
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SITE CODES",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 4.646)
    SET rptsd->m_width = 0.708
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BUTTOCKS",char(0)))
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("A - RA THIGH",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("B - LA THIGH",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("C - RL THIGH",char(0)))
    SET rptsd->m_y = (offsety+ 0.823)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("D - LL THIGH",char(0)))
    SET rptsd->m_y = (offsety+ 0.990)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("E - PERIPHERAL IV",char(0)))
    SET rptsd->m_y = (offsety+ 1.146)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("F - CENTRAL IV",char(0)))
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("G - EPIDURAL CATH",char(0)))
    SET rptsd->m_y = (offsety+ 1.469)
    SET rptsd->m_x = (offsetx+ 3.396)
    SET rptsd->m_width = 1.802
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("H - VENEOUS ACCESS DEVICE",char(0)))
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 4.646)
    SET rptsd->m_width = 0.708
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("I - RUOQ",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.646)
    SET rptsd->m_width = 0.708
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("J - LUOQ",char(0)))
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("K - RT ARM",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("L - LT ARM",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("M - RT FOREARM",char(0)))
    SET rptsd->m_y = (offsety+ 0.823)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("N - LT FOREARM",char(0)))
    SET rptsd->m_y = (offsety+ 0.990)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("O - PRN ANGIO",char(0)))
    SET rptsd->m_y = (offsety+ 1.146)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("P - UMBILICAL IV",char(0)))
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 5.469)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Q - ABDOMEN",char(0)))
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("R - UPPER",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("S - LOWER",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("T - INNER",char(0)))
    SET rptsd->m_y = (offsety+ 0.823)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("U - OUTER",char(0)))
    SET rptsd->m_y = (offsety+ 0.990)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("V - MEDIAL",char(0)))
    SET rptsd->m_y = (offsety+ 1.146)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.354
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("W - PROSTERIOR",char(0)))
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 6.667)
    SET rptsd->m_width = 1.448
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("X - VENTRO-GLUTEAL",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (mar_section_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = mar_section_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (mar_section_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica13b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(section_desc,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (report_divider(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_dividerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (report_dividerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.500),(offsety+ 0.068),(offsetx+ 8.000),(offsety+
     0.068))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_description(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_descriptionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_descriptionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_med_desc = f8 WITH noconstant(0.0), private
   DECLARE __med_desc = vc WITH noconstant(build2(trim(med_desc,3),char(0))), protect
   IF (bcontinue=0)
    SET _remmed_desc = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.865)
   SET rptsd->m_width = 7.146
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmed_desc = _remmed_desc
   IF (_remmed_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmed_desc,((size(
        __med_desc) - _remmed_desc)+ 1),__med_desc)))
    SET drawheight_med_desc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmed_desc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmed_desc,((size(__med_desc) -
       _remmed_desc)+ 1),__med_desc)))))
     SET _remmed_desc += rptsd->m_drawlength
    ELSE
     SET _remmed_desc = 0
    ENDIF
    SET growsum += _remmed_desc
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MED:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.865)
   SET rptsd->m_width = 7.146
   SET rptsd->m_height = drawheight_med_desc
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
   IF (ncalc=rpt_render
    AND _holdremmed_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmed_desc,((size(
        __med_desc) - _holdremmed_desc)+ 1),__med_desc)))
   ELSE
    SET _remmed_desc = _holdremmed_desc
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_details(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_detailsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_detailsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_med_order_details = f8 WITH noconstant(0.0), private
   DECLARE __med_order_details = vc WITH noconstant(build2(med_details_text,char(0))), protect
   IF (bcontinue=0)
    SET _remmed_order_details = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmed_order_details = _remmed_order_details
   IF (_remmed_order_details > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmed_order_details,((
       size(__med_order_details) - _remmed_order_details)+ 1),__med_order_details)))
    SET drawheight_med_order_details = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmed_order_details = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmed_order_details,((size(
        __med_order_details) - _remmed_order_details)+ 1),__med_order_details)))))
     SET _remmed_order_details += rptsd->m_drawlength
    ELSE
     SET _remmed_order_details = 0
    ENDIF
    SET growsum += _remmed_order_details
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_med_order_details
   IF (ncalc=rpt_render
    AND _holdremmed_order_details > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmed_order_details,
       ((size(__med_order_details) - _holdremmed_order_details)+ 1),__med_order_details)))
   ELSE
    SET _remmed_order_details = _holdremmed_order_details
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_instructions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_instructionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_instructionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_med_order_instructions = f8 WITH noconstant(0.0), private
   DECLARE __med_order_instructions = vc WITH noconstant(build2(med_instructions_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remmed_order_instructions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmed_order_instructions = _remmed_order_instructions
   IF (_remmed_order_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmed_order_instructions,
       ((size(__med_order_instructions) - _remmed_order_instructions)+ 1),__med_order_instructions)))
    SET drawheight_med_order_instructions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmed_order_instructions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmed_order_instructions,((size(
        __med_order_instructions) - _remmed_order_instructions)+ 1),__med_order_instructions)))))
     SET _remmed_order_instructions += rptsd->m_drawlength
    ELSE
     SET _remmed_order_instructions = 0
    ENDIF
    SET growsum += _remmed_order_instructions
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_med_order_instructions
   IF (ncalc=rpt_render
    AND _holdremmed_order_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremmed_order_instructions,((size(__med_order_instructions) -
       _holdremmed_order_instructions)+ 1),__med_order_instructions)))
   ELSE
    SET _remmed_order_instructions = _holdremmed_order_instructions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_last_dose(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_last_doseabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_last_doseabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_last_dose = f8 WITH noconstant(0.0), private
   DECLARE __last_dose = vc WITH noconstant(build2(med_last_dose_text,char(0))), protect
   IF (bcontinue=0)
    SET _remlast_dose = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 6.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlast_dose = _remlast_dose
   IF (_remlast_dose > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_dose,((size(
        __last_dose) - _remlast_dose)+ 1),__last_dose)))
    SET drawheight_last_dose = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_dose = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_dose,((size(__last_dose) -
       _remlast_dose)+ 1),__last_dose)))))
     SET _remlast_dose += rptsd->m_drawlength
    ELSE
     SET _remlast_dose = 0
    ENDIF
    SET growsum += _remlast_dose
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LAST DOSE:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 6.625
   SET rptsd->m_height = drawheight_last_dose
   IF (ncalc=rpt_render
    AND _holdremlast_dose > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_dose,((size(
        __last_dose) - _holdremlast_dose)+ 1),__last_dose)))
   ELSE
    SET _remlast_dose = _holdremlast_dose
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_next_dose(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_next_doseabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_next_doseabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NEXT DOSE:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(next_dose_text,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 5.573
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "TIME __________  SITE __________  OBS _________  INITIALS ________  CIS ______",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_assoc_dtas(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_assoc_dtasabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_assoc_dtasabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE __dta_desc = vc WITH noconstant(build2(trim(work->encntrs[e].meds[m].dtas[d].desc,3),char(
      0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.448)
    SET rptsd->m_width = 2.198
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pre __________  Post __________",char
      (0)))
    SET rptsd->m_flags = 8
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dta_desc)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_addtl_notes(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_addtl_notesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_addtl_notesabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ADDITIONAL DOCUMENTATION:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (refused_medications(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = refused_medicationsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (refused_medicationsabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica13b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("OMITTED / REFUSED MEDICATIONS",char(0
       )))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.067
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.427
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "BRADYCARDIA, BRADYPNEA, FAMILY REFUSED, HYPERTENSION, HYPOTENSION, INFLITRATED SITE, NO BLOOD RETURN, ORDER DIS",
       "CONTINUED, PATIENT NPO, PATIENT REFUSED, PATIENT NAUSEATED, PATIENT REFUSED, TACHYCARDIA, TACHYPNEA"
       ),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (refused_med_notes(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = refused_med_notesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (refused_med_notesabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "MED _____________________  REASON _________________  TIME __________  INITIALS __________  CIS ______",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (prn_angio_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = prn_angio_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (prn_angio_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica13b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PRN ANGIO DOCUMENTATION",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (prn_angio_notes(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = prn_angio_notesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (prn_angio_notesabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "TIME __________  SITE __________  OBS __________  INITIALS __________  CIS ______",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (signature_line(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = signature_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (signature_lineabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "INITIALS ______  PRINTED NAME ______________________  SIGNATURE ___________________  TITLE ________",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (page_foot(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (page_footabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE __page_num = vc WITH noconstant(build2(build2("PAGE ",trim(build2(cur_page),3)),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (cur_end_report=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("--- END OF REPORT ---",char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__page_num)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_blank_details_sch(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_blank_details_schabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_blank_details_schabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "DOSE _____________________  ROUTE ______________  FREQUENCY ______________  DURATION ___________",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_blank_details_prn(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_blank_details_prnabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_blank_details_prnabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PRN REASON ____________________",char
      (0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (med_blank_details_iv(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = med_blank_details_ivabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (med_blank_details_ivabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "RATE _____________________  DURATION _______________________",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_DOWNTIME_MAR"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.00
   SET rptreport->m_marginright = 0.00
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.00
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 15
   SET rptfont->m_bold = rpt_on
   SET _helvetica15b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _helvetica90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 13
   SET rptfont->m_bold = rpt_on
   SET _helvetica13b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.021
   SET _pen21s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
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
 SUBROUTINE (sub_head_report(zero1=i2) =null)
   IF (((test_ind=1
    AND e=1) OR (test_ind=0)) )
    SET d0 = initializereport(0)
   ENDIF
   SET cur_page = 0
   SET d0 = sub_head_page(1)
 END ;Subroutine
 SUBROUTINE (sub_head_page(beg_report=i2) =null)
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
 SUBROUTINE (sub_get_work_room(zero2=i2) =null)
   RETURN((y_end_of_page - _yoffset))
 END ;Subroutine
 SUBROUTINE (sub_foot_page(end_report=i2) =null)
   SET cur_page += 1
   SET _yoffset = y_page_foot
   SET d0 = page_foot(rpt_render)
   IF (end_report=0)
    SET d0 = pagebreak(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (sub_foot_report(zero4=i2) =null)
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
    CALL echo(work->encntrs[e].filename)
    SET d0 = finalizereport(work->encntrs[e].filename)
    CALL echo("After finalize")
    SET spool value(work->encntrs[e].filename)  $OUTDEV
    SET tmp_remove = build2('set stat = remove("',work->encntrs[e].filename,'") go')
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
   ENDIF
   SET cur_end_report = 0
 END ;Subroutine
 FOR (e = 1 TO work->e_cnt)
   EXECUTE bhs_sys_pause 10
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
