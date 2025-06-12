CREATE PROGRAM bed_aud_mos_rx:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 order_catalogs[*]
      2 catalog_cd = f8
    1 synonym_types[*]
      2 mnemonic_type_cd = f8
  )
 ENDIF
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
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
 DECLARE build_order_catalog_ids(dummyvar=i2) = null
 DECLARE build_synonym_type_ids(dummyvar=i2) = null
 IF ( NOT (validate(cs6011_primary_cd)))
  DECLARE cs6011_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 ENDIF
 IF ( NOT (validate(cs6000_pharmacy_cd)))
  DECLARE cs6000_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 ENDIF
 IF ( NOT (validate(cs6003_order_cd)))
  DECLARE cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 ENDIF
 DECLARE total_col = i4 WITH protect, noconstant(0)
 DECLARE prim_pharm_id = i4 WITH protect, noconstant(0)
 DECLARE order_catalog_parse = vc WITH protect, noconstant("")
 DECLARE order_catalog_count_parse = vc WITH protect, noconstant("")
 DECLARE synonym_type_parse = vc WITH protect, noconstant("")
 DECLARE order_catalog_cnt = i4 WITH protect, noconstant(0)
 DECLARE synonym_type_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_entry_format oef
  PLAN (oef
   WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
    AND oef.action_type_cd=cs6003_order_cd)
  DETAIL
   prim_pharm_id = oef.oe_format_id
  WITH nocounter
 ;end select
 FREE RECORD fields
 RECORD fields(
   1 qual[*]
     2 meaning = vc
 )
 SET order_catalog_parse = "oc.catalog_cd = ocs.catalog_cd"
 SET order_catalog_count_parse = build("oc.catalog_type_cd =",cs6000_pharmacy_cd)
 SET order_catalog_count_parse = build(order_catalog_count_parse,
  " and oc.orderable_type_flag in (0,1) and oc.active_ind = 1")
 SET synonym_type_parse = "ocs.catalog_cd = oc.catalog_cd and ocs.active_ind = 1"
 SET synonym_type_parse = build(synonym_type_parse,
  " and ocs.oe_format_id > 0 and ocs.oe_format_id !=")
 SET synonym_type_parse = build(synonym_type_parse,prim_pharm_id," and ocs.hide_flag in (0,null)")
 CALL build_order_catalog_ids(0)
 CALL build_synonym_type_ids(0)
 SET stat = alterlist(fields->qual,18)
 SET fields->qual[1].meaning = "STRENGTHDOSE"
 SET fields->qual[2].meaning = "STRENGTHDOSEUNIT"
 SET fields->qual[3].meaning = "VOLUMEDOSE"
 SET fields->qual[4].meaning = "VOLUMEDOSEUNIT"
 SET fields->qual[5].meaning = "FREETXTDOSE"
 SET fields->qual[6].meaning = "RXROUTE"
 SET fields->qual[7].meaning = "DRUGFORM"
 SET fields->qual[8].meaning = "FREQ"
 SET fields->qual[9].meaning = "RXPRIORITY"
 SET fields->qual[10].meaning = "SCH/PRN"
 SET fields->qual[11].meaning = "PRNREASON"
 SET fields->qual[12].meaning = "FREETEXTRATE"
 SET fields->qual[13].meaning = "RATE"
 SET fields->qual[14].meaning = "RATEUNIT"
 SET fields->qual[15].meaning = "INFUSEOVER"
 SET fields->qual[16].meaning = "INFUSEOVERUNIT"
 SET fields->qual[17].meaning = "DURATION"
 SET fields->qual[18].meaning = "DURATIONUNIT"
 SET fcnt = 18
 SELECT DISTINCT INTO "nl:"
  ofm.oe_field_meaning
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r r,
   order_sentence os,
   order_sentence_detail osd,
   oe_field_meaning ofm
  PLAN (oc
   WHERE oc.catalog_type_cd=cs6000_pharmacy_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ocs.oe_format_id > 0
    AND ocs.oe_format_id != prim_pharm_id
    AND ocs.hide_flag IN (0, null))
   JOIN (r
   WHERE r.synonym_id=ocs.synonym_id
    AND r.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=r.order_sentence_id
    AND os.usage_flag=2)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id
    AND  NOT (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
   "VOLUMEDOSEUNIT", "FREETXTDOSE",
   "RXROUTE", "DRUGFORM", "FREQ", "RXPRIORITY", "SCH/PRN",
   "PRNREASON", "FREETEXTRATE", "RATE", "RATEUNIT", "INFUSEOVER",
   "INFUSEOVERUNIT", "DURATION", "DURATIONUNIT")))
  HEAD ofm.oe_field_meaning
   fcnt = (fcnt+ 1), stat = alterlist(fields->qual,fcnt), fields->qual[fcnt].meaning = ofm
   .oe_field_meaning
  WITH nocounter
 ;end select
 FREE SET sent
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
     2 usage_flag = vc
     2 oc_cki = vc
     2 ocs_cki = vc
     2 ident = vc
     2 comment = vc
     2 sequence = vc
     2 det[*]
       3 field = vc
       3 value = vc
 )
 FREE SET syn
 RECORD syn(
   1 qual[*]
     2 id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE parser(order_catalog_count_parse))
   JOIN (ocs
   WHERE parser(synonym_type_parse))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs.mnemonic_key_cap
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), stat = alterlist(syn->qual,cnt), syn->qual[cnt].id = ocs.synonym_id
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SET scnt = 0
 DECLARE select_cnt = i4 WITH private, noconstant(0)
 DECLARE in_clause_size = i4 WITH private, constant(250)
 DECLARE start_idx = i4
 DECLARE end_idx = i4
 IF (mod(cnt,in_clause_size)=0)
  SET select_cnt = (cnt/ in_clause_size)
 ELSE
  SET select_cnt = ((cnt/ in_clause_size)+ 1)
 ENDIF
 FOR (xx = 1 TO select_cnt)
   SET syn_cnt = 0
   FREE SET syn2
   RECORD syn2(
     1 qual[*]
       2 id = f8
   )
   IF (select_cnt=1)
    FOR (z = 1 TO cnt)
      SET syn_cnt = (syn_cnt+ 1)
      SET stat = alterlist(syn2->qual,syn_cnt)
      SET syn2->qual[syn_cnt].id = syn->qual[z].id
    ENDFOR
   ELSE
    SET start_idx = (((xx - 1) * in_clause_size)+ 1)
    IF (xx < select_cnt)
     SET end_idx = (start_idx+ in_clause_size)
    ELSE
     SET end_idx = cnt
    ENDIF
    FOR (z = start_idx TO end_idx)
      SET syn_cnt = (syn_cnt+ 1)
      SET stat = alterlist(syn2->qual,syn_cnt)
      SET syn2->qual[syn_cnt].id = syn->qual[z].id
    ENDFOR
   ENDIF
   SET stat = load_sent(xx)
 ENDFOR
 SUBROUTINE load_sent(xx)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(syn2->qual,5))),
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
    WHERE (ocs.synonym_id=syn2->qual[d.seq].id))
    JOIN (oc
    WHERE parser(order_catalog_parse))
    JOIN (r
    WHERE r.synonym_id=ocs.synonym_id
     AND r.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=r.order_sentence_id
     AND os.usage_flag=2)
    JOIN (osd
    WHERE osd.order_sentence_id=os.order_sentence_id)
    JOIN (cv
    WHERE cv.code_value=osd.default_parent_entity_id)
    JOIN (oef
    WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
     AND oef.action_type_cd=outerjoin(cs6003_order_cd))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
    JOIN (f
    WHERE f.oe_field_id=osd.oe_field_id
     AND f.field_type_flag != 13)
   ORDER BY d.seq, r.display_seq, r.order_sentence_disp_line
   HEAD r.order_sentence_id
    dcnt = 0, scnt = (scnt+ 1), stat = alterlist(sent->qual,scnt),
    sent->qual[scnt].sent_id = r.order_sentence_id, sent->qual[scnt].sentence = r
    .order_sentence_disp_line, sent->qual[scnt].id = ocs.synonym_id,
    sent->qual[scnt].primary = oc.primary_mnemonic, sent->qual[scnt].synonym = ocs.mnemonic, sent->
    qual[scnt].key_cap = ocs.mnemonic_key_cap,
    sent->qual[scnt].type = uar_get_code_display(ocs.mnemonic_type_cd), sent->qual[scnt].format = oef
    .oe_format_name, sent->qual[scnt].usage_flag = "Prescription",
    sent->qual[scnt].oc_cki = oc.cki, sent->qual[scnt].ocs_cki = ocs.cki, sent->qual[scnt].ident = os
    .external_identifier,
    sent->qual[scnt].comment = lt.long_text, sent->qual[scnt].sequence = cnvtstring(r.display_seq)
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(sent->qual[scnt].det,dcnt), sent->qual[scnt].det[dcnt].field
     = ofm.oe_field_meaning
    IF (osd.default_parent_entity_id > 0)
     sent->qual[scnt].det[dcnt].value = cv.display
    ELSE
     IF (f.field_type_flag=7
      AND osd.oe_field_value=1.00)
      sent->qual[scnt].det[dcnt].value = "Yes"
     ELSEIF (f.field_type_flag=7
      AND osd.oe_field_value=0.00)
      sent->qual[scnt].det[dcnt].value = "No"
     ELSE
      sent->qual[scnt].det[dcnt].value = osd.oe_field_display_value
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  RETURN(0)
 END ;Subroutine
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET total_col = ((fcnt * 2)+ 14)
 SET stat = alterlist(reply->collist,total_col)
 SET reply->collist[1].header_text = "Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Mnemonic Key Cap"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Synonym Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Synonym ID"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 0
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
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Order Sentence"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Medication Administration or Prescription?"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Order Sentence Sequence"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Sentence External ID"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET num = 13
 FOR (x = 1 TO fcnt)
   SET num = (num+ 1)
   SET reply->collist[num].header_text = concat("Order Entry Field ",trim(cnvtstring(x)))
   SET reply->collist[num].data_type = 1
   SET reply->collist[num].hide_ind = 0
   SET num = (num+ 1)
   SET reply->collist[num].header_text = concat("Order Entry Field Value",trim(cnvtstring(x)))
   SET reply->collist[num].data_type = 1
   SET reply->collist[num].hide_ind = 0
 ENDFOR
 SET reply->collist[total_col].header_text = "Order Sentence Comment"
 SET reply->collist[total_col].data_type = 1
 SET reply->collist[total_col].hide_ind = 0
 SET rcnt = 0
 FOR (x = 1 TO scnt)
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->rowlist,rcnt)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,total_col)
   SET reply->rowlist[rcnt].celllist[1].string_value = sent->qual[x].primary
   SET reply->rowlist[rcnt].celllist[2].string_value = sent->qual[x].synonym
   SET reply->rowlist[rcnt].celllist[3].string_value = sent->qual[x].key_cap
   SET reply->rowlist[rcnt].celllist[4].string_value = sent->qual[x].type
   SET reply->rowlist[rcnt].celllist[5].double_value = sent->qual[x].id
   SET reply->rowlist[rcnt].celllist[6].string_value = sent->qual[x].format
   SET reply->rowlist[rcnt].celllist[7].string_value = sent->qual[x].oc_cki
   SET reply->rowlist[rcnt].celllist[8].string_value = sent->qual[x].ocs_cki
   SET reply->rowlist[rcnt].celllist[9].double_value = sent->qual[x].sent_id
   SET reply->rowlist[rcnt].celllist[10].string_value = sent->qual[x].sentence
   SET reply->rowlist[rcnt].celllist[11].string_value = sent->qual[x].usage_flag
   SET reply->rowlist[rcnt].celllist[12].string_value = sent->qual[x].sequence
   SET reply->rowlist[rcnt].celllist[13].string_value = sent->qual[x].ident
   SET reply->rowlist[rcnt].celllist[total_col].string_value = sent->qual[x].comment
   SET num = 14
   FOR (y = 1 TO fcnt)
    SET reply->rowlist[rcnt].celllist[num].string_value = fields->qual[y].meaning
    SET num = (num+ 2)
   ENDFOR
   FOR (y = 1 TO size(sent->qual[x].det,5))
     FOR (z = 14 TO total_col)
       IF ((sent->qual[x].det[y].field=reply->rowlist[rcnt].celllist[z].string_value))
        SET reply->rowlist[rcnt].celllist[(z+ 1)].string_value = sent->qual[x].det[y].value
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SUBROUTINE build_order_catalog_ids(dummyvar)
   DECLARE order_catalog_id = vc WITH protect
   DECLARE orderable_cnt = f8 WITH protect
   FOR (order_catalog_cnt = 1 TO size(request->order_catalogs,5))
     IF (orderable_cnt > 999)
      SET order_catalog_id = replace(order_catalog_id,",","",2)
      SET order_catalog_id = build(order_catalog_id,") or oc.catalog_cd in (")
      SET orderable_cnt = 0
     ENDIF
     SET order_catalog_id = build(order_catalog_id,request->order_catalogs[order_catalog_cnt].
      catalog_cd,",")
     SET orderable_cnt = (orderable_cnt+ 1)
   ENDFOR
   SET order_catalog_id = replace(order_catalog_id,",","",2)
   IF (size(request->order_catalogs,5) > 0)
    SET order_catalog_parse = build(order_catalog_parse," and oc.catalog_cd in (",order_catalog_id,
     ")")
    SET order_catalog_count_parse = build(order_catalog_count_parse," and oc.catalog_cd in (",
     order_catalog_id,")")
   ENDIF
 END ;Subroutine
 SUBROUTINE build_synonym_type_ids(dummyvar)
   DECLARE mnemonic_type_cd = vc WITH protect
   DECLARE synonym_cnt = f8 WITH protect
   FOR (synonym_type_cnt = 1 TO size(request->synonym_types,5))
     IF (synonym_cnt > 999)
      SET mnemonic_type_cd = replace(mnemonic_type_cd,",","",2)
      SET mnemonic_type_cd = build(mnemonic_type_cd,") or ocs.mnemonic_type_cd in (")
      SET synonym_cnt = 0
     ENDIF
     SET mnemonic_type_cd = build(mnemonic_type_cd,request->synonym_types[synonym_type_cnt].
      mnemonic_type_cd,",")
     SET synonym_cnt = (synonym_cnt+ 1)
   ENDFOR
   SET mnemonic_type_cd = replace(mnemonic_type_cd,",","",2)
   IF (size(request->synonym_types,5) > 0)
    SET synonym_type_parse = build(synonym_type_parse," and ocs.mnemonic_type_cd in (",
     mnemonic_type_cd,")")
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("mos_rx_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
