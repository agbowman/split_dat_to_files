CREATE PROGRAM bed_get_code_value_group:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 parent_code_set = i4
      2 child_code_set = i4
      2 code_value_group[*]
        3 parent_code_value
          4 code_value = f8
          4 display = vc
          4 description = vc
          4 cdf_meaning = vc
          4 collation_seq = i4
        3 child_code_value[*]
          4 code_value = f8
          4 display = vc
          4 description = vc
          4 cdf_meaning = vc
          4 collation_seq = i4
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
 DECLARE qual_cnt = i4 WITH protect, constant(size(request->qual,5))
 DECLARE qualidx = i4 WITH protect, noconstant(0)
 DECLARE getcodevaluegroups(dummy=i2) = i2
 IF (qual_cnt > 0)
  SET stat = alterlist(reply->qual,qual_cnt)
  FOR (qualidx = 1 TO qual_cnt)
   SET reply->qual[qualidx].parent_code_set = request->qual[qualidx].parent_code_set
   SET reply->qual[qualidx].child_code_set = request->qual[qualidx].child_code_set
  ENDFOR
  IF ( NOT (getcodevaluegroups(0)))
   CALL bederror("Could not return list of code value groups.")
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getcodevaluegroups(dummy)
   DECLARE cvgcnt = i4 WITH protect, noconstant(0)
   DECLARE childcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(qual_cnt)),
     code_value cvp,
     code_value_group cvg,
     code_value cvc
    PLAN (d
     WHERE (reply->qual[d.seq].parent_code_set > 0)
      AND (reply->qual[d.seq].child_code_set > 0))
     JOIN (cvp
     WHERE (cvp.code_set=reply->qual[d.seq].parent_code_set)
      AND cvp.active_ind=1
      AND cvp.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cvp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (cvg
     WHERE cvg.parent_code_value=cvp.code_value
      AND (cvg.code_set=reply->qual[d.seq].child_code_set))
     JOIN (cvc
     WHERE cvc.code_value=cvg.child_code_value
      AND (cvc.code_set=reply->qual[d.seq].child_code_set)
      AND cvc.active_ind=1
      AND cvc.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cvc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY d.seq, cvp.display_key, cvp.code_value,
     cvc.display_key, cvc.code_value
    HEAD REPORT
     cvgcnt = 0, childcnt = 0
    HEAD d.seq
     cvgcnt = 0, childcnt = 0
    HEAD cvp.code_value
     childcnt = 0
     IF (cvp.code_value > 0.0)
      cvgcnt = (cvgcnt+ 1)
      IF (cvgcnt > size(reply->qual[d.seq].code_value_group,5))
       stat = alterlist(reply->qual[d.seq].code_value_group,(cvgcnt+ 9))
      ENDIF
      reply->qual[d.seq].code_value_group[cvgcnt].parent_code_value.code_value = cvp.code_value,
      reply->qual[d.seq].code_value_group[cvgcnt].parent_code_value.display = cvp.display, reply->
      qual[d.seq].code_value_group[cvgcnt].parent_code_value.description = cvp.description,
      reply->qual[d.seq].code_value_group[cvgcnt].parent_code_value.cdf_meaning = cvp.cdf_meaning,
      reply->qual[d.seq].code_value_group[cvgcnt].parent_code_value.collation_seq = cvp.collation_seq
     ENDIF
    HEAD cvc.code_value
     IF (cvp.code_value > 0.0
      AND cvc.code_value > 0.0)
      childcnt = (childcnt+ 1)
      IF (childcnt > size(reply->qual[d.seq].code_value_group[cvgcnt].child_code_value,5))
       stat = alterlist(reply->qual[d.seq].code_value_group[cvgcnt].child_code_value,(childcnt+ 9))
      ENDIF
      reply->qual[d.seq].code_value_group[cvgcnt].child_code_value[childcnt].code_value = cvc
      .code_value, reply->qual[d.seq].code_value_group[cvgcnt].child_code_value[childcnt].display =
      cvc.display, reply->qual[d.seq].code_value_group[cvgcnt].child_code_value[childcnt].description
       = cvc.description,
      reply->qual[d.seq].code_value_group[cvgcnt].child_code_value[childcnt].cdf_meaning = cvc
      .cdf_meaning, reply->qual[d.seq].code_value_group[cvgcnt].child_code_value[childcnt].
      collation_seq = cvc.collation_seq
     ENDIF
    FOOT  cvp.code_value
     stat = alterlist(reply->qual[d.seq].code_value_group[cvgcnt].child_code_value,childcnt)
    FOOT  d.seq
     stat = alterlist(reply->qual[d.seq].code_value_group,cvgcnt)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
END GO
