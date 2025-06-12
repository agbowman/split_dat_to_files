CREATE PROGRAM bed_get_oe_filter_formats:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 field_id = f8
    1 synonym_item_ind = i2
    1 orderables[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 formats[*]
      2 id = f8
      2 name = c100
      2 catalog_type
        3 code_value = f8
        3 display = c40
        3 description = c60
        3 mean = c12
      2 actions[*]
        3 action_type
          4 code_value = f8
          4 display = c40
          4 mean = c12
        3 filter_flag = i2
        3 filter_type = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp1(
   1 formats[*]
     2 id = f8
     2 name = c100
     2 catalog_type
       3 code_value = f8
       3 display = c40
       3 description = c60
       3 mean = c12
     2 actions[*]
       3 action_type
         4 code_value = f8
         4 display = c40
         4 mean = c12
       3 filter_flag = i2
       3 filter_type = vc
 )
 RECORD temp2(
   1 formats[*]
     2 id = f8
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
 SET reply->status_data.status = "F"
 DECLARE translatefiltertypes(filtertype=vc) = vc
 DECLARE filter_params = vc WITH protect, noconstant("")
 SET ocnt = 0
 SET ocnt = size(request->orderables,5)
 SET temp2_cnt = 0
 IF (ocnt > 0)
  IF ((request->synonym_item_ind=1))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog_synonym ocs
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.synonym_id=request->orderables[d.seq].code_value))
    DETAIL
     temp2_cnt = (temp2_cnt+ 1), stat = alterlist(temp2->formats,temp2_cnt), temp2->formats[temp2_cnt
     ].id = ocs.oe_format_id
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog_synonym ocs
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.catalog_cd=request->orderables[d.seq].code_value))
    DETAIL
     temp2_cnt = (temp2_cnt+ 1), stat = alterlist(temp2->formats,temp2_cnt), temp2->formats[temp2_cnt
     ].id = ocs.oe_format_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(temp1->formats,100)
 SET alterlist_fcnt = 0
 SET fcnt = 0
 SELECT INTO "NL:"
  FROM oe_format_fields off,
   order_entry_format oef,
   code_value cv1,
   code_value cv2
  PLAN (off
   WHERE (off.oe_field_id=request->field_id)
    AND off.oe_format_id > 0)
   JOIN (oef
   WHERE oef.oe_format_id=off.oe_format_id
    AND oef.action_type_cd=off.action_type_cd)
   JOIN (cv1
   WHERE cv1.code_value=oef.catalog_type_cd
    AND cv1.code_value > 0
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oef.action_type_cd
    AND cv2.code_value > 0
    AND cv2.active_ind=1)
  ORDER BY off.oe_format_id
  HEAD off.oe_format_id
   alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 100)
    stat = alterlist(temp1->formats,(fcnt+ 100)), alterlist_fcnt = 1
   ENDIF
   fcnt = (fcnt+ 1), temp1->formats[fcnt].id = off.oe_format_id, temp1->formats[fcnt].name = oef
   .oe_format_name,
   temp1->formats[fcnt].catalog_type.code_value = oef.catalog_type_cd, temp1->formats[fcnt].
   catalog_type.display = cv1.display, temp1->formats[fcnt].catalog_type.description = cv1
   .description,
   temp1->formats[fcnt].catalog_type.mean = cv1.cdf_meaning, stat = alterlist(temp1->formats[fcnt].
    actions,10), alterlist_acnt = 0,
   acnt = 0
  DETAIL
   alterlist_acnt = (alterlist_acnt+ 1)
   IF (alterlist_acnt > 10)
    stat = alterlist(temp1->formats,(acnt+ 10)), alterlist_acnt = 1
   ENDIF
   acnt = (acnt+ 1), temp1->formats[fcnt].actions[acnt].action_type.code_value = cv2.code_value,
   temp1->formats[fcnt].actions[acnt].action_type.display = cv2.display,
   temp1->formats[fcnt].actions[acnt].action_type.mean = cv2.cdf_meaning, temp1->formats[fcnt].
   actions[acnt].filter_type = off.filter_params
  FOOT  off.oe_format_id
   stat = alterlist(temp1->formats[fcnt].actions,acnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(temp1->formats,fcnt)
 IF (ocnt=0)
  SET stat = alterlist(reply->formats,fcnt)
  FOR (f = 1 TO fcnt)
    SET reply->formats[f].id = temp1->formats[f].id
    SET reply->formats[f].name = temp1->formats[f].name
    SET reply->formats[f].catalog_type.code_value = temp1->formats[f].catalog_type.code_value
    SET reply->formats[f].catalog_type.display = temp1->formats[f].catalog_type.display
    SET reply->formats[f].catalog_type.description = temp1->formats[f].catalog_type.description
    SET reply->formats[f].catalog_type.mean = temp1->formats[f].catalog_type.mean
    SET acnt = 0
    SET acnt = size(temp1->formats[f].actions,5)
    SET stat = alterlist(reply->formats[f].actions,acnt)
    FOR (a = 1 TO acnt)
      SET reply->formats[f].actions[a].action_type.code_value = temp1->formats[f].actions[a].
      action_type.code_value
      SET reply->formats[f].actions[a].action_type.display = temp1->formats[f].actions[a].action_type
      .display
      SET reply->formats[f].actions[a].action_type.mean = temp1->formats[f].actions[a].action_type.
      mean
      SET reply->formats[f].actions[a].filter_type = translatefiltertypes(temp1->formats[f].actions[a
       ].filter_type)
    ENDFOR
  ENDFOR
 ELSE
  SET rcnt = 0
  FOR (f = 1 TO fcnt)
   SET matchind = 0
   FOR (o = 1 TO temp2_cnt)
     IF (matchind=0
      AND (temp2->formats[o].id=temp1->formats[f].id))
      SET matchind = 1
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(reply->formats,rcnt)
      SET reply->formats[rcnt].id = temp1->formats[f].id
      SET reply->formats[rcnt].name = temp1->formats[f].name
      SET reply->formats[rcnt].catalog_type.code_value = temp1->formats[f].catalog_type.code_value
      SET reply->formats[rcnt].catalog_type.display = temp1->formats[f].catalog_type.display
      SET reply->formats[rcnt].catalog_type.description = temp1->formats[f].catalog_type.description
      SET reply->formats[rcnt].catalog_type.mean = temp1->formats[f].catalog_type.mean
      SET acnt = 0
      SET acnt = size(temp1->formats[f].actions,5)
      SET stat = alterlist(reply->formats[rcnt].actions,acnt)
      FOR (a = 1 TO acnt)
        SET reply->formats[rcnt].actions[a].action_type.code_value = temp1->formats[f].actions[a].
        action_type.code_value
        SET reply->formats[rcnt].actions[a].action_type.display = temp1->formats[f].actions[a].
        action_type.display
        SET reply->formats[rcnt].actions[a].action_type.mean = temp1->formats[f].actions[a].
        action_type.mean
        SET reply->formats[rcnt].actions[a].filter_type = translatefiltertypes(temp1->formats[f].
         actions[a].filter_type)
      ENDFOR
     ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE translatefiltertypes(filtertype)
   CALL bedlogmessage("translateFilterTypes","Entering ...")
   IF (validate(filtertype))
    SET filter_params = filtertype
    SET filter_params = replace(filter_params,"CATALOG TYPE","1")
    SET filter_params = replace(filter_params,"ACTIVITY TYPE","2")
    SET filter_params = replace(filter_params,"ORDERABLE","3")
    SET filter_params = replace(filter_params,"SYNONYM","4")
   ENDIF
   CALL bedlogmessage("translateFilterTypes","Exiting ...")
   RETURN(filter_params)
 END ;Subroutine
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
