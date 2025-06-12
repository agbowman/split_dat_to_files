CREATE PROGRAM bhs_lab_to_hne_from_build
 PROMPT
  "Enter Start Date (mmddyyyy):" = "BEGOFPREVMONTH",
  "Enter End Date (mmddyyyy):" = "ENDOFPREVMONTH",
  "Enter Facility (FMC, BMC, MLH, BWH, BNH):" = "BMC"
  WITH prompt1, prompt2, prompt3
 IF (( $1="BEGOFPREVMONTH"))
  SET current_month = month(curdate)
  SET month_qual = (current_month - 1)
  SET year_qual = year(curdate)
  IF (month_qual=0)
   SET month_qual = 12
   SET year_qual -= 1
  ENDIF
  SET startdate = cnvtdate(concat(format(month_qual,"##"),"01",format(year_qual,"####")))
 ELSE
  SET startdate = cnvtdate( $1)
 ENDIF
 IF (( $2="ENDOFPREVMONTH"))
  SET current_month = month(curdate)
  SET current_year = year(curdate)
  SET enddate = (cnvtdate(concat(format(current_month,"##"),"01",format(current_year,"####"))) - 1)
 ELSE
  SET enddate = cnvtdate( $2)
 ENDIF
 SET printer = concat("lab",cnvtlower( $3),format(enddate,"MMDDYYYY;;D"))
 SET facility = 0.0
 SET facility_disp = cnvtupper(cnvtalphanum( $3))
 SET echo = 1
 CALL echo(build("Beginning Date:",format(startdate,"MM/DD/YYYY;;D")))
 CALL echo(build("Ending Date:",format(enddate,"MM/DD/YYYY;;D")))
 DECLARE adt_cs = f8
 SET adt_cs = uar_get_code_by("DISPLAYKEY",73,"ADTEGATE")
 DECLARE mrn_var = f8
 SET mrn_var = 0.0
 SET mrnvar = uar_get_meaning_by_codeset(4,"MRN",1,mrn_var)
 DECLARE fin_var = f8
 SET fin_var = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_var)
 DECLARE ssn_cd = f8
 SET ssn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(4,"SSN",1,ssn_cd)
 DECLARE doc_cd = f8
 SET doc_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,doc_cd)
 DECLARE txt_cd = f8
 SET txt_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(53,"TXT",1,txt_cd)
 DECLARE num_cd = f8
 SET num_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,num_cd)
 SET inerror_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(8,"INERROR",1,inerror_cd)
 DECLARE facility_cd = f8
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key=facility_disp
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
   AND cv.data_status_cd=25
  DETAIL
   facility_cd = cv.code_value, col 0, facility_cd,
   row + 1
  WITH noformat
 ;end select
 SELECT INTO value(printer)
  pat_name = substring(1,28,p.name_full_formatted), admit = substring(1,8,format(e.reg_dt_tm,
    "mm/dd/yy;;d")), etype = substring(1,2,cva2.alias),
  pnbr = substring(1,20,ep.member_nbr), dob = substring(1,10,format(cnvtdatetimeutc(datetimezone(p
      .birth_dt_tm,p.birth_tz),1),"mm/dd/yyyy;;d")), catalog = substring(1,16,uar_get_code_display(ce
    .catalog_cd)),
  event = substring(1,15,uar_get_code_display(ce.event_cd)), event_dt = substring(1,10,format(ce
    .event_end_dt_tm,"mm/dd/yyyy hh:mm;;q")), facility = trim(uar_get_code_display(e.loc_facility_cd)
   ),
  fin_class = uar_get_code_display(e.financial_class_cd), event2 = substring(1,15,
   uar_get_code_display(ce2.event_cd)), result = substring(1,30,concat(trim(ce2.result_val))),
  units = substring(1,10,uar_get_code_display(ce2.result_units_cd)), proc = substring(1,5,cva.alias),
  ssn = substring(1,9,pa.alias)"#########;RP0",
  acct = substring(1,10,ea.alias), ce.event_id, ce.parent_event_id,
  ce.encntr_id, ce.event_cd, e.encntr_type_cd
  FROM encounter e,
   code_value_alias cva,
   encntr_plan_reltn ep,
   clinical_event ce,
   clinical_event ce2,
   person p,
   person_alias pa,
   code_value_alias cva2,
   encntr_alias ea
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,235959)
    AND ((e.loc_facility_cd+ 0)=facility_cd)
    AND ((e.financial_class_cd+ 0) IN (680497, 680498, 2482642, 2482643, 2482644,
   59174347, 59174348)))
   JOIN (ep
   WHERE ep.encntr_id=e.encntr_id
    AND ((ep.priority_seq+ 0)=1)
    AND cnvtdatetime(sysdate) BETWEEN (ep.beg_effective_dt_tm+ 0) AND (ep.end_effective_dt_tm+ 0)
    AND ((ep.active_ind+ 0)=1))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ((ce.event_start_dt_tm+ 0) BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,235959)
   )
    AND ((ce.contributor_system_cd+ 0)=703452.00)
    AND ((ce.result_status_cd+ 0)=25)
    AND trim(ce.event_tag) != "In Error"
    AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(sysdate))
    AND  NOT (((ce.event_cd+ 0) IN (710012.00, 2455454.00, 2027276.00, 2420181.00)))
    AND ((ce.event_reltn_cd+ 0)=135.00))
   JOIN (cva
   WHERE cva.code_value=ce.catalog_cd
    AND cva.code_set=200)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.event_id
    AND ((ce2.event_reltn_cd+ 0)=132.00))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (cva2
   WHERE cva2.code_value=e.encntr_type_cd
    AND cva2.code_set=71
    AND cva2.contributor_source_cd=673943.00)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(18))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(ce.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(1077.00))
    AND (ea.active_ind= Outerjoin(1)) )
  ORDER BY pat_name, acct, event,
   event_dt DESC, 0
  HEAD REPORT
   dg1 = fillstring(6," "), dg2 = fillstring(6," "), dg3 = fillstring(6," "),
   adm_dx = fillstring(26," "), delim = "|"
  HEAD pat_name
   x = 0
  HEAD acct
   x = 0, col 1, pat_name,
   col 29, delim, col 30,
   acct"##########;L", col 40, delim,
   col 41, dob, col 51,
   delim, col 52, pnbr"############;L",
   col 64, delim, col 65,
   ssn, col 74, delim,
   col 75, etype, col 76,
   delim, col 77, admit,
   col 85, delim, col 86,
   adm_dx, col 112, delim,
   col 113, dg1, col 119,
   delim, col 120, dg2,
   col 126, delim, col 127,
   dg3, row + 1
  DETAIL
   col 1, acct"##########;L", col 11,
   delim, col 12, proc,
   col 17, delim, col 18,
   event, col 34, delim,
   col 35, event2, col 50,
   delim, col 51, result,
   col 120, delim
   IF (units > " ")
    col 121, units
   ELSE
    col 121, "           "
   ENDIF
   row + 1
  WITH maxcol = 134
 ;end select
 FREE SET dclcom
 DECLARE dclcom = vc
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",printer,".dat ","172.31.30.135 brllab jkf34s2")
 CALL echo(dclcom)
 SET stat = 0
 CALL dcl(dclcom,size(dclcom),stat)
END GO
