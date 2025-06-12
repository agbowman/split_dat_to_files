CREATE PROGRAM bed_copy_fav_folder:dba
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
 RECORD copy_from_terms(
   1 nomen_terms[*]
     2 nomenclature_id = f8
 ) WITH protect
 RECORD folders_to_copy(
   1 nomen_categories[*]
     2 personnel_id = f8
     2 category_id = f8
     2 nomen_terms[*]
       3 nomenclature_id = f8
       3 sequence = i4
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
 DECLARE findcopyfromfolderterms(category_id=f8) = i4
 DECLARE initializefolderstocopyrecord(folder_cnt=i4,term_cnt=i4) = null
 DECLARE clearexistingtermsforexistingfolders(dummyvar=i2) = null
 DECLARE createnewfoldersandupdaterecord(category_name=vc,category_type_cd=f8) = null
 DECLARE updatefolderstocopyrecordwithterms(dummyvar=i2) = null
 DECLARE getnextsequence(parent_category_id=f8) = i4
 DECLARE copy_from_terms_cnt = i4 WITH protect, noconstant(0)
 DECLARE category_name = vc WITH protect, noconstant("")
 DECLARE category_type_cd = f8 WITH protect, noconstant(0.0)
 CALL bedbeginscript(0)
 IF (size(request->personnel,5)=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM nomen_category nc
  PLAN (nc
   WHERE (nc.nomen_category_id=request->category_id))
  DETAIL
   category_name = nc.category_name, category_type_cd = nc.category_type_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck(build2("E001: ",trim(cnvtstring(request->category_id,5))))
 SET copy_from_terms_cnt = findcopyfromfolderterms(request->category_id)
 CALL initializefolderstocopyrecord(size(request->personnel,5),copy_from_terms_cnt)
 CALL clearexistingtermsforexistingfolders(0)
 CALL createnewfoldersandupdaterecord(category_name,category_type_cd)
 CALL updatefolderstocopyrecordwithterms(0)
 IF (copy_from_terms_cnt > 0)
  INSERT  FROM nomen_cat_list ncl,
    (dummyt d1  WITH seq = size(folders_to_copy->nomen_categories,5)),
    (dummyt d2  WITH seq = 1)
   SET ncl.nomen_cat_list_id = seq(nomenclature_seq,nextval), ncl.parent_category_id =
    folders_to_copy->nomen_categories[d1.seq].category_id, ncl.nomenclature_id = folders_to_copy->
    nomen_categories[d1.seq].nomen_terms[d2.seq].nomenclature_id,
    ncl.child_flag = 2, ncl.list_sequence = folders_to_copy->nomen_categories[d1.seq].nomen_terms[d2
    .seq].sequence, ncl.updt_cnt = 0,
    ncl.updt_dt_tm = cnvtdatetime(curdate,curtime3), ncl.updt_applctx = reqinfo->updt_applctx, ncl
    .updt_id = reqinfo->updt_id,
    ncl.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE maxrec(d2,copy_from_terms_cnt))
    JOIN (d2)
    JOIN (ncl)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("E009: Failed to insert NOMEN_CAT_LIST rows")
 ENDIF
 SUBROUTINE findcopyfromfolderterms(category_id)
   DECLARE found_terms_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM nomen_cat_list ncl
    PLAN (ncl
     WHERE ncl.parent_category_id=category_id
      AND ncl.child_flag=2)
    ORDER BY ncl.list_sequence
    DETAIL
     found_terms_cnt = (found_terms_cnt+ 1), stat = alterlist(copy_from_terms->nomen_terms,
      found_terms_cnt), copy_from_terms->nomen_terms[found_terms_cnt].nomenclature_id = ncl
     .nomenclature_id
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("E002: ",trim(cnvtstring(category_id,5))))
   RETURN(found_terms_cnt)
 END ;Subroutine
 SUBROUTINE initializefolderstocopyrecord(folder_cnt,term_cnt)
   SET stat = initrec(folders_to_copy)
   SET stat = alterlist(folders_to_copy->nomen_categories,folder_cnt)
   FOR (i = 1 TO folder_cnt)
    SET folders_to_copy->nomen_categories[i].personnel_id = request->personnel[i].personnel_id
    SET stat = alterlist(folders_to_copy->nomen_categories[i].nomen_terms,term_cnt)
   ENDFOR
   IF (folder_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = folder_cnt),
      nomen_category nc
     PLAN (d)
      JOIN (nc
      WHERE nc.category_name=category_name
       AND nc.category_type_cd=category_type_cd
       AND (nc.parent_entity_id=folders_to_copy->nomen_categories[d.seq].personnel_id)
       AND nc.parent_entity_name="PRSNL")
     DETAIL
      folders_to_copy->nomen_categories[d.seq].category_id = nc.nomen_category_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("E003: Failed to initialize folders_to_copy record")
   ENDIF
 END ;Subroutine
 SUBROUTINE clearexistingtermsforexistingfolders(dummyvar)
  DECLARE folders_to_copy_size = i4 WITH protect, noconstant(size(folders_to_copy->nomen_categories,5
    ))
  IF (folders_to_copy_size > 0)
   DELETE  FROM (dummyt d  WITH seq = folders_to_copy_size),
     nomen_cat_list ncl
    SET ncl.seq = 1
    PLAN (d
     WHERE (folders_to_copy->nomen_categories[d.seq].category_id > 0))
     JOIN (ncl
     WHERE (ncl.parent_category_id=folders_to_copy->nomen_categories[d.seq].category_id)
      AND ncl.child_flag=2)
    WITH nocounter
   ;end delete
   CALL bederrorcheck("E004: Failed to delete existing NOMEN_CAT_LIST rows")
  ENDIF
 END ;Subroutine
 SUBROUTINE createnewfoldersandupdaterecord(category_name,category_type_cd)
  DECLARE folders_to_copy_size = i4 WITH protect, noconstant(size(folders_to_copy->nomen_categories,5
    ))
  IF (folders_to_copy_size > 0)
   INSERT  FROM nomen_category nc,
     (dummyt d  WITH seq = folders_to_copy_size)
    SET nc.nomen_category_id = seq(nomenclature_seq,nextval), nc.category_name = category_name, nc
     .category_type_cd = category_type_cd,
     nc.parent_entity_id = folders_to_copy->nomen_categories[d.seq].personnel_id, nc
     .parent_entity_name = "PRSNL", nc.updt_cnt = 0,
     nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_applctx = reqinfo->updt_applctx, nc
     .updt_id = reqinfo->updt_id,
     nc.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (folders_to_copy->nomen_categories[d.seq].category_id=0))
     JOIN (nc)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("E005: Failed to insert new NOMEN_CATEGORY rows")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = folders_to_copy_size),
     nomen_category nc
    PLAN (d
     WHERE (folders_to_copy->nomen_categories[d.seq].category_id=0))
     JOIN (nc
     WHERE nc.category_name=category_name
      AND nc.category_type_cd=category_type_cd
      AND (nc.parent_entity_id=folders_to_copy->nomen_categories[d.seq].personnel_id)
      AND nc.parent_entity_name="PRSNL")
    DETAIL
     folders_to_copy->nomen_categories[d.seq].category_id = nc.nomen_category_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("E006: Failed to update folders_to_copy_size record")
  ENDIF
 END ;Subroutine
 SUBROUTINE updatefolderstocopyrecordwithterms(dummyvar)
  DECLARE folders_to_copy_size = i4 WITH protect, noconstant(size(folders_to_copy->nomen_categories,5
    ))
  FOR (i = 1 TO folders_to_copy_size)
    DECLARE copy_from_terms_cnt = i4 WITH protect, noconstant(size(copy_from_terms->nomen_terms,5))
    DECLARE next_available_seq = i4 WITH protect, noconstant(getnextsequence(folders_to_copy->
      nomen_categories[i].category_id))
    FOR (j = 1 TO copy_from_terms_cnt)
      SET folders_to_copy->nomen_categories[i].nomen_terms[j].nomenclature_id = copy_from_terms->
      nomen_terms[j].nomenclature_id
      SET folders_to_copy->nomen_categories[i].nomen_terms[j].sequence = next_available_seq
      SET next_available_seq = (next_available_seq+ 1)
    ENDFOR
  ENDFOR
 END ;Subroutine
 SUBROUTINE getnextsequence(parent_category_id)
   DECLARE list_sequence = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM nomen_cat_list ncl
    PLAN (ncl
     WHERE ncl.parent_category_id > 0
      AND ncl.parent_category_id=parent_category_id)
    ORDER BY ncl.list_sequence DESC
    HEAD REPORT
     list_sequence = (ncl.list_sequence+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck(build2("E007: ",trim(cnvtstring(request->category_id,5))))
   RETURN(list_sequence)
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
