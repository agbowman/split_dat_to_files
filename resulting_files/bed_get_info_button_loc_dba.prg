CREATE PROGRAM bed_get_info_button_loc:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 locations[*]
      2 location_id = f8
      2 location_display = vc
      2 categories[*]
        3 category_cd = f8
        3 category_display = vc
        3 category_meaning = vc
        3 infobuttons[*]
          4 infobutton_id = f8
          4 infobutton_name = vc
          4 infobutton_type_cd = f8
          4 infobutton_type_display = vc
          4 infobutton_type_meaning = vc
          4 infobutton_default_ind = i2
          4 si_service_reltn_id = f8
          4 service_uri = vc
    1 too_many_results_ind = i2
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
 DECLARE searchtxt = vc
 DECLARE numoffacilities = i4
 DECLARE cv_parse = vc
 DECLARE ssr_parse = vc WITH protect, noconstant("")
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE toomanyindicator(dummyvar=i2) = null
 DECLARE getfacilities(dummyvar=i2) = null
 DECLARE getinfobuttons(dummyvar=i2) = null
 CALL getfacilities(0)
 CALL getinfobuttons(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getfacilities(dummyvar)
   CALL bedlogmessage("getFacilities","Entering ...")
   IF ((request->location_id > 0))
    SET cv_parse = "cv.code_value = ssr.parent_entity_id and cv.active_ind = 1"
    SET ssr_parse = concat('ssr.parent_entity_name = "LOCATION" and ssr.parent_entity_id = ',
     cnvtstring(request->location_id))
   ELSE
    IF (trim(request->search_string) > "")
     IF ((request->search_type_flag="s"))
      SET searchtxt = concat(trim(cnvtupper(request->search_string)),"*")
     ELSE
      SET searchtxt = concat("*",trim(cnvtupper(request->search_string)),"*")
     ENDIF
    ELSE
     SET searchtxt = "*"
     IF ((request->override_flag=0))
      CALL toomanyindicator(0)
     ENDIF
    ENDIF
    SET ssr_parse = 'ssr.parent_entity_name = "LOCATION"'
    SET cv_parse = "cv.code_value = ssr.parent_entity_id"
    SET cv_parse = concat(cv_parse,' and cnvtupper(cv.description) = "',searchtxt,
     '" and cv.active_ind = 1')
   ENDIF
   SET ssrcnt = 0
   SELECT INTO "nl:"
    FROM si_service_reltn ssr,
     code_value cv,
     location l,
     organization o,
     code_value cv2
    PLAN (ssr
     WHERE parser(ssr_parse))
     JOIN (cv
     WHERE parser(cv_parse))
     JOIN (l
     WHERE l.location_cd=cv.code_value)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND o.logical_domain_id=logical_domain_id)
     JOIN (cv2
     WHERE ((cv2.code_set=15782
      AND  NOT (cv2.display IN ("Allergies", "Observation Value"))) OR (cv2.code_value=0)) )
    ORDER BY ssr.parent_entity_id, cv2.code_value
    HEAD ssr.parent_entity_id
     cv2cnt = 0, ssrcnt = (ssrcnt+ 1), stat = alterlist(reply->locations,ssrcnt),
     reply->locations[ssrcnt].location_id = ssr.parent_entity_id, reply->locations[ssrcnt].
     location_display = cv.description
    HEAD cv2.code_value
     cv2cnt = (cv2cnt+ 1), sescnt = 0, stat = alterlist(reply->locations[ssrcnt].categories,cv2cnt),
     reply->locations[ssrcnt].categories[cv2cnt].category_cd = cv2.code_value, reply->locations[
     ssrcnt].categories[cv2cnt].category_display = cv2.display, reply->locations[ssrcnt].categories[
     cv2cnt].category_meaning = cv2.cdf_meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error01: error getting facilities")
   IF (ssrcnt > 5000)
    EXECUTE initrec reply
    SET reply->too_many_results_ind = 1
    GO TO exit_script
   ENDIF
   CALL bedlogmessage("getFacilities","Exiting ...")
 END ;Subroutine
 SUBROUTINE getinfobuttons(dummyvar)
   CALL bedlogmessage("getInfoButtons","Entering ...")
   DECLARE s1 = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->locations,5)),
     (dummyt d2  WITH seq = 1),
     si_service_reltn ssr,
     si_external_service si,
     code_value cv
    PLAN (d
     WHERE maxrec(d2,size(reply->locations[d.seq].categories,5)))
     JOIN (d2)
     JOIN (ssr
     WHERE (ssr.parent_entity_id=reply->locations[d.seq].location_id)
      AND ssr.parent_entity_name="LOCATION"
      AND (ssr.content_cat_filter_cd=reply->locations[d.seq].categories[d2.seq].category_cd)
      AND ssr.default_ind=1)
     JOIN (si
     WHERE si.si_external_service_id=ssr.si_external_service_id)
     JOIN (cv
     WHERE cv.code_value=ssr.external_service_type_cd)
    ORDER BY d.seq, d2.seq, ssr.parent_entity_id,
     ssr.content_cat_filter_cd
    HEAD ssr.parent_entity_id
     s1 = 0
    HEAD ssr.content_cat_filter_cd
     s1 = 1, stat = alterlist(reply->locations[d.seq].categories[d2.seq].infobuttons,s1), reply->
     locations[d.seq].categories[d2.seq].infobuttons[s1].infobutton_id = ssr.si_external_service_id,
     reply->locations[d.seq].categories[d2.seq].infobuttons[s1].infobutton_name = si.service_name,
     reply->locations[d.seq].categories[d2.seq].infobuttons[s1].infobutton_type_cd = ssr
     .external_service_type_cd, reply->locations[d.seq].categories[d2.seq].infobuttons[s1].
     infobutton_type_display = cv.display,
     reply->locations[d.seq].categories[d2.seq].infobuttons[s1].infobutton_type_meaning = cv
     .cdf_meaning, reply->locations[d.seq].categories[d2.seq].infobuttons[s1].infobutton_default_ind
      = ssr.default_ind, reply->locations[d.seq].categories[d2.seq].infobuttons[s1].
     si_service_reltn_id = ssr.si_service_reltn_id,
     reply->locations[d.seq].categories[d2.seq].infobuttons[s1].service_uri = ssr.service_uri
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error02: error getting infobuttons")
   CALL bedlogmessage("getInfoButtons","Exiting ...")
 END ;Subroutine
 SUBROUTINE toomanyindicator(dummyvar)
   CALL bedlogmessage("tooManyIndicator","Entering ...")
   SELECT INTO "nl:"
    cnt = count(DISTINCT parent_entity_id)
    FROM si_service_reltn
    WHERE parent_entity_name="LOCATION"
    FOOT REPORT
     numoffacilities = cnt
    WITH nocounter
   ;end select
   IF (numoffacilities < 100)
    SET reply->too_many_results_ind = 0
   ELSEIF (numoffacilities > 100
    AND numoffacilities < 5000)
    SET reply->too_many_results_ind = 0
    GO TO exit_script
   ELSE
    SET reply->too_many_results_ind = 1
    GO TO exit_script
   ENDIF
   CALL bedlogmessage("tooManyIndicator","Exiting ...")
 END ;Subroutine
END GO
