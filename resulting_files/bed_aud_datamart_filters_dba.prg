CREATE PROGRAM bed_aud_datamart_filters:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 category_id = f8
    1 flexes[*]
      2 flex_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tmpreply(
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
     2 sequence = i4
     2 show_loc_hierarchy = i2
 ) WITH protect
 RECORD topic_filters(
   1 filters[*]
     2 filter_id = f8
     2 filter_mean = vc
     2 filter_category_id = f8
     2 filter_category_mean = vc
     2 filter_category_type_mean = vc
     2 filter_display = vc
     2 filter_seq = i4
 ) WITH protect
 RECORD filter_flexes(
   1 flexes[*]
     2 flex_id = f8
 ) WITH protect
 RECORD filter_map_values(
   1 map_values[*]
     2 map_data_type_disp = vc
     2 mapping_info
       3 map_data_type_cd = f8
       3 millennium_entity = vc
       3 millennium_id = f8
       3 millennium_disp = vc
       3 millennium_desc = vc
       3 mapped_to_code = vc
       3 mapped_to_desc = vc
     2 negation_info
       3 mapped_to_code = vc
       3 mapped_to_desc = vc
     2 value_type = i2
     2 value_seq = i4
     2 group_seq = i4
     2 qual_flag = i2
     2 flex_id = f8
     2 last_updt_dt_tm = dq8
     2 last_updt_by_id = f8
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
 DECLARE audit_type_col = i4 WITH protect, constant(1)
 DECLARE topic_name_col = i4 WITH protect, constant(2)
 DECLARE filter_seq_col = i4 WITH protect, constant(3)
 DECLARE filter_mean_col = i4 WITH protect, constant(4)
 DECLARE filter_type_col = i4 WITH protect, constant(5)
 DECLARE filter_name_col = i4 WITH protect, constant(6)
 DECLARE flex_disp_col = i4 WITH protect, constant(7)
 DECLARE saved_value_col = i4 WITH protect, constant(8)
 DECLARE desc_col = i4 WITH protect, constant(9)
 DECLARE event_set_col = i4 WITH protect, constant(10)
 DECLARE code_value_col = i4 WITH protect, constant(11)
 DECLARE value_type_col = i4 WITH protect, constant(12)
 DECLARE value_seq_col = i4 WITH protect, constant(13)
 DECLARE val_grp_seq_col = i4 WITH protect, constant(14)
 DECLARE qualifier_col = i4 WITH protect, constant(15)
 DECLARE map_type_col = i4 WITH protect, constant(16)
 DECLARE map_cd1_col = i4 WITH protect, constant(17)
 DECLARE map_desc1_col = i4 WITH protect, constant(18)
 DECLARE map_cd2_col = i4 WITH protect, constant(19)
 DECLARE map_desc2_col = i4 WITH protect, constant(20)
 DECLARE updated_tm_col = i4 WITH protect, constant(21)
 DECLARE updated_by_col = i4 WITH protect, constant(22)
 DECLARE num_columns = i4 WITH protect, constant(22)
 DECLARE location_code_set = i4 WITH protect, constant(220)
 DECLARE default_setting = vc WITH protect, constant("<Default Setting>")
 DECLARE report_type = i2 WITH protect, constant(0)
 DECLARE mpage_type = i2 WITH protect, constant(1)
 DECLARE health_report = i2 WITH protect, constant(2)
 DECLARE advisor_report = i2 WITH protect, constant(3)
 DECLARE infection_report = i2 WITH protect, constant(4)
 DECLARE equality_report = i2 WITH protect, constant(5)
 DECLARE not_flexed = i2 WITH protect, constant(0)
 DECLARE position_flexing = i2 WITH protect, constant(1)
 DECLARE facility_flexing = i2 WITH protect, constant(2)
 DECLARE pos_loc_flexing = i2 WITH protect, constant(3)
 DECLARE always_parent_filter = i2 WITH protect, constant(0)
 DECLARE possible_child_filter = i2 WITH protect, constant(1)
 DECLARE code_set_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "CODE_SET"))
 DECLARE dta_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,"DTA"))
 DECLARE dta_alpha_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "DTA_ALPHA"))
 DECLARE event_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,"EVENT"))
 DECLARE event_alpha_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "EVENT_ALPHA"))
 DECLARE hme_sat_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,"HME_SAT")
  )
 DECLARE location_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "LOCATION"))
 DECLARE negation_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "NEGATION"))
 DECLARE order_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,"ORDER"))
 DECLARE patient_ed_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "PATIENT_ED"))
 DECLARE event_num_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "EVENT_NUM"))
 DECLARE dta_numeric_map_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002871,
   "DTA_NUMERIC"))
 DECLARE category_type = vc WITH protect, noconstant(" ")
 DECLARE category_name = vc WITH protect, noconstant(" ")
 DECLARE category_flex = i2 WITH protect, noconstant(0)
 DECLARE temp_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_reply_itr = i4 WITH protect, noconstant(0)
 DECLARE initializeflexestofilter(dummyvar=i2) = null
 DECLARE initializecolumnheaders(dummyvar=i2) = null
 DECLARE retrievecategoryinfo(category_id=f8) = null
 DECLARE retrievelayoutparams(category_id=f8) = null
 DECLARE populatetopicfilters(category_id=f8) = null
 DECLARE populatelochierarchy(dummyvar=i2) = null
 DECLARE populateflexsettings(dummyvar=i2) = null
 DECLARE populateposlocflexsettings(dummyvar=i2) = null
 DECLARE populateupdatedbyinfo(dummyvar=i2) = null
 DECLARE populatereplyfromtemp(dummyvar=i2) = null
 SUBROUTINE initializeflexestofilter(dummyvar)
   CALL bedlogmessage("initializeFlexesToFilter","Entering ..")
   DECLARE filter_values_by_flex = i2 WITH protect, noconstant(false)
   IF (validate(request->flexes)=true)
    IF (size(request->flexes,5) > 0)
     SET stat = alterlist(filter_flexes->flexes,size(request->flexes,5))
     DECLARE flexes_cnt = i4 WITH protect, noconstant(0)
     SET filter_values_by_flex = true
     FOR (flexes_cnt = 1 TO size(request->flexes,5))
       SET filter_flexes->flexes[flexes_cnt].flex_id = request->flexes[flexes_cnt].flex_id
     ENDFOR
    ENDIF
   ENDIF
   IF (filter_values_by_flex=false)
    SET stat = alterlist(filter_flexes->flexes,1)
    SET filter_flexes->flexes[1].flex_id = 0.0
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(filter_flexes)
   ENDIF
   CALL bederrorcheck("Err01: Error initializing flexes to filter.")
   CALL bedlogmessage("initializeFlexesToFilter","Exiting ...")
 END ;Subroutine
 SUBROUTINE initializecolumnheaders(dummyvar)
   CALL bedlogmessage("initializeColumnHeaders","Entering ...")
   SET stat = alterlist(reply->collist,num_columns)
   SET reply->collist[audit_type_col].header_text = "Audit Type"
   SET reply->collist[audit_type_col].data_type = 1
   SET reply->collist[audit_type_col].hide_ind = false
   SET reply->collist[topic_name_col].header_text = "Topic Name"
   SET reply->collist[topic_name_col].data_type = 1
   SET reply->collist[topic_name_col].hide_ind = false
   SET reply->collist[filter_mean_col].header_text = "Filter Meaning"
   SET reply->collist[filter_mean_col].data_type = 1
   SET reply->collist[filter_mean_col].hide_ind = false
   SET reply->collist[filter_name_col].header_text = "Filter Name"
   SET reply->collist[filter_name_col].data_type = 1
   SET reply->collist[filter_name_col].hide_ind = false
   SET reply->collist[filter_seq_col].header_text = "Filter Sequence"
   SET reply->collist[filter_seq_col].data_type = 3
   SET reply->collist[filter_seq_col].hide_ind = false
   SET reply->collist[filter_type_col].header_text = "Filter Type Meaning"
   SET reply->collist[filter_type_col].data_type = 1
   SET reply->collist[filter_type_col].hide_ind = false
   SET reply->collist[saved_value_col].header_text = "Saved Value"
   SET reply->collist[saved_value_col].data_type = 1
   SET reply->collist[saved_value_col].hide_ind = false
   SET reply->collist[desc_col].header_text = "Description"
   SET reply->collist[desc_col].data_type = 1
   SET reply->collist[desc_col].hide_ind = false
   SET reply->collist[event_set_col].header_text = "Event Set Name"
   SET reply->collist[event_set_col].data_type = 1
   SET reply->collist[event_set_col].hide_ind = false
   SET reply->collist[code_value_col].header_text = "Code Value/ID"
   SET reply->collist[code_value_col].data_type = 2
   SET reply->collist[code_value_col].hide_ind = false
   SET reply->collist[value_type_col].header_text = "Value Type"
   SET reply->collist[value_type_col].data_type = 1
   SET reply->collist[value_type_col].hide_ind = false
   SET reply->collist[value_seq_col].header_text = "Value Sequence"
   SET reply->collist[value_seq_col].data_type = 1
   SET reply->collist[value_seq_col].hide_ind = false
   SET reply->collist[val_grp_seq_col].header_text = "Value Group Sequence"
   SET reply->collist[val_grp_seq_col].data_type = 1
   SET reply->collist[val_grp_seq_col].hide_ind = false
   SET reply->collist[qualifier_col].header_text = "Qualifier"
   SET reply->collist[qualifier_col].data_type = 1
   SET reply->collist[qualifier_col].hide_ind = false
   SET reply->collist[flex_disp_col].header_text = "Flex Display"
   SET reply->collist[flex_disp_col].data_type = 1
   SET reply->collist[flex_disp_col].hide_ind = false
   SET reply->collist[map_type_col].header_text = "Map Type"
   SET reply->collist[map_type_col].data_type = 1
   SET reply->collist[map_type_col].hide_ind = true
   SET reply->collist[map_cd1_col].header_text = "Mapped to Code 1"
   SET reply->collist[map_cd1_col].data_type = 1
   SET reply->collist[map_cd1_col].hide_ind = true
   SET reply->collist[map_desc1_col].header_text = "Mapped to Description 1"
   SET reply->collist[map_desc1_col].data_type = 1
   SET reply->collist[map_desc1_col].hide_ind = true
   SET reply->collist[map_cd2_col].header_text = "Mapped to Code 2"
   SET reply->collist[map_cd2_col].data_type = 1
   SET reply->collist[map_cd2_col].hide_ind = true
   SET reply->collist[map_desc2_col].header_text = "Mapped to Description 2"
   SET reply->collist[map_desc2_col].data_type = 1
   SET reply->collist[map_desc2_col].hide_ind = true
   SET reply->collist[updated_tm_col].header_text = "Last Update Date/Time"
   SET reply->collist[updated_tm_col].data_type = 1
   SET reply->collist[updated_tm_col].hide_ind = false
   SET reply->collist[updated_by_col].header_text = "Last Update By"
   SET reply->collist[updated_by_col].data_type = 1
   SET reply->collist[updated_by_col].hide_ind = false
   CALL bederrorcheck("Err02: Error initializing column headers")
   CALL bedlogmessage("initializeColumnHeaders","Exiting ...")
 END ;Subroutine
 SUBROUTINE retrievecategoryinfo(category_id)
   CALL bedlogmessage("retrieveCategoryInfo","Entering ...")
   SELECT INTO "nl:"
    FROM br_datamart_category c
    PLAN (c
     WHERE c.br_datamart_category_id=category_id)
    DETAIL
     IF (c.category_type_flag=report_type)
      category_type = "Report"
     ELSEIF (c.category_type_flag=mpage_type)
      category_type = "MPage"
     ELSEIF (c.category_type_flag=health_report)
      category_type = "HealthAware"
     ELSEIF (c.category_type_flag=advisor_report)
      category_type = "Advisor"
     ELSEIF (c.category_type_flag=infection_report)
      category_type = "Infection Control"
     ELSEIF (c.category_type_flag=equality_report)
      category_type = "eQuality"
     ENDIF
     category_name = c.category_name, category_flex = c.flex_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck("Err03: Error retrieving category information")
   CALL bedlogmessage("retrieveCategoryInfo","Exiting ...")
 END ;Subroutine
 SUBROUTINE retrievelayoutparams(category_id)
   CALL bedlogmessage("retrieveLayoutParams","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SET flex_itr = 0
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_datamart_category dc,
     br_datamart_report dr
    PLAN (dv
     WHERE dv.br_datamart_category_id=category_id
      AND dv.parent_entity_name="BR_DATAMART_REPORT"
      AND dv.br_datamart_filter_id=0
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (dc
     WHERE dc.br_datamart_category_id=dv.br_datamart_category_id
      AND dc.category_type_flag IN (mpage_type, equality_report))
     JOIN (dr
     WHERE dr.br_datamart_report_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = dr.report_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id
     IF (dv.mpage_param_mean=" ")
      IF (dv.value_type_flag=1)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Left column"
      ELSEIF (dv.value_type_flag=0)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Center column"
      ELSEIF (dv.value_type_flag=2)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Right column"
      ELSEIF (dv.value_type_flag=3)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Organizer"
      ELSE
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
        .value_type_flag)
      ENDIF
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(tmpreply)
   ENDIF
   CALL bederrorcheck("Err04: Error Retrieving layout parameters.")
   CALL bedlogmessage("retrieveLayoutParams","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatetopicfilters(category_id)
   CALL bedlogmessage("populateTopicFilters","Entering ...")
   DECLARE topic_filter_cnt = i4 WITH protect, noconstant(0)
   SET flex_itr = 0
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_value v,
     br_datamart_filter_category fc
    PLAN (f
     WHERE f.br_datamart_category_id=category_id)
     JOIN (v
     WHERE v.br_datamart_filter_id=f.br_datamart_filter_id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),v.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (fc
     WHERE fc.filter_category_mean=outerjoin(f.filter_category_mean))
    ORDER BY f.filter_seq, f.br_datamart_filter_id
    HEAD f.br_datamart_filter_id
     topic_filter_cnt = (topic_filter_cnt+ 1), stat = alterlist(topic_filters->filters,
      topic_filter_cnt), topic_filters->filters[topic_filter_cnt].filter_id = f.br_datamart_filter_id,
     topic_filters->filters[topic_filter_cnt].filter_mean = f.filter_mean, topic_filters->filters[
     topic_filter_cnt].filter_category_id = fc.br_datamart_filter_category_id, topic_filters->
     filters[topic_filter_cnt].filter_category_mean = f.filter_category_mean,
     topic_filters->filters[topic_filter_cnt].filter_category_type_mean = fc
     .filter_category_type_mean, topic_filters->filters[topic_filter_cnt].filter_display = f
     .filter_display, topic_filters->filters[topic_filter_cnt].filter_seq = f.filter_seq
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(topic_filters)
   ENDIF
   CALL bederrorcheck("Err05: Error populating topic filters.")
   CALL bedlogmessage("populateTopicFilters","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatelochierarchy(dummyvar)
   CALL bedlogmessage("populateLocHierarchy","Entering ...")
   DECLARE display = vc WITH protect, noconstant(" ")
   DECLARE description = vc WITH protect, noconstant(" ")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   IF (temp_reply_cnt=0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_reply_cnt),
     code_value c,
     location_group lg,
     code_value c2,
     location_group lg2,
     code_value c3,
     location_group lg3,
     code_value c4,
     location_group lg4,
     code_value c5
    PLAN (d
     WHERE (tmpreply->rowlist[d.seq].show_loc_hierarchy=true))
     JOIN (c
     WHERE (c.code_value=tmpreply->rowlist[d.seq].celllist[code_value_col].double_value)
      AND c.code_set=location_code_set)
     JOIN (lg
     WHERE lg.child_loc_cd=c.code_value
      AND lg.root_loc_cd=0
      AND lg.active_ind=true)
     JOIN (c2
     WHERE c2.code_value=lg.parent_loc_cd)
     JOIN (lg2
     WHERE lg2.child_loc_cd=c2.code_value
      AND lg2.root_loc_cd=0
      AND lg2.active_ind=true)
     JOIN (c3
     WHERE c3.code_value=lg2.parent_loc_cd)
     JOIN (lg3
     WHERE lg3.child_loc_cd=outerjoin(c3.code_value)
      AND lg3.root_loc_cd=outerjoin(0)
      AND lg3.active_ind=outerjoin(true))
     JOIN (c4
     WHERE c4.code_value=outerjoin(lg3.parent_loc_cd))
     JOIN (lg4
     WHERE lg4.child_loc_cd=outerjoin(c4.code_value)
      AND lg4.root_loc_cd=outerjoin(0)
      AND lg4.active_ind=outerjoin(true))
     JOIN (c5
     WHERE c5.code_value=outerjoin(lg4.parent_loc_cd))
    DETAIL
     display = concat(trim(c2.display),"/",tmpreply->rowlist[d.seq].celllist[saved_value_col].
      string_value), description = concat(trim(c2.description),"/",tmpreply->rowlist[d.seq].celllist[
      desc_col].string_value)
     IF (c3.display > " ")
      display = concat(trim(c3.display),"/",display), description = concat(trim(c3.description),"/",
       description)
     ENDIF
     IF (c4.display > " ")
      display = concat(trim(c4.display),"/",display), description = concat(trim(c4.description),"/",
       description)
     ENDIF
     IF (c5.display > " ")
      display = concat(trim(c5.display),"/",display), description = concat(trim(c5.description),"/",
       description)
     ENDIF
     tmpreply->rowlist[d.seq].celllist[saved_value_col].string_value = display, tmpreply->rowlist[d
     .seq].celllist[desc_col].string_value = description
    WITH nocounter
   ;end select
   CALL bederrorcheck("Err06: Error populating location hierarchy.")
   CALL bedlogmessage("populateLocHierarchy","Exiting ...")
 END ;Subroutine
 SUBROUTINE populateflexsettings(dummyvar)
   CALL bedlogmessage("populateFlexSettings","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   IF (temp_reply_cnt=0)
    GO TO exit_script
   ENDIF
   IF (category_flex IN (position_flexing, facility_flexing))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = temp_reply_cnt),
      br_datamart_flex f,
      code_value cv
     PLAN (d)
      JOIN (f
      WHERE (f.br_datamart_flex_id=tmpreply->rowlist[d.seq].celllist[flex_disp_col].double_value))
      JOIN (cv
      WHERE cv.code_value=outerjoin(f.parent_entity_id))
     DETAIL
      IF ((tmpreply->rowlist[d.seq].celllist[flex_disp_col].double_value=0))
       tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value = default_setting
      ELSE
       tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value = cv.display
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (category_flex=pos_loc_flexing)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = temp_reply_cnt),
      br_datamart_flex f1,
      br_datamart_flex f2,
      code_value cv1,
      code_value cv2
     PLAN (d)
      JOIN (f1
      WHERE (f1.br_datamart_flex_id=tmpreply->rowlist[d.seq].celllist[flex_disp_col].double_value))
      JOIN (f2
      WHERE f2.br_datamart_flex_id=f1.grouper_flex_id)
      JOIN (cv1
      WHERE cv1.code_value=outerjoin(f1.parent_entity_id))
      JOIN (cv2
      WHERE cv2.code_value=outerjoin(f2.parent_entity_id))
     DETAIL
      IF (f1.grouper_ind=true
       AND cv2.code_value > 0)
       tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value = trim(cv2.display), tmpreply->
       rowlist[d.seq].celllist[flex_disp_col].double_value = cv1.code_value
      ELSEIF (f1.grouper_ind=0
       AND cv1.code_value > 0)
       tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value = build2(trim(cv1.display),
        " (All Facilities)"), tmpreply->rowlist[d.seq].celllist[flex_disp_col].double_value = 0.0
      ELSE
       tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value = default_setting
      ENDIF
     WITH nocounter
    ;end select
    CALL populateposlocflexsettings(0)
   ELSE
    FOR (temp_reply_itr = 1 TO temp_reply_cnt)
      SET tmpreply->rowlist[temp_reply_itr].celllist[flex_disp_col].string_value = default_setting
    ENDFOR
   ENDIF
   CALL bederrorcheck("Err07: Error populating flex settings.")
   CALL bedlogmessage("populateFlexSettings","Exiting ...")
 END ;Subroutine
 SUBROUTINE populateposlocflexsettings(dummyvar)
   CALL bedlogmessage("populatePosLocFlexSettings","Entering ...")
   DECLARE location_cd = f8 WITH protect, noconstant(0.0)
   DECLARE lochierarchydesc = vc WITH protect, noconstant(" ")
   DECLARE lochierdescmapcnt = i4 WITH protect, noconstant(0)
   DECLARE lochierdescmapitr = i4 WITH protect, noconstant(0)
   DECLARE lochierdescindex = i4 WITH protect, noconstant(0)
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   IF (temp_reply_cnt=0)
    GO TO exit_script
   ENDIF
   RECORD lochierarchydescmap(
     1 codetodesclist[*]
       2 location_cd = f8
       2 location_hierarchy_desc = vc
   ) WITH protect
   FREE RECORD getlochierrequest
   RECORD getlochierrequest(
     1 location_cd = f8
   )
   FREE RECORD getlochierreply
   RECORD getlochierreply(
     1 facility[*]
       2 code_value = f8
       2 display = vc
       2 description = vc
       2 meaning = vc
       2 building[*]
         3 code_value = f8
         3 display = vc
         3 description = vc
         3 meaning = vc
         3 unit[*]
           4 code_value = f8
           4 display = vc
           4 description = vc
           4 meaning = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FOR (temp_reply_itr = 1 TO temp_reply_cnt)
    SET location_cd = tmpreply->rowlist[temp_reply_itr].celllist[flex_disp_col].double_value
    IF (location_cd > 0)
     SET lochierdescmapcnt = size(lochierarchydescmap->codetodesclist,5)
     SET lochierdescindex = locateval(lochierdescmapitr,1,lochierdescmapcnt,location_cd,
      lochierarchydescmap->codetodesclist[lochierdescmapitr].location_cd)
     IF (lochierdescindex > 0)
      SET lochierarchydesc = lochierarchydescmap->codetodesclist[lochierdescindex].
      location_hierarchy_desc
     ELSE
      SET getlochierrequest->location_cd = location_cd
      EXECUTE bed_get_location_hierarchy  WITH replace("REQUEST",getlochierrequest), replace("REPLY",
       getlochierreply)
      IF (validate(debug,0)=1)
       CALL echorecord(getlochierrequest)
       CALL echorecord(getlochierreply)
      ENDIF
      SET lochierarchydesc = getlochierreply->facility[1].description
      IF (size(getlochierreply->facility[1].building,5) > 0)
       SET lochierarchydesc = build2(lochierarchydesc,"\",getlochierreply->facility[1].building[1].
        description)
       IF (size(getlochierreply->facility[1].building[1].unit,5) > 0)
        SET lochierarchydesc = build2(lochierarchydesc,"\",getlochierreply->facility[1].building[1].
         unit[1].description)
       ENDIF
      ENDIF
      SET stat = alterlist(lochierarchydescmap->codetodesclist,(lochierdescmapcnt+ 1))
      SET lochierarchydescmap->codetodesclist[(lochierdescmapcnt+ 1)].location_cd = location_cd
      SET lochierarchydescmap->codetodesclist[(lochierdescmapcnt+ 1)].location_hierarchy_desc =
      lochierarchydesc
     ENDIF
     SET tmpreply->rowlist[temp_reply_itr].celllist[flex_disp_col].string_value = build2(tmpreply->
      rowlist[temp_reply_itr].celllist[flex_disp_col].string_value," (",lochierarchydesc,")")
    ENDIF
   ENDFOR
   CALL bederrorcheck("Err08: Error populating pos/loc flex settings.")
   CALL bedlogmessage("populatePosLocFlexSettings","Exiting ...")
 END ;Subroutine
 SUBROUTINE populateupdatedbyinfo(dummyvar)
   CALL bedlogmessage("populateUpdatedByInfo","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   IF (temp_reply_cnt=0)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_reply_cnt),
     person p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=tmpreply->rowlist[d.seq].celllist[updated_by_col].double_value))
    DETAIL
     tmpreply->rowlist[d.seq].celllist[updated_tm_col].string_value = trim(format(tmpreply->rowlist[d
       .seq].celllist[updated_tm_col].date_value,"@LONGDATETIME;;Q"),3), tmpreply->rowlist[d.seq].
     celllist[updated_by_col].string_value = concat(trim(p.name_first)," ",trim(p.name_last))
    WITH nocounter
   ;end select
   CALL bederrorcheck("Err09: Error populating updated by information.")
   CALL bedlogmessage("populateUpdatedByInfo","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereplyfromtemp(dummyvar)
   CALL bedlogmessage("populateReplyFromTemp","Entering ...")
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   IF (temp_reply_cnt=0)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(reply->rowlist,temp_reply_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_reply_cnt)
    ORDER BY tmpreply->rowlist[d.seq].celllist[filter_seq_col].nbr_value, tmpreply->rowlist[d.seq].
     sequence, cnvtupper(tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value)
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist[rcnt].celllist,num_columns), reply->rowlist[
     rcnt].celllist[audit_type_col].string_value = category_type,
     reply->rowlist[rcnt].celllist[topic_name_col].string_value = category_name, reply->rowlist[rcnt]
     .celllist[filter_mean_col].string_value = tmpreply->rowlist[d.seq].celllist[filter_mean_col].
     string_value, reply->rowlist[rcnt].celllist[filter_name_col].string_value = tmpreply->rowlist[d
     .seq].celllist[filter_name_col].string_value,
     reply->rowlist[rcnt].celllist[filter_seq_col].nbr_value = tmpreply->rowlist[d.seq].celllist[
     filter_seq_col].nbr_value, reply->rowlist[rcnt].celllist[filter_type_col].string_value =
     tmpreply->rowlist[d.seq].celllist[filter_type_col].string_value, reply->rowlist[rcnt].celllist[
     saved_value_col].string_value = tmpreply->rowlist[d.seq].celllist[saved_value_col].string_value,
     reply->rowlist[rcnt].celllist[desc_col].string_value = tmpreply->rowlist[d.seq].celllist[
     desc_col].string_value, reply->rowlist[rcnt].celllist[event_set_col].string_value = tmpreply->
     rowlist[d.seq].celllist[event_set_col].string_value, reply->rowlist[rcnt].celllist[
     code_value_col].double_value = tmpreply->rowlist[d.seq].celllist[code_value_col].double_value,
     reply->rowlist[rcnt].celllist[value_type_col].string_value = tmpreply->rowlist[d.seq].celllist[
     value_type_col].string_value, reply->rowlist[rcnt].celllist[value_seq_col].string_value =
     tmpreply->rowlist[d.seq].celllist[value_seq_col].string_value, reply->rowlist[rcnt].celllist[
     val_grp_seq_col].string_value = tmpreply->rowlist[d.seq].celllist[val_grp_seq_col].string_value,
     reply->rowlist[rcnt].celllist[qualifier_col].string_value = tmpreply->rowlist[d.seq].celllist[
     qualifier_col].string_value, reply->rowlist[rcnt].celllist[flex_disp_col].string_value =
     tmpreply->rowlist[d.seq].celllist[flex_disp_col].string_value, reply->rowlist[rcnt].celllist[
     map_type_col].string_value = tmpreply->rowlist[d.seq].celllist[map_type_col].string_value,
     reply->rowlist[rcnt].celllist[map_cd1_col].string_value = tmpreply->rowlist[d.seq].celllist[
     map_cd1_col].string_value, reply->rowlist[rcnt].celllist[map_desc1_col].string_value = tmpreply
     ->rowlist[d.seq].celllist[map_desc1_col].string_value, reply->rowlist[rcnt].celllist[map_cd2_col
     ].string_value = tmpreply->rowlist[d.seq].celllist[map_cd2_col].string_value,
     reply->rowlist[rcnt].celllist[map_desc2_col].string_value = tmpreply->rowlist[d.seq].celllist[
     map_desc2_col].string_value, reply->rowlist[rcnt].celllist[updated_tm_col].string_value =
     tmpreply->rowlist[d.seq].celllist[updated_tm_col].string_value, reply->rowlist[rcnt].celllist[
     updated_by_col].string_value = tmpreply->rowlist[d.seq].celllist[updated_by_col].string_value
    WITH nocounter
   ;end select
   CALL bederrorcheck("Err10: Error populating reply from temp reply.")
   CALL bedlogmessage("populateReplyFromTemp","Exiting ...")
 END ;Subroutine
 DECLARE setgenericfilterinfo(index=i4,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findgenericfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE getfiltervaluegroupseq(category_mean=vc,group_seq=i4) = vc
 DECLARE findcodesetfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmapfiltervals(id=f8,filter_cat_id=f8,mean=vc,category_mean=vc,display=vc,
  seq=i4) = null
 DECLARE populatemappinginfo(filter_id=f8,filter_cat_id=f8) = null
 DECLARE populatenegationinfo(filter_id=f8) = null
 DECLARE populatetmpreplyfrommapvalues(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE finddmscontenttypefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findproviderfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findepselectionfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findsynonymfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findiviewselectfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findorderfolderfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findorderfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findcegroupfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findeventsetfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findfacloctextfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findlookbackfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findnustatusfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmpsectparamsfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmultifreetextfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findyesnofiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findgenericccnfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findccnoversamplefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findccndatefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findsurgtrackviewfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findpfsingleormultiselectfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findedinstructionsfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findorderdetailsfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE finddtanomenfilterfals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findeventnomenfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findnomenfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findproblemfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findproblemreltnfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findprocedurefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmultumcatfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmultumlevelseqfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findoutcomevenuefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findhealthmaintenancefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findhcoselectionfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findeventconceptfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findallergycatfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findcustomfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findsynvaccgroupassignfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findsyncategoryassignfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findfreetextmapfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findmcpoolfiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findhcooversamplefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findhcodatefiltervals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findtherdupclassvals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE findcodesetfilteringvals(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE retrievegroupervalueforvitalsigns(id=f8,mean=vc,category_mean=vc,display=vc,seq=i4) = null
 DECLARE temp_reply_cnt = i4 WITH protect, noconstant(0)
 SUBROUTINE setgenericfilterinfo(index,mean,category_mean,display,seq)
   SET tmpreply->rowlist[index].celllist[filter_mean_col].string_value = mean
   SET tmpreply->rowlist[index].celllist[filter_name_col].string_value = display
   SET tmpreply->rowlist[index].celllist[filter_seq_col].nbr_value = seq
   SET tmpreply->rowlist[index].celllist[filter_type_col].string_value = category_mean
   IF (category_mean IN ("FACILITY", "EVENT", "PRIM_EVENT_SET", "ORDER", "DTA",
   "POWERPLAN", "MULTUM_CAT", "INTERQUAL_ACCT", "XR_TEMPLATE_DEFAULT", "YES_NO",
   "NUMERIC_VALUE"))
    SET tmpreply->rowlist[index].sequence = always_parent_filter
   ELSE
    SET tmpreply->rowlist[index].sequence = possible_child_filter
   ENDIF
 END ;Subroutine
 SUBROUTINE findgenericfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findGenericFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY cnvtupper(dv.freetext_desc), dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc, tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = cnvtstring(dv
      .qualifier_flag), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("GENERIC Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findGenericFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findcodesetfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCodeSetFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     code_value cv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (cv
     WHERE cv.code_value=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = cv.display, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = cv.description,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     getfiltervaluegroupseq(category_mean,dv.group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[
     flex_disp_col].double_value = dv.br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].
     celllist[updated_tm_col].date_value = dv.updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
     IF (category_mean="PRIM_EVENT_SET")
      tmpreply->rowlist[temp_reply_cnt].celllist[event_set_col].string_value = trim(dv.freetext_desc)
     ENDIF
     IF (cv.code_set=location_code_set)
      tmpreply->rowlist[temp_reply_cnt].show_loc_hierarchy = true
     ENDIF
    WITH nocounter
   ;end select
   IF (category_mean="EVENT_SET_SEQ")
    CALL retrievegroupervalueforvitalsigns(id,mean,category_mean,display,seq)
   ENDIF
   CALL bederrorcheck(build2("CODE_SET/CODE_SET_SHARED Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCodeSetFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE retrievegroupervalueforvitalsigns(id,mean,category_mean,display,seq)
   CALL bedlogmessage("retrieveGrouperValueForVitalSigns","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_value v,
     br_datamart_filter f2,
     br_datamart_flex df,
     code_value cv
    PLAN (f
     WHERE f.br_datamart_filter_id=id
      AND f.filter_mean="*VS_CE_SEQ")
     JOIN (v
     WHERE v.br_datamart_filter_id=f.br_datamart_filter_id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),v.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id)
      AND v.parent_entity_name="BR_DATAMART_FILTER")
     JOIN (f2
     WHERE f2.br_datamart_filter_id=v.parent_entity_id)
     JOIN (df
     WHERE df.br_datamart_flex_id=v.br_datamart_flex_id)
     JOIN (cv
     WHERE cv.code_value=df.parent_entity_id)
    ORDER BY f.filter_display, cv.display, v.value_seq
    HEAD v.value_seq
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[flex_disp_col].double_value = v.br_datamart_flex_id, tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = v.freetext_desc,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = v.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = f2.filter_display, tmpreply
     ->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(v.value_type_flag),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(v.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     getfiltervaluegroupseq(category_mean,v.group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[
     updated_tm_col].date_value = v.updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = v.updt_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("retrieveGrouperValueForVitalSigns","Exiting ...")
 END ;Subroutine
 SUBROUTINE getfiltervaluegroupseq(category_mean,group_seq)
   CALL bedlogmessage("getFilterValueGroupSeq","Entering ...")
   IF (category_mean="ADM_SRC_ASSIGN")
    IF (group_seq=1)
     RETURN("Non-Health Care Facility Point of Origin")
    ELSEIF (group_seq=2)
     RETURN("Clinic")
    ELSEIF (group_seq=3)
     RETURN("Transfer from a hospital (different facility)")
    ELSEIF (group_seq=4)
     RETURN("Transfer from a skilled nursing facility (SNF) or intermediate care facility (ICF)")
    ELSEIF (group_seq=5)
     RETURN("Transfer from another health care facility")
    ELSEIF (group_seq=6)
     RETURN("Emergency room")
    ELSEIF (group_seq=7)
     RETURN("Court/law enforcement")
    ELSEIF (group_seq=8)
     RETURN("Information not available")
    ELSEIF (group_seq=9)
     RETURN(concat(
      "Transfer from one distinct unit of the hospital to another distinct unit of the same hospital resulting in ",
      "a separate claim to the payer"))
    ELSEIF (group_seq=10)
     RETURN("Transfer from ambulatory surgery center")
    ELSEIF (group_seq=11)
     RETURN(
     "Transfer from hospice and is under a hospice plan of care or enrolled in a hospice program")
    ENDIF
   ELSEIF (category_mean="CAT_TYPE_ASSIGN")
    IF (group_seq=1)
     RETURN("Medications")
    ELSEIF (group_seq=2)
     RETURN("Labs")
    ELSEIF (group_seq=3)
     RETURN("Imaging")
    ELSEIF (group_seq=4)
     RETURN("Billing")
    ENDIF
   ELSEIF (category_mean="DISC_DISP_ASSIGN")
    IF (group_seq=1)
     RETURN("Discharged to home care or self care")
    ELSEIF (group_seq=2)
     RETURN("Discharged/transferred to a short term general hospital for inpatient care")
    ELSEIF (group_seq=3)
     RETURN(concat(
      "Discharged/transferred to skilled nursing facility (SNF) with Medicare certification in anticipation of ",
      "skilled care"))
    ELSEIF (group_seq=4)
     RETURN("Discharged/transferred to a facility that provides custodial or supportive care")
    ELSEIF (group_seq=5)
     RETURN("Discharged/transferred to a designated cancer center or children's hospital")
    ELSEIF (group_seq=6)
     RETURN(concat(
      "Discharged/transferred to home under care of organized home health service organization in anticipation ",
      "of covered skilled care"))
    ELSEIF (group_seq=7)
     RETURN("Left against medical advice or discontinued care")
    ELSEIF (group_seq=8)
     RETURN("Expired")
    ELSEIF (group_seq=9)
     RETURN("Discharged/transferred to court/law enforcement")
    ELSEIF (group_seq=10)
     RETURN("Discharged/transferred to a federal health care facility")
    ELSEIF (group_seq=11)
     RETURN("Hospice - home")
    ELSEIF (group_seq=12)
     RETURN("Hospice - medical facility (certified) providing hospice level of care")
    ELSEIF (group_seq=13)
     RETURN("Discharged/transferred to hospital-based Medicare approved swing bed")
    ELSEIF (group_seq=14)
     RETURN(concat(
      "Discharged/transferred to an inpatient rehabilitation facility (IRF) including rehabilitation distinct part ",
      "or unit of a hospital"))
    ELSEIF (group_seq=15)
     RETURN("Discharged/transferred to a Medicare certified long term care hospital (LTCH)")
    ELSEIF (group_seq=16)
     RETURN(
     "Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare"
     )
    ELSEIF (group_seq=17)
     RETURN(
     "Discharged/transferred to a psychiatric hospital or psychiatric distinct part or unit of a hospital"
     )
    ELSEIF (group_seq=18)
     RETURN("Discharged/transferred to a critical access hospital (CAH)")
    ELSEIF (group_seq=19)
     RETURN(
     "Discharged/transferred to another type of health care institution not defined elsewhere in this code list"
     )
    ENDIF
   ELSEIF (category_mean="DISC_DISP_ASSIGN_2")
    IF (group_seq=20)
     RETURN("Home")
    ELSEIF (group_seq=21)
     RETURN("Hospice - home")
    ELSEIF (group_seq=22)
     RETURN("Hospice - health care facility")
    ELSEIF (group_seq=23)
     RETURN("Acute care facility")
    ELSEIF (group_seq=24)
     RETURN("Other health care facility")
    ELSEIF (group_seq=25)
     RETURN("Expired")
    ELSEIF (group_seq=26)
     RETURN("Left against medical advice/AMA")
    ELSEIF (group_seq=27)
     RETURN("Not documented or unable to determine (UTD)")
    ENDIF
   ELSEIF (category_mean="TASK_TYPE_ASSIGN")
    IF (group_seq=1)
     RETURN("Medications")
    ELSEIF (group_seq=2)
     RETURN("Patient Assessments")
    ELSEIF (group_seq=3)
     RETURN("Patient Care")
    ELSEIF (group_seq=4)
     RETURN("Other Tasks")
    ELSEIF (group_seq=5)
     RETURN("Not Used")
    ENDIF
   ELSE
    RETURN(cnvtstring(group_seq))
   ENDIF
   CALL bederrorcheck("Get Filter Value Group Seq Error")
   CALL bedlogmessage("getFilterValueGroupSeq","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmapfiltervals(id,filter_cat_id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMapFilterVals","Entering ...")
   SET stat = initrec(filter_map_values)
   CALL populatemappinginfo(id,filter_cat_id)
   CALL populatenegationinfo(id)
   CALL populatetmpreplyfrommapvalues(id,mean,category_mean,display,seq)
   CALL bederrorcheck(build2("MAP Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMapFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatemappinginfo(filter_id,filter_cat_id)
   CALL bedlogmessage("populateMappingInfo","Entering ...")
   DECLARE map_values_cnt = i4 WITH protect, noconstant(0)
   DECLARE map_val_itr = i4 WITH protect, noconstant(0)
   DECLARE map_data_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE millennium_id = f8 WITH protect, noconstant(0.0)
   DECLARE millennium_disp = vc WITH protect, noconstant(" ")
   DECLARE code_display = vc WITH protect, noconstant(" ")
   DECLARE code_desc = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_datam_val_set_item_meas vi,
     br_datam_mapping_type mt,
     br_datam_val_set_item vs
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND dv.map_data_type_cd > 0
      AND dv.map_data_type_cd != negation_map_type_cd
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (vi
     WHERE vi.br_datam_val_set_item_id=dv.parent_entity_id2
      AND vi.br_datam_val_set_item_id > 0)
     JOIN (mt
     WHERE mt.br_datamart_category_id=dv.br_datamart_category_id
      AND mt.br_datamart_filter_category_id=filter_cat_id
      AND mt.map_data_type_cd=dv.map_data_type_cd)
     JOIN (vs
     WHERE vs.br_datam_val_set_item_id=dv.parent_entity_id2)
    ORDER BY dv.br_datamart_value_id, vi.br_datam_val_set_item_id, mt.map_data_type_display
    HEAD REPORT
     reply->collist[map_type_col].hide_ind = false, reply->collist[map_cd1_col].hide_ind = false,
     reply->collist[map_desc1_col].hide_ind = false
    HEAD dv.br_datamart_value_id
     stat = 0
    HEAD vi.br_datam_val_set_item_id
     map_values_cnt = (map_values_cnt+ 1), stat = alterlist(filter_map_values->map_values,
      map_values_cnt), filter_map_values->map_values[map_values_cnt].map_data_type_disp = mt
     .map_data_type_display,
     filter_map_values->map_values[map_values_cnt].mapping_info.map_data_type_cd = dv
     .map_data_type_cd, filter_map_values->map_values[map_values_cnt].mapping_info.millennium_entity
      = dv.parent_entity_name, filter_map_values->map_values[map_values_cnt].mapping_info.
     millennium_id = dv.parent_entity_id,
     filter_map_values->map_values[map_values_cnt].mapping_info.millennium_disp = dv.freetext_desc,
     filter_map_values->map_values[map_values_cnt].mapping_info.mapped_to_code = vs
     .source_vocab_item_ident, filter_map_values->map_values[map_values_cnt].mapping_info.
     mapped_to_desc = vi.vocab_item_desc,
     filter_map_values->map_values[map_values_cnt].value_type = dv.value_type_flag, filter_map_values
     ->map_values[map_values_cnt].value_seq = dv.value_seq, filter_map_values->map_values[
     map_values_cnt].group_seq = dv.group_seq,
     filter_map_values->map_values[map_values_cnt].qual_flag = dv.qualifier_flag, filter_map_values->
     map_values[map_values_cnt].flex_id = dv.br_datamart_flex_id, filter_map_values->map_values[
     map_values_cnt].last_updt_dt_tm = dv.updt_dt_tm,
     filter_map_values->map_values[map_values_cnt].last_updt_by_id = dv.updt_id
    WITH nocounter
   ;end select
   FOR (map_val_itr = 1 TO map_values_cnt)
     SET map_data_type_cd = filter_map_values->map_values[map_val_itr].mapping_info.map_data_type_cd
     SET millennium_id = filter_map_values->map_values[map_val_itr].mapping_info.millennium_id
     SET millennium_disp = filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp
     SET code_display = trim(uar_get_code_display(millennium_id))
     SET code_desc = trim(uar_get_code_description(millennium_id))
     IF (map_data_type_cd IN (code_set_map_type_cd, dta_map_type_cd, event_map_type_cd,
     location_map_type_cd, order_map_type_cd))
      SET filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = code_display
      SET filter_map_values->map_values[map_val_itr].mapping_info.millennium_desc = code_desc
     ELSEIF (map_data_type_cd IN (dta_alpha_map_type_cd, event_alpha_map_type_cd))
      SET filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = code_display
      SELECT INTO "nl:"
       FROM nomenclature n
       PLAN (n
        WHERE n.nomenclature_id=millennium_id)
       DETAIL
        code_display = trim(uar_get_code_display(n.source_vocabulary_cd)), filter_map_values->
        map_values[map_val_itr].mapping_info.millennium_disp = code_display
        IF (n.source_identifier > " ")
         filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = build2(
          code_display," - ",trim(n.source_identifier))
        ENDIF
        IF (n.short_string > " ")
         filter_map_values->map_values[map_val_itr].mapping_info.millennium_desc = trim(n
          .short_string)
        ELSE
         filter_map_values->map_values[map_val_itr].mapping_info.millennium_desc = trim(n
          .source_string)
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM br_datamart_value dv
       PLAN (dv
        WHERE dv.br_datamart_filter_id=id
         AND dv.parent_entity_name="CODE_VALUE"
         AND (dv.value_seq=filter_map_values->map_values[map_val_itr].value_seq))
       DETAIL
        code_display = uar_get_code_display(dv.parent_entity_id), filter_map_values->map_values[
        map_val_itr].mapping_info.millennium_desc = build2(code_display," - ",filter_map_values->
         map_values[map_val_itr].mapping_info.millennium_desc)
       WITH nocounter
      ;end select
     ELSEIF (map_data_type_cd=hme_sat_map_type_cd)
      SELECT INTO "nl:"
       FROM hm_expect_sat hm
       PLAN (hm
        WHERE hm.expect_sat_id=millennium_id)
       DETAIL
        filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = trim(hm
         .expect_sat_name)
       WITH nocounter
      ;end select
     ELSEIF (map_data_type_cd=patient_ed_map_type_cd)
      SELECT INTO "nl:"
       FROM pat_ed_reltn pat
       PLAN (pat
        WHERE pat.pat_ed_reltn_desc=millennium_disp)
       ORDER BY cnvtupper(pat.pat_ed_reltn_desc)
       DETAIL
        filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = trim(pat
         .pat_ed_reltn_desc)
       WITH nocounter
      ;end select
     ELSEIF (map_data_type_cd IN (event_num_map_type_cd, dta_numeric_map_type_cd))
      SET filter_map_values->map_values[map_val_itr].mapping_info.millennium_disp = millennium_disp
      SET filter_map_values->map_values[map_val_itr].mapping_info.millennium_desc = code_desc
     ENDIF
   ENDFOR
   CALL bederrorcheck(build2("MAP Mapping Info Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("populateMappingInfo","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatenegationinfo(filter_id)
   CALL bedlogmessage("populateNegationInfo","Entering ...")
   DECLARE map_val_itr = i4 WITH protect, noconstant(0)
   FOR (map_val_itr = 1 TO size(filter_map_values->map_values,5))
     SELECT INTO "nl:"
      FROM br_datamart_value dv,
       br_datam_val_set_item_meas vi,
       br_datam_val_set_item vs
      PLAN (dv
       WHERE dv.br_datamart_filter_id=id
        AND (dv.value_seq=filter_map_values->map_values[map_val_itr].value_seq)
        AND (dv.parent_entity_name=filter_map_values->map_values[map_val_itr].mapping_info.
       millennium_entity)
        AND (dv.parent_entity_id=filter_map_values->map_values[map_val_itr].mapping_info.
       millennium_id)
        AND dv.map_data_type_cd > 0
        AND dv.map_data_type_cd=negation_map_type_cd)
       JOIN (vi
       WHERE vi.br_datam_val_set_item_id=dv.parent_entity_id2
        AND vi.br_datam_val_set_item_id > 0)
       JOIN (vs
       WHERE vs.br_datam_val_set_item_id=dv.parent_entity_id2)
      ORDER BY dv.br_datamart_value_id, vi.br_datam_val_set_item_id
      HEAD REPORT
       reply->collist[map_cd2_col].hide_ind = false, reply->collist[map_desc2_col].hide_ind = false
      HEAD dv.br_datamart_value_id
       stat = 0
      HEAD vi.br_datam_val_set_item_id
       filter_map_values->map_values[map_val_itr].negation_info.mapped_to_code = vs
       .source_vocab_item_ident, filter_map_values->map_values[map_val_itr].negation_info.
       mapped_to_desc = vi.vocab_item_desc
      WITH nocounter
     ;end select
   ENDFOR
   CALL bederrorcheck(build2("MAP Negation Info Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("populateNegationInfo","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatetmpreplyfrommapvalues(id,mean,category_mean,display,seq)
   CALL bedlogmessage("populateTmpReplyFromMapValues","Entering ...")
   DECLARE map_values_cnt = i4 WITH protect, noconstant(size(filter_map_values->map_values,5))
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = map_values_cnt)
    PLAN (d)
    DETAIL
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[flex_disp_col].double_value = filter_map_values->map_values[d.seq].
     flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value =
     filter_map_values->map_values[d.seq].mapping_info.millennium_disp,
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = filter_map_values->
     map_values[d.seq].mapping_info.millennium_desc, tmpreply->rowlist[temp_reply_cnt].celllist[
     code_value_col].double_value = filter_map_values->map_values[d.seq].mapping_info.millennium_id
     IF ((filter_map_values->map_values[d.seq].mapping_info.map_data_type_cd=location_map_type_cd))
      tmpreply->rowlist[temp_reply_cnt].show_loc_hierarchy = true
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(
      filter_map_values->map_values[d.seq].value_type), tmpreply->rowlist[temp_reply_cnt].celllist[
     value_seq_col].string_value = cnvtstring(filter_map_values->map_values[d.seq].value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(
      filter_map_values->map_values[d.seq].group_seq)
     IF ((filter_map_values->map_values[d.seq].qual_flag=1))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "equal to"
     ELSEIF ((filter_map_values->map_values[d.seq].qual_flag=2))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "not equal to"
     ELSEIF ((filter_map_values->map_values[d.seq].qual_flag=3))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "greater than"
     ELSEIF ((filter_map_values->map_values[d.seq].qual_flag=4))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "less than"
     ELSEIF ((filter_map_values->map_values[d.seq].qual_flag=5))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "greater than or equal to"
     ELSEIF ((filter_map_values->map_values[d.seq].qual_flag=6))
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "less than or equal to"
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = cnvtstring(
       filter_map_values->map_values[d.seq].qual_flag)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[map_type_col].string_value = filter_map_values->
     map_values[d.seq].map_data_type_disp, tmpreply->rowlist[temp_reply_cnt].celllist[map_cd1_col].
     string_value = filter_map_values->map_values[d.seq].mapping_info.mapped_to_code, tmpreply->
     rowlist[temp_reply_cnt].celllist[map_desc1_col].string_value = filter_map_values->map_values[d
     .seq].mapping_info.mapped_to_desc,
     tmpreply->rowlist[temp_reply_cnt].celllist[map_cd2_col].string_value = filter_map_values->
     map_values[d.seq].negation_info.mapped_to_code, tmpreply->rowlist[temp_reply_cnt].celllist[
     map_desc2_col].string_value = filter_map_values->map_values[d.seq].negation_info.mapped_to_desc,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = filter_map_values->
     map_values[d.seq].last_updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = filter_map_values->
     map_values[d.seq].last_updt_by_id,
     CALL bederrorcheck(build2("MAP Populate Tmp Reply Error: BR_DATAMART_FILTER_ID = ",id)),
     CALL bedlogmessage("populateTmpReplyFromMapValues","Exiting ...")
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findproviderfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findProviderFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     prsnl p
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (p
     WHERE p.person_id=dv.parent_entity_id)
    ORDER BY cnvtupper(p.name_full_formatted), dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = p.name_full_formatted, tmpreply->
     rowlist[temp_reply_cnt].celllist[desc_col].string_value = p.name_full_formatted,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("PROVIDER Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findProviderFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE finddmscontenttypefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findDMSContentTypeFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     dms_content_type dct
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (dct
     WHERE dct.dms_content_type_id=dv.parent_entity_id)
    ORDER BY cnvtupper(dct.display), dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dct.display, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = dct.description,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("DMS_CONTENT_TYPE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findDMSContentTypeFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findepselectionfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findEPSelectionFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     person p
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (p
     WHERE p.person_id=dv.parent_entity_id)
    ORDER BY cnvtupper(p.name_full_formatted), dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = p.name_full_formatted, tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("EP_SELECTION Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findEPSelectionFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findsynonymfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findSynonymFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     order_catalog_synonym o
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (o
     WHERE o.synonym_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(o.mnemonic), tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("SYNONYM Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findSynonymFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findiviewselectfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findIViewSelectFilterVals","Entering ...")
   DECLARE iview_display = vc WITH protect, noconstant(" ")
   DECLARE iview_value_type = vc WITH protect, noconstant(" ")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.value_seq, dv.value_type_flag
    HEAD dv.value_seq
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id, tmpreply->rowlist[
     temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    DETAIL
     IF (dv.value_type_flag=1)
      iview_display = trim(dv.freetext_desc), iview_value_type = "1"
     ELSE
      iview_display = concat(iview_display,"/",trim(dv.freetext_desc)), iview_value_type = concat(
       iview_value_type,",",cnvtstring(dv.value_type_flag))
     ENDIF
    FOOT  dv.value_seq
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = iview_display,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = iview_value_type
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("IVIEW_SELECT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findIViewSelectFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findorderfolderfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findOrderFolderFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     alt_sel_cat cat
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (cat
     WHERE cat.alt_sel_category_id=dv.parent_entity_id)
    ORDER BY cnvtupper(dv.freetext_desc), dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = cat.long_description, tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = cnvtstring(dv
      .qualifier_flag), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("ORDER_FOLDER Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findOrderFolderFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findorderfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findOrderFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = uar_get_code_display(dv
      .parent_entity_id), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value =
     uar_get_code_description(dv.parent_entity_id),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("ORDER Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findOrderFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findcegroupfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCEGroupFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq)
     IF (dv.parent_entity_id > 0)
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = uar_get_code_display
      (dv.parent_entity_id)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = uar_get_code_description(dv
      .parent_entity_id), tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value =
     dv.parent_entity_id, tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value =
     cnvtstring(dv.value_type_flag),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
     IF (dv.value_seq=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "Numerator"
     ELSEIF (dv.value_seq=2)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "Denominator"
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("CE_GROUP Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCEGroupFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findeventsetfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findEventSetFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = uar_get_code_display(dv
      .parent_entity_id), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value =
     uar_get_code_description(dv.parent_entity_id),
     tmpreply->rowlist[temp_reply_cnt].celllist[event_set_col].string_value = trim(dv.freetext_desc),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("EVENT_SET Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findEventSetFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findfacloctextfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findFacLocTextFilterVals","Entering ...")
   DECLARE code_display = vc WITH protect, noconstant(" ")
   DECLARE code_description = vc WITH protect, noconstant(" ")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     code_display = uar_get_code_display(dv.parent_entity_id), code_description =
     uar_get_code_description(dv.parent_entity_id),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = concat(code_display,
      " - ",dv.freetext_desc), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value =
     concat(code_description," - ",dv.freetext_desc), tmpreply->rowlist[temp_reply_cnt].celllist[
     code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("FACILITY_LOC_TEXT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findFacLocTextFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findlookbackfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findLookBackFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.group_seq, dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = concat(trim(dv.freetext_desc)," ",
      uar_get_code_display(dv.parent_entity_id)), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col
     ].string_value = concat(trim(dv.freetext_desc)," ",uar_get_code_description(dv.parent_entity_id)
      ),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("LOOK_BACK Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findLookBackFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findnustatusfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findNUStatusFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = uar_get_code_display(dv
      .parent_entity_id), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value =
     uar_get_code_description(dv.parent_entity_id),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = trim(dv.freetext_desc),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id, tmpreply->
     rowlist[temp_reply_cnt].show_loc_hierarchy = true
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("NU_STATUS Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findNUStatusFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmpsectparamsfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMPSectParamsFilterVals","Entering ...")
   DECLARE mp_param_mean = vc WITH protect, noconstant(" ")
   DECLARE mp_param_value = vc WITH protect, noconstant(" ")
   DECLARE code_display = vc WITH protect, noconstant(" ")
   DECLARE code_description = vc WITH protect, noconstant(" ")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     mp_param_mean = trim(dv.mpage_param_mean), mp_param_value = trim(dv.mpage_param_value),
     code_display = uar_get_code_display(dv.parent_entity_id),
     code_description = uar_get_code_description(dv.parent_entity_id),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq)
     IF (code_display > " "
      AND code_description > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = concat(mp_param_mean,
       " / ",mp_param_value," ",code_display), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].
      string_value = concat(mp_param_mean," / ",mp_param_value," ",code_description)
      IF (((mp_param_mean="mp_look_back_units") OR (mp_param_mean="mp_look_back_cur_enc")) )
       IF (dv.value_type_flag=1)
        tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value =
        "All encounters - Specified time period"
       ELSEIF (dv.value_type_flag=2)
        tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value =
        "Current encounter - Specified time period"
       ENDIF
      ENDIF
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = concat(mp_param_mean,
       " / ",mp_param_value)
      IF (((mp_param_mean="mp_look_back_units") OR (mp_param_mean="mp_look_back_cur_enc")) )
       IF (dv.value_type_flag=1)
        tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "All encounters"
       ELSEIF (dv.value_type_flag=2)
        tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Current encounter"
       ENDIF
      ENDIF
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
     IF (mp_param_mean="mp_label")
      tmpreply->rowlist[temp_reply_cnt].sequence = 1
     ELSEIF (mp_param_mean="mp_nbr_label")
      tmpreply->rowlist[temp_reply_cnt].sequence = 2
     ELSEIF (mp_param_mean="mp_link")
      tmpreply->rowlist[temp_reply_cnt].sequence = 3
     ELSEIF (mp_param_mean="mp_add_label")
      tmpreply->rowlist[temp_reply_cnt].sequence = 4
     ELSEIF (mp_param_mean="mp_exp_collapse")
      tmpreply->rowlist[temp_reply_cnt].sequence = 5
     ELSEIF (mp_param_mean="mp_look_back")
      tmpreply->rowlist[temp_reply_cnt].sequence = 6
     ELSEIF (mp_param_mean="mp_look_back_units")
      tmpreply->rowlist[temp_reply_cnt].sequence = 7
     ELSEIF (mp_param_mean="mp_look_back_cur_enc")
      tmpreply->rowlist[temp_reply_cnt].sequence = 8
     ELSEIF (mp_param_mean="mp_max_results")
      tmpreply->rowlist[temp_reply_cnt].sequence = 9
     ELSEIF (mp_param_mean="mp_scrolling")
      tmpreply->rowlist[temp_reply_cnt].sequence = 10
     ELSEIF (mp_param_mean="mp_date_format_3")
      tmpreply->rowlist[temp_reply_cnt].sequence = 11
     ELSEIF (mp_param_mean="mp_date_format_4")
      tmpreply->rowlist[temp_reply_cnt].sequence = 12
     ELSEIF (mp_param_mean="mp_truncate_wrap")
      tmpreply->rowlist[temp_reply_cnt].sequence = 13
     ELSE
      tmpreply->rowlist[temp_reply_cnt].sequence = 100
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("MP_SECT_PARAMS Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMPSectParamsFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmultifreetextfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMultiFreetextFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc, tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq)
     IF (dv.value_seq=0)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "long name"
     ELSEIF (dv.value_seq=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "display name"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
     cnvtstring(dv.qualifier_flag), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].
     double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("MULTI_FREETEXT/MULTI_FREETEXT_SEQ Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMultiFreetextFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findyesnofiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findYesNoFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY cnvtupper(dv.freetext_desc), dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq)
     IF (trim(dv.freetext_desc)="1")
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = "Yes"
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = "No"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
     cnvtstring(dv.qualifier_flag), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].
     double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("YES_NO Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findYesNoFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findccnoversamplefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCCNOversampleFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_ccn ccn
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (ccn
     WHERE ccn.br_ccn_id=dv.parent_entity_id)
    ORDER BY cnvtupper(ccn.ccn_nbr_txt), dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = ccn.ccn_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("CCN_OVERSAMPLE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCCNOversampleFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findccndatefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCCNDateFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_ccn ccn
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (ccn
     WHERE ccn.br_ccn_id=dv.parent_entity_id)
    ORDER BY cnvtupper(ccn.ccn_nbr_txt), dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = format(dv.value_dt_tm,"MM/DD/YY ;;D"),
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = ccn.ccn_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("CCNDATE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCCNDateFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findgenericccnfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findGenericCCNFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_ccn ccn
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (ccn
     WHERE ccn.br_ccn_id=dv.parent_entity_id)
    ORDER BY cnvtupper(ccn.ccn_nbr_txt), dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = ccn.ccn_nbr_txt, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = ccn.ccn_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("GENERIC CCN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findGenericCCNFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findsurgtrackviewfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findSurgTrackViewFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     predefined_prefs p
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (p
     WHERE p.predefined_prefs_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(p.name), tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("SURG_TRACK_VIEW Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findSurgTrackViewFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findpfsingleormultiselectfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findPFSingleOrMultiSelectFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     dcp_forms_ref dcp
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (dcp
     WHERE dcp.dcp_forms_ref_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(dcp.description), tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("PF_MULTI_OR_SINGLE_SELECT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findPFSingleOrMultiSelectFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findedinstructionsfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findEDInstructionsFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     pat_ed_reltn p
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (p
     WHERE p.pat_ed_reltn_desc=dv.freetext_desc)
    ORDER BY cnvtupper(dv.freetext_desc)
    HEAD dv.freetext_desc
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(p.pat_ed_reltn_desc), tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("ED_INSTRUCTIONS Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findEDInstructionsFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findorderdetailsfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findOrderDetailsFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     oe_field_meaning oe
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (oe
     WHERE oe.oe_field_meaning_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = concat(trim(oe.description)," / ",dv
      .freetext_desc), tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv
     .parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("ORDER_DETAILS Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findOrderDetailsFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE finddtanomenfilterfals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findDTANomenFilterFals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq)
     IF (dv.parent_entity_id > 0)
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(
        uar_get_code_display(n.source_vocabulary_cd))," - ",trim(n.source_identifier))
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc
     ENDIF
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id
     IF (dv.value_type_flag=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Numeric"
     ELSEIF (dv.value_type_flag=2)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Freetext"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq)
     IF (dv.qualifier_flag=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "equal to"
     ELSEIF (dv.qualifier_flag=2)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "not equal to"
     ELSEIF (dv.qualifier_flag=3)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "greater than"
     ELSEIF (dv.qualifier_flag=4)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "less than"
     ELSEIF (dv.qualifier_flag=5)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "greater than or equal to"
     ELSEIF (dv.qualifier_flag=6)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "less than or equal to"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("DTA_NOMEN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findDTANomenFilterFals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findeventnomenfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findEventNomenFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq)
     IF (dv.parent_entity_id > 0)
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(
        uar_get_code_display(n.source_vocabulary_cd))," - ",trim(n.source_identifier))
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc
     ENDIF
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id
     IF (dv.value_type_flag=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Numeric"
     ELSEIF (dv.value_type_flag=2)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Freetext"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq)
     IF (dv.qualifier_flag=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "equal to"
     ELSEIF (dv.qualifier_flag=2)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "not equal to"
     ELSEIF (dv.qualifier_flag=3)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "greater than"
     ELSEIF (dv.qualifier_flag=4)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value = "less than"
     ELSEIF (dv.qualifier_flag=5)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "greater than or equal to"
     ELSEIF (dv.qualifier_flag=6)
      tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
      "less than or equal to"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("EVENT_NOMEN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findEventNomenFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findnomenfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findNomenFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(uar_get_code_display(n
        .source_vocabulary_cd))," - ",trim(n.source_identifier))
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("NOMENCLATURE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findNomenFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findproblemfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findProblemFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(uar_get_code_display(n
        .source_vocabulary_cd))," - ",trim(n.source_identifier))
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("PROBLEM Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findProblemFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findproblemreltnfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findProblemReltnFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(uar_get_code_display(n
        .source_vocabulary_cd))," - ",trim(n.source_identifier))
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("PROBLEM_RELTN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findProblemReltnFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findprocedurefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findProcedureFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     nomenclature n
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (n
     WHERE n.nomenclature_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = build2(trim(uar_get_code_display(n
        .source_vocabulary_cd))," - ",trim(n.source_identifier))
     IF (n.short_string > " ")
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.short_string)
     ELSE
      tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = trim(n.source_string)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("PROCEDURE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findProcedureFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmultumcatfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMultumCatFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     mltm_drug_categories m
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (m
     WHERE m.multum_category_id=dv.parent_entity_id)
    ORDER BY dv.group_seq, dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(m.category_name), tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("MULTUM_CAT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMultumCatFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmultumlevelseqfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMultumLevelSeqFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   DECLARE multum_display = vc
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     mltm_drug_categories m,
     mltm_category_sub_xref x,
     mltm_category_sub_xref x2,
     mltm_drug_categories m2,
     mltm_drug_categories m3
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (m
     WHERE m.multum_category_id=dv.parent_entity_id)
     JOIN (x
     WHERE x.sub_category_id=outerjoin(m.multum_category_id))
     JOIN (x2
     WHERE x2.sub_category_id=outerjoin(x.multum_category_id))
     JOIN (m2
     WHERE m2.multum_category_id=outerjoin(x.multum_category_id))
     JOIN (m3
     WHERE m3.multum_category_id=outerjoin(x2.multum_category_id))
    ORDER BY dv.group_seq
    HEAD dv.group_seq
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), multum_display = trim(
      m.category_name)
     IF (x.sub_category_id > 0)
      multum_display = concat(trim(m2.category_name),"/",multum_display)
     ENDIF
     IF (x2.sub_category_id > 0)
      multum_display = concat(trim(m3.category_name),"/",multum_display)
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = multum_display,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("MULTUM_LEVEL_SEQ Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMultumLevelSeqFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findoutcomevenuefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findOutcomeVenueFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   DECLARE multum_display = vc
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     pathway_catalog p,
     outcome_catalog o
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (p
     WHERE p.pathway_catalog_id=dv.parent_entity_id)
     JOIN (o
     WHERE o.outcome_catalog_id=outerjoin(dv.parent_entity_id2))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(p.description), tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
     IF (((category_mean="OUTCOME_VENUE_IP") OR (category_mean="OUTCOME_VENUE_OR")) )
      tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = concat(trim(p
        .description)," / ",trim(o.description))
      IF (dv.value_type_flag=1)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "ED"
      ELSEIF (dv.value_type_flag=2)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Inpatient"
      ELSEIF (dv.value_type_flag=3)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Discharge"
      ELSEIF (dv.value_type_flag=4)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Pre-Op"
      ELSEIF (dv.value_type_flag=5)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Post-Op"
      ELSEIF (dv.value_type_flag=9)
       tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = "Do Not Display"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("OUTCOME_VENUE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findOutcomeVenueFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findhealthmaintenancefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findHealthMaintenanceFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     hm_expect_sat hm
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (hm
     WHERE hm.expect_sat_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(hm.expect_sat_name), tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("HME_SAT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findHealthMaintenanceFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findhcoselectionfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findHCOSelectionFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     br_hco hco
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (hco
     WHERE hco.br_hco_id=dv.parent_entity_id)
    ORDER BY cnvtupper(hco.hco_name), dv.value_seq, dv.value_type_flag
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = cnvtstring(hco.hco_nbr), tmpreply->
     rowlist[temp_reply_cnt].celllist[desc_col].string_value = hco.hco_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("HCO_SELECTION Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findHCOSelectionFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findeventconceptfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findEventConceptFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     br_event_grouper beg
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (beg
     WHERE beg.br_event_grouper_id=dv.parent_entity_id)
    ORDER BY cnvtupper(beg.grouper_name), dv.value_seq, dv.value_type_flag
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = beg.grouper_name, tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     cnvtstring(dv.group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value
      = cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("HCO_SELECTION Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findEventConceptFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findallergycatfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findAllergyCatFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     mltm_alr_category mac
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (mac
     WHERE mac.alr_category_id=dv.parent_entity_id)
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(mac.category_description_plural),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("ALLERGY_CAT Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findAllergyCatFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findcustomfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCustomFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = trim(dv.freetext_desc), tmpreply->
     rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].
     string_value = cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("CUSTOM_LIST Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCustomFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findsynvaccgroupassignfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findSynVaccGroupAssignFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     code_value cv,
     order_catalog_synonym ocs,
     order_catalog oc
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (cv
     WHERE cv.code_value=dv.parent_entity_id)
     JOIN (ocs
     WHERE ocs.synonym_id=dv.parent_entity_id2)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd)
    ORDER BY cnvtupper(cv.display), cnvtupper(oc.description), cnvtupper(ocs.mnemonic),
     dv.value_seq, dv.value_type_flag, dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), reply->collist[
     map_cd1_col].hide_ind = false, reply->collist[map_desc1_col].hide_ind = false,
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = ocs.mnemonic,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id2,
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = oc.description,
     tmpreply->rowlist[temp_reply_cnt].celllist[map_cd1_col].string_value = cnvtstring(cv.code_value),
     tmpreply->rowlist[temp_reply_cnt].celllist[map_desc1_col].string_value = cv.display, tmpreply->
     rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("SYN_VACC_GROUP_ASSIGN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findSynVaccGroupAssignFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findsyncategoryassignfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findSynVaccGroupAssignFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     code_value cv,
     order_catalog_synonym ocs,
     order_catalog oc
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (cv
     WHERE cv.code_value=dv.parent_entity_id)
     JOIN (ocs
     WHERE ocs.synonym_id=dv.parent_entity_id2)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd)
    ORDER BY cnvtupper(cv.display), cnvtupper(oc.description), cnvtupper(ocs.mnemonic),
     dv.value_seq, dv.value_type_flag, dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), reply->collist[
     map_cd1_col].hide_ind = false, reply->collist[map_desc1_col].hide_ind = false,
     tmpreply->rowlist[temp_reply_cnt].celllist[saved_value_col].string_value = ocs.mnemonic,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id2,
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = oc.description,
     tmpreply->rowlist[temp_reply_cnt].celllist[map_cd1_col].string_value = cnvtstring(cv.code_value),
     tmpreply->rowlist[temp_reply_cnt].celllist[map_desc1_col].string_value = cv.display, tmpreply->
     rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("SYN_CATEGORY_ASSIGN Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findSynCategoryAssignFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findfreetextmapfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMultiFreetextFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc, tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq)
     IF (dv.value_seq=0)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "long name"
     ELSEIF (dv.value_seq=1)
      tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = "display name"
     ENDIF
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[qualifier_col].string_value =
     cnvtstring(dv.qualifier_flag), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].
     double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("FREETEXT_MAP_SEQ Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findFreetextMapFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findmcpoolfiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findMCPoolFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_ccn ccn,
     prsnl_group pg
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND dv.parent_entity_name2="BR_CCN"
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id)
      AND dv.parent_entity_name="PRSNL_GROUP")
     JOIN (ccn
     WHERE ccn.br_ccn_id=dv.parent_entity_id2)
     JOIN (pg
     WHERE pg.prsnl_group_id=dv.parent_entity_id)
    ORDER BY cnvtupper(ccn.ccn_nbr_txt), dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = pg.prsnl_group_name, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = ccn.ccn_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id2,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM br_datamart_value dv,
     br_eligible_provider br,
     prsnl_group pg,
     prsnl p
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND dv.parent_entity_name2="BR_ELIGIBLE_PROVIDER"
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id)
      AND dv.parent_entity_name="PRSNL_GROUP")
     JOIN (br
     WHERE br.br_eligible_provider_id=dv.parent_entity_id2)
     JOIN (pg
     WHERE pg.prsnl_group_id=dv.parent_entity_id)
     JOIN (p
     WHERE p.person_id=br.provider_id)
    ORDER BY p.name_full_formatted, dv.value_seq, dv.value_type_flag,
     dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = pg.prsnl_group_name, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = p.name_full_formatted,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id2,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value =
     cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("MESSAGE_CENTERPOOL_EP Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findMCPoolFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findhcooversamplefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findHCOOversampleFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     br_hco hco
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (hco
     WHERE hco.br_hco_id=dv.parent_entity_id)
    ORDER BY cnvtupper(hco.hco_name), dv.value_seq, dv.value_type_flag
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = dv.freetext_desc, tmpreply->rowlist[
     temp_reply_cnt].celllist[desc_col].string_value = hco.hco_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("HCO_OVERSAMPLE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findHCOOversampleFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findhcodatefiltervals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findHCODateFilterVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     br_hco hco
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (hco
     WHERE hco.br_hco_id=dv.parent_entity_id)
    ORDER BY cnvtupper(hco.hco_name), dv.value_seq, dv.value_type_flag
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = format(dv.value_dt_tm,"MM/DD/YY ;;D"),
     tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value = hco.hco_name,
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     cnvtstring(dv.group_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id, tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv
     .updt_dt_tm,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("HCO_DATE Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findHCODateFilterVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findtherdupclassvals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findTherDupClassVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "NL:"
    FROM br_datamart_value dv,
     mltm_duplication_categories mdc
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
     JOIN (mdc
     WHERE mdc.multum_category_id=dv.parent_entity_id)
    ORDER BY cnvtupper(mdc.category_name), dv.value_seq, dv.value_type_flag
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = mdc.category_name, tmpreply->rowlist[
     temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value =
     cnvtstring(dv.group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value
      = cnvtstring(dv.value_seq),
     tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv.br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("THER_DUP_CLASS Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findTherDupClassVals","Exiting ...")
 END ;Subroutine
 SUBROUTINE findcodesetfilteringvals(id,mean,category_mean,display,seq)
   CALL bedlogmessage("findCodeSetFilteringVals","Entering ...")
   SET temp_reply_cnt = size(tmpreply->rowlist,5)
   SELECT INTO "nl:"
    FROM br_datamart_value dv
    PLAN (dv
     WHERE dv.br_datamart_filter_id=id
      AND expand(flex_itr,1,size(filter_flexes->flexes,5),dv.br_datamart_flex_id,filter_flexes->
      flexes[flex_itr].flex_id))
    ORDER BY dv.br_datamart_value_id
    HEAD dv.br_datamart_value_id
     temp_reply_cnt = (temp_reply_cnt+ 1), stat = alterlist(tmpreply->rowlist,temp_reply_cnt), stat
      = alterlist(tmpreply->rowlist[temp_reply_cnt].celllist,num_columns),
     CALL setgenericfilterinfo(temp_reply_cnt,mean,category_mean,display,seq), tmpreply->rowlist[
     temp_reply_cnt].celllist[saved_value_col].string_value = uar_get_code_display(dv
      .parent_entity_id), tmpreply->rowlist[temp_reply_cnt].celllist[desc_col].string_value =
     uar_get_code_description(dv.parent_entity_id),
     tmpreply->rowlist[temp_reply_cnt].celllist[event_set_col].string_value = trim(dv.freetext_desc),
     tmpreply->rowlist[temp_reply_cnt].celllist[code_value_col].double_value = dv.parent_entity_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[value_type_col].string_value = cnvtstring(dv
      .value_type_flag),
     tmpreply->rowlist[temp_reply_cnt].celllist[value_seq_col].string_value = cnvtstring(dv.value_seq
      ), tmpreply->rowlist[temp_reply_cnt].celllist[val_grp_seq_col].string_value = cnvtstring(dv
      .group_seq), tmpreply->rowlist[temp_reply_cnt].celllist[flex_disp_col].double_value = dv
     .br_datamart_flex_id,
     tmpreply->rowlist[temp_reply_cnt].celllist[updated_tm_col].date_value = dv.updt_dt_tm, tmpreply
     ->rowlist[temp_reply_cnt].celllist[updated_by_col].double_value = dv.updt_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("LOOK_BACK Error: BR_DATAMART_FILTER_ID = ",id))
   CALL bedlogmessage("findCodeSetFilteringVals","Exiting ...")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE filter_itr = i4 WITH protect, noconstant(0)
 DECLARE filter_id = f8 WITH protect, noconstant(0.0)
 DECLARE filter_mean = vc WITH protect, noconstant(" ")
 DECLARE filter_category_id = f8 WITH protect, noconstant(0.0)
 DECLARE filter_category_mean = vc WITH protect, noconstant(" ")
 DECLARE filter_category_type_mean = vc WITH protect, noconstant(" ")
 DECLARE filter_display = vc WITH protect, noconstant(" ")
 DECLARE filter_seq = i4 WITH protect, noconstant(0)
 DECLARE flex_itr = i4 WITH protect, noconstant(0)
 CALL initializeflexestofilter(0)
 CALL initializecolumnheaders(0)
 CALL retrievecategoryinfo(request->category_id)
 CALL retrievelayoutparams(request->category_id)
 CALL populatetopicfilters(request->category_id)
 FOR (filter_itr = 1 TO size(topic_filters->filters,5))
   SET filter_id = topic_filters->filters[filter_itr].filter_id
   SET filter_mean = topic_filters->filters[filter_itr].filter_mean
   SET filter_category_id = topic_filters->filters[filter_itr].filter_category_id
   SET filter_category_mean = topic_filters->filters[filter_itr].filter_category_mean
   SET filter_category_type_mean = topic_filters->filters[filter_itr].filter_category_type_mean
   SET filter_display = topic_filters->filters[filter_itr].filter_display
   SET filter_seq = topic_filters->filters[filter_itr].filter_seq
   SET flex_itr = 0
   IF (validate(debug,0)=1)
    CALL echo(build2("BR_DATAMART_FILTER_ID: ",filter_id))
   ENDIF
   IF (filter_category_mean="MESSAGE_CENTERPOOL_EP")
    CALL findmcpoolfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (((filter_category_type_mean="CODE_SET") OR (filter_category_type_mean="CODE_SET_SHARED"))
   )
    CALL findcodesetfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_type_mean="MAP")
    CALL findmapfiltervals(filter_id,filter_category_id,filter_mean,filter_category_mean,
     filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="DMS_CONTENT_TYPE")
    CALL finddmscontenttypefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (((filter_category_mean="PROVIDER") OR (filter_category_mean="PRSNL")) )
    CALL findproviderfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="EP_SELECTION")
    CALL findepselectionfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="SYNONYM")
    CALL findsynonymfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="IVIEW_SELECT")
    CALL findiviewselectfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="ORDER_FOLDER")
    CALL findorderfolderfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="ORDER")
    CALL findorderfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="CE_GROUP")
    CALL findcegroupfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="EVENT_SET")
    CALL findeventsetfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="FACILITY_LOC_TEXT")
    CALL findfacloctextfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="LOOK_BACK")
    CALL findlookbackfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="NU_STATUS")
    CALL findnustatusfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="MP_SECT_PARAMS")
    CALL findmpsectparamsfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (((filter_category_mean="MULTI_FREETEXT") OR (filter_category_mean="MULTI_FREETEXT_SEQ")) )
    CALL findmultifreetextfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="YES_NO")
    CALL findyesnofiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean IN ("CCN_ACUTE", "CCN_ACUTESEL", "CCN_PSYCH", "CCN_PSYCHSEL",
   "CCN_SAMPLE",
   "CCNALL"))
    CALL findgenericccnfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="CCN_OVERSAMPLE")
    CALL findccnoversamplefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="CCNDATE")
    CALL findccndatefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="SURG_TRACK_VIEW")
    CALL findsurgtrackviewfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean IN ("PF_SINGLE_SELECT", "PF_MULTI_SELECT"))
    CALL findpfsingleormultiselectfiltervals(filter_id,filter_mean,filter_category_mean,
     filter_display,filter_seq)
   ELSEIF (filter_category_mean="ED_INSTRUCTIONS")
    CALL findedinstructionsfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="ORDER_DETAILS")
    CALL findorderdetailsfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="DTA_NOMEN")
    CALL finddtanomenfilterfals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="EVENT_NOMEN")
    CALL findeventnomenfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="NOMENCLATURE")
    CALL findnomenfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="PROBLEM")
    CALL findproblemfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="PROBLEM_RELTN")
    CALL findproblemreltnfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="PROCEDURE")
    CALL findprocedurefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq
     )
   ELSEIF (filter_category_mean IN ("MULTUM_CAT", "MULTUM_CAT_SEQ"))
    CALL findmultumcatfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq
     )
   ELSEIF (filter_category_mean="MULTUM_LEVEL_SEQ")
    CALL findmultumlevelseqfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean IN ("OUTCOME_VENUE_IP", "OUTCOME_VENUE_OR", "POWERPLAN"))
    CALL findoutcomevenuefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="HME_SAT")
    CALL findhealthmaintenancefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean IN ("HCO_SELECTION", "HCO_TJC_SELECTION", "HCO_SAMPLE"))
    CALL findhcoselectionfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="EVENTCONCEPT")
    CALL findeventconceptfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="ALLERGY_CAT")
    CALL findallergycatfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_type_mean="CUSTOM_LIST")
    CALL findcustomfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSEIF (filter_category_mean="SYN_VACC_GROUP_ASSIGN")
    CALL findsynvaccgroupassignfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="SYN_CATEGORY_ASSIGN")
    CALL findsyncategoryassignfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="FREETEXT_MAP")
    CALL findfreetextmapfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="HCO_OVERSAMPLE")
    CALL findhcooversamplefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,
     filter_seq)
   ELSEIF (filter_category_mean="HCO_DATE")
    CALL findhcodatefiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ELSE
    CALL findgenericfiltervals(filter_id,filter_mean,filter_category_mean,filter_display,filter_seq)
   ENDIF
 ENDFOR
 IF (size(tmpreply->rowlist,5)=0)
  GO TO exit_script
 ENDIF
 CALL populatelochierarchy(0)
 CALL populateflexsettings(0)
 CALL populateupdatedbyinfo(0)
 CALL populatereplyfromtemp(0)
 IF ((request->skip_volume_check_ind=0))
  IF (size(reply->rowlist,5) > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(reply->rowlist,5) > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(0)
 IF ((reply->high_volume_flag IN (1, 2)))
  SELECT INTO "nl:"
   FROM br_datamart_category dc
   PLAN (dc
    WHERE (dc.br_datamart_category_id=request->category_id))
   DETAIL
    reply->output_filename = build(concat("datamart_",trim(dc.category_mean,3),".csv"))
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
