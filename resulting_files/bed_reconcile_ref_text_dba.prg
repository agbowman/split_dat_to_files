CREATE PROGRAM bed_reconcile_ref_text:dba
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
 FREE RECORD reftextcontent
 RECORD reftextcontent(
   1 list[*]
     2 textrefuid = vc
     2 typecd = f8
     2 text = gvc
 )
 FREE RECORD reftextexisting
 RECORD reftextexisting(
   1 list[*]
     2 reftextid = f8
     2 typecd = f8
     2 text = gvc
     2 processedind = i2
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
 DECLARE getreftextfromcontent(taskassayuid=vc) = i2
 DECLARE getexistingreftext(taskassaycd=f8) = i2
 DECLARE removetext(reftextid=f8) = i2
 DECLARE inserttext(index=i4,typecd=f8) = i2
 DECLARE generatereferencepk(dummyvar=i2) = f8
 DECLARE reftextcontentcnt = i4 WITH protect, noconstant(0)
 DECLARE reftextexistingcnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE k = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE efound = i4 WITH protect, noconstant(0)
 CALL getreftextfromcontent(request->taskassayuid)
 CALL getexistingreftext(request->taskassaycd)
 SET reftextcontentcnt = size(reftextcontent->list,5)
 SET reftextexistingcnt = size(reftextexisting->list,5)
 IF (reftextcontentcnt=0
  AND reftextexistingcnt > 0)
  FOR (k = 1 TO reftextexistingcnt)
    CALL removetext(reftextexisting->list[k].reftextid)
  ENDFOR
 ENDIF
 IF (reftextcontentcnt > 0)
  IF (reftextexistingcnt=0)
   FOR (k = 1 TO reftextcontentcnt)
     CALL inserttext(k,reftextcontent->list[k].typecd)
   ENDFOR
  ELSE
   FOR (i = 1 TO reftextcontentcnt)
     SET num = 1
     SET efound = locateval(num,1,reftextexistingcnt,reftextcontent->list[i].typecd,reftextexisting->
      list[num].typecd)
     IF (efound > 0)
      IF ((reftextcontent->list[i].text != reftextexisting->list[efound].text))
       CALL removetext(reftextexisting->list[efound].reftextid)
       CALL inserttext(i,reftextcontent->list[i].typecd)
      ENDIF
      SET reftextexisting->list[efound].processedind = true
     ELSE
      CALL inserttext(i,reftextcontent->list[i].typecd)
     ENDIF
   ENDFOR
   FOR (k = 1 TO reftextexistingcnt)
     IF ((reftextexisting->list[k].processedind=false))
      CALL removetext(reftextexisting->list[k].reftextid)
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getreftextfromcontent(taskassayuid)
   CALL bedlogmessage("getRefTextFromContent","Entering ...")
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE offset = i4
   DECLARE retlen = i4
   SELECT INTO "nl:"
    FROM cnt_ref_text t,
     cnt_code_value_key c
    PLAN (t
     WHERE t.task_assay_uid=taskassayuid
      AND t.text_type_cduid > " ")
     JOIN (c
     WHERE c.code_value_uid=t.text_type_cduid
      AND c.code_value > 0)
    HEAD REPORT
     msg_buf = fillstring(32000," ")
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reftextcontent->list,rcnt), reftextcontent->list[rcnt].
     textrefuid = t.cnt_ref_text_uid,
     reftextcontent->list[rcnt].typecd = c.code_value, offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(msg_buf,offset,t.cnt_ref_blob)
       IF (retlen > 0)
        IF (retlen=size(msg_buf))
         reftextcontent->list[rcnt].text = concat(reftextcontent->list[rcnt].text,msg_buf)
        ELSE
         reftextcontent->list[rcnt].text = concat(reftextcontent->list[rcnt].text,substring(1,retlen,
           msg_buf))
        ENDIF
       ENDIF
       offset = (offset+ retlen)
     ENDWHILE
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   CALL bedlogmessage("getRefTextFromContent","Exiting ...")
 END ;Subroutine
 SUBROUTINE getexistingreftext(taskassaycd)
   CALL bedlogmessage("getExistingRefText","Entering ...")
   DECLARE reftextcnt = i4 WITH noconstant(0), protect
   DECLARE offset = i4
   DECLARE retlen = i4
   SELECT INTO "nl;"
    FROM ref_text_reltn rtr,
     ref_text rt,
     long_blob lb
    PLAN (rtr
     WHERE rtr.parent_entity_name="DISCRETE_TASK_ASSAY"
      AND rtr.parent_entity_id=taskassaycd
      AND rtr.active_ind=true)
     JOIN (rt
     WHERE rt.refr_text_id=rtr.refr_text_id
      AND rt.text_entity_name="LONG_BLOB"
      AND rt.active_ind=true)
     JOIN (lb
     WHERE lb.long_blob_id=rt.text_entity_id
      AND lb.active_ind=true)
    ORDER BY rtr.ref_text_reltn_id, rt.refr_text_id, lb.long_blob_id
    HEAD REPORT
     msg_buf2 = fillstring(32000," ")
    HEAD lb.long_blob_id
     reftextcnt = (reftextcnt+ 1), stat = alterlist(reftextexisting->list,reftextcnt),
     reftextexisting->list[reftextcnt].reftextid = rt.refr_text_id,
     reftextexisting->list[reftextcnt].typecd = rt.text_type_cd, offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(msg_buf2,offset,lb.long_blob)
       IF (retlen > 0)
        IF (retlen=size(msg_buf2))
         reftextexisting->list[reftextcnt].text = concat(reftextexisting->list[reftextcnt].text,
          msg_buf2)
        ELSE
         reftextexisting->list[reftextcnt].text = concat(reftextexisting->list[reftextcnt].text,
          substring(1,retlen,msg_buf2))
        ENDIF
       ENDIF
       offset = (offset+ retlen)
     ENDWHILE
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   CALL bedlogmessage("getExistingRefText","Exiting ...")
 END ;Subroutine
 SUBROUTINE removetext(reftextid)
   CALL bedlogmessage("removeText","Entering ...")
   DELETE  FROM ref_text_reltn rtr
    WHERE rtr.refr_text_id=reftextid
    WITH nocounter
   ;end delete
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_id=reftextid
    WITH nocounter
   ;end delete
   DELETE  FROM ref_text rt
    WHERE rt.refr_text_id=reftextid
    WITH nocounter
   ;end delete
   CALL bedlogmessage("removeText","Exiting ...")
 END ;Subroutine
 SUBROUTINE inserttext(index,typecd)
   CALL bedlogmessage("insertText","Entering ...")
   DECLARE reftextid = f8 WITH protect, noconstant(0)
   DECLARE reftextreltnid = f8 WITH protect, noconstant(0)
   DECLARE longblobid = f8 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE foundind = i4 WITH protect, noconstant(0)
   SET reftextid = generatereferencepk(0)
   SET reftextreltnid = generatereferencepk(0)
   SELECT INTO "nl:"
    j = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     longblobid = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM ref_text r
    SET r.refr_text_id = reftextid, r.text_type_cd = typecd, r.text_entity_name = "LONG_BLOB",
     r.text_entity_id = longblobid, r.text_type_flag = 0, r.active_ind = 1,
     r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
    WITH nocounter
   ;end insert
   INSERT  FROM long_blob l
    SET l.long_blob_id = longblobid, l.parent_entity_name = "REF_TEXT", l.parent_entity_id =
     reftextid,
     l.long_blob = reftextcontent->list[index].text, l.blob_length = 0, l.compression_cd = 0,
     l.active_ind = 1, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_cd =
     reqdata->active_status_cd,
     l.active_status_prsnl_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l
     .updt_id = reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
    WITH nocounter
   ;end insert
   INSERT  FROM ref_text_reltn r
    SET r.ref_text_reltn_id = reftextreltnid, r.parent_entity_name = "DISCRETE_TASK_ASSAY", r
     .parent_entity_id = request->taskassaycd,
     r.refr_text_id = reftextid, r.text_type_cd = typecd, r.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
     updt_applctx,
     r.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bedlogmessage("insertText","Exiting ...")
 END ;Subroutine
 SUBROUTINE generatereferencepk(dummyvar)
   DECLARE pkid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     pkid = cnvtreal(nextseqnum)
    WITH format, counter
   ;end select
   RETURN(pkid)
 END ;Subroutine
END GO
