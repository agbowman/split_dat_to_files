CREATE PROGRAM bed_aud_drc_report:dba
 RECORD request(
   1 program_name = vc
   1 skip_volume_check_ind = i2
   1 output_filename = vc
   1 grouper_id[*]
     2 grp_id = f8
   1 routes_list[*]
     2 route_id = f8
   1 active_ind = i2
   1 dose_types = i2
   1 age[*]
     2 age_grp_typ = i2
     2 operator = i2
     2 from = f8
     2 to = f8
     2 unit = f8
 )
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
 IF ( NOT (validate(unsortedreply,0)))
  RECORD unsortedreply(
    1 qual[*]
      2 dose_range_check_id = f8
      2 drc_form_reltn_id = f8
      2 reltn_build_flag = i2
      2 reltn_active_ind = i2
      2 drc_name = vc
      2 drc_content_rule_identifier = f8
      2 drc_build_flag = i2
      2 drc_active_ind = i2
      2 parent_premise[*]
        3 parent_premise_id = f8
        3 active_ind = i2
        3 routes_location_flag = i2
        3 premise[*]
          4 drc_premise_id = f8
          4 premise_type_flag = i2
          4 concept_cki = vc
          4 source_string = vc
          4 relational_operator_flag = i2
          4 value_unit_cd = f8
          4 value1 = f8
          4 value2 = f8
          4 age1_to_days = f8
          4 age2_to_days = f8
          4 weight1_to_kgs = f8
          4 weight2_to_kgs = f8
          4 active_ind = i2
          4 routes[*]
            5 drc_premise_list_id = f8
            5 parent_entity_id = f8
            5 route_disp = vc
            5 active_ind = i2
        3 dose_range[*]
          4 drc_dose_range_id = f8
          4 min_value = f8
          4 max_value = f8
          4 min_value_variance = f8
          4 max_value_variance = f8
          4 value_unit_cd = f8
          4 max_dose = f8
          4 max_dose_unit_cd = f8
          4 dose_days = i4
          4 type_flag = i2
          4 long_text_id = f8
          4 long_text = vc
          4 active_ind = i2
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
 FREE SET rows
 RECORD rows(
   1 qual[*]
     2 parent_premise_id = f8
     2 routes_concat_disp = vc
     2 routes_concat_physical_sort_key = i4
     2 clinical_conditions = vc
     2 clinical_cond_physical_sort_key = i4
     2 pma_operator_sort_key = i4
     2 pma_physical_sort_key = i4
     2 pma_field1 = f8
     2 pma_field2 = f8
     2 hepatic_physical_sort_key = i2
     2 crcl_operator_sort_key = i4
     2 crcl_unit_of_measure_sort_key = i1
     2 crcl_physical_sort_key = i4
     2 crcl_field1 = f8
     2 crcl_field2 = f8
     2 age_operator_sort_key = i4
     2 age_physical_sort_key = i4
     2 age_field1 = f8
     2 age_field2 = f8
     2 weight_operator_sort_key = i4
     2 weight_physical_sort_key = i4
     2 weight_field1 = f8
     2 weight_field2 = f8
     2 overlap_sort_key = i4
     2 gap_sort_key = i4
     2 mark_age_overlap = i2
     2 mark_weight_overlap = i2
     2 mark_crcl_overlap = i2
     2 mark_pma_overlap = i2
     2 mark_age_gap = i2
     2 mark_weight_gap = i2
     2 sorted_routes[*]
       3 drc_premise_list_id = f8
       3 parent_entity_id = f8
       3 route_disp = vc
       3 active_ind = i2
 )
 RECORD sorted_rows(
   1 qual[*]
     2 parent_premise_id = f8
 )
 FREE SET prev_row
 RECORD prev_row(
   1 parent_premise_id = f8
   1 routes_concat_physical_sort_key = i4
   1 clinical_cond_physical_sort_key = i4
   1 pma_operator_sort_key = i4
   1 pma_field1 = f8
   1 pma_field2 = f8
   1 hepatic_physical_sort_key = i2
   1 crcl_unit_of_measure_sort_key = i1
   1 crcl_operator_sort_key = i4
   1 crcl_field1 = f8
   1 crcl_field2 = f8
   1 age_operator_sort_key = i4
   1 age_field1 = f8
   1 age_field2 = f8
   1 weight_operator_sort_key = i4
   1 weight_field1 = f8
   1 weight_field2 = f8
   1 overlap_sort_key = i4
   1 gap_sort_key = i4
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
 DECLARE age = i2 WITH protect, constant(1)
 DECLARE routes = i2 WITH protect, constant(2)
 DECLARE weight = i2 WITH protect, constant(3)
 DECLARE crcl = i2 WITH protect, constant(4)
 DECLARE pma = i2 WITH protect, constant(5)
 DECLARE hepatic = i2 WITH protect, constant(6)
 DECLARE clinical_condition = i2 WITH protect, constant(7)
 DECLARE none = i2 WITH protect, constant(0)
 DECLARE no_overlap = i2 WITH protect, constant(0)
 DECLARE has_overlap = i2 WITH protect, constant(1)
 DECLARE same = i2 WITH protect, constant(2)
 DECLARE no_gap = i2 WITH protect, constant(0)
 DECLARE has_gap = i2 WITH protect, constant(1)
 DECLARE less_than_key = i2 WITH protect, constant(- (3))
 DECLARE between_key = i2 WITH protect, constant(- (2))
 DECLARE greater_equal_key = i2 WITH protect, constant(- (1))
 DECLARE no_operator_key = i2 WITH protect, constant(0)
 DECLARE no_hepatic_key = i2 WITH protect, constant(0)
 DECLARE yes_hepatic_key = i2 WITH protect, constant(- (1))
 DECLARE no_condition_key = i2 WITH protect, constant(0)
 DECLARE unit_ml_min_1_73m2_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2570188158"))
 DECLARE unit_ml_min_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2738"))
 DECLARE unit_ml_min_1_73m2_key = i1 WITH protect, constant(1)
 DECLARE unit_ml_min_key = i1 WITH protect, constant(10)
 DECLARE convert_to_days(number=f8,units_code=f8,from_or_to=i2) = null
 DECLARE convert_to_kgs(number=f8,units_code=f8,operator=i2) = null
 DECLARE calculateoperatorsortkey(operator_type=i2) = i2
 DECLARE calculatecrclunitofmeasuresortkey(unit_type=f8) = i1
 DECLARE calculateyesnosortkey(operator_type=f8) = i2
 DECLARE calculateoperatorandfieldbasedsortkey(field_type=i2) = null
 DECLARE ranktherowsforphysicalsorting(dummyvar=i2) = null
 DECLARE compareiftworowsareinsamebucketforoverlap(curr_seq=i4) = null
 DECLARE compareiftworowsareinsamebucketforagegap(curr_seq=i4) = null
 DECLARE compareiftworowsareinsamebucketforweightgap(curr_seq=i4) = null
 DECLARE compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq=i4,type=i2) = null
 DECLARE markoverlap(type=i2) = i2
 DECLARE markrowsforoverlap(dummyvar=i2) = null
 DECLARE markrowsforagegap(dummyvar=i2) = null
 DECLARE markrowsforweightgap(dummyvar=i2) = null
 DECLARE number_of_days = f8 WITH public, noconstant(0.0)
 DECLARE number_of_hrs = f8 WITH public, noconstant(0.0)
 DECLARE number_of_kgs = f8 WITH public, noconstant(0.0)
 DECLARE age_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE pma_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE crcl_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE weight_overlap_flag = i2 WITH public, noconstant(0)
 SUBROUTINE convert_to_days(number,units_code,from_or_to)
   SET number_of_days = 0.0
   SET number_of_hrs = 0.0
   IF (units_code=years
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 360.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number=2.0)
    SET number_of_days = 720.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number >= 3.0)
    SET number_of_days = round((365.0 * number),1)
    SET number_of_hrs = round(((365.0 * number) * 24.0),2)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 359.9
    SET number_of_hrs = ((360.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=2.0)
    SET number_of_days = 719.9
    SET number_of_hrs = ((720.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number >= 3.0)
    SET number_of_days = round(((365.0 * number) - 0.1),1)
    SET number_of_hrs = round((((365.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 28.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number >= 2.0)
    SET number_of_days = round((30.0 * number),1)
    SET number_of_hrs = round(((30.0 * number) * 24.0),2)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 27.9
    SET number_of_hrs = ((28.0 * 24.0) - 0.01)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number >= 2.0)
    SET number_of_days = round(((30.0 * number) - 0.1),1)
    SET number_of_hrs = round((((30.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=weeks
    AND from_or_to=1)
    SET number_of_days = round((7.0 * number),1)
    SET number_of_hrs = round(((7.0 * number) * 24.0),2)
   ELSEIF (units_code=weeks
    AND from_or_to=0)
    SET number_of_days = round(((7.0 * number) - 0.1),1)
    SET number_of_hrs = round((((7.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=days
    AND from_or_to=1)
    SET number_of_days = round(number,1)
    SET number_of_hrs = round((number * 24.0),2)
   ELSEIF (units_code=days
    AND from_or_to=0)
    SET number_of_days = round((number - 0.1),1)
    SET number_of_hrs = round(((number * 24.0) - 0.01),2)
   ELSEIF (units_code=hours
    AND from_or_to=1)
    SET number_of_days = round((number/ 24.0),1)
    SET number_of_hrs = round(number,2)
   ELSEIF (units_code=hours
    AND from_or_to=0)
    SET number_of_days = round(((number/ 24.0) - 0.1),1)
    SET number_of_hrs = round((number - 0.01),2)
   ELSE
    SET number_of_days = 0.0
   ENDIF
   CALL bederrorcheck("Error 013: Failed to convert to days")
 END ;Subroutine
 SUBROUTINE convert_to_kgs(number,units_code,operator)
   SET number_of_kgs = 0.0
   IF (units_code=kg
    AND operator=1)
    SET number_of_kgs = round((number - 0.00001),5)
   ELSEIF (units_code=kg
    AND ((operator=3) OR (operator=4)) )
    SET number_of_kgs = round(number,5)
   ELSEIF (units_code=kg
    AND operator=2)
    SET number_of_kgs = round((number+ 0.00001),5)
   ELSEIF (units_code=gram
    AND operator=1)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 1000.0) - 0.00001),5)
    ENDIF
   ELSEIF (units_code=gram
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((number/ 1000.0),5)
    ENDIF
   ELSEIF (units_code=gram
    AND operator=2)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 1000.0)+ 0.00001),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND operator=1)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((((number/ 16.0) * 0.4545) - 0.00001),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 16.0) * 0.4545),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND operator=2)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((((number/ 16.0) * 0.4545)+ 0.00001),5)
    ENDIF
   ELSEIF (units_code=lbs
    AND operator=1)
    SET number_of_kgs = round(((number * 0.4545) - 0.00001),5)
   ELSEIF (units_code=lbs
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((number * 0.4545),5)
    ENDIF
   ELSEIF (units_code=lbs
    AND operator=2)
    SET number_of_kgs = round(((number * 0.4545)+ 0.00001),5)
   ELSE
    SET number_of_kgs = 0.0
   ENDIF
   CALL bederrorcheck("Error 014: Failed to convert to kgs")
 END ;Subroutine
 SUBROUTINE calculateoperatorsortkey(operator_type)
  CASE (operator_type)
   OF 1:
    RETURN(less_than_key)
   OF 6:
    RETURN(between_key)
   OF 4:
    RETURN(greater_equal_key)
  ENDCASE
  CALL bederrorcheck("Error 015: Wrong operator_type")
 END ;Subroutine
 SUBROUTINE calculateyesnosortkey(operator_type)
  CASE (operator_type)
   OF 0.0:
    RETURN(no_hepatic_key)
   OF 1.0:
    RETURN(yes_hepatic_key)
  ENDCASE
  CALL bederrorcheck("Error 016: Invalid Yes/No operator.")
 END ;Subroutine
 SUBROUTINE ranktherowsforphysicalsorting(dummyvar)
   CALL calculateoperatorandfieldbasedsortkey(routes)
   CALL calculateoperatorandfieldbasedsortkey(age)
   CALL calculateoperatorandfieldbasedsortkey(pma)
   CALL calculateoperatorandfieldbasedsortkey(crcl)
   CALL calculateoperatorandfieldbasedsortkey(weight)
   CALL calculateoperatorandfieldbasedsortkey(clinical_condition)
   SET stat = alterlist(sorted_rows->qual,size(rows->qual,5))
   IF (size(sorted_rows->qual,5) > 0)
    SET i = 0
    SELECT INTO "NL:"
     rows->qual[d1.seq].parent_premise_id
     FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
     PLAN (d1)
     ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].gap_sort_key
       DESC, rows->qual[d1.seq].age_physical_sort_key,
      rows->qual[d1.seq].weight_physical_sort_key, rows->qual[d1.seq].pma_physical_sort_key, rows->
      qual[d1.seq].clinical_cond_physical_sort_key,
      rows->qual[d1.seq].hepatic_physical_sort_key, rows->qual[d1.seq].crcl_physical_sort_key
     DETAIL
      i = (i+ 1), sorted_rows->qual[i].parent_premise_id = rows->qual[d1.seq].parent_premise_id
     WITH nocounter
    ;end select
    CALL bederrorcheck(
     "Error 017: Error while ranking the rows physically based on the physical_sort_keys")
   ENDIF
 END ;Subroutine
 SUBROUTINE calculateoperatorandfieldbasedsortkey(field_type)
  DECLARE previous_concat_route_disp = vc
  IF (size(rows->qual,5) > 0)
   CASE (field_type)
    OF routes:
     SET concat_route_disp_key = 0
     SET previous_concat_route_disp = ""
     SET route_concat_disp = ""
     SELECT INTO "NL:"
      route_concat_disp = substring(1,1000,trim(rows->qual[d1.seq].routes_concat_disp,7))
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY route_concat_disp
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].routes_concat_disp=previous_concat_route_disp)))
        concat_route_disp_key = (concat_route_disp_key+ 1), previous_concat_route_disp = rows->qual[
        d1.seq].routes_concat_disp
       ENDIF
       rows->qual[d1.seq].routes_concat_physical_sort_key = concat_route_disp_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to clinical conditions")
    OF clinical_condition:
     SET clinical_cond_key = no_condition_key
     SET previous_clic_cond = ""
     SET clinical_condition_temp = ""
     SELECT INTO "NL:"
      clinical_condition_temp = substring(1,1000,trim(rows->qual[d1.seq].clinical_conditions,7))
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1
       WHERE  NOT (trim(rows->qual[d1.seq].clinical_conditions,7) IN ("", null)))
      ORDER BY clinical_condition_temp DESC
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].clinical_conditions=previous_clic_cond)))
        clinical_cond_key = (clinical_cond_key - 1), previous_clic_cond = rows->qual[d1.seq].
        clinical_conditions
       ENDIF
       rows->qual[d1.seq].clinical_cond_physical_sort_key = clinical_cond_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to clinical conditions")
    OF pma:
     SET pma_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].pma_operator_sort_key, rows->qual[d1.seq].pma_field1, rows->qual[d1.seq].
      pma_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].pma_operator_sort_key, rows->qual[d1.seq].pma_field1, rows->qual[d1
       .seq].pma_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].pma_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].pma_field1=previous_row_field1)
        AND (rows->qual[d1.seq].pma_field2=previous_row_field2)))
        pma_key = (pma_key+ 1), previous_operator_value = rows->qual[d1.seq].pma_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].pma_field1,
        previous_row_field2 = rows->qual[d1.seq].pma_field2
       ENDIF
       rows->qual[d1.seq].pma_physical_sort_key = pma_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to PMA")
    OF crcl:
     SET crcl_key = 0
     SET previous_unit_of_measure_value = - (128)
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].crcl_unit_of_measure_sort_key, rows->qual[d1.seq].crcl_operator_sort_key,
      rows->qual[d1.seq].crcl_field1,
      rows->qual[d1.seq].crcl_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].crcl_unit_of_measure_sort_key, rows->qual[d1.seq].
       crcl_operator_sort_key, rows->qual[d1.seq].crcl_field1,
       rows->qual[d1.seq].crcl_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].crcl_unit_of_measure_sort_key=previous_unit_of_measure_value)
        AND (rows->qual[d1.seq].crcl_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].crcl_field1=previous_row_field1)
        AND (rows->qual[d1.seq].crcl_field2=previous_row_field2)))
        crcl_key = (crcl_key+ 1), previous_unit_of_measure_value = rows->qual[d1.seq].
        crcl_unit_of_measure_sort_key, previous_operator_value = rows->qual[d1.seq].
        crcl_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].crcl_field1, previous_row_field2 = rows->qual[d1.seq
        ].crcl_field2
       ENDIF
       rows->qual[d1.seq].crcl_physical_sort_key = crcl_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to CrCl")
    OF age:
     SET age_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].age_operator_sort_key, rows->qual[d1.seq].age_field1, rows->qual[d1.seq].
      age_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].age_operator_sort_key, rows->qual[d1.seq].age_field1, rows->qual[d1
       .seq].age_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].age_field1=previous_row_field1)
        AND (rows->qual[d1.seq].age_field2=previous_row_field2)))
        age_key = (age_key+ 1), previous_operator_value = rows->qual[d1.seq].age_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].age_field1,
        previous_row_field2 = rows->qual[d1.seq].age_field2
       ENDIF
       rows->qual[d1.seq].age_physical_sort_key = age_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to Age")
    OF weight:
     SET weight_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].weight_operator_sort_key, rows->qual[d1.seq].weight_field1, rows->qual[d1
      .seq].weight_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].weight_operator_sort_key, rows->qual[d1.seq].weight_field1, rows->
       qual[d1.seq].weight_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].weight_field1=previous_row_field1)
        AND (rows->qual[d1.seq].weight_field2=previous_row_field2)))
        weight_key = (weight_key+ 1), previous_operator_value = rows->qual[d1.seq].
        weight_operator_sort_key, previous_row_field1 = rows->qual[d1.seq].weight_field1,
        previous_row_field2 = rows->qual[d1.seq].weight_field2
       ENDIF
       rows->qual[d1.seq].weight_physical_sort_key = weight_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to Weight")
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforoverlap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   IF ((rows->qual[curr_seq].overlap_sort_key=prev_row->overlap_sort_key)
    AND (rows->qual[curr_seq].routes_concat_physical_sort_key=prev_row->
   routes_concat_physical_sort_key)
    AND (rows->qual[curr_seq].clinical_cond_physical_sort_key=prev_row->
   clinical_cond_physical_sort_key)
    AND (rows->qual[curr_seq].hepatic_physical_sort_key=prev_row->hepatic_physical_sort_key)
    AND (rows->qual[curr_seq].crcl_unit_of_measure_sort_key=prev_row->crcl_unit_of_measure_sort_key))
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,age)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,pma)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,weight)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,crcl)
    SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[
     index].parent_premise_id)
    SET rows->qual[prev_index].mark_age_overlap = markoverlap(age)
    SET rows->qual[prev_index].mark_pma_overlap = markoverlap(pma)
    SET rows->qual[prev_index].mark_weight_overlap = markoverlap(weight)
    SET rows->qual[prev_index].mark_crcl_overlap = markoverlap(crcl)
   ENDIF
   CALL bederrorcheck("Error 020: Error while compare adjacent rows for Overlap.")
 END ;Subroutine
 SUBROUTINE compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,type)
  CASE (type)
   OF age:
    IF ((prev_row->age_operator_sort_key=rows->qual[curr_seq].age_operator_sort_key))
     CASE (prev_row->age_operator_sort_key)
      OF between_key:
       IF ((prev_row->age_field1=rows->qual[curr_seq].age_field1)
        AND (prev_row->age_field2=rows->qual[curr_seq].age_field2))
        SET age_overlap_flag = same
       ELSEIF ((( NOT ((prev_row->age_field1 < rows->qual[curr_seq].age_field2))) OR ( NOT ((prev_row
       ->age_field2 > rows->qual[curr_seq].age_field1)))) )
        SET age_overlap_flag = no_overlap
       ELSE
        SET age_overlap_flag = has_overlap
       ENDIF
      ELSE
       IF ((prev_row->age_field1=rows->qual[curr_seq].age_field1))
        SET age_overlap_flag = same
       ELSE
        SET age_overlap_flag = has_overlap
       ENDIF
     ENDCASE
    ELSE
     CASE (prev_row->age_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->age_field1 > rows->qual[curr_seq].age_field1))
        SET age_overlap_flag = has_overlap
       ELSE
        SET age_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].age_operator_sort_key=greater_equal_key))
        IF ((prev_row->age_field2 > rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].age_operator_sort_key=less_than_key))
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field2))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   OF pma:
    IF ((prev_row->pma_operator_sort_key=rows->qual[curr_seq].pma_operator_sort_key))
     IF ( NOT ((prev_row->pma_operator_sort_key=no_operator_key)))
      CASE (prev_row->pma_operator_sort_key)
       OF between_key:
        IF ((prev_row->pma_field1=rows->qual[curr_seq].pma_field1)
         AND (prev_row->pma_field2=rows->qual[curr_seq].pma_field2))
         SET pma_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field2))) OR ( NOT ((
        prev_row->pma_field2 > rows->qual[curr_seq].pma_field1)))) )
         SET pma_overlap_flag = no_overlap
        ELSE
         SET pma_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1=rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = same
        ELSE
         SET pma_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET pma_overlap_flag = same
     ENDIF
    ELSE
     CASE (prev_row->pma_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->pma_field1 > rows->qual[curr_seq].pma_field1))
        SET pma_overlap_flag = has_overlap
       ELSE
        SET pma_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].pma_operator_sort_key=greater_equal_key))
        IF ((prev_row->pma_field2 > rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].pma_operator_sort_key=less_than_key))
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field2))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   OF weight:
    IF ((prev_row->weight_operator_sort_key=rows->qual[curr_seq].weight_operator_sort_key))
     IF ( NOT ((prev_row->weight_operator_sort_key=no_operator_key)))
      CASE (prev_row->weight_operator_sort_key)
       OF between_key:
        IF ((prev_row->weight_field1=rows->qual[curr_seq].weight_field1)
         AND (prev_row->weight_field2=rows->qual[curr_seq].weight_field2))
         SET weight_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field2))) OR ( NOT ((
        prev_row->weight_field2 > rows->qual[curr_seq].weight_field1)))) )
         SET weight_overlap_flag = no_overlap
        ELSE
         SET weight_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->weight_field1=rows->qual[curr_seq].weight_field1))
         SET weight_overlap_flag = same
        ELSE
         SET weight_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET weight_overlap_flag = same
     ENDIF
    ELSE
     IF ((((prev_row->weight_operator_sort_key=no_operator_key)) OR ((rows->qual[curr_seq].
     weight_operator_sort_key=no_operator_key))) )
      SET weight_overlap_flag = has_overlap
     ELSE
      CASE (prev_row->weight_operator_sort_key)
       OF less_than_key:
        IF ((prev_row->weight_field1 > rows->qual[curr_seq].weight_field1))
         SET weight_overlap_flag = has_overlap
        ELSE
         SET weight_overlap_flag = no_overlap
        ENDIF
       OF between_key:
        IF ((rows->qual[curr_seq].weight_operator_sort_key=greater_equal_key))
         IF ((prev_row->weight_field2 > rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ELSE
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ENDIF
       ELSE
        IF ((rows->qual[curr_seq].weight_operator_sort_key=less_than_key))
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ELSE
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field2))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ENDIF
      ENDCASE
     ENDIF
    ENDIF
   OF crcl:
    IF ((prev_row->crcl_operator_sort_key=rows->qual[curr_seq].crcl_operator_sort_key))
     IF ( NOT ((prev_row->crcl_operator_sort_key=no_operator_key)))
      CASE (prev_row->crcl_operator_sort_key)
       OF between_key:
        IF ((prev_row->crcl_field1=rows->qual[curr_seq].crcl_field1)
         AND (prev_row->crcl_field2=rows->qual[curr_seq].crcl_field2))
         SET crcl_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field2))) OR ( NOT ((
        prev_row->crcl_field2 > rows->qual[curr_seq].crcl_field1)))) )
         SET crcl_overlap_flag = no_overlap
        ELSE
         SET crcl_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1=rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = same
        ELSE
         SET crcl_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET crcl_overlap_flag = same
     ENDIF
    ELSE
     CASE (prev_row->crcl_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->crcl_field1 > rows->qual[curr_seq].crcl_field1))
        SET crcl_overlap_flag = has_overlap
       ELSE
        SET crcl_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].crcl_operator_sort_key=greater_equal_key))
        IF ((prev_row->crcl_field2 > rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].crcl_operator_sort_key=less_than_key))
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field2))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   ELSE
    CALL bederrorcheck("Error 021: Unrecongnizeable premise type flag.")
  ENDCASE
  CALL bederrorcheck("Error 022: Error while compare premises of adjacent rows.")
 END ;Subroutine
 SUBROUTINE markoverlap(type)
   DECLARE result = i2 WITH public, noconstant(0)
   CASE (type)
    OF age:
     IF (((pma_overlap_flag=same) OR (pma_overlap_flag=has_overlap))
      AND ((age_overlap_flag=same) OR (age_overlap_flag=has_overlap))
      AND ((crcl_overlap_flag=same) OR (crcl_overlap_flag=has_overlap))
      AND ((weight_overlap_flag=same) OR (weight_overlap_flag=has_overlap)) )
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF pma:
     IF (((pma_overlap_flag=has_overlap) OR (pma_overlap_flag=same))
      AND age_overlap_flag=same
      AND crcl_overlap_flag=same
      AND weight_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF weight:
     IF (((weight_overlap_flag=has_overlap) OR (weight_overlap_flag=same))
      AND age_overlap_flag=same
      AND crcl_overlap_flag=same
      AND pma_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF crcl:
     IF (((crcl_overlap_flag=has_overlap) OR (crcl_overlap_flag=same))
      AND age_overlap_flag=same
      AND pma_overlap_flag=same
      AND weight_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    ELSE
     CALL bederrorcheck("Error 021: Unrecongnizeable premise type flag.")
   ENDCASE
   CALL bederrorcheck("Error 024: Error while determine if a row has overlap ranges.")
   RETURN(result)
 END ;Subroutine
 SUBROUTINE markrowsforoverlap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SET sorted_index = 1
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1)
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].overlap_sort_key
      DESC, rows->qual[d1.seq].clinical_cond_physical_sort_key,
     rows->qual[d1.seq].pma_physical_sort_key, rows->qual[d1.seq].hepatic_physical_sort_key, rows->
     qual[d1.seq].crcl_physical_sort_key,
     rows->qual[d1.seq].age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforoverlap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->routes_concat_physical_sort_key = rows->qual[d1.seq].
     routes_concat_physical_sort_key,
     prev_row->clinical_cond_physical_sort_key = rows->qual[d1.seq].clinical_cond_physical_sort_key,
     prev_row->hepatic_physical_sort_key = rows->qual[d1.seq].hepatic_physical_sort_key, prev_row->
     pma_operator_sort_key = rows->qual[d1.seq].pma_operator_sort_key,
     prev_row->pma_field1 = rows->qual[d1.seq].pma_field1, prev_row->pma_field2 = rows->qual[d1.seq].
     pma_field2, prev_row->crcl_unit_of_measure_sort_key = rows->qual[d1.seq].
     crcl_unit_of_measure_sort_key,
     prev_row->crcl_operator_sort_key = rows->qual[d1.seq].crcl_operator_sort_key, prev_row->
     crcl_field1 = rows->qual[d1.seq].crcl_field1, prev_row->crcl_field2 = rows->qual[d1.seq].
     crcl_field2,
     prev_row->age_operator_sort_key = rows->qual[d1.seq].age_operator_sort_key, prev_row->age_field1
      = rows->qual[d1.seq].age_field1, prev_row->age_field2 = rows->qual[d1.seq].age_field2,
     prev_row->weight_operator_sort_key = rows->qual[d1.seq].weight_operator_sort_key, prev_row->
     weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->qual[d1.seq].
     weight_field2,
     prev_row->overlap_sort_key = rows->qual[d1.seq].overlap_sort_key
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 025: Error while Marking rows for overlap.")
 END ;Subroutine
 SUBROUTINE markrowsforagegap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SELECT INTO "NL:"
    route = rows->qual[d1.seq].routes_concat_physical_sort_key
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1
     WHERE (rows->qual[d1.seq].gap_sort_key=0001))
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].
     age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    HEAD route
     sorted_index = 1
     IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=less_than_key)))
      rows->qual[d1.seq].mark_age_gap = has_gap
     ENDIF
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforagegap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->age_operator_sort_key = rows->qual[d1.seq].age_operator_sort_key,
     prev_row->age_field1 = rows->qual[d1.seq].age_field1, prev_row->age_field2 = rows->qual[d1.seq].
     age_field2, prev_row->weight_operator_sort_key = rows->qual[d1.seq].weight_operator_sort_key,
     prev_row->weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->
     qual[d1.seq].weight_field2, prev_row->gap_sort_key = rows->qual[d1.seq].gap_sort_key
    FOOT  route
     IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=greater_equal_key)))
      rows->qual[d1.seq].mark_age_gap = has_gap
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 026: Error while Marking rows for gap.")
 END ;Subroutine
 SUBROUTINE markrowsforweightgap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SELECT INTO "NL:"
    route = rows->qual[d1.seq].routes_concat_physical_sort_key, age = rows->qual[d1.seq].
    age_physical_sort_key
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1
     WHERE (rows->qual[d1.seq].overlap_sort_key=0011))
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].
     age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    HEAD route
     sorted_index = 1
    HEAD age
     sorted_index = 1
     IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=less_than_key)))
      rows->qual[d1.seq].mark_weight_gap = has_gap
     ENDIF
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforweightgap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->weight_operator_sort_key = rows->qual[d1.seq].
     weight_operator_sort_key,
     prev_row->weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->
     qual[d1.seq].weight_field2
    FOOT  age
     IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=greater_equal_key)))
      rows->qual[d1.seq].mark_weight_gap = has_gap
     ENDIF
    FOOT  route
     sorted_index = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 026: Error while Marking rows for gap.")
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforagegap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[index
    ].parent_premise_id)
   IF ((rows->qual[prev_index].mark_age_gap=no_gap))
    CASE (prev_row->age_operator_sort_key)
     OF less_than_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF less_than_key:
        SET rows->qual[prev_index].mark_age_gap = no_gap
       OF between_key:
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
      ENDCASE
     OF between_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF between_key:
        IF ((prev_row->age_field2 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->age_field2 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
      ENDCASE
     OF greater_equal_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF greater_equal_key:
        SET rows->qual[prev_index].mark_age_gap = no_gap
      ENDCASE
    ENDCASE
   ENDIF
   CALL bederrorcheck("Error 027: Error while compare adjacent rows for Age Gap.")
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforweightgap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[index
    ].parent_premise_id)
   IF ((rows->qual[prev_index].mark_weight_gap=no_gap))
    CASE (prev_row->weight_operator_sort_key)
     OF less_than_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF less_than_key:
        SET rows->qual[prev_index].mark_weight_gap = no_gap
       OF between_key:
        IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
      ENDCASE
     OF between_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF between_key:
        IF ((((prev_row->weight_field2 < rows->qual[curr_seq].weight_field1)) OR ((prev_row->
        weight_field1 > rows->qual[curr_seq].weight_field2))) )
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->weight_field2 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
      ENDCASE
     OF greater_equal_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF greater_equal_key:
        SET rows->qual[prev_index].mark_weight_gap = no_gap
      ENDCASE
    ENDCASE
   ENDIF
   CALL bederrorcheck("Error 028: Error while compare adjacent rows for Weight Gap.")
 END ;Subroutine
 SUBROUTINE calculatecrclunitofmeasuresortkey(unit_type)
  CASE (unit_type)
   OF unit_ml_min_1_73m2_cd:
    RETURN(unit_ml_min_1_73m2_key)
   OF unit_ml_min_cd:
    RETURN(unit_ml_min_key)
  ENDCASE
  CALL bederrorcheck("Error 029: Wrong unit_type for CrCl")
 END ;Subroutine
 DECLARE populategrouperreply(dummyvar=i2) = null
 DECLARE populatereplyinsortedorder(dummyvar=i2) = null
 DECLARE populatedoseranges(dummyvar=i2) = null
 DECLARE direct_to_days(number=f8,units_code=f8) = null
 DECLARE days_to_unit(number=f8,units_code=f8) = null
 DECLARE populatereplyafterapplyfilter(qualcnt=i4) = null
 DECLARE processrealnumbertorealstring(days=f8) = null
 DECLARE recursiverealnumbertostringconversion(dummyvar=i2) = null
 DECLARE less_than = i2 WITH protect, constant(1)
 DECLARE greater_than_equal = i2 WITH protect, constant(4)
 DECLARE betwn = i2 WITH protect, constant(6)
 DECLARE relational_routes = i2 WITH protect, constant(8)
 DECLARE single = i2 WITH protect, constant(1)
 DECLARE daily = i2 WITH protect, constant(2)
 DECLARE therapy = i2 WITH protect, constant(3)
 DECLARE ndays = i2 WITH protect, constant(4)
 DECLARE na = i2 WITH protect, constant(5)
 DECLARE continuous = i2 WITH protect, constant(6)
 DECLARE lifetime = i2 WITH protect, constant(7)
 DECLARE ppcnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE plcnt = i4 WITH protect, noconstant(0)
 DECLARE qualcnt = i4 WITH protect, noconstant(0)
 DECLARE pploop = i4 WITH protect, noconstant(0)
 DECLARE ploop = i4 WITH protect, noconstant(0)
 DECLARE aloop = i2 WITH protect, noconstant(0)
 DECLARE rloop = i4 WITH protect, noconstant(0)
 DECLARE hours = f8 WITH protect, noconstant(0.0)
 DECLARE days = f8 WITH protect, noconstant(0.0)
 DECLARE weeks = f8 WITH protect, noconstant(0.0)
 DECLARE months = f8 WITH protect, noconstant(0.0)
 DECLARE years = f8 WITH protect, noconstant(0.0)
 DECLARE kg = f8 WITH protect, noconstant(0.0)
 DECLARE gram = f8 WITH protect, noconstant(0.0)
 DECLARE ounce = f8 WITH protect, noconstant(0.0)
 DECLARE lbs = f8 WITH protect, noconstant(0.0)
 DECLARE parse_route_id = vc
 DECLARE parse_drc_grouper_id = vc
 DECLARE dparse = vc
 DECLARE days_to_unit = f8 WITH protect, noconstant(0.0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 SET days = uar_get_code_by_cki("CKI.CODEVALUE!8423")
 SET weeks = uar_get_code_by_cki("CKI.CODEVALUE!7994")
 SET months = uar_get_code_by_cki("CKI.CODEVALUE!7993")
 SET years = uar_get_code_by_cki("CKI.CODEVALUE!3712")
 SET hours = uar_get_code_by_cki("CKI.CODEVALUE!2743")
 SET kg = uar_get_code_by_cki("CKI.CODEVALUE!2751")
 SET gram = uar_get_code_by_cki("CKI.CODEVALUE!6123")
 SET ounce = uar_get_code_by_cki("CKI.CODEVALUE!2745")
 SET lbs = uar_get_code_by_cki("CKI.CODEVALUE!2746")
 CALL bedbeginscript(0)
 CALL preparefilter(0)
 CALL populategrouperunsortedreply(0)
 CALL populatedoseranges(0)
 CALL populatereplyinsortedorder(0)
 SUBROUTINE preparefilter(dummyvar)
   DECLARE groupersize = i4 WITH protect, noconstant(0.0)
   DECLARE routesize = i4 WITH protect, noconstant(0.0)
   DECLARE drc_grouper_id = vc WITH protect
   DECLARE route_id = vc WITH protect, noconstant("")
   SET groupersize = size(request->grouper_id,5)
   IF (groupersize > 0)
    SET drc_grouper_count = 0
    FOR (g = 1 TO groupersize)
      IF (drc_grouper_count > 999)
       SET drc_grouper_id = replace(drc_grouper_id,",","",2)
       SET drc_grouper_id = build(drc_grouper_id,") or dfr.dose_range_check_id IN (")
       SET drc_grouper_count = 0
      ENDIF
      SET drc_grouper_id = build(drc_grouper_id,request->grouper_id[g].grp_id,",")
      SET drc_grouper_count = (drc_grouper_count+ 1)
    ENDFOR
    SET drc_grouper_id = replace(drc_grouper_id,",","",2)
    SET parse_drc_grouper_id = build(parse_drc_grouper_id,"dfr.dose_range_check_id IN (",
     drc_grouper_id,")")
   ELSE
    SET parse_drc_grouper_id = build(parse_drc_grouper_id,"dfr.dose_range_check_id IN (",
     "select dose_range_check_id from drc_form_reltn",")")
   ENDIF
   SET dparse = "ddr.type_flag IN ("
   IF ((request->dose_types=0))
    SET dparse = build(dparse,"1,2,3,4,5,6,7",")")
   ELSE
    SET dparse = build(dparse,request->dose_types,")")
   ENDIF
 END ;Subroutine
 SUBROUTINE populategrouperunsortedreply(dummyvar)
   SET high_volume_cnt = 0
   SELECT INTO "nl:"
    dfr.drc_group_id, dfr.dose_range_check_id, dfr.drc_form_reltn_id,
    dfr.build_flag, dfr.active_ind, drc.dose_range_check_name,
    drc.content_rule_identifier, drc.build_flag, drc.active_ind,
    dp.drc_premise_id, dp.active_ind, dp2.drc_premise_id,
    dp2.premise_type_flag, dp2.relational_operator_flag, dp2.value_unit_cd,
    dp2.value1, dp2.value2, dp2.concept_cki,
    dp2.active_ind, dpl.drc_premise_list_id, dpl.parent_entity_id
    FROM drc_form_reltn dfr,
     dose_range_check drc,
     dummyt d,
     drc_premise dp,
     drc_premise dp2,
     drc_premise_list dpl
    PLAN (dfr
     WHERE parser(parse_drc_grouper_id))
     JOIN (drc
     WHERE drc.dose_range_check_id=dfr.dose_range_check_id
      AND (drc.active_ind=request->active_ind))
     JOIN (d)
     JOIN (dp
     WHERE dp.dose_range_check_id=drc.dose_range_check_id
      AND dp.parent_premise_id=0
      AND dp.active_ind=1)
     JOIN (dp2
     WHERE dp2.parent_premise_id=dp.drc_premise_id
      AND dp2.active_ind=1)
     JOIN (dpl
     WHERE outerjoin(dp2.drc_premise_id)=dpl.drc_premise_id
      AND dpl.active_ind=outerjoin(1))
    ORDER BY drc.dose_range_check_name, dp.drc_premise_id, dp2.premise_type_flag,
     dpl.parent_entity_id
    HEAD REPORT
     ppcnt = 0, pcnt = 0, qualcnt = 0
    HEAD dfr.dose_range_check_id
     ppcnt = 0, qualcnt = (qualcnt+ 1), stat = alterlist(unsortedreply->qual,qualcnt),
     unsortedreply->qual[qualcnt].dose_range_check_id = dfr.dose_range_check_id, unsortedreply->qual[
     qualcnt].drc_form_reltn_id = dfr.drc_form_reltn_id, unsortedreply->qual[qualcnt].
     reltn_build_flag = dfr.build_flag,
     unsortedreply->qual[qualcnt].reltn_active_ind = dfr.active_ind, unsortedreply->qual[qualcnt].
     drc_name = drc.dose_range_check_name, unsortedreply->qual[qualcnt].drc_content_rule_identifier
      = drc.content_rule_identifier,
     unsortedreply->qual[qualcnt].drc_build_flag = drc.build_flag, unsortedreply->qual[qualcnt].
     drc_active_ind = drc.active_ind
    HEAD dp.drc_premise_id
     IF (dp.drc_premise_id > 0.0)
      ppcnt = (ppcnt+ 1), stat = alterlist(unsortedreply->qual[qualcnt].parent_premise,ppcnt), stat
       = alterlist(rows->qual,ppcnt),
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].parent_premise_id = dp.drc_premise_id,
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].active_ind = dp.active_ind, unsortedreply->
      qual[qualcnt].parent_premise[ppcnt].routes_location_flag = 0,
      rows->qual[ppcnt].parent_premise_id = dp.drc_premise_id, pcnt = 0
     ENDIF
     CALL bederrorcheck("Error 001: Error within the head of dp.drc_premise_id")
    HEAD dp2.premise_type_flag
     IF (ppcnt > 0)
      high_volume_cnt = (high_volume_cnt+ 1), pcnt = (pcnt+ 1), stat = alterlist(unsortedreply->qual[
       qualcnt].parent_premise[ppcnt].premise,pcnt)
      IF (dp2.premise_type_flag > 0)
       unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].drc_premise_id = dp2
       .drc_premise_id, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
       premise_type_flag = dp2.premise_type_flag, unsortedreply->qual[qualcnt].parent_premise[ppcnt].
       premise[pcnt].relational_operator_flag = dp2.relational_operator_flag,
       unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value_unit_cd = dp2
       .value_unit_cd, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = dp2
       .value1, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value2 = dp2.value2,
       unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].active_ind = dp2.active_ind
      ELSE
       unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_type_flag = none
      ENDIF
      IF (dp2.premise_type_flag=age)
       CASE (dp2.relational_operator_flag)
        OF less_than:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
        OF greater_than_equal:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
        OF betwn:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,
         CALL direct_to_days(dp2.value2,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age2_to_days = number_of_days
        ELSE
         CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
         CALL bederrorcheck(build("Error 002: Age operator issue for dp2.drc_premise_id of: ",dp2
          .drc_premise_id))
       ENDCASE
      ELSEIF (dp2.premise_type_flag=weight)
       CASE (dp2.relational_operator_flag)
        OF less_than:
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight1_to_kgs = dp2.value1,
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0
        OF greater_than_equal:
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight1_to_kgs = dp2.value1,
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0
        OF betwn:
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight1_to_kgs = dp2.value1,
         unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = dp2.value2
        ELSE
         CALL echo(build("Can't recognize weight relational operator:",dp2.relational_operator_flag))
         CALL bederrorcheck(build("Error 003: Weight operator issue for dp2.drc_premise_id of: ",dp2
          .drc_premise_id))
       ENDCASE
      ELSEIF (dp2.premise_type_flag=pma)
       CASE (dp2.relational_operator_flag)
        OF less_than:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
        OF greater_than_equal:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
        OF betwn:
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,
         CALL direct_to_days(dp2.value2,dp2.value_unit_cd)unsortedreply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age2_to_days = number_of_days
        ELSE
         CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
         CALL bederrorcheck(build("Error 005: PMA operator issue for dp2.drc_premise_id of: ",dp2
          .drc_premise_id))
       ENDCASE
      ENDIF
      plcnt = 0
     ENDIF
    DETAIL
     IF (dp2.premise_type_flag=routes
      AND dpl.drc_premise_id > 0.0
      AND dpl.parent_entity_id > 0.0)
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].routes_location_flag = 1, plcnt = (plcnt+ 1),
      stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes,plcnt),
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].
      drc_premise_list_id = dpl.drc_premise_list_id, unsortedreply->qual[qualcnt].parent_premise[
      ppcnt].premise[pcnt].routes[plcnt].parent_entity_id = dpl.parent_entity_id, unsortedreply->
      qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].route_disp =
      uar_get_code_display(dpl.parent_entity_id),
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].active_ind = dpl
      .active_ind
     ENDIF
    FOOT  dp2.premise_type_flag
     IF (plcnt=0
      AND dp2.premise_type_flag=routes)
      plcnt = 1, stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
       routes,plcnt), unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].
      drc_premise_list_id = unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
      drc_premise_id,
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].parent_entity_id
       = unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1, unsortedreply->
      qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].route_disp =
      uar_get_code_display(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1),
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].active_ind = 1,
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = 0
     ENDIF
    FOOT  dfr.dose_range_check_id
     stat = alterlist(unsortedreply->qual[qualcnt].parent_premise,ppcnt)
    WITH nocounter, outerjoin = d
   ;end select
   IF ((request->skip_volume_check_ind=0))
    IF (high_volume_cnt > 10000)
     SET reply->high_volume_flag = 2
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ELSEIF (high_volume_cnt > 5000)
     SET reply->high_volume_flag = 1
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ENDIF
   ENDIF
   CALL bederrorcheck("Error 006: Error for the main select querry for parent_premise id of: ")
 END ;Subroutine
 SUBROUTINE populatedoseranges(dummyvar)
  SELECT INTO "nl:"
   ddr.drc_premise_id
   FROM (dummyt d1  WITH seq = value(qualcnt)),
    (dummyt d2  WITH seq = 1),
    drc_dose_range ddr,
    long_text lt
   PLAN (d1
    WHERE maxrec(d2,size(unsortedreply->qual[d1.seq].parent_premise,5)))
    JOIN (d2
    WHERE (unsortedreply->qual[d1.seq].parent_premise[d2.seq].parent_premise_id > 0))
    JOIN (ddr
    WHERE parser(dparse)
     AND (ddr.drc_premise_id=unsortedreply->qual[d1.seq].parent_premise[d2.seq].parent_premise_id)
     AND ddr.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(ddr.long_text_id)
     AND lt.active_ind=outerjoin(1))
   ORDER BY ddr.drc_premise_id, ddr.type_flag, ddr.dose_days,
    build(trim(cnvtupper(uar_get_code_display(ddr.value_unit_cd)),7),"          ")
   HEAD ddr.drc_premise_id
    dcnt = 0, hassingle = 0, hasdaily = 0,
    needinsertsingle = 0, needinsertdaily = 0
   HEAD ddr.type_flag
    IF (ddr.type_flag=single)
     hassingle = 1
    ELSE
     IF (ddr.type_flag=daily)
      hasdaily = 1
      IF (hassingle=0)
       needinsertsingle = 1
      ENDIF
     ELSE
      IF (hasdaily=0
       AND hassingle=1)
       needinsertdaily = 1
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1), dcnt = (dcnt+ 1), stat = alterlist(unsortedreply->qual[d1
     .seq].parent_premise[d2.seq].dose_range,dcnt),
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].drc_dose_range_id = ddr
    .drc_dose_range_id, unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].min_value
     = ddr.min_value, unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].max_value
     = ddr.max_value,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].min_value_variance = (ddr
    .min_variance_pct * 100), unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].
    max_value_variance = (ddr.max_variance_pct * 100), unsortedreply->qual[d1.seq].parent_premise[d2
    .seq].dose_range[dcnt].value_unit_cd = ddr.value_unit_cd,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].max_dose = ddr.max_dose,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].max_dose_unit_cd = ddr
    .max_dose_unit_cd, unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].dose_days
     = ddr.dose_days,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].type_flag = ddr.type_flag,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].long_text_id = lt
    .long_text_id, unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].long_text = lt
    .long_text,
    unsortedreply->qual[d1.seq].parent_premise[d2.seq].dose_range[dcnt].active_ind = ddr.active_ind
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 008: Failed to get dose ranges")
 END ;Subroutine
 SUBROUTINE direct_to_days(number,units_code)
   SET number_of_days = 0.0
   IF (units_code=years)
    SET number_of_days = (365.0 * number)
   ELSEIF (units_code=months
    AND number <= 1.0)
    SET number_of_days = 28.0
   ELSEIF (units_code=months
    AND number >= 2.0)
    SET number_of_days = (30.0 * number)
   ELSEIF (units_code=weeks)
    SET number_of_days = (7.0 * number)
   ELSEIF (units_code=days)
    SET number_of_days = number
   ELSEIF (units_code=hours)
    SET number_of_days = (number/ 24.0)
   ELSE
    SET number_of_days = 0.0
   ENDIF
   CALL bederrorcheck("Error 009: Failed to direct to days")
 END ;Subroutine
 SUBROUTINE direct_to_unit(number,units_code)
   SET days_to_unit = 0.0
   IF (units_code=years
    AND number=360.0)
    SET days_to_unit = 1.0
   ELSEIF (units_code=years
    AND number=720.0)
    SET days_to_unit = 2.0
   ELSEIF (units_code=years)
    SET days_to_unit = (number/ 365.0)
   ELSEIF (units_code=months
    AND number=28.0)
    SET days_to_unit = 1.0
   ELSEIF (units_code=months
    AND number >= 30.0)
    SET days_to_unit = (number/ 30.0)
   ELSEIF (units_code=weeks)
    SET days_to_unit = (number/ 7.0)
   ELSEIF (units_code=days)
    SET days_to_unit = number
   ELSEIF (units_code=hours)
    SET days_to_unit = (24.0 * number)
   ELSE
    SET days_to_unit = 0.0
   ENDIF
   CALL bederrorcheck("Error 009: Failed to direct to days")
 END ;Subroutine
 SUBROUTINE populatereplyinsortedorder(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(1)
   DECLARE sorted_pp_index = i4 WITH protect, noconstant(1)
   DECLARE p_list_loop = i4 WITH protect, noconstant(1)
   DECLARE dloop = i4 WITH protect, noconstant(1)
   DECLARE col_cnt = i4 WITH protect, constant(29)
   DECLARE premise_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE dose_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE row_cnt_x = i4 WITH protect, noconstant(0)
   DECLARE row_cnt_y = i2 WITH protect, noconstant(0)
   DECLARE not_match = i2 WITH protect, noconstant(1)
   DECLARE grouper_qual_val = i2 WITH protect, noconstant(0)
   DECLARE from_age = f8 WITH protect, noconstant(0.0)
   DECLARE to_age = f8 WITH protect, noconstant(0.0)
   DECLARE route_flag = i2 WITH protect, noconstant(0)
   DECLARE realvaluestring = vc WITH protect, noconstant("")
   DECLARE afterdecitext = vc WITH protect, noconstant("")
   DECLARE beforedecitext = vc WITH protect, noconstant("")
   IF ((request->skip_volume_check_ind=0))
    IF (high_volume_cnt > 10000)
     SET reply->high_volume_flag = 2
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ELSEIF (high_volume_cnt > 5000)
     SET reply->high_volume_flag = 1
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ENDIF
   ENDIF
   SET stat = alterlist(reply->collist,col_cnt)
   SET reply->collist[1].header_text = "Grouper"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Grouper Status"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "S.No"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Operator"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Age 1"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Age 2"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Age Unit"
   SET reply->collist[7].data_type = 1
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = "PMA Operator"
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
   SET reply->collist[9].header_text = "PMA Age 1"
   SET reply->collist[9].data_type = 1
   SET reply->collist[9].hide_ind = 0
   SET reply->collist[10].header_text = "PMA Age 2"
   SET reply->collist[10].data_type = 1
   SET reply->collist[10].hide_ind = 0
   SET reply->collist[11].header_text = "PMA Age Unit"
   SET reply->collist[11].data_type = 1
   SET reply->collist[11].hide_ind = 0
   SET reply->collist[12].header_text = "CrCl Operator"
   SET reply->collist[12].data_type = 1
   SET reply->collist[12].hide_ind = 0
   SET reply->collist[13].header_text = "CrCl 1"
   SET reply->collist[13].data_type = 1
   SET reply->collist[13].hide_ind = 0
   SET reply->collist[14].header_text = "CrCl 2"
   SET reply->collist[14].data_type = 1
   SET reply->collist[14].hide_ind = 0
   SET reply->collist[15].header_text = "CrCl Unit"
   SET reply->collist[15].data_type = 1
   SET reply->collist[15].hide_ind = 0
   SET reply->collist[16].header_text = "Route"
   SET reply->collist[16].data_type = 1
   SET reply->collist[16].hide_ind = 0
   SET reply->collist[17].header_text = "Weight Range Operator"
   SET reply->collist[17].data_type = 1
   SET reply->collist[17].hide_ind = 0
   SET reply->collist[18].header_text = "Weight 1"
   SET reply->collist[18].data_type = 1
   SET reply->collist[18].hide_ind = 0
   SET reply->collist[19].header_text = "Weight 2"
   SET reply->collist[19].data_type = 1
   SET reply->collist[19].hide_ind = 0
   SET reply->collist[20].header_text = "Weight Unit"
   SET reply->collist[20].data_type = 1
   SET reply->collist[20].hide_ind = 0
   SET reply->collist[21].header_text = "Dose Range Types"
   SET reply->collist[21].data_type = 1
   SET reply->collist[21].hide_ind = 0
   SET reply->collist[22].header_text = "From"
   SET reply->collist[22].data_type = 1
   SET reply->collist[22].hide_ind = 0
   SET reply->collist[23].header_text = "To"
   SET reply->collist[23].data_type = 1
   SET reply->collist[23].hide_ind = 0
   SET reply->collist[24].header_text = "Dose Unit"
   SET reply->collist[24].data_type = 1
   SET reply->collist[24].hide_ind = 0
   SET reply->collist[25].header_text = "Max Dose"
   SET reply->collist[25].data_type = 1
   SET reply->collist[25].hide_ind = 0
   SET reply->collist[26].header_text = "Dose Unit"
   SET reply->collist[26].data_type = 1
   SET reply->collist[26].hide_ind = 0
   SET reply->collist[27].header_text = "Variance From(%)"
   SET reply->collist[27].data_type = 1
   SET reply->collist[27].hide_ind = 0
   SET reply->collist[28].header_text = "Variance To(%)"
   SET reply->collist[28].data_type = 1
   SET reply->collist[28].hide_ind = 0
   SET reply->collist[29].header_text = "Comment"
   SET reply->collist[29].data_type = 1
   SET reply->collist[29].hide_ind = 0
   FOR (cnt = 1 TO size(unsortedreply->qual,5))
    CALL populatereplyafterapplyfilter(cnt)
    IF ((unsortedreply->qual[cnt].drc_active_ind > 0))
     IF (row_cnt_y > row_cnt_x)
      SET row_cnt_x = row_cnt_y
     ELSE
      SET row_cnt_y = row_cnt_x
     ENDIF
     SET row_cnt_x = (row_cnt_x+ 1)
     SET stat = alterlist(reply->rowlist,row_cnt_x)
     SET stat = alterlist(reply->rowlist[row_cnt_x].celllist,col_cnt)
     SET reply->rowlist[row_cnt_x].celllist[1].string_value = build2(reply->rowlist[row_cnt_x].
      celllist[1].string_value,unsortedreply->qual[cnt].drc_name)
     IF ((request->active_ind=1))
      SET reply->rowlist[row_cnt_x].celllist[2].string_value = "Active"
     ELSE
      SET reply->rowlist[row_cnt_x].celllist[2].string_value = "Inactive"
     ENDIF
     SET index = 0
     FOR (pploop = 1 TO size(unsortedreply->qual[cnt].parent_premise,5))
       IF ((unsortedreply->qual[cnt].parent_premise[pploop].active_ind=1)
        AND size(unsortedreply->qual[cnt].parent_premise[pploop].dose_range,5) > 0)
        SET index = (index+ 1)
        SET row_cnt_y = (row_cnt_y+ 1)
        SET stat = alterlist(reply->rowlist,row_cnt_y)
        SET stat = alterlist(reply->rowlist[row_cnt_y].celllist,col_cnt)
        FOR (ploop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].premise,5))
          SET reply->rowlist[row_cnt_y].celllist[3].string_value = trim(cnvtstring(index))
          IF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=age))
           CASE (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
           relational_operator_flag)
            OF less_than:
             SET reply->rowlist[row_cnt_y].celllist[4].string_value = "<"
            OF greater_than_equal:
             SET reply->rowlist[row_cnt_y].celllist[4].string_value = ">="
            OF betwn:
             SET reply->rowlist[row_cnt_y].celllist[4].string_value = "Between"
           ENDCASE
           CALL direct_to_unit(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
            age1_to_days,unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd
            )
           CALL processrealnumbertorealstring(days_to_unit)
           SET reply->rowlist[row_cnt_y].celllist[5].string_value = realvaluestring
           CALL direct_to_unit(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
            age2_to_days,unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd
            )
           CALL processrealnumbertorealstring(days_to_unit)
           SET reply->rowlist[row_cnt_y].celllist[6].string_value = realvaluestring
           SET reply->rowlist[row_cnt_y].celllist[7].string_value = uar_get_code_display(
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd)
          ELSEIF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=
          pma))
           CASE (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
           relational_operator_flag)
            OF less_than:
             SET reply->rowlist[row_cnt_y].celllist[8].string_value = "<"
            OF greater_than_equal:
             SET reply->rowlist[row_cnt_y].celllist[8].string_value = ">="
            OF betwn:
             SET reply->rowlist[row_cnt_y].celllist[8].string_value = "Between"
           ENDCASE
           CALL direct_to_unit(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
            age1_to_days,unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd
            )
           CALL processrealnumbertorealstring(days_to_unit)
           SET reply->rowlist[row_cnt_y].celllist[9].string_value = realvaluestring
           CALL direct_to_unit(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
            age2_to_days,unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd
            )
           CALL processrealnumbertorealstring(days_to_unit)
           SET reply->rowlist[row_cnt_y].celllist[10].string_value = realvaluestring
           SET reply->rowlist[row_cnt_y].celllist[11].string_value = uar_get_code_display(
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd)
          ELSEIF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=
          weight))
           CASE (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
           relational_operator_flag)
            OF less_than:
             SET reply->rowlist[row_cnt_y].celllist[17].string_value = "<"
            OF greater_than_equal:
             SET reply->rowlist[row_cnt_y].celllist[17].string_value = ">="
            OF betwn:
             SET reply->rowlist[row_cnt_y].celllist[17].string_value = "Between"
           ENDCASE
           CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
            premise[ploop].weight1_to_kgs)
           SET reply->rowlist[row_cnt_y].celllist[18].string_value = realvaluestring
           CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
            premise[ploop].weight2_to_kgs)
           SET reply->rowlist[row_cnt_y].celllist[19].string_value = realvaluestring
           SET reply->rowlist[row_cnt_y].celllist[20].string_value = uar_get_code_display(
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd)
          ELSEIF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=
          crcl))
           CASE (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
           relational_operator_flag)
            OF less_than:
             SET reply->rowlist[row_cnt_y].celllist[12].string_value = "<"
            OF betwn:
             SET reply->rowlist[row_cnt_y].celllist[12].string_value = "Between"
           ENDCASE
           CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
            premise[ploop].value1)
           SET reply->rowlist[row_cnt_y].celllist[13].string_value = realvaluestring
           CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
            premise[ploop].value2)
           SET reply->rowlist[row_cnt_y].celllist[14].string_value = realvaluestring
           SET reply->rowlist[row_cnt_y].celllist[15].string_value = uar_get_code_display(
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd)
          ENDIF
          IF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=
          routes))
           FOR (p_list_loop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop
            ].routes,5))
             SET reply->rowlist[row_cnt_y].celllist[16].string_value = build(reply->rowlist[row_cnt_y
              ].celllist[16].string_value,concat(" ",unsortedreply->qual[cnt].parent_premise[pploop].
               premise[ploop].routes[p_list_loop].route_disp),",")
           ENDFOR
           SET reply->rowlist[row_cnt_y].celllist[16].string_value = replace(reply->rowlist[row_cnt_y
            ].celllist[16].string_value,",","",2)
           SET reply->rowlist[row_cnt_y].celllist[16].string_value = replace(reply->rowlist[row_cnt_y
            ].celllist[16].string_value," ","",1)
          ENDIF
        ENDFOR
        FOR (dloop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].dose_range,5))
          CASE (unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].type_flag)
           OF single:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "SINGLE"
           OF daily:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "DAILY"
           OF therapy:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "THERAPY"
           OF ndays:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = build(unsortedreply->qual[cnt].
             parent_premise[pploop].dose_range[dloop].dose_days," DAYS")
           OF na:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "NA"
           OF continuous:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "CONTINUOUS"
           OF lifetime:
            SET reply->rowlist[row_cnt_y].celllist[21].string_value = "LIFETIME"
          ENDCASE
          CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
           dose_range[dloop].min_value)
          SET reply->rowlist[row_cnt_y].celllist[22].string_value = realvaluestring
          CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
           dose_range[dloop].max_value)
          SET reply->rowlist[row_cnt_y].celllist[23].string_value = realvaluestring
          SET reply->rowlist[row_cnt_y].celllist[24].string_value = uar_get_code_display(
           unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].value_unit_cd)
          CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
           dose_range[dloop].max_dose)
          SET reply->rowlist[row_cnt_y].celllist[25].string_value = realvaluestring
          SET reply->rowlist[row_cnt_y].celllist[26].string_value = uar_get_code_display(
           unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].max_dose_unit_cd)
          CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
           dose_range[dloop].min_value_variance)
          SET reply->rowlist[row_cnt_y].celllist[27].string_value = realvaluestring
          CALL processrealnumbertorealstring(unsortedreply->qual[cnt].parent_premise[pploop].
           dose_range[dloop].max_value_variance)
          SET reply->rowlist[row_cnt_y].celllist[28].string_value = realvaluestring
          SET reply->rowlist[row_cnt_y].celllist[29].string_value = unsortedreply->qual[cnt].
          parent_premise[pploop].dose_range[dloop].long_text
          IF (dloop < size(unsortedreply->qual[cnt].parent_premise[pploop].dose_range,5))
           SET row_cnt_y = (row_cnt_y+ 1)
           SET stat = alterlist(reply->rowlist,row_cnt_y)
           SET stat = alterlist(reply->rowlist[row_cnt_y].celllist,col_cnt)
          ENDIF
        ENDFOR
        CALL bederrorcheck("Error 013: Error while populating the premises in the reply")
       ENDIF
     ENDFOR
     CALL bederrorcheck("Error 014: Error while populating the grouper related stuff in the reply")
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatereplyafterapplyfilter(qualcnt)
   SET grouper_qual_val = 0
   SET route_flag = 1
   FOR (pploop = 1 TO size(unsortedreply->qual[qualcnt].parent_premise,5))
     SET not_match = 1
     FOR (ploop = 1 TO size(unsortedreply->qual[qualcnt].parent_premise[pploop].premise,5))
      IF (size(request->age,5) > 0)
       FOR (aloop = 1 TO size(request->age,5))
         IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].premise_type_flag=
         age)
          AND (request->age[aloop].age_grp_typ=age))
          CASE (request->age[aloop].operator)
           OF less_than:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days <
            number_of_days))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             > 0)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days <
            number_of_days))
             SET not_match = 0
            ENDIF
           OF greater_than_equal:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days >=
            number_of_days))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             >= number_of_days))
             SET not_match = 0
            ENDIF
           OF betwn:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            SET from_age = number_of_days
            CALL direct_to_days(request->age[aloop].to,request->age[aloop].unit)
            SET to_age = number_of_days
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days >=
            from_age)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days <=
            to_age))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             > from_age)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days <
            to_age))
             SET not_match = 0
            ENDIF
          ENDCASE
         ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].
         premise_type_flag=pma)
          AND (request->age[aloop].age_grp_typ=pma))
          CASE (request->age[aloop].operator)
           OF less_than:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days <
            number_of_days))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             > 0)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days <
            number_of_days))
             SET not_match = 0
            ENDIF
           OF greater_than_equal:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days >=
            number_of_days))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             >= number_of_days))
             SET not_match = 0
            ENDIF
           OF betwn:
            CALL direct_to_days(request->age[aloop].from,request->age[aloop].unit)
            SET from_age = number_of_days
            CALL direct_to_days(request->age[aloop].to,request->age[aloop].unit)
            SET to_age = number_of_days
            IF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days >=
            from_age)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age1_to_days <=
            to_age))
             SET not_match = 0
            ELSEIF ((unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days
             > from_age)
             AND (unsortedreply->qual[qualcnt].parent_premise[pploop].premise[ploop].age2_to_days <
            to_age))
             SET not_match = 0
            ENDIF
          ENDCASE
         ENDIF
       ENDFOR
      ELSE
       SET not_match = 0
      ENDIF
      IF (size(request->routes_list,5) > 0
       AND (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=routes))
       SET route_flag = 1
       FOR (rloop = 1 TO size(request->routes_list,5))
         IF (route_flag > 0)
          SET route_flag = locateval(p_list_loop,1,size(unsortedreply->qual[cnt].parent_premise[
            pploop].premise[ploop].routes,5),request->routes_list[rloop].route_id,unsortedreply->
           qual[cnt].parent_premise[pploop].premise[ploop].routes[p_list_loop].parent_entity_id)
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
     IF (((not_match > 0) OR (((route_flag=0) OR (size(unsortedreply->qual[qualcnt].parent_premise[
      pploop].dose_range,5)=0)) )) )
      SET unsortedreply->qual[qualcnt].parent_premise[pploop].active_ind = 0
     ELSE
      SET grouper_qual_val = 1
     ENDIF
   ENDFOR
   SET unsortedreply->qual[cnt].drc_active_ind = grouper_qual_val
 END ;Subroutine
 SUBROUTINE processrealnumbertorealstring(days)
   DECLARE last = i4 WITH protect
   DECLARE pos = i4 WITH protect
   SET realvaluestring = ""
   SET afterdecitext = ""
   SET beforedecitext = ""
   SET pos = 0
   IF (days > 0)
    SET realvaluestring = cnvtstring(days,11,5)
    SET pos = findstring(".",realvaluestring,1,1)
    SET afterdecitext = substring((pos+ 1),5,realvaluestring)
    SET last = findstring("0",afterdecitext,1,1)
    CALL recursiverealnumbertostringconversion(0)
    IF (textlen(trim(afterdecitext)) > 0)
     SET beforedecitext = substring(1,pos,realvaluestring)
     SET realvaluestring = concat(beforedecitext,afterdecitext)
    ELSE
     SET beforedecitext = substring(1,pos,realvaluestring)
     SET realvaluestring = replace(beforedecitext,".","",2)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE recursiverealnumbertostringconversion(dummyvar)
   DECLARE aftertextlen = i4 WITH protect, noconstant(0)
   SET aftertextlen = textlen(trim(afterdecitext))
   IF (aftertextlen > 0)
    SET last = findstring("0",afterdecitext,1,1)
    IF (last=aftertextlen)
     SET afterdecitext = replace(afterdecitext,"0","",2)
     CALL recursiverealnumbertostringconversion(0)
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_dose_range_report.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
