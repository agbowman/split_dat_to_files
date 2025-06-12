CREATE PROGRAM bed_ens_detail_prefs_by_user:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 personnel[*]
      2 application_number = i4
      2 prsnl_id = f8
      2 preferences[*]
        3 preference_id = f8
        3 pvc_name = vc
        3 comp_name = vc
        3 view_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD prefs_to_save(
   1 personnel[*]
     2 application_number = i4
     2 prsnl_id = f8
     2 preferences[*]
       3 action_flag = i2
       3 dp_pref_id = f8
       3 nv_pref_id = f8
       3 comp_name = vc
       3 view_name = vc
       3 pvc_name = vc
       3 pvc_value = vc
 ) WITH protect
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
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE prsnl_cnt = i4 WITH protect, constant(size(request->personnel,5))
 DECLARE temp_prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE populatetempstruct(dummyvar=i2) = null
 DECLARE getnextcarenetseq(dummyvar=i2) = f8
 DECLARE insertnewprefs(dummyvar=i2) = null
 DECLARE updateexistingprefs(dummyvar=i2) = null
 DECLARE populatereply(dummyvar=i2) = null
 CALL bedbeginscript(0)
 IF (prsnl_cnt=0)
  GO TO exit_script
 ENDIF
 CALL populatetempstruct(0)
 CALL insertnewprefs(0)
 CALL updateexistingprefs(0)
 CALL populatereply(0)
 SUBROUTINE populatetempstruct(dummyvar)
   DECLARE pref_cnt = i4 WITH private, noconstant(0)
   DECLARE temp_pref_cnt = i4 WITH private, noconstant(0)
   SET stat = alterlist(prefs_to_save->personnel,prsnl_cnt)
   FOR (temp_prsnl_cnt = 1 TO prsnl_cnt)
     SET prefs_to_save->personnel[temp_prsnl_cnt].application_number = request->personnel[
     temp_prsnl_cnt].application_number
     SET prefs_to_save->personnel[temp_prsnl_cnt].prsnl_id = request->personnel[temp_prsnl_cnt].
     prsnl_id
     SET pref_cnt = size(request->personnel[temp_prsnl_cnt].preferences,5)
     SET stat = alterlist(prefs_to_save->personnel[temp_prsnl_cnt].preferences,pref_cnt)
     FOR (temp_pref_cnt = 1 TO pref_cnt)
       SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].action_flag = request
       ->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].action_flag
       SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].comp_name = request->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].comp_name
       SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].view_name = request->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].view_name
       SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_name = request->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_name
       SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_value = request->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_value
       IF ((request->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].action_flag=add_flag))
        SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].dp_pref_id =
        getnextcarenetseq(0)
        SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].nv_pref_id =
        getnextcarenetseq(0)
       ELSE
        SET prefs_to_save->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].nv_pref_id = request
        ->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].preference_id
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE getnextcarenetseq(dummyvar)
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   RETURN(new_id)
 END ;Subroutine
 SUBROUTINE insertnewprefs(dummyvar)
   DECLARE pref_cnt = i4 WITH private, noconstant(0)
   CALL echorecord(prefs_to_save)
   FOR (temp_prsnl_cnt = 1 TO prsnl_cnt)
    SET pref_cnt = size(prefs_to_save->personnel[temp_prsnl_cnt].preferences,5)
    IF (pref_cnt > 0)
     INSERT  FROM detail_prefs dp,
       (dummyt d  WITH seq = value(pref_cnt))
      SET dp.detail_prefs_id = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].dp_pref_id,
       dp.application_number = prefs_to_save->personnel[temp_prsnl_cnt].application_number, dp
       .position_cd = 0.0,
       dp.prsnl_id = prefs_to_save->personnel[temp_prsnl_cnt].prsnl_id, dp.person_id = 0.0, dp
       .view_name = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].view_name,
       dp.view_seq = 0, dp.comp_name = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].
       comp_name, dp.comp_seq = 0,
       dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
       dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_task = reqinfo->updt_task, dp
       .updt_applctx = reqinfo->updt_applctx
      PLAN (d
       WHERE (prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].action_flag=add_flag))
       JOIN (dp)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("dp insert error")
     INSERT  FROM (dummyt d  WITH seq = value(pref_cnt)),
       name_value_prefs nvp
      SET nvp.name_value_prefs_id = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].
       nv_pref_id, nvp.parent_entity_name = "DETAIL_PREFS", nvp.parent_entity_id = prefs_to_save->
       personnel[temp_prsnl_cnt].preferences[d.seq].dp_pref_id,
       nvp.pvc_name = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].pvc_name, nvp
       .pvc_value = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].pvc_value, nvp
       .active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.sequence = 0
      PLAN (d
       WHERE (prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].action_flag=add_flag))
       JOIN (nvp)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("nvp insert error")
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE updateexistingprefs(dummyvar)
  DECLARE pref_cnt = i4 WITH private, noconstant(0)
  FOR (temp_prsnl_cnt = 1 TO prsnl_cnt)
   SET pref_cnt = size(prefs_to_save->personnel[temp_prsnl_cnt].preferences,5)
   IF (pref_cnt > 0)
    UPDATE  FROM (dummyt d  WITH seq = value(pref_cnt)),
      name_value_prefs nvp
     SET nvp.pvc_value = prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].pvc_value, nvp
      .updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].action_flag=update_flag))
      JOIN (nvp
      WHERE (nvp.name_value_prefs_id=prefs_to_save->personnel[temp_prsnl_cnt].preferences[d.seq].
      nv_pref_id))
     WITH nocounter
    ;end update
    CALL bederrorcheck("nvp update error")
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE populatereply(dummyvar)
   DECLARE pref_cnt = i4 WITH private, noconstant(0)
   DECLARE temp_pref_cnt = i4 WITH private, noconstant(0)
   SET stat = alterlist(reply->personnel,prsnl_cnt)
   FOR (temp_prsnl_cnt = 1 TO prsnl_cnt)
     SET reply->personnel[temp_prsnl_cnt].application_number = prefs_to_save->personnel[
     temp_prsnl_cnt].application_number
     SET reply->personnel[temp_prsnl_cnt].prsnl_id = prefs_to_save->personnel[temp_prsnl_cnt].
     prsnl_id
     SET pref_cnt = size(prefs_to_save->personnel[temp_prsnl_cnt].preferences,5)
     SET stat = alterlist(reply->personnel[temp_prsnl_cnt].preferences,pref_cnt)
     FOR (temp_pref_cnt = 1 TO pref_cnt)
       SET reply->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].comp_name = prefs_to_save->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].comp_name
       SET reply->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].view_name = prefs_to_save->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].view_name
       SET reply->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_name = prefs_to_save->
       personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].pvc_name
       SET reply->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].preference_id = prefs_to_save
       ->personnel[temp_prsnl_cnt].preferences[temp_pref_cnt].nv_pref_id
     ENDFOR
   ENDFOR
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
