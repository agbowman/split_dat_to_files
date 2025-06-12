CREATE PROGRAM bed_get_user_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 too_many_results_ind = i2
    1 prsnl_group_list[*]
      2 prsnl_group_id = f8
      2 prsnl_group_desc = vc
      2 prsnl_group_type_code = f8
      2 prsnl_group_type_display = vc
      2 prsnl_group_class_code = f8
      2 prsnl_group_class_display = vc
      2 service_resource_code = f8
      2 service_resource_desc = vc
      2 active_ind = i2
      2 prsnl_assoc_ind = i2
      2 prsnl_diff_domain_ind = i2
      2 medical_service_list[*]
        3 medical_service_cd = f8
        3 medical_service_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
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
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE getusergroupsforpersonnel(prsnlid=f8) = i2
 DECLARE getfilteredusergroups(usergroupname=vc,includeinactiveind=i2,classcd=f8) = i2
 DECLARE getusergroups(includeinactiveind=i2) = i2
 DECLARE checkforpersonnel(null) = i2
 DECLARE checkdiffdomainpersonnel(null) = i2
 DECLARE getmedicalservices(dummyvar=i2) = i2
 IF ((request->prsnl_id > 0))
  CALL getusergroupsforpersonnel(request->prsnl_id)
 ELSEIF ((((request->prsnl_group_name > "")) OR ((request->prsnl_group_class_cd > 0))) )
  CALL getfilteredusergroups(request->prsnl_group_name,request->include_inactive_ind,request->
   prsnl_group_class_cd)
 ELSE
  CALL getusergroups(request->include_inactive_ind)
 ENDIF
 SET replycnt = size(reply->prsnl_group_list,5)
 IF (replycnt > 0)
  CALL checkpersonnel(null)
  CALL checkdiffdomainpersonnel(null)
  CALL getmedicalservices(0)
 ENDIF
 SUBROUTINE getusergroupsforpersonnel(prsnlid)
   CALL bedlogmessage("getUserGroupsForPersonnel","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl_group pg,
     code_value cv,
     code_value cv1,
     code_value cv2
    PLAN (pgr
     WHERE pgr.person_id=prsnlid
      AND pgr.active_ind=true)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id
      AND pg.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND cv.code_set=357
      AND cv.display > " ")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pg.prsnl_group_class_cd))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(pg.service_resource_cd))
    ORDER BY pg.prsnl_group_id
    HEAD pg.prsnl_group_id
     cnt = (cnt+ 1), stat = alterlist(reply->prsnl_group_list,cnt), reply->prsnl_group_list[cnt].
     prsnl_group_id = pg.prsnl_group_id,
     reply->prsnl_group_list[cnt].prsnl_group_desc = pg.prsnl_group_desc, reply->prsnl_group_list[cnt
     ].active_ind = pg.active_ind, reply->prsnl_group_list[cnt].prsnl_group_type_code = pg
     .prsnl_group_type_cd,
     reply->prsnl_group_list[cnt].prsnl_group_type_display = cv.display, reply->prsnl_group_list[cnt]
     .prsnl_group_class_code = pg.prsnl_group_class_cd, reply->prsnl_group_list[cnt].
     prsnl_group_class_display = cv1.display,
     reply->prsnl_group_list[cnt].service_resource_code = pg.service_resource_cd, reply->
     prsnl_group_list[cnt].service_resource_desc = cv2.description
    WITH nocounter
   ;end select
   IF ((request->max_reply != 0)
    AND (cnt > request->max_reply))
    SET stat = alterlist(reply->prsnl_group_list,0)
    SET reply->too_many_results_ind = true
   ENDIF
   CALL bederrorcheck("Failed to retrieve user groups for the given prsnl_id.")
   CALL bedlogmessage("getUserGroupsForPersonnel","Exiting ...")
 END ;Subroutine
 SUBROUTINE getfilteredusergroups(usergroupname,includeinactiveind,classcd)
   CALL bedlogmessage("getFilteredUserGroups","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE searchexpression = vc WITH protect, noconstant("cv.code_set = 357")
   DECLARE activeindexpression = vc WITH protect, noconstant("")
   DECLARE groupexpression = vc WITH protect, noconstant("pg.prsnl_group_type_cd   = cv.code_value")
   IF (usergroupname > "")
    SET searchexpression = build2(searchexpression," and cnvtupper(cv.display)=","'*",cnvtupper(
      usergroupname),"*'")
   ENDIF
   IF (classcd > 0)
    SET groupexpression = build2(groupexpression," and pg.prsnl_group_class_cd=",classcd)
   ENDIF
   IF (includeinactiveind=0)
    SET groupexpression = build2(groupexpression," and pg.active_ind=1")
   ENDIF
   CALL echo(groupexpression)
   SELECT INTO "nl:"
    FROM code_value cv,
     prsnl_group pg,
     code_value cv1,
     code_value cv2
    PLAN (cv
     WHERE parser(searchexpression))
     JOIN (pg
     WHERE parser(groupexpression))
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pg.prsnl_group_class_cd))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(pg.service_resource_cd))
    ORDER BY pg.prsnl_group_id
    HEAD pg.prsnl_group_id
     cnt = (cnt+ 1), stat = alterlist(reply->prsnl_group_list,cnt), reply->prsnl_group_list[cnt].
     prsnl_group_id = pg.prsnl_group_id,
     reply->prsnl_group_list[cnt].prsnl_group_desc = pg.prsnl_group_desc, reply->prsnl_group_list[cnt
     ].active_ind = pg.active_ind, reply->prsnl_group_list[cnt].prsnl_group_type_code = pg
     .prsnl_group_type_cd,
     reply->prsnl_group_list[cnt].prsnl_group_type_display = cv.display, reply->prsnl_group_list[cnt]
     .prsnl_group_class_code = pg.prsnl_group_class_cd, reply->prsnl_group_list[cnt].
     prsnl_group_class_display = cv1.display,
     reply->prsnl_group_list[cnt].service_resource_code = pg.service_resource_cd, reply->
     prsnl_group_list[cnt].service_resource_desc = cv2.description
    WITH nocounter
   ;end select
   IF ((request->max_reply != 0)
    AND (cnt > request->max_reply))
    SET stat = alterlist(reply->prsnl_group_list,0)
    SET reply->too_many_results_ind = true
   ENDIF
   CALL bederrorcheck("Failed to retrieve user groups for the given filter criteria.")
   CALL bedlogmessage("getFilteredUserGroups","Exiting ...")
 END ;Subroutine
 SUBROUTINE getusergroups(includeinactiveind)
   CALL bedlogmessage("getUserGroups","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE activeindexpression = vc WITH protect, noconstant("")
   IF (includeinactiveind)
    SET activeindexpression = "pg.active_ind in(0,1)"
   ELSE
    SET activeindexpression = "pg.active_ind=1"
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl_group pg,
     code_value cv,
     code_value cv1,
     code_value cv2
    PLAN (pg
     WHERE pg.prsnl_group_id > 0
      AND parser(activeindexpression))
     JOIN (cv
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND cv.display > " ")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pg.prsnl_group_class_cd))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(pg.service_resource_cd))
    ORDER BY pg.prsnl_group_id
    HEAD pg.prsnl_group_id
     cnt = (cnt+ 1), stat = alterlist(reply->prsnl_group_list,cnt), reply->prsnl_group_list[cnt].
     prsnl_group_id = pg.prsnl_group_id,
     reply->prsnl_group_list[cnt].prsnl_group_desc = pg.prsnl_group_desc, reply->prsnl_group_list[cnt
     ].active_ind = pg.active_ind, reply->prsnl_group_list[cnt].prsnl_group_type_code = pg
     .prsnl_group_type_cd,
     reply->prsnl_group_list[cnt].prsnl_group_type_display = cv.display, reply->prsnl_group_list[cnt]
     .prsnl_group_class_code = pg.prsnl_group_class_cd, reply->prsnl_group_list[cnt].
     prsnl_group_class_display = cv1.display,
     reply->prsnl_group_list[cnt].service_resource_code = pg.service_resource_cd, reply->
     prsnl_group_list[cnt].service_resource_desc = cv2.description
    WITH nocounter
   ;end select
   IF ((request->max_reply != 0)
    AND (cnt > request->max_reply))
    SET stat = alterlist(reply->prsnl_group_list,0)
    SET reply->too_many_results_ind = true
   ENDIF
   CALL bederrorcheck("Failed to retrieve user groups.")
   CALL bedlogmessage("getUserGroups","Exiting ...")
 END ;Subroutine
 SUBROUTINE checkpersonnel(null)
   CALL bedlogmessage("checkPersonnel","Entering ...")
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     (dummyt d  WITH seq = value(replycnt))
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.prsnl_group_id=reply->prsnl_group_list[d.seq].prsnl_group_id)
      AND pgr.active_ind=1)
    DETAIL
     reply->prsnl_group_list[d.seq].prsnl_assoc_ind = 3
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to check personnel associations.")
   CALL bedlogmessage("checkPersonnel","Exiting ...")
 END ;Subroutine
 SUBROUTINE checkdiffdomainpersonnel(null)
   CALL bedlogmessage("checkDiffDomainPersonnel","Entering ...")
   RANGE OF pr IS prsnl
   SET prsnl_log_domain_ind = validate(pr.logical_domain_id)
   FREE RANGE pr
   IF (prsnl_log_domain_ind)
    SELECT INTO "nl:"
     FROM prsnl_group_reltn pgr,
      prsnl p,
      (dummyt d  WITH seq = value(replycnt))
     PLAN (d)
      JOIN (pgr
      WHERE (pgr.prsnl_group_id=reply->prsnl_group_list[d.seq].prsnl_group_id)
       AND pgr.active_ind=1)
      JOIN (p
      WHERE p.person_id=pgr.person_id
       AND p.logical_domain_id != log_domain_id)
     DETAIL
      reply->prsnl_group_list[d.seq].prsnl_diff_domain_ind = 3
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to check personnel associations.")
   ENDIF
   CALL bedlogmessage("checkDiffDomainPersonnel","Exiting ...")
 END ;Subroutine
 SUBROUTINE getmedicalservices(dummyvar)
   CALL bedlogmessage("getMedicalServices","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt dt  WITH seq = size(reply->prsnl_group_list,5)),
     prsnl_group pg,
     code_value cv,
     code_value_group cvg,
     code_value cv2
    PLAN (dt)
     JOIN (pg
     WHERE (pg.prsnl_group_id=reply->prsnl_group_list[dt.seq].prsnl_group_id))
     JOIN (cv
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND cv.cdf_meaning="MEDSERVICE")
     JOIN (cvg
     WHERE cvg.parent_code_value=cv.code_value)
     JOIN (cv2
     WHERE cv2.code_value=cvg.child_code_value)
    ORDER BY pg.prsnl_group_id
    HEAD pg.prsnl_group_id
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->prsnl_group_list[dt.seq].medical_service_list,cnt),
     reply->prsnl_group_list[dt.seq].medical_service_list[cnt].medical_service_cd = cvg
     .child_code_value,
     reply->prsnl_group_list[dt.seq].medical_service_list[cnt].medical_service_display = cv2.display
    WITH nocounter
   ;end select
   CALL bedlogmessage("getMedicalServices","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
