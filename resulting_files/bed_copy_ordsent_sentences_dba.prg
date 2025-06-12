CREATE PROGRAM bed_copy_ordsent_sentences:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 SET scnt = 0
 SET sentcnt = 0
 SET sentcnt = size(request->sentences,5)
 IF (sentcnt=0)
  GO TO exit_script
 ENDIF
 SET scnt = size(request->synonyms,5)
 IF ((request->catalog_type_code_value=0)
  AND (request->activity_type_code_value=0)
  AND (request->subactivity_type_code_value=0)
  AND scnt=0)
  GO TO exit_script
 ENDIF
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET comp_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="ORDERABLE")
  DETAIL
   comp_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ordsent_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=30620
    AND cv.cdf_meaning="ORDERSENT")
  DETAIL
   ordsent_cd = cv.code_value
  WITH nocounter
 ;end select
 RECORD sentence(
   1 qual[*]
     2 id = f8
     2 sentence = vc
     2 usage_flag = i2
     2 order_encntr_group_cd = f8
     2 ord_comment_long_text_id = f8
     2 text = vc
     2 details[*]
       3 sequence = i4
       3 oe_field_value = f8
       3 oe_field_id = f8
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
       3 field_type_flag = i2
       3 def_parent_name = vc
       3 def_parent_id = f8
     2 facilities[*]
       3 loc_cd = f8
     2 sequence = i4
     2 filters[*]
       3 age_min_value = f8
       3 age_max_value = f8
       3 age_code_value = f8
       3 pma_min_value = f8
       3 pma_max_value = f8
       3 pma_code_value = f8
       3 weight_min_value = f8
       3 weight_max_value = f8
       3 weight_code_value = f8
 )
 SET rcnt = 0
 FOR (x = 1 TO sentcnt)
   IF ((request->sentences[x].standalone_ind=1))
    SELECT INTO "nl:"
     FROM ord_cat_sent_r r,
      order_sentence s,
      long_text l
     PLAN (r
      WHERE (r.order_sentence_id=request->sentences[x].id)
       AND r.active_ind=1)
      JOIN (s
      WHERE s.order_sentence_id=r.order_sentence_id)
      JOIN (l
      WHERE l.long_text_id=s.ord_comment_long_text_id)
     HEAD s.order_sentence_id
      rcnt = (rcnt+ 1), stat = alterlist(sentence->qual,rcnt), sentence->qual[rcnt].id = s
      .order_sentence_id,
      sentence->qual[rcnt].sentence = s.order_sentence_display_line, sentence->qual[rcnt].usage_flag
       = s.usage_flag, sentence->qual[rcnt].order_encntr_group_cd = s.order_encntr_group_cd,
      sentence->qual[rcnt].ord_comment_long_text_id = s.ord_comment_long_text_id, sentence->qual[rcnt
      ].text = l.long_text, sentence->qual[rcnt].sequence = r.display_seq
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM order_sentence s,
      long_text l
     PLAN (s
      WHERE (s.order_sentence_id=request->sentences[x].id))
      JOIN (l
      WHERE l.long_text_id=s.ord_comment_long_text_id)
     HEAD s.order_sentence_id
      rcnt = (rcnt+ 1), stat = alterlist(sentence->qual,rcnt), sentence->qual[rcnt].id = s
      .order_sentence_id,
      sentence->qual[rcnt].sentence = s.order_sentence_display_line, sentence->qual[rcnt].usage_flag
       = s.usage_flag, sentence->qual[rcnt].order_encntr_group_cd = s.order_encntr_group_cd,
      sentence->qual[rcnt].ord_comment_long_text_id = s.ord_comment_long_text_id, sentence->qual[rcnt
      ].text = l.long_text
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (rcnt=0)
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   order_sentence_detail s
  PLAN (d)
   JOIN (s
   WHERE (s.order_sentence_id=sentence->qual[d.seq].id))
  ORDER BY d.seq
  HEAD d.seq
   dcnt = 0
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(sentence->qual[d.seq].details,dcnt), sentence->qual[d.seq].
   details[dcnt].sequence = s.sequence,
   sentence->qual[d.seq].details[dcnt].oe_field_value = s.oe_field_value, sentence->qual[d.seq].
   details[dcnt].oe_field_id = s.oe_field_id, sentence->qual[d.seq].details[dcnt].
   oe_field_display_value = s.oe_field_display_value,
   sentence->qual[d.seq].details[dcnt].oe_field_meaning_id = s.oe_field_meaning_id, sentence->qual[d
   .seq].details[dcnt].field_type_flag = s.field_type_flag, sentence->qual[d.seq].details[dcnt].
   def_parent_name = s.default_parent_entity_name,
   sentence->qual[d.seq].details[dcnt].def_parent_id = s.default_parent_entity_id
  WITH nocounter
 ;end select
 SET filter_cnt = 0
 SELECT INTO "nl:"
  FROM order_sentence_filter osf,
   (dummyt d  WITH seq = value(rcnt))
  PLAN (d)
   JOIN (osf
   WHERE (osf.order_sentence_id=sentence->qual[d.seq].id))
  ORDER BY d.seq
  HEAD d.seq
   filter_cnt = 0
  DETAIL
   filter_cnt = (filter_cnt+ 1), stat = alterlist(sentence->qual[d.seq].filters,filter_cnt), sentence
   ->qual[d.seq].filters[filter_cnt].age_max_value = osf.age_max_value,
   sentence->qual[d.seq].filters[filter_cnt].age_min_value = osf.age_min_value, sentence->qual[d.seq]
   .filters[filter_cnt].age_code_value = osf.age_unit_cd, sentence->qual[d.seq].filters[filter_cnt].
   pma_max_value = osf.pma_max_value,
   sentence->qual[d.seq].filters[filter_cnt].pma_min_value = osf.pma_min_value, sentence->qual[d.seq]
   .filters[filter_cnt].pma_code_value = osf.pma_unit_cd, sentence->qual[d.seq].filters[filter_cnt].
   weight_max_value = osf.weight_max_value,
   sentence->qual[d.seq].filters[filter_cnt].weight_min_value = osf.weight_min_value, sentence->qual[
   d.seq].filters[filter_cnt].weight_code_value = osf.weight_unit_cd
  WITH nocounter
 ;end select
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   filter_entity_reltn f
  PLAN (d)
   JOIN (f
   WHERE (f.parent_entity_id=sentence->qual[d.seq].id))
  ORDER BY d.seq
  HEAD d.seq
   fcnt = 0
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(sentence->qual[d.seq].facilities,fcnt), sentence->qual[d.seq].
   facilities[fcnt].loc_cd = f.filter_entity1_id
  WITH nocounter
 ;end select
 RECORD syn(
   1 qual[*]
     2 id = f8
     2 catalog_cd = f8
     2 oe_format_id = f8
     2 careset_cd = f8
 )
 DECLARE oc_string = vc
 IF ((request->catalog_type_code_value > 0))
  SET oc_string = "oc.catalog_type_cd = request->catalog_type_code_value"
 ENDIF
 IF ((request->activity_type_code_value > 0))
  IF (oc_string > " ")
   SET oc_string = concat(trim(oc_string),
    " and oc.activity_type_cd = request->activity_type_code_value")
  ELSE
   SET oc_string = "oc.activity_type_cd = request->activity_type_code_value"
  ENDIF
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  IF (oc_string > " ")
   SET oc_string = concat(trim(oc_string),
    " and oc.activity_subtype_cd = request->subactivity_type_code_value")
  ELSE
   SET oc_string = "oc.activity_subtype_cd = request->subactivity_type_code_value"
  ENDIF
 ENDIF
 SET ocnt = 0
 IF (scnt > 0)
  SET ocnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(scnt)),
    order_catalog_synonym o
   PLAN (d)
    JOIN (o
    WHERE (o.synonym_id=request->synonyms[d.seq].id)
     AND o.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    ocnt = (ocnt+ 1), stat = alterlist(syn->qual,ocnt), syn->qual[ocnt].id = o.synonym_id,
    syn->qual[ocnt].catalog_cd = o.catalog_cd, syn->qual[ocnt].oe_format_id = o.oe_format_id, syn->
    qual[ocnt].careset_cd = request->synonyms[d.seq].careset_catalog_code_value
   WITH nocounter
  ;end select
 ELSE
  SET ocnt = 0
  SELECT INTO "nl:"
   FROM order_catalog_synonym o
   PLAN (o
    WHERE parser(oc_string)
     AND o.active_ind=1)
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(syn->qual,ocnt), syn->qual[ocnt].id = o.synonym_id,
    syn->qual[ocnt].catalog_cd = o.catalog_cd, syn->qual[ocnt].oe_format_id = o.oe_format_id
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO ocnt)
   FOR (y = 1 TO rcnt)
     SET os_id = 0.0
     SELECT INTO "nl:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       os_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET lt_id = 0.0
     IF ((sentence->qual[y].ord_comment_long_text_id > 0))
      SELECT INTO "nl:"
       j = seq(long_data_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        lt_id = cnvtreal(j)
       WITH format, counter
      ;end select
     ENDIF
     IF ((syn->qual[x].careset_cd=0))
      INSERT  FROM ord_cat_sent_r o
       SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = os_id, o
        .order_sentence_disp_line = substring(1,255,sentence->qual[y].sentence),
        o.catalog_cd = syn->qual[x].catalog_cd, o.synonym_id = syn->qual[x].id, o.active_ind = 1,
        o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
        reqinfo->updt_task,
        o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq =
        IF ((sentence->qual[y].sequence > 0)) sentence->qual[y].sequence
        ELSE null
        ENDIF
       PLAN (o)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("COPY_ORDSENT_ERROR_1")
     ELSE
      SET comp_seq = 0
      SELECT INTO "nl:"
       FROM cs_component c
       PLAN (c
        WHERE (c.catalog_cd=syn->qual[x].careset_cd))
       ORDER BY c.comp_seq
       DETAIL
        comp_seq = c.comp_seq
       WITH nocounter
      ;end select
      UPDATE  FROM cs_component c
       SET c.catalog_cd = syn->qual[x].careset_cd, c.comp_id = syn->qual[x].id, c.comp_seq = (
        comp_seq+ 1),
        c.comp_type_cd = comp_cd, c.order_sentence_id = os_id, c.long_text_id = 0,
        c.required_ind = 0, c.include_exclude_ind = 0, c.comp_label = "",
        c.linked_date_comp_seq = 0, c.variance_format_id = 0, c.parent_comp_seq = null,
        c.cp_row_cat_cd = 0, c.cp_col_cat_cd = 0, c.outcome_par_comp_seq = null,
        c.comp_type_mean = null, c.index_type_cd = 0, c.ord_com_template_long_text_id = 0,
        c.comp_mask = null, c.comp_reference = null, c.lockdown_details_flag = 0,
        c.av_optional_ingredient_ind = 0, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
       PLAN (c)
       WITH nocounter
      ;end update
     ENDIF
     INSERT  FROM order_sentence o
      SET o.order_sentence_id = os_id, o.order_sentence_display_line = substring(1,255,sentence->
        qual[y].sentence), o.oe_format_id = syn->qual[x].oe_format_id,
       o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
       reqinfo->updt_task,
       o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = sentence->qual[y].
       usage_flag,
       o.order_encntr_group_cd = sentence->qual[y].order_encntr_group_cd, o.ord_comment_long_text_id
        = lt_id, o.parent_entity_name = "ORDER_CATALOG_SYNONYM",
       o.parent_entity_id = syn->qual[x].id, o.parent_entity2_name = "", o.parent_entity2_id = 0,
       o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
      PLAN (o)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("COPY_ORDSENT_ERROR_2")
     IF (size(sentence->qual[y].filters,5) > 0)
      INSERT  FROM order_sentence_filter f,
        (dummyt d  WITH seq = value(sentence->qual[y].filters,5))
       SET f.order_sentence_filter_id = seq(reference_seq,nextval), f.age_max_value = sentence->qual[
        y].filters[d.seq].age_max_value, f.age_min_value = sentence->qual[y].filters[d.seq].
        age_min_value,
        f.age_unit_cd = sentence->qual[y].filters[d.seq].age_code_value, f.order_sentence_id = os_id,
        f.pma_max_value = sentence->qual[y].filters[d.seq].pma_max_value,
        f.pma_min_value = sentence->qual[y].filters[d.seq].pma_min_value, f.pma_unit_cd = sentence->
        qual[y].filters[d.seq].pma_code_value, f.weight_max_value = sentence->qual[y].filters[d.seq].
        weight_max_value,
        f.weight_min_value = sentence->qual[y].filters[d.seq].weight_min_value, f.weight_unit_cd =
        sentence->qual[y].filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
        f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
        .updt_applctx = reqinfo->updt_applctx,
        f.updt_cnt = 0
       PLAN (d)
        JOIN (f)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("COPY_ORDSENT_ERROR_3")
     ENDIF
     FOR (z = 1 TO size(sentence->qual[y].details,5))
      INSERT  FROM order_sentence_detail o
       SET o.order_sentence_id = os_id, o.sequence = sentence->qual[y].details[z].sequence, o
        .oe_field_value = sentence->qual[y].details[z].oe_field_value,
        o.oe_field_id = sentence->qual[y].details[z].oe_field_id, o.oe_field_display_value = sentence
        ->qual[y].details[z].oe_field_display_value, o.oe_field_meaning_id = sentence->qual[y].
        details[z].oe_field_meaning_id,
        o.field_type_flag = sentence->qual[y].details[z].field_type_flag, o.updt_id = reqinfo->
        updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime),
        o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
        o.default_parent_entity_name = sentence->qual[y].details[z].def_parent_name, o
        .default_parent_entity_id = sentence->qual[y].details[z].def_parent_id
       PLAN (o)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("COPY_ORDSENT_ERROR_4")
     ENDFOR
     IF (lt_id > 0)
      INSERT  FROM long_text l
       SET l.long_text_id = lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
        l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(
         curdate,curtime),
        l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
        .parent_entity_id = os_id,
        l.long_text = sentence->qual[y].text
       PLAN (l)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("COPY_ORDSENT_ERROR_5")
     ENDIF
     FOR (z = 1 TO size(sentence->qual[y].facilities,5))
      INSERT  FROM filter_entity_reltn f
       SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
        "ORDER_SENTENCE", f.parent_entity_id = os_id,
        f.filter_entity1_name = "LOCATION", f.filter_entity1_id = sentence->qual[y].facilities[z].
        loc_cd, f.filter_entity2_name = null,
        f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
        f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
        f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
        f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
        f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
        .updt_applctx = reqinfo->updt_applctx,
        f.updt_cnt = 0
       PLAN (f)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("COPY_ORDSENT_ERROR_6")
     ENDFOR
   ENDFOR
   SET sent_id = 0.0
   SET mcnt = 0
   SELECT INTO "nl:"
    FROM ord_cat_sent_r o
    PLAN (o
     WHERE (o.synonym_id=syn->qual[x].id))
    DETAIL
     mcnt = (mcnt+ 1), sent_id = o.order_sentence_id
    WITH nocounter
   ;end select
   IF (mcnt=1)
    UPDATE  FROM order_catalog_synonym o
     SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = sent_id, o.updt_id = reqinfo->updt_id,
      o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
       = reqinfo->updt_applctx,
      o.updt_cnt = (o.updt_cnt+ 1)
     PLAN (o
      WHERE (o.synonym_id=syn->qual[x].id))
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM order_catalog_synonym o
     SET o.multiple_ord_sent_ind = 1, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
      o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx
       = reqinfo->updt_applctx,
      o.updt_cnt = (o.updt_cnt+ 1)
     PLAN (o
      WHERE (o.synonym_id=syn->qual[x].id))
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
END GO
