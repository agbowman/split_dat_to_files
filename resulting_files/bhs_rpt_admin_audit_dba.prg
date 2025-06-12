CREATE PROGRAM bhs_rpt_admin_audit:dba
 PROMPT
  "output:" = "MINE",
  "Nurse Unit Display Key:" = 0
  WITH outdev, unit_cd_disp_key
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
       3 o_cnt = i4
       3 catalog_cd = f8
       3 template_ind = i2
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
       3 last_task_dt_tm = dq8
       3 last_task_result = vc
       3 last_task_comments = vc
       3 pt_cnt = i4
       3 order_detail_display_line = vc
       3 desc = vc
       3 order_id = f8
       3 med_type = i2
       3 od_line = vc
       3 dispense_amount = i4
       3 dose = f8
       3 dose_unit = vc
       3 droute = vc
       3 schedulenotused = vc
       3 dispense_datetime = vc
       3 drug_cost = i4
 )
 DECLARE test_ind = i2
 DECLARE cs4_mrn_cd = f8 WITH constant(validatecodevalue("MEANING",4,"CMRN"))
 DECLARE cs8_auth_cd = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED"))
 DECLARE cs8_notdone_cd = f8 WITH constant(validatecodevalue("MEANING",8,"NOT DONE"))
 DECLARE cs24_child_cd = f8 WITH constant(validatecodevalue("MEANING",24,"CHILD"))
 DECLARE cs53_med_cd = f8 WITH constant(validatecodevalue("MEANING",53,"MED"))
 DECLARE cs53_placeholder_cd = f8 WITH constant(validatecodevalue("MEANING",53,"PLACEHOLDER"))
 DECLARE cs180_begin_cd = f8 WITH constant(validatecodevalue("MEANING",180,"BEGIN"))
 DECLARE cs180_bolus_cd = f8 WITH constant(validatecodevalue("MEANING",180,"BOLUS"))
 DECLARE cs180_infuse_cd = f8 WITH constant(validatecodevalue("MEANING",180,"INFUSE"))
 DECLARE cs180_ratechg_cd = f8 WITH constant(validatecodevalue("MEANING",180,"RATECHG"))
 DECLARE cs180_sitechg_cd = f8 WITH constant(validatecodevalue("MEANING",180,"SITECHG"))
 DECLARE cs180_waste_cd = f8 WITH constant(validatecodevalue("MEANING",180,"WASTE"))
 DECLARE cs319_fin_cd = f8 WITH constant(validatecodevalue("MEANING",319,"FIN NBR"))
 DECLARE cs6000_pharm_cd = f8 WITH constant(validatecodevalue("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_future_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"FUTURE"))
 DECLARE cs6004_incomplete_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"INCOMPLETE"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"PENDING"))
 DECLARE cs12025_canceled_cd = f8 WITH constant(validatecodevalue("MEANING",12025,"CANCELED"))
 DECLARE cs16449_instructions_cd = f8 WITH constant(00099.0)
 DECLARE cs16449_holdfor_cd = f8 WITH constant(000999.0)
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    CALL echo(concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
      val))
    GO TO exit_script
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SET work->beg_dt_tm = cnvtdatetime(curdate,0)
 SET work->end_dt_tm = cnvtdatetime((curdate+ 2),235959)
 SET work->unit_cd =  $UNIT_CD_DISP_KEY
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
 IF (curqual <= 0)
  GO TO exit_script
 ENDIF
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
    AND  NOT (o.order_status_cd IN (2542.00, 2544.00))
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
   order_id = o.order_id,
   work->encntrs[d.seq].meds[m_cnt].order_detail_display_line = trim(o.order_detail_display_line,3),
   CALL echo(o.order_id)
  WITH nocounter
 ;end select
 CALL echorecord(work)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (od
   WHERE (work->encntrs[d1.seq].meds[d2.seq].order_id=od.order_id)
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
 SELECT INTO  $OUTDEV
  medtype = work->encntrs[d1.seq].meds[d2.seq].med_type, name = substring(1,40,work->encntrs[d1.seq].
   name), fin = work->encntrs[d1.seq].fin,
  o.order_id, o.order_mnemonic, ce.event_id,
  eventclasscd = uar_get_code_display(ce.event_class_cd), eventrelcd = substring(1,10,
   uar_get_code_display(ce.event_reltn_cd)), ce.event_reltn_cd,
  ce.event_end_dt_tm, ce.result_val, result_stat_cd = uar_get_code_display(ce.result_status_cd),
  ce.event_end_dt_tm, cem.substance_lot_number, iv_event_cd = uar_get_code_display(cem.iv_event_cd),
  cem.*
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   clinical_event ce,
   ce_med_result cem
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (o.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND (((o.template_order_id=work->encntrs[d1.seq].meds[d2.seq].order_id)) OR ((o.order_id=work->
   encntrs[d1.seq].meds[d2.seq].order_id)
    AND o.template_order_id=0
    AND  NOT (o.order_id IN (
   (SELECT
    o1.order_id
    FROM orders o1
    WHERE o1.template_order_id=o.order_id)))))
    AND  NOT (((o.order_status_cd+ 0) IN (2542.00, 2544.00))))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.view_level=1
    AND ce.event_class_cd=outerjoin(232.00,236)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),0)
    AND ce.event_reltn_cd=132.00)
   JOIN (cem
   WHERE cem.event_id=outerjoin(ce.event_id)
    AND cem.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
  ORDER BY ce.person_id, ce.encntr_id, o.order_id,
   cem.substance_lot_number DESC, ce.event_end_dt_tm DESC
  WITH nocounter, format, format(date,";;q"),
   separator = " "
 ;end select
 CALL echorecord(work)
#exit_script
END GO
