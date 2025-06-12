CREATE PROGRAM bed_copy_mpage_settings:dba
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
 FREE RECORD getreportsreply
 RECORD getreportsreply(
   1 reports[*]
     2 br_datamart_report_id = f8
     2 report_name = vc
     2 report_mean = vc
     2 report_seq = i4
     2 text[*]
       3 text_type_mean = vc
       3 text = vc
       3 text_seq = i4
     2 baseline_value = vc
     2 target_value = vc
     2 mpage_pos_flag = i2
     2 mpage_pos_seq = i4
     2 selected_ind = i2
     2 cond_report_mean = vc
     2 mpage_default_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD ensreportlayoutrequest
 RECORD ensreportlayoutrequest(
   1 reports[*]
     2 br_datamart_report_id = f8
     2 mpage_pos_flag = i2
     2 mpage_pos_seq = i4
     2 flex_id = f8
     2 flex_types[*]
       3 parent_entity_value = f8
       3 parent_entity_name = vc
       3 parent_entity_type_flag = i2
     2 groups[*]
       3 parent_parent_entity_name = vc
       3 parent_parent_entity_id = f8
       3 parent_parent_entity_type_flag = i2
       3 child_parent_entity_name = vc
       3 child_parent_entity_id = f8
       3 child_parent_entity_type_flag = i2
   1 mpage_mode_flag = i2
 )
 FREE RECORD getflexesfortopicreply
 RECORD getflexesfortopicreply(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD flexids
 RECORD flexids(
   1 ids[*]
     2 flex_id = f8
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
 DECLARE copy_to_flexes_cnt = i4 WITH protect, constant(size(request->copy_to_flexes,5))
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE flexcnt = i4 WITH protect, noconstant(0)
 DECLARE isreportlayoutreqloaded = i2 WITH protect, noconstant(0)
 DECLARE isatleastoneflexnew = i2 WITH protect, noconstant(0)
 DECLARE selectedindloc = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE getreportstocopy(topicid=f8,fromflexid=f8) = i2
 DECLARE populategeneralreportinfo(dummyvar=i2) = i2
 DECLARE populateflextypesforallreports(pei=f8,pen=vc,petf=i4) = i2
 DECLARE populategroupsforallreports(ppei=f8,ppen=vc,ppetf=i4,cpei=f8,cpen=vc,
  cpetf=i4) = i2
 DECLARE ensurereportslayout(dummyvar=i2) = i2
 DECLARE getflexesfortopic(topicid=f8) = i2
 DECLARE populateflexidstosave(dummyvar=i2) = i2
 DECLARE ensurevalues(topicid=f8,reportid=f8,fromflexid=f8,toflexid=f8) = i2
 IF ((((request->br_datamart_category_id=0)) OR (copy_to_flexes_cnt=0)) )
  CALL bederror("Invalid request.")
 ENDIF
 FOR (flexcnt = 1 TO copy_to_flexes_cnt)
   IF ((request->copy_to_flexes[flexcnt].flex_types.parent_entity_id > 0))
    IF ( NOT (isreportlayoutreqloaded))
     CALL getreportstocopy(request->br_datamart_category_id,request->copy_from_flex_id)
     CALL populategeneralreportinfo(0)
    ENDIF
    CALL populateflextypesforallreports(request->copy_to_flexes[flexcnt].flex_types.parent_entity_id,
     request->copy_to_flexes[flexcnt].flex_types.parent_entity_name,request->copy_to_flexes[flexcnt].
     flex_types.parent_entity_type_flag)
    SET isatleastoneflexnew = true
   ELSEIF ((request->copy_to_flexes[flexcnt].groups.parent_parent_entity_id > 0))
    IF ( NOT (isreportlayoutreqloaded))
     CALL getreportstocopy(request->br_datamart_category_id,request->copy_from_flex_id)
     CALL populategeneralreportinfo(0)
    ENDIF
    CALL populategroupsforallreports(request->copy_to_flexes[flexcnt].groups.parent_parent_entity_id,
     request->copy_to_flexes[flexcnt].groups.parent_parent_entity_name,request->copy_to_flexes[
     flexcnt].groups.parent_parent_entity_type_flag,request->copy_to_flexes[flexcnt].groups.
     child_parent_entity_id,request->copy_to_flexes[flexcnt].groups.child_parent_entity_name,
     request->copy_to_flexes[flexcnt].groups.child_parent_entity_type_flag)
    SET isatleastoneflexnew = true
   ENDIF
 ENDFOR
 IF (isatleastoneflexnew)
  CALL ensurereportslayout(0)
  CALL getflexesfortopic(request->br_datamart_category_id)
 ENDIF
 IF ( NOT (isreportlayoutreqloaded))
  CALL getreportstocopy(request->br_datamart_category_id,request->copy_from_flex_id)
 ENDIF
 CALL populateflexidstosave(0)
 FOR (selrepidx = 1 TO size(request->reports,5))
   SET selectedindloc = 0
   SET selectedindloc = locateval(num1,1,size(getreportsreply->reports,5),1,getreportsreply->reports[
    num1].selected_ind)
   IF (selectedindloc > 0)
    FOR (flexcnt = 1 TO size(flexids->ids,5))
      CALL ensurevalues(request->br_datamart_category_id,request->reports[selrepidx].report_id,
       request->copy_from_flex_id,flexids->ids[flexcnt].flex_id)
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getreportstocopy(topicid,fromflexid)
   CALL bedlogmessage("getReportsToCopy","Entering...")
   FREE RECORD getreportsrequest
   RECORD getreportsrequest(
     1 br_datamart_category_id = f8
     1 flex_id = f8
     1 br_def_layout_ind = i2
   )
   SET getreportsrequest->br_datamart_category_id = topicid
   SET getreportsrequest->flex_id = fromflexid
   SET getreportsrequest->br_def_layout_ind = 0
   EXECUTE bed_get_dmart_reports_by_flex  WITH replace("REQUEST",getreportsrequest), replace("REPLY",
    getreportsreply)
   IF ((getreportsreply->status_data.status != "S"))
    CALL bederror("bed_get_dmart_reports_by_flex failed")
    IF (validate(debug,0)=1)
     CALL echorecord(getreportsrequest)
     CALL echorecord(getreportsreply)
    ENDIF
   ENDIF
   SET isreportlayoutreqloaded = true
   CALL bedlogmessage("getReportsToCopy","Exiting...")
 END ;Subroutine
 SUBROUTINE populategeneralreportinfo(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET ensreportlayoutrequest->mpage_mode_flag = 0
   FOR (r = 1 TO size(getreportsreply->reports,5))
     IF ((getreportsreply->reports[r].selected_ind=true))
      SET cnt = (cnt+ 1)
      SET stat = alterlist(ensreportlayoutrequest->reports,cnt)
      SET ensreportlayoutrequest->reports[cnt].br_datamart_report_id = getreportsreply->reports[r].
      br_datamart_report_id
      SET ensreportlayoutrequest->reports[cnt].mpage_pos_flag = getreportsreply->reports[r].
      mpage_pos_flag
      SET ensreportlayoutrequest->reports[cnt].mpage_pos_seq = getreportsreply->reports[r].
      mpage_pos_seq
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE populateflextypesforallreports(pei,pen,petf)
  DECLARE idx = i4 WITH protect, noconstant(0)
  FOR (ridx = 1 TO size(ensreportlayoutrequest->reports,5))
    SET idx = (size(ensreportlayoutrequest->reports[ridx].flex_types,5)+ 1)
    SET stat = alterlist(ensreportlayoutrequest->reports[ridx].flex_types,idx)
    SET ensreportlayoutrequest->reports[ridx].flex_types[idx].parent_entity_value = pei
    SET ensreportlayoutrequest->reports[ridx].flex_types[idx].parent_entity_name = pen
    SET ensreportlayoutrequest->reports[ridx].flex_types[idx].parent_entity_type_flag = petf
  ENDFOR
 END ;Subroutine
 SUBROUTINE populategroupsforallreports(ppei,ppen,ppetf,cpei,cpen,cpetf)
  DECLARE idx = i4 WITH protect, noconstant(0)
  FOR (ridx = 1 TO size(ensreportlayoutrequest->reports,5))
    SET idx = (size(ensreportlayoutrequest->reports[ridx].groups,5)+ 1)
    SET stat = alterlist(ensreportlayoutrequest->reports[ridx].groups,idx)
    SET ensreportlayoutrequest->reports[ridx].groups[idx].parent_parent_entity_id = ppei
    SET ensreportlayoutrequest->reports[ridx].groups[idx].parent_parent_entity_name = ppen
    SET ensreportlayoutrequest->reports[ridx].groups[idx].parent_parent_entity_type_flag = ppetf
    SET ensreportlayoutrequest->reports[ridx].groups[idx].child_parent_entity_id = cpei
    SET ensreportlayoutrequest->reports[ridx].groups[idx].child_parent_entity_name = cpen
    SET ensreportlayoutrequest->reports[ridx].groups[idx].child_parent_entity_type_flag = cpetf
  ENDFOR
 END ;Subroutine
 SUBROUTINE ensurereportslayout(dummyvar)
   CALL bedlogmessage("ensureReportsLayout","Entering...")
   FREE RECORD ensreportlayoutreply
   RECORD ensreportlayoutreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE bed_ens_datamart_report_val  WITH replace("REQUEST",ensreportlayoutrequest), replace(
    "REPLY",ensreportlayoutreply)
   IF ((ensreportlayoutreply->status_data.status != "S"))
    CALL bederror("bed_ens_datamart_report_val failed")
    IF (validate(debug,0)=1)
     CALL echorecord(ensreportlayoutrequest)
     CALL echorecord(ensreportlayoutreply)
    ENDIF
   ENDIF
   CALL bedlogmessage("ensureReportsLayout","Exiting...")
 END ;Subroutine
 SUBROUTINE getflexesfortopic(topicid)
   CALL bedlogmessage("getFlexesForTopic","Entering...")
   FREE RECORD getflexesfortopicrequest
   RECORD getflexesfortopicrequest(
     1 br_datamart_category_id = f8
   )
   SET getflexesfortopicrequest->br_datamart_category_id = topicid
   EXECUTE bed_get_datamart_flex_settings  WITH replace("REQUEST",getflexesfortopicrequest), replace(
    "REPLY",getflexesfortopicreply)
   IF ((getflexesfortopicreply->status_data.status != "S"))
    CALL bederror("bed_get_datamart_flex_settings failed")
    IF (validate(debug,0)=1)
     CALL echorecord(getflexesfortopicrequest)
     CALL echorecord(getflexesfortopicreply)
    ENDIF
   ENDIF
   CALL bedlogmessage("getFlexesForTopic","Exiting...")
 END ;Subroutine
 SUBROUTINE populateflexidstosave(dummyvar)
   CALL bedlogmessage("populateFlexIdsToSave","Entering...")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE flexsettingssize = i4 WITH protect, noconstant(size(getflexesfortopicreply->flex_settings,
     5))
   DECLARE flexgroupssize = i4 WITH protect, noconstant(size(getflexesfortopicreply->flex_groups,5))
   DECLARE foundloc = i4 WITH protect, noconstant(0)
   SET stat = alterlist(flexids->ids,copy_to_flexes_cnt)
   FOR (flexcnt = 1 TO copy_to_flexes_cnt)
     SET num = 0
     SET foundloc = 0
     IF ((request->copy_to_flexes[flexcnt].flex_id > 0))
      SET flexids->ids[flexcnt].flex_id = request->copy_to_flexes[flexcnt].flex_id
     ELSEIF ((request->copy_to_flexes[flexcnt].flex_types.parent_entity_id > 0))
      SET foundloc = locateval(num,1,flexsettingssize,request->copy_to_flexes[flexcnt].flex_types.
       parent_entity_id,getflexesfortopicreply->flex_settings[num].parent_entity_id,
       request->copy_to_flexes[flexcnt].flex_types.parent_entity_name,getflexesfortopicreply->
       flex_settings[num].parent_entity_name,request->copy_to_flexes[flexcnt].flex_types.
       parent_entity_type_flag,getflexesfortopicreply->flex_settings[num].parent_entity_type_flag)
      IF (foundloc > 0)
       SET flexids->ids[flexcnt].flex_id = getflexesfortopicreply->flex_settings[foundloc].flex_id
      ELSE
       SET stat = alterlist(flexids->ids,(size(flexids->ids,5) - 1))
      ENDIF
     ELSEIF ((request->copy_to_flexes[flexcnt].groups.parent_parent_entity_id > 0))
      SET foundloc = locateval(num,1,flexgroupssize,request->copy_to_flexes[flexcnt].groups.
       parent_parent_entity_id,getflexesfortopicreply->flex_groups[num].parent_flex.parent_entity_id,
       request->copy_to_flexes[flexcnt].groups.parent_parent_entity_name,getflexesfortopicreply->
       flex_groups[num].parent_flex.parent_entity_name,request->copy_to_flexes[flexcnt].groups.
       parent_parent_entity_type_flag,getflexesfortopicreply->flex_groups[num].parent_flex.
       parent_entity_type_flag,request->copy_to_flexes[flexcnt].groups.child_parent_entity_id,
       getflexesfortopicreply->flex_groups[num].child_flex.parent_entity_id,request->copy_to_flexes[
       flexcnt].groups.child_parent_entity_name,getflexesfortopicreply->flex_groups[num].child_flex.
       parent_entity_name,request->copy_to_flexes[flexcnt].groups.child_parent_entity_type_flag,
       getflexesfortopicreply->flex_groups[num].child_flex.parent_entity_type_flag)
      IF (foundloc > 0)
       SET flexids->ids[flexcnt].flex_id = getflexesfortopicreply->flex_groups[foundloc].child_flex.
       child_flex_id
      ELSE
       SET stat = alterlist(flexids->ids,(size(flexids->ids,5) - 1))
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateFlexIdsToSave","Exiting...")
 END ;Subroutine
 SUBROUTINE ensurevalues(topicid,reportid,fromflexid,toflexid)
   CALL bedlogmessage("ensureValues","Entering...")
   FREE RECORD getfiltersrequest
   RECORD getfiltersrequest(
     1 br_datamart_category_id = f8
     1 br_datamart_report_id = f8
     1 flex_id = f8
   )
   FREE RECORD getfiltersreply
   RECORD getfiltersreply(
     1 filter[*]
       2 br_datamart_filter_id = f8
       2 filter_mean = vc
       2 filter_display = vc
       2 filter_seq = i4
       2 denominator_ind = i2
       2 numerator_ind = i2
       2 filter_category_mean = vc
       2 text[*]
         3 text_type_mean = vc
         3 text = vc
         3 text_seq = i4
       2 defined_ind = i2
       2 mpage_label_ind = i2
       2 mpage_nbr_label_ind = i2
       2 mpage_link_ind = i2
       2 mpage_exp_collapse_ind = i2
       2 mpage_lookback_ind = i2
       2 mpage_max_results_ind = i2
       2 mpage_scroll_ind = i2
       2 mpage_truncate_ind = i2
       2 mpage_add_label_ind = i2
       2 filter_category_type_mean = vc
       2 codeset = i4
       2 filter_limit = i4
       2 mpage_date_format_ind = i2
       2 value_set_id = f8
       2 secondary_value_set_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET getfiltersrequest->br_datamart_category_id = topicid
   SET getfiltersrequest->br_datamart_report_id = reportid
   SET getfiltersrequest->flex_id = fromflexid
   CALL bedlogmessage("ensureValues","Executing bed_get_datamart_filters...")
   EXECUTE bed_get_datamart_filters  WITH replace("REQUEST",getfiltersrequest), replace("REPLY",
    getfiltersreply)
   IF ((getfiltersreply->status_data.status != "S"))
    CALL bederror("bed_get_datamart_filters failed")
    IF (validate(debug,0)=1)
     CALL echorecord(getfiltersrequest)
     CALL echorecord(getfiltersreply)
    ENDIF
   ENDIF
   IF (size(getfiltersreply->filter,5) > 0)
    FREE RECORD getvaluesrequest
    RECORD getvaluesrequest(
      1 br_datamart_category_id = f8
      1 filter[*]
        2 br_datamart_filter_id = f8
      1 flex_id = f8
    )
    FREE RECORD getvaluesreply
    RECORD getvaluesreply(
      1 filter[*]
        2 br_datamart_filter_id = f8
        2 value[*]
          3 parent_entity_name = vc
          3 parent_entity_id = f8
          3 value_dt_tm = dq8
          3 freetext_desc = vc
          3 qualifier_flag = i2
          3 value_seq = i4
          3 value_type_flag = i2
          3 group_seq = i4
          3 mpage_param_mean = vc
          3 mpage_param_value = vc
          3 parent_entity_name2 = vc
          3 parent_entity_id2 = f8
          3 map_data_type_cd = f8
          3 map_data_type_meaning = vc
          3 map_data_type_display = vc
          3 filter_description = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET getvaluesrequest->br_datamart_category_id = topicid
    SET getvaluesrequest->flex_id = fromflexid
    SET stat = alterlist(getvaluesrequest->filter,size(getfiltersreply->filter,5))
    FOR (k = 1 TO size(getfiltersreply->filter,5))
      SET getvaluesrequest->filter[k].br_datamart_filter_id = getfiltersreply->filter[k].
      br_datamart_filter_id
    ENDFOR
    CALL bedlogmessage("ensureValues","Executing bed_get_datamart_values...")
    EXECUTE bed_get_datamart_values  WITH replace("REQUEST",getvaluesrequest), replace("REPLY",
     getvaluesreply)
    IF ((getvaluesreply->status_data.status != "S"))
     CALL bederror("bed_get_datamart_values failed")
     IF (validate(debug,0)=1)
      CALL echorecord(getvaluesrequest)
      CALL echorecord(getvaluesreply)
     ENDIF
    ENDIF
    IF (size(getvaluesreply->filter,5) > 0)
     FREE RECORD ensvaluesrequest
     RECORD ensvaluesrequest(
       1 br_datamart_category_id = f8
       1 br_datamart_report_id = f8
       1 baseline_value = vc
       1 target_value = vc
       1 filter[*]
         2 br_datamart_filter_id = f8
         2 filter_mean = vc
         2 value[*]
           3 parent_entity_id = f8
           3 value_dt_tm = dq8
           3 freetext_desc = vc
           3 qualifier_flag = i2
           3 value_seq = i4
           3 value_type_flag = i2
           3 group_seq = i4
           3 mpage_param_mean = vc
           3 mpage_param_value = vc
           3 parent_entity_id2 = f8
           3 map_data_type_cd = f8
           3 parent_entity_name = vc
           3 parent_entity_name2 = vc
         2 flex_id = f8
         2 flex_types[*]
           3 parent_entity_name = vc
           3 parent_entity_id = f8
           3 parent_entity_type_flag = i2
         2 groups[*]
           3 parent_parent_entity_name = vc
           3 parent_parent_entity_id = f8
           3 parent_parent_entity_type_flag = i2
           3 child_parent_entity_name = vc
           3 child_parent_entity_id = f8
           3 child_parent_entity_type_flag = i2
     )
     FREE RECORD ensvaluesreply
     RECORD ensvaluesreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET ensvaluesrequest->br_datamart_category_id = topicid
     SET stat = alterlist(ensvaluesrequest->filter,size(getvaluesreply->filter,5))
     FOR (i = 1 TO size(getvaluesreply->filter,5))
       SET ensvaluesrequest->filter[i].br_datamart_filter_id = getvaluesreply->filter[i].
       br_datamart_filter_id
       SET ensvaluesrequest->filter[i].flex_id = toflexid
       SET stat = alterlist(ensvaluesrequest->filter[i].value,size(getvaluesreply->filter[i].value,5)
        )
       FOR (v = 1 TO size(getvaluesreply->filter[i].value,5))
         SET ensvaluesrequest->filter[i].value[v].parent_entity_id = getvaluesreply->filter[i].value[
         v].parent_entity_id
         SET ensvaluesrequest->filter[i].value[v].value_dt_tm = getvaluesreply->filter[i].value[v].
         value_dt_tm
         SET ensvaluesrequest->filter[i].value[v].freetext_desc = getvaluesreply->filter[i].value[v].
         freetext_desc
         SET ensvaluesrequest->filter[i].value[v].qualifier_flag = getvaluesreply->filter[i].value[v]
         .qualifier_flag
         SET ensvaluesrequest->filter[i].value[v].value_seq = getvaluesreply->filter[i].value[v].
         value_seq
         SET ensvaluesrequest->filter[i].value[v].group_seq = getvaluesreply->filter[i].value[v].
         group_seq
         SET ensvaluesrequest->filter[i].value[v].mpage_param_mean = getvaluesreply->filter[i].value[
         v].mpage_param_mean
         SET ensvaluesrequest->filter[i].value[v].mpage_param_value = getvaluesreply->filter[i].
         value[v].mpage_param_value
         SET ensvaluesrequest->filter[i].value[v].parent_entity_id2 = getvaluesreply->filter[i].
         value[v].parent_entity_id2
         SET ensvaluesrequest->filter[i].value[v].map_data_type_cd = getvaluesreply->filter[i].value[
         v].map_data_type_cd
         SET ensvaluesrequest->filter[i].value[v].parent_entity_name = getvaluesreply->filter[i].
         value[v].parent_entity_name
         SET ensvaluesrequest->filter[i].value[v].parent_entity_name2 = getvaluesreply->filter[i].
         value[v].parent_entity_name2
         SET ensvaluesrequest->filter[i].value[v].value_type_flag = getvaluesreply->filter[i].value[v
         ].value_type_flag
       ENDFOR
     ENDFOR
     CALL bedlogmessage("ensureValues","Executing bed_ens_datamart_values...")
     EXECUTE bed_ens_datamart_values  WITH replace("REQUEST",ensvaluesrequest), replace("REPLY",
      ensvaluesreply)
     IF ((ensvaluesreply->status_data.status != "S"))
      CALL bederror("bed_get_datamart_values failed")
      IF (validate(debug,0)=1)
       CALL echorecord(ensvaluesrequest)
       CALL echorecord(ensvaluesreply)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL bedlogmessage("ensureValues","Exiting...")
 END ;Subroutine
END GO
