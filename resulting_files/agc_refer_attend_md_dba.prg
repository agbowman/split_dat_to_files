CREATE PROGRAM agc_refer_attend_md:dba
 PROMPT
  "Enter print option (file/printer/MINE):" = "MINE",
  "Enter facility (BMC, FMC, MLH, BWH, BWH INPT PSYCH, BNH, BNH INPT PSYCH, BNH REHAB):" = "BMC"
  WITH prompt1, prompt2
 EXECUTE cclseclogin
 DECLARE mrn_var = f8
 SET mrn_var = 0.0
 SET mrnvar = uar_get_meaning_by_codeset(4,"MRN",1,mrn_var)
 DECLARE fin_var = f8
 SET fin_var = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_var)
 DECLARE home_address_type = f8
 SET home_address_type = 0.0
 SET stat = uar_get_meaning_by_codeset(212,"HOME",1,home_address_type)
 DECLARE home_phone_type = f8
 SET home_phone_type = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"HOME",1,home_phone_type)
 DECLARE phone_format = f8
 SET phone_format = 0.0
 SET stat = uar_get_meaning_by_codeset(281,"US",1,phone_format)
 DECLARE attend_doc = f8
 SET attend_doc = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"ATTENDDOC",1,attend_doc)
 DECLARE refer_doc = f8
 SET refer_doc = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"REFERDOC",1,refer_doc)
 DECLARE disch_ip = f8
 SET disch_ip = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=71
   AND cv.display_key="DISCHIP"
   AND cv.active_ind=1
  DETAIL
   disch_ip = cv.code_value
  WITH noformat
 ;end select
 SET printer =  $1
 SET facility_disp = cnvtupper(cnvtalphanum( $2))
 DECLARE facility_cd = f8
 SET facility_cd = 0.0
 DECLARE fac = f8
 SET fac = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key=facility_disp
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
  DETAIL
   facility_cd = cv.code_value, col 0, facility_cd,
   row + 1
  WITH noformat
 ;end select
 FREE RECORD pats
 RECORD pats(
   1 qual = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 facility = f8
     2 location = f8
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 disposition = f8
     2 fin_class = f8
     2 exp_flag = i2
 )
 SELECT INTO "nl:"
  e.person_id, e.encntr_id, e.loc_facility_cd,
  e.loc_nurse_unit_cd, e.disch_dt_tm, e.disch_disposition_cd,
  e.financial_class_cd
  FROM encntr_domain ed,
   encounter e,
   person p
  PLAN (ed
   WHERE ed.loc_facility_cd=facility_cd
    AND ed.end_effective_dt_tm BETWEEN cnvtdatetime((curdate - 200),0) AND cnvtdatetime(curdate,
    curtime3))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=disch_ip)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY p.person_id, e.encntr_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pats->list,cnt), pats->list[cnt].person_id = p.person_id,
   pats->list[cnt].encntr_id = e.encntr_id, pats->list[cnt].facility = e.loc_facility_cd, pats->list[
   cnt].location = e.loc_nurse_unit_cd,
   pats->list[cnt].admit_dt_tm = e.reg_dt_tm, pats->list[cnt].disch_dt_tm = e.disch_dt_tm, pats->
   list[cnt].disposition = e.disch_disposition_cd,
   pats->list[cnt].fin_class = e.financial_class_cd
   IF (p.deceased_cd > 0)
    pats->list[cnt].exp_flag = 1
   ELSE
    pats->list[cnt].exp_flag = 0
   ENDIF
   col 1, pats->list[cnt].person_id, col 12,
   pats->list[cnt].encntr_id, col 25, pats->list[cnt].facility,
   col 40, pats->list[cnt].location, col 55,
   pats->list[cnt].admit_dt_tm, col 70, pats->list[cnt].disch_dt_tm,
   col 85, pats->list[cnt].disposition, row + 1
  FOOT REPORT
   pats->qual = cnt
 ;end select
 SELECT INTO  $1
  encntr = pats->list[d.seq].encntr_id, location = uar_get_code_display(cnvtreal(pats->list[d.seq].
    location)), facility = uar_get_code_display(cnvtreal(pats->list[d.seq].facility)),
  admit_dt = format(pats->list[d.seq].admit_dt_tm,"mm/dd/yy hh:mm;;q"), disch_dt = format(pats->list[
   d.seq].disch_dt_tm,"mm/dd/yy hh:mm;;q"), disch_dp = uar_get_code_display(cnvtreal(pats->list[d.seq
    ].disposition)),
  fin_cl = uar_get_code_display(cnvtreal(pats->list[d.seq].fin_class)), pat_name = substring(1,30,p
   .name_full_formatted), mrn = cnvtalias(pa.alias,pa.alias_pool_cd),
  fin = cnvtalias(ea.alias,ea.alias_pool_cd), street = decode(a.seq,a.street_addr," "), city = decode
  (a.seq,a.city," "),
  state = decode(a.seq,a.state," "), zip = decode(a.seq,a.zipcode," "), phone = decode(ph.seq,ph
   .phone_num," "),
  attend_name = decode(epr.seq,substring(1,30,pl.name_full_formatted)," "), attend_id = pl.person_id,
  refer_name = decode(epr2.seq,substring(1,30,pl2.name_full_formatted)," "),
  refer_id = pl2.person_id
  FROM (dummyt d  WITH seq = value(pats->qual)),
   person p,
   person_alias pa,
   encntr_alias ea,
   dummyt d2,
   address a,
   dummyt d3,
   phone ph,
   dummyt d4,
   encntr_prsnl_reltn epr,
   prsnl pl,
   dummyt d5,
   encntr_prsnl_reltn epr2,
   prsnl pl2
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=pats->list[d.seq].person_id))
   JOIN (pa
   WHERE (pa.person_id=pats->list[d.seq].person_id)
    AND pa.person_alias_type_cd=mrn_var
    AND pa.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id=pats->list[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=fin_var
    AND ea.active_ind=1)
   JOIN (d2)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND a.parent_entity_id=p.person_id
    AND a.address_type_cd=home_address_type
    AND a.active_ind=1)
   JOIN (d3)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND ph.parent_entity_id=p.person_id
    AND ph.phone_type_cd=home_phone_type
    AND ph.active_ind=1)
   JOIN (d4)
   JOIN (epr
   WHERE (epr.encntr_id=pats->list[d.seq].encntr_id)
    AND epr.encntr_prsnl_r_cd=attend_doc
    AND epr.active_ind=1)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id
    AND pl.active_ind=1)
   JOIN (d5)
   JOIN (epr2
   WHERE (epr2.encntr_id=pats->list[d.seq].encntr_id)
    AND epr2.encntr_prsnl_r_cd=refer_doc
    AND epr2.active_ind=1)
   JOIN (pl2
   WHERE pl2.person_id=epr2.prsnl_person_id
    AND pl2.active_ind=1)
  ORDER BY pat_name, encntr
  HEAD REPORT
   start_stamp = format(cnvtdatetime((curdate - 1),0),"mm/dd/yyyy hh:mm;;q"), end_stamp = format(
    cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm;;q"), line = fillstring(56,"="),
   cnt = 0, col 0, row + 1,
   col 0, "{B}",
   CALL center("BAYSTATE HEALTH SYSTEMS",1,95),
   "{ENDB}", row + 1, col 1
  HEAD PAGE
   page_stamp = format(curpage,"###;P0"), col 1, end_stamp,
   col 80, "PAGE ", page_stamp,
   row + 1, col 1, line,
   row + 1, col 1, "INPATIENT DISCHARGE LIST OF REFERRING MD NE ATTENDING MD",
   row + 1, col 1, line,
   row + 1, col 1, "SUMMARY FROM ",
   start_stamp, " TO ", end_stamp,
   row + 1, col 1, "{B}",
   "FACILITY: ", facility_disp, "{ENDB}",
   row + 2, col 1, "UNIT",
   col 10, "ATTENDING MD", col 35,
   "DATE", col 44, "TIME",
   col 52, "STATUS", col 72,
   "DISPOSITION", row + 2
  HEAD encntr
   IF (attend_id != refer_id)
    IF (row > 60)
     BREAK
    ENDIF
    cnt = (cnt+ 1), add_disp = concat(trim(street),char(44),char(32),trim(city),char(44),
     char(32),trim(state),char(44),char(32),trim(zip)), col 1,
    "{F/2}", "{B}", pat_name,
    col 50, "ACCT#: ", fin,
    col 75, "MR#: ", mrn,
    "{ENDB}", "{F/0}", row + 1,
    col 1, location, col 10,
    attend_name, col 35, disch_dt,
    col 72, disch_dp, row + 1,
    col 1, "ADDRESS: ", add_disp,
    row + 1, col 1, "PHONE #: ",
    phone, row + 1, col 1,
    "ADMIT DATE/TIME: ", admit_dt, col 42,
    "FINANCIAL CLASS: ", fin_cl, row + 1,
    col 1, "REFERRING MD: ", refer_name,
    row + 2
   ENDIF
  FOOT PAGE
   col 0,
   CALL center("CONTINUED",1,95)
  FOOT REPORT
   tot = format(cnt,"###;L"), filline = fillstring(30," "), col 1,
   "{B}", "TOTAL DISCHARGED CENSUS: ", tot,
   "{ENDB}", filline, row + 1,
   col 0,
   CALL center("END OF REPORT",1,95)
  WITH dio = postscript, maxcol = 1300, maxrow = 70,
   outerjoin = d2, outerjoin = d3, outerjoin = d4,
   outerjoin = d5, dontcare = a, dontcare = ph,
   dontcare = epr, dontcare = pl, dontcare = epr2,
   dontcare = pl2
 ;end select
END GO
