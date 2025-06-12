CREATE PROGRAM bhs_rpt_home_care_discharge1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = ""
  WITH outdev, encntr_id
 CALL echo("Inside bhs_rpt_home_care_discharge")
 DECLARE outputdev = vc WITH noconstant(" ")
 DECLARE errmsg = vc WITH noconstant(" ")
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE status_detail = vc WITH noconstant(" ")
 DECLARE becont = i4 WITH noconstant(0)
 DECLARE allergy = vc WITH noconstant(" ")
 DECLARE allergiesdetail = vc WITH noconstant(" ")
 DECLARE tab = c6 WITH constant("      ")
 DECLARE allergydisplay = vc WITH noconstant("Allergies:")
 DECLARE advdirval = vc WITH noconstant(" ")
 DECLARE advdirtitle = vc WITH noconstant(" ")
 DECLARE immuntitle = vc WITH noconstant("Immunizations:")
 DECLARE insurancetitle = vc WITH noconstant("Insurance:")
 DECLARE contacttitle = vc WITH noconstant("Contact(s):")
 DECLARE powernotetitle = vc WITH noconstant(" ")
 DECLARE powerformtitle = vc WITH noconstant(" ")
 DECLARE pos = i4 WITH protect
 DECLARE locnum = i4 WITH protect
 CALL echo("declare constants")
 DECLARE homeaddress = f8 WITH constant(validatecodevalue("DISPLAYKEY",212,"HOME")), protect
 DECLARE homephone = f8 WITH constant(validatecodevalue("DISPLAYKEY",43,"HOME")), protect
 DECLARE business = f8 WITH constant(validatecodevalue("MEANING",43,"BUSINESS")), protect
 DECLARE mobile = f8 WITH constant(validatecodevalue("MEANING",43,"MOBILE")), protect
 DECLARE cmrn = f8 WITH constant(validatecodevalue("MEANING",4,"CMRN")), protect
 DECLARE pcp = f8 WITH constant(validatecodevalue("MEANING",333,"PCP")), protect
 DECLARE attenddoc = f8 WITH constant(validatecodevalue("MEANING",333,"ATTENDDOC")), protect
 DECLARE codestatus = f8 WITH constant(validatecodevalue("DISPLAYKEY",106,"CODESTATUS")), protect
 DECLARE ordered = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE advancedirective = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"ADVANCEDIRECTIVE")),
 protect
 DECLARE advancedirectivetype = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "ADVANCEDIRECTIVETYPE")), protect
 DECLARE proxy = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,"PROXY")), protect
 DECLARE contactproxyphonenumber = f8 WITH constant(validatecodevalue("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER")), protect
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE inerror_cd = f8 WITH constant(validatecodevalue("MEANING",8,"INERROR")), protect
 DECLARE mf_pneu_vac_cd01 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCAL7VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd02 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCAL13VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd05 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCAL23VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd06 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCOLDTERM"))
 DECLARE mf_pneu_vac_cd11 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCALCONJUGATEPCV7OLDTERM"))
 DECLARE mf_pneu_vac_cd12 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCALPOLYPPV23OLDTERM"))
 DECLARE mf_pneu_vac_cd13 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINEOLDTERM"))
 DECLARE mf_pneu_vac_cd14 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PNEUMOVAX23OLDTERM"))
 DECLARE mf_pneu_vac_cd15 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PREVNARINJOLDTERM"))
 DECLARE mf_pneu_vac_cd16 = f8 WITH protect, constant(validatecodevalue("DISPLAYKEY",72,
   "PREVNAROLDTERM"))
 DECLARE mf_influ_h1n1_inact = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUVIRUSVACH1N1INACTIVEOLDTERM"))
 DECLARE mf_influ_h1n1_live = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUVIRUSVACH1N1LIVEOLDTERM"))
 DECLARE mf_influ_vacc_inact = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEINACTIVATED"))
 DECLARE mf_influ_vacc_triv = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINELIVETRIVALENT"))
 DECLARE mf_influ_vacc_old = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEOLDTERM"))
 DECLARE mf_influ_vac_cd01 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "AFLURIAOLDTERM"))
 DECLARE mf_influ_vac_cd02 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUARIXOLDTERM"))
 DECLARE mf_influ_vac_cd03 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLULAVALOLDTERM"))
 DECLARE mf_influ_vac_cd04 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUMISTOLDTERM"))
 DECLARE mf_influ_vac_cd05 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUVIRINOLDTERM"))
 DECLARE mf_influ_vac_cd06 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUVIRINPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd07 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUZONEOLDTERM"))
 DECLARE mf_influ_vac_cd08 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd09 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEPEDIOLDTERM"))
 DECLARE mf_influ_vac_cd10 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUENZAINACTIVEIMOLDTERM"))
 DECLARE mf_influ_vac_cd11 = f8 WITH protect, noconstant(validatecodevalue("DISPLAYKEY",72,
   "INFLUENZALIVEINTRANASALOLDTERM"))
 DECLARE emc = f8 WITH constant(validatecodevalue("MEANING",351,"EMC")), protect
 DECLARE defguar = f8 WITH constant(validatecodevalue("MEANING",351,"DEFGUAR")), protect
 DECLARE nok = f8 WITH constant(validatecodevalue("MEANING",351,"NOK")), protect
 DECLARE pcg = f8 WITH constant(validatecodevalue("MEANING",351,"PCG")), protect
 DECLARE ocfcomp = f8 WITH constant(validatecodevalue("MEANING",120,"OCFCOMP")), protect
 DECLARE weight = f8 WITH public, constant(validatecodevalue("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE pulse = f8 WITH public, constant(validatecodevalue("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp = f8 WITH public, constant(validatecodevalue("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp = f8 WITH public, constant(validatecodevalue("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE blob_out = vc WITH noconstant(" ")
 DECLARE blob_out2 = vc WITH noconstant(" ")
 DECLARE blob_out3 = vc WITH noconstant(" ")
 DECLARE subject = vc WITH noconstant(" ")
 CALL echo("end of declares")
 IF (validate(request->visit[1].encntr_id)=1)
  SET encntr_id = request->visit[1].encntr_id
  SET outputdev = request->output_device
 ELSE
  SET outputdev =  $OUTDEV
  CALL echo("Get Encounter from FIN")
  SELECT INTO "NL:"
   FROM encntr_alias ea
   WHERE (ea.alias= $ENCNTR_ID)
    AND ea.active_ind=1
   HEAD ea.encntr_id
    encntr_id = ea.encntr_id
   WITH nocounter
  ;end select
 ENDIF
 IF (encntr_id <= 0)
  CALL echo("encntr_id <= 0")
  GO TO exit_program
 ENDIF
 FREE RECORD dcpforms
 RECORD dcpforms(
   1 qual[*]
     2 title = vc
     2 dcp_forms_ref_id = f8
     2 sort = i4
     2 lookbacktime = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 text = vc
 )
 FREE RECORD info
 RECORD info(
   1 person_id = f8
   1 name = vc
   1 dob = vc
   1 cmrn = vc
   1 address = vc
   1 phone = vc
   1 pcp = vc
   1 attending = vc
   1 admin_dt_tm = vc
   1 dischargefacility = vc
   1 lastnurseunit = vc
   1 code_status_name = vc
   1 code_status_detail[*]
     2 display = vc
   1 advdir[*]
     2 advanceddirectivetitle = vc
     2 advanceddirectiveval = vc
   1 immun[*]
     2 name = vc
     2 given_date = vc
   1 ins_qual[*]
     2 type = vc
     2 name = vc
     2 member_nbr = vc
     2 group_nbr = vc
     2 subscriber = vc
   1 cont_qual[*]
     2 name = vc
     2 relation = vc
     2 phone_cnt = i2
     2 phone_qual[*]
       3 phonetype = vc
       3 phone = vc
       3 ext = vc
   1 powernote[*]
     2 sortseq = i4
     2 title = vc
     2 rtfblob = vc
   1 powerform[*]
     2 title = vc
     2 rtfblob = vc
   1 vitals[1]
     2 vitalfound = i4
     2 wt_result = vc
     2 wt_dt_tm = vc
     2 pulse_result = vc
     2 pulse_dt_tm = vc
     2 systolic_result = vc
     2 diastolic_result = vc
     2 bp_dt_tm = vc
     2 bp_display = vc
   1 form_cnt = i4
   1 form_qual[*]
     2 form_type = vc
     2 form_name = vc
     2 form_date = vc
     2 p_event_id = f8
     2 event_id = f8
     2 dcp_forms_ref_id = f8
     2 sort = i4
     2 sub1_cnt = i2
     2 sub1_qual[*]
       3 event_display = vc
       3 p_event_id = f8
       3 event_id = f8
       3 sub2_cnt = i2
       3 sub2_qual[*]
         4 event_display = vc
         4 event_result = vc
         4 event_date = vc
         4 event_comm = vc
         4 event_comp_cd = f8
         4 p_event_id = f8
         4 event_id = f8
         4 sub3_cnt = i2
         4 sub3_qual[*]
           5 event_display = vc
           5 event_result = vc
           5 event_date = vc
           5 event_comm = vc
           5 event_comp_cd = f8
           5 p_event_id = f8
           5 event_id = f8
           5 sub4_cnt = i2
           5 sub4_qual[*]
             6 event_display = vc
             6 event_result = vc
             6 event_date = vc
             6 event_comm = vc
             6 event_comp_cd = f8
             6 p_event_id = f8
             6 event_id = f8
 )
 CALL echo(build("load patient demographics", $ENCNTR_ID))
 SELECT INTO "NL:"
  *
  FROM encounter e,
   person p,
   address a,
   phone ph,
   person_alias pa,
   encntr_loc_hist elh,
   encntr_prsnl_reltn epr,
   prsnl pr,
   encntr_prsnl_reltn epr2,
   prsnl pr2
  PLAN (e
   WHERE e.encntr_id=encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.encntr_loc_hist_id IN (
   (SELECT
    max(elh1.encntr_loc_hist_id)
    FROM encntr_loc_hist elh1
    WHERE elh1.encntr_id=elh.encntr_id)))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.person_alias_type_cd=outerjoin(cmrn)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= pa.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= pa.end_effective_dt_tm)
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(attenddoc)
    AND epr.active_ind=outerjoin(1)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= epr.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= epr.end_effective_dt_tm)
   JOIN (pr
   WHERE pr.person_id=outerjoin(epr.prsnl_person_id))
   JOIN (epr2
   WHERE epr2.encntr_id=outerjoin(e.encntr_id)
    AND epr2.encntr_prsnl_r_cd=outerjoin(pcp)
    AND epr2.active_ind=outerjoin(1)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= epr2.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= epr2.end_effective_dt_tm)
   JOIN (pr2
   WHERE pr2.person_id=outerjoin(epr2.prsnl_person_id))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(e.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.active_ind=outerjoin(1)
    AND a.address_type_cd=outerjoin(homeaddress)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= a.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= a.end_effective_dt_tm)
   JOIN (ph
   WHERE ph.parent_entity_id=e.person_id
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.active_ind=outerjoin(1)
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= ph.beg_effective_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= ph.end_effective_dt_tm
    AND ph.phone_type_cd=outerjoin(homephone))
  DETAIL
   info->person_id = p.person_id, info->name = concat(trim(p.name_first,3)," ",trim(p.name_last,3)),
   info->dob = format(p.birth_dt_tm,";;q"),
   info->cmrn = trim(pa.alias,3), info->address = concat(trim(a.street_addr,3),
    IF (textlen(trim(check(a.street_addr2),3)) > 0) concat(char(13),trim(a.street_addr2,3))
    ELSE " "
    ENDIF
    ,
    IF (textlen(trim(check(a.street_addr3),3)) > 1) concat(char(13),trim(a.street_addr3,3))
    ELSE " "
    ENDIF
    ,
    IF (textlen(trim(check(a.street_addr4),3)) > 1) concat(char(13),trim(a.street_addr4,3))
    ELSE " "
    ENDIF
    ,char(13),
    trim(a.city,3),", ",trim(uar_get_code_display(a.state_cd),3)," ",trim(a.zipcode,3)), info->phone
    = ph.phone_num,
   info->pcp = concat(trim(pr2.name_first,3)," ",trim(pr2.name_last,3)), info->attending = concat(
    trim(pr.name_first,3)," ",trim(pr.name_last,3)), info->admin_dt_tm = format(e.reg_dt_tm,";;q"),
   info->dischargefacility = uar_get_code_display(e.loc_facility_cd), info->lastnurseunit =
   uar_get_code_display(e.loc_nurse_unit_cd)
  WITH format, separator = " "
 ;end select
 CALL echo(info->address)
 CALL echo("load code Status orders")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 display = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SELECT INTO "nl:"
  FROM order_catalog oc,
   orders o,
   order_detail od,
   order_entry_fields oef
  PLAN (oc
   WHERE oc.activity_type_cd=codestatus)
   JOIN (o
   WHERE o.encntr_id=encntr_id
    AND o.catalog_cd=oc.catalog_cd
    AND o.order_status_cd=ordered)
   JOIN (od
   WHERE od.order_id=outerjoin(o.order_id)
    AND od.oe_field_meaning=outerjoin("OTHER"))
   JOIN (oef
   WHERE oef.oe_field_id=outerjoin(od.oe_field_id))
  ORDER BY o.order_id, od.detail_sequence
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   info->code_status_name = trim(o.order_mnemonic)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(info->code_status_detail,cnt), info->code_status_detail[cnt].
   display = concat(trim(oef.description),": ",trim(od.oe_field_display_value))
  WITH nocounter
 ;end select
 SET pt->line_cnt = 0
 SET max_length = 85
 SET cnt = 0
 SET line_cnt = 0
 FOR (od = 1 TO size(info->code_status_detail,5))
   SET tempstring = fillstring(500,"")
   SET tempstring = trim(info->code_status_detail[od].display)
   EXECUTE dcp_parse_text value(tempstring), value(max_length)
   SET stat = alterlist(temp->qual,(cnt+ pt->line_cnt))
   FOR (line_cnt = 1 TO pt->line_cnt)
    SET cnt = (cnt+ 1)
    SET temp->qual[cnt].display = trim(pt->lns[line_cnt].line)
   ENDFOR
 ENDFOR
 SET stat = alterlist(info->code_status_detail,size(temp->qual,5))
 FOR (od2 = 1 TO size(temp->qual,5))
   SET info->code_status_detail[od2].display = trim(temp->qual[od2].display)
 ENDFOR
 CALL echorecord(info)
 CALL echo("load allergies report")
 EXECUTE bhs_sys_get_allergies_req "person"
 SET stat = alterlist(bhs_allergies_req->persons,1)
 SET bhs_allergies_req->p_cnt = 5
 SET bhs_allergies_req->persons[1].person_id = info->person_id
 EXECUTE bhs_sys_get_allergies_run
 CALL echorecord(bhs_allergies_req)
 CALL echorecord(bhs_allergies_reply)
 CALL echo("Get Advance Directive results")
 SELECT INTO "nl:"
  sort_event =
  IF (ce.event_cd=advancedirective) 1
  ELSEIF (ce.event_cd=advancedirectivetype) 2
  ELSEIF (ce.event_cd=proxy) 3
  ELSEIF (ce.event_cd=contactproxyphonenumber) 4
  ENDIF
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=encntr_id
    AND ce.event_cd IN (advancedirective, advancedirectivetype, proxy, contactproxyphonenumber)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (altered, modified, auth))
  ORDER BY sort_event, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   stat = alterlist(info->advdir,(size(info->advdir,5)+ 1)), info->advdir[size(info->advdir,5)].
   advanceddirectivetitle = trim(uar_get_code_display(ce.event_cd),3), info->advdir[size(info->advdir,
    5)].advanceddirectiveval = trim(ce.result_val,3)
  WITH nocounter
 ;end select
 CALL echo("Get Immunizations")
 SELECT INTO "nl:"
  cem.admin_start_dt_tm
  FROM clinical_event ce,
   ce_med_result cem
  PLAN (ce
   WHERE (ce.person_id=info->person_id)
    AND ce.event_cd IN (mf_pneu_vac_cd01, mf_pneu_vac_cd02, mf_pneu_vac_cd05, mf_pneu_vac_cd06,
   mf_pneu_vac_cd11,
   mf_pneu_vac_cd12, mf_pneu_vac_cd13, mf_pneu_vac_cd14, mf_pneu_vac_cd15, mf_pneu_vac_cd16,
   mf_influ_h1n1_inact, mf_influ_h1n1_live, mf_influ_vacc_inact, mf_influ_vacc_triv,
   mf_influ_vacc_old,
   mf_influ_vac_cd01, mf_influ_vac_cd02, mf_influ_vac_cd03, mf_influ_vac_cd04, mf_influ_vac_cd05,
   mf_influ_vac_cd06, mf_influ_vac_cd07, mf_influ_vac_cd08, mf_influ_vac_cd09, mf_influ_vac_cd10,
   mf_influ_vac_cd11)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd IN (altered, modified, auth))
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
  ORDER BY cem.admin_start_dt_tm DESC
  DETAIL
   stat = alterlist(info->immun,(size(info->immun,5)+ 1)), info->immun[size(info->immun,5)].name =
   trim(uar_get_code_display(ce.event_cd),3), info->immun[size(info->immun,5)].given_date = format(
    cem.admin_start_dt_tm,"mm/dd/yy hh:mm;;d")
  WITH nocounter
 ;end select
 CALL echo("Get Insurance Information")
 SELECT INTO "nl:"
  FROM encntr_plan_reltn e,
   person sub,
   organization o
  PLAN (e
   WHERE e.encntr_id=encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (sub
   WHERE sub.person_id=e.person_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
  ORDER BY e.encntr_plan_reltn_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_plan_reltn_id
   cnt = (cnt+ 1), stat = alterlist(info->ins_qual,cnt), info->ins_qual[cnt].name = o.org_name,
   info->ins_qual[cnt].type =
   IF (e.priority_seq=1) "Primary"
   ELSEIF (e.priority_seq=2) "Secondary"
   ELSEIF (e.priority_seq=3) "Tertiary"
   ENDIF
   , info->ins_qual[cnt].member_nbr = e.member_nbr, info->ins_qual[cnt].group_nbr = e.group_nbr,
   info->ins_qual[cnt].subscriber = trim(sub.name_full_formatted)
  WITH nocounter
 ;end select
 CALL echo("Get Contacts for Encounter")
 SELECT INTO "nl:"
  FROM encntr_person_reltn e,
   person p,
   phone ph
  PLAN (e
   WHERE e.encntr_id=encntr_id
    AND e.active_ind >= 1
    AND e.person_reltn_type_cd IN (emc, defguar, nok, pcg)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=outerjoin(e.related_person_id))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.active_ind=outerjoin(1))
  ORDER BY e.person_reltn_type_cd, e.beg_effective_dt_tm DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(info->cont_qual,3), phone = fillstring(20," "),
   ext = fillstring(8," ")
  HEAD e.person_reltn_type_cd
   cnt = (cnt+ 1)
   IF (mod(cnt,3)=1)
    stat = alterlist(info->cont_qual,(cnt+ 3))
   ENDIF
   info->cont_qual[cnt].name = concat(trim(p.name_first,3)," ",trim(p.name_last,3)), info->cont_qual[
   cnt].relation = trim(uar_get_code_display(e.person_reltn_type_cd)), cnt_phone = 0,
   stat = alterlist(info->cont_qual[cnt].phone_qual,2)
  DETAIL
   cnt_phone = (cnt_phone+ 1)
   IF (mod(cnt_phone,2)=1)
    stat = alterlist(info->cont_qual[cnt].phone_qual,(cnt_phone+ 2))
   ENDIF
   phone = ph.phone_num, ext = substring(1,8,ph.extension), info->cont_qual[cnt].phone_qual[cnt_phone
   ].phonetype = concat(trim(uar_get_code_display(ph.phone_type_cd),3),":"),
   info->cont_qual[cnt].phone_qual[cnt_phone].phone = cnvtphone(ph.phone_num,ph.phone_format_cd,2)
   IF (textlen(trim(ph.extension)) > 0)
    info->cont_qual[cnt].phone_qual[cnt_phone].ext = trim(ph.extension)
   ENDIF
  FOOT  e.person_reltn_type_cd
   stat = alterlist(info->cont_qual[cnt].phone_qual,cnt_phone), info->cont_qual[cnt].phone_cnt =
   cnt_phone
  FOOT REPORT
   stat = alterlist(info->cont_qual,cnt)
  WITH nocounter
 ;end select
 CALL echo("Load PowerNotes")
 FREE RECORD powernotes
 RECORD powernote(
   1 qual[*]
     2 display_key = vc
     2 sortseq = i4
 )
 SET stat = alterlist(powernote->qual,5)
 SET powernote->qual[1].display_key = "PHYSICIANDISCHARGESUMMARY*"
 SET powernote->qual[1].sortseq = 1
 SET powernote->qual[2].display_key = "PATIENTINSTRUCTIONSFOR*"
 SET powernote->qual[2].sortseq = 2
 SET powernote->qual[3].display_key = "HOSPITALISTDISCHARGESUMMARY*"
 SET powernote->qual[3].sortseq = 3
 SET powernote->qual[4].display_key = "OBSERVATIONEXITSUMMARY*"
 SET powernote->qual[4].sortseq = 4
 SET powernote->qual[5].display_key = "SURGICALDISCHARGESUMMARY*"
 SET powernote->qual[5].sortseq = 5
 SELECT INTO "NL:"
  sort = powernote->qual[d.seq].sortseq, srp.scr_pattern_id, ce.event_end_dt_tm
  FROM scd_story s,
   scd_story_pattern ssp,
   scr_pattern srp,
   clinical_event ce,
   ce_blob cb,
   (dummyt d  WITH seq = size(powernote->qual,5))
  PLAN (d)
   JOIN (srp
   WHERE operator(srp.display_key,"like",patstring(powernote->qual[d.seq].display_key,1)))
   JOIN (ssp
   WHERE ssp.scr_pattern_id=srp.scr_pattern_id)
   JOIN (s
   WHERE s.scd_story_id=ssp.scd_story_id
    AND s.story_completion_status_cd=10396.00
    AND s.encounter_id=encntr_id)
   JOIN (ce
   WHERE ce.event_id=s.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (altered, modified, auth))
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY sort, srp.scr_pattern_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD sort
   stat = 0
  HEAD srp.scr_pattern_id
   CALL echo("getting blob")
   IF (cb.compression_cd=ocfcomp)
    blob_compressed_trimmed = fillstring(64000," "), blob_uncompressed = fillstring(64000," "),
    blob_return_len = 0,
    blob_out = fillstring(64000," "), blob_compressed_trimmed = cb.blob_contents,
    CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
    size(blob_uncompressed),blob_return_len),
    blob_out = replace(blob_uncompressed,"ocf_blob","",0)
   ELSE
    blob_out = blob_compressed_trimmed
   ENDIF
   cnt = (cnt+ 1), stat = alterlist(info->powernote,cnt)
   IF (trim(srp.display_key) IN (value("PHYSICIANDISCHARGESUMMARY*")))
    info->powernote[cnt].title = "Physician Discharge Summary", info->powernote[cnt].sortseq = 1
   ELSEIF (trim(srp.display_key) IN (value("PATIENTINSTRUCTIONSFOR*")))
    info->powernote[cnt].title = "Patient Instructions for Discharge", info->powernote[cnt].sortseq
     = 2
   ELSEIF (trim(srp.display_key) IN (value("HOSPITALISTDISCHARGESUMMARY*")))
    info->powernote[cnt].title = "Hospitalist Discharge Summary", info->powernote[cnt].sortseq = 3
   ELSEIF (trim(srp.display_key) IN (value("OBSERVATIONEXITSUMMARY*")))
    info->powernote[cnt].title = "Observation Exit Summary", info->powernote[cnt].sortseq = 4
   ELSEIF (trim(srp.display_key) IN (value("SURGICALDISCHARGESUMMARY*")))
    info->powernote[cnt].title = "Surgical Discharge Summary", info->powernote[cnt].sortseq = 5
   ENDIF
   blob_out = replace(blob_out,"fs2","fs3"), blob_out = replace(blob_out,"fs1","fs2"), info->
   powernote[cnt].rtfblob = blob_out
  WITH nocounter
 ;end select
 CALL echo("Get powerForm")
 FREE RECORD powerform
 RECORD powerform(
   1 qual[*]
     2 description = vc
     2 lookbacktime = dq8
     2 sortseq = i4
 )
 SET stat = alterlist(powerform->qual,7)
 SET cnt = 0
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "ST *"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "PT*"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "Physical Therapy*"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "Occupational *"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "OT *"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "Braden*"
 SET powerform->qual[cnt].sortseq = cnt
 SET cnt = (cnt+ 1)
 SET powerform->qual[cnt].description = "Vital*"
 SET powerform->qual[cnt].lookbacktime = cnvtdatetime((curdate - 1),curtime3)
 SET powerform->qual[cnt].sortseq = cnt
 SELECT INTO "NL:"
  sort = powerform->qual[d.seq].sortseq, dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   (dummyt d  WITH seq = size(powerform->qual,5))
  PLAN (d)
   JOIN (dfr
   WHERE operator(dfr.description,"like",patstring(powerform->qual[d.seq].description,1))
    AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.encntr_id=encntr_id
    AND dfa.active_ind=1
    AND dfa.form_status_cd IN (altered, modified, auth))
  ORDER BY sort, dfr.dcp_forms_ref_id
  HEAD REPORT
   cnt = 0
  HEAD sort
   stat = 0
  HEAD dfr.dcp_forms_ref_id
   CALL echo(dfr.dcp_forms_ref_id), cnt = (cnt+ 1), stat = alterlist(dcpforms->qual,cnt),
   dcpforms->qual[cnt].dcp_forms_ref_id = dfr.dcp_forms_ref_id, dcpforms->qual[cnt].title = dfr
   .description, dcpforms->qual[cnt].lookbacktime = cnvtdatetime(powerform->qual[d.seq].lookbacktime),
   dcpforms->qual[cnt].sort = sort
  WITH nocounter
 ;end select
 CALL echorecord(dcpforms)
 FREE RECORD form_results
 RECORD form_results(
   1 form_cnt = i4
   1 form_qual[*]
     2 form_type = vc
     2 form_name = vc
     2 dcp_forms_ref_id = f8
     2 dcp_forms_activity_id = f8
     2 form_event_id = f8
     2 sort = i4
 )
 SET cnt_f = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(dcpforms->qual,5))),
   dcp_forms_activity dcp,
   dcp_forms_activity_comp dcpc
  PLAN (d)
   JOIN (dcp
   WHERE dcp.encntr_id=encntr_id
    AND ((dcp.dcp_forms_ref_id+ 0)=dcpforms->qual[d.seq].dcp_forms_ref_id)
    AND dcp.active_ind=1
    AND (((dcpforms->qual[d.seq].lookbacktime != 0)
    AND dcp.form_dt_tm >= cnvtdatetime(dcpforms->qual[d.seq].lookbacktime)) OR ((dcpforms->qual[d.seq
   ].lookbacktime <= 0))) )
   JOIN (dcpc
   WHERE dcpc.dcp_forms_activity_id=dcp.dcp_forms_activity_id
    AND dcpc.parent_entity_name="CLINICAL_EVENT")
  ORDER BY dcp.dcp_forms_ref_id, dcp.form_dt_tm DESC
  DETAIL
   CALL echo("PIG"),
   CALL echo(dcpforms->qual[d.seq].lookbacktime), cnt_f = (cnt_f+ 1),
   stat = alterlist(form_results->form_qual,cnt_f), form_results->form_qual[cnt_f].form_name = dcp
   .description, form_results->form_qual[cnt_f].dcp_forms_ref_id = dcp.dcp_forms_ref_id,
   CALL echo(form_results->form_qual[cnt_f].dcp_forms_ref_id),
   CALL echo(dcp.dcp_forms_ref_id), form_results->form_qual[cnt_f].dcp_forms_activity_id = dcp
   .dcp_forms_activity_id,
   form_results->form_qual[cnt_f].form_event_id = dcpc.parent_entity_id, form_results->form_qual[
   cnt_f].sort = dcpforms->qual[d.seq].sort
  WITH nocounter
 ;end select
 SET stat = alterlist(form_results->form_qual,cnt_f)
 SET form_results->form_cnt = cnt_f
 CALL echorecord(form_results)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(form_results->form_cnt)),
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   ce_event_note cen,
   long_blob lb,
   clinical_event ce3,
   ce_event_note cen1,
   long_blob lb1,
   clinical_event ce4,
   ce_event_note cen2,
   long_blob lb2
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=form_results->form_qual[d.seq].form_event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != inerror_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.event_cd != ce.event_cd
    AND ce1.result_status_cd != inerror_cd)
   JOIN (ce2
   WHERE ce2.parent_event_id=outerjoin(ce1.event_id)
    AND ce2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (cen
   WHERE cen.event_id=outerjoin(ce2.event_id)
    AND cen.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb
   WHERE lb.parent_entity_id=outerjoin(cen.ce_event_note_id))
   JOIN (ce3
   WHERE ce3.parent_event_id=outerjoin(ce2.event_id)
    AND ce3.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime))
    AND ce3.view_level=outerjoin(1))
   JOIN (cen1
   WHERE cen1.event_id=outerjoin(ce3.event_id)
    AND cen1.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb1
   WHERE lb1.parent_entity_id=outerjoin(cen1.ce_event_note_id))
   JOIN (ce4
   WHERE ce4.parent_event_id=outerjoin(ce3.event_id)
    AND ce4.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime))
    AND ce4.event_id != outerjoin(ce3.event_id)
    AND ce4.parent_event_id != outerjoin(ce3.parent_event_id)
    AND ce4.view_level=outerjoin(1))
   JOIN (cen2
   WHERE cen2.event_id=outerjoin(ce4.event_id)
    AND cen2.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
   JOIN (lb2
   WHERE lb2.parent_entity_id=outerjoin(cen2.ce_event_note_id))
  ORDER BY ce.event_end_dt_tm, ce.event_id, ce1.event_id,
   ce2.event_id, ce3.event_id, ce4.event_id
  HEAD REPORT
   cnt_form = 0, stat = alterlist(info->form_qual,5)
  HEAD ce.event_end_dt_tm
   row + 0
  HEAD ce.event_id
   cnt_form = (cnt_form+ 1)
   IF (mod(cnt_form,5)=1)
    stat = alterlist(info->form_qual,(cnt_form+ 5))
   ENDIF
   info->form_qual[cnt_form].form_name = trim(uar_get_code_display(ce.event_cd)), info->form_qual[
   cnt_form].form_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), info->form_qual[cnt_form].
   form_type = form_results->form_qual[d.seq].form_type,
   info->form_qual[cnt_form].p_event_id = ce.parent_event_id, info->form_qual[cnt_form].
   dcp_forms_ref_id = form_results->form_qual[d.seq].dcp_forms_ref_id, info->form_qual[cnt_form].
   event_id = ce.event_id,
   info->form_qual[cnt_form].sort = form_results->form_qual[d.seq].sort, stat = alterlist(info->
    form_qual[cnt_form].sub1_qual,10), cnt_sub1 = 0
  HEAD ce1.event_id
   cnt_sub1 = (cnt_sub1+ 1)
   IF (mod(cnt_sub1,10)=1
    AND cnt_sub1 != 1)
    stat = alterlist(info->form_qual[cnt_form].sub1_qual,(cnt_sub1+ 10))
   ENDIF
   info->form_qual[cnt_form].sub1_qual[cnt_sub1].event_display = trim(ce1.event_title_text), info->
   form_qual[cnt_form].sub1_qual[cnt_sub1].p_event_id = ce1.parent_event_id, info->form_qual[cnt_form
   ].sub1_qual[cnt_sub1].event_id = ce1.event_id,
   stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,10), cnt_sub2 = 0
  HEAD ce2.event_id
   cnt_sub2 = (cnt_sub2+ 1)
   IF (mod(cnt_sub2,10)=1
    AND cnt_sub2 != 1)
    stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,(cnt_sub2+ 10))
   ENDIF
   info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_display = trim(
    uar_get_code_display(ce2.event_cd)), info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[
   cnt_sub2].event_result = trim(ce2.result_val), info->form_qual[cnt_form].sub1_qual[cnt_sub1].
   sub2_qual[cnt_sub2].event_date = format(ce2.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
   info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_comm = trim(lb.long_blob),
   info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_comp_cd = cen
   .compression_cd, info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].p_event_id =
   ce2.parent_event_id,
   info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].event_id = ce2.event_id, stat =
   alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual,10),
   cnt_sub3 = 0
  HEAD ce3.event_id
   IF (ce3.result_status_cd != inerror_cd
    AND ce3.event_id > 0)
    cnt_sub3 = (cnt_sub3+ 1)
    IF (mod(cnt_sub3,10)=1
     AND cnt_sub3 != 1)
     stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual,(
      cnt_sub3+ 10))
    ENDIF
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].
    event_display = trim(uar_get_code_display(ce3.event_cd)), info->form_qual[cnt_form].sub1_qual[
    cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].event_result = trim(ce3.result_val), info->
    form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].event_date =
    format(ce3.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].event_comm
     = trim(lb1.long_blob), info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual[cnt_sub3].event_comp_cd = cen1.compression_cd, info->form_qual[cnt_form].sub1_qual[
    cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].p_event_id = ce3.parent_event_id,
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].event_id =
    ce3.event_id, stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
     sub3_qual[cnt_sub3].sub4_qual,10), cnt_sub4 = 0
   ENDIF
  HEAD ce4.event_id
   IF (ce4.result_status_cd != inerror_cd
    AND ce4.event_id > 0)
    cnt_sub4 = (cnt_sub4+ 1)
    IF (mod(cnt_sub4,10)=1
     AND cnt_sub4 != 1)
     stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[
      cnt_sub3].sub4_qual,(cnt_sub4+ 10))
    ENDIF
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[
    cnt_sub4].event_display = trim(uar_get_code_display(ce4.event_cd)), info->form_qual[cnt_form].
    sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].event_result =
    trim(ce4.result_val), info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
    sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].event_date = format(ce4.event_end_dt_tm,
     "mm/dd/yy hh:mm;;d"),
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[
    cnt_sub4].event_comm = trim(lb2.long_blob), info->form_qual[cnt_form].sub1_qual[cnt_sub1].
    sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[cnt_sub4].event_comp_cd = cen2.compression_cd,
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[
    cnt_sub4].p_event_id = ce4.parent_event_id,
    info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[cnt_sub3].sub4_qual[
    cnt_sub4].event_id = ce4.event_id
   ENDIF
  FOOT  ce4.event_id
   row + 0
  FOOT  ce3.event_id
   stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual[
    cnt_sub3].sub4_qual,cnt_sub4), info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].
   sub3_qual[cnt_sub3].sub4_cnt = cnt_sub4
  FOOT  ce2.event_id
   stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_qual,
    cnt_sub3), info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual[cnt_sub2].sub3_cnt = cnt_sub3
  FOOT  ce1.event_id
   stat = alterlist(info->form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_qual,cnt_sub2), info->
   form_qual[cnt_form].sub1_qual[cnt_sub1].sub2_cnt = cnt_sub2
  FOOT  ce.event_id
   stat = alterlist(info->form_qual[cnt_form].sub1_qual,cnt_sub1), info->form_qual[cnt_form].sub1_cnt
    = cnt_sub1
  FOOT  ce.event_end_dt_tm
   row + 0
  FOOT REPORT
   stat = alterlist(info->form_qual,cnt_form), info->form_cnt = cnt_form
  WITH nocounter, memsort
 ;end select
 CALL echorecord(info)
 CALL echo("Print report")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headsec(ncalc=i2) = f8 WITH protect
 DECLARE headsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE linesec(ncalc=i2) = f8 WITH protect
 DECLARE linesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patnamesec(ncalc=i2) = f8 WITH protect
 DECLARE patnamesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientsec(ncalc=i2) = f8 WITH protect
 DECLARE patientsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE codestatussec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE codestatussecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE advdirsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE advdirsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE allergytitlesec(ncalc=i2) = f8 WITH protect
 DECLARE allergytitlesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergysec(ncalc=i2) = f8 WITH protect
 DECLARE allergysecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergydetailsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE allergydetailsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE immundetailsec(ncalc=i2) = f8 WITH protect
 DECLARE immundetailsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE insurancedetailsec(ncalc=i2) = f8 WITH protect
 DECLARE insurancedetailsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE contactdetailsec(ncalc=i2) = f8 WITH protect
 DECLARE contactdetailsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE contactdetailsec2(ncalc=i2) = f8 WITH protect
 DECLARE contactdetailsec2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powernotetitlesec(ncalc=i2) = f8 WITH protect
 DECLARE powernotetitlesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powernotesec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE powernotesecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE powerformtitlesec(ncalc=i2) = f8 WITH protect
 DECLARE powerformtitlesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powerformsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE powerformsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE formtype(ncalc=i2) = f8 WITH protect
 DECLARE formtypeabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE formtitle(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE formtitleabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE sub1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub3(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub3abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub4(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sub4abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE vitals(ncalc=i2) = f8 WITH protect
 DECLARE vitalsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footsec(ncalc=i2) = f8 WITH protect
 DECLARE footsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
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
 DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontcodestatussec = i2 WITH noconstant(0), protect
 DECLARE _remadvdirlbl = i4 WITH noconstant(1), protect
 DECLARE _bcontadvdirsec = i2 WITH noconstant(0), protect
 DECLARE _remallergiesdetaillbl = i4 WITH noconstant(1), protect
 DECLARE _bcontallergydetailsec = i2 WITH noconstant(0), protect
 DECLARE _remphydischsumlbl = i4 WITH noconstant(1), protect
 DECLARE _bcontpowernotesec = i2 WITH noconstant(0), protect
 DECLARE _hrtf_phydischsumlbl = i4 WITH noconstant(0), protect
 DECLARE _remphydischsumlbl = i4 WITH noconstant(1), protect
 DECLARE _bcontpowerformsec = i2 WITH noconstant(0), protect
 DECLARE _hrtf_phydischsumlbl = i4 WITH noconstant(0), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _bcontformtitle = i2 WITH noconstant(0), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _bcontsub1 = i2 WITH noconstant(0), protect
 DECLARE _remsub2out = i4 WITH noconstant(1), protect
 DECLARE _bcontsub2 = i2 WITH noconstant(0), protect
 DECLARE _remsub3out = i4 WITH noconstant(1), protect
 DECLARE _bcontsub3 = i2 WITH noconstant(0), protect
 DECLARE _remsub4out = i4 WITH noconstant(1), protect
 DECLARE _bcontsub4 = i2 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times24u0 = i4 WITH noconstant(0), protect
 DECLARE _times14u0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c255 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_bmp,"bhscust:baysatehealthlogo.bmp")
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
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
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.630000), private
   DECLARE __datetime = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime3),";;q"),char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.042)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 4.625
    SET rptsd->m_height = 0.500
    SET _oldfont = uar_rptsetfont(_hreport,_times24u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Care Discharge Report",char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 0.000),(offsety+ 0.000),2.375,
     0.625,1)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 2.490)
    SET rptsd->m_width = 3.885
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__datetime)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE linesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = linesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE linesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 7.500),(offsety+
     0.063))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patnamesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patnamesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patnamesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(info->name,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times16b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.810000), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(info->name,char(0))), protect
   DECLARE __fieldname20 = vc WITH noconstant(build2(info->dob,char(0))), protect
   DECLARE __fieldname22 = vc WITH noconstant(build2(info->cmrn,char(0))), protect
   DECLARE __fieldname23 = vc WITH noconstant(build2(trim(info->address,3),char(0))), protect
   DECLARE __fieldname24 = vc WITH noconstant(build2(info->phone,char(0))), protect
   DECLARE __fieldname25 = vc WITH noconstant(build2(info->pcp,char(0))), protect
   DECLARE __fieldname26 = vc WITH noconstant(build2(info->attending,char(0))), protect
   DECLARE __fieldname27 = vc WITH noconstant(build2(info->dischargefacility,char(0))), protect
   DECLARE __fieldname28 = vc WITH noconstant(build2(info->lastnurseunit,char(0))), protect
   DECLARE __fieldname29 = vc WITH noconstant(build2(info->admin_dt_tm,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 5.813
    SET rptsd->m_height = 0.271
    SET _oldfont = uar_rptsetfont(_hreport,_times16b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Birthdate:",char(0)))
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Facility:",char(0)))
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending:",char(0)))
    SET rptsd->m_y = (offsety+ 1.292)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PCP:",char(0)))
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.760
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.885
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address:",char(0)))
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname20)
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.552
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname22)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.875)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 1.010
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c255)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname23)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.271
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname24)
    SET rptsd->m_y = (offsety+ 1.292)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.896
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname25)
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname26)
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.854
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname27)
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.823
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname28)
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 4.542)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname29)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 3.292)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Dt/Tm:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE codestatussec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = codestatussecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE codestatussecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname1 = vc WITH noconstant(build2(info->code_status_name,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(status_detail,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname3 = 1
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
    SET rptsd->m_y = (offsety+ 0.167)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname3 = _remfieldname3
   IF (_remfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
        __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
    SET drawheight_fieldname3 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
       _remfieldname3)+ 1),__fieldname3)))))
     SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname3 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname3)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.323
   SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Code Status Order:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.667)
   SET rptsd->m_width = 5.760
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times14u0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.167)
   SET rptsd->m_x = (offsetx+ 1.667)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times140)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Details:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.167)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = drawheight_fieldname3
   IF (ncalc=rpt_render
    AND _holdremfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size(
        __fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
   ELSE
    SET _remfieldname3 = _holdremfieldname3
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
 SUBROUTINE advdirsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = advdirsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE advdirsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_advdirlbl = f8 WITH noconstant(0.0), private
   DECLARE __advdirlbl = vc WITH noconstant(build2(advdirval,char(0))), protect
   IF (bcontinue=0)
    SET _remadvdirlbl = 1
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
   SET rptsd->m_x = (offsetx+ 2.667)
   SET rptsd->m_width = 4.229
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremadvdirlbl = _remadvdirlbl
   IF (_remadvdirlbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remadvdirlbl,((size(
        __advdirlbl) - _remadvdirlbl)+ 1),__advdirlbl)))
    SET drawheight_advdirlbl = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remadvdirlbl = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remadvdirlbl,((size(__advdirlbl) -
       _remadvdirlbl)+ 1),__advdirlbl)))))
     SET _remadvdirlbl = (_remadvdirlbl+ rptsd->m_drawlength)
    ELSE
     SET _remadvdirlbl = 0
    ENDIF
    SET growsum = (growsum+ _remadvdirlbl)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.042)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(advdirtitle,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.667)
   SET rptsd->m_width = 4.229
   SET rptsd->m_height = drawheight_advdirlbl
   SET _dummyfont = uar_rptsetfont(_hreport,_times140)
   IF (ncalc=rpt_render
    AND _holdremadvdirlbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremadvdirlbl,((size(
        __advdirlbl) - _holdremadvdirlbl)+ 1),__advdirlbl)))
   ELSE
    SET _remadvdirlbl = _holdremadvdirlbl
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
 SUBROUTINE allergytitlesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergytitlesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergytitlesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(allergydisplay,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergysec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergysecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergysecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 6.563
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(allergy,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergydetailsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergydetailsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergydetailsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_allergiesdetaillbl = f8 WITH noconstant(0.0), private
   DECLARE __allergiesdetaillbl = vc WITH noconstant(build2(allergiesdetail,char(0))), protect
   IF (bcontinue=0)
    SET _remallergiesdetaillbl = 1
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
   SET rptsd->m_x = (offsetx+ 1.292)
   SET rptsd->m_width = 6.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremallergiesdetaillbl = _remallergiesdetaillbl
   IF (_remallergiesdetaillbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergiesdetaillbl,((
       size(__allergiesdetaillbl) - _remallergiesdetaillbl)+ 1),__allergiesdetaillbl)))
    SET drawheight_allergiesdetaillbl = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remallergiesdetaillbl = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergiesdetaillbl,((size(
        __allergiesdetaillbl) - _remallergiesdetaillbl)+ 1),__allergiesdetaillbl)))))
     SET _remallergiesdetaillbl = (_remallergiesdetaillbl+ rptsd->m_drawlength)
    ELSE
     SET _remallergiesdetaillbl = 0
    ENDIF
    SET growsum = (growsum+ _remallergiesdetaillbl)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.292)
   SET rptsd->m_width = 6.188
   SET rptsd->m_height = drawheight_allergiesdetaillbl
   IF (ncalc=rpt_render
    AND _holdremallergiesdetaillbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergiesdetaillbl,
       ((size(__allergiesdetaillbl) - _holdremallergiesdetaillbl)+ 1),__allergiesdetaillbl)))
   ELSE
    SET _remallergiesdetaillbl = _holdremallergiesdetaillbl
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
 SUBROUTINE immundetailsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immundetailsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE immundetailsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __immunnamelbl = vc WITH noconstant(build2(info->immun[x].name,char(0))), protect
   DECLARE __immundatelbl = vc WITH noconstant(build2(info->immun[x].given_date,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(immuntitle,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunnamelbl)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.625
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immundatelbl)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE insurancedetailsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = insurancedetailsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE insurancedetailsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.250000), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(info->ins_qual[x].name,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(info->ins_qual[x].type,char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(info->ins_qual[x].member_nbr,char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(info->ins_qual[x].group_nbr,char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(info->ins_qual[x].subscriber,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(insurancetitle,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 5.938
    SET rptsd->m_height = 0.323
    SET _dummyfont = uar_rptsetfont(_hreport,_times14u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.271
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.167)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.167)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Group #:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.167)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Member #:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.167)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE contactdetailsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = contactdetailsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE contactdetailsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __name = vc WITH noconstant(build2(info->cont_qual[x].name,char(0))), protect
   DECLARE __relation = vc WITH noconstant(build2(info->cont_qual[x].relation,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.948
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(contacttitle,char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__relation)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE contactdetailsec2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = contactdetailsec2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE contactdetailsec2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __type = vc WITH noconstant(build2(info->cont_qual[x].phone_qual[y].phonetype,char(0))),
   protect
   DECLARE __number = vc WITH noconstant(build2(info->cont_qual[x].phone_qual[y].phone,char(0))),
   protect
   DECLARE __ext = vc WITH noconstant(build2(info->cont_qual[x].phone_qual[y].ext,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__type)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__number)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ext)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powernotetitlesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernotetitlesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powernotetitlesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(powernotetitle,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powernotesec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernotesecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powernotesecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_phydischsumlbl = f8 WITH noconstant(0.0), private
   DECLARE __phydischsumlbl = vc WITH noconstant(build2(trim(info->powernote[x].rtfblob,3),char(0))),
   protect
   IF (bcontinue=0)
    SET _remphydischsumlbl = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remphydischsumlbl > 0)
    IF (_hrtf_phydischsumlbl=0)
     SET _hrtf_phydischsumlbl = uar_rptcreatertf(_hreport,__phydischsumlbl,5.000)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_phydischsumlbl,(offsetx+ 0.000),(offsety+ 0.000),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_phydischsumlbl)
     SET _hrtf_phydischsumlbl = 0
     SET _remphydischsumlbl = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remphydischsumlbl)
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
 SUBROUTINE powerformtitlesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powerformtitlesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powerformtitlesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(powerformtitle,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powerformsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powerformsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powerformsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_phydischsumlbl = f8 WITH noconstant(0.0), private
   DECLARE __phydischsumlbl = vc WITH noconstant(build2(trim(info->powerform[x].rtfblob,3),char(0))),
   protect
   IF (bcontinue=0)
    SET _remphydischsumlbl = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remphydischsumlbl > 0)
    IF (_hrtf_phydischsumlbl=0)
     SET _hrtf_phydischsumlbl = uar_rptcreatertf(_hreport,__phydischsumlbl,7.479)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_phydischsumlbl,(offsetx+ - (0.062)),(offsety+ 0.000),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_phydischsumlbl)
     SET _hrtf_phydischsumlbl = 0
     SET _remphydischsumlbl = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remphydischsumlbl)
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
 SUBROUTINE formtype(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = formtypeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE formtypeabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formtypedisp,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE formtitle(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = formtitleabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE formtitleabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname1 = vc WITH noconstant(build2(output_display,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname1 = 1
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
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.167)
   SET rptsd->m_width = 7.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.167)
   SET rptsd->m_width = 7.313
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
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
 SUBROUTINE sub1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sub1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sub1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname1 = vc WITH noconstant(build2(output_display,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname1 = 1
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
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
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
 SUBROUTINE sub2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sub2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sub2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sub2out = f8 WITH noconstant(0.0), private
   DECLARE __sub2out = vc WITH noconstant(build2(output_display,char(0))), protect
   IF (bcontinue=0)
    SET _remsub2out = 1
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
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsub2out = _remsub2out
   IF (_remsub2out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsub2out,((size(
        __sub2out) - _remsub2out)+ 1),__sub2out)))
    SET drawheight_sub2out = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsub2out = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsub2out,((size(__sub2out) -
       _remsub2out)+ 1),__sub2out)))))
     SET _remsub2out = (_remsub2out+ rptsd->m_drawlength)
    ELSE
     SET _remsub2out = 0
    ENDIF
    SET growsum = (growsum+ _remsub2out)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = drawheight_sub2out
   IF (ncalc=rpt_render
    AND _holdremsub2out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsub2out,((size(
        __sub2out) - _holdremsub2out)+ 1),__sub2out)))
   ELSE
    SET _remsub2out = _holdremsub2out
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
 SUBROUTINE sub3(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sub3abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sub3abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sub3out = f8 WITH noconstant(0.0), private
   DECLARE __sub3out = vc WITH noconstant(build2(output_display,char(0))), protect
   IF (bcontinue=0)
    SET _remsub3out = 1
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
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsub3out = _remsub3out
   IF (_remsub3out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsub3out,((size(
        __sub3out) - _remsub3out)+ 1),__sub3out)))
    SET drawheight_sub3out = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsub3out = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsub3out,((size(__sub3out) -
       _remsub3out)+ 1),__sub3out)))))
     SET _remsub3out = (_remsub3out+ rptsd->m_drawlength)
    ELSE
     SET _remsub3out = 0
    ENDIF
    SET growsum = (growsum+ _remsub3out)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = drawheight_sub3out
   IF (ncalc=rpt_render
    AND _holdremsub3out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsub3out,((size(
        __sub3out) - _holdremsub3out)+ 1),__sub3out)))
   ELSE
    SET _remsub3out = _holdremsub3out
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
 SUBROUTINE sub4(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sub4abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sub4abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sub4out = f8 WITH noconstant(0.0), private
   DECLARE __sub4out = vc WITH noconstant(build2(output_display,char(0))), protect
   IF (bcontinue=0)
    SET _remsub4out = 1
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
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsub4out = _remsub4out
   IF (_remsub4out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsub4out,((size(
        __sub4out) - _remsub4out)+ 1),__sub4out)))
    SET drawheight_sub4out = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsub4out = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsub4out,((size(__sub4out) -
       _remsub4out)+ 1),__sub4out)))))
     SET _remsub4out = (_remsub4out+ rptsd->m_drawlength)
    ELSE
     SET _remsub4out = 0
    ENDIF
    SET growsum = (growsum+ _remsub4out)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = drawheight_sub4out
   IF (ncalc=rpt_render
    AND _holdremsub4out > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsub4out,((size(
        __sub4out) - _holdremsub4out)+ 1),__sub4out)))
   ELSE
    SET _remsub4out = _holdremsub4out
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
 SUBROUTINE vitals(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitalsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE vitalsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __fieldname5 = vc WITH noconstant(build2(info->vitals[1].wt_result,char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(info->vitals[1].pulse_result,char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(info->vitals[1].bp_display,char(0))), protect
   DECLARE __fieldname8 = vc WITH noconstant(build2(info->vitals[1].wt_dt_tm,char(0))), protect
   DECLARE __fieldname9 = vc WITH noconstant(build2(info->vitals[1].pulse_dt_tm,char(0))), protect
   DECLARE __fieldname10 = vc WITH noconstant(build2(info->vitals[1].bp_dt_tm,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.354
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vitals",char(0)))
    SET rptsd->m_y = (offsety+ 0.240)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight",char(0)))
    SET rptsd->m_y = (offsety+ 0.469)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.260
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Heart Rate",char(0)))
    SET rptsd->m_y = (offsety+ 0.719)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Pressure",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 2.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
    SET rptsd->m_y = (offsety+ 0.698)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 2.021
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
    SET rptsd->m_y = (offsety+ 0.240)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
    SET rptsd->m_y = (offsety+ 0.469)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname9)
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Result",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Last Result",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.042)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.271
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_HOME_CARE_DISCHARGE"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
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
   SET rptfont->m_pointsize = 24
   SET rptfont->m_underline = rpt_on
   SET _times24u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_off
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _times14u0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_rgbcolor = rpt_red
   SET _pen14s0c255 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = headsec(rpt_render)
 SET d0 = linesec(rpt_render)
 SET d0 = patientsec(rpt_render)
 IF (size(info->code_status_detail,5) > 0)
  SET d0 = linesec(rpt_render)
  FOR (x = 1 TO size(info->code_status_detail,5))
   IF (x > 1)
    SET status_detail = concat(status_detail,char(13))
   ENDIF
   SET status_detail = concat(status_detail,info->code_status_detail[x].display)
  ENDFOR
  SET d0 = codestatussec(rpt_render,8.5,becont)
 ENDIF
 IF (size(info->advdir,5) > 0)
  CALL echo("printing Advanced")
  SET d0 = linesec(rpt_render)
  FOR (x = 1 TO size(info->advdir,5))
    SET advdirtitle = concat(trim(info->advdir[x].advanceddirectivetitle,3),":")
    SET advdirval = trim(info->advdir[x].advanceddirectiveval,3)
    SET d0 = advdirsec(rpt_render,8.5,becont)
  ENDFOR
 ENDIF
 IF (size(bhs_allergies_reply->persons[1].allergies,5) > 0)
  SET d0 = linesec(rpt_render)
  FOR (x = 1 TO size(bhs_allergies_reply->persons[1].allergies,5))
    SET allergy = trim(bhs_allergies_reply->persons[1].allergies[x].substance_disp,3)
    SET allergiesdetail = ""
    IF (x > 1)
     SET allergydisplay = ""
     CALL echo("clear")
    ELSE
     SET d0 = allergytitlesec(rpt_render)
    ENDIF
    SET d0 = allergysec(rpt_render)
    IF (size(bhs_allergies_reply->persons[1].allergies[x].reactions,5) > 0)
     SET allergiesdetail = "reactions:"
     FOR (r = 1 TO size(bhs_allergies_reply->persons[1].allergies[x].reactions,5))
       SET allergiesdetail = concat(allergiesdetail,char(13),tab,tab,bhs_allergies_reply->persons[1].
        allergies[x].reactions[r].reaction_disp)
     ENDFOR
    ENDIF
    IF (size(bhs_allergies_reply->persons[1].allergies[x].comments,5) > 0)
     IF (textlen(allergiesdetail) > 0)
      SET allergiesdetail = concat(allergiesdetail,char(13))
     ENDIF
     SET allergiesdetail = concat(allergiesdetail,"Comments:")
     FOR (r = 1 TO size(bhs_allergies_reply->persons[1].allergies[x].comments,5))
       SET allergiesdetail = concat(allergiesdetail,char(13),tab,tab,bhs_allergies_reply->persons[1].
        allergies[x].comments[r].comment)
     ENDFOR
    ENDIF
    IF (((_yoffset+ allergydetailsec(rpt_calcheight,8.5,becont)) > 10))
     SET d0 = pgbreak(1)
     SET allergydisplay = "Allergies (Continued):"
     SET d0 = allergytitlesec(rpt_render)
     SET d0 = allergysec(rpt_render)
     SET allergydisplay = ""
    ENDIF
    IF (textlen(trim(allergiesdetail,3)) > 0)
     SET d0 = allergydetailsec(rpt_render,8.5,becont)
    ENDIF
  ENDFOR
 ENDIF
 IF (size(info->immun,5) > 0)
  CALL echo("print immun")
  FOR (x = 1 TO size(info->immun,5))
    IF (((_yoffset+ immundetailsec(rpt_calcheight)) > 10))
     SET d0 = pgbreak(1)
    ENDIF
    IF (x > 1)
     SET immuntitle = ""
    ELSE
     SET d0 = linesec(rpt_render)
    ENDIF
    SET d0 = immundetailsec(rpt_render)
  ENDFOR
 ENDIF
 IF (size(info->ins_qual,5) > 0)
  CALL echo("print insurnace info")
  FOR (x = 1 TO size(info->ins_qual,5))
    IF (((_yoffset+ insurancedetailsec(rpt_calcheight)) > 10))
     SET d0 = pgbreak(1)
     SET d0 = linesec(rpt_render)
    ENDIF
    IF (x > 1)
     SET insurancetitle = ""
    ELSE
     SET d0 = linesec(rpt_render)
    ENDIF
    SET d0 = insurancedetailsec(rpt_render)
  ENDFOR
 ENDIF
 IF (size(info->cont_qual,5) > 0)
  CALL echo("print contacts")
  FOR (x = 1 TO size(info->cont_qual,5))
    IF (((_yoffset+ contactdetailsec(rpt_calcheight)) > 9.5))
     SET d0 = pgbreak(1)
    ENDIF
    IF (x > 1)
     SET insurancetitle = ""
    ELSE
     SET d0 = linesec(rpt_render)
    ENDIF
    SET d0 = contactdetailsec(rpt_render)
    FOR (y = 1 TO size(info->cont_qual[x].phone_qual,5))
      SET d0 = contactdetailsec2(rpt_render)
    ENDFOR
  ENDFOR
 ENDIF
 IF (size(info->powernote,5) > 0)
  FOR (x = 1 TO size(info->powernote,5))
    CALL echo("print PowerNote")
    SET becont = 0
    CALL echo("print powerNotes")
    SET d0 = pgbreak(1)
    SET d0 = linesec(rpt_render)
    FOR (y = 1 TO 100)
      IF (y=1)
       SET powernotetitle = info->powernote[x].title
      ELSE
       SET powernotetitle = concat(info->powernote[x].title," (continued)")
      ENDIF
      SET d0 = powernotetitlesec(rpt_render)
      SET d0 = powernotesec(rpt_render,7.75,becont)
      IF (becont <= 0)
       SET y = 100
      ELSE
       SET d0 = pgbreak(1)
       SET d0 = linesec(rpt_render)
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 CALL echo("print THERAPY forms")
 CALL printforms("THERAPY")
 CALL echo("Print Vitals")
 CALL printforms("VITALS")
 CALL echo("print Braden forms")
 CALL printforms("BRADEN")
 SET d0 = linesec(rpt_render)
 SET d0 = footsec(rpt_render)
 SET d0 = finalizereport(value(outputdev))
 SUBROUTINE pgbreak(dummy)
   CALL echo("Page break")
   SET d0 = linesec(rpt_render)
   SET d0 = footsec(rpt_render)
   SET d0 = pagebreak(dummy)
   SET d0 = headsec(rpt_render)
   SET d0 = linesec(rpt_render)
   SET d0 = patnamesec(rpt_render)
 END ;Subroutine
 SUBROUTINE validatecodevalue(type,codeset,val)
   DECLARE codeval = f8 WITH noconstant(0.0)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
#exit_program
 EXECUTE bhs_sys_get_allergies_req "cleanup"
 IF (textlen(trim(errmsg,3)) > 0)
  CALL echo(errmsg)
  SELECT INTO value(outputdev)
   FROM dummyt
   HEAD REPORT
    msg1 = errmsg, col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, mine, time = 5
  ;end select
  DECLARE hlog = i4 WITH protect, noconstant(0)
  DECLARE hstat = i4 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE printforms(formtype)
   DECLARE output_display = vc WITH noconstant(" ")
   DECLARE output_title = vc WITH noconstant(" ")
   DECLARE output_sub1 = vc WITH noconstant(" ")
   DECLARE output_sub2 = vc WITH noconstant(" ")
   DECLARE output_sub3 = vc WITH noconstant(" ")
   DECLARE spacer = vc WITH noconstant(" ")
   DECLARE formtypedisp = vc WITH noconstant(" ")
   SET blob_compressed_trimmed = fillstring(64000," ")
   SET blob_uncompressed = fillstring(64000," ")
   SET blob_return_len = 0
   SET blob_out = fillstring(64000," ")
   FREE RECORD formrec
   RECORD formrec(
     1 qual[*]
       2 recnum = i4
   )
   SET refcnt = 0
   SET ref_id = 0
   IF (formtype="THERAPY")
    SET formtypedisp = "Therapy Forms"
    CALL echo("find therapy form")
    FOR (l = 1 TO info->form_cnt)
      IF ((info->form_qual[l].sort <= 5))
       SET refcnt = (refcnt+ 1)
       SET stat = alterlist(formrec->qual,refcnt)
       SET formrec->qual[refcnt].recnum = l
      ENDIF
    ENDFOR
   ELSEIF (formtype="BRADEN")
    SET formtypedisp = "Braden Forms"
    CALL echo("find braden forms")
    SELECT INTO "NL:"
     dt = info->form_qual[d.seq].form_date, ref_id = info->form_qual[d.seq].dcp_forms_ref_id
     FROM (dummyt d  WITH seq = info->form_cnt)
     PLAN (d
      WHERE (info->form_qual[d.seq].sort=6))
     ORDER BY ref_id, dt
     HEAD ref_id
      tempseq = d.seq, refcnt = (refcnt+ 1), stat = alterlist(formrec->qual,refcnt),
      formrec->qual[refcnt].recnum = d.seq, info->form_qual[d.seq].form_name = concat(info->
       form_qual[d.seq].form_name," - INITIAL")
     HEAD dt
      stat = 0
     FOOT  ref_id
      IF (tempseq != d.seq)
       refcnt = (refcnt+ 1), stat = alterlist(formrec->qual,refcnt), formrec->qual[refcnt].recnum = d
       .seq,
       info->form_qual[d.seq].form_name = concat(info->form_qual[d.seq].form_name," - FINAL")
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (formtype="VITALS")
    SET formtypedisp = "Vital Forms"
    CALL echo("find Vital form")
    FOR (l = 1 TO info->form_cnt)
      IF ((info->form_qual[l].sort=7))
       SET refcnt = (refcnt+ 1)
       SET stat = alterlist(formrec->qual,refcnt)
       SET formrec->qual[refcnt].recnum = l
      ENDIF
    ENDFOR
   ENDIF
   IF (size(formrec->qual,5) > 0)
    IF (((_yoffset+ formtitle(rpt_calcheight,8.5,becont)) > 7))
     SET d0 = pgbreak(1)
    ENDIF
    SET d0 = linesec(rpt_render)
    SET d0 = formtype(rpt_render)
    SET formtypedisp = concat(formtypedisp," (continued)")
   ENDIF
   FOR (e = 1 TO size(formrec->qual,5))
     SET l = formrec->qual[e].recnum
     SET output_display = ""
     SET output_title = concat(info->form_qual[l].form_name," - ",info->form_qual[l].form_date)
     SET output_display = replace(output_title,"ocf_blob"," ")
     IF (((_yoffset+ formtitle(rpt_calcheight,8.5,becont)) > 7.5))
      SET d0 = pgbreak(1)
      SET d0 = linesec(rpt_render)
      SET d0 = formtype(rpt_render)
     ENDIF
     SET d0 = formtitle(rpt_render,8.5,becont)
     SET becont = 0
     FOR (l1 = 1 TO info->form_qual[l].sub1_cnt)
       SET output_dispaly = ""
       SET output_sub1 = ""
       SET becont = 0
       SET output_sub1 = concat(info->form_qual[l].sub1_qual[l1].event_display)
       SET output_display = replace(output_sub1,"ocf_blob"," ")
       IF (((_yoffset+ sub1(rpt_calcheight,8.5,becont)) > 9.5))
        SET d0 = pgbreak(1)
        SET d0 = linesec(rpt_render)
        SET d0 = formtype(rpt_render)
        SET output_display = concat(output_title," (continued)")
        SET d0 = formtitle(rpt_render,8.5,becont)
       ENDIF
       SET output_display = replace(output_sub1,"ocf_blob"," ")
       SET d0 = sub1(rpt_render,8.5,becont)
       FOR (l2 = 1 TO info->form_qual[l].sub1_qual[l1].sub2_cnt)
         SET becont = 0
         SET output_dispaly = ""
         SET output_sub2 = ""
         SET spacer =
         IF (textlen(trim(info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_result,3)) > 0) " - "
         ELSE " "
         ENDIF
         SET output_sub2 = concat(info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_display,spacer,
          info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_result)
         SET output_sub2 = replace(output_sub2,char(13)," ")
         SET output_sub2 = replace(output_sub2,char(10)," ")
         SET blob_out = info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comm
         IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comp_cd > 0))
          IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comp_cd=ocfcomp))
           SET blob_compressed_trimmed = fillstring(64000," ")
           SET blob_uncompressed = fillstring(64000," ")
           SET blob_return_len = 0
           SET blob_out = fillstring(64000," ")
           SET blob_compressed_trimmed = info->form_qual[l].sub1_qual[l1].sub2_qual[l2].event_comm
           CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
            blob_uncompressed,size(blob_uncompressed),blob_return_len)
           SET blob_out = replace(blob_uncompressed,"ocf_blob","",0)
          ENDIF
         ENDIF
         SET inbuffer = fillstring(32000," ")
         SET outbufferlen = 0
         SET bfl = 0
         SET bfl2 = 1
         SET outbuffer = fillstring(32000," ")
         CALL echo(blob_out)
         IF (findstring("{\rtf",trim(blob_out,3)))
          SET inbuffer = trim(blob_out)
          CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
           bfl)
          SET blob_out = outbuffer
         ENDIF
         SET output_display = replace(build(trim(output_sub2,3),trim(blob_out,3)),"ocf_blob"," ")
         FOR (y = 1 TO 100)
           IF (((((_yoffset+ sub2(rpt_calcheight,8.5,becont)) > 9.5)) OR (becont > 0)) )
            SET d0 = pgbreak(1)
            SET d0 = linesec(rpt_render)
            SET d0 = formtype(rpt_render)
            SET output_display = concat(output_title," (continued)")
            SET d0 = formtitle(rpt_render,8.5,becont)
            SET output_display = concat(output_sub1," (continued)")
            SET d0 = sub1(rpt_render,8.5,becont)
           ENDIF
           IF (textlen(trim(blob_out,3)) > 0)
            SET output_display = replace(build(trim(output_sub2,3)," - ",trim(blob_out,3)),"ocf_blob",
             " ")
            SET blob_out2 = blob_out
           ELSE
            SET output_display = replace(trim(output_sub2,3),"ocf_blob"," ")
            SET blob_out2 = ""
           ENDIF
           SET d0 = sub2(rpt_render,8.5,becont)
           IF (becont <= 0)
            SET y = 100
           ENDIF
         ENDFOR
         FOR (l3 = 1 TO info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_cnt)
           SET output_sub3 = ""
           SET output_display = ""
           SET becont = 0
           SET spacer =
           IF (textlen(trim(info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].event_result,
             3)) > 0) " - "
           ELSE " "
           ENDIF
           SET output_sub3 = concat(info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
            event_display,spacer,info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
            event_result)
           SET output_sub3 = replace(output_sub3,char(13)," ")
           SET output_sub3 = replace(output_sub3,char(10)," ")
           SET blob_out = info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].event_comm
           IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].event_comp_cd > 0))
            CALL echo("found compressed comments")
            IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].event_comp_cd=ocfcomp))
             SET blob_compressed_trimmed = fillstring(64000," ")
             SET blob_uncompressed = fillstring(64000," ")
             SET blob_return_len = 0
             SET blob_out = fillstring(64000," ")
             CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
              blob_uncompressed,size(blob_uncompressed),blob_return_len)
             SET blob_out = replace(blob_uncompressed,"ocf_blob","",0)
            ENDIF
           ENDIF
           SET inbuffer = fillstring(32000," ")
           SET outbufferlen = 0
           SET bfl = 0
           SET bfl2 = 1
           SET outbuffer = fillstring(32000," ")
           IF (findstring("{\rtf",trim(blob_out,3)))
            CALL echo("comments running UAR_RTF2")
            SET inbuffer = trim(blob_out)
            CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
             bfl)
            SET blob_out = outbuffer
           ENDIF
           SET output_display = replace(concat(trim(output_sub3,3)," -3- ",trim(blob_out,3)),
            "ocf_blob"," ")
           FOR (y = 1 TO 100)
             IF (((((_yoffset+ sub3(rpt_calcheight,8.5,becont)) > 9.5)) OR (becont > 0)) )
              SET d0 = pgbreak(1)
              SET d0 = linesec(rpt_render)
              SET d0 = formtype(rpt_render)
              SET output_display = concat(output_title," (continued)")
              SET d0 = formtitle(rpt_render,8.5,becont)
              SET output_display = concat(output_sub1," (continued)")
              SET d0 = sub1(rpt_render,8.5,becont)
              SET output_display = concat(output_sub2," (continued)")
              SET d0 = sub2(rpt_render,8.5,becont)
             ENDIF
             IF (textlen(trim(blob_out,3)) > 0
              AND trim(blob_out2,3) != trim(blob_out,3))
              SET output_display = replace(build(trim(output_sub3,3)," - ",trim(blob_out,3)),
               "ocf_blob"," ")
              SET blob_out3 = trim(blob_out,3)
             ELSE
              SET output_display = replace(trim(output_sub3,3),"ocf_blob"," ")
              SET blob_out3 = ""
             ENDIF
             SET d0 = sub3(rpt_render,8.5,becont)
             IF (becont <= 0)
              SET y = 100
             ENDIF
           ENDFOR
           FOR (l4 = 1 TO info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].sub4_cnt)
             SET output_sub4 = ""
             SET becont = 0
             SET output_display = ""
             SET output_sub4 = concat(info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].
              sub4_qual[l4].event_display," - ",info->form_qual[l].sub1_qual[l1].sub2_qual[l2].
              sub3_qual[l3].sub4_qual[l4].event_result)
             SET output_sub4 = replace(output_sub4,char(13)," ")
             SET output_sub4 = replace(output_sub4,char(10)," ")
             IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].sub4_qual[l4].
             event_comp_cd > 0))
              IF ((info->form_qual[l].sub1_qual[l1].sub2_qual[l2].sub3_qual[l3].sub4_qual[l4].
              event_comp_cd=ocfcomp))
               SET blob_compressed_trimmed = fillstring(64000," ")
               SET blob_uncompressed = fillstring(64000," ")
               SET blob_return_len = 0
               SET blob_out = fillstring(64000," ")
               SET blob_compressed_trimmed = info->form_qual[l].sub1_qual[l1].sub2_qual[l2].
               sub3_qual[l3].sub4_qual[l4].event_comm
               CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
                blob_uncompressed,size(blob_uncompressed),blob_return_len)
               SET blob_out = replace(blob_uncompressed,"ocf_blob","",0)
              ENDIF
             ENDIF
             SET inbuffer = fillstring(32000," ")
             SET outbufferlen = 0
             SET bfl = 0
             SET bfl2 = 1
             SET outbuffer = fillstring(32000," ")
             IF (findstring("{\rtf",trim(blob_out,3)))
              SET inbuffer = trim(blob_out)
              CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
               bfl)
              SET blob_out = outbuffer
             ENDIF
             SET output_display = replace(concat(trim(output_sub4,3)," - ",trim(blob_out,3)),
              "ocf_blob"," ")
             FOR (y = 1 TO 100)
               IF (((((_yoffset+ sub4(rpt_calcheight,8.5,becont)) > 9.5)) OR (becont > 0)) )
                SET d0 = pgbreak(1)
                SET d0 = linesec(rpt_render)
                SET d0 = formtype(rpt_render)
                SET output_display = concat(output_title," (continued)")
                SET d0 = formtitle(rpt_render,8.5,becont)
                SET output_display = concat(output_sub1," (continued)")
                SET d0 = sub1(rpt_render,8.5,becont)
                SET output_display = concat(output_sub2," (continued)")
                SET d0 = sub2(rpt_render,8.5,becont)
                SET output_display = concat(output_sub3," (continued)")
                SET d0 = sub3(rpt_render,8.5,becont)
               ENDIF
               SET becont = 0
               IF (textlen(trim(blob_out,3)) > 0
                AND trim(blob_out3,3) != trim(blob_out,3))
                SET output_display = replace(build(trim(output_sub4,3),trim(blob_out,3)),"ocf_blob",
                 " ")
               ELSE
                SET output_display = replace(trim(output_sub4,3),"ocf_blob"," ")
               ENDIF
               SET d0 = sub4(rpt_render,8.5,becont)
               IF (becont <= 0)
                SET y = 100
               ENDIF
             ENDFOR
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
END GO
