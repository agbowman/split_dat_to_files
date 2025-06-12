CREATE PROGRAM bed_get_mpage_reports_with_ind:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 components_with_ind[*]
      2 report_mean = vc
      2 content_do_not_match_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(getcategoriesreq,0)))
  RECORD getcategoriesreq(
    1 report_mean = vc
  )
 ENDIF
 IF ( NOT (validate(getcategoriesrep,0)))
  RECORD getcategoriesrep(
    1 views[*]
      2 br_datamart_category_id = f8
      2 category_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(tempcomparereq,0)))
  RECORD tempcomparereq(
    1 br_datamart_category_id = f8
    1 req_report_mean = vc
  )
 ENDIF
 IF ( NOT (validate(tempcomparerep,0)))
  RECORD tempcomparerep(
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
 DECLARE components_size = i4 WITH protect, constant(size(request->components,5))
 DECLARE getreportswithindicator(dummyvar=i2) = null
 IF (components_size > 0)
  CALL getreportswithindicator(0)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getreportswithindicator(dummyvar)
   CALL bedlogmessage("getReportCategories","Entering ...")
   DECLARE compcnt = i4 WITH protect, noconstant(0)
   DECLARE catcnt = i4 WITH protect, noconstant(0)
   DECLARE reportcnt = i4 WITH protect, noconstant(0)
   DECLARE filtercnt = i4 WITH protect, noconstant(0)
   DECLARE categoriessize = i4 WITH protect, noconstant(0)
   DECLARE do_not_match_content_ind = i2 WITH protect, noconstant(0)
   FOR (compcnt = 1 TO components_size)
     SET do_not_match_content_ind = 0
     SET getcategoriesreq->report_mean = request->components[compcnt].report_mean
     CALL logdebugmessage("Report Mean to be evaluated: ",getcategoriesreq->report_mean)
     SET stat = initrec(getcategoriesrep)
     EXECUTE bed_get_report_categories  WITH replace("REQUEST",getcategoriesreq), replace("REPLY",
      getcategoriesrep)
     IF ((getcategoriesrep->status_data.status != "S"))
      CALL bederror("bed_get_report_categories did not return success")
      CALL logdebugmessage("bed_get_report_categories failed for report_mean : ",getcategoriesreq->
       report_mean)
     ENDIF
     SET tempcomparereq->req_report_mean = getcategoriesreq->report_mean
     FOR (catcnt = 1 TO size(getcategoriesrep->views,5))
       SET tempcomparereq->br_datamart_category_id = getcategoriesrep->views[catcnt].
       br_datamart_category_id
       CALL logdebugmessage("Category ID to be evaluated: ",tempcomparereq->br_datamart_category_id)
       SET stat = initrec(tempcomparerep)
       EXECUTE bed_compare_mpage_content  WITH replace("REQUEST",tempcomparereq), replace("REPLY",
        tempcomparerep)
       IF ((tempcomparerep->status_data.status != "S"))
        CALL bederror("bed_compare_mpage_content did not return success")
        CALL logdebugmessage("tempCompareReq->br_datamart_category_id : ",tempcomparereq->
         br_datamart_category_id)
       ENDIF
       FOR (reportcnt = 1 TO size(tempcomparerep->reports,5))
         IF (size(tempcomparerep->reports[reportcnt].flags,5) > 0)
          SET do_not_match_content_ind = 1
          CALL logdebugmessage("Report flag found: ",tempcomparerep->reports[reportcnt].report_name)
          SET reportcnt = (size(tempcomparerep->reports,5)+ 1)
          CALL logdebugmessage("Report count set to: ",reportcnt)
         ELSE
          FOR (filtercnt = 1 TO size(tempcomparerep->reports[reportcnt].filters,5))
            IF (size(tempcomparerep->reports[reportcnt].filters[filtercnt].flags,5) > 0)
             SET do_not_match_content_ind = 1
             CALL logdebugmessage("Filter flag found for report: ",tempcomparerep->reports[reportcnt]
              .report_name)
             CALL logdebugmessage("Filter flag found for filter: ",tempcomparerep->reports[reportcnt]
              .filters[filtercnt].filter_display)
             SET filtercnt = (size(tempcomparerep->reports[reportcnt].filters,5)+ 1)
             SET reportcnt = (size(tempcomparerep->reports,5)+ 1)
             CALL logdebugmessage("Report count set to: ",reportcnt)
             CALL logdebugmessage("Filter count set to: ",filtercnt)
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       CALL logdebugmessage("Do not match ind: ",do_not_match_content_ind)
       IF (do_not_match_content_ind=1)
        SET catcnt = (size(getcategoriesrep->views,5)+ 1)
        CALL logdebugmessage("Do not match found and catCnt set to: ",catcnt)
       ENDIF
     ENDFOR
     SET stat = alterlist(reply->components_with_ind,compcnt)
     SET reply->components_with_ind[compcnt].report_mean = request->components[compcnt].report_mean
     SET reply->components_with_ind[compcnt].content_do_not_match_ind = do_not_match_content_ind
   ENDFOR
   CALL bedlogmessage("getReportCategories","Exiting ...")
 END ;Subroutine
END GO
