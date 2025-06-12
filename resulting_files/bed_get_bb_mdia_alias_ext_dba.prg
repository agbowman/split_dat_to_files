CREATE PROGRAM bed_get_bb_mdia_alias_ext:dba
 FREE SET reply
 RECORD reply(
   1 models[*]
     2 code_value = f8
     2 alias_mode[*]
       3 code_value = f8
       3 mean = vc
       3 display = vc
       3 description = vc
       3 ignore_ind = i2
       3 alias[*]
         4 alias = vc
       3 proposed_alias = vc
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
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET rcnt = size(request->models,5)
 SET stat = alterlist(reply->models,rcnt)
 FOR (x = 1 TO rcnt)
   SET reply->models[x].code_value = request->models[x].code_value
 ENDFOR
 FREE SET alias_mode
 RECORD alias_mode(
   1 qual[*]
     2 code_value = f8
     2 mean = vc
     2 display = vc
     2 description = vc
 )
 SET acnt = 0
 IF ((request->code_set=14003))
  CALL get_dta_by_activity_type(null)
 ELSE
  CALL get_codevalues(request->code_set)
 ENDIF
 FOR (x = 1 TO rcnt)
   SET stat = alterlist(reply->models[x].alias_mode,acnt)
   FOR (y = 1 TO acnt)
     SET reply->models[x].alias_mode[y].code_value = alias_mode->qual[y].code_value
     SET reply->models[x].alias_mode[y].mean = alias_mode->qual[y].mean
     SET reply->models[x].alias_mode[y].display = alias_mode->qual[y].display
     SET reply->models[x].alias_mode[y].description = alias_mode->qual[y].description
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     code_value_alias c
    PLAN (d)
     JOIN (c
     WHERE (c.code_value=reply->models[x].alias_mode[d.seq].code_value)
      AND (c.contributor_source_cd=reply->models[x].code_value))
    ORDER BY d.seq
    HEAD d.seq
     scnt = 0
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(reply->models[x].alias_mode[d.seq].alias,scnt), reply->
     models[x].alias_mode[d.seq].alias[scnt].alias = c.alias
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get Code Value Alias")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     br_name_value b
    PLAN (d)
     JOIN (b
     WHERE b.br_nv_key1="BB_ALIAS_IGNORE"
      AND b.br_name=cnvtstring(reply->models[x].code_value)
      AND b.br_value=cnvtstring(reply->models[x].alias_mode[d.seq].code_value))
    ORDER BY d.seq
    HEAD d.seq
     reply->models[x].alias_mode[d.seq].ignore_ind = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get Ignore Ind")
 ENDFOR
 DECLARE get_codevalues(code_set=i4) = null
 SUBROUTINE get_codevalues(code_set)
   CALL bedlogmessage("Get_CodeValues","Entering ...")
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=code_set
      AND c.active_ind=1)
    DETAIL
     acnt = (acnt+ 1), stat = alterlist(alias_mode->qual,acnt), alias_mode->qual[acnt].code_value = c
     .code_value,
     alias_mode->qual[acnt].mean = c.cdf_meaning, alias_mode->qual[acnt].display = c.display,
     alias_mode->qual[acnt].description = c.description
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get Code Values")
   IF (acnt=0)
    GO TO exit_script
   ENDIF
   CALL bedlogmessage("Get_CodeValues","Exiting ...")
 END ;Subroutine
 DECLARE get_dta_by_activity_type(null) = null
 SUBROUTINE get_dta_by_activity_type(null)
   CALL bedlogmessage("GET_DTA_BY_ACTIVITY_TYPE","Entering ...")
   DECLARE dbloodbankactivitytypecd = f8 WITH noconstant(0.0)
   DECLARE dbloodbankproductactivitytypecd = f8 WITH noconstant(0.0)
   DECLARE sbb_activity_type = c12 WITH constant("BB")
   DECLARE sbbproduct_activity_type = c12 WITH constant("BB PRODUCT")
   SET dbloodbankactivitytypecd = uar_get_code_by("MEANING",106,nullterm(sbb_activity_type))
   SET dbloodbankproductactivitytypecd = uar_get_code_by("MEANING",106,nullterm(
     sbbproduct_activity_type))
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE dta.activity_type_cd IN (dbloodbankactivitytypecd, dbloodbankproductactivitytypecd)
      AND dta.active_ind=1)
    DETAIL
     acnt = (acnt+ 1), stat = alterlist(alias_mode->qual,acnt), alias_mode->qual[acnt].code_value =
     dta.task_assay_cd,
     alias_mode->qual[acnt].mean = uar_get_code_meaning(dta.task_assay_cd), alias_mode->qual[acnt].
     display = uar_get_code_display(dta.task_assay_cd), alias_mode->qual[acnt].description =
     uar_get_code_description(dta.task_assay_cd)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get Task Assays")
   CALL bedlogmessage("GET_DTA_BY_ACTIVITY_TYPE","Exiting ...")
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL bedexitscript(0)
 CALL echorecord(reply)
END GO
