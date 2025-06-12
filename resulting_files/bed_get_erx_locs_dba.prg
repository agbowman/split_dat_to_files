CREATE PROGRAM bed_get_erx_locs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facilities[*]
      2 facility_code_value = f8
      2 facility_type_meaning = vc
      2 facility_display = vc
      2 erx_reltn_ind = i2
      2 buildings[*]
        3 building_code_value = f8
        3 building_type_meaning = vc
        3 building_display = vc
        3 units[*]
          4 unit_code_value = f8
          4 unit_type_meaning = vc
          4 unit_display = vc
          4 unit_desc = vc
        3 building_desc = vc
      2 organization_id = f8
      2 facility_desc = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_facs
 RECORD temp_facs(
   1 facs[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 erx_ind = i2
     2 org_id = f8
     2 desc = vc
 )
 FREE SET temp_units
 RECORD temp_units(
   1 units[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 desc = vc
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
 DECLARE iserxlocationexceedmaxcount(dummyvar=i2) = i2
 CALL bedbeginscript(0)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(bedgetlogicaldomain(0))
 DECLARE reltn_type_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE facility_code = f8 WITH protect, noconstant(0.0)
 DECLARE building_code = f8 WITH protect, noconstant(0.0)
 DECLARE max_count = i4 WITH protect, noconstant(0)
 SET reltn_type_code_value = uar_get_code_by("MEANING",30300,"EPRESCRELTN")
 SET facility_code = uar_get_code_by("MEANING",222,"FACILITY")
 SET building_code = uar_get_code_by("MEANING",222,"BUILDING")
 SET max_count = request->max_reply
 DECLARE search_string = vc
 DECLARE search_string_key = vc
 DECLARE loc_parse = vc
 IF (validate(request->search_string))
  IF (trim(request->search_string) > " ")
   IF ((request->search_type_flag="S"))
    SET search_string = concat(trim(cnvtupper(request->search_string)),"*")
    SET search_string_key = concat(trim(cnvtupper(cnvtalphanum(request->search_string))),"*")
   ELSE
    SET search_string = concat("*",trim(cnvtupper(request->search_string)),"*")
    SET search_string_key = concat("*",trim(cnvtupper(cnvtalphanum(request->search_string))),"*")
   ENDIF
   SET loc_parse = concat("(cnvtupper(c.description) = '",search_string,"'",
    " OR cnvtupper(c.display_key) = '",search_string_key,
    "')")
  ELSE
   SET search_string = "*"
   SET loc_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
  ENDIF
 ELSE
  SET search_string = "*"
  SET loc_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 SET loc_parse = concat(loc_parse," and c.active_ind = 1 ")
 DECLARE status_cd_parse = vc
 SET status_cd_parse = "e.status_cd > 0"
 IF (validate(request->inprogress_erx_reltn_ind)
  AND (request->inprogress_erx_reltn_ind=1))
  SET status_cd_parse = "e.status_cd >= 0"
 ENDIF
 CALL iserxlocationexceedmaxcount(0)
 DECLARE fcnt = i4 WITH protect, noconstant(0)
 DECLARE ucnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM eprescribe_detail e,
   prsnl_reltn p,
   location l,
   organization org,
   code_value c,
   code_value c2
  PLAN (e
   WHERE parser(status_cd_parse))
   JOIN (p
   WHERE p.prsnl_reltn_id=e.prsnl_reltn_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.parent_entity_name="LOCATION")
   JOIN (l
   WHERE l.location_cd=p.parent_entity_id
    AND l.active_ind=1)
   JOIN (org
   WHERE org.organization_id=l.organization_id
    AND org.logical_domain_id=logicaldomainid)
   JOIN (c
   WHERE c.code_value=l.location_cd
    AND parser(loc_parse))
   JOIN (c2
   WHERE c2.code_value=l.location_type_cd
    AND c2.active_ind=1)
  ORDER BY c.code_value
  HEAD REPORT
   fcnt = 0, ucnt = 0
  HEAD c.code_value
   IF (c2.cdf_meaning="FACILITY")
    fcnt = (fcnt+ 1), stat = alterlist(temp_facs->facs,fcnt), temp_facs->facs[fcnt].code_value = c
    .code_value,
    temp_facs->facs[fcnt].display = c.display, temp_facs->facs[fcnt].meaning = c.cdf_meaning,
    temp_facs->facs[fcnt].erx_ind = 1,
    temp_facs->facs[fcnt].org_id = l.organization_id, temp_facs->facs[fcnt].desc = c.description
   ELSEIF (c2.cdf_meaning IN ("AMBULATORY", "NURSEUNIT"))
    ucnt = (ucnt+ 1), stat = alterlist(temp_units->units,ucnt), temp_units->units[ucnt].code_value =
    c.code_value,
    temp_units->units[ucnt].display = c.display, temp_units->units[ucnt].meaning = c.cdf_meaning,
    temp_units->units[ucnt].desc = c.description
   ENDIF
  WITH nocounter
 ;end select
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 IF (ucnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ucnt)),
    location_group lg,
    location l,
    code_value c,
    location_group lg2,
    location l2,
    code_value c2
   PLAN (d)
    JOIN (lg
    WHERE (lg.child_loc_cd=temp_units->units[d.seq].code_value)
     AND lg.root_loc_cd=0
     AND lg.location_group_type_cd=building_code
     AND lg.active_ind=1)
    JOIN (l
    WHERE l.location_cd=lg.parent_loc_cd
     AND l.active_ind=1)
    JOIN (c
    WHERE c.code_value=l.location_cd
     AND c.active_ind=1)
    JOIN (lg2
    WHERE lg2.child_loc_cd=lg.parent_loc_cd
     AND lg2.active_ind=1
     AND lg2.location_group_type_cd=facility_code
     AND lg2.root_loc_cd=0)
    JOIN (l2
    WHERE l2.location_cd=lg2.parent_loc_cd
     AND l2.active_ind=1)
    JOIN (c2
    WHERE c2.code_value=l2.location_cd
     AND c2.active_ind=1)
   ORDER BY c2.code_value, c.code_value, lg.child_loc_cd
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->facilities,100)
   HEAD c2.code_value
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->facilities,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->facilities[tcnt].facility_code_value = c2.code_value, reply->facilities[tcnt].
    facility_display = c2.display, reply->facilities[tcnt].facility_type_meaning = c2.cdf_meaning,
    reply->facilities[tcnt].organization_id = l2.organization_id, reply->facilities[tcnt].
    facility_desc = c2.description, bcnt = 0,
    btcnt = 0, stat = alterlist(reply->facilities[tcnt].buildings,10)
   HEAD c.code_value
    bcnt = (bcnt+ 1), btcnt = (btcnt+ 1)
    IF (bcnt > 10)
     stat = alterlist(reply->facilities[tcnt].buildings,(btcnt+ 10)), bcnt = 1
    ENDIF
    reply->facilities[tcnt].buildings[btcnt].building_code_value = c.code_value, reply->facilities[
    tcnt].buildings[btcnt].building_display = c.display, reply->facilities[tcnt].buildings[btcnt].
    building_type_meaning = c.cdf_meaning,
    reply->facilities[tcnt].buildings[btcnt].building_desc = c.description, unit_cnt = 0, unit_tcnt
     = 0,
    stat = alterlist(reply->facilities[tcnt].buildings[btcnt].units,10)
   HEAD lg.child_loc_cd
    unit_cnt = (unit_cnt+ 1), unit_tcnt = (unit_tcnt+ 1)
    IF (unit_cnt > 10)
     stat = alterlist(reply->facilities[tcnt].buildings[btcnt].units,(unit_tcnt+ 10)), unit_cnt = 1
    ENDIF
    reply->facilities[tcnt].buildings[btcnt].units[unit_tcnt].unit_code_value = lg.child_loc_cd,
    reply->facilities[tcnt].buildings[btcnt].units[unit_tcnt].unit_display = temp_units->units[d.seq]
    .display, reply->facilities[tcnt].buildings[btcnt].units[unit_tcnt].unit_type_meaning =
    temp_units->units[d.seq].meaning,
    reply->facilities[tcnt].buildings[btcnt].units[unit_tcnt].unit_desc = temp_units->units[d.seq].
    desc
   FOOT  c.code_value
    stat = alterlist(reply->facilities[tcnt].buildings[btcnt].units,unit_tcnt)
   FOOT  c2.code_value
    stat = alterlist(reply->facilities[tcnt].buildings,btcnt)
   FOOT REPORT
    stat = alterlist(reply->facilities,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL bederrorcheck("Failure in getting buildings")
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 IF (fcnt > 0)
  FOR (x = 1 TO fcnt)
    SET pos = 0
    IF (tcnt > 0)
     SET num = 0
     SET pos = locateval(num,1,tcnt,temp_facs->facs[x].code_value,reply->facilities[num].
      facility_code_value)
    ENDIF
    IF (pos > 0)
     SET reply->facilities[pos].erx_reltn_ind = 1
    ELSE
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->facilities,tcnt)
     SET reply->facilities[tcnt].facility_code_value = temp_facs->facs[x].code_value
     SET reply->facilities[tcnt].facility_type_meaning = temp_facs->facs[x].meaning
     SET reply->facilities[tcnt].facility_display = temp_facs->facs[x].display
     SET reply->facilities[tcnt].erx_reltn_ind = 1
     SET reply->facilities[tcnt].organization_id = temp_facs->facs[x].org_id
     SET reply->facilities[tcnt].facility_desc = temp_facs->facs[x].desc
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE iserxlocationexceedmaxcount(dummyvar)
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   SELECT
    total_cnt = count(DISTINCT c.code_value)
    FROM eprescribe_detail e,
     prsnl_reltn p,
     location l,
     organization org,
     code_value c
    PLAN (e
     WHERE parser(status_cd_parse))
     JOIN (p
     WHERE p.prsnl_reltn_id=e.prsnl_reltn_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND p.parent_entity_name="LOCATION")
     JOIN (l
     WHERE l.location_cd=p.parent_entity_id
      AND l.active_ind=1)
     JOIN (org
     WHERE org.organization_id=l.organization_id
      AND org.logical_domain_id=logicaldomainid)
     JOIN (c
     WHERE c.code_value=l.location_cd
      AND parser(loc_parse)
      AND  EXISTS (
     (SELECT
      1
      FROM code_value c2
      WHERE c2.cdf_meaning IN ("FACILITY", "AMBULATORY", "NURSEUNIT")
       AND c2.code_value=l.location_type_cd)))
    DETAIL
     rowcnt = total_cnt
    WITH maxrec = value((max_count+ 1))
   ;end select
   CALL bederrorcheck("Error 001: Error retrieving erx location count")
   IF (rowcnt > max_count)
    SET reply->too_many_results_ind = 1
    SET stat = alterlist(reply->facilities,0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
