CREATE PROGRAM bed_ens_nomen_term_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 nomenclature_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(nomenbyckirequest,0)))
  RECORD nomenbyckirequest(
    1 concept_cki = vc
    1 all_ind = i2
    1 concept_source_cd = f8
    1 concept_identifier = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(nomenbyckireply,0)))
  RECORD nomenbyckireply(
    1 synonyms[*]
      2 source_string = vc
      2 source_vocabulary_cd = f8
      2 source_vocabulary_disp = vc
      2 source_vocabulary_mean = c12
      2 principle_type_cd = f8
      2 principle_type_disp = vc
      2 principle_type_mean = c12
      2 vocab_axis_cd = f8
      2 vocab_axis_disp = vc
      2 vocab_axis_mean = c12
      2 contributor_system_cd = f8
      2 contributor_system_disp = vc
      2 contributor_system_mean = c12
      2 language_cd = f8
      2 language_disp = vc
      2 language_mean = c12
      2 nomenclature_id = f8
      2 primary_vterm_ind = i2
      2 primary_cterm_ind = i2
      2 string_source_cd = f8
      2 string_source_disp = vc
      2 string_source_mean = c12
      2 active_ind = i2
      2 source_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET string_index
 RECORD string_index(
   1 source_string = vc
   1 strlist[*]
     2 normalized_string_id = f8
     2 normalized_string = vc
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
 CALL bedbeginscript(0)
 IF ( NOT (validate(cs6011_primary_cd)))
  DECLARE cs36_launguage_eng_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",36,"ENG"))
 ENDIF
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE modify_flag = i2 WITH protect, constant(2)
 DECLARE algcat_source_vocab_mean = vc WITH protect, constant("MUL.ALGCAT")
 DECLARE dclass_source_vocab_mean = vc WITH protect, constant("MUL.DCLASS")
 DECLARE drug_source_vocab_mean = vc WITH protect, constant("MUL.DRUG")
 DECLARE mmdc_source_vocab_mean = vc WITH protect, constant("MUL.MMDC")
 DECLARE ptcare_source_vocab_mean = vc WITH protect, constant("PTCARE")
 DECLARE concept_flag = i2 WITH protect, noconstant(0)
 DECLARE concept_identifier = vc WITH protect, noconstant("")
 DECLARE concept_source_cd = f8 WITH protect, noconstant(0.0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE addtermdetails(dummyvar=i2) = null
 DECLARE modifytermdetails(dummyvar=i2) = null
 DECLARE calculateconceptflag(dummyvar=i2) = null
 DECLARE getnextnomenclatureseq(dummyvar=i2) = f8
 DECLARE normalizestring(normstring=vc) = null
 DECLARE changeprimarydisplayterm(dummyvar=i2) = null
 DECLARE insertintonormalizedstringindex(itr=i4) = null
 CALL calculateconceptflag(0)
 IF ((request->action_flag=add_flag))
  CALL addtermdetails(0)
 ELSEIF ((request->action_flag=modify_flag))
  CALL modifytermdetails(0)
 ENDIF
 CALL changeprimarydisplayterm(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE calculateconceptflag(dummyvar)
   DECLARE source_vocab_mean = vc WITH protect, noconstant("")
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET source_vocab_mean = uar_get_code_meaning(request->terminology_cd)
   IF ((request->concept_cki > " "))
    SET pos = findstring("!",request->concept_cki)
    IF (pos > 1
     AND size(request->concept_cki,1) > 2)
     SET concept_source_mean = cnvtupper(substring(1,(pos - 1),request->concept_cki))
     SET concept_identifier = substring((pos+ 1),size(request->concept_cki,1),request->concept_cki)
     SET concept_source_cd = uar_get_code_by("MEANING",12100,nullterm(concept_source_mean))
    ELSE
     CALL bederrorcheck("Error 001: The Concept_CKI is not in the proper format.")
    ENDIF
    IF (((source_vocab_mean=algcat_source_vocab_mean) OR (((source_vocab_mean=
    dclass_source_vocab_mean) OR (((source_vocab_mean=drug_source_vocab_mean) OR (((source_vocab_mean
    =mmdc_source_vocab_mean) OR (source_vocab_mean=ptcare_source_vocab_mean)) )) )) )) )
     SET concept_flag = 1
     SELECT INTO "nl:"
      FROM concept c
      WHERE c.concept_identifier=concept_identifier
       AND c.concept_source_cd=concept_source_cd
       AND c.active_ind=1
       AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL bederrorcheck(
       "Error 002: For one of the above source_vocab_means, source_cd should be present on the concept table."
       )
     ENDIF
    ELSE
     SET concept_flag = 2
     SELECT INTO "nl:"
      FROM cmt_concept c
      WHERE (c.concept_cki=request->concept_cki)
       AND c.active_ind=1
       AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL bederrorcheck(
       "Error 003: For one of the above source_vocab_means, source_cd should be present on the concept table."
       )
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getnextnomenclatureseq(dummyvar)
   DECLARE nomenclature_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(nomenclature_seq,nextval)
    FROM dual
    DETAIL
     nomenclature_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 004: Error while getting the next nomenclature sequence.")
   RETURN(nomenclature_id)
 END ;Subroutine
 SUBROUTINE addtermdetails(dummyvar)
   SET request->nomenclature_id = getnextnomenclatureseq(0)
   SET reply->nomenclature_id = request->nomenclature_id
   INSERT  FROM nomenclature n
    SET n.nomenclature_id = request->nomenclature_id, n.principle_type_cd = request->
     principle_type_cd, n.contributor_system_cd = request->contributor_system_cd,
     n.source_string = trim(request->term_display), n.source_string_keycap = trim(cnvtupper(request->
       term_display)), n.source_identifier = request->source_identifier,
     n.source_identifier_keycap = cnvtupper(request->source_identifier), n.string_identifier = "", n
     .term_id = 0.0,
     n.language_cd = request->language_cd, n.source_vocabulary_cd = request->terminology_cd, n
     .nom_ver_grp_id = reply->nomenclature_id,
     n.data_status_cd = reqdata->data_status_cd, n.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     n.data_status_prsnl_id = reqinfo->updt_id,
     n.short_string = request->short_string, n.mnemonic = request->mnemonic, n.concept_cki = request
     ->concept_cki,
     n.concept_identifier =
     IF (concept_flag=1) concept_identifier
     ELSE ""
     ENDIF
     , n.concept_source_cd =
     IF (concept_flag=1) concept_source_cd
     ELSE 0.0
     ENDIF
     , n.string_source_cd = 0.0,
     n.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), n.end_effective_dt_tm =
     cnvtdatetime(request->end_effective_dt_tm), n.active_ind = request->active_ind,
     n.active_status_cd = reqdata->active_status_cd, n.active_status_prsnl_id = reqinfo->updt_id, n
     .active_status_dt_tm = cnvtdatetime(curdate,curtime),
     n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,curtime), n.updt_id = reqinfo->updt_id,
     n.updt_applctx = reqinfo->updt_applctx, n.updt_task = reqinfo->updt_task, n.vocab_axis_cd =
     request->terminology_axis_cd,
     n.primary_vterm_ind =
     IF ((request->source_identifier="")) 0
     ELSE 1
     ENDIF
     , n.primary_cterm_ind = request->primary_ind
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 005: Failed to insert into the nomenclature table")
   SET string_index->source_string = trim(request->term_display)
   CALL normalizestring(string_index->source_string)
   SET y = 1
   FOR (y = 1 TO size(string_index->strlist,5))
     SET string_index->strlist[y].normalized_string_id = getnextnomenclatureseq(0)
     CALL insertintonormalizedstringindex(y)
     CALL bederrorcheck(concat(
       "Error 008: The string that failed to be inserted on the normalized_string_index, ",
       string_index->strlist[y].normalized_string))
   ENDFOR
 END ;Subroutine
 SUBROUTINE modifytermdetails(dummyvar)
   SET reply->nomenclature_id = request->nomenclature_id
   UPDATE  FROM nomenclature n
    SET n.principle_type_cd = request->principle_type_cd, n.beg_effective_dt_tm = cnvtdatetime(
      request->beg_effective_dt_tm), n.end_effective_dt_tm = cnvtdatetime(request->
      end_effective_dt_tm),
     n.contributor_system_cd = request->contributor_system_cd, n.source_string = request->
     term_display, n.source_string_keycap = cnvtupper(request->term_display),
     n.source_identifier = request->source_identifier, n.source_identifier_keycap = cnvtupper(request
      ->source_identifier), n.string_identifier = request->string_identifier,
     n.string_status_cd =
     IF ((request->string_status_cd > 0.0)) request->string_status_cd
     ELSE 0.0
     ENDIF
     , n.term_id = 0.0, n.language_cd = request->language_cd,
     n.source_vocabulary_cd = request->terminology_cd, n.nom_ver_grp_id = request->nomenclature_id, n
     .short_string = request->short_string,
     n.mnemonic = request->mnemonic, n.concept_identifier =
     IF (concept_flag=1) concept_identifier
     ELSE n.concept_identifier
     ENDIF
     , n.concept_source_cd =
     IF (concept_flag=1) concept_source_cd
     ELSE n.concept_source_cd
     ENDIF
     ,
     n.concept_cki =
     IF (concept_flag=2) request->concept_cki
     ELSE n.concept_cki
     ENDIF
     , n.string_source_cd =
     IF ((request->string_source_cd > 0.0)) request->string_source_cd
     ELSE 0.0
     ENDIF
     , n.vocab_axis_cd =
     IF ((request->terminology_axis_cd > 0.0)) request->terminology_axis_cd
     ELSE 0.0
     ENDIF
     ,
     n.primary_cterm_ind = request->primary_ind, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
     updt_applctx,
     n.active_ind = request->active_ind, n.active_status_cd =
     IF ((request->active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , n.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     n.active_status_prsnl_id = reqinfo->updt_id
    WHERE (n.nomenclature_id=request->nomenclature_id)
     AND n.nomenclature_id > 0.0
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 006: Failed to insert into the nomenclature table")
   IF ((request->active_ind=0))
    UPDATE  FROM normalized_string_index n
     SET n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id =
      reqinfo->updt_id,
      n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx, n.active_ind =
      request->active_ind,
      n.active_status_cd = reqdata->inactive_status_cd, n.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), n.active_status_prsnl_id = reqinfo->updt_id,
      n.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (n.nomenclature_id=request->nomenclature_id)
      AND n.active_ind=1
      AND n.beg_effective_dt_tm <= cnvtdatetime(request->beg_effective_dt_tm)
      AND n.end_effective_dt_tm > cnvtdatetime(request->end_effective_dt_tm)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error 009: Failed to update into the normalized_string_index table")
   ELSE
    DELETE  FROM normalized_string_index n
     WHERE (n.nomenclature_id=request->nomenclature_id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error 010: Failed to delete from the normalized_string_index table")
    SET string_index->source_string = trim(request->term_display)
    CALL normalizestring(string_index->source_string)
    SET y = 1
    FOR (y = 1 TO size(string_index->strlist,5))
      SET string_index->strlist[y].normalized_string_id = getnextnomenclatureseq(0)
      CALL insertintonormalizedstringindex(y)
      CALL bederrorcheck(concat(
        "Error 011: The string that failed to be inserted on the normalized_string_index, ",
        string_index->strlist[y].normalized_string))
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE insertintonormalizedstringindex(itr)
   INSERT  FROM normalized_string_index n
    SET n.normalized_string_id = string_index->strlist[itr].normalized_string_id, n.language_cd =
     request->language_cd, n.nomenclature_id = request->nomenclature_id,
     n.normalized_string = concat(string_index->strlist[itr].normalized_string," "), n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
     updt_applctx,
     n.active_ind = 1, n.active_status_cd = reqdata->active_status_cd, n.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     n.active_status_prsnl_id = reqinfo->updt_id, n.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE normalizestring(norm_string)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE buflen = i4 WITH protect, constant(1000)
   DECLARE wcard = c1 WITH protect, constant(char(32))
   DECLARE wcard2 = vc WITH protect, constant("")
   DECLARE wcount = i4 WITH protect, constant(0)
   DECLARE outstr = c1000 WITH protect
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE istr = vc WITH protect, noconstant("")
   DECLARE tempstr = vc WITH protect, noconstant("")
   SET tempstr = fillstring(1000," ")
   SET tempstr = nullterm(trim(request->term_display))
   CALL uar_normalize_string(nullterm(norm_string),outstr,nullterm(wcard2),buflen,wcount)
   IF (wcount > 0)
    SET stat = alterlist(string_index->strlist,wcount)
    FOR (i = 1 TO wcount)
      IF (i=1)
       SET string_index->strlist[i].normalized_string = fillstring(1000," ")
       SET string_index->strlist[i].normalized_string = trim(outstr,3)
       SET istr = fillstring(1000," ")
       SET istr = trim(outstr,3)
      ELSE
       SET string_index->strlist[i].normalized_string = fillstring(1000," ")
       SET ipos = findstring(wcard,istr)
       SET istr = substring((ipos+ 1),1000,trim(istr))
       SET string_index->strlist[i].normalized_string = trim(istr)
      ENDIF
    ENDFOR
   ENDIF
   CALL bederrorcheck("Error 007: Failed to normalize the term display.")
 END ;Subroutine
 SUBROUTINE changeprimarydisplayterm(dummyvar)
  IF ((request->primary_ind=1))
   SET nomenbyckirequest->concept_cki = request->concept_cki
   SET nomenbyckirequest->all_ind = 0
   SET nomenbyckirequest->concept_source_cd = 0.0
   SET nomenbyckirequest->concept_identifier = " "
   EXECUTE bed_get_nomen_by_cki  WITH replace("REQUEST",nomenbyckirequest), replace("REPLY",
    nomenbyckireply)
   IF (size(nomenbyckireply->synonyms,5) > 1)
    FOR (x = 1 TO size(nomenbyckireply->synonyms,5))
      IF ((nomenbyckireply->synonyms[x].nomenclature_id != request->nomenclature_id)
       AND (nomenbyckireply->synonyms[x].primary_cterm_ind=1))
       UPDATE  FROM nomenclature n
        SET n.primary_cterm_ind = 0
        WHERE (n.nomenclature_id=nomenbyckireply->synonyms[x].nomenclature_id)
         AND n.nomenclature_id > 0.0
        WITH nocounter
       ;end update
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  CALL bederrorcheck("Error 012: Failed to update primary display term for synonyms")
 END ;Subroutine
END GO
