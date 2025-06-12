CREATE PROGRAM bed_get_cpcs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 cpcs[*]
      2 br_cpc_id = f8
      2 br_cpc_name = vc
      2 br_cpc_site_id = vc
      2 br_cpc_tin = vc
      2 providers[*]
        3 provider_id = f8
        3 provider_name = vc
        3 tin = vc
        3 npi = vc
        3 active_ind = i2
        3 effective_ind = i2
      2 loc_defined_ind = i2
      2 locs[*]
        3 code_value = f8
        3 display = vc
        3 mean = vc
        3 active_ind = i2
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
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE remove_flag = i2 WITH protect, constant(3)
 DECLARE parent_entity_cpc = vc WITH protect, constant("BR_CPC")
 DECLARE getcpcs(dummyvar=i2) = null
 DECLARE getproviders(dummyvar=i2) = null
 DECLARE getlocations(dummyvar=i2) = null
 DECLARE getaddresses(dummyvar=i2) = null
 DECLARE getphones(dummyvar=i2) = null
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
 replace("REPLY",acm_get_curr_logical_domain_rep)
 CALL getcpcs(0)
 IF ((request->get_providers_ind=1))
  CALL getproviders(0)
 ENDIF
 IF ((request->get_loc_hier_ind=1))
  CALL getlocations(0)
 ENDIF
 IF ((request->get_address_ind=1))
  CALL getaddresses(0)
 ENDIF
 IF ((request->get_phone_ind=1))
  CALL getphones(0)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getcpcs(dummyvar)
   DECLARE replysize = i4 WITH protect, noconstant(0)
   IF (size(request->cpcs,5)=0)
    SELECT INTO "nl:"
     FROM br_cpc bc
     WHERE bc.br_cpc_id > 0.0
      AND bc.active_ind=1
      AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND (bc.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id)
     DETAIL
      replysize = (replysize+ 1), stat = alterlist(reply->cpcs,replysize), reply->cpcs[replysize].
      br_cpc_id = bc.br_cpc_id
      IF ((request->get_cpc_info_ind=1))
       reply->cpcs[replysize].br_cpc_name = bc.br_cpc_name, reply->cpcs[replysize].br_cpc_site_id =
       bc.cpc_site_id_txt, reply->cpcs[replysize].br_cpc_tin = bc.tax_id_nbr_txt
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERROR001: Error while getting CPCs")
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(request->cpcs,5))),
      br_cpc bc
     PLAN (d)
      JOIN (bc
      WHERE (bc.br_cpc_id=request->cpcs[d.seq].br_cpc_id)
       AND bc.br_cpc_id > 0.0
       AND bc.active_ind=1
       AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND (bc.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
     DETAIL
      replysize = (replysize+ 1), stat = alterlist(reply->cpcs,replysize), reply->cpcs[replysize].
      br_cpc_id = bc.br_cpc_id
      IF ((request->get_cpc_info_ind=1))
       reply->cpcs[replysize].br_cpc_name = bc.br_cpc_name, reply->cpcs[replysize].br_cpc_site_id =
       bc.cpc_site_id_txt, reply->cpcs[replysize].br_cpc_tin = bc.tax_id_nbr_txt
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERROR002: Error while getting CPCs")
   ENDIF
   FOR (x = 1 TO size(reply->cpcs,5))
     SELECT INTO "nl:"
      FROM br_cpc bc,
       br_cpc_loc_reltn bclr,
       code_value cv
      PLAN (bc
       WHERE (bc.br_cpc_id=reply->cpcs[x].br_cpc_id))
       JOIN (bclr
       WHERE bclr.br_cpc_id=bc.br_cpc_id
        AND bclr.active_ind=1
        AND bclr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       JOIN (cv
       WHERE cv.code_value=bclr.location_cd)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET reply->cpcs[x].loc_defined_ind = 1
     ENDIF
     CALL bederrorcheck("ERROR003: Error while getting location indicator")
   ENDFOR
 END ;Subroutine
 SUBROUTINE getproviders(dummyvar)
  DECLARE epsize = i4 WITH protect, noconstant(0)
  FOR (y = 1 TO size(reply->cpcs,5))
   SELECT INTO "nl:"
    FROM br_cpc bc,
     br_cpc_elig_prov_reltn bcepr,
     br_eligible_provider bep,
     prsnl p
    PLAN (bc
     WHERE (bc.br_cpc_id=reply->cpcs[y].br_cpc_id))
     JOIN (bcepr
     WHERE bcepr.br_cpc_id=bc.br_cpc_id
      AND bcepr.active_ind=1
      AND bcepr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bep
     WHERE bep.br_eligible_provider_id=bcepr.br_eligible_provider_id
      AND (bep.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
     JOIN (p
     WHERE p.person_id=bep.provider_id
      AND p.person_id > 0.0)
    HEAD bc.br_cpc_id
     epsize = 0
    DETAIL
     epsize = (epsize+ 1), stat = alterlist(reply->cpcs[y].providers,epsize), reply->cpcs[y].
     providers[epsize].provider_id = bep.br_eligible_provider_id,
     reply->cpcs[y].providers[epsize].provider_name = p.name_full_formatted, reply->cpcs[y].
     providers[epsize].tin = bep.tax_id_nbr_txt, reply->cpcs[y].providers[epsize].npi = bep
     .national_provider_nbr_txt,
     reply->cpcs[y].providers[epsize].active_ind = p.active_ind
     IF (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->cpcs[y].providers[epsize].effective_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 004: Error while getting the providers")
  ENDFOR
 END ;Subroutine
 SUBROUTINE getlocations(dummyvar)
   DECLARE locsize = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->cpcs,5))),
     br_cpc bc,
     br_cpc_loc_reltn bclr,
     code_value cv
    PLAN (d)
     JOIN (bc
     WHERE (bc.br_cpc_id=reply->cpcs[d.seq].br_cpc_id))
     JOIN (bclr
     WHERE bclr.br_cpc_id=bc.br_cpc_id
      AND bclr.active_ind=1
      AND bclr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (cv
     WHERE cv.code_value=bclr.location_cd)
    DETAIL
     locsize = (locsize+ 1), stat = alterlist(reply->cpcs[d.seq].locs,locsize), reply->cpcs[d.seq].
     locs[locsize].code_value = bclr.location_cd,
     reply->cpcs[d.seq].locs[locsize].display = cv.display, reply->cpcs[d.seq].locs[locsize].mean =
     cv.cdf_meaning, reply->cpcs[d.seq].locs[locsize].active_ind = cv.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 005: Error while getting the locations")
 END ;Subroutine
 SUBROUTINE getaddresses(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->cpcs,5))),
    address addr,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (addr
    WHERE addr.parent_entity_name=parent_entity_cpc
     AND (addr.parent_entity_id=reply->cpcs[d.seq].br_cpc_id))
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
    reply->cpcs[d.seq].address.address_id = addr.address_id, reply->cpcs[d.seq].address.street_addr1
     = addr.street_addr, reply->cpcs[d.seq].address.street_addr2 = addr.street_addr2,
    reply->cpcs[d.seq].address.street_addr3 = addr.street_addr3, reply->cpcs[d.seq].address.
    street_addr4 = addr.street_addr4, reply->cpcs[d.seq].address.city = addr.city,
    reply->cpcs[d.seq].address.state_code_value = addr.state_cd, reply->cpcs[d.seq].address.
    state_display = cv2.display, reply->cpcs[d.seq].address.state_mean = cv2.cdf_meaning,
    reply->cpcs[d.seq].address.zipcode = addr.zipcode, reply->cpcs[d.seq].address.county_code_value
     = addr.county_cd, reply->cpcs[d.seq].address.county_display = cv4.display,
    reply->cpcs[d.seq].address.county_mean = cv4.cdf_meaning, reply->cpcs[d.seq].address.
    country_code_value = addr.country_cd, reply->cpcs[d.seq].address.country_display = cv3.display,
    reply->cpcs[d.seq].address.country_mean = cv3.cdf_meaning, reply->cpcs[d.seq].address.
    contact_name = addr.contact_name, reply->cpcs[d.seq].address.comment_txt = addr.comment_txt
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 006: Error while getting the address")
 END ;Subroutine
 SUBROUTINE getphones(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->cpcs,5))),
    phone pc,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (pc
    WHERE pc.parent_entity_name=parent_entity_cpc
     AND (pc.parent_entity_id=reply->cpcs[d.seq].br_cpc_id)
     AND pc.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=pc.phone_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=pc.phone_format_cd)
   ORDER BY d.seq
   DETAIL
    reply->cpcs[d.seq].phone.phone_id = pc.phone_id, reply->cpcs[d.seq].phone.phone_format_code_value
     = pc.phone_format_cd, reply->cpcs[d.seq].phone.phone_format_display = cv2.display,
    reply->cpcs[d.seq].phone.phone_format_mean = cv2.cdf_meaning, reply->cpcs[d.seq].phone.phone_num
     = pc.phone_num, reply->cpcs[d.seq].phone.contact = pc.contact,
    reply->cpcs[d.seq].phone.call_instruction = pc.call_instruction, reply->cpcs[d.seq].phone.
    extension = pc.extension
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 007: Error while getting the phones")
 END ;Subroutine
END GO
