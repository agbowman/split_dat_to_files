CREATE PROGRAM bed_get_term_con_fam_reltns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 concept_identifier = vc
    1 concept_source_cd = f8
    1 concept_source_mean = vc
    1 concept_name = vc
    1 cki = vc
    1 concept_preferred_term = vc
    1 concept_preferred_term_id = f8
    1 active_ind = i2
    1 parent[*]
      2 cki = vc
      2 preferred_term = vc
      2 preferred_term_id = f8
      2 active_ind = i2
    1 child[*]
      2 cki = vc
      2 preferred_term = vc
      2 preferred_term_id = f8
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET parentrecord
 RECORD parentrecord(
   1 item[*]
     2 cki = vc
     2 active_ind = i2
 )
 FREE SET childrecord
 RECORD childrecord(
   1 item[*]
     2 cki = vc
     2 active_ind = i2
     2 relationship_type = i2
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
 DECLARE parent = i2 WITH constant(1)
 DECLARE child = i2 WITH constant(2)
 DECLARE cki = vc WITH protect, noconstant("")
 DECLARE litemcount = i4
 DECLARE ltmpcount = i4
 DECLARE ltempcnt = i4
 DECLARE lcnt = i4
 DECLARE sisacki = vc
 DECLARE idx1 = i4 WITH noconstant(0), public
 DECLARE idx2 = i4 WITH noconstant(0), public
 DECLARE idx3 = i4 WITH noconstant(0), public
 SET litemcount = 0
 SET ltmpcount = 0
 SET ltempcnt = 0
 SET sisacki = "SNOMED!116680003"
 DECLARE populatecki(dummyvar=i2) = null
 DECLARE populateconceptinformation(dummyvar=i2) = null
 DECLARE populateparentconcepts(dummyvar=i2) = null
 DECLARE populatechildconcepts(dummyvar=i2) = null
 CALL populatecki(0)
 CALL populateconceptinformation(0)
 CALL populateparentconcepts(0)
 CALL populatechildconcepts(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE populatecki(dummyvar)
  IF ((request->cki != "")
   AND (request->cki != " "))
   SET cki = request->cki
  ELSE
   SET cki = trim(concat(trim(request->concept_source_mean),"!",trim(request->concept_identifier)))
  ENDIF
  CALL bederrorcheck("Error 001: Problems populating the CKI for term")
 END ;Subroutine
 SUBROUTINE populateconceptinformation(dummyvar)
  SELECT INTO "nl:"
   FROM cmt_concept c,
    nomenclature n
   PLAN (c
    WHERE c.concept_cki=cki)
    JOIN (n
    WHERE n.concept_cki=c.concept_cki
     AND n.active_ind=1
     AND n.primary_vterm_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->concept_identifier = c.concept_identifier, reply->concept_source_mean = c
    .concept_source_mean, reply->concept_source_cd = uar_get_code_by("MEANING",12100,reply->
     concept_source_mean),
    reply->concept_name = c.concept_name, reply->cki = cki, reply->concept_preferred_term = n
    .source_string,
    reply->concept_preferred_term_id = n.nomenclature_id, reply->active_ind = c.active_ind
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 002: Problems populating the concept information for term")
 END ;Subroutine
 SUBROUTINE populateparentconcepts(dummyvar)
   SELECT INTO "nl:"
    FROM cmt_concept_reltn ccr
    WHERE ccr.concept_cki1=cki
     AND cnvtupper(ccr.relation_cki)=cnvtupper(sisacki)
     AND ccr.active_ind=1
     AND ccr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ccr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    ORDER BY ccr.concept_cki2
    DETAIL
     litemcount = (litemcount+ 1)
     IF (mod(litemcount,10)=1)
      stat = alterlist(parentrecord->item,(litemcount+ 10))
     ENDIF
     parentrecord->item[litemcount].cki = ccr.concept_cki2, parentrecord->item[litemcount].active_ind
      = ccr.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 003: Problems populating the parent concepts for term's concept")
   SET stat = alterlist(parentrecord->item,litemcount)
   SET stat = alterlist(reply->parent,litemcount)
   IF (litemcount > 0)
    SELECT INTO "nl:"
     FROM nomenclature n
     PLAN (n
      WHERE expand(idx1,1,litemcount,n.concept_cki,parentrecord->item[idx1].cki)
       AND n.active_ind=1
       AND n.primary_vterm_ind=1
       AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY n.concept_cki
     DETAIL
      lcnt = (lcnt+ 1), reply->parent[lcnt].cki = parentrecord->item[lcnt].cki, reply->parent[lcnt].
      preferred_term = n.source_string,
      reply->parent[lcnt].preferred_term_id = n.nomenclature_id, reply->parent[lcnt].active_ind =
      parentrecord->item[lcnt].active_ind
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck(
    "Error 004: Problems populating the parent preferred display and id for term's concept")
 END ;Subroutine
 SUBROUTINE populatechildconcepts(dummyvar)
   SELECT INTO "nl:"
    cnt2 = count(ccr2.concept_cki1)
    FROM cmt_concept_reltn ccr,
     cmt_concept_reltn ccr2,
     (dummyt d  WITH seq = 1)
    PLAN (ccr
     WHERE ccr.concept_cki2=cki
      AND cnvtupper(ccr.relation_cki)=cnvtupper(sisacki)
      AND ccr.active_ind=1
      AND ccr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ccr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (ccr2
     WHERE outerjoin(ccr.concept_cki1)=ccr2.concept_cki2)
     JOIN (d
     WHERE outerjoin(ccr.relation_cki)=ccr2.relation_cki)
    GROUP BY ccr.concept_cki1
    ORDER BY ccr.concept_cki1
    DETAIL
     ltmpcount = (ltmpcount+ 1)
     IF (mod(ltmpcount,10)=1)
      stat = alterlist(childrecord->item,(ltmpcount+ 10))
     ENDIF
     childrecord->item[ltmpcount].cki = ccr.concept_cki1, childrecord->item[ltmpcount].active_ind =
     ccr.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error 005: Problems populating the child preferred display and id for term's concept")
   SET stat = alterlist(childrecord->item,ltmpcount)
   SET stat = alterlist(reply->child,ltmpcount)
   IF (ltmpcount > 0)
    SELECT INTO "nl:"
     FROM nomenclature n
     PLAN (n
      WHERE expand(idx2,1,ltmpcount,n.concept_cki,childrecord->item[idx2].cki)
       AND n.primary_vterm_ind=1
       AND n.active_ind=1
       AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY n.concept_cki
     DETAIL
      ltempcnt = (ltempcnt+ 1), reply->child[ltempcnt].cki = childrecord->item[ltempcnt].cki, reply->
      child[ltempcnt].preferred_term = n.source_string,
      reply->child[ltempcnt].preferred_term_id = n.nomenclature_id
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck(
    "Error 006: Problems populating the child preferred display and id for term's concept")
 END ;Subroutine
END GO
