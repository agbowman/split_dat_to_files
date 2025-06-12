CREATE PROGRAM bed_get_locs_for_ident_setup:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
          4 mean = vc
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
 FREE RECORD valid_facs
 RECORD valid_facs(
   1 facs[*]
     2 code_value = f8
 )
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
 DECLARE facility_cd = f8 WITH protect, noconstant(0)
 DECLARE building_cd = f8 WITH protect, noconstant(0)
 DECLARE unit_cd_nurse = f8 WITH protect, noconstant(0)
 DECLARE unit_cd_amb = f8 WITH protect, noconstant(0)
 DECLARE unit_cd_surg = f8 WITH protect, noconstant(0)
 DECLARE unit_cd_pharm = f8 WITH protect, noconstant(0)
 DECLARE getsetupidlocationhierarchy(dummyvar=i2) = null
 CALL getsetupidlocationhierarchy(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getsetupidlocationhierarchy(dummyvar)
   CALL bedlogmessage("getSetupIDLocationHierarchy","Entering...")
   SET facility_cd = uar_get_code_by("MEANING",222,"FACILITY")
   SET building_cd = uar_get_code_by("MEANING",222,"BUILDING")
   SET unit_cd_nurse = uar_get_code_by("MEANING",222,"NURSEUNIT")
   SET unit_cd_amb = uar_get_code_by("MEANING",222,"AMBULATORY")
   SET unit_cd_surg = uar_get_code_by("MEANING",222,"ANCILSURG")
   SET unit_cd_pharm = uar_get_code_by("MEANING",222,"PHARM")
   DECLARE search_string = vc
   SET search_string = "*"
   IF (trim(request->search_string) > " ")
    IF ((request->search_type_flag="S"))
     SET search_string = concat(trim(cnvtupper(request->search_string)),"*")
    ELSE
     SET search_string = concat("*",trim(cnvtupper(request->search_string)),"*")
    ENDIF
   ENDIF
   DECLARE fac_name_parse = vc
   IF ((request->search_field=1))
    SET fac_name_parse = concat("cnvtupper(cv3.display) = '",search_string,"'")
   ELSE
    SET fac_name_parse = concat("cnvtupper(cv3.description) = '",search_string,"'")
   ENDIF
   CALL echo(fac_name_parse)
   SET valid_fac_cnt = 0
   IF ((request->only_locs_without_ccn_ind=1))
    SELECT INTO "nl:"
     FROM location l,
      code_value cv1,
      location_group lg1,
      code_value cv2,
      location_group lg2,
      code_value cv3
     PLAN (l
      WHERE l.location_type_cd IN (unit_cd_nurse, unit_cd_amb, unit_cd_surg, unit_cd_pharm)
       AND l.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=l.location_cd
       AND cv1.active_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       bswlr.location_cd
       FROM br_setup_wizard_loc_reltn bswlr,
        br_setup_wizard bsw
       WHERE bswlr.location_cd=l.location_cd
        AND bswlr.br_setup_wizard_id=bsw.br_setup_wizard_id
        AND (bsw.setup_wizard_flag=request->wizard_setup_flag)))))
      JOIN (lg1
      WHERE lg1.child_loc_cd=l.location_cd
       AND lg1.location_group_type_cd=building_cd
       AND lg1.active_ind=1)
      JOIN (cv2
      WHERE cv2.code_value=lg1.parent_loc_cd
       AND cv2.active_ind=1)
      JOIN (lg2
      WHERE lg2.child_loc_cd=lg1.parent_loc_cd
       AND lg2.location_group_type_cd=facility_cd
       AND lg2.active_ind=1)
      JOIN (cv3
      WHERE cv3.code_value=lg2.parent_loc_cd
       AND cv3.active_ind=1
       AND parser(fac_name_parse))
     DETAIL
      found_ind = 0, start = 1, num = 0
      IF (valid_fac_cnt > 0)
       found_ind = locateval(num,start,valid_fac_cnt,cv3.code_value,valid_facs->facs[num].code_value)
      ENDIF
      IF (found_ind=0)
       valid_fac_cnt = (valid_fac_cnt+ 1), stat = alterlist(valid_facs->facs,valid_fac_cnt),
       valid_facs->facs[valid_fac_cnt].code_value = cv3.code_value
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM location l,
      code_value cv1,
      location_group lg1,
      code_value cv2,
      location_group lg2,
      code_value cv3
     PLAN (l
      WHERE l.location_type_cd IN (unit_cd_nurse, unit_cd_amb, unit_cd_surg, unit_cd_pharm)
       AND l.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=l.location_cd
       AND cv1.active_ind=1)
      JOIN (lg1
      WHERE lg1.child_loc_cd=l.location_cd
       AND lg1.location_group_type_cd=building_cd
       AND lg1.active_ind=1)
      JOIN (cv2
      WHERE cv2.code_value=lg1.parent_loc_cd
       AND cv2.active_ind=1)
      JOIN (lg2
      WHERE lg2.child_loc_cd=lg1.parent_loc_cd
       AND lg2.location_group_type_cd=facility_cd
       AND lg2.active_ind=1)
      JOIN (cv3
      WHERE cv3.code_value=lg2.parent_loc_cd
       AND cv3.active_ind=1
       AND parser(fac_name_parse))
     DETAIL
      found_ind = 0, start = 1, num = 0
      IF (valid_fac_cnt > 0)
       found_ind = locateval(num,start,valid_fac_cnt,cv3.code_value,valid_facs->facs[num].code_value)
      ENDIF
      IF (found_ind=0)
       valid_fac_cnt = (valid_fac_cnt+ 1), stat = alterlist(valid_facs->facs,valid_fac_cnt),
       valid_facs->facs[valid_fac_cnt].code_value = cv3.code_value
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->max_reply > 0)
    AND (valid_fac_cnt > request->max_reply))
    SET reply->too_many_results_ind = 1
    RETURN
   ENDIF
   IF (valid_fac_cnt > 0)
    SET fcnt = 0
    IF ((request->only_locs_without_ccn_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = valid_fac_cnt),
       location_group lg1,
       code_value cv1,
       location_group lg2,
       code_value cv2,
       location l,
       code_value cv3
      PLAN (d)
       JOIN (lg1
       WHERE (lg1.parent_loc_cd=valid_facs->facs[d.seq].code_value)
        AND lg1.location_group_type_cd=facility_cd
        AND lg1.active_ind=1)
       JOIN (cv1
       WHERE cv1.code_value=lg1.parent_loc_cd
        AND cv1.active_ind=1)
       JOIN (lg2
       WHERE lg2.parent_loc_cd=lg1.child_loc_cd
        AND lg2.location_group_type_cd=building_cd
        AND lg2.active_ind=1)
       JOIN (cv2
       WHERE cv2.code_value=lg2.parent_loc_cd
        AND cv2.active_ind=1)
       JOIN (l
       WHERE l.location_cd=lg2.child_loc_cd
        AND l.location_type_cd IN (unit_cd_nurse, unit_cd_amb, unit_cd_surg, unit_cd_pharm)
        AND l.active_ind=1)
       JOIN (cv3
       WHERE cv3.code_value=l.location_cd
        AND cv3.active_ind=1
        AND  NOT ( EXISTS (
       (SELECT
        bswlr.location_cd
        FROM br_setup_wizard_loc_reltn bswlr,
         br_setup_wizard bsw
        WHERE bswlr.location_cd=l.location_cd
         AND bswlr.br_setup_wizard_id=bsw.br_setup_wizard_id
         AND (bsw.setup_wizard_flag=request->wizard_setup_flag)))))
      ORDER BY cv1.code_value, cv2.code_value, cv3.code_value
      HEAD cv1.code_value
       fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value
        = cv1.code_value,
       reply->facilities[fcnt].display = cv1.display, reply->facilities[fcnt].description = cv1
       .description, bcnt = 0
      HEAD cv2.code_value
       bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings,bcnt), reply->facilities[
       fcnt].buildings[bcnt].code_value = cv2.code_value,
       reply->facilities[fcnt].buildings[bcnt].display = cv2.display, reply->facilities[fcnt].
       buildings[bcnt].description = cv2.description, ucnt = 0
      HEAD cv3.code_value
       ucnt = (ucnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,ucnt), reply
       ->facilities[fcnt].buildings[bcnt].units[ucnt].code_value = cv3.code_value,
       reply->facilities[fcnt].buildings[bcnt].units[ucnt].display = cv3.display, reply->facilities[
       fcnt].buildings[bcnt].units[ucnt].description = cv3.description, reply->facilities[fcnt].
       buildings[bcnt].units[ucnt].mean = cv3.cdf_meaning
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = valid_fac_cnt),
       location_group lg1,
       code_value cv1,
       location_group lg2,
       code_value cv2,
       location l,
       code_value cv3
      PLAN (d)
       JOIN (lg1
       WHERE (lg1.parent_loc_cd=valid_facs->facs[d.seq].code_value)
        AND lg1.location_group_type_cd=facility_cd
        AND lg1.active_ind=1)
       JOIN (cv1
       WHERE cv1.code_value=lg1.parent_loc_cd
        AND cv1.active_ind=1)
       JOIN (lg2
       WHERE lg2.parent_loc_cd=lg1.child_loc_cd
        AND lg2.location_group_type_cd=building_cd
        AND lg2.active_ind=1)
       JOIN (cv2
       WHERE cv2.code_value=lg2.parent_loc_cd
        AND cv2.active_ind=1)
       JOIN (l
       WHERE l.location_cd=lg2.child_loc_cd
        AND l.location_type_cd IN (unit_cd_nurse, unit_cd_amb, unit_cd_surg, unit_cd_pharm)
        AND l.active_ind=1)
       JOIN (cv3
       WHERE cv3.code_value=l.location_cd
        AND cv3.active_ind=1)
      ORDER BY cv1.code_value, cv2.code_value, cv3.code_value
      HEAD cv1.code_value
       fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value
        = cv1.code_value,
       reply->facilities[fcnt].display = cv1.display, reply->facilities[fcnt].description = cv1
       .description, bcnt = 0
      HEAD cv2.code_value
       bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings,bcnt), reply->facilities[
       fcnt].buildings[bcnt].code_value = cv2.code_value,
       reply->facilities[fcnt].buildings[bcnt].display = cv2.display, reply->facilities[fcnt].
       buildings[bcnt].description = cv2.description, ucnt = 0
      HEAD cv3.code_value
       ucnt = (ucnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].units,ucnt), reply
       ->facilities[fcnt].buildings[bcnt].units[ucnt].code_value = cv3.code_value,
       reply->facilities[fcnt].buildings[bcnt].units[ucnt].display = cv3.display, reply->facilities[
       fcnt].buildings[bcnt].units[ucnt].description = cv3.description, reply->facilities[fcnt].
       buildings[bcnt].units[ucnt].mean = cv3.cdf_meaning
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   CALL bederrorcheck("Failed to get location hierarchy.")
   CALL bedlogmessage("getSetupIDLocationHierarchy","Exiting...")
 END ;Subroutine
END GO
