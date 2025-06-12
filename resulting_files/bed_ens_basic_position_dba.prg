CREATE PROGRAM bed_ens_basic_position:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 position_cd = f8
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
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE update_attributes_flag = i2 WITH protect, constant(4)
 DECLARE categorycnt = i4 WITH protect, noconstant(size(request->categories,5))
 DECLARE appgroupcnt = i4 WITH protect, noconstant(size(request->applicationgroups,5))
 DECLARE pcowhoworks = i2 WITH protect, noconstant(0)
 DECLARE positioncd = f8 WITH protect, noconstant(0)
 DECLARE getpcowhoworks(pcowhoworks=i2(ref)) = i2
 DECLARE doespositiondisplayexist(dummyvar=i2) = i2
 DECLARE modifypositionincodeset(actionflag=i2) = i2
 DECLARE addpcodetails(dummyvar=i2) = i2
 DECLARE addpositioncategories(batchmode=i2,categoryid=f8,catphysind=i2) = i2
 DECLARE addapplicationgroups(batchmode=i2,appgroupcd=f8) = i2
 DECLARE deletepositionrelationships(dummyvar=i2) = i2
 DECLARE modifylongdescription(dummyvar=i2) = i2
 IF ((request->pcoind=true))
  CALL getpcowhoworks(pcowhoworks)
 ENDIF
 IF ((request->action_flag=add_flag))
  IF (doespositiondisplayexist(0))
   CALL bederror("Duplicate display.")
  ENDIF
  IF ( NOT (modifypositionincodeset(add_flag)))
   CALL bederror("Failed to insert position on code set 88.")
  ENDIF
  IF ((request->long_description > ""))
   CALL modifylongdescription(0)
  ENDIF
  IF (pcowhoworks > 0)
   IF ( NOT (addpcodetails(0)))
    CALL bederror("Failed to insert PCO details.Error adding position to br_name_value.")
   ENDIF
  ENDIF
  IF (categorycnt > 0)
   IF ( NOT (addpositioncategories(1,0.0,0)))
    CALL bederror("Failed to insert position categories. Error adding position to br_pos_cat_comp.")
   ENDIF
  ENDIF
  IF (appgroupcnt > 0)
   IF ( NOT (addapplicationgroups(1,0.0)))
    CALL bederror("Failed to insert application groups. Error adding position to application_group.")
   ENDIF
  ENDIF
 ELSEIF ((request->action_flag=update_flag))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=88
    AND (cv.code_value=request->code_value)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL bederror("The position you are trying to modify does not exist.")
  ENDIF
  IF ( NOT (modifypositionincodeset(update_flag)))
   CALL bederror("Failed to update position on code set 88.")
  ENDIF
  IF ((request->long_description > ""))
   CALL modifylongdescription(0)
  ENDIF
  FOR (catidx = 1 TO categorycnt)
    IF ((request->categories[catidx].action_flag=add_flag))
     IF ( NOT (addpositioncategories(0,request->categories[catidx].category_id,request->categories[
      catidx].cat_phys_ind)))
      CALL bederror("Failed to insert position categories. Error adding position to br_pos_cat_comp."
       )
     ENDIF
    ELSEIF ((request->categories[catidx].action_flag=update_flag))
     IF ( NOT (updatepositioncategory(request->categories[catidx].category_id,request->categories[
      catidx].cat_phys_ind)))
      CALL bederror("Failed to update postion category.")
     ENDIF
    ELSEIF ((request->categories[catidx].action_flag=delete_flag))
     IF ( NOT (deletepositioncategory(request->categories[catidx].category_id)))
      CALL bederror("Failed to delete position category.")
     ENDIF
    ENDIF
  ENDFOR
  FOR (appidx = 1 TO appgroupcnt)
    IF ((request->applicationgroups[appidx].action_flag=add_flag))
     IF ( NOT (addapplicationgroups(0,request->applicationgroups[appidx].app_group_cd)))
      CALL bederror(
       "Failed to insert application groups. Error adding position to application_group.")
     ENDIF
    ELSEIF ((request->applicationgroups[appidx].action_flag=update_flag))
     CALL bedlogmessage("main()","Updating application group is not supported.")
    ELSEIF ((request->applicationgroups[appidx].action_flag=delete_flag))
     IF ( NOT (deleteapplicationgroups(request->applicationgroups[appidx].app_group_cd)))
      CALL bederror("Failed to delete application group.")
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF ((request->action_flag=update_attributes_flag))
  SET positioncd = request->code_value
  FOR (catidx = 1 TO categorycnt)
    IF ((request->categories[catidx].action_flag=add_flag))
     IF ( NOT (addpositioncategories(0,request->categories[catidx].category_id,request->categories[
      catidx].cat_phys_ind)))
      CALL bederror("Failed to insert position categories. Error adding position to br_pos_cat_comp."
       )
     ENDIF
    ELSEIF ((request->categories[catidx].action_flag=update_flag))
     IF ( NOT (updatepositioncategory(request->categories[catidx].category_id,request->categories[
      catidx].cat_phys_ind)))
      CALL bederror("Failed to update postion category.")
     ENDIF
    ELSEIF ((request->categories[catidx].action_flag=delete_flag))
     IF ( NOT (deletepositioncategory(request->categories[catidx].category_id)))
      CALL bederror("Failed to delete position category.")
     ENDIF
    ENDIF
  ENDFOR
  FOR (appidx = 1 TO appgroupcnt)
    IF ((request->applicationgroups[appidx].action_flag=add_flag))
     IF ( NOT (addapplicationgroups(0,request->applicationgroups[appidx].app_group_cd)))
      CALL bederror(
       "Failed to insert application groups. Error adding position to application_group.")
     ENDIF
    ELSEIF ((request->applicationgroups[appidx].action_flag=update_flag))
     CALL bedlogmessage("main()","Updating application group is not supported.")
    ELSEIF ((request->applicationgroups[appidx].action_flag=delete_flag))
     IF ( NOT (deleteapplicationgroups(request->applicationgroups[appidx].app_group_cd)))
      CALL bederror("Failed to delete application group.")
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  CALL bederror(build2("Invalid action flag: ",request->action_flag,". Valid values 1,2,3."))
 ENDIF
 SET reply->position_cd = positioncd
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getpcowhoworks(pcowhoworks)
   CALL bedlogmessage("getPCOWhoWorks()","Entering")
   SET pcowhoworks = 0
   SELECT INTO "nl:"
    FROM br_name_value b
    PLAN (b
     WHERE b.br_nv_key1="PCOPSNSELECTED")
    DETAIL
     pcowhoworks = 1
    WITH nocounter
   ;end select
   CALL bedlogmessage("getPCOWhoWorks()","Exiting")
 END ;Subroutine
 SUBROUTINE doespositiondisplayexist(dummyvar)
   CALL bedlogmessage("doesPositionDisplayExist()","Entering")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.active_ind=true
      AND cv.code_set=88
      AND cv.display=substring(1,40,request->display))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
   CALL bedlogmessage("doesPositionDisplayExist()","Exiting")
 END ;Subroutine
 SUBROUTINE modifypositionincodeset(actionflag)
   CALL bedlogmessage("modifyPositionInCodeSet","Entering...")
   FREE RECORD codevaluerequest
   RECORD codevaluerequest(
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
   FREE RECORD codevaluereply
   RECORD codevaluereply(
     1 curqual = i4
     1 qual[*]
       2 status = i2
       2 error_num = i4
       2 error_msg = vc
       2 code_value = f8
       2 cki = vc
     1 error_msg = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF (actionflag=add_flag)
    SET codevaluerequest->cd_value_list[1].action_flag = 1
    IF (size(trim(request->description,3),1) > 1)
     SET codevaluerequest->cd_value_list[1].description = substring(1,60,request->description)
    ELSE
     SET codevaluerequest->cd_value_list[1].description = substring(1,60,request->display)
    ENDIF
   ELSEIF (actionflag=update_flag)
    SET codevaluerequest->cd_value_list[1].action_flag = 2
    SET codevaluerequest->code_value = request->code_value
    SET codevaluerequest->cd_value_list[1].description = substring(1,60,request->description)
   ENDIF
   SET codevaluerequest->cd_value_list[1].code_set = 88
   SET codevaluerequest->cd_value_list[1].display = substring(1,40,request->display)
   SET codevaluerequest->cd_value_list[1].definition = codevaluerequest->cd_value_list[1].display
   SET codevaluerequest->cd_value_list[1].cdf_meaning = request->cdf_meaning
   SET codevaluerequest->cd_value_list[1].active_ind = 1
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",codevaluerequest), replace("REPLY",codevaluereply
    )
   IF ((codevaluereply->status_data.status="S")
    AND (codevaluereply->qual[1].code_value > 0))
    SET positioncd = codevaluereply->qual[1].code_value
   ENDIF
   CALL bedlogmessage("modifyPositionInCodeSet","Exiting...")
   IF (positioncd > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE modifylongdescription(dummyvar)
   CALL bedlogmessage("modifyLongDescription()","Entering...")
   DECLARE longdescid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_long_text b
    PLAN (b
     WHERE b.parent_entity_name="CODE_VALUE"
      AND b.parent_entity_id=positioncd)
    DETAIL
     longdescid = b.long_text_id
    WITH nocounter
   ;end select
   IF (longdescid > 0)
    UPDATE  FROM br_long_text lt
     SET lt.long_text = request->long_description, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
      .updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
      .updt_cnt+ 1)
     PLAN (lt
      WHERE lt.long_text_id=longdescid)
     WITH nocounter
    ;end update
   ELSE
    INSERT  FROM br_long_text lt
     SET lt.long_text_id = seq(bedrock_seq,nextval), lt.long_text = request->long_description, lt
      .parent_entity_id = positioncd,
      lt.parent_entity_name = "CODE_VALUE", lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
      .updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   CALL bedlogmessage("modifyLongDescription()","Exiting...")
 END ;Subroutine
 SUBROUTINE addpcodetails(dummyvar)
   CALL bedlogmessage("addPCODetails()","Entering")
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "PCOPSNSELECTED", bnv
     .br_name = "CVFROMCS88",
     bnv.br_value = cnvtstring(positioncd), bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->
     updt_task,
     bnv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    RETURN(false)
   ENDIF
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "PCONEWPOSITION", bnv
     .br_name = "CVFROMCS88",
     bnv.br_value = cnvtstring(positioncd), bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->
     updt_task,
     bnv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("addPCODetails()","Existing")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE addpositioncategories(batchmode,categoryid,catphysind)
   CALL bedlogmessage("addPositionCategories","Entering...")
   IF (batchmode=1)
    INSERT  FROM br_position_cat_comp bpcc,
      (dummyt d  WITH seq = size(request->categories,5))
     SET bpcc.category_id = request->categories[d.seq].category_id, bpcc.position_cd = positioncd,
      bpcc.sequence = 1,
      bpcc.physician_ind = request->categories[d.seq].cat_phys_ind, bpcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), bpcc.updt_id = reqinfo->updt_id,
      bpcc.updt_task = reqinfo->updt_task, bpcc.updt_cnt = 0, bpcc.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d
      WHERE (request->categories[d.seq].category_id > 0))
      JOIN (bpcc)
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM br_position_cat_comp bpcc
     SET bpcc.category_id = categoryid, bpcc.position_cd = positioncd, bpcc.sequence = 1,
      bpcc.physician_ind = catphysind, bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpcc.updt_id
       = reqinfo->updt_id,
      bpcc.updt_task = reqinfo->updt_task, bpcc.updt_cnt = 0, bpcc.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("addPositionCategories()","Exiting...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE updatepositioncategory(categoryid,catphysind)
   CALL bedlogmessage("updatePositionCategory()","Entering ...")
   UPDATE  FROM br_position_cat_comp bpcc
    SET bpcc.physician_ind = catphysind, bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpcc
     .updt_id = reqinfo->updt_id,
     bpcc.updt_task = reqinfo->updt_task, bpcc.updt_cnt = (bpcc.updt_cnt+ 1), bpcc.updt_applctx =
     reqinfo->updt_applctx
    PLAN (bpcc
     WHERE bpcc.category_id=categoryid
      AND bpcc.position_cd=positioncd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("updatePositionCategory()","Exiting...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE deletepositioncategory(categoryid)
   CALL bedlogmessage("deletePositionCategory()","Entering ...")
   DELETE  FROM br_position_cat_comp bpcc
    WHERE bpcc.category_id=categoryid
     AND bpcc.position_cd=positioncd
    WITH nocounter
   ;end delete
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("deletePositionCategory()","Exiting ...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE addapplicationgroups(batchmode,appgroupcd)
   CALL bedlogmessage("addApplicationGroups()","Entering")
   IF (batchmode=1)
    INSERT  FROM application_group ap,
      (dummyt d  WITH seq = size(request->applicationgroups,5))
     SET ap.application_group_id = seq(reference_seq,nextval), ap.position_cd = positioncd, ap
      .app_group_cd = request->applicationgroups[d.seq].app_group_cd,
      ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ap.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0,
      ap.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (request->applicationgroups[d.seq].app_group_cd > 0))
      JOIN (ap)
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM application_group ap
     SET ap.application_group_id = seq(reference_seq,nextval), ap.position_cd = positioncd, ap
      .app_group_cd = appgroupcd,
      ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ap.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0,
      ap.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("addApplicationGroups()","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE deleteapplicationgroup(appgroupcd)
   CALL bedlogmessage("deleteApplicationGroup()","Entering...")
   DELETE  FROM application_group ap
    WHERE ap.position_cd=positioncd
     AND ap.app_group_cd=appgroupcd
    WITH nocounter
   ;end delete
   CALL bedlogmessage("deleteApplicationGroup()","Exiting...")
 END ;Subroutine
END GO
