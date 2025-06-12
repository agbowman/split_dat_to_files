CREATE PROGRAM bed_aud_order_sentences:dba
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
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD sent(
   1 qual[*]
     2 id = f8
     2 primary = vc
     2 synonym = vc
     2 key_cap = vc
     2 type = vc
     2 format = vc
     2 sent_id = f8
     2 sentence = vc
     2 oc_cki = vc
     2 ocs_cki = vc
     2 ident = vc
     2 comment = vc
     2 sequence = vc
     2 det[*]
       3 field = vc
       3 value = vc
 ) WITH protect
 RECORD syn(
   1 qual[*]
     2 id = f8
 ) WITH protect
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
 DECLARE cs6003_order_code = f8 WITH protect, noconstant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE activity_type_cnt = i4 WITH protect, noconstant(size(request->activity_types,5))
 DECLARE act_type_list = vc WITH protect, noconstant("")
 DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
 DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
 DECLARE os_detail_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_fields = i4 WITH protect, noconstant(0)
 DECLARE total_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE oe_field_index = i4 WITH protect, noconstant(0)
 CALL bedbeginscript(0)
 IF (activity_type_cnt=0)
  GO TO exit_script
 ENDIF
 SET act_type_list = build(" oc.activity_type_cd in (",request->activity_types[1].code_value)
 FOR (a = 2 TO activity_type_cnt)
   SET act_type_list = build(act_type_list,",",request->activity_types[a].code_value)
 ENDFOR
 SET act_type_list = concat(act_type_list,")")
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    ord_cat_sent_r r
   PLAN (oc
    WHERE oc.orderable_type_flag IN (0, 1)
     AND oc.active_ind=1
     AND parser(act_type_list))
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.active_ind=1
     AND ocs.oe_format_id > 0)
    JOIN (r
    WHERE r.synonym_id=ocs.synonym_id
     AND r.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL bederrorcheck("001 - Failed to determine output volume")
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1
    AND parser(act_type_list))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ocs.oe_format_id > 0)
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs.mnemonic_key_cap, ocs.synonym_id
  HEAD ocs.synonym_id
   synonym_cnt = (synonym_cnt+ 1), stat = alterlist(syn->qual,synonym_cnt), syn->qual[synonym_cnt].id
    = ocs.synonym_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("002 - Failed to obtain synonyms for given activity types")
 IF (synonym_cnt=0)
  GO TO exit_script
 ENDIF
 SET max_fields = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(synonym_cnt)),
   order_catalog_synonym ocs,
   order_catalog oc,
   ord_cat_sent_r r,
   order_sentence os,
   order_sentence_detail osd,
   code_value cv,
   order_entry_format oef,
   long_text lt,
   oe_field_meaning ofm,
   order_entry_fields f
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.synonym_id=syn->qual[d.seq].id))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
   JOIN (r
   WHERE r.synonym_id=ocs.synonym_id
    AND r.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=r.order_sentence_id)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (cv
   WHERE cv.code_value=osd.default_parent_entity_id)
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=cs6003_order_code)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
   JOIN (f
   WHERE f.oe_field_id=osd.oe_field_id)
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
  ORDER BY d.seq, r.display_seq, r.order_sentence_disp_line,
   r.order_sentence_id
  HEAD r.order_sentence_id
   os_detail_cnt = 0, sentence_cnt = (sentence_cnt+ 1), stat = alterlist(sent->qual,sentence_cnt),
   sent->qual[sentence_cnt].sent_id = r.order_sentence_id, sent->qual[sentence_cnt].sentence = r
   .order_sentence_disp_line, sent->qual[sentence_cnt].id = ocs.synonym_id,
   sent->qual[sentence_cnt].primary = oc.primary_mnemonic, sent->qual[sentence_cnt].synonym = ocs
   .mnemonic, sent->qual[sentence_cnt].key_cap = ocs.mnemonic_key_cap,
   sent->qual[sentence_cnt].type = uar_get_code_display(ocs.mnemonic_type_cd), sent->qual[
   sentence_cnt].format = oef.oe_format_name, sent->qual[sentence_cnt].oc_cki = oc.cki,
   sent->qual[sentence_cnt].ocs_cki = ocs.cki, sent->qual[sentence_cnt].ident = os
   .external_identifier, sent->qual[sentence_cnt].comment = lt.long_text,
   sent->qual[sentence_cnt].sequence = cnvtstring(r.display_seq)
  DETAIL
   os_detail_cnt = (os_detail_cnt+ 1), stat = alterlist(sent->qual[sentence_cnt].det,os_detail_cnt),
   sent->qual[sentence_cnt].det[os_detail_cnt].field = ofm.oe_field_meaning
   IF (osd.default_parent_entity_id > 0)
    sent->qual[sentence_cnt].det[os_detail_cnt].value = cv.display
   ELSE
    IF (f.field_type_flag=7
     AND trim(osd.oe_field_display_value)="1")
     sent->qual[sentence_cnt].det[os_detail_cnt].value = "Yes"
    ELSEIF (f.field_type_flag=7
     AND trim(osd.oe_field_display_value)="0")
     sent->qual[sentence_cnt].det[os_detail_cnt].value = "Yes"
    ELSE
     sent->qual[sentence_cnt].det[os_detail_cnt].value = osd.oe_field_display_value
    ENDIF
   ENDIF
  FOOT  r.order_sentence_id
   IF (os_detail_cnt > max_fields)
    max_fields = os_detail_cnt
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("003 - Failed to obtain sentences for given synonyms")
 IF (sentence_cnt=0)
  GO TO exit_script
 ENDIF
 SET total_col_cnt = ((max_fields * 2)+ 13)
 SET stat = alterlist(reply->collist,total_col_cnt)
 SET reply->collist[1].header_text = "Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Mnemonic Key Cap"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Synonym Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Synonym ID"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Order Entry Format"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Catalog CKI"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Synonym CKI"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Order Sentence ID"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 1
 SET reply->collist[10].header_text = "Order Sentence"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Order Sentence Comment"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Order Sentence Sequence"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Sentence External ID"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 1
 SET oe_field_index = 13
 FOR (x = 1 TO max_fields)
   SET oe_field_index = (oe_field_index+ 1)
   SET reply->collist[oe_field_index].header_text = concat("Order Entry Field ",trim(cnvtstring(x)))
   SET reply->collist[oe_field_index].data_type = 1
   SET reply->collist[oe_field_index].hide_ind = 0
   SET oe_field_index = (oe_field_index+ 1)
   SET reply->collist[oe_field_index].header_text = concat("Order Entry Field Value",trim(cnvtstring(
      x)))
   SET reply->collist[oe_field_index].data_type = 1
   SET reply->collist[oe_field_index].hide_ind = 0
 ENDFOR
 FOR (x = 1 TO sentence_cnt)
   SET row_cnt = (row_cnt+ 1)
   SET stat = alterlist(reply->rowlist,row_cnt)
   SET stat = alterlist(reply->rowlist[row_cnt].celllist,total_col_cnt)
   SET reply->rowlist[row_cnt].celllist[1].string_value = sent->qual[x].primary
   SET reply->rowlist[row_cnt].celllist[2].string_value = sent->qual[x].synonym
   SET reply->rowlist[row_cnt].celllist[3].string_value = sent->qual[x].key_cap
   SET reply->rowlist[row_cnt].celllist[4].string_value = sent->qual[x].type
   SET reply->rowlist[row_cnt].celllist[5].double_value = sent->qual[x].id
   SET reply->rowlist[row_cnt].celllist[6].string_value = sent->qual[x].format
   SET reply->rowlist[row_cnt].celllist[7].string_value = sent->qual[x].oc_cki
   SET reply->rowlist[row_cnt].celllist[8].string_value = sent->qual[x].ocs_cki
   SET reply->rowlist[row_cnt].celllist[9].double_value = sent->qual[x].sent_id
   SET reply->rowlist[row_cnt].celllist[10].string_value = sent->qual[x].sentence
   SET reply->rowlist[row_cnt].celllist[11].string_value = sent->qual[x].comment
   SET reply->rowlist[row_cnt].celllist[12].string_value = sent->qual[x].sequence
   SET reply->rowlist[row_cnt].celllist[13].string_value = sent->qual[x].ident
   SET oe_field_index = 13
   FOR (y = 1 TO size(sent->qual[x].det,5))
     SET oe_field_index = (oe_field_index+ 1)
     SET reply->rowlist[row_cnt].celllist[oe_field_index].string_value = sent->qual[x].det[y].field
     SET oe_field_index = (oe_field_index+ 1)
     SET reply->rowlist[row_cnt].celllist[oe_field_index].string_value = sent->qual[x].det[y].value
   ENDFOR
 ENDFOR
#exit_script
 CALL bedexitscript(0)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("order_sentences.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
