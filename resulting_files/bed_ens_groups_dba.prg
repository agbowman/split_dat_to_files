CREATE PROGRAM bed_ens_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 br_group_id = f8
      2 deleted_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_delete
 RECORD temp_delete(
   1 parent_ids[*]
     2 action_flag = i2
     2 id = f8
 )
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE RECORD reqgroups
 RECORD reqgroups(
   1 groups[*]
     2 action_flag = i2
     2 br_group_id = f8
     2 group_name = vc
     2 group_type_flag = i2
     2 delete_ind = i2
     2 relations[*]
       3 action_flag = i2
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 logical_domain_ind = i2
 ) WITH protect
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
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
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE parent_cnt = i4 WITH noconstant(0), protect
 DECLARE reqgrpcnt = i4 WITH noconstant(1), protect
 DECLARE reqrelcnt = i4 WITH noconstant(1), protect
 DECLARE asscnt = i4 WITH noconstant(0), protect
 DECLARE index = i4 WITH noconstant(0), protect
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 SET req_size = size(request->groups,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   br_group_reltn r1
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=3))
   JOIN (r1
   WHERE r1.parent_entity_name="BR_GROUP"
    AND (r1.parent_entity_id=request->groups[d.seq].br_group_id))
  ORDER BY r1.br_group_id
  HEAD REPORT
   cnt = 0, parent_cnt = 0, stat = alterlist(temp_delete->parent_ids,10)
  HEAD r1.br_group_id
   cnt = (cnt+ 1), parent_cnt = (parent_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp_delete->parent_ids,(parent_cnt+ 10)), cnt = 1
   ENDIF
   temp_delete->parent_ids[parent_cnt].id = r1.br_group_id, temp_delete->parent_ids[parent_cnt].
   action_flag = 3
  FOOT REPORT
   stat = alterlist(temp_delete->parent_ids,parent_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Cleanup start failed")
 SELECT INTO "nl:"
  j = seq(bedrock_seq,nextval)
  FROM (dummyt d1  WITH seq = value(req_size)),
   dual d
  PLAN (d1
   WHERE (request->groups[d1.seq].action_flag=1))
   JOIN (d)
  DETAIL
   request->groups[d1.seq].br_group_id = cnvtreal(j)
  WITH counter
 ;end select
 CALL bederrorcheck("Group Id Retrieval Error")
 INSERT  FROM (dummyt d1  WITH seq = value(req_size)),
   br_group bg
  SET bg.br_group_id = request->groups[d1.seq].br_group_id, bg.group_name = request->groups[d1.seq].
   group_name, bg.group_type_flag = request->groups[d1.seq].group_type_flag,
   bg.updt_dt_tm = cnvtdatetime(curdate,curtime3), bg.updt_id = reqinfo->updt_id, bg.updt_task =
   reqinfo->updt_task,
   bg.updt_cnt = 0, bg.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE (request->groups[d1.seq].action_flag=1))
   JOIN (bg)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Group Insert Error")
 UPDATE  FROM (dummyt d1  WITH seq = value(req_size)),
   br_group bg
  SET bg.group_name = request->groups[d1.seq].group_name, bg.group_type_flag = request->groups[d1.seq
   ].group_type_flag, bg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bg.updt_id = reqinfo->updt_id, bg.updt_task = reqinfo->updt_task, bg.updt_cnt = (bg.updt_cnt+ 1),
   bg.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE (request->groups[d1.seq].action_flag=2))
   JOIN (bg
   WHERE (bg.br_group_id=request->groups[d1.seq].br_group_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Group Update Error")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_size)),
   br_group_reltn bgr,
   br_eligible_provider bep
  PLAN (d1
   WHERE (request->groups[d1.seq].action_flag=3)
    AND (request->groups[d1.seq].group_type_flag=1))
   JOIN (bgr
   WHERE (bgr.br_group_id=request->groups[d1.seq].br_group_id))
   JOIN (bep
   WHERE bep.br_eligible_provider_id=bgr.parent_entity_id
    AND bep.logical_domain_id=log_domain_id)
  ORDER BY bgr.br_group_reltn_id
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = bgr.br_group_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_name = "BR_GROUP_RELTN"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELRECSELECTION1 FOR TIER 1 GROUPS")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_size)),
   br_group_reltn bgr,
   br_group_reltn bgr2,
   br_eligible_provider ep
  PLAN (d1
   WHERE (request->groups[d1.seq].action_flag=3)
    AND (request->groups[d1.seq].group_type_flag=2))
   JOIN (bgr
   WHERE (bgr.br_group_id=request->groups[d1.seq].br_group_id))
   JOIN (bgr2
   WHERE bgr2.br_group_id=bgr.parent_entity_id)
   JOIN (ep
   WHERE ep.br_eligible_provider_id=bgr2.parent_entity_id
    AND ep.logical_domain_id=log_domain_id)
  ORDER BY bgr.br_group_reltn_id
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  HEAD bgr.br_group_reltn_id
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = bgr.br_group_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_name = "BR_GROUP_RELTN"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELRECSELECTION1 FOR TIER 2 GROUPS")
 FOR (reqgrpcnt = 1 TO size(request->groups,5))
   IF ((request->groups[reqgrpcnt].action_flag=3))
    SET stat = alterlist(reqgroups->groups,reqgrpcnt)
    SET reqgroups->groups[reqgrpcnt].action_flag = request->groups[reqgrpcnt].action_flag
    SET reqgroups->groups[reqgrpcnt].br_group_id = request->groups[reqgrpcnt].br_group_id
    SET reqgroups->groups[reqgrpcnt].group_name = request->groups[reqgrpcnt].group_name
    SET reqgroups->groups[reqgrpcnt].group_type_flag = request->groups[reqgrpcnt].group_type_flag
    FOR (reqrelcnt = 1 TO size(request->groups[reqgrpcnt].relations,5))
      SET stat = alterlist(reqgroups->groups[reqgrpcnt].relations,reqrelcnt)
      SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].action_flag = request->groups[reqgrpcnt].
      relations[reqrelcnt].action_flag
      SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].parent_entity_name = request->groups[
      reqgrpcnt].relations[reqrelcnt].parent_entity_name
      SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].parent_entity_id = request->groups[
      reqgrpcnt].relations[reqrelcnt].parent_entity_id
      IF ((request->groups[reqgrpcnt].group_type_flag=1))
       SELECT INTO "nl:"
        FROM br_group_reltn bgr,
         br_eligible_provider ep
        PLAN (bgr
         WHERE (bgr.br_group_id=reqgroups->groups[reqgrpcnt].br_group_id))
         JOIN (ep
         WHERE ep.br_eligible_provider_id=bgr.parent_entity_id
          AND ep.logical_domain_id != log_domain_id)
        HEAD bgr.br_group_id
         asscnt = 0
        DETAIL
         asscnt = (asscnt+ 1)
        WITH nocounter
       ;end select
       IF (asscnt > 0)
        SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].logical_domain_ind = 1
       ELSE
        SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].logical_domain_ind = 0
       ENDIF
      ELSEIF ((request->groups[reqgrpcnt].group_type_flag=2))
       SELECT INTO "nl:"
        FROM br_group_reltn bgr,
         br_group_reltn bgr2,
         br_eligible_provider ep
        PLAN (bgr
         WHERE (bgr.br_group_id=reqgroups->groups[reqgrpcnt].br_group_id))
         JOIN (bgr2
         WHERE bgr2.br_group_id=bgr.parent_entity_id)
         JOIN (ep
         WHERE ep.br_eligible_provider_id=bgr2.parent_entity_id
          AND ep.logical_domain_id != log_domain_id)
        HEAD bgr.br_group_id
         asscnt = 0
        DETAIL
         asscnt = (asscnt+ 1)
        WITH nocounter
       ;end select
       IF (asscnt > 0)
        SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].logical_domain_ind = 1
       ELSE
        SET reqgroups->groups[reqgrpcnt].relations[reqrelcnt].logical_domain_ind = 0
       ENDIF
      ENDIF
    ENDFOR
    SET index = locateval(index,1,size(reqgroups->groups[reqgrpcnt].relations,5),1,reqgroups->groups[
     reqgrpcnt].relations[index].logical_domain_ind)
    IF (index > 0)
     SET reqgroups->groups[reqgrpcnt].delete_ind = 0
    ELSE
     SET reqgroups->groups[reqgrpcnt].delete_ind = 1
    ENDIF
   ENDIF
 ENDFOR
 CALL bederrorcheck("ERROR Copying the request into free record")
 UPDATE  FROM (dummyt d1  WITH seq = value(size(reqgroups->groups,5))),
   br_prsnl_elig_prov_grp_r bpepgr
  SET bpepgr.active_ind = 0, bpepgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpepgr
   .updt_applctx = reqinfo->updt_applctx,
   bpepgr.updt_cnt = (bpepgr.updt_cnt+ 1), bpepgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpepgr
   .updt_id = reqinfo->updt_id,
   bpepgr.updt_task = reqinfo->updt_task
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bpepgr
   WHERE (bpepgr.br_group_id=reqgroups->groups[d1.seq].br_group_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Group Delete Error")
 DELETE  FROM (dummyt d1  WITH seq = value(size(delete_hist->deleted_item,5))),
   br_group_reltn bgr
  SET bgr.seq = 1
  PLAN (d1
   WHERE (request->groups.action_flag=3))
   JOIN (bgr
   WHERE (bgr.br_group_reltn_id=delete_hist->deleted_item[d1.seq].parent_entity_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error Deleting the relations")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reqgroups->groups,5))),
   br_group_reltn bgr
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bgr
   WHERE (bgr.parent_entity_id=reqgroups->groups[d1.seq].br_group_id)
    AND bgr.parent_entity_name="BR_GROUP")
  ORDER BY bgr.br_group_reltn_id
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = bgr.br_group_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_name = "BR_GROUP_RELTN"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELRECSELECTION2")
 DELETE  FROM (dummyt d1  WITH seq = value(size(reqgroups->groups,5))),
   br_group_reltn bgr
  SET bgr.seq = 1
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bgr
   WHERE (bgr.parent_entity_id=reqgroups->groups[d1.seq].br_group_id)
    AND bgr.parent_entity_name="BR_GROUP")
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error Deleting relations with in logical domain")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reqgroups->groups,5))),
   br_group bg
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bg
   WHERE (bg.br_group_id=reqgroups->groups[d1.seq].br_group_id))
  ORDER BY bg.br_group_id
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = bg.br_group_id, delete_hist->deleted_item[delete_hist_cnt].parent_entity_name
    = " BR_ELIGIBLE_PROVIDER"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELRECGROUPSELECTION1")
 SET reply_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH size(reqgroups->groups,5)),
   br_group bg
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bg
   WHERE (bg.br_group_id=reqgroups->groups[d1.seq].br_group_id))
  HEAD bg.br_group_id
   reply_cnt = (reply_cnt+ 1), stat = alterlist(reply->groups,d1.seq), reply->groups[d1.seq].
   deleted_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error in Deletion of Eligible Provider Group")
 DELETE  FROM (dummyt d1  WITH seq = value(size(reqgroups->groups,5))),
   br_group bg
  SET bg.seq = 1
  PLAN (d1
   WHERE (reqgroups->groups[d1.seq].action_flag=3)
    AND (reqgroups->groups[d1.seq].delete_ind=1))
   JOIN (bg
   WHERE (bg.br_group_id=reqgroups->groups[d1.seq].br_group_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error in Deletion of Eligible Provider Group")
 INSERT  FROM (dummyt d1  WITH seq = req_size),
   (dummyt d2  WITH seq = 1),
   br_group_reltn bgr
  SET bgr.br_group_reltn_id = seq(bedrock_seq,nextval), bgr.br_group_id = request->groups[d1.seq].
   br_group_id, bgr.parent_entity_name = request->groups[d1.seq].relations[d2.seq].parent_entity_name,
   bgr.parent_entity_id = request->groups[d1.seq].relations[d2.seq].parent_entity_id, bgr.updt_dt_tm
    = cnvtdatetime(curdate,curtime3), bgr.updt_id = reqinfo->updt_id,
   bgr.updt_task = reqinfo->updt_task, bgr.updt_cnt = 0, bgr.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE maxrec(d2,size(request->groups[d1.seq].relations,5))
    AND (((request->groups[d1.seq].action_flag=1)) OR ((request->groups[d1.seq].action_flag=2))) )
   JOIN (d2
   WHERE (request->groups[d1.seq].relations[d2.seq].action_flag=1))
   JOIN (bgr)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Reltn Insert Error")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_size)),
   (dummyt d2  WITH seq = 1),
   br_group_reltn bgr
  PLAN (d1
   WHERE maxrec(d2,size(request->groups[d1.seq].relations,5))
    AND (request->groups[d1.seq].action_flag=2))
   JOIN (d2
   WHERE (request->groups[d1.seq].relations[d2.seq].action_flag=3))
   JOIN (bgr
   WHERE (bgr.br_group_id=request->groups[d1.seq].br_group_id)
    AND (bgr.parent_entity_id=request->groups[d1.seq].relations[d2.seq].parent_entity_id)
    AND (bgr.parent_entity_name=request->groups[d1.seq].relations[d2.seq].parent_entity_name))
  ORDER BY bgr.br_group_reltn_id
  HEAD REPORT
   stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
   ENDIF
   delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_id = bgr.br_group_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
   parent_entity_name = "BR_GROUP_RELTN"
  FOOT REPORT
   stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("DELRECSELECTION3")
 DELETE  FROM (dummyt d1  WITH seq = value(req_size)),
   (dummyt d2  WITH seq = 1),
   br_group_reltn bgr
  SET bgr.seq = 1
  PLAN (d1
   WHERE maxrec(d2,size(request->groups[d1.seq].relations,5))
    AND (request->groups[d1.seq].action_flag=2))
   JOIN (d2
   WHERE (request->groups[d1.seq].relations[d2.seq].action_flag=3))
   JOIN (bgr
   WHERE (bgr.br_group_id=request->groups[d1.seq].br_group_id)
    AND (bgr.parent_entity_id=request->groups[d1.seq].relations[d2.seq].parent_entity_id)
    AND (bgr.parent_entity_name=request->groups[d1.seq].relations[d2.seq].parent_entity_name))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Reltn Delete Error")
 IF (parent_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(parent_cnt)),
    br_group_reltn b
   PLAN (d)
    JOIN (b
    WHERE (b.br_group_id=temp_delete->parent_ids[d.seq].id))
   ORDER BY d.seq
   DETAIL
    temp_delete->parent_ids[d.seq].action_flag = 0
   WITH nocounter
  ;end select
  CALL bederrorcheck("Cleanup check failed")
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(req_size)),
    br_group bg
   PLAN (d1
    WHERE (temp_delete->parent_ids[d1.seq].action_flag=3))
    JOIN (bg
    WHERE (bg.br_group_id=temp_delete->parent_ids[d1.seq].id))
   ORDER BY bg.br_group_id
   HEAD REPORT
    stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
    ENDIF
    delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
    parent_entity_id = bg.br_group_id, delete_hist->deleted_item[delete_hist_cnt].parent_entity_name
     = "BR_GROUP"
   FOOT REPORT
    stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("DELRECGROUPSELECTION1")
  DELETE  FROM (dummyt d1  WITH seq = value(parent_cnt)),
    br_group bg
   SET bg.seq = 1
   PLAN (d1
    WHERE (temp_delete->parent_ids[d1.seq].action_flag=3))
    JOIN (bg
    WHERE (bg.br_group_id=temp_delete->parent_ids[d1.seq].id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Cleanup Delete Error")
 ENDIF
 SET reply_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_size))
  PLAN (d1
   WHERE (((request->groups[d1.seq].action_flag=1)) OR ((request->groups[d1.seq].action_flag=2))) )
  HEAD REPORT
   reply_cnt = (reply_cnt+ 1), stat = alterlist(reply->groups,reply_cnt)
  DETAIL
   reply->groups[reply_cnt].br_group_id = request->groups[d1.seq].br_group_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error populating reply")
 IF (delete_hist_cnt > 0)
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = delete_hist_cnt)
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
    parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task =
    reqinfo->updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     curdate,curtime3)
   PLAN (d)
    JOIN (his)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("DELHISTINSERTFAILED1")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
