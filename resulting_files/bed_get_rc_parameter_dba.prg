CREATE PROGRAM bed_get_rc_parameter:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 parameter[*]
      2 rc_parameter_set_id = f8
      2 id = f8
      2 name = vc
      2 parm_name
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 parm_value
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 cdf_meaning = vc
        3 collation_seq = i4
      2 parm_value_nbr = i4
      2 parm_value_txt = vc
      2 parm_value_dt_tm = dq8
      2 parm_value_type_flag = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD parameterlist
 RECORD parameterlist(
   1 parameter[*]
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
 DECLARE getparameters(dummyvar=i2) = i2
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE d_cs4622006_global_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4622006,"GLOBAL"
   ))
 IF (size(request->parameter,5) > 0)
  IF ( NOT (getparameters(0)))
   CALL bederror("Could not return list of parameters.")
  ENDIF
 ELSE
  CALL bederror("No criteria provided in request.")
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getparameters(dummyvar)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   CALL echo("Loading parameters by RC_PARAMETER_SET_ID...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->parameter,5))),
     rc_parameter_set rps,
     rc_parameter rp
    PLAN (d
     WHERE (request->parameter[d.seq].rc_parameter_set_id > 0.0))
     JOIN (rps
     WHERE (rps.rc_parameter_set_id=request->parameter[d.seq].rc_parameter_set_id)
      AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
     )) )
     JOIN (rp
     WHERE rp.rc_parameter_set_id=rps.rc_parameter_set_id
      AND rp.parm_name_cd > 0.0)
    DETAIL
     IF (rp.rc_parameter_id > 0.0)
      lcnt = (lcnt+ 1)
      IF (lcnt > size(parameterlist->parameter,5))
       stat = alterlist(parameterlist->parameter,(lcnt+ 9))
      ENDIF
      parameterlist->parameter[lcnt].id = rp.rc_parameter_id
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("Loading parameters by ID...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->parameter,5))),
     rc_parameter rp,
     rc_parameter_set rps
    PLAN (d
     WHERE (request->parameter[d.seq].id > 0.0))
     JOIN (rp
     WHERE (rp.rc_parameter_id=request->parameter[d.seq].id)
      AND rp.parm_name_cd > 0.0)
     JOIN (rps
     WHERE rps.rc_parameter_set_id=rp.rc_parameter_set_id
      AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
     )) )
    DETAIL
     IF (rp.rc_parameter_id > 0.0)
      lcnt = (lcnt+ 1)
      IF (lcnt > size(parameterlist->parameter,5))
       stat = alterlist(parameterlist->parameter,(lcnt+ 9))
      ENDIF
      parameterlist->parameter[lcnt].id = rp.rc_parameter_id
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("Loading parameters by name...")
   FOR (lidx = 1 TO size(request->parameter,5))
     IF ((request->parameter[lidx].id=0.0))
      SELECT INTO "nl:"
       FROM rc_parameter rp,
        rc_parameter_set rps
       PLAN (rp
        WHERE rp.parm_name=patstring(cnvtupper(request->parameter[lidx].name))
         AND rp.parm_name_cd > 0.0)
        JOIN (rps
        WHERE rps.rc_parameter_set_id=rp.rc_parameter_set_id
         AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=
        d_cs4622006_global_cd)) )
       DETAIL
        IF (rp.rc_parameter_id > 0.0)
         lcnt = (lcnt+ 1)
         IF (lcnt > size(parameterlist->parameter,5))
          stat = alterlist(parameterlist->parameter,(lcnt+ 9))
         ENDIF
         parameterlist->parameter[lcnt].id = rp.rc_parameter_id
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   SET stat = alterlist(parameterlist->parameter,lcnt)
   CALL echo("Compiling unique list of parameters and loading data...")
   SELECT INTO "nl:"
    FROM rc_parameter rp,
     rc_parameter_set rps,
     code_value cv,
     code_value cv2
    PLAN (rp
     WHERE expand(lidx,1,size(parameterlist->parameter,5),rp.rc_parameter_id,parameterlist->
      parameter[lidx].id))
     JOIN (rps
     WHERE rps.rc_parameter_set_id=rp.rc_parameter_set_id
      AND ((rps.logical_domain_id=logical_domain_id) OR (rps.parm_set_type_cd=d_cs4622006_global_cd
     )) )
     JOIN (cv
     WHERE cv.code_value=rp.parm_name_cd)
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(rp.parm_value))
    ORDER BY rp.rc_parameter_id
    HEAD REPORT
     lcnt = 0
    HEAD rp.rc_parameter_id
     IF (rp.rc_parameter_id > 0.0)
      lcnt = (lcnt+ 1)
      IF (lcnt > size(reply->parameter,5))
       stat = alterlist(reply->parameter,(lcnt+ 9))
      ENDIF
      reply->parameter[lcnt].rc_parameter_set_id = rp.rc_parameter_set_id, reply->parameter[lcnt].id
       = rp.rc_parameter_id, reply->parameter[lcnt].name = rp.parm_name,
      reply->parameter[lcnt].parm_name.code_value = cv.code_value, reply->parameter[lcnt].parm_name.
      display = cv.display, reply->parameter[lcnt].parm_name.description = cv.description,
      reply->parameter[lcnt].parm_name.cdf_meaning = cv.cdf_meaning, reply->parameter[lcnt].parm_name
      .collation_seq = cv.collation_seq, reply->parameter[lcnt].parm_value.code_value = cv2
      .code_value,
      reply->parameter[lcnt].parm_value.display = cv2.display, reply->parameter[lcnt].parm_value.
      description = cv2.description, reply->parameter[lcnt].parm_value.cdf_meaning = cv2.cdf_meaning,
      reply->parameter[lcnt].parm_value.collation_seq = cv2.collation_seq, reply->parameter[lcnt].
      parm_value_nbr = rp.parm_value_nbr, reply->parameter[lcnt].parm_value_txt = rp.parm_value_txt,
      reply->parameter[lcnt].parm_value_dt_tm = rp.parm_value_dt_tm, reply->parameter[lcnt].
      parm_value_type_flag = rp.parm_value_type_flag, reply->parameter[lcnt].beg_effective_dt_tm = rp
      .beg_effective_dt_tm
      IF (rp.end_effective_dt_tm >= cnvtdatetime("02-JAN-2100"))
       reply->parameter[lcnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      ELSE
       reply->parameter[lcnt].end_effective_dt_tm = rp.end_effective_dt_tm
      ENDIF
      reply->parameter[lcnt].active_ind = rp.active_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->parameter,lcnt)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
END GO
