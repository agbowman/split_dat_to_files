CREATE PROGRAM bhs_rpt_admin_audit_full:dba
 PROMPT
  "output:" = "MINE",
  "Nurse Unit Display Key:" = 686926.00,
  "execute from explorerMenu" = "1",
  "All Units:" = "0"
  WITH outdev, unit_cd_disp_key, runtype,
  allunits
 EXECUTE bhs_sys_stand_subroutine
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
     2 firstname = vc
     2 lastname = vc
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
       3 dose = vc
       3 start_dt_tm = dq8
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
       3 ordevent[*]
         4 diluent = vc
         4 dispense_amount = i4
         4 ddose = f8
         4 dose_unit = vc
         4 droute = vc
         4 schedulenotused = vc
         4 dispense_datetime = vc
         4 drug_cost = i4
         4 bag = vc
         4 eventid = f8
         4 parent_event_id = f8
         4 primary_nemonic = vc
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
 SET work->beg_dt_tm = cnvtdatetime((curdate - 1),0)
 SET work->end_dt_tm = cnvtdatetime((curdate - 1),235959)
 SET work->unit_cd =  $UNIT_CD_DISP_KEY
 IF ((work->unit_cd <= 0.00)
  AND ( $ALLUNITS=0))
  CALL echo("Nurse Unit not found.")
  GO TO exit_progam
 ENDIF
 CALL echo( $ALLUNITS)
 SELECT INTO "nl:"
  FROM location l,
   encounter e,
   encntr_domain ed,
   encntr_alias ea,
   person_alias pa,
   person p
  PLAN (l
   WHERE (((l.location_cd=work->unit_cd)
    AND ( $ALLUNITS=0)) OR (l.location_cd > 0
    AND ( $ALLUNITS=1)))
    AND (l.organization_id=
   (SELECT
    ll.organization_id
    FROM location ll
    WHERE ll.location_cd IN (673936, 673937, 673938, 589763.00, 589764.00,
    589764.00, 580062482, 780848199.0)
     AND ll.location_type_cd=783
     AND ll.active_ind=1))
    AND l.location_type_cd=794
    AND l.active_ind=1)
   JOIN (ed
   WHERE ed.loc_nurse_unit_cd=l.location_cd
    AND ed.beg_effective_dt_tm <= cnvtdatetime(work->end_dt_tm)
    AND ed.end_effective_dt_tm >= cnvtdatetime(work->beg_dt_tm)
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
    work->e_cnt += 1, stat = alterlist(work->encntrs,work->e_cnt), work->encntrs[work->e_cnt].
    reg_dt_tm = format(e.reg_dt_tm,";;Q"),
    work->encntrs[work->e_cnt].person_id = p.person_id, work->encntrs[work->e_cnt].encntr_id = e
    .encntr_id, work->encntrs[work->e_cnt].name = trim(p.name_full_formatted,3),
    work->encntrs[work->e_cnt].firstname = trim(p.name_first,3), work->encntrs[work->e_cnt].lastname
     = trim(p.name_last,3), work->encntrs[work->e_cnt].dob = format(cnvtdatetimeutc(datetimezone(p
       .birth_dt_tm,p.birth_tz),1),"MM-DD-YYYY;;d"),
    work->encntrs[work->e_cnt].fin = trim(ea.alias,3), work->encntrs[work->e_cnt].mrn = format(trim(
      pa.alias,3),"#######;P0"), work->encntrs[work->e_cnt].unit = trim(uar_get_code_display(ed
      .loc_nurse_unit_cd),3),
    work->encntrs[work->e_cnt].room = trim(uar_get_code_display(ed.loc_room_cd),3), work->encntrs[
    work->e_cnt].allergy_text = "NKA", work->encntrs[work->e_cnt].filename = build(trim(substring(1,
       14,trim(cnvtlower(cnvtalphanum(p.name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(
        cnvtlower(cnvtalphanum(p.name_first_key,2)),4)),3),".ps")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  GO TO exit_program
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
   order_id = o.order_id,
   work->encntrs[d.seq].meds[m_cnt].order_detail_display_line = trim(o.order_detail_display_line,3)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  ce.person_id, ce.encntr_id, parentorder = work->encntrs[d1.seq].meds[d2.seq].order_id,
  o.order_id, cem.substance_lot_number, cem.event_id,
  ce.event_end_dt_tm
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   clinical_event ce,
   ce_med_result cem,
   order_catalog oc
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (o.encntr_id=work->encntrs[d1.seq].encntr_id)
    AND (((o.template_order_id=work->encntrs[d1.seq].meds[d2.seq].order_id)) OR ((o.order_id=work->
   encntrs[d1.seq].meds[d2.seq].order_id)
    AND o.template_order_id=0))
    AND  NOT (((o.order_status_cd+ 0) IN (2542.00, 2544.00))))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.event_class_cd=outerjoin(232.00,236)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->beg_dt_tm) AND cnvtdatetime(work->end_dt_tm)
    AND ce.event_reltn_cd=132.00)
   JOIN (cem
   WHERE cem.event_id=ce.event_id
    AND cem.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (oc
   WHERE oc.catalog_cd=ce.catalog_cd
    AND oc.active_ind=1)
  ORDER BY ce.person_id, ce.encntr_id, parentorder,
   o.order_id, cem.substance_lot_number DESC, cem.event_id,
   ce.event_end_dt_tm DESC
  HEAD ce.person_id
   stat = 0
  HEAD ce.encntr_id
   stat = 0
  HEAD parentorder
   eventcnt = 0
  HEAD o.order_id
   stat = 0
  HEAD cem.substance_lot_number
   stat = 0
  HEAD cem.event_id
   eventcnt += 1, stat = alterlist(work->encntrs[d1.seq].meds[d2.seq].ordevent,eventcnt), tdose = 0.0,
   begindose = 0.0, work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].dose_unit =
   uar_get_code_display(cem.dosage_unit_cd), work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].
   droute = uar_get_code_display(cem.admin_route_cd),
   work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].dispense_datetime = format(cnvtdatetime(ce
     .event_end_dt_tm),"YYYYMMDDHHMMSS;;q"), work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].
   bag = cem.substance_lot_number, work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].eventid = ce
   .event_id,
   work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].primary_nemonic = oc.primary_mnemonic
  HEAD ce.event_end_dt_tm
   stat = 0
  DETAIL
   IF ((work->encntrs[d1.seq].meds[d2.seq].med_type=4))
    IF (cem.iv_event_cd IN (734.00, 735.00))
     tdose += cem.admin_dosage
    ELSEIF (cem.iv_event_cd IN (733.00))
     begindose = cem.initial_dosage
    ENDIF
   ELSE
    tdose = cem.admin_dosage
   ENDIF
  FOOT  ce.event_end_dt_tm
   stat = 0
  FOOT  cem.event_id
   IF ((work->encntrs[d1.seq].meds[d2.seq].med_type=4))
    IF (tdose > 0)
     work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].ddose = tdose, work->encntrs[d1.seq].meds[
     d2.seq].ordevent[eventcnt].dispense_amount = 1
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].ddose = begindose, work->encntrs[d1.seq].
     meds[d2.seq].ordevent[eventcnt].dispense_amount = 0
    ENDIF
   ELSE
    work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].ddose = tdose
    IF (ce.result_status_cd IN (36.00))
     work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].dispense_amount = 0
    ELSE
     work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].dispense_amount = 1
    ENDIF
   ENDIF
   IF (cem.diluent_type_cd > 0)
    work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].diluent = uar_get_code_display(cem
     .diluent_type_cd), work->encntrs[d1.seq].meds[d2.seq].ordevent[eventcnt].parent_event_id = ce
    .parent_event_id
   ENDIF
  WITH nocounter, format, format(date,";;q"),
   separator = " "
 ;end select
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
 IF (( $RUNTYPE="0"))
  SET var_output = "adminreport.dat"
  SET sep = "|"
 ELSE
  SET var_output =  $OUTDEV
  SET sep = " "
 ENDIF
 DECLARE t = vc WITH noconstant(" ")
 SELECT INTO value(var_output)
  namefirst = substring(1,50,work->encntrs[d.seq].firstname), namelast = substring(1,50,work->
   encntrs[d.seq].lastname), medtype = work->encntrs[d.seq].meds[d1.seq].med_type,
  eventid = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].eventid, bag = work->encntrs[d.seq].
  meds[d1.seq].ordevent[d2.seq].bag, fin = substring(1,12,build(work->encntrs[d.seq].fin)),
  cmrn = substring(1,7,work->encntrs[d.seq].mrn), drug_code_order_id = cnvtstring(work->encntrs[d.seq
   ].meds[d1.seq].order_id), drug_text = substring(1,100,work->encntrs[d.seq].meds[d1.seq].
   order_detail_display_line),
  od_line = check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].od_line)), generic_drug_name =
  check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].desc)), ndc = "N/A",
  diluent = substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].diluent),
  dispense_amount = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount, dose = work->
  encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].ddose,
  dose_unit = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dose_unit, route = substring(1,50,
   work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].droute), schedule_code = "n/a",
  dispense_datetime = substring(1,20,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].
   dispense_datetime), drug_cost = 0, status =
  IF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)
   AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "BeginBag"
  ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)
   AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "Infused/bolus"
  ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)) "NotDone"
  ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)) "Dispensed"
  ENDIF
  ,
  primary_nemonic = substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].
   primary_nemonic), parent_event_id = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].
  parent_event_id
  FROM (dummyt d  WITH seq = size(work->encntrs,5)),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE maxrec(d1,size(work->encntrs[d.seq].meds,5)))
   JOIN (d1
   WHERE maxrec(d2,size(work->encntrs[d.seq].meds[d1.seq].ordevent,5)))
   JOIN (d2)
  ORDER BY fin, medtype, bag DESC
  WITH nocounter, format, format(date,"YYYYMMDDHHMMSS;;q"),
   separator = value(sep)
 ;end select
 IF (( $RUNTYPE="0"))
  CALL emailfile(var_output,var_output,"CIScore@baystatehealth.org","Discern Report: admin audit",0)
  SET filenamein = var_output
  SET filenameout = var_output
  SET ipaddress = "172.17.3.11"
  SET folderdir = "/tempfiles/hold/egate/cis_rxobot"
  SET username = "egtest"
  SET password = "egtest"
  CALL ftpfile(filenamein,filenameout,ipaddress,folderdir,username,
   password)
 ENDIF
#exit_program
END GO
