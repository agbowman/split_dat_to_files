CREATE PROGRAM cv_upd_order_event_tst
 DECLARE assertequaldouble(f8,f8,vc) = i2
 DECLARE assertequallong(i4,i4,vc) = i2
 DECLARE assertequalshort(i2,i2,vc) = i2
 DECLARE assertequalstring(vc,vc,vc) = i2
 DECLARE assertequaldate(d8,d8,vc) = i2
 DECLARE assertnotequaldouble(f8,f8,vc) = i2
 DECLARE assertnotequallong(i4,i4,vc) = i2
 DECLARE assertnotequalshort(i2,i2,vc) = i2
 DECLARE assertnotequalstring(vc,vc,vc) = i2
 DECLARE assertnotequaldate(d8,d8,vc) = i2
 DECLARE assertlessthandouble(f8,f8,vc) = i2
 DECLARE assertlessthanlong(i4,i4,vc) = i2
 DECLARE assertlessthanshort(i2,i2,vc) = i2
 DECLARE assertlessthanstring(vc,vc,vc) = i2
 DECLARE assertlessthandate(d8,d8,vc) = i2
 DECLARE assertlessthanorequaldouble(f8,f8,vc) = i2
 DECLARE assertlessthanorequallong(i4,i4,vc) = i2
 DECLARE assertlessthanorequalshort(i2,i2,vc) = i2
 DECLARE assertlessthanorequalstring(vc,vc,vc) = i2
 DECLARE assertlessthanorequaldate(d8,d8,vc) = i2
 IF (validate(unit_test_success)=0)
  DECLARE unit_test_success = i2 WITH persistscript, noconstant(1)
 ENDIF
 CALL assertnotequaldouble(reqinfo->updt_id,0,"You must be logged in to run this test")
 SET reqdata->loglevel = 4
 DECLARE theaccession = vc WITH constant( $1)
 DECLARE theprocstatusmeaning = vc WITH constant( $2)
 DECLARE statuscdtoset = f8 WITH constant(uar_get_code_by("MEANING",4000341,nullterm(
    theprocstatusmeaning)))
 CALL assertnotequaldouble(statuscdtoset,0,build2("Meaning ",theprocstatusmeaning,
   " not found in code set 4000341."))
 DECLARE thestatusdisplay = vc WITH constant(uar_get_code_display(statuscdtoset))
 DECLARE proc_reference_prefix = c8 WITH constant("CV_PROC:"), protect
 DECLARE contrib_sys_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 FREE RECORD therequest
 RECORD therequest(
   1 catalog_cd = f8
   1 order_id = f8
   1 accession_nbr = vc
   1 encntr_id = f8
   1 person_id = f8
   1 result_val = vc
   1 event_end_dt_tm = dq8
   1 event_start_dt_tm = dq8
   1 reference_nbr = vc
   1 event_cd = f8
   1 event_id = f8
   1 proc_status_cd = f8
 )
 DECLARE accessioncount = i4 WITH noconstant(0)
 DECLARE thepreviousclinicaleventid = f8 WITH noconstant(0)
 DECLARE thepreviousresultstatusmeaning = vc WITH noconstant("")
 DECLARE thepreviouseventtag = vc WITH noconstant("")
 SELECT INTO "nl:"
  FROM cv_proc cp,
   clinical_event ce
  PLAN (cp
   WHERE cp.accession=theaccession)
   JOIN (ce
   WHERE ce.accession_nbr=cp.accession
    AND ce.valid_until_dt_tm=cnvtdatetime("31-dec-2100"))
  DETAIL
   accessioncount += 1, therequest->catalog_cd = cp.catalog_cd, therequest->order_id = cp.order_id,
   therequest->accession_nbr = cp.accession, therequest->encntr_id = cp.encntr_id, therequest->
   person_id = cp.person_id,
   therequest->event_start_dt_tm = cnvtdatetime(cp.action_dt_tm), therequest->event_end_dt_tm =
   cnvtdatetime(cp.action_dt_tm), therequest->reference_nbr = concat(nullterm(proc_reference_prefix),
    cnvtstring(cp.cv_proc_id)),
   therequest->event_cd = ce.event_cd, therequest->event_id = cp.group_event_id, therequest->
   proc_status_cd = statuscdtoset,
   thepreviousclinicaleventid = ce.clinical_event_id, thepreviousresultstatusmeaning =
   uar_get_code_meaning(ce.result_status_cd), thepreviouseventtag = ce.event_tag
  WITH nocounter
 ;end select
 CALL assertnotequallong(accessioncount,0,build2("no procedure has accession ",theaccession,
   " and a valid clinical event"))
 CALL assertequallong(accessioncount,1,build2("multiple procedures have accession ",theaccession,
   " and a valid clinical event"))
 EXECUTE cv_upd_order_event  WITH replace("REQUEST",therequest), replace("REPLY",thereply)
 DECLARE thenewclinicaleventid = f8 WITH noconstant(0)
 DECLARE thenewresultstatusmeaning = vc WITH noconstant("")
 DECLARE theneweventtag = vc WITH noconstant("")
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.accession_nbr=theaccession
   AND ce.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
  DETAIL
   thenewclinicaleventid = ce.clinical_event_id, thenewresultstatusmeaning = uar_get_code_meaning(ce
    .result_status_cd), theneweventtag = ce.event_tag
  WITH nocounter
 ;end select
 IF ( NOT (thepreviousresultstatusmeaning IN ("CANCELLED", "INERROR")))
  CALL assertequalstring(theneweventtag,thestatusdisplay,
   "the event tag should match the status' display - 1")
 ENDIF
 IF (thepreviousresultstatusmeaning="CANCELLED")
  IF (theprocstatusmeaning != "CANCELLED")
   CALL assertequaldouble(thenewclinicaleventid,thepreviousclinicaleventid,
    "theNewClinicalEventId equals thePreviousClinicalEventId")
  ELSE
   CALL assertequalstring(theneweventtag,thestatusdisplay,
    "the event tag should match the status' display - 2")
  ENDIF
 ENDIF
 IF (thepreviousresultstatusmeaning="CANCELLED")
  IF (theprocstatusmeaning != "DISCONTINUED")
   CALL assertequaldouble(thenewclinicaleventid,thepreviousclinicaleventid,
    "theNewClinicalEventId equals thePreviousClinicalEventId")
  ELSE
   CALL assertequalstring(theneweventtag,thestatusdisplay,
    "the event tag should match the status' display - 2")
  ENDIF
 ENDIF
 IF (thepreviousresultstatusmeaning IN ("AUTH", "MODIFIED"))
  IF (theprocstatusmeaning IN ("CANCELLED", "DISCONTINUED"))
   CALL assertequalstring(thenewresultstatusmeaning,"INERROR","theNewResultStatusMeaning is INERROR")
  ENDIF
 ENDIF
 IF (thepreviousresultstatusmeaning IN ("AUTH", "MODIFIED"))
  IF ( NOT (theprocstatusmeaning IN ("CANCELLED", "DISCONTINUED")))
   CALL assertequalstring(thenewresultstatusmeaning,"MODIFIED",
    "theNewResultStatusMeaning is MODIFIED")
  ENDIF
 ENDIF
 IF ( NOT (thepreviousresultstatusmeaning IN ("AUTH", "MODIFIED", "CANCELLED", "INERROR")))
  IF (theprocstatusmeaning IN ("ORDERED", "SCHEDULED", "ARRIVED", "INPROCESS", "COMPLETED",
  "VERIFIED", "UNSIGNED"))
   CALL assertequalstring(thenewresultstatusmeaning,"IN PROGRESS",
    "theNewResultStatusMeaning is IN PROGRESS")
  ENDIF
 ENDIF
#exit_script
 SUBROUTINE assertequaldouble(val,expected,description)
   IF (val=expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertEqualDouble failed for ",description,". Expected ",expected,
      " but was ",
      val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertequallong(val,expected,description)
   IF (val=expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertEqualLong failed for ",description,". Expected ",expected," but was ",
      val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertequalshort(val,expected,description)
   IF (val=expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertEqualShort failed for ",description,". Expected ",expected,
      " but was ",
      val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertequaldate(val,expected,description)
   IF (val=expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertEqualDate failed for ",description,". Expected ",expected," but was ",
      val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertequalstring(val,expected,description)
   IF (val=expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertEqualString failed for ",description,". Expected '",expected,
      "' but was '",
      val,"'"))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertnotequaldouble(val,expected,description)
   IF (val != expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertNotEqualDouble failed for ",description,
      ". Expected the value to not be ",val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertnotequallong(val,expected,description)
   IF (val != expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertNotEqualLong failed for ",description,
      ". Expected the value to not be ",val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertnotequalshort(val,expected,description)
   IF (val != expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertNotEqualShort failed for ",description,
      ". Expected the value to not be ",val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertnotequaldate(val,expected,description)
   IF (val != expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertNotEqualDate failed for ",description,
      ". Expected the value to not be ",val))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertnotequalstring(val,expected,description)
   IF (val != expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertNotEqualString failed for ",description,
      ". Expected the value to not be '",val,"'"))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthandouble(val,expected,description)
   IF (val < expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanDouble failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanlong(val,expected,description)
   IF (val < expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanLong failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanshort(val,expected,description)
   IF (val < expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanShort failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthandate(val,expected,description)
   IF (val < expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanDate failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanstring(val,expected,description)
   IF (val < expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanString failed for ",description,". Expected '",val,
      "' to be less than '",
      expected,"'"))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanorequaldouble(val,expected,description)
   IF (val <= expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanOrEqualDouble failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanorequallong(val,expected,description)
   IF (val <= expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanOrEqualLong failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanorequalshort(val,expected,description)
   IF (val <= expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanOrEqualShort failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanorequaldate(val,expected,description)
   IF (val <= expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanOrEqualDate failed for ",description,". Expected ",val,
      " to be less than ",
      expected))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
 SUBROUTINE assertlessthanorequalstring(val,expected,description)
   IF (val <= expected)
    RETURN(true)
   ELSE
    CALL echo(build2("TEST FAILED (",curprog,")!!!"))
    CALL echo(build2("    assertLessThanOrEqualString failed for ",description,". Expected '",val,
      "' to be less than or equal '",
      expected,"'"))
    SET unit_test_success = false
    GO TO end_test
   ENDIF
 END ;Subroutine
#end_test
 CALL echo("calling ROLLBACK to restore all the borrowed records")
 ROLLBACK
 DECLARE errormessage = vc
 DECLARE errorcode = i2
 SET errorcode = error(errormessage,0)
 IF (errorcode != 0)
  CALL echo(build2("CCL Error: ",errormessage))
  SET unit_test_success = false
 ENDIF
 CALL echo("*********************************")
 CALL echo(build2("unit test ",curprog,
   IF (unit_test_success=true) " SUCCEEDED"
   ELSE " FAILED"
   ENDIF
   ))
 CALL echo("*********************************")
END GO
