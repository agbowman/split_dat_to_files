CREATE PROGRAM bed_get_qch_prsnl:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qch_prsnl[*]
      2 full_name_formatted = vc
      2 active_ind = i2
      2 effective_dt_tm = dq8
      2 user_name = vc
      2 person_id = f8
      2 dashboard_ind = i2
      2 ec_portal_ind = i2
      2 mips_display_ind = i2
      2 qrda_export_ind = i2
      2 eh_portal_ind = i2
    1 qch_prsnl_row_ind = i2
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
 DECLARE qch_prsnl_group_id = f8 WITH protect
 DECLARE log_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 IF ( NOT (validate(cs19189_group_class_cd)))
  DECLARE cs19189_group_class_cd = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=19189
    AND cv.cdf_meaning="QCH"
   DETAIL
    cs19189_group_class_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR001: Error while retrieving QCH code value")
 ENDIF
 IF ( NOT (validate(cs357_group_type_cd)))
  DECLARE cs357_group_type_cd = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="QCHUSER"
   DETAIL
    cs357_group_type_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR002: Error while retrieving QCH User code value")
 ENDIF
 CALL bedbeginscript(0)
 DECLARE populateqchprsnlgroupid(dummyvar=i2) = null
 DECLARE populateqchpersonnelreply(dummyvar=i2) = null
 CALL populateqchprsnlgroupid(0)
 CALL populateqchpersonnelreply(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE populateqchprsnlgroupid(dummyvar)
   SELECT INTO "nl:"
    FROM prsnl_group pg
    WHERE pg.prsnl_group_class_cd=cs19189_group_class_cd
     AND pg.prsnl_group_type_cd=cs357_group_type_cd
     AND pg.active_ind=1
    DETAIL
     qch_prsnl_group_id = pg.prsnl_group_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET reply->qch_prsnl_row_ind = 1
   ENDIF
   CALL bederrorcheck("ERROR003: Error while retrieving PRSNL_GROUP_ID from PRSNL_GROUP table")
 END ;Subroutine
 SUBROUTINE populateqchpersonnelreply(dummyvar)
   SET reply_size = 0
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl p,
     qmd_portal_permission qpp
    PLAN (pgr
     WHERE pgr.prsnl_group_id=qch_prsnl_group_id
      AND pgr.active_ind=1)
     JOIN (p
     WHERE p.person_id=pgr.person_id
      AND p.logical_domain_id=log_domain_id)
     JOIN (qpp
     WHERE qpp.prsnl_group_reltn_id=outerjoin(pgr.prsnl_group_reltn_id))
    DETAIL
     reply_size = (reply_size+ 1), stat = alterlist(reply->qch_prsnl,reply_size), reply->qch_prsnl[
     reply_size].full_name_formatted = p.name_full_formatted,
     reply->qch_prsnl[reply_size].active_ind = p.active_ind, reply->qch_prsnl[reply_size].
     effective_dt_tm = p.end_effective_dt_tm, reply->qch_prsnl[reply_size].user_name = p.username,
     reply->qch_prsnl[reply_size].person_id = p.person_id, reply->qch_prsnl[reply_size].dashboard_ind
      = qpp.dashboard_ind, reply->qch_prsnl[reply_size].eh_portal_ind = qpp.client_portal_display_ind,
     reply->qch_prsnl[reply_size].mips_display_ind = qpp.mips_display_ind, reply->qch_prsnl[
     reply_size].qrda_export_ind = qpp.qrda_export_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR004: Error while retrieving effective QCH personnel")
 END ;Subroutine
END GO
