CREATE PROGRAM bed_get_nomen_terms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 max_reply_ind = i2
    1 terms[*]
      2 nomenclature_id = f8
      2 term_display = vc
      2 terminology_axis_display = vc
      2 code_display = vc
      2 terminology_cd = f8
      2 terminology_display = vc
      2 primary_display = vc
      2 concept_cki = c255
      2 active_ind = i2
      2 effective_ind = i2
      2 concept_source_mean = vc
      2 concept_identifier = vc
      2 concept_source_cd = f8
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
 DECLARE starts_with = i2 WITH public, constant(1)
 DECLARE contains = i2 WITH public, constant(2)
 DECLARE by_name = i2 WITH public, constant(1)
 DECLARE by_code = i2 WITH public, constant(2)
 DECLARE exact_match = i2 WITH public, constant(3)
 DECLARE parsestring = vc
 DECLARE searchtext = vc WITH protect, constant(cnvtupper(replace(request->search_text,"*","",0)))
 DECLARE nomentermcount = i4 WITH protect, noconstant(0)
 DECLARE termcount = i4 WITH protect, noconstant(0)
 DECLARE exnum = i4 WITH protect, noconstant(0)
 DECLARE exnum2 = i4 WITH protect, noconstant(0)
 DECLARE dynamiccounter = vc WITH protect, noconstant("maxqual(n, 501)")
 DECLARE getnomenterms(dummyvar=i2) = i2
 CALL logdebugmessage("Replaced Search Text:",searchtext)
 IF (validate(request->ignore_primary_vterm_ind,0)=1)
  SET parsestring = build(parsestring,"n.primary_vterm_ind != 1")
 ELSE
  SET parsestring = build(parsestring,"(n.primary_vterm_ind in (0,1) or n.primary_vterm_ind = NULL)")
 ENDIF
 IF ( NOT (validate(request->inc_inactive_ineffective_ind,0)=1))
  SET parsestring = build(parsestring," and n.active_ind = 1")
  SET parsestring = build(parsestring," and n.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)"
   )
 ENDIF
 IF (validate(request->ignore_empty_source_ident_ind,0)=1)
  SET parsestring = build(parsestring," and n.source_identifier not in (' ', '', NULL) ")
 ENDIF
 IF ((request->search_by_flag=by_name)
  AND (request->starts_with_contains_flag=contains))
  SET parsestring = build(parsestring," and n.source_string_keycap = ",'"',"*",searchtext,
   "*",'"')
 ELSEIF ((request->search_by_flag=by_name)
  AND (request->starts_with_contains_flag=starts_with))
  SET parsestring = build(parsestring," and n.source_string_keycap = ",'"',searchtext,"*",
   '"')
 ELSEIF ((request->search_by_flag=by_code)
  AND (request->starts_with_contains_flag=contains))
  SET parsestring = build(parsestring," and n.source_identifier_keycap = ",'"',"*",searchtext,
   "*",'"')
 ELSEIF ((request->search_by_flag=by_code)
  AND (request->starts_with_contains_flag=starts_with))
  SET parsestring = build(parsestring," and n.source_identifier_keycap = ",'"',searchtext,"*",
   '"')
 ELSEIF ((request->search_by_flag=by_name)
  AND (request->starts_with_contains_flag=exact_match))
  SET parsestring = build(parsestring," and n.source_string_keycap = ",'"',searchtext,'"')
 ELSEIF ((request->search_by_flag=by_code)
  AND (request->starts_with_contains_flag=exact_match))
  SET parsestring = build(parsestring," and n.source_identifier_keycap = ",'"',searchtext,'"')
 ENDIF
 IF ( NOT (trim(request->search_text)=""))
  SET dynamiccounter = "nocounter"
 ENDIF
 CALL getnomentermscount(0)
 IF (nomentermcount <= 500)
  CALL getnomenterms(0)
 ELSE
  SET reply->max_reply_ind = 1
  GO TO exit_script
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getnomentermscount(dummyvar)
   CALL bedlogmessage("getNomenTermsCount","Entering...")
   SET exnum = 0
   SET exnum2 = 0
   CALL logdebugmessage("Parse parameter for nomenclature table:",parsestring)
   IF ((request->ignore_axes_ind=0))
    SELECT INTO "nl:"
     total_count = count(1)
     FROM nomenclature n
     PLAN (n
      WHERE expand(exnum,1,size(request->terminologies,5),n.source_vocabulary_cd,request->
       terminologies[exnum].terminology_cd)
       AND expand(exnum2,1,size(request->terminology_axes,5),n.vocab_axis_cd,request->
       terminology_axes[exnum2].terminology_axis_cd)
       AND ((n.disallowed_ind = null) OR (n.disallowed_ind=0))
       AND parser(parsestring))
     DETAIL
      nomentermcount = total_count
     WITH parser(dynamiccounter)
    ;end select
    CALL bederrorcheck("Error 001: Error retrieving nomen terms count")
   ELSE
    SELECT INTO "NL:"
     total_count = count(1)
     FROM nomenclature n
     PLAN (n
      WHERE expand(exnum,1,size(request->terminologies,5),n.source_vocabulary_cd,request->
       terminologies[exnum].terminology_cd)
       AND ((n.disallowed_ind = null) OR (n.disallowed_ind=0))
       AND parser(parsestring))
     DETAIL
      nomentermcount = total_count
     WITH parser(dynamiccounter)
    ;end select
    CALL bederrorcheck("Error 002: Error retrieving nomen terms count")
   ENDIF
   CALL bedlogmessage("getNomenTermsCount","Exiting...")
 END ;Subroutine
 SUBROUTINE getnomenterms(dummyvar)
   CALL bedlogmessage("getNomenTerms","Entering...")
   SET exnum = 0
   SET exnum2 = 0
   CALL logdebugmessage("Parse parameter for nomenclature table:",parsestring)
   IF ((request->ignore_axes_ind=0))
    SELECT INTO "NL:"
     FROM nomenclature n
     PLAN (n
      WHERE expand(exnum,1,size(request->terminologies,5),n.source_vocabulary_cd,request->
       terminologies[exnum].terminology_cd)
       AND expand(exnum2,1,size(request->terminology_axes,5),n.vocab_axis_cd,request->
       terminology_axes[exnum2].terminology_axis_cd)
       AND ((n.disallowed_ind = null) OR (n.disallowed_ind=0))
       AND parser(parsestring))
     ORDER BY n.source_string, n.source_vocabulary_cd, n.vocab_axis_cd
     HEAD REPORT
      termcount = 0, stat = alterlist(reply->terms,10)
     HEAD n.nomenclature_id
      termcount = (termcount+ 1)
      IF (mod(termcount,10)=1
       AND termcount != 1)
       stat = alterlist(reply->terms,(termcount+ 9))
      ENDIF
     DETAIL
      reply->terms[termcount].nomenclature_id = n.nomenclature_id, reply->terms[termcount].
      concept_cki = n.concept_cki, reply->terms[termcount].term_display = n.source_string,
      reply->terms[termcount].terminology_axis_display = uar_get_code_display(n.vocab_axis_cd), reply
      ->terms[termcount].terminology_cd = n.source_vocabulary_cd, reply->terms[termcount].
      terminology_display = uar_get_code_display(n.source_vocabulary_cd),
      reply->terms[termcount].code_display = n.source_identifier, reply->terms[termcount].
      concept_source_mean = uar_get_code_meaning(n.concept_source_cd), reply->terms[termcount].
      concept_identifier = n.concept_identifier,
      reply->terms[termcount].concept_source_cd = n.concept_source_cd
      IF (validate(request->inc_inactive_ineffective_ind))
       reply->terms[termcount].active_ind = n.active_ind
       IF (n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
        reply->terms[termcount].effective_ind = 1
       ELSE
        reply->terms[termcount].effective_ind = 0
       ENDIF
      ENDIF
     FOOT REPORT
      reply->max_reply_ind = 0, stat = alterlist(reply->terms,termcount)
     WITH nocounter, expand = 1
    ;end select
    CALL bederrorcheck("Error 003: Error populating reply")
   ELSE
    SELECT INTO "NL:"
     FROM nomenclature n
     PLAN (n
      WHERE expand(exnum,1,size(request->terminologies,5),n.source_vocabulary_cd,request->
       terminologies[exnum].terminology_cd)
       AND ((n.disallowed_ind = null) OR (n.disallowed_ind=0))
       AND parser(parsestring))
     ORDER BY n.source_string, n.source_vocabulary_cd
     HEAD REPORT
      termcount = 0, stat = alterlist(reply->terms,10)
     HEAD n.nomenclature_id
      termcount = (termcount+ 1)
      IF (mod(termcount,10)=1
       AND termcount != 1)
       stat = alterlist(reply->terms,(termcount+ 9))
      ENDIF
     DETAIL
      reply->terms[termcount].nomenclature_id = n.nomenclature_id, reply->terms[termcount].
      concept_cki = n.concept_cki, reply->terms[termcount].term_display = n.source_string,
      reply->terms[termcount].terminology_axis_display = uar_get_code_display(n.vocab_axis_cd), reply
      ->terms[termcount].terminology_cd = n.source_vocabulary_cd, reply->terms[termcount].
      terminology_display = uar_get_code_display(n.source_vocabulary_cd),
      reply->terms[termcount].code_display = n.source_identifier, reply->terms[termcount].
      concept_source_mean = uar_get_code_meaning(n.concept_source_cd), reply->terms[termcount].
      concept_identifier = n.concept_identifier,
      reply->terms[termcount].concept_source_cd = n.concept_source_cd
      IF (validate(request->inc_inactive_ineffective_ind))
       reply->terms[termcount].active_ind = n.active_ind
       IF (n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
        reply->terms[termcount].effective_ind = 1
       ELSE
        reply->terms[termcount].effective_ind = 0
       ENDIF
      ENDIF
     FOOT REPORT
      reply->max_reply_ind = 0, stat = alterlist(reply->terms,termcount)
     WITH nocounter, expand = 1
    ;end select
    CALL bederrorcheck("Error 004: Error populating reply")
   ENDIF
   CALL bedlogmessage("getNomenTerms","Exiting...")
 END ;Subroutine
END GO
