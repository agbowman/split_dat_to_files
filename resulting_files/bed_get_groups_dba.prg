CREATE PROGRAM bed_get_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 br_group_id = f8
      2 group_name = vc
      2 group_type_flag = i2
      2 relations[*]
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 relation_display = vc
        3 active_ind = i2
        3 effective_ind = i2
        3 tier2_group_ld_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD repgroups
 RECORD repgroups(
   1 groups[*]
     2 br_group_id = f8
     2 group_name = vc
     2 group_type_flag = i2
     2 relations[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 relation_display = vc
       3 active_ind = i2
       3 effective_ind = i2
 ) WITH protect
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE group_cnt = i4 WITH noconstant(size(request->groups,5)), protect
 DECLARE selected_group_cnt = i4 WITH noconstant(0), protect
 DECLARE group_reltn_cnt = i4 WITH protect
 DECLARE asscnt = i4 WITH noconstant(0), protect
 DECLARE repgrpcnt = i4 WITH noconstant(1), protect
 DECLARE reprelcnt = i4 WITH noconstant(1), protect
 DECLARE logical_domain_id = f8 WITH noconstant(0.0), protect
 SET logical_domain_id = bedgetlogicaldomain(0)
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
    IF (validate(ld_concept_person)=0)
     DECLARE ld_concept_person = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_prsnl)=0)
     DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
    ENDIF
    IF (validate(ld_concept_organization)=0)
     DECLARE ld_concept_organization = i2 WITH public, constant(3)
    ENDIF
    IF (validate(ld_concept_healthplan)=0)
     DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
    ENDIF
    IF (validate(ld_concept_alias_pool)=0)
     DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
    ENDIF
    IF (validate(ld_concept_minvalue)=0)
     DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_maxvalue)=0)
     DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
    ENDIF
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
 ENDIF
 DECLARE getgroups(dummyvar=i2) = null
 DECLARE getreltngroups(dummyvar=i2) = null
 IF (group_cnt=0)
  CALL getgroups(0)
 ELSE
  CALL getreltngroups(0)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getgroups(dummyvar)
  CALL bedlogmessage("getGroups","Entering ...")
  IF ((request->group_type_flag=1))
   SELECT INTO "nl:"
    FROM br_group bg,
     br_group_reltn bgr,
     br_eligible_provider ep,
     prsnl pr
    PLAN (bg
     WHERE (bg.group_type_flag=request->group_type_flag))
     JOIN (bgr
     WHERE bgr.br_group_id=bg.br_group_id)
     JOIN (ep
     WHERE ep.br_eligible_provider_id=bgr.parent_entity_id
      AND ep.logical_domain_id=logical_domain_id
      AND ep.active_ind=1
      AND ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (pr
     WHERE pr.person_id=outerjoin(ep.provider_id))
    ORDER BY bg.br_group_id
    HEAD bg.br_group_id
     group_cnt = (group_cnt+ 1), stat = alterlist(reply->groups,group_cnt), reply->groups[group_cnt].
     br_group_id = bg.br_group_id,
     reply->groups[group_cnt].group_name = bg.group_name, reply->groups[group_cnt].group_type_flag =
     bg.group_type_flag, group_reltn_cnt = 0
    DETAIL
     group_reltn_cnt = (group_reltn_cnt+ 1), stat = alterlist(reply->groups[group_cnt].relations,
      group_reltn_cnt), reply->groups[group_cnt].relations[group_reltn_cnt].parent_entity_name = bgr
     .parent_entity_name,
     reply->groups[group_cnt].relations[group_reltn_cnt].parent_entity_id = bgr.parent_entity_id
     IF (pr.person_id > 0.0)
      reply->groups[group_cnt].relations[group_reltn_cnt].relation_display = pr.name_full_formatted,
      reply->groups[group_cnt].relations[group_reltn_cnt].active_ind = pr.active_ind
      IF (pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->groups[group_cnt].relations[group_reltn_cnt].effective_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Group select groups error flag 1")
  ELSEIF ((request->group_type_flag=2))
   SELECT INTO "nl:"
    FROM br_group bg,
     br_group_reltn bgr,
     br_group bg2,
     br_group_reltn bgr2,
     br_eligible_provider ep
    PLAN (bg
     WHERE (bg.group_type_flag=request->group_type_flag))
     JOIN (bgr
     WHERE bgr.br_group_id=bg.br_group_id)
     JOIN (bg2
     WHERE bg2.br_group_id=bgr.parent_entity_id)
     JOIN (bgr2
     WHERE bgr2.br_group_id=bg2.br_group_id)
     JOIN (ep
     WHERE ep.br_eligible_provider_id=bgr2.parent_entity_id
      AND ep.logical_domain_id=logical_domain_id
      AND ep.active_ind=1
      AND ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY bg.br_group_id, bg2.br_group_id
    HEAD bg.br_group_id
     group_cnt = (group_cnt+ 1), stat = alterlist(repgroups->groups,group_cnt), repgroups->groups[
     group_cnt].br_group_id = bg.br_group_id,
     repgroups->groups[group_cnt].group_name = bg.group_name, repgroups->groups[group_cnt].
     group_type_flag = bg.group_type_flag, group_reltn_cnt = 0
    HEAD bg2.br_group_id
     group_reltn_cnt = (group_reltn_cnt+ 1), stat = alterlist(repgroups->groups[group_cnt].relations,
      group_reltn_cnt), repgroups->groups[group_cnt].relations[group_reltn_cnt].parent_entity_name =
     bgr.parent_entity_name,
     repgroups->groups[group_cnt].relations[group_reltn_cnt].parent_entity_id = bgr.parent_entity_id
     IF (bg2.br_group_id > 0.0)
      repgroups->groups[group_cnt].relations[group_reltn_cnt].relation_display = bg2.group_name,
      repgroups->groups[group_cnt].relations[group_reltn_cnt].active_ind = 1, repgroups->groups[
      group_cnt].relations[group_reltn_cnt].effective_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR Copying the request into free record")
   FOR (repgrpcnt = 1 TO size(repgroups->groups,5))
     SET stat = alterlist(reply->groups,repgrpcnt)
     SET reply->groups[repgrpcnt].br_group_id = repgroups->groups[repgrpcnt].br_group_id
     SET reply->groups[repgrpcnt].group_name = repgroups->groups[repgrpcnt].group_name
     SET reply->groups[repgrpcnt].group_type_flag = repgroups->groups[repgrpcnt].group_type_flag
     FOR (reprelcnt = 1 TO size(repgroups->groups[repgrpcnt].relations,5))
       SET stat = alterlist(reply->groups[repgrpcnt].relations,reprelcnt)
       SET reply->groups[repgrpcnt].relations[reprelcnt].parent_entity_name = repgroups->groups[
       repgrpcnt].relations[reprelcnt].parent_entity_name
       SET reply->groups[repgrpcnt].relations[reprelcnt].parent_entity_id = repgroups->groups[
       repgrpcnt].relations[reprelcnt].parent_entity_id
       SET reply->groups[repgrpcnt].relations[reprelcnt].relation_display = repgroups->groups[
       repgrpcnt].relations[reprelcnt].relation_display
       SET reply->groups[repgrpcnt].relations[reprelcnt].active_ind = repgroups->groups[repgrpcnt].
       relations[reprelcnt].active_ind
       SET reply->groups[repgrpcnt].relations[reprelcnt].effective_ind = repgroups->groups[repgrpcnt]
       .relations[reprelcnt].effective_ind
       SELECT INTO "nl:"
        FROM br_group_reltn bgr,
         br_eligible_provider ep
        PLAN (bgr
         WHERE (bgr.br_group_id=repgroups->groups[repgrpcnt].relations[reprelcnt].parent_entity_id))
         JOIN (ep
         WHERE ep.br_eligible_provider_id=bgr.parent_entity_id
          AND ep.logical_domain_id != logical_domain_id)
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET reply->groups[repgrpcnt].relations[reprelcnt].tier2_group_ld_ind = 1
       ELSE
        SET reply->groups[repgrpcnt].relations[reprelcnt].tier2_group_ld_ind = 0
       ENDIF
       CALL bederrorcheck("Group select groups error flag 2")
     ENDFOR
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE getreltngroups(dummyvar)
  CALL bedlogmessage("getReltnGroups","Entering ...")
  IF ((request->group_type_flag=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->groups,5))),
     br_group bg,
     br_group_reltn bgr,
     br_eligible_provider ep,
     prsnl pr
    PLAN (d)
     JOIN (bg
     WHERE (bg.group_type_flag=request->group_type_flag)
      AND (bg.br_group_id=request->groups[d.seq].br_group_id))
     JOIN (bgr
     WHERE bgr.br_group_id=bg.br_group_id)
     JOIN (ep
     WHERE ep.br_eligible_provider_id=bgr.parent_entity_id
      AND ep.logical_domain_id=logical_domain_id
      AND ep.active_ind=1
      AND ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (pr
     WHERE pr.person_id=outerjoin(ep.provider_id))
    ORDER BY bg.br_group_id
    HEAD bg.br_group_id
     selected_group_cnt = (selected_group_cnt+ 1), stat = alterlist(reply->groups,selected_group_cnt),
     reply->groups[selected_group_cnt].br_group_id = bg.br_group_id,
     reply->groups[selected_group_cnt].group_name = bg.group_name, reply->groups[selected_group_cnt].
     group_type_flag = bg.group_type_flag, group_reltn_cnt = 0
    DETAIL
     group_reltn_cnt = (group_reltn_cnt+ 1), stat = alterlist(reply->groups[selected_group_cnt].
      relations,group_reltn_cnt), reply->groups[selected_group_cnt].relations[group_reltn_cnt].
     parent_entity_name = bgr.parent_entity_name,
     reply->groups[selected_group_cnt].relations[group_reltn_cnt].parent_entity_id = bgr
     .parent_entity_id
     IF (pr.person_id > 0.0)
      reply->groups[selected_group_cnt].relations[group_reltn_cnt].relation_display = pr
      .name_full_formatted, reply->groups[selected_group_cnt].relations[group_reltn_cnt].active_ind
       = pr.active_ind
      IF (pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->groups[selected_group_cnt].relations[group_reltn_cnt].effective_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Group select relations error flag 1")
  ELSEIF ((request->group_type_flag=2))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->groups,5))),
     br_group bg,
     br_group_reltn bgr,
     br_group bg2,
     br_group_reltn bgr2,
     br_eligible_provider ep
    PLAN (d)
     JOIN (bg
     WHERE (bg.group_type_flag=request->group_type_flag)
      AND (bg.br_group_id=request->groups[d.seq].br_group_id))
     JOIN (bgr
     WHERE bgr.br_group_id=bg.br_group_id)
     JOIN (bg2
     WHERE bg2.br_group_id=outerjoin(bgr.parent_entity_id))
     JOIN (bgr2
     WHERE bgr2.br_group_id=bg2.br_group_id)
     JOIN (ep
     WHERE ep.br_eligible_provider_id=bgr2.parent_entity_id
      AND ep.logical_domain_id=logical_domain_id
      AND ep.active_ind=1
      AND ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY bg.br_group_id, bg2.br_group_id
    HEAD bg.br_group_id
     selected_group_cnt = (selected_group_cnt+ 1), stat = alterlist(reply->groups,selected_group_cnt),
     reply->groups[selected_group_cnt].br_group_id = bg.br_group_id,
     reply->groups[selected_group_cnt].group_name = bg.group_name, reply->groups[selected_group_cnt].
     group_type_flag = bg.group_type_flag, group_reltn_cnt = 0
    HEAD bg2.br_group_id
     group_reltn_cnt = (group_reltn_cnt+ 1), stat = alterlist(reply->groups[selected_group_cnt].
      relations,group_reltn_cnt), reply->groups[selected_group_cnt].relations[group_reltn_cnt].
     parent_entity_name = bgr.parent_entity_name,
     reply->groups[selected_group_cnt].relations[group_reltn_cnt].parent_entity_id = bgr
     .parent_entity_id
     IF (bg2.br_group_id > 0.0)
      reply->groups[selected_group_cnt].relations[group_reltn_cnt].relation_display = bg2.group_name,
      reply->groups[selected_group_cnt].relations[group_reltn_cnt].active_ind = 1, reply->groups[
      selected_group_cnt].relations[group_reltn_cnt].effective_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Group select relations error flag 2")
  ENDIF
 END ;Subroutine
END GO
