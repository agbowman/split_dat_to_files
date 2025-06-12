CREATE PROGRAM bed_compare_mpage_content:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 FREE RECORD std_content_list
 RECORD std_content_list(
   1 reports[*]
     2 report_id = f8
     2 report_mean = vc
     2 report_name = vc
     2 filters[*]
       3 filter_id = f8
       3 filter_mean = vc
       3 filter_category_mean = vc
       3 filter_display = vc
       3 filter_seq = i4
       3 filter_limit = i4
 ) WITH protect
 FREE RECORD view_comp_list
 RECORD view_comp_list(
   1 reports[*]
     2 report_id = f8
     2 report_mean = vc
     2 report_name = vc
     2 filters[*]
       3 filter_id = f8
       3 filter_mean = vc
       3 filter_category_mean = vc
       3 filter_display = vc
       3 filter_seq = i4
       3 filter_limit = i4
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
 SUBROUTINE addcomponentflag(pos,flag_type)
   DECLARE flag_list_size = i4 WITH protect, noconstant(0)
   SET flag_list_size = (size(reply->reports[pos].flags,5)+ 1)
   SET stat = alterlist(reply->reports[pos].flags,flag_list_size)
   SET reply->reports[pos].flags[flag_list_size].flag_type = flag_type
   CALL bederrorcheck("addComponentFlag error")
 END ;Subroutine
 SUBROUTINE addfilterflag(rep_pos,fil_pos,flag_type)
   DECLARE flag_list_size = i4 WITH protect, noconstant(0)
   SET flag_list_size = (size(reply->reports[rep_pos].filters[fil_pos].flags,5)+ 1)
   SET stat = alterlist(reply->reports[rep_pos].filters[fil_pos].flags,flag_list_size)
   SET reply->reports[rep_pos].filters[fil_pos].flags[flag_list_size].flag_type = flag_type
   CALL bederrorcheck("addFilterFlag error")
 END ;Subroutine
 SUBROUTINE populatecomponentlists(req_category_id,req_report_mean)
   DECLARE report_cnt = i4 WITH protect, noconstant(0)
   DECLARE filter_cnt = i4 WITH protect, noconstant(0)
   DECLARE parse_report_mean = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM br_datamart_category bdc,
     br_datamart_report bdr,
     br_datamart_report_filter_r bdrfr,
     br_datamart_filter bdf
    PLAN (bdc
     WHERE bdc.category_type_flag=standard_content_type_flag)
     JOIN (bdr
     WHERE bdr.br_datamart_category_id=bdc.br_datamart_category_id)
     JOIN (bdrfr
     WHERE bdrfr.br_datamart_report_id=outerjoin(bdr.br_datamart_report_id))
     JOIN (bdf
     WHERE bdf.br_datamart_filter_id=outerjoin(bdrfr.br_datamart_filter_id))
    ORDER BY bdr.report_mean, bdf.filter_seq, bdf.filter_display
    HEAD bdr.br_datamart_report_id
     report_cnt = (report_cnt+ 1), filter_cnt = 0, stat = alterlist(std_content_list->reports,
      report_cnt),
     std_content_list->reports[report_cnt].report_id = bdr.br_datamart_report_id, std_content_list->
     reports[report_cnt].report_name = bdr.report_name, std_content_list->reports[report_cnt].
     report_mean = bdr.report_mean
    HEAD bdf.br_datamart_filter_id
     filter_cnt = (filter_cnt+ 1), stat = alterlist(std_content_list->reports[report_cnt].filters,
      filter_cnt), std_content_list->reports[report_cnt].filters[filter_cnt].filter_id = bdf
     .br_datamart_filter_id,
     std_content_list->reports[report_cnt].filters[filter_cnt].filter_mean = bdf.filter_mean,
     std_content_list->reports[report_cnt].filters[filter_cnt].filter_display = bdf.filter_display,
     std_content_list->reports[report_cnt].filters[filter_cnt].filter_seq = bdf.filter_seq,
     std_content_list->reports[report_cnt].filters[filter_cnt].filter_category_mean = bdf
     .filter_category_mean, std_content_list->reports[report_cnt].filters[filter_cnt].filter_limit =
     bdf.filter_limit
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echo("***std_content_list:***")
    CALL echorecord(std_content_list)
   ENDIF
   SET report_cnt = 0
   SET filter_cnt = 0
   SET parse_report_mean = "bdr.br_datamart_category_id = req_category_id"
   IF (req_report_mean > "")
    SET parse_report_mean = concat(parse_report_mean,' and bdr.report_mean = "',req_report_mean,'"')
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_report bdr
    PLAN (bdr
     WHERE parser(parse_report_mean))
    ORDER BY bdr.report_mean
    HEAD bdr.br_datamart_report_id
     report_cnt = (report_cnt+ 1), stat = alterlist(view_comp_list->reports,report_cnt),
     view_comp_list->reports[report_cnt].report_id = bdr.br_datamart_report_id,
     view_comp_list->reports[report_cnt].report_name = bdr.report_name, view_comp_list->reports[
     report_cnt].report_mean = bdr.report_mean
    WITH nocounter
   ;end select
   FOR (x = 1 TO report_cnt)
    SET filter_cnt = 0
    SELECT INTO "nl:"
     FROM br_datamart_report_filter_r bdrfr,
      br_datamart_filter bdf
     PLAN (bdrfr
      WHERE (bdrfr.br_datamart_report_id=view_comp_list->reports[x].report_id))
      JOIN (bdf
      WHERE bdf.br_datamart_filter_id=bdrfr.br_datamart_filter_id)
     ORDER BY bdf.filter_seq, bdf.filter_display
     HEAD bdf.br_datamart_filter_id
      filter_cnt = (filter_cnt+ 1), stat = alterlist(view_comp_list->reports[x].filters,filter_cnt),
      view_comp_list->reports[x].filters[filter_cnt].filter_id = bdf.br_datamart_filter_id,
      view_comp_list->reports[x].filters[filter_cnt].filter_mean = bdf.filter_mean, view_comp_list->
      reports[x].filters[filter_cnt].filter_display = bdf.filter_display, view_comp_list->reports[x].
      filters[filter_cnt].filter_seq = bdf.filter_seq,
      view_comp_list->reports[x].filters[filter_cnt].filter_category_mean = bdf.filter_category_mean,
      view_comp_list->reports[x].filters[filter_cnt].filter_limit = bdf.filter_limit
     WITH nocounter
    ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echo("***view_comp_list:***")
    CALL echorecord(view_comp_list)
   ENDIF
   CALL bederrorcheck("populateComponentLists error")
 END ;Subroutine
 SUBROUTINE checkforchangedcomponentnames(std_comp_pos,curr_view_pos,reply_pos)
  IF ((std_content_list->reports[std_comp_pos].report_name != view_comp_list->reports[curr_view_pos].
  report_name))
   SET reply->reports[reply_pos].report_name_changed = std_content_list->reports[std_comp_pos].
   report_name
   CALL addcomponentflag(reply_pos,component_name_changed_flag)
  ENDIF
  CALL bederrorcheck("changedComponentNames error")
 END ;Subroutine
 SUBROUTINE checkforchangedcomponenttext(std_comp_pos,curr_view_pos,reply_pos)
   FREE RECORD std_report_text
   RECORD std_report_text(
     1 report_text[*]
       2 text_type_mean = vc
       2 long_text = vc
   ) WITH protect
   DECLARE std_text_cnt = i4 WITH protect, noconstant(0)
   DECLARE found_updated_text = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_report bdr,
     br_datamart_text bdt,
     br_long_text blt
    PLAN (bdr
     WHERE (bdr.br_datamart_report_id=std_content_list->reports[std_comp_pos].report_id))
     JOIN (bdt
     WHERE bdt.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdt.br_datamart_report_id=bdr.br_datamart_report_id
      AND bdt.br_datamart_filter_id=0.0)
     JOIN (blt
     WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
      AND blt.parent_entity_id=bdt.br_datamart_text_id)
    ORDER BY blt.long_text_id
    DETAIL
     std_text_cnt = (std_text_cnt+ 1), stat = alterlist(std_report_text->report_text,std_text_cnt),
     std_report_text->report_text[std_text_cnt].text_type_mean = bdt.text_type_mean,
     std_report_text->report_text[std_text_cnt].long_text = blt.long_text
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(std_report_text)
   ENDIF
   IF (std_text_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(std_text_cnt)),
      br_datamart_report bdr,
      br_datamart_text bdt,
      br_long_text blt
     PLAN (d)
      JOIN (bdr
      WHERE (bdr.br_datamart_report_id=view_comp_list->reports[curr_view_pos].report_id))
      JOIN (bdt
      WHERE bdt.br_datamart_category_id=bdr.br_datamart_category_id
       AND bdt.br_datamart_report_id=bdr.br_datamart_report_id
       AND bdt.br_datamart_filter_id=0.0
       AND (bdt.text_type_mean=std_report_text->report_text[d.seq].text_type_mean))
      JOIN (blt
      WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
       AND blt.parent_entity_id=bdt.br_datamart_text_id)
     ORDER BY blt.long_text_id
     DETAIL
      IF ((std_report_text->report_text[d.seq].text_type_mean="PREREQ"))
       IF ((blt.long_text != std_report_text->report_text[d.seq].long_text))
        IF (validate(debug,0)=1)
         CALL echo(build(blt.long_text,"---does not match---",std_report_text->report_text[d.seq].
          long_text))
        ENDIF
        found_updated_text = 1
       ENDIF
      ELSE
       IF (d.seq=bdt.text_seq)
        IF ((blt.long_text != std_report_text->report_text[d.seq].long_text))
         IF (validate(debug,0)=1)
          CALL echo(build(blt.long_text,"---does not match---",std_report_text->report_text[d.seq].
           long_text))
         ENDIF
         found_updated_text = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (found_updated_text=1)
     CALL addcomponentflag(reply_pos,component_text_changed_flag)
    ENDIF
   ENDIF
   CALL bederrorcheck("changedComponentText error")
 END ;Subroutine
 SUBROUTINE checkforchangedcomponentreportdefaults(std_comp_pos,curr_view_pos,reply_pos)
   DECLARE defaults_changed = i2 WITH protect, noconstant(0)
   DECLARE std_content_rpt_default_cnt = i4 WITH protect, noconstant(0)
   DECLARE curr_view_rpt_default_cnt = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE contains = i4 WITH protect, noconstant(0)
   FREE RECORD report_defaults_std_content
   RECORD report_defaults_std_content(
     1 report_defaults[*]
       2 mpage_param_mean = vc
       2 mpage_param_value = vc
   ) WITH protect
   FREE RECORD report_defaults_view
   RECORD report_defaults_view(
     1 report_defaults[*]
       2 mpage_param_mean = vc
       2 mpage_param_value = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_datamart_report_default bdrd
    PLAN (bdrd
     WHERE (bdrd.br_datamart_report_id=std_content_list->reports[std_comp_pos].report_id))
    ORDER BY bdrd.mpage_param_mean
    DETAIL
     std_content_rpt_default_cnt = (std_content_rpt_default_cnt+ 1), stat = alterlist(
      report_defaults_std_content->report_defaults,std_content_rpt_default_cnt),
     report_defaults_std_content->report_defaults[std_content_rpt_default_cnt].mpage_param_mean =
     bdrd.mpage_param_mean,
     report_defaults_std_content->report_defaults[std_content_rpt_default_cnt].mpage_param_value =
     bdrd.mpage_param_value
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(report_defaults_std_content)
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_report_default bdrd
    PLAN (bdrd
     WHERE (bdrd.br_datamart_report_id=view_comp_list->reports[curr_view_pos].report_id))
    ORDER BY bdrd.mpage_param_mean
    DETAIL
     curr_view_rpt_default_cnt = (curr_view_rpt_default_cnt+ 1), stat = alterlist(
      report_defaults_view->report_defaults,curr_view_rpt_default_cnt), report_defaults_view->
     report_defaults[curr_view_rpt_default_cnt].mpage_param_mean = bdrd.mpage_param_mean,
     report_defaults_view->report_defaults[curr_view_rpt_default_cnt].mpage_param_value = bdrd
     .mpage_param_value
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(report_defaults_view)
   ENDIF
   IF (size(report_defaults_std_content->report_defaults,5) != size(report_defaults_view->
    report_defaults,5))
    SET defaults_changed = 1
    IF (validate(debug,0)=1)
     CALL echo("Sizes of report default lists are different")
     CALL echorecord(report_defaults_std_content)
     CALL echorecord(report_defaults_view)
    ENDIF
   ELSE
    FOR (x = 1 TO size(report_defaults_std_content->report_defaults,5))
     SET contains = locateval(y,1,size(report_defaults_view->report_defaults,5),
      report_defaults_std_content->report_defaults[x].mpage_param_mean,report_defaults_view->
      report_defaults[y].mpage_param_mean)
     IF (contains=0)
      SET defaults_changed = 1
      IF (validate(debug,0)=1)
       CALL echo("A standard content report default is not contained in the view report defaults")
       CALL echo(build("Missing component:",report_defaults_std_content->report_defaults[x].
         mpage_param_mean))
      ENDIF
     ELSE
      IF ((report_defaults_std_content->report_defaults[x].mpage_param_value != report_defaults_view
      ->report_defaults[contains].mpage_param_value))
       SET defaults_changed = 1
       IF (validate(debug,0)=1)
        CALL echo("Two report defaults with matching means do not have matching values")
        CALL echo(build("Mean:",report_defaults_std_content->report_defaults[x].mpage_param_mean))
        CALL echo(build("Value 1:",report_defaults_std_content->report_defaults[x].mpage_param_value)
         )
        CALL echo(build("Value 2:",report_defaults_view->report_defaults[contains].mpage_param_value)
         )
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (defaults_changed=1)
    CALL addcomponentflag(reply_pos,component_report_defaults_changed_flag)
   ENDIF
   CALL bederrorcheck("changedComponentReportDefaults error")
 END ;Subroutine
 SUBROUTINE checkforaddedfilters(std_report_pos,curr_report_pos)
   DECLARE curr_filter_pos = i4 WITH protect, noconstant(0)
   DECLARE filter_added = i2 WITH protect, noconstant(0)
   DECLARE fil_add_loc = i4 WITH protect, noconstant(0)
   FOR (k = 1 TO size(std_content_list->reports[std_report_pos].filters,5))
    SET fil_add_loc = locateval(curr_filter_pos,1,size(view_comp_list->reports[curr_report_pos].
      filters,5),std_content_list->reports[std_report_pos].filters[k].filter_mean,view_comp_list->
     reports[curr_report_pos].filters[curr_filter_pos].filter_mean)
    IF (fil_add_loc=0
     AND (std_content_list->reports[std_report_pos].filters[k].filter_id > 0.0))
     SET filter_size = size(reply->reports[report_size].filters,5)
     SET filter_size = (filter_size+ 1)
     SET stat = alterlist(reply->reports[report_size].filters,filter_size)
     SET reply->reports[report_size].filters[filter_size].filter_id = std_content_list->reports[
     std_report_pos].filters[k].filter_id
     SET reply->reports[report_size].filters[filter_size].filter_mean = std_content_list->reports[
     std_report_pos].filters[k].filter_mean
     SET reply->reports[report_size].filters[filter_size].filter_category_mean = std_content_list->
     reports[std_report_pos].filters[k].filter_category_mean
     SET reply->reports[report_size].filters[filter_size].filter_display = std_content_list->reports[
     std_report_pos].filters[k].filter_display
     SET reply->reports[report_size].filters[filter_size].filter_seq = std_content_list->reports[
     std_report_pos].filters[k].filter_seq
     CALL addfilterflag(report_size,filter_size,filter_added_flag)
     SET filter_added = 1
    ENDIF
   ENDFOR
   CALL bederrorcheck("addedFilters error")
   RETURN(filter_added)
 END ;Subroutine
 SUBROUTINE checkforresequencedfilters(std_comp_pos,curr_view_pos,reply_pos)
   DECLARE filter_seq_changed = i2 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE current_filter_mean = vc WITH protect
   IF (size(view_comp_list->reports[curr_view_pos].filters,5)=size(std_content_list->reports[
    std_comp_pos].filters,5))
    FOR (j = 1 TO size(view_comp_list->reports[curr_view_pos].filters,5))
      IF ((std_content_list->reports[std_comp_pos].filters[j].filter_mean != view_comp_list->reports[
      curr_view_pos].filters[j].filter_mean))
       SET filter_seq_changed = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (filter_seq_changed=1)
    CALL addcomponentflag(reply_pos,filter_list_resequenced_flag)
   ENDIF
   CALL bederrorcheck("resequencedFilters error")
 END ;Subroutine
 SUBROUTINE checkforfilterdefaultschanged(std_comp_pos,std_fil_pos,curr_comp_pos,curr_fil_pos,
  reply_pos,filter_pos)
   DECLARE fil_def_std_size = i4 WITH protect, noconstant(0)
   DECLARE fil_def_view_size = i4 WITH protect, noconstant(0)
   DECLARE filter_defaults_changed = i2 WITH protect, noconstant(0)
   DECLARE i = i2 WITH protect, noconstant(0)
   DECLARE j = i2 WITH protect, noconstant(0)
   FREE RECORD filter_defaults_std_content
   RECORD filter_defaults_std_content(
     1 filter_defaults[*]
       2 filter_mean = vc
       2 unique_identifier = vc
       2 cv_display = vc
   ) WITH protect
   FREE RECORD filter_defaults_view
   RECORD filter_defaults_view(
     1 filter_defaults[*]
       2 filter_mean = vc
       2 unique_identifier = vc
       2 cv_display = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_datamart_filter bdf,
     br_datamart_default bdd
    PLAN (bdf
     WHERE (bdf.br_datamart_filter_id=std_content_list->reports[std_comp_pos].filters[std_fil_pos].
     filter_id))
     JOIN (bdd
     WHERE bdd.br_datamart_filter_id=bdf.br_datamart_filter_id)
    ORDER BY bdf.filter_mean, bdd.unique_identifier, bdd.cv_display
    DETAIL
     fil_def_std_size = (fil_def_std_size+ 1), stat = alterlist(filter_defaults_std_content->
      filter_defaults,fil_def_std_size), filter_defaults_std_content->filter_defaults[
     fil_def_std_size].filter_mean = bdf.filter_mean,
     filter_defaults_std_content->filter_defaults[fil_def_std_size].unique_identifier = bdd
     .unique_identifier, filter_defaults_std_content->filter_defaults[fil_def_std_size].cv_display =
     bdd.cv_display
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM br_datamart_filter bdf,
     br_datamart_default bdd
    PLAN (bdf
     WHERE (bdf.br_datamart_filter_id=view_comp_list->reports[curr_comp_pos].filters[curr_fil_pos].
     filter_id))
     JOIN (bdd
     WHERE bdd.br_datamart_filter_id=bdf.br_datamart_filter_id)
    ORDER BY bdf.filter_mean, bdd.unique_identifier, bdd.cv_display
    DETAIL
     fil_def_view_size = (fil_def_view_size+ 1), stat = alterlist(filter_defaults_view->
      filter_defaults,fil_def_view_size), filter_defaults_view->filter_defaults[fil_def_view_size].
     filter_mean = bdf.filter_mean,
     filter_defaults_view->filter_defaults[fil_def_view_size].unique_identifier = bdd
     .unique_identifier, filter_defaults_view->filter_defaults[fil_def_view_size].cv_display = bdd
     .cv_display
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(filter_defaults_std_content)
    CALL echorecord(filter_defaults_view)
   ENDIF
   IF (fil_def_std_size != fil_def_view_size)
    IF (validate(debug,0)=1)
     CALL echo("Size does not match")
    ENDIF
    SET filter_defaults_changed = 1
   ENDIF
   FOR (i = 1 TO size(filter_defaults_view->filter_defaults,5))
     IF (filter_defaults_changed=0)
      IF ((((filter_defaults_view->filter_defaults[i].cv_display != filter_defaults_std_content->
      filter_defaults[i].cv_display)) OR ((((filter_defaults_view->filter_defaults[i].
      unique_identifier != filter_defaults_std_content->filter_defaults[i].unique_identifier)) OR ((
      filter_defaults_view->filter_defaults[i].filter_mean != filter_defaults_std_content->
      filter_defaults[i].filter_mean))) )) )
       IF (validate(debug,0)=1)
        CALL echo(build(
          "Either cv_display, unique_identifier, or filter_mean has been changed for struct entry:",i
          ))
       ENDIF
       SET filter_defaults_changed = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (filter_defaults_changed=1)
    CALL addfilterflag(reply_pos,filter_pos,filter_content_recommendations_changed_flag)
   ENDIF
   CALL bederrorcheck("resequencedFilters error")
 END ;Subroutine
 SUBROUTINE checkforchangedfilternames(std_rep_comp_pos,curr_rep_view_pos,std_comp_pos,curr_view_pos,
  rep_reply_pos,reply_pos)
  IF ((std_content_list->reports[std_rep_comp_pos].filters[std_comp_pos].filter_display !=
  view_comp_list->reports[curr_rep_view_pos].filters[curr_view_pos].filter_display))
   SET reply->reports[rep_reply_pos].filters[reply_pos].filter_name_changed = std_content_list->
   reports[std_rep_comp_pos].filters[std_comp_pos].filter_display
   CALL addfilterflag(rep_reply_pos,reply_pos,filter_name_changed_flag)
  ENDIF
  CALL bederrorcheck("changedFilterNames error")
 END ;Subroutine
 SUBROUTINE checkforchangedfiltertext(std_comp_rep_pos,curr_view_rep_pos,std_comp_fil_pos,
  curr_view_fil_pos,rep_reply_pos,fil_reply_pos)
   FREE RECORD std_filter_text
   RECORD std_filter_text(
     1 filter_text[*]
       2 text_type_mean = vc
       2 long_text = vc
   ) WITH protect
   DECLARE std_text_cnt = i4 WITH protect, noconstant(0)
   DECLARE found_updated_text = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_filter bdf,
     br_datamart_text bdt,
     br_long_text blt
    PLAN (bdf
     WHERE (bdf.br_datamart_filter_id=std_content_list->reports[std_comp_rep_pos].filters[
     std_comp_fil_pos].filter_id))
     JOIN (bdt
     WHERE bdt.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdt.br_datamart_report_id=0.0
      AND bdt.br_datamart_filter_id=bdf.br_datamart_filter_id)
     JOIN (blt
     WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
      AND blt.parent_entity_id=bdt.br_datamart_text_id)
    ORDER BY bdt.text_seq
    DETAIL
     std_text_cnt = (std_text_cnt+ 1), stat = alterlist(std_filter_text->filter_text,std_text_cnt),
     std_filter_text->filter_text[std_text_cnt].text_type_mean = bdt.text_type_mean,
     std_filter_text->filter_text[std_text_cnt].long_text = blt.long_text
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(std_filter_text)
   ENDIF
   CALL bederrorcheck("changedFilterText1 error")
   IF (std_text_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(std_text_cnt)),
      br_datamart_filter bdf,
      br_datamart_text bdt,
      br_long_text blt
     PLAN (d)
      JOIN (bdf
      WHERE (bdf.br_datamart_filter_id=view_comp_list->reports[curr_view_rep_pos].filters[
      curr_view_fil_pos].filter_id))
      JOIN (bdt
      WHERE bdt.br_datamart_category_id=bdf.br_datamart_category_id
       AND bdt.br_datamart_report_id=0.0
       AND bdt.br_datamart_filter_id=bdf.br_datamart_filter_id
       AND (bdt.text_type_mean=std_filter_text->filter_text[d.seq].text_type_mean))
      JOIN (blt
      WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
       AND blt.parent_entity_id=bdt.br_datamart_text_id)
     ORDER BY bdt.text_seq
     DETAIL
      IF (d.seq=bdt.text_seq)
       IF ((blt.long_text != std_filter_text->filter_text[d.seq].long_text))
        IF (validate(debug,0)=1)
         CALL echo(build(blt.long_text,"---does not match---",std_filter_text->filter_text[d.seq].
          long_text))
        ENDIF
        found_updated_text = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (found_updated_text=1)
     CALL addfilterflag(rep_reply_pos,fil_reply_pos,filter_text_changed_flag)
    ENDIF
   ENDIF
   CALL bederrorcheck("changedFilterText2 error")
 END ;Subroutine
 SUBROUTINE checkforchangedfilterlimit(std_comp_rep_pos,curr_view_rep_pos,std_comp_fil_pos,
  curr_view_fil_pos,rep_reply_pos,fil_reply_pos)
  IF ((std_content_list->reports[std_comp_rep_pos].filters[std_comp_fil_pos].filter_limit !=
  view_comp_list->reports[curr_view_rep_pos].filters[curr_view_fil_pos].filter_limit))
   SET reply->reports[rep_reply_pos].filters[fil_reply_pos].filter_limit_changed = std_content_list->
   reports[std_comp_rep_pos].filters[std_comp_fil_pos].filter_limit
   CALL addfilterflag(rep_reply_pos,fil_reply_pos,filter_limit_changed_flag)
  ENDIF
  CALL bederrorcheck("changedFilterLimits error")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE standard_content_type_flag = i4 WITH constant(6)
 DECLARE component_name_changed_flag = i4 WITH constant(1)
 DECLARE component_text_changed_flag = i4 WITH constant(2)
 DECLARE component_report_defaults_changed_flag = i4 WITH constant(3)
 DECLARE component_removed_flag = i4 WITH constant(4)
 DECLARE filter_list_resequenced_flag = i4 WITH constant(5)
 DECLARE filter_added_flag = i4 WITH constant(6)
 DECLARE filter_name_changed_flag = i4 WITH constant(7)
 DECLARE filter_removed_flag = i4 WITH constant(8)
 DECLARE filter_content_recommendations_changed_flag = i4 WITH constant(9)
 DECLARE filter_text_changed_flag = i4 WITH constant(10)
 DECLARE filter_limit_changed_flag = i4 WITH constant(11)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE k = i4 WITH protect, noconstant(0)
 DECLARE l = i4 WITH protect, noconstant(0)
 DECLARE loc = i4 WITH protect, noconstant(0)
 DECLARE fil_loc = i4 WITH protect, noconstant(0)
 DECLARE report_size = i4 WITH protect, noconstant(0)
 DECLARE filter_size = i4 WITH protect, noconstant(0)
 DECLARE filters_added_ind = i2 WITH protect, noconstant(0)
 DECLARE filters_removed_ind = i2 WITH protect, noconstant(0)
 DECLARE current_report_mean = vc WITH protect
 DECLARE populatecomponentlists(req_category_id=f8,req_report_mean=vc) = null
 DECLARE addcomponentflag(pos=i4,flag_type=i4) = null
 DECLARE addfilterflag(rep_pos=i4,fil_pos=i4,flag_type=i4) = null
 DECLARE checkforchangedcomponentnames(std_comp_pos=i4,curr_view_pos=i4,reply_pos=i4) = null
 DECLARE checkforchangedcomponenttext(std_comp_pos=i4,curr_view_pos=i4,reply_pos=i4) = null
 DECLARE checkforchangedcomponentreportdefaults(report_mean=vc,std_comp_pos=i4,curr_view_pos=i4) =
 null
 DECLARE checkforresequencedfilters(std_comp_pos=i4,curr_view_pos=i4,reply_pos=i4) = null
 DECLARE checkforfilterdefaultschanged(std_comp_pos=i4,std_fil_pos=i4,curr_comp_pos=i4,curr_fil_pos=
  i4,reply_pos=i4,
  filter_pos=i4) = null
 DECLARE checkforchangedfilternames(std_rep_comp_pos=i4,curr_rep_view_pos=i4,std_comp_pos=i4,
  curr_view_pos=i4,rep_reply_pos=i4,
  reply_pos=i4) = null
 DECLARE checkforchangedfiltertext(std_comp_rep_pos=i4,curr_view_rep_pos=i4,std_comp_fil_pos=i4,
  curr_view_fil_pos=i4,rep_reply_pos=i4,
  fil_reply_pos=i4) = null
 DECLARE checkforchangedfilterlimit(std_comp_rep_pos=i4,curr_view_rep_pos=i4,std_comp_fil_pos=i4,
  curr_view_fil_pos=i4,rep_reply_pos=i4,
  fil_reply_pos=i4) = null
 SET reply->br_datamart_category_id = request->br_datamart_category_id
 IF (validate(request->req_report_mean))
  CALL populatecomponentlists(request->br_datamart_category_id,request->req_report_mean)
 ELSE
  CALL populatecomponentlists(request->br_datamart_category_id,"")
 ENDIF
 FOR (i = 1 TO size(view_comp_list->reports,5))
   SET current_report_mean = view_comp_list->reports[i].report_mean
   SET report_size = size(reply->reports,5)
   SET report_size = (report_size+ 1)
   SET filter_size = 0
   SET filters_added_ind = 0
   SET filters_removed_ind = 0
   DECLARE stat = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->reports,report_size)
   SET reply->reports[report_size].report_id = view_comp_list->reports[i].report_id
   SET reply->reports[report_size].report_mean = current_report_mean
   SET reply->reports[report_size].report_name = view_comp_list->reports[i].report_name
   SET loc = locateval(j,1,size(std_content_list->reports,5),current_report_mean,std_content_list->
    reports[j].report_mean)
   IF (loc=0)
    CALL addcomponentflag(report_size,component_removed_flag)
   ELSE
    CALL checkforchangedcomponentnames(loc,i,report_size)
    CALL checkforchangedcomponenttext(loc,i,report_size)
    CALL checkforchangedcomponentreportdefaults(loc,i,report_size)
    SET filters_added_ind = checkforaddedfilters(loc,i)
   ENDIF
   FOR (k = 1 TO size(view_comp_list->reports[i].filters,5))
     IF ((view_comp_list->reports[i].filters[k].filter_id > 0.0))
      SET filter_size = size(reply->reports[report_size].filters,5)
      SET filter_size = (filter_size+ 1)
      SET stat = alterlist(reply->reports[report_size].filters,filter_size)
      SET reply->reports[report_size].filters[filter_size].filter_id = view_comp_list->reports[i].
      filters[k].filter_id
      SET reply->reports[report_size].filters[filter_size].filter_mean = view_comp_list->reports[i].
      filters[k].filter_mean
      SET reply->reports[report_size].filters[filter_size].filter_category_mean = view_comp_list->
      reports[i].filters[k].filter_category_mean
      SET reply->reports[report_size].filters[filter_size].filter_display = view_comp_list->reports[i
      ].filters[k].filter_display
      SET reply->reports[report_size].filters[filter_size].filter_seq = view_comp_list->reports[i].
      filters[k].filter_seq
      IF (validate(reply->reports[report_size].filters[filter_size].filter_limit)=1)
       SET reply->reports[report_size].filters[filter_size].filter_limit = view_comp_list->reports[i]
       .filters[k].filter_limit
      ENDIF
      IF (loc > 0)
       SET fil_loc = locateval(l,1,size(std_content_list->reports[loc].filters,5),view_comp_list->
        reports[i].filters[k].filter_mean,std_content_list->reports[loc].filters[l].filter_mean)
       IF (fil_loc=0)
        CALL addfilterflag(report_size,filter_size,filter_removed_flag)
        SET filters_removed_ind = 1
       ELSE
        CALL checkforfilterdefaultschanged(loc,fil_loc,i,k,report_size,
         filter_size)
        CALL checkforchangedfilternames(loc,i,fil_loc,k,report_size,
         filter_size)
        CALL checkforchangedfiltertext(loc,i,fil_loc,k,report_size,
         filter_size)
        IF (validate(reply->reports[report_size].filters[filter_size].filter_limit_changed)=1)
         CALL checkforchangedfilterlimit(loc,i,fil_loc,k,report_size,
          filter_size)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (filters_added_ind=0
    AND filters_removed_ind=0)
    CALL checkforresequencedfilters(loc,i,report_size)
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(0)
END GO
