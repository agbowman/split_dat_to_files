CREATE PROGRAM bed_get_pp_with_warnings_b:dba
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
      2 synonym_inactive_ind = i2
      2 synonym_type_invalid_ind = i2
      2 virtual_view_warn_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD plan_temp(
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
     2 synonym_inactive_ind = i2
     2 synonym_type_invalid_ind = i2
     2 virtual_view_warn_ind = i2
     2 vv_all_facilities_ind = i2
     2 vv_facility[*]
       3 id = f8
     2 phases[*]
       3 phase_id = f8
 )
 RECORD phase_temp(
   1 phases[*]
     2 phase_id = f8
     2 synonym_inactive_ind = i2
     2 synonym_type_invalid_ind = i2
     2 virtual_view_warn_ind = i2
     2 all_cnt = i4
     2 syn_cnt = i4
     2 vv[*]
       3 id = f8
       3 id_cnt = i4
     2 syns[*]
     2 id = f8
 )
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE med_ord_ct_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE med_ord_at_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE clin_cat_disp_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 SET total_pp_cnt = 0
 SET total_phase_cnt = 0
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_flex pcf,
   location l,
   organization o
  PLAN (p
   WHERE p.type_mean="CAREPLAN"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id > 0)
   JOIN (l
   WHERE l.location_cd=pcf.parent_entity_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.logical_domain_id=logical_domain_id)
  ORDER BY p.pathway_catalog_id
  HEAD REPORT
   total_pp_cnt = 0, total_phase_cnt = 0, stat = alterlist(plan_temp->power_plans,10),
   stat = alterlist(phase_temp->phases,10)
  HEAD p.pathway_catalog_id
   cnt = (cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1), total_phase_cnt = (total_phase_cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp
     ->phases,(total_phase_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,1), plan_temp->power_plans[
   total_pp_cnt].phases[1].phase_id = p.pathway_catalog_id, phase_temp->phases[total_phase_cnt].
   phase_id = p.pathway_catalog_id
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt), stat = alterlist(phase_temp->phases,
    total_phase_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_flex pcf
  PLAN (p
   WHERE p.type_mean="CAREPLAN"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id=0)
  ORDER BY p.pathway_catalog_id
  HEAD REPORT
   cnt = 0, total_pp_cnt = size(plan_temp->power_plans,5), total_phase_cnt = size(phase_temp->phases,
    5),
   stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp->phases,(
    total_phase_cnt+ 10))
  HEAD p.pathway_catalog_id
   cnt = (cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1), total_phase_cnt = (total_phase_cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp
     ->phases,(total_phase_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,1), plan_temp->power_plans[
   total_pp_cnt].phases[1].phase_id = p.pathway_catalog_id, phase_temp->phases[total_phase_cnt].
   phase_id = p.pathway_catalog_id
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt), stat = alterlist(phase_temp->phases,
    total_phase_cnt)
  WITH nocounter
 ;end select
 SET plan_cnt = 0
 SET plan_phase_cnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_reltn pcr,
   pw_cat_flex pcf,
   location l,
   organization o
  PLAN (p
   WHERE p.type_mean="PATHWAY"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=p.pathway_catalog_id
    AND pcr.type_mean="GROUP")
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id > 0)
   JOIN (l
   WHERE l.location_cd=pcf.parent_entity_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.logical_domain_id=logical_domain_id)
  ORDER BY p.pathway_catalog_id, pcr.pw_cat_t_id
  HEAD REPORT
   total_pp_cnt = size(plan_temp->power_plans,5), total_phase_cnt = size(phase_temp->phases,5),
   plan_cnt = 0,
   stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp->phases,(
    total_phase_cnt+ 10))
  HEAD p.pathway_catalog_id
   plan_cnt = (plan_cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1)
   IF (plan_cnt > 10)
    plan_cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   total_plan_phase_cnt = 0, plan_phase_cnt = 0, stat = alterlist(plan_temp->power_plans[total_pp_cnt
    ].phases,5)
  HEAD pcr.pw_cat_t_id
   plan_phase_cnt = (plan_phase_cnt+ 1), total_plan_phase_cnt = (total_plan_phase_cnt+ 1)
   IF (plan_phase_cnt > 5)
    plan_phase_cnt = 1, stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,(
     total_plan_phase_cnt+ 5))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].phases[total_plan_phase_cnt].phase_id = pcr.pw_cat_t_id,
   total_phase_cnt = (total_phase_cnt+ 1), stat = alterlist(phase_temp->phases,total_phase_cnt),
   phase_temp->phases[total_phase_cnt].phase_id = pcr.pw_cat_t_id
  FOOT  p.pathway_catalog_id
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,total_plan_phase_cnt)
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_reltn pcr,
   pw_cat_flex pcf
  PLAN (p
   WHERE p.type_mean="PATHWAY"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=p.pathway_catalog_id
    AND pcr.type_mean="GROUP")
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=p.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND pcf.parent_entity_id=0)
  ORDER BY p.pathway_catalog_id, pcr.pw_cat_t_id
  HEAD REPORT
   total_pp_cnt = size(plan_temp->power_plans,5), total_phase_cnt = size(phase_temp->phases,5),
   plan_cnt = 0,
   stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp->phases,(
    total_phase_cnt+ 10))
  HEAD p.pathway_catalog_id
   plan_cnt = (plan_cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1)
   IF (plan_cnt > 10)
    plan_cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   total_plan_phase_cnt = 0, plan_phase_cnt = 0, stat = alterlist(plan_temp->power_plans[total_pp_cnt
    ].phases,5)
  HEAD pcr.pw_cat_t_id
   plan_phase_cnt = (plan_phase_cnt+ 1), total_plan_phase_cnt = (total_plan_phase_cnt+ 1)
   IF (plan_phase_cnt > 5)
    plan_phase_cnt = 1, stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,(
     total_plan_phase_cnt+ 5))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].phases[total_plan_phase_cnt].phase_id = pcr.pw_cat_t_id,
   total_phase_cnt = (total_phase_cnt+ 1), stat = alterlist(phase_temp->phases,total_phase_cnt),
   phase_temp->phases[total_phase_cnt].phase_id = pcr.pw_cat_t_id
  FOOT  p.pathway_catalog_id
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,total_plan_phase_cnt)
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt), stat = alterlist(phase_temp->phases,
    total_phase_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_pp_cnt)),
   pw_cat_flex pcf,
   code_value cv
  PLAN (d)
   JOIN (pcf
   WHERE (pcf.pathway_catalog_id=plan_temp->power_plans[d.seq].power_plan_id)
    AND pcf.parent_entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_value=outerjoin(pcf.parent_entity_id)
    AND cv.active_ind=outerjoin(1))
  ORDER BY d.seq, cv.code_value
  HEAD d.seq
   fcnt = 0, ftcnt = 0, stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,10)
  HEAD cv.code_value
   IF (pcf.parent_entity_id=0)
    plan_temp->power_plans[d.seq].vv_all_facilities_ind = 1
   ELSEIF (cv.code_value > 0)
    fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
    IF (fcnt > 10)
     stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,(ftcnt+ 10)), fcnt = 1
    ENDIF
    plan_temp->power_plans[d.seq].vv_facility[ftcnt].id = cv.code_value
   ENDIF
  FOOT  d.seq
   stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,ftcnt)
  WITH nocounter
 ;end select
 FREE SET temp_vv
 RECORD temp_vv(
   1 all_ind = i2
   1 vv[*]
     2 id = f8
 )
 CALL echo(total_phase_cnt)
 SELECT INTO "nl:"
  FROM pathway_comp pc,
   order_catalog_synonym ocs,
   code_value cv_mt,
   (dummyt d  WITH seq = value(total_phase_cnt))
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_catalog_id=phase_temp->phases[d.seq].phase_id)
    AND trim(pc.parent_entity_name)="ORDER_CATALOG_SYNONYM"
    AND pc.active_ind=1)
   JOIN (ocs
   WHERE outerjoin(pc.parent_entity_id)=ocs.synonym_id)
   JOIN (cv_mt
   WHERE outerjoin(ocs.mnemonic_type_cd)=cv_mt.code_value)
  ORDER BY d.seq, ocs.synonym_id
  HEAD d.seq
   cnt = 0
  HEAD ocs.synonym_id
   phase_temp->phases[d.seq].syn_cnt = (phase_temp->phases[d.seq].syn_cnt+ 1)
   IF (ocs.active_ind=0)
    phase_temp->phases[d.seq].synonym_inactive_ind = 1
   ENDIF
   IF (ocs.synonym_id > 0)
    IF (pc.comp_type_cd=prescription_comp_cd)
     IF ( NOT (cv_mt.cdf_meaning IN ("GENERICPROD", "GENERICTOP", "TRADETOP", "TRADEPROD", "PRIMARY",
     "BRANDNAME")))
      phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
     ENDIF
    ELSEIF (pc.comp_type_cd=order_comp_cd)
     IF (ocs.catalog_type_cd=med_ord_ct_cd
      AND ocs.activity_type_cd=med_ord_at_cd
      AND ocs.orderable_type_flag IN (0, 1, 8, 11))
      IF ( NOT (cv_mt.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICNAME", "GENERICTOP",
      "IVNAME", "PRIMARY", "TRADETOP")))
       phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
      ENDIF
     ELSE
      IF ( NOT (cv_mt.cdf_meaning IN ("DCP", "PRIMARY")))
       phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_comp pc,
   ocs_facility_r ofr,
   (dummyt d  WITH seq = value(total_phase_cnt))
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_catalog_id=phase_temp->phases[d.seq].phase_id)
    AND trim(pc.parent_entity_name)="ORDER_CATALOG_SYNONYM"
    AND pc.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=pc.parent_entity_id)
  ORDER BY d.seq, ofr.facility_cd, ofr.synonym_id
  HEAD d.seq
   cnt = 0, vv_cnt = 0, stat = alterlist(phase_temp->phases[d.seq].vv,10)
  HEAD ofr.facility_cd
   IF (ofr.facility_cd > 0)
    cnt = (cnt+ 1), vv_cnt = (vv_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(phase_temp->phases[d.seq].vv,(vv_cnt+ 10)), cnt = 1
    ENDIF
    phase_temp->phases[d.seq].vv[vv_cnt].id = ofr.facility_cd
   ENDIF
  HEAD ofr.synonym_id
   IF (ofr.facility_cd=0
    AND ofr.synonym_id > 0)
    phase_temp->phases[d.seq].all_cnt = (phase_temp->phases[d.seq].all_cnt+ 1)
   ELSEIF (ofr.facility_cd > 0)
    phase_temp->phases[d.seq].vv[vv_cnt].id_cnt = (phase_temp->phases[d.seq].vv[vv_cnt].id_cnt+ 1)
   ENDIF
  FOOT  d.seq
   stat = alterlist(phase_temp->phases[d.seq].vv,vv_cnt)
  WITH nocounter
 ;end select
 FOR (p = 1 TO total_pp_cnt)
   SET phasecnt = size(plan_temp->power_plans[p].phases,5)
   SET tempplanvvcnt = size(plan_temp->power_plans[p].vv_facility,5)
   FOR (h = 1 TO phasecnt)
     SET start = 0
     SET num = 0
     SET found_idx = locateval(num,start,total_phase_cnt,plan_temp->power_plans[p].phases[h].phase_id,
      phase_temp->phases[num].phase_id)
     IF (found_idx > 0)
      IF ((phase_temp->phases[found_idx].synonym_inactive_ind=1))
       SET plan_temp->power_plans[p].synonym_inactive_ind = 1
      ENDIF
      IF ((phase_temp->phases[found_idx].synonym_type_invalid_ind=1))
       SET plan_temp->power_plans[p].synonym_type_invalid_ind = 1
      ENDIF
      IF ((phase_temp->phases[found_idx].all_cnt != phase_temp->phases[found_idx].syn_cnt)
       AND (plan_temp->power_plans[p].virtual_view_warn_ind=0))
       SET phase_vv_cnt = size(phase_temp->phases[found_idx].vv,5)
       IF ((((plan_temp->power_plans[p].vv_all_facilities_ind=1)) OR (phase_vv_cnt=0
        AND tempplanvvcnt > 0)) )
        SET plan_temp->power_plans[p].virtual_view_warn_ind = 1
       ELSE
        FOR (v = 1 TO tempplanvvcnt)
          SET found_vv_idx = 0
          SET start = 0
          SET num = 0
          SET found_vv_idx = locateval(num,start,phase_vv_cnt,plan_temp->power_plans[p].vv_facility[v
           ].id,phase_temp->phases[found_idx].vv[num].id)
          IF (((found_vv_idx <= 0) OR (((phase_temp->phases[found_idx].vv[found_vv_idx].id_cnt+
          phase_temp->phases[found_idx].all_cnt) != phase_temp->phases[found_idx].syn_cnt))) )
           SET plan_temp->power_plans[p].virtual_view_warn_ind = 1
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_pp_cnt))
  PLAN (d
   WHERE (((plan_temp->power_plans[d.seq].synonym_inactive_ind=1)) OR ((((plan_temp->power_plans[d
   .seq].synonym_type_invalid_ind=1)) OR ((plan_temp->power_plans[d.seq].virtual_view_warn_ind=1)))
   )) )
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->power_plans,total_pp_cnt)
  HEAD d.seq
   cnt = (cnt+ 1), reply->power_plans[cnt].power_plan_id = plan_temp->power_plans[d.seq].
   power_plan_id, reply->power_plans[cnt].active_ind = plan_temp->power_plans[d.seq].active_ind,
   reply->power_plans[cnt].beg_effective_dt_tm = plan_temp->power_plans[d.seq].beg_effective_dt_tm,
   reply->power_plans[cnt].display_description = plan_temp->power_plans[d.seq].display_description,
   reply->power_plans[cnt].end_effective_dt_tm = plan_temp->power_plans[d.seq].end_effective_dt_tm,
   reply->power_plans[cnt].highest_powerplan_ver_id = plan_temp->power_plans[d.seq].
   highest_powerplan_ver_id, reply->power_plans[cnt].synonym_inactive_ind = plan_temp->power_plans[d
   .seq].synonym_inactive_ind, reply->power_plans[cnt].synonym_type_invalid_ind = plan_temp->
   power_plans[d.seq].synonym_type_invalid_ind,
   reply->power_plans[cnt].updt_cnt = plan_temp->power_plans[d.seq].updt_cnt, reply->power_plans[cnt]
   .uuid = plan_temp->power_plans[d.seq].uuid, reply->power_plans[cnt].version = plan_temp->
   power_plans[d.seq].version,
   reply->power_plans[cnt].virtual_view_warn_ind = plan_temp->power_plans[d.seq].
   virtual_view_warn_ind
  FOOT REPORT
   stat = alterlist(reply->power_plans,cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
