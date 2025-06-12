CREATE PROGRAM bed_get_gpro_subgrp_prov
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 br_eligible_provider_id = f8
      2 provider_name = vc
      2 tin = vc
      2 npi = vc
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
 FREE RECORD gpro_all_providers
 RECORD gpro_all_providers(
   1 gpro_list[*]
     2 br_gpro_id = f8
     2 br_eligible_provider = f8
 )
 FREE RECORD gpro_mapped_providers
 RECORD gpro_mapped_providers(
   1 gpro_list[*]
     2 br_gpro_id = f8
     2 br_eligible_provider = f8
 )
 DECLARE br_gpro_id = f8 WITH public
 DECLARE numa = i4 WITH public
 DECLARE nump = i4 WITH public
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
 SELECT INTO "NL:"
  FROM br_gpro_reltn bgr,
   br_gpro_sub bgs
  PLAN (bgs
   WHERE (bgs.br_gpro_sub_id=request->gpro_sub_id)
    AND bgs.beg_effective_dt_tm <= cnvtdatetime(curdate,235959)
    AND bgs.end_effective_dt_tm >= cnvtdatetime(curdate,000000)
    AND bgs.active_ind=1)
   JOIN (bgr
   WHERE bgs.br_gpro_id=bgr.br_gpro_id
    AND bgr.beg_effective_dt_tm <= cnvtdatetime(curdate,235959)
    AND bgr.end_effective_dt_tm >= cnvtdatetime(curdate,000000)
    AND bgr.active_ind=1)
  ORDER BY bgr.parent_entity_id
  HEAD REPORT
   cnt = 0
  HEAD bgr.parent_entity_id
   cnt = (cnt+ 1), stat = alterlist(gpro_all_providers->gpro_list,cnt), gpro_all_providers->
   gpro_list[cnt].br_eligible_provider = bgr.parent_entity_id,
   gpro_all_providers->gpro_list[cnt].br_gpro_id = bgr.br_gpro_id, br_gpro_id = bgr.br_gpro_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR 001 : Error retrieving all providers")
 SELECT INTO "nl:"
  FROM br_gpro_sub bgs,
   br_gpro_sub_reltn bgsr
  PLAN (bgs
   WHERE bgs.br_gpro_id=br_gpro_id
    AND bgs.beg_effective_dt_tm <= cnvtdatetime(curdate,235959)
    AND bgs.end_effective_dt_tm >= cnvtdatetime(curdate,000000)
    AND bgs.active_ind=1)
   JOIN (bgsr
   WHERE bgsr.br_gpro_sub_id=bgs.br_gpro_sub_id
    AND bgsr.beg_effective_dt_tm <= cnvtdatetime(curdate,235959)
    AND bgsr.end_effective_dt_tm >= cnvtdatetime(curdate,000000)
    AND bgsr.active_ind=1)
  ORDER BY bgsr.br_eligible_provider_id
  HEAD REPORT
   cnt = 0
  HEAD bgsr.br_eligible_provider_id
   cnt = (cnt+ 1), stat = alterlist(gpro_mapped_providers->gpro_list,cnt), gpro_mapped_providers->
   gpro_list[cnt].br_eligible_provider = bgsr.br_eligible_provider_id,
   gpro_mapped_providers->gpro_list[cnt].br_gpro_id = bgs.br_gpro_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_eligible_provider b,
   prsnl p
  PLAN (b
   WHERE expand(numa,1,size(gpro_all_providers->gpro_list,5),b.br_eligible_provider_id,
    gpro_all_providers->gpro_list[numa].br_eligible_provider)
    AND  NOT (expand(nump,1,size(gpro_mapped_providers->gpro_list,5),b.br_eligible_provider_id,
    gpro_mapped_providers->gpro_list[nump].br_eligible_provider))
    AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=b.provider_id
    AND p.active_ind=1
    AND p.logical_domain_id=b.logical_domain_id)
  ORDER BY p.name_full_formatted, b.br_eligible_provider_id
  HEAD REPORT
   cnt = 0
  HEAD b.br_eligible_provider_id
   cnt = (cnt+ 1), stat = alterlist(reply->providers,cnt), reply->providers[cnt].active_ind = b
   .active_ind,
   reply->providers[cnt].npi = b.national_provider_nbr_txt, reply->providers[cnt].
   br_eligible_provider_id = b.br_eligible_provider_id, reply->providers[cnt].provider_name = p
   .name_full_formatted,
   reply->providers[cnt].tin = b.tax_id_nbr_txt
  WITH nocounter, expand = 1
 ;end select
 CALL bederrorcheck("ERROR 003 : Error sending REPLY")
#exit_script
 CALL bedexitscript(1)
END GO
