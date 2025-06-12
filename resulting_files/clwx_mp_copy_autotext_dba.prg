CREATE PROGRAM clwx_mp_copy_autotext:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "User ID:" = ""
  WITH outdev, uid
 FREE RECORD record_data
 RECORD record_data(
   1 error_in_rec = i2
   1 autotextlist[*]
     2 noteid = f8
     2 action_mode = vc
     2 results = vc
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
 SET log_program_name = "CLWX_MP_COPY_AUTOTEXT"
 IF ((validate(debug_ind,- (99))=- (99)))
  DECLARE debug_ind = i2 WITH protect, noconstant(false)
 ENDIF
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE delete_reqid = i4 WITH public, constant(969554)
 DECLARE preview_reqid = i4 WITH public, constant(969552)
 DECLARE copy_reqid = i4 WITH public, constant(969554)
 DECLARE asteriskfoundat = i4 WITH noconstant(0)
 DECLARE whitespacefoundat = i4 WITH noconstant(0)
 DECLARE autotext_cnt = i4 WITH noconstant(0)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->status_data.status = "F"
 EXECUTE ccluarxrtl
 IF (validate(request->blob_in))
  IF ((request->blob_in > " "))
   CALL log_message("Begin CnvtJSONRec",log_level_debug)
   DECLARE cnvtbeg_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE jrec = i4
   SET jrec = cnvtjsontorec(trim(request->blob_in))
   CALL log_message(build("Finish CnvtJSONRec(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       curdate,curtime3),cnvtbeg_date_time,5)),log_level_debug)
   IF (validate(copyautotext->autotextlist))
    IF (debug_ind=true)
     CALL echorecord(copyautotext)
    ENDIF
    SET autotext_cnt = size(copyautotext->autotextlist,5)
   ENDIF
  ENDIF
 ENDIF
 CALL log_message("Processing copyautotext",log_level_debug)
 DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
 IF (autotext_cnt > 0)
  FOR (i = 1 TO autotext_cnt)
    SET stat = alterlist(record_data->autotextlist,i)
    SET asteriskfoundat = findstring("*",copyautotext->autotextlist[i].abber)
    SET whitespacefoundat = findstring(" ",copyautotext->autotextlist[i].abber)
    IF (((asteriskfoundat > 0) OR (whitespacefoundat > 0)) )
     SET record_data->autotextlist[i].noteid = cnvtreal(copyautotext->autotextlist[i].noteid)
     SET record_data->autotextlist[i].action_mode = "ASTERISKWHITESPACECOPY"
     SET record_data->autotextlist[i].results = "F"
     SET record_data->error_in_rec = 1
    ELSE
     IF ((copyautotext->autotextlist[i].updtnoteid != "0.00"))
      RECORD delete_request(
        1 action = vc
        1 note_phrase_id = f8
        1 abbreviation = vc
        1 description = vc
        1 user_id = f8
        1 note_phrase_comps[*]
          2 note_phrase_comp_id = f8
          2 fkey_name = vc
          2 fkey_id = f8
          2 format_cd = f8
          2 sequence = i4
          2 system_generated_ind = i2
          2 formatted_text = gvc
          2 drop_list_uuid = vc
        1 drop_lists[*]
          2 note_phrase_drop_list_id = f8
          2 uuid = vc
          2 drop_list_items[*]
            3 note_phrase_drop_list_item_id = f8
            3 display = vc
            3 sequence = i4
            3 default_ind = i2
          2 multiselectable = i2
      )
      RECORD delete_reply(
        1 note_phrase_id = f8
        1 updt_dt_tm = dq8
        1 note_phrase_comps[*]
          2 note_phrase_comp_id = f8
          2 format_cd = f8
          2 sequence = i4
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      SET delete_request->action = "DELETE"
      SET delete_request->note_phrase_id = cnvtreal(copyautotext->autotextlist[i].updtnoteid)
      SET stat = tdbexecute(3202004,3202004,delete_reqid,"REC",delete_request,
       "REC",delete_reply)
      IF ((((delete_reply->status_data.status="F")) OR ((delete_reply->status_data.status="Z"))) )
       SET record_data->autotextlist[i].noteid = cnvtreal(copyautotext->autotextlist[i].noteid)
       SET record_data->autotextlist[i].action_mode = "DELETE"
       SET record_data->autotextlist[i].results = delete_reply->status_data.status
       SET record_data->error_in_rec = 1
      ENDIF
      FREE RECORD delete_request
      FREE RECORD delete_reply
     ENDIF
     RECORD preview_request(
       1 note_phrase_id = f8
     )
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
     RECORD copy_request(
       1 action = vc
       1 note_phrase_id = f8
       1 abbreviation = vc
       1 description = vc
       1 user_id = f8
       1 note_phrase_comps[*]
         2 note_phrase_comp_id = f8
         2 fkey_name = vc
         2 fkey_id = f8
         2 format_cd = f8
         2 sequence = i4
         2 system_generated_ind = i2
         2 formatted_text = gvc
         2 drop_list_uuid = vc
       1 drop_lists[*]
         2 note_phrase_drop_list_id = f8
         2 uuid = vc
         2 drop_list_items[*]
           3 note_phrase_drop_list_item_id = f8
           3 display = vc
           3 sequence = i4
           3 default_ind = i2
         2 multiselectable = i2
     )
     RECORD copy_reply(
       1 note_phrase_id = f8
       1 updt_dt_tm = dq8
       1 note_phrase_comps[*]
         2 note_phrase_comp_id = f8
         2 format_cd = f8
         2 sequence = i4
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET preview_request->note_phrase_id = cnvtreal(copyautotext->autotextlist[i].noteid)
     SET stat = tdbexecute(3202004,3202004,preview_reqid,"REC",preview_request,
      "REC",preview_reply)
     IF (debug_ind=true)
      CALL echorecord(preview_reply)
     ENDIF
     IF ((((preview_reply->status_data.status="F")) OR ((preview_reply->status_data.status="Z"))) )
      SET record_data->autotextlist[i].noteid = preview_request->note_phrase_id
      SET record_data->autotextlist[i].results = preview_reply->status_data.status
      SET record_data->autotextlist[i].action_mode = "PREVIEW"
      SET record_data->error_in_rec = 1
      FREE RECORD preview_request
      FREE RECORD preview_reply
     ELSE
      SET preview_cnt = size(preview_reply->components,5)
      IF (preview_cnt > 0)
       SET copy_request->action = "ADD"
       SET copy_request->note_phrase_id = 0.00
       SET copy_request->abbreviation = copyautotext->autotextlist[i].abber
       SET copy_request->description = copyautotext->autotextlist[i].desc
       SET copy_request->user_id =  $UID
       SET note_comp_size = size(preview_reply->components,5)
       SET stat = alterlist(copy_request->note_phrase_comps,note_comp_size)
       IF (note_comp_size > 0)
        FOR (y = 1 TO note_comp_size)
          SET copy_request->note_phrase_comps[y].fkey_name = preview_reply->components[y].fkey_name
          SET copy_request->note_phrase_comps[y].fkey_id = preview_reply->components[y].fkey_id
          SET copy_request->note_phrase_comps[y].format_cd = preview_reply->components[y].format_cd
          SET copy_request->note_phrase_comps[y].sequence = preview_reply->components[y].sequence
          SET copy_request->note_phrase_comps[y].system_generated_ind = preview_reply->components[y].
          system_generated_ind
          SET copy_request->note_phrase_comps[y].formatted_text = preview_reply->components[y].
          component_text
          SET drop_dow_size = size(preview_reply->components[y].drop_list,5)
          SET req_drop_size = size(copy_request->drop_lists,5)
          FOR (z = 1 TO drop_dow_size)
            IF ((preview_reply->components[y].drop_list[z].note_phrase_drop_list_id > 0.0))
             SET req_drop_cnt = (req_drop_size+ 1)
             SET stat = alterlist(copy_request->drop_lists,req_drop_cnt)
             SET uuid = trim(uar_createuuid(0))
             SET copy_request->note_phrase_comps[y].drop_list_uuid = uuid
             SET copy_request->drop_lists[req_drop_cnt].uuid = uuid
             SET copy_request->drop_lists[req_drop_cnt].multiselectable = preview_reply->components[y
             ].drop_list[z].multiselectable
             SET drop_list_item_size = size(preview_reply->components[y].drop_list[z].drop_list_items,
              5)
             FOR (z1 = 1 TO drop_list_item_size)
               SET req_drop_item_cnt = (size(copy_request->drop_lists[req_drop_cnt].drop_list_items,5
                )+ 1)
               SET stat = alterlist(copy_request->drop_lists[req_drop_cnt].drop_list_items,
                req_drop_item_cnt)
               SET copy_request->drop_lists[req_drop_cnt].drop_list_items[req_drop_item_cnt].
               note_phrase_drop_list_item_id = 0
               SET copy_request->drop_lists[req_drop_cnt].drop_list_items[req_drop_item_cnt].display
                = preview_reply->components[y].drop_list[z].drop_list_items[z1].display
               SET copy_request->drop_lists[req_drop_cnt].drop_list_items[req_drop_item_cnt].
               default_ind = preview_reply->components[y].drop_list[z].drop_list_items[z1].
               default_ind
               SET copy_request->drop_lists[req_drop_cnt].drop_list_items[req_drop_item_cnt].sequence
                = preview_reply->components[y].drop_list[z].drop_list_items[z1].sequence
             ENDFOR
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
       IF (debug_ind=true)
        CALL echorecord(copy_request)
       ENDIF
       SET stat = tdbexecute(3202004,3202004,copy_reqid,"REC",copy_request,
        "REC",copy_reply)
       IF (debug_ind=true)
        CALL echorecord(copy_reply)
       ENDIF
       SET stat = alterlist(record_data->autotextlist,i)
       SET record_data->autotextlist[i].noteid = cnvtreal(copyautotext->autotextlist[i].noteid)
       SET record_data->autotextlist[i].action_mode = "ADD"
       SET record_data->autotextlist[i].results = copy_reply->status_data.status
       IF ((copy_reply->status_data.status != "S"))
        SET record_data->error_in_rec = 1
       ENDIF
       FREE RECORD preview_request
       FREE RECORD preview_reply
       FREE RECORD copy_request
       FREE RECORD copy_reply
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET record_data->status_data.status = "S"
 CALL log_message(build("Processing copy auto text done, Elapsed time in seconds:",datetimediff(
    cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
#exit_script
 SET _memory_reply_string = cnvtrectojson(record_data)
 IF (debug_ind=true)
  CALL echo(_memory_reply_string)
  CALL echorecord(record_data)
 ENDIF
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
    begin_date_time,5)),log_level_debug)
 FREE RECORD record_data
END GO
