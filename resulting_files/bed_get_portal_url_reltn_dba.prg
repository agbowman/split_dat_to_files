CREATE PROGRAM bed_get_portal_url_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 urls[*]
      2 br_portal_url_id = f8
      2 eligible_providers[*]
        3 br_eligible_provider_id = f8
        3 name_full_formatted = vc
        3 invitation_provided_event_code
          4 event_cd = f8
          4 display = vc
        3 patient_declined_event_code
          4 event_cd = f8
          4 display = vc
      2 ccn[*]
        3 br_ccn_id = f8
        3 ccn_name = vc
        3 invitation_provided_event_code
          4 event_cd = f8
          4 display = vc
        3 patient_declined_event_code
          4 event_cd = f8
          4 display = vc
      2 alias_pool
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 alias_type
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 url = vc
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
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
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 CALL bedbeginscript(0)
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE request_size = i4 WITH protect, noconstant(size(request->urls,5))
 DECLARE invitation_provided_type_flag = i2 WITH protect, constant(1)
 DECLARE patient_declined_type_flag = i2 WITH protect, constant(2)
 DECLARE alias_pool_codeset = i4 WITH protect, constant(263)
 DECLARE getportalurlreltn(null) = i2
 IF (request_size=0)
  SET load_ep_ccn_ind = request->load_ep_ccn_ind
  FREE RECORD request
  RECORD request(
    1 urls[*]
      2 br_portal_url_id = f8
    1 load_ep_ccn_ind = i2
  )
  SELECT INTO "nl:"
   FROM br_portal_url port_url
   PLAN (port_url
    WHERE port_url.active_ind=1
     AND port_url.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND port_url.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    request_size = (request_size+ 1), stat = alterlist(request->urls,request_size), request->urls[
    request_size].br_portal_url_id = port_url.br_portal_url_id
   WITH nocounter
  ;end select
  IF (request_size=0)
   GO TO exit_script
  ENDIF
  SET request->load_ep_ccn_ind = load_ep_ccn_ind
  CALL bederrorcheck("Failed to get URLs")
 ENDIF
 CALL getportalurlreltn(null)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = request_size),
   br_portal_url port_url
  PLAN (d)
   JOIN (port_url
   WHERE (port_url.br_portal_url_id=reply->urls[d.seq].br_portal_url_id))
  DETAIL
   reply->urls[d.seq].url = port_url.br_portal_url
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to get URL displays")
 SUBROUTINE getportalurlreltn(null)
   CALL bedlogmessage("getPortalURLReltn","Entering ...")
   SET stat = alterlist(reply->urls,request_size)
   FOR (x = 1 TO request_size)
     SET reply->urls[x].br_portal_url_id = request->urls[x].br_portal_url_id
   ENDFOR
   DECLARE ccn_cnt = i4 WITH protect, noconstant(0)
   DECLARE ep_cnt = i4 WITH protect, noconstant(0)
   IF ((request->load_ep_ccn_ind=1))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(request_size)),
      br_portal_url_svc_entity_r r,
      br_eligible_provider ep,
      prsnl p,
      br_prtl_url_se_r_cd_r inv_prov_event,
      code_value inv_prov_cd,
      br_prtl_url_se_r_cd_r pat_decl_event,
      code_value pat_decl_cd
     PLAN (d)
      JOIN (r
      WHERE (r.br_portal_url_id=reply->urls[d.seq].br_portal_url_id)
       AND trim(cnvtupper(r.parent_entity_name))="BR_ELIGIBLE_PROVIDER"
       AND r.active_ind=1
       AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ep
      WHERE ep.br_eligible_provider_id=r.parent_entity_id
       AND ep.logical_domain_id=log_domain_id)
      JOIN (p
      WHERE p.person_id=ep.provider_id)
      JOIN (inv_prov_event
      WHERE inv_prov_event.br_portal_url_svc_entity_r_id=outerjoin(r.br_portal_url_svc_entity_r_id)
       AND inv_prov_event.code_type_flag=outerjoin(invitation_provided_type_flag)
       AND inv_prov_event.active_ind=outerjoin(1)
       AND inv_prov_event.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
       AND inv_prov_event.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (inv_prov_cd
      WHERE inv_prov_cd.code_value=outerjoin(inv_prov_event.portal_attr_cd_value))
      JOIN (pat_decl_event
      WHERE pat_decl_event.br_portal_url_svc_entity_r_id=outerjoin(r.br_portal_url_svc_entity_r_id)
       AND pat_decl_event.code_type_flag=outerjoin(patient_declined_type_flag)
       AND pat_decl_event.active_ind=outerjoin(1)
       AND pat_decl_event.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
       AND pat_decl_event.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (pat_decl_cd
      WHERE pat_decl_cd.code_value=outerjoin(pat_decl_event.portal_attr_cd_value))
     ORDER BY d.seq, r.br_portal_url_id, r.br_portal_url_svc_entity_r_id
     HEAD r.br_portal_url_id
      ep_cnt = 0
     DETAIL
      ep_cnt = (ep_cnt+ 1), stat = alterlist(reply->urls[d.seq].eligible_providers,ep_cnt), reply->
      urls[d.seq].eligible_providers[ep_cnt].br_eligible_provider_id = r.parent_entity_id,
      reply->urls[d.seq].eligible_providers[ep_cnt].name_full_formatted = p.name_full_formatted,
      reply->urls[d.seq].eligible_providers[ep_cnt].invitation_provided_event_code.event_cd =
      inv_prov_cd.code_value, reply->urls[d.seq].eligible_providers[ep_cnt].
      invitation_provided_event_code.display = inv_prov_cd.display,
      reply->urls[d.seq].eligible_providers[ep_cnt].patient_declined_event_code.event_cd =
      pat_decl_cd.code_value, reply->urls[d.seq].eligible_providers[ep_cnt].
      patient_declined_event_code.display = pat_decl_cd.display
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to get URL EP Reltn")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(request_size)),
      br_portal_url_svc_entity_r r,
      br_ccn c,
      br_prtl_url_se_r_cd_r inv_prov_event,
      code_value inv_prov_cd,
      br_prtl_url_se_r_cd_r pat_decl_event,
      code_value pat_decl_cd
     PLAN (d)
      JOIN (r
      WHERE (r.br_portal_url_id=reply->urls[d.seq].br_portal_url_id)
       AND trim(cnvtupper(r.parent_entity_name))="BR_CCN"
       AND r.active_ind=1
       AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (c
      WHERE c.br_ccn_id=r.parent_entity_id
       AND c.logical_domain_id=log_domain_id)
      JOIN (inv_prov_event
      WHERE inv_prov_event.br_portal_url_svc_entity_r_id=outerjoin(r.br_portal_url_svc_entity_r_id)
       AND inv_prov_event.code_type_flag=outerjoin(invitation_provided_type_flag)
       AND inv_prov_event.active_ind=outerjoin(1)
       AND inv_prov_event.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
       AND inv_prov_event.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (inv_prov_cd
      WHERE inv_prov_cd.code_value=outerjoin(inv_prov_event.portal_attr_cd_value))
      JOIN (pat_decl_event
      WHERE pat_decl_event.br_portal_url_svc_entity_r_id=outerjoin(r.br_portal_url_svc_entity_r_id)
       AND pat_decl_event.code_type_flag=outerjoin(patient_declined_type_flag)
       AND pat_decl_event.active_ind=outerjoin(1)
       AND pat_decl_event.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
       AND pat_decl_event.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (pat_decl_cd
      WHERE pat_decl_cd.code_value=outerjoin(pat_decl_event.portal_attr_cd_value))
     ORDER BY d.seq, r.br_portal_url_id, r.br_portal_url_svc_entity_r_id,
      c.br_ccn_id
     HEAD r.br_portal_url_id
      ccn_cnt = 0
     DETAIL
      ccn_cnt = (ccn_cnt+ 1), stat = alterlist(reply->urls[d.seq].ccn,ccn_cnt), reply->urls[d.seq].
      ccn[ccn_cnt].br_ccn_id = r.parent_entity_id,
      reply->urls[d.seq].ccn[ccn_cnt].ccn_name = c.ccn_name, reply->urls[d.seq].ccn[ccn_cnt].
      invitation_provided_event_code.event_cd = inv_prov_cd.code_value, reply->urls[d.seq].ccn[
      ccn_cnt].invitation_provided_event_code.display = inv_prov_cd.display,
      reply->urls[d.seq].ccn[ccn_cnt].patient_declined_event_code.event_cd = pat_decl_cd.code_value,
      reply->urls[d.seq].ccn[ccn_cnt].patient_declined_event_code.display = pat_decl_cd.display
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to get URL CCN Reltn")
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(request_size)),
     br_portal_url_svc_entity_r r,
     code_value cv
    PLAN (d)
     JOIN (r
     WHERE (r.br_portal_url_id=request->urls[d.seq].br_portal_url_id)
      AND trim(cnvtupper(r.parent_entity_name))="CODE_VALUE"
      AND r.active_ind=1
      AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (cv
     WHERE cv.code_value=r.parent_entity_id)
    ORDER BY d.seq, r.br_portal_url_id, r.br_portal_url_svc_entity_r_id,
     cv.code_value
    DETAIL
     IF (cv.code_set=alias_pool_codeset)
      reply->urls[d.seq].alias_pool.code_value = cv.code_value, reply->urls[d.seq].alias_pool.display
       = cv.display, reply->urls[d.seq].alias_pool.meaning = cv.cdf_meaning
     ELSE
      reply->urls[d.seq].alias_type.code_value = cv.code_value, reply->urls[d.seq].alias_type.display
       = cv.display, reply->urls[d.seq].alias_type.meaning = cv.cdf_meaning
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get URL alias pool/type reltn.")
   CALL bedlogmessage("getPortalURLReltn","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
