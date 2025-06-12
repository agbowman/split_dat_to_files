CREATE PROGRAM bed_ens_batch_direct_email:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 provision_failures_occurred_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD emaillist
 RECORD emaillist(
   1 emails[*]
     2 entity_name = vc
     2 entity_id = f8
     2 name_first = vc
     2 name_last = vc
     2 initial_first = vc
     2 initial_middle = vc
     2 name_full_formatted = vc
     2 user_name = vc
     2 actual_email = vc
     2 actual_email_encode = vc
     2 position = vc
     2 provisioning_status = i4
 ) WITH protect
 FREE RECORD sxml
 RECORD sxml(
   1 data = vc
 )
 FREE RECORD oauthreply
 RECORD oauthreply(
   1 header = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE code_value = f8
 IF ( NOT (validate(cs43_internalsecure_cd)))
  SET code_value = uar_get_code_by("MEANING",43,"INTSECEMAIL")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",43,"INTERNALSECUREEMAIL")
  ENDIF
  DECLARE cs43_internalsecure_cd = f8 WITH protect, constant(code_value)
 ENDIF
 IF ( NOT (validate(cs281_freetext_cd)))
  SET code_value = uar_get_code_by("MEANING",281,"FREETEXT")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",281,"FREETEXT")
  ENDIF
  DECLARE cs281_freetext_cd = f8 WITH protect, constant(code_value)
 ENDIF
 IF ( NOT (validate(cs89_cernerdirect_cd)))
  SET code_value = uar_get_code_by("MEANING",89,"CERNERDIRECT")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",89,"CERNERDIRECT")
  ENDIF
  DECLARE cs89_cernerdirect_cd = f8 WITH protect, constant(code_value)
 ENDIF
 IF ( NOT (validate(cs23056_email_cd)))
  SET code_value = uar_get_code_by("MEANING",23056,"MAILTO")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",23056,"EMAIL")
  ENDIF
  DECLARE cs23056_email_cd = f8 WITH protect, constant(code_value)
 ENDIF
 IF ( NOT (validate(cs48_active_cd)))
  SET code_value = uar_get_code_by("MEANING",48,"ACTIVE")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",48,"ACTIVE")
  ENDIF
  DECLARE cs48_active_cd = f8 WITH protect, constant(code_value)
 ENDIF
 IF ( NOT (validate(cs8_unauth_cd)))
  SET code_value = uar_get_code_by("MEANING",8,"UNAUTH")
  IF (code_value < 0)
   SET code_value = uar_get_code_by("DISPLAYKEY",8,"UNAUTH")
  ENDIF
  DECLARE cs8_unauth_cd = f8 WITH protect, constant(code_value)
 ENDIF
 DECLARE size_of_entities = i4 WITH protect, constant(size(request->entities,5))
 DECLARE prod_environment = i4 WITH protect, constant(0)
 DECLARE non_prod_environment = i4 WITH protect, constant(1)
 DECLARE success_file_name = vc
 DECLARE in_error_file_name = vc
 SET success_file_name = concat("success_direct_emails_uploaded_",format(cnvtdatetime(curdate,
    curtime3),"YYYYMMDDHHMMSS;;Q"),".dat")
 SET in_error_file_name = concat("in_error_direct_emails_uploaded_",format(cnvtdatetime(curdate,
    curtime3),"YYYYMMDDHHMMSS;;Q"),".dat")
 DECLARE curr_email_candidate = vc WITH protect
 DECLARE curr_email_candidate_encode = vc WITH protect
 DECLARE dupenumtoappend = vc WITH protect
 DECLARE cpm_http_transaction = i4 WITH protect, constant(2000)
 DECLARE category_col_start = i4 WITH protect, constant(1)
 DECLARE value_col_start = i4 WITH protect, constant(50)
 DECLARE oauthmsg = i4 WITH noconstant(0)
 DECLARE oauthreq = i4 WITH noconstant(0)
 DECLARE oauthrep = i4 WITH noconstant(0)
 DECLARE oauthstatus = i4 WITH noconstant(0)
 DECLARE oauth_response = i4 WITH noconstant(0)
 DECLARE success_ind = i4 WITH noconstant(0)
 DECLARE oauth_token = vc
 DECLARE oauth_token_secret = vc
 DECLARE oauth_consumer_key = vc
 DECLARE oauth_accessor_secret = vc
 DECLARE header = vc
 DECLARE new_oauth_trans_ind = i2 WITH protect, noconstant(0)
 SET oauthreply->status_data.status = "F"
 SET oauthmsg = uar_srvselectmessage(99999131)
 IF (oauthmsg=0)
  CALL echo(
   "New OAuth Transaction does not exist. Calling old CernerOAuthProxy.1.StartOAuthSession.User transaction"
   )
  SET oauthmsg = uar_srvselectmessage(99999115)
  IF (oauthmsg=0)
   CALL bederror("001: Invalid OAUTH message received from SCP 387")
  ENDIF
 ELSE
  SET new_oauth_trans_ind = 1
 ENDIF
 SET oauthreq = uar_srvcreaterequest(oauthmsg)
 SET oauthrep = uar_srvcreatereply(oauthmsg)
 SET stat = uar_srvexecute(oauthmsg,oauthreq,oauthrep)
 SET oauthstatus = uar_srvgetstruct(oauthrep,"status")
 SET success_ind = uar_srvgetshort(oauthstatus,"success_ind")
 IF (success_ind=0)
  CALL bederror("002: Status for OAuth connection failure")
 ENDIF
 DECLARE ccldate = dq8
 SET ccldate = cnvtdatetime(curdate,curtime3)
 DECLARE epoch_date_start = f8
 DECLARE epoch_date_current = f8
 DECLARE epoch_date = i4
 DECLARE oauth_nonce = vc
 DECLARE oauth_signature_method = vc
 DECLARE oauth_version = vc
 DECLARE oauth_timestamp = vc
 DECLARE oauth_signature = vc
 SET epoch_date_start = (cnvtdatetime("01-JAN-1970")/ 10000000)
 SET epoch_date_current = (ccldate/ 10000000)
 SET epoch_date = (epoch_date_current - epoch_date_start)
 IF (new_oauth_trans_ind=1)
  SET oauth_response = uar_srvgetstruct(oauthrep,"oauth_access_token")
 ELSE
  SET oauth_response = uar_srvgetstruct(oauthrep,"oauth_response")
 ENDIF
 SET oauth_token = uar_srvgetstringptr(oauth_response,"oauth_token")
 CALL bedlogmessage("Setup001",concat("OAUTH token: ",oauth_token))
 SET oauth_token_secret = uar_srvgetstringptr(oauth_response,"oauth_token_secret")
 CALL bedlogmessage("Setup002",concat("OAUTH token secret: ",oauth_token_secret))
 SET oauth_consumer_key = uar_srvgetstringptr(oauth_response,"oauth_consumer_key")
 CALL bedlogmessage("Setup003",concat("OAUTH consumer key:",oauth_consumer_key))
 SET oauth_accessor_secret = uar_srvgetstringptr(oauth_response,"oauth_accessor_secret")
 SET oauth_signature_method = "PLAINTEXT"
 SET oauth_version = "1.0"
 SET oauth_timestamp = cnvtstring(epoch_date)
 SET oauth_nonce = trim(format((epoch_date_current * epoch_date_start),
   "###############################;T(1)"),3)
 SET oauth_signature = concat(oauth_accessor_secret,"%26",oauth_token_secret)
 DECLARE generateemailsbasedonformattype(dummyvar=i2) = i2
 DECLARE populateemaillist(currentity=i4) = i2
 DECLARE checkphonetableforduplicateemails(candidate=vc) = i2
 DECLARE firstnamelastname(dummyvar=i2) = i2
 DECLARE firstnamemiddleinitiallastname(dummyvar=i2) = i2
 DECLARE firstinitiallastname(dummyvar=i2) = i2
 DECLARE firstinitialmiddleinitiallastname(dummyvar=i2) = i2
 DECLARE millname(dummyvar=i2) = i2
 DECLARE postprovisioningtocernerdirect(emailindextoprovision=i4) = i2
 DECLARE ensurepersonemail(dummyvar=i2) = i2
 DECLARE writeemailstologfiles(dummyvar=i2) = i2
 CALL generateemailsbasedonformattype(0)
 CALL writeemailstologfiles(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE generateemailsbasedonformattype(dummyvar)
   SET stat = alterlist(emaillist->emails,size_of_entities)
   FOR (currentity = 1 TO size_of_entities)
     IF ((request->entities[currentity].parent_entity_name="PERSON"))
      CALL populateemaillist(currentity)
      CASE (request->format_type)
       OF 0:
        CALL firstnamelastname(0)
       OF 1:
        CALL firstnamemiddleinitiallastname(0)
       OF 2:
        CALL firstinitiallastname(0)
       OF 3:
        CALL firstinitialmiddleinitiallastname(0)
       OF 4:
        CALL millname(0)
       ELSE
        CALL bederror("ERROR001: Invalid Format Type.")
      ENDCASE
      IF (postprovisioningtocernerdirect(currentity)=1)
       CALL ensurepersonemail(currentity)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE populateemaillist(currentity)
   SELECT INTO "nl:"
    FROM person p,
     prsnl prsnl
    PLAN (p
     WHERE (p.person_id=request->entities[currentity].parent_entity_id))
     JOIN (prsnl
     WHERE (prsnl.person_id=request->entities[currentity].parent_entity_id))
    DETAIL
     emaillist->emails[currentity].entity_id = request->entities[currentity].parent_entity_id,
     emaillist->emails[currentity].entity_name = request->entities[currentity].parent_entity_name,
     emaillist->emails[currentity].name_first = trim(prsnl.name_first,5),
     emaillist->emails[currentity].name_last = trim(prsnl.name_last,5), emaillist->emails[currentity]
     .user_name = trim(prsnl.username,5), emaillist->emails[currentity].initial_first = substring(1,1,
      trim(cnvtlower(prsnl.name_first),6)),
     emaillist->emails[currentity].initial_middle = substring(1,1,trim(cnvtlower(p.name_middle),6)),
     emaillist->emails[currentity].name_full_formatted = prsnl.name_full_formatted, emaillist->
     emails[currentity].position = uar_get_code_display(prsnl.position_cd)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL bederror("ERROR002: No person with the person_id exists on the person table.")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE checkphonetableforduplicateemails(candidate)
   SELECT INTO "nl:"
    FROM phone p
    PLAN (p
     WHERE (p.parent_entity_name=request->entities[currentity].parent_entity_name)
      AND p.phone_type_cd=cs43_internalsecure_cd
      AND cnvtlower(p.phone_num)=candidate)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   CALL bederrorcheck("ERROR003: Could not retrieve from phone table.")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE firstnamelastname(dummyvar)
   DECLARE dupappennum = i4
   DECLARE duplicatesremain = i4
   SET dupappennum = 1
   SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].name_first),8),
     5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),"@",trim(cnvtlower(
      request->domain_addr),7))
   SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
       name_first),8),5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),
    "%40",trim(cnvtlower(request->domain_addr),7))
   IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
    SET duplicatesremain = 1
    WHILE (duplicatesremain=1)
      SET dupenumtoappend = cnvtstring(dupappennum)
      SET dupenumtoappend = trim(dupenumtoappend,7)
      SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].name_first),
         8),5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),dupenumtoappend,
       "@",
       trim(cnvtlower(request->domain_addr),7))
      SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
          name_first),8),5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),
       dupenumtoappend,"%40",
       trim(cnvtlower(request->domain_addr),7))
      IF (checkphonetableforduplicateemails(curr_email_candidate)=0)
       SET emaillist->emails[currentity].actual_email = curr_email_candidate
       SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
       SET duplicatesremain = 0
      ELSE
       SET dupappennum = (dupappennum+ 1)
      ENDIF
    ENDWHILE
   ELSE
    SET emaillist->emails[currentity].actual_email = curr_email_candidate
    SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
    SET duplicatesremain = 0
   ENDIF
   CALL bederrorcheck("ERROR004: Could not generate firstName.lastName1 based e-mail.")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE firstnamemiddleinitiallastname(dummyvar)
   DECLARE dupappennum = i4
   DECLARE duplicatesremain = i4
   SET dupappennum = 1
   SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].name_first),8),
     5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),"@",trim(cnvtlower(
      request->domain_addr),7))
   SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
       name_first),8),5),".",trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),
    "%40",trim(cnvtlower(request->domain_addr),7))
   IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
    SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].name_first),8
       ),5),".",emaillist->emails[currentity].initial_middle,trim(trim(cnvtlower(emaillist->emails[
        currentity].name_last),8),5),"@",
     trim(cnvtlower(request->domain_addr),7))
    SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
        name_first),8),5),".",emaillist->emails[currentity].initial_middle,trim(trim(cnvtlower(
        emaillist->emails[currentity].name_last),8),5),"%40",
     trim(cnvtlower(request->domain_addr),7))
    IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
     SET duplicatesremain = 1
     WHILE (duplicatesremain=1)
       SET dupenumtoappend = cnvtstring(dupappennum)
       SET dupenumtoappend = trim(dupenumtoappend,7)
       SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].name_first
           ),8),5),".",emaillist->emails[currentity].initial_middle,trim(trim(cnvtlower(emaillist->
           emails[currentity].name_last),8),5),dupenumtoappend,
        "@",trim(cnvtlower(request->domain_addr),7))
       SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
           name_first),8),5),".",emaillist->emails[currentity].initial_middle,trim(trim(cnvtlower(
           emaillist->emails[currentity].name_last),8),5),dupenumtoappend,
        "%40",trim(cnvtlower(request->domain_addr),7))
       IF (checkphonetableforduplicateemails(curr_email_candidate)=0)
        SET emaillist->emails[currentity].actual_email = curr_email_candidate
        SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
        SET duplicatesremain = 0
       ELSE
        SET dupappennum = (dupappennum+ 1)
       ENDIF
     ENDWHILE
    ELSE
     SET emaillist->emails[currentity].actual_email = curr_email_candidate
     SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
     SET duplicatesremain = 0
    ENDIF
   ELSE
    SET emaillist->emails[currentity].actual_email = curr_email_candidate
    SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
    SET duplicatesremain = 0
   ENDIF
   CALL bederrorcheck("ERROR005: Could not generate firstName.middleInitialLastName2 based e-mail.")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE firstinitiallastname(dummyvar)
   DECLARE dupappennum = i4
   DECLARE duplicatesremain = i4
   SET dupappennum = 1
   SET curr_email_candidate = concat(emaillist->emails[currentity].initial_first,trim(trim(cnvtlower(
       emaillist->emails[currentity].name_last),8),5),"@",trim(cnvtlower(request->domain_addr),7))
   SET curr_email_candidate_encode = concat(emaillist->emails[currentity].initial_first,trim(trim(
      cnvtlower(emaillist->emails[currentity].name_last),8),5),"%40",trim(cnvtlower(request->
      domain_addr),7))
   IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
    SET duplicatesremain = 1
    WHILE (duplicatesremain=1)
      SET dupenumtoappend = cnvtstring(dupappennum)
      SET dupenumtoappend = trim(dupenumtoappend,7)
      SET curr_email_candidate = concat(emaillist->emails[currentity].initial_first,trim(trim(
         cnvtlower(emaillist->emails[currentity].name_last),8),5),dupenumtoappend,"@",trim(cnvtlower(
         request->domain_addr),7))
      SET curr_email_candidate_encode = concat(emaillist->emails[currentity].initial_first,trim(trim(
         cnvtlower(emaillist->emails[currentity].name_last),8),5),dupenumtoappend,"%40",trim(
        cnvtlower(request->domain_addr),7))
      IF (checkphonetableforduplicateemails(curr_email_candidate)=0)
       SET emaillist->emails[currentity].actual_email = curr_email_candidate
       SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
       SET duplicatesremain = 0
      ELSE
       SET dupappennum = (dupappennum+ 1)
      ENDIF
    ENDWHILE
   ELSE
    SET emaillist->emails[currentity].actual_email = curr_email_candidate
    SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
    SET duplicatesremain = 0
   ENDIF
   CALL bederrorcheck("ERROR006: Could not generate firstInitialLastName2 based e-mail.")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE firstinitialmiddleinitiallastname(dummyvar)
   DECLARE dupappennum = i4
   DECLARE duplicatesremain = i4
   SET dupappennum = 1
   SET curr_email_candidate = concat(emaillist->emails[currentity].initial_first,trim(trim(cnvtlower(
       emaillist->emails[currentity].name_last),8),5),"@",trim(cnvtlower(request->domain_addr),7))
   SET curr_email_candidate_encode = concat(emaillist->emails[currentity].initial_first,trim(trim(
      cnvtlower(emaillist->emails[currentity].name_last),8),5),"%40",trim(cnvtlower(request->
      domain_addr),7))
   IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
    SET curr_email_candidate = concat(emaillist->emails[currentity].initial_first,emaillist->emails[
     currentity].initial_middle,trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8),5),
     "@",trim(cnvtlower(request->domain_addr),7))
    SET curr_email_candidate_encode = concat(emaillist->emails[currentity].initial_first,emaillist->
     emails[currentity].initial_middle,trim(trim(cnvtlower(emaillist->emails[currentity].name_last),8
       ),5),"%40",trim(cnvtlower(request->domain_addr),7))
    IF (checkphonetableforduplicateemails(curr_email_candidate)=1)
     SET duplicatesremain = 1
     WHILE (duplicatesremain=1)
       SET dupenumtoappend = cnvtstring(dupappennum)
       SET dupenumtoappend = trim(dupenumtoappend,7)
       SET curr_email_candidate = concat(emaillist->emails[currentity].initial_first,emaillist->
        emails[currentity].initial_middle,trim(trim(cnvtlower(emaillist->emails[currentity].name_last
           ),8),5),dupenumtoappend,"@",
        trim(cnvtlower(request->domain_addr),7))
       SET curr_email_candidate_encode = concat(emaillist->emails[currentity].initial_first,emaillist
        ->emails[currentity].initial_middle,trim(trim(cnvtlower(emaillist->emails[currentity].
           name_last),8),5),dupenumtoappend,"%40",
        trim(cnvtlower(request->domain_addr),7))
       IF (checkphonetableforduplicateemails(curr_email_candidate)=0)
        SET emaillist->emails[currentity].actual_email = curr_email_candidate
        SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
        SET duplicatesremain = 0
       ELSE
        SET dupappennum = (dupappennum+ 1)
       ENDIF
     ENDWHILE
    ELSE
     SET emaillist->emails[currentity].actual_email = curr_email_candidate
     SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
     SET duplicatesremain = 0
    ENDIF
   ELSE
    SET emaillist->emails[currentity].actual_email = curr_email_candidate
    SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
    SET duplicatesremain = 0
   ENDIF
   CALL bederrorcheck("ERROR007: Could not generate firstInitialMiddleInitialLastName2 based e-mail."
    )
   RETURN(1)
 END ;Subroutine
 SUBROUTINE millname(dummyvar)
   SET curr_email_candidate = concat(trim(trim(cnvtlower(emaillist->emails[currentity].user_name),8),
     5),"@",request->domain_addr)
   SET curr_email_candidate_encode = concat(trim(trim(cnvtlower(emaillist->emails[currentity].
       user_name),8),5),"%40",request->domain_addr)
   SET emaillist->emails[currentity].actual_email = curr_email_candidate
   SET emaillist->emails[currentity].actual_email_encode = curr_email_candidate_encode
   CALL bederrorcheck("ERROR008: Could not generate Millennium Username based e-mail.")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE postprovisioningtocernerdirect(emailindextoprovision)
   IF ((request->environment_type=prod_environment))
    SET sxml->data = "https://api.cernerdirect.com/provisioning/user/"
   ELSEIF ((request->environment_type=non_prod_environment))
    SET sxml->data = "https://api.stagingcernerdirect.com/provisioning/user/"
   ENDIF
   SET sxml->data = concat(sxml->data,trim(emaillist->emails[emailindextoprovision].
     actual_email_encode),"?")
   SET sxml->data = concat(sxml->data,"oauth_token=",oauth_token)
   SET sxml->data = concat(sxml->data,"&","oauth_consumer_key=",oauth_consumer_key)
   SET sxml->data = concat(sxml->data,"&","oauth_signature_method=",oauth_signature_method)
   SET sxml->data = concat(sxml->data,"&","oauth_timestamp=",trim(oauth_timestamp))
   SET sxml->data = concat(sxml->data,"&","oauth_nonce=",oauth_nonce)
   SET sxml->data = concat(sxml->data,"&","oauth_signature=",oauth_signature)
   DECLARE executehttpcall(emailindex=i4) = i4
   DECLARE hhttpmsg = i4 WITH protect
   DECLARE hhttpreq = i4 WITH protect
   DECLARE hhttprep = i4 WITH protect
   DECLARE nhttpstatus = i4 WITH private
   DECLARE stat = i4
   DECLARE size = i4
   SET nhttpstatus = executehttpcall(emailindextoprovision)
   CALL bedlogmessage("postProvisioningToCernerDirect",concat(cnvtstring(nhttpstatus),trim(emaillist
      ->emails[emailindextoprovision].actual_email_encode)))
   CALL bederrorcheck("ERROR008: Failed posting e-mail to be provisioned to Cerner Direct.")
   IF (nhttpstatus=201)
    CALL bedlogmessage("postProvisioningToCernerDirect",nhttpstatus)
    SET emaillist->emails[emailindextoprovision].provisioning_status = nhttpstatus
    CALL bedlogmessage("postProvisioningToCernerDirect",emaillist->emails[emailindextoprovision].
     provisioning_status)
    RETURN(1)
   ELSE
    SET emaillist->emails[emailindextoprovision].provisioning_status = nhttpstatus
    SET reply->provision_failures_occurred_ind = 1
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE executehttpcall(emailindex)
   DECLARE fname = vc WITH protect, noconstant("")
   DECLARE lname = vc WITH protect, noconstant("")
   DECLARE nhttpstatus = i4 WITH private
   SET hhttpmsg = uar_srvselectmessage(cpm_http_transaction)
   SET hhttpreq = uar_srvcreaterequest(hhttpmsg)
   SET hhttprep = uar_srvcreatereply(hhttpmsg)
   CALL echo(build("sXML->data...",sxml->data))
   SET hheader = uar_srvgetstruct(hhttpreq,"header")
   SET stat = uar_srvsetstring(hheader,"content_type","application/json")
   SET fname = replace(emaillist->emails[emailindex].name_first,"\","\\",0)
   SET lname = replace(emaillist->emails[emailindex].name_last,"\","\\",0)
   SET fname = replace(fname,'"','\"',0)
   SET lname = replace(lname,'"','\"',0)
   SET fname = replace(fname,"/","\/",0)
   SET lname = replace(lname,"/","\/",0)
   SET requestbody = build2('{"firstName":"',fname,'",','"lastName":"',lname,
    '"}')
   CALL echo(requestbody)
   IF (size(requestbody,1) > 0)
    SET stat = uar_srvsetasis(hhttpreq,"request_buffer",nullterm(requestbody),size(requestbody,1))
   ENDIF
   SET stat = uar_srvsetstringfixed(hhttpreq,"uri",sxml->data,size(sxml->data,1))
   SET stat = uar_srvsetstring(hhttpreq,"method","POST")
   SET stat = uar_srvexecute(hhttpmsg,hhttpreq,hhttprep)
   SET nhttpstatus = uar_srvgetlong(hhttprep,"http_status_code")
   RETURN(nhttpstatus)
 END ;Subroutine
 SUBROUTINE writeemailstologfiles(dummyvar)
   SELECT INTO value(success_file_name)
    email_address = substring(1,100,emaillist->emails[d.seq].actual_email), person_id = trim(
     cnvtstring(emaillist->emails[d.seq].entity_id),5), prsnl_last = substring(1,30,emaillist->
     emails[d.seq].name_last),
    prsnl_first = substring(1,30,emaillist->emails[d.seq].name_first), prsnl_full = substring(1,60,
     emaillist->emails[d.seq].name_full_formatted), prsnl_username = substring(1,30,emaillist->
     emails[d.seq].user_name),
    prsnl_position = substring(1,30,emaillist->emails[d.seq].position), direct_status = trim(
     cnvtstring(emaillist->emails[d.seq].provisioning_status),5)
    FROM (dummyt d  WITH seq = value(size(emaillist->emails,5)))
    PLAN (d
     WHERE (emaillist->emails[d.seq].provisioning_status=201))
    WITH heading, format, counter,
     maxcol = 600, separator = "|"
   ;end select
   CALL bederrorcheck("ERROR010: Failed writing e-mail to success log file")
   SELECT INTO value(in_error_file_name)
    email_address = substring(1,100,emaillist->emails[d.seq].actual_email), person_id = trim(
     cnvtstring(emaillist->emails[d.seq].entity_id),5), prsnl_last = substring(1,30,emaillist->
     emails[d.seq].name_last),
    prsnl_first = substring(1,30,emaillist->emails[d.seq].name_first), prsnl_full = substring(1,60,
     emaillist->emails[d.seq].name_full_formatted), prsnl_username = substring(1,30,emaillist->
     emails[d.seq].user_name),
    prsnl_position = substring(1,30,emaillist->emails[d.seq].position), direct_status = trim(
     cnvtstring(emaillist->emails[d.seq].provisioning_status),5)
    FROM (dummyt d  WITH seq = value(size(emaillist->emails,5)))
    PLAN (d
     WHERE (emaillist->emails[d.seq].provisioning_status != 201))
    WITH heading, format, counter,
     maxcol = 600, separator = "|"
   ;end select
   CALL bederrorcheck("ERROR011: Failed writing e-mail to failed log file")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ensurepersonemail(emailindextoprovision)
   INSERT  FROM phone ph
    SET ph.phone_id = seq(phone_seq,nextval), ph.parent_entity_id = emaillist->emails[
     emailindextoprovision].entity_id, ph.parent_entity_name = emaillist->emails[
     emailindextoprovision].entity_name,
     ph.phone_num = emaillist->emails[emailindextoprovision].actual_email, ph.phone_num_key =
     cnvtalphanum(cnvtupper(emaillist->emails[emailindextoprovision].actual_email)), ph.phone_type_cd
      = cs43_internalsecure_cd,
     ph.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ph.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 14:00:00"), ph.phone_format_cd = cs281_freetext_cd,
     ph.phone_type_seq = 1, ph.contributor_system_cd = cs89_cernerdirect_cd, ph.contact_method_cd =
     cs23056_email_cd,
     ph.updt_dt_tm = cnvtdatetime(curdate,curtime3), ph.updt_id = reqinfo->updt_id, ph.updt_task =
     3028,
     ph.updt_applctx = 1670070652.00, ph.active_status_cd = cs48_active_cd, ph.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ph.active_status_prsnl_id = reqinfo->updt_id, ph.active_ind = 1, ph.data_status_cd =
     cs8_unauth_cd,
     ph.data_status_dt_tm = cnvtdatetime(curdate,curtime3), ph.data_status_prsnl_id = reqinfo->
     updt_id
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR012: Error ensuring to Phone table.")
   RETURN(1)
 END ;Subroutine
END GO
