CREATE PROGRAM bed_ens_pm_dist:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 distribution_id = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE logicaldomainid = f8 WITH protect, noconstant(bedgetlogicaldomain(0))
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET active_code = 0.0
 SET inactive_code = 0.0
 SET printer_count = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning IN ("ACTIVE", "INACTIVE")
  DETAIL
   IF (c.cdf_meaning="ACTIVE")
    active_code = c.code_value
   ELSE
    inactive_code = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error[1]: Failure in getting active code value")
 IF ((request->action_flag=1))
  GO TO add_new
 ELSEIF ((request->action_flag=2))
  IF ((request->distribution_id > 0))
   UPDATE  FROM pm_doc_distribution pdd
    SET pdd.distribution_name = request->distribution_name, pdd.distribution_desc = request->
     distribution_name, pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
     pdd.updt_task = reqinfo->updt_task, pdd.updt_id = reqinfo->updt_id, pdd.updt_applctx = reqinfo->
     updt_applctx,
     pdd.updt_cnt = (pdd.updt_cnt+ 1)
    WHERE (pdd.distribution_id=request->distribution_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error[2]: Failure in distribution update query")
   UPDATE  FROM pm_doc_dist_filter pddf
    SET pddf.value = request->transaction_type_mean, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime),
     pddf.updt_task = reqinfo->updt_task,
     pddf.updt_id = reqinfo->updt_id, pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_cnt = (
     pddf.updt_cnt+ 1)
    WHERE (pddf.distribution_id=request->distribution_id)
     AND pddf.filter_type="TRN"
     AND pddf.active_ind=1
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error[19]: Failure in distribution transaction update query")
  ELSE
   SET error_flag = "Y"
   SET error_msg = "Distribution ID must be filled out on update."
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  IF ((request->distribution_id > 0))
   UPDATE  FROM pm_doc_distribution pdd
    SET pdd.active_ind = 0, pdd.active_status_dt_tm = cnvtdatetime(curdate,curtime), pdd
     .active_status_cd = inactive_code,
     pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo->
     updt_applctx,
     pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd.updt_cnt = (pdd.updt_cnt+ 1)
    WHERE (pdd.distribution_id=request->distribution_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error[3]: Failure in delete query")
  ELSE
   SET error_flag = "Y"
   SET error_msg = "Distribution ID must be filled out on delete."
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 IF ((request->distribution_id=0))
  GO TO exit_script
 ENDIF
 SET fcnt = size(request->flist,5)
 FOR (x = 1 TO fcnt)
  SET vcnt = size(request->flist[x].vlist,5)
  FOR (y = 1 TO vcnt)
    IF ((request->flist[x].vlist[y].action_flag=1))
     INSERT  FROM pm_doc_dist_filter pddf
      SET pddf.dist_filter_id = seq(pm_document_seq,nextval), pddf.distribution_id = request->
       distribution_id, pddf.filter_type = request->flist[x].filter_type,
       pddf.value = request->flist[x].vlist[y].value, pddf.value_cd = request->flist[x].vlist[y].
       value_cd, pddf.value_ind = request->flist[x].vlist[y].value_ind,
       pddf.exclude_ind = request->flist[x].vlist[y].exclude_ind, pddf.active_ind = 1, pddf
       .active_status_cd = active_code,
       pddf.active_status_prsnl_id = reqinfo->updt_id, pddf.active_status_dt_tm = cnvtdatetime(
        curdate,curtime), pddf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
       pddf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pddf.updt_id = reqinfo->
       updt_id, pddf.updt_task = reqinfo->updt_task,
       pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime),
       pddf.updt_cnt = 0
     ;end insert
    ELSEIF ((request->flist[x].vlist[y].action_flag=2))
     UPDATE  FROM pm_doc_dist_filter pddf
      SET pddf.exclude_ind = request->flist[x].vlist[y].exclude_ind, pddf.updt_id = reqinfo->updt_id,
       pddf.updt_task = reqinfo->updt_task,
       pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime),
       pddf.updt_cnt = (pddf.updt_cnt+ 1)
      WHERE (pddf.distribution_id=request->distribution_id)
       AND (pddf.filter_type=request->flist[x].filter_type)
       AND (((pddf.value_cd=request->flist[x].vlist[y].value_cd)
       AND (request->flist[x].filter_type != "CET")) OR ((pddf.value_ind=request->flist[x].vlist[y].
      value_ind)
       AND (request->flist[x].filter_type="CET")))
      WITH nocounter
     ;end update
     CALL bederrorcheck("Error[4]: Failure in filter and transaction update query")
    ELSEIF ((request->flist[x].vlist[y].action_flag=3))
     DELETE  FROM pm_doc_dist_filter pddf
      WHERE (pddf.distribution_id=request->distribution_id)
       AND (pddf.filter_type=request->flist[x].filter_type)
       AND (((pddf.value_cd=request->flist[x].vlist[y].value_cd)
       AND (request->flist[x].filter_type != "CET")
       AND (request->flist[x].filter_type != "PCI")) OR ((((pddf.value_ind=request->flist[x].vlist[y]
      .value_ind)
       AND (request->flist[x].filter_type="CET")) OR ((pddf.value=request->flist[x].vlist[y].value)
       AND (request->flist[x].filter_type="PCI"))) ))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("Error[5]: Failure in filter and transaction delete query")
    ENDIF
  ENDFOR
 ENDFOR
 SET dcnt = size(request->doclist,5)
 FOR (x = 1 TO dcnt)
   IF ((request->doclist[x].action_flag=3))
    DELETE  FROM pm_doc_destination pdd
     WHERE (pdd.distribution_id=request->distribution_id)
      AND (pdd.document_id=request->doclist[x].document_id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error[6]: Failure in documents delete query")
   ELSE
    SET pcnt = size(request->doclist[x].plist,5)
    IF (pcnt=0)
     IF ((request->doclist[x].action_flag=1))
      INSERT  FROM pm_doc_destination pdd
       SET pdd.destination_id = seq(pm_document_seq,nextval), pdd.document_id = request->doclist[x].
        document_id, pdd.distribution_id = request->distribution_id,
        pdd.output_dest_cd = 0, pdd.copies = 0, pdd.active_ind = 1,
        pdd.active_status_cd = active_code, pdd.active_status_prsnl_id = reqinfo->updt_id, pdd
        .active_status_dt_tm = cnvtdatetime(curdate,curtime),
        pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00"), pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
        pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx =
        reqinfo->updt_applctx,
        pdd.updt_cnt = 0
       WITH nocounter
      ;end insert
      CALL bederrorcheck("Error[7]: Failure in documents insert query")
     ENDIF
    ELSE
     FOR (y = 1 TO pcnt)
       IF ((request->doclist[x].plist[y].action_flag=1))
        DELETE  FROM pm_doc_destination pdd
         WHERE (pdd.distribution_id=request->distribution_id)
          AND (pdd.document_id=request->doclist[x].document_id)
          AND pdd.output_dest_cd=0
         WITH nocounter
        ;end delete
        CALL bederrorcheck("Error[8]: Failure in document printers delete query")
        INSERT  FROM pm_doc_destination pdd
         SET pdd.destination_id = seq(pm_document_seq,nextval), pdd.document_id = request->doclist[x]
          .document_id, pdd.distribution_id = request->distribution_id,
          pdd.output_dest_cd = request->doclist[x].plist[y].output_dest_cd, pdd.copies = request->
          doclist[x].plist[y].copies, pdd.active_ind = 1,
          pdd.active_status_cd = active_code, pdd.active_status_prsnl_id = reqinfo->updt_id, pdd
          .active_status_dt_tm = cnvtdatetime(curdate,curtime),
          pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm =
          cnvtdatetime("31-DEC-2100 00:00:00.00"), pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
          pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx =
          reqinfo->updt_applctx,
          pdd.updt_cnt = 0
         WITH nocounter
        ;end insert
        CALL bederrorcheck("Error[9]: Failure in document printers insert query")
       ELSEIF ((request->doclist[x].plist[y].action_flag=2))
        UPDATE  FROM pm_doc_destination pdd
         SET pdd.copies = request->doclist[x].plist[y].copies, pdd.updt_dt_tm = cnvtdatetime(curdate,
           curtime), pdd.updt_id = reqinfo->updt_id,
          pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo->updt_applctx, pdd.updt_cnt
           = (pdd.updt_cnt+ 1)
         WHERE (pdd.distribution_id=request->distribution_id)
          AND (pdd.document_id=request->doclist[x].document_id)
          AND (pdd.output_dest_cd=request->doclist[x].plist[y].output_dest_cd)
         WITH nocounter
        ;end update
        CALL bederrorcheck("Error[10]: Failure in document printers update query")
       ELSEIF ((request->doclist[x].plist[y].action_flag=3))
        SET printer_count = 0
        SELECT INTO "nl:"
         FROM pm_doc_destination pdd
         PLAN (pdd
          WHERE (pdd.distribution_id=request->distribution_id)
           AND (pdd.document_id=request->doclist[x].document_id))
         DETAIL
          printer_count = (printer_count+ 1)
         WITH nocounter
        ;end select
        CALL bederrorcheck("Error[11]: Failure in getting document printers count")
        IF (printer_count > 1)
         DELETE  FROM pm_doc_destination pdd
          WHERE (pdd.distribution_id=request->distribution_id)
           AND (pdd.document_id=request->doclist[x].document_id)
           AND (pdd.output_dest_cd=request->doclist[x].plist[y].output_dest_cd)
          WITH nocounter
         ;end delete
         CALL bederrorcheck("Error[12]: Failure in deleting printer for specific document")
        ELSE
         UPDATE  FROM pm_doc_destination pdd
          SET pdd.copies = 0, pdd.output_dest_cd = 0, pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
           pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx =
           reqinfo->updt_applctx,
           pdd.updt_cnt = (pdd.updt_cnt+ 1)
          WHERE (pdd.distribution_id=request->distribution_id)
           AND (pdd.document_id=request->doclist[x].document_id)
           AND (pdd.output_dest_cd=request->doclist[x].plist[y].output_dest_cd)
          WITH nocounter
         ;end update
         CALL bederrorcheck("Error[13]: Failure in document update for distribution")
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#add_new
 SET distribution_id = 0.0
 SELECT INTO "nl:"
  y = seq(pm_document_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   distribution_id = cnvtreal(y)
  WITH format, counter
 ;end select
 SET reply->distribution_id = distribution_id
 INSERT  FROM pm_doc_distribution pdd
  SET pdd.distribution_id = distribution_id, pdd.distribution_name = request->distribution_name, pdd
   .distribution_desc = request->distribution_name,
   pdd.active_ind = 1, pdd.logical_domain_id = logicaldomainid, pdd.active_status_cd = active_code,
   pdd.active_status_prsnl_id = reqinfo->updt_id, pdd.active_status_dt_tm = cnvtdatetime(curdate,
    curtime), pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
   pdd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pdd.updt_id = reqinfo->updt_id,
   pdd.updt_task = reqinfo->updt_task,
   pdd.updt_applctx = reqinfo->updt_applctx, pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd
   .updt_cnt = 0
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Error[14]: Failure in distribution insert query")
 INSERT  FROM pm_doc_dist_filter pddf
  SET pddf.dist_filter_id = seq(pm_document_seq,nextval), pddf.distribution_id = distribution_id,
   pddf.filter_type = "TRN",
   pddf.value = request->transaction_type_mean, pddf.value_cd = 0, pddf.value_ind = 0,
   pddf.exclude_ind = 0, pddf.active_ind = 1, pddf.active_status_cd = active_code,
   pddf.active_status_prsnl_id = reqinfo->updt_id, pddf.active_status_dt_tm = cnvtdatetime(curdate,
    curtime), pddf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
   pddf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pddf.updt_id = reqinfo->
   updt_id, pddf.updt_task = reqinfo->updt_task,
   pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime), pddf
   .updt_cnt = 0
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Error[15]: Failure in transaction type insert query")
 SET fcnt = size(request->flist,5)
 FOR (x = 1 TO fcnt)
  SET vcnt = size(request->flist[x].vlist,5)
  FOR (y = 1 TO vcnt)
   INSERT  FROM pm_doc_dist_filter pddf
    SET pddf.dist_filter_id = seq(pm_document_seq,nextval), pddf.distribution_id = distribution_id,
     pddf.filter_type = request->flist[x].filter_type,
     pddf.value = request->flist[x].vlist[y].value, pddf.value_cd = request->flist[x].vlist[y].
     value_cd, pddf.value_ind = request->flist[x].vlist[y].value_ind,
     pddf.exclude_ind = request->flist[x].vlist[y].exclude_ind, pddf.active_ind = 1, pddf
     .active_status_cd = active_code,
     pddf.active_status_prsnl_id = reqinfo->updt_id, pddf.active_status_dt_tm = cnvtdatetime(curdate,
      curtime), pddf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
     pddf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pddf.updt_id = reqinfo->
     updt_id, pddf.updt_task = reqinfo->updt_task,
     pddf.updt_applctx = reqinfo->updt_applctx, pddf.updt_dt_tm = cnvtdatetime(curdate,curtime), pddf
     .updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error[16]: Failure in distribution insert query")
  ENDFOR
 ENDFOR
 SET dcnt = size(request->doclist,5)
 FOR (x = 1 TO dcnt)
  SET pcnt = size(request->doclist[x].plist,5)
  IF (pcnt=0)
   IF ((request->doclist[x].action_flag=1))
    INSERT  FROM pm_doc_destination pdd
     SET pdd.destination_id = seq(pm_document_seq,nextval), pdd.document_id = request->doclist[x].
      document_id, pdd.distribution_id = distribution_id,
      pdd.output_dest_cd = 0, pdd.copies = 0, pdd.active_ind = 1,
      pdd.active_status_cd = active_code, pdd.active_status_prsnl_id = reqinfo->updt_id, pdd
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm = cnvtdatetime
      ("31-DEC-2100 00:00:00.00"), pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
      pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo
      ->updt_applctx,
      pdd.updt_cnt = 0
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error[17]: Failure in documents insert query")
   ENDIF
  ELSE
   FOR (y = 1 TO pcnt)
    INSERT  FROM pm_doc_destination pdd
     SET pdd.destination_id = seq(pm_document_seq,nextval), pdd.document_id = request->doclist[x].
      document_id, pdd.distribution_id = distribution_id,
      pdd.output_dest_cd = request->doclist[x].plist[y].output_dest_cd, pdd.copies = request->
      doclist[x].plist[y].copies, pdd.active_ind = 1,
      pdd.active_status_cd = active_code, pdd.active_status_prsnl_id = reqinfo->updt_id, pdd
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm = cnvtdatetime
      ("31-DEC-2100 00:00:00.00"), pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
      pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo
      ->updt_applctx,
      pdd.updt_cnt = 0
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error[18]: Failure in printers insert query")
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
