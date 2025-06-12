CREATE PROGRAM bed_get_cust_interactions:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 batch_list[*]
      2 drug_class_int_custom_id = f8
      2 combo_ind = i2
      2 custom_type_flag = i2
      2 custom_interaction_flag = i2
      2 class1_ident = vc
      2 entity1_display = vc
      2 class2_ident = vc
      2 entity2_display = vc
      2 long_text = vc
      2 last_updt_dt_tm = dq8
      2 custom_list[*]
        3 dcp_entity_reltn_id = f8
        3 entity1_id = f8
        3 entity1_display = vc
        3 entity1_name = vc
        3 entity2_id = f8
        3 entity2_display = vc
        3 custom_severity_level = i4
        3 entity_reltn_mean = vc
        3 begin_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 custom_alert_long_text = vc
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
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 DECLARE populatecustominteractions(null) = null
 DECLARE populatebatchcustominteractions(null) = null
 IF ((((request->custom_type_flag=3)
  AND (request->combo_ind=0)) OR ((request->combo_ind=0)
  AND (request->custom_type_flag=0))) )
  CALL populatecustominteractions(null)
 ELSE
  CALL populatebatchcustominteractions(null)
 ENDIF
 SUBROUTINE populatecustominteractions(null)
   SELECT INTO "nl:"
    FROM dcp_entity_reltn d,
     long_text l
    PLAN (d
     WHERE (d.entity_reltn_mean=request->entity_reltn_mean)
      AND d.active_ind=1
      AND d.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (l
     WHERE l.parent_entity_id=outerjoin(d.dcp_entity_reltn_id)
      AND l.parent_entity_name=outerjoin("DCP_ENTITY_RELTN"))
    ORDER BY d.entity1_display
    HEAD REPORT
     stat = alterlist(reply->batch_list,1), stat = alterlist(reply->batch_list[1].custom_list,10),
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->batch_list[1].custom_list,(count1+ 9))
     ENDIF
     reply->batch_list[1].custom_list[count1].dcp_entity_reltn_id = d.dcp_entity_reltn_id, reply->
     batch_list[1].custom_list[count1].entity1_id = d.entity1_id, reply->batch_list[1].custom_list[
     count1].entity1_display = d.entity1_display
     IF (isnumeric(d.entity1_name)=1)
      reply->batch_list[1].custom_list[count1].entity1_name = d.entity1_name
     ELSE
      reply->batch_list[1].custom_list[count1].entity1_name = "0"
     ENDIF
     reply->batch_list[1].custom_list[count1].entity2_id = d.entity2_id, reply->batch_list[1].
     custom_list[count1].entity2_display = d.entity2_display, reply->batch_list[1].custom_list[count1
     ].custom_severity_level = d.rank_sequence,
     reply->batch_list[1].custom_list[count1].entity_reltn_mean = d.entity_reltn_mean, reply->
     batch_list[1].custom_list[count1].begin_effective_dt_tm = cnvtdatetime(d.begin_effective_dt_tm),
     reply->batch_list[1].custom_list[count1].end_effective_dt_tm = cnvtdatetime(d
      .end_effective_dt_tm),
     reply->batch_list[1].custom_list[count1].custom_alert_long_text = l.long_text
    FOOT REPORT
     stat = alterlist(reply->batch_list[1].custom_list,count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE populatebatchcustominteractions(null)
  SELECT INTO "nl:"
   FROM drug_class_int_custom dcc,
    drug_class_int_cstm_entity_r dcer,
    dcp_entity_reltn der,
    long_text lt
   PLAN (dcc
    WHERE (dcc.custom_type_flag=request->custom_type_flag)
     AND (dcc.custom_interaction_flag=request->custom_interaction_flag))
    JOIN (dcer
    WHERE dcer.drug_class_int_custom_id=dcc.drug_class_int_custom_id)
    JOIN (der
    WHERE der.dcp_entity_reltn_id=dcer.dcp_entity_reltn_id)
    JOIN (lt
    WHERE lt.long_text_id=dcc.long_text_id)
   ORDER BY dcc.drug_class_int_custom_id, dcer.drug_class_int_cstm_ent_r_id
   HEAD REPORT
    batchcnt = 0
   HEAD dcc.drug_class_int_custom_id
    batchcnt = (batchcnt+ 1), custom_drug_cnt = 0
    IF (mod(batchcnt,5)=1)
     stat = alterlist(reply->batch_list,(batchcnt+ 4))
    ENDIF
    reply->batch_list[batchcnt].drug_class_int_custom_id = dcc.drug_class_int_custom_id, reply->
    batch_list[batchcnt].custom_type_flag = dcc.custom_type_flag, reply->batch_list[batchcnt].
    custom_interaction_flag = dcc.custom_interaction_flag,
    reply->batch_list[batchcnt].combo_ind = dcc.combo_ind, reply->batch_list[batchcnt].class1_ident
     = dcc.entity1_ident, reply->batch_list[batchcnt].entity1_display = dcc.entity1_display,
    reply->batch_list[batchcnt].class2_ident = dcc.entity2_ident, reply->batch_list[batchcnt].
    entity2_display = dcc.entity2_display, reply->batch_list[batchcnt].long_text = lt.long_text,
    reply->batch_list[batchcnt].last_updt_dt_tm = cnvtdatetime(dcc.updt_dt_tm)
   HEAD dcer.drug_class_int_cstm_ent_r_id
    custom_drug_cnt = (custom_drug_cnt+ 1)
    IF (mod(custom_drug_cnt,5)=1)
     stat = alterlist(reply->batch_list[batchcnt].custom_list,(custom_drug_cnt+ 4))
    ENDIF
    reply->batch_list[batchcnt].custom_list[custom_drug_cnt].dcp_entity_reltn_id = der
    .dcp_entity_reltn_id, reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity1_id = der
    .entity1_id, reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity2_id = der.entity2_id,
    reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity1_display = der.entity1_display,
    reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity2_display = der.entity2_display,
    reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity_reltn_mean = der
    .entity_reltn_mean
    IF (isnumeric(der.entity1_name)=1)
     reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity1_name = der.entity1_name
    ELSE
     reply->batch_list[batchcnt].custom_list[custom_drug_cnt].entity1_name = "0"
    ENDIF
    reply->batch_list[batchcnt].custom_list[custom_drug_cnt].custom_severity_level = der
    .rank_sequence, reply->batch_list[batchcnt].custom_list[custom_drug_cnt].begin_effective_dt_tm =
    cnvtdatetime(der.begin_effective_dt_tm), reply->batch_list[batchcnt].custom_list[custom_drug_cnt]
    .end_effective_dt_tm = cnvtdatetime(der.end_effective_dt_tm)
   FOOT  dcc.drug_class_int_custom_id
    stat = alterlist(reply->batch_list[batchcnt].custom_list,custom_drug_cnt)
   FOOT REPORT
    stat = alterlist(reply->batch_list,batchcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 02: Failed to retrie batch active customizations")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
