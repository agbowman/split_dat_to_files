CREATE PROGRAM bed_ens_fav_folder:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 favorite_folders[*]
      2 category_id = f8
      2 category_name = vc
      2 category_type_cd = f8
      2 personnel_id = f8
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
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE folder_cnt = i4 WITH protect, constant(size(request->favorite_folders,5))
 DECLARE addfavoritefolder(name=vc,folder_type_cd=f8,personnel_id=f8,parent_id=f8) = f8
 DECLARE updatefavoritefolder(folder_id=f8,folder_type_cd=f8,personnel_id=f8,name=vc) = null
 DECLARE deletefavoritefolder(folder_id=f8,folder_type_cd=f8,personnel_id=f8) = null
 DECLARE addnomenclatureterm(parent_id=f8,nomenclature_id=f8,sequence=i4) = null
 DECLARE updatenomenclatureterm(parent_id=f8,nomenclature_id=f8,sequence=i4) = null
 DECLARE deletenomenclatureterm(parent_id=f8,nomenclature_id=f8) = null
 DECLARE getnextsequence(parent_category_id=f8) = i4
 CALL bedbeginscript(0)
 FOR (i = 1 TO folder_cnt)
   DECLARE category_id = f8 WITH protect, noconstant(request->favorite_folders[i].category_id)
   DECLARE category_name = vc WITH protect, noconstant(request->favorite_folders[i].category_name)
   DECLARE category_type_cd = f8 WITH protect, noconstant(request->favorite_folders[i].
    category_type_cd)
   DECLARE personnel_id = f8 WITH protect, noconstant(request->favorite_folders[i].personnel_id)
   DECLARE parent_category_id = f8 WITH protect, noconstant(request->favorite_folders[i].
    parent_category_id)
   IF ((request->favorite_folders[i].action_flag=add_flag))
    SET category_id = addfavoritefolder(category_name,category_type_cd,personnel_id,
     parent_category_id)
   ELSEIF ((request->favorite_folders[i].action_flag=update_flag))
    CALL updatefavoritefolder(category_id,category_type_cd,personnel_id,category_name)
   ELSEIF ((request->favorite_folders[i].action_flag=delete_flag))
    CALL deletefavoritefolder(category_id,category_type_cd,personnel_id)
   ENDIF
   IF (size(request->favorite_folders[i].nomen_terms[i],5) > 0)
    FOR (j = 1 TO size(request->favorite_folders[i].nomen_terms[i],5))
      DECLARE nomenclature_id = f8 WITH protect, noconstant(request->favorite_folders[i].nomen_terms[
       j].nomenclature_id)
      DECLARE sequence = i4 WITH protect, noconstant(request->favorite_folders[i].nomen_terms[j].
       sequence)
      IF ((request->favorite_folders[i].nomen_terms[j].action_flag=add_flag))
       CALL addnomenclatureterm(category_id,nomenclature_id,sequence)
      ELSEIF ((request->favorite_folders[i].nomen_terms[j].action_flag=update_flag))
       CALL updatenomenclatureterm(category_id,nomenclature_id,sequence)
      ELSEIF ((request->favorite_folders[i].nomen_terms[j].action_flag=delete_flag))
       CALL deletenomenclatureterm(category_id,nomenclature_id)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SUBROUTINE addfavoritefolder(name,folder_type_cd,personnel_id,parent_id)
   DECLARE reply_cnt = i4 WITH protect, noconstant(size(reply->favorite_folders,5))
   DECLARE new_category_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(nomenclature_seq,nextval)
    FROM dual
    DETAIL
     new_category_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   CALL bederrorcheck("Error 001 - Add: Failed to retrieve new nomen seq for nomen_category")
   INSERT  FROM nomen_category nc
    SET nc.nomen_category_id = new_category_id, nc.category_name = name, nc.category_type_cd =
     folder_type_cd,
     nc.parent_entity_id = personnel_id, nc.parent_entity_name = "PRSNL", nc.updt_cnt = 0,
     nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_applctx = reqinfo->updt_applctx, nc
     .updt_id = reqinfo->updt_id,
     nc.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 002 - Add: Failed to add new nomen_category row")
   IF (parent_id > 0)
    DECLARE relation_id = f8 WITH protect, noconstant(0.0)
    DECLARE relation_seq = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     next_seq = seq(nomenclature_seq,nextval)
     FROM dual
     DETAIL
      relation_id = cnvtreal(next_seq)
     WITH format, nocounter
    ;end select
    CALL bederrorcheck("Error 003 - Add: Failed to retrieve new nomen seq for nomen_cat_list")
    SET relation_seq = getnextsequence(parent_id)
    INSERT  FROM nomen_cat_list ncl
     SET ncl.nomen_cat_list_id = relation_id, ncl.child_category_id = new_category_id, ncl
      .parent_category_id = parent_id,
      ncl.child_flag = 1, ncl.list_sequence = relation_seq, ncl.updt_cnt = 0,
      ncl.updt_dt_tm = cnvtdatetime(curdate,curtime3), ncl.updt_applctx = reqinfo->updt_applctx, ncl
      .updt_id = reqinfo->updt_id,
      ncl.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 005 - Add: Failed to add new nomen_cat_list row")
   ENDIF
   SET stat = alterlist(reply->favorite_folders,(reply_cnt+ 1))
   SET reply->favorite_folders[reply_cnt].category_id = new_category_id
   SET reply->favorite_folders[reply_cnt].category_name = name
   SET reply->favorite_folders[reply_cnt].category_type_cd = folder_type_cd
   SET reply->favorite_folders[reply_cnt].personnel_id = personnel_id
   RETURN(new_category_id)
 END ;Subroutine
 SUBROUTINE updatefavoritefolder(folder_id,folder_type_cd,personnel_id,name)
   DECLARE upd_category_id = f8 WITH protect, noconstant(folder_id)
   IF (upd_category_id=0)
    SELECT INTO "nl:"
     FROM nomen_category nc
     WHERE nc.parent_entity_id=personnel_id
      AND nc.parent_entity_name="PRSNL"
      AND nc.category_type_cd=folder_type_cd
     DETAIL
      upd_category_id = nc.nomen_category_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 006 - Update: Failed to find category id")
   ENDIF
   UPDATE  FROM nomen_category nc
    SET nc.category_name = name, nc.updt_cnt = (nc.updt_cnt+ 1), nc.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     nc.updt_applctx = reqinfo->updt_applctx, nc.updt_id = reqinfo->updt_id, nc.updt_task = reqinfo->
     updt_task
    WHERE nc.nomen_category_id=upd_category_id
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error 007 - Update: Failed to update nomen_category row")
 END ;Subroutine
 SUBROUTINE deletefavoritefolder(folder_id,folder_type_cd,personnel_id)
   DECLARE del_category_id = f8 WITH protect, noconstant(folder_id)
   IF (del_category_id=0)
    SELECT INTO "nl:"
     FROM nomen_category nc
     WHERE nc.parent_entity_id=personnel_id
      AND nc.parent_entity_name="PRSNL"
      AND nc.category_type_cd=folder_type_cd
     DETAIL
      del_category_id = nc.nomen_category_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 008 - Delete: Failed to find category id")
   ENDIF
   DELETE  FROM nomen_cat_list ncl
    WHERE ((ncl.parent_category_id=del_category_id) OR (ncl.child_category_id=del_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 009 - Delete: Failed to delete children")
   DELETE  FROM nomen_category nc
    WHERE nc.nomen_category_id=del_category_id
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 010 - Delete: Failed to delete category")
 END ;Subroutine
 SUBROUTINE addnomenclatureterm(parent_id,nomenclature_id,sequence)
   DECLARE relation_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(nomenclature_seq,nextval)
    FROM dual
    DETAIL
     relation_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   CALL bederrorcheck("Error 012 - Add Term: Failed to retrieve new nomen seq for nomen_cat_list")
   INSERT  FROM nomen_cat_list ncl
    SET ncl.nomen_cat_list_id = relation_id, ncl.parent_category_id = parent_id, ncl.nomenclature_id
      = nomenclature_id,
     ncl.child_flag = 2, ncl.list_sequence = sequence, ncl.updt_cnt = 0,
     ncl.updt_dt_tm = cnvtdatetime(curdate,curtime3), ncl.updt_applctx = reqinfo->updt_applctx, ncl
     .updt_id = reqinfo->updt_id,
     ncl.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error 013 - Add Term: Failed to add new nomen_cat_list row")
 END ;Subroutine
 SUBROUTINE updatenomenclatureterm(parent_id,nomenclature_id,sequence)
  UPDATE  FROM nomen_cat_list ncl
   SET ncl.list_sequence = sequence, ncl.updt_cnt = (ncl.updt_cnt+ 1), ncl.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    ncl.updt_applctx = reqinfo->updt_applctx, ncl.updt_id = reqinfo->updt_id, ncl.updt_task = reqinfo
    ->updt_task
   WHERE ncl.parent_category_id=parent_id
    AND ncl.nomenclature_id=nomenclature_id
    AND ncl.child_flag=2
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error 014 - Update Term: Failed to update the nomen_cat_list row")
 END ;Subroutine
 SUBROUTINE deletenomenclatureterm(parent_id,nomenclature_id)
  DELETE  FROM nomen_cat_list ncl
   WHERE ncl.parent_category_id=parent_id
    AND ncl.nomenclature_id=nomenclature_id
    AND ncl.child_flag=2
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error 015 - Delete Term: Failed to remove the nomen_cat_list row")
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
   CALL bederrorcheck("Error 004: Failed to find next sequence for nomen_cat_list")
   RETURN(list_sequence)
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
