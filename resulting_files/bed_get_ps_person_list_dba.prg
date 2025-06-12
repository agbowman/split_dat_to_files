CREATE PROGRAM bed_get_ps_person_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_list[*]
      2 person_id = f8
      2 name_full_formatted = vc
      2 username = vc
      2 apps[*]
        3 number = i4
        3 description = vc
      2 task[*]
        3 number = i4
        3 description = vc
        3 apps[*]
          4 number = i4
          4 description = vc
        3 no_conversation_ind = i2
        3 style_flag = i2
    1 too_many_results_ind = i2
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
 DECLARE plistparse = vc
 SET plistparse = "p.person_id > 0 and p.name_full_formatted > ' ' and p.active_ind = 1"
 IF ((request->name_last > " "))
  SET plistparse = concat(plistparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim(
       request->name_last)))),"*'")
 ENDIF
 IF ((request->name_first > " "))
  SET plistparse = concat(plistparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(trim
      (request->name_first)))),"*'")
 ENDIF
 IF ((request->username > " "))
  SET plistparse = concat(plistparse," and cnvtupper(p.username) = '",trim(cnvtupper(request->
     username)),"*'")
 ENDIF
 IF ((request->position_code_value > 0))
  SET plistparse = build(plistparse," and p.position_cd = ",request->position_code_value)
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET plistparse = concat(plistparse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET plistparse = build(plistparse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET plistparse = build(plistparse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET tcnt = 0
 SET overall_cnt = 0
 SET task_cnt = 0
 SET overall_stop_index = request->max_reply
 SELECT INTO "nl:"
  FROM prsnl p,
   pm_sch_setup ps,
   application a
  PLAN (p
   WHERE parser(plistparse))
   JOIN (ps
   WHERE ps.person_id=p.person_id)
   JOIN (a
   WHERE a.application_number=ps.application_number
    AND a.active_ind=1)
  ORDER BY p.name_full_formatted, p.person_id, ps.task_number,
   a.application_number
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->prsnl_list,100)
  HEAD p.person_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->prsnl_list,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->prsnl_list[tcnt].person_id = p.person_id, reply->prsnl_list[tcnt].name_full_formatted = p
   .name_full_formatted, reply->prsnl_list[tcnt].username = p.username,
   pcnt = 0, ptcnt = 0, tncnt = 0,
   ncnt = 0, stat = alterlist(reply->prsnl_list[tcnt].apps,100), stat = alterlist(reply->prsnl_list[
    tcnt].task,100)
  HEAD ps.task_number
   IF (ps.task_number > 0)
    ncnt = (ncnt+ 1), tncnt = (tncnt+ 1)
    IF (ncnt > 100)
     stat = alterlist(reply->prsnl_list[tcnt].task,(tncnt+ 100)), ncnt = 1
    ENDIF
    reply->prsnl_list[tcnt].task[tncnt].number = ps.task_number, reply->prsnl_list[tcnt].task[tncnt].
    style_flag = ps.style_flag
   ENDIF
  HEAD a.application_number
   IF (ps.task_number=0)
    pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
    IF (pcnt > 100)
     stat = alterlist(reply->prsnl_list[tcnt].apps,(ptcnt+ 100)), pcnt = 1
    ENDIF
    reply->prsnl_list[tcnt].apps[ptcnt].number = a.application_number, reply->prsnl_list[tcnt].apps[
    ptcnt].description = a.description
   ENDIF
  FOOT  p.person_id
   overall_cnt = (overall_cnt+ ptcnt), overall_cnt = (overall_cnt+ 1), stat = alterlist(reply->
    prsnl_list[tcnt].apps,ptcnt),
   stat = alterlist(reply->prsnl_list[tcnt].task,tncnt)
   IF ((overall_cnt > request->max_reply)
    AND (overall_stop_index=request->max_reply))
    overall_stop_index = (tcnt - 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->prsnl_list,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  FOR (x = 1 TO tcnt)
   SET task_cnt = size(reply->prsnl_list[x].task,5)
   IF (task_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(task_cnt)),
      pm_flx_conversation p,
      application ap,
      pm_sch_setup ps
     PLAN (d)
      JOIN (ps
      WHERE (ps.task_number=reply->prsnl_list[x].task[d.seq].number)
       AND (ps.person_id=reply->prsnl_list[x].person_id))
      JOIN (p
      WHERE p.task=ps.task_number
       AND p.active_ind=1)
      JOIN (ap
      WHERE ap.application_number=ps.application_number)
     ORDER BY p.description, ap.description
     HEAD p.description
      acnt = 0, reply->prsnl_list[x].task[d.seq].description = p.description
     HEAD ap.application_number
      acnt = (acnt+ 1), stat = alterlist(reply->prsnl_list[x].task[d.seq].apps,acnt), reply->
      prsnl_list[x].task[d.seq].apps[acnt].number = ap.application_number,
      reply->prsnl_list[x].task[d.seq].apps[acnt].description = ap.description
     WITH nocounter
    ;end select
    FOR (y = 0 TO task_cnt)
      DECLARE app_description = vc WITH protect
      SELECT INTO "nl:"
       FROM application ap,
        pm_sch_setup ps
       WHERE (ps.task_number=reply->prsnl_list[x].task[y].number)
        AND (ps.person_id=reply->prsnl_list[x].person_id)
        AND ap.application_number=ps.application_number
       DETAIL
        app_description = ap.description
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM pm_flx_conversation p,
        pm_sch_setup ps
       PLAN (ps
        WHERE (ps.task_number=reply->prsnl_list[x].task[y].number)
         AND (ps.person_id=reply->prsnl_list[x].person_id))
        JOIN (p
        WHERE p.task=ps.task_number
         AND p.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET reply->prsnl_list[x].task[y].description = trim(app_description,3)
       SET reply->prsnl_list[x].task[y].no_conversation_ind = 1
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF ((overall_cnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->prsnl_list,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 CALL bedexitscript(0)
END GO
