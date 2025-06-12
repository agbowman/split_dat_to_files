CREATE PROGRAM bed_get_event_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_codes[*]
      2 event_cd = f8
      2 event_cd_desc = c60
      2 event_cd_disp = c40
      2 event_set_name = c40
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = null
 DECLARE populateeventcodesforcenumeric(dummyvar=i2) = null
 DECLARE populateeventcodesfordtanumeric(dummyvar=i2) = null
 DECLARE numeric_result_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE calculation_result_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"8"))
 DECLARE max_reply = i4 WITH protect, constant(1000)
 DECLARE search_parser = vc WITH protect
 DECLARE count = i4 WITH protect, noconstant(0)
 IF (validate(request->search_text,"") > " ")
  CALL populateparsestringbasedonrequest(0)
 ENDIF
 CALL echo(search_parser)
 IF ((request->search_type_flag=1))
  CALL populateeventcodesforcenumeric(0)
 ELSEIF ((request->search_type_flag=2))
  CALL populateeventcodesfordtanumeric(0)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
  SET request->search_text = cnvtupper(request->search_text)
  IF ((request->search_type_flag=1))
   SET search_parser = build(search_parser,"cv.code_value > 0.0")
   IF ((request->search_type_text IN ("S", "s")))
    SET search_parser = concat(search_parser," and cv.display_key = patstring('",request->search_text,
     "*')")
   ELSEIF ((request->search_type_text IN ("C", "c")))
    SET search_parser = concat(search_parser," and cv.display_key = patstring('*",request->
     search_text,"*')")
   ENDIF
  ELSEIF ((request->search_type_flag=2))
   SET search_parser = build(search_parser,"dta.active_ind = 1")
   IF ((request->search_type_text IN ("S", "s")))
    SET search_parser = concat(search_parser," and dta.mnemonic_key_cap = patstring('",request->
     search_text,"*')")
   ELSEIF ((request->search_type_text IN ("C", "c")))
    SET search_parser = concat(search_parser," and dta.mnemonic_key_cap = patstring('*",request->
     search_text,"*')")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE populateeventcodesforcenumeric(dummyvar)
   SELECT INTO "NL:"
    is_null = nullind(dta.default_result_type_cd)
    FROM code_value cv,
     (left JOIN discrete_task_assay dta ON dta.event_cd=cv.code_value
      AND dta.default_result_type_cd IN (numeric_result_type_cd, calculation_result_type_cd)),
     (left JOIN code_value_event_r cver ON cver.event_cd=cv.code_value
      AND cver.flex1_cd=0.0),
     (left JOIN code_value cv2 ON cv2.code_value=dta.task_assay_cd),
     (left JOIN code_value cv3 ON cv3.code_value=cver.parent_cd
      AND cv3.code_set=14003),
     (left JOIN discrete_task_assay dta2 ON dta2.task_assay_cd=cv3.code_value),
     v500_event_code vec
    PLAN (cv
     WHERE parser(search_parser)
      AND cv.code_set=72
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (vec
     WHERE vec.event_cd=cv.code_value)
     JOIN (dta)
     JOIN (cver)
     JOIN (cv2)
     JOIN (cv3)
     JOIN (dta2)
    ORDER BY cv.code_value
    HEAD REPORT
     count = 0
    HEAD cv.code_value
     IF (is_null=0)
      count = (count+ 1), stat = alterlist(reply->event_codes,count), reply->event_codes[count].
      event_cd = cv.code_value,
      reply->event_codes[count].event_cd_disp = cv.display, reply->event_codes[count].event_cd_desc
       = cv.description, reply->event_codes[count].event_set_name = vec.event_set_name
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error:1 - Failed to retrieve Event Codes")
   IF (count > max_reply)
    SET stat = initrec(reply)
    SET reply->too_many_results_ind = 1
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE populateeventcodesfordtanumeric(dummyvar)
   SELECT INTO "NL:"
    FROM discrete_task_assay dta,
     br_assay ba,
     code_value cv106,
     code_value cv289,
     code_value cv1636,
     code_value cv14286,
     code_value cv
    PLAN (dta
     WHERE parser(search_parser)
      AND dta.default_result_type_cd IN (numeric_result_type_cd, calculation_result_type_cd))
     JOIN (cv106
     WHERE cv106.code_set=106
      AND cv106.active_ind=1
      AND cv106.code_value=dta.activity_type_cd)
     JOIN (cv289
     WHERE cv289.code_set=outerjoin(289)
      AND cv289.active_ind=outerjoin(1)
      AND cv289.code_value=outerjoin(dta.default_result_type_cd))
     JOIN (cv1636
     WHERE cv1636.code_set=outerjoin(1636)
      AND cv1636.active_ind=outerjoin(1)
      AND cv1636.code_value=outerjoin(dta.bb_result_processing_cd))
     JOIN (cv14286
     WHERE cv14286.code_set=outerjoin(14286)
      AND cv14286.active_ind=outerjoin(1)
      AND cv14286.code_value=outerjoin(dta.rad_section_type_cd))
     JOIN (cv
     WHERE cv.code_value=dta.event_cd)
     JOIN (ba
     WHERE ba.task_assay_cd=outerjoin(dta.task_assay_cd))
    ORDER BY dta.task_assay_cd
    HEAD REPORT
     count = 0
    HEAD dta.task_assay_cd
     count = (count+ 1), stat = alterlist(reply->event_codes,count), reply->event_codes[count].
     event_cd = dta.task_assay_cd,
     reply->event_codes[count].event_cd_disp = dta.mnemonic, reply->event_codes[count].event_cd_desc
      = dta.description
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error:2 - Failed to retrieve Assays")
   IF (count > max_reply)
    SET stat = initrec(reply)
    SET reply->too_many_results_ind = 1
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(reply)
   ENDIF
 END ;Subroutine
END GO
