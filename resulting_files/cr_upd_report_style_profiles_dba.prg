CREATE PROGRAM cr_upd_report_style_profiles:dba
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
 SET log_program_name = "CR_UPD_REPORT_STYLE_PROFILES"
 CALL log_message("Starting script: cr_upd_report_style_profiles",log_level_debug)
 IF (validate(reply,0))
  CALL log_message("Called from parent script",log_level_debug)
 ELSE
  CALL log_message("Called from Front-End App",log_level_debug)
  FREE RECORD reply
  RECORD reply(
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
 ENDIF
 FREE RECORD temp_style_profile
 RECORD temp_style_profile(
   1 report_style_profile_id = f8
   1 style_profile_id = f8
   1 style_profile_name = vc
   1 style_profile_name_key = vc
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
 )
 DECLARE lselectresult = i4 WITH protect, noconstant(0)
 DECLARE dexistingstyleprofileid = f8 WITH protect, noconstant(0.0)
 DECLARE dreportstyleprofileid = f8 WITH protect, noconstant(0.0)
 DECLARE dlongtextid = f8 WITH protect, noconstant(0.0)
 DECLARE lnumofstyleprofiles = i4 WITH noconstant(0)
 DECLARE lstyleprofilecnt = i4 WITH noconstant(0)
 IF (validate(currentdatetime,1)=1)
  CALL echo("In if currentdatetime")
  DECLARE currentdatetime = q8 WITH protect, constant(cnvtdatetime(sysdate))
 ENDIF
 DECLARE errmsg = c132 WITH protect
 DECLARE sstyleprofilenamekey = c32 WITH protect
 DECLARE dsystemdate = f8 WITH protect
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 DECLARE nnew_style_profile = i2 WITH protect, constant(1)
 DECLARE nnew_style_profile_long_text = i2 WITH protect, constant(2)
 DECLARE insertnewstyleprofile(null) = null
 DECLARE modifystyleprofile(null) = null
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET reqinfo->commit_ind = 0
 CALL echo(build("Commit_ind 0 - ",reqinfo->commit_ind))
 SET lnumofstyleprofiles = size(request->cr_report_style_profile,5)
 SET stat = alterlist(reply->style_profile_catalog.item,lnumofstyleprofiles)
 FOR (lstyleprofilecnt = 1 TO lnumofstyleprofiles)
   IF ((request->cr_report_style_profile[lstyleprofilecnt].style_profile_id=0))
    SET dexistingstyleprofileid = getidofexistinginacativestyleprofile(request->
     cr_report_style_profile[lstyleprofilecnt].style_profile_name)
    IF (dexistingstyleprofileid=0)
     CALL insertnewstyleprofile(null)
    ELSE
     SET request->cr_report_style_profile[lstyleprofilecnt].style_profile_id =
     dexistingstyleprofileid
     CALL modifystyleprofile(null)
    ENDIF
   ELSEIF ((request->cr_report_style_profile[lstyleprofilecnt].style_profile_dirty_ind=1))
    CALL modifystyleprofile(null)
   ELSE
    SET reply->style_profile_catalog.item[lstyleprofilecnt].style_profile_id = request->
    cr_report_style_profile[lstyleprofilecnt].style_profile_id
    SET reply->style_profile_catalog.item[lstyleprofilecnt].updt_cnt = request->
    cr_report_style_profile[lstyleprofilecnt].updt_cnt
   ENDIF
 ENDFOR
 SUBROUTINE insertnewstyleprofile(null)
   CALL echo("In InsertNewStyleProfile")
   CALL log_message("Entered InsertNewStyleProfile subroutine.",log_level_debug)
   IF ((request->cr_report_style_profile[lstyleprofilecnt].xml_detail_dirty_ind=1))
    CALL createsequences(nnew_style_profile_long_text)
    CALL insertlongtext(0)
   ELSE
    CALL createsequences(nnew_style_profile)
   ENDIF
   SET sstyleprofilenamekey = trim(cnvtupper(cnvtalphanum(request->cr_report_style_profile[
      lstyleprofilecnt].style_profile_name)),3)
   SET dsystemdate = sysdate
   INSERT  FROM cr_report_style_profile crsp
    SET crsp.report_style_profile_id = dreportstyleprofileid, crsp.style_profile_id =
     dreportstyleprofileid, crsp.style_profile_name = request->cr_report_style_profile[
     lstyleprofilecnt].style_profile_name,
     crsp.style_profile_name_key = sstyleprofilenamekey, crsp.name_ident = concat(
      sstyleprofilenamekey,cnvtstring(dsystemdate)), crsp.long_text_id = dlongtextid,
     crsp.active_ind = request->cr_report_style_profile[lstyleprofilecnt].active_ind, crsp
     .beg_effective_dt_tm = cnvtdatetime(currentdatetime), crsp.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"),
     crsp.updt_cnt = 0, crsp.updt_dt_tm = cnvtdatetime(currentdatetime), crsp.updt_id = reqinfo->
     updt_id,
     crsp.updt_task = reqinfo->updt_task, crsp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertNewStyleProfile",
    "CR_Report_Style_Profile table could not be updated.  Exiting script.",1,1)
   SET reply->style_profile_catalog.item[lstyleprofilecnt].style_profile_id = dreportstyleprofileid
   SET reply->style_profile_catalog.item[lstyleprofilecnt].updt_cnt = 0
   SET reply->style_profile_catalog.item[lstyleprofilecnt].version_dt_tm = cnvtdatetime(
    currentdatetime)
   CALL log_message("Exiting InsertNewStyleProfile subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE modifystyleprofile(null)
   CALL echo("In ModifyStyleProfile")
   CALL log_message("Entered ModifyStyleProfile subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_report_style_profile crsp
    WHERE (crsp.style_profile_id=request->cr_report_style_profile[lstyleprofilecnt].style_profile_id)
     AND (crsp.report_style_profile_id=request->cr_report_style_profile[lstyleprofilecnt].
    style_profile_id)
    DETAIL
     temp_style_profile->report_style_profile_id = crsp.report_style_profile_id, temp_style_profile->
     style_profile_id = crsp.style_profile_id, temp_style_profile->style_profile_name = crsp
     .style_profile_name,
     temp_style_profile->style_profile_name_key = crsp.style_profile_name_key, temp_style_profile->
     name_ident = crsp.name_ident, temp_style_profile->beg_effective_dt_tm = crsp.beg_effective_dt_tm,
     temp_style_profile->end_effective_dt_tm = cnvtdatetime(currentdatetime), temp_style_profile->
     long_text_id = crsp.long_text_id, temp_style_profile->active_ind = crsp.active_ind,
     temp_style_profile->updt_id = crsp.updt_id, temp_style_profile->updt_task = crsp.updt_task,
     temp_style_profile->updt_dt_tm = crsp.updt_dt_tm,
     temp_style_profile->updt_applctx = crsp.updt_applctx, temp_style_profile->updt_cnt = crsp
     .updt_cnt
    WITH nocounter, forupdate(crs)
   ;end select
   CALL error_and_zero_check(curqual,"ModifyStyleProfile",
    "Could not perform Lock against CR_REPORT_STYLE_PROFILE.  Exiting script.",1,1)
   IF ((request->cr_report_style_profile[lstyleprofilecnt].updt_cnt=temp_style_profile->updt_cnt))
    SET sstyleprofilenamekey = trim(cnvtupper(cnvtalphanum(request->cr_report_style_profile[
       lstyleprofilecnt].style_profile_name)),3)
    SET dsystemdate = sysdate
    IF ((request->cr_report_style_profile[lstyleprofilecnt].xml_detail_dirty_ind=1))
     CALL createsequences(nnew_style_profile_long_text)
     CALL insertlongtext(1)
    ELSE
     CALL createsequences(nnew_style_profile)
     SET dlongtextid = temp_style_profile->long_text_id
    ENDIF
    UPDATE  FROM cr_report_style_profile crsp
     SET crsp.style_profile_name = request->cr_report_style_profile[lstyleprofilecnt].
      style_profile_name, crsp.style_profile_name_key = sstyleprofilenamekey, crsp.name_ident =
      concat(sstyleprofilenamekey,cnvtstring(dsystemdate)),
      crsp.beg_effective_dt_tm = cnvtdatetime(currentdatetime), crsp.long_text_id = dlongtextid, crsp
      .active_ind = request->cr_report_style_profile[lstyleprofilecnt].active_ind,
      crsp.updt_cnt = (request->cr_report_style_profile[lstyleprofilecnt].updt_cnt+ 1), crsp
      .updt_dt_tm = cnvtdatetime(currentdatetime), crsp.updt_id = reqinfo->updt_id,
      crsp.updt_task = reqinfo->updt_task, crsp.updt_applctx = reqinfo->updt_applctx
     WHERE (crsp.report_style_profile_id=request->cr_report_style_profile[lstyleprofilecnt].
     style_profile_id)
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyStyleProfile",
     "Old Row could not be updated.  Exiting script.",1,1)
    INSERT  FROM cr_report_style_profile crsp
     SET crsp.report_style_profile_id = dreportstyleprofileid, crsp.style_profile_id =
      temp_style_profile->style_profile_id, crsp.style_profile_name = temp_style_profile->
      style_profile_name,
      crsp.style_profile_name_key = temp_style_profile->style_profile_name_key, crsp.name_ident =
      temp_style_profile->name_ident, crsp.long_text_id = temp_style_profile->long_text_id,
      crsp.active_ind = temp_style_profile->active_ind, crsp.beg_effective_dt_tm = cnvtdatetime(
       temp_style_profile->beg_effective_dt_tm), crsp.end_effective_dt_tm = cnvtdatetime(
       currentdatetime),
      crsp.updt_cnt = temp_style_profile->updt_cnt, crsp.updt_dt_tm = cnvtdatetime(temp_style_profile
       ->updt_dt_tm), crsp.updt_id = temp_style_profile->updt_id,
      crsp.updt_task = temp_style_profile->updt_task, crsp.updt_applctx = temp_style_profile->
      updt_applctx
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"ModifyStyleProfile",
     "New Row could not be created.  Exiting script.",1,1)
    SET reply->style_profile_catalog.item[lstyleprofilecnt].style_profile_id = request->
    cr_report_style_profile[lstyleprofilecnt].style_profile_id
    SET reply->style_profile_catalog.item[lstyleprofilecnt].updt_cnt = (request->
    cr_report_style_profile[lstyleprofilecnt].updt_cnt+ 1)
    SET reply->style_profile_catalog.item[lstyleprofilecnt].version_dt_tm = cnvtdatetime(
     currentdatetime)
   ELSE
    SET reply->status_data.status = "U"
    SET reply->update_data.target_object_id = build("CR_REPORT_STYLE_PROFILE#",temp_style_profile->
     style_profile_id)
    SET reply->update_data.submitted_updt_cnt = request->cr_report_style_profile[lstyleprofilecnt].
    updt_cnt
    SET reply->update_data.latest_updt_cnt = temp_style_profile->updt_cnt
    SET reply->update_data.updt_dt_tm = temp_style_profile->updt_dt_tm
    SET reply->update_data.updt_id = temp_style_profile->updt_id
    SET reply->update_data.updt_applctx = temp_style_profile->updt_applctx
    SET reply->update_data.updt_task = temp_style_profile->updt_task
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting ModifyStyleProfile subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createsequences(seqind=i2) =null)
   CALL echo("In CreateSequences")
   CALL log_message("Entered CreateSequences subroutine.",log_level_debug)
   IF (seqind >= nnew_style_profile)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dreportstyleprofileid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "StyleProfile seq could not be created.  Exiting script.",1,1)
    SET dlongtextid = 0
   ENDIF
   IF (seqind=nnew_style_profile_long_text)
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dlongtextid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Long_Text seq could not be created.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting CreateSequences subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertlongtext(updtind=i2) =null)
   CALL echo("In InsertLongText")
   CALL log_message("Entered InsertLongtext subroutine.",log_level_debug)
   DECLARE parententityid = f8 WITH noconstant(0.0)
   IF (updtind=0)
    SET parententityid = dreportstyleprofileid
   ELSE
    SET parententityid = temp_style_profile->report_style_profile_id
   ENDIF
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = dlongtextid, ltr.long_text = request->cr_report_style_profile[
     lstyleprofilecnt].xml_detail, ltr.parent_entity_id = parententityid,
     ltr.parent_entity_name = "CR_REPORT_STYLE_PROFILE", ltr.active_ind = 1, ltr.active_status_cd =
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
     SET ltr.parent_entity_id = dreportstyleprofileid
     WHERE (ltr.long_text_id=temp_style_profile->long_text_id)
      AND ltr.parent_entity_name="CR_REPORT_STYLE_PROFILE"
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyLongTextReference",
     "Old Row could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertLongtext subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (getidofexistinginacativestyleprofile(styleprofilename=vc) =f8)
   CALL log_message("Entered GetIdOfExistingInacativeStyleProfile subroutine.",log_level_debug)
   DECLARE styleprofileid = f8 WITH noconstant(0.0)
   DECLARE activeind = i2 WITH noconstant(0)
   DECLARE updatecount = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM cr_report_style_profile crsp
    WHERE crsp.style_profile_name_key=trim(cnvtupper(cnvtalphanum(styleprofilename)),3)
     AND crsp.style_profile_id=crsp.report_style_profile_id
    DETAIL
     IF (styleprofilename=crsp.style_profile_name)
      styleprofileid = crsp.style_profile_id, activeind = crsp.active_ind, updatecount = crsp
      .updt_cnt,
      BREAK
     ENDIF
    WITH nocounter
   ;end select
   IF (activeind=0)
    CALL log_message(concat("Reactivating style profile ",cnvtstring(styleprofileid),
      " and adding new version"),log_level_debug)
    SET request->cr_report_style_profile[lstyleprofilecnt].updt_cnt = updatecount
    RETURN(styleprofileid)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = "GetIdOfExistingInacativeStyleProfile"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = curprog
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "This style profile cannot be inserted because an active style profile already exists with the name ",
     trim(styleprofilename),". (id = ",trim(cnvtstring(styleprofileid)),")")
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting GetIdOfExistingInacativeStyleProfile subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echo(build("Commit_ind 1 - ",reqinfo->commit_ind))
#exit_script
 FREE RECORD temp_style_profile
 CALL log_message("End of script: cr_upd_report_style_profiles",log_level_debug)
 CALL echorecord(reply)
END GO
