CREATE PROGRAM bed_copy_mpage_for_pos:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(br_datamart_value_rows,0)))
  RECORD br_datamart_value_rows(
    1 rows[*]
      2 br_datamart_filter_id = f8
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 freetext_desc = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 br_datamart_category_id = f8
      2 value_seq = i4
      2 value_type_flag = i4
      2 qualifier_flag = i4
      2 group_seq = i4
      2 mpage_param_mean = vc
      2 mpage_param_value = vc
      2 parent_entity_id2 = f8
      2 parent_entity_name2 = vc
      2 logical_domain_id = f8
      2 br_datamart_flex_id = f8
      2 map_data_type_cd = f8
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
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE flex_id = f8 WITH protect, noconstant(0)
 DECLARE new_datamart_value = f8 WITH protect, noconstant(0)
 DECLARE copympages(frompositioncd=f8,topositioncd=f8) = i2
 CALL copympages(request->copy_from_position_cd,request->copy_to_position_cd)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE copympages(frompositioncd,topositioncd)
   CALL bedlogmessage("copyMPages","Entering...")
   SELECT INTO "nl:"
    FROM br_datamart_value bdv,
     br_datamart_flex bdf
    WHERE bdv.br_datamart_flex_id=bdf.br_datamart_flex_id
     AND bdf.parent_entity_id=frompositioncd
     AND bdf.parent_entity_name="CODE_VALUE"
    DETAIL
     row_cnt = (row_cnt+ 1), stat = alterlist(br_datamart_value_rows->rows,row_cnt),
     br_datamart_value_rows->rows[row_cnt].br_datamart_filter_id = bdv.br_datamart_filter_id,
     br_datamart_value_rows->rows[row_cnt].parent_entity_name = bdv.parent_entity_name,
     br_datamart_value_rows->rows[row_cnt].parent_entity_id = bdv.parent_entity_id,
     br_datamart_value_rows->rows[row_cnt].freetext_desc = bdv.freetext_desc,
     br_datamart_value_rows->rows[row_cnt].beg_effective_dt_tm = bdv.beg_effective_dt_tm,
     br_datamart_value_rows->rows[row_cnt].end_effective_dt_tm = bdv.end_effective_dt_tm,
     br_datamart_value_rows->rows[row_cnt].br_datamart_category_id = bdv.br_datamart_category_id,
     br_datamart_value_rows->rows[row_cnt].value_seq = bdv.value_seq, br_datamart_value_rows->rows[
     row_cnt].value_type_flag = bdv.value_type_flag, br_datamart_value_rows->rows[row_cnt].
     qualifier_flag = bdv.qualifier_flag,
     br_datamart_value_rows->rows[row_cnt].group_seq = bdv.group_seq, br_datamart_value_rows->rows[
     row_cnt].mpage_param_mean = bdv.mpage_param_mean, br_datamart_value_rows->rows[row_cnt].
     mpage_param_value = bdv.mpage_param_value,
     br_datamart_value_rows->rows[row_cnt].parent_entity_id2 = bdv.parent_entity_id2,
     br_datamart_value_rows->rows[row_cnt].parent_entity_name2 = bdv.parent_entity_name2,
     br_datamart_value_rows->rows[row_cnt].logical_domain_id = bdv.logical_domain_id,
     br_datamart_value_rows->rows[row_cnt].br_datamart_flex_id = bdv.br_datamart_flex_id,
     br_datamart_value_rows->rows[row_cnt].map_data_type_cd = bdv.map_data_type_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(br_datamart_value_rows)
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_flex bdf
    WHERE bdf.parent_entity_id=topositioncd
     AND bdf.parent_entity_name="CODE_VALUE"
    DETAIL
     flex_id = bdf.br_datamart_flex_id
    WITH nocounter
   ;end select
   IF (flex_id=0)
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      flex_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_datamart_flex bdf
     SET bdf.br_datamart_flex_id = flex_id, bdf.grouper_flex_id = 0.0, bdf.parent_entity_name =
      "CODE_VALUE",
      bdf.parent_entity_type_flag = 1, bdf.parent_entity_id = topositioncd, bdf.updt_applctx =
      reqinfo->updt_applctx,
      bdf.updt_cnt = 0, bdf.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdf.updt_id = reqinfo->
      updt_id,
      bdf.updt_task = 3202004
    ;end insert
   ENDIF
   FOR (i = 1 TO size(br_datamart_value_rows->rows,5))
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      new_datamart_value = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_datamart_value bdv
     SET bdv.br_datamart_value_id = new_datamart_value, bdv.br_datamart_flex_id = flex_id, bdv
      .br_datamart_filter_id = br_datamart_value_rows->rows[i].br_datamart_filter_id,
      bdv.parent_entity_name = br_datamart_value_rows->rows[i].parent_entity_name, bdv
      .parent_entity_id = br_datamart_value_rows->rows[i].parent_entity_id, bdv.freetext_desc =
      br_datamart_value_rows->rows[i].freetext_desc,
      bdv.beg_effective_dt_tm = cnvtdatetime(br_datamart_value_rows->rows[i].beg_effective_dt_tm),
      bdv.end_effective_dt_tm = cnvtdatetime(br_datamart_value_rows->rows[i].end_effective_dt_tm),
      bdv.br_datamart_category_id = br_datamart_value_rows->rows[i].br_datamart_category_id,
      bdv.value_seq = br_datamart_value_rows->rows[i].value_seq, bdv.value_type_flag =
      br_datamart_value_rows->rows[i].value_type_flag, bdv.qualifier_flag = br_datamart_value_rows->
      rows[i].qualifier_flag,
      bdv.group_seq = br_datamart_value_rows->rows[i].group_seq, bdv.mpage_param_mean =
      br_datamart_value_rows->rows[i].mpage_param_mean, bdv.mpage_param_value =
      br_datamart_value_rows->rows[i].mpage_param_value,
      bdv.parent_entity_id2 = br_datamart_value_rows->rows[i].parent_entity_id2, bdv
      .parent_entity_name2 = br_datamart_value_rows->rows[i].parent_entity_name2, bdv
      .logical_domain_id = br_datamart_value_rows->rows[i].logical_domain_id,
      bdv.map_data_type_cd = br_datamart_value_rows->rows[i].map_data_type_cd, bdv.value_dt_tm =
      cnvtdatetime(curdate,curtime3), bdv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bdv.updt_id = reqinfo->updt_id, bdv.updt_task = 3202004, bdv.updt_applctx = reqinfo->
      updt_applctx
    ;end insert
   ENDFOR
   CALL bedlogmessage("copyMPages","Exiting...")
 END ;Subroutine
END GO
