CREATE PROGRAM bed_get_missing_code_ind:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 missing_ind = i2
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
 FREE RECORD ensnewsectionsrequest
 RECORD ensnewsectionsrequest(
   1 dcp_form_ref_id = f8
   1 form_uid = vc
   1 definition = vc
   1 description = vc
   1 enforce_required_ind = i2
   1 done_charting_ind = i2
   1 event_cd = f8
   1 text_rendition_event_cd = f8
   1 addsections[*]
     2 section_uid = vc
     2 sequence = i4
     2 conditional_flag = i4
     2 description = vc
     2 definition = vc
     2 ignore_ind = i2
   1 updatesections[*]
     2 dcp_section_ref_id = f8
     2 section_uid = vc
     2 conditional_flag = i4
     2 sequence = i4
     2 ignore_ind = i2
   1 ccl_logging_ind = i2
 )
 FREE RECORD getcontentsectionsreply
 RECORD getcontentsectionsreply(
   1 sections[*]
     2 section_uid = vc
     2 description = vc
     2 width = i4
     2 height = i4
     2 sequence = i4
     2 dcp_section_ref_id = f8
     2 match_description = vc
     2 match_width = i4
     2 match_height = i4
     2 ignore_ind = i2
     2 condition_ind = i2
     2 name = vc
     2 match_name = vc
     2 modified_status = vc
     2 modified_status_level = vc
     2 conditional_section_ind = i2
   1 form_modified_status = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD getinputsreply
 RECORD getinputsreply(
   1 inputs[*]
     2 description = vc
     2 input_ref_seq = i4
     2 input_type = i4
     2 module = vc
     2 dcp_input_ref_id = f8
     2 preferences[*]
       3 name_value_prefs_id = f8
       3 pvc_name = vc
       3 pvc_value = vc
       3 merge_name = vc
       3 sequence = i4
       3 task_assay_uid = vc
       3 event_cduid = vc
       3 ignore_ind = i2
       3 cnt_input_id = f8
       3 merge_id = f8
       3 content_merge_uid = vc
       3 merge_display = vc
     2 cnt_input_key_id = f8
     2 cnt_modified_status = vc
     2 grideventcodes[*]
       3 col_task_assay_uid = vc
       3 col_task_assay_cd = f8
       3 col_assay_display = vc
       3 row_task_assay_uid = vc
       3 row_task_assay_cd = f8
       3 row_assay_display = vc
       3 int_event_cduid = vc
       3 int_event_cd = f8
       3 int_event_display = vc
       3 old_event_cd = f8
       3 old_event_display = vc
       3 event_modified_status = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD getexistingassayreply
 RECORD getexistingassayreply(
   1 slist[*]
     2 active_ind = i2
     2 code_value = f8
     2 assay_list[*]
       3 active_ind = i2
       3 code_value = f8
       3 display = c50
       3 description = c60
       3 general_info
         4 result_type_code_value = f8
         4 result_type_display = c40
         4 result_type_mean = vc
         4 activity_type_code_value = f8
         4 activity_type_display = c40
         4 delta_check_ind = i2
         4 inter_data_check_ind = i2
         4 res_proc_type_code_value = f8
         4 res_proc_type_display = c40
         4 rad_section_type_code_value = f8
         4 rad_section_type_display = c40
         4 single_select_ind = i2
         4 io_flag = i2
         4 event
           5 code_value = f8
           5 display = vc
           5 es_hier_ind = i2
           5 event_cd_cki = vc
         4 concept
           5 concept_cki = vc
           5 concept_name = vc
           5 vocab_cd = f8
           5 vocab_disp = c40
           5 vocab_axis_cd = f8
           5 vocab_axis_disp = c40
           5 source_identifier = vc
         4 sci_notation_ind = i2
       3 data_map[*]
         4 active_ind = i2
         4 service_resource_code_value = f8
         4 service_resource_display = vc
         4 min_digits = i4
         4 max_digits = i4
         4 dec_place = i4
         4 data_map_type_flag = i2
       3 rr_list[*]
         4 active_ind = i2
         4 rrf_id = f8
         4 sequence = i4
         4 def_value = f8
         4 uom_code_value = f8
         4 uom_display = c40
         4 from_age = i4
         4 from_age_unit_code_value = f8
         4 from_age_unit_display = c40
         4 from_age_unit_mean = c12
         4 to_age = i4
         4 to_age_unit_code_value = f8
         4 to_age_unit_display = c40
         4 to_age_unit_mean = c12
         4 unknown_age_ind = i2
         4 sex_code_value = f8
         4 sex_display = c40
         4 sex_mean = c12
         4 specimen_type_code_value = f8
         4 specimen_type_display = c40
         4 service_resource_code_value = f8
         4 service_resource_display = c40
         4 ref_low = f8
         4 ref_high = f8
         4 ref_ind = i2
         4 crit_low = f8
         4 crit_high = f8
         4 crit_ind = i2
         4 review_low = f8
         4 review_high = f8
         4 review_ind = i2
         4 linear_low = f8
         4 linear_high = f8
         4 linear_ind = i2
         4 dilute_ind = i2
         4 feasible_low = f8
         4 feasible_high = f8
         4 feasible_ind = i2
         4 alpha_list[*]
           5 active_ind = i2
           5 nomenclature_id = f8
           5 sequence = i4
           5 source_string = c255
           5 short_string = c60
           5 mnemonic = c25
           5 default_ind = i2
           5 use_units_ind = i2
           5 reference_ind = i2
           5 result_process_code_value = f8
           5 result_process_display = c40
           5 result_process_description = c60
           5 result_value = f8
           5 truth_state_cd = f8
           5 truth_state_display = vc
           5 truth_state_mean = vc
           5 grid_display = i4
         4 rule_list[*]
           5 ref_range_notify_trig_id = f8
           5 trigger_name = vc
           5 trigger_seq_nbr = i4
         4 species
           5 code_value = f8
           5 display = vc
           5 meaning = vc
         4 adv_deltas[*]
           5 delta_ind = i2
           5 delta_low = f8
           5 delta_high = f8
           5 delta_check_type
             6 code_value = f8
             6 display = vc
             6 description = vc
             6 mean = vc
           5 delta_minutes = i4
           5 delta_value = f8
         4 delta_check_type
           5 code_value = f8
           5 display = vc
           5 description = vc
           5 mean = vc
         4 delta_minutes = i4
         4 delta_value = f8
         4 delta_chk_flag = i2
         4 service_resource_mean = vc
       3 equivalent_assay[*]
         4 active_ind = i2
         4 code_value = f8
         4 display = c40
       3 event
         4 code_value = f8
         4 display = vc
         4 es_hier_ind = i2
       3 source = i2
       3 equation[*]
         4 id = f8
         4 description = vc
         4 equation_description = vc
         4 age_from = f8
         4 age_from_units
           5 code_value = f8
           5 display = vc
           5 mean = vc
         4 age_to = f8
         4 age_to_units
           5 code_value = f8
           5 display = vc
           5 mean = vc
         4 sex
           5 code_value = f8
           5 display = vc
           5 mean = vc
         4 unknown_age_ind = i2
         4 default_ind = i2
         4 components[*]
           5 component_name = vc
           5 included_assay
             6 code_value = f8
             6 display = vc
             6 mean = vc
           5 constant_value = f8
           5 required_flag = i2
           5 look_time_direction_flag = i2
           5 time_window_back_minutes = i4
           5 time_window_minutes = i4
           5 value_unit
             6 code_value = f8
             6 display = vc
             6 mean = vc
           5 optional_value = f8
       3 dynamic_groups[*]
         4 doc_set_ref_id = f8
         4 description = vc
       3 dgroup_label_ind = i2
       3 lookback_minutes[*]
         4 type_code_value = f8
         4 type_display = vc
         4 type_mean = vc
         4 minutes_nbr = i4
       3 interpretations_ind = i2
       3 witness_required_ind = i2
       3 default_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 FREE RECORD getassaysreply
 RECORD getassaysreply(
   1 assays[*]
     2 task_assay_uid = vc
     2 task_assay_code_value = f8
     2 description = vc
     2 mnemonic = vc
     2 witness_required_ind = i2
     2 lookback_minutes[*]
       3 type_code_value = f8
       3 type_display = vc
       3 type_mean = vc
       3 minutes_nbr = i4
     2 equations[*]
       3 equation_uid = vc
       3 equation_id = f8
       3 description = vc
       3 age_from = f8
       3 age_from_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 age_to = f8
       3 age_to_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 sex
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 unknown_age_ind = i2
       3 default_ind = i2
       3 components[*]
         4 component_name = vc
         4 included_assay_uid = vc
         4 included_assay
           5 code_value = f8
           5 display = vc
           5 mean = vc
         4 constant_value = f8
         4 required_flag = i2
         4 look_time_direction_flag = i2
         4 time_window_back_minutes = i4
         4 time_window_minutes = i4
         4 value_unit
           5 code_value = f8
           5 display = vc
           5 mean = vc
         4 optional_value = f8
     2 max_digits = i4
     2 min_digits = i4
     2 min_decimal_places = i4
     2 default_type_flag = i2
     2 concept_cki = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 result_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 event
       3 uid = vc
       3 display = vc
       3 event_cd_cki = vc
     2 single_select_ind = i2
     2 io_flag = i2
     2 ref_ranges[*]
       3 rrf_uid = vc
       3 age_to = f8
       3 age_to_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 age_from = f8
       3 age_from_units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 normal_low = f8
       3 normal_high = f8
       3 critical_low = f8
       3 critical_high = f8
       3 review_low = f8
       3 review_high = f8
       3 linear_low = f8
       3 linear_high = f8
       3 feasible_low = f8
       3 feasible_high = f8
       3 default_result = f8
       3 alpha_responses[*]
         4 ar_uid = vc
         4 source_string = vc
         4 short_string = vc
         4 mnemonic = vc
         4 nomenclature_id = f8
         4 sequence = i4
         4 result_value = f8
         4 multi_alpha_sort_order = i4
         4 reference_ind = i2
         4 default_ind = i2
         4 use_units_ind = i2
         4 result_process_code_value = f8
         4 principle_type_code_value = f8
         4 contributor_system_code_value = f8
         4 language_code_value = f8
         4 source_vocabulary_code_value = f8
         4 source_identifier = vc
         4 concept_cki = vc
         4 vocab_axis_code_value = f8
         4 truth_state_cd = f8
         4 truth_state_display = vc
         4 truth_state_mean = vc
         4 modified_status = vc
       3 units
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 sex
         4 code_value = f8
         4 display = vc
         4 mean = vc
     2 notes[*]
       3 text_id = f8
       3 text = vc
       3 user_id = f8
       3 user = vc
       3 updt_dt_tm = dq8
     2 interps[*]
       3 sex_cd = f8
       3 age_from_minutes = i4
       3 age_to_minutes = i4
       3 uid = vc
       3 comps[*]
         4 component_assay_cd = f8
         4 sequence = i4
         4 description = vc
         4 flags = i4
         4 mnemonic = vc
       3 states[*]
         4 input_assay_cd = f8
         4 state = i4
         4 flags = i4
         4 numeric_low = f8
         4 numeric_high = f8
         4 nomenclature_id = f8
         4 resulting_state = i4
         4 result_nomenclature_id = f8
         4 result_value = f8
       3 sex_mean = vc
       3 sex_display = vc
     2 ref_text_modified_ind = i2
     2 modified_status = vc
     2 has_all_interp_comp_assays = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD reconcileassayrequest
 RECORD reconcileassayrequest(
   1 assays[*]
     2 taskassayuid = vc
     2 taskassaycd = f8
     2 resulttypecd = f8
     2 display = vc
     2 description = vc
     2 conceptcki = vc
     2 witnessrequiredind = i2
     2 singleselectind = i2
     2 ioflag = i2
     2 defaulttypeflag = i2
     2 offsetminutes[*]
       3 actionflag = i2
       3 offsetminnbr = i4
       3 offsettypecd = f8
     2 datamap
       3 actionflag = i2
       3 max_digits = i4
       3 min_digits = i4
       3 min_decimal_places = i4
     2 refranges[*]
       3 actionflag = i2
       3 rrfuid = vc
       3 rrfid = f8
       3 alpharesponses[*]
         4 actionflag = i4
         4 aruid = vc
         4 nomenclatureid = f8
     2 equations[*]
       3 actionflag = i2
       3 equationuid = vc
       3 equationid = f8
     2 referencetextupdateind = i2
     2 interpretationsupdateind = i2
     2 eventcodecki = vc
   1 ccl_logging_ind = i2
   1 powerformoriviewname = vc
   1 powerformoriviewind = i2
 )
 DECLARE modified = vc WITH protect, constant("M")
 CALL bedbeginscript(0)
 DECLARE getcontentsections(dummyvar=i2) = i2
 DECLARE getmissingcodes(dummyvar=i2) = i2
 DECLARE getinputsforsection(sectionuid=vc) = i2
 DECLARE loadpwfrmcodes(pwfrmrequest=vc(ref)) = i2
 CALL getcontentsections(0)
 CALL getmissingcodes(0)
 SUBROUTINE getcontentsections(dummyvar)
   CALL bedlogmessage("getContentSections ","Entering ...")
   FREE RECORD getcontentsectionsrequest
   RECORD getcontentsectionsrequest(
     1 form_uid = vc
     1 dcp_form_ref_id = f8
   )
   SET getcontentsectionsrequest->form_uid = request->formuid
   SET getcontentsectionsrequest->dcp_form_ref_id = request->formid
   SET stat = initrec(getcontentsectionsreply)
   EXECUTE bed_get_pwrform_cern_sections  WITH replace("REQUEST",getcontentsectionsrequest), replace(
    "REPLY",getcontentsectionsreply)
   IF ((getcontentsectionsreply->status_data.status != "S"))
    CALL bederror("bed_get_pwrform_cern_sections failed.")
   ENDIF
   CALL bedlogmessage("getContentSections ","Exiting ...")
 END ;Subroutine
 SUBROUTINE getmissingcodes(dummyvar)
   CALL bedlogmessage("getMissingCodes ","Entering ...")
   DECLARE ssscnt = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   FREE RECORD getinputsrequest
   RECORD getinputsrequest(
     1 section_uid = vc
     1 compare_ind = i2
   )
   FREE RECORD getassaysrequest
   RECORD getassaysrequest(
     1 assays[*]
       2 task_assay_uid = vc
       2 bailoutind = i2
     1 get_interps_ind = i2
     1 form_uid = vc
   )
   FREE RECORD getpwrfrmcodesrequest
   RECORD getpwrfrmcodesrequest(
     1 assays[*]
       2 task_assay_uid = vc
   )
   FREE RECORD getpwrfrmcodesreply
   RECORD getpwrfrmcodesreply(
     1 codes[*]
       2 uid = vc
       2 display = vc
       2 mean = vc
       2 code_set = i4
       2 name = vc
       2 assay_desc = vc
       2 assay_uid = vc
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FOR (ssscnt = 1 TO size(getcontentsectionsreply->sections,5))
     IF ((getcontentsectionsreply->sections[ssscnt].modified_status=modified))
      SET acnt = 0
      SET stat = initrec(getpwrfrmcodesrequest)
      CALL getinputsforsection(getcontentsectionsreply->sections[ssscnt].section_uid)
      FOR (icnt = 1 TO size(getinputsreply->inputs,5))
        FOR (pcnt = 1 TO size(getinputsreply->inputs[icnt].preferences,5))
          IF ((getinputsreply->inputs[icnt].preferences[pcnt].merge_name="DISCRETE_TASK_ASSAY*"))
           SET acnt = (acnt+ 1)
           SET stat = alterlist(getpwrfrmcodesrequest->assays,acnt)
           SET getpwrfrmcodesrequest->assays[acnt].task_assay_uid = getinputsreply->inputs[icnt].
           preferences[pcnt].content_merge_uid
          ENDIF
        ENDFOR
      ENDFOR
      IF (loadpwfrmcodes(getpwrfrmcodesrequest)=1)
       SET reply->missing_ind = 1
       RETURN(1)
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("getMissingCodes ","Exiting ...")
 END ;Subroutine
 SUBROUTINE getinputsforsection(sectionuid)
   CALL bedlogmessage("getInputsForSection ","Entering ...")
   FREE RECORD getinputsrequest
   RECORD getinputsrequest(
     1 section_uid = vc
     1 compare_ind = i2
   )
   SET stat = initrec(getinputsreply)
   SET getinputsrequest->section_uid = sectionuid
   EXECUTE bed_get_pwrform_cern_inputs  WITH replace("REQUEST",getinputsrequest), replace("REPLY",
    getinputsreply)
   IF ((getinputsreply->status_data.status != "S"))
    CALL bederror("bed_get_pwrform_cern_inputs failed.")
   ENDIF
   CALL bedlogmessage("getInputsForSection ","Exiting ...")
 END ;Subroutine
 SUBROUTINE loadpwfrmcodes(pwfrmrequest)
   CALL bedlogmessage("loadPwfrmCodes ","Entering ...")
   SET stat = initrec(getpwrfrmcodesreply)
   EXECUTE bed_get_pwrform_cern_codes  WITH replace("REQUEST",pwfrmrequest), replace("REPLY",
    getpwrfrmcodesreply)
   IF ((getpwrfrmcodesreply->status_data.status != "S"))
    CALL bederror("bed_get_pwrform_cern_codes failed.")
   ENDIF
   IF (size(getpwrfrmcodesreply->codes,5) > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   CALL bedlogmessage("loadPwfrmCodes ","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
