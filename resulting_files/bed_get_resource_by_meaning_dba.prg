CREATE PROGRAM bed_get_resource_by_meaning:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 resources[*]
      2 code_value = f8
      2 cdf_meaning = c12
      2 description = c200
      2 display = c40
      2 active_ind = i2
      2 status_ind = i2
      2 child_ind = i2
      2 root_service_resource_cd = f8
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
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE deleted_code = f8 WITH protect, constant(reqdata->deleted_cd)
 DECLARE resource_cnt = i4 WITH protect, noconstant(0)
 SELECT
  IF ((request->get_all_flag=0)
   AND (request->get_view_flag=1)
   AND (request->get_master_flag=0))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.root_service_resource_cd=sr.service_resource_cd
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=0)
   AND (request->get_view_flag=0)
   AND (request->get_master_flag=0))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.root_service_resource_cd=0
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=1)
   AND (request->get_view_flag=1)
   AND (request->get_master_flag=0))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.root_service_resource_cd=sr.service_resource_cd
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=1)
   AND (request->get_view_flag=0)
   AND (request->get_master_flag=0))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.root_service_resource_cd=0
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=0)
   AND (request->get_view_flag=1)
   AND (request->get_master_flag=1))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=0)
   AND (request->get_view_flag=0)
   AND (request->get_master_flag=1))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=1)
   AND (request->get_view_flag=1)
   AND (request->get_master_flag=1))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSEIF ((request->get_all_flag=1)
   AND (request->get_view_flag=0)
   AND (request->get_master_flag=1))
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_type_cd != deleted_code)
    JOIN (sr
    WHERE c.code_value=sr.service_resource_cd)
    JOIN (o
    WHERE o.organization_id=sr.organization_id
     AND ((o.logical_domain_id=log_domain_id) OR (o.organization_id=0)) )
    JOIN (d)
    JOIN (r
    WHERE r.parent_service_resource_cd=c.code_value
     AND r.active_status_cd != deleted_code)
    JOIN (sr2
    WHERE sr2.service_resource_cd=r.child_service_resource_cd)
  ELSE
  ENDIF
  INTO "nl:"
  c.code_value, r.parent_service_resource_cd
  FROM code_value c,
   resource_group r,
   (dummyt d  WITH seq = 1),
   service_resource sr,
   service_resource sr2,
   organization o
  ORDER BY c.code_value
  HEAD REPORT
   resource_cnt = 0, stat = alterlist(reply->resources,1)
  HEAD c.code_value
   resource_cnt = (resource_cnt+ 1)
   IF (mod(resource_cnt,10)=2)
    stat = alterlist(reply->resources,(resource_cnt+ 9))
   ENDIF
   reply->resources[resource_cnt].code_value = c.code_value, reply->resources[resource_cnt].
   cdf_meaning = c.cdf_meaning, reply->resources[resource_cnt].display = c.display,
   reply->resources[resource_cnt].description = c.description, reply->resources[resource_cnt].
   active_ind = c.active_ind
   IF (c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    reply->resources[resource_cnt].status_ind = 1
   ELSE
    reply->resources[resource_cnt].status_ind = 0
   ENDIF
  DETAIL
   IF ((request->get_all_flag=0)
    AND r.parent_service_resource_cd > 0
    AND r.active_ind=1
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    reply->resources[resource_cnt].child_ind = 1
   ELSEIF ((request->get_all_flag=1)
    AND r.parent_service_resource_cd > 0)
    reply->resources[resource_cnt].child_ind = 1
   ENDIF
   IF ((request->get_view_flag=1))
    reply->resources[resource_cnt].root_service_resource_cd = sr.service_resource_cd
   ELSE
    reply->resources[resource_cnt].root_service_resource_cd = 0
   ENDIF
  WITH nocounter, outerjoin = d, orahint("index(r xpkresource_group)")
 ;end select
 SET stat = alterlist(reply->resources,resource_cnt)
 CALL bedexitscript(0)
END GO
