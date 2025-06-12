CREATE PROGRAM bed_ens_datamart_report_val:dba
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
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
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
 CALL bedbeginscript(0)
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE category_id = f8 WITH protect, noconstant(0)
 DECLARE flexid = f8 WITH protect, noconstant(0)
 DECLARE flextypescnt = i4 WITH protect, noconstant(0)
 DECLARE groupscnt = i4 WITH protect, noconstant(0)
 DECLARE reportcnt = i4 WITH protect, noconstant(0)
 DECLARE delete_hist_cnt = i4 WITH protect, noconstant(0)
 DECLARE mpage_mode_flag = i2 WITH protect, noconstant(0)
 DECLARE getcategoryid(catid=f8(ref)) = i2
 DECLARE deletevalues(flexid=f8) = i2
 DECLARE insertvalues(reportid=f8,mposseq=i4,mposflag=i4,flexid=f8) = i2
 DECLARE copydatamartdeletevalues(categoryid=f8,filterid=f8,flexid=f8) = i2
 SET reportcnt = size(request->reports,5)
 IF (reportcnt=0)
  CALL bedexitsuccess(0)
 ENDIF
 SET mpage_mode_flag = request->mpage_mode_flag
 IF (mpage_mode_flag=1)
  CALL echo(mpage_mode_flag)
  SET flexid = 0
 ELSE
  SET flexid = request->reports[1].flex_id
 ENDIF
 CALL getcategoryid(category_id)
 SET flextypescnt = size(request->reports[1].flex_types,5)
 SET groupscnt = size(request->reports[1].groups,5)
 IF (flexid=0
  AND flextypescnt=0
  AND groupscnt=0)
  CALL bedlogmessage("Begin","Processing default settings")
  CALL copydatamartdeletevalues(flexid)
  CALL deletevalues(flexid)
  IF (delete_hist_cnt > 0)
   EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",delete_hist)
  ENDIF
  FOR (reportidx = 1 TO reportcnt)
    CALL insertvalues(request->reports[reportidx].br_datamart_report_id,request->reports[reportidx].
     mpage_pos_seq,request->reports[reportidx].mpage_pos_flag,0.0)
  ENDFOR
  CALL bedlogmessage("End","Processing default settings")
 ENDIF
 IF (flexid > 0)
  CALL bedlogmessage("Begin","Modify flex settings")
  CALL copydatamartdeletevalues(flexid)
  CALL deletevalues(flexid)
  IF (delete_hist_cnt > 0)
   EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",delete_hist)
  ENDIF
  FOR (reportidx = 1 TO reportcnt)
    CALL insertvalues(request->reports[reportidx].br_datamart_report_id,request->reports[reportidx].
     mpage_pos_seq,request->reports[reportidx].mpage_pos_flag,flexid)
  ENDFOR
  CALL bedlogmessage("End","Modify flex settings")
 ELSEIF (((flextypescnt > 0) OR (groupscnt > 0)) )
  CALL bedlogmessage("Begin","Add flex settings")
  FOR (reportidx = 1 TO reportcnt)
    CALL processflexedsettings(reportidx,flextypescnt,groupscnt)
  ENDFOR
  CALL bedlogmessage("End","Add flex settings")
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getcategoryid(catid)
   CALL bedlogmessage("getCategoryId","Entering ...")
   SET catid = 0.0
   SELECT INTO "nl:"
    FROM br_datamart_report b
    PLAN (b
     WHERE (b.br_datamart_report_id=request->reports[1].br_datamart_report_id))
    DETAIL
     catid = b.br_datamart_category_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("getCategoryId","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletevalues(flexid)
   CALL bedlogmessage("deleteValues","Entering ...")
   CALL echo(flexid)
   SELECT INTO "nl:"
    FROM br_datamart_value d
    PLAN (d
     WHERE d.br_datamart_category_id=category_id
      AND d.logical_domain_id=logical_domain_id
      AND d.parent_entity_name="BR_DATAMART_REPORT"
      AND d.br_datamart_flex_id=flexid
      AND ((cnvtupper(d.mpage_param_mean) != "MP_VB_COMPONENT_STATUS") OR (d.mpage_param_mean=null))
     )
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo("Deleting... ")
    DELETE  FROM br_datamart_value d
     PLAN (d
      WHERE d.br_datamart_category_id=category_id
       AND d.logical_domain_id=logical_domain_id
       AND d.parent_entity_name="BR_DATAMART_REPORT"
       AND d.br_datamart_flex_id=flexid
       AND ((cnvtupper(d.mpage_param_mean) != "MP_VB_COMPONENT_STATUS") OR (d.mpage_param_mean=null
      )) )
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error deleting 1.")
    CALL bedlogmessage("deleteValues","Exiting ...")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertvalues(reportid,mposseq,mposflag,flexid)
   CALL bedlogmessage("insertValues","Entering ...")
   INSERT  FROM br_datamart_value b
    SET b.logical_domain_id = logical_domain_id, b.br_datamart_value_id = seq(bedrock_seq,nextval), b
     .br_datamart_category_id = category_id,
     b.parent_entity_name = "BR_DATAMART_REPORT", b.parent_entity_id = reportid, b
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.value_seq = mposseq, b.value_type_flag =
     mposflag,
     b.br_datamart_flex_id = flexid, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   CALL bedlogmessage("insertValues","Exiting ...")
 END ;Subroutine
 SUBROUTINE processflexedsettings(reportindex,flextypecnt,groupcnt)
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
     SET flexparententityname = request->reports[reportindex].flex_types[cnt].parent_entity_name
     SET flexparententityid = request->reports[reportindex].flex_types[cnt].parent_entity_value
     SET flexparententityflag = request->reports[reportindex].flex_types[cnt].parent_entity_type_flag
     SET flexid = findflexid(flexparententityname,flexparententityid,flexparententityflag,0.0,0)
     IF (flexid=0)
      CALL generateflexid(flexid)
      CALL insertflex(flexid,0.0,flexparententityname,flexparententityid,flexparententityflag,
       0)
     ENDIF
     CALL insertvalues(request->reports[reportindex].br_datamart_report_id,request->reports[
      reportindex].mpage_pos_seq,request->reports[reportindex].mpage_pos_flag,flexid)
   ENDFOR
   FOR (gcnt = 1 TO groupcnt)
     SET pparententityname = request->reports[reportindex].groups[gcnt].parent_parent_entity_name
     SET pparententityid = request->reports[reportindex].groups[gcnt].parent_parent_entity_id
     SET pparententityflag = request->reports[reportindex].groups[gcnt].
     parent_parent_entity_type_flag
     SET cparententityname = request->reports[reportindex].groups[gcnt].child_parent_entity_name
     SET cparententityid = request->reports[reportindex].groups[gcnt].child_parent_entity_id
     SET cparententityflag = request->reports[reportindex].groups[gcnt].child_parent_entity_type_flag
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
     CALL insertvalues(request->reports[reportindex].br_datamart_report_id,request->reports[
      reportindex].mpage_pos_seq,request->reports[reportindex].mpage_pos_flag,childflexid)
   ENDFOR
   CALL bedlogmessage("processFlexedSettings","Exiting ...")
 END ;Subroutine
 SUBROUTINE copydatamartdeletevalues(flexid)
   SELECT INTO "nl:"
    FROM br_datamart_value b
    PLAN (b
     WHERE b.br_datamart_category_id=category_id
      AND b.logical_domain_id=logical_domain_id
      AND b.parent_entity_name="BR_DATAMART_REPORT"
      AND b.br_datamart_flex_id=flexid
      AND ((cnvtupper(b.mpage_param_mean) != "MP_VB_COMPONENT_STATUS") OR (b.mpage_param_mean=null))
     )
    ORDER BY b.br_datamart_value_id
    HEAD REPORT
     delete_hist_cnt = 0, stat = alterlist(delete_hist->deleted_items,100)
    HEAD b.br_datamart_value_id
     delete_hist_cnt = (delete_hist_cnt+ 1)
     IF (mod(delete_hist_cnt,10)=1
      AND delete_hist_cnt > 100)
      stat = alterlist(delete_hist->deleted_items,(delete_hist_cnt+ 10))
     ENDIF
    DETAIL
     delete_hist->deleted_items[delete_hist_cnt].parent_entity_id = b.br_datamart_value_id,
     delete_hist->deleted_items[delete_hist_cnt].parent_entity_name = "BR_DATAMART_VALUE"
    FOOT REPORT
     stat = alterlist(delete_hist->deleted_items,delete_hist_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error copying datamart delete values.")
   CALL bedlogmessage("copyDatamartDeleteValues","Exiting ...")
 END ;Subroutine
END GO
