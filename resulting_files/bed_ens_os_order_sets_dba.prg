CREATE PROGRAM bed_ens_os_order_sets:dba
 RECORD request_cv(
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
 FREE SET temp_note
 RECORD temp_note(
   1 notes[*]
     2 note_id = f8
 )
 FREE SET temp_cs
 RECORD temp_cs(
   1 syns[*]
     2 mnemonic = vc
     2 synonym_id = f8
     2 activity_code_value = f8
     2 catalog_code_value = f8
 )
 FREE SET temp_bill
 RECORD temp_bill(
   1 items[*]
     2 bill_id = f8
     2 catalog_code_value = f8
     2 seq = i2
     2 active_ind = i2
     2 mnemonic = vc
 )
 FREE SET temp_order_sentence
 RECORD temp_order_sentence(
   1 order_sentence_id = f8
   1 order_sentence_display_line = vc
   1 oe_format_id = f8
   1 usage_flag = i2
   1 order_encntr_group_cd = f8
   1 ord_comment_long_text_id = f8
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 parent_entity2_id = f8
   1 parent_entity2_name = vc
   1 ic_auto_verify_flag = i2
   1 discern_auto_verify_flag = i2
   1 external_identifier = vc
   1 updt_applctx = f8
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
 )
 FREE SET temp_order_sentence_detail
 RECORD temp_order_sentence_detail(
   1 os_detail[*]
     2 order_sentence_id = f8
     2 sequence = i4
     2 oe_field_value = f8
     2 oe_field_id = f8
     2 oe_field_display_value = vc
     2 oe_field_meaning_id = f8
     2 field_type_flag = i2
     2 default_parent_entity_name = vc
     2 default_parent_entity_id = f8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
 )
 FREE SET sent_to_delete
 RECORD sent_to_delete(
   1 order_sentence[*]
     2 order_sentence_id = f8
 )
 FREE SET temp_new_note_ids
 RECORD temp_new_note_ids(
   1 new_note[*]
     2 new_note_id = f8
 )
 FREE SET same_or_cd_val
 RECORD same_or_cd_val(
   1 cs_entry[*]
     2 cs_syn_id = f8
     2 cs_mnem = vc
     2 cs_cd_val = f8
     2 cs_seq = i4
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_sets[*]
      2 code_value = f8
      2 os_synonyms[*]
        3 synonym_id = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE active_status_code_value = f8 WITH protect
 DECLARE inactive_status_code_value = f8 WITH protect
 DECLARE primary_code_value = f8 WITH protect
 DECLARE cs_orderable_code_value = f8 WITH protect
 DECLARE cs_note_code_value = f8 WITH protect
 DECLARE cs_label_code_value = f8 WITH protect
 DECLARE ord_code_value = f8 WITH protect
 DECLARE syn_cnt = i4 WITH protect
 DECLARE list_cnt = i4 WITH protect
 DECLARE tot_cnt = i4 WITH protect
 DECLARE oscnt = i4 WITH protect
 DECLARE new_bill_id = f8 WITH protect
 DECLARE sequence = i4 WITH protect
 DECLARE syn_description = vc WITH protect
 DECLARE inact_description = vc WITH protect
 DECLARE long_text_parser = vc WITH protect
 SET syn_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 DECLARE long_txt = vc WITH protect
 DECLARE lt_id = i4 WITH protect
 DECLARE long_text_cnt = i4 WITH protect
 DECLARE new_note_cnt = i4 WITH protect
 DECLARE delete_sent_cnt = i4 WITH protect
 DECLARE os_active_ind = i2 WITH protect
 DECLARE x = i4 WITH protect
 DECLARE z = i4 WITH protect
 DECLARE l = i4 WITH protect
 DECLARE cs_comp_cd = f8 WITH protect
 DECLARE cs_comp_mnemonic = vc WITH protect
 DECLARE cs_comp_owner_cd = f8 WITH protect
 DECLARE ex_cd_mnem = vc WITH protect
 DECLARE ex_cd_val = f8 WITH protect
 DECLARE ex_cd_idx = i4 WITH protect
 DECLARE k = i4 WITH protect
 DECLARE k1 = i4 WITH protect
 DECLARE k2 = i4 WITH protect
 DECLARE sequence = i4 WITH protect
 DECLARE bill_id = f8 WITH protect
 DECLARE bill_ind = i2 WITH protect
 DECLARE existing_bi_seq = i4 WITH protect
 DECLARE existing_bi_active_ind = i4 WITH protect
 DECLARE new_order_sentence_id = f8 WITH protect
 DECLARE del_size = i4 WITH protect
 DECLARE new_lt_id = f8 WITH protect
 DECLARE comp_count = i4 WITH protect
 DECLARE rec_size = i4 WITH protect, noconstant(0)
 DECLARE cs_comp_cnt = i4 WITH protect, noconstant(0)
 DECLARE setupcodevalues(dummyvar=i2) = null
 DECLARE getactiveindfororderset(x=i4) = null
 DECLARE insertneworderset(x=i4) = null
 DECLARE updateorderset(x=i4) = null
 DECLARE insertnewsynonym(x=i4,y=i4) = null
 DECLARE updatesynonym(x=i4,y=i4) = null
 DECLARE deletebillitems(x=i4) = null
 DECLARE saveoriginalsentenceids(x=i4) = null
 DECLARE deletecaresetcomponents(x=i4) = null
 DECLARE insertthendeletesentences(x=i4) = null
 DECLARE deletetheninsertnotes(x=i4) = null
 DECLARE insertsections(x=i4) = null
 DECLARE buildlongtextidparser(x=i4,y=i4) = null
 DECLARE insertnewcaresetcomponents(x=i4,z=i4) = null
 DECLARE updatecaresetcomponent(x=i4,z=i4) = null
 DECLARE deletespecificcscomponent(x=i4,z=i4) = null
 DECLARE createsameorcscomprecordstruct(x=i4) = null
 CALL setupcodevalues(0)
 SET os_active_ind = 0
 SET oscnt = size(request->order_sets,5)
 SET stat = alterlist(reply->order_sets,oscnt)
 FOR (x = 1 TO oscnt)
   CALL getactiveindfororderset(x)
   IF ((request->order_sets[x].action_flag=1))
    CALL insertneworderset(x)
   ELSEIF ((request->order_sets[x].action_flag=2))
    CALL updateorderset(x)
   ENDIF
   SET syn_cnt = size(request->order_sets[x].os_synonyms,5)
   SET stat = alterlist(reply->order_sets[x].os_synonyms,syn_cnt)
   FOR (y = 1 TO syn_cnt)
    IF ((request->order_sets[x].os_synonyms[y].action_flag=1))
     CALL insertnewsynonym(x,y)
    ELSEIF ((request->order_sets[x].os_synonyms[y].action_flag=2))
     CALL updatesynonym(x,y)
    ENDIF
    SET reply->order_sets[x].os_synonyms[y].synonym_id = request->order_sets[x].os_synonyms[y].
    synonym_id
   ENDFOR
   CALL deletebillitems(x)
   CALL saveoriginalsentenceids(x)
   CALL deletecaresetcomponents(x)
   CALL insertthendeletesentences(x)
   CALL deletetheninsertnotes(x)
   CALL insertsections(x)
   CALL bederrorcheck("Entering createSameOrCsCompRecordStruct")
   CALL createsameorcscomprecordstruct(x)
   CALL echorecord(same_or_cd_val)
   SET cs_comp_cnt = size(request->order_sets[x].component_synonyms,5)
   FOR (z = 1 TO cs_comp_cnt)
     IF ((request->order_sets[x].component_synonyms[z].action_flag=1))
      CALL insertnewcaresetcomponents(x,z)
     ELSEIF ((request->order_sets[x].component_synonyms[z].action_flag IN (0, 2, 3)))
      CALL updatecaresetcomponent(x,z)
     ENDIF
   ENDFOR
   SET reply->order_sets[x].code_value = request->order_sets[x].code_value
 ENDFOR
 SUBROUTINE createsameorcscomprecordstruct(x)
   SET comp_count = 0
   SET comp_count = size(request->order_sets[x].component_synonyms,5)
   SET stat = alterlist(same_or_cd_val->cs_entry,comp_count)
   FOR (l = 1 TO comp_count)
     SET ex_cd_val = 0.0
     SET ex_cd_mnem = ""
     SET ex_cd_idx = 0
     SET k = 0
     SELECT INTO "nl:"
      FROM order_catalog_synonym ocs
      PLAN (ocs
       WHERE (ocs.synonym_id=request->order_sets[x].component_synonyms[l].synonym_id))
      DETAIL
       ex_cd_val = ocs.catalog_cd, ex_cd_mnem = ocs.mnemonic
      WITH nocounter
     ;end select
     SET sequence = request->order_sets[x].component_synonyms[l].sequence
     SET rec_size = size(same_or_cd_val->cs_entry,5)
     IF ((request->order_sets[x].component_synonyms[l].action_flag IN (0, 1, 2)))
      IF (rec_size > 0)
       SET ex_cd_idx = locateval(k,1,rec_size,ex_cd_val,same_or_cd_val->cs_entry[k].cs_cd_val)
       IF (ex_cd_idx > 0)
        IF ((same_or_cd_val->cs_entry[ex_cd_idx].cs_seq > sequence))
         SET same_or_cd_val->cs_entry[l].cs_cd_val = ex_cd_val
         SET same_or_cd_val->cs_entry[l].cs_seq = sequence
         SET same_or_cd_val->cs_entry[l].cs_mnem = ex_cd_mnem
         SET same_or_cd_val->cs_entry[l].cs_syn_id = request->order_sets[x].component_synonyms[l].
         synonym_id
         SET same_or_cd_val->cs_entry[ex_cd_idx].cs_syn_id = 0.0
         SET same_or_cd_val->cs_entry[ex_cd_idx].cs_mnem = ""
         SET same_or_cd_val->cs_entry[ex_cd_idx].cs_cd_val = 0.0
         SET same_or_cd_val->cs_entry[ex_cd_idx].cs_seq = 0
        ENDIF
       ELSEIF (ex_cd_idx=0)
        SET same_or_cd_val->cs_entry[l].cs_mnem = ex_cd_mnem
        SET same_or_cd_val->cs_entry[l].cs_syn_id = request->order_sets[x].component_synonyms[l].
        synonym_id
        SET same_or_cd_val->cs_entry[l].cs_cd_val = ex_cd_val
        SET same_or_cd_val->cs_entry[l].cs_seq = sequence
       ENDIF
      ELSE
       SET same_or_cd_val->cs_entry[l].cs_mnem = ex_cd_mnem
       SET same_or_cd_val->cs_entry[l].cs_syn_id = request->order_sets[x].component_synonyms[l].
       synonym_id
       SET same_or_cd_val->cs_entry[l].cs_cd_val = ex_cd_val
       SET same_or_cd_val->cs_entry[l].cs_seq = sequence
      ENDIF
     ELSE
      SET same_or_cd_val->cs_entry[l].cs_syn_id = 0.0
      SET same_or_cd_val->cs_entry[l].cs_mnem = ""
      SET same_or_cd_val->cs_entry[l].cs_cd_val = 0.0
      SET same_or_cd_val->cs_entry[l].cs_seq = 0
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE setupcodevalues(dummyvar)
   SET active_status_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
    DETAIL
     active_status_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET inactive_status_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="INACTIVE"
     AND cv.active_ind=1
    DETAIL
     inactive_status_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET primary_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=6011
     AND cv.cdf_meaning="PRIMARY"
     AND cv.active_ind=1
    DETAIL
     primary_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET cs_orderable_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=6030
     AND cv.cdf_meaning="ORDERABLE"
     AND cv.active_ind=1
    DETAIL
     cs_orderable_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET cs_note_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=6030
     AND cv.cdf_meaning="NOTE"
     AND cv.active_ind=1
    DETAIL
     cs_note_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET cs_label_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=6030
     AND cv.cdf_meaning="LABEL"
     AND cv.active_ind=1
    DETAIL
     cs_label_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET ord_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=13016
     AND cv.cdf_meaning="ORD CAT"
     AND cv.active_ind=1
    DETAIL
     ord_code_value = cv.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getactiveindfororderset(x)
   SELECT INTO "nl:"
    FROM order_catalog oc
    WHERE (oc.catalog_cd=request->order_sets[x].code_value)
    DETAIL
     os_active_ind = oc.active_ind
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE insertneworderset(x)
   DECLARE new_cv = f8
   SET new_cv = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_cv = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM code_value cv
    SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
     cv.cki = null, cv.concept_cki = " ", cv.display_key_nls = null,
     cv.display = trim(substring(1,40,request->order_sets[x].description)), cv.display_key = trim(
      cnvtupper(cnvtalphanum(substring(1,40,request->order_sets[x].description)))), cv.description =
     trim(substring(1,60,request->order_sets[x].description)),
     cv.definition = null, cv.data_status_cd = 0, cv.data_status_prsnl_id = 0,
     cv.active_type_cd = active_status_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3),
     cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("CODE_VALUE ins error")
   SET request->order_sets[x].code_value = new_cv
   INSERT  FROM order_catalog oc
    SET oc.catalog_cd = request->order_sets[x].code_value, oc.abn_review_ind = null, oc
     .activity_type_cd = request->order_sets[x].activity_type_code_value,
     oc.activity_subtype_cd = request->order_sets[x].subactivity_type_code_value, oc
     .resource_route_lvl = null, oc.active_ind = 1,
     oc.prompt_ind = null, oc.catalog_type_cd = request->order_sets[x].catalog_type_code_value, oc
     .requisition_format_cd = 0,
     oc.requisition_routing_cd = 0, oc.description = trim(substring(1,60,request->order_sets[x].
       description)), oc.print_req_ind = 0,
     oc.orderable_type_flag = 6, oc.oe_format_id = 0, oc.prep_info_flag = 0,
     oc.cont_order_method_flag = 0, oc.primary_mnemonic = trim(substring(1,100,request->order_sets[x]
       .description)), oc.dept_display_name = trim(substring(1,60,request->order_sets[x].description)
      ),
     oc.ref_text_mask = null, oc.source_vocab_ident = null, oc.source_vocab_mean = null,
     oc.dcp_clin_cat_cd = request->order_sets[x].clin_cat_code_value, oc.cki = null, oc.concept_cki
      = null,
     oc.consent_form_ind = 0, oc.inst_restriction_ind = 0, oc.schedule_ind = 0,
     oc.quick_chart_ind = 0, oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0,
     oc.dup_checking_ind = null, oc.bill_only_ind = 0, oc.form_level = null,
     oc.modifiable_flag = 1, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->
     updt_id,
     oc.updt_task = reqinfo->updt_task, oc.updt_cnt = 0, oc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ORDER_CATALOG ins error")
   SET new_bill_id = 0.0
   SELECT INTO "NL:"
    j = seq(bill_item_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_bill_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM bill_item b
    SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->order_sets[x].code_value,
     b.ext_parent_contributor_cd = ord_code_value,
     b.ext_child_reference_id = 0, b.ext_child_contributor_cd = 0, b.ext_description = trim(request->
      order_sets[x].description),
     b.ext_owner_cd = request->order_sets[x].activity_type_code_value, b.parent_qual_cd = 1, b
     .charge_point_cd = 0,
     b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
     b.ext_short_desc = trim(substring(1,50,request->order_sets[x].description)), b
     .ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name = null,
     b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
     b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
     b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
     b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
     updt_applctx,
     b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
     b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
     b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100")
    WITH nocounter
   ;end insert
   CALL bederrorcheck("BILL_ITEM ins error (1)")
 END ;Subroutine
 SUBROUTINE updateorderset(x)
   UPDATE  FROM code_value cv
    SET cv.description = trim(substring(1,60,request->order_sets[x].description)), cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
     .updt_cnt+ 1)
    WHERE (cv.code_value=request->order_sets[x].code_value)
    WITH nocounter
   ;end update
   CALL bederrorcheck("CODE_VALUE upd error")
   UPDATE  FROM order_catalog oc
    SET oc.activity_type_cd = request->order_sets[x].activity_type_code_value, oc.activity_subtype_cd
      = request->order_sets[x].subactivity_type_code_value, oc.catalog_type_cd = request->order_sets[
     x].catalog_type_code_value,
     oc.description = trim(substring(1,60,request->order_sets[x].description)), oc.dcp_clin_cat_cd =
     request->order_sets[x].clin_cat_code_value, oc.form_level = 0,
     oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task =
     reqinfo->updt_task,
     oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->updt_applctx
    WHERE (oc.catalog_cd=request->order_sets[x].code_value)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ORDER_CATALOG upd error (1)")
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.catalog_type_cd = request->order_sets[x].catalog_type_code_value, ocs.activity_type_cd =
     request->order_sets[x].activity_type_code_value, ocs.activity_subtype_cd = request->order_sets[x
     ].subactivity_type_code_value,
     ocs.concentration_strength = 0, ocs.concentration_volume = 0, ocs.hide_flag = request->
     order_sets[x].hide_ind,
     ocs.dcp_clin_cat_cd = request->order_sets[x].clin_cat_code_value, ocs.updt_applctx = reqinfo->
     updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1),
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
      = reqinfo->updt_task
    WHERE (ocs.catalog_cd=request->order_sets[x].code_value)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ORDER_CATALOG_SYNONYM upd error (2)")
   UPDATE  FROM bill_item b
    SET b.ext_description = trim(request->order_sets[x].description), b.ext_owner_cd = request->
     order_sets[x].activity_type_code_value, b.ext_short_desc = trim(substring(1,50,request->
       order_sets[x].description)),
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->updt_applctx, b
     .updt_cnt = (b.updt_cnt+ 1),
     b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
    WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
     AND b.child_seq=0
     AND b.ext_child_reference_id=0
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET new_bill_id = 0.0
    SELECT INTO "NL:"
     j = seq(bill_item_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_bill_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM bill_item b
     SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->order_sets[x].code_value,
      b.ext_parent_contributor_cd = ord_code_value,
      b.ext_child_reference_id = 0, b.ext_child_contributor_cd = 0, b.ext_description = trim(request
       ->order_sets[x].description),
      b.ext_owner_cd = request->order_sets[x].activity_type_code_value, b.parent_qual_cd = 1, b
      .charge_point_cd = 0,
      b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
      b.ext_short_desc = trim(substring(1,50,request->order_sets[x].description)), b
      .ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name = null,
      b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
      b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
      b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
      b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
      b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
      b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100")
     WITH nocounter
    ;end insert
   ENDIF
   CALL bederrorcheck("BILL_ITEM ins error (2)")
 END ;Subroutine
 SUBROUTINE insertnewsynonym(x,y)
   DECLARE new_order_synonym_id = f8
   SET new_order_synonym_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_order_synonym_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM order_catalog_synonym ocs
    SET ocs.synonym_id = new_order_synonym_id, ocs.catalog_cd = request->order_sets[x].code_value,
     ocs.catalog_type_cd = request->order_sets[x].catalog_type_code_value,
     ocs.mnemonic = request->order_sets[x].os_synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
      request->order_sets[x].os_synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->order_sets[x].
     os_synonyms[y].mnem_type_code_value,
     ocs.oe_format_id = 0, ocs.active_ind = request->order_sets[x].os_synonyms[y].active_ind, ocs
     .activity_type_cd = request->order_sets[x].activity_type_code_value,
     ocs.activity_subtype_cd = request->order_sets[x].subactivity_type_code_value, ocs
     .orderable_type_flag = 6, ocs.concentration_strength = null,
     ocs.concentration_volume = null, ocs.active_status_cd = active_status_code_value, ocs
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.ref_text_mask = null, ocs
     .multiple_ord_sent_ind = null,
     ocs.hide_flag = request->order_sets[x].hide_ind, ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = request
     ->order_sets[x].clin_cat_code_value,
     ocs.filtered_od_ind = null, ocs.cki = null, ocs.mnemonic_key_cap_nls = null,
     ocs.virtual_view = " ", ocs.health_plan_view = null, ocs.concept_cki = null,
     ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = 0, ocs.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ORDER_CATALOG_SYNONYM ins error")
   SET request->order_sets[x].os_synonyms[y].synonym_id = new_order_synonym_id
   IF ((request->order_sets[x].os_synonyms[y].mnem_type_code_value=primary_code_value))
    UPDATE  FROM order_catalog oc
     SET oc.primary_mnemonic = request->order_sets[x].os_synonyms[y].mnemonic, oc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
      oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->
      updt_applctx
     WHERE (oc.catalog_cd=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ORDER_CATALOG upd error (2)")
    UPDATE  FROM bill_item b
     SET b.ext_short_desc = trim(substring(1,50,request->order_sets[x].os_synonyms[y].mnemonic)), b
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("BILL_ITEM upd error (1)")
    SET os_active_ind = request->order_sets[x].os_synonyms[y].active_ind
   ENDIF
   INSERT  FROM ocs_facility_r ofr
    SET ofr.synonym_id = new_order_synonym_id, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
     updt_applctx,
     ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ofr.updt_id = reqinfo->
     updt_id,
     ofr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("OCS_FACILITY_R ins error")
 END ;Subroutine
 SUBROUTINE updatesynonym(x,y)
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.active_ind = request->order_sets[x].os_synonyms[y].active_ind, ocs.mnemonic = request->
     order_sets[x].os_synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(request->order_sets[x].
      os_synonyms[y].mnemonic),
     ocs.mnemonic_type_cd = request->order_sets[x].os_synonyms[y].mnem_type_code_value, ocs
     .updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1),
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
      = reqinfo->updt_task
    WHERE (ocs.synonym_id=request->order_sets[x].os_synonyms[y].synonym_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ORDER_CATALOG_SYNONYM upd error (1)")
   IF ((request->order_sets[x].os_synonyms[y].mnem_type_code_value=primary_code_value))
    UPDATE  FROM order_catalog oc
     SET oc.active_ind = request->order_sets[x].os_synonyms[y].active_ind, oc.primary_mnemonic =
      request->order_sets[x].os_synonyms[y].mnemonic, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1
      ),
      oc.updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ORDER_CATALOG upd error (3)")
    UPDATE  FROM bill_item b
     SET b.ext_short_desc = trim(substring(1,50,request->order_sets[x].os_synonyms[y].mnemonic)), b
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("BILL_ITEM upd error (2)")
    IF ((request->order_sets[x].os_synonyms[y].active_ind=0)
     AND os_active_ind=1)
     UPDATE  FROM bill_item b
      SET b.active_ind = 0, b.active_status_cd = inactive_status_code_value, b.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
       .updt_applctx = reqinfo->updt_applctx,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
      WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
      WITH nocounter
     ;end update
     CALL bederrorcheck("BILL_ITEM upd error (3)")
    ELSEIF ((request->order_sets[x].os_synonyms[y].active_ind=1)
     AND os_active_ind=0)
     DECLARE tcnt = i4
     SET tcnt = 0
     SELECT INTO "nl:"
      FROM cs_component cc,
       order_catalog_synonym ocs
      PLAN (cc
       WHERE (cc.catalog_cd=request->order_sets[x].code_value)
        AND cc.comp_type_cd=cs_orderable_code_value)
       JOIN (ocs
       WHERE ocs.synonym_id=cc.comp_id)
      ORDER BY cc.comp_seq
      HEAD REPORT
       tcnt = 0, list_cnt = 0, stat = alterlist(temp_cs->syns,10)
      DETAIL
       tcnt = (tcnt+ 1), list_cnt = (list_cnt+ 1)
       IF (list_cnt > 10)
        stat = alterlist(temp_cs->syns,(tcnt+ 10)), list_cnt = 1
       ENDIF
       temp_cs->syns[tcnt].mnemonic = ocs.mnemonic, temp_cs->syns[tcnt].catalog_code_value = ocs
       .catalog_cd, temp_cs->syns[tcnt].synonym_id = ocs.synonym_id,
       temp_cs->syns[tcnt].activity_code_value = ocs.activity_type_cd
      FOOT REPORT
       stat = alterlist(temp_cs->syns,tcnt)
      WITH nocounter
     ;end select
     FOR (z = 1 TO tcnt)
       SET bill_id = 0
       SET bill_ind = 0
       SELECT INTO "nl:"
        FROM bill_item b
        PLAN (b
         WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
          AND b.active_ind=0
          AND (b.ext_child_reference_id=temp_cs->syns[z].catalog_code_value))
        ORDER BY b.child_seq
        DETAIL
         IF (bill_ind=0)
          bill_id = b.bill_item_id, bill_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (bill_id > 0)
        UPDATE  FROM bill_item b
         SET b.active_ind = 1, b.ext_description = trim(temp_cs->syns[z].mnemonic), b.ext_owner_cd =
          temp_cs->syns[z].activity_code_value,
          b.ext_short_desc = trim(substring(1,50,temp_cs->syns[z].mnemonic)), b.active_status_cd =
          active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          b.updt_applctx = reqinfo->updt_applctx,
          b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->
          updt_id
         WHERE b.bill_item_id=bill_id
         WITH nocounter
        ;end update
        CALL bederrorcheck("BILL_ITEM upd error (4)")
       ELSE
        SET sequence = 0
        SELECT INTO "nl:"
         temp_seq = max(b.child_seq)
         FROM bill_item b
         PLAN (b
          WHERE (b.ext_child_reference_id=temp_cs->syns[z].catalog_code_value)
           AND (b.ext_parent_reference_id=request->order_sets[x].code_value))
         DETAIL
          sequence = temp_seq
         WITH nocounter
        ;end select
        SET new_bill_id = 0.0
        SELECT INTO "NL:"
         j = seq(bill_item_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_bill_id = cnvtreal(j)
         WITH format, counter
        ;end select
        INSERT  FROM bill_item b
         SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->order_sets[x].
          code_value, b.ext_parent_contributor_cd = ord_code_value,
          b.ext_child_reference_id = temp_cs->syns[z].catalog_code_value, b.ext_child_contributor_cd
           = ord_code_value, b.ext_description = trim(temp_cs->syns[z].mnemonic),
          b.ext_owner_cd = temp_cs->syns[z].activity_code_value, b.parent_qual_cd = 1, b
          .charge_point_cd = 0,
          b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
          b.ext_short_desc = trim(substring(1,50,temp_cs->syns[z].mnemonic)), b
          .ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name = "CODE_VALUE",
          b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
          b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = (sequence+ 1),
          b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
          b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
          updt_applctx,
          b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
          b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
           curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
          b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
        CALL bederrorcheck("BILL_ITEM ins error (3)")
       ENDIF
     ENDFOR
    ENDIF
    SET os_active_ind = request->order_sets[x].os_synonyms[y].active_ind
   ENDIF
 END ;Subroutine
 SUBROUTINE deletebillitems(x)
   FOR (y = 1 TO size(request->order_sets[x].component_synonyms,5))
     FREE SET temp_os_bi
     RECORD temp_os_bi(
       1 qual[*]
         2 syn_id = f8
         2 seq = i4
         2 mnemonic = vc
         2 bi_id = f8
     )
     DECLARE max_seq = i4
     DECLARE bi_cnt = i4
     SET max_seq = 0
     SET bi_cnt = 0
     DECLARE syn_mnemonic = vc
     DECLARE syn_cat_code = f8
     SET syn_cat_code = 0.0
     SELECT INTO "nl:"
      FROM order_catalog_synonym o
      PLAN (o
       WHERE (o.synonym_id=request->order_sets[x].component_synonyms[y].synonym_id))
      DETAIL
       syn_cat_code = o.catalog_cd, syn_mnemonic = o.mnemonic
      WITH nocounter
     ;end select
     DECLARE os_bi_cnt = i4
     DECLARE del_seq = i4
     SET os_bi_cnt = 0
     SET max_seq = 0
     SET del_seq = 0
     SELECT INTO "nl:"
      FROM cs_component c,
       order_catalog_synonym o
      PLAN (c
       WHERE (c.catalog_cd=request->order_sets[x].code_value)
        AND c.comp_type_cd=cs_orderable_code_value)
       JOIN (o
       WHERE o.synonym_id=c.comp_id
        AND o.catalog_cd=syn_cat_code)
      ORDER BY c.comp_seq
      DETAIL
       os_bi_cnt = (os_bi_cnt+ 1), stat = alterlist(temp_os_bi->qual,os_bi_cnt), temp_os_bi->qual[
       os_bi_cnt].syn_id = o.synonym_id,
       temp_os_bi->qual[os_bi_cnt].mnemonic = o.mnemonic, temp_os_bi->qual[os_bi_cnt].seq = os_bi_cnt,
       del_seq = os_bi_cnt
      WITH nocounter
     ;end select
     CALL echorecord(temp_os_bi)
     IF (os_bi_cnt=0)
      UPDATE  FROM bill_item b
       SET b.active_ind = 0, b.ext_description = syn_mnemonic, b.ext_short_desc = trim(substring(1,50,
          syn_mnemonic)),
        b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
        updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->
        updt_task,
        b.updt_id = reqinfo->updt_id
       WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
        AND b.ext_child_reference_id=syn_cat_code
       WITH nocounter
      ;end update
      CALL bederrorcheck("BILL_ITEM upd error (5)")
     ELSE
      UPDATE  FROM bill_item b,
        (dummyt d  WITH seq = value(os_bi_cnt))
       SET b.ext_description = temp_os_bi->qual[d.seq].mnemonic, b.ext_short_desc = trim(substring(1,
          50,temp_os_bi->qual[d.seq].mnemonic)), b.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3),
        b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_applctx = reqinfo->updt_applctx,
        b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
       PLAN (d)
        JOIN (b
        WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
         AND b.ext_child_reference_id=syn_cat_code
         AND (b.child_seq=temp_os_bi->qual[d.seq].seq))
       WITH nocounter
      ;end update
      CALL bederrorcheck("BILL_ITEM upd error (6)")
      UPDATE  FROM bill_item b
       SET b.active_ind = 0, b.ext_description = syn_mnemonic, b.ext_short_desc = trim(substring(1,50,
          syn_mnemonic)),
        b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
        updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->
        updt_task,
        b.updt_id = reqinfo->updt_id
       WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
        AND b.ext_child_reference_id=syn_cat_code
        AND b.child_seq > del_seq
       WITH nocounter
      ;end update
      CALL bederrorcheck("BILL_ITEM upd error (7)")
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE saveoriginalsentenceids(x)
  SELECT INTO "nl:"
   FROM cs_component cc
   WHERE (cc.catalog_cd=request->order_sets[x].code_value)
    AND cc.order_sentence_id > 0
   HEAD REPORT
    delete_sent_cnt = 0
   DETAIL
    delete_sent_cnt = (delete_sent_cnt+ 1), stat = alterlist(sent_to_delete->order_sentence,
     delete_sent_cnt), sent_to_delete->order_sentence[delete_sent_cnt].order_sentence_id = cc
    .order_sentence_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("CS_COMPONENT sel error (1)")
 END ;Subroutine
 SUBROUTINE deletecaresetcomponents(x)
  DELETE  FROM cs_component cc
   WHERE (cc.catalog_cd=request->order_sets[x].code_value)
   WITH nocounter
  ;end delete
  CALL bederrorcheck("CS_COMPONENT del error")
 END ;Subroutine
 SUBROUTINE insertthendeletesentences(x)
   DECLARE comp_cnt = i4
   DECLARE os_ind = i4
   DECLARE osd_ind = i4
   DECLARE os_detail_cnt = i4
   SET new_note_cnt = 0
   SET long_text_cnt = 0
   SET long_text_parser = " lt.long_text_id IN ("
   SET comp_cnt = size(request->order_sets[x].component_synonyms,5)
   FOR (y = 1 TO comp_cnt)
     IF ((request->order_sets[x].component_synonyms[y].action_flag IN (0, 1, 2)))
      SET new_order_sentence_id = 0.0
      IF ((request->order_sets[x].component_synonyms[y].sentence_id > 0))
       SET os_ind = 0
       SET osd_ind = 0
       CALL echo(build("*****sentence**",request->order_sets[x].component_synonyms[y].sentence_id))
       SELECT INTO "nl:"
        FROM order_sentence os,
         order_sentence_detail osd
        PLAN (os
         WHERE (os.order_sentence_id=request->order_sets[x].component_synonyms[y].sentence_id))
         JOIN (osd
         WHERE osd.order_sentence_id=outerjoin(os.order_sentence_id))
        DETAIL
         os_ind = 1
         IF (osd.order_sentence_id > 0)
          osd_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (os_ind=1)
        SELECT INTO "NL:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_order_sentence_id = cnvtreal(j)
         WITH format, counter
        ;end select
        IF (osd_ind=1)
         SET os_detail_cnt = 0
         SELECT INTO "nl:"
          FROM order_sentence_detail osd
          WHERE (osd.order_sentence_id=request->order_sets[x].component_synonyms[y].sentence_id)
          HEAD osd.sequence
           os_detail_cnt = (os_detail_cnt+ 1), stat = alterlist(temp_order_sentence_detail->os_detail,
            os_detail_cnt), temp_order_sentence_detail->os_detail[os_detail_cnt].order_sentence_id =
           osd.order_sentence_id,
           temp_order_sentence_detail->os_detail[os_detail_cnt].sequence = osd.sequence,
           temp_order_sentence_detail->os_detail[os_detail_cnt].oe_field_value = osd.oe_field_value,
           temp_order_sentence_detail->os_detail[os_detail_cnt].oe_field_id = osd.oe_field_id,
           temp_order_sentence_detail->os_detail[os_detail_cnt].oe_field_display_value = osd
           .oe_field_display_value, temp_order_sentence_detail->os_detail[os_detail_cnt].
           oe_field_meaning_id = osd.oe_field_meaning_id, temp_order_sentence_detail->os_detail[
           os_detail_cnt].field_type_flag = osd.field_type_flag,
           temp_order_sentence_detail->os_detail[os_detail_cnt].default_parent_entity_name = osd
           .default_parent_entity_name, temp_order_sentence_detail->os_detail[os_detail_cnt].
           default_parent_entity_id = osd.default_parent_entity_id, temp_order_sentence_detail->
           os_detail[os_detail_cnt].updt_dt_tm = osd.updt_dt_tm,
           temp_order_sentence_detail->os_detail[os_detail_cnt].updt_id = osd.updt_id,
           temp_order_sentence_detail->os_detail[os_detail_cnt].updt_task = osd.updt_task,
           temp_order_sentence_detail->os_detail[os_detail_cnt].updt_cnt = osd.updt_cnt,
           temp_order_sentence_detail->os_detail[os_detail_cnt].updt_applctx = osd.updt_applctx
          WITH nocounter
         ;end select
        ENDIF
        SELECT INTO "nl:"
         FROM order_sentence os
         WHERE (os.order_sentence_id=request->order_sets[x].component_synonyms[y].sentence_id)
         DETAIL
          temp_order_sentence->order_sentence_id = os.order_sentence_id, temp_order_sentence->
          order_sentence_display_line = os.order_sentence_display_line, temp_order_sentence->
          oe_format_id = os.oe_format_id,
          temp_order_sentence->usage_flag = os.usage_flag, temp_order_sentence->order_encntr_group_cd
           = os.order_encntr_group_cd, temp_order_sentence->ord_comment_long_text_id = os
          .ord_comment_long_text_id,
          temp_order_sentence->parent_entity_id = os.parent_entity_id, temp_order_sentence->
          parent_entity_name = os.parent_entity_name, temp_order_sentence->parent_entity2_id = os
          .parent_entity2_id,
          temp_order_sentence->parent_entity2_name = os.parent_entity2_name, temp_order_sentence->
          ic_auto_verify_flag = os.ic_auto_verify_flag, temp_order_sentence->discern_auto_verify_flag
           = os.discern_auto_verify_flag,
          temp_order_sentence->external_identifier = os.external_identifier, temp_order_sentence->
          updt_applctx = os.updt_applctx, temp_order_sentence->updt_cnt = os.updt_cnt,
          temp_order_sentence->updt_dt_tm = os.updt_dt_tm, temp_order_sentence->updt_task = os
          .updt_task
         WITH nocounter
        ;end select
        DECLARE new_comment_id = f8
        SET lt_id = 0.0
        SET new_comment_id = 0.0
        SELECT INTO "nl:"
         FROM order_sentence os
         WHERE (os.order_sentence_id=request->order_sets[x].component_synonyms[y].sentence_id)
          AND os.ord_comment_long_text_id > 0
         DETAIL
          lt_id = os.ord_comment_long_text_id
         WITH nocounter
        ;end select
        IF (lt_id > 0)
         SELECT INTO "NL:"
          j = seq(long_data_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_comment_id = cnvtreal(j)
          WITH format, counter
         ;end select
         CALL buildlongtextidparser(lt_id,long_text_cnt)
         SET long_txt = ""
         SELECT INTO "nl:"
          FROM long_text lt2
          WHERE lt2.long_text_id=lt_id
          DETAIL
           long_txt = lt2.long_text
          WITH nocounter
         ;end select
         IF (curqual=0)
          CALL bederror(concat("Unable to retrieve long_text_id: ",trim(cnvtstring(lt_id)),
            " when copying order_sentence ID: ",trim(cnvtstring(request->order_sets[x].
              component_synonyms[y].sentence_id))," to synonym_id: ",
            trim(cnvtstring(request->order_sets[x].component_synonyms[y].synonym_id)),
            " in the long_text table."))
         ENDIF
         CALL bederrorcheck("LONG_TEXT del error (1)")
         INSERT  FROM long_text lt
          SET lt.long_text_id = new_comment_id, lt.active_ind = 1, lt.active_status_cd =
           active_status_code_value,
           lt.active_status_dt_tm = cnvtdatetime(curdate,curtime), lt.active_status_prsnl_id =
           reqinfo->updt_id, lt.parent_entity_id = new_order_sentence_id,
           lt.parent_entity_name = "ORDER_SENTENCE", lt.long_text = long_txt, lt.updt_applctx =
           reqinfo->updt_applctx,
           lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt.updt_id = reqinfo->
           updt_id,
           lt.updt_task = reqinfo->updt_task
          WITH nocounter
         ;end insert
         CALL bederrorcheck("LONG_TEXT ins error (1)")
         SET new_note_cnt = (size(temp_new_note_ids->new_note,5)+ 1)
         SET stat = alterlist(temp_new_note_ids->new_note,new_note_cnt)
         SET temp_new_note_ids->new_note[new_note_cnt].new_note_id = new_comment_id
        ENDIF
        INSERT  FROM order_sentence os
         SET os.order_sentence_id = new_order_sentence_id, os.order_sentence_display_line =
          temp_order_sentence->order_sentence_display_line, os.oe_format_id = temp_order_sentence->
          oe_format_id,
          os.usage_flag = temp_order_sentence->usage_flag, os.order_encntr_group_cd =
          temp_order_sentence->order_encntr_group_cd, os.ord_comment_long_text_id = new_comment_id,
          os.parent_entity_id = request->order_sets[x].component_synonyms[y].synonym_id, os
          .parent_entity_name = "ORDER_CATALOG_SYNONYM", os.parent_entity2_id = request->order_sets[x
          ].code_value,
          os.parent_entity2_name = "ORDER_CATALOG", os.ic_auto_verify_flag = temp_order_sentence->
          ic_auto_verify_flag, os.discern_auto_verify_flag = temp_order_sentence->
          discern_auto_verify_flag,
          os.external_identifier = null, os.updt_applctx = reqinfo->updt_applctx, os.updt_cnt = 0,
          os.updt_dt_tm = cnvtdatetime(curdate,curtime), os.updt_id = reqinfo->updt_id, os.updt_task
           = reqinfo->updt_task
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ORDER_SENTENCE ins error")
        IF (osd_ind=1)
         FOR (osd = 1 TO size(temp_order_sentence_detail->os_detail,5))
          INSERT  FROM order_sentence_detail osd
           SET osd.order_sentence_id = new_order_sentence_id, osd.sequence =
            temp_order_sentence_detail->os_detail[osd].sequence, osd.oe_field_value =
            temp_order_sentence_detail->os_detail[osd].oe_field_value,
            osd.oe_field_id = temp_order_sentence_detail->os_detail[osd].oe_field_id, osd
            .oe_field_display_value = temp_order_sentence_detail->os_detail[osd].
            oe_field_display_value, osd.oe_field_meaning_id = temp_order_sentence_detail->os_detail[
            osd].oe_field_meaning_id,
            osd.field_type_flag = temp_order_sentence_detail->os_detail[osd].field_type_flag, osd
            .default_parent_entity_name = temp_order_sentence_detail->os_detail[osd].
            default_parent_entity_name, osd.default_parent_entity_id = temp_order_sentence_detail->
            os_detail[osd].default_parent_entity_id,
            osd.updt_dt_tm = cnvtdatetime(curdate,curtime), osd.updt_id = reqinfo->updt_id, osd
            .updt_task = reqinfo->updt_task,
            osd.updt_cnt = 0, osd.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          CALL bederrorcheck("OS_DETAIL ins error")
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
      INSERT  FROM cs_component cc
       SET cc.catalog_cd = request->order_sets[x].code_value, cc.comp_seq = request->order_sets[x].
        component_synonyms[y].sequence, cc.comp_type_cd = cs_orderable_code_value,
        cc.comp_id = request->order_sets[x].component_synonyms[y].synonym_id, cc.long_text_id = 0, cc
        .required_ind = request->order_sets[x].component_synonyms[y].required_ind,
        cc.include_exclude_ind = request->order_sets[x].component_synonyms[y].include_exclude_ind, cc
        .comp_label = " ", cc.order_sentence_id = new_order_sentence_id,
        cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
        cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
        cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
        cc.comp_mask = null, cc.comp_reference = trim(request->order_sets[x].component_synonyms[y].
         comp_reference), cc.lockdown_details_flag = 0,
        cc.av_optional_ingredient_ind = 0, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
        cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task
         = reqinfo->updt_task
       WITH nocounter
      ;end insert
      CALL bederrorcheck("CS_COMPONENT ins error")
     ENDIF
   ENDFOR
   SET del_size = size(sent_to_delete->order_sentence,5)
   SET k1 = 0
   SET k2 = 0
   IF (del_size > 0)
    DELETE  FROM order_sentence_detail osd
     PLAN (osd
      WHERE expand(k1,1,del_size,osd.order_sentence_id,sent_to_delete->order_sentence[k1].
       order_sentence_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("OS_DETAIL del error")
    DELETE  FROM order_sentence os
     PLAN (os
      WHERE expand(k2,1,del_size,os.order_sentence_id,sent_to_delete->order_sentence[k2].
       order_sentence_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("ORDER_SENTENCE del error")
   ENDIF
   IF (long_text_cnt > 0)
    SET long_text_parser = replace(long_text_parser,",","",2)
    SET long_text_parser = build(long_text_parser,")")
    DELETE  FROM long_text lt
     WHERE parser(long_text_parser)
    ;end delete
    CALL bederrorcheck("FREE_TEXT del error")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildlongtextidparser(lt_id,long_text_cnt)
   IF (long_text_cnt > 999)
    SET long_text_parser = replace(long_text_parser,",","",2)
    SET long_text_parser = build(long_text_parser,") or lt.long_text_id IN (")
    SET long_text_cnt = 0
   ENDIF
   SET long_text_parser = build(long_text_parser,lt_id,",")
   SET long_text_cnt = (long_text_cnt+ 1)
 END ;Subroutine
 SUBROUTINE deletetheninsertnotes(x)
   SELECT INTO "nl:"
    FROM cs_component cc
    PLAN (cc
     WHERE (cc.catalog_cd=request->order_sets[x].code_value)
      AND cc.long_text_id > 0)
    HEAD REPORT
     list_cnt = 0, tot_cnt = size(temp_note->notes,5), stat = alterlist(temp_note->notes,(tot_cnt+ 10
      ))
    DETAIL
     list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (list_cnt > 10)
      stat = alterlist(temp_note->notes,(tot_cnt+ 10)), list_cnt = 1
     ENDIF
     temp_note->notes[tot_cnt].note_id = cc.long_text_id
    FOOT REPORT
     stat = alterlist(temp_note->notes,tot_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("CS_COMPONENT sel error (2)")
   DECLARE del_note_cnt = i4
   SET del_note_cnt = size(temp_note->notes,5)
   FOR (y = 1 TO del_note_cnt)
     SET contains = 0
     SET contains = locateval(i,1,size(temp_new_note_ids->new_note,5),temp_note->notes[y].note_id,
      temp_new_note_ids->new_note[i].new_note)
     IF (contains=0)
      DELETE  FROM long_text lt
       WHERE (lt.long_text_id=temp_note->notes[y].note_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck(concat("Unable to delete note with id: ",trim(cnvtstring(temp_note->notes[x]
          .note_id))))
     ENDIF
   ENDFOR
   CALL bederrorcheck("LONG_TEXT del error (2)")
   DECLARE req_note_cnt = i4
   FREE SET lt
   RECORD lt(
     1 lt_id[*]
       2 id = f8
   )
   SET req_note_cnt = size(request->order_sets[x].notes,5)
   SET stat = alterlist(lt->lt_id,req_note_cnt)
   IF (req_note_cnt > 0)
    FOR (y = 1 TO req_note_cnt)
      CALL echo("IN IF INSERT NOTES")
      SET new_lt_id = 0.0
      SELECT INTO "NL:"
       j = seq(long_data_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_lt_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET lt->lt_id[y].id = new_lt_id
    ENDFOR
    CALL echorecord(lt)
    INSERT  FROM long_text lt,
      (dummyt d  WITH seq = req_note_cnt)
     SET lt.long_text_id = lt->lt_id[d.seq].id, lt.active_ind = 1, lt.active_status_cd =
      active_status_code_value,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.parent_entity_id = request->order_sets[x].code_value,
      lt.parent_entity_name = "CS_COMPONENT", lt.long_text = request->order_sets[x].notes[d.seq].text,
      lt.updt_applctx = reqinfo->updt_applctx,
      lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (lt)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("LONG_TEXT ins error (2)")
    INSERT  FROM cs_component cc,
      (dummyt dt  WITH seq = req_note_cnt)
     SET cc.catalog_cd = request->order_sets[x].code_value, cc.comp_seq = request->order_sets[x].
      notes[dt.seq].sequence, cc.comp_type_cd = cs_note_code_value,
      cc.comp_id = 0, cc.long_text_id = lt->lt_id[dt.seq].id, cc.required_ind = 0,
      cc.include_exclude_ind = 0, cc.comp_label = " ", cc.order_sentence_id = 0,
      cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
      cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
      cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
      cc.comp_mask = null, cc.comp_reference = trim(request->order_sets[x].notes[dt.seq].
       comp_reference), cc.lockdown_details_flag = 0,
      cc.av_optional_ingredient_ind = 0, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
      cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
      reqinfo->updt_task
     PLAN (dt)
      JOIN (cc)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("CS_COMPONENT ins notes error ")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertsections(x)
   DECLARE req_section_cnt = i4
   SET req_section_cnt = size(request->order_sets[x].sections,5)
   IF (req_section_cnt > 0)
    INSERT  FROM cs_component cc,
      (dummyt d  WITH seq = value(req_section_cnt))
     SET cc.catalog_cd = request->order_sets[x].code_value, cc.comp_seq = request->order_sets[x].
      sections[d.seq].sequence, cc.comp_type_cd = cs_label_code_value,
      cc.comp_id = 0, cc.long_text_id = 0, cc.required_ind = 0,
      cc.include_exclude_ind = 0, cc.comp_label = trim(request->order_sets[x].sections[d.seq].name),
      cc.order_sentence_id = 0,
      cc.linked_date_comp_seq = 0, cc.variance_format_id = 0, cc.parent_comp_seq = null,
      cc.cp_row_cat_cd = 0, cc.cp_col_cat_cd = 0, cc.outcome_par_comp_seq = null,
      cc.comp_type_mean = null, cc.index_type_cd = 0, cc.ord_com_template_long_text_id = 0,
      cc.comp_mask = null, cc.comp_reference = trim(request->order_sets[x].sections[d.seq].
       comp_reference), cc.lockdown_details_flag = 0,
      cc.av_optional_ingredient_ind = 0, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0,
      cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
      reqinfo->updt_task
     PLAN (d)
      JOIN (cc)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("CS_COMPONENT ins error (1)")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertnewcaresetcomponents(x,z)
   SET new_bill_id = 0.0
   SET cs_comp_cd = 0
   SET cs_comp_mnemonic = ""
   SET cs_comp_owner_cd = 0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE (ocs.synonym_id=request->order_sets[x].component_synonyms[z].synonym_id)
    DETAIL
     cs_comp_mnemonic = ocs.mnemonic, cs_comp_cd = ocs.catalog_cd, cs_comp_owner_cd = ocs
     .activity_type_cd
    WITH nocounter
   ;end select
   SET sequence = request->order_sets[x].component_synonyms[z].sequence
   SET bill_id = 0.0
   SET bill_ind = 0
   SET existing_bi_seq = 0
   SET existing_bi_active_ind = 0
   SELECT INTO "nl:"
    FROM bill_item b
    PLAN (b
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
      AND b.ext_child_reference_id=cs_comp_cd)
    ORDER BY b.child_seq
    DETAIL
     IF (bill_ind=0)
      bill_id = b.bill_item_id, bill_ind = 1
     ENDIF
     existing_bi_seq = b.child_seq, existing_bi_active_ind = b.active_ind
    WITH nocounter
   ;end select
   IF (bill_id > 0.0)
    IF ((same_or_cd_val->cs_entry[z].cs_cd_val > 0))
     UPDATE  FROM bill_item b
      SET b.active_ind = 1, b.ext_description = trim(same_or_cd_val->cs_entry[z].cs_mnem), b
       .ext_owner_cd = cs_comp_owner_cd,
       b.ext_short_desc = trim(substring(1,50,same_or_cd_val->cs_entry[z].cs_mnem)), b
       .active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
       .updt_applctx = reqinfo->updt_applctx,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
      WHERE b.bill_item_id=bill_id
      WITH nocounter
     ;end update
     CALL bederrorcheck("BILL_ITEM upd error (5) in insertNewCareSetComponents")
    ENDIF
   ELSEIF (bill_id=0)
    SET new_bill_id = 0.0
    SELECT INTO "NL:"
     j = seq(bill_item_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_bill_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM bill_item b
     SET b.bill_item_id = new_bill_id, b.ext_parent_reference_id = request->order_sets[x].code_value,
      b.ext_parent_contributor_cd = ord_code_value,
      b.ext_child_reference_id = cs_comp_cd, b.ext_child_contributor_cd = ord_code_value, b
      .ext_description = trim(cs_comp_mnemonic),
      b.ext_owner_cd = cs_comp_owner_cd, b.parent_qual_cd = 1, b.charge_point_cd = 0,
      b.physician_qual_cd = 0, b.calc_type_cd = 0, b.active_ind = 1,
      b.ext_short_desc = trim(substring(1,50,cs_comp_mnemonic)), b.ext_parent_entity_name =
      "CODE_VALUE", b.ext_child_entity_name = "CODE_VALUE",
      b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
      b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
      b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
      b.tax_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = 0, b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id,
      b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
      b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100")
     WITH nocounter
    ;end insert
    CALL bederrorcheck("BILL_ITEM ins error (4) in insertNewCareSetComponents")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatecaresetcomponent(x,z)
   SET cs_comp_cd = 0
   SET cs_comp_mnemonic = ""
   SET cs_comp_owner_cd = 0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE (ocs.synonym_id=request->order_sets[x].component_synonyms[z].synonym_id))
    DETAIL
     cs_comp_cd = ocs.catalog_cd, cs_comp_mnemonic = ocs.mnemonic, cs_comp_owner_cd = ocs
     .activity_type_cd
    WITH nocounter
   ;end select
   SET sequence = request->order_sets[x].component_synonyms[z].sequence
   IF ((request->order_sets[x].component_synonyms[z].action_flag=3))
    UPDATE  FROM order_catalog oc
     SET oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
       = reqinfo->updt_task,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ORDER_CATALOG upd error in updateCareSetComponent in delete scenario")
    UPDATE  FROM bill_item b
     SET b.active_ind = 0, b.active_status_cd = inactive_status_code_value, b.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->
      updt_task,
      b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
      AND b.ext_child_reference_id=cs_comp_cd
     WITH nocounter
    ;end update
    UPDATE  FROM bill_item b
     SET b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->updt_applctx, b
      .updt_cnt = (b.updt_cnt+ 1),
      b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
      AND b.ext_child_reference_id=0
     WITH nocounter
    ;end update
    CALL bederrorcheck("BILL_ITEM upd error in updateCareSetComponent for delete")
   ELSE
    UPDATE  FROM cs_component cc
     SET cc.comp_seq = request->order_sets[x].component_synonyms[z].sequence, cc.comp_type_cd =
      cs_orderable_code_value, cc.required_ind = request->order_sets[x].component_synonyms[z].
      required_ind,
      cc.comp_id = request->order_sets[x].component_synonyms[z].synonym_id, cc.include_exclude_ind =
      request->order_sets[x].component_synonyms[z].include_exclude_ind, cc.comp_reference = trim(
       request->order_sets[x].component_synonyms[z].comp_reference),
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = (cc.updt_cnt+ 1), cc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cc.updt_id = reqinfo->updt_id, cc.updt_task = reqinfo->updt_task
     WHERE (cc.catalog_cd=request->order_sets[x].code_value)
      AND (cc.comp_seq=request->order_sets[x].component_synonyms[z].sequence)
     WITH nocounter
    ;end update
    CALL bederrorcheck("CS_COMPONENT update error in updateCareSetComponent")
    UPDATE  FROM order_catalog oc
     SET oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task
       = reqinfo->updt_task,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->updt_applctx
     WHERE (oc.catalog_cd=request->order_sets[x].code_value)
     WITH nocounter
    ;end update
    CALL bederrorcheck("ORDER_CATALOG upd error in updateCareSetComponent")
    UPDATE  FROM bill_item b
     SET b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_applctx = reqinfo->updt_applctx, b
      .updt_cnt = (b.updt_cnt+ 1),
      b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
     WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
      AND b.ext_child_reference_id=cs_comp_cd
     WITH nocounter
    ;end update
    CALL bederrorcheck("BILL_ITEM upd error in updateCareSetComponent")
    SET bill_id = 0.0
    SELECT INTO "nl:"
     FROM bill_item b
     PLAN (b
      WHERE (b.ext_parent_reference_id=request->order_sets[x].code_value)
       AND b.ext_child_reference_id=cs_comp_cd)
     DETAIL
      bill_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (bill_id > 0.0)
     IF ((same_or_cd_val->cs_entry[z].cs_cd_val > 0))
      UPDATE  FROM bill_item b
       SET b.active_ind = 1, b.ext_description = trim(same_or_cd_val->cs_entry[z].cs_mnem), b
        .ext_owner_cd = cs_comp_owner_cd,
        b.ext_short_desc = trim(substring(1,50,same_or_cd_val->cs_entry[z].cs_mnem)), b
        .active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3),
        b.active_status_prsnl_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_applctx = reqinfo->updt_applctx,
        b.updt_cnt = (b.updt_cnt+ 1), b.updt_task = reqinfo->updt_task, b.updt_id = reqinfo->updt_id
       PLAN (b
        WHERE b.bill_item_id=bill_id)
       WITH nocounter
      ;end update
      CALL bederrorcheck("BILL_ITEM upd error (5) in insertNewCareSetComponents")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
