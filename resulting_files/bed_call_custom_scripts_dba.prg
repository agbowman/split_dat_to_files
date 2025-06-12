CREATE PROGRAM bed_call_custom_scripts:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 custom_filter_items[*]
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 display = vc
      2 status_ind = i2
      2 description = vc
    1 script_found_ind = i2
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
 RECORD temp_reply(
   1 custom_filter_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 display = vc
     2 status_ind = i2
     2 description = vc
 ) WITH protect
 RECORD getfiltervalues(
   1 custom_filter_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 display = vc
     2 status_ind = i2
     2 description = vc
     2 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
 DECLARE setsearchstringfromrequest(dummyvar=i2) = i2
 DECLARE wcard = vc WITH protect, constant("*")
 DECLARE search_string = vc WITH protect, noconstant("")
 DECLARE include_inactives_ind = i2 WITH protect, noconstant(0)
 DECLARE max_limit = i4 WITH protect, constant(5000)
 DECLARE script_name = vc WITH protect, noconstant("")
 DECLARE replysize = i4 WITH protect, noconstant(0)
 DECLARE search_string_found = i2 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 DECLARE poscnt = i4 WITH protect, noconstant(0)
 DECLARE active_cnt = i4 WITH protect, noconstant(0)
 DECLARE script_found = i4 WITH protect, noconstant(0)
 SET reply->too_many_results_ind = 0
 SET reply->script_found_ind = 0
 CALL bedbeginscript(0)
 IF (validate(request->script_name,"") > " ")
  SET script_name = trim(cnvtupper(request->script_name))
  SET script_found = checkprg(cnvtupper(script_name))
 ENDIF
 IF (validate(request->include_inactives_ind,0)=1)
  SET include_inactives_ind = 1
 ENDIF
 IF (script_found IN (1, 2))
  SET reply->script_found_ind = 1
  EXECUTE value(script_name)  WITH replace("REPLY",getfiltervalues)
  IF ((getfiltervalues->status_data.status != "S"))
   CALL bederror(concat("Executing the script",script_name,"failed"))
   IF (validate(debug,0)=1)
    CALL echorecord(getfiltervalues)
   ENDIF
  ELSEIF (validate(getfiltervalues->custom_filter_items))
   SET replysize = size(getfiltervalues->custom_filter_items,5)
   SET search_string_found = setsearchstringfromrequest(0)
   IF (replysize > max_limit)
    SET stat = initrec(getfiltervalues)
    SET reply->too_many_results_ind = 1
    SET reply->script_found_ind = 1
    GO TO exit_script
   ELSEIF (replysize > 0)
    IF (search_string_found=1)
     SET pos = locateval(index,1,size(getfiltervalues->custom_filter_items,5),patstring(search_string
       ),cnvtupper(getfiltervalues->custom_filter_items[index].display))
     WHILE (pos > 0)
       SET poscnt = (poscnt+ 1)
       SET stat = alterlist(reply->custom_filter_items,poscnt)
       SET reply->custom_filter_items[poscnt].parent_entity_name = getfiltervalues->
       custom_filter_items[pos].parent_entity_name
       SET reply->custom_filter_items[poscnt].parent_entity_id = getfiltervalues->
       custom_filter_items[pos].parent_entity_id
       SET reply->custom_filter_items[poscnt].display = getfiltervalues->custom_filter_items[pos].
       display
       SET reply->custom_filter_items[poscnt].description = getfiltervalues->custom_filter_items[pos]
       .description
       SET reply->custom_filter_items[poscnt].status_ind = getfiltervalues->custom_filter_items[pos].
       status_ind
       SET pos = locateval(index,(pos+ 1),size(getfiltervalues->custom_filter_items,5),patstring(
         search_string),cnvtupper(getfiltervalues->custom_filter_items[index].display))
     ENDWHILE
     SET stat = alterlist(reply->custom_filter_items,poscnt)
    ELSEIF (search_string_found=0)
     SET stat = alterlist(reply->custom_filter_items,replysize)
     FOR (i = 1 TO replysize)
       SET reply->custom_filter_items[i].parent_entity_name = getfiltervalues->custom_filter_items[i]
       .parent_entity_name
       SET reply->custom_filter_items[i].parent_entity_id = getfiltervalues->custom_filter_items[i].
       parent_entity_id
       SET reply->custom_filter_items[i].display = getfiltervalues->custom_filter_items[i].display
       SET reply->custom_filter_items[i].description = getfiltervalues->custom_filter_items[i].
       description
       SET reply->custom_filter_items[i].status_ind = getfiltervalues->custom_filter_items[i].
       status_ind
     ENDFOR
    ENDIF
   ENDIF
  ENDIF
  SET stat = moverec(reply->custom_filter_items,temp_reply->custom_filter_items)
  IF (include_inactives_ind=0)
   SET pos = locateval(index1,1,size(temp_reply->custom_filter_items,5),1,temp_reply->
    custom_filter_items[index1].status_ind)
   WHILE (pos > 0)
     SET active_cnt = (active_cnt+ 1)
     SET stat = alterlist(reply->custom_filter_items,active_cnt)
     SET reply->custom_filter_items[active_cnt].parent_entity_name = temp_reply->custom_filter_items[
     pos].parent_entity_name
     SET reply->custom_filter_items[active_cnt].parent_entity_id = temp_reply->custom_filter_items[
     pos].parent_entity_id
     SET reply->custom_filter_items[active_cnt].display = temp_reply->custom_filter_items[pos].
     display
     SET reply->custom_filter_items[active_cnt].description = temp_reply->custom_filter_items[pos].
     description
     SET reply->custom_filter_items[active_cnt].status_ind = temp_reply->custom_filter_items[pos].
     status_ind
     SET pos = locateval(index1,(pos+ 1),size(temp_reply->custom_filter_items,5),1,temp_reply->
      custom_filter_items[index1].status_ind)
   ENDWHILE
   SET stat = alterlist(reply->custom_filter_items,active_cnt)
  ENDIF
 ENDIF
 SUBROUTINE setsearchstringfromrequest(dummyvar)
   IF (trim(request->search_txt) > " ")
    SET search_string_found = 1
    IF ((request->search_type_flag="S"))
     SET search_string = concat(cnvtupper(trim(request->search_txt)),wcard)
    ELSEIF ((request->search_type_flag="C"))
     SET search_string = concat(wcard,cnvtupper(trim(request->search_txt)),wcard)
    ENDIF
   ENDIF
   CALL echo(build("search_string:",search_string))
   RETURN(search_string_found)
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
