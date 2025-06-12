CREATE PROGRAM cp_get_prsnl_ident_by_ids:dba
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
 SET log_program_name = "CP_GET_PRSNL_IDENT_BY_IDS"
 IF (validate(request) != 1)
  RECORD request(
    1 qual[*]
      2 person_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 name_history[*]
        3 name_full = vc
        3 name_initials = vc
        3 name_first = vc
        3 name_last = vc
        3 name_middle = vc
        3 name_title = vc
        3 username = vc
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
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
 DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE current_date_time = q8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE getprsnlinformation(null) = null
 SET reply->status_data.status = "F"
 CALL getprsnlinformation(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getprsnlinformation(null)
   CALL log_message("In GetPrsnlInformation()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE nrecordsize = i4 WITH constant(size(request->qual,5)), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET request->qual[i].person_id = request->qual[nrecordsize].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     prsnl p,
     person_name pn,
     dummyt d2
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (p
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),p.person_id,request->qual[idx].person_id,
      bind_cnt))
     JOIN (d2)
     JOIN (pn
     WHERE pn.person_id=p.person_id
      AND pn.name_type_cd=prsnl_name_type_cd)
    ORDER BY p.person_id
    HEAD REPORT
     person_cnt = 0, found_zero_row = 0
    HEAD p.person_id
     person_cnt += 1
     IF (person_cnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(person_cnt+ 9))
     ENDIF
     reply->qual[person_cnt].person_id = p.person_id, history_cnt = 0, found_zero_row = 0
    DETAIL
     IF (found_zero_row=0)
      history_cnt += 1
      IF (history_cnt > size(reply->qual[person_cnt].name_history,5))
       stat = alterlist(reply->qual[person_cnt].name_history,(history_cnt+ 9))
      ENDIF
     ENDIF
     IF (pn.person_id > 0)
      reply->qual[person_cnt].name_history[history_cnt].name_full = trim(pn.name_full,3), reply->
      qual[person_cnt].name_history[history_cnt].name_first = pn.name_first, reply->qual[person_cnt].
      name_history[history_cnt].name_last = pn.name_last,
      reply->qual[person_cnt].name_history[history_cnt].name_middle = pn.name_middle, reply->qual[
      person_cnt].name_history[history_cnt].username = p.username, reply->qual[person_cnt].
      name_history[history_cnt].name_initials = pn.name_initials,
      reply->qual[person_cnt].name_history[history_cnt].name_title = pn.name_title, reply->qual[
      person_cnt].name_history[history_cnt].beg_effective_dt_tm = pn.beg_effective_dt_tm, reply->
      qual[person_cnt].name_history[history_cnt].end_effective_dt_tm = pn.end_effective_dt_tm
     ELSE
      IF (found_zero_row=0)
       found_zero_row = 1, reply->qual[person_cnt].name_history[history_cnt].name_full = trim(p
        .name_full_formatted,3), reply->qual[person_cnt].name_history[history_cnt].name_first = p
       .name_first,
       reply->qual[person_cnt].name_history[history_cnt].name_last = p.name_last, reply->qual[
       person_cnt].name_history[history_cnt].username = p.username, reply->qual[person_cnt].
       name_history[history_cnt].name_initials = "",
       reply->qual[person_cnt].name_history[history_cnt].name_title = "", reply->qual[person_cnt].
       name_history[history_cnt].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->qual[person_cnt]
       .name_history[history_cnt].end_effective_dt_tm = p.end_effective_dt_tm
      ENDIF
     ENDIF
    FOOT  p.person_id
     stat = alterlist(reply->qual[person_cnt].name_history,history_cnt), stat = alterlist(reply->qual,
      person_cnt)
    WITH nocounter, outerjoin = d2
   ;end select
   CALL error_and_zero_check(curqual,"PRSNL","GetPrsnlInformation",1,1)
   CALL log_message(build("Exit GetPrsnlInformation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(reply)
 ENDIF
 CALL log_message(build("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
