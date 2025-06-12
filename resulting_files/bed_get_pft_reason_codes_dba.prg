CREATE PROGRAM bed_get_pft_reason_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reason_code_categories[*]
      2 code_set = i4
      2 reason_codes[*]
        3 code_value = f8
        3 display = vc
        3 meaning = vc
        3 reason_type
          4 code_value = f8
          4 display = vc
          4 meaning = vc
        3 reason_group
          4 code_value = f8
          4 display = vc
          4 meaning = vc
        3 alias = vc
        3 post_primary_ind = i2
        3 post_secondary_ind = i2
        3 post_tertiary_ind = i2
        3 direct_to_non_ar = i2
        3 reverse_expected = i2
        3 x12b = vc
        3 curr_users_logical_domain_ind = i2
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
 DECLARE claim_codeset = f8 WITH protect, constant(26398.0)
 DECLARE remit_codeset = f8 WITH protect, constant(26399.0)
 DECLARE denied_codeset = f8 WITH protect, constant(24730.0)
 DECLARE cont_source_codeset = i4 WITH protect, constant(73)
 DECLARE x12_claim_meaning = vc WITH protect, constant("X12CLAIM")
 DECLARE logdomainid = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE getreasoncodes(dummyvar=i2) = i2
 CALL getreasoncodes(0)
#exit_script
 CALL bederrorcheck("Descriptive error message not provided.")
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  IF (commitind)
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
 SUBROUTINE getreasoncodes(dummyvar)
   DECLARE catcnt = i4 WITH protect, noconstant(0)
   DECLARE codecnt = i4 WITH protect, noconstant(0)
   DECLARE ppi = i2 WITH protect, noconstant(0)
   DECLARE psi = i2 WITH protect, noconstant(0)
   DECLARE pti = i2 WITH protect, noconstant(0)
   DECLARE data_partition_ind = i2 WITH protect, noconstant(0)
   DECLARE postmethod = i2 WITH protect, noconstant(- (1))
   DECLARE al1 = vc WITH protect
   DECLARE al2 = vc WITH protect
   DECLARE denialparse = vc WITH protect
   DECLARE x12claimcd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value cv,
     pft_denial_code_ref pdcr,
     code_value cv2,
     code_value cv3,
     pft_alias pa
    PLAN (cv
     WHERE ((cv.code_set=claim_codeset) OR (((cv.code_set=remit_codeset) OR (cv.code_set=
     denied_codeset)) ))
      AND cv.active_ind=1)
     JOIN (pa
     WHERE pa.code_value=outerjoin(cv.code_value)
      AND pa.parent_entity_name=outerjoin("DEFAULT"))
     JOIN (pdcr
     WHERE pdcr.denial_cd=outerjoin(cv.code_value)
      AND pdcr.logical_domain_id=outerjoin(logdomainid))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(pdcr.denial_group_cd))
     JOIN (cv3
     WHERE cv3.code_value=outerjoin(pdcr.denial_type_cd))
    ORDER BY cv.code_set, cv.display
    HEAD cv.code_set
     catcnt = (catcnt+ 1), stat = alterlist(reply->reason_code_categories,catcnt), reply->
     reason_code_categories[catcnt].code_set = cv.code_set,
     codecnt = 0
    HEAD cv.code_value
     codecnt = (codecnt+ 1), al1 = " ", al2 = " ",
     al1 = pdcr.x12_code, al2 = pa.alias
    DETAIL
     stat = alterlist(reply->reason_code_categories[catcnt].reason_codes,codecnt), reply->
     reason_code_categories[catcnt].reason_codes[codecnt].code_value = cv.code_value, reply->
     reason_code_categories[catcnt].reason_codes[codecnt].display = cv.display,
     reply->reason_code_categories[catcnt].reason_codes[codecnt].meaning = cv.cdf_meaning
     IF (al1 > " ")
      reply->reason_code_categories[catcnt].reason_codes[codecnt].alias = al1
     ELSE
      reply->reason_code_categories[catcnt].reason_codes[codecnt].alias = al2
     ENDIF
     postmethod = pdcr.post_no_post_method_flag
     CASE (postmethod)
      OF 0:
       ppi = 1,psi = 1,pti = 1
      OF 1:
       ppi = 0,psi = 0,pti = 0
      OF 2:
       ppi = 1,psi = 0,pti = 1
      OF 3:
       ppi = 1,psi = 0,pti = 0
      OF 4:
       ppi = 1,psi = 1,pti = 0
      OF 5:
       ppi = 0,psi = 0,pti = 1
      OF 6:
       ppi = 0,psi = 1,pti = 0
      OF 7:
       ppi = 0,psi = 1,pti = 1
      ELSE
       ppi = 0,psi = 0,pti = 0
     ENDCASE
     IF (pdcr.pft_denial_code_ref_id > 0.0)
      reply->reason_code_categories[catcnt].reason_codes[codecnt].curr_users_logical_domain_ind = 1
     ELSE
      reply->reason_code_categories[catcnt].reason_codes[codecnt].curr_users_logical_domain_ind = 0
     ENDIF
     reply->reason_code_categories[catcnt].reason_codes[codecnt].post_primary_ind = ppi, reply->
     reason_code_categories[catcnt].reason_codes[codecnt].post_secondary_ind = psi, reply->
     reason_code_categories[catcnt].reason_codes[codecnt].post_tertiary_ind = pti,
     reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.code_value = cv2
     .code_value, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.display =
     cv2.display, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.meaning =
     cv2.cdf_meaning,
     reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.code_value = cv3
     .code_value, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.display =
     cv3.display, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.meaning =
     cv3.cdf_meaning,
     reply->reason_code_categories[catcnt].reason_codes[codecnt].direct_to_non_ar = pdcr
     .direct_to_non_ar_ind, reply->reason_code_categories[catcnt].reason_codes[codecnt].
     reverse_expected = pdcr.reverse_expected_ind, reply->reason_code_categories[catcnt].
     reason_codes[codecnt].x12b = pdcr.x12_code
    WITH nocounter
   ;end select
   CALL bederrorcheck("retrieve reason code")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(reply->reason_code_categories,5)),
     (dummyt d2  WITH seq = 1),
     code_value cv,
     code_value_extension cve1
    PLAN (cv
     WHERE ((cv.code_set=claim_codeset) OR (((cv.code_set=remit_codeset) OR (cv.code_set=
     denied_codeset)) ))
      AND cv.active_ind=1)
     JOIN (cve1
     WHERE cve1.code_value=cv.code_value
      AND cve1.field_name="X12B")
     JOIN (d1
     WHERE maxrec(d2,size(reply->reason_code_categories[d1.seq].reason_codes,5))
      AND (reply->reason_code_categories[d1.seq].code_set=cv.code_set))
     JOIN (d2
     WHERE (reply->reason_code_categories[d1.seq].reason_codes[d2.seq].code_value=cv.code_value))
    DETAIL
     IF (size(trim(reply->reason_code_categories[d1.seq].reason_codes[d2.seq].alias,3),1)=0
      AND size(trim(cve1.field_value,3),1) > 0)
      reply->reason_code_categories[d1.seq].reason_codes[d2.seq].alias = cve1.field_value
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("retrieve reason code")
   SET stat = uar_get_meaning_by_codeset(cont_source_codeset,x12_claim_meaning,1,x12claimcd)
   IF (x12claimcd > 0.0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(reply->reason_code_categories,5)),
      (dummyt d2  WITH seq = 1),
      code_value cv,
      code_value_alias cva
     PLAN (cv
      WHERE cv.code_set=denied_codeset
       AND cv.active_ind=1)
      JOIN (cva
      WHERE cva.code_value=cv.code_value
       AND cva.contributor_source_cd=x12claimcd)
      JOIN (d1
      WHERE maxrec(d2,size(reply->reason_code_categories[d1.seq].reason_codes,5)) > 0
       AND (reply->reason_code_categories[d1.seq].code_set=cv.code_set))
      JOIN (d2
      WHERE (reply->reason_code_categories[d1.seq].reason_codes[d2.seq].code_value=cv.code_value))
     DETAIL
      IF (size(trim(reply->reason_code_categories[d1.seq].reason_codes[d2.seq].alias,3),1)=0
       AND size(trim(cva.alias,3),1) > 0)
       reply->reason_code_categories[d1.seq].reason_codes[d2.seq].alias = cva.alias
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("retrieve reason code")
   ENDIF
 END ;Subroutine
END GO
