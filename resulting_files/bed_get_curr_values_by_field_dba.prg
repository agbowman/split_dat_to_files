CREATE PROGRAM bed_get_curr_values_by_field:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 current_values[*]
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
 DECLARE usageflagparser = vc WITH protect, noconstant("")
 DECLARE actiontypecdparser = vc WITH protect, noconstant("")
 DECLARE isyesnofield = i2 WITH protect, noconstant(0)
 DECLARE oefieldmeaningid = f8 WITH protect, noconstant(0)
 DECLARE isreasonforexamdcpfield = i2 WITH protect, noconstant(0)
 DECLARE validaterequest(dummyvar=i2) = i2
 DECLARE constructparsers(dummyvar=i2) = i2
 DECLARE getcurrentvalues(dummyvar=i2) = i2
 DECLARE getcurrentvaluesforreasonforexamdcpfield(dummyvar=i2) = i2
 CALL validaterequest(0)
 CALL constructparsers(0)
 CALL getcurrentvalues(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE validaterequest(dummyvar)
   IF ((((request->oe_format_id <= 0)) OR ((request->oe_field_id <= 0))) )
    CALL bederror("Invalid request. oe_format_id and oe_field_id must be > 0")
   ENDIF
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
     WHERE (oef.oe_field_id=request->oe_field_id)
      AND oef.field_type_flag IN (3, 5, 6, 7, 8,
     9, 10, 12, 13))
    DETAIL
     IF (oef.field_type_flag=7)
      isyesnofield = 1
     ENDIF
     IF (oef.field_type_flag=12
      AND oef.oe_field_meaning_id=oefieldmeaningid)
      isreasonforexamdcpfield = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL bedlogmessage("validateRequest()","The requested oe_field_id's flag is not supported. ")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE constructparsers(dummyvar)
   DECLARE usageflagssize = i4 WITH protect, noconstant(0)
   SET usageflagssize = size(request->usage_flags,5)
   IF (usageflagssize=1)
    IF ((request->usage_flags[1].usage_flag=1))
     SET usageflagparser = "os.usage_flag in (0,1)"
     SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
    ELSEIF ((request->usage_flags[1].usage_flag=2))
     SET usageflagparser = "os.usage_flag = 2"
     SET actiontypecdparser = "off.action_type_cd = CS6003_DISORDER_CD"
    ELSE
     SET usageflagparser = build("os.usage_flag = ",request->usage_flags[1].usage_flag)
    ENDIF
   ELSEIF (usageflagssize=2)
    SET usageflagparser = build("os.usage_flag in (0,",request->usage_flags[1].usage_flag,",",request
     ->usage_flags[2].usage_flag,")")
    SET actiontypecdparser = "off.action_type_cd in (CS6003_ORDER_CD, CS6003_DISORDER_CD)"
   ELSE
    SET usageflagparser = "os.usage_flag >= 0"
    SET actiontypecdparser = "off.action_type_cd = CS6003_ORDER_CD"
   ENDIF
 END ;Subroutine
 SUBROUTINE getcurrentvalues(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   IF (isyesnofield)
    CALL getcurrentvaluesforyesno(0)
    RETURN(0)
   ENDIF
   IF (isreasonforexamdcpfield)
    CALL getcurrentvaluesforreasonforexamdcpfield(0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM order_sentence os,
     order_sentence_detail osd
    PLAN (os
     WHERE (os.oe_format_id=request->oe_format_id)
      AND parser(usageflagparser))
     JOIN (osd
     WHERE osd.order_sentence_id=os.order_sentence_id
      AND (osd.oe_field_id=request->oe_field_id))
    ORDER BY osd.oe_field_display_value
    HEAD osd.oe_field_display_value
     cnt = (cnt+ 1), stat = alterlist(reply->current_values,cnt), reply->current_values[cnt].display
      = osd.oe_field_display_value
     IF (osd.field_type_flag IN (6, 8, 9, 10, 12,
     13))
      reply->current_values[cnt].id = osd.default_parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getcurrentvaluesforreasonforexamdcpfield(dummyvar)
  DECLARE cnt = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM order_sentence_detail osd,
    coded_exam_reason cer
   PLAN (osd
    WHERE (osd.oe_field_id=request->oe_field_id))
    JOIN (cer
    WHERE cer.exam_reason_id=osd.default_parent_entity_id
     AND cer.active_ind=1
     AND osd.default_parent_entity_name="CODE_VALUE")
   ORDER BY osd.oe_field_display_value
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->current_values,100)
   HEAD osd.oe_field_display_value
    cnt = (cnt+ 1)
    IF (cnt > 100
     AND mod(cnt,100)=1)
     stat = alterlist(reply->current_values,(cnt+ 99))
    ENDIF
    reply->current_values[cnt].display = osd.oe_field_display_value, reply->current_values[cnt].id =
    osd.default_parent_entity_id
   FOOT REPORT
    stat = alterlist(reply->current_values,cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getcurrentvaluesforyesno(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE vcnt = i4 WITH protect, noconstant(0)
   FREE RECORD yesnovalues
   RECORD yesnovalues(
     1 list[*]
       2 label_text = vc
       2 dept_line_label = vc
   )
   SELECT INTO "nl:"
    FROM oe_format_fields off
    PLAN (off
     WHERE (off.oe_format_id=request->oe_format_id)
      AND (off.oe_field_id=request->oe_field_id)
      AND parser(actiontypecdparser))
    DETAIL
     vcnt = (vcnt+ 1), stat = alterlist(yesnovalues->list,vcnt), yesnovalues->list[vcnt].label_text
      = off.label_text,
     yesnovalues->list[vcnt].dept_line_label = off.dept_line_label
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_sentence os,
     order_sentence_detail osd
    PLAN (os
     WHERE (os.oe_format_id=request->oe_format_id)
      AND parser(usageflagparser))
     JOIN (osd
     WHERE osd.order_sentence_id=os.order_sentence_id
      AND (osd.oe_field_id=request->oe_field_id))
    ORDER BY osd.oe_field_value
    HEAD osd.oe_field_value
     IF (osd.oe_field_value=1.0)
      FOR (i = 1 TO vcnt)
        cnt = (cnt+ 1), stat = alterlist(reply->current_values,cnt)
        IF (size(trim(yesnovalues->list[i].label_text,3),1) > 0)
         reply->current_values[cnt].display = trim(yesnovalues->list[i].label_text,3)
        ELSE
         reply->current_values[cnt].display = "Yes"
        ENDIF
        reply->current_values[cnt].id = osd.oe_field_value
      ENDFOR
     ELSEIF (osd.oe_field_value=0.0)
      FOR (i = 1 TO vcnt)
        cnt = (cnt+ 1), stat = alterlist(reply->current_values,cnt)
        IF (size(trim(yesnovalues->list[i].dept_line_label,3),1) > 0)
         reply->current_values[cnt].display = trim(yesnovalues->list[i].dept_line_label,3)
        ELSE
         reply->current_values[cnt].display = "No"
        ENDIF
        reply->current_values[cnt].id = osd.oe_field_value
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
