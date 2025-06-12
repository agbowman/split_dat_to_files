CREATE PROGRAM chart_section_discover_keys:dba
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
 SET log_program_name = "CHART_SECTION_DISCOVER_KEYS"
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
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE loadchartsections(null) = null
 DECLARE loadchartgroup(null) = null
 DECLARE loadchartgroupeventset(null) = null
 CALL log_message("Entering chart_section_discover_keys script",log_level_debug)
 SET reply->status_data.status = "F"
 CALL loadchartsections(null)
 CALL loadchartgroup(null)
 CALL loadchartgroupeventset(null)
 CALL error_and_zero_check(size(reply->keys,5),"Main","Zero records",1,1)
 SET reply->status_data.status = "S"
 SUBROUTINE loadchartgroup(null)
   CALL log_message("In LoadChartGroup()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ncount = i4 WITH noconstant(size(reply->keys,5)), protected
   DECLARE idx = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM chart_group cg
    WHERE cg.updt_dt_tm > cnvtdatetime(request->since)
    ORDER BY cg.chart_section_id
    HEAD REPORT
     donothing = 0
    HEAD cg.chart_section_id
     string_section_id = trim(cnvtstring(cg.chart_section_id)), section_loc = locateval(idx,1,size(
       reply->keys,5),string_section_id,reply->keys[idx].key_id)
     IF (section_loc=0)
      ncount += 1
      IF (ncount > size(reply->keys,5))
       stat = alterlist(reply->keys,(ncount+ 9))
      ENDIF
      reply->keys[ncount].changed = cg.updt_dt_tm, reply->keys[ncount].key_id = string_section_id
     ENDIF
    DETAIL
     donothing = 0
    FOOT  cg.chart_section_id
     donothing = 0
    FOOT REPORT
     stat = alterlist(reply->keys,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartGroup","Retrieving chart groups",1,0)
   CALL log_message(build("Exit LoadChartGroup(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadchartgroupeventset(null)
   CALL log_message("In LoadChartGroupEventSet()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ncount = i4 WITH noconstant(size(reply->keys,5)), protected
   FREE RECORD group_rec
   RECORD group_rec(
     1 cnt = i4
     1 qual[*]
       2 chart_group_id = f8
   )
   SELECT INTO "nl:"
    FROM chart_grp_evnt_set cges
    WHERE cges.updt_dt_tm > cnvtdatetime(request->since)
    ORDER BY cges.chart_group_id
    HEAD cges.chart_group_id
     group_rec->cnt += 1
     IF ((group_rec->cnt > size(group_rec->qual,5)))
      stat = alterlist(group_rec->qual,(group_rec->cnt+ 9))
     ENDIF
     group_rec->qual[group_rec->cnt].chart_group_id = cges.chart_group_id
    DETAIL
     donothing = 0
    FOOT  cges.chart_group_id
     stat = alterlist(group_rec->qual,group_rec->cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartGroupEventSet","Retrieving chart events",1,0)
   IF ((group_rec->cnt > 0))
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idx2 = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(group_rec->cnt)/ bind_cnt)) * bind_cnt
     )), protect
    SET stat = alterlist(group_rec->qual,noptimizedtotal)
    FOR (x = (group_rec->cnt+ 1) TO noptimizedtotal)
      SET group_rec->qual[x].chart_group_id = group_rec->qual[group_rec->cnt].chart_group_id
    ENDFOR
    SELECT INTO "nl:"
     FROM chart_group cg
     PLAN (cg
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cg.chart_group_id,group_rec->qual[idx].
       chart_group_id,
       bind_cnt))
     ORDER BY cg.chart_section_id
     HEAD cg.chart_section_id
      string_section_id = trim(cnvtstring(cg.chart_section_id)), section_loc = locateval(idx2,1,size(
        reply->keys,5),string_section_id,reply->keys[idx2].key_id)
      IF (section_loc=0)
       ncount += 1
       IF (ncount > size(reply->keys,5))
        stat = alterlist(reply->keys,(ncount+ 9))
       ENDIF
       reply->keys[ncount].changed = cg.updt_dt_tm, reply->keys[ncount].key_id = string_section_id
      ENDIF
     DETAIL
      donothing = 0
     FOOT  cg.chart_section_id
      stat = alterlist(reply->keys,ncount)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"LoadChartGroupEventSet","Retrieving chart groups",1,0)
   ENDIF
   CALL log_message(build("Exit LoadChartGroupEventSet(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadchartsections(null)
   CALL log_message("In LoadChartSections()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ncount = i4 WITH noconstant(size(reply->keys,5)), protected
   SELECT INTO "nl:"
    FROM chart_section cs
    WHERE cs.updt_dt_tm > cnvtdatetime(request->since)
    ORDER BY cs.chart_section_id
    HEAD REPORT
     donothing = 0
    DETAIL
     ncount += 1
     IF (ncount > size(reply->keys,5))
      stat = alterlist(reply->keys,(ncount+ 9))
     ENDIF
     reply->keys[ncount].changed = cs.updt_dt_tm, reply->keys[ncount].key_id = trim(cnvtstring(cs
       .chart_section_id))
    FOOT REPORT
     stat = alterlist(reply->keys,ncount)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"LoadChartSections",
    "An error occured when reading from chart_section table.  Exiting script.",1,0)
   CALL log_message(build("Exit LoadChartSections(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting chart_section_discover_keys script",log_level_debug)
END GO
