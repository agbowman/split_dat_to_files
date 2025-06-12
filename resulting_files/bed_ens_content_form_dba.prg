CREATE PROGRAM bed_ens_content_form:dba
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
 FREE RECORD tempexistingassayreply
 RECORD tempexistingassayreply(
   1 slist[*]
     2 active_ind = i2
     2 code_value = f8
     2 assay_list[*]
       3 active_ind = i2
       3 code_value = f8
       3 display = c50
       3 description = vc
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
 FREE RECORD interpimported
 RECORD interpimported(
   1 interp[*]
     2 sex_cd = f8
     2 age_from_minutes = i4
     2 age_to_minutes = i4
     2 uid = vc
     2 comp[*]
       3 component_assay_cd = f8
       3 sequence = i4
       3 description = vc
       3 flags = i4
       3 mnemonic = vc
     2 state[*]
       3 input_assay_cd = f8
       3 state = i4
       3 flags = i4
       3 numeric_low = f8
       3 numeric_high = f8
       3 aruid = vc
       3 nomenclature_id = f8
       3 resulting_state = i4
       3 resultaruid = vc
       3 result_nomenclature_id = f8
       3 result_value = f8
 )
 FREE RECORD interpexisting
 RECORD interpexisting(
   1 interp[*]
     2 sex_cd = f8
     2 age_from_minutes = i4
     2 age_to_minutes = i4
     2 comp[*]
       3 component_assay_cd = f8
       3 sequence = i4
       3 description = vc
       3 flags = i4
     2 state[*]
       3 input_assay_cd = f8
       3 state = i4
       3 flags = i4
       3 numeric_low = f8
       3 numeric_high = f8
       3 nomenclature_id = f8
       3 resulting_state = i4
       3 result_nomenclature_id = f8
       3 result_value = f8
 )
 FREE RECORD reftextimported
 RECORD reftextimported(
   1 ref_text[*]
     2 text_type_cd = f8
     2 text = vc
 )
 FREE RECORD reftextexisting
 RECORD reftextexisting(
   1 ref_text[*]
     2 text_type_cd = f8
     2 text = vc
 )
 DECLARE bailoutind = i2 WITH protect, noconstant(0)
 DECLARE setmodifiedstatus(bailoutind=i2) = null
 DECLARE findassaycdbydescmnemonicandactivitytype(assaymnemonic=vc,activitytypecode=f8) = f8
 DECLARE populateassaystatus(taskassayuid=vc,taskassaycd=f8,importedassaycnt=i4,shouldevaluateinterps
  =i2) = null
 DECLARE populateexistingassay(taskassaycd=f8,importedassaycnt=i4) = null
 DECLARE compareimportedagainstexistingassay(taskassayuid=vc,taskassaycd=f8,importedassaycnt=i4,
  shouldevaluateinterps=i2) = null
 DECLARE assaygeneralcomparison(i=i2) = null
 DECLARE assayoffsetminutescomparison(i=i2) = null
 DECLARE assaynumericmappingcomparison(i=i2) = null
 DECLARE assayequationcomparison(i=i2,taskassaycd=f8) = null
 DECLARE assaynumericdetailscomparison(i=i2,j=i2,k=i2) = null
 DECLARE assayalpharesponsecomparison(i=i2,j=i2,k=i2,l=i2) = null
 DECLARE findandpopulateremovedalpharesponse(i=i2,j=i2,k=i2) = null
 DECLARE areinterpsdifferent(taskassayuid=vc,taskassaycd=f8) = i2
 DECLARE getcntinterp(taskassayuid=vc) = null
 DECLARE getdcpinterp(taskassaycd=f8) = null
 DECLARE arereferencetextdifferent(taskassayuid=vc,taskassaycd=f8) = i2
 DECLARE getcntreftext(taskassayuid=vc) = null
 DECLARE getdcpreftext(taskassaycd=f8) = null
 DECLARE copyexistingreferencerangestoimported(importedassaycnt=i4,existingrrid=f8) = null
 DECLARE marknonmatchedalpharesponseasadded(importedassaycnt=i4,j=i4) = null
 DECLARE assayalphamultifreetextcomparison(assindex=i4) = i2
 DECLARE getassaysinform(formuid=vc) = null
 DECLARE areallinterpassaysavailableinform(assayuid=vc) = i2
 SUBROUTINE setmodifiedstatus(bailoutind)
   CALL bedlogmessage("setModifiedStatus","Entering ...")
   DECLARE importedassaycnt = i4 WITH protect, noconstant(0)
   DECLARE matchedassaycd = f8 WITH protect, noconstant(0)
   DECLARE shouldinterpsevaluated = i2 WITH protect, noconstant(false)
   SET bailoutind = bailoutind
   FOR (importedassaycnt = 1 TO size(reply->assays,5))
     SET shouldinterpsevaluated = shouldevaluateinterps(reply->assays[importedassaycnt].
      task_assay_uid)
     SET reply->assays[importedassaycnt].has_all_interp_comp_assays = shouldinterpsevaluated
     SET reply->assays[importedassaycnt].modified_status = none
     IF ((reply->assays[importedassaycnt].task_assay_code_value > 0))
      CALL logdebuginfo(build2("Matched assay code from the request: ",reply->assays[importedassaycnt
        ].task_assay_code_value))
      CALL populateassaystatus(reply->assays[importedassaycnt].task_assay_uid,reply->assays[
       importedassaycnt].task_assay_code_value,importedassaycnt,shouldinterpsevaluated)
     ELSE
      SET matchedassaycd = findassaycdbydescmnemonicandactivitytype(reply->assays[importedassaycnt].
       mnemonic,reply->assays[importedassaycnt].activity_type.code_value)
      IF (matchedassaycd > 0)
       SET reply->assays[importedassaycnt].task_assay_code_value = matchedassaycd
       CALL logdebuginfo(build2("Found matched assay for Desc and Mnemonic: ",matchedassaycd))
       CALL populateassaystatus(reply->assays[importedassaycnt].task_assay_uid,matchedassaycd,
        importedassaycnt,shouldinterpsevaluated)
      ELSE
       CALL logdebuginfo("Match is not found thus mark the assay as new.")
       SET reply->assays[importedassaycnt].modified_status = added
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("setModifiedStatus","Exiting ...")
 END ;Subroutine
 SUBROUTINE findassaycdbydescmnemonicandactivitytype(assaymnemonic,activitytypecode)
   CALL bedlogmessage("findAssayCdByDescMnemonicAndActivityType","Entering ...")
   DECLARE matchedassay = f8 WITH protect, noconstant(0)
   IF (assaymnemonic != ""
    AND activitytypecode > 0)
    SELECT INTO "n1:"
     FROM discrete_task_assay dta
     PLAN (dta
      WHERE cnvtupper(dta.mnemonic)=cnvtupper(assaymnemonic)
       AND dta.activity_type_cd=activitytypecode
       AND dta.active_ind=true)
     DETAIL
      matchedassay = dta.task_assay_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL bedlogmessage("findAssayCdByDescMnemonicAndActivityType","Exiting ...")
   RETURN(matchedassay)
 END ;Subroutine
 SUBROUTINE populateassaystatus(taskassayuid,taskassaycd,importedassaycnt,shouldevaluateinterps)
   CALL bedlogmessage("populateAssayStatus","Entering ...")
   CALL populateexistingassay(taskassaycd,importedassaycnt)
   CALL compareimportedagainstexistingassay(taskassayuid,taskassaycd,importedassaycnt,
    shouldevaluateinterps)
   CALL bedlogmessage("populateAssayStatus","Exiting ...")
 END ;Subroutine
 SUBROUTINE populateexistingassay(taskassaycd,importedassaycnt)
   CALL bedlogmessage("populateExistingAssay","Entering ...")
   FREE SET tempexistingassayrequest
   RECORD tempexistingassayrequest(
     1 search_by = i4
     1 search_list[*]
       2 code_value = f8
     1 search_txt = vc
     1 search_type_flag = c1
     1 include_inactive_child_ind = i4
     1 max_reply = i4
     1 load
       2 reference_ranges_ind = i4
       2 equivalent_info_ind = i4
       2 data_map_ind = i4
       2 equation_ind = i4
       2 dynamic_group_ind = i4
       2 lookback_minutes_ind = i4
       2 interpretations_ind = i4
     1 result_type_code_value = f8
     1 activity_type_cd = f8
     1 result_types[*]
   )
   SET tempexistingassayrequest->search_by = 3
   SET stat = alterlist(tempexistingassayrequest->search_list,1)
   SET tempexistingassayrequest->search_list[1].code_value = taskassaycd
   SET tempexistingassayrequest->search_txt = ""
   SET tempexistingassayrequest->search_type_flag = ""
   SET tempexistingassayrequest->include_inactive_child_ind = 0
   SET tempexistingassayrequest->max_reply = 0
   SET tempexistingassayrequest->load.reference_ranges_ind = 1
   SET tempexistingassayrequest->load.equivalent_info_ind = 0
   SET tempexistingassayrequest->load.data_map_ind = 1
   SET tempexistingassayrequest->load.equation_ind = 1
   SET tempexistingassayrequest->load.dynamic_group_ind = 0
   SET tempexistingassayrequest->load.lookback_minutes_ind = 1
   SET tempexistingassayrequest->load.interpretations_ind = 1
   SET tempexistingassayrequest->result_type_code_value = 0.0
   SET tempexistingassayrequest->activity_type_cd = 0.0
   SET stat = initrec(tempexistingassayreply)
   EXECUTE bed_get_assay  WITH replace("REQUEST",tempexistingassayrequest), replace("REPLY",
    tempexistingassayreply)
   IF ((tempexistingassayreply->status_data.status != "S"))
    CALL bederror("bed_get_assay did not return success")
   ENDIF
   IF (size(tempexistingassayreply->slist,5) > 0
    AND size(tempexistingassayreply->slist[1].assay_list,5) > 0)
    CALL logdebuginfo(build2("Existing Assay - slist count: ",size(tempexistingassayreply->slist,5)))
    CALL logdebuginfo(build2("Existing Assay - assay_list count: ",size(tempexistingassayreply->
       slist[1].assay_list,5)))
   ELSE
    CALL logdebuginfo(build2(
      "Mark the assay as new as Existing Assay script doesn't returns valid result for the assay cd: ",
      taskassaycd))
    SET reply->assays[importedassaycnt].modified_status = added
    GO TO exit_script
   ENDIF
   CALL bedlogmessage("populateExistingAssay","Exiting ...")
 END ;Subroutine
 SUBROUTINE compareimportedagainstexistingassay(taskassayuid,taskassaycd,importedassaycnt,
  shouldevaluateinterps)
   CALL bedlogmessage("compareImportedAgainstExistingAssay","Entering ...")
   DECLARE found = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE importedresulttypemean = vc WITH protect, noconstant("")
   DECLARE existingresulttypemean = vc WITH protect, noconstant("")
   SET importedresulttypemean = reply->assays[importedassaycnt].result_type.mean
   SET existingresulttypemean = tempexistingassayreply->slist[1].assay_list[1].general_info.
   result_type_mean
   IF (importedresulttypemean != existingresulttypemean)
    CALL logdebuginfo(build2("Assay Result Type is different: ",importedresulttypemean,"::",
      existingresulttypemean))
    SET reply->assays[importedassaycnt].modified_status = modified
   ENDIF
   IF ((reply->assays[importedassaycnt].modified_status=none))
    CALL assaygeneralcomparison(importedassaycnt)
   ENDIF
   DECLARE ref_text_modified_flag = i2 WITH protect, noconstant(0)
   IF (bailoutind)
    IF ((reply->assays[importedassaycnt].modified_status=none))
     SET ref_text_modified_flag = arereferencetextdifferent(taskassayuid,taskassaycd)
     IF (ref_text_modified_flag > 0)
      SET reply->assays[importedassaycnt].modified_status = modified
      SET reply->assays[importedassaycnt].ref_text_modified_ind = ref_text_modified_flag
     ENDIF
    ENDIF
    IF (importedresulttypemean IN ("2", "21", "5", "22"))
     IF ((reply->assays[importedassaycnt].modified_status=none)
      AND size(reply->assays[importedassaycnt].ref_ranges,5)=size(tempexistingassayreply->slist[1].
      assay_list[1].rr_list,5))
      IF (assayalphamultifreetextcomparison(importedassaycnt))
       SET reply->assays[importedassaycnt].modified_status = modified
      ENDIF
     ELSE
      CALL logdebuginfo("bailOutInd is ON and assay is modified.")
      SET reply->assays[importedassaycnt].modified_status = modified
     ENDIF
     IF ((reply->assays[importedassaycnt].modified_status=none)
      AND shouldevaluateinterps)
      IF (areinterpsdifferent(taskassayuid,taskassaycd))
       SET reply->assays[importedassaycnt].modified_status = modified
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ref_text_modified_flag = arereferencetextdifferent(taskassayuid,taskassaycd)
    IF (ref_text_modified_flag > 0)
     SET reply->assays[importedassaycnt].modified_status = modified
     SET reply->assays[importedassaycnt].ref_text_modified_ind = ref_text_modified_flag
    ENDIF
    IF (importedresulttypemean IN ("2", "21", "5", "22"))
     IF (assayalphamultifreetextcomparison(importedassaycnt))
      SET reply->assays[importedassaycnt].modified_status = modified
     ENDIF
     IF ((reply->assays[importedassaycnt].modified_status=none)
      AND shouldevaluateinterps)
      IF (areinterpsdifferent(taskassayuid,taskassaycd))
       SET reply->assays[importedassaycnt].modified_status = modified
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->assays[importedassaycnt].modified_status=none))
    IF (importedresulttypemean IN ("3", "8"))
     IF ((reply->assays[importedassaycnt].modified_status=none))
      CALL assaynumericmappingcomparison(importedassaycnt)
     ENDIF
     IF ((reply->assays[importedassaycnt].modified_status=none))
      CALL assaynumericdetailscomparison(importedassaycnt)
     ENDIF
     IF ((reply->assays[importedassaycnt].modified_status=none))
      IF ((reply->assays[importedassaycnt].io_flag != tempexistingassayreply->slist[1].assay_list[1].
      general_info.io_flag))
       CALL logdebuginfo(build2("Assay Intake and Output is different: ",reply->assays[
         importedassaycnt].io_flag,"::",tempexistingassayreply->slist[1].assay_list[1].general_info.
         io_flag))
       SET reply->assays[importedassaycnt].modified_status = modified
      ENDIF
     ENDIF
    ENDIF
    IF (importedresulttypemean="8")
     IF ((reply->assays[importedassaycnt].modified_status=none))
      CALL assayequationcomparison(importedassaycnt,taskassaycd)
     ENDIF
    ELSEIF (importedresulttypemean="4")
     IF ((reply->assays[importedassaycnt].modified_status=none)
      AND shouldevaluateinterps)
      IF (areinterpsdifferent(taskassayuid,taskassaycd))
       SET reply->assays[importedassaycnt].modified_status = modified
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL bedlogmessage("compareImportedAgainstExistingAssay","Exiting ...")
 END ;Subroutine
 SUBROUTINE assayalphamultifreetextcomparison(assindex)
   CALL bedlogmessage("assayAlphaMultiFreetextComparison","Entering ...")
   IF ((reply->assays[assindex].single_select_ind != tempexistingassayreply->slist[1].assay_list[1].
   general_info.single_select_ind))
    CALL logdebuginfo(build2("Single select indicator is different",reply->assays[assindex].
      single_select_ind,tempexistingassayreply->slist[1].assay_list[1].general_info.single_select_ind
      ))
    SET reply->assays[assindex].modified_status = modified
   ENDIF
   DECLARE prrcnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE num3 = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE foundprocrr = i4 WITH protect, noconstant(0)
   DECLARE allexistingrrcopied = i2 WITH protect, noconstant(0)
   FREE RECORD processedrr
   RECORD processedrr(
     1 list[*]
       2 rrf_id = f8
   )
   IF (size(reply->assays[assindex].ref_ranges,5) > 0)
    CALL logdebuginfo(build2("Imported content has reference ranges to compare: ",size(reply->assays[
       assindex].ref_ranges,5)))
    FOR (j = 1 TO size(reply->assays[assindex].ref_ranges,5))
      SET num = 1
      SET pos = locateval(num,1,size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5),
       cnvtint(reply->assays[assindex].ref_ranges[j].age_to),tempexistingassayreply->slist[1].
       assay_list[1].rr_list[num].to_age,
       reply->assays[assindex].ref_ranges[j].age_to_units.code_value,tempexistingassayreply->slist[1]
       .assay_list[1].rr_list[num].to_age_unit_code_value,cnvtint(reply->assays[assindex].ref_ranges[
        j].age_from),tempexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age,reply->
       assays[assindex].ref_ranges[j].age_from_units.code_value,
       tempexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age_unit_code_value,reply->
       assays[assindex].ref_ranges[j].sex.code_value,tempexistingassayreply->slist[1].assay_list[1].
       rr_list[num].sex_code_value)
      IF (pos > 0)
       CALL logdebuginfo(build2("Reference range match found for Age Range: ",reply->assays[assindex]
         .ref_ranges[j].age_from,"::",reply->assays[assindex].ref_ranges[j].age_to))
       SET prrcnt = (prrcnt+ 1)
       SET stat = alterlist(processedrr->list,prrcnt)
       SET processedrr->list[prrcnt].rrf_id = tempexistingassayreply->slist[1].assay_list[1].rr_list[
       pos].rrf_id
       IF (bailoutind
        AND (((reply->assays[assindex].modified_status != none)) OR (size(reply->assays[assindex].
        ref_ranges[j].alpha_responses,5) != size(tempexistingassayreply->slist[1].assay_list[1].
        rr_list[pos].alpha_list,5))) )
        RETURN(true)
       ENDIF
       FOR (l = 1 TO size(reply->assays[assindex].ref_ranges[j].alpha_responses,5))
        IF (bailoutind
         AND (reply->assays[assindex].modified_status != none))
         RETURN(true)
        ENDIF
        CALL assayalpharesponsecomparison(assindex,j,pos,l)
       ENDFOR
       IF (bailoutind=0)
        CALL findandpopulateremovedalpharesponse(assindex,j,pos)
       ENDIF
      ELSE
       CALL logdebuginfo(build2("Reference range match not found for Age Range: ",reply->assays[
         assindex].ref_ranges[j].age_from,"::",reply->assays[assindex].ref_ranges[j].age_to))
       SET reply->assays[assindex].modified_status = modified
       IF (bailoutind)
        RETURN(true)
       ENDIF
       CALL marknonmatchedalpharesponseasadded(assindex,j)
      ENDIF
    ENDFOR
   ELSEIF (size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5) > 0)
    CALL logdebuginfo(build2(
      "Imported content doesn't has reference ranges but there are Existing reference ranges: ",size(
       tempexistingassayreply->slist[1].assay_list[1].rr_list,5)))
    CALL copyexistingreferencerangestoimported(assindex,0.0)
    SET allexistingrrcopied = 1
   ELSE
    CALL logdebuginfo(build2("No Reference Ranges in Imported and Existing content."))
   ENDIF
   FOR (eai = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5))
     SET num3 = 1
     SET foundprocrr = locateval(num3,1,prrcnt,tempexistingassayreply->slist[1].assay_list[1].
      rr_list[eai].rrf_id,processedrr->list[num3].rrf_id)
     IF (foundprocrr=0
      AND allexistingrrcopied=0)
      CALL copyexistingreferencerangestoimported(assindex,tempexistingassayreply->slist[1].
       assay_list[1].rr_list[eai].rrf_id)
      SET reply->assays[assindex].modified_status = modified
      RETURN(true)
     ENDIF
   ENDFOR
   CALL bedlogmessage("assayAlphaMultiFreetextComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE marknonmatchedalpharesponseasadded(importedassaycnt,j)
   CALL bedlogmessage("markNonMatchedAlphaResponseAsAdded","Entering ...")
   DECLARE arcnt = i4 WITH protect, noconstant(0)
   FOR (arcnt = 1 TO size(reply->assays[importedassaycnt].ref_ranges[j].alpha_responses,5))
     SET reply->assays[importedassaycnt].ref_ranges[j].alpha_responses[arcnt].modified_status = added
   ENDFOR
   CALL bedlogmessage("markNonMatchedAlphaResponseAsAdded","Exiting ...")
 END ;Subroutine
 SUBROUTINE copyexistingreferencerangestoimported(importedassaycnt,existingrrid)
   CALL bedlogmessage("copyExistingReferenceRangesToImported","Entering ...")
   DECLARE rrcnt = i4 WITH protect, noconstant(0)
   DECLARE arcnt = i4 WITH protect, noconstant(0)
   DECLARE reprrcnt = i4 WITH protect, noconstant(0)
   SET reprrcnt = size(reply->assays[importedassaycnt].ref_ranges,5)
   CALL logdebuginfo(
    "Copy the Existing reference ranges and mark the assay as modified and the alpha responses as Removed."
    )
   CALL logdebuginfo(build2("Copy for RR ID: (i.e. 0 means ALL):",existingrrid))
   FOR (rrcnt = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5))
     IF (((existingrrid=0) OR ((existingrrid=tempexistingassayreply->slist[1].assay_list[1].rr_list[
     rrcnt].rrf_id))) )
      SET reprrcnt = (reprrcnt+ 1)
      SET stat = alterlist(reply->assays[importedassaycnt].ref_ranges,reprrcnt)
      SET reply->assays[importedassaycnt].modified_status = modified
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_from = tempexistingassayreply->
      slist[1].assay_list[1].rr_list[rrcnt].from_age
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_from_units.code_value =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].from_age_unit_code_value
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_from_units.display =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].from_age_unit_display
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_from_units.mean =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].from_age_unit_mean
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_to = tempexistingassayreply->
      slist[1].assay_list[1].rr_list[rrcnt].to_age
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_to_units.code_value =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].to_age_unit_code_value
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_to_units.display =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].to_age_unit_display
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].age_to_units.mean =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].to_age_unit_mean
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].sex.code_value =
      tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].sex_code_value
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].sex.display = tempexistingassayreply->
      slist[1].assay_list[1].rr_list[rrcnt].sex_display
      SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].sex.mean = tempexistingassayreply->
      slist[1].assay_list[1].rr_list[rrcnt].sex_mean
      FOR (arcnt = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list,
       5))
        SET stat = alterlist(reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses,
         arcnt)
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].
        modified_status = removed
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].source_string
         = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].
        source_string
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].short_string
         = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].
        short_string
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].mnemonic =
        tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].mnemonic
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].
        nomenclature_id = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[
        arcnt].nomenclature_id
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].sequence =
        tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].sequence
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].reference_ind
         = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].
        reference_ind
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].default_ind
         = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].
        default_ind
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].use_units_ind
         = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].alpha_list[arcnt].
        use_units_ind
        SET reply->assays[importedassaycnt].ref_ranges[reprrcnt].alpha_responses[arcnt].
        result_process_code_value = tempexistingassayreply->slist[1].assay_list[1].rr_list[rrcnt].
        alpha_list[arcnt].result_process_code_value
      ENDFOR
     ENDIF
   ENDFOR
   CALL bedlogmessage("copyExistingReferenceRangesToImported","Exiting ...")
 END ;Subroutine
 SUBROUTINE assaygeneralcomparison(assayindex)
   CALL bedlogmessage("assayGeneralComparison","Entering ...")
   IF ((reply->assays[assayindex].description != tempexistingassayreply->slist[1].assay_list[1].
   description))
    CALL logdebuginfo(build2("Assay Description is different: ",reply->assays[assayindex].description,
      "::",tempexistingassayreply->slist[1].assay_list[1].description))
    SET reply->assays[assayindex].modified_status = modified
   ELSEIF ((reply->assays[assayindex].witness_required_ind != tempexistingassayreply->slist[1].
   assay_list[1].witness_required_ind))
    CALL logdebuginfo(build2("Assay Witness Required Ind is different: ",reply->assays[assayindex].
      witness_required_ind,"::",tempexistingassayreply->slist[1].assay_list[1].witness_required_ind))
    SET reply->assays[assayindex].modified_status = modified
   ELSEIF ((reply->assays[assayindex].default_type_flag != tempexistingassayreply->slist[1].
   assay_list[1].default_type_flag))
    CALL logdebuginfo(build2("Assay default type flag is different: ",reply->assays[assayindex].
      default_type_flag,"::",tempexistingassayreply->slist[1].assay_list[1].default_type_flag))
    SET reply->assays[assayindex].modified_status = modified
   ELSEIF ((reply->assays[assayindex].activity_type.code_value != tempexistingassayreply->slist[1].
   assay_list[1].general_info.activity_type_code_value))
    CALL logdebuginfo(build2("Assay Activity Type is different: ",reply->assays[assayindex].
      activity_type.code_value,"::",tempexistingassayreply->slist[1].assay_list[1].general_info.
      activity_type_code_value))
    SET reply->assays[assayindex].modified_status = modified
   ELSEIF ((reply->assays[assayindex].concept_cki != tempexistingassayreply->slist[1].assay_list[1].
   general_info.concept.concept_cki))
    CALL logdebuginfo(build2("Assay Concept CKI is different: ",reply->assays[assayindex].concept_cki,
      "::",tempexistingassayreply->slist[1].assay_list[1].general_info.concept.concept_cki))
    SET reply->assays[assayindex].modified_status = modified
   ELSEIF ((reply->assays[assayindex].event.event_cd_cki != tempexistingassayreply->slist[1].
   assay_list[1].general_info.event.event_cd_cki))
    CALL logdebuginfo(build2("CKI is different: ",reply->assays[assayindex].event.event_cd_cki,"::",
      tempexistingassayreply->slist[1].assay_list[1].general_info.event.event_cd_cki))
    SET reply->assays[assayindex].modified_status = modified
   ENDIF
   IF ((reply->assays[assayindex].modified_status=none))
    CALL assayoffsetminutescomparison(assayindex)
   ENDIF
   CALL bedlogmessage("assayGeneralComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE assayoffsetminutescomparison(assayindex)
   CALL bedlogmessage("assayOffsetMinutesComparison","Entering ...")
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE ofound = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SET icnt = size(reply->assays[assayindex].lookback_minutes,5)
   SET ecnt = size(tempexistingassayreply->slist[1].assay_list[1].lookback_minutes,5)
   IF (icnt != ecnt)
    CALL logdebuginfo(build2("Assay Offset min fields (size): ",icnt,"::",ecnt))
    SET reply->assays[assayindex].modified_status = modified
   ELSE
    IF (icnt > 0)
     FOR (ii = 1 TO icnt)
       SET num = 1
       SET ofound = locateval(num,1,ecnt,reply->assays[assayindex].lookback_minutes[icnt].
        type_code_value,tempexistingassayreply->slist[1].assay_list[1].lookback_minutes[num].
        type_code_value)
       IF (ofound > 0)
        IF ((reply->assays[assayindex].lookback_minutes[icnt].minutes_nbr != tempexistingassayreply->
        slist[1].assay_list[1].lookback_minutes[num].minutes_nbr))
         CALL logdebuginfo(build2("Assay Lookback Min: ",reply->assays[assayindex].lookback_minutes[
           icnt].minutes_nbr,"::",tempexistingassayreply->slist[1].assay_list[1].lookback_minutes[num
           ].minutes_nbr))
         SET reply->assays[assayindex].modified_status = modified
         RETURN(true)
        ENDIF
       ELSE
        CALL logdebuginfo(build2("No lookback min match found for: ",reply->assays[assayindex].
          lookback_minutes[icnt].type_display))
        SET reply->assays[assayindex].modified_status = modified
        RETURN(true)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL bedlogmessage("assayOffsetMinutesComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE assaynumericmappingcomparison(assayindex)
   CALL bedlogmessage("assayNumericMappingComparison","Entering ...")
   DECLARE datamapcnt = i4 WITH noconstant(0), protect
   DECLARE locatevalresult = i4 WITH noconstant(0), protect
   DECLARE locatevalindex = i4 WITH noconstant(0), protect
   IF (size(tempexistingassayreply->slist[1].assay_list[1].data_map,5)=0)
    SET reply->assays[assayindex].modified_status = modified
   ELSE
    SET locatevalresult = locateval(locatevalindex,1,size(tempexistingassayreply->slist[1].
      assay_list[1].data_map,5),0.0,tempexistingassayreply->slist[1].assay_list[1].data_map[
     locatevalindex].service_resource_code_value)
    IF (locatevalresult > 0)
     IF ((reply->assays[assayindex].max_digits != tempexistingassayreply->slist[1].assay_list[1].
     data_map[locatevalresult].max_digits))
      CALL logdebuginfo(build2("Assay Numeric Max is different: ",reply->assays[assayindex].
        max_digits,"::",tempexistingassayreply->slist[1].assay_list[1].data_map[locatevalresult].
        max_digits))
      SET reply->assays[assayindex].modified_status = modified
     ELSEIF ((reply->assays[assayindex].min_digits != tempexistingassayreply->slist[1].assay_list[1].
     data_map[locatevalresult].min_digits))
      CALL logdebuginfo(build2("Assay Numeric Min is different: ",reply->assays[assayindex].
        min_digits,"::",tempexistingassayreply->slist[1].assay_list[1].data_map[locatevalresult].
        min_digits))
      SET reply->assays[assayindex].modified_status = modified
     ELSEIF ((reply->assays[assayindex].min_decimal_places != tempexistingassayreply->slist[1].
     assay_list[1].data_map[locatevalresult].dec_place))
      CALL logdebuginfo(build2("Assay Numeric Decimal is different: ",reply->assays[assayindex].
        min_decimal_places,"::",tempexistingassayreply->slist[1].assay_list[1].data_map[
        locatevalresult].dec_place))
      SET reply->assays[assayindex].modified_status = modified
     ENDIF
    ENDIF
   ENDIF
   CALL bedlogmessage("assayNumericMappingComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE assayequationcomparison(i,taskassaycd)
   CALL bedlogmessage("assayEquationComparison","Entering ...")
   DECLARE equationcnt = i4 WITH noconstant(0), protect
   DECLARE equationfound = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE eqproccnt = i4 WITH noconstant(0), protect
   DECLARE comparerefrangedetails = i2 WITH noconstant(0), protect
   FREE RECORD eqprocessed
   RECORD eqprocessed(
     1 list[*]
       2 id = f8
   )
   FOR (equationcnt = 1 TO size(reply->assays[i].equations,5))
     SET comparerefrangedetails = 0
     SET num = 1
     SET equationfound = locateval(num,1,size(tempexistingassayreply->slist[1].assay_list[1].equation,
       5),reply->assays[i].equations[equationcnt].equation_id,tempexistingassayreply->slist[1].
      assay_list[1].equation[num].id)
     IF (equationfound=0)
      SET num = 1
      SET equationfound = locateval(num,1,size(tempexistingassayreply->slist[1].assay_list[1].
        equation,5),reply->assays[i].equations[equationcnt].age_from,tempexistingassayreply->slist[1]
       .assay_list[1].equation[num].age_from,
       reply->assays[i].equations[equationcnt].age_from_units.code_value,tempexistingassayreply->
       slist[1].assay_list[1].equation[num].age_from_units.code_value,reply->assays[i].equations[
       equationcnt].age_to,tempexistingassayreply->slist[1].assay_list[1].equation[num].age_to,reply
       ->assays[i].equations[equationcnt].age_to_units.code_value,
       tempexistingassayreply->slist[1].assay_list[1].equation[num].age_to_units.code_value,reply->
       assays[i].equations[equationcnt].sex.code_value,tempexistingassayreply->slist[1].assay_list[1]
       .equation[num].sex.code_value)
     ELSE
      SET comparerefrangedetails = 1
     ENDIF
     IF (equationfound > 0)
      SET eqproccnt = (eqproccnt+ 1)
      SET stat = alterlist(eqprocessed->list,eqproccnt)
      SET eqprocessed->list[eqproccnt].id = tempexistingassayreply->slist[1].assay_list[1].equation[
      equationfound].id
      IF ((reply->assays[i].equations[equationcnt].description != tempexistingassayreply->slist[1].
      assay_list[1].equation[equationfound].equation_description))
       CALL logdebuginfo(build2("Assay Equation - Description is different: ",reply->assays[i].
         equations[equationcnt].description,"::",tempexistingassayreply->slist[1].assay_list[1].
         equation[equationfound].equation_description))
       SET reply->assays[i].modified_status = modified
      ELSEIF ((reply->assays[i].equations[equationcnt].unknown_age_ind != tempexistingassayreply->
      slist[1].assay_list[1].equation[equationfound].unknown_age_ind))
       CALL logdebuginfo(build2("Assay Equation - Unknown Age is different: ",reply->assays[i].
         equations[equationcnt].unknown_age_ind,"::",tempexistingassayreply->slist[1].assay_list[1].
         equation[equationfound].unknown_age_ind))
       SET reply->assays[i].modified_status = modified
      ELSEIF ((reply->assays[i].equations[equationcnt].default_ind != tempexistingassayreply->slist[1
      ].assay_list[1].equation[equationfound].default_ind))
       CALL logdebuginfo(build2("Assay Equation - Default is different: ",reply->assays[i].equations[
         equationcnt].default_ind,"::",tempexistingassayreply->slist[1].assay_list[1].equation[
         equationfound].default_ind))
       SET reply->assays[i].modified_status = modified
      ELSEIF (comparerefrangedetails=1
       AND (reply->assays[i].equations[equationcnt].age_from != tempexistingassayreply->slist[1].
      assay_list[1].equation[equationfound].age_from))
       CALL logdebuginfo(build2("Assay Equation - Age From is different: ",reply->assays[i].
         equations[equationcnt].age_from,"::",tempexistingassayreply->slist[1].assay_list[1].
         equation[equationfound].age_from))
       SET reply->assays[i].modified_status = modified
      ELSEIF (comparerefrangedetails=1
       AND (reply->assays[i].equations[equationcnt].age_from_units.code_value !=
      tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].age_from_units.
      code_value))
       CALL logdebuginfo(build2("Assay Equation - Age From Units is different: ",reply->assays[i].
         equations[equationcnt].age_from_units.code_value,"::",tempexistingassayreply->slist[1].
         assay_list[1].equation[equationfound].age_from_units.code_value))
       SET reply->assays[i].modified_status = modified
      ELSEIF (comparerefrangedetails=1
       AND (reply->assays[i].equations[equationcnt].age_to != tempexistingassayreply->slist[1].
      assay_list[1].equation[equationfound].age_to))
       CALL logdebuginfo(build2("Assay Equation - Age To is different: ",reply->assays[i].equations[
         equationcnt].age_to,"::",tempexistingassayreply->slist[1].assay_list[1].equation[
         equationfound].age_to))
       SET reply->assays[i].modified_status = modified
      ELSEIF (comparerefrangedetails=1
       AND (reply->assays[i].equations[equationcnt].age_to_units.code_value != tempexistingassayreply
      ->slist[1].assay_list[1].equation[equationfound].age_to_units.code_value))
       CALL logdebuginfo(build2("Assay Equation - Age To Units is different: ",reply->assays[i].
         equations[equationcnt].age_to_units.code_value,"::",tempexistingassayreply->slist[1].
         assay_list[1].equation[equationfound].age_to_units.code_value))
       SET reply->assays[i].modified_status = modified
      ELSEIF (comparerefrangedetails=1
       AND (reply->assays[i].equations[equationcnt].sex.code_value != tempexistingassayreply->slist[1
      ].assay_list[1].equation[equationfound].sex.code_value))
       CALL logdebuginfo(build2("Assay Equation - Sex cd is different: ",reply->assays[i].equations[
         equationcnt].sex.code_value,"::",tempexistingassayreply->slist[1].assay_list[1].equation[
         equationfound].sex.code_value))
       SET reply->assays[i].modified_status = modified
      ELSEIF (size(reply->assays[i].equations[equationcnt].components,5) != size(
       tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components,5))
       CALL logdebuginfo("Number of components for this assay is different")
       SET reply->assays[i].modified_status = modified
      ELSEIF (size(reply->assays[i].equations[equationcnt].components,5)=size(tempexistingassayreply
       ->slist[1].assay_list[1].equation[equationfound].components,5))
       FOR (componentidx = 1 TO size(reply->assays[i].equations[equationcnt].components,5))
         IF ((reply->assays[i].equations[equationcnt].components[componentidx].included_assay.
         code_value != tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].
         components[componentidx].included_assay.code_value))
          CALL logdebuginfo(build2("Assay component for equation is diffrent",reply->assays[i].
            equations[equationcnt].components[componentidx].included_assay.code_value,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].included_assay.code_value))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].component_name !=
         tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
         componentidx].component_name))
          CALL logdebuginfo(build2("Component name for equation is diffrent",reply->assays[i].
            equations[equationcnt].components[componentidx].component_name,tempexistingassayreply->
            slist[1].assay_list[1].equation[equationfound].components[componentidx].component_name))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].constant_value !=
         tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
         componentidx].constant_value))
          CALL logdebuginfo(build2("Constant value for equation is diffrent",reply->assays[i].
            equations[equationcnt].components[componentidx].constant_value,tempexistingassayreply->
            slist[1].assay_list[1].equation[equationfound].components[componentidx].constant_value))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].required_flag !=
         tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
         componentidx].required_flag))
          CALL logdebuginfo(build2("Required flag for component for equation is diffrent",reply->
            assays[i].equations[equationcnt].components[componentidx].required_flag,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].required_flag))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].
         look_time_direction_flag != tempexistingassayreply->slist[1].assay_list[1].equation[
         equationfound].components[componentidx].look_time_direction_flag))
          CALL logdebuginfo(build2("Look time dir flag for component for equation is diffrent",reply
            ->assays[i].equations[equationcnt].components[componentidx].look_time_direction_flag,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].look_time_direction_flag))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].
         time_window_back_minutes != tempexistingassayreply->slist[1].assay_list[1].equation[
         equationfound].components[componentidx].time_window_back_minutes))
          CALL logdebuginfo(build2("Look back min for component for equation is diffrent",reply->
            assays[i].equations[equationcnt].components[componentidx].time_window_back_minutes,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].time_window_back_minutes))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].
         time_window_minutes != tempexistingassayreply->slist[1].assay_list[1].equation[equationfound
         ].components[componentidx].time_window_minutes))
          CALL logdebuginfo(build2("Time window for component for equation is diffrent",reply->
            assays[i].equations[equationcnt].components[componentidx].time_window_minutes,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].time_window_minutes))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].value_unit.
         code_value != tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].
         components[componentidx].value_unit.code_value))
          CALL logdebuginfo(build2("Unit code for component for equation is diffrent",reply->assays[i
            ].equations[equationcnt].components[componentidx].value_unit.code_value,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].value_unit.code_value))
          SET reply->assays[i].modified_status = modified
         ELSEIF ((reply->assays[i].equations[equationcnt].components[componentidx].optional_value !=
         tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
         componentidx].optional_value))
          CALL logdebuginfo(build2("optional_value for component for equation is diffrent",reply->
            assays[i].equations[equationcnt].components[componentidx].optional_value,
            tempexistingassayreply->slist[1].assay_list[1].equation[equationfound].components[
            componentidx].optional_value))
          SET reply->assays[i].modified_status = modified
         ENDIF
       ENDFOR
      ENDIF
     ELSE
      CALL logdebuginfo(build2("Assay Equation - no match on millennium side found: ",reply->assays[i
        ].equations[equationcnt].equation_id))
      SET reply->assays[i].modified_status = modified
     ENDIF
   ENDFOR
   FOR (exeqcnt = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].equation,5))
     SET num = 1
     SET equationfound = locateval(num,1,eqproccnt,tempexistingassayreply->slist[1].assay_list[1].
      equation[exeqcnt].id,eqprocessed->list[num].id)
     IF (equationfound=0)
      CALL logdebuginfo("Equation exists in millennium but not on content.")
      SET reply->assays[i].modified_status = modified
     ENDIF
   ENDFOR
   CALL bedlogmessage("assayEquationComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE assaynumericdetailscomparison(i)
   CALL bedlogmessage("assayNumericDetailsComparison","Entering ...")
   DECLARE prrcnt = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE num3 = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE foundprocrr = i4 WITH protect, noconstant(0)
   FREE RECORD processedrr
   RECORD processedrr(
     1 list[*]
       2 rrf_id = f8
   )
   IF (size(reply->assays[i].ref_ranges,5) > 0)
    CALL logdebuginfo(build2("Imported content has reference ranges to compare: ",size(reply->assays[
       i].ref_ranges,5)))
    FOR (j = 1 TO size(reply->assays[i].ref_ranges,5))
      SET num = 1
      SET pos = locateval(num,1,size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5),
       cnvtint(reply->assays[i].ref_ranges[j].age_to),tempexistingassayreply->slist[1].assay_list[1].
       rr_list[num].to_age,
       reply->assays[i].ref_ranges[j].age_to_units.code_value,tempexistingassayreply->slist[1].
       assay_list[1].rr_list[num].to_age_unit_code_value,cnvtint(reply->assays[i].ref_ranges[j].
        age_from),tempexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age,reply->assays[
       i].ref_ranges[j].age_from_units.code_value,
       tempexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age_unit_code_value,reply->
       assays[i].ref_ranges[j].sex.code_value,tempexistingassayreply->slist[1].assay_list[1].rr_list[
       num].sex_code_value)
      IF (pos > 0)
       CALL logdebuginfo(build2("Reference range match found for Age Range: ",reply->assays[i].
         ref_ranges[j].age_from,"::",reply->assays[i].ref_ranges[j].age_to))
       SET prrcnt = (prrcnt+ 1)
       SET stat = alterlist(processedrr->list,prrcnt)
       SET processedrr->list[prrcnt].rrf_id = tempexistingassayreply->slist[1].assay_list[1].rr_list[
       pos].rrf_id
       IF ((reply->assays[i].ref_ranges[j].units.code_value != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].uom_code_value))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].units.code_value,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[
          pos].uom_code_value))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].normal_low != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].ref_low))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].normal_low,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          ref_low))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].normal_high != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].ref_high))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].normal_high,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          ref_high))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].critical_low != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].crit_low))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].critical_low,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos]
          .crit_low))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].critical_high != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].crit_high))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].critical_high,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos
          ].crit_high))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].review_low != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].review_low))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].review_low,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          review_low))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].review_high != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].review_high))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].review_high,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          review_high))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].linear_low != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].linear_low))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].linear_low,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          linear_low))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].linear_high != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].linear_high))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].linear_high,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos].
          linear_high))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].feasible_low != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].feasible_low))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].feasible_low,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos]
          .feasible_low))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].feasible_high != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].feasible_high))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].feasible_high,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[pos
          ].feasible_high))
        SET reply->assays[i].modified_status = modified
       ELSEIF ((reply->assays[i].ref_ranges[j].default_result != tempexistingassayreply->slist[1].
       assay_list[1].rr_list[pos].def_value))
        CALL logdebuginfo(build2("Ref Range Units code value is different: ",reply->assays[i].
          ref_ranges[j].default_result,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[
          pos].def_value))
        SET reply->assays[i].modified_status = modified
       ENDIF
      ELSE
       CALL logdebuginfo(build2("Reference range match not found for Age Range: ",reply->assays[i].
         ref_ranges[j].age_from,"::",reply->assays[i].ref_ranges[j].age_to))
       SET reply->assays[i].modified_status = modified
       IF (bailoutind)
        RETURN(true)
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF (size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5) > 0)
    CALL logdebuginfo(build2(
      "Imported content doesn't has reference ranges but there are Existing reference ranges: ",size(
       tempexistingassayreply->slist[1].assay_list[1].rr_list,5)))
    SET reply->assays[i].modified_status = modified
   ELSE
    CALL logdebuginfo("No Reference Ranges in Imported and Existing content.")
   ENDIF
   FOR (eai = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].rr_list,5))
     SET num3 = 1
     SET foundprocrr = locateval(num3,1,prrcnt,tempexistingassayreply->slist[1].assay_list[1].
      rr_list[eai].rrf_id,processedrr->list[num3].rrf_id)
     IF (foundprocrr=0)
      CALL logdebuginfo(
       "There is existing reference range for this numeric assay where no match on content side.")
      SET reply->assays[importedassaycnt].modified_status = modified
      RETURN(true)
     ENDIF
   ENDFOR
   CALL bedlogmessage("assayNumericDetailsComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE assayalpharesponsecomparison(i,j,k,l)
   CALL bedlogmessage("assayAlphaResponseComparison","Entering ...")
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = none
   SET pos = locateval(num,1,size(tempexistingassayreply->slist[1].assay_list[1].rr_list[k].
     alpha_list,5),reply->assays[i].ref_ranges[j].alpha_responses[l].nomenclature_id,
    tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[num].nomenclature_id)
   IF (pos > 0)
    CALL logdebuginfo(build2("Alpha response match found: ",trim(reply->assays[i].ref_ranges[j].
       alpha_responses[l].source_string)))
    IF ((reply->assays[i].ref_ranges[j].alpha_responses[l].sequence != tempexistingassayreply->slist[
    1].assay_list[1].rr_list[k].alpha_list[pos].sequence))
     CALL logdebuginfo(build2("Alpha response sequence is different: ",reply->assays[i].ref_ranges[j]
       .alpha_responses[l].sequence,"::",tempexistingassayreply->slist[1].assay_list[1].rr_list[k].
       alpha_list[pos].sequence))
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = modified
    ELSEIF ((reply->assays[i].ref_ranges[j].alpha_responses[l].result_value != tempexistingassayreply
    ->slist[1].assay_list[1].rr_list[k].alpha_list[pos].result_value))
     CALL logdebuginfo(build2("Alpha response result value is different: ",reply->assays[i].
       ref_ranges[j].alpha_responses[l].result_value,"::",tempexistingassayreply->slist[1].
       assay_list[1].rr_list[k].alpha_list[pos].result_value))
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = modified
    ELSEIF ((reply->assays[i].ref_ranges[j].alpha_responses[l].truth_state_cd !=
    tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[pos].truth_state_cd))
     CALL logdebuginfo(build2("Alpha response truth state is different: ",reply->assays[i].
       ref_ranges[j].alpha_responses[l].truth_state_cd,"::",tempexistingassayreply->slist[1].
       assay_list[1].rr_list[k].alpha_list[pos].truth_state_cd))
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = modified
    ELSEIF ((reply->assays[i].ref_ranges[j].alpha_responses[l].multi_alpha_sort_order !=
    tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[pos].grid_display))
     CALL logdebuginfo(build2("Alpha response grid display is different: ",reply->assays[i].
       ref_ranges[j].alpha_responses[l].multi_alpha_sort_order,"::",tempexistingassayreply->slist[1].
       assay_list[1].rr_list[k].alpha_list[pos].grid_display))
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = modified
    ELSEIF ((reply->assays[i].ref_ranges[j].alpha_responses[l].default_ind != tempexistingassayreply
    ->slist[1].assay_list[1].rr_list[k].alpha_list[pos].default_ind))
     CALL logdebuginfo(build2("Alpha response default ind is different: ",reply->assays[i].
       ref_ranges[j].alpha_responses[l].default_ind,"::",tempexistingassayreply->slist[1].assay_list[
       1].rr_list[k].alpha_list[pos].default_ind))
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = modified
    ENDIF
   ELSE
    CALL logdebuginfo(build2("Alpha response match not found thus mark it as added: ",trim(reply->
       assays[i].ref_ranges[j].alpha_responses[l].source_string)))
    SET reply->assays[i].ref_ranges[j].alpha_responses[l].modified_status = added
    SET reply->assays[i].modified_status = modified
   ENDIF
   CALL bedlogmessage("assayAlphaResponseComparison","Exiting ...")
 END ;Subroutine
 SUBROUTINE findandpopulateremovedalpharesponse(i,j,k)
   CALL bedlogmessage("findAndPopulateRemovedAlphaResponse","Entering ...")
   DECLARE num = i4 WITH noconstant(0), public
   FOR (w = 1 TO size(tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list,5))
    SET pos = locateval(num,1,size(reply->assays[i].ref_ranges[j].alpha_responses,5),
     tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[w].nomenclature_id,reply->
     assays[i].ref_ranges[j].alpha_responses[num].nomenclature_id)
    IF (pos=0)
     CALL echo("findAndPopulateRemovedAlphaResponse - found removed alpha resp.")
     CALL echo(build("Alpha resp Existing:::: ",tempexistingassayreply->slist[1].assay_list[1].
       rr_list[k].alpha_list[w].mnemonic))
     SET acnt = (size(reply->assays[i].ref_ranges[j].alpha_responses,5)+ 1)
     SET stat = alterlist(reply->assays[i].ref_ranges[j].alpha_responses,acnt)
     SET reply->assays[i].modified_status = modified
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].modified_status = removed
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].source_string = tempexistingassayreply
     ->slist[1].assay_list[1].rr_list[k].alpha_list[w].source_string
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].short_string = tempexistingassayreply->
     slist[1].assay_list[1].rr_list[k].alpha_list[w].short_string
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].mnemonic = tempexistingassayreply->
     slist[1].assay_list[1].rr_list[k].alpha_list[w].mnemonic
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].nomenclature_id =
     tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[w].nomenclature_id
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].sequence = tempexistingassayreply->
     slist[1].assay_list[1].rr_list[k].alpha_list[w].sequence
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].reference_ind = tempexistingassayreply
     ->slist[1].assay_list[1].rr_list[k].alpha_list[w].reference_ind
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].default_ind = tempexistingassayreply->
     slist[1].assay_list[1].rr_list[k].alpha_list[w].default_ind
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].use_units_ind = tempexistingassayreply
     ->slist[1].assay_list[1].rr_list[k].alpha_list[w].use_units_ind
     SET reply->assays[i].ref_ranges[j].alpha_responses[acnt].result_process_code_value =
     tempexistingassayreply->slist[1].assay_list[1].rr_list[k].alpha_list[w].
     result_process_code_value
    ENDIF
   ENDFOR
   CALL bedlogmessage("findAndPopulateRemovedAlphaResponse","Exiting ...")
 END ;Subroutine
 SUBROUTINE areinterpsdifferent(taskassayuid,taskassaycd)
   CALL bedlogmessage("areInterpsDifferent","Entering ...")
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE poscomp = i4 WITH protect, noconstant(0)
   DECLARE posstate = i4 WITH protect, noconstant(0)
   DECLARE q = i4 WITH protect, noconstant(0)
   CALL getcntinterp(taskassayuid)
   CALL getdcpinterp(taskassaycd)
   IF (validate(debug,0)=1)
    CALL echorecord(interpimported)
    CALL echorecord(interpexisting)
   ENDIF
   IF (size(interpimported->interp,5)=size(interpexisting->interp,5))
    FOR (q = 1 TO size(interpimported->interp,5))
      SET num = 1
      SET pos = locateval(num,1,size(interpexisting->interp,5),interpimported->interp[q].
       age_from_minutes,interpexisting->interp[num].age_from_minutes,
       interpimported->interp[q].age_to_minutes,interpexisting->interp[num].age_to_minutes,
       interpimported->interp[q].sex_cd,interpexisting->interp[num].sex_cd)
      IF (pos > 0)
       CALL logdebuginfo(build2("Interp match found for Ref Range: ",interpimported->interp[q].
         age_from_minutes,"::",interpimported->interp[q].age_to_minutes))
       IF (size(interpimported->interp[q].comp,5)=size(interpexisting->interp[pos].comp,5))
        FOR (s = 1 TO size(interpimported->interp[q].comp,5))
          SET num = 1
          SET poscomp = locateval(num,1,size(interpexisting->interp[pos].comp,5),interpimported->
           interp[q].comp[s].component_assay_cd,interpexisting->interp[pos].comp[num].
           component_assay_cd)
          IF (poscomp > 0)
           CALL logdebuginfo(build2("Interp component match found: ",interpimported->interp[q].comp[s
             ].component_assay_cd))
           IF ((interpimported->interp[q].comp[s].sequence != interpexisting->interp[pos].comp[
           poscomp].sequence))
            CALL logdebuginfo(build2("Interp Component sequence is different: ",interpimported->
              interp[q].comp[s].sequence,"::",interpexisting->interp[pos].comp[poscomp].sequence))
            RETURN(true)
           ENDIF
           IF ((interpimported->interp[q].comp[s].flags != interpexisting->interp[pos].comp[poscomp].
           flags))
            CALL logdebuginfo(build2("Interp Component flags (num or calc) is different: ",
              interpimported->interp[q].comp[s].flags,"::",interpexisting->interp[pos].comp[poscomp].
              flags))
            RETURN(true)
           ENDIF
          ELSE
           CALL logdebuginfo(build2("Interp component is different: ",interpimported->interp[q].comp[
             s].description))
           RETURN(true)
          ENDIF
        ENDFOR
       ELSE
        CALL logdebuginfo(build2("Imported and Existing Interp component count are different: ",size(
           interpimported->interp[q].comp,5),"::",size(interpexisting->interp[pos].comp,5)))
        RETURN(true)
       ENDIF
       IF (size(interpimported->interp[q].state,5)=size(interpexisting->interp[pos].state,5))
        FOR (u = 1 TO size(interpimported->interp[q].state,5))
         CALL logdebuginfo(build2("Evalute for Resulting State: ",interpimported->interp[q].state[u].
           resulting_state))
         IF ((interpimported->interp[q].state[u].numeric_low != interpexisting->interp[pos].state[u].
         numeric_low))
          CALL logdebuginfo(build2("Interp Numeric Low is different: ",interpimported->interp[q].
            state[u].numeric_low,"::",interpexisting->interp[pos].state[u].numeric_low))
          RETURN(true)
         ELSEIF ((interpimported->interp[q].state[u].numeric_high != interpexisting->interp[pos].
         state[u].numeric_high))
          CALL logdebuginfo(build2("Interp Numeric High is different: ",interpimported->interp[q].
            state[u].numeric_high,"::",interpexisting->interp[pos].state[u].numeric_high))
          RETURN(true)
         ELSEIF ((interpimported->interp[q].state[u].nomenclature_id != interpexisting->interp[pos].
         state[u].nomenclature_id))
          CALL logdebuginfo(build2("Interp Nomenclature is different: ",interpimported->interp[q].
            state[u].nomenclature_id,"::",interpexisting->interp[pos].state[u].nomenclature_id))
          RETURN(true)
         ELSEIF ((interpimported->interp[q].state[u].result_nomenclature_id != interpexisting->
         interp[pos].state[u].result_nomenclature_id))
          CALL logdebuginfo(build2("Interp Result Nomenclature is different: ",interpimported->
            interp[q].state[u].result_nomenclature_id,"::",interpexisting->interp[pos].state[u].
            result_nomenclature_id))
          RETURN(true)
         ELSEIF ((interpimported->interp[q].state[u].resulting_state != interpexisting->interp[pos].
         state[u].resulting_state))
          CALL logdebuginfo(build2("Interp Result State is different: ",interpimported->interp[q].
            state[u].resulting_state,"::",interpexisting->interp[pos].state[u].resulting_state))
          RETURN(true)
         ELSEIF ((interpimported->interp[q].state[u].state != interpexisting->interp[pos].state[u].
         state))
          CALL logdebuginfo(build2("Interp state is different: ",interpimported->interp[q].state[u].
            state,"::",interpexisting->interp[pos].state[u].state))
          RETURN(true)
         ENDIF
        ENDFOR
       ELSE
        CALL logdebuginfo(build2("Imported and Existing Interp state count are different: ",size(
           interpimported->interp[q].state,5),"::",size(interpexisting->interp[pos].state,5)))
        RETURN(true)
       ENDIF
      ELSE
       CALL logdebuginfo(build2("Interp is different as Ref Range not found: ",interpimported->
         interp[q].age_from_minutes,"::",interpimported->interp[q].age_to_minutes))
       RETURN(true)
      ENDIF
    ENDFOR
   ELSE
    CALL logdebuginfo(build2("Imported and Existing Interp count are different: ",size(interpimported
       ->interp,5),"::",size(interpexisting->interp,5)))
    RETURN(true)
   ENDIF
   CALL bedlogmessage("areInterpsDifferent","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE getcntinterp(taskassayuid)
   CALL bedlogmessage("getCNTInterp","Entering ...")
   DECLARE icnt = i4 WITH noconstant(0), protect
   DECLARE iccnt = i4 WITH noconstant(0), protect
   DECLARE iscnt = i4 WITH noconstant(0), protect
   DECLARE intidx = i4 WITH noconstant(0), protect
   DECLARE stidx = i4 WITH noconstant(0), protect
   SET stat = initrec(interpimported)
   SELECT INTO "nl:"
    FROM cnt_dcp_interp2 i,
     cnt_dcp_interp_component ic,
     cnt_dta_key2 d,
     cnt_dta cd,
     cnt_code_value_key ck,
     discrete_task_assay dta
    PLAN (i
     WHERE i.task_assay_uid=taskassayuid)
     JOIN (ic
     WHERE ic.dcp_interp_uid=i.dcp_interp_uid)
     JOIN (d
     WHERE d.task_assay_uid=ic.component_assay_uid)
     JOIN (cd
     WHERE cd.task_assay_uid=d.task_assay_uid)
     JOIN (ck
     WHERE ck.code_value_uid=outerjoin(i.sex_cduid))
     JOIN (dta
     WHERE dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
      AND dta.activity_type_cd=outerjoin(cd.activity_type_cd)
      AND dta.active_ind=outerjoin(1))
    ORDER BY i.dcp_interp_uid, ic.component_sequence
    HEAD i.dcp_interp_uid
     icnt = (icnt+ 1), stat = alterlist(interpimported->interp,icnt), interpimported->interp[icnt].
     uid = i.dcp_interp_uid,
     interpimported->interp[icnt].age_from_minutes = i.age_from_minutes, interpimported->interp[icnt]
     .age_to_minutes = i.age_to_minutes
     IF (i.sex_cd > 0)
      interpimported->interp[icnt].sex_cd = i.sex_cd
     ELSEIF (ck.code_value > 0)
      interpimported->interp[icnt].sex_cd = ck.code_value
     ENDIF
     iccnt = 0
    HEAD ic.component_sequence
     iccnt = (iccnt+ 1), stat = alterlist(interpimported->interp[icnt].comp,iccnt)
     IF (d.task_assay_cd > 0)
      interpimported->interp[icnt].comp[iccnt].component_assay_cd = d.task_assay_cd
     ELSE
      interpimported->interp[icnt].comp[iccnt].component_assay_cd = dta.task_assay_cd
     ENDIF
     interpimported->interp[icnt].comp[iccnt].sequence = ic.component_sequence, interpimported->
     interp[icnt].comp[iccnt].description = ic.description, interpimported->interp[icnt].comp[iccnt].
     flags = ic.flags,
     interpimported->interp[icnt].comp[iccnt].mnemonic = dta.mnemonic
    WITH nocounter
   ;end select
   IF (icnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = icnt),
      cnt_dcp_interp_state s,
      cnt_dta_key2 d,
      cnt_dta cd,
      discrete_task_assay dta,
      cnt_alpha_response_key k1,
      cnt_alpha_response_key k2
     PLAN (d1)
      JOIN (s
      WHERE (s.dcp_interp_uid=interpimported->interp[d1.seq].uid))
      JOIN (k1
      WHERE k1.ar_uid=outerjoin(s.ar_uid))
      JOIN (k2
      WHERE k2.ar_uid=outerjoin(s.result_ar_uid))
      JOIN (d
      WHERE d.task_assay_uid=outerjoin(s.input_assay_uid))
      JOIN (cd
      WHERE cd.task_assay_uid=outerjoin(d.task_assay_uid))
      JOIN (dta
      WHERE dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
       AND dta.activity_type_cd=outerjoin(cd.activity_type_cd)
       AND dta.active_ind=outerjoin(1))
     ORDER BY s.dcp_interp_uid, s.resulting_state, s.cnt_dcp_interp_state_id
     HEAD s.dcp_interp_uid
      iscnt = 0
     HEAD s.cnt_dcp_interp_state_id
      iscnt = (iscnt+ 1), stat = alterlist(interpimported->interp[d1.seq].state,iscnt)
      IF (d.task_assay_cd > 0)
       interpimported->interp[d1.seq].state[iscnt].input_assay_cd = d.task_assay_cd
      ELSE
       interpimported->interp[d1.seq].state[iscnt].input_assay_cd = dta.task_assay_cd
      ENDIF
      interpimported->interp[d1.seq].state[iscnt].state = s.interp_state, interpimported->interp[d1
      .seq].state[iscnt].numeric_low = s.numeric_low, interpimported->interp[d1.seq].state[iscnt].
      numeric_high = s.numeric_high,
      interpimported->interp[d1.seq].state[iscnt].aruid = s.ar_uid
      IF (s.flags=0)
       IF (s.nomenclature_id > 0)
        interpimported->interp[d1.seq].state[iscnt].nomenclature_id = s.nomenclature_id
       ELSEIF (k1.nomenclature_id > 0)
        interpimported->interp[d1.seq].state[iscnt].nomenclature_id = k1.nomenclature_id
       ENDIF
      ENDIF
      interpimported->interp[d1.seq].state[iscnt].resulting_state = s.resulting_state, interpimported
      ->interp[d1.seq].state[iscnt].resultaruid = s.result_ar_uid
      IF (s.result_nomenclature_id > 0)
       interpimported->interp[d1.seq].state[iscnt].result_nomenclature_id = s.result_nomenclature_id
      ELSEIF (k2.nomenclature_id > 0)
       interpimported->interp[d1.seq].state[iscnt].result_nomenclature_id = k2.nomenclature_id
      ENDIF
      interpimported->interp[d1.seq].state[iscnt].result_value = s.result_value, interpimported->
      interp[d1.seq].state[iscnt].flags = s.flags
     WITH nocounter
    ;end select
   ENDIF
   FOR (intidx = 1 TO size(interpimported->interp,5))
     FOR (stidx = 1 TO size(interpimported->interp[intidx].state,5))
      IF ((interpimported->interp[intidx].state[stidx].nomenclature_id=0))
       SELECT INTO "nl:"
        FROM cnt_alpha_response_key ak,
         cnt_code_value_key c1,
         cnt_code_value_key c2,
         nomenclature n
        PLAN (ak
         WHERE (ak.ar_uid=interpimported->interp[intidx].state[stidx].aruid))
         JOIN (c1
         WHERE c1.code_value_uid=ak.source_vocabulary_cduid)
         JOIN (c2
         WHERE c2.code_value_uid=ak.principle_type_cduid)
         JOIN (n
         WHERE n.source_vocabulary_cd=c1.code_value
          AND n.source_identifier=ak.source_identifier
          AND n.source_string=ak.source_string
          AND n.principle_type_cd=c2.code_value)
        DETAIL
         interpimported->interp[intidx].state[stidx].nomenclature_id = n.nomenclature_id
        WITH nocounter
       ;end select
      ENDIF
      IF ((interpimported->interp[intidx].state[stidx].result_nomenclature_id=0))
       SELECT INTO "nl:"
        FROM cnt_alpha_response_key ak,
         cnt_code_value_key c1,
         cnt_code_value_key c2,
         nomenclature n
        PLAN (ak
         WHERE (ak.ar_uid=interpimported->interp[intidx].state[stidx].resultaruid))
         JOIN (c1
         WHERE c1.code_value_uid=ak.source_vocabulary_cduid)
         JOIN (c2
         WHERE c2.code_value_uid=ak.principle_type_cduid)
         JOIN (n
         WHERE n.source_vocabulary_cd=c1.code_value
          AND n.source_identifier=ak.source_identifier
          AND n.source_string=ak.source_string
          AND n.principle_type_cd=c2.code_value)
        DETAIL
         interpimported->interp[intidx].state[stidx].result_nomenclature_id = n.nomenclature_id
        WITH nocounter
       ;end select
      ENDIF
     ENDFOR
   ENDFOR
   CALL bedlogmessage("getCNTInterp","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdcpinterp(taskassaycd)
   CALL bedlogmessage("getDCPInterp","Entering ...")
   DECLARE interpcnt = i2 WITH noconstant(0), protect
   DECLARE interpcompcnt = i2 WITH noconstant(0), protect
   DECLARE interpstatecnt = i2 WITH noconstant(0), protect
   DECLARE rrsize = i4 WITH protect, noconstant(0)
   DECLARE compsize = i4 WITH protect, noconstant(0)
   DECLARE statesize = i4 WITH protect, noconstant(0)
   SET stat = initrec(interpexisting)
   FREE RECORD getexistinginterpsrequest
   RECORD getexistinginterpsrequest(
     1 assay_code_value = f8
   )
   FREE RECORD getexistinginterpsreply
   RECORD getexistinginterpsreply(
     1 reference_ranges[*]
       2 dcp_interp_id = f8
       2 sex_code_value = f8
       2 sex_display = vc
       2 sex_meaning = vc
       2 age_from_minutes = i4
       2 age_to_minutes = i4
       2 components[*]
         3 code_value = f8
         3 description = vc
         3 mnemonic = vc
         3 sequence = i4
         3 numeric_or_calc_ind = i2
         3 look_back_minutes = i4
         3 look_ahead_minutes = i4
         3 look_direction_ind = i2
       2 states[*]
         3 assay_code_value = f8
         3 state = i4
         3 numeric_low = i4
         3 numeric_high = i4
         3 nomenclature_id = f8
         3 resulting_state = i4
         3 result_nomenclature_id = f8
         3 numeric_low_double = f8
         3 numeric_high_double = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET getexistinginterpsrequest->assay_code_value = taskassaycd
   EXECUTE bed_get_interp  WITH replace("REQUEST",getexistinginterpsrequest), replace("REPLY",
    getexistinginterpsreply)
   SET rrsize = size(getexistinginterpsreply->reference_ranges,5)
   IF (rrsize > 0)
    SET stat = alterlist(interpexisting->interp,rrsize)
    FOR (interpcnt = 1 TO rrsize)
      SET interpexisting->interp[interpcnt].age_from_minutes = getexistinginterpsreply->
      reference_ranges[interpcnt].age_from_minutes
      SET interpexisting->interp[interpcnt].age_to_minutes = getexistinginterpsreply->
      reference_ranges[interpcnt].age_to_minutes
      SET interpexisting->interp[interpcnt].sex_cd = getexistinginterpsreply->reference_ranges[
      interpcnt].sex_code_value
      SET compsize = size(getexistinginterpsreply->reference_ranges[interpcnt].components,5)
      SET stat = alterlist(interpexisting->interp[interpcnt].comp,compsize)
      FOR (interpcompcnt = 1 TO compsize)
        SET interpexisting->interp[interpcnt].comp[interpcompcnt].component_assay_cd =
        getexistinginterpsreply->reference_ranges[interpcnt].components[interpcompcnt].code_value
        SET interpexisting->interp[interpcnt].comp[interpcompcnt].sequence = getexistinginterpsreply
        ->reference_ranges[interpcnt].components[interpcompcnt].sequence
        SET interpexisting->interp[interpcnt].comp[interpcompcnt].description =
        getexistinginterpsreply->reference_ranges[interpcnt].components[interpcompcnt].description
        SET interpexisting->interp[interpcnt].comp[interpcompcnt].flags = getexistinginterpsreply->
        reference_ranges[interpcnt].components[interpcompcnt].numeric_or_calc_ind
      ENDFOR
      SET statesize = size(getexistinginterpsreply->reference_ranges[interpcnt].states,5)
      SET stat = alterlist(interpexisting->interp[interpcnt].state,statesize)
      FOR (interpstatecnt = 1 TO statesize)
        SET interpexisting->interp[interpcnt].state[interpstatecnt].input_assay_cd =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].assay_code_value
        SET interpexisting->interp[interpcnt].state[interpstatecnt].state = getexistinginterpsreply->
        reference_ranges[interpcnt].states[interpstatecnt].state
        SET interpexisting->interp[interpcnt].state[interpstatecnt].numeric_low =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].
        numeric_low_double
        SET interpexisting->interp[interpcnt].state[interpstatecnt].numeric_high =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].
        numeric_high_double
        SET interpexisting->interp[interpcnt].state[interpstatecnt].nomenclature_id =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].nomenclature_id
        SET interpexisting->interp[interpcnt].state[interpstatecnt].resulting_state =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].resulting_state
        SET interpexisting->interp[interpcnt].state[interpstatecnt].result_nomenclature_id =
        getexistinginterpsreply->reference_ranges[interpcnt].states[interpstatecnt].
        result_nomenclature_id
      ENDFOR
    ENDFOR
   ENDIF
   CALL bedlogmessage("getDCPInterp","Exiting ...")
 END ;Subroutine
 SUBROUTINE arereferencetextdifferent(taskassayuid,taskassaycd)
   CALL bedlogmessage("areReferenceTextDifferent","Entering ...")
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   CALL getcntreftext(taskassayuid)
   CALL getdcpreftext(taskassaycd)
   IF ( NOT (size(reftextimported->ref_text,5) > 0)
    AND size(reftextexisting->ref_text,5) > 0)
    RETURN(3)
   ELSEIF ( NOT (size(reftextexisting->ref_text,5) > 0)
    AND size(reftextimported->ref_text,5) > 0)
    RETURN(2)
   ELSEIF (size(reftextimported->ref_text,5)=size(reftextexisting->ref_text,5))
    FOR (u = 1 TO size(reftextimported->ref_text,5))
      SET num = 1
      SET pos = locateval(num,1,size(reftextexisting->ref_text,5),reftextimported->ref_text[u].
       text_type_cd,reftextexisting->ref_text[num].text_type_cd)
      IF (pos > 0)
       IF ((reftextimported->ref_text[u].text != reftextexisting->ref_text[pos].text))
        CALL logdebuginfo(build2("Reference Text is different: ",reftextimported->ref_text[u].text,
          "::",reftextexisting->ref_text[pos].text))
        RETURN(1)
       ENDIF
      ELSE
       CALL logdebuginfo(build2("Reference Text type is different: ",reftextimported->ref_text[u].
         text_type_cd,"::",reftextexisting->ref_text[pos].text_type_cd))
       RETURN(1)
      ENDIF
    ENDFOR
   ELSE
    CALL logdebuginfo(build2("Imported and Existing Reference Text count are different: ",size(
       reftextimported->ref_text,5),"::",size(reftextexisting->ref_text,5)))
    RETURN(1)
   ENDIF
   CALL bedlogmessage("areReferenceTextDifferent","Exiting ...")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getcntreftext(taskassayuid)
   CALL bedlogmessage("getCNTRefText","Entering ...")
   SET stat = initrec(reftextimported)
   DECLARE reftextcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM cnt_ref_text t,
     cnt_code_value_key c
    PLAN (t
     WHERE t.task_assay_uid=taskassayuid)
     JOIN (c
     WHERE c.code_value_uid=t.text_type_cduid)
    HEAD t.cnt_ref_text_id
     ncnt = 0
    DETAIL
     reftextcnt = (reftextcnt+ 1), stat = alterlist(reftextimported->ref_text,reftextcnt),
     reftextimported->ref_text[reftextcnt].text_type_cd = c.code_value,
     reftextimported->ref_text[reftextcnt].text = t.cnt_ref_blob
    WITH nocounter
   ;end select
   CALL bedlogmessage("getCNTRefText","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdcpreftext(taskassaycd)
   CALL bedlogmessage("getDCPRefText","Entering ...")
   SET stat = initrec(reftextexisting)
   DECLARE reftextcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl;"
    FROM ref_text_reltn rtr,
     ref_text rt,
     long_blob lb
    PLAN (rtr
     WHERE rtr.parent_entity_name="DISCRETE_TASK_ASSAY"
      AND rtr.parent_entity_id=taskassaycd
      AND rtr.active_ind=true)
     JOIN (rt
     WHERE rt.refr_text_id=rtr.refr_text_id
      AND rt.text_entity_name="LONG_BLOB"
      AND rt.active_ind=true)
     JOIN (lb
     WHERE lb.long_blob_id=rt.text_entity_id
      AND lb.active_ind=true)
    ORDER BY rtr.ref_text_reltn_id, rt.refr_text_id, lb.long_blob_id
    HEAD lb.long_blob_id
     reftextcnt = (reftextcnt+ 1), stat = alterlist(reftextexisting->ref_text,reftextcnt),
     reftextexisting->ref_text[reftextcnt].text_type_cd = rt.text_type_cd,
     reftextexisting->ref_text[reftextcnt].text = lb.long_blob
    WITH nocounter
   ;end select
   CALL bedlogmessage("getDCPRefText","Exiting ...")
 END ;Subroutine
 SUBROUTINE getassaysinform(formuid)
   CALL bedlogmessage("getAssaysInForm","Entering ...")
   DECLARE assaycnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnt_pf_section_r f,
     cnt_section_dta_r s
    PLAN (f
     WHERE f.form_uid=formuid)
     JOIN (s
     WHERE s.section_uid=f.section_uid)
    HEAD s.task_assay_uid
     assaycnt = (assaycnt+ 1), stat = alterlist(assaysinform->assays,assaycnt), assaysinform->assays[
     assaycnt].task_assay_uid = s.task_assay_uid
    WITH nocounter
   ;end select
   CALL bedlogmessage("getAssaysInForm","Exiting ...")
 END ;Subroutine
 SUBROUTINE areallinterpassaysavailableinform(assayuid)
   CALL bedlogmessage("areAllInterpAssaysAvailableInForm","Entering ...")
   DECLARE assaycnt = i4 WITH protect, noconstant(size(assaysinform->assays,5))
   DECLARE interpcompassaycnt = i4 WITH protect, noconstant(0)
   DECLARE assayidx = i4 WITH protect, noconstant(0)
   DECLARE interpassayidx = i4 WITH protect, noconstant(0)
   DECLARE assaynotavailableinform = i2 WITH protect, noconstant(true)
   FREE RECORD interpcomponentassays
   RECORD interpcomponentassays(
     1 assays[*]
       2 task_assay_uid = vc
   )
   SELECT INTO "nl:"
    FROM cnt_dcp_interp2 i,
     cnt_dcp_interp_component ic
    PLAN (i
     WHERE i.task_assay_uid=assayuid)
     JOIN (ic
     WHERE ic.dcp_interp_uid=i.dcp_interp_uid)
    HEAD ic.component_assay_uid
     interpcompassaycnt = (interpcompassaycnt+ 1), stat = alterlist(interpcomponentassays->assays,
      interpcompassaycnt), interpcomponentassays->assays[interpcompassaycnt].task_assay_uid = ic
     .component_assay_uid
    WITH nocounter
   ;end select
   FOR (interpassayidx = 1 TO interpcompassaycnt)
     FOR (assayidx = 1 TO assaycnt)
       IF ((interpcomponentassays->assays[interpassayidx].task_assay_uid=assaysinform->assays[
       assayidx].task_assay_uid))
        SET assaynotavailableinform = false
        SET assayidx = assaycnt
       ENDIF
     ENDFOR
     IF (assaynotavailableinform)
      SET interpassayidx = interpcompassaycnt
      CALL logdebuginfo(build2("Interp Comp assay is not not available in Form:",
        interpcomponentassays->assays[interpassayidx].task_assay_uid))
      RETURN(false)
     ENDIF
     SET assaynotavailableinform = true
   ENDFOR
   CALL logdebuginfo("All the Interp Comp assays are available in Form.")
   CALL bedlogmessage("areAllInterpAssaysAvailableInForm","Exiting ...")
   RETURN(true)
 END ;Subroutine
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 DECLARE modified_section = vc WITH protect, constant("S")
 DECLARE modified_input = vc WITH protect, constant("I")
 DECLARE modified_assay = vc WITH protect, constant("A")
 DECLARE logfileind = i2 WITH protect, noconstant(0)
 DECLARE logfilename = vc WITH protect, noconstant("")
 DECLARE getsectionidbysectionuid(sectionuid=vc) = f8
 DECLARE gettaskassaycdforuid(taskassayuid=vc) = f8
 DECLARE logdebuginfo(desc=vc) = i2
 DECLARE isinputmodified(getimportedinputsreply=vc(ref),getexistinginputsreply=vc(ref),returnind=i2)
  = i2
 DECLARE geteventcdforuid(eventuid=vc) = f8
 DECLARE isassaymodified(taskassayuid=vc,formuid=vc) = i2
 DECLARE compareintersectingeventcodes(idx=i4,getimportedinputsreply=vc(ref)) = i2
 DECLARE openlogfile(outputfilename=vc) = i2
 DECLARE writelogstothefile(outputfilename=vc,ccllogind=i2) = i2
 DECLARE writeiviewlogstothefile(outputfilename=vc,ccllogind=i2) = i2
 DECLARE closelogfile(dummyvar=i2) = i2
 DECLARE bedaddlogstologgerfile(logmessage=vc) = null
 DECLARE findpowerformorsectionnameofassay(assayuid=vc) = vc
 FREE RECORD assaysinform
 RECORD assaysinform(
   1 assays[*]
     2 task_assay_uid = vc
 )
 IF ( NOT (validate(logger,0)))
  RECORD logger(
    1 logs[*]
      2 texttobewritten = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec,0)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 SUBROUTINE getsectionidbysectionuid(sectionuid)
   CALL bedlogmessage("getSectionIdBySectionUID","Entering ...")
   DECLARE sectionid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnt_section_key2 sk
    WHERE sk.section_uid=sectionuid
    DETAIL
     sectionid = sk.dcp_section_ref_id
    WITH nocounter
   ;end select
   IF (sectionid=0)
    SELECT INTO "nl:"
     FROM cnt_section_key2 sk,
      dcp_section_ref r
     PLAN (sk
      WHERE sk.section_uid=sectionuid)
      JOIN (r
      WHERE r.definition=sk.section_definition
       AND r.active_ind=true)
     DETAIL
      sectionid = r.dcp_section_ref_id
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("sectionId:",sectionid))
   CALL bedlogmessage("getSectionIdBySectionUID","Exiting ...")
   RETURN(sectionid)
 END ;Subroutine
 SUBROUTINE gettaskassaycdforuid(taskassayuid)
   CALL bedlogmessage("getTaskAssayCdForUID","Entering ...")
   DECLARE taskassaycd = f8 WITH protect, noconstant(0)
   DECLARE mnemonic = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM cnt_dta_key2 dk,
     cnt_dta d
    PLAN (dk
     WHERE dk.task_assay_uid=taskassayuid)
     JOIN (d
     WHERE d.task_assay_uid=dk.task_assay_uid)
    DETAIL
     taskassaycd = dk.task_assay_cd, mnemonic = d.mnemonic
    WITH nocounter
   ;end select
   IF (taskassaycd=0)
    SELECT INTO "nl:"
     FROM discrete_task_assay dta
     WHERE dta.mnemonic=mnemonic
     DETAIL
      taskassaycd = dta.task_assay_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("taskAssayCd:",taskassaycd))
   CALL bedlogmessage("getTaskAssayCdForUID","Exiting ...")
   RETURN(taskassaycd)
 END ;Subroutine
 SUBROUTINE logdebuginfo(desc)
   IF (validate(debug,0)=1)
    CALL echo("===============================================")
    CALL echo(desc)
    CALL echo("===============================================")
   ENDIF
 END ;Subroutine
 SUBROUTINE compareintersectingeventcodes(idx,getimportedinputsreply)
   CALL bedlogmessage("compareIntersectingEventCodes","Entering ...")
   DECLARE diffind = i2 WITH protect, noconstant(0)
   DECLARE evcd = i2 WITH protect, noconstant(0)
   IF ((getimportedinputsreply->inputs[idx].cnt_modified_status=modified))
    RETURN(true)
   ENDIF
   IF (size(getimportedinputsreply->inputs[idx].grideventcodes,5) > 0)
    FOR (evcd = 1 TO size(getimportedinputsreply->inputs[idx].grideventcodes,5))
      IF ((getimportedinputsreply->inputs[idx].grideventcodes[evcd].col_task_assay_cd > 0)
       AND (getimportedinputsreply->inputs[idx].grideventcodes[evcd].row_task_assay_cd > 0))
       SELECT INTO "nl:"
        FROM code_value_event_r r
        PLAN (r
         WHERE r.parent_cd=outerjoin(getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          col_task_assay_cd)
          AND r.flex1_cd=outerjoin(getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          row_task_assay_cd)
          AND r.flex2_cd=outerjoin(0)
          AND r.flex3_cd=outerjoin(0)
          AND r.flex4_cd=outerjoin(0)
          AND r.flex5_cd=outerjoin(0))
        DETAIL
         IF ((r.event_cd != getimportedinputsreply->inputs[idx].grideventcodes[evcd].int_event_cd))
          getimportedinputsreply->inputs[idx].grideventcodes[evcd].old_event_cd = r.event_cd,
          getimportedinputsreply->inputs[idx].grideventcodes[evcd].old_event_display =
          uar_get_code_display(r.event_cd), getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          event_modified_status = modified,
          diffind = true
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET getimportedinputsreply->inputs[idx].grideventcodes[evcd].event_modified_status = modified
        SET diffind = true
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(diffind)
   CALL bedlogmessage("compareIntersectingEventCodes","Exiting ...")
 END ;Subroutine
 SUBROUTINE isinputmodified(getimportedinputsreply,getexistinginputsreply,returnind)
   CALL bedlogmessage("isInputModified","Entering ...")
   DECLARE importedinputsize = i4 WITH protect, constant(size(getimportedinputsreply->inputs,5))
   DECLARE existinginputsize = i4 WITH protect, constant(size(getexistinginputsreply->inputs,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE preffoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   DECLARE existprefcnt = i4 WITH protect, noconstant(0)
   DECLARE epcnt = i4 WITH protect, noconstant(0)
   FOR (eidx = 1 TO existinginputsize)
     SET num = 1
     SET foundidx = locateval(num,1,importedinputsize,getexistinginputsreply->inputs[eidx].
      input_ref_id,getimportedinputsreply->inputs[num].dcp_input_ref_id)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,importedinputsize,getexistinginputsreply->inputs[eidx].
       input_ref_seq,getimportedinputsreply->inputs[num].input_ref_seq,
       getexistinginputsreply->inputs[eidx].input_type,getimportedinputsreply->inputs[num].input_type,
       getexistinginputsreply->inputs[eidx].module,getimportedinputsreply->inputs[num].module)
     ENDIF
     CALL logdebuginfo(build2("Evaluating at position(existing): ",getexistinginputsreply->inputs[
       eidx].input_ref_seq," --Input type(existing):",getexistinginputsreply->inputs[eidx].input_type
       ))
     CALL logdebuginfo(build2("Found match:",foundidx))
     IF (foundidx > 0)
      IF ((getimportedinputsreply->inputs[foundidx].dcp_input_ref_id=0))
       SET getimportedinputsreply->inputs[foundidx].dcp_input_ref_id = getexistinginputsreply->
       inputs[foundidx].input_ref_id
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].input_type=19)
       AND (getexistinginputsreply->inputs[eidx].input_type=19))
       IF (compareintersectingeventcodes(foundidx,getimportedinputsreply))
        SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
        IF (returnind)
         RETURN(true)
        ENDIF
       ENDIF
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].input_ref_seq != getexistinginputsreply->inputs[
      eidx].input_ref_seq))
       CALL logdebuginfo(build2("input_ref_seq: ",getimportedinputsreply->inputs[foundidx].
         input_ref_seq,"::",getexistinginputsreply->inputs[eidx].input_ref_seq))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].description != getexistinginputsreply->
      inputs[eidx].description))
       CALL logdebuginfo(build2("description: ",getimportedinputsreply->inputs[foundidx].description,
         "::",getexistinginputsreply->inputs[eidx].description))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].input_type != getexistinginputsreply->inputs[
      eidx].input_type))
       CALL logdebuginfo(build2("input_type: ",getimportedinputsreply->inputs[foundidx].input_type,
         "::",getexistinginputsreply->inputs[eidx].input_type))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].module != getexistinginputsreply->inputs[eidx
      ].module))
       CALL logdebuginfo(build2("module: ",getimportedinputsreply->inputs[foundidx].module,"::",
         getexistinginputsreply->inputs[eidx].module))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF (size(getimportedinputsreply->inputs[foundidx].preferences,5) != size(
       getexistinginputsreply->inputs[eidx].preferences,5))
       CALL logdebuginfo(build2("preference:size: ",size(getimportedinputsreply->inputs[foundidx].
          preferences,5),"::",size(getexistinginputsreply->inputs[eidx].preferences,5)))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].cnt_modified_status != modified))
       FOR (prefidx = 1 TO size(getimportedinputsreply->inputs[foundidx].preferences,5))
         CALL logdebuginfo(build2("Evaluating preference at index: ",prefidx))
         SET num1 = 1
         SET preffoundidx = locateval(num1,1,size(getexistinginputsreply->inputs[eidx].preferences,5),
          getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id,
          getexistinginputsreply->inputs[eidx].preferences[num1].id)
         IF (preffoundidx=0)
          SET num1 = 1
          SET preffoundidx = locateval(num1,1,size(getexistinginputsreply->inputs[eidx].preferences,5
            ),getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_name,
           getexistinginputsreply->inputs[eidx].preferences[num1].pvc_name,
           getimportedinputsreply->inputs[foundidx].preferences[prefidx].sequence,
           getexistinginputsreply->inputs[eidx].preferences[num1].sequence)
         ENDIF
         IF (preffoundidx=0)
          CALL logdebuginfo(build2("Preference did not find a match in millennium for ",
            getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_name))
          SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
          IF (returnind)
           RETURN(true)
          ENDIF
         ELSE
          IF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id=0))
           SET getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id =
           getexistinginputsreply->inputs[eidx].preferences[preffoundidx].id
          ENDIF
          IF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_value !=
          getexistinginputsreply->inputs[eidx].preferences[preffoundidx].pvc_value))
           CALL logdebuginfo(build2("preference:pvc_value: ",getimportedinputsreply->inputs[foundidx]
             .preferences[prefidx].pvc_value,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].pvc_value))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ELSEIF (trim(getimportedinputsreply->inputs[foundidx].preferences[prefidx].merge_name,7)
           != trim(getexistinginputsreply->inputs[eidx].preferences[preffoundidx].merge_name,7))
           CALL logdebuginfo(build2("preference:merge_name: ",getimportedinputsreply->inputs[foundidx
             ].preferences[prefidx].merge_name,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].merge_name))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ELSEIF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].merge_id !=
          getexistinginputsreply->inputs[eidx].preferences[preffoundidx].merge_id))
           CALL logdebuginfo(build2("preference:merge_id: ",getimportedinputsreply->inputs[foundidx].
             preferences[prefidx].merge_id,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].merge_id))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].cnt_modified_status=""))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = none
      ENDIF
     ELSE
      SET icnt = (size(getimportedinputsreply->inputs,5)+ 1)
      SET stat = alterlist(getimportedinputsreply->inputs,icnt)
      SET getimportedinputsreply->inputs[icnt].description = getexistinginputsreply->inputs[eidx].
      description
      SET getimportedinputsreply->inputs[icnt].input_ref_seq = getexistinginputsreply->inputs[eidx].
      input_ref_seq
      SET getimportedinputsreply->inputs[icnt].input_type = getexistinginputsreply->inputs[eidx].
      input_type
      SET getimportedinputsreply->inputs[icnt].module = getexistinginputsreply->inputs[eidx].module
      SET getimportedinputsreply->inputs[icnt].cnt_modified_status = removed
      SET getimportedinputsreply->inputs[icnt].dcp_input_ref_id = getexistinginputsreply->inputs[eidx
      ].input_ref_id
      SET getimportedinputsreply->inputs[icnt].cnt_input_key_id = getexistinginputsreply->inputs[eidx
      ].input_ref_id
      SET existprefcnt = size(getexistinginputsreply->inputs[eidx].preferences,5)
      SET stat = alterlist(getimportedinputsreply->inputs[icnt].preferences,existprefcnt)
      FOR (epcnt = 1 TO existprefcnt)
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].name_value_prefs_id =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].id
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].pvc_name = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].pvc_name
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].pvc_value =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].pvc_value
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_name =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].merge_name
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_id = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].merge_id
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].sequence = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].sequence
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_display =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].merge_display
      ENDFOR
      IF (returnind)
       RETURN(true)
      ENDIF
     ENDIF
   ENDFOR
   FOR (iidx = 1 TO size(getimportedinputsreply->inputs,5))
     IF ((getimportedinputsreply->inputs[iidx].cnt_modified_status=""))
      SET getimportedinputsreply->inputs[iidx].cnt_modified_status = added
     ENDIF
   ENDFOR
   CALL bedlogmessage("isInputModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE geteventcdforuid(eventuid)
   CALL bedlogmessage("getEventCdForUID","Entering ...")
   DECLARE eventcd = f8 WITH protect, noconstant(0)
   DECLARE eventdesc = vc WITH protect, noconstant("")
   DECLARE eventdisp = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM cnt_code_value_key k
    WHERE k.code_value_uid=eventuid
    DETAIL
     eventcd = k.code_value, eventdesc = k.description, eventdisp = k.display
    WITH nocounter
   ;end select
   IF (eventcd=0)
    SELECT INTO "nl:"
     FROM v500_event_code ec
     WHERE ec.event_cd_disp=eventdisp
     DETAIL
      eventcd = ec.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("eventCd:",eventcd))
   CALL bedlogmessage("getEventCdForUID","Exiting ...")
   RETURN(eventcd)
 END ;Subroutine
 SUBROUTINE isassaymodified(taskassayuid,formuid)
   CALL bedlogmessage("isAssayModified","Entering ...")
   FREE RECORD assayrequest
   RECORD assayrequest(
     1 assays[*]
       2 task_assay_uid = vc
       2 bailoutind = i2
     1 get_interps_ind = i2
     1 form_uid = vc
   )
   IF ( NOT (validate(assayreply,0)))
    RECORD assayreply(
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
    ) WITH protect
   ENDIF
   SET stat = alterlist(assayrequest->assays,1)
   SET assayrequest->assays[1].task_assay_uid = taskassayuid
   SET assayrequest->assays[1].bailoutind = 1
   SET assayrequest->get_interps_ind = 1
   SET assayrequest->form_uid = formuid
   EXECUTE bed_get_pwrform_cern_assays  WITH replace("REQUEST",assayrequest), replace("REPLY",
    assayreply)
   IF ((assayreply->status_data.status != "S"))
    CALL bederror(build("bed_get_pwrform_cern_assays did not return success for assay: ",taskassayuid
      ))
   ENDIF
   IF (size(assayreply->assays,5)=1)
    IF ((assayreply->assays[1].modified_status != none))
     CALL logdebuginfo(build2("The assay is modified: ",taskassayuid))
     RETURN(true)
    ENDIF
   ELSE
    CALL logdebuginfo(build2("Invalid reply returned for the assay: ",taskassayuid))
   ENDIF
   FREE RECORD assayreply
   CALL bedlogmessage("isAssayModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE bedaddlogstologgerfile(logmessage)
   DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
   SET stat = alterlist(logger->logs,(logcnt+ 1))
   SET logger->logs[(logcnt+ 1)].texttobewritten = logmessage
 END ;Subroutine
 SUBROUTINE openlogfile(outputfilename,ispowerform)
   CALL bedlogmessage("openLogFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering openLogFile ...")
   CALL bedaddlogstologgerfile(build2("### outputFileName:",outputfilename))
   CALL bedaddlogstologgerfile(build2("### isPowerForm:",ispowerform))
   DECLARE filenameprefix = vc WITH protect, noconstant("")
   IF (logfileind)
    IF (ispowerform)
     SET filenameprefix = "bed_pf_"
    ELSE
     SET filenameprefix = "bed_iview_"
    ENDIF
    CALL bedaddlogstologgerfile(build2("### fileNamePrefix:",filenameprefix))
    DECLARE curdatetime = vc WITH protect, noconstant(format(cnvtdatetime(curdate,curtime3),
      "YYYYMMDDHH;;Q"))
    SET frec->file_name = build(filenameprefix,outputfilename,build("_",curdatetime),".log")
    SET frec->file_buf = "a"
    CALL bedaddlogstologgerfile(build2(curprog," : ","frec->file_name:",frec->file_name))
    SET stat = cclio("OPEN",frec)
   ENDIF
   CALL bedlogmessage("openLogFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting openLogFile ...")
 END ;Subroutine
 SUBROUTINE writelogstothefile(outputfilename,ccllogind)
   CALL bedlogmessage("writeLogsToTheFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering writeLogsToTheFile ...")
   SET logfileind = ccllogind
   CALL openlogfile(trim(outputfilename,4),true)
   IF (logfileind)
    DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
    CALL bedaddlogstologgerfile(build2(curprog," : ","Number of Logs:",logcnt))
    FOR (x = 1 TO logcnt)
      SET frec->file_buf = build(frec->file_buf,char(10),logger->logs[x].texttobewritten)
    ENDFOR
    SET stat = cclio("WRITE",frec)
    SET stat = initrec(logger)
   ENDIF
   CALL closelogfile(logfileind)
   CALL bedlogmessage("writeLogsToTheFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting writeLogsToTheFile ...")
 END ;Subroutine
 SUBROUTINE writeiviewlogstothefile(outputfilename,ccllogind)
   CALL bedlogmessage("writeIViewLogsToTheFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering writeIViewLogsToTheFile ...")
   SET logfileind = ccllogind
   CALL openlogfile(trim(outputfilename,4),false)
   IF (logfileind)
    DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
    CALL bedaddlogstologgerfile(build2(curprog," : ","Number of Logs:",logcnt))
    FOR (x = 1 TO logcnt)
      SET frec->file_buf = build(frec->file_buf,char(10),logger->logs[x].texttobewritten)
    ENDFOR
    SET stat = cclio("WRITE",frec)
    SET stat = initrec(logger)
   ENDIF
   CALL closelogfile(logfileind)
   CALL bedlogmessage("writeIViewLogsToTheFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting writeIViewLogsToTheFile ...")
 END ;Subroutine
 SUBROUTINE closelogfile(dummyvar)
   CALL bedlogmessage("closeLogFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering closeLogFile ...")
   IF (logfileind)
    SET stat = cclio("CLOSE",frec)
   ENDIF
   CALL bedlogmessage("closeLogFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting closeLogFile ...")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE populateformdetails(dummyvar=i2) = i2
 DECLARE populatecontentsections(dummyvar=i2) = i2
 DECLARE savenewsections(dummyvar=i2) = i2
 DECLARE updatesectioncontrols(dummyvar=i2) = i2
 DECLARE getcontentsections(dummyvar=i2) = i2
 DECLARE savesectioninputs(sectionuid=vc,sectionid=f8) = i2
 DECLARE updateassays(dummyvar=i2) = i2
 DECLARE getinputsforsection(sectionuid=vc) = i2
 DECLARE loadassays(assayrequest=vc(ref)) = i2
 DECLARE saveassays(sectionuid=vc) = i2
 DECLARE reconcileassays(dummyvar=i2) = i2
 DECLARE loadexistingassay(assaycd=f8) = i2
 DECLARE compareassay(iaidx=i4) = i2
 DECLARE compareequation(ai=i4) = i2
 DECLARE logdebuginfo(desc) = i2
 CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_CONTENT_FORM.PRG ####")
 CALL bedaddlogstologgerfile(cnvtrectoxml(request))
 CALL populateformdetails(0)
 CALL populatecontentsections(0)
 CALL bedaddlogstologgerfile(cnvtrectoxml(ensnewsectionsrequest))
 CALL savenewsections(0)
 CALL updatesectioncontrols(0)
 CALL updateassays(0)
 IF (validate(request->cclloggingind))
  CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
  CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_CONTENT_FORM.PRG ####")
  CALL writelogstothefile(ensnewsectionsrequest->definition,request->cclloggingind)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE populateformdetails(dummyvar)
   CALL bedlogmessage("populateFormDetails ","Entering ...")
   CALL bedaddlogstologgerfile("#### Entering populateFormDetails...")
   SET ensnewsectionsrequest->dcp_form_ref_id = request->formid
   SET ensnewsectionsrequest->form_uid = request->formuid
   SET ensnewsectionsrequest->definition = request->definition
   SET ensnewsectionsrequest->description = request->description
   IF (validate(request->cclloggingind))
    SET ensnewsectionsrequest->ccl_logging_ind = request->cclloggingind
   ENDIF
   SELECT INTO "nl:"
    FROM cnt_powerform p,
     cnt_pf_key2 pk,
     cnt_code_value_key cv1,
     cnt_code_value_key cv2
    PLAN (p
     WHERE (p.form_uid=request->formuid)
      AND p.active_ind=true)
     JOIN (pk
     WHERE pk.form_uid=p.form_uid)
     JOIN (cv1
     WHERE cv1.code_value_uid=outerjoin(p.form_event_cduid))
     JOIN (cv2
     WHERE cv2.code_value_uid=outerjoin(p.text_rendition_event_cduid))
    DETAIL
     IF (((p.form_flag=1) OR (((p.form_flag=3) OR ((request->enforce_required_ind=1))) )) )
      ensnewsectionsrequest->enforce_required_ind = 1
     ELSE
      ensnewsectionsrequest->enforce_required_ind = 0
     ENDIF
     IF (((p.form_flag=2) OR (((p.form_flag=3) OR ((request->done_charting_ind=1))) )) )
      ensnewsectionsrequest->done_charting_ind = 1
     ELSE
      ensnewsectionsrequest->done_charting_ind = 0
     ENDIF
     IF ((request->event_cd > 0))
      ensnewsectionsrequest->event_cd = request->event_cd
     ELSEIF (p.form_event_cd > 0)
      ensnewsectionsrequest->event_cd = p.form_event_cd
     ELSE
      ensnewsectionsrequest->event_cd = cv1.code_value
     ENDIF
     IF ((request->text_rendition_event_cd > 0))
      ensnewsectionsrequest->text_rendition_event_cd = request->text_rendition_event_cd
     ELSEIF (p.text_rendition_event_cd > 0)
      ensnewsectionsrequest->text_rendition_event_cd = p.text_rendition_event_cd
     ELSE
      ensnewsectionsrequest->text_rendition_event_cd = cv2.code_value
     ENDIF
    WITH nocounter
   ;end select
   CALL bedlogmessage("populateFormDetails ","Exiting ...")
   CALL bedaddlogstologgerfile("#### Exiting populateFormDetails...")
 END ;Subroutine
 SUBROUTINE getcontentsections(dummyvar)
   CALL bedlogmessage("getContentSections ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering getContentSections ...")
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
   CALL bedaddlogstologgerfile("### Exiting getContentSections ...")
 END ;Subroutine
 SUBROUTINE populatecontentsections(dummyvar)
   CALL bedlogmessage("populateContentSections ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering populateContentSections ...")
   DECLARE scnt = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE mcnt = i4 WITH protect, noconstant(0)
   CALL getcontentsections(0)
   FOR (scnt = 1 TO size(getcontentsectionsreply->sections,5))
     IF ((getcontentsectionsreply->sections[scnt].modified_status=added))
      SET acnt = (acnt+ 1)
      SET stat = alterlist(ensnewsectionsrequest->addsections,acnt)
      SET ensnewsectionsrequest->addsections[acnt].section_uid = getcontentsectionsreply->sections[
      scnt].section_uid
      SET ensnewsectionsrequest->addsections[acnt].sequence = getcontentsectionsreply->sections[scnt]
      .sequence
      SET ensnewsectionsrequest->addsections[acnt].conditional_flag = getcontentsectionsreply->
      sections[scnt].conditional_section_ind
      SET ensnewsectionsrequest->addsections[acnt].description = getcontentsectionsreply->sections[
      scnt].name
      SET ensnewsectionsrequest->addsections[acnt].definition = getcontentsectionsreply->sections[
      scnt].description
      SET ensnewsectionsrequest->addsections[acnt].ignore_ind = 0
     ELSEIF ((getcontentsectionsreply->sections[scnt].modified_status IN (modified, none)))
      SET mcnt = (mcnt+ 1)
      SET stat = alterlist(ensnewsectionsrequest->updatesections,mcnt)
      SET ensnewsectionsrequest->updatesections[mcnt].conditional_flag = getcontentsectionsreply->
      sections[scnt].conditional_section_ind
      SET ensnewsectionsrequest->updatesections[mcnt].dcp_section_ref_id = getcontentsectionsreply->
      sections[scnt].dcp_section_ref_id
      SET ensnewsectionsrequest->updatesections[mcnt].ignore_ind = getcontentsectionsreply->sections[
      scnt].ignore_ind
      SET ensnewsectionsrequest->updatesections[mcnt].section_uid = getcontentsectionsreply->
      sections[scnt].section_uid
      SET ensnewsectionsrequest->updatesections[mcnt].sequence = getcontentsectionsreply->sections[
      scnt].sequence
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateContentSections ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting populateContentSections ...")
 END ;Subroutine
 SUBROUTINE savenewsections(dummyvar)
   CALL bedlogmessage("saveNewSections ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering saveNewSections ...")
   FREE RECORD ensnewsectionsreply
   RECORD ensnewsectionsreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF (validate(debug,0)=1)
    CALL echorecord(ensnewsectionsrequest)
   ENDIF
   EXECUTE bed_ens_pwrform_sections  WITH replace("REQUEST",ensnewsectionsrequest), replace("REPLY",
    ensnewsectionsreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensnewsectionsreply))
   IF ((ensnewsectionsreply->status_data.status != "S"))
    CALL bederror("bed_ens_pwrform_sections failed.")
   ENDIF
   CALL bedlogmessage("saveNewSections ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting saveNewSections ...")
 END ;Subroutine
 SUBROUTINE updatesectioncontrols(dummyvar)
   CALL bedlogmessage("updateSectionControls ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateSectionControls ...")
   DECLARE scnt = i4 WITH protect, noconstant(0)
   CALL getcontentsections(0)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getcontentsectionsreply))
   FOR (scnt = 1 TO size(getcontentsectionsreply->sections,5))
     IF ((getcontentsectionsreply->sections[scnt].modified_status=modified))
      IF ((getcontentsectionsreply->sections[scnt].modified_status_level IN ("S", "I")))
       CALL savesectioninputs(getcontentsectionsreply->sections[scnt].section_uid,
        getcontentsectionsreply->sections[scnt].dcp_section_ref_id)
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("updateSectionControls ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateSectionControls ...")
 END ;Subroutine
 SUBROUTINE savesectioninputs(sectionuid,sectionid)
   CALL bedlogmessage("saveSectionInputs ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering saveSectionInputs ...")
   CALL bedaddlogstologgerfile(build2("### Inside saveSectionInputs - Section UID:",sectionuid))
   CALL bedaddlogstologgerfile(build2("### Inside saveSectionInputs - Section ID:",sectionid))
   FREE RECORD recsectionrequest
   RECORD recsectionrequest(
     1 dcp_section_ref_id = f8
     1 description = vc
     1 definition = vc
     1 input_list[*]
       2 cnt_input_key_id = f8
       2 description = vc
       2 module = vc
       2 input_ref_seq = i4
       2 input_type = i4
       2 nv[*]
         3 cnt_input_id = f8
         3 pvc_name = vc
         3 pvc_value = vc
         3 merge_name = vc
         3 merge_id = f8
         3 merge_uid = vc
         3 sequence = i4
       2 grideventcodes[*]
         3 row_assay_cd = f8
         3 col_assay_cd = f8
         3 event_cd = f8
         3 event_cduid = vc
     1 dcp_forms_ref_id = f8
     1 conditionalsections[*]
       2 dcpsectionrefid = f8
       2 actionflag = i2
     1 cclloggingind = i2
   )
   FREE RECORD recsectionreply
   RECORD recsectionreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET recsectionrequest->dcp_forms_ref_id = request->formid
   IF (validate(request->cclloggingind))
    SET recsectionrequest->cclloggingind = request->cclloggingind
   ENDIF
   SELECT INTO "nl:"
    FROM dcp_section_ref r
    WHERE r.dcp_section_ref_id=sectionid
     AND r.active_ind=true
    DETAIL
     recsectionrequest->dcp_section_ref_id = sectionid, recsectionrequest->definition = r.definition
    WITH nocounter
   ;end select
   IF ((((recsectionrequest->dcp_section_ref_id=0)) OR ((recsectionrequest->definition=""))) )
    CALL bederror(build2("Error finding dcp_section_ref:",sectionid))
   ENDIF
   SELECT INTO "nl:"
    FROM cnt_section_key2 k
    WHERE k.section_uid=sectionuid
    DETAIL
     recsectionrequest->description = k.section_description
    WITH nocounter
   ;end select
   CALL getinputsforsection(sectionuid)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getinputsreply))
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   DECLARE evcnt = i4 WITH protect, noconstant(0)
   DECLARE revcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(recsectionrequest->input_list,size(getinputsreply->inputs,5))
   FOR (icnt = 1 TO size(getinputsreply->inputs,5))
     SET recsectionrequest->input_list[icnt].cnt_input_key_id = getinputsreply->inputs[icnt].
     cnt_input_key_id
     SET recsectionrequest->input_list[icnt].description = getinputsreply->inputs[icnt].description
     SET recsectionrequest->input_list[icnt].input_ref_seq = getinputsreply->inputs[icnt].
     input_ref_seq
     SET recsectionrequest->input_list[icnt].input_type = getinputsreply->inputs[icnt].input_type
     SET recsectionrequest->input_list[icnt].module = getinputsreply->inputs[icnt].module
     SET stat = alterlist(recsectionrequest->input_list[icnt].nv,size(getinputsreply->inputs[icnt].
       preferences,5))
     FOR (pcnt = 1 TO size(getinputsreply->inputs[icnt].preferences,5))
       SET recsectionrequest->input_list[icnt].nv[pcnt].cnt_input_id = getinputsreply->inputs[icnt].
       preferences[pcnt].cnt_input_id
       SET recsectionrequest->input_list[icnt].nv[pcnt].merge_id = getinputsreply->inputs[icnt].
       preferences[pcnt].merge_id
       SET recsectionrequest->input_list[icnt].nv[pcnt].merge_name = getinputsreply->inputs[icnt].
       preferences[pcnt].merge_name
       SET recsectionrequest->input_list[icnt].nv[pcnt].merge_uid = getinputsreply->inputs[icnt].
       preferences[pcnt].content_merge_uid
       SET recsectionrequest->input_list[icnt].nv[pcnt].pvc_name = getinputsreply->inputs[icnt].
       preferences[pcnt].pvc_name
       SET recsectionrequest->input_list[icnt].nv[pcnt].pvc_value = getinputsreply->inputs[icnt].
       preferences[pcnt].pvc_value
       SET recsectionrequest->input_list[icnt].nv[pcnt].sequence = getinputsreply->inputs[icnt].
       preferences[pcnt].sequence
     ENDFOR
     IF (size(getinputsreply->inputs[icnt].grideventcodes,5) > 0)
      SET revcnt = 0
      FOR (evcnt = 1 TO size(getinputsreply->inputs[icnt].grideventcodes,5))
        IF ((getinputsreply->inputs[icnt].grideventcodes[evcnt].event_modified_status != none)
         AND (getinputsreply->inputs[icnt].grideventcodes[evcnt].col_task_assay_cd > 0)
         AND (getinputsreply->inputs[icnt].grideventcodes[evcnt].row_task_assay_cd > 0))
         SET revcnt = (revcnt+ 1)
         SET stat = alterlist(recsectionrequest->input_list[icnt].grideventcodes,revcnt)
         SET recsectionrequest->input_list[icnt].grideventcodes[revcnt].col_assay_cd = getinputsreply
         ->inputs[icnt].grideventcodes[evcnt].col_task_assay_cd
         SET recsectionrequest->input_list[icnt].grideventcodes[revcnt].event_cd = getinputsreply->
         inputs[icnt].grideventcodes[evcnt].int_event_cd
         SET recsectionrequest->input_list[icnt].grideventcodes[revcnt].event_cduid = getinputsreply
         ->inputs[icnt].grideventcodes[evcnt].int_event_cduid
         SET recsectionrequest->input_list[icnt].grideventcodes[revcnt].row_assay_cd = getinputsreply
         ->inputs[icnt].grideventcodes[evcnt].row_task_assay_cd
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(recsectionrequest)
   ENDIF
   CALL bedaddlogstologgerfile(cnvtrectoxml(recsectionrequest))
   EXECUTE bed_ens_pwrfrm_rec_sections  WITH replace("REQUEST",recsectionrequest), replace("REPLY",
    recsectionreply)
   IF ((recsectionreply->status_data.status != "S"))
    CALL bederror("bed_ens_pwrfrm_rec_sections failed.")
   ENDIF
   CALL bedlogmessage("saveSectionInputs ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting saveSectionInputs ...")
 END ;Subroutine
 SUBROUTINE getinputsforsection(sectionuid)
   CALL bedlogmessage("getInputsForSection ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering getInputsForSection ...")
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
   CALL bedaddlogstologgerfile("### Exiting getInputsForSection ...")
 END ;Subroutine
 SUBROUTINE updateassays(dummyvar)
   CALL bedlogmessage("updateAssays ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateAssays ...")
   DECLARE ssscnt = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   CALL getcontentsections(0)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getcontentsectionsreply))
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
   FOR (ssscnt = 1 TO size(getcontentsectionsreply->sections,5))
     IF ((getcontentsectionsreply->sections[ssscnt].modified_status=modified))
      SET acnt = 0
      SET stat = initrec(getassaysrequest)
      CALL getinputsforsection(getcontentsectionsreply->sections[ssscnt].section_uid)
      CALL bedaddlogstologgerfile(build2("### Inside updateAssays - Section UID:",
        getcontentsectionsreply->sections[ssscnt].section_uid))
      CALL bedaddlogstologgerfile(cnvtrectoxml(getinputsreply))
      FOR (icnt = 1 TO size(getinputsreply->inputs,5))
        FOR (pcnt = 1 TO size(getinputsreply->inputs[icnt].preferences,5))
          IF ((getinputsreply->inputs[icnt].preferences[pcnt].merge_name="DISCRETE_TASK_ASSAY*"))
           SET acnt = (acnt+ 1)
           SET stat = alterlist(getassaysrequest->assays,acnt)
           SET getassaysrequest->assays[acnt].task_assay_uid = getinputsreply->inputs[icnt].
           preferences[pcnt].content_merge_uid
          ENDIF
        ENDFOR
      ENDFOR
      SET getassaysrequest->get_interps_ind = 1
      SET getassaysrequest->form_uid = request->formuid
      CALL loadassays(getassaysrequest)
      CALL saveassays(getcontentsectionsreply->sections[ssscnt].section_uid)
      CALL loadassays(getassaysrequest)
      CALL reconcileassays(0)
     ENDIF
   ENDFOR
   CALL bedlogmessage("updateAssays ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateAssays ...")
 END ;Subroutine
 SUBROUTINE loadassays(assayrequest)
   CALL bedlogmessage("loadAssays ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering loadAssays ...")
   SET stat = initrec(getassaysreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(assayrequest))
   EXECUTE bed_get_pwrform_cern_assays  WITH replace("REQUEST",assayrequest), replace("REPLY",
    getassaysreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getassaysreply))
   IF ((getassaysreply->status_data.status != "S"))
    CALL bederror("bed_get_pwrform_cern_assays failed.")
   ENDIF
   CALL bedlogmessage("loadAssays ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting loadAssays ...")
 END ;Subroutine
 SUBROUTINE saveassays(sectionuid)
   CALL bedlogmessage("saveAssays ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering saveAssays ...")
   DECLARE aidx1 = i4 WITH protect, noconstant(0)
   FREE RECORD ensassaysrequest
   RECORD ensassaysrequest(
     1 section_uid = vc
     1 assays[*]
       2 assay_action_flag = i2
       2 task_assay_uid = vc
       2 task_assay_cd = f8
       2 description = vc
       2 save_interps = i2
     1 content_match_ind = i2
     1 powerformorsectionname = vc
     1 cclloggingind = i2
   )
   FREE RECORD ensassaysreply
   RECORD ensassaysreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET ensassaysrequest->section_uid = sectionuid
   SET ensassaysrequest->content_match_ind = 0
   IF (validate(request->cclloggingind))
    SET ensassaysrequest->powerformorsectionname = ensnewsectionsrequest->definition
    SET ensassaysrequest->cclloggingind = request->cclloggingind
   ENDIF
   SET stat = alterlist(ensassaysrequest->assays,size(getassaysreply->assays,5))
   FOR (aidx1 = 1 TO size(getassaysreply->assays,5))
    IF ((getassaysreply->assays[aidx1].modified_status=added))
     SET ensassaysrequest->assays[aidx1].assay_action_flag = 1
     SET ensassaysrequest->assays[aidx1].task_assay_uid = getassaysreply->assays[aidx1].
     task_assay_uid
    ELSE
     SET ensassaysrequest->assays[aidx1].assay_action_flag = 0
     SET ensassaysrequest->assays[aidx1].task_assay_uid = getassaysreply->assays[aidx1].
     task_assay_uid
     SET ensassaysrequest->assays[aidx1].task_assay_cd = getassaysreply->assays[aidx1].
     task_assay_code_value
    ENDIF
    SET ensassaysrequest->assays[aidx1].save_interps = getassaysreply->assays[aidx1].
    has_all_interp_comp_assays
   ENDFOR
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensassaysrequest))
   EXECUTE bed_ens_pwrform_assay  WITH replace("REQUEST",ensassaysrequest), replace("REPLY",
    ensassaysreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensassaysreply))
   IF ((ensassaysreply->status_data.status != "S"))
    CALL bederror("bed_ens_pwrform_assay failed.")
   ENDIF
   CALL bedlogmessage("saveAssays ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting saveAssays ...")
 END ;Subroutine
 SUBROUTINE reconcileassays(dummyvar)
   CALL bedlogmessage("reconcileAssays ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering reconcileAssays ...")
   DECLARE aidx = i4 WITH protect, noconstant(0)
   DECLARE ridx = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(interpimported,0)))
    RECORD interpimported(
      1 interp[*]
        2 sex_cd = f8
        2 age_from_minutes = i4
        2 age_to_minutes = i4
        2 uid = vc
        2 comp[*]
          3 component_assay_cd = f8
          3 sequence = i4
          3 description = vc
          3 flags = i4
          3 mnemonic = vc
        2 state[*]
          3 input_assay_cd = f8
          3 state = i4
          3 flags = i4
          3 numeric_low = f8
          3 numeric_high = f8
          3 aruid = vc
          3 nomenclature_id = f8
          3 resulting_state = i4
          3 resultaruid = vc
          3 result_nomenclature_id = f8
          3 result_value = f8
    )
   ENDIF
   IF ( NOT (validate(interpexisting,0)))
    RECORD interpexisting(
      1 interp[*]
        2 sex_cd = f8
        2 age_from_minutes = i4
        2 age_to_minutes = i4
        2 comp[*]
          3 component_assay_cd = f8
          3 sequence = i4
          3 description = vc
          3 flags = i4
        2 state[*]
          3 input_assay_cd = f8
          3 state = i4
          3 flags = i4
          3 numeric_low = f8
          3 numeric_high = f8
          3 nomenclature_id = f8
          3 resulting_state = i4
          3 result_nomenclature_id = f8
          3 result_value = f8
    )
   ENDIF
   FREE RECORD reconcileassayreply
   RECORD reconcileassayreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FOR (aidx = 1 TO size(getassaysreply->assays,5))
     IF ((getassaysreply->assays[aidx].modified_status=modified))
      CALL loadexistingassay(getassaysreply->assays[aidx].task_assay_code_value)
      SET stat = initrec(reconcileassayrequest)
      SET stat = initrec(reconcileassayreply)
      SET stat = alterlist(reconcileassayrequest->assays,1)
      SET reconcileassayrequest->assays[1].taskassayuid = getassaysreply->assays[aidx].task_assay_uid
      SET reconcileassayrequest->assays[1].taskassaycd = getassaysreply->assays[aidx].
      task_assay_code_value
      SET reconcileassayrequest->assays[1].resulttypecd = getassaysreply->assays[aidx].result_type.
      code_value
      SET reconcileassayrequest->assays[1].display = getassaysreply->assays[aidx].mnemonic
      SET reconcileassayrequest->assays[1].description = getassaysreply->assays[aidx].description
      SET reconcileassayrequest->assays[1].conceptcki = getassaysreply->assays[aidx].concept_cki
      SET reconcileassayrequest->assays[1].witnessrequiredind = getassaysreply->assays[aidx].
      witness_required_ind
      SET reconcileassayrequest->assays[1].singleselectind = getassaysreply->assays[aidx].
      single_select_ind
      SET reconcileassayrequest->assays[1].ioflag = getassaysreply->assays[aidx].io_flag
      SET reconcileassayrequest->assays[1].defaulttypeflag = getassaysreply->assays[aidx].
      default_type_flag
      SET reconcileassayrequest->assays[1].referencetextupdateind = getassaysreply->assays[aidx].
      ref_text_modified_ind
      IF (validate(request->cclloggingind))
       SET reconcileassayrequest->ccl_logging_ind = request->cclloggingind
      ENDIF
      SET reconcileassayrequest->powerformoriviewname = ensnewsectionsrequest->definition
      SET reconcileassayrequest->powerformoriviewind = 0
      IF ((getassaysreply->assays[aidx].has_all_interp_comp_assays=true))
       SET reconcileassayrequest->assays[1].interpretationsupdateind = areinterpsdifferent(
        getassaysreply->assays[aidx].task_assay_uid,getassaysreply->assays[aidx].
        task_assay_code_value)
      ENDIF
      CALL compareassay(aidx)
      IF (validate(debug,0)=1)
       CALL echorecord(reconcileassayrequest)
      ENDIF
      CALL bedaddlogstologgerfile(cnvtrectoxml(reconcileassayrequest))
      EXECUTE bed_reconcile_assay  WITH replace("REQUEST",reconcileassayrequest), replace("REPLY",
       reconcileassayreply)
      CALL bedaddlogstologgerfile(cnvtrectoxml(reconcileassayreply))
      IF ((reconcileassayreply->status_data.status != "S"))
       CALL bederror("bed_reconcile_assay failed.")
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("reconcileAssays ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting reconcileAssays ...")
 END ;Subroutine
 SUBROUTINE compareassay(iaidx)
   CALL bedlogmessage("compareAssay ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering compareAssay ...")
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE foundi = i4 WITH protect, noconstant(0)
   DECLARE ocnt = i4 WITH protect, noconstant(0)
   DECLARE rrcnt = i4 WITH protect, noconstant(0)
   DECLARE pprrcnt = i4 WITH protect, noconstant(0)
   DECLARE ar = i4 WITH protect, noconstant(0)
   DECLARE arcnt = i4 WITH protect, noconstant(0)
   DECLARE existrrcnt = i4 WITH protect, noconstant(0)
   FOR (k = 1 TO size(getassaysreply->assays[iaidx].lookback_minutes,5))
     SET num = 1
     SET foundi = locateval(num,1,size(getexistingassayreply->slist[1].assay_list[1].lookback_minutes,
       5),getassaysreply->assays[iaidx].lookback_minutes[k].type_code_value,getexistingassayreply->
      slist[1].assay_list[1].lookback_minutes[num].type_code_value)
     IF (((foundi > 0
      AND (getassaysreply->assays[iaidx].lookback_minutes[k].minutes_nbr != getexistingassayreply->
     slist[1].assay_list[1].lookback_minutes[foundi].minutes_nbr)) OR (foundi=0)) )
      SET ocnt = (ocnt+ 1)
      SET stat = alterlist(reconcileassayrequest->assays[1].offsetminutes,ocnt)
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].actionflag = 1
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].offsetminnbr = getassaysreply->assays[
      iaidx].lookback_minutes[k].minutes_nbr
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].offsettypecd = getassaysreply->assays[
      iaidx].lookback_minutes[k].type_code_value
     ENDIF
   ENDFOR
   FOR (k = 1 TO size(getexistingassayreply->slist[1].assay_list[1].lookback_minutes,5))
     SET num = 1
     SET foundi = locateval(num,1,size(getassaysreply->assays[iaidx].lookback_minutes,5),
      getexistingassayreply->slist[1].assay_list[1].lookback_minutes[k].type_code_value,
      getassaysreply->assays[iaidx].lookback_minutes[num].type_code_value)
     IF (foundi=0)
      SET ocnt = (ocnt+ 1)
      SET stat = alterlist(reconcileassayrequest->assays[1].offsetminutes,ocnt)
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].actionflag = 3
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].offsetminnbr = getexistingassayreply->
      slist[1].assay_list[1].lookback_minutes[k].minutes_nbr
      SET reconcileassayrequest->assays[1].offsetminutes[ocnt].offsettypecd = getexistingassayreply->
      slist[1].assay_list[1].lookback_minutes[k].type_code_value
     ENDIF
   ENDFOR
   SET num = 1
   SET foundi = locateval(num,1,size(getexistingassayreply->slist[1].assay_list[1].data_map,5),0.0,
    getexistingassayreply->slist[1].assay_list[1].data_map[num].service_resource_code_value)
   IF (foundi > 0)
    IF ((((getassaysreply->assays[iaidx].max_digits != getexistingassayreply->slist[1].assay_list[1].
    data_map[foundi].max_digits)) OR ((((getassaysreply->assays[iaidx].min_digits !=
    getexistingassayreply->slist[1].assay_list[1].data_map[foundi].min_digits)) OR ((getassaysreply->
    assays[iaidx].min_decimal_places != getexistingassayreply->slist[1].assay_list[1].data_map[foundi
    ].dec_place))) )) )
     SET reconcileassayrequest->assays[1].datamap.actionflag = 2
     SET reconcileassayrequest->assays[1].datamap.max_digits = getassaysreply->assays[iaidx].
     max_digits
     SET reconcileassayrequest->assays[1].datamap.min_digits = getassaysreply->assays[iaidx].
     min_digits
     SET reconcileassayrequest->assays[1].datamap.min_decimal_places = getassaysreply->assays[iaidx].
     min_decimal_places
    ENDIF
   ENDIF
   DECLARE importedresulttypemean = vc WITH protect, noconstant("")
   DECLARE existingresulttypemean = vc WITH protect, noconstant("")
   DECLARE modifiedrr = i2 WITH protect, noconstant(0)
   SET importedresulttypemean = getassaysreply->assays[iaidx].result_type.mean
   SET existingresulttypemean = getexistingassayreply->slist[1].assay_list[1].general_info.
   result_type_mean
   FREE RECORD processedrrs
   RECORD processedrrs(
     1 list[*]
       2 rrf_id = f8
   )
   FOR (k = 1 TO size(getassaysreply->assays[iaidx].ref_ranges,5))
     SET num = 1
     SET foundi = locateval(num,1,size(getexistingassayreply->slist[1].assay_list[1].rr_list,5),
      cnvtint(getassaysreply->assays[iaidx].ref_ranges[k].age_to),getexistingassayreply->slist[1].
      assay_list[1].rr_list[num].to_age,
      getassaysreply->assays[iaidx].ref_ranges[k].age_to_units.code_value,getexistingassayreply->
      slist[1].assay_list[1].rr_list[num].to_age_unit_code_value,cnvtint(getassaysreply->assays[iaidx
       ].ref_ranges[k].age_from),getexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age,
      getassaysreply->assays[iaidx].ref_ranges[k].age_from_units.code_value,
      getexistingassayreply->slist[1].assay_list[1].rr_list[num].from_age_unit_code_value,
      getassaysreply->assays[iaidx].ref_ranges[k].sex.code_value,getexistingassayreply->slist[1].
      assay_list[1].rr_list[num].sex_code_value)
     IF (foundi > 0)
      SET pprrcnt = (size(processedrrs->list,5)+ 1)
      SET stat = alterlist(processedrrs->list,pprrcnt)
      SET processedrrs->list[pprrcnt].rrf_id = getexistingassayreply->slist[1].assay_list[1].rr_list[
      foundi].rrf_id
      IF ((getassaysreply->assays[iaidx].ref_ranges[k].rrf_uid=""))
       SET rrcnt = (size(reconcileassayrequest->assays[1].refranges,5)+ 1)
       SET stat = alterlist(reconcileassayrequest->assays[1].refranges,rrcnt)
       SET reconcileassayrequest->assays[1].refranges[rrcnt].actionflag = 3
       SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfid = getexistingassayreply->slist[1].
       assay_list[1].rr_list[foundi].rrf_id
      ELSE
       IF (importedresulttypemean IN ("3", "8"))
        IF ((getassaysreply->assays[iaidx].ref_ranges[k].units.code_value != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].uom_code_value))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].normal_low != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].ref_low))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].normal_high != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].ref_high))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].critical_low != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].crit_low))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].critical_high != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].crit_high))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].review_low != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].review_low))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].review_high != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].review_high))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].linear_low != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].linear_low))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].linear_high != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].linear_high))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].feasible_low != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].feasible_low))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].feasible_high != getexistingassayreply->
        slist[1].assay_list[1].rr_list[foundi].feasible_high))
         SET modifiedrr = 1
        ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].default_result != getexistingassayreply
        ->slist[1].assay_list[1].rr_list[foundi].def_value))
         SET modifiedrr = 1
        ENDIF
        IF (modifiedrr=1)
         SET rrcnt = (size(reconcileassayrequest->assays[1].refranges,5)+ 1)
         SET stat = alterlist(reconcileassayrequest->assays[1].refranges,rrcnt)
         SET reconcileassayrequest->assays[1].refranges[rrcnt].actionflag = 2
         SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfid = getexistingassayreply->slist[1
         ].assay_list[1].rr_list[foundi].rrf_id
         SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfuid = getassaysreply->assays[iaidx]
         .ref_ranges[k].rrf_uid
        ENDIF
        IF (importedresulttypemean="8")
         CALL compareequation(iaidx)
        ENDIF
       ELSEIF (importedresulttypemean IN ("2", "21", "5", "22"))
        SET modifiedrr = 0
        FOR (ar = 1 TO size(getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses,5))
          IF ((getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].modified_status !=
          none))
           IF (modifiedrr=0)
            SET rrcnt = (size(reconcileassayrequest->assays[1].refranges,5)+ 1)
            SET stat = alterlist(reconcileassayrequest->assays[1].refranges,rrcnt)
            SET reconcileassayrequest->assays[1].refranges[rrcnt].actionflag = 0
            SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfid = getexistingassayreply->
            slist[1].assay_list[1].rr_list[foundi].rrf_id
            SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfuid = getassaysreply->assays[
            iaidx].ref_ranges[k].rrf_uid
           ENDIF
           SET arcnt = (size(reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses,5)+ 1)
           SET stat = alterlist(reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses,
            arcnt)
           IF ((getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].modified_status=added
           ))
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].actionflag =
            1
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].aruid =
            getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].ar_uid
           ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].modified_status=
           modified))
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].actionflag =
            2
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].aruid =
            getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].ar_uid
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].
            nomenclatureid = getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].
            nomenclature_id
           ELSEIF ((getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].modified_status=
           removed))
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].actionflag =
            3
            SET reconcileassayrequest->assays[1].refranges[rrcnt].alpharesponses[arcnt].
            nomenclatureid = getassaysreply->assays[iaidx].ref_ranges[k].alpha_responses[ar].
            nomenclature_id
           ENDIF
           SET modifiedrr = 1
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ELSE
      SET rrcnt = (size(reconcileassayrequest->assays[1].refranges,5)+ 1)
      SET stat = alterlist(reconcileassayrequest->assays[1].refranges,rrcnt)
      SET reconcileassayrequest->assays[1].refranges[rrcnt].actionflag = 1
      SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfuid = getassaysreply->assays[iaidx].
      ref_ranges[k].rrf_uid
     ENDIF
   ENDFOR
   FOR (existrrcnt = 1 TO size(getexistingassayreply->slist[1].assay_list[1].rr_list,5))
    SET foundi = locateval(num,1,size(processedrrs->list,5),getexistingassayreply->slist[1].
     assay_list[1].rr_list[existrrcnt].rrf_id,processedrrs->list[num].rrf_id)
    IF (foundi=0)
     SET rrcnt = (size(reconcileassayrequest->assays[1].refranges,5)+ 1)
     SET stat = alterlist(reconcileassayrequest->assays[1].refranges,rrcnt)
     SET reconcileassayrequest->assays[1].refranges[rrcnt].actionflag = 3
     SET reconcileassayrequest->assays[1].refranges[rrcnt].rrfid = getexistingassayreply->slist[1].
     assay_list[1].rr_list[existrrcnt].rrf_id
    ENDIF
   ENDFOR
   CALL bedlogmessage("compareAssay ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting compareAssay ...")
 END ;Subroutine
 SUBROUTINE compareequation(ai)
   CALL bedlogmessage("compareEquation ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering compareEquation ...")
   DECLARE importedeqsize = i4 WITH protect, noconstant(0)
   DECLARE existingeqsize = i4 WITH protect, noconstant(0)
   DECLARE eqcnt = i4 WITH protect, noconstant(0)
   DECLARE equationcnt = i4 WITH protect, noconstant(0)
   DECLARE equationfound = i2 WITH protect, noconstant(0)
   DECLARE modeqind = i2 WITH protect, noconstant(0)
   DECLARE eqproccnt = i4 WITH protect, noconstant(0)
   FREE RECORD eqprocessed
   RECORD eqprocessed(
     1 list[*]
       2 id = f8
   )
   SET importedeqsize = size(getassaysreply->assays[ai].equations,5)
   SET existingeqsize = size(getexistingassayreply->slist[1].assay_list[1].equation,5)
   IF (importedeqsize > 0)
    IF (existingeqsize=0)
     FOR (eqcnt = 1 TO importedeqsize)
       SET stat = alterlist(reconcileassayrequest->assays[1].equations,eqcnt)
       SET reconcileassayrequest->assays[1].equations[eqcnt].actionflag = 1
       SET reconcileassayrequest->assays[1].equations[eqcnt].equationuid = getassaysreply->assays[ai]
       .equations[eqcnt].equation_uid
     ENDFOR
    ELSE
     FOR (equationcnt = 1 TO importedeqsize)
       SET num = 1
       SET equationfound = locateval(num,1,size(getexistingassayreply->slist[1].assay_list[1].
         equation,5),getassaysreply->assays[ai].equations[equationcnt].age_from,getexistingassayreply
        ->slist[1].assay_list[1].equation[num].age_from,
        getassaysreply->assays[ai].equations[equationcnt].age_from_units.code_value,
        getexistingassayreply->slist[1].assay_list[1].equation[num].age_from_units.code_value,
        getassaysreply->assays[ai].equations[equationcnt].age_to,getexistingassayreply->slist[1].
        assay_list[1].equation[num].age_to,getassaysreply->assays[ai].equations[equationcnt].
        age_to_units.code_value,
        getexistingassayreply->slist[1].assay_list[1].equation[num].age_to_units.code_value,
        getassaysreply->assays[ai].equations[equationcnt].sex.code_value,getexistingassayreply->
        slist[1].assay_list[1].equation[num].sex.code_value)
       IF (equationfound=0)
        SET tempeqcnt = (size(reconcileassayrequest->assays[1].equations,5)+ 1)
        SET stat = alterlist(reconcileassayrequest->assays[1].equations,tempeqcnt)
        SET reconcileassayrequest->assays[1].equations[tempeqcnt].actionflag = 1
        SET reconcileassayrequest->assays[1].equations[tempeqcnt].equationuid = getassaysreply->
        assays[ai].equations[tempeqcnt].equation_uid
       ELSE
        SET eqproccnt = (eqproccnt+ 1)
        SET stat = alterlist(eqprocessed->list,eqproccnt)
        SET eqprocessed->list[eqproccnt].id = getexistingassayreply->slist[1].assay_list[1].equation[
        equationfound].id
        IF ((getassaysreply->assays[ai].equations[equationcnt].description != getexistingassayreply->
        slist[1].assay_list[1].equation[equationfound].equation_description))
         SET modeqind = 1
        ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].unknown_age_ind !=
        getexistingassayreply->slist[1].assay_list[1].equation[equationfound].unknown_age_ind))
         SET modeqind = 1
        ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].default_ind !=
        getexistingassayreply->slist[1].assay_list[1].equation[equationfound].default_ind))
         SET modeqind = 1
        ELSEIF (size(getassaysreply->assays[ai].equations[equationcnt].components,5) != size(
         getexistingassayreply->slist[1].assay_list[1].equation[equationfound].components,5))
         SET modeqind = 1
        ELSEIF (size(getassaysreply->assays[ai].equations[equationcnt].components,5)=size(
         getexistingassayreply->slist[1].assay_list[1].equation[equationfound].components,5))
         FOR (componentidx = 1 TO size(getassaysreply->assays[ai].equations[equationcnt].components,5
          ))
           IF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           included_assay.code_value != getexistingassayreply->slist[1].assay_list[1].equation[
           equationfound].components[componentidx].included_assay.code_value))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           component_name != getexistingassayreply->slist[1].assay_list[1].equation[equationfound].
           components[componentidx].component_name))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           constant_value != getexistingassayreply->slist[1].assay_list[1].equation[equationfound].
           components[componentidx].constant_value))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           required_flag != getexistingassayreply->slist[1].assay_list[1].equation[equationfound].
           components[componentidx].required_flag))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           look_time_direction_flag != getexistingassayreply->slist[1].assay_list[1].equation[
           equationfound].components[componentidx].look_time_direction_flag))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           time_window_back_minutes != getexistingassayreply->slist[1].assay_list[1].equation[
           equationfound].components[componentidx].time_window_back_minutes))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           time_window_minutes != getexistingassayreply->slist[1].assay_list[1].equation[
           equationfound].components[componentidx].time_window_minutes))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           value_unit.code_value != getexistingassayreply->slist[1].assay_list[1].equation[
           equationfound].components[componentidx].value_unit.code_value))
            SET modeqind = 1
           ELSEIF ((getassaysreply->assays[ai].equations[equationcnt].components[componentidx].
           optional_value != getexistingassayreply->slist[1].assay_list[1].equation[equationfound].
           components[componentidx].optional_value))
            SET modeqind = 1
           ENDIF
         ENDFOR
        ENDIF
        IF (modeqind=1)
         SET tempeqcnt = (size(reconcileassayrequest->assays[1].equations,5)+ 1)
         SET stat = alterlist(reconcileassayrequest->assays[1].equations,tempeqcnt)
         SET reconcileassayrequest->assays[1].equations[tempeqcnt].actionflag = 2
         SET reconcileassayrequest->assays[1].equations[tempeqcnt].equationuid = getassaysreply->
         assays[ai].equations[tempeqcnt].equation_uid
         SET reconcileassayrequest->assays[1].equations[tempeqcnt].equationid = getexistingassayreply
         ->slist[1].assay_list[1].equation[equationfound].id
        ENDIF
       ENDIF
     ENDFOR
     FOR (eqcnt = 1 TO existingeqsize)
       SET num = 1
       SET equationfound = locateval(num,1,eqproccnt,getexistingassayreply->slist[1].assay_list[1].
        equation[eqcnt].id,eqprocessed->list[num].id)
       IF (equationfound=0)
        SET stat = alterlist(reconcileassayrequest->assays[1].equations,eqcnt)
        SET reconcileassayrequest->assays[1].equations[eqcnt].actionflag = 3
        SET reconcileassayrequest->assays[1].equations[eqcnt].equationid = getexistingassayreply->
        slist[1].assay_list[1].equation[eqcnt].id
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF (existingeqsize > 0)
    FOR (eqcnt = 1 TO existingeqsize)
      SET tempeqcnt = (size(reconcileassayrequest->assays[1].equations,5)+ 1)
      SET stat = alterlist(reconcileassayrequest->assays[1].equations,tempeqcnt)
      SET reconcileassayrequest->assays[1].equations[tempeqcnt].actionflag = 3
      SET reconcileassayrequest->assays[1].equations[tempeqcnt].equationid = getexistingassayreply->
      slist[1].assay_list[1].equation[eqcnt].id
    ENDFOR
   ENDIF
   CALL bedlogmessage("compareEquation ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting compareEquation ...")
 END ;Subroutine
 SUBROUTINE loadexistingassay(assaycd)
   CALL bedlogmessage("loadExistingAssay ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering loadExistingAssay ...")
   FREE RECORD getexistingassayrequest
   RECORD getexistingassayrequest(
     1 search_by = i2
     1 search_list[1]
       2 code_value = f8
     1 search_txt = vc
     1 search_type_flag = vc
     1 include_inactive_child_ind = i2
     1 max_reply = i4
     1 load
       2 reference_ranges_ind = i2
       2 equivalent_info_ind = i2
       2 data_map_ind = i2
       2 equation_ind = i2
       2 dynamic_group_ind = i2
       2 lookback_minutes_ind = i2
       2 interpretations_ind = i2
     1 result_type_code_value = f8
     1 activity_type_cd = f8
     1 result_types[*]
       2 code_value = f8
   )
   SET getexistingassayrequest->search_by = 3
   SET getexistingassayrequest->search_list[1].code_value = assaycd
   SET getexistingassayrequest->load.reference_ranges_ind = 1
   SET getexistingassayrequest->load.data_map_ind = 1
   SET getexistingassayrequest->load.equation_ind = 1
   SET getexistingassayrequest->load.lookback_minutes_ind = 1
   SET getexistingassayrequest->load.interpretations_ind = 1
   SET stat = initrec(getexistingassayreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getexistingassayrequest))
   EXECUTE bed_get_assay  WITH replace("REQUEST",getexistingassayrequest), replace("REPLY",
    getexistingassayreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(getexistingassayreply))
   IF ((((getexistingassayreply->status_data.status != "S")) OR (size(getexistingassayreply->slist,5)
   =0)) )
    CALL bederror("bed_reconcile_assay failed.")
   ENDIF
   CALL bedlogmessage("loadExistingAssay ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting loadExistingAssay ...")
 END ;Subroutine
 SUBROUTINE logdebuginfo(desc)
   IF (validate(debug,0)=1)
    CALL echo("===============================================")
    CALL echo(desc)
    CALL echo("===============================================")
   ENDIF
 END ;Subroutine
END GO
