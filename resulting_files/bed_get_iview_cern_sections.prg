CREATE PROGRAM bed_get_iview_cern_sections
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sections[*]
      2 wv_section_uid = vc
      2 wv_sectoin_name = vc
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
 FREE RECORD sectionswithassays
 RECORD sectionswithassays(
   1 sections[*]
     2 wv_section_uid = vc
     2 wv_sectoin_name = vc
     2 assays[*]
       3 task_assay_uid = vc
 )
 FREE RECORD assaysrequest
 RECORD assaysrequest(
   1 assays[*]
     2 task_assay_uid = vc
     2 bailoutind = i2
   1 get_interps_ind = i2
   1 form_uid = vc
 )
 FREE RECORD assaysreply
 RECORD assaysreply(
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
 DECLARE sectioncnt = i4 WITH noconstant(0), protect
 DECLARE getsectionswithassays(dummyvar=i2) = null
 DECLARE identifywhethersectionhasassaydifferences(dummyvar=i2) = null
 CALL getsectionswithassays(0)
 CALL identifywhethersectionhasassaydifferences(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getsectionswithassays(dummyvar)
   CALL bedlogmessage("getSectionsWithAssays","Entering ...")
   DECLARE assaycnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM cnt_wv_section_r s,
     cnt_wv_section_key sk,
     cnt_wv_section_item_r ir,
     cnt_wv_item_key ik,
     cnt_wv_item_dta dta
    PLAN (s
     WHERE (s.working_view_uid=request->working_view_uid))
     JOIN (sk
     WHERE sk.wv_section_uid=s.wv_section_uid)
     JOIN (ir
     WHERE ir.wv_section_uid=s.wv_section_uid)
     JOIN (ik
     WHERE ik.wv_item_uid=ir.wv_item_uid)
     JOIN (dta
     WHERE dta.wv_item_uid=outerjoin(ik.wv_item_uid))
    ORDER BY s.wv_section_uid, ik.task_assay_guid, dta.task_assay_uid
    HEAD s.wv_section_uid
     assaycnt = 0
     IF (((ik.task_assay_guid > " ") OR (dta.task_assay_uid > " ")) )
      sectioncnt = (sectioncnt+ 1), stat = alterlist(sectionswithassays->sections,sectioncnt),
      sectionswithassays->sections[sectioncnt].wv_section_uid = s.wv_section_uid,
      sectionswithassays->sections[sectioncnt].wv_sectoin_name = sk.event_set_name
     ENDIF
    HEAD ik.task_assay_guid
     IF (ik.task_assay_guid > " ")
      assaycnt = (assaycnt+ 1), stat = alterlist(sectionswithassays->sections[sectioncnt].assays,
       assaycnt), sectionswithassays->sections[sectioncnt].assays[assaycnt].task_assay_uid = ik
      .task_assay_guid
     ENDIF
    HEAD dta.task_assay_uid
     IF (dta.cnt_wv_item_dta_id > 0)
      assaycnt = (assaycnt+ 1), stat = alterlist(sectionswithassays->sections[sectioncnt].assays,
       assaycnt), sectionswithassays->sections[sectioncnt].assays[assaycnt].task_assay_uid = dta
      .task_assay_uid
     ENDIF
    WITH nocounter
   ;end select
   CALL getrepeatablegrouplabelassays(0)
   CALL echorecord(sectionswithassays)
   CALL bedlogmessage("getSectionsWithAssays","Exiting ...")
 END ;Subroutine
 SUBROUTINE getrepeatablegrouplabelassays(dummyvar)
   CALL bedlogmessage("getRepeatableGroupLabelAssays","Entering ...")
   DECLARE aidx = i4 WITH protect, noconstant(0)
   DECLARE assaycnt = i4 WITH protect, noconstant(0)
   FREE RECORD repgrouprequest
   RECORD repgrouprequest(
     1 working_view_uid = vc
   )
   RECORD repgroupreply(
     1 assays[*]
       2 task_assay_uid = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET repgrouprequest->working_view_uid = request->working_view_uid
   EXECUTE bed_get_iview_cern_rep_groups  WITH replace("REQUEST",repgrouprequest), replace("REPLY",
    repgroupreply)
   IF (size(repgroupreply->assays,5) > 0)
    SET sectioncnt = (sectioncnt+ 1)
    SET stat = alterlist(sectionswithassays->sections,sectioncnt)
    SET sectionswithassays->sections[sectioncnt].wv_sectoin_name =
    "Label Assays for Repeatable Groups"
    FOR (aidx = 1 TO size(repgroupreply->assays,5))
      SET assaycnt = (assaycnt+ 1)
      SET stat = alterlist(sectionswithassays->sections[sectioncnt].assays,assaycnt)
      SET sectionswithassays->sections[sectioncnt].assays[assaycnt].task_assay_uid = repgroupreply->
      assays[aidx].task_assay_uid
    ENDFOR
   ENDIF
   CALL bedlogmessage("getRepeatableGroupLabelAssays","Exiting ...")
 END ;Subroutine
 SUBROUTINE identifywhethersectionhasassaydifferences(dummyvar)
   CALL bedlogmessage("identifyWhetherSectionHasAssayDifferences","Entering ...")
   DECLARE sidx = i4 WITH protect, noconstant(0)
   DECLARE aidx = i4 WITH protect, noconstant(1)
   DECLARE sectioncnt = i4 WITH protect, noconstant(0)
   FOR (sidx = 1 TO size(sectionswithassays->sections,5))
     SET stat = initrec(assaysreply)
     WHILE (aidx <= size(sectionswithassays->sections[sidx].assays,5)
      AND (assaysreply->assays[1].modified_status != "M")
      AND (assaysreply->assays[1].modified_status != "A"))
       SET stat = initrec(assaysreply)
       SET stat = alterlist(assaysrequest->assays,1)
       SET assaysrequest->assays[1].task_assay_uid = sectionswithassays->sections[sidx].assays[aidx].
       task_assay_uid
       SET assaysrequest->assays[1].bailoutind = true
       SET assaysrequest->get_interps_ind = false
       CALL echorecord(assaysrequest)
       EXECUTE bed_get_pwrform_cern_assays  WITH replace("REQUEST",assaysrequest), replace("REPLY",
        assaysreply)
       IF ((((assaysreply->assays[1].modified_status="M")) OR ((assaysreply->assays[1].
       modified_status="A"))) )
        SET sectioncnt = (sectioncnt+ 1)
        SET stat = alterlist(reply->sections,sectioncnt)
        SET reply->sections[sectioncnt].wv_section_uid = sectionswithassays->sections[sidx].
        wv_section_uid
        SET reply->sections[sectioncnt].wv_sectoin_name = sectionswithassays->sections[sidx].
        wv_sectoin_name
       ENDIF
       SET aidx = (aidx+ 1)
     ENDWHILE
     SET aidx = 1
   ENDFOR
   CALL bedlogmessage("identifyWhetherSectionHasAssayDifferences","Exiting ...")
 END ;Subroutine
END GO
