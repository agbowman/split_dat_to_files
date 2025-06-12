CREATE PROGRAM bed_ens_mltm_content:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 code_value = f8
      2 synonyms[*]
        3 synonym_id = f8
      2 dup_event_ind = i2
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET med_hier
 RECORD med_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET dil_hier
 RECORD dil_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET im_hier
 RECORD im_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET temp_seq
 RECORD temp_seq(
   1 event_sets[*]
     2 code_value = f8
 )
 FREE SET fin_med_hier
 RECORD fin_med_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET fin_dil_hier
 RECORD fin_dil_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET fin_im_hier
 RECORD fin_im_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
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
 DECLARE isidnenabled = i2 WITH protect, noconstant(isidnenabled(0))
 DECLARE cat_parse_txt = vc
 DECLARE dnum = vc
 DECLARE len = i2 WITH protect, noconstant(0)
 DECLARE add_events_ind = i2 WITH protect, noconstant(0)
 DECLARE primary_code_value = f8 WITH protect, noconstant(0)
 DECLARE error_flag = vc
 DECLARE privilege_exception_id = f8 WITH protect, noconstant(0)
 DECLARE exception_type_code_value = f8 WITH protect, noconstant(0)
 DECLARE activity_type_code_value = f8 WITH protect, noconstant(0)
 DECLARE task_activity_type_code_value = f8 WITH protect, noconstant(0)
 DECLARE catalog_type_code_value = f8 WITH protect, noconstant(0)
 DECLARE default_client_code_value = f8 WITH protect, noconstant(0)
 DECLARE order_synonym_id = f8 WITH protect, noconstant(0)
 DECLARE active_status_code_value = f8 WITH protect, noconstant(0)
 DECLARE auth_code_value = f8 WITH protect, noconstant(0)
 DECLARE bill_id = f8 WITH protect, noconstant(0)
 DECLARE parent_contributor_code_value = f8 WITH protect, noconstant(0)
 DECLARE task_contributor_code_value = f8 WITH protect, noconstant(0)
 DECLARE cosign_cnt = i2 WITH protect, noconstant(0)
 DECLARE synonym_cnt = i2 WITH protect, noconstant(0)
 DECLARE privilege_cnt = i2 WITH protect, noconstant(0)
 DECLARE list_cnt = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE serrmsg = vc
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE new_event_code_value = f8 WITH protect, noconstant(0)
 DECLARE def_frmt_code_value = f8 WITH protect, noconstant(0)
 DECLARE def_store_code_value = f8 WITH protect, noconstant(0)
 DECLARE def_class_code_value = f8 WITH protect, noconstant(0)
 DECLARE def_confid_lvl_code_value = f8 WITH protect, noconstant(0)
 DECLARE subclass_code_value = f8 WITH protect, noconstant(0)
 DECLARE event_code_value = f8 WITH protect, noconstant(0)
 DECLARE event_set_code_value = f8 WITH protect, noconstant(0)
 DECLARE medication_code_value = f8 WITH protect, noconstant(0)
 DECLARE immunization_code_value = f8 WITH protect, noconstant(0)
 DECLARE diluents_code_value = f8 WITH protect, noconstant(0)
 DECLARE ocfset_code_value = f8 WITH protect, noconstant(0)
 DECLARE child_code_value = f8 WITH protect, noconstant(0)
 DECLARE drug_cat_id = f8 WITH protect, noconstant(0)
 DECLARE med_cnt = f8 WITH protect, noconstant(0)
 DECLARE im_cnt = f8 WITH protect, noconstant(0)
 DECLARE med_reseq = f8 WITH protect, noconstant(0)
 DECLARE im_reseq = f8 WITH protect, noconstant(0)
 DECLARE parent_cd = f8 WITH protect, noconstant(0)
 DECLARE dil_cnt = f8 WITH protect, noconstant(0)
 DECLARE dil_reseq = f8 WITH protect, noconstant(0)
 DECLARE dup_event_ind = i2 WITH protect, noconstant(0)
 DECLARE task_template_ind = i2 WITH protect, noconstant(0)
 DECLARE qb_pos_cnt = i2 WITH protect, noconstant(0)
 DECLARE task_activity_code_value = f8 WITH protect, noconstant(0)
 DECLARE cnt = i2
 DECLARE oc_multi_pharmacy_review_table_exists = i2 WITH protect, noconstant(0)
 DECLARE new_cv = f8 WITH protect, noconstant(0)
 DECLARE br_pr_req_ind = i2 WITH protect, noconstant(0)
 DECLARE dcp_clin_cat_code_value = i2 WITH protect, noconstant(0)
 DECLARE level = i2
 DECLARE parent_ind = i2
 DECLARE tot_cnt = i2
 DECLARE new_ref_id = f8
 DECLARE br_print_req_ind = i2
 DECLARE task_created_ind = i2
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET primary_code_value = 0.0
 SET privilege_exception_id = 0.0
 SET exception_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET task_activity_type_code_value = 0.0
 SET catalog_type_code_value = 0.0
 SET default_client_code_value = 0.0
 SET order_synonym_id = 0.0
 SET active_status_code_value = 0.0
 SET auth_code_value = 0.0
 SET bill_id = 0.0
 SET parent_contributor_code_value = 0.0
 SET task_contributor_code_value = 0.0
 SET cosign_cnt = 0
 SET synonym_cnt = 0
 SET privilege_cnt = 0
 SET list_cnt = 0
 SET cnt = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET new_event_code_value = 0.0
 SET def_frmt_code_value = 0.0
 SET def_store_code_value = 0.0
 SET def_class_code_value = 0.0
 SET def_confid_lvl_code_value = 0.0
 SET subclass_code_value = 0.0
 SET event_code_value = 0.0
 SET event_set_code_value = 0.0
 SET medication_code_value = 0.0
 SET immunization_code_value = 0.0
 SET diluents_code_value = 0.0
 SET ocfset_code_value = 0.0
 SET child_code_value = 0.0
 SET drug_cat_id = 0.0
 SET med_cnt = 0.0
 SET im_cnt = 0.0
 SET med_reseq = 0.0
 SET im_reseq = 0.0
 SET parent_cd = 0.0
 SET dil_cnt = 0.0
 SET dil_reseq = 0.0
 SET dup_event_ind = 0
 SET oc_multi_pharmacy_review_table_exists = checkdic("OC_MULTI_PHARMACY_REVIEW","T",0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6015
   AND cv.cdf_meaning="ORDERABLES"
   AND cv.active_ind=1
  DETAIL
   exception_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   activity_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="TASK"
   AND cv.active_ind=1
  DETAIL
   task_activity_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   catalog_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16389
   AND cv.cdf_meaning="MEDICATIONS"
   AND cv.active_ind=1
  DETAIL
   default_client_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_status_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD CAT"
   AND cv.active_ind=1
  DETAIL
   parent_contributor_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="TASKCAT"
   AND cv.active_ind=1
  DETAIL
   task_contributor_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_code_value = cv.code_value
  WITH nocounter
 ;end select
 RECORD qb_params(
   1 active_ind = i2
   1 chart_not_cmplt_ind = i2
   1 task_type_cd = f8
   1 quick_chart_done_ind = i2
   1 quick_chart_notdone_ind = i2
   1 retain_time = f8
   1 retain_units = i2
   1 overdue_min = f8
   1 allpositionchart_ind = i2
   1 primary_synonym_ind = i2
   1 dcp_synonym_ind = i2
   1 ancillary_synonym_ind = i2
   1 input_form_cd = f8
   1 build_input_form_ind = i2
   1 reschedule_time = i2
   1 qual_pos[*]
     2 position_cd = f8
   1 quick_chart_ind = i2
   1 overdue_units = i4
   1 build_event_cd_ind = i2
 )
 SET task_template_ind = 0
 SELECT INTO "nl:"
  FROM tl_quick_build_params tlqb
  WHERE tlqb.catalog_type_cd=catalog_type_code_value
   AND tlqb.activity_type_cd=activity_type_code_value
  DETAIL
   task_template_ind = 1, qb_params->active_ind = tlqb.active_ind, qb_params->chart_not_cmplt_ind =
   tlqb.chart_not_cmplt_ind,
   qb_params->task_type_cd = tlqb.task_type_cd, qb_params->quick_chart_done_ind = tlqb
   .quick_chart_done_ind, qb_params->quick_chart_notdone_ind = tlqb.quick_chart_notdone_ind,
   qb_params->retain_time = tlqb.retain_time, qb_params->retain_units = tlqb.retain_units, qb_params
   ->overdue_min = tlqb.overdue_min,
   qb_params->allpositionchart_ind = tlqb.allpositionchart_ind, qb_params->primary_synonym_ind = tlqb
   .primary_synonym_ind, qb_params->dcp_synonym_ind = tlqb.dcp_synonym_ind,
   qb_params->ancillary_synonym_ind = tlqb.ancillary_synonym_ind, qb_params->input_form_cd = tlqb
   .input_form_cd, qb_params->build_input_form_ind = tlqb.build_input_form_ind,
   qb_params->reschedule_time = tlqb.reschedule_time, qb_params->quick_chart_ind = tlqb
   .quick_chart_ind, qb_params->overdue_units = tlqb.overdue_units,
   qb_params->build_event_cd_ind = tlqb.build_event_cd_ind
  WITH counter
 ;end select
 SET qb_pos_cnt = 0
 IF ((qb_params->allpositionchart_ind=0))
  SELECT INTO "nl:"
   FROM tl_quick_build_position_xref t,
    code_value cv
   PLAN (t
    WHERE t.catalog_type_cd=catalog_type_code_value
     AND t.activity_type_cd=activity_type_code_value)
    JOIN (cv
    WHERE cv.code_value=t.position_cd
     AND cv.active_ind=1)
   DETAIL
    qb_pos_cnt = (qb_pos_cnt+ 1), stat = alterlist(qb_params->qual_pos,qb_pos_cnt), qb_params->
    qual_pos[qb_pos_cnt].position_cd = t.position_cd
   WITH counter
  ;end select
 ENDIF
 SET task_activity_code_value = 0.0
 SET task_activity_code_value = uar_get_code_by("MEANING",6027,"CHART RESULT")
 SET cnt = size(request->orderables,5)
 SET stat = alterlist(reply->orderables,cnt)
 FOR (x = 1 TO cnt)
   SET cosign_cnt = 0
   SET synonym_cnt = 0
   SET privilege_cnt = 0
   SET dup_event_ind = 0
   IF ((request->orderables[x].code_value=0))
    SET synonym_cnt = size(request->orderables[x].synonyms,5)
    IF (synonym_cnt > 0)
     FOR (y = 1 TO synonym_cnt)
       IF ((request->orderables[x].synonyms[y].mnemonic_type_code_value=primary_code_value))
        SET new_cv = 0.0
        SELECT INTO "NL:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_cv = cnvtreal(j)
         WITH format, counter
        ;end select
        SET request->orderables[x].code_value = new_cv
        INSERT  FROM code_value cv
         SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
          cv.cki = request->orderables[x].cki, cv.concept_cki = request->orderables[x].concept_cki,
          cv.display_key_nls = null,
          cv.display = trim(substring(1,40,request->orderables[x].description)), cv.display_key =
          trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x].description)))), cv
          .description = trim(substring(1,60,request->orderables[x].description)),
          cv.data_status_cd = auth_code_value, cv.data_status_prsnl_id = reqinfo->updt_id, cv
          .active_type_cd = active_status_code_value,
          cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.begin_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task
           = reqinfo->updt_task,
          cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].description),
          " into codeset 200.")
         GO TO exit_script
        ENDIF
        IF ((request->orderables[x].event_code_display > " "))
         SET add_events_ind = 1
         SET dup_event_ind = 0
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE cv.code_set=72
           AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x].
              event_code_display))))
          DETAIL
           dup_event_ind = 1
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE cv.code_set=93
           AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x].
              event_code_display))))
          DETAIL
           dup_event_ind = 1
          WITH nocounter
         ;end select
         SELECT INTO "nl:"
          FROM v500_event_set_code v
          WHERE v.event_set_name_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x
              ].event_code_display))))
           AND trim(cnvtupper(v.event_set_name))=trim(cnvtupper(substring(1,40,request->orderables[x]
             .event_code_display)))
          DETAIL
           dup_event_ind = 1
          WITH nocounter
         ;end select
         IF (dup_event_ind=0)
          SET med_cnt = size(fin_med_hier->event_hier,5)
          SET dil_cnt = size(fin_dil_hier->event_hier,5)
          IF (((med_cnt <= 0) OR (dil_cnt <= 0)) )
           SELECT INTO "nl:"
            FROM code_value cv
            WHERE cv.code_set=23
             AND cv.cdf_meaning="UNKNOWN"
             AND cv.active_ind=1
            DETAIL
             def_frmt_code_value = cv.code_value
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM code_value cv
            WHERE cv.code_set=25
             AND cv.cdf_meaning="UNKNOWN"
             AND cv.active_ind=1
            DETAIL
             def_store_code_value = cv.code_value
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM code_value cv
            WHERE cv.code_set=53
             AND cv.cdf_meaning="MED"
             AND cv.active_ind=1
            DETAIL
             def_class_code_value = cv.code_value
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM code_value cv
            WHERE cv.code_set=87
             AND cv.cdf_meaning="ROUTCLINICAL"
             AND cv.active_ind=1
            DETAIL
             def_confid_lvl_code_value = cv.code_value
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM code_value cv
            WHERE cv.code_set=102
             AND cv.cdf_meaning="UNKNOWN"
             AND cv.active_ind=1
            DETAIL
             subclass_code_value = cv.code_value
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM v500_event_set_code v
            WHERE v.event_set_name_key="MEDICATIONS"
             AND trim(cnvtupper(v.event_set_name))="MEDICATIONS"
            DETAIL
             medication_code_value = v.event_set_cd
            WITH nocounter
           ;end select
           SELECT INTO "nl:"
            FROM v500_event_set_code v
            WHERE v.event_set_name_key="IMMUNIZATIONS"
             AND trim(cnvtupper(v.event_set_name))="IMMUNIZATIONS"
            DETAIL
             immunization_code_value = v.event_set_cd
            WITH nocounter
           ;end select
           IF ((request->diluent_set_code_value=0))
            SELECT INTO "nl:"
             FROM v500_event_set_code v
             WHERE v.event_set_name_key="DILUENTS"
              AND trim(cnvtupper(v.event_set_name))="DILUENTS"
             DETAIL
              diluents_code_value = v.event_set_cd
             WITH nocounter
            ;end select
           ELSE
            SET diluents_code_value = request->diluent_set_code_value
           ENDIF
           SELECT INTO "nl:"
            FROM v500_event_set_code v
            WHERE v.event_set_name_key="ALLOCFSETS"
             AND trim(cnvtupper(v.event_set_name))="ALLOCFSETS"
            DETAIL
             ocfset_code_value = v.event_set_cd
            WITH nocounter
           ;end select
          ENDIF
          IF (med_cnt <= 0)
           SET med_reseq = 1
           DECLARE med_parse = vc
           SET stat = alterlist(med_hier->event_hier,10)
           SET level = 1
           SET med_hier->event_hier[1].code_value = medication_code_value
           SET med_hier->event_hier[1].level = 1
           SET med_parse = build("vec.event_set_cd IN (",medication_code_value,")")
           SET parent_ind = 1
           SET list_cnt = 1
           SET tot_cnt = 1
           WHILE (parent_ind=1)
             SET level = (level+ 1)
             SET parent_ind = 0
             SELECT INTO "nl:"
              FROM v500_event_set_canon vec
              WHERE parser(med_parse)
              HEAD REPORT
               med_parse = "vec.event_set_cd IN (", comma_ind = 0
              DETAIL
               list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
               IF (tot_cnt > 10)
                stat = alterlist(med_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
               ENDIF
               med_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, med_hier->
               event_hier[list_cnt].level = level
               IF (comma_ind=0)
                med_parse = build(med_parse,vec.parent_event_set_cd), comma_ind = 1
               ELSE
                med_parse = build(med_parse,",",vec.parent_event_set_cd)
               ENDIF
               parent_ind = 1
              WITH nocounter
             ;end select
             SET med_parse = concat(med_parse,")")
           ENDWHILE
           SET stat = alterlist(med_hier->event_hier,list_cnt)
           IF (size(med_hier->event_hier,5) > 0)
            SELECT INTO "nl:"
             c = med_hier->event_hier[d.seq].code_value, l = med_hier->event_hier[d.seq].level
             FROM (dummyt d  WITH seq = size(med_hier->event_hier,5))
             PLAN (d)
             ORDER BY c, l DESC
             HEAD REPORT
              list_cnt = 0, tot_cnt = 0, stat = alterlist(fin_med_hier->event_hier,10)
             HEAD c
              list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
              IF (tot_cnt > 10)
               stat = alterlist(fin_med_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
              ENDIF
              fin_med_hier->event_hier[list_cnt].code_value = c, fin_med_hier->event_hier[list_cnt].
              level = l
             FOOT REPORT
              stat = alterlist(fin_med_hier->event_hier,list_cnt)
             WITH nocounter
            ;end select
           ENDIF
          ENDIF
          IF (dil_cnt <= 0)
           SET dil_reseq = 1
           DECLARE dil_parse = vc
           SET stat = alterlist(dil_hier->event_hier,10)
           SET level = 1
           SET dil_hier->event_hier[1].code_value = diluents_code_value
           SET dil_hier->event_hier[1].level = 1
           SET dil_parse = build("vec.event_set_cd IN (",diluents_code_value,")")
           SET parent_ind = 1
           SET list_cnt = 1
           SET tot_cnt = 1
           WHILE (parent_ind=1)
             SET level = (level+ 1)
             SET parent_ind = 0
             SELECT INTO "nl:"
              FROM v500_event_set_canon vec
              WHERE parser(dil_parse)
              HEAD REPORT
               dil_parse = "vec.event_set_cd IN (", comma_ind = 0
              DETAIL
               list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
               IF (tot_cnt > 10)
                stat = alterlist(dil_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
               ENDIF
               dil_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, dil_hier->
               event_hier[list_cnt].level = level
               IF (comma_ind=0)
                dil_parse = build(dil_parse,vec.parent_event_set_cd), comma_ind = 1
               ELSE
                dil_parse = build(dil_parse,",",vec.parent_event_set_cd)
               ENDIF
               parent_ind = 1
              WITH nocounter
             ;end select
             SET dil_parse = concat(dil_parse,")")
           ENDWHILE
           SET stat = alterlist(dil_hier->event_hier,list_cnt)
           IF (size(dil_hier->event_hier,5) > 0)
            SELECT INTO "nl:"
             c = dil_hier->event_hier[d.seq].code_value, l = dil_hier->event_hier[d.seq].level
             FROM (dummyt d  WITH seq = size(dil_hier->event_hier,5))
             PLAN (d)
             ORDER BY c, l DESC
             HEAD REPORT
              list_cnt = 0, tot_cnt = 0, stat = alterlist(fin_dil_hier->event_hier,10)
             HEAD c
              list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
              IF (tot_cnt > 10)
               stat = alterlist(fin_dil_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
              ENDIF
              fin_dil_hier->event_hier[list_cnt].code_value = c, fin_dil_hier->event_hier[list_cnt].
              level = l
             FOOT REPORT
              stat = alterlist(fin_dil_hier->event_hier,list_cnt)
             WITH nocounter
            ;end select
           ENDIF
          ENDIF
          SET request_cv->cd_value_list[1].action_flag = 1
          SET request_cv->cd_value_list[1].code_set = 72
          SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orderables[x].
            event_code_display))
          IF (isidnenabled=1)
           SET request_cv->cd_value_list[1].description = trim(substring(1,40,request->orderables[x].
             event_code_display))
          ELSE
           SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orderables[x].
             description))
          ENDIF
          IF (isidnenabled=1)
           SET request_cv->cd_value_list[1].definition = trim(substring(1,40,request->orderables[x].
             event_code_display))
          ELSE
           SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orderables[x].
             description))
          ENDIF
          SET request_cv->cd_value_list[1].active_ind = 1
          SET trace = recpersist
          EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
          IF ((reply_cv->status_data.status="S")
           AND (reply_cv->qual[1].code_value > 0))
           SET event_code_value = reply_cv->qual[1].code_value
          ELSE
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into codeset 72.")
           GO TO exit_script
          ENDIF
          INSERT  FROM v500_event_code vec
           SET vec.event_cd = event_code_value, vec.event_cd_definition =
            IF (isidnenabled=1) trim(substring(1,40,request->orderables[x].event_code_display))
            ELSE trim(substring(1,100,request->orderables[x].description))
            ENDIF
            , vec.event_cd_descr =
            IF (isidnenabled=1) trim(substring(1,40,request->orderables[x].event_code_display))
            ELSE trim(substring(1,60,request->orderables[x].description))
            ENDIF
            ,
            vec.event_cd_disp = trim(substring(1,40,request->orderables[x].event_code_display)), vec
            .event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x].
                event_code_display)))), vec.code_status_cd = active_status_code_value,
            vec.def_docmnt_attributes = " ", vec.def_docmnt_format_cd = def_frmt_code_value, vec
            .def_docmnt_storage_cd = def_store_code_value,
            vec.def_event_class_cd = def_class_code_value, vec.def_event_confid_level_cd =
            def_confid_lvl_code_value, vec.def_event_level = 0.0,
            vec.event_add_access_ind = 0.0, vec.event_cd_subclass_cd = subclass_code_value, vec
            .event_chg_access_ind = 1,
            vec.event_set_name = trim(substring(1,40,request->orderables[x].event_code_display)), vec
            .retention_days = 0.0, vec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0,
            vec.updt_applctx = reqinfo->updt_applctx, vec.event_code_status_cd = auth_code_value, vec
            .collating_seq = 0.0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into v500_event_code table.")
           GO TO exit_script
          ENDIF
          SET request_cv->cd_value_list[1].action_flag = 1
          SET request_cv->cd_value_list[1].code_set = 93
          IF (isidnenabled=1)
           SET request_cv->cd_value_list[1].description = trim(substring(1,40,request->orderables[x].
             event_code_display))
          ELSE
           SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orderables[x].
             description))
          ENDIF
          IF (isidnenabled=1)
           SET request_cv->cd_value_list[1].definition = trim(substring(1,40,request->orderables[x].
             event_code_display))
          ELSE
           SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orderables[x].
             description))
          ENDIF
          SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orderables[x].
            event_code_display))
          SET request_cv->cd_value_list[1].active_ind = 1
          SET trace = recpersist
          EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
          IF ((reply_cv->status_data.status="S")
           AND (reply_cv->qual[1].code_value > 0))
           SET event_set_code_value = reply_cv->qual[1].code_value
          ELSE
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into codeset 93.")
           GO TO exit_script
          ENDIF
          INSERT  FROM v500_event_set_code ves
           SET ves.accumulation_ind = 1, ves.category_flag = 0, ves.event_set_cd_definition =
            IF (isidnenabled=1) trim(substring(1,40,request->orderables[x].event_code_display))
            ELSE trim(substring(1,100,request->orderables[x].description))
            ENDIF
            ,
            ves.event_set_cd_descr =
            IF (isidnenabled=1) trim(substring(1,40,request->orderables[x].event_code_display))
            ELSE trim(substring(1,60,request->orderables[x].description))
            ENDIF
            , ves.event_set_cd_disp = trim(substring(1,40,request->orderables[x].event_code_display)),
            ves.event_set_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->
                orderables[x].event_code_display)))),
            ves.code_status_cd = active_status_code_value, ves.event_set_cd = event_set_code_value,
            ves.combine_format = " ",
            ves.event_set_color_name = null, ves.event_set_icon_name = null, ves.event_set_name =
            trim(substring(1,40,request->orderables[x].event_code_display)),
            ves.event_set_name_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orderables[x
                ].event_code_display)))), ves.event_set_status_cd = auth_code_value, ves
            .grouping_rule_flag = 0,
            ves.leaf_event_cd_count = 0, ves.operation_display_flag = 0, ves.operation_formula = " ",
            ves.primitive_event_set_count = 0, ves.show_if_no_data_ind = 0, ves.updt_dt_tm =
            cnvtdatetime(curdate,curtime3),
            ves.updt_id = reqinfo->updt_id, ves.updt_task = reqinfo->updt_task, ves.updt_cnt = 0,
            ves.updt_applctx = reqinfo->updt_applctx, ves.display_association_ind = 0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into v500_event_set_code table.")
           GO TO exit_script
          ENDIF
          INSERT  FROM v500_event_set_explode vee
           SET vee.event_cd = event_code_value, vee.event_set_cd = event_set_code_value, vee
            .event_set_status_cd = 0.0,
            vee.event_set_level = 0, vee.updt_dt_tm = cnvtdatetime(curdate,curtime3), vee.updt_id =
            reqinfo->updt_id,
            vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
            updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into v500_event_set_explode table.")
           GO TO exit_script
          ENDIF
          IF (substring(0,8,request->orderables[x].cki)="MUL.MMDC")
           SET parent_cd = diluents_code_value
          ELSE
           SET parent_cd = medication_code_value
          ENDIF
          INSERT  FROM v500_event_set_canon vesc
           SET vesc.parent_event_set_cd = parent_cd, vesc.event_set_cd = event_set_code_value, vesc
            .event_set_collating_seq = 0,
            vesc.event_set_explode_ind = 0, vesc.event_set_status_cd = active_status_code_value, vesc
            .updt_dt_tm = cnvtdatetime(curdate,curtime3),
            vesc.updt_id = reqinfo->updt_id, vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = 0,
            vesc.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
             event_code_display)," into v500_event_set_canon table.")
           GO TO exit_script
          ENDIF
          IF ((request->orderables[x].immunization_ind=1))
           SET im_cnt = size(fin_im_hier->event_hier,5)
           IF (im_cnt <= 0)
            SET im_reseq = 1
            SET med_parse = build("vec.event_set_cd IN (",medication_code_value,",",
             immunization_code_value,")")
            DECLARE im_parse = vc
            SET stat = alterlist(im_hier->event_hier,10)
            SET level = 1
            SET im_hier->event_hier[1].code_value = medication_code_value
            SET im_hier->event_hier[1].level = 1
            SET im_parse = build("vec.event_set_cd IN (",medication_code_value,",",
             immunization_code_value,")")
            SET im_hier->event_hier[2].code_value = immunization_code_value
            SET im_hier->event_hier[2].level = 1
            SET parent_ind = 1
            SET list_cnt = 2
            SET tot_cnt = 2
            WHILE (parent_ind=1)
              SET level = (level+ 1)
              SET parent_ind = 0
              SELECT INTO "nl:"
               FROM v500_event_set_canon vec
               WHERE parser(im_parse)
               HEAD REPORT
                im_parse = "vec.event_set_cd IN (", comma_ind = 0
               DETAIL
                list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
                IF (tot_cnt > 10)
                 stat = alterlist(im_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
                ENDIF
                im_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, im_hier->
                event_hier[list_cnt].level = level
                IF (comma_ind=0)
                 im_parse = build(im_parse,vec.parent_event_set_cd), comma_ind = 1
                ELSE
                 im_parse = build(im_parse,",",vec.parent_event_set_cd)
                ENDIF
                parent_ind = 1
               WITH nocounter
              ;end select
              SET im_parse = concat(im_parse,")")
            ENDWHILE
            SET stat = alterlist(im_hier->event_hier,list_cnt)
            IF (size(im_hier->event_hier,5) > 0)
             SELECT INTO "nl:"
              c = im_hier->event_hier[d.seq].code_value, l = im_hier->event_hier[d.seq].level
              FROM (dummyt d  WITH seq = size(im_hier->event_hier,5))
              PLAN (d)
              ORDER BY c, l DESC
              HEAD REPORT
               list_cnt = 0, tot_cnt = 0, stat = alterlist(fin_im_hier->event_hier,10)
              HEAD c
               list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
               IF (tot_cnt > 10)
                stat = alterlist(fin_im_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
               ENDIF
               fin_im_hier->event_hier[list_cnt].code_value = c, fin_im_hier->event_hier[list_cnt].
               level = l
              FOOT REPORT
               stat = alterlist(fin_im_hier->event_hier,list_cnt)
              WITH nocounter
             ;end select
            ENDIF
           ENDIF
           INSERT  FROM v500_event_set_canon vesc
            SET vesc.parent_event_set_cd = immunization_code_value, vesc.event_set_cd =
             event_set_code_value, vesc.event_set_collating_seq = 0,
             vesc.event_set_explode_ind = 0, vesc.event_set_status_cd = active_status_code_value,
             vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
             vesc.updt_id = reqinfo->updt_id, vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = 0,
             vesc.updt_applctx = reqinfo->updt_applctx
            WITH nocounter
           ;end insert
           IF (curqual=0)
            SET error_flag = "Y"
            SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].
              event_code_display)," into v500_event_set_canon table.")
            GO TO exit_script
           ENDIF
           SET len = size(fin_im_hier->event_hier,5)
           IF (len > 0)
            SET ierrcode = 0
            INSERT  FROM v500_event_set_explode vee,
              (dummyt d  WITH seq = len)
             SET vee.event_cd = event_code_value, vee.event_set_cd = fin_im_hier->event_hier[d.seq].
              code_value, vee.event_set_status_cd = 0.0,
              vee.event_set_level = fin_im_hier->event_hier[d.seq].level, vee.updt_dt_tm =
              cnvtdatetime(curdate,curtime3), vee.updt_id = reqinfo->updt_id,
              vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
              updt_applctx
             PLAN (d)
              JOIN (vee)
             WITH nocounter
            ;end insert
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET error_flag = "Y"
             SET reply->error_msg = concat("Unable to insert into immunization grouper on ",
              "the v500_event_set_explode table: ",serrmsg)
             GO TO exit_script
            ENDIF
           ENDIF
           SELECT INTO "nl:"
            FROM code_value_extension c
            PLAN (c
             WHERE (c.code_value=request->orderables[x].code_value)
              AND c.code_set=200
              AND c.field_name="IMMUNIZATIONIND")
            WITH nocounter
           ;end select
           IF (curqual=0)
            SET ierrcode = 0
            INSERT  FROM code_value_extension c
             SET c.code_value = request->orderables[x].code_value, c.code_set = 200, c.field_name =
              "IMMUNIZATIONIND",
              c.field_type = 1, c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
              c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
              c.updt_applctx = reqinfo->updt_applctx
             WITH nocounter
            ;end insert
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET error_flag = "Y"
             SET reply->status_data.subeventstatus[1].targetobjectname = build(
              "Error on extension insert")
             SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
             GO TO exit_script
            ENDIF
           ELSE
            SET ierrcode = 0
            UPDATE  FROM code_value_extension c
             SET c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
              reqinfo->updt_id,
              c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx =
              reqinfo->updt_applctx
             WHERE (c.code_value=request->orderables[x].code_value)
              AND c.code_set=200
              AND c.field_name="IMMUNIZATIONIND"
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET error_flag = "Y"
             SET reply->status_data.subeventstatus[1].targetobjectname = build(
              "Error on extension update")
             SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
             GO TO exit_script
            ENDIF
           ENDIF
          ELSE
           IF (parent_cd=diluents_code_value)
            SET len = size(fin_dil_hier->event_hier,5)
            IF (len > 0)
             SET ierrcode = 0
             INSERT  FROM v500_event_set_explode vee,
               (dummyt d  WITH seq = len)
              SET vee.event_cd = event_code_value, vee.event_set_cd = fin_dil_hier->event_hier[d.seq]
               .code_value, vee.event_set_status_cd = 0.0,
               vee.event_set_level = fin_dil_hier->event_hier[d.seq].level, vee.updt_dt_tm =
               cnvtdatetime(curdate,curtime3), vee.updt_id = reqinfo->updt_id,
               vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
               updt_applctx
              PLAN (d)
               JOIN (vee)
              WITH nocounter
             ;end insert
             SET ierrcode = error(serrmsg,1)
             IF (ierrcode > 0)
              SET error_flag = "Y"
              SET reply->error_msg = concat("Unable to insert into medication grouper on ",
               "the v500_event_set_explode table: ",serrmsg)
              GO TO exit_script
             ENDIF
            ENDIF
           ELSE
            SET len = size(fin_med_hier->event_hier,5)
            IF (len > 0)
             SET ierrcode = 0
             INSERT  FROM v500_event_set_explode vee,
               (dummyt d  WITH seq = len)
              SET vee.event_cd = event_code_value, vee.event_set_cd = fin_med_hier->event_hier[d.seq]
               .code_value, vee.event_set_status_cd = 0.0,
               vee.event_set_level = fin_med_hier->event_hier[d.seq].level, vee.updt_dt_tm =
               cnvtdatetime(curdate,curtime3), vee.updt_id = reqinfo->updt_id,
               vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
               updt_applctx
              PLAN (d)
               JOIN (vee)
              WITH nocounter
             ;end insert
             SET ierrcode = error(serrmsg,1)
             IF (ierrcode > 0)
              SET error_flag = "Y"
              SET reply->error_msg = concat("Unable to insert into medication grouper on ",
               "the v500_event_set_explode table: ",serrmsg)
              GO TO exit_script
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        SET br_print_req_ind = 0
        IF ((((request->orderables[x].req_format_code_value > 0)) OR ((request->orderables[x].
        req_routing_id > 0))) )
         SET br_print_req_ind = 1
        ENDIF
        SET dcp_clin_cat_code_value = default_client_code_value
        IF (validate(request->orderables[x].dcp_clin_cat_mean))
         SET dcp_clin_cat_code_value = uar_get_code_by("MEANING",16389,request->orderables[x].
          dcp_clin_cat_mean)
         IF ((dcp_clin_cat_code_value=- (1)))
          SET dcp_clin_cat_code_value = default_client_code_value
         ENDIF
        ENDIF
        INSERT  FROM order_catalog oc
         SET oc.catalog_cd = request->orderables[x].code_value, oc.abn_review_ind = null, oc
          .activity_type_cd = activity_type_code_value,
          oc.resource_route_lvl = null, oc.active_ind = 1, oc.prompt_ind = null,
          oc.catalog_type_cd = catalog_type_code_value, oc.requisition_format_cd = request->
          orderables[x].req_format_code_value, oc.requisition_routing_cd = request->orderables[x].
          req_routing_id,
          oc.description = request->orderables[x].description, oc.print_req_ind = br_print_req_ind,
          oc.oe_format_id = request->orderables[x].synonyms[y].order_entry_format_id,
          oc.prep_info_flag = null, oc.cont_order_method_flag = 2, oc.primary_mnemonic = request->
          orderables[x].synonyms[y].mnemonic,
          oc.dept_display_name = request->orderables[x].description, oc.ref_text_mask = 64, oc
          .source_vocab_ident = null,
          oc.source_vocab_mean = null, oc.dcp_clin_cat_cd = dcp_clin_cat_code_value, oc.cki = request
          ->orderables[x].cki,
          oc.concept_cki = request->orderables[x].concept_cki, oc.consent_form_ind = 0, oc
          .inst_restriction_ind = 0,
          oc.schedule_ind = 0, oc.orderable_type_flag = 0, oc.quick_chart_ind = 0,
          oc.auto_cancel_ind = request->orderables[x].auto_cancel_ind, oc.complete_upon_order_ind =
          request->orderables[x].complete_upon_order_ind, oc.comment_template_flag = 0,
          oc.dup_checking_ind = 0, oc.bill_only_ind = request->orderables[x].bill_only_ind, oc
          .disable_order_comment_ind = request->orderables[x].disable_order_comment_ind,
          oc.form_level = 0, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->
          updt_id,
          oc.updt_task = reqinfo->updt_task, oc.updt_cnt = 0, oc.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].description),
          " into the order catalog table.")
         GO TO exit_script
        ENDIF
        IF (validate(request->orderables[x].task_ind))
         IF ((request->orderables[x].task_ind=1)
          AND task_template_ind=1)
          SET new_ref_id = 0.0
          SELECT INTO "NL:"
           j = seq(reference_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            new_ref_id = cnvtreal(j)
           WITH format, counter
          ;end select
          SET ierrcode = 0
          INSERT  FROM order_task ot
           SET ot.reference_task_id = new_ref_id, ot.task_description = request->orderables[x].
            synonyms[y].mnemonic, ot.task_description_key = cnvtupper(request->orderables[x].
             synonyms[y].mnemonic),
            ot.task_activity_cd = task_activity_code_value, ot.active_ind = qb_params->active_ind, ot
            .chart_not_cmplt_ind = qb_params->chart_not_cmplt_ind,
            ot.task_type_cd = qb_params->task_type_cd, ot.quick_chart_done_ind = qb_params->
            quick_chart_done_ind, ot.quick_chart_notdone_ind = qb_params->quick_chart_notdone_ind,
            ot.retain_time = qb_params->retain_time, ot.retain_units = qb_params->retain_units, ot
            .overdue_min = qb_params->overdue_min,
            ot.allpositionchart_ind = qb_params->allpositionchart_ind, ot.reschedule_time = qb_params
            ->reschedule_time, ot.cernertask_flag = 0,
            ot.quick_chart_ind = qb_params->quick_chart_ind, ot.overdue_units = qb_params->
            overdue_units, ot.event_cd = 0,
            ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot
            .updt_task = reqinfo->updt_task,
            ot.updt_cnt = 0, ot.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET error_flag = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
          SET ierrcode = 0
          INSERT  FROM order_task_xref otx
           SET otx.reference_task_id = new_ref_id, otx.catalog_cd = request->orderables[x].code_value,
            otx.order_task_seq = seq(reference_seq,nextval),
            otx.order_task_type_flag = 0, otx.primary_task_ind = 1, otx.updt_dt_tm = cnvtdatetime(
             curdate,curtime3),
            otx.updt_id = reqinfo->updt_id, otx.updt_task = reqinfo->updt_task, otx.updt_cnt = 0,
            otx.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET error_flag = "Y"
           SET reply->error_msg = serrmsg
           GO TO exit_script
          ENDIF
          IF ((qb_params->allpositionchart_ind=0)
           AND qb_pos_cnt > 0)
           SET ierrcode = 0
           INSERT  FROM order_task_position_xref otp,
             (dummyt d  WITH seq = value(qb_pos_cnt))
            SET otp.seq = 1, otp.reference_task_id = new_ref_id, otp.position_cd = qb_params->
             qual_pos[d.seq].position_cd,
             otp.updt_dt_tm = cnvtdatetime(curdate,curtime3), otp.updt_id = reqinfo->updt_id, otp
             .updt_task = reqinfo->updt_task,
             otp.updt_cnt = 0, otp.updt_applctx = reqinfo->updt_applctx
            PLAN (d)
             JOIN (otp)
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET error_flag = "Y"
            SET reply->error_msg = serrmsg
            GO TO exit_script
           ENDIF
          ENDIF
          SELECT INTO "NL:"
           j = seq(bill_item_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            bill_id = cnvtreal(j)
           WITH format, counter
          ;end select
          INSERT  FROM bill_item b
           SET b.bill_item_id = bill_id, b.ext_parent_reference_id = new_ref_id, b
            .ext_parent_contributor_cd = task_contributor_code_value,
            b.ext_description = request->orderables[x].synonyms[y].mnemonic, b.ext_owner_cd =
            task_activity_type_code_value, b.parent_qual_cd = 1,
            b.active_ind = 1, b.ext_short_desc = cnvtupper(substring(0,50,request->orderables[x].
              synonyms[y].mnemonic)), b.ext_parent_entity_name = "CODE_VALUE",
            b.ext_child_entity_name = null, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b
            .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
            b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(
             curdate,curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
            b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(
             curdate,curtime3),
            b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert task row for ",trim(request->orderables[x]
             .synonyms[y].mnemonic)," into the bill_item table.")
           GO TO exit_script
          ENDIF
          SELECT INTO "NL:"
           j = seq(bill_item_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            bill_id = cnvtreal(j)
           WITH format, counter
          ;end select
          INSERT  FROM bill_item b
           SET b.bill_item_id = bill_id, b.ext_parent_reference_id = request->orderables[x].
            code_value, b.ext_parent_contributor_cd = parent_contributor_code_value,
            b.ext_child_reference_id = new_ref_id, b.ext_child_contributor_cd =
            task_contributor_code_value, b.ext_description = request->orderables[x].synonyms[y].
            mnemonic,
            b.ext_owner_cd = activity_type_code_value, b.parent_qual_cd = 1, b.active_ind = 1,
            b.ext_short_desc = cnvtupper(substring(0,50,request->orderables[x].synonyms[y].mnemonic)),
            b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name = "ORDER_TASK",
            b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm =
            cnvtdatetime("31-DEC-2100"), b.active_status_cd = active_status_code_value,
            b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id =
            reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx,
            b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
            updt_id,
            b.updt_task = reqinfo->updt_task
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET reply->error_msg = concat("Unable to insert relationship row for ",trim(request->
             orderables[x].synonyms[y].mnemonic)," into the bill_item table.")
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
        IF ((request->orderables[x].event_code_display > " ")
         AND dup_event_ind=0)
         INSERT  FROM code_value_event_r cr
          SET cr.event_cd = event_code_value, cr.parent_cd = request->orderables[x].code_value, cr
           .flex1_cd = 0,
           cr.flex2_cd = 0, cr.flex3_cd = 0, cr.flex4_cd = 0,
           cr.flex5_cd = 0, cr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cr.updt_id = reqinfo->
           updt_id,
           cr.updt_task = reqinfo->updt_task, cr.updt_cnt = 0, cr.updt_applctx = reqinfo->
           updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].description),
           " into the code_value_event_r table.")
          GO TO exit_script
         ENDIF
        ENDIF
        SELECT INTO "NL:"
         j = seq(bill_item_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          bill_id = cnvtreal(j)
         WITH format, counter
        ;end select
        SET task_created_ind = 0
        IF (validate(request->orderables[x].task_ind))
         IF ((request->orderables[x].task_ind=1)
          AND task_template_ind=1)
          SET task_created_ind = 1
         ENDIF
        ENDIF
        INSERT  FROM bill_item b
         SET b.bill_item_id = bill_id, b.ext_parent_reference_id = request->orderables[x].code_value,
          b.ext_parent_contributor_cd = parent_contributor_code_value,
          b.ext_description = request->orderables[x].description, b.ext_owner_cd =
          activity_type_code_value, b.parent_qual_cd = 1,
          b.active_ind = 1, b.active_status_cd = active_status_code_value, b.ext_short_desc =
          substring(0,50,request->orderables[x].description),
          b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name =
          IF (task_created_ind=0) null
          ELSE "NOMENCLATURE"
          ENDIF
          , b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.active_status_cd =
          active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          b.active_status_prsnl_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b
          .updt_cnt = 0,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to insert ",trim(request->orderables[x].description),
          " into the bill_item table.")
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET cosign_cnt = size(request->orderables[x].cosignatures,5)
   IF (cosign_cnt > 0)
    FOR (y = 1 TO cosign_cnt)
      SET nurse_flag = 0
      IF (validate(request->orderables[x].cosignatures[y].nurse_verify_flag))
       SET nurse_flag = request->orderables[x].cosignatures[y].nurse_verify_flag
      ENDIF
      SET pharm_flag = 0
      IF (validate(request->orderables[x].cosignatures[y].pharm_verify_flag))
       SET pharm_flag = request->orderables[x].cosignatures[y].pharm_verify_flag
      ENDIF
      IF ((((request->orderables[x].cosignatures[y].cosign_flag > 0)) OR ((((request->orderables[x].
      cosignatures[y].nurse_verify_flag > 0)) OR ((request->orderables[x].cosignatures[y].
      pharm_verify_flag > 0))) )) )
       INSERT  FROM order_catalog_review ocr
        SET ocr.catalog_cd = request->orderables[x].code_value, ocr.action_type_cd = request->
         orderables[x].cosignatures[y].action_code_value, ocr.doctor_cosign_flag = request->
         orderables[x].cosignatures[y].cosign_flag,
         ocr.nurse_review_flag = nurse_flag, ocr.review_required_ind = 0, ocr.rx_verify_flag =
         pharm_flag,
         ocr.updt_applctx = reqinfo->updt_applctx, ocr.updt_cnt = 0, ocr.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         ocr.updt_id = reqinfo->updt_id, ocr.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to assign doctor cosignature to orderable: ",trim(
          cnvtstring(request->orderables[x].code_value)))
        GO TO exit_script
       ENDIF
       SET rev_upd_ind = 1
       SELECT INTO "nl:"
        FROM order_catalog oc
        PLAN (oc
         WHERE (oc.catalog_cd=request->orderables[x].code_value)
          AND oc.order_review_ind=1)
        DETAIL
         rev_upd_ind = 0
        WITH nocounter
       ;end select
       IF (rev_upd_ind=1)
        UPDATE  FROM order_catalog oc
         SET oc.order_review_ind = 1, oc.orderable_type_flag = 0, oc.updt_applctx = reqinfo->
          updt_applctx,
          oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id
           = reqinfo->updt_id,
          oc.updt_task = reqinfo->updt_task
         WHERE (oc.catalog_cd=request->orderables[x].code_value)
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET synonym_cnt = size(request->orderables[x].synonyms,5)
   SET stat = alterlist(reply->orderables[x].synonyms,synonym_cnt)
   SET reply->orderables[x].code_value = request->orderables[x].code_value
   SET reply->orderables[x].dup_event_ind = dup_event_ind
   SET dcp_clin_cat_code_value = default_client_code_value
   IF (validate(request->orderables[x].dcp_clin_cat_mean))
    SET dcp_clin_cat_code_value = uar_get_code_by("MEANING",16389,request->orderables[x].
     dcp_clin_cat_mean)
    IF ((dcp_clin_cat_code_value=- (1)))
     SET dcp_clin_cat_code_value = default_client_code_value
    ENDIF
   ENDIF
   IF (synonym_cnt > 0)
    FOR (y = 1 TO synonym_cnt)
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        order_synonym_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM order_catalog_synonym ocs
       SET ocs.synonym_id = order_synonym_id, ocs.catalog_cd = request->orderables[x].code_value, ocs
        .catalog_type_cd = catalog_type_code_value,
        ocs.mnemonic = request->orderables[x].synonyms[y].mnemonic, ocs.mnemonic_key_cap = cnvtupper(
         request->orderables[x].synonyms[y].mnemonic), ocs.mnemonic_type_cd = request->orderables[x].
        synonyms[y].mnemonic_type_code_value,
        ocs.oe_format_id = request->orderables[x].synonyms[y].order_entry_format_id, ocs.active_ind
         = 1, ocs.activity_type_cd = activity_type_code_value,
        ocs.orderable_type_flag = 0, ocs.concentration_strength = 0, ocs.concentration_volume = 0,
        ocs.active_status_cd = active_status_code_value, ocs.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), ocs.active_status_prsnl_id = reqinfo->updt_id,
        ocs.ref_text_mask = 64, ocs.multiple_ord_sent_ind = null, ocs.hide_flag = request->
        orderables[x].synonyms[y].hide_ind,
        ocs.rx_mask = request->orderables[x].synonyms[y].med_admin_mask, ocs.dcp_clin_cat_cd =
        dcp_clin_cat_code_value, ocs.filtered_od_ind = null,
        ocs.cki = request->orderables[x].synonyms[y].cki, ocs.mnemonic_key_cap_nls = null, ocs
        .virtual_view = cnvtstring(1111111111),
        ocs.health_plan_view = " ", ocs.concept_cki = request->orderables[x].synonyms[y].concept_cki,
        ocs.updt_applctx = reqinfo->updt_applctx,
        ocs.updt_cnt = 0, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->
        updt_id,
        ocs.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Unable to update order synonym: ",trim(request->orderables[x].
         synonyms[y].mnemonic)," on the order_catalog_synonym table")
       GO TO exit_script
      ENDIF
      DELETE  FROM br_name_value b
       WHERE b.br_nv_key1="MLTM_IGN_CONTENT"
        AND b.br_name="MLTM_ORDER_CATALOG_LOAD"
        AND b.br_value=trim(request->orderables[x].synonyms[y].cki)
       WITH nocounter
      ;end delete
      SET reply->orderables[x].synonyms[y].synonym_id = order_synonym_id
    ENDFOR
   ENDIF
   SET privilege_cnt = size(request->orderables[x].privileges,5)
   IF (privilege_cnt > 0)
    FOR (y = 1 TO privilege_cnt)
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        privilege_exception_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM privilege_exception pe
       SET pe.privilege_id = request->orderables[x].privileges[y].privilege_id, pe
        .privilege_exception_id = privilege_exception_id, pe.exception_id = request->orderables[x].
        code_value,
        pe.exception_entity_name = "ORDER CATALOG", pe.exception_type_cd = exception_type_code_value,
        pe.event_set_name = " ",
        pe.active_ind = 1, pe.active_status_cd = 0.0, pe.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3),
        pe.active_status_prsnl_id = reqinfo->updt_id, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        pe.updt_id = reqinfo->updt_id,
        pe.updt_task = reqinfo->updt_task, pe.updt_cnt = 0, pe.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Unable to insert exception_id = ",cnvtstring(request->
         orderables[x].code_value)," into table privilege_exception.")
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   DECLARE multi_pharm_cd = f8
   IF (oc_multi_pharmacy_review_table_exists)
    IF (validate(request->orderables[x].qual_multi_pharmacy_review)=1)
     IF (size(request->orderables[x].qual_multi_pharmacy_review,5) > 0)
      FOR (m = 1 TO size(request->orderables[x].qual_multi_pharmacy_review,5))
        SELECT INTO "NL:"
         j = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          multi_pharm_cd = cnvtreal(j)
         WITH format, counter
        ;end select
        CALL echo(build("CV = ",multi_pharm_cd))
        IF (validate(request->orderables[x].qual_multi_pharmacy_review[m].
         eligible_multi_pharm_rev_ind,0)=1)
         CALL echo(build("Inside insert",size(request->orderables[x].qual_multi_pharmacy_review,5)))
         INSERT  FROM oc_multi_pharmacy_review ompr
          SET ompr.multiple_pharmacy_review_ind = request->orderables[x].qual_multi_pharmacy_review[m
           ].eligible_multi_pharm_rev_ind, ompr.catalog_cd = request->orderables[x].code_value, ompr
           .oc_multi_pharmacy_review_id = multi_pharm_cd,
           ompr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ompr.updt_id = reqinfo->updt_id, ompr
           .updt_task = reqinfo->updt_task,
           ompr.updt_applctx = reqinfo->updt_applctx, ompr.updt_cnt = 0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET reply->error_msg = concat("Unable to insert exception_id = ",cnvtstring(request->
            orderables[x].code_value)," into table oc_multi_pharmacy_review.")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (med_reseq > 0
  AND add_events_ind=1)
  SELECT INTO "nl:"
   FROM v500_event_set_canon vesc,
    code_value cv
   PLAN (vesc
    WHERE vesc.parent_event_set_cd=medication_code_value)
    JOIN (cv
    WHERE cv.code_value=vesc.event_set_cd)
   ORDER BY cv.display_key
   HEAD REPORT
    list_cnt = 0, tot_cnt = 0, stat = alterlist(temp_seq->event_sets,100)
   DETAIL
    list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 100)
     stat = alterlist(temp_seq->event_sets,(list_cnt+ 100)), tot_cnt = 1
    ENDIF
    temp_seq->event_sets[list_cnt].code_value = vesc.event_set_cd
   FOOT REPORT
    stat = alterlist(temp_seq->event_sets,list_cnt)
   WITH nocounter
  ;end select
  IF (list_cnt > 0)
   SET ierrcode = 0
   UPDATE  FROM v500_event_set_canon vesc,
     (dummyt d  WITH seq = list_cnt)
    SET vesc.event_set_collating_seq = d.seq, vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3), vesc
     .updt_id = reqinfo->updt_id,
     vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = (vesc.updt_cnt+ 1), vesc.updt_applctx =
     reqinfo->updt_applctx
    PLAN (d)
     JOIN (vesc
     WHERE vesc.parent_event_set_cd=medication_code_value
      AND (vesc.event_set_cd=temp_seq->event_sets[d.seq].code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to re-sequence medication grouper on ",
     "the v500_event_set_cannon table: ",serrmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (im_reseq > 0
  AND add_events_ind=1)
  SELECT INTO "nl:"
   FROM v500_event_set_canon vesc,
    code_value cv
   PLAN (vesc
    WHERE vesc.parent_event_set_cd=immunization_code_value)
    JOIN (cv
    WHERE cv.code_value=vesc.event_set_cd)
   ORDER BY cv.display_key
   HEAD REPORT
    list_cnt = 0, tot_cnt = 0, stat = alterlist(temp_seq->event_sets,100)
   DETAIL
    list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 100)
     stat = alterlist(temp_seq->event_sets,(list_cnt+ 100)), tot_cnt = 1
    ENDIF
    temp_seq->event_sets[list_cnt].code_value = vesc.event_set_cd
   FOOT REPORT
    stat = alterlist(temp_seq->event_sets,list_cnt)
   WITH nocounter
  ;end select
  IF (list_cnt > 0)
   SET ierrcode = 0
   UPDATE  FROM v500_event_set_canon vesc,
     (dummyt d  WITH seq = list_cnt)
    SET vesc.event_set_collating_seq = d.seq, vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3), vesc
     .updt_id = reqinfo->updt_id,
     vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = (vesc.updt_cnt+ 1), vesc.updt_applctx =
     reqinfo->updt_applctx
    PLAN (d)
     JOIN (vesc
     WHERE vesc.parent_event_set_cd=immunization_code_value
      AND (vesc.event_set_cd=temp_seq->event_sets[d.seq].code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to re-sequence immunization grouper on ",
     "the v500_event_set_cannon table: ",serrmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (dil_reseq > 0
  AND add_events_ind=1)
  SELECT INTO "nl:"
   FROM v500_event_set_canon vesc,
    code_value cv
   PLAN (vesc
    WHERE vesc.parent_event_set_cd=diluents_code_value)
    JOIN (cv
    WHERE cv.code_value=vesc.event_set_cd)
   ORDER BY cv.display_key
   HEAD REPORT
    list_cnt = 0, tot_cnt = 0, stat = alterlist(temp_seq->event_sets,100)
   DETAIL
    list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 100)
     stat = alterlist(temp_seq->event_sets,(list_cnt+ 100)), tot_cnt = 1
    ENDIF
    temp_seq->event_sets[list_cnt].code_value = vesc.event_set_cd
   FOOT REPORT
    stat = alterlist(temp_seq->event_sets,list_cnt)
   WITH nocounter
  ;end select
  IF (list_cnt > 0)
   SET ierrcode = 0
   UPDATE  FROM v500_event_set_canon vesc,
     (dummyt d  WITH seq = list_cnt)
    SET vesc.event_set_collating_seq = d.seq, vesc.updt_dt_tm = cnvtdatetime(curdate,curtime3), vesc
     .updt_id = reqinfo->updt_id,
     vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = (vesc.updt_cnt+ 1), vesc.updt_applctx =
     reqinfo->updt_applctx
    PLAN (d)
     JOIN (vesc
     WHERE vesc.parent_event_set_cd=diluents_code_value
      AND (vesc.event_set_cd=temp_seq->event_sets[d.seq].code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to re-sequence diluent grouper on ",
     "the v500_event_set_cannon table: ",serrmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (validate(request->existing_ords_add_tasks[1].code_value))
  SET exist_cnt = size(request->existing_ords_add_tasks,5)
  IF (exist_cnt > 0
   AND task_template_ind=1)
   FOR (x = 1 TO exist_cnt)
     SET new_ref_id = 0.0
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_ref_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET ierrcode = 0
     INSERT  FROM order_task ot
      SET ot.reference_task_id = new_ref_id, ot.task_description = request->existing_ords_add_tasks[x
       ].primary_mnemonic, ot.task_description_key = cnvtupper(request->existing_ords_add_tasks[x].
        primary_mnemonic),
       ot.task_activity_cd = task_activity_code_value, ot.active_ind = qb_params->active_ind, ot
       .chart_not_cmplt_ind = qb_params->chart_not_cmplt_ind,
       ot.task_type_cd = qb_params->task_type_cd, ot.quick_chart_done_ind = qb_params->
       quick_chart_done_ind, ot.quick_chart_notdone_ind = qb_params->quick_chart_notdone_ind,
       ot.retain_time = qb_params->retain_time, ot.retain_units = qb_params->retain_units, ot
       .overdue_min = qb_params->overdue_min,
       ot.allpositionchart_ind = qb_params->allpositionchart_ind, ot.reschedule_time = qb_params->
       reschedule_time, ot.cernertask_flag = 0,
       ot.quick_chart_ind = qb_params->quick_chart_ind, ot.overdue_units = qb_params->overdue_units,
       ot.event_cd = 0,
       ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task =
       reqinfo->updt_task,
       ot.updt_cnt = 0, ot.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     INSERT  FROM order_task_xref otx
      SET otx.reference_task_id = new_ref_id, otx.catalog_cd = request->existing_ords_add_tasks[x].
       code_value, otx.order_task_seq = seq(reference_seq,nextval),
       otx.order_task_type_flag = 0, otx.primary_task_ind = 1, otx.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       otx.updt_id = reqinfo->updt_id, otx.updt_task = reqinfo->updt_task, otx.updt_cnt = 0,
       otx.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
     IF ((qb_params->allpositionchart_ind=0)
      AND qb_pos_cnt > 0)
      SET ierrcode = 0
      INSERT  FROM order_task_position_xref otp,
        (dummyt d  WITH seq = value(qb_pos_cnt))
       SET otp.seq = 1, otp.reference_task_id = new_ref_id, otp.position_cd = qb_params->qual_pos[d
        .seq].position_cd,
        otp.updt_dt_tm = cnvtdatetime(curdate,curtime3), otp.updt_id = reqinfo->updt_id, otp
        .updt_task = reqinfo->updt_task,
        otp.updt_cnt = 0, otp.updt_applctx = reqinfo->updt_applctx
       PLAN (d)
        JOIN (otp)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      j = seq(bill_item_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       bill_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM bill_item b
      SET b.bill_item_id = bill_id, b.ext_parent_reference_id = new_ref_id, b
       .ext_parent_contributor_cd = task_contributor_code_value,
       b.ext_description = request->existing_ords_add_tasks[x].primary_mnemonic, b.ext_owner_cd =
       task_activity_type_code_value, b.parent_qual_cd = 1,
       b.active_ind = 1, b.ext_short_desc = cnvtupper(substring(0,50,request->
         existing_ords_add_tasks[x].primary_mnemonic)), b.ext_parent_entity_name = "CODE_VALUE",
       b.ext_child_entity_name = null, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       b.active_status_cd = active_status_code_value, b.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->error_msg = concat("Unable to insert task row for ",trim(request->
        existing_ords_add_tasks[x].primary_mnemonic)," into the bill_item table.")
      GO TO exit_script
     ENDIF
     SELECT INTO "NL:"
      j = seq(bill_item_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       bill_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM bill_item b
      SET b.bill_item_id = bill_id, b.ext_parent_reference_id = request->existing_ords_add_tasks[x].
       code_value, b.ext_parent_contributor_cd = parent_contributor_code_value,
       b.ext_child_reference_id = new_ref_id, b.ext_child_contributor_cd =
       task_contributor_code_value, b.ext_description = request->existing_ords_add_tasks[x].
       primary_mnemonic,
       b.ext_owner_cd = activity_type_code_value, b.parent_qual_cd = 1, b.active_ind = 1,
       b.ext_short_desc = cnvtupper(substring(0,50,request->existing_ords_add_tasks[x].
         primary_mnemonic)), b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_entity_name =
       "ORDER_TASK",
       b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), b.active_status_cd = active_status_code_value,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.updt_applctx = reqinfo->updt_applctx,
       b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->error_msg = concat("Unable to insert relationship row for ",trim(request->
        existing_ords_add_tasks[x].primary_mnemonic)," into the bill_item table.")
      GO TO exit_script
     ENDIF
     UPDATE  FROM bill_item b
      SET b.ext_child_entity_name = "NOMENCLATURE", b.updt_applctx = reqinfo->updt_applctx, b
       .updt_cnt = (b.updt_cnt+ 1),
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task
      WHERE (b.ext_parent_reference_id=request->existing_ords_add_tasks[x].code_value)
       AND b.ext_parent_contributor_cd=parent_contributor_code_value
       AND b.ext_child_reference_id=0
       AND b.ext_child_contributor_cd=0
       AND (b.ext_description=request->existing_ords_add_tasks[x].primary_mnemonic)
      WITH nocounter
     ;end update
     DELETE  FROM br_name_value b
      WHERE b.br_nv_key1="MLTM_IGN_ORDS"
       AND b.br_name="ORDER_CATALOG"
       AND (cnvtreal(trim(b.br_value))=request->existing_ords_add_tasks[x].code_value)
      WITH nocounter
     ;end delete
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
