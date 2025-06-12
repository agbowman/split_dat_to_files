CREATE PROGRAM bed_aud_cn_med_nurse_witness:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 synonyms[*]
      2 id = f8
    1 required_flag = i4
    1 orderableitems[*]
      2 item_cd = f8
    1 synonymtype[*]
      2 meaning = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 oqual[*]
     2 orderable = vc
     2 synonyms[*]
       3 synonym_name = vc
       3 synonym_type = vc
       3 witness_default_ind = i2
       3 groups[*]
         4 group_id = f8
         4 facility = vc
         4 attributes[*]
           5 attr_cd = f8
           5 value_disp = vc
 )
 FREE RECORD synlist
 RECORD synlist(
   1 synonyms[*]
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
 CALL bedbeginscript(0)
 DECLARE synonym_type_count = i4 WITH protect, constant(size(request->synonymtype,5))
 DECLARE orderable_item_count = i4 WITH protect, constant(size(request->orderableitems,5))
 DECLARE synonym_type_parse = vc WITH protect, noconstant("")
 DECLARE orderable_parse = vc WITH protect, noconstant("")
 DECLARE synonym_types_parse = vc WITH protect, noconstant("")
 DECLARE parseorderableandsynonymtype(dummyvar=i2) = i2
 CALL parseorderableandsynonymtype(0)
 SET syns_in_request = 0
 SET stat = alterlist(synlist->synonyms,0)
 IF (validate(request->synonyms[1].id))
  SET syns_in_request = size(request->synonyms,5)
  SET stat = alterlist(synlist->synonyms,syns_in_request)
  FOR (s = 1 TO syns_in_request)
    SET synlist->synonyms[s].id = request->synonyms[s].id
  ENDFOR
 ENDIF
 DECLARE pharmacy = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharmacy = cv.code_value
  WITH nocounter
 ;end select
 DECLARE brandname = f8 WITH public, noconstant(0.0)
 DECLARE dcp = f8 WITH public, noconstant(0.0)
 DECLARE dispdrug = f8 WITH public, noconstant(0.0)
 DECLARE generictop = f8 WITH public, noconstant(0.0)
 DECLARE ivname = f8 WITH public, noconstant(0.0)
 DECLARE primary = f8 WITH public, noconstant(0.0)
 DECLARE tradetop = f8 WITH public, noconstant(0.0)
 DECLARE rxmnemonic = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP", "RXMNEMONIC")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="BRANDNAME")
    brandname = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname = cv.code_value
   ELSEIF (cv.cdf_meaning="PRIMARY")
    primary = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop = cv.code_value
   ELSEIF (cv.cdf_meaning="RXMNEMONIC")
    rxmnemonic = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE agecode = f8 WITH public, noconstant(0.0)
 DECLARE ivevent = f8 WITH public, noconstant(0.0)
 DECLARE location = f8 WITH public, noconstant(0.0)
 DECLARE route = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4000047
    AND cv.cdf_meaning IN ("AGECODE", "IVEVENT", "LOCATION", "ROUTE")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="AGECODE")
    agecode = cv.code_value
   ELSEIF (cv.cdf_meaning="IVEVENT")
    ivevent = cv.code_value
   ELSEIF (cv.cdf_meaning="LOCATION")
    location = cv.code_value
   ELSEIF (cv.cdf_meaning="ROUTE")
    route = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET synonym_type_parse =
 "ocs.synonym_id = oax.synonym_id and ocs.catalog_type_cd = PHARMACY and ocs.active_ind = 1"
 IF (synonym_type_count > 0)
  SET synonym_type_parse = build(synonym_type_parse,synonym_types_parse)
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  IF (syns_in_request=0)
   SELECT INTO "NL:"
    FROM ocs_attr_xcptn oax,
     order_catalog_synonym ocs
    PLAN (oax)
     JOIN (ocs
     WHERE parser(synonym_type_parse))
    ORDER BY ocs.synonym_id, oax.ocs_attr_xcptn_group_id
    HEAD ocs.synonym_id
     IF (ocs.witness_flag=1)
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
    HEAD oax.ocs_attr_xcptn_group_id
     IF (oax.ocs_attr_xcptn_id > 0)
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = syns_in_request),
     order_catalog_synonym ocs,
     ocs_attr_xcptn oax
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.synonym_id=synlist->synonyms[d.seq].id))
     JOIN (oax
     WHERE oax.synonym_id=outerjoin(ocs.synonym_id))
    ORDER BY ocs.synonym_id, oax.ocs_attr_xcptn_group_id
    HEAD ocs.synonym_id
     IF (ocs.witness_flag=1)
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
    HEAD oax.ocs_attr_xcptn_group_id
     IF (oax.ocs_attr_xcptn_id > 0)
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET synonym_type_parse = "ocs.catalog_cd = oc.catalog_cd and ocs.active_ind = 1"
 IF (synonym_type_count > 0)
  SET synonym_type_parse = build(synonym_type_parse,synonym_types_parse)
 ENDIF
 IF ((((request->required_flag=0)) OR ((request->required_flag=1))) )
  SET synonym_type_parse = build(synonym_type_parse," and ocs.witness_flag = ",request->required_flag
   )
 ENDIF
 SET ocnt = 0
 SET gcnt = 0
 SET acnt = 0
 IF (syns_in_request=0)
  SELECT INTO "NL:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    code_value cvsyn,
    ocs_attr_xcptn oax,
    code_value cvfac,
    code_value cvval
   PLAN (oc
    WHERE parser(orderable_parse))
    JOIN (ocs
    WHERE parser(synonym_type_parse))
    JOIN (cvsyn
    WHERE cvsyn.code_value=ocs.mnemonic_type_cd
     AND cvsyn.active_ind=1)
    JOIN (oax
    WHERE oax.synonym_id=outerjoin(ocs.synonym_id))
    JOIN (cvfac
    WHERE cvfac.code_value=outerjoin(oax.facility_cd)
     AND cvfac.active_ind=outerjoin(1))
    JOIN (cvval
    WHERE cvval.code_value=outerjoin(oax.flex_obj_cd)
     AND cvval.active_ind=outerjoin(1))
   ORDER BY cnvtupper(oc.description), cnvtupper(ocs.mnemonic), cnvtupper(cvfac.display),
    oax.ocs_attr_xcptn_group_id, ocs.synonym_id, oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].orderable = oc
    .description,
    scnt = 1, stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
   HEAD ocs.synonym_id
    IF (ocs.mnemonic_type_cd=primary)
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[1].synonym_name = concat(ocs.mnemonic," <hidden>")
     ELSE
      temp->oqual[ocnt].synonyms[1].synonym_name = ocs.mnemonic
     ENDIF
     temp->oqual[ocnt].synonyms[1].synonym_type = cvsyn.display, temp->oqual[ocnt].synonyms[1].
     witness_default_ind = ocs.witness_flag
    ELSE
     scnt = (scnt+ 1), stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[scnt].synonym_name = concat(ocs.mnemonic," <hidden>")
     ELSE
      temp->oqual[ocnt].synonyms[scnt].synonym_name = ocs.mnemonic
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].synonym_type = cvsyn.display, temp->oqual[ocnt].synonyms[scnt].
     witness_default_ind = ocs.witness_flag
    ENDIF
    gcnt = 0
   HEAD oax.ocs_attr_xcptn_group_id
    IF (oax.ocs_attr_xcptn_id > 0)
     gcnt = (gcnt+ 1)
     IF (ocs.mnemonic_type_cd=primary)
      stat = alterlist(temp->oqual[ocnt].synonyms[1].groups,gcnt), temp->oqual[ocnt].synonyms[1].
      groups[gcnt].group_id = oax.ocs_attr_xcptn_group_id, temp->oqual[ocnt].synonyms[1].groups[gcnt]
      .facility = cvfac.display
     ELSE
      stat = alterlist(temp->oqual[ocnt].synonyms[scnt].groups,gcnt), temp->oqual[ocnt].synonyms[scnt
      ].groups[gcnt].group_id = oax.ocs_attr_xcptn_group_id, temp->oqual[ocnt].synonyms[scnt].groups[
      gcnt].facility = cvfac.display
     ENDIF
     acnt = 0
    ENDIF
   DETAIL
    IF (oax.flex_obj_type_cd > 0)
     acnt = (acnt+ 1)
     IF (ocs.mnemonic_type_cd=primary)
      stat = alterlist(temp->oqual[ocnt].synonyms[1].groups[gcnt].attributes,acnt), temp->oqual[ocnt]
      .synonyms[1].groups[gcnt].attributes[acnt].attr_cd = oax.flex_obj_type_cd, temp->oqual[ocnt].
      synonyms[1].groups[gcnt].attributes[acnt].value_disp = cvval.display
     ELSE
      stat = alterlist(temp->oqual[ocnt].synonyms[scnt].groups[gcnt].attributes,acnt), temp->oqual[
      ocnt].synonyms[scnt].groups[gcnt].attributes[acnt].attr_cd = oax.flex_obj_type_cd, temp->oqual[
      ocnt].synonyms[scnt].groups[gcnt].attributes[acnt].value_disp = cvval.display
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = syns_in_request),
    order_catalog oc,
    order_catalog_synonym ocs,
    code_value cvsyn,
    ocs_attr_xcptn oax,
    code_value cvfac,
    code_value cvval
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=synlist->synonyms[d.seq].id))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (cvsyn
    WHERE cvsyn.code_value=ocs.mnemonic_type_cd
     AND cvsyn.active_ind=1)
    JOIN (oax
    WHERE oax.synonym_id=outerjoin(ocs.synonym_id))
    JOIN (cvfac
    WHERE cvfac.code_value=outerjoin(oax.facility_cd)
     AND cvfac.active_ind=outerjoin(1))
    JOIN (cvval
    WHERE cvval.code_value=outerjoin(oax.flex_obj_cd)
     AND cvval.active_ind=outerjoin(1))
   ORDER BY cnvtupper(oc.description), cnvtupper(ocs.mnemonic), cnvtupper(cvfac.display),
    oax.ocs_attr_xcptn_group_id, ocs.synonym_id, oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].orderable = oc
    .description,
    scnt = 1, stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
   HEAD ocs.synonym_id
    IF (ocs.mnemonic_type_cd=primary)
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[1].synonym_name = concat(ocs.mnemonic," <hidden>")
     ELSE
      temp->oqual[ocnt].synonyms[1].synonym_name = ocs.mnemonic
     ENDIF
     temp->oqual[ocnt].synonyms[1].synonym_type = cvsyn.display, temp->oqual[ocnt].synonyms[1].
     witness_default_ind = ocs.witness_flag
    ELSE
     scnt = (scnt+ 1), stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[scnt].synonym_name = concat(ocs.mnemonic," <hidden>")
     ELSE
      temp->oqual[ocnt].synonyms[scnt].synonym_name = ocs.mnemonic
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].synonym_type = cvsyn.display, temp->oqual[ocnt].synonyms[scnt].
     witness_default_ind = ocs.witness_flag
    ENDIF
    gcnt = 0
   HEAD oax.ocs_attr_xcptn_group_id
    IF (oax.ocs_attr_xcptn_id > 0)
     gcnt = (gcnt+ 1)
     IF (ocs.mnemonic_type_cd=primary)
      stat = alterlist(temp->oqual[ocnt].synonyms[1].groups,gcnt), temp->oqual[ocnt].synonyms[1].
      groups[gcnt].group_id = oax.ocs_attr_xcptn_group_id, temp->oqual[ocnt].synonyms[1].groups[gcnt]
      .facility = cvfac.display
     ELSE
      stat = alterlist(temp->oqual[ocnt].synonyms[scnt].groups,gcnt), temp->oqual[ocnt].synonyms[scnt
      ].groups[gcnt].group_id = oax.ocs_attr_xcptn_group_id, temp->oqual[ocnt].synonyms[scnt].groups[
      gcnt].facility = cvfac.display
     ENDIF
     acnt = 0
    ENDIF
   DETAIL
    IF (oax.flex_obj_type_cd > 0)
     acnt = (acnt+ 1)
     IF (ocs.mnemonic_type_cd=primary)
      stat = alterlist(temp->oqual[ocnt].synonyms[1].groups[gcnt].attributes,acnt), temp->oqual[ocnt]
      .synonyms[1].groups[gcnt].attributes[acnt].attr_cd = oax.flex_obj_type_cd, temp->oqual[ocnt].
      synonyms[1].groups[gcnt].attributes[acnt].value_disp = cvval.display
     ELSE
      stat = alterlist(temp->oqual[ocnt].synonyms[scnt].groups[gcnt].attributes,acnt), temp->oqual[
      ocnt].synonyms[scnt].groups[gcnt].attributes[acnt].attr_cd = oax.flex_obj_type_cd, temp->oqual[
      ocnt].synonyms[scnt].groups[gcnt].attributes[acnt].value_disp = cvval.display
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Orderable Item Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Witness Default"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Witness Exception"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Facility"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Location"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "IV Event"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Age"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Route"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (o = 1 TO ocnt)
  SET scnt = size(temp->oqual[o].synonyms,5)
  FOR (s = 1 TO scnt)
    IF ((temp->oqual[o].synonyms[s].synonym_name > " "))
     SET gcnt = 0
     SET gcnt = size(temp->oqual[o].synonyms[s].groups,5)
     IF ((((temp->oqual[o].synonyms[s].witness_default_ind=1)) OR ((temp->oqual[o].synonyms[s].
     witness_default_ind=0)
      AND gcnt > 0)) )
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[o].orderable
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[o].synonyms[s].synonym_name
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[o].synonyms[s].synonym_type
      IF ((temp->oqual[o].synonyms[s].witness_default_ind=0))
       SET reply->rowlist[row_nbr].celllist[4].string_value = "Not Required"
      ELSE
       SET reply->rowlist[row_nbr].celllist[4].string_value = "Required"
      ENDIF
      FOR (g = 1 TO gcnt)
        IF ((temp->oqual[o].synonyms[s].witness_default_ind=1))
         SET reply->rowlist[row_nbr].celllist[5].string_value = "Not Required"
        ELSE
         SET reply->rowlist[row_nbr].celllist[5].string_value = "Required"
        ENDIF
        SET reply->rowlist[row_nbr].celllist[6].string_value = temp->oqual[o].synonyms[s].groups[g].
        facility
        SET acnt = size(temp->oqual[o].synonyms[s].groups[g].attributes,5)
        FOR (a = 1 TO acnt)
          IF ((temp->oqual[o].synonyms[s].groups[g].attributes[a].attr_cd=location))
           SET reply->rowlist[row_nbr].celllist[7].string_value = temp->oqual[o].synonyms[s].groups[g
           ].attributes[a].value_disp
          ELSEIF ((temp->oqual[o].synonyms[s].groups[g].attributes[a].attr_cd=route))
           SET reply->rowlist[row_nbr].celllist[10].string_value = temp->oqual[o].synonyms[s].groups[
           g].attributes[a].value_disp
          ELSEIF ((temp->oqual[o].synonyms[s].groups[g].attributes[a].attr_cd=ivevent))
           SET reply->rowlist[row_nbr].celllist[8].string_value = temp->oqual[o].synonyms[s].groups[g
           ].attributes[a].value_disp
          ELSEIF ((temp->oqual[o].synonyms[s].groups[g].attributes[a].attr_cd=agecode))
           SET reply->rowlist[row_nbr].celllist[9].string_value = temp->oqual[o].synonyms[s].groups[g
           ].attributes[a].value_disp
          ENDIF
        ENDFOR
        IF (g < gcnt)
         SET row_nbr = (row_nbr+ 1)
         SET stat = alterlist(reply->rowlist,row_nbr)
         SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
         SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[o].orderable
         SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[o].synonyms[s].
         synonym_name
         SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[o].synonyms[s].
         synonym_type
         IF ((temp->oqual[o].synonyms[s].witness_default_ind=0))
          SET reply->rowlist[row_nbr].celllist[4].string_value = "Not Required"
         ELSE
          SET reply->rowlist[row_nbr].celllist[4].string_value = "Required"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SUBROUTINE parseorderableandsynonymtype(dummyvar)
   SET orderable_parse = "oc.catalog_type_cd+0 = PHARMACY and oc.active_ind = 1 "
   SET id_count = 0
   IF (orderable_item_count > 0)
    SET orderable_parse = build(orderable_parse," and oc.catalog_cd in(")
    FOR (i = 1 TO orderable_item_count)
      IF (id_count > 999)
       SET orderable_parse = replace(orderable_parse,",","",2)
       SET orderable_parse = build(orderable_parse,") or oc.catalog_cd in(")
       SET id_count = 0
      ENDIF
      SET orderable_parse = build(orderable_parse,request->orderableitems[i].item_cd,",")
      SET id_count = (id_count+ 1)
    ENDFOR
    SET orderable_parse = trim(substring(1,(size(orderable_parse,1) - 1),orderable_parse))
    SET orderable_parse = build(orderable_parse,")")
   ENDIF
   IF (synonym_type_count > 0)
    SET synonym_types_parse = " and ocs.mnemonic_type_cd in("
    FOR (i = 1 TO synonym_type_count)
      SET synonym_types_parse = build(synonym_types_parse,request->synonymtype[i].meaning,",")
    ENDFOR
    SET synonym_types_parse = trim(substring(1,(size(synonym_types_parse,1) - 1),synonym_types_parse)
     )
    SET synonym_types_parse = build(synonym_types_parse,")")
   ENDIF
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_med_nurse_witness.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
