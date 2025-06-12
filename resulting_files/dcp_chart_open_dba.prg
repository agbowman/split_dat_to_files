CREATE PROGRAM dcp_chart_open:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE makecoherent(null) = null
 DECLARE markasincoherent(null) = null
 DECLARE callhealthexpectationserver(null) = i4
 DECLARE callrecommendationserver(null) = i4
 DECLARE error_list_size = i4 WITH protect, noconstant(1)
 DECLARE requestid = i4
 DECLARE hrequest = i4
 DECLARE hreply = i4
 DECLARE hmsg = i4
 DECLARE hstatus = i4
 DECLARE iret = i4
 DECLARE allow_recommendation_server_ind = i2
 DECLARE include_satisfied_pending_ind = i2 WITH noconstant(0)
 DECLARE async_res_ind = i2 WITH noconstant(0)
 FREE RECORD personlist
 RECORD personlist(
   1 qual[*]
     2 person_id = f8
     2 ppr_cd = f8
   1 prsnl_id = f8
 )
 FREE RECORD coherencylist
 RECORD coherencylist(
   1 person[*]
     2 person_id = f8
     2 coherent = i2
     2 long_blob_id = f8
     2 locked = i2
     2 coherent_as_of = dq8
     2 coherent_until = dq8
     2 ppr_cd = f8
   1 prsnl_id = f8
 )
 DECLARE stamplastbuilddate(null) = null
 IF (validate(reply) != 0
  AND validate(reply->status_data) != 0
  AND validate(reply->status_data.status) != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (lockpatient(person_id=f8) =i4)
   DECLARE was_locked = i4 WITH protect, noconstant(0)
   CALL echo(build("attempting to lock person = ",person_id))
   DECLARE locked_state = i4 WITH protect, noconstant
   SET locked_state = islocked(person_id)
   IF (locked_state=1)
    CALL echo(build("person already locked. waiting 2 seconds before retry.  person = ",person_id))
    CALL pause(2)
    SET locked_state = islocked(person_id)
    IF (locked_state=1)
     CALL echo(build("person already locked. waiting 2 seconds before retry.  person = ",person_id))
     CALL pause(2)
     SET locked_state = islocked(person_id)
     IF (locked_state=1)
      CALL echo(build("person already locked. waiting 2 seconds before retry.  person = ",person_id))
      CALL pause(2)
      SET locked_state = islocked(person_id)
      IF (locked_state=1)
       CALL echo(build("person already locked. waiting 2 seconds before retry.  person = ",person_id)
        )
       CALL pause(2)
       SET locked_state = islocked(person_id)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (locked_state=1)
    CALL echo(build("unable to obtain lock after 5 attempts (10 seconds).  person = ",person_id))
    DECLARE nulldate = dq8 WITH protect, constant(null)
    CALL releaselock(person_id,nulldate,nulldate)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "obtain lock timeout"
    SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
    SET was_locked = 0
   ELSEIF (locked_state=99)
    CALL echo(build("lock available for person = ",person_id))
    DECLARE rec_id = f8
    SELECT INTO "nl:"
     next_seq_nbr = seq(pco_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      rec_id = cnvtreal(next_seq_nbr)
     WITH nocounter
    ;end select
    IF (rec_id=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "create rec_id failed"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Dual"
     SET was_locked = 0
     RETURN(was_locked)
    ENDIF
    INSERT  FROM hm_recommendation hr
     SET hr.recommendation_id = rec_id, hr.status_flag = 1, hr.person_id = person_id,
      hr.expect_id = 0.0, hr.updt_cnt = 0, hr.updt_dt_tm = cnvtdatetime(sysdate),
      hr.updt_id = reqinfo->updt_id, hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Insert person zero row failed"
     SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
     SET was_locked = 0
    ELSE
     COMMIT
     CALL echo(build("new zero row inserted for for person = ",person_id))
     SET was_locked = 1
    ENDIF
   ELSE
    CALL echo(build("lock available for person = ",person_id))
    UPDATE  FROM hm_recommendation hr
     SET hr.status_flag = 1, hr.updt_dt_tm = cnvtdatetime(sysdate), hr.updt_id = reqinfo->updt_id,
      hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr
      .updt_cnt+ 1)
     WHERE hr.person_id=person_id
      AND hr.expect_id=0.0
      AND hr.expectation_ftdesc=null
     WITH nocounter
    ;end update
    IF (curqual=0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Update lock patient failed"
     SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
     SET was_locked = 0
    ELSE
     COMMIT
     CALL echo(build("lock state of zero row updated for for person = ",person_id))
     SET was_locked = 1
    ENDIF
   ENDIF
   IF (was_locked=1)
    CALL echo(build("lock obtained for person = ",person_id))
   ELSE
    CALL echo(build("failed to obtain lock for person = ",person_id))
   ENDIF
   RETURN(was_locked)
 END ;Subroutine
 SUBROUTINE (islocked(person_id=f8) =i4)
   DECLARE is_locked = i4 WITH protect, noconstant(99)
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE hr.person_id=person_id
     AND hr.expect_id=0.0
     AND hr.expectation_ftdesc=null
    DETAIL
     IF (hr.status_flag=1)
      is_locked = 1
     ELSE
      is_locked = 0
     ENDIF
    WITH nocounter, forupdate(hr)
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM hm_recommendation hr
     WHERE hr.person_id=person_id
      AND hr.expect_id=0.0
      AND hr.expectation_ftdesc=null
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET is_locked = 1
    ENDIF
   ENDIF
   RETURN(is_locked)
 END ;Subroutine
 SUBROUTINE (releaselock(person_id=f8,coherentfrom=q8,coherentuntil=q8) =null)
   CALL echo(build("Attempting to release the lock on person = ",person_id))
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE hr.person_id=person_id
     AND hr.expect_id=0.0
     AND hr.expectation_ftdesc=null
    WITH nocounter, forupdate(hr)
   ;end select
   IF (curqual=0)
    CALL echo("DB has a row lock so some other process is holding the lock and it cannot be freed")
    CALL echo(build("person_id = ",person_id))
    CALL echo(build("unable to release the lock on person = ",person_id))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Release lock on patient failed"
    SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
   ELSE
    UPDATE  FROM hm_recommendation hr
     SET hr.status_flag = 0, hr.due_dt_tm = cnvtdatetime(coherentfrom), hr.first_due_dt_tm =
      cnvtdatetime(coherentuntil),
      hr.updt_dt_tm = cnvtdatetime(sysdate), hr.updt_id = reqinfo->updt_id, hr.updt_task = reqinfo->
      updt_task,
      hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr.updt_cnt+ 1)
     WHERE hr.person_id=person_id
      AND hr.expect_id=0.0
      AND hr.expectation_ftdesc=null
     WITH nocounter
    ;end update
    IF (curqual=0)
     ROLLBACK
     CALL echo(build("unable to release the lock on person = ",person_id))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Release lock on patient failed"
     SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
    ELSE
     COMMIT
     CALL echo(build("lock released for person = ",person_id))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE stamplastbuilddate(null)
   UPDATE  FROM hm_recommendation hr
    SET hr.due_dt_tm = cnvtdatetime(sysdate)
    WHERE hr.recommendation_id=0
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM hm_recommendation hr
     SET hr.recommendation_id = 0, hr.status_flag = 1, hr.person_id = 0.0,
      hr.expect_id = 0.0, hr.due_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    ROLLBACK
    CALL echo("unable to stamp the last build date time")
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Stamp failed"
    SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
   ELSE
    COMMIT
    CALL echo(build("successfully stamped the last build date time to ",cnvtdatetime(sysdate)))
   ENDIF
 END ;Subroutine
 SUBROUTINE makecoherent(null)
   DECLARE personcount = i4 WITH protect, noconstant(0)
   SET personcount = size(personlist->qual,5)
   DECLARE i = i4 WITH protect, noconstant(0)
   IF (personcount=0)
    CALL logmessage(3,"Recommendations","Z","MakeCoherent",
     "There are no persons to make coherent.  Be sure and fill out the Person List record structure")
    RETURN
   ELSE
    CALL logmessage(3,"Recommendations","S","MakeCoherent",build2("Attempting to make ",personcount,
      " persons coherent"))
   ENDIF
   DECLARE emptydate = dq8 WITH protect, constant(null)
   SET stat = alterlist(coherencylist->person,personcount)
   FOR (i = 1 TO personcount)
     SET coherencylist->person[i].person_id = personlist->qual[i].person_id
     SET coherencylist->person[i].coherent = 0
     SET coherencylist->person[i].coherent_as_of = emptydate
     SET coherencylist->person[i].coherent_until = emptydate
     SET coherencylist->person[i].locked = 0
     SET coherencylist->person[i].ppr_cd = personlist->qual[i].ppr_cd
   ENDFOR
   SET coherencylist->prsnl_id = personlist->prsnl_id
   DECLARE coherent = i2 WITH noconstant(0)
   DECLARE longblobid = f8 WITH noconstant(0)
   DECLARE coherentasof = f8 WITH noconstant(0)
   DECLARE coherentuntil = f8 WITH noconstant(0)
   DECLARE coherentreason = vc WITH noconstant("")
   FOR (i = 1 TO personcount)
     CALL getcoherencydata(coherencylist->person[i].person_id,coherent,longblobid,coherentasof,
      coherentuntil,
      coherentreason)
     SET coherencylist->person[i].coherent = coherent
     SET coherencylist->person[i].long_blob_id = longblobid
     SET coherencylist->person[i].coherent_as_of = coherentasof
     SET coherencylist->person[i].coherent_until = coherentuntil
     IF ((coherencylist->person[i].coherent=0))
      SET coherencylist->person[i].locked = lockpatient(coherencylist->person[i].person_id)
     ENDIF
   ENDFOR
   SET stat = 0
   IF (allow_recommendation_server_ind=1)
    CALL echo("Recommendation Server Allowed")
    EXECUTE srvrtl
    SET hmsg = uar_srvselectmessage(966803)
    SET hrequest = uar_srvcreaterequest(hmsg)
    SET hreply = uar_srvcreatereply(hmsg)
    DECLARE servercheck = c1
    SET stat = uar_srvexecute(hmsg,hrequest,hreply)
    SET hstatus = uar_srvgetstruct(hreply,"status_data")
    SET servercheck = uar_srvgetstringptr(hstatus,"status")
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    IF (servercheck="S")
     SET stat = callrecommendationserver(null)
    ELSE
     CALL logmessage(2,"Recommendation Server: Not Running","","966812","GetRecommendationsByPerson")
     SET stat = callhealthexpectationserver(null)
    ENDIF
    CALL echo(build("Request: ",966812,". Status:",stat))
   ELSE
    SET stat = callhealthexpectationserver(null)
   ENDIF
   FOR (i = 1 TO personcount)
     IF ((coherencylist->person[i].locked=1))
      CALL releaselock(coherencylist->person[i].person_id,coherencylist->person[i].coherent_as_of,
       coherencylist->person[i].coherent_until)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (ispersoncoherent(person_id=f8) =i4)
   DECLARE coherent = i2 WITH noconstant(0)
   DECLARE longblobid = f8 WITH noconstant(0)
   DECLARE coherentasof = f8 WITH noconstant(0)
   DECLARE coherentuntil = f8 WITH noconstant(0)
   DECLARE coherentreason = vc WITH noconstant("")
   CALL getcoherencydata(person_id,coherent,longblobid,coherentasof,coherentuntil,
    coherentreason)
   RETURN(coherent)
 END ;Subroutine
 SUBROUTINE (getcoherencydata(person_id=f8,coherent=i2(ref),long_blob_id=f8(ref),coherent_as_of=f8(
   ref),coherent_until=f8(ref),coherent_reason=vc(ref)) =null)
   DECLARE last_birthday_check = q8 WITH protect, noconstant(cnvtdatetime("0"))
   DECLARE last_build_change = q8 WITH protect, noconstant(cnvtdatetime("0"))
   CALL logmessage(4,"Recommendations","S","GetCoherencyData",build2(
     "Retrieving coherency data for person ",person_id))
   SET coherent_as_of = cnvtdatetime(null)
   SET coherent_until = cnvtdatetime(null)
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE ((hr.person_id=person_id
     AND hr.expect_id=0.0
     AND hr.expectation_ftdesc=null) OR (hr.recommendation_id=0))
    HEAD REPORT
     last_build_change = cnvtdatetime("01-JAN-1800"), last_birthday_check = cnvtdatetime(
      "01-JAN-1800"), coherent_as_of = cnvtdatetime("01-JAN-1800"),
     coherent_until = cnvtdatetime("31-DEC-2199")
    DETAIL
     IF (hr.recommendation_id=0)
      IF (hr.due_dt_tm != null)
       last_build_change = hr.due_dt_tm
      ENDIF
      IF (hr.first_due_dt_tm != null)
       last_birthday_check = hr.first_due_dt_tm
      ENDIF
     ELSE
      IF (hr.due_dt_tm != null)
       coherent_as_of = hr.due_dt_tm
      ENDIF
      IF (hr.first_due_dt_tm != null)
       coherent_until = hr.first_due_dt_tm
      ENDIF
      long_blob_id = hr.step_id
      IF (long_blob_id > 0)
       CALL echo(build("GetCoherencyData: Found long blob id for patient: ",long_blob_id))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage(3,"Recommendations","S","GetCoherencyData",build2("Last Build Date: ",format(
      last_build_change,";;q")))
   CALL logmessage(3,"Recommendations","S","GetCoherencyData",build2("Last Birthday Check Date: ",
     format(last_birthday_check,";;q")))
   CALL logmessage(3,"Recommendations","S","GetCoherencyData",build2("Person ",person_id,
     " is coherent as of: ",format(coherent_as_of,";;q")))
   CALL logmessage(3,"Recommendations","S","GetCoherencyData",build2("Person ",person_id,
     " is coherent until: ",format(coherent_until,";;q")))
   CALL logmessage(3,"Recommendations","S","GetCoherencyData",build2("Person ",person_id,
     " has a long blob id of: ",long_blob_id))
   SET coherent = 1
   IF (coherent_as_of <= last_build_change)
    SET coherent_reason = build2("Person ",person_id,
     " is incoherent because the build has changed since they were last made coherent")
    CALL logmessage(2,"Recommendations","S","GetCoherencyData",coherent_reason)
    SET coherent = 0
   ENDIF
   IF (datetimecmp(last_birthday_check,cnvtdatetime(curdate,0)) != 0)
    SET coherent_reason = build2("Person ",person_id," is incoherent because ",datetimecmp(
      cnvtdatetime(curdate,0),last_birthday_check)," days have passed since the last birthday check")
    CALL logmessage(2,"Recommendations","S","GetCoherencyData",coherent_reason)
    SET coherent = 0
   ENDIF
   IF (cnvtdatetime(curdate,curtime) > coherent_until)
    SET coherent_reason = build2("Person ",person_id,
     " is incoherent because they have a pending order that no longer satisfies")
    CALL logmessage(2,"Recommendations","S","GetCoherencyData",coherent_reason)
    SET coherent = 0
   ENDIF
   IF (coherent=1)
    SET coherent_reason = build2("Person ",person_id," is coherent")
    CALL logmessage(2,"Recommendations","S","GetCoherencyData",coherent_reason)
   ENDIF
 END ;Subroutine
 SUBROUTINE callhealthexpectationserver(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE filloutreply = i2 WITH protect, noconstant(0)
   CALL echo(build("validate",validate(reply)))
   IF (validate(reply) != 0
    AND validate(reply->person) != 0)
    SET filloutreply = 1
   ENDIF
   DECLARE applicationid = i4 WITH constant(966300)
   DECLARE taskid = i4 WITH constant(966310)
   DECLARE requestid = i4 WITH constant(966303)
   DECLARE happ = i4
   DECLARE htask = i4
   DECLARE hstep = i4
   DECLARE hreq = i4
   DECLARE hitem = i4
   DECLARE hreply = i4
   EXECUTE srvrtl
   EXECUTE crmrtl
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    CALL logmessage(0,"HE Server: CrmBeginApp","F","966300",build2("crm status = ",iret))
    RETURN(1)
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    CALL logmessage(0,"HE Server: CrmBeginTask","F","966310",build2("crm status = ",iret))
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    CALL logmessage(0,"HE Server: CrmBeginReq","F","966303",build2("crm status = ",iret))
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF ( NOT (hreq))
    CALL logmessage(0,"HE Server: CrmGetRequest","F","966303","no handle created")
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   DECLARE personcount = i4 WITH protect, noconstant(size(coherencylist->person,5))
   FOR (i = 1 TO personcount)
     IF ((((coherencylist->person[i].coherent=0)) OR (filloutreply=1)) )
      CALL logmessage(3,"Recommendations","S","CallHealthExpectationServer",build2(
        "Calling HE Server for person ",coherencylist->person[i].person_id))
      SET hitem = uar_srvadditem(hreq,"person")
      SET iret = uar_srvsetdouble(hitem,"person_id",coherencylist->person[i].person_id)
      SET iret = uar_srvsetdouble(hitem,"long_blob_id",coherencylist->person[i].long_blob_id)
      IF ((coherencylist->person[i].coherent=0))
       SET iret = uar_srvsetshort(hitem,"write_to_blob",1)
      ELSE
       IF ((coherencylist->person[i].long_blob_id > 0))
        SET iret = uar_srvsetshort(hitem,"read_from_blob",1)
       ENDIF
      ENDIF
     ELSE
      CALL logmessage(3,"Recommendations","S","CallHealthExpectationServer",build2(
        "No need to call HE Server for person ",coherencylist->person[i].person_id,
        " because they are coherent"))
     ENDIF
   ENDFOR
   SET personsinrequest = uar_srvgetitemcount(hreq,"person")
   IF (personsinrequest=0)
    CALL logmessage(4,"Recommendations","S","CallHealthExpectationServer",
     "There is no need to call HE server")
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   CALL echo(build2("Calling HE server with ",personsinrequest," persons"))
   SET iret = uar_crmperform(hstep)
   CALL echo(build("HE Server: CRM Perform, Status:",iret))
   IF (iret)
    CALL logmessage(0,"HE Server: CrmPerform","F","966303",build2("crm status = ",iret))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF ( NOT (hreply))
    CALL logmessage(0,"HE Server: CrmGetReply","F","966303","no handle returned")
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   IF (filloutreply=1)
    CALL copyserverreply(hreply)
   ENDIF
   SET hstatus = uar_srvgetstruct(hreply,"status_data")
   SET status = uar_srvgetstringptr(hstatus,"status")
   SET status_value = uar_srvgetlong(hstatus,"status_value")
   IF (((status="F") OR (status_value != 0)) )
    CALL logmessage(0,"HE Server: Status",status,"Health Expect Server",build2("status value = ",
      status_value))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   DECLARE blobidfromserver = f8 WITH protect, noconstant(0)
   DECLARE currentdate = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   SET personcount = uar_srvgetitemcount(hreply,"person")
   IF (personcount=0)
    CALL logmessage(0,"HE Server: Inconsistent","F","HE Server",build2(
      "There were no persons returned which is inconsistent with the request of ",personsinrequest))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
   DECLARE pi = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO personcount)
     SET hperson = uar_srvgetitem(hreply,"person",(i - 1))
     SET personid = uar_srvgetdouble(hperson,"person_id")
     CALL logmessage(4,"Recommendations","S","CallHealthExpectationServer",build2(
       "Iterating through server reply for person ",personid))
     SET pos = locateval(pi,1,size(coherencylist->person,5),personid,coherencylist->person[pi].
      person_id)
     IF (pos=0)
      CALL logmessage(0,"HE Server: Inconsistent","F","HE Server",build2("The person id ",personid,
        " returned from the HE server was not passed in the request"))
      CALL uar_crmendreq(hstep)
      CALL uar_crmendtask(htask)
      CALL uar_crmendapp(happ)
      RETURN(1)
     ENDIF
     IF ((coherencylist->person[pos].coherent=0))
      SET coherencylist->person[pos].coherent_as_of = currentdate
      SET coherencylist->person[pos].coherent_until = determinecoherentuntildate(hperson)
      SET blobidfromserver = uar_srvgetdouble(hperson,"long_blob_id")
      IF (blobidfromserver > 0
       AND (coherencylist->person[pos].long_blob_id != blobidfromserver))
       CALL logmessage(3,"Recommendations","S","CallHealthExpectationServer",build2(
         "Updating blob id for person ",personid," from ",coherencylist->person[pos].long_blob_id,
         " to ",
         blobidfromserver))
       UPDATE  FROM hm_recommendation hr
        SET hr.step_id = blobidfromserver
        WHERE hr.person_id=personid
         AND hr.expect_id=0.0
         AND hr.expectation_ftdesc=null
        WITH nocounter
       ;end update
       SET coherencylist->person[pos].long_blob_id = blobidfromserver
      ENDIF
     ENDIF
   ENDFOR
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (determinecoherentuntildate(hperson=i4) =dq8)
   DECLARE irec = i4 WITH protect, noconstant(0)
   DECLARE nextduedate = dq8 WITH protect, noconstant(null)
   DECLARE datetoreturn = dq8 WITH protect, noconstant(null)
   DECLARE drecommendationid = f8 WITH protect, noconstant(0)
   DECLARE dexpectationid = f8 WITH protect, noconstant(0)
   DECLARE qualifyuntildate = dq8 WITH protect, noconstant(cnvtdatetime(null))
   SET recordcount = uar_srvgetitemcount(hperson,"record")
   IF (recordcount=0)
    RETURN(nextduedate)
   ENDIF
   FOR (irec = 1 TO recordcount)
     SET hrecord = uar_srvgetitem(hperson,"record",(irec - 1))
     SET drecommendationid = uar_srvgetdouble(hrecord,"recommendation_id")
     SET dexpectationid = uar_srvgetdouble(hrecord,"expectation_id")
     IF (drecommendationid=0
      AND dexpectationid > 0)
      CALL uar_srvgetdate(hrecord,"next_due_dt_tm",nextduedate)
      IF (datetoreturn=null)
       SET datetoreturn = nextduedate
      ELSE
       IF (datetoreturn < nextduedate
        AND datetoreturn != null)
        SET datetoreturn = nextduedate
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL uar_srvgetdate(hperson,"qualify_until_dt_tm",qualifyuntildate)
   IF (qualifyuntildate != null
    AND ((qualifyuntildate < datetoreturn) OR (datetoreturn=null)) )
    SET datetoreturn = qualifyuntildate
   ENDIF
   RETURN(datetoreturn)
 END ;Subroutine
 SUBROUTINE (copyserverreply(hreply=i4) =null)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET hstatus = uar_srvgetstruct(hreply,"status_data")
   SET reply->status_data.status = uar_srvgetstringptr(hstatus,"status")
   SET reply->status_data.status_value = uar_srvgetlong(hstatus,"status_value")
   CALL echo(build("status_value ",reply->status_data.status_value))
   DECLARE isubevents = i4 WITH protect, noconstant(0)
   SET isubeventcount = uar_srvgetitemcount(hstatus,"subeventstatus")
   IF (isubeventcount > 0)
    SET currentsize = size(reply->status_data.subeventstatus,5)
    SET stat = alter(reply->status_data.subeventstatus,(currentsize+ isubeventcount))
    FOR (i = 1 TO isubeventcount)
      SET nsubeventstatus = uar_srvgetitem(hstatus,"subeventstatus",(i - 1))
      SET reply->status_data.subeventstatus[(currentsize+ i)].operationname = substring(1,25,
       uar_srvgetstringptr(nsubeventstatus,"OperationName"))
      SET reply->status_data.subeventstatus[(currentsize+ i)].operationstatus = substring(1,1,
       uar_srvgetstringptr(nsubeventstatus,"OperationStatus"))
      SET reply->status_data.subeventstatus[(currentsize+ i)].targetobjectname = substring(1,25,
       uar_srvgetstringptr(nsubeventstatus,"TargetObjectName"))
      SET reply->status_data.subeventstatus[(currentsize+ i)].targetobjectvalue = uar_srvgetstringptr
      (nsubeventstatus,"TargetObjectValue")
    ENDFOR
   ENDIF
   IF ((reply->status_data.status="F"))
    RETURN
   ENDIF
   CALL uar_srvgetdate(hreply,"valid_as_of",reply->valid_as_of)
   SET reply->coherency_active_ind = uar_srvgetshort(hreply,"coherency_active_ind")
   IF (validate(reply->filteredrecommendation)=1)
    SET reply->filteredrecommendation = uar_srvgetshort(hreply,"filtered_recommendation_ind")
    CALL echo(build("filteredRecommendation : ",reply->filteredrecommendation))
   ENDIF
   DECLARE irem = i4 WITH protect, noconstant(0)
   DECLARE irec = i4 WITH protect, noconstant(0)
   SET personcount = uar_srvgetitemcount(hreply,"person")
   SET stat = alterlist(reply->person,personcount)
   FOR (i = 1 TO personcount)
     SET hperson = uar_srvgetitem(hreply,"person",(i - 1))
     SET reply->person[i].person_id = uar_srvgetdouble(hperson,"person_id")
     SET reply->person[i].long_blob_id = uar_srvgetdouble(hperson,"long_blob_id")
     CALL uar_srvgetdate(hperson,"qualify_until_dt_tm",reply->person[i].qualify_until_dt_tm)
     CALL logmessage(3,"Recommendations","S","CopyServerReply",build2(
       "Copying from server reply to script reply for person ",reply->person[i].person_id))
     SET remindercount = uar_srvgetitemcount(hperson,"reminder")
     SET stat = alterlist(reply->person[i].reminder,remindercount)
     CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("Person has ",remindercount,
       " reminders"))
     FOR (irem = 1 TO remindercount)
       SET hreminder = uar_srvgetitem(hperson,"reminder",(irem - 1))
       SET reply->person[i].reminder[irem].schedule_id = uar_srvgetdouble(hreminder,"schedule_id")
       SET reply->person[i].reminder[irem].series_id = uar_srvgetdouble(hreminder,"series_id")
       SET reply->person[i].reminder[irem].expectation_id = uar_srvgetdouble(hreminder,
        "expectation_id")
       SET reply->person[i].reminder[irem].step_id = uar_srvgetdouble(hreminder,"step_id")
       SET reply->person[i].reminder[irem].status_flag = uar_srvgetshort(hreminder,"status_flag")
       CALL uar_srvgetdate(hreminder,"effective_start_dt_tm",reply->person[i].reminder[irem].
        effective_start_dt_tm)
       CALL uar_srvgetdate(hreminder,"valid_start_dt_tm",reply->person[i].reminder[irem].
        valid_start_dt_tm)
       CALL uar_srvgetdate(hreminder,"valid_end_dt_tm",reply->person[i].reminder[irem].
        valid_end_dt_tm)
       SET reply->person[i].reminder[irem].recommend_start_age = uar_srvgetlong(hreminder,
        "recommend_start_age")
       SET reply->person[i].reminder[irem].recommend_end_age = uar_srvgetlong(hreminder,
        "recommend_end_age")
       CALL uar_srvgetdate(hreminder,"recommend_due_dt_tm",reply->person[i].reminder[irem].
        recommend_due_dt_tm)
       CALL uar_srvgetdate(hreminder,"over_due_dt_tm",reply->person[i].reminder[irem].over_due_dt_tm)
       CALL uar_srvgetdate(hreminder,"last_sat_dt_tm",reply->person[i].reminder[irem].last_sat_dt_tm)
       IF (validate(reply->person[i].reminder[irem].near_due_dt_tm)=1)
        CALL uar_srvgetdate(hreminder,"near_due_dt_tm",reply->person[i].reminder[irem].near_due_dt_tm
         )
       ENDIF
       SET reply->person[i].reminder[irem].alternate_exp_available = uar_srvgetshort(hreminder,
        "alternate_exp_available")
       SET reply->person[i].reminder[irem].last_sat_prsnl_id = uar_srvgetdouble(hreminder,
        "last_sat_prsnl_id")
       SET reply->person[i].reminder[irem].last_sat_prsnl_name = uar_srvgetstringptr(hreminder,
        "last_sat_prsnl_name")
       SET reply->person[i].reminder[irem].last_sat_comment = uar_srvgetstringptr(hreminder,
        "last_sat_comment")
       SET reply->person[i].reminder[irem].last_sat_organization_id = uar_srvgetdouble(hreminder,
        "last_sat_organization_id")
       SET reply->person[i].reminder[irem].frequency_value = uar_srvgetlong(hreminder,
        "frequency_value")
       SET reply->person[i].reminder[irem].frequency_unit_cd = uar_srvgetdouble(hreminder,
        "frequency_unit_cd")
       SET reply->person[i].reminder[irem].has_frequency_modification = uar_srvgetshort(hreminder,
        "has_frequency_modification")
       SET reply->person[i].reminder[irem].has_due_date_modification = uar_srvgetshort(hreminder,
        "has_due_date_modification")
       SET reply->person[i].reminder[irem].system_frequency_value = uar_srvgetlong(hreminder,
        "system_frequency_value")
       SET reply->person[i].reminder[irem].system_frequency_unit_cd = uar_srvgetdouble(hreminder,
        "system_frequency_unit_cd")
       SET reply->person[i].reminder[irem].recommendation_id = uar_srvgetdouble(hreminder,
        "recommendation_id")
       SET reply->person[i].reminder[irem].expectation_ftdesc = uar_srvgetstringptr(hreminder,
        "expectation_ftdesc")
       SET reply->person[i].reminder[irem].has_expectation_modification = uar_srvgetshort(hreminder,
        "expectation_override_ind")
       IF (validate(reply->person[i].reminder[irem].expectation_name)=1)
        IF (uar_srvfieldexists(hreminder,"expectation_name"))
         SET reply->person[i].reminder[irem].expectation_name = uar_srvgetstringptr(hreminder,
          "expectation_name")
        ENDIF
       ENDIF
       IF (validate(reply->person[i].reminder[irem].external_info)=1)
        SET externalinfocount = uar_srvgetitemcount(hreminder,"external_info")
        SET stat = alterlist(reply->person[i].reminder[irem].external_info,externalinfocount)
        CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("Reminder has ",
          externalinfocount," external sources"))
        FOR (iext = 1 TO externalinfocount)
          SET hexternalinfo = uar_srvgetitem(hreminder,"external_info",(iext - 1))
          SET reply->person[i].reminder[irem].external_info[iext].source_type_flag = uar_srvgetshort(
           hexternalinfo,"source_type_flag")
          SET attributecount = uar_srvgetitemcount(hexternalinfo,"source_attribute")
          SET stat = alterlist(reply->person[i].reminder[irem].external_info[iext].source_attribute,
           attributecount)
          CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("External source has ",
            attributecount," source attributes"))
          FOR (iattr = 1 TO attributecount)
            SET hattribute = uar_srvgetitem(hexternalinfo,"source_attribute",(iattr - 1))
            SET reply->person[i].reminder[irem].external_info[iext].source_attribute[iattr].name =
            uar_srvgetstringptr(hattribute,"name")
            SET reply->person[i].reminder[irem].external_info[iext].source_attribute[iattr].value =
            uar_srvgetstringptr(hattribute,"value")
          ENDFOR
          SET supportingfactscount = uar_srvgetitemcount(hexternalinfo,"supporting_fact")
          SET stat = alterlist(reply->person[i].reminder[irem].external_info[iext].supporting_fact,
           supportingfactscount)
          CALL logmessage(4,"Recommendations","S","CopyServerReply",build2(reply->person[i].reminder[
            irem].expectation_name," has ",supportingfactscount," supporting facts"))
          FOR (ifct = 1 TO supportingfactscount)
            SET hsupportingfact = uar_srvgetitem(hexternalinfo,"supporting_fact",(ifct - 1))
            SET reply->person[i].reminder[irem].external_info[iext].supporting_fact[ifct].name =
            uar_srvgetstringptr(hsupportingfact,"name")
            SET reply->person[i].reminder[irem].external_info[iext].supporting_fact[ifct].date =
            uar_srvgetstringptr(hsupportingfact,"date")
            SET reply->person[i].reminder[irem].external_info[iext].supporting_fact[ifct].
            formatted_code = uar_srvgetstringptr(hsupportingfact,"formatted_code")
            SET reply->person[i].reminder[irem].external_info[iext].supporting_fact[ifct].
            formatted_source = uar_srvgetstringptr(hsupportingfact,"formatted_source")
          ENDFOR
        ENDFOR
       ENDIF
     ENDFOR
     SET recordcount = uar_srvgetitemcount(hperson,"record")
     SET stat = alterlist(reply->person[i].hmrecord,recordcount)
     CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("Person has ",recordcount,
       " records"))
     FOR (irec = 1 TO recordcount)
       SET hrecord = uar_srvgetitem(hperson,"record",(irec - 1))
       SET reply->person[i].hmrecord[irec].modifier_id = uar_srvgetdouble(hrecord,"modifier_id")
       SET reply->person[i].hmrecord[irec].modifier_type_cd = uar_srvgetdouble(hrecord,
        "modifier_type_cd")
       SET reply->person[i].hmrecord[irec].clinical_event_id = uar_srvgetdouble(hrecord,
        "clinical_event_id")
       SET reply->person[i].hmrecord[irec].order_id = uar_srvgetdouble(hrecord,"order_id")
       SET reply->person[i].hmrecord[irec].procedure_id = uar_srvgetdouble(hrecord,"procedure_id")
       SET reply->person[i].hmrecord[irec].schedule_id = uar_srvgetdouble(hrecord,"schedule_id")
       SET reply->person[i].hmrecord[irec].series_id = uar_srvgetdouble(hrecord,"series_id")
       SET reply->person[i].hmrecord[irec].expectation_id = uar_srvgetdouble(hrecord,"expectation_id"
        )
       SET reply->person[i].hmrecord[irec].step_id = uar_srvgetdouble(hrecord,"step_id")
       SET reply->person[i].hmrecord[irec].status_flag = uar_srvgetshort(hrecord,"status_flag")
       SET reply->person[i].hmrecord[irec].appointment_id = uar_srvgetdouble(hrecord,"appointment_id"
        )
       CALL uar_srvgetdate(hrecord,"modifier_dt_tm",reply->person[i].hmrecord[irec].modifier_dt_tm)
       CALL uar_srvgetdate(hrecord,"next_due_dt_tm",reply->person[i].hmrecord[irec].next_due_dt_tm)
       CALL uar_srvgetdate(hrecord,"recorded_dt_tm",reply->person[i].hmrecord[irec].recorded_dt_tm)
       SET reply->person[i].hmrecord[irec].recorded_for_prsnl_id = uar_srvgetdouble(hrecord,
        "recorded_for_prsnl_id")
       SET reply->person[i].hmrecord[irec].recorded_for_prsnl_name = uar_srvgetstringptr(hrecord,
        "recorded_for_prsnl_name")
       SET reply->person[i].hmrecord[irec].reason_cd = uar_srvgetdouble(hrecord,"reason_cd")
       SET reply->person[i].hmrecord[irec].reason_disp = uar_srvgetstringptr(hrecord,"reason_disp")
       SET reply->person[i].hmrecord[irec].comment = uar_srvgetstringptr(hrecord,"comment")
       SET reply->person[i].hmrecord[irec].created_prsnl_name = uar_srvgetstringptr(hrecord,
        "created_prsnl_name")
       SET reply->person[i].hmrecord[irec].encounter_id = uar_srvgetdouble(hrecord,"encounter_id")
       SET reply->person[i].hmrecord[irec].recommendation_id = uar_srvgetdouble(hrecord,
        "recommendation_id")
       SET reply->person[i].hmrecord[irec].expectation_ftdesc = uar_srvgetstringptr(hrecord,
        "expectation_ftdesc")
       SET reply->person[i].hmrecord[irec].recommendation_action_id = uar_srvgetdouble(hrecord,
        "recommendation_action_id")
       IF (validate(reply->person[i].hmrecord[irec].expectation_name)=1)
        IF (uar_srvfieldexists(hrecord,"expectation_name"))
         SET reply->person[i].hmrecord[irec].expectation_name = uar_srvgetstringptr(hrecord,
          "expectation_name")
        ENDIF
       ENDIF
     ENDFOR
     IF (validate(reply->person[i].source_status)=1)
      SET sourcestatuscount = uar_srvgetitemcount(hperson,"source_status")
      SET stat = alterlist(reply->person[i].source_status,sourcestatuscount)
      FOR (isrc = 1 TO sourcestatuscount)
        SET hsourcestatus = uar_srvgetitem(hperson,"source_status",(isrc - 1))
        SET reply->person[i].source_status[isrc].source_type_flag = uar_srvgetshort(hsourcestatus,
         "source_type_flag")
        SET attributecount = uar_srvgetitemcount(hsourcestatus,"status_attribute")
        SET stat = alterlist(reply->person[i].source_status[isrc].status_attribute,attributecount)
        CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("Source has ",attributecount,
          " attributes"))
        FOR (iattr = 1 TO attributecount)
          SET hattribute = uar_srvgetitem(hsourcestatus,"status_attribute",(iattr - 1))
          SET reply->person[i].source_status[isrc].status_attribute[iattr].name = uar_srvgetstringptr
          (hattribute,"name")
          SET reply->person[i].source_status[isrc].status_attribute[iattr].value =
          uar_srvgetstringptr(hattribute,"value")
        ENDFOR
      ENDFOR
     ENDIF
     IF (validate(reply->person[i].program_supporting_fact)=1)
      SET progsupportingfactscount = uar_srvgetitemcount(hperson,"program_supporting_fact")
      SET stat = alterlist(reply->person[i].program_supporting_fact,progsupportingfactscount)
      CALL echo(build2("program supporting fact count : ",progsupportingfactscount))
      CALL logmessage(4,"Recommendations","S","CopyServerReply",build2("Person has ",
        progsupportingfactscount," program supporting facts"))
      FOR (iprgfct = 1 TO progsupportingfactscount)
        SET hprogamsupfact = uar_srvgetitem(hperson,"program_supporting_fact",(iprgfct - 1))
        SET reply->person[i].program_supporting_fact[iprgfct].program_id = uar_srvgetstringptr(
         hprogamsupfact,"program_id")
        SET reply->person[i].program_supporting_fact[iprgfct].name = uar_srvgetstringptr(
         hprogamsupfact,"name")
        SET reply->person[i].program_supporting_fact[iprgfct].date = uar_srvgetstringptr(
         hprogamsupfact,"date")
        SET reply->person[i].program_supporting_fact[iprgfct].formatted_code = uar_srvgetstringptr(
         hprogamsupfact,"formatted_code")
        SET reply->person[i].program_supporting_fact[iprgfct].formatted_source = uar_srvgetstringptr(
         hprogamsupfact,"formatted_source")
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (logmessage(level=i2,operationname=vc,operationstatus=c1,targetobjectname=vc,
  targetobjectvalue=vc) =null)
   DECLARE messagetolog = vc WITH protect, noconstant("")
   SET messagetolog = build2("{{Target Name:",targetobjectname,"}}{{Target Value:",targetobjectvalue,
    "}}")
   IF (validate(hsystemmessageviewhandle) != 0)
    IF (hsystemmessageviewhandle > 0)
     CALL uar_sysevent(hsystemmessageviewhandle,level,nullterm(operationname),nullterm(messagetolog))
    ENDIF
   ENDIF
   CALL echo(messagetolog,level)
   IF (level > 0)
    RETURN
   ENDIF
   IF (validate(reply) != 0
    AND validate(reply->status_data) != 0)
    SET reply->status_data.status = "F"
    IF (validate(reply->status_data.subeventstatus) != 0)
     IF (error_list_size > size(reply->status_data.subeventstatus,5))
      SET error_list_size += 1
      SET stat = alter(reply->status_data.subeventstatus,error_list_size)
     ENDIF
     SET reply->status_data.subeventstatus[error_list_size].operationname = substring(1,25,
      operationname)
     SET reply->status_data.subeventstatus[error_list_size].operationstatus = substring(1,1,
      operationstatus)
     SET reply->status_data.subeventstatus[error_list_size].targetobjectname = substring(1,25,
      targetobjectname)
     SET reply->status_data.subeventstatus[error_list_size].targetobjectvalue = targetobjectvalue
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE markasincoherent(null)
   DECLARE ipersoncnt = i4 WITH protect, noconstant(0)
   SET ipersoncnt = size(personlist->qual,5)
   UPDATE  FROM hm_recommendation hr,
     (dummyt d1  WITH seq = value(ipersoncnt))
    SET hr.due_dt_tm = null, hr.updt_dt_tm = cnvtdatetime(sysdate), hr.updt_id = reqinfo->updt_id,
     hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr
     .updt_cnt+ 1)
    PLAN (d1)
     JOIN (hr
     WHERE (hr.person_id=personlist->qual[d1.seq].person_id)
      AND hr.expect_id=0.0
      AND hr.expectation_ftdesc=null)
    WITH nocounter
   ;end update
   SET personcount = size(personlist->qual,5)
   FOR (i = 1 TO personcount)
     CALL logmessage(2,"Recommendations","S","MarkAsInCoherent",build2("Person ",personlist->qual[i].
       person_id," has been made incoherent"))
   ENDFOR
 END ;Subroutine
 SUBROUTINE (markhmincoherent_appointment(person_id=f8,appointment_type_cd=f8) =null)
   DECLARE appointmentsatisfiercount = i4
   SELECT INTO "nl:"
    y = count(hes.expect_sat_id)
    FROM hm_expect_sat hes
    WHERE hes.parent_entity_name="SCH_APPT_TYPE"
     AND hes.parent_entity_id=appointment_type_cd
     AND hes.active_ind=1
    DETAIL
     appointmentsatisfiercount = y
    WITH nocounter
   ;end select
   IF (appointmentsatisfiercount > 0)
    CALL logmessage(3,"Recommendations","S","MarkHMIncoherent_Appointment",build2(
      appointmentsatisfiercount," satisfier(s) found for appointment type: ",appointment_type_cd,
      " Person ID: ",person_id,
      ". Marking as InCoherent..."))
    SET stat = alterlist(personlist->qual,1)
    SET personlist->qual[1].person_id = person_id
    CALL markasincoherent(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE callrecommendationserver(null)
   DECLARE filloutreply = i2 WITH protect, noconstant(0)
   CALL echo(build("validate",validate(reply)))
   IF (validate(reply) != 0
    AND validate(reply->person) != 0)
    SET filloutreply = 1
   ENDIF
   SET personcount = size(personlist->qual,5)
   IF (filloutreply=0)
    CALL echo("Returning 0 from CallRecommendationServer, FILLOUTREPLY = 0")
    RETURN(0)
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4
   EXECUTE srvrtl
   SET hmsg = uar_srvselectmessage(966812)
   SET hrequest = uar_srvcreaterequest(hmsg)
   SET hreply = uar_srvcreatereply(hmsg)
   IF (personcount=0)
    CALL logmessage(4,"Recommendations","S","CallHealthRecommendationServer",
     "There is no need to call Recommendation server")
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    RETURN(0)
   ENDIF
   SET iret = uar_srvsetdouble(hrequest,"prsnl_id",coherencylist->prsnl_id)
   SET iret = uar_srvsetshort(hrequest,"include_satisfied_pending_ind",include_satisfied_pending_ind)
   CALL echo(build("CallRecommendationServer: include_satisfied_pending_ind value: ",
     include_satisfied_pending_ind))
   SET iret = uar_srvsetshort(hrequest,"async_res_ind",async_res_ind)
   FOR (i = 1 TO personcount)
     SET hitem = uar_srvadditem(hrequest,"person")
     SET iret = uar_srvsetdouble(hitem,"person_id",coherencylist->person[i].person_id)
     SET iret = uar_srvsetdouble(hitem,"ppr_cd",coherencylist->person[i].ppr_cd)
     CALL logmessage(3,"Recommendations","S","CallRecommendationServer",build2(
       "Calling Recommendation Server for person ",coherencylist->person[i].person_id))
   ENDFOR
   SET stat = uar_srvexecute(hmsg,hrequest,hreply)
   CALL echo(build("HRecommendation Server: SRV Perform, Status:",stat))
   IF (stat > 0)
    CALL logmessage(0,"Recommendation Server: SrvExecute","F","966812",build2("srv status = ",stat))
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    CALL echo("Returning (stat) ;failure")
    RETURN(stat)
   ENDIF
   CALL copyserverreply(hreply)
   SET hstatus = uar_srvgetstruct(hreply,"status_data")
   SET status = uar_srvgetstringptr(hstatus,"status")
   SET status_value = uar_srvgetlong(hstatus,"status_value")
   IF (((status="F") OR (status_value != 0)) )
    CALL logmessage(0,"Recommendation Server: Status",status,"Recommendation Server",build2(
      "status value = ",status_value))
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    RETURN(status_value)
   ENDIF
   SET personsinrequest = uar_srvgetitemcount(hrequest,"person")
   SET personcount = uar_srvgetitemcount(hreply,"person")
   IF (personcount=0)
    CALL logmessage(0,"Recommendation Server: Inconsistent","F","Recommendation Server",build2(
      "There were no persons returned which is inconsistent with the request of ",personsinrequest))
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(2)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE ms_healthmaint_view = vc WITH protect, constant("HEALTHMAINT")
 DECLARE ms_immunsched_view = vc WITH protect, constant("IMMUNSCHED")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE containshm = i2
 DECLARE containsimm = i2
 SET containshm = 0
 SET containsimm = 0
 IF (expand(ml_idx,1,size(request->views,5),ms_healthmaint_view,request->views[ml_idx].view_name))
  SET containshm = 1
 ENDIF
 IF (expand(ml_idx,1,size(request->views,5),ms_immunsched_view,request->views[ml_idx].view_name))
  SET containsimm = 1
 ENDIF
 IF (((containshm=1) OR (containsimm=1)) )
  IF (containshm=1
   AND containsimm=0)
   SET allow_recommendation_server_ind = 1
  ENDIF
  SET ml_stat = alterlist(personlist->qual,1)
  SET personlist->qual[1].person_id = request->person_id
  CALL makecoherent(null)
 ENDIF
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
