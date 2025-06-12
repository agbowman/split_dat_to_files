CREATE PROGRAM cp_br_del_components_json:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Node Id" = 0.0,
  "Component Type Code List" = ""
  WITH outdev, nodeid, comptypelist
 FREE RECORD components_json
 RECORD components_json(
   1 component_type_code_list[*]
     2 type_code = vc
     2 comp_id = f8
 )
 FREE RECORD comp_del_request
 RECORD comp_del_request(
   1 cp_node_id = f8
   1 node_display = vc
   1 keep_node_behaviors = i2
   1 qual[*]
     2 comp_display = vc
     2 cp_component_id = f8
     2 comp_type_cd = f8
     2 bedrock_wizard_ind = i4
     2 report_mean = vc
 )
 FREE RECORD comp_del_reply
 RECORD comp_del_reply(
   1 cp_node_id = f8
   1 component_list[*]
     2 comp_type_cd = f8
     2 cp_component_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD mpagereply
 RECORD mpagereply(
   1 component_list[*]
     2 cp_node_id = f8
     2 comp_type_cd = f8
     2 cp_component_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
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
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
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
 IF ( NOT (validate(mp_common_output_imported)))
  EXECUTE mp_common_output
 ENDIF
 DECLARE verifyinputs(null) = null WITH protect
 DECLARE deleterows(null) = i2 WITH protect
 DECLARE comp_type_cd_codeset = i4 WITH constant(4003130), protect
 DECLARE nodeid = f8 WITH constant( $NODEID), protect
 DECLARE compid = f8 WITH noconstant(0.0), protect
 DECLARE json_str = vc WITH noconstant(trim( $COMPTYPELIST,3)), protect
 DECLARE compcntr = i4 WITH noconstant(0), protect
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 DECLARE current_date_time2 = dq8 WITH constant(curtime3), private
 SET mpagereply->status_data.status = "F"
 CALL verifyinputs(null)
 CALL deleterows(null)
 SET mpagereply->status_data.status = "S"
 SUBROUTINE verifyinputs(null)
   CALL log_message("In verifyInputs()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   IF (nodeid <= 0)
    CALL reporterrorandexit("PERFORM","Validate","Component list must be nonzero in size.")
   ENDIF
   SELECT INTO "NL:"
    FROM cp_node cn
    WHERE cn.cp_node_id=nodeid
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL reporterrorandexit("PERFORM","Validate","cp_node_id is invalid.")
   ENDIF
   CALL log_message(build("Exit verifyInputs(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE deleterows(null)
   CALL log_message("In deleteRows()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET iscomptypelistjson = cnvtjsontorec(json_str)
   DECLARE comp_type_cd_codeset = i4 WITH constant(4003130), protect
   DECLARE complistsize = i4 WITH protect, noconstant(0)
   IF (iscomptypelistjson=1)
    SET complistsize = size(components_json->component_type_code_list,5)
    SET comp_del_request->cp_node_id = nodeid
    SET stat = alterlist(comp_del_request->qual,complistsize)
    FOR (compcntr = 1 TO complistsize)
     SET comp_del_request->qual[compcntr].cp_component_id = components_json->
     component_type_code_list[compcntr].comp_id
     SET comp_del_request->qual[compcntr].comp_type_cd = uar_get_code_by("MEANING",
      comp_type_cd_codeset,components_json->component_type_code_list[compcntr].type_code)
    ENDFOR
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(comp_del_request)
   ENDIF
   EXECUTE cp_br_del_component
   IF (validate(debug_ind,0)=1)
    CALL echorecord(comp_del_reply)
   ENDIF
   IF (size(comp_del_reply->component_list,5) > 0)
    SET stat = alterlist(mpagereply->component_list,size(comp_del_reply->component_list,5))
    FOR (x = 1 TO size(comp_del_reply->component_list,5))
      SET mpagereply->component_list[x].comp_type_cd = comp_del_reply->component_list[x].comp_type_cd
      SET mpagereply->component_list[x].cp_component_id = comp_del_reply->component_list[x].
      cp_component_id
      SET mpagereply->component_list[x].cp_node_id = comp_del_reply->cp_node_id
    ENDFOR
    SET mpagereply->status_data.status = comp_del_reply->status_data.status
    SET mpagereply->status_data.subeventstatus[1].operationname = comp_del_reply->status_data.
    subeventstatus[1].operationname
    SET mpagereply->status_data.subeventstatus[1].operationstatus = comp_del_reply->status_data.
    subeventstatus[1].operationstatus
    SET mpagereply->status_data.subeventstatus[1].targetobjectname = comp_del_reply->status_data.
    subeventstatus[1].targetobjectname
    SET mpagereply->status_data.subeventstatus[1].targetobjectvalue = comp_del_reply->status_data.
    subeventstatus[1].targetobjectvalue
   ENDIF
   CALL log_message(build("Exit deleteRows(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (reporterrorandexit(operationname=vc,targetobjectname=vc,targetobjectvalue=vc) =null
  WITH protect)
   CALL log_message("In reportErrorAndExit()",log_level_debug)
   CALL reporterror(operationname,targetobjectname,targetobjectvalue)
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE (reporterror(operationname=vc,targetobjectname=vc,targetobjectvalue=vc) =null WITH
  protect)
   CALL log_message("In reportError()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET mpagereply->status_data.status = "F"
   SET mpagereply->status_data.subeventstatus.operationname = operationname
   SET mpagereply->status_data.subeventstatus.operationstatus = "F"
   SET mpagereply->status_data.subeventstatus.targetobjectname = targetobjectname
   SET mpagereply->status_data.subeventstatus.targetobjectvalue = targetobjectvalue
   CALL log_message(build("Exit reportError(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(mpagereply)
 ENDIF
 CALL putjsonrecordtofile(mpagereply, $OUTDEV)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - current_date_time2)/ 100.0)),
  log_level_debug)
END GO
