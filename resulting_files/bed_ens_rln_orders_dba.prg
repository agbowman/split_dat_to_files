CREATE PROGRAM bed_ens_rln_orders:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 saved_order_list[1]
      2 saved_order = vc
    1 duplicate_order_list[1]
      2 duplicate_order = vc
    1 error_order_list[1]
      2 error_order = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 activate_order_list[1]
      2 activate_order = vc
    1 duplicate_dta_event_list[1]
      2 duplicate_dta_event = vc
  ) WITH protect
 ENDIF
 FREE RECORD change_active_ind_request
 RECORD change_active_ind_request(
   1 active_ind = i2
   1 catalog_cd = f8
 )
 FREE RECORD change_active_ind_reply
 RECORD change_active_ind_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cv_request
 RECORD cv_request(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD cv_reply
 RECORD cv_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dta_request
 RECORD dta_request(
   1 assay_list[*]
     2 action_flag = i2
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 general_info
       3 result_type_code_value = f8
       3 activity_type_code_value = f8
       3 delta_check_ind = i2
       3 inter_data_check_ind = i2
       3 res_proc_type_code_value = f8
       3 rad_section_type_code_value = f8
       3 single_select_ind = i2
       3 io_flag = i2
       3 default_type_flag = i2
       3 sci_notation_ind = i2
     2 data_map[*]
       3 action_flag = i4
       3 service_resource_code_value = f8
       3 min_digits = i4
       3 max_digits = i4
       3 dec_place = i4
     2 rr_list[*]
       3 action_flag = i4
       3 rrf_id = f8
       3 def_value = f8
       3 uom_code_value = f8
       3 from_age = i4
       3 from_age_code_value = f8
       3 to_age = i4
       3 to_age_code_value = f8
       3 sex_code_value = f8
       3 specimen_type_code_value = f8
       3 service_resource_code_value = f8
       3 ref_low = f8
       3 ref_high = f8
       3 ref_ind = i2
       3 crit_low = f8
       3 crit_high = f8
       3 crit_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 review_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 linear_ind = i2
       3 dilute_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 feasible_ind = i2
       3 alpha_list[*]
         4 action_flag = i2
         4 nomenclature_id = f8
         4 sequence = i4
         4 short_string = c60
         4 default_ind = i2
         4 use_units_ind = i2
         4 reference_ind = i2
         4 result_process_code_value = f8
         4 result_value = f8
         4 multi_alpha_sort_order = i4
       3 rule_list[*]
         4 action_flag = i2
         4 ref_range_notify_trig_id = f8
         4 trigger_name = vc
         4 trigger_seq_nbr = i4
       3 species_code_value = f8
       3 adv_deltas[*]
         4 action_flag = i2
         4 delta_ind = i2
         4 delta_low = f8
         4 delta_high = f8
         4 delta_check_type_code_value = f8
         4 delta_minutes = i4
         4 delta_value = f8
       3 delta_check_type_code_value = f8
       3 delta_minutes = i4
       3 delta_value = f8
       3 delta_chk_flag = i2
       3 mins_back = i4
       3 gestational_ind = i2
     2 equivalent_assay[*]
       3 action_flag = i4
       3 code_value = f8
 )
 FREE RECORD dta_reply
 RECORD dta_reply(
   1 assay_list[*]
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dta_loinc_request
 RECORD dta_loinc_request(
   1 codes[1]
     2 service_resource_code_value = f8
     2 assay_code_value = f8
     2 specimen_type_code = f8
     2 loinc_code = vc
     2 ignore_ind = i2
     2 code_type_ind = i2
     2 concept_identifier_dta_id = f8
 )
 FREE RECORD dta_loinc_reply
 RECORD dta_loinc_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE lab_source_cd = f8 WITH protect
 DECLARE glab_result_type_bill_cd = f8 WITH protect
 DECLARE ut_auth_cd = f8 WITH protect
 DECLARE cntr = i4 WITH protect
 DECLARE x = i4 WITH protect
 DECLARE i_event_cd_disp_key = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE msg = vc WITH protect
 DECLARE event_code_exists = i4 WITH protect
 DECLARE code_value_cnt = i4 WITH protect
 DECLARE i_def_docmnt_format_cd = f8 WITH protect
 DECLARE i_def_docmnt_storage_cd = f8 WITH protect
 DECLARE i_def_event_class_cd = f8 WITH protect
 DECLARE i_def_event_confid_level_cd = f8 WITH protect
 DECLARE i_event_cd_subclass_cd = f8 WITH protect
 DECLARE i_code_status_cd = f8 WITH protect
 DECLARE i_event_code_status_cd = f8 WITH protect
 RECORD internal(
   1 int_rec[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
 )
 RECORD dm_post_event_code_request(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 DECLARE glbcreatedtaevtcdsfornewdta(mnemonic=vc) = i2
 DECLARE posteventcodefordta(dummyvar=i2) = i2
 DECLARE verifycurqual(table_name=vc,data_field=vc) = i2
 DECLARE setdmposteventrequest(event_set_name=vc,event_cd_disp=vc,event_cd_descr=vc,
  event_cd_definition=vc,parent_cd=vc) = null
 SUBROUTINE glbcreatedtaevtcdsfornewdta(mnemonic)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=73
     AND cv.display_key="LAB"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     lab_source_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=289
     AND cv.display_key="17"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     glab_result_type_bill_cd = cv.code_value
    WITH nocounter
   ;end select
   SET cntr = 0
   SET x = 0
   SELECT INTO "nl:"
    dta.mnemonic, dta.task_assay_cd
    FROM discrete_task_assay dta
    WHERE dta.mnemonic=mnemonic
     AND dta.activity_type_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=106
      AND cv.cdf_meaning="GLB"
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     WITH nocounter))
     AND dta.default_result_type_cd != glab_result_type_bill_cd
     AND dta.active_ind=1
    HEAD REPORT
     cntr = 0
    DETAIL
     cntr = (cntr+ 1), stat = alterlist(internal->int_rec,cntr), internal->int_rec[cntr].
     task_assay_cd = dta.task_assay_cd,
     internal->int_rec[cntr].mnemonic = dta.mnemonic
    WITH nocounter
   ;end select
   IF (cntr > 0)
    FOR (x = 1 TO cntr)
     CALL setdmposteventrequest(substring(1,40,internal->int_rec[x].mnemonic),substring(1,40,internal
       ->int_rec[x].mnemonic),substring(1,60,internal->int_rec[x].mnemonic),internal->int_rec[x].
      mnemonic,internal->int_rec[x].task_assay_cd)
     IF (posteventcodefordta(0))
      SET msg = concat("Successfully Added code value events for assay: ",trim(
        dm_post_event_code_request->event_cd_definition),"..")
      CALL bedlogmessage(msg,"")
     ELSE
      SET msg = concat("Failed to add code value/ events for assay: ",trim(dm_post_event_code_request
        ->event_cd_definition),"..")
      CALL bedlogmessage(msg,"")
      RETURN(false)
     ENDIF
    ENDFOR
    CALL setdmposteventrequest(fillstring(40," "),"LAB","LAB","LAB",lab_source_cd)
    IF (posteventcodefordta(0))
     SET msg = concat("Sccessfully Added code value/events for assay: ",trim(
       dm_post_event_code_request->event_cd_definition),"..")
     CALL bedlogmessage(msg,"")
    ELSE
     SET msg = concat("Failed to add code value/events  for assay: ",trim(dm_post_event_code_request
       ->event_cd_definition),"..")
     CALL bedlogmessage(msg,"")
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE posteventcodefordta(dummyvar)
   SET i_event_cd_disp_key = cnvtupper(cnvtalphanum(dm_post_event_code_request->event_cd_disp))
   SET cnt = 0
   SELECT INTO "nl:"
    y = count(*)
    FROM code_value_event_r dpec
    WHERE (dpec.parent_cd=dm_post_event_code_request->parent_cd)
     AND (dpec.flex1_cd=dm_post_event_code_request->flex1_cd)
     AND (dpec.flex2_cd=dm_post_event_code_request->flex2_cd)
     AND (dpec.flex3_cd=dm_post_event_code_request->flex3_cd)
     AND (dpec.flex4_cd=dm_post_event_code_request->flex4_cd)
     AND (dpec.flex5_cd=dm_post_event_code_request->flex5_cd)
    DETAIL
     cnt = y
    WITH nocounter
   ;end select
   SET dm_post_event_code_request->event_cd = 0
   IF (cnt=0)
    SET event_code_exists = 0
    SELECT INTO "nl:"
     vec.event_cd
     FROM v500_event_code vec
     WHERE vec.event_cd_disp_key=i_event_cd_disp_key
      AND (vec.event_cd_disp=dm_post_event_code_request->event_cd_disp)
     DETAIL
      dm_post_event_code_request->event_cd = vec.event_cd, event_code_exists = 1
     WITH nocounter
    ;end select
    SET code_value_cnt = 0
    IF (event_code_exists=1)
     SELECT INTO "nl:"
      y = count(*)
      FROM code_value cv
      WHERE (cv.code_value=dm_post_event_code_request->event_cd)
      DETAIL
       code_value_cnt = y
      WITH nocounter
     ;end select
    ENDIF
    IF (event_code_exists=0)
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       dm_post_event_code_request->event_cd = y
      WITH nocounter
     ;end select
     SET i_def_docmnt_format_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->format)
       AND cv.code_set=23
      DETAIL
       i_def_docmnt_format_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_docmnt_storage_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->storage)
       AND cv.code_set=25
      DETAIL
       i_def_docmnt_storage_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_event_class_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_class)
       AND cv.code_set=53
      DETAIL
       i_def_event_class_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_event_confid_level_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_confid_level)
       AND cv.code_set=87
      DETAIL
       i_def_event_confid_level_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_event_cd_subclass_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_subclass)
       AND cv.code_set=102
      DETAIL
       i_event_cd_subclass_cd = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF (((event_code_exists=0) OR (code_value_cnt=0)) )
     SET i_code_status_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->status)
       AND cv.code_set=48
      DETAIL
       i_code_status_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_event_code_status_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_code_status)
       AND cv.code_set=8
      DETAIL
       i_event_code_status_cd = cv.code_value
      WITH nocounter
     ;end select
     INSERT  FROM code_value cv
      (cv.display, cv.code_set, cv.display_key,
      cv.description, cv.definition, cv.collation_seq,
      cv.active_type_cd, cv.active_ind, cv.active_dt_tm,
      cv.updt_dt_tm, cv.updt_id, cv.updt_cnt,
      cv.updt_task, cv.updt_applctx, cv.begin_effective_dt_tm,
      cv.end_effective_dt_tm, cv.data_status_cd, cv.data_status_dt_tm,
      cv.data_status_prsnl_id, cv.active_status_prsnl_id, cv.code_value)
      VALUES(dm_post_event_code_request->event_cd_disp, 72, i_event_cd_disp_key,
      dm_post_event_code_request->event_cd_descr, dm_post_event_code_request->event_cd_definition, 1,
      i_code_status_cd, 1, cnvtdatetime(curdate,curtime3),
      cnvtdatetime(curdate,curtime3), 12087, 1,
      12087, 12087, cnvtdatetime(curdate,curtime3),
      cnvtdatetime("31-dec-2100"), i_event_code_status_cd, cnvtdatetime(curdate,curtime3),
      0, 0, dm_post_event_code_request->event_cd)
      WITH nocounter
     ;end insert
     IF (verifycurqual("code_value",trim(dm_post_event_code_request->event_cd_definition))=false)
      RETURN(false)
     ENDIF
     IF (event_code_exists=0)
      INSERT  FROM v500_event_code
       (event_cd, event_cd_definition, event_cd_descr,
       event_cd_disp, event_cd_disp_key, code_status_cd,
       def_docmnt_format_cd, def_docmnt_storage_cd, def_event_class_cd,
       def_event_confid_level_cd, event_add_access_ind, event_cd_subclass_cd,
       event_chg_access_ind, event_set_name, event_code_status_cd,
       updt_dt_tm, updt_applctx, updt_cnt,
       updt_id, updt_task)
       VALUES(dm_post_event_code_request->event_cd, dm_post_event_code_request->event_cd_definition,
       dm_post_event_code_request->event_cd_descr,
       dm_post_event_code_request->event_cd_disp, i_event_cd_disp_key, i_code_status_cd,
       i_def_docmnt_format_cd, i_def_docmnt_storage_cd, i_def_event_class_cd,
       i_def_event_confid_level_cd, 0, i_event_cd_subclass_cd,
       0, dm_post_event_code_request->event_set_name, i_event_code_status_cd,
       cnvtdatetime(curdate,curtime3), 12087, 1,
       12087, 12087)
       WITH nocounter
      ;end insert
      IF (verifycurqual("v500_event_code",trim(dm_post_event_code_request->event_cd_definition))=
      false)
       RETURN(false)
      ENDIF
     ENDIF
    ENDIF
    INSERT  FROM code_value_event_r
     (event_cd, parent_cd, flex1_cd,
     flex2_cd, flex3_cd, flex4_cd,
     flex5_cd, updt_dt_tm, updt_id,
     updt_cnt, updt_task, updt_applctx)
     VALUES(dm_post_event_code_request->event_cd, dm_post_event_code_request->parent_cd,
     dm_post_event_code_request->flex1_cd,
     dm_post_event_code_request->flex2_cd, dm_post_event_code_request->flex3_cd,
     dm_post_event_code_request->flex4_cd,
     dm_post_event_code_request->flex5_cd, cnvtdatetime(curdate,curtime3), 12087,
     1, 12087, 12087)
     WITH nocounter
    ;end insert
    IF (verifycurqual("code_value_event_r",trim(dm_post_event_code_request->event_cd_definition))=
    false)
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE verifycurqual(table_name,data_field)
   CALL bederrorcheck(concat("Failed to add new code to table:",table_name,""))
   IF (curqual=0)
    SET msg = concat("Failed to add code value/events for assay: ",data_field," to the table :",
     table_name)
    CALL bedlogmessage(msg,"")
    RETURN(false)
   ENDIF
   SET msg = concat("Added code values/events for assay: ",data_field," to the table :",table_name)
   CALL bedlogmessage(msg,"")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setdmposteventrequest(event_set_name,event_cd_disp,event_cd_descr,event_cd_definition,
  parent_cd)
   SET dm_post_event_code_request->event_set_name = event_set_name
   SET dm_post_event_code_request->event_cd_disp = event_cd_disp
   SET dm_post_event_code_request->event_cd_descr = event_cd_descr
   SET dm_post_event_code_request->event_cd_definition = event_cd_definition
   SET dm_post_event_code_request->status = "ACTIVE"
   SET dm_post_event_code_request->format = "UNKNOWN"
   SET dm_post_event_code_request->storage = "UNKNOWN"
   SET dm_post_event_code_request->event_class = "UNKNOWN"
   SET dm_post_event_code_request->event_confid_level = "ROUTCLINICAL"
   SET dm_post_event_code_request->event_subclass = "UNKNOWN"
   SET dm_post_event_code_request->event_code_status = "AUTH"
   SET dm_post_event_code_request->event_cd = 0.0
   SET dm_post_event_code_request->parent_cd = parent_cd
   SET dm_post_event_code_request->flex1_cd = 0.0
   SET dm_post_event_code_request->flex2_cd = 0.0
   SET dm_post_event_code_request->flex3_cd = 0.0
   SET dm_post_event_code_request->flex4_cd = 0.0
   SET dm_post_event_code_request->flex5_cd = 0.0
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE active_cd = f8 WITH protect, noconstant(0)
 DECLARE inactive_cd = f8 WITH protect, noconstant(0)
 DECLARE result_type_cd = f8 WITH protect, noconstant(0)
 DECLARE cat_cd = f8 WITH protect, noconstant(0)
 DECLARE act_cd = f8 WITH protect, noconstant(0)
 DECLARE act_sub_cd = f8 WITH protect, noconstant(0)
 DECLARE new_dta_cd = f8 WITH protect, noconstant(0)
 DECLARE new_catalog_cd = f8 WITH protect, noconstant(0)
 DECLARE new_synonym_cd = f8 WITH protect, noconstant(0)
 DECLARE primary_mnemonic_type_cd = f8 WITH protect, noconstant(0)
 DECLARE ancillary_mnemonic_type_cd = f8 WITH protect, noconstant(0)
 DECLARE duplicate_catalog_cd = f8 WITH protect, noconstant(0)
 DECLARE dcp_clin_category_cd = f8 WITH protect, noconstant(0)
 DECLARE ord_cat_contributor_cd = f8 WITH protect, noconstant(0)
 DECLARE orc_found = vc WITH protect, noconstant("")
 DECLARE orc_was_deactivate = vc WITH protect, noconstant("")
 DECLARE orl_facility_found = vc WITH protect, noconstant("")
 DECLARE alias_found = vc WITH protect, noconstant("")
 DECLARE dta_found = vc WITH protect, noconstant("")
 DECLARE order_dta_found = vc WITH protect, noconstant("")
 DECLARE apr_found = vc WITH protect, noconstant("")
 DECLARE facility_coll_req_found = vc WITH protect, noconstant("")
 DECLARE msg = vc WITH protect, noconstant("")
 DECLARE assay_new_disp = vc WITH protect, noconstant("")
 DECLARE assay_new_code = vc WITH protect, noconstant("")
 DECLARE num_orders = i4 WITH protect, noconstant(0)
 DECLARE num_benches = i4 WITH protect, noconstant(0)
 DECLARE num_coll_req = i4 WITH protect, noconstant(0)
 DECLARE num_alt_coll_req = i4 WITH protect, noconstant(0)
 DECLARE num_dtas = i4 WITH protect, noconstant(0)
 DECLARE msg_var = i4 WITH protect, noconstant(0)
 DECLARE error_msg_var = i4 WITH protect, noconstant(0)
 DECLARE saved_orders = i4 WITH protect, noconstant(0)
 DECLARE dup_orders = i4 WITH protect, noconstant(0)
 DECLARE error_orders = i4 WITH protect, noconstant(0)
 DECLARE activate_orders = i4 WITH protect, noconstant(0)
 DECLARE newcollectioninfosequence = f8 WITH protect, noconstant(0)
 DECLARE existingcollectioninfosequence = f8 WITH protect, noconstant(0)
 DECLARE alternate_coll_req_found = vc WITH protect, noconstant("")
 DECLARE newlabhandlingidsequence = f8 WITH protect, noconstant(0)
 DECLARE oldlabhandlingidsequence = f8 WITH protect, noconstant(0)
 DECLARE labhandlingcd = f8 WITH protect, noconstant(0)
 DECLARE lab_handling_cd_found = vc WITH protect, noconstant("")
 DECLARE collreqsequence = i4 WITH protect, noconstant(0)
 DECLARE code_value_alias_found = vc WITH protect, noconstant("")
 DECLARE code_value_outbound_found = vc WITH protect, noconstant("")
 DECLARE procedure_specimen_type_found = vc WITH protect, noconstant("")
 DECLARE dta_name_found = vc WITH protect, noconstant("")
 DECLARE is_optional_assay = f8 WITH protect, noconstant(0)
 DECLARE messsage_log_continue = vc WITH protect, noconstant("")
 DECLARE message_to_log = vc WITH protect, noconstant("")
 DECLARE position = i4 WITH protect, noconstant(0)
 DECLARE ii = i2
 DECLARE zz = i2
 DECLARE benchsequene = i4
 DECLARE min_vol_units = vc
 DECLARE mseq = i2
 DECLARE tcnt = i2
 DECLARE service_resource_index = i4
 DECLARE indexer = i4
 DECLARE num_cdtas = i4
 DECLARE bench_cd = f8
 DECLARE dup_dta_event_count = i4 WITH protect, noconstant(0)
 DECLARE dup_dta_event_entry_found = vc WITH protect, noconstant("")
 DECLARE assay_event_relation = f8
 DECLARE dup_event_cd = f8
 DECLARE openlogfile(dummyvar=i2) = i2
 DECLARE logmessage(msg=vc) = i2
 DECLARE openerrorlogfile(dummyvar=i2) = i2
 DECLARE logerrormessage(errormsg=vc) = i2
 DECLARE initializevariables(dummyvar=i2) = i2
 DECLARE findexistingorder(orderindex=i4) = i2
 DECLARE saveneworder(orderindex=i4) = i2
 DECLARE ensureorderdtasandeventcode(orderindex=i4,catalogcd=f8) = i2
 DECLARE orcresourcelistsave(catalogcd=f8) = i2
 DECLARE savecollectionrequirements(orderindex=i4,catalogcd=f8) = i2
 DECLARE savealternatecontainers(orderindex=i4,catalogcd=f8,newcollectioninfosequence=f8,benchsequene
  =i4) = i2
 DECLARE savenewlabhandling(orderindex=i4,catalogcd=f8,newcollectioninfosequence=f8,labhandlingcd=f8)
  = i2
 DECLARE savecodevaluealias(contributorsourcecd=f8,aliascode=vc,catalogcd=f8,codeset=i4) = i2
 DECLARE savecodevalueoutbound(contributorsourcecd=f8,aliascode=vc,catalogcd=f8,codeset=i4) = i2
 DECLARE saveprocedurespecimentype(orderindex=i4,catalogcd=f8) = i2
 DECLARE addassayprocessing(newdtacd=f8) = i2
 DECLARE addloinccode(orderindex=i4,datindex=i4) = i2
 DECLARE addprofiletask(newcatalogcd=f8,newdtacd=f8) = i2
 DECLARE addalternatecontainer(catalogcd=f8,orderindex=i4,newcollectioninfosequence=f8,
  altcollreqsequence=i4,benchsequene=i4) = i2
 DECLARE updatealternatecontainer(catalogcd=f8,orderindex=i4,newcollectioninfosequence=f8,
  altcollreqsequence=i4,benchsequene=i4) = i2
 DECLARE deletealternatecontainer(catalogcd=f8,newcollectioninfosequence=f8,orderindex=i4,
  benchsequene=i4) = i2
 DECLARE verifydtadisplay(assaynewdisp=vc,newdtacd=f8) = i2
 CALL openlogfile(0)
 CALL openerrorlogfile(0)
 CALL initializevariables(0)
 SET ii = 0
 SET num_orders = size(request->order_list,5)
 SET num_benches = size(request->service_resource_list,5)
 FOR (ii = 1 TO num_orders)
   SET duplicate_catalog_cd = 0.0
   SET orc_found = "N"
   SET orc_was_deactivate = "N"
   SET alias_found = "N"
   IF ((request->order_list[ii].action_flag=1))
    CALL logmessage("New Order Build Begin...")
    CALL findexistingorder(ii)
    IF (orc_found="Y")
     IF (orc_was_deactivate="Y")
      SET change_active_ind_request->catalog_cd = duplicate_catalog_cd
      SET change_active_ind_request->active_ind = 1
      SET trace = recpersist
      CALL logmessage("* before calling bed_ens_rln_set_ord_act_ind")
      EXECUTE bed_ens_rln_set_ord_act_ind  WITH replace("REQUEST",change_active_ind_request), replace
      ("REPLY",change_active_ind_reply)
      IF ((change_active_ind_reply->status_data.status="S"))
       CALL logmessage("* bed_ens_rln_set_ord_act_ind executed successfully")
       SET activate_orders = (activate_orders+ 1)
       IF (activate_orders > 1)
        SET stat = alter(reply->activate_order_list,activate_orders)
       ENDIF
       SET reply->activate_order_list[activate_orders].activate_order = request->order_list[ii].
       order_primary_syn
      ELSE
       CALL logmessage("* bed_ens_rln_set_ord_act_ind execution failed")
       CALL logerrormessage("* bed_ens_rln_set_ord_act_ind execution failed")
      ENDIF
     ENDIF
     CALL orcresourcelistsave(duplicate_catalog_cd)
     CALL saveprocedurespecimentype(ii,duplicate_catalog_cd)
     CALL savecollectionrequirements(ii,duplicate_catalog_cd)
     CALL ensureorderdtasandeventcode(ii,duplicate_catalog_cd)
     CALL logmessage("Duplicate Order!")
     IF (orc_was_deactivate="N")
      SET dup_orders = (dup_orders+ 1)
      IF (dup_orders > 1)
       SET stat = alter(reply->duplicate_order_list,dup_orders)
      ENDIF
      SET reply->duplicate_order_list[dup_orders].duplicate_order = request->order_list[ii].
      order_primary_syn
     ENDIF
    ELSE
     IF (saveneworder(ii))
      COMMIT
      CALL logmessage("New Order Build Complete!")
      SET saved_orders = (saved_orders+ 1)
      IF (saved_orders > 1)
       SET stat = alter(reply->saved_order_list,saved_orders)
      ENDIF
      SET reply->saved_order_list[saved_orders].saved_order = request->order_list[ii].
      order_primary_syn
     ELSE
      ROLLBACK
      CALL logmessage("Error! New Order Build Incomplete. Transactions rolled back.")
      SET error_orders = (error_orders+ 1)
      IF (error_orders > 1)
       SET stat = alter(reply->error_order_list,error_orders)
      ENDIF
      SET reply->error_order_list[error_orders].error_order = request->order_list[ii].
      order_primary_syn
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE openlogfile(dummyvar)
   SELECT INTO "ccluserdir:bed_save_rln_orders.log"
    msg_var
    HEAD REPORT
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
     col + 1, "Bedrock Save RLN Orders Log"
    DETAIL
     row + 2, col 2, " "
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logmessage(msg)
   SET position = 1
   SET messsage_log_continue = "Y"
   WHILE (messsage_log_continue="Y")
     SET message_to_log = msg
     IF (textlen(msg) < 120)
      SET messsage_log_continue = "N"
     ELSE
      SET message_to_log = substring(position,120,msg)
      SET msg = substring((position+ 120),textlen(msg),msg)
     ENDIF
     SELECT INTO "ccluserdir:bed_save_rln_orders.log"
      msg_var
      DETAIL
       row + 1, col 0, message_to_log
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE openerrorlogfile(dummyvar)
   SELECT INTO "ccluserdir:bed_save_rln_orders_error.log"
    error_msg_var
    HEAD REPORT
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
     col + 1, "Bedrock Save RLN Orders Error Log"
    DETAIL
     row + 2, col 2, " "
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logerrormessage(errormsg)
   SET position = 1
   SET messsage_log_continue = "Y"
   WHILE (messsage_log_continue="Y")
     SET message_to_log = errormsg
     IF (textlen(errormsg) < 120)
      SET messsage_log_continue = "N"
     ELSE
      SET message_to_log = substring(position,120,errormsg)
      SET errormsg = substring((position+ 120),textlen(errormsg),errormsg)
     ENDIF
     SELECT INTO "ccluserdir:bed_save_rln_orders_error.log"
      error_msg_var
      DETAIL
       row + 1, col 0, message_to_log
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE initializevariables(dummyvar)
   CALL logmessage("***initializeVariables***. Entering ...")
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=48
      AND c.cdf_meaning="ACTIVE")
    DETAIL
     active_cd = c.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Active Code: ",cnvtstring(active_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=48
      AND c.cdf_meaning="INACTIVE")
    DETAIL
     inactive_cd = c.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Inactive Code: ",cnvtstring(inactive_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=289
      AND c.cdf_meaning="7"
      AND c.active_ind=1)
    DETAIL
     result_type_cd = c.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Result Type (Freetext) Code: ",cnvtstring(result_type_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=6000
      AND c.cdf_meaning="GENERAL LAB"
      AND c.active_ind=1)
    DETAIL
     cat_cd = c.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Catalog Type Code: ",cnvtstring(cat_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=106
      AND c.cdf_meaning="GLB"
      AND c.active_ind=1)
    DETAIL
     act_cd = c.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Activity Type Code: ",cnvtstring(act_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM rln_contributor rc
    PLAN (rc
     WHERE (rc.contributor_source_cd=request->contributor_source_cd))
    DETAIL
     act_sub_cd = rc.activity_type_cd
    WITH nocounter
   ;end select
   SET msg = concat("Sub-Activity Type Code: ",cnvtstring(act_sub_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=6011
      AND cv.display="Primary"
      AND cv.active_ind=1)
    DETAIL
     primary_mnemonic_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Primary Mnemonic Type Code: ",cnvtstring(primary_mnemonic_type_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=6011
     AND cv.display="Ancillary"
     AND cv.active_ind=1
    DETAIL
     ancillary_mnemonic_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Ancillary Mnemonic Type Code: ",cnvtstring(ancillary_mnemonic_type_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13016
     AND cv.cdf_meaning="ORD CAT"
     AND cv.active_ind=1
    DETAIL
     ord_cat_contributor_cd = cv.code_value
    WITH nocounter
   ;end select
   SET msg = concat("Order Catalog External Contributor Type Code: ",cnvtstring(
     ord_cat_contributor_cd))
   CALL logmessage(msg)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=16389
     AND cv.display_key="LABORATORY"
     AND cv.active_ind=1
    DETAIL
     dcp_clin_category_cd = cv.code_value
    WITH nocounter
   ;end select
   SET msg = concat("DCP Clinical Category Code: ",cnvtstring(dcp_clin_category_cd))
   CALL logmessage(msg)
   CALL logmessage("***initializeVariables***. Exiting ...")
 END ;Subroutine
 SUBROUTINE findexistingorder(orderindex)
   CALL logmessage("***findExistingOrder***. Entering ...")
   SELECT INTO "nl:"
    o.catalog_cd
    FROM order_catalog o
    PLAN (o
     WHERE (o.primary_mnemonic=request->order_list[orderindex].order_primary_syn))
    DETAIL
     orc_found = "Y", duplicate_catalog_cd = o.catalog_cd
     IF (o.active_ind=0)
      orc_was_deactivate = "Y"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cva.code_value
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.alias=request->order_list[orderindex].alias_code)
      AND cva.code_set=200
      AND (cva.contributor_source_cd=request->contributor_source_cd))
    DETAIL
     orc_found = "Y", alias_found = "Y", duplicate_catalog_cd = cva.code_value
    WITH nocounter
   ;end select
   IF (orc_found="Y")
    CALL logmessage("Code value Alias/Outbound is inserted or updated for the found order")
    CALL savecodevaluealias(request->contributor_source_cd,request->order_list[orderindex].alias_code,
     duplicate_catalog_cd,200)
    CALL savecodevalueoutbound(request->contributor_source_cd,request->order_list[orderindex].
     alias_code,duplicate_catalog_cd,200)
    CALL logmessage("Code value Alias/Outbound Insertion or Updation compleated for the found order")
    IF (alias_found="Y")
     SET msg = concat("Found existing record on the code_value_alias table for order alias: ",request
      ->order_list[orderindex].alias_code)
     CALL logmessage(msg)
     CALL logerrormessage(msg)
    ENDIF
    SET msg = concat("Found existing record on the order_catalog table for order primary synonym: ",
     request->order_list[orderindex].order_primary_syn)
    CALL logmessage(msg)
    CALL logerrormessage(msg)
   ELSE
    SET msg = concat(
     "Found no existing record on the order_catalog table for order primary synonym: ",request->
     order_list[orderindex].order_primary_syn)
    CALL logmessage(msg)
   ENDIF
   CALL logmessage("***findExistingOrder***. Exiting ...")
 END ;Subroutine
 SUBROUTINE savecollectionrequirements(orderindex,catalogcd)
   SET num_coll_req = size(request->order_list[orderindex].coll_req_list,5)
   SET collreqsequence = 1
   SET min_vol_units = fillstring(40," ")
   SET labhandlingcd = request->order_list[orderindex].coll_req_list[collreqsequence].lab_handling_cd
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=54
     AND (cv.code_value=request->order_list[orderindex].coll_req_list[collreqsequence].unit_cd)
    DETAIL
     min_vol_units = cv.display
    WITH nocounter
   ;end select
   SET benchsequene = 0
   FOR (benchsequene = 1 TO num_benches)
     SET existingcollectioninfosequence = 0
     SET facility_coll_req_found = "N"
     SELECT INTO "nl:"
      FROM collection_info_qualifiers ciq
      PLAN (ciq
       WHERE ciq.catalog_cd=catalogcd
        AND (ciq.service_resource_cd=request->service_resource_list[benchsequene].service_resource_cd
       )
        AND (ciq.specimen_type_cd=request->order_list[orderindex].specimen_type_cd)
        AND (request->order_list[orderindex].coll_req_list[collreqsequence].is_alternate_container=0)
       )
      DETAIL
       facility_coll_req_found = "Y", existingcollectioninfosequence = ciq.sequence
      WITH nocounter
     ;end select
     IF (facility_coll_req_found="N")
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)"##################;rp0"
       FROM collection_info_qualifiers
       DETAIL
        newcollectioninfosequence = y
       WITH format, nocounter
      ;end select
      INSERT  FROM collection_info_qualifiers ciq
       SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
        ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.catalog_cd = catalogcd,
        ciq.coll_class_cd = request->order_list[orderindex].coll_req_list[collreqsequence].
        coll_class_cd, ciq.min_vol = request->order_list[orderindex].coll_req_list[collreqsequence].
        min_vol, ciq.min_vol_units = min_vol_units,
        ciq.required_ind = null, ciq.sequence = newcollectioninfosequence, ciq.spec_cntnr_cd =
        request->order_list[orderindex].coll_req_list[collreqsequence].container_cd,
        ciq.spec_hndl_cd = request->order_list[orderindex].coll_req_list[collreqsequence].
        spec_hndl_cd, ciq.species_cd = 0.0, ciq.specimen_type_cd = request->order_list[orderindex].
        specimen_type_cd,
        ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq.service_resource_cd
         = request->service_resource_list[benchsequene].service_resource_cd,
        ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = request->order_list[
        orderindex].coll_req_list[collreqsequence].unit_cd,
        ciq.collection_priority_cd = 0.0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Failed to add collection requirements for service_resource_cd: ",trim(
         cnvtstring(request->service_resource_list[benchsequene].service_resource_cd)),
        " to the collection_info_qualifiers table.")
       CALL logmessage(msg)
       CALL logerrormessage(msg)
       RETURN(false)
      ELSE
       SET msg = concat("Added collection requirements for service_resource_cd: ",trim(cnvtstring(
          request->service_resource_list[benchsequene].service_resource_cd)),
        " to the collection_info_qualifiers table.")
       CALL logmessage(msg)
      ENDIF
      CALL savealternatecontainers(orderindex,catalogcd,newcollectioninfosequence,benchsequene)
      IF (labhandlingcd != 0.0)
       CALL savenewlabhandling(orderindex,catalogcd,newcollectioninfosequence,labhandlingcd)
      ENDIF
     ELSE
      UPDATE  FROM collection_info_qualifiers ciq
       SET ciq.age_from_minutes = 0, ciq.age_to_minutes = 78840000, ciq.aliquot_ind = 0,
        ciq.aliquot_route_sequence = 0, ciq.aliquot_seq = 0, ciq.coll_class_cd = request->order_list[
        orderindex].coll_req_list[collreqsequence].coll_class_cd,
        ciq.min_vol = request->order_list[orderindex].coll_req_list[collreqsequence].min_vol, ciq
        .min_vol_units = min_vol_units, ciq.required_ind = null,
        ciq.spec_cntnr_cd = request->order_list[orderindex].coll_req_list[collreqsequence].
        container_cd, ciq.spec_hndl_cd = request->order_list[orderindex].coll_req_list[
        collreqsequence].spec_hndl_cd, ciq.species_cd = 0.0,
        ciq.specimen_type_cd = request->order_list[orderindex].specimen_type_cd, ciq.updt_applctx =
        reqinfo->updt_applctx, ciq.updt_cnt = (ciq.updt_cnt+ 1),
        ciq.updt_dt_tm = cnvtdatetime(curdate,curtime), ciq.updt_id = reqinfo->updt_id, ciq.updt_task
         = reqinfo->updt_task,
        ciq.optional_ind = 0, ciq.additional_labels = 0, ciq.units_cd = request->order_list[
        orderindex].coll_req_list[collreqsequence].unit_cd,
        ciq.collection_priority_cd = 0.0
       WHERE ciq.sequence=existingcollectioninfosequence
        AND (ciq.service_resource_cd=request->service_resource_list[benchsequene].service_resource_cd
       )
        AND ciq.catalog_cd=catalogcd
       WITH nocounter
      ;end update
      CALL savealternatecontainers(orderindex,catalogcd,existingcollectioninfosequence,benchsequene)
      IF (labhandlingcd != 0.0)
       CALL savenewlabhandling(orderindex,catalogcd,existingcollectioninfosequence,labhandlingcd)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE savealternatecontainers(orderindex,catalogcd,newcollectioninfosequence,benchsequene)
   DECLARE iter_alt_container = i4 WITH noconstant(0)
   SET msg = concat("saveAlternatecontainers",cnvtstring(orderindex),trim(cnvtstring(catalogcd)),
    cnvtstring(newcollectioninfosequence))
   CALL logmessage(msg)
   SET msg = cnvtstring(orderindex)
   CALL logmessage(msg)
   SET num_alt_coll_req = size(request->order_list[orderindex].coll_req_list,5)
   SET msg = cnvtstring(num_alt_coll_req)
   CALL logmessage(msg)
   IF (num_alt_coll_req > 1)
    FOR (altcollreqsequence = 2 TO num_alt_coll_req)
      SET msg = cnvtstring(altcollreqsequence)
      CALL logmessage(msg)
      SET alternate_coll_req_found = "N"
      SELECT INTO "nl:"
       FROM alt_collection_info ciq
       PLAN (ciq
        WHERE ciq.catalog_cd=catalogcd
         AND (ciq.spec_cntnr_cd=request->order_list[orderindex].coll_req_list[altcollreqsequence].
        container_cd)
         AND (ciq.specimen_type_cd=request->order_list[orderindex].specimen_type_cd)
         AND (request->order_list[orderindex].coll_req_list[altcollreqsequence].
        is_alternate_container=1)
         AND ciq.coll_info_seq=newcollectioninfosequence)
       DETAIL
        alternate_coll_req_found = "Y"
       WITH nocounter
      ;end select
      IF (alternate_coll_req_found="N")
       CALL addalternatecontainer(catalogcd,orderindex,newcollectioninfosequence,altcollreqsequence,
        benchsequene)
      ELSE
       CALL updatealternatecontainer(catalogcd,orderindex,newcollectioninfosequence,
        altcollreqsequence,benchsequene)
      ENDIF
    ENDFOR
    CALL deletealternatecontainer(catalogcd,newcollectioninfosequence,orderindex,benchsequene)
   ENDIF
 END ;Subroutine
 SUBROUTINE orcresourcelistsave(catalogcd)
   SET mseq = 0
   SET tcnt = 0
   SET zz = 0
   FOR (zz = 1 TO num_benches)
     SET orl_facility_found = "N"
     SELECT INTO "nl:"
      FROM orc_resource_list orl
      PLAN (orl
       WHERE orl.catalog_cd=catalogcd
        AND (orl.service_resource_cd=request->service_resource_list[zz].service_resource_cd))
      DETAIL
       orl_facility_found = "Y"
      WITH nocounter
     ;end select
     IF (orl_facility_found="N")
      SELECT INTO "nl:"
       orl.sequence
       FROM orc_resource_list orl
       PLAN (orl
        WHERE orl.catalog_cd=catalogcd)
       DETAIL
        tcnt = (tcnt+ 1)
        IF (mseq < orl.sequence)
         mseq = orl.sequence
        ENDIF
       WITH nocounter
      ;end select
      IF (tcnt=0)
       SET mseq = 0
      ELSE
       SET mseq = (mseq+ 1)
      ENDIF
      INSERT  FROM orc_resource_list orl
       SET orl.service_resource_cd = request->service_resource_list[zz].service_resource_cd, orl
        .catalog_cd = catalogcd, orl.sequence = mseq,
        orl.primary_ind = 1, orl.script_name = " ", orl.updt_applctx = reqinfo->updt_applctx,
        orl.updt_dt_tm = cnvtdatetime(curdate,curtime), orl.updt_cnt = 0, orl.updt_id = reqinfo->
        updt_id,
        orl.updt_task = reqinfo->updt_task, orl.active_ind = 1, orl.active_status_cd = active_cd,
        orl.active_status_dt_tm = cnvtdatetime(curdate,curtime), orl.active_status_prsnl_id = reqinfo
        ->updt_id, orl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        orl.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Failed to add order routing for service_resource_cd: ",trim(cnvtstring(
          request->service_resource_list[zz].service_resource_cd))," to the orc_resource_list table."
        )
       CALL logmessage(msg)
       CALL logerrormessage(msg)
       RETURN(false)
      ELSE
       SET msg = concat("Added order routing for service_resource_cd: ",trim(cnvtstring(request->
          service_resource_list[zz].service_resource_cd))," to the orc_resource_list table.")
       CALL logmessage(msg)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE saveneworder(orderindex)
   CALL logmessage("***saveNewOrder***. Entering ...")
   SET cv_request->cd_value_list[1].action_flag = 1
   SET cv_request->cd_value_list[1].code_set = 200
   SET cv_request->cd_value_list[1].display = substring(1,40,request->order_list[orderindex].
    order_primary_syn)
   SET cv_request->cd_value_list[1].description = substring(1,60,request->order_list[orderindex].
    order_description)
   SET cv_request->cd_value_list[1].active_ind = 1
   SET cv_request->cd_value_list[1].cki = ""
   SET cv_request->cd_value_list[1].concept_cki = ""
   SET cv_request->cd_value_list[1].definition = " "
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",cv_request), replace("REPLY",cv_reply)
   IF ((cv_reply->status_data.status="S")
    AND (cv_reply->qual[1].code_value > 0))
    SET new_catalog_cd = cv_reply->qual[1].code_value
    SET msg = concat("Added orderable: ",trim(request->order_list[orderindex].order_primary_syn),
     " to the code_value table. New orderable code value: ",cnvtstring(new_catalog_cd))
    CALL logmessage(msg)
   ELSE
    SET msg = concat("Failed to add orderable: ",trim(request->order_list[orderindex].
      order_primary_syn)," to the code_value table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ENDIF
   INSERT  FROM order_catalog oc
    SET oc.catalog_cd = new_catalog_cd, oc.dcp_clin_cat_cd = dcp_clin_category_cd, oc.catalog_type_cd
      = cat_cd,
     oc.activity_type_cd = act_cd, oc.activity_subtype_cd = act_sub_cd, oc.oe_format_id = request->
     order_list[orderindex].oef_id,
     oc.resource_route_lvl = 1, oc.orderable_type_flag = 0, oc.active_ind = 1,
     oc.description = request->order_list[orderindex].order_description, oc.primary_mnemonic =
     request->order_list[orderindex].order_primary_syn, oc.dept_display_name = request->order_list[
     orderindex].dept_name,
     oc.cki = " ", oc.concept_cki = null, oc.consent_form_ind = 0,
     oc.inst_restriction_ind = 0, oc.schedule_ind = 0, oc.print_req_ind = 0,
     oc.quick_chart_ind = 0, oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0,
     oc.dup_checking_ind = 0, oc.bill_only_ind = 0, oc.cont_order_method_flag = 0,
     oc.order_review_ind = 0, oc.ref_text_mask = 0, oc.form_level = 0,
     oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task =
     reqinfo->updt_task,
     oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Failed to add orderable: ",trim(request->order_list[orderindex].
      order_primary_syn)," to the order_catalog table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("Added orderable: ",trim(request->order_list[orderindex].order_primary_syn),
     " to the order_catalog table.")
    CALL logmessage(msg)
   ENDIF
   INSERT  FROM bill_item bi
    SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = new_catalog_cd, bi
     .ext_parent_contributor_cd = ord_cat_contributor_cd,
     bi.ext_child_reference_id = 0.0, bi.ext_child_contributor_cd = 0.0, bi.ext_description = request
     ->order_list[orderindex].order_description,
     bi.ext_owner_cd = act_cd, bi.parent_qual_cd = 1.0, bi.charge_point_cd = 0.0,
     bi.physician_qual_cd = 0.0, bi.calc_type_cd = 0.0, bi.updt_cnt = 0,
     bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id, bi.updt_task =
     reqinfo->updt_task,
     bi.updt_applctx = reqinfo->updt_applctx, bi.active_ind = 1, bi.active_status_cd = active_cd,
     bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi.active_status_prsnl_id = reqinfo->
     updt_id, bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     bi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), bi.ext_short_desc = substring(
      1,50,request->order_list[orderindex].order_primary_syn), bi.ext_parent_entity_name =
     "CODE_VALUE",
     bi.ext_child_entity_name = null, bi.careset_ind = 0.0, bi.workload_only_ind = 0.0,
     bi.parent_qual_ind = 0.0, bi.misc_ind = 0.0, bi.stats_only_ind = 0.0,
     bi.child_seq = 0.0, bi.num_hits = 0.0, bi.late_chrg_excl_ind = 0.0,
     bi.cost_basis_amt = 0.0, bi.tax_ind = 0.0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Failed to add orderable: ",trim(request->order_list[orderindex].
      order_primary_syn)," to the bill_item table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("Added orderable: ",trim(request->order_list[orderindex].order_primary_syn),
     " to the bill_item table.")
    CALL logmessage(msg)
   ENDIF
   INSERT  FROM service_directory l
    SET l.short_description = request->order_list[orderindex].dept_name, l.description = request->
     order_list[orderindex].order_description, l.catalog_cd = new_catalog_cd,
     l.synonym_id = 0, l.active_ind = 1, l.active_status_cd = active_cd,
     l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.group_ind = 0, l.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_cnt = 0, l.updt_task = reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Failed to add orderable: ",trim(request->order_list[orderindex].
      order_primary_syn)," to the service_directory table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("Added orderable: ",trim(request->order_list[orderindex].order_primary_syn),
     " to the service_directory table.")
    CALL logmessage(msg)
   ENDIF
   IF (new_catalog_cd > 0)
    SET new_synonym_cd = 0.0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_synonym_cd = cnvtreal(y)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET msg = concat("Unable generate new primary synonym_id when processing ",trim(request->
       order_list[orderindex].order_primary_syn))
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ENDIF
    INSERT  FROM order_catalog_synonym ocs
     SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = dcp_clin_category_cd, ocs.synonym_id = new_synonym_cd,
      ocs.catalog_cd = new_catalog_cd, ocs.catalog_type_cd = cat_cd, ocs.activity_type_cd = act_cd,
      ocs.activity_subtype_cd = act_sub_cd, ocs.oe_format_id = request->order_list[orderindex].oef_id,
      ocs.mnemonic = request->order_list[orderindex].order_primary_syn,
      ocs.mnemonic_key_cap = trim(cnvtupper(request->order_list[orderindex].order_primary_syn)), ocs
      .mnemonic_type_cd = primary_mnemonic_type_cd, ocs.active_ind = 1,
      ocs.orderable_type_flag = 0, ocs.ref_text_mask = 0, ocs.hide_flag = 0,
      ocs.cki = " ", ocs.virtual_view = " ", ocs.health_plan_view = " ",
      ocs.concentration_strength = 0, ocs.concentration_volume = 0, ocs.active_status_cd = active_cd,
      ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
      ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
      ->updt_applctx,
      ocs.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add primary synonym to the order_catalog_synonym table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added primary synonym to the order_catalog_synonym table. Synonym ID: ",
      cnvtstring(new_synonym_cd))
     CALL logmessage(msg)
    ENDIF
    INSERT  FROM ocs_facility_r ofr
     SET ofr.synonym_id = new_synonym_cd, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
      updt_applctx,
      ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
      updt_id,
      ofr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET new_synonym_cd = 0.0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_synonym_cd = cnvtreal(y)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET msg = concat("Unable generate new ancillary synonym_id when processing ",trim(request->
       order_list[orderindex].order_primary_syn))
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ENDIF
    INSERT  FROM order_catalog_synonym ocs
     SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = dcp_clin_category_cd, ocs.synonym_id = new_synonym_cd,
      ocs.catalog_cd = new_catalog_cd, ocs.catalog_type_cd = cat_cd, ocs.activity_type_cd = act_cd,
      ocs.activity_subtype_cd = act_sub_cd, ocs.oe_format_id = request->order_list[orderindex].oef_id,
      ocs.mnemonic = request->order_list[orderindex].order_primary_syn,
      ocs.mnemonic_key_cap = trim(cnvtupper(request->order_list[orderindex].order_primary_syn)), ocs
      .mnemonic_type_cd = ancillary_mnemonic_type_cd, ocs.active_ind = 1,
      ocs.orderable_type_flag = 0, ocs.ref_text_mask = 0, ocs.hide_flag = 0,
      ocs.cki = " ", ocs.virtual_view = " ", ocs.health_plan_view = " ",
      ocs.concentration_strength = 0, ocs.concentration_volume = 0, ocs.active_status_cd = active_cd,
      ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
      ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
      ->updt_applctx,
      ocs.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add ancillary synonym to the order_catalog_synonym table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added ancillary synonym to the order_catalog_synonym table. Synonym ID: ",
      cnvtstring(new_synonym_cd))
     CALL logmessage(msg)
    ENDIF
    INSERT  FROM ocs_facility_r ofr
     SET ofr.synonym_id = new_synonym_cd, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
      updt_applctx,
      ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
      updt_id,
      ofr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   CALL savecodevaluealias(request->contributor_source_cd,request->order_list[orderindex].alias_code,
    new_catalog_cd,200)
   CALL savecodevalueoutbound(request->contributor_source_cd,request->order_list[orderindex].
    alias_code,new_catalog_cd,200)
   CALL orcresourcelistsave(new_catalog_cd)
   CALL saveprocedurespecimentype(orderindex,new_catalog_cd)
   CALL savecollectionrequirements(orderindex,new_catalog_cd)
   CALL ensureorderdtasandeventcode(orderindex,new_catalog_cd)
   CALL logmessage("***saveNewOrder***. Exiting ...")
 END ;Subroutine
 SUBROUTINE ensureorderdtasandeventcode(orderindex,new_catalog_cd)
   CALL logmessage("***ensureOrderDTAsAndEventCode***. Entering ...")
   SET nn = 0
   SET num_dtas = size(request->order_list[orderindex].dta_list,5)
   FOR (nn = 1 TO num_dtas)
     SET dup_dta_event_entry_found = "N"
     SET dta_name_found = "N"
     SET new_dta_cd = 0.0
     SET dta_found = "N"
     SET assay_new_disp = request->order_list[orderindex].dta_list[nn].assay_display
     SET assay_new_code = request->order_list[orderindex].dta_list[nn].alias_code
     SET is_optional_assay = request->order_list[orderindex].dta_list[nn].optional_assay
     SET assay_event_relation = 0
     SET dup_event_cd = 0
     SELECT INTO "nl:"
      FROM code_value_alias cva
      PLAN (cva
       WHERE (cva.alias=request->order_list[orderindex].dta_list[nn].alias_code)
        AND cva.code_set=14003
        AND (cva.contributor_source_cd=request->contributor_source_cd))
      DETAIL
       new_dta_cd = cva.code_value, dta_found = "Y"
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM v500_event_code vec
      PLAN (vec
       WHERE vec.event_cd_disp=assay_new_disp)
      DETAIL
       dup_dta_event_entry_found = "Y", dup_event_cd = vec.event_cd
      WITH nocounter
     ;end select
     IF (dta_found="Y")
      CALL verifydtadisplay(assay_new_disp,new_dta_cd)
      SELECT INTO "nl:"
       FROM code_value_event_r cve
       PLAN (cve
        WHERE cve.event_cd=dup_event_cd
         AND cve.parent_cd=new_dta_cd)
       DETAIL
        assay_event_relation = 1
       WITH nocounter
      ;end select
      IF (assay_event_relation=0
       AND dta_name_found="Y")
       IF (dup_dta_event_entry_found="N")
        IF (glbcreatedtaevtcdsfornewdta(assay_new_disp))
         SET msg = concat("The new DTA is qualified to add it to the clinical Events Table",
          assay_new_disp,"")
         CALL logmessage(msg)
        ELSE
         SET msg = concat("The new DTA is not qualified to add it to the clinical Events Table",
          assay_new_disp,"")
         CALL logmessage(msg)
         RETURN(false)
        ENDIF
       ELSE
        SET dup_dta_event_count = (dup_dta_event_count+ 1)
        IF (dup_dta_event_count >= 1)
         SET stat = alter(reply->duplicate_dta_event_list,dup_dta_event_count)
        ENDIF
        SET reply->duplicate_dta_event_list[dup_dta_event_count].duplicate_dta_event = assay_new_disp
       ENDIF
      ENDIF
     ENDIF
     IF (dta_name_found="N")
      SET stat = alterlist(dta_request->assay_list,1)
      IF (dta_found="N")
       SET dta_request->assay_list[1].action_flag = 1
       SET dta_request->assay_list[1].code_value = new_dta_cd
       SET dta_request->assay_list[1].description = request->order_list[orderindex].dta_list[nn].
       assay_description
       SET dta_request->assay_list[1].display = assay_new_disp
       SET dta_request->assay_list[1].general_info.activity_type_code_value = act_cd
       SET dta_request->assay_list[1].general_info.result_type_code_value = result_type_cd
       SET dta_request->assay_list[1].general_info.delta_check_ind = 0
       SET dta_request->assay_list[1].general_info.res_proc_type_code_value = 0.0
       SET trace = recpersist
       EXECUTE bed_ens_assay  WITH replace("REQUEST",dta_request), replace("REPLY",dta_reply)
       SET new_dta_cd = dta_reply->assay_list[1].code_value
       IF (new_dta_cd > 0.0)
        SET msg = concat("Successfully added Order DTA: ",request->order_list[orderindex].dta_list[nn
         ].assay_display,"New DTA Code: ",cnvtstring(new_dta_cd))
        CALL logmessage(msg)
       ELSE
        SET msg = concat("Failed to add Order DTA: ",request->order_list[orderindex].dta_list[nn].
         assay_display)
        CALL logmessage(msg)
        CALL logerrormessage(msg)
        RETURN(false)
       ENDIF
      ELSE
       SET msg = concat("DTA record found for: ",assay_new_disp,"existing DTA Code: ",cnvtstring(
         new_dta_cd))
       CALL logmessage(msg)
      ENDIF
      IF (dup_dta_event_entry_found="Y"
       AND assay_event_relation=0)
       SET dup_dta_event_count = (dup_dta_event_count+ 1)
       IF (dup_dta_event_count >= 1)
        SET stat = alter(reply->duplicate_dta_event_list,dup_dta_event_count)
       ENDIF
       SET reply->duplicate_dta_event_list[dup_dta_event_count].duplicate_dta_event = assay_new_disp
       SET msg = concat("The new DTA event code already exist in the events table  ",assay_new_disp,
        "")
       CALL logmessage(msg)
      ELSE
       IF (glbcreatedtaevtcdsfornewdta(assay_new_disp))
        SET msg = concat("The new DTA is qualified to add it to the clinical Events Table",
         assay_new_disp,"")
        CALL logmessage(msg)
       ELSE
        SET msg = concat("The new DTA is not qualified to add it to the clinical Events Table",
         assay_new_disp,"")
        CALL logmessage(msg)
        RETURN(false)
       ENDIF
      ENDIF
     ELSE
      SET msg = concat("DTA name exit for: ",assay_new_disp,"DTA Code: ",cnvtstring(new_dta_cd))
      CALL logmessage(msg)
     ENDIF
     CALL logmessage("call saveCodeValueAlias to add DTA alias code to code_value_alias ")
     CALL savecodevaluealias(request->contributor_source_cd,request->order_list[orderindex].dta_list[
      nn].alias_code,new_dta_cd,14003)
     CALL logmessage("call saveCodeValueOutbound to add DDTA alias code to code_value_outbound")
     CALL savecodevalueoutbound(request->contributor_source_cd,request->order_list[orderindex].
      dta_list[nn].alias_code,new_dta_cd,14003)
     CALL addassayprocessing(new_dta_cd)
     CALL addloinccode(orderindex,nn)
     CALL addprofiletask(new_catalog_cd,new_dta_cd,is_optional_assay)
   ENDFOR
   CALL logmessage("***ensureOrderDTAsAndEventCode***. Exiting ...")
 END ;Subroutine
 SUBROUTINE savenewlabhandling(orderindex,catalogcd,newcollectioninfosequence,labhandlingcd)
   SET msg = concat("saveNewLabHandling",cnvtstring(orderindex),trim(cnvtstring(catalogcd)),
    cnvtstring(newcollectioninfosequence))
   CALL logmessage(msg)
   SET msg = cnvtstring(orderindex)
   CALL logmessage(msg)
   SET lab_handling_cd_found = "N"
   SET oldlabhandlingidsequence = 0
   SELECT INTO "nl:"
    FROM lab_handling lh
    PLAN (lh
     WHERE lh.catalog_cd=catalogcd
      AND (lh.specimen_type_cd=request->order_list[orderindex].specimen_type_cd)
      AND lh.coll_info_seq=newcollectioninfosequence)
    DETAIL
     lab_handling_cd_found = "Y", oldlabhandlingidsequence = lh.lab_handling_id
    WITH nocounter
   ;end select
   IF (lab_handling_cd_found="N")
    SELECT INTO "nl:"
     l = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      newlabhandlingidsequence = l
     WITH format, nocounter
    ;end select
    INSERT  FROM lab_handling lh
     SET lh.lab_handling_id = newlabhandlingidsequence, lh.catalog_cd = catalogcd, lh
      .specimen_type_cd = request->order_list[orderindex].specimen_type_cd,
      lh.coll_info_seq = newcollectioninfosequence, lh.lab_handling_cd = labhandlingcd, lh
      .lab_handling_order_seq = 0,
      lh.updt_dt_tm = cnvtdatetime(curdate,curtime), lh.updt_id = reqinfo->updt_id, lh.updt_task =
      reqinfo->updt_task,
      lh.updt_applctx = reqinfo->updt_applctx, lh.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add new labhandling cd : ",trim(cnvtstring(labhandlingcd)),
      " to the lab_handling table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added new labhandling cd: ",trim(cnvtstring(labhandlingcd)),
      "to the lab_handling table.")
     CALL logmessage(msg)
    ENDIF
   ELSE
    UPDATE  FROM lab_handling lh
     SET lh.lab_handling_cd = labhandlingcd, lh.lab_handling_order_seq = 0, lh.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      lh.updt_id = reqinfo->updt_id, lh.updt_task = reqinfo->updt_task, lh.updt_applctx = reqinfo->
      updt_applctx,
      lh.updt_cnt = (lh.updt_cnt+ 1)
     WHERE lh.catalog_cd=catalogcd
      AND (lh.specimen_type_cd=request->order_list[orderindex].specimen_type_cd)
      AND lh.coll_info_seq=newcollectioninfosequence
      AND lh.lab_handling_id=oldlabhandlingidsequence
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat("Failed to update labhandling cd : ",trim(cnvtstring(labhandlingcd)),
      " to the lab_handling table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Updated labhandling cd: ",trim(cnvtstring(labhandlingcd)),
      "to the lab_handling table.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE savecodevaluealias(contributor_source_cd,alias_code,catalog_cd,code_set)
   SET code_value_alias_found = "N"
   SELECT INTO "nl:"
    FROM code_value_alias cva
    PLAN (cva
     WHERE cva.code_value=catalog_cd
      AND cva.contributor_source_cd=contributor_source_cd)
    DETAIL
     code_value_alias_found = "Y"
    WITH nocounter
   ;end select
   IF (code_value_alias_found="N")
    INSERT  FROM code_value_alias cva
     SET cva.code_set = code_set, cva.contributor_source_cd = contributor_source_cd, cva.alias =
      alias_code,
      cva.code_value = catalog_cd, cva.primary_ind = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime
       ),
      cva.updt_id = reqinfo->updt_id, cva.updt_cnt = 0, cva.updt_task = reqinfo->updt_task,
      cva.updt_applctx = reqinfo->updt_applctx, cva.alias_type_meaning = null
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add order alias code for orderable: ",trim(request->order_list[
       orderindex].order_primary_syn)," to the code_value_alias table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added order alias code for orderable: ",trim(request->order_list[orderindex].
       order_primary_syn)," to the code_value_alias table.")
     CALL logmessage(msg)
    ENDIF
   ELSE
    UPDATE  FROM code_value_alias cva
     SET cva.alias = alias_code, cva.primary_ind = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime),
      cva.updt_id = reqinfo->updt_id, cva.updt_cnt = (cva.updt_cnt+ 1), cva.updt_task = reqinfo->
      updt_task,
      cva.updt_applctx = reqinfo->updt_applctx, cva.alias_type_meaning = null
     WHERE cva.code_set=code_set
      AND cva.contributor_source_cd=contributor_source_cd
      AND cva.code_value=catalog_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat("Failed to UPDATE order alias code for orderable: ",trim(request->order_list[
       orderindex].order_primary_syn)," to the code_value_alias table for found duplicate order.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Updated order alias code for orderable: ",trim(request->order_list[orderindex]
       .order_primary_syn)," to the code_value_alias table for found duplicate order.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE savecodevalueoutbound(contributor_source_cd,alias_code,catalog_cd,code_set)
   SET code_value_outbound_found = "N"
   SELECT INTO "nl:"
    FROM code_value_outbound cvo
    PLAN (cvo
     WHERE cvo.code_value=catalog_cd
      AND cvo.contributor_source_cd=contributor_source_cd)
    DETAIL
     code_value_outbound_found = "Y"
    WITH nocounter
   ;end select
   IF (code_value_outbound_found="N")
    INSERT  FROM code_value_outbound cvo
     SET cvo.code_value = catalog_cd, cvo.contributor_source_cd = contributor_source_cd, cvo
      .alias_type_meaning = null,
      cvo.code_set = code_set, cvo.alias = alias_code, cvo.updt_dt_tm = cnvtdatetime(curdate,curtime),
      cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt = 0, cvo.updt_task = reqinfo->updt_task,
      cvo.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add order alias code for orderable: ",trim(request->order_list[
       orderindex].order_primary_syn)," to the code_value_outbound table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added order alias code for orderable: ",trim(request->order_list[orderindex].
       order_primary_syn)," to the code_value_outbound table.")
     CALL logmessage(msg)
    ENDIF
   ELSE
    UPDATE  FROM code_value_outbound cvo
     SET cvo.alias_type_meaning = null, cvo.code_set = code_set, cvo.alias = alias_code,
      cvo.updt_dt_tm = cnvtdatetime(curdate,curtime), cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt =
      (cvo.updt_cnt+ 1),
      cvo.updt_task = reqinfo->updt_task, cvo.updt_applctx = reqinfo->updt_applctx
     WHERE cvo.code_value=catalog_cd
      AND cvo.contributor_source_cd=contributor_source_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat("Failed to update code value outbound for orderable: ",trim(request->
       order_list[orderindex].order_primary_syn)," to the code_value_outbound table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Updated code value outbound for orderable: ",trim(request->order_list[
       orderindex].order_primary_syn)," to the code_value_outbound table.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE saveprocedurespecimentype(orderindex,catalogcd)
   SET procedure_specimen_type_found = "N"
   SELECT INTO "nl:"
    FROM procedure_specimen_type pst
    PLAN (pst
     WHERE pst.catalog_cd=catalogcd
      AND (pst.specimen_type_cd=request->order_list[orderindex].specimen_type_cd))
    DETAIL
     procedure_specimen_type_found = "Y"
    WITH nocounter
   ;end select
   IF (procedure_specimen_type_found="N")
    INSERT  FROM procedure_specimen_type pst
     SET pst.catalog_cd = catalogcd, pst.specimen_type_cd = request->order_list[orderindex].
      specimen_type_cd, pst.default_collection_method_cd = request->order_list[orderindex].
      collection_method_cd,
      pst.accession_class_cd = request->order_list[orderindex].accession_class_cd, pst.updt_applctx
       = reqinfo->updt_applctx, pst.updt_dt_tm = cnvtdatetime(curdate,curtime),
      pst.updt_id = reqinfo->updt_id, pst.updt_cnt = 0, pst.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add order specimen type for orderable: ",trim(request->order_list[
       orderindex].order_primary_syn)," to the procedure_specimen_type table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added order specimen type for orderable: ",trim(request->order_list[orderindex
       ].order_primary_syn)," to the procedure_specimen_type table.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addassayprocessing(new_dta_cd)
   SET mseq = 0
   SET service_resource_index = 0
   FOR (service_resource_index = 1 TO num_benches)
     SET apr_found = "N"
     SELECT INTO "nl:"
      FROM assay_processing_r apr
      PLAN (apr
       WHERE apr.task_assay_cd=new_dta_cd
        AND (apr.service_resource_cd=request->service_resource_list[service_resource_index].
       service_resource_cd))
      DETAIL
       apr_found = "Y"
      WITH nocounter
     ;end select
     IF (apr_found="N")
      SELECT INTO "nl:"
       apr.display_sequence
       FROM assay_processing_r apr
       PLAN (apr
        WHERE (apr.service_resource_cd=request->service_resource_list[service_resource_index].
        service_resource_cd))
       DETAIL
        IF (mseq < apr.display_sequence)
         mseq = apr.display_sequence
        ENDIF
       WITH nocounter
      ;end select
      INSERT  FROM assay_processing_r apr
       SET apr.task_assay_cd = new_dta_cd, apr.service_resource_cd = request->service_resource_list[
        service_resource_index].service_resource_cd, apr.upld_assay_alias = null,
        apr.process_sequence = null, apr.active_ind = 1, apr.default_result_type_cd = result_type_cd,
        apr.default_result_template_id = 0.0, apr.qc_result_type_cd = 0.0, apr.qc_sequence = 0,
        apr.updt_cnt = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime), apr.updt_task = reqinfo->
        updt_task,
        apr.updt_id = reqinfo->updt_id, apr.updt_applctx = reqinfo->updt_applctx, apr
        .dnld_assay_alias = null,
        apr.post_zero_result_ind = null, apr.display_sequence = (mseq+ 1), apr.downld_ind = 0,
        apr.code_set = 0, apr.active_status_cd = active_cd, apr.active_status_dt_tm = cnvtdatetime(
         curdate,curtime),
        apr.active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Failed to add DTA routing for service_resource_cd: ",trim(cnvtstring(request
          ->service_resource_list[service_resource_index].service_resource_cd)),
        " to the assay_processing_r table.")
       CALL logmessage(msg)
       CALL logerrormessage(msg)
       RETURN(false)
      ELSE
       SET msg = concat("Added DTA routing for service_resource_cd: ",trim(cnvtstring(request->
          service_resource_list[service_resource_index].service_resource_cd)),
        " to the assay_processing_r table.")
       CALL logmessage(msg)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addloinccode(orderindex,datindex)
   IF (size(trim(request->order_list[orderindex].dta_list[datindex].loinc_code)) > 0)
    SET zz = 0
    FOR (zz = 1 TO num_benches)
      SET bench_cd = request->service_resource_list[zz].service_resource_cd
      SET dta_loinc_request->codes[1].service_resource_code_value = bench_cd
      SET dta_loinc_request->codes[1].assay_code_value = new_dta_cd
      SET dta_loinc_request->codes[1].specimen_type_code = request->order_list[orderindex].
      specimen_type_cd
      SET dta_loinc_request->codes[1].loinc_code = request->order_list[orderindex].dta_list[datindex]
      .loinc_code
      SET dta_loinc_request->codes[1].ignore_ind = 0
      SET dta_loinc_request->codes[1].code_type_ind = 1
      SET dta_loinc_request->codes[1].concept_identifier_dta_id = 0.0
      SET trace = recpersist
      EXECUTE bed_ens_loinc_codes  WITH replace("REQUEST",dta_loinc_request), replace("REPLY",
       dta_loinc_reply)
      IF ((dta_loinc_reply->status_data.status="S"))
       SET msg = concat("Added LOINC Code: ",request->order_list[orderindex].dta_list[datindex].
        loinc_code," for service_resource_cd: ",trim(cnvtstring(request->service_resource_list[zz].
          service_resource_cd))," to the concept_identifier_dta table.")
       CALL logmessage(msg)
      ELSE
       SET msg = concat("Failed to add LOINC Code: ",request->order_list[orderindex].dta_list[
        datindex].loinc_code," for service_resource_cd: ",trim(cnvtstring(request->
          service_resource_list[zz].service_resource_cd))," to the concept_identifier_dta table.")
       CALL logmessage(msg)
       CALL logerrormessage(msg)
       RETURN(false)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE addprofiletask(new_catalog_cd,new_dta_cd,is_optional_assay)
   SET mseq = 0
   SET tcnt = 0
   SET order_dta_found = "N"
   SELECT INTO "nl:"
    FROM profile_task_r ptr
    PLAN (ptr
     WHERE ptr.catalog_cd=new_catalog_cd
      AND ptr.task_assay_cd=new_dta_cd)
    DETAIL
     order_dta_found = "Y"
    WITH nocounter
   ;end select
   IF (order_dta_found="N")
    SELECT INTO "nl:"
     ptr.sequence
     FROM profile_task_r ptr
     PLAN (ptr
      WHERE ptr.catalog_cd=new_catalog_cd)
     DETAIL
      tcnt = (tcnt+ 1)
      IF (mseq < ptr.sequence)
       mseq = ptr.sequence
      ENDIF
     WITH nocounter
    ;end select
    IF (tcnt=0)
     SET mseq = 0
    ELSE
     SET mseq = (mseq+ 1)
    ENDIF
    INSERT  FROM profile_task_r ptr
     SET ptr.catalog_cd = new_catalog_cd, ptr.task_assay_cd = new_dta_cd, ptr.version_nbr = 0,
      ptr.group_cd = 0.0, ptr.item_type_flag = 0, ptr.pending_ind = is_optional_assay,
      ptr.repeat_ind = 0, ptr.sequence = mseq, ptr.dup_chk_min = 0,
      ptr.dup_chk_action_cd = 0.0, ptr.updt_dt_tm = cnvtdatetime(curdate,curtime), ptr.updt_id =
      reqinfo->updt_id,
      ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = 0, ptr.updt_applctx = reqinfo->updt_applctx,
      ptr.active_ind = 1, ptr.post_prompt_ind = 0, ptr.prompt_resource_cd = 0.0,
      ptr.active_status_cd = active_cd, ptr.active_status_dt_tm = cnvtdatetime(curdate,curtime), ptr
      .active_status_prsnl_id = reqinfo->updt_id,
      ptr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), ptr.end_effective_dt_tm = cnvtdatetime
      ("31-DEC-2100, 00:00:00"), ptr.reference_task_id = 0.0,
      ptr.prompt_long_text_id = 0.0, ptr.restrict_display_ind = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Failed to add Order-to-DTA relationship for assay: ",trim(request->order_list[
       orderindex].dta_list[nn].assay_description)," to the profile_task_r table.")
     CALL logmessage(msg)
     CALL logerrormessage(msg)
     RETURN(false)
    ELSE
     SET msg = concat("Added Order-to-DTA relationship for assay: ",trim(request->order_list[
       orderindex].dta_list[nn].assay_description)," to the profile_task_r table.")
     CALL logmessage(msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addalternatecontainer(catalogcd,orderindex,newcollectioninfosequence,altcollreqsequence,
  benchsequene)
   CALL logmessage("Entering addAlternateContainer")
   INSERT  FROM alt_collection_info aci
    SET aci.alt_collection_info_id = seq(reference_seq,nextval), aci.catalog_cd = catalogcd, aci
     .specimen_type_cd = request->order_list[orderindex].specimen_type_cd,
     aci.coll_info_seq = newcollectioninfosequence, aci.spec_cntnr_cd = request->order_list[
     orderindex].coll_req_list[altcollreqsequence].container_cd, aci.min_vol_amt = request->
     order_list[orderindex].coll_req_list[altcollreqsequence].min_vol,
     aci.coll_class_cd = request->order_list[orderindex].coll_req_list[altcollreqsequence].
     coll_class_cd, aci.spec_hndl_cd = request->order_list[orderindex].coll_req_list[
     altcollreqsequence].spec_hndl_cd, aci.updt_dt_tm = cnvtdatetime(curdate,curtime),
     aci.updt_id = reqinfo->updt_id, aci.updt_task = reqinfo->updt_task, aci.updt_applctx = reqinfo->
     updt_applctx,
     aci.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Failed to add alternate Containers for Service_resource_cd: ",trim(cnvtstring(
       request->service_resource_list[benchsequene].service_resource_cd)),
     " to the alt_collection_info table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("Added alternate containers for service_resource_cd: ",trim(cnvtstring(request->
       service_resource_list[benchsequene].service_resource_cd))," to the alt_collection_info table."
     )
    CALL logmessage(msg)
   ENDIF
   CALL logmessage("Exiting addAlternateContainer")
 END ;Subroutine
 SUBROUTINE updatealternatecontainer(catalogcd,orderindex,newcollectioninfosequence,
  altcollreqsequence,benchsequene)
   CALL logmessage("Entering updateAlternateContainer")
   UPDATE  FROM alt_collection_info aci
    SET aci.alt_collection_info_id = seq(reference_seq,nextval), aci.specimen_type_cd = request->
     order_list[orderindex].specimen_type_cd, aci.min_vol_amt = request->order_list[orderindex].
     coll_req_list[altcollreqsequence].min_vol,
     aci.coll_class_cd = request->order_list[orderindex].coll_req_list[altcollreqsequence].
     coll_class_cd, aci.spec_hndl_cd = request->order_list[orderindex].coll_req_list[
     altcollreqsequence].spec_hndl_cd, aci.updt_dt_tm = cnvtdatetime(curdate,curtime),
     aci.updt_id = reqinfo->updt_id, aci.updt_task = reqinfo->updt_task, aci.updt_applctx = reqinfo->
     updt_applctx,
     aci.updt_cnt = (aci.updt_cnt+ 1)
    WHERE aci.catalog_cd=catalogcd
     AND aci.coll_info_seq=newcollectioninfosequence
     AND (aci.spec_cntnr_cd=request->order_list[orderindex].coll_req_list[altcollreqsequence].
    container_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET msg = concat("Failed to update alternate Containers for Service_resource_cd: ",trim(
      cnvtstring(request->service_resource_list[benchsequene].service_resource_cd)),
     " to the alt_collection_info table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("Updated alternate containers for service_resource_cd: ",trim(cnvtstring(request
       ->service_resource_list[benchsequene].service_resource_cd)),
     " to the alt_collection_info table.")
    CALL logmessage(msg)
   ENDIF
   CALL logmessage("Exiting updateAlternateContainer")
 END ;Subroutine
 SUBROUTINE deletealternatecontainer(catalogcd,newcollectioninfosequence,orderindex,benchsequene)
   CALL logmessage("Entering deleteAlternateContainer")
   DELETE  FROM alt_collection_info aci
    WHERE aci.catalog_cd=catalogcd
     AND aci.coll_info_seq=newcollectioninfosequence
     AND  NOT (expand(iter_alt_container,2,size(request->order_list[orderindex].coll_req_list,5),aci
     .spec_cntnr_cd,request->order_list[orderindex].coll_req_list[iter_alt_container].container_cd))
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET msg = concat("Failed to delete alternate Containers for Service_resource_cd: ",trim(
      cnvtstring(request->service_resource_list[benchsequene].service_resource_cd)),
     " to the alt_collection_info table.")
    CALL logmessage(msg)
    CALL logerrormessage(msg)
    RETURN(false)
   ELSE
    SET msg = concat("deleated alternate containers for service_resource_cd: ",trim(cnvtstring(
       request->service_resource_list[benchsequene].service_resource_cd)),
     " to the alt_collection_info table.")
    CALL logmessage(msg)
   ENDIF
   CALL logmessage("Exiting deleteAlternateContainer")
 END ;Subroutine
 SUBROUTINE verifydtadisplay(assay_new_disp,new_dta_cd)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.display=substring(1,40,assay_new_disp)
      AND cv.code_set=14003
      AND cv.code_value=new_dta_cd)
    DETAIL
     dta_name_found = "Y"
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
