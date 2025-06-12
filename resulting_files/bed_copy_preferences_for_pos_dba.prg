CREATE PROGRAM bed_copy_preferences_for_pos:dba
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
 DECLARE copyviewpreferences(frompositioncd=f8,topositioncd=f8) = i2
 DECLARE copyviewcomppreferences(frompositioncd=f8,topositioncd=f8) = i2
 DECLARE copydetailpreferences(frompositioncd=f8,topositioncd=f8) = i2
 DECLARE copyapppreferences(frompositioncd=f8,topositioncd=f8) = i2
 DECLARE copynamevaluepreferences(frompositioncd=f8,topositioncd=f8) = i2
 CALL copyviewpreferences(request->copy_from_position_cd,request->copy_to_position_cd)
 CALL copyviewcomppreferences(request->copy_from_position_cd,request->copy_to_position_cd)
 CALL copydetailpreferences(request->copy_from_position_cd,request->copy_to_position_cd)
 CALL copyapppreferences(request->copy_from_position_cd,request->copy_to_position_cd)
 CALL copynamevaluepreferences(request->copy_from_position_cd,request->copy_to_position_cd)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE copyviewpreferences(frompositioncd,topositioncd)
   CALL bedlogmessage("copyViewPreferences()","Entering...")
   FREE RECORD viewprefs
   RECORD viewprefs(
     1 prefs[*]
       2 application_number = f8
       2 prsnl_id = f8
       2 frame_type = vc
       2 view_name = vc
       2 view_seq = i4
   )
   DECLARE vpcnt = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    vp.application_number, vp.prsnl_id, vp.frame_type,
    vp.view_name, vp.view_seq
    FROM view_prefs vp
    PLAN (vp
     WHERE vp.position_cd=frompositioncd
      AND vp.active_ind=true)
    ORDER BY vp.application_number, vp.prsnl_id, vp.frame_type,
     vp.view_name, vp.view_seq
    DETAIL
     vpcnt = (vpcnt+ 1), stat = alterlist(viewprefs->prefs,vpcnt), viewprefs->prefs[vpcnt].
     application_number = vp.application_number,
     viewprefs->prefs[vpcnt].prsnl_id = vp.prsnl_id, viewprefs->prefs[vpcnt].frame_type = vp
     .frame_type, viewprefs->prefs[vpcnt].view_name = vp.view_name,
     viewprefs->prefs[vpcnt].view_seq = vp.view_seq
    WITH nocounter
   ;end select
   IF (vpcnt > 0)
    INSERT  FROM view_prefs vp,
      (dummyt d  WITH seq = vpcnt)
     SET vp.view_prefs_id = seq(carenet_seq,nextval), vp.application_number = viewprefs->prefs[d.seq]
      .application_number, vp.position_cd = topositioncd,
      vp.prsnl_id = viewprefs->prefs[d.seq].prsnl_id, vp.frame_type = viewprefs->prefs[d.seq].
      frame_type, vp.view_name = viewprefs->prefs[d.seq].view_name,
      vp.view_seq = viewprefs->prefs[d.seq].view_seq, vp.active_ind = 1, vp.updt_id = reqinfo->
      updt_id,
      vp.updt_cnt = 0, vp.updt_task = reqinfo->updt_task, vp.updt_applctx = reqinfo->updt_applctx,
      vp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (vp)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert view preferences.")
   ENDIF
   CALL bedlogmessage("copyViewPreferences()","Exiting...")
 END ;Subroutine
 SUBROUTINE copyviewcomppreferences(frompositioncd,topositioncd)
   CALL bedlogmessage("copyViewCompPreferences()","Entering...")
   FREE RECORD viewcompprefs
   RECORD viewcompprefs(
     1 prefs[*]
       2 application_number = f8
       2 prsnl_id = f8
       2 view_name = vc
       2 view_seq = i4
       2 comp_name = vc
       2 comp_seq = i4
   )
   DECLARE vcpcnt = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    vcp.application_number, vcp.prsnl_id, vcp.view_name,
    vcp.view_seq, vcp.comp_name, vcp.comp_seq
    FROM view_comp_prefs vcp
    PLAN (vcp
     WHERE vcp.position_cd=frompositioncd
      AND vcp.active_ind=true)
    ORDER BY vcp.application_number, vcp.prsnl_id, vcp.view_name,
     vcp.view_seq, vcp.comp_name, vcp.comp_seq
    DETAIL
     vcpcnt = (vcpcnt+ 1), stat = alterlist(viewcompprefs->prefs,vcpcnt), viewcompprefs->prefs[vcpcnt
     ].application_number = vcp.application_number,
     viewcompprefs->prefs[vcpcnt].prsnl_id = vcp.prsnl_id, viewcompprefs->prefs[vcpcnt].view_name =
     vcp.view_name, viewcompprefs->prefs[vcpcnt].view_seq = vcp.view_seq,
     viewcompprefs->prefs[vcpcnt].comp_name = vcp.comp_name, viewcompprefs->prefs[vcpcnt].comp_seq =
     vcp.comp_seq
    WITH nocounter
   ;end select
   IF (vcpcnt > 0)
    INSERT  FROM view_comp_prefs vcp,
      (dummyt d  WITH seq = vcpcnt)
     SET vcp.view_comp_prefs_id = seq(carenet_seq,nextval), vcp.application_number = viewcompprefs->
      prefs[d.seq].application_number, vcp.position_cd = topositioncd,
      vcp.prsnl_id = viewcompprefs->prefs[d.seq].prsnl_id, vcp.view_name = viewcompprefs->prefs[d.seq
      ].view_name, vcp.view_seq = viewcompprefs->prefs[d.seq].view_seq,
      vcp.comp_name = viewcompprefs->prefs[d.seq].comp_name, vcp.comp_seq = viewcompprefs->prefs[d
      .seq].comp_seq, vcp.active_ind = 1,
      vcp.updt_id = reqinfo->updt_id, vcp.updt_cnt = 0, vcp.updt_task = reqinfo->updt_task,
      vcp.updt_applctx = reqinfo->updt_applctx, vcp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (vcp)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert view comp preferences.")
   ENDIF
   CALL bedlogmessage("copyViewCompPreferences()","Exiting...")
 END ;Subroutine
 SUBROUTINE copydetailpreferences(frompositioncd,topositioncd)
   CALL bedlogmessage("copyDetailPreferences()","Entering...")
   FREE RECORD viewdetailprefs
   RECORD viewdetailprefs(
     1 prefs[*]
       2 application_number = f8
       2 prsnl_id = f8
       2 person_id = f8
       2 view_name = vc
       2 view_seq = i4
       2 comp_name = vc
       2 comp_seq = i4
   )
   DECLARE dpcnt = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    dp.application_number, dp.prsnl_id, dp.person_id,
    dp.view_name, dp.view_seq, dp.comp_name,
    dp.comp_seq
    FROM detail_prefs dp
    PLAN (dp
     WHERE dp.position_cd=frompositioncd
      AND dp.active_ind=true)
    ORDER BY dp.application_number, dp.prsnl_id, dp.person_id,
     dp.view_name, dp.view_seq, dp.comp_name,
     dp.comp_seq
    DETAIL
     dpcnt = (dpcnt+ 1), stat = alterlist(viewdetailprefs->prefs,dpcnt), viewdetailprefs->prefs[dpcnt
     ].application_number = dp.application_number,
     viewdetailprefs->prefs[dpcnt].prsnl_id = dp.prsnl_id, viewdetailprefs->prefs[dpcnt].person_id =
     dp.person_id, viewdetailprefs->prefs[dpcnt].view_name = dp.view_name,
     viewdetailprefs->prefs[dpcnt].view_seq = dp.view_seq, viewdetailprefs->prefs[dpcnt].comp_name =
     dp.comp_name, viewdetailprefs->prefs[dpcnt].comp_seq = dp.comp_seq
    WITH nocounter
   ;end select
   IF (dpcnt > 0)
    INSERT  FROM detail_prefs dp,
      (dummyt d  WITH seq = dpcnt)
     SET dp.detail_prefs_id = seq(carenet_seq,nextval), dp.application_number = viewdetailprefs->
      prefs[d.seq].application_number, dp.position_cd = topositioncd,
      dp.prsnl_id = viewdetailprefs->prefs[d.seq].prsnl_id, dp.person_id = viewdetailprefs->prefs[d
      .seq].person_id, dp.view_name = viewdetailprefs->prefs[d.seq].view_name,
      dp.view_seq = viewdetailprefs->prefs[d.seq].view_seq, dp.comp_name = viewdetailprefs->prefs[d
      .seq].comp_name, dp.comp_seq = viewdetailprefs->prefs[d.seq].comp_seq,
      dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
      dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (dp)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert view detail preferences.")
   ENDIF
   CALL bedlogmessage("copyDetailPreferences()","Exiting...")
 END ;Subroutine
 SUBROUTINE copyapppreferences(frompositioncd,topositioncd)
   CALL bedlogmessage("copyAppPreferences()","Entering...")
   FREE RECORD appprefs
   RECORD appprefs(
     1 prefs[*]
       2 application_number = f8
       2 prsnl_id = f8
   )
   DECLARE appcnt = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    ap.application_number, ap.prsnl_id
    FROM app_prefs ap
    PLAN (ap
     WHERE ap.position_cd=frompositioncd
      AND ap.active_ind=true)
    ORDER BY ap.application_number, ap.prsnl_id
    DETAIL
     appcnt = (appcnt+ 1), stat = alterlist(appprefs->prefs,appcnt), appprefs->prefs[appcnt].
     application_number = ap.application_number,
     appprefs->prefs[appcnt].prsnl_id = ap.prsnl_id
    WITH nocounter
   ;end select
   IF (appcnt > 0)
    INSERT  FROM app_prefs ap,
      (dummyt d  WITH seq = appcnt)
     SET ap.app_prefs_id = seq(carenet_seq,nextval), ap.application_number = appprefs->prefs[d.seq].
      application_number, ap.position_cd = topositioncd,
      ap.prsnl_id = appprefs->prefs[d.seq].prsnl_id, ap.active_ind = 1, ap.updt_id = reqinfo->updt_id,
      ap.updt_cnt = 0, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx,
      ap.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (ap)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert application preferences.")
   ENDIF
   CALL bedlogmessage("copyAppPreferences()","Exiting...")
 END ;Subroutine
 SUBROUTINE copynamevaluepreferences(frompositioncd,topositioncd)
   CALL bedlogmessage("copyNameValuePreferences()","Entering...")
   INSERT  FROM name_value_prefs
    (name_value_prefs_id, parent_entity_name, parent_entity_id,
    pvc_name, pvc_value, merge_name,
    merge_id, sequence, active_ind,
    updt_dt_tm, updt_id, updt_task,
    updt_cnt, updt_applctx)(SELECT
     seq(carenet_seq,nextval), nvp.parent_entity_name, t2.view_prefs_id,
     nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
     nvp.merge_id, nvp.sequence, nvp.active_ind,
     cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
     0, reqinfo->updt_applctx
     FROM name_value_prefs nvp,
      view_prefs t1,
      view_prefs t2
     WHERE t1.position_cd=frompositioncd
      AND t2.application_number=t1.application_number
      AND t2.position_cd=topositioncd
      AND t2.prsnl_id=t1.prsnl_id
      AND t2.frame_type=t1.frame_type
      AND t2.view_name=t1.view_name
      AND t2.view_seq=t1.view_seq
      AND t2.active_ind=t1.active_ind
      AND nvp.parent_entity_name="VIEW_PREFS"
      AND nvp.parent_entity_id=t1.view_prefs_id)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Failed to copy view prefs to name_value_prefs.")
   INSERT  FROM name_value_prefs nvp1
    (nvp1.name_value_prefs_id, nvp1.parent_entity_name, nvp1.parent_entity_id,
    nvp1.pvc_name, nvp1.pvc_value, nvp1.merge_name,
    nvp1.merge_id, nvp1.sequence, nvp1.active_ind,
    nvp1.updt_dt_tm, nvp1.updt_id, nvp1.updt_task,
    nvp1.updt_cnt, nvp1.updt_applctx)(SELECT
     seq(carenet_seq,nextval), nvp.parent_entity_name, t2.view_comp_prefs_id,
     nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
     nvp.merge_id, nvp.sequence, nvp.active_ind,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task,
     0, reqinfo->updt_applctx
     FROM name_value_prefs nvp,
      view_comp_prefs t1,
      view_comp_prefs t2
     WHERE t1.position_cd=frompositioncd
      AND t2.application_number=t1.application_number
      AND t2.position_cd=topositioncd
      AND t2.prsnl_id=t1.prsnl_id
      AND t2.view_name=t1.view_name
      AND t2.view_seq=t1.view_seq
      AND t2.comp_name=t1.comp_name
      AND t2.comp_seq=t1.comp_seq
      AND t2.active_ind=t1.active_ind
      AND nvp.parent_entity_id=t1.view_comp_prefs_id
      AND nvp.parent_entity_name="VIEW_COMP_PREFS")
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Failed to copy view comp prefs to name_value_prefs.")
   INSERT  FROM name_value_prefs
    (name_value_prefs_id, parent_entity_name, parent_entity_id,
    pvc_name, pvc_value, merge_name,
    merge_id, sequence, active_ind,
    updt_dt_tm, updt_id, updt_task,
    updt_cnt, updt_applctx)(SELECT
     seq(carenet_seq,nextval), nvp.parent_entity_name, t2.detail_prefs_id,
     nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
     nvp.merge_id, nvp.sequence, nvp.active_ind,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task,
     0, reqinfo->updt_applctx
     FROM name_value_prefs nvp,
      detail_prefs t1,
      detail_prefs t2
     WHERE t1.position_cd=frompositioncd
      AND t2.application_number=t1.application_number
      AND t2.position_cd=topositioncd
      AND t2.prsnl_id=t1.prsnl_id
      AND t2.person_id=t1.person_id
      AND t2.view_name=t1.view_name
      AND t2.view_seq=t1.view_seq
      AND t2.comp_name=t1.comp_name
      AND t2.comp_seq=t1.comp_seq
      AND t2.active_ind=t1.active_ind
      AND nvp.parent_entity_id=t1.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS")
    WITH nocounter
   ;end insert
   INSERT  FROM name_value_prefs
    (name_value_prefs_id, parent_entity_name, parent_entity_id,
    pvc_name, pvc_value, merge_name,
    merge_id, sequence, active_ind,
    updt_dt_tm, updt_id, updt_task,
    updt_cnt, updt_applctx)(SELECT
     seq(carenet_seq,nextval), nvp.parent_entity_name, t2.app_prefs_id,
     nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
     nvp.merge_id, nvp.sequence, nvp.active_ind,
     cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
     0, reqinfo->updt_applctx
     FROM name_value_prefs nvp,
      app_prefs t1,
      app_prefs t2
     WHERE t1.position_cd=frompositioncd
      AND t2.application_number=t1.application_number
      AND t2.position_cd=topositioncd
      AND t2.prsnl_id=t1.prsnl_id
      AND t2.active_ind=t1.active_ind
      AND nvp.parent_entity_id=t1.app_prefs_id
      AND nvp.parent_entity_name="APP_PREFS")
    WITH nocounter
   ;end insert
   CALL bedlogmessage("copyNameValuePreferences()","Exiting...")
 END ;Subroutine
END GO
