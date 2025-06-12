CREATE PROGRAM bed_ens_rc_parameter_set:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_cnt = i4
    1 parameter_set[*]
      2 id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD parm_set_info
 RECORD parm_set_info(
   1 add_cnt = i4
   1 upt_cnt = i4
   1 del_cnt = i4
   1 qual[*]
     2 id = f8
     2 action_type = vc
     2 row_found_ind = i2
     2 dup_name_ind = i2
     2 active_ind_chg_ind = i2
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
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs48_inactive_cd)))
  DECLARE cs48_inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 DECLARE d_cs4622006_global_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4622006,"GLOBAL"
   ))
 DECLARE lcnt = i4 WITH protect, constant(size(request->parameter_set,5))
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 DECLARE validateparametersets(dummyvar=i2) = i2
 DECLARE addparametersets(dummyvar=i2) = i2
 DECLARE uptparametersets(dummyvar=i2) = i2
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF (lcnt <= 0)
  SET error_flag = "Y"
  CALL bederror("No parameter sets provided.")
  GO TO exit_script
 ENDIF
 FOR (lidx = 1 TO lcnt)
   IF ((request->parameter_set[lidx].end_effective_dt_tm >= cnvtdatetime("02-JAN-2100")))
    SET request->parameter_set[lidx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->parameter_set,lcnt)
 SET stat = alterlist(parm_set_info->qual,lcnt)
 IF ( NOT (validateparametersets(0)))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter_set"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  CALL bederror("validateParameterSets()")
  GO TO exit_script
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(parm_set_info)
 ENDIF
 CASE (request->action_flag)
  OF 1:
   IF ( NOT (addparametersets(0)))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter_set"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror("addParameterSets()")
    GO TO exit_script
   ENDIF
   IF ( NOT (uptparametersets(0)))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter_set"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror("uptParameterSets()")
    GO TO exit_script
   ENDIF
 ENDCASE
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE validateparametersets(dummyvar)
   DECLARE bdupnameind = i2 WITH protect, noconstant(false)
   DECLARE brownotfoundind = i2 WITH protect, noconstant(false)
   IF (lcnt > 0)
    FOR (lidx = 1 TO lcnt)
      SET reply->parameter_set[lidx].id = request->parameter_set[lidx].id
      SET parm_set_info->qual[lidx].id = request->parameter_set[lidx].id
      SET request->parameter_set[lidx].name = cnvtupper(request->parameter_set[lidx].name)
    ENDFOR
    IF ((request->action_flag=1))
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateParameterSets","Checking for duplicate names...")
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(lcnt)),
       rc_parameter_set rps
      PLAN (d
       WHERE textlen(trim(request->parameter_set[d.seq].name,3)) > 0)
       JOIN (rps
       WHERE (rps.parm_set_name=request->parameter_set[d.seq].name)
        AND (rps.parm_set_type_cd=request->parameter_set[d.seq].parm_set_type.code_value)
        AND (rps.rc_parameter_set_id != request->parameter_set[d.seq].id)
        AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
       )) )
      DETAIL
       IF (rps.rc_parameter_set_id > 0.0)
        parm_set_info->qual[d.seq].dup_name_ind = 1, bdupnameind = true
       ENDIF
      WITH nocounter
     ;end select
     IF (bdupnameind)
      SET serrmsg = "Duplicate parameter set names found in request."
      IF (validate(debug,0)=1)
       CALL bedlogmessage("validateParameterSets",build("#ERROR=",serrmsg))
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0)=1)
     CALL bedlogmessage("validateParameterSets","Ensuring rows exist for IDs provided...")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(lcnt)),
      rc_parameter_set rps
     PLAN (d
      WHERE (request->parameter_set[d.seq].id > 0.0))
      JOIN (rps
      WHERE (rps.rc_parameter_set_id=request->parameter_set[d.seq].id)
       AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
      )) )
     DETAIL
      IF (rps.rc_parameter_set_id > 0.0)
       parm_set_info->qual[d.seq].row_found_ind = 1
       IF ((request->parameter_set[d.seq].active_ind_ind=1)
        AND (request->parameter_set[d.seq].active_ind != rps.active_ind))
        parm_set_info->qual[d.seq].active_ind_chg_ind = true
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    FOR (lidx = 1 TO lcnt)
      IF ((request->parameter_set[lidx].id > 0.0))
       CASE (request->action_flag)
        OF - (1):
         SET parm_set_info->qual[lidx].action_type = "DEL"
         SET parm_set_info->del_cnt = (parm_set_info->del_cnt+ 1)
        OF 1:
         SET parm_set_info->qual[lidx].action_type = "UPT"
         SET parm_set_info->upt_cnt = (parm_set_info->upt_cnt+ 1)
       ENDCASE
       IF ((parm_set_info->qual[lidx].row_found_ind=0))
        SET brownotfoundind = true
       ENDIF
      ELSEIF ((request->action_flag=1))
       SET parm_set_info->qual[lidx].action_type = "ADD"
       SET parm_set_info->add_cnt = (parm_set_info->add_cnt+ 1)
       SELECT INTO "nl:"
        new_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         parm_set_info->qual[lidx].id = new_id, reply->parameter_set[lidx].id = new_id
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
    IF (brownotfoundind)
     SET serrmsg = "Row not found for ID found in request."
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateParameterSets",build("#ERROR=",serrmsg))
     ENDIF
     RETURN(false)
    ENDIF
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE addparametersets(dummyvar)
   IF (lcnt > 0
    AND (parm_set_info->add_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("addParameterSets",build(
       "Attempting to insert parameter set(s)...  INSERT COUNT=",parm_set_info->add_cnt))
    ENDIF
    SET ierrcode = 0
    INSERT  FROM rc_parameter_set rps,
      (dummyt d  WITH seq = value(lcnt))
     SET rps.rc_parameter_set_id = reply->parameter_set[d.seq].id, rps.parm_set_type_cd = request->
      parameter_set[d.seq].parm_set_type.code_value, rps.parm_set_name = request->parameter_set[d.seq
      ].name,
      rps.create_dt_tm = cnvtdatetime(curdate,curtime3), rps.create_prsnl_id = reqinfo->updt_id, rps
      .beg_effective_dt_tm = evaluate(request->parameter_set[d.seq].beg_effective_dt_tm,0.0,
       cnvtdatetime(curdate,curtime3),cnvtdatetime(request->parameter_set[d.seq].beg_effective_dt_tm)
       ),
      rps.end_effective_dt_tm = evaluate(request->parameter_set[d.seq].end_effective_dt_tm,0.0,
       cnvtdatetime("31-DEC-2100"),cnvtdatetime(request->parameter_set[d.seq].end_effective_dt_tm)),
      rps.active_ind = evaluate(request->parameter_set[d.seq].active_ind_ind,0,1,request->
       parameter_set[d.seq].active_ind), rps.active_status_prsnl_id = reqinfo->updt_id,
      rps.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rps.active_status_cd = cs48_active_cd,
      rps.updt_cnt = 0,
      rps.updt_id = reqinfo->updt_id, rps.updt_dt_tm = cnvtdatetime(curdate,curtime3), rps.updt_task
       = reqinfo->updt_task,
      rps.updt_applctx = reqinfo->updt_applctx, rps.logical_domain_id = evaluate(request->
       parameter_set[d.seq].parm_set_type.code_value,d_cs4622006_global_cd,0.0,logical_domain_id)
     PLAN (d
      WHERE (parm_set_info->qual[d.seq].action_type="ADD")
       AND (parm_set_info->qual[d.seq].id > 0.00))
      JOIN (rps)
     WITH nocounter, rdbarrayinsert = 1
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("addParameterSets",build("#ERROR=",serrmsg))
     ENDIF
     ROLLBACK
     RETURN(false)
    ELSE
     COMMIT
     RETURN(true)
    ENDIF
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE uptparametersets(dummyvar)
   IF (lcnt > 0
    AND (parm_set_info->upt_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("uptParameterSets",build(
       "Attempting to insert parameter set(s)...  UPDATE COUNT=",parm_set_info->upt_cnt))
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM rc_parameter_set rps,
      (dummyt d  WITH seq = value(lcnt))
     SET rps.parm_set_name = evaluate(textlen(trim(request->parameter_set[d.seq].name,3)),0,rps
       .parm_set_name,request->parameter_set[d.seq].name), rps.parm_set_type_cd = evaluate(request->
       parameter_set[d.seq].parm_set_type.code_value,0.0,rps.parm_set_type_cd,request->parameter_set[
       d.seq].parm_set_type.code_value), rps.beg_effective_dt_tm = evaluate(request->parameter_set[d
       .seq].beg_effective_dt_tm,0.0,rps.beg_effective_dt_tm,cnvtdatetime(request->parameter_set[d
        .seq].beg_effective_dt_tm)),
      rps.end_effective_dt_tm = evaluate(request->parameter_set[d.seq].end_effective_dt_tm,0.0,rps
       .end_effective_dt_tm,cnvtdatetime(request->parameter_set[d.seq].end_effective_dt_tm)), rps
      .active_ind = evaluate(parm_set_info->qual[d.seq].active_ind_chg_ind,1,request->parameter_set[d
       .seq].active_ind,rps.active_ind), rps.active_status_prsnl_id = evaluate(parm_set_info->qual[d
       .seq].active_ind_chg_ind,1,reqinfo->updt_id,rps.active_status_prsnl_id),
      rps.active_status_dt_tm = evaluate(parm_set_info->qual[d.seq].active_ind_chg_ind,1,cnvtdatetime
       (curdate,curtime3),rps.active_status_dt_tm), rps.active_status_cd = evaluate(parm_set_info->
       qual[d.seq].active_ind_chg_ind,1,evaluate(request->parameter_set[d.seq].active_ind,1,
        cs48_active_cd,cs48_inactive_cd),rps.active_status_cd), rps.updt_cnt = (rps.updt_cnt+ 1),
      rps.updt_id = reqinfo->updt_id, rps.updt_dt_tm = cnvtdatetime(curdate,curtime3), rps.updt_task
       = reqinfo->updt_task,
      rps.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (parm_set_info->qual[d.seq].action_type="UPT"))
      JOIN (rps
      WHERE (rps.rc_parameter_set_id=request->parameter_set[d.seq].id)
       AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
      )) )
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("uptParameterSets",build("#ERROR=",serrmsg))
     ENDIF
     ROLLBACK
     RETURN(false)
    ELSE
     COMMIT
     RETURN(true)
    ENDIF
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
END GO
