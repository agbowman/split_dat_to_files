CREATE PROGRAM bhs_rpt_admin_audit_all3:dba
 PROMPT
  "output:" = "MINE",
  "order_id" = 0,
  "execute from:" = 0
  WITH outdev, order_id, runtype
 EXECUTE bhs_sys_stand_subroutine
 EXECUTE bhs_check_domain:dba
 CALL echo(build("runtype: ", $RUNTYPE))
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
     2 middlename = vc
     2 lastname = vc
     2 dob = vc
     2 mrn = vc
     2 fin = vc
     2 unit = vc
     2 fac = vc
     2 room = vc
     2 allergy_text = vc
     2 a_cnt = i4
     2 allergies[*]
       3 text = vc
     2 m_cnt = i4
     2 meds[*]
       3 o_cnt = i4
       3 catalog_cd = f8
       3 catprimary = vc
       3 template_ind = i2
       3 dose = vc
       3 start_dt_tm = dq8
       3 f_dose = vc
       3 v_dose = vc
       3 v_dose_unit = vc
       3 s_dose = vc
       3 s_dose_unit = vc
       3 order_as_mnemonic = vc
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
       3 med_type = i4
       3 od_line = vc
       3 ordevent[*]
         4 diluent = vc
         4 dispense_amount = i4
         4 ddose = f8
         4 dose_unit = vc
         4 droute = vc
         4 schedulenotused = vc
         4 admin_datetime = dq8
         4 drug_cost = i4
         4 bag = vc
         4 eventid = f8
         4 ordercatprimary = vc
         4 parenteventid = f8
         4 admintotaldose = vc
         4 admintotaldoseunit = vc
 )
 DECLARE test_ind = i2
 DECLARE msgdttime = vc WITH noconstant(" ")
 DECLARE domain = c1
 DECLARE adminline = vc WITH noconstant(" ")
 DECLARE dispenseline = vc WITH noconstant(" ")
 DECLARE dispenselinetemp = vc WITH noconstant(" ")
 DECLARE tline = vc WITH noconstant(" ")
 DECLARE cs319_mrn_cd = f8 WITH constant(validatecodevalue("MEANING",319,"MRN"))
 DECLARE cs319_fin_cd = f8 WITH constant(validatecodevalue("MEANING",319,"FIN NBR"))
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
 DECLARE cs6000_pharm_cd = f8 WITH constant(validatecodevalue("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"ORDERED"))
 DECLARE cs6004_completed_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_future_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"FUTURE"))
 DECLARE cs6004_incomplete_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"INCOMPLETE"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"PENDING"))
 DECLARE cs6004_canceled_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"CANCELED"))
 DECLARE cs6004_deleted_cd = f8 WITH constant(validatecodevalue("MEANING",6004,"DELETED"))
 DECLARE cs12025_canceled_cd = f8 WITH constant(validatecodevalue("MEANING",12025,"CANCELED"))
 DECLARE bmc = f8 WITH constant(673936)
 DECLARE cs16449_instructions_cd = f8 WITH constant(00099.0)
 DECLARE cs16449_holdfor_cd = f8 WITH constant(000999.0)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(work->beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(work->end_dt_tm),";;q"))
 CALL echo("Gather Patient Info")
 CALL echo("All locations")
 SELECT INTO "nl:"
  e.encntr_id, o.order_id, cem.substance_lot_number,
  cem.event_id, ce.event_end_dt_tm, med_type =
  IF (o.prn_ind=1) 3
  ELSEIF (o.iv_ind=1) 4
  ELSEIF (o.freq_type_flag=5) 2
  ELSE 1
  ENDIF
  ,
  seq_mnemonic = substring(1,100,cnvtupper(o.hna_order_mnemonic))
  FROM orders o1,
   ce_med_result cem,
   clinical_event ce,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1,
   person p,
   orders o,
   order_catalog oc,
   frequency_schedule f
  PLAN (o1
   WHERE (o1.order_id= $ORDER_ID))
   JOIN (ce
   WHERE ce.order_id=o1.order_id
    AND ((ce.valid_until_dt_tm+ 0) >= cnvtdatetime(curdate,curtime))
    AND ((ce.view_level+ 0)=1)
    AND ((ce.event_class_cd+ 0) IN (232, 236))
    AND ((ce.event_reltn_cd+ 0)=132.00)
    AND ce.result_status_cd IN (34.00, 35, 25.00, 36))
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cs319_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(cs319_mrn_cd)) )
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(o.catalog_cd)) )
   JOIN (f
   WHERE (f.frequency_id= Outerjoin(o.frequency_id)) )
  ORDER BY e.encntr_id, o.order_id, cem.event_id,
   cem.substance_lot_number DESC, cem.event_id, ce.event_end_dt_tm DESC
  HEAD e.encntr_id
   work->e_cnt += 1, stat = alterlist(work->encntrs,work->e_cnt), work->encntrs[work->e_cnt].
   reg_dt_tm = format(e.reg_dt_tm,";;Q"),
   work->encntrs[work->e_cnt].person_id = p.person_id, work->encntrs[work->e_cnt].encntr_id = e
   .encntr_id, work->encntrs[work->e_cnt].name = trim(p.name_full_formatted,3),
   work->encntrs[work->e_cnt].firstname = trim(p.name_first,3), work->encntrs[work->e_cnt].middlename
    = trim(p.name_middle,3), work->encntrs[work->e_cnt].lastname = trim(p.name_last,3),
   work->encntrs[work->e_cnt].dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz
       ),1),"MM-DD-YYYY;;d"),3), work->encntrs[work->e_cnt].fin = format(trim(ea.alias,3),
    "############;P0"), work->encntrs[work->e_cnt].mrn = format(trim(ea1.alias,3),"#######;P0"),
   work->encntrs[work->e_cnt].unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), work->
   encntrs[work->e_cnt].fac = trim(uar_get_code_display(e.loc_facility_cd),3), work->encntrs[work->
   e_cnt].room = trim(uar_get_code_display(e.loc_room_cd),3),
   m_cnt = 0
  HEAD o.order_id
   m_cnt += 1, stat = alterlist(work->encntrs[work->e_cnt].meds,m_cnt), work->encntrs[work->e_cnt].
   m_cnt = m_cnt,
   work->encntrs[work->e_cnt].meds[m_cnt].med_type = med_type, work->encntrs[work->e_cnt].meds[m_cnt]
   .catalog_cd = o.catalog_cd, work->encntrs[work->e_cnt].meds[m_cnt].catprimary = oc
   .primary_mnemonic,
   work->encntrs[work->e_cnt].meds[m_cnt].desc = build2(trim(o.hna_order_mnemonic,3)," (",trim(o
     .order_mnemonic,3),")"), work->encntrs[work->e_cnt].meds[m_cnt].freq = trim(uar_get_code_display
    (f.frequency_cd),3), work->encntrs[work->e_cnt].meds[m_cnt].comments_ind = o.order_comment_ind,
   work->encntrs[work->e_cnt].meds[m_cnt].order_id =
   IF (o.template_order_id >= 0) o.order_id
   ELSE o.template_order_id
   ENDIF
   , work->encntrs[work->e_cnt].meds[m_cnt].order_detail_display_line = trim(o
    .order_detail_display_line,3), eventcnt = 0
  HEAD cem.event_id
   eventcnt += 1, stat = alterlist(work->encntrs[work->e_cnt].meds[m_cnt].ordevent,eventcnt), tdose
    = 0.0,
   begindose = 0.0, work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].dose_unit =
   uar_get_code_display(cem.dosage_unit_cd), work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt
   ].droute = uar_get_code_display(cem.admin_route_cd),
   work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].admin_datetime = cnvtdatetime(ce
    .event_end_dt_tm), work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].bag = cem
   .substance_lot_number, work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].eventid = ce
   .event_id,
   work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].admintotaldose = ce.result_val, work->
   encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].admintotaldoseunit = uar_get_code_display(ce
    .result_units_cd)
  HEAD ce.event_end_dt_tm
   stat = 0
  DETAIL
   IF ((work->encntrs[work->e_cnt].meds[m_cnt].med_type=4))
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
   IF ((work->encntrs[work->e_cnt].meds[m_cnt].med_type=4))
    IF (tdose > 0)
     work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].ddose = tdose, work->encntrs[work->
     e_cnt].meds[m_cnt].ordevent[eventcnt].dispense_amount = 1
    ELSE
     work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].ddose = begindose, work->encntrs[work
     ->e_cnt].meds[m_cnt].ordevent[eventcnt].dispense_amount = 0
    ENDIF
   ELSE
    work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].ddose = tdose
    IF (ce.result_status_cd IN (36.00))
     work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].dispense_amount = 0
    ELSE
     work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].dispense_amount = 1
    ENDIF
   ENDIF
   IF (cem.diluent_type_cd > 0)
    work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].diluent = uar_get_code_display(cem
     .diluent_type_cd), work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].ordercatprimary =
    oc.primary_mnemonic
   ELSE
    work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].diluent, work->encntrs[work->e_cnt].
    meds[m_cnt].ordevent[eventcnt].ordercatprimary = work->encntrs[work->e_cnt].meds[m_cnt].
    catprimary
   ENDIF
   work->encntrs[work->e_cnt].meds[m_cnt].ordevent[eventcnt].parenteventid = ce.parent_event_id
  WITH nocounter
 ;end select
 CALL echo(curqual)
 CALL echorecord(work)
 IF (curqual <= 0)
  GO TO exit_program
 ENDIF
 CALL echo("Gather Order Details")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].m_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=work->encntrs[d1.seq].meds[d2.seq].order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
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
     char(12),work->encntrs[d1.seq].meds[d2.seq].hold_for)
   ENDIF
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].instructions,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].od_line = build2(work->encntrs[d1.seq].meds[d2.seq].od_line,
     char(12),work->encntrs[d1.seq].meds[d2.seq].instructions)
   ENDIF
   IF (trim(work->encntrs[d1.seq].meds[d2.seq].spec_instr,3) > " ")
    work->encntrs[d1.seq].meds[d2.seq].od_line = build2(work->encntrs[d1.seq].meds[d2.seq].od_line,
     char(12),work->encntrs[d1.seq].meds[d2.seq].spec_instr)
   ENDIF
   IF ((work->encntrs[d1.seq].meds[d2.seq].start_dt_tm IN (null, 0)))
    work->encntrs[d1.seq].meds[d2.seq].start_dt_tm = o.current_start_dt_tm
   ENDIF
  FOOT  d1.seq
   null
  WITH nocounter, time = 200
 ;end select
 IF (( $RUNTYPE > 0))
  SET var_output = "adminreport.dat"
  SET sep = "|"
 ELSE
  SET var_output =  $OUTDEV
  SET sep = " "
 ENDIF
 CALL echo("output")
 CALL echorecord(work)
 DECLARE t = vc WITH noconstant(" ")
 IF (( $RUNTYPE=0))
  CALL echo("runtype = 0")
  SELECT INTO value(var_output)
   namefirst = substring(1,50,work->encntrs[d.seq].firstname), namemiddle = substring(1,50,work->
    encntrs[d.seq].middlename), namelast = substring(1,50,work->encntrs[d.seq].lastname),
   medtype = work->encntrs[d.seq].meds[d1.seq].med_type, eventid = work->encntrs[d.seq].meds[d1.seq].
   ordevent[d2.seq].eventid, start_dt_tm = format(cnvtdatetime(work->encntrs[d.seq].meds[d1.seq].
     start_dt_tm),"YYYYMMDDHHMMSS;;q"),
   bag = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].bag, fin = substring(1,12,build(work->
     encntrs[d.seq].fin)), mrn = substring(1,7,work->encntrs[d.seq].mrn),
   drug_code_order_id = cnvtstring(work->encntrs[d.seq].meds[d1.seq].order_id), drug_text = substring
   (1,100,work->encntrs[d.seq].meds[d1.seq].order_detail_display_line), od_line = check(substring(1,
     100,work->encntrs[d.seq].meds[d1.seq].od_line)),
   parent_event_id = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].parenteventid, primary =
   check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].ordercatprimary)),
   generic_drug_name = check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].desc)),
   ndc = "N/A", diluent = substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].diluent),
   dispense_amount = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount,
   dose = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].ddose, dose_unit = work->encntrs[d.seq].
   meds[d1.seq].ordevent[d2.seq].dose_unit, route = substring(1,50,work->encntrs[d.seq].meds[d1.seq].
    ordevent[d2.seq].droute),
   schedule_code = "n/a", admin_datetime = format(cnvtdatetime(work->encntrs[d.seq].meds[d1.seq].
     ordevent[d2.seq].admin_datetime),";;q"), drug_cost = 0,
   status =
   IF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)
    AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "BeginBag"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)
    AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "Infused/bolus"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)) "NotDone"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)) "Dispensed"
   ENDIF
   FROM (dummyt d  WITH seq = size(work->encntrs,5)),
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1)
   PLAN (d
    WHERE maxrec(d1,size(work->encntrs[d.seq].meds,5)))
    JOIN (d1
    WHERE maxrec(d2,size(work->encntrs[d.seq].meds[d1.seq].ordevent,5)))
    JOIN (d2)
   ORDER BY admin_datetime, parent_event_id
   WITH nocounter, format, format(date,"YYYYMMDDHHMMSS;;q"),
    separator = value(sep)
  ;end select
 ELSE
  SET msgdttime = format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q")
  SET domain =
  IF (gl_bhs_prod_flag=1) "P"
  ELSE "T"
  ENDIF
  SELECT INTO value(var_output)
   namefirst = substring(1,50,work->encntrs[d.seq].firstname), namemiddle = substring(1,50,work->
    encntrs[d.seq].middlename), namelast = substring(1,50,work->encntrs[d.seq].lastname),
   medtype = work->encntrs[d.seq].meds[d1.seq].med_type, eventid = work->encntrs[d.seq].meds[d1.seq].
   ordevent[d2.seq].eventid, start_dt_tm = format(cnvtdatetime(work->encntrs[d.seq].meds[d1.seq].
     start_dt_tm),"YYYYMMDDHHMMSS;;q"),
   bag = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].bag, fin = trim(substring(1,12,build(work
      ->encntrs[d.seq].fin))), mrn = substring(1,7,work->encntrs[d.seq].mrn),
   fac = substring(1,4,work->encntrs[d.seq].fac), drug_code_order_id = cnvtstring(work->encntrs[d.seq
    ].meds[d1.seq].order_id), drug_text = substring(1,100,work->encntrs[d.seq].meds[d1.seq].
    order_detail_display_line),
   od_line = check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].od_line)), parent_event_id =
   format(trim(cnvtstring(work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].parenteventid),3),
    "############;P0"), primary = check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2
     .seq].ordercatprimary)),
   generic_drug_name = check(substring(1,100,work->encntrs[d.seq].meds[d1.seq].desc)), ndc = "N/A",
   diluent = substring(1,100,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].diluent),
   dispense_amount = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount, dose = trim(
    format(work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].ddose,"######.#####;T(1)"),3),
   dose_unit = work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dose_unit,
   route = substring(1,50,work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].droute), schedule_code
    = "n/a", admin_datetime = cnvtdatetime(work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].
    admin_datetime),
   drug_cost = 0, status =
   IF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)
    AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "BeginBag"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)
    AND (work->encntrs[d.seq].meds[d1.seq].med_type=4)) "Infused/bolus"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=0)) "NotDone"
   ELSEIF ((work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].dispense_amount=1)) "Dispensed"
   ENDIF
   FROM (dummyt d  WITH seq = size(work->encntrs,5)),
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1)
   PLAN (d
    WHERE maxrec(d1,size(work->encntrs[d.seq].meds,5)))
    JOIN (d1
    WHERE maxrec(d2,size(work->encntrs[d.seq].meds[d1.seq].ordevent,5)))
    JOIN (d2)
   ORDER BY admin_datetime, parent_event_id
   HEAD parent_event_id
    tline = "", dispenseline = "", adminline = concat("MSH|^~\&|CERNER|",trim(fac,3),"|PREMIER|DHQ",
     "|",msgdttime,
     "||RAS^O17","|",msgdttime,parent_event_id,"|",
     domain,"|2.3",char(13),"PID|1","|",
     fin,"|",mrn,"|","|",
     trim(namelast,3),"^",trim(namemiddle),"^",trim(namefirst,3),
     "||||||||||||","|",fin,char(13),"ORC|RE",
     "|",trim(drug_code_order_id,3),"|||SC","||||||||||",char(13),
     "RXE","|^^^",trim(start_dt_tm,3),"^^^^",trim(drug_text,3),
     "|",trim(generic_drug_name,3),"|||||||","||","|||",
     "|",trim(drug_code_order_id,3),"|||||",char(13),"RXR",
     "|",trim(route,3),"^",trim(route,3),"|||"),
    cnt = 0
   DETAIL
    cnt += 1, dispenseline = build(dispenseline,char(13),"RXC","|A","|^",
     trim(primary,3),"|",trim(dose,3),"|",trim(work->encntrs[d.seq].meds[d1.seq].ordevent[d2.seq].
      dose_unit,3),
     "||")
   FOOT  parent_event_id
    tline = "", tline = concat(trim(adminline,3),char(13),trim(dispenseline,3)), tline = concat(tline,
     char(13),"RXA","||","|",
     trim(admin_datetime,3),"||","|","|","||",
     trim(od_line,3),"||||||||||","|",trim(status,3),"||||||",
     char(13)),
    col 0, tline, row + 1
   WITH nocounter, format, format(date,"YYYYMMDDHHMMSS;;q"),
    maxcol = 1500, formfeed = none, format = undefined
  ;end select
  CALL echo("Email and FTP")
  CALL echo(curnode)
 ENDIF
#exit_program
END GO
