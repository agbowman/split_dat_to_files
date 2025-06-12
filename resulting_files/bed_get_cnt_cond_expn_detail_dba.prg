CREATE PROGRAM bed_get_cnt_cond_expn_detail:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 DECLARE get_me_code_value(code_value_uid=vc) = f8
 DECLARE get_me_cv_display(code_value_uid=vc) = vc
 DECLARE get_me_cv_meaning(code_value_uid=vc) = vc
 DECLARE comp_cnt = i4 WITH noconstant(0)
 DECLARE dta_cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM cnt_cond_expression_key ccek,
   cnt_cond_exprsn_comp_key compkey,
   cnt_dta_key2 cdk,
   cnt_dta cd,
   cnt_code_value_key cv,
   cnt_alpha_response_key cark,
   discrete_task_assay dta
  PLAN (ccek
   WHERE (ccek.cnt_cond_expression_key_uid=request->cnt_cond_expression_key_uid)
    AND ccek.active_ind=true)
   JOIN (compkey
   WHERE compkey.cond_exprsn_id=ccek.cond_expression_id
    AND compkey.active_ind=true)
   JOIN (cdk
   WHERE cdk.task_assay_uid=compkey.trigger_assay_cd_uid)
   JOIN (cd
   WHERE cd.task_assay_uid=cdk.task_assay_uid)
   JOIN (cv
   WHERE cv.code_value_uid=compkey.operator_cd_uid)
   JOIN (cark
   WHERE cark.ar_uid=outerjoin(compkey.ar_uid))
   JOIN (dta
   WHERE dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
    AND dta.activity_type_cd=outerjoin(cd.activity_type_cd)
    AND dta.active_ind=outerjoin(1))
  ORDER BY ccek.cond_expression_id, compkey.cnt_cond_exprsn_comp_key_uid
  HEAD ccek.cond_expression_id
   reply->cnt_cond_expression_key_uid = ccek.cnt_cond_expression_key_uid, reply->
   cnt_cond_expression_id = ccek.cond_expression_id, reply->cnt_cond_expression_name = ccek
   .cond_expression_name,
   reply->cnt_cond_expression_txt = ccek.cond_expression_txt, reply->cnt_cond_postfix_txt = ccek
   .cond_postfix_txt, reply->cnt_multiple_ind = ccek.multiple_ind,
   reply->dcp_cond_expression_ref_id = ccek.dcp_cond_expression_ref_id, comp_cnt = 0
  HEAD compkey.cnt_cond_exprsn_comp_key_uid
   comp_cnt = (comp_cnt+ 1), stat = alterlist(reply->cnt_exp_comp,comp_cnt), reply->cnt_exp_comp[
   comp_cnt].cnt_cond_exprsn_comp_key_uid = compkey.cnt_cond_exprsn_comp_key_uid,
   reply->cnt_exp_comp[comp_cnt].cnt_cond_comp_name = compkey.cond_comp_name, reply->cnt_exp_comp[
   comp_cnt].cond_exprsn_comp_id = compkey.cond_exprsn_comp_id, reply->cnt_exp_comp[comp_cnt].
   operator_cd_uid = compkey.operator_cd_uid,
   reply->cnt_exp_comp[comp_cnt].cnt_operator_cd_display = cv.display, reply->cnt_exp_comp[comp_cnt].
   cnt_operator_cd_meaning = cv.cdf_meaning, reply->cnt_exp_comp[comp_cnt].operator_cd = cv
   .code_value,
   reply->cnt_exp_comp[comp_cnt].ar_uid = compkey.ar_uid, reply->cnt_exp_comp[comp_cnt].
   nomenclature_name = cark.source_string, reply->cnt_exp_comp[comp_cnt].cnt_required_ind = compkey
   .required_ind,
   reply->cnt_exp_comp[comp_cnt].cnt_result_value = compkey.result_value, reply->cnt_exp_comp[
   comp_cnt].trigger_assay_cd_uid = compkey.trigger_assay_cd_uid, reply->cnt_exp_comp[comp_cnt].
   cnt_trigger_assay_cd_description = cd.description,
   reply->cnt_exp_comp[comp_cnt].cnt_trigger_assay_cd_mnemonic = cd.mnemonic
   IF (cdk.task_assay_cd > 0)
    reply->cnt_exp_comp[comp_cnt].trigger_assay_cd = cdk.task_assay_cd
   ELSE
    reply->cnt_exp_comp[comp_cnt].trigger_assay_cd = dta.task_assay_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cnt_cond_expression_key ccek,
   cnt_conditional_dta_key cd,
   cnt_dta_key2 cdk,
   cnt_dta cd2,
   discrete_task_assay dta
  PLAN (ccek
   WHERE (ccek.cnt_cond_expression_key_uid=request->cnt_cond_expression_key_uid)
    AND ccek.active_ind=true)
   JOIN (cd
   WHERE cd.cond_expression_id=ccek.cond_expression_id
    AND cd.active_ind=true)
   JOIN (cdk
   WHERE cdk.task_assay_uid=cd.conditional_assay_cd_uid)
   JOIN (cd2
   WHERE cd2.task_assay_uid=cdk.task_assay_uid)
   JOIN (dta
   WHERE dta.mnemonic_key_cap=outerjoin(cd2.mnemonic_key_cap)
    AND dta.activity_type_cd=outerjoin(cd2.activity_type_cd)
    AND dta.active_ind=outerjoin(1))
  DETAIL
   dta_cnt = (dta_cnt+ 1), stat = alterlist(reply->cnt_cond_dtas,dta_cnt), reply->cnt_cond_dtas[
   dta_cnt].cnt_age_from_nbr = cd.age_from_nbr,
   reply->cnt_cond_dtas[dta_cnt].age_from_unit_cd_uid = cd.age_from_unit_cd_uid, reply->
   cnt_cond_dtas[dta_cnt].cnt_age_to_nbr = cd.age_to_nbr, reply->cnt_cond_dtas[dta_cnt].
   age_to_unit_cd_uid = cd.age_to_unit_cd_uid,
   reply->cnt_cond_dtas[dta_cnt].conditional_assay_cd_uid = cd.conditional_assay_cd_uid, reply->
   cnt_cond_dtas[dta_cnt].cnt_conditional_assay_cd_description = cd2.description, reply->
   cnt_cond_dtas[dta_cnt].cnt_conditional_assay_cd_mnemonic = cd2.mnemonic
   IF (cdk.task_assay_cd > 0)
    reply->cnt_cond_dtas[dta_cnt].conditional_assay_cd = cdk.task_assay_cd
   ELSE
    reply->cnt_cond_dtas[dta_cnt].conditional_assay_cd = dta.task_assay_cd
   ENDIF
   reply->cnt_cond_dtas[dta_cnt].gender_cd_uid = cd.gender_cd_uid, reply->cnt_cond_dtas[dta_cnt].
   position_cd_uid = cd.position_cd_uid, reply->cnt_cond_dtas[dta_cnt].location_cd_uid = cd
   .location_cd_uid,
   reply->cnt_cond_dtas[dta_cnt].cnt_required_ind = cd.required_ind, reply->cnt_cond_dtas[dta_cnt].
   cnt_unknown_age_ind = cd.unknown_age_ind
  WITH nocounter
 ;end select
 FOR (index = 1 TO size(reply->cnt_cond_dtas,5))
   SET reply->cnt_cond_dtas[index].age_from_unit_cd = get_me_code_value(reply->cnt_cond_dtas[index].
    age_from_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_age_from_unit_cd_display = get_me_cv_display(reply->
    cnt_cond_dtas[index].age_from_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_age_from_unit_cd_meaning = get_me_cv_meaning(reply->
    cnt_cond_dtas[index].age_from_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].age_to_unit_cd = get_me_code_value(reply->cnt_cond_dtas[index].
    age_to_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_age_to_unit_cd_display = get_me_cv_display(reply->
    cnt_cond_dtas[index].age_to_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_age_to_unit_cd_meaning = get_me_cv_meaning(reply->
    cnt_cond_dtas[index].age_to_unit_cd_uid)
   SET reply->cnt_cond_dtas[index].gender_cd = get_me_code_value(reply->cnt_cond_dtas[index].
    gender_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_gender_cd_display = get_me_cv_display(reply->cnt_cond_dtas[
    index].gender_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_gender_cd_meaning = get_me_cv_meaning(reply->cnt_cond_dtas[
    index].gender_cd_uid)
   SET reply->cnt_cond_dtas[index].position_cd = get_me_code_value(reply->cnt_cond_dtas[index].
    position_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_position_cd_display = get_me_cv_display(reply->cnt_cond_dtas[
    index].position_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_position_cd_meaning = get_me_cv_meaning(reply->cnt_cond_dtas[
    index].position_cd_uid)
   SET reply->cnt_cond_dtas[index].location_cd = get_me_code_value(reply->cnt_cond_dtas[index].
    location_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_location_cd_display = get_me_cv_display(reply->cnt_cond_dtas[
    index].location_cd_uid)
   SET reply->cnt_cond_dtas[index].cnt_location_cd_meaning = get_me_cv_meaning(reply->cnt_cond_dtas[
    index].location_cd_uid)
 ENDFOR
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE get_me_code_value(code_value_uid)
   DECLARE code_value = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM cnt_code_value_key cvk
    WHERE cvk.code_value_uid=code_value_uid
    DETAIL
     code_value = cvk.code_value
    WITH nocounter
   ;end select
   RETURN(code_value)
 END ;Subroutine
 SUBROUTINE get_me_cv_display(code_value_uid)
   DECLARE display = vc WITH noconstant("")
   SELECT INTO "nl:"
    FROM cnt_code_value_key cvk
    WHERE cvk.code_value_uid=code_value_uid
    DETAIL
     display = cvk.display
    WITH nocounter
   ;end select
   RETURN(display)
 END ;Subroutine
 SUBROUTINE get_me_cv_meaning(code_value_uid)
   DECLARE cdf_meaning = vc WITH noconstant("")
   SELECT INTO "nl:"
    FROM cnt_code_value_key cvk
    WHERE cvk.code_value_uid=code_value_uid
    DETAIL
     cdf_meaning = cvk.cdf_meaning
    WITH nocounter
   ;end select
   RETURN(cdf_meaning)
 END ;Subroutine
END GO
