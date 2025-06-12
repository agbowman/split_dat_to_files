CREATE PROGRAM bed_get_facs_by_loc_type:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 facilities[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 RECORD temp(
   1 facilities[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
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
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE facility = vc WITH protect, constant("FACILITY")
 DECLARE building = vc WITH protect, constant("BUILDING")
 DECLARE ambulatory = vc WITH protect, constant("AMBULATORY")
 DECLARE returnbin = vc WITH protect, constant("RETURNBIN")
 DECLARE apptloc = vc WITH protect, constant("APPTLOC")
 DECLARE lab = vc WITH protect, constant("LAB")
 DECLARE nurseunit = vc WITH protect, constant("NURSEUNIT")
 DECLARE pharm = vc WITH protect, constant("PHARM")
 DECLARE rad = vc WITH protect, constant("RAD")
 DECLARE ancilsurg = vc WITH protect, constant("ANCILSURG")
 DECLARE max_cnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE fcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE alterlist_rcnt = i4 WITH protect, noconstant(0)
 DECLARE alterlist_fcnt = i4 WITH protect, noconstant(0)
 DECLARE fac_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bld_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ambulatory_cd = f8 WITH protect, noconstant(0.0)
 DECLARE return_bin_cd = f8 WITH protect, noconstant(0.0)
 DECLARE appt_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nurse_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pharm_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rad_cd = f8 WITH protect, noconstant(0.0)
 DECLARE lab_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ancil_surg_cd = f8 WITH protect, noconstant(0.0)
 DECLARE fac_name_parse = vc WITH protect, noconstant("")
 DECLARE building_name_parse = vc WITH protect, noconstant("")
 DECLARE unit_name_parse = vc WITH protect, noconstant("")
 DECLARE search_string = vc WITH protect, noconstant("")
 DECLARE search_string_key = vc WITH protect, noconstant("")
 SET reply->too_many_results_ind = 0
 SET max_cnt = 0
 IF (validate(request->max_reply_limit))
  IF ((request->max_reply_limit > 0))
   SET max_cnt = request->max_reply_limit
  ENDIF
 ENDIF
 SET rcnt = 0
 SET fac_cd = 0.0
 SET bld_cd = 0.0
 SET ambulatory_cd = 0.0
 SET return_bin_cd = 0.0
 SET appt_loc_cd = 0.0
 SET lab_cd = 0.0
 SET nurse_unit_cd = 0.0
 SET pharm_cd = 0.0
 SET rad_cd = 0.0
 SET ancil_surg_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN (facility, building, ambulatory, returnbin, apptloc,
  lab, nurseunit, pharm, rad, ancilsurg)
   AND ((cv.active_ind=1) OR ((request->inc_inactive_ind=1)))
  ORDER BY cv.code_value
  HEAD cv.code_value
   IF (cv.cdf_meaning=facility)
    fac_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=building)
    bld_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=ambulatory)
    ambulatory_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=returnbin)
    return_bin_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=apptloc)
    appt_loc_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=lab)
    lab_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=nurseunit)
    nurse_unit_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=pharm)
    pharm_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=rad)
    rad_cd = cv.code_value
   ELSEIF (cv.cdf_meaning=ancilsurg)
    ancil_surg_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 001: Error while getting the code_values for the type of location.")
 IF (validate(request->search_buildings))
  IF ((request->search_buildings=1))
   IF (trim(request->search_txt) > " ")
    IF ((request->search_type_flag="S"))
     SET search_string = concat(trim(cnvtupper(request->search_txt)),"*")
     SET search_string_key = concat(trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
    ELSE
     SET search_string = concat("*",trim(cnvtupper(request->search_txt)),"*")
     SET search_string_key = concat("*",trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
    ENDIF
    SET building_name_parse = concat("(cnvtupper(cv1.description) = '",search_string,"'",
     " OR (cnvtupper(cv1.display_key) = '",trim(search_string_key),
     "'"," AND cnvtupper(cv1.display) = '",search_string,"'))")
   ELSE
    SET search_string_key = "*"
    SET building_name_parse = concat("cnvtupper(cv1.display_key) = '",search_string_key,"'")
   ENDIF
   SET fcnt = 0
   SET alterlist_fcnt = 0
   SET stat = alterlist(temp->facilities,100)
   SELECT INTO "NL:"
    FROM code_value cv1,
     code_value cv2,
     location l1,
     location l2,
     organization o1,
     organization o2,
     location_group lg
    PLAN (cv1
     WHERE parser(building_name_parse)
      AND cv1.code_set=220
      AND cv1.cdf_meaning=building
      AND ((cv1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (l1
     WHERE l1.location_cd=cv1.code_value
      AND l1.location_type_cd=bld_cd
      AND l1.organization_id > 0
      AND ((l1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (o1
     WHERE o1.organization_id=l1.organization_id
      AND o1.logical_domain_id=logical_domain_id)
     JOIN (lg
     WHERE lg.child_loc_cd=cv1.code_value
      AND ((lg.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (cv2
     WHERE cv2.code_value=lg.parent_loc_cd
      AND cv2.cdf_meaning=facility
      AND ((cv2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (l2
     WHERE l2.location_cd=cv2.code_value
      AND l2.location_type_cd=fac_cd
      AND l2.organization_id > 0
      AND ((l2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (o2
     WHERE o2.organization_id=l2.organization_id
      AND o2.logical_domain_id=logical_domain_id)
    ORDER BY cv2.display_key
    HEAD REPORT
     fcnt = 0
    HEAD cv2.display_key
     fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
     IF (alterlist_fcnt > 100)
      stat = alterlist(temp->facilities,(fcnt+ 100)), alterlist_fcnt = 1
     ENDIF
     temp->facilities[fcnt].code_value = cv2.code_value, temp->facilities[fcnt].display = cv2.display,
     temp->facilities[fcnt].description = cv2.description
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 002: Error while searching building for the given search text.")
   SET stat = alterlist(temp->facilities,fcnt)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(request->search_units))
  IF ((request->search_units=1))
   IF (trim(request->search_txt) > " ")
    IF ((request->search_type_flag="S"))
     SET search_string = concat(trim(cnvtupper(request->search_txt)),"*")
     SET search_string_key = concat(trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
    ELSE
     SET search_string = concat("*",trim(cnvtupper(request->search_txt)),"*")
     SET search_string_key = concat("*",trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
    ENDIF
    SET unit_name_parse = concat("(cnvtupper(cv1.description) = '",search_string,"'",
     " OR (cnvtupper(cv1.display_key) = '",trim(search_string_key),
     "'"," AND cnvtupper(cv1.display) = '",search_string,"'))")
   ELSE
    SET search_string_key = "*"
    SET unit_name_parse = concat("cnvtupper(cv1.display_key) = '",search_string_key,"'")
   ENDIF
   SET fcnt = 0
   SET alterlist_fcnt = 0
   SET stat = alterlist(temp->facilities,100)
   SELECT INTO "NL:"
    FROM code_value cv1,
     code_value cv2,
     code_value cv3,
     location l1,
     location l2,
     location l3,
     organization o1,
     organization o2,
     organization o3,
     location_group lg1,
     location_group lg2
    PLAN (cv1
     WHERE parser(unit_name_parse)
      AND cv1.code_set=220
      AND cv1.cdf_meaning IN (ambulatory, returnbin, apptloc, lab, nurseunit,
     pharm, rad, ancilsurg)
      AND ((cv1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (l1
     WHERE l1.location_cd=cv1.code_value
      AND l1.location_type_cd IN (ambulatory_cd, return_bin_cd, appt_loc_cd, lab_cd, nurse_unit_cd,
     pharm_cd, rad_cd, ancil_surg_cd)
      AND l1.organization_id > 0
      AND ((l1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (o1
     WHERE o1.organization_id=l1.organization_id
      AND o1.logical_domain_id=logical_domain_id)
     JOIN (lg1
     WHERE lg1.child_loc_cd=cv1.code_value
      AND ((lg1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (cv2
     WHERE cv2.code_value=lg1.parent_loc_cd
      AND cv2.cdf_meaning=building
      AND ((cv2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (l2
     WHERE l2.location_cd=cv2.code_value
      AND l2.location_type_cd=bld_cd
      AND l2.organization_id > 0
      AND ((l2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (o2
     WHERE o2.organization_id=l2.organization_id
      AND o2.logical_domain_id=logical_domain_id)
     JOIN (lg2
     WHERE lg2.child_loc_cd=cv2.code_value
      AND ((lg2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (cv3
     WHERE cv3.code_value=lg2.parent_loc_cd
      AND cv3.cdf_meaning=facility
      AND ((cv3.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (l3
     WHERE l3.location_cd=cv3.code_value
      AND l3.location_type_cd=fac_cd
      AND l3.organization_id > 0
      AND ((l3.active_ind=1) OR ((request->inc_inactive_ind=1))) )
     JOIN (o3
     WHERE o3.organization_id=l3.organization_id
      AND o3.logical_domain_id=logical_domain_id)
    ORDER BY cv3.display_key
    HEAD REPORT
     fcnt = 0
    HEAD cv3.display_key
     fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
     IF (alterlist_fcnt > 100)
      stat = alterlist(temp->facilities,(fcnt+ 100)), alterlist_fcnt = 1
     ENDIF
     temp->facilities[fcnt].code_value = cv3.code_value, temp->facilities[fcnt].display = cv3.display,
     temp->facilities[fcnt].description = cv3.description
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 003: Error while searching unit for the given search text.")
   SET stat = alterlist(temp->facilities,fcnt)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(request->search_txt))
  IF (trim(request->search_txt) > " ")
   IF ((request->search_type_flag="S"))
    SET search_string = concat(trim(cnvtupper(request->search_txt)),"*")
    SET search_string_key = concat(trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
   ELSE
    SET search_string = concat("*",trim(cnvtupper(request->search_txt)),"*")
    SET search_string_key = concat("*",trim(cnvtupper(cnvtalphanum(request->search_txt))),"*")
   ENDIF
   SET fac_name_parse = concat("(cnvtupper(cv.description) = '",search_string,"'",
    " OR cnvtupper(cv.display_key) = '",search_string_key,
    "')")
  ELSE
   SET search_string = "*"
   SET fac_name_parse = concat("cnvtupper(cv.display_key) = '",search_string,"'")
  ENDIF
 ELSE
  SET search_string = "*"
  SET fac_name_parse = concat("cnvtupper(cv.display_key) = '",search_string,"'")
 ENDIF
 SET fcnt = 0
 SET alterlist_fcnt = 0
 SET stat = alterlist(temp->facilities,100)
 SELECT INTO "NL:"
  FROM code_value cv,
   location l,
   organization o
  PLAN (cv
   WHERE parser(fac_name_parse)
    AND cv.code_set=220
    AND cv.cdf_meaning=facility
    AND ((cv.active_ind=1) OR ((request->inc_inactive_ind=1))) )
   JOIN (l
   WHERE l.location_cd=cv.code_value
    AND l.location_type_cd=fac_cd
    AND l.organization_id > 0
    AND ((l.active_ind=1) OR ((request->inc_inactive_ind=1))) )
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.logical_domain_id=logical_domain_id)
  ORDER BY cv.display_key
  HEAD REPORT
   fcnt = 0
  DETAIL
   fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 100)
    stat = alterlist(temp->facilities,(fcnt+ 100)), alterlist_fcnt = 1
   ENDIF
   temp->facilities[fcnt].code_value = cv.code_value, temp->facilities[fcnt].display = cv.display,
   temp->facilities[fcnt].description = cv.description
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 004: Error while searching facility for the given search text.")
 SET stat = alterlist(temp->facilities,fcnt)
#exit_script
 IF (fcnt > 0)
  SET alterlist_rcnt = 0
  SET stat = alterlist(reply->facilities,100)
  DECLARE loc_type_parse = vc
  SET loc_type_parse = build2("l2.location_cd = lg2.child_loc_cd and ","(l2.active_ind+0 = 1 OR ",
   request->inc_inactive_ind," = 1) and l2.location_type_cd+0 in (")
  SET lcnt = size(request->location_types,5)
  FOR (l = 1 TO lcnt)
    IF (l=lcnt)
     SET loc_type_parse = build(loc_type_parse,request->location_types[l].code_value,")")
    ELSE
     SET loc_type_parse = build(loc_type_parse,request->location_types[l].code_value,",")
    ENDIF
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = fcnt),
    location_group lg1,
    location_group lg2,
    code_value cv1,
    code_value cv2,
    location l1,
    location l2
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.parent_loc_cd=temp->facilities[d.seq].code_value)
     AND ((lg1.location_group_type_cd+ 0)=fac_cd)
     AND ((lg1.root_loc_cd+ 0)=0)
     AND ((((lg1.active_ind+ 0)=1)) OR ((request->inc_inactive_ind=1))) )
    JOIN (cv1
    WHERE cv1.code_value=lg1.child_loc_cd
     AND ((cv1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
    JOIN (l1
    WHERE l1.location_cd=cv1.code_value
     AND ((l1.active_ind=1) OR ((request->inc_inactive_ind=1))) )
    JOIN (lg2
    WHERE lg2.parent_loc_cd=lg1.child_loc_cd
     AND ((lg2.location_group_type_cd+ 0)=bld_cd)
     AND ((lg2.root_loc_cd+ 0)=0)
     AND ((((lg2.active_ind+ 0)=1)) OR ((request->inc_inactive_ind=1))) )
    JOIN (cv2
    WHERE cv2.code_value=lg1.child_loc_cd
     AND ((cv2.active_ind=1) OR ((request->inc_inactive_ind=1))) )
    JOIN (l2
    WHERE parser(loc_type_parse))
   ORDER BY lg1.parent_loc_cd
   HEAD lg1.parent_loc_cd
    rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
    IF (alterlist_rcnt > 100)
     stat = alterlist(reply->facilities,(rcnt+ 100)), alterlist_rcnt = 1
    ENDIF
    reply->facilities[rcnt].code_value = temp->facilities[d.seq].code_value, reply->facilities[rcnt].
    display = temp->facilities[d.seq].display, reply->facilities[rcnt].description = temp->
    facilities[d.seq].description
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 005: Error while assembling reply from temp.")
  SET stat = alterlist(reply->facilities,rcnt)
 ENDIF
 IF (max_cnt > 0)
  IF (rcnt > max_cnt)
   SET stat = alterlist(reply->facilities,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ENDIF
 CALL bedexitscript(0)
END GO
