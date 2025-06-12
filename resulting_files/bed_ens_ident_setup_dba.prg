CREATE PROGRAM bed_ens_ident_setup:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 setup_id_rep_lst[*]
      2 setup_id = f8
      2 setup_nbr = i4
      2 setup_name = vc
      2 setup_flag = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD temp_delete(
   1 setup_id_del_list[*]
     2 setup_id = f8
 )
 RECORD temp_update(
   1 setup_id_upd_list[*]
     2 setup_id = f8
     2 setup_nbr = i4
     2 setup_name = vc
     2 setup_flag = i4
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
 CALL bedbeginscript(0)
 DECLARE id_cnt = i4 WITH protect, noconstant(0)
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE del_cnt = i4 WITH protect, noconstant(0)
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE populatetempstructures(dummyvar=i2) = null
 DECLARE addidentifiersetupinformation(dummyvar=i2) = null
 DECLARE updateidentifiersetupinformation(dummyvar=i2) = null
 DECLARE deleteidentifiersetupinformation(dummyvar=i2) = null
 CALL populatetempstructures(0)
 CALL addidentifiersetupinformation(0)
 CALL updateidentifiersetupinformation(0)
 CALL deleteidentifiersetupinformation(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE populatetempstructures(dummyvar)
   CALL bedlogmessage("populateTempStructures","Entering...")
   SET id_cnt = size(request->setup_id_req_lst,5)
   FOR (i = 1 TO id_cnt)
     IF ((request->setup_id_req_lst[i].action_flag=3))
      SET del_cnt = (del_cnt+ 1)
      SET stat = alterlist(temp_delete->setup_id_del_list,del_cnt)
      SET temp_delete->setup_id_del_list[del_cnt].setup_id = request->setup_id_req_lst[i].setup_id
     ENDIF
     IF ((request->setup_id_req_lst[i].action_flag=2))
      SET updt_cnt = (updt_cnt+ 1)
      SET stat = alterlist(temp_update->setup_id_upd_list,updt_cnt)
      SET temp_update->setup_id_upd_list[updt_cnt].setup_name = request->setup_id_req_lst[i].
      setup_name
      SET temp_update->setup_id_upd_list[updt_cnt].setup_nbr = request->setup_id_req_lst[i].setup_nbr
      SET temp_update->setup_id_upd_list[updt_cnt].setup_id = request->setup_id_req_lst[i].setup_id
      SET temp_update->setup_id_upd_list[updt_cnt].setup_flag = request->setup_id_req_lst[i].
      setup_flag
     ENDIF
     IF ((request->setup_id_req_lst[i].action_flag=1))
      SET reply_cnt = (reply_cnt+ 1)
      SET br_setup_id = 0.0
      SELECT INTO "nl:"
       z = seq(bedrock_seq,nextval)
       FROM dual
       DETAIL
        br_setup_id = cnvtreal(z)
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->setup_id_rep_lst,reply_cnt)
      SET reply->setup_id_rep_lst[reply_cnt].setup_name = request->setup_id_req_lst[i].setup_name
      SET reply->setup_id_rep_lst[reply_cnt].setup_nbr = request->setup_id_req_lst[i].setup_nbr
      SET reply->setup_id_rep_lst[reply_cnt].setup_flag = request->setup_id_req_lst[i].setup_flag
      SET reply->setup_id_rep_lst[reply_cnt].setup_id = br_setup_id
     ENDIF
   ENDFOR
   CALL bederrorcheck("Failed to populate temp structures.")
   CALL bedlogmessage("populateTempStructures","Exiting...")
 END ;Subroutine
 SUBROUTINE addidentifiersetupinformation(dummyvar)
   CALL bedlogmessage("addIdentifierSetupInformation","Entering...")
   IF (reply_cnt > 0)
    INSERT  FROM br_setup_wizard b,
      (dummyt d  WITH seq = value(reply_cnt))
     SET b.br_setup_wizard_id = reply->setup_id_rep_lst[d.seq].setup_id, b.setup_ident = cnvtstring(
       reply->setup_id_rep_lst[d.seq].setup_nbr), b.setup_name = reply->setup_id_rep_lst[d.seq].
      setup_name,
      b.setup_wizard_flag = reply->setup_id_rep_lst[d.seq].setup_flag, b.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     PLAN (d)
      JOIN (b)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to add to br_setup_wizard.")
   ENDIF
   CALL bedlogmessage("addIdentifierSetupInformation","Exiting...")
 END ;Subroutine
 SUBROUTINE updateidentifiersetupinformation(dummyvar)
   CALL bedlogmessage("updateIdentifierSetupInformation","Entering...")
   IF (updt_cnt > 0)
    UPDATE  FROM br_setup_wizard b,
      (dummyt d  WITH seq = value(updt_cnt))
     SET b.setup_ident = cnvtstring(temp_update->setup_id_upd_list[d.seq].setup_nbr), b.setup_name =
      temp_update->setup_id_upd_list[d.seq].setup_name, b.setup_wizard_flag = temp_update->
      setup_id_upd_list[d.seq].setup_flag,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1)
     PLAN (d)
      JOIN (b
      WHERE (b.br_setup_wizard_id=temp_update->setup_id_upd_list[d.seq].setup_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("Failed to update br_setup_wizard.")
   ENDIF
   CALL bedlogmessage("updateIdentifierSetupInformation","Exiting...")
 END ;Subroutine
 SUBROUTINE deleteidentifiersetupinformation(dummyvar)
   CALL bedlogmessage("deleteIdentifierSetupInformation","Entering...")
   IF (del_cnt > 0)
    DELETE  FROM br_setup_wizard_loc_reltn b,
      (dummyt d  WITH seq = value(del_cnt))
     SET b.seq = 1
     PLAN (d)
      JOIN (b
      WHERE (b.br_setup_wizard_id=temp_delete->setup_id_del_list[d.seq].setup_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed to delete from br_setup_wizard_loc_reltn.")
    DELETE  FROM br_setup_wizard b,
      (dummyt d  WITH seq = value(del_cnt))
     SET b.seq = 1
     PLAN (d)
      JOIN (b
      WHERE (b.br_setup_wizard_id=temp_delete->setup_id_del_list[d.seq].setup_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed to delete from br_setup_wizard.")
   ENDIF
   CALL bedlogmessage("deleteIdentifierSetupInformation","Exiting...")
 END ;Subroutine
END GO
