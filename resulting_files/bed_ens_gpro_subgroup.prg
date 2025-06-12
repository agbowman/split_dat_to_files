CREATE PROGRAM bed_ens_gpro_subgroup
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
 FREE RECORD gpro_subgroup
 RECORD gpro_subgroup(
   1 gpro_list[*]
     2 br_gpro_id = f8
     2 logical_domain_id = f8
     2 br_gpro_sub_id = f8
 )
 FREE RECORD br_delete_hist
 RECORD br_delete_hist(
   1 list[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE brid = f8 WITH protect, noconstant(0)
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0)
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
 IF ((request->gpro_id != 0.00)
  AND (request->gpro_sub_id=0.00))
  SELECT INTO "nl:"
   FROM br_gpro bg
   WHERE (bg.br_gpro_id=request->gpro_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(gpro_subgroup->gpro_list,cnt), gpro_subgroup->gpro_list[cnt].
    br_gpro_id = bg.br_gpro_id,
    gpro_subgroup->gpro_list[cnt].logical_domain_id = bg.logical_domain_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 001 : Error retrieving GPRO ID")
  SELECT INTO "nl:"
   z = seq(bedrock_seq,nextval)
   FROM dual
   DETAIL
    brid = cnvtreal(z)
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 002: Problems occurred retrieving next sequence value for BR_GPRO PK.")
  INSERT  FROM br_gpro_sub bgs,
    (dummyt d  WITH seq = size(gpro_subgroup->gpro_list,5))
   SET bgs.br_gpro_sub_id = brid, bgs.active_ind = 1, bgs.br_gpro_id = gpro_subgroup->gpro_list[d.seq
    ].br_gpro_id,
    bgs.br_gpro_sub_name = request->gpro_sub_name, bgs.br_gpro_sub_nbr_txt = request->
    gpro_sub_nbr_txt, bgs.logical_domain_id = gpro_subgroup->gpro_list[d.seq].logical_domain_id,
    bgs.orig_br_gpro_sub_id = brid, bgs.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgs
    .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
    bgs.updt_applctx = reqinfo->updt_applctx, bgs.updt_cnt = 0, bgs.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    bgs.updt_id = reqinfo->updt_id, bgs.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (bgs)
   WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
  ;end insert
  COMMIT
  CALL bederrorcheck("ERROR 003: Error Inserting into BR_GPRO_SUB")
 ELSEIF ((request->gpro_id=0.00)
  AND (request->gpro_sub_id != 0.00))
  SELECT INTO "nl:"
   FROM br_gpro_sub bgs
   WHERE (bgs.br_gpro_sub_id=request->gpro_sub_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(gpro_subgroup->gpro_list,cnt), gpro_subgroup->gpro_list[cnt].
    br_gpro_sub_id = bgs.br_gpro_sub_id,
    br_gpro_sub_id = bgs.br_gpro_sub_id, logical_domain_id = bgs.logical_domain_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR 004 : Error retrieving GPRO SUB ID")
  IF (cnvtupper(request->remove_yn)="N")
   UPDATE  FROM br_gpro_sub bgs,
     (dummyt d  WITH seq = size(gpro_subgroup->gpro_list,5))
    SET bgs.br_gpro_sub_name = request->gpro_sub_name, bgs.br_gpro_sub_nbr_txt = request->
     gpro_sub_nbr_txt, bgs.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     bgs.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), bgs.orig_br_gpro_sub_id =
     gpro_subgroup->gpro_list[d.seq].br_gpro_sub_id, bgs.updt_applctx = reqinfo->updt_applctx,
     bgs.updt_cnt = (bgs.updt_cnt+ 1), bgs.updt_dt_tm = cnvtdatetime(curdate,curtime3), bgs.updt_id
      = reqinfo->updt_id,
     bgs.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (bgs
     WHERE (bgs.br_gpro_sub_id=gpro_subgroup->gpro_list[d.seq].br_gpro_sub_id))
    WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
   ;end update
   CALL bederrorcheck("ERROR 005 : Error Updating GPRO SUB")
   SELECT INTO "NL:"
    FROM br_gpro_sub_reltn bgsr
    PLAN (bgsr
     WHERE (bgsr.br_gpro_sub_id=request->gpro_sub_id))
    ORDER BY bgsr.br_gpro_sub_reltn_id
    HEAD REPORT
     cnt = 0
    HEAD bgsr.br_gpro_sub_reltn_id
     cnt = (cnt+ 1), stat = alterlist(br_delete_hist->list,cnt), br_delete_hist->list[cnt].
     parent_entity_id = bgsr.br_gpro_sub_reltn_id,
     br_delete_hist->list[cnt].parent_entity_name = build2(trim(cnvtstring(bgsr.br_gpro_sub_id)),
      "BR_GPRO_SUB_RELTN",trim(cnvtstring(bgsr.br_eligible_provider_id)))
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 006 : Error retrieving Delete items")
   IF (size(br_delete_hist->list,5) != 0)
    INSERT  FROM br_delete_hist bdh,
      (dummyt d  WITH seq = size(br_delete_hist->list,5))
     SET bdh.br_delete_hist_id = seq(bedrock_seq,nextval), bdh.parent_entity_name = br_delete_hist->
      list[d.seq].parent_entity_name, bdh.parent_entity_id = br_delete_hist->list[d.seq].
      parent_entity_id,
      bdh.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdh.updt_id = reqinfo->updt_id, bdh.updt_task
       = reqinfo->updt_task,
      bdh.updt_cnt = 0, bdh.updt_applctx = reqinfo->updt_applctx, bdh.create_dt_tm = cnvtdatetime(
       curdate,curtime3)
     PLAN (d)
      JOIN (bdh)
     WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
    ;end insert
    COMMIT
   ENDIF
   CALL bederrorcheck("ERROR 007 : Error inserting into History")
   DELETE  FROM br_gpro_sub_reltn bgsr,
     (dummyt d  WITH seq = size(gpro_subgroup->gpro_list,5))
    SET bgsr.seq = 1
    PLAN (d)
     JOIN (bgsr
     WHERE (bgsr.br_gpro_sub_id=gpro_subgroup->gpro_list[d.seq].br_gpro_sub_id))
    WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
   ;end delete
   CALL bederrorcheck("ERROR 008 : Error deleting GPRO SUB RELATION")
   IF (size(request->providers,5) > 0)
    INSERT  FROM br_gpro_sub_reltn bgsr,
      (dummyt d  WITH seq = size(request->providers,5))
     SET bgsr.active_ind = 1, bgsr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgsr
      .br_eligible_provider_id = request->providers[d.seq].br_eligible_provider_id,
      bgsr.br_gpro_sub_id = request->gpro_sub_id, bgsr.br_gpro_sub_reltn_id = cnvtreal(seq(
        bedrock_seq,nextval)), bgsr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
      bgsr.orig_br_gpro_sub_reltn_id = cnvtreal(seq(bedrock_seq,nextval)), bgsr.logical_domain_id =
      logical_domain_id, bgsr.updt_applctx = reqinfo->updt_applctx,
      bgsr.updt_cnt = 0, bgsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bgsr.updt_id = reqinfo->
      updt_id,
      bgsr.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bgsr)
     WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
    ;end insert
    COMMIT
   ENDIF
   CALL bederrorcheck("ERROR 009 : Error inserting into GPRO SUB RELTATION")
  ELSEIF (cnvtupper(request->remove_yn)="Y")
   SELECT INTO "NL:"
    FROM br_gpro_sub_reltn bgsr
    PLAN (bgsr
     WHERE (bgsr.br_gpro_sub_id=request->gpro_sub_id))
    ORDER BY bgsr.br_gpro_sub_reltn_id
    HEAD REPORT
     cnt = 0
    HEAD bgsr.br_gpro_sub_reltn_id
     cnt = (cnt+ 1), stat = alterlist(br_delete_hist->list,cnt), br_delete_hist->list[cnt].
     parent_entity_id = bgsr.br_gpro_sub_reltn_id,
     br_delete_hist->list[cnt].parent_entity_name = build2(trim(cnvtstring(bgsr.br_gpro_sub_id)),
      "BR_GPRO_SUB_RELTN",trim(cnvtstring(bgsr.br_eligible_provider_id)))
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 010 : Error retrieving Delete items")
   IF (size(br_delete_hist->list,5) != 0)
    INSERT  FROM br_delete_hist bdh,
      (dummyt d  WITH seq = size(br_delete_hist->list,5))
     SET bdh.br_delete_hist_id = seq(bedrock_seq,nextval), bdh.parent_entity_name = br_delete_hist->
      list[d.seq].parent_entity_name, bdh.parent_entity_id = br_delete_hist->list[d.seq].
      parent_entity_id,
      bdh.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdh.updt_id = reqinfo->updt_id, bdh.updt_task
       = reqinfo->updt_task,
      bdh.updt_cnt = 0, bdh.updt_applctx = reqinfo->updt_applctx, bdh.create_dt_tm = cnvtdatetime(
       curdate,curtime3)
     PLAN (d)
      JOIN (bdh)
     WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
    ;end insert
   ENDIF
   COMMIT
   CALL bederrorcheck("ERROR 011 : Error inserting into History")
   DELETE  FROM br_gpro_sub_reltn bgsr,
     (dummyt d  WITH seq = size(gpro_subgroup->gpro_list,5))
    SET bgsr.seq = 1
    PLAN (d)
     JOIN (bgsr
     WHERE (bgsr.br_gpro_sub_id=gpro_subgroup->gpro_list[d.seq].br_gpro_sub_id))
    WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
   ;end delete
   CALL bederrorcheck("ERROR 008 : Error deleting GPRO SUB RELATION")
   DELETE  FROM br_gpro_sub bgs,
     (dummyt d  WITH seq = size(gpro_subgroup->gpro_list,5))
    SET bgs.seq = 1
    PLAN (d)
     JOIN (bgs
     WHERE (bgs.br_gpro_sub_id=gpro_subgroup->gpro_list[d.seq].br_gpro_sub_id))
    WITH nocounter, maxcommit = 100, rdbarrayinsert = 100
   ;end delete
   COMMIT
   CALL bederrorcheck("ERROR 008 : Error deleting GPRO SUB")
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(1)
END GO
