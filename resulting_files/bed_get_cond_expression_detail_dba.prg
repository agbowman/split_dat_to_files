CREATE PROGRAM bed_get_cond_expression_detail:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 cond_expression_id = f8
    1 cond_expression_name = vc
    1 cond_expression_txt = vc
    1 cond_postfix_txt = vc
    1 multiple_ind = i2
    1 exp_comp[*]
      2 cond_comp_name = vc
      2 cond_expression_comp_id = f8
      2 operator_cd = f8
      2 operator_cd_display = vc
      2 operator_cd_meaning = vc
      2 parent_entity_id = f8
      2 parent_entity_name = vc
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
 DECLARE comp_cnt = i4 WITH noconstant(0)
 DECLARE dta_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM cond_expression ce,
   cond_expression_comp cec,
   discrete_task_assay dta
  PLAN (ce
   WHERE (ce.cond_expression_id=request->cond_expression_id)
    AND ce.active_ind=true)
   JOIN (cec
   WHERE cec.cond_expression_id=ce.cond_expression_id
    AND cec.active_ind=true)
   JOIN (dta
   WHERE dta.task_assay_cd=cec.trigger_assay_cd
    AND dta.active_ind=true)
  ORDER BY ce.cond_expression_id, cec.cond_expression_comp_id
  HEAD ce.cond_expression_id
   reply->cond_expression_id = ce.cond_expression_id, reply->cond_expression_name = ce
   .cond_expression_name, reply->cond_expression_txt = ce.cond_expression_txt,
   reply->cond_postfix_txt = ce.cond_postfix_txt, comp_cnt = 0
  HEAD cec.cond_expression_comp_id
   comp_cnt = (comp_cnt+ 1), stat = alterlist(reply->exp_comp,comp_cnt), reply->exp_comp[comp_cnt].
   cond_comp_name = cec.cond_comp_name,
   reply->exp_comp[comp_cnt].cond_expression_comp_id = cec.cond_expression_comp_id, reply->exp_comp[
   comp_cnt].cond_expression_id = cec.cond_expression_id, reply->exp_comp[comp_cnt].operator_cd = cec
   .operator_cd,
   reply->exp_comp[comp_cnt].operator_cd_display = uar_get_code_display(cec.operator_cd), reply->
   exp_comp[comp_cnt].operator_cd_meaning = uar_get_code_meaning(cec.operator_cd), reply->exp_comp[
   comp_cnt].parent_entity_id = cec.parent_entity_id,
   reply->exp_comp[comp_cnt].parent_entity_name = cec.parent_entity_name, reply->exp_comp[comp_cnt].
   required_ind = cec.required_ind, reply->exp_comp[comp_cnt].result_value = cec.result_value,
   reply->exp_comp[comp_cnt].trigger_assay_cd = cec.trigger_assay_cd, reply->exp_comp[comp_cnt].
   trigger_assay_cd_description = dta.description, reply->exp_comp[comp_cnt].
   trigger_assay_cd_mnemonic = dta.mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM conditional_dta cd,
   discrete_task_assay dta
  PLAN (cd
   WHERE (cd.cond_expression_id=request->cond_expression_id)
    AND cd.active_ind=true)
   JOIN (dta
   WHERE dta.task_assay_cd=cd.conditional_assay_cd)
  DETAIL
   dta_cnt = (dta_cnt+ 1), stat = alterlist(reply->cond_dtas,dta_cnt), reply->cond_dtas[dta_cnt].
   age_from_nbr = cd.age_from_nbr,
   reply->cond_dtas[dta_cnt].age_from_unit_cd = cd.age_from_unit_cd, reply->cond_dtas[dta_cnt].
   age_from_unit_cd_display = uar_get_code_display(cd.age_from_unit_cd), reply->cond_dtas[dta_cnt].
   age_from_unit_cd_meaning = uar_get_code_meaning(cd.age_from_unit_cd),
   reply->cond_dtas[dta_cnt].age_to_nbr = cd.age_to_nbr, reply->cond_dtas[dta_cnt].age_to_unit_cd =
   cd.age_to_unit_cd, reply->cond_dtas[dta_cnt].age_to_unit_cd_display = uar_get_code_display(cd
    .age_to_unit_cd),
   reply->cond_dtas[dta_cnt].age_to_unit_cd_meaning = uar_get_code_meaning(cd.age_to_unit_cd), reply
   ->cond_dtas[dta_cnt].cond_expression_id = cd.cond_expression_id, reply->cond_dtas[dta_cnt].
   conditional_assay_cd = cd.conditional_assay_cd,
   reply->cond_dtas[dta_cnt].conditional_assay_cd_description = dta.description, reply->cond_dtas[
   dta_cnt].conditional_assay_cd_mnemonic = dta.mnemonic, reply->cond_dtas[dta_cnt].
   conditional_dta_id = cd.conditional_dta_id,
   reply->cond_dtas[dta_cnt].gender_cd = cd.gender_cd, reply->cond_dtas[dta_cnt].gender_cd_display =
   uar_get_code_display(cd.gender_cd), reply->cond_dtas[dta_cnt].gender_cd_meaning =
   uar_get_code_meaning(cd.gender_cd),
   reply->cond_dtas[dta_cnt].location_cd = cd.location_cd, reply->cond_dtas[dta_cnt].
   location_cd_display = uar_get_code_display(cd.location_cd), reply->cond_dtas[dta_cnt].
   location_cd_meaning = uar_get_code_meaning(cd.location_cd),
   reply->cond_dtas[dta_cnt].position_cd = cd.position_cd, reply->cond_dtas[dta_cnt].
   position_cd_display = uar_get_code_display(cd.position_cd), reply->cond_dtas[dta_cnt].
   position_cd_meaning = uar_get_code_meaning(cd.position_cd),
   reply->cond_dtas[dta_cnt].required_ind = cd.required_ind, reply->cond_dtas[dta_cnt].
   unknown_age_ind = cd.unknown_age_ind
  WITH nocounter
 ;end select
#exit_script
 CALL bedexitscript(0)
END GO
