CREATE PROGRAM bed_get_of_folders:dba
 FREE SET reply
 RECORD reply(
   1 flist[*]
     2 folder_id = f8
     2 folder_name = vc
     2 component_flag = i2
     2 slist[*]
       3 sequence = i4
       3 synonym_id = f8
       3 synonym_name = vc
       3 type_ind = c1
       3 order_sentence_id = f8
       3 order_sentence_display = vc
       3 catalog_code_value = f8
       3 catalog_display = vc
       3 catalog_meaning = vc
       3 list_type = i4
       3 order_sentence_filter
         4 order_sentence_filter_id = f8
         4 age_min_value = f8
         4 age_max_value = f8
         4 age_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
         4 pma_min_value = f8
         4 pma_max_value = f8
         4 pma_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
         4 weight_min_value = f8
         4 weight_max_value = f8
         4 weight_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
     2 plist[*]
       3 sequence = i4
       3 pathway_catalog_id = f8
       3 description = vc
       3 list_type = i4
       3 pw_cat_synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE getorderfolders() = i2
 CALL getorderfolders(0)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getorderfolders(dummyvar)
   SELECT INTO "nl:"
    FROM alt_sel_cat c,
     alt_sel_list l,
     order_catalog_synonym o,
     code_value cv,
     order_sentence s,
     pathway_catalog pc,
     pw_cat_synonym pcs
    PLAN (c
     WHERE c.ahfs_ind IN (0, null)
      AND c.adhoc_ind IN (0, null)
      AND c.folder_flag IN (0, 1, null)
      AND c.security_flag=2)
     JOIN (l
     WHERE l.alt_sel_category_id=outerjoin(c.alt_sel_category_id))
     JOIN (o
     WHERE o.synonym_id=outerjoin(l.synonym_id))
     JOIN (cv
     WHERE cv.code_value=outerjoin(o.catalog_cd))
     JOIN (s
     WHERE s.order_sentence_id=outerjoin(l.order_sentence_id))
     JOIN (pc
     WHERE pc.pathway_catalog_id=outerjoin(l.pathway_catalog_id))
     JOIN (pcs
     WHERE pcs.pw_cat_synonym_id=outerjoin(l.pw_cat_synonym_id))
    ORDER BY c.long_description, l.sequence, o.mnemonic,
     s.order_sentence_display_line
    HEAD REPORT
     fcnt = 0, scnt = 0, pcnt = 0
    HEAD c.alt_sel_category_id
     scnt = 0, pcnt = 0, fcnt = (fcnt+ 1),
     stat = alterlist(reply->flist,fcnt), reply->flist[fcnt].folder_id = c.alt_sel_category_id, reply
     ->flist[fcnt].folder_name = c.long_description,
     reply->flist[fcnt].component_flag = c.source_component_flag
    DETAIL
     IF (l.list_type IN (2, 6))
      IF (l.synonym_id > 0.0)
       scnt = (scnt+ 1), stat = alterlist(reply->flist[fcnt].slist,scnt), reply->flist[fcnt].slist[
       scnt].list_type = l.list_type,
       reply->flist[fcnt].slist[scnt].sequence = l.sequence, reply->flist[fcnt].slist[scnt].
       synonym_id = l.synonym_id, reply->flist[fcnt].slist[scnt].synonym_name = o.mnemonic,
       reply->flist[fcnt].slist[scnt].catalog_code_value = o.catalog_cd, reply->flist[fcnt].slist[
       scnt].catalog_display = cv.display, reply->flist[fcnt].slist[scnt].catalog_meaning = cv
       .cdf_meaning
       IF (o.orderable_type_flag IN (2, 6))
        reply->flist[fcnt].slist[scnt].type_ind = "C"
       ELSE
        reply->flist[fcnt].slist[scnt].type_ind = "S"
       ENDIF
       reply->flist[fcnt].slist[scnt].order_sentence_id = l.order_sentence_id, reply->flist[fcnt].
       slist[scnt].order_sentence_display = s.order_sentence_display_line
      ELSEIF (l.pathway_catalog_id > 0.0)
       IF (l.pw_cat_synonym_id > 0
        AND pcs.pw_cat_synonym_id > 0)
        pcnt = (pcnt+ 1), stat = alterlist(reply->flist[fcnt].plist,pcnt), reply->flist[fcnt].plist[
        pcnt].list_type = l.list_type,
        reply->flist[fcnt].plist[pcnt].sequence = l.sequence, reply->flist[fcnt].plist[pcnt].
        pathway_catalog_id = l.pathway_catalog_id, reply->flist[fcnt].plist[pcnt].description = pcs
        .synonym_name,
        reply->flist[fcnt].plist[pcnt].pw_cat_synonym_id = pcs.pw_cat_synonym_id
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Get order folders error")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->flist,5))),
     (dummyt d2  WITH seq = 1),
     order_sentence_filter osf,
     code_value cv_age,
     code_value cv_pma,
     code_value cv_weight
    PLAN (d1
     WHERE maxrec(d2,size(reply->flist[d1.seq].slist,5)))
     JOIN (d2)
     JOIN (osf
     WHERE (osf.order_sentence_id=reply->flist[d1.seq].slist[d2.seq].order_sentence_id))
     JOIN (cv_age
     WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
     JOIN (cv_pma
     WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
     JOIN (cv_weight
     WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
    ORDER BY d1.seq, d2.seq, osf.order_sentence_id
    DETAIL
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.order_sentence_filter_id = osf
     .order_sentence_filter_id, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.
     age_min_value = osf.age_min_value, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.
     age_max_value = osf.age_max_value,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.age_unit_cd.code_value = osf
     .age_unit_cd, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.age_unit_cd.display =
     cv_age.display, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.age_unit_cd.description
      = cv_age.description,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.age_unit_cd.mean = cv_age.cdf_meaning,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_min_value = osf.pma_min_value,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_max_value = osf.pma_max_value,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_unit_cd.code_value = osf
     .pma_unit_cd, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_unit_cd.display =
     cv_pma.display, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_unit_cd.description
      = cv_pma.description,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.pma_unit_cd.mean = cv_pma.cdf_meaning,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_min_value = osf.weight_min_value,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_max_value = osf.weight_max_value,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_unit_cd.code_value = osf
     .weight_unit_cd, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_unit_cd.display
      = cv_weight.display, reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_unit_cd.
     description = cv_weight.description,
     reply->flist[d1.seq].slist[d2.seq].order_sentence_filter.weight_unit_cd.mean = cv_weight
     .cdf_meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck("Order sentence filter error")
 END ;Subroutine
END GO
