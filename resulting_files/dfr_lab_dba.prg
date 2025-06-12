CREATE PROGRAM dfr_lab:dba
 PROMPT
  "Enter print option (file/printer/MINE):" = "ccluserdir:dfr_lab.dat",
  "Enter Start Date (mmddyyyy):" = "11012003",
  "Enter End Date (mmddyyyy):" = "11202003",
  "Enter Facility (FMC, BMC, MLH, BWH, BWH INPT PSYCH, BNH, BNH INPT PSYCH, BNH REHAB):" = "BMC"
  WITH prompt1, prompt2, prompt3,
  prompt4
 SET printer =  $1
 SET startdate = cnvtdate( $2)
 SET enddate = cnvtdate( $3)
 SET facility_disp = cnvtupper(cnvtalphanum( $4))
 SET echo = 1
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
  DETAIL
   facility_cd = cv.code_value, col 0, facility_cd,
   row + 1
  WITH noformat
 ;end select
 DECLARE hne_cd = f8
 SET hne_cd = 0.0
 SET hne_cd = uar_get_code_by("displaykey",354,"HEALTHNEWENGLAND")
 DECLARE hne_id = f8
 SET hne_id = 0.0
 SELECT INTO "nl:"
  FROM health_plan hp
  WHERE hp.plan_name_key="HEALTHNEWENGLAND"
   AND hp.active_ind=1
  DETAIL
   hne_id = hp.health_plan_id
  WITH noformat
 ;end select
 DECLARE fin_class_54_cd = f8
 SET fin_class_54_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_set=354
   AND cva.alias="54"
  DETAIL
   fin_class_54_cd = cva.code_value
  WITH nocounter
 ;end select
 DECLARE fin_class_l01_cd = f8
 SET fin_class_l01_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_set=354
   AND cva.alias="L01"
  DETAIL
   fin_class_l01_cd = cva.code_value
  WITH nocounter
 ;end select
 SET lab_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
 SET genlab_cd = uar_get_code_by("MEANING",106,"GLB")
 DECLARE lab_event_disp = f8
 SET lab_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="LABORATORY"
   AND cv.active_ind=1
  DETAIL
   lab_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE chem_event_disp = f8
 SET chem_event_disp = 0.0
 DECLARE endo_event_disp = f8
 SET endo_event_disp = 0.0
 DECLARE heme_event_disp = f8
 SET heme_event_disp = 0.0
 DECLARE immu_event_disp = f8
 SET immu_event_disp = 0.0
 DECLARE urine_event_disp = f8
 SET urine_event_disp = 0.0
 DECLARE toxi_event_disp = f8
 SET toxi_event_disp = 0.0
 SELECT INTO "nl:"
  cv = cv.code_value, d_key = cv.display_key
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.active_ind=1
  DETAIL
   CASE (d_key)
    OF "CHEMISTRY":
     chem_event_disp = cv
    OF "ENDOCRINETUMORMARKER":
     endo_event_disp = cv
    OF "HEMATOLOGY":
     heme_event_disp = cv
    OF "IMMUNOSEROLOGY":
     immu_event_disp = cv
    OF "URINETEST":
     urine_event_disp = cv
    OF "TOXICOLOGYTDM":
     toxi_event_disp = cv
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="URINETEST"
   AND cv.active_ind=1
  DETAIL
   urine_event_disp = cv.code_value
  WITH nocounter
 ;end select
 IF (echo)
  CALL echo(build("CHEMISTRY = ",chem_event_disp))
  CALL echo(build("ENDOCRINETUMORMARKER = ",endo_event_disp))
  CALL echo(build("HEMATOLOGY = ",heme_event_disp))
  CALL echo(build("IMMUNOSEROLOGY = ",immu_event_disp))
  CALL echo(build("URINETEST = ",urine_event_disp))
  CALL echo(build("TOXICOLOGYTDM = ",toxi_event_disp))
 ENDIF
 FREE RECORD parent_event
 RECORD parent_event(
   1 qual = i4
   1 list[*]
     2 parent_cd = f8
 )
 SELECT INTO "nl:"
  parent = decode(esca.seq,esca.parent_event_set_cd,0.0), parenta = decode(esca.seq,esca.event_set_cd,
   0.0), parentb = decode(esca2.seq,esca2.event_set_cd,0.0),
  child = decode(esca3.seq,esca3.event_set_cd,0.0)
  FROM v500_event_set_canon esca,
   v500_event_set_canon esca2,
   dummyt d1,
   v500_event_set_canon esca3
  PLAN (esca
   WHERE esca.event_set_cd IN (chem_event_disp, endo_event_disp, heme_event_disp, immu_event_disp,
   urine_event_disp,
   toxi_event_disp)
    AND esca.parent_event_set_cd=lab_event_disp)
   JOIN (esca2
   WHERE esca.event_set_cd=esca2.parent_event_set_cd)
   JOIN (d1)
   JOIN (esca3
   WHERE esca2.event_set_cd=esca3.parent_event_set_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(parent_event->list,cnt)
   IF (child=0.0)
    IF (parentb=0.0)
     parent_event->list[cnt].parent_cd = parenta
    ELSE
     parent_event->list[cnt].parent_cd = parentb
    ENDIF
   ELSE
    parent_event->list[cnt].parent_cd = child
   ENDIF
   col 0, parent_event->list[cnt].parent_cd, row + 1
  FOOT REPORT
   parent_event->qual = cnt
  WITH nullreport, outerjoin = d1, dontcare = esca3
 ;end select
 FREE RECORD lab_event
 RECORD lab_event(
   1 qual = i4
   1 list[*]
     2 event_cd = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(parent_event->qual)),
   v500_event_set_code esc,
   v500_event_set_explode esce
  PLAN (d)
   JOIN (esc
   WHERE (esc.event_set_cd=parent_event->list[d.seq].parent_cd))
   JOIN (esce
   WHERE esce.event_set_cd=esc.event_set_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(lab_event->list,cnt), lab_event->list[cnt].event_cd = esce
   .event_cd
  FOOT REPORT
   lab_event->qual = cnt
  WITH nocounter
 ;end select
 SELECT INTO "lab_events"
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   FOR (x = 1 TO lab_event->qual)
     event = lab_event->list[x].event_cd, col 0, event,
     row + 1
   ENDFOR
  WITH noheader
 ;end select
 SET logical lab_logical "/cerner/d_prod/ccluserdir/lab_events.dat"
 FREE DEFINE rtl
 DEFINE rtl "lab_logical"
 SELECT INTO  $1
  pat_name = substring(1,28,p.name_full_formatted), admit = substring(1,8,format(e.reg_dt_tm,
    "mm/dd/yy;;d")), etype = substring(1,2,cva2.alias),
  pnbr = substring(1,20,epr.member_nbr), dob = substring(1,10,format(p.birth_dt_tm,"mm/dd/yyyy;;d")),
  catalog = substring(1,16,uar_get_code_display(ce.catalog_cd)),
  event = substring(1,15,uar_get_code_display(ce.event_cd)), event_dt = substring(1,10,format(ce
    .event_end_dt_tm,"mm/dd/yyyy hh:mm;;q")), event2 = substring(1,15,uar_get_code_display(ce2
    .event_cd)),
  result = substring(1,30,ce2.result_val), units = substring(1,10,uar_get_code_display(ce2
    .result_units_cd)), proc = decode(cva.seq,substring(1,5,cva.alias),fillstring(5," ")),
  acct = decode(ea.seq,substring(1,10,ea.alias),fillstring(10," ")), ssn = decode(pa.seq,substring(1,
    9,pa.alias),fillstring(9," "))
  FROM rtlt r,
   encounter e,
   encntr_plan_reltn epr,
   clinical_event ce,
   code_value_alias cva,
   clinical_event ce2,
   person p,
   code_value_alias cva2,
   person_alias pa,
   encntr_alias ea
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359)
    AND e.loc_facility_cd=facility_cd
    AND e.financial_class_cd IN (fin_class_54_cd, fin_class_l01_cd))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.health_plan_id=hne_id)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.encntr_id=e.encntr_id
    AND ce.event_start_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(curdate,curtime3)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd != inerror_cd
    AND ce.event_tag != "In Error")
   JOIN (r
   WHERE ce.event_cd=cnvtint(r.line)
    AND cnvtint(r.line) != 0)
   JOIN (cva
   WHERE cva.code_value=ce.catalog_cd
    AND cva.code_set=200)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.event_id)
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (cva2
   WHERE cva2.code_value=e.encntr_type_cd
    AND cva2.code_set=71
    AND cva2.contributor_source_cd=adt_cs)
   JOIN (pa
   WHERE outerjoin(p.person_id)=pa.person_id
    AND pa.person_alias_type_cd=outerjoin(ssn_cd)
    AND pa.active_ind=outerjoin(1))
   JOIN (ea
   WHERE outerjoin(ce.encntr_id)=ea.encntr_id
    AND ea.encntr_alias_type_cd=outerjoin(fin_var)
    AND ea.active_ind=outerjoin(1))
  ORDER BY pat_name, acct, event,
   event_dt DESC, cva.updt_dt_tm DESC
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
  HEAD event
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
END GO
