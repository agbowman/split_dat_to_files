CREATE PROGRAM bed_aud_erx_reltns_report:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 from_date = dq8
    1 to_date = dq8
    1 facilities[*]
      2 facility_code_value = f8
    1 units[*]
      2 unit_code_value = f8
    1 service_levels[*]
      2 service_level = i4
    1 prov_statuses[*]
      2 provider_status = f8
    1 show_deactive_providers_ind = i2
  )
 ENDIF
 FREE RECORD reply
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 FREE RECORD temp_rep
 RECORD temp_rep(
   1 locations[*]
     2 facility_id = f8
     2 facility_description = vc
     2 unit_description = vc
     2 unit_id = f8
     2 location_id = f8
     2 prsnl[*]
       3 prsnl_id = f8
       3 name_full_formatted = vc
       3 erx_reltns[*]
         4 submission_dt_tm = dq8
         4 prsnl_reltn_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 display_seq = i4
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 service_level_mask = i4
         4 status_code_value = f8
         4 error_code_value = f8
         4 desc_error = vc
         4 child_reltns[*]
           5 prsnl_reltn_child_id = f8
           5 parent_entity_name = vc
           5 parent_entity_id = f8
           5 display_seq = i4
   1 max_phone_cnt = i4
 )
 FREE SET temp_locations
 RECORD temp_locations(
   1 locations[*]
     2 location_cd = f8
     2 facility_id = f8
     2 facility_description = vc
     2 unit_description = vc
     2 unit_id = f8
 )
 FREE RECORD tprsnl_alias
 RECORD tprsnl_alias(
   1 prsnl_aliases[*]
     2 prsnl_alias_id = f8
     2 alias_type_cd = vc
     2 alias = vc
 )
 FREE RECORD taddress
 RECORD taddress(
   1 addresses[*]
     2 address_id = f8
     2 address_type_display = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
 )
 FREE RECORD tphone
 RECORD tphone(
   1 phones[*]
     2 phone_id = f8
     2 phone_type_display = vc
     2 phone_formatted = vc
 )
 DECLARE determinewhatsltoshow(dummyvar=i2) = i2
 DECLARE cs3401_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,"ERROR"))
 DECLARE cs3401_in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,"IN ERROR"))
 DECLARE cs3401_error_retry_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,
   "ERROR RETRY"))
 DECLARE ucern_wiki_ref_prefix = vc WITH protect, constant(
  "https://wiki.ucern.com/display/public/reference/")
 DECLARE post_go_live_erx_space = vc WITH protect, constant(concat(ucern_wiki_ref_prefix,
   "Post+Go-Live+ePrescribe+Management#"))
 DECLARE common_erx_errors_suffix = vc WITH protect, constant(
  "PostGo-LiveePrescribeManagement-ErrorsReceivedUsingtheBedrockProviderRegistrationWizard")
 DECLARE common_erx_errors_url = vc WITH protect, constant(concat(post_go_live_erx_space,
   common_erx_errors_suffix))
 DECLARE address_cnt = i4 WITH protect
 DECLARE prsnl_alias_cnt = i4 WITH protect
 DECLARE phone_cnt = i4 WITH protect
 DECLARE total_reltns_cnt = i4 WITH protect
 DECLARE loc_cnt = i4 WITH protect
 DECLARE tot_sort_cnt = i4 WITH protect
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE beg_date = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE end_date = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE facility_code = f8 WITH protect
 DECLARE building_code = f8 WITH protect
 DECLARE auth_cd = f8 WITH protect
 DECLARE active_code = f8 WITH protect
 DECLARE prsnl_code = f8 WITH protect
 DECLARE npi_code = f8 WITH protect
 DECLARE reltn_type_code_value = f8 WITH protect
 DECLARE deactive_prov_flag = i2 WITH protect
 DECLARE deactive_prov_parser1 = vc WITH protect
 DECLARE deactive_prov_parser2 = vc WITH protect
 IF ((request->from_date > 0))
  SET beg_date = cnvtdatetime(request->from_date)
 ENDIF
 IF ((request->to_date > 0))
  SET end_date = cnvtdatetime(request->to_date)
 ENDIF
 SET deactive_prov_flag = request->show_deactive_providers_ind
 IF (deactive_prov_flag=1)
  SET deactive_prov_parser1 =
  "(p.active_ind = 0 or e.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))"
 ELSE
  SET deactive_prov_parser1 =
  "(p.active_ind = 1 and p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))"
 ENDIF
 CALL logdebugmessage("deactive_prov_parser1 :",deactive_prov_parser1)
 DECLARE req_fac_size = i4 WITH protect
 SET req_fac_size = size(request->facilities,5)
 FOR (x = 1 TO req_fac_size)
   SET loc_cnt = (loc_cnt+ 1)
   SET stat = alterlist(temp_locations->locations,loc_cnt)
   SET temp_locations->locations[loc_cnt].location_cd = request->facilities[x].facility_code_value
   SET temp_locations->locations[loc_cnt].facility_id = request->facilities[x].facility_code_value
 ENDFOR
 DECLARE req_unit_size = i4 WITH protect
 SET req_unit_size = size(request->units,5)
 FOR (x = 1 TO req_unit_size)
   SET loc_cnt = (loc_cnt+ 1)
   SET stat = alterlist(temp_locations->locations,loc_cnt)
   SET temp_locations->locations[loc_cnt].location_cd = request->units[x].unit_code_value
   SET temp_locations->locations[loc_cnt].unit_id = request->units[x].unit_code_value
 ENDFOR
 IF (loc_cnt=0)
  SELECT INTO "nl:"
   FROM eprescribe_detail e,
    prsnl_reltn p,
    location l,
    code_value c,
    code_value c2,
    organization o
   PLAN (e
    WHERE ((e.submit_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request->to_date
     )) OR ((request->from_date=0)
     AND (request->to_date=0))) )
    JOIN (p
    WHERE parser(deactive_prov_parser1)
     AND p.prsnl_reltn_id=e.prsnl_reltn_id
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.parent_entity_name="LOCATION")
    JOIN (l
    WHERE l.location_cd=p.parent_entity_id
     AND l.active_ind=1)
    JOIN (c
    WHERE c.code_value=l.location_cd
     AND c.active_ind=1)
    JOIN (c2
    WHERE c2.code_value=l.location_type_cd
     AND c2.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND o.logical_domain_id=log_domain_id)
   ORDER BY c.code_value
   HEAD REPORT
    loc_cnt = 0
   HEAD c.code_value
    loc_cnt = (loc_cnt+ 1), stat = alterlist(temp_locations->locations,loc_cnt), temp_locations->
    locations[loc_cnt].location_cd = c.code_value
    IF (c2.cdf_meaning="FACILITY")
     temp_locations->locations[loc_cnt].facility_id = c.code_value, temp_locations->locations[loc_cnt
     ].facility_description = c.description
    ELSEIF (c2.cdf_meaning IN ("AMBULATORY", "NURSEUNIT"))
     temp_locations->locations[loc_cnt].unit_id = c.code_value, temp_locations->locations[loc_cnt].
     unit_description = c.description
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL bederrorcheck("Error getting locs")
 IF (loc_cnt=0)
  GO TO exit_script
 ENDIF
 SET facility_code = uar_get_code_by("MEANING",222,"FACILITY")
 SET building_code = uar_get_code_by("MEANING",222,"BUILDING")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loc_cnt)),
   location_group lg,
   location l,
   location_group lg2,
   location l2,
   code_value c
  PLAN (d
   WHERE (temp_locations->locations[d.seq].unit_id > 0))
   JOIN (lg
   WHERE (lg.child_loc_cd=temp_locations->locations[d.seq].unit_id)
    AND lg.root_loc_cd=0
    AND lg.location_group_type_cd=building_code
    AND lg.active_ind=1)
   JOIN (l
   WHERE l.location_cd=lg.parent_loc_cd
    AND l.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.location_group_type_cd=facility_code
    AND lg2.root_loc_cd=0)
   JOIN (l2
   WHERE l2.location_cd=lg2.parent_loc_cd
    AND l2.active_ind=1)
   JOIN (c
   WHERE c.code_value=l2.location_cd
    AND c.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp_locations->locations[d.seq].facility_id = c.code_value, temp_locations->locations[d.seq].
   facility_description = c.description
  WITH nocounter
 ;end select
 CALL bederrorcheck("Facility Error")
 SET tot_sort_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loc_cnt)),
   code_value c,
   code_value c2
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=temp_locations->locations[d.seq].facility_id))
   JOIN (c2
   WHERE (c2.code_value=temp_locations->locations[d.seq].unit_id))
  ORDER BY cnvtupper(c.description), cnvtupper(c2.description)
  HEAD REPORT
   stat = alterlist(temp_rep->locations,10), sort_cnt = 0, tot_sort_cnt = 0
  DETAIL
   sort_cnt = (sort_cnt+ 1), tot_sort_cnt = (tot_sort_cnt+ 1)
   IF (sort_cnt > 10)
    stat = alterlist(temp_rep->locations,(tot_sort_cnt+ 10)), sort_cnt = 1
   ENDIF
   temp_rep->locations[tot_sort_cnt].facility_id = temp_locations->locations[d.seq].facility_id,
   temp_rep->locations[tot_sort_cnt].facility_description = c.description, temp_rep->locations[
   tot_sort_cnt].unit_id = temp_locations->locations[d.seq].unit_id,
   temp_rep->locations[tot_sort_cnt].unit_description = c2.description, temp_rep->locations[
   tot_sort_cnt].location_id = temp_locations->locations[d.seq].location_cd
  FOOT REPORT
   stat = alterlist(temp_rep->locations,tot_sort_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Loc Display Error")
 DECLARE pparse = vc
 SET pparse = " p.person_id > 0 "
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET prsnl_code = uar_get_code_by("MEANING",213,"PRSNL")
 SET npi_code = uar_get_code_by("MEANING",320,"NPI")
 SET reltn_type_code_value = uar_get_code_by("MEANING",30300,"EPRESCRELTN")
 SET pparse = concat(pparse," and p.active_ind = 1 ",
  " and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
  "  and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ")
 SET pparse = build(pparse," and p.data_status_cd  = ",auth_cd,"  and p.logical_domain_id = ",
  log_domain_id)
 CALL echo(pparse)
 DECLARE service_lvl_size = i4 WITH protect
 DECLARE provider_statuses_size = i4 WITH protect
 SET service_lvl_size = size(request->service_levels,5)
 SET provider_statuses_size = size(request->prov_statuses,5)
 IF (deactive_prov_flag=1)
  SET deactive_prov_parser2 =
  "(pr.active_ind = 0 or e.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))"
 ELSE
  SET deactive_prov_parser2 =
  "(pr.active_ind = 1 and pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))"
 ENDIF
 CALL logdebugmessage("deactive_prov_parser2 : ",deactive_prov_parser2)
 DECLARE ctcnt = i4 WITH protect
 DECLARE ccnt = i4 WITH protect
 SET address_cnt = 0
 SET prsnl_alias_cnt = 0
 SET phone_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_sort_cnt)),
   prsnl_reltn pr,
   prsnl_reltn_child c,
   eprescribe_detail e,
   prsnl p,
   person_name pn,
   code_value cv
  PLAN (d)
   JOIN (pr
   WHERE (pr.parent_entity_id=temp_rep->locations[d.seq].location_id)
    AND pr.parent_entity_name="LOCATION"
    AND pr.reltn_type_cd=reltn_type_code_value
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE parser(deactive_prov_parser2)
    AND e.prsnl_reltn_id=pr.prsnl_reltn_id
    AND ((e.submit_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request->to_date))
    OR ((request->from_date=0)
    AND (request->to_date=0))) )
   JOIN (c
   WHERE c.prsnl_reltn_id=pr.prsnl_reltn_id
    AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND parser(pparse))
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1
    AND pn.name_type_cd=prsnl_code
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_set=3401
    AND ((e.status_cd=cv.code_value) OR (e.status_cd=0.0
    AND cv.cki="CKI.CODEVALUE!2500015253")) )
  ORDER BY d.seq, pn.name_full, p.person_id,
   pr.prsnl_reltn_id, c.prsnl_reltn_child_id, c.display_seq
  HEAD REPORT
   max_phone_total_cnt = 0
  HEAD d.seq
   listcnt = 0, pcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl,10)
  HEAD p.person_id
   pcnt = (pcnt+ 1), listcnt = (listcnt+ 1)
   IF (listcnt > 10)
    listcnt = 1, stat = alterlist(temp_rep->locations[d.seq].prsnl,(pcnt+ 10))
   ENDIF
   temp_rep->locations[d.seq].prsnl[pcnt].prsnl_id = p.person_id, temp_rep->locations[d.seq].prsnl[
   pcnt].name_full_formatted = pn.name_full, rcnt = 0,
   rtcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,10)
  HEAD pr.prsnl_reltn_id
   pass_service_lvl = 0
   IF (service_lvl_size=0)
    pass_service_lvl = 1
   ELSE
    FOR (x = 1 TO size(request->service_levels,5))
      IF (band(e.service_level_nbr,request->service_levels[x].service_level) > 0)
       pass_service_lvl = 1
      ENDIF
    ENDFOR
   ENDIF
   pass_provider_status = 0
   IF (provider_statuses_size=0)
    pass_provider_status = 1
   ELSE
    FOR (x = 1 TO size(request->prov_statuses,5))
     prov_status_inst = request->prov_statuses[x].provider_status,
     IF (((e.status_cd=prov_status_inst) OR (e.status_cd=0
      AND prov_status_inst=cv.code_value)) )
      pass_provider_status = 1
     ENDIF
    ENDFOR
   ENDIF
   IF (pass_service_lvl=1
    AND pass_provider_status=1)
    total_reltns_cnt = (total_reltns_cnt+ 1), total_phones_per_reltn = 0, rcnt = (rcnt+ 1),
    rtcnt = (rtcnt+ 1)
    IF (rcnt > 10)
     stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,(rtcnt+ 10)), rcnt = 1
    ENDIF
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].prsnl_reltn_id = pr.prsnl_reltn_id,
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].display_seq = pr.display_seq, temp_rep->
    locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].submission_dt_tm = e.submit_dt_tm,
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].parent_entity_id = pr.parent_entity_id,
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].parent_entity_name = pr
    .parent_entity_name, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].service_level_mask
     =
    IF (e.service_level_nbr > 0) e.service_level_nbr
    ELSE e.prop_service_level_nbr
    ENDIF
    ,
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].beg_effective_dt_tm = e
    .beg_effective_dt_tm, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].
    end_effective_dt_tm = e.end_effective_dt_tm, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[
    rtcnt].status_code_value = e.status_cd,
    temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].error_code_value = e.error_cd, temp_rep
    ->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].desc_error = e.error_desc, ccnt = 0,
    ctcnt = 0, stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,
     10)
   ENDIF
  HEAD c.prsnl_reltn_child_id
   IF (pass_service_lvl=1
    AND pass_provider_status=1)
    IF (((pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pr.end_effective_dt_tm <=
    cnvtdatetime(curdate,curtime3)
     AND pr.end_effective_dt_tm=c.end_effective_dt_tm)) )
     ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
     IF (ccnt > 10)
      stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,(ctcnt+
       10)), ccnt = 1
     ENDIF
     temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].display_seq = c
     .display_seq, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].
     parent_entity_id = c.parent_entity_id, temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].
     child_reltns[ctcnt].parent_entity_name = c.parent_entity_name,
     temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns[ctcnt].
     prsnl_reltn_child_id = c.prsnl_reltn_child_id
     IF (c.parent_entity_name="PRSNL_ALIAS")
      prsnl_alias_cnt = (prsnl_alias_cnt+ 1), stat = alterlist(tprsnl_alias->prsnl_aliases,
       prsnl_alias_cnt), tprsnl_alias->prsnl_aliases[prsnl_alias_cnt].prsnl_alias_id = c
      .parent_entity_id
     ELSEIF (c.parent_entity_name="ADDRESS")
      address_cnt = (address_cnt+ 1), stat = alterlist(taddress->addresses,address_cnt), taddress->
      addresses[address_cnt].address_id = c.parent_entity_id
     ELSEIF (c.parent_entity_name="PHONE")
      phone_cnt = (phone_cnt+ 1), stat = alterlist(tphone->phones,phone_cnt), tphone->phones[
      phone_cnt].phone_id = c.parent_entity_id,
      total_phones_per_reltn = (total_phones_per_reltn+ 1)
     ENDIF
    ENDIF
   ENDIF
  FOOT  pr.prsnl_reltn_id
   stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns[rtcnt].child_reltns,ctcnt)
   IF (total_phones_per_reltn > max_phone_total_cnt)
    max_phone_total_cnt = total_phones_per_reltn
   ENDIF
  FOOT  p.person_id
   stat = alterlist(temp_rep->locations[d.seq].prsnl[pcnt].erx_reltns,rtcnt)
  FOOT  d.seq
   stat = alterlist(temp_rep->locations[d.seq].prsnl,pcnt)
  FOOT REPORT
   temp_rep->max_phone_cnt = max_phone_total_cnt
  WITH nocounter
 ;end select
 CALL bederrorcheck("Reltns Error")
 IF ((request->skip_volume_check_ind=0))
  CALL echo(total_reltns_cnt)
  IF (total_reltns_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (total_reltns_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE col_cnt_wo_phones = i4 WITH protect, noconstant(24)
 DECLARE phone_col_cnt = i4 WITH private, noconstant(0)
 DECLARE col_cnt = i4 WITH private, noconstant(0)
 DECLARE isepaon = i2 WITH protect, noconstant(0)
 DECLARE ismuse3on = i2 WITH protect, noconstant(0)
 DECLARE isltcon = i2 WITH protect, noconstant(0)
 CALL determinewhatsltoshow(0)
 IF (isepaon=1)
  SET col_cnt_wo_phones = (col_cnt_wo_phones+ 2)
 ENDIF
 IF (ismuse3on=1)
  SET col_cnt_wo_phones = (col_cnt_wo_phones+ 3)
 ENDIF
 IF (isltcon=1)
  SET col_cnt_wo_phones = (col_cnt_wo_phones+ 1)
 ENDIF
 SET phone_col_cnt = (temp_rep->max_phone_cnt * 2)
 SET col_cnt = (col_cnt_wo_phones+ phone_col_cnt)
 DECLARE facility_column = i2 WITH protect, constant(1)
 DECLARE location_column = i2 WITH protect, constant(2)
 DECLARE provider_column = i2 WITH protect, constant(3)
 DECLARE status_column = i2 WITH protect, constant(4)
 DECLARE error_msg_column = i2 WITH protect, constant(5)
 DECLARE error_help_column = i2 WITH protect, constant(6)
 DECLARE submit_date_column = i2 WITH protect, constant(7)
 DECLARE spi_alias_column = i2 WITH protect, constant(8)
 DECLARE npi_alias_column = i2 WITH protect, constant(9)
 DECLARE docdea_alias_column = i2 WITH protect, constant(10)
 DECLARE docupin_alias_column = i2 WITH protect, constant(11)
 DECLARE gdp_alias_column = i2 WITH protect, constant(12)
 DECLARE licensenbr_alias_column = i2 WITH protect, constant(13)
 DECLARE medicaid_alias_column = i2 WITH protect, constant(14)
 DECLARE new_rx_sl_column = i2 WITH protect, constant(15)
 DECLARE refill_sl_column = i2 WITH protect, constant(16)
 DECLARE cntr_subs_sl_column = i2 WITH protect, constant(17)
 DECLARE cancel_sl_column = i2 WITH protect, noconstant(18)
 DECLARE rxrefill_sl_column = i2 WITH protect, noconstant(19)
 DECLARE change_sl_column = i2 WITH protect, noconstant(20)
 DECLARE epa_prospective_sl_column = i2 WITH protect, noconstant(21)
 DECLARE epa_retrospective_sl_column = i2 WITH protect, noconstant(22)
 DECLARE long_term_care_sl_column = i2 WITH protect, noconstant(23)
 DECLARE end_date_column = i2 WITH protect, noconstant(24)
 DECLARE addr_type_column = i2 WITH protect, noconstant(25)
 DECLARE addr_line1_column = i2 WITH protect, noconstant(26)
 DECLARE addr_line2_column = i2 WITH protect, noconstant(27)
 DECLARE addr_city_column = i2 WITH protect, noconstant(28)
 DECLARE addr_state_column = i2 WITH protect, noconstant(29)
 DECLARE addr_zip_column = i2 WITH protect, noconstant(30)
 IF (isepaon=0
  AND ismuse3on=0
  AND isltcon=0)
  SET end_date_column = 18
  SET addr_type_column = 19
  SET addr_line1_column = 20
  SET addr_line2_column = 21
  SET addr_city_column = 22
  SET addr_state_column = 23
  SET addr_zip_column = 24
 ELSEIF (isepaon=1
  AND ismuse3on=1
  AND isltcon=0)
  SET end_date_column = 23
  SET addr_type_column = 24
  SET addr_line1_column = 25
  SET addr_line2_column = 26
  SET addr_city_column = 27
  SET addr_state_column = 28
  SET addr_zip_column = 29
 ELSEIF (isepaon=1
  AND ismuse3on=0
  AND isltcon=1)
  SET epa_prospective_sl_column = 18
  SET epa_retrospective_sl_column = 19
  SET long_term_care_sl_column = 20
  SET end_date_column = 21
  SET addr_type_column = 22
  SET addr_line1_column = 23
  SET addr_line2_column = 24
  SET addr_city_column = 25
  SET addr_state_column = 26
  SET addr_zip_column = 27
 ELSEIF (isepaon=0
  AND ismuse3on=1
  AND isltcon=1)
  SET long_term_care_sl_column = 21
  SET end_date_column = 22
  SET addr_type_column = 23
  SET addr_line1_column = 24
  SET addr_line2_column = 25
  SET addr_city_column = 26
  SET addr_state_column = 27
  SET addr_zip_column = 28
 ELSEIF (isepaon=1
  AND ismuse3on=0
  AND isltcon=0)
  SET epa_prospective_sl_column = 18
  SET epa_retrospective_sl_column = 19
  SET end_date_column = 20
  SET addr_type_column = 21
  SET addr_line1_column = 22
  SET addr_line2_column = 23
  SET addr_city_column = 24
  SET addr_state_column = 25
  SET addr_zip_column = 26
 ELSEIF (isepaon=0
  AND ismuse3on=0
  AND isltcon=1)
  SET long_term_care_sl_column = 18
  SET end_date_column = 19
  SET addr_type_column = 20
  SET addr_line1_column = 21
  SET addr_line2_column = 22
  SET addr_city_column = 23
  SET addr_state_column = 24
  SET addr_zip_column = 25
 ELSEIF (isepaon=0
  AND ismuse3on=1
  AND isltcon=0)
  SET end_date_column = 21
  SET addr_type_column = 22
  SET addr_line1_column = 23
  SET addr_line2_column = 24
  SET addr_city_column = 25
  SET addr_state_column = 26
  SET addr_zip_column = 27
 ENDIF
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[facility_column].header_text = "Facility"
 SET reply->collist[facility_column].data_type = 1
 SET reply->collist[facility_column].hide_ind = 0
 SET reply->collist[location_column].header_text = "Location"
 SET reply->collist[location_column].data_type = 1
 SET reply->collist[location_column].hide_ind = 0
 SET reply->collist[provider_column].header_text = "Provider"
 SET reply->collist[provider_column].data_type = 1
 SET reply->collist[provider_column].hide_ind = 0
 SET reply->collist[status_column].header_text = "Status"
 SET reply->collist[status_column].data_type = 1
 SET reply->collist[status_column].hide_ind = 0
 SET reply->collist[error_msg_column].header_text = "Error Message"
 SET reply->collist[error_msg_column].data_type = 1
 SET reply->collist[error_msg_column].hide_ind = 0
 SET reply->collist[error_help_column].header_text = "Error Help"
 SET reply->collist[error_help_column].data_type = 5
 SET reply->collist[error_help_column].hide_ind = 0
 SET reply->collist[submit_date_column].header_text = "Submission Date"
 SET reply->collist[submit_date_column].data_type = 4
 SET reply->collist[submit_date_column].hide_ind = 0
 SET reply->collist[spi_alias_column].header_text = "SPI Alias"
 SET reply->collist[spi_alias_column].data_type = 1
 SET reply->collist[spi_alias_column].hide_ind = 0
 SET reply->collist[npi_alias_column].header_text = "NPI Alias"
 SET reply->collist[npi_alias_column].data_type = 1
 SET reply->collist[npi_alias_column].hide_ind = 0
 SET reply->collist[docdea_alias_column].header_text = "DOCDEA Alias"
 SET reply->collist[docdea_alias_column].data_type = 1
 SET reply->collist[docdea_alias_column].hide_ind = 0
 SET reply->collist[docupin_alias_column].header_text = "DOCUPIN Alias"
 SET reply->collist[docupin_alias_column].data_type = 1
 SET reply->collist[docupin_alias_column].hide_ind = 0
 SET reply->collist[gdp_alias_column].header_text = "GDP Alias"
 SET reply->collist[gdp_alias_column].data_type = 1
 SET reply->collist[gdp_alias_column].hide_ind = 0
 SET reply->collist[licensenbr_alias_column].header_text = "LICENSENBR Alias"
 SET reply->collist[licensenbr_alias_column].data_type = 1
 SET reply->collist[licensenbr_alias_column].hide_ind = 0
 SET reply->collist[medicaid_alias_column].header_text = "Medicaid Alias"
 SET reply->collist[medicaid_alias_column].data_type = 1
 SET reply->collist[medicaid_alias_column].hide_ind = 0
 SET reply->collist[new_rx_sl_column].header_text = "New RX Service Level"
 SET reply->collist[new_rx_sl_column].data_type = 1
 SET reply->collist[new_rx_sl_column].hide_ind = 0
 SET reply->collist[refill_sl_column].header_text = "Refill/Renew Service Level"
 SET reply->collist[refill_sl_column].data_type = 1
 SET reply->collist[refill_sl_column].hide_ind = 0
 SET reply->collist[cntr_subs_sl_column].header_text = "Controlled Substances Service Level"
 SET reply->collist[cntr_subs_sl_column].data_type = 1
 SET reply->collist[cntr_subs_sl_column].hide_ind = 0
 IF (isepaon=1)
  SET reply->collist[epa_prospective_sl_column].header_text = "EPA-Prospective Service Level"
  SET reply->collist[epa_prospective_sl_column].data_type = 1
  SET reply->collist[epa_prospective_sl_column].hide_ind = 0
  SET reply->collist[epa_retrospective_sl_column].header_text = "EPA-Retrospective Service Level"
  SET reply->collist[epa_retrospective_sl_column].data_type = 1
  SET reply->collist[epa_retrospective_sl_column].hide_ind = 0
 ENDIF
 IF (ismuse3on=1)
  SET reply->collist[cancel_sl_column].header_text = "Cancel Service Level"
  SET reply->collist[cancel_sl_column].data_type = 1
  SET reply->collist[cancel_sl_column].hide_ind = 0
  SET reply->collist[rxrefill_sl_column].header_text = "RxFill Service Level"
  SET reply->collist[rxrefill_sl_column].data_type = 1
  SET reply->collist[rxrefill_sl_column].hide_ind = 0
  SET reply->collist[change_sl_column].header_text = "Change Service Level"
  SET reply->collist[change_sl_column].data_type = 1
  SET reply->collist[change_sl_column].hide_ind = 0
 ENDIF
 IF (isltcon=1)
  SET reply->collist[long_term_care_sl_column].header_text = "Long Term Care Service Level"
  SET reply->collist[long_term_care_sl_column].data_type = 1
  SET reply->collist[long_term_care_sl_column].hide_ind = 0
 ENDIF
 SET reply->collist[end_date_column].header_text = "End Effective Date"
 SET reply->collist[end_date_column].data_type = 4
 SET reply->collist[end_date_column].hide_ind = 0
 SET reply->collist[addr_type_column].header_text = "Address Type"
 SET reply->collist[addr_type_column].data_type = 1
 SET reply->collist[addr_type_column].hide_ind = 0
 SET reply->collist[addr_line1_column].header_text = "Address Line 1"
 SET reply->collist[addr_line1_column].data_type = 1
 SET reply->collist[addr_line1_column].hide_ind = 0
 SET reply->collist[addr_line2_column].header_text = "Address Line 2"
 SET reply->collist[addr_line2_column].data_type = 1
 SET reply->collist[addr_line2_column].hide_ind = 0
 SET reply->collist[addr_city_column].header_text = "City"
 SET reply->collist[addr_city_column].data_type = 1
 SET reply->collist[addr_city_column].hide_ind = 0
 SET reply->collist[addr_state_column].header_text = "State"
 SET reply->collist[addr_state_column].data_type = 1
 SET reply->collist[addr_state_column].hide_ind = 0
 SET reply->collist[addr_zip_column].header_text = "Zip Code"
 SET reply->collist[addr_zip_column].data_type = 1
 SET reply->collist[addr_zip_column].hide_ind = 0
 DECLARE c = i4 WITH private
 DECLARE cur_phone_cnt = i4 WITH protect
 SET cur_phone_cnt = 0
 FOR (c = 1 TO phone_col_cnt)
   SET cur_phone_cnt = (cur_phone_cnt+ 1)
   SET reply->collist[(col_cnt_wo_phones+ c)].header_text = concat("Phone "," ",trim(cnvtstring(
      cur_phone_cnt))," Type")
   SET reply->collist[(col_cnt_wo_phones+ c)].data_type = 1
   SET reply->collist[(col_cnt_wo_phones+ c)].hide_ind = 0
   SET c = (c+ 1)
   SET reply->collist[(col_cnt_wo_phones+ c)].header_text = concat("Phone "," ",trim(cnvtstring(
      cur_phone_cnt))," Number")
   SET reply->collist[(col_cnt_wo_phones+ c)].data_type = 1
   SET reply->collist[(col_cnt_wo_phones+ c)].hide_ind = 0
 ENDFOR
 CALL load_child_reltn_info(1)
 DECLARE y = i4 WITH private
 DECLARE x = i4 WITH private
 DECLARE row_cnt = i4 WITH private
 DECLARE prsnl_size = i4 WITH private
 DECLARE reltn_size = i4 WITH private
 DECLARE status_cd = f8 WITH private
 FOR (x = 1 TO tot_sort_cnt)
  SET prsnl_size = size(temp_rep->locations[x].prsnl,5)
  FOR (y = 1 TO prsnl_size)
   SET reltn_size = size(temp_rep->locations[x].prsnl[y].erx_reltns,5)
   IF (reltn_size > 0)
    FOR (z = 1 TO reltn_size)
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
      SET reply->rowlist[row_cnt].celllist[facility_column].string_value = temp_rep->locations[x].
      facility_description
      SET reply->rowlist[row_cnt].celllist[location_column].string_value = temp_rep->locations[x].
      unit_description
      SET reply->rowlist[row_cnt].celllist[provider_column].string_value = temp_rep->locations[x].
      prsnl[y].name_full_formatted
      SET status_cd = temp_rep->locations[x].prsnl[y].erx_reltns[z].status_code_value
      IF (status_cd > 0)
       SET reply->rowlist[row_cnt].celllist[status_column].string_value = uar_get_code_display(
        status_cd)
      ELSE
       SET reply->rowlist[row_cnt].celllist[status_column].string_value = "In Progress"
      ENDIF
      SET reply->rowlist[row_cnt].celllist[error_msg_column].string_value = temp_rep->locations[x].
      prsnl[y].erx_reltns[z].desc_error
      IF (status_cd IN (cs3401_error_cd, cs3401_in_error_cd, cs3401_error_retry_cd))
       SET reply->rowlist[row_cnt].celllist[error_help_column].string_value = common_erx_errors_url
      ENDIF
      SET reply->rowlist[row_cnt].celllist[submit_date_column].date_value = cnvtdatetime(temp_rep->
       locations[x].prsnl[y].erx_reltns[z].submission_dt_tm)
      CALL add_children(x,y,z,row_cnt)
      CALL add_service_levels(x,y,z,row_cnt)
      SET reply->rowlist[row_cnt].celllist[end_date_column].date_value = cnvtdatetime(temp_rep->
       locations[x].prsnl[y].erx_reltns[z].end_effective_dt_tm)
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 CALL bederrorcheck("Error Building Reply")
 CALL echo(build("Row Cnt: ",row_cnt))
 SUBROUTINE add_children(loc_pos,prsnl_pos,erx_pos,row_cnt)
   DECLARE parent_entity_name = vc
   DECLARE phone_cnt_for_reltn = i4 WITH private
   DECLARE parent_entity_id = f8 WITH private
   DECLARE num = i4 WITH private
   DECLARE alias_index = i4 WITH private
   DECLARE address_index = i4 WITH private
   DECLARE phone_index = i4 WITH private
   SET phone_cnt_for_reltn = 0
   FOR (cr = 1 TO size(temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].child_reltns,
    5))
     SET parent_entity_id = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
     child_reltns[cr].parent_entity_id
     SET parent_entity_name = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
     child_reltns[cr].parent_entity_name
     IF (parent_entity_name="PRSNL_ALIAS")
      SET num = 0
      SET alias_index = locateval(num,1,prsnl_alias_cnt,parent_entity_id,tprsnl_alias->prsnl_aliases[
       num].prsnl_alias_id)
      IF (alias_index > 0)
       CALL set_prsnl_alias_rowlist(tprsnl_alias->prsnl_aliases[alias_index].alias_type_cd,
        tprsnl_alias->prsnl_aliases[alias_index].alias,row_cnt)
      ENDIF
     ELSEIF (parent_entity_name="ADDRESS")
      SET num = 0
      SET address_index = locateval(num,1,address_cnt,parent_entity_id,taddress->addresses[num].
       address_id)
      IF (address_index > 0)
       SET reply->rowlist[row_cnt].celllist[addr_type_column].string_value = taddress->addresses[
       address_index].address_type_display
       SET reply->rowlist[row_cnt].celllist[addr_line1_column].string_value = taddress->addresses[
       address_index].street_addr
       SET reply->rowlist[row_cnt].celllist[addr_line2_column].string_value = taddress->addresses[
       address_index].street_addr2
       SET reply->rowlist[row_cnt].celllist[addr_city_column].string_value = taddress->addresses[
       address_index].city
       SET reply->rowlist[row_cnt].celllist[addr_state_column].string_value = taddress->addresses[
       address_index].state
       SET reply->rowlist[row_cnt].celllist[addr_zip_column].string_value = taddress->addresses[
       address_index].zipcode
      ENDIF
     ELSEIF (parent_entity_name="PHONE")
      SET num = 0
      SET phone_index = locateval(num,1,phone_cnt,parent_entity_id,tphone->phones[num].phone_id)
      IF (phone_index > 0)
       SET phone_cnt_for_reltn = (phone_cnt_for_reltn+ 1)
       SET reply->rowlist[row_cnt].celllist[(col_cnt_wo_phones+ phone_cnt_for_reltn)].string_value =
       tphone->phones[phone_index].phone_type_display
       SET phone_cnt_for_reltn = (phone_cnt_for_reltn+ 1)
       SET reply->rowlist[row_cnt].celllist[(col_cnt_wo_phones+ phone_cnt_for_reltn)].string_value =
       tphone->phones[phone_index].phone_formatted
      ENDIF
     ENDIF
   ENDFOR
   CALL bederrorcheck("Child Error")
 END ;Subroutine
 SUBROUTINE set_prsnl_alias_rowlist(cdf_meaning,alias,row_cnt)
   IF (cdf_meaning="SPI")
    SET reply->rowlist[row_cnt].celllist[spi_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="NPI")
    SET reply->rowlist[row_cnt].celllist[npi_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="DOCDEA")
    SET reply->rowlist[row_cnt].celllist[docdea_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="DOCUPIN")
    SET reply->rowlist[row_cnt].celllist[docupin_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="GDP")
    SET reply->rowlist[row_cnt].celllist[gdp_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="LICENSENBR")
    SET reply->rowlist[row_cnt].celllist[licensenbr_alias_column].string_value = alias
   ENDIF
   IF (cdf_meaning="MEDICAID")
    SET reply->rowlist[row_cnt].celllist[medicaid_alias_column].string_value = alias
   ENDIF
 END ;Subroutine
 SUBROUTINE add_service_levels(loc_pos,prsnl_pos,erx_pos,row_cnt)
   DECLARE bit_mask = i4 WITH protect, noconstant(0)
   SET bit_mask = temp_rep->locations[loc_pos].prsnl[prsnl_pos].erx_reltns[erx_pos].
   service_level_mask
   IF (band(bit_mask,1) > 0)
    SET reply->rowlist[row_cnt].celllist[new_rx_sl_column].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[new_rx_sl_column].string_value = ""
   ENDIF
   IF (band(bit_mask,2) > 0)
    SET reply->rowlist[row_cnt].celllist[refill_sl_column].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[refill_sl_column].string_value = ""
   ENDIF
   IF (band(bit_mask,2048) > 0)
    SET reply->rowlist[row_cnt].celllist[cntr_subs_sl_column].string_value = "X"
   ELSE
    SET reply->rowlist[row_cnt].celllist[cntr_subs_sl_column].string_value = ""
   ENDIF
   IF (isltcon=1)
    IF (band(bit_mask,128) > 0)
     SET reply->rowlist[row_cnt].celllist[long_term_care_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[long_term_care_sl_column].string_value = ""
    ENDIF
   ENDIF
   IF (isepaon=1)
    IF (band(bit_mask,32768) > 0)
     SET reply->rowlist[row_cnt].celllist[epa_prospective_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[epa_prospective_sl_column].string_value = ""
    ENDIF
    IF (band(bit_mask,16384) > 0)
     SET reply->rowlist[row_cnt].celllist[epa_retrospective_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[epa_retrospective_sl_column].string_value = ""
    ENDIF
   ENDIF
   IF (ismuse3on=1)
    IF (band(bit_mask,16) > 0)
     SET reply->rowlist[row_cnt].celllist[cancel_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[cancel_sl_column].string_value = ""
    ENDIF
    IF (band(bit_mask,8) > 0)
     SET reply->rowlist[row_cnt].celllist[rxrefill_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[rxrefill_sl_column].string_value = ""
    ENDIF
    IF (band(bit_mask,4) > 0)
     SET reply->rowlist[row_cnt].celllist[change_sl_column].string_value = "X"
    ELSE
     SET reply->rowlist[row_cnt].celllist[change_sl_column].string_value = ""
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE load_child_reltn_info(i)
   IF (prsnl_alias_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prsnl_alias_cnt)),
      prsnl_alias p,
      code_value c
     PLAN (d)
      JOIN (p
      WHERE (p.prsnl_alias_id=tprsnl_alias->prsnl_aliases[d.seq].prsnl_alias_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=p.prsnl_alias_type_cd
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      tprsnl_alias->prsnl_aliases[d.seq].alias_type_cd = c.cdf_meaning, tprsnl_alias->prsnl_aliases[d
      .seq].alias = p.alias
     WITH nocounter
    ;end select
    CALL bederrorcheck("Prsnl Alias Error")
   ENDIF
   IF (address_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(address_cnt)),
      address a,
      code_value c,
      code_value c2,
      code_value c3
     PLAN (d)
      JOIN (a
      WHERE (a.address_id=taddress->addresses[d.seq].address_id)
       AND a.address_id > 0
       AND a.active_ind=1
       AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=a.address_type_cd
       AND c.active_ind=1)
      JOIN (c2
      WHERE c2.code_value=outerjoin(a.state_cd)
       AND c2.active_ind=outerjoin(1))
      JOIN (c3
      WHERE c3.code_value=outerjoin(a.city_cd)
       AND c3.active_ind=outerjoin(1))
     ORDER BY d.seq
     DETAIL
      taddress->addresses[d.seq].address_id = a.address_id, taddress->addresses[d.seq].
      address_type_display = c.display, taddress->addresses[d.seq].street_addr = a.street_addr,
      taddress->addresses[d.seq].street_addr2 = a.street_addr2, taddress->addresses[d.seq].city = a
      .city
      IF (c3.code_value > 0)
       taddress->addresses[d.seq].city = c3.display
      ENDIF
      taddress->addresses[d.seq].state = c2.display, taddress->addresses[d.seq].zipcode = a.zipcode
     WITH nocounter
    ;end select
    CALL bederrorcheck("Address Error")
   ENDIF
   IF (phone_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(phone_cnt)),
      phone p,
      code_value c
     PLAN (d)
      JOIN (p
      WHERE (p.phone_id=tphone->phones[d.seq].phone_id)
       AND p.phone_id > 0
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.code_value=p.phone_type_cd
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      tphone->phones[d.seq].phone_type_display = c.display, tphone->phones[d.seq].phone_formatted =
      cnvtphone(cnvtalphanum(p.phone_num),p.phone_format_cd)
      IF (p.extension > " ")
       tphone->phones[d.seq].phone_formatted = concat(tphone->phones[d.seq].phone_formatted," ext ",p
        .extension)
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Phone Error")
   ENDIF
 END ;Subroutine
 SUBROUTINE determinewhatsltoshow(dummyvar)
   FREE RECORD epservicesreply
   RECORD epservicesreply(
     1 services[*]
       2 name = vc
       2 value = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE bed_get_eprs_services  WITH replace("REPLY",epservicesreply)
   FOR (epsk = 1 TO size(epservicesreply->services,5))
     IF ((epservicesreply->services[epsk].name="EPA")
      AND (epservicesreply->services[epsk].value="1"))
      SET isepaon = 1
     ENDIF
     IF ((epservicesreply->services[epsk].name="MUSE3")
      AND (epservicesreply->services[epsk].value="1"))
      SET ismuse3on = 1
     ENDIF
     IF ((epservicesreply->services[epsk].name="LTC")
      AND (epservicesreply->services[epsk].value="1"))
      SET isltcon = 1
     ENDIF
   ENDFOR
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_erx_reltns.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
