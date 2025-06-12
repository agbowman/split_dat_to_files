CREATE PROGRAM bed_get_gpros:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 gpros[*]
      2 gpro_id = f8
      2 gpro_name = vc
      2 tin = vc
      2 providers[*]
        3 provider_id = f8
        3 provider_name = vc
        3 tin = vc
        3 npi = vc
        3 active_ind = i2
        3 effective_ind = i2
        3 aci_exclusion_ind = i2
      2 address
        3 address_id = f8
        3 street_addr1 = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city = vc
        3 state_code_value = f8
        3 state_display = vc
        3 state_mean = vc
        3 zipcode = vc
        3 county_code_value = f8
        3 county_display = vc
        3 county_mean = vc
        3 country_code_value = f8
        3 country_display = vc
        3 country_mean = vc
        3 contact_name = vc
        3 comment_txt = vc
      2 phone
        3 phone_id = f8
        3 phone_format_code_value = f8
        3 phone_format_display = vc
        3 phone_format_mean = vc
        3 phone_num = vc
        3 contact = vc
        3 call_instruction = vc
        3 extension = vc
      2 locations[*]
        3 location_cd = f8
        3 location_name_with_parent = vc
      2 submit_type_flag = i2
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
 CALL bedbeginscript(0)
 DECLARE parent_entity_eligible_provider = vc WITH protect, constant("BR_ELIGIBLE_PROVIDER")
 DECLARE parent_entity_br_gpro = vc WITH protect, constant("BR_GPRO")
 DECLARE parent_entity_locations = vc WITH protect, constant("LOCATION")
 DECLARE group_cnt = i4 WITH protect, noconstant(size(request->groups,5))
 DECLARE group_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE group_loc_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE getallgpros(dummyvar=i2) = null
 DECLARE getgprosbyids(dummyvar=i2) = null
 DECLARE getrelationsforgpros(dummyvar=i2) = null
 DECLARE getaddressforgpros(dummyvar=i2) = null
 DECLARE getphoneforgpros(dummyvar=i2) = null
 DECLARE getlocationsforgpros(dummyvar=i2) = null
 DECLARE getlocationhierarchy(dummyvar=i2) = null
 DECLARE getparentlocation(locationcd=f8,locationname=vc(ref)) = f8
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
 replace("REPLY",acm_get_curr_logical_domain_rep)
 IF (group_cnt=0)
  CALL getallgpros(0)
 ELSE
  CALL getgprosbyids(0)
 ENDIF
 IF (size(reply->gpros,5) > 0)
  IF ((request->only_gpro_flag=0))
   CALL getrelationsforgpros(0)
   CALL getaddressforgpros(0)
   CALL getphoneforgpros(0)
   CALL getlocationsforgpros(0)
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getallgpros(dummyvar)
  SELECT INTO "nl:"
   FROM br_gpro bg
   PLAN (bg
    WHERE bg.br_gpro_id > 0.0
     AND (bg.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id)
     AND bg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND bg.active_ind=1)
   HEAD bg.br_gpro_id
    group_cnt = (group_cnt+ 1), stat = alterlist(reply->gpros,group_cnt), reply->gpros[group_cnt].
    gpro_id = bg.br_gpro_id,
    reply->gpros[group_cnt].gpro_name = bg.br_gpro_name, reply->gpros[group_cnt].tin = bg
    .tax_id_nbr_txt, reply->gpros[group_cnt].submit_type_flag = bg.submit_type_flag
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 001: Error in getting all GPRO groups.")
 END ;Subroutine
 SUBROUTINE getgprosbyids(dummyvar)
   SET group_cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->groups,5))),
     br_gpro bg
    PLAN (d)
     JOIN (bg
     WHERE (bg.br_gpro_id=request->groups[d.seq].br_gpro_id))
    HEAD bg.br_gpro_id
     group_cnt = (group_cnt+ 1), stat = alterlist(reply->gpros,group_cnt), reply->gpros[group_cnt].
     gpro_id = bg.br_gpro_id,
     reply->gpros[group_cnt].gpro_name = bg.br_gpro_name, reply->gpros[group_cnt].tin = bg
     .tax_id_nbr_txt, reply->gpros[group_cnt].submit_type_flag = bg.submit_type_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 002: Error while getting specific GPRO groups.")
 END ;Subroutine
 SUBROUTINE getrelationsforgpros(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->gpros,5))),
    br_gpro_reltn bgr,
    br_eligible_provider ep,
    prsnl pr
   PLAN (d)
    JOIN (bgr
    WHERE (bgr.br_gpro_id=reply->gpros[d.seq].gpro_id)
     AND bgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND bgr.active_ind=1
     AND bgr.parent_entity_name=parent_entity_eligible_provider)
    JOIN (ep
    WHERE ep.br_eligible_provider_id=outerjoin(bgr.parent_entity_id))
    JOIN (pr
    WHERE pr.person_id=ep.provider_id
     AND pr.person_id > 0.0)
   HEAD d.seq
    group_reltn_cnt = 0
   DETAIL
    group_reltn_cnt = (group_reltn_cnt+ 1), stat = alterlist(reply->gpros[d.seq].providers,
     group_reltn_cnt), reply->gpros[d.seq].providers[group_reltn_cnt].provider_id = ep
    .br_eligible_provider_id,
    reply->gpros[d.seq].providers[group_reltn_cnt].provider_name = pr.name_full_formatted, reply->
    gpros[d.seq].providers[group_reltn_cnt].tin = ep.tax_id_nbr_txt, reply->gpros[d.seq].providers[
    group_reltn_cnt].npi = ep.national_provider_nbr_txt,
    reply->gpros[d.seq].providers[group_reltn_cnt].active_ind = pr.active_ind, reply->gpros[d.seq].
    providers[group_reltn_cnt].aci_exclusion_ind = bgr.aci_excluded_ind
    IF (pr.beg_effective_dt_tm < cnvtdatetime(curtime,curtime3)
     AND pr.end_effective_dt_tm > cnvtdatetime(curtime,curtime3))
     reply->gpros[d.seq].providers[group_reltn_cnt].effective_ind = 1
    ENDIF
    IF (pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     reply->gpros[d.seq].providers[group_reltn_cnt].effective_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 003: Error while getting the Eligible Providers")
 END ;Subroutine
 SUBROUTINE getaddressforgpros(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->gpros,5))),
    address addr,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (addr
    WHERE addr.parent_entity_name=parent_entity_br_gpro
     AND (addr.parent_entity_id=reply->gpros[d.seq].gpro_id))
    JOIN (cv1
    WHERE cv1.code_value=addr.address_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=addr.state_cd)
    JOIN (cv3
    WHERE cv3.code_value=addr.country_cd)
    JOIN (cv4
    WHERE cv4.code_value=addr.county_cd)
    JOIN (cv5
    WHERE cv5.code_value=addr.residence_type_cd)
   ORDER BY d.seq
   DETAIL
    reply->gpros[d.seq].address.address_id = addr.address_id, reply->gpros[d.seq].address.
    street_addr1 = addr.street_addr, reply->gpros[d.seq].address.street_addr2 = addr.street_addr2,
    reply->gpros[d.seq].address.street_addr3 = addr.street_addr3, reply->gpros[d.seq].address.
    street_addr4 = addr.street_addr4, reply->gpros[d.seq].address.city = addr.city,
    reply->gpros[d.seq].address.state_code_value = addr.state_cd, reply->gpros[d.seq].address.
    state_display = cv2.display, reply->gpros[d.seq].address.state_mean = cv2.cdf_meaning,
    reply->gpros[d.seq].address.zipcode = addr.zipcode, reply->gpros[d.seq].address.county_code_value
     = addr.county_cd, reply->gpros[d.seq].address.county_display = cv4.display,
    reply->gpros[d.seq].address.county_mean = cv4.cdf_meaning, reply->gpros[d.seq].address.
    country_code_value = addr.country_cd, reply->gpros[d.seq].address.country_display = cv3.display,
    reply->gpros[d.seq].address.country_mean = cv3.cdf_meaning, reply->gpros[d.seq].address.
    contact_name = addr.contact_name, reply->gpros[d.seq].address.comment_txt = addr.comment_txt
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 004: Error while getting the Address")
 END ;Subroutine
 SUBROUTINE getphoneforgpros(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->gpros,5))),
    phone pc,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (pc
    WHERE pc.parent_entity_name=parent_entity_br_gpro
     AND (pc.parent_entity_id=reply->gpros[d.seq].gpro_id)
     AND pc.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=pc.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=pc.phone_format_cd)
   ORDER BY d.seq
   DETAIL
    reply->gpros[d.seq].phone.phone_id = pc.phone_id, reply->gpros[d.seq].phone.
    phone_format_code_value = pc.phone_format_cd, reply->gpros[d.seq].phone.phone_format_display =
    cv2.display,
    reply->gpros[d.seq].phone.phone_format_mean = cv2.cdf_meaning, reply->gpros[d.seq].phone.
    phone_num = pc.phone_num, reply->gpros[d.seq].phone.contact = pc.contact,
    reply->gpros[d.seq].phone.call_instruction = pc.call_instruction, reply->gpros[d.seq].phone.
    extension = pc.extension
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 005: Error while getting the Phone")
 END ;Subroutine
 SUBROUTINE getlocationsforgpros(dummyvar)
   CALL bedlogmessage("getLocationsForGPROS","Entering ...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->gpros,5))),
     br_gpro_reltn bgr,
     location l,
     code_value cv
    PLAN (d)
     JOIN (bgr
     WHERE (bgr.br_gpro_id=reply->gpros[d.seq].gpro_id)
      AND bgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND bgr.active_ind=1
      AND bgr.parent_entity_name=parent_entity_locations)
     JOIN (l
     WHERE l.location_cd=outerjoin(bgr.parent_entity_id))
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.code_set=220
      AND cv.active_ind=1)
    HEAD d.seq
     group_loc_reltn_cnt = 0
    DETAIL
     group_loc_reltn_cnt = (group_loc_reltn_cnt+ 1), stat = alterlist(reply->gpros[d.seq].locations,
      group_loc_reltn_cnt), reply->gpros[d.seq].locations[group_loc_reltn_cnt].location_cd = cv
     .code_value
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 005: Error while getting the Locations")
   CALL getlocationhierarchy(0)
   CALL bedlogmessage("getLocationsForGPROS","Exiting ...")
 END ;Subroutine
 SUBROUTINE getlocationhierarchy(dummyvar)
   CALL bedlogmessage("getLocationHierarchy","Entering ...")
   DECLARE gindex = i4 WITH protect, noconstant(0)
   DECLARE lindex = i4 WITH protect, noconstant(0)
   DECLARE locationtypemean = vc WITH protect, noconstant("")
   DECLARE locationname = vc WITH protect, noconstant("")
   DECLARE parentloccd = f8 WITH protect, noconstant(0.0)
   FOR (gindex = 1 TO size(reply->gpros,5))
     FOR (lindex = 1 TO size(reply->gpros[gindex].locations,5))
       SET locationtypemean = ""
       SET locationname = ""
       SELECT INTO "nl:"
        FROM location l,
         code_value cv,
         code_value cv2
        PLAN (l
         WHERE (l.location_cd=reply->gpros[gindex].locations[lindex].location_cd))
         JOIN (cv
         WHERE cv.code_value=l.location_cd
          AND cv.code_set=220
          AND cv.active_ind=1)
         JOIN (cv2
         WHERE cv2.code_value=l.location_type_cd)
        DETAIL
         locationtypemean = cv2.cdf_meaning, locationname = cv.description
        WITH nocounter
       ;end select
       CALL bederrorcheck("ERROR 006: Error getting the Location type and name.")
       CALL bedlogmessage("locationTypeMean:",locationtypemean)
       CALL bedlogmessage("locationName:",locationname)
       IF (locationtypemean="BUILDING")
        CALL getparentlocation(reply->gpros[gindex].locations[lindex].location_cd,locationname)
       ELSEIF (locationtypemean != "FACILITY")
        SET parentloccd = getparentlocation(reply->gpros[gindex].locations[lindex].location_cd,
         locationname)
        CALL getparentlocation(parentloccd,locationname)
       ENDIF
       SET reply->gpros[gindex].locations[lindex].location_name_with_parent = locationname
     ENDFOR
   ENDFOR
   CALL bedlogmessage("getLocationHierarchy","Exiting ...")
 END ;Subroutine
 SUBROUTINE getparentlocation(locationcd,locationname)
   CALL bedlogmessage("getParentLocation","Entering ...")
   DECLARE parent_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM location_group lg,
     location l,
     code_value c
    PLAN (lg
     WHERE lg.child_loc_cd=locationcd
      AND lg.active_ind=1
      AND lg.root_loc_cd=0)
     JOIN (l
     WHERE l.location_cd=lg.parent_loc_cd
      AND l.active_ind=1
      AND (l.data_status_cd !=
     (SELECT
      code_value
      FROM code_value
      WHERE cdf_meaning="UNAUTH"
       AND code_set=8.0)))
     JOIN (c
     WHERE c.code_value=l.location_cd)
    DETAIL
     locationname = build2(trim(c.description),"/",locationname), parent_cd = c.code_value
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 007: Error getting the building name from unit.")
   CALL bedlogmessage("locationName:",locationname)
   CALL bedlogmessage("getParentLocation","Exiting ...")
   RETURN(parent_cd)
 END ;Subroutine
END GO
