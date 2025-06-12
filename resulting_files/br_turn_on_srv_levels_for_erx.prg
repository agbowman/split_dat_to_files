CREATE PROGRAM br_turn_on_srv_levels_for_erx
 PROMPT
  "Do you want to turn on EPA service Level?(y/n):" = " ",
  "Do you want to turn on MUSE3 service Level?(y/n):" = " ",
  "Do you want to turn on LTC service Level?(y/n):" = " "
  WITH promptresponse
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
 IF ( NOT (validate(servicelevelslist,0)))
  RECORD servicelevelslist(
    1 servicelevelslist[*]
      2 service_level = vc
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
 DECLARE eprescribingservices = vc WITH protect, constant("EPRESCRIBINGSERVICES")
 DECLARE epa = vc WITH protect, constant("EPA")
 DECLARE muse3 = vc WITH protect, constant("MUSE3")
 DECLARE ltc = vc WITH protect, constant("LTC")
 DECLARE servicelevelsize = i4 WITH protect, constant(3)
 DECLARE needtoupdate = i2 WITH protect, noconstant(0)
 DECLARE needtoinsert = i2 WITH protect, noconstant(0)
 DECLARE brnamevalueid = f8 WITH protect, noconstant(0)
 DECLARE checkservicelevelneedstoturnon(servicelevel=vc) = i2
 DECLARE updateservicelevelconfiguration(servicelevel=vc) = null
 SET stat = initrec(servicelevelslist)
 SET stat = alterlist(servicelevelslist->servicelevelslist,servicelevelsize)
 SET servicelevelslist->servicelevelslist[1].service_level = epa
 SET servicelevelslist->servicelevelslist[2].service_level = muse3
 SET servicelevelslist->servicelevelslist[3].service_level = ltc
 FOR (servicelevel = 1 TO size(servicelevelslist->servicelevelslist,5))
   IF (checkservicelevelneedstoturnon(servicelevelslist->servicelevelslist[servicelevel].
    service_level))
    IF ((((servicelevelslist->servicelevelslist[servicelevel].service_level=epa)
     AND cnvtupper( $1)="Y") OR ((((servicelevelslist->servicelevelslist[servicelevel].service_level=
    muse3)
     AND cnvtupper( $2)="Y") OR ((servicelevelslist->servicelevelslist[servicelevel].service_level=
    ltc)
     AND cnvtupper( $3)="Y")) )) )
     CALL updateservicelevelconfiguration(servicelevelslist->servicelevelslist[servicelevel].
      service_level)
    ELSE
     CALL echo("***********************************************************")
     CALL echo(concat(servicelevelslist->servicelevelslist[servicelevel].service_level,
       " is in OFF status"))
     CALL echo("***********************************************************")
    ENDIF
   ELSE
    CALL echo("***********************************************************")
    CALL echo(concat(servicelevelslist->servicelevelslist[servicelevel].service_level,
      " is already turned ON"))
    CALL echo("***********************************************************")
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE checkservicelevelneedstoturnon(servicelevel)
   SET brnamevalueid = 0.0
   SET needtoupdate = 0
   SET needtoinsert = 0
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=eprescribingservices
      AND bnv.br_name=servicelevel)
    DETAIL
     brnamevalueid = bnv.br_name_value_id
     IF (bnv.br_value != "1"
      AND brnamevalueid > 0)
      needtoupdate = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (brnamevalueid=0)
    SET needtoinsert = 1
   ENDIF
   IF (((needtoupdate=1) OR (needtoinsert=1)) )
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE updateservicelevelconfiguration(servicelevel)
   IF (needtoupdate=1)
    UPDATE  FROM br_name_value bnv
     SET br_value = "1"
     WHERE br_name_value_id=brnamevalueid
     WITH nocounter
    ;end update
    CALL echo("***********************************************************")
    CALL echo(concat(servicelevel," is Turned ON Now"))
    CALL echo("***********************************************************")
   ELSEIF (needtoinsert=1)
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = eprescribingservices, bnv
      .br_name = servicelevel,
      bnv.br_value = "1", bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("Insering into BR_NAME_VALUE failed.")
    ELSE
     CALL echo("***********************************************************")
     CALL echo(concat(servicelevel," is Turned ON Now"))
     CALL echo("***********************************************************")
    ENDIF
   ENDIF
 END ;Subroutine
END GO
