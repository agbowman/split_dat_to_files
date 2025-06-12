CREATE PROGRAM bed_ens_org_hp:dba
 RECORD request(
   1 organizations[*]
     2 action_flag = i2
     2 id = f8
     2 name = vc
     2 org_types[*]
       3 action_flag = i2
       3 code_value = f8
     2 addresses[*]
       3 action_flag = i2
       3 id = f8
       3 sequence = i4
       3 street_addr1 = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state_code_value = f8
       3 county_code_value = f8
       3 zipcode = vc
       3 country_code_value = f8
       3 address_type_code_value = f8
       3 contact_name = vc
       3 comment_txt = vc
     2 phones[*]
       3 action_flag = i2
       3 id = f8
       3 phone_type_code_value = f8
       3 phone_format_code_value = f8
       3 phone_number = vc
       3 sequence = i4
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
       3 contact_method_code_value = f8
       3 contributor_system_code_value = f8
     2 aliases[*]
       3 action_flag = i2
       3 id = f8
       3 alias = vc
       3 alias_pool_code_value = f8
       3 alias_type_code_value = f8
     2 health_plans[*]
       3 action_flag = i2
       3 id = f8
       3 org_plan_reltn_code_value = f8
       3 group_number = vc
       3 group_name = vc
     2 revelate_required_fields = gvc
 )
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 organizations[*]
      2 id = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET child_phone
 RECORD child_phone(
   1 phones[*]
     2 org_index = i4
     2 phone_index = i4
     2 prsnl_reltn_id = f8
     2 person_id = f8
     2 phone_id = f8
 )
 FREE SET child_add
 RECORD child_add(
   01 address[*]
     02 address_id = f8
     02 org_index = i4
     02 add_index = i4
     02 state_disp = vc
     02 county = vc
     02 country = vc
     02 prsnl_reltn_id = f8
 )
 IF ( NOT (validate(reqorgtorccloudsync,0)))
  RECORD reqorgtorccloudsync(
    1 orglist[*]
      2 action_flag = i2
      2 organization_id = f8
      2 revelate_required_fields = gvc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reporgtorccloudsync,0)))
  RECORD reporgtorccloudsync(
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET org_id = 0.0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SET auth_cd = 0.0
 SET org_class_cd = 0.0
 SET sponsor_cd = 0.0
 DECLARE state_display = vc
 DECLARE county_display = vc
 DECLARE country_display = vc
 DECLARE rccloudindex = i4 WITH protect, noconstant(0)
 DECLARE beho_failed = vc WITH protect, noconstant("N")
 DECLARE ispayerfeatureenabled = i2 WITH protect, noconstant(false)
 DECLARE system_identifier_feature_toggle_key = vc WITH protect, constant("urn:cerner:revelate")
 DECLARE revelate_enable_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":enable"))
 DECLARE payer_mf_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":payer-master-file"))
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=370
   AND c.cdf_meaning="SPONSOR"
  DETAIL
   sponsor_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="INACTIVE"
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=396
   AND c.cdf_meaning="ORG"
  DETAIL
   org_class_cd = c.code_value
  WITH nocounter
 ;end select
 SET ispayerfeatureenabled = isfeaturetoggleenabled(revelate_enable_feature_toggle_key,
  payer_mf_feature_toggle_key,system_identifier_feature_toggle_key)
 IF ( NOT (ispayerfeatureenabled))
  CALL logdebugmessage("main",build2("Feature Toggle disabled for one or both Keys: ",
    revelate_enable_feature_toggle_key," and ",payer_mf_feature_toggle_key))
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET first_prg_exists_ind = 0
  SET first_prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  SET second_prg_exists_ind = 0
  SET second_prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (first_prg_exists_ind > 0
   AND second_prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
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
    SET acm_get_curr_logical_domain_req->concept = 3
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 5
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 FOR (x = 1 TO size(request->organizations,5))
   IF ((request->organizations[x].action_flag != 1))
    SET org_id = request->organizations[x].id
    IF (org_id=0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->organizations[x].action_flag=1))
    DECLARE org_parse = vc
    SET org_parse = "o.org_name_key = cnvtupper(cnvtalphanum(request->organizations[x].name))"
    IF (data_partition_ind=1)
     IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
      SET org_parse = concat(org_parse," and o.logical_domain_id in (")
      FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
        IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
         SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
          logical_domain_id,")")
        ELSE
         SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
          logical_domain_id,",")
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM organization o
     WHERE parser(org_parse)
      AND o.data_status_cd=auth_cd
      AND o.active_ind=1
     DETAIL
      org_id = o.organization_id
     WITH nocounter
    ;end select
    IF (org_id > 0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     j = seq(organization_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      org_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET ierrcode = 0
    IF (data_partition_ind=1)
     INSERT  FROM organization o
      SET o.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, o.organization_id
        = org_id, o.contributor_system_cd = 0,
       o.org_name = trim(request->organizations[x].name), o.org_name_key = cnvtupper(cnvtalphanum(
         request->organizations[x].name)), o.federal_tax_id_nbr = "",
       o.org_status_cd = 0, o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd,
       o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o.data_status_prsnl_id = reqinfo->
       updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.active_ind = 1, o.active_status_cd =
       active_cd,
       o.active_status_prsnl_id = reqinfo->updt_id, o.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.updt_id = reqinfo->updt_id,
       o.updt_task = reqinfo->updt_task, o.ft_entity_id = 0
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM organization o
      SET o.organization_id = org_id, o.contributor_system_cd = 0, o.org_name = trim(request->
        organizations[x].name),
       o.org_name_key = cnvtupper(cnvtalphanum(request->organizations[x].name)), o.federal_tax_id_nbr
        = "", o.org_status_cd = 0,
       o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       o.data_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       o.active_ind = 1, o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id,
       o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), o.updt_applctx = reqinfo->updt_applctx,
       o.updt_cnt = 0, o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task,
       o.ft_entity_id = 0
      WITH nocounter
     ;end insert
    ENDIF
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
   ELSEIF ((request->organizations[x].action_flag=2))
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.org_name_key=cnvtupper(cnvtalphanum(request->organizations[x].name))
       AND o.organization_id != org_id
       AND o.data_status_cd=auth_cd
       AND o.active_ind=1
       AND (o.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM organization o
     SET o.org_name = trim(request->organizations[x].name), o.org_name_key = cnvtupper(cnvtalphanum(
        request->organizations[x].name)), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      o.active_ind = 1, o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id,
      o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), o.updt_applctx = reqinfo->updt_applctx,
      o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task
     PLAN (o
      WHERE o.organization_id=org_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
   ELSEIF ((request->organizations[x].action_flag=3))
    SET ierrcode = 0
    UPDATE  FROM organization o
     SET o.active_ind = 0, o.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task,
      o.updt_applctx = reqinfo->updt_applctx
     PLAN (o
      WHERE o.organization_id=org_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET beho_failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   FOR (y = 1 TO size(request->organizations[x].org_types,5))
     IF ((request->organizations[x].org_types[y].action_flag=1))
      SELECT INTO "nl:"
       FROM org_type_reltn otr
       PLAN (otr
        WHERE (otr.org_type_cd=request->organizations[x].org_types[y].code_value)
         AND otr.organization_id=org_id
         AND otr.active_ind=0)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       UPDATE  FROM org_type_reltn otr
        SET otr.updt_id = reqinfo->updt_id, otr.updt_cnt = 0, otr.updt_applctx = reqinfo->
         updt_applctx,
         otr.updt_task = reqinfo->updt_task, otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr
         .active_ind = 1,
         otr.active_status_cd = active_cd
        PLAN (otr
         WHERE (otr.org_type_cd=request->organizations[x].org_types[y].code_value)
          AND otr.organization_id=org_id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       INSERT  FROM org_type_reltn otr
        SET otr.organization_id = org_id, otr.org_type_cd = request->organizations[x].org_types[y].
         code_value, otr.updt_id = reqinfo->updt_id,
         otr.updt_cnt = 0, otr.updt_applctx = reqinfo->updt_applctx, otr.updt_task = reqinfo->
         updt_task,
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_ind = 1, otr.active_status_cd =
         active_cd,
         otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id =
         reqinfo->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->organizations[x].org_types[y].action_flag=3))
      SET ierrcode = 0
      DELETE  FROM org_type_reltn otr
       WHERE (otr.org_type_cd=request->organizations[x].org_types[y].code_value)
        AND otr.organization_id=org_id
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->organizations[x].addresses,5))
     SET state_display = " "
     IF ((request->organizations[x].addresses[y].state_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->organizations[x].addresses[y].state_code_value)
        AND cv.active_ind=1
       DETAIL
        state_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET county_display = " "
     IF ((request->organizations[x].addresses[y].county_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->organizations[x].addresses[y].county_code_value)
        AND cv.active_ind=1
       DETAIL
        county_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     SET country_display = " "
     IF ((request->organizations[x].addresses[y].country_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->organizations[x].addresses[y].country_code_value)
        AND cv.active_ind=1
       DETAIL
        country_display = cv.display
       WITH nocounter
      ;end select
     ENDIF
     IF ((request->organizations[x].addresses[y].action_flag=1))
      SET ierrcode = 0
      INSERT  FROM address a
       SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORGANIZATION", a
        .parent_entity_id = org_id,
        a.address_type_cd = request->organizations[x].addresses[y].address_type_code_value, a.updt_id
         = reqinfo->updt_id, a.updt_cnt = 0,
        a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        a.street_addr = request->organizations[x].addresses[y].street_addr1, a.street_addr2 = request
        ->organizations[x].addresses[y].street_addr2, a.street_addr3 = request->organizations[x].
        addresses[y].street_addr3,
        a.street_addr4 = request->organizations[x].addresses[y].street_addr4, a.address_type_seq =
        request->organizations[x].addresses[y].sequence, a.city = request->organizations[x].
        addresses[y].city,
        a.state = state_display, a.state_cd = request->organizations[x].addresses[y].state_code_value,
        a.zipcode = request->organizations[x].addresses[y].zipcode,
        a.zipcode_key = cnvtupper(cnvtalphanum(request->organizations[x].addresses[y].zipcode)), a
        .county = county_display, a.county_cd = request->organizations[x].addresses[y].
        county_code_value,
        a.country = country_display, a.country_cd = request->organizations[x].addresses[y].
        country_code_value, a.contact_name = request->organizations[x].addresses[y].contact_name,
        a.comment_txt = request->organizations[x].addresses[y].comment_txt, a.postal_barcode_info =
        " ", a.mail_stop = " ",
        a.operation_hours = " ", a.data_status_cd = auth_cd, a.data_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        a.data_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].addresses[y].action_flag=2))
      SET ierrcode = 0
      UPDATE  FROM address a
       SET a.address_type_cd = request->organizations[x].addresses[y].address_type_code_value, a
        .street_addr = request->organizations[x].addresses[y].street_addr1, a.street_addr2 = request
        ->organizations[x].addresses[y].street_addr2,
        a.street_addr3 = request->organizations[x].addresses[y].street_addr3, a.street_addr4 =
        request->organizations[x].addresses[y].street_addr4, a.city = request->organizations[x].
        addresses[y].city,
        a.state = state_display, a.state_cd = request->organizations[x].addresses[y].state_code_value,
        a.zipcode = request->organizations[x].addresses[y].zipcode,
        a.zipcode_key = cnvtupper(cnvtalphanum(request->organizations[x].addresses[y].zipcode)), a
        .county = county_display, a.county_cd = request->organizations[x].addresses[y].
        county_code_value,
        a.address_type_seq = request->organizations[x].addresses[y].sequence, a.country =
        country_display, a.country_cd = request->organizations[x].addresses[y].country_code_value,
        a.contact_name = request->organizations[x].addresses[y].contact_name, a.comment_txt = request
        ->organizations[x].addresses[y].comment_txt, a.updt_cnt = (a.updt_cnt+ 1),
        a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
        updt_applctx,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (a
        WHERE (a.address_id=request->organizations[x].addresses[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].addresses[y].action_flag=3))
      SET ierrcode = 0
      UPDATE  FROM address a
       SET a.active_ind = 0, a.active_status_cd = inactive_cd, a.updt_cnt = (a.updt_cnt+ 1),
        a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
        updt_applctx,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (a
        WHERE (a.address_id=request->organizations[x].addresses[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->organizations[x].phones,5))
     IF ((request->organizations[x].phones[y].action_flag=1))
      SET ierrcode = 0
      IF ((request->organizations[x].phones[y].sequence IN (null, 0)))
       SET request->organizations[x].phones[y].sequence = 1
      ENDIF
      SET contact_method_cd = 0.0
      IF (validate(request->organizations[x].phones[y].contact_method_code_value))
       SET contact_method_cd = request->organizations[x].phones[y].contact_method_code_value
      ENDIF
      SET contributor_system_cd = 0.0
      IF (validate(request->organizations[x].phones[y].contributor_system_code_value))
       SET contributor_system_cd = request->organizations[x].phones[y].contributor_system_code_value
      ENDIF
      INSERT  FROM phone p
       SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION", p
        .parent_entity_id = org_id,
        p.phone_type_cd = request->organizations[x].phones[y].phone_type_code_value, p
        .phone_format_cd = request->organizations[x].phones[y].phone_format_code_value, p.phone_num
         = trim(request->organizations[x].phones[y].phone_number),
        p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->organizations[x].phones[y].
           phone_number))), p.phone_type_seq = request->organizations[x].phones[y].sequence, p
        .description = trim(request->organizations[x].phones[y].description),
        p.contact = trim(request->organizations[x].phones[y].contact), p.call_instruction = trim(
         request->organizations[x].phones[y].call_instruction), p.extension = trim(request->
         organizations[x].phones[y].extension),
        p.paging_code = trim(request->organizations[x].phones[y].paging_code), p.contact_method_cd =
        contact_method_cd, p.contributor_system_cd = contributor_system_cd,
        p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
        p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind
         = 1,
        p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
        .active_status_prsnl_id = reqinfo->updt_id,
        p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100"), p.data_status_cd = auth_cd,
        p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->
        updt_id
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].phones[y].action_flag=2))
      SET ierrcode = 0
      SET contact_method_cd = 0.0
      IF (validate(request->organizations[x].phones[y].contact_method_code_value))
       SET contact_method_cd = request->organizations[x].phones[y].contact_method_code_value
      ENDIF
      UPDATE  FROM phone p
       SET p.phone_type_cd = request->organizations[x].phones[y].phone_type_code_value, p
        .phone_format_cd = request->organizations[x].phones[y].phone_format_code_value, p.phone_num
         = trim(request->organizations[x].phones[y].phone_number),
        p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->organizations[x].phones[y].
           phone_number))), p.phone_type_seq = request->organizations[x].phones[y].sequence, p
        .description = trim(request->organizations[x].phones[y].description),
        p.contact = trim(request->organizations[x].phones[y].contact), p.call_instruction = trim(
         request->organizations[x].phones[y].call_instruction), p.extension = trim(request->
         organizations[x].phones[y].extension),
        p.paging_code = trim(request->organizations[x].phones[y].paging_code), p.contact_method_cd =
        contact_method_cd, p.updt_cnt = (p.updt_cnt+ 1),
        p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
        updt_applctx,
        p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (p
        WHERE (p.phone_id=request->organizations[x].phones[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].phones[y].action_flag=3))
      SET ierrcode = 0
      UPDATE  FROM phone p
       SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.end_effective_dt_tm = cnvtdatetime(
         curdate,curtime),
        p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (p
        WHERE (p.phone_id=request->organizations[x].phones[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->organizations[x].aliases,5))
     IF ((request->organizations[x].aliases[y].action_flag=1))
      SELECT INTO "nl:"
       FROM organization_alias oa
       PLAN (oa
        WHERE oa.organization_id=org_id
         AND (oa.alias_pool_cd=request->organizations[x].aliases[y].alias_pool_code_value)
         AND (oa.org_alias_type_cd=request->organizations[x].aliases[y].alias_type_code_value)
         AND oa.alias_key=cnvtupper(cnvtalphanum(request->organizations[x].aliases[y].alias))
         AND oa.active_ind=0)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET ierrcode = 0
       UPDATE  FROM organization_alias oa
        SET oa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), oa.active_ind = 1, oa
         .active_status_cd = active_cd,
         oa.updt_dt_tm = cnvtdatetime(curdate,curtime3), oa.updt_applctx = reqinfo->updt_applctx, oa
         .updt_cnt = (oa.updt_cnt+ 1),
         oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task
        PLAN (oa
         WHERE oa.organization_id=org_id
          AND (oa.alias_pool_cd=request->organizations[x].aliases[y].alias_pool_code_value)
          AND (oa.org_alias_type_cd=request->organizations[x].aliases[y].alias_type_code_value)
          AND oa.alias_key=cnvtupper(cnvtalphanum(request->organizations[x].aliases[y].alias)))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       INSERT  FROM organization_alias oa
        SET oa.organization_alias_id = seq(organization_seq,nextval), oa.organization_id = org_id, oa
         .alias_pool_cd = request->organizations[x].aliases[y].alias_pool_code_value,
         oa.org_alias_type_cd = request->organizations[x].aliases[y].alias_type_code_value, oa.alias
          = trim(request->organizations[x].aliases[y].alias), oa.alias_key = cnvtupper(cnvtalphanum(
           request->organizations[x].aliases[y].alias)),
         oa.alias_key_nls = null, oa.check_digit = null, oa.org_alias_sub_type_cd = 0,
         oa.contributor_system_cd = 0, oa.data_status_cd = auth_cd, oa.data_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         oa.data_status_prsnl_id = reqinfo->updt_id, oa.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), oa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         oa.active_ind = 1, oa.active_status_cd = active_cd, oa.active_status_prsnl_id = reqinfo->
         updt_id,
         oa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oa.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), oa.updt_applctx = reqinfo->updt_applctx,
         oa.updt_cnt = 0, oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->organizations[x].aliases[y].action_flag=2))
      SET ierrcode = 0
      UPDATE  FROM organization_alias oa
       SET oa.alias_pool_cd = request->organizations[x].aliases[y].alias_pool_code_value, oa
        .org_alias_type_cd = request->organizations[x].aliases[y].alias_type_code_value, oa.alias =
        trim(request->organizations[x].aliases[y].alias),
        oa.alias_key = cnvtupper(cnvtalphanum(request->organizations[x].aliases[y].alias)), oa
        .updt_dt_tm = cnvtdatetime(curdate,curtime3), oa.updt_applctx = reqinfo->updt_applctx,
        oa.updt_cnt = (oa.updt_cnt+ 1), oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->
        updt_task
       PLAN (oa
        WHERE (oa.organization_alias_id=request->organizations[x].aliases[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSEIF ((request->organizations[x].aliases[y].action_flag=3))
      SET ierrcode = 0
      UPDATE  FROM organization_alias oa
       SET oa.active_ind = 0, oa.active_status_cd = inactive_cd, oa.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime),
        oa.updt_dt_tm = cnvtdatetime(curdate,curtime3), oa.updt_applctx = reqinfo->updt_applctx, oa
        .updt_cnt = (oa.updt_cnt+ 1),
        oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task
       PLAN (oa
        WHERE (oa.organization_alias_id=request->organizations[x].aliases[y].id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   DECLARE opr_id = f8 WITH protect, noconstant(0)
   FOR (y = 1 TO size(request->organizations[x].health_plans,5))
    SET opr_id = 0.0
    IF ((request->organizations[x].health_plans[y].action_flag=1))
     SELECT INTO "nl:"
      FROM org_plan_reltn opr
      PLAN (opr
       WHERE opr.organization_id=org_id
        AND (opr.health_plan_id=request->organizations[x].health_plans[y].id)
        AND (opr.org_plan_reltn_cd=request->organizations[x].health_plans[y].
       org_plan_reltn_code_value)
        AND opr.active_ind=0)
      DETAIL
       opr_id = opr.org_plan_reltn_id
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET ierrcode = 0
      UPDATE  FROM org_plan_reltn opr
       SET opr.group_nbr = request->organizations[x].health_plans[y].group_number, opr.group_name =
        request->organizations[x].health_plans[y].group_name, opr.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id =
        reqinfo->updt_id,
        opr.updt_task = reqinfo->updt_task, opr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        opr.active_ind = 1,
        opr.active_status_cd = active_cd
       PLAN (opr
        WHERE opr.organization_id=org_id
         AND (opr.health_plan_id=request->organizations[x].health_plans[y].id)
         AND (opr.org_plan_reltn_cd=request->organizations[x].health_plans[y].
        org_plan_reltn_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ELSE
      SELECT INTO "nl:"
       j = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        opr_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET ierrcode = 0
      INSERT  FROM org_plan_reltn opr
       SET opr.org_plan_reltn_id = opr_id, opr.health_plan_id = request->organizations[x].
        health_plans[y].id, opr.organization_id = org_id,
        opr.org_plan_reltn_cd = request->organizations[x].health_plans[y].org_plan_reltn_code_value,
        opr.group_nbr = request->organizations[x].health_plans[y].group_number, opr.group_name =
        request->organizations[x].health_plans[y].group_name,
        opr.policy_nbr = null, opr.contract_code = null, opr.contributor_system_cd = 0,
        opr.data_status_cd = auth_cd, opr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), opr
        .data_status_prsnl_id = reqinfo->updt_id,
        opr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), opr.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), opr.active_ind = 1,
        opr.active_status_cd = active_cd, opr.active_status_prsnl_id = reqinfo->updt_id, opr
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_applctx = reqinfo->updt_applctx,
        opr.updt_cnt = 0,
        opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET beho_failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     FREE SET addr
     RECORD addr(
       1 qual[*]
         2 address_type_cd = f8
         2 street_addr1 = vc
         2 street_addr2 = vc
         2 street_addr3 = vc
         2 street_addr4 = vc
         2 city = vc
         2 state = vc
         2 state_cd = f8
         2 address_type_seq = i4
         2 zipcode = vc
         2 zipcode_key = vc
         2 county = vc
         2 county_cd = f8
         2 country = vc
         2 country_cd = f8
         2 contact_name = vc
         2 comment_txt = vc
         2 postal_barcode_info = vc
         2 mail_stop = vc
         2 operation_hours = vc
     )
     FREE SET phone
     RECORD phone(
       1 qual[*]
         2 phone_type_cd = f8
         2 phone_format_cd = f8
         2 phone_num = vc
         2 phone_type_seq = i4
         2 description = vc
         2 contact = vc
         2 call_instruction = vc
         2 extension = vc
         2 paging_code = vc
     )
     IF ((request->organizations[x].health_plans[y].org_plan_reltn_code_value=sponsor_cd))
      SELECT INTO "nl:"
       FROM address a
       PLAN (a
        WHERE a.parent_entity_id=org_id
         AND a.parent_entity_name="ORGANIZATION"
         AND a.active_ind=1)
       HEAD REPORT
        acnt = 0
       DETAIL
        acnt = (acnt+ 1), stat = alterlist(addr->qual,acnt), addr->qual[acnt].address_type_cd = a
        .address_type_cd,
        addr->qual[acnt].street_addr1 = a.street_addr, addr->qual[acnt].street_addr2 = a.street_addr2,
        addr->qual[acnt].street_addr3 = a.street_addr3,
        addr->qual[acnt].street_addr4 = a.street_addr4, addr->qual[acnt].city = a.city, addr->qual[
        acnt].state_cd = a.state_cd,
        addr->qual[acnt].address_type_seq = a.address_type_seq, addr->qual[acnt].state = a.state,
        addr->qual[acnt].zipcode = a.zipcode,
        addr->qual[acnt].zipcode_key = a.zipcode_key, addr->qual[acnt].county_cd = a.county_cd, addr
        ->qual[acnt].county = a.county,
        addr->qual[acnt].country_cd = a.country_cd, addr->qual[acnt].country = a.country, addr->qual[
        acnt].contact_name = a.contact_name,
        addr->qual[acnt].comment_txt = a.comment_txt, addr->qual[acnt].postal_barcode_info = a
        .postal_barcode_info, addr->qual[acnt].mail_stop = a.mail_stop,
        addr->qual[acnt].operation_hours = a.operation_hours
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM phone p
       PLAN (p
        WHERE p.parent_entity_id=org_id
         AND p.parent_entity_name="ORGANIZATION"
         AND p.active_ind=1)
       HEAD REPORT
        pcnt = 0
       DETAIL
        pcnt = (pcnt+ 1), stat = alterlist(phone->qual,pcnt), phone->qual[pcnt].phone_type_cd = p
        .phone_type_cd,
        phone->qual[pcnt].phone_format_cd = p.phone_format_cd, phone->qual[pcnt].phone_num = p
        .phone_num, phone->qual[pcnt].phone_type_seq = p.phone_type_seq,
        phone->qual[pcnt].description = p.description, phone->qual[pcnt].contact = p.contact, phone->
        qual[pcnt].call_instruction = p.call_instruction,
        phone->qual[pcnt].extension = p.extension, phone->qual[pcnt].paging_code = p.paging_code
       WITH nocounter
      ;end select
      IF (size(addr->qual,5) > 0)
       SET ierrcode = 0
       INSERT  FROM (dummyt d  WITH seq = value(size(addr->qual,5))),
         address a
        SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORG_PLAN_RELTN", a
         .parent_entity_id = opr_id,
         a.address_type_cd = addr->qual[d.seq].address_type_cd, a.updt_id = reqinfo->updt_id, a
         .updt_cnt = 0,
         a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         a.street_addr = addr->qual[d.seq].street_addr1, a.street_addr2 = addr->qual[d.seq].
         street_addr2, a.street_addr3 = addr->qual[d.seq].street_addr3,
         a.street_addr4 = addr->qual[d.seq].street_addr4, a.address_type_seq = addr->qual[d.seq].
         address_type_seq, a.city = addr->qual[d.seq].city,
         a.state = addr->qual[d.seq].state, a.state_cd = addr->qual[d.seq].state_cd, a.zipcode = addr
         ->qual[d.seq].zipcode,
         a.zipcode_key = addr->qual[d.seq].zipcode_key, a.county = addr->qual[d.seq].county, a
         .county_cd = addr->qual[d.seq].county_cd,
         a.country = addr->qual[d.seq].country, a.country_cd = addr->qual[d.seq].country_cd, a
         .contact_name = addr->qual[d.seq].contact_name,
         a.comment_txt = addr->qual[d.seq].comment_txt, a.postal_barcode_info = addr->qual[d.seq].
         postal_barcode_info, a.mail_stop = addr->qual[d.seq].mail_stop,
         a.operation_hours = addr->qual[d.seq].operation_hours, a.data_status_cd = auth_cd, a
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         a.data_status_prsnl_id = reqinfo->updt_id
        PLAN (d)
         JOIN (a)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
      IF (size(phone->qual,5) > 0)
       SET ierrcode = 0
       INSERT  FROM (dummyt d  WITH seq = value(size(phone->qual,5))),
         phone p
        SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORG_PLAN_RELTN", p
         .parent_entity_id = opr_id,
         p.phone_type_cd = phone->qual[d.seq].phone_type_cd, p.phone_format_cd = phone->qual[d.seq].
         phone_format_cd, p.phone_num = phone->qual[d.seq].phone_num,
         p.phone_num_key = cnvtupper(cnvtalphanum(phone->qual[d.seq].phone_num)), p.phone_type_seq =
         phone->qual[d.seq].phone_type_seq, p.description = phone->qual[d.seq].description,
         p.contact = phone->qual[d.seq].contact, p.call_instruction = phone->qual[d.seq].
         call_instruction, p.extension = phone->qual[d.seq].extension,
         p.paging_code = phone->qual[d.seq].paging_code, p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
         p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
         .data_status_prsnl_id = reqinfo->updt_id
        PLAN (d)
         JOIN (p)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET beho_failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSEIF ((request->organizations[x].health_plans[y].action_flag=2))
     SET ierrcode = 0
     UPDATE  FROM org_plan_reltn opr
      SET opr.group_nbr = request->organizations[x].health_plans[y].group_number, opr.group_name =
       request->organizations[x].health_plans[y].group_name, opr.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id =
       reqinfo->updt_id,
       opr.updt_task = reqinfo->updt_task
      PLAN (opr
       WHERE opr.organization_id=org_id
        AND (opr.health_plan_id=request->organizations[x].health_plans[y].id)
        AND (opr.org_plan_reltn_cd=request->organizations[x].health_plans[y].
       org_plan_reltn_code_value))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET beho_failed = "Y"
      GO TO exit_script
     ENDIF
    ELSEIF ((request->organizations[x].health_plans[y].action_flag=3))
     SET ierrcode = 0
     UPDATE  FROM org_plan_reltn opr
      SET opr.active_ind = 0, opr.active_status_cd = inactive_cd, opr.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime),
       opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_applctx = reqinfo->updt_applctx, opr
       .updt_cnt = (opr.updt_cnt+ 1),
       opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->updt_task
      PLAN (opr
       WHERE opr.organization_id=org_id
        AND (opr.health_plan_id=request->organizations[x].health_plans[y].id)
        AND (opr.org_plan_reltn_cd=request->organizations[x].health_plans[y].
       org_plan_reltn_code_value))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET beho_failed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
   SET stat = alterlist(reply->organizations,x)
   SET reply->organizations[x].id = org_id
   IF (ispayerfeatureenabled
    AND beho_failed="N"
    AND (request->organizations[x].action_flag > 0))
    IF (validate(request->organizations[x].revelate_required_fields))
     IF ((request->organizations[x].revelate_required_fields != "")
      AND (request->organizations[x].revelate_required_fields != null))
      SET rccloudindex = (rccloudindex+ 1)
      SET stat = alterlist(reqorgtorccloudsync->orglist,rccloudindex)
      SET reqorgtorccloudsync->orglist[rccloudindex].action_flag = request->organizations[x].
      action_flag
      SET reqorgtorccloudsync->orglist[rccloudindex].organization_id = org_id
      SET reqorgtorccloudsync->orglist[rccloudindex].revelate_required_fields = request->
      organizations[x].revelate_required_fields
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET org_size = size(request->organizations,5)
 IF (org_size=0)
  GO TO exit_script
 ENDIF
 SET ptcnt = 0
 SET phone_reltn_type = uar_get_code_by("MEANING",30300,"PHONE")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(org_size)),
   (dummyt d2  WITH seq = 1),
   prsnl_reltn pr,
   prsnl p,
   prsnl_reltn_child prc,
   phone p2,
   prsnl_reltn_child prc2,
   phone p3
  PLAN (d
   WHERE maxrec(d2,size(request->organizations[d.seq].phones,5)))
   JOIN (d2
   WHERE (request->organizations[d.seq].phones[d2.seq].action_flag IN (2, 3)))
   JOIN (p2
   WHERE (p2.phone_id=request->organizations[d.seq].phones[d2.seq].id)
    AND p2.parent_entity_name="ORGANIZATION")
   JOIN (prc
   WHERE prc.parent_entity_id=p2.phone_id
    AND prc.parent_entity_name="PHONE"
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prsnl_reltn_id=prc.prsnl_reltn_id
    AND pr.reltn_type_cd=phone_reltn_type
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc2
   WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc2.parent_entity_name="PHONE"
    AND prc2.prsnl_reltn_child_id != prc.prsnl_reltn_child_id
    AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p3
   WHERE p3.phone_id=prc2.parent_entity_id
    AND p3.active_ind=1
    AND p3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p3.parent_entity_id=p.person_id
    AND p3.parent_entity_name="PERSON")
  ORDER BY p3.phone_id
  HEAD REPORT
   pcnt = 0, ptcnt = 0, stat = alterlist(child_phone->phones,100)
  HEAD p3.phone_id
   pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
   IF (pcnt > 100)
    stat = alterlist(child_phone->phones,(ptcnt+ 100)), pcnt = 1
   ENDIF
   child_phone->phones[ptcnt].org_index = d.seq, child_phone->phones[ptcnt].phone_index = d2.seq,
   child_phone->phones[ptcnt].person_id = p3.parent_entity_id,
   child_phone->phones[ptcnt].prsnl_reltn_id = prc2.prsnl_reltn_id, child_phone->phones[ptcnt].
   phone_id = p3.phone_id
  FOOT REPORT
   stat = alterlist(child_phone->phones,ptcnt)
  WITH nocounter
 ;end select
 IF (ptcnt > 0)
  SET ierrcode = 0
  UPDATE  FROM phone p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.phone_type_cd = request->organizations[child_phone->phones[d.seq].org_index].phones[
    child_phone->phones[d.seq].phone_index].phone_type_code_value, p.phone_format_cd = request->
    organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d.seq].phone_index
    ].phone_format_code_value, p.phone_num = request->organizations[child_phone->phones[d.seq].
    org_index].phones[child_phone->phones[d.seq].phone_index].phone_number,
    p.phone_num_key = cnvtupper(cnvtalphanum(request->organizations[child_phone->phones[d.seq].
      org_index].phones[child_phone->phones[d.seq].phone_index].phone_number)), p.description =
    request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d.seq].
    phone_index].description, p.contact = request->organizations[child_phone->phones[d.seq].org_index
    ].phones[child_phone->phones[d.seq].phone_index].contact,
    p.call_instruction = request->organizations[child_phone->phones[d.seq].org_index].phones[
    child_phone->phones[d.seq].phone_index].call_instruction, p.paging_code = request->organizations[
    child_phone->phones[d.seq].org_index].phones[child_phone->phones[d.seq].phone_index].paging_code,
    p.extension = request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->
    phones[d.seq].phone_index].extension,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d
    .seq].phone_index].action_flag=2))
    JOIN (p
    WHERE (p.phone_id=child_phone->phones[d.seq].phone_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error updating prsnl phones")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM phone p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.end_effective_dt_tm = cnvtdatetime(
     curdate,curtime),
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d
    .seq].phone_index].action_flag=3))
    JOIN (p
    WHERE (p.phone_id=child_phone->phones[d.seq].phone_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error inactivating prsnl phones")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.display_seq = 0, p.updt_id = reqinfo->updt_id,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d
    .seq].phone_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_phone->phones[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update prsnl_reltn rows.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p
    .updt_cnt = (p.updt_cnt+ 1),
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_phone->phones[d.seq].org_index].phones[child_phone->phones[d
    .seq].phone_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_phone->phones[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate prsnl_reltn_child rows2.")
   GO TO exit_script
  ENDIF
 ENDIF
 SET atcnt = 0
 SET add_reltn_type = uar_get_code_by("MEANING",30300,"ADDRESS")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(org_size)),
   (dummyt d2  WITH seq = 1),
   prsnl_reltn pr,
   prsnl p,
   prsnl_reltn_child prc,
   address a,
   prsnl_reltn_child prc2,
   address a2
  PLAN (d
   WHERE maxrec(d2,size(request->organizations[d.seq].addresses,5)))
   JOIN (d2
   WHERE (request->organizations[d.seq].addresses[d2.seq].action_flag IN (2, 3)))
   JOIN (a
   WHERE (a.address_id=request->organizations[d.seq].addresses[d2.seq].id)
    AND a.parent_entity_name="ORGANIZATION")
   JOIN (prc
   WHERE prc.parent_entity_id=a.address_id
    AND prc.parent_entity_name="ADDRESS"
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prsnl_reltn_id=prc.prsnl_reltn_id
    AND pr.reltn_type_cd=add_reltn_type
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc2
   WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc2.parent_entity_name="ADDRESS"
    AND prc2.prsnl_reltn_child_id != prc.prsnl_reltn_child_id
    AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a2
   WHERE a2.address_id=prc2.parent_entity_id
    AND a2.active_ind=1
    AND a2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND a2.parent_entity_id=p.person_id
    AND a2.parent_entity_name="PERSON")
  ORDER BY a2.address_id
  HEAD REPORT
   acnt = 0, atcnt = 0, stat = alterlist(child_add->address,100)
  HEAD a2.address_id
   acnt = (acnt+ 1), atcnt = (atcnt+ 1)
   IF (acnt > 100)
    stat = alterlist(child_add->address,(atcnt+ 100)), acnt = 1
   ENDIF
   child_add->address[atcnt].address_id = a2.address_id, child_add->address[atcnt].country = a
   .country, child_add->address[atcnt].county = a.county,
   child_add->address[atcnt].state_disp = a.state, child_add->address[atcnt].prsnl_reltn_id = prc2
   .prsnl_reltn_id
  FOOT REPORT
   stat = alterlist(child_add->address,(atcnt+ 100))
  WITH nocounter
 ;end select
 IF (atcnt > 0)
  SET ierrcode = 0
  UPDATE  FROM address a,
    (dummyt d  WITH seq = value(atcnt))
   SET a.street_addr = request->organizations[child_add->address[d.seq].org_index].addresses[
    child_add->address[d.seq].add_index].street_addr1, a.street_addr2 = request->organizations[
    child_add->address[d.seq].org_index].addresses[child_add->address[d.seq].add_index].street_addr2,
    a.street_addr3 = request->organizations[child_add->address[d.seq].org_index].addresses[child_add
    ->address[d.seq].add_index].street_addr3,
    a.street_addr4 = request->organizations[child_add->address[d.seq].org_index].addresses[child_add
    ->address[d.seq].add_index].street_addr4, a.city = request->organizations[child_add->address[d
    .seq].org_index].addresses[child_add->address[d.seq].add_index].city, a.address_type_seq =
    request->organizations[child_add->address[d.seq].org_index].addresses[child_add->address[d.seq].
    add_index].sequence,
    a.state = child_add->address[d.seq].state_disp, a.state_cd = request->organizations[child_add->
    address[d.seq].org_index].addresses[child_add->address[d.seq].add_index].state_code_value, a
    .zipcode = request->organizations[child_add->address[d.seq].org_index].addresses[child_add->
    address[d.seq].add_index].zipcode,
    a.zipcode_key = cnvtupper(cnvtalphanum(request->organizations[child_add->address[d.seq].org_index
      ].addresses[child_add->address[d.seq].add_index].zipcode)), a.county = child_add->address[d.seq
    ].county, a.county_cd = request->organizations[child_add->address[d.seq].org_index].addresses[
    child_add->address[d.seq].add_index].county_code_value,
    a.country = child_add->address[d.seq].country, a.country_cd = request->organizations[child_add->
    address[d.seq].org_index].addresses[child_add->address[d.seq].add_index].country_code_value, a
    .address_type_cd = request->organizations[child_add->address[d.seq].org_index].addresses[
    child_add->address[d.seq].add_index].address_type_code_value,
    a.contact_name = request->organizations[child_add->address[d.seq].org_index].addresses[child_add
    ->address[d.seq].add_index].contact_name, a.comment_txt = request->organizations[child_add->
    address[d.seq].org_index].addresses[child_add->address[d.seq].add_index].comment_txt, a.updt_cnt
     = (a.updt_cnt+ 1),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_add->address[d.seq].org_index].addresses[child_add->address[d
    .seq].add_index].action_flag=2))
    JOIN (a
    WHERE (a.address_id=child_add->address[d.seq].address_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update child addresses.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM address a,
    (dummyt d  WITH seq = value(atcnt))
   SET a.active_ind = 0, a.active_status_cd = inactive_cd, a.updt_cnt = (a.updt_cnt+ 1),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_add->address[d.seq].org_index].addresses[child_add->address[d
    .seq].add_index].action_flag=3))
    JOIN (a
    WHERE (a.address_id=child_add->address[d.seq].address_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate child addresses.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.display_seq = 0, p.updt_id = reqinfo->updt_id,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_add->address[d.seq].org_index].addresses[child_add->address[d
    .seq].add_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_add->address[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update prsnl_reltn rows.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p
    .updt_cnt = (p.updt_cnt+ 1),
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->organizations[child_add->address[d.seq].org_index].addresses[child_add->address[d
    .seq].add_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_add->address[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate prsnl_reltn_child rows2.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (ispayerfeatureenabled
  AND rccloudindex > 0)
  SET ierrcode = 0
  EXECUTE pft_bed_ens_org_hp  WITH replace("REQUEST",reqorgtorccloudsync), replace("REPLY",
   reporgtorccloudsync)
  SET ierrcode = error(serrmsg,1)
  IF (((ierrcode > 0) OR ((reporgtorccloudsync->status_data.status != "S"))) )
   SET beho_failed = "Y"
   SET error_flag = "Y"
   SET error_msg = concat(
    "Error when updating rc_cloud_sync table. Contact Patient Account for assistance.")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (((beho_failed="Y") OR (error_flag="Y")) )
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
