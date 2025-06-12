CREATE PROGRAM bed_get_prsnl_by_email:dba
 IF ( NOT (validate(prsnl_list_b_request,0)))
  RECORD prsnl_list_b_request(
    1 physician_only_ind = i2
    1 position_list[*]
      2 position_cd = f8
    1 name_first = vc
    1 name_last = vc
    1 username = vc
    1 inc_inactive_ind = i2
    1 inc_unauth_ind = i2
    1 max_reply = i4
    1 submit_by = vc
    1 load
      2 get_bus_address_ind = i2
      2 get_bus_phone_ind = i2
      2 get_specialties_ind = i2
      2 get_org_cnt_ind = i2
      2 get_specialty_cnt_ind = i2
      2 get_org_ind = i2
    1 person_id = f8
    1 username_only_ind = i2
    1 organizations[*]
      2 id = f8
    1 organization_groups[*]
      2 id = f8
    1 load_orgs_and_groups_ind = i2
    1 external_ind = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl[*]
      2 prsnl_id = f8
      2 name_full_formatted = vc
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
 IF ( NOT (validate(prsnl_list_b_reply,0)))
  RECORD prsnl_list_b_reply(
    1 prsnl_list[*]
      2 person_id = f8
      2 org_cnt = i2
      2 org_ind = i2
      2 specialty_cnt = i2
      2 name_full_formatted = vc
      2 username = vc
      2 active_ind = i2
      2 auth_ind = i2
      2 slist[*]
        3 specialty_id = f8
        3 specialty_value = vc
        3 specialty_name = vc
      2 address_list[*]
        3 address_id = f8
        3 address_type_code_value = f8
        3 address_type_disp = vc
        3 address_type_mean = vc
        3 address_type_seq = i4
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city = vc
        3 state = vc
        3 state_code_value = f8
        3 state_disp = vc
        3 zipcode = vc
        3 country_code_value = f8
        3 country_disp = vc
        3 county_code_value = f8
        3 county_disp = vc
        3 contact_name = vc
        3 residence_type_code_value = f8
        3 residence_type_disp = vc
        3 residence_type_mean = vc
        3 comment_txt = vc
        3 active_ind = i2
      2 phone_list[*]
        3 phone_id = f8
        3 phone_type_code_value = f8
        3 phone_type_disp = vc
        3 phone_type_mean = vc
        3 phone_format_code_value = f8
        3 phone_format_disp = vc
        3 phone_format_mean = vc
        3 sequence = i4
        3 phone_num = vc
        3 phone_formatted = vc
        3 description = vc
        3 contact = vc
        3 call_instruction = vc
        3 extension = vc
        3 paging_code = vc
        3 operation_hours = vc
        3 active_ind = i2
      2 position_code_value = f8
      2 position_display = vc
      2 position_mean = vc
      2 organizations[*]
        3 id = f8
        3 name = vc
      2 organization_groups[*]
        3 id = f8
        3 name = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 external_ind = i2
    1 error_msg = vc
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
 IF ( NOT (validate(cs43_intsecemail_cd)))
  DECLARE cs43_intsecemail_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"INTSECEMAIL")
   )
 ENDIF
 IF ( NOT (validate(cs43_extsecemail_cd)))
  DECLARE cs43_extsecemail_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"EXTSECEMAIL")
   )
 ENDIF
 DECLARE position_list_size = i4 WITH protect, noconstant(0)
 DECLARE org_list_size = i4 WITH protect, noconstant(0)
 DECLARE org_group_list_size = i4 WITH protect, noconstant(0)
 DECLARE prsnl_list_size = i4 WITH protect, noconstant(0)
 DECLARE getpersonnelbyemail(dummyvar=i2) = null
 CALL getpersonnelbyemail(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getpersonnelbyemail(dummyvar)
   SET prsnl_list_b_request->name_first = request->first_name
   SET prsnl_list_b_request->name_last = request->last_name
   SET prsnl_list_b_request->username = request->username
   SET prsnl_list_b_request->inc_inactive_ind = request->inc_inactive_ind
   SET prsnl_list_b_request->physician_only_ind = request->physician_only_ind
   SET prsnl_list_b_request->username_only_ind = request->username_only_ind
   SET prsnl_list_b_request->max_reply = request->max_reply_limit
   FOR (x = 1 TO size(request->positions,5))
     SET position_list_size = (position_list_size+ 1)
     SET stat = alterlist(prsnl_list_b_request->position_list,position_list_size)
     SET prsnl_list_b_request->position_list[position_list_size].position_cd = request->positions[x].
     position_cd
   ENDFOR
   FOR (x = 1 TO size(request->organizations,5))
     SET org_list_size = (org_list_size+ 1)
     SET stat = alterlist(prsnl_list_b_request->organizations,org_list_size)
     SET prsnl_list_b_request->organizations[org_list_size].id = request->organizations[x].org_id
   ENDFOR
   FOR (x = 1 TO size(request->organization_groups,5))
     SET org_group_list_size = (org_group_list_size+ 1)
     SET stat = alterlist(prsnl_list_b_request->organization_groups,org_group_list_size)
     SET prsnl_list_b_request->organization_groups[org_group_list_size].id = request->
     organization_groups[x].org_group_id
   ENDFOR
   CALL bederrorcheck("Failed to populate request")
   EXECUTE bed_get_personnel_list_b  WITH replace("REQUEST",prsnl_list_b_request), replace("REPLY",
    prsnl_list_b_reply)
   IF ((prsnl_list_b_reply->status_data.status="F"))
    CALL bederror("bed_get_personnel_list_b failed")
   ENDIF
   IF ((prsnl_list_b_reply->too_many_results_ind=1))
    SET reply->too_many_results_ind = 1
   ELSE
    IF ((request->with_emails_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(prsnl_list_b_reply->prsnl_list,5)),
       prsnl p,
       phone ph
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=prsnl_list_b_reply->prsnl_list[d.seq].person_id))
       JOIN (ph
       WHERE ph.parent_entity_id=p.person_id
        AND ph.parent_entity_name="PERSON"
        AND ph.phone_type_cd IN (cs43_intsecemail_cd, cs43_extsecemail_cd))
      ORDER BY p.name_full_formatted
      HEAD REPORT
       prsnl_list_size = 0
      DETAIL
       prsnl_list_size = (prsnl_list_size+ 1), stat = alterlist(reply->prsnl,prsnl_list_size), reply
       ->prsnl[prsnl_list_size].prsnl_id = p.person_id,
       reply->prsnl[prsnl_list_size].name_full_formatted = p.name_full_formatted
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(prsnl_list_b_reply->prsnl_list,5)),
       prsnl p
      PLAN (d)
       JOIN (p
       WHERE (p.person_id=prsnl_list_b_reply->prsnl_list[d.seq].person_id)
        AND  NOT ( EXISTS (
       (SELECT
        ph.phone_id
        FROM phone ph
        WHERE ph.parent_entity_name="PERSON"
         AND ph.parent_entity_id=p.person_id
         AND ph.phone_type_cd IN (cs43_intsecemail_cd, cs43_extsecemail_cd)
         AND ph.active_ind=1))))
      ORDER BY p.name_full_formatted
      HEAD REPORT
       prsnl_list_size = 0
      DETAIL
       prsnl_list_size = (prsnl_list_size+ 1), stat = alterlist(reply->prsnl,prsnl_list_size), reply
       ->prsnl[prsnl_list_size].prsnl_id = p.person_id,
       reply->prsnl[prsnl_list_size].name_full_formatted = p.name_full_formatted
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
END GO
