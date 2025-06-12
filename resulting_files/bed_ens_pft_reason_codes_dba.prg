CREATE PROGRAM bed_ens_pft_reason_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reason_codes[*]
      2 code_value = f8
    1 error_code = vc
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(request_cv,0)))
  RECORD request_cv(
    1 cd_value_list[1]
      2 action_flag = i2
      2 cdf_meaning = vc
      2 cki = vc
      2 code_set = i4
      2 code_value = f8
      2 collation_seq = i4
      2 concept_cki = vc
      2 definition = vc
      2 description = vc
      2 display = vc
      2 begin_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 active_ind = i2
      2 display_key = vc
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
 IF ( NOT (validate(cs48_active)))
  DECLARE cs48_active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs48_inactive)))
  DECLARE cs48_inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 IF ( NOT (validate(cs29904_technical)))
  DECLARE cs29904_technical = f8 WITH protect, constant(uar_get_code_by("MEANING",29904,"TECHNICAL"))
 ENDIF
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE client_defined_code_set = i4 WITH protect, constant(24730)
 DECLARE current_reason_code_index = i4 WITH protect, noconstant(0)
 DECLARE reason_code_cnt = i4 WITH protect, noconstant(0)
 DECLARE repcnt = i4 WITH protect, noconstant(0)
 DECLARE insertreasoncode(current_reason_code_index=i2) = null
 DECLARE updatereasoncode(current_reason_code_index=i2) = null
 DECLARE deletereasoncode(current_reason_code_index=i2) = null
 SET reason_code_cnt = size(request->reason_codes,5)
 FOR (current_reason_code_index = 1 TO reason_code_cnt)
   IF ((request->reason_codes[current_reason_code_index].action_flag=1))
    CALL insertreasoncode(current_reason_code_index)
   ELSEIF ((request->reason_codes[current_reason_code_index].action_flag=2))
    CALL updatereasoncode(current_reason_code_index)
   ELSEIF ((request->reason_codes[current_reason_code_index].action_flag=3))
    CALL deletereasoncode(current_reason_code_index)
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE insertreasoncode(current_reason_code_index)
   SET next_code = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.display=trim(request->reason_codes[current_reason_code_index].display)
    DETAIL
     next_code = cv.code_value, repcnt = (repcnt+ 1), stat = alterlist(reply->reason_codes,repcnt),
     reply->reason_codes[repcnt].code_value = next_code
    WITH nocounter
   ;end select
   CALL bederrorcheck(concat(
     "Error001: Error while selecting from the code_value table for display: ",request->reason_codes[
     current_reason_code_index].display))
   IF (curqual=0)
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = client_defined_code_set
    SET request_cv->cd_value_list[1].display = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].description = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].definition = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].concept_cki = " "
    SET request_cv->cd_value_list[1].collation_seq = 0
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET next_code = reply_cv->qual[1].code_value
     SET repcnt = (repcnt+ 1)
     SET stat = alterlist(reply->reason_codes,repcnt)
     SET reply->reason_codes[repcnt].code_value = next_code
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Error creating new code_value for ",request->reason_codes[
      current_reason_code_index].display)
     GO TO exit_script
    ENDIF
   ENDIF
   SET newid = 0.0
   SELECT INTO "nl:"
    nid = seq(pft_ref_seq,nextval)
    FROM dual
    DETAIL
     newid = cnvtreal(nid)
    WITH format, counter
   ;end select
   CALL bederrorcheck(concat("Error002: Error creating new pft id for ",request->reason_codes[
     current_reason_code_index].display))
   IF ((request->reason_codes[current_reason_code_index].reason_type_code_value=cs29904_technical))
    SET prio = 1
   ELSE
    SET prio = 0
   ENDIF
   INSERT  FROM pft_denial_code_ref pdcr
    SET pdcr.pft_denial_code_ref_id = newid, pdcr.denial_cd = next_code, pdcr.denial_type_cd =
     request->reason_codes[current_reason_code_index].reason_type_code_value,
     pdcr.denial_group_cd = request->reason_codes[current_reason_code_index].reason_group_code_value,
     pdcr.logical_domain_id = logical_domain_id, pdcr.priority_level = prio,
     pdcr.autowriteoff_ind = 0, pdcr.trans_alias_cd = 0.0, pdcr.process_ind = 0,
     pdcr.updt_id = reqinfo->updt_id, pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pdcr
     .updt_task = reqinfo->updt_task,
     pdcr.updt_applctx = reqinfo->updt_applctx, pdcr.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck(concat("Error 003: Error creating new pft row for ",request->reason_codes[
     current_reason_code_index].display))
   IF ((request->reason_codes[current_reason_code_index].alias > " "))
    SELECT INTO "NL:"
     FROM pft_alias pa
     WHERE pa.parent_entity_name="DEFAULT"
      AND pa.code_value=next_code
     WITH nocounter
    ;end select
    CALL bederrorcheck(concat("Error 004: Error creating new pft_alias row for ",request->
      reason_codes[current_reason_code_index].display))
    IF (curqual=0)
     INSERT  FROM pft_alias pa
      SET pa.seq = 1, pa.parent_entity_name = "DEFAULT", pa.parent_entity_id = next_code,
       pa.alias = request->reason_codes[current_reason_code_index].alias, pa.code_value = next_code,
       pa.updt_id = reqinfo->updt_id,
       pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_task = reqinfo->updt_task, pa
       .updt_applctx = reqinfo->updt_applctx,
       pa.updt_cnt = 0, pa.active_ind = 1, pa.active_status_cd = cs48_active,
       pa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pa.active_status_prsnl_id = reqinfo->
       updt_id, pa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter
     ;end insert
     CALL bederrorcheck(concat("Error005: Error creating new pft_alias row for ",request->
       reason_codes[current_reason_code_index].display))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updatereasoncode(current_reason_code_index)
   DECLARE display = vc WITH protect, noconstant("")
   DECLARE alias = vc WITH protect, noconstant("")
   DECLARE postval = i2 WITH protect, noconstant(- (1))
   DECLARE original_postval = i2 WITH protect, noconstant(- (1))
   DECLARE code_set = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->reason_codes[current_reason_code_index].code_value)
    DETAIL
     code_set = cv.code_set
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE (code_value=request->reason_codes[current_reason_code_index].code_value)
    DETAIL
     display = cnvtupper(trim(cv.display))
    WITH nocounter
   ;end select
   CALL bederrorcheck(concat(
     "Error 006: Error while selecting code_value from the code_value table: ",cnvtstring(request->
      reason_codes[current_reason_code_index].code_value)))
   IF (display != cnvtupper(trim(request->reason_codes[current_reason_code_index].display)))
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_value = request->reason_codes[current_reason_code_index].
    code_value
    SET request_cv->cd_value_list[1].code_set = client_defined_code_set
    SET request_cv->cd_value_list[1].display = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].description = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].definition = request->reason_codes[current_reason_code_index].
    display
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].concept_cki = " "
    SET request_cv->cd_value_list[1].collation_seq = 0
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S"))
     SET next_code = reply_cv->qual[1].code_value
     SET repcnt = (repcnt+ 1)
     SET stat = alterlist(reply->reason_codes,repcnt)
     SET reply->reason_codes[repcnt].code_value = next_code
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Error updating a code_value for ",cnvtstring(request->reason_codes[
       current_reason_code_index].code_value))
     GO TO exit_script
    ENDIF
   ENDIF
   SET cnt = 0
   SELECT INTO "NL:"
    FROM pft_alias pa
    WHERE pa.parent_entity_name="DEFAULT"
     AND (pa.code_value=request->reason_codes[current_reason_code_index].code_value)
    DETAIL
     alias = pa.alias, cnt = (cnt+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck(concat("Error 007: Error selecting pft_alias row for ",cnvtstring(request->
      reason_codes[current_reason_code_index].code_value)))
   IF (cnt=0)
    INSERT  FROM pft_alias pa
     SET pa.seq = 1, pa.parent_entity_name = "DEFAULT", pa.parent_entity_id = request->reason_codes[
      current_reason_code_index].code_value,
      pa.alias = request->reason_codes[current_reason_code_index].alias, pa.code_value = request->
      reason_codes[current_reason_code_index].code_value, pa.updt_id = reqinfo->updt_id,
      pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_task = reqinfo->updt_task, pa
      .updt_applctx = reqinfo->updt_applctx,
      pa.updt_cnt = 0, pa.active_ind = 1, pa.active_status_cd = cs48_active,
      pa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pa.active_status_prsnl_id = reqinfo->
      updt_id, pa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     WITH nocounter
    ;end insert
    CALL bederrorcheck(concat("Error008: Error creating new pft_alias row, during update, for: ",
      request->reason_codes[current_reason_code_index].display))
   ELSEIF (cnt=1)
    IF (trim(alias) != trim(request->reason_codes[current_reason_code_index].alias))
     UPDATE  FROM pft_alias pa
      SET pa.seq = 1, pa.parent_entity_name = "DEFAULT", pa.alias = request->reason_codes[
       current_reason_code_index].alias,
       pa.updt_id = reqinfo->updt_id, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_task =
       reqinfo->updt_task,
       pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = (pa.updt_cnt+ 1), pa.active_ind = 1
      WHERE (pa.code_value=request->reason_codes[current_reason_code_index].code_value)
       AND pa.parent_entity_name="DEFAULT"
      WITH nocounter
     ;end update
     CALL bederrorcheck(concat("Error009: Error updating pft_alias row for ",cnvtstring(request->
        reason_codes[current_reason_code_index].code_value)))
    ENDIF
   ENDIF
   IF (code_set=26398)
    SET ppi = trim(cnvtstring(request->reason_codes[current_reason_code_index].post_primary_ind),7)
    SET psi = trim(cnvtstring(request->reason_codes[current_reason_code_index].post_secondary_ind),7)
    SET pti = trim(cnvtstring(request->reason_codes[current_reason_code_index].post_tertiary_ind),7)
    SET reqval = concat(ppi,psi,pti)
    CASE (trim(trim(reqval,9),7))
     OF "111":
      SET postval = 0
     OF "000":
      SET postval = 1
     OF "101":
      SET postval = 2
     OF "100":
      SET postval = 3
     OF "110":
      SET postval = 4
     OF "001":
      SET postval = 5
     OF "010":
      SET postval = 6
     OF "011":
      SET postval = 7
     ELSE
      SET postval = 1
    ENDCASE
   ELSEIF (((code_set=26399) OR (code_set=24730)) )
    SET postval = 0
   ENDIF
   IF ((request->reason_codes[current_reason_code_index].reason_type_code_value=cs29904_technical))
    SET prio = 1
   ELSE
    SET prio = 0
   ENDIF
   SELECT INTO "NL:"
    FROM pft_denial_code_ref pdcr
    WHERE (pdcr.denial_cd=request->reason_codes[current_reason_code_index].code_value)
     AND pdcr.logical_domain_id=logical_domain_id
    DETAIL
     original_postval = pdcr.post_no_post_method_flag
    WITH nocounter
   ;end select
   IF (curqual=1)
    UPDATE  FROM pft_denial_code_ref pdcr
     SET pdcr.denial_type_cd = request->reason_codes[current_reason_code_index].
      reason_type_code_value, pdcr.denial_group_cd = request->reason_codes[current_reason_code_index]
      .reason_group_code_value, pdcr.x12_code = request->reason_codes[current_reason_code_index].x12b,
      pdcr.post_no_post_method_flag = postval, pdcr.priority_level = prio, pdcr.autowriteoff_ind = 0,
      pdcr.trans_alias_cd = 0.0, pdcr.process_ind = 0, pdcr.direct_to_non_ar_ind = request->
      reason_codes[current_reason_code_index].direct_to_non_ar,
      pdcr.reverse_expected_ind = request->reason_codes[current_reason_code_index].reverse_expected,
      pdcr.updt_id = reqinfo->updt_id, pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pdcr.updt_task = reqinfo->updt_task, pdcr.updt_applctx = reqinfo->updt_applctx, pdcr.updt_cnt
       = (pdcr.updt_cnt+ 1)
     WHERE (pdcr.denial_cd=request->reason_codes[current_reason_code_index].code_value)
      AND pdcr.logical_domain_id=logical_domain_id
     WITH nocounter
    ;end update
    CALL bederrorcheck(concat("Error 010: Error updating pft row for ",cnvtstring(request->
       reason_codes[current_reason_code_index].display)))
   ELSE
    SET newid = 0.0
    SELECT INTO "nl:"
     nid = seq(pft_ref_seq,nextval)
     FROM dual
     DETAIL
      newid = cnvtreal(nid)
     WITH format, counter
    ;end select
    CALL bederrorcheck(concat("Error011: Error creating new pft id for ",request->reason_codes[
      current_reason_code_index].display))
    INSERT  FROM pft_denial_code_ref pdcr
     SET pdcr.pft_denial_code_ref_id = newid, pdcr.denial_cd = request->reason_codes[
      current_reason_code_index].code_value, pdcr.denial_type_cd = request->reason_codes[
      current_reason_code_index].reason_type_code_value,
      pdcr.denial_group_cd = request->reason_codes[current_reason_code_index].reason_group_code_value,
      pdcr.logical_domain_id = logical_domain_id, pdcr.post_no_post_method_flag = postval,
      pdcr.priority_level = prio, pdcr.autowriteoff_ind = 0, pdcr.trans_alias_cd = 0.0,
      pdcr.process_ind = 0, pdcr.updt_id = reqinfo->updt_id, pdcr.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      pdcr.updt_task = reqinfo->updt_task, pdcr.updt_applctx = reqinfo->updt_applctx, pdcr.updt_cnt
       = 0
     WITH nocounter
    ;end insert
    CALL bederrorcheck(concat("Error 012: Error creating new pft row for ",request->reason_codes[
      current_reason_code_index].display))
   ENDIF
 END ;Subroutine
 SUBROUTINE deletereasoncode(current_reason_code_index)
   SET stm = 123
   SET currentreasoncodecodeset = 0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->reason_codes[current_reason_code_index].code_value)
    DETAIL
     currentreasoncodecodeset = cv.code_set
    WITH nocounter
   ;end select
   CALL bederrorcheck(concat("Error 013: Could not find code set for code value: ",request->
     reason_codes[current_reason_code_index].display))
   IF (currentreasoncodecodeset=client_defined_code_set)
    DELETE  FROM pft_denial_code_ref pdcr
     WHERE (pdcr.denial_cd=request->reason_codes[current_reason_code_index].code_value)
      AND pdcr.logical_domain_id=logical_domain_id
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error 014: Failed to delete pft_denial_code_ref row")
   ENDIF
 END ;Subroutine
END GO
