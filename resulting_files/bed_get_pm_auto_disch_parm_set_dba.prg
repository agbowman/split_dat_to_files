CREATE PROGRAM bed_get_pm_auto_disch_parm_set:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reltn[*]
      2 id = f8
      2 rc_parameter_set_id = f8
      2 encntr_type
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 loc_facility
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 loc_nurse_unit
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 active_ind = i2
    1 reltn_summary[*]
      2 encntr_type
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 facility_cnt = i4
      2 unit_summary[*]
        3 loc_facility
          4 code_value = f8
          4 display = vc
          4 description = vc
          4 cdf_meaning = vc
          4 collation_seq = i4
        3 unit_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD reltnlist
 RECORD reltnlist(
   1 reltn[*]
     2 id = f8
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
 DECLARE getreltns(dummyvar=i2) = i2
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 IF (size(request->reltn,5) > 0)
  IF ( NOT (getreltns(0)))
   CALL bederror("Could not return list of auto discharge relations.")
  ENDIF
 ELSE
  CALL bederror("No criteria provided in request.")
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getreltns(dummyvar)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   CALL echo("Loading reltns...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->reltn,5))),
     rc_parameter_set rps,
     pm_auto_disch_parm_set_r padpsr,
     code_value cv_etype,
     code_value cv_fac,
     code_value cv_unit
    PLAN (d
     WHERE (request->reltn[d.seq].rc_parameter_set_id > 0.0))
     JOIN (rps
     WHERE (rps.rc_parameter_set_id=request->reltn[d.seq].rc_parameter_set_id)
      AND rps.logical_domain_id=logical_domain_id)
     JOIN (padpsr
     WHERE padpsr.rc_parameter_set_id=rps.rc_parameter_set_id
      AND (request->reltn[d.seq].encntr_type.code_value IN (0.0, padpsr.encntr_type_cd))
      AND (request->reltn[d.seq].loc_facility.code_value IN (0.0, padpsr.loc_facility_cd))
      AND (request->reltn[d.seq].loc_nurse_unit.code_value IN (0.0, padpsr.loc_nurse_unit_cd))
      AND ((padpsr.loc_nurse_unit_cd=0.0) OR ( EXISTS (
     (SELECT
      "x"
      FROM pm_auto_disch_parm_set_r padpsr2
      WHERE padpsr2.encntr_type_cd=padpsr.encntr_type_cd
       AND padpsr2.loc_facility_cd=padpsr.loc_facility_cd
       AND padpsr2.loc_nurse_unit_cd=0.0)))) )
     JOIN (cv_etype
     WHERE cv_etype.code_value=padpsr.encntr_type_cd)
     JOIN (cv_fac
     WHERE cv_fac.code_value=padpsr.loc_facility_cd)
     JOIN (cv_unit
     WHERE cv_unit.code_value=padpsr.loc_nurse_unit_cd)
    HEAD REPORT
     lcnt = 0
    DETAIL
     IF (padpsr.pm_auto_disch_parm_set_r_id > 0.0)
      lcnt = (lcnt+ 1)
      IF (lcnt > size(reply->reltn,5))
       stat = alterlist(reply->reltn,(lcnt+ 9))
      ENDIF
      reply->reltn[lcnt].id = padpsr.pm_auto_disch_parm_set_r_id, reply->reltn[lcnt].
      rc_parameter_set_id = padpsr.rc_parameter_set_id, reply->reltn[lcnt].beg_effective_dt_tm =
      padpsr.beg_effective_dt_tm,
      reply->reltn[lcnt].encntr_type.code_value = cv_etype.code_value, reply->reltn[lcnt].encntr_type
      .display = cv_etype.display, reply->reltn[lcnt].encntr_type.description = cv_etype.description,
      reply->reltn[lcnt].encntr_type.cdf_meaning = cv_etype.cdf_meaning, reply->reltn[lcnt].
      encntr_type.collation_seq = cv_etype.collation_seq, reply->reltn[lcnt].loc_facility.code_value
       = cv_fac.code_value,
      reply->reltn[lcnt].loc_facility.display = cv_fac.display, reply->reltn[lcnt].loc_facility.
      description = cv_fac.description, reply->reltn[lcnt].loc_facility.cdf_meaning = cv_fac
      .cdf_meaning,
      reply->reltn[lcnt].loc_nurse_unit.collation_seq = cv_unit.collation_seq, reply->reltn[lcnt].
      loc_nurse_unit.code_value = cv_unit.code_value, reply->reltn[lcnt].loc_nurse_unit.display =
      cv_unit.display,
      reply->reltn[lcnt].loc_nurse_unit.description = cv_unit.description, reply->reltn[lcnt].
      loc_nurse_unit.cdf_meaning = cv_unit.cdf_meaning, reply->reltn[lcnt].loc_nurse_unit.
      collation_seq = cv_unit.collation_seq
      IF (padpsr.end_effective_dt_tm >= cnvtdatetime("02-JAN-2100"))
       reply->reltn[lcnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      ELSE
       reply->reltn[lcnt].end_effective_dt_tm = padpsr.end_effective_dt_tm
      ENDIF
      reply->reltn[lcnt].active_ind = padpsr.active_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->reltn,lcnt)
    WITH nocounter
   ;end select
   IF (lcnt > 0
    AND size(reply->reltn,5) > 0)
    CALL echo("Generating summary...")
    SELECT INTO "nl:"
     encntr_type_disp = substring(1,40,cnvtupper(reply->reltn[d.seq].encntr_type.display)),
     encntr_type_cd = reply->reltn[d.seq].encntr_type.code_value, facility_disp = substring(1,40,
      cnvtupper(reply->reltn[d.seq].loc_facility.display)),
     facility_cd = reply->reltn[d.seq].loc_facility.code_value, nurse_unit_disp = substring(1,40,
      cnvtupper(reply->reltn[d.seq].loc_nurse_unit.display)), nurse_unit_cd = reply->reltn[d.seq].
     loc_nurse_unit.code_value
     FROM (dummyt d  WITH seq = value(size(reply->reltn,5)))
     PLAN (d
      WHERE (reply->reltn[d.seq].rc_parameter_set_id > 0.0))
     ORDER BY encntr_type_disp, encntr_type_cd, facility_disp,
      facility_cd, nurse_unit_disp, nurse_unit_cd
     HEAD REPORT
      ecnt = 0, fcnt = 0, ncnt = 0
     HEAD encntr_type_cd
      fcnt = 0, ncnt = 0, ecnt = (ecnt+ 1)
      IF (ecnt > size(reply->reltn_summary,5))
       stat = alterlist(reply->reltn_summary,(ecnt+ 9))
      ENDIF
      reply->reltn_summary[ecnt].encntr_type.code_value = reply->reltn[d.seq].encntr_type.code_value,
      reply->reltn_summary[ecnt].encntr_type.display = reply->reltn[d.seq].encntr_type.display, reply
      ->reltn_summary[ecnt].encntr_type.description = reply->reltn[d.seq].encntr_type.description,
      reply->reltn_summary[ecnt].encntr_type.cdf_meaning = reply->reltn[d.seq].encntr_type.
      cdf_meaning, reply->reltn_summary[ecnt].encntr_type.collation_seq = reply->reltn[d.seq].
      encntr_type.collation_seq
     HEAD facility_cd
      ncnt = 0
      IF (facility_cd > 0.0)
       fcnt = (fcnt+ 1)
       IF (fcnt > size(reply->reltn_summary[ecnt].unit_summary,5))
        stat = alterlist(reply->reltn_summary[ecnt].unit_summary,(fcnt+ 9))
       ENDIF
       reply->reltn_summary[ecnt].unit_summary[fcnt].loc_facility.code_value = reply->reltn[d.seq].
       loc_facility.code_value, reply->reltn_summary[ecnt].unit_summary[fcnt].loc_facility.display =
       reply->reltn[d.seq].loc_facility.display, reply->reltn_summary[ecnt].unit_summary[fcnt].
       loc_facility.description = reply->reltn[d.seq].loc_facility.description,
       reply->reltn_summary[ecnt].unit_summary[fcnt].loc_facility.cdf_meaning = reply->reltn[d.seq].
       loc_facility.cdf_meaning, reply->reltn_summary[ecnt].unit_summary[fcnt].loc_facility.
       collation_seq = reply->reltn[d.seq].loc_facility.collation_seq
      ENDIF
     HEAD nurse_unit_cd
      IF (nurse_unit_cd > 0.0)
       ncnt = (ncnt+ 1)
      ENDIF
     FOOT  facility_cd
      IF (fcnt > 0
       AND fcnt <= size(reply->reltn_summary[ecnt].unit_summary,5))
       reply->reltn_summary[ecnt].unit_summary[fcnt].unit_cnt = ncnt
      ENDIF
     FOOT  encntr_type_cd
      stat = alterlist(reply->reltn_summary[ecnt].unit_summary,fcnt), reply->reltn_summary[ecnt].
      facility_cnt = fcnt
     FOOT REPORT
      stat = alterlist(reply->reltn_summary,ecnt)
     WITH nocounter
    ;end select
   ENDIF
   RETURN(true)
 END ;Subroutine
END GO
