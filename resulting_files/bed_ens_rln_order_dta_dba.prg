CREATE PROGRAM bed_ens_rln_order_dta:dba
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
 RECORD service_resource(
   1 service_resource_list[*]
     2 code_value = f8
 )
 FREE RECORD add_dta_reply
 RECORD add_dta_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 task_assay_cd = f8
     2 catalog_cd = f8
 )
 FREE RECORD dta_request
 RECORD dta_request(
   1 assay_list[1]
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
 DECLARE active_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inactive_cd = f8 WITH protect, noconstant(0.0)
 DECLARE act_cd = f8 WITH protect, noconstant(0.0)
 DECLARE result_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_dta_cd = f8 WITH protect, noconstant(0.0)
 DECLARE del_dta_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dta_found = vc WITH protect, noconstant("")
 DECLARE num_updated_dta_list = i4 WITH protect, noconstant(0)
 DECLARE assay_new_disp = vc WITH protect, noconstant("")
 DECLARE assay_new_code = vc WITH protect, noconstant("")
 DECLARE apr_found = vc WITH protect, noconstant("")
 DECLARE ii = i4
 DECLARE bench_cnt = i4
 DECLARE new_event_cd = f8
 DECLARE specimen_type_cd = f8
 DECLARE mseq = i4
 DECLARE tcnt = i4
 DECLARE zz = i4
 DECLARE newlogmsg = vc
 DECLARE dup_dta_event_entry_found = vc
 DECLARE initializevariables(dummyvar=i2) = i2
 DECLARE getdeletedtacodevalue(dtaindex=i4) = i2
 DECLARE getadddtacodevalue(dtaindex=i4) = i2
 DECLARE deletedtaorderreltn(dummyvar=i2) = i2
 DECLARE adddtaorderreltn(dtaindex=i2) = i2
 DECLARE addnewdta(dtaindex=i4) = i2
 DECLARE savenewdtatoclinicalevents(assay_new_disp=vc) = i2
 DECLARE setprofiletaskr(catalog_cd=f8,task_assay_cd=f8,pending_ind=i2,mseq=i4) = i2
 SET num_updated_dta_list = size(request->updated_dta_list,5)
 CALL initializevariables(0)
 SET ii = 0
 IF (num_updated_dta_list > 0)
  FOR (ii = 1 TO num_updated_dta_list)
    IF ((request->updated_dta_list[ii].is_deleted=1))
     CALL getdeletedtacodevalue(ii)
     IF (del_dta_cd > 0.0)
      CALL deletedtaorderreltn(0)
     ENDIF
    ELSE
     CALL getadddtacodevalue(ii)
     IF (new_dta_cd=0.0)
      CALL addnewdta(ii)
     ENDIF
     CALL adddtaorderreltn(ii)
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE initializevariables(dummyvar)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=48
      AND c.cdf_meaning="ACTIVE")
    DETAIL
     active_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=48
      AND c.cdf_meaning="INACTIVE")
    DETAIL
     inactive_cd = c.code_value
    WITH nocounter
   ;end select
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
 END ;Subroutine
 SUBROUTINE getdeletedtacodevalue(dtaindex)
   CALL bedlogmessage("getDeleteDTACodeValue","Entering ...")
   SELECT INTO "nl:"
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.alias=request->updated_dta_list[dtaindex].assay_alias_code)
      AND cva.code_set=14003)
    DETAIL
     del_dta_cd = cva.code_value
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get deleted DTA's code value from discrete_task_assay table.")
   CALL bedlogmessage("getDeleteDTACodeValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE getadddtacodevalue(dtaindex)
   CALL bedlogmessage("getAddDTACodeValue","Entering ...")
   SET new_dta_cd = 0.00
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE (dta.mnemonic=request->updated_dta_list[dtaindex].assay_display))
    DETAIL
     new_dta_cd = dta.task_assay_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get new DTA's code value from discrete_task_assay table.")
   CALL bedlogmessage("getAddDTACodeValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletedtaorderreltn(dummyvar)
   CALL bedlogmessage("deleteDTAOrderReltn","Entering ...")
   UPDATE  FROM profile_task_r ptr
    SET ptr.active_ind = 0, ptr.updt_dt_tm = cnvtdatetime(curdate,curtime), ptr.updt_id = reqinfo->
     updt_id,
     ptr.updt_cnt = (ptr.updt_cnt+ 1), ptr.updt_task = reqinfo->updt_task, ptr.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ptr.catalog_cd=request->orderable_cd)
     AND ptr.task_assay_cd=del_dta_cd
     AND ptr.reference_task_id=0.0
    WITH nocounter
   ;end update
   CALL bederrorcheck("Failed to inactive deleted DTA on profile_task_r table.")
   CALL bedlogmessage("deleteDTAOrderReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE adddtaorderreltn(dtaindex)
   CALL bedlogmessage("addDTAOrderReltn","Entering ...")
   SET mseq = 0
   SET tcnt = 0
   SELECT INTO "nl:"
    ptr.sequence
    FROM profile_task_r ptr
    PLAN (ptr
     WHERE (ptr.catalog_cd=request->orderable_cd))
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
   CALL setprofiletaskr(request->orderable_cd,new_dta_cd,request->updated_dta_list[dtaindex].
    is_optional_assay,mseq)
   CALL bedlogmessage("addDTAOrderReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE addnewdta(dtaindex)
   CALL bedlogmessage("addNewDTA","Entering ...")
   SET dta_found = "N"
   SET assay_new_disp = request->updated_dta_list[dtaindex].assay_display
   SET assay_new_code = request->updated_dta_list[dtaindex].assay_alias_code
   SELECT INTO "nl:"
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.alias=request->updated_dta_list[dtaindex].assay_alias_code)
      AND cva.code_set=14003)
    DETAIL
     new_dta_cd = cva.code_value, dta_found = "Y"
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get existing DTA alias")
   IF (dta_found="N")
    SET dta_request->assay_list[1].action_flag = 1
    SET dta_request->assay_list[1].code_value = 0.0
    SET dta_request->assay_list[1].description = request->updated_dta_list[dtaindex].
    assay_description
    SET dta_request->assay_list[1].display = assay_new_disp
    SET dta_request->assay_list[1].general_info.activity_type_code_value = act_cd
    SET dta_request->assay_list[1].general_info.result_type_code_value = result_type_cd
    SET dta_request->assay_list[1].general_info.delta_check_ind = 0
    SET dta_request->assay_list[1].general_info.res_proc_type_code_value = 0.0
    SET trace = recpersist
    EXECUTE bed_ens_assay  WITH replace("REQUEST",dta_request), replace("REPLY",dta_reply)
    SET new_dta_cd = dta_reply->assay_list[1].code_value
    INSERT  FROM code_value_alias cva
     SET cva.alias = request->updated_dta_list[dtaindex].assay_alias_code, cva.code_set = 14003, cva
      .code_value = new_dta_cd,
      cva.contributor_source_cd = request->contributor_source_cd, cva.primary_ind = 0, cva
      .updt_applctx = reqinfo->updt_applctx,
      cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_id = reqinfo->
      updt_id,
      cva.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to add new assay alias to code_value_alias table.")
    INSERT  FROM code_value_outbound cvo
     SET cvo.code_value = new_dta_cd, cvo.contributor_source_cd = request->contributor_source_cd, cvo
      .alias_type_meaning = null,
      cvo.code_set = 14003, cvo.alias = request->updated_dta_list[dtaindex].assay_alias_code, cvo
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt = 0, cvo.updt_task = reqinfo->updt_task,
      cvo.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to add new assay alias to code_value_outbound table.")
   ENDIF
   SET bench_cnt = 0
   SELECT INTO "nl:"
    FROM orc_resource_list orl
    PLAN (orl
     WHERE (orl.catalog_cd=request->orderable_cd)
      AND orl.active_ind=1)
    HEAD REPORT
     bench_cnt = 0
    DETAIL
     bench_cnt = (bench_cnt+ 1), stat = alterlist(service_resource->service_resource_list,bench_cnt),
     service_resource->service_resource_list[bench_cnt].code_value = orl.service_resource_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get order benches")
   SET specimen_type_cd = 0.0
   SELECT INTO "nl:"
    FROM procedure_specimen_type pst
    WHERE (pst.catalog_cd=request->orderable_cd)
    DETAIL
     specimen_type_cd = pst.specimen_type_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get specimen")
   SET mseq = 0
   SET zz = 0
   FOR (zz = 1 TO bench_cnt)
     SET apr_found = "N"
     SELECT INTO "nl:"
      FROM assay_processing_r apr
      PLAN (apr
       WHERE apr.task_assay_cd=new_dta_cd
        AND (apr.service_resource_cd=service_resource->service_resource_list[zz].code_value))
      DETAIL
       apr_found = "Y"
      WITH nocounter
     ;end select
     CALL bederrorcheck("Failed to get existing assay processing relationship")
     IF (apr_found="N")
      SELECT INTO "nl:"
       apr.display_sequence
       FROM assay_processing_r apr
       PLAN (apr
        WHERE (apr.service_resource_cd=service_resource->service_resource_list[zz].code_value))
       DETAIL
        IF (mseq < apr.display_sequence)
         mseq = apr.display_sequence
        ENDIF
       WITH nocounter
      ;end select
      CALL bederrorcheck("Failed to get next sequence for assay_processing_r")
      INSERT  FROM assay_processing_r apr
       SET apr.task_assay_cd = new_dta_cd, apr.service_resource_cd = service_resource->
        service_resource_list[zz].code_value, apr.upld_assay_alias = null,
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
      CALL bederrorcheck("Failed to add new assay to assay_processing_r table.")
     ENDIF
     IF (size(trim(request->updated_dta_list[dtaindex].assay_loinc_code)) > 0)
      SET bench_cd = service_resource->service_resource_list[zz].code_value
      SET dta_loinc_request->codes[1].service_resource_code_value = bench_cd
      SET dta_loinc_request->codes[1].assay_code_value = new_dta_cd
      SET dta_loinc_request->codes[1].specimen_type_code = specimen_type_cd
      SET dta_loinc_request->codes[1].loinc_code = request->updated_dta_list[dtaindex].
      assay_loinc_code
      SET dta_loinc_request->codes[1].ignore_ind = 0
      SET dta_loinc_request->codes[1].code_type_ind = 1
      SET dta_loinc_request->codes[1].concept_identifier_dta_id = 0.0
      SET trace = recpersist
      EXECUTE bed_ens_loinc_codes  WITH replace("REQUEST",dta_loinc_request), replace("REPLY",
       dta_loinc_reply)
     ENDIF
   ENDFOR
   SET dup_dta_event_entry_found = "N"
   SELECT INTO "nl:"
    FROM v500_event_code vec
    PLAN (vec
     WHERE vec.event_cd_disp=assay_new_disp)
    DETAIL
     dup_dta_event_entry_found = "Y"
    WITH nocounter
   ;end select
   IF (dup_dta_event_entry_found="N")
    CALL savenewdtatoclinicalevents(assay_new_disp)
   ENDIF
   CALL bedlogmessage("addNewDTA","Exiting ...")
 END ;Subroutine
 SUBROUTINE savenewdtatoclinicalevents(assay_new_disp)
   CALL bedlogmessage("***saveNewDTAToClinicalEvents***"," Beginning ...")
   SET newlogmsg = ""
   IF (glbcreatedtaevtcdsfornewdta(assay_new_disp))
    SET newlogmsg = concat("The new DTA is qualified to add it to the clinical Events Table",
     assay_new_disp,"")
    CALL bedlogmessage(newlogmsg,"")
   ELSE
    SET newlogmsg = concat("The new DTA is not qualified to add it to the clinical Events Table",
     assay_new_disp,"")
    CALL bedlogmessage(newlogmsg,"")
   ENDIF
   CALL bedlogmessage("***saveNewDTAToClinicalEvents***","Exiting ...")
 END ;Subroutine
 SUBROUTINE setprofiletaskr(catalog_cd,task_assay_cd,is_optional_assay,mseq)
   CALL bedlogmessage("**setProfileTaskR**"," Beginning ...")
   SELECT INTO "nl:"
    p.*
    FROM profile_task_r p
    WHERE p.task_assay_cd=task_assay_cd
     AND p.catalog_cd=catalog_cd
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM profile_task_r p
     SET p.task_assay_cd = task_assay_cd, p.catalog_cd = catalog_cd, p.reference_task_id = 0.0,
      p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id =
      reqinfo->updt_id,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.beg_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
      p.pending_ind = is_optional_assay, p.sequence = mseq, p.group_cd = 0.0,
      p.restrict_display_ind = 0, p.post_prompt_ind = 0, p.prompt_resource_cd = 0.0,
      p.repeat_ind = 0, p.version_nbr = 0, p.item_type_flag = 0,
      p.dup_chk_min = 0, p.dup_chk_action_cd = 0.0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.updt_cnt = 0
     WHERE p.task_assay_cd=task_assay_cd
      AND p.catalog_cd=catalog_cd
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM profile_task_r p
     SET p.task_assay_cd = task_assay_cd, p.catalog_cd = catalog_cd, p.reference_task_id = 0.0,
      p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id =
      reqinfo->updt_id,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.beg_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
      p.pending_ind = is_optional_assay, p.sequence = mseq, p.group_cd = 0.0,
      p.restrict_display_ind = 0, p.post_prompt_ind = 0, p.prompt_resource_cd = 0.0,
      p.repeat_ind = 0, p.version_nbr = 0, p.item_type_flag = 0,
      p.dup_chk_min = 0, p.dup_chk_action_cd = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL bedlogmessage("**setProfileTaskR**"," Failed to insert into profile_task_r")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    l.*
    FROM service_directory l
    WHERE l.catalog_cd=catalog_cd
    WITH nocounter, forupdate(l)
   ;end select
   IF (curqual=0)
    CALL bedlogmessage("**setProfileTaskR**","failed to select from service_directory")
   ENDIF
   UPDATE  FROM service_directory l
    SET l.group_ind = 0, l.prompt_ind = l.prompt_ind, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx,
     l.updt_cnt = (l.updt_cnt+ 1)
    WHERE l.catalog_cd=catalog_cd
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL bedlogmessage("**setProfileTaskR**","failed to update service_directory ")
   ENDIF
   CALL bedlogmessage("**setProfileTaskR**","Exiting")
 END ;Subroutine
END GO
