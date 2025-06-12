CREATE PROGRAM cr_get_user_viewable_templates:dba
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
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 SET log_program_name = "cr_get_user_viewable_templates"
 CALL log_message("Starting script: cr_get_user_viewable_templates",log_level_debug)
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 templates[*]
      2 id = f8
      2 name = vc
      2 version_mode = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DELETE  FROM shared_list_gttd
  WHERE source_entity_id > 0
 ;end delete
 SET reply->status_data.status = "F"
 IF ((request->user_id <= 0))
  SET reply->status_data.subeventstatus[1].operationname = "cr_get_user_viewable_templates"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "The user id must be filled out with a value greater than 0"
  GO TO exit_script
 ENDIF
 FREE RECORD accessible_orgs
 RECORD accessible_orgs(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 FREE RECORD valid_templates
 RECORD valid_templates(
   1 templates[*]
     2 id = f8
     2 name = vc
     2 publish_dt_tm = dq8
 )
 FREE RECORD filtered_templates
 RECORD filtered_templates(
   1 templates[*]
     2 id = f8
     2 name = vc
     2 publish_dt_tm = dq8
 )
 DECLARE getaccessibleorgsforuser(null) = null
 DECLARE filterpublishedtemplatesbyorg(null) = null
 DECLARE filterworkingtemplatesbyorg(null) = null
 DECLARE filterpublishedtemplatesbyposition(null) = null
 DECLARE filterworkingtemplatesbyposition(null) = null
 DECLARE templatecount = i4 WITH noconstant(0)
 DECLARE lidx = i4 WITH noconstant(0)
 DECLARE filterbyorgind = i2 WITH noconstant(0)
 DECLARE lnumberoforgs = i4 WITH noconstant(- (1))
 DECLARE working_version_mode = i2 WITH constant(1)
 DECLARE published_version_mode = i2 WITH constant(2)
 DECLARE templates_valid_static_regions = i4 WITH constant(1)
 DECLARE userpositioncd = f8 WITH protect, noconstant(0.0)
 DECLARE filterbypositionind = i2 WITH noconstant(1)
 IF (validate(request->not_filter_by_position,0)=1)
  SET filterbypositionind = 0
 ENDIF
 SET filterbyorgind = validate(request->filter_by_org,0)
 CALL echo(build("filter templates by user position: ",filterbypositionind))
 IF (filterbypositionind=1)
  SET stat = getcurrentposition(null)
  SET userpositioncd = sac_cur_pos_rep->position_cd
  CALL log_message(build2("Current user: ",reqinfo->updt_id," request user id: ",request->user_id,
    " position cd: ",
    userpositioncd),log_level_debug)
 ENDIF
 CALL echo(build("user position cd:",userpositioncd))
 CALL getaccessibleorgsforuser(null)
 CALL error_and_zero_check(curqual,"Retrieve",
  "CR_Publish_Template table could not be read.  Exiting script.",1,0)
 INSERT  FROM shared_list_gttd
  (source_entity_id, source_entity_txt, source_entity_dt_tm)(SELECT
   crt.template_id, crt.template_name, ctp.publish_dt_tm
   FROM cr_report_template crt,
    cr_template_publish ctp
   WHERE ctp.active_ind=1
    AND crt.template_id=ctp.template_id
    AND crt.beg_effective_dt_tm <= ctp.publish_dt_tm
    AND crt.end_effective_dt_tm > ctp.publish_dt_tm
    AND crt.active_ind=1)
 ;end insert
 UPDATE  FROM shared_list_gttd s
  SET s.source_entity_nbr = templates_valid_static_regions
  WHERE  EXISTS (
  (SELECT
   crsr.static_region_id
   FROM cr_template_snapshot cts,
    cr_report_static_region crsr
   WHERE cts.template_id=s.source_entity_id
    AND cts.static_region_id > 0
    AND cts.beg_effective_dt_tm <= s.source_entity_dt_tm
    AND cts.end_effective_dt_tm > s.source_entity_dt_tm
    AND crsr.static_region_id=cts.static_region_id
    AND crsr.beg_effective_dt_tm <= s.source_entity_dt_tm
    AND crsr.end_effective_dt_tm > s.source_entity_dt_tm
    AND crsr.active_ind=1))
 ;end update
 SELECT INTO "nl:"
  FROM shared_list_gttd s
  WHERE s.source_entity_nbr=templates_valid_static_regions
   AND  EXISTS (
  (SELECT
   crs.section_id
   FROM cr_template_snapshot cts,
    cr_report_section crs
   WHERE cts.template_id=s.source_entity_id
    AND cts.section_id > 0
    AND cts.beg_effective_dt_tm <= s.source_entity_dt_tm
    AND cts.end_effective_dt_tm > s.source_entity_dt_tm
    AND crs.section_id=cts.section_id
    AND crs.beg_effective_dt_tm <= s.source_entity_dt_tm
    AND crs.end_effective_dt_tm > s.source_entity_dt_tm
    AND crs.active_ind=1))
  DETAIL
   templatecount += 1
   IF (mod(templatecount,10)=1)
    stat = alterlist(valid_templates->templates,(templatecount+ 9))
   ENDIF
   valid_templates->templates[templatecount].id = s.source_entity_id, valid_templates->templates[
   templatecount].publish_dt_tm = s.source_entity_dt_tm, valid_templates->templates[templatecount].
   name = s.source_entity_txt
  WITH nocounter
 ;end select
 SET stat = alterlist(valid_templates->templates,templatecount)
 CALL echo(build("valid publish templates before user position check: ",size(valid_templates->
    templates,5)))
 DECLARE xcount = i4 WITH noconstant(0)
 DECLARE validtemplatecount = i4 WITH noconstant(0)
 IF (filterbypositionind=1)
  CALL filterpublishedtemplatesbyposition(null)
 ELSE
  SET xcount = 1
  SET stat = alterlist(filtered_templates->templates,size(valid_templates->templates,5))
  WHILE (xcount <= size(valid_templates->templates,5))
    SET filtered_templates->templates[xcount].id = valid_templates->templates[xcount].id
    SET filtered_templates->templates[xcount].name = valid_templates->templates[xcount].name
    SET filtered_templates->templates[xcount].publish_dt_tm = valid_templates->templates[xcount].
    publish_dt_tm
    SET xcount += 1
  ENDWHILE
 ENDIF
 CALL echo(build("valid publish templates before org check: ",size(filtered_templates->templates,5)))
 IF ((lnumberoforgs=- (1)))
  SET xcount = 1
  SET stat = alterlist(reply->templates,size(filtered_templates->templates,5))
  WHILE (xcount <= size(filtered_templates->templates,5))
    SET reply->templates[xcount].id = filtered_templates->templates[xcount].id
    SET reply->templates[xcount].name = filtered_templates->templates[xcount].name
    SET reply->templates[xcount].version_mode = published_version_mode
    SET xcount += 1
  ENDWHILE
 ELSE
  CALL filterpublishedtemplatesbyorg(null)
 ENDIF
 IF ((request->load_working_versions=1))
  DELETE  FROM shared_list_gttd
   WHERE source_entity_id > 0
  ;end delete
  SET templatecount = 0
  SET stat = initrec(valid_templates)
  SET stat = initrec(filtered_templates)
  INSERT  FROM shared_list_gttd
   (source_entity_id, source_entity_txt)(SELECT
    crt.template_id, crt.template_name
    FROM cr_report_template crt
    WHERE crt.report_template_id=crt.template_id
     AND crt.active_ind=1)
  ;end insert
  UPDATE  FROM shared_list_gttd s
   SET s.source_entity_nbr = templates_valid_static_regions
   WHERE  EXISTS (
   (SELECT
    crsr.static_region_id
    FROM cr_template_snapshot cts,
     cr_report_static_region crsr
    WHERE cts.template_id=s.source_entity_id
     AND cts.static_region_id > 0
     AND cts.active_ind=1
     AND crsr.report_static_region_id=cts.static_region_id
     AND crsr.active_ind=1))
  ;end update
  SELECT INTO "nl:"
   s.source_entity_id
   FROM shared_list_gttd s
   WHERE s.source_entity_nbr=templates_valid_static_regions
    AND  EXISTS (
   (SELECT
    crs.section_id
    FROM cr_template_snapshot cts,
     cr_report_section crs
    WHERE cts.template_id=s.source_entity_id
     AND cts.section_id > 0
     AND cts.active_ind=1
     AND crs.report_section_id=cts.section_id
     AND crs.active_ind=1))
   DETAIL
    templatecount += 1
    IF (mod(templatecount,10)=1)
     stat = alterlist(valid_templates->templates,(templatecount+ 9))
    ENDIF
    valid_templates->templates[templatecount].id = s.source_entity_id, valid_templates->templates[
    templatecount].name = s.source_entity_txt
   WITH nocounter
  ;end select
  SET stat = alterlist(valid_templates->templates,templatecount)
  CALL echo(build("valid working templates before user position check: ",templatecount))
  IF (filterbypositionind=1)
   CALL filterworkingtemplatesbyposition(null)
  ELSE
   SET xcount = 1
   SET stat = alterlist(filtered_templates->templates,size(valid_templates->templates,5))
   WHILE (xcount <= size(valid_templates->templates,5))
     SET filtered_templates->templates[xcount].id = valid_templates->templates[xcount].id
     SET filtered_templates->templates[xcount].name = valid_templates->templates[xcount].name
     SET xcount += 1
   ENDWHILE
  ENDIF
  IF ((lnumberoforgs=- (1)))
   SET xcount = size(reply->templates,5)
   SET validtemplatecount = 1
   WHILE (validtemplatecount <= size(filtered_templates->templates,5))
     SET xcount += 1
     SET stat = alterlist(reply->templates,xcount)
     SET reply->templates[xcount].id = filtered_templates->templates[validtemplatecount].id
     SET reply->templates[xcount].name = filtered_templates->templates[validtemplatecount].name
     SET reply->templates[xcount].version_mode = working_version_mode
     SET validtemplatecount += 1
   ENDWHILE
  ELSE
   CALL filterworkingtemplatesbyorg(null)
  ENDIF
  CALL error_and_zero_check(curqual,"Retrieve",
   "CR_Report_Template table could not be read.  Exiting script.",1,0)
 ENDIF
 IF (size(reply->templates,5)=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SUBROUTINE getaccessibleorgsforuser(null)
   IF (filterbyorgind=1)
    CALL echo("Entering GetAccessibleOrgsForUser.")
    DECLARE org_security_ind = i2 WITH noconstant(0)
    IF (validate(request->bypass_org_security_check,0)=1)
     CALL echo("Bypass org security checking.")
     SET org_security_ind = validate(request->overridden_org_security_ind,0)
    ELSE
     FREE RECORD security_request
     RECORD security_request(
       1 action_flag = i2
       1 check_org_level_sec = i2
       1 check_confid_level_sec = i2
       1 org_id = f8
       1 user_id = f8
     )
     FREE RECORD security_reply
     RECORD security_reply(
       1 org_level_sec_enabled = i2
       1 confid_level_sec_enabled = i2
       1 confid_level_cd = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET security_request->action_flag = 1
     SET security_request->check_org_level_sec = 1
     EXECUTE pm_chk_security  WITH replace("REQUEST",security_request), replace("REPLY",
      security_reply)
     IF ((security_reply->status_data.status="F"))
      SET reply->status_data.status = security_reply->status_data.status
      SET reply->status_data.subeventstatus[1].operationname = security_reply->status_data.
      subeventstatus[1].operationname
      SET reply->status_data.subeventstatus[1].operationstatus = security_reply->status_data.
      subeventstatus[1].operationstatus
      SET reply->status_data.subeventstatus[1].targetobjectname = security_reply->status_data.
      subeventstatus[1].targetobjectname
      SET reply->status_data.subeventstatus[1].targetobjectvalue = security_reply->status_data.
      subeventstatus[1].targetobjectvalue
      GO TO exit_script
     ENDIF
     SET org_security_ind = security_reply->org_level_sec_enabled
    ENDIF
    IF (org_security_ind=1)
     CALL log_message("Org security is enabled.",log_level_debug)
     SET old_updt_id = reqinfo->updt_id
     SET reqinfo->updt_id = request->user_id
     EXECUTE sac_get_user_organizations  WITH replace("REPLY",accessible_orgs)
     SET reqinfo->updt_id = old_updt_id
     SET lnumberoforgs = size(accessible_orgs->organizations,5)
     CALL log_message(concat("number of orgs related to the user: ",cnvtstring(lnumberoforgs)),
      log_level_debug)
    ENDIF
    CALL echo("Exiting GetAccessibleOrgsForUser.")
   ENDIF
 END ;Subroutine
 SUBROUTINE filterpublishedtemplatesbyposition(null)
   CALL log_message("Entered FilterPublishedTemplatesByPosition subroutine.",log_level_debug)
   SET validtemplatesnopos = 0
   SET xcount = 0
   SELECT INTO "nl:"
    crt.template_id, crt.template_name
    FROM cr_report_template crt,
     (dummyt d  WITH seq = value(size(valid_templates->templates,5)))
    PLAN (d)
     JOIN (crt
     WHERE (crt.template_id=valid_templates->templates[d.seq].id)
      AND crt.beg_effective_dt_tm <= cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
      AND crt.end_effective_dt_tm > cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
      AND crt.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      cpos.template_id
      FROM cr_template_position_reltn cpos
      WHERE cpos.template_id=crt.template_id
       AND cpos.beg_effective_dt_tm <= cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
       AND cpos.end_effective_dt_tm > cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)))
     ))
    DETAIL
     validtemplatesnopos += 1, xcount += 1, stat = alterlist(filtered_templates->templates,xcount),
     filtered_templates->templates[xcount].id = crt.template_id, filtered_templates->templates[xcount
     ].name = crt.template_name, filtered_templates->templates[xcount].publish_dt_tm =
     valid_templates->templates[d.seq].publish_dt_tm
    WITH nocounter
   ;end select
   CALL echo(build("valid published templates without associated positions: ",validtemplatesnopos))
   DECLARE tempnoposcount = i4 WITH private, noconstant(1)
   DECLARE nopostemplateid = f8 WITH private, noconstant(0.0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE pos = i4 WITH private, noconstant(0)
   WHILE (tempnoposcount <= validtemplatesnopos)
     SET nopostemplateid = filtered_templates->templates[tempnoposcount].id
     SET pos = locateval(idx,1,size(valid_templates->templates,5),nopostemplateid,valid_templates->
      templates[idx].id)
     IF (pos > 0)
      SET stat = alterlist(valid_templates->templates,(size(valid_templates->templates,5) - 1),(pos
        - 1))
     ENDIF
     SET tempnoposcount += 1
   ENDWHILE
   CALL echo(build("templates with associated positions: ",size(valid_templates->templates,5)))
   IF (userpositioncd > 0
    AND size(valid_templates->templates,5) > 0)
    DECLARE validtemplateswithpos = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     FROM cr_report_template crt,
      cr_template_position_reltn cpos,
      (dummyt d  WITH seq = value(size(valid_templates->templates,5)))
     PLAN (d)
      JOIN (crt
      WHERE (crt.template_id=valid_templates->templates[d.seq].id)
       AND crt.beg_effective_dt_tm <= cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
       AND crt.end_effective_dt_tm > cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
       AND crt.active_ind=1)
      JOIN (cpos
      WHERE cpos.template_id=crt.template_id
       AND cpos.position_cd=userpositioncd
       AND cpos.beg_effective_dt_tm <= cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm)
       AND cpos.end_effective_dt_tm > cnvtdatetime(valid_templates->templates[d.seq].publish_dt_tm))
     DETAIL
      validtemplateswithpos += 1, xcount += 1, stat = alterlist(filtered_templates->templates,xcount),
      filtered_templates->templates[xcount].id = crt.template_id, filtered_templates->templates[
      xcount].name = crt.template_name, filtered_templates->templates[xcount].publish_dt_tm =
      valid_templates->templates[d.seq].publish_dt_tm
     WITH counter
    ;end select
    CALL echo(build("qualified published templates with user positions: ",validtemplateswithpos))
   ENDIF
   CALL log_message("Exiting FilterPublishedTemplatesByPosition subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE filterpublishedtemplatesbyorg(null)
   CALL log_message("Entered FilterPublishedTemplatesByOrg subroutine.",log_level_debug)
   DECLARE validtemplatsnoorgs = i4 WITH noconstant(0)
   SET xcount = size(reply->templates,5)
   SELECT INTO "nl:"
    crt.template_id, crt.template_name
    FROM cr_report_template crt,
     (dummyt d  WITH seq = value(size(filtered_templates->templates,5)))
    PLAN (d)
     JOIN (crt
     WHERE (crt.template_id=filtered_templates->templates[d.seq].id)
      AND crt.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm)
      AND crt.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm)
      AND crt.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      csror.static_region_id
      FROM cr_static_region_org_reltn csror,
       cr_report_static_region crsr,
       cr_template_snapshot cts
      WHERE cts.template_id=crt.template_id
       AND cts.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm
       )
       AND cts.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm)
       AND crsr.static_region_id=cts.static_region_id
       AND crsr.active_ind=1
       AND crsr.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].
       publish_dt_tm)
       AND crsr.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm
       )
       AND csror.static_region_id=crsr.static_region_id
       AND csror.beg_effective_dt_tm <= crsr.beg_effective_dt_tm
       AND csror.end_effective_dt_tm >= crsr.end_effective_dt_tm))))
    DETAIL
     validtemplatsnoorgs += 1, xcount += 1, stat = alterlist(reply->templates,xcount),
     reply->templates[xcount].id = crt.template_id, reply->templates[xcount].name = crt.template_name,
     reply->templates[xcount].version_mode = published_version_mode
    WITH nocounter
   ;end select
   DECLARE replycount = i4 WITH protect, noconstant(1)
   DECLARE replytemplateid = f8 WITH protect, noconstant(0.0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   WHILE (replycount <= size(reply->templates,5))
     SET replytemplateid = reply->templates[replycount].id
     SET pos = locateval(idx,1,size(filtered_templates->templates,5),replytemplateid,
      filtered_templates->templates[idx].id)
     IF (pos > 0)
      SET stat = alterlist(filtered_templates->templates,(size(filtered_templates->templates,5) - 1),
       (pos - 1))
     ENDIF
     SET replycount += 1
   ENDWHILE
   CALL echo(build("valid published templates with page masters with no orgs: ",validtemplatsnoorgs))
   IF (lnumberoforgs > 0)
    DECLARE validtemplatswithorgs = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     FROM cr_report_template crt,
      (dummyt d  WITH seq = value(size(filtered_templates->templates,5)))
     PLAN (d)
      JOIN (crt
      WHERE (crt.template_id=filtered_templates->templates[d.seq].id)
       AND crt.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm
       )
       AND crt.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm)
       AND crt.active_ind=1
       AND  EXISTS (
      (SELECT
       csror.static_region_id
       FROM cr_static_region_org_reltn csror,
        cr_report_static_region crsr,
        cr_template_snapshot cts
       WHERE cts.template_id=crt.template_id
        AND cts.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].
        publish_dt_tm)
        AND cts.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].publish_dt_tm
        )
        AND csror.static_region_id=crsr.static_region_id
        AND crsr.static_region_id=cts.static_region_id
        AND crsr.beg_effective_dt_tm <= cnvtdatetime(filtered_templates->templates[d.seq].
        publish_dt_tm)
        AND crsr.end_effective_dt_tm > cnvtdatetime(filtered_templates->templates[d.seq].
        publish_dt_tm)
        AND crsr.active_ind=1
        AND csror.beg_effective_dt_tm <= crsr.beg_effective_dt_tm
        AND csror.end_effective_dt_tm >= crsr.end_effective_dt_tm
        AND expand(lidx,1,lnumberoforgs,csror.organization_id,accessible_orgs->organizations[lidx].
        organization_id))))
     DETAIL
      validtemplatswithorgs += 1, xcount += 1, stat = alterlist(reply->templates,xcount),
      reply->templates[xcount].id = crt.template_id, reply->templates[xcount].name = crt
      .template_name, reply->templates[xcount].version_mode = published_version_mode
     WITH counter, expand = 0
    ;end select
    CALL echo(build("valid templates with page masters with user qualified orgs: ",
      validtemplatswithorgs))
   ENDIF
   CALL log_message("Exiting FilterPublishedTemplatesByOrg subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE filterworkingtemplatesbyposition(null)
   CALL log_message("Entered FilterWorkingTemplatesByPosition subroutine.",log_level_debug)
   SET validtemplatesnopos = 0
   SET xcount = 0
   SELECT INTO "nl:"
    crt.template_id, crt.template_name
    FROM cr_report_template crt,
     (dummyt d  WITH seq = value(size(valid_templates->templates,5)))
    PLAN (d)
     JOIN (crt
     WHERE (crt.report_template_id=valid_templates->templates[d.seq].id)
      AND crt.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      cpos.template_id
      FROM cr_template_position_reltn cpos
      WHERE cpos.template_id=crt.template_id
       AND cpos.beg_effective_dt_tm <= crt.beg_effective_dt_tm
       AND cpos.end_effective_dt_tm >= crt.end_effective_dt_tm))))
    DETAIL
     validtemplatesnopos += 1, xcount += 1, stat = alterlist(filtered_templates->templates,xcount),
     filtered_templates->templates[xcount].id = crt.template_id, filtered_templates->templates[xcount
     ].name = crt.template_name
    WITH nocounter
   ;end select
   CALL echo(build("valid working templates without assicated position: ",validtemplatesnopos))
   DECLARE tempnoposcount = i4 WITH private, noconstant(1)
   DECLARE nopostemplateid = f8 WITH private, noconstant(0.0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE pos = i4 WITH private, noconstant(0)
   WHILE (tempnoposcount <= validtemplatesnopos)
     SET nopostemplateid = filtered_templates->templates[tempnoposcount].id
     SET pos = locateval(idx,1,size(valid_templates->templates,5),nopostemplateid,valid_templates->
      templates[idx].id)
     IF (pos > 0)
      SET stat = alterlist(valid_templates->templates,(size(valid_templates->templates,5) - 1),(pos
        - 1))
     ENDIF
     SET tempnoposcount += 1
   ENDWHILE
   CALL echo(build("working templates with associated positions: ",size(valid_templates->templates,5)
     ))
   IF (userpositioncd > 0
    AND size(valid_templates->templates,5) > 0)
    DECLARE validtemplateswithpos = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     crt.template_id, crt.template_name
     FROM cr_report_template crt,
      cr_template_position_reltn cpos,
      (dummyt d  WITH seq = value(size(valid_templates->templates,5)))
     PLAN (d)
      JOIN (crt
      WHERE (crt.report_template_id=valid_templates->templates[d.seq].id)
       AND crt.active_ind=1)
      JOIN (cpos
      WHERE cpos.template_id=crt.template_id
       AND cpos.position_cd=userpositioncd
       AND cpos.active_ind=1)
     DETAIL
      validtemplateswithpos += 1, xcount += 1, stat = alterlist(filtered_templates->templates,xcount),
      filtered_templates->templates[xcount].id = crt.template_id, filtered_templates->templates[
      xcount].name = crt.template_name
     WITH counter
    ;end select
    CALL echo(build("qualified working templates for user position: ",validtemplateswithpos))
   ENDIF
   CALL log_message("Exiting FilterWorkingTemplatesByPosition subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE filterworkingtemplatesbyorg(null)
   CALL log_message("Entered FilterWorkingTemplatesByOrg subroutine.",log_level_debug)
   DECLARE validtemplatsnoorgs = i4 WITH noconstant(0)
   SET xcount = size(reply->templates,5)
   FREE RECORD templateswithnoorgs
   RECORD templateswithnoorgs(
     1 templates[*]
       2 id = f8
   )
   SELECT INTO "nl:"
    crt.template_id, crt.template_name
    FROM cr_report_template crt,
     (dummyt d  WITH seq = value(size(filtered_templates->templates,5)))
    PLAN (d)
     JOIN (crt
     WHERE (crt.report_template_id=filtered_templates->templates[d.seq].id)
      AND crt.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      csror.static_region_id
      FROM cr_template_snapshot cts,
       cr_report_static_region crsr,
       cr_static_region_org_reltn csror
      WHERE cts.template_id=crt.template_id
       AND cts.static_region_id > 0
       AND cts.active_ind=1
       AND crsr.report_static_region_id=cts.static_region_id
       AND crsr.active_ind=1
       AND csror.static_region_id=crsr.static_region_id
       AND csror.beg_effective_dt_tm <= crsr.beg_effective_dt_tm
       AND csror.end_effective_dt_tm >= crsr.end_effective_dt_tm))))
    DETAIL
     validtemplatsnoorgs += 1
     IF (mod(validtemplatsnoorgs,10)=1)
      stat = alterlist(templateswithnoorgs->templates,(validtemplatsnoorgs+ 9))
     ENDIF
     xcount += 1, stat = alterlist(reply->templates,xcount), templateswithnoorgs->templates[
     validtemplatsnoorgs].id = crt.template_id,
     reply->templates[xcount].id = crt.template_id, reply->templates[xcount].name = crt.template_name,
     reply->templates[xcount].version_mode = working_version_mode
    WITH nocounter
   ;end select
   DECLARE replycount = i4 WITH protect, noconstant(1)
   DECLARE replytemplateid = f8 WITH protect, noconstant(0.0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   WHILE (replycount <= size(templateswithnoorgs->templates,5))
     SET replytemplateid = templateswithnoorgs->templates[replycount].id
     SET pos = locateval(idx,1,size(filtered_templates->templates,5),replytemplateid,
      filtered_templates->templates[idx].id)
     IF (pos > 0)
      SET stat = alterlist(filtered_templates->templates,(size(filtered_templates->templates,5) - 1),
       (pos - 1))
     ENDIF
     SET replycount += 1
   ENDWHILE
   CALL echo(build("valid working templates with page masters with no orgs: ",validtemplatsnoorgs))
   IF (lnumberoforgs > 0)
    DECLARE validtemplatswithorgs = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     crt.template_id, crt.template_name
     FROM cr_report_template crt,
      (dummyt d  WITH seq = value(size(filtered_templates->templates,5)))
     PLAN (d)
      JOIN (crt
      WHERE (crt.report_template_id=filtered_templates->templates[d.seq].id)
       AND crt.active_ind=1
       AND  EXISTS (
      (SELECT
       csror.static_region_id
       FROM cr_template_snapshot cts,
        cr_report_static_region crsr,
        cr_static_region_org_reltn csror
       WHERE cts.template_id=crt.template_id
        AND cts.static_region_id > 0
        AND cts.active_ind=1
        AND crsr.report_static_region_id=cts.static_region_id
        AND crsr.active_ind=1
        AND csror.static_region_id=crsr.static_region_id
        AND csror.beg_effective_dt_tm <= crsr.beg_effective_dt_tm
        AND csror.end_effective_dt_tm >= crsr.end_effective_dt_tm
        AND expand(lidx,1,lnumberoforgs,csror.organization_id,accessible_orgs->organizations[lidx].
        organization_id))))
     DETAIL
      validtemplatswithorgs += 1, xcount += 1, stat = alterlist(reply->templates,xcount),
      reply->templates[xcount].id = crt.template_id, reply->templates[xcount].name = crt
      .template_name, reply->templates[xcount].version_mode = working_version_mode
     WITH counter, expand = 0
    ;end select
    CALL echo(build("valid working templates with page masters with user qualified orgs: ",
      validtemplatswithorgs))
   ENDIF
   CALL log_message("Exiting FilterWorkingTemplatesByOrg subroutine.",log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 DELETE  FROM shared_list_gttd
  WHERE source_entity_id > 0
 ;end delete
 CALL echorecord(reply)
 CALL log_message(build("End of script: cr_get_user_viewable_templates.  #Templates: ",curqual),
  log_level_debug)
END GO
