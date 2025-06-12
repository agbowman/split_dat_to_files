CREATE PROGRAM bed_aud_eligible_provider:dba
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
  ) WITH protect
 ENDIF
 FREE RECORD epdata
 RECORD epdata(
   1 eplist[*]
     2 ep_id = f8
     2 name_full_formatted = vc
     2 npi = vc
     2 tin = vc
     2 address_line_1 = vc
     2 address_line_2 = vc
     2 address_line_3 = vc
     2 address_line_4 = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 county = vc
     2 country = vc
     2 phone_num = vc
     2 measures[*]
       3 measure_id = f8
       3 measure_iden = vc
       3 adult_pediatric_type = vc
       3 measure_description = vc
       3 domain = vc
       3 mu_year = vc
       3 high_priority_ind = i2
       3 outcome_ind = i2
     2 extension = vc
     2 extension_type = vc
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
 DECLARE column_cnt = i4 WITH protect, constant(22)
 DECLARE col_full_name_formatted = i4 WITH protect, constant(1)
 DECLARE col_npi = i4 WITH protect, constant(2)
 DECLARE col_tin = i4 WITH protect, constant(3)
 DECLARE col_extension_type = i4 WITH protect, constant(4)
 DECLARE col_extension = i4 WITH protect, constant(5)
 DECLARE col_address1 = i4 WITH protect, constant(6)
 DECLARE col_address2 = i4 WITH protect, constant(7)
 DECLARE col_address3 = i4 WITH protect, constant(8)
 DECLARE col_address4 = i4 WITH protect, constant(9)
 DECLARE col_city = i4 WITH protect, constant(10)
 DECLARE col_state = i4 WITH protect, constant(11)
 DECLARE col_zip = i4 WITH protect, constant(12)
 DECLARE col_county = i4 WITH protect, constant(13)
 DECLARE col_country = i4 WITH protect, constant(14)
 DECLARE col_phone = i4 WITH protect, constant(15)
 DECLARE col_measure_year = i4 WITH protect, constant(16)
 DECLARE col_measure_id = i4 WITH protect, constant(17)
 DECLARE col_adult_pediatric = i4 WITH protect, constant(18)
 DECLARE col_description = i4 WITH protect, constant(19)
 DECLARE col_domain = i4 WITH protect, constant(20)
 DECLARE col_high_priority = i4 WITH protect, constant(21)
 DECLARE col_outcome = i4 WITH protect, constant(22)
 DECLARE rowcnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE geteligibleproviderdemographicinfo(dummyvar=i2) = i2
 DECLARE geteligibleproviderdemographicinfobasedonrequestcriteria(dummyvar=i2) = i2
 DECLARE geteligibleprovidercqmmeasures(dummyvar=i2) = i2
 DECLARE geteligibleproviderextensions(dummyvar=i2) = i2
 DECLARE populatereportheaders(dummyvar=i2) = i2
 DECLARE populatereportdata(dummyvar=i2) = i2
 DECLARE populatereportdatabasedonrequestcriteria(dummyvar=i2) = i2
 IF (size(request->br_eligible_provider_id_list,5) > 0)
  CALL geteligibleproviderdemographicinfobasedonrequestcriteria(0)
 ELSE
  CALL geteligibleproviderdemographicinfo(0)
 ENDIF
 IF (size(epdata->eplist,5) > 0)
  CALL geteligibleprovidercqmmeasures(0)
  CALL geteligibleproviderextensions(0)
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (size(epdata->eplist,5) > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(epdata->eplist,5) > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL populatereportheaders(0)
 IF ((((request->medicaid_flag=1)) OR ((request->medicare_flag=1))) )
  CALL populatereportdatabasedonrequestcriteria(0)
 ELSE
  CALL populatereportdata(0)
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_eligible_provider.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
 SUBROUTINE geteligibleproviderdemographicinfo(dummyvar)
   CALL bedlogmessage("getEligibleProviderDemographicInfo","Entering ...")
   DECLARE k = i4 WITH protect, noconstant(1)
   FREE RECORD geteprequest
   RECORD geteprequest(
     1 last_name = vc
     1 first_name = vc
     1 omf_group_cd = f8
     1 no_quality_measures_ind = i2
   )
   FREE RECORD getepreply
   RECORD getepreply(
     1 providers[*]
       2 id = f8
       2 person_id = f8
       2 national_provider_nbr = vc
       2 tax_id = vc
       2 specialty_id = f8
       2 health_plan = vc
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
       2 quality_measures[*]
         3 id = f8
         3 display = vc
         3 sequence = i2
         3 unique_code_value_display = vc
       2 omf_group_cd = f8
       2 omf_group_display = vc
       2 active_ind = i2
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 first_name = vc
       2 last_name = vc
       2 name_full_formatted = vc
       2 username = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE bed_get_eligible_providers  WITH replace("REQUEST",geteprequest), replace("REPLY",
    getepreply)
   IF ((getepreply->status_data.status != "S"))
    CALL bedlogmessage("getEligibleProviderDemographicInfo",
     "bed_get_eligible_providers did not return success.")
    IF (validate(debug,0)=1)
     CALL echorecord(geteprequest)
     CALL echorecord(getepreply)
     CALL bederror("Failure calling bed_get_eligible_providers")
    ENDIF
   ENDIF
   SET stat = alterlist(epdata->eplist,size(getepreply->providers,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(getepreply->providers,5))
    PLAN (d)
    ORDER BY cnvtupper(getepreply->providers[d.seq].name_full_formatted)
    DETAIL
     epdata->eplist[k].ep_id = getepreply->providers[d.seq].id, epdata->eplist[k].name_full_formatted
      = getepreply->providers[d.seq].name_full_formatted, epdata->eplist[k].npi = getepreply->
     providers[d.seq].national_provider_nbr,
     epdata->eplist[k].tin = getepreply->providers[d.seq].tax_id, epdata->eplist[k].address_line_1 =
     getepreply->providers[d.seq].address.street_addr1, epdata->eplist[k].address_line_2 = getepreply
     ->providers[d.seq].address.street_addr2,
     epdata->eplist[k].address_line_3 = getepreply->providers[d.seq].address.street_addr3, epdata->
     eplist[k].address_line_4 = getepreply->providers[d.seq].address.street_addr4, epdata->eplist[k].
     city = getepreply->providers[d.seq].address.city,
     epdata->eplist[k].zip = getepreply->providers[d.seq].address.zipcode, epdata->eplist[k].county
      = getepreply->providers[d.seq].address.county_display, epdata->eplist[k].country = getepreply->
     providers[d.seq].address.country_display,
     epdata->eplist[k].state = getepreply->providers[d.seq].address.state_display
     IF (size(trim(getepreply->providers[d.seq].phone.extension,7),1) > 0)
      epdata->eplist[k].phone_num = build2(getepreply->providers[d.seq].phone.phone_num," Ext: ",
       getepreply->providers[d.seq].phone.extension)
     ELSE
      epdata->eplist[k].phone_num = getepreply->providers[d.seq].phone.phone_num
     ENDIF
     k = (k+ 1)
    WITH nocounter
   ;end select
   CALL bedlogmessage("getEligibleProviderDemographicInfo","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteligibleproviderdemographicinfobasedonrequestcriteria(dummyvar)
   CALL bedlogmessage("getEligibleProviderDemographicInfoBasedOnRequestCriteria","Entering ...")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE epcnt = i4 WITH protect, noconstant(0)
   DECLARE req_size = i4 WITH protect, noconstant(0)
   SET idx = 0
   SET epcnt = 0
   SET req_size = size(request->br_eligible_provider_id_list,5)
   SELECT INTO "nl:"
    FROM br_eligible_provider b,
     prsnl pr,
     address a,
     code_value cv1,
     code_value cv2,
     code_value cv3,
     phone p,
     code_value cv4
    PLAN (b
     WHERE expand(idx,1,req_size,b.br_eligible_provider_id,request->br_eligible_provider_id_list[idx]
      .br_eligible_provider_id))
     JOIN (pr
     WHERE pr.person_id=b.provider_id)
     JOIN (a
     WHERE a.parent_entity_name=outerjoin("BR_ELIGIBLE_PROVIDER")
      AND a.parent_entity_id=outerjoin(b.br_eligible_provider_id)
      AND a.active_ind=outerjoin(1))
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(a.state_cd)
      AND cv1.active_ind=outerjoin(1))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(a.county_cd)
      AND cv2.active_ind=outerjoin(1))
     JOIN (cv3
     WHERE cv3.code_value=outerjoin(a.country_cd)
      AND cv3.active_ind=outerjoin(1))
     JOIN (p
     WHERE p.parent_entity_name=outerjoin("BR_ELIGIBLE_PROVIDER")
      AND p.parent_entity_id=outerjoin(b.br_eligible_provider_id)
      AND p.active_ind=outerjoin(1))
     JOIN (cv4
     WHERE cv4.code_value=outerjoin(p.phone_format_cd)
      AND cv4.active_ind=outerjoin(1))
    ORDER BY cnvtupper(pr.name_full_formatted)
    DETAIL
     epcnt = (epcnt+ 1), stat = alterlist(epdata->eplist,epcnt), epdata->eplist[epcnt].ep_id = b
     .br_eligible_provider_id,
     epdata->eplist[epcnt].name_full_formatted = pr.name_full_formatted, epdata->eplist[epcnt].npi =
     b.national_provider_nbr_txt, epdata->eplist[epcnt].tin = b.tax_id_nbr_txt,
     epdata->eplist[epcnt].address_line_1 = a.street_addr, epdata->eplist[epcnt].address_line_2 = a
     .street_addr2, epdata->eplist[epcnt].address_line_3 = a.street_addr3,
     epdata->eplist[epcnt].address_line_4 = a.street_addr4, epdata->eplist[epcnt].city = a.city,
     epdata->eplist[epcnt].zip = a.zipcode,
     epdata->eplist[epcnt].county = cv2.display, epdata->eplist[epcnt].country = cv3.display, epdata
     ->eplist[epcnt].state = cv1.display
     IF (size(trim(p.extension,7),1) > 0)
      epdata->eplist[epcnt].phone_num = build2(p.phone_num," Ext: ",p.extension)
     ELSE
      epdata->eplist[epcnt].phone_num = p.phone_num
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL bedlogmessage("getEligibleProviderDemographicInfoBasedOnRequestCriteria","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteligibleprovidercqmmeasures(dummyvar)
   CALL bedlogmessage("getEligibleProviderCQMMeasures","Entering ...")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE loc = i4 WITH protect, noconstant(0)
   FREE RECORD getcqmmeasuresrequest
   RECORD getcqmmeasuresrequest(
     1 providers[*]
       2 provider_id = f8
       2 service_entity_flag = i4
   )
   FREE RECORD getcqmmeasuresreply
   RECORD getcqmmeasuresreply(
     1 providers[*]
       2 provider_id = f8
       2 measures[*]
         3 measure_id = f8
         3 meas_ident = vc
         3 adult_pediatric_type = vc
         3 measure_description = vc
         3 domain = vc
         3 mu_year = vc
         3 high_priority_ind = i2
         3 outcome_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET stat = alterlist(getcqmmeasuresrequest->providers,size(epdata->eplist,5))
   FOR (i = 1 TO size(epdata->eplist,5))
    SET getcqmmeasuresrequest->providers[i].provider_id = epdata->eplist[i].ep_id
    SET getcqmmeasuresrequest->providers[i].service_entity_flag = 1
   ENDFOR
   EXECUTE bed_get_cqm_measures_by_prov  WITH replace("REQUEST",getcqmmeasuresrequest), replace(
    "REPLY",getcqmmeasuresreply)
   IF ((getcqmmeasuresreply->status_data.status != "S"))
    CALL bedlogmessage("getEligibleProviderCQMMeasures",
     "bed_get_cqm_measures_by_prov did not return success.")
    IF (validate(debug,0)=1)
     CALL echorecord(getcqmmeasuresrequest)
     CALL echorecord(getcqmmeasuresreply)
     CALL bederror("Failure calling bed_get_cqm_measures_by_prov")
    ENDIF
   ENDIF
   FOR (p = 1 TO size(getcqmmeasuresreply->providers,5))
     IF (size(getcqmmeasuresreply->providers[p].measures,5) > 0)
      SET loc = locateval(num,1,size(epdata->eplist,5),getcqmmeasuresreply->providers[p].provider_id,
       epdata->eplist[num].ep_id)
      IF (loc > 0)
       SET stat = alterlist(epdata->eplist[loc].measures,size(getcqmmeasuresreply->providers[p].
         measures,5))
       FOR (m = 1 TO size(getcqmmeasuresreply->providers[p].measures,5))
         SET epdata->eplist[loc].measures[m].measure_id = getcqmmeasuresreply->providers[p].measures[
         m].measure_id
         SET epdata->eplist[loc].measures[m].measure_description = getcqmmeasuresreply->providers[p].
         measures[m].measure_description
         SET epdata->eplist[loc].measures[m].measure_iden = getcqmmeasuresreply->providers[p].
         measures[m].meas_ident
         SET epdata->eplist[loc].measures[m].adult_pediatric_type = getcqmmeasuresreply->providers[p]
         .measures[m].adult_pediatric_type
         SET epdata->eplist[loc].measures[m].domain = getcqmmeasuresreply->providers[p].measures[m].
         domain
         SET epdata->eplist[loc].measures[m].mu_year = getcqmmeasuresreply->providers[p].measures[m].
         mu_year
         SET epdata->eplist[loc].measures[m].high_priority_ind = getcqmmeasuresreply->providers[p].
         measures[m].high_priority_ind
         SET epdata->eplist[loc].measures[m].outcome_ind = getcqmmeasuresreply->providers[p].
         measures[m].outcome_ind
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("getEligibleProviderCQMMeasures","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteligibleproviderextensions(dummyvar)
   FOR (j = 1 TO size(epdata->eplist,5))
     SELECT INTO "nl:"
      FROM br_elig_prov_extension bepe,
       code_value cv
      WHERE (bepe.br_eligible_provider_id=epdata->eplist[j].ep_id)
       AND bepe.active_ind=1
       AND bepe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND cv.code_value=outerjoin(bepe.medicaid_stage_cd)
       AND cv.code_value != outerjoin(0.0)
      DETAIL
       IF (trim(bepe.program_type_txt,5)="MEDICAID")
        epdata->eplist[j].extension_type = "MEDICAID", epdata->eplist[j].extension = cv.description
       ELSEIF (trim(bepe.program_type_txt,5)="MEDICARE")
        epdata->eplist[j].extension_type = "MEDICARE", epdata->eplist[j].extension = cnvtstring(bepe
         .medicare_year,4)
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   CALL bedlogmessage("populateReportHeaders","Entering ...")
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[col_full_name_formatted].header_text = "Name Full Formatted"
   SET reply->collist[col_full_name_formatted].data_type = 1
   SET reply->collist[col_full_name_formatted].hide_ind = 0
   SET reply->collist[col_npi].header_text = "NPI"
   SET reply->collist[col_npi].data_type = 1
   SET reply->collist[col_npi].hide_ind = 0
   SET reply->collist[col_tin].header_text = "TIN"
   SET reply->collist[col_tin].data_type = 1
   SET reply->collist[col_tin].hide_ind = 0
   SET reply->collist[col_extension_type].header_text = "Program Enrollment"
   SET reply->collist[col_extension_type].data_type = 1
   SET reply->collist[col_extension_type].hide_ind = 0
   SET reply->collist[col_extension].header_text = "Program Enrollment Date"
   SET reply->collist[col_extension].data_type = 1
   SET reply->collist[col_extension].hide_ind = 0
   SET reply->collist[col_address1].header_text = "Address Line 1"
   SET reply->collist[col_address1].data_type = 1
   SET reply->collist[col_address1].hide_ind = 0
   SET reply->collist[col_address2].header_text = "Address Line 2"
   SET reply->collist[col_address2].data_type = 1
   SET reply->collist[col_address2].hide_ind = 0
   SET reply->collist[col_address3].header_text = "Address Line 3"
   SET reply->collist[col_address3].data_type = 1
   SET reply->collist[col_address3].hide_ind = 0
   SET reply->collist[col_address4].header_text = "Address Line 4"
   SET reply->collist[col_address4].data_type = 1
   SET reply->collist[col_address4].hide_ind = 0
   SET reply->collist[col_city].header_text = "City"
   SET reply->collist[col_city].data_type = 1
   SET reply->collist[col_city].hide_ind = 0
   SET reply->collist[col_state].header_text = "State"
   SET reply->collist[col_state].data_type = 1
   SET reply->collist[col_state].hide_ind = 0
   SET reply->collist[col_zip].header_text = "Zip Code"
   SET reply->collist[col_zip].data_type = 1
   SET reply->collist[col_zip].hide_ind = 0
   SET reply->collist[col_county].header_text = "County"
   SET reply->collist[col_county].data_type = 1
   SET reply->collist[col_county].hide_ind = 0
   SET reply->collist[col_country].header_text = "Country"
   SET reply->collist[col_country].data_type = 1
   SET reply->collist[col_country].hide_ind = 0
   SET reply->collist[col_phone].header_text = "Phone number"
   SET reply->collist[col_phone].data_type = 1
   SET reply->collist[col_phone].hide_ind = 0
   SET reply->collist[col_measure_year].header_text = "Measure Year"
   SET reply->collist[col_measure_year].data_type = 1
   SET reply->collist[col_measure_year].hide_ind = 0
   SET reply->collist[col_measure_id].header_text = "Measure ID"
   SET reply->collist[col_measure_id].data_type = 1
   SET reply->collist[col_measure_id].hide_ind = 0
   SET reply->collist[col_adult_pediatric].header_text = "Adult-Pediatric"
   SET reply->collist[col_adult_pediatric].data_type = 1
   SET reply->collist[col_adult_pediatric].hide_ind = 0
   SET reply->collist[col_description].header_text = "Description"
   SET reply->collist[col_description].data_type = 1
   SET reply->collist[col_description].hide_ind = 0
   SET reply->collist[col_domain].header_text = "Domain"
   SET reply->collist[col_domain].data_type = 1
   SET reply->collist[col_domain].hide_ind = 0
   SET reply->collist[col_high_priority].header_text = "High Priority"
   SET reply->collist[col_high_priority].data_type = 1
   SET reply->collist[col_high_priority].hide_ind = 0
   SET reply->collist[col_outcome].header_text = "Outcome"
   SET reply->collist[col_outcome].data_type = 1
   SET reply->collist[col_outcome].hide_ind = 0
   CALL bedlogmessage("populateReportHeaders","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   CALL bedlogmessage("populateReportData","Entering ...")
   FOR (pcnt = 1 TO size(epdata->eplist,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET reply->rowlist[rowcnt].celllist[col_full_name_formatted].string_value = epdata->eplist[pcnt]
     .name_full_formatted
     SET reply->rowlist[rowcnt].celllist[col_npi].string_value = epdata->eplist[pcnt].npi
     SET reply->rowlist[rowcnt].celllist[col_tin].string_value = epdata->eplist[pcnt].tin
     SET reply->rowlist[rowcnt].celllist[col_extension_type].string_value = epdata->eplist[pcnt].
     extension_type
     SET reply->rowlist[rowcnt].celllist[col_extension].string_value = epdata->eplist[pcnt].extension
     SET reply->rowlist[rowcnt].celllist[col_address1].string_value = epdata->eplist[pcnt].
     address_line_1
     SET reply->rowlist[rowcnt].celllist[col_address2].string_value = epdata->eplist[pcnt].
     address_line_2
     SET reply->rowlist[rowcnt].celllist[col_address3].string_value = epdata->eplist[pcnt].
     address_line_3
     SET reply->rowlist[rowcnt].celllist[col_address4].string_value = epdata->eplist[pcnt].
     address_line_4
     SET reply->rowlist[rowcnt].celllist[col_city].string_value = epdata->eplist[pcnt].city
     SET reply->rowlist[rowcnt].celllist[col_state].string_value = epdata->eplist[pcnt].state
     SET reply->rowlist[rowcnt].celllist[col_zip].string_value = epdata->eplist[pcnt].zip
     SET reply->rowlist[rowcnt].celllist[col_county].string_value = epdata->eplist[pcnt].county
     SET reply->rowlist[rowcnt].celllist[col_country].string_value = epdata->eplist[pcnt].country
     SET reply->rowlist[rowcnt].celllist[col_phone].string_value = epdata->eplist[pcnt].phone_num
     SET cnt = size(epdata->eplist[pcnt].measures,5)
     IF (cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(epdata->eplist[pcnt].measures,5))
       PLAN (d)
       ORDER BY epdata->eplist[pcnt].measures[d.seq].mu_year, epdata->eplist[pcnt].measures[d.seq].
        measure_iden
       DETAIL
        reply->rowlist[rowcnt].celllist[col_full_name_formatted].string_value = epdata->eplist[pcnt].
        name_full_formatted, reply->rowlist[rowcnt].celllist[col_measure_year].string_value = epdata
        ->eplist[pcnt].measures[d.seq].mu_year, reply->rowlist[rowcnt].celllist[col_measure_id].
        string_value = epdata->eplist[pcnt].measures[d.seq].measure_iden,
        reply->rowlist[rowcnt].celllist[col_adult_pediatric].string_value = epdata->eplist[pcnt].
        measures[d.seq].adult_pediatric_type, reply->rowlist[rowcnt].celllist[col_description].
        string_value = epdata->eplist[pcnt].measures[d.seq].measure_description, reply->rowlist[
        rowcnt].celllist[col_domain].string_value = epdata->eplist[pcnt].measures[d.seq].domain
        IF ((epdata->eplist[pcnt].measures[d.seq].high_priority_ind=0))
         reply->rowlist[rowcnt].celllist[col_high_priority].string_value = ""
        ELSE
         reply->rowlist[rowcnt].celllist[col_high_priority].string_value = "High Priority"
        ENDIF
        IF ((epdata->eplist[pcnt].measures[d.seq].outcome_ind=0))
         reply->rowlist[rowcnt].celllist[col_outcome].string_value = ""
        ELSE
         reply->rowlist[rowcnt].celllist[col_outcome].string_value = "Outcome"
        ENDIF
        cnt = (cnt - 1)
        IF (cnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateReportData","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportdatabasedonrequestcriteria(dummyvar)
  CALL bedlogmessage("populateReportData","Entering ...")
  FOR (pcnt = 1 TO size(epdata->eplist,5))
    IF ((((request->medicaid_flag=1)
     AND trim(epdata->eplist[pcnt].extension_type,5)="MEDICAID") OR ((request->medicare_flag=1)
     AND trim(epdata->eplist[pcnt].extension_type,5)="MEDICARE")) )
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET reply->rowlist[rowcnt].celllist[col_full_name_formatted].string_value = epdata->eplist[pcnt]
     .name_full_formatted
     SET reply->rowlist[rowcnt].celllist[col_npi].string_value = epdata->eplist[pcnt].npi
     SET reply->rowlist[rowcnt].celllist[col_tin].string_value = epdata->eplist[pcnt].tin
     SET reply->rowlist[rowcnt].celllist[col_extension_type].string_value = epdata->eplist[pcnt].
     extension_type
     SET reply->rowlist[rowcnt].celllist[col_extension].string_value = epdata->eplist[pcnt].extension
     SET reply->rowlist[rowcnt].celllist[col_address1].string_value = epdata->eplist[pcnt].
     address_line_1
     SET reply->rowlist[rowcnt].celllist[col_address2].string_value = epdata->eplist[pcnt].
     address_line_2
     SET reply->rowlist[rowcnt].celllist[col_address3].string_value = epdata->eplist[pcnt].
     address_line_3
     SET reply->rowlist[rowcnt].celllist[col_address4].string_value = epdata->eplist[pcnt].
     address_line_4
     SET reply->rowlist[rowcnt].celllist[col_city].string_value = epdata->eplist[pcnt].city
     SET reply->rowlist[rowcnt].celllist[col_state].string_value = epdata->eplist[pcnt].state
     SET reply->rowlist[rowcnt].celllist[col_zip].string_value = epdata->eplist[pcnt].zip
     SET reply->rowlist[rowcnt].celllist[col_county].string_value = epdata->eplist[pcnt].county
     SET reply->rowlist[rowcnt].celllist[col_country].string_value = epdata->eplist[pcnt].country
     SET reply->rowlist[rowcnt].celllist[col_phone].string_value = epdata->eplist[pcnt].phone_num
     SET cnt = size(epdata->eplist[pcnt].measures,5)
     IF (cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(epdata->eplist[pcnt].measures,5))
       PLAN (d)
       ORDER BY epdata->eplist[pcnt].measures[d.seq].mu_year, epdata->eplist[pcnt].measures[d.seq].
        measure_iden
       DETAIL
        reply->rowlist[rowcnt].celllist[col_full_name_formatted].string_value = epdata->eplist[pcnt].
        name_full_formatted, reply->rowlist[rowcnt].celllist[col_measure_year].string_value = epdata
        ->eplist[pcnt].measures[d.seq].mu_year, reply->rowlist[rowcnt].celllist[col_measure_id].
        string_value = epdata->eplist[pcnt].measures[d.seq].measure_iden,
        reply->rowlist[rowcnt].celllist[col_adult_pediatric].string_value = epdata->eplist[pcnt].
        measures[d.seq].adult_pediatric_type, reply->rowlist[rowcnt].celllist[col_description].
        string_value = epdata->eplist[pcnt].measures[d.seq].measure_description, reply->rowlist[
        rowcnt].celllist[col_domain].string_value = epdata->eplist[pcnt].measures[d.seq].domain
        IF ((epdata->eplist[pcnt].measures[d.seq].high_priority_ind=0))
         reply->rowlist[rowcnt].celllist[col_high_priority].string_value = ""
        ELSE
         reply->rowlist[rowcnt].celllist[col_high_priority].string_value = "High Priority"
        ENDIF
        IF ((epdata->eplist[pcnt].measures[d.seq].outcome_ind=0))
         reply->rowlist[rowcnt].celllist[col_outcome].string_value = ""
        ELSE
         reply->rowlist[rowcnt].celllist[col_outcome].string_value = "Outcome"
        ENDIF
        cnt = (cnt - 1)
        IF (cnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
END GO
