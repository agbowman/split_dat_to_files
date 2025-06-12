CREATE PROGRAM bed_copy_privileges_for_pos:dba
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
 IF ( NOT (validate(cs48_cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 DECLARE privlocreltnid = f8 WITH protect, noconstant(0)
 DECLARE addprivlocreltn(topositioncd=f8) = i2
 DECLARE copyprivileges(frompositioncd=f8,topositioncd=f8) = i2
 CALL addprivlocreltn(request->copy_to_position_cd)
 CALL copyprivileges(request->copy_from_position_cd,request->copy_to_position_cd)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE addprivlocreltn(topositioncd)
   CALL bedlogmessage("addPrivLocReltn()","Entering...")
   SELECT INTO "nl:"
    z = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     privlocreltnid = cnvtreal(z)
    WITH format, nocounter
   ;end select
   INSERT  FROM priv_loc_reltn plr
    SET plr.priv_loc_reltn_id = privlocreltnid, plr.person_id = 0.0, plr.position_cd = topositioncd,
     plr.ppr_cd = 0.0, plr.location_cd = 0.0, plr.updt_cnt = 0,
     plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
      = reqinfo->updt_task,
     plr.updt_applctx = reqinfo->updt_applctx, plr.active_ind = 1, plr.active_status_cd =
     cs48_active_cd,
     plr.active_status_dt_tm = cnvtdatetime(curdate,curtime), plr.active_status_prsnl_id = reqinfo->
     updt_id, plr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
     plr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Failed to insert priv_loc_reltn.")
   CALL bedlogmessage("addPrivLocReltn()","Exiting...")
 END ;Subroutine
 SUBROUTINE copyprivileges(frompositioncd,topositioncd)
   CALL bedlogmessage("copyPrivileges()","Entering...")
   FREE RECORD privs
   RECORD privs(
     1 ids[*]
       2 priv_loc_reltn_id = f8
   )
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr
    PLAN (plr
     WHERE plr.person_id=0.0
      AND plr.position_cd=frompositioncd
      AND plr.ppr_cd=0.0
      AND plr.location_cd=0.0)
    DETAIL
     pcnt = (pcnt+ 1), stat = alterlist(privs->ids,pcnt), privs->ids[pcnt].priv_loc_reltn_id = plr
     .priv_loc_reltn_id
    WITH nocounter
   ;end select
   FOR (p = 1 TO pcnt)
     INSERT  FROM privilege
      (privilege_id, priv_loc_reltn_id, privilege_cd,
      priv_value_cd, updt_cnt, updt_dt_tm,
      updt_id, updt_task, updt_applctx,
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, restr_method_cd, log_grouping_cd)(SELECT
       seq(reference_seq,nextval), privlocreltnid, p.privilege_cd,
       p.priv_value_cd, 0, cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
       p.active_ind, p.active_status_cd, p.active_status_dt_tm,
       p.active_status_prsnl_id, p.restr_method_cd, p.log_grouping_cd
       FROM privilege p
       WHERE (p.priv_loc_reltn_id=privs->ids[p].priv_loc_reltn_id)
        AND p.active_ind=true)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Failed to insert privilege.")
     INSERT  FROM privilege_exception
      (privilege_exception_id, privilege_id, exception_type_cd,
      exception_id, updt_cnt, updt_dt_tm,
      updt_id, updt_task, updt_applctx,
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, exception_entity_name, event_set_name)(SELECT
       seq(reference_seq,nextval), t2.privilege_id, pe.exception_type_cd,
       pe.exception_id, 0, cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
       pe.active_ind, pe.active_status_cd, pe.active_status_dt_tm,
       pe.active_status_prsnl_id, pe.exception_entity_name, pe.event_set_name
       FROM privilege_exception pe,
        privilege t1,
        privilege t2
       WHERE (t1.priv_loc_reltn_id=privs->ids[p].priv_loc_reltn_id)
        AND t2.priv_loc_reltn_id=privlocreltnid
        AND t2.privilege_cd=t1.privilege_cd
        AND t2.priv_value_cd=t1.priv_value_cd
        AND t2.active_ind=t1.active_ind
        AND pe.privilege_id=t1.privilege_id)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Failed to insert privilege_exception.")
     INSERT  FROM priv_group_reltn
      (priv_group_reltn_id, privilege_id, log_grouping_cd,
      updt_cnt, updt_dt_tm, updt_id,
      updt_task, updt_applctx)(SELECT
       seq(reference_seq,nextval), t2.privilege_id, pr.log_grouping_cd,
       0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
       reqinfo->updt_task, reqinfo->updt_applctx
       FROM priv_group_reltn pr,
        privilege t1,
        privilege t2
       WHERE (t1.priv_loc_reltn_id=privs->ids[p].priv_loc_reltn_id)
        AND t2.priv_loc_reltn_id=privlocreltnid
        AND t2.privilege_cd=t1.privilege_cd
        AND t2.priv_value_cd=t1.priv_value_cd
        AND t2.active_ind=t1.active_ind
        AND pr.privilege_id=t1.privilege_id)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Failed to insert priv_group_reltn.")
   ENDFOR
   CALL bedlogmessage("copyPrivileges()","Exiting...")
 END ;Subroutine
END GO
