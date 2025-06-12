CREATE PROGRAM bed_get_os_for_powerplan_comp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_sentence[*]
      2 order_sentence_id = f8
      2 order_sentence_display_line = vc
      2 sequence = i4
      2 os_oe_format_id = f8
      2 rx_type_mean = vc
      2 intermittent_ind = i2
      2 details[*]
        3 oef_id = f8
        3 value = f8
        3 display = vc
        3 sequence = i4
        3 oef_description = vc
        3 field_type_flag = i2
      2 comment = vc
      2 filters
        3 order_sentence_filter_id = f8
        3 age_min_value = f8
        3 age_max_value = f8
        3 age_unit_cd
          4 code_value = f8
          4 display = vc
          4 mean = vc
          4 description = vc
        3 pma_min_value = f8
        3 pma_max_value = f8
        3 pma_unit_cd
          4 code_value = f8
          4 display = vc
          4 mean = vc
          4 description = vc
        3 weight_min_value = f8
        3 weight_max_value = f8
        3 weight_unit_cd
          4 code_value = f8
          4 display = vc
          4 mean = vc
          4 description = vc
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
 CALL bedbeginscript(0)
 DECLARE os_count = i4 WITH protect, noconstant(0)
 DECLARE os_detail_count = i4 WITH protect, noconstant(0)
 DECLARE pathway_count = i4 WITH protect, noconstant(0)
 DECLARE usage_flag_parser = vc WITH noconstant(" ")
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
 SET pathway_count = size(request->pathway_comp,5)
 FOR (x = 1 TO pathway_count)
   IF ((request->pathway_comp[pathway_count].pathway_comp_id=0))
    CALL bederror("Error 001 - A component id must be passed!")
   ENDIF
 ENDFOR
 SET usage_flag_parser = concat("os.usage_flag >= 0")
 IF (size(request->usage_flags,5) > 0)
  FOR (i = 1 TO size(request->usage_flags,5))
    IF (i=1)
     SET usage_flag_parser = build2("os.usage_flag = ",value(request->usage_flags[i].flag))
    ELSE
     SET usage_flag_parser = build2(usage_flag_parser," or os.usage_flag = ",value(request->
       usage_flags[i].flag))
    ENDIF
  ENDFOR
 ENDIF
 CALL echo(usage_flag_parser)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = pathway_count),
   pw_comp_os_reltn pcor,
   order_sentence os,
   long_text lt
  PLAN (d)
   JOIN (pcor
   WHERE (pcor.pathway_comp_id=request->pathway_comp[d.seq].pathway_comp_id)
    AND (pcor.iv_comp_syn_id=request->pathway_comp[d.seq].iv_comp_syn_id))
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND parser(usage_flag_parser))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
  ORDER BY d.seq, pcor.pathway_comp_id, pcor.order_sentence_seq
  DETAIL
   IF (((pcor.iv_comp_syn_id=0) OR ((request->pathway_comp[d.seq].iv_comp_syn_id > 0))) )
    os_count = (os_count+ 1), stat = alterlist(reply->order_sentence,os_count), reply->
    order_sentence[os_count].order_sentence_id = pcor.order_sentence_id
    IF (pcor.os_display_line != null
     AND pcor.os_display_line != "")
     reply->order_sentence[os_count].order_sentence_display_line = trim(pcor.os_display_line)
    ELSE
     reply->order_sentence[os_count].order_sentence_display_line = trim(os
      .order_sentence_display_line)
    ENDIF
    reply->order_sentence[os_count].sequence = pcor.order_sentence_seq, reply->order_sentence[
    os_count].os_oe_format_id = os.oe_format_id, reply->order_sentence[os_count].rx_type_mean = os
    .rx_type_mean,
    reply->order_sentence[os_count].comment = lt.long_text
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrieve order sentences.")
 IF (os_count > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = os_count),
    order_sentence_detail osd,
    order_entry_fields oef
   PLAN (d)
    JOIN (osd
    WHERE (osd.order_sentence_id=reply->order_sentence[d.seq].order_sentence_id))
    JOIN (oef
    WHERE oef.oe_field_id=osd.oe_field_id
     AND oef.oe_field_meaning_id=osd.oe_field_meaning_id)
   ORDER BY d.seq, osd.sequence
   HEAD d.seq
    os_detail_count = 0
   DETAIL
    os_detail_count = (os_detail_count+ 1), stat = alterlist(reply->order_sentence[d.seq].details,
     os_detail_count), reply->order_sentence[d.seq].details[os_detail_count].oef_id = osd.oe_field_id
    IF (osd.field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))
     reply->order_sentence[d.seq].details[os_detail_count].value = osd.oe_field_value
    ELSEIF (osd.field_type_flag IN (6, 8, 9, 10, 12,
    13))
     reply->order_sentence[d.seq].details[os_detail_count].value = osd.default_parent_entity_id
    ENDIF
    reply->order_sentence[d.seq].details[os_detail_count].display = osd.oe_field_display_value, reply
    ->order_sentence[d.seq].details[os_detail_count].sequence = osd.sequence, reply->order_sentence[d
    .seq].details[os_detail_count].oef_description = oef.description,
    reply->order_sentence[d.seq].details[os_detail_count].field_type_flag = oef.field_type_flag
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed to retrieve order sentence details.")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = os_count),
    order_sentence_filter osf,
    code_value cv_age,
    code_value cv_pma,
    code_value cv_weight
   PLAN (d)
    JOIN (osf
    WHERE (osf.order_sentence_id=reply->order_sentence[d.seq].order_sentence_id))
    JOIN (cv_age
    WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
    JOIN (cv_pma
    WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
    JOIN (cv_weight
    WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
   ORDER BY d.seq, osf.order_sentence_id
   DETAIL
    reply->order_sentence[d.seq].filters.order_sentence_filter_id = osf.order_sentence_filter_id,
    reply->order_sentence[d.seq].filters.age_min_value = osf.age_min_value, reply->order_sentence[d
    .seq].filters.age_max_value = osf.age_max_value,
    reply->order_sentence[d.seq].filters.age_unit_cd.code_value = osf.age_unit_cd, reply->
    order_sentence[d.seq].filters.age_unit_cd.display = cv_age.display, reply->order_sentence[d.seq].
    filters.age_unit_cd.description = cv_age.description,
    reply->order_sentence[d.seq].filters.age_unit_cd.mean = cv_age.cdf_meaning, reply->
    order_sentence[d.seq].filters.pma_min_value = osf.pma_min_value, reply->order_sentence[d.seq].
    filters.pma_max_value = osf.pma_max_value,
    reply->order_sentence[d.seq].filters.pma_unit_cd.code_value = osf.pma_unit_cd, reply->
    order_sentence[d.seq].filters.pma_unit_cd.display = cv_pma.display, reply->order_sentence[d.seq].
    filters.pma_unit_cd.description = cv_pma.description,
    reply->order_sentence[d.seq].filters.pma_unit_cd.mean = cv_pma.cdf_meaning, reply->
    order_sentence[d.seq].filters.weight_min_value = osf.weight_min_value, reply->order_sentence[d
    .seq].filters.weight_max_value = osf.weight_max_value,
    reply->order_sentence[d.seq].filters.weight_unit_cd.code_value = osf.weight_unit_cd, reply->
    order_sentence[d.seq].filters.weight_unit_cd.display = cv_weight.display, reply->order_sentence[d
    .seq].filters.weight_unit_cd.description = cv_weight.description,
    reply->order_sentence[d.seq].filters.weight_unit_cd.mean = cv_weight.cdf_meaning
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed to retrieve order sentence filter.")
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
