CREATE PROGRAM bed_get_pp_by_subphase:dba
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
      2 test_version_exists_ind = i2
      2 vv_all_facilities_ind = i2
      2 vv_facility[*]
        3 id = f8
        3 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET temp_phases
 RECORD temp_phases(
   1 phase[*]
     2 id = f8
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
 DECLARE pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ppt_cnt = i4 WITH protect, noconstant(0)
 DECLARE phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE phaset_cnt = i4 WITH protect, noconstant(0)
 DECLARE facility_count = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM pathway_comp comp,
   pathway_catalog phase,
   pw_cat_reltn pcr,
   pathway_catalog p_cat
  PLAN (comp
   WHERE (comp.pathway_comp_id=request->sub_phase_comp_id)
    AND comp.parent_entity_name="PATHWAY_CATALOG")
   JOIN (phase
   WHERE phase.pathway_catalog_id=comp.parent_entity_id)
   JOIN (pcr
   WHERE pcr.pw_cat_t_id=phase.pathway_catalog_id
    AND pcr.type_mean="SUBPHASE")
   JOIN (p_cat
   WHERE p_cat.pathway_catalog_id=pcr.pw_cat_s_id)
  ORDER BY p_cat.pathway_catalog_id
  HEAD REPORT
   stat = alterlist(reply->power_plans,10), stat = alterlist(temp_phases->phase,10)
  HEAD p_cat.pathway_catalog_id
   IF (p_cat.type_mean="PHASE")
    phase_cnt = (phase_cnt+ 1), phaset_cnt = (phaset_cnt+ 1)
    IF (phase_cnt > 10)
     stat = alterlist(temp_phases->phase,(phaset_cnt+ 10)), phase_cnt = 1
    ENDIF
    temp_phases->phase[phaset_cnt].id = p_cat.pathway_catalog_id
   ELSEIF (((p_cat.type_mean="PATHWAY") OR (p_cat.type_mean="CAREPLAN")) )
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    reply->power_plans[ppt_cnt].active_ind = p_cat.active_ind, reply->power_plans[ppt_cnt].
    beg_effective_dt_tm = p_cat.beg_effective_dt_tm, reply->power_plans[ppt_cnt].display_description
     = p_cat.display_description,
    reply->power_plans[ppt_cnt].end_effective_dt_tm = p_cat.end_effective_dt_tm, reply->power_plans[
    ppt_cnt].highest_powerplan_ver_id = p_cat.version_pw_cat_id, reply->power_plans[ppt_cnt].
    power_plan_id = p_cat.pathway_catalog_id,
    reply->power_plans[ppt_cnt].version = p_cat.version, reply->power_plans[ppt_cnt].uuid = p_cat
    .pathway_uuid, reply->power_plans[ppt_cnt].updt_cnt = p_cat.updt_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->power_plans,ppt_cnt), stat = alterlist(temp_phases->phase,phaset_cnt)
  WITH nocounter
 ;end select
 IF (phase_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = phase_cnt),
    pw_cat_reltn pcr,
    pathway_catalog p_cat
   PLAN (d)
    JOIN (pcr
    WHERE (pcr.pw_cat_t_id=temp_phases->phase[d.seq].id)
     AND pcr.type_mean="GROUP")
    JOIN (p_cat
    WHERE p_cat.pathway_catalog_id=pcr.pw_cat_s_id)
   ORDER BY p_cat.pathway_catalog_id
   HEAD REPORT
    stat = alterlist(reply->power_plans,(ppt_cnt+ 10)), pp_cnt = 0
   HEAD p_cat.pathway_catalog_id
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    reply->power_plans[ppt_cnt].active_ind = p_cat.active_ind, reply->power_plans[ppt_cnt].
    beg_effective_dt_tm = p_cat.beg_effective_dt_tm, reply->power_plans[ppt_cnt].display_description
     = p_cat.display_description,
    reply->power_plans[ppt_cnt].end_effective_dt_tm = p_cat.end_effective_dt_tm, reply->power_plans[
    ppt_cnt].highest_powerplan_ver_id = p_cat.version_pw_cat_id, reply->power_plans[ppt_cnt].
    power_plan_id = p_cat.pathway_catalog_id,
    reply->power_plans[ppt_cnt].version = p_cat.version, reply->power_plans[ppt_cnt].uuid = p_cat
    .pathway_uuid, reply->power_plans[ppt_cnt].updt_cnt = p_cat.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->power_plans,ppt_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL bederrorcheck("Error 001 - Failed to retrieve power plans.")
 IF (ppt_cnt > 0)
  SELECT INTO "nl:"
   FROM pathway_catalog pw_cat,
    (dummyt d_pp  WITH seq = ppt_cnt)
   PLAN (d_pp)
    JOIN (pw_cat
    WHERE (pw_cat.pathway_uuid=reply->power_plans[d_pp.seq].uuid)
     AND pw_cat.type_mean != "PHASE"
     AND pw_cat.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND pw_cat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND pw_cat.ref_owner_person_id=0.0)
   ORDER BY d_pp.seq, pw_cat.pathway_uuid
   DETAIL
    reply->power_plans[d_pp.seq].test_version_exists_ind = 1
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 002 - uuid ")
  SELECT INTO "nl:"
   FROM pw_cat_flex p,
    code_value c,
    (dummyt d_pp  WITH seq = ppt_cnt)
   PLAN (d_pp)
    JOIN (p
    WHERE (p.pathway_catalog_id=reply->power_plans[d_pp.seq].power_plan_id)
     AND p.parent_entity_name=outerjoin("CODE_VALUE"))
    JOIN (c
    WHERE c.code_value=outerjoin(p.parent_entity_id))
   DETAIL
    IF (c.code_value=0.0)
     reply->power_plans[d_pp.seq].vv_all_facilities_ind = 1
    ENDIF
    IF (c.active_ind=1)
     facility_count = (facility_count+ 1), stat = alterlist(reply->power_plans[d_pp.seq].vv_facility,
      facility_count), reply->power_plans[d_pp.seq].vv_facility[facility_count].id = p
     .parent_entity_id,
     reply->power_plans[d_pp.seq].vv_facility[facility_count].display = c.display
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 003 - pathway_catalog id ")
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
