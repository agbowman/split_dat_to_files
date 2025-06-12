CREATE PROGRAM agc_expire_emerg_list:dba
 PROMPT
  "Enter print option (file/printer/MINE): " = "MINE",
  "Enter Start Date (mmddyyyy): " = "08012003",
  "Enter End Date (mmddyyyy): " = "09052003"
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
 DECLARE nok_var = f8
 SET nok_var = 0.0
 SET stat = uar_get_meaning_by_codeset(352,"NOK",1,nok_var)
 DECLARE deceased_exp = f8
 SET deceased_exp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=268
   AND cv.display_key="EXPIRED"
  DETAIL
   deceased_exp = cv.code_value
  WITH noformat
 ;end select
 DECLARE attend_doc = f8
 SET attend_doc = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"ATTENDDOC",1,attend_doc)
 SET printer =  $1
 SET startdate = cnvtdate( $2)
 SET enddate = cnvtdate( $3)
 FREE RECORD emerg
 RECORD emerg(
   1 qual = i4
   1 list[*]
     2 loc_cd = f8
     2 desc = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key IN ("EMERGENCYCOURT", "EMERGENCY", "EMERGENCYDEPT", "EMERGENCYGENER",
  "EMERGENCYPEDI",
  "EMERGENCYTRAUM")
   AND cv.cdf_meaning="AMBULATORY"
   AND cv.active_ind=1
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(emerg->list,cnt), emerg->list[cnt].loc_cd = cv.code_value,
   emerg->list[cnt].desc = trim(cv.description)
  FOOT REPORT
   emerg->qual = cnt
 ;end select
 FREE RECORD pats
 RECORD pats(
   1 qual = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 facility = f8
     2 location = f8
 )
 SELECT INTO "nl:"
  e.person_id, e.encntr_id, p.deceased_cd,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.location_cd
  FROM (dummyt d  WITH seq = value(emerg->qual)),
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (d)
   JOIN (elh
   WHERE (elh.location_cd=emerg->list[d.seq].loc_cd)
    AND elh.beg_effective_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY p.person_id, e.encntr_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pats->list,cnt), pats->list[cnt].person_id = p.person_id,
   pats->list[cnt].encntr_id = e.encntr_id, pats->list[cnt].facility = elh.loc_facility_cd, pats->
   list[cnt].location = elh.loc_nurse_unit_cd,
   col 1, pats->list[cnt].person_id, col 12,
   pats->list[cnt].encntr_id, col 25, pats->list[cnt].facility,
   col 40, pats->list[cnt].location, row + 1
  FOOT REPORT
   pats->qual = cnt
 ;end select
 SELECT INTO  $1
  pat_name = substring(1,30,p.name_full_formatted), dead_date = format(p.deceased_dt_tm,
   "mm/dd/yy hh:mm;;q"), religion = uar_get_code_display(p.religion_cd),
  sex = substring(1,1,uar_get_code_display(p.sex_cd)), dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
  mrn = cnvtalias(pa.alias,pa.alias_pool_cd),
  fin = cnvtalias(ea.alias,ea.alias_pool_cd), street = decode(a.seq,a.street_addr," "), city = decode
  (a.seq,a.city," "),
  state = decode(a.seq,a.state," "), zip = decode(a.seq,a.zipcode," "), phone = decode(ph.seq,ph
   .phone_num," "),
  church = decode(pp.seq,uar_get_code_display(pp.church_cd)," "), nok_name = decode(nokp.seq,
   substring(1,45,nokp.name_full_formatted)," "), nok_street = decode(noka.seq,noka.street_addr," "),
  nok_city = decode(noka.seq,noka.city," "), nok_state = decode(noka.seq,noka.state," "), nok_zip =
  decode(noka.seq,noka.zipcode," "),
  nok_phone = decode(nokph.seq,nokph.phone_num," ")
  FROM (dummyt d  WITH seq = value(pats->qual)),
   person p,
   person_alias pa,
   dummyt d5,
   encntr_alias ea,
   dummyt d2,
   person_patient pp,
   dummyt d3,
   address a,
   dummyt d4,
   phone ph,
   dummyt d6,
   encntr_person_reltn epr,
   dummyt d7,
   person nokp,
   dummyt d8,
   address noka,
   dummyt d9,
   phone nokph
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=pats->list[d.seq].person_id))
   JOIN (pa
   WHERE (pa.person_id=pats->list[d.seq].person_id)
    AND pa.person_alias_type_cd=mrn_var
    AND pa.active_ind=1)
   JOIN (d5)
   JOIN (ea
   WHERE (ea.encntr_id=pats->list[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=fin_var
    AND ea.active_ind=1)
   JOIN (d2)
   JOIN (pp
   WHERE pp.person_id=p.person_id
    AND pp.active_ind=1)
   JOIN (d3)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND a.parent_entity_id=p.person_id
    AND a.address_type_cd=home_address_type
    AND a.active_ind=1)
   JOIN (d4)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND ph.parent_entity_id=p.person_id
    AND ph.phone_type_cd=home_phone_type
    AND ph.active_ind=1)
   JOIN (d6)
   JOIN (epr
   WHERE (epr.encntr_id=pats->list[d.seq].encntr_id)
    AND epr.person_reltn_type_cd=nok_var
    AND epr.active_ind=1)
   JOIN (d7)
   JOIN (nokp
   WHERE nokp.person_id=epr.related_person_id
    AND nokp.active_ind=1)
   JOIN (d8)
   JOIN (noka
   WHERE noka.parent_entity_name="PERSON"
    AND noka.parent_entity_id=nokp.person_id
    AND noka.address_type_cd=home_address_type
    AND noka.active_ind=1)
   JOIN (d9)
   JOIN (nokph
   WHERE nokph.parent_entity_name="PERSON"
    AND nokph.parent_entity_id=nokp.person_id
    AND nokph.phone_type_cd=home_phone_type
    AND nokph.active_ind=1)
  ORDER BY fin
  HEAD REPORT
   cnt = 0, date_stamp = format(curdate,"mm/dd/yyyy;;d"), time_stamp = format(curtime3,"hh:mm;;z"),
   start_stamp = format(startdate,"mm/dd/yyyy;;d"), end_stamp = format(enddate,"mm/dd/yyyy;;d"), line
    = fillstring(24,"="),
   col 0, row + 1, col 0,
   "{B}",
   CALL center("BAYSTATE HEALTH SYSTEMS",1,95), "{ENDB}",
   row + 1
  HEAD PAGE
   page_stamp = format(curpage,"###;P0"), col 1, date_stamp,
   " ", time_stamp, col 80,
   "PAGE ", page_stamp, row + 1,
   line, row + 1, col 1,
   "EXPIRED EMERGENCY LIST", row + 1, line,
   row + 1, col 1, "SUMMARY FROM ",
   start_stamp, " TO ", end_stamp,
   row + 3
  HEAD fin
   cnt = (cnt+ 1)
   IF (row > 60)
    BREAK
   ENDIF
   col 1, "{F/2}", "{B}",
   pat_name, "{ENDB}", "{F/0}",
   col 69, "NOK: ", nok_name,
   row + 1, col 2, street,
   col 50, "ADDR: ", nok_street,
   row + 1, col 2, city,
   "  ", state, " ",
   zip, col 50, "CITY: ",
   nok_city, " ", nok_state,
   " ", nok_zip, row + 1,
   col 2, phone, col 50,
   "PHON: ", nok_phone, row + 1,
   col 2, "ACCOUNT #: ", fin,
   col 30, "DOB: ", dob,
   row + 1, col 2, "MED REC #: ",
   mrn, col 30, "SEX: ",
   sex, row + 1, col 2,
   "EXP DATE : ", dead_date, row + 1,
   col 2, "DIAGNOSIS: ", row + 1,
   col 2, "DENOMINATION: ", religion,
   row + 1, col 2, "CHURCH: ",
   church, row + 2
  FOOT PAGE
   col 0,
   CALL center("CONTINUED",1,95)
  FOOT REPORT
   tot = format(cnt,"###;L"), filline = fillstring(30," "), col 1,
   "{B}", "TOTAL ES EXPIRED CENSUS: ", tot,
   "{ENDB}", filline, row + 1,
   col 0,
   CALL center("END OF REPORT",1,95)
  WITH dio = postscript, maxcol = 1300, maxrow = 70,
   outerjoin = d2, outerjoin = d3, outerjoin = d4,
   dontcare = pp, dontcare = a, dontcare = ph,
   outerjoin = d5, dontcare = ea, outerjoin = d6,
   outerjoin = d7, outerjoin = d8, outerjoin = d9,
   dontcare = epr, dontcare = nokp, dontcare = noka,
   dontcare = nokph
 ;end select
END GO
