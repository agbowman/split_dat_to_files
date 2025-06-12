CREATE PROGRAM bed_aud_clinrpt_expedites:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 expedites[*]
      2 expedite_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD triggers
 RECORD triggers(
   1 trigger[*]
     2 trigger_name = vc
     2 order_complete_flag = i2
     2 discharged_flag = i2
     2 params_id = f8
     2 chart_content_flag = i2
     2 chart_format = vc
     2 report_template = vc
     2 output_flag = i2
     2 output_name = vc
     2 exp_prov_ind = i2
     2 location_context_flag = i2
     2 copy[*]
       3 encntr_prsnl_r_disp = vc
     2 priority_cnt = i4
     2 priority[*]
       3 code_value = f8
       3 display = vc
     2 result_range_cnt = i4
     2 result_range[*]
       3 code_value = f8
       3 display = vc
     2 result_status_cnt = i4
     2 result_status[*]
       3 code_value = f8
       3 display = vc
     2 result_cnt = i4
     2 result[*]
       3 code_value = f8
       3 display = vc
       3 nbr = i4
     2 report_processing_cnt = i4
     2 report_processing[*]
       3 code_value = f8
       3 display = vc
       3 nbr = i4
     2 catalog_cnt = i4
     2 catalog[*]
       3 code_value = f8
       3 display = vc
     2 activity_cnt = i4
     2 activity[*]
       3 code_value = f8
       3 display = vc
     2 orc_cnt = i4
     2 orc[*]
       3 code_value = f8
       3 mnemonic = vc
     2 assay_cnt = i4
     2 coded_resp_ind = i2
     2 assay[*]
       3 catalog_cd = f8
       3 code_value = f8
       3 display = vc
       3 expedite_trigger_id = f8
       3 coded_resp_ind = i2
       3 coded_resp_cnt = i4
       3 coded_resp[*]
         4 mnemonic = vc
     2 location_cnt = i4
     2 location[*]
       3 code_value = f8
       3 tree_cnt = i4
       3 tree[*]
         4 code_value = f8
         4 description = vc
     2 organization_cnt = i4
     2 organization[*]
       3 organization_id = f8
       3 org_name = vc
     2 service_resource_cnt = i4
     2 service_resource[*]
       3 code_value = f8
       3 description = vc
     2 provider_cnt = i4
     2 provider[*]
       3 provider_id = f8
       3 name = vc
     2 param_name = vc
     2 sa_result_action[*]
       3 description = vc
     2 pathology_ind = i2
     2 sending_org_id = f8
     2 sending_org_name = vc
     2 sending_org_email = vc
 )
 FREE RECORD tree
 RECORD tree(
   1 qual[*]
     2 code_value = f8
     2 lowest_child_cd = f8
     2 sr_tree_lvl = i4
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
 DECLARE build_expedite_ids(dummyvar=i2) = null
 DECLARE exp_parse = vc WITH protect
 DECLARE exp_cnt = i4 WITH protect
 DECLARE intsecemail_cd = f8 WITH noconstant(0.0)
 DECLARE sending_org_fld_exists = i2 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 SET path_fld_exists = checkdic("EXPEDITE_PARAMS.PATHOLOGIST_DEFAULT_IND","A",0)
 SET sending_org_fld_exists = checkdic("EXPEDITE_PARAMS.SENDING_ORG_ID","A",0)
 SET exp_parse = " et.expedite_trigger_id > 0 and et.active_ind = 1"
 CALL build_expedite_ids(0)
 SET primary_type_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET src_vocab_cd = uar_get_code_by("MEANING",400,"MICROBIOLOGY")
 SET org_pri_type_cd = uar_get_code_by("MEANING",401,"ORGANISM")
 SET grp_pri_type_cd = uar_get_code_by("MEANING",401,"GRPALPHARESP")
 SET det_pri_type_cd = uar_get_code_by("MEANING",401,"ALPHA RESPON")
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "NL:"
   FROM expedite_trigger et,
    expedite_params_r epr
   PLAN (et
    WHERE parser(exp_parse))
    JOIN (epr
    WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
   ORDER BY et.name, et.location_cd
   HEAD et.name
    high_volume_cnt = (high_volume_cnt+ 1)
   HEAD et.location_cd
    high_volume_cnt = (high_volume_cnt+ 1)
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM expedite_trigger et,
   expedite_params_r epr,
   organization o,
   order_catalog_synonym ocs,
   order_catalog oc,
   discrete_task_assay dta,
   prsnl p,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7,
   code_value cv8,
   code_value cv9
  PLAN (et
   WHERE parser(exp_parse))
   JOIN (epr
   WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
   JOIN (o
   WHERE o.organization_id=outerjoin(et.organization_id)
    AND o.active_ind=outerjoin(1))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(et.synonym_id)
    AND ocs.active_ind=outerjoin(1))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(ocs.catalog_cd)
    AND oc.active_ind=outerjoin(1))
   JOIN (dta
   WHERE dta.task_assay_cd=outerjoin(et.task_assay_cd)
    AND dta.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(et.provider_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(et.report_priority_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(et.result_range_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(et.result_status_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(et.result_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(et.report_processing_cd)
    AND cv5.active_ind=outerjoin(1))
   JOIN (cv6
   WHERE cv6.code_value=outerjoin(et.service_resource_cd)
    AND cv6.active_ind=outerjoin(1))
   JOIN (cv7
   WHERE cv7.code_value=outerjoin(et.catalog_type_cd)
    AND cv7.active_ind=outerjoin(1))
   JOIN (cv8
   WHERE cv8.code_value=outerjoin(et.activity_type_cd)
    AND cv8.active_ind=outerjoin(1))
   JOIN (cv9
   WHERE cv9.code_value=outerjoin(et.task_assay_cd)
    AND cv9.active_ind=outerjoin(1))
  ORDER BY et.name, epr.precedence_seq
  HEAD et.name
   tcnt = (tcnt+ 1), priority_cnt = 0, result_range_cnt = 0,
   result_status_cnt = 0, result_cnt = 0, report_processing_cnt = 0,
   location_cnt = 0, organization_cnt = 0, service_resource_cnt = 0,
   catalog_cnt = 0, activity_cnt = 0, orc_cnt = 0,
   assay_cnt = 0, provider_cnt = 0, mic_ver_dup_ind = 0,
   mic_cor_dup_ind = 0, mic_com_dup_ind = 0, mic_after_com_dup_ind = 0,
   organization_dup_ind = 0, location_dup_ind = 0, priority_dup_ind = 0,
   result_range_dup_ind = 0, result_status_dup_ind = 0, report_processing_dup_ind = 0,
   service_resource_dup_ind = 0, catalog_dup_ind = 0, activity_dup_ind = 0,
   orc_dup_ind = 0, assay_dup_ind = 0, coded_resp_ind = 0,
   provider_dup_ind = 0, count = 0, stat = alterlist(triggers->trigger,tcnt),
   triggers->trigger[tcnt].trigger_name = et.name, triggers->trigger[tcnt].order_complete_flag = et
   .order_complete_flag, triggers->trigger[tcnt].discharged_flag = et.discharged_flag,
   triggers->trigger[tcnt].params_id = epr.expedite_params_id
  DETAIL
   IF (et.coded_resp_ind=1)
    triggers->trigger[tcnt].coded_resp_ind = 1
   ENDIF
   triggers->trigger[tcnt].location_context_flag = et.location_context_flag
   IF (et.mic_ver_flag=1)
    mic_ver_dup_ind = locateval(idx,1,count,"Antibiotic Verified",triggers->trigger[tcnt].
     sa_result_action[idx].description)
    IF (mic_ver_dup_ind=0)
     count = (count+ 1), stat = alterlist(triggers->trigger[tcnt].sa_result_action,count), triggers->
     trigger[tcnt].sa_result_action[count].description = "Antibiotic Verified"
    ENDIF
   ENDIF
   IF (et.mic_cor_flag=1)
    mic_cor_dup_ind = locateval(idx,1,count,"Antibiotic Corrected",triggers->trigger[tcnt].
     sa_result_action[idx].description)
    IF (mic_cor_dup_ind=0)
     count = (count+ 1), stat = alterlist(triggers->trigger[tcnt].sa_result_action,count), triggers->
     trigger[tcnt].sa_result_action[count].description = "Antibiotic Corrected"
    ENDIF
   ENDIF
   IF (et.mic_com_flag=1)
    mic_com_dup_ind = locateval(idx,1,count,"Susceptibility Method Complete",triggers->trigger[tcnt].
     sa_result_action[idx].description)
    IF (mic_com_dup_ind=0)
     count = (count+ 1), stat = alterlist(triggers->trigger[tcnt].sa_result_action,count), triggers->
     trigger[tcnt].sa_result_action[count].description = "Susceptibility Method Complete"
    ENDIF
   ENDIF
   IF (et.mic_after_com_flag=1)
    mic_after_com_dup_ind = locateval(idx,1,count,
     "Antibiotic Verified/Corrected after Susceptibility Complete",triggers->trigger[tcnt].
     sa_result_action[idx].description)
    IF (mic_after_com_dup_ind=0)
     count = (count+ 1), stat = alterlist(triggers->trigger[tcnt].sa_result_action,count), triggers->
     trigger[tcnt].sa_result_action[count].description =
     "Antibiotic Verified/Corrected after Susceptibility Complete"
    ENDIF
   ENDIF
   IF (et.organization_id > 0)
    organization_dup_ind = locateval(idx,1,organization_cnt,et.organization_id,triggers->trigger[tcnt
     ].organization[idx].organization_id)
    IF (organization_dup_ind=0)
     organization_cnt = (organization_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].organization,
      organization_cnt), triggers->trigger[tcnt].organization[organization_cnt].organization_id = et
     .organization_id,
     triggers->trigger[tcnt].organization[organization_cnt].org_name = o.org_name, triggers->trigger[
     tcnt].organization_cnt = organization_cnt
    ENDIF
   ENDIF
   IF (et.location_cd > 0)
    location_dup_ind = locateval(idx,1,location_cnt,et.location_cd,triggers->trigger[tcnt].location[
     idx].code_value)
    IF (location_dup_ind=0)
     location_cnt = (location_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].location,location_cnt
      ), triggers->trigger[tcnt].location[location_cnt].code_value = et.location_cd,
     triggers->trigger[tcnt].location_cnt = location_cnt
    ENDIF
   ENDIF
   IF (et.report_priority_cd > 0)
    priority_dup_ind = locateval(idx,1,priority_cnt,et.report_priority_cd,triggers->trigger[tcnt].
     priority[idx].code_value)
    IF (priority_dup_ind=0)
     priority_cnt = (priority_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].priority,priority_cnt
      ), triggers->trigger[tcnt].priority[priority_cnt].code_value = et.report_priority_cd,
     triggers->trigger[tcnt].priority[priority_cnt].display = cv1.display, triggers->trigger[tcnt].
     priority_cnt = priority_cnt
    ENDIF
   ENDIF
   IF (et.result_range_cd > 0)
    result_range_dup_ind = locateval(idx,1,result_range_cnt,et.result_range_cd,triggers->trigger[tcnt
     ].result_range[idx].code_value)
    IF (result_range_dup_ind=0)
     result_range_cnt = (result_range_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].result_range,
      result_range_cnt), triggers->trigger[tcnt].result_range[result_range_cnt].code_value = et
     .result_range_cd,
     triggers->trigger[tcnt].result_range[result_range_cnt].display = cv2.display, triggers->trigger[
     tcnt].result_range_cnt = result_range_cnt
    ENDIF
   ENDIF
   IF (et.result_status_cd > 0)
    result_status_dup_ind = locateval(idx,1,result_status_cnt,et.result_status_cd,triggers->trigger[
     tcnt].result_status[idx].code_value)
    IF (result_status_dup_ind=0)
     result_status_cnt = (result_status_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].
      result_status,result_status_cnt), triggers->trigger[tcnt].result_status[result_status_cnt].
     code_value = et.result_status_cd,
     triggers->trigger[tcnt].result_status[result_status_cnt].display = cv3.display, triggers->
     trigger[tcnt].result_status_cnt = result_status_cnt
    ENDIF
   ENDIF
   IF (et.result_cd > 0)
    result_dup_ind = locateval(idx,1,result_cnt,et.result_cd,triggers->trigger[tcnt].result[idx].
     code_value)
    IF (result_dup_ind=0)
     result_cnt = (result_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].result,result_cnt),
     triggers->trigger[tcnt].result[result_cnt].code_value = et.result_cd,
     triggers->trigger[tcnt].result[result_cnt].display = cv4.display, triggers->trigger[tcnt].
     result[result_cnt].nbr = et.result_nbr, triggers->trigger[tcnt].result_cnt = result_cnt
    ENDIF
   ENDIF
   IF (et.report_processing_cd > 0)
    report_processing_dup_ind = locateval(idx,1,report_processing_cnt,et.report_processing_cd,
     triggers->trigger[tcnt].report_processing[idx].code_value)
    IF (report_processing_dup_ind=0)
     report_processing_cnt = (report_processing_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].
      report_processing,report_processing_cnt), triggers->trigger[tcnt].report_processing[
     report_processing_cnt].code_value = et.report_processing_cd,
     triggers->trigger[tcnt].report_processing[report_processing_cnt].display = cv5.display, triggers
     ->trigger[tcnt].report_processing[report_processing_cnt].nbr = et.report_processing_nbr,
     triggers->trigger[tcnt].report_processing_cnt = report_processing_cnt
    ENDIF
   ENDIF
   IF (et.service_resource_cd > 0)
    service_resource_dup_ind = locateval(idx,1,service_resource_cnt,et.service_resource_cd,triggers->
     trigger[tcnt].service_resource[idx].code_value)
    IF (service_resource_dup_ind=0)
     service_resource_cnt = (service_resource_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].
      service_resource,service_resource_cnt), triggers->trigger[tcnt].service_resource[
     service_resource_cnt].code_value = et.service_resource_cd,
     triggers->trigger[tcnt].service_resource[service_resource_cnt].description = cv6.description,
     triggers->trigger[tcnt].service_resource_cnt = service_resource_cnt
    ENDIF
   ENDIF
   IF (et.catalog_type_cd > 0)
    catalog_dup_ind = locateval(idx,1,catalog_cnt,et.catalog_type_cd,triggers->trigger[tcnt].catalog[
     idx].code_value)
    IF (catalog_dup_ind=0)
     catalog_cnt = (catalog_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].catalog,catalog_cnt),
     triggers->trigger[tcnt].catalog[catalog_cnt].code_value = et.catalog_type_cd,
     triggers->trigger[tcnt].catalog[catalog_cnt].display = cv7.display, triggers->trigger[tcnt].
     catalog_cnt = catalog_cnt
    ENDIF
   ENDIF
   IF (et.activity_type_cd > 0)
    activity_dup_ind = locateval(idx,1,activity_cnt,et.activity_type_cd,triggers->trigger[tcnt].
     activity[idx].code_value)
    IF (activity_dup_ind=0)
     activity_cnt = (activity_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].activity,activity_cnt
      ), triggers->trigger[tcnt].activity[activity_cnt].code_value = et.activity_type_cd,
     triggers->trigger[tcnt].activity[activity_cnt].display = cv8.display, triggers->trigger[tcnt].
     activity_cnt = activity_cnt
    ENDIF
   ENDIF
   IF (et.catalog_cd > 0
    AND et.task_assay_cd=0)
    orc_dup_ind = locateval(idx,1,orc_cnt,et.catalog_cd,triggers->trigger[tcnt].orc[idx].code_value)
    IF (orc_dup_ind=0
     AND ocs.catalog_cd > 0)
     orc_cnt = (orc_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].orc,orc_cnt), triggers->
     trigger[tcnt].orc[orc_cnt].code_value = et.catalog_cd
     IF (ocs.mnemonic_type_cd=primary_type_cd)
      triggers->trigger[tcnt].orc[orc_cnt].mnemonic = oc.dept_display_name
     ELSE
      triggers->trigger[tcnt].orc[orc_cnt].mnemonic = ocs.mnemonic
     ENDIF
     triggers->trigger[tcnt].orc_cnt = orc_cnt
    ENDIF
   ENDIF
   IF (et.task_assay_cd > 0)
    assay_dup_ind = locateval(idx,1,assay_cnt,et.task_assay_cd,triggers->trigger[tcnt].assay[idx].
     code_value,
     et.catalog_cd,triggers->trigger[tcnt].assay[idx].catalog_cd)
    IF (assay_dup_ind=0)
     assay_cnt = (assay_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].assay,assay_cnt), triggers
     ->trigger[tcnt].assay[assay_cnt].code_value = et.task_assay_cd,
     triggers->trigger[tcnt].assay[assay_cnt].display = cv9.display, triggers->trigger[tcnt].assay[
     assay_cnt].expedite_trigger_id = et.expedite_trigger_id, triggers->trigger[tcnt].assay[assay_cnt
     ].catalog_cd = et.catalog_cd,
     triggers->trigger[tcnt].assay[assay_cnt].coded_resp_ind = et.coded_resp_ind, triggers->trigger[
     tcnt].assay_cnt = assay_cnt
    ENDIF
   ENDIF
   IF (et.provider_id > 0)
    provider_dup_ind = locateval(idx,1,provider_cnt,et.provider_id,triggers->trigger[tcnt].provider[
     idx].provider_id)
    IF (provider_dup_ind=0)
     provider_cnt = (provider_cnt+ 1), stat = alterlist(triggers->trigger[tcnt].provider,provider_cnt
      ), triggers->trigger[tcnt].provider[provider_cnt].provider_id = et.provider_id,
     triggers->trigger[tcnt].provider[provider_cnt].name = p.name_full_formatted, triggers->trigger[
     tcnt].provider_cnt = provider_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    expedite_params ep,
    output_dest od,
    expedite_copy ec,
    chart_format cf,
    cr_report_template crt
   PLAN (d)
    JOIN (ep
    WHERE (ep.expedite_params_id=triggers->trigger[d.seq].params_id))
    JOIN (od
    WHERE od.output_dest_cd=outerjoin(ep.output_dest_cd))
    JOIN (ec
    WHERE ec.expedite_params_id=outerjoin(ep.expedite_params_id))
    JOIN (cf
    WHERE cf.chart_format_id=outerjoin(ep.chart_format_id)
     AND cf.active_ind=outerjoin(1))
    JOIN (crt
    WHERE crt.report_template_id=outerjoin(ep.template_id))
   ORDER BY d.seq
   HEAD d.seq
    triggers->trigger[d.seq].chart_content_flag = ep.chart_content_flag, triggers->trigger[d.seq].
    chart_format = cf.chart_format_desc, triggers->trigger[d.seq].report_template = crt.template_name,
    triggers->trigger[d.seq].output_flag = ep.output_flag, triggers->trigger[d.seq].output_name = od
    .name, triggers->trigger[d.seq].exp_prov_ind = ep.exp_prov_ind,
    triggers->trigger[d.seq].param_name = ep.name, copy_cnt = 0
   DETAIL
    IF (ep.copy_ind=1)
     copy_cnt = (copy_cnt+ 1), stat = alterlist(triggers->trigger[d.seq].copy,copy_cnt), triggers->
     trigger[d.seq].copy[copy_cnt].encntr_prsnl_r_disp = uar_get_code_display(ec.encntr_prsnl_r_cd)
    ENDIF
   WITH nocounter
  ;end select
  IF (path_fld_exists=2)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt),
     expedite_params ep
    PLAN (d)
     JOIN (ep
     WHERE (ep.expedite_params_id=triggers->trigger[d.seq].params_id))
    DETAIL
     triggers->trigger[d.seq].pathology_ind = ep.pathologist_default_ind
    WITH nocounter
   ;end select
  ENDIF
  IF (sending_org_fld_exists=2)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt),
     expedite_params ep
    PLAN (d)
     JOIN (ep
     WHERE (ep.expedite_params_id=triggers->trigger[d.seq].params_id))
    DETAIL
     triggers->trigger[d.seq].sending_org_id = ep.sending_org_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (t = 1 TO tcnt)
   IF ((triggers->trigger[t].assay_cnt > 0)
    AND (triggers->trigger[t].coded_resp_ind=1))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(triggers->trigger[t].assay_cnt)),
      expedite_coded_resp ecr,
      code_value cv,
      nomenclature n
     PLAN (d
      WHERE (triggers->trigger[t].assay[d.seq].coded_resp_ind=1))
      JOIN (ecr
      WHERE (ecr.expedite_trigger_id=triggers->trigger[t].assay[d.seq].expedite_trigger_id))
      JOIN (cv
      WHERE cv.code_value=outerjoin(ecr.coded_response_cd)
       AND cv.active_ind=outerjoin(1))
      JOIN (n
      WHERE n.nomenclature_id=outerjoin(ecr.nomenclature_id)
       AND n.active_ind=outerjoin(1))
     ORDER BY ecr.expedite_trigger_id
     HEAD ecr.expedite_trigger_id
      coded_resp_cnt = 0
     DETAIL
      coded_resp_cnt = (coded_resp_cnt+ 1), triggers->trigger[t].assay[d.seq].coded_resp_cnt =
      coded_resp_cnt, stat = alterlist(triggers->trigger[t].assay[d.seq].coded_resp,coded_resp_cnt)
      IF (ecr.coded_response_cd > 0)
       triggers->trigger[t].assay[d.seq].coded_resp[coded_resp_cnt].mnemonic = cv.display
      ELSE
       triggers->trigger[t].assay[d.seq].coded_resp[coded_resp_cnt].mnemonic = n.mnemonic
      ENDIF
      IF (n.source_vocabulary_cd=src_vocab_cd)
       IF (n.principle_type_cd=org_pri_type_cd)
        triggers->trigger[t].assay[d.seq].coded_resp[coded_resp_cnt].mnemonic = concat(trim(n
          .mnemonic)," (organism)")
       ENDIF
       IF (n.principle_type_cd=grp_pri_type_cd)
        triggers->trigger[t].assay[d.seq].coded_resp[coded_resp_cnt].mnemonic = concat(trim(n
          .mnemonic)," (group)")
       ENDIF
       IF (n.principle_type_cd=det_pri_type_cd)
        triggers->trigger[t].assay[d.seq].coded_resp[coded_resp_cnt].mnemonic = concat(trim(n
          .mnemonic)," (detail)")
       ENDIF
      ENDIF
      triggers->trigger[t].assay[d.seq].coded_resp_cnt = coded_resp_cnt
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (t = 1 TO tcnt)
   IF ((triggers->trigger[t].location_cnt > 0))
    FOR (l = 1 TO triggers->trigger[t].location_cnt)
      SET tree_cnt = 1
      SET stat = alterlist(tree->qual,tree_cnt)
      SET child_cd = triggers->trigger[t].location[l].code_value
      SET tree->qual[1].code_value = child_cd
      EXECUTE exp_build_loc_tree
      SET stat = alterlist(triggers->trigger[t].location[l].tree,tree_cnt)
      IF (tree_cnt > 0)
       SELECT INTO "NL:"
        FROM (dummyt d  WITH seq = tree_cnt)
        ORDER BY d.seq DESC
        HEAD REPORT
         loc_tree_cnt = 0
        DETAIL
         loc_tree_cnt = (loc_tree_cnt+ 1), triggers->trigger[t].location[l].tree[loc_tree_cnt].
         code_value = tree->qual[d.seq].code_value
        WITH nocounter
       ;end select
       SET triggers->trigger[t].location[l].tree_cnt = tree_cnt
      ENDIF
      IF ((triggers->trigger[t].location[l].tree_cnt > 0))
       SELECT INTO "NL:"
        FROM (dummyt d  WITH seq = value(triggers->trigger[t].location[l].tree_cnt)),
         code_value cv
        PLAN (d)
         JOIN (cv
         WHERE (cv.code_value=triggers->trigger[t].location[l].tree[d.seq].code_value)
          AND cv.active_ind=1)
        DETAIL
         triggers->trigger[t].location[l].tree[d.seq].description = cv.description
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = uar_get_meaning_by_codeset(43,"INTSECEMAIL",1,intsecemail_cd)
 FOR (t = 1 TO tcnt)
   IF ((triggers->trigger[t].sending_org_id > 0))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tcnt),
      organization o
     PLAN (d)
      JOIN (o
      WHERE (o.organization_id=triggers->trigger[t].sending_org_id)
       AND o.active_ind=1)
     DETAIL
      triggers->trigger[t].sending_org_name = o.org_name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tcnt),
      phone p
     PLAN (d)
      JOIN (p
      WHERE (p.parent_entity_id=triggers->trigger[t].sending_org_id)
       AND p.active_ind=1
       AND p.phone_type_cd=intsecemail_cd)
     DETAIL
      triggers->trigger[t].sending_org_email = p.phone_num
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->collist,29)
 SET reply->collist[1].header_text = "Expedite Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Qualify Based on Report Priority"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Qualify Based on Result Range"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Qualify Based on Result Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Expedite Non-Discharged Patients"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Expedite Discharged Patients"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Qualify Complete Orders Only"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Facility"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Building"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Nursing/Ambulatory/Other"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Room/Bed"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Location Criteria"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Qualify Based on Service Resource"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Qualify Based on Ordering Provider"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Qualify Based on Organization"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Results to Qualify Type"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Results to Qualify"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Micro / Radiology Report Processing"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Micro Positive / Negative"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Susceptibility/Antibiotic Result Action"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Param Name"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Expedite Routing"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Sending Organization"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Chart Format"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Report Template"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Additional Copies for Selected Provider Types"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Exclude Expired Relationships"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Cumulative Chart"
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = "Default to Responsible Pathologist"
 SET reply->collist[29].data_type = 1
 SET reply->collist[29].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (t = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,29)
   SET reply->rowlist[row_nbr].celllist[1].string_value = triggers->trigger[t].trigger_name
   SET reply->rowlist[row_nbr].celllist[21].string_value = triggers->trigger[t].param_name
   IF ((triggers->trigger[t].pathology_ind=1))
    SET reply->rowlist[row_nbr].celllist[29].string_value = "Yes"
   ELSEIF ((triggers->trigger[t].pathology_ind=0))
    SET reply->rowlist[row_nbr].celllist[29].string_value = "No"
   ENDIF
   FOR (x = 1 TO size(triggers->trigger[t].sa_result_action,5))
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[20].string_value = trim(triggers->trigger[t].
       sa_result_action[x].description)
     ELSE
      SET reply->rowlist[row_nbr].celllist[20].string_value = build2(reply->rowlist[row_nbr].
       celllist[20].string_value,", ",trim(triggers->trigger[t].sa_result_action[x].description))
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].priority_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[2].string_value = trim(triggers->trigger[t].priority[x].
       display)
     ELSE
      SET reply->rowlist[row_nbr].celllist[2].string_value = build2(reply->rowlist[row_nbr].celllist[
       2].string_value,", ",trim(triggers->trigger[t].priority[x].display))
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].result_range_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[3].string_value = trim(triggers->trigger[t].result_range[x
       ].display)
     ELSE
      SET reply->rowlist[row_nbr].celllist[3].string_value = build2(reply->rowlist[row_nbr].celllist[
       3].string_value,", ",trim(triggers->trigger[t].result_range[x].display))
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].result_status_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[4].string_value = trim(triggers->trigger[t].result_status[
       x].display)
     ELSE
      SET reply->rowlist[row_nbr].celllist[4].string_value = build2(reply->rowlist[row_nbr].celllist[
       4].string_value,", ",trim(triggers->trigger[t].result_status[x].display))
     ENDIF
   ENDFOR
   IF ((triggers->trigger[t].discharged_flag=0))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "Yes"
    SET reply->rowlist[row_nbr].celllist[6].string_value = "Yes"
   ELSEIF ((triggers->trigger[t].discharged_flag=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "Yes"
    SET reply->rowlist[row_nbr].celllist[6].string_value = "No"
   ELSEIF ((triggers->trigger[t].discharged_flag=2))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "No"
    SET reply->rowlist[row_nbr].celllist[6].string_value = "Yes"
   ENDIF
   IF ((triggers->trigger[t].order_complete_flag=1))
    SET reply->rowlist[row_nbr].celllist[7].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[7].string_value = "No"
   ENDIF
   IF ((triggers->trigger[t].location_context_flag=1))
    SET reply->rowlist[row_nbr].celllist[12].string_value = "Patient's current location"
   ELSEIF ((triggers->trigger[t].location_context_flag=2))
    SET reply->rowlist[row_nbr].celllist[12].string_value = "Patient's location at time of order"
   ELSEIF ((triggers->trigger[t].location_context_flag=3))
    SET reply->rowlist[row_nbr].celllist[12].string_value = "Order location"
   ELSEIF ((triggers->trigger[t].location_context_flag=8))
    SET reply->rowlist[row_nbr].celllist[12].string_value =
    "Patient's current location, Patient's location at time of order"
   ELSEIF ((triggers->trigger[t].location_context_flag=6))
    SET reply->rowlist[row_nbr].celllist[12].string_value =
    "Patient's current location, Order location"
   ELSEIF ((triggers->trigger[t].location_context_flag=7))
    SET reply->rowlist[row_nbr].celllist[12].string_value =
    "Patient's location at time of order, Order location"
   ELSEIF ((triggers->trigger[t].location_context_flag=9))
    SET reply->rowlist[row_nbr].celllist[12].string_value =
    "Patient's current location, Patient's location at time of order, Order location"
   ENDIF
   FOR (x = 1 TO triggers->trigger[t].service_resource_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[13].string_value = trim(triggers->trigger[t].
       service_resource[x].description)
     ELSE
      SET reply->rowlist[row_nbr].celllist[13].string_value = build2(reply->rowlist[row_nbr].
       celllist[13].string_value,", ",trim(triggers->trigger[t].service_resource[x].description))
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].provider_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[14].string_value = trim(triggers->trigger[t].provider[x].
       name)
     ELSE
      SET reply->rowlist[row_nbr].celllist[14].string_value = build2(reply->rowlist[row_nbr].
       celllist[14].string_value,"; ",trim(triggers->trigger[t].provider[x].name))
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].organization_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[15].string_value = trim(triggers->trigger[t].organization[
       x].org_name)
     ELSE
      SET reply->rowlist[row_nbr].celllist[15].string_value = build2(reply->rowlist[row_nbr].
       celllist[15].string_value,", ",trim(triggers->trigger[t].organization[x].org_name))
     ENDIF
   ENDFOR
   IF ((triggers->trigger[t].catalog_cnt > 0))
    SET reply->rowlist[row_nbr].celllist[16].string_value = "Order Catalog Types"
   ELSEIF ((triggers->trigger[t].activity_cnt > 0))
    SET reply->rowlist[row_nbr].celllist[16].string_value = "Activity Types"
   ELSEIF ((triggers->trigger[t].orc_cnt > 0))
    SET reply->rowlist[row_nbr].celllist[16].string_value = "Order Catalog Items"
   ELSEIF ((triggers->trigger[t].assay_cnt > 0)
    AND (triggers->trigger[t].assay[1].coded_resp_ind=0))
    SET reply->rowlist[row_nbr].celllist[16].string_value = "Task Assays"
   ELSEIF ((triggers->trigger[t].assay_cnt > 0)
    AND (triggers->trigger[t].assay[1].coded_resp_ind=1))
    SET reply->rowlist[row_nbr].celllist[16].string_value = "Coded Responses"
   ENDIF
   IF ((triggers->trigger[t].catalog_cnt > 0))
    FOR (x = 1 TO triggers->trigger[t].catalog_cnt)
      IF (x=1)
       SET reply->rowlist[row_nbr].celllist[17].string_value = trim(triggers->trigger[t].catalog[x].
        display)
      ELSE
       SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
        celllist[17].string_value,", ",trim(triggers->trigger[t].catalog[x].display))
      ENDIF
    ENDFOR
   ELSEIF ((triggers->trigger[t].activity_cnt > 0))
    FOR (x = 1 TO triggers->trigger[t].activity_cnt)
      IF (x=1)
       SET reply->rowlist[row_nbr].celllist[17].string_value = trim(triggers->trigger[t].activity[x].
        display)
      ELSE
       SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
        celllist[17].string_value,", ",trim(triggers->trigger[t].activity[x].display))
      ENDIF
    ENDFOR
   ELSEIF ((triggers->trigger[t].orc_cnt > 0))
    FOR (x = 1 TO triggers->trigger[t].orc_cnt)
      IF (x=1)
       SET reply->rowlist[row_nbr].celllist[17].string_value = trim(triggers->trigger[t].orc[x].
        mnemonic)
      ELSE
       SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
        celllist[17].string_value,", ",trim(triggers->trigger[t].orc[x].mnemonic))
      ENDIF
    ENDFOR
   ELSEIF ((triggers->trigger[t].assay_cnt > 0))
    FOR (x = 1 TO triggers->trigger[t].assay_cnt)
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[17].string_value = trim(triggers->trigger[t].assay[x].
       display)
     ELSE
      SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
       celllist[17].string_value,", ",trim(triggers->trigger[t].assay[x].display))
     ENDIF
     IF ((triggers->trigger[t].assay[x].coded_resp_ind=1))
      FOR (y = 1 TO triggers->trigger[t].assay[x].coded_resp_cnt)
        IF (y=1
         AND (triggers->trigger[t].assay[x].coded_resp_cnt=1))
         SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
          celllist[17].string_value," (",trim(triggers->trigger[t].assay[x].coded_resp[y].mnemonic),
          ")")
        ELSEIF (y=1
         AND (triggers->trigger[t].assay[x].coded_resp_cnt > 1))
         SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
          celllist[17].string_value," (",trim(triggers->trigger[t].assay[x].coded_resp[y].mnemonic))
        ELSEIF ((y=triggers->trigger[t].assay[x].coded_resp_cnt))
         SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
          celllist[17].string_value,", ",trim(triggers->trigger[t].assay[x].coded_resp[y].mnemonic),
          ")")
        ELSE
         SET reply->rowlist[row_nbr].celllist[17].string_value = build2(reply->rowlist[row_nbr].
          celllist[17].string_value,", ",trim(triggers->trigger[t].assay[x].coded_resp[y].mnemonic))
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   FOR (x = 1 TO triggers->trigger[t].report_processing_cnt)
     IF (x=1)
      IF ((triggers->trigger[t].report_processing[x].nbr=0))
       SET reply->rowlist[row_nbr].celllist[18].string_value = build2("All ",trim(triggers->trigger[t
         ].report_processing[x].display))
      ELSE
       SET reply->rowlist[row_nbr].celllist[18].string_value = build2(trim(cnvtstring(triggers->
          trigger[t].report_processing[x].nbr))," ",trim(triggers->trigger[t].report_processing[x].
         display))
      ENDIF
     ELSE
      IF ((triggers->trigger[t].report_processing[x].nbr=0))
       SET reply->rowlist[row_nbr].celllist[18].string_value = build2(reply->rowlist[row_nbr].
        celllist[18].string_value,", All ",trim(triggers->trigger[t].report_processing[x].display))
      ELSE
       SET reply->rowlist[row_nbr].celllist[18].string_value = build2(reply->rowlist[row_nbr].
        celllist[18].string_value,", ",trim(cnvtstring(triggers->trigger[t].report_processing[x].nbr)
         )," ",trim(triggers->trigger[t].report_processing[x].display))
      ENDIF
     ENDIF
   ENDFOR
   FOR (x = 1 TO triggers->trigger[t].result_cnt)
     IF (x=1)
      IF ((triggers->trigger[t].result[x].nbr=0))
       SET reply->rowlist[row_nbr].celllist[19].string_value = build2("All ",trim(triggers->trigger[t
         ].result[x].display))
      ELSE
       SET reply->rowlist[row_nbr].celllist[19].string_value = build2(trim(cnvtstring(triggers->
          trigger[t].result[x].nbr))," ",trim(triggers->trigger[t].result[x].display))
      ENDIF
     ELSE
      IF ((triggers->trigger[t].result[x].nbr=0))
       SET reply->rowlist[row_nbr].celllist[19].string_value = build2(reply->rowlist[row_nbr].
        celllist[19].string_value,", All ",trim(triggers->trigger[t].result[x].display))
      ELSE
       SET reply->rowlist[row_nbr].celllist[19].string_value = build2(reply->rowlist[row_nbr].
        celllist[19].string_value,", ",trim(cnvtstring(triggers->trigger[t].result[x].nbr))," ",trim(
         triggers->trigger[t].result[x].display))
      ENDIF
     ENDIF
   ENDFOR
   IF ((triggers->trigger[t].output_flag=1))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Patient location"
   ELSEIF ((triggers->trigger[t].output_flag=2))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Patient location at time of order"
   ELSEIF ((triggers->trigger[t].output_flag=7))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Order location"
   ELSEIF ((triggers->trigger[t].output_flag=3))
    SET reply->rowlist[row_nbr].celllist[22].string_value =
    "Patient location and patient location at time of order and order location"
   ELSEIF ((triggers->trigger[t].output_flag=8))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Patient's temporary location"
   ELSEIF ((triggers->trigger[t].output_flag=9))
    SET reply->rowlist[row_nbr].celllist[22].string_value =
    "Both temporary location and patient location"
   ELSEIF ((triggers->trigger[t].output_flag=4))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Service resource"
   ELSEIF ((triggers->trigger[t].output_flag=5))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Organization"
   ELSEIF ((triggers->trigger[t].output_flag=6))
    SET reply->rowlist[row_nbr].celllist[22].string_value = "Selected provider types"
   ELSEIF ((triggers->trigger[t].output_flag=0))
    SET reply->rowlist[row_nbr].celllist[22].string_value = build2("Assigned device: ",triggers->
     trigger[t].output_name)
   ENDIF
   IF ((triggers->trigger[t].sending_org_name=null))
    SET reply->rowlist[row_nbr].celllist[23].string_value = " "
   ELSEIF ((triggers->trigger[t].sending_org_email=null))
    SET reply->rowlist[row_nbr].celllist[23].string_value = triggers->trigger[t].sending_org_name
   ELSE
    SET reply->rowlist[row_nbr].celllist[23].string_value = build2(triggers->trigger[t].
     sending_org_name," (",triggers->trigger[t].sending_org_email,")")
   ENDIF
   SET reply->rowlist[row_nbr].celllist[24].string_value = triggers->trigger[t].chart_format
   SET reply->rowlist[row_nbr].celllist[25].string_value = triggers->trigger[t].report_template
   FOR (x = 1 TO size(triggers->trigger[t].copy,5))
     IF (x=1)
      SET reply->rowlist[row_nbr].celllist[26].string_value = trim(triggers->trigger[t].copy[x].
       encntr_prsnl_r_disp)
     ELSE
      SET reply->rowlist[row_nbr].celllist[26].string_value = build2(reply->rowlist[row_nbr].
       celllist[26].string_value,", ",trim(triggers->trigger[t].copy[x].encntr_prsnl_r_disp))
     ENDIF
   ENDFOR
   IF ((triggers->trigger[t].exp_prov_ind=1))
    SET reply->rowlist[row_nbr].celllist[27].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[27].string_value = "No"
   ENDIF
   IF ((triggers->trigger[t].chart_content_flag=0))
    SET reply->rowlist[row_nbr].celllist[28].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[28].string_value = "No"
   ENDIF
   FOR (l = 1 TO triggers->trigger[t].location_cnt)
    FOR (r = 1 TO triggers->trigger[t].location[l].tree_cnt)
      IF (r=1)
       SET reply->rowlist[row_nbr].celllist[8].string_value = triggers->trigger[t].location[l].tree[r
       ].description
      ELSEIF (r=2)
       SET reply->rowlist[row_nbr].celllist[9].string_value = triggers->trigger[t].location[l].tree[r
       ].description
      ELSEIF (r=3)
       SET reply->rowlist[row_nbr].celllist[10].string_value = triggers->trigger[t].location[l].tree[
       r].description
      ELSEIF (r=4)
       SET reply->rowlist[row_nbr].celllist[11].string_value = triggers->trigger[t].location[l].tree[
       r].description
      ELSEIF (r=5)
       SET reply->rowlist[row_nbr].celllist[11].string_value = build2(reply->rowlist[row_nbr].
        celllist[11].string_value," / ",trim(triggers->trigger[t].location[l].tree[r].description))
      ENDIF
    ENDFOR
    IF ((l < triggers->trigger[t].location_cnt))
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,29)
    ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE build_expedite_ids(dummyvar)
   DECLARE parse_expedite_id = vc WITH protect
   DECLARE expedite_cnt = f8 WITH protect
   FOR (exp_cnt = 1 TO size(request->expedites,5))
     IF (expedite_cnt > 999)
      SET parse_expedite_id = replace(parse_expedite_id,",","",2)
      SET parse_expedite_id = build(parse_expedite_id,") or et.expedite_trigger_id in (")
      SET expedite_cnt = 0
     ENDIF
     SET parse_expedite_id = build(parse_expedite_id,request->expedites[exp_cnt].expedite_id,",")
     SET expedite_cnt = (expedite_cnt+ 1)
   ENDFOR
   SET parse_expedite_id = replace(parse_expedite_id,",","",2)
   IF (size(request->expedites,5) > 0)
    SET exp_parse = build(exp_parse," and et.expedite_trigger_id in (",parse_expedite_id,")")
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("clinical_reporting_expedites_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
