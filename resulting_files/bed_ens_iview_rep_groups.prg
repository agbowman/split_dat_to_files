CREATE PROGRAM bed_ens_iview_rep_groups
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
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE assaycnt = i4 WITH protect, noconstant(0)
 DECLARE docsetsectionrefid = f8 WITH protect, noconstant(0.0)
 DECLARE docsetrefid = f8 WITH protect, noconstant(0.0)
 DECLARE repeatablegroupcd = f8 WITH protect, noconstant(request->repeatable_group.
  repeatable_group_cd)
 DECLARE createrepeatablegroup(dummyvar=i2) = null
 DECLARE createlabelassays(dummyvar=i2) = null
 DECLARE updatelabelassays(dummyvar=i2) = null
 DECLARE createlabeltemplate(dummyvar=i2) = null
 DECLARE updatelabeltemplate(dummyvar=i2) = null
 CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_IVIEW_REP_GROUPS_ASSAY.PRG ####")
 CALL bedaddlogstologgerfile(cnvtrectoxml(request))
 IF (repeatablegroupcd > 0)
  CALL updatelabelassays(0)
  CALL updatelabeltemplate(0)
 ELSE
  CALL createrepeatablegroup(0)
  CALL createlabelassays(0)
  CALL createlabeltemplate(0)
 ENDIF
 IF (validate(request->iviewname)
  AND validate(request->cclloggingind))
  CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
  CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_IVIEW_REP_GROUPS_ASSAY.PRG ####")
  CALL writeiviewlogstothefile(request->iviewname,request->cclloggingind)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE createrepeatablegroup(dummyvar)
   CALL bedlogmessage("createRepeatableGroup","Entering ...")
   CALL bedaddlogstologgerfile("### Entering createRepeatableGroup ...")
   DECLARE docsetsectionrefrelid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    seqid = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     docsetsectionrefid = cnvtreal(seqid)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2(
     "### inserting into doc_set_section_ref with docSetSectionRefId:",docsetsectionrefid))
   INSERT  FROM doc_set_section_ref sr
    SET sr.doc_set_section_ref_id = docsetsectionrefid, sr.prev_doc_set_section_ref_id =
     docsetsectionrefid, sr.doc_set_section_name = request->repeatable_group.repeatable_group_name,
     sr.doc_set_section_name_key = cnvtupper(request->repeatable_group.repeatable_group_name), sr
     .active_ind = 1, sr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     sr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), sr.updt_cnt = 0, sr.updt_id = reqinfo->
     updt_id,
     sr.updt_task = reqinfo->updt_task, sr.updt_applctx = reqinfo->updt_applctx, sr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    seqid = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     docsetrefid = cnvtreal(seqid)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### inserting into doc_set_ref with docSetRefId:",docsetrefid)
    )
   INSERT  FROM doc_set_ref dsr
    SET dsr.doc_set_ref_id = docsetrefid, dsr.prev_doc_set_ref_id = docsetrefid, dsr.doc_set_name =
     request->repeatable_group.repeatable_group_name,
     dsr.active_ind = 1, dsr.doc_set_name_key = cnvtupper(request->repeatable_group.
      repeatable_group_name), dsr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     dsr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), dsr.last_modified_dt_tm = cnvtdatetime(
      curdate,curtime3), dsr.updt_cnt = 0,
     dsr.updt_id = reqinfo->updt_id, dsr.updt_task = reqinfo->updt_task, dsr.updt_applctx = reqinfo->
     updt_applctx,
     dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    seqid = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     docsetsectionrefrelid = cnvtreal(seqid)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2(
     "### inserting into doc_set_section_ref_r with docSetSectionRefRelId:",docsetsectionrefrelid))
   INSERT  FROM doc_set_section_ref_r dssrr
    SET dssrr.doc_set_section_ref_r_id = docsetsectionrefrelid, dssrr.prev_doc_set_section_ref_r_id
      = docsetsectionrefrelid, dssrr.doc_set_ref_id = docsetrefid,
     dssrr.doc_set_section_ref_id = docsetsectionrefid, dssrr.doc_set_section_sequence = 1, dssrr
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     dssrr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), dssrr.active_ind = 1, dssrr.updt_id =
     reqinfo->updt_id,
     dssrr.updt_applctx = reqinfo->updt_applctx, dssrr.updt_task = reqinfo->updt_task, dssrr.updt_cnt
      = 0,
     dssrr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bedlogmessage("createRepeatableGroup","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting createRepeatableGroup ...")
 END ;Subroutine
 SUBROUTINE createlabelassays(dummyvar)
   CALL bedlogmessage("createLabelAssays","Entering ...")
   CALL bedaddlogstologgerfile("### Entering createLabelAssays ...")
   FOR (index = 1 TO size(request->repeatable_group.label_assays,5))
     IF ((request->repeatable_group.label_assays[index].modified_status=added))
      CALL bedaddlogstologgerfile(build2("### Inside createLabelAssays docSetSectionRefId:",
        docsetsectionrefid,", assay_cd:",request->repeatable_group.label_assays[index].assay_cd))
      DECLARE istheassayneverpartofgroup = i2 WITH protect, noconstant(1)
      SELECT INTO "nl:"
       FROM doc_set_element_ref sef
       PLAN (sef
        WHERE sef.doc_set_section_ref_id=docsetsectionrefid
         AND (sef.task_assay_cd=request->repeatable_group.label_assays[index].assay_cd))
       HEAD sef.task_assay_cd
        request->repeatable_group.label_assays[index].modified_status = modified,
        istheassayneverpartofgroup = 0
       WITH nocounter
      ;end select
      CALL bedaddlogstologgerfile(build2("### isTheAssayNeverPartOfGroup:",istheassayneverpartofgroup
        ))
      IF (istheassayneverpartofgroup=1)
       DECLARE newdocsetelementid = f8 WITH protect, noconstant(0.0)
       SELECT INTO "nl:"
        seqid = seq(carenet_seq,nextval)
        FROM dual
        DETAIL
         newdocsetelementid = cnvtreal(seqid)
        WITH format, nocounter
       ;end select
       CALL bedaddlogstologgerfile(build2(
         "### Inserting into doc_set_element_ref - newDocSetElementId:",newdocsetelementid))
       INSERT  FROM doc_set_element_ref dser
        SET dser.doc_set_element_id = newdocsetelementid, dser.prev_doc_set_element_id =
         newdocsetelementid, dser.doc_set_section_ref_id = docsetsectionrefid,
         dser.doc_set_element_name = request->repeatable_group.label_assays[index].mnemonic, dser
         .doc_set_elem_sequence = request->repeatable_group.label_assays[index].sequence, dser
         .active_ind = 1,
         dser.task_assay_cd = request->repeatable_group.label_assays[index].assay_cd, dser
         .required_ind = request->repeatable_group.label_assays[index].required_ind, dser
         .allow_comment_ind = 1,
         dser.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), dser.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), dser.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         dser.updt_id = reqinfo->updt_id, dser.updt_applctx = reqinfo->updt_applctx, dser.updt_cnt =
         0,
         dser.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("createLabelAssays","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting createLabelAssays ...")
 END ;Subroutine
 SUBROUTINE updatelabelassays(dummyvar)
   CALL bedlogmessage("updateLabelAssays","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateLabelAssays ...")
   SELECT INTO "nl:"
    FROM doc_set_section_ref_r r
    PLAN (r
     WHERE r.doc_set_ref_id=repeatablegroupcd)
    DETAIL
     docsetsectionrefid = r.doc_set_section_ref_id
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### Inside updateLabelAssays - docSetSectionRefId:",
     docsetsectionrefid))
   CALL createlabelassays(0)
   FOR (index = 1 TO size(request->repeatable_group.label_assays,5))
     IF ((((request->repeatable_group.label_assays[index].modified_status=modified)) OR ((request->
     repeatable_group.label_assays[index].modified_status=removed))) )
      DECLARE newdocsetelementid = f8 WITH protect, noconstant(0.0)
      FREE RECORD oldlabelassayelement
      RECORD oldlabelassayelement(
        1 element
          2 doc_set_element_id = f8
          2 doc_set_elem_sequence = i4
          2 required_ind = i2
          2 beg_effective_dt_tm = dq8
          2 active_ind = i2
      )
      SELECT INTO "nl:"
       seqid = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        newdocsetelementid = cnvtreal(seqid)
       WITH format, nocounter
      ;end select
      CALL bedaddlogstologgerfile(build2("### Inside updateLabelAssays - newDocSetElementId:",
        newdocsetelementid))
      CALL bedaddlogstologgerfile(build2("### Inside updateLabelAssays - assay_cd:",request->
        repeatable_group.label_assays[index].assay_cd))
      SELECT INTO "nl:"
       FROM doc_set_element_ref sef
       PLAN (sef
        WHERE sef.doc_set_section_ref_id=docsetsectionrefid
         AND (sef.task_assay_cd=request->repeatable_group.label_assays[index].assay_cd))
       DETAIL
        oldlabelassayelement->element.doc_set_element_id = sef.doc_set_element_id,
        oldlabelassayelement->element.doc_set_elem_sequence = sef.doc_set_elem_sequence,
        oldlabelassayelement->element.required_ind = sef.required_ind,
        oldlabelassayelement->element.beg_effective_dt_tm = sef.beg_effective_dt_tm
       WITH nocounter
      ;end select
      CALL bedaddlogstologgerfile(cnvtrectoxml(oldlabelassayelement))
      INSERT  FROM doc_set_element_ref dser
       SET dser.doc_set_element_id = newdocsetelementid, dser.prev_doc_set_element_id =
        oldlabelassayelement->element.doc_set_element_id, dser.doc_set_section_ref_id =
        docsetsectionrefid,
        dser.doc_set_element_name = request->repeatable_group.label_assays[index].mnemonic, dser
        .doc_set_elem_sequence = oldlabelassayelement->element.doc_set_elem_sequence, dser.active_ind
         = 1,
        dser.task_assay_cd = request->repeatable_group.label_assays[index].assay_cd, dser
        .required_ind = oldlabelassayelement->element.required_ind, dser.allow_comment_ind = 1,
        dser.beg_effective_dt_tm = cnvtdatetime(oldlabelassayelement->element.beg_effective_dt_tm),
        dser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dser.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        dser.updt_id = reqinfo->updt_id, dser.updt_applctx = reqinfo->updt_applctx, dser.updt_cnt = 0,
        dser.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF ((request->repeatable_group.label_assays[index].modified_status=removed))
       SET oldlabelassayelement->active_ind = 0
      ELSE
       SET oldlabelassayelement->active_ind = 1
      ENDIF
      CALL bedaddlogstologgerfile(build2("### Inside updateLabelAssays - active_ind:",
        oldlabelassayelement->active_ind))
      CALL bedaddlogstologgerfile(build2("### Inside updateLabelAssays sequence:",request->
        repeatable_group.label_assays[index].sequence,", required_ind:",request->repeatable_group.
        label_assays[index].required_ind))
      UPDATE  FROM doc_set_element_ref dser
       SET dser.doc_set_elem_sequence = request->repeatable_group.label_assays[index].sequence, dser
        .required_ind = request->repeatable_group.label_assays[index].required_ind, dser.active_ind
         = oldlabelassayelement->active_ind,
        dser.updt_cnt = (dser.updt_cnt+ 1), dser.updt_dt_tm = cnvtdatetime(curdate,curtime3), dser
        .updt_id = reqinfo->updt_id,
        dser.updt_task = reqinfo->updt_task, dser.updt_applctx = reqinfo->updt_applctx
       PLAN (dser
        WHERE (dser.doc_set_element_id=oldlabelassayelement->element.doc_set_element_id)
         AND dser.doc_set_section_ref_id=docsetsectionrefid)
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
   CALL bedlogmessage("updateLabelAssays","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateLabelAssays ...")
 END ;Subroutine
 SUBROUTINE createlabeltemplate(dummyvar)
   CALL bedlogmessage("createLabelTemplate","Entering ...")
   CALL bedaddlogstologgerfile("### Entering createLabelTemplate ...")
   DECLARE newlabeltemplateid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    seqid = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     newlabeltemplateid = cnvtreal(seqid)
    WITH format, nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### newLabelTemplateId:",newlabeltemplateid))
   INSERT  FROM dynamic_label_template dlt
    SET dlt.label_template_id = newlabeltemplateid, dlt.doc_set_ref_id = docsetrefid, dlt.updt_cnt =
     0,
     dlt.updt_id = reqinfo->updt_id, dlt.updt_task = reqinfo->updt_task, dlt.updt_applctx = reqinfo->
     updt_applctx,
     dlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dlt.encounter_specific_ind = request->
     repeatable_group.encounter_specific_ind
    WITH nocounter
   ;end insert
   FOR (index = 1 TO size(request->repeatable_group.template_assays,5))
    CALL bedaddlogstologgerfile(build2("### assay_cd:",request->repeatable_group.template_assays[
      index].assay_cd))
    UPDATE  FROM discrete_task_assay dta
     SET dta.label_template_id = newlabeltemplateid, dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      dta.updt_id = reqinfo->updt_id, dta.updt_task = reqinfo->updt_task, dta.updt_applctx = reqinfo
      ->updt_applctx
     PLAN (dta
      WHERE (dta.task_assay_cd=request->repeatable_group.template_assays[index].assay_cd))
     WITH nocounter
    ;end update
   ENDFOR
   CALL bedlogmessage("createLabelTemplate","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting createLabelTemplate ...")
 END ;Subroutine
 SUBROUTINE updatelabeltemplate(dummyvar)
   CALL bedlogmessage("updateLabelTemplate","Entering ...")
   CALL bedaddlogstologgerfile("### Entering updateLabelTemplate ...")
   DECLARE labeltemplateid = f8 WITH protect, noconstant(0.0)
   DECLARE assayslabeltemplateid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM dynamic_label_template dlt
    PLAN (dlt
     WHERE dlt.doc_set_ref_id=repeatablegroupcd)
    DETAIL
     labeltemplateid = dlt.label_template_id
    WITH nocounter
   ;end select
   CALL bedaddlogstologgerfile(build2("### labelTemplateId:",labeltemplateid))
   UPDATE  FROM dynamic_label_template dlt
    SET dlt.encounter_specific_ind = request->repeatable_group.encounter_specific_ind, dlt.updt_cnt
      = (dlt.updt_cnt+ 1), dlt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dlt.updt_id = reqinfo->updt_id, dlt.updt_task = reqinfo->updt_task, dlt.updt_applctx = reqinfo->
     updt_applctx
    PLAN (dlt
     WHERE dlt.label_template_id=labeltemplateid)
    WITH nocounter
   ;end update
   FOR (index = 1 TO size(request->repeatable_group.template_assays,5))
     SELECT INTO "nl:"
      FROM discrete_task_assay a
      PLAN (a
       WHERE (a.task_assay_cd=request->repeatable_group.template_assays[index].assay_cd))
      DETAIL
       assayslabeltemplateid = a.label_template_id
      WITH nocounter
     ;end select
     CALL bedaddlogstologgerfile(build2("### assaysLabelTemplateId:",assayslabeltemplateid))
     IF (assayslabeltemplateid != labeltemplateid)
      CALL bedaddlogstologgerfile(build2("### assay_cd:",request->repeatable_group.template_assays[
        index].assay_cd))
      UPDATE  FROM discrete_task_assay dta
       SET dta.label_template_id = labeltemplateid, dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_dt_tm
         = cnvtdatetime(curdate,curtime3),
        dta.updt_id = reqinfo->updt_id, dta.updt_task = reqinfo->updt_task, dta.updt_applctx =
        reqinfo->updt_applctx
       PLAN (dta
        WHERE (dta.task_assay_cd=request->repeatable_group.template_assays[index].assay_cd))
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
   CALL bedlogmessage("updateLabelTemplate","Exiting ...")
   CALL bedaddlogstologgerfile("### Exiting updateLabelTemplate ...")
 END ;Subroutine
END GO
