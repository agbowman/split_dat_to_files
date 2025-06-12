CREATE PROGRAM bed_get_syn_groups_with_sent:dba
 RECORD allsentences(
   1 sentences[*]
     2 sent_id = f8
     2 clin_disp_line = vc
 ) WITH protect
 RECORD pwtypemean(
   1 types[*]
     2 pw_cat_id = f8
     2 type_mean = vc
 ) WITH protect
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 list_synonym_groups[*]
      2 synonym_group_id = f8
      2 synonym_group_name = vc
      2 synonym_group_flag = i2
      2 list_synonyms[*]
        3 synonym_id = f8
        3 synonym_name = vc
        3 synonym_type_flag = i2
        3 list_sentences[*]
          4 sentence_id = f8
          4 clin_disp_line = vc
    1 too_many_results_ind = i2
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
 DECLARE usageflagparser = vc WITH protect, noconstant("")
 DECLARE actiontypecdparser = vc WITH protect, noconstant("")
 DECLARE currentvalueparser = vc WITH protect, noconstant("")
 DECLARE yesnoparser = vc WITH protect, noconstant("")
 DECLARE searchtextparser = vc WITH protect, noconstant("")
 DECLARE groupcnt = i4 WITH protect, noconstant(0)
 DECLARE numberofsentences = i4 WITH protect, noconstant(0)
 DECLARE numberofitems = i4 WITH protect, noconstant(0)
 DECLARE searchtextparserneeded = i2 WITH protect, noconstant(0)
 DECLARE searchtoplevelind = i2 WITH protect, noconstant(0)
 DECLARE searchsynonymind = i2 WITH protect, noconstant(0)
 DECLARE standalone_synonym_type = i4 WITH protect, constant(1)
 DECLARE care_set_type = i4 WITH protect, constant(2)
 DECLARE power_plan_type = i4 WITH protect, constant(3)
 DECLARE order_folder_type = i4 WITH protect, constant(4)
 DECLARE iv_set_type = i4 WITH protect, constant(5)
 DECLARE max_reply = i4 WITH protect, constant(1500)
 IF ( NOT (validate(cs6003_order_cd)))
  DECLARE cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 ENDIF
 IF ( NOT (validate(cs6003_disorder_cd)))
  DECLARE cs6003_disorder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"DISORDER"))
 ENDIF
 DECLARE constructusageflagandactiontypecodeparsers(dummyvar=i2) = i2
 DECLARE constructcurrentvalueparser(dummyvar=i2) = i2
 DECLARE constructyesnoparser(dummyvar=i2) = i2
 DECLARE constructsearchtextparser(topleveljoin=vc) = i2
 DECLARE gettotalnumberofitems(numberofitems=i4(ref)) = i2
 DECLARE checkiftoomanyitems(dummyvar=i2) = i2
 DECLARE getsentencesbyformatfieldvalue(dummyvar=i2) = i2
 DECLARE getsentencehierarchy(dummyvar=i2) = i2
 DECLARE getstandalonesynonyms(dummyvar=i2) = i2
 DECLARE getorderfolders(dummyvar=i2) = i2
 DECLARE getcaresetsorivsets(dummyvar=i2) = i2
 DECLARE getpowerplans(dummyvar=i2) = i2
 DECLARE getpathwayrulepowerplans(dummyvar=i2) = i2
 CALL bedbeginscript(0)
 CALL constructusageflagandactiontypecodeparsers(0)
 CALL constructcurrentvalueparser(0)
 CALL constructyesnoparser(0)
 CALL getsentencesbyformatfieldvalue(0)
 IF (size(trim(request->search_text,3),1) > 0)
  SET searchtextparserneeded = true
  IF ((request->search_type_flag=0))
   SET searchtoplevelind = 1
  ELSE
   SET searchsynonymind = 1
  ENDIF
 ENDIF
 IF (numberofsentences > 0)
  CALL getsentencehierarchy(0)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE constructusageflagandactiontypecodeparsers(dummyvar)
   DECLARE usageflagssize = i4 WITH protect, noconstant(0)
   SET usageflagssize = size(request->usage_flags,5)
   IF (usageflagssize=1)
    IF ((request->usage_flags[1].usage_flag=1))
     SET usageflagparser = "os.usage_flag in (0,1)"
     SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
    ELSEIF ((request->usage_flags[1].usage_flag=2))
     SET usageflagparser = "os.usage_flag = 2"
     SET actiontypecdparser = "off.action_type_cd = CS6003_DISORDER_CD"
    ELSE
     SET usageflagparser = build("os.usage_flag = ",request->usage_flags[1].usage_flag)
    ENDIF
   ELSEIF (usageflagssize=2)
    SET usageflagparser = build("os.usage_flag in (0,",request->usage_flags[1].usage_flag,",",request
     ->usage_flags[2].usage_flag,")")
    SET actiontypecdparser = "off.action_type_cd in (CS6003_ORDER_CD, CS6003_DISORDER_CD)"
   ELSE
    SET usageflagparser = "os.usage_flag >= 0"
    SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
   ENDIF
 END ;Subroutine
 SUBROUTINE constructcurrentvalueparser(dummyvar)
   IF ((request->oe_current_val_id > 0))
    SET currentvalueparser = build("osd.default_parent_entity_id = ",request->oe_current_val_id)
   ELSE
    SET currentvalueparser = build("osd.oe_field_display_value = '",request->oe_current_val_disp,"'")
   ENDIF
 END ;Subroutine
 SUBROUTINE constructyesnoparser(dummyvar)
   IF ((request->oe_current_val_id=1))
    SET yesnoparser = build("off.label_text in ('', ' ', '",request->oe_current_val_disp,"')")
   ELSE
    SET yesnoparser = build("off.dept_line_label in ('', ' ', '",request->oe_current_val_disp,"')")
   ENDIF
 END ;Subroutine
 SUBROUTINE constructsearchtextparser(topleveljoin)
  SET searchtextparser = ""
  IF (searchtextparserneeded=true)
   IF (searchtoplevelind=1)
    SET searchtextparser = topleveljoin
   ELSE
    SET searchtextparser = build("cnvtupper(ocs.mnemonic) = '")
   ENDIF
   IF ((request->search_text_flag="STARTS_WITH"))
    SET searchtextparser = build(searchtextparser,cnvtupper(trim(request->search_text,3)),"*'")
   ELSE
    SET searchtextparser = build(searchtextparser,"*",cnvtupper(trim(request->search_text,3)),"*'")
   ENDIF
  ELSE
   SET searchtextparser = "1=1"
  ENDIF
 END ;Subroutine
 SUBROUTINE gettotalnumberofitems(numberofitems)
   SET numberofitems = 0
   SET numberofitems = size(reply->list_synonym_groups,5)
   FOR (i = 1 TO size(reply->list_synonym_groups,5))
    SET numberofitems = (numberofitems+ size(reply->list_synonym_groups[i].list_synonyms,5))
    FOR (k = 1 TO size(reply->list_synonym_groups[i].list_synonyms,5))
      SET numberofitems = (numberofitems+ size(reply->list_synonym_groups[i].list_synonyms[k].
       list_sentences,5))
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE getsentencesbyformatfieldvalue(dummyvar)
   CALL bedlogmessage("getSentencesByFormatFieldValue","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE isnumericfield = i2 WITH protect, noconstant(false)
   DECLARE isyesnofield = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM order_entry_fields oef
    PLAN (oef
     WHERE (oef.oe_field_id=request->oe_field_id)
      AND oef.field_type_flag IN (1, 2))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET isnumericfield = true
   ENDIF
   SELECT INTO "nl:"
    FROM order_entry_fields oef
    PLAN (oef
     WHERE (oef.oe_field_id=request->oe_field_id)
      AND oef.field_type_flag=7)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET isyesnofield = true
   ENDIF
   IF (isnumericfield)
    SELECT INTO "nl:"
     FROM order_sentence os,
      order_sentence_detail osd
     PLAN (os
      WHERE (os.oe_format_id=request->oe_format_id)
       AND parser(usageflagparser))
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id
       AND (osd.oe_field_id=request->oe_field_id)
       AND (osd.oe_field_value=request->oe_current_val_id))
     ORDER BY os.order_sentence_id
     HEAD os.order_sentence_id
      cnt = (cnt+ 1), stat = alterlist(allsentences->sentences,cnt), allsentences->sentences[cnt].
      sent_id = os.order_sentence_id,
      allsentences->sentences[cnt].clin_disp_line = os.order_sentence_display_line
     WITH nocounter
    ;end select
   ELSEIF (isyesnofield)
    SELECT INTO "nl:"
     FROM order_sentence os,
      order_sentence_detail osd,
      oe_format_fields off
     PLAN (os
      WHERE (os.oe_format_id=request->oe_format_id)
       AND parser(usageflagparser))
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id
       AND (osd.oe_field_id=request->oe_field_id)
       AND (osd.oe_field_value=request->oe_current_val_id))
      JOIN (off
      WHERE (off.oe_format_id=request->oe_format_id)
       AND off.oe_field_id=osd.oe_field_id
       AND parser(actiontypecdparser)
       AND parser(yesnoparser))
     ORDER BY os.order_sentence_id
     HEAD os.order_sentence_id
      cnt = (cnt+ 1), stat = alterlist(allsentences->sentences,cnt), allsentences->sentences[cnt].
      sent_id = os.order_sentence_id,
      allsentences->sentences[cnt].clin_disp_line = os.order_sentence_display_line
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM order_sentence os,
      order_sentence_detail osd
     PLAN (os
      WHERE (os.oe_format_id=request->oe_format_id)
       AND parser(usageflagparser))
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id
       AND parser(currentvalueparser)
       AND (osd.oe_field_id=request->oe_field_id))
     ORDER BY os.order_sentence_id
     HEAD os.order_sentence_id
      cnt = (cnt+ 1), stat = alterlist(allsentences->sentences,cnt), allsentences->sentences[cnt].
      sent_id = os.order_sentence_id,
      allsentences->sentences[cnt].clin_disp_line = os.order_sentence_display_line
     WITH nocounter
    ;end select
   ENDIF
   SET numberofsentences = size(allsentences->sentences,5)
   CALL bederrorcheck("Failed to retrieve sentences for the given format, field and current value.")
   CALL bedlogmessage("getSentencesByFormatFieldValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE getsentencehierarchy(dummyvar)
   IF ((request->standalone_syn_ind=1))
    CALL getstandalonesynonyms(0)
   ENDIF
   CALL checkiftoomanyitems(0)
   IF ((request->order_folders_ind=1))
    CALL getorderfolders(0)
   ENDIF
   CALL checkiftoomanyitems(0)
   IF ((((request->care_set_ind=1)) OR ((request->iv_set_ind=1))) )
    CALL getcaresetsorivsets(0)
   ENDIF
   CALL checkiftoomanyitems(0)
   IF ((request->power_plan_ind=1))
    CALL getpowerplans(0)
    CALL getpathwayrulepowerplans(0)
   ENDIF
   CALL checkiftoomanyitems(0)
 END ;Subroutine
 SUBROUTINE checkiftoomanyitems(dummyvar)
  CALL gettotalnumberofitems(numberofitems)
  IF (numberofitems > max_reply)
   SET stat = alterlist(reply->list_synonym_groups,0)
   SET reply->too_many_results_ind = 1
   CALL bedexitsuccess(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE getstandalonesynonyms(dummyvar)
   CALL bedlogmessage("getStandaloneSynonyms","Entering ...")
   DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
   CALL constructsearchtextparser(build("cnvtupper(oc.description) = '"))
   SELECT
    IF (searchtoplevelind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      ord_cat_sent_r ocsr,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
       AND ((os.parent_entity2_name=null) OR (os.parent_entity2_name != "ALT_SEL_CAT"))
       AND  NOT ( EXISTS (
      (SELECT
       cc.order_sentence_id
       FROM cs_component cc
       WHERE os.order_sentence_id=cc.order_sentence_id))))
      JOIN (ocsr
      WHERE ocsr.order_sentence_id=os.order_sentence_id)
      JOIN (ocs
      WHERE ocs.synonym_id=os.parent_entity_id
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND parser(searchtextparser))
    ELSEIF (searchsynonymind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
       AND ((os.parent_entity2_name=null) OR (os.parent_entity2_name != "ALT_SEL_CAT"))
       AND  NOT ( EXISTS (
      (SELECT
       cc.order_sentence_id
       FROM cs_component cc
       WHERE os.order_sentence_id=cc.order_sentence_id))))
      JOIN (ocs
      WHERE ocs.synonym_id=os.parent_entity_id
       AND parser(searchtextparser)
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSE INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
       AND ((os.parent_entity2_name=null) OR (os.parent_entity2_name != "ALT_SEL_CAT"))
       AND  NOT ( EXISTS (
      (SELECT
       cc.order_sentence_id
       FROM cs_component cc
       WHERE os.order_sentence_id=cc.order_sentence_id))))
      JOIN (ocs
      WHERE ocs.synonym_id=os.parent_entity_id
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ENDIF
    ORDER BY oc.catalog_cd, ocs.synonym_id
    HEAD oc.catalog_cd
     groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt), reply->
     list_synonym_groups[groupcnt].synonym_group_id = oc.catalog_cd,
     reply->list_synonym_groups[groupcnt].synonym_group_name = oc.description, reply->
     list_synonym_groups[groupcnt].synonym_group_flag = standalone_synonym_type, synonym_cnt = 0
    HEAD ocs.synonym_id
     synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
     synonym_id = ocs.synonym_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic,
     sentence_cnt = 0
    DETAIL
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
     list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
     .seq].sent_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
     clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to retrieve hierarchy for standalone synonyms.")
   CALL bedlogmessage("getStandaloneSynonyms","Exiting ...")
 END ;Subroutine
 SUBROUTINE getorderfolders(dummyvar)
   CALL bedlogmessage("getOrderFolders","Entering ...")
   DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
   CALL constructsearchtextparser(build("cnvtupper(c.long_description) = '"))
   SELECT
    IF (searchtoplevelind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      alt_sel_list l,
      alt_sel_cat c,
      order_catalog_synonym ocs
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity2_name="ALT_SEL_CAT")
      JOIN (l
      WHERE l.order_sentence_id=os.order_sentence_id)
      JOIN (c
      WHERE c.alt_sel_category_id=l.alt_sel_category_id
       AND parser(searchtextparser))
      JOIN (ocs
      WHERE ocs.synonym_id=l.synonym_id)
    ELSEIF (searchsynonymind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      alt_sel_list l,
      alt_sel_cat c,
      order_catalog_synonym ocs
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity2_name="ALT_SEL_CAT")
      JOIN (l
      WHERE l.order_sentence_id=os.order_sentence_id)
      JOIN (c
      WHERE c.alt_sel_category_id=l.alt_sel_category_id)
      JOIN (ocs
      WHERE ocs.synonym_id=l.synonym_id
       AND parser(searchtextparser))
    ELSE INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      alt_sel_list l,
      alt_sel_cat c,
      order_catalog_synonym ocs
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id)
       AND os.parent_entity2_name="ALT_SEL_CAT")
      JOIN (l
      WHERE l.order_sentence_id=os.order_sentence_id)
      JOIN (c
      WHERE c.alt_sel_category_id=l.alt_sel_category_id)
      JOIN (ocs
      WHERE ocs.synonym_id=l.synonym_id)
    ENDIF
    ORDER BY l.pathway_catalog_id, l.synonym_id
    HEAD l.pathway_catalog_id
     groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt), reply->
     list_synonym_groups[groupcnt].synonym_group_id = l.pathway_catalog_id,
     reply->list_synonym_groups[groupcnt].synonym_group_name = c.long_description, reply->
     list_synonym_groups[groupcnt].synonym_group_flag = order_folder_type, synonym_cnt = 0
    HEAD l.synonym_id
     synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
     synonym_id = l.synonym_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic,
     sentence_cnt = 0
    DETAIL
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
     list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
     .seq].sent_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
     clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to retrieve hierarchy for order folders.")
   CALL bedlogmessage("getOrderFolders","Exiting ...")
 END ;Subroutine
 SUBROUTINE getcaresetsorivsets(dummyvar)
   CALL bedlogmessage("getCareSetsOrIVSets","Entering ...")
   DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
   CALL constructsearchtextparser(build("cnvtupper(oc.description) = '"))
   SELECT
    IF (searchtoplevelind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      cs_component cc,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (cc
      WHERE cc.order_sentence_id=os.order_sentence_id)
      JOIN (ocs
      WHERE ocs.synonym_id=cc.comp_id)
      JOIN (oc
      WHERE oc.catalog_cd=cc.catalog_cd
       AND parser(searchtextparser))
    ELSEIF (searchsynonymind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      cs_component cc,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (cc
      WHERE cc.order_sentence_id=os.order_sentence_id)
      JOIN (ocs
      WHERE ocs.synonym_id=cc.comp_id
       AND parser(searchtextparser))
      JOIN (oc
      WHERE oc.catalog_cd=cc.catalog_cd)
    ELSE INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      cs_component cc,
      order_catalog_synonym ocs,
      order_catalog oc
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (cc
      WHERE cc.order_sentence_id=os.order_sentence_id)
      JOIN (ocs
      WHERE ocs.synonym_id=cc.comp_id)
      JOIN (oc
      WHERE oc.catalog_cd=cc.catalog_cd)
    ENDIF
    ORDER BY oc.catalog_cd, cc.comp_id
    HEAD oc.catalog_cd
     groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt), reply->
     list_synonym_groups[groupcnt].synonym_group_id = oc.catalog_cd,
     reply->list_synonym_groups[groupcnt].synonym_group_name = oc.description
     IF (oc.orderable_type_flag IN (8, 11))
      reply->list_synonym_groups[groupcnt].synonym_group_flag = iv_set_type
     ELSE
      reply->list_synonym_groups[groupcnt].synonym_group_flag = care_set_type
     ENDIF
     synonym_cnt = 0
    HEAD cc.comp_id
     synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
     synonym_id = cc.comp_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic,
     sentence_cnt = 0
    DETAIL
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
     list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
     .seq].sent_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
     clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to retrieve hierarchy for care sets/iv sets.")
   CALL bedlogmessage("getCareSetsOrIVSets","Exiting ...")
 END ;Subroutine
 SUBROUTINE getpowerplans(dummyvar)
   CALL bedlogmessage("getPowerPlans","Entering ...")
   DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
   DECLARE type_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = numberofsentences),
     order_sentence os,
     order_catalog_synonym ocs2,
     pw_comp_os_reltn pcor,
     pathway_comp pc,
     pathway_catalog pcat
    PLAN (d)
     JOIN (os
     WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
     JOIN (ocs2
     WHERE ocs2.synonym_id=os.parent_entity2_id)
     JOIN (pcor
     WHERE pcor.order_sentence_id=os.order_sentence_id)
     JOIN (pc
     WHERE pc.pathway_comp_id=pcor.pathway_comp_id
      AND pc.active_ind=1)
     JOIN (pcat
     WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
      AND pcat.type_mean="PHASE")
    ORDER BY pcat.pathway_catalog_id
    HEAD pcat.pathway_catalog_id
     type_cnt = (type_cnt+ 1), stat = alterlist(pwtypemean->types,type_cnt), pwtypemean->types[
     type_cnt].pw_cat_id = pcat.pathway_catalog_id,
     pwtypemean->types[type_cnt].type_mean = pcat.type_mean
    WITH nocounter
   ;end select
   CALL echorecord(pwtypemean)
   DECLARE typesize = i4 WITH protect
   SET typesize = size(pwtypemean->types,5)
   IF (typesize > 0
    AND size(trim(request->search_text,3),1) > 0
    AND searchtoplevelind=1)
    CALL constructsearchtextparser(build("cnvtupper(pcat2.description) = '"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs2,
      pw_comp_os_reltn pcor,
      pathway_comp pc,
      pathway_catalog pcat2,
      pathway_catalog pcat,
      order_catalog_synonym ocs,
      pw_cat_reltn prel
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (ocs2
      WHERE ocs2.synonym_id=os.parent_entity2_id)
      JOIN (pcor
      WHERE pcor.order_sentence_id=os.order_sentence_id)
      JOIN (pc
      WHERE pc.pathway_comp_id=pcor.pathway_comp_id
       AND pc.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id)
      JOIN (prel
      WHERE prel.pw_cat_t_id=outerjoin(pc.pathway_catalog_id)
       AND prel.type_mean=outerjoin("GROUP"))
      JOIN (pcat2
      WHERE pcat2.pathway_catalog_id=outerjoin(prel.pw_cat_s_id)
       AND parser(searchtextparser)
       AND pcat2.active_ind=1)
      JOIN (pcat
      WHERE pcat.pathway_catalog_id=prel.pw_cat_t_id
       AND pcat.active_ind=1)
     ORDER BY pc.pathway_catalog_id, pc.parent_entity_id
     HEAD pc.pathway_catalog_id
      groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt)
      IF (pcat2.pathway_catalog_id > 0)
       reply->list_synonym_groups[groupcnt].synonym_group_id = pcat2.pathway_catalog_id, reply->
       list_synonym_groups[groupcnt].synonym_group_name = concat(trim(pcat2.description,3)," - ",pcat
        .description)
      ELSE
       reply->list_synonym_groups[groupcnt].synonym_group_id = pc.pathway_catalog_id, reply->
       list_synonym_groups[groupcnt].synonym_group_name = concat(pcat.description)
      ENDIF
      reply->list_synonym_groups[groupcnt].synonym_group_flag = power_plan_type, synonym_cnt = 0
     HEAD pc.parent_entity_id
      synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
       list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
      synonym_id = pc.parent_entity_id
      IF (ocs2.synonym_id > 0)
       reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = concat(trim(ocs
         .mnemonic,3),"/",trim(ocs2.mnemonic,3)), reply->list_synonym_groups[groupcnt].list_synonyms[
       synonym_cnt].synonym_type_flag = iv_set_type
      ELSE
       reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic
      ENDIF
      sentence_cnt = 0
     DETAIL
      sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
       list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
      .seq].sent_id,
      reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
      clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
     WITH nocounter
    ;end select
   ENDIF
   CALL constructsearchtextparser(build("cnvtupper(pcat.description) = '"))
   SELECT
    IF (searchtoplevelind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs2,
      pw_comp_os_reltn pcor,
      pathway_comp pc,
      pathway_catalog pcat,
      order_catalog_synonym ocs,
      pw_cat_reltn prel,
      pathway_catalog pcat2
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (ocs2
      WHERE ocs2.synonym_id=os.parent_entity2_id)
      JOIN (pcor
      WHERE pcor.order_sentence_id=os.order_sentence_id)
      JOIN (pc
      WHERE pc.pathway_comp_id=pcor.pathway_comp_id
       AND pc.active_ind=1)
      JOIN (pcat
      WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
       AND parser(searchtextparser)
       AND pcat.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id)
      JOIN (prel
      WHERE prel.pw_cat_t_id=outerjoin(pc.pathway_catalog_id)
       AND prel.type_mean=outerjoin("GROUP"))
      JOIN (pcat2
      WHERE pcat2.pathway_catalog_id=outerjoin(prel.pw_cat_s_id))
    ELSEIF (searchsynonymind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs2,
      pw_comp_os_reltn pcor,
      pathway_comp pc,
      pathway_catalog pcat,
      order_catalog_synonym ocs,
      pw_cat_reltn prel,
      pathway_catalog pcat2
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (ocs2
      WHERE ocs2.synonym_id=os.parent_entity2_id)
      JOIN (pcor
      WHERE pcor.order_sentence_id=os.order_sentence_id)
      JOIN (pc
      WHERE pc.pathway_comp_id=pcor.pathway_comp_id
       AND pc.active_ind=1)
      JOIN (pcat
      WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
       AND pcat.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id
       AND parser(searchtextparser))
      JOIN (prel
      WHERE prel.pw_cat_t_id=outerjoin(pc.pathway_catalog_id)
       AND prel.type_mean=outerjoin("GROUP"))
      JOIN (pcat2
      WHERE pcat2.pathway_catalog_id=outerjoin(prel.pw_cat_s_id))
    ELSE INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      order_catalog_synonym ocs2,
      pw_comp_os_reltn pcor,
      pathway_comp pc,
      pathway_catalog pcat,
      order_catalog_synonym ocs,
      pw_cat_reltn prel,
      pathway_catalog pcat2
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (ocs2
      WHERE ocs2.synonym_id=os.parent_entity2_id)
      JOIN (pcor
      WHERE pcor.order_sentence_id=os.order_sentence_id)
      JOIN (pc
      WHERE pc.pathway_comp_id=pcor.pathway_comp_id
       AND pc.active_ind=1)
      JOIN (pcat
      WHERE pcat.pathway_catalog_id=pc.pathway_catalog_id
       AND pcat.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id)
      JOIN (prel
      WHERE prel.pw_cat_t_id=outerjoin(pc.pathway_catalog_id)
       AND prel.type_mean=outerjoin("GROUP"))
      JOIN (pcat2
      WHERE pcat2.pathway_catalog_id=outerjoin(prel.pw_cat_s_id))
    ENDIF
    ORDER BY pc.pathway_catalog_id, pc.parent_entity_id
    HEAD pc.pathway_catalog_id
     groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt)
     IF (pcat2.pathway_catalog_id > 0)
      reply->list_synonym_groups[groupcnt].synonym_group_id = pcat2.pathway_catalog_id, reply->
      list_synonym_groups[groupcnt].synonym_group_name = concat(trim(pcat2.description,3)," - ",pcat
       .description)
     ELSE
      reply->list_synonym_groups[groupcnt].synonym_group_id = pc.pathway_catalog_id, reply->
      list_synonym_groups[groupcnt].synonym_group_name = concat(pcat.description)
     ENDIF
     reply->list_synonym_groups[groupcnt].synonym_group_flag = power_plan_type, synonym_cnt = 0
    HEAD pc.parent_entity_id
     synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
     synonym_id = pc.parent_entity_id
     IF (ocs2.synonym_id > 0)
      reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = concat(trim(ocs
        .mnemonic,3),"/",trim(ocs2.mnemonic,3)), reply->list_synonym_groups[groupcnt].list_synonyms[
      synonym_cnt].synonym_type_flag = iv_set_type
     ELSE
      reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic
     ENDIF
     sentence_cnt = 0
    DETAIL
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
     list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
     .seq].sent_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
     clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to retrieve hierarchy for power plans.")
   CALL bedlogmessage("getPowerPlans","Exiting ...")
 END ;Subroutine
 SUBROUTINE getpathwayrulepowerplans(dummyvar)
   DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
   DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
   CALL constructsearchtextparser(build("cnvtupper(pcp.plan_name) = '"))
   SELECT
    IF (searchtoplevelind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      pathway_rule p,
      pathway_comp pc,
      pathway_customized_plan pcp,
      order_catalog_synonym ocs,
      prsnl pr
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (p
      WHERE p.pathway_rule_id=os.parent_entity_id
       AND p.entity_name="ORDER_SENTENCE")
      JOIN (pcp
      WHERE pcp.pathway_customized_plan_id=p.pathway_customized_plan_id
       AND pcp.active_ind=1
       AND parser(searchtextparser))
      JOIN (pr
      WHERE pr.person_id=pcp.prsnl_id)
      JOIN (pc
      WHERE pc.pathway_uuid=p.target_uuid
       AND pc.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id
       AND ocs.active_ind=1)
    ELSEIF (searchsynonymind=1)INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      pathway_rule p,
      pathway_comp pc,
      pathway_customized_plan pcp,
      order_catalog_synonym ocs,
      prsnl pr
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (p
      WHERE p.pathway_rule_id=os.parent_entity_id
       AND p.entity_name="ORDER_SENTENCE")
      JOIN (pcp
      WHERE pcp.pathway_customized_plan_id=p.pathway_customized_plan_id
       AND pcp.active_ind=1)
      JOIN (pr
      WHERE pr.person_id=pcp.prsnl_id)
      JOIN (pc
      WHERE pc.pathway_uuid=p.target_uuid
       AND pc.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id
       AND ocs.active_ind=1
       AND parser(searchtextparser))
    ELSE INTO "nl:"
     FROM (dummyt d  WITH seq = numberofsentences),
      order_sentence os,
      pathway_rule p,
      pathway_comp pc,
      pathway_customized_plan pcp,
      order_catalog_synonym ocs,
      prsnl pr
     PLAN (d)
      JOIN (os
      WHERE (os.order_sentence_id=allsentences->sentences[d.seq].sent_id))
      JOIN (p
      WHERE p.pathway_rule_id=os.parent_entity_id
       AND p.entity_name="ORDER_SENTENCE")
      JOIN (pcp
      WHERE pcp.pathway_customized_plan_id=p.pathway_customized_plan_id
       AND pcp.active_ind=1)
      JOIN (pr
      WHERE pr.person_id=pcp.prsnl_id)
      JOIN (pc
      WHERE pc.pathway_uuid=p.target_uuid
       AND pc.active_ind=1)
      JOIN (ocs
      WHERE ocs.synonym_id=pc.parent_entity_id
       AND ocs.active_ind=1)
    ENDIF
    ORDER BY p.pathway_customized_plan_id, ocs.synonym_id, os.order_sentence_id
    HEAD p.pathway_customized_plan_id
     groupcnt = (groupcnt+ 1), stat = alterlist(reply->list_synonym_groups,groupcnt), reply->
     list_synonym_groups[groupcnt].synonym_group_id = pcp.pathway_customized_plan_id,
     reply->list_synonym_groups[groupcnt].synonym_group_name = concat(trim(pcp.plan_name)," (",trim(
       cnvtupper(pr.username)),")"), reply->list_synonym_groups[groupcnt].synonym_group_flag =
     power_plan_type, synonym_cnt = 0
    HEAD ocs.synonym_id
     synonym_cnt = (synonym_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms,synonym_cnt), reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].
     synonym_id = ocs.synonym_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].synonym_name = ocs.mnemonic,
     sentence_cnt = 0
    HEAD os.order_sentence_id
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->list_synonym_groups[groupcnt].
      list_synonyms[synonym_cnt].list_sentences,sentence_cnt), reply->list_synonym_groups[groupcnt].
     list_synonyms[synonym_cnt].list_sentences[sentence_cnt].sentence_id = allsentences->sentences[d
     .seq].sent_id,
     reply->list_synonym_groups[groupcnt].list_synonyms[synonym_cnt].list_sentences[sentence_cnt].
     clin_disp_line = allsentences->sentences[d.seq].clin_disp_line
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL echorecord(reply)
END GO
