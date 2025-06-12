CREATE PROGRAM bed_ens_pwrform_assay:dba
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
 FREE RECORD assaystosave
 RECORD assaystosave(
   1 assays[*]
     2 assay_action_flag = i2
     2 task_assay_uid = vc
     2 task_assay_cd = f8
     2 description = vc
     2 save_interps = i2
 )
 FREE RECORD ultragridassays
 RECORD ultragridassays(
   1 list[*]
     2 dtacd = f8
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
 DECLARE insertsection(dcpsectionrefid=f8,description=vc,definition=vc,taskassaycd=f8,eventcd=f8,
  height=i4,width=4,rsectionrefid=f8(ref),rsectioninstanceid=f8(ref)) = i2
 DECLARE deletesection(dcpsectionrefid) = i2
 DECLARE insertcontrol(dcpsectionrefid=f8,dcpsectioninstanceid=f8,desc=vc,module=vc,inputseq=i4,
  inputtype=i4) = f8
 DECLARE insertpropertyforcontrol(dcpinputrefid=f8,pvcname=vc,pvcvalue=vc,mergename=vc,mergeid=f8,
  propseq=i4) = f8
 DECLARE determineparententityid(parententityname=vc,mergeuid=vc) = f8
 DECLARE insertcodevalue(cdfmeaning=vc,definition=vc,description=vc,display=vc,codeset=i4,
  conceptcki=vc,cki=vc) = f8
 DECLARE inserteventcode(ncodevalue=f8,cvdefinition=vc,cvdescription=vc,cvdisplay=vc,eventsetname=vc)
  = i2
 DECLARE insertnewformandsectionsrelationship(formrefid=f8,forminstanceid=f8,dcp_section_ref_id=f8,
  section_seq=i4,conditional_flags=i4) = i2
 DECLARE getcorrectnewlinecharforstring(stringtoconvert=vc) = vc
 DECLARE updatecntinputkeytable(cntinputkeyid=f8,dcpinputrefid=f8) = i2
 DECLARE updatecntinputtable(newpropid=f8,cntinputid=f8) = i2
 DECLARE isconditionalunit(propname=vc) = i2
 DECLARE isgrideventcode(propname=vc) = i2
 DECLARE logdebuginfo(desc=vc) = i2
 SUBROUTINE insertsection(dcpsectionrefid,description,definition,taskassaycd,eventcd,height,width,
  rsectionrefid,rsectioninstanceid)
   CALL bedlogmessage("insertSection","Entering ...")
   CALL bedaddlogstologgerfile("### Entering bed_powerform_ensure_subs.inc - insertSection ...")
   SET rsectionrefid = 0.0
   SET rsectioninstanceid = 0.0
   IF (dcpsectionrefid > 0)
    SET rsectionrefid = dcpsectionrefid
   ELSE
    SELECT INTO "nl:"
     w = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      rsectionrefid = w
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    ww = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     rsectioninstanceid = ww
    WITH nocounter
   ;end select
   INSERT  FROM dcp_section_ref dsr
    SET dsr.dcp_section_ref_id = rsectionrefid, dsr.dcp_section_instance_id = rsectioninstanceid, dsr
     .description = description,
     dsr.definition = definition, dsr.task_assay_cd = taskassaycd, dsr.event_cd = eventcd,
     dsr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), dsr.end_effective_dt_tm = cnvtdatetime
     ("31-Dec-2100"), dsr.active_ind = true,
     dsr.width = width, dsr.height = height, dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
     updt_applctx,
     dsr.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Insert into dcp_section_ref failed")
   IF (validate(debug,0)=1)
    CALL logdebuginfo(build2("Inserted dcp_section_ref_id: ",rsectionrefid))
    CALL logdebuginfo(build2("Inserted dcp_section_instance_id: ",rsectioninstanceid))
   ENDIF
   CALL bedaddlogstologgerfile(build2("Inserted dcp_section_ref_id: ",rsectionrefid))
   CALL bedaddlogstologgerfile(build2("Inserted dcp_section_instance_id: ",rsectioninstanceid))
   CALL bedlogmessage("insertSection","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting bed_powerform_ensure_subs.inc - insertSection ...")
 END ;Subroutine
 SUBROUTINE deletesection(dcpsectionrefid)
   CALL bedlogmessage("deleteSection","Entering ...")
   CALL bedaddlogstologgerfile("### Entering bed_powerform_ensure_subs.inc - deleteSection ...")
   UPDATE  FROM dcp_section_ref dsr
    SET dsr.active_ind = false, dsr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dsr
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
     updt_applctx,
     dsr.updt_cnt = (dsr.updt_cnt+ 1)
    WHERE dsr.dcp_section_ref_id=dcpsectionrefid
     AND dsr.active_ind=true
    WITH nocounter
   ;end update
   CALL bederrorcheck("Update into dcp_section_ref failed")
   CALL bedaddlogstologgerfile(build2("### Inside deleteSection - DCP Section Ref ID:",
     dcpsectionrefid))
   CALL bedlogmessage("deleteSection","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting bed_powerform_ensure_subs.inc - deleteSection ...")
 END ;Subroutine
 SUBROUTINE insertcontrol(dcpsectionrefid,dcpsectioninstanceid,desc,module,inputseq,inputtype)
   CALL bedlogmessage("insertControl","Entering ...")
   CALL bedaddlogstologgerfile("### Entering bed_powerform_ensure_subs.inc - insertControl ...")
   DECLARE dcpinputrefid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     dcpinputrefid = w
    WITH nocounter
   ;end select
   INSERT  FROM dcp_input_ref dir
    SET dir.dcp_input_ref_id = dcpinputrefid, dir.dcp_section_ref_id = dcpsectionrefid, dir
     .dcp_section_instance_id = dcpsectioninstanceid,
     dir.description = desc, dir.module = module, dir.input_ref_seq = inputseq,
     dir.input_type = inputtype, dir.active_ind = true, dir.updt_cnt = 0,
     dir.updt_dt_tm = cnvtdatetime(curdate,curtime3), dir.updt_id = reqinfo->updt_id, dir.updt_task
      = reqinfo->updt_task,
     dir.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Insert into dcp_input_ref failed.")
   IF (validate(debug,0)=1)
    CALL logdebuginfo(build2("Inserted dcp_input_ref_id: ",dcpinputrefid))
   ENDIF
   CALL bedaddlogstologgerfile(build2("Inserted dcp_input_ref_id: ",dcpinputrefid))
   CALL bedlogmessage("insertControl","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting bed_powerform_ensure_subs.inc - insertControl ...")
   RETURN(dcpinputrefid)
 END ;Subroutine
 SUBROUTINE insertpropertyforcontrol(dcpinputrefid,pvcname,pvcvalue,mergename,mergeid,propseq)
   CALL bedlogmessage("insertPropertyForControl","Entering ...")
   CALL bedaddlogstologgerfile("### Entering insertPropertyForControl ...")
   DECLARE newnamevalueprefsid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    w = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     newnamevalueprefsid = w
    WITH nocounter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = newnamevalueprefsid, nvp.parent_entity_name = "DCP_INPUT_REF", nvp
     .parent_entity_id = dcpinputrefid,
     nvp.pvc_name = pvcname, nvp.pvc_value = pvcvalue, nvp.merge_name = mergename,
     nvp.merge_id = mergeid, nvp.sequence = propseq, nvp.active_ind = true,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Insert into name_value_prefs failed.")
   IF (validate(debug,0)=1)
    CALL logdebuginfo(build2("Inserted name_value_prefs_id: ",newnamevalueprefsid))
   ENDIF
   CALL bedaddlogstologgerfile(build2("Inserted name_value_prefs_id: ",newnamevalueprefsid))
   CALL bedlogmessage("insertPropertyForControl","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting insertPropertyForControl ...")
   RETURN(newnamevalueprefsid)
 END ;Subroutine
 SUBROUTINE determineparententityid(parententityname,mergeuid)
   CALL bedlogmessage("determineParentEntityId","Entering ...")
   CALL bedaddlogstologgerfile("### Entering determineParentEntityId ...")
   DECLARE parententityid = f8 WITH protect, noconstant(0.0)
   IF (validate(debug,0)=1)
    CALL logdebuginfo(build2("Merge name: ",parententityname))
    CALL logdebuginfo(build2("Merge uid: ",mergeuid))
   ENDIF
   CALL bedaddlogstologgerfile(build2("### parentEntityName:",parententityname," mergeUid:",mergeuid)
    )
   IF (parententityname IN ("CODE_VALUE", "V500_EVENT_CODE"))
    DECLARE cvcdfmeaning = vc WITH protect, noconstant("")
    DECLARE cvdefinition = vc WITH protect, noconstant("")
    DECLARE cvdescription = vc WITH protect, noconstant("")
    DECLARE cvdisplay = vc WITH protect, noconstant("")
    DECLARE cvcodeset = i4 WITH protect, noconstant(0)
    DECLARE cvcki = vc WITH protect, noconstant("")
    DECLARE cvconceptcki = vc WITH protect, noconstant("")
    DECLARE eventsetname = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM cnt_code_value_key k,
      code_value cv
     PLAN (k
      WHERE k.code_value_uid=mergeuid)
      JOIN (cv
      WHERE cv.cdf_meaning=outerjoin(k.cdf_meaning)
       AND cv.display=outerjoin(k.display)
       AND cv.description=outerjoin(k.description)
       AND cv.code_set=outerjoin(k.code_set))
     DETAIL
      IF (k.code_value > 0)
       parententityid = k.code_value
      ELSEIF (cv.code_value > 0)
       parententityid = cv.code_value
      ELSE
       cvcdfmeaning = k.cdf_meaning, cvdefinition = k.definition, cvdescription = k.description,
       cvdisplay = k.display, cvcodeset = k.code_set, cvcki = k.cki,
       cvconceptcki = k.concept_cki, eventsetname = k.event_set_name
      ENDIF
     WITH nocounter
    ;end select
    IF (validate(debug,0)=1)
     CALL logdebuginfo(build2("Did I find existing code value: ",parententityid))
     CALL logdebuginfo(build2("cvCdfMeaning: ",cvcdfmeaning))
     CALL logdebuginfo(build2("cvDefinition: ",cvdefinition))
     CALL logdebuginfo(build2("cvDescription: ",cvdescription))
     CALL logdebuginfo(build2("cvDisplay: ",cvdisplay))
     CALL logdebuginfo(build2("cvCodeSet: ",cvcodeset))
    ENDIF
    CALL bedaddlogstologgerfile(build2("### parentEntityId:",parententityid," cvCdfMeaning:",
      cvcdfmeaning," cvDefinition:",
      cvdefinition," cvDescription:",cvdescription," cvDisplay:",cvdisplay,
      " cvCodeSet:",cvcodeset," cvCki:",cvcki," cvConceptCki:",
      cvconceptcki," eventSetName:",eventsetname))
    IF (parententityid > 0)
     RETURN(parententityid)
    ENDIF
    SET parententityid = insertcodevalue(cvcdfmeaning,cvdefinition,cvdescription,cvdisplay,cvcodeset,
     cvconceptcki,cvcki)
    IF (parententityid > 0)
     CALL bedaddlogstologgerfile(build2("### created parentEntityId:",parententityid))
     IF (parententityname="V500_EVENT_CODE")
      CALL inserteventcode(parententityid,cvdefinition,cvdescription,cvdisplay,eventsetname)
     ENDIF
     UPDATE  FROM cnt_code_value_key c
      SET c.code_value = parententityid, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
       reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
       updt_applctx
      WHERE c.code_value_uid=mergeuid
      WITH nocounter
     ;end update
     IF (validate(debug,0)=1)
      CALL logdebuginfo(build2("Inserted code value: ",parententityid))
     ENDIF
    ENDIF
   ELSEIF (((parententityname="DISCRETE_TASK_ASSAY") OR (parententityname="DISCRETE_TASK_ASSAY1")) )
    SELECT INTO "nl:"
     FROM cnt_dta_key2 k,
      cnt_dta cd,
      discrete_task_assay dta
     PLAN (k
      WHERE k.task_assay_uid=mergeuid)
      JOIN (cd
      WHERE cd.task_assay_uid=k.task_assay_uid)
      JOIN (dta
      WHERE dta.activity_type_cd=outerjoin(cd.activity_type_cd)
       AND dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
       AND dta.active_ind=outerjoin(1))
     DETAIL
      IF (k.task_assay_cd > 0)
       parententityid = k.task_assay_cd
      ELSEIF (dta.task_assay_cd > 0)
       parententityid = dta.task_assay_cd
      ENDIF
     WITH nocounter
    ;end select
    IF (validate(debug,0)=1)
     CALL logdebuginfo(build2("Did I find existing assay_cd: ",parententityid))
    ENDIF
    CALL bedaddlogstologgerfile(build2("### Assay parentEntityId:",parententityid))
    IF (parententityid > 0)
     RETURN(parententityid)
    ENDIF
   ELSEIF (parententityname="DCP_SECTION_REF")
    SELECT INTO "nl:"
     FROM cnt_section_key k,
      dcp_section_ref d
     PLAN (k
      WHERE k.section_uid=mergeuid)
      JOIN (d
      WHERE d.definition=outerjoin(k.section_definition))
     DETAIL
      IF (k.dcp_section_ref_id > 0)
       parententityid = k.dcp_section_ref_id
      ELSEIF (d.dcp_section_ref_id > 0)
       parententityid = d.dcp_section_ref_id
      ENDIF
     WITH nocounter
    ;end select
    IF (validate(debug,0)=1)
     CALL logdebuginfo(build2("Did I find existing section id: ",parententityid))
    ENDIF
    CALL bedaddlogstologgerfile(build2("### Section parentEntityId:",parententityid))
    IF (parententityid > 0)
     RETURN(parententityid)
    ENDIF
   ENDIF
   CALL bedlogmessage("determineParentEntityId","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting determineParentEntityId ...")
   RETURN(parententityid)
 END ;Subroutine
 SUBROUTINE insertcodevalue(cdfmeaning,definition,description,display,codeset,conceptcki,cki)
   CALL bedlogmessage("insertCodeValue","Entering ...")
   CALL bedaddlogstologgerfile("### Entering insertCodeValue ...")
   DECLARE rcodevalue = f8 WITH protect, noconstant(0.0)
   IF (codeset IN (72, 14003))
    FREE SET request_cv
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
      1 ignore_duplicate_checks = i2
    )
    FREE SET reply_cv
    RECORD reply_cv(
      1 curqual = i4
      1 qual[*]
        2 status = i2
        2 error_num = i4
        2 error_msg = vc
        2 code_value = f8
        2 cki = vc
      1 error_msg = vc
      1 status_data
        2 status = c1
        2 subeventstatus[*]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].active_ind = 1
    SET request_cv->cd_value_list[1].code_set = codeset
    SET request_cv->cd_value_list[1].cdf_meaning = cdfmeaning
    SET request_cv->cd_value_list[1].display = display
    SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(display))
    SET request_cv->cd_value_list[1].definition = definition
    SET request_cv->cd_value_list[1].description = description
    SET request_cv->cd_value_list[1].concept_cki = conceptcki
    SET request_cv->cd_value_list[1].cki = cki
    SET request_cv->ignore_duplicate_checks = 1
    IF (validate(debug,0)=1)
     CALL echorecord(request_cv)
    ENDIF
    CALL bedaddlogstologgerfile(cnvtrectoxml(request_cv))
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET rcodevalue = reply_cv->qual[1].code_value
    ELSE
     CALL bederrorcheck("bed_ens_cd_value failed.")
    ENDIF
    CALL bedaddlogstologgerfile(cnvtrectoxml(reply_cv))
    CALL bedlogmessage("insertCodeValue","Exiting ...")
   ENDIF
   CALL bedaddlogstologgerfile("### Exiting insertCodeValue ...")
   RETURN(rcodevalue)
 END ;Subroutine
 SUBROUTINE inserteventcode(ncodevalue,cvdefinition,cvdescription,cvdisplay,eventsetname)
   CALL bedlogmessage("insertEventCode","Entering ...")
   CALL bedaddlogstologgerfile("### Entering insertEventCode ...")
   DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE format_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"UNKNOWN"))
   DECLARE storage_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"UNKNOWN"))
   DECLARE class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"UNKNOWN"))
   DECLARE level_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",87,"ROUTCLINICAL"))
   DECLARE subclass_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",102,"UNKNOWN"))
   DECLARE status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
   CALL bedaddlogstologgerfile(build2("### nCodeValue:",ncodevalue," cvDefinition:",cvdefinition,
     " cvDescription:",
     cvdescription," cvDisplay:",cvdisplay," eventSetName:",eventsetname,
     " active_cd:",active_cd," format_cd:",format_cd," storage_cd:",
     storage_cd," class_cd:",class_cd," level_cd:",level_cd,
     " subclass_cd:",subclass_cd," status_cd:",status_cd))
   INSERT  FROM v500_event_code vec
    SET vec.event_cd = ncodevalue, vec.event_cd_definition = trim(substring(1,100,cvdefinition)), vec
     .event_cd_descr = trim(substring(1,60,cvdescription)),
     vec.event_cd_disp = trim(substring(1,40,cvdisplay)), vec.event_cd_disp_key = trim(substring(1,40,
       cnvtupper(cnvtalphanum(cvdisplay)))), vec.code_status_cd = active_cd,
     vec.def_docmnt_attributes = null, vec.def_docmnt_format_cd = format_cd, vec
     .def_docmnt_storage_cd = storage_cd,
     vec.def_event_class_cd = class_cd, vec.def_event_confid_level_cd = level_cd, vec.def_event_level
      = null,
     vec.event_add_access_ind = 0.0, vec.event_cd_subclass_cd = subclass_cd, vec.event_chg_access_ind
      = 0,
     vec.event_set_name = trim(substring(1,40,eventsetname)), vec.retention_days = null, vec
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0,
     vec.updt_applctx = reqinfo->updt_applctx, vec.event_code_status_cd = status_cd, vec
     .collating_seq = 0.0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Insert Event Code")
   CALL bedlogmessage("insertEventCode","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting insertEventCode ...")
 END ;Subroutine
 SUBROUTINE insertnewformandsectionsrelationship(formrefid,forminstanceid,dcp_section_ref_id,
  section_seq,flags)
   CALL bedlogmessage("insertNewFormAndSectionsRelationship ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering insertNewFormAndSectionsRelationship ...")
   CALL logdebuginfo(build2("dcp_section_ref_id = ",dcp_section_ref_id))
   CALL logdebuginfo(build2("section_seq = ",section_seq))
   CALL logdebuginfo(build2("flags = ",flags))
   CALL bedaddlogstologgerfile(build2("dcp_section_ref_id = ",dcp_section_ref_id))
   CALL bedaddlogstologgerfile(build2("section_seq = ",section_seq))
   CALL bedaddlogstologgerfile(build2("flags = ",flags))
   INSERT  FROM dcp_forms_def dfd
    SET dfd.dcp_forms_def_id = seq(carenet_seq,nextval), dfd.dcp_form_instance_id = forminstanceid,
     dfd.dcp_forms_ref_id = formrefid,
     dfd.active_ind = 1, dfd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfd.updt_id = reqinfo->
     updt_id,
     dfd.updt_task = reqinfo->updt_task, dfd.updt_cnt = 0, dfd.updt_applctx = reqinfo->updt_applctx,
     dfd.dcp_section_ref_id = dcp_section_ref_id, dfd.section_seq = section_seq, dfd.flags = flags
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Insert into dcp_forms_def failed")
   CALL bedlogmessage("insertNewFormAndSectionsRelationship ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting insertNewFormAndSectionsRelationship ...")
 END ;Subroutine
 SUBROUTINE updatecntinputkeytable(cntinputkeyid,dcpinputrefid)
   CALL bedlogmessage("updateCNTInputKeyTable ","Entering ...")
   CALL bedaddlogstologgerfile(
    "### Entering bed_powerform_ensure_subs.inc - updateCntInputKeyTable ...")
   UPDATE  FROM cnt_input_key cik
    SET cik.dcp_input_ref_id = dcpinputrefid, cik.updt_cnt = (cik.updt_cnt+ 1), cik.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cik.updt_id = reqinfo->updt_id, cik.updt_task = reqinfo->updt_task, cik.updt_applctx = reqinfo->
     updt_applctx
    WHERE cik.cnt_input_key_id=cntinputkeyid
    WITH nocounter
   ;end update
   CALL bederrorcheck("Update cnt_input_key with dcp id")
   CALL bedaddlogstologgerfile(build2("### Inserted - CNT Input Key ID:",cntinputkeyid))
   CALL bedaddlogstologgerfile(build2("### Inserted - DCP Input Ref ID:",dcpinputrefid))
   CALL bedlogmessage("updateCNTInputKeyTable ","Exiting ...")
   CALL bedaddlogstologgerfile(
    "### Exiting bed_powerform_ensure_subs.inc - updateCntInputKeyTable ...")
 END ;Subroutine
 SUBROUTINE updatecntinputtable(newpropid,cntinputid)
   CALL bedlogmessage("updateCntInputTable ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateCntInputTable ...")
   UPDATE  FROM cnt_input i
    SET i.name_value_prefs_id = newpropid, i.updt_cnt = (i.updt_cnt+ 1), i.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     i.updt_id = reqinfo->updt_id, i.updt_task = reqinfo->updt_task, i.updt_applctx = reqinfo->
     updt_applctx
    WHERE i.cnt_input_id=cntinputid
    WITH nocounter
   ;end update
   CALL bederrorcheck("Update cnt_input failed")
   CALL bedaddlogstologgerfile(build2("### Inside updateCntInputTable - newPropId:",newpropid))
   CALL bedaddlogstologgerfile(build2("### Inside updateCntInputTable - cntInputId:",cntinputid))
   CALL bedlogmessage("updateCntInputTable ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateCntInputTable ...")
 END ;Subroutine
 SUBROUTINE isconditionalunit(propname)
  IF (propname IN ("conditional_section_unit", "conditional_control_unit"))
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE isgrideventcode(propname)
  IF (propname="grid_event_cd")
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE getcorrectnewlinecharforstring(stringtoconvert)
   DECLARE stringtoreturn = vc WITH protect, noconstant("")
   SET stringtoreturn = replace(stringtoconvert,"\u000a",char(10))
   RETURN(stringtoreturn)
 END ;Subroutine
 SUBROUTINE logdebuginfo(desc)
   IF (validate(debug,0)=1)
    CALL echo("===============================================")
    CALL echo(desc)
    CALL echo("===============================================")
   ENDIF
 END ;Subroutine
 FREE RECORD ensassayrequest
 RECORD ensassayrequest(
   1 assay_list[*]
     2 action_flag = i2
     2 code_value = f8
     2 display = c50
     2 description = vc
     2 general_info
       3 result_type_code_value = f8
       3 activity_type_code_value = f8
       3 delta_check_ind = i2
       3 inter_data_check_ind = i2
       3 res_proc_type_code_value = f8
       3 rad_section_type_code_value = f8
       3 single_select_ind = i2
       3 io_flag = i2
       3 default_type_flag = i2
       3 sci_notation_ind = i2
       3 concept_cki = vc
     2 data_map[*]
       3 action_flag = i4
       3 service_resource_code_value = f8
       3 min_digits = i4
       3 max_digits = i4
       3 dec_place = i4
     2 rr_list[*]
       3 action_flag = i4
       3 sequence = i4
       3 rrf_id = f8
       3 def_value = f8
       3 uom_code_value = f8
       3 from_age = i4
       3 from_age_code_value = f8
       3 to_age = i4
       3 to_age_code_value = f8
       3 unknown_age_ind = i2
       3 sex_code_value = f8
       3 specimen_type_code_value = f8
       3 service_resource_code_value = f8
       3 ref_low = f8
       3 ref_high = f8
       3 ref_ind = i2
       3 crit_low = f8
       3 crit_high = f8
       3 crit_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 review_ind = i2
       3 linear_low = f8
       3 linear_high = f8
       3 linear_ind = i2
       3 dilute_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 feasible_ind = i2
       3 alpha_list[*]
         4 action_flag = i2
         4 nomenclature_id = f8
         4 sequence = i4
         4 short_string = c60
         4 default_ind = i2
         4 use_units_ind = i2
         4 reference_ind = i2
         4 result_process_code_value = f8
         4 result_value = f8
         4 multi_alpha_sort_order = i4
         4 truth_state_cd = f8
       3 rule_list[*]
         4 action_flag = i2
         4 ref_range_notify_trig_id = f8
         4 trigger_name = vc
         4 trigger_seq_nbr = i4
       3 species_code_value = f8
       3 adv_deltas[*]
         4 action_flag = i2
         4 delta_ind = i2
         4 delta_low = f8
         4 delta_high = f8
         4 delta_check_type_code_value = f8
         4 delta_minutes = i4
         4 delta_value = f8
       3 delta_check_type_code_value = f8
       3 delta_minutes = i4
       3 delta_value = f8
       3 delta_chk_flag = i2
       3 mins_back = i4
       3 gestational_ind = i2
     2 equivalent_assay[*]
       3 action_flag = i4
       3 code_value = f8
 )
 FREE RECORD ensassayreply
 RECORD ensassayreply(
   1 assay_list[*]
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE add_flag = i4 WITH protect, noconstant(1)
 DECLARE update_flag = i4 WITH protect, noconstant(2)
 DECLARE remove_flag = i4 WITH protect, noconstant(3)
 DECLARE handlereferencerange(aidxv=i4,rrfuid=vc,rrfid=f8,actionflag=i2) = i2
 DECLARE addallalpharesponses(aidxz=i4,ridx=i4,rrfuid=vc) = i2
 DECLARE updateoffsetminutes(actionflag=i2,taskassaycd=f8,numberofminutes=i4,mintypecd=f8) = null
 DECLARE updatereferencetext(taskassayuid=vc,taskassaycd=f8) = null
 DECLARE updatewitnessrequiredind(taskassaycd=f8,witnessrequiredind=i2) = i2
 DECLARE getnomenclatureid(actionflag=i2,aruid=vc,sourcevocabcd=f8,sourceidentifier=vc,sourcestring=
  vc,
  principletypecd=f8,shortstring=vc,mnemonic=vc,contributorsystemcd=f8,conceptcki=vc,
  conceptidentifier=vc,vocabaxiscd=f8) = f8
 DECLARE addnewequation(equationuid=vc,taskassaycd=f8) = i2
 DECLARE removeequation(equationid=f8) = i2
 DECLARE updatenomenidoncnt(aruid=vc,nomenid=f8) = i2
 DECLARE executebedensassay(dummyvar=i2) = f8
 DECLARE generatereferencepk(dummyvar=i2) = f8
 DECLARE generatedcpinterppk(dummyvar=i2) = f8
 DECLARE findcodevalueforuid(cvuid=vc) = f8
 DECLARE addnewinterp(taskassayuid=vc,taskassaycd=f8) = i2
 DECLARE removeinterp(taskassaycd=f8) = i2
 DECLARE insertintoequationcomponent(index=i4) = null
 SUBROUTINE executebedensassay(dummyvar)
   CALL bedlogmessage("executeBedEnsAssay","Entering ...")
   CALL bedaddlogstologgerfile("### Entering executeBedEnsAssay ...")
   DECLARE newlycreatedassaycd = f8 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echorecord(ensassayrequest)
   ENDIF
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensassayrequest))
   EXECUTE bed_ens_assay  WITH replace("REQUEST",ensassayrequest), replace("REPLY",ensassayreply)
   IF ((((ensassayreply->status_data.status != "S")) OR (size(ensassayreply->assay_list,5)=0)) )
    CALL bederror("bed_ens_assay failed.")
   ENDIF
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensassayreply))
   SET newlycreatedassaycd = ensassayreply->assay_list[1].code_value
   CALL bedlogmessage("executeBedEnsAssay","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting executeBedEnsAssay ...")
   RETURN(newlycreatedassaycd)
 END ;Subroutine
 SUBROUTINE handlereferencerange(aidxv,rrfuid,rrfid,actionflag)
   CALL bedlogmessage("handleReferenceRange","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleReferenceRange ...")
   CALL bedaddlogstologgerfile(build2("### Inside handleReferenceRange - aIdxv:",aidxv,"rrfUid:",
     rrfuid," rrfId:",
     rrfid," actionFlag:",actionflag))
   DECLARE r = i4 WITH protect, noconstant(0)
   FREE RECORD rrrec
   RECORD rrrec(
     1 sequence = i4
     1 defvalue = f8
     1 unitscd = f8
     1 unitsuid = vc
     1 fromage = f8
     1 fromagecd = f8
     1 fromageuid = vc
     1 toage = f8
     1 toagecd = f8
     1 toageuid = vc
     1 speciescd = f8
     1 speciesuid = vc
     1 sexcd = f8
     1 sexuid = vc
     1 serviceresourcecd = f8
     1 serviceresourceuid = vc
     1 criticalhigh = f8
     1 criticallow = f8
     1 criticalind = i2
     1 feasiblehigh = f8
     1 feasiblelow = f8
     1 feasibleind = i2
     1 linearhigh = f8
     1 linearlow = f8
     1 linearind = i2
     1 normalhigh = f8
     1 normallow = f8
     1 normalind = i2
     1 reviewhigh = f8
     1 reviewlow = f8
     1 reviewind = i2
     1 diluteind = i2
     1 gestationalind = i2
     1 specimentypecd = f8
     1 specimentypeuid = vc
     1 deltaminutes = i4
     1 deltavalue = f8
     1 deltachecktypecd = f8
     1 deltachecktypeuid = vc
     1 delta_chk_flag = i2
     1 minsback = i4
   )
   SELECT INTO "nl:"
    FROM cnt_rrf_key k,
     cnt_rrf r
    PLAN (k
     WHERE k.rrf_uid=rrfuid)
     JOIN (r
     WHERE r.rrf_uid=k.rrf_uid)
    DETAIL
     rrrec->sequence = k.precedence_sequence, rrrec->defvalue = r.default_result, rrrec->unitscd = r
     .units_cd,
     rrrec->unitsuid = r.units_cduid, rrrec->fromage = k.age_from_minutes, rrrec->fromagecd = k
     .age_from_units_cd,
     rrrec->fromageuid = k.age_from_units_cduid, rrrec->toage = k.age_to_minutes, rrrec->toagecd = k
     .age_to_units_cd,
     rrrec->toageuid = k.age_to_units_cduid, rrrec->speciescd = k.species_cd, rrrec->speciesuid = k
     .species_cduid,
     rrrec->sexcd = k.sex_cd, rrrec->sexuid = k.sex_cduid, rrrec->serviceresourcecd = k
     .service_resource_cd,
     rrrec->serviceresourceuid = k.service_resource_cduid, rrrec->criticalhigh = r.critical_high,
     rrrec->criticallow = r.critical_low,
     rrrec->criticalind = r.critical_ind, rrrec->feasiblehigh = r.feasible_high, rrrec->feasiblelow
      = r.feasible_low,
     rrrec->feasibleind = r.feasible_ind, rrrec->linearhigh = r.linear_high, rrrec->linearlow = r
     .linear_low,
     rrrec->linearind = r.linear_ind, rrrec->normalhigh = r.normal_high, rrrec->normallow = r
     .normal_low,
     rrrec->normalind = r.normal_ind, rrrec->reviewhigh = r.review_high, rrrec->reviewlow = r
     .review_low,
     rrrec->reviewind = r.review_ind, rrrec->diluteind = r.dilute_ind, rrrec->gestationalind = r
     .gestational_ind,
     rrrec->specimentypecd = k.specimen_type_cd, rrrec->specimentypeuid = k.specimen_type_cduid,
     rrrec->deltaminutes = r.delta_minutes,
     rrrec->deltavalue = r.delta_value, rrrec->deltachecktypecd = r.delta_check_type_cd, rrrec->
     deltachecktypeuid = r.delta_check_type_cduid,
     rrrec->delta_chk_flag = r.delta_chk_flag, rrrec->minsback = r.mins_back
    WITH nocounter
   ;end select
   IF ((rrrec->unitscd=0))
    SET rrrec->unitscd = findcodevalueforuid(rrrec->unitsuid)
   ENDIF
   IF ((rrrec->fromagecd=0))
    SET rrrec->fromagecd = findcodevalueforuid(rrrec->fromageuid)
   ENDIF
   IF ((rrrec->toagecd=0))
    SET rrrec->toagecd = findcodevalueforuid(rrrec->toageuid)
   ENDIF
   IF ((rrrec->speciescd=0))
    SET rrrec->speciescd = findcodevalueforuid(rrrec->speciesuid)
   ENDIF
   IF ((rrrec->sexcd=0))
    SET rrrec->sexcd = findcodevalueforuid(rrrec->sexuid)
   ENDIF
   IF ((rrrec->serviceresourcecd=0))
    SET rrrec->serviceresourcecd = findcodevalueforuid(rrrec->serviceresourceuid)
   ENDIF
   IF ((rrrec->specimentypecd=0))
    SET rrrec->specimentypecd = findcodevalueforuid(rrrec->specimentypeuid)
   ENDIF
   IF ((rrrec->deltachecktypecd=0))
    SET rrrec->deltachecktypecd = findcodevalueforuid(rrrec->deltachecktypeuid)
   ENDIF
   CALL bedaddlogstologgerfile(cnvtrectoxml(rrrec))
   SET r = (size(ensassayrequest->assay_list[aidxv].rr_list,5)+ 1)
   SET stat = alterlist(ensassayrequest->assay_list[aidxv].rr_list,r)
   SET ensassayrequest->assay_list[aidxv].rr_list[r].action_flag = actionflag
   SET ensassayrequest->assay_list[aidxv].rr_list[r].rrf_id = rrfid
   SET ensassayrequest->assay_list[aidxv].rr_list[r].sequence = rrrec->sequence
   SET ensassayrequest->assay_list[aidxv].rr_list[r].def_value = rrrec->defvalue
   SET ensassayrequest->assay_list[aidxv].rr_list[r].uom_code_value = rrrec->unitscd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].from_age = rrrec->fromage
   SET ensassayrequest->assay_list[aidxv].rr_list[r].from_age_code_value = rrrec->fromagecd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].to_age = rrrec->toage
   SET ensassayrequest->assay_list[aidxv].rr_list[r].to_age_code_value = rrrec->toagecd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].sex_code_value = rrrec->sexcd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].specimen_type_code_value = rrrec->specimentypecd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].species_code_value = rrrec->speciescd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].service_resource_code_value = rrrec->
   serviceresourcecd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].ref_low = rrrec->normallow
   SET ensassayrequest->assay_list[aidxv].rr_list[r].ref_high = rrrec->normalhigh
   SET ensassayrequest->assay_list[aidxv].rr_list[r].ref_ind = rrrec->normalind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].crit_low = rrrec->criticallow
   SET ensassayrequest->assay_list[aidxv].rr_list[r].crit_high = rrrec->criticalhigh
   SET ensassayrequest->assay_list[aidxv].rr_list[r].crit_ind = rrrec->criticalind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].review_low = rrrec->reviewlow
   SET ensassayrequest->assay_list[aidxv].rr_list[r].review_high = rrrec->reviewhigh
   SET ensassayrequest->assay_list[aidxv].rr_list[r].review_ind = rrrec->reviewind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].linear_low = rrrec->linearlow
   SET ensassayrequest->assay_list[aidxv].rr_list[r].linear_high = rrrec->linearhigh
   SET ensassayrequest->assay_list[aidxv].rr_list[r].linear_ind = rrrec->linearind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].dilute_ind = rrrec->diluteind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].feasible_low = rrrec->feasiblelow
   SET ensassayrequest->assay_list[aidxv].rr_list[r].feasible_high = rrrec->feasiblehigh
   SET ensassayrequest->assay_list[aidxv].rr_list[r].feasible_ind = rrrec->feasibleind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].gestational_ind = rrrec->gestationalind
   SET ensassayrequest->assay_list[aidxv].rr_list[r].delta_minutes = rrrec->deltaminutes
   SET ensassayrequest->assay_list[aidxv].rr_list[r].delta_check_type_code_value = rrrec->
   deltachecktypecd
   SET ensassayrequest->assay_list[aidxv].rr_list[r].delta_value = rrrec->deltavalue
   SET ensassayrequest->assay_list[aidxv].rr_list[r].delta_chk_flag = rrrec->delta_chk_flag
   SET ensassayrequest->assay_list[aidxv].rr_list[r].mins_back = rrrec->minsback
   CALL bedaddlogstologgerfile(cnvtrectoxml(ensassayrequest))
   IF (actionflag=add_flag)
    CALL addallalpharesponses(aidxv,r,rrfuid)
   ENDIF
   CALL bedlogmessage("handleReferenceRange","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleReferenceRange ...")
 END ;Subroutine
 SUBROUTINE addallalpharesponses(aidxz,ridx,rrfuid)
   CALL bedlogmessage("addAllAlphaResponses","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addAllAlphaResponses ...")
   CALL bedaddlogstologgerfile(build2("### Inside addAllAlphaResponses - aIdxz:",aidxz,"rIdx:",ridx,
     " rrfUid:",
     rrfuid))
   DECLARE arcnt = i4 WITH protect, noconstant(0)
   DECLARE a = i4 WITH protect, noconstant(0)
   FREE RECORD arrec
   RECORD arrec(
     1 list[*]
       2 aruid = vc
       2 sequence = i4
       2 resultprocesscd = f8
       2 resultprocessuid = vc
       2 defaultind = i2
       2 useunitsind = i2
       2 referenceind = i2
       2 resultvalue = f8
       2 sortorder = i4
       2 truthstatecd = f8
       2 truthstateuid = vc
       2 nomenclatureid = f8
       2 principletypecd = f8
       2 principletypeuid = vc
       2 sourceidentifier = vc
       2 sourcestring = vc
       2 sourcevocabcd = f8
       2 sourcevocabuid = vc
       2 shortstring = vc
       2 mnemonic = vc
       2 contributorsystemcd = f8
       2 contributorsystemuid = vc
       2 conceptcki = vc
       2 conceptidentifier = vc
       2 vocabaxiscd = f8
       2 vocabaxisuid = vc
   )
   SELECT INTO "nl:"
    FROM cnt_rrf_ar_r arr,
     cnt_alpha_response_key ark,
     cnt_alpha_response ar
    PLAN (arr
     WHERE arr.rrf_uid=rrfuid)
     JOIN (ark
     WHERE ark.ar_uid=arr.ar_uid)
     JOIN (ar
     WHERE ar.ar_uid=ark.ar_uid)
    ORDER BY arr.ar_uid
    HEAD arr.ar_uid
     arcnt = (arcnt+ 1), stat = alterlist(arrec->list,arcnt), arrec->list[arcnt].aruid = arr.ar_uid,
     arrec->list[arcnt].sequence = arr.ar_sequence, arrec->list[arcnt].resultprocesscd = arr
     .result_process_cd, arrec->list[arcnt].resultprocessuid = arr.result_process_cduid,
     arrec->list[arcnt].defaultind = arr.default_ind, arrec->list[arcnt].useunitsind = arr
     .use_units_ind, arrec->list[arcnt].referenceind = arr.reference_ind,
     arrec->list[arcnt].resultvalue = arr.result_value, arrec->list[arcnt].sortorder = arr
     .multi_alpha_sort_order, arrec->list[arcnt].truthstatecd = arr.truth_state_cd,
     arrec->list[arcnt].truthstateuid = arr.truth_state_cduid, arrec->list[arcnt].nomenclatureid =
     ark.nomenclature_id, arrec->list[arcnt].principletypecd = ark.principle_type_cd,
     arrec->list[arcnt].principletypeuid = ark.principle_type_cduid, arrec->list[arcnt].
     sourceidentifier = ark.source_identifier, arrec->list[arcnt].sourcestring = ark.source_string,
     arrec->list[arcnt].sourcevocabcd = ark.source_vocabulary_cd, arrec->list[arcnt].sourcevocabuid
      = ark.source_vocabulary_cduid, arrec->list[arcnt].shortstring = ar.short_string,
     arrec->list[arcnt].mnemonic = ar.mnemonic, arrec->list[arcnt].contributorsystemcd = ar
     .contributor_system_cd, arrec->list[arcnt].contributorsystemuid = ar.contributor_system_cduid,
     arrec->list[arcnt].conceptcki = ar.concept_cki, arrec->list[arcnt].conceptidentifier = ar
     .concept_identifier, arrec->list[arcnt].vocabaxiscd = ar.vocab_axis_cd,
     arrec->list[arcnt].vocabaxisuid = ar.vocab_axis_cduid
    WITH nocounter
   ;end select
   FOR (a = 1 TO arcnt)
     IF ((arrec->list[a].resultprocesscd=0))
      SET arrec->list[a].resultprocesscd = findcodevalueforuid(arrec->list[a].resultprocessuid)
     ENDIF
     IF ((arrec->list[a].principletypecd=0))
      SET arrec->list[a].principletypecd = findcodevalueforuid(arrec->list[a].principletypeuid)
     ENDIF
     IF ((arrec->list[a].sourcevocabcd=0))
      SET arrec->list[a].sourcevocabcd = findcodevalueforuid(arrec->list[a].sourcevocabuid)
     ENDIF
     IF ((arrec->list[a].contributorsystemcd=0))
      SET arrec->list[a].contributorsystemcd = findcodevalueforuid(arrec->list[a].
       contributorsystemuid)
     ENDIF
     IF ((arrec->list[a].vocabaxiscd=0))
      SET arrec->list[a].vocabaxiscd = findcodevalueforuid(arrec->list[a].vocabaxisuid)
     ENDIF
     IF ((arrec->list[a].truthstatecd=0))
      SET arrec->list[a].truthstatecd = findcodevalueforuid(arrec->list[a].truthstateuid)
     ENDIF
     IF ((arrec->list[a].nomenclatureid=0))
      SET arrec->list[a].nomenclatureid = getnomenclatureid(add_flag,arrec->list[a].aruid,arrec->
       list[a].sourcevocabcd,arrec->list[a].sourceidentifier,arrec->list[a].sourcestring,
       arrec->list[a].principletypecd,arrec->list[a].shortstring,arrec->list[a].mnemonic,arrec->list[
       a].contributorsystemcd,arrec->list[a].conceptcki,
       arrec->list[a].conceptidentifier,arrec->list[a].vocabaxiscd)
      CALL updatenomenidoncnt(arrec->list[a].aruid,arrec->list[a].nomenclatureid)
     ENDIF
     CALL bedaddlogstologgerfile(cnvtrectoxml(arrec))
     SET stat = alterlist(ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list,a)
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].action_flag = 1
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].nomenclature_id = arrec->
     list[a].nomenclatureid
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].sequence = arrec->list[a].
     sequence
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].default_ind = arrec->list[a].
     defaultind
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].use_units_ind = arrec->list[a
     ].useunitsind
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].reference_ind = arrec->list[a
     ].referenceind
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].result_process_code_value =
     arrec->list[a].resultprocesscd
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].result_value = arrec->list[a]
     .resultvalue
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].multi_alpha_sort_order =
     arrec->list[a].sortorder
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].short_string = arrec->list[a]
     .shortstring
     SET ensassayrequest->assay_list[aidxz].rr_list[ridx].alpha_list[a].truth_state_cd = arrec->list[
     a].truthstatecd
     CALL bedaddlogstologgerfile(cnvtrectoxml(ensassayrequest))
   ENDFOR
   CALL bedlogmessage("addAllAlphaResponses","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addAllAlphaResponses ...")
 END ;Subroutine
 SUBROUTINE updatewitnessrequiredind(taskassaycd,witnessrequiredind)
   CALL bedlogmessage("updateWitnessRequiredInd","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateWitnessRequiredInd ...")
   CALL bedaddlogstologgerfile(build2("### Inside updateWitnessRequiredInd - taskAssayCd:",
     taskassaycd," witnessRequiredInd:",witnessrequiredind))
   DECLARE newfieldvalue = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=taskassaycd
     AND cve.field_name="dta_witness_required_ind"
    DETAIL
     IF (cve.field_value="1")
      IF (witnessrequiredind=0)
       newfieldvalue = "0"
      ENDIF
     ELSE
      IF (witnessrequiredind > 0)
       newfieldvalue = "1"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside updateWitnessRequiredInd - newFieldValue:",
     newfieldvalue," curqual:",curqual))
   IF (curqual=0)
    IF (witnessrequiredind > 0)
     INSERT  FROM code_value_extension cve
      SET cve.code_value = taskassaycd, cve.field_name = "dta_witness_required_ind", cve.code_set =
       14003,
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve
       .field_type = 0,
       cve.field_value = "1", cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
       cve.updt_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    IF (newfieldvalue != "")
     UPDATE  FROM code_value_extension cve
      SET cve.field_value = newfieldvalue, cve.updt_task = reqinfo->updt_task, cve.updt_cnt = (cve
       .updt_cnt+ 1),
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_id = reqinfo->updt_id, cve.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE cve.code_value=taskassaycd
       AND cve.field_name="dta_witness_required_ind"
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   CALL bedlogmessage("updateWitnessRequiredInd","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateWitnessRequiredInd ...")
 END ;Subroutine
 SUBROUTINE updateoffsetminutes(actionflag,taskassaycd,numberofminutes,mintypecd)
   CALL bedlogmessage("updateOffsetMinutes","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateOffsetMinutes ...")
   CALL bedaddlogstologgerfile(build2("### Inside updateOffsetMinutes - actionFlag:",actionflag,
     " taskAssayCd:",taskassaycd," numberOfMinutes:",
     numberofminutes," minTypeCd:",mintypecd))
   DECLARE dtaoffsetminid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dta_offset_min do
    WHERE do.task_assay_cd=taskassaycd
     AND do.offset_min_type_cd=mintypecd
     AND do.active_ind=true
    DETAIL
     dtaoffsetminid = do.dta_offset_min_id
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside updateOffsetMinutes - dtaOffsetMinId:",
     dtaoffsetminid))
   IF (dtaoffsetminid > 0)
    UPDATE  FROM dta_offset_min dom
     SET dom.active_ind = false, dom.end_effective_dt_tm = cnvtdatetime(curtime,curtime3), dom
      .updt_cnt = (dom.updt_cnt+ 1),
      dom.updt_dt_tm = cnvtdatetime(curdate,curtime3), dom.updt_id = reqinfo->updt_id, dom.updt_task
       = reqinfo->updt_task,
      dom.updt_applctx = reqinfo->updt_applctx
     WHERE dom.dta_offset_min_id=dtaoffsetminid
    ;end update
   ENDIF
   IF (actionflag=add_flag)
    SET dtaoffsetminid = generatereferencepk(0)
    CALL bedaddlogstologgerfile(build2("### Inside updateOffsetMinutes - updated dtaOffsetMinId:",
      dtaoffsetminid))
    INSERT  FROM dta_offset_min dom
     SET dom.dta_offset_min_id = dtaoffsetminid, dom.task_assay_cd = taskassaycd, dom
      .offset_min_type_cd = mintypecd,
      dom.offset_min_nbr = numberofminutes, dom.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      dom.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      dom.active_ind = true, dom.updt_cnt = 0, dom.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dom.updt_id = reqinfo->updt_id, dom.updt_task = reqinfo->updt_task, dom.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   CALL bedlogmessage("updateOffsetMinutes","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateOffsetMinutes ...")
 END ;Subroutine
 SUBROUTINE updatereferencetext(taskassayuid,taskassaycd)
   CALL bedlogmessage("updateReferenceText","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateReferenceText ...")
   FREE RECORD reftextrequest
   RECORD reftextrequest(
     1 taskassayuid = vc
     1 taskassaycd = f8
   )
   FREE RECORD reftextreply
   RECORD reftextreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET reftextrequest->taskassayuid = taskassayuid
   SET reftextrequest->taskassaycd = taskassaycd
   CALL bedaddlogstologgerfile(cnvtrectoxml(reftextrequest))
   EXECUTE bed_reconcile_ref_text  WITH replace("REQUEST",reftextrequest), replace("REPLY",
    reftextreply)
   CALL bedaddlogstologgerfile(cnvtrectoxml(reftextreply))
   IF ((reftextreply->status_data.status != "S"))
    CALL bederror("bed_reconcile_ref_text failed.")
   ENDIF
   CALL bedlogmessage("updateReferenceText","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateReferenceText ...")
 END ;Subroutine
 SUBROUTINE getnomenclatureid(actionflag,aruid,sourcevocabcd,sourceidentifier,sourcestring,
  principletypecd,shortstring,mnemonic,contributorsystemcd,conceptcki,conceptidentifier,vocabaxiscd)
   CALL bedlogmessage("getNomenclatureId","Entering ...")
   CALL bedaddlogstologgerfile("### Entering getNomenclatureId ...")
   CALL bedaddlogstologgerfile(build2("### actionFlag:",actionflag," arUID:",aruid," sourceVocabCd:",
     sourcevocabcd," sourceIdentifier:",sourceidentifier," sourceString:",sourcestring,
     " principleTypeCd:",principletypecd," shortString:",shortstring," mnemonic:",
     mnemonic," contributorSystemCd:",contributorsystemcd," conceptCki:",conceptcki,
     " conceptIdentifier:",conceptidentifier," vocabAxisCd:",vocabaxiscd))
   DECLARE nomenid = f8 WITH protect, noconstant(0)
   SET nomenid = 0
   SELECT INTO "nl:"
    FROM nomenclature n
    PLAN (n
     WHERE n.source_vocabulary_cd=sourcevocabcd
      AND trim(n.source_identifier,3) IN ("", null, trim(n.source_identifier,3))
      AND n.source_string=sourcestring
      AND n.principle_type_cd=principletypecd)
    DETAIL
     nomenid = n.nomenclature_id
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### nomenId:",nomenid))
   IF (actionflag=add_flag
    AND nomenid=0)
    FREE RECORD addnomenfields
    RECORD addnomenfields(
      1 language_cd = f8
      1 language_cduid = vc
      1 concept_source_cd = f8
      1 concept_source_cduid = vc
      1 string_source_cd = f8
      1 string_source_cduid = vc
      1 string_status_cd = f8
      1 string_status_cduid = vc
    )
    SELECT INTO "nl:"
     FROM cnt_alpha_response a
     WHERE a.ar_uid=aruid
     DETAIL
      addnomenfields->language_cd = a.language_cd, addnomenfields->language_cduid = a.language_cduid,
      addnomenfields->concept_source_cd = a.concept_source_cd,
      addnomenfields->concept_source_cduid = a.concept_source_cduid, addnomenfields->string_source_cd
       = a.string_source_cd, addnomenfields->string_source_cduid = a.string_source_cduid,
      addnomenfields->string_status_cd = a.string_status_cd, addnomenfields->string_status_cduid = a
      .string_status_cduid
     WITH nocounter
    ;end select
    IF ((addnomenfields->language_cd=0))
     SET addnomenfields->language_cd = findcodevalueforuid(addnomenfields->language_cduid)
    ENDIF
    IF ((addnomenfields->concept_source_cd=0))
     SET addnomenfields->concept_source_cd = findcodevalueforuid(addnomenfields->concept_source_cduid
      )
    ENDIF
    IF ((addnomenfields->string_source_cd=0))
     SET addnomenfields->string_source_cd = findcodevalueforuid(addnomenfields->string_source_cduid)
    ENDIF
    IF ((addnomenfields->string_status_cd=0))
     SET addnomenfields->string_status_cd = findcodevalueforuid(addnomenfields->string_status_cduid)
    ENDIF
    CALL bedaddlogstologgerfile(cnvtrectoxml(addnomenfields))
    FREE RECORD ensnomenrequest
    RECORD ensnomenrequest(
      1 nomen_list[1]
        2 action_flag = i2
        2 nomenclature_id = f8
        2 source_string = c255
        2 short_string = c60
        2 mnemonic = c25
        2 principle_type_code_value = f8
        2 contributor_system_code_value = f8
        2 language_code_value = f8
        2 source_vocabulary_code_value = f8
        2 source_identifier = vc
        2 concept_identifier = vc
        2 concept_cki = vc
        2 vocab_axis_code_value = f8
        2 concept_source_code_value = f8
    )
    FREE RECORD ensnomenreply
    RECORD ensnomenreply(
      1 nomen_list[*]
        2 nomenclature_id = f8
      1 error_msg = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET ensnomenrequest->nomen_list[1].action_flag = 1
    SET ensnomenrequest->nomen_list[1].source_string = sourcestring
    SET ensnomenrequest->nomen_list[1].short_string = shortstring
    SET ensnomenrequest->nomen_list[1].mnemonic = mnemonic
    SET ensnomenrequest->nomen_list[1].principle_type_code_value = principletypecd
    SET ensnomenrequest->nomen_list[1].contributor_system_code_value = contributorsystemcd
    SET ensnomenrequest->nomen_list[1].source_vocabulary_code_value = sourcevocabcd
    SET ensnomenrequest->nomen_list[1].source_identifier = sourceidentifier
    SET ensnomenrequest->nomen_list[1].concept_identifier = conceptidentifier
    SET ensnomenrequest->nomen_list[1].concept_cki = conceptcki
    SET ensnomenrequest->nomen_list[1].vocab_axis_code_value = vocabaxiscd
    SET ensnomenrequest->nomen_list[1].language_code_value = addnomenfields->language_cd
    SET ensnomenrequest->nomen_list[1].concept_source_code_value = addnomenfields->concept_source_cd
    CALL bedaddlogstologgerfile(cnvtrectoxml(ensnomenrequest))
    EXECUTE bed_ens_nomen  WITH replace("REQUEST",ensnomenrequest), replace("REPLY",ensnomenreply)
    CALL bedaddlogstologgerfile(cnvtrectoxml(ensnomenreply))
    IF ((((ensnomenreply->status_data.status="F")) OR (size(ensnomenreply->nomen_list,5)=0)) )
     CALL bederror("bed_ens_nomen failed.")
    ENDIF
    SET nomenid = ensnomenreply->nomen_list[1].nomenclature_id
    IF ((((addnomenfields->string_source_cd > 0)) OR ((addnomenfields->string_status_cd > 0))) )
     UPDATE  FROM nomenclature n
      SET n.string_source_cd = addnomenfields->string_source_cd, n.string_status_cd = addnomenfields
       ->string_status_cd, n.updt_cnt = 0,
       n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
       reqinfo->updt_task,
       n.updt_applctx = reqinfo->updt_applctx
      WHERE n.nomenclature_id=nomenid
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   CALL bedlogmessage("getNomenclatureId","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting getNomenclatureId ...")
   RETURN(nomenid)
 END ;Subroutine
 SUBROUTINE addnewequation(equationuid,taskassaycd)
   CALL bedlogmessage("addNewEquation","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addNewEquation ...")
   DECLARE eccnt = i4 WITH protect, noconstant(0)
   DECLARE newequationid = f8 WITH protect, noconstant(0)
   FREE RECORD equationrec
   RECORD equationrec(
     1 service_resource_cd = f8
     1 unknown_age_ind = i2
     1 age_from_units_cd = f8
     1 age_from_minutes = i4
     1 age_to_units_cd = f8
     1 age_to_minutes = i4
     1 sex_cd = f8
     1 species_cd = f8
     1 equation_description = vc
     1 equation_postfix = vc
     1 default_ind = i2
     1 script = vc
     1 gestational_age_ind = i2
     1 comp[*]
       2 result_status_cd = f8
       2 age_ind = i2
       2 sequence = i4
       2 included_assay_cd = f8
       2 name = vc
       2 default_value = f8
       2 cross_drawn_dt_tm_ind = i2
       2 time_window_minutes = i4
       2 time_window_back_minutes = i4
       2 variable_prompt = vc
       2 constant_value = f8
       2 component_flag = i2
       2 units_cd = f8
       2 octal_value = f8
       2 race_ind = i2
       2 result_req_flag = i2
       2 sex_ind = i2
       2 look_time_direction_flag = i2
   )
   SELECT INTO "nl:"
    FROM cnt_equation e,
     cnt_code_value_key c1,
     cnt_code_value_key c2,
     cnt_code_value_key c3,
     cnt_code_value_key c4,
     cnt_equation_component ec,
     cnt_code_value_key c5,
     cnt_code_value_key c6,
     cnt_dta_key2 dk,
     cnt_dta ca,
     discrete_task_assay dta
    PLAN (e
     WHERE e.equation_uid=equationuid)
     JOIN (c1
     WHERE c1.code_value_uid=outerjoin(e.age_to_units_cduid))
     JOIN (c2
     WHERE c2.code_value_uid=outerjoin(e.age_from_units_cduid))
     JOIN (c3
     WHERE c3.code_value_uid=outerjoin(e.sex_cduid))
     JOIN (c4
     WHERE c4.code_value_uid=outerjoin(e.species_cduid))
     JOIN (ec
     WHERE ec.equation_uid=e.equation_uid)
     JOIN (c5
     WHERE c5.code_value_uid=outerjoin(ec.result_status_cduid))
     JOIN (c6
     WHERE c6.code_value_uid=outerjoin(ec.units_cduid))
     JOIN (dk
     WHERE dk.task_assay_uid=outerjoin(ec.included_assay_uid))
     JOIN (ca
     WHERE ca.task_assay_uid=outerjoin(dk.task_assay_uid))
     JOIN (dta
     WHERE dta.mnemonic_key_cap=outerjoin(ca.mnemonic_key_cap)
      AND dta.activity_type_cd=outerjoin(ca.activity_type_cd)
      AND dta.active_ind=outerjoin(ca.active_ind))
    ORDER BY e.equation_uid, ec.component_sequence
    HEAD e.equation_uid
     equationrec->service_resource_cd = e.service_resource_cd, equationrec->unknown_age_ind = e
     .unknown_age_ind
     IF (e.age_from_units_cd > 0)
      equationrec->age_from_units_cd = e.age_from_units_cd
     ELSE
      equationrec->age_from_units_cd = c1.code_value
     ENDIF
     equationrec->age_from_minutes = e.age_from_minutes
     IF (e.age_to_units_cd > 0)
      equationrec->age_to_units_cd = e.age_to_units_cd
     ELSE
      equationrec->age_to_units_cd = c2.code_value
     ENDIF
     equationrec->age_to_minutes = e.age_to_minutes
     IF (e.sex_cd > 0)
      equationrec->sex_cd = e.sex_cd
     ELSE
      equationrec->sex_cd = c3.code_value
     ENDIF
     IF (e.species_cd > 0)
      equationrec->species_cd = e.species_cd
     ELSE
      equationrec->species_cd = c4.code_value
     ENDIF
     equationrec->equation_description = e.equation_descripton, equationrec->equation_postfix = e
     .equation_postfix, equationrec->default_ind = e.default_ind,
     equationrec->script = e.script_name, equationrec->gestational_age_ind = e.gestational_age_ind
    HEAD ec.component_sequence
     eccnt = (eccnt+ 1), stat = alterlist(equationrec->comp,eccnt)
     IF (ec.result_status_cd > 0)
      equationrec->comp[eccnt].result_status_cd = ec.result_status_cd
     ELSE
      equationrec->comp[eccnt].result_status_cd = c5.code_value
     ENDIF
     equationrec->comp[eccnt].age_ind = ec.age_ind, equationrec->comp[eccnt].sequence = ec
     .component_sequence, equationrec->comp[eccnt].included_assay_cd = dta.task_assay_cd,
     equationrec->comp[eccnt].name = ec.component_name, equationrec->comp[eccnt].default_value = ec
     .default_value, equationrec->comp[eccnt].cross_drawn_dt_tm_ind = ec.cross_drawn_dt_tm_ind,
     equationrec->comp[eccnt].time_window_minutes = ec.time_window_minutes, equationrec->comp[eccnt].
     time_window_back_minutes = ec.time_window_back_minutes, equationrec->comp[eccnt].variable_prompt
      = ec.variable_prompt,
     equationrec->comp[eccnt].constant_value = ec.constant_value, equationrec->comp[eccnt].
     component_flag = ec.component_flag
     IF (ec.units_cd > 0)
      equationrec->comp[eccnt].units_cd = ec.units_cd
     ELSE
      equationrec->comp[eccnt].units_cd = c6.code_value
     ENDIF
     equationrec->comp[eccnt].octal_value = ec.octal_value, equationrec->comp[eccnt].race_ind = ec
     .race_ind, equationrec->comp[eccnt].result_req_flag = ec.result_req_flag,
     equationrec->comp[eccnt].sex_ind = ec.sex_ind, equationrec->comp[eccnt].look_time_direction_flag
      = ec.look_time_direction_flag
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(equationrec))
   IF (curqual > 0)
    SET newequationid = generatereferencepk(0)
    INSERT  FROM equation e
     SET e.equation_id = newequationid, e.service_resource_cd = equationrec->service_resource_cd, e
      .task_assay_cd = taskassaycd,
      e.unknown_age_ind = equationrec->unknown_age_ind, e.age_from_units_cd = equationrec->
      age_from_units_cd, e.age_from_minutes = equationrec->age_from_minutes,
      e.age_to_units_cd = equationrec->age_to_units_cd, e.age_to_minutes = equationrec->
      age_to_minutes, e.sex_cd = equationrec->sex_cd,
      e.species_cd = equationrec->species_cd, e.equation_description = equationrec->
      equation_description, e.equation_postfix = equationrec->equation_postfix,
      e.active_dt_tm = cnvtdatetime(curdate,curtime3), e.inactive_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00"), e.default_ind = equationrec->default_ind,
      e.active_ind = 1, e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task,
      e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
      .updt_cnt = 0,
      e.script = equationrec->script, e.gestational_age_ind = equationrec->gestational_age_ind
     WITH nocounter
    ;end insert
    UPDATE  FROM cnt_equation ce
     SET ce.equation_id = newequationid, ce.updt_id = reqinfo->updt_id, ce.updt_task = reqinfo->
      updt_task,
      ce.updt_applctx = reqinfo->updt_applctx, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce
      .updt_cnt = 0
     WHERE ce.equation_uid=equationuid
     WITH nocounter
    ;end update
    FOR (qq = 1 TO size(equationrec->comp,5))
      CALL insertintoequationcomponent(qq)
    ENDFOR
   ENDIF
   CALL bedlogmessage("addNewEquation","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addNewEquation ...")
 END ;Subroutine
 SUBROUTINE insertintoequationcomponent(index)
   INSERT  FROM equation_component ec
    SET ec.equation_id = newequationid, ec.age_ind = equationrec->comp[index].age_ind, ec.sequence =
     equationrec->comp[index].sequence,
     ec.result_status_cd = equationrec->comp[index].result_status_cd, ec.included_assay_cd =
     equationrec->comp[index].included_assay_cd, ec.name = equationrec->comp[index].name,
     ec.default_value = equationrec->comp[index].default_value, ec.cross_drawn_dt_tm_ind =
     equationrec->comp[index].cross_drawn_dt_tm_ind, ec.time_window_minutes = equationrec->comp[index
     ].time_window_minutes,
     ec.time_window_back_minutes = equationrec->comp[index].time_window_back_minutes, ec
     .result_req_flag = equationrec->comp[index].result_req_flag, ec.variable_prompt = equationrec->
     comp[index].variable_prompt,
     ec.constant_value = equationrec->comp[index].constant_value, ec.component_flag = equationrec->
     comp[index].component_flag, ec.units_cd = equationrec->comp[index].units_cd,
     ec.octal_value = equationrec->comp[index].octal_value, ec.race_ind = equationrec->comp[index].
     race_ind, ec.sex_ind = equationrec->comp[index].sex_ind,
     ec.look_time_direction_flag = equationrec->comp[index].look_time_direction_flag, ec.updt_id =
     reqinfo->updt_id, ec.updt_task = reqinfo->updt_task,
     ec.updt_applctx = reqinfo->updt_applctx, ec.updt_dt_tm = cnvtdatetime(curdate,curtime3), ec
     .updt_cnt = 0
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE removeequation(equationid)
   CALL bedlogmessage("removeEquation","Entering ...")
   CALL bedaddlogstologgerfile("### Entering removeEquation ...")
   DELETE  FROM equation_component ec
    WHERE ec.equation_id=equationid
    WITH nocounter
   ;end delete
   DELETE  FROM equation e
    WHERE e.equation_id=equationid
    WITH nocounter
   ;end delete
   CALL bedaddlogstologgerfile(build2("### Deleted Equation:",equationid))
   CALL bedlogmessage("removeEquation","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting removeEquation ...")
 END ;Subroutine
 SUBROUTINE updatenomenidoncnt(aruid,nomenid)
   CALL bedlogmessage("updateNomenIdOnCnt","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateNomenIdOnCnt ...")
   CALL bedaddlogstologgerfile(build2("### arUID:",aruid," nomenId:",nomenid))
   UPDATE  FROM cnt_alpha_response_key k
    SET k.nomenclature_id = nomenid, k.updt_id = reqinfo->updt_id, k.updt_task = reqinfo->updt_task,
     k.updt_applctx = reqinfo->updt_applctx, k.updt_dt_tm = cnvtdatetime(curdate,curtime3), k
     .updt_cnt = (k.updt_cnt+ 1)
    WHERE k.ar_uid=aruid
    WITH nocounter
   ;end update
   CALL bedaddlogstologgerfile("### Exiting updateNomenIdOnCnt ...")
   CALL bedlogmessage("updateNomenIdOnCnt","Exiting ...")
 END ;Subroutine
 SUBROUTINE findcodevalueforuid(cvuid)
   CALL bedlogmessage("findCodeValueForUID","Entering ...")
   CALL bedaddlogstologgerfile("### Entering findCodeValueForUID ...")
   CALL bedaddlogstologgerfile(build2("### cvUID:",cvuid))
   DECLARE cdvalue = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cnt_code_value_key k
    WHERE k.code_value_uid=cvuid
    DETAIL
     cdvalue = k.code_value
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echo(build2("Code value UID:",cvuid))
    CALL echo(build2("Code value:",cdvalue))
   ENDIF
   CALL bedaddlogstologgerfile(build2("### cdValue:",cdvalue))
   CALL bedaddlogstologgerfile("### Exiting findCodeValueForUID ...")
   CALL bedlogmessage("findCodeValueForUID","Exiting ...")
   RETURN(cdvalue)
 END ;Subroutine
 SUBROUTINE generatereferencepk(dummyvar)
   DECLARE pkid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     pkid = cnvtreal(nextseqnum)
    WITH format, counter
   ;end select
   RETURN(pkid)
 END ;Subroutine
 SUBROUTINE generatedcpinterppk(dummyvar)
   DECLARE pkid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    nextseqnum = seq(dcp_interp_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     pkid = cnvtreal(nextseqnum)
    WITH format, counter
   ;end select
   RETURN(pkid)
 END ;Subroutine
 SUBROUTINE addnewinterp(taskassayuid,taskassaycd)
   CALL bedlogmessage("addNewInterp","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addNewInterp ...")
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE iccnt = i4 WITH protect, noconstant(0)
   DECLARE scnt = i4 WITH protect, noconstant(0)
   DECLARE compassayexists = i2 WITH protect, noconstant(true)
   DECLARE dcpinterpid = f8 WITH protect, noconstant(0)
   DECLARE dcpinterpcomponentid = f8 WITH protect, noconstant(0)
   DECLARE dcpinterpstateid = f8 WITH protect, noconstant(0)
   DECLARE icindex = i4 WITH protect, noconstant(0)
   DECLARE iindex = i4 WITH protect, noconstant(0)
   FREE RECORD interprec
   RECORD interprec(
     1 list[*]
       2 dcpinterpuid = vc
       2 agefromminutes = i4
       2 agetominutes = i4
       2 sexcd = f8
       2 component[*]
         3 componentassaycd = f8
         3 componentsequence = i4
         3 componentdescription = vc
         3 componentflags = i4
       2 state[*]
         3 inputassaycd = f8
         3 state = i4
         3 numericlow = f8
         3 numerichigh = f8
         3 flags = i4
         3 resultvalue = f8
         3 aruid = vc
         3 nomenclatureid = f8
         3 resultingstate = i4
         3 resultnomenid = f8
         3 resultaruid = vc
   )
   SELECT INTO "nl:"
    FROM cnt_dcp_interp2 i,
     cnt_dcp_interp_component ic,
     cnt_dta_key2 d,
     cnt_dta cd,
     discrete_task_assay dta
    PLAN (i
     WHERE i.task_assay_uid=taskassayuid)
     JOIN (ic
     WHERE ic.dcp_interp_uid=i.dcp_interp_uid)
     JOIN (d
     WHERE d.task_assay_uid=ic.component_assay_uid)
     JOIN (cd
     WHERE cd.task_assay_uid=d.task_assay_uid)
     JOIN (dta
     WHERE dta.mnemonic_key_cap=cd.mnemonic_key_cap
      AND dta.activity_type_cd=cd.activity_type_cd
      AND dta.active_ind=1)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET compassayexists = false
   ENDIF
   CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - Are all comp assays exists:",
     compassayexists))
   IF ( NOT (compassayexists))
    CALL echo("********************")
    CALL echo("Not all interp component assays exist in millennium")
    CALL echo("********************")
   ELSE
    SELECT INTO "nl:"
     FROM cnt_dcp_interp2 i,
      cnt_dcp_interp_component ic,
      cnt_dta_key2 d,
      cnt_dta cd,
      cnt_code_value_key ck,
      discrete_task_assay dta
     PLAN (i
      WHERE i.task_assay_uid=taskassayuid)
      JOIN (ic
      WHERE ic.dcp_interp_uid=i.dcp_interp_uid)
      JOIN (d
      WHERE d.task_assay_uid=ic.component_assay_uid)
      JOIN (cd
      WHERE cd.task_assay_uid=d.task_assay_uid)
      JOIN (ck
      WHERE ck.code_value_uid=outerjoin(i.sex_cduid))
      JOIN (dta
      WHERE dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
       AND dta.activity_type_cd=outerjoin(cd.activity_type_cd)
       AND dta.active_ind=outerjoin(1))
     ORDER BY i.dcp_interp_uid, ic.component_sequence
     HEAD i.dcp_interp_uid
      icnt = (icnt+ 1), stat = alterlist(interprec->list,icnt), interprec->list[icnt].dcpinterpuid =
      i.dcp_interp_uid,
      interprec->list[icnt].agefromminutes = i.age_from_minutes, interprec->list[icnt].agetominutes
       = i.age_to_minutes
      IF (i.sex_cd > 0)
       interprec->list[icnt].sexcd = i.sex_cd
      ELSEIF (ck.code_value > 0)
       interprec->list[icnt].sexcd = ck.code_value
      ENDIF
      iccnt = 0
     HEAD ic.component_sequence
      iccnt = (iccnt+ 1), stat = alterlist(interprec->list[icnt].component,iccnt)
      IF (d.task_assay_cd > 0)
       interprec->list[icnt].component[iccnt].componentassaycd = d.task_assay_cd
      ELSE
       interprec->list[icnt].component[iccnt].componentassaycd = dta.task_assay_cd
      ENDIF
      interprec->list[icnt].component[iccnt].componentsequence = ic.component_sequence, interprec->
      list[icnt].component[iccnt].componentdescription = ic.description, interprec->list[icnt].
      component[iccnt].componentflags = ic.flags
     WITH nocounter
    ;end select
    IF (icnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = icnt),
       cnt_dcp_interp_state s,
       cnt_dta_key2 d,
       cnt_dta cd,
       discrete_task_assay dta,
       cnt_alpha_response_key k1,
       cnt_alpha_response_key k2
      PLAN (d1)
       JOIN (s
       WHERE (s.dcp_interp_uid=interprec->list[d1.seq].dcpinterpuid))
       JOIN (k1
       WHERE k1.ar_uid=outerjoin(s.ar_uid))
       JOIN (k2
       WHERE k2.ar_uid=outerjoin(s.result_ar_uid))
       JOIN (d
       WHERE d.task_assay_uid=outerjoin(s.input_assay_uid))
       JOIN (cd
       WHERE cd.task_assay_uid=outerjoin(d.task_assay_uid))
       JOIN (dta
       WHERE dta.mnemonic_key_cap=outerjoin(cd.mnemonic_key_cap)
        AND dta.activity_type_cd=outerjoin(cd.activity_type_cd)
        AND dta.active_ind=outerjoin(1))
      ORDER BY s.dcp_interp_uid, s.cnt_dcp_interp_state_id
      HEAD s.dcp_interp_uid
       scnt = 0
      HEAD s.cnt_dcp_interp_state_id
       scnt = (scnt+ 1), stat = alterlist(interprec->list[d1.seq].state,scnt)
       IF (d.task_assay_cd > 0)
        interprec->list[d1.seq].state[scnt].inputassaycd = d.task_assay_cd
       ELSE
        interprec->list[d1.seq].state[scnt].inputassaycd = dta.task_assay_cd
       ENDIF
       interprec->list[d1.seq].state[scnt].state = s.interp_state, interprec->list[d1.seq].state[scnt
       ].numericlow = s.numeric_low, interprec->list[d1.seq].state[scnt].numerichigh = s.numeric_high,
       interprec->list[d1.seq].state[scnt].aruid = s.ar_uid
       IF (s.flags=0)
        IF (s.nomenclature_id > 0)
         interprec->list[d1.seq].state[scnt].nomenclatureid = s.nomenclature_id
        ELSEIF (k1.nomenclature_id > 0)
         interprec->list[d1.seq].state[scnt].nomenclatureid = k1.nomenclature_id
        ENDIF
       ENDIF
       interprec->list[d1.seq].state[scnt].resultingstate = s.resulting_state, interprec->list[d1.seq
       ].state[scnt].resultaruid = s.result_ar_uid
       IF (s.result_nomenclature_id > 0)
        interprec->list[d1.seq].state[scnt].resultnomenid = s.result_nomenclature_id
       ELSEIF (k2.nomenclature_id > 0)
        interprec->list[d1.seq].state[scnt].resultnomenid = k2.nomenclature_id
       ENDIF
       interprec->list[d1.seq].state[scnt].flags = s.flags, interprec->list[d1.seq].state[scnt].
       resultvalue = s.result_value
      WITH nocounter
     ;end select
    ENDIF
    IF (validate(debug,0)=1)
     CALL echo(build2("Inserting interp for assay (cd/uid):",taskassaycd,taskassayuid))
     CALL echorecord(interprec)
    ENDIF
    CALL bedaddlogstologgerfile(build2("Inserting interp for assay (cd/uid):",taskassaycd,
      taskassayuid))
    CALL bedaddlogstologgerfile(cnvtrectoxml(interprec))
    FOR (iindex = 1 TO icnt)
      SET dcpinterpid = generatedcpinterppk(0)
      CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - dcpInterpId:",dcpinterpid))
      INSERT  FROM dcp_interp i
       SET i.dcp_interp_id = dcpinterpid, i.task_assay_cd = taskassaycd, i.sex_cd = interprec->list[
        iindex].sexcd,
        i.age_from_minutes = interprec->list[iindex].agefromminutes, i.age_to_minutes = interprec->
        list[iindex].agetominutes, i.updt_cnt = 0,
        i.updt_applctx = reqinfo->updt_applctx, i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i
        .updt_id = reqinfo->updt_id,
        i.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      FOR (icindex = 1 TO size(interprec->list[iindex].component,5))
        SET dcpinterpcomponentid = generatedcpinterppk(0)
        CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - dcpInterpComponentId:",
          dcpinterpcomponentid))
        INSERT  FROM dcp_interp_component c
         SET c.dcp_interp_component_id = dcpinterpcomponentid, c.dcp_interp_id = dcpinterpid, c
          .component_assay_cd = interprec->list[iindex].component[icindex].componentassaycd,
          c.component_sequence = interprec->list[iindex].component[icindex].componentsequence, c
          .description = interprec->list[iindex].component[icindex].componentdescription, c.flags =
          interprec->list[iindex].component[icindex].componentflags,
          c.look_back_minutes = 0, c.look_ahead_minutes = 0, c.look_time_direction_flag = 0,
          c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
          reqinfo->updt_task,
          c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
      FOR (sindex = 1 TO size(interprec->list[iindex].state,5))
        IF ((interprec->list[iindex].state[sindex].nomenclatureid=0))
         SELECT INTO "nl:"
          FROM cnt_alpha_response_key ak,
           cnt_code_value_key c1,
           cnt_code_value_key c2,
           nomenclature n
          PLAN (ak
           WHERE (ak.ar_uid=interprec->list[iindex].state[sindex].aruid))
           JOIN (c1
           WHERE c1.code_value_uid=ak.source_vocabulary_cduid)
           JOIN (c2
           WHERE c2.code_value_uid=ak.principle_type_cduid)
           JOIN (n
           WHERE n.source_vocabulary_cd=c1.code_value
            AND n.source_identifier=ak.source_identifier
            AND n.source_string=ak.source_string
            AND n.principle_type_cd=c2.code_value)
          DETAIL
           interprec->list[iindex].state[sindex].nomenclatureid = n.nomenclature_id
          WITH nocounter
         ;end select
        ENDIF
        CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - nomenclatureId:",interprec->
          list[iindex].state[sindex].nomenclatureid))
        IF ((interprec->list[iindex].state[sindex].resultnomenid=0))
         SELECT INTO "nl:"
          FROM cnt_alpha_response_key ak,
           cnt_code_value_key c1,
           cnt_code_value_key c2,
           nomenclature n
          PLAN (ak
           WHERE (ak.ar_uid=interprec->list[iindex].state[sindex].resultaruid))
           JOIN (c1
           WHERE c1.code_value_uid=ak.source_vocabulary_cduid)
           JOIN (c2
           WHERE c2.code_value_uid=ak.principle_type_cduid)
           JOIN (n
           WHERE n.source_vocabulary_cd=c1.code_value
            AND n.source_identifier=ak.source_identifier
            AND n.source_string=ak.source_string
            AND n.principle_type_cd=c2.code_value)
          DETAIL
           interprec->list[iindex].state[sindex].resultnomenid = n.nomenclature_id
          WITH nocounter
         ;end select
        ENDIF
        CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - resultNomenId:",interprec->
          list[iindex].state[sindex].resultnomenid))
        SET dcpinterpstateid = generatedcpinterppk(0)
        CALL bedaddlogstologgerfile(build2("### Inside addNewInterp - dcpInterpStateId:",
          dcpinterpstateid))
        INSERT  FROM dcp_interp_state s
         SET s.dcp_interp_state_id = dcpinterpstateid, s.dcp_interp_id = dcpinterpid, s
          .input_assay_cd = interprec->list[iindex].state[sindex].inputassaycd,
          s.state = interprec->list[iindex].state[sindex].state, s.flags = interprec->list[iindex].
          state[sindex].flags, s.result_value = interprec->list[iindex].state[sindex].resultvalue,
          s.numeric_low = interprec->list[iindex].state[sindex].numericlow, s.numeric_high =
          interprec->list[iindex].state[sindex].numerichigh, s.nomenclature_id = interprec->list[
          iindex].state[sindex].nomenclatureid,
          s.resulting_state = interprec->list[iindex].state[sindex].resultingstate, s
          .result_nomenclature_id = interprec->list[iindex].state[sindex].resultnomenid, s.updt_dt_tm
           = cnvtdatetime(curdate,curtime3),
          s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_cnt = 0,
          s.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
    ENDFOR
   ENDIF
   CALL bedlogmessage("addNewInterp","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addNewInterp ...")
 END ;Subroutine
 SUBROUTINE removeinterp(taskassaycd)
   CALL bedlogmessage("removeInterp","Entering ...")
   CALL bedaddlogstologgerfile("### Entering removeInterp ...")
   DECLARE delcnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   FREE RECORD interptodel
   RECORD interptodel(
     1 list[*]
       2 dcpinterpid = f8
   )
   SELECT INTO "nl:"
    FROM dcp_interp i
    WHERE i.task_assay_cd=taskassaycd
    DETAIL
     delcnt = (delcnt+ 1), stat = alterlist(interptodel->list,delcnt), interptodel->list[delcnt].
     dcpinterpid = i.dcp_interp_id
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(interptodel))
   CALL bedaddlogstologgerfile(build2("### delCnt:",delcnt))
   IF (delcnt > 0)
    FOR (i = 1 TO delcnt)
     DELETE  FROM dcp_interp_component c
      WHERE (c.dcp_interp_id=interptodel->list[i].dcpinterpid)
      WITH nocounter
     ;end delete
     DELETE  FROM dcp_interp_state s
      WHERE (s.dcp_interp_id=interptodel->list[i].dcpinterpid)
      WITH nocounter
     ;end delete
    ENDFOR
    DELETE  FROM dcp_interp i
     WHERE i.task_assay_cd=taskassaycd
     WITH nocounter
    ;end delete
   ENDIF
   CALL bedlogmessage("removeInterp","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting removeInterp ...")
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE assay_cnt = i4 WITH protect, noconstant(size(request->assays,5))
 DECLARE contentmatchind = i2 WITH protect, constant(validate(request->content_match_ind,0))
 DECLARE xx = i4 WITH protect, noconstant(0)
 DECLARE ascnt = i4 WITH protect, noconstant(0)
 DECLARE updateinputpreferencefornewassays(taskassayuid=vc) = i2
 DECLARE matchassay(taskassaycd=f8,taskassayuid=vc) = i2
 DECLARE addassay(taskassayuid=vc,cansaveinterps=i2,assaydesc=vc) = f8
 DECLARE addevent(eventcduid=vc,taskassaycd=f8) = f8
 DECLARE sortassaysbeforesaving(dummyvar=i2) = i2
 DECLARE addintersectingeventcodes(sectionuid=vc) = i2
 IF (assay_cnt > 0)
  CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_PWRFORM_ASSAY.PRG ####")
  CALL bedaddlogstologgerfile(cnvtrectoxml(request))
  CALL sortassaysbeforesaving(0)
  SET assay_cnt = size(assaystosave->assays,5)
  FOR (xx = 1 TO assay_cnt)
    IF ((assaystosave->assays[xx].task_assay_cd > 0))
     CALL matchassay(assaystosave->assays[xx].task_assay_cd,assaystosave->assays[xx].task_assay_uid)
    ENDIF
  ENDFOR
  IF (contentmatchind=0)
   FOR (xx = 1 TO assay_cnt)
     IF ((assaystosave->assays[xx].assay_action_flag=1))
      CALL addassay(assaystosave->assays[xx].task_assay_uid,assaystosave->assays[xx].save_interps,
       assaystosave->assays[xx].description)
      CALL updateinputpreferencefornewassays(assaystosave->assays[xx].task_assay_uid)
     ENDIF
   ENDFOR
   CALL addintersectingeventcodes(request->section_uid)
  ENDIF
  IF (validate(request->powerformorsectionname)
   AND validate(request->cclloggingind))
   CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
   CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_PWRFORM_ASSAY.PRG ####")
   CALL writelogstothefile(request->powerformorsectionname,request->cclloggingind)
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE matchassay(taskassaycd,taskassayuid)
   CALL bedlogmessage("matchAssay ","Entering ...")
   CALL bedaddlogstologgerfile("### Entering matchAssay ...")
   UPDATE  FROM cnt_dta_key2 dk
    SET dk.task_assay_cd = taskassaycd, dk.updt_cnt = (dk.updt_cnt+ 1), dk.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     dk.updt_id = reqinfo->updt_id, dk.updt_task = reqinfo->updt_task, dk.updt_applctx = reqinfo->
     updt_applctx
    PLAN (dk
     WHERE dk.task_assay_uid=taskassayuid)
    WITH nocounter
   ;end update
   CALL bedaddlogstologgerfile(build2("### Inside matchAssay - Assay UID:",taskassayuid,
     ", taskAssayCd:",taskassaycd))
   CALL bedlogmessage("matchAssay ","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting matchAssay ...")
 END ;Subroutine
 SUBROUTINE addintersectingeventcodes(sectionuid)
   CALL bedlogmessage("addIntersectingEventCodes","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addIntersectingEventCodes ...")
   DECLARE gcnt = i4 WITH protect, noconstant(0)
   DECLARE ugsize = i4 WITH protect, constant(size(ultragridassays->list,5))
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE num1 = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   CALL bedaddlogstologgerfile(build2("### Inside addIntersectingEventCodes - ugSize:",ugsize))
   IF (ugsize > 0)
    FREE RECORD grideventcodes
    RECORD grideventcodes(
      1 list[*]
        2 col_dta_cd = f8
        2 row_dta_cd = f8
        2 event_cd = f8
        2 event_uid = vc
        2 event_display = vc
    )
    SELECT INTO "nl:"
     FROM cnt_input_key i,
      cnt_grid g,
      cnt_dta_key2 d1,
      cnt_dta_key2 d2,
      cnt_code_value_key cv
     PLAN (i
      WHERE i.section_uid=sectionuid
       AND i.input_type=19)
      JOIN (g
      WHERE g.cnt_input_key_id=i.cnt_input_key_id)
      JOIN (d1
      WHERE d1.task_assay_uid=g.col_task_assay_uid)
      JOIN (d2
      WHERE d2.task_assay_uid=g.row_task_assay_uid)
      JOIN (cv
      WHERE cv.code_value_uid=g.int_event_cduid)
     ORDER BY g.cnt_grid_id
     HEAD g.cnt_grid_id
      gcnt = (gcnt+ 1), stat = alterlist(grideventcodes->list,gcnt), grideventcodes->list[gcnt].
      col_dta_cd = d1.task_assay_cd,
      grideventcodes->list[gcnt].row_dta_cd = d2.task_assay_cd
      IF (g.int_event_cd > 0)
       grideventcodes->list[gcnt].event_cd = g.int_event_cd
      ELSE
       grideventcodes->list[gcnt].event_cd = cv.code_value
      ENDIF
      grideventcodes->list[gcnt].event_display = cv.display, grideventcodes->list[gcnt].event_uid = g
      .int_event_cduid
     WITH nocounter
    ;end select
    CALL bedaddlogstologgerfile(cnvtrectoxml(grideventcodes))
    FOR (k = 1 TO gcnt)
      SET num = 1
      SET num1 = 1
      IF (((locateval(num,1,ugsize,grideventcodes->list[k].col_dta_cd,ultragridassays->list[num].
       dtacd) > 0) OR (locateval(num1,1,ugsize,grideventcodes->list[k].row_dta_cd,ultragridassays->
       list[num].dtacd) > 0)) )
       IF ((grideventcodes->list[k].event_cd=0))
        SET grideventcodes->list[k].event_cd = addevent(grideventcodes->list[k].event_uid,0.0)
       ENDIF
       SELECT INTO "nl:"
        FROM code_value_event_r r
        WHERE (r.parent_cd=grideventcodes->list[k].col_dta_cd)
         AND (r.flex1_cd=grideventcodes->list[k].row_dta_cd)
         AND (r.event_cd=grideventcodes->list[k].event_cd)
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL bedaddlogstologgerfile(build2(
          "### Inside addIntersectingEventCodes - Inserting into code_value_event_r:",
          " gridEventCodes->list[k].event_cd:",grideventcodes->list[k].event_cd,
          " gridEventCodes->list[k].col_dta_cd:",grideventcodes->list[k].col_dta_cd,
          " gridEventCodes->list[k].row_dta_cd:",grideventcodes->list[k].row_dta_cd))
        INSERT  FROM code_value_event_r cer
         SET cer.event_cd = grideventcodes->list[k].event_cd, cer.parent_cd = grideventcodes->list[k]
          .col_dta_cd, cer.flex1_cd = grideventcodes->list[k].row_dta_cd,
          cer.flex2_cd = 0, cer.flex3_cd = 0, cer.flex4_cd = 0,
          cer.flex5_cd = 0, cer.updt_id = reqinfo->updt_id, cer.updt_task = reqinfo->updt_task,
          cer.updt_applctx = reqinfo->updt_applctx, cer.updt_dt_tm = cnvtdatetime(curdate,curtime3)
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL bedlogmessage("addIntersectingEventCodes","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addIntersectingEventCodes ...")
 END ;Subroutine
 SUBROUTINE updateinputpreferencefornewassays(taskassayuid)
   CALL bedlogmessage("updateInputPreferenceForNewAssays","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateInputPreferenceForNewAssays ...")
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   DECLARE prefcnt = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE index1 = i4 WITH protect, noconstant(0)
   DECLARE ultragridind = i2 WITH protect, noconstant(0)
   DECLARE gcnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   FREE RECORD getcntinput
   RECORD getcntinput(
     1 input[*]
       2 dcp_input_ref_id = f8
       2 preference[*]
         3 pvc_name = vc
         3 pvc_value = vc
         3 merge_name = vc
         3 merge_id = f8
         3 sequence = i4
         3 cnt_input_id = f8
   )
   SELECT INTO "nl:"
    FROM cnt_input pref,
     cnt_input_key cntrl,
     cnt_dta_key2 dta
    PLAN (pref
     WHERE (pref.section_uid=request->section_uid)
      AND pref.task_assay_uid=taskassayuid
      AND pref.merge_name="DISCRETE_TASK_ASSAY")
     JOIN (cntrl
     WHERE cntrl.cnt_input_key_id=pref.cnt_input_key_id)
     JOIN (dta
     WHERE dta.task_assay_uid=pref.task_assay_uid)
    ORDER BY cntrl.cnt_input_key_id
    HEAD cntrl.cnt_input_key_id
     ccnt = (ccnt+ 1), stat = alterlist(getcntinput->input,ccnt), getcntinput->input[ccnt].
     dcp_input_ref_id = cntrl.dcp_input_ref_id,
     prefcnt = 0, ultragridind = false
     IF (cntrl.input_type=19)
      ultragridind = true
     ENDIF
    DETAIL
     prefcnt = (prefcnt+ 1), stat = alterlist(getcntinput->input[ccnt].preference,prefcnt),
     getcntinput->input[ccnt].preference[prefcnt].pvc_name = pref.pvc_name,
     getcntinput->input[ccnt].preference[prefcnt].pvc_value = pref.pvc_value, getcntinput->input[ccnt
     ].preference[prefcnt].merge_name = pref.merge_name, getcntinput->input[ccnt].preference[prefcnt]
     .merge_id = dta.task_assay_cd,
     getcntinput->input[ccnt].preference[prefcnt].sequence = pref.input_sequence, getcntinput->input[
     ccnt].preference[prefcnt].cnt_input_id = pref.cnt_input_id
     IF (ultragridind
      AND pref.pvc_name="discrete_task_assay*")
      num = 1, gcnt = size(ultragridassays->list,5)
      IF (locateval(num,1,gcnt,dta.task_assay_cd,ultragridassays->list[num].dtacd)=0)
       gcnt = (gcnt+ 1), stat = alterlist(ultragridassays->list,gcnt), ultragridassays->list[gcnt].
       dtacd = dta.task_assay_cd
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(getcntinput))
   CALL bedaddlogstologgerfile(cnvtrectoxml(ultragridassays))
   FOR (index = 1 TO ccnt)
     FOR (index1 = 1 TO size(getcntinput->input[index].preference,5))
       SET newpropid = insertpropertyforcontrol(getcntinput->input[index].dcp_input_ref_id,
        getcntinput->input[index].preference[index1].pvc_name,getcntinput->input[index].preference[
        index1].pvc_value,getcntinput->input[index].preference[index1].merge_name,getcntinput->input[
        index].preference[index1].merge_id,
        getcntinput->input[index].preference[index1].sequence)
       CALL bedaddlogstologgerfile(build2("### Inside updateInputPreferenceForNewAssays - newPropId:",
         newpropid))
       CALL updatecntinputtable(newpropid,getcntinput->input[index].preference[index1].cnt_input_id)
     ENDFOR
   ENDFOR
   CALL bedlogmessage("updateInputPreferenceForNewAssays","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateInputPreferenceForNewAssays ...")
 END ;Subroutine
 SUBROUTINE addassay(taskassayuid,cansaveinterps,assaydesc)
   CALL bedlogmessage("addAssay","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addAssay ...")
   CALL bedaddlogstologgerfile(build2("### Inside addAssay - Assay UID:",taskassayuid,
     " canSaveInterps:",cansaveinterps," assayDesc:",
     assaydesc))
   CALL echo(build2("Adding assayUID=",taskassayuid))
   DECLARE newtaskassaycd = f8 WITH protect, noconstant(0)
   DECLARE mcnt = i4 WITH protect, noconstant(0)
   DECLARE rrcnt = i4 WITH protect, noconstant(0)
   DECLARE omcnt = i4 WITH protect, noconstant(0)
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE witnessrequiedind = i2 WITH protect, noconstant(0)
   DECLARE dtaeventcduid = vc WITH protect, noconstant("")
   FREE RECORD importedrrrec
   RECORD importedrrrec(
     1 list[*]
       2 rrfuid = vc
   )
   FREE RECORD offsetminrec
   RECORD offsetminrec(
     1 list[*]
       2 offsetminnbr = i4
       2 offsettypecd = f8
   )
   FREE RECORD equationsrec
   RECORD equationsrec(
     1 list[*]
       2 equationuid = vc
   )
   SET stat = initrec(ensassayrequest)
   SET stat = alterlist(ensassayrequest->assay_list,1)
   SET ensassayrequest->assay_list[1].action_flag = add_flag
   SELECT INTO "nl:"
    FROM cnt_dta d,
     cnt_code_value_key c1,
     cnt_code_value_key c2,
     cnt_code_value_key c3,
     cnt_code_value_key c4
    PLAN (d
     WHERE d.task_assay_uid=taskassayuid)
     JOIN (c1
     WHERE c1.code_value_uid=outerjoin(d.default_result_type_cduid))
     JOIN (c2
     WHERE c2.code_value_uid=outerjoin(d.activity_type_cduid))
     JOIN (c3
     WHERE c3.code_value_uid=outerjoin(d.rad_sect_type_cduid))
     JOIN (c4
     WHERE c4.code_value_uid=outerjoin(d.bb_result_type_cduid))
    DETAIL
     IF (assaydesc > " ")
      ensassayrequest->assay_list[1].display = assaydesc, ensassayrequest->assay_list[1].description
       = assaydesc
     ELSE
      ensassayrequest->assay_list[1].display = d.mnemonic, ensassayrequest->assay_list[1].description
       = d.description
     ENDIF
     IF (d.default_result_type_cd > 0)
      ensassayrequest->assay_list[1].general_info.result_type_code_value = d.default_result_type_cd
     ELSE
      ensassayrequest->assay_list[1].general_info.result_type_code_value = c1.code_value
     ENDIF
     IF (d.activity_type_cd > 0)
      ensassayrequest->assay_list[1].general_info.activity_type_code_value = d.activity_type_cd
     ELSE
      ensassayrequest->assay_list[1].general_info.activity_type_code_value = c2.code_value
     ENDIF
     ensassayrequest->assay_list[1].general_info.single_select_ind = d.single_select_ind,
     ensassayrequest->assay_list[1].general_info.io_flag = d.io_flag, ensassayrequest->assay_list[1].
     general_info.delta_check_ind = d.delta_lvl_flag,
     ensassayrequest->assay_list[1].general_info.inter_data_check_ind = d.interp_data_ind
     IF (d.rad_section_type_cd > 0)
      ensassayrequest->assay_list[1].general_info.rad_section_type_code_value = d.rad_section_type_cd
     ELSE
      ensassayrequest->assay_list[1].general_info.rad_section_type_code_value = c3.code_value
     ENDIF
     ensassayrequest->assay_list[1].general_info.default_type_flag = d.default_type_flag,
     ensassayrequest->assay_list[1].general_info.sci_notation_ind = d.sci_notation_ind
     IF (d.bb_result_type_cd > 0)
      ensassayrequest->assay_list[1].general_info.res_proc_type_code_value = d.bb_result_type_cd
     ELSE
      ensassayrequest->assay_list[1].general_info.res_proc_type_code_value = c4.code_value
     ENDIF
     ensassayrequest->assay_list[1].general_info.concept_cki = d.concept_cki, witnessrequiedind = d
     .signature_line_ind
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cnt_data_map m,
     cnt_code_value_key c1
    PLAN (m
     WHERE m.task_assay_uid=taskassayuid)
     JOIN (c1
     WHERE c1.code_value_uid=outerjoin(m.service_resource_cduid))
    DETAIL
     mcnt = (mcnt+ 1), stat = alterlist(ensassayrequest->assay_list[1].data_map,mcnt),
     ensassayrequest->assay_list[1].data_map[mcnt].action_flag = add_flag
     IF (m.service_resource_cd > 0)
      ensassayrequest->assay_list[1].data_map[mcnt].service_resource_code_value = m
      .service_resource_cd
     ELSE
      ensassayrequest->assay_list[1].data_map[mcnt].service_resource_code_value = c1.code_value
     ENDIF
     ensassayrequest->assay_list[1].data_map[mcnt].max_digits = m.max_digits, ensassayrequest->
     assay_list[1].data_map[mcnt].min_digits = m.min_digits, ensassayrequest->assay_list[1].data_map[
     mcnt].dec_place = m.min_decimal_places
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cnt_dta_rrf_r r
    PLAN (r
     WHERE r.task_assay_uid=taskassayuid)
    DETAIL
     rrcnt = (rrcnt+ 1), stat = alterlist(importedrrrec->list,rrcnt), importedrrrec->list[rrcnt].
     rrfuid = r.rrf_uid
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(importedrrrec))
   FOR (izi = 1 TO rrcnt)
     CALL handlereferencerange(1,importedrrrec->list[izi].rrfuid,0.0,add_flag)
   ENDFOR
   SET newtaskassaycd = executebedensassay(0)
   SELECT INTO "nl:"
    FROM cnt_dta d
    WHERE d.task_assay_uid=taskassayuid
    DETAIL
     dtaeventcduid = d.event_code_cduid
    WITH nocounter
   ;end select
   CALL addevent(dtaeventcduid,newtaskassaycd)
   CALL updatewitnessrequiredind(newtaskassaycd,witnessrequiedind)
   SELECT INTO "nl:"
    FROM cnt_dta_offset_min off
    PLAN (off
     WHERE off.task_assay_uid=taskassayuid)
    DETAIL
     omcnt = (omcnt+ 1), stat = alterlist(offsetminrec->list,omcnt), offsetminrec->list[omcnt].
     offsetminnbr = off.offset_min_nbr,
     offsetminrec->list[omcnt].offsettypecd = off.offset_min_type_cd
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(offsetminrec))
   FOR (i = 1 TO omcnt)
     CALL updateoffsetminutes(add_flag,newtaskassaycd,offsetminrec->list[i].offsetminnbr,offsetminrec
      ->list[i].offsettypecd)
   ENDFOR
   SELECT INTO "nl:"
    FROM cnt_ref_text rt
    WHERE rt.task_assay_uid=taskassayuid
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside addAssay after cnt_ref_text select - curqual:",
     curqual))
   IF (curqual > 0)
    CALL updatereferencetext(taskassayuid,newtaskassaycd)
   ENDIF
   SELECT INTO "nl:"
    FROM cnt_equation e
    PLAN (e
     WHERE e.task_assay_uid=taskassayuid)
    DETAIL
     ecnt = (ecnt+ 1), stat = alterlist(equationsrec->list,ecnt), equationsrec->list[ecnt].
     equationuid = e.equation_uid
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(equationsrec))
   FOR (i = 1 TO ecnt)
     CALL addnewequation(equationsrec->list[i].equationuid,newtaskassaycd)
   ENDFOR
   IF (cansaveinterps)
    SELECT INTO "nl:"
     FROM cnt_dcp_interp2 i
     WHERE i.task_assay_uid=taskassayuid
     WITH nocounter
    ;end select
    CALL bedaddlogstologgerfile(build2("### Inside addAssay - Can interps be saved:",curqual))
    IF (curqual > 0)
     CALL addnewinterp(taskassayuid,newtaskassaycd)
    ENDIF
   ENDIF
   CALL matchassay(newtaskassaycd,taskassayuid)
   CALL bedlogmessage("addAssay","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addAssay ...")
   RETURN(newtaskassaycd)
 END ;Subroutine
 SUBROUTINE addevent(eventcduid,taskassaycd)
   CALL bedlogmessage("addEvent","Entering ...")
   CALL bedaddlogstologgerfile("### Entering addEvent ...")
   CALL bedaddlogstologgerfile(build2("### Inside addEvent - Event UID:",eventcduid))
   CALL bedaddlogstologgerfile(build2("### Inside addEvent - Task Assay Cd:",taskassaycd))
   DECLARE cdfmeaning = vc WITH protect, noconstant("")
   DECLARE definition = vc WITH protect, noconstant("")
   DECLARE description = vc WITH protect, noconstant("")
   DECLARE display = vc WITH protect, noconstant("")
   DECLARE conceptcki = vc WITH protect, noconstant("")
   DECLARE cki = vc WITH protect, noconstant("")
   DECLARE codeset = i4 WITH protect, noconstant(72)
   DECLARE event_code_value = f8 WITH protect, noconstant(0)
   DECLARE eventsetname = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM cnt_code_value_key c
    PLAN (c
     WHERE c.code_value_uid=eventcduid
      AND c.cnt_code_value_key_id > 0)
    DETAIL
     event_code_value = c.code_value, display = substring(1,40,c.display), definition = substring(1,
      100,c.definition),
     description = substring(1,60,c.description), conceptcki = c.concept_cki, cki = c.cki,
     eventsetname = c.event_set_name
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside addEvent - event_code_value:",event_code_value,
     " display:",display," definition:",
     definition," description:",description," conceptCki:",conceptcki,
     " cki:",cki," eventSetName:",eventsetname," curqual:",
     curqual))
   IF (curqual > 0)
    IF (event_code_value=0
     AND display != "")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=72
        AND cnvtupper(c.display)=cnvtupper(display)
        AND c.active_ind=true)
      DETAIL
       event_code_value = c.code_value
      WITH nocounter
     ;end select
     CALL bedaddlogstologgerfile(build2("### Inside addEvent - event_code_value:",event_code_value))
     IF (event_code_value=0)
      SET event_code_value = insertcodevalue(cdfmeaning,definition,description,display,codeset,
       conceptcki,cki)
      CALL bedaddlogstologgerfile(build2("### Inside addEvent - created event_code_value:",
        event_code_value))
      CALL inserteventcode(event_code_value,definition,description,display,eventsetname)
     ENDIF
    ENDIF
    IF (event_code_value > 0
     AND taskassaycd > 0)
     UPDATE  FROM discrete_task_assay d
      SET d.event_cd = event_code_value, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(
        curdate,curtime),
       d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
       updt_applctx
      PLAN (d
       WHERE d.task_assay_cd=taskassaycd)
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   CALL bedlogmessage("addEvent","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting addEvent ...")
   RETURN(event_code_value)
 END ;Subroutine
 SUBROUTINE sortassaysbeforesaving(dummyvar)
   CALL bedlogmessage("sortAssaysBeforeSaving","Entering ...")
   CALL bedaddlogstologgerfile("### Entering sortAssaysBeforeSaving ...")
   DECLARE ascnt = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE intercnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = assay_cnt),
     cnt_equation_component ec
    PLAN (d)
     JOIN (ec
     WHERE (ec.included_assay_uid=request->assays[d.seq].task_assay_uid))
    ORDER BY ec.included_assay_uid
    HEAD ec.included_assay_uid
     ascnt = (ascnt+ 1), stat = alterlist(assaystosave->assays,ascnt), assaystosave->assays[ascnt].
     assay_action_flag = request->assays[d.seq].assay_action_flag,
     assaystosave->assays[ascnt].task_assay_uid = request->assays[d.seq].task_assay_uid, assaystosave
     ->assays[ascnt].task_assay_cd = request->assays[d.seq].task_assay_cd, assaystosave->assays[ascnt
     ].description = request->assays[d.seq].description,
     assaystosave->assays[ascnt].save_interps = request->assays[d.seq].save_interps
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = assay_cnt),
     cnt_dcp_interp_component comp
    PLAN (d)
     JOIN (comp
     WHERE (comp.component_assay_uid=request->assays[d.seq].task_assay_uid))
    ORDER BY comp.component_assay_uid
    HEAD comp.component_assay_uid
     num = 1, assayfound = locateval(num,1,size(assaystosave->assays,5),comp.component_assay_uid,
      assaystosave->assays[num].task_assay_uid)
     IF (assayfound=0)
      intercnt = (size(assaystosave->assays,5)+ 1), stat = alterlist(assaystosave->assays,intercnt),
      assaystosave->assays[intercnt].assay_action_flag = request->assays[d.seq].assay_action_flag,
      assaystosave->assays[intercnt].task_assay_uid = request->assays[d.seq].task_assay_uid,
      assaystosave->assays[intercnt].task_assay_cd = request->assays[d.seq].task_assay_cd,
      assaystosave->assays[intercnt].description = request->assays[d.seq].description,
      assaystosave->assays[intercnt].save_interps = request->assays[d.seq].save_interps
     ENDIF
    WITH nocounter
   ;end select
   IF (ascnt=0
    AND intercnt=0)
    SET stat = alterlist(assaystosave->assays,assay_cnt)
    FOR (ascnt = 1 TO assay_cnt)
      SET assaystosave->assays[ascnt].assay_action_flag = request->assays[ascnt].assay_action_flag
      SET assaystosave->assays[ascnt].task_assay_uid = request->assays[ascnt].task_assay_uid
      SET assaystosave->assays[ascnt].task_assay_cd = request->assays[ascnt].task_assay_cd
      SET assaystosave->assays[ascnt].description = request->assays[ascnt].description
      SET assaystosave->assays[ascnt].save_interps = request->assays[icnt].save_interps
    ENDFOR
   ELSE
    FOR (icnt = 1 TO assay_cnt)
      SET ascnt = size(assaystosave->assays,5)
      SET num = 1
      SET assayfound = locateval(num,1,ascnt,request->assays[icnt].task_assay_uid,assaystosave->
       assays[num].task_assay_uid)
      IF (assayfound=0)
       SET ascnt = (ascnt+ 1)
       SET stat = alterlist(assaystosave->assays,ascnt)
       SET assaystosave->assays[ascnt].assay_action_flag = request->assays[icnt].assay_action_flag
       SET assaystosave->assays[ascnt].task_assay_uid = request->assays[icnt].task_assay_uid
       SET assaystosave->assays[ascnt].task_assay_cd = request->assays[icnt].task_assay_cd
       SET assaystosave->assays[ascnt].description = request->assays[icnt].description
       SET assaystosave->assays[ascnt].save_interps = request->assays[icnt].save_interps
      ENDIF
    ENDFOR
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(assaystosave)
   ENDIF
   CALL bedaddlogstologgerfile(cnvtrectoxml(assaystosave))
   CALL bedlogmessage("sortAssaysBeforeSaving","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting sortAssaysBeforeSaving ...")
 END ;Subroutine
END GO
