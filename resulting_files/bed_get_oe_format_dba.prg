CREATE PROGRAM bed_get_oe_format:dba
 FREE SET reply
 RECORD reply(
   1 oe_format_list[*]
     2 oe_format_id = f8
     2 oe_format_name = vc
     2 catalog_type_code_value = f8
     2 catalog_type_display = c40
     2 catalog_type_cdf_meaning = c12
     2 flexed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD full_oe_format_list(
   1 oe_format_list[*]
     2 oe_format_id = f8
     2 oe_format_name = vc
     2 catalog_type_code_value = f8
     2 catalog_type_display = c40
     2 catalog_type_cdf_meaning = c12
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
 DECLARE listcount = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE order_code_value = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(size(request->alist,5))
 DECLARE oef_parse = vc WITH protect, noconstant("")
 DECLARE aff_parse = vc WITH protect, noconstant("")
 DECLARE buildoefparserfororderaction(dummyvar=i2) = i2
 DECLARE buildoefparserforrequestedactions(dummyvar=i2) = i2
 DECLARE getorderentryformatswithsentences(dummyvar=i2) = i2
 DECLARE getorderentryformats(dummyvar=i2) = i2
 SET reply->too_many_results_ind = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 IF (validate(request->sentencecheckind,0)=1)
  CALL getorderentryformatswithsentences(0)
 ELSE
  IF (((acnt=0) OR ((request->alist[1].action_type_cdf_meaning=" "))) )
   CALL buildoefparserfororderaction(0)
  ELSE
   CALL buildoefparserforrequestedactions(0)
  ENDIF
  CALL getorderentryformats(0)
 ENDIF
#exit_script
 IF (count >= max_reply)
  SET stat = alterlist(reply->oe_format_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE getorderentryformatswithsentences(dummyvar)
   DECLARE fcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_entry_format oef,
     code_value cv
    PLAN (oef
     WHERE oef.oe_format_id > 0)
     JOIN (cv
     WHERE cv.code_value=oef.catalog_type_cd
      AND cv.code_set=6000
      AND cv.active_ind=1)
    ORDER BY oef.oe_format_id
    HEAD oef.oe_format_id
     fcnt = (fcnt+ 1), stat = alterlist(full_oe_format_list->oe_format_list,fcnt),
     full_oe_format_list->oe_format_list[fcnt].oe_format_id = oef.oe_format_id,
     full_oe_format_list->oe_format_list[fcnt].oe_format_name = oef.oe_format_name,
     full_oe_format_list->oe_format_list[fcnt].catalog_type_code_value = oef.catalog_type_cd,
     full_oe_format_list->oe_format_list[fcnt].catalog_type_display = cv.display,
     full_oe_format_list->oe_format_list[fcnt].catalog_type_cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET count = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(full_oe_format_list->oe_format_list,5)),
     order_sentence os
    PLAN (d)
     JOIN (os
     WHERE (os.oe_format_id=full_oe_format_list->oe_format_list[d.seq].oe_format_id))
    HEAD d.seq
     count = (count+ 1), stat = alterlist(reply->oe_format_list,count), reply->oe_format_list[count].
     oe_format_id = full_oe_format_list->oe_format_list[d.seq].oe_format_id,
     reply->oe_format_list[count].oe_format_name = full_oe_format_list->oe_format_list[d.seq].
     oe_format_name, reply->oe_format_list[count].catalog_type_code_value = full_oe_format_list->
     oe_format_list[d.seq].catalog_type_code_value, reply->oe_format_list[count].catalog_type_display
      = full_oe_format_list->oe_format_list[d.seq].catalog_type_display,
     reply->oe_format_list[count].catalog_type_cdf_meaning = full_oe_format_list->oe_format_list[d
     .seq].catalog_type_cdf_meaning
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getorderentryformats(dummyvar)
   SET stat = alterlist(reply->oe_format_list,25)
   SELECT DISTINCT INTO "NL:"
    oef.*, cv.*
    FROM order_entry_format oef,
     code_value cv
    PLAN (oef
     WHERE parser(oef_parse))
     JOIN (cv
     WHERE cv.code_value=oef.catalog_type_cd
      AND cv.code_set=6000
      AND cv.active_ind=1)
    ORDER BY oef.oe_format_name
    HEAD REPORT
     count = 0, listcount = 0
    DETAIL
     count = (count+ 1), listcount = (listcount+ 1)
     IF (listcount > 25)
      stat = alterlist(reply->oe_format_list,(listcount+ 25)), listcountcount = 0
     ENDIF
     reply->oe_format_list[count].oe_format_id = oef.oe_format_id, reply->oe_format_list[count].
     oe_format_name = oef.oe_format_name, reply->oe_format_list[count].catalog_type_code_value = oef
     .catalog_type_cd,
     reply->oe_format_list[count].catalog_type_display = cv.display, reply->oe_format_list[count].
     catalog_type_cdf_meaning = cv.cdf_meaning
    WITH maxrec = value(max_reply), nocounter
   ;end select
   CALL bederrorcheck("Failure in getOrderEntryFormats()")
   SET stat = alterlist(reply->oe_format_list,count)
   IF (count > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = count),
      accept_format_flexing aff
     PLAN (d)
      JOIN (aff
      WHERE (aff.oe_format_id=reply->oe_format_list[d.seq].oe_format_id))
     HEAD aff.oe_format_id
      reply->oe_format_list[d.seq].flexed_ind = 1
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failure in getOrderEntryFormats()")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildoefparserfororderaction(dummyvar)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.cdf_meaning="ORDER"
     AND cv.code_set=6003
     AND cv.active_ind=1
    DETAIL
     order_code_value = cv.code_value
    WITH nocounter
   ;end select
   CALL echo(order_code_value)
   CALL bederrorcheck("Failure in buildOEFParserForOrderAction()")
   SET oef_parse = concat("oef.oe_format_id > 0 and ",
    "(oef.catalog_type_cd = request->catalog_type_code_value or ",
    "request->catalog_type_code_value = 0) and (","oef.action_type_cd = order_code_value)")
 END ;Subroutine
 SUBROUTINE buildoefparserforrequestedactions(dummyvar)
   DECLARE actioncd = f8 WITH protect, noconstant(0)
   SET oef_parse = concat("oef.oe_format_id > 0 and ",
    "(oef.catalog_type_cd = request->catalog_type_code_value or ",
    "request->catalog_type_code_value = 0) and (")
   FOR (a = 1 TO acnt)
     SET actioncd = 0
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE cv.code_set=6003
       AND (cv.cdf_meaning=request->alist[a].action_type_cdf_meaning)
       AND cv.active_ind=1
      DETAIL
       actioncd = cv.code_value
      WITH nocounter
     ;end select
     CALL bederrorcheck("Failure in buildOEFParserForRequestedActions()")
     IF (a=acnt)
      SET oef_parse = build(oef_parse," oef.action_type_cd = ",actioncd,")")
     ELSE
      SET oef_parse = build(oef_parse," oef.action_type_cd = ",actioncd," or ")
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
