CREATE PROGRAM bed_get_terms_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 term_details[*]
      2 nomenclature_id = f8
      2 source_vocabulary_cd = f8
      2 principle_type_cd = f8
      2 source_string = vc
      2 contributor_system_cd = f8
      2 language_cd = f8
      2 vocab_axis_cd = f8
      2 short_string = vc
      2 source_identifier = vc
      2 mnemonic = c25
      2 concept_name = vc
      2 primary_cterm_ind = i2
      2 concept_cki = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 active_ind = i2
      2 string_identifier = vc
      2 string_source_cd = f8
      2 string_status_cd = f8
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
 DECLARE term_cnt = i4 WITH public, constant(value(size(request->term_ids,5)))
 CALL bedbeginscript(0)
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_vocabulary_cd, source_vocab_mean = uar_get_code_meaning(n
   .source_vocabulary_cd),
  n.principle_type_cd, n.source_string, n.contributor_system_cd,
  n.language_cd, n.vocab_axis_cd, n.short_string,
  n.source_identifier, n.mnemonic, n.concept_cki,
  n.primary_cterm_ind, n.beg_effective_dt_tm, n.end_effective_dt_tm,
  n.active_ind, cki = decode(cc.seq,"CMT_CONCEPT",c.seq,"CONCEPT","NO_CKI")
  FROM nomenclature n,
   cmt_concept cc,
   concept c,
   (dummyt d  WITH seq = term_cnt),
   dummyt d1,
   dummyt d2
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=request->term_ids[d.seq].nomenclature_id))
   JOIN (d1)
   JOIN (cc
   WHERE cc.concept_cki=n.concept_cki
    AND cc.active_ind=1)
   JOIN (d2)
   JOIN (c
   WHERE c.concept_identifier=n.concept_identifier
    AND c.concept_source_cd=n.concept_source_cd
    AND c.active_ind=1)
  HEAD REPORT
   nomen_cnt = 0
  DETAIL
   nomen_cnt = (nomen_cnt+ 1), stat = alterlist(reply->term_details,nomen_cnt), reply->term_details[
   nomen_cnt].nomenclature_id = n.nomenclature_id,
   reply->term_details[nomen_cnt].source_vocabulary_cd = n.source_vocabulary_cd, reply->term_details[
   nomen_cnt].principle_type_cd = n.principle_type_cd, reply->term_details[nomen_cnt].source_string
    = n.source_string,
   reply->term_details[nomen_cnt].contributor_system_cd = n.contributor_system_cd, reply->
   term_details[nomen_cnt].language_cd = n.language_cd, reply->term_details[nomen_cnt].vocab_axis_cd
    = n.vocab_axis_cd,
   reply->term_details[nomen_cnt].short_string = n.short_string, reply->term_details[nomen_cnt].
   source_identifier = n.source_identifier, reply->term_details[nomen_cnt].mnemonic = n.mnemonic,
   reply->term_details[nomen_cnt].primary_cterm_ind = n.primary_cterm_ind, reply->term_details[
   nomen_cnt].beg_effective_dt_tm = n.beg_effective_dt_tm, reply->term_details[nomen_cnt].
   end_effective_dt_tm = n.end_effective_dt_tm,
   reply->term_details[nomen_cnt].active_ind = n.active_ind, reply->term_details[nomen_cnt].
   string_identifier = n.string_identifier, reply->term_details[nomen_cnt].string_source_cd = n
   .string_source_cd,
   reply->term_details[nomen_cnt].string_status_cd = n.string_status_cd
   IF (((source_vocab_mean="MUL.ALGCAT") OR (((source_vocab_mean="MUL.DCLASS") OR (((
   source_vocab_mean="MUL.DRUG") OR (source_vocab_mean="MUL.MMDC")) )) )) )
    IF (cki="CONCEPT")
     reply->term_details[nomen_cnt].concept_cki = c.cki, reply->term_details[nomen_cnt].concept_name
      = c.concept_name
    ELSE
     reply->term_details[nomen_cnt].concept_cki = "", reply->term_details[nomen_cnt].concept_name =
     ""
    ENDIF
   ELSE
    IF (cki="CMT_CONCEPT")
     reply->term_details[nomen_cnt].concept_cki = cc.concept_cki, reply->term_details[nomen_cnt].
     concept_name = cc.concept_name
    ELSE
     reply->term_details[nomen_cnt].concept_cki = "", reply->term_details[nomen_cnt].concept_name =
     ""
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = cc,
   outerjoin = d2, dontcare = c
 ;end select
 CALL bederrorcheck("Error 001: Error getting term details")
#exit_script
 CALL bedexitscript(1)
END GO
