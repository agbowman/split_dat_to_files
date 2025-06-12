CREATE PROGRAM bed_ens_health_plan:dba
 IF ( NOT (validate(reqhptorccloudsync,0)))
  FREE SET reqhptorccloudsync
  RECORD reqhptorccloudsync(
    1 hplist[*]
      2 action_flag = i2
      2 health_plan_id = f8
      2 revelate_required_fields = gvc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(rephptorccloudsync,0)))
  FREE SET rephptorccloudsync
  RECORD rephptorccloudsync(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(timelyfilingrequest,0)))
  FREE SET timelyfilingrequest
  RECORD timelyfilingrequest(
    1 timely_filings[*]
      2 action_flag = i2
      2 health_plan_id = f8
      2 auto_release_days = i4
      2 limit_days = i4
      2 notify_days = i4
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 health_plans[*]
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
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE health_plan_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",397,"HEALTHPLAN"))
 DECLARE carrier_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",370,"CARRIER"))
 DECLARE carrier_rx_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",370,"CARRIER_RX"))
 DECLARE sponsor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",370,"SPONSOR"))
 DECLARE fhp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30620,"HEALTHPLAN"))
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE medical_service_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",27137,
   "MEDICAL"))
 DECLARE prescription_service_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",27137,
   "PRESCRIPTION"))
 DECLARE field_format_id = f8 WITH protect, noconstant(0.0)
 DECLARE plan_id = f8 WITH protect, noconstant(0.0)
 DECLARE state_display = vc WITH protect, noconstant("")
 DECLARE county_display = vc WITH protect, noconstant("")
 DECLARE country_display = vc WITH protect, noconstant("")
 DECLARE rccloudindex = i4 WITH protect, noconstant(0)
 DECLARE ishpfeatureenabled = i2 WITH protect, noconstant(false)
 DECLARE data_partition_ind = f8 WITH protect, noconstant(0.0)
 DECLARE field_found = f8 WITH protect, noconstant(0.0)
 DECLARE prg_exists_ind = f8 WITH protect, noconstant(0.0)
 DECLARE service_type_exists = f8 WITH protect, noconstant(0.0)
 DECLARE hcnt = f8 WITH protect, noconstant(0.0)
 DECLARE plan_category_exists = f8 WITH protect, noconstant(0.0)
 DECLARE service_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE plan_category_cd = f8 WITH protect, noconstant(0.0)
 DECLARE timelyfilingrowcount = f8 WITH protect, noconstant(0.0)
 DECLARE system_identifier_feature_toggle_key = vc WITH protect, constant("urn:cerner:revelate")
 DECLARE revelate_enable_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":enable"))
 DECLARE health_plan_mf_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":health-plan-master-file"))
 SET ishpfeatureenabled = isfeaturetoggleenabled(revelate_enable_feature_toggle_key,
  health_plan_mf_feature_toggle_key,system_identifier_feature_toggle_key)
 IF ( NOT (ishpfeatureenabled))
  CALL logdebugmessage("main",build2("Feature Toggle disabled for one or both Keys: ",
    revelate_enable_feature_toggle_key," and ",health_plan_mf_feature_toggle_key))
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF h IS health_plan
   SET field_found = validate(h.logical_domain_id)
   FREE RANGE h
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
 SET service_type_exists = 0
 SET hcnt = size(request->health_plans,5)
 IF (hcnt > 0)
  IF (validate(request->health_plans[1].service_type_code_value))
   SET service_type_exists = 1
  ENDIF
 ENDIF
 SET plan_category_exists = 0
 SET hcnt = size(request->health_plans,5)
 IF (hcnt > 0)
  IF (validate(request->health_plans[1].plan_category_code_value))
   SET plan_category_exists = 1
  ENDIF
 ENDIF
 FOR (x = 1 TO size(request->health_plans,5))
   IF ((request->health_plans[x].action_flag != 1))
    SET plan_id = request->health_plans[x].plan_id
    IF (plan_id=0)
     GO TO exit_script
    ENDIF
   ENDIF
   SET service_type_cd = 0.0
   IF (service_type_exists=1)
    SET service_type_cd = request->health_plans[x].service_type_code_value
   ENDIF
   SET plan_category_cd = 0.0
   IF (plan_category_exists=1)
    SET plan_category_cd = request->health_plans[x].plan_category_code_value
   ENDIF
   IF ((request->health_plans[x].action_flag=1))
    SELECT INTO "nl:"
     j = seq(health_plan_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      plan_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL bederrorcheck("ERROR 001: Generating new health_plan_id failed")
    IF (data_partition_ind=1)
     INSERT  FROM health_plan hp
      SET hp.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, hp
       .health_plan_id = plan_id, hp.contributor_system_cd = 0,
       hp.plan_name = trim(request->health_plans[x].plan_name), hp.plan_name_key = cnvtupper(
        cnvtalphanum(request->health_plans[x].plan_name)), hp.plan_desc = trim(request->health_plans[
        x].plan_desc),
       hp.classification_cd = request->health_plans[x].classification_code_value, hp.plan_type_cd =
       request->health_plans[x].plan_type_code_value, hp.financial_class_cd = request->health_plans[x
       ].financial_class_code_value,
       hp.plan_class_cd = health_plan_cd, hp.ft_entity_name = null, hp.ft_entity_id = 0,
       hp.baby_coverage_cd = 0, hp.comb_baby_bill_cd = 0, hp.group_nbr = null,
       hp.group_name = null, hp.policy_nbr = null, hp.plan_name_key_nls = null,
       hp.pat_bill_pref_flag = 0, hp.pri_concurrent_ind = 0, hp.sec_concurrent_ind = 0,
       hp.product_cd = 0, hp.data_status_cd = auth_cd, hp.data_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       hp.data_status_prsnl_id = reqinfo->updt_id, hp.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), hp.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       hp.active_ind = 1, hp.active_status_cd = active_cd, hp.active_status_prsnl_id = reqinfo->
       updt_id,
       hp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), hp.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), hp.updt_applctx = reqinfo->updt_applctx,
       hp.updt_cnt = 0, hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->updt_task,
       hp.service_type_cd = service_type_cd, hp.plan_category_cd = plan_category_cd, hp
       .consumer_add_covrg_allow_ind = evaluate(request->health_plans[x].consumer_add_covrg_allow_ind,
        - (1),null,request->health_plans[x].consumer_add_covrg_allow_ind),
       hp.consumer_modify_covrg_deny_ind = evaluate(request->health_plans[x].
        consumer_modify_covrg_deny_ind,- (1),null,request->health_plans[x].
        consumer_modify_covrg_deny_ind), hp.priority_ranking_nbr = evaluate(request->health_plans[x].
        priority_ranking_nbr_null_ind,1,null,request->health_plans[x].priority_ranking_nbr)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ERROR 002: health_plan table insertion failed")
    ELSE
     INSERT  FROM health_plan hp
      SET hp.health_plan_id = plan_id, hp.contributor_system_cd = 0, hp.plan_name = trim(request->
        health_plans[x].plan_name),
       hp.plan_name_key = cnvtupper(cnvtalphanum(request->health_plans[x].plan_name)), hp.plan_desc
        = trim(request->health_plans[x].plan_desc), hp.classification_cd = request->health_plans[x].
       classification_code_value,
       hp.plan_type_cd = request->health_plans[x].plan_type_code_value, hp.financial_class_cd =
       request->health_plans[x].financial_class_code_value, hp.plan_class_cd = health_plan_cd,
       hp.ft_entity_name = null, hp.ft_entity_id = 0, hp.baby_coverage_cd = 0,
       hp.comb_baby_bill_cd = 0, hp.group_nbr = null, hp.group_name = null,
       hp.policy_nbr = null, hp.plan_name_key_nls = null, hp.pat_bill_pref_flag = 0,
       hp.pri_concurrent_ind = 0, hp.sec_concurrent_ind = 0, hp.product_cd = 0,
       hp.data_status_cd = auth_cd, hp.data_status_dt_tm = cnvtdatetime(curdate,curtime3), hp
       .data_status_prsnl_id = reqinfo->updt_id,
       hp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), hp.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), hp.active_ind = 1,
       hp.active_status_cd = active_cd, hp.active_status_prsnl_id = reqinfo->updt_id, hp
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       hp.updt_dt_tm = cnvtdatetime(curdate,curtime3), hp.updt_applctx = reqinfo->updt_applctx, hp
       .updt_cnt = 0,
       hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->updt_task, hp.service_type_cd =
       service_type_cd,
       hp.plan_category_cd = plan_category_cd, hp.consumer_add_covrg_allow_ind = evaluate(request->
        health_plans[x].consumer_add_covrg_allow_ind,- (1),null,request->health_plans[x].
        consumer_add_covrg_allow_ind), hp.consumer_modify_covrg_deny_ind = evaluate(request->
        health_plans[x].consumer_modify_covrg_deny_ind,- (1),null,request->health_plans[x].
        consumer_modify_covrg_deny_ind),
       hp.priority_ranking_nbr = evaluate(request->health_plans[x].priority_ranking_nbr_null_ind,1,
        null,request->health_plans[x].priority_ranking_nbr)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ERROR 003:health_plan table insertion failed")
    ENDIF
   ELSEIF ((request->health_plans[x].action_flag=2))
    IF ((request->health_plans[x].set_end_effective=1))
     UPDATE  FROM health_plan hp
      SET hp.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), hp.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), hp.updt_applctx = reqinfo->updt_applctx,
       hp.updt_cnt = (hp.updt_cnt+ 1), hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->
       updt_task
      PLAN (hp
       WHERE hp.health_plan_id=plan_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR 004:health_plan table updation failed")
    ELSE
     UPDATE  FROM health_plan hp
      SET hp.plan_name = trim(request->health_plans[x].plan_name), hp.plan_name_key = cnvtupper(
        cnvtalphanum(request->health_plans[x].plan_name)), hp.plan_desc = trim(request->health_plans[
        x].plan_desc),
       hp.classification_cd = request->health_plans[x].classification_code_value, hp.plan_type_cd =
       request->health_plans[x].plan_type_code_value, hp.financial_class_cd = request->health_plans[x
       ].financial_class_code_value,
       hp.plan_category_cd = plan_category_cd, hp.updt_dt_tm = cnvtdatetime(curdate,curtime3), hp
       .updt_applctx = reqinfo->updt_applctx,
       hp.updt_cnt = (hp.updt_cnt+ 1), hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->
       updt_task,
       hp.service_type_cd = service_type_cd, hp.consumer_add_covrg_allow_ind = evaluate(request->
        health_plans[x].consumer_add_covrg_allow_ind,- (1),null,request->health_plans[x].
        consumer_add_covrg_allow_ind), hp.consumer_modify_covrg_deny_ind = evaluate(request->
        health_plans[x].consumer_modify_covrg_deny_ind,- (1),null,request->health_plans[x].
        consumer_modify_covrg_deny_ind),
       hp.priority_ranking_nbr = evaluate(request->health_plans[x].priority_ranking_nbr_null_ind,1,
        null,request->health_plans[x].priority_ranking_nbr)
      PLAN (hp
       WHERE hp.health_plan_id=plan_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR 005:health_plan table updation failed")
     IF (service_type_cd=medical_service_type_cd
      AND size(request->health_plans[x].org_plans,5)=0)
      UPDATE  FROM org_plan_reltn opr
       SET opr.org_plan_reltn_cd = carrier_cd, opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr
        .updt_applctx = reqinfo->updt_applctx,
        opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->
        updt_task
       PLAN (opr
        WHERE opr.org_plan_reltn_cd=carrier_rx_cd
         AND opr.health_plan_id=plan_id
         AND opr.active_ind=1)
       WITH nocounter
      ;end update
      CALL bederrorcheck(
       "ERROR 006:org_plan_reltn table updation failed (failed to update carrier_cd)")
     ELSEIF (service_type_cd=prescription_service_type_cd
      AND size(request->health_plans[x].org_plans,5)=0)
      UPDATE  FROM org_plan_reltn opr
       SET opr.org_plan_reltn_cd = carrier_rx_cd, opr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        opr.updt_applctx = reqinfo->updt_applctx,
        opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->
        updt_task
       PLAN (opr
        WHERE opr.org_plan_reltn_cd=carrier_cd
         AND opr.health_plan_id=plan_id
         AND opr.active_ind=1)
       WITH nocounter
      ;end update
      CALL bederrorcheck(
       "ERROR 007:org_plan_reltn table updation failed (failed to update carrier_rx_cd)")
     ENDIF
    ENDIF
   ELSEIF ((request->health_plans[x].action_flag=3))
    UPDATE  FROM health_plan hp
     SET hp.active_ind = 0, hp.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), hp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      hp.updt_cnt = (hp.updt_cnt+ 1), hp.updt_id = reqinfo->updt_id, hp.updt_task = reqinfo->
      updt_task,
      hp.updt_applctx = reqinfo->updt_applctx
     PLAN (hp
      WHERE hp.health_plan_id=plan_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ERROR 008:health_plan table updation failed")
    UPDATE  FROM health_plan_alias hpa
     SET hpa.active_ind = 0, hpa.active_status_cd = inactive_cd, hpa.end_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_applctx = reqinfo->updt_applctx, hpa
      .updt_cnt = (hpa.updt_cnt+ 1),
      hpa.updt_id = reqinfo->updt_id, hpa.updt_task = reqinfo->updt_task
     PLAN (hpa
      WHERE hpa.health_plan_id=plan_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ERROR 022:health_plan_alias table update failed")
   ENDIF
   DECLARE existing_timely_filing_days = i4
   DECLARE existing_auto_claims = i4
   DECLARE existing_notify_days = i4
   IF ((request->health_plans[x].timely_filing_action_flag=2))
    SELECT INTO "nl:"
     FROM health_plan_timely_filing hptf
     PLAN (hptf
      WHERE (hptf.health_plan_id=request->health_plans[x].plan_id))
     DETAIL
      existing_timely_filing_days = hptf.limit_days, existing_auto_claims = hptf.auto_release_days,
      existing_notify_days = hptf.notify_days
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 040: health_plan_timely_filing table select failed.")
    IF (curqual=1)
     IF ((request->health_plans[x].timely_filing_days=0)
      AND (request->health_plans[x].auto_release_claims=0)
      AND (request->health_plans[x].timely_filing_notification=0))
      SET request->health_plans[x].timely_filing_action_flag = 3
     ELSE
      SET request->health_plans[x].timely_filing_action_flag = 2
     ENDIF
    ELSE
     IF ((request->health_plans[x].timely_filing_days=0)
      AND (request->health_plans[x].auto_release_claims=0)
      AND (request->health_plans[x].timely_filing_notification=0))
      SET request->health_plans[x].timely_filing_action_flag = 0
     ELSE
      SET request->health_plans[x].timely_filing_action_flag = 1
     ENDIF
    ENDIF
   ENDIF
   CALL bederrorcheck("Error 041:Error finding the timely filing action flag.")
   SET timelyfilingrowcount = (size(timelyfilingrequest->timely_filings,5)+ 1)
   IF ((request->health_plans[x].timely_filing_action_flag > 0))
    SET stat = alterlist(timelyfilingrequest->timely_filings,timelyfilingrowcount)
    SET timelyfilingrequest->timely_filings[timelyfilingrowcount].action_flag = request->
    health_plans[x].timely_filing_action_flag
    IF ((request->health_plans[x].action_flag=1)
     AND (request->health_plans[x].timely_filing_action_flag=1))
     SET timelyfilingrequest->timely_filings[timelyfilingrowcount].health_plan_id = plan_id
    ELSE
     SET timelyfilingrequest->timely_filings[timelyfilingrowcount].health_plan_id = request->
     health_plans[x].plan_id
    ENDIF
    SET timelyfilingrequest->timely_filings[timelyfilingrowcount].limit_days = request->health_plans[
    x].timely_filing_days
    SET timelyfilingrequest->timely_filings[timelyfilingrowcount].auto_release_days = request->
    health_plans[x].auto_release_claims
    SET timelyfilingrequest->timely_filings[timelyfilingrowcount].notify_days = request->
    health_plans[x].timely_filing_notification
   ENDIF
   FOR (y = 1 TO size(request->health_plans[x].addresses,5))
     SET state_display = " "
     IF ((request->health_plans[x].addresses[y].state_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->health_plans[x].addresses[y].state_code_value)
        AND cv.active_ind=1
       DETAIL
        state_display = cv.display
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 009:code_value table select failed")
     ENDIF
     SET county_display = " "
     IF ((request->health_plans[x].addresses[y].county_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->health_plans[x].addresses[y].county_code_value)
        AND cv.active_ind=1
       DETAIL
        county_display = cv.display
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 010:code_value table select failed")
     ENDIF
     SET country_display = " "
     IF ((request->health_plans[x].addresses[y].country_code_value > 0))
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE (cv.code_value=request->health_plans[x].addresses[y].country_code_value)
        AND cv.active_ind=1
       DETAIL
        country_display = cv.display
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 011:code_value table select failed")
     ENDIF
     IF ((request->health_plans[x].addresses[y].action_flag=1))
      INSERT  FROM address a
       SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "HEALTH_PLAN", a
        .parent_entity_id = plan_id,
        a.address_type_cd = request->health_plans[x].addresses[y].address_type_code_value, a.updt_id
         = reqinfo->updt_id, a.updt_cnt = 0,
        a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        a.street_addr = request->health_plans[x].addresses[y].street_addr1, a.street_addr2 = request
        ->health_plans[x].addresses[y].street_addr2, a.street_addr3 = request->health_plans[x].
        addresses[y].street_addr3,
        a.street_addr4 = request->health_plans[x].addresses[y].street_addr4, a.city = request->
        health_plans[x].addresses[y].city, a.state = state_display,
        a.state_cd = request->health_plans[x].addresses[y].state_code_value, a.zipcode = request->
        health_plans[x].addresses[y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->
          health_plans[x].addresses[y].zipcode)),
        a.county = county_display, a.county_cd = request->health_plans[x].addresses[y].
        county_code_value, a.country = country_display,
        a.country_cd = request->health_plans[x].addresses[y].country_code_value, a.contact_name =
        request->health_plans[x].addresses[y].contact_name, a.comment_txt = request->health_plans[x].
        addresses[y].comment_txt,
        a.address_type_seq = request->health_plans[x].addresses[y].sequence, a.postal_barcode_info =
        " ", a.mail_stop = " ",
        a.operation_hours = " ", a.data_status_cd = auth_cd, a.data_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        a.data_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ERROR 012:address table insertion failed")
     ELSEIF ((request->health_plans[x].addresses[y].action_flag=2))
      UPDATE  FROM address a
       SET a.address_type_cd = request->health_plans[x].addresses[y].address_type_code_value, a
        .street_addr = request->health_plans[x].addresses[y].street_addr1, a.street_addr2 = request->
        health_plans[x].addresses[y].street_addr2,
        a.street_addr3 = request->health_plans[x].addresses[y].street_addr3, a.street_addr4 = request
        ->health_plans[x].addresses[y].street_addr4, a.city = request->health_plans[x].addresses[y].
        city,
        a.state = state_display, a.state_cd = request->health_plans[x].addresses[y].state_code_value,
        a.zipcode = request->health_plans[x].addresses[y].zipcode,
        a.zipcode_key = cnvtupper(cnvtalphanum(request->health_plans[x].addresses[y].zipcode)), a
        .county = county_display, a.county_cd = request->health_plans[x].addresses[y].
        county_code_value,
        a.country = country_display, a.country_cd = request->health_plans[x].addresses[y].
        country_code_value, a.contact_name = request->health_plans[x].addresses[y].contact_name,
        a.comment_txt = request->health_plans[x].addresses[y].comment_txt, a.address_type_seq =
        request->health_plans[x].addresses[y].sequence, a.updt_cnt = (a.updt_cnt+ 1),
        a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
        updt_applctx,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (a
        WHERE (a.address_id=request->health_plans[x].addresses[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 013:address table updation failed")
     ELSEIF ((request->health_plans[x].addresses[y].action_flag=3))
      UPDATE  FROM address a
       SET a.active_ind = 0, a.active_status_cd = inactive_cd, a.updt_cnt = (a.updt_cnt+ 1),
        a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
        updt_applctx,
        a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (a
        WHERE (a.address_id=request->health_plans[x].addresses[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 014:address table updation failed")
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->health_plans[x].phones,5))
     IF ((request->health_plans[x].phones[y].action_flag=1))
      IF ((request->health_plans[x].phones[y].sequence IN (null, 0)))
       SET request->health_plans[x].phones[y].sequence = 1
      ENDIF
      INSERT  FROM phone p
       SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "HEALTH_PLAN", p
        .parent_entity_id = plan_id,
        p.phone_type_cd = request->health_plans[x].phones[y].phone_type_code_value, p.phone_format_cd
         = request->health_plans[x].phones[y].phone_format_code_value, p.phone_num = trim(request->
         health_plans[x].phones[y].phone_number),
        p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->health_plans[x].phones[y].phone_number
           ))), p.phone_type_seq = request->health_plans[x].phones[y].sequence, p.description = trim(
         request->health_plans[x].phones[y].description),
        p.contact = trim(request->health_plans[x].phones[y].contact), p.call_instruction = trim(
         request->health_plans[x].phones[y].call_instruction), p.extension = trim(request->
         health_plans[x].phones[y].extension),
        p.paging_code = trim(request->health_plans[x].phones[y].paging_code), p.updt_id = reqinfo->
        updt_id, p.updt_cnt = 0,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
        .data_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ERROR 015:phone table insertion failed")
     ELSEIF ((request->health_plans[x].phones[y].action_flag=2))
      UPDATE  FROM phone p
       SET p.phone_type_cd = request->health_plans[x].phones[y].phone_type_code_value, p
        .phone_format_cd = request->health_plans[x].phones[y].phone_format_code_value, p.phone_num =
        trim(request->health_plans[x].phones[y].phone_number),
        p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->health_plans[x].phones[y].phone_number
           ))), p.phone_type_seq = request->health_plans[x].phones[y].sequence, p.description = trim(
         request->health_plans[x].phones[y].description),
        p.contact = trim(request->health_plans[x].phones[y].contact), p.call_instruction = trim(
         request->health_plans[x].phones[y].call_instruction), p.extension = trim(request->
         health_plans[x].phones[y].extension),
        p.paging_code = trim(request->health_plans[x].phones[y].paging_code), p.updt_cnt = (p
        .updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
        p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3)
       PLAN (p
        WHERE (p.phone_id=request->health_plans[x].phones[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 016:phone table updation failed")
     ELSEIF ((request->health_plans[x].phones[y].action_flag=3))
      UPDATE  FROM phone p
       SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.end_effective_dt_tm = cnvtdatetime(
         curdate,curtime),
        p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       PLAN (p
        WHERE (p.phone_id=request->health_plans[x].phones[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 017:phone table updation failed")
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->health_plans[x].aliases,5))
     IF ((request->health_plans[x].aliases[y].action_flag=1))
      SET alias_id = 0
      SELECT INTO "nl:"
       FROM health_plan_alias hpa
       PLAN (hpa
        WHERE hpa.health_plan_id=plan_id
         AND (hpa.alias_pool_cd=request->health_plans[x].aliases[y].alias_pool_code_value)
         AND (hpa.plan_alias_type_cd=request->health_plans[x].aliases[y].alias_type_code_value)
         AND (hpa.alias=request->health_plans[x].aliases[y].alias)
         AND hpa.active_ind=0)
       DETAIL
        alias_id = hpa.health_plan_alias_id
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 018:health_plan_alias table select failed")
      IF (curqual > 0)
       UPDATE  FROM health_plan_alias hpa
        SET hpa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), hpa.active_ind = 1, hpa
         .active_status_cd = active_cd,
         hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_applctx = reqinfo->updt_applctx,
         hpa.updt_cnt = (hpa.updt_cnt+ 1),
         hpa.updt_id = reqinfo->updt_id, hpa.updt_task = reqinfo->updt_task
        PLAN (hpa
         WHERE hpa.health_plan_alias_id=alias_id)
        WITH nocounter
       ;end update
       CALL bederrorcheck("ERROR 019:health_plan_alias table update failed")
      ELSE
       INSERT  FROM health_plan_alias hpa
        SET hpa.health_plan_alias_id = seq(health_plan_seq,nextval), hpa.health_plan_id = plan_id,
         hpa.alias_pool_cd = request->health_plans[x].aliases[y].alias_pool_code_value,
         hpa.plan_alias_type_cd = request->health_plans[x].aliases[y].alias_type_code_value, hpa
         .alias = trim(request->health_plans[x].aliases[y].alias), hpa.check_digit = null,
         hpa.check_digit_method_cd = 0, hpa.plan_alias_sub_type_cd = 0, hpa.contributor_system_cd = 0,
         hpa.data_status_cd = auth_cd, hpa.data_status_dt_tm = cnvtdatetime(curdate,curtime3), hpa
         .data_status_prsnl_id = reqinfo->updt_id,
         hpa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), hpa.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), hpa.active_ind = 1,
         hpa.active_status_cd = active_cd, hpa.active_status_prsnl_id = reqinfo->updt_id, hpa
         .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_applctx = reqinfo->updt_applctx,
         hpa.updt_cnt = 0,
         hpa.updt_id = reqinfo->updt_id, hpa.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ERROR 020:health_plan_alias table insertion failed")
      ENDIF
     ELSEIF ((request->health_plans[x].aliases[y].action_flag=2))
      UPDATE  FROM health_plan_alias hpa
       SET hpa.alias_pool_cd = request->health_plans[x].aliases[y].alias_pool_code_value, hpa
        .plan_alias_type_cd = request->health_plans[x].aliases[y].alias_type_code_value, hpa.alias =
        trim(request->health_plans[x].aliases[y].alias),
        hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_applctx = reqinfo->updt_applctx,
        hpa.updt_cnt = (hpa.updt_cnt+ 1),
        hpa.updt_id = reqinfo->updt_id, hpa.updt_task = reqinfo->updt_task
       PLAN (hpa
        WHERE (hpa.health_plan_alias_id=request->health_plans[x].aliases[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 021:health_plan_alias table update failed")
     ELSEIF ((request->health_plans[x].aliases[y].action_flag=3))
      UPDATE  FROM health_plan_alias hpa
       SET hpa.active_ind = 0, hpa.active_status_cd = inactive_cd, hpa.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime),
        hpa.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpa.updt_applctx = reqinfo->updt_applctx,
        hpa.updt_cnt = (hpa.updt_cnt+ 1),
        hpa.updt_id = reqinfo->updt_id, hpa.updt_task = reqinfo->updt_task
       PLAN (hpa
        WHERE (hpa.health_plan_alias_id=request->health_plans[x].aliases[y].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 022:health_plan_alias table update failed")
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->health_plans[x].org_plans,5))
     IF ((request->health_plans[x].org_plans[y].action_flag=1))
      SELECT INTO "nl:"
       FROM org_plan_reltn opr
       PLAN (opr
        WHERE (opr.organization_id=request->health_plans[x].org_plans[y].organization_id)
         AND opr.health_plan_id=plan_id
         AND (opr.org_plan_reltn_cd=request->health_plans[x].org_plans[y].org_plan_reltn_code_value)
         AND opr.active_ind=0)
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 023:org_plan_reltn table select failed")
      IF (curqual > 0)
       UPDATE  FROM org_plan_reltn opr
        SET opr.group_nbr = request->health_plans[x].org_plans[y].group_number, opr.group_name =
         request->health_plans[x].org_plans[y].group_name, opr.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id =
         reqinfo->updt_id,
         opr.updt_task = reqinfo->updt_task, opr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         opr.active_ind = 1,
         opr.active_status_cd = active_cd
        PLAN (opr
         WHERE (opr.organization_id=request->health_plans[x].org_plans[y].organization_id)
          AND opr.health_plan_id=plan_id
          AND (opr.org_plan_reltn_cd=request->health_plans[x].org_plans[y].org_plan_reltn_code_value)
         )
        WITH nocounter
       ;end update
       CALL bederrorcheck("ERROR 024:org_plan_reltn table updation failed")
      ELSE
       SET opr_id = 0.0
       SELECT INTO "nl:"
        j = seq(organization_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         opr_id = cnvtreal(j)
        WITH format, counter
       ;end select
       CALL bederrorcheck("ERROR 025:Generating new org_plan_reltn_id failed")
       INSERT  FROM org_plan_reltn opr
        SET opr.org_plan_reltn_id = opr_id, opr.health_plan_id = plan_id, opr.organization_id =
         request->health_plans[x].org_plans[y].organization_id,
         opr.org_plan_reltn_cd = request->health_plans[x].org_plans[y].org_plan_reltn_code_value, opr
         .group_nbr = request->health_plans[x].org_plans[y].group_number, opr.group_name = request->
         health_plans[x].org_plans[y].group_name,
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
       CALL bederrorcheck("ERROR 026:org_plan_reltn table insertion failed")
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
           2 address_type_seq = i4
           2 state_cd = f8
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
       IF ((request->health_plans[x].org_plans[y].org_plan_reltn_code_value=sponsor_cd))
        SELECT INTO "nl:"
         FROM address a
         PLAN (a
          WHERE (a.parent_entity_id=request->health_plans[x].org_plans[y].organization_id)
           AND a.parent_entity_name="ORGANIZATION"
           AND a.active_ind=1)
         HEAD REPORT
          acnt = 0
         DETAIL
          acnt = (acnt+ 1), stat = alterlist(addr->qual,acnt), addr->qual[acnt].address_type_cd = a
          .address_type_cd,
          addr->qual[acnt].street_addr1 = a.street_addr, addr->qual[acnt].street_addr2 = a
          .street_addr2, addr->qual[acnt].street_addr3 = a.street_addr3,
          addr->qual[acnt].street_addr4 = a.street_addr4, addr->qual[acnt].city = a.city, addr->qual[
          acnt].state_cd = a.state_cd,
          addr->qual[acnt].state = a.state, addr->qual[acnt].zipcode = a.zipcode, addr->qual[acnt].
          zipcode_key = a.zipcode_key,
          addr->qual[acnt].county_cd = a.county_cd, addr->qual[acnt].county = a.county, addr->qual[
          acnt].country_cd = a.country_cd,
          addr->qual[acnt].country = a.country, addr->qual[acnt].address_type_seq = a
          .address_type_seq, addr->qual[acnt].contact_name = a.contact_name,
          addr->qual[acnt].comment_txt = a.comment_txt, addr->qual[acnt].postal_barcode_info = a
          .postal_barcode_info, addr->qual[acnt].mail_stop = a.mail_stop,
          addr->qual[acnt].operation_hours = a.operation_hours
         WITH nocounter
        ;end select
        CALL bederrorcheck("ERROR 027:address table select failed")
        SELECT INTO "nl:"
         FROM phone p
         PLAN (p
          WHERE (p.parent_entity_id=request->health_plans[x].org_plans[y].organization_id)
           AND p.parent_entity_name="ORGANIZATION"
           AND p.active_ind=1)
         HEAD REPORT
          pcnt = 0
         DETAIL
          pcnt = (pcnt+ 1), stat = alterlist(phone->qual,pcnt), phone->qual[pcnt].phone_type_cd = p
          .phone_type_cd,
          phone->qual[pcnt].phone_format_cd = p.phone_format_cd, phone->qual[pcnt].phone_num = p
          .phone_num, phone->qual[pcnt].phone_type_seq = p.phone_type_seq,
          phone->qual[pcnt].description = p.description, phone->qual[pcnt].contact = p.contact, phone
          ->qual[pcnt].call_instruction = p.call_instruction,
          phone->qual[pcnt].extension = p.extension, phone->qual[pcnt].paging_code = p.paging_code
         WITH nocounter
        ;end select
        CALL bederrorcheck("ERROR 028:phone table select failed")
        IF (size(addr->qual,5) > 0)
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
           a.state = addr->qual[d.seq].state, a.state_cd = addr->qual[d.seq].state_cd, a.zipcode =
           addr->qual[d.seq].zipcode,
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
         CALL bederrorcheck("ERROR 029:address table insertion failed")
        ENDIF
        IF (size(phone->qual,5) > 0)
         INSERT  FROM (dummyt d  WITH seq = value(size(phone->qual,5))),
           phone p
          SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORG_PLAN_RELTN", p
           .parent_entity_id = opr_id,
           p.phone_type_cd = phone->qual[d.seq].phone_type_cd, p.phone_format_cd = phone->qual[d.seq]
           .phone_format_cd, p.phone_num = phone->qual[d.seq].phone_num,
           p.phone_num_key = cnvtupper(cnvtalphanum(phone->qual[d.seq].phone_num)), p.phone_type_seq
            = phone->qual[d.seq].phone_type_seq, p.description = phone->qual[d.seq].description,
           p.contact = phone->qual[d.seq].contact, p.call_instruction = phone->qual[d.seq].
           call_instruction, p.extension = phone->qual[d.seq].extension,
           p.paging_code = phone->qual[d.seq].paging_code, p.updt_id = reqinfo->updt_id, p.updt_cnt
            = 0,
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
         CALL bederrorcheck("ERROR 030:phone table insertion failed")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((request->health_plans[x].org_plans[y].action_flag=2))
      UPDATE  FROM org_plan_reltn opr
       SET opr.organization_id = request->health_plans[x].org_plans[y].organization_id, opr
        .health_plan_id = plan_id, opr.org_plan_reltn_cd = request->health_plans[x].org_plans[y].
        org_plan_reltn_code_value,
        opr.group_nbr = request->health_plans[x].org_plans[y].group_number, opr.group_name = request
        ->health_plans[x].org_plans[y].group_name, opr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        opr.updt_applctx = reqinfo->updt_applctx, opr.updt_cnt = (opr.updt_cnt+ 1), opr.updt_id =
        reqinfo->updt_id,
        opr.updt_task = reqinfo->updt_task
       PLAN (opr
        WHERE (opr.org_plan_reltn_id=request->health_plans[x].org_plans[y].org_plan_reltn_id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 031:org_plan_reltn table update failed")
     ELSEIF ((request->health_plans[x].org_plans[y].action_flag=3))
      UPDATE  FROM org_plan_reltn opr
       SET opr.active_ind = 0, opr.active_status_cd = inactive_cd, opr.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime),
        opr.updt_dt_tm = cnvtdatetime(curdate,curtime3), opr.updt_applctx = reqinfo->updt_applctx,
        opr.updt_cnt = (opr.updt_cnt+ 1),
        opr.updt_id = reqinfo->updt_id, opr.updt_task = reqinfo->updt_task
       PLAN (opr
        WHERE (opr.org_plan_reltn_id=request->health_plans[x].org_plans[y].org_plan_reltn_id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 032:org_plan_reltn table update failed")
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->health_plans[x].facilities,5))
     IF ((request->health_plans[x].facilities[y].action_flag=1))
      SELECT INTO "NL:"
       FROM filter_type_data ftd
       PLAN (ftd
        WHERE (ftd.filter_entity1_id=request->health_plans[x].facilities[y].location_code_value)
         AND ftd.filter_entity1_name="LOCATION"
         AND ftd.filter_type_cd=fhp_cd)
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 038: filter_type_data table existing record check failed")
      IF (curqual=0)
       INSERT  FROM filter_type_data f
        SET f.filter_type_data_id = seq(reference_seq,nextval), f.filter_entity1_id = request->
         health_plans[x].facilities[y].location_code_value, f.filter_entity1_name = "LOCATION",
         f.filter_entity2_id = 0, f.filter_entity2_name = "", f.filter_entity3_id = 0,
         f.filter_entity3_name = "", f.filter_entity4_id = 0, f.filter_entity4_name = "",
         f.filter_entity5_id = 0, f.filter_entity5_name = "", f.filter_type_cd = fhp_cd,
         f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_applctx = reqinfo->updt_applctx, f
         .updt_cnt = 0,
         f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ERROR 033:filter_type_data table insertion failed")
      ENDIF
      INSERT  FROM filter_entity_reltn fer
       SET fer.filter_entity_reltn_id = seq(reference_seq,nextval), fer.parent_entity_id = plan_id,
        fer.parent_entity_name = "HEALTH_PLAN",
        fer.filter_entity1_name = "LOCATION", fer.filter_entity1_id = request->health_plans[x].
        facilities[y].location_code_value, fer.filter_entity2_name = "",
        fer.filter_entity2_id = 0, fer.filter_entity3_name = "", fer.filter_entity3_id = 0,
        fer.filter_entity4_name = "", fer.filter_entity4_id = 0, fer.filter_entity5_name = "",
        fer.filter_entity5_id = 0, fer.filter_type_cd = fhp_cd, fer.exclusion_filter_ind = 0,
        fer.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), fer.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), fer.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        fer.updt_applctx = reqinfo->updt_applctx, fer.updt_cnt = 0, fer.updt_id = reqinfo->updt_id,
        fer.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ERROR 034:filter_entity_reltn table insertion failed")
     ELSEIF ((request->health_plans[x].facilities[y].action_flag=3))
      DELETE  FROM filter_entity_reltn fer
       WHERE fer.parent_entity_id=plan_id
        AND fer.parent_entity_name="HEALTH_PLAN"
        AND (fer.filter_entity1_id=request->health_plans[x].facilities[y].location_code_value)
        AND fer.filter_entity1_name="LOCATION"
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ERROR 035:filter_entity_reltn table deletion failed")
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(request->health_plans[x].number_formats,5))
     IF ((request->health_plans[x].number_formats[y].action_flag=1))
      SELECT INTO "nl:"
       j = seq(health_plan_seq,nextval)
       FROM dual
       DETAIL
        field_format_id = cnvtreal(j)
       WITH format, counter
      ;end select
      CALL bederrorcheck("Generating new field_format_id failed")
      INSERT  FROM health_plan_field_format hpff
       SET hpff.field_required_ind = request->health_plans[x].number_formats[y].field_required_ind,
        hpff.field_type_meaning_txt = request->health_plans[x].number_formats[y].
        field_type_meaning_txt, hpff.format_mask_txt = request->health_plans[x].number_formats[y].
        format_mask_txt,
        hpff.health_plan_field_format_id = field_format_id, hpff.health_plan_id = plan_id, hpff
        .min_format_mask_char_cnt = request->health_plans[x].number_formats[y].
        min_format_mask_char_cnt,
        hpff.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpff.updt_applctx = reqinfo->updt_applctx,
        hpff.updt_cnt = 0,
        hpff.updt_id = reqinfo->updt_id, hpff.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ERROR 036:health_plan_field_format table insertion failed")
     ELSEIF ((request->health_plans[x].number_formats[y].action_flag=2))
      UPDATE  FROM health_plan_field_format hpff
       SET hpff.field_required_ind = request->health_plans[x].number_formats[y].field_required_ind,
        hpff.field_type_meaning_txt = request->health_plans[x].number_formats[y].
        field_type_meaning_txt, hpff.format_mask_txt = request->health_plans[x].number_formats[y].
        format_mask_txt,
        hpff.min_format_mask_char_cnt = request->health_plans[x].number_formats[y].
        min_format_mask_char_cnt, hpff.updt_dt_tm = cnvtdatetime(curdate,curtime3), hpff.updt_applctx
         = reqinfo->updt_applctx,
        hpff.updt_cnt = (hpff.updt_cnt+ 1), hpff.updt_id = reqinfo->updt_id, hpff.updt_task = reqinfo
        ->updt_task
       WHERE (hpff.health_plan_field_format_id=request->health_plans[x].number_formats[y].
       health_plan_field_format_id)
       WITH nocounter
      ;end update
      CALL bederrorcheck("ERROR 037:health_plan_field_format table updation failed")
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->health_plans,x)
   SET reply->health_plans[x].id = plan_id
   IF (ishpfeatureenabled
    AND error_flag != "Y"
    AND (request->health_plans[x].action_flag > 0))
    IF (validate(request->health_plans[x].revelate_required_fields))
     IF (trim(request->health_plans[x].revelate_required_fields) != ""
      AND (request->health_plans[x].revelate_required_fields != null))
      SET rccloudindex = (rccloudindex+ 1)
      SET stat = alterlist(reqhptorccloudsync->hplist,rccloudindex)
      SET reqhptorccloudsync->hplist[rccloudindex].action_flag = request->health_plans[x].action_flag
      SET reqhptorccloudsync->hplist[rccloudindex].health_plan_id = plan_id
      SET reqhptorccloudsync->hplist[rccloudindex].revelate_required_fields = request->health_plans[x
      ].revelate_required_fields
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE bed_ens_hp_timely_filing  WITH replace("REQUEST",timelyfilingrequest)
 CALL bederrorcheck("ERROR 039:Error when adding or updating timely filing data.")
 IF (ishpfeatureenabled
  AND rccloudindex > 0)
  EXECUTE pft_bed_ens_health_plan  WITH replace("REQUEST",reqhptorccloudsync), replace("REPLY",
   rephptorccloudsync)
  CALL bederrorcheck(build2("ERROR 040:Error when performing operation on rc_cloud_sync table.",
    " Contact Patient Accounting for assistance."))
  IF ((rephptorccloudsync->status_data.status != "S"))
   CALL bederror("ERROR 041:Error saving health plan data in rc_cloud_sync table.")
  ENDIF
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
