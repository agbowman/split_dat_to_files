CREATE PROGRAM cp_import_folder_details
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD orm_upd_request
 RECORD orm_upd_request(
   1 alt_sel_category_id = f8
   1 upd_asc_ind = i2
   1 short_description = vc
   1 long_description = vc
   1 child_cat_ind = i2
   1 owner_id = f8
   1 security_flag = i2
   1 updt_cnt = i4
   1 del_aos_ordsents_ind = i2
   1 aosadd_cnt = i4
   1 aosadd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosupd_cnt = i4
   1 aosupd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosdel_cnt = i4
   1 aosdel_qual[*]
     2 sequence = i4
 )
 FREE RECORD orm_upd_reply
 RECORD orm_upd_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD orm_add_request
 RECORD orm_add_request(
   1 short_description = vc
   1 long_description = vc
   1 child_cat_ind = i2
   1 owner_id = f8
   1 security_flag = i2
   1 aoslist_cnt = i4
   1 source_component_flag = i2
 )
 FREE RECORD orm_add_reply
 RECORD orm_add_reply(
   1 alt_sel_category_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD 500350_request
 RECORD 500350_request(
   1 order_sentence_list[*]
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 order_encntr_group_cd = f8
     2 display_seq = i4
     2 discern_auto_verify_flag = i2
     2 ic_auto_verify_flag = i2
     2 usage_flag = i2
     2 ord_comment_long_text = vc
     2 oe_format_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 parent_entity2_name = vc
     2 parent_entity2_id = f8
     2 facilities_list[*]
       3 facility_cd = f8
     2 detail_list[*]
       3 sequence = i4
       3 oe_field_id = f8
       3 oe_field_display_value = vc
       3 oe_field_value = f8
       3 oe_field_meaning_id = f8
       3 field_type_flag = i2
     2 rx_type_mean = c12
     2 order_sentence_filters[*]
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
 )
 FREE RECORD 500350_reply
 RECORD 500350_reply(
   1 order_sentence_list[*]
     2 order_sentence_id = f8
     2 success_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD import_folders_reply
 RECORD import_folders_reply(
   1 qual[*]
     2 desc = vc
     2 type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(request->blob_in))
  IF ((request->blob_in > " "))
   CALL logblobindata("cp_import_folder_details",request->blob_in, $OUTDEV)
   IF (validate(debug_ind,0)=1)
    CALL echo(request->blob_in)
   ENDIF
   SET jrec = cnvtjsontorec(request->blob_in)
   IF (jrec != 1)
    SET folder_details_reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   FREE RECORD request
  ENDIF
 ENDIF
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
 DECLARE short_desc = vc WITH protect, noconstant(" ")
 DECLARE long_desc = vc WITH protect, noconstant(" ")
 DECLARE itemcntr = i4 WITH protect, noconstant(0)
 DECLARE fldrcntr = i4 WITH protect, noconstant(0)
 DECLARE new_folder_id = f8 WITH protect, noconstant(0.0)
 DECLARE existing_folder_id = f8 WITH protect, noconstant(0.0)
 DECLARE format_id = f8 WITH protect, noconstant(0.0)
 DECLARE synonym_id = f8 WITH protect, noconstant(0.0)
 DECLARE sentence_id = f8 WITH protect, noconstant(0.0)
 DECLARE pathway_cat_id = f8 WITH protect, noconstant(0.0)
 DECLARE pathway_syn_id = f8 WITH protect, noconstant(0.0)
 DECLARE regimen_syn_id = f8 WITH protect, noconstant(0.0)
 DECLARE list_type = i4 WITH protect, noconstant(0)
 DECLARE add_ind = i4 WITH protect, noconstant(1)
 DECLARE lseq = i4 WITH protect, noconstant(0)
 DECLARE ecnt = i4 WITH protect, noconstant(0)
 DECLARE importfolders(null) = null
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 DECLARE current_date_time2 = dq8 WITH constant(curtime3), private
 CALL importfolders(null)
 SET import_folders_reply->status_data.status = "S"
 SUBROUTINE (getexistingfolderid(folder_desc=vc) =null)
   CALL log_message("Begin getExistingFolderId()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   IF (folder_desc > " ")
    SELECT INTO "nl:"
     FROM alt_sel_cat a
     PLAN (a
      WHERE a.long_description=folder_desc)
     DETAIL
      existing_folder_id = a.alt_sel_category_id
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit getExistingFolderId(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertorderfolder(folder_long_desc=vc,folder_short_desc=vc) =null)
   CALL log_message("Begin insertOrderFolder()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET stat = initrec(orm_add_request)
   SET orm_add_request->short_description = folder_short_desc
   SET orm_add_request->long_description = folder_long_desc
   SET orm_add_request->security_flag = 2
   EXECUTE orm_add_aos_cat_info  WITH replace("REQUEST",orm_add_request), replace("REPLY",
    orm_add_reply)
   CALL log_message(build("Exit insertOrderFolder(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (findsynonym(foldercntr=i4,folderitemcntr=i4) =null)
   CALL log_message("Begin findSynonym()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE orderable_type_flag = i2 WITH noconstant(0), protect
   IF ((folder_details->folders[foldercntr].item[folderitemcntr].key_cap > " "))
    SET orderable_type_flag = folder_details->folders[foldercntr].item[folderitemcntr].
    orderable_type_flag
    SELECT INTO "nl:"
     FROM order_entry_format f
     PLAN (f
      WHERE (f.oe_format_name=folder_details->folders[foldercntr].item[folderitemcntr].format_name))
     DETAIL
      folder_details->folders[foldercntr].item[folderitemcntr].format_id = f.oe_format_id, format_id
       = f.oe_format_id
     WITH nocounter
    ;end select
    IF (((format_id > 0) OR (orderable_type_flag=6)) )
     SELECT INTO "nl:"
      FROM order_catalog_synonym s
      PLAN (s
       WHERE (s.mnemonic_key_cap=folder_details->folders[foldercntr].item[folderitemcntr].key_cap))
      DETAIL
       IF (((s.oe_format_id=format_id) OR (orderable_type_flag=6)) )
        folder_details->folders[foldercntr].item[folderitemcntr].synonym_id = s.synonym_id,
        folder_details->folders[foldercntr].item[folderitemcntr].parent_entity_id = s.synonym_id,
        synonym_id = s.synonym_id,
        list_type = 2
        IF (synonym_id=0)
         add_ind = 0, ecnt += 1, stat = alterlist(import_folders_reply->qual,ecnt),
         import_folders_reply->qual[ecnt].type = "ORDER_SYNONYM_NOT_FOUND", import_folders_reply->
         qual[ecnt].desc = folder_details->folders[foldercntr].item[folderitemcntr].synonym
        ENDIF
       ELSE
        add_ind = 0, ecnt += 1, stat = alterlist(import_folders_reply->qual,ecnt),
        import_folders_reply->qual[ecnt].type = "ORDER_ENTRY_FORMAT_DID_NOT_MATCH",
        import_folders_reply->qual[ecnt].desc = folder_details->folders[foldercntr].item[
        folderitemcntr].synonym
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SET add_ind = 0
     SET ecnt += 1
     SET stat = alterlist(import_folders_reply->qual,ecnt)
     SET import_folders_reply->qual[ecnt].type = "ORDER_ENTRY_FORMAT_NOT_FOUND"
     SET import_folders_reply->qual[ecnt].desc = folder_details->folders[foldercntr].item[
     folderitemcntr].synonym
    ENDIF
   ENDIF
   CALL log_message(build("Exit findSynonym(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (findpowerplan(plan_desc=vc) =null)
   CALL log_message("Begin findPowerplan()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   IF (plan_desc > " ")
    SELECT INTO "nl:"
     FROM pw_cat_synonym pcs
     PLAN (pcs
      WHERE pcs.synonym_name=plan_desc)
     DETAIL
      pathway_syn_id = pcs.pw_cat_synonym_id, pathway_cat_id = pcs.pathway_catalog_id, list_type = 6
     WITH nocounter
    ;end select
    IF (pathway_syn_id=0)
     SET add_ind = 0
     SET ecnt += 1
     SET stat = alterlist(import_folders_reply->qual,ecnt)
     SET import_folders_reply->qual[ecnt].type = "POWERPLAN_NOT_FOUND"
     SET import_folders_reply->qual[ecnt].desc = plan_desc
    ENDIF
   ENDIF
   CALL log_message(build("Exit findPowerplan(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (findregimen(regimen_desc=vc) =null)
   CALL log_message("Begin findRegimen()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   IF (regimen_desc > " ")
    SELECT INTO "nl:"
     FROM regimen_cat_synonym rcs
     PLAN (rcs
      WHERE rcs.synonym_display=regimen_desc)
     DETAIL
      regimen_syn_id = rcs.regimen_cat_synonym_id, list_type = 7
     WITH nocounter
    ;end select
    IF (regimen_syn_id=0)
     SET add_ind = 0
     SET ecnt += 1
     SET stat = alterlist(import_folders_reply->qual,ecnt)
     SET import_folders_reply->qual[ecnt].type = "REGIMEN_NOT_FOUND"
     SET import_folders_reply->qual[ecnt].desc = regimen_desc
    ENDIF
   ENDIF
   CALL log_message(build("Exit findRegimen(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (findorcreateordersentence(folderindex=i4,itemindex=i4) =null)
   CALL log_message("Begin findOrCreateOrderSentence()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE altselcat = vc WITH constant("ALT_SEL_CAT"), protect
   DECLARE detailscntr = i4 WITH noconstant(0), protect
   DECLARE sentcnt = i4 WITH noconstant(0), protect
   DECLARE ordercatsyn = vc WITH constant("ORDER_CATALOG_SYNONYM"), protect
   IF (size(folder_details->folders[folderindex].item[itemindex].details,5) > 0
    AND synonym_id > 0)
    SELECT INTO "nl:"
     FROM order_sentence os
     PLAN (os
      WHERE (os.order_sentence_display_line=folder_details->folders[folderindex].item[itemindex].
      display)
       AND os.oe_format_id=format_id
       AND os.parent_entity_id=synonym_id
       AND os.parent_entity2_id=0)
     DETAIL
      sentence_id = os.order_sentence_id
     WITH nocounter
    ;end select
    IF (sentence_id=0.0)
     SET stat = alterlist(500350_request->order_sentence_list,1)
     SET 500350_request->order_sentence_list[1].order_sentence_id = 0.0
     SET 500350_request->order_sentence_list[1].order_sentence_display_line = folder_details->
     folders[folderindex].item[itemindex].display
     SET 500350_request->order_sentence_list[1].oe_format_id = folder_details->folders[folderindex].
     item[itemindex].format_id
     SET 500350_request->order_sentence_list[1].parent_entity_name = ordercatsyn
     SET 500350_request->order_sentence_list[1].parent_entity_id = synonym_id
     SET 500350_request->order_sentence_list[1].parent_entity2_name = altselcat
     SET 500350_request->order_sentence_list[1].parent_entity2_id = new_folder_id
     SET 500350_request->order_sentence_list[1].order_encntr_group_cd = 0.0
     SET 500350_request->order_sentence_list[1].display_seq = 0
     SET 500350_request->order_sentence_list[1].discern_auto_verify_flag = 0
     SET 500350_request->order_sentence_list[1].ic_auto_verify_flag = 0
     SET 500350_request->order_sentence_list[1].usage_flag = folder_details->folders[folderindex].
     item[itemindex].usage_flag
     SET 500350_request->order_sentence_list[1].ord_comment_long_text = ""
     SET 500350_request->order_sentence_list[1].rx_type_mean = ""
     SET stat = alterlist(500350_request->order_sentence_list[1].facilities_list,1)
     SET 500350_request->order_sentence_list[1].facilities_list[1].facility_cd = 0.0
     FOR (detailscntr = 1 TO size(folder_details->folders[fldrcntr].item[1].details,5))
       SET stat = alterlist(500350_request->order_sentence_list[1].detail_list,detailscntr)
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].oe_field_id =
       folder_details->folders[fldrcntr].item[itemcntr].details[detailscntr].oe_field_id
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].oe_field_display_value =
       folder_details->folders[fldrcntr].item[itemcntr].details[detailscntr].oe_field_display_value
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].oe_field_value =
       folder_details->folders[fldrcntr].item[itemcntr].details[detailscntr].oe_field_value
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].oe_field_meaning_id =
       folder_details->folders[fldrcntr].item[itemcntr].details[detailscntr].oe_field_meaning_id
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].field_type_flag =
       folder_details->folders[fldrcntr].item[itemcntr].details[detailscntr].field_type_flag
       SET 500350_request->order_sentence_list[1].detail_list[detailscntr].sequence = folder_details
       ->folders[fldrcntr].item[itemcntr].details[detailscntr].sequence
     ENDFOR
     SET stat = tdbexecute(500000,500010,500350,"REC",500350_request,
      "REC",500350_reply,1)
     IF ((500350_reply->status_data.status="S"))
      FOR (sentcnt = 1 TO size(500350_reply->order_sentence_list,5))
        IF ((500350_reply->order_sentence_list[sentcnt].success_ind=1)
         AND (500350_reply->order_sentence_list[sentcnt].order_sentence_id > 0))
         SET sentence_id = 500350_reply->order_sentence_list[sentcnt].order_sentence_id
         SET list_type = 2
        ELSE
         SET add_ind = 0
         SET ecnt += 1
         SET stat = alterlist(import_folders_reply->qual,ecnt)
         SET import_folders_reply->qual[ecnt].type = "COULD_NOT_CREATE_ORDER_SENTENCE"
         SET import_folders_reply->qual[ecnt].desc = folder_details->folders[fldrcntr].item[itemcntr]
         .display
        ENDIF
      ENDFOR
     ELSE
      SET add_ind = 0
      SET ecnt += 1
      SET stat = alterlist(import_folders_reply->qual,ecnt)
      SET import_folders_reply->qual[ecnt].type = "COULD_NOT_CREATE_ORDER_SENTENCE"
      SET import_folders_reply->qual[ecnt].desc = folder_details->folders[fldrcntr].item[itemcntr].
      display
     ENDIF
    ENDIF
   ENDIF
   CALL log_message(build("Exit findOrCreateOrderSentence(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE importfolders(null)
   CALL log_message("Begin importFolders()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   FOR (fldrcntr = 1 TO size(folder_details->folders,5))
     SET stat = initrec(orm_upd_request)
     SET short_desc = folder_details->folders[fldrcntr].short_desc
     SET long_desc = folder_details->folders[fldrcntr].long_desc
     SET new_folder_id = 0.0
     SET existing_folder_id = 0.0
     CALL getexistingfolderid(long_desc)
     IF (existing_folder_id=0)
      CALL insertorderfolder(long_desc,short_desc)
      IF ((orm_add_reply->status_data.status="S"))
       SET new_folder_id = orm_add_reply->alt_sel_category_id
       SET lseq = 0
       SET stat = initrec(orm_upd_request)
       SET orm_upd_request->alt_sel_category_id = new_folder_id
       SET orm_upd_request->short_description = short_desc
       SET orm_upd_request->long_description = long_desc
       SET orm_upd_request->security_flag = 2
       FOR (itemcntr = 1 TO size(folder_details->folders[fldrcntr].item,5))
         SET format_id = 0.0
         SET synonym_id = 0.0
         SET sentence_id = 0.0
         SET pathway_cat_id = 0.0
         SET pathway_syn_id = 0.0
         SET regimen_syn_id = 0.0
         SET list_type = 0
         SET add_ind = 1
         CALL findsynonym(fldrcntr,itemcntr)
         CALL findpowerplan(folder_details->folders[fldrcntr].item[itemcntr].plan_desc)
         CALL findregimen(folder_details->folders[fldrcntr].item[itemcntr].regimen_desc)
         CALL findorcreateordersentence(fldrcntr,itemcntr)
         IF (add_ind=1)
          SET lseq += 1
          SET orm_upd_request->aosadd_cnt = lseq
          SET stat = alterlist(orm_upd_request->aosadd_qual,lseq)
          SET orm_upd_request->aosadd_qual[lseq].sequence = lseq
          SET orm_upd_request->aosadd_qual[lseq].list_type = list_type
          SET orm_upd_request->aosadd_qual[lseq].synonym_id = synonym_id
          SET orm_upd_request->aosadd_qual[lseq].order_sentence_id = sentence_id
          SET orm_upd_request->aosadd_qual[lseq].pathway_catalog_id = pathway_cat_id
          SET orm_upd_request->aosadd_qual[lseq].pw_cat_synonym_id = pathway_syn_id
          SET orm_upd_request->aosadd_qual[lseq].regimen_cat_synonym_id = regimen_syn_id
         ENDIF
       ENDFOR
       EXECUTE orm_upd_aos_cat_info  WITH replace("REQUEST",orm_upd_request), replace("REPLY",
        orm_upd_reply)
       IF ((orm_upd_reply->status_data.status="F"))
        SET ecnt += 1
        SET stat = alterlist(import_folders_reply->qual,ecnt)
        SET import_folders_reply->qual[ecnt].type = "INSERT_ORDER_FOLDER_FAILED"
        SET import_folders_reply->qual[ecnt].desc = folder_details->folders[fldrcntr].long_desc
       ENDIF
      ELSE
       SET add_ind = 0
       SET ecnt += 1
       SET stat = alterlist(import_folders_reply->qual,ecnt)
       SET import_folders_reply->qual[ecnt].type = "INSERT_ORDER_FOLDER_CONTENTS_FAILED"
       SET import_folders_reply->qual[ecnt].desc = folder_details->folders[fldrcntr].long_desc
      ENDIF
     ELSE
      SET ecnt += 1
      SET stat = alterlist(import_folders_reply->qual,ecnt)
      SET import_folders_reply->qual[ecnt].type = "DUPLICATE_ORDER_FOLDER"
      SET import_folders_reply->qual[ecnt].desc = folder_details->folders[fldrcntr].long_desc
     ENDIF
   ENDFOR
   CALL log_message(build("Exit importFolders(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(import_folders_reply)
 ENDIF
 CALL putjsonrecordtofile(import_folders_reply, $OUTDEV)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - current_date_time2)/ 100.0)),
  log_level_debug)
END GO
