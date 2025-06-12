CREATE PROGRAM bed_get_rvu_mod_formulas:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 rvu_mod_formulas[*]
      2 rcr_rvu_modifier_formula_id = f8
      2 modifier_ident = vc
      2 calculation_value = f8
      2 percentage_ind = i2
      2 global_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 source_vocab_cd = f8
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 modifier_position_seq = i4
      2 modifier_desc = vc
      2 billing_entity_id = f8
      2 rvu_override_ind = i2
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
 IF ( NOT (validate(cs400_cpt4_cd)))
  DECLARE cs400_cpt4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"CPT4"))
 ENDIF
 IF ( NOT (validate(cs400_hcpcs_cd)))
  DECLARE cs400_hcpcs_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"HCPCS"))
 ENDIF
 IF ( NOT (validate(cs401_modifier)))
  DECLARE cs401_modifier = f8 WITH protect, constant(uar_get_code_by("MEANING",401,"MODIFIER"))
 ENDIF
 DECLARE logical_domain_id = f8 WITH constant(bedgetlogicaldomain(0)), protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE whereclause = vc WITH protect, noconstant("")
 DECLARE getrvuformulas(dummyvar=i2) = null
 DECLARE getmodifiers(dummyvar=i2) = null
 IF (validate(debug,0)=1)
  CALL logdebugmessage("Logical Domain ID:",logical_domain_id)
 ENDIF
 IF ((request->billing_entity_id > 0))
  SET whereclause = "r.billing_entity_id in (0.0, request->billing_entity_id)"
 ELSE
  SET whereclause = "r.billing_entity_id = 0.0"
 ENDIF
 CALL getrvuformulas(0)
 CALL getmodifiers(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getrvuformulas(facilitylist)
   CALL bedlogmessage("getRVUFormulas","Entering ...")
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM nomenclature n,
     code_value cv,
     rcr_rvu_modifier_formula r
    PLAN (r
     WHERE r.billing_entity_id IN (0, request->billing_entity_id)
      AND r.active_ind=1)
     JOIN (n
     WHERE n.source_identifier=r.modifier_ident
      AND n.source_vocabulary_cd IN (cs400_cpt4_cd, cs400_hcpcs_cd)
      AND n.principle_type_cd=cs401_modifier)
     JOIN (cv
     WHERE cv.code_value=n.source_vocabulary_cd)
    ORDER BY r.source_vocabulary_cd, r.modifier_ident, r.billing_entity_id,
     r.beg_effective_dt_tm, r.rcr_rvu_modifier_formula_id
    HEAD r.rcr_rvu_modifier_formula_id
     IF (r.rcr_rvu_modifier_formula_id > 0)
      IF (logical_domain_id=r.logical_domain_id)
       cnt = (cnt+ 1), stat = alterlist(reply->rvu_mod_formulas,cnt), reply->rvu_mod_formulas[cnt].
       source_vocab_cd.code_value = r.source_vocabulary_cd,
       reply->rvu_mod_formulas[cnt].source_vocab_cd.display = cv.display, reply->rvu_mod_formulas[cnt
       ].source_vocab_cd.mean = cv.cdf_meaning, reply->rvu_mod_formulas[cnt].modifier_ident = n
       .source_identifier,
       reply->rvu_mod_formulas[cnt].modifier_desc = n.source_string, reply->rvu_mod_formulas[cnt].
       rcr_rvu_modifier_formula_id = r.rcr_rvu_modifier_formula_id, reply->rvu_mod_formulas[cnt].
       calculation_value = r.calculation_value,
       reply->rvu_mod_formulas[cnt].percentage_ind = r.percentage_ind, reply->rvu_mod_formulas[cnt].
       global_ind = r.global_ind, reply->rvu_mod_formulas[cnt].beg_effective_dt_tm = r
       .beg_effective_dt_tm,
       reply->rvu_mod_formulas[cnt].end_effective_dt_tm = r.end_effective_dt_tm, reply->
       rvu_mod_formulas[cnt].modifier_position_seq = r.modifier_position_nbr, reply->
       rvu_mod_formulas[cnt].billing_entity_id = r.billing_entity_id,
       reply->rvu_mod_formulas[cnt].rvu_override_ind = r.rvu_override_ind, ncnt = (ncnt+ 1)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error001: Error getting default modifiers")
   CALL bedlogmessage("getRVUFormulas","Exiting ...")
 END ;Subroutine
 SUBROUTINE getmodifiers(facilitylist)
   CALL bedlogmessage("getModifiers","Entering ...")
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM nomenclature n,
     code_value cv
    PLAN (n
     WHERE n.source_vocabulary_cd IN (cs400_cpt4_cd, cs400_hcpcs_cd)
      AND n.principle_type_cd=cs401_modifier
      AND (n.source_identifier !=
     (SELECT
      r.modifier_ident
      FROM rcr_rvu_modifier_formula r
      WHERE r.active_ind=1
       AND r.rcr_rvu_modifier_formula_id > 0
       AND r.logical_domain_id=logical_domain_id
       AND parser(whereclause))))
     JOIN (cv
     WHERE cv.code_value=n.source_vocabulary_cd)
    ORDER BY n.source_vocabulary_cd, n.source_identifier, n.end_effective_dt_tm DESC
    HEAD n.source_vocabulary_cd
     dcnt = 0
    HEAD n.source_identifier
     cnt = (cnt+ 1), stat = alterlist(reply->rvu_mod_formulas,cnt), reply->rvu_mod_formulas[cnt].
     source_vocab_cd.code_value = n.source_vocabulary_cd,
     reply->rvu_mod_formulas[cnt].source_vocab_cd.display = cv.display, reply->rvu_mod_formulas[cnt].
     source_vocab_cd.mean = cv.cdf_meaning, reply->rvu_mod_formulas[cnt].modifier_ident = n
     .source_identifier,
     reply->rvu_mod_formulas[cnt].modifier_desc = n.source_string, reply->rvu_mod_formulas[cnt].
     global_ind = 1, reply->rvu_mod_formulas[cnt].rvu_override_ind = 0
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error001: Error getting modifiers")
   CALL bedlogmessage("getModifiers","Exiting ...")
 END ;Subroutine
END GO
