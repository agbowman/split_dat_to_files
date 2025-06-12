CREATE PROGRAM bed_ens_cpy_drc_grouper_to_fac:dba
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
 DECLARE insert_flag = i2 WITH protect, constant(1)
 DECLARE pp_count = i4 WITH protect, noconstant(0)
 DECLARE pp_index = i4 WITH protect, noconstant(0)
 DECLARE p_count = i4 WITH protect, noconstant(0)
 DECLARE premise_cnt = i4 WITH protect, noconstant(0)
 DECLARE p_index = i4 WITH protect, noconstant(0)
 DECLARE route_count = i4 WITH protect, noconstant(0)
 DECLARE route_index = i4 WITH protect, noconstant(0)
 DECLARE dr_count = i4 WITH protect, noconstant(0)
 DECLARE dr_index = i4 WITH protect, noconstant(0)
 DECLARE facility_count = i4 WITH protect, noconstant(0)
 DECLARE facility_index = i4 WITH protect, noconstant(0)
 DECLARE new_dose_range_check_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_drc_form_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE get_next_seq(seq_name=vc) = f8
 DECLARE preparecontentensurerequest(dummyvar=i2) = null
 DECLARE resetensurerequesttoinsertstate(dummyvar=i2) = null
 DECLARE createdoserangecheckentriesandassociations(facility_index=i4) = null
 IF ( NOT (validate(getrequest,0)))
  RECORD getrequest(
    1 drc_group_id = f8
    1 dose_range_check_id = f8
  )
 ENDIF
 IF ( NOT (validate(getreply,0)))
  RECORD getreply(
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
          4 value_unit_display = c40
          4 value1 = f8
          4 value2 = f8
          4 age1_to_days = f8
          4 age2_to_days = f8
          4 weight1_to_kgs = f8
          4 weight2_to_kgs = f8
          4 active_ind = i2
          4 has_overlap = i2
          4 has_gap = i2
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
          4 value_unit_display = c40
          4 max_dose = f8
          4 max_dose_unit_cd = f8
          4 max_dose_unit_display = c40
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
 IF ( NOT (validate(ensrequest,0)))
  RECORD ensrequest(
    1 groupers[*]
      2 dose_range_check_id = f8
      2 parent_premises[*]
        3 parent_premise_id = f8
        3 premises[*]
          4 action_flag = i2
          4 premise_id = f8
          4 premise_type_flag = i2
          4 value1 = f8
          4 value2 = f8
          4 value_unit_cd = f8
          4 value_string = vc
          4 operator_flag = i2
        3 routes[*]
          4 route_cd = f8
        3 dose_ranges[*]
          4 dose_range_id = f8
          4 action_flag = i2
          4 min_value = f8
          4 max_value = f8
          4 dose_unit_cd = f8
          4 max_dose = f8
          4 max_dose_unit_cd = f8
          4 min_variance = f8
          4 max_variance = f8
          4 dose_days = i4
          4 dose_type = i2
          4 long_text_id = f8
          4 comment_text = vc
  )
 ENDIF
 SET getrequest->dose_range_check_id = request->dose_range_check_id
 EXECUTE bed_get_drc_group  WITH replace("REQUEST",getrequest), replace("REPLY",getreply)
 CALL preparecontentensurerequest(0)
 SET facility_count = size(request->facilities,5)
 FOR (facility_index = 1 TO facility_count)
   CALL createdoserangecheckentriesandassociations(facility_index)
   CALL resetensurerequesttoinsertstate(0)
   SET ensrequest->groupers[1].dose_range_check_id = new_dose_range_check_id
   EXECUTE bed_ens_drc_groups  WITH replace("REQUEST",ensrequest)
 ENDFOR
 CALL echorecord(ensrequest)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE get_next_seq(seq_name)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = cnvtreal(number)
    WITH format, counter
   ;end select
   RETURN(next_seq)
 END ;Subroutine
 SUBROUTINE createdoserangecheckentriesandassociations(facility_index)
   SET new_dose_range_check_id = get_next_seq("drc_seq")
   INSERT  FROM dose_range_check drc
    SET drc.dose_range_check_id = new_dose_range_check_id, drc.dose_range_check_name = trim(getreply
      ->qual[1].drc_name), drc.build_flag = 2,
     drc.active_ind = getreply->qual[1].drc_active_ind, drc.updt_applctx = reqinfo->updt_applctx, drc
     .updt_cnt = 0,
     drc.updt_dt_tm = cnvtdatetime(curdate,curtime3), drc.updt_id = reqinfo->updt_id, drc.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL insert_version_row_dose_range_check_ver_table(new_dose_range_check_id)
   SET new_drc_form_reltn_id = get_next_seq("drc_seq")
   INSERT  FROM drc_form_reltn dfr
    SET dfr.drc_form_reltn_id = new_drc_form_reltn_id, dfr.drc_group_id = request->drc_group_id, dfr
     .dose_range_check_id = new_dose_range_check_id,
     dfr.build_flag = 2, dfr.active_ind = getreply->qual[1].reltn_active_ind, dfr.updt_applctx =
     reqinfo->updt_applctx,
     dfr.updt_cnt = 0, dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfr.updt_id = reqinfo->
     updt_id,
     dfr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL insert_version_row_drc_form_reltn_ver_table(new_drc_form_reltn_id)
   SET new_drc_facility_r_id = get_next_seq("reference_seq")
   INSERT  FROM drc_facility_r dfr
    SET dfr.facility_cd = request->facilities[facility_index].facility_cd, dfr.drc_group_id = request
     ->drc_group_id, dfr.drc_facility_r_id = new_drc_facility_r_id,
     dfr.dose_range_check_id = new_dose_range_check_id, dfr.active_ind = 1, dfr.updt_applctx =
     reqinfo->updt_applctx,
     dfr.updt_cnt = 0, dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfr.updt_id = reqinfo->
     updt_id,
     dfr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL insert_version_row_drc_facility_r_ver_table(new_drc_facility_r_id)
 END ;Subroutine
 SUBROUTINE preparecontentensurerequest(dummyvar)
   SET stat = alterlist(ensrequest->groupers,1)
   SET pp_count = size(getreply->qual[1].parent_premise,5)
   SET stat = alterlist(ensrequest->groupers[1].parent_premises,pp_count)
   FOR (pp_index = 1 TO pp_count)
     SET ensrequest->groupers[1].parent_premises[pp_index].parent_premise_id = 0.0
     SET p_count = size(getreply->qual[1].parent_premise[pp_index].premise,5)
     SET stat = alterlist(ensrequest->groupers[1].parent_premises[pp_index].premises,(p_count - 1))
     SET premise_cnt = 1
     FOR (p_index = 1 TO p_count)
       IF (size(getreply->qual[1].parent_premise[pp_index].premise[p_index].routes,5) > 0)
        SET route_count = size(getreply->qual[1].parent_premise[pp_index].premise[p_index].routes,5)
        SET stat = alterlist(ensrequest->groupers[1].parent_premises[pp_index].routes,route_count)
        FOR (route_index = 1 TO route_count)
          SET ensrequest->groupers[1].parent_premises[pp_index].routes[route_index].route_cd =
          getreply->qual[1].parent_premise[pp_index].premise[p_index].routes[route_index].
          parent_entity_id
        ENDFOR
       ELSE
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].action_flag =
        insert_flag
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].premise_id = 0.0
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].premise_type_flag
         = getreply->qual[1].parent_premise[pp_index].premise[p_index].premise_type_flag
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].operator_flag =
        getreply->qual[1].parent_premise[pp_index].premise[p_index].relational_operator_flag
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].value1 = getreply
        ->qual[1].parent_premise[pp_index].premise[p_index].value1
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].value2 = getreply
        ->qual[1].parent_premise[pp_index].premise[p_index].value2
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].value_unit_cd =
        getreply->qual[1].parent_premise[pp_index].premise[p_index].value_unit_cd
        SET ensrequest->groupers[1].parent_premises[pp_index].premises[premise_cnt].value_string =
        getreply->qual[1].parent_premise[pp_index].premise[p_index].concept_cki
        SET premise_cnt = (premise_cnt+ 1)
       ENDIF
     ENDFOR
     SET dr_count = size(getreply->qual[1].parent_premise[pp_index].dose_range,5)
     SET stat = alterlist(ensrequest->groupers[1].parent_premises[pp_index].dose_ranges,dr_count)
     FOR (dr_index = 1 TO dr_count)
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].action_flag =
       insert_flag
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].dose_range_id =
       0.0
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].long_text_id = 0.0
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].min_value =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].min_value
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].max_value =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].max_value
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].dose_unit_cd =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].value_unit_cd
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].max_dose =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].max_dose
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].max_dose_unit_cd
        = getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].max_dose_unit_cd
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].min_variance = (
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].min_value_variance/ 100)
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].max_variance = (
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].max_value_variance/ 100)
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].dose_days =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].dose_days
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].dose_type =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].type_flag
       SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].comment_text =
       getreply->qual[1].parent_premise[pp_index].dose_range[dr_index].long_text
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE resetensurerequesttoinsertstate(dummyvar)
  SET pp_count = size(ensrequest->groupers[1].parent_premises,5)
  FOR (pp_index = 1 TO pp_count)
    SET ensrequest->groupers[1].parent_premises[pp_index].parent_premise_id = 0.0
    SET p_count = size(ensrequest->groupers[1].parent_premises[pp_index].premises,5)
    FOR (p_index = 1 TO p_count)
     SET ensrequest->groupers[1].parent_premises[pp_index].premises[p_count].action_flag =
     insert_flag
     SET ensrequest->groupers[1].parent_premises[pp_index].premises[p_count].premise_id = 0.0
    ENDFOR
    SET dr_count = size(ensrequest->groupers[1].parent_premises[pp_index].dose_ranges,5)
    FOR (dr_index = 1 TO dr_count)
      SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].action_flag =
      insert_flag
      SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].dose_range_id = 0.0
      SET ensrequest->groupers[1].parent_premises[pp_index].dose_ranges[dr_index].long_text_id = 0.0
    ENDFOR
  ENDFOR
 END ;Subroutine
END GO
