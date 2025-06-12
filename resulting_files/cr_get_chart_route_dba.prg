CREATE PROGRAM cr_get_chart_route:dba
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 chart_route_id = f8
     2 route_name = vc
     2 route_name_key = vc
     2 route_type_flag = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 banner_page_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE where_clause = vc WITH noconstant("")
 SET reply->status_data.status = "F"
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
 SET log_program_name = "CR_GET_CHART_ROUTE"
 CALL log_message("Starting script: cr_get_chart_route",log_level_debug)
 IF ((request->chart_route_id > 0))
  SET stat = alterlist(request->chart_routes,1)
  SET request->chart_routes[1].chart_route_id = request->chart_route_id
 ENDIF
 IF (size(request->chart_routes,5) > 0)
  SET where_clause = "c.chart_route_id = request->chart_routes[d.seq].chart_route_id"
  IF ((request->route_type_flag > 0))
   SET where_clause = build(where_clause," and c.route_type_flag+0 = ",request->route_type_flag)
  ENDIF
 ELSEIF ((request->route_type_flag > 0))
  SET where_clause = build("c.route_type_flag = ",request->route_type_flag)
 ELSE
  SET where_clause = "0=0"
 ENDIF
 CALL echo(where_clause)
 SELECT INTO "nl:"
  FROM chart_route c,
   (dummyt d  WITH seq = value(size(request->chart_routes,5)))
  PLAN (d)
   JOIN (c
   WHERE parser(where_clause)
    AND c.active_ind=1)
  ORDER BY c.route_name
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].chart_route_id = c.chart_route_id, reply->qual[cnt].route_name = c.route_name,
   reply->qual[cnt].route_name_key = c.route_name_key,
   reply->qual[cnt].route_type_flag = c.route_type_flag, reply->qual[cnt].updt_cnt = c.updt_cnt,
   reply->qual[cnt].active_ind = c.active_ind,
   reply->qual[cnt].banner_page_ind = c.banner_page_ind
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  CALL log_message("Zero groups returned.",log_level_debug)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  CALL log_message("Groups successfully returned.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 CALL log_message("End of script: cr_get_chart_route",log_level_debug)
END GO
