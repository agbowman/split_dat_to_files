CREATE PROGRAM bed_get_inbound_alias:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 code_values[*]
      2 code_value = f8
      2 display = vc
      2 mean = vc
      2 description = vc
      2 active_ind = i2
      2 inbound_aliases[*]
        3 alias = vc
      2 outbound_alias = vc
      2 ignore_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
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
 CALL bedbeginscript(0)
 DECLARE cv_parse = vc
 SET cv_parse = "cv.code_set = request->code_set"
 IF ((request->code_set=72))
  SET ecnt = size(request->event_codes,5)
  IF (ecnt > 0)
   DECLARE event_code_list = vc
   SET event_code_list = " and cv.code_value in ("
   FOR (e = 1 TO ecnt)
     IF (e=ecnt)
      SET event_code_list = build(event_code_list,request->event_codes[e].code_value,")")
     ELSE
      SET event_code_list = build(event_code_list,request->event_codes[e].code_value,",")
     ENDIF
   ENDFOR
   SET cv_parse = concat(cv_parse,event_code_list)
  ENDIF
 ENDIF
 DECLARE oc_parse = vc
 SET oc_parse = "oc.catalog_cd = cv.code_value"
 IF (validate(request->catalog_type_code_value))
  IF ((request->catalog_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.catalog_type_cd = request->catalog_type_code_value")
  ENDIF
 ENDIF
 IF (validate(request->activity_type_code_value))
  IF ((request->activity_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.activity_type_cd = request->activity_type_code_value")
  ENDIF
 ENDIF
 IF (validate(request->subactivity_type_code_value))
  IF ((request->subactivity_type_code_value > 0))
   SET oc_parse = concat(oc_parse,
    " and oc.activity_subtype_cd = request->subactivity_type_code_value")
  ENDIF
 ENDIF
 SET ccnt = 0
 IF ((request->alias_config_params_ind=1))
  SELECT
   IF ((request->code_set=200))
    FROM code_value cv,
     order_catalog oc,
     br_name_value bnv,
     code_value_outbound cvo,
     code_value_alias cva
    PLAN (cv
     WHERE parser(cv_parse))
     JOIN (oc
     WHERE parser(oc_parse))
     JOIN (bnv
     WHERE bnv.br_nv_key1=outerjoin("ALIAS_IGNORE_CV")
      AND bnv.br_name=outerjoin(cnvtstring(request->contributor_system_code_value))
      AND bnv.br_value=outerjoin(cnvtstring(cv.code_value)))
     JOIN (cvo
     WHERE cvo.code_value=outerjoin(cv.code_value)
      AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cva
     WHERE cva.code_value=outerjoin(cv.code_value)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    ORDER BY cv.code_value
   ELSE
   ENDIF
   INTO "NL:"
   FROM code_value cv,
    br_name_value bnv,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE parser(cv_parse))
    JOIN (bnv
    WHERE bnv.br_nv_key1=outerjoin("ALIAS_IGNORE_CV")
     AND bnv.br_name=outerjoin(cnvtstring(request->contributor_system_code_value))
     AND bnv.br_value=outerjoin(cnvtstring(cv.code_value)))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value)
     AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    IF (cva.alias > " ")
     ccnt = (ccnt+ 1), stat = alterlist(reply->code_values,ccnt), reply->code_values[ccnt].code_value
      = cv.code_value,
     reply->code_values[ccnt].display = cv.display, reply->code_values[ccnt].mean = cv.cdf_meaning,
     reply->code_values[ccnt].description = cv.description,
     reply->code_values[ccnt].active_ind = cv.active_ind
     IF (bnv.br_name_value_id > 0)
      reply->code_values[ccnt].ignore_ind = 1
     ENDIF
     IF (cvo.code_value > 0)
      IF (cvo.alias > " ")
       reply->code_values[ccnt].outbound_alias = cvo.alias
      ELSE
       reply->code_values[ccnt].outbound_alias = "<space>"
      ENDIF
     ENDIF
     reply->code_values[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->code_values[ccnt
     ].end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
    ENDIF
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->code_values[ccnt].inbound_aliases,icnt), reply->
     code_values[ccnt].inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 001: Failed to find any aliases with ignore flag")
 ELSE
  SELECT
   IF ((request->code_set=200))
    FROM code_value cv,
     order_catalog oc,
     code_value_outbound cvo,
     code_value_alias cva
    PLAN (cv
     WHERE parser(cv_parse))
     JOIN (oc
     WHERE parser(oc_parse))
     JOIN (cvo
     WHERE cvo.code_value=outerjoin(cv.code_value)
      AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cva
     WHERE cva.code_value=outerjoin(cv.code_value)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    ORDER BY cv.code_value
   ELSE
   ENDIF
   INTO "NL:"
   FROM code_value cv,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE parser(cv_parse))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value)
     AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    IF (cva.alias > " ")
     ccnt = (ccnt+ 1), stat = alterlist(reply->code_values,ccnt), reply->code_values[ccnt].code_value
      = cv.code_value,
     reply->code_values[ccnt].display = cv.display, reply->code_values[ccnt].description = cv
     .description, reply->code_values[ccnt].active_ind = cv.active_ind
     IF (cvo.code_value > 0)
      IF (cvo.alias > " ")
       reply->code_values[ccnt].outbound_alias = cvo.alias
      ELSE
       reply->code_values[ccnt].outbound_alias = "<space>"
      ENDIF
     ENDIF
     reply->code_values[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->code_values[ccnt
     ].end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
    ENDIF
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->code_values[ccnt].inbound_aliases,icnt), reply->
     code_values[ccnt].inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 002: Failed to find any aliases without ignore flag")
 ENDIF
#exit_script
 CALL bedexitscript(0)
 CALL echorecord(reply)
END GO
