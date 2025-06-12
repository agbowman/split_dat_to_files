CREATE PROGRAM cr_get_related_accessions:dba
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
 SET log_program_name = "cr_get_related_accessions"
 IF (validate(request) != 1)
  FREE RECORD request
  RECORD request(
    1 person_id = f8
    1 encounters[*]
      2 encntr_id = f8
    1 accession = vc
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 accessions[*]
      2 accession_nbr = vc
      2 orderable_name = vc
      2 event_end_dt_tm = dq8
      2 order_status = vc
      2 order_id = f8
      2 encntr_id = f8
      2 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE getaccessioninfo(null) = null
 DECLARE getaccessioninfobyacc(null) = null
 DECLARE getorderinfo(null) = null
 SET reply->status_data.status = "F"
 IF ((request->person_id=0))
  CALL getaccessioninfobyacc(null)
 ELSE
  CALL getaccessioninfo(null)
 ENDIF
 CALL getorderinfo(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getaccessioninfobyacc(null)
   CALL log_message("In GetAccessionInfoByAcc()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT DISTINCT INTO "nl:"
    c.accession_nbr, c.order_id, c.encntr_id,
    c.event_end_dt_tm
    FROM clinical_event c,
     ce_event_order_link ceol
    PLAN (c
     WHERE (c.accession_nbr=request->accession)
      AND c.valid_until_dt_tm > cnvtdatetime(current_date_time)
      AND c.view_level=1
      AND c.accession_nbr != "")
     JOIN (ceol
     WHERE (ceol.event_id= Outerjoin(c.event_id))
      AND (ceol.valid_until_dt_tm> Outerjoin(cnvtdatetime(current_date_time))) )
    ORDER BY c.accession_nbr, c.event_end_dt_tm, c.order_id,
     ceol.order_id
    HEAD REPORT
     counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,10)=1)
      stat = alterlist(reply->accessions,(counter+ 9))
     ENDIF
     reply->accessions[counter].accession_nbr = c.accession_nbr, reply->accessions[counter].
     event_end_dt_tm = c.event_end_dt_tm, reply->accessions[counter].encntr_id = c.encntr_id,
     reply->accessions[counter].person_id = c.person_id
     IF (ceol.order_id > 0.0)
      reply->accessions[counter].order_id = ceol.order_id
     ELSE
      reply->accessions[counter].order_id = c.order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->accessions,counter)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GETACCESSIONINFO","cr_get_related_accessions",1,1)
   CALL log_message(build("Exit GetAccessionInfo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getaccessioninfo(null)
   CALL log_message("In GetAccessionInfo()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->encounters,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->encounters,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->encounters[i].encntr_id = request->encounters[nrecordsize].encntr_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    c.accession_nbr, c.order_id, c.encntr_id,
    c.event_end_dt_tm
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event c,
     ce_event_order_link ceol
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (c
     WHERE (c.person_id=request->person_id)
      AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),c.encntr_id,request->encounters[idx].
      encntr_id,
      bind_cnt)
      AND trim(c.accession_nbr) > ""
      AND c.valid_until_dt_tm > cnvtdatetime(current_date_time)
      AND c.view_level=1)
     JOIN (ceol
     WHERE (ceol.event_id= Outerjoin(c.event_id))
      AND (ceol.valid_until_dt_tm> Outerjoin(cnvtdatetime(current_date_time))) )
    ORDER BY c.accession_nbr, c.event_end_dt_tm, c.order_id,
     ceol.order_id
    HEAD REPORT
     counter = 0
    DETAIL
     counter += 1
     IF (mod(counter,10)=1)
      stat = alterlist(reply->accessions,(counter+ 9))
     ENDIF
     reply->accessions[counter].accession_nbr = c.accession_nbr, reply->accessions[counter].
     event_end_dt_tm = c.event_end_dt_tm, reply->accessions[counter].encntr_id = c.encntr_id,
     reply->accessions[counter].person_id = request->person_id
     IF (ceol.order_id > 0.0)
      reply->accessions[counter].order_id = ceol.order_id
     ELSE
      reply->accessions[counter].order_id = c.order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->accessions,counter)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GETACCESSIONINFO","cr_get_related_accessions",1,1)
   CALL log_message(build("Exit GetAccessionInfo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getorderinfo(null)
   CALL log_message("In GetOrderInfo()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE replyreccnt = i4 WITH constant(size(reply->accessions,5)), protect
   SELECT INTO "nl:"
    o.hna_order_mnemonic
    FROM orders o,
     (dummyt d  WITH seq = value(replyreccnt))
    PLAN (d
     WHERE (reply->accessions[d.seq].order_id > 0))
     JOIN (o
     WHERE (o.order_id=reply->accessions[d.seq].order_id))
    DETAIL
     reply->accessions[d.seq].orderable_name = o.hna_order_mnemonic, reply->accessions[d.seq].
     order_status = uar_get_code_display(o.order_status_cd)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GETORDERINFO","cr_get_related_accessions",1,0)
   CALL log_message(build("Exit GetOrderInfo(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cr_get_related_accessions",log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
 IF (validate(debug_ind,0))
  CALL echorecord(reply)
 ENDIF
END GO
