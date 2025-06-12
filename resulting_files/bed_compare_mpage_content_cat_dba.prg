CREATE PROGRAM bed_compare_mpage_content_cat:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 compared_views[*]
      2 br_datamart_category_id = f8
      2 reports
        3 report_id = f8
        3 report_mean = vc
        3 report_name = vc
        3 report_name_changed = vc
        3 flags[*]
          4 flag_type = i4
        3 filters[*]
          4 filter_id = f8
          4 filter_mean = vc
          4 filter_category_mean = vc
          4 filter_display = vc
          4 filter_seq = i4
          4 filter_name_changed = vc
          4 flags[*]
            5 flag_type = i4
          4 filter_limit = i4
          4 filter_limit_changed = i4
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
 DECLARE categoriescnt = i4 WITH protect, noconstant(size(request->views,5))
 DECLARE populatecomparedviews(dummyvar=i2) = null
 IF ( NOT (validate(temprequest,0)))
  RECORD temprequest(
    1 br_datamart_category_id = f8
    1 req_report_mean = vc
  )
 ENDIF
 IF ( NOT (validate(tempcompare,0)))
  RECORD tempcompare(
    1 br_datamart_category_id = f8
    1 reports[*]
      2 report_id = f8
      2 report_mean = vc
      2 report_name = vc
      2 report_name_changed = vc
      2 flags[*]
        3 flag_type = i4
      2 filters[*]
        3 filter_id = f8
        3 filter_mean = vc
        3 filter_category_mean = vc
        3 filter_display = vc
        3 filter_seq = i4
        3 filter_name_changed = vc
        3 flags[*]
          4 flag_type = i4
        3 filter_limit = i4
        3 filter_limit_changed = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL populatecomparedviews(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE populatecomparedviews(codeset)
   IF (categoriescnt > 0)
    CALL logdebugmessage("categoriesCnt : ",categoriescnt)
    DECLARE comparedviewreplycnt = i4 WITH protect, noconstant(0)
    DECLARE i = i4 WITH protect, noconstant(0)
    DECLARE j = i4 WITH protect, noconstant(0)
    DECLARE k = i4 WITH protect, noconstant(0)
    DECLARE p = i4 WITH protect, noconstant(0)
    DECLARE q = i4 WITH protect, noconstant(0)
    SET temprequest->req_report_mean = request->report_mean
    FOR (i = 1 TO categoriescnt)
      SET temprequest->br_datamart_category_id = request->views[i].br_datamart_category_id
      EXECUTE bed_compare_mpage_content  WITH replace("REQUEST",temprequest), replace("REPLY",
       tempcompare)
      IF ((tempcompare->status_data.status != "S"))
       CALL bederror("bed_compare_mpage_content did not return success")
       CALL logdebugmessage("tempRequest->br_datamart_category_id : ",temprequest->
        br_datamart_category_id)
      ENDIF
      SET comparedviewreplycnt = (comparedviewreplycnt+ 1)
      SET stat = alterlist(reply->compared_views,comparedviewreplycnt)
      SET reply->compared_views[comparedviewreplycnt].br_datamart_category_id = tempcompare->
      br_datamart_category_id
      FOR (j = 1 TO size(tempcompare->reports,5))
        SET reply->compared_views[comparedviewreplycnt].reports.report_id = tempcompare->reports[j].
        report_id
        SET reply->compared_views[comparedviewreplycnt].reports.report_mean = tempcompare->reports[j]
        .report_mean
        SET reply->compared_views[comparedviewreplycnt].reports.report_name = tempcompare->reports[j]
        .report_name
        SET reply->compared_views[comparedviewreplycnt].reports.report_name_changed = tempcompare->
        reports[j].report_name_changed
        SET stat = alterlist(reply->compared_views[comparedviewreplycnt].reports.flags,size(
          tempcompare->reports[j].flags,5))
        FOR (k = 1 TO size(tempcompare->reports[j].flags,5))
          SET reply->compared_views[comparedviewreplycnt].reports.flags[k].flag_type = tempcompare->
          reports[j].flags[k].flag_type
        ENDFOR
        SET stat = alterlist(reply->compared_views[comparedviewreplycnt].reports.filters,size(
          tempcompare->reports[j].filters,5))
        FOR (p = 1 TO size(tempcompare->reports[j].filters,5))
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_category_mean =
          tempcompare->reports[j].filters[p].filter_category_mean
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_display =
          tempcompare->reports[j].filters[p].filter_display
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_id = tempcompare
          ->reports[j].filters[p].filter_id
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_mean =
          tempcompare->reports[j].filters[p].filter_mean
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_name_changed =
          tempcompare->reports[j].filters[p].filter_name_changed
          SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_seq = tempcompare
          ->reports[j].filters[p].filter_seq
          IF (validate(reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_limit)=1
          )
           SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_limit =
           tempcompare->reports[j].filters[p].filter_limit
          ENDIF
          IF (validate(reply->compared_views[comparedviewreplycnt].reports.filters[p].
           filter_limit_changed)=1)
           SET reply->compared_views[comparedviewreplycnt].reports.filters[p].filter_limit_changed =
           tempcompare->reports[j].filters[p].filter_limit_changed
          ENDIF
          SET stat = alterlist(reply->compared_views[comparedviewreplycnt].reports.filters[p].flags,
           size(tempcompare->reports[j].filters[p].flags,5))
          FOR (q = 1 TO size(tempcompare->reports[j].filters[p].flags,5))
            SET reply->compared_views[comparedviewreplycnt].reports.filters[p].flags[q].flag_type =
            tempcompare->reports[j].filters[p].flags[q].flag_type
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
   ELSE
    CALL logdebugmessage("categoriesCnt is invalid : ",categoriescnt)
   ENDIF
 END ;Subroutine
END GO
