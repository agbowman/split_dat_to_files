CREATE PROGRAM bed_ens_mltm_replace_syns:dba
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
 RECORD temp_request(
   1 synonyms[*]
     2 synonym_id = f8
     2 replacement_synonym_id = f8
     2 caresets[*]
       3 careset_id = f8
       3 action_flag = i2
     2 favorite_folders[*]
       3 favorite_folder_id = f8
       3 action_flag = i2
     2 iv_sets[*]
       3 item_id = f8
       3 action_flag = i2
     2 order_folders[*]
       3 order_folder_id = f8
       3 action_flag = i2
     2 power_plans[*]
       3 power_plan_id = f8
       3 action_flag = i2
     2 products[*]
       3 item_id = f8
       3 action_flag = i2
 ) WITH protect
 RECORD ord_sent_to_remove(
   1 order_sentences[*]
     2 order_sentence_id = f8
 ) WITH protect
 RECORD ref_request(
   1 synonyms[*]
     2 synonym_id = f8
 ) WITH protect
 RECORD ref_reply(
   1 synonyms[*]
     2 synonym_id = f8
     2 caresets[*]
       3 careset_id = f8
       3 display = vc
     2 favorite_folders[*]
       3 favorite_folder_id = f8
       3 display = vc
     2 iv_sets[*]
       3 item_id = f8
       3 display = vc
     2 order_folders[*]
       3 order_folder_id = f8
       3 display = vc
     2 power_plans[*]
       3 power_plan_id = f8
       3 display = vc
     2 products[*]
       3 item_id = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE synonym_table_name = vc WITH protect, constant("ORDER_CATALOG_SYNONYM")
 DECLARE iv_set_med_type = i2 WITH protect, constant(3)
 DECLARE product_med_type = i2 WITH protect, constant(0)
 DECLARE synonym_count = i4 WITH protect, constant(size(request->synonyms,5))
 DECLARE care_set_count = i4 WITH protect, noconstant(0)
 DECLARE fav_folder_count = i4 WITH protect, noconstant(0)
 DECLARE ord_folder_count = i4 WITH protect, noconstant(0)
 DECLARE power_plan_count = i4 WITH protect, noconstant(0)
 DECLARE iv_count = i4 WITH protect, noconstant(0)
 DECLARE product_count = i4 WITH protect, noconstant(0)
 DECLARE order_sentence_count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE reference_reply_size = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
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
 SET stat = alterlist(temp_request->synonyms,synonym_count)
 SET stat = alterlist(ref_request->synonyms,synonym_count)
 FOR (x = 1 TO synonym_count)
   SET temp_request->synonyms[x].synonym_id = request->synonyms[x].synonym_id
   SET temp_request->synonyms[x].replacement_synonym_id = request->synonyms[x].replacement_synonym_id
   SET ref_request->synonyms[x].synonym_id = request->synonyms[x].synonym_id
 ENDFOR
 EXECUTE bed_get_synonym_references  WITH replace("REQUEST",ref_request), replace("REPLY",ref_reply)
 IF ((ref_reply->status="F"))
  CALL bederror("ERROR 001: Error getting synonym references from bed_get_synonym_references.prg")
 ENDIF
 SET reference_reply_size = size(ref_reply->synonyms,5)
 FOR (x = 1 TO reference_reply_size)
   SET index = locateval(index2,1,reference_reply_size,ref_reply->synonyms[x].synonym_id,temp_request
    ->synonyms[index2].synonym_id)
   SET care_set_count = size(ref_reply->synonyms[x].caresets,5)
   SET fav_folder_count = size(ref_reply->synonyms[x].favorite_folders,5)
   SET ord_folder_count = size(ref_reply->synonyms[x].order_folders,5)
   SET power_plan_count = size(ref_reply->synonyms[x].power_plans,5)
   SET iv_count = size(ref_reply->synonyms[x].iv_sets,5)
   SET product_count = size(ref_reply->synonyms[x].products,5)
   IF (care_set_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].caresets,care_set_count)
    FOR (y = 1 TO care_set_count)
     SET temp_request->synonyms[index].caresets[y].careset_id = ref_reply->synonyms[x].caresets[y].
     careset_id
     SET temp_request->synonyms[index].caresets[y].action_flag = 2
    ENDFOR
   ENDIF
   IF (fav_folder_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].favorite_folders,fav_folder_count)
    FOR (y = 1 TO fav_folder_count)
     SET temp_request->synonyms[index].favorite_folders[y].favorite_folder_id = ref_reply->synonyms[x
     ].favorite_folders[y].favorite_folder_id
     SET temp_request->synonyms[index].favorite_folders[y].action_flag = 0
    ENDFOR
   ENDIF
   IF (ord_folder_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].order_folders,ord_folder_count)
    FOR (y = 1 TO ord_folder_count)
     SET temp_request->synonyms[index].order_folders[y].order_folder_id = ref_reply->synonyms[x].
     order_folders[y].order_folder_id
     SET temp_request->synonyms[index].order_folders[y].action_flag = 0
    ENDFOR
   ENDIF
   IF (power_plan_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].power_plans,power_plan_count)
    FOR (y = 1 TO power_plan_count)
     SET temp_request->synonyms[index].power_plans[y].power_plan_id = ref_reply->synonyms[x].
     power_plans[y].power_plan_id
     SET temp_request->synonyms[index].power_plans[y].action_flag = 2
    ENDFOR
   ENDIF
   IF (iv_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].iv_sets,iv_count)
    FOR (y = 1 TO iv_count)
     SET temp_request->synonyms[index].iv_sets[y].item_id = ref_reply->synonyms[x].iv_sets[y].item_id
     SET temp_request->synonyms[index].iv_sets[y].action_flag = 2
    ENDFOR
   ENDIF
   IF (product_count > 0)
    SET stat = alterlist(temp_request->synonyms[index].products,product_count)
    FOR (y = 1 TO product_count)
     SET temp_request->synonyms[index].products[y].item_id = ref_reply->synonyms[x].products[y].
     item_id
     SET temp_request->synonyms[index].products[y].action_flag = 2
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO synonym_count)
   SET care_set_count = size(temp_request->synonyms[x].caresets,5)
   IF (care_set_count > 0)
    SET index = 1
    SELECT INTO "nl:"
     FROM cs_component cs
     PLAN (cs
      WHERE (cs.comp_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,care_set_count,cs.catalog_cd,ref_reply->synonyms[x].caresets[index].
       careset_id)
       AND cs.order_sentence_id > 0.0)
     DETAIL
      order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
       order_sentences,order_sentence_count), ord_sent_to_remove->order_sentences[
      order_sentence_count].order_sentence_id = cs.order_sentence_id
     WITH nocounter, expand = value(bedgetexpandind(care_set_count))
    ;end select
    CALL bederrorcheck("ERROR 002: Issue getting care set order sentences.")
    SET index = 1
    SET index2 = 1
    UPDATE  FROM cs_component cs
     SET cs.comp_id = temp_request->synonyms[x].replacement_synonym_id, cs.order_sentence_id = 0, cs
      .updt_applctx = reqinfo->updt_applctx,
      cs.updt_cnt = (cs.updt_cnt+ 1), cs.updt_dt_tm = cnvtdatetime(curdate,curtime3), cs.updt_id =
      reqinfo->updt_id,
      cs.updt_task = reqinfo->updt_task
     PLAN (cs
      WHERE (cs.comp_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,care_set_count,cs.catalog_cd,ref_reply->synonyms[x].caresets[index].
       careset_id))
     WITH nocounter, expand = value(bedgetexpandind(care_set_count))
    ;end update
    CALL bederrorcheck("ERROR 003: Issue replacing care sets.")
   ENDIF
   SET fav_folder_count = size(temp_request->synonyms[x].favorite_folders,5)
   IF (fav_folder_count > 0)
    SET index = 1
    SET index2 = 0
    SELECT INTO "nl:"
     FROM alt_sel_list aslist,
      alt_sel_cat ascat
     PLAN (aslist
      WHERE (aslist.synonym_id=temp_request->synonyms[x].synonym_id))
      JOIN (ascat
      WHERE expand(index,1,fav_folder_count,ascat.alt_sel_category_id,temp_request->synonyms[x].
       favorite_folders[index].favorite_folder_id)
       AND ascat.ahfs_ind IN (0, null))
     DETAIL
      IF (index2 < fav_folder_count)
       index2 = (index2+ 1), temp_request->synonyms[x].favorite_folders[index2].action_flag = 2
      ENDIF
      IF (aslist.order_sentence_id > 0.0)
       order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
        order_sentences,order_sentence_count), ord_sent_to_remove->order_sentences[
       order_sentence_count].order_sentence_id = aslist.order_sentence_id
      ENDIF
     WITH nocounter, expand = value(bedgetexpandind(fav_folder_count))
    ;end select
    CALL bederrorcheck("ERROR 004: Issue getting favorite folders action flags.")
    SET index = 1
    SET index2 = 1
    UPDATE  FROM alt_sel_list aslist
     SET aslist.synonym_id = temp_request->synonyms[x].replacement_synonym_id, aslist
      .order_sentence_id = 0, aslist.updt_applctx = reqinfo->updt_applctx,
      aslist.updt_cnt = (aslist.updt_cnt+ 1), aslist.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      aslist.updt_id = reqinfo->updt_id,
      aslist.updt_task = reqinfo->updt_task
     PLAN (aslist
      WHERE (aslist.synonym_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,fav_folder_count,aslist.alt_sel_category_id,temp_request->synonyms[x].
       favorite_folders[index].favorite_folder_id)
       AND expand(index2,1,fav_folder_count,2,temp_request->synonyms[x].favorite_folders[index2].
       action_flag))
     WITH nocounter, expand = value(bedgetexpandind(fav_folder_count))
    ;end update
    CALL bederrorcheck("ERROR 005: Issue replacing favorite folders.")
   ENDIF
   SET ord_folder_count = size(temp_request->synonyms[x].order_folders,5)
   IF (ord_folder_count > 0)
    SET index = 1
    SET index2 = 0
    SELECT INTO "nl:"
     FROM alt_sel_list aslist,
      alt_sel_cat ascat
     PLAN (aslist
      WHERE (aslist.synonym_id=temp_request->synonyms[x].synonym_id))
      JOIN (ascat
      WHERE expand(index,1,ord_folder_count,ascat.alt_sel_category_id,temp_request->synonyms[x].
       order_folders[index].order_folder_id)
       AND ascat.ahfs_ind IN (0, null))
     DETAIL
      IF (index2 < ord_folder_count)
       index2 = (index2+ 1), temp_request->synonyms[x].order_folders[index2].action_flag = 2
      ENDIF
      IF (aslist.order_sentence_id > 0.0)
       order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
        order_sentences,order_sentence_count), ord_sent_to_remove->order_sentences[
       order_sentence_count].order_sentence_id = aslist.order_sentence_id
      ENDIF
     WITH nocounter, expand = value(bedgetexpandind(ord_folder_count))
    ;end select
    CALL bederrorcheck("ERROR 006: Issue getting order folders action flags.")
    SET index = 1
    SET index2 = 1
    UPDATE  FROM alt_sel_list aslist
     SET aslist.synonym_id = temp_request->synonyms[x].replacement_synonym_id, aslist
      .order_sentence_id = 0, aslist.updt_applctx = reqinfo->updt_applctx,
      aslist.updt_cnt = (aslist.updt_cnt+ 1), aslist.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      aslist.updt_id = reqinfo->updt_id,
      aslist.updt_task = reqinfo->updt_task
     PLAN (aslist
      WHERE (aslist.synonym_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,ord_folder_count,aslist.alt_sel_category_id,temp_request->synonyms[x].
       order_folders[index].order_folder_id)
       AND expand(index2,1,ord_folder_count,2,temp_request->synonyms[x].order_folders[index2].
       action_flag))
     WITH nocounter, expand = value(bedgetexpandind(ord_folder_count))
    ;end update
    CALL bederrorcheck("ERROR 007: Issue replacing order folders.")
   ENDIF
   SET power_plan_count = size(temp_request->synonyms[x].power_plans,5)
   IF (power_plan_count > 0)
    SET index = 1
    SELECT INTO "nl:"
     FROM pathway_comp pco,
      pw_comp_os_reltn pcor
     PLAN (pco
      WHERE (pco.parent_entity_id=temp_request->synonyms[x].synonym_id)
       AND pco.parent_entity_name=synonym_table_name
       AND expand(index,1,power_plan_count,pco.pathway_catalog_id,temp_request->synonyms[x].
       power_plans[index].power_plan_id))
      JOIN (pcor
      WHERE pcor.pathway_comp_id=pco.pathway_comp_id)
     DETAIL
      IF (pcor.order_sentence_id > 0.0)
       order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
        order_sentences,order_sentence_count), ord_sent_to_remove->order_sentences[
       order_sentence_count].order_sentence_id = pcor.order_sentence_id
      ENDIF
     WITH nocounter, expand = value(bedgetexpandind(power_plan_count))
    ;end select
    CALL bederrorcheck("ERROR 008: Issue getting order sentences to remove.")
    SET index = 1
    DELETE  FROM pw_comp_os_reltn pcor
     PLAN (pcor
      WHERE expand(index,1,order_sentence_count,pcor.order_sentence_id,ord_sent_to_remove->
       order_sentences[index].order_sentence_id)
       AND pcor.order_sentence_id > 0.0)
     WITH noconter, expand = value(bedgetexpandind(order_sentence_count))
    ;end delete
    CALL bederrorcheck("ERROR 009: Issue removing order sentences from a power plan component.")
    SET index = 1
    UPDATE  FROM pathway_comp pco
     SET pco.parent_entity_id = temp_request->synonyms[x].replacement_synonym_id,
      order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
       order_sentences,order_sentence_count),
      ord_sent_to_remove->order_sentences[order_sentence_count].order_sentence_id = pco
      .order_sentence_id, pco.order_sentence_id = 0, pco.updt_applctx = reqinfo->updt_applctx,
      pco.updt_cnt = (pco.updt_cnt+ 1), pco.updt_dt_tm = cnvtdatetime(curdate,curtime3), pco.updt_id
       = reqinfo->updt_id,
      pco.updt_task = reqinfo->updt_task
     PLAN (pco
      WHERE (pco.parent_entity_id=temp_request->synonyms[x].synonym_id)
       AND pco.parent_entity_name=synonym_table_name
       AND expand(index,1,power_plan_count,pco.pathway_catalog_id,temp_request->synonyms[x].
       power_plans[index].power_plan_id))
     WITH nocounter, expand = value(bedgetexpandind(power_plan_count))
    ;end update
    CALL bederrorcheck("ERROR 010: Issue replacing power plans.")
   ENDIF
   SET iv_count = size(temp_request->synonyms[x].iv_sets,5)
   IF (iv_count > 0)
    SET index = 1
    SELECT INTO "nl:"
     FROM cs_component cs
     PLAN (cs
      WHERE (cs.comp_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,iv_count,cs.catalog_cd,temp_request->synonyms[x].iv_sets[index].item_id)
       AND cs.order_sentence_id > 0.0)
     DETAIL
      order_sentence_count = (order_sentence_count+ 1), stat = alterlist(ord_sent_to_remove->
       order_sentences,order_sentence_count), ord_sent_to_remove->order_sentences[
      order_sentence_count].order_sentence_id = cs.order_sentence_id
     WITH nocounter, expand = value(bedgetexpandind(iv_count))
    ;end select
    CALL bederrorcheck("ERROR 011: Issue getting iv set order sentences.")
    SET index = 1
    UPDATE  FROM cs_component cs
     SET cs.comp_id = temp_request->synonyms[x].replacement_synonym_id, cs.order_sentence_id = 0, cs
      .updt_applctx = reqinfo->updt_applctx,
      cs.updt_cnt = (cs.updt_cnt+ 1), cs.updt_dt_tm = cnvtdatetime(curdate,curtime3), cs.updt_id =
      reqinfo->updt_id,
      cs.updt_task = reqinfo->updt_task
     PLAN (cs
      WHERE (cs.comp_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,iv_count,cs.catalog_cd,temp_request->synonyms[x].iv_sets[index].item_id))
     WITH nocounter, expand = value(bedgetexpandind(iv_count))
    ;end update
    CALL bederrorcheck("ERROR 012: Issue replacing iv sets.")
   ENDIF
   SET product_count = size(temp_request->synonyms[x].products,5)
   IF (product_count > 0)
    SET index = 1
    UPDATE  FROM order_catalog_item_r ocir
     SET ocir.synonym_id = temp_request->synonyms[x].replacement_synonym_id, ocir.updt_applctx =
      reqinfo->updt_applctx, ocir.updt_cnt = (ocir.updt_cnt+ 1),
      ocir.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocir.updt_id = reqinfo->updt_id, ocir
      .updt_task = reqinfo->updt_task
     PLAN (ocir
      WHERE (ocir.synonym_id=temp_request->synonyms[x].synonym_id)
       AND expand(index,1,product_count,ocir.item_id,temp_request->synonyms[x].products[index].
       item_id))
     WITH nocounter, expand = value(bedgetexpandind(product_count))
    ;end update
    CALL bederrorcheck("ERROR 013: Issue replacing products.")
   ENDIF
   IF (order_sentence_count > 0)
    SET index = 1
    DELETE  FROM order_sentence_filter osf
     PLAN (osf
      WHERE expand(index,1,order_sentence_count,osf.order_sentence_id,ord_sent_to_remove->
       order_sentences[index].order_sentence_id)
       AND (ord_sent_to_remove->order_sentences[index].order_sentence_id > 0))
     WITH expand = value(bedgetexpandind(order_sentence_count))
    ;end delete
    CALL bederrorcheck("ERROR 014: Issue removing order sentence details.")
    SET index = 1
    DELETE  FROM order_sentence_detail osd
     PLAN (osd
      WHERE expand(index,1,order_sentence_count,osd.order_sentence_id,ord_sent_to_remove->
       order_sentences[index].order_sentence_id)
       AND (ord_sent_to_remove->order_sentences[index].order_sentence_id > 0))
     WITH expand = value(bedgetexpandind(order_sentence_count))
    ;end delete
    CALL bederrorcheck("ERROR 015: Issue removing order sentence details.")
    SET index = 1
    DELETE  FROM order_sentence os
     PLAN (os
      WHERE expand(index,1,order_sentence_count,os.order_sentence_id,ord_sent_to_remove->
       order_sentences[index].order_sentence_id)
       AND (ord_sent_to_remove->order_sentences[index].order_sentence_id > 0))
     WITH expand = value(bedgetexpandind(order_sentence_count))
    ;end delete
    CALL bederrorcheck("ERROR 016: Issue removing order sentences.")
    SET stat = alterlist(ord_sent_to_remove->order_sentences,0)
    SET order_sentence_count = 0
   ENDIF
 ENDFOR
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
