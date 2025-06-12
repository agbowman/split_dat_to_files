CREATE PROGRAM bed_ens_pharm_ords_wo_ec:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_rep
 RECORD temp_rep(
   1 orders[*]
     2 dnum = vc
 )
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
 FREE SET temp_seq
 RECORD temp_seq(
   1 event_sets[*]
     2 code_value = f8
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
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE cat_parse_txt = vc
 SET med_reseq = 0
 SET im_reseq = 0
 SET dil_reseq = 0.0
 SET pharmacy_ct_code_value = 0.0
 SET primary_code_value = 0.0
 SET active_status_code_value = 0.0
 SET auth_code_value = 0.0
 SET def_frmt_code_value = 0.0
 SET def_store_code_value = 0.0
 SET def_class_code_value = 0.0
 SET def_confid_lvl_code_value = 0.0
 SET subclass_code_value = 0.0
 SET medication_code_value = 0.0
 SET immunization_code_value = 0.0
 SET diluents_code_value = 0.0
 SET ocfset_code_value = 0.0
 SET add_immunization_ind = 0
 SET req_cnt = 0
 SET parent_cd = 0.0
 SET pharmacy_ct_code_value = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET active_status_code_value = uar_get_code_by("MEANING",48,"ACTIVE")
 SET auth_code_value = uar_get_code_by("MEANING",8,"AUTH")
 SET def_frmt_code_value = uar_get_code_by("MEANING",23,"UNKNOWN")
 SET def_store_code_value = uar_get_code_by("MEANING",25,"UNKNOWN")
 SET def_class_code_value = uar_get_code_by("MEANING",53,"MED")
 SET def_confid_lvl_code_value = uar_get_code_by("MEANING",87,"ROUTCLINICAL")
 SET subclass_code_value = uar_get_code_by("MEANING",102,"UNKNOWN")
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
 IF (validate(request->diluent_event_set_code_value)=0)
  SELECT INTO "nl:"
   FROM v500_event_set_code v
   WHERE v.event_set_name_key="DILUENTS"
    AND trim(cnvtupper(v.event_set_name))="DILUENTS"
   DETAIL
    diluents_code_value = v.event_set_cd
   WITH nocounter
  ;end select
 ELSE
  SET diluents_code_value = request->diluent_event_set_code_value
 ENDIF
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="ALLOCFSETS"
   AND trim(cnvtupper(v.event_set_name))="ALLOCFSETS"
  DETAIL
   ocfset_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 SET req_cnt = size(request->orders,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->orders,req_cnt)
 FOR (x = 1 TO req_cnt)
  SET reply->orders[x].catalog_code_value = request->orders[x].catalog_code_value
  IF ((request->orders[x].immunization_ind=1))
   SET add_immunization_ind = 1
  ENDIF
 ENDFOR
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
     med_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, med_hier->event_hier[
     list_cnt].level = level
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
    fin_med_hier->event_hier[list_cnt].code_value = c, fin_med_hier->event_hier[list_cnt].level = l
   FOOT REPORT
    stat = alterlist(fin_med_hier->event_hier,list_cnt)
   WITH nocounter
  ;end select
 ENDIF
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
     dil_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, dil_hier->event_hier[
     list_cnt].level = level
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
    fin_dil_hier->event_hier[list_cnt].code_value = c, fin_dil_hier->event_hier[list_cnt].level = l
   FOOT REPORT
    stat = alterlist(fin_dil_hier->event_hier,list_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (add_immunization_ind=1)
  DECLARE im_parse = vc
  SET stat = alterlist(im_hier->event_hier,10)
  SET level = 1
  SET im_hier->event_hier[1].code_value = medication_code_value
  SET im_hier->event_hier[1].level = 1
  SET im_parse = build("vec.event_set_cd IN (",medication_code_value,",",immunization_code_value,")")
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
      im_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, im_hier->event_hier[
      list_cnt].level = level
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
     fin_im_hier->event_hier[list_cnt].code_value = c, fin_im_hier->event_hier[list_cnt].level = l
    FOOT REPORT
     stat = alterlist(fin_im_hier->event_hier,list_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (x = 1 TO req_cnt)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=72
      AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display)))))
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=93
      AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display)))))
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    PLAN (v
     WHERE v.event_set_name_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display))))
      AND trim(cnvtupper(v.event_set_name))=trim(cnvtupper(substring(1,40,request->orders[x].
        event_code_display))))
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   IF ((reply->orders[x].duplicate_ind=0))
    SET med_reseq = 1
    SET dil_reseq = 1
    SET event_code_value = 0.0
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 72
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orders[x].
      event_code_display))
    IF (isidnenabled=1)
     SET request_cv->cd_value_list[1].description = trim(substring(1,40,request->orders[x].
       event_code_display))
     SET request_cv->cd_value_list[1].definition = trim(substring(1,40,request->orders[x].
       event_code_display))
    ELSE
     SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orders[x].
       description))
     SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orders[x].
       description))
    ENDIF
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET event_code_value = reply_cv->qual[1].code_value
    ELSE
     CALL echorecord(reply_cv)
     CALL echo(trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].event_code_display)))))
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on cs 72 insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->orders[x].
     event_code_display
     GO TO exit_script
    ENDIF
    INSERT  FROM v500_event_code vec
     SET vec.event_cd = event_code_value, vec.event_cd_definition =
      IF (isidnenabled=1) trim(substring(1,40,request->orders[x].event_code_display))
      ELSE trim(substring(1,100,request->orders[x].description))
      ENDIF
      , vec.event_cd_descr =
      IF (isidnenabled=1) trim(substring(1,40,request->orders[x].event_code_display))
      ELSE trim(substring(1,60,request->orders[x].description))
      ENDIF
      ,
      vec.event_cd_disp = trim(substring(1,40,request->orders[x].event_code_display)), vec
      .event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
          event_code_display)))), vec.code_status_cd = active_status_code_value,
      vec.def_docmnt_attributes = " ", vec.def_docmnt_format_cd = def_frmt_code_value, vec
      .def_docmnt_storage_cd = def_store_code_value,
      vec.def_event_class_cd = def_class_code_value, vec.def_event_confid_level_cd =
      def_confid_lvl_code_value, vec.def_event_level = 0.0,
      vec.event_add_access_ind = 0.0, vec.event_cd_subclass_cd = subclass_code_value, vec
      .event_chg_access_ind = 1,
      vec.event_set_name = trim(substring(1,40,request->orders[x].event_code_display)), vec
      .retention_days = 0.0, vec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0,
      vec.updt_applctx = reqinfo->updt_applctx, vec.event_code_status_cd = auth_code_value, vec
      .collating_seq = 0.0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Error on v500_event_code insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET event_set_code_value = 0.0
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 93
    IF (isidnenabled=1)
     SET request_cv->cd_value_list[1].description = trim(substring(1,40,request->orders[x].
       event_code_display))
     SET request_cv->cd_value_list[1].definition = trim(substring(1,40,request->orders[x].
       event_code_display))
    ELSE
     SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orders[x].
       description))
     SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orders[x].
       description))
    ENDIF
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET event_set_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on cs 93 insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    INSERT  FROM v500_event_set_code ves
     SET ves.accumulation_ind = 1, ves.category_flag = 0, ves.event_set_cd_definition =
      IF (isidnenabled=1) trim(substring(1,40,request->orders[x].event_code_display))
      ELSE trim(substring(1,100,request->orders[x].description))
      ENDIF
      ,
      ves.event_set_cd_descr =
      IF (isidnenabled=1) trim(substring(1,40,request->orders[x].event_code_display))
      ELSE trim(substring(1,60,request->orders[x].description))
      ENDIF
      , ves.event_set_cd_disp = trim(substring(1,40,request->orders[x].event_code_display)), ves
      .event_set_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
          event_code_display)))),
      ves.code_status_cd = active_status_code_value, ves.event_set_cd = event_set_code_value, ves
      .combine_format = " ",
      ves.event_set_color_name = null, ves.event_set_icon_name = null, ves.event_set_name = trim(
       substring(1,40,request->orders[x].event_code_display)),
      ves.event_set_name_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
          event_code_display)))), ves.event_set_status_cd = auth_code_value, ves.grouping_rule_flag
       = 0,
      ves.leaf_event_cd_count = 0, ves.operation_display_flag = 0, ves.operation_formula = " ",
      ves.primitive_event_set_count = 0, ves.show_if_no_data_ind = 0, ves.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      ves.updt_id = reqinfo->updt_id, ves.updt_task = reqinfo->updt_task, ves.updt_cnt = 0,
      ves.updt_applctx = reqinfo->updt_applctx, ves.display_association_ind = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Error on v500_event_set_code insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    INSERT  FROM v500_event_set_explode vee
     SET vee.event_cd = event_code_value, vee.event_set_cd = event_set_code_value, vee
      .event_set_status_cd = 0.0,
      vee.event_set_level = 0, vee.updt_dt_tm = cnvtdatetime(curdate,curtime3), vee.updt_id = reqinfo
      ->updt_id,
      vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on v500 explode insert"
      )
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF (substring(0,8,request->orders[x].order_cki)="MUL.MMDC")
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
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on v500 canon insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF ((request->orders[x].immunization_ind=0))
     IF (parent_cd=diluents_code_value)
      SET len = size(fin_dil_hier->event_hier,5)
      IF (len > 0)
       SET ierrcode = 0
       INSERT  FROM v500_event_set_explode vee,
         (dummyt d  WITH seq = len)
        SET vee.event_cd = event_code_value, vee.event_set_cd = fin_dil_hier->event_hier[d.seq].
         code_value, vee.event_set_status_cd = 0.0,
         vee.event_set_level = fin_dil_hier->event_hier[d.seq].level, vee.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), vee.updt_id = reqinfo->updt_id,
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
        SET vee.event_cd = event_code_value, vee.event_set_cd = fin_med_hier->event_hier[d.seq].
         code_value, vee.event_set_status_cd = 0.0,
         vee.event_set_level = fin_med_hier->event_hier[d.seq].level, vee.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), vee.updt_id = reqinfo->updt_id,
         vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
         updt_applctx
        PLAN (d)
         JOIN (vee)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->status_data.subeventstatus[1].targetobjectname = build(
         "Error on medication insert")
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET im_reseq = 1
     INSERT  FROM v500_event_set_canon vesc
      SET vesc.parent_event_set_cd = immunization_code_value, vesc.event_set_cd =
       event_set_code_value, vesc.event_set_collating_seq = 0,
       vesc.event_set_explode_ind = 0, vesc.event_set_status_cd = active_status_code_value, vesc
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       vesc.updt_id = reqinfo->updt_id, vesc.updt_task = reqinfo->updt_task, vesc.updt_cnt = 0,
       vesc.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on v500 canon insert")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      FROM code_value_extension c
      PLAN (c
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND")
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET ierrcode = 0
      INSERT  FROM code_value_extension c
       SET c.code_value = request->orders[x].catalog_code_value, c.code_set = 200, c.field_name =
        "IMMUNIZATIONIND",
        c.field_type = 1, c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
        c.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on extension insert")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ELSE
      SET ierrcode = 0
      UPDATE  FROM code_value_extension c
       SET c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
        updt_id,
        c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
        updt_applctx
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND"
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on extension update")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
     SET len = size(fin_im_hier->event_hier,5)
     IF (len > 0)
      SET ierrcode = 0
      INSERT  FROM v500_event_set_explode vee,
        (dummyt d  WITH seq = len)
       SET vee.event_cd = event_code_value, vee.event_set_cd = fin_im_hier->event_hier[d.seq].
        code_value, vee.event_set_status_cd = 0.0,
        vee.event_set_level = fin_im_hier->event_hier[d.seq].level, vee.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), vee.updt_id = reqinfo->updt_id,
        vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
        updt_applctx
       PLAN (d)
        JOIN (vee)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build(
        "Error on immunization insert")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    SET ierrcode = 0
    INSERT  FROM code_value_event_r cr
     SET cr.event_cd = event_code_value, cr.parent_cd = request->orders[x].catalog_code_value, cr
      .flex1_cd = 0,
      cr.flex2_cd = 0, cr.flex3_cd = 0, cr.flex4_cd = 0,
      cr.flex5_cd = 0, cr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cr.updt_id = reqinfo->updt_id,
      cr.updt_task = reqinfo->updt_task, cr.updt_cnt = 0, cr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Error on code_value_event_r insert")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (med_reseq > 0)
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
 IF (dil_reseq > 0)
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
 IF (im_reseq > 0)
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
 SET req_cnt = size(reply->orders,5)
 IF (req_cnt > 0)
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = value(req_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE b.br_nv_key1="MLTM_IGN_ORDS_WO_EC"
     AND b.br_name="ORDER_CATALOG"
     AND (cnvtreal(trim(b.br_value))=reply->orders[d.seq].catalog_code_value)
     AND (reply->orders[d.seq].duplicate_ind=0))
   WITH nocounter
  ;end delete
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
