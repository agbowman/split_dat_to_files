CREATE PROGRAM bed_aud_mul_interactions:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp_rep(
   1 batch_list[*]
     2 drug_class_int_custom_id = f8
     2 combo_ind = i2
     2 custom_type_flag = i2
     2 custom_interaction_flag = i2
     2 class1_ident = vc
     2 entity1_display = vc
     2 class2_ident = vc
     2 entity2_display = vc
     2 user_display = vc
     2 custom_sever_header = vc
     2 custom_severity_level = vc
     2 last_updt_dt_tm = dq8
     2 user_id = f8
     2 custom_repeat_num = i4
     2 suppress_dt_tm = dq8
     2 expert_trigger = vc
     2 source = vc
     2 dcp_entity1_id = f8
     2 dcp_entity2_id = f8
     2 dcp_entity1_display = vc
     2 dcp_entity2_display = vc
   1 custom_list[*]
     2 dcp_entity_reltn_id = f8
     2 entity1_id = f8
     2 entity1_display = vc
     2 entity2_id = f8
     2 entity2_display = vc
     2 user_display = vc
     2 user_id = f8
     2 custom_sever_header = vc
     2 custom_severity_level = vc
     2 active_ind = i2
     2 last_updt_dt_tm = dq8
     2 entity_reltn_mean = vc
     2 custom_repeat_num = i4
     2 suppress_dt_tm = dq8
 )
 RECORD header_rep(
   1 binary_list[*]
     2 binary_value = i2
   1 header_list[*]
     2 header_id = i2
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
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE batch_flag = i4 WITH public, noconstant(0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 DECLARE divide_value = i2 WITH public, noconstant(0)
 DECLARE binary_count = i2 WITH public, noconstant(0)
 DECLARE table_head_id = i2 WITH public, noconstant(0)
 DECLARE populate_custom_interactions(null) = null
 DECLARE populate_batch_custom_interactions(null) = null
 DECLARE populate_table_columns(null) = null
 DECLARE populate_drug_drug_module_table_column(null) = null
 DECLARE populate_drug_name_column(null) = null
 DECLARE populate_additional_filter_column(null) = null
 DECLARE create_drug_allergy_reply(null) = null
 DECLARE create_drug_drug_reply(null) = null
 DECLARE create_drug_food_reply(null) = null
 DECLARE create_duplicate_therapy_reply(null) = null
 DECLARE create_reference_text_reply(null) = null
 DECLARE drug_drug_and_drug_allergy_module_category_category(null) = null
 DECLARE drug_drug_and_drug_allergy_module_category_drug(null) = null
 DECLARE drug_allergy_module_allergy_category_drug(null) = null
 DECLARE drug_allergy_module_allergy_category_category(null) = null
 DECLARE drug_food_module_category_food(null) = null
 DECLARE drug_food_module_drug_food(null) = null
 DECLARE populate_reference_text_module_column(null) = null
 DECLARE populate_duplicate_therapy_module_drug_column(null) = null
 DECLARE populate_duplicate_therapy_module_category_column(null) = null
 DECLARE populate_drug_allergy_and_drug_food_module_common_column(null) = null
 DECLARE populate_duplicate_therapy_module_column(null) = null
 DECLARE populate_custominteractions_duplicate_category(null) = null
 DECLARE populate_additional_filter_customer_interaction(null) = null
 DECLARE get_multiple_severity_headers(severity_header_id=i2) = vc
 DECLARE get_severity_header_text(severity_header_id=i2) = vc
 DECLARE populate_severity_header_text(severity_header_id=i2) = vc
 DECLARE get_severity_levels(severity_level_id=i4) = vc
 DECLARE get_user_display(updt_id=f8) = vc
 DECLARE get_drug_identifier(drug_name=vc,drug_id=vc) = vc
 DECLARE populate_additional_filter_interactions_category(null) = null
 DECLARE populate_additional_filter_interactions_drug(null) = null
 IF ((request->custom_interaction_flag=7))
  IF ((request->custom_type_flag=0))
   CALL populate_additional_filter_interactions_drug(null)
  ELSE
   CALL populate_additional_filter_interactions_category(null)
  ENDIF
  CALL populate_table_columns(null)
 ENDIF
 IF ((request->entity_reltn_mean="TDC/CAT/SUPP"))
  CALL populate_custominteractions_duplicate_category(null)
  CALL populate_table_columns(null)
 ELSE
  IF ((((request->combo_ind=0)
   AND (request->custom_type_flag=3)) OR ((request->combo_ind=0)
   AND (request->custom_type_flag=0))) )
   SET batch_flag = 0
   CALL populate_custom_interactions(null)
   CALL populate_table_columns(null)
  ELSE
   SET batch_flag = 1
   CALL populate_batch_custom_interactions(null)
   CALL populate_table_columns(null)
  ENDIF
 ENDIF
 SUBROUTINE populate_severity_header_text(header_id)
   DECLARE multiple_header = vc
   IF (((header_id=1) OR (((header_id=2) OR (((header_id=4) OR (((header_id=8) OR (((header_id=16)
    OR (((header_id=32) OR (header_id=64)) )) )) )) )) )) )
    RETURN(get_severity_header_text(header_id))
   ELSE
    CALL get_multiple_severity_headers(header_id)
    FOR (x = 1 TO size(header_rep->header_list,5))
      IF (x < size(header_rep->header_list,5))
       SET multiple_header = build(multiple_header,get_severity_header_text(header_rep->header_list[x
         ].header_id),", ")
      ELSE
       SET multiple_header = build(multiple_header,get_severity_header_text(header_rep->header_list[x
         ].header_id))
      ENDIF
    ENDFOR
   ENDIF
   RETURN(multiple_header)
 END ;Subroutine
 SUBROUTINE get_severity_header_text(header_id)
   DECLARE header_text = vc
   IF (header_id=1)
    SET header_text = "Contraindicated"
   ELSEIF (header_id=2)
    SET header_text = "Generally Avoid"
   ELSEIF (header_id=4)
    SET header_text = "Monitor Closely"
   ELSEIF (header_id=8)
    SET header_text = "Adjust Dosing Interval"
   ELSEIF (header_id=16)
    SET header_text = "Adjust Dose"
   ELSEIF (header_id=32)
    SET header_text = "Additional Contraception Recommended"
   ELSEIF (header_id=64)
    SET header_text = "Monitor"
   ENDIF
   RETURN(header_text)
 END ;Subroutine
 SUBROUTINE get_multiple_severity_headers(divide_value)
   IF (divide_value >= 2)
    SET binary_count = (binary_count+ 1)
    IF (mod(binary_count,10)=1
     AND binary_count != 1)
     SET stat = alterlist(header_rep->binary_list,(binary_count+ 9))
    ENDIF
    SET header_rep->binary_list[binary_count].binary_value = mod(divide_value,2)
    SET divide_value = (divide_value/ 2)
    IF (divide_value >= 2)
     CALL get_multiple_severity_headers(divide_value)
    ELSE
     SET binary_count = (binary_count+ 1)
     IF (mod(binary_count,10)=1
      AND binary_count != 1)
      SET stat = alterlist(header_rep->binary_list,(binary_count+ 9))
     ENDIF
     SET header_rep->binary_list[binary_count].binary_value = divide_value
     CALL get_multiple_severity_headers(divide_value)
    ENDIF
   ENDIF
   SET stat = alterlist(header_rep->binary_list,binary_count)
   SET stat = alterlist(header_rep->header_list,10)
   SET head_count = 0
   FOR (x = 1 TO size(header_rep->binary_list,5))
     IF ((header_rep->binary_list[x].binary_value=1))
      SET head_count = (head_count+ 1)
      DECLARE head_id = i2
      SET head_id = 1
      IF (mod(head_count,10)=1
       AND head_count != 1)
       SET stat = alterlist(header_rep->header_list,(head_count+ 9))
      ENDIF
      FOR (y = 1 TO (x - 1))
        SET head_id = (head_id * 2)
      ENDFOR
      SET header_rep->header_list[head_count].header_id = head_id
     ENDIF
   ENDFOR
   SET stat = alterlist(header_rep->header_list,head_count)
 END ;Subroutine
 SUBROUTINE populate_custom_interactions(null)
   DECLARE index = i4 WITH protect, noconstant(0)
   SELECT
    IF ((request->entity_reltn_mean="TDC/SUPP"))
     WHERE (d.entity_reltn_mean=request->entity_reltn_mean)
      AND d.active_ind=1
      AND ((d.begin_effective_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request
      ->to_date)) OR ((request->from_date=0)
      AND (request->to_date=0)))
     ORDER BY cnvtupper(d.entity2_display)
    ELSEIF ((request->entity_reltn_mean="DRUG/TEXT"))
     WHERE expand(index,1,size(request->text_type_list,5),d.entity1_id,request->text_type_list[index]
      .text_type_id)
      AND (d.entity_reltn_mean=request->entity_reltn_mean)
      AND  NOT (d.dcp_entity_reltn_id IN (
     (SELECT
      dcp_entity_reltn_id
      FROM drug_class_int_cstm_entity_r)))
      AND d.active_ind=1
      AND ((d.begin_effective_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request
      ->to_date)) OR ((request->from_date=0)
      AND (request->to_date=0)))
     ORDER BY cnvtupper(d.entity2_display)
    ELSE
     WHERE (d.entity_reltn_mean=request->entity_reltn_mean)
      AND  NOT (d.dcp_entity_reltn_id IN (
     (SELECT
      dcp_entity_reltn_id
      FROM drug_class_int_cstm_entity_r)))
      AND d.active_ind=1
      AND ((d.begin_effective_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request
      ->to_date)) OR ((request->from_date=0)
      AND (request->to_date=0)))
     ORDER BY cnvtupper(d.entity1_display), cnvtupper(d.entity2_display)
    ENDIF
    INTO "nl:"
    FROM dcp_entity_reltn d
    HEAD REPORT
     stat = alterlist(temp_rep->custom_list,10), count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(temp_rep->custom_list,(count1+ 9))
     ENDIF
     stat = alterlist(header_rep->binary_list,10), binary_count = 0, temp_rep->custom_list[count1].
     dcp_entity_reltn_id = d.dcp_entity_reltn_id,
     temp_rep->custom_list[count1].entity1_id = d.entity1_id, temp_rep->custom_list[count1].
     entity1_display = d.entity1_display, temp_rep->custom_list[count1].entity2_id = d.entity2_id,
     temp_rep->custom_list[count1].entity2_display = d.entity2_display, temp_rep->custom_list[count1]
     .user_id = d.updt_id, temp_rep->custom_list[count1].active_ind = d.active_ind
     IF (cnvtint(d.entity1_name)=0)
      temp_rep->custom_list[count1].custom_sever_header = ""
     ELSE
      temp_rep->custom_list[count1].custom_sever_header = populate_severity_header_text(cnvtint(d
        .entity1_name))
     ENDIF
     temp_rep->custom_list[count1].custom_severity_level = get_severity_levels(d.rank_sequence),
     temp_rep->custom_list[count1].entity_reltn_mean = d.entity_reltn_mean, temp_rep->custom_list[
     count1].last_updt_dt_tm = cnvtdatetime(d.updt_dt_tm),
     temp_rep->custom_list[count1].suppress_dt_tm = cnvtdatetime(d.begin_effective_dt_tm), temp_rep->
     custom_list[count1].custom_repeat_num = d.rank_sequence
    FOOT REPORT
     stat = alterlist(temp_rep->custom_list,count1)
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(temp_rep->custom_list,5))
     SET temp_rep->custom_list[x].user_display = get_user_display(temp_rep->custom_list[x].user_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE populate_additional_filter_interactions_category(null)
   SELECT INTO "nl:"
    FROM drug_class_int_custom dcc,
     drug_class_int_cstm_entity_r dcer,
     dcp_entity_reltn der,
     long_text lt
    PLAN (dcc
     WHERE (dcc.custom_interaction_flag=request->custom_interaction_flag)
      AND ((dcc.updt_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request->to_date
      )) OR ((request->from_date=0)
      AND (request->to_date=0))) )
     JOIN (dcer
     WHERE dcer.drug_class_int_custom_id=dcc.drug_class_int_custom_id)
     JOIN (der
     WHERE der.dcp_entity_reltn_id=dcer.dcp_entity_reltn_id
      AND (der.entity_reltn_mean=request->entity_reltn_mean)
      AND der.dcp_entity_reltn_id IN (
     (SELECT
      dcp_entity_reltn_id
      FROM drug_class_int_cstm_entity_r))
      AND der.active_ind=1)
     JOIN (lt
     WHERE lt.parent_entity_id=der.dcp_entity_reltn_id)
    ORDER BY cnvtupper(der.entity1_display), cnvtupper(der.entity2_display), der.dcp_entity_reltn_id
    HEAD REPORT
     stat = alterlist(temp_rep->batch_list,5), batchcnt = 0
    HEAD der.dcp_entity_reltn_id
     batchcnt = (batchcnt+ 1), custom_drug_cnt = 0
     IF (mod(batchcnt,5)=1)
      stat = alterlist(temp_rep->batch_list,(batchcnt+ 4))
     ENDIF
     stat = alterlist(header_rep->binary_list,11), binary_count = 0, temp_rep->batch_list[batchcnt].
     class1_ident = dcc.entity1_ident,
     temp_rep->batch_list[batchcnt].entity1_display = dcc.entity1_display, temp_rep->batch_list[
     batchcnt].class2_ident = dcc.entity2_ident, temp_rep->batch_list[batchcnt].entity2_display = dcc
     .entity2_display,
     temp_rep->batch_list[batchcnt].user_id = dcc.updt_id, temp_rep->batch_list[batchcnt].
     last_updt_dt_tm = cnvtdatetime(der.updt_dt_tm), temp_rep->batch_list[batchcnt].expert_trigger =
     lt.long_text,
     temp_rep->batch_list[batchcnt].dcp_entity1_id = der.entity1_id, temp_rep->batch_list[batchcnt].
     dcp_entity1_display = der.entity1_display, temp_rep->batch_list[batchcnt].dcp_entity2_id = der
     .entity2_id,
     temp_rep->batch_list[batchcnt].dcp_entity2_display = der.entity2_display, temp_rep->batch_list[
     batchcnt].custom_severity_level = get_severity_levels(der.rank_sequence)
    FOOT REPORT
     stat = alterlist(temp_rep->batch_list,batchcnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 02: Failed to retrieve  batch active customizations")
   FOR (x = 1 TO size(temp_rep->batch_list,5))
     SET temp_rep->batch_list[x].user_display = get_user_display(temp_rep->batch_list[x].user_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE populate_additional_filter_interactions_drug(null)
   SELECT INTO "nl:"
    FROM dcp_entity_reltn der,
     long_text lt
    PLAN (der
     WHERE (der.entity_reltn_mean=request->entity_reltn_mean)
      AND  NOT (der.dcp_entity_reltn_id IN (
     (SELECT
      dcp_entity_reltn_id
      FROM drug_class_int_cstm_entity_r)))
      AND der.active_ind=1
      AND ((der.begin_effective_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(
      request->to_date)) OR ((request->from_date=0)
      AND (request->to_date=0))) )
     JOIN (lt
     WHERE lt.parent_entity_id=der.dcp_entity_reltn_id)
    ORDER BY cnvtupper(der.entity1_display), cnvtupper(der.entity2_display)
    HEAD REPORT
     stat = alterlist(temp_rep->batch_list,5), batchcnt = 0
    HEAD der.dcp_entity_reltn_id
     batchcnt = (batchcnt+ 1), custom_drug_cnt = 0
     IF (mod(batchcnt,5)=1)
      stat = alterlist(temp_rep->batch_list,(batchcnt+ 4))
     ENDIF
     stat = alterlist(header_rep->binary_list,11), binary_count = 0, temp_rep->batch_list[batchcnt].
     user_id = der.updt_id,
     temp_rep->batch_list[batchcnt].last_updt_dt_tm = cnvtdatetime(der.updt_dt_tm), temp_rep->
     batch_list[batchcnt].expert_trigger = lt.long_text, temp_rep->batch_list[batchcnt].
     dcp_entity1_id = der.entity1_id,
     temp_rep->batch_list[batchcnt].dcp_entity1_display = der.entity1_display, temp_rep->batch_list[
     batchcnt].dcp_entity2_id = der.entity2_id, temp_rep->batch_list[batchcnt].dcp_entity2_display =
     der.entity2_display,
     temp_rep->batch_list[batchcnt].custom_severity_level = get_severity_levels(der.rank_sequence)
    FOOT REPORT
     stat = alterlist(temp_rep->batch_list,batchcnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 02: Failed to retrieve  batch active customizations")
   FOR (x = 1 TO size(temp_rep->batch_list,5))
     SET temp_rep->batch_list[x].user_display = get_user_display(temp_rep->batch_list[x].user_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE populate_batch_custom_interactions(null)
   SELECT INTO "nl:"
    FROM drug_class_int_custom dcc,
     drug_class_int_cstm_entity_r dcer,
     dcp_entity_reltn der,
     long_text lt
    PLAN (dcc
     WHERE (dcc.custom_type_flag=request->custom_type_flag)
      AND (dcc.custom_interaction_flag=request->custom_interaction_flag)
      AND (dcc.combo_ind=request->combo_ind)
      AND ((dcc.updt_dt_tm BETWEEN cnvtdatetime(request->from_date) AND cnvtdatetime(request->to_date
      )) OR ((request->from_date=0)
      AND (request->to_date=0))) )
     JOIN (dcer
     WHERE dcer.drug_class_int_custom_id=dcc.drug_class_int_custom_id)
     JOIN (der
     WHERE der.dcp_entity_reltn_id=dcer.dcp_entity_reltn_id)
     JOIN (lt
     WHERE lt.long_text_id=dcc.long_text_id)
    ORDER BY cnvtupper(dcc.entity1_display), cnvtupper(dcc.entity2_display)
    HEAD REPORT
     stat = alterlist(temp_rep->batch_list,5), batchcnt = 0
    HEAD dcc.drug_class_int_custom_id
     batchcnt = (batchcnt+ 1), custom_drug_cnt = 0
     IF (mod(batchcnt,5)=1)
      stat = alterlist(temp_rep->batch_list,(batchcnt+ 4))
     ENDIF
     stat = alterlist(header_rep->binary_list,10), binary_count = 0, temp_rep->batch_list[batchcnt].
     drug_class_int_custom_id = dcc.drug_class_int_custom_id,
     temp_rep->batch_list[batchcnt].custom_type_flag = dcc.custom_type_flag, temp_rep->batch_list[
     batchcnt].custom_interaction_flag = dcc.custom_interaction_flag, temp_rep->batch_list[batchcnt].
     combo_ind = dcc.combo_ind,
     temp_rep->batch_list[batchcnt].class1_ident = dcc.entity1_ident, temp_rep->batch_list[batchcnt].
     entity1_display = dcc.entity1_display, temp_rep->batch_list[batchcnt].class2_ident = dcc
     .entity2_ident,
     temp_rep->batch_list[batchcnt].entity2_display = dcc.entity2_display, temp_rep->batch_list[
     batchcnt].user_id = dcc.updt_id, temp_rep->batch_list[batchcnt].last_updt_dt_tm = cnvtdatetime(
      dcc.updt_dt_tm),
     temp_rep->batch_list[batchcnt].suppress_dt_tm = cnvtdatetime(der.begin_effective_dt_tm)
     IF (cnvtint(der.entity1_name)=0)
      temp_rep->batch_list[batchcnt].custom_sever_header = ""
     ELSE
      temp_rep->batch_list[batchcnt].custom_sever_header = populate_severity_header_text(cnvtint(der
        .entity1_name))
     ENDIF
     temp_rep->batch_list[batchcnt].custom_severity_level = get_severity_levels(der.rank_sequence),
     temp_rep->batch_list[batchcnt].custom_repeat_num = der.rank_sequence
    FOOT REPORT
     stat = alterlist(temp_rep->batch_list,batchcnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 02: Failed to retrieve  batch active customizations")
   FOR (x = 1 TO size(temp_rep->batch_list,5))
     SET temp_rep->batch_list[x].user_display = get_user_display(temp_rep->batch_list[x].user_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_user_display(updt_id)
   DECLARE name_full_formatted = vc
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=updt_id
    DETAIL
     name_full_formatted = p.name_full_formatted
    WITH maxrec = 1
   ;end select
   RETURN(name_full_formatted)
 END ;Subroutine
 SUBROUTINE get_drug_identifier(drug_name,drug_id)
   DECLARE drug_identifier = vc
   SELECT INTO "n1:"
    FROM mltm_drug_name mdn,
     mltm_drug_name_map mdnm
    WHERE mdnm.drug_synonym_id=mdn.drug_synonym_id
     AND mdn.drug_name=drug_name
    DETAIL
     drug_identifier = mdnm.drug_identifier
    WITH maxrec = 1
   ;end select
   IF (drug_identifier > "")
    RETURN(drug_identifier)
   ELSEIF ((request->combo_ind=1)
    AND (((request->custom_type_flag=1)) OR ((((request->custom_type_flag=2)) OR ((((request->
   custom_type_flag=3)) OR ((request->custom_type_flag=1))) )) )) )
    RETURN(drug_id)
   ELSEIF ((((request->custom_type_flag=2)) OR ((((request->custom_type_flag=3)) OR ((((request->
   custom_type_flag=4)) OR ((request->custom_type_flag=1))) )) )) )
    RETURN(drug_id)
   ELSE
    RETURN(concat("d",drug_id))
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_custominteractions_duplicate_category(null)
   SELECT INTO "nl:"
    FROM mltm_duplication_categories mdc,
     dcp_entity_reltn dcper
    PLAN (mdc)
     JOIN (dcper
     WHERE dcper.entity2_id=mdc.multum_category_id
      AND (dcper.entity_reltn_mean=request->entity_reltn_mean)
      AND dcper.active_ind=1)
    ORDER BY cnvtupper(mdc.category_name)
    HEAD REPORT
     stat = alterlist(temp_rep->custom_list,10), count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(temp_rep->custom_list,(count1+ 9))
     ENDIF
     temp_rep->custom_list[count1].entity2_id = mdc.multum_category_id, temp_rep->custom_list[count1]
     .entity2_display = mdc.category_name, temp_rep->custom_list[count1].custom_repeat_num = dcper
     .rank_sequence,
     temp_rep->custom_list[count1].suppress_dt_tm = cnvtdatetime(dcper.begin_effective_dt_tm),
     temp_rep->custom_list[count1].last_updt_dt_tm = cnvtdatetime(dcper.updt_dt_tm), temp_rep->
     custom_list[count1].user_id = dcper.updt_id
    FOOT REPORT
     stat = alterlist(temp_rep->custom_list,count1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 01: Failed to retrieve  duplicate categories")
   FOR (x = 1 TO size(temp_rep->custom_list,5))
     SET temp_rep->custom_list[x].user_display = get_user_display(temp_rep->custom_list[x].user_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_severity_levels(level_id)
   DECLARE severity_level = vc
   IF (level_id=0)
    SET severity_level = "Suppress"
   ELSEIF (level_id=1)
    SET severity_level = "Minor"
   ELSEIF (level_id=2)
    SET severity_level = "Moderate"
   ELSEIF (level_id=3)
    SET severity_level = "Major"
   ELSEIF (level_id=4)
    SET severity_level = "Active"
   ENDIF
   RETURN(severity_level)
 END ;Subroutine
 SUBROUTINE populate_table_columns(null)
   IF ((request->custom_interaction_flag=1))
    SET stat = alterlist(reply->collist,8)
    IF ((request->custom_type_flag=0))
     CALL populate_drug_name_column(null)
     CALL populate_drug_drug_module_table_column(null)
    ELSEIF ((request->custom_type_flag=1))
     CALL drug_drug_and_drug_allergy_module_category_drug(null)
     CALL populate_drug_drug_module_table_column(null)
    ELSEIF ((request->custom_type_flag=2))
     CALL drug_drug_and_drug_allergy_module_category_category(null)
     CALL populate_drug_drug_module_table_column(null)
    ENDIF
    CALL create_drug_drug_reply(null)
   ELSEIF ((request->custom_interaction_flag=2))
    SET stat = alterlist(reply->collist,6)
    IF ((request->custom_type_flag=0))
     CALL populate_drug_name_column(null)
     CALL populate_drug_allergy_and_drug_food_module_common_column(null)
    ELSEIF ((request->custom_type_flag=1))
     CALL drug_drug_and_drug_allergy_module_category_drug(null)
     CALL populate_drug_allergy_and_drug_food_module_common_column(null)
    ELSEIF ((request->custom_type_flag=2))
     CALL drug_drug_and_drug_allergy_module_category_category(null)
     CALL populate_drug_allergy_and_drug_food_module_common_column(null)
    ELSEIF ((request->custom_type_flag=3))
     CALL drug_allergy_module_allergy_category_drug(null)
     CALL populate_drug_allergy_and_drug_food_module_common_column(null)
    ELSEIF ((request->custom_type_flag=4))
     CALL drug_allergy_module_allergy_category_category(null)
     CALL populate_drug_allergy_and_drug_food_module_common_column(null)
    ENDIF
    CALL create_drug_allergy_reply(null)
   ELSEIF ((request->custom_interaction_flag=3))
    SET stat = alterlist(reply->collist,5)
    IF ((request->custom_type_flag=0))
     CALL drug_food_module_drug_food(null)
     CALL populate_drug_food_module_column(null)
    ELSEIF ((request->custom_type_flag=2))
     CALL drug_food_module_category_food(null)
     CALL populate_drug_food_module_column(null)
    ENDIF
    CALL create_drug_food_reply(null)
   ELSEIF ((request->custom_interaction_flag=6))
    SET stat = alterlist(reply->collist,5)
    CALL populate_reference_text_module_column(null)
    CALL create_reference_text_reply(null)
   ELSEIF ((request->custom_interaction_flag=7))
    IF ((request->custom_type_flag=2))
     SET stat = alterlist(reply->collist,11)
    ELSE
     SET stat = alterlist(reply->collist,9)
    ENDIF
    CALL populate_additional_filter_column(null)
    CALL populate_additional_filter_customer_interaction(null)
   ELSEIF ((request->custom_interaction_flag=5))
    SET stat = alterlist(reply->collist,6)
    IF ((request->entity_reltn_mean="TDC/SUPP"))
     CALL populate_duplicate_therapy_module_drug_column(null)
     CALL populate_duplicate_therapy_module_column(null)
     CALL create_duplicate_therapy_reply(null)
    ELSEIF ((request->entity_reltn_mean="TDC/CAT/SUPP"))
     CALL populate_duplicate_therapy_module_category_column(null)
     CALL populate_duplicate_therapy_module_column(null)
     CALL populate_duplicate_category_reply(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_drug_drug_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   IF (batch_flag=1)
    FOR (x = 1 TO size(temp_rep->batch_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,8)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       batch_list[x].entity1_display,temp_rep->batch_list[x].class1_ident)
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->batch_list[x].entity1_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = get_drug_identifier(temp_rep->
       batch_list[x].entity2_display,temp_rep->batch_list[x].class2_ident)
      SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->batch_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->batch_list[x].
      custom_severity_level
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->batch_list[x].
      custom_sever_header
      SET reply->rowlist[row_cnt].celllist[7].date_value = temp_rep->batch_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[8].string_value = temp_rep->batch_list[x].user_display
    ENDFOR
   ELSE
    FOR (x = 1 TO size(temp_rep->custom_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,8)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       custom_list[x].entity1_display,cnvtstring(temp_rep->custom_list[x].entity1_id))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity1_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = get_drug_identifier(temp_rep->
       custom_list[x].entity2_display,cnvtstring(temp_rep->custom_list[x].entity2_id))
      SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->custom_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->custom_list[x].
      custom_severity_level
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->custom_list[x].
      custom_sever_header
      SET reply->rowlist[row_cnt].celllist[7].date_value = temp_rep->custom_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[8].string_value = temp_rep->custom_list[x].user_display
    ENDFOR
   ENDIF
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_additional_filter_customer_interaction(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   DECLARE list_size = i4 WITH private
   IF ((request->custom_type_flag=2))
    SET list_size = 11
   ELSE
    SET list_size = 9
   ENDIF
   SET row_cnt = 0
   FOR (x = 1 TO size(temp_rep->batch_list,5))
     IF ((temp_rep->batch_list[x].expert_trigger > " "))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,list_size)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       batch_list[x].dcp_entity1_display,cnvtstring(temp_rep->batch_list[x].dcp_entity1_id))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->batch_list[x].
      dcp_entity1_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = get_drug_identifier(temp_rep->
       batch_list[x].dcp_entity2_display,cnvtstring(temp_rep->batch_list[x].dcp_entity2_id))
      SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->batch_list[x].
      dcp_entity2_display
      IF ((request->custom_type_flag=2))
       SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->batch_list[x].class1_ident
       SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->batch_list[x].entity1_display
       SET reply->rowlist[row_cnt].celllist[7].string_value = temp_rep->batch_list[x].expert_trigger
       SET reply->rowlist[row_cnt].celllist[8].string_value = temp_rep->batch_list[x].
       custom_severity_level
       SET reply->rowlist[row_cnt].celllist[9].string_value = "Client"
       SET reply->rowlist[row_cnt].celllist[10].date_value = temp_rep->batch_list[x].last_updt_dt_tm
       SET reply->rowlist[row_cnt].celllist[11].string_value = temp_rep->batch_list[x].user_display
      ELSE
       SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->batch_list[x].expert_trigger
       SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->batch_list[x].
       custom_severity_level
       SET reply->rowlist[row_cnt].celllist[7].string_value = "Client"
       SET reply->rowlist[row_cnt].celllist[8].date_value = temp_rep->batch_list[x].last_updt_dt_tm
       SET reply->rowlist[row_cnt].celllist[9].string_value = temp_rep->batch_list[x].user_display
      ENDIF
     ENDIF
   ENDFOR
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE create_drug_allergy_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   IF (batch_flag=1)
    FOR (x = 1 TO size(temp_rep->batch_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,6)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       batch_list[x].entity1_display,cnvtstring(temp_rep->batch_list[x].class1_ident))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->batch_list[x].entity1_display
      IF ((((request->custom_type_flag=1)) OR ((request->custom_type_flag=3))) )
       DECLARE pos = i2
       DECLARE identifier = vc
       SET identifier = get_drug_identifier(temp_rep->batch_list[x].entity2_display,cnvtstring(
         temp_rep->batch_list[x].class2_ident))
       SET pos = findstring("d",identifier,1,0)
       IF (pos=0)
        SET reply->rowlist[row_cnt].celllist[3].string_value = concat("d",cnvtstring(temp_rep->
          batch_list[x].class2_ident))
       ELSE
        SET reply->rowlist[row_cnt].celllist[3].string_value = identifier
       ENDIF
      ELSE
       SET reply->rowlist[row_cnt].celllist[3].string_value = get_drug_identifier(temp_rep->
        batch_list[x].entity2_display,cnvtstring(temp_rep->batch_list[x].class2_ident))
      ENDIF
      SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->batch_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[5].date_value = temp_rep->batch_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->batch_list[x].user_display
    ENDFOR
   ELSE
    FOR (x = 1 TO size(temp_rep->custom_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,6)
      IF ((request->custom_type_flag=3)
       AND (request->combo_ind=0))
       SET reply->rowlist[row_cnt].celllist[1].string_value = cnvtstring(temp_rep->custom_list[x].
        entity1_id)
      ELSE
       SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
        custom_list[x].entity1_display,cnvtstring(temp_rep->custom_list[x].entity1_id))
      ENDIF
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity1_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = get_drug_identifier(temp_rep->
       custom_list[x].entity2_display,cnvtstring(temp_rep->custom_list[x].entity2_id))
      SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->custom_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[5].date_value = temp_rep->custom_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->custom_list[x].user_display
    ENDFOR
   ENDIF
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE create_drug_food_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   IF (batch_flag=1)
    FOR (x = 1 TO size(temp_rep->batch_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,5)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       batch_list[x].entity2_display,cnvtstring(temp_rep->batch_list[x].class2_ident))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->batch_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = temp_rep->batch_list[x].
      custom_severity_level
      SET reply->rowlist[row_cnt].celllist[4].date_value = temp_rep->batch_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->batch_list[x].user_display
    ENDFOR
   ELSE
    FOR (x = 1 TO size(temp_rep->custom_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,5)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       custom_list[x].entity2_display,cnvtstring(temp_rep->custom_list[x].entity2_id))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = temp_rep->custom_list[x].
      custom_severity_level
      SET reply->rowlist[row_cnt].celllist[4].date_value = temp_rep->custom_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->custom_list[x].user_display
    ENDFOR
   ENDIF
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE create_duplicate_therapy_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   IF (batch_flag=1)
    FOR (x = 1 TO size(temp_rep->batch_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,6)
      SET reply->rowlist[row_cnt].celllist[1].string_value = temp_rep->batch_list[x].class2_ident
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->batch_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[3].date_value = temp_rep->batch_list[x].suppress_dt_tm
      SET reply->rowlist[row_cnt].celllist[4].nbr_value = temp_rep->batch_list[x].custom_repeat_num
      SET reply->rowlist[row_cnt].celllist[5].date_value = temp_rep->batch_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->batch_list[x].user_display
    ENDFOR
   ELSE
    FOR (x = 1 TO size(temp_rep->custom_list,5))
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist,row_cnt)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,6)
      SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
       custom_list[x].entity2_display,cnvtstring(temp_rep->custom_list[x].entity2_id))
      SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity2_display
      SET reply->rowlist[row_cnt].celllist[3].date_value = temp_rep->custom_list[x].suppress_dt_tm
      SET reply->rowlist[row_cnt].celllist[4].nbr_value = temp_rep->custom_list[x].custom_repeat_num
      SET reply->rowlist[row_cnt].celllist[5].date_value = temp_rep->custom_list[x].last_updt_dt_tm
      SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->custom_list[x].user_display
    ENDFOR
   ENDIF
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_duplicate_category_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   FOR (x = 1 TO size(temp_rep->custom_list,5))
     SET row_cnt = (row_cnt+ 1)
     SET stat = alterlist(reply->rowlist,row_cnt)
     SET stat = alterlist(reply->rowlist[row_cnt].celllist,6)
     SET reply->rowlist[row_cnt].celllist[1].string_value = cnvtstring(temp_rep->custom_list[x].
      entity2_id)
     SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity2_display
     SET reply->rowlist[row_cnt].celllist[3].date_value = temp_rep->custom_list[x].suppress_dt_tm
     SET reply->rowlist[row_cnt].celllist[4].nbr_value = temp_rep->custom_list[x].custom_repeat_num
     SET reply->rowlist[row_cnt].celllist[5].date_value = temp_rep->custom_list[x].last_updt_dt_tm
     SET reply->rowlist[row_cnt].celllist[6].string_value = temp_rep->custom_list[x].user_display
   ENDFOR
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE create_reference_text_reply(null)
   DECLARE x = i4 WITH private
   DECLARE row_cnt = i4 WITH private
   SET row_cnt = 0
   FOR (x = 1 TO size(temp_rep->custom_list,5))
     SET row_cnt = (row_cnt+ 1)
     SET stat = alterlist(reply->rowlist,row_cnt)
     SET stat = alterlist(reply->rowlist[row_cnt].celllist,5)
     SET reply->rowlist[row_cnt].celllist[1].string_value = get_drug_identifier(temp_rep->
      custom_list[x].entity2_display,cnvtstring(temp_rep->custom_list[x].entity2_id))
     SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->custom_list[x].entity2_display
     SET reply->rowlist[row_cnt].celllist[3].string_value = temp_rep->custom_list[x].entity1_display
     SET reply->rowlist[row_cnt].celllist[4].date_value = temp_rep->custom_list[x].last_updt_dt_tm
     SET reply->rowlist[row_cnt].celllist[5].string_value = temp_rep->custom_list[x].user_display
   ENDFOR
   IF (row_cnt < 5000)
    SET reply->high_volume_flag = 0
   ELSEIF (row_cnt >= 5000
    AND row_cnt <= 10000)
    SET reply->high_volume_flag = 1
   ELSEIF (row_cnt > 10000)
    SET reply->high_volume_flag = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_drug_name_column(null)
   SET reply->collist[1].header_text = "Drug Identifier1"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Drug Name1"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Drug Identifier2"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Drug Name2"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_drug_drug_module_table_column(null)
   SET reply->collist[5].header_text = "Severity Level"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Severity Header"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Last Customized Date"
   SET reply->collist[7].data_type = 4
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = "Customized By"
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_allergy_module_allergy_category_category(null)
   SET reply->collist[1].header_text = "Allergy Category Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Allergy Category Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Category Identifier"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Category Name"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_drug_and_drug_allergy_module_category_category(null)
   SET reply->collist[1].header_text = "Category Identifier1"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Category Name1"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Category Identifier2"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Category Name2"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_drug_and_drug_allergy_module_category_drug(null)
   SET reply->collist[1].header_text = "Category Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Category Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Drug Identifier"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Drug Name"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_allergy_module_allergy_category_drug(null)
   SET reply->collist[1].header_text = "Allergy Category Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Allergy Category Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Drug Identifier"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Drug Name"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_food_module_drug_food(null)
   SET reply->collist[1].header_text = "Drug Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Drug Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Severity Level"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
 END ;Subroutine
 SUBROUTINE drug_food_module_category_food(null)
   SET reply->collist[1].header_text = "Category Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Category Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[3].header_text = "Severity Level"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_reference_text_module_column(null)
   SET reply->collist[1].header_text = "Drug Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Drug Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Text Type"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Last Customized Date"
   SET reply->collist[4].data_type = 4
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Customized By"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_duplicate_therapy_module_drug_column(null)
   SET reply->collist[1].header_text = "Drug Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Drug Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_duplicate_therapy_module_category_column(null)
   SET reply->collist[1].header_text = "Category Identifier"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Category Name"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_drug_food_module_column(null)
   SET reply->collist[4].header_text = "Last Customized Date"
   SET reply->collist[4].data_type = 4
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Customized By"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_drug_allergy_and_drug_food_module_common_column(null)
   SET reply->collist[5].header_text = "Last Customized Date"
   SET reply->collist[5].data_type = 4
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Customized By"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_duplicate_therapy_module_column(null)
   SET reply->collist[3].header_text = "Suppress Date"
   SET reply->collist[3].data_type = 4
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Custom Repeat Number"
   SET reply->collist[4].data_type = 3
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Last Customized Date"
   SET reply->collist[5].data_type = 4
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Customized By"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populate_additional_filter_column(null)
   SET reply->collist[1].header_text = "Drug Identifier1"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Drug Name1"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Drug Identifier2"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Drug Name2"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   IF ((request->custom_type_flag=2))
    SET reply->collist[5].header_text = "Category Identifier"
    SET reply->collist[5].data_type = 1
    SET reply->collist[5].hide_ind = 0
    SET reply->collist[6].header_text = "Category Name"
    SET reply->collist[6].data_type = 1
    SET reply->collist[6].hide_ind = 0
    SET reply->collist[7].header_text = "Expert Trigger"
    SET reply->collist[7].data_type = 1
    SET reply->collist[7].hide_ind = 0
    SET reply->collist[8].header_text = "Severity Level"
    SET reply->collist[8].data_type = 1
    SET reply->collist[8].hide_ind = 0
    SET reply->collist[9].header_text = "Source"
    SET reply->collist[9].data_type = 1
    SET reply->collist[9].hide_ind = 0
    SET reply->collist[10].header_text = "Last Customized Date"
    SET reply->collist[10].data_type = 4
    SET reply->collist[10].hide_ind = 0
    SET reply->collist[11].header_text = "Customized By"
    SET reply->collist[11].data_type = 1
    SET reply->collist[11].hide_ind = 0
   ELSE
    SET reply->collist[5].header_text = "Expert Trigger"
    SET reply->collist[5].data_type = 1
    SET reply->collist[5].hide_ind = 0
    SET reply->collist[6].header_text = "Severity Level"
    SET reply->collist[6].data_type = 1
    SET reply->collist[6].hide_ind = 0
    SET reply->collist[7].header_text = "Source"
    SET reply->collist[7].data_type = 1
    SET reply->collist[7].hide_ind = 0
    SET reply->collist[8].header_text = "Last Customized Date"
    SET reply->collist[8].data_type = 4
    SET reply->collist[8].hide_ind = 0
    SET reply->collist[9].header_text = "Customized By"
    SET reply->collist[9].data_type = 1
    SET reply->collist[9].hide_ind = 0
   ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
