CREATE PROGRAM bhs_rw_phone_triage_genview
 FREE RECORD work
 RECORD work(
   1 person_id = f8
   1 encntr_id = f8
   1 atr_ind = i2
   1 patient_name = vc
   1 gender = vc
   1 birth_dt_tm = dq8
   1 cmrn = vc
   1 bmc_mrn = vc
   1 last_encntr_id = f8
   1 last_ins = vc
   1 loc_nurse_unit_cd = f8
   1 nurse_unit = vc
   1 home_phone = vc
   1 work_phone = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zipcode = vc
   1 pcp_name = vc
   1 past_appt_max = i4
   1 past_appt_cnt = i4
   1 past_appts[*]
     2 appt_dt_tm = dq8
     2 appt_type = vc
     2 resource = vc
     2 encntr_id = f8
   1 future_appt_max = i4
   1 future_appt_cnt = i4
   1 future_appts[*]
     2 appt_dt_tm = dq8
     2 appt_type = vc
     2 resource = vc
     2 encntr_id = f8
   1 pharm_cnt = i4
   1 pharms[*]
     2 pharmacy = vc
 )
 IF (validate(request->visit[1].encntr_id,0.00) <= 0.00)
  IF (cnvtreal(parameter(1,0)) <= 0.00)
   CALL echo("No ENCNTR_ID found. Exitting Script")
   GO TO exit_script
  ELSE
   SET work->encntr_id = cnvtreal(parameter(1,0))
  ENDIF
 ELSE
  SET work->encntr_id = request->visit[1].encntr_id
 ENDIF
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 status_data[1]
      2 status = c1
    1 text = vc
  )
 ENDIF
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SET work->atr_ind = 0
 SELECT INTO "NL:"
  ea.alias
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=work->encntr_id)
    AND ea.encntr_alias_type_cd=cs319_fin_cd
    AND ea.alias="ATR*"
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   work->atr_ind = 1
  WITH nocounter
 ;end select
 IF ((work->atr_ind <= 0))
  CALL echo("Non-ATR Encounter found. Going to Print Output")
  GO TO print_output
 ENDIF
 FREE SET cs319_fin_cd
 DECLARE cs43_home_phone_cd = f8 WITH constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE cs43_work_phone_cd = f8 WITH constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE cs212_home_addr_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs263_bhs_cmrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN"))
 DECLARE cs263_bmc_mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN"))
 SELECT INTO "NL:"
  e.person_id, p.name_full_formatted, p.birth_dt_tm
  FROM encounter e,
   person p,
   person_alias pa1,
   person_alias pa2
  PLAN (e
   WHERE (e.encntr_id=work->encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa1
   WHERE outerjoin(p.person_id)=pa1.person_id
    AND pa1.alias_pool_cd=outerjoin(cs263_bhs_cmrn_cd)
    AND pa1.active_ind=outerjoin(1)
    AND pa1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pa2
   WHERE outerjoin(p.person_id)=pa2.person_id
    AND pa2.alias_pool_cd=outerjoin(cs263_bmc_mrn_cd)
    AND pa2.active_ind=outerjoin(1)
    AND pa2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD e.encntr_id
   work->person_id = e.person_id, work->cmrn = format(trim(pa1.alias,3),"#######;P0"), work->bmc_mrn
    = format(trim(pa2.alias,3),"#######;P0"),
   work->patient_name = p.name_full_formatted, work->gender = trim(uar_get_code_display(p.sex_cd),3),
   work->birth_dt_tm = p.birth_dt_tm,
   work->loc_nurse_unit_cd = e.loc_nurse_unit_cd, work->nurse_unit = trim(uar_get_code_display(e
     .loc_nurse_unit_cd),3)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM phone ph
  PLAN (ph
   WHERE (work->person_id=ph.parent_entity_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (cs43_home_phone_cd, cs43_work_phone_cd)
    AND ph.active_ind=1
    AND ph.active_status_cd=cs48_active_cd
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ph.data_status_cd=cs8_auth_cd)
  ORDER BY ph.phone_type_seq
  DETAIL
   IF (ph.phone_type_cd=cs43_home_phone_cd
    AND trim(work->home_phone,3) <= " ")
    work->home_phone = ph.phone_num
   ELSEIF (ph.phone_type_cd=cs43_work_phone_cd
    AND trim(work->work_phone,3) <= " ")
    work->work_phone = ph.phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE (a.parent_entity_id=work->person_id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=cs212_home_addr_cd
    AND a.active_ind=1)
  ORDER BY a.address_type_seq
  DETAIL
   IF (trim(work->address,3) <= " ")
    IF (trim(a.street_addr) > " ")
     work->address = trim(a.street_addr,3)
    ENDIF
    IF (trim(a.street_addr2) > " ")
     work->address = build2(work->address," ",trim(a.street_addr2,3))
    ENDIF
    IF (trim(a.street_addr3) > " ")
     work->address = build2(work->address," ",trim(a.street_addr3,3))
    ENDIF
    IF (trim(a.street_addr4) > " ")
     work->address = build2(work->address," ",trim(a.street_addr4,3))
    ENDIF
    work->city = a.city, work->state = a.state, work->zipcode = a.zipcode
   ENDIF
  WITH nocounter
 ;end select
 FREE SET cs43_home_phone_cd
 FREE SET cs43_work_phone_cd
 FREE SET cs212_home_addr_cd
 FREE SET cs48_active_cd
 FREE SET cs8_auth_cd
 FREE SET cs263_bhs_cmrn_cd
 FREE SET cs263_bmc_mrn_cd
 DECLARE cs331_ppr_pcp_cd = f8 WITH constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE cs333_epr_pcp_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"PCP"))
 SELECT INTO "NL:"
  ppr.ft_prsnl_name, pr.name_full_formatted
  FROM person_prsnl_reltn ppr,
   prsnl pr
  PLAN (ppr
   WHERE (work->person_id=ppr.person_id)
    AND ppr.person_prsnl_r_cd=cs331_ppr_pcp_cd
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE outerjoin(ppr.prsnl_person_id)=pr.person_id)
  ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   IF (pr.person_id > 0.0)
    work->pcp_name = trim(pr.name_full_formatted,3)
   ELSE
    work->pcp_name = trim(ppr.ft_prsnl_name,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (trim(work->pcp_name,3) <= " ")
  SELECT INTO "NL:"
   epr.ft_prsnl_name, pr.name_full_formatted
   FROM encounter e,
    encntr_prsnl_reltn epr,
    prsnl pr
   PLAN (e
    WHERE (work->person_id=e.person_id))
    JOIN (epr
    WHERE e.encntr_id=epr.encntr_id
     AND epr.encntr_prsnl_r_cd=cs333_epr_pcp_cd
     AND epr.expire_dt_tm=null)
    JOIN (pr
    WHERE outerjoin(epr.prsnl_person_id)=pr.person_id)
   ORDER BY e.person_id, epr.activity_dt_tm DESC
   HEAD e.person_id
    IF (pr.person_id > 0.0)
     work->pcp_name = trim(pr.name_full_formatted,3)
    ELSE
     work->pcp_name = trim(epr.ft_prsnl_name,3)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE SET cs331_ppr_pcp_cd
 FREE SET cs333_epr_pcp_cd
 SET work->past_appt_max = 3
 SET work->future_appt_max = 3
 SELECT INTO "NL:"
  sa1.beg_dt_tm, se.appt_type_cd, sa2.resource_cd
  FROM sch_appt sa1,
   sch_appt sa2,
   sch_event se
  PLAN (sa1
   WHERE (sa1.person_id=work->person_id)
    AND sa1.role_meaning="PATIENT"
    AND sa1.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED")
    AND sa1.end_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((sa1.appt_location_cd+ 0)=work->loc_nurse_unit_cd))
   JOIN (sa2
   WHERE sa1.schedule_id=sa2.schedule_id
    AND sa2.role_meaning="RESOURCE"
    AND sa2.resource_cd > 0.0)
   JOIN (se
   WHERE sa1.sch_event_id=se.sch_event_id
    AND sa1.schedule_seq=se.schedule_seq)
  ORDER BY sa1.beg_dt_tm DESC, se.sch_event_id
  HEAD REPORT
   pa_cnt = 0
  HEAD se.sch_event_id
   pa_cnt = (work->past_appt_cnt+ 1), work->past_appt_cnt = pa_cnt, stat = alterlist(work->past_appts,
    pa_cnt),
   work->past_appts[pa_cnt].appt_dt_tm = sa1.beg_dt_tm, work->past_appts[pa_cnt].appt_type = trim(
    uar_get_code_display(se.appt_type_cd)), work->past_appts[pa_cnt].resource = trim(
    uar_get_code_display(sa2.resource_cd)),
   work->past_appts[pa_cnt].encntr_id = sa1.encntr_id
  WITH nocounter, maxrec = value(work->past_appt_max)
 ;end select
 SELECT INTO "NL:"
  sa1.beg_dt_tm, se.appt_type_cd, sa2.resource_cd
  FROM sch_appt sa1,
   sch_appt sa2,
   sch_event se
  PLAN (sa1
   WHERE (sa1.person_id=work->person_id)
    AND sa1.role_meaning="PATIENT"
    AND sa1.state_meaning IN ("CONFIRMED", "RESCHEDULED")
    AND sa1.beg_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ((sa1.appt_location_cd+ 0)=work->loc_nurse_unit_cd))
   JOIN (sa2
   WHERE outerjoin(sa1.schedule_id)=sa2.schedule_id
    AND sa2.role_meaning=outerjoin("RESOURCE")
    AND sa2.resource_cd > outerjoin(0.0))
   JOIN (se
   WHERE sa1.sch_event_id=se.sch_event_id
    AND sa1.schedule_seq=se.schedule_seq)
  ORDER BY sa1.beg_dt_tm DESC
  HEAD REPORT
   fa_cnt = 0
  HEAD se.sch_event_id
   fa_cnt = (work->future_appt_cnt+ 1), work->future_appt_cnt = fa_cnt, stat = alterlist(work->
    future_appts,fa_cnt),
   work->future_appts[fa_cnt].appt_dt_tm = sa1.beg_dt_tm, work->future_appts[fa_cnt].appt_type = trim
   (uar_get_code_display(se.appt_type_cd)), work->future_appts[fa_cnt].resource = trim(
    uar_get_code_display(sa2.resource_cd)),
   work->future_appts[fa_cnt].encntr_id = sa1.encntr_id
  WITH nocounter, maxrec = value(work->future_appt_max)
 ;end select
 IF ((work->past_appt_cnt > 0))
  SELECT INTO "NL:"
   e.financial_class_cd
   FROM encounter e
   PLAN (e
    WHERE (work->past_appts[1].encntr_id=e.encntr_id))
   DETAIL
    work->last_ins = build2(trim(uar_get_code_display(e.financial_class_cd),3),
     " (from Last Dept Visit)")
   WITH nocounter
  ;end select
 ELSE
  SET work->last_ins = "No Previous Dept Visit"
 ENDIF
#print_output
 SELECT INTO "NL:"
  FROM dummyt
  HEAD REPORT
   tab_char = "\tab", end_line = "\par", end_para = "\pard",
   beg_text = "\f0\fs20", line_return = build2(char(10),char(13)), beg_doc =
   "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}{\colortbl ;\red255\green0\blue0;}",
   end_doc = "}", beg_bold = "\b", end_bold = "\b0",
   beg_uline = "\ul", end_uline = "\ulnone"
  DETAIL
   IF ((work->atr_ind=1))
    reply->text = build2(beg_doc,"\f0\fs28",line_return,beg_bold," ",
     work->patient_name,end_line,line_return), reply->text = build2(reply->text,"\f0\fs24",
     line_return,end_line,line_return,
     "Corp MRN: ",work->cmrn,end_line,line_return,"BMC MRN: ",
     work->bmc_mrn,end_bold,beg_text,end_line,line_return,
     end_line,line_return), reply->text = build2(reply->text,beg_bold," Gender:",tab_char," ",
     work->gender,end_bold,end_line,line_return),
    reply->text = build2(reply->text,beg_bold," Home Phone:",tab_char," ",
     work->home_phone,end_bold,end_line,line_return), reply->text = build2(reply->text,beg_bold,
     " Work Phone:",tab_char," ",
     work->work_phone,end_bold,end_line,line_return,end_line,
     line_return), reply->text = build2(reply->text,beg_bold," ",work->address,end_bold,
     end_line,line_return,beg_bold," ",work->city,
     ", ",work->state,"  ",work->zipcode,end_bold,
     end_line,line_return,end_line,line_return),
    reply->text = build2(reply->text,beg_bold," Date of Birth:",end_bold,tab_char,
     " ",format(work->birth_dt_tm,"MM/DD/YYYY;;D"),end_line,line_return), reply->text = build2(reply
     ->text,beg_bold," Insurance:",end_bold,tab_char,
     " ",work->last_ins,end_line,line_return), reply->text = build2(reply->text,beg_bold," PCP:",
     end_bold,tab_char,
     tab_char," ",work->pcp_name,end_line,line_return,
     end_line,line_return),
    reply->text = build2(reply->text,beg_bold," Last Appt(s) at ",work->nurse_unit,":",
     end_bold,end_line,line_return)
    FOR (p = 1 TO work->past_appt_cnt)
      reply->text = build2(reply->text,tab_char," ",format(work->past_appts[p].appt_dt_tm,
        "MM/DD/YYYY HH:MM;;D"),"  |  ",
       work->past_appts[p].appt_type,"  |  ",work->past_appts[p].resource,end_line,line_return)
    ENDFOR
    reply->text = build2(reply->text,end_line,line_return), reply->text = build2(reply->text,beg_bold,
     " Future Appt(s) at ",work->nurse_unit,":",
     end_bold,end_line,line_return)
    FOR (f = 1 TO work->future_appt_cnt)
      reply->text = build2(reply->text,tab_char," ",format(work->future_appts[f].appt_dt_tm,
        "MM/DD/YYYY HH:MM;;D"),"  |  ",
       work->future_appts[f].appt_type,"  |  ",work->future_appts[f].resource,end_line,line_return)
    ENDFOR
   ELSE
    reply->text = build2(beg_doc,"\cf1\f0\fs72",line_return,end_line,line_return,
     end_line,beg_bold,"\qc NOT A TRIAGE ENCOUNTER!!!",end_line,line_return,
     end_bold,end_line,line_return)
   ENDIF
  FOOT REPORT
   reply->text = build2(reply->text,end_doc)
  WITH nocounter
 ;end select
 SET reply->status_data[1].status = "S"
 CALL echo(reply->text)
#exit_script
END GO
