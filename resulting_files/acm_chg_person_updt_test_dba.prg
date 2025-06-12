CREATE PROGRAM acm_chg_person_updt_test:dba
 IF ((validate(run_acm_updt,- (999))=- (999)))
  DECLARE run_acm_updt = i2 WITH noconstant(0)
  DECLARE s_executepersonupdates(_null) = i2
  DECLARE s_getrequestlistsize(_null) = i4
  DECLARE s_getprimarylistsize(_null) = i4
  DECLARE s_clearall(_null) = i2
  DECLARE s_clearprimarykeys(_null) = i2
  DECLARE s_requestaddtolist(dpersonid=f8) = i2
  DECLARE s_requestaddtoprimarykeyslist(dprimarykeyid=f8) = i2
  DECLARE s_lacm_chg_person_updt_status = i2 WITH noconstant(false)
  DECLARE s_getdeclaringprog(_null) = vc
  DECLARE s_curprog = vc WITH protected, constant(curprog)
  RECORD acm_chg_person_updt_request(
    1 call_echo_ind = i2
    1 call_echo_ind = i2
    1 requestlistsize = i4
    1 requestcurrentsize = i4
    1 person_qual[*]
      2 person_id = f8
  )
  RECORD acm_chg_person_updt_reply(
    1 person_qual[*]
      2 person_id = f8
      2 status = i2
      2 status_operation = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD primarykeys(
    1 primarykeylistsize = i4
    1 primarykeycurrentsize = i4
    1 ids_qual[*]
      2 primary_key_id = f8
  )
  SUBROUTINE s_requestaddtoprimarykeyslist(dprimarykeyid)
    RETURN(true)
  END ;Subroutine
  SUBROUTINE s_requestaddtolist(dpersonid)
    RETURN(true)
  END ;Subroutine
  SUBROUTINE s_executepersonupdates(_null)
    RETURN(true)
  END ;Subroutine
  SUBROUTINE s_getrequestlistsize(_null)
    RETURN(acm_chg_person_updt_request->requestlistsize)
  END ;Subroutine
  SUBROUTINE s_getprimarylistsize(_null)
    RETURN(primarykeys->primarykeylistsize)
  END ;Subroutine
  SUBROUTINE s_clearall(_null)
    FREE RECORD primarykeys
    FREE RECORD acm_chg_person_updt_request
    FREE RECORD acm_chg_person_updt_reply
    SET s_lacm_chg_person_updt_status = 0
    RETURN(true)
  END ;Subroutine
  SUBROUTINE s_getdeclaringprog(_null)
    RETURN(s_curprog)
  END ;Subroutine
  SUBROUTINE s_clearprimarykeys(_null)
    SET stat = alterlist(primarykeys->ids_qual,0)
    SET primarykeys->primarykeylistsize = 0
    SET primarykeys->primarykeycurrentsize = 0
    RETURN(true)
  END ;Subroutine
 ENDIF
 CALL echo(build("Current Parent Program = ",s_getdeclaringprog(0)))
 CALL s_requestaddtolist(99999999.00)
 CALL s_requestaddtolist(992710.00)
 CALL s_executepersonupdates(0)
 CALL echorecord(acm_chg_person_updt_reply)
END GO
