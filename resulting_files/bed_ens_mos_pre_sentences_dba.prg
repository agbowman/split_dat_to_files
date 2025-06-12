CREATE PROGRAM bed_ens_mos_pre_sentences:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 sentence_id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET fields
 RECORD fields(
   1 fields[*]
     2 oe_field_id = f8
     2 field_disp_value = vc
     2 field_code_value = f8
     2 seq = i4
     2 field_type_flag = i2
     2 dname = vc
     2 dvalue = f8
     2 meaning_id = f8
     2 sent_id = f8
     2 parent_entity_id = f8
 )
 FREE SET upd_ocs
 RECORD upd_ocs(
   1 syns[*]
     2 synonym_id = f8
     2 mul_sent_ind = i2
     2 order_sent_id = f8
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
 SET req_cnt = size(request->sentences,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE filtersize = i4 WITH protect, noconstant(0)
 DECLARE deletefiltersforsentence(sentenceid=f8) = i2
 SET active_code = 0.0
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET ordsent_code = 0.0
 SET ordsent_code = uar_get_code_by("MEANING",30620,"ORDERSENT")
 SET stat = alterlist(reply->sentences,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->sentences[x].sentence_id = request->sentences[x].sentence_id
   SET reply->sentences[x].display = request->sentences[x].display
   IF ((request->sentences[x].ext_identifier="MUL.OP*"))
    SET request->sentences[x].ext_identifier = concat("BR",request->sentences[x].ext_identifier)
   ENDIF
 ENDFOR
 DELETE  FROM long_text l,
   (dummyt d  WITH seq = value(req_cnt))
  SET l.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].comment.action_flag=3))
   JOIN (l
   WHERE l.parent_entity_name="ORDER_SENTENCE"
    AND (l.parent_entity_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete LT002.")
 UPDATE  FROM order_sentence o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task =
   reqinfo->updt_task,
   o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1), o.ord_comment_long_text_id
    = 0
  PLAN (d
   WHERE (request->sentences[d.seq].comment.action_flag=3))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed to update OS002.")
 DELETE  FROM filter_entity_reltn f,
   (dummyt d  WITH seq = value(req_cnt))
  SET f.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=3))
   JOIN (f
   WHERE (f.parent_entity_id=request->sentences[d.seq].sentence_id)
    AND f.parent_entity_name="ORDER_SENTENCE")
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete VV.")
 DELETE  FROM order_sentence_filter f,
   (dummyt d  WITH seq = value(req_cnt))
  SET f.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=3))
   JOIN (f
   WHERE (f.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete filter.")
 DELETE  FROM long_text l,
   (dummyt d  WITH seq = value(req_cnt))
  SET l.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=3))
   JOIN (l
   WHERE l.parent_entity_name="ORDER_SENTENCE"
    AND (l.parent_entity_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete LT.")
 DELETE  FROM order_sentence_detail o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag IN (2, 3)))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete OSD.")
 DELETE  FROM order_sentence o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=3))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete OS.")
 DELETE  FROM ord_cat_sent_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.seq = 1
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=3))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Failed to delete OCSR.")
 SELECT INTO "NL:"
  j = seq(reference_seq,nextval)"##################;rp0"
  FROM dual du,
   (dummyt d  WITH seq = value(req_cnt))
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=1))
   JOIN (du)
  DETAIL
   reply->sentences[d.seq].sentence_id = cnvtreal(j), request->sentences[d.seq].sentence_id =
   cnvtreal(j)
  WITH format, counter
 ;end select
 SELECT INTO "NL:"
  j = seq(long_data_seq,nextval)"##################;rp0"
  FROM dual du,
   (dummyt d  WITH seq = value(req_cnt))
  PLAN (d
   WHERE (request->sentences[d.seq].comment.action_flag=1))
   JOIN (du)
  DETAIL
   request->sentences[d.seq].comment.comment_id = cnvtreal(j)
  WITH format, counter
 ;end select
 INSERT  FROM ord_cat_sent_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.order_cat_sent_r_id = seq(reference_seq,nextval), o.order_sentence_id = request->sentences[d
   .seq].sentence_id, o.order_sentence_disp_line = request->sentences[d.seq].display,
   o.catalog_cd = request->sentences[d.seq].catalog_code_value, o.synonym_id = request->sentences[d
   .seq].synonym_id, o.active_ind = 1,
   o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo
   ->updt_task,
   o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.display_seq = request->sentences[d.seq].
   sequence
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=1))
   JOIN (o)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Failed to insert OCSR.")
 INSERT  FROM order_sentence o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.order_sentence_id = request->sentences[d.seq].sentence_id, o.order_sentence_display_line =
   request->sentences[d.seq].display, o.oe_format_id = request->sentences[d.seq].oe_format_id,
   o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo
   ->updt_task,
   o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.usage_flag = 2,
   o.order_encntr_group_cd = request->sentences[d.seq].encntr_group_code_value, o
   .ord_comment_long_text_id = request->sentences[d.seq].comment.comment_id, o.parent_entity_name =
   "ORDER_CATALOG_SYNONYM",
   o.parent_entity_id = request->sentences[d.seq].synonym_id, o.parent_entity2_name = "", o
   .parent_entity2_id = 0,
   o.ic_auto_verify_flag = 0, o.discern_auto_verify_flag = 0, o.external_identifier = request->
   sentences[d.seq].ext_identifier
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=1))
   JOIN (o)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Failed to insert OS.")
 INSERT  FROM long_text l,
   (dummyt d  WITH seq = value(req_cnt))
  SET l.long_text_id = request->sentences[d.seq].comment.comment_id, l.updt_id = reqinfo->updt_id, l
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0,
   l.active_ind = 1, l.active_status_cd = active_code, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime),
   l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "ORDER_SENTENCE", l
   .parent_entity_id = request->sentences[d.seq].sentence_id,
   l.long_text = request->sentences[d.seq].comment.text
  PLAN (d
   WHERE (request->sentences[d.seq].comment.action_flag=1))
   JOIN (l)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Failed to insert LT.")
 UPDATE  FROM order_sentence o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.order_sentence_display_line = request->sentences[d.seq].display, o.oe_format_id = request->
   sentences[d.seq].oe_format_id, o.updt_id = reqinfo->updt_id,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx =
   reqinfo->updt_applctx,
   o.updt_cnt = (o.updt_cnt+ 1), o.usage_flag = 2, o.order_encntr_group_cd = request->sentences[d.seq
   ].encntr_group_code_value,
   o.ord_comment_long_text_id =
   IF ((request->sentences[d.seq].comment.action_flag=3)) 0
   ELSE request->sentences[d.seq].comment.comment_id
   ENDIF
   , o.parent_entity_name = "ORDER_CATALOG_SYNONYM", o.parent_entity_id = request->sentences[d.seq].
   synonym_id,
   o.parent_entity2_name = "", o.parent_entity2_id = 0, o.ic_auto_verify_flag = 0,
   o.discern_auto_verify_flag = 0, o.external_identifier = request->sentences[d.seq].ext_identifier
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=2))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed to update OS.")
 UPDATE  FROM ord_cat_sent_r o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.order_sentence_disp_line = request->sentences[d.seq].display, o.display_seq = request->
   sentences[d.seq].sequence, o.updt_id = reqinfo->updt_id,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_cnt = (o
   .updt_cnt+ 1),
   o.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag=2))
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id)
    AND (o.catalog_cd=request->sentences[d.seq].catalog_code_value)
    AND (o.synonym_id=request->sentences[d.seq].synonym_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed to update OCSR.")
 UPDATE  FROM long_text l,
   (dummyt d  WITH seq = value(req_cnt))
  SET l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_task =
   reqinfo->updt_task,
   l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1), l.long_text = request->
   sentences[d.seq].comment.text
  PLAN (d
   WHERE (request->sentences[d.seq].comment.action_flag=2))
   JOIN (l
   WHERE (l.long_text_id=request->sentences[d.seq].comment.comment_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed to update LT.")
 FOR (x = 1 TO req_cnt)
   SET fsize = size(request->sentences[x].fields,5)
   SET stat = initrec(fields)
   SET stat = alterlist(fields->fields,fsize)
   IF (fsize > 0
    AND (request->sentences[x].action_flag IN (1, 2)))
    SELECT INTO "nl:"
     a = request->sentences[x].fields[d.seq].group_seq, b = request->sentences[x].fields[d.seq].
     field_seq
     FROM (dummyt d  WITH seq = value(fsize)),
      order_entry_fields o
     PLAN (d)
      JOIN (o
      WHERE (o.oe_field_id=request->sentences[x].fields[d.seq].oe_field_id))
     ORDER BY a, b
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), fields->fields[cnt].field_code_value = request->sentences[x].fields[d.seq].
      field_code_value, fields->fields[cnt].field_disp_value = request->sentences[x].fields[d.seq].
      field_disp_value,
      fields->fields[cnt].field_type_flag = request->sentences[x].fields[d.seq].field_type_flag,
      fields->fields[cnt].oe_field_id = request->sentences[x].fields[d.seq].oe_field_id, fields->
      fields[cnt].meaning_id = o.oe_field_meaning_id,
      fields->fields[cnt].seq = cnt, fields->fields[cnt].sent_id = request->sentences[x].sentence_id
      IF (validate(request->sentences[x].fields[d.seq].parent_entity_id))
       fields->fields[cnt].parent_entity_id = request->sentences[x].fields[d.seq].parent_entity_id
      ENDIF
     WITH nocounter
    ;end select
    FOR (y = 1 TO fsize)
      IF ((fields->fields[y].field_type_flag IN (0, 1, 2, 3, 5,
      7, 11, 14, 15)))
       SET fields->fields[y].dname = " "
       SET fields->fields[y].dvalue = 0
       IF ((fields->fields[y].field_type_flag=5))
        SET fields->fields[y].field_code_value = - (99999)
       ELSEIF ((fields->fields[y].field_type_flag=7)
        AND (fields->fields[y].field_disp_value="Yes"))
        SET fields->fields[y].field_code_value = 1
       ENDIF
      ELSEIF ((fields->fields[y].field_type_flag IN (6, 9)))
       SET fields->fields[y].dname = "CODE_VALUE"
       SET fields->fields[y].dvalue = fields->fields[y].parent_entity_id
      ELSEIF ((fields->fields[y].field_type_flag=12))
       IF ((fields->fields[y].meaning_id=48))
        SET fields->fields[y].dname = "RESEARCH_ACCOUNT"
       ELSEIF ((fields->fields[y].meaning_id=123))
        SET fields->fields[y].dname = "SCH_BOOK_INSTR"
       ELSE
        SET fields->fields[y].dname = "CODE_VALUE"
       ENDIF
       SET fields->fields[y].dvalue = fields->fields[y].parent_entity_id
      ELSEIF ((fields->fields[y].field_type_flag IN (8, 13)))
       SET fields->fields[y].dname = "PERSON"
       SET fields->fields[y].dvalue = fields->fields[y].parent_entity_id
      ELSEIF ((fields->fields[y].field_type_flag=10))
       SET fields->fields[y].dname = "NOMENCLATURE"
       SET fields->fields[y].dvalue = fields->fields[y].parent_entity_id
      ENDIF
    ENDFOR
    INSERT  FROM order_sentence_detail o,
      (dummyt d  WITH seq = value(fsize))
     SET o.order_sentence_id = fields->fields[d.seq].sent_id, o.sequence = fields->fields[d.seq].seq,
      o.oe_field_value = fields->fields[d.seq].field_code_value,
      o.oe_field_id = fields->fields[d.seq].oe_field_id, o.oe_field_display_value = fields->fields[d
      .seq].field_disp_value, o.oe_field_meaning_id = fields->fields[d.seq].meaning_id,
      o.field_type_flag = fields->fields[d.seq].field_type_flag, o.updt_id = reqinfo->updt_id, o
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0,
      o.default_parent_entity_name = fields->fields[d.seq].dname, o.default_parent_entity_id = fields
      ->fields[d.seq].dvalue
     PLAN (d)
      JOIN (o)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert OSD.")
   ENDIF
   SET filtersize = size(request->sentences[x].filters,5)
   IF (filtersize > 0)
    UPDATE  FROM order_sentence_filter f,
      (dummyt d  WITH seq = value(filtersize))
     SET f.age_max_value = request->sentences[x].filters[d.seq].age_max_value, f.age_min_value =
      request->sentences[x].filters[d.seq].age_min_value, f.age_unit_cd = request->sentences[x].
      filters[d.seq].age_code_value,
      f.pma_max_value = request->sentences[x].filters[d.seq].pma_max_value, f.pma_min_value = request
      ->sentences[x].filters[d.seq].pma_min_value, f.pma_unit_cd = request->sentences[x].filters[d
      .seq].pma_code_value,
      f.weight_max_value = request->sentences[x].filters[d.seq].weight_max_value, f.weight_min_value
       = request->sentences[x].filters[d.seq].weight_min_value, f.weight_unit_cd = request->
      sentences[x].filters[d.seq].weight_code_value,
      f.updt_id = reqinfo->updt_id, f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task =
      reqinfo->updt_task,
      f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = (f.updt_cnt+ 1)
     PLAN (d
      WHERE (request->sentences[x].filters[d.seq].order_sentence_filter_id > 0)
       AND (((request->sentences[x].filters[d.seq].age_code_value > 0)) OR ((((request->sentences[x].
      filters[d.seq].pma_code_value > 0)) OR ((request->sentences[x].filters[d.seq].weight_code_value
       > 0))) )) )
      JOIN (f
      WHERE (f.order_sentence_filter_id=request->sentences[x].filters[d.seq].order_sentence_filter_id
      ))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Failed to update Filter.")
    INSERT  FROM order_sentence_filter f,
      (dummyt d  WITH seq = value(filtersize))
     SET f.order_sentence_filter_id = seq(reference_seq,nextval), f.age_max_value = request->
      sentences[x].filters[d.seq].age_max_value, f.age_min_value = request->sentences[x].filters[d
      .seq].age_min_value,
      f.age_unit_cd = request->sentences[x].filters[d.seq].age_code_value, f.order_sentence_id =
      request->sentences[x].sentence_id, f.pma_max_value = request->sentences[x].filters[d.seq].
      pma_max_value,
      f.pma_min_value = request->sentences[x].filters[d.seq].pma_min_value, f.pma_unit_cd = request->
      sentences[x].filters[d.seq].pma_code_value, f.weight_max_value = request->sentences[x].filters[
      d.seq].weight_max_value,
      f.weight_min_value = request->sentences[x].filters[d.seq].weight_min_value, f.weight_unit_cd =
      request->sentences[x].filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
      f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f.updt_applctx
       = reqinfo->updt_applctx,
      f.updt_cnt = 0
     PLAN (d
      WHERE (request->sentences[x].filters[d.seq].order_sentence_filter_id=0)
       AND (((request->sentences[x].filters[d.seq].age_code_value > 0)) OR ((((request->sentences[x].
      filters[d.seq].pma_code_value > 0)) OR ((request->sentences[x].filters[d.seq].weight_code_value
       > 0))) )) )
      JOIN (f)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert Filter.")
    DELETE  FROM order_sentence_filter f,
      (dummyt d  WITH seq = value(filtersize))
     SET f.seq = 1
     PLAN (d
      WHERE (request->sentences[x].filters[d.seq].order_sentence_filter_id > 0)
       AND (request->sentences[x].filters[d.seq].age_code_value=0)
       AND (request->sentences[x].filters[d.seq].pma_code_value=0)
       AND (request->sentences[x].filters[d.seq].weight_code_value=0))
      JOIN (f
      WHERE (f.order_sentence_filter_id=request->sentences[x].filters[d.seq].order_sentence_filter_id
      ))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed to delete filters")
   ELSE
    CALL deletefiltersforsentence(request->sentences[x].sentence_id)
   ENDIF
   SET facsize = size(request->sentences[x].facilities,5)
   IF (facsize > 0)
    INSERT  FROM filter_entity_reltn f,
      (dummyt d  WITH seq = value(facsize))
     SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
      "ORDER_SENTENCE", f.parent_entity_id = request->sentences[x].sentence_id,
      f.filter_entity1_name = "LOCATION", f.filter_entity1_id = request->sentences[x].facilities[d
      .seq].facility_code_value, f.filter_entity2_name = null,
      f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
      f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
      f.filter_entity5_id = 0, f.filter_type_cd = ordsent_code, f.exclusion_filter_ind = null,
      f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
      f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f.updt_applctx
       = reqinfo->updt_applctx,
      f.updt_cnt = 0
     PLAN (d
      WHERE (request->sentences[x].facilities[d.seq].action_flag=1))
      JOIN (f)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert VV.")
    DELETE  FROM filter_entity_reltn f,
      (dummyt d  WITH seq = value(facsize))
     SET f.seq = 1
     PLAN (d
      WHERE (request->sentences[x].facilities[d.seq].action_flag=3))
      JOIN (f
      WHERE (f.parent_entity_id=request->sentences[x].sentence_id)
       AND f.parent_entity_name="ORDER_SENTENCE"
       AND f.filter_entity1_name="LOCATION"
       AND (f.filter_entity1_id=request->sentences[x].facilities[d.seq].facility_code_value))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed to delete VV.")
    DELETE  FROM filter_entity_reltn f,
      (dummyt d  WITH seq = value(facsize))
     SET f.seq = 1
     PLAN (d
      WHERE (request->sentences[x].facilities[d.seq].action_flag=1)
       AND (request->sentences[x].facilities[d.seq].facility_code_value > 0))
      JOIN (f
      WHERE (f.parent_entity_id=request->sentences[x].sentence_id)
       AND f.parent_entity_name="ORDER_SENTENCE"
       AND f.filter_entity1_name="LOCATION"
       AND f.filter_entity1_id=0)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed to delete2 VV.")
   ENDIF
 ENDFOR
 SET utcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr
  PLAN (d
   WHERE (request->sentences[d.seq].action_flag IN (1, 3)))
   JOIN (ocs
   WHERE (ocs.synonym_id=request->sentences[d.seq].synonym_id))
   JOIN (ocsr
   WHERE ocsr.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY ocs.synonym_id
  HEAD REPORT
   ucnt = 0, utcnt = 0, stat = alterlist(upd_ocs->syns,100)
  HEAD ocs.synonym_id
   sent_cnt = 0, ms_ind = 0, os_id = 0.0,
   add_ind = 0
  DETAIL
   IF (ocsr.synonym_id > 0)
    sent_cnt = (sent_cnt+ 1), os_id = ocsr.order_sentence_id
   ENDIF
  FOOT  ocs.synonym_id
   IF (sent_cnt=0)
    IF (((ocs.multiple_ord_sent_ind > 0) OR (ocs.order_sentence_id > 0)) )
     ms_ind = 0, os_id = 0.0, add_ind = 1
    ENDIF
   ELSEIF (sent_cnt=1)
    IF (((ocs.multiple_ord_sent_ind > 0) OR (((ocs.order_sentence_id=0) OR (ocs.order_sentence_id !=
    ocsr.order_sentence_id)) )) )
     ms_ind = 0, add_ind = 1
    ENDIF
   ELSE
    IF (((ocs.multiple_ord_sent_ind=0) OR (ocs.order_sentence_id > 0)) )
     ms_ind = 1, os_id = 0.0, add_ind = 1
    ENDIF
   ENDIF
   IF (add_ind=1)
    ucnt = (ucnt+ 1), utcnt = (utcnt+ 1)
    IF (ucnt > 100)
     stat = alterlist(upd_ocs->syns,(utcnt+ 100)), ucnt = 1
    ENDIF
    upd_ocs->syns[utcnt].mul_sent_ind = ms_ind, upd_ocs->syns[utcnt].order_sent_id = os_id, upd_ocs->
    syns[utcnt].synonym_id = ocs.synonym_id
   ENDIF
  FOOT REPORT
   stat = alterlist(upd_ocs->syns,utcnt)
  WITH nocounter
 ;end select
 IF (utcnt > 0)
  UPDATE  FROM order_catalog_synonym o,
    (dummyt d  WITH seq = value(utcnt))
   SET o.multiple_ord_sent_ind = upd_ocs->syns[d.seq].mul_sent_ind, o.order_sentence_id = upd_ocs->
    syns[d.seq].order_sent_id, o.updt_id = reqinfo->updt_id,
    o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx =
    reqinfo->updt_applctx,
    o.updt_cnt = (o.updt_cnt+ 1)
   PLAN (d)
    JOIN (o
    WHERE (o.synonym_id=upd_ocs->syns[d.seq].synonym_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Failed to update OCS.")
 ENDIF
 SUBROUTINE deletefiltersforsentence(sentenceid)
   CALL bedlogmessage("deleteFiltersForSentence","Entering ...")
   DELETE  FROM order_sentence_filter f
    WHERE f.order_sentence_id=sentenceid
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Failed to delete filters for the given sentence id.")
   CALL bedlogmessage("deleteFiltersForSentence","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
