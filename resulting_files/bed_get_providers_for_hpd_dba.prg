CREATE PROGRAM bed_get_providers_for_hpd:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 personid = f8
      2 firstname = vc
      2 lastname = vc
      2 namefullformatted = vc
      2 directemail = vc
      2 activeind = i2
    1 toomanyind = i2
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
 IF ( NOT (validate(cs43_intsecemail_cd)))
  DECLARE cs43_intsecemail_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"INTSECEMAIL")
   )
 ENDIF
 DECLARE logicaldomainid = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE poscnt = i4 WITH protect, constant(size(request->positions,5))
 DECLARE orgcnt = i4 WITH protect, constant(size(request->organizations,5))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(1)
 DECLARE num1 = i4 WITH protect, noconstant(1)
 DECLARE prsnlqualifiers = vc WITH protect, noconstant("")
 DECLARE defaultmaxreply = i4 WITH protect, noconstant(2000)
 DECLARE activecnt = i4 WITH protect, noconstant(0)
 DECLARE createqualifiersforprsnltable(dummyvar=i2) = i2
 DECLARE executequerywithnoorgfiltering(dummyvar=i2) = i2
 DECLARE executequerywithorgfiltering(dummyvar=i2) = i2
 CALL createqualifiersforprsnltable(0)
 IF (orgcnt > 0)
  CALL executequerywithorgfiltering(0)
 ELSE
  CALL executequerywithnoorgfiltering(0)
 ENDIF
 IF ((request->maxreply > 0))
  SET defaultmaxreply = request->maxreply
 ENDIF
 IF (activecnt > defaultmaxreply)
  SET stat = initrec(reply)
  SET reply->toomanyind = true
 ELSEIF (defaultmaxreply < size(reply->providers,5))
  SET stat = initrec(reply)
  SET reply->toomanyind = true
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE createqualifiersforprsnltable(dummyvar)
   IF (poscnt > 0)
    SET prsnlqualifiers = "expand(num, 1, posCnt, p.position_cd, request->positions[num].positionCd)"
    SET prsnlqualifiers = concat(prsnlqualifiers," and p.logical_domain_id = logicalDomainId")
   ELSE
    SET prsnlqualifiers = " p.logical_domain_id = logicalDomainId "
   ENDIF
   IF (trim(request->lastname) > " ")
    SET prsnlqualifiers = concat(prsnlqualifiers," and p.name_last_key = '",nullterm(cnvtalphanum(
       cnvtupper(trim(request->lastname)))),"*'")
   ENDIF
   IF (trim(request->firstname) > " ")
    SET prsnlqualifiers = concat(prsnlqualifiers," and p.name_first_key = '",nullterm(cnvtalphanum(
       cnvtupper(trim(request->firstname)))),"*'")
   ENDIF
   IF (validate(debug,0)=1)
    CALL echo(prsnlqualifiers)
   ENDIF
 END ;Subroutine
 SUBROUTINE executequerywithorgfiltering(dummyvar)
   SELECT INTO "nl:"
    FROM prsnl p,
     phone ph,
     prsnl_org_reltn por
    PLAN (p
     WHERE parser(prsnlqualifiers))
     JOIN (ph
     WHERE ph.parent_entity_id=p.person_id
      AND ph.parent_entity_name="PERSON"
      AND ph.phone_type_cd=cs43_intsecemail_cd)
     JOIN (por
     WHERE expand(num1,1,orgcnt,por.organization_id,request->organizations[num1].orgid)
      AND por.person_id=p.person_id
      AND por.active_ind=true)
    ORDER BY p.person_id, ph.active_ind
    HEAD p.person_id
     cnt = (cnt+ 1), stat = alterlist(reply->providers,cnt), reply->providers[cnt].personid = p
     .person_id,
     reply->providers[cnt].directemail = ph.phone_num, reply->providers[cnt].firstname = p.name_first,
     reply->providers[cnt].lastname = p.name_last,
     reply->providers[cnt].namefullformatted = p.name_full_formatted
    HEAD ph.phone_id
     IF (ph.active_ind=1
      AND p.active_ind=1)
      reply->providers[cnt].activeind = 1, activecnt = (activecnt+ 1)
     ENDIF
     IF (((ph.active_ind=0) OR (p.active_ind=0))
      AND (reply->providers[cnt].activeind != 1))
      reply->providers[cnt].activeind = 0
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE executequerywithnoorgfiltering(dummyvar)
   SELECT INTO "nl:"
    FROM prsnl p,
     phone ph
    PLAN (p
     WHERE parser(prsnlqualifiers))
     JOIN (ph
     WHERE ph.parent_entity_id=p.person_id
      AND ph.parent_entity_name="PERSON"
      AND ph.phone_type_cd=cs43_intsecemail_cd)
    ORDER BY p.person_id, ph.phone_id
    HEAD p.person_id
     cnt = (cnt+ 1), stat = alterlist(reply->providers,cnt), reply->providers[cnt].personid = p
     .person_id,
     reply->providers[cnt].directemail = ph.phone_num, reply->providers[cnt].firstname = p.name_first,
     reply->providers[cnt].lastname = p.name_last,
     reply->providers[cnt].namefullformatted = p.name_full_formatted
    HEAD ph.phone_id
     IF (ph.active_ind=1
      AND p.active_ind=1)
      reply->providers[cnt].activeind = 1, activecnt = (activecnt+ 1)
     ENDIF
     IF (((ph.active_ind=0) OR (p.active_ind=0))
      AND (reply->providers[cnt].activeind != 1))
      reply->providers[cnt].activeind = 0
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
