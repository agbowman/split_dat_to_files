CREATE PROGRAM bed_ens_pwrfrm_rec_sections:dba
 IF (validate(reply)=0)
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
 CALL bedbeginscript(1)
 DECLARE section_ref_id = f8 WITH protect, constant(request->dcp_section_ref_id)
 DECLARE add_action_flag = i2 WITH protect, constant(1)
 DECLARE rem_action_flag = i2 WITH protect, constant(2)
 DECLARE sectioninstanceid = f8 WITH protect, noconstant(0)
 DECLARE logfilename = vc WITH protect, noconstant("")
 DECLARE handlesectiondetails(dummyvar=i2) = i2
 DECLARE handlecontrolsandproperities(dummyvar=i2) = i2
 DECLARE handleformshavingthissection(dummyvar=i2) = i2
 DECLARE handleconditionalsections(dummyvar=i2) = i2
 DECLARE resequencecontrols(dummyvar=i2) = i2
 DECLARE handleultragrideventcodes(inputindex=i4) = i2
 CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_PWRFRM_REC_SECTIONS.PRG ####")
 CALL bedaddlogstologgerfile(cnvtrectoxml(request))
 IF ((request->dcp_section_ref_id=0))
  CALL bedlogmessage("Main - Invalid request","dcp_section_ref_id = 0")
  CALL bederror("Invalid request")
 ENDIF
 CALL handlesectiondetails(0)
 CALL handlecontrolsandproperities(0)
 IF ((request->dcp_forms_ref_id > 0))
  CALL handleconditionalsections(0)
 ENDIF
 CALL handleformshavingthissection(0)
 CALL resequencecontrols(0)
 IF ((request->dcp_forms_ref_id > 0))
  SELECT INTO "nl:"
   FROM dcp_forms_ref r
   WHERE (r.dcp_forms_ref_id=request->dcp_forms_ref_id)
    AND r.active_ind=true
   DETAIL
    logfilename = r.definition
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dcp_section_ref dsr
   WHERE dsr.dcp_section_ref_id=section_ref_id
    AND dsr.active_ind=true
   DETAIL
    logfilename = dsr.definition
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(request->cclloggingind))
  CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
  CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_PWRFRM_REC_SECTIONS.PRG ####")
  CALL writelogstothefile(logfilename,request->cclloggingind)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE handlesectiondetails(dummyvar)
   CALL bedlogmessage("handleSectionDetails","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleSectionDetails ...")
   DECLARE eheight = i4 WITH protect, noconstant(0)
   DECLARE ewidth = i4 WITH protect, noconstant(0)
   DECLARE contentheight = i4 WITH protect, noconstant(0)
   DECLARE contentwidth = i4 WITH protect, noconstant(0)
   DECLARE checkcnt = i4 WITH protect, noconstant(0)
   DECLARE mocksecrefid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dcp_section_ref dsr
    WHERE dsr.dcp_section_ref_id=section_ref_id
     AND dsr.active_ind=true
    DETAIL
     eheight = dsr.height, ewidth = dsr.width
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cnt_section_key2 sk,
     cnt_section cs
    PLAN (sk
     WHERE sk.dcp_section_ref_id=section_ref_id)
     JOIN (cs
     WHERE cs.section_uid=sk.section_uid)
    DETAIL
     checkcnt = (checkcnt+ 1), contentheight = cs.section_height, contentwidth = cs.section_width
    WITH nocounter
   ;end select
   IF (checkcnt=1)
    IF (contentheight > eheight)
     SET eheight = contentheight
    ENDIF
    IF (contentwidth > ewidth)
     SET ewidth = contentwidth
    ENDIF
   ENDIF
   CALL bedaddlogstologgerfile(build2("### Inside handleSectionDetails - eHeight:",eheight))
   CALL bedaddlogstologgerfile(build2("### Inside handleSectionDetails - eWidth:",ewidth))
   CALL deletesection(section_ref_id)
   CALL insertsection(section_ref_id,request->description,request->definition,0.0,0.0,
    eheight,ewidth,mocksecrefid,sectioninstanceid)
   CALL bedlogmessage("handleSectionDetails","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleSectionDetails ...")
 END ;Subroutine
 SUBROUTINE handlecontrolsandproperities(dummyvar)
   CALL bedlogmessage("handleControlDetails","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleControlsAndProperities ...")
   DECLARE inputidx = i4 WITH protect, noconstant(0)
   DECLARE newinputid = f8 WITH protect, noconstant(0.0)
   DECLARE propidx = i4 WITH protect, noconstant(0)
   DECLARE newpropid = f8 WITH protect, noconstant(0.0)
   DECLARE parententityid = f8 WITH protect, noconstant(0.0)
   DECLARE parententityname = vc WITH protect, noconstant("")
   FOR (inputidx = 1 TO size(request->input_list,5))
     IF (validate(debug,0)=1)
      CALL logdebuginfo(build2("Inserting control at index: ",inputidx))
      CALL logdebuginfo(build2("Control desc: ",request->input_list[inputidx].description))
     ENDIF
     CALL bedaddlogstologgerfile(build2("Inserting control at index: ",inputidx))
     CALL bedaddlogstologgerfile(build2("Control desc: ",request->input_list[inputidx].description))
     SET newinputid = insertcontrol(section_ref_id,sectioninstanceid,request->input_list[inputidx].
      description,request->input_list[inputidx].module,request->input_list[inputidx].input_ref_seq,
      request->input_list[inputidx].input_type)
     IF ((request->input_list[inputidx].cnt_input_key_id > 0))
      CALL updatecntinputkeytable(request->input_list[inputidx].cnt_input_key_id,newinputid)
     ENDIF
     FOR (propidx = 1 TO size(request->input_list[inputidx].nv,5))
       IF ((request->input_list[inputidx].nv[propidx].pvc_name="caption"))
        SET request->input_list[inputidx].nv[propidx].pvc_value = getcorrectnewlinecharforstring(
         request->input_list[inputidx].nv[propidx].pvc_value)
       ENDIF
       SET parententityname = request->input_list[inputidx].nv[propidx].merge_name
       SET parententityid = request->input_list[inputidx].nv[propidx].merge_id
       IF (parententityid=0
        AND trim(request->input_list[inputidx].nv[propidx].merge_uid,7) != "")
        SET parententityid = determineparententityid(parententityname,request->input_list[inputidx].
         nv[propidx].merge_uid)
       ENDIF
       IF (((parententityid > 0
        AND parententityname != "") OR (((parententityid=0
        AND parententityname="") OR (((isconditionalunit(request->input_list[inputidx].nv[propidx].
        pvc_name)) OR (isgrideventcode(request->input_list[inputidx].nv[propidx].pvc_name))) )) )) )
        IF (validate(debug,0)=1)
         CALL logdebuginfo(build2("Inserting property at index: ",propidx))
         CALL logdebuginfo(build2("PVC Name: ",request->input_list[inputidx].nv[propidx].pvc_name))
        ENDIF
        CALL bedaddlogstologgerfile(build2("Inserting property at index: ",propidx))
        CALL bedaddlogstologgerfile(build2("PVC Name: ",request->input_list[inputidx].nv[propidx].
          pvc_name))
        SET newpropid = insertpropertyforcontrol(newinputid,request->input_list[inputidx].nv[propidx]
         .pvc_name,request->input_list[inputidx].nv[propidx].pvc_value,parententityname,
         parententityid,
         request->input_list[inputidx].nv[propidx].sequence)
        IF ((request->input_list[inputidx].nv[propidx].cnt_input_id > 0))
         CALL updatecntinputtable(newpropid,request->input_list[inputidx].nv[propidx].cnt_input_id)
        ENDIF
       ENDIF
     ENDFOR
     IF (size(request->input_list[inputidx].grideventcodes,5) > 0)
      CALL handleultragrideventcodes(inputidx)
     ENDIF
   ENDFOR
   CALL bedlogmessage("handleControlDetails","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleControlsAndProperities ...")
 END ;Subroutine
 SUBROUTINE handleconditionalsections(dummyvar)
   CALL bedlogmessage("handleConditionalSections","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleConditionalSections ...")
   IF (size(request->conditionalsections,5) > 0)
    DECLARE forminstanceid = f8 WITH protect, noconstant(0)
    DECLARE sidx = i4 WITH protect, noconstant(0)
    DECLARE nextsectionseq = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM dcp_forms_ref r
     WHERE (r.dcp_forms_ref_id=request->dcp_forms_ref_id)
      AND r.active_ind=true
     DETAIL
      forminstanceid = r.dcp_form_instance_id
     WITH nocounter
    ;end select
    CALL bedaddlogstologgerfile(build2("### Inside handleConditionalSections - formInstanceId:",
      forminstanceid))
    FOR (sidx = 1 TO size(request->conditionalsections,5))
      CALL bedaddlogstologgerfile(build2("### Inside handleConditionalSections - actionFlag:",request
        ->conditionalsections[sidx].actionflag))
      CALL bedaddlogstologgerfile(build2("### Inside handleConditionalSections - dcpSectionRefId:",
        request->conditionalsections[sidx].dcpsectionrefid))
      IF ((request->conditionalsections[sidx].actionflag=add_action_flag))
       SELECT INTO "nl:"
        FROM dcp_forms_def d
        WHERE d.dcp_form_instance_id=forminstanceid
         AND (d.dcp_forms_ref_id=request->dcp_forms_ref_id)
         AND (d.dcp_section_ref_id=request->conditionalsections[sidx].dcpsectionrefid)
         AND d.active_ind=true
        WITH nocounter
       ;end select
       CALL bedaddlogstologgerfile(build2("### Inside handleConditionalSections - curqual:",curqual))
       IF (curqual=0)
        SELECT INTO "nl:"
         FROM dcp_forms_def d
         WHERE d.dcp_form_instance_id=forminstanceid
          AND (d.dcp_forms_ref_id=request->dcp_forms_ref_id)
         ORDER BY d.section_seq DESC
         HEAD REPORT
          nextsectionseq = (d.section_seq+ 1)
         WITH nocounter
        ;end select
        CALL insertnewformandsectionsrelationship(request->dcp_forms_ref_id,forminstanceid,request->
         conditionalsections[sidx].dcpsectionrefid,nextsectionseq,1)
       ENDIF
      ELSEIF ((request->conditionalsections[sidx].actionflag=rem_action_flag))
       DELETE  FROM dcp_forms_def d
        WHERE (d.dcp_forms_ref_id=request->dcp_forms_ref_id)
         AND d.dcp_form_instance_id=forminstanceid
         AND (d.dcp_section_ref_id=request->conditionalsections[sidx].dcpsectionrefid)
        WITH nocounter
       ;end delete
      ENDIF
    ENDFOR
   ENDIF
   CALL bedlogmessage("handleConditionalSections","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleConditionalSections ...")
 END ;Subroutine
 SUBROUTINE handleformshavingthissection(dummyvar)
   CALL bedlogmessage("handleFormsHavingThisSection","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleFormsHavingThisSection ...")
   DECLARE fcnt = i4 WITH protect, noconstant(0)
   DECLARE sectionwidth = i4 WITH protect, noconstant(0)
   DECLARE sectionheight = i4 WITH protect, noconstant(0)
   FREE RECORD associatedforms
   RECORD associatedforms(
     1 list[*]
       2 dcp_form_instance_id = f8
       2 fwidth = i4
       2 fheight = i4
   )
   SELECT INTO "nl:"
    FROM dcp_section_ref sr
    WHERE sr.dcp_section_ref_id=section_ref_id
     AND sr.active_ind=true
    DETAIL
     sectionwidth = sr.width, sectionheight = sr.height
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dcp_forms_def fd,
     dcp_forms_ref fr
    PLAN (fd
     WHERE fd.dcp_section_ref_id=section_ref_id
      AND fd.active_ind=true)
     JOIN (fr
     WHERE fr.dcp_form_instance_id=fd.dcp_form_instance_id
      AND fr.active_ind=true)
    DETAIL
     IF (((fr.width < sectionwidth) OR (fr.height < sectionheight)) )
      fcnt = (fcnt+ 1), stat = alterlist(associatedforms->list,fcnt), associatedforms->list[fcnt].
      dcp_form_instance_id = fr.dcp_form_instance_id,
      associatedforms->list[fcnt].fwidth = fr.width, associatedforms->list[fcnt].fheight = fr.height
      IF (fr.width < sectionwidth)
       associatedforms->list[fcnt].fwidth = sectionwidth
      ENDIF
      IF (fr.height < sectionheight)
       associatedforms->list[fcnt].fheight = sectionheight
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(associatedforms))
   FOR (k = 1 TO fcnt)
     UPDATE  FROM dcp_forms_ref fr
      SET fr.width = associatedforms->list[k].fwidth, fr.height = associatedforms->list[k].fheight
      WHERE (fr.dcp_form_instance_id=associatedforms->list[k].dcp_form_instance_id)
      WITH nocounter
     ;end update
   ENDFOR
   CALL bedlogmessage("handleFormsHavingThisSection","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleFormsHavingThisSection ...")
 END ;Subroutine
 SUBROUTINE resequencecontrols(dummyvar)
   CALL bedlogmessage("resequenceControls","Entering ...")
   CALL bedaddlogstologgerfile("### Entering resequenceControls ...")
   DECLARE previousseq = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   FREE RECORD inputstoupdate
   RECORD inputstoupdate(
     1 list[*]
       2 dcp_input_ref_id = f8
       2 newseq = i4
   )
   SELECT INTO "nl:"
    FROM dcp_input_ref r
    PLAN (r
     WHERE r.dcp_section_ref_id=section_ref_id
      AND r.dcp_section_instance_id=sectioninstanceid
      AND r.active_ind=true)
    ORDER BY r.input_ref_seq
    DETAIL
     IF ((r.input_ref_seq != (previousseq+ 1)))
      icnt = (icnt+ 1), stat = alterlist(inputstoupdate->list,icnt), inputstoupdate->list[icnt].
      dcp_input_ref_id = r.dcp_input_ref_id,
      inputstoupdate->list[icnt].newseq = (previousseq+ 1), previousseq = (previousseq+ 1)
     ELSE
      previousseq = r.input_ref_seq
     ENDIF
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(cnvtrectoxml(inputstoupdate))
   FOR (i = 1 TO icnt)
     UPDATE  FROM dcp_input_ref r
      SET r.input_ref_seq = inputstoupdate->list[i].newseq
      WHERE (r.dcp_input_ref_id=inputstoupdate->list[i].dcp_input_ref_id)
      WITH nocounter
     ;end update
   ENDFOR
   CALL bedlogmessage("resequenceControls","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting resequenceControls ...")
 END ;Subroutine
 SUBROUTINE handleultragrideventcodes(inputindex)
   CALL bedlogmessage("handleUltraGridEventCodes","Entering ...")
   CALL bedaddlogstologgerfile("### Entering handleUltraGridEventCodes ...")
   DECLARE k = i4 WITH protect, noconstant(0)
   FOR (k = 1 TO size(request->input_list[inputindex].grideventcodes,5))
     CALL bedaddlogstologgerfile(build2("### Inside handleUltraGridEventCodes - event_cd UID:",
       request->input_list[inputindex].grideventcodes[k].event_cduid))
     IF ((request->input_list[inputindex].grideventcodes[k].event_cd=0))
      SET request->input_list[inputindex].grideventcodes[k].event_cd = determineparententityid(
       "V500_EVENT_CODE",request->input_list[inputindex].grideventcodes[k].event_cduid)
     ENDIF
     CALL bedaddlogstologgerfile(build2("### Inside handleUltraGridEventCodes - event_cd:",request->
       input_list[inputindex].grideventcodes[k].event_cd))
     SELECT INTO "nl:"
      FROM code_value_event_r c
      PLAN (c
       WHERE (c.parent_cd=request->input_list[inputindex].grideventcodes[k].col_assay_cd)
        AND (c.flex1_cd=request->input_list[inputindex].grideventcodes[k].row_assay_cd)
        AND c.flex2_cd=0
        AND c.flex3_cd=0
        AND c.flex4_cd=0
        AND c.flex5_cd=0)
      WITH nocounter
     ;end select
     CALL bedaddlogstologgerfile(build2("### Inside handleUltraGridEventCodes - curqual:",curqual))
     CALL bedaddlogstologgerfile(build2("### Inside handleUltraGridEventCodes - col_assay_cd:",
       request->input_list[inputindex].grideventcodes[k].col_assay_cd))
     CALL bedaddlogstologgerfile(build2("### Inside handleUltraGridEventCodes - row_assay_cd:",
       request->input_list[inputindex].grideventcodes[k].row_assay_cd))
     IF (curqual > 0)
      DELETE  FROM code_value_event_r c
       WHERE (c.parent_cd=request->input_list[inputindex].grideventcodes[k].col_assay_cd)
        AND (c.flex1_cd=request->input_list[inputindex].grideventcodes[k].row_assay_cd)
        AND c.flex2_cd=0
        AND c.flex3_cd=0
        AND c.flex4_cd=0
        AND c.flex5_cd=0
       WITH nocounter
      ;end delete
     ENDIF
     INSERT  FROM code_value_event_r cer
      SET cer.event_cd = request->input_list[inputindex].grideventcodes[k].event_cd, cer.parent_cd =
       request->input_list[inputindex].grideventcodes[k].col_assay_cd, cer.flex1_cd = request->
       input_list[inputindex].grideventcodes[k].row_assay_cd,
       cer.flex2_cd = 0, cer.flex3_cd = 0, cer.flex4_cd = 0,
       cer.flex5_cd = 0, cer.updt_id = reqinfo->updt_id, cer.updt_task = reqinfo->updt_task,
       cer.updt_applctx = reqinfo->updt_applctx, cer.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
   ENDFOR
   CALL bedlogmessage("handleUltraGridEventCodes","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting handleUltraGridEventCodes ...")
 END ;Subroutine
END GO
