CREATE PROGRAM bed_get_cnt_missing_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 codes[*]
      2 uid = vc
      2 display = vc
      2 description = vc
      2 cdf_meaning = vc
      2 code_set = i4
      2 code_set_display = vc
      2 ignore_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET missingcodes
 RECORD missingcodes(
   1 codes[*]
     2 uid = vc
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
 DECLARE getmissingcodeofaform(dummyvar=i2) = null
 DECLARE getmissingcodeofasection(dummyvar=i2) = null
 DECLARE addmissingcodes(missingcodeuid=vc) = null
 DECLARE populatereply(dummyvar=i2) = null
 DECLARE form_uid = vc WITH protect, noconstant(trim(request->form_uid))
 DECLARE section_uid = vc WITH protect, noconstant(trim(request->section_uid))
 IF (form_uid != "")
  CALL getmissingcodeofaform(0)
 ELSEIF (section_uid != "")
  CALL getmissingcodeofasection(0)
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(missingcodes)
 ENDIF
 CALL populatereply(0)
 SUBROUTINE getmissingcodeofaform(dummyvar)
   CALL bedlogmessage("getMissingCodeOfAForm","Entering ...")
   SELECT INTO "nl:"
    FROM cnt_powerform p,
     cnt_pf_section_r psr,
     cnt_input i,
     cnt_dta d,
     cnt_dta_rrf_r rr,
     cnt_rrf rrf,
     cnt_rrf_key rrk,
     cnt_rrf_ar_r arr,
     cnt_alpha_response_key ark,
     cnt_alpha_response ar,
     cnt_dcp_interp di,
     cnt_dcp_interp2 di2,
     cnt_ref_text rf,
     cnt_equation e,
     cnt_equation_component ec,
     cnt_data_map dm,
     cnt_grid g,
     cnt_dta_offset_min om
    PLAN (p
     WHERE p.form_uid=form_uid)
     JOIN (psr
     WHERE psr.form_uid=outerjoin(p.form_uid))
     JOIN (i
     WHERE i.section_uid=outerjoin(psr.section_uid))
     JOIN (d
     WHERE d.task_assay_uid=outerjoin(i.task_assay_uid))
     JOIN (rr
     WHERE rr.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (rrf
     WHERE rrf.rrf_uid=outerjoin(rr.rrf_uid))
     JOIN (rrk
     WHERE rrk.rrf_uid=outerjoin(rr.rrf_uid))
     JOIN (arr
     WHERE arr.rrf_uid=outerjoin(rrk.rrf_uid))
     JOIN (ark
     WHERE ark.ar_uid=outerjoin(arr.ar_uid))
     JOIN (ar
     WHERE ar.ar_uid=outerjoin(ark.ar_uid))
     JOIN (di
     WHERE di.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (di2
     WHERE di2.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (rf
     WHERE rf.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (e
     WHERE e.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (ec
     WHERE ec.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (dm
     WHERE dm.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (g
     WHERE g.cnt_input_key_id=outerjoin(i.cnt_input_key_id))
     JOIN (om
     WHERE om.task_assay_uid=outerjoin(d.task_assay_uid))
    DETAIL
     IF (i.merge_name="CODE_VALUE"
      AND i.merge_id=0
      AND i.merge_uid != ""
      AND i.merge_uid != " ")
      CALL logdebugmessage("cnt_input's merge_uid is missing:",i.merge_uid),
      CALL addmissingcodes(i.merge_uid)
     ENDIF
     IF (d.activity_type_cduid != ""
      AND d.activity_type_cduid != " "
      AND d.activity_type_cd=0)
      CALL logdebugmessage("cnt_dta's activity_type_cduid is missing:",d.activity_type_cduid),
      CALL addmissingcodes(d.activity_type_cduid)
     ENDIF
     IF (d.default_result_type_cduid != ""
      AND d.default_result_type_cduid != " "
      AND d.default_result_type_cd=0)
      CALL logdebugmessage("cnt_dta's default_result_type_cduid is missing:",d
      .default_result_type_cduid),
      CALL addmissingcodes(d.default_result_type_cduid)
     ENDIF
     IF (d.history_activity_type_cduid != ""
      AND d.history_activity_type_cduid != " "
      AND d.history_activity_type_cd=0)
      CALL logdebugmessage("cnt_dta's history_activity_type_cduid is missing:",d
      .history_activity_type_cduid),
      CALL addmissingcodes(d.history_activity_type_cduid)
     ENDIF
     IF (d.bb_result_type_cduid != ""
      AND d.bb_result_type_cduid != " "
      AND d.bb_result_type_cd=0)
      CALL logdebugmessage("cnt_dta's bb_result_type_cduid is missing:",d.bb_result_type_cduid),
      CALL addmissingcodes(d.bb_result_type_cduid)
     ENDIF
     IF (d.rad_sect_type_cduid != ""
      AND d.rad_sect_type_cduid != " "
      AND d.rad_section_type_cd=0)
      CALL logdebugmessage("cnt_dta's rad_sect_type_cduid is missing:",d.rad_sect_type_cduid),
      CALL addmissingcodes(d.rad_sect_type_cduid)
     ENDIF
     IF (rrf.delta_check_type_cduid != ""
      AND rrf.delta_check_type_cduid != " "
      AND rrf.delta_check_type_cd=0)
      CALL logdebugmessage("cnt_rrf's delta_check_type_cduid is missing:",rrf.delta_check_type_cduid),
      CALL addmissingcodes(rrf.delta_check_type_cduid)
     ENDIF
     IF (rrf.units_cduid != ""
      AND rrf.units_cduid != " "
      AND rrf.units_cd=0)
      CALL logdebugmessage("cnt_rrf's units_cduid is missing:",rrf.units_cduid),
      CALL addmissingcodes(rrf.units_cduid)
     ENDIF
     IF (rrf.encntr_type_cduid != ""
      AND rrf.encntr_type_cduid != " "
      AND rrf.encntr_type_cd=0)
      CALL logdebugmessage("cnt_rrf's encntr_type_cduid is missing:",rrf.encntr_type_cduid),
      CALL addmissingcodes(rrf.encntr_type_cduid)
     ENDIF
     IF (rrk.species_cduid != ""
      AND rrk.species_cduid != " "
      AND rrk.species_cd=0)
      CALL logdebugmessage("cnt_rrf_key's species_cduid is missing:",rrk.species_cduid),
      CALL addmissingcodes(rrk.species_cduid)
     ENDIF
     IF (rrk.organism_cduid != ""
      AND rrk.organism_cduid != " "
      AND rrk.organism_cd=0)
      CALL logdebugmessage("cnt_rrf_key's organism_cduid is missing:",rrk.organism_cduid),
      CALL addmissingcodes(rrk.organism_cduid)
     ENDIF
     IF (rrk.service_resource_cduid != ""
      AND rrk.service_resource_cduid != " "
      AND rrk.service_resource_cd=0)
      CALL logdebugmessage("cnt_rrf_key's service_resource_cduid is missing:",rrk
      .service_resource_cduid),
      CALL addmissingcodes(rrk.service_resource_cduid)
     ENDIF
     IF (rrk.sex_cduid != ""
      AND rrk.sex_cduid != " "
      AND rrk.sex_cd=0)
      CALL logdebugmessage("cnt_rrf_key's sex_cduid is missing:",rrk.sex_cduid),
      CALL addmissingcodes(rrk.sex_cduid)
     ENDIF
     IF (rrk.age_from_units_cduid != ""
      AND rrk.age_from_units_cduid != " "
      AND rrk.age_from_units_cd=0)
      CALL logdebugmessage("cnt_rrf_key's age_from_units_cduid is missing:",rrk.age_from_units_cduid),
      CALL addmissingcodes(rrk.age_from_units_cduid)
     ENDIF
     IF (rrk.age_to_units_cduid != ""
      AND rrk.age_to_units_cduid != " "
      AND rrk.age_to_units_cd=0)
      CALL logdebugmessage("cnt_rrf_key's age_to_units_cduid is missing:",rrk.age_to_units_cduid),
      CALL addmissingcodes(rrk.age_to_units_cduid)
     ENDIF
     IF (rrk.specimen_type_cduid != ""
      AND rrk.specimen_type_cduid != " "
      AND rrk.specimen_type_cd=0)
      CALL logdebugmessage("cnt_rrf_key's specimen_type_cduid is missing:",rrk.specimen_type_cduid),
      CALL addmissingcodes(rrk.specimen_type_cduid)
     ENDIF
     IF (rrk.patient_condition_cduid != ""
      AND rrk.patient_condition_cduid != " "
      AND rrk.patient_condition_cd=0)
      CALL logdebugmessage("cnt_rrf_key's patient_condition_cduid is missing:",rrk
      .patient_condition_cduid),
      CALL addmissingcodes(rrk.patient_condition_cduid)
     ENDIF
     IF (arr.result_process_cduid != ""
      AND arr.result_process_cduid != " "
      AND arr.result_process_cd=0)
      CALL logdebugmessage("cnt_rrf_ar_r's result_process_cduid is missing:",arr.result_process_cduid
      ),
      CALL addmissingcodes(arr.result_process_cduid)
     ENDIF
     IF (ark.principle_type_cduid != ""
      AND ark.principle_type_cduid != " "
      AND ark.principle_type_cd=0)
      CALL logdebugmessage("cnt_alpha_response_key's principle_type_cduid is missing:",ark
      .principle_type_cduid),
      CALL addmissingcodes(ark.principle_type_cduid)
     ENDIF
     IF (ark.source_vocabulary_cduid != ""
      AND ark.source_vocabulary_cduid != " "
      AND ark.source_vocabulary_cd=0)
      CALL logdebugmessage("cnt_alpha_response_key's source_vocabulary_cduid is missing:",ark
      .source_vocabulary_cduid),
      CALL addmissingcodes(ark.source_vocabulary_cduid)
     ENDIF
     IF (ar.contributor_system_cduid != ""
      AND ar.contributor_system_cduid != " "
      AND ar.contributor_system_cd=0)
      CALL logdebugmessage("cnt_alpha_response's contributor_system_cduid is missing:",ar
      .contributor_system_cduid),
      CALL addmissingcodes(ar.contributor_system_cduid)
     ENDIF
     IF (ar.vocab_axis_cduid != ""
      AND ar.vocab_axis_cduid != " "
      AND ar.vocab_axis_cd=0)
      CALL logdebugmessage("cnt_alpha_response's vocab_axis_cduid is missing:",ar.vocab_axis_cduid),
      CALL addmissingcodes(ar.vocab_axis_cduid)
     ENDIF
     IF (di.service_resource_cduid != ""
      AND di.service_resource_cduid != " "
      AND di.service_resource_cd=0)
      CALL logdebugmessage("cnt_dcp_interp's service_resource_cduid is missing:",di
      .service_resource_cduid),
      CALL addmissingcodes(di.service_resource_cduid)
     ENDIF
     IF (di.sex_cduid != ""
      AND di.sex_cduid != " "
      AND di.sex_cd=0)
      CALL logdebugmessage("cnt_dcp_interp's sex_cduid is missing:",di.sex_cduid),
      CALL addmissingcodes(di.sex_cduid)
     ENDIF
     IF (di2.service_resource_cduid != ""
      AND di2.service_resource_cduid != " "
      AND di2.service_resource_cd=0)
      CALL logdebugmessage("cnt_dcp_interp2's service_resource_cduid is missing:",di2
      .service_resource_cduid),
      CALL addmissingcodes(di2.service_resource_cduid)
     ENDIF
     IF (di2.sex_cduid != ""
      AND di2.sex_cduid != " "
      AND di2.sex_cd=0)
      CALL logdebugmessage("cnt_dcp_interp2's sex_cduid is missing:",di2.sex_cduid),
      CALL addmissingcodes(di2.sex_cduid)
     ENDIF
     IF (rf.text_type_cduid != ""
      AND rf.text_type_cduid != " "
      AND rf.text_type_cd=0)
      CALL logdebugmessage("cnt_ref_text's text_type_cduid is missing:",rf.text_type_cduid),
      CALL addmissingcodes(rf.text_type_cduid)
     ENDIF
     IF (e.service_resource_cduid != ""
      AND e.service_resource_cduid != " "
      AND e.service_resource_cd=0)
      CALL logdebugmessage("cnt_equation's service_resource_cduid is missing:",e
      .service_resource_cduid),
      CALL addmissingcodes(e.service_resource_cduid)
     ENDIF
     IF (e.sex_cduid != ""
      AND e.sex_cduid != " "
      AND e.sex_cd=0)
      CALL logdebugmessage("cnt_equation's sex_cduid is missing:",e.sex_cduid),
      CALL addmissingcodes(e.sex_cduid)
     ENDIF
     IF (e.species_cduid != ""
      AND e.species_cduid != " "
      AND e.species_cd=0)
      CALL logdebugmessage("cnt_equation's species_cduid is missing:",e.species_cduid),
      CALL addmissingcodes(e.species_cduid)
     ENDIF
     IF (e.age_from_units_cduid != ""
      AND e.age_from_units_cduid != " "
      AND e.age_from_units_cd=0)
      CALL logdebugmessage("cnt_equation's age_from_units_cduid is missing:",e.age_from_units_cduid),
      CALL addmissingcodes(e.age_from_units_cduid)
     ENDIF
     IF (e.age_to_units_cduid != ""
      AND e.age_to_units_cduid != " "
      AND e.age_to_units_cd=0)
      CALL logdebugmessage("cnt_equation's age_to_units_cduid is missing:",e.age_to_units_cduid),
      CALL addmissingcodes(e.age_to_units_cduid)
     ENDIF
     IF (ec.result_status_cduid != ""
      AND ec.result_status_cduid != " "
      AND ec.result_status_cd=0)
      CALL logdebugmessage("cnt_equation_component's result_status_cduid is missing:",ec
      .result_status_cduid),
      CALL addmissingcodes(ec.result_status_cduid)
     ENDIF
     IF (ec.units_cduid != ""
      AND ec.units_cduid != " "
      AND ec.units_cd=0)
      CALL logdebugmessage("cnt_equation_component's units_cduid is missing:",ec.units_cduid),
      CALL addmissingcodes(ec.units_cduid)
     ENDIF
     IF (dm.service_resource_cduid != ""
      AND dm.service_resource_cduid != " "
      AND dm.service_resource_cd=0)
      CALL logdebugmessage("cnt_data_map's service_resource_cduid is missing:",dm
      .service_resource_cduid),
      CALL addmissingcodes(dm.service_resource_cduid)
     ENDIF
     IF (om.offset_min_type_cduid != ""
      AND om.offset_min_type_cduid != " "
      AND om.offset_min_type_cd=0)
      CALL logdebugmessage("cnt_dta_offset_min's offset_min_type_cduid is missing:",om
      .offset_min_type_cduid),
      CALL addmissingcodes(om.offset_min_type_cduid)
     ENDIF
    WITH nocounter
   ;end select
   CALL bedlogmessage("getMissingCodeOfAForm","Exiting ...")
 END ;Subroutine
 SUBROUTINE getmissingcodeofasection(dummyvar)
   CALL bedlogmessage("getMissingCodeOfASection","Entering ...")
   SELECT INTO "nl:"
    FROM cnt_input i,
     cnt_dta d,
     cnt_dta_rrf_r rr,
     cnt_rrf rrf,
     cnt_rrf_key rrk,
     cnt_rrf_ar_r arr,
     cnt_alpha_response_key ark,
     cnt_alpha_response ar,
     cnt_dcp_interp di,
     cnt_dcp_interp2 di2,
     cnt_ref_text rf,
     cnt_equation e,
     cnt_equation_component ec,
     cnt_data_map dm,
     cnt_grid g,
     cnt_dta_offset_min om
    PLAN (i
     WHERE i.section_uid=section_uid)
     JOIN (d
     WHERE d.task_assay_uid=outerjoin(i.task_assay_uid))
     JOIN (rr
     WHERE rr.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (rrf
     WHERE rrf.rrf_uid=outerjoin(rr.rrf_uid))
     JOIN (rrk
     WHERE rrk.rrf_uid=outerjoin(rr.rrf_uid))
     JOIN (arr
     WHERE arr.rrf_uid=outerjoin(rrk.rrf_uid))
     JOIN (ark
     WHERE ark.ar_uid=outerjoin(arr.ar_uid))
     JOIN (ar
     WHERE ar.ar_uid=outerjoin(ark.ar_uid))
     JOIN (di
     WHERE di.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (di2
     WHERE di2.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (rf
     WHERE rf.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (e
     WHERE e.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (ec
     WHERE ec.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (dm
     WHERE dm.task_assay_uid=outerjoin(d.task_assay_uid))
     JOIN (g
     WHERE g.cnt_input_key_id=outerjoin(i.cnt_input_key_id))
     JOIN (om
     WHERE om.task_assay_uid=outerjoin(d.task_assay_uid))
    DETAIL
     IF (i.merge_name="CODE_VALUE"
      AND i.merge_id=0
      AND i.merge_uid != ""
      AND i.merge_uid != " ")
      CALL logdebugmessage("cnt_input's merge_uid is missing:",i.merge_uid),
      CALL addmissingcodes(i.merge_uid)
     ENDIF
     IF (d.activity_type_cduid != ""
      AND d.activity_type_cduid != " "
      AND d.activity_type_cd=0)
      CALL logdebugmessage("cnt_dta's activity_type_cduid is missing:",d.activity_type_cduid),
      CALL addmissingcodes(d.activity_type_cduid)
     ENDIF
     IF (d.default_result_type_cduid != ""
      AND d.default_result_type_cduid != " "
      AND d.default_result_type_cd=0)
      CALL logdebugmessage("cnt_dta's default_result_type_cduid is missing:",d
      .default_result_type_cduid),
      CALL addmissingcodes(d.default_result_type_cduid)
     ENDIF
     IF (d.history_activity_type_cduid != ""
      AND d.history_activity_type_cduid != " "
      AND d.history_activity_type_cd=0)
      CALL logdebugmessage("cnt_dta's history_activity_type_cduid is missing:",d
      .history_activity_type_cduid),
      CALL addmissingcodes(d.history_activity_type_cduid)
     ENDIF
     IF (d.bb_result_type_cduid != ""
      AND d.bb_result_type_cduid != " "
      AND d.bb_result_type_cd=0)
      CALL logdebugmessage("cnt_dta's bb_result_type_cduid is missing:",d.bb_result_type_cduid),
      CALL addmissingcodes(d.bb_result_type_cduid)
     ENDIF
     IF (d.rad_sect_type_cduid != ""
      AND d.rad_sect_type_cduid != " "
      AND d.rad_section_type_cd=0)
      CALL logdebugmessage("cnt_dta's rad_sect_type_cduid is missing:",d.rad_sect_type_cduid),
      CALL addmissingcodes(d.rad_sect_type_cduid)
     ENDIF
     IF (rrf.delta_check_type_cduid != ""
      AND rrf.delta_check_type_cduid != " "
      AND rrf.delta_check_type_cd=0)
      CALL logdebugmessage("cnt_rrf's delta_check_type_cduid is missing:",rrf.delta_check_type_cduid),
      CALL addmissingcodes(rrf.delta_check_type_cduid)
     ENDIF
     IF (rrf.units_cduid != ""
      AND rrf.units_cduid != " "
      AND rrf.units_cd=0)
      CALL logdebugmessage("cnt_rrf's units_cduid is missing:",rrf.units_cduid),
      CALL addmissingcodes(rrf.units_cduid)
     ENDIF
     IF (rrf.encntr_type_cduid != ""
      AND rrf.encntr_type_cduid != " "
      AND rrf.encntr_type_cd=0)
      CALL logdebugmessage("cnt_rrf's encntr_type_cduid is missing:",rrf.encntr_type_cduid),
      CALL addmissingcodes(rrf.encntr_type_cduid)
     ENDIF
     IF (rrk.species_cduid != ""
      AND rrk.species_cduid != " "
      AND rrk.species_cd=0)
      CALL logdebugmessage("cnt_rrf_key's species_cduid is missing:",rrk.species_cduid),
      CALL addmissingcodes(rrk.species_cduid)
     ENDIF
     IF (rrk.organism_cduid != ""
      AND rrk.organism_cduid != " "
      AND rrk.organism_cd=0)
      CALL logdebugmessage("cnt_rrf_key's organism_cduid is missing:",rrk.organism_cduid),
      CALL addmissingcodes(rrk.organism_cduid)
     ENDIF
     IF (rrk.service_resource_cduid != ""
      AND rrk.service_resource_cduid != " "
      AND rrk.service_resource_cd=0)
      CALL logdebugmessage("cnt_rrf_key's service_resource_cduid is missing:",rrk
      .service_resource_cduid),
      CALL addmissingcodes(rrk.service_resource_cduid)
     ENDIF
     IF (rrk.sex_cduid != ""
      AND rrk.sex_cduid != " "
      AND rrk.sex_cd=0)
      CALL logdebugmessage("cnt_rrf_key's sex_cduid is missing:",rrk.sex_cduid),
      CALL addmissingcodes(rrk.sex_cduid)
     ENDIF
     IF (rrk.age_from_units_cduid != ""
      AND rrk.age_from_units_cduid != " "
      AND rrk.age_from_units_cd=0)
      CALL logdebugmessage("cnt_rrf_key's age_from_units_cduid is missing:",rrk.age_from_units_cduid),
      CALL addmissingcodes(rrk.age_from_units_cduid)
     ENDIF
     IF (rrk.age_to_units_cduid != ""
      AND rrk.age_to_units_cduid != " "
      AND rrk.age_to_units_cd=0)
      CALL logdebugmessage("cnt_rrf_key's age_to_units_cduid is missing:",rrk.age_to_units_cduid),
      CALL addmissingcodes(rrk.age_to_units_cduid)
     ENDIF
     IF (rrk.specimen_type_cduid != ""
      AND rrk.specimen_type_cduid != " "
      AND rrk.specimen_type_cd=0)
      CALL logdebugmessage("cnt_rrf_key's specimen_type_cduid is missing:",rrk.specimen_type_cduid),
      CALL addmissingcodes(rrk.specimen_type_cduid)
     ENDIF
     IF (rrk.patient_condition_cduid != ""
      AND rrk.patient_condition_cduid != " "
      AND rrk.patient_condition_cd=0)
      CALL logdebugmessage("cnt_rrf_key's patient_condition_cduid is missing:",rrk
      .patient_condition_cduid),
      CALL addmissingcodes(rrk.patient_condition_cduid)
     ENDIF
     IF (arr.result_process_cduid != ""
      AND arr.result_process_cduid != " "
      AND arr.result_process_cd=0)
      CALL logdebugmessage("cnt_rrf_ar_r's result_process_cduid is missing:",arr.result_process_cduid
      ),
      CALL addmissingcodes(arr.result_process_cduid)
     ENDIF
     IF (ark.principle_type_cduid != ""
      AND ark.principle_type_cduid != " "
      AND ark.principle_type_cd=0)
      CALL logdebugmessage("cnt_alpha_response_key's principle_type_cduid is missing:",ark
      .principle_type_cduid),
      CALL addmissingcodes(ark.principle_type_cduid)
     ENDIF
     IF (ark.source_vocabulary_cduid != ""
      AND ark.source_vocabulary_cduid != " "
      AND ark.source_vocabulary_cd=0)
      CALL logdebugmessage("cnt_alpha_response_key's source_vocabulary_cduid is missing:",ark
      .source_vocabulary_cduid),
      CALL addmissingcodes(ark.source_vocabulary_cduid)
     ENDIF
     IF (ar.contributor_system_cduid != ""
      AND ar.contributor_system_cduid != " "
      AND ar.contributor_system_cd=0)
      CALL logdebugmessage("cnt_alpha_response's contributor_system_cduid is missing:",ar
      .contributor_system_cduid),
      CALL addmissingcodes(ar.contributor_system_cduid)
     ENDIF
     IF (ar.vocab_axis_cduid != ""
      AND ar.vocab_axis_cduid != " "
      AND ar.vocab_axis_cd=0)
      CALL logdebugmessage("cnt_alpha_response's vocab_axis_cduid is missing:",ar.vocab_axis_cduid),
      CALL addmissingcodes(ar.vocab_axis_cduid)
     ENDIF
     IF (di.service_resource_cduid != ""
      AND di.service_resource_cduid != " "
      AND di.service_resource_cd=0)
      CALL logdebugmessage("cnt_dcp_interp's service_resource_cduid is missing:",di
      .service_resource_cduid),
      CALL addmissingcodes(di.service_resource_cduid)
     ENDIF
     IF (di.sex_cduid != ""
      AND di.sex_cduid != " "
      AND di.sex_cd=0)
      CALL logdebugmessage("cnt_dcp_interp's sex_cduid is missing:",di.sex_cduid),
      CALL addmissingcodes(di.sex_cduid)
     ENDIF
     IF (di2.service_resource_cduid != ""
      AND di2.service_resource_cduid != " "
      AND di2.service_resource_cd=0)
      CALL logdebugmessage("cnt_dcp_interp2's service_resource_cduid is missing:",di2
      .service_resource_cduid),
      CALL addmissingcodes(di2.service_resource_cduid)
     ENDIF
     IF (di2.sex_cduid != ""
      AND di2.sex_cduid != " "
      AND di2.sex_cd=0)
      CALL logdebugmessage("cnt_dcp_interp2's sex_cduid is missing:",di2.sex_cduid),
      CALL addmissingcodes(di2.sex_cduid)
     ENDIF
     IF (rf.text_type_cduid != ""
      AND rf.text_type_cduid != " "
      AND rf.text_type_cd=0)
      CALL logdebugmessage("cnt_ref_text's text_type_cduid is missing:",rf.text_type_cduid),
      CALL addmissingcodes(rf.text_type_cduid)
     ENDIF
     IF (e.service_resource_cduid != ""
      AND e.service_resource_cduid != " "
      AND e.service_resource_cd=0)
      CALL logdebugmessage("cnt_equation's service_resource_cduid is missing:",e
      .service_resource_cduid),
      CALL addmissingcodes(e.service_resource_cduid)
     ENDIF
     IF (e.sex_cduid != ""
      AND e.sex_cduid != " "
      AND e.sex_cd=0)
      CALL logdebugmessage("cnt_equation's sex_cduid is missing:",e.sex_cduid),
      CALL addmissingcodes(e.sex_cduid)
     ENDIF
     IF (e.species_cduid != ""
      AND e.species_cduid != " "
      AND e.species_cd=0)
      CALL logdebugmessage("cnt_equation's species_cduid is missing:",e.species_cduid),
      CALL addmissingcodes(e.species_cduid)
     ENDIF
     IF (e.age_from_units_cduid != ""
      AND e.age_from_units_cduid != " "
      AND e.age_from_units_cd=0)
      CALL logdebugmessage("cnt_equation's age_from_units_cduid is missing:",e.age_from_units_cduid),
      CALL addmissingcodes(e.age_from_units_cduid)
     ENDIF
     IF (e.age_to_units_cduid != ""
      AND e.age_to_units_cduid != " "
      AND e.age_to_units_cd=0)
      CALL logdebugmessage("cnt_equation's age_to_units_cduid is missing:",e.age_to_units_cduid),
      CALL addmissingcodes(e.age_to_units_cduid)
     ENDIF
     IF (ec.result_status_cduid != ""
      AND ec.result_status_cduid != " "
      AND ec.result_status_cd=0)
      CALL logdebugmessage("cnt_equation_component's result_status_cduid is missing:",ec
      .result_status_cduid),
      CALL addmissingcodes(ec.result_status_cduid)
     ENDIF
     IF (ec.units_cduid != ""
      AND ec.units_cduid != " "
      AND ec.units_cd=0)
      CALL logdebugmessage("cnt_equation_component's units_cduid is missing:",ec.units_cduid),
      CALL addmissingcodes(ec.units_cduid)
     ENDIF
     IF (dm.service_resource_cduid != ""
      AND dm.service_resource_cduid != " "
      AND dm.service_resource_cd=0)
      CALL logdebugmessage("cnt_data_map's service_resource_cduid is missing:",dm
      .service_resource_cduid),
      CALL addmissingcodes(dm.service_resource_cduid)
     ENDIF
     IF (om.offset_min_type_cduid != ""
      AND om.offset_min_type_cduid != " "
      AND om.offset_min_type_cd=0)
      CALL logdebugmessage("cnt_dta_offset_min's offset_min_type_cduid is missing:",om
      .offset_min_type_cduid),
      CALL addmissingcodes(om.offset_min_type_cduid)
     ENDIF
    WITH nocounter
   ;end select
   CALL bedlogmessage("getMissingCodeOfASection","Exiting ...")
 END ;Subroutine
 SUBROUTINE addmissingcodes(missingcodeuid)
   DECLARE mcnt = i4 WITH protect, noconstant(0)
   DECLARE isexist = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SET isexist = locateval(num,1,size(missingcodes->codes,5),missingcodeuid,missingcodes->codes[num].
    uid)
   CALL logdebugmessage("addMissingCodes:isExist:",isexist)
   IF (isexist=0)
    SET mcnt = (size(missingcodes->codes,5)+ 1)
    CALL alterlist(missingcodes->codes,mcnt)
    SET missingcodes->codes[mcnt].uid = missingcodeuid
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(dummyvar)
   CALL bedlogmessage("populateReply ","Entering ...")
   DECLARE exnum = i4 WITH protect, noconstant(0)
   DECLARE repcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnt_code_value_key c,
     code_value_set s
    PLAN (c
     WHERE expand(exnum,1,size(missingcodes->codes,5),c.code_value_uid,missingcodes->codes[exnum].uid
      )
      AND c.code_value=0.00)
     JOIN (s
     WHERE s.code_set=outerjoin(c.code_set))
    HEAD c.code_value_uid
     repcnt = (repcnt+ 1), stat = alterlist(reply->codes,repcnt), reply->codes[repcnt].uid = c
     .code_value_uid,
     reply->codes[repcnt].display = c.display, reply->codes[repcnt].description = c.description,
     reply->codes[repcnt].cdf_meaning = c.cdf_meaning,
     reply->codes[repcnt].code_set = c.code_set, reply->codes[repcnt].ignore_ind = c.ignore_ind,
     reply->codes[repcnt].code_set_display = s.display
    WITH nocounter, expand = value(bedgetexpandind(size(missingcodes->codes,5)))
   ;end select
   CALL bedlogmessage("populateReply ","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
