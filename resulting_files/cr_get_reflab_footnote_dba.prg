CREATE PROGRAM cr_get_reflab_footnote:dba
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
 SET log_program_name = "CR_GET_REFLAB_FOOTNOTE"
 RECORD reply(
   1 qual[*]
     2 resource_cd = f8
     2 ref_lab_description = vc
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET skip_list
 RECORD skip_list(
   1 qual[*]
     2 skip_ind = i2
 )
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nno_relate = i2 WITH protect, constant(3)
 DECLARE nunknown_relate = i2 WITH protect, constant(4)
 DECLARE lselectresult = i4 WITH protect, noconstant(0)
 DECLARE org_relation_ind = i2 WITH constant(0), private
 DECLARE loc_relation_ind = i2 WITH constant(1), private
 DECLARE resource_relation_ind = i2 WITH noconstant(0), protect
 DECLARE facility_location_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY")), protect
 DECLARE request_qual_cnt = i4 WITH constant(value(size(request->qual,5))), protect
 SET lselectresult = nno_error
 SET stat = alterlist(skip_list->qual,request_qual_cnt)
 IF ((request->debug_ind=1))
  CALL echo("Request at begining of script")
  CALL echorecord(request)
 ENDIF
 IF (0=request_qual_cnt)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="CLINICAL_REPORTING"
   AND d.info_name="ORG_RES_MAINT"
  DETAIL
   resource_relation_ind = d.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET resource_relation_ind = 0
 ENDIF
 IF (error_message(1) > 0)
  SET lselectresult = nccl_error
  GO TO exit_script
 ENDIF
 CALL log_message(build("resource_relation_ind = ",resource_relation_ind),log_level_debug)
 CALL log_message("Retreived service resource relationship.",log_level_debug)
 IF (resource_relation_ind=org_relation_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = request_qual_cnt),
    encounter e,
    organization_resource ors
   PLAN (d
    WHERE (request->qual[d.seq].encntr_id > 0)
     AND (request->qual[d.seq].resource_cd > 0))
    JOIN (e
    WHERE (e.encntr_id=request->qual[d.seq].encntr_id))
    JOIN (ors
    WHERE (ors.service_resource_cd=request->qual[d.seq].resource_cd)
     AND ors.parent_entity_id=e.organization_id
     AND ors.ref_lab_ind=1
     AND ors.active_ind=1
     AND ors.parent_entity_name="ORGANIZATION")
   DETAIL
    skip_list->qual[d.seq].skip_ind = 1
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
  CALL log_message("Removed org level resources that match.",log_level_debug)
 ELSEIF (resource_relation_ind=loc_relation_ind)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = request_qual_cnt),
    encounter e,
    location l,
    organization_resource ors
   PLAN (d
    WHERE (request->qual[d.seq].encntr_id > 0)
     AND (request->qual[d.seq].resource_cd > 0))
    JOIN (e
    WHERE (e.encntr_id=request->qual[d.seq].encntr_id))
    JOIN (l
    WHERE l.location_cd=e.loc_facility_cd
     AND l.location_type_cd=facility_location_cd)
    JOIN (ors
    WHERE (ors.service_resource_cd=request->qual[d.seq].resource_cd)
     AND ors.parent_entity_id=l.organization_id
     AND ors.ref_lab_ind=1
     AND ors.active_ind=1
     AND ors.parent_entity_name="ORGANIZATION")
   DETAIL
    skip_list->qual[d.seq].skip_ind = 1
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
  CALL log_message("Removed location level resources that match.",log_level_debug)
 ELSE
  SET lselectresult = nunknown_relate
  GO TO exit_script
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo("Request after matching resources are removed.")
  CALL echorecord(request)
 ENDIF
 CALL log_message("Building resource descriptions.",log_level_debug)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = request_qual_cnt),
   organization_resource o
  PLAN (d
   WHERE (skip_list->qual[d.seq].skip_ind=0)
    AND (request->qual[d.seq].resource_cd > 0)
    AND (request->qual[d.seq].encntr_id > 0))
   JOIN (o
   WHERE (o.service_resource_cd=request->qual[d.seq].resource_cd)
    AND o.ref_lab_ind=1
    AND o.active_ind=1)
  HEAD REPORT
   x = 0
  DETAIL
   x += 1
   IF (x > value(size(reply->qual,5)))
    stat = alterlist(reply->qual,(x+ 5))
   ENDIF
   reply->qual[x].resource_cd = request->qual[d.seq].resource_cd, reply->qual[x].ref_lab_description
    = o.ref_lab_description, reply->qual[x].encntr_id = request->qual[d.seq].encntr_id
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (error_message(1) > 0)
  SET lselectresult = nccl_error
  GO TO exit_script
 ENDIF
 CALL log_message("Finished building resource descriptions.",log_level_debug)
#exit_script
 CASE (lselectresult)
  OF nno_error:
   CALL log_message("Script was successfully run.",log_level_debug)
   SET reply->status_data.status = "S"
  OF nccl_error:
   CALL log_message("CCL error message was logged.",log_level_debug)
   SET reply->status_data.status = "F"
  OF nno_relate:
   CALL log_message("No service resource relationships were found.",log_level_debug)
   SET reply->status_data.status = "Z"
  OF nunknown_relate:
   CALL log_message("An unknown service resource relationship was found.",log_level_debug)
   SET reply->status_data.status = "F"
  ELSE
   CALL log_message("Unknown error.",log_level_debug)
   SET reply->status_data.status = "F"
 ENDCASE
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
END GO
