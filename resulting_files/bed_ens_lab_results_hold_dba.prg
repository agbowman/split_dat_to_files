CREATE PROGRAM bed_ens_lab_results_hold:dba
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
 DECLARE added_lab_results_hold_cnt = i2 WITH protect, constant(size(request->addedlabresultsholds,5)
  )
 DECLARE updated_lab_results_hold_cnt = i2 WITH protect, constant(size(request->
   updatedlabresultsholds,5))
 DECLARE deleted_lab_results_hold_cnt = i2 WITH protect, constant(size(request->
   deletedlabresultsholds,5))
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE addedlabresultholdindex = i4 WITH protect, noconstant(0)
 DECLARE updatedlabresultholdindex = i4 WITH protect, noconstant(0)
 DECLARE deletedlabresultholdindex = i4 WITH protect, noconstant(0)
 DECLARE addlabresultshold(addedlabresultholdindex=i4) = null
 DECLARE updatelabresultshold(updatedlabresultholdindex=i4) = null
 DECLARE deletelabresultshold(deletedlabresultholdindex=i4) = null
 FOR (addedlabresultholdindex = 1 TO added_lab_results_hold_cnt)
   CALL addlabresultshold(addedlabresultholdindex)
 ENDFOR
 FOR (updatedlabresultholdindex = 1 TO updated_lab_results_hold_cnt)
   CALL updatelabresultshold(updatedlabresultholdindex)
 ENDFOR
 FOR (deletedlabresultholdindex = 1 TO deleted_lab_results_hold_cnt)
   CALL deletelabresultshold(deletedlabresultholdindex)
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE addlabresultshold(addedlabresultholdindex)
   CALL bedlogmessage("addLabResultsHold","Entering ...")
   DECLARE holdresultsconfigid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     holdresultsconfigid = cnvtreal(j)
    WITH nocounter
   ;end select
   CALL logdebugmessage("AddedLabResultHoldIndex: ",addedlabresultholdindex)
   CALL logdebugmessage("HoldResultsConfigId: ",holdresultsconfigid)
   INSERT  FROM order_results_hold_config o
    SET o.order_results_hold_config_id = holdresultsconfigid, o.catalog_cd = request->
     addedlabresultsholds[addedlabresultholdindex].catalogcd, o.location_cd = request->
     addedlabresultsholds[addedlabresultholdindex].facilitycd,
     o.encounter_type_class_cd = request->addedlabresultsholds[addedlabresultholdindex].
     encountertypecd, o.hold_flag = 1, o.updt_cnt = 0,
     o.logical_domain_id = logical_domain_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o
     .updt_id = reqinfo->updt_id,
     o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bedlogmessage("addLabResultsHold","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatelabresultshold(updatedlabresultholdindex)
   CALL bedlogmessage("updateLabResultsHold","Entering ...")
   CALL logdebugmessage("HoldResultsConfigId: ",request->updatedlabresultsholds[
    updatedlabresultholdindex].labresultsholdid)
   UPDATE  FROM order_results_hold_config o
    SET o.catalog_cd = request->updatedlabresultsholds[updatedlabresultholdindex].catalogcd, o
     .location_cd = request->updatedlabresultsholds[updatedlabresultholdindex].facilitycd, o
     .encounter_type_class_cd = request->updatedlabresultsholds[updatedlabresultholdindex].
     encountertypecd,
     o.logical_domain_id = logical_domain_id, o.updt_cnt = (o.updt_cnt+ 1)
    WHERE (o.order_results_hold_config_id=request->updatedlabresultsholds[updatedlabresultholdindex].
    labresultsholdid)
    WITH nocounter
   ;end update
   CALL bedlogmessage("updateLabResultsHold","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletelabresultshold(deletedlabresultholdindex)
   CALL bedlogmessage("deleteLabResultsHold","Entering ...")
   CALL logdebugmessage("Catalog Cd: ",request->deletedlabresultsholds[deletedlabresultholdindex].
    catalogcd)
   CALL logdebugmessage("Facility Cd: ",request->deletedlabresultsholds[deletedlabresultholdindex].
    facilitycd)
   CALL logdebugmessage("Encounter Type Cd: ",request->deletedlabresultsholds[
    deletedlabresultholdindex].encountertypecd)
   DELETE  FROM order_results_hold_config o
    WHERE (o.catalog_cd=request->deletedlabresultsholds[deletedlabresultholdindex].catalogcd)
     AND (o.location_cd=request->deletedlabresultsholds[deletedlabresultholdindex].facilitycd)
     AND (o.encounter_type_class_cd=request->deletedlabresultsholds[deletedlabresultholdindex].
    encountertypecd)
     AND o.logical_domain_id=logical_domain_id
     AND o.order_results_hold_config_id > 0
    WITH nocounter
   ;end delete
   CALL bedlogmessage("deleteLabResultsHold","Exiting ...")
 END ;Subroutine
END GO
