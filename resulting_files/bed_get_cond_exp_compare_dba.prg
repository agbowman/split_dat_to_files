CREATE PROGRAM bed_get_cond_exp_compare:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 cnt_cond_expression_key_uid = vc
    1 dcp_cond_expression_ref_id = f8
    1 expression_name = vc
    1 expression_status = vc
    1 expression_txt = vc
    1 content_expression_txt = vc
    1 content_triggers[*]
      2 trigger_name = vc
      2 trigger_name_status = vc
      2 trigger_dta_mnemonic = vc
      2 trigger_dta_status = vc
      2 operator_display = vc
      2 operator_status = vc
      2 value_display = vc
      2 value_display_status = vc
    1 existing_triggers[*]
      2 trigger_name = vc
      2 trigger_name_status = vc
      2 trigger_dta_mnemonic = vc
      2 trigger_dta_status = vc
      2 operator_display = vc
      2 operator_status = vc
      2 value_display = vc
      2 value_display_status = vc
    1 content_cond_dtas[*]
      2 conditional_assay_mnemonic = vc
      2 conditional_assay_status = vc
      2 required_ind = i2
      2 required_ind_status = vc
      2 ref_range_display = vc
      2 ref_range_status = vc
      2 gender_display = vc
      2 gender_status = vc
      2 location_display = vc
      2 location_status = vc
      2 position_display = vc
      2 position_status = vc
    1 existing_cond_dtas[*]
      2 conditional_assay_mnemonic = vc
      2 conditional_assay_status = vc
      2 required_ind = i2
      2 required_ind_status = vc
      2 ref_range_display = vc
      2 ref_range_status = vc
      2 gender_display = vc
      2 gender_status = vc
      2 location_display = vc
      2 location_status = vc
      2 position_display = vc
      2 position_status = vc
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
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 CALL bedbeginscript(0)
 DECLARE expressionuid = vc WITH protect, constant(request->cnt_cond_expression_key_uid)
 DECLARE matchexpressionid = f8 WITH protect, noconstant(0)
 DECLARE populatenewexpression(expressionuid=vc) = i2
 DECLARE populatemodifiedexpression(expressionuid=vc,matchexpressionid=f8) = i2
 DECLARE constructrefrangedisplay(agefrom=i4,agefromunit=vc,ageto=i4,agetounit=vc) = vc
 DECLARE determineexistingresultvalue(triggerassaycd=f8,operatorcd=f8,resultvaluenbr=f8,
  parententityname=vc,parententityid=f8) = vc
 DECLARE determinecontentresultvalue(triggerassaycd=f8,operatorcd=f8,resultvaluenbr=f8,aruid=vc) = vc
 DECLARE getexpressionstatus(dummyvar=vc) = vc
 SELECT INTO "nl:"
  FROM cnt_cond_expression_key k,
   cond_expression ce
  PLAN (k
   WHERE k.cnt_cond_expression_key_uid=expressionuid)
   JOIN (ce
   WHERE ce.cond_expression_name=outerjoin(k.cond_expression_name)
    AND ce.active_ind=true)
  DETAIL
   matchexpressionid = ce.cond_expression_id
  WITH nocounter
 ;end select
 IF (matchexpressionid=0)
  CALL populatenewexpression(expressionuid)
 ELSE
  CALL populatemodifiedexpression(expressionuid,matchexpressionid)
 ENDIF
 SET reply->expression_status = getexpressionstatus(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE populatenewexpression(expressionuid)
   CALL bedlogmessage("populateNewExpression","Entering ...")
   DECLARE tcnt = i4 WITH protect, noconstant(0)
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   FREE RECORD contentexpressionrequest
   RECORD contentexpressionrequest(
     1 cnt_cond_expression_key_uid = vc
   )
   FREE RECORD contentexpressionreply
   RECORD contentexpressionreply(
     1 cnt_cond_expression_key_uid = vc
     1 cnt_cond_expression_id = f8
     1 cnt_cond_expression_name = vc
     1 cnt_cond_expression_txt = vc
     1 cnt_cond_postfix_txt = vc
     1 cnt_multiple_ind = i2
     1 dcp_cond_expression_ref_id = f8
     1 cnt_exp_comp[*]
       2 cnt_cond_exprsn_comp_key_uid = vc
       2 cnt_cond_comp_name = vc
       2 cond_exprsn_comp_id = f8
       2 operator_cd_uid = vc
       2 cnt_operator_cd_display = vc
       2 cnt_operator_cd_meaning = vc
       2 operator_cd = f8
       2 ar_uid = vc
       2 nomenclature_name = vc
       2 cnt_required_ind = i2
       2 trigger_assay_cd_uid = vc
       2 cnt_trigger_assay_cd_description = vc
       2 cnt_trigger_assay_cd_mnemonic = vc
       2 trigger_assay_cd = f8
       2 cnt_result_value = f8
     1 cnt_cond_dtas[*]
       2 cnt_age_from_nbr = i4
       2 age_from_nbr = i4
       2 age_from_unit_cd_uid = vc
       2 cnt_age_from_unit_cd_display = vc
       2 cnt_age_from_unit_cd_meaning = vc
       2 age_from_unit_cd = f8
       2 cnt_age_to_nbr = i4
       2 age_to_unit_cd_uid = vc
       2 cnt_age_to_unit_cd_display = vc
       2 cnt_age_to_unit_cd_meaning = vc
       2 age_to_unit_cd = f8
       2 conditional_assay_cd_uid = vc
       2 cnt_conditional_assay_cd_description = vc
       2 cnt_conditional_assay_cd_mnemonic = vc
       2 conditional_assay_cd = f8
       2 gender_cd_uid = vc
       2 cnt_gender_cd_display = vc
       2 cnt_gender_cd_meaning = vc
       2 gender_cd = f8
       2 position_cd_uid = vc
       2 cnt_position_cd_display = vc
       2 cnt_position_cd_meaning = vc
       2 position_cd = f8
       2 location_cd_uid = vc
       2 cnt_location_cd_display = vc
       2 cnt_location_cd_meaning = vc
       2 location_cd = f8
       2 cnt_required_ind = i2
       2 cnt_unknown_age_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET contentexpressionrequest->cnt_cond_expression_key_uid = expressionuid
   EXECUTE bed_get_cnt_cond_expn_detail  WITH replace("REQUEST",contentexpressionrequest), replace(
    "REPLY",contentexpressionreply)
   IF ((contentexpressionreply->status_data.status != "S"))
    CALL bederror("bed_get_cnt_cond_expn_detail did not return success")
   ENDIF
   SET reply->cnt_cond_expression_key_uid = expressionuid
   SET reply->dcp_cond_expression_ref_id = 0
   SET reply->expression_name = contentexpressionreply->cnt_cond_expression_name
   SET reply->expression_status = added
   SET reply->content_expression_txt = contentexpressionreply->cnt_cond_expression_txt
   SET stat = alterlist(reply->content_triggers,size(contentexpressionreply->cnt_exp_comp,5))
   FOR (tcnt = 1 TO size(contentexpressionreply->cnt_exp_comp,5))
     SET reply->content_triggers[tcnt].trigger_name = contentexpressionreply->cnt_exp_comp[tcnt].
     cnt_cond_comp_name
     SET reply->content_triggers[tcnt].trigger_name_status = added
     SET reply->content_triggers[tcnt].trigger_dta_mnemonic = contentexpressionreply->cnt_exp_comp[
     tcnt].cnt_trigger_assay_cd_mnemonic
     SET reply->content_triggers[tcnt].trigger_dta_status = added
     SET reply->content_triggers[tcnt].operator_display = contentexpressionreply->cnt_exp_comp[tcnt].
     cnt_operator_cd_display
     SET reply->content_triggers[tcnt].operator_status = added
     SET reply->content_triggers[tcnt].value_display = determinecontentresultvalue(
      contentexpressionreply->cnt_exp_comp[tcnt].trigger_assay_cd,contentexpressionreply->
      cnt_exp_comp[tcnt].operator_cd,contentexpressionreply->cnt_exp_comp[tcnt].cnt_result_value,
      contentexpressionreply->cnt_exp_comp[tcnt].ar_uid)
     SET reply->content_triggers[tcnt].value_display_status = added
   ENDFOR
   SET stat = alterlist(reply->content_cond_dtas,size(contentexpressionreply->cnt_cond_dtas,5))
   FOR (ccnt = 1 TO size(contentexpressionreply->cnt_cond_dtas,5))
     SET reply->content_cond_dtas[ccnt].conditional_assay_mnemonic = contentexpressionreply->
     cnt_cond_dtas[ccnt].cnt_conditional_assay_cd_mnemonic
     SET reply->content_cond_dtas[ccnt].conditional_assay_status = added
     SET reply->content_cond_dtas[ccnt].required_ind = contentexpressionreply->cnt_cond_dtas[ccnt].
     cnt_required_ind
     SET reply->content_cond_dtas[ccnt].required_ind_status = added
     IF ((contentexpressionreply->cnt_cond_dtas[ccnt].age_from_unit_cd_uid="")
      AND (contentexpressionreply->cnt_cond_dtas[ccnt].age_to_unit_cd_uid=""))
      SET reply->content_cond_dtas[ccnt].ref_range_display = "All"
     ELSE
      SET reply->content_cond_dtas[ccnt].ref_range_display = constructrefrangedisplay(
       contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_from_nbr,contentexpressionreply->
       cnt_cond_dtas[ccnt].cnt_age_from_unit_cd_display,contentexpressionreply->cnt_cond_dtas[ccnt].
       cnt_age_to_nbr,contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_to_unit_cd_display)
     ENDIF
     SET reply->content_cond_dtas[ccnt].ref_range_status = added
     SET reply->content_cond_dtas[ccnt].gender_display = contentexpressionreply->cnt_cond_dtas[ccnt].
     cnt_gender_cd_meaning
     SET reply->content_cond_dtas[ccnt].gender_status = added
     SET reply->content_cond_dtas[ccnt].location_display = contentexpressionreply->cnt_cond_dtas[ccnt
     ].cnt_location_cd_display
     SET reply->content_cond_dtas[ccnt].location_status = added
     SET reply->content_cond_dtas[ccnt].position_display = contentexpressionreply->cnt_cond_dtas[ccnt
     ].cnt_position_cd_display
     SET reply->content_cond_dtas[ccnt].position_status = added
   ENDFOR
   CALL bedlogmessage("populateNewExpression","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatemodifiedexpression(expressionuid,matchexpressionid)
   CALL bedlogmessage("populateModifiedExpression","Entering ...")
   CALL echo(build2("ExpressionUID:",expressionuid))
   CALL echo(build2("MatchedExpressionID:",matchexpressionid))
   DECLARE tcnt = i4 WITH protect, noconstant(0)
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   DECLARE etcnt = i4 WITH protect, noconstant(0)
   DECLARE eccnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE matchtriggerloc = i4 WITH protect, noconstant(0)
   DECLARE matchconddtaloc = i4 WITH protect, noconstant(0)
   DECLARE status = vc WITH protect, noconstant("")
   FREE RECORD contentexpressionrequest
   RECORD contentexpressionrequest(
     1 cnt_cond_expression_key_uid = vc
   )
   FREE RECORD contentexpressionreply
   RECORD contentexpressionreply(
     1 cnt_cond_expression_key_uid = vc
     1 cnt_cond_expression_id = f8
     1 cnt_cond_expression_name = vc
     1 cnt_cond_expression_txt = vc
     1 cnt_cond_postfix_txt = vc
     1 cnt_multiple_ind = i2
     1 dcp_cond_expression_ref_id = f8
     1 cnt_exp_comp[*]
       2 cnt_cond_exprsn_comp_key_uid = vc
       2 cnt_cond_comp_name = vc
       2 cond_exprsn_comp_id = f8
       2 operator_cd_uid = vc
       2 cnt_operator_cd_display = vc
       2 cnt_operator_cd_meaning = vc
       2 operator_cd = f8
       2 ar_uid = vc
       2 nomenclature_name = vc
       2 cnt_required_ind = i2
       2 trigger_assay_cd_uid = vc
       2 cnt_trigger_assay_cd_description = vc
       2 cnt_trigger_assay_cd_mnemonic = vc
       2 trigger_assay_cd = f8
       2 cnt_result_value = f8
     1 cnt_cond_dtas[*]
       2 cnt_age_from_nbr = i4
       2 age_from_nbr = i4
       2 age_from_unit_cd_uid = vc
       2 cnt_age_from_unit_cd_display = vc
       2 cnt_age_from_unit_cd_meaning = vc
       2 age_from_unit_cd = f8
       2 cnt_age_to_nbr = i4
       2 age_to_unit_cd_uid = vc
       2 cnt_age_to_unit_cd_display = vc
       2 cnt_age_to_unit_cd_meaning = vc
       2 age_to_unit_cd = f8
       2 conditional_assay_cd_uid = vc
       2 cnt_conditional_assay_cd_description = vc
       2 cnt_conditional_assay_cd_mnemonic = vc
       2 conditional_assay_cd = f8
       2 gender_cd_uid = vc
       2 cnt_gender_cd_display = vc
       2 cnt_gender_cd_meaning = vc
       2 gender_cd = f8
       2 position_cd_uid = vc
       2 cnt_position_cd_display = vc
       2 cnt_position_cd_meaning = vc
       2 position_cd = f8
       2 location_cd_uid = vc
       2 cnt_location_cd_display = vc
       2 cnt_location_cd_meaning = vc
       2 location_cd = f8
       2 cnt_required_ind = i2
       2 cnt_unknown_age_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET contentexpressionrequest->cnt_cond_expression_key_uid = expressionuid
   EXECUTE bed_get_cnt_cond_expn_detail  WITH replace("REQUEST",contentexpressionrequest), replace(
    "REPLY",contentexpressionreply)
   IF ((contentexpressionreply->status_data.status != "S"))
    CALL bederror("bed_get_cnt_cond_expn_detail did not return success")
   ENDIF
   FREE RECORD getexistingexpdetailrequest
   RECORD getexistingexpdetailrequest(
     1 cond_expression_id = f8
   )
   FREE RECORD getexistingexpdetailreply
   RECORD getexistingexpdetailreply(
     1 cond_expression_id = f8
     1 cond_expression_name = c100
     1 cond_expression_txt = c512
     1 cond_postfix_txt = c512
     1 multiple_ind = i2
     1 exp_comp[*]
       2 cond_comp_name = c30
       2 cond_expression_comp_id = f8
       2 operator_cd = f8
       2 operator_cd_display = vc
       2 operator_cd_meaning = vc
       2 parent_entity_id = f8
       2 parent_entity_name = c60
       2 required_ind = i2
       2 trigger_assay_cd = f8
       2 trigger_assay_cd_description = vc
       2 trigger_assay_cd_mnemonic = vc
       2 result_value = f8
       2 cond_expression_id = f8
     1 cond_dtas[*]
       2 age_from_nbr = i4
       2 age_from_unit_cd = f8
       2 age_from_unit_cd_display = vc
       2 age_from_unit_cd_meaning = vc
       2 age_to_nbr = i4
       2 age_to_unit_cd = f8
       2 age_to_unit_cd_display = vc
       2 age_to_unit_cd_meaning = vc
       2 conditional_assay_cd = f8
       2 conditional_assay_cd_description = vc
       2 conditional_assay_cd_mnemonic = vc
       2 conditional_dta_id = f8
       2 cond_expression_id = f8
       2 gender_cd = f8
       2 gender_cd_display = vc
       2 gender_cd_meaning = vc
       2 location_cd = f8
       2 location_cd_display = vc
       2 location_cd_meaning = vc
       2 position_cd = f8
       2 position_cd_display = vc
       2 position_cd_meaning = vc
       2 required_ind = i2
       2 unknown_age_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET getexistingexpdetailrequest->cond_expression_id = matchexpressionid
   EXECUTE bed_get_cond_expression_detail  WITH replace("REQUEST",getexistingexpdetailrequest),
   replace("REPLY",getexistingexpdetailreply)
   IF ((getexistingexpdetailreply->status_data.status != "S"))
    CALL bederror("bed_get_cond_expression_detail did not return success")
   ENDIF
   SET reply->cnt_cond_expression_key_uid = expressionuid
   SET reply->dcp_cond_expression_ref_id = matchexpressionid
   SET reply->expression_name = contentexpressionreply->cnt_cond_expression_name
   SET reply->expression_status = modified
   SET reply->content_expression_txt = contentexpressionreply->cnt_cond_expression_txt
   SET reply->expression_txt = getexistingexpdetailreply->cond_expression_txt
   SET stat = alterlist(reply->content_triggers,size(contentexpressionreply->cnt_exp_comp,5))
   FOR (tcnt = 1 TO size(contentexpressionreply->cnt_exp_comp,5))
     SET num = 1
     SET matchtriggerloc = locateval(num,1,size(getexistingexpdetailreply->exp_comp,5),
      contentexpressionreply->cnt_exp_comp[tcnt].cnt_cond_comp_name,getexistingexpdetailreply->
      exp_comp[num].cond_comp_name)
     IF (matchtriggerloc > 0)
      SET etcnt = (size(reply->existing_triggers,5)+ 1)
      SET stat = alterlist(reply->existing_triggers,etcnt)
      SET reply->content_triggers[tcnt].trigger_dta_mnemonic = contentexpressionreply->cnt_exp_comp[
      tcnt].cnt_trigger_assay_cd_mnemonic
      SET reply->existing_triggers[etcnt].trigger_dta_mnemonic = getexistingexpdetailreply->exp_comp[
      matchtriggerloc].trigger_assay_cd_mnemonic
      SET status = none
      IF ((contentexpressionreply->cnt_exp_comp[tcnt].trigger_assay_cd != getexistingexpdetailreply->
      exp_comp[matchtriggerloc].trigger_assay_cd))
       SET status = modified
      ENDIF
      SET reply->content_triggers[tcnt].trigger_dta_status = status
      SET reply->existing_triggers[etcnt].trigger_dta_status = status
      SET status = none
      IF ((contentexpressionreply->cnt_exp_comp[tcnt].cnt_cond_comp_name != getexistingexpdetailreply
      ->exp_comp[matchtriggerloc].cond_comp_name))
       SET status = modified
      ENDIF
      SET reply->content_triggers[tcnt].trigger_name = contentexpressionreply->cnt_exp_comp[tcnt].
      cnt_cond_comp_name
      SET reply->content_triggers[tcnt].trigger_name_status = status
      SET reply->existing_triggers[etcnt].trigger_name = getexistingexpdetailreply->exp_comp[
      matchtriggerloc].cond_comp_name
      SET reply->existing_triggers[etcnt].trigger_name_status = status
      SET status = none
      IF ((contentexpressionreply->cnt_exp_comp[tcnt].operator_cd != getexistingexpdetailreply->
      exp_comp[matchtriggerloc].operator_cd))
       SET status = modified
      ENDIF
      SET reply->content_triggers[tcnt].operator_display = contentexpressionreply->cnt_exp_comp[tcnt]
      .cnt_operator_cd_display
      SET reply->content_triggers[tcnt].operator_status = status
      SET reply->existing_triggers[etcnt].operator_display = getexistingexpdetailreply->exp_comp[
      matchtriggerloc].operator_cd_display
      SET reply->existing_triggers[etcnt].operator_status = status
      SET status = none
      SET reply->content_triggers[tcnt].value_display = determinecontentresultvalue(
       contentexpressionreply->cnt_exp_comp[tcnt].trigger_assay_cd,contentexpressionreply->
       cnt_exp_comp[tcnt].operator_cd,contentexpressionreply->cnt_exp_comp[tcnt].cnt_result_value,
       contentexpressionreply->cnt_exp_comp[tcnt].ar_uid)
      SET reply->existing_triggers[etcnt].value_display = determineexistingresultvalue(
       getexistingexpdetailreply->exp_comp[matchtriggerloc].trigger_assay_cd,
       getexistingexpdetailreply->exp_comp[matchtriggerloc].operator_cd,getexistingexpdetailreply->
       exp_comp[matchtriggerloc].result_value,getexistingexpdetailreply->exp_comp[matchtriggerloc].
       parent_entity_name,getexistingexpdetailreply->exp_comp[matchtriggerloc].parent_entity_id)
      IF ((reply->content_triggers[tcnt].value_display != reply->existing_triggers[etcnt].
      value_display))
       SET status = modified
      ENDIF
      SET reply->content_triggers[tcnt].value_display_status = status
      SET reply->existing_triggers[etcnt].value_display_status = status
     ELSE
      SET reply->content_triggers[tcnt].trigger_name = contentexpressionreply->cnt_exp_comp[tcnt].
      cnt_cond_comp_name
      SET reply->content_triggers[tcnt].trigger_name_status = added
      SET reply->content_triggers[tcnt].trigger_dta_mnemonic = contentexpressionreply->cnt_exp_comp[
      tcnt].cnt_trigger_assay_cd_mnemonic
      SET reply->content_triggers[tcnt].trigger_dta_status = added
      SET reply->content_triggers[tcnt].operator_display = contentexpressionreply->cnt_exp_comp[tcnt]
      .cnt_operator_cd_display
      SET reply->content_triggers[tcnt].operator_status = added
      SET reply->content_triggers[tcnt].value_display = determinecontentresultvalue(
       contentexpressionreply->cnt_exp_comp[tcnt].trigger_assay_cd,contentexpressionreply->
       cnt_exp_comp[tcnt].operator_cd,contentexpressionreply->cnt_exp_comp[tcnt].cnt_result_value,
       contentexpressionreply->cnt_exp_comp[tcnt].ar_uid)
      SET reply->content_triggers[tcnt].value_display_status = added
     ENDIF
   ENDFOR
   FOR (excnt = 1 TO size(getexistingexpdetailreply->exp_comp,5))
     SET num = 1
     SET foundidx = locateval(num,1,size(reply->existing_triggers,5),getexistingexpdetailreply->
      exp_comp[excnt].trigger_assay_cd_mnemonic,reply->existing_triggers[num].trigger_dta_mnemonic)
     IF (foundidx=0)
      SET etcnt = (size(reply->existing_triggers,5)+ 1)
      SET stat = alterlist(reply->existing_triggers,etcnt)
      SET reply->existing_triggers[etcnt].trigger_dta_mnemonic = getexistingexpdetailreply->exp_comp[
      excnt].trigger_assay_cd_mnemonic
      SET reply->existing_triggers[etcnt].trigger_dta_status = removed
      SET reply->existing_triggers[etcnt].trigger_name = getexistingexpdetailreply->exp_comp[excnt].
      cond_comp_name
      SET reply->existing_triggers[etcnt].trigger_name_status = removed
      SET reply->existing_triggers[etcnt].operator_display = getexistingexpdetailreply->exp_comp[
      excnt].operator_cd_display
      SET reply->existing_triggers[etcnt].operator_status = removed
      SET reply->existing_triggers[etcnt].value_display = determineexistingresultvalue(
       getexistingexpdetailreply->exp_comp[excnt].trigger_assay_cd,getexistingexpdetailreply->
       exp_comp[excnt].operator_cd,getexistingexpdetailreply->exp_comp[excnt].result_value,
       getexistingexpdetailreply->exp_comp[excnt].parent_entity_name,getexistingexpdetailreply->
       exp_comp[excnt].parent_entity_id)
      SET reply->existing_triggers[etcnt].value_display_status = removed
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->content_cond_dtas,size(contentexpressionreply->cnt_cond_dtas,5))
   FOR (ccnt = 1 TO size(contentexpressionreply->cnt_cond_dtas,5))
     SET num = 1
     SET matchconddtaloc = locateval(num,1,size(getexistingexpdetailreply->cond_dtas,5),
      contentexpressionreply->cnt_cond_dtas[ccnt].conditional_assay_cd,getexistingexpdetailreply->
      cond_dtas[num].conditional_assay_cd)
     IF (matchconddtaloc > 0)
      SET eccnt = (size(reply->existing_cond_dtas,5)+ 1)
      SET stat = alterlist(reply->existing_cond_dtas,eccnt)
      SET reply->content_cond_dtas[ccnt].conditional_assay_mnemonic = contentexpressionreply->
      cnt_cond_dtas[ccnt].cnt_conditional_assay_cd_mnemonic
      SET reply->content_cond_dtas[ccnt].conditional_assay_status = none
      SET reply->existing_cond_dtas[eccnt].conditional_assay_mnemonic = getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].conditional_assay_cd_mnemonic
      SET reply->existing_cond_dtas[eccnt].conditional_assay_status = none
      SET status = none
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].cnt_required_ind != getexistingexpdetailreply
      ->cond_dtas[matchconddtaloc].required_ind))
       SET status = modified
      ENDIF
      SET reply->content_cond_dtas[ccnt].required_ind = contentexpressionreply->cnt_cond_dtas[ccnt].
      cnt_required_ind
      SET reply->content_cond_dtas[ccnt].required_ind_status = status
      SET reply->existing_cond_dtas[eccnt].required_ind = getexistingexpdetailreply->cond_dtas[
      matchconddtaloc].required_ind
      SET reply->existing_cond_dtas[eccnt].required_ind_status = status
      SET status = none
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].location_cd != getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].location_cd))
       SET status = modified
      ENDIF
      SET reply->content_cond_dtas[ccnt].location_display = contentexpressionreply->cnt_cond_dtas[
      ccnt].cnt_location_cd_display
      SET reply->content_cond_dtas[ccnt].location_status = status
      SET reply->existing_cond_dtas[eccnt].location_display = getexistingexpdetailreply->cond_dtas[
      matchconddtaloc].location_cd_display
      SET reply->existing_cond_dtas[eccnt].location_status = status
      SET status = none
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].position_cd != getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].position_cd))
       SET status = modified
      ENDIF
      SET reply->content_cond_dtas[ccnt].position_display = contentexpressionreply->cnt_cond_dtas[
      ccnt].cnt_position_cd_display
      SET reply->content_cond_dtas[ccnt].position_status = status
      SET reply->existing_cond_dtas[eccnt].position_display = getexistingexpdetailreply->cond_dtas[
      matchconddtaloc].position_cd_display
      SET reply->existing_cond_dtas[eccnt].position_status = status
      SET status = none
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].gender_cd != getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].gender_cd))
       SET status = modified
      ENDIF
      SET reply->content_cond_dtas[ccnt].gender_display = contentexpressionreply->cnt_cond_dtas[ccnt]
      .cnt_gender_cd_display
      SET reply->content_cond_dtas[ccnt].gender_status = status
      SET reply->existing_cond_dtas[eccnt].gender_display = getexistingexpdetailreply->cond_dtas[
      matchconddtaloc].gender_cd_display
      SET reply->existing_cond_dtas[eccnt].gender_status = status
      SET status = none
      IF ((((contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_from_nbr !=
      getexistingexpdetailreply->cond_dtas[matchconddtaloc].age_from_nbr)) OR ((((
      contentexpressionreply->cnt_cond_dtas[ccnt].age_from_unit_cd != getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].age_from_unit_cd)) OR ((((contentexpressionreply->cnt_cond_dtas[ccnt
      ].cnt_age_to_nbr != getexistingexpdetailreply->cond_dtas[matchconddtaloc].age_to_nbr)) OR ((
      contentexpressionreply->cnt_cond_dtas[ccnt].age_to_unit_cd != getexistingexpdetailreply->
      cond_dtas[matchconddtaloc].age_to_unit_cd))) )) )) )
       SET status = modified
      ENDIF
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].age_from_unit_cd_uid="")
       AND (contentexpressionreply->cnt_cond_dtas[ccnt].age_to_unit_cd_uid=""))
       SET reply->content_cond_dtas[ccnt].ref_range_display = "All"
      ELSE
       SET reply->content_cond_dtas[ccnt].ref_range_display = constructrefrangedisplay(
        contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_from_nbr,contentexpressionreply->
        cnt_cond_dtas[ccnt].cnt_age_from_unit_cd_display,contentexpressionreply->cnt_cond_dtas[ccnt].
        cnt_age_to_nbr,contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_to_unit_cd_display)
      ENDIF
      SET reply->content_cond_dtas[ccnt].ref_range_status = status
      IF ((getexistingexpdetailreply->cond_dtas[matchconddtaloc].age_from_unit_cd=0)
       AND (getexistingexpdetailreply->cond_dtas[matchconddtaloc].age_to_unit_cd=0))
       SET reply->existing_cond_dtas[eccnt].ref_range_display = "All"
      ELSE
       SET reply->existing_cond_dtas[eccnt].ref_range_display = constructrefrangedisplay(
        getexistingexpdetailreply->cond_dtas[matchconddtaloc].age_from_nbr,getexistingexpdetailreply
        ->cond_dtas[matchconddtaloc].age_from_unit_cd_display,getexistingexpdetailreply->cond_dtas[
        matchconddtaloc].age_to_nbr,getexistingexpdetailreply->cond_dtas[matchconddtaloc].
        age_to_unit_cd_display)
      ENDIF
      SET reply->existing_cond_dtas[eccnt].ref_range_status = status
     ELSE
      SET reply->content_cond_dtas[ccnt].conditional_assay_mnemonic = contentexpressionreply->
      cnt_cond_dtas[ccnt].cnt_conditional_assay_cd_mnemonic
      SET reply->content_cond_dtas[ccnt].conditional_assay_status = added
      SET reply->content_cond_dtas[ccnt].required_ind = contentexpressionreply->cnt_cond_dtas[ccnt].
      cnt_required_ind
      SET reply->content_cond_dtas[ccnt].required_ind_status = added
      IF ((contentexpressionreply->cnt_cond_dtas[ccnt].age_from_unit_cd_uid="")
       AND (contentexpressionreply->cnt_cond_dtas[ccnt].age_to_unit_cd_uid=""))
       SET reply->content_cond_dtas[ccnt].ref_range_display = "All"
      ELSE
       SET reply->content_cond_dtas[ccnt].ref_range_display = constructrefrangedisplay(
        contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_from_nbr,contentexpressionreply->
        cnt_cond_dtas[ccnt].cnt_age_from_unit_cd_display,contentexpressionreply->cnt_cond_dtas[ccnt].
        cnt_age_to_nbr,contentexpressionreply->cnt_cond_dtas[ccnt].cnt_age_to_unit_cd_display)
      ENDIF
      SET reply->content_cond_dtas[ccnt].ref_range_status = added
      SET reply->content_cond_dtas[ccnt].gender_display = contentexpressionreply->cnt_cond_dtas[ccnt]
      .cnt_gender_cd_meaning
      SET reply->content_cond_dtas[ccnt].gender_status = added
      SET reply->content_cond_dtas[ccnt].location_display = contentexpressionreply->cnt_cond_dtas[
      ccnt].cnt_location_cd_display
      SET reply->content_cond_dtas[ccnt].location_status = added
      SET reply->content_cond_dtas[ccnt].position_display = contentexpressionreply->cnt_cond_dtas[
      ccnt].cnt_position_cd_display
      SET reply->content_cond_dtas[ccnt].position_status = added
     ENDIF
   ENDFOR
   FOR (excnt = 1 TO size(getexistingexpdetailreply->cond_dtas,5))
     SET num = 1
     SET foundidx = locateval(num,1,size(reply->existing_cond_dtas,5),getexistingexpdetailreply->
      cond_dtas[excnt].conditional_assay_cd_mnemonic,reply->existing_cond_dtas[num].
      conditional_assay_mnemonic)
     IF (foundidx=0)
      SET eccnt = (size(reply->existing_cond_dtas,5)+ 1)
      SET stat = alterlist(reply->existing_cond_dtas,eccnt)
      SET reply->existing_cond_dtas[eccnt].conditional_assay_mnemonic = getexistingexpdetailreply->
      cond_dtas[excnt].conditional_assay_cd_mnemonic
      SET reply->existing_cond_dtas[eccnt].conditional_assay_status = removed
      SET reply->existing_cond_dtas[eccnt].required_ind = getexistingexpdetailreply->cond_dtas[excnt]
      .required_ind
      SET reply->existing_cond_dtas[eccnt].required_ind_status = removed
      IF ((getexistingexpdetailreply->cond_dtas[excnt].age_from_unit_cd=0)
       AND (getexistingexpdetailreply->cond_dtas[excnt].age_to_unit_cd=0))
       SET reply->existing_cond_dtas[eccnt].ref_range_display = "All"
      ELSE
       SET reply->existing_cond_dtas[eccnt].ref_range_display = constructrefrangedisplay(
        getexistingexpdetailreply->cond_dtas[excnt].age_from_nbr,getexistingexpdetailreply->
        cond_dtas[excnt].age_from_unit_cd_display,getexistingexpdetailreply->cond_dtas[excnt].
        age_to_nbr,getexistingexpdetailreply->cond_dtas[excnt].age_to_unit_cd_display)
      ENDIF
      SET reply->existing_cond_dtas[eccnt].ref_range_status = removed
      SET reply->existing_cond_dtas[eccnt].gender_display = getexistingexpdetailreply->cond_dtas[
      excnt].gender_cd_display
      SET reply->existing_cond_dtas[eccnt].gender_status = removed
      SET reply->existing_cond_dtas[eccnt].location_display = getexistingexpdetailreply->cond_dtas[
      excnt].location_cd_display
      SET reply->existing_cond_dtas[eccnt].location_status = removed
      SET reply->existing_cond_dtas[eccnt].position_display = getexistingexpdetailreply->cond_dtas[
      excnt].position_cd_display
      SET reply->existing_cond_dtas[eccnt].position_status = removed
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateModifiedExpression","Exiting ...")
 END ;Subroutine
 SUBROUTINE constructrefrangedisplay(agefrom,agefromunit,ageto,agetounit)
   DECLARE refrangedisplay = vc WITH protect, noconstant("")
   SET refrangedisplay = concat(trim(cnvtstring(agefrom),7)," ",agefromunit," - ",trim(cnvtstring(
      ageto),7),
    " ",agetounit)
   RETURN(refrangedisplay)
 END ;Subroutine
 SUBROUTINE determineexistingresultvalue(triggerassaycd,operatorcd,resultvaluenbr,parententityname,
  parententityid)
   DECLARE resultvalue = vc WITH protect, noconstant("")
   DECLARE oroperatorcd = f8 WITH protect, constant(uar_get_code_by("MEANING",31340,"OR"))
   DECLARE isnumeric = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     code_value cv
    WHERE dta.task_assay_cd=triggerassaycd
     AND cv.code_value=dta.default_result_type_cd
    DETAIL
     IF (cv.cdf_meaning IN ("8", "3"))
      isnumeric = true
     ENDIF
    WITH nocounter
   ;end select
   IF (isnumeric
    AND operatorcd=oroperatorcd
    AND resultvaluenbr=1)
    SET resultvalue = "Any response"
   ELSEIF (isnumeric)
    SET resultvalue = trim(cnvtstring(resultvaluenbr),7)
   ENDIF
   IF ( NOT (isnumeric))
    IF (resultvaluenbr=0
     AND parententityname="NOMENCLATURE"
     AND parententityid=1
     AND operatorcd=oroperatorcd)
     SET resultvalue = "Any response"
    ELSEIF (parententityid > 0)
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE n.nomenclature_id=parententityid
      DETAIL
       resultvalue = n.source_string
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(resultvalue)
 END ;Subroutine
 SUBROUTINE determinecontentresultvalue(triggerassaycd,operatorcd,resultvaluenbr,aruid)
   DECLARE resultvalue = vc WITH protect, noconstant("")
   DECLARE oroperatorcd = f8 WITH protect, constant(uar_get_code_by("MEANING",31340,"OR"))
   DECLARE isnumeric = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     code_value cv
    WHERE dta.task_assay_cd=triggerassaycd
     AND cv.code_value=dta.default_result_type_cd
    DETAIL
     IF (cv.cdf_meaning IN ("8", "3"))
      isnumeric = true
     ENDIF
    WITH nocounter
   ;end select
   IF (isnumeric
    AND operatorcd=oroperatorcd
    AND resultvaluenbr=1)
    SET resultvalue = "Any response"
   ELSEIF (isnumeric)
    SET resultvalue = trim(cnvtstring(resultvaluenbr),7)
   ENDIF
   IF ( NOT (isnumeric))
    IF (resultvaluenbr=0
     AND aruid="1"
     AND operatorcd=oroperatorcd)
     SET resultvalue = "Any response"
    ELSEIF (aruid != "")
     SELECT INTO "nl:"
      FROM cnt_alpha_response_key ar
      WHERE ar.ar_uid=aruid
      DETAIL
       resultvalue = ar.source_string
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(resultvalue)
 END ;Subroutine
 SUBROUTINE getexpressionstatus(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt_dta = i4 WITH protect, noconstant(0)
   SET reply->expression_status = none
   FOR (cnt = 1 TO size(reply->content_triggers,5))
     IF ((((reply->content_triggers[cnt].operator_status=added)) OR ((reply->content_triggers[cnt].
     operator_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_triggers[cnt].trigger_dta_status=added)) OR ((reply->content_triggers[cnt]
     .trigger_dta_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_triggers[cnt].trigger_name_status=added)) OR ((reply->content_triggers[cnt
     ].trigger_name_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_triggers[cnt].value_display_status=added)) OR ((reply->content_triggers[
     cnt].value_display_status=modified))) )
      RETURN(modified)
     ENDIF
   ENDFOR
   FOR (cnt_dta = 1 TO size(reply->content_cond_dtas,5))
     IF ((((reply->content_cond_dtas[cnt_dta].conditional_assay_status=added)) OR ((reply->
     content_cond_dtas[cnt_dta].conditional_assay_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_cond_dtas[cnt_dta].gender_status=added)) OR ((reply->content_cond_dtas[
     cnt_dta].gender_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_cond_dtas[cnt_dta].location_status=added)) OR ((reply->content_cond_dtas[
     cnt_dta].location_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_cond_dtas[cnt_dta].position_status=added)) OR ((reply->content_cond_dtas[
     cnt_dta].position_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_cond_dtas[cnt_dta].ref_range_status=added)) OR ((reply->content_cond_dtas[
     cnt_dta].ref_range_status=modified))) )
      RETURN(modified)
     ENDIF
     IF ((((reply->content_cond_dtas[cnt_dta].required_ind_status=added)) OR ((reply->
     content_cond_dtas[cnt_dta].required_ind_status=modified))) )
      RETURN(modified)
     ENDIF
   ENDFOR
   RETURN(none)
 END ;Subroutine
END GO
