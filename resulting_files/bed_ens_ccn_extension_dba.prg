CREATE PROGRAM bed_ens_ccn_extension:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD copyextension
 RECORD copyextension(
   1 br_ccn_extension_id = f8
   1 orig_br_ccn_extension_id = f8
   1 br_ccn_id = f8
   1 program_type_txt = vc
   1 medicaid_stage_cd = f8
   1 medicare_year = i4
   1 beg_effective_dt_tm = dq8
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
 DECLARE extensionexists(ccnid=f8) = i2
 DECLARE modifyextension(ccnindex=i4) = i2
 DECLARE insertextension(ccnindex=i4) = i2
 DECLARE createnewid(dummyvar=i2) = f8
 FOR (x = 1 TO size(request->ccns,5))
   IF (extensionexists(request->ccns[x].ccn_id))
    CALL modifyextension(x)
   ELSE
    CALL insertextension(x)
   ENDIF
 ENDFOR
 SUBROUTINE extensionexists(ccnid)
   CALL bedlogmessage("extensionExists","Entering...")
   SELECT INTO "nl:"
    FROM br_ccn_extension bce
    WHERE bce.br_ccn_id=ccnid
     AND bce.active_ind=1
     AND bce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echo(build("Rows found:",curqual))
   ENDIF
   IF (curqual > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL bedlogmessage("extensionExists","Exiting...")
 END ;Subroutine
 SUBROUTINE createnewid(dummyvar)
   CALL bedlogmessage("createNewId","Entering...")
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     new_id = cnvtreal(z)
    WITH nocounter
   ;end select
   IF (validate(debug,0)=1)
    CALL echo(build("New ID:",new_id))
   ENDIF
   CALL bederrorcheck("NewIdErr")
   CALL bedlogmessage("createNewId","Exiting...")
   RETURN(new_id)
 END ;Subroutine
 SUBROUTINE modifyextension(ccnindex)
   CALL bedlogmessage("modifyExtension","Entering...")
   SELECT INTO "nl:"
    FROM br_ccn_extension bce
    WHERE (bce.br_ccn_id=request->ccns[ccnindex].ccn_id)
     AND bce.active_ind=1
     AND bce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     copyextension->br_ccn_extension_id = bce.br_ccn_extension_id, copyextension->
     orig_br_ccn_extension_id = bce.orig_br_ccn_extension_id, copyextension->br_ccn_id = bce
     .br_ccn_id,
     copyextension->program_type_txt = bce.program_type_txt, copyextension->medicaid_stage_cd = bce
     .medicaid_stage_cd, copyextension->medicare_year = bce.medicare_year,
     copyextension->beg_effective_dt_tm = bce.beg_effective_dt_tm
    WITH nocounter
   ;end select
   CALL bederrorcheck("GetRowErr1")
   IF (validate(debug,0)=1)
    CALL echorecord(copyextension)
   ENDIF
   DECLARE modifynewid = f8 WITH protect, noconstant(0.0)
   SET modifynewid = createnewid(0)
   INSERT  FROM br_ccn_extension bce
    SET bce.br_ccn_extension_id = modifynewid, bce.orig_br_ccn_extension_id = copyextension->
     orig_br_ccn_extension_id, bce.br_ccn_id = copyextension->br_ccn_id,
     bce.program_type_txt = copyextension->program_type_txt, bce.medicaid_stage_cd = copyextension->
     medicaid_stage_cd, bce.medicare_year = copyextension->medicare_year,
     bce.beg_effective_dt_tm = cnvtdatetime(copyextension->beg_effective_dt_tm), bce
     .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bce.active_ind = 1,
     bce.updt_dt_tm = cnvtdatetime(curdate,curtime3), bce.updt_id = reqinfo->updt_id, bce.updt_task
      = reqinfo->updt_task,
     bce.updt_applctx = reqinfo->updt_applctx, bce.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("InsErr1")
   UPDATE  FROM br_ccn_extension bce
    SET bce.program_type_txt = request->ccns[ccnindex].program_type, bce.medicaid_stage_cd = request
     ->ccns[ccnindex].medicaid, bce.medicare_year = request->ccns[ccnindex].medicare,
     bce.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bce.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), bce.updt_id = reqinfo->updt_id,
     bce.updt_task = reqinfo->updt_task, bce.updt_applctx = reqinfo->updt_applctx, bce.updt_cnt = (
     bce.updt_cnt+ 1)
    WHERE (bce.br_ccn_extension_id=copyextension->br_ccn_extension_id)
   ;end update
   CALL bederrorcheck("UpdErr1")
   CALL bedlogmessage("modifyExtension","Exiting...")
 END ;Subroutine
 SUBROUTINE insertextension(ccnindex)
   CALL bedlogmessage("insertExtension","Entering...")
   DECLARE insertnewid = f8 WITH protect, noconstant(0.0)
   SET insertnewid = createnewid(0)
   INSERT  FROM br_ccn_extension bce
    SET bce.br_ccn_extension_id = insertnewid, bce.orig_br_ccn_extension_id = insertnewid, bce
     .br_ccn_id = request->ccns[ccnindex].ccn_id,
     bce.program_type_txt = request->ccns[ccnindex].program_type, bce.medicaid_stage_cd = request->
     ccns[ccnindex].medicaid, bce.medicare_year = request->ccns[ccnindex].medicare,
     bce.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bce.end_effective_dt_tm = cnvtdatetime
     ("31-DEC-2100"), bce.active_ind = 1,
     bce.updt_dt_tm = cnvtdatetime(curdate,curtime3), bce.updt_id = reqinfo->updt_id, bce.updt_task
      = reqinfo->updt_task,
     bce.updt_applctx = reqinfo->updt_applctx, bce.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("InsErr2")
   CALL bedlogmessage("insertExtension","Exiting...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
