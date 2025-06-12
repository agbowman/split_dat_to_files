CREATE PROGRAM chart_format_lookup_keys:dba
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
 SET log_program_name = "CHART_FORMAT_LOOKUP_KEYS"
 FREE RECORD reply
 RECORD reply(
   1 keys[*]
     2 key_id = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 cnt = i4
   1 qual[*]
     2 chart_format_id = f8
 )
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE preparetemprec(null) = null
 DECLARE loadchartformats(null) = null
 DECLARE loadchartformsects(null) = null
 CALL log_message("Entering chart_format_lookup_keys script",log_level_debug)
 SET reply->status_data.status = "F"
 CALL preparetemprec(null)
 CALL loadchartformats(null)
 CALL loadchartformsects(null)
 CALL error_and_zero_check(size(reply->keys,5),"Main","Zero check",1,1)
 SET reply->status_data.status = "S"
 SUBROUTINE preparetemprec(null)
   CALL log_message("In PrepareTempRec()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE noptimizedtotal = i4 WITH noconstant(0)
   DECLARE nrecordsize = i4 WITH noconstant(0)
   SET temp_rec->cnt = size(request->keys,5)
   SET stat = alterlist(temp_rec->qual,temp_rec->cnt)
   FOR (x = 1 TO temp_rec->cnt)
     SET temp_rec->qual[x].chart_format_id = cnvtreal(request->keys[x].key_id)
   ENDFOR
   SET nrecordsize = temp_rec->cnt
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(temp_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET temp_rec->qual[i].chart_format_id = temp_rec->qual[nrecordsize].chart_format_id
   ENDFOR
   CALL log_message(build("Exit PrepareTempRec(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadchartformats(null)
   CALL log_message("In LoadChartFormats()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ncount = i4 WITH noconstant(size(reply->keys,5)), protected
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(temp_rec->cnt)/ bind_cnt)) * bind_cnt)),
   protect
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_format cf
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cf
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cf.chart_format_id,temp_rec->qual[idx].
      chart_format_id,
      bind_cnt))
    ORDER BY cf.chart_format_id
    HEAD REPORT
     donothing = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->keys,5))
      stat = alterlist(reply->keys,(ncount+ 9))
     ENDIF
     reply->keys[ncount].changed = cf.updt_dt_tm, reply->keys[ncount].key_id = trim(cnvtstring(cf
       .chart_format_id))
    FOOT REPORT
     stat = alterlist(reply->keys,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartFormats","Reading chart_format table.",1,0)
   CALL log_message(build("Exit LoadChartFormats(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadchartformsects(null)
   CALL log_message("In LoadChartFormSects()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ncount = i4 WITH noconstant(size(reply->keys,5)), protected
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(temp_rec->cnt)/ bind_cnt)) * bind_cnt)),
   protect
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_form_sects cfs
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (cfs
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cfs.chart_format_id,temp_rec->qual[idx].
      chart_format_id,
      bind_cnt))
    ORDER BY cfs.chart_format_id
    HEAD REPORT
     donothing = 0
    HEAD cfs.chart_format_id
     string_format_id = trim(cnvtstring(cfs.chart_format_id)), format_loc = locateval(idx,1,size(
       reply->keys,5),string_format_id,reply->keys[idx].key_id)
     IF (format_loc=0)
      ncount += 1
      IF (ncount > size(reply->keys,5))
       stat = alterlist(reply->keys,(ncount+ 9))
      ENDIF
      reply->keys[ncount].changed = cfs.updt_dt_tm, reply->keys[ncount].key_id = trim(cnvtstring(cfs
        .chart_format_id))
     ELSEIF ((reply->keys[format_loc].changed < cnvtdatetime(cfs.updt_dt_tm)))
      reply->keys[format_loc].changed = cnvtdatetime(cfs.updt_dt_tm)
     ENDIF
    DETAIL
     donothing = 0
    FOOT REPORT
     stat = alterlist(reply->keys,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartFormSects","Reading from chart_form_sects table.",1,0)
   CALL log_message(build("Exit LoadChartFormSects(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting chart_format_lookup_keys script",log_level_debug)
 CALL echorecord(reply)
END GO
