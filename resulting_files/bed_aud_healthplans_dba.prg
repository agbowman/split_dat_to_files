CREATE PROGRAM bed_aud_healthplans:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 plantypelist[*]
      2 plan_type_cd = f8
    1 financialclasslist[*]
      2 financial_class_cd = f8
    1 servicetypelist[*]
      2 service_type_cd = f8
    1 healthplancategorylist[*]
      2 health_plan_cat_cd = f8
    1 insurancecompanylist[*]
      2 org_id = f8
  )
 ENDIF
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
 RECORD temp(
   1 tlist[*]
     2 health_plan_id = f8
     2 health_plan_name = vc
     2 ins_comps[*]
       3 ins_company = vc
     2 health_plan_type = vc
     2 fin_class = vc
     2 address[*]
       3 address_type = vc
       3 street_address = vc
       3 street_address2 = vc
       3 street_address3 = vc
       3 street_address4 = vc
       3 city = vc
       3 state = vc
       3 zip = vc
       3 country = vc
     2 phone[*]
       3 phone_number_type = vc
       3 phone_number = vc
       3 contact = vc
     2 alias[*]
       3 health_plan_alias_type = vc
       3 health_plan_alias = vc
     2 sponsors[*]
       3 display = vc
     2 facilities[*]
       3 display = vc
     2 plan_category_display = vc
     2 service_type_display = vc
     2 timely_filing_days = i4
     2 timely_filing_auto_release = i4
     2 timely_filing_notification = i4
     2 expose_in_cust_hp_search = vc
     2 deny_cust_modification = vc
     2 priority_ranking_nbr = vc
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
 DECLARE buildhealthplanparse(dummyvar=i2) = null
 DECLARE auth_cd = f8 WITH protect, noconstant(0.0)
 DECLARE carrier_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sponsor_cd = f8 WITH protect, noconstant(0.0)
 DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE field_found = i2 WITH protect, noconstant(0)
 DECLARE plantypeparse = vc
 DECLARE financialclassparse = vc
 DECLARE servicetypeparse = vc
 DECLARE healthplancatparse = vc
 DECLARE insurancecompanyparse = vc
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE plantypeflag = i2 WITH protect
 DECLARE financialtypeflag = i2 WITH protect
 DECLARE servicetypeflag = i2 WITH protect
 DECLARE hpcattypeflag = i2 WITH protect
 DECLARE insurancecomptypeflag = i2 WITH protect
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=370
   AND cv.cdf_meaning IN ("CARRIER", "SPONSOR")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="CARRIER")
    carrier_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SPONSOR")
    sponsor_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
  DETAIL
   facility_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE field_found = i2 WITH protect
 DECLARE prg_exists_ind = i2 WITH protect
 DECLARE data_partition_ind = i2 WITH protect
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = 4
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 CALL buildhealthplanparse(0)
 SET tcnt = 0
 SET ccnt = 0
 IF (insurancecomptypeflag=0)
  SELECT INTO "NL:"
   FROM health_plan hp,
    code_value cv_plantype,
    code_value cv_finclass,
    health_plan_timely_filing hptf
   PLAN (hp
    WHERE parser(plantypeparse)
     AND parser(financialclassparse)
     AND parser(servicetypeparse)
     AND parser(healthplancatparse)
     AND hp.data_status_cd=auth_cd
     AND hp.active_ind=1
     AND (hp.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
    JOIN (cv_plantype
    WHERE cv_plantype.code_value=hp.plan_type_cd
     AND cv_plantype.active_ind=1)
    JOIN (cv_finclass
    WHERE cv_finclass.code_value=outerjoin(hp.financial_class_cd)
     AND cv_finclass.active_ind=outerjoin(1))
    JOIN (hptf
    WHERE hptf.health_plan_id=outerjoin(hp.health_plan_id))
   ORDER BY hp.plan_name, hp.health_plan_id
   HEAD hp.health_plan_id
    tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].health_plan_id = hp
    .health_plan_id,
    temp->tlist[tcnt].health_plan_name = hp.plan_name, temp->tlist[tcnt].health_plan_type =
    cv_plantype.display
    IF (cv_finclass.code_value > 0)
     temp->tlist[tcnt].fin_class = cv_finclass.display
    ENDIF
    temp->tlist[tcnt].plan_category_display = uar_get_code_display(hp.plan_category_cd), temp->tlist[
    tcnt].service_type_display = uar_get_code_display(hp.service_type_cd), temp->tlist[tcnt].
    timely_filing_days = hptf.limit_days,
    temp->tlist[tcnt].timely_filing_auto_release = hptf.auto_release_days, temp->tlist[tcnt].
    timely_filing_notification = hptf.notify_days
    IF (nullind(hp.consumer_add_covrg_allow_ind)=1)
     temp->tlist[tcnt].expose_in_cust_hp_search = ""
    ELSE
     IF (hp.consumer_add_covrg_allow_ind=1)
      temp->tlist[tcnt].expose_in_cust_hp_search = "Yes"
     ELSEIF (hp.consumer_add_covrg_allow_ind=0)
      temp->tlist[tcnt].expose_in_cust_hp_search = "No"
     ENDIF
    ENDIF
    IF (nullind(hp.consumer_modify_covrg_deny_ind)=1)
     temp->tlist[tcnt].deny_cust_modification = ""
    ELSE
     IF (hp.consumer_modify_covrg_deny_ind=1)
      temp->tlist[tcnt].deny_cust_modification = "Yes"
     ELSEIF (hp.consumer_modify_covrg_deny_ind=0)
      temp->tlist[tcnt].deny_cust_modification = "No"
     ENDIF
    ENDIF
    IF (nullind(hp.priority_ranking_nbr)=1)
     temp->tlist[tcnt].priority_ranking_nbr = ""
    ELSE
     temp->tlist[tcnt].priority_ranking_nbr = cnvtstring(hp.priority_ranking_nbr)
    ENDIF
   WITH nocounter
  ;end select
  CALL echo("Count")
  CALL echo(tcnt)
  IF (tcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    org_plan_reltn opr_carrier,
    organization o_carrier
   PLAN (d)
    JOIN (opr_carrier
    WHERE (opr_carrier.health_plan_id=temp->tlist[d.seq].health_plan_id)
     AND opr_carrier.data_status_cd=auth_cd
     AND opr_carrier.active_ind=1)
    JOIN (o_carrier
    WHERE o_carrier.organization_id=opr_carrier.organization_id
     AND o_carrier.active_ind=1
     AND o_carrier.data_status_cd=auth_cd)
   ORDER BY opr_carrier.health_plan_id, d.seq, o_carrier.org_name,
    o_carrier.organization_id
   HEAD opr_carrier.health_plan_id
    ccnt = 0
   HEAD o_carrier.organization_id
    ccnt = (ccnt+ 1), stat = alterlist(temp->tlist[d.seq].ins_comps,ccnt), temp->tlist[d.seq].
    ins_comps[ccnt].ins_company = o_carrier.org_name
   WITH nocounter
  ;end select
  CALL echorecord(temp)
 ELSE
  SELECT INTO "NL:"
   FROM health_plan hp,
    org_plan_reltn opr_carrier,
    organization o_carrier,
    code_value cv_plantype,
    code_value cv_finclass,
    health_plan_timely_filing hptf
   PLAN (hp
    WHERE parser(plantypeparse)
     AND parser(financialclassparse)
     AND parser(servicetypeparse)
     AND parser(healthplancatparse)
     AND hp.data_status_cd=auth_cd
     AND hp.active_ind=1
     AND (hp.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
    JOIN (opr_carrier
    WHERE opr_carrier.health_plan_id=hp.health_plan_id
     AND parser(insurancecompanyparse))
    JOIN (o_carrier
    WHERE o_carrier.organization_id=opr_carrier.organization_id
     AND o_carrier.active_ind=1
     AND o_carrier.data_status_cd=auth_cd)
    JOIN (cv_plantype
    WHERE cv_plantype.code_value=hp.plan_type_cd
     AND cv_plantype.active_ind=1)
    JOIN (cv_finclass
    WHERE cv_finclass.code_value=outerjoin(hp.financial_class_cd)
     AND cv_finclass.active_ind=outerjoin(1))
    JOIN (hptf
    WHERE hptf.health_plan_id=outerjoin(hp.health_plan_id))
   ORDER BY hp.plan_name, hp.health_plan_id, o_carrier.org_name,
    o_carrier.organization_id
   HEAD hp.health_plan_id
    ccnt = 0, tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt),
    temp->tlist[tcnt].health_plan_id = hp.health_plan_id, temp->tlist[tcnt].health_plan_name = hp
    .plan_name, temp->tlist[tcnt].health_plan_type = cv_plantype.display
    IF (cv_finclass.code_value > 0)
     temp->tlist[tcnt].fin_class = cv_finclass.display
    ENDIF
    temp->tlist[tcnt].plan_category_display = uar_get_code_display(hp.plan_category_cd), temp->tlist[
    tcnt].service_type_display = uar_get_code_display(hp.service_type_cd), temp->tlist[tcnt].
    timely_filing_days = hptf.limit_days,
    temp->tlist[tcnt].timely_filing_auto_release = hptf.auto_release_days, temp->tlist[tcnt].
    timely_filing_notification = hptf.notify_days
    IF (nullind(hp.consumer_add_covrg_allow_ind)=1)
     temp->tlist[tcnt].expose_in_cust_hp_search = ""
    ELSE
     IF (hp.consumer_add_covrg_allow_ind=1)
      temp->tlist[tcnt].expose_in_cust_hp_search = "Yes"
     ELSEIF (hp.consumer_add_covrg_allow_ind=0)
      temp->tlist[tcnt].expose_in_cust_hp_search = "No"
     ENDIF
    ENDIF
    IF (nullind(hp.consumer_modify_covrg_deny_ind)=1)
     temp->tlist[tcnt].deny_cust_modification = ""
    ELSE
     IF (hp.consumer_modify_covrg_deny_ind=1)
      temp->tlist[tcnt].deny_cust_modification = "Yes"
     ELSEIF (hp.consumer_modify_covrg_deny_ind=0)
      temp->tlist[tcnt].deny_cust_modification = "No"
     ENDIF
    ENDIF
    IF (nullind(hp.priority_ranking_nbr)=1)
     temp->tlist[tcnt].priority_ranking_nbr = ""
    ELSE
     temp->tlist[tcnt].priority_ranking_nbr = cnvtstring(hp.priority_ranking_nbr)
    ENDIF
   HEAD o_carrier.organization_id
    ccnt = (ccnt+ 1), stat = alterlist(temp->tlist[tcnt].ins_comps,ccnt), temp->tlist[tcnt].
    ins_comps[ccnt].ins_company = o_carrier.org_name
   WITH nocounter
  ;end select
  CALL echo("Count")
  CALL echo(tcnt)
  IF (tcnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   health_plan_alias hpa,
   code_value cv_aliaspool
  PLAN (d)
   JOIN (hpa
   WHERE (hpa.health_plan_id=temp->tlist[d.seq].health_plan_id)
    AND hpa.active_ind=1)
   JOIN (cv_aliaspool
   WHERE cv_aliaspool.code_value=hpa.alias_pool_cd
    AND cv_aliaspool.active_ind=1)
  ORDER BY d.seq, hpa.health_plan_alias_id
  HEAD d.seq
   acnt = 0
  HEAD hpa.health_plan_alias_id
   acnt = (acnt+ 1), stat = alterlist(temp->tlist[d.seq].alias,acnt), temp->tlist[d.seq].alias[acnt].
   health_plan_alias = hpa.alias,
   temp->tlist[d.seq].alias[acnt].health_plan_alias_type = cv_aliaspool.display
  WITH nocounter
 ;end select
 SET acnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   address a,
   code_value cv1,
   code_value cv2
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=temp->tlist[d.seq].health_plan_id)
    AND a.parent_entity_name="HEALTH_PLAN"
    AND a.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=a.address_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(a.state_cd)
    AND cv2.active_ind=outerjoin(1))
  HEAD d.seq
   acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(temp->tlist[d.seq].address,acnt), temp->tlist[d.seq].address[
   acnt].address_type = cv1.display,
   temp->tlist[d.seq].address[acnt].street_address = a.street_addr, temp->tlist[d.seq].address[acnt].
   street_address2 = a.street_addr2, temp->tlist[d.seq].address[acnt].street_address3 = a
   .street_addr3,
   temp->tlist[d.seq].address[acnt].street_address4 = a.street_addr4, temp->tlist[d.seq].address[acnt
   ].city = a.city, temp->tlist[d.seq].address[acnt].state = cv2.display,
   temp->tlist[d.seq].address[acnt].zip = a.zipcode, temp->tlist[d.seq].address[acnt].country = a
   .country
  WITH nocounter
 ;end select
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   phone p,
   code_value cv1
  PLAN (d)
   JOIN (p
   WHERE (p.parent_entity_id=temp->tlist[d.seq].health_plan_id)
    AND p.parent_entity_name="HEALTH_PLAN"
    AND p.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=p.phone_type_cd
    AND cv1.active_ind=1)
  HEAD d.seq
   pcnt = 0
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->tlist[d.seq].phone,pcnt), temp->tlist[d.seq].phone[pcnt].
   phone_number_type = cv1.display,
   temp->tlist[d.seq].phone[pcnt].phone_number = p.phone_num, temp->tlist[d.seq].phone[pcnt].contact
    = p.contact
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    org_plan_reltn opr,
    organization o
   PLAN (d)
    JOIN (opr
    WHERE (opr.health_plan_id=temp->tlist[d.seq].health_plan_id)
     AND opr.org_plan_reltn_cd=sponsor_cd
     AND opr.data_status_cd=auth_cd
     AND opr.active_ind=1)
    JOIN (o
    WHERE o.organization_id=opr.organization_id
     AND o.active_ind=1)
   ORDER BY d.seq, o.org_name
   HEAD d.seq
    scnt = 0
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(temp->tlist[d.seq].sponsors,scnt), temp->tlist[d.seq].
    sponsors[scnt].display = o.org_name
   WITH nocounter
  ;end select
 ENDIF
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    filter_entity_reltn f,
    location l,
    code_value cv
   PLAN (d)
    JOIN (f
    WHERE (f.parent_entity_id=temp->tlist[d.seq].health_plan_id)
     AND f.parent_entity_name="HEALTH_PLAN"
     AND f.filter_entity1_name="LOCATION")
    JOIN (l
    WHERE l.location_cd=f.filter_entity1_id
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cv.active_ind=1)
   ORDER BY d.seq, cv.display
   HEAD d.seq
    fcnt = 0
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(temp->tlist[d.seq].facilities,fcnt), temp->tlist[d.seq].
    facilities[fcnt].display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,28)
 SET reply->collist[1].header_text = "Health Plan Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Insurance Company"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Health Plan Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Financial Class"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Address Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Street Address"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Street Address 2"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Street Address 3"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Street Address 4"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "City"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "State"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Zip"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Country"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Phone Number Type"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Phone Number"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Contact"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Health Plan Alias Type"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Health Plan Alias"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Sponsor"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Facility View"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Plan Category"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Service Type"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Timely Filing Days"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Auto-Release Claims"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Timely Filing Notification"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Expose in Consumer HP Search"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Deny Consumer Modification"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Priority Ranking Number"
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE lines = i4 WITH protect
 DECLARE records = i4 WITH protect
 DECLARE sponsorrow = i4 WITH protect
 SET lines = 0
 SET records = 0
 SET sponsorrow = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt)
  DETAIL
   lines = maxval(1,size(temp->tlist[d.seq].address,5),size(temp->tlist[d.seq].phone,5),size(temp->
     tlist[d.seq].ins_comps,5),size(temp->tlist[d.seq].alias,5)), stat = alterlist(reply->rowlist,(
    lines+ records))
   FOR (i = (records+ 1) TO (lines+ records))
     stat = alterlist(reply->rowlist[i].celllist,28), reply->rowlist[i].celllist[1].string_value =
     temp->tlist[d.seq].health_plan_name
     IF ((i=(records+ 1)))
      reply->rowlist[i].celllist[3].string_value = temp->tlist[d.seq].health_plan_type, reply->
      rowlist[i].celllist[4].string_value = temp->tlist[d.seq].fin_class
     ENDIF
     reply->rowlist[i].celllist[21].string_value = temp->tlist[d.seq].plan_category_display, reply->
     rowlist[i].celllist[22].string_value = temp->tlist[d.seq].service_type_display
     IF ((temp->tlist[d.seq].timely_filing_days > 0.0))
      reply->rowlist[i].celllist[23].string_value = cnvtstring(temp->tlist[d.seq].timely_filing_days)
     ELSE
      reply->rowlist[i].celllist[23].string_value = ""
     ENDIF
     IF ((temp->tlist[d.seq].timely_filing_auto_release > 0.0))
      reply->rowlist[i].celllist[24].string_value = cnvtstring(temp->tlist[d.seq].
       timely_filing_auto_release)
     ELSE
      reply->rowlist[i].celllist[24].string_value = ""
     ENDIF
     IF ((temp->tlist[d.seq].timely_filing_notification > 0.0))
      reply->rowlist[i].celllist[25].string_value = cnvtstring(temp->tlist[d.seq].
       timely_filing_notification)
     ELSE
      reply->rowlist[i].celllist[25].string_value = ""
     ENDIF
     reply->rowlist[i].celllist[26].string_value = temp->tlist[d.seq].expose_in_cust_hp_search, reply
     ->rowlist[i].celllist[27].string_value = temp->tlist[d.seq].deny_cust_modification, reply->
     rowlist[i].celllist[28].string_value = temp->tlist[d.seq].priority_ranking_nbr
   ENDFOR
   FOR (i = 1 TO size(temp->tlist[d.seq].alias,5))
    reply->rowlist[(i+ records)].celllist[17].string_value = temp->tlist[d.seq].alias[i].
    health_plan_alias_type,reply->rowlist[(i+ records)].celllist[18].string_value = temp->tlist[d.seq
    ].alias[i].health_plan_alias
   ENDFOR
   FOR (i = 1 TO size(temp->tlist[d.seq].ins_comps,5))
     reply->rowlist[(i+ records)].celllist[2].string_value = temp->tlist[d.seq].ins_comps[i].
     ins_company
   ENDFOR
   FOR (i = 1 TO size(temp->tlist[d.seq].address,5))
     reply->rowlist[(i+ records)].celllist[5].string_value = temp->tlist[d.seq].address[i].
     address_type, reply->rowlist[(i+ records)].celllist[6].string_value = temp->tlist[d.seq].
     address[i].street_address, reply->rowlist[(i+ records)].celllist[7].string_value = temp->tlist[d
     .seq].address[i].street_address2,
     reply->rowlist[(i+ records)].celllist[8].string_value = temp->tlist[d.seq].address[i].
     street_address3, reply->rowlist[(i+ records)].celllist[9].string_value = temp->tlist[d.seq].
     address[i].street_address4, reply->rowlist[(i+ records)].celllist[10].string_value = temp->
     tlist[d.seq].address[i].city,
     reply->rowlist[(i+ records)].celllist[11].string_value = temp->tlist[d.seq].address[i].state,
     reply->rowlist[(i+ records)].celllist[12].string_value = temp->tlist[d.seq].address[i].zip,
     reply->rowlist[(i+ records)].celllist[13].string_value = temp->tlist[d.seq].address[i].country
   ENDFOR
   FOR (i = 1 TO size(temp->tlist[d.seq].phone,5))
     reply->rowlist[(i+ records)].celllist[14].string_value = temp->tlist[d.seq].phone[i].
     phone_number_type, reply->rowlist[(i+ records)].celllist[15].string_value = temp->tlist[d.seq].
     phone[i].phone_number, reply->rowlist[(i+ records)].celllist[16].string_value = temp->tlist[d
     .seq].phone[i].contact
   ENDFOR
   FOR (s = 1 TO size(temp->tlist[d.seq].sponsors,5))
     IF (s=1)
      reply->rowlist[(1+ records)].celllist[19].string_value = trim(temp->tlist[d.seq].sponsors[s].
       display)
     ELSE
      reply->rowlist[(1+ records)].celllist[19].string_value = build2(reply->rowlist[(1+ records)].
       celllist[19].string_value,", ",trim(temp->tlist[d.seq].sponsors[s].display))
     ENDIF
   ENDFOR
   FOR (f = 1 TO size(temp->tlist[d.seq].facilities,5))
     IF (f=1)
      reply->rowlist[(1+ records)].celllist[20].string_value = trim(temp->tlist[d.seq].facilities[f].
       display)
     ELSE
      reply->rowlist[(1+ records)].celllist[20].string_value = build2(reply->rowlist[(1+ records)].
       celllist[20].string_value,", ",trim(temp->tlist[d.seq].facilities[f].display))
     ENDIF
   ENDFOR
   records = (records+ lines)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (size(reply->rowlist,5) > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(reply->rowlist,5) > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE buildhealthplanparse(dummyvar)
   DECLARE plantypesize = i4 WITH protect, noconstant(0)
   DECLARE financialclasssize = i4 WITH protect, noconstant(0)
   DECLARE servicetypesize = i4 WITH protect, noconstant(0)
   DECLARE hpcategorysize = i4 WITH protect, noconstant(0)
   DECLARE insurancecompsize = i4 WITH protect, noconstant(0)
   DECLARE all = vc WITH protect, constant("1 = 1")
   SET plantypesize = size(request->plantypelist,5)
   IF (plantypesize > 0)
    SET plantypeparse = build(plantypeparse,"hp.plan_type_cd IN ( ")
    FOR (pt = 1 TO plantypesize)
      SET plantypeparse = build(plantypeparse,request->plantypelist[pt].plan_type_cd,",")
    ENDFOR
    SET plantypeparse = replace(plantypeparse,",","",2)
    SET plantypeparse = build(plantypeparse,")")
    SET plantypeflag = 1
   ELSE
    SET plantypeparse = build(plantypeparse,all)
    SET plantypeflag = 0
   ENDIF
   SET financialclasssize = size(request->financialclasslist,5)
   IF (financialclasssize > 0)
    SET financialclassparse = build(financialclassparse,"hp.financial_class_cd IN ( ")
    FOR (fc = 1 TO financialclasssize)
      SET financialclassparse = build(financialclassparse,request->financialclasslist[fc].
       financial_class_cd,",")
    ENDFOR
    SET financialclassparse = replace(financialclassparse,",","",2)
    SET financialclassparse = build(financialclassparse,")")
    SET financialtypeflag = 1
   ELSE
    SET financialclassparse = build(financialclassparse,all)
    SET financialtypeflag = 0
   ENDIF
   SET servicetypesize = size(request->servicetypelist,5)
   IF (servicetypesize > 0)
    SET servicetypeparse = build(servicetypeparse,"hp.service_type_cd IN ( ")
    FOR (st = 1 TO servicetypesize)
      SET servicetypeparse = build(servicetypeparse,request->servicetypelist[st].service_type_cd,",")
    ENDFOR
    SET servicetypeparse = replace(servicetypeparse,",","",2)
    SET servicetypeparse = build(servicetypeparse,")")
    SET servicetypeflag = 1
   ELSE
    SET servicetypeparse = build(servicetypeparse,all)
    SET servicetypeflag = 0
   ENDIF
   CALL echo(build("serviceTypeParse :",servicetypeparse))
   SET hpcategorysize = size(request->healthplancategorylist,5)
   IF (hpcategorysize > 0)
    SET healthplancatparse = build(healthplancatparse,"hp.plan_category_cd IN ( ")
    FOR (hpc = 1 TO hpcategorysize)
      SET healthplancatparse = build(healthplancatparse,request->healthplancategorylist[hpc].
       health_plan_cat_cd,",")
    ENDFOR
    SET healthplancatparse = replace(healthplancatparse,",","",2)
    SET healthplancatparse = build(healthplancatparse,")")
    SET hpcattypeflag = 1
   ELSE
    SET healthplancatparse = build(healthplancatparse,all)
    SET hpcattypeflag = 0
   ENDIF
   SET insurancecompsize = size(request->insurancecompanylist,5)
   IF (insurancecompsize > 0)
    SET insurancecompanyparse = build(insurancecompanyparse,"opr_carrier.organization_id IN ( ")
    FOR (ic = 1 TO insurancecompsize)
      SET insurancecompanyparse = build(insurancecompanyparse,request->insurancecompanylist[ic].
       org_id,",")
    ENDFOR
    SET insurancecompanyparse = replace(insurancecompanyparse,",","",2)
    SET insurancecompanyparse = build(insurancecompanyparse,")")
    SET insurancecomptypeflag = 1
   ELSE
    SET insurancecompanyparse = build(insurancecompanyparse,all)
    SET insurancecomptypeflag = 0
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_health_plan_report.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
