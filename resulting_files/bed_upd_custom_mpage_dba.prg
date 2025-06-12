CREATE PROGRAM bed_upd_custom_mpage:dba
 FREE RECORD comp_to_delete
 RECORD comp_to_delete(
   1 reports[*]
     2 br_datamart_report_id = f8
 ) WITH protect
 FREE RECORD comp_to_upd_text
 RECORD comp_to_upd_text(
   1 components[*]
     2 component_id = f8
     2 component_mean = vc
 ) WITH protect
 FREE RECORD comp_to_upd_display
 RECORD comp_to_upd_display(
   1 components[*]
     2 component_id = f8
     2 component_mean = vc
 ) WITH protect
 FREE RECORD comp_to_upd_def
 RECORD comp_to_upd_def(
   1 components[*]
     2 component_id = f8
     2 component_mean = vc
     2 report_def[*]
       3 param_mean = vc
       3 param_value = vc
 ) WITH protect
 FREE RECORD filter_to_upd_name
 RECORD filter_to_upd_name(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
 ) WITH protect
 FREE RECORD filters_to_delete
 RECORD filters_to_delete(
   1 filters[*]
     2 br_datamart_filter_id = f8
     2 reports[*]
       3 br_datamart_report_id = f8
     2 preserve_shared_filters_ind = i2
 ) WITH protect
 FREE RECORD filters_to_upd_def
 RECORD filters_to_upd_def(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
     2 report_mean = vc
 ) WITH protect
 FREE RECORD filters_to_add
 RECORD filters_to_add(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
     2 component_id = f8
     2 component_mean = vc
     2 denominator_ind = i2
     2 numerator_ind = i2
     2 filter_display = vc
     2 filter_seq = i4
     2 filter_category_mean = vc
     2 filter_limit = i4
     2 details[*]
       3 oe_field_meaning = vc
       3 required_ind = i2
     2 text[*]
       3 std_filter_text_id = f8
       3 new_filter_text_id = f8
       3 std_filter_long_text_id = f8
       3 new_filter_long_text_id = f8
     2 defaults[*]
       3 new_filter_default_id = f8
       3 unique_identifier = vc
       3 cv_display = vc
       3 cv_description = vc
       3 code_set = i4
       3 result_type_flag = i2
       3 qualifier_flag = i2
       3 result_value = vc
       3 order_detail_ind = i2
       3 group_name = vc
       3 group_ce_name = vc
       3 group_ce_concept_cki = vc
       3 details[*]
         4 oe_field_meaning = vc
         4 detail_value = vc
         4 detail_cki = vc
 ) WITH protect
 FREE RECORD reseq_init
 RECORD reseq_init(
   1 reseq_list[*]
     2 reseq_comp_id = f8
 ) WITH protect
 FREE RECORD filters_to_seq
 RECORD filters_to_seq(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
     2 filter_seq = i4
     2 category_id = f8
 ) WITH protect
 FREE RECORD filters_to_upd_text
 RECORD filters_to_upd_text(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
     2 report_mean = vc
     2 std_filter_id = f8
 ) WITH protect
 FREE RECORD filters_to_upd_filter_limit
 RECORD filters_to_upd_filter_limit(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
 ) WITH protect
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
 DECLARE req_size = i4 WITH protect, constant(size(request->components,5))
 DECLARE delcomp_size = i4 WITH protect, noconstant(0)
 DECLARE updtext_size = i4 WITH protect, noconstant(0)
 DECLARE updname_size = i4 WITH protect, noconstant(0)
 DECLARE upddef_size = i4 WITH protect, noconstant(0)
 DECLARE addfilter_size = i4 WITH protect, noconstant(0)
 DECLARE seqfilter_size = i4 WITH protect, noconstant(0)
 DECLARE updfiltername_size = i4 WITH protect, noconstant(0)
 DECLARE delfilter_size = i4 WITH protect, noconstant(0)
 DECLARE updfildef_size = i4 WITH protect, noconstant(0)
 DECLARE updfiltext_size = i4 WITH protect, noconstant(0)
 DECLARE reseq_list_size = i4 WITH protect, noconstant(0)
 DECLARE updfillimit_size = i4 WITH protect, noconstant(0)
 DECLARE fcnt = i4 WITH protect, noconstant(0)
 DECLARE dcnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE defcnt = i4 WITH protect, noconstant(0)
 DECLARE filtercnt = i4 WITH protect, noconstant(0)
 DECLARE fil_index = i4 WITH protect, noconstant(0)
 DECLARE rep_index = i4 WITH protect, noconstant(0)
 DECLARE fil_position = i4 WITH protect, noconstant(0)
 DECLARE loc = i4 WITH protect, noconstant(0)
 DECLARE fil_loc = i4 WITH protect, noconstant(0)
 DECLARE delreports(null) = i2
 DECLARE updatetext(null) = i2
 DECLARE updatenames(null) = i2
 DECLARE updatedefaults(null) = i2
 DECLARE addfilters(null) = i2
 DECLARE reseqfilters(null) = i2
 DECLARE updatefilternames(null) = i2
 DECLARE delfilters(null) = i2
 DECLARE updatefilterdefaults(null) = i2
 DECLARE updatefiltertext(null) = i2
 DECLARE updatefilterlimit(null) = i2
 DECLARE populatecomponentlists(null) = null
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(0)
 DECLARE w = i4 WITH protect, noconstant(0)
 DECLARE fil_shared_ind = i4 WITH protect, noconstant(0)
 FOR (x = 1 TO req_size)
  FOR (y = 1 TO size(request->components[x].flags,5))
    IF ((request->components[x].flags[y].flag_type=component_removed_flag))
     SET delcomp_size = (delcomp_size+ 1)
     SET stat = alterlist(comp_to_delete->reports,delcomp_size)
     SET comp_to_delete->reports[delcomp_size].br_datamart_report_id = request->components[x].
     component_id
     FOR (z = 1 TO size(request->components[x].filters,5))
       FOR (w = 1 TO size(request->components[x].filters[z].flags,5))
         SET delfilter_size = (delfilter_size+ 1)
         SET stat = alterlist(filters_to_delete->filters,delfilter_size)
         SET filters_to_delete->filters[delfilter_size].br_datamart_filter_id = request->components[x
         ].filters[z].filter_id
         SET fil_shared_ind = isfiltershared(request->components[x].filters[z].filter_id)
         IF (fil_shared_ind=1)
          SET filters_to_delete->filters[delfilter_size].preserve_shared_filters_ind = 1
          SET stat = alterlist(filters_to_delete->filters[delfilter_size].reports,1)
          SET filters_to_delete->filters[delfilter_size].filters[delfilter_size].reports[1].
          br_datamart_report_id = request->components[x].component_id
         ENDIF
       ENDFOR
     ENDFOR
    ELSEIF ((request->components[x].flags[y].flag_type=component_text_changed_flag))
     SET updtext_size = (updtext_size+ 1)
     SET stat = alterlist(comp_to_upd_text->components,updtext_size)
     SET comp_to_upd_text->components[updtext_size].component_id = request->components[x].
     component_id
     SET comp_to_upd_text->components[updtext_size].component_mean = request->components[x].
     component_mean
    ELSEIF ((request->components[x].flags[y].flag_type=component_name_changed_flag))
     SET updname_size = (updname_size+ 1)
     SET stat = alterlist(comp_to_upd_display->components,updname_size)
     SET comp_to_upd_display->components[updname_size].component_id = request->components[x].
     component_id
     SET comp_to_upd_display->components[updname_size].component_mean = request->components[x].
     component_mean
    ELSEIF ((request->components[x].flags[y].flag_type=component_report_defaults_changed_flag))
     SET upddef_size = (upddef_size+ 1)
     SET stat = alterlist(comp_to_upd_def->components,upddef_size)
     SET comp_to_upd_def->components[upddef_size].component_id = request->components[x].component_id
     SET comp_to_upd_def->components[upddef_size].component_mean = request->components[x].
     component_mean
    ELSEIF ((request->components[x].flags[y].flag_type=filter_list_resequenced_flag))
     SET reseq_list_size = (size(reseq_init->reseq_list,5)+ 1)
     SET stat = alterlist(reseq_init->reseq_list,reseq_list_size)
     SET reseq_init->reseq_list[reseq_list_size].reseq_comp_id = request->components[x].component_id
    ENDIF
  ENDFOR
  FOR (z = 1 TO size(request->components[x].filters,5))
    FOR (w = 1 TO size(request->components[x].filters[z].flags,5))
      IF ((request->components[x].filters[z].flags[w].flag_type=filter_name_changed_flag))
       SET updfiltername_size = (updfiltername_size+ 1)
       SET stat = alterlist(filter_to_upd_name->filters,updfiltername_size)
       SET filter_to_upd_name->filters[updfiltername_size].filter_id = request->components[x].
       filters[z].filter_id
       SET filter_to_upd_name->filters[updfiltername_size].filter_mean = request->components[x].
       filters[z].filter_mean
      ELSEIF ((request->components[x].filters[z].flags[w].flag_type=filter_limit_changed_flag))
       SET updfillimit_size = (updfillimit_size+ 1)
       SET stat = alterlist(filters_to_upd_filter_limit->filters,updfillimit_size)
       SET filters_to_upd_filter_limit->filters[updfillimit_size].filter_id = request->components[x].
       filters[z].filter_id
       SET filters_to_upd_filter_limit->filters[updfillimit_size].filter_mean = request->components[x
       ].filters[z].filter_mean
      ELSEIF ((request->components[x].filters[z].flags[w].flag_type=filter_removed_flag))
       SET delfilter_size = (delfilter_size+ 1)
       SET stat = alterlist(filters_to_delete->filters,delfilter_size)
       SET filters_to_delete->filters[delfilter_size].br_datamart_filter_id = request->components[x].
       filters[z].filter_id
       SET fil_shared_ind = isfiltershared(request->components[x].filters[z].filter_id)
       IF (fil_shared_ind=1)
        SET filters_to_delete->filters[delfilter_size].preserve_shared_filters_ind = 1
        SET stat = alterlist(filters_to_delete->filters[delfilter_size].reports,1)
        SET filters_to_delete->filters[delfilter_size].reports[1].br_datamart_report_id = request->
        components[x].component_id
       ENDIF
      ELSEIF ((request->components[x].filters[z].flags[w].flag_type=
      filter_content_recommendations_changed_flag))
       SET updfildef_size = (updfildef_size+ 1)
       SET stat = alterlist(filters_to_upd_def->filters,updfildef_size)
       SET filters_to_upd_def->filters[updfildef_size].filter_id = request->components[x].filters[z].
       filter_id
       SET filters_to_upd_def->filters[updfildef_size].filter_mean = request->components[x].filters[z
       ].filter_mean
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(updfildef_size)),
         br_datamart_report_filter_r bdrfr,
         br_datamart_report bdr
        PLAN (d)
         JOIN (bdrfr
         WHERE (bdrfr.br_datamart_filter_id=filters_to_upd_def->filters[d.seq].filter_id))
         JOIN (bdr
         WHERE bdr.br_datamart_report_id=bdrfr.br_datamart_report_id)
        HEAD d.seq
         filters_to_upd_def->filters[d.seq].report_mean = bdr.report_mean
        WITH nocounter
       ;end select
      ELSEIF ((request->components[x].filters[z].flags[w].flag_type=filter_text_changed_flag))
       SET updfiltext_size = (updfiltext_size+ 1)
       SET stat = alterlist(filters_to_upd_text->filters,updfiltext_size)
       SET filters_to_upd_text->filters[updfiltext_size].filter_id = request->components[x].filters[z
       ].filter_id
       SET filters_to_upd_text->filters[updfiltext_size].filter_mean = request->components[x].
       filters[z].filter_mean
       SET filters_to_upd_text->filters[updfiltext_size].report_mean = request->components[x].
       component_mean
      ELSEIF ((request->components[x].filters[z].flags[w].flag_type=filter_added_flag))
       SET addfilter_size = (addfilter_size+ 1)
       SET stat = alterlist(filters_to_add->filters,addfilter_size)
       SET filters_to_add->filters[addfilter_size].filter_mean = request->components[x].filters[z].
       filter_mean
       SET filters_to_add->filters[addfilter_size].component_id = request->components[x].component_id
       SET filters_to_add->filters[addfilter_size].component_mean = request->components[x].
       component_mean
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
 IF (delcomp_size > 0)
  CALL delreports(null)
 ENDIF
 IF (updtext_size > 0)
  CALL updatetext(null)
 ENDIF
 IF (updname_size > 0)
  CALL updatenames(null)
 ENDIF
 IF (upddef_size > 0)
  CALL updatedefaults(null)
 ENDIF
 IF (delfilter_size > 0)
  CALL delfilters(null)
 ENDIF
 IF (addfilter_size > 0)
  CALL addfilters(null)
 ENDIF
 IF (updfiltername_size > 0)
  CALL updatefilternames(null)
 ENDIF
 IF (updfildef_size > 0)
  CALL updatefilterdefaults(null)
 ENDIF
 IF (updfiltext_size > 0)
  CALL updatefiltertext(null)
 ENDIF
 IF (updfillimit_size > 0)
  CALL updatefilterlimit(null)
 ENDIF
 SET reseq_list_size = size(reseq_init->reseq_list,5)
 IF (reseq_list_size > 0.0)
  CALL reseqfilters(null)
 ENDIF
 SUBROUTINE delreports(null)
   CALL bedlogmessage("delReports","Entering ...")
   EXECUTE bed_del_datamart_reports  WITH replace("REQUEST",comp_to_delete)
   CALL bedlogmessage("delReports","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatetext(null)
   CALL bedlogmessage("updateText","Entering ...")
   RECORD updatedtext(
     1 components[*]
       2 component_id = f8
       2 text_type_mean = vc
       2 upd_text_id = f8
       2 upd_text = vc
   )
   DECLARE updated_cnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echorecord(comp_to_upd_text)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updtext_size)),
     br_datamart_report bdr,
     br_datamart_category bdc,
     br_datamart_text bdt,
     br_long_text blt
    PLAN (d)
     JOIN (bdr
     WHERE (bdr.report_mean=comp_to_upd_text->components[d.seq].component_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdc.category_type_flag=6)
     JOIN (bdt
     WHERE bdt.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdt.br_datamart_report_id=bdr.br_datamart_report_id
      AND bdt.br_datamart_filter_id=0.0)
     JOIN (blt
     WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
      AND blt.parent_entity_id=bdt.br_datamart_text_id)
    ORDER BY d.seq, blt.long_text_id
    DETAIL
     updated_cnt = (updated_cnt+ 1), stat = alterlist(updatedtext->components,updated_cnt),
     updatedtext->components[updated_cnt].upd_text = blt.long_text,
     updatedtext->components[updated_cnt].text_type_mean = bdt.text_type_mean, updatedtext->
     components[updated_cnt].component_id = comp_to_upd_text->components[d.seq].component_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting std text")
   IF (size(updatedtext->components,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(updated_cnt)),
      br_datamart_report bdr,
      br_datamart_text bdt,
      br_long_text blt
     PLAN (d)
      JOIN (bdr
      WHERE (bdr.br_datamart_report_id=updatedtext->components[d.seq].component_id))
      JOIN (bdt
      WHERE bdt.br_datamart_category_id=bdr.br_datamart_category_id
       AND bdt.br_datamart_report_id=bdr.br_datamart_report_id
       AND bdt.br_datamart_filter_id=0.0
       AND (bdt.text_type_mean=updatedtext->components[d.seq].text_type_mean))
      JOIN (blt
      WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
       AND blt.parent_entity_id=bdt.br_datamart_text_id)
     ORDER BY bdt.text_seq
     DETAIL
      IF ((updatedtext->components[d.seq].text_type_mean="PREREQ"))
       IF ((blt.long_text != updatedtext->components[d.seq].upd_text))
        updatedtext->components[d.seq].upd_text_id = blt.long_text_id
       ENDIF
      ELSE
       IF (d.seq=bdt.text_seq)
        IF ((blt.long_text != updatedtext->components[d.seq].upd_text))
         updatedtext->components[d.seq].upd_text_id = blt.long_text_id
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error getting text id")
    IF (validate(debug,0)=1)
     CALL echorecord(updatedtext)
    ENDIF
    UPDATE  FROM br_long_text blt,
      (dummyt d  WITH seq = value(updated_cnt))
     SET blt.long_text = updatedtext->components[d.seq].upd_text, blt.updt_id = reqinfo->updt_id, blt
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      blt.updt_task = reqinfo->updt_task, blt.updt_applctx = reqinfo->updt_applctx, blt.updt_cnt = (
      blt.updt_cnt+ 1)
     PLAN (d
      WHERE (updatedtext->components[d.seq].upd_text_id > 0))
      JOIN (blt
      WHERE (blt.long_text_id=updatedtext->components[d.seq].upd_text_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error upd text id")
   ENDIF
   CALL bedlogmessage("updateText","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatenames(null)
   CALL bedlogmessage("updateNames","Entering ...")
   RECORD updatedtext(
     1 components[*]
       2 component_id = f8
       2 upd_text = vc
   )
   DECLARE updated_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updname_size)),
     br_datamart_report bdr,
     br_datamart_category bdc
    PLAN (d)
     JOIN (bdr
     WHERE (bdr.report_mean=comp_to_upd_display->components[d.seq].component_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdc.category_type_flag=6)
    ORDER BY d.seq
    HEAD d.seq
     updated_cnt = (updated_cnt+ 1), stat = alterlist(updatedtext->components,updated_cnt),
     updatedtext->components[updated_cnt].upd_text = bdr.report_name,
     updatedtext->components[updated_cnt].component_id = comp_to_upd_display->components[d.seq].
     component_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting upd name")
   IF (size(updatedtext->components,5) > 0)
    UPDATE  FROM br_datamart_report br,
      (dummyt d  WITH seq = value(updated_cnt))
     SET br.report_name = updatedtext->components[d.seq].upd_text, br.updt_id = reqinfo->updt_id, br
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br
      .updt_cnt+ 1)
     PLAN (d
      WHERE (updatedtext->components[d.seq].component_id > 0))
      JOIN (br
      WHERE (br.br_datamart_report_id=updatedtext->components[d.seq].component_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error upd name")
   ENDIF
   CALL bedlogmessage("updateNames","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatedefaults(null)
   CALL bedlogmessage("updateDefaults","Entering ...")
   RECORD updateddefaults(
     1 components[*]
       2 component_id = f8
       2 component_mean = vc
       2 report_def[*]
         3 param_mean = vc
         3 param_value = vc
   )
   DECLARE updated_cnt = i4 WITH protect, noconstant(0)
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(upddef_size)),
     br_datamart_report bdr,
     br_datamart_report_default bdd,
     br_datamart_category bdc
    PLAN (d)
     JOIN (bdr
     WHERE (bdr.report_mean=comp_to_upd_def->components[d.seq].component_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdc.category_type_flag=6)
     JOIN (bdd
     WHERE bdd.br_datamart_report_id=bdr.br_datamart_report_id)
    ORDER BY d.seq, bdd.br_datamart_report_default_id
    HEAD d.seq
     def_cnt = 0, updated_cnt = (updated_cnt+ 1), stat = alterlist(updateddefaults->components,
      updated_cnt),
     updateddefaults->components[updated_cnt].component_mean = bdr.report_name, updateddefaults->
     components[updated_cnt].component_id = comp_to_upd_def->components[d.seq].component_id
    HEAD bdd.br_datamart_report_default_id
     def_cnt = (def_cnt+ 1), stat = alterlist(updateddefaults->components[updated_cnt].report_def,
      def_cnt), updateddefaults->components[updated_cnt].report_def[def_cnt].param_mean = bdd
     .mpage_param_mean,
     updateddefaults->components[updated_cnt].report_def[def_cnt].param_value = bdd.mpage_param_value
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting upd def")
   DELETE  FROM (dummyt d  WITH seq = value(updated_cnt)),
     br_datamart_report_default bdd
    SET bdd.seq = 1
    PLAN (d)
     JOIN (bdd
     WHERE (bdd.br_datamart_report_id=comp_to_upd_def->components[d.seq].component_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_report_default table")
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   FOR (x = 1 TO updated_cnt)
    INSERT  FROM br_datamart_report_default bdd,
      (dummyt d  WITH seq = size(updateddefaults->components[x].report_def,5))
     SET bdd.br_datamart_report_default_id = seq(bedrock_seq,nextval), bdd.br_datamart_report_id =
      updateddefaults->components[x].component_id, bdd.mpage_param_mean = updateddefaults->
      components[x].report_def[d.seq].param_mean,
      bdd.mpage_param_value = updateddefaults->components[x].report_def[d.seq].param_value, bdd
      .updt_applctx = reqinfo->updt_applctx, bdd.updt_id = reqinfo->updt_id,
      bdd.updt_cnt = 0, bdd.updt_task = reqinfo->updt_task, bdd.updt_dt_tm = cnvtdatetime(curdate,
       curtime3)
     PLAN (d)
      JOIN (bdd)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error inserting into br_datamart_report_default table")
   ENDFOR
   CALL bedlogmessage("updateDefaults","Exiting ...")
 END ;Subroutine
 SUBROUTINE addfilters(null)
   CALL bedlogmessage("addFilters","Entering ...")
   RECORD longtext(
     1 text[*]
       2 long_text_id = f8
       2 parent_entity_name = vc
       2 parent_entity_id = f8
       2 long_text = vc
   )
   DECLARE exist_cat_id = f8 WITH protect, noconstant(0.0)
   DECLARE textcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(addfilter_size)),
     br_datamart_report r
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_report_id=filters_to_add->filters[d.seq].component_id))
    HEAD r.br_datamart_category_id
     exist_cat_id = r.br_datamart_category_id, reseq_list_size = (size(reseq_init->reseq_list,5)+ 1),
     stat = alterlist(reseq_init->reseq_list,reseq_list_size),
     reseq_init->reseq_list[reseq_list_size].reseq_comp_id = r.br_datamart_report_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error get cat id")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(addfilter_size)),
     br_datamart_report bdr,
     br_datamart_category bdc,
     br_datamart_report_filter_r bdfr,
     br_datamart_filter bdf,
     br_datamart_filter_detail fd,
     br_datamart_text t,
     br_long_text l,
     br_datamart_default def,
     br_datamart_default_detail defdet
    PLAN (d)
     JOIN (bdr
     WHERE (bdr.report_mean=filters_to_add->filters[d.seq].component_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdr.br_datamart_category_id
      AND bdc.category_type_flag=6)
     JOIN (bdfr
     WHERE bdfr.br_datamart_report_id=bdr.br_datamart_report_id)
     JOIN (bdf
     WHERE bdf.br_datamart_filter_id=bdfr.br_datamart_filter_id
      AND (bdf.filter_mean=filters_to_add->filters[d.seq].filter_mean))
     JOIN (fd
     WHERE fd.br_datamart_filter_id=outerjoin(bdf.br_datamart_filter_id))
     JOIN (t
     WHERE t.br_datamart_filter_id=outerjoin(bdf.br_datamart_filter_id))
     JOIN (l
     WHERE l.parent_entity_id=outerjoin(t.br_datamart_text_id)
      AND l.parent_entity_name=outerjoin("BR_DATAMART_TEXT"))
     JOIN (def
     WHERE def.br_datamart_filter_id=outerjoin(bdf.br_datamart_filter_id))
     JOIN (defdet
     WHERE defdet.br_datamart_default_id=outerjoin(def.br_datamart_default_id))
    ORDER BY bdc.br_datamart_category_id, d.seq, bdf.br_datamart_filter_id,
     fd.br_datamart_filter_detail_id, t.br_datamart_text_id, def.br_datamart_default_id,
     defdet.br_datamart_default_detail_id
    HEAD d.seq
     fcnt = 0
    HEAD bdf.br_datamart_filter_id
     filters_to_add->filters[d.seq].denominator_ind = bdfr.denominator_ind, filters_to_add->filters[d
     .seq].numerator_ind = bdfr.numerator_ind, filters_to_add->filters[d.seq].filter_mean = bdf
     .filter_mean,
     filters_to_add->filters[d.seq].filter_display = bdf.filter_display, filters_to_add->filters[d
     .seq].filter_seq = - (1), filters_to_add->filters[d.seq].filter_category_mean = bdf
     .filter_category_mean,
     filters_to_add->filters[d.seq].filter_limit = bdf.filter_limit, dcnt = 0, tcnt = 0,
     defcnt = 0
    HEAD fd.br_datamart_filter_detail_id
     IF (fd.br_datamart_filter_detail_id > 0)
      dcnt = (dcnt+ 1), stat = alterlist(filters_to_add->filters[d.seq].details,dcnt), filters_to_add
      ->filters[d.seq].details[dcnt].oe_field_meaning = fd.oe_field_meaning,
      filters_to_add->filters[d.seq].details[dcnt].required_ind = fd.required_ind
     ENDIF
    HEAD t.br_datamart_text_id
     IF (t.br_datamart_text_id > 0)
      tcnt = (tcnt+ 1), stat = alterlist(filters_to_add->filters[d.seq].text,tcnt), filters_to_add->
      filters[d.seq].text[tcnt].std_filter_text_id = t.br_datamart_text_id,
      filters_to_add->filters[d.seq].text[tcnt].std_filter_long_text_id = l.long_text_id
     ENDIF
    HEAD def.br_datamart_default_id
     IF (def.br_datamart_default_id > 0)
      defcnt = (defcnt+ 1), stat = alterlist(filters_to_add->filters[d.seq].defaults,defcnt),
      filters_to_add->filters[d.seq].defaults[defcnt].unique_identifier = def.unique_identifier,
      filters_to_add->filters[d.seq].defaults[defcnt].cv_display = def.cv_display, filters_to_add->
      filters[d.seq].defaults[defcnt].cv_description = def.cv_description, filters_to_add->filters[d
      .seq].defaults[defcnt].code_set = def.code_set,
      filters_to_add->filters[d.seq].defaults[defcnt].result_type_flag = def.result_type_flag,
      filters_to_add->filters[d.seq].defaults[defcnt].qualifier_flag = def.qualifier_flag,
      filters_to_add->filters[d.seq].defaults[defcnt].result_value = def.result_value,
      filters_to_add->filters[d.seq].defaults[defcnt].order_detail_ind = def.order_detail_ind,
      filters_to_add->filters[d.seq].defaults[defcnt].group_name = def.group_name, filters_to_add->
      filters[d.seq].defaults[defcnt].group_ce_name = def.group_ce_name,
      filters_to_add->filters[d.seq].defaults[defcnt].group_ce_concept_cki = def.group_ce_concept_cki
     ENDIF
     defdetcnt = 0
    HEAD defdet.br_datamart_default_detail_id
     IF (defdet.br_datamart_default_detail_id > 0)
      defdetcnt = (defdetcnt+ 1), stat = alterlist(filters_to_add->filters[d.seq].defaults[defcnt].
       details,defdetcnt), filters_to_add->filters[d.seq].defaults[defcnt].details[defdetcnt].
      oe_field_meaning = defdet.oe_field_meaning,
      filters_to_add->filters[d.seq].defaults[defcnt].details[defdetcnt].detail_value = defdet
      .detail_value, filters_to_add->filters[d.seq].defaults[defcnt].details[defdetcnt].detail_cki =
      defdet.detail_cki
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error get filter name")
   SET filtercnt = size(filters_to_add->filters,5)
   IF (filtercnt > 0)
    SELECT INTO "nl:"
     new_filter_val = seq(bedrock_seq,nextval)
     FROM (dummyt d  WITH seq = value(filtercnt)),
      dual dd
     PLAN (d)
      JOIN (dd)
     DETAIL
      filters_to_add->filters[d.seq].filter_id = cnvtreal(new_filter_val)
     WITH nocounter
    ;end select
    FOR (f = 1 TO filtercnt)
      SET defcnt = 0
      SET defcnt = size(filters_to_add->filters[f].defaults,5)
      IF (defcnt > 0)
       SELECT INTO "nl:"
        new_def_val = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(defcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         filters_to_add->filters[f].defaults[d.seq].new_filter_default_id = cnvtreal(new_def_val)
        WITH nocounter
       ;end select
      ENDIF
      SET textcnt = 0
      SET textcnt = size(filters_to_add->filters[f].text,5)
      IF (textcnt > 0)
       SELECT INTO "nl:"
        new_text_val = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(textcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         filters_to_add->filters[f].text[d.seq].new_filter_text_id = cnvtreal(new_text_val)
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        new_longtext_val = seq(bedrock_seq,nextval)
        FROM (dummyt d  WITH seq = value(textcnt)),
         dual dd
        PLAN (d)
         JOIN (dd)
        DETAIL
         filters_to_add->filters[f].text[d.seq].new_filter_long_text_id = cnvtreal(new_longtext_val)
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
    IF (validate(debug,0)=1)
     CALL echorecord(filters_to_add)
    ENDIF
    INSERT  FROM br_datamart_filter bdf,
      (dummyt d  WITH seq = filtercnt)
     SET bdf.br_datamart_filter_id = filters_to_add->filters[d.seq].filter_id, bdf
      .br_datamart_category_id = exist_cat_id, bdf.filter_mean = filters_to_add->filters[d.seq].
      filter_mean,
      bdf.filter_display = filters_to_add->filters[d.seq].filter_display, bdf.filter_seq =
      filters_to_add->filters[d.seq].filter_seq, bdf.filter_category_mean = filters_to_add->filters[d
      .seq].filter_category_mean,
      bdf.filter_limit = filters_to_add->filters[d.seq].filter_limit, bdf.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), bdf.updt_id = reqinfo->updt_id,
      bdf.updt_task = reqinfo->updt_task, bdf.updt_cnt = 0, bdf.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (bdf)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error insert filter")
    INSERT  FROM br_datamart_report_filter_r r,
      (dummyt d  WITH seq = filtercnt)
     SET r.br_datamart_report_filter_r_id = seq(bedrock_seq,nextval), r.br_datamart_filter_id =
      filters_to_add->filters[d.seq].filter_id, r.denominator_ind = filters_to_add->filters[d.seq].
      denominator_ind,
      r.numerator_ind = filters_to_add->filters[d.seq].numerator_ind, r.br_datamart_report_id =
      filters_to_add->filters[d.seq].component_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = 0,
      r.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (r)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error insert filter report r")
    INSERT  FROM br_datamart_filter_detail fd,
      (dummyt d  WITH seq = filtercnt),
      (dummyt d2  WITH seq = 1)
     SET fd.br_datamart_filter_detail_id = seq(bedrock_seq,nextval), fd.br_datamart_filter_id =
      filters_to_add->filters[d.seq].filter_id, fd.oe_field_meaning = filters_to_add->filters[d.seq].
      details[d2.seq].oe_field_meaning,
      fd.required_ind = filters_to_add->filters[d.seq].details[d2.seq].required_ind, fd.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), fd.updt_id = reqinfo->updt_id,
      fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0, fd.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE maxrec(d2,size(filters_to_add->filters[d.seq].details,5)))
      JOIN (d2)
      JOIN (fd)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error insert filter detail")
    INSERT  FROM br_datamart_default fd,
      (dummyt d  WITH seq = filtercnt),
      (dummyt d2  WITH seq = 1)
     SET fd.br_datamart_default_id = filters_to_add->filters[d.seq].defaults[d2.seq].
      new_filter_default_id, fd.br_datamart_filter_id = filters_to_add->filters[d.seq].filter_id, fd
      .unique_identifier = filters_to_add->filters[d.seq].defaults[d2.seq].unique_identifier,
      fd.cv_display = filters_to_add->filters[d.seq].defaults[d2.seq].cv_display, fd.cv_description
       = filters_to_add->filters[d.seq].defaults[d2.seq].cv_description, fd.code_set = filters_to_add
      ->filters[d.seq].defaults[d2.seq].code_set,
      fd.result_type_flag = filters_to_add->filters[d.seq].defaults[d2.seq].result_type_flag, fd
      .qualifier_flag = filters_to_add->filters[d.seq].defaults[d2.seq].qualifier_flag, fd
      .result_value = filters_to_add->filters[d.seq].defaults[d2.seq].result_value,
      fd.order_detail_ind = filters_to_add->filters[d.seq].defaults[d2.seq].order_detail_ind, fd
      .group_name = filters_to_add->filters[d.seq].defaults[d2.seq].group_name, fd.group_ce_name =
      filters_to_add->filters[d.seq].defaults[d2.seq].group_ce_name,
      fd.group_ce_concept_cki = filters_to_add->filters[d.seq].defaults[d2.seq].group_ce_concept_cki,
      fd.updt_dt_tm = cnvtdatetime(curdate,curtime3), fd.updt_id = reqinfo->updt_id,
      fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0, fd.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE maxrec(d2,size(filters_to_add->filters[d.seq].defaults,5)))
      JOIN (d2)
      JOIN (fd)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error insert filter default")
    FOR (f = 1 TO filtercnt)
      SET defcnt = 0.0
      SET defcnt = size(filters_to_add->filters[f].defaults,5)
      IF (defcnt > 0)
       INSERT  FROM br_datamart_default_detail fd,
         (dummyt d  WITH seq = defcnt),
         (dummyt d2  WITH seq = 1)
        SET fd.br_datamart_default_detail_id = seq(bedrock_seq,nextval), fd.br_datamart_default_id =
         filters_to_add->filters[f].defaults[d.seq].new_filter_default_id, fd.oe_field_meaning =
         filters_to_add->filters[f].defaults[d.seq].details[d2.seq].oe_field_meaning,
         fd.detail_value = filters_to_add->filters[f].defaults[d.seq].details[d2.seq].detail_value,
         fd.detail_cki = filters_to_add->filters[f].defaults[d.seq].details[d2.seq].detail_cki, fd
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         fd.updt_id = reqinfo->updt_id, fd.updt_task = reqinfo->updt_task, fd.updt_cnt = 0,
         fd.updt_applctx = reqinfo->updt_applctx
        PLAN (d
         WHERE maxrec(d2,size(filters_to_add->filters[f].defaults[d.seq].details,5)))
         JOIN (d2)
         JOIN (fd)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("Error insert filter default detail")
      ENDIF
      SET textcnt = size(filters_to_add->filters[f].text,5)
      FOR (t = 1 TO textcnt)
        INSERT  FROM br_datamart_text bt
         (bt.br_datamart_text_id, bt.br_datamart_category_id, bt.br_datamart_filter_id,
         bt.br_datamart_report_id, bt.text_type_mean, bt.text_seq,
         bt.updt_applctx, bt.updt_cnt, bt.updt_dt_tm,
         bt.updt_id, bt.updt_task)(SELECT
          filters_to_add->filters[f].text[t].new_filter_text_id, exist_cat_id, filters_to_add->
          filters[f].filter_id,
          0, bt2.text_type_mean, bt2.text_seq,
          reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime),
          reqinfo->updt_id, reqinfo->updt_task
          FROM br_datamart_text bt2
          WHERE (bt2.br_datamart_text_id=filters_to_add->filters[f].text[t].std_filter_text_id))
         WITH nocounter
        ;end insert
        CALL bederrorcheck("Error insert filter text")
        SET textlength = 0
        SET stat = alterlist(longtext->text,0)
        SELECT INTO "nl:"
         FROM br_long_text bt
         PLAN (bt
          WHERE (bt.long_text_id=filters_to_add->filters[f].text[t].std_filter_long_text_id))
         HEAD bt.long_text_id
          textlength = (textlength+ 1), stat = alterlist(longtext->text,textlength)
         DETAIL
          longtext->text[textlength].long_text_id = filters_to_add->filters[f].text[t].
          new_filter_long_text_id, longtext->text[textlength].parent_entity_name = bt
          .parent_entity_name, longtext->text[textlength].parent_entity_id = filters_to_add->filters[
          f].text[t].new_filter_text_id,
          longtext->text[textlength].long_text = bt.long_text
         WITH nocounter
        ;end select
        CALL bederrorcheck("Error getting long text")
        INSERT  FROM (dummyt d  WITH seq = textlength),
          br_long_text bt
         SET bt.long_text_id = longtext->text[d.seq].long_text_id, bt.parent_entity_name = longtext->
          text[d.seq].parent_entity_name, bt.parent_entity_id = longtext->text[d.seq].
          parent_entity_id,
          bt.long_text = longtext->text[d.seq].long_text, bt.updt_applctx = reqinfo->updt_applctx, bt
          .updt_cnt = 0,
          bt.updt_dt_tm = cnvtdatetime(curdate,curtime), bt.updt_id = reqinfo->updt_id, bt.updt_task
           = reqinfo->updt_task
         PLAN (d)
          JOIN (bt)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("Error inserting long text")
      ENDFOR
    ENDFOR
   ENDIF
   CALL echorecord(filters_to_add)
   CALL bedlogmessage("addFilters","Exiting ...")
 END ;Subroutine
 SUBROUTINE reseqfilters(null)
   CALL bedlogmessage("reseqFilters","Entering ...")
   DECLARE seq = i4 WITH protect, noconstant(0)
   DECLARE cat_id = f8 WITH protect, noconstant(0.0)
   DECLARE prev_seq = i4 WITH protect, noconstant(- (1))
   DECLARE prev_cat_id = f8 WITH protect, noconstant(0.0)
   SET reseq_list_size = size(reseq_init->reseq_list,5)
   FOR (r_idx = 1 TO reseq_list_size)
     SELECT INTO "nl:"
      FROM br_datamart_report r,
       br_datamart_filter f
      PLAN (r
       WHERE (r.br_datamart_report_id=reseq_init->reseq_list[r_idx].reseq_comp_id))
       JOIN (f
       WHERE f.br_datamart_category_id=r.br_datamart_category_id
        AND f.br_datamart_filter_id > 0)
      ORDER BY f.br_datamart_filter_id
      HEAD f.br_datamart_filter_id
       seqfilter_size = (seqfilter_size+ 1), stat = alterlist(filters_to_seq->filters,seqfilter_size),
       filters_to_seq->filters[seqfilter_size].filter_mean = f.filter_mean,
       filters_to_seq->filters[seqfilter_size].filter_id = f.br_datamart_filter_id
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error finding filters")
     IF (size(filters_to_seq->filters,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(seqfilter_size)),
        br_datamart_filter bdf,
        br_datamart_category bdc
       PLAN (d)
        JOIN (bdf
        WHERE (bdf.filter_mean=filters_to_seq->filters[d.seq].filter_mean))
        JOIN (bdc
        WHERE bdc.br_datamart_category_id=bdf.br_datamart_category_id
         AND bdc.category_type_flag=6)
       ORDER BY d.seq
       HEAD d.seq
        filters_to_seq->filters[d.seq].filter_seq = bdf.filter_seq, filters_to_seq->filters[d.seq].
        category_id = bdc.br_datamart_category_id
       WITH nocounter
      ;end select
      CALL bederrorcheck("Error finding seq")
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(seqfilter_size))
       ORDER BY filters_to_seq->filters[d.seq].category_id, filters_to_seq->filters[d.seq].filter_seq
       DETAIL
        IF ((prev_seq=filters_to_seq->filters[d.seq].filter_seq)
         AND (filters_to_seq->filters[d.seq].category_id=prev_cat_id))
         filters_to_seq->filters[d.seq].filter_seq = seq
        ELSE
         seq = (seq+ 1), prev_seq = filters_to_seq->filters[d.seq].filter_seq, filters_to_seq->
         filters[d.seq].filter_seq = seq
        ENDIF
        prev_cat_id = filters_to_seq->filters[d.seq].category_id
       WITH nocounter
      ;end select
      CALL bederrorcheck("Error setting seq")
      UPDATE  FROM br_datamart_filter bdf,
        (dummyt d  WITH seq = value(seqfilter_size))
       SET bdf.filter_seq = filters_to_seq->filters[d.seq].filter_seq, bdf.updt_id = reqinfo->updt_id,
        bdf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bdf.updt_task = reqinfo->updt_task, bdf.updt_applctx = reqinfo->updt_applctx, bdf.updt_cnt =
        (bdf.updt_cnt+ 1)
       PLAN (d
        WHERE (filters_to_seq->filters[d.seq].filter_id > 0))
        JOIN (bdf
        WHERE (bdf.br_datamart_filter_id=filters_to_seq->filters[d.seq].filter_id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("Error upd filter seq")
     ENDIF
   ENDFOR
   CALL bedlogmessage("reseqFilters","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatefilternames(null)
   CALL bedlogmessage("updateFilterNames","Entering ...")
   RECORD updatedfilternames(
     1 filters[*]
       2 filter_id = f8
       2 upd_name = vc
   )
   DECLARE updated_filter_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updfiltername_size)),
     br_datamart_category bdc,
     br_datamart_filter bdf
    PLAN (d)
     JOIN (bdf
     WHERE (bdf.filter_mean=filter_to_upd_name->filters[d.seq].filter_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdc.category_type_flag=6)
    ORDER BY d.seq
    HEAD d.seq
     updated_filter_cnt = (updated_filter_cnt+ 1), stat = alterlist(updatedfilternames->filters,
      updated_filter_cnt), updatedfilternames->filters[updated_filter_cnt].upd_name = bdf
     .filter_display,
     updatedfilternames->filters[updated_filter_cnt].filter_id = filter_to_upd_name->filters[d.seq].
     filter_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting upd filter name")
   IF (size(updatedfilternames->filters,5) > 0)
    UPDATE  FROM br_datamart_filter bdf,
      (dummyt d  WITH seq = value(updated_filter_cnt))
     SET bdf.filter_display = updatedfilternames->filters[d.seq].upd_name, bdf.updt_id = reqinfo->
      updt_id, bdf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bdf.updt_task = reqinfo->updt_task, bdf.updt_applctx = reqinfo->updt_applctx, bdf.updt_cnt = (
      bdf.updt_cnt+ 1)
     PLAN (d
      WHERE (updatedfilternames->filters[d.seq].filter_id > 0))
      JOIN (bdf
      WHERE (bdf.br_datamart_filter_id=updatedfilternames->filters[d.seq].filter_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error upd filter name")
   ENDIF
   CALL bedlogmessage("updateFilterNames","Exiting ...")
 END ;Subroutine
 SUBROUTINE delfilters(null)
   CALL bedlogmessage("delFilters","Entering ...")
   EXECUTE bed_del_datamart_filters  WITH replace("REQUEST",filters_to_delete)
   CALL bedlogmessage("delFilters","Exiting ...")
 END ;Subroutine
 SUBROUTINE isfiltershared(filter_id)
   CALL bedlogmessage("isFilterShared","Entering ...")
   DECLARE result_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_report_filter_r bdrfr
    PLAN (bdrfr
     WHERE bdrfr.br_datamart_filter_id=filter_id)
    DETAIL
     result_cnt = (result_cnt+ 1)
    WITH nocounter
   ;end select
   IF (result_cnt > 1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   CALL bedlogmessage("isFilterShared","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatefilterdefaults(null)
   CALL bedlogmessage("updateFilterDefaults","Entering ...")
   RECORD updatedfilterdefaults(
     1 filters[*]
       2 filter_id = f8
       2 filter_mean = vc
       2 unique_identifier = vc
       2 cv_display = vc
       2 cv_description = vc
       2 code_set = i4
       2 result_type_flag = i2
       2 qualifier_flag = i2
       2 result_value = vc
       2 order_detail_ind = i2
       2 group_name = vc
       2 group_ce_name = vc
       2 group_ce_concept_cki = vc
   )
   DECLARE updated_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updfildef_size)),
     br_datamart_filter bdf,
     br_datamart_default bdd,
     br_datamart_category bdc,
     br_datamart_report_filter_r bdrfr,
     br_datamart_report bdr
    PLAN (d)
     JOIN (bdf
     WHERE (bdf.filter_mean=filters_to_upd_def->filters[d.seq].filter_mean))
     JOIN (bdd
     WHERE bdd.br_datamart_filter_id=bdf.br_datamart_filter_id)
     JOIN (bdrfr
     WHERE bdrfr.br_datamart_filter_id=bdf.br_datamart_filter_id)
     JOIN (bdr
     WHERE bdr.br_datamart_report_id=bdrfr.br_datamart_report_id
      AND (bdr.report_mean=filters_to_upd_def->filters[d.seq].report_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdc.category_type_flag=6)
    ORDER BY d.seq, bdd.br_datamart_default_id
    HEAD bdd.br_datamart_default_id
     updated_cnt = (updated_cnt+ 1), stat = alterlist(updatedfilterdefaults->filters,updated_cnt),
     updatedfilterdefaults->filters[updated_cnt].filter_id = filters_to_upd_def->filters[d.seq].
     filter_id,
     updatedfilterdefaults->filters[updated_cnt].filter_mean = filters_to_upd_def->filters[d.seq].
     filter_mean, updatedfilterdefaults->filters[updated_cnt].unique_identifier = bdd
     .unique_identifier, updatedfilterdefaults->filters[updated_cnt].cv_display = bdd.cv_display,
     updatedfilterdefaults->filters[updated_cnt].cv_description = bdd.cv_description,
     updatedfilterdefaults->filters[updated_cnt].code_set = bdd.code_set, updatedfilterdefaults->
     filters[updated_cnt].result_type_flag = bdd.result_type_flag,
     updatedfilterdefaults->filters[updated_cnt].qualifier_flag = bdd.qualifier_flag,
     updatedfilterdefaults->filters[updated_cnt].result_value = bdd.result_value,
     updatedfilterdefaults->filters[updated_cnt].order_detail_ind = bdd.order_detail_ind,
     updatedfilterdefaults->filters[updated_cnt].group_name = bdd.group_name, updatedfilterdefaults->
     filters[updated_cnt].group_ce_name = bdd.group_ce_name, updatedfilterdefaults->filters[
     updated_cnt].group_ce_concept_cki = bdd.group_ce_concept_cki
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting upd fil def")
   IF (validate(debug,0)=1)
    CALL echorecord(filters_to_upd_def)
    CALL echorecord(updatedfilterdefaults)
   ENDIF
   DELETE  FROM (dummyt d  WITH seq = value(updfildef_size)),
     br_datamart_default bdd
    SET bdd.seq = 1
    PLAN (d)
     JOIN (bdd
     WHERE (bdd.br_datamart_filter_id=filters_to_upd_def->filters[d.seq].filter_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_default table")
   IF (updated_cnt > 0)
    INSERT  FROM br_datamart_default bdd,
      (dummyt d  WITH seq = updated_cnt)
     SET bdd.br_datamart_default_id = seq(bedrock_seq,nextval), bdd.br_datamart_filter_id =
      updatedfilterdefaults->filters[d.seq].filter_id, bdd.unique_identifier = updatedfilterdefaults
      ->filters[d.seq].unique_identifier,
      bdd.cv_display = updatedfilterdefaults->filters[d.seq].cv_display, bdd.cv_description =
      updatedfilterdefaults->filters[d.seq].cv_description, bdd.code_set = updatedfilterdefaults->
      filters[d.seq].code_set,
      bdd.result_type_flag = updatedfilterdefaults->filters[d.seq].result_type_flag, bdd
      .qualifier_flag = updatedfilterdefaults->filters[d.seq].qualifier_flag, bdd.result_value =
      updatedfilterdefaults->filters[d.seq].result_value,
      bdd.order_detail_ind = updatedfilterdefaults->filters[d.seq].order_detail_ind, bdd.group_name
       = updatedfilterdefaults->filters[d.seq].group_name, bdd.group_ce_name = updatedfilterdefaults
      ->filters[d.seq].group_ce_name,
      bdd.group_ce_concept_cki = updatedfilterdefaults->filters[d.seq].group_ce_concept_cki, bdd
      .updt_applctx = reqinfo->updt_applctx, bdd.updt_id = reqinfo->updt_id,
      bdd.updt_cnt = 0, bdd.updt_task = reqinfo->updt_task, bdd.updt_dt_tm = cnvtdatetime(curdate,
       curtime3)
     PLAN (d)
      JOIN (bdd)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error inserting into br_datamart_default table")
   ENDIF
   CALL bedlogmessage("updateFilterDefaults","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatefiltertext(null)
   CALL bedlogmessage("updateFilterText","Entering ...")
   RECORD updatedfiltertext(
     1 filters[*]
       2 filter_id = f8
       2 text_type_mean = vc
       2 upd_text_id = f8
       2 upd_text = vc
   )
   DECLARE updated_cnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echorecord(filters_to_upd_text)
   ENDIF
   CALL populatecomponentlists(null)
   FOR (fil_index = 1 TO size(filters_to_upd_text->filters,5))
     SET loc = locateval(rep_index,1,size(std_content_list->reports,5),filters_to_upd_text->filters[
      fil_index].report_mean,std_content_list->reports[rep_index].report_mean)
     SET fil_loc = locateval(fil_position,1,size(std_content_list->reports[loc].filters,5),
      filters_to_upd_text->filters[fil_index].filter_mean,std_content_list->reports[loc].filters[
      fil_position].filter_mean)
     SET filters_to_upd_text->filters[fil_index].std_filter_id = std_content_list->reports[loc].
     filters[fil_loc].filter_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updfiltext_size)),
     br_datamart_filter bdf,
     br_datamart_category bdc,
     br_datamart_text bdt,
     br_long_text blt
    PLAN (d)
     JOIN (bdf
     WHERE (bdf.br_datamart_filter_id=filters_to_upd_text->filters[d.seq].std_filter_id))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdc.category_type_flag=6)
     JOIN (bdt
     WHERE bdt.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdt.br_datamart_report_id=0.0
      AND bdt.br_datamart_filter_id=bdf.br_datamart_filter_id)
     JOIN (blt
     WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
      AND blt.parent_entity_id=bdt.br_datamart_text_id)
    ORDER BY d.seq, blt.long_text_id
    DETAIL
     updated_cnt = (updated_cnt+ 1), stat = alterlist(updatedfiltertext->filters,updated_cnt),
     updatedfiltertext->filters[updated_cnt].upd_text = blt.long_text,
     updatedfiltertext->filters[updated_cnt].text_type_mean = bdt.text_type_mean, updatedfiltertext->
     filters[updated_cnt].filter_id = filters_to_upd_text->filters[d.seq].filter_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting std fil text")
   IF (validate(debug,0)=1)
    CALL echorecord(updatedfiltertext)
   ENDIF
   IF (size(updatedfiltertext->filters,5) > 0)
    DECLARE text_cnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(updated_cnt)),
      br_datamart_text bdt,
      br_long_text blt
     PLAN (d)
      JOIN (bdt
      WHERE (bdt.br_datamart_filter_id=updatedfiltertext->filters[d.seq].filter_id)
       AND bdt.br_datamart_report_id=0.0
       AND (bdt.text_type_mean=updatedfiltertext->filters[d.seq].text_type_mean))
      JOIN (blt
      WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
       AND blt.parent_entity_id=bdt.br_datamart_text_id)
     ORDER BY bdt.text_seq
     DETAIL
      IF (d.seq=bdt.text_seq)
       updatedfiltertext->filters[d.seq].upd_text_id = blt.long_text_id
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error getting fil text id")
    IF (validate(debug,0)=1)
     CALL echorecord(updatedfiltertext)
    ENDIF
    UPDATE  FROM br_long_text blt,
      (dummyt d  WITH seq = value(updated_cnt))
     SET blt.long_text = updatedfiltertext->filters[d.seq].upd_text, blt.updt_id = reqinfo->updt_id,
      blt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      blt.updt_task = reqinfo->updt_task, blt.updt_applctx = reqinfo->updt_applctx, blt.updt_cnt = (
      blt.updt_cnt+ 1)
     PLAN (d
      WHERE (updatedfiltertext->filters[d.seq].upd_text_id > 0))
      JOIN (blt
      WHERE (blt.long_text_id=updatedfiltertext->filters[d.seq].upd_text_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error upd fil text id")
   ENDIF
   CALL bedlogmessage("updateFilterText","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatecomponentlists(null)
   DECLARE report_cnt = i4 WITH protect, noconstant(0)
   DECLARE filter_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category bdc,
     br_datamart_report bdr,
     br_datamart_report_filter_r bdrfr,
     br_datamart_filter bdf
    PLAN (bdc
     WHERE bdc.category_type_flag=6)
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
   CALL bederrorcheck("Error while getting standard contents")
 END ;Subroutine
 SUBROUTINE updatefilterlimit(null)
   CALL bedlogmessage("updateFilterLimit","Entering ...")
   RECORD updatedfilterlimits(
     1 filters[*]
       2 filter_id = f8
       2 upd_filter_limit = i4
   )
   DECLARE updated_filter_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(updfillimit_size)),
     br_datamart_category bdc,
     br_datamart_filter bdf
    PLAN (d)
     JOIN (bdf
     WHERE (bdf.filter_mean=filters_to_upd_filter_limit->filters[d.seq].filter_mean))
     JOIN (bdc
     WHERE bdc.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdc.category_type_flag=6)
    ORDER BY d.seq
    HEAD d.seq
     updated_filter_cnt = (updated_filter_cnt+ 1), stat = alterlist(updatedfilterlimits->filters,
      updated_filter_cnt), updatedfilterlimits->filters[updated_filter_cnt].upd_filter_limit = bdf
     .filter_limit,
     updatedfilterlimits->filters[updated_filter_cnt].filter_id = filters_to_upd_filter_limit->
     filters[d.seq].filter_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error getting upd filter limit")
   IF (size(updatedfilterlimits->filters,5) > 0)
    UPDATE  FROM br_datamart_filter bdf,
      (dummyt d  WITH seq = value(updated_filter_cnt))
     SET bdf.filter_limit = updatedfilterlimits->filters[d.seq].upd_filter_limit, bdf.updt_id =
      reqinfo->updt_id, bdf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bdf.updt_task = reqinfo->updt_task, bdf.updt_applctx = reqinfo->updt_applctx, bdf.updt_cnt = (
      bdf.updt_cnt+ 1)
     PLAN (d
      WHERE (updatedfilterlimits->filters[d.seq].filter_id > 0))
      JOIN (bdf
      WHERE (bdf.br_datamart_filter_id=updatedfilterlimits->filters[d.seq].filter_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error upd filter limit")
   ENDIF
   CALL bedlogmessage("updateFilterLimit","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
