CREATE PROGRAM bed_ens_ordsent_sentences:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sentence_id = f8
    1 display_line = vc
    1 error_msg = vc
    1 filters[*]
      2 order_sentence_filter_id = f8
      2 age_min_value = f8
      2 age_max_value = f8
      2 age_unit_cd
        3 code_value = f8
        3 display = vc
        3 mean = vc
        3 description = vc
      2 pma_min_value = f8
      2 pma_max_value = f8
      2 pma_unit_cd
        3 code_value = f8
        3 display = vc
        3 mean = vc
        3 description = vc
      2 weight_min_value = f8
      2 weight_max_value = f8
      2 weight_unit_cd
        3 code_value = f8
        3 display = vc
        3 mean = vc
        3 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET new_filter_ids
 RECORD new_filter_ids(
   1 filter_ids[*]
     2 filter_id = f8
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
 DECLARE ensureordersentences(dummyvar=i2) = null
 DECLARE replyfilteradd(filterlistsize=i4) = null
 CALL ensureordersentences(0)
 SUBROUTINE ensureordersentences(dummyvar)
   SET eg_cnt = 0
   SET eg_cd = 0.0
   SET use_eg_list = 0
   SET cs_cnt = 0
   SET sentence_id = 0.0
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
   SET order_cd = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=6003
      AND c.cdf_meaning="ORDER"
      AND c.active_ind=1)
    DETAIL
     order_cd = c.code_value
    WITH nocounter
   ;end select
   SET disorder_cd = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=6003
      AND c.cdf_meaning="DISORDER"
      AND c.active_ind=1)
    DETAIL
     disorder_cd = c.code_value
    WITH nocounter
   ;end select
   IF ((request->action_flag=1))
    SET catalog_cd = 0.0
    SET format_id = 0.0
    SELECT INTO "nl:"
     FROM order_catalog_synonym o
     PLAN (o
      WHERE (o.synonym_id=request->synonym_id))
     DETAIL
      catalog_cd = o.catalog_cd, format_id = o.oe_format_id
     WITH nocounter
    ;end select
    DECLARE order_sentence = vc
    DECLARE os_value = vc
    FOR (x = 1 TO size(request->fields,5))
      IF ((request->fields[x].field_type_flag=7))
       IF ((request->fields[x].value IN ("YES", "1")))
        SET request->fields[x].value = "Yes"
       ENDIF
       IF ((request->fields[x].value IN ("NO", "0")))
        SET request->fields[x].value = "No"
       ENDIF
      ENDIF
      SET os_value = ""
      IF ((request->usage_flag=2))
       SELECT INTO "nl:"
        FROM oe_format_fields o
        PLAN (o
         WHERE o.oe_format_id=format_id
          AND (o.oe_field_id=request->fields[x].oe_field_id)
          AND o.action_type_cd=disorder_cd)
        DETAIL
         IF (o.clin_line_ind > 0)
          os_value = request->fields[x].value
          IF ((request->fields[x].field_type_flag=7))
           os_value = ""
           IF ((request->fields[x].value="No"))
            IF (o.disp_yes_no_flag IN (0, 2))
             os_value = o.clin_line_label
            ELSE
             os_value = ""
            ENDIF
           ELSE
            IF (o.disp_yes_no_flag=2)
             os_value = ""
            ELSE
             os_value = o.label_text
            ENDIF
           ENDIF
          ELSE
           IF (o.clin_line_label > " ")
            IF (o.clin_suffix_ind=1)
             os_value = concat(trim(request->fields[x].value)," ",trim(o.clin_line_label))
            ELSE
             os_value = concat(trim(o.clin_line_label)," ",trim(request->fields[x].value))
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "nl:"
        FROM oe_format_fields o
        PLAN (o
         WHERE o.oe_format_id=format_id
          AND (o.oe_field_id=request->fields[x].oe_field_id)
          AND o.action_type_cd=order_cd)
        DETAIL
         IF (o.clin_line_ind > 0)
          os_value = request->fields[x].value
          IF ((request->fields[x].field_type_flag=7))
           os_value = ""
           IF ((request->fields[x].value="No"))
            IF (o.disp_yes_no_flag IN (0, 2))
             os_value = o.clin_line_label
            ELSE
             os_value = ""
            ENDIF
           ELSE
            IF (o.disp_yes_no_flag=2)
             os_value = ""
            ELSE
             os_value = o.label_text
            ENDIF
           ENDIF
          ELSE
           IF (o.clin_line_label > " ")
            IF (o.clin_suffix_ind=1)
             os_value = concat(trim(request->fields[x].value)," ",trim(o.clin_line_label))
            ELSE
             os_value = concat(trim(o.clin_line_label)," ",trim(request->fields[x].value))
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      IF ( NOT (order_sentence > " "))
       IF (os_value > " ")
        SET order_sentence = trim(os_value)
        SET gseq = request->fields[x].group_seq
       ENDIF
      ELSE
       IF (os_value > " ")
        IF ((gseq=request->fields[x].group_seq))
         SET order_sentence = concat(trim(order_sentence)," ",trim(os_value))
        ELSE
         SET order_sentence = concat(trim(order_sentence),", ",trim(os_value))
         SET gseq = request->fields[x].group_seq
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    SET reply->display_line = order_sentence
    SET eg_cnt = size(request->encntr_groups,5)
    IF (eg_cnt=0)
     SET eg_cnt = 1
     SET eg_cd = 0.0
    ELSE
     SET use_eg_list = 1
    ENDIF
    FOR (z = 1 TO eg_cnt)
      IF (use_eg_list=1)
       SET eg_cd = request->encntr_groups[z].code_value
      ENDIF
      SET os_id = 0.0
      SELECT INTO "nl:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        os_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET reply->sentence_id = os_id
      SET lt_id = 0.0
      IF ((request->comment.action_flag=1))
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         lt_id = cnvtreal(j)
        WITH format, counter
       ;end select
      ENDIF
      IF ((request->standalone_ind=1))
       INSERT  FROM ord_cat_sent_r o
        SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = os_id, o
         .order_sentence_disp_line = substring(1,255,order_sentence),
         o.catalog_cd = catalog_cd, o.synonym_id = request->synonym_id, o.active_ind = 1,
         o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
         reqinfo->updt_task,
         o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq = null
        PLAN (o)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ENS_OS_ERROR_1")
      ELSE
       UPDATE  FROM cs_component c
        SET c.order_sentence_id = os_id, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
          curdate,curtime),
         c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
         .updt_cnt+ 1)
        PLAN (c
         WHERE (c.catalog_cd=request->careset_catalog_code_value)
          AND (c.comp_id=request->synonym_id)
          AND (c.comp_seq=request->comp_seq))
        WITH nocounter
       ;end update
       CALL bederrorcheck("ENS_OS_ERROR_2")
       IF ((request->add_standalone_ind=1))
        SET s_os_id = 0.0
        SELECT INTO "nl:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          s_os_id = cnvtreal(j)
         WITH format, counter
        ;end select
        SET s_lt_id = 0.0
        IF ((request->comment.action_flag=1))
         SELECT INTO "nl:"
          j = seq(long_data_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           s_lt_id = cnvtreal(j)
          WITH format, counter
         ;end select
        ENDIF
        INSERT  FROM ord_cat_sent_r o
         SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = s_os_id, o
          .order_sentence_disp_line = substring(1,255,order_sentence),
          o.catalog_cd = catalog_cd, o.synonym_id = request->synonym_id, o.active_ind = 1,
          o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
          reqinfo->updt_task,
          o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq = null
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_3")
        INSERT  FROM order_sentence o
         SET o.order_sentence_id = s_os_id, o.order_sentence_display_line = substring(1,255,
           order_sentence), o.oe_format_id = format_id,
          o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
          reqinfo->updt_task,
          o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = request->usage_flag,
          o.order_encntr_group_cd = eg_cd, o.ord_comment_long_text_id = s_lt_id, o.parent_entity_name
           = "ORDER_CATALOG_SYNONYM",
          o.parent_entity_id = request->synonym_id, o.parent_entity2_name = null, o.parent_entity2_id
           = 0,
          o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_4")
        SET filtersize = size(request->filters,5)
        IF (filtersize > 0)
         SET stat = alterlist(new_filter_ids->filter_ids,filtersize)
         FOR (x = 1 TO filtersize)
          SELECT INTO "nl:"
           j = seq(reference_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            new_filter_ids->filter_ids[x].filter_id = cnvtreal(j)
           WITH format, counter
          ;end select
          CALL bederrorcheck("ID_GENERATE_1")
         ENDFOR
         INSERT  FROM order_sentence_filter f,
           (dummyt d  WITH seq = value(filtersize))
          SET f.order_sentence_filter_id = new_filter_ids->filter_ids[d.seq].filter_id, f
           .age_max_value = request->filters[d.seq].age_max_value, f.age_min_value = request->
           filters[d.seq].age_min_value,
           f.age_unit_cd = request->filters[d.seq].age_code_value, f.order_sentence_id = s_os_id, f
           .pma_max_value = request->filters[d.seq].pma_max_value,
           f.pma_min_value = request->filters[d.seq].pma_min_value, f.pma_unit_cd = request->filters[
           d.seq].pma_code_value, f.weight_max_value = request->filters[d.seq].weight_max_value,
           f.weight_min_value = request->filters[d.seq].weight_min_value, f.weight_unit_cd = request
           ->filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
           f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
           .updt_applctx = reqinfo->updt_applctx,
           f.updt_cnt = 0
          PLAN (d
           WHERE (request->filters[d.seq].order_sentence_filter_id=0)
            AND (((request->filters[d.seq].age_code_value > 0)) OR ((((request->filters[d.seq].
           pma_code_value > 0)) OR ((request->filters[d.seq].weight_code_value > 0))) )) )
           JOIN (f)
          WITH nocounter
         ;end insert
         CALL replyfilteradd(filtersize)
         CALL bederrorcheck("ENS_OS_FILTER_ERR_1")
        ENDIF
        FOR (x = 1 TO size(request->fields,5))
          SET oe_field_meaning_id = 0.0
          DECLARE default_name = vc
          SET default_id = 0.0
          SELECT INTO "nl:"
           FROM order_entry_fields o
           PLAN (o
            WHERE (o.oe_field_id=request->fields[x].oe_field_id))
           DETAIL
            oe_field_meaning_id = o.oe_field_meaning_id
           WITH nocounter
          ;end select
          IF ((request->fields[x].field_type_flag IN (0, 1, 2, 3, 5,
          7, 11, 14, 15)))
           SET default_name = " "
           SET default_id = 0
          ELSEIF ((request->fields[x].field_type_flag IN (6, 9)))
           SET default_name = "CODE_VALUE"
           SET default_id = request->fields[x].code_value
          ELSEIF ((request->fields[x].field_type_flag=12))
           IF (oe_field_meaning_id=48)
            SET default__name = "RESEARCH_ACCOUNT"
           ELSEIF (oe_field_meaning_id=123)
            SET default_name = "SCH_BOOK_INSTR"
           ELSE
            SET default_name = "CODE_VALUE"
           ENDIF
           SET default_id = request->fields[x].code_value
          ELSEIF ((request->fields[x].field_type_flag IN (8, 13)))
           SET default_name = "PERSON"
           IF (validate(request->fields[x].parent_entity_id))
            SET default_id = request->fields[x].parent_entity_id
           ENDIF
          ELSEIF ((request->fields[x].field_type_flag=10))
           SET default_name = "NOMENCLATURE"
           IF (validate(request->fields[x].parent_entity_id))
            SET default_id = request->fields[x].parent_entity_id
           ENDIF
          ENDIF
          INSERT  FROM order_sentence_detail o
           SET o.order_sentence_id = s_os_id, o.sequence = x, o.oe_field_value = request->fields[x].
            field_value,
            o.oe_field_id = request->fields[x].oe_field_id, o.oe_field_display_value = request->
            fields[x].value, o.oe_field_meaning_id = oe_field_meaning_id,
            o.field_type_flag = request->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o
            .updt_dt_tm = cnvtdatetime(curdate,curtime),
            o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
            o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
           PLAN (o)
           WITH nocounter
          ;end insert
          CALL bederrorcheck("ENS_OS_ERROR_5")
        ENDFOR
        IF (s_lt_id > 0)
         INSERT  FROM long_text l
          SET l.long_text_id = s_lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(
            curdate,curtime),
           l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
           l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(
            curdate,curtime),
           l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
           .parent_entity_id = s_os_id,
           l.long_text = request->comment.text
          PLAN (l)
          WITH nocounter
         ;end insert
         CALL bederrorcheck("ENS_OS_ERROR_6")
        ENDIF
       ENDIF
      ENDIF
      DECLARE p2_id = f8 WITH protect, noconstant(0.0)
      DECLARE p2_name = vc WITH protect, noconstant("")
      IF ((request->standalone_ind=0))
       SET p2_name = "ORDER_CATALOG"
       SET p2_id = request->careset_catalog_code_value
      ENDIF
      INSERT  FROM order_sentence o
       SET o.order_sentence_id = os_id, o.order_sentence_display_line = substring(1,255,
         order_sentence), o.oe_format_id = format_id,
        o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
        reqinfo->updt_task,
        o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = request->usage_flag,
        o.order_encntr_group_cd = eg_cd, o.ord_comment_long_text_id = lt_id, o.parent_entity_name =
        "ORDER_CATALOG_SYNONYM",
        o.parent_entity_id = request->synonym_id, o.parent_entity2_name = evaluate(p2_name,
         "ORDER_CATALOG",p2_name,null), o.parent_entity2_id = p2_id,
        o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
       PLAN (o)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ENS_OS_ERROR_7")
      SET filtersize = size(request->filters,5)
      IF (filtersize > 0)
       SET stat = alterlist(new_filter_ids->filter_ids,filtersize)
       FOR (x = 1 TO filtersize)
        SELECT INTO "nl:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_filter_ids->filter_ids[x].filter_id = cnvtreal(j)
         WITH format, counter
        ;end select
        CALL bederrorcheck("ID_GENERATE_1")
       ENDFOR
       INSERT  FROM order_sentence_filter f,
         (dummyt d  WITH seq = value(filtersize))
        SET f.order_sentence_filter_id = new_filter_ids->filter_ids[d.seq].filter_id, f.age_max_value
          = request->filters[d.seq].age_max_value, f.age_min_value = request->filters[d.seq].
         age_min_value,
         f.age_unit_cd = request->filters[d.seq].age_code_value, f.order_sentence_id = os_id, f
         .pma_max_value = request->filters[d.seq].pma_max_value,
         f.pma_min_value = request->filters[d.seq].pma_min_value, f.pma_unit_cd = request->filters[d
         .seq].pma_code_value, f.weight_max_value = request->filters[d.seq].weight_max_value,
         f.weight_min_value = request->filters[d.seq].weight_min_value, f.weight_unit_cd = request->
         filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
         f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
         .updt_applctx = reqinfo->updt_applctx,
         f.updt_cnt = 0
        PLAN (d
         WHERE (((request->filters[d.seq].age_code_value > 0)) OR ((((request->filters[d.seq].
         pma_code_value > 0)) OR ((request->filters[d.seq].weight_code_value > 0))) )) )
         JOIN (f)
        WITH nocounter
       ;end insert
       CALL replyfilteradd(filtersize)
       CALL bederrorcheck("ENS_OS_FILTER_ERR_2")
      ENDIF
      FOR (x = 1 TO size(request->fields,5))
        SET oe_field_meaning_id = 0.0
        DECLARE default_name = vc
        SET default_id = 0.0
        SELECT INTO "nl:"
         FROM order_entry_fields o
         PLAN (o
          WHERE (o.oe_field_id=request->fields[x].oe_field_id))
         DETAIL
          oe_field_meaning_id = o.oe_field_meaning_id
         WITH nocounter
        ;end select
        IF ((request->fields[x].field_type_flag IN (0, 1, 2, 3, 5,
        7, 11, 14, 15)))
         SET default_name = " "
         SET default_id = 0
        ELSEIF ((request->fields[x].field_type_flag IN (6, 9)))
         SET default_name = "CODE_VALUE"
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag=12))
         IF (oe_field_meaning_id=48)
          SET default__name = "RESEARCH_ACCOUNT"
         ELSEIF (oe_field_meaning_id=123)
          SET default_name = "SCH_BOOK_INSTR"
         ELSE
          SET default_name = "CODE_VALUE"
         ENDIF
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag IN (8, 13)))
         SET default_name = "PERSON"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ELSEIF ((request->fields[x].field_type_flag=10))
         SET default_name = "NOMENCLATURE"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ENDIF
        INSERT  FROM order_sentence_detail o
         SET o.order_sentence_id = os_id, o.sequence = x, o.oe_field_value = request->fields[x].
          field_value,
          o.oe_field_id = request->fields[x].oe_field_id, o.oe_field_display_value = request->fields[
          x].value, o.oe_field_meaning_id = oe_field_meaning_id,
          o.field_type_flag = request->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o
          .updt_dt_tm = cnvtdatetime(curdate,curtime),
          o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
          o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_8")
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
         l.long_text = request->comment.text
        PLAN (l)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ENS_OS_ERROR_9")
      ENDIF
      IF ((request->standalone_ind=1))
       IF ((request->all_facility_ind=1))
        INSERT  FROM filter_entity_reltn f
         SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
          "ORDER_SENTENCE", f.parent_entity_id = os_id,
          f.filter_entity1_name = "LOCATION", f.filter_entity1_id = 0, f.filter_entity2_name = null,
          f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
          f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
          f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
          f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime
          ("31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
          f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
          .updt_applctx = reqinfo->updt_applctx,
          f.updt_cnt = 0
         PLAN (f)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_10")
       ELSE
        FOR (y = 1 TO size(request->facilities,5))
         INSERT  FROM filter_entity_reltn f
          SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
           "ORDER_SENTENCE", f.parent_entity_id = os_id,
           f.filter_entity1_name = "LOCATION", f.filter_entity1_id = request->facilities[y].
           code_value, f.filter_entity2_name = null,
           f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
           f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
           f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
           f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm =
           cnvtdatetime("31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
           f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
           .updt_applctx = reqinfo->updt_applctx,
           f.updt_cnt = 0
          PLAN (f)
          WITH nocounter
         ;end insert
         CALL bederrorcheck("ENS_OS_ERROR_11")
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
    SET cs_cnt = size(request->caresets,5)
    SET eg_cd = 0.0
    FOR (z = 1 TO cs_cnt)
      SET os_id = 0.0
      SELECT INTO "nl:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        os_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET lt_id = 0.0
      IF ((request->comment.action_flag=1))
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         lt_id = cnvtreal(j)
        WITH format, counter
       ;end select
      ENDIF
      SET catalog_cd = 0.0
      SET format_id = 0.0
      SELECT INTO "nl:"
       FROM order_catalog_synonym o
       PLAN (o
        WHERE (o.synonym_id=request->synonym_id))
       DETAIL
        catalog_cd = o.catalog_cd, format_id = o.oe_format_id
       WITH nocounter
      ;end select
      UPDATE  FROM cs_component c
       SET c.order_sentence_id = os_id, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1)
       PLAN (c
        WHERE (c.catalog_cd=request->caresets[z].code_value)
         AND (c.comp_id=request->synonym_id)
         AND (c.comp_seq=request->caresets[z].comp_seq))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ENS_OS_ERROR_12")
      INSERT  FROM order_sentence o
       SET o.order_sentence_id = os_id, o.order_sentence_display_line = substring(1,255,
         order_sentence), o.oe_format_id = format_id,
        o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
        reqinfo->updt_task,
        o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = request->usage_flag,
        o.order_encntr_group_cd = eg_cd, o.ord_comment_long_text_id = lt_id, o.parent_entity_name =
        "ORDER_CATALOG_SYNONYM",
        o.parent_entity_id = request->synonym_id, o.parent_entity2_name = "ORDER_CATALOG", o
        .parent_entity2_id = request->caresets[z].code_value,
        o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
       PLAN (o)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ENS_OS_ERROR_13")
      FOR (x = 1 TO size(request->fields,5))
        SET oe_field_meaning_id = 0.0
        DECLARE default_name = vc
        SET default_id = 0.0
        SELECT INTO "nl:"
         FROM order_entry_fields o
         PLAN (o
          WHERE (o.oe_field_id=request->fields[x].oe_field_id))
         DETAIL
          oe_field_meaning_id = o.oe_field_meaning_id
         WITH nocounter
        ;end select
        IF ((request->fields[x].field_type_flag IN (0, 1, 2, 3, 5,
        7, 11, 14, 15)))
         SET default_name = " "
         SET default_id = 0
        ELSEIF ((request->fields[x].field_type_flag IN (6, 9)))
         SET default_name = "CODE_VALUE"
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag=12))
         IF (oe_field_meaning_id=48)
          SET default__name = "RESEARCH_ACCOUNT"
         ELSEIF (oe_field_meaning_id=123)
          SET default_name = "SCH_BOOK_INSTR"
         ELSE
          SET default_name = "CODE_VALUE"
         ENDIF
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag IN (8, 13)))
         SET default_name = "PERSON"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ELSEIF ((request->fields[x].field_type_flag=10))
         SET default_name = "NOMENCLATURE"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ENDIF
        INSERT  FROM order_sentence_detail o
         SET o.order_sentence_id = os_id, o.sequence = x, o.oe_field_value = request->fields[x].
          field_value,
          o.oe_field_id = request->fields[x].oe_field_id, o.oe_field_display_value = request->fields[
          x].value, o.oe_field_meaning_id = oe_field_meaning_id,
          o.field_type_flag = request->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o
          .updt_dt_tm = cnvtdatetime(curdate,curtime),
          o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
          o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_14")
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
         l.long_text = request->comment.text
        PLAN (l)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ENS_OS_ERROR_15")
      ENDIF
    ENDFOR
   ELSEIF ((request->action_flag IN (0, 2)))
    SET reply->sentence_id = request->sentence_id
    RECORD temp(
      1 qual[*]
        2 id = f8
        2 lt_id = f8
    )
    SET scnt = 0
    IF ((request->standalone_ind=1))
     SELECT INTO "nl:"
      FROM ord_cat_sent_r r,
       order_sentence s
      PLAN (r
       WHERE (r.order_sentence_id=request->sentence_id))
       JOIN (s
       WHERE s.order_sentence_id=r.order_sentence_id)
      HEAD s.order_sentence_id
       scnt = (scnt+ 1), stat = alterlist(temp->qual,scnt), temp->qual[scnt].id = s.order_sentence_id,
       temp->qual[scnt].lt_id = s.ord_comment_long_text_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM order_sentence s
      PLAN (s
       WHERE (s.order_sentence_id=request->sentence_id))
      HEAD s.order_sentence_id
       scnt = (scnt+ 1), stat = alterlist(temp->qual,scnt), temp->qual[scnt].id = s.order_sentence_id,
       temp->qual[scnt].lt_id = s.ord_comment_long_text_id
      WITH nocounter
     ;end select
    ENDIF
    IF (scnt=0)
     GO TO exit_script
    ENDIF
    IF ((request->comment.action_flag=1))
     FOR (x = 1 TO scnt)
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         temp->qual[x].lt_id = cnvtreal(j)
        WITH format, counter
       ;end select
     ENDFOR
    ENDIF
    IF ((request->action_flag IN (0, 2)))
     DECLARE order_sentence = vc
     IF (size(request->fields,5) > 0)
      IF ((request->fields[1].value > " "))
       SET format_id = 0.0
       SELECT INTO "nl:"
        FROM order_catalog_synonym o
        PLAN (o
         WHERE (o.synonym_id=request->synonym_id))
        DETAIL
         format_id = o.oe_format_id
        WITH nocounter
       ;end select
       DECLARE os_value = vc
       SET order_sentence = ""
       FOR (x = 1 TO size(request->fields,5))
         IF ((request->fields[x].field_type_flag=7))
          IF ((request->fields[x].value IN ("YES", "1")))
           SET request->fields[x].value = "Yes"
          ENDIF
          IF ((request->fields[x].value IN ("NO", "0")))
           SET request->fields[x].value = "No"
          ENDIF
         ENDIF
         SET os_value = ""
         IF ((request->usage_flag=2))
          SELECT INTO "nl:"
           FROM oe_format_fields o
           PLAN (o
            WHERE o.oe_format_id=format_id
             AND (o.oe_field_id=request->fields[x].oe_field_id)
             AND o.action_type_cd=disorder_cd)
           DETAIL
            IF (o.clin_line_ind > 0)
             os_value = request->fields[x].value
             IF ((request->fields[x].field_type_flag=7))
              os_value = ""
              IF ((request->fields[x].value="No"))
               IF (o.disp_yes_no_flag IN (0, 2))
                os_value = o.clin_line_label
               ELSE
                os_value = ""
               ENDIF
              ELSE
               IF (o.disp_yes_no_flag=2)
                os_value = ""
               ELSE
                os_value = o.label_text
               ENDIF
              ENDIF
             ELSE
              IF (o.clin_line_label > " ")
               IF (o.clin_suffix_ind=1)
                os_value = concat(trim(request->fields[x].value)," ",trim(o.clin_line_label))
               ELSE
                os_value = concat(trim(o.clin_line_label)," ",trim(request->fields[x].value))
               ENDIF
              ENDIF
             ENDIF
            ENDIF
           WITH nocounter
          ;end select
         ELSE
          SELECT INTO "nl:"
           FROM oe_format_fields o
           PLAN (o
            WHERE o.oe_format_id=format_id
             AND (o.oe_field_id=request->fields[x].oe_field_id)
             AND o.action_type_cd=order_cd)
           DETAIL
            IF (o.clin_line_ind > 0)
             os_value = request->fields[x].value
             IF ((request->fields[x].field_type_flag=7))
              os_value = ""
              IF ((request->fields[x].value="No"))
               IF (o.disp_yes_no_flag IN (0, 2))
                os_value = o.clin_line_label
               ELSE
                os_value = ""
               ENDIF
              ELSE
               IF (o.disp_yes_no_flag=2)
                os_value = ""
               ELSE
                os_value = o.label_text
               ENDIF
              ENDIF
             ELSE
              IF (o.clin_line_label > " ")
               IF (o.clin_suffix_ind=1)
                os_value = concat(trim(request->fields[x].value)," ",trim(o.clin_line_label))
               ELSE
                os_value = concat(trim(o.clin_line_label)," ",trim(request->fields[x].value))
               ENDIF
              ENDIF
             ENDIF
            ENDIF
           WITH nocounter
          ;end select
         ENDIF
         IF ( NOT (order_sentence > " "))
          IF (os_value > " ")
           SET order_sentence = trim(os_value)
           SET gseq = request->fields[x].group_seq
          ENDIF
         ELSE
          IF (os_value > " ")
           IF ((gseq=request->fields[x].group_seq))
            SET order_sentence = concat(trim(order_sentence)," ",trim(os_value))
           ELSE
            SET order_sentence = concat(trim(order_sentence),", ",trim(os_value))
            SET gseq = request->fields[x].group_seq
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET reply->display_line = order_sentence
      ENDIF
     ENDIF
     IF ((request->action_flag=2))
      IF ((request->standalone_ind=1))
       UPDATE  FROM ord_cat_sent_r o,
         (dummyt d  WITH seq = value(scnt))
        SET o.order_sentence_disp_line = substring(1,255,order_sentence), o.updt_id = reqinfo->
         updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime),
         o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
         .updt_cnt+ 1)
        PLAN (d)
         JOIN (o
         WHERE (o.order_sentence_id=temp->qual[d.seq].id))
        WITH nocounter
       ;end update
       CALL bederrorcheck("ENS_OS_ERROR_16")
      ENDIF
      UPDATE  FROM order_sentence o,
        (dummyt d  WITH seq = value(scnt))
       SET o.order_sentence_display_line = substring(1,255,order_sentence), o.usage_flag = request->
        usage_flag, o.ord_comment_long_text_id = temp->qual[d.seq].lt_id,
        o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
        reqinfo->updt_task,
        o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1)
       PLAN (d)
        JOIN (o
        WHERE (o.order_sentence_id=temp->qual[d.seq].id))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ENS_OS_ERROR_17")
      SET filtersize = size(request->filters,5)
      IF (filtersize > 0)
       SET row_exists = 0
       SELECT INTO "nl:"
        FROM order_sentence_filter f,
         (dummyt d  WITH seq = value(filtersize))
        PLAN (d)
         JOIN (f
         WHERE (f.order_sentence_id=temp->qual[d.seq].id))
        DETAIL
         row_exists = 1
        WITH nocounter
       ;end select
       CALL bederrorcheck("ENS_OS_ERROR_51")
       IF (row_exists=1)
        UPDATE  FROM order_sentence_filter f,
          (dummyt d  WITH seq = value(filtersize))
         SET f.age_max_value = request->filters[d.seq].age_max_value, f.age_min_value = request->
          filters[d.seq].age_min_value, f.age_unit_cd = request->filters[d.seq].age_code_value,
          f.pma_max_value = request->filters[d.seq].pma_max_value, f.pma_min_value = request->
          filters[d.seq].pma_min_value, f.pma_unit_cd = request->filters[d.seq].pma_code_value,
          f.weight_max_value = request->filters[d.seq].weight_max_value, f.weight_min_value = request
          ->filters[d.seq].weight_min_value, f.weight_unit_cd = request->filters[d.seq].
          weight_code_value,
          f.updt_id = reqinfo->updt_id, f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task =
          reqinfo->updt_task,
          f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = (f.updt_cnt+ 1)
         PLAN (d
          WHERE (request->filters[d.seq].order_sentence_filter_id > 0))
          JOIN (f
          WHERE (f.order_sentence_filter_id=request->filters[d.seq].order_sentence_filter_id))
         WITH nocounter
        ;end update
        CALL bederrorcheck("ENS_OS_FILTER_ERR_3")
        SET index = 1
        DELETE  FROM order_sentence_filter f
         SET f.seq = 1
         PLAN (f
          WHERE expand(index,1,filtersize,f.order_sentence_filter_id,request->filters[index].
           order_sentence_filter_id)
           AND (request->filters[index].order_sentence_filter_id > 0.0)
           AND (request->filters[index].age_code_value=0.0)
           AND (request->filters[index].pma_code_value=0.0)
           AND (request->filters[index].weight_code_value=0.0))
         WITH nocounter
        ;end delete
        CALL replyfilteradd(filtersize)
        CALL bederrorcheck("DELETE_OS_FILTER_ERR_3")
       ELSE
        SET stat = alterlist(new_filter_ids->filter_ids,filtersize)
        FOR (x = 1 TO filtersize)
         SELECT INTO "nl:"
          j = seq(reference_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_filter_ids->filter_ids[x].filter_id = cnvtreal(j)
          WITH format, counter
         ;end select
         CALL bederrorcheck("ID_GENERATE_3")
        ENDFOR
        INSERT  FROM order_sentence_filter f,
          (dummyt d  WITH seq = value(filtersize))
         SET f.order_sentence_filter_id = new_filter_ids->filter_ids[d.seq].filter_id, f
          .age_max_value = request->filters[d.seq].age_max_value, f.age_min_value = request->filters[
          d.seq].age_min_value,
          f.age_unit_cd = request->filters[d.seq].age_code_value, f.order_sentence_id = temp->qual[d
          .seq].id, f.pma_max_value = request->filters[d.seq].pma_max_value,
          f.pma_min_value = request->filters[d.seq].pma_min_value, f.pma_unit_cd = request->filters[d
          .seq].pma_code_value, f.weight_max_value = request->filters[d.seq].weight_max_value,
          f.weight_min_value = request->filters[d.seq].weight_min_value, f.weight_unit_cd = request->
          filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
          f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
          .updt_applctx = reqinfo->updt_applctx,
          f.updt_cnt = 0
         PLAN (d
          WHERE (((request->filters[d.seq].age_code_value > 0)) OR ((((request->filters[d.seq].
          pma_code_value > 0)) OR ((request->filters[d.seq].weight_code_value > 0))) )) )
          JOIN (f)
         WITH nocounter
        ;end insert
        CALL replyfilteradd(filtersize)
        CALL bederrorcheck("ENS_OS_FILTER_ERR_8")
       ENDIF
      ENDIF
      DELETE  FROM order_sentence_detail o,
        (dummyt d  WITH seq = value(scnt))
       SET o.seq = 1
       PLAN (d)
        JOIN (o
        WHERE (o.order_sentence_id=temp->qual[d.seq].id))
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_18")
      FOR (x = 1 TO size(request->fields,5))
        SET oe_field_meaning_id = 0.0
        DECLARE default_name = vc
        SET default_id = 0.0
        SELECT INTO "nl:"
         FROM order_entry_fields o
         PLAN (o
          WHERE (o.oe_field_id=request->fields[x].oe_field_id))
         DETAIL
          oe_field_meaning_id = o.oe_field_meaning_id
         WITH nocounter
        ;end select
        IF ((request->fields[x].field_type_flag IN (0, 1, 2, 3, 5,
        7, 11, 14, 15)))
         SET default_name = " "
         SET default_id = 0
        ELSEIF ((request->fields[x].field_type_flag IN (6, 9)))
         SET default_name = "CODE_VALUE"
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag=12))
         IF (oe_field_meaning_id=48)
          SET default__name = "RESEARCH_ACCOUNT"
         ELSEIF (oe_field_meaning_id=123)
          SET default_name = "SCH_BOOK_INSTR"
         ELSE
          SET default_name = "CODE_VALUE"
         ENDIF
         SET default_id = request->fields[x].code_value
        ELSEIF ((request->fields[x].field_type_flag IN (8, 13)))
         SET default_name = "PERSON"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ELSEIF ((request->fields[x].field_type_flag=10))
         SET default_name = "NOMENCLATURE"
         IF (validate(request->fields[x].parent_entity_id))
          SET default_id = request->fields[x].parent_entity_id
         ENDIF
        ENDIF
        INSERT  FROM order_sentence_detail o,
          (dummyt d  WITH seq = value(scnt))
         SET o.order_sentence_id = temp->qual[d.seq].id, o.sequence = x, o.oe_field_value = request->
          fields[x].field_value,
          o.oe_field_id = request->fields[x].oe_field_id, o.oe_field_display_value = request->fields[
          x].value, o.oe_field_meaning_id = oe_field_meaning_id,
          o.field_type_flag = request->fields[x].field_type_flag, o.updt_id = reqinfo->updt_id, o
          .updt_dt_tm = cnvtdatetime(curdate,curtime),
          o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
          o.default_parent_entity_name = default_name, o.default_parent_entity_id = default_id
         PLAN (d)
          JOIN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_19")
      ENDFOR
     ENDIF
    ENDIF
    IF ((request->comment.action_flag=1))
     INSERT  FROM long_text l,
       (dummyt d  WITH seq = value(scnt))
      SET l.long_text_id = temp->qual[d.seq].lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
       l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
        curtime),
       l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
       .parent_entity_id = temp->qual[d.seq].id,
       l.long_text = request->comment.text
      PLAN (d)
       JOIN (l)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ENS_OS_ERROR_20")
    ENDIF
    IF ((request->comment.action_flag=2))
     UPDATE  FROM long_text l,
       (dummyt d  WITH seq = value(scnt))
      SET l.long_text = request->comment.text, l.updt_id = reqinfo->updt_id, l.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
       .updt_cnt+ 1)
      PLAN (d)
       JOIN (l
       WHERE (l.long_text_id=temp->qual[d.seq].lt_id)
        AND l.long_text_id > 0)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ENS_OS_ERROR_21")
    ENDIF
    IF ((request->standalone_ind=1))
     IF ((request->all_facility_ind=1))
      DELETE  FROM filter_entity_reltn f,
        (dummyt d  WITH seq = value(scnt))
       SET f.seq = 1
       PLAN (d)
        JOIN (f
        WHERE (f.parent_entity_id=temp->qual[d.seq].id))
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_22")
      INSERT  FROM filter_entity_reltn f,
        (dummyt d  WITH seq = value(scnt))
       SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
        "ORDER_SENTENCE", f.parent_entity_id = temp->qual[d.seq].id,
        f.filter_entity1_name = "LOCATION", f.filter_entity1_id = 0, f.filter_entity2_name = null,
        f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
        f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
        f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
        f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
        f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
        .updt_applctx = reqinfo->updt_applctx,
        f.updt_cnt = 0
       PLAN (d)
        JOIN (f)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ENS_OS_ERROR_23")
     ELSE
      DELETE  FROM filter_entity_reltn f,
        (dummyt d  WITH seq = value(scnt))
       SET f.seq = 1
       PLAN (d)
        JOIN (f
        WHERE (f.parent_entity_id=temp->qual[d.seq].id)
         AND f.filter_entity1_id=0)
       WITH nocounter
      ;end delete
      FOR (x = 1 TO size(request->facilities,5))
       IF ((request->facilities[x].action_flag=1))
        INSERT  FROM filter_entity_reltn f,
          (dummyt d  WITH seq = value(scnt))
         SET f.seq = 1, f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name
           = "ORDER_SENTENCE",
          f.parent_entity_id = temp->qual[d.seq].id, f.filter_entity1_name = "LOCATION", f
          .filter_entity1_id = request->facilities[x].code_value,
          f.filter_entity2_name = null, f.filter_entity2_id = 0, f.filter_entity3_name = null,
          f.filter_entity3_id = 0, f.filter_entity4_name = null, f.filter_entity4_id = 0,
          f.filter_entity5_name = null, f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd,
          f.exclusion_filter_ind = null, f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f
          .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
          f.updt_id = reqinfo->updt_id, f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task =
          reqinfo->updt_task,
          f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = 0
         PLAN (d)
          JOIN (f)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_24")
       ENDIF
       IF ((request->facilities[x].action_flag=3))
        DELETE  FROM filter_entity_reltn f,
          (dummyt d  WITH seq = value(scnt))
         SET f.seq = 1
         PLAN (d)
          JOIN (f
          WHERE (f.parent_entity_id=temp->qual[d.seq].id)
           AND (f.filter_entity1_id=request->facilities[x].code_value))
         WITH nocounter
        ;end delete
        CALL bederrorcheck("ENS_OS_ERROR_25")
       ENDIF
      ENDFOR
     ENDIF
     FOR (x = 1 TO size(request->encntr_groups,5))
       IF (x=1)
        SET catalog_cd = 0.0
        SET format_id = 0.0
        SELECT INTO "nl:"
         FROM order_catalog_synonym o
         PLAN (o
          WHERE (o.synonym_id=request->synonym_id))
         DETAIL
          catalog_cd = o.catalog_cd, format_id = o.oe_format_id
         WITH nocounter
        ;end select
        FREE SET sentence
        RECORD sentence(
          1 id = f8
          1 sentence = vc
          1 usage_flag = i2
          1 ord_comment_long_text_id = f8
          1 text = vc
          1 details[*]
            2 sequence = i4
            2 oe_field_value = f8
            2 oe_field_id = f8
            2 oe_field_display_value = vc
            2 oe_field_meaning_id = f8
            2 field_type_flag = i2
            2 def_parent_name = vc
            2 def_parent_id = f8
          1 facilities[*]
            2 loc_cd = f8
        )
        SELECT INTO "nl:"
         FROM order_sentence s,
          long_text l
         PLAN (s
          WHERE (s.order_sentence_id=request->sentence_id))
          JOIN (l
          WHERE l.long_text_id=s.ord_comment_long_text_id)
         DETAIL
          sentence->id = s.order_sentence_id, sentence->sentence = s.order_sentence_display_line,
          sentence->usage_flag = s.usage_flag,
          sentence->ord_comment_long_text_id = s.ord_comment_long_text_id, sentence->text = l
          .long_text
         WITH nocounter
        ;end select
        SET dcnt = 0
        SELECT INTO "nl:"
         FROM order_sentence_detail s
         PLAN (s
          WHERE (s.order_sentence_id=sentence->id))
         DETAIL
          dcnt = (dcnt+ 1), stat = alterlist(sentence->details,dcnt), sentence->details[dcnt].
          sequence = s.sequence,
          sentence->details[dcnt].oe_field_value = s.oe_field_value, sentence->details[dcnt].
          oe_field_id = s.oe_field_id, sentence->details[dcnt].oe_field_display_value = s
          .oe_field_display_value,
          sentence->details[dcnt].oe_field_meaning_id = s.oe_field_meaning_id, sentence->details[dcnt
          ].field_type_flag = s.field_type_flag, sentence->details[dcnt].def_parent_name = s
          .default_parent_entity_name,
          sentence->details[dcnt].def_parent_id = s.default_parent_entity_id
         WITH nocounter
        ;end select
        SET fcnt = 0
        SELECT INTO "nl:"
         FROM filter_entity_reltn f
         PLAN (f
          WHERE (f.parent_entity_id=sentence->id))
         DETAIL
          fcnt = (fcnt+ 1), stat = alterlist(sentence->facilities,fcnt), sentence->facilities[fcnt].
          loc_cd = f.filter_entity1_id
         WITH nocounter
        ;end select
       ENDIF
       IF ((request->encntr_groups[x].action_flag=1))
        SET os_id = 0.0
        SELECT INTO "nl:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          os_id = cnvtreal(j)
         WITH format, counter
        ;end select
        SET lt_id = 0.0
        IF ((sentence->ord_comment_long_text_id > 0))
         SELECT INTO "nl:"
          j = seq(long_data_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           lt_id = cnvtreal(j)
          WITH format, counter
         ;end select
        ENDIF
        INSERT  FROM ord_cat_sent_r o
         SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = os_id, o
          .order_sentence_disp_line = substring(1,255,sentence->sentence),
          o.catalog_cd = catalog_cd, o.synonym_id = request->synonym_id, o.active_ind = 1,
          o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
          reqinfo->updt_task,
          o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq = null
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_26")
        INSERT  FROM order_sentence o
         SET o.order_sentence_id = os_id, o.order_sentence_display_line = substring(1,255,sentence->
           sentence), o.oe_format_id = format_id,
          o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
          reqinfo->updt_task,
          o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = sentence->usage_flag,
          o.order_encntr_group_cd = request->encntr_groups[x].code_value, o.ord_comment_long_text_id
           = lt_id, o.parent_entity_name = "ORDER_CATALOG_SYNONYM",
          o.parent_entity_id = request->synonym_id, o.parent_entity2_name = null, o.parent_entity2_id
           = 0,
          o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
         PLAN (o)
         WITH nocounter
        ;end insert
        CALL bederrorcheck("ENS_OS_ERROR_27")
        SET filtersize = size(request->filters,5)
        IF (filtersize > 0)
         SET stat = alterlist(new_filter_ids->filter_ids,filtersize)
         FOR (x = 1 TO filtersize)
          SELECT INTO "nl:"
           j = seq(reference_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            new_filter_ids->filter_ids[x].filter_id = cnvtreal(j)
           WITH format, counter
          ;end select
          CALL bederrorcheck("ID_GENERATE_2")
         ENDFOR
         INSERT  FROM order_sentence_filter f,
           (dummyt d  WITH seq = value(filtersize))
          SET f.order_sentence_filter_id = new_filter_ids->filter_ids[d.seq].filter_id, f
           .age_max_value = request->filters[d.seq].age_max_value, f.age_min_value = request->
           filters[d.seq].age_min_value,
           f.age_unit_cd = request->filters[d.seq].age_code_value, f.order_sentence_id = os_id, f
           .pma_max_value = request->filters[d.seq].pma_max_value,
           f.pma_min_value = request->filters[d.seq].pma_min_value, f.pma_unit_cd = request->filters[
           d.seq].pma_code_value, f.weight_max_value = request->filters[d.seq].weight_max_value,
           f.weight_min_value = request->filters[d.seq].weight_min_value, f.weight_unit_cd = request
           ->filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
           f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
           .updt_applctx = reqinfo->updt_applctx,
           f.updt_cnt = 0
          PLAN (d
           WHERE (request->filters[d.seq].order_sentence_filter_id=0)
            AND (((request->filters[d.seq].age_code_value > 0)) OR ((((request->filters[d.seq].
           pma_code_value > 0)) OR ((request->filters[d.seq].weight_code_value > 0))) )) )
           JOIN (f)
          WITH nocounter
         ;end insert
         CALL replyfilteradd(filtersize)
         CALL bederrorcheck("ENS_OS_FILTER_ERR_4")
        ENDIF
        FOR (z = 1 TO size(sentence->details,5))
         INSERT  FROM order_sentence_detail o
          SET o.order_sentence_id = os_id, o.sequence = sentence->details[z].sequence, o
           .oe_field_value = sentence->details[z].oe_field_value,
           o.oe_field_id = sentence->details[z].oe_field_id, o.oe_field_display_value = sentence->
           details[z].oe_field_display_value, o.oe_field_meaning_id = sentence->details[z].
           oe_field_meaning_id,
           o.field_type_flag = sentence->details[z].field_type_flag, o.updt_id = reqinfo->updt_id, o
           .updt_dt_tm = cnvtdatetime(curdate,curtime),
           o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
           o.default_parent_entity_name = sentence->details[z].def_parent_name, o
           .default_parent_entity_id = sentence->details[z].def_parent_id
          PLAN (o)
          WITH nocounter
         ;end insert
         CALL bederrorcheck("ENS_OS_ERROR_28")
        ENDFOR
        IF (lt_id > 0)
         INSERT  FROM long_text l
          SET l.long_text_id = lt_id, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(
            curdate,curtime),
           l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
           l.active_ind = 1, l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(
            curdate,curtime),
           l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
           .parent_entity_id = os_id,
           l.long_text = sentence->text
          PLAN (l)
          WITH nocounter
         ;end insert
         CALL bederrorcheck("ENS_OS_ERROR_29")
        ENDIF
        FOR (z = 1 TO size(sentence->facilities,5))
         INSERT  FROM filter_entity_reltn f
          SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
           "ORDER_SENTENCE", f.parent_entity_id = os_id,
           f.filter_entity1_name = "LOCATION", f.filter_entity1_id = sentence->facilities[z].loc_cd,
           f.filter_entity2_name = null,
           f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
           f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
           f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
           f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm =
           cnvtdatetime("31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
           f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f
           .updt_applctx = reqinfo->updt_applctx,
           f.updt_cnt = 0
          PLAN (f)
          WITH nocounter
         ;end insert
         CALL bederrorcheck("ENS_OS_ERROR_30")
        ENDFOR
       ENDIF
       IF ((request->encntr_groups[x].action_flag=3))
        FOR (y = 1 TO scnt)
          SET sentence_id = 0.0
          SELECT INTO "nl:"
           FROM order_sentence s
           PLAN (s
            WHERE (s.order_sentence_id=temp->qual[y].id)
             AND ((s.order_encntr_group_cd+ 0)=request->encntr_groups[x].code_value))
           DETAIL
            sentence_id = s.order_sentence_id
           WITH nocounter
          ;end select
          IF (sentence_id > 0)
           DELETE  FROM filter_entity_reltn f
            PLAN (f
             WHERE f.parent_entity_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_ERROR_31")
           DELETE  FROM long_text l
            PLAN (l
             WHERE l.parent_entity_name="ORDER_SENTENCE"
              AND l.parent_entity_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_ERROR_32")
           DELETE  FROM order_sentence_detail o
            PLAN (o
             WHERE o.order_sentence_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_ERROR_33")
           DELETE  FROM order_sentence_filter f
            PLAN (f
             WHERE f.order_sentence_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_FILTER_ERR_5")
           DELETE  FROM order_sentence o
            PLAN (o
             WHERE o.order_sentence_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_ERROR_34")
           DELETE  FROM ord_cat_sent_r o
            PLAN (o
             WHERE o.order_sentence_id=sentence_id)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("ENS_OS_ERROR_35")
          ENDIF
        ENDFOR
       ENDIF
       SELECT INTO "nl:"
        FROM ord_cat_sent_r r
        PLAN (r
         WHERE (r.synonym_id=request->synonym_id)
          AND (r.order_sentence_disp_line=sentence->sentence))
        DETAIL
         reply->sentence_id = r.order_sentence_id
        WITH nocounter
       ;end select
     ENDFOR
    ENDIF
    FOR (x = 1 TO size(request->caresets,5))
     IF ((request->caresets[x].action_flag=1))
      SET catalog_cd = 0.0
      SET format_id = 0.0
      SELECT INTO "nl:"
       FROM order_catalog_synonym o
       PLAN (o
        WHERE (o.synonym_id=request->synonym_id))
       DETAIL
        catalog_cd = o.catalog_cd, format_id = o.oe_format_id
       WITH nocounter
      ;end select
      FREE SET sentence
      RECORD sentence(
        1 id = f8
        1 sentence = vc
        1 usage_flag = i2
        1 ord_comment_long_text_id = f8
        1 text = vc
        1 details[*]
          2 sequence = i4
          2 oe_field_value = f8
          2 oe_field_id = f8
          2 oe_field_display_value = vc
          2 oe_field_meaning_id = f8
          2 field_type_flag = i2
          2 def_parent_name = vc
          2 def_parent_id = f8
      )
      SELECT INTO "nl:"
       FROM order_sentence s,
        long_text l
       PLAN (s
        WHERE (s.order_sentence_id=request->sentence_id))
        JOIN (l
        WHERE l.long_text_id=s.ord_comment_long_text_id)
       DETAIL
        sentence->id = s.order_sentence_id, sentence->sentence = s.order_sentence_display_line,
        sentence->usage_flag = s.usage_flag,
        sentence->ord_comment_long_text_id = s.ord_comment_long_text_id, sentence->text = l.long_text
       WITH nocounter
      ;end select
      SET dcnt = 0
      SELECT INTO "nl:"
       FROM order_sentence_detail s
       PLAN (s
        WHERE (s.order_sentence_id=sentence->id))
       DETAIL
        dcnt = (dcnt+ 1), stat = alterlist(sentence->details,dcnt), sentence->details[dcnt].sequence
         = s.sequence,
        sentence->details[dcnt].oe_field_value = s.oe_field_value, sentence->details[dcnt].
        oe_field_id = s.oe_field_id, sentence->details[dcnt].oe_field_display_value = s
        .oe_field_display_value,
        sentence->details[dcnt].oe_field_meaning_id = s.oe_field_meaning_id, sentence->details[dcnt].
        field_type_flag = s.field_type_flag, sentence->details[dcnt].def_parent_name = s
        .default_parent_entity_name,
        sentence->details[dcnt].def_parent_id = s.default_parent_entity_id
       WITH nocounter
      ;end select
      SET os_id = 0.0
      SELECT INTO "nl:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        os_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET lt_id = 0.0
      IF ((sentence->ord_comment_long_text_id > 0))
       SELECT INTO "nl:"
        j = seq(long_data_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         lt_id = cnvtreal(j)
        WITH format, counter
       ;end select
      ENDIF
      UPDATE  FROM cs_component c
       SET c.order_sentence_id = os_id, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1)
       PLAN (c
        WHERE (c.catalog_cd=request->caresets[x].code_value)
         AND (c.comp_id=request->synonym_id)
         AND (c.comp_seq=request->caresets[x].comp_seq))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ENS_OS_ERROR_36")
      INSERT  FROM order_sentence o
       SET o.order_sentence_id = os_id, o.order_sentence_display_line = substring(1,255,sentence->
         sentence), o.oe_format_id = format_id,
        o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
        reqinfo->updt_task,
        o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = sentence->usage_flag,
        o.order_encntr_group_cd = 0, o.ord_comment_long_text_id = lt_id, o.parent_entity_name =
        "ORDER_CATALOG_SYNONYM",
        o.parent_entity_id = request->synonym_id, o.parent_entity2_name = "ORDER_CATALOG", o
        .parent_entity2_id = request->caresets[x].code_value,
        o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = null
       PLAN (o)
       WITH nocounter
      ;end insert
      CALL bederrorcheck("ENS_OS_ERROR_37")
      FOR (z = 1 TO size(sentence->details,5))
       INSERT  FROM order_sentence_detail o
        SET o.order_sentence_id = os_id, o.sequence = sentence->details[z].sequence, o.oe_field_value
          = sentence->details[z].oe_field_value,
         o.oe_field_id = sentence->details[z].oe_field_id, o.oe_field_display_value = sentence->
         details[z].oe_field_display_value, o.oe_field_meaning_id = sentence->details[z].
         oe_field_meaning_id,
         o.field_type_flag = sentence->details[z].field_type_flag, o.updt_id = reqinfo->updt_id, o
         .updt_dt_tm = cnvtdatetime(curdate,curtime),
         o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
         o.default_parent_entity_name = sentence->details[z].def_parent_name, o
         .default_parent_entity_id = sentence->details[z].def_parent_id
        PLAN (o)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ENS_OS_ERROR_38")
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
         l.long_text = sentence->text
        PLAN (l)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("ENS_OS_ERROR_39")
      ENDIF
     ENDIF
     IF ((request->caresets[x].action_flag=3))
      UPDATE  FROM cs_component c
       SET c.order_sentence_id = 0, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1)
       PLAN (c
        WHERE (c.catalog_cd=request->caresets[x].code_value)
         AND (c.comp_id=request->synonym_id)
         AND (c.comp_seq=request->caresets[x].comp_seq))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ENS_OS_ERROR_40")
     ENDIF
    ENDFOR
   ELSEIF ((request->action_flag=3))
    RECORD temp(
      1 qual[*]
        2 id = f8
        2 lt_id = f8
    )
    SET scnt = 0
    IF ((request->standalone_ind=1))
     SELECT INTO "nl:"
      FROM ord_cat_sent_r r,
       order_sentence s
      PLAN (r
       WHERE (r.order_sentence_id=request->sentence_id))
       JOIN (s
       WHERE s.order_sentence_id=r.order_sentence_id)
      HEAD s.order_sentence_id
       scnt = (scnt+ 1), stat = alterlist(temp->qual,scnt), temp->qual[scnt].id = s.order_sentence_id,
       temp->qual[scnt].lt_id = s.ord_comment_long_text_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM order_sentence s
      PLAN (s
       WHERE (s.order_sentence_id=request->sentence_id))
      HEAD s.order_sentence_id
       scnt = (scnt+ 1), stat = alterlist(temp->qual,scnt), temp->qual[scnt].id = s.order_sentence_id,
       temp->qual[scnt].lt_id = s.ord_comment_long_text_id
      WITH nocounter
     ;end select
    ENDIF
    IF (scnt=0)
     GO TO exit_script
    ENDIF
    IF ((request->standalone_ind=1))
     DELETE  FROM filter_entity_reltn f,
       (dummyt d  WITH seq = value(scnt))
      SET f.seq = 1
      PLAN (d)
       JOIN (f
       WHERE (f.parent_entity_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_ERROR_41")
     DELETE  FROM long_text l,
       (dummyt d  WITH seq = value(scnt))
      SET l.seq = 1
      PLAN (d)
       JOIN (l
       WHERE l.parent_entity_name="ORDER_SENTENCE"
        AND (l.parent_entity_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_ERROR_42")
     DELETE  FROM order_sentence_detail o,
       (dummyt d  WITH seq = value(scnt))
      SET o.seq = 1
      PLAN (d)
       JOIN (o
       WHERE (o.order_sentence_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_ERROR_43")
     DELETE  FROM order_sentence_filter f,
       (dummyt d  WITH seq = value(scnt))
      SET f.seq = 1
      PLAN (d)
       JOIN (f
       WHERE (f.order_sentence_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_FILTER_ERR_6")
     DELETE  FROM order_sentence o,
       (dummyt d  WITH seq = value(scnt))
      SET o.seq = 1
      PLAN (d)
       JOIN (o
       WHERE (o.order_sentence_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_ERROR_44")
     DELETE  FROM ord_cat_sent_r o,
       (dummyt d  WITH seq = value(scnt))
      SET o.seq = 1
      PLAN (d)
       JOIN (o
       WHERE (o.order_sentence_id=temp->qual[d.seq].id))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("ENS_OS_ERROR_45")
    ELSE
     IF ((request->sentence_id > 0))
      SET sentence_id = request->sentence_id
      DELETE  FROM filter_entity_reltn f
       PLAN (f
        WHERE f.parent_entity_id=sentence_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_46")
      DELETE  FROM long_text l
       PLAN (l
        WHERE l.parent_entity_name="ORDER_SENTENCE"
         AND l.parent_entity_id=sentence_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_47")
      DELETE  FROM order_sentence_detail o
       PLAN (o
        WHERE o.order_sentence_id=sentence_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_48")
      DELETE  FROM order_sentence_filter f
       PLAN (f
        WHERE f.order_sentence_id=sentence_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_FILTER_ERR_7")
      DELETE  FROM order_sentence o
       PLAN (o
        WHERE o.order_sentence_id=sentence_id)
       WITH nocounter
      ;end delete
      CALL bederrorcheck("ENS_OS_ERROR_49")
      UPDATE  FROM cs_component c
       SET c.order_sentence_id = 0, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
        .updt_cnt+ 1)
       PLAN (c
        WHERE (c.catalog_cd=request->careset_catalog_code_value)
         AND (c.comp_id=request->synonym_id)
         AND (c.comp_seq=request->comp_seq))
       WITH nocounter
      ;end update
      CALL bederrorcheck("ENS_OS_ERROR_50")
     ENDIF
    ENDIF
   ENDIF
   IF ((request->synonym_id > 0))
    SET sent_id = 0.0
    SET mcnt = 0
    SET mult_ind = 0
    SET ocs_sent_id = 0.0
    SELECT INTO "nl:"
     FROM ord_cat_sent_r o
     PLAN (o
      WHERE (o.synonym_id=request->synonym_id))
     DETAIL
      mcnt = (mcnt+ 1), sent_id = o.order_sentence_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs
     WHERE (ocs.synonym_id=request->synonym_id)
     DETAIL
      mult_ind = ocs.multiple_ord_sent_ind, ocs_sent_id = ocs.order_sentence_id
     WITH nocounter
    ;end select
    IF (mcnt=0)
     IF (((mult_ind > 0) OR (ocs_sent_id > 0)) )
      UPDATE  FROM order_catalog_synonym o
       SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o
        .updt_applctx = reqinfo->updt_applctx,
        o.updt_cnt = (o.updt_cnt+ 1)
       PLAN (o
        WHERE (o.synonym_id=request->synonym_id))
       WITH nocounter
      ;end update
     ENDIF
    ELSEIF (mcnt=1)
     IF (((ocs_sent_id != sent_id) OR (mult_ind=1)) )
      UPDATE  FROM order_catalog_synonym o
       SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = sent_id, o.updt_id = reqinfo->updt_id,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o
        .updt_applctx = reqinfo->updt_applctx,
        o.updt_cnt = (o.updt_cnt+ 1)
       PLAN (o
        WHERE (o.synonym_id=request->synonym_id))
       WITH nocounter
      ;end update
     ENDIF
    ELSE
     IF (((ocs_sent_id > 0) OR (mult_ind=0)) )
      UPDATE  FROM order_catalog_synonym o
       SET o.multiple_ord_sent_ind = 1, o.order_sentence_id = 0, o.updt_id = reqinfo->updt_id,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o
        .updt_applctx = reqinfo->updt_applctx,
        o.updt_cnt = (o.updt_cnt+ 1)
       PLAN (o
        WHERE (o.synonym_id=request->synonym_id))
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
   ENDIF
#exit_script
   CALL bedexitscript(1)
 END ;Subroutine
 SUBROUTINE replyfilteradd(filterlistsize)
  SET stat = alterlist(reply->filters,filtersize)
  FOR (x = 1 TO filterlistsize)
    SET reply->filters[x].order_sentence_filter_id = new_filter_ids->filter_ids[x].filter_id
    SET reply->filters[x].age_max_value = request->filters[x].age_max_value
    SET reply->filters[x].age_min_value = request->filters[x].age_min_value
    SET reply->filters[x].age_unit_cd.code_value = request->filters[x].age_code_value
    SELECT INTO "nl:"
     FROM code_value cv_age
     WHERE (cv_age.code_value=request->filters[x].age_code_value)
     DETAIL
      reply->filters[x].age_unit_cd.display = cv_age.display, reply->filters[x].age_unit_cd.mean =
      cv_age.cdf_meaning, reply->filters[x].age_unit_cd.description = cv_age.description
     WITH nocounter
    ;end select
    SET reply->filters[x].pma_max_value = request->filters[x].pma_max_value
    SET reply->filters[x].pma_min_value = request->filters[x].pma_min_value
    SET reply->filters[x].pma_unit_cd.code_value = request->filters[x].pma_code_value
    SELECT INTO "nl:"
     FROM code_value cv_pma
     WHERE (cv_pma.code_value=request->filters[x].pma_code_value)
     DETAIL
      reply->filters[x].pma_unit_cd.display = cv_pma.display, reply->filters[x].pma_unit_cd.mean =
      cv_pma.cdf_meaning, reply->filters[x].pma_unit_cd.description = cv_pma.description
     WITH nocounter
    ;end select
    SET reply->filters[x].weight_max_value = request->filters[x].weight_max_value
    SET reply->filters[x].weight_min_value = request->filters[x].weight_min_value
    SET reply->filters[x].weight_unit_cd.code_value = request->filters[x].weight_code_value
    SELECT INTO "nl:"
     FROM code_value cv_weight
     WHERE (cv_weight.code_value=request->filters[x].weight_code_value)
     DETAIL
      reply->filters[x].weight_unit_cd.display = cv_weight.display, reply->filters[x].weight_unit_cd.
      mean = cv_weight.cdf_meaning, reply->filters[x].weight_unit_cd.description = cv_weight
      .description
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
END GO
