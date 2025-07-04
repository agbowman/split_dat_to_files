CREATE PROGRAM bed_get_catalog_filters:dba
 FREE SET reply
 RECORD reply(
   1 catalog_type_list[*]
     2 catalog_type_code_value = f8
     2 catalog_type_display = c40
     2 catalog_type_mean = vc
     2 activity_type_list[*]
       3 activity_type_code_value = f8
       3 activity_type_display = c40
       3 activity_type_mean = vc
       3 subactivity_type_list[*]
         4 subactivity_type_code_value = f8
         4 subactivity_type_display = c40
         4 subactivity_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
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
 DECLARE catalog_index = i4 WITH protect, noconstant(0)
 DECLARE activity_index = i4 WITH protect, noconstant(0)
 DECLARE subactivity_index = i4 WITH protect, noconstant(0)
 DECLARE prev_catalog = f8 WITH protect, noconstant(0.0)
 DECLARE prev_activity = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET catalog_index = 0
 SET activity_index = 0
 SET subactivity_index = 0
 SET prev_catalog = 0
 SET prev_activity = 0
 SET list_sub = 0
 SET list_act = 0
 SET list_cat = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 SELECT INTO "NL:"
  FROM code_value cv6000,
   code_value cv106,
   code_value cv5801,
   dummyt d1,
   dummyt d2
  PLAN (cv6000
   WHERE cv6000.code_set=6000
    AND cv6000.active_ind=1)
   JOIN (d1)
   JOIN (cv106
   WHERE cv106.code_set=106
    AND cv106.active_ind=1
    AND cnvtupper(cv106.definition)=cv6000.cdf_meaning)
   JOIN (d2)
   JOIN (cv5801
   WHERE cv5801.code_set=5801
    AND cv5801.active_ind=1
    AND cnvtupper(cv5801.definition)=cv106.cdf_meaning)
  DETAIL
   IF (cv6000.code_value != prev_catalog)
    catalog_index = (catalog_index+ 1), stat = alterlist(reply->catalog_type_list,catalog_index),
    reply->catalog_type_list[catalog_index].catalog_type_code_value = cv6000.code_value,
    reply->catalog_type_list[catalog_index].catalog_type_display = cv6000.display, reply->
    catalog_type_list[catalog_index].catalog_type_mean = cv6000.cdf_meaning, prev_catalog = cv6000
    .code_value,
    prev_activity = 0, activity_index = 0, subactivity_index = 0,
    list_act = 0, list_sub = 0
   ENDIF
   IF (cv106.code_value != prev_activity
    AND cv106.code_value > 0)
    activity_index = (activity_index+ 1), stat = alterlist(reply->catalog_type_list[catalog_index].
     activity_type_list,activity_index), reply->catalog_type_list[catalog_index].activity_type_list[
    activity_index].activity_type_code_value = cv106.code_value,
    reply->catalog_type_list[catalog_index].activity_type_list[activity_index].activity_type_display
     = cv106.display, reply->catalog_type_list[catalog_index].activity_type_list[activity_index].
    activity_type_mean = cv106.cdf_meaning, prev_activity = cv106.code_value,
    subactivity_index = 0, list_sub = 0
   ENDIF
   IF (cv5801.code_value > 0)
    subactivity_index = (subactivity_index+ 1), stat = alterlist(reply->catalog_type_list[
     catalog_index].activity_type_list[activity_index].subactivity_type_list,subactivity_index),
    reply->catalog_type_list[catalog_index].activity_type_list[activity_index].subactivity_type_list[
    subactivity_index].subactivity_type_code_value = cv5801.code_value,
    reply->catalog_type_list[catalog_index].activity_type_list[activity_index].subactivity_type_list[
    subactivity_index].subactivity_type_display = cv5801.display, reply->catalog_type_list[
    catalog_index].activity_type_list[activity_index].subactivity_type_list[subactivity_index].
    subactivity_type_mean = cv5801.cdf_meaning
   ENDIF
  WITH outerjoin = d1, outerjoin = d2, nocounter
 ;end select
 CALL bederrorcheck("Error 001 - Failed to retrieve catalog, activity and sub-activity types.")
 IF (catalog_index >= max_reply)
  SET stat = alterlist(reply->catalog_type_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSEIF (catalog_index > 0)
  SET reply->status_data.status = "S"
 ELSEIF (catalog_index=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
