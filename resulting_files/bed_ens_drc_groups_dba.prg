CREATE PROGRAM bed_ens_drc_groups:dba
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
 FREE RECORD routesrequest
 RECORD routesrequest(
   1 premises[*]
     2 drc_premise_id = f8
     2 location_flag = i2
   1 routes[*]
     2 route_code_value = f8
     2 route_display = vc
     2 action_flag = i2
   1 dose_range_check_id = f8
   1 parent_premise_id = f8
 )
 IF ( NOT (validate(routesreply,0)))
  RECORD routesreply(
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
 DECLARE insert_version_row_drc_prem_ver_table(drc_premise_id=f8) = null
 DECLARE insert_version_row_drc_prem_list_ver_table(drc_premise_id=f8,code_value=f8) = null
 DECLARE insert_version_row_drc_dose_range_ver_table(drc_dose_range_id=f8) = null
 DECLARE insert_version_row_drc_form_reltn_ver_table(drc_form_reltn_id=f8) = null
 DECLARE insert_version_row_dose_range_check_ver_table(dose_range_check_id=f8) = null
 DECLARE insert_version_row_drc_facility_r_ver_table(drc_facility_r_id=f8) = null
 DECLARE insert_ver_row_dose_range_after_premise_update(premise_id=f8) = null
 SUBROUTINE insert_version_row_drc_prem_ver_table(drc_premise_id)
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   FREE RECORD temp_prem
   RECORD temp_prem(
     1 dose_range_check_id = f8
     1 multum_case_id = f8
     1 parent_premise_id = f8
     1 premise_type_flag = i2
     1 relational_operator_flag = i2
     1 value1 = f8
     1 value1_string = vc
     1 value2 = f8
     1 value2_string = vc
     1 value_type_flag = i2
     1 value_unit_cd = f8
     1 concept_cki = vc
     1 active_ind = i2
     1 parent_ind = i2
   )
   SELECT INTO "nl:"
    dp.parent_premise_id, dp.dose_range_check_id
    FROM drc_premise dp
    WHERE dp.drc_premise_id=drc_premise_id
    DETAIL
     temp_prem->dose_range_check_id = dp.dose_range_check_id, temp_prem->multum_case_id = dp
     .multum_case_id, temp_prem->parent_premise_id = dp.parent_premise_id,
     temp_prem->premise_type_flag = dp.premise_type_flag, temp_prem->relational_operator_flag = dp
     .relational_operator_flag, temp_prem->value1 = dp.value1,
     temp_prem->value1_string = dp.value1_string, temp_prem->value2 = dp.value2, temp_prem->
     value2_string = dp.value2_string,
     temp_prem->value_type_flag = dp.value_type_flag, temp_prem->value_unit_cd = dp.value_unit_cd,
     temp_prem->concept_cki = dp.concept_cki,
     temp_prem->parent_ind = dp.parent_ind, temp_prem->active_ind = dp.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error001: while selecting a row from drc_premise table to be versioned.")
   SET v_ver_seq = 1
   SELECT INTO "NL:"
    FROM drc_premise_ver dpv
    WHERE dpv.drc_premise_id=drc_premise_id
     AND (dpv.parent_ind=temp_prem->parent_ind)
    FOOT REPORT
     v_ver_seq = (max(dpv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error002: while selecting the next_seq for drc_premise_ver.")
   INSERT  FROM drc_premise_ver dpv
    SET dpv.drc_premise_id = drc_premise_id, dpv.parent_premise_id = temp_prem->parent_premise_id,
     dpv.dose_range_check_id = temp_prem->dose_range_check_id,
     dpv.parent_ind = temp_prem->parent_ind, dpv.premise_type_flag = temp_prem->premise_type_flag,
     dpv.relational_operator_flag = temp_prem->relational_operator_flag,
     dpv.value_type_flag = temp_prem->value_type_flag, dpv.value_unit_cd = temp_prem->value_unit_cd,
     dpv.value1 = temp_prem->value1,
     dpv.value1_string = temp_prem->value1_string, dpv.value2 = temp_prem->value2, dpv.value2_string
      = temp_prem->value2_string,
     dpv.active_ind = temp_prem->active_ind, dpv.multum_case_id = temp_prem->multum_case_id, dpv
     .ver_seq = v_ver_seq,
     dpv.concept_cki = temp_prem->concept_cki, dpv.updt_applctx = reqinfo->updt_applctx, dpv.updt_cnt
      = 0,
     dpv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpv.updt_id = reqinfo->updt_id, dpv.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error003: while inserting a version row on drc_premise_ver table.")
 END ;Subroutine
 SUBROUTINE insert_version_row_drc_prem_list_ver_table(drc_premise_id,code_value)
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   FREE SET temp_prem_list
   RECORD temp_prem_list(
     1 active_ind = i2
     1 drc_premise_list_id = f8
     1 parent_entity_id = f8
   )
   SELECT INTO "NL:"
    FROM drc_premise_list dpl
    WHERE dpl.parent_entity_id=code_value
     AND dpl.drc_premise_id=drc_premise_id
     AND dpl.parent_entity_name="CODE_VALUE"
    DETAIL
     temp_prem_list->active_ind = dpl.active_ind, temp_prem_list->drc_premise_list_id = dpl
     .drc_premise_list_id, temp_prem_list->parent_entity_id = dpl.parent_entity_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error004: while selecting a row from drc_premise_list table to be versioned.")
   SET v_ver_seq = 1
   SELECT INTO "nl:"
    FROM drc_premise_list_ver dplv
    WHERE (dplv.drc_premise_list_id=temp_prem_list->drc_premise_list_id)
    FOOT REPORT
     v_ver_seq = (max(dplv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error005: while selecting the next_seq for drc_premise_list_ver.")
   INSERT  FROM drc_premise_list_ver dplv
    SET dplv.drc_premise_list_id = temp_prem_list->drc_premise_list_id, dplv.drc_premise_id =
     drc_premise_id, dplv.parent_entity_name = "CODE_VALUE",
     dplv.parent_entity_id = temp_prem_list->parent_entity_id, dplv.active_ind = temp_prem_list->
     active_ind, dplv.ver_seq = v_ver_seq,
     dplv.updt_applctx = reqinfo->updt_applctx, dplv.updt_cnt = 0, dplv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     dplv.updt_id = reqinfo->updt_id, dplv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error006: while inserting a version row into drc_premise_list_ver table.")
 END ;Subroutine
 SUBROUTINE insert_version_row_drc_dose_range_ver_table(drc_dose_range_id)
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   FREE RECORD temp_drc_dose_ranges_ver
   RECORD temp_drc_dose_ranges_ver(
     1 drc_dose_range_id = f8
     1 drc_premise_id = f8
     1 min_value = f8
     1 max_value = f8
     1 min_value_variance = f8
     1 max_value_variance = f8
     1 value_unit_cd = f8
     1 max_dose = f8
     1 max_dose_unit_cd = f8
     1 dose_days = i4
     1 type_flag = i2
     1 long_text_id = f8
     1 active_ind = i2
   )
   SELECT INTO "NL:"
    FROM drc_dose_range ddr
    WHERE ddr.drc_dose_range_id=drc_dose_range_id
    DETAIL
     temp_drc_dose_ranges_ver->active_ind = ddr.active_ind, temp_drc_dose_ranges_ver->drc_premise_id
      = ddr.drc_premise_id, temp_drc_dose_ranges_ver->drc_dose_range_id = ddr.drc_dose_range_id,
     temp_drc_dose_ranges_ver->min_value = ddr.min_value, temp_drc_dose_ranges_ver->max_value = ddr
     .max_value, temp_drc_dose_ranges_ver->min_value_variance = ddr.min_variance_pct,
     temp_drc_dose_ranges_ver->max_value_variance = ddr.max_variance_pct, temp_drc_dose_ranges_ver->
     value_unit_cd = ddr.value_unit_cd, temp_drc_dose_ranges_ver->max_dose = ddr.max_dose,
     temp_drc_dose_ranges_ver->max_dose_unit_cd = ddr.max_dose_unit_cd, temp_drc_dose_ranges_ver->
     dose_days = ddr.dose_days, temp_drc_dose_ranges_ver->type_flag = ddr.type_flag,
     temp_drc_dose_ranges_ver->long_text_id = ddr.long_text_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error007: while selecting a row from drc_dose_range_ver table to be versioned.")
   SET v_ver_seq = 1
   SELECT INTO "nl:"
    FROM drc_dose_range_ver ddrv
    WHERE (ddrv.drc_dose_range_id=temp_drc_dose_ranges_ver->drc_dose_range_id)
    FOOT REPORT
     v_ver_seq = (max(ddrv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck(concat("Error008: while selecting the next_seq for drc_dose_range_ver.",
     cnvtstring(drc_dose_range_id)))
   INSERT  FROM drc_dose_range_ver ddrv
    SET ddrv.active_ind = temp_drc_dose_ranges_ver->active_ind, ddrv.drc_dose_range_id =
     temp_drc_dose_ranges_ver->drc_dose_range_id, ddrv.drc_premise_id = temp_drc_dose_ranges_ver->
     drc_premise_id,
     ddrv.min_value = temp_drc_dose_ranges_ver->min_value, ddrv.max_value = temp_drc_dose_ranges_ver
     ->max_value, ddrv.min_variance_pct = temp_drc_dose_ranges_ver->min_value_variance,
     ddrv.max_variance_pct = temp_drc_dose_ranges_ver->max_value_variance, ddrv.value_unit_cd =
     temp_drc_dose_ranges_ver->value_unit_cd, ddrv.max_dose = temp_drc_dose_ranges_ver->max_dose,
     ddrv.max_dose_unit_cd = temp_drc_dose_ranges_ver->max_dose_unit_cd, ddrv.dose_days =
     temp_drc_dose_ranges_ver->dose_days, ddrv.type_flag = temp_drc_dose_ranges_ver->type_flag,
     ddrv.long_text_id = temp_drc_dose_ranges_ver->long_text_id, ddrv.ver_seq = v_ver_seq, ddrv
     .updt_applctx = reqinfo->updt_applctx,
     ddrv.updt_cnt = 0, ddrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddrv.updt_id = reqinfo->
     updt_id,
     ddrv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error009: while inserting a version row into drc_dose_range_ver table.")
 END ;Subroutine
 SUBROUTINE insert_version_row_drc_form_reltn_ver_table(drc_form_reltn_id)
   FREE SET temp_drc_form_reltn
   RECORD temp_drc_form_reltn(
     1 drc_form_reltn_id = f8
     1 active_ind = i2
     1 build_flag = i2
     1 dose_range_check_id = f8
     1 drc_group_id = f8
     1 formulation_code = i4
   )
   SELECT INTO "NL:"
    FROM drc_form_reltn dfr
    WHERE dfr.drc_form_reltn_id=drc_form_reltn_id
    DETAIL
     temp_drc_form_reltn->drc_form_reltn_id = dfr.drc_form_reltn_id, temp_drc_form_reltn->active_ind
      = dfr.active_ind, temp_drc_form_reltn->build_flag = dfr.build_flag,
     temp_drc_form_reltn->dose_range_check_id = dfr.dose_range_check_id, temp_drc_form_reltn->
     drc_group_id = dfr.drc_group_id, temp_drc_form_reltn->formulation_code = dfr.formulation_code
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error010: while selecting a row from drc_form_reltn table to be versioned.")
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   SET v_ver_seq = 1
   SELECT INTO "nl:"
    FROM drc_form_reltn_ver dfrv
    WHERE (dfrv.drc_form_reltn_id=temp_drc_form_reltn->drc_form_reltn_id)
    FOOT REPORT
     v_ver_seq = (max(dfrv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error011: while selecting the next_seq for drc_dose_range_ver.")
   INSERT  FROM drc_form_reltn_ver dfrv
    SET dfrv.drc_form_reltn_id = temp_drc_form_reltn->drc_form_reltn_id, dfrv.active_ind =
     temp_drc_form_reltn->active_ind, dfrv.build_flag = temp_drc_form_reltn->build_flag,
     dfrv.dose_range_check_id = temp_drc_form_reltn->dose_range_check_id, dfrv.drc_group_id =
     temp_drc_form_reltn->drc_group_id, dfrv.formulation_code = temp_drc_form_reltn->formulation_code,
     dfrv.ver_seq = v_ver_seq, dfrv.updt_applctx = reqinfo->updt_applctx, dfrv.updt_cnt = 0,
     dfrv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfrv.updt_id = reqinfo->updt_id, dfrv
     .updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error012: while inserting a version row into drc_form_reltn_ver table.")
 END ;Subroutine
 SUBROUTINE insert_version_row_dose_range_check_ver_table(dose_range_check_id)
   FREE SET temp_dose_range_check
   RECORD temp_dose_range_check(
     1 dose_range_check_id = f8
     1 active_ind = i2
     1 build_flag = i2
     1 content_rule_identifier = i4
     1 dose_range_check_name = c100
     1 long_text_id = f8
   )
   SELECT INTO "NL:"
    FROM dose_range_check drc
    WHERE drc.dose_range_check_id=dose_range_check_id
    DETAIL
     temp_dose_range_check->dose_range_check_id = drc.dose_range_check_id, temp_dose_range_check->
     active_ind = drc.active_ind, temp_dose_range_check->build_flag = drc.build_flag,
     temp_dose_range_check->content_rule_identifier = drc.content_rule_identifier,
     temp_dose_range_check->dose_range_check_name = drc.dose_range_check_name, temp_dose_range_check
     ->long_text_id = drc.long_text_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error013: while selecting a row from dose_range_check table to be versioned.")
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   SET v_ver_seq = 1
   SELECT INTO "nl:"
    FROM dose_range_check_ver drcv
    WHERE (drcv.dose_range_check_id=temp_dose_range_check->dose_range_check_id)
    FOOT REPORT
     v_ver_seq = (max(drcv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error014: while selecting the next_seq for dose_range_check_ver.")
   INSERT  FROM dose_range_check_ver drcv
    SET drcv.dose_range_check_id = temp_dose_range_check->dose_range_check_id, drcv.active_ind =
     temp_dose_range_check->active_ind, drcv.build_flag = temp_dose_range_check->build_flag,
     drcv.content_rule_identifier = temp_dose_range_check->content_rule_identifier, drcv
     .dose_range_check_name = temp_dose_range_check->dose_range_check_name, drcv.ver_seq = v_ver_seq,
     drcv.updt_applctx = reqinfo->updt_applctx, drcv.updt_cnt = 0, drcv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     drcv.updt_id = reqinfo->updt_id, drcv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error015: while inserting a version row into dose_range_check_ver table.")
 END ;Subroutine
 SUBROUTINE insert_version_row_drc_facility_r_ver_table(drc_facility_r_id)
   FREE SET temp_drc_facility_r
   RECORD temp_drc_facility_r(
     1 drc_facility_r_id = f8
     1 active_ind = i2
     1 dose_range_check_id = f8
     1 drc_group_id = f8
     1 facility_cd = f8
   )
   SELECT INTO "NL:"
    FROM drc_facility_r dfr
    WHERE dfr.dose_range_check_id=dose_range_check_id
    DETAIL
     temp_drc_facility_r->drc_facility_r_id = dfr.drc_facility_r_id, temp_drc_facility_r->active_ind
      = dfr.active_ind, temp_drc_facility_r->dose_range_check_id = dfr.dose_range_check_id,
     temp_drc_facility_r->drc_group_id = dfr.drc_group_id, temp_drc_facility_r->facility_cd = dfr
     .facility_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error016: while selecting a row from drc_facility_r table to be versioned.")
   DECLARE v_ver_seq = i4 WITH protect, noconstant(1)
   SET v_ver_seq = 1
   SELECT INTO "nl:"
    FROM drc_facility_r_ver dfrv
    WHERE (dfrv.drc_facility_r_id=temp_drc_facility_r->drc_facility_r_id)
    FOOT REPORT
     v_ver_seq = (max(dfrv.ver_seq)+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error017: while selecting the next_seq for drc_facility_r_ver.")
   INSERT  FROM drc_facility_r_ver dfrv
    SET dfrv.drc_facility_r_id = temp_drc_facility_r->drc_facility_r_id, dfrv.active_ind =
     temp_drc_facility_r->active_ind, dfrv.build_flag = temp_drc_facility_r->dose_range_check_id,
     dfrv.dose_range_check_id = temp_drc_facility_r->drc_group_id, dfrv.drc_group_id =
     temp_drc_facility_r->facility_cd, dfrv.ver_seq = v_ver_seq,
     dfrv.updt_applctx = reqinfo->updt_applctx, dfrv.updt_cnt = 0, dfrv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     dfrv.updt_id = reqinfo->updt_id, dfrv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error018: while inserting a version row into drc_facility_r_ver table.")
 END ;Subroutine
 SUBROUTINE insert_ver_row_dose_range_after_premise_update(premise_id)
   DECLARE ddrcnt = i4 WITH protect, noconstant(0)
   FREE RECORD ddr_ids
   RECORD ddr_ids(
     1 list[*]
       2 dose_range_id = f8
   )
   SELECT INTO "nl:"
    FROM drc_dose_range ddr
    WHERE ddr.drc_premise_id=premise_id
     AND ddr.active_ind=1
    ORDER BY ddr.drc_dose_range_id
    HEAD ddr.drc_dose_range_id
     ddrcnt = (ddrcnt+ 1), stat = alterlist(ddr_ids->list,ddrcnt), ddr_ids->list[ddrcnt].
     dose_range_id = ddr.drc_dose_range_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 019:Error inserting new version of dose range.")
   FOR (ddridx = 1 TO ddrcnt)
     CALL insert_version_row_drc_dose_range_ver_table(ddr_ids->list[ddridx].dose_range_id)
   ENDFOR
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE modify_flag = i2 WITH protect, constant(2)
 DECLARE remove_flag = i2 WITH protect, constant(3)
 DECLARE age = i2 WITH protect, constant(1)
 DECLARE routes = i2 WITH protect, constant(2)
 DECLARE weight = i2 WITH protect, constant(3)
 DECLARE crcl = i2 WITH protect, constant(4)
 DECLARE pma = i2 WITH protect, constant(5)
 DECLARE hepatic = i2 WITH protect, constant(6)
 DECLARE clin_cond = i2 WITH protect, constant(7)
 DECLARE equals = i2 WITH protect, constant(0)
 DECLARE less_than = i2 WITH protect, constant(1)
 DECLARE greater_than = i2 WITH protect, constant(2)
 DECLARE less_than_or_equal_to = i2 WITH protect, constant(3)
 DECLARE greater_than_or_equal_to = i2 WITH protect, constant(4)
 DECLARE betw = i2 WITH protect, constant(5)
 DECLARE comment_string = vc WITH protect, noconstant("")
 DECLARE value1_string = vc WITH protect, noconstant("")
 DECLARE value2_string = vc WITH protect, noconstant("")
 DECLARE changed_ind = i2 WITH protect, noconstant(0)
 DECLARE set_to_active = i2 WITH protect, noconstant(1)
 DECLARE existingpremiseid = f8 WITH protect, noconstant(0)
 DECLARE existingdoserangeid = f8 WITH protect, noconstant(0)
 DECLARE existinglongtextid = f8 WITH protect, noconstant(0)
 DECLARE createparentpremise(grp_index=i2) = f8
 DECLARE createallrouteassociations(grp_index=i2,pp_index=i2) = null
 DECLARE locateexistingpremise(grp_index=i2,pp_index=i2,p_index=i2) = f8
 DECLARE createpremise(grp_index=i2,pp_index=i2,p_index=i2) = f8
 DECLARE reactivatepremise(grp_index=i2,pp_index=i2,p_index=i2) = null
 DECLARE modifypremise(grp_index=i2,pp_index=i2,p_index=i2) = null
 DECLARE removepremise(grp_index=i2,pp_index=i2,p_index=i2) = null
 DECLARE locateexistingdoserange(grp_index=i2,pp_index=i2,drc_index=i2) = f8
 DECLARE createdoserange(grp_index=i2,pp_index=i2,drc_index=i2) = f8
 DECLARE reactivatedoserange(grp_index=i2,pp_index=i2,drc_index=i2) = null
 DECLARE modifydoserange(grp_index=i2,pp_index=i2,drc_index=i2) = null
 DECLARE removedoserange(grp_index=i2,pp_index=i2,drc_index=i2) = null
 DECLARE setdoserangecustomindafterpremiseupdate(drc_premise_id=f8) = null
 DECLARE setdoserangecustomindaftermodifiedlongtext(drc_dose_range_id=f8) = null
 DECLARE createlongtextrow(grp_index=i2,pp_index=i2,drc_index=i2) = f8
 DECLARE modifylongtextrow(grp_index=i2,pp_index=i2,drc_index=i2) = null
 DECLARE getnextdrcseq(dummyvar=i2) = null
 DECLARE getnextlongdataseq(dummyvar=i2) = null
 DECLARE format_number(number=f8) = vc
 FOR (grouper_cnt = 1 TO size(request->groupers,5))
   FOR (parent_premise_cnt = 1 TO size(request->groupers[grouper_cnt].parent_premises,5))
     IF ((request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].parent_premise_id=0.0))
      SET request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].parent_premise_id =
      createparentpremise(grouper_cnt)
     ENDIF
     FOR (premise_cnt = 1 TO size(request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].
      premises,5))
       IF ((request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].premises[premise_cnt].
       premise_type_flag IN (age, weight, pma, crcl, hepatic,
       clin_cond)))
        CASE (request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].premises[premise_cnt
        ].action_flag)
         OF add_flag:
          SET existingpremiseid = locateexistingpremise(grouper_cnt,parent_premise_cnt,premise_cnt)
          IF (existingpremiseid=0.0)
           SET request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].premises[
           premise_cnt].premise_id = createpremise(grouper_cnt,parent_premise_cnt,premise_cnt)
          ELSE
           SET request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].premises[
           premise_cnt].premise_id = existingpremiseid
           CALL reactivatepremise(grouper_cnt,parent_premise_cnt,premise_cnt)
          ENDIF
         OF modify_flag:
          CALL modifypremise(grouper_cnt,parent_premise_cnt,premise_cnt)
         OF remove_flag:
          CALL removepremise(grouper_cnt,parent_premise_cnt,premise_cnt)
        ENDCASE
       ENDIF
     ENDFOR
     IF (size(request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].routes,5) > 0)
      CALL createallrouteassociations(grouper_cnt,parent_premise_cnt)
     ENDIF
     FOR (dose_range_cnt = 1 TO size(request->groupers[grouper_cnt].parent_premises[
      parent_premise_cnt].dose_ranges,5))
       CASE (request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].dose_ranges[
       dose_range_cnt].action_flag)
        OF add_flag:
         SET existingdoserangeid = locateexistingdoserange(grouper_cnt,parent_premise_cnt,
          dose_range_cnt)
         IF (existingdoserangeid=0.0)
          SET request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].dose_ranges[
          dose_range_cnt].dose_range_id = createdoserange(grouper_cnt,parent_premise_cnt,
           dose_range_cnt)
         ELSE
          SET request->groupers[grouper_cnt].parent_premises[parent_premise_cnt].dose_ranges[
          dose_range_cnt].dose_range_id = existingdoserangeid
          CALL reactivatedoserange(grouper_cnt,parent_premise_cnt,dose_range_cnt)
         ENDIF
        OF modify_flag:
         CALL modifydoserange(grouper_cnt,parent_premise_cnt,dose_range_cnt)
        OF remove_flag:
         CALL removedoserange(grouper_cnt,parent_premise_cnt,dose_range_cnt)
       ENDCASE
     ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM dm_info dm
    WHERE dm.info_domain="KNOWLEDGE INDEX APPLICATIONS"
     AND dm.info_name="DRC_FLEX"
    WITH nocounter
   ;end select
   IF (curqual > 0)
    UPDATE  FROM drc_facility_r dfac
     SET dfac.active_ind = 1
     WHERE (dfac.dose_range_check_id=request->groupers[grouper_cnt].dose_range_check_id)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE createparentpremise(grp_index)
   SET newparentpremiseid = getnextdrcseq(0)
   INSERT  FROM drc_premise dp
    SET dp.active_ind = 1, dp.dose_range_check_id = request->groupers[grp_index].dose_range_check_id,
     dp.drc_premise_id = newparentpremiseid,
     dp.parent_ind = 1, dp.parent_premise_id = 0.0, dp.updt_applctx = reqinfo->updt_applctx,
     dp.updt_cnt = 0, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id,
     dp.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 001: Error creating parent premise.")
   CALL insert_version_row_drc_prem_ver_table(newparentpremiseid)
   RETURN(newparentpremiseid)
 END ;Subroutine
 SUBROUTINE createallrouteassociations(grp_index,pp_index)
   SET stat = alterlist(routesrequest->premises,1)
   SET routesrequest->premises[1].drc_premise_id = 0.0
   SET routesrequest->premises[1].location_flag = 0
   SET stat = alterlist(routesrequest->routes,size(request->groupers[grp_index].parent_premises[
     pp_index].routes,5))
   FOR (route_cnt = 1 TO size(request->groupers[grp_index].parent_premises[pp_index].routes,5))
     SET routesrequest->routes[route_cnt].route_code_value = request->groupers[grp_index].
     parent_premises[pp_index].routes[route_cnt].route_cd
     SET routesrequest->routes[route_cnt].route_display = uar_get_code_display(routesrequest->routes[
      route_cnt].route_code_value)
     SET routesrequest->routes[route_cnt].action_flag = 1
   ENDFOR
   SET routesrequest->dose_range_check_id = request->groupers[grp_index].dose_range_check_id
   SET routesrequest->parent_premise_id = request->groupers[grp_index].parent_premises[pp_index].
   parent_premise_id
   EXECUTE bed_ens_drc_routes  WITH replace("REQUEST",routesrequest), replace("REPLY",routesreply)
   CALL bederrorcheck("Error 002:Error creating route associations.")
 END ;Subroutine
 SUBROUTINE createpremise(grp_index,pp_index,p_index)
   SET newpremiseid = getnextdrcseq(0)
   DECLARE value_type_flag = i2 WITH protect, noconstant(1)
   IF ((request->groupers[grp_index].parent_premises[pp_index].premises[p_index].premise_type_flag=7)
   )
    SET value_type_flag = 0
   ENDIF
   SET value1_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value1)
   SET value2_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value2)
   INSERT  FROM drc_premise dp
    SET dp.active_ind = 1, dp.dose_range_check_id = request->groupers[grp_index].dose_range_check_id,
     dp.drc_premise_id = newpremiseid,
     dp.parent_ind = 0, dp.parent_premise_id = request->groupers[grp_index].parent_premises[pp_index]
     .parent_premise_id, dp.premise_type_flag = request->groupers[grp_index].parent_premises[pp_index
     ].premises[p_index].premise_type_flag,
     dp.relational_operator_flag = request->groupers[grp_index].parent_premises[pp_index].premises[
     p_index].operator_flag, dp.value1 = request->groupers[grp_index].parent_premises[pp_index].
     premises[p_index].value1, dp.value2 = request->groupers[grp_index].parent_premises[pp_index].
     premises[p_index].value2,
     dp.value1_string = value1_string, dp.value2_string = value2_string, dp.value_unit_cd = request->
     groupers[grp_index].parent_premises[pp_index].premises[p_index].value_unit_cd,
     dp.concept_cki = trim(request->groupers[grp_index].parent_premises[pp_index].premises[p_index].
      value_string,7), dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt = 0,
     dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id, dp.updt_task =
     reqinfo->updt_task,
     dp.value_type_flag = value_type_flag
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 003:Error creating premise.")
   CALL insert_version_row_drc_prem_ver_table(newpremiseid)
   CALL setdoserangecustomindafterpremiseupdate(request->groupers[grp_index].parent_premises[pp_index
    ].parent_premise_id)
   RETURN(newpremiseid)
 END ;Subroutine
 SUBROUTINE modifypremise(grp_index,pp_index,p_index)
   SET value1_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value1)
   SET value2_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value2)
   UPDATE  FROM drc_premise dp
    SET dp.relational_operator_flag = request->groupers[grp_index].parent_premises[pp_index].
     premises[p_index].operator_flag, dp.value_unit_cd = request->groupers[grp_index].
     parent_premises[pp_index].premises[p_index].value_unit_cd, dp.concept_cki = trim(request->
      groupers[grp_index].parent_premises[pp_index].premises[p_index].value_string,7),
     dp.value1 = request->groupers[grp_index].parent_premises[pp_index].premises[p_index].value1, dp
     .value2 = request->groupers[grp_index].parent_premises[pp_index].premises[p_index].value2, dp
     .value1_string = value1_string,
     dp.value2_string = value2_string, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt = (dp
     .updt_cnt+ 1),
     dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id, dp.updt_task =
     reqinfo->updt_task
    WHERE (dp.drc_premise_id=request->groupers[grp_index].parent_premises[pp_index].premises[p_index]
    .premise_id)
     AND (dp.parent_premise_id=request->groupers[grp_index].parent_premises[pp_index].
    parent_premise_id)
     AND dp.parent_ind=0
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 004:Error modifying premise.")
   CALL insert_version_row_drc_prem_ver_table(request->groupers[grp_index].parent_premises[pp_index].
    premises[p_index].premise_id)
   CALL setdoserangecustomindafterpremiseupdate(request->groupers[grp_index].parent_premises[pp_index
    ].parent_premise_id)
 END ;Subroutine
 SUBROUTINE removepremise(grp_index,pp_index,p_index)
   IF ((request->groupers[grp_index].parent_premises[pp_index].premises[p_index].premise_type_flag=
   hepatic))
    UPDATE  FROM drc_premise dp
     SET dp.value1 = 0, dp.value1_string = "0", dp.updt_applctx = reqinfo->updt_applctx,
      dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id =
      reqinfo->updt_id,
      dp.updt_task = reqinfo->updt_task
     WHERE dp.drc_premise_id=premise_id
      AND (dp.parent_premise_id=request->groupers[grp_index].parent_premises[pp_index].
     parent_premise_id)
      AND dp.parent_ind=0
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM drc_premise dp
     SET dp.active_ind = 0, dp.relational_operator_flag = request->groupers[grp_index].
      parent_premises[pp_index].premises[p_index].operator_flag, dp.value_unit_cd = request->
      groupers[grp_index].parent_premises[pp_index].premises[p_index].value_unit_cd,
      dp.concept_cki = trim(request->groupers[grp_index].parent_premises[pp_index].premises[p_index].
       value_string,7), dp.value1 = request->groupers[grp_index].parent_premises[pp_index].premises[
      p_index].value1, dp.value2 = request->groupers[grp_index].parent_premises[pp_index].premises[
      p_index].value2,
      dp.value1_string = value1_string, dp.value2_string = value2_string, dp.updt_applctx = reqinfo->
      updt_applctx,
      dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id =
      reqinfo->updt_id,
      dp.updt_task = reqinfo->updt_task
     WHERE (dp.drc_premise_id=request->groupers[grp_index].parent_premises[pp_index].premises[p_index
     ].premise_id)
     WITH nocounter
    ;end update
   ENDIF
   CALL bederrorcheck("Error 005:Error removing premise.")
   CALL insert_version_row_drc_prem_ver_table(request->groupers[grp_index].parent_premises[pp_index].
    premises[p_index].premise_id)
   CALL setdoserangecustomindafterpremiseupdate(request->groupers[grp_index].parent_premises[pp_index
    ].parent_premise_id)
 END ;Subroutine
 SUBROUTINE createdoserange(grp_index,pp_index,drc_index)
   SET drc_dose_range_id = getnextdrcseq(0)
   SET long_text_id = 0.0
   IF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7) > ""
    AND (request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id=
   0.0))
    SET long_text_id = createlongtextrow(grp_index,pp_index,drc_index)
   ENDIF
   INSERT  FROM drc_dose_range ddr
    SET ddr.active_ind = 1, ddr.custom_ind = 1, ddr.dose_days = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].dose_days,
     ddr.drc_dose_range_id = drc_dose_range_id, ddr.drc_premise_id = request->groupers[grp_index].
     parent_premises[pp_index].parent_premise_id, ddr.long_text_id = long_text_id,
     ddr.max_dose = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
     max_dose, ddr.max_dose_unit_cd = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].max_dose_unit_cd, ddr.max_value = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].max_value,
     ddr.max_variance_pct = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].max_variance, ddr.min_value = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].min_value, ddr.min_variance_pct = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].min_variance,
     ddr.type_flag = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
     dose_type, ddr.updt_applctx = reqinfo->updt_applctx, ddr.updt_cnt = 0,
     ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->updt_id, ddr.updt_task
      = reqinfo->updt_task,
     ddr.value_unit_cd = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index
     ].dose_unit_cd
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 006:Error creating dose range.")
   CALL insert_version_row_drc_dose_range_ver_table(drc_dose_range_id)
   RETURN(drc_dose_range_id)
 END ;Subroutine
 SUBROUTINE createlongtextrow(grp_index,pp_index,drc_index)
   SET long_text_id = getnextlongdataseq(0)
   SET set_to_active = 1
   IF ((request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].action_flag=
   remove_flag))
    SET set_to_active = 0
   ENDIF
   INSERT  FROM long_text lt
    SET lt.active_ind = set_to_active, lt.long_text = trim(request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].comment_text,7), lt.long_text_id =
     long_text_id,
     lt.parent_entity_name = "DRC_TEXT", lt.parent_entity_id = 0.0, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.active_status_prsnl_id = reqinfo->updt_id, lt
     .active_status_cd = 0.0,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 007:Error creating long_text.")
   CALL setdoserangecustomindaftermodifiedlongtext(request->groupers[grp_index].parent_premises[
    pp_index].dose_ranges[drc_index].dose_range_id)
   RETURN(long_text_id)
 END ;Subroutine
 SUBROUTINE modifylongtextrow(grp_index,pp_index,drc_index)
   SET set_to_active = 1
   IF ((request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].action_flag=
   remove_flag))
    SET set_to_active = 0
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.active_ind = set_to_active, lt.long_text = trim(request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].comment_text,7), lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id =
     reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.active_status_prsnl_id = reqinfo->updt_id, lt
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (lt.long_text_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
    drc_index].long_text_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 008:Error modifying long_text.")
   CALL setdoserangecustomindaftermodifiedlongtext(request->groupers[grp_index].parent_premises[
    pp_index].dose_ranges[drc_index].dose_range_id)
 END ;Subroutine
 SUBROUTINE modifydoserange(grp_index,pp_index,drc_index)
   SET comment_string = ""
   SET changed_ind = 0
   IF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7) > ""
    AND (request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id=
   0.0))
    SET request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id =
    createlongtextrow(grp_index,pp_index,drc_index)
    SET changed_ind = 1
   ELSEIF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7)="")
    SET request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id =
    0
    SET changed_ind = 1
   ELSE
    SELECT INTO "nl:"
     FROM long_text lt
     WHERE (lt.long_text_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].long_text_id)
     DETAIL
      comment_string = lt.long_text
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 009:Error getting old long text row.")
    IF (comment_string != trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].comment_text,7))
     CALL modifylongtextrow(grp_index,pp_index,drc_index)
    ENDIF
   ENDIF
   IF (changed_ind=0)
    SELECT INTO "nl:"
     FROM drc_dose_range ddr
     WHERE (ddr.drc_dose_range_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].dose_range_id)
     DETAIL
      IF ((((ddr.min_value != request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
      drc_index].min_value)) OR ((((ddr.min_variance_pct != request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].min_variance)) OR ((((ddr.max_value != request
      ->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].max_value)) OR ((((ddr
      .max_variance_pct != request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
      drc_index].max_variance)) OR ((((ddr.value_unit_cd != request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].dose_unit_cd)) OR ((((ddr.max_dose != request
      ->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].max_dose)) OR ((((ddr
      .max_dose_unit_cd != request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
      drc_index].max_dose_unit_cd)) OR ((ddr.dose_days != request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].dose_days))) )) )) )) )) )) )) )
       changed_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (changed_ind=1)
    UPDATE  FROM drc_dose_range ddr
     SET ddr.min_value = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index
      ].min_value, ddr.min_variance_pct = request->groupers[grp_index].parent_premises[pp_index].
      dose_ranges[drc_index].min_variance, ddr.max_value = request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].max_value,
      ddr.max_variance_pct = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
      drc_index].max_variance, ddr.value_unit_cd = request->groupers[grp_index].parent_premises[
      pp_index].dose_ranges[drc_index].dose_unit_cd, ddr.max_dose = request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].max_dose,
      ddr.max_dose_unit_cd = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
      drc_index].max_dose_unit_cd, ddr.long_text_id = request->groupers[grp_index].parent_premises[
      pp_index].dose_ranges[drc_index].long_text_id, ddr.dose_days = request->groupers[grp_index].
      parent_premises[pp_index].dose_ranges[drc_index].dose_days,
      ddr.updt_applctx = reqinfo->updt_applctx, ddr.updt_cnt = (ddr.updt_cnt+ 1), ddr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ddr.updt_id = reqinfo->updt_id, ddr.updt_task = reqinfo->updt_task, ddr.custom_ind = 1
     WHERE (ddr.drc_dose_range_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].dose_range_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error 010:Error modifying dose range.")
    CALL insert_version_row_drc_dose_range_ver_table(request->groupers[grp_index].parent_premises[
     pp_index].dose_ranges[drc_index].dose_range_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE locateexistingpremise(grp_index,pp_index,p_index)
   DECLARE existingid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    dp.drc_premise_id
    FROM drc_premise dp
    WHERE (dp.parent_premise_id=request->groupers[grp_index].parent_premises[pp_index].
    parent_premise_id)
     AND (dp.premise_type_flag=request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].premise_type_flag)
     AND dp.active_ind=0
    DETAIL
     existingid = dp.drc_premise_id
    WITH nocounter
   ;end select
   RETURN(existingid)
 END ;Subroutine
 SUBROUTINE locateexistingdoserange(grp_index,pp_index,drc_index)
   DECLARE existingid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ddr.drc_dose_range_id
    FROM drc_dose_range ddr
    WHERE (ddr.drc_premise_id=request->groupers[grp_index].parent_premises[pp_index].
    parent_premise_id)
     AND (ddr.type_flag=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index]
    .dose_type)
     AND (ddr.value_unit_cd=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
    drc_index].dose_unit_cd)
     AND ddr.active_ind=0
    DETAIL
     existingid = ddr.drc_dose_range_id
    WITH nocounter
   ;end select
   RETURN(existingid)
 END ;Subroutine
 SUBROUTINE reactivatepremise(grp_index,pp_index,p_index)
   SET value1_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value1)
   SET value2_string = format_number(request->groupers[grp_index].parent_premises[pp_index].premises[
    p_index].value2)
   SET premise_id = request->groupers[grp_index].parent_premises[pp_index].premises[p_index].
   premise_id
   UPDATE  FROM drc_premise dp
    SET dp.active_ind = 1, dp.relational_operator_flag = request->groupers[grp_index].
     parent_premises[pp_index].premises[p_index].operator_flag, dp.value_unit_cd = request->groupers[
     grp_index].parent_premises[pp_index].premises[p_index].value_unit_cd,
     dp.concept_cki = trim(request->groupers[grp_index].parent_premises[pp_index].premises[p_index].
      value_string,7), dp.value1 = request->groupers[grp_index].parent_premises[pp_index].premises[
     p_index].value1, dp.value2 = request->groupers[grp_index].parent_premises[pp_index].premises[
     p_index].value2,
     dp.value1_string = value1_string, dp.value2_string = value2_string, dp.updt_applctx = reqinfo->
     updt_applctx,
     dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id =
     reqinfo->updt_id,
     dp.updt_task = reqinfo->updt_task
    WHERE dp.drc_premise_id=premise_id
     AND (dp.parent_premise_id=request->groupers[grp_index].parent_premises[pp_index].
    parent_premise_id)
     AND dp.parent_ind=0
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 011:Error re-activating premise.")
   CALL insert_version_row_drc_prem_ver_table(premise_id)
   CALL setdoserangecustomindafterpremiseupdate(request->groupers[grp_index].parent_premises[pp_index
    ].parent_premise_id)
 END ;Subroutine
 SUBROUTINE reactivatedoserange(grp_index,pp_index,drc_index)
   IF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7) > "")
    SET request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id =
    createlongtextrow(grp_index,pp_index,drc_index)
   ENDIF
   UPDATE  FROM drc_dose_range ddr
    SET ddr.active_ind = 1, ddr.custom_ind = 1, ddr.min_value = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].min_value,
     ddr.min_variance_pct = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].min_variance, ddr.max_value = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].max_value, ddr.max_variance_pct = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].max_variance,
     ddr.value_unit_cd = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index
     ].dose_unit_cd, ddr.max_dose = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].max_dose, ddr.max_dose_unit_cd = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].max_dose_unit_cd,
     ddr.long_text_id = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index]
     .long_text_id, ddr.dose_days = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].dose_days, ddr.updt_applctx = reqinfo->updt_applctx,
     ddr.updt_cnt = (ddr.updt_cnt+ 1), ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id
      = reqinfo->updt_id,
     ddr.updt_task = reqinfo->updt_task
    WHERE (ddr.drc_dose_range_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
    drc_index].dose_range_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 012:Error re-activating dose range.")
   CALL insert_version_row_drc_dose_range_ver_table(request->groupers[grp_index].parent_premises[
    pp_index].dose_ranges[drc_index].dose_range_id)
 END ;Subroutine
 SUBROUTINE removedoserange(grp_index,pp_index,drc_index)
   SET comment_string = ""
   IF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7) > ""
    AND (request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id=
   0.0))
    SET request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id =
    createlongtextrow(grp_index,pp_index,drc_index)
   ELSEIF (trim(request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
    comment_text,7)="")
    SET request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].long_text_id =
    0
   ELSE
    CALL modifylongtextrow(grp_index,pp_index,drc_index)
   ENDIF
   UPDATE  FROM drc_dose_range ddr
    SET ddr.active_ind = 0, ddr.custom_ind = 1, ddr.min_value = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].min_value,
     ddr.min_variance_pct = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
     drc_index].min_variance, ddr.max_value = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].max_value, ddr.max_variance_pct = request->groupers[grp_index].
     parent_premises[pp_index].dose_ranges[drc_index].max_variance,
     ddr.value_unit_cd =
     IF ((request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].dose_unit_cd
      > 0.0)) request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
      dose_unit_cd
     ELSE ddr.value_unit_cd
     ENDIF
     , ddr.max_dose = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index].
     max_dose, ddr.max_dose_unit_cd = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].max_dose_unit_cd,
     ddr.long_text_id = request->groupers[grp_index].parent_premises[pp_index].dose_ranges[drc_index]
     .long_text_id, ddr.dose_days = request->groupers[grp_index].parent_premises[pp_index].
     dose_ranges[drc_index].dose_days, ddr.updt_applctx = reqinfo->updt_applctx,
     ddr.updt_cnt = (ddr.updt_cnt+ 1), ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id
      = reqinfo->updt_id,
     ddr.updt_task = reqinfo->updt_task
    WHERE (ddr.drc_dose_range_id=request->groupers[grp_index].parent_premises[pp_index].dose_ranges[
    drc_index].dose_range_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 013:Error modifying dose range.")
   CALL insert_version_row_drc_dose_range_ver_table(request->groupers[grp_index].parent_premises[
    pp_index].dose_ranges[drc_index].dose_range_id)
 END ;Subroutine
 SUBROUTINE setdoserangecustomindafterpremiseupdate(drc_premise_id)
   UPDATE  FROM drc_dose_range ddr
    SET ddr.custom_ind = 1, ddr.updt_applctx = reqinfo->updt_applctx, ddr.updt_cnt = (ddr.updt_cnt+ 1
     ),
     ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->updt_id, ddr.updt_task
      = reqinfo->updt_task
    WHERE ddr.drc_premise_id=drc_premise_id
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 014:Error modifying dose range.")
   CALL insert_ver_row_dose_range_after_premise_update(drc_premise_id)
 END ;Subroutine
 SUBROUTINE setdoserangecustomindaftermodifiedlongtext(drc_dose_range_id)
   UPDATE  FROM drc_dose_range ddr
    SET ddr.custom_ind = 1, ddr.updt_applctx = reqinfo->updt_applctx, ddr.updt_cnt = (ddr.updt_cnt+ 1
     ),
     ddr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ddr.updt_id = reqinfo->updt_id, ddr.updt_task
      = reqinfo->updt_task
    WHERE ddr.drc_dose_range_id=drc_dose_range_id
   ;end update
   CALL bederrorcheck("Error 015:Error modifying dose range.")
   CALL insert_version_row_drc_dose_range_ver_table(drc_dose_range_id)
 END ;Subroutine
 SUBROUTINE getnextdrcseq(dummyvar)
   DECLARE id = f8 WITH protect
   SELECT INTO "nl:"
    z = seq(drc_seq,nextval)
    FROM dual d
    DETAIL
     id = z
    WITH nocounter
   ;end select
   RETURN(id)
 END ;Subroutine
 SUBROUTINE getnextlongdataseq(dummyvar)
   DECLARE id = f8 WITH protect
   SELECT INTO "nl:"
    z = seq(long_data_seq,nextval)
    FROM dual d
    DETAIL
     id = z
    WITH nocounter
   ;end select
   RETURN(id)
 END ;Subroutine
 SUBROUTINE format_number(number)
   DECLARE number_string = vc WITH protect, noconstant(fillstring(255," "))
   SET mod_value = 0.0
   SET mod_value = (number - cnvtint(number))
   IF (mod_value=0.0)
    SET number_string = trim(cnvtstring(number))
   ELSE
    IF (mod((number * 10000),10) != 0)
     SET number_string = trim(format(number,"##########.####"),3)
    ELSEIF (mod((number * 1000),10) != 0)
     SET number_string = trim(format(number,"##########.###"),3)
    ELSEIF (mod((number * 100),10) != 0)
     SET number_string = trim(format(number,"##########.##"),3)
    ELSE
     SET number_string = trim(format(number,"##########.#"),3)
    ENDIF
   ENDIF
   RETURN(number_string)
 END ;Subroutine
END GO
