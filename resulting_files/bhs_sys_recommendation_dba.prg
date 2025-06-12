CREATE PROGRAM bhs_sys_recommendation:dba
 RECORD reply(
   1 person[*]
     2 person_id = f8
     2 reminder[*]
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 effective_start_dt_tm = dq8
       3 valid_start_dt_tm = dq8
       3 valid_end_dt_tm = dq8
       3 recommend_start_age = i4
       3 recommend_end_age = i4
       3 recommend_due_dt_tm = dq8
       3 over_due_dt_tm = dq8
       3 latest_postponed_dt_tm = dq8
       3 alternate_exp_available = i2
       3 last_sat_dt_tm = dq8
       3 last_sat_prsnl_id = f8
       3 last_sat_prsnl_name = vc
       3 last_sat_comment = vc
       3 last_sat_organization_id = f8
     2 hmrecord[*]
       3 modifier_id = f8
       3 modifier_type_cd = f8
       3 modifier_type_mean = vc
       3 clinical_event_id = f8
       3 order_id = f8
       3 procedure_id = f8
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 modifier_dt_tm = dq8
       3 next_due_dt_tm = dq8
       3 recorded_dt_tm = dq8
       3 recorded_for_prsnl_id = f8
       3 recorded_for_prsnl_name = vc
       3 reason_cd = f8
       3 reason_disp = vc
       3 comment = vc
       3 created_prsnl_id = f8
       3 created_prsnl_name = vc
       3 organization_id = f8
       3 encounter_id = f8
       3 adr[*]
         4 reltn_entity_id = f8
         4 reltn_entity_all_ind = i2
       3 status_ind = i2
     2 schedule_reltn[*]
       3 schedule_id = f8
       3 mode_flag = i2
     2 series[*]
       3 series_mean = vc
       3 sched_mean = vc
       3 qualify_flag = i2
       3 explanation = vc
   1 person_org_sec_on = i2
   1 status_data
     2 status = c1
     2 status_value = i4
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE makecoherent(person_id=f8) = null
 DECLARE markasincoherent(null) = null
 DECLARE getserverinfo(person_id=f8) = null
 DECLARE ispersoncoherent(person_id=f8) = i4
 DECLARE delhrtableitems(person_id=f8) = null
 DECLARE addreminderitems(person_id=f8) = null
 DECLARE addrecorditems(person_id=f8) = null
 DECLARE clean_app(happ=i4) = null
 DECLARE clean_app_task(happ=i4,htask=i4) = null
 DECLARE clean_app_task_req(happ=i4,htask=i4,hstep=i4) = null
 DECLARE applicationid = i4 WITH constant(966300)
 DECLARE taskid = i4 WITH constant(966310)
 DECLARE requestid = i4 WITH constant(966303)
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hstep = i4
 DECLARE hreq = i4
 DECLARE hitem = i4
 DECLARE hitem2 = i4
 DECLARE hcode = i4
 DECLARE hreply = i4
 DECLARE lqualcnt = i4
 DECLARE iret = i4
 DECLARE rem_count = i4
 DECLARE rec_count = i4
 DECLARE cur_dt_tm = dq8
 DECLARE pending_until_date = q8
 FREE RECORD personlist
 RECORD personlist(
   1 qual[*]
     2 person_id = f8
 )
 FREE RECORD hrservremlist
 RECORD hrservremlist(
   1 qual[*]
     2 expect_id = f8
     2 step_id = f8
     2 due_dt_tm = dq8
     2 first_due_dt_tm = dq8
     2 status_flag = i4
     2 satisfaction_id = f8
     2 satisfaction_source = vc
     2 action_flag = i4
     2 schedule_id = f8
     2 series_id = f8
     2 long_text_id = f8
     2 on_behalf_of_prsnl_id = f8
     2 comment = vc
     2 action_dt_tm = dq8
     2 valid_start_dt_tm = dq8
     2 valid_end_dt_tm = dq8
     2 over_due_dt_tm = dq8
 )
 FREE SET hrservreclist
 RECORD hrservreclist(
   1 qual[*]
     2 expect_id = f8
     2 first_due_dt_tm = dq8
     2 step_id = f8
     2 status_flag = i4
     2 satisfaction_id = f8
     2 satisfaction_source = vc
     2 action_flag = i4
     2 schedule_id = f8
     2 series_id = f8
     2 long_text_id = f8
     2 on_behalf_of_prsnl_id = f8
     2 reason_cd = f8
     2 comment = vc
     2 action_dt_tm = dq8
     2 modifier_type_cd = f8
 )
 FREE RECORD hrtablelist
 RECORD hrtablelist(
   1 qual[*]
     2 recommendation_id = f8
     2 long_text_id = f8
 )
 FREE RECORD temp
 RECORD temp(
   1 pending_temp = dq8
 )
 DECLARE lockpatient(person_id=f8) = i4
 DECLARE releaselock(person_id=f8,coherentfrom=q8,coherentuntil=q8) = null
 DECLARE islocked(person_id=f8) = i4
 DECLARE stamplastbuilddate(null) = null
 SET reply->status_data.status = "S"
 SUBROUTINE lockpatient(person_id)
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
    DECLARE emptydate = dq8
    SET emptydate = null
    CALL releaselock(person_id,emptydate,emptydate)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "obtain lock timeout"
    SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
    SET was_locked = 0
   ELSEIF (locked_state=99)
    CALL echo(build("lock available for person = ",person_id))
    DECLARE rec_id = i4
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
      hr.expect_id = 0.0, hr.updt_cnt = 0, hr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
     SET hr.status_flag = 1, hr.updt_dt_tm = cnvtdatetime(curdate,curtime3), hr.updt_id = reqinfo->
      updt_id,
      hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr
      .updt_cnt+ 1)
     WHERE hr.person_id=person_id
      AND ((hr.expect_id+ 0)=0.0)
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
 SUBROUTINE islocked(person_id)
   DECLARE is_locked = i4 WITH protect, noconstant(99)
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE hr.person_id=person_id
     AND ((hr.expect_id+ 0)=0.0)
    DETAIL
     IF (hr.status_flag=1)
      is_locked = 1
     ELSE
      is_locked = 0
     ENDIF
    WITH nocounter
   ;end select
   RETURN(is_locked)
 END ;Subroutine
 SUBROUTINE releaselock(person_id,coherentfrom,coherentuntil)
   CALL echo(build("Attempting to release the lock on person = ",person_id))
   UPDATE  FROM hm_recommendation hr
    SET hr.status_flag = 0, hr.due_dt_tm = cnvtdatetime(coherentfrom), hr.first_due_dt_tm =
     cnvtdatetime(coherentuntil),
     hr.updt_dt_tm = cnvtdatetime(curdate,curtime3), hr.updt_id = reqinfo->updt_id, hr.updt_task =
     reqinfo->updt_task,
     hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr.updt_cnt+ 1)
    WHERE hr.person_id=person_id
     AND ((hr.expect_id+ 0)=0.0)
    WITH nocounter
   ;end update
   IF (curqual=0)
    ROLLBACK
    CALL echo(build("unable to release the lock on person = ",person_id))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Relase lock on patient failed"
    SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
   ELSE
    COMMIT
    CALL echo(build("lock released for person = ",person_id))
   ENDIF
 END ;Subroutine
 SUBROUTINE stamplastbuilddate(null)
   UPDATE  FROM hm_recommendation hr
    SET hr.due_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE hr.person_id=0.0
     AND ((hr.expect_id+ 0)=0.0)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM hm_recommendation hr
     SET hr.status_flag = 1, hr.person_id = 0.0, hr.expect_id = 0.0,
      hr.due_dt_tm = cnvtdatetime(curdate,curtime3)
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
    CALL echo(build("successfully stamped the last build date time to ",cnvtdatetime(curdate,curtime3
       )))
   ENDIF
 END ;Subroutine
 SUBROUTINE makecoherent(person_id)
   DECLARE coherent = i4 WITH protect, noconstant
   SET coherent = ispersoncoherent(person_id)
   IF (coherent=0)
    DECLARE locked_ind = i4 WITH protect, noconstant
    SET locked_ind = lockpatient(person_id)
    IF (locked_ind=1)
     IF ((reply->status_data.status != "F"))
      CALL getserverinfo(person_id)
     ENDIF
     IF ((reply->status_data.status != "F"))
      CALL delhrtableitems(person_id)
     ENDIF
     IF ((reply->status_data.status != "F"))
      CALL addreminderitems(person_id)
     ENDIF
     IF ((reply->status_data.status != "F"))
      CALL addrecorditems(person_id)
     ENDIF
     COMMIT
     IF ((reply->status_data.status != "F"))
      CALL releaselock(person_id,cnvtdatetime(curdate,curtime3),pending_until_date)
     ELSE
      DECLARE emptydate = dq8
      SET emptydate = null
      CALL releaselock(person_id,emptydate,pending_until_date)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE ispersoncoherent(person_id)
   DECLARE return_value = i4 WITH protect, noconstant(0)
   DECLARE coherent_as_of = q8 WITH protect, noconstant(cnvtdatetime("0"))
   DECLARE coherent_until = q8 WITH protect, noconstant(cnvtdatetime("0"))
   DECLARE last_birthday_check = q8 WITH protect, noconstant(cnvtdatetime("0"))
   DECLARE last_build_change = q8 WITH protect, noconstant(cnvtdatetime("0"))
   SELECT INTO "nl:"
    FROM hm_recommendation hr
    WHERE ((hr.person_id=person_id
     AND ((hr.expect_id+ 0)=0.0)) OR (hr.person_id=0.0
     AND ((hr.expect_id+ 0)=0.0)))
    HEAD REPORT
     last_build_change = cnvtdatetime("31-DEC-2199"), last_birthday_check = cnvtdatetime(
      "01-JAN-1800"), coherent_as_of = cnvtdatetime("01-JAN-1800"),
     coherent_until = cnvtdatetime("31-DEC-2199")
    DETAIL
     IF (hr.person_id=0)
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
     ENDIF
     long_blob_id = hr.step_id
    WITH nocounter
   ;end select
   CALL echo(build("Coherent as of date  :",format(coherent_as_of,";;q")))
   CALL echo(build("Last build change date  :",format(last_build_change,";;q")))
   CALL echo(build("Last birthday check date  :",format(last_birthday_check,";;q")))
   CALL echo(build("Last pending satisfier date  :",format(coherent_until,";;q")))
   SET return_value = 1
   IF (coherent_as_of <= last_build_change)
    SET return_value = 0
   ENDIF
   IF (datetimecmp(last_birthday_check,cnvtdatetime(curdate,0)) != 0)
    CALL echo(build("Days since last birthday check ",datetimecmp(last_birthday_check,cnvtdatetime(
        curdate,0))))
    SET return_value = 0
   ENDIF
   IF (cnvtdatetime(curdate,curtime) > coherent_until)
    SET return_value = 0
   ENDIF
   IF (return_value=1)
    CALL echo(build("person is coherent.  person = ",person_id))
   ELSE
    CALL echo(build("person is NOT coherent.  person = ",person_id))
   ENDIF
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE getserverinfo(person_id)
   DECLARE count1 = i4
   DECLARE sprsnl = vc
   EXECUTE srvrtl
   EXECUTE crmrtl
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "BeginApp"
    SET reply->status_data.subeventstatus[1].targetobjectname = "966300"
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "BeginTask"
    SET reply->status_data.subeventstatus[1].targetobjectname = "966310"
    CALL clean_app(happ)
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "BeginReq"
    SET reply->status_data.subeventstatus[1].targetobjectname = "966303"
    CALL clean_app_task(happ,htask)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF ( NOT (hreq))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "GetRequest"
    SET reply->status_data.subeventstatus[1].targetobjectname = "966303"
    CALL clean_app_task_req(happ,htask,hstep)
   ENDIF
   SET hitem = uar_srvadditem(hreq,"person")
   SET iret = uar_srvsetdouble(hitem,"person_id",person_id)
   SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
   SET iret = uar_srvsetdate(hitem,"eval_start_dt_tm",cnvtdatetime(cur_dt_tm))
   CALL echo(build("cur_dt_tm",cur_dt_tm))
   SET iret = uar_crmperform(hstep)
   CALL echo(build("CRM Perform with assignments, Status:",iret))
   IF (iret)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "crmPerform"
    SET reply->status_data.subeventstatus[1].targetobjectname = "966303"
    CALL uar_crmendreq(hstep)
    CALL clean_app_task_req(happ,htask,hstep)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   SET lqualcnt = uar_srvgetitemcount(hreply,"person")
   CALL echo(build("lqualcnt  ",lqualcnt))
   FOR (i = 0 TO (lqualcnt - 1))
     SET hitem2 = uar_srvgetitem(hreply,"person",i)
     SET rem_count = uar_srvgetitemcount(hitem2,"reminder")
     CALL echo(build("rem_count= ",rem_count))
     SET stat = alterlist(hrservremlist->qual,rem_count)
     SET count1 = 0
     FOR (x = 0 TO (rem_count - 1))
       SET hcode = uar_srvgetitem(hitem2,"reminder",x)
       SET count1 = (count1+ 1)
       IF (uar_srvgetdouble(hcode,"expectation_id") > 0)
        SET hrservremlist->qual[count1].expect_id = uar_srvgetdouble(hcode,"expectation_id")
       ELSE
        SET hrservremlist->qual[count1].expect_id = - (1)
       ENDIF
       CALL uar_srvgetdate(hcode,"effective_start_dt_tm",hrservremlist->qual[count1].first_due_dt_tm)
       SET hrservremlist->qual[count1].step_id = uar_srvgetdouble(hcode,"step_id")
       SET hrservremlist->qual[count1].status_flag = uar_srvgetshort(hcode,"status_flag")
       CALL uar_srvgetdate(hcode,"recommend_due_dt_tm",hrservremlist->qual[count1].due_dt_tm)
       CALL uar_srvgetdate(hcode,"last_sat_dt_tm",hrservremlist->qual[count1].action_dt_tm)
       CALL uar_srvgetdate(hcode,"valid_start_dt_tm",hrservremlist->qual[count1].valid_start_dt_tm)
       CALL uar_srvgetdate(hcode,"valid_end_dt_tm",hrservremlist->qual[count1].valid_end_dt_tm)
       CALL uar_srvgetdate(hcode,"over_due_dt_tm",hrservremlist->qual[count1].over_due_dt_tm)
       SET hrservremlist->qual[count1].on_behalf_of_prsnl_id = uar_srvgetdouble(hcode,
        "last_sat_prsnl_id")
       SET hrservremlist->qual[count1].comment = uar_srvgetstringptr(hcode,"last_sat_comment")
       SET hrservremlist->qual[count1].satisfaction_id = uar_srvgetdouble(hcode,
        "last_sat_organization_id")
       SET hrservremlist->qual[count1].schedule_id = uar_srvgetdouble(hcode,"schedule_id")
       SET hrservremlist->qual[count1].series_id = uar_srvgetdouble(hcode,"series_id")
       SET hrservremlist->qual[count1].satisfaction_source = "ORG"
     ENDFOR
     CALL echorecord(hrservremlist)
     SET rem_count = count1
     SET rec_count = uar_srvgetitemcount(hitem2,"record")
     CALL echo(build("rec_count= ",rec_count))
     SET stat = alterlist(hrservreclist->qual,rec_count)
     SET count1 = 0
     FOR (x = 0 TO (rec_count - 1))
       SET hcode = uar_srvgetitem(hitem2,"record",x)
       SET count1 = (count1+ 1)
       IF (uar_srvgetdouble(hcode,"expectation_id") > 0)
        SET hrservreclist->qual[count1].expect_id = uar_srvgetdouble(hcode,"expectation_id")
       ELSE
        SET hrservreclist->qual[count1].expect_id = - (1)
       ENDIF
       CALL uar_srvgetdate(hcode,"recorded_dt_tm",hrservreclist->qual[count1].first_due_dt_tm)
       SET hrservreclist->qual[count1].step_id = uar_srvgetdouble(hcode,"step_id")
       SET hrservreclist->qual[count1].status_flag = uar_srvgetshort(hcode,"status_flag")
       CALL uar_srvgetdate(hcode,"modifier_dt_tm",hrservreclist->qual[count1].action_dt_tm)
       SET sprsnl = uar_srvgetstringptr(hcode,"recorded_for_prsnl_name")
       IF ("" < sprsnl)
        SET hrservreclist->qual[count1].on_behalf_of_prsnl_id = uar_srvgetdouble(hcode,
         "recorded_for_prsnl_id")
       ENDIF
       SET hrservreclist->qual[count1].comment = uar_srvgetstringptr(hcode,"comment")
       SET hrservreclist->qual[count1].reason_cd = uar_srvgetdouble(hcode,"reason_cd")
       SET hrservreclist->qual[count1].schedule_id = uar_srvgetdouble(hcode,"schedule_id")
       SET hrservreclist->qual[count1].series_id = uar_srvgetdouble(hcode,"series_id")
       SET hrservreclist->qual[count1].modifier_type_cd = uar_srvgetdouble(hcode,"modifier_type_cd")
       IF (uar_srvgetdouble(hcode,"modifier_id") > 0)
        SET hrservreclist->qual[count1].satisfaction_id = uar_srvgetdouble(hcode,"modifier_id")
        SET hrservreclist->qual[count1].satisfaction_source = "MODIFIER"
       ELSEIF (uar_srvgetdouble(hcode,"clinical_event_id") > 0)
        SET hrservreclist->qual[count1].satisfaction_id = uar_srvgetdouble(hcode,"clinical_event_id")
        SET hrservreclist->qual[count1].satisfaction_source = "CLINICAL_EVENT"
       ELSEIF (uar_srvgetdouble(hcode,"order_id") > 0)
        SET hrservreclist->qual[count1].satisfaction_id = uar_srvgetdouble(hcode,"order_id")
        SET hrservreclist->qual[count1].satisfaction_source = "ORDER"
       ELSEIF (uar_srvgetdouble(hcode,"procedure_id") > 0)
        SET hrservreclist->qual[count1].satisfaction_id = uar_srvgetdouble(hcode,"procedure_id")
        SET hrservreclist->qual[count1].satisfaction_source = "PROCEDURE"
       ENDIF
       CALL uar_srvgetdate(hcode,"next_due_dt_tm",temp->pending_temp)
       IF (pending_until_date=0)
        SET pending_until_date = temp->pending_temp
       ELSEIF ((temp->pending_temp < pending_until_date)
        AND (temp->pending_temp != null))
        SET pending_until_date = temp->pending_temp
       ENDIF
     ENDFOR
     CALL echorecord(hrservreclist)
     SET rec_count = count1
   ENDFOR
   CALL clean_app_task_req(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE addreminderitems(person_id)
   DECLARE rec_id = f8
   DECLARE long_text_id = f8
   SET long_text_id = 0
   FOR (i = 1 TO rem_count)
     IF ((hrservremlist->qual[i].comment > ""))
      SELECT INTO "nl:"
       j = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        long_text_id = cnvtreal(j)
       WITH format, nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = long_text_id, lt.long_text = hrservremlist->qual[i].comment, lt
        .active_ind = 1,
        lt.active_status_cd = reqdata->active_status_cd, lt.active_status_prsnl_id = reqinfo->updt_id,
        lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
        updt_id,
        lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      next_seq_nbr = seq(pco_seq,nextval)"#################;rp0"
      FROM dual
      DETAIL
       rec_id = cnvtreal(next_seq_nbr)
      WITH nocounter
     ;end select
     IF (rec_id=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "create rec_id failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Dual"
     ENDIF
     INSERT  FROM hm_recommendation hr
      SET hr.recommendation_id = rec_id, hr.expect_id = hrservremlist->qual[i].expect_id, hr.step_id
        = hrservremlist->qual[i].step_id,
       hr.status_flag = hrservremlist->qual[i].status_flag, hr.due_dt_tm = cnvtdatetime(hrservremlist
        ->qual[i].due_dt_tm), hr.first_due_dt_tm = cnvtdatetime(hrservremlist->qual[i].
        first_due_dt_tm),
       hr.person_id = person_id, hr.updt_cnt = 0, hr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       hr.updt_id = reqinfo->updt_id, hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].action_dt_tm),
       hra.on_behalf_of_prsnl_id = hrservremlist->qual[i].on_behalf_of_prsnl_id, hra.long_text_id =
       long_text_id, hra.satisfaction_id = hrservremlist->qual[i].satisfaction_id,
       hra.satisfaction_source = hrservremlist->qual[i].satisfaction_source, hra.record_number = i,
       hra.updt_cnt = 0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].valid_start_dt_tm),
       hra.record_number = i, hra.updt_cnt = 0, hra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       hra.updt_id = reqinfo->updt_id, hra.updt_task = reqinfo->updt_task, hra.updt_applctx = reqinfo
       ->updt_applctx,
       hra.action_flag = 1
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].valid_end_dt_tm),
       hra.record_number = i, hra.updt_cnt = 0, hra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       hra.updt_id = reqinfo->updt_id, hra.updt_task = reqinfo->updt_task, hra.updt_applctx = reqinfo
       ->updt_applctx,
       hra.action_flag = 2
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].over_due_dt_tm),
       hra.record_number = i, hra.updt_cnt = 0, hra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       hra.updt_id = reqinfo->updt_id, hra.updt_task = reqinfo->updt_task, hra.updt_applctx = reqinfo
       ->updt_applctx,
       hra.action_flag = 3
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].action_dt_tm),
       hra.satisfaction_id = hrservremlist->qual[i].schedule_id, hra.record_number = i, hra.updt_cnt
        = 0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 4
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservremlist->qual[i].action_dt_tm),
       hra.satisfaction_id = hrservremlist->qual[i].series_id, hra.record_number = i, hra.updt_cnt =
       0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 5
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addrecorditems(person_id)
   DECLARE rec_id = i4
   DECLARE long_text_id = f8
   SET long_text_id = 0
   FOR (i = 1 TO rec_count)
     IF ((hrservreclist->qual[i].comment > ""))
      SELECT INTO "nl:"
       j = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        long_text_id = cnvtreal(j)
       WITH format, nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = long_text_id, lt.long_text = hrservreclist->qual[i].comment, lt
        .active_ind = 1,
        lt.active_status_cd = reqdata->active_status_cd, lt.active_status_prsnl_id = reqinfo->updt_id,
        lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
        updt_id,
        lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      next_seq_nbr = seq(pco_seq,nextval)"#################;rp0"
      FROM dual
      DETAIL
       rec_id = cnvtreal(next_seq_nbr)
      WITH nocounter
     ;end select
     IF (rec_id=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "create rec_id failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Dual"
     ENDIF
     INSERT  FROM hm_recommendation hr
      SET hr.recommendation_id = rec_id, hr.expect_id = hrservreclist->qual[i].expect_id, hr.step_id
        = hrservreclist->qual[i].step_id,
       hr.status_flag = hrservreclist->qual[i].status_flag, hr.first_due_dt_tm = cnvtdatetime(
        hrservreclist->qual[i].first_due_dt_tm), hr.person_id = person_id,
       hr.updt_cnt = 0, hr.updt_dt_tm = cnvtdatetime(curdate,curtime3), hr.updt_id = reqinfo->updt_id,
       hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservreclist->qual[i].action_dt_tm),
       hra.on_behalf_of_prsnl_id = hrservreclist->qual[i].on_behalf_of_prsnl_id, hra.long_text_id =
       long_text_id, hra.reason_cd = hrservreclist->qual[i].reason_cd,
       hra.satisfaction_id = hrservreclist->qual[i].satisfaction_id, hra.satisfaction_source =
       hrservreclist->qual[i].satisfaction_source, hra.record_number = (i+ rem_count),
       hra.updt_cnt = 0, hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->
       updt_id,
       hra.updt_task = reqinfo->updt_task, hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag
        = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservreclist->qual[i].action_dt_tm),
       hra.satisfaction_id = hrservreclist->qual[i].schedule_id, hra.record_number = (i+ rem_count),
       hra.updt_cnt = 0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 4
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservreclist->qual[i].action_dt_tm),
       hra.satisfaction_id = hrservreclist->qual[i].series_id, hra.record_number = (i+ rem_count),
       hra.updt_cnt = 0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 5
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
     INSERT  FROM hm_recommendation_action hra
      SET hra.recommendation_id = rec_id, hra.recommendation_action_id = seq(pco_seq,nextval), hra
       .action_dt_tm = cnvtdatetime(hrservreclist->qual[i].action_dt_tm),
       hra.satisfaction_id = hrservreclist->qual[i].modifier_type_cd, hra.record_number = (i+
       rem_count), hra.updt_cnt = 0,
       hra.updt_dt_tm = cnvtdatetime(curdate,curtime3), hra.updt_id = reqinfo->updt_id, hra.updt_task
        = reqinfo->updt_task,
       hra.updt_applctx = reqinfo->updt_applctx, hra.action_flag = 6
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = "insert failed"
      SET reply->status_data.subeventstatus[1].targetobjectname = "hm_recommendation_action"
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE delhrtableitems(person_id)
   DECLARE count1 = i4
   SELECT INTO "nl:"
    FROM hm_recommendation hr,
     hm_recommendation_action hra
    PLAN (hr
     WHERE hr.person_id=person_id)
     JOIN (hra
     WHERE hra.recommendation_id=hr.recommendation_id)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(hrtablelist->qual,(count1+ 9))
     ENDIF
     hrtablelist->qual[count1].long_text_id = hra.long_text_id, hrtablelist->qual[count1].
     recommendation_id = hra.recommendation_id
    WITH nocounter
   ;end select
   CALL echo(build("count1 = ",count1))
   FOR (j = 1 TO count1)
    DELETE  FROM hm_recommendation_action hma
     WHERE (hma.recommendation_id=hrtablelist->qual[j].recommendation_id)
     WITH nocounter
    ;end delete
    IF ((hrtablelist->qual[j].long_text_id > 0))
     DELETE  FROM long_text lt
      WHERE (lt.long_text_id=hrtablelist->qual[j].long_text_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDFOR
   DELETE  FROM hm_recommendation hm
    WHERE hm.person_id=person_id
     AND ((hm.expect_id+ 0) != 0)
    WITH nocounter, orahint("index( HM xie1hm_recommendation)")
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE markasincoherent(null)
   DECLARE personcnt = i4
   SET personcnt = size(personlist->qual,5)
   UPDATE  FROM hm_recommendation hr,
     (dummyt d1  WITH seq = value(personcnt))
    SET hr.due_dt_tm = null, hr.updt_dt_tm = cnvtdatetime(curdate,curtime3), hr.updt_id = reqinfo->
     updt_id,
     hr.updt_task = reqinfo->updt_task, hr.updt_applctx = reqinfo->updt_applctx, hr.updt_cnt = (hr
     .updt_cnt+ 1)
    PLAN (d1)
     JOIN (hr
     WHERE (hr.person_id=personlist->qual[d1.seq].person_id)
      AND hr.expect_id=0.0)
    WITH nocounter
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE clean_app(happ)
   IF (happ)
    CALL uar_crmendapp(happ)
    SET happ = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE clean_app_task(happ,htask)
  IF (htask)
   CALL uar_crmendtask(htask)
   SET htask = 0
  ENDIF
  CALL clean_app(happ)
 END ;Subroutine
 SUBROUTINE clean_app_task_req(happ,htask,hstep)
  IF (hstep)
   CALL uar_crmendreq(hstep)
   SET hstep = 0
  ENDIF
  CALL clean_app_task(happ,htask)
 END ;Subroutine
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE personlistsize = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE failed = i4 WITH protect, noconstant(0)
 DECLARE select_error = i4 WITH protect, constant(1)
 DECLARE server_error = i4 WITH protect, constant(2)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE locval = i4 WITH protect, noconstant(0)
 SET personlistsize = size(request->person,5)
 SET index = 1
 WHILE (index <= personlistsize)
   IF ((request->person[index].person_id > 0))
    CALL makecoherent(request->person[index].person_id)
   ENDIF
   SET index = (index+ 1)
   IF ((reply->status_data.subeventstatus[1].operationstatus="F"))
    COMMIT
    SET failed = server_error
    GO TO exit_script
   ENDIF
 ENDWHILE
 SET stat = alterlist(reply->person,personlistsize)
 FOR (x = 1 TO personlistsize)
   SET reply->person[x].person_id = request->person[x].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM hm_recommendation r,
   hm_recommendation_action ra,
   hm_expect h,
   hm_expect_series he,
   hm_expect_mod hem,
   clinical_event c,
   orders o,
   procedure p,
   prsnl pr,
   long_text l,
   encounter e1,
   encounter e2,
   encounter e3,
   person pe,
   (dummyt d  WITH seq = value(personlistsize))
  PLAN (d)
   JOIN (r
   WHERE (r.person_id=request->person[d.seq].person_id))
   JOIN (pe
   WHERE pe.person_id=r.person_id)
   JOIN (ra
   WHERE ra.recommendation_id=r.recommendation_id)
   JOIN (h
   WHERE h.expect_id=outerjoin(r.expect_id))
   JOIN (he
   WHERE he.expect_series_id=outerjoin(h.expect_series_id))
   JOIN (pr
   WHERE pr.person_id=outerjoin(ra.on_behalf_of_prsnl_id))
   JOIN (c
   WHERE c.clinical_event_id=outerjoin(ra.satisfaction_id))
   JOIN (p
   WHERE p.procedure_id=outerjoin(ra.satisfaction_id))
   JOIN (o
   WHERE o.order_id=outerjoin(ra.satisfaction_id))
   JOIN (l
   WHERE l.long_text_id=outerjoin(ra.long_text_id))
   JOIN (e1
   WHERE e1.encntr_id=outerjoin(c.encntr_id))
   JOIN (e2
   WHERE e2.encntr_id=outerjoin(o.encntr_id))
   JOIN (e3
   WHERE e3.encntr_id=outerjoin(p.encntr_id))
   JOIN (hem
   WHERE hem.expect_mod_id=outerjoin(ra.satisfaction_id))
  ORDER BY r.person_id, ra.record_number, ra.action_flag DESC
  HEAD REPORT
   clinicalevent = "CLINICAL_EVENT", ordersatisfier = "ORDER", proceduresatisfier = "PROCEDURE",
   manualsatisfier = "MODIFIER", birthdatecode = 2, gendercode = 3
  HEAD r.person_id
   recindex = 0, remindex = 0, seriesindex = 0
   IF (pe.sex_cd=null)
    reply->status_data.status_value = gendercode
   ELSEIF (pe.birth_dt_tm=0)
    reply->status_data.status_value = birthdatecode
   ENDIF
  DETAIL
   IF (r.expect_id=0)
    date = r.due_dt_tm
   ELSE
    locval = locateval(ml_idx,1,size(reply->person[d.seq].series,5),he.expect_series_name,reply->
     person[d.seq].series[ml_idx].series_mean)
    IF (locval=0)
     seriesindex = (seriesindex+ 1)
     IF (mod(seriesindex,10)=1)
      stat = alterlist(reply->person[d.seq].series,(seriesindex+ 9))
     ENDIF
     reply->person[d.seq].series[seriesindex].series_mean = he.expect_series_name
    ENDIF
    IF (r.due_dt_tm=null)
     IF (ra.action_flag=0)
      recindex = (recindex+ 1)
      IF (mod(recindex,10)=1)
       stat = alterlist(reply->person[d.seq].hmrecord,(recindex+ 9))
      ENDIF
      IF ((r.expect_id=- (1)))
       reply->person[d.seq].hmrecord[recindex].expectation_id = 0
      ELSE
       reply->person[d.seq].hmrecord[recindex].expectation_id = r.expect_id
      ENDIF
      reply->person[d.seq].hmrecord[recindex].step_id = r.step_id, reply->person[d.seq].hmrecord[
      recindex].modifier_dt_tm = ra.action_dt_tm, reply->person[d.seq].hmrecord[recindex].reason_cd
       = ra.reason_cd,
      reply->person[d.seq].hmrecord[recindex].reason_disp = uar_get_code_meaning(ra.reason_cd), reply
      ->person[d.seq].hmrecord[recindex].recorded_for_prsnl_id = ra.on_behalf_of_prsnl_id, reply->
      person[d.seq].hmrecord[recindex].recorded_for_prsnl_name = pr.name_full_formatted,
      reply->person[d.seq].hmrecord[recindex].comment = l.long_text, reply->person[d.seq].hmrecord[
      recindex].recorded_dt_tm = r.first_due_dt_tm, reply->person[d.seq].hmrecord[recindex].
      status_flag = r.status_flag
      IF (ra.satisfaction_source=clinicalevent)
       reply->person[d.seq].hmrecord[recindex].clinical_event_id = ra.satisfaction_id, reply->person[
       d.seq].hmrecord[recindex].organization_id = e1.organization_id, reply->person[d.seq].hmrecord[
       recindex].encounter_id = e1.encntr_id
      ELSEIF (ra.satisfaction_source=manualsatisfier)
       reply->person[d.seq].hmrecord[recindex].modifier_id = ra.satisfaction_id, reply->person[d.seq]
       .hmrecord[recindex].organization_id = hem.organization_id, reply->person[d.seq].hmrecord[
       recindex].encounter_id = 0
      ELSEIF (ra.satisfaction_source=ordersatisfier)
       reply->person[d.seq].hmrecord[recindex].order_id = ra.satisfaction_id, reply->person[d.seq].
       hmrecord[recindex].organization_id = e2.organization_id, reply->person[d.seq].hmrecord[
       recindex].encounter_id = e2.encntr_id
      ELSEIF (ra.satisfaction_source=proceduresatisfier)
       reply->person[d.seq].hmrecord[recindex].procedure_id = ra.satisfaction_id, reply->person[d.seq
       ].hmrecord[recindex].organization_id = e3.organization_id, reply->person[d.seq].hmrecord[
       recindex].encounter_id = e3.encntr_id
      ENDIF
     ELSEIF (ra.action_flag=4)
      reply->person[d.seq].hmrecord[recindex].schedule_id = ra.satisfaction_id
     ELSEIF (ra.action_flag=5)
      reply->person[d.seq].hmrecord[recindex].series_id = ra.satisfaction_id
     ELSEIF (ra.action_flag=6)
      reply->person[d.seq].hmrecord[recindex].modifier_type_cd = ra.satisfaction_id
     ENDIF
    ELSE
     IF (ra.action_flag=0)
      remindex = (remindex+ 1)
      IF (mod(remindex,10)=1)
       stat = alterlist(reply->person[d.seq].reminder,(remindex+ 9))
      ENDIF
      reply->person[d.seq].reminder[remindex].expectation_id = r.expect_id, reply->person[d.seq].
      reminder[remindex].step_id = r.step_id
      IF (datetimecmp(date,r.due_dt_tm)=0)
       reply->person[d.seq].reminder[remindex].recommend_due_dt_tm = sysdate
      ELSE
       reply->person[d.seq].reminder[remindex].recommend_due_dt_tm = r.due_dt_tm
      ENDIF
      reply->person[d.seq].reminder[remindex].effective_start_dt_tm = r.first_due_dt_tm, reply->
      person[d.seq].reminder[remindex].last_sat_prsnl_name = pr.name_full_formatted, reply->person[d
      .seq].reminder[remindex].last_sat_prsnl_id = pr.person_id,
      reply->person[d.seq].reminder[remindex].last_sat_comment = l.long_text, reply->person[d.seq].
      reminder[remindex].last_sat_dt_tm = ra.action_dt_tm, reply->person[d.seq].reminder[remindex].
      status_flag = r.status_flag
      IF (ra.satisfaction_source="ORG")
       reply->person[d.seq].reminder[remindex].last_sat_organization_id = ra.satisfaction_id
      ENDIF
     ELSEIF (ra.action_flag=1)
      reply->person[d.seq].reminder[remindex].valid_start_dt_tm = ra.action_dt_tm
     ELSEIF (ra.action_flag=2)
      reply->person[d.seq].reminder[remindex].valid_end_dt_tm = ra.action_dt_tm
     ELSEIF (ra.action_flag=3)
      reply->person[d.seq].reminder[remindex].over_due_dt_tm = ra.action_dt_tm
     ELSEIF (ra.action_flag=4)
      reply->person[d.seq].reminder[remindex].schedule_id = ra.satisfaction_id
     ELSEIF (ra.action_flag=5)
      reply->person[d.seq].reminder[remindex].series_id = ra.satisfaction_id
     ENDIF
    ENDIF
   ENDIF
  FOOT  r.person_id
   stat = alterlist(reply->person[d.seq].reminder,remindex), stat = alterlist(reply->person[d.seq].
    hmrecord,recindex), stat = alterlist(reply->person[d.seq].series,seriesindex)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  ROLLBACK
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=server_error)
   SET reply->status_data.subeventstatus[1].operationname = "SERVER"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Health Expectation"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF (size(reply->person,5) > 0)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "000 06/23/2006 JD3348"
END GO
