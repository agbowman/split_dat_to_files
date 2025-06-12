CREATE PROGRAM bed_upd_pp_favorite_usage:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 plans[*]
     2 pathway_customized_plan_id = f8
     2 prsnl_id = f8
     2 status_flag = i2
     2 pathway_customized_notify_id = f8
     2 version_pw_cat_id = f8
     2 power_plan_id = f8
     2 text_id = f8
 )
 FREE SET temp_plans
 RECORD temp_plans(
   1 plans[*]
     2 id = f8
     2 statusflag = i2
     2 text_id = f8
     2 notify_id = f8
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
 DECLARE activecd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE plan_cnt = i4 WITH noconstant(0), protect
 DECLARE status_flag = i2 WITH noconstant(0), protect
 DECLARE plancnt = i4 WITH noconstant(0), protect
 DECLARE totalplancnt = i4 WITH noconstant(0), protect
 IF ((request->require_new_plan_creation=1))
  SET status_flag = 2
 ELSEIF ((request->notification_text > " "))
  SET status_flag = 1
 ELSE
  GO TO exit_script
 ENDIF
 IF (validate(request->power_plans))
  SET plan_cnt = size(request->power_plans,5)
  SET stat = alterlist(temp_plans->plans,plan_cnt)
  FOR (i = 1 TO plan_cnt)
   SET temp_plans->plans[i].id = request->power_plans[i].power_plan_id
   IF ((request->notification_text > " "))
    SELECT INTO "nl:"
     new_text_id = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp_plans->plans[i].text_id = cnvtreal(new_text_id)
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->power_plan_id > 0))
  SET plan_cnt = (plan_cnt+ 1)
  SET stat = alterlist(temp_plans->plans,plan_cnt)
  SET temp_plans->plans[plan_cnt].id = request->power_plan_id
  IF ((request->notification_text > " "))
   SELECT INTO "nl:"
    new_text_id = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     temp_plans->plans[plan_cnt].text_id = cnvtreal(new_text_id)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (plan_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->plans,10)
 SELECT INTO "nl:"
  new_notify_id = seq(reference_seq,nextval)
  FROM (dummyt d  WITH seq = value(plan_cnt)),
   pathway_catalog pc,
   pathway_catalog pc2,
   pathway_customized_plan pcp,
   dual du
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_catalog_id=temp_plans->plans[d.seq].id))
   JOIN (pc2
   WHERE pc2.version_pw_cat_id=pc.version_pw_cat_id)
   JOIN (pcp
   WHERE pcp.pathway_catalog_id=pc2.pathway_catalog_id)
   JOIN (du)
  DETAIL
   plancnt = (plancnt+ 1), totalplancnt = (totalplancnt+ 1)
   IF (plancnt > 10)
    plancnt = 1, stat = alterlist(temp->plans,(totalplancnt+ 10))
   ENDIF
   temp->plans[totalplancnt].pathway_customized_plan_id = pcp.pathway_customized_plan_id, temp->
   plans[totalplancnt].prsnl_id = pcp.prsnl_id, temp->plans[totalplancnt].status_flag = pcp
   .status_flag,
   temp->plans[totalplancnt].pathway_customized_notify_id = cnvtreal(new_notify_id), temp->plans[
   totalplancnt].version_pw_cat_id = pc.version_pw_cat_id, temp->plans[totalplancnt].power_plan_id =
   temp_plans->plans[d.seq].id,
   temp->plans[totalplancnt].text_id = temp_plans->plans[d.seq].text_id, temp_plans->plans[d.seq].
   notify_id = cnvtreal(new_notify_id)
  FOOT REPORT
   stat = alterlist(temp->plans,totalplancnt)
  WITH nocounter
 ;end select
 IF (totalplancnt=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway_customized_plan pcp,
   (dummyt d  WITH seq = totalplancnt)
  SET pcp.status_flag = status_flag, pcp.updt_id = reqinfo->updt_id, pcp.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   pcp.updt_task = reqinfo->updt_task, pcp.updt_applctx = reqinfo->updt_applctx, pcp.updt_cnt = (pcp
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (pcp
   WHERE (pcp.pathway_customized_plan_id=temp->plans[d.seq].pathway_customized_plan_id)
    AND pcp.status_flag < status_flag)
  WITH nocounter
 ;end update
 CALL bederrorcheck("Error 001 - Failed updating into pathway_customized_plan")
 IF (status_flag=1)
  INSERT  FROM pathway_customized_notify pcn,
    (dummyt d  WITH seq = totalplancnt)
   SET pcn.active_ind = 1, pcn.long_text_id = temp->plans[d.seq].text_id, pcn.notification_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pcn.pathway_catalog_id = temp->plans[d.seq].power_plan_id, pcn.pathway_customized_notify_id =
    temp->plans[d.seq].pathway_customized_notify_id, pcn.pathway_customized_plan_id = temp->plans[d
    .seq].pathway_customized_plan_id,
    pcn.version_pw_cat_id = temp->plans[d.seq].version_pw_cat_id, pcn.updt_applctx = reqinfo->
    updt_applctx, pcn.updt_cnt = 0,
    pcn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcn.updt_id = reqinfo->updt_id, pcn.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (pcn)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error 002 - Failed inserting into pathway_customized_notify")
  IF (plan_cnt > 0)
   INSERT  FROM long_text_reference ltr,
     (dummyt d  WITH seq = value(plan_cnt))
    SET ltr.active_ind = 1, ltr.active_status_cd = activecd, ltr.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.long_text = request->notification_text, ltr
     .long_text_id = temp_plans->plans[d.seq].text_id,
     ltr.parent_entity_id = temp_plans->plans[d.seq].notify_id, ltr.parent_entity_name =
     "PATHWAY_CUSTOMIZED_NOTIFY", ltr.updt_applctx = reqinfo->updt_applctx,
     ltr.updt_cnt = 0, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr.updt_id = reqinfo->
     updt_id,
     ltr.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (temp_plans->plans[d.seq].text_id > 0))
     JOIN (ltr)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 003 - Failed  inserting into long_text_reference")
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
