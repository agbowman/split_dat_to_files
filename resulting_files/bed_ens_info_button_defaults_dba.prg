CREATE PROGRAM bed_ens_info_button_defaults:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
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
 CALL bedbeginscript(0)
 DECLARE category_ib_cnt = i4 WITH noconstant(0)
 DECLARE facility_cd = f8 WITH protect, constant(request->facility_cd)
 DECLARE parent_entity_name = vc WITH protect, constant("LOCATION")
 DECLARE categoryibindex = i4 WITH protect, noconstant(0)
 DECLARE addsiservicereltn(categoryibindex=i4) = null
 DECLARE updatesiservicereltn(categoryibindex=i4) = null
 DECLARE deletesiservicereltn(categoryibindex=i4) = null
 SET category_ib_cnt = size(request->categoryib,5)
 FOR (categoryibindex = 1 TO category_ib_cnt)
   IF ((request->categoryib[categoryibindex].action_flag=1))
    CALL addsiservicereltn(categoryibindex)
   ELSEIF ((request->categoryib[categoryibindex].action_flag=2))
    CALL updatesiservicereltn(categoryibindex)
   ELSEIF ((request->categoryib[categoryibindex].action_flag=3))
    CALL deletesiservicereltn(categoryibindex)
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE addsiservicereltn(categoryibindex)
   CALL bedlogmessage("addSiServiceReltn","Entering ...")
   DECLARE siservicereltnid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(si_registry_seq,nextval)
    FROM dual
    DETAIL
     siservicereltnid = cnvtreal(j)
    WITH nocounter
   ;end select
   CALL echo(siservicereltnid)
   CALL logdebugmessage("AddedCategoryIbIndex: ",categoryibindex)
   CALL logdebugmessage("AddedSiServiceReltnId: ",siservicereltnid)
   DELETE  FROM si_service_reltn ssr
    WHERE ssr.parent_entity_name=parent_entity_name
     AND ssr.parent_entity_id=facility_cd
     AND (ssr.content_cat_filter_cd=request->categoryib[categoryibindex].category_cd)
     AND (ssr.si_external_service_id=request->categoryib[categoryibindex].service_id)
     AND (ssr.external_service_type_cd=request->categoryib[categoryibindex].external_service_type_cd)
    WITH nocounter
   ;end delete
   INSERT  FROM si_service_reltn ssr
    SET ssr.si_service_reltn_id = siservicereltnid, ssr.parent_entity_name = parent_entity_name, ssr
     .parent_entity_id = facility_cd,
     ssr.si_external_service_id = request->categoryib[categoryibindex].service_id, ssr
     .content_cat_filter_cd = request->categoryib[categoryibindex].category_cd, ssr.default_ind =
     request->categoryib[categoryibindex].default_ind,
     ssr.external_service_type_cd = request->categoryib[categoryibindex].external_service_type_cd,
     ssr.service_uri = request->categoryib[categoryibindex].service_uri, ssr.listener_alias = "",
     ssr.authorization_type_cd = 0.0, ssr.auth_location_uri = "", ssr.certificate_location_uri = "",
     ssr.certificate_type_cd = 0.0, ssr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssr.updt_id =
     reqinfo->updt_id,
     ssr.updt_task = reqinfo->updt_task, ssr.updt_cnt = 0, ssr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bedlogmessage("addSiServiceReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatesiservicereltn(categoryibindex)
   CALL bedlogmessage("updateSiServiceReltn","Entering ...")
   CALL logdebugmessage("SiServiceReltnId: ",request->categoryib[categoryibindex].si_service_reltn_id
    )
   UPDATE  FROM si_service_reltn ssr
    SET ssr.default_ind = request->categoryib[categoryibindex].default_ind, ssr.updt_cnt = (ssr
     .updt_cnt+ 1), ssr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ssr.updt_id = reqinfo->updt_id, ssr.updt_task = reqinfo->updt_task, ssr.updt_applctx = reqinfo->
     updt_applctx
    WHERE ssr.parent_entity_id=facility_cd
     AND (ssr.si_external_service_id=request->categoryib[categoryibindex].service_id)
     AND ssr.content_cat_filter_cd=0
     AND (ssr.si_external_service_id=request->categoryib[categoryibindex].service_id)
     AND (ssr.external_service_type_cd=request->categoryib[categoryibindex].external_service_type_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL addsiservicereltn(categoryibindex)
   ENDIF
   CALL bedlogmessage("updateSiServiceReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletesiservicereltn(categoryibindex)
   CALL bedlogmessage("deleteSiServiceReltn","Entering ...")
   CALL logdebugmessage("Content Category Cd: ",request->categoryib[categoryibindex].category_cd)
   CALL logdebugmessage("Facility Cd: ",facility_cd)
   CALL logdebugmessage("Service Id: ",request->categoryib[categoryibindex].service_id)
   CALL logdebugmessage("Service URI: ",request->categoryib[categoryibindex].service_uri)
   DELETE  FROM si_service_reltn ssr
    WHERE ssr.parent_entity_name=parent_entity_name
     AND ssr.parent_entity_id=facility_cd
     AND (ssr.content_cat_filter_cd=request->categoryib[categoryibindex].category_cd)
     AND (ssr.si_service_reltn_id=request->categoryib[categoryibindex].si_service_reltn_id)
     AND (ssr.external_service_type_cd=request->categoryib[categoryibindex].external_service_type_cd)
    WITH nocounter
   ;end delete
   CALL bedlogmessage("deleteSiServiceReltn","Exiting ...")
 END ;Subroutine
END GO
