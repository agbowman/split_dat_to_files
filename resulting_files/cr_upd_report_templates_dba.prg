CREATE PROGRAM cr_upd_report_templates:dba
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
 SET log_program_name = "CR_UPD_REPORT_TEMPLATES"
 CALL log_message("Starting script: cr_upd_report_templates",log_level_debug)
 IF ( NOT (validate(reply,0)))
  FREE RECORD reply
  RECORD reply(
    1 template_id = f8
    1 updt_cnt = i4
    1 version_dt_tm = dq8
    1 section_catalog
      2 item[*]
        3 section_id = f8
        3 updt_cnt = i4
        3 version_dt_tm = dq8
    1 static_region_catalog
      2 item[*]
        3 static_region_id = f8
        3 updt_cnt = i4
        3 version_dt_tm = dq8
    1 style_profile_catalog
      2 style_profile_id = f8
      2 updt_cnt = i4
      2 version_dt_tm = dq8
    1 update_data
      2 target_object_id = vc
      2 submitted_updt_cnt = i4
      2 latest_updt_cnt = i4
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 updt_applctx = i4
      2 updt_task = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp_template
 RECORD temp_template(
   1 report_template_id = f8
   1 template_id = f8
   1 template_name = vc
   1 template_name_key = vc
   1 name_ident = vc
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 long_text_id = f8
   1 active_ind = i2
   1 updt_id = f8
   1 updt_dt_tm = dq8
   1 updt_task = i4
   1 updt_applctx = i4
   1 updt_cnt = i4
   1 report_style_profile_id = f8
   1 facesheet_id = f8
   1 portrait_watermark_id = f8
   1 landscape_watermark_id = f8
   1 lab_legend_id = f8
   1 micro_legend_id = f8
   1 pat_care_legend_id = f8
   1 summary_type_cd = f8
 )
 FREE RECORD temp_snapshot
 RECORD temp_snapshot(
   1 qual[*]
     2 template_snapshot_id = f8
     2 template_id = f8
     2 section_id = f8
     2 static_region_id = f8
     2 sequence_nbr = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 page_break_after_ind = i2
 )
 FREE RECORD snapshot_seq
 RECORD snapshot_seq(
   1 qual[*]
     2 snapshot_id = f8
 )
 DECLARE lselectresult = i4 WITH protect, noconstant(0)
 DECLARE dexistingtemplateid = f8 WITH protect, noconstant(0.0)
 DECLARE dreporttemplateid = f8 WITH protect, noconstant(0.0)
 DECLARE dlongtextid = f8 WITH protect, noconstant(0.0)
 DECLARE dstyleprofileid = f8 WITH protect, noconstant(0.0)
 DECLARE dsnapshotid = f8 WITH protect, noconstant(0.0)
 DECLARE dpositionreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE lnumofsectionrows = i4 WITH protect, noconstant(0)
 DECLARE lnumofregionrows = i4 WITH protect, noconstant(0)
 DECLARE currentdatetime = q8 WITH public, constant(cnvtdatetime(sysdate))
 DECLARE existingsnapshot = i2 WITH protect, noconstant(0)
 DECLARE existingpositionreltn = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect
 DECLARE stemplatenamekey = vc WITH protect
 DECLARE dsystemdate = f8 WITH protect
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE nnew_pos = i2 WITH protect, constant(0)
 DECLARE nnew_snap_shot = i2 WITH protect, constant(1)
 DECLARE nnew_temp = i2 WITH protect, constant(2)
 DECLARE nnew_temp_long_text = i2 WITH protect, constant(3)
 DECLARE insertnewtemplate(null) = null
 DECLARE modifytemplate(null) = null
 DECLARE modifysnapshot(null) = null
 DECLARE insertnewsnapshot(null) = null
 DECLARE populatetempsnapshot(null) = null
 DECLARE updatesections(null) = null
 DECLARE updateregions(null) = null
 DECLARE updatestyleprofiles(null) = null
 DECLARE insertnewpositions(templateid=f8) = null
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL echo(build("Commit_ind 0 - ",reqinfo->commit_ind))
 SET errmsg = fillstring(132," ")
 SET reply->template_id = request->template_id
 SET reply->updt_cnt = request->updt_cnt
 SET lnumofsectionrows = size(request->cr_report_section,5)
 SET lnumofregionrows = size(request->cr_report_static_region,5)
 SET dstyleprofileid = request->cr_report_style_profile.style_profile_id
 CALL echo(build("Number of Section Rows Passed In:  ",lnumofsectionrows))
 CALL echo(build("Number of Region Rows Passed In:  ",lnumofregionrows))
 IF (lnumofsectionrows > 0)
  CALL updatesections(null)
 ENDIF
 IF (lnumofregionrows > 0)
  CALL updateregions(null)
 ENDIF
 IF ((((request->cr_report_style_profile.xml_detail_dirty_ind=1)) OR ((request->
 cr_report_style_profile.style_profile_dirty_ind=1))) )
  CALL updatestyleprofiles(null)
 ELSE
  SET reply->style_profile_catalog.style_profile_id = dstyleprofileid
  SET reply->style_profile_catalog.updt_cnt = request->cr_report_style_profile.updt_cnt
 ENDIF
 IF ((request->template_id=0))
  SET dexistingtemplateid = getidofexistinginactivetemplate(request->template_name)
  SET request->template_id = dexistingtemplateid
 ENDIF
 IF ((((request->xml_detail_dirty_ind=1)) OR ((request->template_dirty_ind=1))) )
  IF ((request->template_id=0))
   CALL insertnewtemplate(null)
  ELSE
   CALL modifytemplate(null)
  ENDIF
 ENDIF
 IF ((request->relation_dirty_ind=1))
  SELECT INTO "nl:"
   FROM cr_template_snapshot cts
   WHERE (cts.template_id=request->template_id)
    AND cts.template_id > 0
   DETAIL
    existingsnapshot = 1
   WITH nocounter
  ;end select
  IF (existingsnapshot=0)
   CALL insertnewsnapshot(null)
  ELSE
   CALL modifysnapshot(null)
  ENDIF
 ENDIF
 IF (validate(request->positions_dirty_ind,0)=1)
  IF ((request->template_id > 0))
   CALL insertpositions(request->template_id)
  ELSE
   CALL insertpositions(dreporttemplateid)
  ENDIF
 ENDIF
 SUBROUTINE insertpositions(dtemplateid)
   CALL log_message("Entered InsertPositions subroutine.",log_level_debug)
   UPDATE  FROM cr_template_position_reltn ctp
    SET ctp.end_effective_dt_tm = cnvtdatetime(currentdatetime), ctp.active_ind = 0, ctp.updt_cnt = (
     ctp.updt_cnt+ 1),
     ctp.updt_dt_tm = cnvtdatetime(currentdatetime), ctp.updt_id = reqinfo->updt_id, ctp.updt_task =
     reqinfo->updt_task,
     ctp.updt_applctx = reqinfo->updt_applctx
    WHERE ctp.template_id=dtemplateid
     AND ctp.active_ind=1
   ;end update
   DECLARE positioncount = i4 WITH noconstant(0)
   DECLARE lpositioncnt = i4 WITH noconstant(0)
   SET positioncount = size(request->positions,5)
   IF (positioncount > 0)
    FOR (lpositioncnt = 1 TO positioncount)
     CALL createsequences(nnew_pos)
     INSERT  FROM cr_template_position_reltn ctp
      SET ctp.cr_template_position_reltn_id = dpositionreltnid, ctp.template_id = dtemplateid, ctp
       .position_cd = request->positions[lpositioncnt].position_cd,
       ctp.beg_effective_dt_tm = cnvtdatetime(currentdatetime), ctp.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"), ctp.active_ind = 1,
       ctp.updt_cnt = 0, ctp.updt_dt_tm = cnvtdatetime(currentdatetime), ctp.updt_id = reqinfo->
       updt_id,
       ctp.updt_task = reqinfo->updt_task, ctp.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDFOR
    CALL error_and_zero_check(curqual,"InsertPositions",
     "CR_TEMPLATE_POSITION_RELTN table could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertPositions subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertnewtemplate(null)
   CALL echo("In InsertNewTemplate")
   CALL log_message("Entered InsertNewTemplate subroutine.",log_level_debug)
   IF ((request->xml_detail_dirty_ind=1))
    CALL createsequences(nnew_temp_long_text)
    CALL insertlongtext(0)
   ELSE
    CALL createsequences(nnew_temp)
   ENDIF
   SET stemplatenamekey = trim(cnvtupper(cnvtalphanum(request->template_name)),3)
   SET dsystemdate = sysdate
   INSERT  FROM cr_report_template crt
    SET crt.report_template_id = dreporttemplateid, crt.template_id = dreporttemplateid, crt
     .template_name = request->template_name,
     crt.template_name_key = stemplatenamekey, crt.name_ident = concat(stemplatenamekey,cnvtstring(
       dsystemdate)), crt.long_text_id = dlongtextid,
     crt.active_ind = request->active_ind, crt.beg_effective_dt_tm = cnvtdatetime(currentdatetime),
     crt.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     crt.updt_cnt = 0, crt.updt_dt_tm = cnvtdatetime(currentdatetime), crt.updt_id = reqinfo->updt_id,
     crt.updt_task = reqinfo->updt_task, crt.updt_applctx = reqinfo->updt_applctx, crt
     .report_style_profile_id = dstyleprofileid,
     crt.facesheet_id = request->facesheet_id, crt.portrait_watermark_id = request->
     portrait_watermark_id, crt.landscape_watermark_id = request->landscape_watermark_id,
     crt.lab_legend_id = request->lab_legend_id, crt.micro_legend_id = request->micro_legend_id, crt
     .pat_care_legend_id = request->pat_care_legend_id,
     crt.summary_type_cd = request->summary_type_cd
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertNewTemplate",
    "CR_Report_Template table could not be updated.  Exiting script.",1,1)
   SET reply->template_id = dreporttemplateid
   SET reply->updt_cnt = 0
   SET reply->version_dt_tm = cnvtdatetime(currentdatetime)
   CALL log_message("Exiting InsertNewTemplate subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE modifytemplate(null)
   CALL echo("In InModifyTemplate")
   CALL log_message("Entered ModifyTemplate subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE (crt.template_id=request->template_id)
     AND (crt.report_template_id=request->template_id)
    DETAIL
     temp_template->report_template_id = crt.report_template_id, temp_template->template_id = crt
     .template_id, temp_template->template_name = crt.template_name,
     temp_template->template_name_key = crt.template_name_key, temp_template->name_ident = crt
     .name_ident, temp_template->beg_effective_dt_tm = crt.beg_effective_dt_tm,
     temp_template->end_effective_dt_tm = cnvtdatetime(currentdatetime), temp_template->long_text_id
      = crt.long_text_id, temp_template->active_ind = crt.active_ind,
     temp_template->updt_id = crt.updt_id, temp_template->updt_task = crt.updt_task, temp_template->
     updt_dt_tm = crt.updt_dt_tm,
     temp_template->updt_applctx = crt.updt_applctx, temp_template->updt_cnt = crt.updt_cnt,
     temp_template->report_style_profile_id = crt.report_style_profile_id,
     temp_template->facesheet_id = crt.facesheet_id, temp_template->portrait_watermark_id = crt
     .portrait_watermark_id, temp_template->landscape_watermark_id = crt.landscape_watermark_id,
     temp_template->lab_legend_id = crt.lab_legend_id, temp_template->micro_legend_id = crt
     .micro_legend_id, temp_template->pat_care_legend_id = crt.pat_care_legend_id,
     temp_template->summary_type_cd = crt.summary_type_cd
    WITH nocounter, forupdate(crt)
   ;end select
   CALL error_and_zero_check(curqual,"ModifyTemplate",
    "Could not perform Select against CR_REPORT_TEMPLATE.  Exiting script.",1,1)
   IF ((request->updt_cnt=temp_template->updt_cnt))
    SET stemplatenamekey = trim(cnvtupper(cnvtalphanum(request->template_name)),3)
    SET dsystemdate = sysdate
    IF ((request->xml_detail_dirty_ind=1))
     CALL createsequences(nnew_temp_long_text)
     CALL insertlongtext(1)
    ELSE
     CALL createsequences(nnew_temp)
     SET dlongtextid = temp_template->long_text_id
    ENDIF
    UPDATE  FROM cr_report_template crt
     SET crt.template_name = request->template_name, crt.template_name_key = stemplatenamekey, crt
      .name_ident = concat(stemplatenamekey,cnvtstring(dsystemdate)),
      crt.beg_effective_dt_tm = cnvtdatetime(currentdatetime), crt.long_text_id = dlongtextid, crt
      .active_ind = request->active_ind,
      crt.updt_cnt = (request->updt_cnt+ 1), crt.updt_dt_tm = cnvtdatetime(currentdatetime), crt
      .updt_id = reqinfo->updt_id,
      crt.updt_task = reqinfo->updt_task, crt.updt_applctx = reqinfo->updt_applctx, crt
      .report_style_profile_id = dstyleprofileid,
      crt.facesheet_id = request->facesheet_id, crt.portrait_watermark_id = request->
      portrait_watermark_id, crt.landscape_watermark_id = request->landscape_watermark_id,
      crt.lab_legend_id = request->lab_legend_id, crt.micro_legend_id = request->micro_legend_id, crt
      .pat_care_legend_id = request->pat_care_legend_id,
      crt.summary_type_cd = request->summary_type_cd
     WHERE (crt.report_template_id=request->template_id)
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyTemplate",
     "Old CR_REPORT_TEMPLATE row could not be updated.  Exiting script.",1,1)
    INSERT  FROM cr_report_template crt
     SET crt.report_template_id = dreporttemplateid, crt.template_id = temp_template->template_id,
      crt.template_name = temp_template->template_name,
      crt.template_name_key = temp_template->template_name_key, crt.name_ident = temp_template->
      name_ident, crt.long_text_id = temp_template->long_text_id,
      crt.active_ind = temp_template->active_ind, crt.beg_effective_dt_tm = cnvtdatetime(
       temp_template->beg_effective_dt_tm), crt.end_effective_dt_tm = cnvtdatetime(currentdatetime),
      crt.updt_cnt = temp_template->updt_cnt, crt.updt_dt_tm = cnvtdatetime(temp_template->updt_dt_tm
       ), crt.updt_id = temp_template->updt_id,
      crt.updt_task = temp_template->updt_task, crt.updt_applctx = temp_template->updt_applctx, crt
      .report_style_profile_id = temp_template->report_style_profile_id,
      crt.facesheet_id = temp_template->facesheet_id, crt.portrait_watermark_id = temp_template->
      portrait_watermark_id, crt.landscape_watermark_id = temp_template->landscape_watermark_id,
      crt.lab_legend_id = temp_template->lab_legend_id, crt.micro_legend_id = temp_template->
      micro_legend_id, crt.pat_care_legend_id = temp_template->pat_care_legend_id,
      crt.summary_type_cd = temp_template->summary_type_cd
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"ModifyTemplate",
     "New CR_REPORT_TEMPLATE row could not be created.  Exiting script.",1,1)
    SET reply->template_id = request->template_id
    SET reply->updt_cnt = (request->updt_cnt+ 1)
    SET reply->version_dt_tm = cnvtdatetime(currentdatetime)
   ELSE
    SET reply->status_data.status = "U"
    SET reply->update_data.target_object_id = build("CR_REPORT_TEMPLATE#",temp_template->template_id)
    SET reply->update_data.submitted_updt_cnt = request->updt_cnt
    SET reply->update_data.latest_updt_cnt = temp_template->updt_cnt
    SET reply->update_data.updt_dt_tm = temp_template->updt_dt_tm
    SET reply->update_data.updt_id = temp_template->updt_id
    SET reply->update_data.updt_applctx = temp_template->updt_applctx
    SET reply->update_data.updt_task = temp_template->updt_task
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting ModifyTemplate subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE insertnewsnapshot(null)
   CALL echo("In InsertNewSnapshot")
   CALL log_message("Entered InsertNewSnapshot subroutine.",log_level_debug)
   CALL populatetempsnapshot(null)
   CALL createsequences(nnew_snap_shot)
   DECLARE insertsnapcnt = i4 WITH noconstant(0)
   SET insertsnapcnt = size(temp_snapshot->qual,5)
   INSERT  FROM (dummyt d1  WITH seq = value(insertsnapcnt)),
     cr_template_snapshot cts
    SET cts.template_snapshot_id = snapshot_seq->qual[d1.seq].snapshot_id, cts.template_id =
     temp_snapshot->qual[d1.seq].template_id, cts.section_id = temp_snapshot->qual[d1.seq].section_id,
     cts.sequence_nbr = temp_snapshot->qual[d1.seq].sequence_nbr, cts.static_region_id =
     temp_snapshot->qual[d1.seq].static_region_id, cts.page_break_after_ind = temp_snapshot->qual[d1
     .seq].page_break_after_ind,
     cts.beg_effective_dt_tm = cnvtdatetime(currentdatetime), cts.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), cts.active_ind = 1,
     cts.updt_cnt = 0, cts.updt_dt_tm = cnvtdatetime(currentdatetime), cts.updt_id = reqinfo->updt_id,
     cts.updt_task = reqinfo->updt_task, cts.updt_applctx = reqinfo->updt_applctx
    PLAN (d1)
     JOIN (cts)
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertNewSnapshot",
    "CR_Template_Snapshot table could not be updated.  Exiting script.",1,1)
   CALL log_message("Exiting InsertNewSnapshot subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE modifysnapshot(null)
   CALL echo("In ModifySnapshot")
   CALL log_message("Entered ModifySnapshot subroutine.",log_level_debug)
   CALL populatetempsnapshot(null)
   DECLARE insertmodsnapcnt = i4 WITH noconstant(0)
   SET insertmodsnapcnt = size(temp_snapshot->qual,5)
   CALL echo(build("insertmodsnapcnt = ",insertmodsnapcnt))
   DECLARE max_date = q8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM cr_template_snapshot cts
    PLAN (cts
     WHERE (cts.template_id=request->template_id))
    ORDER BY cts.end_effective_dt_tm
    FOOT  cts.end_effective_dt_tm
     max_date = cts.end_effective_dt_tm
    WITH nocounter
   ;end select
   CALL echo(build("Maximum snapshot date = ",format(cnvtdatetime(max_date),";;q")))
   SELECT INTO "nl:"
    updt_cnt = cts.updt_cnt
    FROM cr_template_snapshot cts
    PLAN (cts
     WHERE (cts.template_id=request->template_id)
      AND cts.end_effective_dt_tm >= cnvtdatetime(max_date))
    DETAIL
     IF (updt_cnt != 0)
      lselectresult = nupdate_cnt_error
     ENDIF
    WITH nocounter, forupdate(cts)
   ;end select
   IF (lselectresult=nupdate_cnt_error)
    CALL error_and_zero_check(0,"ModifySnapshot",
     "CR_Template_Snapshot row could not be locked.  Exiting script.",1,1)
   ELSEIF (error_message(1) > 0)
    CALL error_and_zero_check(curqual,"ModifySnapshot",
     "CR_Template_Snapshot row could not be locked.  Exiting script.",1,1)
   ENDIF
   UPDATE  FROM cr_template_snapshot cts
    SET cts.end_effective_dt_tm = cnvtdatetime(currentdatetime), cts.active_ind = 0
    WHERE (cts.template_id=request->template_id)
     AND cts.end_effective_dt_tm >= cnvtdatetime(max_date)
    WITH nocounter
   ;end update
   CALL error_and_zero_check(curqual,"ModifySnapshot",
    "Could not update the existing rows on Cr_Template_Snapshot.  Exiting script.",1,1)
   CALL createsequences(nnew_snap_shot)
   IF (insertmodsnapcnt > 0)
    INSERT  FROM (dummyt d1  WITH seq = value(insertmodsnapcnt)),
      cr_template_snapshot cts
     SET cts.template_snapshot_id = snapshot_seq->qual[d1.seq].snapshot_id, cts.template_id =
      temp_snapshot->qual[d1.seq].template_id, cts.section_id = temp_snapshot->qual[d1.seq].
      section_id,
      cts.sequence_nbr = temp_snapshot->qual[d1.seq].sequence_nbr, cts.static_region_id =
      temp_snapshot->qual[d1.seq].static_region_id, cts.page_break_after_ind = temp_snapshot->qual[d1
      .seq].page_break_after_ind,
      cts.beg_effective_dt_tm = cnvtdatetime(currentdatetime), cts.end_effective_dt_tm = cnvtdatetime
      ("31-DEC-2100"), cts.active_ind = 1,
      cts.updt_cnt = 0, cts.updt_dt_tm = cnvtdatetime(currentdatetime), cts.updt_id = reqinfo->
      updt_id,
      cts.updt_task = reqinfo->updt_task, cts.updt_applctx = reqinfo->updt_applctx
     PLAN (d1)
      JOIN (cts)
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"ModifySnapshot",
     "CR_Template_Snapshot table could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting ModifySnapshot subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE populatetempsnapshot(null)
   CALL echo("In PopulateSnapshot")
   CALL log_message("Entered PopulateTempSnapshot subroutine.",log_level_debug)
   IF (((lnumofsectionrows > 0) OR (lnumofregionrows > 0)) )
    SET stat = alterlist(temp_snapshot->qual,(lnumofsectionrows+ lnumofregionrows))
    FOR (x = 1 TO lnumofsectionrows)
      IF ((request->template_id > 0))
       SET temp_snapshot->qual[x].template_id = request->template_id
      ELSE
       SET temp_snapshot->qual[x].template_id = dreporttemplateid
      ENDIF
      SET temp_snapshot->qual[x].static_region_id = 0
      IF ((request->cr_report_section[x].section_dirty_ind=1))
       SET temp_snapshot->qual[x].section_id = reply->section_catalog.item[x].section_id
      ELSE
       SET temp_snapshot->qual[x].section_id = request->cr_report_section[x].section_id
      ENDIF
      SET temp_snapshot->qual[x].sequence_nbr = request->cr_report_section[x].sequence_nbr
      SET temp_snapshot->qual[x].page_break_after_ind = request->cr_report_section[x].
      page_break_after_ind
      SET temp_snapshot->qual[x].beg_effective_dt_tm = cnvtdatetime(currentdatetime)
      SET temp_snapshot->qual[x].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    ENDFOR
    FOR (x = 1 TO lnumofregionrows)
      IF ((request->template_id > 0))
       SET temp_snapshot->qual[(x+ lnumofsectionrows)].template_id = request->template_id
      ELSE
       SET temp_snapshot->qual[(x+ lnumofsectionrows)].template_id = dreporttemplateid
      ENDIF
      IF ((request->cr_report_static_region[x].region_dirty_ind=1))
       SET temp_snapshot->qual[(x+ lnumofsectionrows)].static_region_id = reply->
       static_region_catalog.item[x].static_region_id
      ELSE
       SET temp_snapshot->qual[(x+ lnumofsectionrows)].static_region_id = request->
       cr_report_static_region[x].static_region_id
      ENDIF
      SET temp_snapshot->qual[(x+ lnumofsectionrows)].section_id = 0
      SET temp_snapshot->qual[(x+ lnumofsectionrows)].sequence_nbr = x
      SET temp_snapshot->qual[(x+ lnumofsectionrows)].page_break_after_ind = 0
      SET temp_snapshot->qual[(x+ lnumofsectionrows)].beg_effective_dt_tm = cnvtdatetime(
       currentdatetime)
      SET temp_snapshot->qual[(x+ lnumofsectionrows)].end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100")
    ENDFOR
   ENDIF
   CALL echorecord(temp_snapshot)
   CALL log_message("Exiting PopulateTempSnapshot subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatesections(null)
   CALL log_message("Entered UpdateSections subroutine.",log_level_debug)
   CALL echo("Before Section Script")
   EXECUTE cr_upd_report_sections
   SET reqinfo->commit_ind = 0
   IF ((reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
   CALL echo("After Section Script")
   CALL log_message("Exiting UpdateSections subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updateregions(null)
   CALL log_message("Entered UpdateRegions subroutine.",log_level_debug)
   CALL echo("Before Region Script")
   EXECUTE cr_upd_report_regions
   SET reqinfo->commit_ind = 0
   IF ((reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
   CALL echo("After Region Script")
   CALL log_message("Exiting UpdateRegions subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE updatestyleprofiles(null)
   CALL log_message("Entered UpdateStyleProfiles subroutine.",log_level_debug)
   CALL echo("Before Style Profile Script")
   FREE SET temp_request
   RECORD temp_request(
     1 cr_report_style_profile[*]
       2 style_profile_id = f8
       2 style_profile_name = vc
       2 xml_detail = vc
       2 updt_cnt = i4
       2 active_ind = i2
       2 sequence_nbr = i4
       2 xml_detail_dirty_ind = i2
       2 style_profile_dirty_ind = i2
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 style_profile_catalog
       2 item[*]
         3 style_profile_id = f8
         3 updt_cnt = i4
         3 version_dt_tm = dq8
     1 update_data
       2 target_object_id = vc
       2 submitted_updt_cnt = i4
       2 latest_updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_applctx = i4
       2 updt_task = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET stat = alterlist(temp_request->cr_report_style_profile,1)
   SET temp_request->cr_report_style_profile[1].style_profile_id = request->cr_report_style_profile.
   style_profile_id
   SET temp_request->cr_report_style_profile[1].style_profile_name = request->cr_report_style_profile
   .style_profile_name
   SET temp_request->cr_report_style_profile[1].xml_detail = request->cr_report_style_profile.
   xml_detail
   SET temp_request->cr_report_style_profile[1].updt_cnt = request->cr_report_style_profile.updt_cnt
   SET temp_request->cr_report_style_profile[1].active_ind = request->cr_report_style_profile.
   active_ind
   SET temp_request->cr_report_style_profile[1].xml_detail_dirty_ind = request->
   cr_report_style_profile.xml_detail_dirty_ind
   SET temp_request->cr_report_style_profile[1].style_profile_dirty_ind = request->
   cr_report_style_profile.style_profile_dirty_ind
   EXECUTE cr_upd_report_style_profiles  WITH replace("REQUEST",temp_request), replace("REPLY",
    temp_reply)
   SET reply->style_profile_catalog.style_profile_id = temp_reply->style_profile_catalog.item[1].
   style_profile_id
   SET dstyleprofileid = temp_reply->style_profile_catalog.item[1].style_profile_id
   SET reply->style_profile_catalog.updt_cnt = temp_reply->style_profile_catalog.item[1].updt_cnt
   SET reply->style_profile_catalog.version_dt_tm = temp_reply->style_profile_catalog.item[1].
   version_dt_tm
   SET reply->status_data.status = temp_reply->status_data.status
   SET reqinfo->commit_ind = 0
   IF ((reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
   CALL echo("After Style Profile Script")
   CALL log_message("Exiting UpdateStyleProfiles subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createsequences(seqind=i2) =null)
   CALL echo("In Create Sequence")
   CALL log_message("Entered CreateSequences subroutine.",log_level_debug)
   IF (seqind >= nnew_temp)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      dreporttemplateid = nextseqnum
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Template seq could not be created.  Exiting script.",1,1)
    SET dlongtextid = 0
    CALL echo(build("dReportTemplateId:  ",dreporttemplateid))
   ENDIF
   IF (seqind=nnew_temp_long_text)
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dlongtextid = nextseqnum
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Long_Text seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dLongTextId:  ",dlongtextid))
   ELSEIF (seqind=nnew_snap_shot)
    DECLARE insertseqcnt = i4 WITH noconstant(size(temp_snapshot->qual,5))
    DECLARE x = i4 WITH noconstant(0)
    CALL echo(build("insertSeqCnt = ",insertseqcnt))
    SET stat = alterlist(snapshot_seq->qual,insertseqcnt)
    FOR (x = 1 TO insertseqcnt)
      SELECT INTO "nl:"
       nextseqnum = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        snapshot_seq->qual[x].snapshot_id = nextseqnum
       WITH nocounter
      ;end select
    ENDFOR
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Snapshot seq could not be created.  Exiting script.",1,1)
    CALL echorecord(snapshot_seq)
   ELSEIF (seqind=nnew_pos)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      dpositionreltnid = nextseqnum
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Position Reltn seq could not be created.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting CreateSequences subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertlongtext(updtind=i2) =null)
   CALL echo("In InsertLongText")
   CALL log_message("Entered InsertLongtext subroutine.",log_level_debug)
   DECLARE tempparententityid = f8 WITH noconstant(0.0)
   IF (updtind=0)
    SET tempparententityid = dreporttemplateid
   ELSE
    SET tempparententityid = temp_template->report_template_id
   ENDIF
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = dlongtextid, ltr.long_text = request->xml_detail, ltr.parent_entity_id =
     tempparententityid,
     ltr.parent_entity_name = "CR_REPORT_TEMPLATE", ltr.active_ind = 1, ltr.active_status_cd =
     reqdata->active_status_cd,
     ltr.active_status_dt_tm = cnvtdatetime(currentdatetime), ltr.active_status_prsnl_id = reqinfo->
     updt_id, ltr.updt_cnt = 0,
     ltr.updt_dt_tm = cnvtdatetime(currentdatetime), ltr.updt_id = reqinfo->updt_id, ltr.updt_task =
     reqinfo->updt_task,
     ltr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertLongText",
    "Long_Text_Reference table could not be updated.  Exiting script.",1,1)
   IF (updtind=1)
    UPDATE  FROM long_text_reference ltr
     SET ltr.parent_entity_id = dreporttemplateid
     WHERE (ltr.long_text_id=temp_template->long_text_id)
      AND ltr.parent_entity_name="CR_REPORT_TEMPLATE"
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyLongTextReference",
     "Old Row could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertLongtext subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (getidofexistinginactivetemplate(templatename=vc) =f8)
   CALL log_message("Entered GetIdOfExistingInactiveTemplate subroutine.",log_level_debug)
   DECLARE templateid = f8 WITH noconstant(0.0)
   DECLARE activeind = i2 WITH noconstant(0)
   DECLARE updatecount = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM cr_report_template crt
    WHERE crt.template_name_key=trim(cnvtupper(cnvtalphanum(templatename)),3)
     AND crt.template_id=crt.report_template_id
    DETAIL
     IF (templatename=crt.template_name)
      templateid = crt.template_id, activeind = crt.active_ind, updatecount = crt.updt_cnt,
      BREAK
     ENDIF
    WITH nocounter
   ;end select
   IF (activeind=0)
    CALL log_message(concat("Reactivating template ",trim(cnvtstring(templateid)),
      " and adding new version"),log_level_debug)
    SET request->updt_cnt = updatecount
    RETURN(templateid)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = "GetIdOfExistingInactiveTemplate"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = curprog
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "This template cannot be inserted because an active template already exists with the name ",trim
     (templatename),". (id = ",trim(cnvtstring(templateid)),")")
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting GetIdOfExistingInactiveTemplate subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echo(build("Commit_ind 1 - ",reqinfo->commit_ind))
#exit_script
 FREE RECORD temp_templates
 FREE RECORD temp_snapshot
 CALL log_message("End of script: cr_upd_report_templates",log_level_debug)
 CALL echo(build("Commit_ind - ",reqinfo->commit_ind))
 CALL echorecord(reply)
END GO
