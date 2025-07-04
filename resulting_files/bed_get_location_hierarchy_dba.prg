CREATE PROGRAM bed_get_location_hierarchy:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facility[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 meaning = vc
      2 building[*]
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 meaning = vc
        3 unit[*]
          4 code_value = f8
          4 display = vc
          4 description = vc
          4 meaning = vc
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
 DECLARE facilitycd = f8 WITH protect, noconstant(0)
 DECLARE buildingcd = f8 WITH protect, noconstant(0)
 DECLARE unitcd = f8 WITH protect, noconstant(0)
 DECLARE facility_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE building_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE loadfacility(facilitycd=f8) = i2
 DECLARE loadbuildinghierarchy(buildingcd=f8) = i2
 DECLARE loadunithierarchy(unitcd=f8) = i2
 IF ((request->location_cd <= 0))
  CALL bederror("Invalid request")
 ENDIF
 SELECT INTO "nl:"
  FROM location l,
   code_value cv
  PLAN (l
   WHERE (l.location_cd=request->location_cd))
   JOIN (cv
   WHERE cv.code_value=l.location_type_cd)
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    facilitycd = l.location_cd
   ELSEIF (cv.cdf_meaning="BUILDING")
    buildingcd = l.location_cd
   ELSE
    unitcd = l.location_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (facilitycd > 0)
  CALL loadfacility(facilitycd)
 ELSEIF (buildingcd > 0)
  CALL loadbuildinghierarchy(buildingcd)
 ELSEIF (unitcd > 0)
  CALL loadunithierarchy(unitcd)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE loadfacility(facilitycd)
   CALL bedlogmessage("loadFacility","Entering...")
   SET stat = alterlist(reply->facility,1)
   SET reply->facility[1].code_value = facilitycd
   SET reply->facility[1].display = uar_get_code_display(facilitycd)
   SET reply->facility[1].description = uar_get_code_description(facilitycd)
   SET reply->facility[1].meaning = uar_get_code_meaning(facilitycd)
   CALL bedlogmessage("loadFacility","Exiting...")
 END ;Subroutine
 SUBROUTINE loadbuildinghierarchy(buildingcd)
   CALL bedlogmessage("loadBuildingHierarchy","Entering...")
   DECLARE faccnt = i4 WITH protect, noconstant(0)
   DECLARE bldcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location_group lg
    PLAN (lg
     WHERE lg.child_loc_cd=buildingcd
      AND lg.root_loc_cd=0.0
      AND lg.location_group_type_cd=facility_type_cd)
    ORDER BY lg.parent_loc_cd
    HEAD lg.parent_loc_cd
     faccnt = (faccnt+ 1), stat = alterlist(reply->facility,faccnt), reply->facility[faccnt].
     code_value = lg.parent_loc_cd,
     reply->facility[faccnt].display = uar_get_code_display(lg.parent_loc_cd), reply->facility[faccnt
     ].description = uar_get_code_description(lg.parent_loc_cd), reply->facility[faccnt].meaning =
     uar_get_code_meaning(lg.parent_loc_cd)
    HEAD lg.child_loc_cd
     bldcnt = (bldcnt+ 1), stat = alterlist(reply->facility[faccnt].building,bldcnt), reply->
     facility[faccnt].building[bldcnt].code_value = lg.child_loc_cd,
     reply->facility[faccnt].building[bldcnt].display = uar_get_code_display(lg.child_loc_cd), reply
     ->facility[faccnt].building[bldcnt].description = uar_get_code_description(lg.child_loc_cd),
     reply->facility[faccnt].building[bldcnt].meaning = uar_get_code_meaning(lg.child_loc_cd)
    WITH nocounter
   ;end select
   CALL bedlogmessage("loadBuildingHierarchy","Exiting...")
 END ;Subroutine
 SUBROUTINE loadunithierarchy(unitcd)
   CALL bedlogmessage("loadUnitHierarchy","Entering...")
   FREE RECORD getunithierrequest
   RECORD getunithierrequest(
     1 location_units[1]
       2 code_value = f8
     1 inc_inactive_ind = i2
   )
   FREE RECORD getunithierreply
   RECORD getunithierreply(
     1 facilities[*]
       2 code_value = f8
       2 display = vc
       2 description = vc
       2 buildings[*]
         3 code_value = f8
         3 display = vc
         3 description = vc
         3 units[*]
           4 code_value = f8
           4 display = vc
           4 description = vc
           4 location_type
             5 loc_type_code = f8
             5 loc_type_disp = vc
             5 loc_type_mean = vc
           4 active_ind = i2
           4 active_rel_ind = i2
         3 active_ind = i2
         3 active_rel_ind = i2
       2 active_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET getunithierrequest->location_units[1].code_value = unitcd
   EXECUTE bed_get_loc_hier_by_unit  WITH replace("REQUEST",getunithierrequest), replace("REPLY",
    getunithierreply)
   IF ((getunithierreply->status_data.status != "S"))
    IF (validate(debug,0)=1)
     CALL echorecord(getunithierrequest)
     CALL echorecord(getunithierreply)
    ENDIF
    CALL bederror("bed_get_loc_hier_by_unit failed")
   ENDIF
   FOR (f = 1 TO size(getunithierreply->facilities,5))
     SET stat = alterlist(reply->facility,f)
     SET reply->facility[f].code_value = getunithierreply->facilities[f].code_value
     SET reply->facility[f].description = getunithierreply->facilities[f].description
     SET reply->facility[f].display = getunithierreply->facilities[f].display
     SET reply->facility[f].meaning = uar_get_code_meaning(reply->facility[f].code_value)
     FOR (b = 1 TO size(getunithierreply->facilities[f].buildings,5))
       SET stat = alterlist(reply->facility[f].building,b)
       SET reply->facility[f].building[b].code_value = getunithierreply->facilities[f].buildings[b].
       code_value
       SET reply->facility[f].building[b].description = getunithierreply->facilities[f].buildings[b].
       description
       SET reply->facility[f].building[b].display = getunithierreply->facilities[f].buildings[b].
       display
       SET reply->facility[f].building[b].meaning = uar_get_code_meaning(reply->facility[f].building[
        b].code_value)
       FOR (u = 1 TO size(getunithierreply->facilities[f].buildings[b].units,5))
         SET stat = alterlist(reply->facility[f].building[b].unit,u)
         SET reply->facility[f].building[b].unit[u].code_value = getunithierreply->facilities[f].
         buildings[b].units[u].code_value
         SET reply->facility[f].building[b].unit[u].description = getunithierreply->facilities[f].
         buildings[b].units[u].description
         SET reply->facility[f].building[b].unit[u].display = getunithierreply->facilities[f].
         buildings[b].units[u].display
         SET reply->facility[f].building[b].unit[u].meaning = uar_get_code_meaning(reply->facility[f]
          .building[b].unit[u].code_value)
       ENDFOR
     ENDFOR
   ENDFOR
   CALL bedlogmessage("loadUnitHierarchy","Exiting...")
 END ;Subroutine
END GO
