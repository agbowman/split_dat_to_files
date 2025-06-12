CREATE PROGRAM bed_ens_provider_enrollment:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 provider_list[*]
      2 provider_enrollment_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD provider_request(
   1 provider_list[*]
     2 provider_enrollment_id = f8
     2 prsnl_id = f8
     2 location_cd = f8
     2 payer_org_id = f8
     2 health_plan_id = f8
     2 priority_seq = i4
     2 bill_type_flag = i2
     2 participation_status_cd = f8
     2 comments = vc
     2 comment_ind = i2
     2 timely_filling_dt_tm = dq8
     2 process_beg_effective_dt_tm = dq8
     2 process_end_effective_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_ind = i2
     2 paperwork_submitted_dt_tm = dq8
     2 paperwork_acknowledged_dt_tm = dq8
     2 priority_seq_requested_ind = i2
     2 ins_at_provider_enrollment_id = f8
 ) WITH protect
 RECORD dup_req_indexs(
   1 indexes[*]
     2 index = i4
 ) WITH protect
 RECORD provider_reply(
   1 provider_list[*]
     2 provider_enrollment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
 IF ( NOT (validate(wf_save_task_ident)))
  DECLARE wf_save_task_ident = vc WITH protect, constant("PFT_WF_CMPLT_CRDNTL_EDIT_FAIL")
 ENDIF
 IF ( NOT (validate(wf_save_task_entity)))
  DECLARE wf_save_task_entity = vc WITH protect, constant("PROVIDER_ENROLLMENT")
 ENDIF
 DECLARE provider_enrollment_collector_id = vc WITH protect, constant("2015.2.00222.4")
 DECLARE isnewprovider(null) = i2
 DECLARE addnewprovider(null) = i2
 DECLARE updateprovider(null) = i2
 DECLARE removeprovider(null) = i2
 DECLARE populateproviders(null) = null
 DECLARE addcomment(pe_id=f8,index=i4) = i2
 DECLARE logprovenrollcapability(null) = null
 DECLARE getmaxlocpriorityseq(null) = null
 DECLARE compresslocationpriorityseq(null) = i2
 DECLARE expandlocationpriorityseq(null) = i2
 DECLARE addproviderenrollmenttask(null) = i2
 DECLARE getnextpriorityseq(null) = i2
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE req_cnt = i4 WITH protect, noconstant(0)
 IF ((request->action_ind=0))
  IF (isnewprovider(null))
   CALL bedlogmessage("isNewProvider","Unique records exists")
   DECLARE provider_count = i4 WITH protect, noconstant(0)
   IF (addnewprovider(null))
    CALL bedlogmessage("addNewProvider","Providers added successfully")
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "S"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
    SET stat = alterlist(reply->provider_list,size(provider_reply->provider_list,5))
    FOR (provider_count = 1 TO size(reply->provider_list,5))
      SET reply->provider_list[provider_count].provider_enrollment_id = provider_reply->
      provider_list[provider_count].provider_enrollment_id
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
    CALL bederror("Failed to add Providers")
    SET provider_count = 0
    SET stat = alterlist(reply->provider_list,size(provider_reply->provider_list,5))
    FOR (provider_count = 1 TO size(reply->provider_list,5))
      SET reply->provider_list[provider_count].provider_enrollment_id = provider_reply->
      provider_list[provider_count].provider_enrollment_id
    ENDFOR
   ENDIF
  ELSE
   CALL bedlogmessage("isNewProvider","Duplicate records found")
   DECLARE str1 = vc WITH protect
   SET stat = alterlist(reply->provider_list,size(request->provider_list,5))
   FOR (i = 1 TO size(reply->provider_list,5))
     SET str2 = cnvtstring(provider_reply->provider_list[i].provider_enrollment_id)
   ENDFOR
   SET str1 = "Duplicate record found"
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
   GO TO exit_script
  ENDIF
  CALL logprovenrollcapability(null)
 ENDIF
 IF ((request->action_ind=1))
  IF ( NOT (updateprovider(null)))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
   SET stat = alterlist(reply->provider_list,size(request->provider_list,5))
   SET req_cnt = 0
   FOR (i = 1 TO size(reply->provider_list,5))
     IF (expand(num,1,size(dup_req_indexs->indexes,5),i,dup_req_indexs->indexes[num].index))
      SET req_cnt = (req_cnt+ 1)
      SET reply->provider_list[req_cnt].provider_enrollment_id = request->provider_list[i].
      provider_enrollment_id
     ENDIF
   ENDFOR
   CALL bederror("Failed to update Providers")
  ELSE
   IF (addproviderenrollmenttask(null))
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "S"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
    CALL bederror("Failed to insert to workflow_task_queue table")
   ENDIF
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
   SET stat = alterlist(reply->provider_list,size(request->provider_list,5))
   SET rep_cnt = 0
   FOR (i = 1 TO size(reply->provider_list,5))
     IF ( NOT (expand(num,1,size(dup_req_indexs->indexes,5),i,dup_req_indexs->indexes[num].index)))
      SET rep_cnt = (rep_cnt+ 1)
      SET reply->provider_list[rep_cnt].provider_enrollment_id = request->provider_list[i].
      provider_enrollment_id
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->provider_list,rep_cnt)
  ENDIF
  CALL logprovenrollcapability(null)
 ENDIF
 IF ((request->action_ind=2))
  IF (compresslocationpriorityseq(null))
   IF ( NOT (removeprovider(null)))
    DECLARE str1 = vc WITH protect
    DECLARE str2 = vc WITH protect
    SET stat = alterlist(reply->provider_list,size(request->provider_list,5))
    FOR (i = 1 TO size(reply->provider_list,5))
      SET reply->provider_list[i].provider_enrollment_id = request->provider_list[i].
      provider_enrollment_id
    ENDFOR
    SET stat = alterlist(reply->provider_list,size(request->provider_list,5))
    FOR (i = 1 TO size(reply->provider_list,5))
     SET reply->provider_list[i].provider_enrollment_id = request->provider_list[i].
     provider_enrollment_id
     SET str2 = cnvtstring(reply->provider_list[i].provider_enrollment_id)
    ENDFOR
    SET str1 = "not found"
    SET str2 = concat(str2," ",str1)
    CALL bederror(str2)
   ELSE
    IF (addproviderenrollmenttask(null))
     SET reply->status_data.status = "S"
     SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     SET reply->status_data.subeventstatus[1].operationstatus = "S"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
     CALL bederror("Failed to insert to workflow_task_queue table")
    ENDIF
   ENDIF
  ELSE
   CALL bederror("Failed to update location priority sequence for Providers")
  ENDIF
  CALL logprovenrollcapability(null)
 ENDIF
 FOR (j = 1 TO size(provider_request->provider_list,5))
   IF ((provider_request->provider_list[j].comment_ind=true))
    IF ( NOT (addcomment(provider_reply->provider_list[j].provider_enrollment_id,j)))
     CALL bederror("Failed to add comment")
    ENDIF
   ENDIF
 ENDFOR
 CALL bedexitscript(1)
#exit_script
 CALL echorecord(reply)
 SUBROUTINE isnewprovider(null)
   CALL bedlogmessage("isNewProvider","Entering")
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   DECLARE dup_count = i4 WITH protect, noconstant(0)
   DECLARE req_beg_effective_dt_tm = dq8 WITH protect, noconstant(null)
   DECLARE req_end_effective_dt_tm = dq8 WITH protect, noconstant(null)
   DECLARE enroll_end_effective_dt_tm = dq8 WITH protect, noconstant(null)
   DECLARE enroll_beg_effective_dt_tm = dq8 WITH protect, noconstant(null)
   DECLARE magic_begin_date = dq8 WITH protect, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
   DECLARE magic_end_date = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 23:59:59.00"))
   DECLARE rep_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->provider_list,5)),
     provider_enrollment pe
    PLAN (d)
     JOIN (pe
     WHERE (pe.prsnl_id=request->provider_list[d.seq].prsnl_id)
      AND (pe.location_cd=request->provider_list[d.seq].location_cd)
      AND (pe.health_plan_id=request->provider_list[d.seq].health_plan_id)
      AND (pe.payer_org_id=request->provider_list[d.seq].payer_org_id)
      AND pe.active_ind=1)
    HEAD REPORT
     dup_count = 0, stat = alterlist(dup_req_indexs->indexes,size(request->provider_list,5))
    DETAIL
     enroll_beg_effective_dt_tm = magic_begin_date, enroll_end_effective_dt_tm = magic_end_date,
     req_beg_effective_dt_tm = magic_begin_date,
     req_end_effective_dt_tm = magic_end_date
     IF (pe.enroll_beg_effective_dt_tm != null)
      enroll_beg_effective_dt_tm = pe.enroll_beg_effective_dt_tm
     ENDIF
     IF (pe.enroll_end_effective_dt_tm != null)
      enroll_end_effective_dt_tm = pe.enroll_end_effective_dt_tm
     ENDIF
     IF ((request->provider_list[d.seq].beg_effective_dt_tm != null))
      req_beg_effective_dt_tm = request->provider_list[d.seq].beg_effective_dt_tm
     ENDIF
     IF ((request->provider_list[d.seq].end_effective_dt_tm != null))
      req_end_effective_dt_tm = request->provider_list[d.seq].end_effective_dt_tm
     ENDIF
     IF (((cnvtdatetime(req_beg_effective_dt_tm) >= cnvtdatetime(enroll_beg_effective_dt_tm)
      AND cnvtdatetime(req_beg_effective_dt_tm) <= cnvtdatetime(enroll_end_effective_dt_tm)) OR (((
     cnvtdatetime(req_end_effective_dt_tm) >= cnvtdatetime(enroll_beg_effective_dt_tm)
      AND cnvtdatetime(req_end_effective_dt_tm) <= cnvtdatetime(enroll_end_effective_dt_tm)) OR (
     cnvtdatetime(req_beg_effective_dt_tm) < cnvtdatetime(enroll_beg_effective_dt_tm)
      AND cnvtdatetime(req_end_effective_dt_tm) > cnvtdatetime(enroll_end_effective_dt_tm))) )) )
      IF ( NOT (expand(num,1,size(dup_req_indexs->indexes,5),d.seq,dup_req_indexs->indexes[num].index
       )))
       dup_count = (dup_count+ 1), dup_req_indexs->indexes[dup_count].index = d.seq
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dup_req_indexs->indexes,dup_count)
    WITH nocounter
   ;end select
   IF (dup_count=size(request->provider_list,5))
    SET status_ind = false
   ELSE
    SET status_ind = true
   ENDIF
   CALL bedlogmessage("isNewProvider","Exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE addnewprovider(null)
   CALL bedlogmessage("addNewProvider","Entering")
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   CALL populateproviders(null)
   IF (size(request->provider_list,5) > 0)
    EXECUTE bed_da_add_provider_enrollment  WITH replace("REQUEST",provider_request), replace("REPLY",
     provider_reply)
   ELSE
    CALL bedlogmessage("populateProviders","Zero provider records populated")
   ENDIF
   IF (cnvtupper(provider_reply->status_data.status)="S")
    SET status_ind = true
   ENDIF
   FOR (i = 1 TO size(provider_request->provider_list,5))
     IF (textlen(provider_request->provider_list[i].comments) > 0)
      SET provider_request->provider_list[i].comment_ind = true
     ENDIF
   ENDFOR
   CALL expandlocationpriorityseq(null)
   CALL bedlogmessage("addNewProvider","Exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE updateprovider(null)
   CALL bedlogmessage("updateProvider","Entering")
   DECLARE enroll_id = i4 WITH protect, noconstant(0)
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   DECLARE record_found = i2 WITH protect, noconstant(false)
   IF (size(request->provider_list,5) > 0)
    UPDATE  FROM provider_enrollment pe
     SET pe.active_ind = false, pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_id = reqinfo->updt_id,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE expand(enroll_id,1,size(request->provider_list,5),pe.provider_enrollment_id,request->
      provider_list[enroll_id].provider_enrollment_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET record_found = false
    ELSE
     SET record_found = true
    ENDIF
    IF ((request->action_ind=1)
     AND record_found=true)
     IF (isnewprovider(null))
      CALL populateproviders(null)
      IF (size(provider_request->provider_list,5) > 0)
       EXECUTE bed_da_add_provider_enrollment  WITH replace("REQUEST",provider_request), replace(
        "REPLY",provider_reply)
       IF (cnvtupper(provider_reply->status_data.status)="S")
        SET status_ind = true
       ENDIF
       FOR (i = 1 TO size(provider_request->provider_list,5))
         IF (textlen(provider_request->provider_list[i].comments) > 0)
          SET provider_request->provider_list[i].comment_ind = true
         ENDIF
       ENDFOR
      ELSE
       CALL bedlogmessage("updateProvider","Zero records to update")
       SET status_ind = false
      ENDIF
     ELSE
      SET reply->status_data.status = "Z"
      SET reply->status_data.subeventstatus[1].operationname = "Udate"
      SET reply->status_data.subeventstatus[1].operationstatus = "Z"
      SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROVIDER_ENROLLMENT"
      GO TO exit_script
     ENDIF
    ELSE
     IF (record_found)
      SET status_ind = true
     ELSE
      SET status_ind = false
      CALL bedlogmessage("Provider info not found","1")
     ENDIF
    ENDIF
   ENDIF
   CALL bedlogmessage("updateProvider","Exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE removeprovider(null)
   CALL bedlogmessage("removeProvider","Entering")
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   IF (size(request->provider_list,5) > 0)
    IF (updateprovider(null))
     SET status_ind = true
    ENDIF
   ELSE
    CALL bedlogmessage("removeProvider","Zero provider records removed")
    SET status_ind = false
   ENDIF
   CALL bedlogmessage("removeProvider","Exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE populateproviders(null)
   CALL bedlogmessage("populateProviders","entering")
   DECLARE add_count = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->provider_list,5))
    HEAD REPORT
     stat = alterlist(provider_request->provider_list,10), add_count = 0
    DETAIL
     IF ( NOT (expand(iterator,1,size(dup_req_indexs->indexes,5),d.seq,dup_req_indexs->indexes[
      iterator].index)))
      add_count = (add_count+ 1)
      IF (mod(add_count,10)=1
       AND add_count > 10)
       stat = alterlist(provider_request->provider_list,(add_count+ 9))
      ENDIF
      provider_request->provider_list[add_count].prsnl_id = request->provider_list[d.seq].prsnl_id,
      provider_request->provider_list[add_count].location_cd = request->provider_list[d.seq].
      location_cd, provider_request->provider_list[add_count].bill_type_flag = request->
      provider_list[d.seq].bill_type_flag,
      provider_request->provider_list[add_count].health_plan_id = request->provider_list[d.seq].
      health_plan_id, provider_request->provider_list[add_count].payer_org_id = request->
      provider_list[d.seq].payer_org_id
      IF ((request->action_ind=0)
       AND (request->provider_list[d.seq].priority_seq > 0))
       provider_request->provider_list[add_count].priority_seq_requested_ind = 1
      ENDIF
      provider_request->provider_list[add_count].priority_seq = evaluate(request->provider_list[d.seq
       ].priority_seq,0,1,request->provider_list[d.seq].priority_seq), provider_request->
      provider_list[add_count].participation_status_cd = request->provider_list[d.seq].
      participation_status_cd, provider_request->provider_list[add_count].beg_effective_dt_tm =
      request->provider_list[d.seq].beg_effective_dt_tm,
      provider_request->provider_list[add_count].end_effective_dt_tm = request->provider_list[d.seq].
      end_effective_dt_tm, provider_request->provider_list[add_count].timely_filling_dt_tm = request
      ->provider_list[d.seq].timely_filling_dt_tm, provider_request->provider_list[add_count].
      process_beg_effective_dt_tm = request->provider_list[d.seq].process_beg_effective_dt_tm,
      provider_request->provider_list[add_count].process_end_effective_dt_tm = request->
      provider_list[d.seq].process_end_effective_dt_tm, provider_request->provider_list[add_count].
      comments = request->provider_list[d.seq].comments, provider_request->provider_list[add_count].
      active_ind = true,
      provider_request->provider_list[add_count].paperwork_submitted_dt_tm = request->provider_list[d
      .seq].paperwork_submitted_dt_tm, provider_request->provider_list[add_count].
      paperwork_acknowledged_dt_tm = request->provider_list[d.seq].paperwork_acknowledged_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(provider_request->provider_list,add_count)
    WITH nocounter
   ;end select
   IF ((request->action_ind=0))
    CALL getnextpriorityseq(null)
    CALL getmaxlocpriorityseq(null)
   ENDIF
   CALL bedlogmessage("populateProviders","exiting")
 END ;Subroutine
 SUBROUTINE addcomment(pe_id,index)
   CALL bedlogmessage("addComment","entering")
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   RECORD req_apply_comment_charge(
     1 comment_text = vc
     1 related_id_list[*]
       2 related_id = f8
       2 related_vrsn_nbr = i4
       2 class_desc = i4
     1 importance_flag = i2
     1 comment_date = dq8
     1 reason_cd = f8
   ) WITH protect
   RECORD add_comment_reply(
     1 pft_status_data
       2 status = c1
       2 subeventstatus[*]
         3 status = c1
         3 table_name = vc
         3 pk_values = vc
     1 mod_objs[*]
       2 entity_type = vc
       2 mod_recs[*]
         3 table_name = vc
         3 pk_values = vc
         3 mod_flds[*]
           4 field_name = vc
           4 field_type = vc
           4 field_value_obj = vc
           4 field_value_db = vc
     1 failure_stack
       2 failures[*]
         3 programname = vc
         3 routinename = vc
         3 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET stat = alterlist(req_apply_comment_charge->related_id_list,1)
   SET req_apply_comment_charge->related_id_list[1].related_id = pe_id
   SET req_apply_comment_charge->related_id_list[1].class_desc = 20
   SET req_apply_comment_charge->comment_text = provider_request->provider_list[index].comments
   EXECUTE pft_add_comment  WITH replace("REQUEST",req_apply_comment_charge), replace("REPLY",
    add_comment_reply)
   IF (cnvtupper(add_comment_reply->status_data.status)="S")
    CALL bedlogmessage("addComment","Commented Successfully")
    SET status_ind = true
   ELSE
    CALL bedlogmessage("addComment","Failure while commenting")
    CALL bedexitscript(0)
   ENDIF
   CALL bedlogmessage("addComment","exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE logprovenrollcapability(null)
   CALL bedlogmessage("logProvEnrollCapability","entering")
   DECLARE entity_count = i4 WITH protect, noconstant(0)
   RECORD capabilitylogrequest(
     1 capability_ident = vc
     1 teamname = vc
     1 entities[*]
       2 entity_id = f8
       2 entity_name = vc
   ) WITH protect
   RECORD capabilitylogreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET capabilitylogrequest->capability_ident = provider_enrollment_collector_id
   SET capabilitylogrequest->teamname = "BEDROCK"
   SET stat = alterlist(capabilitylogrequest->entities,size(request->provider_list,5))
   FOR (entity_count = 1 TO size(request->provider_list,5))
    SET capabilitylogrequest->entities[entity_count].entity_id = request->provider_list[entity_count]
    .location_cd
    SET capabilitylogrequest->entities[entity_count].entity_name = "LOCATION_CD"
   ENDFOR
   CALL echorecord(capabilitylogrequest)
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace("REPLY",
    capabilitylogreply)
   IF ((capabilitylogreply->status_data.status != "S"))
    CALL bedlogmessage("logProvEnrollCapability","failed to log in pft_log_solution_capability")
   ENDIF
   CALL bedlogmessage("logProvEnrollCapability","exiting")
 END ;Subroutine
 SUBROUTINE getmaxlocpriorityseq(null)
   CALL bedlogmessage("getMaxLocPrioritySeq","entering")
   RECORD max_priority_sequence(
     1 sequence_list[*]
       2 location_cd = f8
       2 lastpriorityseq = i4
   ) WITH protect
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE findindex = i4 WITH protect, noconstant(0)
   DECLARE indexofloc = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM provider_enrollment p,
     (dummyt d  WITH seq = size(provider_request->provider_list,5))
    PLAN (d)
     JOIN (p
     WHERE (p.location_cd=provider_request->provider_list[d.seq].location_cd)
      AND p.active_ind=1
      AND (provider_request->provider_list[d.seq].priority_seq_requested_ind=0))
    ORDER BY p.location_cd DESC, p.location_priority_seq DESC
    HEAD REPORT
     index = 0
    HEAD p.location_cd
     index = (index+ 1), stat = alterlist(max_priority_sequence->sequence_list,index),
     max_priority_sequence->sequence_list[index].location_cd = p.location_cd,
     max_priority_sequence->sequence_list[index].lastpriorityseq = p.location_priority_seq
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(provider_request->provider_list,5))
     IF ((provider_request->provider_list[i].priority_seq_requested_ind=0))
      SET findindex = 0
      SET indexofloc = 0
      SET indexofloc = locateval(findindex,1,size(max_priority_sequence->sequence_list,5),
       provider_request->provider_list[i].location_cd,max_priority_sequence->sequence_list[findindex]
       .location_cd)
      IF (indexofloc=0)
       SET stat = alterlist(max_priority_sequence->sequence_list,(size(max_priority_sequence->
         sequence_list,5)+ 1))
       SET max_priority_sequence->sequence_list[size(max_priority_sequence->sequence_list,5)].
       location_cd = provider_request->provider_list[i].location_cd
       SET max_priority_sequence->sequence_list[size(max_priority_sequence->sequence_list,5)].
       lastpriorityseq = 1
       SET provider_request->provider_list[i].priority_seq = max_priority_sequence->sequence_list[
       size(max_priority_sequence->sequence_list,5)].lastpriorityseq
      ELSE
       SET max_priority_sequence->sequence_list[indexofloc].lastpriorityseq = (max_priority_sequence
       ->sequence_list[indexofloc].lastpriorityseq+ 1)
       SET provider_request->provider_list[i].priority_seq = max_priority_sequence->sequence_list[
       indexofloc].lastpriorityseq
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("getMaxLocPrioritySeq","exiting")
 END ;Subroutine
 SUBROUTINE getnextpriorityseq(null)
   CALL bedlogmessage("getNextPrioritySeq","entering")
   RECORD next_priority_sequence(
     1 next_sequence_list[*]
       2 location_cd = f8
       2 lastpriorityseq = i4
   ) WITH protect
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE findindex = i4 WITH protect, noconstant(0)
   DECLARE indexofloc = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM provider_enrollment p,
     (dummyt d  WITH seq = size(provider_request->provider_list,5))
    PLAN (d)
     JOIN (p
     WHERE (p.location_cd=provider_request->provider_list[d.seq].location_cd)
      AND p.active_ind=1
      AND (provider_request->provider_list[d.seq].priority_seq_requested_ind=1))
    ORDER BY p.location_cd DESC, p.location_priority_seq DESC
    HEAD REPORT
     index = 0
    HEAD p.location_cd
     index = (index+ 1), stat = alterlist(next_priority_sequence->next_sequence_list,index),
     next_priority_sequence->next_sequence_list[index].location_cd = p.location_cd,
     next_priority_sequence->next_sequence_list[index].lastpriorityseq = p.location_priority_seq
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM provider_enrollment p,
     (dummyt d  WITH seq = size(provider_request->provider_list,5))
    PLAN (d)
     JOIN (p
     WHERE (p.location_cd=provider_request->provider_list[d.seq].location_cd)
      AND p.active_ind=1
      AND p.location_priority_seq IN (provider_request->provider_list[d.seq].priority_seq, (
     provider_request->provider_list[d.seq].priority_seq+ 1))
      AND (provider_request->provider_list[d.seq].priority_seq_requested_ind=1))
    ORDER BY d.seq, p.location_priority_seq
    HEAD d.seq
     priority_seq = provider_request->provider_list[d.seq].priority_seq
    DETAIL
     IF ((p.location_priority_seq=provider_request->provider_list[d.seq].priority_seq))
      priority_seq = (p.location_priority_seq+ 1)
     ELSEIF ((p.location_priority_seq=(provider_request->provider_list[d.seq].priority_seq+ 1))
      AND priority_seq=p.location_priority_seq)
      provider_request->provider_list[d.seq].ins_at_provider_enrollment_id = p.provider_enrollment_id
     ENDIF
    FOOT  d.seq
     provider_request->provider_list[d.seq].priority_seq = priority_seq
    WITH nocounter
   ;end select
   CALL bedlogmessage("getNextPrioritySeq","exiting")
 END ;Subroutine
 SUBROUTINE compresslocationpriorityseq(null)
   CALL bedlogmessage("compressLocationPrioritySeq","entering")
   RECORD enrollment_list_seq(
     1 provider_list[*]
       2 provider_enrollment_id = f8
   ) WITH protect
   DECLARE loc_priority_seq = i4 WITH protect, noconstant(0)
   DECLARE location_cd = f8 WITH protect, noconstant(0)
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   DECLARE enroll_count = i4 WITH protect, noconstant(0)
   SET status_ind = false
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->provider_list,5)),
     provider_enrollment p
    PLAN (d)
     JOIN (p
     WHERE (p.provider_enrollment_id=request->provider_list[d.seq].provider_enrollment_id))
    ORDER BY p.location_priority_seq
    HEAD REPORT
     enroll_count = 0
    DETAIL
     enroll_count = (enroll_count+ 1)
     IF (mod(enroll_count,10)=1)
      stat = alterlist(enrollment_list_seq->provider_list,(enroll_count+ 9))
     ENDIF
     enrollment_list_seq->provider_list[enroll_count].provider_enrollment_id = p
     .provider_enrollment_id
    FOOT REPORT
     stat = alterlist(enrollment_list_seq->provider_list,enroll_count)
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(enrollment_list_seq->provider_list,5))
    SELECT INTO "nl:"
     FROM provider_enrollment p
     WHERE (p.provider_enrollment_id=enrollment_list_seq->provider_list[i].provider_enrollment_id)
     DETAIL
      loc_priority_seq = p.location_priority_seq, location_cd = p.location_cd
     WITH nocounter
    ;end select
    IF (loc_priority_seq > 0)
     UPDATE  FROM provider_enrollment p
      SET p.location_priority_seq = (p.location_priority_seq - 1)
      WHERE p.location_cd=location_cd
       AND p.location_priority_seq > loc_priority_seq
       AND p.active_ind=1
     ;end update
     IF (curqual > 0)
      SET status_ind = true
     ENDIF
    ENDIF
   ENDFOR
   IF (loc_priority_seq > 0)
    SET status_ind = true
   ENDIF
   CALL bedlogmessage("compressLocationPrioritySeq","exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE expandlocationpriorityseq(null)
   CALL bedlogmessage("expandLocationPrioritySeq","entering")
   RECORD enrollment_list_seq(
     1 provider_list[*]
       2 provider_enrollment_id = f8
   ) WITH protect
   DECLARE loc_priority_seq = i4 WITH protect, noconstant(0)
   DECLARE location_cd = f8 WITH protect, noconstant(0)
   DECLARE status_ind = i2 WITH protect, noconstant(false)
   DECLARE enroll_count = i4 WITH protect, noconstant(0)
   SET status_ind = false
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(provider_request->provider_list,5)),
     provider_enrollment p
    PLAN (d)
     JOIN (p
     WHERE (p.provider_enrollment_id=provider_request->provider_list[d.seq].
     ins_at_provider_enrollment_id)
      AND (provider_request->provider_list[d.seq].ins_at_provider_enrollment_id > 0))
    ORDER BY p.location_priority_seq DESC
    HEAD REPORT
     enroll_count = 0
    DETAIL
     enroll_count = (enroll_count+ 1)
     IF (mod(enroll_count,10)=1)
      stat = alterlist(enrollment_list_seq->provider_list,(enroll_count+ 9))
     ENDIF
     enrollment_list_seq->provider_list[enroll_count].provider_enrollment_id = p
     .provider_enrollment_id
    FOOT REPORT
     stat = alterlist(enrollment_list_seq->provider_list,enroll_count)
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(enrollment_list_seq->provider_list,5))
    SELECT INTO "nl:"
     FROM provider_enrollment p
     WHERE (p.provider_enrollment_id=enrollment_list_seq->provider_list[i].provider_enrollment_id)
     DETAIL
      loc_priority_seq = p.location_priority_seq, location_cd = p.location_cd
     WITH nocounter
    ;end select
    IF (loc_priority_seq > 0)
     UPDATE  FROM provider_enrollment p
      SET p.location_priority_seq = (p.location_priority_seq+ 1)
      WHERE (((p.provider_enrollment_id=enrollment_list_seq->provider_list[i].provider_enrollment_id)
      ) OR (p.location_cd=location_cd
       AND p.location_priority_seq > loc_priority_seq
       AND p.active_ind=1))
     ;end update
     IF (curqual > 0)
      SET status_ind = true
     ENDIF
    ENDIF
   ENDFOR
   IF (loc_priority_seq > 0)
    SET status_ind = true
   ENDIF
   CALL bedlogmessage("expandLocationPrioritySeq","exiting")
   RETURN(status_ind)
 END ;Subroutine
 SUBROUTINE addproviderenrollmenttask(null)
   CALL bedlogmessage("addProviderEnrollmentTask","entering")
   RECORD wtptaskrequest(
     1 objarray[*]
       2 providerenrollmentid = f8
   ) WITH protect
   RECORD addtasktowtprequest(
     1 workflowtaskqueueid = f8
     1 requestjson = vc
     1 replyjson = vc
     1 requestlongtextid = f8
     1 replylongtextid = f8
     1 originaltaskqueueid = f8
     1 processdttm = dq8
     1 taskident = vc
     1 entityname = vc
     1 entityid = f8
     1 taskdatatxt = vc
     1 retrycount = i4
     1 queuestatuscd = f8
   ) WITH protect
   RECORD addtasktowtpreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   DECLARE peidx = i4 WITH protect, noconstant(0)
   DECLARE pecnt = i4 WITH protect, noconstant(size(request->provider_list,5))
   SET stat = alterlist(wtptaskrequest->objarray,pecnt)
   FOR (peidx = 1 TO pecnt)
     SET wtptaskrequest->objarray[peidx].providerenrollmentid = request->provider_list[peidx].
     provider_enrollment_id
   ENDFOR
   SET addtasktowtprequest->requestjson = cnvtrectojson(wtptaskrequest)
   SET addtasktowtprequest->processdttm = cnvtdatetime(curdate,curtime3)
   SET addtasktowtprequest->taskident = wf_save_task_ident
   SET addtasktowtprequest->entityname = wf_save_task_entity
   SET addtasktowtprequest->entityid = request->provider_list[1].provider_enrollment_id
   CASE (request->action_ind)
    OF 0:
     SET addtasktowtprequest->taskdatatxt = "PROVIDER_ENROLLMENT_ADDITION"
    OF 1:
     SET addtasktowtprequest->taskdatatxt = "PROVIDER_ENROLLMENT_UPDATE"
    OF 2:
     SET addtasktowtprequest->taskdatatxt = "PROVIDER_ENROLLMENT_DELETION"
   ENDCASE
   EXECUTE wtp_workflow_task_save  WITH replace("REQUEST",addtasktowtprequest), replace("REPLY",
    addtasktowtpreply)
   IF ((addtasktowtpreply->status_data.status != "S"))
    CALL bederror("Failed to add into workflow_task_queue table")
    RETURN(false)
   ENDIF
   CALL bedlogmessage("addProviderEnrollmentTask","exiting")
   RETURN(true)
 END ;Subroutine
END GO
