CREATE PROGRAM bed_ens_datamart_values:dba
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
 DECLARE generateflexid(pk=f8(ref)) = i2
 DECLARE insertflex(flexid=f8,grouperflexid=f8,perententityname=vc,parententityid=f8,typeflag=i4,
  grouperind=i2) = i2
 DECLARE findflexid(pename=vc,peid=f8,petypeflag=i2,grouperid=f8,grouperind=i2) = f8
 SUBROUTINE generateflexid(id)
   CALL bedlogmessage("generateFlexId","Entering ...")
   SET id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     id = cnvtreal(j)
    WITH format, counter
   ;end select
   CALL bedlogmessage("generateFlexId","Exiting ...")
 END ;Subroutine
 SUBROUTINE findflexid(pename,peid,petypeflag,grouperid,grouperind)
   CALL bedlogmessage("findFlexId","Entering ...")
   IF ( NOT (validate(tempflexid)))
    DECLARE tempflexid = f8 WITH protect, noconstant(0)
   ENDIF
   SET tempflexid = 0.0
   SELECT INTO "nl:"
    FROM br_datamart_flex f
    PLAN (f
     WHERE f.parent_entity_name=pename
      AND f.parent_entity_id=peid
      AND f.parent_entity_type_flag=petypeflag
      AND f.grouper_flex_id=grouperid
      AND f.grouper_ind=grouperind)
    DETAIL
     tempflexid = f.br_datamart_flex_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("findFlexId","Exiting ...")
   RETURN(tempflexid)
 END ;Subroutine
 SUBROUTINE insertflex(flexid,grouperflexid,perententityname,parententityid,typeflag,grouperind)
   CALL bedlogmessage("insertFlex","Entering ...")
   INSERT  FROM br_datamart_flex f
    SET f.br_datamart_flex_id = flexid, f.grouper_flex_id = grouperflexid, f.parent_entity_name =
     perententityname,
     f.parent_entity_type_flag = typeflag, f.parent_entity_id = parententityid, f.grouper_ind =
     grouperind,
     f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task
    PLAN (f)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error insering br_datamart_flex.")
   CALL bedlogmessage("insertFlex","Exiting ...")
 END ;Subroutine
 IF ( NOT (validate(delete_hist,0)))
  RECORD delete_hist(
    1 deleted_items[*]
      2 parent_entity_id = f8
      2 parent_entity_name = vc
  ) WITH protect
 ENDIF
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE multi_freetext_filter_cat_mean = vc WITH protect, constant("MULTI_FREETEXT_SEQ")
 DECLARE processflexedsettings(filterindex=i4,flextypecnt=i4,groupcnt=i4,datamartcategoryid=f8) = i2
 DECLARE getgroupseq(filterindex=i4,use_group_seq=i2(ref),group_seq=i4(ref)) = i2
 DECLARE determineparententitynames(filterindex=i4,valueindex=i4,parent_entity_name=vc(ref),
  parent_entity_name2=vc(ref)) = i2
 DECLARE getvalueseq(filterindex=i4,use_value_seq=i2(ref),value_seq=i4(ref)) = i2
 DECLARE insertdatamartvalue(filterindex=i4,valueindex=i4,temp_flex_id=f8,parent_entity_name=vc,
  parent_entity_name2=vc,
  use_group_seq=i2,group_seq=i4,use_value_seq=i2,value_seq=i4,datamartcategoryid=f8) = i2
 DECLARE updatebasetargetvalue(mpageparamvalue=vc,mpageparammean=vc,parententityname=vc,
  parententityid=f8) = i2
 DECLARE insertbasetargetvalue(datamartcategoryid=f8,mpageparammean=vc,mpageparamvalue=vc,
  parententityname=vc,parententityid=f8) = i2
 DECLARE determinebaselinetargetind(parententityid=f8,parententityname=vc,baseind=i2(ref),targetind=
  i2(ref)) = i2
 DECLARE handledatamartreportupdates(brdatamartreportid=f8,baselinevalue=vc,targetvalue=vc) = i2
 DECLARE handledatamartcategoryupdates(brdatamartcategoryid=f8,baselinevalue=vc,targetvalue=vc) = i2
 DECLARE deletevalues(categoryid=f8,filterid=f8,flexid=f8) = i2
 DECLARE insertvalues(filterindex=i4,flexid=f8,isinsertioncheckrequired=i2,datamartcategoryid=f8) =
 i2
 DECLARE copydatamartdeletevalues(categoryid=f8,filterid=f8,flexid=f8) = i2
 DECLARE isinsertionneeded(filterindex=i4,childflexid=f8,valueidx=i2,datamartcategoryid=f8) = i2
 DECLARE getfiltercategorymeaning(filtrid=f8) = vc
 SUBROUTINE deletevalues(categoryid,filterid,flexid)
   CALL bedlogmessage("deleteValues","Entering ...")
   IF (filter_category_mean=message_cntr_pool_mean)
    DELETE  FROM (dummyt d1  WITH seq = value(value_indx)),
      br_datamart_value b
     SET b.seq = 1
     PLAN (d1)
      JOIN (b
      WHERE b.br_datamart_category_id=categoryid
       AND b.br_datamart_filter_id=filterid
       AND b.br_datamart_flex_id=flexid
       AND b.logical_domain_id=logical_domain_id
       AND (b.parent_entity_id=request->filter[filteridx].value[d1.seq].parent_entity_id))
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM br_datamart_value b
     WHERE b.br_datamart_category_id=categoryid
      AND b.br_datamart_filter_id=filterid
      AND b.br_datamart_flex_id=flexid
      AND b.logical_domain_id=logical_domain_id
     WITH nocounter
    ;end delete
   ENDIF
   CALL bederrorcheck("Error deleting from br_datamart_value.")
   CALL bedlogmessage("deleteValues","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertvalues(filterindex,flexid,isinsertioncheckrequired,datamartcategoryid)
   CALL bedlogmessage("insertValues","Entering ...")
   DECLARE valueidx = i4 WITH protect, noconstant(0)
   DECLARE parententityname = vc WITH protect, noconstant("")
   DECLARE parententityname2 = vc WITH protect, noconstant("")
   DECLARE usegroupseq = i2 WITH protect, noconstant(0)
   DECLARE groupseq = i4 WITH protect, noconstant(0)
   DECLARE usevalueseq = i2 WITH protect, noconstant(0)
   DECLARE valueseq = i4 WITH protect, noconstant(0)
   CALL getgroupseq(filterindex,usegroupseq,groupseq)
   FOR (valueidx = 1 TO size(request->filter[filterindex].value,5))
     CALL determineparententitynames(filterindex,valueidx,parententityname,parententityname2)
     CALL getvalueseq(filterindex,usevalueseq,valueseq)
     IF (isinsertioncheckrequired=1)
      IF (isinsertionneeded(filterindex,flexid,valueidx,datamartcategoryid)=1)
       CALL insertdatamartvalue(filterindex,valueidx,flexid,parententityname,parententityname2,
        usegroupseq,groupseq,usevalueseq,valueseq,datamartcategoryid)
      ENDIF
     ELSE
      CALL insertdatamartvalue(filterindex,valueidx,flexid,parententityname,parententityname2,
       usegroupseq,groupseq,usevalueseq,valueseq,datamartcategoryid)
     ENDIF
   ENDFOR
   CALL bedlogmessage("insertValues","Exiting ...")
 END ;Subroutine
 SUBROUTINE processflexedsettings(filterindex,flextypecnt,groupcnt,datamartcategoryid)
   CALL bedlogmessage("processFlexedSettings","Entering ...")
   DECLARE flexparententityname = vc WITH protect, noconstant("")
   DECLARE flexparententityid = f8 WITH protect, noconstant(0)
   DECLARE flexparententityflag = i2 WITH protect, noconstant(0)
   DECLARE pparententityname = vc WITH protect, noconstant("")
   DECLARE pparententityid = f8 WITH protect, noconstant(0)
   DECLARE pparententityflag = i2 WITH protect, noconstant(0)
   DECLARE cparententityname = vc WITH protect, noconstant("")
   DECLARE cparententityid = f8 WITH protect, noconstant(0)
   DECLARE cparententityflag = i2 WITH protect, noconstant(0)
   DECLARE flexid = f8 WITH protect, noconstant(0)
   DECLARE parentflexid = f8 WITH protect, noconstant(0)
   DECLARE childflexid = f8 WITH protect, noconstant(0)
   FOR (cnt = 1 TO flextypecnt)
     SET flexparententityname = request->filter[filterindex].flex_types[cnt].parent_entity_name
     SET flexparententityid = request->filter[filterindex].flex_types[cnt].parent_entity_id
     SET flexparententityflag = request->filter[filterindex].flex_types[cnt].parent_entity_type_flag
     SET flexid = findflexid(flexparententityname,flexparententityid,flexparententityflag,0.0,0)
     IF (flexid=0)
      CALL generateflexid(flexid)
      CALL insertflex(flexid,0.0,flexparententityname,flexparententityid,flexparententityflag,
       0)
     ENDIF
     CALL insertvalues(filterindex,flexid,1,datamartcategoryid)
   ENDFOR
   FOR (gcnt = 1 TO groupcnt)
     SET pparententityname = request->filter[filterindex].groups[gcnt].parent_parent_entity_name
     SET pparententityid = request->filter[filterindex].groups[gcnt].parent_parent_entity_id
     SET pparententityflag = request->filter[filterindex].groups[gcnt].parent_parent_entity_type_flag
     SET cparententityname = request->filter[filterindex].groups[gcnt].child_parent_entity_name
     SET cparententityid = request->filter[filterindex].groups[gcnt].child_parent_entity_id
     SET cparententityflag = request->filter[filterindex].groups[gcnt].child_parent_entity_type_flag
     SET parentflexid = findflexid(pparententityname,pparententityid,pparententityflag,0.0,1)
     IF (parentflexid > 0)
      SET childflexid = findflexid(cparententityname,cparententityid,cparententityflag,parentflexid,1
       )
      IF (childflexid=0)
       CALL generateflexid(childflexid)
       CALL insertflex(childflexid,parentflexid,cparententityname,cparententityid,cparententityflag,
        1)
      ENDIF
     ELSE
      CALL generateflexid(parentflexid)
      CALL insertflex(parentflexid,0.0,pparententityname,pparententityid,pparententityflag,
       1)
      CALL generateflexid(childflexid)
      CALL insertflex(childflexid,parentflexid,cparententityname,cparententityid,cparententityflag,
       1)
     ENDIF
     CALL insertvalues(filterindex,childflexid,1,datamartcategoryid)
   ENDFOR
   CALL bedlogmessage("processFlexedSettings","Exiting ...")
 END ;Subroutine
 SUBROUTINE getgroupseq(filterindex,use_group_seq,group_seq)
   CALL bedlogmessage("getGroupSeq","Entering ...")
   SET use_group_seq = 0
   SET group_seq = 0
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_value v
    PLAN (f
     WHERE (f.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id)
      AND f.filter_category_mean="ORDER")
     JOIN (v
     WHERE v.br_datamart_category_id=outerjoin(f.br_datamart_category_id)
      AND v.br_datamart_filter_id=outerjoin(f.br_datamart_filter_id)
      AND v.logical_domain_id=outerjoin(logical_domain_id))
    ORDER BY v.group_seq
    DETAIL
     use_group_seq = 1, group_seq = v.group_seq
    WITH nocounter
   ;end select
   CALL bedlogmessage("getGroupSeq","Exitng ...")
 END ;Subroutine
 SUBROUTINE determineparententitynames(filterindex,valueindex,parent_entity_name,parent_entity_name2)
   CALL bedlogmessage("determineParentEntityNames","Entering ...")
   DECLARE parent_entity_id = f8 WITH protect, noconstant(0)
   DECLARE freetext_desc = vc WITH protect, noconstant("")
   SET parent_entity_name = ""
   SET parent_entity_name2 = ""
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_filter_category c
    PLAN (f
     WHERE (f.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id))
     JOIN (c
     WHERE c.filter_category_mean=outerjoin(f.filter_category_mean))
    DETAIL
     IF (c.filter_category_type_mean="MAP")
      parent_entity_name = validate(request->filter[filterindex].value[valueindex].parent_entity_name,
       ""), parent_entity_name2 = validate(request->filter[filterindex].value[valueindex].
       parent_entity_name2,"")
     ELSEIF (f.filter_category_mean IN ("ENC_TYPE", "FACILITY", "EVENT", "NU_STATUS", "ORDER",
     "CE_GROUP", "CE_BP", "EVENT_SEQ", "EVENT_SET", "NU_EXCL",
     "DISC_DISP", "ADM_SRC", "NU_INCL", "UNIT_SELECT", "ADM_TYPE",
     "RACE", "ORGANISM", "PT_PRSNL", "ENC_PRSNL", "PATHWAY_STATUS",
     "DISC_DISP_ASSIGN", "ADM_SRC_ASSIGN", "CAT_TYPE_ASSIGN", "POWERPLAN_CLASS", "PLAN_LEVEL_STATUS",
     "FIN_CLASS", "PRIM_EVENT_SET", "EVENT_SET_SEQ", "DTA", "UNIT_ROOM_BED_SELECT",
     "UNIT_AMB_RAD_SURG_SELECT", "TASK_TYPE_ASSIGN", "FACILITY_LOC_TEXT", "LOOK_BACK",
     "LABRAD_SELECT",
     "CODE_SET_FILTERING"))
      parent_entity_name = "CODE_VALUE"
     ELSEIF (f.filter_category_mean IN ("CHARGES_VISIT_ASSIGN"))
      parent_entity_name = "CODE_VALUE", parent_entity_name2 = "CODE_VALUE"
     ELSEIF (f.filter_category_mean IN ("EVENT_NOMEN", "PROBLEM", "PROCEDURE", "PROBLEM_RELTN",
     "DTA_NOMEN",
     "NOMENCLATURE"))
      parent_entity_name = "NOMENCLATURE"
     ELSEIF (f.filter_category_mean IN ("POWERPLAN"))
      parent_entity_name = "PATHWAY_CATALOG"
     ELSEIF (f.filter_category_mean IN ("ORDER_DETAILS"))
      parent_entity_name = "OE_FIELD_MEANING"
     ELSEIF (f.filter_category_mean IN ("PF_SINGLE_SELECT"))
      parent_entity_name = "DCP_FORMS_REF"
     ELSEIF (f.filter_category_mean IN ("MULTUM_CAT", "MULTUM_CAT_SEQ", "MULTUM_LEVEL_SEQ"))
      parent_entity_name = "MLTM_DRUG_CATEGORIES"
     ELSEIF (f.filter_category_mean IN ("THER_DUP_CLASS"))
      parent_entity_name = "MLTM_DUPLICATION_CATEGORIES"
     ELSEIF (f.filter_category_mean IN ("SYNONYM"))
      parent_entity_name = "ORDER_CATALOG_SYNONYM"
     ELSEIF (f.filter_category_mean IN ("OUTCOME_VENUE_IP", "OUTCOME_VENUE_OR"))
      parent_entity_name = "PATHWAY_CATALOG", parent_entity_name2 = "OUTCOME_CATALOG"
     ELSEIF (f.filter_category_mean IN ("SURG_TRACK_VIEW"))
      parent_entity_name = "PREDEFINED_PREFS"
     ELSEIF (f.filter_category_mean IN ("PF_MULTI_SELECT"))
      parent_entity_name = "DCP_FORMS_REF"
     ELSEIF (f.filter_category_mean IN ("ED_INSTRUCTIONS"))
      parent_entity_name = " "
     ELSEIF (f.filter_category_mean IN ("HME_SAT"))
      parent_entity_name = "HM_EXPECT_SAT"
     ELSEIF (f.filter_category_mean IN ("XR_TEMPLATE"))
      parent_entity_name = "cr_report_template"
     ELSEIF (f.filter_category_mean IN ("XR_TEMPLATE_DEFAULT"))
      parent_entity_name = "cr_report_template"
     ELSEIF (f.filter_category_mean IN ("IVIEW_SELECT"))
      parent_entity_name = "WORKING_VIEW"
     ELSEIF (f.filter_category_mean IN ("EP_SELECTION"))
      parent_entity_name = "PERSON"
     ELSEIF (f.filter_category_mean IN ("HCO_SELECTION", "HCO_TJC_SELECTION", "HCO_DATE",
     "HCO_SAMPLE", "HCO_OVERSAMPLE"))
      parent_entity_name = "BR_HCO"
     ELSEIF (f.filter_category_mean IN ("CCN_PSYCH", "CCN_PSYCHSEL", "CCN_ACUTE", "CCN_ACUTESEL",
     "CCN_SAMPLE",
     "CCN_OVERSAMPLE", "CCNALL", "CCNDATE"))
      parent_entity_name = "BR_CCN"
     ELSEIF (f.filter_category_mean IN ("ORDER_FOLDER"))
      parent_entity_name = "ALT_SEL_CAT"
     ELSEIF (f.filter_category_mean IN ("DMS_CONTENT_TYPE"))
      parent_entity_name = "DMS_CONTENT_TYPE"
     ELSEIF (f.filter_category_mean IN ("PROVIDER"))
      parent_entity_name = "PRSNL"
     ELSEIF (f.filter_category_mean IN ("EVENTCONCEPT"))
      parent_entity_name = "BR_EVENT_GROUPER"
     ELSEIF (f.filter_category_mean IN ("ALLERGY_CAT"))
      parent_entity_name = "MLTM_ALR_CATEGORY"
     ELSEIF (f.filter_category_mean IN ("EVENT_TEMPLATE"))
      parent_entity_name = "NOTE_TYPE", parent_entity_name2 = "DD_REF_TEMPLATE"
     ELSEIF (f.filter_category_mean IN ("EVENT_TEMPLATE_GROUP"))
      parent_entity_name = "NOTE_TYPE", parent_entity_name2 = "DD_REF_TEMPLATE"
     ELSEIF (c.filter_category_type_mean IN ("CUSTOM_CCL", "CMT_CUSTOM_CCL"))
      parent_entity_name = validate(request->filter[filterindex].value[valueindex].parent_entity_name,
       " ")
     ELSEIF (f.filter_category_mean IN ("SYN_VACC_GROUP_ASSIGN", "SYN_CATEGORY_ASSIGN"))
      parent_entity_name = validate(request->filter[filterindex].value[valueindex].parent_entity_name,
       " "), parent_entity_name2 = validate(request->filter[filterindex].value[valueindex].
       parent_entity_name2," ")
     ELSEIF (f.filter_category_mean IN (message_cntr_pool_mean))
      parent_entity_name = "PRSNL_GROUP", parent_entity_name2 = validate(request->filter[filterindex]
       .value[valueindex].parent_entity_name2," ")
     ENDIF
    WITH nocounter
   ;end select
   SET parent_entity_id = request->filter[filterindex].value[valueindex].parent_entity_id
   SET freetext_desc = request->filter[filterindex].value[valueindex].freetext_desc
   IF (parent_entity_id > 0
    AND freetext_desc IN (meaning_temperature, meaning_blood_pressure, meaning_heart_rate))
    SELECT INTO "nl:"
     FROM br_datamart_filter b
     PLAN (b
      WHERE b.br_datamart_filter_id=parent_entity_id)
     DETAIL
      parent_entity_name = "BR_DATAMART_FILTER"
     WITH nocounter
    ;end select
   ENDIF
   IF (((cnvtupper(request->filter[filterindex].value[valueindex].mpage_param_mean)=
   "MP_LOOK_BACK_UNITS") OR (cnvtupper(request->filter[filterindex].value[valueindex].
    mpage_param_mean)="MP_LOOK_BACK_CUR_ENC"))
    AND (request->filter[filterindex].value[valueindex].parent_entity_id > 0))
    SET parent_entity_name = "CODE_VALUE"
   ENDIF
   IF (parent_entity_name IN ("", " ", null)
    AND (request->filter[filterindex].value[valueindex].parent_entity_id > 0))
    SELECT INTO "nl:"
     FROM br_datamart_filter b,
      br_datamart_filter_category c
     PLAN (b
      WHERE (b.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id))
      JOIN (c
      WHERE c.filter_category_mean=b.filter_category_mean
       AND c.codeset > 0)
     DETAIL
      parent_entity_name = "CODE_VALUE"
     WITH nocounter
    ;end select
   ENDIF
   CALL bedlogmessage("determineParentEntityNames","Exiting ...")
 END ;Subroutine
 SUBROUTINE getvalueseq(filterindex,use_value_seq,value_seq)
   CALL bedlogmessage("getValueSeq","Entering ...")
   SET use_value_seq = 0
   SET value_seq = 0
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_value v
    PLAN (f
     WHERE (f.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id)
      AND f.filter_category_mean IN ("EVENT", "DTA"))
     JOIN (v
     WHERE v.br_datamart_category_id=outerjoin(f.br_datamart_category_id)
      AND v.br_datamart_filter_id=outerjoin(f.br_datamart_filter_id)
      AND v.logical_domain_id=outerjoin(logical_domain_id))
    ORDER BY v.value_seq
    DETAIL
     use_value_seq = 1, value_seq = v.value_seq
    WITH nocounter
   ;end select
   SET value_seq = (value_seq+ 1)
   CALL bedlogmessage("getValueSeq","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertdatamartvalue(filterindex,valueindex,temp_flex_id,parent_entity_name,
  parent_entity_name2,use_group_seq,group_seq,use_value_seq,value_seq,datamartcategoryid)
   CALL bedlogmessage("insertDatamartValue","Entering ...")
   DECLARE parententityid2 = f8 WITH protect, noconstant(0)
   SET parententityid2 = validate(request->filter[filterindex].value[valueindex].parent_entity_id2,0)
   IF (filter_category_mean=message_cntr_pool_mean)
    IF (parententityid2 != 0.0)
     INSERT  FROM br_datamart_value b
      SET b.logical_domain_id = logical_domain_id, b.br_datamart_value_id = seq(bedrock_seq,nextval),
       b.br_datamart_category_id = datamartcategoryid,
       b.br_datamart_filter_id = request->filter[filterindex].br_datamart_filter_id, b
       .parent_entity_name =
       IF ((request->filter[filterindex].value[valueindex].parent_entity_id > 0)) parent_entity_name
       ELSE " "
       ENDIF
       , b.parent_entity_id = request->filter[filterindex].value[valueindex].parent_entity_id,
       b.parent_entity_name2 =
       IF (parententityid2 > 0) parent_entity_name2
       ELSE " "
       ENDIF
       , b.parent_entity_id2 = parententityid2, b.freetext_desc = request->filter[filterindex].value[
       valueindex].freetext_desc,
       b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), b.qualifier_flag = request->filter[filterindex].value[valueindex].
       qualifier_flag,
       b.value_seq =
       IF (use_value_seq=1
        AND (request->filter[filterindex].value[valueindex].value_seq=0)) value_seq
       ELSE request->filter[filterindex].value[valueindex].value_seq
       ENDIF
       , b.value_type_flag = request->filter[filterindex].value[valueindex].value_type_flag, b
       .value_dt_tm =
       IF (cnvtdatetime(request->filter[filterindex].value[valueindex].value_dt_tm) > 0) cnvtdatetime
        (request->filter[filterindex].value[valueindex].value_dt_tm)
       ELSE cnvtdatetime(curdate,curtime3)
       ENDIF
       ,
       b.group_seq =
       IF (use_group_seq=1
        AND (request->filter[filterindex].value[valueindex].group_seq=0)) group_seq
       ELSE request->filter[filterindex].value[valueindex].group_seq
       ENDIF
       , b.mpage_param_mean = request->filter[filterindex].value[valueindex].mpage_param_mean, b
       .mpage_param_value = request->filter[filterindex].value[valueindex].mpage_param_value,
       b.map_data_type_cd = validate(request->filter[filterindex].value[valueindex].map_data_type_cd,
        0.0), b.br_datamart_flex_id = temp_flex_id, b.updt_cnt = 0,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_applctx = reqinfo->updt_applctx
      PLAN (b)
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    INSERT  FROM br_datamart_value b
     SET b.logical_domain_id = logical_domain_id, b.br_datamart_value_id = seq(bedrock_seq,nextval),
      b.br_datamart_category_id = datamartcategoryid,
      b.br_datamart_filter_id = request->filter[filterindex].br_datamart_filter_id, b
      .parent_entity_name =
      IF ((request->filter[filterindex].value[valueindex].parent_entity_id > 0)) parent_entity_name
      ELSE " "
      ENDIF
      , b.parent_entity_id = request->filter[filterindex].value[valueindex].parent_entity_id,
      b.parent_entity_name2 =
      IF (parententityid2 > 0) parent_entity_name2
      ELSE " "
      ENDIF
      , b.parent_entity_id2 = parententityid2, b.freetext_desc = request->filter[filterindex].value[
      valueindex].freetext_desc,
      b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), b.qualifier_flag = request->filter[filterindex].value[valueindex].
      qualifier_flag,
      b.value_seq =
      IF (use_value_seq=1
       AND (request->filter[filterindex].value[valueindex].value_seq=0)) value_seq
      ELSE request->filter[filterindex].value[valueindex].value_seq
      ENDIF
      , b.value_type_flag = request->filter[filterindex].value[valueindex].value_type_flag, b
      .value_dt_tm =
      IF (cnvtdatetime(request->filter[filterindex].value[valueindex].value_dt_tm) > 0) cnvtdatetime(
        request->filter[filterindex].value[valueindex].value_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      b.group_seq =
      IF (use_group_seq=1
       AND (request->filter[filterindex].value[valueindex].group_seq=0)) group_seq
      ELSE request->filter[filterindex].value[valueindex].group_seq
      ENDIF
      , b.mpage_param_mean = request->filter[filterindex].value[valueindex].mpage_param_mean, b
      .mpage_param_value = request->filter[filterindex].value[valueindex].mpage_param_value,
      b.map_data_type_cd = validate(request->filter[filterindex].value[valueindex].map_data_type_cd,
       0.0), b.br_datamart_flex_id = temp_flex_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     PLAN (b)
     WITH nocounter
    ;end insert
   ENDIF
   CALL bederrorcheck("Error inserting into br_datamart_value.")
   CALL bedlogmessage("insertDatamartValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatebasetargetvalue(mpageparamvalue,mpageparammean,parententityname,parententityid)
   CALL bedlogmessage("updateBaseTargetValue","Entering ...")
   UPDATE  FROM br_datamart_value v
    SET v.mpage_param_value = mpageparamvalue, v.updt_id = reqinfo->updt_id, v.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
     .updt_cnt+ 1)
    WHERE v.br_datamart_filter_id=0
     AND v.logical_domain_id=logical_domain_id
     AND v.parent_entity_name=parententityname
     AND v.parent_entity_id=parententityid
     AND v.mpage_param_mean=mpageparammean
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error update report value")
   CALL bedlogmessage("updateBaseTargetValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE insertbasetargetvalue(datamartcategoryid,mpageparammean,mpageparamvalue,parententityname,
  parententityid)
   CALL bedlogmessage("insertBaseTargetValue","Entering ...")
   INSERT  FROM br_datamart_value b
    SET b.logical_domain_id = logical_domain_id, b.br_datamart_value_id = seq(bedrock_seq,nextval), b
     .br_datamart_category_id = datamartcategoryid,
     b.br_datamart_filter_id = 0, b.parent_entity_name = parententityname, b.parent_entity_id =
     parententityid,
     b.mpage_param_mean = mpageparammean, b.mpage_param_value = mpageparamvalue, b.map_data_type_cd
      = 0.0,
     b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error inserting br_datamart_value")
   CALL bedlogmessage("insertBaseTargetValue","Exiting ...")
 END ;Subroutine
 SUBROUTINE determinebaselinetargetind(parententityid,parententityname,baseind,targetind)
   CALL bedlogmessage("determineBaselineTargetInd","Entering ...")
   SET baseind = 0
   SET targetind = 0
   SELECT INTO "nl:"
    FROM br_datamart_value v
    PLAN (v
     WHERE v.br_datamart_filter_id=0
      AND v.logical_domain_id=logical_domain_id
      AND v.parent_entity_name=parententityname
      AND v.parent_entity_id=parententityid
      AND cnvtupper(v.mpage_param_mean) IN ("BASELINE", "TARGET"))
    DETAIL
     IF (cnvtupper(v.mpage_param_mean)="BASELINE")
      baseind = 1
     ELSEIF (cnvtupper(v.mpage_param_mean)="TARGET")
      targetind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bedlogmessage("determineBaselineTargetInd","Exiting ...")
 END ;Subroutine
 SUBROUTINE handledatamartreportupdates(brdatamartreportid,baselinevalue,targetvalue)
   CALL bedlogmessage("handleDatamartReportUpdates","Entering ...")
   DECLARE lhbasetargetupdind = i2 WITH protect, noconstant(0)
   DECLARE lhcategoryind = i2 WITH protect, noconstant(0)
   DECLARE datamartcategoryid = f8 WITH protect, noconstant(0)
   DECLARE iccategoryind = i2 WITH protect, noconstant(0)
   DECLARE baselinerowind = i2 WITH protect, noconstant(0)
   DECLARE targetrowind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_name_value b
    WHERE b.br_nv_key1="LH_BASE_TARGET_UPD"
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET lhbasetargetupdind = 1
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_report r,
     br_datamart_category c
    PLAN (r
     WHERE r.br_datamart_report_id=brdatamartreportid)
     JOIN (c
     WHERE c.br_datamart_category_id=r.br_datamart_category_id)
    DETAIL
     IF (c.category_type_flag=0)
      lhcategoryind = 1, datamartcategoryid = r.br_datamart_category_id
     ELSEIF (c.category_type_flag=4)
      iccategoryind = 1, datamartcategoryid = r.br_datamart_category_id
     ENDIF
    WITH nocounter
   ;end select
   IF (((lhbasetargetupdind=1
    AND lhcategoryind=1) OR (iccategoryind=1)) )
    CALL determinebaselinetargetind(brdatamartreportid,"BR_DATAMART_REPORT",baselinerowind,
     targetrowind)
    IF (baselinerowind=1)
     CALL updatebasetargetvalue(baselinevalue,"baseline","BR_DATAMART_REPORT",brdatamartreportid)
    ELSE
     CALL insertbasetargetvalue(datamartcategoryid,"baseline",baselinevalue,"BR_DATAMART_REPORT",
      brdatamartreportid)
    ENDIF
    IF (targetrowind=1)
     CALL updatebasetargetvalue(targetvalue,"target","BR_DATAMART_REPORT",brdatamartreportid)
    ELSE
     CALL insertbasetargetvalue(datamartcategoryid,"target",targetvalue,"BR_DATAMART_REPORT",
      brdatamartreportid)
    ENDIF
   ELSE
    UPDATE  FROM br_datamart_report b
     SET b.baseline_value = baselinevalue, b.target_value = targetvalue, b.updt_id = reqinfo->updt_id,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_task = reqinfo->updt_task, b.updt_applctx
       = reqinfo->updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1)
     PLAN (b
      WHERE b.br_datamart_report_id=brdatamartreportid)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Update report br_datamart_report")
   ENDIF
   CALL bedlogmessage("handleDatamartReportUpdates","Exiting ...")
 END ;Subroutine
 SUBROUTINE handledatamartcategoryupdates(brdatamartcategoryid,baselinevalue,targetvalue)
   CALL bedlogmessage("handleDatamartCategoryUpdates","Entering ...")
   DECLARE lhcategoryind = i2 WITH protect, noconstant(0)
   DECLARE iccategoryind = i2 WITH protect, noconstant(0)
   DECLARE baselinerowind = i2 WITH protect, noconstant(0)
   DECLARE targetrowind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category c
    PLAN (c
     WHERE c.br_datamart_category_id=brdatamartcategoryid
      AND c.category_type_flag IN (0, null, 4))
    DETAIL
     IF (c.category_type_flag IN (0, null))
      lhcategoryind = 1
     ELSEIF (c.category_type_flag=4)
      iccategoryind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (((lhcategoryind=1) OR (iccategoryind=1)) )
    CALL determinebaselinetargetind(brdatamartcategoryid,"BR_DATAMART_CATEGORY",baselinerowind,
     targetrowind)
    IF (baselinerowind=1)
     CALL updatebasetargetvalue(baselinevalue,"BASELINE","BR_DATAMART_CATEGORY",brdatamartcategoryid)
    ELSE
     CALL insertbasetargetvalue(brdatamartcategoryid,"BASELINE",baselinevalue,"BR_DATAMART_CATEGORY",
      brdatamartcategoryid)
    ENDIF
    IF (targetrowind=1)
     CALL updatebasetargetvalue(targetvalue,"TARGET","BR_DATAMART_CATEGORY",brdatamartcategoryid)
    ELSE
     CALL insertbasetargetvalue(brdatamartcategoryid,"TARGET",targetvalue,"BR_DATAMART_CATEGORY",
      brdatamartcategoryid)
    ENDIF
   ENDIF
   CALL bedlogmessage("handleDatamartCategoryUpdates","Exiting ...")
 END ;Subroutine
 SUBROUTINE isinsertionneeded(filterindex,childflexid,valueidx,datamartcategoryid)
   DECLARE currentvalueseq = f8 WITH protect, noconstant(0.0)
   DECLARE brdatamartvalueid = f8 WITH protect, noconstant(0.0)
   DECLARE filter_category_mean = vc WITH protect
   SET filter_category_mean = getfiltercategorymeaning(request->filter[filterindex].
    br_datamart_filter_id)
   SELECT
    IF (filter_category_mean=multi_freetext_filter_cat_mean)
     WHERE (b.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id)
      AND (b.parent_entity_id=request->filter[filterindex].value[valueidx].parent_entity_id)
      AND b.br_datamart_category_id=datamartcategoryid
      AND b.br_datamart_flex_id=childflexid
      AND (b.freetext_desc=request->filter[filterindex].value[valueidx].freetext_desc)
      AND (b.value_seq=request->filter[filterindex].value[valueidx].value_seq)
    ELSE
     WHERE (b.br_datamart_filter_id=request->filter[filterindex].br_datamart_filter_id)
      AND (b.parent_entity_id=request->filter[filterindex].value[valueidx].parent_entity_id)
      AND b.br_datamart_category_id=datamartcategoryid
      AND b.br_datamart_flex_id=childflexid
    ENDIF
    INTO "nl:"
    FROM br_datamart_value b
    DETAIL
     currentvalueseq = b.value_seq, brdatamartvalueid = b.br_datamart_value_id
    WITH nocounter
   ;end select
   IF (curqual=1
    AND (request->filter[filterindex].value[valueidx].value_seq=currentvalueseq))
    RETURN(0)
   ELSEIF (curqual=1
    AND (request->filter[filterindex].value[valueidx].value_seq != currentvalueseq))
    UPDATE  FROM br_datamart_value b
     SET b.value_seq = request->filter[filterindex].value[valueidx].value_seq, b.updt_id = reqinfo->
      updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
      .updt_cnt+ 1)
     WHERE b.br_datamart_value_id=brdatamartvalueid
      AND (b.freetext_desc=request->filter[filterindex].value[valueidx].freetext_desc)
     WITH nocounter
    ;end update
    RETURN(0)
   ELSEIF (curqual=0)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE copydatamartdeletevalues(categoryid,filterid,flexid)
   CALL bedlogmessage("copyDatamartDeleteValues","Entering ...")
   IF (filter_category_mean=message_cntr_pool_mean)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(value_indx)),
      br_datamart_value b
     PLAN (d)
      JOIN (b
      WHERE b.br_datamart_category_id=categoryid
       AND b.br_datamart_filter_id=filterid
       AND b.br_datamart_flex_id=flexid
       AND b.logical_domain_id=logical_domain_id
       AND (b.parent_entity_id=request->filter[filteridx].value[d.seq].parent_entity_id))
     ORDER BY b.br_datamart_value_id
     HEAD REPORT
      delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
     HEAD b.br_datamart_value_id
      delete_hist_cnt = (delete_hist_cnt+ 1)
      IF (mod(delete_hist_cnt,100)=1
       AND delete_hist_cnt > 100)
       stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 99))
      ENDIF
     DETAIL
      delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = b.br_datamart_value_id,
      delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL echorecord(delete_hist)
   ELSE
    SELECT INTO "nl:"
     FROM br_datamart_value b
     PLAN (b
      WHERE b.br_datamart_category_id=categoryid
       AND b.br_datamart_filter_id=filterid
       AND b.br_datamart_flex_id=flexid
       AND b.logical_domain_id=logical_domain_id)
     ORDER BY b.br_datamart_value_id
     HEAD REPORT
      delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
     HEAD b.br_datamart_value_id
      delete_hist_cnt = (delete_hist_cnt+ 1)
      IF (mod(delete_hist_cnt,100)=1
       AND delete_hist_cnt > 100)
       stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 99))
      ENDIF
     DETAIL
      delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = b.br_datamart_value_id,
      delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(delete_hist)
   ENDIF
   CALL bederrorcheck("Error copying datamart delete values.")
   CALL bedlogmessage("copyDatamartDeleteValues","Exiting ...")
 END ;Subroutine
 SUBROUTINE getfiltercategorymeaning(filtrid)
   CALL bedlogmessage("getFilterCategoryMeaning","Entering ...")
   DECLARE filter_cat_mean = vc WITH protect
   SELECT INTO "nl:"
    FROM br_datamart_filter f
    PLAN (f
     WHERE f.br_datamart_filter_id=filtrid)
    DETAIL
     filter_cat_mean = f.filter_category_mean
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error fetching filter category meaning.")
   CALL bedlogmessage("getFilterCategoryMeaning","Exiting ...")
   RETURN(filter_cat_mean)
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE meaning_temperature = vc WITH protect, constant("<Temperature>")
 DECLARE meaning_blood_pressure = vc WITH protect, constant("<Blood Pressure>")
 DECLARE meaning_heart_rate = vc WITH protect, constant("<Heart Rate>")
 DECLARE filter_cnt = i4 WITH protect, constant(size(request->filter,5))
 DECLARE message_cntr_pool_mean = vc WITH protect, constant("MESSAGE_CENTERPOOL_EP")
 DECLARE filteridx = i4 WITH protect, noconstant(0)
 DECLARE flexid = f8 WITH protect, noconstant(0)
 DECLARE flextypescnt = i4 WITH protect, noconstant(0)
 DECLARE groupscnt = i4 WITH protect, noconstant(0)
 DECLARE delete_hist_cnt = i4 WITH protect, noconstant(0)
 DECLARE value_indx = i4 WITH protect, noconstant(0)
 DECLARE filter_category_mean = vc WITH protect, noconstant("")
 DECLARE datamartcategoryid = f8 WITH protect, noconstant(0.0)
 DECLARE datamartreportid = f8 WITH protect, noconstant(0.0)
 DECLARE baselinevalue = vc WITH protect, noconstant("")
 DECLARE targetvalue = vc WITH protect, noconstant("")
 SET datamartcategoryid = request->br_datamart_category_id
 SET datamartreportid = request->br_datamart_report_id
 SET baselinevalue = request->baseline_value
 SET targetvalue = request->target_value
 FOR (filteridx = 1 TO filter_cnt)
   SET flexid = request->filter[filteridx].flex_id
   SET flextypescnt = size(request->filter[filteridx].flex_types,5)
   IF (validate(request->filter[filteridx].groups))
    SET groupscnt = size(request->filter[filteridx].groups,5)
   ENDIF
   IF (validate(request->filter[filteridx].value))
    SET value_indx = size(request->filter[filteridx].value,5)
   ENDIF
   SET filter_category_mean = getfiltercategorymeaning(request->filter[filteridx].
    br_datamart_filter_id)
   IF (flexid=0
    AND flextypescnt=0
    AND groupscnt=0)
    CALL bedlogmessage("Begin","Processing default settings")
    CALL copydatamartdeletevalues(datamartcategoryid,request->filter[filteridx].br_datamart_filter_id,
     0.0)
    CALL deletevalues(datamartcategoryid,request->filter[filteridx].br_datamart_filter_id,0.0)
    IF (delete_hist_cnt > 0)
     EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",delete_hist)
    ENDIF
    CALL insertvalues(filteridx,flexid,0,datamartcategoryid)
    CALL bedlogmessage("End","Processing default settings")
   ENDIF
   IF (flexid > 0)
    CALL bedlogmessage("Begin","Modify flex settings")
    CALL copydatamartdeletevalues(datamartcategoryid,request->filter[filteridx].br_datamart_filter_id,
     flexid)
    CALL deletevalues(datamartcategoryid,request->filter[filteridx].br_datamart_filter_id,flexid)
    IF (delete_hist_cnt > 0)
     EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",delete_hist)
    ENDIF
    CALL insertvalues(filteridx,flexid,0,datamartcategoryid)
    CALL bedlogmessage("End","Modify flex settings")
   ELSEIF (((flextypescnt > 0) OR (groupscnt > 0)) )
    CALL bedlogmessage("Begin","Add flex settings")
    CALL processflexedsettings(filteridx,flextypescnt,groupscnt,datamartcategoryid)
    CALL bedlogmessage("End","Add flex settings")
   ENDIF
 ENDFOR
 IF (datamartreportid > 0)
  CALL handledatamartreportupdates(datamartreportid,baselinevalue,targetvalue)
 ENDIF
 IF (datamartcategoryid > 0
  AND datamartreportid=0)
  CALL handledatamartcategoryupdates(datamartcategoryid,baselinevalue,targetvalue)
 ENDIF
#exit_script
 CALL bedexitscript(1)
END GO
