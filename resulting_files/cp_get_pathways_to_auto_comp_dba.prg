CREATE PROGRAM cp_get_pathways_to_auto_comp:dba
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
 DECLARE cur_encntr_type_cd = f8 WITH noconstant(0), protect
 DECLARE eid = f8 WITH constant(trigger_encntrid), protect
 DECLARE active_pw_status_cd = f8 WITH constant(uar_get_code_by("MEANING",4003198,"ACTIVE")), protect
 DECLARE active_act_status_cd = f8 WITH constant(uar_get_code_by("MEANING",4003352,"ACTIVE")),
 protect
 DECLARE script_start_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE encntr_discharge_type_mean = vc WITH constant("ENCOUNTER_TYPE_DISCHARGE"), protect
 DECLARE main(null) = null
 DECLARE getcurrentencountertype(null) = null
 DECLARE buildpathwaystoautocomplete(null) = null
 FREE RECORD pathwaystoautocomplete
 RECORD pathwaystoautocomplete(
   1 cnt = i4
   1 qual[*]
     2 cp_pathway_id = f8
     2 pathway_name = vc
     2 pathway_instance_id = f8
     2 triggering_entity_id = f8
     2 triggering_entity_disp = vc
     2 triggering_entity_name = vc
     2 triggering_criteria_group_mean = vc
     2 triggering_criteria_ident = vc
     2 criteria_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SUBROUTINE main(null)
   CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
   CALL getcurrentencountertype(null)
   CALL buildpathwaystoautocomplete(null)
   SET log_misc1 = cnvtrectojson(pathwaystoautocomplete)
   IF ((pathwaystoautocomplete->cnt > 0))
    SET retval = 100
   ENDIF
 END ;Subroutine
 SUBROUTINE getcurrentencountertype(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("start getCurrentEncounterType ()",log_level_debug)
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=eid)
    DETAIL
     cur_encntr_type_cd = e.encntr_type_cd
    WITH nocounter
   ;end select
   IF (validate(debug_ind))
    CALL echo(build(" cur_encntr_type_cd ---> ",cur_encntr_type_cd))
   ENDIF
   CALL log_message(build("exit getCurrentEncounterType, elapsed time in seconds:",((curtime3 -
     start_tm)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildpathwaystoautocomplete(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("start buildPathwaysToAutoComplete ()",log_level_debug)
   SELECT INTO "nl:"
    FROM cp_pathway_activity cpa,
     cp_triggering_criteria ctc,
     cp_pathway cp
    PLAN (cpa
     WHERE cpa.encntr_id=eid
      AND cpa.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cpa.pathway_activity_status_cd=active_act_status_cd)
     JOIN (ctc
     WHERE ctc.cp_pathway_id=cpa.cp_pathway_id
      AND ctc.triggering_entity_id=cur_encntr_type_cd
      AND ctc.triggering_entity_name="CODE_VALUE"
      AND ctc.triggering_criteria_group_mean=encntr_discharge_type_mean
      AND ctc.criteria_type_mean="AUTO_COMPLETE")
     JOIN (cp
     WHERE cp.cp_pathway_id=cpa.cp_pathway_id)
    ORDER BY cpa.pathway_instance_id
    HEAD cpa.pathway_instance_id
     pathwaystoautocomplete->cnt += 1, stat = alterlist(pathwaystoautocomplete->qual,
      pathwaystoautocomplete->cnt), pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].
     cp_pathway_id = cpa.cp_pathway_id,
     pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].pathway_name = cp.pathway_name,
     pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].pathway_instance_id = cpa
     .pathway_instance_id, pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].
     triggering_entity_id = ctc.triggering_entity_id,
     pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].triggering_entity_disp =
     uar_get_code_display(ctc.triggering_entity_id), pathwaystoautocomplete->qual[
     pathwaystoautocomplete->cnt].triggering_entity_name = ctc.triggering_entity_name,
     pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].triggering_criteria_group_mean = ctc
     .triggering_criteria_group_mean,
     pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].triggering_criteria_ident = ctc
     .triggering_criteria_ident, pathwaystoautocomplete->qual[pathwaystoautocomplete->cnt].
     criteria_type_mean = ctc.criteria_type_mean
    WITH nocounter
   ;end select
   CALL log_message(build("exit buildPathwaysToAutoComplete, elapsed time in seconds:",((curtime3 -
     start_tm)/ 100.0)),log_level_debug)
 END ;Subroutine
 CALL main(null)
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
END GO
