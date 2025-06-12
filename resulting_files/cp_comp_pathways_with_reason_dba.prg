CREATE PROGRAM cp_comp_pathways_with_reason:dba
 PROMPT
  "Pathways JSON" = ""
  WITH pathways_json
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
 DECLARE reserved_chars_size = i4 WITH protect, noconstant(4)
 DECLARE str_reservedchars[4] = c1 WITH protect, noconstant("-","_",".","~")
 DECLARE encoded_chars_size = i4 WITH protect, constant(9)
 DECLARE newlinechars = vc WITH protect, constant(concat(concat(char(13),char(10))))
 DECLARE str_encodedchars[9] = c1 WITH protect, noconstant("\","/","'",'"',"<",
  "~","^","&","#")
 DECLARE str_encodedcharsstr[9] = c3 WITH protect, noconstant("%5C","%2F","%27","%22","%3C",
  "%7E","%5E","%26","%23")
 SUBROUTINE (str_isunreservedchar(character=vc) =i2)
   DECLARE ord = i4 WITH protect, constant(ichar(character))
   IF (ord >= 48
    AND ord <= 57)
    RETURN(1)
   ENDIF
   IF (ord >= 65
    AND ord <= 90)
    RETURN(1)
   ENDIF
   IF (ord >= 97
    AND ord <= 122)
    RETURN(1)
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO reserved_chars_size)
     IF (ord=ichar(str_reservedchars[i]))
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (str_charat(input=vc,pos=i4) =vc)
   RETURN(notrim(substring(pos,1,input)))
 END ;Subroutine
 SUBROUTINE (str_encodechar(character=vc) =vc)
   RETURN(build2chk("%",notrim(cnvtrawhex(character))))
 END ;Subroutine
 SUBROUTINE (str_decodechar(charstr=vc) =vc)
  DECLARE hexstr = vc WITH protect, noconstant(substring(2,2,charstr))
  RETURN(notrim(cnvthexraw(hexstr)))
 END ;Subroutine
 SUBROUTINE (str_decodeuri(uri=vc) =vc)
   DECLARE result = vc WITH protect
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE curchar = vc WITH protect, noconstant("")
   DECLARE todecode = vc WITH protect, noconstant("")
   FOR (i = 1 TO textlen(uri))
    SET curchar = notrim(str_charat(uri,i))
    IF (curchar="%")
     SET todecode = "%"
    ELSEIF (todecode != "")
     SET todecode = build2chk(todecode,curchar)
     IF (textlen(todecode)=3)
      SET result = notrim(build2chk(result,notrim(str_decodechar(todecode))))
      SET todecode = ""
     ENDIF
    ELSE
     SET result = notrim(build2chk(result,curchar))
    ENDIF
   ENDFOR
   RETURN(nullterm(result))
 END ;Subroutine
 SUBROUTINE (str_encodeuri(uri=vc) =vc)
   DECLARE result = vc WITH protect
   DECLARE curchar = vc WITH protect, noconstant("")
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO textlen(uri))
    SET curchar = notrim(str_charat(uri,i))
    IF (str_isunreservedchar(curchar)=0)
     SET result = build2chk(result,str_encodechar(notrim(curchar)))
    ELSE
     SET result = build2chk(result,curchar)
    ENDIF
   ENDFOR
   RETURN(nullterm(result))
 END ;Subroutine
 SUBROUTINE (str_isctrlchar(char=vc) =i2)
   DECLARE ord = i4 WITH protect, constant(ichar(char))
   IF (((ord > 0
    AND ord < 10) OR (((ord >= 11
    AND ord <= 12) OR (ord >= 14
    AND ord <= 31)) )) )
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (str_decodestring(uri=vc) =vc)
   DECLARE result = vc WITH protect, noconstant("")
   SET result = uri
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO encoded_chars_size)
     SET result = notrim(replace(result,str_encodedcharsstr[i],str_encodedchars[i],0))
   ENDFOR
   SET result = notrim(replace(result,"%0A%0D",newlinechars,0))
   SET result = notrim(replace(result,"%0D%0A",newlinechars,0))
   SET result = notrim(replace(result,"%0A",newlinechars,0))
   SET result = notrim(replace(result,"%0D",newlinechars,0))
   SET result = notrim(replace(result,"%25","%",0))
   RETURN(result)
 END ;Subroutine
 SUBROUTINE (str_encodestring(uri=vc) =vc)
   DECLARE result = vc WITH protect
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE isctrl = i2 WITH protect, noconstant(0)
   DECLARE curchar = vc WITH protect, noconstant("")
   FOR (i = 1 TO textlen(uri))
     SET curchar = notrim(str_charat(uri,i))
     SET isctrl = str_isctrlchar(curchar)
     IF (isctrl != 1)
      SET result = notrim(build2chk(result,curchar))
     ENDIF
   ENDFOR
   SET result = notrim(replace(result,"%","%25",0))
   FOR (i = 1 TO encoded_chars_size)
     SET result = notrim(replace(result,str_encodedchars[i],str_encodedcharsstr[i],0))
   ENDFOR
   SET result = notrim(replace(result,newlinechars,"%0D%0A",0))
   RETURN(nullterm(result))
 END ;Subroutine
 DECLARE script_start_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE pid = f8 WITH constant(trigger_personid), protect
 DECLARE eid = f8 WITH constant(trigger_encntrid), protect
 DECLARE prsnl_id = f8 WITH constant(reqinfo->updt_id), protect
 DECLARE pathways_json = vc WITH constant( $PATHWAYS_JSON), protect
 DECLARE sys_auto_complete_mean = vc WITH constant("SYSPWCOMP"), protect
 DECLARE cur_dt_tm = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE encntr_discharge_type_mean = vc WITH constant("ENCOUNTER_TYPE_DISCHARGE"), protect
 DECLARE complete_by_enc_type_disch_mean = vc WITH constant("COMPBYDISCH"), protect
 FREE RECORD actionreq
 RECORD actionreq(
   1 actions[*]
     2 pathway_instance_id = f8
     2 cp_node_id = f8
     2 encntr_id = f8
     2 cp_component_id = f8
     2 prsnl_id = f8
     2 treatment_line_cd = f8
     2 action_type_mean = vc
     2 action_dt_tm = dq8
     2 details[*]
       3 action_detail_entity_name = vc
       3 action_detail_entity_id = f8
       3 action_detail_text = vc
       3 action_detail_entity_text = vc
       3 cp_action_detail_type_mean = vc
 ) WITH protect
 FREE RECORD reply_record
 RECORD reply_record(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SUBROUTINE main(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   DECLARE pathwaycntr = i4 WITH protect
   DECLARE completedpathwaynames = vc WITH noconstant(""), protect
   DECLARE cur_pathway_instance_id = f8 WITH noconstant(0), protect
   CALL log_message("start main()",log_level_debug)
   SET reply_record->status_data.status = "F"
   IF (textlen(pathways_json) > 0)
    SET stat = cnvtjsontorec(pathways_json)
    IF ((pathwaystoautocomplete->cnt > 0))
     IF (validate(debug_ind))
      CALL echorecord(pathwaystoautocomplete)
     ENDIF
     FOR (pathwaycntr = 1 TO pathwaystoautocomplete->cnt)
       SET cur_pathway_instance_id = pathwaystoautocomplete->qual[pathwaycntr].pathway_instance_id
       SET trace = recpersist
       EXECUTE cp_add_pathway_activity:dba "NOFORMS", pid, eid,
       reqinfo->updt_id, pathwaystoautocomplete->qual[pathwaycntr].cp_pathway_id, "COMPLETE",
       value(cur_pathway_instance_id), 1 WITH replace("MPAGEREPLY","ACTIVITYREPLY")
       SET trace = norecpersist
       IF (validate(debug_ind))
        CALL echorecord(activityreply)
       ENDIF
       IF ((activityreply->status_data.status="S")
        AND cur_pathway_instance_id > 0)
        SET stat = initrec(actionreq)
        SET stat = alterlist(actionreq->actions,1)
        SET actionreq->actions[1].pathway_instance_id = cur_pathway_instance_id
        SET actionreq->actions[1].encntr_id = eid
        SET actionreq->actions[1].prsnl_id = prsnl_id
        SET actionreq->actions[1].action_type_mean = sys_auto_complete_mean
        SET actionreq->actions[1].action_dt_tm = cur_dt_tm
        SET stat = alterlist(actionreq->actions[1].details,1)
        IF ((pathwaystoautocomplete->qual[pathwaycntr].triggering_criteria_group_mean=
        encntr_discharge_type_mean))
         SET actionreq->actions[1].details[1].cp_action_detail_type_mean =
         complete_by_enc_type_disch_mean
        ENDIF
        SET actionreq->actions[1].details[1].action_detail_text = pathwaystoautocomplete->qual[
        pathwaycntr].triggering_entity_disp
        SET actionreq->actions[1].details[1].action_detail_entity_name = pathwaystoautocomplete->
        qual[pathwaycntr].triggering_entity_name
        SET actionreq->actions[1].details[1].action_detail_entity_id = pathwaystoautocomplete->qual[
        pathwaycntr].triggering_entity_id
        IF (validate(debug_ind))
         CALL echorecord(actionreq)
        ENDIF
        EXECUTE cp_add_pathway_action "NOFORMS", "" WITH replace("ACTIONREQ","ACTIONREQ"), replace(
         "MPAGEREPLY","ACTIONREPLY")
        IF (validate(debug_ind))
         CALL echorecord(actionreply)
        ENDIF
        IF ((actionreply->status_data.status="S"))
         IF (completedpathwaynames="")
          SET completedpathwaynames = str_decodeuri(pathwaystoautocomplete->qual[pathwaycntr].
           pathway_name)
         ELSE
          SET completedpathwaynames = build2(completedpathwaynames,", ",str_decodeuri(
            pathwaystoautocomplete->qual[pathwaycntr].pathway_name))
         ENDIF
        ELSE
         CALL log_message(" Failure in cp_add_pathway_action script ",log_level_debug)
         SET log_misc1 = ""
         SET retval = 0
         SET reqinfo->commit_ind = 0
         GO TO exit_script
        ENDIF
       ELSE
        CALL log_message(" Failure in cp_add_pathway_activity script ",log_level_debug)
        SET log_misc1 = ""
        SET retval = 0
        SET reqinfo->commit_ind = 0
        GO TO exit_script
       ENDIF
     ENDFOR
     IF (completedpathwaynames > " ")
      SET log_misc1 = build("Completing Care Pathway(s): ",completedpathwaynames)
      SET retval = 100
      SET reqinfo->commit_ind = 1
     ELSE
      SET log_misc1 = "No Care Pathways completed"
      SET retval = 0
     ENDIF
    ELSE
     CALL log_message(build("Found ",cnvtstring(pathwaystoautocomplete->cnt),
       " pathways; cannot complete."),log_level_debug)
     SET log_misc1 = ""
     SET retval = 0
     GO TO exit_script
    ENDIF
   ELSE
    CALL log_message(build("Invalid input parameter."),log_level_debug)
    SET log_misc1 = ""
    SET retval = 0
    GO TO exit_script
   ENDIF
   SET reply_record->status_data.status = "S"
   CALL log_message(build("exit main, elapsed time in seconds:",((curtime3 - start_tm)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 CALL main(null)
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
END GO
