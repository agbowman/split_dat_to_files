CREATE PROGRAM cp_export_folder_details
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Folder id's" = ""
  WITH outdev, folderlist
 FREE RECORD pathway_folders
 RECORD pathway_folders(
   1 folder[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 parent_id = f8
     2 item[*]
       3 plan_desc = vc
       3 regimen_desc = vc
       3 list_type = i4
       3 synonym_id = f8
       3 synonym = vc
       3 key_cap = vc
       3 sentence_id = f8
       3 display = vc
       3 usage_flag = i2
       3 orderable_type_flag = i2
       3 format_id = f8
       3 format_name = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 parent_entity2_name = vc
       3 parent_entity2_id = f8
       3 details[*]
         4 sequence = i4
         4 oe_field_id = f8
         4 oe_field_display_value = vc
         4 oe_field_value = f8
         4 oe_field_meaning_id = f8
         4 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD orm_request
 RECORD orm_request(
   1 alt_sel_category_id = f8
 )
 FREE RECORD os_request
 RECORD os_request(
   1 order_sentence_id = f8
 )
 FREE RECORD os_reply
 RECORD os_reply(
   1 qual[*]
     2 sequence = i4
     2 oe_field_value = f8
     2 oe_field_id = f8
     2 oe_field_display_value = vc
     2 oe_field_meaning_id = f8
     2 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD orm_reply
 RECORD orm_reply(
   1 qual[*]
     2 active_ind = i2
     2 sequence = i4
     2 list_type = i4
     2 child_alt_sel_cat_id = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 oe_format_id = f8
     2 orderable_type_flag = i2
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 updt_dt_tm = dq8
     2 usage_flag = i2
     2 plan_description = vc
     2 pathway_catalog_id = f8
     2 version_nbr = i4
     2 pw_cat_synonym_id = f8
     2 regimen_display = vc
     2 regimen_cat_synonym_id = f8
     2 order_sentence_filters[*]
       3 order_sentence_filter_id = f8
       3 order_sentence_filter_display = vc
       3 age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 postmenstrual_age_range_filter[*]
         4 minimum = i4
         4 maximum = i4
         4 unit_cd = f8
       3 weight_range_filter[*]
         4 minimum = f8
         4 maximum = f8
         4 unit_cd = f8
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
 DECLARE folder_rec = i4 WITH protect
 DECLARE jsonstr = vc WITH protect, noconstant(trim( $FOLDERLIST))
 SET jsonstr = replace(jsonstr,'"/date(','"\/date(',0)
 SET jsonstr = replace(jsonstr,')/"',')\/"',0)
 IF (validate(debug_ind,0)=1)
  CALL echo(jsonstr)
  CALL echo(cnvtjsontorec(trim(jsonstr,3)))
 ENDIF
 IF (jsonstr > " ")
  SET folder_rec = cnvtjsontorec(trim(jsonstr,3))
  IF (validate(debug_ind,0)=1)
   CALL echorecord(folder_ids_list)
  ENDIF
 ENDIF
 DECLARE getfolderids(null) = null WITH protect
 DECLARE getfoldercontents(null) = null WITH protect
 DECLARE getorderinfo(null) = null WITH protect
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 DECLARE current_date_time2 = dq8 WITH constant(curtime3), private
 SET pathway_folders->status_data.status = "F"
 CALL getfolderids(null)
 CALL getfoldercontents(null)
 CALL getorderinfo(null)
 SET pathway_folders->status_data.status = "S"
 SUBROUTINE getfolderids(null)
   CALL log_message("Begin GetFolderIds()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO size(folder_ids_list->qual,5))
    SET stat = alterlist(pathway_folders->folder,x)
    SET pathway_folders->folder[x].id = folder_ids_list->qual[x].folder_id
   ENDFOR
   CALL log_message(build("Exit GetFolderIds(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getfoldercontents(null)
   CALL log_message("Begin GetFolderContents()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ii = i4 WITH protect, noconstant(0)
   DECLARE xx = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE scnt = i4 WITH protect, noconstant(0)
   FOR (ii = 1 TO size(folder_ids_list->qual,5))
     SET orm_request->alt_sel_category_id = pathway_folders->folder[ii].id
     SET stat = initrec(orm_reply)
     EXECUTE orm_get_aos_folder_contents  WITH replace("REQUEST",orm_request), replace("REPLY",
      orm_reply)
     SET scnt = 0
     FOR (xx = 1 TO size(orm_reply->qual,5))
       SET scnt += 1
       SET stat = alterlist(pathway_folders->folder[ii].item,scnt)
       SET pathway_folders->folder[ii].item[scnt].synonym_id = orm_reply->qual[xx].synonym_id
       SET pathway_folders->folder[ii].item[scnt].sentence_id = orm_reply->qual[xx].order_sentence_id
       SET pathway_folders->folder[ii].item[scnt].display = orm_reply->qual[xx].
       order_sentence_display_line
       SET pathway_folders->folder[ii].item[scnt].usage_flag = orm_reply->qual[xx].usage_flag
       SET pathway_folders->folder[ii].item[scnt].format_id = orm_reply->qual[xx].oe_format_id
       SET pathway_folders->folder[ii].item[scnt].plan_desc = orm_reply->qual[xx].plan_description
       SET pathway_folders->folder[ii].item[scnt].regimen_desc = orm_reply->qual[xx].regimen_display
       SET pathway_folders->folder[ii].item[scnt].list_type = orm_reply->qual[xx].list_type
       SET pathway_folders->folder[ii].item[scnt].orderable_type_flag = orm_reply->qual[xx].
       orderable_type_flag
       IF ((orm_reply->qual[xx].order_sentence_id > 0))
        SET os_request->order_sentence_id = orm_reply->qual[xx].order_sentence_id
        EXECUTE orm_get_ord_sent_detail  WITH replace("REQUEST",os_request), replace("REPLY",os_reply
         )
        FOR (y = 1 TO size(os_reply->qual,5))
          SET stat = alterlist(pathway_folders->folder[ii].item[scnt].details,y)
          SET pathway_folders->folder[ii].item[scnt].details[y].sequence = os_reply->qual[y].sequence
          SET pathway_folders->folder[ii].item[scnt].details[y].oe_field_display_value = os_reply->
          qual[y].oe_field_display_value
          SET pathway_folders->folder[ii].item[scnt].details[y].oe_field_id = os_reply->qual[y].
          oe_field_id
          SET pathway_folders->folder[ii].item[scnt].details[y].oe_field_value = os_reply->qual[y].
          oe_field_value
          SET pathway_folders->folder[ii].item[scnt].details[y].oe_field_meaning_id = os_reply->qual[
          y].oe_field_meaning_id
          SET pathway_folders->folder[ii].item[scnt].details[y].field_type_flag = os_reply->qual[y].
          field_type_flag
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build("Exit GetFolderContents(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getorderinfo(null)
   CALL log_message("Begin GetOrderInfo()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE xx = i4 WITH protect, noconstant(0)
   FOR (xx = 1 TO size(folder_ids_list->qual,5))
    SELECT INTO "nl:"
     FROM alt_sel_cat c
     PLAN (c
      WHERE (c.alt_sel_category_id=pathway_folders->folder[xx].id))
     DETAIL
      pathway_folders->folder[xx].short_desc = c.short_description, pathway_folders->folder[xx].
      long_desc = c.long_description
     WITH nocounter
    ;end select
    IF (size(pathway_folders->folder[xx].item,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(pathway_folders->folder[xx].item,5))),
       order_entry_format f
      PLAN (d)
       JOIN (f
       WHERE (f.oe_format_id=pathway_folders->folder[xx].item[d.seq].format_id))
      ORDER BY d.seq
      HEAD d.seq
       pathway_folders->folder[xx].item[d.seq].format_name = f.oe_format_name
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(pathway_folders->folder[xx].item,5))),
       order_catalog_synonym s
      PLAN (d)
       JOIN (s
       WHERE (s.synonym_id=pathway_folders->folder[xx].item[d.seq].synonym_id))
      ORDER BY d.seq
      HEAD d.seq
       pathway_folders->folder[xx].item[d.seq].synonym = s.mnemonic, pathway_folders->folder[xx].
       item[d.seq].key_cap = s.mnemonic_key_cap
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
   CALL log_message(build("Exit GetOrderInfo(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(pathway_folders)
 ENDIF
 CALL putjsonrecordtofile(pathway_folders, $OUTDEV)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - current_date_time2)/ 100.0)),
  log_level_debug)
END GO
