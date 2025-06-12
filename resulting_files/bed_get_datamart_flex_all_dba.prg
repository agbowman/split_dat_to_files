CREATE PROGRAM bed_get_datamart_flex_all:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 flex_settings[*]
      2 flex_id = f8
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 parent_entity_type_flag = i2
    1 flex_groups[*]
      2 parent_flex
        3 parent_flex_id = f8
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 parent_entity_type_flag = i2
      2 child_flex
        3 child_flex_id = f8
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 parent_entity_type_flag = i2
    1 too_many_results_ind = i2
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
 IF ((validate(success,- (1))=- (1)))
  DECLARE success = i2 WITH protect, constant(1)
 ENDIF
 DECLARE max_items_to_return = i4 WITH protect, constant(1000)
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE cat_type_flags_size = i4 WITH protect, constant(size(request->category_type_flags,5))
 DECLARE flex_flags_size = i4 WITH protect, constant(size(request->flex_flags,5))
 DECLARE default_position_flex_search = vc WITH protect, constant(".br_datamart_flex_id > 0.0 ")
 DECLARE starts_with = vc WITH protect, constant("S")
 DECLARE contains = vc WITH protect, constant("C")
 DECLARE blank_string = vc WITH protect, constant(" ")
 DECLARE position_code_set = i4 WITH protect, constant(88)
 DECLARE position_entity_type = i2 WITH protect, constant(1)
 DECLARE location_entity_type = i2 WITH protect, constant(2)
 DECLARE flex_table_1_alias = vc WITH protect, constant("f1")
 DECLARE flex_table_2_alias = vc WITH protect, constant("f2")
 DECLARE pos_flex = i4 WITH protect, constant(1)
 DECLARE pos_loc_flex = i4 WITH protect, constant(3)
 DECLARE cat_type_parse = vc WITH protect, noconstant("")
 DECLARE flex_flag_parse = vc WITH protect, noconstant("")
 DECLARE position_flex_parse1 = vc WITH protect, noconstant(build2(flex_table_1_alias,
   default_position_flex_search))
 DECLARE position_flex_parse2 = vc WITH protect, noconstant(build2(flex_table_2_alias,
   default_position_flex_search))
 DECLARE flex_cnt = i4 WITH protect, noconstant(0)
 DECLARE flex_group_cnt = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE found = i4 WITH protect, noconstant(0)
 DECLARE parent_flex_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_entity_name = vc WITH protect, noconstant("")
 DECLARE parent_entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_entity_type_flag = i2 WITH protect, noconstant(0)
 DECLARE child_flex_id = f8 WITH protect, noconstant(0.0)
 DECLARE child_entity_name = vc WITH protect, noconstant("")
 DECLARE child_entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE child_entity_type_flag = i2 WITH protect, noconstant(0)
 DECLARE generatecattypeparse(dummy_var=i2) = i2 WITH protect
 DECLARE generateflexflagparse(dummy_var=i2) = i2 WITH protect
 DECLARE generatepositionsearchparse(tablealias=vc) = vc WITH protect
 DECLARE checkfortoomanyresults(dummyvar=i2) = i2 WITH protect
 IF (((cat_type_flags_size=0) OR (flex_flags_size=0)) )
  EXECUTE bederror "Error 01: Category type flag or flex type flag not given"
 ENDIF
 CALL generatecattypeparse(0)
 CALL generateflexflagparse(0)
 SET position_flex_parse1 = generatepositionsearchparse(flex_table_1_alias)
 SET position_flex_parse2 = generatepositionsearchparse(flex_table_2_alias)
 CALL logdebugmessage("POSITION PARSE1: ",position_flex_parse1)
 CALL logdebugmessage("POSITION PARSE2: ",position_flex_parse2)
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_value v,
   br_datamart_flex f1
  PLAN (c
   WHERE parser(cat_type_parse)
    AND parser(flex_flag_parse))
   JOIN (v
   WHERE v.br_datamart_category_id=c.br_datamart_category_id
    AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND v.logical_domain_id=logical_domain_id)
   JOIN (f1
   WHERE f1.br_datamart_flex_id=v.br_datamart_flex_id
    AND f1.grouper_ind=0
    AND ((f1.parent_entity_type_flag=location_entity_type) OR (parser(position_flex_parse1))) )
  ORDER BY f1.br_datamart_flex_id
  HEAD f1.br_datamart_flex_id
   IF (c.flex_flag=pos_flex)
    IF (locateval(index,1,flex_cnt,f1.parent_entity_id,reply->flex_settings[index].parent_entity_id)=
    0)
     flex_cnt = (flex_cnt+ 1), stat = alterlist(reply->flex_settings,flex_cnt), reply->flex_settings[
     flex_cnt].flex_id = f1.br_datamart_flex_id,
     reply->flex_settings[flex_cnt].parent_entity_name = f1.parent_entity_name, reply->flex_settings[
     flex_cnt].parent_entity_id = f1.parent_entity_id, reply->flex_settings[flex_cnt].
     parent_entity_type_flag = f1.parent_entity_type_flag
    ENDIF
   ELSEIF (c.flex_flag=pos_loc_flex)
    IF (locateval(index,1,flex_group_cnt,f1.parent_entity_id,reply->flex_groups[index].parent_flex.
     parent_entity_id)=0)
     flex_group_cnt = (flex_group_cnt+ 1), stat = alterlist(reply->flex_groups,flex_group_cnt), reply
     ->flex_groups[flex_group_cnt].parent_flex.parent_flex_id = f1.br_datamart_flex_id,
     reply->flex_groups[flex_group_cnt].parent_flex.parent_entity_name = f1.parent_entity_name, reply
     ->flex_groups[flex_group_cnt].parent_flex.parent_entity_id = f1.parent_entity_id, reply->
     flex_groups[flex_group_cnt].parent_flex.parent_entity_type_flag = f1.parent_entity_type_flag
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 02: Unable to retrieve flexed settings")
 CALL checkfortoomanyresults(0)
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_value v,
   br_datamart_flex f1,
   br_datamart_flex f2
  PLAN (c
   WHERE parser(cat_type_parse)
    AND parser(flex_flag_parse))
   JOIN (v
   WHERE v.br_datamart_category_id=c.br_datamart_category_id
    AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND v.logical_domain_id=logical_domain_id)
   JOIN (f1
   WHERE f1.br_datamart_flex_id=v.br_datamart_flex_id
    AND f1.grouper_ind=1
    AND ((f1.parent_entity_type_flag=location_entity_type) OR (parser(position_flex_parse1))) )
   JOIN (f2
   WHERE ((f2.grouper_flex_id=f1.br_datamart_flex_id) OR (f2.br_datamart_flex_id=f1.grouper_flex_id
   ))
    AND f2.grouper_ind=1
    AND ((f2.parent_entity_type_flag=location_entity_type) OR (parser(position_flex_parse2))) )
  ORDER BY f1.br_datamart_flex_id, f2.br_datamart_flex_id
  HEAD f2.br_datamart_flex_id
   IF (f1.parent_entity_type_flag=position_entity_type)
    parent_flex_id = f1.br_datamart_flex_id, parent_entity_name = f1.parent_entity_name,
    parent_entity_id = f1.parent_entity_id,
    parent_entity_type_flag = f1.parent_entity_type_flag, child_flex_id = f2.br_datamart_flex_id,
    child_entity_name = f2.parent_entity_name,
    child_entity_id = f2.parent_entity_id, child_entity_type_flag = f2.parent_entity_type_flag
   ELSE
    parent_flex_id = f2.br_datamart_flex_id, parent_entity_name = f2.parent_entity_name,
    parent_entity_id = f2.parent_entity_id,
    parent_entity_type_flag = f2.parent_entity_type_flag, child_flex_id = f1.br_datamart_flex_id,
    child_entity_name = f1.parent_entity_name,
    child_entity_id = f1.parent_entity_id, child_entity_type_flag = f1.parent_entity_type_flag
   ENDIF
   found = 0
   FOR (index = 1 TO flex_group_cnt)
     IF ((reply->flex_groups[index].parent_flex.parent_entity_id=parent_entity_id)
      AND (reply->flex_groups[index].child_flex.parent_entity_id=child_entity_id))
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    flex_group_cnt = (flex_group_cnt+ 1), stat = alterlist(reply->flex_groups,flex_group_cnt), reply
    ->flex_groups[flex_group_cnt].parent_flex.parent_flex_id = parent_flex_id,
    reply->flex_groups[flex_group_cnt].parent_flex.parent_entity_name = parent_entity_name, reply->
    flex_groups[flex_group_cnt].parent_flex.parent_entity_id = parent_entity_id, reply->flex_groups[
    flex_group_cnt].parent_flex.parent_entity_type_flag = parent_entity_type_flag,
    reply->flex_groups[flex_group_cnt].child_flex.child_flex_id = child_flex_id, reply->flex_groups[
    flex_group_cnt].child_flex.parent_entity_name = child_entity_name, reply->flex_groups[
    flex_group_cnt].child_flex.parent_entity_id = child_entity_id,
    reply->flex_groups[flex_group_cnt].child_flex.parent_entity_type_flag = child_entity_type_flag
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 03: Unable to retrieve flexed grouped settings")
 CALL checkfortoomanyresults(0)
 SUBROUTINE generatecattypeparse(dummy_var)
   FOR (i = 1 TO cat_type_flags_size)
    SET cur_cat_type = request->category_type_flags[i].category_type_flag
    IF (i=1)
     SET cat_type_parse = build2("c.category_type_flag in( ",cur_cat_type)
    ELSE
     SET cat_type_parse = build2(cat_type_parse,", ",cur_cat_type)
    ENDIF
   ENDFOR
   SET cat_type_parse = build2(cat_type_parse," )")
   IF (validate(debug,0)=1)
    CALL echo(build("cat_type_parse: ",cat_type_parse))
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE generateflexflagparse(dummy_var)
   FOR (j = 1 TO flex_flags_size)
    SET cur_flex_flag = request->flex_flags[j].flex_flag
    IF (j=1)
     SET flex_flag_parse = build2("c.flex_flag in (",cur_flex_flag)
    ELSE
     SET flex_flag_parse = build2(flex_flag_parse,",",cur_flex_flag)
    ENDIF
   ENDFOR
   SET flex_flag_parse = build2(flex_flag_parse,")")
   IF (validate(debug,0)=1)
    CALL echo(build("flex_flag_parse: ",flex_flag_parse))
   ENDIF
 END ;Subroutine
 SUBROUTINE generatepositionsearchparse(tablealias)
   DECLARE inputed_search_type = vc WITH protect, constant(cnvtupper(trim(request->
      position_search_settings.search_type)))
   DECLARE inputed_search_string = vc WITH protect, constant(cnvtupper(trim(request->
      position_search_settings.search_string)))
   DECLARE position_flex_parse = vc WITH protect, noconstant(build2(tablealias,
     default_position_flex_search))
   IF (((inputed_search_type=starts_with) OR (inputed_search_type=contains))
    AND inputed_search_string > blank_string)
    DECLARE position_search = vc WITH protect, noconstant(build2(position_search," cv.code_set = ",
      position_code_set))
    SET position_search = build2(position_search,
     " and cv.active_ind = 1 and cv.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ")
    IF (inputed_search_type=starts_with)
     SET position_search = build2(position_search," and cnvtupper(cv.display) = '")
     SET position_search = build2(position_search,inputed_search_string)
     SET position_search = build2(position_search,"*'")
    ELSEIF (inputed_search_type=contains)
     SET position_search = build2(position_search," and cnvtupper(cv.display) = '*")
     SET position_search = build2(position_search,inputed_search_string)
     SET position_search = build2(position_search,"*'")
    ENDIF
    DECLARE first_position = i2 WITH protect, noconstant(1)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE parser(position_search))
     ORDER BY cv.code_value
     HEAD REPORT
      position_flex_parse = build2(position_flex_parse," and ",tablealias,".parent_entity_id in( ")
     DETAIL
      IF (first_position=1)
       first_position = 0
      ELSE
       position_flex_parse = build2(position_flex_parse,", ")
      ENDIF
      position_flex_parse = build2(position_flex_parse,cv.code_value)
     FOOT REPORT
      position_flex_parse = build2(position_flex_parse," )")
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 04: Unable to retrieve filtered positions")
   ENDIF
   RETURN(position_flex_parse)
 END ;Subroutine
 SUBROUTINE checkfortoomanyresults(dummyvar)
   IF (((size(reply->flex_settings,5)+ size(reply->flex_groups,5)) > max_items_to_return))
    SET stat = alterlist(reply->flex_settings,0)
    SET stat = alterlist(reply->flex_groups,0)
    SET reply->too_many_results_ind = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
