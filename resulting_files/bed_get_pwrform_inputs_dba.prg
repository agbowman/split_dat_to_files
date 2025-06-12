CREATE PROGRAM bed_get_pwrform_inputs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 inputs[*]
      2 input_ref_id = f8
      2 description = vc
      2 input_ref_seq = i4
      2 input_type = i4
      2 module = vc
      2 preferences[*]
        3 id = f8
        3 pvc_name = vc
        3 pvc_value = vc
        3 merge_name = vc
        3 merge_id = f8
        3 sequence = i4
        3 merge_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
 DECLARE getinputs(dummyvar=i2) = i2
 DECLARE populatemergedisplay(dummyvar=i2) = i2
 CALL getinputs(0)
 CALL populatemergedisplay(0)
 SUBROUTINE getinputs(dummyvar)
   CALL bedlogmessage("getInputs","Entering ...")
   SET icnt = 0
   SET pcnt = 0
   SELECT INTO "nl:"
    FROM dcp_section_ref s,
     dcp_input_ref i,
     name_value_prefs n
    PLAN (s
     WHERE (s.dcp_section_ref_id=request->dcp_section_ref_id)
      AND s.active_ind=1)
     JOIN (i
     WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
      AND i.active_ind=1)
     JOIN (n
     WHERE n.parent_entity_id=i.dcp_input_ref_id
      AND n.parent_entity_name="DCP_INPUT_REF"
      AND ((n.active_ind+ 0)=1))
    ORDER BY i.input_ref_seq, n.pvc_name, n.sequence
    HEAD i.dcp_input_ref_id
     pcnt = 0, icnt = (icnt+ 1), stat = alterlist(reply->inputs,icnt),
     reply->inputs[icnt].input_ref_id = i.dcp_input_ref_id, reply->inputs[icnt].description = i
     .description, reply->inputs[icnt].input_ref_seq = i.input_ref_seq,
     reply->inputs[icnt].input_type = i.input_type, reply->inputs[icnt].module = i.module
    DETAIL
     pcnt = (pcnt+ 1), stat = alterlist(reply->inputs[icnt].preferences,pcnt), reply->inputs[icnt].
     preferences[pcnt].id = n.name_value_prefs_id,
     reply->inputs[icnt].preferences[pcnt].pvc_name = n.pvc_name, reply->inputs[icnt].preferences[
     pcnt].pvc_value = n.pvc_value, reply->inputs[icnt].preferences[pcnt].merge_name = n.merge_name,
     reply->inputs[icnt].preferences[pcnt].merge_id = n.merge_id, reply->inputs[icnt].preferences[
     pcnt].sequence = n.sequence
    WITH nocounter
   ;end select
   CALL bedlogmessage("getInputs","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatemergedisplay(dummyvar)
   CALL bedlogmessage("populateMergeDisplay","Entering ...")
   FOR (i = 1 TO size(reply->inputs,5))
     FOR (p = 1 TO size(reply->inputs[i].preferences,5))
       IF ((reply->inputs[i].preferences[p].merge_id > 0))
        IF ((reply->inputs[i].preferences[p].merge_name="DISCRETE_TASK_ASSAY"))
         SELECT INTO "nl:"
          FROM discrete_task_assay dta
          PLAN (dta
           WHERE (dta.task_assay_cd=reply->inputs[i].preferences[p].merge_id))
          DETAIL
           reply->inputs[i].preferences[p].merge_display = dta.mnemonic
          WITH nocounter
         ;end select
        ENDIF
        IF ((reply->inputs[i].preferences[p].merge_name="V500_EVENT_CODE"))
         SELECT INTO "nl:"
          FROM v500_event_code e
          PLAN (e
           WHERE (e.event_cd=reply->inputs[i].preferences[p].merge_id))
          DETAIL
           reply->inputs[i].preferences[p].merge_display = e.event_cd_disp
          WITH nocounter
         ;end select
        ENDIF
        IF ((reply->inputs[i].preferences[p].merge_name="CODE_VALUE"))
         SELECT INTO "nl:"
          FROM code_value cv
          PLAN (cv
           WHERE (cv.code_value=reply->inputs[i].preferences[p].merge_id))
          DETAIL
           reply->inputs[i].preferences[p].merge_display = cv.display
          WITH nocounter
         ;end select
        ENDIF
        IF ((reply->inputs[i].preferences[p].merge_name="DCP_SECTION_REF"))
         SELECT INTO "nl:"
          FROM dcp_section_ref s
          PLAN (s
           WHERE (s.dcp_section_ref_id=reply->inputs[i].preferences[p].merge_id))
          DETAIL
           reply->inputs[i].preferences[p].merge_display = s.definition
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   CALL bedlogmessage("populateMergeDisplay","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
