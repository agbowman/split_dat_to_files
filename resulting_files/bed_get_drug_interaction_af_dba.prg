CREATE PROGRAM bed_get_drug_interaction_af:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dnum = vc
    1 drug_name = vc
    1 get_list[*]
      2 entity1_id = f8
      2 entity2_id = f8
      2 dnum1 = vc
      2 drug_name1 = vc
      2 dnum2 = vc
      2 drug_name2 = vc
      2 level = i4
      2 expert_trigger = vc
      2 alert_text = vc
      2 source = vc
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
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE batchcnt = i4 WITH noconstant(0.0)
 SELECT INTO "nl:"
  FROM mltm_drug_name mdn,
   mltm_drug_name_map mdnm
  PLAN (mdnm
   WHERE (mdnm.drug_identifier=request->drug_identifier)
    AND mdnm.function_id=16)
   JOIN (mdn
   WHERE mdnm.drug_synonym_id=mdn.drug_synonym_id)
  DETAIL
   reply->dnum = request->drug_identifier, reply->drug_name = mdn.drug_name
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error while fetching drug name")
 SELECT INTO "nl:"
  FROM mltm_combination_drug mcd,
   mltm_int_drug_interactions midi,
   mltm_drug_name mdn,
   mltm_drug_name_map mdnm,
   mltm_drug_name mdn2,
   mltm_drug_name_map mdnm2,
   mltm_interaction_description mid
  PLAN (mcd
   WHERE (mcd.drug_identifier=request->drug_identifier))
   JOIN (midi
   WHERE ((mcd.member_drug_identifier=midi.drug_identifier_1) OR (mcd.member_drug_identifier=midi
   .drug_identifier_2)) )
   JOIN (mid
   WHERE midi.int_id=mid.int_id)
   JOIN (mdnm
   WHERE mdnm.drug_identifier=midi.drug_identifier_1
    AND mdnm.function_id=16)
   JOIN (mdn
   WHERE mdnm.drug_synonym_id=mdn.drug_synonym_id)
   JOIN (mdnm2
   WHERE mdnm2.drug_identifier=midi.drug_identifier_2
    AND mdnm2.function_id=16)
   JOIN (mdn2
   WHERE mdnm2.drug_synonym_id=mdn2.drug_synonym_id)
  ORDER BY mcd.member_drug_identifier
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->get_list,count1), reply->get_list[count1].dnum1 =
   mcd.member_drug_identifier,
   reply->get_list[count1].entity1_id = cnvtreal(trim(substring(2,5,mcd.member_drug_identifier)))
   IF (mcd.member_drug_identifier=midi.drug_identifier_1)
    reply->get_list[count1].drug_name1 = mdn.drug_name
   ELSE
    reply->get_list[count1].drug_name1 = mdn2.drug_name
   ENDIF
   IF (mcd.member_drug_identifier=midi.drug_identifier_1)
    reply->get_list[count1].dnum2 = midi.drug_identifier_2, reply->get_list[count1].entity2_id =
    cnvtreal(trim(substring(2,5,midi.drug_identifier_2)))
   ELSE
    reply->get_list[count1].dnum2 = midi.drug_identifier_1, reply->get_list[count1].entity2_id =
    cnvtreal(trim(substring(2,5,midi.drug_identifier_1)))
   ENDIF
   IF (mcd.member_drug_identifier=midi.drug_identifier_1)
    reply->get_list[count1].drug_name2 = mdn2.drug_name
   ELSE
    reply->get_list[count1].drug_name2 = mdn.drug_name
   ENDIF
   reply->get_list[count1].alert_text = mid.int_desc_text, reply->get_list[count1].source = "Multum"
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error while fetching the drug combinations details")
 IF (count1=0)
  SELECT INTO "nl:"
   FROM mltm_int_drug_interactions midi,
    mltm_drug_name mdn,
    mltm_drug_name_map mdnm,
    mltm_drug_name mdn2,
    mltm_drug_name_map mdnm2,
    mltm_interaction_description mid
   PLAN (midi
    WHERE (((midi.drug_identifier_1=request->drug_identifier)) OR ((midi.drug_identifier_2=request->
    drug_identifier))) )
    JOIN (mid
    WHERE midi.int_id=mid.int_id)
    JOIN (mdnm
    WHERE mdnm.drug_identifier=midi.drug_identifier_1
     AND mdnm.function_id=16)
    JOIN (mdn
    WHERE mdnm.drug_synonym_id=mdn.drug_synonym_id)
    JOIN (mdnm2
    WHERE mdnm2.drug_identifier=midi.drug_identifier_2
     AND mdnm2.function_id=16)
    JOIN (mdn2
    WHERE mdnm2.drug_synonym_id=mdn2.drug_synonym_id)
   ORDER BY midi.drug_identifier_1, midi.drug_identifier_2
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->get_list,count1), reply->get_list[count1].dnum1 =
    request->drug_identifier,
    reply->get_list[count1].entity1_id = cnvtreal(trim(substring(2,5,request->drug_identifier)))
    IF ((request->drug_identifier=midi.drug_identifier_1))
     reply->get_list[count1].drug_name1 = mdn.drug_name
    ELSE
     reply->get_list[count1].drug_name1 = mdn2.drug_name
    ENDIF
    IF ((request->drug_identifier=midi.drug_identifier_1))
     reply->get_list[count1].dnum2 = midi.drug_identifier_2, reply->get_list[count1].entity2_id =
     cnvtreal(trim(substring(2,5,midi.drug_identifier_2)))
    ELSE
     reply->get_list[count1].dnum2 = midi.drug_identifier_1, reply->get_list[count1].entity2_id =
     cnvtreal(trim(substring(2,5,midi.drug_identifier_1)))
    ENDIF
    IF ((request->drug_identifier=midi.drug_identifier_1))
     reply->get_list[count1].drug_name2 = mdn2.drug_name
    ELSE
     reply->get_list[count1].drug_name2 = mdn.drug_name
    ENDIF
    reply->get_list[count1].alert_text = mid.int_desc_text, reply->get_list[count1].source = "Multum"
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error while populating single drug details if there is no combination")
 ENDIF
 IF (count1 > 0)
  SELECT INTO "nl:"
   FROM dcp_entity_reltn der,
    long_text l,
    (dummyt d  WITH seq = value(count1))
   PLAN (d)
    JOIN (der
    WHERE der.entity_reltn_mean="DRUG/RULE"
     AND (((der.entity1_id=reply->get_list[d.seq].entity1_id)
     AND (der.entity2_id=reply->get_list[d.seq].entity2_id)) OR ((der.entity1_id=reply->get_list[d
    .seq].entity2_id)
     AND (der.entity2_id=reply->get_list[d.seq].entity1_id)))
     AND der.active_ind=1
     AND der.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND der.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.parent_entity_name="DCP_ENTITY_RELTN"
     AND l.parent_entity_id=der.dcp_entity_reltn_id)
   DETAIL
    reply->get_list[d.seq].level = der.rank_sequence, reply->get_list[d.seq].expert_trigger = l
    .long_text
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error populating level and trigger info")
  SELECT INTO "nl:"
   FROM dcp_entity_reltn der,
    long_text l,
    (dummyt d  WITH seq = value(count1))
   PLAN (d)
    JOIN (der
    WHERE der.entity_reltn_mean="DRUG/DRUG"
     AND (((der.entity1_id=reply->get_list[d.seq].entity1_id)
     AND (der.entity2_id=reply->get_list[d.seq].entity2_id)) OR ((der.entity1_id=reply->get_list[d
    .seq].entity2_id)
     AND (der.entity2_id=reply->get_list[d.seq].entity1_id)))
     AND der.active_ind=1
     AND der.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND der.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.parent_entity_name="DCP_ENTITY_RELTN"
     AND l.parent_entity_id=der.dcp_entity_reltn_id)
   DETAIL
    reply->get_list[d.seq].level = der.rank_sequence, reply->get_list[d.seq].alert_text = l.long_text,
    reply->get_list[d.seq].source = "Client"
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error populating custom text details")
  SELECT INTO "nl:"
   dcp.dcp_entity_reltn_id
   FROM dcp_entity_reltn dcp,
    drug_class_int_cstm_entity_r dcer,
    (dummyt d  WITH seq = value(count1))
   PLAN (d)
    JOIN (dcp
    WHERE (((dcp.entity1_id=reply->get_list[d.seq].entity1_id)
     AND (dcp.entity2_id=reply->get_list[d.seq].entity2_id)) OR ((dcp.entity1_id=reply->get_list[d
    .seq].entity2_id)
     AND (dcp.entity2_id=reply->get_list[d.seq].entity1_id)))
     AND dcp.entity_reltn_mean="DRUG/DRUG")
    JOIN (dcer
    WHERE dcer.dcp_entity_reltn_id=dcp.dcp_entity_reltn_id)
   HEAD REPORT
    batchcnt = 0
   DETAIL
    batchcnt = (batchcnt+ 1)
    IF (batchcnt > 0)
     reply->get_list[d.seq].source = "Client-Batch"
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error populating batch details")
 ENDIF
 CALL echorecord(reply)
#exit_script
 CALL bedexitscript(0)
END GO
