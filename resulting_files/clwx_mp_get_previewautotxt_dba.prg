CREATE PROGRAM clwx_mp_get_previewautotxt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "NotePhrase ID:" = 0.0
  WITH outdev, npid
 FREE RECORD record_data
 RECORD record_data(
   1 json_size = vc
   1 note_phrase_id = f8
   1 note_preview_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CLWX_MP_GET_PREVIEWAUTOTXT"
 IF ((validate(debug_ind,- (99))=- (99)))
  DECLARE debug_ind = i2 WITH protect, noconstant(false)
 ENDIF
 DECLARE current_date_time_previewauto = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE 23_rtf_format_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3802"))
 DECLARE 23_html_format_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!107731"))
 DECLARE preview_reqid = i4 WITH public, constant(969552)
 DECLARE htmltxt_reqid = i4 WITH public, constant(969553)
 DECLARE html_note_preview_text = vc
 DECLARE rtf_note_preview_text = vc
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->status_data.status = "F"
 SET record_data->note_phrase_id =  $NPID
 CALL getpreviewautotext(null)
 SET modify maxvarlen 30000000
 SET record_data->json_size = cnvtstring(size(cnvtrectojson(record_data)))
 SET _memory_reply_string = cnvtrectojson(record_data)
 IF (debug_ind=true)
  CALL echorecord(record_data)
  CALL echo(_memory_reply_string)
 ENDIF
 SUBROUTINE getpreviewautotext(dummy)
   CALL log_message("In GetPreviewAutoText",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   FREE RECORD preview_request
   RECORD preview_request(
     1 note_phrase_id = f8
   )
   FREE RECORD preview_reply
   RECORD preview_reply(
     1 components[*]
       2 note_phrase_component_id = f8
       2 fkey_name = vc
       2 fkey_id = f8
       2 format_cd = f8
       2 sequence = i4
       2 system_generated_ind = i2
       2 component_text = vc
       2 template_name = vc
       2 component_display_text = vc
       2 drop_list[*]
         3 note_phrase_drop_list_id = f8
         3 uuid = vc
         3 drop_list_items[*]
           4 note_phrase_drop_list_item_id = f8
           4 display = vc
           4 sequence = i2
           4 default_ind = i2
         3 multiselectable = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD formattext_request
   RECORD formattext_request(
     1 desired_format_cd = f8
     1 origin_format_cd = f8
     1 origin_text = vc
   )
   FREE RECORD formattext_reply
   RECORD formattext_reply(
     1 converted_text = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET preview_request->note_phrase_id = cnvtreal(record_data->note_phrase_id)
   SET stat = tdbexecute(3202004,3202004,preview_reqid,"REC",preview_request,
    "REC",preview_reply)
   IF (debug_ind=true)
    CALL echorecord(preview_reply)
   ENDIF
   IF ((((preview_reply->status_data.status="F")) OR ((preview_reply->status_data.status="Z"))) )
    SET record_data->status_data.status = "F"
    SET record_data->status_data.subeventstatus.targetobjectvalue = preview_reply->status_data.
    subeventstatus.targetobjectvalue
   ELSE
    SET record_data->status_data.status = "S"
    SET preview_cnt = size(preview_reply->components,5)
    IF (preview_cnt > 0)
     FOR (i = 1 TO preview_cnt)
       IF ((((preview_reply->components[i].fkey_name="CODE_VALUE")) OR ((preview_reply->components[i]
       .fkey_name="CLINICAL_NOTE_TEMPLATE")))
        AND (preview_reply->components[i].system_generated_ind != 1))
        IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
         SET rtf_note_preview_text = concat(rtf_note_preview_text,"[",preview_reply->components[i].
          template_name,"]")
        ELSE
         SET html_note_preview_text = concat(html_note_preview_text,"[",preview_reply->components[i].
          template_name,"]")
        ENDIF
       ELSEIF ((preview_reply->components[i].fkey_name="DATA_TOKEN")
        AND (preview_reply->components[i].system_generated_ind != 1))
        IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
         SET rtf_note_preview_text = concat(rtf_note_preview_text,"[",preview_reply->components[i].
          component_text,"]")
        ELSE
         SET html_note_preview_text = concat(html_note_preview_text,"[",preview_reply->components[i].
          component_text,"]")
        ENDIF
       ELSEIF ((preview_reply->components[i].fkey_name="NOTE_PHRASE_DROP_LIST")
        AND (preview_reply->components[i].system_generated_ind != 1))
        SET item_cnt = size(preview_reply->components[i].drop_list[1].drop_list_items,5)
        IF (item_cnt > 0)
         IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
          SET rtf_note_preview_text = concat(rtf_note_preview_text,
           "<html><span style='color:#0071e0;font-size:13px;'>")
         ELSE
          SET html_note_preview_text = concat(html_note_preview_text,
           "<html><span style='color:#0071e0;font-size:13px;'>")
         ENDIF
         SET found_first = 0
         FOR (j = 1 TO item_cnt)
           IF ((preview_reply->components[i].drop_list[1].drop_list_items[j].default_ind != 0))
            IF (found_first != 1)
             SET found_first = 1
             IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
              SET rtf_note_preview_text = concat(rtf_note_preview_text,preview_reply->components[i].
               drop_list[1].drop_list_items[j].display)
             ELSE
              SET html_note_preview_text = concat(html_note_preview_text,preview_reply->components[i]
               .drop_list[1].drop_list_items[j].display)
             ENDIF
            ELSE
             IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
              SET rtf_note_preview_text = concat(rtf_note_preview_text,", ",preview_reply->
               components[i].drop_list[1].drop_list_items[j].display)
             ELSE
              SET html_note_preview_text = concat(html_note_preview_text,", ",preview_reply->
               components[i].drop_list[1].drop_list_items[j].display)
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
         IF (found_first != 1)
          IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
           SET rtf_note_preview_text = concat(rtf_note_preview_text,preview_reply->components[i].
            drop_list[1].drop_list_items[1].display)
          ELSE
           SET html_note_preview_text = concat(html_note_preview_text,preview_reply->components[i].
            drop_list[1].drop_list_items[1].display)
          ENDIF
         ENDIF
         IF ((preview_reply->components[i].format_cd=23_rtf_format_cd))
          SET rtf_note_preview_text = concat(rtf_note_preview_text,"&#x25bc</span></html>")
         ELSE
          SET html_note_preview_text = concat(html_note_preview_text,"&#x25bc</span></html>")
         ENDIF
        ENDIF
       ELSEIF ((preview_reply->components[i].format_cd=23_rtf_format_cd)
        AND (preview_reply->components[i].system_generated_ind != 1))
        SET formattext_request->origin_text = preview_reply->components[i].component_text
        SET formattext_request->origin_format_cd = 23_rtf_format_cd
        SET formattext_request->desired_format_cd = 23_html_format_cd
        SET stat = tdbexecute(3202004,3202004,htmltxt_reqid,"REC",formattext_request,
         "REC",formattext_reply)
        IF (debug_ind=true)
         CALL echorecord(formattext_reply)
        ENDIF
        IF ((((formattext_reply->status_data.status="F")) OR ((formattext_reply->status_data.status=
        "Z"))) )
         SET record_data->status_data.status = "F"
         SET record_data->status_data.subeventstatus.targetobjectvalue = formattext_reply->
         status_data.subeventstatus.targetobjectvalue
         GO TO exit_script
        ELSE
         SET rtf_note_preview_text = concat(rtf_note_preview_text,formattext_reply->converted_text)
         SET record_data->status_data.status = "S"
        ENDIF
       ELSEIF ((preview_reply->components[i].format_cd=23_html_format_cd)
        AND (preview_reply->components[i].system_generated_ind != 1))
        SET html_note_preview_text = concat(html_note_preview_text,preview_reply->components[i].
         component_text)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (trim(html_note_preview_text) != "")
    SET record_data->note_preview_text = html_note_preview_text
   ELSE
    SET record_data->note_preview_text = rtf_note_preview_text
   ENDIF
   CALL log_message(build("Exit GetPreviewAutoText, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
    current_date_time_previewauto,5)),log_level_debug)
 FREE RECORD record_data
END GO
