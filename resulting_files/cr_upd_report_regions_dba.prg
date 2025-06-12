CREATE PROGRAM cr_upd_report_regions:dba
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
 SET log_program_name = "CR_UPD_REPORT_REGIONS"
 CALL log_message("Starting script: cr_upd_report_regions",log_level_debug)
 IF (validate(reply,0))
  CALL log_message("Called from parent script",log_level_debug)
 ELSE
  CALL log_message("Called from Front-End App",log_level_debug)
  FREE RECORD reply
  RECORD reply(
    1 static_region_catalog
      2 item[*]
        3 static_region_id = f8
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
 FREE RECORD temp_region
 RECORD temp_region(
   1 report_static_region_id = f8
   1 static_region_id = f8
   1 region_name = vc
   1 region_name_key = vc
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
 DECLARE dexistingregionid = f8 WITH protect, noconstant(0.0)
 DECLARE dreportregionid = f8 WITH protect, noconstant(0.0)
 DECLARE dlongtextid = f8 WITH protect, noconstant(0.0)
 DECLARE dorgreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE dlocationreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE dserviceresourcereltnid = f8 WITH protect, noconstant(0.0)
 DECLARE lnumofregions = i4 WITH noconstant(0)
 DECLARE lregcnt = i4 WITH noconstant(0)
 IF (validate(currentdatetime,1)=1)
  DECLARE currentdatetime = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 ENDIF
 DECLARE errmsg = c132 WITH protect
 DECLARE sregionnamekey = vc WITH protect
 DECLARE dsystemdate = f8 WITH protect
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE nnew_reg = i2 WITH protect, constant(3)
 DECLARE nnew_reg_long_text = i2 WITH protect, constant(4)
 DECLARE nnew_org = i2 WITH protect, constant(1)
 DECLARE nnew_loc = i2 WITH protect, constant(2)
 DECLARE nnew_sr = i2 WITH protect, constant(5)
 DECLARE insertnewregion(null) = null
 DECLARE modifyregion(null) = null
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET errmsg = fillstring(132," ")
 SET lnumofregions = size(request->cr_report_static_region,5)
 SET stat = alterlist(reply->static_region_catalog.item,lnumofregions)
 FOR (lregcnt = 1 TO lnumofregions)
   IF ((request->cr_report_static_region[lregcnt].static_region_id=0))
    SET dexistingregionid = getidofexistinginacativeregion(request->cr_report_static_region[lregcnt].
     region_name)
    IF (dexistingregionid=0)
     CALL insertnewregion(null)
    ELSE
     SET request->cr_report_static_region[lregcnt].static_region_id = dexistingregionid
     CALL modifyregion(null)
    ENDIF
   ELSEIF ((request->cr_report_static_region[lregcnt].region_dirty_ind=1))
    CALL modifyregion(null)
   ELSE
    SET reply->static_region_catalog.item[lregcnt].static_region_id = request->
    cr_report_static_region[lregcnt].static_region_id
    SET reply->static_region_catalog.item[lregcnt].updt_cnt = request->cr_report_static_region[
    lregcnt].updt_cnt
   ENDIF
 ENDFOR
 SUBROUTINE insertnewregion(null)
   CALL log_message("Entered InsertNewRegion subroutine.",log_level_debug)
   IF ((request->cr_report_static_region[lregcnt].xml_detail_dirty_ind=1))
    CALL createsequences(nnew_reg_long_text)
    CALL insertlongtext(0)
   ELSE
    CALL createsequences(nnew_reg)
   ENDIF
   SET sregionnamekey = trim(cnvtupper(cnvtalphanum(request->cr_report_static_region[lregcnt].
      region_name)),3)
   SET dsystemdate = sysdate
   INSERT  FROM cr_report_static_region crs
    SET crs.report_static_region_id = dreportregionid, crs.static_region_id = dreportregionid, crs
     .long_text_id = dlongtextid,
     crs.region_name = request->cr_report_static_region[lregcnt].region_name, crs.region_name_key =
     sregionnamekey, crs.name_ident = concat(sregionnamekey,cnvtstring(dsystemdate)),
     crs.active_ind = request->cr_report_static_region[lregcnt].active_ind, crs.beg_effective_dt_tm
      = cnvtdatetime(currentdatetime), crs.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     crs.updt_cnt = 0, crs.updt_dt_tm = cnvtdatetime(currentdatetime), crs.updt_id = reqinfo->updt_id,
     crs.updt_task = reqinfo->updt_task, crs.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"InsertNewRegion",
    "CR_Report_Static_Region table could not be updated.  Exiting script.",1,1)
   SET reply->static_region_catalog.item[lregcnt].static_region_id = dreportregionid
   SET reply->static_region_catalog.item[lregcnt].updt_cnt = 0
   SET reply->static_region_catalog.item[lregcnt].version_dt_tm = cnvtdatetime(currentdatetime)
   IF (validate(request->cr_report_static_region[lregcnt].orgs_dirty_ind,0)=1)
    CALL insertorganizations(dreportregionid)
   ENDIF
   IF (validate(request->cr_report_static_region[lregcnt].locations_dirty_ind,0)=1)
    CALL insertlocations(dreportregionid)
   ENDIF
   IF (validate(request->cr_report_static_region[lregcnt].serv_rescs_dirty_ind,0)=1)
    CALL insertserviceresources(dreportregionid)
   ENDIF
   CALL log_message("Exiting InsertNewRegion subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE modifyregion(null)
   CALL log_message("Entered ModifyRegion subroutine.",log_level_debug)
   SELECT INTO "nl:"
    FROM cr_report_static_region crs
    WHERE (crs.static_region_id=request->cr_report_static_region[lregcnt].static_region_id)
     AND (crs.report_static_region_id=request->cr_report_static_region[lregcnt].static_region_id)
    DETAIL
     temp_region->report_static_region_id = crs.report_static_region_id, temp_region->
     static_region_id = crs.static_region_id, temp_region->region_name = crs.region_name,
     temp_region->region_name_key = crs.region_name_key, temp_region->name_ident = crs.name_ident,
     temp_region->beg_effective_dt_tm = cnvtdatetime(crs.beg_effective_dt_tm),
     temp_region->end_effective_dt_tm = cnvtdatetime(currentdatetime), temp_region->long_text_id =
     crs.long_text_id, temp_region->active_ind = crs.active_ind,
     temp_region->updt_id = crs.updt_id, temp_region->updt_task = crs.updt_task, temp_region->
     updt_dt_tm = cnvtdatetime(crs.updt_dt_tm),
     temp_region->updt_applctx = crs.updt_applctx, temp_region->updt_cnt = crs.updt_cnt
    WITH nocounter, forupdate(crs)
   ;end select
   CALL error_and_zero_check(curqual,"ModifyRegion",
    "Could not perform Select against CR_REPORT_STATIC_REGION.  Exiting script.",1,1)
   IF ((request->cr_report_static_region[lregcnt].updt_cnt=temp_region->updt_cnt))
    SET sregionnamekey = trim(cnvtupper(cnvtalphanum(request->cr_report_static_region[lregcnt].
       region_name)),3)
    SET dsystemdate = sysdate
    IF ((request->cr_report_static_region[lregcnt].xml_detail_dirty_ind=1))
     CALL createsequences(nnew_reg_long_text)
     CALL insertlongtext(1)
    ELSE
     CALL createsequences(nnew_reg)
     SET dlongtextid = temp_region->long_text_id
    ENDIF
    UPDATE  FROM cr_report_static_region crs
     SET crs.region_name = request->cr_report_static_region[lregcnt].region_name, crs.region_name_key
       = sregionnamekey, crs.name_ident = concat(sregionnamekey,cnvtstring(dsystemdate)),
      crs.beg_effective_dt_tm = cnvtdatetime(currentdatetime), crs.long_text_id = dlongtextid, crs
      .active_ind = request->cr_report_static_region[lregcnt].active_ind,
      crs.updt_cnt = (request->cr_report_static_region[lregcnt].updt_cnt+ 1), crs.updt_dt_tm =
      cnvtdatetime(currentdatetime), crs.updt_id = reqinfo->updt_id,
      crs.updt_task = reqinfo->updt_task, crs.updt_applctx = reqinfo->updt_applctx
     WHERE (crs.report_static_region_id=request->cr_report_static_region[lregcnt].static_region_id)
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyRegion","Old Row could not be updated.  Exiting script.",
     1,1)
    INSERT  FROM cr_report_static_region crs
     SET crs.report_static_region_id = dreportregionid, crs.static_region_id = temp_region->
      static_region_id, crs.region_name = temp_region->region_name,
      crs.region_name_key = temp_region->region_name_key, crs.name_ident = temp_region->name_ident,
      crs.long_text_id = temp_region->long_text_id,
      crs.active_ind = temp_region->active_ind, crs.beg_effective_dt_tm = cnvtdatetime(temp_region->
       beg_effective_dt_tm), crs.end_effective_dt_tm = cnvtdatetime(currentdatetime),
      crs.updt_cnt = temp_region->updt_cnt, crs.updt_dt_tm = cnvtdatetime(temp_region->updt_dt_tm),
      crs.updt_id = temp_region->updt_id,
      crs.updt_task = temp_region->updt_task, crs.updt_applctx = temp_region->updt_applctx
     WITH nocounter
    ;end insert
    CALL error_and_zero_check(curqual,"ModifyRegion","New Row could not be created.  Exiting script.",
     1,1)
    SET reply->static_region_catalog.item[lregcnt].static_region_id = request->
    cr_report_static_region[lregcnt].static_region_id
    SET reply->static_region_catalog.item[lregcnt].updt_cnt = (request->cr_report_static_region[
    lregcnt].updt_cnt+ 1)
    SET reply->static_region_catalog.item[lregcnt].version_dt_tm = cnvtdatetime(currentdatetime)
    IF (validate(request->cr_report_static_region[lregcnt].orgs_dirty_ind,0)=1)
     CALL insertorganizations(temp_region->static_region_id)
    ENDIF
    IF (validate(request->cr_report_static_region[lregcnt].locations_dirty_ind,0)=1)
     CALL insertlocations(temp_region->static_region_id)
    ENDIF
    IF (validate(request->cr_report_static_region[lregcnt].serv_rescs_dirty_ind,0)=1)
     CALL insertserviceresources(temp_region->static_region_id)
    ENDIF
   ELSE
    SET reply->status_data.status = "U"
    SET reply->update_data.target_object_id = build("CR_REPORT_STATIC_REGION#",temp_region->
     static_region_id)
    SET reply->update_data.submitted_updt_cnt = request->cr_report_static_region[lregcnt].updt_cnt
    SET reply->update_data.latest_updt_cnt = temp_region->updt_cnt
    SET reply->update_data.updt_dt_tm = temp_region->updt_dt_tm
    SET reply->update_data.updt_id = temp_region->updt_id
    SET reply->update_data.updt_applctx = temp_region->updt_applctx
    SET reply->update_data.updt_task = temp_region->updt_task
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting ModifyRegion subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (createsequences(seqind=i2) =null)
   CALL log_message("Entered CreateSequences subroutine.",log_level_debug)
   IF (seqind >= nnew_reg)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dreportregionid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Region seq could not be created.  Exiting script.",1,1)
    SET dlongtextid = 0
    SET dorgreltnid = 0
    SET dlocationreltnid = 0
    SET dserviceresourcereltnid = 0
   ENDIF
   IF (seqind=nnew_org)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dorgreltnid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Org Reltn seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dOrgReltnId:  ",dorgreltnid))
   ELSEIF (seqind=nnew_loc)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dlocationreltnid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Loc Reltn seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dLocationReltnId:  ",dlocationreltnid))
   ELSEIF (seqind=nnew_sr)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dserviceresourcereltnid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Service Resource seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dServiceResourceReltnId:  ",dserviceresourcereltnid))
   ELSEIF (seqind=nnew_reg_long_text)
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
     FROM dual
     DETAIL
      dlongtextid = nextseqnum
     WITH format, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CreateSequences",
     "Long_Text seq could not be created.  Exiting script.",1,1)
    CALL echo(build("dLongTextId:  ",dlongtextid))
   ENDIF
   CALL log_message("Exiting CreateSequences subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertlongtext(updtind=i2) =null)
   CALL log_message("Entered InsertLongtext subroutine.",log_level_debug)
   DECLARE regionparententityid = f8 WITH noconstant(0.0)
   IF (updtind=0)
    SET regionparententityid = dreportregionid
   ELSE
    SET regionparententityid = temp_region->report_static_region_id
   ENDIF
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = dlongtextid, ltr.long_text = request->cr_report_static_region[lregcnt].
     xml_detail, ltr.parent_entity_id = regionparententityid,
     ltr.parent_entity_name = "CR_REPORT_STATIC_REGION", ltr.active_ind = 1, ltr.active_status_cd =
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
     SET ltr.parent_entity_id = dreportregionid
     WHERE (ltr.long_text_id=temp_region->long_text_id)
      AND ltr.parent_entity_name="CR_REPORT_STATIC_REGION"
     WITH nocounter
    ;end update
    CALL error_and_zero_check(curqual,"ModifyLongTextReference",
     "Old Row could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertLongtext subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertorganizations(staticregionid=f8) =null)
   CALL log_message("Entered InsertOrganizations subroutine.",log_level_debug)
   UPDATE  FROM cr_static_region_org_reltn csror
    SET csror.end_effective_dt_tm = cnvtdatetime(currentdatetime), csror.active_ind = 0, csror
     .updt_cnt = (csror.updt_cnt+ 1),
     csror.updt_dt_tm = cnvtdatetime(currentdatetime), csror.updt_id = reqinfo->updt_id, csror
     .updt_task = reqinfo->updt_task,
     csror.updt_applctx = reqinfo->updt_applctx
    WHERE csror.static_region_id=staticregionid
     AND csror.active_ind=1
   ;end update
   DECLARE relatedorgcount = i4 WITH noconstant(0)
   SET relatedorgcount = size(request->cr_report_static_region[lregcnt].related_orgs,5)
   CALL log_message(concat("Related org count: ",cnvtstring(relatedorgcount)),log_level_debug)
   IF (relatedorgcount > 0)
    FOR (lorgcnt = 1 TO relatedorgcount)
     CALL createsequences(nnew_org)
     INSERT  FROM cr_static_region_org_reltn csror
      SET csror.cr_static_region_org_reltn_id = dorgreltnid, csror.static_region_id = staticregionid,
       csror.organization_id = request->cr_report_static_region[lregcnt].related_orgs[lorgcnt].
       organization_id,
       csror.beg_effective_dt_tm = cnvtdatetime(currentdatetime), csror.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"), csror.active_ind = 1,
       csror.updt_cnt = 0, csror.updt_dt_tm = cnvtdatetime(currentdatetime), csror.updt_id = reqinfo
       ->updt_id,
       csror.updt_task = reqinfo->updt_task, csror.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDFOR
    CALL error_and_zero_check(curqual,"InsertOrganizations",
     "CR_STATIC_REGION_ORG_RELTN table could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertOrganizations subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertlocations(staticregionid=f8) =null)
   CALL log_message("Entered InsertLocations subroutine.",log_level_debug)
   UPDATE  FROM cr_static_region_loc_reltn csrlr
    SET csrlr.end_effective_dt_tm = cnvtdatetime(currentdatetime), csrlr.active_ind = 0, csrlr
     .updt_cnt = (csrlr.updt_cnt+ 1),
     csrlr.updt_dt_tm = cnvtdatetime(currentdatetime), csrlr.updt_id = reqinfo->updt_id, csrlr
     .updt_task = reqinfo->updt_task,
     csrlr.updt_applctx = reqinfo->updt_applctx
    WHERE csrlr.static_region_id=staticregionid
     AND csrlr.active_ind=1
   ;end update
   DECLARE relatedlocationcount = i4 WITH noconstant(0)
   SET relatedlocationcount = size(request->cr_report_static_region[lregcnt].related_locations,5)
   IF (relatedlocationcount > 0)
    FOR (llocationcnt = 1 TO relatedlocationcount)
     CALL createsequences(nnew_loc)
     INSERT  FROM cr_static_region_loc_reltn csrlr
      SET csrlr.cr_static_region_loc_reltn_id = dlocationreltnid, csrlr.static_region_id =
       staticregionid, csrlr.location_cd = request->cr_report_static_region[lregcnt].
       related_locations[llocationcnt].location_cd,
       csrlr.beg_effective_dt_tm = cnvtdatetime(currentdatetime), csrlr.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"), active_ind = 1,
       csrlr.updt_cnt = 0, csrlr.updt_dt_tm = cnvtdatetime(currentdatetime), csrlr.updt_id = reqinfo
       ->updt_id,
       csrlr.updt_task = reqinfo->updt_task, csrlr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDFOR
    CALL error_and_zero_check(curqual,"InsertLocations",
     "CR_STATIC_REGION_LOC_RELTN table could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertOrganizations subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (insertserviceresources(staticregionid=f8) =null)
   CALL log_message("Entered InsertServiceResources subroutine.",log_level_debug)
   UPDATE  FROM cr_static_region_sr_reltn csrsr
    SET csrsr.end_effective_dt_tm = cnvtdatetime(currentdatetime), csrsr.active_ind = 0, csrsr
     .updt_cnt = (csrsr.updt_cnt+ 1),
     csrsr.updt_dt_tm = cnvtdatetime(currentdatetime), csrsr.updt_id = reqinfo->updt_id, csrsr
     .updt_task = reqinfo->updt_task,
     csrsr.updt_applctx = reqinfo->updt_applctx
    WHERE csrsr.static_region_id=staticregionid
     AND csrsr.active_ind=1
   ;end update
   DECLARE relatedserviceresourcecount = i4 WITH noconstant(0)
   SET relatedserviceresourcecount = size(request->cr_report_static_region[lregcnt].
    related_serv_rescs,5)
   IF (relatedserviceresourcecount > 0)
    FOR (lserviceresourcecnt = 1 TO relatedserviceresourcecount)
     CALL createsequences(nnew_sr)
     INSERT  FROM cr_static_region_sr_reltn csrsr
      SET csrsr.cr_static_region_sr_reltn_id = dserviceresourcereltnid, csrsr.static_region_id =
       staticregionid, csrsr.service_resource_cd = request->cr_report_static_region[lregcnt].
       related_serv_rescs[lserviceresourcecnt].service_resource_cd,
       csrsr.beg_effective_dt_tm = cnvtdatetime(currentdatetime), csrsr.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"), active_ind = 1,
       csrsr.updt_cnt = 0, csrsr.updt_dt_tm = cnvtdatetime(currentdatetime), csrsr.updt_id = reqinfo
       ->updt_id,
       csrsr.updt_task = reqinfo->updt_task, csrsr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDFOR
    CALL error_and_zero_check(curqual,"InsertServiceResources",
     "CR_STATIC_REGION_SR_RELTN table could not be updated.  Exiting script.",1,1)
   ENDIF
   CALL log_message("Exiting InsertServiceResources subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE (getidofexistinginacativeregion(regionname=vc) =f8)
   CALL log_message("Entered GetIdOfExistingInacativeRegion subroutine.",log_level_debug)
   DECLARE regionid = f8 WITH noconstant(0.0)
   DECLARE activeind = i2 WITH noconstant(0)
   DECLARE updatecount = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM cr_report_static_region crsr
    WHERE crsr.region_name_key=trim(cnvtupper(cnvtalphanum(regionname)),3)
     AND crsr.static_region_id=crsr.report_static_region_id
    DETAIL
     IF (regionname=crsr.region_name)
      regionid = crsr.static_region_id, activeind = crsr.active_ind, updatecount = crsr.updt_cnt,
      BREAK
     ENDIF
    WITH nocounter
   ;end select
   IF (activeind=0)
    CALL log_message(concat("Reactivating page master ",trim(cnvtstring(regionid)),
      " and adding new version"),log_level_debug)
    SET request->cr_report_static_region[lregcnt].updt_cnt = updatecount
    RETURN(regionid)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = "GetIdOfExistingInacativeRegion"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = curprog
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "This page master cannot be inserted because an active page master already exists with the name ",
     trim(regionname),". (id = ",trim(cnvtstring(regionid)),")")
    GO TO exit_script
   ENDIF
   CALL log_message("Exiting GetIdOfExistingInacativeRegion subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
#exit_script
 FREE RECORD temp_region
 CALL log_message("End of script: cr_upd_report_regions",log_level_debug)
 CALL echorecord(reply)
END GO
