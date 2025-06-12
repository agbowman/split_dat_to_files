CREATE PROGRAM bed_ens_interp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 reference_ranges[*]
     2 dcp_interp_id = f8
     2 update_cnt = i4
 )
 RECORD tempinterpretations(
   1 interpretations[*]
     2 dcp_interp_id = f8
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
 DECLARE dummy = f8
 SET rcnt = size(request->reference_ranges,5)
 IF ((request->action_flag=1))
  IF (rcnt=0)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(temp->reference_ranges,rcnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    dcp_interp i
   PLAN (d
    WHERE (request->reference_ranges[d.seq].dcp_interp_id > 0))
    JOIN (i
    WHERE (i.dcp_interp_id=request->reference_ranges[d.seq].dcp_interp_id))
   DETAIL
    temp->reference_ranges[d.seq].dcp_interp_id = request->reference_ranges[d.seq].dcp_interp_id,
    temp->reference_ranges[d.seq].update_cnt = (i.updt_cnt+ 1)
   WITH nocounter
  ;end select
  SET stat = deleteinterpretationsfromreferenceranges(dummy)
  SELECT INTO "nl:"
   j = seq(dcp_interp_seq,nextval)
   FROM (dummyt d  WITH seq = rcnt),
    dual dd
   PLAN (d
    WHERE (request->reference_ranges[d.seq].dcp_interp_id=0))
    JOIN (dd)
   DETAIL
    temp->reference_ranges[d.seq].dcp_interp_id = cnvtreal(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM dcp_interp i,
    (dummyt d  WITH seq = rcnt)
   SET i.dcp_interp_id = temp->reference_ranges[d.seq].dcp_interp_id, i.task_assay_cd = request->
    assay_code_value, i.sex_cd = request->reference_ranges[d.seq].sex_code_value,
    i.age_from_minutes = request->reference_ranges[d.seq].age_from_minutes, i.age_to_minutes =
    request->reference_ranges[d.seq].age_to_minutes, i.updt_cnt = temp->reference_ranges[d.seq].
    update_cnt,
    i.updt_applctx = reqinfo->updt_applctx, i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_id
     = reqinfo->updt_id,
    i.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (i)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into dcp_interp table")
  INSERT  FROM dcp_interp_component c,
    (dummyt d  WITH seq = rcnt),
    (dummyt d2  WITH seq = 1)
   SET c.dcp_interp_component_id = seq(dcp_interp_seq,nextval), c.dcp_interp_id = temp->
    reference_ranges[d.seq].dcp_interp_id, c.component_assay_cd = request->reference_ranges[d.seq].
    components[d2.seq].code_value,
    c.component_sequence = request->reference_ranges[d.seq].components[d2.seq].sequence, c
    .description = request->reference_ranges[d.seq].components[d2.seq].description, c.flags = request
    ->reference_ranges[d.seq].components[d2.seq].numeric_or_calc_ind,
    c.look_back_minutes = request->reference_ranges[d.seq].components[d2.seq].look_back_minutes, c
    .look_ahead_minutes = request->reference_ranges[d.seq].components[d2.seq].look_ahead_minutes, c
    .look_time_direction_flag = request->reference_ranges[d.seq].components[d2.seq].
    look_direction_ind,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
    reqinfo->updt_task,
    c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE maxrec(d2,size(request->reference_ranges[d.seq].components,5)))
    JOIN (d2)
    JOIN (c)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into dcp_interp_component table")
  INSERT  FROM dcp_interp_state s,
    (dummyt d  WITH seq = rcnt),
    (dummyt d2  WITH seq = 1)
   SET s.dcp_interp_state_id = seq(dcp_interp_seq,nextval), s.dcp_interp_id = temp->reference_ranges[
    d.seq].dcp_interp_id, s.input_assay_cd = request->reference_ranges[d.seq].states[d2.seq].
    assay_code_value,
    s.state = request->reference_ranges[d.seq].states[d2.seq].state, s.flags =
    IF ((request->reference_ranges[d.seq].states[d2.seq].nomenclature_id > 0)) 0
    ELSE 1
    ENDIF
    , s.numeric_low = request->reference_ranges[d.seq].states[d2.seq].numeric_low_double,
    s.numeric_high = request->reference_ranges[d.seq].states[d2.seq].numeric_high_double, s
    .nomenclature_id = request->reference_ranges[d.seq].states[d2.seq].nomenclature_id, s
    .resulting_state = request->reference_ranges[d.seq].states[d2.seq].resulting_state,
    s.result_nomenclature_id = request->reference_ranges[d.seq].states[d2.seq].result_nomenclature_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id,
    s.updt_task = reqinfo->updt_task, s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE maxrec(d2,size(request->reference_ranges[d.seq].states,5)))
    JOIN (d2)
    JOIN (s)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into dcp_interp_state table")
 ELSEIF ((request->action_flag=3))
  IF ((request->assay_code_value=0))
   IF (rcnt=0)
    GO TO exit_script
   ENDIF
   SET stat = deleteinterpretationsfromreferenceranges(dummy)
  ELSE
   SET ccnt = 0
   SELECT INTO "nl:"
    FROM dcp_interp di
    WHERE (di.task_assay_cd=request->assay_code_value)
    DETAIL
     ccnt = (ccnt+ 1), stat = alterlist(tempinterpretations->interpretations,ccnt),
     tempinterpretations->interpretations[ccnt].dcp_interp_id = di.dcp_interp_id
    WITH nocounter
   ;end select
   IF (ccnt > 0)
    DELETE  FROM dcp_interp_component i,
      (dummyt d  WITH seq = ccnt)
     SET i.seq = 1
     PLAN (d)
      JOIN (i
      WHERE (i.dcp_interp_id=tempinterpretations->interpretations[d.seq].dcp_interp_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error deleting from dcp_interp_component table")
    DELETE  FROM dcp_interp_state i,
      (dummyt d  WITH seq = ccnt)
     SET i.seq = 1
     PLAN (d)
      JOIN (i
      WHERE (i.dcp_interp_id=tempinterpretations->interpretations[d.seq].dcp_interp_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error deleting from dcp_interp_state table")
    DELETE  FROM dcp_interp i,
      (dummyt d  WITH seq = ccnt)
     SET i.seq = 1
     PLAN (d)
      JOIN (i
      WHERE (i.dcp_interp_id=tempinterpretations->interpretations[d.seq].dcp_interp_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error deleting from dcp_interp table")
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE deleteinterpretationsfromreferenceranges(dummy)
   DELETE  FROM dcp_interp_component i,
     (dummyt d  WITH seq = rcnt)
    SET i.seq = 1
    PLAN (d
     WHERE (request->reference_ranges[d.seq].dcp_interp_id > 0))
     JOIN (i
     WHERE (i.dcp_interp_id=request->reference_ranges[d.seq].dcp_interp_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from dcp_interp_component table")
   DELETE  FROM dcp_interp_state i,
     (dummyt d  WITH seq = rcnt)
    SET i.seq = 1
    PLAN (d
     WHERE (request->reference_ranges[d.seq].dcp_interp_id > 0))
     JOIN (i
     WHERE (i.dcp_interp_id=request->reference_ranges[d.seq].dcp_interp_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from dcp_interp_state table")
   DELETE  FROM dcp_interp i,
     (dummyt d  WITH seq = rcnt)
    SET i.seq = 1
    PLAN (d
     WHERE (request->reference_ranges[d.seq].dcp_interp_id > 0))
     JOIN (i
     WHERE (i.dcp_interp_id=request->reference_ranges[d.seq].dcp_interp_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from dcp_interp table")
   RETURN
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
