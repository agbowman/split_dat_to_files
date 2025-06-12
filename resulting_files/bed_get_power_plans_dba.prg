CREATE PROGRAM bed_get_power_plans:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 power_plans[*]
      2 power_plan_id = f8
      2 display_description = vc
      2 version = i4
      2 active_ind = i2
      2 highest_powerplan_ver_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 uuid = vc
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
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
 DECLARE logical_domain_id = f8 WITH protect, noconstant(bedgetlogicaldomain(0))
 DECLARE parsetext = vc
 DECLARE loadinactive = i2 WITH noconstant(0), protect
 DECLARE maxreply = i4 WITH noconstant(0), protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE clin_cat_disp_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 SET parsetext = concat("p.type_mean in ('CAREPLAN', 'PATHWAY') ",
  " and p.display_method_cd = clin_cat_disp_method_cd "," and p.ref_owner_person_id = 0 ")
 IF (validate(request->load_inactives))
  SET loadinactive = request->load_inactives
 ENDIF
 IF (loadinactive=0)
  SET parsetext = concat(parsetext," and p.active_ind = 1 ")
 ENDIF
 IF (validate(request->search_string))
  IF ((request->search_string > " "))
   SET parsetext = build(parsetext," and cnvtupper(p.display_description) = '")
   IF ((request->search_type_flag="C"))
    SET parsetext = build(parsetext,"*")
   ENDIF
   SET parsetext = build(parsetext,trim(cnvtupper(request->search_string)),"*'")
  ENDIF
 ENDIF
 IF (validate(request->max_reply))
  SET maxreply = request->max_reply
 ENDIF
 SET cnt = 0
 SET total_cnt = 0
 SET stat = alterlist(reply->power_plans,10)
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_flex pcf,
   location l,
   organization o
  PLAN (p
   WHERE parser(parsetext))
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id > 0.0)
   JOIN (l
   WHERE l.location_cd=pcf.parent_entity_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.logical_domain_id=logical_domain_id)
  ORDER BY p.pathway_catalog_id
  HEAD p.pathway_catalog_id
   cnt = (cnt+ 1), total_cnt = (total_cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->power_plans,(total_cnt+ 10))
   ENDIF
   reply->power_plans[total_cnt].power_plan_id = p.pathway_catalog_id, reply->power_plans[total_cnt].
   display_description = p.display_description, reply->power_plans[total_cnt].version = p.version,
   reply->power_plans[total_cnt].active_ind = p.active_ind, reply->power_plans[total_cnt].
   highest_powerplan_ver_id = p.version_pw_cat_id, reply->power_plans[total_cnt].beg_effective_dt_tm
    = p.beg_effective_dt_tm,
   reply->power_plans[total_cnt].end_effective_dt_tm = p.end_effective_dt_tm, reply->power_plans[
   total_cnt].uuid = p.pathway_uuid, reply->power_plans[total_cnt].updt_cnt = p.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->power_plans,total_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->power_plans,(total_cnt+ 10))
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_flex pcf
  PLAN (p
   WHERE parser(parsetext))
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id=0.0)
  ORDER BY p.pathway_catalog_id
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->power_plans,(total_cnt+ 10))
  HEAD p.pathway_catalog_id
   cnt = (cnt+ 1), total_cnt = (total_cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->power_plans,(total_cnt+ 10))
   ENDIF
   reply->power_plans[total_cnt].power_plan_id = p.pathway_catalog_id, reply->power_plans[total_cnt].
   display_description = p.display_description, reply->power_plans[total_cnt].version = p.version,
   reply->power_plans[total_cnt].active_ind = p.active_ind, reply->power_plans[total_cnt].
   highest_powerplan_ver_id = p.version_pw_cat_id, reply->power_plans[total_cnt].beg_effective_dt_tm
    = p.beg_effective_dt_tm,
   reply->power_plans[total_cnt].end_effective_dt_tm = p.end_effective_dt_tm, reply->power_plans[
   total_cnt].uuid = p.pathway_uuid, reply->power_plans[total_cnt].updt_cnt = p.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->power_plans,total_cnt)
  WITH nocounter
 ;end select
 IF (loadinactive=1)
  SELECT INTO "nl:"
   FROM pathway_catalog p
   PLAN (p
    WHERE parser(parsetext)
     AND p.active_ind=0
     AND  NOT (p.pathway_catalog_id IN (
    (SELECT
     pathway_catalog_id
     FROM pw_cat_flex))))
   ORDER BY p.pathway_catalog_id
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->power_plans,(total_cnt+ 10))
   HEAD p.pathway_catalog_id
    cnt = (cnt+ 1), total_cnt = (total_cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(reply->power_plans,(total_cnt+ 10))
    ENDIF
    reply->power_plans[total_cnt].power_plan_id = p.pathway_catalog_id, reply->power_plans[total_cnt]
    .display_description = p.display_description, reply->power_plans[total_cnt].version = p.version,
    reply->power_plans[total_cnt].active_ind = p.active_ind, reply->power_plans[total_cnt].
    highest_powerplan_ver_id = p.version_pw_cat_id, reply->power_plans[total_cnt].beg_effective_dt_tm
     = p.beg_effective_dt_tm,
    reply->power_plans[total_cnt].end_effective_dt_tm = p.end_effective_dt_tm, reply->power_plans[
    total_cnt].uuid = p.pathway_uuid, reply->power_plans[total_cnt].updt_cnt = p.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->power_plans,total_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (maxreply > 0
  AND total_cnt > maxreply)
  SET stat = alterlist(reply->power_plans,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
