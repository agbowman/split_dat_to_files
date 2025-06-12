CREATE PROGRAM bed_ens_rc_parameter:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_cnt = i4
    1 parameter[*]
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
 FREE RECORD parm_info
 RECORD parm_info(
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
 DECLARE lcnt = i4 WITH protect, constant(size(request->parameter,5))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 DECLARE validateparameters(dummyvar=i2) = i2
 DECLARE addparameters(dummyvar=i2) = i2
 DECLARE uptparameters(dummyvar=i2) = i2
 DECLARE delparameters(dummyvar=i2) = i2
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF (lcnt <= 0)
  SET error_flag = "Y"
  CALL bederror("No parameters provided.")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->parameter,lcnt)
 SET stat = alterlist(parm_info->qual,lcnt)
 IF ( NOT (validateparameters(0)))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  CALL bederror("validateParameters()")
  GO TO exit_script
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(parm_info)
 ENDIF
 CASE (request->action_flag)
  OF 1:
   IF ( NOT (addparameters(0)))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror("addParameters()")
    GO TO exit_script
   ENDIF
   IF ( NOT (uptparameters(0)))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror("uptParameters()")
    GO TO exit_script
   ENDIF
  OF - (1):
   IF ( NOT (delparameters(0)))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "bed_ens_rc_parameter"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror("delParameters()")
    GO TO exit_script
   ENDIF
 ENDCASE
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE validateparameters(dummyvar)
   DECLARE bdupnameind = i2 WITH protect, noconstant(false)
   DECLARE brownotfoundind = i2 WITH protect, noconstant(false)
   IF (lcnt > 0)
    FOR (lidx = 1 TO lcnt)
      SET reply->parameter[lidx].id = request->parameter[lidx].id
      SET parm_info->qual[lidx].id = request->parameter[lidx].id
      SET request->parameter[lidx].name = cnvtupper(request->parameter[lidx].name)
    ENDFOR
    IF ((request->action_flag=1))
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateParameters","Checking for duplicate names...")
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(lcnt)),
       rc_parameter rp
      PLAN (d
       WHERE (request->parameter[d.seq].rc_parameter_set_id > 0.0)
        AND textlen(trim(request->parameter[d.seq].name,3)) > 0)
       JOIN (rp
       WHERE (rp.rc_parameter_set_id=request->parameter[d.seq].rc_parameter_set_id)
        AND (rp.parm_name=request->parameter[d.seq].name)
        AND (rp.parm_name_cd=request->parameter[d.seq].parm_name.code_value)
        AND (rp.rc_parameter_id != request->parameter[d.seq].id))
      DETAIL
       IF (rp.rc_parameter_id > 0.0)
        parm_info->qual[d.seq].dup_name_ind = 1, bdupnameind = true
       ENDIF
      WITH nocounter
     ;end select
     IF (bdupnameind)
      SET serrmsg = "Duplicate parameter names found in request."
      IF (validate(debug,0)=1)
       CALL bedlogmessage("validateParameters",build("#ERROR=",serrmsg))
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0)=1)
     CALL bedlogmessage("validateParameters","Ensuring rows exist for IDs provided...")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(lcnt)),
      rc_parameter rp
     PLAN (d
      WHERE (request->parameter[d.seq].id > 0.0))
      JOIN (rp
      WHERE (rp.rc_parameter_id=request->parameter[d.seq].id))
     DETAIL
      IF (rp.rc_parameter_id > 0.0)
       parm_info->qual[d.seq].row_found_ind = 1
       IF ((request->parameter[d.seq].active_ind_ind=1)
        AND (request->parameter[d.seq].active_ind != rp.active_ind))
        parm_info->qual[d.seq].active_ind_chg_ind = true
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    FOR (lidx = 1 TO lcnt)
      IF ((request->parameter[lidx].id > 0.0))
       CASE (request->action_flag)
        OF - (1):
         SET parm_info->qual[lidx].action_type = "DEL"
         SET parm_info->del_cnt = (parm_info->del_cnt+ 1)
        OF 1:
         SET parm_info->qual[lidx].action_type = "UPT"
         SET parm_info->upt_cnt = (parm_info->upt_cnt+ 1)
       ENDCASE
       IF ((parm_info->qual[lidx].row_found_ind=0))
        SET brownotfoundind = true
       ENDIF
      ELSEIF ((request->action_flag=1))
       SET parm_info->qual[lidx].action_type = "ADD"
       SET parm_info->add_cnt = (parm_info->add_cnt+ 1)
       SELECT INTO "nl:"
        new_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         parm_info->qual[lidx].id = new_id, reply->parameter[lidx].id = new_id
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
    IF (brownotfoundind)
     SET serrmsg = "Row not found for ID found in request."
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateParameters",build("#ERROR=",serrmsg))
     ENDIF
     RETURN(false)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addparameters(dummyvar)
   IF (lcnt > 0
    AND (parm_info->add_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("addParameters",build("Attempting to insert parameter(s)...  INSERT COUNT=",
       parm_info->add_cnt))
    ENDIF
    SET ierrcode = 0
    INSERT  FROM rc_parameter rp,
      (dummyt d  WITH seq = value(lcnt))
     SET rp.rc_parameter_set_id = request->parameter[d.seq].rc_parameter_set_id, rp.rc_parameter_id
       = reply->parameter[d.seq].id, rp.parm_name = request->parameter[d.seq].name,
      rp.parm_name_cd = request->parameter[d.seq].parm_name.code_value, rp.parm_value = request->
      parameter[d.seq].parm_value.code_value, rp.parm_value_nbr = request->parameter[d.seq].
      parm_value_nbr,
      rp.parm_value_txt = request->parameter[d.seq].parm_value_txt, rp.parm_value_dt_tm =
      cnvtdatetime(request->parameter[d.seq].parm_value_dt_tm), rp.parm_value_type_flag = request->
      parameter[d.seq].parm_value_type_flag,
      rp.create_dt_tm = cnvtdatetime(curdate,curtime3), rp.create_prsnl_id = reqinfo->updt_id, rp
      .beg_effective_dt_tm = evaluate(request->parameter[d.seq].beg_effective_dt_tm,0.0,cnvtdatetime(
        curdate,curtime3),cnvtdatetime(request->parameter[d.seq].beg_effective_dt_tm)),
      rp.end_effective_dt_tm = evaluate(request->parameter[d.seq].end_effective_dt_tm,0.0,
       cnvtdatetime("31-DEC-2100"),cnvtdatetime(request->parameter[d.seq].end_effective_dt_tm)), rp
      .active_ind = evaluate(request->parameter[d.seq].active_ind_ind,0,1,request->parameter[d.seq].
       active_ind), rp.active_status_prsnl_id = reqinfo->updt_id,
      rp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rp.active_status_cd = cs48_active_cd,
      rp.updt_cnt = 0,
      rp.updt_id = reqinfo->updt_id, rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_task =
      reqinfo->updt_task,
      rp.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (parm_info->qual[d.seq].action_type="ADD")
       AND (parm_info->qual[d.seq].id > 0.00))
      JOIN (rp)
     WITH nocounter, rdbarrayinsert = 1
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("addParameters",build("#ERROR=",serrmsg))
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
 SUBROUTINE uptparameters(dummyvar)
   IF (lcnt > 0
    AND (parm_info->upt_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("uptParameters",build("Attempting to insert parameter(s)...  UPDATE COUNT=",
       parm_info->upt_cnt))
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM rc_parameter rp,
      (dummyt d  WITH seq = value(lcnt))
     SET rp.rc_parameter_set_id = evaluate(request->parameter[d.seq].rc_parameter_set_id,0.0,rp
       .rc_parameter_set_id,request->parameter[d.seq].rc_parameter_set_id), rp.parm_name = evaluate(
       textlen(trim(request->parameter[d.seq].name,3)),0,rp.parm_name,request->parameter[d.seq].name),
      rp.parm_name_cd = evaluate(request->parameter[d.seq].parm_name.code_value,0.0,rp.parm_name_cd,
       request->parameter[d.seq].parm_name.code_value),
      rp.parm_value = request->parameter[d.seq].parm_value.code_value, rp.parm_value_nbr = request->
      parameter[d.seq].parm_value_nbr, rp.parm_value_txt = request->parameter[d.seq].parm_value_txt,
      rp.parm_value_dt_tm = cnvtdatetime(request->parameter[d.seq].parm_value_dt_tm), rp
      .parm_value_type_flag = request->parameter[d.seq].parm_value_type_flag, rp.beg_effective_dt_tm
       = evaluate(request->parameter[d.seq].beg_effective_dt_tm,0.0,rp.beg_effective_dt_tm,
       cnvtdatetime(request->parameter[d.seq].beg_effective_dt_tm)),
      rp.end_effective_dt_tm = evaluate(request->parameter[d.seq].end_effective_dt_tm,0.0,rp
       .end_effective_dt_tm,cnvtdatetime(request->parameter[d.seq].end_effective_dt_tm)), rp
      .active_ind = evaluate(parm_info->qual[d.seq].active_ind_chg_ind,1,request->parameter[d.seq].
       active_ind,rp.active_ind), rp.active_status_prsnl_id = evaluate(parm_info->qual[d.seq].
       active_ind_chg_ind,1,reqinfo->updt_id,rp.active_status_prsnl_id),
      rp.active_status_dt_tm = evaluate(parm_info->qual[d.seq].active_ind_chg_ind,1,cnvtdatetime(
        curdate,curtime3),rp.active_status_dt_tm), rp.active_status_cd = evaluate(parm_info->qual[d
       .seq].active_ind_chg_ind,1,evaluate(request->parameter[d.seq].active_ind,1,cs48_active_cd,
        cs48_inactive_cd),rp.active_status_cd), rp.updt_cnt = (rp.updt_cnt+ 1),
      rp.updt_id = reqinfo->updt_id, rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_task =
      reqinfo->updt_task,
      rp.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (parm_info->qual[d.seq].action_type="UPT"))
      JOIN (rp
      WHERE (rp.rc_parameter_id=request->parameter[d.seq].id))
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("uptParameters",build("#ERROR=",serrmsg))
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
 SUBROUTINE delparameters(dummyvar)
   IF (lcnt > 0
    AND (parm_info->del_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("delParameters",build("Attempting to delete parameter(s)...  DELETE COUNT=",
       parm_info->del_cnt))
    ENDIF
    SET ierrcode = 0
    DELETE  FROM rc_parameter rp,
      (dummyt d  WITH seq = value(lcnt))
     SET rp.seq = 1
     PLAN (d
      WHERE (parm_info->qual[d.seq].action_type="DEL"))
      JOIN (rp
      WHERE (rp.rc_parameter_id=request->parameter[d.seq].id))
     WITH nocounter, rdbarrayinsert = 1
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("delParameters",build("#ERROR=",serrmsg))
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
