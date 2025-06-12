CREATE PROGRAM bed_ens_rvu_mod_formulas:dba
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
 FREE RECORD formulastobemodified
 RECORD formulastobemodified(
   1 modifier_formulas[*]
     2 rcr_rvu_modifier_formula_id = f8
 )
 DECLARE modcnt = i4 WITH protect, noconstant(0)
 DECLARE logicaldomainid = f8 WITH constant(bedgetlogicaldomain(0)), protect
 DECLARE getlogicaldomainid(dummyvar=i2) = null
 DECLARE createmodifierformula(dummyvar=i4) = null
 DECLARE updatemodifierformula(dummyvar=i4) = null
 DECLARE deletemodifierformula(dummyvar=i4) = null
 DECLARE insertintorvumodifierformula(modposseq=i4,calcvalue=f8,percentageind=i2) = null
 DECLARE populatetherelatedformulastobemodified(dummyvar=i4) = null
 IF ((request->rvu_mod_formula.action_flag=1))
  CALL createmodifierformula(0)
 ELSEIF ((request->rvu_mod_formula.action_flag=2))
  CALL updatemodifierformula(0)
 ELSEIF ((request->rvu_mod_formula.action_flag=3))
  CALL deletemodifierformula(0)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE createmodifierformula(dummyvar)
   CALL bedlogmessage("createModifierFormula","Entering ...")
   DECLARE calccnt = i2 WITH protect, noconstant(0)
   FOR (calccnt = 1 TO size(request->rvu_mod_formula.calc_values,5))
     CALL insertintorvumodifierformula(request->rvu_mod_formula.calc_values[calccnt].mod_pos_seq,
      request->rvu_mod_formula.calc_values[calccnt].calc_value,request->rvu_mod_formula.calc_values[
      calccnt].percentage_ind)
   ENDFOR
   CALL bedlogmessage("createModifierFormula","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatemodifierformula(dummyvar)
   CALL bedlogmessage("updateModifierFormula","Entering ...")
   DECLARE calccnt = i2 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   CALL populatetherelatedformulastobemodified(0)
   UPDATE  FROM rcr_rvu_modifier_formula r
    SET r.active_ind = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_id = reqinfo->updt_id, r.updt_cnt = (r.updt_cnt+ 1), r.updt_task = reqinfo->updt_task
    WHERE expand(num,1,size(formulastobemodified->modifier_formulas,5),r.rcr_rvu_modifier_formula_id,
     formulastobemodified->modifier_formulas[num].rcr_rvu_modifier_formula_id)
    WITH nocounter
   ;end update
   FOR (calccnt = 1 TO size(request->rvu_mod_formula.calc_values,5))
     CALL insertintorvumodifierformula(request->rvu_mod_formula.calc_values[calccnt].mod_pos_seq,
      request->rvu_mod_formula.calc_values[calccnt].calc_value,request->rvu_mod_formula.calc_values[
      calccnt].percentage_ind)
   ENDFOR
   CALL bedlogmessage("updateModifierFormula","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletemodifierformula(dummyvar)
   CALL bedlogmessage("deleteModifierFormula","Entering ...")
   DECLARE num = i4 WITH protect, noconstant(0)
   CALL populatetherelatedformulastobemodified(0)
   UPDATE  FROM rcr_rvu_modifier_formula r
    SET r.active_ind = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime), r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_id = reqinfo->updt_id, r.updt_cnt = (r.updt_cnt+ 1), r.updt_task = reqinfo->updt_task
    WHERE expand(num,1,size(formulastobemodified->modifier_formulas,5),r.rcr_rvu_modifier_formula_id,
     formulastobemodified->modifier_formulas[num].rcr_rvu_modifier_formula_id)
    WITH nocounter
   ;end update
   CALL bedlogmessage("deleteModifierFormula","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertintorvumodifierformula(modposseq,calcvalue,percentageind)
   CALL bedlogmessage("insertIntoRvuModifierFormula","Entering ...")
   DECLARE rcr_rvu_modifier_formula_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    y = seq(shr_dw_seq,nextval)
    FROM dual
    DETAIL
     rcr_rvu_modifier_formula_id = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM rcr_rvu_modifier_formula r
    SET r.rcr_rvu_modifier_formula_id = rcr_rvu_modifier_formula_id, r.modifier_ident = request->
     rvu_mod_formula.modifier_ident, r.global_ind = request->rvu_mod_formula.global_ind,
     r.beg_effective_dt_tm = cnvtdatetime(request->rvu_mod_formula.beg_effective_dt_tm), r
     .end_effective_dt_tm = cnvtdatetime(request->rvu_mod_formula.end_effective_dt_tm), r
     .source_vocabulary_cd = request->rvu_mod_formula.source_vocab_cd,
     r.billing_entity_id = request->rvu_mod_formula.billing_entity_id, r.modifier_position_nbr =
     modposseq, r.calculation_value = calcvalue,
     r.percentage_ind = percentageind, r.active_ind = 1, r.logical_domain_id = logicaldomainid,
     r.rvu_override_ind = request->rvu_mod_formula.rvu_override_ind, r.create_dt_tm = cnvtdatetime(
      curdate,curtime), r.updt_dt_tm = cnvtdatetime(curdate,curtime),
     r.updt_applctx = reqinfo->updt_applctx, r.updt_id = reqinfo->updt_id, r.updt_cnt = 0,
     r.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bedlogmessage("insertIntoRvuModifierFormula","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatetherelatedformulastobemodified(dummyvar)
   CALL bedlogmessage("populateTheRelatedFormulasToBeModified","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE modifiername = vc WITH protect, noconstant("")
   DECLARE begeffectivedttm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
   DECLARE endeffectivedttm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
   SELECT INTO "nl:"
    FROM rcr_rvu_modifier_formula r
    PLAN (r
     WHERE (r.rcr_rvu_modifier_formula_id=request->rvu_mod_formula.rcr_rvu_modifier_formula_id)
      AND (r.billing_entity_id=request->rvu_mod_formula.billing_entity_id)
      AND r.logical_domain_id=logicaldomainid)
    DETAIL
     modifiername = r.modifier_ident, begeffectivedttm = r.beg_effective_dt_tm, endeffectivedttm = r
     .end_effective_dt_tm
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM rcr_rvu_modifier_formula r
    PLAN (r
     WHERE r.modifier_ident=modifiername
      AND r.beg_effective_dt_tm=cnvtdatetime(begeffectivedttm)
      AND r.end_effective_dt_tm=cnvtdatetime(endeffectivedttm)
      AND (r.billing_entity_id=request->rvu_mod_formula.billing_entity_id)
      AND r.logical_domain_id=logicaldomainid)
    HEAD r.rcr_rvu_modifier_formula_id
     cnt = (cnt+ 1), stat = alterlist(formulastobemodified->modifier_formulas,cnt),
     formulastobemodified->modifier_formulas[cnt].rcr_rvu_modifier_formula_id = r
     .rcr_rvu_modifier_formula_id
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(formulastobemodified)
   ENDIF
   CALL bedlogmessage("populateTheRelatedFormulasToBeModified","Exiting ...")
 END ;Subroutine
END GO
