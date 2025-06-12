CREATE PROGRAM bed_add_bb_group_type:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 aborh_code_value = f8
    1 abo_code_value = f8
    1 rh_code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 result_code_value = f8
  )
 ENDIF
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET 1641_cd = 0.0
 SET 1642_cd = 0.0
 SET 1640_cd = 0.0
 SET 1643_cd = 0.0
 UPDATE  FROM code_value_extension c
  SET c.field_value = "0"
  PLAN (c
   WHERE operator(c.field_value,"REGEXPLIKE","(^.{0}$)|(\s)")
    AND ((c.field_name="ABOOnly_cd") OR (c.field_name="RhOnly_cd"))
    AND c.code_set=1640)
  WITH nocounter
 ;end update
 CALL bederrorcheck("ERROR 001: Update Fail. CVE field 0")
 IF ((request->abo_text > " "))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 1641
  SET request_cv->cd_value_list[1].display = request->abo_text
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->abo_text))
  SET request_cv->cd_value_list[1].description = request->abo_text
  SET request_cv->cd_value_list[1].definition = request->abo_text
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 1641_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSE
  SET 1641_cd = request->abo_code_value
 ENDIF
 IF ((request->rh_text > " "))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 1642
  SET request_cv->cd_value_list[1].display = request->rh_text
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->rh_text))
  SET request_cv->cd_value_list[1].description = request->rh_text
  SET request_cv->cd_value_list[1].definition = request->rh_text
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 1642_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSE
  SET 1642_cd = request->rh_code_value
 ENDIF
 IF (1641_cd=0
  AND 1642_cd=0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SET request_cv->cd_value_list[1].action_flag = 1
 SET request_cv->cd_value_list[1].code_set = 1640
 SET request_cv->cd_value_list[1].cdf_meaning = request->isbt
 SET request_cv->cd_value_list[1].display = request->display
 SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->display))
 SET request_cv->cd_value_list[1].description = request->description
 SET request_cv->cd_value_list[1].definition = request->description
 SET request_cv->cd_value_list[1].active_ind = 1
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET 1640_cd = reply_cv->qual[1].code_value
 ELSE
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SET request_cv->cd_value_list[1].action_flag = 1
 SET request_cv->cd_value_list[1].code_set = 1643
 IF ((request->meaning="STANDARD"))
  SET request_cv->cd_value_list[1].cdf_meaning = "1"
 ELSEIF ((request->meaning="UNDETERMINED"))
  SET request_cv->cd_value_list[1].cdf_meaning = "2"
 ENDIF
 SET request_cv->cd_value_list[1].display = request->display
 SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->display))
 SET request_cv->cd_value_list[1].description = request->description
 SET request_cv->cd_value_list[1].definition = request->description
 SET request_cv->cd_value_list[1].active_ind = 1
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET 1643_cd = reply_cv->qual[1].code_value
 ELSE
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM code_value_extension cve
  SET cve.code_value = 1640_cd, cve.field_name = "Barcode", cve.code_set = 1640,
   cve.field_type = 1, cve.field_value = request->bar_code, cve.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
   cve.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 CALL bederrorcheck("ERROR 002: INSERT Fail CVE BarCode")
 IF (1641_cd > 0)
  SET ierrcode = 0
  INSERT  FROM code_value_extension cve
   SET cve.code_value = 1640_cd, cve.field_name = "ABOOnly_cd", cve.code_set = 1640,
    cve.field_type = 1, cve.field_value = cnvtstring(1641_cd), cve.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
    cve.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 003: INSERT Fail CVE ABOOnly_cd Non zero")
 ENDIF
 IF (1641_cd=0)
  SET ierrcode = 0
  INSERT  FROM code_value_extension cve
   SET cve.code_value = 1640_cd, cve.field_name = "ABOOnly_cd", cve.code_set = 1640,
    cve.field_type = 1, cve.field_value = "0", cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
    cve.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 004: INSERT Fail CVE ABOOnly_cd zero")
 ENDIF
 IF (1642_cd > 0)
  SET ierrcode = 0
  INSERT  FROM code_value_extension cve
   SET cve.code_value = 1640_cd, cve.field_name = "RhOnly_cd", cve.code_set = 1640,
    cve.field_type = 1, cve.field_value = cnvtstring(1642_cd), cve.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
    cve.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 005: INSERT Fail CVE RhOnly_cd Non zero")
 ENDIF
 IF (1642_cd=0)
  SET ierrcode = 0
  INSERT  FROM code_value_extension cve
   SET cve.code_value = 1640_cd, cve.field_name = "RhOnly_cd", cve.code_set = 1640,
    cve.field_type = 1, cve.field_value = "0", cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
    cve.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  CALL bederrorcheck("ERROR 006: INSERT Fail CVE RhOnly_cd zero")
 ENDIF
 SET ierrcode = 0
 INSERT  FROM code_value_extension cve
  SET cve.code_value = 1643_cd, cve.field_name = "ABORH_cd", cve.code_set = 1643,
   cve.field_type = 1, cve.field_value =
   IF ((request->self_standard_ind=1)) cnvtstring(1640_cd)
   ELSE cnvtstring(request->standard_code_value)
   ENDIF
   , cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
   cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
   cve.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 CALL bederrorcheck("ERROR 007: INSERT Fail CVE ABORH_cd")
 SET ierrcode = 0
 INSERT  FROM code_value_extension cve
  SET cve.code_value = 1643_cd, cve.field_name = "ChartName", cve.code_set = 1643,
   cve.field_type = 1, cve.field_value = request->display, cve.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   cve.updt_id = reqinfo->updt_id, cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task,
   cve.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 CALL bederrorcheck("ERROR 008: INSERT Fail CVE ChartName")
#exit_script
 IF (error_flag="N")
  SET reply->aborh_code_value = 1640_cd
  SET reply->abo_code_value = 1641_cd
  SET reply->rh_code_value = 1642_cd
  SET reply->result_code_value = 1643_cd
 ENDIF
 CALL bedexitscript(1)
END GO
