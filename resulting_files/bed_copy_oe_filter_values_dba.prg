CREATE PROGRAM bed_copy_oe_filter_values:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_load
 RECORD temp_load(
   1 temp[*]
     2 load_ind = i2
     2 mean = vc
     2 entity1_id = f8
     2 entity1_display = vc
     2 entity2_id = f8
     2 entity2_display = vc
     2 rank_seq = i4
     2 active_ind = i2
     2 beg_date = dq8
     2 end_date = dq8
     2 entity1_name = vc
     2 entity2_name = vc
     2 entity3_id = f8
     2 entity3_display = vc
     2 entity3_name = vc
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
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE temp_cnt = i4 WITH protect, noconstant(0)
 DECLARE append_flag = i2 WITH protect, noconstant(0)
 DECLARE ent_rel_mean = vc WITH protect, noconstant("")
 SET tcnt = size(request->target_filters,5)
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET ent_rel_mean = fillstring(12," ")
 IF ((request->filter_flag=1))
  SET ent_rel_mean = concat("CT/",cnvtstring(request->code_set))
 ELSEIF ((request->filter_flag=2))
  SET ent_rel_mean = concat("AT/",cnvtstring(request->code_set))
 ELSEIF ((request->filter_flag=3))
  SET ent_rel_mean = concat("ORC/",cnvtstring(request->code_set))
 ELSEIF ((request->filter_flag=4))
  SET ent_rel_mean = concat("OCS/",cnvtstring(request->code_set))
 ENDIF
 CALL logdebugmessage("The ent_rel_mean is:",ent_rel_mean)
 IF (validate(request->append_ind))
  IF ((request->append_ind=1))
   SET append_flag = 1
   SELECT INTO "nl:"
    FROM dcp_entity_reltn der
    WHERE der.entity_reltn_mean=ent_rel_mean
     AND (der.entity1_id=request->source_filter_code_value)
    HEAD REPORT
     cnt = 0, temp_cnt = 0, stat = alterlist(temp_load->temp,100)
    DETAIL
     cnt = (cnt+ 1), temp_cnt = (temp_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_load->temp,(temp_cnt+ 100)), cnt = 1
     ENDIF
     temp_load->temp[temp_cnt].active_ind = der.active_ind, temp_load->temp[temp_cnt].beg_date = der
     .begin_effective_dt_tm, temp_load->temp[temp_cnt].end_date = der.end_effective_dt_tm,
     temp_load->temp[temp_cnt].entity1_display = der.entity1_display, temp_load->temp[temp_cnt].
     entity1_id = der.entity1_id, temp_load->temp[temp_cnt].entity1_name = der.entity1_name,
     temp_load->temp[temp_cnt].entity2_display = der.entity2_display, temp_load->temp[temp_cnt].
     entity2_id = der.entity2_id, temp_load->temp[temp_cnt].entity2_name = der.entity2_name,
     temp_load->temp[temp_cnt].entity3_display = der.entity3_display, temp_load->temp[temp_cnt].
     entity3_id = der.entity3_id, temp_load->temp[temp_cnt].entity3_name = der.entity3_name,
     temp_load->temp[temp_cnt].mean = der.entity_reltn_mean, temp_load->temp[temp_cnt].rank_seq = der
     .rank_sequence
    FOOT REPORT
     stat = alterlist(temp_load->temp,temp_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERR01: Retrieval from dcp_entity_reltn failed.")
   IF (validate(debug,0)=1)
    CALL echorecord(temp_load)
   ENDIF
  ENDIF
 ENDIF
 FOR (t = 1 TO tcnt)
   IF (append_flag=0)
    DELETE  FROM dcp_entity_reltn der
     WHERE der.entity_reltn_mean=ent_rel_mean
      AND (der.entity1_id=request->target_filters[t].code_value)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("ERR02: delete from dcp_entity_reltn failed.")
    SET target_display = fillstring(40," ")
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->target_filters[t].code_value)
     DETAIL
      target_display = cv.display
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERR03: Retrieval from code_value failed.")
    INSERT  FROM dcp_entity_reltn
     (dcp_entity_reltn_id, entity_reltn_mean, entity1_id,
     entity1_display, entity2_id, entity2_display,
     entity3_id, entity3_display, rank_sequence,
     active_ind, begin_effective_dt_tm, end_effective_dt_tm,
     updt_applctx, updt_cnt, updt_dt_tm,
     updt_id, updt_task, entity1_name,
     entity2_name, entity3_name)(SELECT
      seq(carenet_seq,nextval), ent_rel_mean, request->target_filters[t].code_value,
      target_display, der.entity2_id, der.entity2_display,
      der.entity3_id, der.entity3_display, der.rank_sequence,
      der.active_ind, der.begin_effective_dt_tm, der.end_effective_dt_tm,
      reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime),
      reqinfo->updt_id, reqinfo->updt_task, der.entity1_name,
      der.entity2_name, der.entity3_name
      FROM dcp_entity_reltn der
      WHERE der.entity_reltn_mean=ent_rel_mean
       AND (der.entity1_id=request->source_filter_code_value))
     WITH nocounter
    ;end insert
    CALL bederrorcheck("ERR 04: insert into dcp_entity_reltn failed.")
   ELSEIF (append_flag=1
    AND temp_cnt > 0)
    SET target_display = fillstring(40," ")
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->target_filters[t].code_value)
     DETAIL
      target_display = cv.display
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERR 05: Retrieval from code_value failed.")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(temp_cnt)),
      dcp_entity_reltn der
     PLAN (d)
      JOIN (der
      WHERE (der.entity_reltn_mean=temp_load->temp[d.seq].mean)
       AND (der.entity1_id=request->target_filters[t].code_value)
       AND (der.entity2_id=temp_load->temp[d.seq].entity2_id)
       AND (der.entity2_name=temp_load->temp[d.seq].entity2_name)
       AND (der.entity3_id=temp_load->temp[d.seq].entity3_id)
       AND (der.entity3_name=temp_load->temp[d.seq].entity3_name))
     ORDER BY d.seq
     DETAIL
      temp_load->temp[d.seq].load_ind = 3
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERR 06: Retrieval from dcp_entity_reltn failed.")
    IF (validate(debug,0)=1)
     CALL echorecord(temp_load)
    ENDIF
    INSERT  FROM dcp_entity_reltn der,
      (dummyt d  WITH seq = value(temp_cnt))
     SET der.dcp_entity_reltn_id = seq(carenet_seq,nextval), der.entity_reltn_mean = temp_load->temp[
      d.seq].mean, der.entity1_id = request->target_filters[t].code_value,
      der.entity1_display = target_display, der.entity1_name = temp_load->temp[d.seq].entity1_name,
      der.entity2_id = temp_load->temp[d.seq].entity2_id,
      der.entity2_display = temp_load->temp[d.seq].entity2_display, der.entity2_name = temp_load->
      temp[d.seq].entity2_name, der.entity3_id = temp_load->temp[d.seq].entity3_id,
      der.entity3_display = temp_load->temp[d.seq].entity3_display, der.entity3_name = temp_load->
      temp[d.seq].entity3_name, der.rank_sequence = temp_load->temp[d.seq].rank_seq,
      der.active_ind = temp_load->temp[d.seq].active_ind, der.begin_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), der.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
      der.updt_applctx = reqinfo->updt_applctx, der.updt_cnt = 0, der.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      der.updt_id = reqinfo->updt_id, der.updt_task = reqinfo->updt_task
     PLAN (d
      WHERE (temp_load->temp[d.seq].load_ind=0))
      JOIN (der)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("ERR 07: insert into dcp_entity_reltn failed.")
    FOR (l = 1 TO temp_cnt)
      SET temp_load->temp[l].load_ind = 0
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 CALL bedexitscript(1)
END GO
