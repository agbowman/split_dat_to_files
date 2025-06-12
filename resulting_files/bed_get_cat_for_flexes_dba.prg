CREATE PROGRAM bed_get_cat_for_flexes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 flexes[*]
      2 flex_id = f8
      2 position_cd = f8
      2 location_cd = f8
      2 flex_type = i2
      2 defined_ind = i2
      2 category[*]
        3 br_datamart_category_id = f8
        3 category_name = vc
        3 category_mean = vc
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
 DECLARE flex_size = i4 WITH protect, constant(size(request->flexes,5))
 DECLARE grouper_exist = i4 WITH protect, constant(1)
 DECLARE no_grouper_exist = i4 WITH protect, constant(0)
 DECLARE pos_flex = i4 WITH protect, constant(1)
 DECLARE pos_loc_flex = i4 WITH protect, constant(3)
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE category_id_parse = vc WITH protect, constant(
  " b_cat.br_datamart_category_id = b_val.br_datamart_category_id ")
 DECLARE category_flex_parse = vc WITH protect, constant(build2(" and b_cat.flex_flag = ",request->
   flex_type," "))
 DECLARE category_type_parse = vc WITH protect, constant(build2(" and b_cat.category_type_flag = ",
   request->category_type," "))
 DECLARE zero_id = f8 WITH protect, constant(0.0)
 DECLARE code_value_table = vc WITH protect, constant("CODE_VALUE")
 DECLARE position_type_flag = i2 WITH protect, constant(1)
 DECLARE location_type_flag = i2 WITH protect, constant(2)
 DECLARE cat_count = i2 WITH protect, noconstant(0)
 DECLARE cat_parse = vc WITH protect, noconstant(build2(category_id_parse,category_flex_parse,
   category_type_parse))
 DECLARE parentflexid = f8 WITH protect, noconstant(0.0)
 DECLARE generatecatparse(index=i4) = i2 WITH protect
 IF (flex_size > 0)
  SET stat = alterlist(reply->flexes,flex_size)
  FOR (x = 1 TO flex_size)
    IF ((request->flexes[x].location_cd=zero_id))
     SET request->flexes[x].flex_id = findflexid(code_value_table,request->flexes[x].position_cd,
      position_type_flag,zero_id,no_grouper_exist)
    ELSE
     SET parentflexid = findflexid(code_value_table,request->flexes[x].position_cd,position_type_flag,
      zero_id,grouper_exist)
     IF (parentflexid != zero_id)
      SET request->flexes[x].flex_id = findflexid(code_value_table,request->flexes[x].location_cd,
       location_type_flag,parentflexid,grouper_exist)
     ENDIF
    ENDIF
    CALL generatecatparse(x)
    SET cat_count = 0
    SELECT INTO "nl:"
     FROM br_datamart_value b_val,
      br_datamart_category b_cat
     PLAN (b_val
      WHERE (b_val.br_datamart_flex_id=request->flexes[x].flex_id)
       AND b_val.br_datamart_flex_id != 0
       AND b_val.logical_domain_id=logical_domain_id)
      JOIN (b_cat
      WHERE parser(cat_parse))
     ORDER BY b_val.br_datamart_flex_id, b_cat.br_datamart_category_id, b_cat.category_mean
     HEAD REPORT
      reply->flexes[x].flex_id = request->flexes[x].flex_id, reply->flexes[x].position_cd = request->
      flexes[x].position_cd, reply->flexes[x].location_cd = request->flexes[x].location_cd,
      reply->flexes[x].flex_type = request->flex_type
     HEAD b_cat.br_datamart_category_id
      reply->flexes[x].defined_ind = 1
      IF ((request->return_ind=1))
       cat_count = (cat_count+ 1), stat = alterlist(reply->flexes[x].category,cat_count), reply->
       flexes[x].category[cat_count].br_datamart_category_id = b_cat.br_datamart_category_id,
       reply->flexes[x].category[cat_count].category_name = b_cat.category_name, reply->flexes[x].
       category[cat_count].category_mean = b_cat.category_mean
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 05: Unable to retrieve categories")
  ENDFOR
 ENDIF
 SUBROUTINE generatecatparse(index)
   SET cat_count = size(request->flexes[index].topics,5)
   IF (cat_count > 0)
    SET cat_parse = build2(cat_parse," and b_cat.br_datamart_category_id in ( ")
    FOR (i = 1 TO (cat_count - 1))
      SET cat_parse = build2(cat_parse,request->flexes[index].topics[i].category_id," , ")
    ENDFOR
    SET cat_parse = build2(cat_parse,request->flexes[index].topics[cat_count].category_id)
    SET cat_parse = build2(cat_parse," ) ")
   ENDIF
   IF (validate(debug,0)=1)
    CALL echo(build("cat_parse: ",cat_parse))
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
