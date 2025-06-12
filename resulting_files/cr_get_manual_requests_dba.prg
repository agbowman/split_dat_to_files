CREATE PROGRAM cr_get_manual_requests:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CR_GET_MANUAL_REQUESTS"
 IF (validate(request) != 1)
  RECORD request(
    1 ids[*]
      2 expedite_manual_id = f8
    1 order_ids[*]
      2 order_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 expedite_manual_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = vc
      2 output_dest_cd = f8
      2 output_device_cd = f8
      2 provider_id = f8
      2 provider_role_cd = f8
      2 chart_content_flag = i2
      2 chart_format_id = f8
      2 device_name = vc
      2 output_dest_name = vc
      2 scope_flag = i2
      2 event_ind = i2
      2 rrd_deliver_dt_tm = dq8
      2 rrd_phone_suffix = vc
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 date_range_ind = i2
      2 template_id = f8
      2 user_role_profile = vc
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 copies_nbr = i4
      2 dms_service_identifier = vc
      2 sending_org_id = f8
      2 prsnl_role_profile_uid = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE retrieveallmanualexpedites(null) = null
 DECLARE retrievemanualexpeditesbyids(null) = null
 DECLARE retrievemanualexpeditesbyorderids(null) = null
 CALL log_message(build("Begin script: ",log_program_name),log_level_debug)
 SET reply->status_data.status = "F"
 IF (size(request->ids,5) > 0)
  CALL retrievemanualexpeditesbyids(null)
 ELSEIF (size(request->order_ids,5) > 0)
  CALL retrievemanualexpeditesbyorderids(null)
 ELSE
  CALL retrieveallmanualexpedites(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE retrievemanualexpeditesbyids(null)
   CALL log_message("In RetrieveManualExpeditesByIds()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->ids,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->ids,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->ids[i].expedite_manual_id = request->ids[nrecordsize].expedite_manual_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     expedite_manual em
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (em
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),em.expedite_manual_id,request->ids[idx].
      expedite_manual_id,
      bind_cnt))
    HEAD REPORT
     ncount = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncount+ 9))
     ENDIF
     CALL addmanualrequesttoreply(ncount)
    FOOT REPORT
     stat = alterlist(reply->qual,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"EXPEDITE_MANUAL","RetrieveManualExpeditesByIds",1,1)
   CALL log_message(build("Exit RetrieveManualExpeditesByIds(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievemanualexpeditesbyorderids(null)
   CALL log_message("In RetrieveManualExpeditesByOrderIds()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->order_ids,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->order_ids,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->order_ids[i].order_id = request->order_ids[nrecordsize].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     expedite_manual em
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (em
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),em.order_id,request->order_ids[idx].
      order_id,
      bind_cnt)
      AND em.order_id > 0)
    HEAD REPORT
     ncount = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncount+ 9))
     ENDIF
     CALL addmanualrequesttoreply(ncount)
    FOOT REPORT
     stat = alterlist(reply->qual,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"EXPEDITE_MANUAL","RetrieveManualExpeditesByOrderIds",1,1)
   CALL log_message(build("Exit RetrieveManualExpeditesByOrderIds(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveallmanualexpedites(null)
   CALL log_message("In RetrieveAllManualExpedites()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM expedite_manual em
    PLAN (em
     WHERE em.expedite_manual_id > 0)
    HEAD REPORT
     ncount = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncount+ 9))
     ENDIF
     CALL addmanualrequesttoreply(ncount)
    FOOT REPORT
     stat = alterlist(reply->qual,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"EXPEDITE_MANUAL","RetrieveAllManualExpedites",1,1)
   CALL log_message(build("Exit RetrieveAllManualExpedites(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addmanualrequesttoreply(qual_seq=i4(val)) =null)
   SET reply->qual[qual_seq].expedite_manual_id = em.expedite_manual_id
   SET reply->qual[qual_seq].accession_nbr = em.accession
   SET reply->qual[qual_seq].begin_dt_tm = em.begin_dt_tm
   SET reply->qual[qual_seq].chart_content_flag = em.chart_content_flag
   SET reply->qual[qual_seq].chart_format_id = em.chart_format_id
   SET reply->qual[qual_seq].date_range_ind = em.date_range_ind
   SET reply->qual[qual_seq].device_name = em.device_name
   SET reply->qual[qual_seq].encntr_id = em.encntr_id
   SET reply->qual[qual_seq].end_dt_tm = em.end_dt_tm
   SET reply->qual[qual_seq].event_ind = em.event_ind
   IF (em.provider_id != 0)
    SET reply->qual[qual_seq].provider_id = em.provider_id
   ELSE
    SET reply->qual[qual_seq].provider_id = em.updt_id
   ENDIF
   SET reply->qual[qual_seq].order_id = em.order_id
   SET reply->qual[qual_seq].output_dest_cd = em.output_dest_cd
   SET reply->qual[qual_seq].output_dest_name = em.output_dest_name
   SET reply->qual[qual_seq].output_device_cd = em.output_device_cd
   SET reply->qual[qual_seq].person_id = em.person_id
   SET reply->qual[qual_seq].provider_role_cd = em.provider_role_cd
   SET reply->qual[qual_seq].rrd_deliver_dt_tm = em.rrd_deliver_dt_tm
   SET reply->qual[qual_seq].rrd_phone_suffix = em.rrd_phone_suffix
   SET reply->qual[qual_seq].scope_flag = em.scope_flag
   SET reply->qual[qual_seq].template_id = em.template_id
   SET reply->qual[qual_seq].user_role_profile = em.user_role_profile
   SET reply->qual[qual_seq].updt_dt_tm = em.updt_dt_tm
   SET reply->qual[qual_seq].updt_id = em.updt_id
   SET reply->qual[qual_seq].copies_nbr = em.copies_nbr
   SET reply->qual[qual_seq].dms_service_identifier = em.dms_service_identifier
   SET reply->qual[qual_seq].sending_org_id = em.sending_org_id
   SET reply->qual[qual_seq].prsnl_role_profile_uid = trim(validate(em.prsnl_role_profile_uid,""))
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=0)
  FREE RECORD provider_rec
 ENDIF
 CALL log_message(build("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
