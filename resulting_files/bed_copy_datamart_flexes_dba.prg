CREATE PROGRAM bed_copy_datamart_flexes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD valuestocopy
 RECORD valuestocopy(
   1 values[*]
     2 br_datamart_filter_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 freetext_desc = vc
     2 end_effective_dt_tm = dq8
     2 br_datamart_category_id = f8
     2 value_seq = i4
     2 value_type_flag = i2
     2 qualifier_flag = i2
     2 group_seq = i4
     2 mpage_param_mean = vc
     2 mpage_param_value = vc
     2 parent_entity_id2 = f8
     2 parent_entity_name2 = vc
     2 map_data_type_cd = f8
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
 DECLARE generateflexid(pk=f8(ref)) = i2
 DECLARE insertflex(flexid=f8,grouperflexid=f8,perententityname=vc,parententityid=f8,typeflag=i4,
  grouperind=i2) = i2
 DECLARE findflexid(pename=vc,peid=f8,petypeflag=i2,grouperid=f8,grouperind=i2) = f8
 SUBROUTINE generateflexid(id)
   CALL bedlogmessage("generateFlexId","Entering ...")
   SET id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     id = cnvtreal(j)
    WITH format, counter
   ;end select
   CALL bedlogmessage("generateFlexId","Exiting ...")
 END ;Subroutine
 SUBROUTINE findflexid(pename,peid,petypeflag,grouperid,grouperind)
   CALL bedlogmessage("findFlexId","Entering ...")
   IF ( NOT (validate(tempflexid)))
    DECLARE tempflexid = f8 WITH protect, noconstant(0)
   ENDIF
   SET tempflexid = 0.0
   SELECT INTO "nl:"
    FROM br_datamart_flex f
    PLAN (f
     WHERE f.parent_entity_name=pename
      AND f.parent_entity_id=peid
      AND f.parent_entity_type_flag=petypeflag
      AND f.grouper_flex_id=grouperid
      AND f.grouper_ind=grouperind)
    DETAIL
     tempflexid = f.br_datamart_flex_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("findFlexId","Exiting ...")
   RETURN(tempflexid)
 END ;Subroutine
 SUBROUTINE insertflex(flexid,grouperflexid,perententityname,parententityid,typeflag,grouperind)
   CALL bedlogmessage("insertFlex","Entering ...")
   INSERT  FROM br_datamart_flex f
    SET f.br_datamart_flex_id = flexid, f.grouper_flex_id = grouperflexid, f.parent_entity_name =
     perententityname,
     f.parent_entity_type_flag = typeflag, f.parent_entity_id = parententityid, f.grouper_ind =
     grouperind,
     f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task
    PLAN (f)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error insering br_datamart_flex.")
   CALL bedlogmessage("insertFlex","Exiting ...")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE copy_to_flex_size = i4 WITH protect, constant(size(request->copytoflexes,5))
 DECLARE topics_to_copy_size = i4 WITH protect, constant(size(request->topicstocopy,5))
 DECLARE zero_id = f8 WITH protect, constant(0.0)
 DECLARE code_value_table = vc WITH protect, constant("CODE_VALUE")
 DECLARE non_grouper = i2 WITH protect, constant(0)
 DECLARE grouper = i2 WITH protect, constant(1)
 DECLARE position_type_flag = i2 WITH protect, constant(1)
 DECLARE location_type_flag = i2 WITH protect, constant(2)
 DECLARE base_topic_parse = vc WITH protect, constant(" v.br_datamart_value_id > 0.0 ")
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE temp_id = f8 WITH protect, noconstant(0.0)
 DECLARE topic_parse = vc WITH protect, noconstant(base_topic_parse)
 DECLARE value_count = i4 WITH protect, noconstant(0)
 DECLARE parentflexid = f8 WITH protect, noconstant(0.0)
 DECLARE getflexids(dummyvar=i2) = i2
 DECLARE preparetopicparse(dummyvar=i2) = i2
 DECLARE preparevaluestocopy(dummyvar=i2) = i2
 DECLARE removeoldvalues(dummyvar=i2) = i2
 DECLARE copynewvalues(dummyvar=i2) = i2
 IF (((copy_to_flex_size=0) OR (topics_to_copy_size=0)) )
  GO TO exit_script
 ENDIF
 CALL bedlogmessage("DEBUG001:"," Entering getFlexIds")
 CALL getflexids(0)
 CALL bedlogmessage("DEBUG002:"," Exiting getFlexIds")
 CALL bedlogmessage("DEBUG003:"," Entering prepareValuesToCopy")
 CALL preparevaluestocopy(0)
 CALL bedlogmessage("DEBUG004:"," Exiting prepareValuesToCopy")
 CALL bedlogmessage("DEBUG005:"," Entering removeOldValues")
 CALL removeoldvalues(0)
 CALL bedlogmessage("DEBUG006:"," Exiting removeOldValues")
 CALL bedlogmessage("DEBUG007:"," Entering copyNewValues")
 CALL copynewvalues(0)
 CALL bedlogmessage("DEBUG008:"," Exiting copyNewValues")
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getflexids(dummyvar)
  IF ((request->copyfromflex.location_cd=zero_id))
   SET request->copyfromflex.flex_id = findflexid(code_value_table,request->copyfromflex.position_cd,
    position_type_flag,zero_id,non_grouper)
  ELSE
   SET parentflexid = findflexid(code_value_table,request->copyfromflex.position_cd,
    position_type_flag,zero_id,grouper)
   SET request->copyfromflex.flex_id = findflexid(code_value_table,request->copyfromflex.location_cd,
    location_type_flag,parentflexid,grouper)
  ENDIF
  FOR (index = 1 TO copy_to_flex_size)
    IF ((request->copytoflexes[index].location_cd=zero_id))
     SET request->copytoflexes[index].flex_id = findflexid(code_value_table,request->copytoflexes[
      index].position_cd,position_type_flag,zero_id,non_grouper)
     IF ((request->copytoflexes[index].flex_id=zero_id))
      CALL generateflexid(parentflexid)
      CALL insertflex(parentflexid,zero_id,code_value_table,request->copytoflexes[index].position_cd,
       position_type_flag,
       non_grouper)
      SET request->copytoflexes[index].flex_id = findflexid(code_value_table,request->copytoflexes[
       index].position_cd,position_type_flag,zero_id,non_grouper)
     ENDIF
    ELSE
     SET parentflexid = findflexid(code_value_table,request->copytoflexes[index].position_cd,
      position_type_flag,zero_id,grouper)
     IF (parentflexid=zero_id)
      CALL generateflexid(parentflexid)
      CALL insertflex(parentflexid,zero_id,code_value_table,request->copytoflexes[index].position_cd,
       position_type_flag,
       grouper)
      CALL generateflexid(request->copytoflexes[index].flex_id)
      CALL insertflex(request->copytoflexes[index].flex_id,parentflexid,code_value_table,request->
       copytoflexes[index].location_cd,location_type_flag,
       grouper)
     ELSE
      SET request->copytoflexes[index].flex_id = findflexid(code_value_table,request->copytoflexes[
       index].location_cd,location_type_flag,parentflexid,grouper)
      IF ((request->copytoflexes[index].flex_id=zero_id))
       CALL generateflexid(request->copytoflexes[index].flex_id)
       CALL insertflex(request->copytoflexes[index].flex_id,parentflexid,code_value_table,request->
        copytoflexes[index].location_cd,location_type_flag,
        grouper)
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE preparetopicparse(dummyvar)
   CALL bedlogmessage("DEBUG012:","Entering prepareTopicParse.")
   SET topic_parse = build2(base_topic_parse," and v.br_datamart_category_id in ( ")
   FOR (index = 1 TO (topics_to_copy_size - 1))
     SET topic_parse = build2(topic_parse,request->topicstocopy[index].topic_id,", ")
   ENDFOR
   SET topic_parse = build2(topic_parse,request->topicstocopy[topics_to_copy_size].topic_id," ) ")
   CALL bedlogmessage("DEBUG011:",topic_parse)
   CALL bedlogmessage("DEBUG013:","Exiting prepareTopicParse.")
 END ;Subroutine
 SUBROUTINE preparevaluestocopy(dummyvar)
   CALL preparetopicparse(0)
   SELECT INTO "nl:"
    FROM br_datamart_value v
    PLAN (v
     WHERE (v.br_datamart_flex_id=request->copyfromflex.flex_id)
      AND v.logical_domain_id=logical_domain_id
      AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND parser(topic_parse))
    ORDER BY v.br_datamart_value_id
    DETAIL
     value_count = (value_count+ 1), stat = alterlist(valuestocopy->values,value_count), valuestocopy
     ->values[value_count].br_datamart_filter_id = v.br_datamart_filter_id,
     valuestocopy->values[value_count].parent_entity_name = v.parent_entity_name, valuestocopy->
     values[value_count].parent_entity_id = v.parent_entity_id, valuestocopy->values[value_count].
     freetext_desc = v.freetext_desc,
     valuestocopy->values[value_count].end_effective_dt_tm = v.end_effective_dt_tm, valuestocopy->
     values[value_count].br_datamart_category_id = v.br_datamart_category_id, valuestocopy->values[
     value_count].value_seq = v.value_seq,
     valuestocopy->values[value_count].value_type_flag = v.value_type_flag, valuestocopy->values[
     value_count].qualifier_flag = v.qualifier_flag, valuestocopy->values[value_count].group_seq = v
     .group_seq,
     valuestocopy->values[value_count].mpage_param_mean = v.mpage_param_mean, valuestocopy->values[
     value_count].mpage_param_value = v.mpage_param_value, valuestocopy->values[value_count].
     parent_entity_id2 = v.parent_entity_id2,
     valuestocopy->values[value_count].parent_entity_name2 = v.parent_entity_name2, valuestocopy->
     values[value_count].map_data_type_cd = v.map_data_type_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR009: Cannot get values.")
 END ;Subroutine
 SUBROUTINE removeoldvalues(dummyvar)
   CALL preparetopicparse(0)
   DELETE  FROM (dummyt d  WITH seq = copy_to_flex_size),
     br_datamart_value v
    SET v.seq = 1
    PLAN (d)
     JOIN (v
     WHERE (v.br_datamart_flex_id=request->copytoflexes[d.seq].flex_id)
      AND v.logical_domain_id=logical_domain_id
      AND v.br_datamart_flex_id > zero_id
      AND parser(topic_parse))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("ERROR010: Cannot remove existing values.")
 END ;Subroutine
 SUBROUTINE copynewvalues(dummyvar)
   FOR (index = 1 TO copy_to_flex_size)
    CALL echo(cnvtstring(index))
    FOR (index2 = 1 TO size(valuestocopy->values,5))
      SELECT INTO "nl:"
       j = seq(bedrock_seq,nextval)
       FROM dual d
       DETAIL
        temp_id = j
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR011: Cannot get new value id.")
      INSERT  FROM br_datamart_value v
       SET v.br_datamart_value_id = temp_id, v.br_datamart_filter_id = valuestocopy->values[index2].
        br_datamart_filter_id, v.parent_entity_name = valuestocopy->values[index2].parent_entity_name,
        v.parent_entity_id = valuestocopy->values[index2].parent_entity_id, v.freetext_desc =
        valuestocopy->values[index2].freetext_desc, v.value_dt_tm = cnvtdatetime(curdate,curtime3),
        v.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), v.end_effective_dt_tm = cnvtdatetime(
         valuestocopy->values[index2].end_effective_dt_tm), v.br_datamart_category_id = valuestocopy
        ->values[index2].br_datamart_category_id,
        v.value_seq = valuestocopy->values[index2].value_seq, v.value_type_flag = valuestocopy->
        values[index2].value_type_flag, v.qualifier_flag = valuestocopy->values[index2].
        qualifier_flag,
        v.group_seq = valuestocopy->values[index2].group_seq, v.mpage_param_mean = valuestocopy->
        values[index2].mpage_param_mean, v.mpage_param_value = valuestocopy->values[index2].
        mpage_param_value,
        v.parent_entity_id2 = valuestocopy->values[index2].parent_entity_id2, v.parent_entity_name2
         = valuestocopy->values[index2].parent_entity_name2, v.br_datamart_flex_id = request->
        copytoflexes[index].flex_id,
        v.map_data_type_cd = valuestocopy->values[index2].map_data_type_cd, v.logical_domain_id =
        logical_domain_id, v.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        v.updt_id = reqinfo->updt_id, v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ERROR012: Cannot insert new value.")
    ENDFOR
   ENDFOR
 END ;Subroutine
END GO
