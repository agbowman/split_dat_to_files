CREATE PROGRAM bed_get_cnt_cond_expression:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 expression_list[*]
      2 cnt_cond_expression_key_id = f8
      2 cnt_cond_expression_key_uid = vc
      2 cnt_cond_expression_id = f8
      2 cnt_cond_expression_name = vc
      2 cnt_cond_expression_txt = vc
      2 cnt_cond_postfix_txt = vc
      2 cnt_multiple_ind = i2
      2 dcp_cond_expression_ref_id = f8
      2 exp_status = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD importedexpressions(
   1 expression_list[*]
     2 cnt_cond_expression_key_id = f8
     2 cnt_cond_expression_key_uid = vc
     2 cnt_cond_expression_id = f8
     2 cnt_cond_expression_name = vc
     2 cnt_cond_expression_txt = vc
     2 cnt_cond_postfix_txt = vc
     2 cnt_multiple_ind = i2
     2 dcp_cond_expression_ref_id = f8
     2 exp_status = vc
 ) WITH protect
 FREE RECORD taskassayuids
 RECORD taskassayuids(
   1 assays[*]
     2 task_assay_uid = vc
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
 DECLARE isexpcompmodified(getimportedexpdetailreply=vc(ref),getexistingexpdetailreply=vc(ref)) = i2
 DECLARE isconddtamodified(getimportedexpdetailreply=vc(ref),getexistingexpdetailreply=vc(ref)) = i2
 DECLARE getalpharesponsedisplay(nomenid=f8) = vc
 SUBROUTINE isexpcompmodified(getimportedexpdetailreply,getexistingexpdetailreply)
   CALL bedlogmessage("isExpCompModified","Entering ...")
   DECLARE importedexpcompsize = i4 WITH protect, constant(size(getimportedexpdetailreply->
     cnt_exp_comp,5))
   DECLARE existingexpcompsize = i4 WITH protect, constant(size(getexistingexpdetailreply->exp_comp,5
     ))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE eidx = i4 WITH protect, noconstant(0)
   FOR (eidx = 1 TO importedexpcompsize)
     SET num = 1
     SET foundidx = locateval(num,1,existingexpcompsize,getimportedexpdetailreply->cnt_exp_comp[eidx]
      .cnt_cond_comp_name,getexistingexpdetailreply->exp_comp[num].cond_comp_name)
     IF (foundidx > 0)
      CALL echo("Match is found - isExpCompModified")
      IF ((getimportedexpdetailreply->cnt_exp_comp[eidx].cnt_cond_comp_name !=
      getexistingexpdetailreply->exp_comp[foundidx].cond_comp_name))
       CALL echo(build2("Trigger Name:",getimportedexpdetailreply->cnt_exp_comp[eidx].
         cnt_cond_comp_name,getexistingexpdetailreply->exp_comp[foundidx].cond_comp_name))
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_exp_comp[eidx].operator_cd != getexistingexpdetailreply->
      exp_comp[foundidx].operator_cd))
       CALL echo(build2("Operator:",getimportedexpdetailreply->cnt_exp_comp[eidx].operator_cd,
         getexistingexpdetailreply->exp_comp[foundidx].operator_cd))
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_exp_comp[eidx].cnt_result_value !=
      getexistingexpdetailreply->exp_comp[foundidx].result_value))
       CALL echo(build2("Result Value:",getimportedexpdetailreply->cnt_exp_comp[eidx].
         cnt_result_value,getexistingexpdetailreply->exp_comp[foundidx].result_value))
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_exp_comp[eidx].nomenclature_name != getalpharesponsedisplay
      (getexistingexpdetailreply->exp_comp[foundidx].parent_entity_id)))
       CALL echo(build2("Alpha Response:",getimportedexpdetailreply->cnt_exp_comp[eidx].
         nomenclature_name,getalpharesponsedisplay(getexistingexpdetailreply->exp_comp[foundidx].
          parent_entity_id)))
       RETURN(true)
      ENDIF
     ELSE
      CALL echo(build2("Match not found for content trigger assay:",getimportedexpdetailreply->
        cnt_exp_comp[eidx].trigger_assay_cd))
      RETURN(true)
     ENDIF
   ENDFOR
   CALL bedlogmessage("isExpCompModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE isconddtamodified(getimportedexpdetailreply,getexistingexpdetailreply)
   CALL bedlogmessage("isCondDtaModified","Entering ...")
   DECLARE importedconddtasize = i4 WITH protect, constant(size(getimportedexpdetailreply->
     cnt_cond_dtas,5))
   DECLARE existingconddtasize = i4 WITH protect, constant(size(getexistingexpdetailreply->cond_dtas,
     5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE eidx = i4 WITH protect, noconstant(0)
   FOR (eidx = 1 TO importedconddtasize)
     SET num = 1
     SET foundidx = locateval(num,1,existingconddtasize,getimportedexpdetailreply->cnt_cond_dtas[eidx
      ].conditional_assay_cd,getexistingexpdetailreply->cond_dtas[num].conditional_assay_cd)
     IF (foundidx > 0)
      CALL echo(build2("Match is found for conditional DTA",getimportedexpdetailreply->cnt_cond_dtas[
        eidx].conditional_assay_cd))
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].cnt_age_from_nbr !=
      getexistingexpdetailreply->cond_dtas[foundidx].age_from_nbr))
       CALL echo("Age from is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].age_from_unit_cd !=
      getexistingexpdetailreply->cond_dtas[foundidx].age_from_unit_cd))
       CALL echo("Age from unit cd is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].cnt_age_to_nbr != getexistingexpdetailreply
      ->cond_dtas[foundidx].age_to_nbr))
       CALL echo("Age to is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].age_to_unit_cd != getexistingexpdetailreply
      ->cond_dtas[foundidx].age_to_unit_cd))
       CALL echo("Age to unit cd is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].gender_cd != getexistingexpdetailreply->
      cond_dtas[foundidx].gender_cd))
       CALL echo("Gender is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].position_cd != getexistingexpdetailreply->
      cond_dtas[foundidx].position_cd))
       CALL echo("Position cd is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].location_cd != getexistingexpdetailreply->
      cond_dtas[foundidx].location_cd))
       CALL echo("Location cd is different")
       RETURN(true)
      ENDIF
      IF ((getimportedexpdetailreply->cnt_cond_dtas[eidx].cnt_required_ind !=
      getexistingexpdetailreply->cond_dtas[foundidx].required_ind))
       CALL echo("Required ind is differnt")
       RETURN(true)
      ENDIF
     ELSE
      CALL echo(build2("Match is NOT found for conditional DTA",getimportedexpdetailreply->
        cnt_cond_dtas[eidx].conditional_assay_cd))
      RETURN(true)
     ENDIF
   ENDFOR
   CALL bedlogmessage("isCondDtaModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE getalpharesponsedisplay(nomenid)
   DECLARE display = vc WITH protect, noconstant("")
   IF (nomenid > 0)
    SELECT INTO "nl:"
     FROM nomenclature n
     WHERE n.nomenclature_id=nomenid
     DETAIL
      display = n.source_string
     WITH nocounter
    ;end select
   ENDIF
   RETURN(display)
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 DECLARE conditioncnt = i4 WITH protect, noconstant(0)
 DECLARE taskassayuidcnt = i4 WITH protect, noconstant(0)
 DECLARE getexpressionsforassay(task_assay_uid=vc) = i2
 DECLARE populateexpressions(dummyvar=i2) = i2
 DECLARE docomparison(cnt_cond_expression_id_uid=vc,dcp_cond_expression_ref_id=f8) = vc
 DECLARE filteroutnonmodifiedexpressions(dummyvar=i2) = i2
 SELECT INTO "nl:"
  FROM cnt_wv_section_r s,
   cnt_wv_section_item_r ir,
   cnt_wv_item_key ik
  PLAN (s
   WHERE (s.working_view_uid=request->working_view_uid))
   JOIN (ir
   WHERE ir.wv_section_uid=s.wv_section_uid)
   JOIN (ik
   WHERE ik.wv_item_uid=ir.wv_item_uid)
  ORDER BY ik.task_assay_guid
  HEAD ik.task_assay_guid
   taskassayuidcnt = (taskassayuidcnt+ 1), stat = alterlist(taskassayuids->assays,taskassayuidcnt),
   taskassayuids->assays[taskassayuidcnt].task_assay_uid = ik.task_assay_guid
  WITH nocounter
 ;end select
 FOR (taskassaycnt = 1 TO taskassayuidcnt)
   CALL getexpressionsforassay(taskassayuids->assays[taskassaycnt].task_assay_uid)
 ENDFOR
 IF (conditioncnt > 0)
  CALL populateexpressions(0)
  CALL filteroutnonmodifiedexpressions(0)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getexpressionsforassay(task_assay_uid)
   CALL bedlogmessage("getExpressionsForAssay","Entering ...")
   DECLARE triggerfound = i2 WITH protect, noconstant(0)
   SET triggerfound = 0
   SELECT INTO "nl:"
    FROM cnt_cond_exprsn_comp_key cec,
     cnt_cond_expression_key ce,
     cnt_wv_item_key ik,
     cnt_wv_section_item_r ir,
     cnt_wv_section_r s
    PLAN (cec
     WHERE cec.trigger_assay_cd_uid=task_assay_uid
      AND cec.active_ind=true)
     JOIN (ce
     WHERE cec.cond_exprsn_id=ce.cond_expression_id
      AND ce.active_ind=true)
     JOIN (ik
     WHERE ik.task_assay_guid=task_assay_uid)
     JOIN (ir
     WHERE ir.wv_item_uid=ik.wv_item_uid)
     JOIN (s
     WHERE s.wv_section_uid=ir.wv_section_uid
      AND (s.working_view_uid=request->working_view_uid))
    ORDER BY ce.cond_expression_id
    HEAD ce.cond_expression_id
     conditioncnt = (conditioncnt+ 1), stat = alterlist(importedexpressions->expression_list,
      conditioncnt), importedexpressions->expression_list[conditioncnt].cnt_cond_expression_key_id =
     ce.cnt_cond_expression_key_id,
     importedexpressions->expression_list[conditioncnt].cnt_cond_expression_key_uid = ce
     .cnt_cond_expression_key_uid, importedexpressions->expression_list[conditioncnt].
     cnt_cond_expression_id = ce.cond_expression_id, importedexpressions->expression_list[
     conditioncnt].cnt_cond_expression_name = ce.cond_expression_name,
     importedexpressions->expression_list[conditioncnt].cnt_cond_expression_txt = ce
     .cond_expression_txt, importedexpressions->expression_list[conditioncnt].cnt_cond_postfix_txt =
     ce.cond_postfix_txt, importedexpressions->expression_list[conditioncnt].cnt_multiple_ind = ce
     .multiple_ind,
     importedexpressions->expression_list[conditioncnt].dcp_cond_expression_ref_id = ce
     .dcp_cond_expression_ref_id, triggerfound = 1
    WITH nocounter
   ;end select
   IF (triggerfound > 0)
    SELECT INTO "nl:"
     FROM cnt_conditional_dta_key cd,
      cnt_cond_expression_key ce,
      cnt_wv_item_key ik,
      cnt_wv_section_item_r ir,
      cnt_wv_section_r s
     PLAN (cd
      WHERE cd.conditional_assay_cd_uid=task_assay_uid
       AND cd.active_ind=true)
      JOIN (ce
      WHERE ce.cond_expression_id=cd.cond_expression_id
       AND ce.active_ind=true)
      JOIN (ik
      WHERE ik.task_assay_guid=task_assay_uid)
      JOIN (ir
      WHERE ir.wv_item_uid=ik.wv_item_uid)
      JOIN (s
      WHERE s.wv_section_uid=ir.wv_section_uid
       AND (s.working_view_uid=request->working_view_uid))
     ORDER BY cd.cond_expression_id
     HEAD cd.cond_expression_id
      conditioncnt = (conditioncnt+ 1), stat = alterlist(importedexpressions->expression_list,
       conditioncnt), importedexpressions->expression_list[conditioncnt].cnt_cond_expression_key_id
       = ce.cnt_cond_expression_key_id,
      importedexpressions->expression_list[conditioncnt].cnt_cond_expression_key_uid = ce
      .cnt_cond_expression_key_uid, importedexpressions->expression_list[conditioncnt].
      cnt_cond_expression_id = ce.cond_expression_id, importedexpressions->expression_list[
      conditioncnt].cnt_cond_expression_name = ce.cond_expression_name,
      importedexpressions->expression_list[conditioncnt].cnt_cond_expression_txt = ce
      .cond_expression_txt, importedexpressions->expression_list[conditioncnt].cnt_cond_postfix_txt
       = ce.cond_postfix_txt, importedexpressions->expression_list[conditioncnt].cnt_multiple_ind =
      ce.multiple_ind,
      importedexpressions->expression_list[conditioncnt].dcp_cond_expression_ref_id = ce
      .dcp_cond_expression_ref_id
     WITH nocounter
    ;end select
   ENDIF
   CALL bedlogmessage("getExpressionsForAssay","Exiting ...")
 END ;Subroutine
 SUBROUTINE populateexpressions(dummyvar)
   CALL bedlogmessage("populateExpressions","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE cntcondexpuid = vc WITH protect, noconstant("")
   DECLARE index_cnt = i4 WITH protect, noconstant(0)
   DECLARE status_ind = vc WITH protect, noconstant("")
   IF (validate(debug,0)=1)
    CALL echorecord(importedexpressions)
   ENDIF
   SELECT INTO "nl:"
    cntcondexpuid = importedexpressions->expression_list[d.seq].cnt_cond_expression_key_uid
    FROM (dummyt d  WITH seq = size(importedexpressions->expression_list,5)),
     cnt_cond_expression_key e,
     cnt_conditional_dta_key ccd,
     cnt_cond_exprsn_comp_key k
    PLAN (d)
     JOIN (e
     WHERE (e.cnt_cond_expression_key_uid=importedexpressions->expression_list[d.seq].
     cnt_cond_expression_key_uid)
      AND e.active_ind=true)
     JOIN (ccd
     WHERE ccd.cond_expression_id=e.cond_expression_id
      AND ccd.active_ind=true)
     JOIN (k
     WHERE k.cond_exprsn_id=e.cond_expression_id
      AND k.active_ind=true)
    ORDER BY cntcondexpuid
    HEAD cntcondexpuid
     cnt = (cnt+ 1), stat = alterlist(reply->expression_list,cnt), reply->expression_list[cnt].
     cnt_cond_expression_key_id = importedexpressions->expression_list[d.seq].
     cnt_cond_expression_key_id,
     reply->expression_list[cnt].cnt_cond_expression_key_uid = importedexpressions->expression_list[d
     .seq].cnt_cond_expression_key_uid, reply->expression_list[cnt].cnt_cond_expression_id =
     importedexpressions->expression_list[d.seq].cnt_cond_expression_id, reply->expression_list[cnt].
     cnt_cond_expression_name = importedexpressions->expression_list[d.seq].cnt_cond_expression_name,
     reply->expression_list[cnt].cnt_cond_expression_txt = importedexpressions->expression_list[d.seq
     ].cnt_cond_expression_txt, reply->expression_list[cnt].cnt_cond_postfix_txt =
     importedexpressions->expression_list[d.seq].cnt_cond_postfix_txt, reply->expression_list[cnt].
     cnt_multiple_ind = importedexpressions->expression_list[d.seq].cnt_multiple_ind,
     reply->expression_list[cnt].dcp_cond_expression_ref_id = importedexpressions->expression_list[d
     .seq].dcp_cond_expression_ref_id
    WITH nocounter
   ;end select
   FOR (index_cnt = 1 TO size(reply->expression_list,5))
     IF ((reply->expression_list[index_cnt].dcp_cond_expression_ref_id <= 0.0))
      CALL echo("Expression match not found on Millennium side... Search match by name")
      SELECT INTO "nl:"
       FROM cond_expression ce
       PLAN (ce
        WHERE (ce.cond_expression_name=reply->expression_list[index_cnt].cnt_cond_expression_name)
         AND ce.active_ind=true)
       DETAIL
        reply->expression_list[index_cnt].dcp_cond_expression_ref_id = ce.cond_expression_id
       WITH nocounter
      ;end select
     ENDIF
     IF ((reply->expression_list[index_cnt].dcp_cond_expression_ref_id <= 0.0))
      SET status_ind = added
     ELSE
      SET status_ind = docomparison(reply->expression_list[index_cnt].cnt_cond_expression_key_uid,
       reply->expression_list[index_cnt].dcp_cond_expression_ref_id)
     ENDIF
     SET reply->expression_list[index_cnt].exp_status = status_ind
   ENDFOR
   CALL bedlogmessage("populateExpressions","Exiting ...")
 END ;Subroutine
 SUBROUTINE filteroutnonmodifiedexpressions(dummyvar)
   CALL bedlogmessage("filterOutNonModifiedExpressions","Entering ...")
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE tcnt = i4 WITH protect, noconstant(0)
   FREE RECORD tempexp
   RECORD tempexp(
     1 expression_list[*]
       2 cnt_cond_expression_key_id = f8
       2 cnt_cond_expression_key_uid = vc
       2 cnt_cond_expression_id = f8
       2 cnt_cond_expression_name = vc
       2 cnt_cond_expression_txt = vc
       2 cnt_cond_postfix_txt = vc
       2 cnt_multiple_ind = i2
       2 dcp_cond_expression_ref_id = f8
       2 exp_status = vc
   )
   FOR (ecnt = 1 TO size(reply->expression_list,5))
     IF ((reply->expression_list[ecnt].exp_status IN (added, modified)))
      SET tcnt = (tcnt+ 1)
      SET stat = alterlist(tempexp->expression_list,tcnt)
      SET tempexp->expression_list[tcnt].cnt_cond_expression_key_id = reply->expression_list[ecnt].
      cnt_cond_expression_key_id
      SET tempexp->expression_list[tcnt].cnt_cond_expression_key_uid = reply->expression_list[ecnt].
      cnt_cond_expression_key_uid
      SET tempexp->expression_list[tcnt].cnt_cond_expression_id = reply->expression_list[ecnt].
      cnt_cond_expression_id
      SET tempexp->expression_list[tcnt].cnt_cond_expression_name = reply->expression_list[ecnt].
      cnt_cond_expression_name
      SET tempexp->expression_list[tcnt].cnt_cond_expression_txt = reply->expression_list[ecnt].
      cnt_cond_expression_txt
      SET tempexp->expression_list[tcnt].cnt_cond_postfix_txt = reply->expression_list[ecnt].
      cnt_cond_postfix_txt
      SET tempexp->expression_list[tcnt].cnt_multiple_ind = reply->expression_list[ecnt].
      cnt_multiple_ind
      SET tempexp->expression_list[tcnt].dcp_cond_expression_ref_id = reply->expression_list[ecnt].
      dcp_cond_expression_ref_id
      SET tempexp->expression_list[tcnt].exp_status = reply->expression_list[ecnt].exp_status
     ENDIF
   ENDFOR
   SET stat = initrec(reply)
   SET stat = alterlist(reply->expression_list,tcnt)
   FOR (ecnt = 1 TO tcnt)
     SET reply->expression_list[ecnt].cnt_cond_expression_key_id = tempexp->expression_list[ecnt].
     cnt_cond_expression_key_id
     SET reply->expression_list[ecnt].cnt_cond_expression_key_uid = tempexp->expression_list[ecnt].
     cnt_cond_expression_key_uid
     SET reply->expression_list[ecnt].cnt_cond_expression_id = tempexp->expression_list[ecnt].
     cnt_cond_expression_id
     SET reply->expression_list[ecnt].cnt_cond_expression_name = tempexp->expression_list[ecnt].
     cnt_cond_expression_name
     SET reply->expression_list[ecnt].cnt_cond_expression_txt = tempexp->expression_list[ecnt].
     cnt_cond_expression_txt
     SET reply->expression_list[ecnt].cnt_cond_postfix_txt = tempexp->expression_list[ecnt].
     cnt_cond_postfix_txt
     SET reply->expression_list[ecnt].cnt_multiple_ind = tempexp->expression_list[ecnt].
     cnt_multiple_ind
     SET reply->expression_list[ecnt].dcp_cond_expression_ref_id = tempexp->expression_list[ecnt].
     dcp_cond_expression_ref_id
     SET reply->expression_list[ecnt].exp_status = tempexp->expression_list[ecnt].exp_status
   ENDFOR
   CALL bedlogmessage("filterOutNonModifiedExpressions","Exiting ...")
 END ;Subroutine
 SUBROUTINE docomparison(cnt_cond_expression_key_uid,dcp_cond_expression_ref_id)
   CALL bedlogmessage("doComparison","Entering ...")
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
   SET getexistingexpdetailrequest->cond_expression_id = dcp_cond_expression_ref_id
   EXECUTE bed_get_cond_expression_detail  WITH replace("REQUEST",getexistingexpdetailrequest),
   replace("REPLY",getexistingexpdetailreply)
   IF ((getexistingexpdetailreply->status_data.status != "S"))
    CALL bederror("bed_get_cond_expression_detail did not return success")
   ENDIF
   FREE RECORD getimportedexpdetailrequest
   RECORD getimportedexpdetailrequest(
     1 cnt_cond_expression_key_uid = vc
   )
   FREE RECORD getimportedexpdetailreply
   RECORD getimportedexpdetailreply(
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
   SET getimportedexpdetailrequest->cnt_cond_expression_key_uid = cnt_cond_expression_key_uid
   EXECUTE bed_get_cnt_cond_expn_detail  WITH replace("REQUEST",getimportedexpdetailrequest), replace
   ("REPLY",getimportedexpdetailreply)
   IF ((getimportedexpdetailreply->status_data.status != "S"))
    CALL bederror("bed_get_cnt_cond_expn_detail did not return success")
   ENDIF
   CALL echo("<------------------ Compare Expressions -------------->")
   IF (isexpcompmodified(getimportedexpdetailreply,getexistingexpdetailreply))
    RETURN(modified)
   ELSEIF (isconddtamodified(getimportedexpdetailreply,getexistingexpdetailreply))
    RETURN(modified)
   ELSE
    CALL echo("There are no differences")
    RETURN(none)
   ENDIF
   CALL bedlogmessage("doComparison","Exiting ...")
 END ;Subroutine
END GO
