CREATE PROGRAM bhs_rpt_early_warning_statstst:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email:" = ""
  WITH outdev, email
 DECLARE finnbr = f8 WITH constant(validatecodevalue("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE expired = f8 WITH constant(validatecodevalue("DISPLAYKEY",268,"EXPIRED")), protect
 DECLARE medical = f8 WITH protect, constant(validatecodevalue("MEANING",12033,"MEDICAL"))
 DECLARE codestatus = f8 WITH constant(validatecodevalue("DISPLAYKEY",106,"CODESTATUS")), protect
 DECLARE canceled = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"CANCELED")), protect
 DECLARE deleted = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE incomplete = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"INCOMPLETE")), protect
 DECLARE suspended = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"SUSPENDED")), protect
 DECLARE transfercanceled = f8 WITH constant(validatecodevalue("DISPLAYKEY",6004,"TRANSFERCANCELED")),
 protect
 DECLARE ecanceled = f8 WITH constant(validatecodevalue("DISPLAYKEY",261,"CANCELLED"))
 SET bdate = datetimefind(cnvtdatetime((curdate - 20),0),"W","B","B")
 FREE RECORD ews
 RECORD ews(
   1 maxprobcnt = i4
   1 maxproblength = i4
   1 maxdxcnt = i4
   1 maxdxlength = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 encntr_type = vc
     2 fin = vc
     2 name = vc
     2 age = vc
     2 gender = vc
     2 initalloc = f8
     2 initalscore = i4
     2 initaldttm = dq8
     2 highscore = i4
     2 highdttm = dq8
     2 deathcd = f8
     2 death = i4
     2 deathdttm = dq8
     2 encntrtype = vc
     2 problems = vc
     2 problist[*]
       3 problems = vc
     2 code_status_name = vc
     2 code_status_detail = vc
     2 dx = vc
     2 dxlist[*]
       3 dx = vc
     2 cunit[*]
       3 unit = f8
       3 unitdttm = dq8
 )
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET emailout = trim( $EMAIL,3)
 ELSE
  SET email_ind = 0
 ENDIF
 SELECT INTO "NL:"
  b.encntr_id, b.updt_dt_tm, deceaseddttm = format(cnvtdatetime(p.deceased_dt_tm),";;q"),
  uar_get_code_display(p.deceased_cd)
  FROM bhs_early_warning b,
   encntr_alias ea,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (b
   WHERE b.total_score >= 10
    AND b.insert_dt_tm >= cnvtdatetime(bdate))
   JOIN (e
   WHERE e.encntr_id=b.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr
    AND ea.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=b.encntr_id
    AND b.insert_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
  ORDER BY b.encntr_id, b.updt_dt_tm
  HEAD REPORT
   stat = alterlist(ews->qual,10), cnt = 0
  HEAD b.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(ews->qual,(cnt+ 9))
   ENDIF
   ews->qual[cnt].encntr_id = e.encntr_id, ews->qual[cnt].person_id = e.person_id, ews->qual[cnt].
   name = p.name_full_formatted,
   ews->qual[cnt].initalscore = b.total_score, ews->qual[cnt].initalloc = elh.loc_nurse_unit_cd, ews
   ->qual[cnt].initaldttm = b.insert_dt_tm,
   ews->qual[cnt].deathcd = p.deceased_cd, ews->qual[cnt].encntrtype = uar_get_code_display(e
    .encntr_type_cd), ews->qual[cnt].fin = ea.alias,
   ews->qual[cnt].age = cnvtage(p.birth_dt_tm,cnvtdatetime(ews->qual[cnt].initaldttm),0), ews->qual[
   cnt].gender = uar_get_code_display(p.sex_cd), ews->qual[cnt].encntrtype = uar_get_code_display(e
    .encntr_type_cd)
  DETAIL
   IF ((b.total_score > ews->qual[cnt].highscore))
    ews->qual[cnt].highscore = b.total_score, ews->qual[cnt].highdttm = b.insert_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(ews->qual,cnt)
  WITH format(date,";;q"), format, separator = " "
 ;end select
 SELECT
  FROM (dummyt d  WITH seq = size(ews->qual,5)),
   encntr_loc_hist elh
  PLAN (d)
   JOIN (elh
   WHERE (elh.encntr_id=ews->qual[d.seq].encntr_id)
    AND cnvtdatetime(ews->qual[d.seq].initaldttm) <= elh.beg_effective_dt_tm
    AND elh.loc_nurse_unit_cd IN (
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.code_set=220
     AND c.cdf_meaning="NURSEUNIT"
     AND c.display_key IN ("*ICU*", "CVC*", "CVIC*")
     AND  NOT (c.display_key IN ("*MOCK*")))))
  ORDER BY elh.encntr_id, elh.loc_nurse_unit_cd
  HEAD elh.encntr_id
   cnt1 = 0
  HEAD elh.loc_nurse_unit_cd
   cnt1 = (cnt1+ 1), stat = alterlist(ews->qual[d.seq].cunit,cnt1), ews->qual[d.seq].cunit[cnt1].unit
    = elh.loc_nurse_unit_cd,
   ews->qual[d.seq].cunit[cnt1].unitdttm = elh.beg_effective_dt_tm
  WITH format, separator = " "
 ;end select
 CALL echo("Locating Death rule fires")
 SELECT INTO "NL:"
  ed.encntr_id, e.updt_dt_tm
  FROM (dummyt d  WITH seq = size(ews->qual,5)),
   eks_module_audit_det ed,
   eks_module_audit e
  PLAN (d)
   JOIN (ed
   WHERE (ed.encntr_id=ews->qual[d.seq].encntr_id)
    AND ed.template_name="EKS_ENCOUNTER_DETAIL_L"
    AND ed.updt_dt_tm >= cnvtdatetime(ews->qual[d.seq].initaldttm))
   JOIN (e
   WHERE e.rec_id=ed.module_audit_id
    AND e.module_name IN ("BHS_ASY_DEATH_NOTICE2")
    AND ((e.updt_dt_tm+ 0) >= cnvtdatetime(ews->qual[d.seq].initaldttm)))
  ORDER BY ed.encntr_id, e.updt_dt_tm
  HEAD ed.encntr_id
   ews->qual[d.seq].deathdttm = cnvtdatetime(datetimeadd(e.updt_dt_tm,- (1)))
  WITH nocounter
 ;end select
 CALL echo(curqual)
 CALL echo("Check to see if the patient has expired encntr")
 SELECT INTO "NL:"
  FROM person p,
   encounter e,
   (dummyt d  WITH seq = size(ews->qual,5))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=ews->qual[d.seq].person_id))
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1
    AND  NOT (e.encntr_status_cd IN (ecanceled)))
  DETAIL
   IF (cnvtupper(trim(uar_get_code_display(e.encntr_type_cd),3)) IN ("*EXPIRED*"))
    ews->qual[d.seq].death = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  encntr_id = ews->qual[d.seq].encntr_id, p.person_id, p.problem_id
  FROM (dummyt d  WITH seq = size(ews->qual,5)),
   problem p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=ews->qual[d.seq].person_id)
    AND p.active_ind=1
    AND cnvtdatetime(ews->qual[d.seq].initaldttm) <= p.end_effective_dt_tm)
  ORDER BY encntr_id, p.problem_id
  HEAD encntr_id
   cnt2 = 0, pcnt = 0
  HEAD p.problem_id
   cnt2 = (cnt2+ 1)
   IF (cnt2=1)
    ews->qual[d.seq].problems =
    IF (textlen(trim(p.annotated_display,3)) > 0) trim(p.annotated_display,3)
    ELSE trim(p.problem_ftdesc,3)
    ENDIF
    , ews->qual[d.seq].problems = concat(trim(p.annotated_display,3),", ",
     IF (textlen(trim(p.annotated_display,3)) > 0) trim(p.annotated_display,3)
     ELSE trim(p.problem_ftdesc,3)
     ENDIF
     )
   ENDIF
   pcnt = (pcnt+ 1), stat = alterlist(ews->qual[d.seq].problist,pcnt), ews->qual[d.seq].problist[pcnt
   ].problems =
   IF (textlen(trim(p.annotated_display,3)) > 0) trim(p.annotated_display,3)
   ELSE trim(p.problem_ftdesc,3)
   ENDIF
   IF ((pcnt > ews->maxprobcnt))
    ews->maxprobcnt = pcnt
   ENDIF
   IF ((textlen(trim(ews->qual[d.seq].problist[pcnt].problems,3)) > ews->maxproblength))
    ews->maxproblength = textlen(trim(ews->qual[d.seq].problist[pcnt].problems,3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  encntr_id = ews->qual[d.seq].encntr_id, dx.person_id, dx.diagnosis_id
  FROM (dummyt d  WITH seq = size(ews->qual,5)),
   diagnosis dx
  PLAN (d)
   JOIN (dx
   WHERE (dx.encntr_id=ews->qual[d.seq].encntr_id)
    AND dx.active_ind=1
    AND cnvtdatetime(ews->qual[d.seq].initaldttm) <= dx.end_effective_dt_tm)
  ORDER BY encntr_id, dx.person_id, dx.diagnosis_id
  HEAD d.seq
   cnt2 = 0
  HEAD dx.person_id
   stat = 0, dcnt = 0
  HEAD dx.diagnosis_id
   cnt2 = (cnt2+ 1)
   IF (cnt2=1)
    ews->qual[d.seq].dx = trim(dx.diagnosis_display,3)
   ELSE
    ews->qual[d.seq].dx = concat(trim(dx.diagnosis_display,3),", ",ews->qual[d.seq].dx)
   ENDIF
   dcnt = (dcnt+ 1), stat = alterlist(ews->qual[d.seq].dxlist,dcnt), ews->qual[d.seq].dxlist[dcnt].dx
    = trim(dx.diagnosis_display,3)
   IF ((dcnt > ews->maxdxcnt))
    ews->maxdxcnt = dcnt
   ENDIF
   IF ((textlen(trim(ews->qual[d.seq].dxlist[dcnt].dx,3)) > ews->maxdxlength))
    ews->maxdxlength = textlen(trim(ews->qual[d.seq].dxlist[dcnt].dx,3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   orders o,
   order_detail od,
   order_entry_fields oef,
   (dummyt d  WITH seq = size(ews->qual,5))
  PLAN (d)
   JOIN (oc
   WHERE oc.activity_type_cd=codestatus)
   JOIN (o
   WHERE (o.encntr_id=ews->qual[d.seq].encntr_id)
    AND ((o.catalog_cd+ 0)=oc.catalog_cd)
    AND  NOT (((o.order_status_cd+ 0) IN (canceled, deleted, incomplete, suspended, transfercanceled)
   )))
   JOIN (od
   WHERE od.order_id=outerjoin(o.order_id)
    AND od.oe_field_meaning=outerjoin("OTHER"))
   JOIN (oef
   WHERE oef.oe_field_id=outerjoin(od.oe_field_id))
  ORDER BY o.encntr_id, o.order_id, od.detail_sequence
  HEAD o.encntr_id
   cnt4 = 0
  HEAD o.order_id
   cnt4 = (cnt4+ 1)
   IF (cnt4=1)
    ews->qual[d.seq].code_status_name = trim(o.order_mnemonic)
   ELSE
    ews->qual[d.seq].code_status_name = concat(trim(o.order_mnemonic),", ",ews->qual[d.seq].
     code_status_name)
   ENDIF
  DETAIL
   ews->qual[d.seq].code_status_detail = concat(trim(oef.description),": ",trim(od
     .oe_field_display_value),", ",ews->qual[d.seq].code_status_detail)
  WITH nocounter
 ;end select
 DECLARE tline = vc WITH noconstant(" ")
 IF (email_ind=0)
  SET var_output =  $OUTDEV
 ELSE
  SET var_output = "jrwtestest.xls"
 ENDIF
 DECLARE diagnosis = vc WITH noconstant(" ")
 DECLARE problem = vc WITH noconstant(" ")
 SELECT INTO value(var_output)
  person_id = ews->qual[d.seq].person_id, encntr_type = substring(1,15,ews->qual[d.seq].encntrtype),
  fin = substring(1,11,ews->qual[d.seq].fin),
  inital_nunit = substring(1,20,uar_get_code_display(ews->qual[d.seq].initalloc)), gender = substring
  (1,10,ews->qual[d.seq].gender), age = substring(1,3,ews->qual[d.seq].age),
  initalscore = ews->qual[d.seq].initalscore, initaldttm = substring(1,20,format(cnvtdatetime(ews->
     qual[d.seq].initaldttm),";;q")), highscore = ews->qual[d.seq].highscore,
  highdttm = substring(1,20,format(cnvtdatetime(ews->qual[d.seq].highdttm),";;q")), criticalunit =
  substring(1,20,uar_get_code_display(ews->qual[d.seq].cunit[d1.seq].unit)), criticalunitdttm =
  format(cnvtdatetime(ews->qual[d.seq].cunit[d1.seq].unitdttm),";;q"),
  this_encntr_status =
  IF (cnvtupper(ews->qual[d.seq].encntrtype) IN ("*EXPIRED*")) "EXPIRED"
  ELSE " "
  ENDIF
  , patientdeceased =
  IF ((((ews->qual[d.seq].death=1)) OR (((cnvtupper(trim(uar_get_code_display(ews->qual[d.seq].
     deathcd),3)) IN ("*EXPIRED*")) OR (cnvtdatetime(ews->qual[d.seq].deathdttm) > 0)) )) ) "Yes"
  ELSE " "
  ENDIF
  , deceasedtransactiondttm = substring(1,20,format(cnvtdatetime(ews->qual[d.seq].deathdttm),";;q")),
  codestatusname = substring(1,100,ews->qual[d.seq].code_status_name), codestatusdetail = substring(1,
   100,ews->qual[d.seq].code_status_detail)
  FROM (dummyt d  WITH seq = size(ews->qual,5)),
   (dummyt d1  WITH seq = 1),
   dummyt d2
  PLAN (d
   WHERE maxrec(d1,size(ews->qual[d.seq].cunit,5)))
   JOIN (d2)
   JOIN (d1)
  ORDER BY inital_nunit DESC, initaldttm DESC, person_id,
   fin
  HEAD REPORT
   IF (email_ind=0)
    x = 0, col x, "person_id",
    x = (x+ 15), col x, "encntr_type",
    x = (x+ 15), col x, "fin",
    x = (x+ 15), col x, "inital_NUnit",
    x = (x+ 15), col x, "gender",
    x = (x+ 30), col x, "age",
    x = (x+ 15), col x, "initalScore",
    x = (x+ 15), col x, "initalDttm",
    x = (x+ 25), col x, "highScore",
    x = (x+ 15), col x, "highDtTm",
    x = (x+ 25), col x, "CriticalUnit",
    x = (x+ 25), col x, "CriticalUnitDtTm",
    x = (x+ 25), col x, "This_encntr_status",
    x = (x+ 25), col x, "PatientDeceased",
    x = (x+ 25), col x, "DeceasedTransactionDtTm",
    x = (x+ 25), col x, "codeStatusname",
    x = (x+ 40), col x, "codeStatusDetail",
    x = (x+ 150)
    FOR (y = 1 TO ews->maxdxcnt)
      col x, "diagnosis", x = (x+ ews->maxdxlength)
    ENDFOR
    FOR (y = 1 TO ews->maxprobcnt)
      col x, "Problem", x = (x+ ews->maxproblength)
    ENDFOR
    row + 1
   ELSE
    tline = concat("person_id",char(9),"encntr_type",char(9),"fin",
     char(9),"inital_NUnit",char(9),"gender",char(9),
     "age",char(9),"initalScore",char(9),"initalDttm",
     char(9),"highScore",char(9),"highDtTm",char(9),
     "CriticalUnit",char(9),"CriticalUnitDtTm",char(9),"This_encntr_status",
     char(9),"PatientDeceased",char(9),"DeceasedTransactionDtTm",char(9),
     "codeStatusname",char(9),"codeStatusDetail",char(9))
    FOR (y = 1 TO ews->maxdxcnt)
      tline = concat(tline,"diagnosis",char(9))
    ENDFOR
    FOR (y = 1 TO ews->maxprobcnt)
      tline = concat(tline,"Problem",char(9))
    ENDFOR
    tline = trim(tline,3), col 0, tline,
    row + 1
   ENDIF
  DETAIL
   CALL echo(build("*************",ews->qual[d.seq].deathcd)),
   CALL echo(build("***",uar_get_code_display(ews->qual[d.seq].deathcd))),
   CALL echo(build("DEATH:",ews->qual[d.seq].death)),
   CALL echo(cnvtupper(trim(uar_get_code_display(ews->qual[d.seq].deathcd),3))),
   CALL echo(format(cnvtdatetime(ews->qual[d.seq].deathdttm),";;q"))
   IF (email_ind=0)
    x = 0, col x, person_id,
    x = (x+ 15), col x, encntr_type,
    x = (x+ 15), col x, fin,
    x = (x+ 15), col x, inital_nunit,
    x = (x+ 15), col x, gender,
    x = (x+ 30), col x, age,
    x = (x+ 15), col x, initalscore,
    x = (x+ 15), col x, initaldttm,
    x = (x+ 25), col x, highscore,
    x = (x+ 15), col x, highdttm,
    x = (x+ 25), col x, criticalunit,
    x = (x+ 25), col x, criticalunitdttm,
    x = (x+ 25), col x, this_encntr_status,
    x = (x+ 25), col x, patientdeceased,
    x = (x+ 25), col x, deceasedtransactiondttm,
    x = (x+ 25), col x, codestatusname,
    x = (x+ 40), col x, codestatusdetail,
    x = (x+ 150)
    FOR (y = 1 TO ews->maxdxcnt)
      diagnosis = " "
      IF (y <= size(ews->qual[d.seq].dxlist,5))
       diagnosis = trim(ews->qual[d.seq].dxlist[y].dx,3)
      ENDIF
      col x, diagnosis, x = (x+ ews->maxdxlength)
    ENDFOR
    FOR (y = 1 TO ews->maxprobcnt)
      problem = " "
      IF (y <= size(ews->qual[d.seq].problist,5))
       problem = trim(ews->qual[d.seq].problist[y].problems,3)
      ENDIF
      col x, problem, x = (x+ ews->maxproblength)
    ENDFOR
    col 0, tline, row + 1
   ELSE
    tline = build(person_id,char(9),encntr_type,char(9),fin,
     char(9),inital_nunit,char(9),gender,char(9),
     age,char(9),initalscore,char(9),initaldttm,
     char(9),highscore,char(9),highdttm,char(9),
     criticalunit,char(9),criticalunitdttm,char(9),this_encntr_status,
     char(9),patientdeceased,char(9),deceasedtransactiondttm,char(9),
     codestatusname,char(9),codestatusdetail,char(9))
    FOR (y = 1 TO ews->maxdxcnt)
      IF (y <= size(ews->qual[d.seq].dxlist,5))
       tline = concat(tline,trim(ews->qual[d.seq].dxlist[y].dx,3),char(9))
      ELSE
       tline = concat(tline,char(9))
      ENDIF
    ENDFOR
    FOR (y = 1 TO ews->maxprobcnt)
      IF (y <= size(ews->qual[d.seq].problist,5))
       tline = concat(tline,trim(ews->qual[d.seq].problist[y].problems,3),char(9))
      ELSE
       tline = concat(tline,char(9))
      ENDIF
    ENDFOR
    tline = trim(tline,3), col 0, tline,
    row + 1
   ENDIF
  WITH format, outerjoin = d2, maxcol = 20000,
   formfeed = none
 ;end select
 IF (email_ind=0)
  SELECT INTO "nl:"
   DETAIL
    row + 0
   WITH skipreport = value(1)
  ;end select
 ELSE
  IF (findfile(trim(var_output))=1)
   EXECUTE bhs_ma_email_file
   CALL emailfile(var_output,var_output,emailout,"Discern Report:EWS",0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Email sent to:", msg2 = trim(emailout), col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   SET stat = remove(trim(var_output))
   IF (stat=0)
    CALL echo("File could not be removed")
   ELSE
    CALL echo("File was removed")
   ENDIF
  ELSE
   CALL echo("File could not be removed. File does not exist or permission denied")
  ENDIF
 ENDIF
 SUBROUTINE validatecodevalue(type,codeset,val)
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
END GO
