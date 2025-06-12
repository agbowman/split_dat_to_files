CREATE PROGRAM bed_get_class_mappings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 registries[*]
      2 registry_id = f8
      2 registry_display = vc
      2 active_ind = i2
      2 can_inactivate_ind = i2
    1 condition_sets[*]
      2 condition_set_id = f8
      2 codition_set_display = vc
      2 active_ind = i2
      2 can_inactivate_ind = i2
      2 classifications[*]
        3 he_rule_text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
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
 DECLARE add_definition(id=f8,display=vc,active_ind=i2) = null
 DECLARE add_saved_classifications(dummyvar=i2) = null
 DECLARE determineinactivatestatus(dummyvar=i2) = null
 DECLARE registry_type = i4 WITH protect, constant(1)
 DECLARE condition_set_type = i4 WITH protect, constant(2)
 DECLARE def_cnt = i4 WITH protect, noconstant(0)
 DECLARE rule_cnt = i4 WITH protect, noconstant(0)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
 CALL bedbeginscript(0)
 SET logicaldomainid = bedgetlogicaldomain(0)
 SELECT INTO "nl:"
  FROM ac_class_def def
  PLAN (def
   WHERE (def.class_type_flag=request->class_type_flag)
    AND def.ac_class_def_id > 0
    AND def.logical_domain_id=logicaldomainid)
  DETAIL
   def_cnt = (def_cnt+ 1),
   CALL add_definition(def.ac_class_def_id,def.class_display_name,def.active_ind)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting classification definitions")
 CALL add_saved_classifications(0)
 CALL determineinactivatestatus(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE add_definition(id,display,active_ind)
   IF ((request->class_type_flag=registry_type))
    SET stat = alterlist(reply->registries,def_cnt)
    SET reply->registries[def_cnt].registry_id = id
    SET reply->registries[def_cnt].registry_display = display
    SET reply->registries[def_cnt].active_ind = active_ind
    SET reply->registries[def_cnt].can_inactivate_ind = true
   ELSEIF ((request->class_type_flag=condition_set_type))
    SET stat = alterlist(reply->condition_sets,def_cnt)
    SET reply->condition_sets[def_cnt].condition_set_id = id
    SET reply->condition_sets[def_cnt].codition_set_display = display
    SET reply->condition_sets[def_cnt].active_ind = active_ind
    SET reply->condition_sets[def_cnt].can_inactivate_ind = true
   ENDIF
 END ;Subroutine
 SUBROUTINE add_saved_classifications(dummyvar)
   DECLARE cs_count = i4 WITH protect, noconstant(0)
   SET cs_count = size(reply->condition_sets,5)
   IF (cs_count > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cs_count),
      ac_class_he_rule rule
     PLAN (d)
      JOIN (rule
      WHERE (rule.ac_class_def_id=reply->condition_sets[d.seq].condition_set_id))
     ORDER BY rule.ac_class_def_id
     HEAD rule.ac_class_def_id
      rule_cnt = 0
     DETAIL
      rule_cnt = (rule_cnt+ 1), stat = alterlist(reply->condition_sets[d.seq].classifications,
       rule_cnt), reply->condition_sets[d.seq].classifications[rule_cnt].he_rule_text = rule
      .health_expert_rule_txt
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck("Error setting classifications")
 END ;Subroutine
 SUBROUTINE determineinactivatestatus(dummyvar)
  IF (size(reply->condition_sets,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->condition_sets,5)),
     ac_class_person_reltn acpr
    PLAN (d)
     JOIN (acpr
     WHERE (acpr.ac_class_def_id=reply->condition_sets[d.seq].condition_set_id)
      AND acpr.active_ind=true)
    ORDER BY acpr.ac_class_def_id
    HEAD acpr.ac_class_def_id
     reply->condition_sets[d.seq].can_inactivate_ind = false
    WITH nocounter
   ;end select
  ENDIF
  IF (size(reply->registries,5) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->registries,5)),
     ac_class_person_reltn acpr
    PLAN (d)
     JOIN (acpr
     WHERE (acpr.ac_class_def_id=reply->registries[d.seq].registry_id)
      AND acpr.active_ind=true)
    ORDER BY acpr.ac_class_def_id
    HEAD acpr.ac_class_def_id
     reply->registries[d.seq].can_inactivate_ind = false
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
END GO
