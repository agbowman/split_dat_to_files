CREATE PROGRAM bed_ens_erx_status_v6:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 personnel_id = f8
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
 IF ( NOT (validate(cs320_delivered_cd)))
  DECLARE cs320_delivered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,"DELIVERED"))
 ENDIF
 IF ( NOT (validate(cs320_complete_cd)))
  DECLARE cs320_complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,"COMPLETE"))
 ENDIF
 DECLARE add_flag = i2 WITH protect, constant(1)
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ensureservicelevels(dummyvar=i2) = i2
 IF ((request->error_code_value=0)
  AND (((request->status_code_value=cs320_delivered_cd)) OR ((request->status_code_value=
 cs320_complete_cd))) )
  CALL ensureservicelevels(0)
  IF ( NOT ((request->spi IN (""))))
   FREE SET temprequest
   RECORD temprequest(
     1 req_msg_id = vc
     1 spi = vc
     1 prsnl_reltn_id = f8
     1 prsnl_id = f8
     1 parent_entity_id = f8
     1 parent_entity_name = vc
   )
   SET temprequest->req_msg_id = request->message_id
   SET temprequest->spi = request->spi
   SET temprequest->prsnl_reltn_id = 0.0
   SET temprequest->prsnl_id = 0.0
   SET temprequest->parent_entity_id = 0.0
   SET temprequest->parent_entity_name = ""
   FREE SET tempreply
   RECORD tempreply(
     1 prsnl_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   CALL echorecord(temprequest)
   EXECUTE bed_ens_erx_spi  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
   IF ((tempreply->status_data.status="S"))
    CALL echo("bed_ens_erx_spi call successful. New SPI was ensured")
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "SCRIPT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "bed_ens_erx_spi"
   ENDIF
  ENDIF
 ELSE
  CALL echorecord(request)
  UPDATE  FROM eprescribe_detail e
   SET e.status_cd = request->status_code_value, e.error_cd = request->error_code_value, e.error_desc
     = request->error_desc,
    e.updt_id = reqinfo->updt_id, e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->
    updt_applctx,
    e.updt_task = reqinfo->updt_task, e.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (e.message_ident=request->message_id)
   WITH nocounter
  ;end update
  SET reply->status_data.status = "S"
  SET reply->personnel_id = 0.0
  SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SCRIPT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "BED_ENS_ERX_STATUS_V6 request contains error_cd. eprescribe_detail table updated with error_cd."
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE ensureservicelevels(dummyvar)
   CALL bedlogmessage("ensureServiceLevels","Entering ...")
   IF ( NOT (validate(tempstruct,0)))
    RECORD tempstruct(
      1 message_id = vc
      1 status_code_value = f8
      1 error_code_value = f8
      1 error_desc = vc
      1 proposed_service_level = i4
    )
   ENDIF
   SELECT INTO "nl:"
    FROM eprescribe_detail e,
     prsnl_reltn p
    PLAN (e
     WHERE (e.message_ident=request->message_id))
     JOIN (p
     WHERE e.prsnl_reltn_id=p.prsnl_reltn_id)
    DETAIL
     tempstruct->message_id = e.message_ident, tempstruct->error_desc = substring(1,100,request->
      error_desc), tempstruct->error_code_value = request->error_code_value,
     tempstruct->status_code_value = request->status_code_value, tempstruct->proposed_service_level
      = e.prop_service_level_nbr, reply->personnel_id = p.person_id
    WITH nocounter
   ;end select
   CALL echorecord(tempstruct)
   IF ((tempstruct->proposed_service_level > 0))
    SET ierrcode = 0
    UPDATE  FROM eprescribe_detail e
     SET e.status_cd = tempstruct->status_code_value, e.error_cd = tempstruct->error_code_value, e
      .error_desc = tempstruct->error_desc,
      e.updt_id = reqinfo->updt_id, e.updt_cnt = (e.updt_cnt+ 1), e.updt_applctx = reqinfo->
      updt_applctx,
      e.updt_task = reqinfo->updt_task, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
      .service_level_nbr = tempstruct->proposed_service_level,
      e.prop_service_level_nbr = 0
     WHERE (e.message_ident=tempstruct->message_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Update eprescribe_detail rows."
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   CALL bedlogmessage("ensureServiceLevels","Exiting ...")
 END ;Subroutine
END GO
