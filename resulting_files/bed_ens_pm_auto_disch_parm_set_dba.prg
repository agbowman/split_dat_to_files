CREATE PROGRAM bed_ens_pm_auto_disch_parm_set:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reltn[*]
      2 id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 invalidconfigflag = i2
    1 invalidconfigflagtxt = vc
    1 invalidconfigflagmeaning = vc
  ) WITH protect
 ENDIF
 FREE RECORD reltn_info
 RECORD reltn_info(
   1 add_cnt = i4
   1 upt_cnt = i4
   1 del_cnt = i4
   1 qual[*]
     2 id = f8
     2 action_type = vc
     2 row_found_ind = i2
     2 dup_ind = i2
     2 active_ind_chg_ind = i2
     2 encntr_type_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
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
 CALL bedbeginscript(0)
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs48_inactive_cd)))
  DECLARE cs48_inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 DECLARE d_logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 IF ( NOT (validate(s_ens_duplicate_build)))
  DECLARE s_ens_duplicate_build = vc WITH protect, constant("ENS_DUPLICATE_BUILD")
 ENDIF
 IF ( NOT (validate(s_ens_duplicate_reltn)))
  DECLARE s_ens_duplicate_reltn = vc WITH protect, constant("ENS_DUPLICATE_RELTN")
 ENDIF
 IF ( NOT (validate(s_ens_invalid_reltn_all)))
  DECLARE s_ens_invalid_reltn_all = vc WITH protect, constant("ENS_INVALID_RELTN_ALL")
 ENDIF
 IF ( NOT (validate(s_ens_invalid_reltn_fac)))
  DECLARE s_ens_invalid_reltn_fac = vc WITH protect, constant("ENS_INVALID_RELTN_FAC")
 ENDIF
 IF ( NOT (validate(s_ens_val_reltn_err)))
  DECLARE s_ens_val_reltn_err = vc WITH protect, constant("ENS_VAL_RELTN_ERR")
 ENDIF
 IF ( NOT (validate(s_ens_del_reltn_err)))
  DECLARE s_ens_del_reltn_err = vc WITH protect, constant("ENS_DEL_RELTN_ERR")
 ENDIF
 IF ( NOT (validate(s_ens_add_reltn_err)))
  DECLARE s_ens_add_reltn_err = vc WITH protect, constant("ENS_ADD_RELTN_ERR")
 ENDIF
 IF ( NOT (validate(s_ens_upt_reltn_err)))
  DECLARE s_ens_upt_reltn_err = vc WITH protect, constant("ENS_UPT_RELTN_ERR")
 ENDIF
 DECLARE lcnt = i4 WITH protect, constant(size(request->reltn,5))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 DECLARE validaterelations(dummyvar=i2) = i2
 DECLARE addrelations(dummyvar=i2) = i2
 DECLARE uptrelations(dummyvar=i2) = i2
 DECLARE delrelations(dummyvar=i2) = i2
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF (lcnt <= 0)
  SET error_flag = "Y"
  CALL bederror("No auto discharge relations provided.")
  GO TO exit_script
 ENDIF
 FOR (lidx = 1 TO lcnt)
   IF ((request->reltn[lidx].end_effective_dt_tm >= cnvtdatetime("02-JAN-2100")))
    SET request->reltn[lidx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->reltn,lcnt)
 SET stat = alterlist(reltn_info->qual,lcnt)
 IF ( NOT (validaterelations(0)))
  IF ((reply->invalidconfigflag=true))
   GO TO exit_script
  ELSE
   SET reply->invalidconfigflag = true
   SET reply->invalidconfigflagtxt = serrmsg
   SET reply->invalidconfigflagmeaning = s_ens_val_reltn_err
   GO TO exit_script
  ENDIF
 ENDIF
 CASE (request->action_flag)
  OF 1:
   IF ( NOT (addrelations(0)))
    SET reply->invalidconfigflag = true
    SET reply->invalidconfigflagtxt = serrmsg
    SET reply->invalidconfigflagmeaning = s_ens_add_reltn_err
    CALL bedlogmessage("addRelations()",build("#ERROR=",serrmsg))
    GO TO exit_script
   ENDIF
   IF ( NOT (uptrelations(0)))
    SET reply->invalidconfigflag = true
    SET reply->invalidconfigflagtxt = serrmsg
    SET reply->invalidconfigflagmeaning = s_ens_upt_reltn_err
    CALL bedlogmessage("uptRelations()",build("#ERROR=",serrmsg))
    GO TO exit_script
   ENDIF
  OF - (1):
   IF ( NOT (delrelations(0)))
    SET reply->invalidconfigflag = true
    SET reply->invalidconfigflagtxt = serrmsg
    SET reply->invalidconfigflagmeaning = s_ens_del_reltn_err
    CALL bedlogmessage("delRelations()",build("#ERROR=",serrmsg))
    GO TO exit_script
   ENDIF
 ENDCASE
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reltn_info)
 ENDIF
 CALL bedexitscript(1)
 SUBROUTINE validaterelations(dummyvar)
   DECLARE bdupind = i2 WITH protect, noconstant(false)
   DECLARE brownotfoundind = i2 WITH protect, noconstant(false)
   IF (lcnt > 0)
    FOR (lidx = 1 TO lcnt)
     SET reply->reltn[lidx].id = request->reltn[lidx].id
     SET reltn_info->qual[lidx].id = request->reltn[lidx].id
    ENDFOR
    IF ((request->action_flag=1))
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateRelations","Checking for duplicates...")
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(lcnt)),
       pm_auto_disch_parm_set_r padpsr,
       rc_parameter_set rps
      PLAN (d
       WHERE (request->reltn[d.seq].rc_parameter_set_id > 0.0))
       JOIN (padpsr
       WHERE (padpsr.rc_parameter_set_id=request->reltn[d.seq].rc_parameter_set_id)
        AND (padpsr.encntr_type_cd=request->reltn[d.seq].encntr_type.code_value)
        AND (padpsr.loc_facility_cd=request->reltn[d.seq].loc_facility.code_value)
        AND (padpsr.loc_nurse_unit_cd=request->reltn[d.seq].loc_nurse_unit.code_value)
        AND (padpsr.pm_auto_disch_parm_set_r_id != request->reltn[d.seq].id))
       JOIN (rps
       WHERE rps.rc_parameter_set_id=padpsr.rc_parameter_set_id)
      DETAIL
       IF (padpsr.pm_auto_disch_parm_set_r_id > 0.0)
        IF ((request->reltn[d.seq].loc_facility.code_value=0.0)
         AND padpsr.loc_facility_cd > 0.0)
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_invalid_reltn_all, reltn_info->qual[
         d.seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps.parm_set_name,
           3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ELSEIF ((request->reltn[d.seq].loc_facility.code_value > 0.0)
         AND padpsr.loc_facility_cd=0.0)
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_invalid_reltn_fac, reltn_info->qual[
         d.seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps.parm_set_name,
           3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ELSEIF ((request->reltn[d.seq].loc_facility.code_value=padpsr.loc_facility_cd))
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_duplicate_build, reltn_info->qual[d
         .seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps.parm_set_name,
           3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (bdupind)
      SET serrmsg = "Duplicate auto discharge relations found in request."
      IF (validate(debug,0)=1)
       CALL bedlogmessage("validateRelations",build("#ERROR=",serrmsg))
      ENDIF
      RETURN(false)
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(lcnt)),
       rc_parameter_set rps,
       pm_auto_disch_parm_set_r padpsr,
       rc_parameter_set rps2
      PLAN (d
       WHERE (request->reltn[d.seq].rc_parameter_set_id > 0.0))
       JOIN (rps
       WHERE (rps.rc_parameter_set_id=request->reltn[d.seq].rc_parameter_set_id))
       JOIN (padpsr
       WHERE padpsr.rc_parameter_set_id != rps.rc_parameter_set_id
        AND (padpsr.encntr_type_cd=request->reltn[d.seq].encntr_type.code_value)
        AND (padpsr.pm_auto_disch_parm_set_r_id != request->reltn[d.seq].id)
        AND padpsr.active_ind=1)
       JOIN (rps2
       WHERE rps2.rc_parameter_set_id=padpsr.rc_parameter_set_id
        AND rps2.logical_domain_id=d_logical_domain_id
        AND rps2.parm_set_type_cd=rps.parm_set_type_cd)
      DETAIL
       IF (rps2.rc_parameter_set_id > 0.0)
        IF ((request->reltn[d.seq].loc_facility.code_value=0.0)
         AND padpsr.loc_facility_cd > 0.0)
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_invalid_reltn_all, reltn_info->qual[
         d.seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps2
           .parm_set_name,3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ELSEIF ((request->reltn[d.seq].loc_facility.code_value > 0.0)
         AND padpsr.loc_facility_cd=0.0)
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_invalid_reltn_fac, reltn_info->qual[
         d.seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps2
           .parm_set_name,3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ELSEIF ((request->reltn[d.seq].loc_facility.code_value=padpsr.loc_facility_cd))
         bdupind = true, reply->invalidconfigflagmeaning = s_ens_duplicate_reltn, reltn_info->qual[d
         .seq].dup_ind = 1,
         reply->invalidconfigflag = true, reply->invalidconfigflagtxt = concat(trim(rps2
           .parm_set_name,3)," \ ",trim(uar_get_code_display(padpsr.encntr_type_cd),3)," \ ",trim(
           uar_get_code_display(padpsr.loc_facility_cd),3))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (bdupind)
      SET serrmsg = "Duplicate build across parameter set found in request."
      IF (validate(debug,0)=1)
       CALL bedlogmessage("validateRelations",build("#ERROR=",serrmsg))
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    IF (validate(debug,0)=1)
     CALL bedlogmessage("validateRelations","Ensuring rows exist for IDs provided...")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(lcnt)),
      pm_auto_disch_parm_set_r padpsr
     PLAN (d
      WHERE (request->reltn[d.seq].id > 0.0))
      JOIN (padpsr
      WHERE (padpsr.pm_auto_disch_parm_set_r_id=request->reltn[d.seq].id))
     DETAIL
      IF (padpsr.pm_auto_disch_parm_set_r_id > 0.0)
       reltn_info->qual[d.seq].row_found_ind = 1, reltn_info->qual[d.seq].encntr_type_cd = padpsr
       .encntr_type_cd, reltn_info->qual[d.seq].loc_facility_cd = padpsr.loc_facility_cd,
       reltn_info->qual[d.seq].loc_nurse_unit_cd = padpsr.loc_nurse_unit_cd
       IF ((request->reltn[d.seq].active_ind_ind=1)
        AND (request->reltn[d.seq].active_ind != padpsr.active_ind))
        reltn_info->qual[d.seq].active_ind_chg_ind = true
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    FOR (lidx = 1 TO lcnt)
      IF ((request->reltn[lidx].id > 0.0))
       CASE (request->action_flag)
        OF - (1):
         SET reltn_info->qual[lidx].action_type = "DEL"
         SET reltn_info->del_cnt = (reltn_info->del_cnt+ 1)
        OF 1:
         SET reltn_info->qual[lidx].action_type = "UPT"
         SET reltn_info->upt_cnt = (reltn_info->upt_cnt+ 1)
       ENDCASE
       IF ((reltn_info->qual[lidx].row_found_ind=0))
        SET brownotfoundind = true
       ENDIF
      ELSEIF ((request->action_flag=1))
       SET reltn_info->qual[lidx].action_type = "ADD"
       SET reltn_info->add_cnt = (reltn_info->add_cnt+ 1)
       SELECT INTO "nl:"
        new_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         reltn_info->qual[lidx].id = new_id, reply->reltn[lidx].id = new_id
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
    IF (brownotfoundind)
     SET serrmsg = "Row not found for ID found in request."
     IF (validate(debug,0)=1)
      CALL bedlogmessage("validateRelations",build("#ERROR=",serrmsg))
     ENDIF
     RETURN(false)
    ENDIF
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE addrelations(dummyvar)
   IF (lcnt > 0
    AND (reltn_info->add_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("addRelations",build(
       "Attempting to insert auto discharge relation(s)...  INSERT COUNT=",reltn_info->add_cnt))
    ENDIF
    SET ierrcode = 0
    INSERT  FROM pm_auto_disch_parm_set_r padpsr,
      (dummyt d  WITH seq = value(lcnt))
     SET padpsr.rc_parameter_set_id = request->reltn[d.seq].rc_parameter_set_id, padpsr
      .pm_auto_disch_parm_set_r_id = reply->reltn[d.seq].id, padpsr.encntr_type_cd = request->reltn[d
      .seq].encntr_type.code_value,
      padpsr.loc_facility_cd = request->reltn[d.seq].loc_facility.code_value, padpsr
      .loc_nurse_unit_cd = request->reltn[d.seq].loc_nurse_unit.code_value, padpsr.create_dt_tm =
      cnvtdatetime(curdate,curtime3),
      padpsr.create_prsnl_id = reqinfo->updt_id, padpsr.beg_effective_dt_tm = evaluate(request->
       reltn[d.seq].beg_effective_dt_tm,0.0,cnvtdatetime(curdate,curtime3),cnvtdatetime(request->
        reltn[d.seq].beg_effective_dt_tm)), padpsr.end_effective_dt_tm = evaluate(request->reltn[d
       .seq].end_effective_dt_tm,0.0,cnvtdatetime("31-DEC-2100"),cnvtdatetime(request->reltn[d.seq].
        end_effective_dt_tm)),
      padpsr.active_ind = evaluate(request->reltn[d.seq].active_ind_ind,0,1,request->reltn[d.seq].
       active_ind), padpsr.active_status_prsnl_id = reqinfo->updt_id, padpsr.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      padpsr.active_status_cd = cs48_active_cd, padpsr.updt_cnt = 0, padpsr.updt_id = reqinfo->
      updt_id,
      padpsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), padpsr.updt_task = reqinfo->updt_task,
      padpsr.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (reltn_info->qual[d.seq].action_type="ADD")
       AND (reltn_info->qual[d.seq].id > 0.00))
      JOIN (padpsr)
     WITH nocounter, rdbarrayinsert = 1
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("addRelations",build("#ERROR=",serrmsg))
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
 SUBROUTINE uptrelations(dummyvar)
   IF (lcnt > 0
    AND (reltn_info->upt_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("uptRelations",build(
       "Attempting to insert auto discharge relation(s)...  UPDATE COUNT=",reltn_info->upt_cnt))
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM pm_auto_disch_parm_set_r padpsr,
      (dummyt d  WITH seq = value(lcnt))
     SET padpsr.rc_parameter_set_id = evaluate(request->reltn[d.seq].rc_parameter_set_id,0.0,padpsr
       .rc_parameter_set_id,request->reltn[d.seq].rc_parameter_set_id), padpsr.encntr_type_cd =
      request->reltn[d.seq].encntr_type.code_value, padpsr.loc_facility_cd = request->reltn[d.seq].
      loc_facility.code_value,
      padpsr.loc_nurse_unit_cd = request->reltn[d.seq].loc_nurse_unit.code_value, padpsr
      .beg_effective_dt_tm = evaluate(request->reltn[d.seq].beg_effective_dt_tm,0.0,padpsr
       .beg_effective_dt_tm,cnvtdatetime(request->reltn[d.seq].beg_effective_dt_tm)), padpsr
      .end_effective_dt_tm = evaluate(request->reltn[d.seq].end_effective_dt_tm,0.0,padpsr
       .end_effective_dt_tm,cnvtdatetime(request->reltn[d.seq].end_effective_dt_tm)),
      padpsr.active_ind = evaluate(reltn_info->qual[d.seq].active_ind_chg_ind,1,request->reltn[d.seq]
       .active_ind,padpsr.active_ind), padpsr.active_status_prsnl_id = evaluate(reltn_info->qual[d
       .seq].active_ind_chg_ind,1,reqinfo->updt_id,padpsr.active_status_prsnl_id), padpsr
      .active_status_dt_tm = evaluate(reltn_info->qual[d.seq].active_ind_chg_ind,1,cnvtdatetime(
        curdate,curtime3),padpsr.active_status_dt_tm),
      padpsr.active_status_cd = evaluate(reltn_info->qual[d.seq].active_ind_chg_ind,1,evaluate(
        request->reltn[d.seq].active_ind,1,cs48_active_cd,cs48_inactive_cd),padpsr.active_status_cd),
      padpsr.updt_cnt = (padpsr.updt_cnt+ 1), padpsr.updt_id = reqinfo->updt_id,
      padpsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), padpsr.updt_task = reqinfo->updt_task,
      padpsr.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (reltn_info->qual[d.seq].action_type="UPT"))
      JOIN (padpsr
      WHERE (padpsr.pm_auto_disch_parm_set_r_id=request->reltn[d.seq].id))
     WITH nocounter, rdbarrayinsert = 1
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("uptRelations",build("#ERROR=",serrmsg))
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
 SUBROUTINE delrelations(dummyvar)
   IF (lcnt > 0
    AND (reltn_info->del_cnt > 0))
    IF (validate(debug,0)=1)
     CALL bedlogmessage("delRelations",build(
       "Attempting to delete auto discharge relation(s)...  DELETE COUNT=",reltn_info->del_cnt))
    ENDIF
    SET ierrcode = 0
    DELETE  FROM pm_auto_disch_parm_set_r padpsr,
      (dummyt d  WITH seq = value(lcnt))
     SET padpsr.seq = 1
     PLAN (d
      WHERE (reltn_info->qual[d.seq].action_type="DEL")
       AND (reltn_info->qual[d.seq].loc_facility_cd > 0.0)
       AND (reltn_info->qual[d.seq].loc_nurse_unit_cd <= 0.0))
      JOIN (padpsr
      WHERE (padpsr.encntr_type_cd=reltn_info->qual[d.seq].encntr_type_cd)
       AND (padpsr.loc_facility_cd=reltn_info->qual[d.seq].loc_facility_cd)
       AND padpsr.loc_nurse_unit_cd > 0.0)
     WITH nocounter, rdbarrayinsert = 1
    ;end delete
    DELETE  FROM pm_auto_disch_parm_set_r padpsr,
      (dummyt d  WITH seq = value(lcnt))
     SET padpsr.seq = 1
     PLAN (d
      WHERE (reltn_info->qual[d.seq].action_type="DEL"))
      JOIN (padpsr
      WHERE (padpsr.pm_auto_disch_parm_set_r_id=request->reltn[d.seq].id))
     WITH nocounter, rdbarrayinsert = 1
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     IF (validate(debug,0)=1)
      CALL bedlogmessage("delRelations",build("#ERROR=",serrmsg))
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
