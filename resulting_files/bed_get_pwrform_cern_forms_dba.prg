CREATE PROGRAM bed_get_pwrform_cern_forms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 forms[*]
      2 form_uid = vc
      2 description = vc
      2 dcp_forms_ref_id = f8
      2 match_description = vc
      2 definition = vc
      2 enforce_required_ind = i2
      2 done_charting_ind = i2
      2 event_set_name = vc
      2 event_cd = f8
      2 event_cd_display = vc
      2 text_rendition_event_cd = f8
      2 note_type_display = vc
      2 event_cd_meaning = vc
      2 note_type_meaning = vc
      2 name = vc
      2 pwrfrm_imp_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE cnt = i4 WITH protect, noconstant(0)
 CALL bedbeginscript(0)
 SELECT INTO "nl:"
  FROM cnt_powerform p,
   cnt_pf_key2 pk,
   cnt_code_value_key cv1,
   cnt_code_value_key cv2,
   dcp_forms_ref d
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pk
   WHERE pk.form_uid=p.form_uid)
   JOIN (cv1
   WHERE cv1.code_value_uid=outerjoin(p.form_event_cduid))
   JOIN (cv2
   WHERE cv2.code_value_uid=outerjoin(p.text_rendition_event_cduid))
   JOIN (d
   WHERE d.dcp_forms_ref_id=outerjoin(pk.dcp_forms_ref_id)
    AND d.active_ind=outerjoin(1))
  ORDER BY pk.form_description
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->forms,cnt), reply->forms[cnt].form_uid = pk.form_uid,
   reply->forms[cnt].description = pk.form_description, reply->forms[cnt].dcp_forms_ref_id = pk
   .dcp_forms_ref_id, reply->forms[cnt].match_description = d.description,
   reply->forms[cnt].definition = pk.form_definition
   IF (((p.form_flag=1) OR (p.form_flag=3)) )
    reply->forms[cnt].enforce_required_ind = 1
   ELSE
    reply->forms[cnt].enforce_required_ind = 0
   ENDIF
   IF (((p.form_flag=2) OR (p.form_flag=3)) )
    reply->forms[cnt].done_charting_ind = 1
   ELSE
    reply->forms[cnt].done_charting_ind = 0
   ENDIF
   reply->forms[cnt].event_set_name = p.form_event_set_name
   IF (p.form_event_cd > 0)
    reply->forms[cnt].event_cd = p.form_event_cd, reply->forms[cnt].event_cd_display =
    uar_get_code_display(p.form_event_cd), reply->forms[cnt].event_cd_meaning = uar_get_code_meaning(
     p.form_event_cd)
   ELSE
    reply->forms[cnt].event_cd = cv1.code_value, reply->forms[cnt].event_cd_display = cv1.display,
    reply->forms[cnt].event_cd_meaning = cv1.cdf_meaning
   ENDIF
   IF (p.text_rendition_event_cd > 0)
    reply->forms[cnt].text_rendition_event_cd = p.text_rendition_event_cd, reply->forms[cnt].
    note_type_display = uar_get_code_display(p.text_rendition_event_cd), reply->forms[cnt].
    note_type_meaning = uar_get_code_meaning(p.text_rendition_event_cd)
   ELSE
    reply->forms[cnt].text_rendition_event_cd = cv2.code_value, reply->forms[cnt].note_type_display
     = cv2.display, reply->forms[cnt].note_type_meaning = cv2.cdf_meaning
   ENDIF
   reply->forms[cnt].pwrfrm_imp_dt_tm = p.updt_dt_tm
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR 001: Error in retrieving imported powerform details")
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    dcp_forms_ref r
   PLAN (d
    WHERE (reply->forms[d.seq].dcp_forms_ref_id=0))
    JOIN (r
    WHERE (r.definition=reply->forms[d.seq].definition)
     AND r.active_ind=true)
   DETAIL
    reply->forms[d.seq].dcp_forms_ref_id = r.dcp_forms_ref_id, reply->forms[d.seq].match_description
     = r.description
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 002: Error in finding form mathes by name")
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
