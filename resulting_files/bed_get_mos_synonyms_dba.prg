CREATE PROGRAM bed_get_mos_synonyms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 mnemonic = vc
      2 type_code_value = f8
      2 type_display = vc
      2 oe_format_id = f8
      2 sentences[*]
        3 sentence_id = f8
        3 full_display = vc
        3 display = vc
        3 usage_flag = i2
        3 comment_id = f8
        3 comment_txt = vc
        3 encntr_group_code_value = f8
        3 sequence = i4
        3 details[*]
          4 oe_field_id = f8
          4 oe_field_label = vc
          4 field_disp_value = vc
          4 field_code_value = f8
          4 field_type_flag = i2
          4 sequence = i4
        3 all_facilities_ind = i2
        3 facilities[*]
          4 facility_code_value = f8
          4 display = vc
        3 oe_format_id = f8
        3 discern_rules_checking = i2
        3 multum_clinical_checking = i2
        3 source = i2
        3 filters
          4 order_sentence_filter_id = f8
          4 age_min_value = f8
          4 age_max_value = f8
          4 age_unit_cd
            5 code_value = f8
            5 display = vc
            5 mean = vc
            5 description = vc
          4 pma_min_value = f8
          4 pma_max_value = f8
          4 pma_unit_cd
            5 code_value = f8
            5 display = vc
            5 mean = vc
            5 description = vc
          4 weight_min_value = f8
          4 weight_max_value = f8
          4 weight_unit_cd
            5 code_value = f8
            5 display = vc
            5 mean = vc
            5 description = vc
      2 type_meaning = vc
      2 products[*]
        3 item_id = f8
      2 hidden_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 products[*]
      2 item_id = f8
      2 description = vc
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
 SET tcnt = 0
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET y_code_value = 0.0
 SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET z_code_value = 0.0
 SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET action_code = 0.0
 IF ((request->usage_flag=2))
  SET action_code = uar_get_code_by("MEANING",6003,"DISORDER")
 ELSE
  SET action_code = uar_get_code_by("MEANING",6003,"ORDER")
 ENDIF
 SET inpatient_code_value = 0.0
 SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET desc_code_value = 0.0
 SET desc_code_value = uar_get_code_by("MEANING",11000,"DESC")
 SET system_code_value = 0.0
 SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET sys_pkg_code_value = 0.0
 SET sys_pkg_code_value = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET orderable_code_value = 0.0
 SET orderable_code_value = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET prn_id = 0.0
 SELECT INTO "nl:"
  FROM oe_field_meaning o
  WHERE o.oe_field_meaning="SCH/PRN"
  DETAIL
   prn_id = o.oe_field_meaning_id
  WITH nocounter
 ;end select
 CALL bederrorcheck(
  "ERROR 001: select from oe_field_meaning table failed for the field_meaning SCH/PRN")
 DECLARE ocs_parse = vc
 IF ((request->usage_flag=2))
  SET ocs_parse = concat("ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value,",
   "c_code_value, e_code_value, m_code_value, n_code_value, y_code_value, z_code_value)")
 ELSE
  SET ocs_parse = concat(
   "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
   "c_code_value, e_code_value, m_code_value, n_code_value)")
 ENDIF
 SET stcnt = 0
 SET hide_flag = request->hidden_synonyms_ind
 IF ((request->ignore_facility_ind=0))
  SELECT INTO "nl:"
   mtype = uar_get_code_display(ocs.mnemonic_type_cd), mmean = uar_get_code_meaning(ocs
    .mnemonic_type_cd)
   FROM order_catalog_synonym ocs,
    ocs_facility_r ofr
   PLAN (ocs
    WHERE (ocs.catalog_cd=request->catalog_code_value)
     AND parser(ocs_parse)
     AND ocs.hide_flag IN (0, hide_flag, null)
     AND ocs.active_ind=1)
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id
     AND ((ofr.facility_cd+ 0) IN (request->facility_code_value, 0)))
   ORDER BY ocs.synonym_id
   HEAD REPORT
    scnt = 0, stcnt = 0, stat = alterlist(reply->synonyms,10)
   HEAD ocs.synonym_id
    scnt = (scnt+ 1), stcnt = (stcnt+ 1)
    IF (scnt > 10)
     stat = alterlist(reply->synonyms,(stcnt+ 10)), scnt = 1
    ENDIF
    reply->synonyms[stcnt].synonym_id = ocs.synonym_id, reply->synonyms[stcnt].mnemonic = ocs
    .mnemonic, reply->synonyms[stcnt].oe_format_id = ocs.oe_format_id,
    reply->synonyms[stcnt].type_code_value = ocs.mnemonic_type_cd, reply->synonyms[stcnt].
    type_display = mtype, reply->synonyms[stcnt].type_meaning = mmean,
    reply->synonyms[stcnt].hidden_ind = ocs.hide_flag
   FOOT REPORT
    stat = alterlist(reply->synonyms,stcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 002: select from order_catalog_synonym and ocs_facility_r tables failed")
 ELSE
  SELECT INTO "nl:"
   mtype = uar_get_code_display(ocs.mnemonic_type_cd), mmean = uar_get_code_meaning(ocs
    .mnemonic_type_cd)
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE (ocs.catalog_cd=request->catalog_code_value)
     AND parser(ocs_parse)
     AND ocs.hide_flag IN (0, hide_flag, null)
     AND ocs.active_ind=1)
   ORDER BY ocs.synonym_id
   HEAD REPORT
    scnt = 0, stcnt = 0, stat = alterlist(reply->synonyms,10)
   HEAD ocs.synonym_id
    scnt = (scnt+ 1), stcnt = (stcnt+ 1)
    IF (scnt > 10)
     stat = alterlist(reply->synonyms,(stcnt+ 10)), scnt = 1
    ENDIF
    reply->synonyms[stcnt].synonym_id = ocs.synonym_id, reply->synonyms[stcnt].mnemonic = ocs
    .mnemonic, reply->synonyms[stcnt].oe_format_id = ocs.oe_format_id,
    reply->synonyms[stcnt].type_code_value = ocs.mnemonic_type_cd, reply->synonyms[stcnt].
    type_display = mtype, reply->synonyms[stcnt].type_meaning = mmean,
    reply->synonyms[stcnt].hidden_ind = ocs.hide_flag
   FOOT REPORT
    stat = alterlist(reply->synonyms,stcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 003: select from order_catalog_synonym table failed")
 ENDIF
 IF (stcnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->ignore_facility_ind=0))
  SET max_sent_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(stcnt)),
    ord_cat_sent_r ocsr,
    order_sentence os,
    filter_entity_reltn f,
    long_text lt
   PLAN (d)
    JOIN (ocsr
    WHERE (ocsr.synonym_id=reply->synonyms[d.seq].synonym_id)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND (os.usage_flag=request->usage_flag))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
    JOIN (f
    WHERE f.parent_entity_name="ORDER_SENTENCE"
     AND f.parent_entity_id=os.order_sentence_id
     AND f.filter_entity1_name="LOCATION"
     AND f.filter_entity1_id IN (request->facility_code_value, 0))
   ORDER BY d.seq, os.order_sentence_id, f.filter_entity1_id
   HEAD d.seq
    tcnt = 0, ttcnt = 0, stat = alterlist(reply->synonyms[d.seq].sentences,10)
   HEAD os.order_sentence_id
    tcnt = (tcnt+ 1), ttcnt = (ttcnt+ 1)
    IF (tcnt > 10)
     stat = alterlist(reply->synonyms[d.seq].sentences,(ttcnt+ 10)), tcnt = 1
    ENDIF
    reply->synonyms[d.seq].sentences[ttcnt].sentence_id = os.order_sentence_id, reply->synonyms[d.seq
    ].sentences[ttcnt].display = os.order_sentence_display_line, reply->synonyms[d.seq].sentences[
    ttcnt].encntr_group_code_value = os.order_encntr_group_cd,
    reply->synonyms[d.seq].sentences[ttcnt].sequence = ocsr.display_seq, reply->synonyms[d.seq].
    sentences[ttcnt].usage_flag = os.usage_flag, reply->synonyms[d.seq].sentences[ttcnt].comment_id
     = lt.long_text_id,
    reply->synonyms[d.seq].sentences[ttcnt].comment_txt = lt.long_text, reply->synonyms[d.seq].
    sentences[ttcnt].oe_format_id = os.oe_format_id, reply->synonyms[d.seq].sentences[ttcnt].
    discern_rules_checking = os.discern_auto_verify_flag,
    reply->synonyms[d.seq].sentences[ttcnt].multum_clinical_checking = os.ic_auto_verify_flag
    IF (os.external_identifier IN ("MUL.OP*", "BRMUL.OP*", "MUL.IP*", "BRMUL.IP*")
     AND os.updt_cnt=0)
     reply->synonyms[d.seq].sentences[ttcnt].source = 1
    ELSE
     reply->synonyms[d.seq].sentences[ttcnt].source = 2
    ENDIF
   HEAD f.filter_entity1_id
    IF (f.filter_entity1_id=0)
     reply->synonyms[d.seq].sentences[ttcnt].all_facilities_ind = 1
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->synonyms[d.seq].sentences,ttcnt)
    IF (ttcnt > max_sent_cnt)
     max_sent_cnt = ttcnt
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck(
   "ERROR 004: select from ord_cat_sent_r, order_sentence, filter_entity_reltn, long_text lt tables failed"
   )
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(stcnt)),
    (dummyt d2  WITH seq = 1),
    filter_entity_reltn f,
    code_value cv
   PLAN (d1
    WHERE maxrec(d2,size(reply->synonyms[d1.seq].sentences,5)))
    JOIN (d2)
    JOIN (f
    WHERE f.parent_entity_name="ORDER_SENTENCE"
     AND (f.parent_entity_id=reply->synonyms[d1.seq].sentences[d2.seq].sentence_id)
     AND f.filter_entity1_name="LOCATION"
     AND f.filter_entity1_id > 0)
    JOIN (cv
    WHERE cv.code_value=f.filter_entity1_id)
   ORDER BY cv.code_value
   HEAD REPORT
    dtcnt = 0
   HEAD cv.code_value
    dtcnt = (dtcnt+ 1), stat = alterlist(reply->synonyms[d1.seq].sentences[d2.seq].facilities,dtcnt),
    reply->synonyms[d1.seq].sentences[d2.seq].facilities[dtcnt].facility_code_value = cv.code_value,
    reply->synonyms[d1.seq].sentences[d2.seq].facilities[dtcnt].display = cv.display
   FOOT REPORT
    stat = alterlist(reply->synonyms[d1.seq].sentences[d2.seq].facilities,dtcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 005: select from filter_entity_reltn and code_value tables failed")
 ELSE
  SET max_sent_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(stcnt)),
    ord_cat_sent_r ocsr,
    order_sentence os,
    long_text lt
   PLAN (d)
    JOIN (ocsr
    WHERE (ocsr.synonym_id=reply->synonyms[d.seq].synonym_id)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND (os.usage_flag=request->usage_flag))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
   ORDER BY d.seq
   HEAD d.seq
    tcnt = 0, ttcnt = 0, stat = alterlist(reply->synonyms[d.seq].sentences,10)
   DETAIL
    tcnt = (tcnt+ 1), ttcnt = (ttcnt+ 1)
    IF (tcnt > 10)
     stat = alterlist(reply->synonyms[d.seq].sentences,(ttcnt+ 10)), tcnt = 1
    ENDIF
    reply->synonyms[d.seq].sentences[ttcnt].sentence_id = os.order_sentence_id, reply->synonyms[d.seq
    ].sentences[ttcnt].display = os.order_sentence_display_line, reply->synonyms[d.seq].sentences[
    ttcnt].encntr_group_code_value = os.order_encntr_group_cd,
    reply->synonyms[d.seq].sentences[ttcnt].sequence = ocsr.display_seq, reply->synonyms[d.seq].
    sentences[ttcnt].usage_flag = os.usage_flag, reply->synonyms[d.seq].sentences[ttcnt].comment_id
     = lt.long_text_id,
    reply->synonyms[d.seq].sentences[ttcnt].comment_txt = lt.long_text, reply->synonyms[d.seq].
    sentences[ttcnt].oe_format_id = os.oe_format_id, reply->synonyms[d.seq].sentences[ttcnt].
    discern_rules_checking = os.discern_auto_verify_flag,
    reply->synonyms[d.seq].sentences[ttcnt].multum_clinical_checking = os.ic_auto_verify_flag
    IF (os.external_identifier IN ("MUL.OP*", "BRMUL.OP*", "MUL.IP*", "BRMUL.IP*")
     AND os.updt_cnt=0)
     reply->synonyms[d.seq].sentences[ttcnt].source = 1
    ELSE
     reply->synonyms[d.seq].sentences[ttcnt].source = 2
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->synonyms[d.seq].sentences,ttcnt)
    IF (ttcnt > max_sent_cnt)
     max_sent_cnt = ttcnt
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 006: select from ord_cat_sent_r, order_sentence, long_text tables failed"
   )
 ENDIF
 FOR (x = 1 TO stcnt)
  SET sent_cnt = size(reply->synonyms[x].sentences,5)
  IF (sent_cnt > 0)
   DECLARE order_sentence = vc
   DECLARE order_sentence_full = vc
   DECLARE os_value = vc
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sent_cnt)),
     order_sentence_detail osd,
     order_entry_fields oef,
     oe_format_fields off
    PLAN (d)
     JOIN (osd
     WHERE (osd.order_sentence_id=reply->synonyms[x].sentences[d.seq].sentence_id))
     JOIN (oef
     WHERE oef.oe_field_id=osd.oe_field_id)
     JOIN (off
     WHERE off.oe_field_id=outerjoin(oef.oe_field_id)
      AND off.action_type_cd=outerjoin(action_code)
      AND ((off.oe_format_id+ 0)=outerjoin(reply->synonyms[x].sentences[d.seq].oe_format_id)))
    ORDER BY d.seq, off.group_seq, off.field_seq
    HEAD d.seq
     dcnt = 0, dtcnt = 0, stat = alterlist(reply->synonyms[x].sentences[d.seq].details,10),
     out_of_oe = 0
    DETAIL
     dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
     IF (dcnt > 10)
      stat = alterlist(reply->synonyms[x].sentences[d.seq].details,(dtcnt+ 10)), dcnt = 1
     ENDIF
     IF (osd.default_parent_entity_name > " ")
      reply->synonyms[x].sentences[d.seq].details[dtcnt].field_code_value = osd
      .default_parent_entity_id
     ELSE
      reply->synonyms[x].sentences[d.seq].details[dtcnt].field_code_value = osd.oe_field_value
     ENDIF
     reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = osd.oe_field_display_value,
     reply->synonyms[x].sentences[d.seq].details[dtcnt].field_type_flag = osd.field_type_flag, reply
     ->synonyms[x].sentences[d.seq].details[dtcnt].sequence = osd.sequence,
     reply->synonyms[x].sentences[d.seq].details[dtcnt].oe_field_id = oef.oe_field_id, reply->
     synonyms[x].sentences[d.seq].details[dtcnt].oe_field_label = oef.description
     IF (off.oe_field_id > 0)
      IF (oef.field_type_flag=7)
       IF ((reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value IN ("YES", "1")))
        reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = "Yes"
       ENDIF
       IF ((reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value IN ("NO", "0")))
        reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = "No"
       ENDIF
      ENDIF
      os_value = reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value
      IF (oef.field_type_flag=7)
       IF ((reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value="Yes"))
        IF (oef.oe_field_meaning_id=prn_id)
         os_value = "PRN"
        ELSE
         IF (off.disp_yes_no_flag IN (0, 1))
          os_value = off.label_text
         ELSE
          os_value = ""
         ENDIF
        ENDIF
       ELSEIF ((reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value="No"))
        IF (oef.oe_field_meaning_id=prn_id)
         os_value = ""
        ELSE
         IF (off.disp_yes_no_flag IN (0, 2))
          os_value = off.clin_line_label
         ELSE
          os_value = ""
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (off.clin_line_label > " ")
        IF (off.clin_suffix_ind=1)
         os_value = concat(trim(reply->synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value),
          " ",trim(off.clin_line_label))
        ELSE
         os_value = concat(trim(off.clin_line_label)," ",trim(reply->synonyms[x].sentences[d.seq].
           details[dtcnt].field_disp_value))
        ENDIF
       ENDIF
      ENDIF
      IF (dtcnt=1)
       order_sentence_full = trim(os_value), gseq = off.group_seq
      ELSE
       IF (os_value > " ")
        IF (gseq=off.group_seq)
         order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
        ELSE
         order_sentence_full = concat(trim(order_sentence_full),", ",trim(os_value)), gseq = off
         .group_seq
        ENDIF
       ENDIF
      ENDIF
     ELSE
      out_of_oe = 1
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->synonyms[x].sentences[d.seq].details,dtcnt)
     IF (out_of_oe=0)
      reply->synonyms[x].sentences[d.seq].full_display = trim(order_sentence_full,3)
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 007: select from order_sentence_detail, order_entry_fields, oe_format_fields tables failed"
    )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sent_cnt)),
     order_sentence_filter osf,
     code_value cv_age,
     code_value cv_pma,
     code_value cv_weight
    PLAN (d)
     JOIN (osf
     WHERE (osf.order_sentence_id=reply->synonyms[x].sentences[d.seq].sentence_id))
     JOIN (cv_age
     WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
     JOIN (cv_pma
     WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
     JOIN (cv_weight
     WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
    ORDER BY d.seq, osf.order_sentence_id
    DETAIL
     reply->synonyms[x].sentences[d.seq].filters.order_sentence_filter_id = osf
     .order_sentence_filter_id, reply->synonyms[x].sentences[d.seq].filters.age_min_value = osf
     .age_min_value, reply->synonyms[x].sentences[d.seq].filters.age_max_value = osf.age_max_value,
     reply->synonyms[x].sentences[d.seq].filters.age_unit_cd.code_value = osf.age_unit_cd, reply->
     synonyms[x].sentences[d.seq].filters.age_unit_cd.display = cv_age.display, reply->synonyms[x].
     sentences[d.seq].filters.age_unit_cd.description = cv_age.description,
     reply->synonyms[x].sentences[d.seq].filters.age_unit_cd.mean = cv_age.cdf_meaning, reply->
     synonyms[x].sentences[d.seq].filters.pma_min_value = osf.pma_min_value, reply->synonyms[x].
     sentences[d.seq].filters.pma_max_value = osf.pma_max_value,
     reply->synonyms[x].sentences[d.seq].filters.pma_unit_cd.code_value = osf.pma_unit_cd, reply->
     synonyms[x].sentences[d.seq].filters.pma_unit_cd.display = cv_pma.display, reply->synonyms[x].
     sentences[d.seq].filters.pma_unit_cd.description = cv_pma.description,
     reply->synonyms[x].sentences[d.seq].filters.pma_unit_cd.mean = cv_pma.cdf_meaning, reply->
     synonyms[x].sentences[d.seq].filters.weight_min_value = osf.weight_min_value, reply->synonyms[x]
     .sentences[d.seq].filters.weight_max_value = osf.weight_max_value,
     reply->synonyms[x].sentences[d.seq].filters.weight_unit_cd.code_value = osf.weight_unit_cd,
     reply->synonyms[x].sentences[d.seq].filters.weight_unit_cd.display = cv_weight.display, reply->
     synonyms[x].sentences[d.seq].filters.weight_unit_cd.description = cv_weight.description,
     reply->synonyms[x].sentences[d.seq].filters.weight_unit_cd.mean = cv_weight.cdf_meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 008: select from order_sentence_filter and code_value tables failed")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sent_cnt)),
     filter_entity_reltn f,
     code_value cv
    PLAN (d
     WHERE (reply->synonyms[x].sentences[d.seq].all_facilities_ind=0))
     JOIN (f
     WHERE f.parent_entity_name="ORDER_SENTENCE"
      AND (f.parent_entity_id=reply->synonyms[x].sentences[d.seq].sentence_id)
      AND f.filter_entity1_name="LOCATION")
     JOIN (cv
     WHERE cv.code_value=outerjoin(f.filter_entity1_id))
    ORDER BY d.seq, cv.code_value
    HEAD d.seq
     dcnt = 0, dtcnt = 0, stat = alterlist(reply->synonyms[x].sentences[d.seq].facilities,10)
    HEAD cv.code_value
     IF (cv.code_value=0
      AND f.filter_entity1_id=0)
      reply->synonyms[x].sentences[d.seq].all_facilities_ind = 1
     ELSEIF (cv.code_value > 0)
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(reply->synonyms[x].sentences[d.seq].facilities,(dtcnt+ 10)), dcnt = 1
      ENDIF
      reply->synonyms[x].sentences[d.seq].facilities[dtcnt].facility_code_value = cv.code_value,
      reply->synonyms[x].sentences[d.seq].facilities[dtcnt].display = cv.display
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->synonyms[x].sentences[d.seq].facilities,dtcnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 008: select from filter_entity_reltn and code_value tables failed")
  ENDIF
 ENDFOR
 SET cnt = 0
 SET tot_cnt = 0
 SET stat = alterlist(reply->products,100)
 IF ((request->ignore_facility_ind=0))
  SELECT INTO "nl:"
   FROM order_catalog_item_r ocir,
    medication_definition md,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    item_definition id,
    med_identifier mi
   PLAN (ocir
    WHERE (ocir.catalog_cd=request->catalog_code_value))
    JOIN (md
    WHERE ocir.item_id=md.item_id)
    JOIN (mdf
    WHERE md.item_id=mdf.item_id
     AND mdf.pharmacy_type_cd=inpatient_code_value
     AND mdf.flex_type_cd=sys_pkg_code_value)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND ((mfoi.flex_object_type_cd+ 0)=orderable_code_value)
     AND ((mfoi.parent_entity_id+ 0) IN (0, request->facility_code_value))
     AND mfoi.active_ind=1)
    JOIN (id
    WHERE md.item_id=id.item_id
     AND ((id.active_ind+ 0)=1))
    JOIN (mi
    WHERE mi.item_id=id.item_id
     AND mi.pharmacy_type_cd=inpatient_code_value
     AND mi.med_identifier_type_cd=desc_code_value
     AND ((mi.flex_type_cd+ 0)=system_code_value)
     AND mi.primary_ind=1
     AND ((mi.med_product_id+ 0)=0)
     AND ((mi.active_ind+ 0)=1))
   ORDER BY md.item_id
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->products,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->products[tot_cnt].item_id = md.item_id, reply->products[tot_cnt].description = mi.value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 009: Failed to Select Products from medication_definition table")
  SET stat = alterlist(reply->products,tot_cnt)
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog_item_r ocir,
    medication_definition md,
    med_def_flex mdf,
    item_definition id,
    med_identifier mi
   PLAN (ocir
    WHERE (ocir.catalog_cd=request->catalog_code_value))
    JOIN (md
    WHERE ocir.item_id=md.item_id)
    JOIN (mdf
    WHERE md.item_id=mdf.item_id
     AND mdf.pharmacy_type_cd=inpatient_code_value
     AND mdf.flex_type_cd=sys_pkg_code_value)
    JOIN (id
    WHERE md.item_id=id.item_id
     AND ((id.active_ind+ 0)=1))
    JOIN (mi
    WHERE mi.item_id=id.item_id
     AND mi.pharmacy_type_cd=inpatient_code_value
     AND mi.med_identifier_type_cd=desc_code_value
     AND ((mi.flex_type_cd+ 0)=system_code_value)
     AND mi.primary_ind=1
     AND ((mi.med_product_id+ 0)=0)
     AND ((mi.active_ind+ 0)=1))
   ORDER BY md.item_id
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->products,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->products[tot_cnt].item_id = md.item_id, reply->products[tot_cnt].description = mi.value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 010: Failed to Select Products from medication_definition table")
  SET stat = alterlist(reply->products,tot_cnt)
 ENDIF
 SET syn_cnt = size(reply->synonyms,5)
 IF (syn_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(syn_cnt)),
    synonym_item_r s,
    med_identifier mi
   PLAN (d)
    JOIN (s
    WHERE (s.synonym_id=reply->synonyms[d.seq].synonym_id))
    JOIN (mi
    WHERE mi.item_id=s.item_id
     AND mi.pharmacy_type_cd=inpatient_code_value
     AND mi.med_identifier_type_cd=desc_code_value
     AND ((mi.flex_type_cd+ 0)=system_code_value)
     AND mi.primary_ind=1
     AND ((mi.med_product_id+ 0)=0)
     AND ((mi.active_ind+ 0)=1))
   ORDER BY d.seq
   HEAD d.seq
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->synonyms[d.seq].products,10)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->synonyms[d.seq].products,(tot_cnt+ 10)), cnt = 1
    ENDIF
    reply->synonyms[d.seq].products[tot_cnt].item_id = s.item_id
   FOOT  d.seq
    stat = alterlist(reply->synonyms[d.seq].products,tot_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 011: Select from synonym_item_r and med_identifier tables failed")
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
