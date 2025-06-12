CREATE PROGRAM cds_batch_rerun_activity:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start of Reporting Period" = "CURDATE",
  "End of Reporting Period" = "CURDATE",
  "Batch Type" = 0,
  "Anonymise the data?" = 0,
  "Trust" = "",
  "File Version" = "5            ",
  "Mars Report ID" = 0
  WITH outdev, startdate, enddate,
  batch_type, anon, org,
  version, mars_report_id
 SET last_mod = "817537"
 IF (validate(ukr_error_subroutines) != 0)
  GO TO ukr_error_subroutines_exit
 ENDIF
 DECLARE ukr_error_subroutines = i2 WITH public, constant(1)
 DECLARE max_errors = i4 WITH public, constant(25)
 DECLARE failure = c1 WITH public, constant("F")
 DECLARE no_data = c1 WITH public, constant("Z")
 DECLARE warning = c1 WITH public, constant("W")
 DECLARE success = c1 WITH public, constant("S")
 DECLARE partial = c1 WITH public, constant("P")
 DECLARE error_mode = c1 WITH public, constant("E")
 DECLARE reply_mode = c1 WITH public, constant("R")
 DECLARE error_storage_mode = c1 WITH public, noconstant(error_mode)
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE clearerrorstructure() = null
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE msg_default = i4 WITH protect, noconstant(0)
 DECLARE msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET msg_default = uar_msgopen("UKDISCERNREPORTING")
 SET msg_level = uar_msggetlevel(msg_default)
 DECLARE iloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE slogtext = vc WITH protect, noconstant("")
 DECLARE slogevent = vc WITH protect, noconstant("")
 DECLARE iholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE info_domain = vc WITH protect, constant("UKDISCERNREPORTING SCRIPT LOGGING")
 DECLARE logging_on = c1 WITH protect, constant("L")
 DECLARE debug_ind = i2 WITH public, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE subeventcnt = i4 WITH protect, noconstant(0)
 DECLARE iloggingstat = i2 WITH protect, noconstant(0)
 DECLARE subeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD errors
 RECORD errors(
   1 error_ind = i2
   1 error_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE (checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) =i2)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt += 1
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     CALL log_message(s_err_msg,log_level_audit)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE (seterrorstoragemode(s_error_storage_mode=c1) =i2)
  IF (s_error_storage_mode=error_mode)
   SET error_storage_mode = s_error_storage_mode
  ELSEIF (s_error_storage_mode=reply_mode
   AND validate(reply)=1)
   SET error_storage_mode = s_error_storage_mode
   SET reply->status_data.status = failure
  ELSE
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,
  s_target_obj_value=vc) =null)
   SET errors->error_cnt += 1
   SET s_status = cnvtupper(trim(substring(1,1,s_status),3))
   SET s_op_status = cnvtupper(trim(substring(1,1,s_op_status),3))
   IF (error_storage_mode=reply_mode)
    IF ((reply->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(reply->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(reply->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET reply->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ELSE
    IF (textlen(s_status) > 0
     AND (errors->status_data.status != failure))
     SET errors->status_data.status = s_status
    ENDIF
    IF ((errors->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(errors->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(errors->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET errors->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (showerrors(s_output=vc) =null)
  DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
  IF ((errors->error_cnt > 0))
   IF (error_storage_mode=reply_mode)
    SET stat = alter(reply->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,reply->status_data.
      status,reply->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),reply->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ELSE
    SET stat = alter(errors->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,errors->status_data.
      status,errors->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),errors->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE checkstatusblock(i_expected_cnt,i_results_cnt)
  IF ((errors->error_ind=1))
   CALL checkerror(failure,"CCL_ERROR",failure,"FINAL ERROR CHECK")
  ENDIF
  IF ((errors->error_ind=1))
   SET reply->status_data.status = failure
  ELSE
   CASE (i_results_cnt)
    OF i_expected_cnt:
     SET reply->status_data.status = success
    OF 0:
     SET reply->status_data.status = no_data
    ELSE
     SET reply->status_data.status = partial
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iloglvloverrideind = 0
   SET slogtext = ""
   SET slogevent = ""
   SET slogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iholdloglevel = loglvl
   ELSE
    IF (msg_level < loglvl)
     SET iholdloglevel = msg_level
     SET iloglvloverrideind = 1
    ELSE
     SET iholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iloglvloverrideind=1)
    SET slogevent = "Script_Override"
   ELSE
    CASE (iholdloglevel)
     OF log_level_error:
      SET slogevent = "Script_Error"
     OF log_level_warning:
      SET slogevent = "Script_Warning"
     OF log_level_audit:
      SET slogevent = "Script_Audit"
     OF log_level_info:
      SET slogevent = "Script_Info"
     OF log_level_debug:
      SET slogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(msg_default,0,nullterm(slogevent),iholdloglevel,nullterm(
     slogtext))
   IF (debug_ind=1)
    CALL echo(logmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE clearerrorstructure(null)
   SET errors->error_ind = 0
   SET errors->error_cnt = 0
   SET errors->status_data.status = ""
   SET errors->status_data.subeventstatus[1].operationname = ""
   SET errors->status_data.subeventstatus[1].operationstatus = ""
   SET errors->status_data.subeventstatus[1].targetobjectname = ""
   SET errors->status_data.subeventstatus[1].targetobjectvalue = ""
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL adderrormsg(failure,opname,failure,"CCL ERROR",serrmsg)
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
    CALL populate_subeventstatus(opname,"Z","No records qualified",logname)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET subeventcnt = size(reply->status_data.subeventstatus,5)
    SET subeventsize = size(trim(reply->status_data.subeventstatus[subeventcnt].operationname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].operationstatus))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectvalue))
    IF (subeventsize > 0)
     SET subeventcnt += 1
     SET iloggingstat = alter(reply->status_data.subeventstatus,subeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[subeventcnt].operationname = substring(1,25,operationname)
    SET reply->status_data.subeventstatus[subeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (validationfailuremsg(s_output=vc,logmsg=vc,loglvl=vc) =null)
   CALL log_message(logmsg,loglvl)
   DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
   IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
    SET s_output_dest = "NOFORMS"
   ENDIF
   SELECT INTO value(s_output_dest)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     row + 1, logmsg
    WITH nocounter, format, separator = " ",
     maxcol = 200
   ;end select
   GO TO exit_script
 END ;Subroutine
#ukr_error_subroutines_exit
 EXECUTE ukr_cds_create_extracts  $OUTDEV,  $STARTDATE,  $ENDDATE,
  $BATCH_TYPE,  $ANON,  $ORG,
  $VERSION, 0, "CDS_BATCH_RERUN_ACTIVITY",
  $MARS_REPORT_ID
#exit_script
 IF (checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK") > 0)
  CALL showerrors(value( $OUTDEV))
 ENDIF
 FREE RECORD reply
END GO
