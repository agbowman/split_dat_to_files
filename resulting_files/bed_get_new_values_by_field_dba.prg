CREATE PROGRAM bed_get_new_values_by_field:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 values[*]
      2 id = f8
      2 display = vc
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
 IF ( NOT (validate(cs6003_order_cd)))
  DECLARE cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 ENDIF
 IF ( NOT (validate(cs6003_disorder_cd)))
  DECLARE cs6003_disorder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"DISORDER"))
 ENDIF
 DECLARE fieldtype = i4 WITH protect, noconstant(0)
 DECLARE oefieldmeaningid = f8 WITH protect, noconstant(0)
 DECLARE isreasonforexamdcpfield = i2 WITH protect, noconstant(0)
 DECLARE validaterequest(dummyvar=i2) = i2
 DECLARE getyesnovalues(dummyvar=i2) = i2
 DECLARE doesvalueexistinreply(val=vc) = i2
 DECLARE getnewvaluesforreasonforexamdcpfield(dummyvar=i2) = i2
 CALL validaterequest(0)
 SELECT INTO "nl:"
  FROM oe_field_meaning ofm
  WHERE ofm.oe_field_meaning="REASONFOREXAM"
  DETAIL
   oefieldmeaningid = ofm.oe_field_meaning_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  PLAN (oef
   WHERE (oef.oe_field_id=request->oe_field_id))
  DETAIL
   fieldtype = oef.field_type_flag
   IF (oef.oe_field_meaning_id=oefieldmeaningid)
    isreasonforexamdcpfield = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (fieldtype=7)
  CALL getyesnovalues(0)
 ENDIF
 IF (fieldtype=12
  AND isreasonforexamdcpfield)
  CALL getnewvaluesforreasonforexamdcpfield(0)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE validaterequest(dummyvar)
   IF ((((request->oe_format_id <= 0)) OR ((request->oe_field_id <= 0))) )
    CALL bederror("Invalid request. oe_format_id and oe_field_id must be > 0")
   ENDIF
 END ;Subroutine
 SUBROUTINE getyesnovalues(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE usageflagssize = i4 WITH protect, noconstant(size(request->usage_flags,5))
   DECLARE actiontypecdparser = vc WITH protect, noconstant("")
   IF (usageflagssize=1)
    IF ((request->usage_flags[1].usage_flag=1))
     SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
    ELSEIF ((request->usage_flags[1].usage_flag=2))
     SET actiontypecdparser = "off.action_type_cd = CS6003_DISORDER_CD"
    ENDIF
   ELSEIF (usageflagssize=2)
    SET actiontypecdparser = "off.action_type_cd in (CS6003_ORDER_CD, CS6003_DISORDER_CD)"
   ELSE
    SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
   ENDIF
   SELECT INTO "nl:"
    FROM oe_format_fields off
    PLAN (off
     WHERE (off.oe_format_id=request->oe_format_id)
      AND (off.oe_field_id=request->oe_field_id)
      AND parser(actiontypecdparser))
    DETAIL
     IF (size(trim(off.label_text,3),1) > 0)
      IF ( NOT (doesvalueexistinreply(trim(off.label_text,3))))
       cnt = (cnt+ 1), stat = alterlist(reply->values,cnt), reply->values[cnt].display = trim(off
        .label_text,3),
       reply->values[cnt].id = 1.0
      ENDIF
     ELSE
      IF ( NOT (doesvalueexistinreply("Yes")))
       cnt = (cnt+ 1), stat = alterlist(reply->values,cnt), reply->values[cnt].display = "Yes",
       reply->values[cnt].id = 1.0
      ENDIF
     ENDIF
     IF (size(trim(off.dept_line_label,3),1) > 0)
      IF ( NOT (doesvalueexistinreply(trim(off.dept_line_label,3))))
       cnt = (cnt+ 1), stat = alterlist(reply->values,cnt), reply->values[cnt].display = trim(off
        .dept_line_label,3),
       reply->values[cnt].id = 0.0
      ENDIF
     ELSE
      IF ( NOT (doesvalueexistinreply("No")))
       cnt = (cnt+ 1), stat = alterlist(reply->values,cnt), reply->values[cnt].display = "No",
       reply->values[cnt].id = 0.0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnewvaluesforreasonforexamdcpfield(dummyvar)
  DECLARE cnt = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM coded_exam_reason cer
   WHERE cer.active_ind=1
   ORDER BY cer.description
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->values,100)
   HEAD cer.description
    cnt = (cnt+ 1)
    IF (cnt > 100
     AND mod(cnt,100)=1)
     stat = alterlist(reply->values,(cnt+ 99))
    ENDIF
    reply->values[cnt].display = cer.description, reply->values[cnt].id = cer.exam_reason_id
   FOOT REPORT
    stat = alterlist(reply->values,cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE doesvalueexistinreply(val)
   SET num = 0
   SET pos = locateval(num,1,size(reply->values,5),val,reply->values[num].display)
   IF (pos > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
END GO
