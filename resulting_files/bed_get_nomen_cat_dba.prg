CREATE PROGRAM bed_get_nomen_cat:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 categories[*]
      2 category_id = f8
      2 category_name = vc
      2 category_type
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 position
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 owner
        3 person_id = f8
        3 person_name = vc
        3 person_username = vc
      2 category_flex_type_name = vc
      2 children[*]
        3 child_id = f8
        3 child_name = vc
        3 child_type = i2
        3 list_sequence = i4
        3 term
          4 term_axis_disp = vc
          4 code_disp = vc
          4 term_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
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
 DECLARE parent_entity = vc WITH protect, noconstant("")
 DECLARE category_flex_type = vc WITH protect, constant(cnvtupper(request->category_flex_type_name))
 DECLARE buildreply(dummyvar=i2) = null
 IF (category_flex_type="GENERAL")
  SET parent_entity = build2("nc.parent_entity_name IN(","'","GENERAL","'",")")
 ELSEIF (category_flex_type="PRSNL")
  SET parent_entity = build2("nc.parent_entity_name IN(","'","GENERAL","', '","PRSNL",
   "'",")")
 ELSEIF (category_flex_type="POSITION")
  SET parent_entity = build2("nc.parent_entity_name IN(","'","GENERAL","', '","POSITION",
   "'",")")
 ENDIF
 SET reply->too_many_results_ind = 0
 IF (((category_flex_type="GENERAL") OR (((category_flex_type="PRSNL") OR (category_flex_type=
 "POSITION")) )) )
  DECLARE cnt = i4 WITH protect, noconstant(0)
  DECLARE child_cnt = i4 WITH protect, noconstant(0)
  DECLARE max_cnt = i4 WITH protect, constant(500)
  DECLARE category_type_cnt = i4 WITH protect, noconstant(0)
  IF (validate(request->search_txt))
   IF (size(trim(request->search_txt),1) > 0)
    SET parent_entity = build(parent_entity," and (cnvtupper(nc.category_name) = ' ")
    IF (trim(cnvtupper(request->search_type_flag))="C")
     SET parent_entity = build(parent_entity,"*")
    ENDIF
    SET parent_entity = build(parent_entity,trim(cnvtupper(request->search_txt)),"*')")
   ENDIF
  ENDIF
  SET category_type_cnt = size(request->category_type_code,5)
  IF (category_type_cnt > 0)
   FOR (i = 1 TO category_type_cnt)
     IF (i=1)
      SET parent_entity = build(parent_entity," and nc.category_type_cd IN (",request->
       category_type_code[i].categories_type_code_value)
     ELSE
      SET parent_entity = build(parent_entity,",",request->category_type_code[i].
       categories_type_code_value)
     ENDIF
   ENDFOR
   SET parent_entity = concat(parent_entity,")")
  ENDIF
  CALL logdebugmessage("PARENT ENTITY PARSER :",parent_entity)
  SELECT INTO "nl:"
   FROM nomen_category nc,
    nomen_cat_list nl,
    nomen_category nc1,
    nomenclature n,
    prsnl p
   PLAN (nc
    WHERE parser(parent_entity))
    JOIN (nl
    WHERE outerjoin(nc.nomen_category_id)=nl.parent_category_id)
    JOIN (nc1
    WHERE outerjoin(nl.child_category_id)=nc1.nomen_category_id)
    JOIN (n
    WHERE outerjoin(nl.nomenclature_id)=n.nomenclature_id)
    JOIN (p
    WHERE p.person_id=outerjoin(nc.parent_entity_id))
   ORDER BY nc.nomen_category_id, nl.list_sequence
   HEAD nc.nomen_category_id
    cnt = (cnt+ 1), child_cnt = 0, stat = alterlist(reply->categories,cnt),
    reply->categories[cnt].category_id = nc.nomen_category_id, reply->categories[cnt].category_name
     = nc.category_name, reply->categories[cnt].category_flex_type_name = nc.parent_entity_name,
    reply->categories[cnt].category_type.code_value = nc.category_type_cd, reply->categories[cnt].
    category_type.display = uar_get_code_display(nc.category_type_cd), reply->categories[cnt].
    category_type.meaning = uar_get_code_meaning(nc.category_type_cd)
    IF (nc.parent_entity_name="POSITION")
     reply->categories[cnt].position.code_value = nc.parent_entity_id, reply->categories[cnt].
     position.display = uar_get_code_display(nc.parent_entity_id), reply->categories[cnt].position.
     meaning = uar_get_code_meaning(nc.parent_entity_id)
    ELSEIF (nc.parent_entity_name="PRSNL")
     reply->categories[cnt].owner.person_id = nc.parent_entity_id, reply->categories[cnt].owner.
     person_name = p.name_full_formatted, reply->categories[cnt].owner.person_username = p.username
    ENDIF
   HEAD nl.child_category_id
    IF (nl.child_category_id > 0)
     child_cnt = (child_cnt+ 1), stat = alterlist(reply->categories[cnt].children,child_cnt), reply->
     categories[cnt].children[child_cnt].child_id = nl.child_category_id,
     reply->categories[cnt].children[child_cnt].child_name = nc1.category_name, reply->categories[cnt
     ].children[child_cnt].child_type = nl.child_flag, reply->categories[cnt].children[child_cnt].
     list_sequence = nl.list_sequence
    ENDIF
   HEAD nl.nomenclature_id
    IF (nl.nomenclature_id > 0)
     child_cnt = (child_cnt+ 1), stat = alterlist(reply->categories[cnt].children,child_cnt), reply->
     categories[cnt].children[child_cnt].child_id = nl.nomenclature_id,
     reply->categories[cnt].children[child_cnt].child_name = n.source_string, reply->categories[cnt].
     children[child_cnt].child_type = nl.child_flag, reply->categories[cnt].children[child_cnt].
     list_sequence = nl.list_sequence,
     reply->categories[cnt].children[child_cnt].term.term_axis_disp = uar_get_code_display(n
      .vocab_axis_cd), reply->categories[cnt].children[child_cnt].term.code_disp = n
     .source_identifier, reply->categories[cnt].children[child_cnt].term.term_disp =
     uar_get_code_display(n.source_vocabulary_cd)
    ENDIF
   WITH nocounter
  ;end select
  IF (cnt > max_cnt)
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   SET stat = alterlist(reply->categories,0)
   GO TO exit_script
  ENDIF
 ELSE
  CALL bedlogmessage("parent_entity_name is incorrect in the request",parent_entity)
  CALL bederror("parent_entity_name is incorrect in the request...")
  GO TO exit_script
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
