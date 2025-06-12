CREATE PROGRAM bed_get_provider_enrollment:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 provider_list[*]
      2 provider_enrollment_id = f8
      2 prsnl_id = f8
      2 prsnl_name = vc
      2 location_cd = f8
      2 location_name = vc
      2 payer_org_id = f8
      2 payer_name = vc
      2 health_plan_id = f8
      2 health_plan_name = vc
      2 hp_payer_org_id = f8
      2 bill_type_flag = i2
      2 claim_flag_type_name = vc
      2 participation_status_cd = f8
      2 participation_status_name = vc
      2 comments = vc
      2 process_beg_effective_dt_tm = dq8
      2 process_end_effective_dt_tm = dq8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 priority_seq = i4
      2 last_modified_dt_tm = dq8
      2 last_modified_by = vc
      2 paperwork_submitted_dt_tm = dq8
      2 paperwork_acknowledged_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD comments_list(
   1 activity_list[*]
     2 updt_id = f8
 ) WITH protect
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
 DECLARE d1 = dq8 WITH protect
 DECLARE d2 = dq8 WITH protect
 DECLARE d3 = dq8 WITH protect
 DECLARE d4 = dq8 WITH protect
 DECLARE d5 = dq8 WITH protect
 DECLARE d6 = dq8 WITH protect
 DECLARE end_date_parser = vc WITH protect
 DECLARE begin_date_parser = vc WITH protect
 DECLARE process_end_date_parser = vc WITH protect
 DECLARE process_start_date_parser = vc WITH protect
 DECLARE paperwork_end_date_parser = vc WITH protect
 DECLARE paperwork_start_date_parser = vc WITH protect
 DECLARE bill_type_flag_parser = vc WITH protect
 DECLARE status_parser = vc WITH protect
 DECLARE health_plan_parser = vc WITH protect
 DECLARE payer_parser = vc WITH protect
 DECLARE facility_parser = vc WITH protect
 DECLARE provider_parser = vc WITH protect
 DECLARE provider_count = i4 WITH protect, noconstant(0)
 DECLARE fillprovidersinfo(null) = null
 DECLARE fillotherprsnlinfo(null) = null
 SET reply->status_data.status = "F"
 IF ((request->prsnl_id > 0.0))
  SET provider_parser = build(provider_parser," pe.prsnl_id = request->prsnl_id ")
 ELSE
  SET provider_parser = "1=1"
 ENDIF
 IF ((request->location_cd > 0.0))
  SET facility_parser = build(facility_parser," pe.location_cd = request->location_cd ")
 ELSE
  SET facility_parser = "1=1"
 ENDIF
 IF ((request->payer_org_id > 0.0))
  SET payer_parser = build(payer_parser,"pe.payer_org_id = request->payer_org_id ")
 ELSE
  SET payer_parser = "1=1"
 ENDIF
 IF ((request->health_plan_id > 0.0))
  SET health_plan_parser = build(health_plan_parser,"pe.health_plan_id = request->health_plan_id ")
 ELSE
  SET health_plan_parser = "1=1"
 ENDIF
 IF ((request->participation_status_cd > 0.0))
  SET status_parser = build(status_parser,
   "pe.participation_status_cd = request->participation_status_cd ")
 ELSE
  SET status_parser = "1=1"
 ENDIF
 IF ((request->bill_type_flag > 0))
  SET bill_type_flag_parser = build(bill_type_flag_parser,
   "pe.bill_type_flag = request->bill_type_flag ")
 ELSE
  SET bill_type_flag_parser = "1=1"
 ENDIF
 IF ((request->process_beg_effective_dt_tm != null))
  SET d1 = cnvtdatetime(request->process_beg_effective_dt_tm)
  SET process_start_date_parser =
  "pe.process_beg_effective_dt_tm between cnvtdatetime(D1) and  cnvtlookahead('1,D',cnvtdatetime(D1))"
 ELSE
  SET process_start_date_parser = "1=1"
 ENDIF
 IF ((request->process_end_effective_dt_tm != null))
  SET d2 = cnvtdatetime(request->process_end_effective_dt_tm)
  SET process_end_date_parser =
  "pe.process_end_effective_dt_tm between cnvtdatetime(D2) and  cnvtlookahead('1,D', cnvtdatetime(D2))"
 ELSE
  SET process_end_date_parser = "1=1"
 ENDIF
 IF ((request->beg_effective_dt_tm != null))
  SET d3 = cnvtdatetime(request->beg_effective_dt_tm)
  SET begin_date_parser =
  "pe.enroll_beg_effective_dt_tm between cnvtdatetime(D3) and  cnvtlookahead('1,D',cnvtdatetime(D3))"
 ELSE
  SET begin_date_parser = "1=1"
 ENDIF
 IF ((request->end_effective_dt_tm != null))
  SET d4 = cnvtdatetime(request->end_effective_dt_tm)
  SET end_date_parser =
  "pe.enroll_end_effective_dt_tm between cnvtdatetime(D4) and  cnvtlookahead('1,D', cnvtdatetime(D4))"
 ELSE
  SET end_date_parser = "1=1"
 ENDIF
 IF ((request->paperwork_submitted_dt_tm != null))
  SET d5 = cnvtdatetime(request->paperwork_submitted_dt_tm)
  SET paperwork_start_date_parser =
  "pe.submitted_to_payer_dt_tm between cnvtdatetime(D5) and  cnvtlookahead('1,D',cnvtdatetime(D5))"
 ELSE
  SET paperwork_start_date_parser = "1=1"
 ENDIF
 IF ((request->paperwork_acknowledged_dt_tm != null))
  SET d6 = cnvtdatetime(request->paperwork_acknowledged_dt_tm)
  SET paperwork_end_date_parser =
  "pe.received_by_payer_dt_tm between cnvtdatetime(D6) and  cnvtlookahead('1,D', cnvtdatetime(D6))"
 ELSE
  SET paperwork_end_date_parser = "1=1"
 ENDIF
 CALL fillprovidersinfo(null)
 IF (size(reply->provider_list,5) > 0)
  CALL fillotherprsnlinfo(null)
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No provider records"
  CALL bedlogmessage("Main logic","No provider records")
 ENDIF
#exit_script
 SUBROUTINE fillprovidersinfo(null)
   CALL bedlogmessage("fillProvidersInfo","Entering")
   DECLARE provider_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM provider_enrollment pe,
     corsp_log_reltn clr,
     corsp_log cl,
     long_text l
    PLAN (pe
     WHERE parser(provider_parser)
      AND parser(facility_parser)
      AND parser(payer_parser)
      AND parser(health_plan_parser)
      AND parser(status_parser)
      AND parser(bill_type_flag_parser)
      AND parser(process_start_date_parser)
      AND parser(process_end_date_parser)
      AND parser(begin_date_parser)
      AND parser(end_date_parser)
      AND parser(paperwork_start_date_parser)
      AND parser(paperwork_end_date_parser)
      AND pe.active_ind=1)
     JOIN (clr
     WHERE clr.parent_entity_id=outerjoin(pe.provider_enrollment_id)
      AND clr.parent_entity_name=outerjoin("ENROLLMENT")
      AND clr.active_ind=outerjoin(1))
     JOIN (cl
     WHERE cl.activity_id=outerjoin(clr.activity_id)
      AND cl.active_ind=outerjoin(1))
     JOIN (l
     WHERE l.long_text_id=outerjoin(cl.long_text_id)
      AND l.active_ind=outerjoin(1))
    ORDER BY pe.location_priority_seq, pe.provider_enrollment_id
    HEAD REPORT
     stat = alterlist(reply->provider_list,10), provider_count = 0
    HEAD pe.provider_enrollment_id
     provider_count = (provider_count+ 1)
     IF (mod(provider_count,10)=1
      AND provider_count > 10)
      stat = alterlist(reply->provider_list,(provider_count+ 9))
     ENDIF
     reply->provider_list[provider_count].provider_enrollment_id = pe.provider_enrollment_id, reply->
     provider_list[provider_count].prsnl_id = pe.prsnl_id, reply->provider_list[provider_count].
     payer_org_id = pe.payer_org_id,
     reply->provider_list[provider_count].health_plan_id = pe.health_plan_id, reply->provider_list[
     provider_count].location_cd = pe.location_cd, reply->provider_list[provider_count].
     bill_type_flag = pe.bill_type_flag,
     reply->provider_list[provider_count].beg_effective_dt_tm = cnvtdate(pe
      .enroll_beg_effective_dt_tm), reply->provider_list[provider_count].end_effective_dt_tm =
     cnvtdate(pe.enroll_end_effective_dt_tm), reply->provider_list[provider_count].
     participation_status_cd = pe.participation_status_cd,
     reply->provider_list[provider_count].process_beg_effective_dt_tm = cnvtdate(pe
      .process_beg_effective_dt_tm), reply->provider_list[provider_count].process_end_effective_dt_tm
      = cnvtdate(pe.process_end_effective_dt_tm), reply->provider_list[provider_count].
     last_modified_dt_tm = pe.updt_dt_tm,
     reply->provider_list[provider_count].priority_seq = pe.location_priority_seq, reply->
     provider_list[provider_count].paperwork_submitted_dt_tm = cnvtdate(pe.submitted_to_payer_dt_tm),
     reply->provider_list[provider_count].paperwork_acknowledged_dt_tm = cnvtdate(pe
      .received_by_payer_dt_tm),
     reply->provider_list[provider_count].comments = trim(l.long_text,3), reply->status_data.status
      = "S"
    FOOT REPORT
     stat = alterlist(reply->provider_list,provider_count)
    WITH nocounter
   ;end select
   CALL bedlogmessage("fillProvidersInfo","Exiting")
 END ;Subroutine
 SUBROUTINE fillotherprsnlinfo(null)
   CALL bedlogmessage("fillOtherPrsnlInfo","Entering")
   DECLARE info_count = i4 WITH protect, noconstant(0)
   DECLARE activity_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM provider_enrollment pe,
     prsnl p,
     organization o,
     health_plan hp,
     (dummyt d  WITH seq = size(reply->provider_list,5))
    PLAN (d)
     JOIN (pe
     WHERE (pe.provider_enrollment_id=reply->provider_list[d.seq].provider_enrollment_id)
      AND pe.active_ind=1)
     JOIN (p
     WHERE pe.prsnl_id=p.person_id)
     JOIN (o
     WHERE pe.payer_org_id=o.organization_id)
     JOIN (hp
     WHERE hp.health_plan_id=pe.health_plan_id)
    HEAD REPORT
     stat = alterlist(comments_list->activity_list,10), activity_count = 0
    DETAIL
     info_count = (info_count+ 1), reply->provider_list[info_count].prsnl_name = p
     .name_full_formatted, reply->provider_list[info_count].payer_name = o.org_name,
     reply->provider_list[info_count].location_name = uar_get_code_display(reply->provider_list[
      info_count].location_cd), reply->provider_list[info_count].health_plan_name = hp.plan_name,
     reply->provider_list[info_count].participation_status_name = uar_get_code_display(reply->
      provider_list[info_count].participation_status_cd)
     IF ((reply->provider_list[info_count].bill_type_flag=0))
      reply->provider_list[info_count].claim_flag_type_name = "None"
     ELSEIF ((reply->provider_list[info_count].bill_type_flag=1))
      reply->provider_list[info_count].claim_flag_type_name = "All"
     ELSEIF ((reply->provider_list[info_count].bill_type_flag=2))
      reply->provider_list[info_count].claim_flag_type_name = "1450 - Institutional Claim"
     ELSE
      reply->provider_list[info_count].claim_flag_type_name = "1500 - Professional Claim"
     ENDIF
     activity_count = (activity_count+ 1)
     IF (mod(activity_count,10)=1
      AND activity_count > 10)
      stat = alterlist(comments_list->activity_list,(activity_count+ 9))
     ENDIF
     comments_list->activity_list[activity_count].updt_id = pe.updt_id
    FOOT REPORT
     stat = alterlist(comments_list->activity_list,activity_count)
    WITH nocounter
   ;end select
   SET info_count = 0
   SELECT INTO "nl:"
    FROM prsnl p,
     (dummyt d  WITH seq = size(comments_list->activity_list,5))
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=comments_list->activity_list[d.seq].updt_id))
    DETAIL
     info_count = (info_count+ 1), reply->provider_list[info_count].last_modified_by = concat(trim(p
       .name_last_key,3),",",trim(p.name_first_key,3))
    WITH nocounter
   ;end select
   CALL bedlogmessage("fillOtherPrsnlInfo","Exiting")
 END ;Subroutine
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
