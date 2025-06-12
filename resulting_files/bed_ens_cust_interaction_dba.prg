CREATE PROGRAM bed_ens_cust_interaction:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dcp_entity_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET dcp_entity_rec
 RECORD dcp_entity_rec(
   1 dcp_list[*]
     2 dcp_entity_reltn_id = f8
 )
 FREE SET long_text_rec
 RECORD long_text_rec(
   1 text_list[*]
     2 long_text_id = f8
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
 DECLARE reqcounter = i4 WITH noconstant(0)
 DECLARE batchcnt = i4 WITH noconstant(0)
 DECLARE dcpcnt = i4 WITH noconstant(0)
 DECLARE textcnt = i4 WITH noconstant(0)
 DECLARE txtloopcnt = i4 WITH noconstant(0)
 DECLARE dcploopcnt = i4 WITH noconstant(0)
 DECLARE drug_class_int_custom_id = f8 WITH noconstant(0.0)
 DECLARE batch_long_text_id = f8 WITH noconstant(0.0)
 DECLARE drug_class_int_cstm_entity_r_id = f8 WITH noconstant(0.0)
 DECLARE dcp_entity_reltn_id = f8 WITH public, noconstant(0.0)
 DECLARE old_dcp_entity_reltn_id = f8 WITH public, noconstant(0.0)
 DECLARE class1_ident = vc WITH public, noconstant("")
 DECLARE class2_ident = vc WITH public, noconstant("")
 DECLARE entity1_ident_disp = vc WITH public, noconstant("")
 DECLARE entity2_ident_disp = vc WITH public, noconstant("")
 DECLARE temp_long_text = vc WITH noconstant("")
 DECLARE temp_long_text_id = f8 WITH noconstant(0.0)
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE long_text_id = f8 WITH public, noconstant(0.0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 DECLARE entity1_name = c32 WITH public, noconstant("")
 DECLARE entity2_name = c32 WITH public, noconstant("")
 DECLARE entity1_display = vc WITH public, noconstant("")
 DECLARE entity2_display = vc WITH public, noconstant("")
 DECLARE createbatchcustom(null) = null
 DECLARE createdcpbatchreltn(dcp_id=f8) = null
 DECLARE createbatchlongtext(null) = null
 DECLARE processdcpentityreltn(null) = null
 DECLARE deletebatchcustominteractions(null) = null
 CASE (request->custom_type_flag)
  OF 0:
   IF ((request->combo_ind=0)
    AND (request->interaction_type_flag != 7))
    CALL processdcpentityreltn(null)
    GO TO exit_script
   ELSE
    IF (cnvtreal(request->class1_ident) < cnvtreal(request->class2_ident))
     SET class1_ident = request->class1_ident
     SET entity1_ident_disp = trim(request->entity1_display)
     SET class2_ident = request->class2_ident
     SET entity2_ident_disp = trim(request->entity2_display)
    ELSE
     IF ((request->interaction_type_flag=7))
      SET class1_ident = request->class1_ident
      SET entity1_ident_disp = trim(request->entity1_display)
     ELSE
      SET class1_ident = request->class2_ident
      SET entity1_ident_disp = trim(request->entity2_display)
      SET class2_ident = request->class1_ident
      SET entity2_ident_disp = trim(request->entity1_display)
     ENDIF
    ENDIF
   ENDIF
  OF 1:
   SET class1_ident = request->class1_ident
   SET entity1_ident_disp = trim(request->entity1_display)
   SET class2_ident = request->class2_ident
   SET entity2_ident_disp = trim(request->entity2_display)
  OF 2:
   IF (cnvtreal(request->class1_ident) < cnvtreal(request->class2_ident))
    SET class1_ident = request->class1_ident
    SET entity1_ident_disp = trim(request->entity1_display)
    SET class2_ident = request->class2_ident
    SET entity2_ident_disp = trim(request->entity2_display)
   ELSE
    SET class1_ident = request->class2_ident
    SET entity1_ident_disp = trim(request->entity2_display)
    SET class2_ident = request->class1_ident
    SET entity2_ident_disp = trim(request->entity1_display)
   ENDIF
  OF 3:
   IF ((request->combo_ind=0))
    CALL processdcpentityreltn(null)
    GO TO exit_script
   ELSE
    SET class1_ident = request->class1_ident
    SET entity1_ident_disp = trim(request->entity1_display)
    SET class2_ident = request->class2_ident
    SET entity2_ident_disp = trim(request->entity2_display)
   ENDIF
  OF 4:
   SET class1_ident = request->class1_ident
   SET entity1_ident_disp = trim(request->entity1_display)
   SET class2_ident = request->class2_ident
   SET entity2_ident_disp = trim(request->entity2_display)
 ENDCASE
 IF ((request->del_batch_cust_int_ind=1))
  CALL deletebatchcustominteractions(null)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.drug_class_int_custom_id
  FROM drug_class_int_custom d
  WHERE (d.custom_type_flag=request->custom_type_flag)
   AND (d.custom_interaction_flag=request->interaction_type_flag)
   AND d.entity1_ident=class1_ident
   AND d.entity2_ident=class2_ident
  HEAD REPORT
   batchcnt = 0
  DETAIL
   batchcnt = (batchcnt+ 1), drug_class_int_custom_id = d.drug_class_int_custom_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("ERROR 001: select from drug_class_int_custom table failed")
 IF (batchcnt=0)
  CALL createbatchcustom(null)
  IF ((request->custom_alert_text > " "))
   CALL createbatchlongtext(null)
   UPDATE  FROM drug_class_int_custom d
    SET d.long_text_id = temp_long_text_id, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
     updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
    WHERE d.drug_class_int_custom_id=drug_class_int_custom_id
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 002: update into drug_class_int_custom table failed")
  ENDIF
  CALL processdcpentityreltn(null)
 ELSEIF (batchcnt=1)
  DELETE  FROM drug_class_int_cstm_entity_r d
   WHERE d.drug_class_int_custom_id=drug_class_int_custom_id
   WITH nocounter
  ;end delete
  CALL bederrorcheck("ERROR 003: delete from drug_class_int_custom table failed")
  UPDATE  FROM long_text l
   SET l.active_ind = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = (l.updt_cnt+ 1),
    l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
    updt_applctx
   WHERE l.parent_entity_id=drug_class_int_custom_id
    AND l.parent_entity_name="DRUG_CLASS_INT_CUSTOM"
   WITH nocounter
  ;end update
  CALL bederrorcheck("ERROR 004: update into long_text table failed")
  IF ((request->custom_alert_text > " "))
   CALL createbatchlongtext(null)
   UPDATE  FROM drug_class_int_custom d
    SET d.long_text_id = temp_long_text_id, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id
      = reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
     .updt_cnt+ 1)
    WHERE d.drug_class_int_custom_id=drug_class_int_custom_id
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 005: update into drug_class_int_custom table failed")
  ENDIF
  CALL processdcpentityreltn(null)
 ENDIF
 SUBROUTINE createbatchcustom(null)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     drug_class_int_custom_id = cnvtreal(nextseqnum)
    WITH format, nocounter
   ;end select
   CALL bederrorcheck("ERROR 006: select from dual table failed")
   INSERT  FROM drug_class_int_custom d
    SET d.drug_class_int_custom_id = drug_class_int_custom_id, d.entity1_ident = class1_ident, d
     .entity1_display = entity1_ident_disp,
     d.entity2_ident = class2_ident, d.entity2_display = entity2_ident_disp, d.custom_type_flag =
     request->custom_type_flag,
     d.custom_interaction_flag = request->interaction_type_flag, d.combo_ind = request->combo_ind, d
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx,
     d.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 007: insert into drug_class_int_custom table failed")
 END ;Subroutine
 SUBROUTINE createdcpbatchreltn(dcp_id)
   SET drug_class_int_cstm_entity_r_id = 0
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     drug_class_int_cstm_entity_r_id = cnvtreal(nextseqnum)
    WITH format, nocounter
   ;end select
   CALL bederrorcheck("ERROR 008: select from dual table failed")
   INSERT  FROM drug_class_int_cstm_entity_r d
    SET d.drug_class_int_cstm_ent_r_id = drug_class_int_cstm_entity_r_id, d.dcp_entity_reltn_id =
     dcp_id, d.drug_class_int_custom_id = drug_class_int_custom_id,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
     reqinfo->updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 009: insert into drug_class_int_cstm_entity_r table failed")
 END ;Subroutine
 SUBROUTINE processdcpentityreltn(null)
   FOR (reqcounter = 1 TO value(size(request->custom_list,5)))
     IF ((request->custom_list[reqcounter].entity_reltn_mean != "ALGCAT/DRUG"))
      IF ((request->custom_list[reqcounter].entity1_id < request->custom_list[reqcounter].entity2_id)
      )
       SET entity1_id = request->custom_list[reqcounter].entity1_id
       SET entity1_display = trim(request->custom_list[reqcounter].entity1_display)
       SET entity2_id = request->custom_list[reqcounter].entity2_id
       SET entity2_display = trim(request->custom_list[reqcounter].entity2_display)
      ELSE
       SET entity1_id = request->custom_list[reqcounter].entity2_id
       SET entity1_display = trim(request->custom_list[reqcounter].entity2_display)
       SET entity2_id = request->custom_list[reqcounter].entity1_id
       SET entity2_display = trim(request->custom_list[reqcounter].entity1_display)
      ENDIF
     ELSE
      SET entity1_id = request->custom_list[reqcounter].entity1_id
      SET entity1_display = trim(request->custom_list[reqcounter].entity1_display)
      SET entity2_id = request->custom_list[reqcounter].entity2_id
      SET entity2_display = trim(request->custom_list[reqcounter].entity2_display)
     ENDIF
     IF ((((request->custom_list[reqcounter].entity_reltn_mean="DRUG/DRUG")) OR ((request->
     custom_list[reqcounter].entity_reltn_mean="DRUG/ALLERGY"))) )
      SET entity1_name = request->custom_list[reqcounter].entity1_name
      SET entity2_name = "DRUG"
     ELSEIF ((request->custom_list[reqcounter].entity_reltn_mean="DRUG/FOOD"))
      SET entity1_name = "FOOD"
      SET entity2_name = "DRUG"
     ELSEIF ((request->custom_list[reqcounter].entity_reltn_mean="TDC/SUPP"))
      SET entity1_name = "SUPP"
      SET entity2_name = "DRUG"
     ELSEIF ((request->custom_list[reqcounter].entity_reltn_mean="DRUG/TEXT"))
      SET entity1_name = "TEXT"
      SET entity2_name = "DRUG"
     ELSEIF ((request->custom_list[reqcounter].entity_reltn_mean="ALGCAT/DRUG"))
      SET entity1_name = "ALGCAT"
      SET entity2_name = "DRUG"
     ELSEIF ((request->custom_list[reqcounter].entity_reltn_mean="DRUG/RULE"))
      SET entity1_name = "RULE"
      SET entity2_name = "DRUG"
     ELSE
      SET entity1_name = ""
      SET entity2_name = ""
     ENDIF
     SELECT INTO "nl:"
      d.dcp_entity_reltn_id, d.entity_reltn_mean, d.entity1_id,
      d.entity2_id, d.active_ind
      FROM dcp_entity_reltn d
      WHERE d.entity1_id=entity1_id
       AND d.entity2_id=entity2_id
       AND d.active_ind=1
       AND d.entity_reltn_mean=trim(request->custom_list[reqcounter].entity_reltn_mean)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 = (count1+ 1), old_dcp_entity_reltn_id = d.dcp_entity_reltn_id
      WITH nocounter
     ;end select
     IF (count1=1)
      SELECT INTO "nl:"
       dc.dcp_entity_reltn_id
       FROM drug_class_int_cstm_entity_r dc
       WHERE dc.dcp_entity_reltn_id=old_dcp_entity_reltn_id
       WITH nocounter
      ;end select
      CALL bederrorcheck("ERROR 001: select from drug_class_int_cstm_entity_r table failed")
      IF (curqual > 0)
       DELETE  FROM drug_class_int_cstm_entity_r dcer
        WHERE dcer.dcp_entity_reltn_id=old_dcp_entity_reltn_id
        WITH nocounter
       ;end delete
       CALL bederrorcheck("ERROR 002: delete from drug_class_int_cstm_entity_r table failed")
      ENDIF
      UPDATE  FROM dcp_entity_reltn d
       SET d.active_ind = 0, d.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
        d.updt_applctx = reqinfo->updt_applctx
       WHERE d.dcp_entity_reltn_id=old_dcp_entity_reltn_id
      ;end update
      CALL bederrorcheck("ERROR 003: update into dcp_entity_reltn table failed")
      UPDATE  FROM long_text b
       SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt = (b.updt_cnt
        + 1),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx
       WHERE b.parent_entity_id=old_dcp_entity_reltn_id
        AND b.parent_entity_name="DCP_ENTITY_RELTN"
      ;end update
      CALL bederrorcheck("ERROR 004: update into long_text table failed")
     ENDIF
     IF ((request->custom_list[reqcounter].activate=0))
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)"######################;rp0"
      FROM dual
      DETAIL
       dcp_entity_reltn_id = cnvtreal(nextseqnum)
      WITH format, nocounter
     ;end select
     CALL bederrorcheck("ERROR 005: select from dual table failed")
     INSERT  FROM dcp_entity_reltn d
      SET d.dcp_entity_reltn_id = dcp_entity_reltn_id, d.entity_reltn_mean = trim(request->
        custom_list[reqcounter].entity_reltn_mean), d.entity1_id = entity1_id,
       d.entity1_display = entity1_display, d.entity2_id = entity2_id, d.entity2_display =
       entity2_display,
       d.rank_sequence = request->custom_list[reqcounter].custom_severity_level, d.active_ind = 1, d
       .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       d.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), d.updt_id = reqinfo->updt_id,
       d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0,
       d.entity1_name = entity1_name, d.entity2_name = entity2_name
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ERROR 006: insert into dcp_entity_reltn table failed")
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
      FROM dual
      DETAIL
       long_text_id = cnvtreal(nextseqnum)
      WITH format, nocounter
     ;end select
     DECLARE tmp_long_text = vc WITH protect, noconstant("")
     IF ((request->custom_list[reqcounter].custom_alert_long_text > " "))
      SET tmp_long_text = trim(request->custom_list[reqcounter].custom_alert_long_text)
     ELSE
      SET tmp_long_text = " "
     ENDIF
     INSERT  FROM long_text l
      SET l.active_ind = 1, l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       l.active_status_prsnl_id = reqinfo->updt_id, l.long_text = tmp_long_text, l.long_text_id = seq
       (long_data_seq,nextval),
       l.parent_entity_name = "DCP_ENTITY_RELTN", l.parent_entity_id = dcp_entity_reltn_id, l
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
       updt_applctx,
       l.updt_cnt = 0
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ERROR 007: insert into long_text table failed")
     IF ((((request->combo_ind != 0)) OR ((((request->custom_type_flag != 0)
      AND (request->custom_type_flag != 3)) OR ((request->interaction_type_flag=7))) )) )
      CALL createdcpbatchreltn(dcp_entity_reltn_id)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE createbatchlongtext(null)
   IF ((request->custom_alert_text > " "))
    SET temp_long_text = trim(request->custom_alert_text)
   ELSE
    SET temp_long_text = " "
   ENDIF
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
    FROM dual
    DETAIL
     temp_long_text_id = cnvtreal(nextseqnum)
    WITH format, nocounter
   ;end select
   CALL bederrorcheck("ERROR 011: select from dual table failed")
   INSERT  FROM long_text l
    SET l.active_ind = 1, l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     l.active_status_prsnl_id = reqinfo->updt_id, l.long_text = temp_long_text, l.long_text_id =
     temp_long_text_id,
     l.parent_entity_name = "DRUG_CLASS_INT_CUSTOM", l.parent_entity_id = drug_class_int_custom_id, l
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx,
     l.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 012: insert into long_text table failed")
 END ;Subroutine
 SUBROUTINE deletebatchcustominteractions(null)
   SELECT INTO "nl:"
    FROM drug_class_int_custom dcc,
     drug_class_int_cstm_entity_r dcer,
     dcp_entity_reltn der,
     long_text lt
    PLAN (dcc
     WHERE dcc.entity1_ident=class1_ident
      AND dcc.entity2_ident=class2_ident
      AND (dcc.custom_type_flag=request->custom_type_flag)
      AND (dcc.custom_interaction_flag=request->interaction_type_flag))
     JOIN (dcer
     WHERE dcer.drug_class_int_custom_id=dcc.drug_class_int_custom_id)
     JOIN (der
     WHERE der.dcp_entity_reltn_id=dcer.dcp_entity_reltn_id)
     JOIN (lt
     WHERE lt.parent_entity_id=outerjoin(der.dcp_entity_reltn_id))
    HEAD REPORT
     batchcnt = 0
    HEAD dcc.drug_class_int_custom_id
     dcpcnt = 0, textcnt = 0, batchcnt = (batchcnt+ 1),
     drug_class_int_custom_id = dcc.drug_class_int_custom_id, batch_long_text_id = dcc.long_text_id
    HEAD dcer.drug_class_int_cstm_ent_r_id
     dcpcnt = (dcpcnt+ 1)
     IF (mod(dcpcnt,5)=1)
      stat = alterlist(dcp_entity_rec->dcp_list,(dcpcnt+ 4))
     ENDIF
     dcp_entity_rec->dcp_list[dcpcnt].dcp_entity_reltn_id = dcer.dcp_entity_reltn_id
    HEAD lt.long_text_id
     textcnt = (textcnt+ 1)
     IF (mod(textcnt,5)=1)
      stat = alterlist(long_text_rec->text_list,(textcnt+ 4))
     ENDIF
     long_text_rec->text_list[textcnt].long_text_id = lt.long_text_id
    FOOT REPORT
     stat = alterlist(dcp_entity_rec->dcp_list,dcpcnt), stat = alterlist(long_text_rec->text_list,
      textcnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 013: Retrieving batch customization row failed")
   IF (drug_class_int_custom_id > 0
    AND batchcnt=1)
    UPDATE  FROM long_text ltx
     SET ltx.active_ind = 0, ltx.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltx.updt_cnt = (ltx
      .updt_cnt+ 1),
      ltx.updt_id = reqinfo->updt_id, ltx.updt_task = reqinfo->updt_task, ltx.updt_applctx = reqinfo
      ->updt_applctx
     WHERE ltx.long_text_id=batch_long_text_id
     WITH nocounter
    ;end update
    CALL bederrorcheck("ERROR 014: updating into long_text table failed")
    FOR (txtloopcnt = 1 TO size(long_text_rec->text_list,5))
     UPDATE  FROM long_text ltt
      SET ltt.active_ind = 0, ltt.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltt.updt_cnt = (ltt
       .updt_cnt+ 1),
       ltt.updt_id = reqinfo->updt_id, ltt.updt_task = reqinfo->updt_task, ltt.updt_applctx = reqinfo
       ->updt_applctx
      WHERE (ltt.long_text_id=long_text_rec->text_list[txtloopcnt].long_text_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR 015: updating into long_text table failed")
    ENDFOR
    FOR (dcploopcnt = 1 TO size(dcp_entity_rec->dcp_list,5))
     UPDATE  FROM dcp_entity_reltn der
      SET der.active_ind = 0, der.updt_dt_tm = cnvtdatetime(curdate,curtime3), der.updt_cnt = (der
       .updt_cnt+ 1),
       der.updt_id = reqinfo->updt_id, der.updt_task = reqinfo->updt_task, der.updt_applctx = reqinfo
       ->updt_applctx
      WHERE (der.dcp_entity_reltn_id=dcp_entity_rec->dcp_list[dcploopcnt].dcp_entity_reltn_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR 016: updating into dcp_entity_reltn table failed")
    ENDFOR
    DELETE  FROM drug_class_int_cstm_entity_r dr
     WHERE dr.drug_class_int_custom_id=drug_class_int_custom_id
     WITH nocounter
    ;end delete
    CALL bederrorcheck("ERROR 017: deleting from drug_class_int_cstm_entity_r table failed")
    DELETE  FROM drug_class_int_custom dci
     WHERE dci.drug_class_int_custom_id=drug_class_int_custom_id
     WITH nocounter
    ;end delete
    CALL bederrorcheck("ERROR 018: deleting from drug_class_int_custom table failed")
   ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
