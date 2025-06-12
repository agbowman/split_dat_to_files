CREATE PROGRAM bhs_braden_score_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Start Date" = "SYSDATE",
  "Enter End Date" = "SYSDATE"
  WITH outdev, st_dt, en_dt
 IF (validate(request->batch_selection))
  SET strt_date = datetimeadd(cnvtdatetime(curdate,065959),- (1))
  SET end_date = cnvtdatetime(curdate,070000)
 ELSE
  SET strt_date = cnvtdatetime(cnvtdatetime2( $ST_DT))
  SET end_date = cnvtdatetime(cnvtdatetime2( $EN_DT))
  IF (datetimediff(cnvtdatetime(cnvtdatetime2( $EN_DT)),cnvtdatetime(cnvtdatetime2( $ST_DT))) > 31)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 15
   ;end select
   GO TO exit_prg
  ELSEIF (datetimediff(cnvtdatetime(cnvtdatetime2( $EN_DT)),cnvtdatetime(cnvtdatetime2( $ST_DT))) < 0
  )
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08
   ;end select
   GO TO exit_prg
  ENDIF
 ENDIF
 SET daystay_cd = uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")
 SET inpat_cd = uar_get_code_by("DISPLAYKEY",71,"INPATIENT")
 SET mrn_cd = uar_get_code_by("DISPLAYKEY",319,"MRN")
 SET fnbr_cd = uar_get_code_by("DISPLAYKEY",319,"FINNBR")
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"BRADENQASSESSMENTPEDIATRICFORM")
 SET dta3 = uar_get_code_by("DISPLAYKEY",72,"BRADENSCORE")
 SET dta4 = uar_get_code_by("DISPLAYKEY",72,"BRADENQSCOREPEDIATRICS")
 SET org1 = uar_get_code_by("DESCRIPTION",220,"BAYSTATE MEDICAL CENTER")
 SET org2 = uar_get_code_by("DISPLAYKEY",220,"BMCINPTPSYCH")
 SET count = 0
 RECORD temp_rec(
   1 bradens[*]
     2 enct = f8
     2 resval = f8
     2 eventcd = vc
     2 person_id = f8
     2 event_code = f8
     2 result_status_disp = vc
     2 event_id = f8
     2 result = i2
     2 facil = vc
     2 nurse_unit = vc
     2 pt_name = vc
     2 dob = vc
     2 dob_dq8 = dq8
     2 age = vc
     2 acct = vc
     2 clinsig_updt_dt_tm = dq8
     2 event_end_dt_tm_vc = vc
     2 pt_name = vc
     2 admit_dt = vc
   1 rescnt = i4
   1 brad = i4
   1 brad_ped = i4
   1 pat_cnta = i4
   1 pat_cntb = i4
 )
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 DECLARE st_dt2 = vc WITH public
 DECLARE y_val = i4 WITH public
 DECLARE x_val = i4 WITH public
 DECLARE maxsecs = i4 WITH public
 IF (validate(isodbc,0)=1)
  SET maxsecs = 200
 ENDIF
 SELECT INTO "nl:"
  ce_event_disp = uar_get_code_display(ce.event_cd), ce_result_status_disp = uar_get_code_display(ce
   .result_status_cd), elh_loc_facility_disp = uar_get_code_display(elh.loc_facility_cd),
  ed_loc_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd), p.name_full_formatted, ce
  .clinsig_updt_dt_tm
  FROM clinical_event ce,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(strt_date) AND cnvtdatetime(end_date)
    AND ((ce.event_cd+ 0) IN (dta3, dta4))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
   JOIN (e
   WHERE ce.encntr_id=e.encntr_id
    AND ((e.active_ind+ 0)=1))
   JOIN (elh
   WHERE elh.encntr_id=ce.encntr_id
    AND ((elh.beg_effective_dt_tm+ 0) <= ce.clinsig_updt_dt_tm)
    AND elh.end_effective_dt_tm >= ce.clinsig_updt_dt_tm
    AND elh.loc_facility_cd IN (org1, org2))
   JOIN (p
   WHERE ce.person_id=p.person_id)
  ORDER BY ed_loc_nurse_unit, p.name_full_formatted, ce.clinsig_updt_dt_tm DESC
  HEAD p.name_full_formatted
   age_date = cnvtagedatetime(75,0,0,0)
   IF (cnvtreal(trim(ce.result_val,3)) <= 18
    AND ((p.birth_dt_tm <= age_date) OR (cnvtreal(trim(ce.result_val,3)) <= 16
    AND p.birth_dt_tm > age_date)) )
    temp_rec->rescnt = (temp_rec->rescnt+ 1)
    IF (ce.event_cd=dta3)
     temp_rec->brad = (temp_rec->brad+ 1)
    ELSEIF (ce.event_cd=dta4)
     temp_rec->brad_ped = (temp_rec->brad_ped+ 1)
    ENDIF
    stat = alterlist(temp_rec->bradens,temp_rec->rescnt), temp_rec->bradens[temp_rec->rescnt].enct =
    ce.encntr_id, temp_rec->bradens[temp_rec->rescnt].eventcd = substring(0,20,ce_event_disp),
    temp_rec->bradens[temp_rec->rescnt].person_id = ce.person_id, temp_rec->bradens[temp_rec->rescnt]
    .event_code = ce.event_cd, temp_rec->bradens[temp_rec->rescnt].result_status_disp =
    ce_result_status_disp,
    temp_rec->bradens[temp_rec->rescnt].event_id = ce.event_id, temp_rec->bradens[temp_rec->rescnt].
    result = cnvtint(ce.result_val), temp_rec->bradens[temp_rec->rescnt].clinsig_updt_dt_tm = ce
    .clinsig_updt_dt_tm,
    temp_rec->bradens[temp_rec->rescnt].event_end_dt_tm_vc = format(ce.clinsig_updt_dt_tm,
     "MM/DD/YY HH:MM;;d"), temp_rec->bradens[temp_rec->rescnt].nurse_unit = ed_loc_nurse_unit,
    temp_rec->bradens[temp_rec->rescnt].facil = elh_loc_facility_disp,
    temp_rec->bradens[temp_rec->rescnt].dob_dq8 = p.birth_dt_tm, temp_rec->bradens[temp_rec->rescnt].
    dob = format(p.birth_dt_tm,";;d"), temp_rec->bradens[temp_rec->rescnt].pt_name = trim(p
     .name_full_formatted),
    temp_rec->bradens[temp_rec->rescnt].age = cnvtage(p.birth_dt_tm), temp_rec->bradens[temp_rec->
    rescnt].admit_dt = format(e.reg_dt_tm,"MM/DD/YY;;d")
   ENDIF
  WITH nocounter, separator = " ", format,
   time = value(maxsecs)
 ;end select
 SELECT INTO  $OUTDEV
  nu = substring(1,30,temp_rec->bradens[d.seq].nurse_unit), temp_rec->bradens[d.seq].pt_name, mrn =
  cnvtalias(ea1.alias,ea1.alias_pool_cd),
  fin = cnvtalias(ea.alias,ea.alias_pool_cd), clin_sig_dt_time = temp_rec->bradens[d.seq].
  clinsig_updt_dt_tm
  FROM (dummyt d  WITH seq = temp_rec->rescnt),
   encntr_alias ea,
   encntr_alias ea1
  PLAN (d)
   JOIN (ea
   WHERE (temp_rec->bradens[d.seq].enct=ea.encntr_id)
    AND ((ea.encntr_alias_type_cd+ 0)=fnbr_cd))
   JOIN (ea1
   WHERE (temp_rec->bradens[d.seq].enct=ea1.encntr_id)
    AND ((ea1.encntr_alias_type_cd+ 0)=mrn_cd))
  ORDER BY nu, temp_rec->bradens[d.seq].result DESC
  HEAD REPORT
   y_pos = 18, st_dt2 = build("Audit From...",format(strt_date,"@SHORTDATETIME"),
    "           To...    ",format(end_date,"@SHORTDATETIME")), printpsheader = 0,
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/5}{CPI/14}",
   CALL print(calcpos(300,(y_pos+ 0))), "Braden Score less than or equal to 16 for Wound Care Nurse",
   row + 1,
   row + 1,
   CALL print(calcpos(52,(y_pos+ 36))), "Report Date:",
   row + 1,
   CALL print(calcpos(150,(y_pos+ 36))), curdate,
   row + 1,
   CALL print(calcpos(648,(y_pos+ 36))), "Page:",
   row + 1,
   CALL print(calcpos(666,(y_pos+ 36))), curpage,
   row + 1,
   CALL print(calcpos(52,(y_pos+ 45))), "Report Time:",
   row + 1,
   CALL print(calcpos(150,(y_pos+ 45))), curtime,
   row + 1,
   CALL print(calcpos(250,(y_pos+ 27))), st_dt2,
   row + 1,
   CALL print(calcpos(20,(y_pos+ 63))), "Nurse Unit",
   row + 1,
   CALL print(calcpos(70,(y_pos+ 63))), "Patient",
   row + 1,
   CALL print(calcpos(210,(y_pos+ 63))), "AcctNum",
   row + 1,
   CALL print(calcpos(270,(y_pos+ 63))), "MRN",
   row + 1,
   CALL print(calcpos(322,(y_pos+ 63))), "Age",
   row + 1,
   CALL print(calcpos(380,(y_pos+ 63))), "DOB",
   row + 1,
   CALL print(calcpos(438,(y_pos+ 63))), "Score Type",
   row + 1,
   CALL print(calcpos(545,(y_pos+ 63))), "Score",
   row + 1,
   CALL print(calcpos(585,(y_pos+ 63))), "Score Date",
   row + 1,
   CALL print(calcpos(670,(y_pos+ 63))), "Admit Date",
   row + 1, y_val = ((792 - y_pos) - 90), "{PS/newpath 2 setlinewidth   22 ",
   y_val, " moveto  745 ", y_val,
   " lineto stroke 36 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 96)
  DETAIL
   IF (((y_pos+ 120) >= 612))
    y_pos = 0, row + 1, "{F/5}{CPI/10}",
    CALL print(calcpos(668,(y_pos+ (612 - 100)))), "Page:",
    CALL print(calcpos(680,(y_pos+ (612 - 100)))),
    curpage, BREAK
   ENDIF
   row + 1, "{F/3}{CPI/14}", row + 1,
   CALL print(calcpos(20,(y_pos+ 0))), temp_rec->bradens[d.seq].nurse_unit, row + 1,
   CALL print(calcpos(70,(y_pos+ 0))), temp_rec->bradens[d.seq].pt_name, row + 1,
   CALL print(calcpos(210,(y_pos+ 0))), fin, row + 1,
   CALL print(calcpos(270,(y_pos+ 0))), mrn, row + 1,
   CALL print(calcpos(315,(y_pos+ 0))), temp_rec->bradens[d.seq].age, row + 1,
   CALL print(calcpos(380,(y_pos+ 0))), temp_rec->bradens[d.seq].dob, row + 1,
   CALL print(calcpos(438,(y_pos+ 0))), temp_rec->bradens[d.seq].eventcd, row + 1,
   CALL print(calcpos(510,(y_pos+ 0))), temp_rec->bradens[d.seq].result, row + 1,
   CALL print(calcpos(585,(y_pos+ 0))), temp_rec->bradens[d.seq].event_end_dt_tm_vc, row + 1,
   CALL print(calcpos(670,(y_pos+ 0))), temp_rec->bradens[d.seq].admit_dt, y_pos = (y_pos+ 9)
  FOOT PAGE
   row + 1,
   CALL print(calcpos(668,(y_pos+ (612 - 100)))), "Page:",
   row + 1,
   CALL print(calcpos(680,(y_pos+ (612 - 100)))), curpage
  FOOT  nu
   y_pos = (y_pos+ 9)
  FOOT REPORT
   row + 1, y_pos = 0, row + 1,
   y_val = ((792 - y_pos) - 550), "{PS/newpath 2 setlinewidth   36 ", y_val,
   " moveto  745 ", y_val, " lineto stroke 36 ",
   y_val, " moveto/}", row + 1,
   row + 1, "{F/5}{CPI/10}", row + 1,
   CALL print(calcpos(52,(y_pos+ (612 - 50)))), "Total Patient with Qualifying Score :", row + 1,
   CALL print(calcpos(300,(y_pos+ (612 - 50)))), temp_rec->brad, row + 1,
   CALL print(calcpos(52,(y_pos+ (612 - 30)))), "Total Patient with Qualifying Pediatric Score:", row
    + 1,
   CALL print(calcpos(300,(y_pos+ (612 - 30)))), temp_rec->brad_ped, row + 1,
   CALL print(calcpos(668,(y_pos+ (612 - 100)))), "Page:", row + 1,
   CALL print(calcpos(680,(y_pos+ (612 - 100)))), curpage
  WITH maxcol = 400, maxrow = 1000, landscape,
   dio = 08, noheading, format = variable,
   time = value(maxsecs), nullreport
 ;end select
#exit_prg
END GO
