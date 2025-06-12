CREATE PROGRAM bed_ens_org_timely_filing:dba
 IF ( NOT (validate(reqcopy,0)))
  RECORD reqcopy(
    1 timely_filings[*]
      2 action_flag = i2
      2 org_timely_filing_id = f8
      2 organization_id = f8
      2 auto_release_days = i4
      2 limit_days = i4
      2 notify_days = i4
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(m_dm2_seq_stat,0)))
  RECORD m_dm2_seq_stat(
    1 n_status = i4
    1 s_error_msg = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 CALL bedbeginscript(0)
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE req_size = i4 WITH protect, noconstant(size(request->timely_filings,5))
 DECLARE validateandcopyrequest(dummyvar=i2) = null
 DECLARE generateuniqueid(dummyvar=i2) = f8
 DECLARE performupdates(dummyvar=i2) = null
 DECLARE lockorgtimelyfiling(current_org_timely_filing_index=i4) = null
 DECLARE addorgtimelyfiling(current_org_timely_filing_index=i4) = null
 DECLARE modifyorgtimelyfiling(current_org_timely_filing_index=i4) = null
 DECLARE removeorgtimelyfiling(current_org_timely_filing_index=i4) = null
 CALL validateandcopyrequest(0)
 CALL performupdates(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE validateandcopyrequest(null)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reqcopy->timely_filings,req_size)
   FOR (index = 1 TO req_size)
     IF ((((request->timely_filings[index].action_flag < 1)) OR ((request->timely_filings[index].
     action_flag > 3))) )
      CALL bederror("ERROR 001: Request contains invalid values")
     ELSE
      SET reqcopy->timely_filings[index].action_flag = request->timely_filings[index].action_flag
      SET reqcopy->timely_filings[index].org_timely_filing_id = request->timely_filings[index].
      org_timely_filing_id
      SET reqcopy->timely_filings[index].organization_id = request->timely_filings[index].
      organization_id
      SET reqcopy->timely_filings[index].auto_release_days = request->timely_filings[index].
      auto_release_days
      SET reqcopy->timely_filings[index].limit_days = request->timely_filings[index].limit_days
      SET reqcopy->timely_filings[index].notify_days = request->timely_filings[index].notify_days
      SET reqcopy->timely_filings[index].beg_effective_dt_tm = request->timely_filings[index].
      beg_effective_dt_tm
      SET reqcopy->timely_filings[index].end_effective_dt_tm = request->timely_filings[index].
      end_effective_dt_tm
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE lockorgtimelyfiling(current_org_timely_filing_index)
  SELECT INTO "nl:"
   otf.org_timely_filing_id
   FROM org_timely_filing otf
   WHERE (otf.org_timely_filing_id=reqcopy->timely_filings[current_org_timely_filing_index].
   org_timely_filing_id)
   WITH nocounter, forupdate(psr)
  ;end select
  CALL bederrorcheck(
   "ERROR 002: Locking the organization timely filing configuration row failed for update operation")
 END ;Subroutine
 SUBROUTINE generateuniqueid(dummyvar)
   FREE RECORD add_reference_entity
   RECORD add_reference_entity(
     1 entity[*]
       2 entity_id = f8
   )
   SET stat = alterlist(add_reference_entity->entity,1)
   EXECUTE dm2_dar_get_bulk_seq "ADD_REFERENCE_ENTITY->ENTITY", 1, "ENTITY_ID",
   1, "HEALTH_PLAN_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    CALL bederror(concat(" ERROR 003: Sequence retrieval error: ",m_dm2_seq_stat->s_error_msg,
      " ERROR ENCOUNTERED IN DM2_DAR_GET_BULK_SEQ (HEALTH_PLAN_SEQ)"))
   ENDIF
   RETURN(add_reference_entity->entity[1].entity_id)
 END ;Subroutine
 SUBROUTINE performupdates(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   FOR (index = 1 TO req_size)
     IF ((reqcopy->timely_filings[index].action_flag=1))
      SET new_id = generateuniqueid(null)
      IF (new_id <= 0.0)
       CALL bederror("ERROR 004: Unable to generate new organization timely filing Id.")
      ENDIF
      SET reqcopy->timely_filings[index].org_timely_filing_id = new_id
      CALL addorgtimelyfiling(index)
     ELSEIF ((reqcopy->timely_filings[index].action_flag=2))
      IF ((reqcopy->timely_filings[index].org_timely_filing_id <= 0.0))
       CALL bederror("ERROR 005: Primary key not found for update operation.")
      ENDIF
      CALL modifyorgtimelyfiling(index)
     ELSEIF ((reqcopy->timely_filings[index].action_flag=3))
      IF ((reqcopy->timely_filings[index].org_timely_filing_id <= 0.0))
       CALL bederror("ERROR 006: Primary key not found for update operation.")
      ENDIF
      CALL removeorgtimelyfiling(index)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addorgtimelyfiling(current_org_timely_filing_index)
  INSERT  FROM org_timely_filing otf
   SET otf.org_timely_filing_id = reqcopy->timely_filings[current_org_timely_filing_index].
    org_timely_filing_id, otf.organization_id = reqcopy->timely_filings[
    current_org_timely_filing_index].organization_id, otf.auto_release_days = reqcopy->
    timely_filings[current_org_timely_filing_index].auto_release_days,
    otf.limit_days = reqcopy->timely_filings[current_org_timely_filing_index].limit_days, otf
    .notify_days = reqcopy->timely_filings[current_org_timely_filing_index].notify_days, otf
    .active_ind = 1,
    otf.beg_effective_dt_tm =
    IF ((reqcopy->timely_filings[current_org_timely_filing_index].beg_effective_dt_tm <= 0))
     cnvtdatetime(cur_dt_tm)
    ELSE cnvtdatetime(reqcopy->timely_filings[current_org_timely_filing_index].beg_effective_dt_tm)
    ENDIF
    , otf.end_effective_dt_tm =
    IF ((reqcopy->timely_filings[current_org_timely_filing_index].end_effective_dt_tm <= 0))
     cnvtdatetime("31-DEC-2100 23:59:59.00")
    ELSE cnvtdatetime(cnvtdate(reqcopy->timely_filings[current_org_timely_filing_index].
       end_effective_dt_tm),235959)
    ENDIF
    , otf.updt_dt_tm = cnvtdatetime(cur_dt_tm),
    otf.updt_id = reqinfo->updt_id, otf.updt_task = reqinfo->updt_task, otf.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 007: Unable to insert new organization timely filing configuration row.")
 END ;Subroutine
 SUBROUTINE modifyorgtimelyfiling(current_org_timely_filing_index)
   CALL lockorgtimelyfiling(current_org_timely_filing_index)
   UPDATE  FROM org_timely_filing otf
    SET otf.auto_release_days = reqcopy->timely_filings[current_org_timely_filing_index].
     auto_release_days, otf.limit_days = reqcopy->timely_filings[current_org_timely_filing_index].
     limit_days, otf.notify_days = reqcopy->timely_filings[current_org_timely_filing_index].
     notify_days,
     otf.beg_effective_dt_tm =
     IF ((reqcopy->timely_filings[current_org_timely_filing_index].beg_effective_dt_tm <= 0)) otf
      .beg_effective_dt_tm
     ELSE cnvtdatetime(reqcopy->timely_filings[current_org_timely_filing_index].beg_effective_dt_tm)
     ENDIF
     , otf.end_effective_dt_tm =
     IF ((reqcopy->timely_filings[current_org_timely_filing_index].end_effective_dt_tm <= 0)) otf
      .end_effective_dt_tm
     ELSE cnvtdatetime(reqcopy->timely_filings[current_org_timely_filing_index].end_effective_dt_tm)
     ENDIF
     , otf.updt_cnt = (otf.updt_cnt+ 1),
     otf.updt_dt_tm = cnvtdatetime(cur_dt_tm), otf.updt_id = reqinfo->updt_id, otf.updt_task =
     reqinfo->updt_task,
     otf.updt_applctx = reqinfo->updt_applctx
    WHERE (otf.org_timely_filing_id=reqcopy->timely_filings[current_org_timely_filing_index].
    org_timely_filing_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck(
    "ERROR 008: Modifying organization health plan timely filing configuration failed.")
 END ;Subroutine
 SUBROUTINE removeorgtimelyfiling(current_org_timely_filing_index)
   CALL lockorgtimelyfiling(current_org_timely_filing_index)
   UPDATE  FROM org_timely_filing otf
    SET otf.active_ind = 0, otf.updt_cnt = (otf.updt_cnt+ 1), otf.updt_dt_tm = cnvtdatetime(cur_dt_tm
      ),
     otf.updt_id = reqinfo->updt_id, otf.updt_task = reqinfo->updt_task, otf.updt_applctx = reqinfo->
     updt_applctx
    WHERE (otf.org_timely_filing_id=reqcopy->timely_filings[current_org_timely_filing_index].
    org_timely_filing_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 009: Removing organization timely filing configuration failed.")
 END ;Subroutine
END GO
