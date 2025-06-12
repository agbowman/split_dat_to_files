CREATE PROGRAM bed_ens_erx_spi:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_id = f8
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
 IF ( NOT (validate(cs320_spi_cd)))
  DECLARE cs320_spi_cd = f8 WITH protect, noconstant(0.0)
 ENDIF
 DECLARE input_spi = vc WITH protect, noconstant("")
 DECLARE dprsnlreltnid = f8 WITH protect, noconstant(request->prsnl_reltn_id)
 DECLARE dpersonid = f8 WITH protect, noconstant(request->prsnl_id)
 DECLARE dprsnlaliasid = f8 WITH protect, noconstant(0.0)
 DECLARE dorgid = f8 WITH protect, noconstant(0.0)
 DECLARE dloccd = f8 WITH protect, noconstant(0.0)
 DECLARE daliaspoolcd = f8 WITH protect, noconstant(0.0)
 DECLARE determinealiaspoolcdfromreqmsgid(dummyvar=i2) = i2
 DECLARE determinealiaspoolcdfromlocid(dummyvar=i2) = i2
 DECLARE verifyuniquespi(dummyvar=i2) = i2
 DECLARE insertnewalias(dummyvar=i2) = i2
 DECLARE insertspireltns(dummyvar=i2) = i2
 DECLARE getpersonnelidtoreturn(dummyvar=i2) = i2
 SET stat = uar_get_meaning_by_codeset(320,"SPI",1,cs320_spi_cd)
 SET input_spi = request->spi
 SET reply->status_data.status = "S"
 IF ((request->req_msg_id=""))
  CALL determinealiaspoolcdfromlocid(0)
 ELSE
  CALL determinealiaspoolcdfromreqmsgid(0)
 ENDIF
 DECLARE isspiunique = i2 WITH protect, constant(verifyuniquespi(0))
 IF (isspiunique=true)
  CALL insertnewalias(0)
 ELSE
  IF (validate(debug,0)=1)
   CALL bedlogmessage("verifyUniqueSPI",
    " Returned duplicate SPI. SPI exists in millennium. Program will now exit.")
   CALL echorecord(request)
   CALL echorecord(reply)
  ENDIF
  GO TO exit_script
 ENDIF
 CALL insertspireltns(0)
 CALL getpersonnelidtoreturn(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE determinealiaspoolcdfromreqmsgid(dummyvar)
   CALL bedlogmessage("determineAliasPoolCdFromReqMsgId","Entering ...")
   SELECT INTO "nl:"
    FROM eprescribe_detail e,
     prsnl_reltn pr
    PLAN (e)
     JOIN (pr
     WHERE (e.message_ident=request->req_msg_id)
      AND pr.prsnl_reltn_id=e.prsnl_reltn_id)
    DETAIL
     dprsnlreltnid = pr.prsnl_reltn_id, dpersonid = pr.person_id
     IF (pr.parent_entity_name="ORGANIZATION")
      dorgid = pr.parent_entity_id
     ELSEIF (pr.parent_entity_name="LOCATION")
      dloccd = pr.parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "eprescribe_detail/PRSNL_RELTN"
    IF (validate(debug,0)=1)
     CALL bedlogmessage("determineAliasPoolCd",
      "Data missing from eprescribe_detail or prsnl_reltn table.")
     CALL echorecord(request)
     CALL echorecord(reply)
    ENDIF
    GO TO exit_script
   ENDIF
   CALL echo(dloccd)
   CALL echo(dorgid)
   IF (dloccd > 0.0)
    SELECT INTO "nl:"
     l.organization_id, oap.alias_pool_cd
     FROM location l,
      org_alias_pool_reltn oap
     PLAN (l
      WHERE l.location_cd=dloccd)
      JOIN (oap
      WHERE oap.organization_id=l.organization_id
       AND oap.alias_entity_name="PRSNL_ALIAS"
       AND oap.alias_entity_alias_type_cd=cs320_spi_cd)
     DETAIL
      daliaspoolcd = oap.alias_pool_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "LOCATION/ORG_ALIAS_POOL_RELTN"
     GO TO exit_script
    ENDIF
   ELSEIF (dorgid > 0.0)
    SELECT INTO "nl:"
     oap.alias_pool_cd
     FROM org_alias_pool_reltn oap
     WHERE oap.organization_id=dorgid
      AND oap.alias_entity_name="PRSNL_ALIAS"
      AND oap.alias_entity_alias_type_cd=cs320_spi_cd
     DETAIL
      daliaspoolcd = oap.alias_pool_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORG_ALIAS_POOL_RELTN"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL bedlogmessage("determineAliasPoolCdFromReqMsgId","Exiting ...")
 END ;Subroutine
 SUBROUTINE determinealiaspoolcdfromlocid(dummyvar)
   CALL bedlogmessage("determineAliasPoolCdFromLocId","Entering ...")
   SELECT INTO "nl:"
    l.organization_id, oap.alias_pool_cd
    FROM location l,
     org_alias_pool_reltn oap
    PLAN (l
     WHERE (l.location_cd=request->parent_entity_id))
     JOIN (oap
     WHERE oap.organization_id=l.organization_id
      AND oap.alias_entity_name="PRSNL_ALIAS"
      AND oap.alias_entity_alias_type_cd=cs320_spi_cd)
    DETAIL
     daliaspoolcd = oap.alias_pool_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LOCATION/ORG_ALIAS_POOL_RELTN"
    GO TO exit_script
   ENDIF
   CALL bedlogmessage("determineAliasPoolCdFromLocId","Exiting ...")
 END ;Subroutine
 SUBROUTINE verifyuniquespi(dummyvar)
   CALL bedlogmessage("verifyUniqueSPI","Entering ...")
   SELECT INTO "nl:"
    FROM prsnl_alias p
    WHERE p.alias=input_spi
     AND p.active_ind=1
     AND p.alias_pool_cd=daliaspoolcd
     AND p.prsnl_alias_type_cd=cs320_spi_cd
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "PRSNL_ALIAS - DUPLICATE ALIAS EXISTS"
    RETURN(false)
   ENDIF
   RETURN(true)
   CALL bedlogmessage("verifyUniqueSPI","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewalias(dummyvar)
   CALL bedlogmessage("insertNewAlias","Entering ...")
   SELECT INTO "nl:"
    nextseqnum = seq(prsnl_seq,nextval)
    FROM dual
    DETAIL
     dprsnlaliasid = nextseqnum
    WITH nocounter
   ;end select
   INSERT  FROM prsnl_alias p
    SET p.prsnl_alias_id = dprsnlaliasid, p.person_id = dpersonid, p.alias_pool_cd = daliaspoolcd,
     p.prsnl_alias_type_cd = cs320_spi_cd, p.alias = request->spi, p.data_status_cd = reqdata->
     data_status_cd,
     p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id,
     p.active_ind = 1,
     p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), p.active_status_cd = reqdata->active_status_cd,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
     updt_id, p.updt_cnt = 0,
     p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bedlogmessage("insertNewAlias","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertspireltns(dummyvar)
   CALL bedlogmessage("insertSPIReltns","Entering ...")
   INSERT  FROM prsnl_reltn_child p
    SET p.prsnl_reltn_child_id = seq(person_only_seq,nextval), p.prsnl_reltn_id = dprsnlreltnid, p
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.display_seq = - (1), p.parent_entity_id
      = dprsnlaliasid,
     p.parent_entity_name = "PRSNL_ALIAS", p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bedlogmessage("insertSPIReltns","Exiting ...")
 END ;Subroutine
 SUBROUTINE getpersonnelidtoreturn(dummyvar)
   CALL bedlogmessage("getPersonnelIdToReturn","Entering ...")
   SELECT INTO "nl:"
    FROM prsnl_reltn p
    WHERE p.prsnl_reltn_id=dprsnlreltnid
    DETAIL
     reply->prsnl_id = p.person_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("getPersonnelIdToReturn","Exiting ...")
 END ;Subroutine
END GO
