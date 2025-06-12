CREATE PROGRAM bed_ens_qch_prsnl:dba
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
 IF ( NOT (validate(child_reltn_recs,0)))
  RECORD child_reltn_recs(
    1 relations[*]
      2 br_reltn_id = f8
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
 CALL bedbeginscript(0)
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs48_inactive_cd)))
  DECLARE cs48_inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 IF ( NOT (validate(cs8_auth_cd)))
  DECLARE cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 ENDIF
 IF ( NOT (validate(cs19189_group_class_cd)))
  DECLARE cs19189_group_class_cd = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=19189
    AND cv.cdf_meaning="QCH"
   DETAIL
    cs19189_group_class_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR001: Error while retrieving QCH code value")
 ENDIF
 IF ( NOT (validate(cs357_group_type_cd)))
  DECLARE cs357_group_type_cd = f8 WITH protect, noconstant(0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="QCHUSER"
   DETAIL
    cs357_group_type_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("ERROR002: Error while retrieving QCH User code value")
 ENDIF
 DECLARE add_flag = i4 WITH protect, constant(1)
 DECLARE delete_flag = i4 WITH protect, constant(3)
 DECLARE size_of_prsnl = i4 WITH protect, constant(size(request->prsnls,5))
 DECLARE qchprsnlgroupid = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE reltncnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE new_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE prsnlgrpreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE createqchpersonnel(prsnlid=f8,dashboard_ind=i2,eh_portal_ind=i2,mips_display_ind=i2,
  qrda_export_ind=i2) = null
 DECLARE removeqchpersonnel(prsnlid=f8) = null
 DECLARE doesqchccnreltnexist(prsnlgrpreltnid=f8) = i2
 DECLARE doesqchepgreltnexist(prsnlgrpreltnid=f8) = i2
 IF (validate(debug,0)=1)
  CALL bedlogmessage("Ensuring QCH Users...","")
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group pg
  WHERE pg.prsnl_group_class_cd=cs19189_group_class_cd
   AND pg.prsnl_group_type_cd=cs357_group_type_cd
   AND pg.active_ind=1
  DETAIL
   qchprsnlgroupid = pg.prsnl_group_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR003: Error while retrieving PRSNL_GROUP_ID from PRSNL_GROUP table")
 IF (curqual=0)
  IF (validate(debug,0)=1)
   CALL bedlogmessage("There is no row on the prsnl_group table. The README needs to be re-run.")
  ENDIF
  CALL bederrorcheck(
   "ERROR004: QCH group does not exist on the prsnl_group table. Need to run the README.")
 ENDIF
 FOR (cnt = 1 TO size_of_prsnl)
   IF ((request->prsnls[cnt].action_flag=1))
    CALL createqchpersonnel(request->prsnls[cnt].prsnl_id,request->prsnls[cnt].dashboard_ind,request
     ->prsnls[cnt].eh_portal_ind,request->prsnls[cnt].mips_display_ind,request->prsnls[cnt].
     qrda_export_ind)
   ELSEIF ((request->prsnls[cnt].action_flag=3))
    CALL removeqchpersonnel(request->prsnls[cnt].prsnl_id)
   ELSEIF ((request->prsnls[cnt].action_flag=2))
    CALL updateqmdindicators(request->prsnls[cnt].prsnl_id,request->prsnls[cnt].dashboard_ind,request
     ->prsnls[cnt].eh_portal_ind,request->prsnls[cnt].mips_display_ind,request->prsnls[cnt].
     qrda_export_ind)
    CALL bederrorcheck("ERROR005: Wrong action flag for prsnl_id")
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE createqchpersonnel(prsnlid,dashboard_ind,eh_portal_ind,mips_display_ind,qrda_export_ind)
   CALL bedlogmessage("createQCHPersonnel ","Exiting ...")
   SET new_reltn_id = 0.0
   SELECT INTO "nl:"
    z = seq(prsnl_seq,nextval)
    FROM dual
    DETAIL
     new_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR006: Problems occurred retrieving next sequence value.")
   INSERT  FROM prsnl_group_reltn pgr
    SET pgr.prsnl_group_reltn_id = new_reltn_id, pgr.active_ind = 1, pgr.active_status_cd =
     cs48_active_cd,
     pgr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.active_status_prsnl_id = reqinfo->
     updt_id, pgr.data_status_cd = cs8_auth_cd,
     pgr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.data_status_prsnl_id = reqinfo->
     updt_id, pgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     pgr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), pgr.person_id = prsnlid, pgr
     .prsnl_group_id = qchprsnlgroupid,
     pgr.updt_applctx = reqinfo->updt_applctx, pgr.updt_cnt = 0, pgr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     pgr.updt_id = reqinfo->updt_id, pgr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR007: Error while inserting person_id into prsnl_group_relation table")
   SET qmd_portal_permission_id = 0.0
   SELECT INTO "nl:"
    z = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     qmd_portal_permission_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR008: Problems occurred retrieving next sequence value.")
   CALL echo(qmd_portal_permission_id)
   CALL echo(new_reltn_id)
   INSERT  FROM qmd_portal_permission qpp
    SET qpp.qmd_portal_permission_id = qmd_portal_permission_id, qpp.prsnl_group_reltn_id =
     new_reltn_id, qpp.dashboard_ind = dashboard_ind,
     qpp.client_portal_display_ind = eh_portal_ind, qpp.mips_display_ind = mips_display_ind, qpp
     .qrda_export_ind = qrda_export_ind,
     qpp.updt_applctx = reqinfo->updt_applctx, qpp.updt_cnt = 0, qpp.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     qpp.updt_task = reqinfo->updt_task, qpp.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   CALL bederrorcheck(
    "ERROR009: Error while inserting qmd_portal_permission_id into qmd_portal_permission table")
   CALL bedlogmessage("createQCHPersonnel ","Exiting ...")
 END ;Subroutine
 SUBROUTINE removeqchpersonnel(prsnlid)
   CALL bedlogmessage("removeQCHPersonnel ","Entering ...")
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr
    WHERE active_ind=1
     AND pgr.prsnl_group_id=qchprsnlgroupid
     AND pgr.person_id=prsnlid
     AND pgr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    DETAIL
     prsnlgrpreltnid = pgr.prsnl_group_reltn_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR010: Error while retrieving prsnl group reltn id from prsnl_group_reltn table")
   UPDATE  FROM prsnl_group_reltn pgr
    SET pgr.active_ind = 0, pgr.active_status_cd = cs48_inactive_cd, pgr.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     pgr.active_status_prsnl_id = reqinfo->updt_id, pgr.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pgr.updt_applctx = reqinfo->updt_applctx,
     pgr.updt_cnt = (pgr.updt_cnt+ 1), pgr.updt_id = reqinfo->updt_id, pgr.updt_task = reqinfo->
     updt_task,
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE pgr.person_id=prsnlid
     AND pgr.prsnl_group_id=qchprsnlgroupid
     AND pgr.active_ind=1
     AND pgr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR011: Error while removing person_id from prsnl_group_relation table")
   IF (doesqchccnreltnexist(prsnlgrpreltnid))
    FOR (i = 1 TO size(child_reltn_recs->relations,5))
     UPDATE  FROM br_prsnl_ccn_reltn pcr
      SET pcr.active_ind = 0, pcr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pcr
       .updt_applctx = reqinfo->updt_applctx,
       pcr.updt_cnt = (pcr.updt_cnt+ 1), pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->
       updt_task,
       pcr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (pcr.br_prsnl_ccn_reltn_id=child_reltn_recs->relations[i].br_reltn_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR012: Error while removing relation from br_prsnl_ccn_reltn table")
    ENDFOR
   ENDIF
   IF (doesqchepgreltnexist(prsnlgrpreltnid))
    FOR (i = 1 TO size(child_reltn_recs->relations,5))
     UPDATE  FROM br_prsnl_elig_prov_grp_r pepgr
      SET pepgr.active_ind = 0, pepgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pepgr
       .updt_applctx = reqinfo->updt_applctx,
       pepgr.updt_cnt = (pepgr.updt_cnt+ 1), pepgr.updt_id = reqinfo->updt_id, pepgr.updt_task =
       reqinfo->updt_task,
       pepgr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (pepgr.br_prsnl_elig_prov_grp_r_id=child_reltn_recs->relations[i].br_reltn_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR013: Error while removing relation from br_prsnl_elig_prov_grp_r table"
      )
    ENDFOR
   ENDIF
   DELETE  FROM qmd_portal_permission qpp
    WHERE qpp.prsnl_group_reltn_id=prsnlgrpreltnid
    WITH nocounter
   ;end delete
   CALL bederrorcheck("ERROR014: Error while deleting row from qmd_portal_permission table")
   CALL bedlogmessage("removeQCHPersonnel ","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateqmdindicators(prsnlid,dashboard_ind,eh_portal_ind,mips_display_ind,qrda_export_ind)
   CALL bedlogmessage("updateQMDIndicators ","Entering ...")
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr
    WHERE active_ind=1
     AND pgr.prsnl_group_id=qchprsnlgroupid
     AND pgr.person_id=prsnlid
     AND pgr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    DETAIL
     prsnlgrpreltnid = pgr.prsnl_group_reltn_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR015: Error while removing person_id from prsnl_group_relation table")
   CALL echo(qchprsnlgroupid)
   SELECT INTO "nl:"
    FROM qmd_portal_permission q
    WHERE q.prsnl_group_reltn_id=prsnlgrpreltnid
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR016: Error while retrieving prsnl group reltn id from qmd_portal_permission table")
   IF (curqual > 0)
    UPDATE  FROM qmd_portal_permission qpp
     SET qpp.dashboard_ind = dashboard_ind, qpp.client_portal_display_ind = eh_portal_ind, qpp
      .mips_display_ind = mips_display_ind,
      qpp.qrda_export_ind = qrda_export_ind, qpp.updt_applctx = reqinfo->updt_applctx, qpp.updt_cnt
       = (updt_cnt+ 1),
      qpp.updt_dt_tm = cnvtdatetime(curdate,curtime3), qpp.updt_task = reqinfo->updt_task, qpp
      .updt_id = reqinfo->updt_id
     WHERE qpp.prsnl_group_reltn_id=prsnlgrpreltnid
     WITH nocounter
    ;end update
    CALL bederrorcheck("ERROR017: Error while updating qmd_portal_permission table")
   ELSE
    SET qmd_portal_permission_id = 0.0
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      qmd_portal_permission_id = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERROR018: Problems occurred retrieving next sequence value.")
    INSERT  FROM qmd_portal_permission qpp
     SET qpp.qmd_portal_permission_id = qmd_portal_permission_id, qpp.prsnl_group_reltn_id =
      prsnlgrpreltnid, qpp.dashboard_ind = dashboard_ind,
      qpp.client_portal_display_ind = eh_portal_ind, qpp.mips_display_ind = mips_display_ind, qpp
      .qrda_export_ind = qrda_export_ind,
      qpp.updt_applctx = reqinfo->updt_applctx, qpp.updt_cnt = 0, qpp.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      qpp.updt_task = reqinfo->updt_task, qpp.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    CALL bederrorcheck(
     "ERROR019: Error while inserting qmd_portal_permission_id into qmd_portal_permission table")
   ENDIF
   CALL bedlogmessage("updateQMDIndicators ","Exiting ...")
 END ;Subroutine
 SUBROUTINE doesqchccnreltnexist(prsnlgrpreltnid)
   SET reltncnt = 0
   SELECT INTO "nl:"
    FROM br_prsnl_ccn_reltn pcr
    WHERE pcr.prsnl_group_reltn_id=prsnlgrpreltnid
     AND pcr.active_ind=1
     AND pcr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    DETAIL
     reltncnt = (reltncnt+ 1), stat = alterlist(child_reltn_recs->relations,reltncnt),
     child_reltn_recs->relations[reltncnt].br_reltn_id = pcr.br_prsnl_ccn_reltn_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR020: Error while trying to get a active child relation from br_prsnl_ccn_reltn table")
   IF (curqual=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE doesqchepgreltnexist(prsnlgrpreltnid)
   SET reltncnt = 0
   SELECT INTO "nl:"
    FROM br_prsnl_elig_prov_grp_r pepgr
    WHERE pepgr.prsnl_group_reltn_id=prsnlgrpreltnid
     AND pepgr.active_ind=1
     AND pepgr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    DETAIL
     reltncnt = (reltncnt+ 1), stat = alterlist(child_reltn_recs->relations,reltncnt),
     child_reltn_recs->relations[reltncnt].br_reltn_id = pepgr.br_prsnl_elig_prov_grp_r_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR021: Error while trying to get a active child relation from br_prsnl_elig_prov_reltn table"
    )
   IF (curqual=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
END GO
