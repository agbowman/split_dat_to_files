CREATE PROGRAM bed_ens_cond_expression:dba
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
 FREE RECORD contentexpressionreply
 RECORD contentexpressionreply(
   1 cnt_cond_expression_key_uid = vc
   1 cnt_cond_expression_id = f8
   1 cnt_cond_expression_name = vc
   1 cnt_cond_expression_txt = vc
   1 cnt_cond_postfix_txt = vc
   1 cnt_multiple_ind = i2
   1 dcp_cond_expression_ref_id = f8
   1 cnt_exp_comp[*]
     2 cnt_cond_exprsn_comp_key_uid = vc
     2 cnt_cond_comp_name = vc
     2 cond_exprsn_comp_id = f8
     2 operator_cd_uid = vc
     2 cnt_operator_cd_display = vc
     2 cnt_operator_cd_meaning = vc
     2 operator_cd = f8
     2 ar_uid = vc
     2 nomenclature_name = vc
     2 cnt_required_ind = i2
     2 trigger_assay_cd_uid = vc
     2 cnt_trigger_assay_cd_description = vc
     2 cnt_trigger_assay_cd_mnemonic = vc
     2 trigger_assay_cd = f8
     2 cnt_result_value = f8
   1 cnt_cond_dtas[*]
     2 cnt_age_from_nbr = i4
     2 age_from_nbr = i4
     2 age_from_unit_cd_uid = vc
     2 cnt_age_from_unit_cd_display = vc
     2 cnt_age_from_unit_cd_meaning = vc
     2 age_from_unit_cd = f8
     2 cnt_age_to_nbr = i4
     2 age_to_unit_cd_uid = vc
     2 cnt_age_to_unit_cd_display = vc
     2 cnt_age_to_unit_cd_meaning = vc
     2 age_to_unit_cd = f8
     2 conditional_assay_cd_uid = vc
     2 cnt_conditional_assay_cd_description = vc
     2 cnt_conditional_assay_cd_mnemonic = vc
     2 conditional_assay_cd = f8
     2 gender_cd_uid = vc
     2 cnt_gender_cd_display = vc
     2 cnt_gender_cd_meaning = vc
     2 gender_cd = f8
     2 position_cd_uid = vc
     2 cnt_position_cd_display = vc
     2 cnt_position_cd_meaning = vc
     2 position_cd = f8
     2 location_cd_uid = vc
     2 cnt_location_cd_display = vc
     2 cnt_location_cd_meaning = vc
     2 location_cd = f8
     2 cnt_required_ind = i2
     2 cnt_unknown_age_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD exp_version(
   1 cond_expression_id = f8
   1 cond_expression_name = c100
   1 cond_expression_txt = c512
   1 cond_postfix_txt = c512
   1 multiple_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_cond_expression_id = f8
 )
 RECORD comp_version(
   1 cond_comp_name = c30
   1 cond_expression_comp_id = f8
   1 operator_cd = f8
   1 parent_entity_id = f8
   1 parent_entity_name = c60
   1 required_ind = i2
   1 trigger_assay_cd = f8
   1 result_value = f8
   1 cond_expression_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_cond_expression_comp_id = f8
 )
 RECORD dta_version(
   1 age_from_nbr = i4
   1 age_from_unit_cd = f8
   1 age_to_nbr = i4
   1 age_to_unit_cd = f8
   1 conditional_assay_cd = f8
   1 conditional_dta_id = f8
   1 cond_expression_id = f8
   1 gender_cd = f8
   1 location_cd = f8
   1 position_cd = f8
   1 required_ind = i2
   1 unknown_age_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prev_conditional_dta_id = f8
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
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 DECLARE modified_section = vc WITH protect, constant("S")
 DECLARE modified_input = vc WITH protect, constant("I")
 DECLARE modified_assay = vc WITH protect, constant("A")
 DECLARE logfileind = i2 WITH protect, noconstant(0)
 DECLARE logfilename = vc WITH protect, noconstant("")
 DECLARE getsectionidbysectionuid(sectionuid=vc) = f8
 DECLARE gettaskassaycdforuid(taskassayuid=vc) = f8
 DECLARE logdebuginfo(desc=vc) = i2
 DECLARE isinputmodified(getimportedinputsreply=vc(ref),getexistinginputsreply=vc(ref),returnind=i2)
  = i2
 DECLARE geteventcdforuid(eventuid=vc) = f8
 DECLARE isassaymodified(taskassayuid=vc,formuid=vc) = i2
 DECLARE compareintersectingeventcodes(idx=i4,getimportedinputsreply=vc(ref)) = i2
 DECLARE openlogfile(outputfilename=vc) = i2
 DECLARE writelogstothefile(outputfilename=vc,ccllogind=i2) = i2
 DECLARE writeiviewlogstothefile(outputfilename=vc,ccllogind=i2) = i2
 DECLARE closelogfile(dummyvar=i2) = i2
 DECLARE bedaddlogstologgerfile(logmessage=vc) = null
 DECLARE findpowerformorsectionnameofassay(assayuid=vc) = vc
 FREE RECORD assaysinform
 RECORD assaysinform(
   1 assays[*]
     2 task_assay_uid = vc
 )
 IF ( NOT (validate(logger,0)))
  RECORD logger(
    1 logs[*]
      2 texttobewritten = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec,0)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 SUBROUTINE getsectionidbysectionuid(sectionuid)
   CALL bedlogmessage("getSectionIdBySectionUID","Entering ...")
   DECLARE sectionid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnt_section_key2 sk
    WHERE sk.section_uid=sectionuid
    DETAIL
     sectionid = sk.dcp_section_ref_id
    WITH nocounter
   ;end select
   IF (sectionid=0)
    SELECT INTO "nl:"
     FROM cnt_section_key2 sk,
      dcp_section_ref r
     PLAN (sk
      WHERE sk.section_uid=sectionuid)
      JOIN (r
      WHERE r.definition=sk.section_definition
       AND r.active_ind=true)
     DETAIL
      sectionid = r.dcp_section_ref_id
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("sectionId:",sectionid))
   CALL bedlogmessage("getSectionIdBySectionUID","Exiting ...")
   RETURN(sectionid)
 END ;Subroutine
 SUBROUTINE gettaskassaycdforuid(taskassayuid)
   CALL bedlogmessage("getTaskAssayCdForUID","Entering ...")
   DECLARE taskassaycd = f8 WITH protect, noconstant(0)
   DECLARE mnemonic = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM cnt_dta_key2 dk,
     cnt_dta d
    PLAN (dk
     WHERE dk.task_assay_uid=taskassayuid)
     JOIN (d
     WHERE d.task_assay_uid=dk.task_assay_uid)
    DETAIL
     taskassaycd = dk.task_assay_cd, mnemonic = d.mnemonic
    WITH nocounter
   ;end select
   IF (taskassaycd=0)
    SELECT INTO "nl:"
     FROM discrete_task_assay dta
     WHERE dta.mnemonic=mnemonic
     DETAIL
      taskassaycd = dta.task_assay_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("taskAssayCd:",taskassaycd))
   CALL bedlogmessage("getTaskAssayCdForUID","Exiting ...")
   RETURN(taskassaycd)
 END ;Subroutine
 SUBROUTINE logdebuginfo(desc)
   IF (validate(debug,0)=1)
    CALL echo("===============================================")
    CALL echo(desc)
    CALL echo("===============================================")
   ENDIF
 END ;Subroutine
 SUBROUTINE compareintersectingeventcodes(idx,getimportedinputsreply)
   CALL bedlogmessage("compareIntersectingEventCodes","Entering ...")
   DECLARE diffind = i2 WITH protect, noconstant(0)
   DECLARE evcd = i2 WITH protect, noconstant(0)
   IF ((getimportedinputsreply->inputs[idx].cnt_modified_status=modified))
    RETURN(true)
   ENDIF
   IF (size(getimportedinputsreply->inputs[idx].grideventcodes,5) > 0)
    FOR (evcd = 1 TO size(getimportedinputsreply->inputs[idx].grideventcodes,5))
      IF ((getimportedinputsreply->inputs[idx].grideventcodes[evcd].col_task_assay_cd > 0)
       AND (getimportedinputsreply->inputs[idx].grideventcodes[evcd].row_task_assay_cd > 0))
       SELECT INTO "nl:"
        FROM code_value_event_r r
        PLAN (r
         WHERE r.parent_cd=outerjoin(getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          col_task_assay_cd)
          AND r.flex1_cd=outerjoin(getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          row_task_assay_cd)
          AND r.flex2_cd=outerjoin(0)
          AND r.flex3_cd=outerjoin(0)
          AND r.flex4_cd=outerjoin(0)
          AND r.flex5_cd=outerjoin(0))
        DETAIL
         IF ((r.event_cd != getimportedinputsreply->inputs[idx].grideventcodes[evcd].int_event_cd))
          getimportedinputsreply->inputs[idx].grideventcodes[evcd].old_event_cd = r.event_cd,
          getimportedinputsreply->inputs[idx].grideventcodes[evcd].old_event_display =
          uar_get_code_display(r.event_cd), getimportedinputsreply->inputs[idx].grideventcodes[evcd].
          event_modified_status = modified,
          diffind = true
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET getimportedinputsreply->inputs[idx].grideventcodes[evcd].event_modified_status = modified
        SET diffind = true
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(diffind)
   CALL bedlogmessage("compareIntersectingEventCodes","Exiting ...")
 END ;Subroutine
 SUBROUTINE isinputmodified(getimportedinputsreply,getexistinginputsreply,returnind)
   CALL bedlogmessage("isInputModified","Entering ...")
   DECLARE importedinputsize = i4 WITH protect, constant(size(getimportedinputsreply->inputs,5))
   DECLARE existinginputsize = i4 WITH protect, constant(size(getexistinginputsreply->inputs,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE preffoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   DECLARE existprefcnt = i4 WITH protect, noconstant(0)
   DECLARE epcnt = i4 WITH protect, noconstant(0)
   FOR (eidx = 1 TO existinginputsize)
     SET num = 1
     SET foundidx = locateval(num,1,importedinputsize,getexistinginputsreply->inputs[eidx].
      input_ref_id,getimportedinputsreply->inputs[num].dcp_input_ref_id)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,importedinputsize,getexistinginputsreply->inputs[eidx].
       input_ref_seq,getimportedinputsreply->inputs[num].input_ref_seq,
       getexistinginputsreply->inputs[eidx].input_type,getimportedinputsreply->inputs[num].input_type,
       getexistinginputsreply->inputs[eidx].module,getimportedinputsreply->inputs[num].module)
     ENDIF
     CALL logdebuginfo(build2("Evaluating at position(existing): ",getexistinginputsreply->inputs[
       eidx].input_ref_seq," --Input type(existing):",getexistinginputsreply->inputs[eidx].input_type
       ))
     CALL logdebuginfo(build2("Found match:",foundidx))
     IF (foundidx > 0)
      IF ((getimportedinputsreply->inputs[foundidx].dcp_input_ref_id=0))
       SET getimportedinputsreply->inputs[foundidx].dcp_input_ref_id = getexistinginputsreply->
       inputs[foundidx].input_ref_id
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].input_type=19)
       AND (getexistinginputsreply->inputs[eidx].input_type=19))
       IF (compareintersectingeventcodes(foundidx,getimportedinputsreply))
        SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
        IF (returnind)
         RETURN(true)
        ENDIF
       ENDIF
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].input_ref_seq != getexistinginputsreply->inputs[
      eidx].input_ref_seq))
       CALL logdebuginfo(build2("input_ref_seq: ",getimportedinputsreply->inputs[foundidx].
         input_ref_seq,"::",getexistinginputsreply->inputs[eidx].input_ref_seq))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].description != getexistinginputsreply->
      inputs[eidx].description))
       CALL logdebuginfo(build2("description: ",getimportedinputsreply->inputs[foundidx].description,
         "::",getexistinginputsreply->inputs[eidx].description))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].input_type != getexistinginputsreply->inputs[
      eidx].input_type))
       CALL logdebuginfo(build2("input_type: ",getimportedinputsreply->inputs[foundidx].input_type,
         "::",getexistinginputsreply->inputs[eidx].input_type))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF ((getimportedinputsreply->inputs[foundidx].module != getexistinginputsreply->inputs[eidx
      ].module))
       CALL logdebuginfo(build2("module: ",getimportedinputsreply->inputs[foundidx].module,"::",
         getexistinginputsreply->inputs[eidx].module))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ELSEIF (size(getimportedinputsreply->inputs[foundidx].preferences,5) != size(
       getexistinginputsreply->inputs[eidx].preferences,5))
       CALL logdebuginfo(build2("preference:size: ",size(getimportedinputsreply->inputs[foundidx].
          preferences,5),"::",size(getexistinginputsreply->inputs[eidx].preferences,5)))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
       IF (returnind)
        RETURN(true)
       ENDIF
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].cnt_modified_status != modified))
       FOR (prefidx = 1 TO size(getimportedinputsreply->inputs[foundidx].preferences,5))
         CALL logdebuginfo(build2("Evaluating preference at index: ",prefidx))
         SET num1 = 1
         SET preffoundidx = locateval(num1,1,size(getexistinginputsreply->inputs[eidx].preferences,5),
          getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id,
          getexistinginputsreply->inputs[eidx].preferences[num1].id)
         IF (preffoundidx=0)
          SET num1 = 1
          SET preffoundidx = locateval(num1,1,size(getexistinginputsreply->inputs[eidx].preferences,5
            ),getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_name,
           getexistinginputsreply->inputs[eidx].preferences[num1].pvc_name,
           getimportedinputsreply->inputs[foundidx].preferences[prefidx].sequence,
           getexistinginputsreply->inputs[eidx].preferences[num1].sequence)
         ENDIF
         IF (preffoundidx=0)
          CALL logdebuginfo(build2("Preference did not find a match in millennium for ",
            getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_name))
          SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
          IF (returnind)
           RETURN(true)
          ENDIF
         ELSE
          IF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id=0))
           SET getimportedinputsreply->inputs[foundidx].preferences[prefidx].name_value_prefs_id =
           getexistinginputsreply->inputs[eidx].preferences[preffoundidx].id
          ENDIF
          IF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].pvc_value !=
          getexistinginputsreply->inputs[eidx].preferences[preffoundidx].pvc_value))
           CALL logdebuginfo(build2("preference:pvc_value: ",getimportedinputsreply->inputs[foundidx]
             .preferences[prefidx].pvc_value,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].pvc_value))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ELSEIF (trim(getimportedinputsreply->inputs[foundidx].preferences[prefidx].merge_name,7)
           != trim(getexistinginputsreply->inputs[eidx].preferences[preffoundidx].merge_name,7))
           CALL logdebuginfo(build2("preference:merge_name: ",getimportedinputsreply->inputs[foundidx
             ].preferences[prefidx].merge_name,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].merge_name))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ELSEIF ((getimportedinputsreply->inputs[foundidx].preferences[prefidx].merge_id !=
          getexistinginputsreply->inputs[eidx].preferences[preffoundidx].merge_id))
           CALL logdebuginfo(build2("preference:merge_id: ",getimportedinputsreply->inputs[foundidx].
             preferences[prefidx].merge_id,"::",getexistinginputsreply->inputs[eidx].preferences[
             preffoundidx].merge_id))
           SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = modified
           IF (returnind)
            RETURN(true)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF ((getimportedinputsreply->inputs[foundidx].cnt_modified_status=""))
       SET getimportedinputsreply->inputs[foundidx].cnt_modified_status = none
      ENDIF
     ELSE
      SET icnt = (size(getimportedinputsreply->inputs,5)+ 1)
      SET stat = alterlist(getimportedinputsreply->inputs,icnt)
      SET getimportedinputsreply->inputs[icnt].description = getexistinginputsreply->inputs[eidx].
      description
      SET getimportedinputsreply->inputs[icnt].input_ref_seq = getexistinginputsreply->inputs[eidx].
      input_ref_seq
      SET getimportedinputsreply->inputs[icnt].input_type = getexistinginputsreply->inputs[eidx].
      input_type
      SET getimportedinputsreply->inputs[icnt].module = getexistinginputsreply->inputs[eidx].module
      SET getimportedinputsreply->inputs[icnt].cnt_modified_status = removed
      SET getimportedinputsreply->inputs[icnt].dcp_input_ref_id = getexistinginputsreply->inputs[eidx
      ].input_ref_id
      SET getimportedinputsreply->inputs[icnt].cnt_input_key_id = getexistinginputsreply->inputs[eidx
      ].input_ref_id
      SET existprefcnt = size(getexistinginputsreply->inputs[eidx].preferences,5)
      SET stat = alterlist(getimportedinputsreply->inputs[icnt].preferences,existprefcnt)
      FOR (epcnt = 1 TO existprefcnt)
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].name_value_prefs_id =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].id
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].pvc_name = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].pvc_name
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].pvc_value =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].pvc_value
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_name =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].merge_name
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_id = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].merge_id
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].sequence = getexistinginputsreply
        ->inputs[eidx].preferences[epcnt].sequence
        SET getimportedinputsreply->inputs[icnt].preferences[epcnt].merge_display =
        getexistinginputsreply->inputs[eidx].preferences[epcnt].merge_display
      ENDFOR
      IF (returnind)
       RETURN(true)
      ENDIF
     ENDIF
   ENDFOR
   FOR (iidx = 1 TO size(getimportedinputsreply->inputs,5))
     IF ((getimportedinputsreply->inputs[iidx].cnt_modified_status=""))
      SET getimportedinputsreply->inputs[iidx].cnt_modified_status = added
     ENDIF
   ENDFOR
   CALL bedlogmessage("isInputModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE geteventcdforuid(eventuid)
   CALL bedlogmessage("getEventCdForUID","Entering ...")
   DECLARE eventcd = f8 WITH protect, noconstant(0)
   DECLARE eventdesc = vc WITH protect, noconstant("")
   DECLARE eventdisp = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM cnt_code_value_key k
    WHERE k.code_value_uid=eventuid
    DETAIL
     eventcd = k.code_value, eventdesc = k.description, eventdisp = k.display
    WITH nocounter
   ;end select
   IF (eventcd=0)
    SELECT INTO "nl:"
     FROM v500_event_code ec
     WHERE ec.event_cd_disp=eventdisp
     DETAIL
      eventcd = ec.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL logdebuginfo(build2("eventCd:",eventcd))
   CALL bedlogmessage("getEventCdForUID","Exiting ...")
   RETURN(eventcd)
 END ;Subroutine
 SUBROUTINE isassaymodified(taskassayuid,formuid)
   CALL bedlogmessage("isAssayModified","Entering ...")
   FREE RECORD assayrequest
   RECORD assayrequest(
     1 assays[*]
       2 task_assay_uid = vc
       2 bailoutind = i2
     1 get_interps_ind = i2
     1 form_uid = vc
   )
   IF ( NOT (validate(assayreply,0)))
    RECORD assayreply(
      1 assays[*]
        2 task_assay_uid = vc
        2 task_assay_code_value = f8
        2 description = vc
        2 mnemonic = vc
        2 witness_required_ind = i2
        2 lookback_minutes[*]
          3 type_code_value = f8
          3 type_display = vc
          3 type_mean = vc
          3 minutes_nbr = i4
        2 equations[*]
          3 equation_uid = vc
          3 equation_id = f8
          3 description = vc
          3 age_from = f8
          3 age_from_units
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 age_to = f8
          3 age_to_units
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 sex
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 unknown_age_ind = i2
          3 default_ind = i2
          3 components[*]
            4 component_name = vc
            4 included_assay_uid = vc
            4 included_assay
              5 code_value = f8
              5 display = vc
              5 mean = vc
            4 constant_value = f8
            4 required_flag = i2
            4 look_time_direction_flag = i2
            4 time_window_back_minutes = i4
            4 time_window_minutes = i4
            4 value_unit
              5 code_value = f8
              5 display = vc
              5 mean = vc
            4 optional_value = f8
        2 max_digits = i4
        2 min_digits = i4
        2 min_decimal_places = i4
        2 default_type_flag = i2
        2 concept_cki = vc
        2 activity_type
          3 code_value = f8
          3 display = vc
          3 mean = vc
        2 result_type
          3 code_value = f8
          3 display = vc
          3 mean = vc
        2 event
          3 uid = vc
          3 display = vc
          3 event_cd_cki = vc
        2 single_select_ind = i2
        2 io_flag = i2
        2 ref_ranges[*]
          3 rrf_uid = vc
          3 age_to = f8
          3 age_to_units
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 age_from = f8
          3 age_from_units
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 normal_low = f8
          3 normal_high = f8
          3 critical_low = f8
          3 critical_high = f8
          3 review_low = f8
          3 review_high = f8
          3 linear_low = f8
          3 linear_high = f8
          3 feasible_low = f8
          3 feasible_high = f8
          3 default_result = f8
          3 alpha_responses[*]
            4 ar_uid = vc
            4 source_string = vc
            4 short_string = vc
            4 mnemonic = vc
            4 nomenclature_id = f8
            4 sequence = i4
            4 result_value = f8
            4 multi_alpha_sort_order = i4
            4 reference_ind = i2
            4 default_ind = i2
            4 use_units_ind = i2
            4 result_process_code_value = f8
            4 principle_type_code_value = f8
            4 contributor_system_code_value = f8
            4 language_code_value = f8
            4 source_vocabulary_code_value = f8
            4 source_identifier = vc
            4 concept_cki = vc
            4 vocab_axis_code_value = f8
            4 truth_state_cd = f8
            4 truth_state_display = vc
            4 truth_state_mean = vc
            4 modified_status = vc
          3 units
            4 code_value = f8
            4 display = vc
            4 mean = vc
          3 sex
            4 code_value = f8
            4 display = vc
            4 mean = vc
        2 notes[*]
          3 text_id = f8
          3 text = vc
          3 user_id = f8
          3 user = vc
          3 updt_dt_tm = dq8
        2 interps[*]
          3 sex_cd = f8
          3 age_from_minutes = i4
          3 age_to_minutes = i4
          3 uid = vc
          3 comps[*]
            4 component_assay_cd = f8
            4 sequence = i4
            4 description = vc
            4 flags = i4
            4 mnemonic = vc
          3 states[*]
            4 input_assay_cd = f8
            4 state = i4
            4 flags = i4
            4 numeric_low = f8
            4 numeric_high = f8
            4 nomenclature_id = f8
            4 resulting_state = i4
            4 result_nomenclature_id = f8
            4 result_value = f8
          3 sex_mean = vc
          3 sex_display = vc
        2 ref_text_modified_ind = i2
        2 modified_status = vc
        2 has_all_interp_comp_assays = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
   ENDIF
   SET stat = alterlist(assayrequest->assays,1)
   SET assayrequest->assays[1].task_assay_uid = taskassayuid
   SET assayrequest->assays[1].bailoutind = 1
   SET assayrequest->get_interps_ind = 1
   SET assayrequest->form_uid = formuid
   EXECUTE bed_get_pwrform_cern_assays  WITH replace("REQUEST",assayrequest), replace("REPLY",
    assayreply)
   IF ((assayreply->status_data.status != "S"))
    CALL bederror(build("bed_get_pwrform_cern_assays did not return success for assay: ",taskassayuid
      ))
   ENDIF
   IF (size(assayreply->assays,5)=1)
    IF ((assayreply->assays[1].modified_status != none))
     CALL logdebuginfo(build2("The assay is modified: ",taskassayuid))
     RETURN(true)
    ENDIF
   ELSE
    CALL logdebuginfo(build2("Invalid reply returned for the assay: ",taskassayuid))
   ENDIF
   FREE RECORD assayreply
   CALL bedlogmessage("isAssayModified","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE bedaddlogstologgerfile(logmessage)
   DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
   SET stat = alterlist(logger->logs,(logcnt+ 1))
   SET logger->logs[(logcnt+ 1)].texttobewritten = logmessage
 END ;Subroutine
 SUBROUTINE openlogfile(outputfilename,ispowerform)
   CALL bedlogmessage("openLogFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering openLogFile ...")
   CALL bedaddlogstologgerfile(build2("### outputFileName:",outputfilename))
   CALL bedaddlogstologgerfile(build2("### isPowerForm:",ispowerform))
   DECLARE filenameprefix = vc WITH protect, noconstant("")
   IF (logfileind)
    IF (ispowerform)
     SET filenameprefix = "bed_pf_"
    ELSE
     SET filenameprefix = "bed_iview_"
    ENDIF
    CALL bedaddlogstologgerfile(build2("### fileNamePrefix:",filenameprefix))
    DECLARE curdatetime = vc WITH protect, noconstant(format(cnvtdatetime(curdate,curtime3),
      "YYYYMMDDHH;;Q"))
    SET frec->file_name = build(filenameprefix,outputfilename,build("_",curdatetime),".log")
    SET frec->file_buf = "a"
    CALL bedaddlogstologgerfile(build2(curprog," : ","frec->file_name:",frec->file_name))
    SET stat = cclio("OPEN",frec)
   ENDIF
   CALL bedlogmessage("openLogFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting openLogFile ...")
 END ;Subroutine
 SUBROUTINE writelogstothefile(outputfilename,ccllogind)
   CALL bedlogmessage("writeLogsToTheFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering writeLogsToTheFile ...")
   SET logfileind = ccllogind
   CALL openlogfile(trim(outputfilename,4),true)
   IF (logfileind)
    DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
    CALL bedaddlogstologgerfile(build2(curprog," : ","Number of Logs:",logcnt))
    FOR (x = 1 TO logcnt)
      SET frec->file_buf = build(frec->file_buf,char(10),logger->logs[x].texttobewritten)
    ENDFOR
    SET stat = cclio("WRITE",frec)
    SET stat = initrec(logger)
   ENDIF
   CALL closelogfile(logfileind)
   CALL bedlogmessage("writeLogsToTheFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting writeLogsToTheFile ...")
 END ;Subroutine
 SUBROUTINE writeiviewlogstothefile(outputfilename,ccllogind)
   CALL bedlogmessage("writeIViewLogsToTheFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering writeIViewLogsToTheFile ...")
   SET logfileind = ccllogind
   CALL openlogfile(trim(outputfilename,4),false)
   IF (logfileind)
    DECLARE logcnt = i4 WITH protect, noconstant(size(logger->logs,5))
    CALL bedaddlogstologgerfile(build2(curprog," : ","Number of Logs:",logcnt))
    FOR (x = 1 TO logcnt)
      SET frec->file_buf = build(frec->file_buf,char(10),logger->logs[x].texttobewritten)
    ENDFOR
    SET stat = cclio("WRITE",frec)
    SET stat = initrec(logger)
   ENDIF
   CALL closelogfile(logfileind)
   CALL bedlogmessage("writeIViewLogsToTheFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting writeIViewLogsToTheFile ...")
 END ;Subroutine
 SUBROUTINE closelogfile(dummyvar)
   CALL bedlogmessage("closeLogFile","Entering ...")
   CALL bedaddlogstologgerfile("### Entering closeLogFile ...")
   IF (logfileind)
    SET stat = cclio("CLOSE",frec)
   ENDIF
   CALL bedlogmessage("closeLogFile","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting closeLogFile ...")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE getcontentexpression(expressionuid=vc) = i2
 DECLARE insertnewconditionalexpression(dummyvar=i2) = i2
 DECLARE updateconditionalexpression(expressionid=f8) = null
 DECLARE insertnewconditionalcomponents(expressionid=f8) = null
 DECLARE insertnewconditionaldtas(expressionid=f8) = null
 DECLARE updateconditionalcomponents(expressionid=f8) = null
 DECLARE updateconditionalcomponentbyindex(index=i4) = null
 DECLARE updateconditionaldtas(expressionid=f8) = null
 DECLARE updateconditionaldtabyindex(index=i4,expressionid=f8) = null
 DECLARE insertnewcomponentbyindex(index=i4,expressionid=f8) = null
 DECLARE insertnewconditionaldtabyindex(index=i4,expressionid=f8) = null
 CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_COND_EXPRESSION.PRG ####")
 CALL bedaddlogstologgerfile(cnvtrectoxml(request))
 IF ((request->cond_expression_id=0))
  SELECT INTO "nl:"
   FROM cnt_cond_expression_key k,
    cond_expression ce
   PLAN (k
    WHERE (k.cnt_cond_expression_key_uid=request->cnt_cond_expression_key_uid))
    JOIN (ce
    WHERE ce.cond_expression_name=k.cond_expression_name
     AND ce.active_ind=1)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL bedaddlogstologgerfile(build2("### curqual value is >0",curqual))
   CALL bederror("Duplicate expression name")
  ENDIF
  CALL getcontentexpression(request->cnt_cond_expression_key_uid)
  CALL insertnewconditionalexpression(0)
 ELSE
  CALL getcontentexpression(request->cnt_cond_expression_key_uid)
  CALL updateconditionalexpression(request->cond_expression_id)
 ENDIF
 IF (validate(request->ccl_logging_ind))
  CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
  SET logfilename = request->iview_name
  CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_COND_EXPRESSION.PRG ####")
  CALL writeiviewlogstothefile(logfilename,request->ccl_logging_ind)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getcontentexpression(expressionuid)
   CALL bedlogmessage("getContentExpression","Entering ...")
   CALL bedaddlogstologgerfile("### Entering getContentExpression ...")
   CALL bedaddlogstologgerfile(build2("### Inside getContentExpression - expressionUID:",
     expressionuid))
   FREE RECORD contentexpressionrequest
   RECORD contentexpressionrequest(
     1 cnt_cond_expression_key_uid = vc
   )
   SET contentexpressionrequest->cnt_cond_expression_key_uid = expressionuid
   CALL bedaddlogstologgerfile(cnvtrectoxml(contentexpressionrequest))
   EXECUTE bed_get_cnt_cond_expn_detail  WITH replace("REQUEST",contentexpressionrequest), replace(
    "REPLY",contentexpressionreply)
   CALL bedaddlogstologgerfile(
    "### Inside getContentExpression - Executed bed_get_cnt_cond_expn_detail script ...")
   IF ((contentexpressionreply->status_data.status != "S"))
    CALL bederror("bed_get_cnt_cond_expn_detail did not return success")
    CALL bedaddlogstologgerfile(
     "###Inside getContentExpression - bed_get_cnt_cond_expn_detail script did not return success..."
     )
   ENDIF
   CALL bedaddlogstologgerfile("### Exiting getContentExpression ...")
   CALL bedlogmessage("getContentExpression","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewconditionalexpression(dummyvar)
   CALL bedlogmessage("InsertNewConditionalExpression","Entering ...")
   CALL bedaddlogstologgerfile("### Entering InsertNewConditionalExpression ...")
   DECLARE newseq = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newseq = cnvtreal(j)
    WITH format, nocounter
   ;end select
   INSERT  FROM cond_expression ce
    SET ce.cond_expression_id = newseq, ce.prev_cond_expression_id = newseq, ce.active_ind = 1,
     ce.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ce.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), ce.cond_expression_name = contentexpressionreply->cnt_cond_expression_name,
     ce.cond_expression_txt = contentexpressionreply->cnt_cond_expression_txt, ce.cond_postfix_txt =
     contentexpressionreply->cnt_cond_postfix_txt, ce.multiple_ind = contentexpressionreply->
     cnt_multiple_ind,
     ce.updt_id = reqinfo->updt_id, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_applctx
      = reqinfo->updt_applctx,
     ce.updt_cnt = 0, ce.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bedaddlogstologgerfile(
    "### Inside InsertNewConditionalExpression - values inserted into cond_expression Table...")
   CALL insertnewconditionalcomponents(newseq)
   CALL insertnewconditionaldtas(newseq)
   CALL bedaddlogstologgerfile("### Exiting InsertNewConditionalExpression ...")
   CALL bedlogmessage("InsertNewConditionalExpression","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewconditionalcomponents(expressionid)
   CALL bedlogmessage("InsertNewConditionalComponents","Entering ...")
   CALL bedaddlogstologgerfile("### Entering InsertNewConditionalComponents ...")
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewConditionalComponents - expressionId:",
     expressionid))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE comp_cnt = i4 WITH protect, noconstant(size(contentexpressionreply->cnt_exp_comp,5))
   DECLARE newcompid = f8 WITH protect, noconstant(0)
   DECLARE nomenid = f8 WITH protect, noconstant(0)
   FOR (x = 1 TO comp_cnt)
     CALL insertnewcomponentbyindex(x,expressionid)
   ENDFOR
   CALL bedaddlogstologgerfile("### Exiting InsertNewConditionalComponents ...")
   CALL bedlogmessage("InsertNewConditionalComponents","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewconditionaldtas(expressionid)
   CALL bedlogmessage("InsertNewConditionalDTAs","Entering ...")
   CALL bedaddlogstologgerfile("### Entering InsertNewConditionalDTAs ...")
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewConditionalDTAs - expressionId:",
     expressionid))
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE cond_cnt = i4 WITH protect, noconstant(size(contentexpressionreply->cnt_cond_dtas,5))
   DECLARE newconddtaid = f8 WITH protect, noconstant(0)
   FOR (index = 1 TO cond_cnt)
     SELECT INTO "nl:"
      j = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       newconddtaid = cnvtreal(j)
      WITH format, nocounter
     ;end select
     CALL bedaddlogstologgerfile(build2("### Inside InsertNewConditionalDTAs - newCondDtaId:",
       newconddtaid))
     INSERT  FROM conditional_dta cd
      SET cd.conditional_dta_id = newconddtaid, cd.cond_expression_id = expressionid, cd.active_ind
        = 1,
       cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), cd.age_from_nbr = contentexpressionreply->cnt_cond_dtas[index].
       cnt_age_from_nbr,
       cd.age_from_unit_cd = contentexpressionreply->cnt_cond_dtas[index].age_from_unit_cd, cd
       .age_to_nbr = contentexpressionreply->cnt_cond_dtas[index].cnt_age_to_nbr, cd.age_to_unit_cd
        = contentexpressionreply->cnt_cond_dtas[index].age_to_unit_cd,
       cd.prev_conditional_dta_id = newconddtaid, cd.required_ind = contentexpressionreply->
       cnt_cond_dtas[index].cnt_required_ind, cd.gender_cd = contentexpressionreply->cnt_cond_dtas[
       index].gender_cd,
       cd.location_cd = contentexpressionreply->cnt_cond_dtas[index].location_cd, cd.position_cd =
       contentexpressionreply->cnt_cond_dtas[index].position_cd, cd.unknown_age_ind =
       contentexpressionreply->cnt_cond_dtas[index].cnt_unknown_age_ind,
       cd.conditional_assay_cd = contentexpressionreply->cnt_cond_dtas[index].conditional_assay_cd,
       cd.updt_id = reqinfo->updt_id, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0, cd.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     CALL bedaddlogstologgerfile(
      "### Inside InsertNewConditionalDTAs - values inserted into conditional_dta Table...")
   ENDFOR
   CALL bedaddlogstologgerfile("### Exiting InsertNewConditionalDTAs ...")
   CALL bedlogmessage("InsertNewConditionalDTAs","Exiting ...")
 END ;Subroutine
 SUBROUTINE getnomenclatureid(aruid)
   CALL bedlogmessage("getNomenclatureID","Entering ...")
   CALL bedaddlogstologgerfile("### Entering getNomenclatureID ...")
   CALL bedaddlogstologgerfile(build2("### Inside getNomenclatureID - arUID:",aruid))
   DECLARE nomenid = f8 WITH protect, noconstant(0)
   IF (aruid="1")
    SET nomenid = 1.0
   ELSE
    SELECT INTO "nl:"
     FROM cnt_alpha_response_key ar,
      nomenclature n
     PLAN (ar
      WHERE ar.ar_uid=aruid)
      JOIN (n
      WHERE n.source_vocabulary_cd=outerjoin(ar.source_vocabulary_cd)
       AND n.source_identifier=outerjoin(ar.source_identifier)
       AND n.source_string=outerjoin(ar.source_string)
       AND n.principle_type_cd=outerjoin(ar.principle_type_cd))
     DETAIL
      IF (ar.nomenclature_id > 0)
       nomenid = ar.nomenclature_id
      ELSE
       nomenid = n.nomenclature_id
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL bedaddlogstologgerfile(build2("### Inside getNomenclatureID - nomenId:",nomenid))
   CALL bedaddlogstologgerfile("### Exiting getNomenclatureID ...")
   CALL bedlogmessage("getNomenclatureID","Exiting ...")
   RETURN(nomenid)
 END ;Subroutine
 SUBROUTINE updateconditionalexpression(expressionid)
   CALL bedlogmessage("UpdateConditionalExpression","Entering ...")
   CALL bedaddlogstologgerfile("### Entering UpdateConditionalExpression ...")
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalExpression - expressionId:",
     expressionid))
   DECLARE prev_exp_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     prev_exp_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalExpression - prev_exp_id:",
     prev_exp_id))
   SELECT INTO "nl:"
    FROM cond_expression ce
    WHERE ce.cond_expression_id=expressionid
     AND ce.active_ind=1
    DETAIL
     exp_version->beg_effective_dt_tm = ce.beg_effective_dt_tm, exp_version->cond_expression_id =
     prev_exp_id, exp_version->cond_expression_name = ce.cond_expression_name,
     exp_version->cond_expression_txt = ce.cond_expression_txt, exp_version->cond_postfix_txt = ce
     .cond_postfix_txt, exp_version->end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     exp_version->multiple_ind = ce.multiple_ind, exp_version->prev_cond_expression_id = ce
     .prev_cond_expression_id
    WITH nocounter
   ;end select
   IF ((((exp_version->cond_expression_name != contentexpressionreply->cnt_cond_expression_name)) OR
   ((((exp_version->cond_expression_txt != contentexpressionreply->cnt_cond_expression_txt)) OR ((((
   exp_version->cond_postfix_txt != contentexpressionreply->cnt_cond_postfix_txt)) OR ((exp_version->
   multiple_ind != contentexpressionreply->cnt_multiple_ind))) )) )) )
    UPDATE  FROM cond_expression ce
     SET ce.cond_expression_name = contentexpressionreply->cnt_cond_expression_name, ce
      .cond_expression_txt = contentexpressionreply->cnt_cond_expression_txt, ce.cond_postfix_txt =
      contentexpressionreply->cnt_cond_postfix_txt,
      ce.multiple_ind = contentexpressionreply->cnt_multiple_ind, ce.updt_id = reqinfo->updt_id, ce
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ce.updt_applctx = reqinfo->updt_applctx, ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_task = reqinfo
      ->updt_task
     WHERE ce.cond_expression_id=expressionid
     WITH nocounter
    ;end update
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalExpression - Table cond_expression updated...")
    INSERT  FROM cond_expression ce
     SET ce.cond_expression_id = prev_exp_id, ce.prev_cond_expression_id = exp_version->
      prev_cond_expression_id, ce.active_ind = 0,
      ce.beg_effective_dt_tm = cnvtdatetime(exp_version->beg_effective_dt_tm), ce.end_effective_dt_tm
       = cnvtdatetime(exp_version->end_effective_dt_tm), ce.cond_expression_name = exp_version->
      cond_expression_name,
      ce.cond_expression_txt = exp_version->cond_expression_txt, ce.cond_postfix_txt = exp_version->
      cond_postfix_txt, ce.multiple_ind = exp_version->multiple_ind,
      ce.updt_id = reqinfo->updt_id, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_applctx
       = reqinfo->updt_applctx,
      ce.updt_cnt = 0, ce.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalExpression - Values inserted into cond_expression Table...")
   ENDIF
   CALL updateconditionalcomponents(expressionid)
   CALL updateconditionaldtas(expressionid)
   CALL bedaddlogstologgerfile("### Exiting UpdateConditionalExpression ...")
   CALL bedlogmessage("UpdateConditionalExpression","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateconditionalcomponents(expressionid)
   CALL bedlogmessage("UpdateConditionalComponents","Entering ...")
   CALL bedaddlogstologgerfile("### Entering UpdateConditionalComponents ...")
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalComponents - expressionId:",
     expressionid))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE comp_cnt = i4 WITH protect, constant(size(contentexpressionreply->cnt_exp_comp,5))
   DECLARE comp_exists = i2 WITH protect, noconstant(0)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO comp_cnt)
     IF ((contentexpressionreply->cnt_exp_comp[x].trigger_assay_cd > 0))
      SELECT INTO "nl:"
       FROM cond_expression_comp cec
       WHERE cec.cond_expression_id=expressionid
        AND (cec.cond_comp_name=contentexpressionreply->cnt_exp_comp[x].cnt_cond_comp_name)
        AND cec.active_ind=1
       DETAIL
        comp_version->cond_comp_name = cec.cond_comp_name, comp_version->cond_expression_comp_id =
        cec.cond_expression_comp_id, comp_version->cond_expression_id = cec.cond_expression_id,
        comp_version->beg_effective_dt_tm = cec.beg_effective_dt_tm, comp_version->
        end_effective_dt_tm = cec.end_effective_dt_tm, comp_version->operator_cd = cec.operator_cd,
        comp_version->parent_entity_id = cec.parent_entity_id, comp_version->parent_entity_name = cec
        .parent_entity_name, comp_version->prev_cond_expression_comp_id = cec
        .prev_cond_expression_comp_id,
        comp_version->required_ind = cec.required_ind, comp_version->result_value = cec.result_value,
        comp_version->trigger_assay_cd = cec.trigger_assay_cd
       WITH nocounter
      ;end select
      IF (curqual > 0)
       CALL bedaddlogstologgerfile(build2(
         "###InsideUpdateConditionalComponents-curqual is>0,callUpdateConditionalCompntByIndex:",
         curqual))
       CALL updateconditionalcomponentbyindex(x)
      ELSE
       CALL bedaddlogstologgerfile(build2(
         "###InsideUpdateConditionalComponents-curqual is not>0,call InsertNewComponentByIndex:",
         curqual))
       CALL insertnewcomponentbyindex(x,expressionid)
      ENDIF
     ENDIF
   ENDFOR
   CALL bedaddlogstologgerfile("### Exiting UpdateConditionalComponents ...")
   CALL bedlogmessage("UpdateConditionalComponents","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateconditionalcomponentbyindex(index)
   CALL bedlogmessage("UpdateConditionalComponentByIndex","Entering ...")
   CALL bedaddlogstologgerfile("### Entering UpdateConditionalComponentByIndex ...")
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalComponentByIndex - INDEX:",index))
   DECLARE nomenid = f8 WITH protect, noconstant(0)
   SET nomenid = getnomenclatureid(contentexpressionreply->cnt_exp_comp[x].ar_uid)
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalComponentByIndex - nomenId:",
     nomenid))
   IF ((((comp_version->operator_cd != contentexpressionreply->cnt_exp_comp[x].operator_cd)) OR ((((
   comp_version->parent_entity_id != nomenid)) OR ((((comp_version->required_ind !=
   contentexpressionreply->cnt_exp_comp[x].cnt_required_ind)) OR ((((comp_version->result_value !=
   contentexpressionreply->cnt_exp_comp[x].cnt_result_value)) OR ((comp_version->trigger_assay_cd !=
   contentexpressionreply->cnt_exp_comp[x].trigger_assay_cd))) )) )) )) )
    DECLARE prev_comp_id = f8 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      prev_comp_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalComponentByIndex - prev_comp_id:",
      prev_comp_id))
    INSERT  FROM cond_expression_comp cec
     SET cec.cond_expression_comp_id = prev_comp_id, cec.cond_expression_id = comp_version->
      cond_expression_id, cec.active_ind = 0,
      cec.beg_effective_dt_tm = cnvtdatetime(comp_version->beg_effective_dt_tm), cec
      .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cec.cond_comp_name = comp_version->
      cond_comp_name,
      cec.operator_cd = comp_version->operator_cd, cec.parent_entity_id = comp_version->
      parent_entity_id, cec.parent_entity_name = comp_version->parent_entity_name,
      cec.prev_cond_expression_comp_id = comp_version->prev_cond_expression_comp_id, cec.required_ind
       = comp_version->required_ind, cec.result_value = comp_version->result_value,
      cec.trigger_assay_cd = comp_version->trigger_assay_cd, cec.updt_id = reqinfo->updt_id, cec
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cec.updt_applctx = reqinfo->updt_applctx, cec.updt_cnt = 0, cec.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalComponentByIndex - Values inserted into cond_expression_comp Table..."
     )
    UPDATE  FROM cond_expression_comp cec
     SET cec.active_ind = 1, cec.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cec
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      cec.cond_comp_name = contentexpressionreply->cnt_exp_comp[index].cnt_cond_comp_name, cec
      .operator_cd = contentexpressionreply->cnt_exp_comp[index].operator_cd, cec.parent_entity_id =
      nomenid,
      cec.required_ind = contentexpressionreply->cnt_exp_comp[index].cnt_required_ind, cec
      .result_value = contentexpressionreply->cnt_exp_comp[index].cnt_result_value, cec
      .trigger_assay_cd = contentexpressionreply->cnt_exp_comp[index].trigger_assay_cd,
      cec.updt_id = reqinfo->updt_id, cec.updt_dt_tm = cnvtdatetime(curdate,curtime3), cec
      .updt_applctx = reqinfo->updt_applctx,
      cec.updt_cnt = (cec.updt_cnt+ 1), cec.updt_task = reqinfo->updt_task
     WHERE (cec.cond_expression_comp_id=comp_version->cond_expression_comp_id)
     WITH nocounter
    ;end update
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalComponentByIndex - Table cond_expression_comp updated...")
   ENDIF
   CALL bedaddlogstologgerfile("### Exiting UpdateConditionalComponentByIndex ...")
   CALL bedlogmessage("UpdateConditionalComponentByIndex","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewcomponentbyindex(index,expressionid)
   CALL bedlogmessage("InsertNewComponentByIndex","Entering ...")
   CALL bedaddlogstologgerfile("### Entering InsertNewComponentByIndex ...")
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewComponentByIndex-INDEX value:",index,
     "expressionId value:",expressionid))
   DECLARE newcompid = f8 WITH protect, noconstant(0)
   DECLARE nomenid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newcompid = cnvtreal(j)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewComponentByIndex - newCompId:",newcompid))
   IF ((contentexpressionreply->cnt_exp_comp[index].ar_uid != ""))
    SET nomenid = getnomenclatureid(contentexpressionreply->cnt_exp_comp[index].ar_uid)
   ENDIF
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewComponentByIndex - nomenId:",nomenid))
   INSERT  FROM cond_expression_comp cec
    SET cec.cond_expression_comp_id = newcompid, cec.cond_expression_id = expressionid, cec
     .active_ind = 1,
     cec.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cec.end_effective_dt_tm = cnvtdatetime
     ("31-DEC-2100"), cec.cond_comp_name = contentexpressionreply->cnt_exp_comp[index].
     cnt_cond_comp_name,
     cec.operator_cd = contentexpressionreply->cnt_exp_comp[index].operator_cd, cec.parent_entity_id
      = nomenid, cec.parent_entity_name =
     IF (nomenid > 0) "NOMENCLATURE"
     ELSE ""
     ENDIF
     ,
     cec.prev_cond_expression_comp_id = newcompid, cec.required_ind = contentexpressionreply->
     cnt_exp_comp[index].cnt_required_ind, cec.result_value = contentexpressionreply->cnt_exp_comp[
     index].cnt_result_value,
     cec.trigger_assay_cd = contentexpressionreply->cnt_exp_comp[index].trigger_assay_cd, cec.updt_id
      = reqinfo->updt_id, cec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cec.updt_applctx = reqinfo->updt_applctx, cec.updt_cnt = 0, cec.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bedaddlogstologgerfile(
    "### Inside InsertNewComponentByIndex - Values inserted into cond_expression_comp Table...")
   CALL bedaddlogstologgerfile("### Exiting InsertNewComponentByIndex ...")
   CALL bedlogmessage("InsertNewComponentByIndex","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateconditionaldtas(expressionid)
   CALL bedlogmessage("UpdateConditionalDTAs","Entering ...")
   CALL bedaddlogstologgerfile("### Entering UpdateConditionalDTAs ...")
   CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalDTAs - expressionId:",expressionid
     ))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE cond_cnt = i4 WITH protect, constant(size(contentexpressionreply->cnt_cond_dtas,5))
   DECLARE cond_exists = i2 WITH protect, noconstant(0)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO cond_cnt)
     IF ((contentexpressionreply->cnt_cond_dtas[x].conditional_assay_cd > 0))
      SELECT INTO "nl:"
       FROM conditional_dta cd
       WHERE (cd.conditional_assay_cd=contentexpressionreply->cnt_cond_dtas[x].conditional_assay_cd)
        AND cd.active_ind=1
        AND cd.cond_expression_id=expressionid
       DETAIL
        dta_version->age_from_nbr = cd.age_from_nbr, dta_version->age_from_unit_cd = cd
        .age_from_unit_cd, dta_version->age_to_nbr = cd.age_to_nbr,
        dta_version->age_to_unit_cd = cd.age_to_unit_cd, dta_version->beg_effective_dt_tm = cd
        .beg_effective_dt_tm, dta_version->end_effective_dt_tm = cd.end_effective_dt_tm,
        dta_version->cond_expression_id = cd.cond_expression_id, dta_version->conditional_assay_cd =
        cd.conditional_assay_cd, dta_version->conditional_dta_id = cd.conditional_dta_id,
        dta_version->gender_cd = cd.gender_cd, dta_version->location_cd = cd.location_cd, dta_version
        ->position_cd = cd.position_cd,
        dta_version->required_ind = cd.required_ind, dta_version->unknown_age_ind = cd
        .unknown_age_ind, dta_version->prev_conditional_dta_id = cd.prev_conditional_dta_id
       WITH nocounter
      ;end select
      IF (curqual > 0)
       CALL bedaddlogstologgerfile(build2(
         "###Inside UpdateConditionalDTAs-curqual is>0,calling UpdateConditionalDTAByIndex:",curqual)
        )
       CALL updateconditionaldtabyindex(x,expressionid)
      ELSE
       CALL bedaddlogstologgerfile(build2(
         "###InsideUpdateConditionalDTAs-curqual isnot>0,call InsertNewConditionalDTAByIndex:",
         curqual))
       CALL insertnewconditionaldtabyindex(x,expressionid)
      ENDIF
     ENDIF
   ENDFOR
   CALL bedaddlogstologgerfile("### Exiting UpdateConditionalDTAs ...")
   CALL bedlogmessage("UpdateConditionalDTAs","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateconditionaldtabyindex(index,expressionid)
   CALL bedlogmessage("UpdateConditionalDTAByIndex","Entering ...")
   CALL bedaddlogstologgerfile("### Entering UpdateConditionalDTAByIndex ...")
   CALL bedaddlogstologgerfile(build2("###Inside UpdateConditionalDTAByIndex-INDEX value:",index,
     "expressionId value:",expressionid))
   IF ((((dta_version->age_from_nbr != contentexpressionreply->cnt_cond_dtas[x].cnt_age_from_nbr))
    OR ((((dta_version->age_from_unit_cd != contentexpressionreply->cnt_cond_dtas[x].age_from_unit_cd
   )) OR ((((dta_version->age_to_nbr != contentexpressionreply->cnt_cond_dtas[x].cnt_age_to_nbr)) OR
   ((((dta_version->age_to_unit_cd != contentexpressionreply->cnt_cond_dtas[x].age_to_unit_cd)) OR (
   (((dta_version->conditional_assay_cd != contentexpressionreply->cnt_cond_dtas[x].
   conditional_assay_cd)) OR ((((dta_version->gender_cd != contentexpressionreply->cnt_cond_dtas[x].
   gender_cd)) OR ((((dta_version->location_cd != contentexpressionreply->cnt_cond_dtas[x].
   location_cd)) OR ((((dta_version->position_cd != contentexpressionreply->cnt_cond_dtas[x].
   position_cd)) OR ((((dta_version->required_ind != contentexpressionreply->cnt_cond_dtas[x].
   cnt_required_ind)) OR ((dta_version->unknown_age_ind != contentexpressionreply->cnt_cond_dtas[x].
   cnt_unknown_age_ind))) )) )) )) )) )) )) )) )) )
    DECLARE prev_cond_id = f8 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      prev_cond_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    CALL bedaddlogstologgerfile(build2("### Inside UpdateConditionalDTAByIndex - prev_cond_id:",
      prev_cond_id))
    INSERT  FROM conditional_dta cd
     SET cd.conditional_dta_id = prev_cond_id, cd.cond_expression_id = dta_version->
      cond_expression_id, cd.active_ind = 0,
      cd.beg_effective_dt_tm = cnvtdatetime(dta_version->beg_effective_dt_tm), cd.end_effective_dt_tm
       = cnvtdatetime(curdate,curtime3), cd.age_from_nbr = dta_version->age_from_nbr,
      cd.age_from_unit_cd = dta_version->age_from_unit_cd, cd.age_to_nbr = dta_version->age_to_nbr,
      cd.age_to_unit_cd = dta_version->age_to_unit_cd,
      cd.prev_conditional_dta_id = prev_cond_id, cd.required_ind = dta_version->required_ind, cd
      .gender_cd = dta_version->gender_cd,
      cd.location_cd = dta_version->location_cd, cd.position_cd = dta_version->position_cd, cd
      .unknown_age_ind = dta_version->unknown_age_ind,
      cd.conditional_assay_cd = dta_version->conditional_assay_cd, cd.updt_id = reqinfo->updt_id, cd
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0, cd.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalDTAByIndex - Values inserted into conditional_dta Table...")
    UPDATE  FROM conditional_dta cd
     SET cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm =
      cnvtdatetime("31-DEC-2100"), cd.age_from_nbr = contentexpressionreply->cnt_cond_dtas[index].
      cnt_age_from_nbr,
      cd.age_from_unit_cd = contentexpressionreply->cnt_cond_dtas[index].age_from_unit_cd, cd
      .age_to_nbr = contentexpressionreply->cnt_cond_dtas[index].cnt_age_to_nbr, cd.age_to_unit_cd =
      contentexpressionreply->cnt_cond_dtas[index].age_to_unit_cd,
      cd.gender_cd = contentexpressionreply->cnt_cond_dtas[index].gender_cd, cd.required_ind =
      contentexpressionreply->cnt_cond_dtas[index].cnt_required_ind, cd.location_cd =
      contentexpressionreply->cnt_cond_dtas[index].location_cd,
      cd.position_cd = contentexpressionreply->cnt_cond_dtas[index].position_cd, cd.unknown_age_ind
       = contentexpressionreply->cnt_cond_dtas[index].cnt_unknown_age_ind, cd.conditional_assay_cd =
      contentexpressionreply->cnt_cond_dtas[index].conditional_assay_cd,
      cd.updt_id = reqinfo->updt_id, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_applctx
       = reqinfo->updt_applctx,
      cd.updt_cnt = (cd.updt_cnt+ 1), cd.updt_task = reqinfo->updt_task
     WHERE (cd.conditional_assay_cd=contentexpressionreply->cnt_cond_dtas[index].conditional_assay_cd
     )
      AND cd.cond_expression_id=expressionid
      AND cd.active_ind=1
     WITH nocounter
    ;end update
    CALL bedaddlogstologgerfile(
     "### Inside UpdateConditionalDTAByIndex - conditional_dta Table Updated...")
   ENDIF
   CALL bedaddlogstologgerfile("### Exiting UpdateConditionalDTAByIndex ...")
   CALL bedlogmessage("UpdateConditionalDTAByIndex","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertnewconditionaldtabyindex(index,expressionid)
   CALL bedlogmessage("InsertNewConditionalDTAByIndex","Entering ...")
   CALL bedaddlogstologgerfile("### Entering InsertNewConditionalDTAByIndex ...")
   CALL bedaddlogstologgerfile(build2("###Inside InsertNewConditionalDTAByIndex-INDEX:",index,
     "expressionId:",expressionid))
   DECLARE newconddtaid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    j = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newconddtaid = cnvtreal(j)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside InsertNewConditionalDTAByIndex - newCondDtaId:",
     newconddtaid))
   INSERT  FROM conditional_dta cd
    SET cd.conditional_dta_id = newconddtaid, cd.cond_expression_id = expressionid, cd.active_ind = 1,
     cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), cd.age_from_nbr = contentexpressionreply->cnt_cond_dtas[index].cnt_age_from_nbr,
     cd.age_from_unit_cd = contentexpressionreply->cnt_cond_dtas[index].age_from_unit_cd, cd
     .age_to_nbr = contentexpressionreply->cnt_cond_dtas[index].cnt_age_to_nbr, cd.age_to_unit_cd =
     contentexpressionreply->cnt_cond_dtas[index].age_to_unit_cd,
     cd.prev_conditional_dta_id = newconddtaid, cd.required_ind = contentexpressionreply->
     cnt_cond_dtas[index].cnt_required_ind, cd.gender_cd = contentexpressionreply->cnt_cond_dtas[
     index].gender_cd,
     cd.location_cd = contentexpressionreply->cnt_cond_dtas[index].location_cd, cd.position_cd =
     contentexpressionreply->cnt_cond_dtas[index].position_cd, cd.unknown_age_ind =
     contentexpressionreply->cnt_cond_dtas[index].cnt_unknown_age_ind,
     cd.conditional_assay_cd = contentexpressionreply->cnt_cond_dtas[index].conditional_assay_cd, cd
     .updt_id = reqinfo->updt_id, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0, cd.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bedaddlogstologgerfile(
    "### Inside InsertNewConditionalDTAByIndex - Values inserted into conditional_dta Table...")
   CALL bedaddlogstologgerfile("### Exiting InsertNewConditionalDTAByIndex ...")
   CALL bedlogmessage("InsertNewConditionalDTAByIndex","Exiting ...")
 END ;Subroutine
END GO
