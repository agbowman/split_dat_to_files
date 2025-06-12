CREATE PROGRAM bed_ens_cnt_wv_details:dba
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
 FREE RECORD existingdetails
 RECORD existingdetails(
   1 working_view_sections[*]
     2 working_view_section_id = f8
     2 display_name = vc
     2 event_set_name = vc
     2 included_ind = i2
     2 required_ind = i2
     2 section_type_flag = i2
     2 working_view_items[*]
       3 working_view_item_id = f8
       3 falloff_view_minutes = i4
       3 included_ind = i2
       3 parent_event_set_name = vc
       3 primitive_event_set_name = vc
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
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs88_dba_cd)))
  DECLARE cs88_dba_cd = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF ((request->position_cd > 0))
  SET cs88_dba_cd = request->position_cd
 ELSE
  DECLARE dbacd = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=88
    AND c.cdf_meaning="DBA"
    AND c.active_ind=1
   DETAIL
    dbacd = c.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Could not find DBA")
  SET cs88_dba_cd = dbacd
 ENDIF
 DECLARE logfilename = vc WITH protect, noconstant("")
 DECLARE insertworkingview(futureind=i2) = i2
 DECLARE getcurrentdcpworkingviewid(dummyvar=i2) = f8
 DECLARE next_id(next_id_dummy=i4) = f8
 DECLARE loadexistingdetails(dcp_id=f8) = i2
 DECLARE comparedetails(dummyvar=i2) = i2
 CALL bedaddlogstologgerfile("#### ENTERING INTO BED_ENS_CNT_WV_DETAILS.PRG ####")
 CALL bedaddlogstologgerfile(cnvtrectoxml(request))
 CALL bedaddlogstologgerfile(build2("### CS48_ACTIVE_CD value:",cs48_active_cd))
 CALL bedaddlogstologgerfile(build2("### CS88_DBA_CD value:",cs88_dba_cd))
 CALL insertworkingview(request->future_ind)
 IF (validate(request->ccl_logging_ind))
  CALL bedaddlogstologgerfile(cnvtrectoxml(reply))
  SET logfilename = request->working_view_display
  CALL bedaddlogstologgerfile("#### EXITING FROM BED_ENS_CNT_WV_DETAILS.PRG ####")
  CALL writeiviewlogstothefile(logfilename,request->ccl_logging_ind)
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getcurrentdcpworkingviewid(dummyvar)
   CALL bedaddlogstologgerfile("### Entering getCurrentDCPWorkingViewId ...")
   DECLARE cnt_dcp_id = f8 WITH protect, noconstant(0.0)
   DECLARE match_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM cnt_wv_key c
    PLAN (c
     WHERE (c.working_view_uid=request->working_view_uid)
      AND c.active_ind=1)
    DETAIL
     cnt_dcp_id = c.dcp_wv_ref_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not retrieve dcp id")
   CALL bedaddlogstologgerfile(build2("### Inside getCurrentDCPWorkingViewId - dcp id:",cnt_dcp_id))
   IF (cnt_dcp_id > 0)
    SELECT INTO "nl:"
     FROM working_view wv
     PLAN (wv
      WHERE wv.working_view_id=cnt_dcp_id)
     DETAIL
      IF (wv.current_working_view=0)
       match_id = wv.working_view_id
      ELSE
       match_id = wv.current_working_view
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not retrieve version")
   ELSE
    SELECT INTO "nl:"
     FROM cnt_wv_key w,
      working_view wv
     PLAN (w
      WHERE (w.working_view_uid=request->working_view_uid)
       AND w.active_ind=1)
      JOIN (wv
      WHERE cnvtupper(wv.display_name)=cnvtupper(w.display_name)
       AND wv.current_working_view=0)
     DETAIL
      match_id = wv.working_view_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not retrieve name match")
   ENDIF
   RETURN(match_id)
   CALL bedaddlogstologgerfile(build2("### Inside getCurrentDCPWorkingViewId - Value of match_id:",
     match_id))
   CALL bedaddlogstologgerfile("### Exiting getCurrentDCPWorkingViewId ...")
 END ;Subroutine
 SUBROUTINE insertworkingview(futureind)
   CALL bedaddlogstologgerfile("### Entering insertWorkingView ...")
   CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - futureInd:",futureind))
   DECLARE currentid = f8 WITH protect, noconstant(0.0)
   DECLARE active = i2 WITH protect, noconstant(0)
   DECLARE version = i4 WITH protect, noconstant(0)
   DECLARE wv_display = vc WITH protect
   DECLARE wv_location_cd = f8 WITH protect, noconstant(0.0)
   DECLARE wv_position_cd = f8 WITH protect, noconstant(0.0)
   DECLARE view_id = f8 WITH protect, noconstant(0.0)
   DECLARE section_id = f8 WITH protect, noconstant(0.0)
   DECLARE item_id = f8 WITH protect, noconstant(0.0)
   DECLARE scnt = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   SET view_id = next_id(0)
   CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - Value of view_id:",view_id))
   IF (futureind=1)
    SET currentid = getcurrentdcpworkingviewid(0)
    SELECT INTO "nl:"
     FROM working_view wv
     WHERE wv.working_view_id=currentid
     DETAIL
      wv_display = wv.display_name, wv_location_cd = wv.location_cd, wv_position_cd = wv.position_cd
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not load wv details")
    SET active = 0
    SET version = 0
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView and futureInd is 1- currentId:",
      currentid))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView and futureInd is 1- wv_display:",
      wv_display))
    CALL bedaddlogstologgerfile(build2(
      "### Inside insertWorkingView and futureInd is 1- wv_location_cd:",wv_location_cd))
    CALL bedaddlogstologgerfile(build2(
      "### Inside insertWorkingView and futureInd is 1- wv_position_cd:",wv_position_cd))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView and futureInd is 1- active:",
      active))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView and futureInd is 1- version:",
      version))
    CALL loadexistingdetails(currentid)
    CALL comparedetails(0)
   ELSE
    SET wv_display = request->working_view_display
    SET currentid = 0
    SET active = 1
    SET version = 1
    SET wv_location_cd = 0.0
    SET wv_position_cd = cs88_dba_cd
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - currentId:",currentid))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - wv_display:",wv_display))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - wv_location_cd:",
      wv_location_cd))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - wv_position_cd:",
      wv_position_cd))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - active:",active))
    CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - version:",version))
   ENDIF
   INSERT  FROM working_view wv
    SET wv.working_view_id = view_id, wv.active_ind = active, wv.beg_effective_dt_tm = cnvtdatetime(
      curdate,curtime3),
     wv.current_working_view = currentid, wv.display_name = wv_display, wv.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100"),
     wv.location_cd = wv_location_cd, wv.position_cd = wv_position_cd, wv.version_num = version,
     wv.active_status_cd = cs48_active_cd, wv.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     wv.active_status_prsnl_id = reqinfo->updt_id,
     wv.updt_cnt = 0, wv.updt_dt_tm = cnvtdatetime(curdate,curtime3), wv.updt_id = reqinfo->updt_id,
     wv.updt_task = reqinfo->updt_task, wv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Could not insert view")
   IF (futureind=0)
    UPDATE  FROM cnt_wv_key
     SET dcp_wv_ref_id = view_id
     WHERE (working_view_uid=request->working_view_uid)
     WITH nocounter
    ;end update
   ENDIF
   CALL bedaddlogstologgerfile(build2(
     "### Inside insertWorkingView - inserted into working_view table for view:",wv_display))
   SET scnt = size(request->sections,5)
   FOR (y = 1 TO scnt)
     SET section_id = next_id(0)
     INSERT  FROM working_view_section w
      SET w.working_view_section_id = section_id, w.working_view_id = view_id, w.event_set_name =
       request->sections[y].event_set_name,
       w.required_ind = request->sections[y].required_ind, w.included_ind = request->sections[y].
       included_ind, w.falloff_view_minutes = request->sections[y].falloff_view_minutes,
       w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime3), w.updt_task =
       reqinfo->updt_task,
       w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0, w.section_type_flag = request->
       sections[y].section_type_flag,
       w.display_name = request->sections[y].display_name
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Could not insert section")
     CALL bedaddlogstologgerfile(build2("###inserted into working_view_section table for section: ",
       request->sections[y].wv_section_uid))
     IF (futureind=0)
      UPDATE  FROM cnt_wv_section_key cs
       SET cs.dcp_wv_section_ref_id = section_id
       WHERE (cs.wv_section_uid=request->sections[y].wv_section_uid)
       WITH nocounter
      ;end update
      CALL bederrorcheck("Could not update section")
      CALL bedaddlogstologgerfile(build2("###futureInd is 0-cnt_wv_section_key updated for section:",
        request->sections[y].wv_section_uid))
     ENDIF
     SET icnt = size(request->sections[y].items,5)
     FOR (z = 1 TO icnt)
       SET item_id = next_id(0)
       CALL bedaddlogstologgerfile(build2("### Inside insertWorkingView - item_id:",item_id))
       INSERT  FROM working_view_item w
        SET w.working_view_item_id = item_id, w.working_view_section_id = section_id, w
         .primitive_event_set_name = request->sections[y].items[z].primitive_event_set_name,
         w.parent_event_set_name =
         IF ((request->sections[y].items[z].parent_event_set_name > " ")) request->sections[y].items[
          z].parent_event_set_name
         ELSE request->sections[y].event_set_name
         ENDIF
         , w.included_ind = request->sections[y].items[z].included_ind, w.updt_id = reqinfo->updt_id,
         w.updt_dt_tm = cnvtdatetime(curdate,curtime3), w.updt_task = reqinfo->updt_task, w
         .updt_applctx = reqinfo->updt_applctx,
         w.updt_cnt = 0, w.falloff_view_minutes = request->sections[y].items[z].falloff_view_minutes
        WITH nocounter
       ;end insert
       CALL bederrorcheck("Could not insert item")
       CALL bedaddlogstologgerfile(build2("###inserted into working_view_item table for item:",
         request->sections[y].items[z].wv_item_uid))
       IF (futureind=0)
        UPDATE  FROM cnt_wv_item_key ci
         SET ci.dcp_wv_item_ref_id = item_id
         WHERE (ci.wv_item_uid=request->sections[y].items[z].wv_item_uid)
         WITH nocounter
        ;end update
        CALL bederrorcheck("Could not update item")
        CALL bedaddlogstologgerfile(build2("###futureInd:0 -working_view_item updated for item:",
          request->sections[y].items[z].wv_item_uid))
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(true)
   CALL bedaddlogstologgerfile("### Exiting insertWorkingView ...")
 END ;Subroutine
 SUBROUTINE next_id(next_id_dummy)
   CALL bedaddlogstologgerfile("### Entering next_id ...")
   CALL bedaddlogstologgerfile(build2("### Inside next_id - next_id_dummy:",next_id_dummy))
   SET new_id = 0.0
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   RETURN(new_id)
   CALL bedaddlogstologgerfile(build2("### Inside next_id - new_id:",new_id))
   CALL bedaddlogstologgerfile("### Exiting next_id ...")
 END ;Subroutine
 SUBROUTINE loadexistingdetails(dcp_id)
   CALL bedaddlogstologgerfile("### Entering loadExistingDetails ...")
   CALL bedaddlogstologgerfile(build2("### Inside loadExistingDetails - dcp_id:",dcp_id))
   DECLARE wvs_cnt = i4 WITH protect, noconstant(0)
   DECLARE wvi_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM working_view wv,
     working_view_section wvs,
     working_view_item wvi
    PLAN (wv
     WHERE wv.working_view_id=dcp_id)
     JOIN (wvs
     WHERE wvs.working_view_id=wv.working_view_id)
     JOIN (wvi
     WHERE wvi.working_view_section_id=wvs.working_view_section_id)
    ORDER BY wvs.working_view_section_id, wvi.working_view_item_id
    HEAD wvs.working_view_section_id
     wvi_cnt = 0, wvs_cnt = (wvs_cnt+ 1), stat = alterlist(existingdetails->working_view_sections,
      wvs_cnt),
     existingdetails->working_view_sections[wvs_cnt].working_view_section_id = wvs
     .working_view_section_id, existingdetails->working_view_sections[wvs_cnt].display_name = wvs
     .display_name, existingdetails->working_view_sections[wvs_cnt].event_set_name = wvs
     .event_set_name,
     existingdetails->working_view_sections[wvs_cnt].included_ind = wvs.included_ind, existingdetails
     ->working_view_sections[wvs_cnt].required_ind = wvs.required_ind, existingdetails->
     working_view_sections[wvs_cnt].section_type_flag = wvs.section_type_flag
    HEAD wvi.working_view_item_id
     wvi_cnt = (wvi_cnt+ 1), stat = alterlist(existingdetails->working_view_sections[wvs_cnt].
      working_view_items,wvi_cnt), existingdetails->working_view_sections[wvs_cnt].
     working_view_items[wvi_cnt].working_view_item_id = wvi.working_view_item_id,
     existingdetails->working_view_sections[wvs_cnt].working_view_items[wvi_cnt].falloff_view_minutes
      = wvi.falloff_view_minutes, existingdetails->working_view_sections[wvs_cnt].working_view_items[
     wvi_cnt].included_ind = wvi.included_ind, existingdetails->working_view_sections[wvs_cnt].
     working_view_items[wvi_cnt].parent_event_set_name = wvi.parent_event_set_name,
     existingdetails->working_view_sections[wvs_cnt].working_view_items[wvi_cnt].
     primitive_event_set_name = wvi.primitive_event_set_name
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not retrieve exist details")
   CALL bedaddlogstologgerfile("### Exiting loadExistingDetails ...")
 END ;Subroutine
 SUBROUTINE comparedetails(dummyvar)
   CALL bedaddlogstologgerfile("### Entering compareDetails ...")
   DECLARE importedsectionsize = i4 WITH protect, constant(size(request->sections,5))
   DECLARE existingsectionsize = i4 WITH protect, constant(size(existingdetails->
     working_view_sections,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE itemfoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   CALL bedaddlogstologgerfile(build2("### Inside compareDetails - importedSectionSize:",
     importedsectionsize))
   CALL bedaddlogstologgerfile(build2("### Inside compareDetails - existingSectionSize:",
     existingsectionsize))
   FOR (eidx = 1 TO importedsectionsize)
     IF ((request->sections[eidx].ignore_ind=1))
      SET num = 1
      SET foundidx = locateval(num,1,existingsectionsize,request->sections[eidx].
       dcp_wv_section_ref_id,existingdetails->working_view_sections[num].working_view_section_id)
      IF (foundidx=0)
       SET num = 1
       SET foundidx = locateval(num,1,existingsectionsize,request->sections[eidx].event_set_name,
        existingdetails->working_view_sections[num].event_set_name)
      ENDIF
      IF (foundidx > 0)
       SET request->sections[eidx].event_set_name = existingdetails->working_view_sections[foundidx].
       event_set_name
       SET request->sections[eidx].display_name = existingdetails->working_view_sections[foundidx].
       display_name
       SET request->sections[eidx].required_ind = existingdetails->working_view_sections[foundidx].
       required_ind
       SET request->sections[eidx].included_ind = existingdetails->working_view_sections[foundidx].
       included_ind
       FOR (itemidx = 1 TO size(request->sections[eidx].items,5))
         IF ((request->sections[eidx].items[itemidx].ignore_ind=1))
          SET num1 = 1
          SET itemfoundidx = locateval(num1,1,size(existingdetails->working_view_sections[foundidx].
            working_view_items,5),request->sections[eidx].items[itemidx].dcp_wv_item_ref_id,
           existingdetails->working_view_sections[foundidx].working_view_items[num1].
           working_view_item_id)
          IF (itemfoundidx=0)
           SET num1 = 1
           SET itemfoundidx = locateval(num1,1,size(existingdetails->working_view_sections[foundidx].
             working_view_items,5),request->sections[eidx].items[itemidx].primitive_event_set_name,
            existingdetails->working_view_sections[foundidx].working_view_items[num1].
            primitive_event_set_name)
          ENDIF
          IF (itemfoundidx > 0)
           SET request->sections[eidx].items[itemidx].primitive_event_set_name = existingdetails->
           working_view_sections[foundidx].working_view_items[itemfoundidx].primitive_event_set_name
           SET request->sections[eidx].items[itemidx].included_ind = existingdetails->
           working_view_sections[foundidx].working_view_items[itemfoundidx].included_ind
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   CALL bedaddlogstologgerfile("### Exiting compareDetails ...")
 END ;Subroutine
END GO
