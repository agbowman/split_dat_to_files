CREATE PROGRAM bed_ens_tin_locations:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(br_gpro_reltn_hist,0)))
  RECORD br_gpro_reltn_hist(
    1 br_gpro_reltn_id = f8
    1 orig_br_gpro_reltn_id = f8
    1 br_gpro_id = f8
    1 parent_entity_name = vc
    1 parent_entity_id = f8
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 updt_id = f8
    1 updt_task = i4
    1 updt_applctx = f8
    1 updt_dt_tm = dq8
    1 updt_cnt = i4
  ) WITH protect
 ENDIF
 DECLARE insertlocation(loccnt=i4) = null
 DECLARE removelocation(loccnt=i4) = null
 DECLARE activatinganexistinglocation(dummyvar=i2) = null
 DECLARE locations_count = i4 WITH protect, constant(size(request->locations,5))
 DECLARE no_change_flag = i4 WITH protect, constant(0)
 DECLARE add_flag = i4 WITH protect, constant(1)
 DECLARE update_flag = i4 WITH protect, constant(2)
 DECLARE delete_flag = i4 WITH protect, constant(3)
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
 FOR (loccnt = 1 TO locations_count)
   IF ((request->locations[loccnt].action_flag=no_change_flag))
    SET dummyvar = 0
   ELSEIF ((request->locations[loccnt].action_flag=add_flag))
    CALL insertlocation(loccnt)
   ELSEIF ((request->locations[loccnt].action_flag=update_flag))
    SET dummyvar = 0
   ELSEIF ((request->locations[loccnt].action_flag=delete_flag))
    CALL removelocation(loccnt)
   ELSE
    CALL bederror("ERROR 001: Invalid locations action_flag.")
   ENDIF
 ENDFOR
 SUBROUTINE insertlocation(loccnt)
   CALL bedlogmessage("insertLocation","Entering...")
   DECLARE br_gpro_reltn_id_new = f8 WITH protect, noconstant(0)
   SET stat = initrec(br_gpro_reltn_hist)
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->group_id)
     AND bgr.parent_entity_name="LOCATION"
     AND (bgr.parent_entity_id=request->locations[loccnt].location_cd)
     AND bgr.active_ind=0
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_hist->br_gpro_reltn_id = bgr.br_gpro_reltn_id, br_gpro_reltn_hist->br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->parent_entity_name = bgr.parent_entity_name,
     br_gpro_reltn_hist->parent_entity_id = bgr.parent_entity_id, br_gpro_reltn_hist->
     beg_effective_dt_tm = bgr.beg_effective_dt_tm, br_gpro_reltn_hist->end_effective_dt_tm = bgr
     .end_effective_dt_tm,
     br_gpro_reltn_hist->updt_id = bgr.updt_id, br_gpro_reltn_hist->updt_task = bgr.updt_task,
     br_gpro_reltn_hist->updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->updt_dt_tm = bgr.updt_dt_tm, br_gpro_reltn_hist->updt_cnt = bgr.updt_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 002 : Error while finding an inactive(logically deleted gpro) gpro")
   IF (validate(debug,0)=1)
    CALL echorecord(br_gpro_reltn_hist)
    CALL logdebugmessage("curqual:",curqual)
   ENDIF
   IF (curqual > 0)
    CALL activatinganexistinglocation(0)
   ELSE
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_gpro_reltn_id_new = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck(
     "ERROR 003: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
    INSERT  FROM br_gpro_reltn bgr
     SET bgr.br_gpro_reltn_id = br_gpro_reltn_id_new, bgr.orig_br_gpro_reltn_id =
      br_gpro_reltn_id_new, bgr.br_gpro_id = request->group_id,
      bgr.parent_entity_name = "LOCATION", bgr.parent_entity_id = request->locations[loccnt].
      location_cd, bgr.active_ind = 1,
      bgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bgr.updt_id = reqinfo->updt_id, bgr.updt_task
       = reqinfo->updt_task,
      bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_cnt = 0, bgr.beg_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bgr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
     WITH nocounter
    ;end insert
    CALL bederrorcheck(
     "ERROR 004: Problems occurred writing new GPRO relationship to BR_GPRO_RELTN table.")
   ENDIF
   CALL bedlogmessage("insertLocation","Exiting...")
 END ;Subroutine
 SUBROUTINE activatinganexistinglocation(dummyvar)
   CALL bedlogmessage("activatingAnExistingLocation","Entering...")
   DECLARE br_new_hist_gpro_reltn_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_new_hist_gpro_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 005: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
   INSERT  FROM br_gpro_reltn bgr
    SET bgr.br_gpro_reltn_id = br_new_hist_gpro_reltn_id, bgr.orig_br_gpro_reltn_id =
     br_gpro_reltn_hist->br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->br_gpro_id,
     bgr.parent_entity_name = br_gpro_reltn_hist->parent_entity_name, bgr.parent_entity_id =
     br_gpro_reltn_hist->parent_entity_id, bgr.active_ind = 0,
     bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->updt_dt_tm), bgr.updt_id = br_gpro_reltn_hist
     ->updt_id, bgr.updt_task = br_gpro_reltn_hist->updt_task,
     bgr.updt_applctx = br_gpro_reltn_hist->updt_applctx, bgr.updt_cnt = br_gpro_reltn_hist->updt_cnt,
     bgr.beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->beg_effective_dt_tm),
     bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 006: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.active_ind = 1, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn_id)
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 007: Problems occurred updating the BR_GPRO_RELTN table.")
   CALL bedlogmessage("activatingAnExistingLocation","Exiting...")
 END ;Subroutine
 SUBROUTINE removelocation(loccnt)
   CALL bedlogmessage("removeLocation","Entering...")
   DECLARE br_new_gpro_reltn_id = f8 WITH protect, noconstant(0)
   SET stat = initrec(br_gpro_reltn_hist)
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->group_id)
     AND bgr.parent_entity_name="LOCATION"
     AND (bgr.parent_entity_id=request->locations[loccnt].location_cd)
     AND bgr.active_ind=1
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_hist->br_gpro_reltn_id = bgr.br_gpro_reltn_id, br_gpro_reltn_hist->br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->parent_entity_name = bgr.parent_entity_name,
     br_gpro_reltn_hist->parent_entity_id = bgr.parent_entity_id, br_gpro_reltn_hist->
     beg_effective_dt_tm = bgr.beg_effective_dt_tm, br_gpro_reltn_hist->end_effective_dt_tm = bgr
     .end_effective_dt_tm,
     br_gpro_reltn_hist->updt_id = bgr.updt_id, br_gpro_reltn_hist->updt_task = bgr.updt_task,
     br_gpro_reltn_hist->updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->updt_dt_tm = bgr.updt_dt_tm, br_gpro_reltn_hist->updt_cnt = bgr.updt_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 008: Problems occurred selecting from BR_GPRO_RELTN table.")
   IF (validate(debug,0)=1)
    CALL echorecord(br_gpro_reltn_hist)
   ENDIF
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_new_gpro_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 005: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
   INSERT  FROM br_gpro_reltn bgr
    SET bgr.br_gpro_reltn_id = br_new_gpro_reltn_id, bgr.orig_br_gpro_reltn_id = br_gpro_reltn_hist->
     br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->br_gpro_id,
     bgr.parent_entity_name = br_gpro_reltn_hist->parent_entity_name, bgr.parent_entity_id =
     br_gpro_reltn_hist->parent_entity_id, bgr.active_ind = 1,
     bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->updt_dt_tm), bgr.updt_id = br_gpro_reltn_hist
     ->updt_id, bgr.updt_task = br_gpro_reltn_hist->updt_task,
     bgr.updt_applctx = br_gpro_reltn_hist->updt_applctx, bgr.updt_cnt = br_gpro_reltn_hist->updt_cnt,
     bgr.beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->beg_effective_dt_tm),
     bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 009: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.active_ind = 0, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn_id)
     AND bgr.active_ind=1
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 010: Problems occurred updating the BR_GPRO_RELTN table.")
   CALL bedlogmessage("removeLocation","Exiting...")
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 CALL bedexitscript(1)
END GO
