CREATE PROGRAM bed_ens_oe_filter_values:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET historyrows
 RECORD historyrows(
   1 historyrow[*]
     2 entity1_id = f8
     2 entity1_name = vc
     2 entity1_display = vc
     2 entity2_id = f8
     2 entity2_name = vc
     2 entity2_display = vc
     2 entity_reltn_mean = vc
 )
 DECLARE populatehistoryrows(entity1_id=f8,entity_reltn_mean=vc) = i2
 DECLARE insertnewrows(entity1_id=f8,entity2_id=f8,entity_reltn_mean=vc,entity3_id=f8) = i2
 DECLARE inserthistoryrows(entity3_id=f8) = i2
 DECLARE deleterows(entity1_id=f8,entity2_id=f8,entity_reltn_mean=vc,entity3_id=f8) = i2
 DECLARE logdebuginfo(desc=vc) = i2
 DECLARE deleteoldrowswithnoentitythreeid(entity1_id=f8,entity2_id=f8,entity_reltn_mean=vc) = i2
 DECLARE action_flag_value = i4 WITH protect, noconstant(0)
 DECLARE filter_display = vc WITH protect, noconstant("")
 DECLARE value_display = vc WITH protect, noconstant("")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE failed = vc WITH protect, noconstant("")
 DECLARE entity_reltn_mean = vc WITH protect, noconstant("")
 DECLARE fcnt = i4 WITH protect
 DECLARE vcnt = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE y = i4 WITH protect
 DECLARE new_dcp_id = f8 WITH protect
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET fcnt = 0
 SET fcnt = size(request->filters,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 FOR (f = 1 TO fcnt)
   SET vcnt = 0
   SET vcnt = size(request->filters[f].values,5)
   SET action_flag_value = request->filters[f].values[1].action_flag
   FOR (v = 1 TO vcnt)
     IF ((action_flag_value != request->filters[f].values[v].action_flag))
      SET action_flag_value = 2
     ENDIF
   ENDFOR
   SET entity_reltn_mean = fillstring(12," ")
   IF ((request->filters[f].filter_flag=1))
    SET entity_reltn_mean = concat("CT/",cnvtstring(request->filters[f].code_set))
   ELSEIF ((request->filters[f].filter_flag=2))
    SET entity_reltn_mean = concat("AT/",cnvtstring(request->filters[f].code_set))
   ELSEIF ((request->filters[f].filter_flag=3))
    SET entity_reltn_mean = concat("ORC/",cnvtstring(request->filters[f].code_set))
   ELSEIF ((request->filters[f].filter_flag=4))
    SET entity_reltn_mean = concat("OCS/",cnvtstring(request->filters[f].code_set))
   ENDIF
   IF (((action_flag_value=1) OR (action_flag_value=2))
    AND (request->filter_type_indicator != 1))
    CALL populatehistoryrows(request->filters[f].filter_code_value,entity_reltn_mean)
    CALL inserthistoryrows(request->filters[f].entity3_id)
   ENDIF
   FOR (v = 1 TO vcnt)
     IF (action_flag_value=1)
      CALL insertnewrows(request->filters[f].filter_code_value,request->filters[f].values[v].
       code_value,entity_reltn_mean,request->filters[f].entity3_id)
     ELSEIF (action_flag_value=2)
      IF ((request->filters[f].values[v].action_flag=0))
       IF ((request->filter_type_indicator != 1))
        CALL deleteoldrowswithnoentitythreeid(request->filters[f].filter_code_value,request->filters[
         f].values[v].code_value,entity_reltn_mean)
       ENDIF
      ELSEIF ((request->filters[f].values[v].action_flag=1))
       CALL insertnewrows(request->filters[f].filter_code_value,request->filters[f].values[v].
        code_value,entity_reltn_mean,request->filters[f].entity3_id)
      ELSEIF ((request->filters[f].values[v].action_flag=3))
       CALL deleterows(request->filters[f].filter_code_value,request->filters[f].values[v].code_value,
        entity_reltn_mean,request->filters[f].entity3_id)
       CALL deleteoldrowswithnoentitythreeid(request->filters[f].filter_code_value,request->filters[f
        ].values[v].code_value,entity_reltn_mean)
      ENDIF
     ELSEIF (action_flag_value=3)
      CALL deleterows(request->filters[f].filter_code_value,request->filters[f].values[v].code_value,
       entity_reltn_mean,request->filters[f].entity3_id)
      CALL deleteoldrowswithnoentitythreeid(request->filters[f].filter_code_value,request->filters[f]
       .values[v].code_value,entity_reltn_mean)
     ELSEIF (action_flag_value=0)
      IF ((request->filter_type_indicator != 1))
       CALL deleteoldrowswithnoentitythreeid(request->filters[f].filter_code_value,request->filters[f
        ].values[v].code_value,entity_reltn_mean)
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE populatehistoryrows(entity1_id,entity_reltn_mean)
   CALL logdebuginfo(build2("entity1_id = ",entity1_id))
   CALL logdebuginfo(build2("entity_reltn_mean = ",entity_reltn_mean))
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dcp_entity_reltn der
    WHERE der.entity1_id=entity1_id
     AND der.entity_reltn_mean=entity_reltn_mean
     AND ((nullind(der.entity3_id)=1) OR (der.entity3_id=0.0))
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(historyrows->historyrow,cnt), historyrows->historyrow[cnt].
     entity1_display = der.entity1_display,
     historyrows->historyrow[cnt].entity1_id = der.entity1_id, historyrows->historyrow[cnt].
     entity1_name = der.entity1_name, historyrows->historyrow[cnt].entity2_display = der
     .entity2_display,
     historyrows->historyrow[cnt].entity2_id = der.entity2_id, historyrows->historyrow[cnt].
     entity2_name = der.entity2_name, historyrows->historyrow[cnt].entity_reltn_mean = der
     .entity_reltn_mean
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE inserthistoryrows(entity3_id)
   CALL logdebuginfo(build2("historyRows = ",historyrows))
   DECLARE oe_field_display = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM order_entry_fields oef,
     code_value cv
    PLAN (oef)
     JOIN (cv
     WHERE cv.code_value=oef.oe_field_id
      AND oef.oe_field_id=entity3_id)
    DETAIL
     oe_field_display = cv.display
    WITH nocounter
   ;end select
   CALL logdebuginfo(build2("oe_field_display = ",oe_field_display))
   FREE SET dcp
   RECORD dcp(
     1 dcp_id[*]
       2 id = f8
   )
   SET cnt = size(historyrows->historyrow,5)
   SET stat = alterlist(dcp->dcp_id,cnt)
   IF (cnt > 0)
    FOR (y = 1 TO cnt)
      SET new_dcp_id = 0.0
      SELECT INTO "NL:"
       j = seq(carenet_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_dcp_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET dcp->dcp_id[y].id = new_dcp_id
    ENDFOR
    INSERT  FROM dcp_entity_reltn der,
      (dummyt d  WITH seq = cnt)
     SET der.dcp_entity_reltn_id = dcp->dcp_id[d.seq].id, der.entity_reltn_mean = historyrows->
      historyrow[d.seq].entity_reltn_mean, der.entity1_id = historyrows->historyrow[d.seq].entity1_id,
      der.entity1_name = historyrows->historyrow[d.seq].entity1_name, der.entity1_display =
      historyrows->historyrow[d.seq].entity1_display, der.entity2_id = historyrows->historyrow[d.seq]
      .entity2_id,
      der.entity2_display = historyrows->historyrow[d.seq].entity2_display, der.entity2_name =
      historyrows->historyrow[d.seq].entity2_name, der.entity3_id = entity3_id,
      der.entity3_display = oe_field_display, der.entity3_name = "ORDER_ENTRY_FIELDS", der
      .rank_sequence = 0,
      der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), der
      .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
      der.updt_applctx = reqinfo->updt_applctx, der.updt_cnt = 0, der.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      der.updt_id = reqinfo->updt_id, der.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (der)
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE insertnewrows(entity1_id,entity2_id,entity_reltn_mean,entity3_id)
   DECLARE oe_field_display = vc WITH protect, noconstant("")
   DECLARE entity3_name = vc WITH protect, noconstant("")
   IF ((request->filter_type_indicator != 1))
    SET entity3_name = "ORDER_ENTRY_FIELDS"
   ELSE
    SET entity3_name = ""
   ENDIF
   SELECT INTO "nl:"
    FROM order_entry_fields oef,
     code_value cv
    PLAN (oef)
     JOIN (cv
     WHERE cv.code_value=oef.oe_field_id
      AND oef.oe_field_id=entity3_id)
    DETAIL
     oe_field_display = cv.display
    WITH nocounter
   ;end select
   SET filter_display = fillstring(40," ")
   SET value_display = fillstring(40," ")
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE ((cv.code_value=entity1_id) OR (cv.code_value=entity2_id))
    DETAIL
     IF (cv.code_value=entity1_id)
      filter_display = cv.display
     ELSEIF (cv.code_value=entity2_id)
      value_display = cv.display
     ENDIF
    WITH nocounter
   ;end select
   INSERT  FROM dcp_entity_reltn der
    SET der.dcp_entity_reltn_id = seq(carenet_seq,nextval), der.entity_reltn_mean = entity_reltn_mean,
     der.entity1_id = entity1_id,
     der.entity1_display = filter_display, der.entity1_name =
     IF ((request->filters[f].filter_flag=3)) "ORDER_CATALOG"
     ELSEIF ((request->filters[f].filter_flag=4)) "ORDER_CATALOG_SYNONYM"
     ELSE "CODE_VALUE"
     ENDIF
     , der.entity2_id = entity2_id,
     der.entity2_display = value_display, der.entity2_name = "CODE_VALUE", der.entity3_id =
     entity3_id,
     der.entity3_display = oe_field_display, der.entity3_name = entity3_name, der.rank_sequence = 0,
     der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), der
     .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
     der.updt_applctx = reqinfo->updt_applctx, der.updt_cnt = 0, der.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     der.updt_id = reqinfo->updt_id, der.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE deleterows(entity1_id,entity2_id,entity_reltn_mean,entity3_id)
   CALL logdebuginfo(build2("entity1_id = ",entity1_id))
   CALL logdebuginfo(build2("entity2_id = ",entity2_id))
   CALL logdebuginfo(build2("entity3_id = ",entity3_id))
   CALL logdebuginfo(build2("entity_reltn_mean = ",entity_reltn_mean))
   DECLARE newrowexists = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dcp_entity_reltn der
    WHERE der.entity_reltn_mean=entity_reltn_mean
     AND der.entity1_id=entity1_id
     AND der.entity2_id=entity2_id
     AND der.entity3_id=entity3_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET newrowexists = 1
   ENDIF
   CALL logdebuginfo(build2("newRowExists = ",newrowexists))
   IF (newrowexists > 0)
    DELETE  FROM dcp_entity_reltn der
     WHERE der.entity_reltn_mean=entity_reltn_mean
      AND der.entity1_id=entity1_id
      AND der.entity2_id=entity2_id
      AND der.entity3_id=entity3_id
     WITH nocounter
    ;end delete
   ELSEIF ((request->filter_type_indicator != 1))
    DELETE  FROM dcp_entity_reltn der
     WHERE der.entity_reltn_mean=entity_reltn_mean
      AND der.entity1_id=entity1_id
      AND ((nullind(der.entity3_id)=1) OR (der.entity3_id=0.0))
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteoldrowswithnoentitythreeid(entity1_id,entity2_id,entity_reltn_mean)
   CALL logdebuginfo(build2("entity1_id = ",entity1_id))
   CALL logdebuginfo(build2("entity2_id = ",entity2_id))
   CALL logdebuginfo(build2("entity_reltn_mean = ",entity_reltn_mean))
   DELETE  FROM dcp_entity_reltn der
    WHERE der.entity_reltn_mean=entity_reltn_mean
     AND der.entity1_id=entity1_id
     AND der.entity2_id=entity2_id
     AND ((nullind(der.entity3_id)=1) OR (der.entity3_id=0.0))
    WITH nocounter
   ;end delete
 END ;Subroutine
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE logdebuginfo(desc)
   IF (validate(debug,0)=1)
    CALL echo("===============================================")
    CALL echo(desc)
    CALL echo("===============================================")
   ENDIF
 END ;Subroutine
END GO
