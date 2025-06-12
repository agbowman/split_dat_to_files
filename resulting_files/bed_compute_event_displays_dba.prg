CREATE PROGRAM bed_compute_event_displays:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 catalog_cd = f8
      2 codes[*]
        3 code_set = i4
        3 code_value = f8
      2 proposed_display = vc
      2 proposed_display_dupe_ind = i2
      2 given_display_dupe_ind = i2
      2 cki = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(orderableindexesexpectuniqueeventdisplays,0)))
  RECORD orderableindexesexpectuniqueeventdisplays(
    1 orderables[*]
      2 display_gt_40char_ind = i2
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
 DECLARE isordercatalogismedication(display=vc) = f8
 DECLARE isdisplayduplicateonordercatalog(display=vc) = f8
 DECLARE isdisplayduplicateoncodevaluefororderable(display=vc,codevalue=f8) = f8
 DECLARE isidnenabled(dummyvar=i2) = i2
 DECLARE getcodevaluefordisplayfromcodeset(display=vc,codeset=i4) = f8
 DECLARE geteventcodeassociatedtoorderable(catalogcd=f8) = f8
 DECLARE geteventsetassociatedtoorderable(catalogcd=f8) = f8
 DECLARE appendckitothedisplay(codevalue=f8,display=vc,consideronlyactive=i2,cki=vc) = vc
 DECLARE ensureordercatalogforidn(catalogcd=f8,primarymnemonic=vc) = f8
 DECLARE generateuniquedisplayfromhash(codevalue=f8) = vc
 DECLARE isdisplayduplicateonv500eventsetcodetable(display=vc) = f8
 DECLARE isdisplayduplicateonv500eventcodetable(display=vc) = f8
 DECLARE med_order_catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pharmacy_catalog_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE v500_event_set_cd = f8 WITH protect, noconstant(0.0)
 DECLARE v500_event_cd = f8 WITH protect, noconstant(0.0)
 SUBROUTINE isdisplayduplicateonordercatalog(display)
   SET order_catalog_cd = 0.0
   SELECT INTO "nl:"
    FROM order_catalog oc
    PLAN (oc
     WHERE trim(cnvtupper(oc.primary_mnemonic))=trim(cnvtupper(substring(1,100,display))))
    DETAIL
     order_catalog_cd = oc.catalog_cd
    WITH nocounter
   ;end select
   RETURN(order_catalog_cd)
 END ;Subroutine
 SUBROUTINE isordercatalogismedication(display)
   SET med_order_catalog_cd = 0.0
   SELECT INTO "nl:"
    FROM order_catalog oc
    PLAN (oc
     WHERE trim(cnvtupper(oc.primary_mnemonic))=trim(cnvtupper(substring(1,100,display)))
      AND oc.catalog_type_cd=pharmacy_catalog_cd)
    DETAIL
     med_order_catalog_cd = oc.catalog_cd
    WITH nocounter
   ;end select
   RETURN(med_order_catalog_cd)
 END ;Subroutine
 SUBROUTINE isdisplayduplicateoncodevaluefororderable(display,codevalue)
   DECLARE codevalueofduplicateon200 = f8 WITH protect, noconstant(0.0)
   DECLARE codevalueofduplicateon72 = f8 WITH protect, noconstant(0)
   DECLARE codevalueofduplicateon93 = f8 WITH protect, noconstant(0)
   DECLARE truncateddisplay = vc WITH protect, noconstant("")
   DECLARE codevaluefromcs200 = f8 WITH protect, noconstant(0.0)
   DECLARE codevaluefromcs72 = f8 WITH protect, noconstant(0.0)
   DECLARE codevaluefromcs93 = f8 WITH protect, noconstant(0.0)
   DECLARE codevalueofduplicate = f8 WITH protect, noconstant(0.0)
   DECLARE eventcodecdassociatedtoorderablefromv500 = f8 WITH protect, noconstant(0.0)
   DECLARE eventsetcdassociatedtoorderablefromv500 = f8 WITH protect, noconstant(0.0)
   SET truncateddisplay = substring(1,40,display)
   SET codevaluefromcs200 = getcodevaluefordisplayfromcodeset(truncateddisplay,200)
   IF (codevaluefromcs200 > 0.0
    AND codevaluefromcs200 != codevalue)
    SET codevalueofduplicateon200 = codevaluefromcs200
   ENDIF
   IF (codevalue > 0.0
    AND codevalueofduplicateon200=0.0)
    SET eventcodecdassociatedtoorderablefromv500 = geteventcodeassociatedtoorderable(codevalue)
    SET codevaluefromcs72 = getcodevaluefordisplayfromcodeset(truncateddisplay,72)
    IF (eventcodecdassociatedtoorderablefromv500 > 0.0
     AND codevaluefromcs72 > 0.0
     AND eventcodecdassociatedtoorderablefromv500 != codevaluefromcs72)
     SET codevalueofduplicateon72 = codevaluefromcs72
    ENDIF
    SET eventsetcdassociatedtoorderablefromv500 = geteventsetassociatedtoorderable(codevalue)
    SET codevaluefromcs93 = getcodevaluefordisplayfromcodeset(truncateddisplay,93)
    IF (eventsetcdassociatedtoorderablefromv500 > 0.0
     AND codevaluefromcs93 > 0.0
     AND eventcodecdassociatedtoorderablefromv500 != codevaluefromcs93)
     SET codevalueofduplicateon93 = codevaluefromcs93
    ENDIF
   ENDIF
   IF (codevalueofduplicateon200 > 0.0)
    SET codevalueofduplicate = codevalueofduplicateon200
   ELSEIF (codevalueofduplicateon72 > 0.0)
    SET codevalueofduplicate = codevalueofduplicateon72
   ELSEIF (codevalueofduplicateon93 > 0.0)
    SET codevalueofduplicate = codevalueofduplicateon93
   ELSE
    SET codevalueofduplicate = 0.0
   ENDIF
   RETURN(codevalueofduplicate)
 END ;Subroutine
 SUBROUTINE getcodevaluefordisplayfromcodeset(display,codeset)
   DECLARE duplicatecodevalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.display=display
     AND cv.code_set=codeset
    DETAIL
     duplicatecodevalue = cv.code_value
    WITH nocounter
   ;end select
   RETURN(duplicatecodevalue)
 END ;Subroutine
 SUBROUTINE geteventcodeassociatedtoorderable(catalogcd)
   DECLARE eventcodecdassociatedtoorderablefromv500 = f8 WITH protect, noconstant(0.0)
   IF (catalogcd > 0.0)
    SELECT INTO "nl:"
     FROM code_value_event_r cver
     WHERE cver.parent_cd=catalogcd
      AND cver.event_cd > 0.0
     DETAIL
      eventcodecdassociatedtoorderablefromv500 = cver.event_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(eventcodecdassociatedtoorderablefromv500)
 END ;Subroutine
 SUBROUTINE geteventsetassociatedtoorderable(catalogcd)
   DECLARE eventcodecdassociatedtoorderablefromv500 = f8 WITH protect, noconstant(
    geteventcodeassociatedtoorderable(catalogcd))
   DECLARE eventsetcdassociatedtoorderablefromv500 = f8 WITH protect, noconstant(0.0)
   IF (eventcodecdassociatedtoorderablefromv500 > 0.0)
    SELECT INTO "nl:"
     FROM v500_event_set_explode vese
     WHERE vese.event_cd=eventcodecdassociatedtoorderablefromv500
      AND vese.event_set_cd > 0.0
     DETAIL
      eventsetcdassociatedtoorderablefromv500 = vese.event_set_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(eventsetcdassociatedtoorderablefromv500)
 END ;Subroutine
 SUBROUTINE isidnenabled(dummyvar)
   SELECT INTO "nl:"
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_name="INCREASED DRUG NAME CKI LOGIC"
      AND dm.info_domain="MULTUM"
      AND dm.info_domain_id=0)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE appendckitothedisplay(codevalue,display,consideronlyactive,cki)
   DECLARE ckistring = vc WITH protect, noconstant("")
   DECLARE uniquediplay = vc WITH protect, noconstant("")
   IF (codevalue > 0.0)
    IF (consideronlyactive=1)
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_value=codevalue
        AND cv.active_ind=1)
      DETAIL
       ckistring = cv.cki
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_value=codevalue)
      DETAIL
       ckistring = cv.cki
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (trim(cki) > "")
    SET ckistring = trim(cki)
   ENDIF
   CALL bedlogmessage("before: appendCKIToTheDisplay - ckiString = ",cnvtstring(ckistring))
   CALL bedlogmessage("before: code value = ",cnvtstring(codevalue))
   IF (ckistring="")
    SET ckistring = generateuniquedisplayfromhash(codevalue)
   ENDIF
   DECLARE ckilength = i4 WITH protect, constant(textlen(ckistring))
   DECLARE updateddisplaylength = i4 WITH protect, constant((40 - ckilength))
   CALL bedlogmessage("after: appendCKIToTheDisplay - cki Length = ",cnvtstring(ckilength))
   CALL bedlogmessage("after: appendCKIToTheDisplay - ckiString = ",cnvtstring(ckistring))
   DECLARE trimmeddisplay = vc WITH protect, constant(substring(0,updateddisplaylength,display))
   CALL bedlogmessage("appendCKIToTheDisplay - trimmedDisplay = ",trimmeddisplay)
   SET uniquediplay = build(trimmeddisplay,ckistring)
   CALL bedlogmessage("appendCKIToTheDisplay",uniquediplay)
   RETURN(uniquediplay)
 END ;Subroutine
 SUBROUTINE generateuniquedisplayfromhash(codevalue)
   DECLARE hashstring = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    hash = sqlpassthru("dbms_utility.GET_HASH_VALUE(oc.primary_mnemonic,0,1073741824)",10)
    FROM order_catalog oc
    WHERE oc.catalog_cd=codevalue
    GROUP BY sqlpassthru("dbms_utility.GET_HASH_VALUE(oc.primary_mnemonic,0,1073741824)",10)
    DETAIL
     hashstring = hash
    WITH format
   ;end select
   IF (curqual <= 0)
    CALL bedlogmessage(
     "generateUniqueDisplayFromHash - There is no row on order catalog table with catalog_Cd = ",
     codevalue)
   ENDIF
   CALL bedlogmessage("generateUniqueDisplayFromHash",hashstring)
   RETURN(hashstring)
 END ;Subroutine
 SUBROUTINE isdisplayduplicateonv500eventsetcodetable(display)
   SET v500_event_set_cd = 0.0
   SELECT INTO "nl:"
    FROM v500_event_set_code vesc
    PLAN (vesc
     WHERE trim(cnvtupper(vesc.event_set_cd_disp))=trim(cnvtupper(substring(1,40,display))))
    DETAIL
     v500_event_set_cd = vesc.event_set_cd
    WITH nocounter
   ;end select
   RETURN(v500_event_set_cd)
 END ;Subroutine
 SUBROUTINE isdisplayduplicateonv500eventcodetable(display)
   SET v500_event_cd = 0.0
   SELECT INTO "nl:"
    FROM v500_event_code vec
    PLAN (vec
     WHERE trim(cnvtupper(vec.event_cd_disp))=trim(cnvtupper(substring(1,40,display))))
    DETAIL
     v500_event_cd = vec.event_cd
    WITH nocounter
   ;end select
   RETURN(v500_event_cd)
 END ;Subroutine
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
 DECLARE cvparse = vc WITH protect, noconstant("")
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 DECLARE givencodeset = i4 WITH protect, noconstant(0)
 DECLARE displaydupind = i2 WITH protect, noconstant(0)
 DECLARE proposed_display = vc WITH protect, noconstant("")
 DECLARE checkforduplicates(display=vc,codeset=i4) = null
 DECLARE computedisplay(dummyvar) = null
 DECLARE computedisplayforspecificorderable(catalog_cd=f8,display=vc,consider_only_active=i2,
  requested_cki=vc) = vc
 IF (size(request->orderables,5) > 0)
  SET stat = alterlist(reply->orderables,size(request->orderables,5))
  SET stat = alterlist(orderableindexesexpectuniqueeventdisplays->orderables,size(request->orderables,
    5))
  IF ((request->is_display_eval_needed=1))
   FOR (i = 1 TO size(request->orderables,5))
     IF (textlen(trim(request->orderables[i].given_display)) > 40)
      SET orderableindexesexpectuniqueeventdisplays->orderables[i].display_gt_40char_ind = 1
      SET reply->orderables[i].proposed_display = computedisplayforspecificorderable(request->
       orderables[i].catalog_cd,request->orderables[i].given_display,request->orderables[i].
       consider_only_active,request->orderables[i].cki)
     ENDIF
   ENDFOR
  ENDIF
  FOR (i = 1 TO size(request->orderables,5))
    IF ((request->orderables[i].consider_only_active=1))
     SET cvparse = "cv.active_ind = 1"
    ELSE
     SET cvparse = "(cv.active_ind = 1 or cv.active_ind = 0)"
    ENDIF
    IF ((request->orderables[i].catalog_cd > 0.0))
     SET reply->orderables[i].catalog_cd = request->orderables[i].catalog_cd
     SET reply->orderables[i].given_display_dupe_ind = 0
    ELSEIF (trim(request->orderables[i].cki) > "")
     SET reply->orderables[i].catalog_cd = 0.0
     SET reply->orderables[i].cki = request->orderables[i].cki
     SET reply->orderables[i].given_display_dupe_ind = 0
    ELSE
     CALL bederrorcheck("Error 000: Invalid request.")
    ENDIF
    FOR (j = 1 TO size(request->orderables[i].code_sets,5))
     CALL checkforduplicates(request->orderables[i].given_display,request->orderables[i].code_sets[j]
      .code_set,orderableindexesexpectuniqueeventdisplays->orderables[i].display_gt_40char_ind)
     IF (codevalue > 0.0)
      SET stat = alterlist(reply->orderables[i].codes,j)
      SET reply->orderables[i].codes[j].code_value = codevalue
      SET reply->orderables[i].codes[j].code_set = givencodeset
      SET reply->orderables[i].given_display_dupe_ind = displaydupind
     ELSEIF ((codevalue=- (1.0)))
      SET stat = alterlist(reply->orderables[i].codes,j)
      SET reply->orderables[i].codes[j].code_value = codevalue
      SET reply->orderables[i].codes[j].code_set = givencodeset
      SET reply->orderables[i].given_display_dupe_ind = displaydupind
     ENDIF
    ENDFOR
  ENDFOR
  IF ((request->is_display_eval_needed=1))
   CALL computedisplay(0)
   FOR (i = 1 TO size(reply->orderables,5))
    IF ((request->orderables[i].consider_only_active=1))
     SET cvparse = "cv.active_ind = 1"
    ELSE
     SET cvparse = "(cv.active_ind = 1 or cv.active_ind = 0)"
    ENDIF
    FOR (j = 1 TO size(reply->orderables[i].codes,5))
      IF ((reply->orderables[i].given_display_dupe_ind=1))
       CALL checkforduplicates(reply->orderables[i].proposed_display,reply->orderables[i].codes[j].
        code_set,0)
       IF (codevalue > 0.0)
        SET reply->orderables[i].codes[j].code_value = codevalue
        SET reply->orderables[i].proposed_display_dupe_ind = displaydupind
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 SUBROUTINE checkforduplicates(display,codeset,displaygt40charind)
   IF (displaygt40charind=0)
    SET codevalue = 0.0
    SET givencodeset = 0
    SET displaydupind = 0
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=codeset
      AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,display))))
      AND parser(cvparse)
     DETAIL
      codevalue = cv.code_value, givencodeset = codeset, displaydupind = 1
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 001: Error while checking for dupe display")
    IF (codeset=72)
     SELECT INTO "nl:"
      FROM v500_event_code vec
      WHERE vec.event_cd_disp_key=trim(cnvtupper(cnvtalphanum(substring(1,40,display))))
      DETAIL
       codevalue = vec.event_cd, givencodeset = codeset, displaydupind = 1
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 002: Error while checking for dupe display on v500_event_code table.")
    ELSEIF (codeset=93)
     SELECT INTO "nl:"
      FROM v500_event_set_code vesc
      WHERE vesc.event_set_name_key=trim(cnvtupper(cnvtalphanum(substring(1,40,display))))
      DETAIL
       codevalue = vesc.event_set_cd, givencodeset = codeset, displaydupind = 1
      WITH nocounter
     ;end select
     CALL bederrorcheck(
      "Error 003: Error while checking for dupe display on v500_event_set_code table.")
    ELSE
     CALL bederrorcheck("Error 004: Invalid code_set in the request.")
    ENDIF
   ELSE
    SET codevalue = - (1.0)
    SET givencodeset = codeset
    SET displaydupind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE computedisplay(dummyvar)
   DECLARE oc_display = vc WITH protect, noconstant("")
   DECLARE cki = vc WITH protect, noconstant("")
   FOR (i = 1 TO size(reply->orderables,5))
     IF ((reply->orderables[i].given_display_dupe_ind=1)
      AND (orderableindexesexpectuniqueeventdisplays->orderables[i].display_gt_40char_ind=0))
      IF ((request->orderables[i].catalog_cd > 0.0))
       SELECT INTO "nl:"
        FROM order_catalog oc
        WHERE (oc.catalog_cd=reply->orderables[i].catalog_cd)
        DETAIL
         oc_display = oc.primary_mnemonic
        WITH nocounter
       ;end select
       CALL bederrorcheck("Error 005: Error while selecting mnemonic from order_catalog.")
      ELSEIF (trim(request->orderables[i].cki) > "")
       SET oc_display = trim(request->orderables[i].given_display)
       SET cki = trim(request->orderables[i].cki)
      ENDIF
      SET reply->orderables[i].proposed_display = appendckitothedisplay(reply->orderables[i].
       catalog_cd,oc_display,request->orderables[i].consider_only_active,cki)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE computedisplayforspecificorderable(catalog_cd,display,consider_only_active,requested_cki)
   SET proposed_display = ""
   DECLARE oc_display = vc WITH protect, noconstant("")
   DECLARE cki = vc WITH protect, noconstant("")
   IF ((request->orderables[i].catalog_cd > 0.0))
    SELECT INTO "nl:"
     FROM order_catalog oc
     WHERE oc.catalog_cd=catalog_cd
     DETAIL
      oc_display = oc.primary_mnemonic
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 006: Error while selecting mnemonic from order_catalog.")
   ELSEIF (trim(requested_cki) > "")
    SET oc_display = trim(display)
    SET cki = trim(requested_cki)
   ENDIF
   SET proposed_display = appendckitothedisplay(catalog_cd,oc_display,consider_only_active,cki)
   RETURN(proposed_display)
 END ;Subroutine
#exit_script
 CALL bedexitscript(0)
END GO
