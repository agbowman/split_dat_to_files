CREATE PROGRAM bed_ens_hp_timely_filing:dba
 IF ( NOT (validate(reqcopy,0)))
  RECORD reqcopy(
    1 timely_filings[*]
      2 action_flag = i2
      2 health_plan_timely_filing_id = f8
      2 health_plan_id = f8
      2 auto_release_days = i4
      2 limit_days = i4
      2 notify_days = i4
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reqcopy,0)))
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
 DECLARE performupdates(dummyvar=i2) = null
 DECLARE gethealthplantimelyfilingids(dummyvar=i2) = null
 DECLARE lockhealthplantimelyfiling(current_hp_timely_filing_index=i4) = null
 DECLARE addhealthplantimelyfiling(current_hp_timely_filing_index=i4) = null
 DECLARE modifyhealthplantimelyfiling(current_hp_timely_filing_index=i4) = null
 CALL validateandcopyrequest(0)
 CALL gethealthplantimelyfilingids(0)
 CALL performupdates(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE validateandcopyrequest(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reqcopy->timely_filings,req_size)
   FOR (index = 1 TO req_size)
     IF ((((request->timely_filings[index].action_flag < 0)) OR ((((request->timely_filings[index].
     action_flag > 3)) OR ((request->timely_filings[index].health_plan_id <= 0.0))) )) )
      CALL bederror("ERROR 001: Request contains invalid values")
     ELSE
      SET reqcopy->timely_filings[index].action_flag = request->timely_filings[index].action_flag
      SET reqcopy->timely_filings[index].health_plan_id = request->timely_filings[index].
      health_plan_id
      SET reqcopy->timely_filings[index].auto_release_days = request->timely_filings[index].
      auto_release_days
      SET reqcopy->timely_filings[index].limit_days = request->timely_filings[index].limit_days
      SET reqcopy->timely_filings[index].notify_days = request->timely_filings[index].notify_days
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE gethealthplantimelyfilingids(dummyvar)
   DECLARE z_index = i4 WITH protect, noconstant(0)
   DECLARE x_index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    hptf.health_plan_timely_filing_id
    FROM health_plan_timely_filing hptf
    WHERE expand(z_index,1,req_size,hptf.health_plan_id,reqcopy->timely_filings[z_index].
     health_plan_id)
    ORDER BY hptf.health_plan_id
    DETAIL
     x_index = locateval(z_index,1,req_size,hptf.health_plan_id,reqcopy->timely_filings[z_index].
      health_plan_id)
     WHILE (x_index != 0)
      reqcopy->timely_filings[x_index].health_plan_timely_filing_id = hptf
      .health_plan_timely_filing_id,x_index = locateval(z_index,(x_index+ 1),req_size,hptf
       .health_plan_id,reqcopy->timely_filings[z_index].health_plan_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 002: Getting health plan timely filing id's failed")
 END ;Subroutine
 SUBROUTINE lockhealthplantimelyfiling(current_hp_timely_filing_index)
  SELECT INTO "nl:"
   hptf.health_plan_timely_filing_id
   FROM health_plan_timely_filing hptf
   WHERE (hptf.health_plan_timely_filing_id=reqcopy->timely_filings[current_hp_timely_filing_index].
   health_plan_timely_filing_id)
   WITH nocounter, forupdate(psr)
  ;end select
  CALL bederrorcheck(
   "ERROR 003: Locking the hp timely filing configuration row failed for update operation")
 END ;Subroutine
 SUBROUTINE performupdates(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   FOR (index = 1 TO req_size)
     IF ((reqcopy->timely_filings[index].action_flag=1))
      IF ((reqcopy->timely_filings[index].health_plan_timely_filing_id=0.0))
       SELECT INTO "nl:"
        z = seq(health_plan_seq,nextval)
        FROM dual
        DETAIL
         new_id = cnvtreal(z)
        WITH nocounter
       ;end select
       CALL bederrorcheck(
        "ERROR 004: Problems occurred retrieving next sequence value for health_plan_timely_filing PK."
        )
       IF (new_id <= 0.0)
        CALL bederror("ERROR 005: Unable to generate new timely filing Id.")
       ENDIF
       SET reqcopy->timely_filings[index].health_plan_timely_filing_id = new_id
       CALL addhealthplantimelyfiling(index)
      ELSE
       IF ((reqcopy->timely_filings[index].health_plan_timely_filing_id < 0.0))
        CALL bederror("ERROR 006: Primary key not found for modify action.")
       ENDIF
       CALL modifyhealthplantimelyfiling(index)
      ENDIF
     ELSEIF ((reqcopy->timely_filings[index].action_flag=2))
      IF ((reqcopy->timely_filings[index].health_plan_timely_filing_id <= 0.0))
       CALL bederror("ERROR 007: Primary key not found for update operation.")
      ENDIF
      CALL modifyhealthplantimelyfiling(index)
     ELSEIF ((reqcopy->timely_filings[index].action_flag=3))
      CALL removehealthplantimelyfiling(index)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addhealthplantimelyfiling(current_hp_timely_filing_index)
  INSERT  FROM health_plan_timely_filing hptf
   SET hptf.health_plan_timely_filing_id = reqcopy->timely_filings[current_hp_timely_filing_index].
    health_plan_timely_filing_id, hptf.health_plan_id = reqcopy->timely_filings[
    current_hp_timely_filing_index].health_plan_id, hptf.auto_release_days = reqcopy->timely_filings[
    current_hp_timely_filing_index].auto_release_days,
    hptf.limit_days = reqcopy->timely_filings[current_hp_timely_filing_index].limit_days, hptf
    .notify_days = reqcopy->timely_filings[current_hp_timely_filing_index].notify_days, hptf
    .updt_dt_tm = cnvtdatetime(cur_dt_tm),
    hptf.updt_id = reqinfo->updt_id, hptf.updt_task = reqinfo->updt_task, hptf.updt_applctx = reqinfo
    ->updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 008: Unable to insert new timely filing configuration row.")
 END ;Subroutine
 SUBROUTINE modifyhealthplantimelyfiling(current_hp_timely_filing_index)
   CALL lockhealthplantimelyfiling(current_hp_timely_filing_index)
   UPDATE  FROM health_plan_timely_filing hptf
    SET hptf.auto_release_days = reqcopy->timely_filings[current_hp_timely_filing_index].
     auto_release_days, hptf.limit_days = reqcopy->timely_filings[current_hp_timely_filing_index].
     limit_days, hptf.notify_days = reqcopy->timely_filings[current_hp_timely_filing_index].
     notify_days,
     hptf.updt_cnt = (hptf.updt_cnt+ 1), hptf.updt_dt_tm = cnvtdatetime(cur_dt_tm), hptf.updt_id =
     reqinfo->updt_id,
     hptf.updt_task = reqinfo->updt_task, hptf.updt_applctx = reqinfo->updt_applctx
    WHERE (hptf.health_plan_timely_filing_id=reqcopy->timely_filings[current_hp_timely_filing_index].
    health_plan_timely_filing_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 009: Modifying health plan timely filing configuration failed.")
 END ;Subroutine
 SUBROUTINE removehealthplantimelyfiling(current_hp_timely_filing_index)
  DELETE  FROM health_plan_timely_filing hptf
   WHERE (hptf.health_plan_id=reqcopy->timely_filings[current_hp_timely_filing_index].health_plan_id)
   WITH nocounter
  ;end delete
  CALL bederrorcheck("ERROR 010: Deleting health plan timely filing configuration failed.")
 END ;Subroutine
END GO
