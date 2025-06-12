CREATE PROGRAM bed_ens_gpros:dba
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
 CALL bedbeginscript(0)
 IF ( NOT (validate(cs43_business_cd)))
  DECLARE cs43_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 ENDIF
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs8_auth_cd)))
  DECLARE cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 ENDIF
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
 replace("REPLY",acm_get_curr_logical_domain_rep)
 DECLARE gpros_count = i4 WITH protect, constant(size(request->gpros,5))
 DECLARE no_change_flag = i4 WITH protect, constant(0)
 DECLARE add_flag = i4 WITH protect, constant(1)
 DECLARE update_flag = i4 WITH protect, constant(2)
 DECLARE delete_flag = i4 WITH protect, constant(3)
 DECLARE br_group_id = f8 WITH protect, noconstant(0.0)
 DECLARE processgprorequest(dummyvar=i2) = i2
 DECLARE insertgpro(current_gpro_index=i4) = i2
 DECLARE updategpro(current_gpro_index=i4) = i2
 DECLARE removegpro(current_gpro_index=i4) = i2
 DECLARE insertprovider(current_gpro_index=i4,current_provider_index=i4) = null
 DECLARE activatinganexistingep(current_gpro_index=i4,current_provider_index=i4) = null
 DECLARE removeprovider(current_gpro_index=i4,current_provider_index=i4) = null
 DECLARE updateprovider(current_gpro_index=i4,current_provider_index=i4) = null
 DECLARE insertgproaddress(current_gpro_index=i2) = null
 DECLARE updategproaddress(dummyvar=i2) = null
 DECLARE insertgprophone(current_gpro_index=i4) = null
 DECLARE updategprophone(current_gpro_index=i4) = null
 CALL processgprorequest(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE processgprorequest(dummyvar)
  FOR (gprocnt = 1 TO gpros_count)
    IF ((request->gpros[gprocnt].action_flag=no_change_flag))
     SET dummyvar = 0
    ELSEIF ((request->gpros[gprocnt].action_flag=add_flag))
     CALL insertgpro(gprocnt)
    ELSEIF ((request->gpros[gprocnt].action_flag=update_flag))
     CALL updategpro(gprocnt)
    ELSEIF ((request->gpros[gprocnt].action_flag=delete_flag))
     CALL removegpro(gprocnt)
    ELSE
     CALL bederror("ERROR 001: Invalid GPRO action_flag.")
    ENDIF
    SET gpro_provider_count = size(request->gpros[gprocnt].providers,5)
    FOR (providercnt = 1 TO gpro_provider_count)
      IF ((request->gpros[gprocnt].providers[providercnt].action_flag=no_change_flag))
       SET dummyvar = 0
      ELSEIF ((request->gpros[gprocnt].providers[providercnt].action_flag=add_flag))
       CALL insertprovider(gprocnt,providercnt)
      ELSEIF ((request->gpros[gprocnt].providers[providercnt].action_flag=delete_flag))
       CALL removeprovider(gprocnt,providercnt)
      ELSEIF ((request->gpros[gprocnt].providers[providercnt].action_flag=update_flag))
       CALL updateprovider(gprocnt,providercnt)
      ELSE
       CALL bederror("ERROR 002: Invalid providers action_flag.")
      ENDIF
    ENDFOR
    IF ((request->gpros[gprocnt].address.action_flag=no_change_flag))
     SET dummyvar = 0
    ELSEIF ((request->gpros[gprocnt].address.action_flag=add_flag))
     CALL insertgproaddress(gprocnt)
    ELSEIF ((request->gpros[gprocnt].address.action_flag=update_flag))
     CALL updategproaddress(gprocnt)
    ELSE
     CALL bederror("ERROR 003: Invalid GPRO address action_flag.")
    ENDIF
    IF ((request->gpros[gprocnt].phone.action_flag=no_change_flag))
     SET dummyvar = 0
    ELSEIF ((request->gpros[gprocnt].phone.action_flag=add_flag))
     CALL insertgprophone(gprocnt)
    ELSEIF ((request->gpros[gprocnt].phone.action_flag=update_flag))
     CALL updategprophone(gprocnt)
    ELSE
     CALL bederror("ERROR 004: Invalid GPRO phone action_flag.")
    ENDIF
  ENDFOR
  RETURN(1)
 END ;Subroutine
 SUBROUTINE insertgpro(current_gpro_index)
   SET br_group_id_new = 0.0
   SELECT INTO "nl:"
    FROM br_gpro gpro
    WHERE (gpro.br_gpro_name=request->gpros[current_gpro_index].group_name)
     AND (gpro.tax_id_nbr_txt=request->gpros[current_gpro_index].tin)
     AND gpro.active_ind=0
     AND gpro.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    DETAIL
     br_group_id_new = gpro.br_gpro_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 005 : Error while finding an inactive(logically deleted gpro) gpro")
   IF (curqual > 0)
    SET request->gpros[current_gpro_index].group_id = br_group_id_new
    CALL updategpro(current_gpro_index)
   ELSE
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_group_id_new = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERROR 006: Problems occurred retrieving next sequence value for BR_GPRO PK.")
    INSERT  FROM br_gpro gpro
     SET gpro.br_gpro_id = br_group_id_new, gpro.br_gpro_name = request->gpros[current_gpro_index].
      group_name, gpro.tax_id_nbr_txt = request->gpros[current_gpro_index].tin,
      gpro.updt_dt_tm = cnvtdatetime(curdate,curtime3), gpro.updt_id = reqinfo->updt_id, gpro
      .updt_task = reqinfo->updt_task,
      gpro.updt_applctx = reqinfo->updt_applctx, gpro.updt_cnt = 0, gpro.active_ind = 1,
      gpro.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, gpro
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), gpro.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00"),
      gpro.orig_br_gpro_id = br_group_id_new, gpro.submit_type_flag = request->gpros[
      current_gpro_index].submit_type_flag
     WITH nocounter
    ;end insert
    CALL bederrorcheck("ERROR 007: Problems occurred writing new GPRO to BR_GPRO table.")
    SET request->gpros[current_gpro_index].group_id = br_group_id_new
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updategpro(current_gpro_index)
   SET br_group_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_group_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 008: Problems occurred retrieving next sequence value for BR_GPRO historical row.")
   SET history_gpro_id = br_group_id
   DECLARE history_gpro_name = vc
   DECLARE history_gpro_tax_id_nbr_txt = vc
   DECLARE history_gpro_updt_dt_tm = dq8
   DECLARE history_gpro_updt_id = f8
   DECLARE history_gpro_updt_task = i4
   DECLARE history_gpro_updt_applctx = f8
   DECLARE history_gpro_updt_cnt = i4
   DECLARE history_gpro_logical_domain_id = f8
   DECLARE history_beg_effective_dt_tm = dq8
   DECLARE history_gpro_active_ind = i2
   DECLARE history_submit_type_flag = i2
   SELECT INTO "nl:"
    FROM br_gpro gpro
    WHERE (gpro.br_gpro_id=request->gpros[current_gpro_index].group_id)
    DETAIL
     history_gpro_name = gpro.br_gpro_name, history_gpro_tax_id_nbr_txt = gpro.tax_id_nbr_txt,
     history_gpro_updt_dt_tm = gpro.updt_dt_tm,
     history_gpro_updt_id = gpro.updt_id, history_gpro_updt_task = gpro.updt_task,
     history_gpro_updt_applctx = gpro.updt_applctx,
     history_gpro_updt_cnt = gpro.updt_cnt, history_gpro_logical_domain_id = gpro.logical_domain_id,
     history_beg_effective_dt_tm = gpro.beg_effective_dt_tm,
     history_gpro_active_ind = gpro.active_ind, history_submit_type_flag = gpro.submit_type_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 009: Problems occurred writing new GPRO to BR_GPRO table.")
   INSERT  FROM br_gpro gpro
    SET gpro.br_gpro_id = history_gpro_id, gpro.br_gpro_name = history_gpro_name, gpro.tax_id_nbr_txt
      = history_gpro_tax_id_nbr_txt,
     gpro.updt_dt_tm = cnvtdatetime(history_gpro_updt_dt_tm), gpro.updt_id = history_gpro_updt_id,
     gpro.updt_task = history_gpro_updt_task,
     gpro.updt_applctx = history_gpro_updt_applctx, gpro.updt_cnt = history_gpro_updt_cnt, gpro
     .active_ind = history_gpro_active_ind,
     gpro.logical_domain_id = history_gpro_logical_domain_id, gpro.beg_effective_dt_tm = cnvtdatetime
     (history_beg_effective_dt_tm), gpro.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     gpro.orig_br_gpro_id = request->gpros[current_gpro_index].group_id, gpro.submit_type_flag =
     history_submit_type_flag
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 010: Problems occurred writing new GPRO to BR_GPRO table.")
   UPDATE  FROM br_gpro gpro
    SET gpro.br_gpro_name = request->gpros[current_gpro_index].group_name, gpro.active_ind = 1, gpro
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     gpro.tax_id_nbr_txt = request->gpros[current_gpro_index].tin, gpro.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), gpro.updt_id = reqinfo->updt_id,
     gpro.updt_task = reqinfo->updt_task, gpro.updt_applctx = reqinfo->updt_applctx, gpro.updt_cnt =
     (history_gpro_updt_cnt+ 1),
     gpro.submit_type_flag = request->gpros[current_gpro_index].submit_type_flag
    WHERE (gpro.br_gpro_id=request->gpros[current_gpro_index].group_id)
    WITH nocounter
   ;end update
   RETURN(1)
 END ;Subroutine
 SUBROUTINE removegpro(current_gpro_index)
   SET br_group_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_group_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 011: Problems occurred retrieving next sequence value for BR_GPRO historical row.")
   SET history_gpro_id = br_group_id
   DECLARE history_gpro_name = vc
   DECLARE history_gpro_tax_id_nbr_txt = vc
   DECLARE history_gpro_updt_dt_tm = dq8
   DECLARE history_gpro_updt_id = f8
   DECLARE history_gpro_updt_task = i4
   DECLARE history_gpro_updt_applctx = f8
   DECLARE history_gpro_updt_cnt = i4
   DECLARE history_gpro_logical_domain_id = f8
   DECLARE history_beg_effective_dt_tm = dq8
   DECLARE history_submit_type_flag = i2
   SELECT INTO "nl:"
    FROM br_gpro gpro
    WHERE (gpro.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND gpro.active_ind=1
    DETAIL
     history_gpro_name = gpro.br_gpro_name, history_gpro_tax_id_nbr_txt = gpro.tax_id_nbr_txt,
     history_gpro_updt_dt_tm = gpro.updt_dt_tm,
     history_gpro_updt_id = gpro.updt_id, history_gpro_updt_task = gpro.updt_task,
     history_gpro_updt_applctx = gpro.updt_applctx,
     history_gpro_updt_cnt = gpro.updt_cnt, history_gpro_logical_domain_id = gpro.logical_domain_id,
     history_beg_effective_dt_tm = gpro.beg_effective_dt_tm,
     history_submit_type_flag = gpro.submit_type_flag
    WITH nocounter
   ;end select
   INSERT  FROM br_gpro gpro
    SET gpro.br_gpro_id = history_gpro_id, gpro.br_gpro_name = history_gpro_name, gpro.tax_id_nbr_txt
      = history_gpro_tax_id_nbr_txt,
     gpro.updt_dt_tm = cnvtdatetime(history_gpro_updt_dt_tm), gpro.updt_id = history_gpro_updt_id,
     gpro.updt_task = history_gpro_updt_task,
     gpro.updt_applctx = history_gpro_updt_applctx, gpro.updt_cnt = history_gpro_updt_cnt, gpro
     .active_ind = 1,
     gpro.logical_domain_id = history_gpro_logical_domain_id, gpro.beg_effective_dt_tm = cnvtdatetime
     (history_beg_effective_dt_tm), gpro.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     gpro.orig_br_gpro_id = request->gpros[current_gpro_index].group_id, gpro.submit_type_flag =
     history_submit_type_flag
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 012: Problems occurred writing new GPRO to BR_GPRO table.")
   UPDATE  FROM br_gpro gpro
    SET gpro.br_gpro_name = request->gpros[current_gpro_index].group_name, gpro.beg_effective_dt_tm
      = cnvtdatetime(curdate,curtime3), gpro.tax_id_nbr_txt = request->gpros[current_gpro_index].tin,
     gpro.updt_dt_tm = cnvtdatetime(curdate,curtime3), gpro.updt_id = reqinfo->updt_id, gpro
     .updt_task = reqinfo->updt_task,
     gpro.updt_applctx = reqinfo->updt_applctx, gpro.updt_cnt = (history_gpro_updt_cnt+ 1), gpro
     .active_ind = 0,
     gpro.submit_type_flag = request->gpros[current_gpro_index].submit_type_flag
    WHERE (gpro.br_gpro_id=request->gpros[current_gpro_index].group_id)
    WITH nocounter
   ;end update
   DELETE  FROM phone p
    WHERE p.parent_entity_name="BR_GPRO"
     AND (p.parent_entity_id=request->gpros[current_gpro_index].group_id)
    WITH nocounter
   ;end delete
   DELETE  FROM address a
    WHERE a.parent_entity_name="BR_GPRO"
     AND (a.parent_entity_id=request->gpros[current_gpro_index].group_id)
    WITH nocounter
   ;end delete
   IF ( NOT (validate(br_gpro_reltn_hist,0)))
    RECORD br_gpro_reltn_hist(
      1 relations_to_delete[*]
        2 br_gpro_reltn_id = f8
        2 orig_br_gpro_reltn_id = f8
        2 br_gpro_id = f8
        2 parent_entity_name = vc
        2 parent_entity_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 updt_id = f8
        2 updt_task = i4
        2 updt_applctx = f8
        2 updt_dt_tm = dq8
        2 updt_cnt = i4
        2 aci_exclusion_ind = i2
    ) WITH protect
   ENDIF
   SET current_row_cnt = 0
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND bgr.active_ind=1
    DETAIL
     current_row_cnt = (current_row_cnt+ 1), stat = alterlist(br_gpro_reltn_hist->relations_to_delete,
      current_row_cnt), br_gpro_reltn_hist->relations_to_delete[current_row_cnt].br_gpro_reltn_id =
     bgr.br_gpro_reltn_id,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].orig_br_gpro_reltn_id = bgr
     .orig_br_gpro_reltn_id, br_gpro_reltn_hist->relations_to_delete[current_row_cnt].br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->relations_to_delete[current_row_cnt].parent_entity_name =
     bgr.parent_entity_name,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].parent_entity_id = bgr.parent_entity_id,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].beg_effective_dt_tm = bgr
     .beg_effective_dt_tm, br_gpro_reltn_hist->relations_to_delete[current_row_cnt].
     end_effective_dt_tm = bgr.end_effective_dt_tm,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].updt_id = bgr.updt_id,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].updt_task = bgr.updt_task,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].updt_dt_tm = bgr.updt_dt_tm,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].updt_cnt = bgr.updt_cnt,
     br_gpro_reltn_hist->relations_to_delete[current_row_cnt].aci_exclusion_ind = bgr
     .aci_excluded_ind
    WITH nocounter
   ;end select
   FOR (currowcnt = 1 TO current_row_cnt)
     SET br_new_gpro_reltn_id = 0.0
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       br_new_gpro_reltn_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck(
      "ERROR 013: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
     UPDATE  FROM br_gpro_reltn bgr
      SET bgr.active_ind = 0, bgr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), bgr
       .updt_id = reqinfo->updt_id,
       bgr.updt_cnt = 0, bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_task = reqinfo->updt_task,
       bgr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->relations_to_delete[currowcnt].br_gpro_reltn_id
      )
       AND bgr.active_ind=1
       AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ERROR 014: Problems occurred updating the BR_GPRO_RELTN table.")
     CALL bedlogmessage("updt_dt_tm",cnvtstring(br_gpro_reltn_hist->relations_to_delete[currowcnt].
       updt_dt_tm))
     INSERT  FROM br_gpro_reltn bgr
      SET bgr.br_gpro_reltn_id = br_new_gpro_reltn_id, bgr.orig_br_gpro_reltn_id = br_gpro_reltn_hist
       ->relations_to_delete[currowcnt].br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->
       relations_to_delete[currowcnt].br_gpro_id,
       bgr.parent_entity_name = br_gpro_reltn_hist->relations_to_delete[currowcnt].parent_entity_name,
       bgr.parent_entity_id = br_gpro_reltn_hist->relations_to_delete[currowcnt].parent_entity_id,
       bgr.active_ind = 1,
       bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->relations_to_delete[currowcnt].updt_dt_tm),
       bgr.updt_id = br_gpro_reltn_hist->relations_to_delete[currowcnt].updt_id, bgr.updt_task =
       br_gpro_reltn_hist->relations_to_delete[currowcnt].updt_task,
       bgr.updt_applctx = br_gpro_reltn_hist->relations_to_delete[currowcnt].updt_applctx, bgr
       .updt_cnt = br_gpro_reltn_hist->relations_to_delete[currowcnt].updt_cnt, bgr
       .beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->relations_to_delete[currowcnt].
        beg_effective_dt_tm),
       bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.aci_excluded_ind =
       br_gpro_reltn_hist->relations_to_delete[currowcnt].aci_exclusion_ind
      WITH nocounter
     ;end insert
     CALL bederrorcheck(
      "ERROR 015: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   ENDFOR
   IF ( NOT (validate(br_gpros_measures_hist,0)))
    RECORD br_gpros_measures_hist(
      1 br_gpros_measures_hist_rows[*]
        2 lh_cqm_meas_svc_entity_r_id = f8
    ) WITH protect
   ENDIF
   SET current_row_cnt = 0
   SELECT INTO "nl:"
    FROM lh_cqm_meas_svc_entity_r r
    WHERE (r.parent_entity_id=request->gpros[current_gpro_index].group_id)
     AND r.parent_entity_name="BR_GPRO"
    DETAIL
     current_row_cnt = (current_row_cnt+ 1), stat = alterlist(br_gpros_measures_hist->
      br_gpros_measures_hist_rows,current_row_cnt), br_gpros_measures_hist->
     br_gpros_measures_hist_rows[current_row_cnt].lh_cqm_meas_svc_entity_r_id = r
     .lh_cqm_meas_svc_entity_r_id
    WITH nocounter
   ;end select
   DELETE  FROM lh_cqm_meas_svc_entity_r r
    WHERE (r.parent_entity_id=request->gpros[current_gpro_index].group_id)
     AND r.parent_entity_name="BR_GPRO"
    WITH nocounter
   ;end delete
   FOR (curcnt = 1 TO current_row_cnt)
     INSERT  FROM br_delete_hist his
      SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name =
       "LH_CQM_MEAS_SVC_ENTITY_R", his.parent_entity_id = br_gpros_measures_hist->
       br_gpros_measures_hist_rows[curcnt].lh_cqm_meas_svc_entity_r_id,
       his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task
        = reqinfo->updt_task,
       his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
        curdate,curtime3)
      WITH nocounter
     ;end insert
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE insertprovider(current_gpro_index,current_provider_index)
   SET br_gpro_reltn_id_new = 0.0
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND (bgr.parent_entity_id=request->gpros[current_gpro_index].providers[current_provider_index].
    id)
     AND bgr.active_ind=0
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_id_new = bgr.br_gpro_reltn_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 016 : Error while finding an inactive(logically deleted) gpro")
   IF (curqual > 0)
    CALL activatinganexistingep(current_gpro_index,current_provider_index)
   ELSE
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_gpro_reltn_id_new = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck(
     "ERROR 017: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
    INSERT  FROM br_gpro_reltn bgr
     SET bgr.br_gpro_reltn_id = br_gpro_reltn_id_new, bgr.orig_br_gpro_reltn_id =
      br_gpro_reltn_id_new, bgr.br_gpro_id = request->gpros[current_gpro_index].group_id,
      bgr.parent_entity_name = "BR_ELIGIBLE_PROVIDER", bgr.parent_entity_id = request->gpros[
      current_gpro_index].providers[current_provider_index].id, bgr.active_ind = 1,
      bgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bgr.updt_id = reqinfo->updt_id, bgr.updt_task
       = reqinfo->updt_task,
      bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_cnt = 0, bgr.beg_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bgr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), bgr.aci_excluded_ind = request
      ->gpros[current_gpro_index].providers[current_provider_index].aci_exclusion_ind
     WITH nocounter
    ;end insert
    CALL bederrorcheck(
     "ERROR 018: Problems occurred writing new GPRO relationship to BR_GPRO_RELTN table.")
   ENDIF
 END ;Subroutine
 SUBROUTINE activatinganexistingep(current_gpro_index,current_provider_index)
   IF ( NOT (validate(br_gpro_reltn_hist,0)))
    RECORD br_gpro_reltn_hist(
      1 br_gpro_reltn_id = f8
      1 orig_br_gpro_reltn_id = f8
      1 br_gpro_id = f8
      1 parent_entity_name = vc
      1 parent_entity_id = f8
      1 beg_effective_dt_tm = dq8
      1 end_effective_dt_tm = dq8
      1 updt_id = f8
      1 updt_task = i4
      1 updt_applctx = f8
      1 updt_dt_tm = dq8
      1 updt_cnt = i4
      1 aci_exclusion_ind = i2
    ) WITH protect
   ENDIF
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND (bgr.parent_entity_id=request->gpros[current_gpro_index].providers[current_provider_index].
    id)
     AND bgr.active_ind=0
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_hist->br_gpro_reltn_id = bgr.br_gpro_reltn_id, br_gpro_reltn_hist->br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->parent_entity_name = bgr.parent_entity_name,
     br_gpro_reltn_hist->parent_entity_id = bgr.parent_entity_id, br_gpro_reltn_hist->
     beg_effective_dt_tm = bgr.beg_effective_dt_tm, br_gpro_reltn_hist->end_effective_dt_tm = bgr
     .end_effective_dt_tm,
     br_gpro_reltn_hist->updt_id = bgr.updt_id, br_gpro_reltn_hist->updt_task = bgr.updt_task,
     br_gpro_reltn_hist->updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->updt_dt_tm = bgr.updt_dt_tm, br_gpro_reltn_hist->updt_cnt = bgr.updt_cnt,
     br_gpro_reltn_hist->aci_exclusion_ind = bgr.aci_excluded_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 019: Problems occurred selecting the current row from BR_GPRO_RELTN table for history.")
   SET br_new_hist_gpro_reltn_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_new_hist_gpro_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 020: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
   INSERT  FROM br_gpro_reltn bgr
    SET bgr.br_gpro_reltn_id = br_new_hist_gpro_reltn_id, bgr.orig_br_gpro_reltn_id =
     br_gpro_reltn_hist->br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->br_gpro_id,
     bgr.parent_entity_name = br_gpro_reltn_hist->parent_entity_name, bgr.parent_entity_id =
     br_gpro_reltn_hist->parent_entity_id, bgr.active_ind = 0,
     bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->updt_dt_tm), bgr.updt_id = br_gpro_reltn_hist
     ->updt_id, bgr.updt_task = br_gpro_reltn_hist->updt_task,
     bgr.updt_applctx = br_gpro_reltn_hist->updt_applctx, bgr.updt_cnt = br_gpro_reltn_hist->updt_cnt,
     bgr.beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->beg_effective_dt_tm),
     bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.aci_excluded_ind =
     br_gpro_reltn_hist->aci_exclusion_ind
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 021: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.active_ind = 1, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr
     .aci_excluded_ind = request->gpros[current_gpro_index].providers[current_provider_index].
     aci_exclusion_ind
    WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn_id)
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 022: Problems occurred updating the BR_GPRO_RELTN table.")
 END ;Subroutine
 SUBROUTINE updateprovider(current_gpro_index,current_provider_index)
   IF ( NOT (validate(br_gpro_reltn_hist,0)))
    RECORD br_gpro_reltn_hist(
      1 br_gpro_reltn_id = f8
      1 orig_br_gpro_reltn_id = f8
      1 br_gpro_id = f8
      1 parent_entity_name = vc
      1 parent_entity_id = f8
      1 beg_effective_dt_tm = dq8
      1 end_effective_dt_tm = dq8
      1 updt_id = f8
      1 updt_task = i4
      1 updt_applctx = f8
      1 updt_dt_tm = dq8
      1 updt_cnt = i4
      1 aci_exclusion_ind = i2
    ) WITH protect
   ENDIF
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND (bgr.parent_entity_id=request->gpros[current_gpro_index].providers[current_provider_index].
    id)
     AND bgr.active_ind=1
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_hist->br_gpro_reltn_id = bgr.br_gpro_reltn_id, br_gpro_reltn_hist->br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->parent_entity_name = bgr.parent_entity_name,
     br_gpro_reltn_hist->parent_entity_id = bgr.parent_entity_id, br_gpro_reltn_hist->
     beg_effective_dt_tm = bgr.beg_effective_dt_tm, br_gpro_reltn_hist->end_effective_dt_tm = bgr
     .end_effective_dt_tm,
     br_gpro_reltn_hist->updt_id = bgr.updt_id, br_gpro_reltn_hist->updt_task = bgr.updt_task,
     br_gpro_reltn_hist->updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->updt_dt_tm = bgr.updt_dt_tm, br_gpro_reltn_hist->updt_cnt = bgr.updt_cnt,
     br_gpro_reltn_hist->aci_exclusion_ind = bgr.aci_excluded_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 032: Problems occurred selecting the current row from BR_GPRO_RELTN table for history.")
   SET br_new_hist_gpro_reltn_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_new_hist_gpro_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 033: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
   INSERT  FROM br_gpro_reltn bgr
    SET bgr.br_gpro_reltn_id = br_new_hist_gpro_reltn_id, bgr.orig_br_gpro_reltn_id =
     br_gpro_reltn_hist->br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->br_gpro_id,
     bgr.parent_entity_name = br_gpro_reltn_hist->parent_entity_name, bgr.parent_entity_id =
     br_gpro_reltn_hist->parent_entity_id, bgr.active_ind = 1,
     bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->updt_dt_tm), bgr.updt_id = br_gpro_reltn_hist
     ->updt_id, bgr.updt_task = br_gpro_reltn_hist->updt_task,
     bgr.updt_applctx = br_gpro_reltn_hist->updt_applctx, bgr.updt_cnt = br_gpro_reltn_hist->updt_cnt,
     bgr.beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->beg_effective_dt_tm),
     bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.aci_excluded_ind =
     br_gpro_reltn_hist->aci_exclusion_ind
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 034: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.aci_excluded_ind = request->
     gpros[current_gpro_index].providers[current_provider_index].aci_exclusion_ind
    WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn_id)
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 035: Problems occurred updating the BR_GPRO_RELTN table.")
 END ;Subroutine
 SUBROUTINE removeprovider(current_gpro_index,current_provider_index)
   IF ( NOT (validate(br_gpro_reltn_hist,0)))
    RECORD br_gpro_reltn_hist(
      1 br_gpro_reltn_id = f8
      1 orig_br_gpro_reltn_id = f8
      1 br_gpro_id = f8
      1 parent_entity_name = vc
      1 parent_entity_id = f8
      1 beg_effective_dt_tm = dq8
      1 end_effective_dt_tm = dq8
      1 updt_id = f8
      1 updt_task = i4
      1 updt_applctx = f8
      1 updt_dt_tm = dq8
      1 updt_cnt = i4
      1 aci_exclusion_ind = i2
    ) WITH protect
   ENDIF
   SELECT INTO "nl:"
    FROM br_gpro_reltn bgr
    WHERE (bgr.br_gpro_id=request->gpros[current_gpro_index].group_id)
     AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND (bgr.parent_entity_id=request->gpros[current_gpro_index].providers[current_provider_index].
    id)
     AND bgr.active_ind=1
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     br_gpro_reltn_hist->br_gpro_reltn_id = bgr.br_gpro_reltn_id, br_gpro_reltn_hist->br_gpro_id =
     bgr.br_gpro_id, br_gpro_reltn_hist->parent_entity_name = bgr.parent_entity_name,
     br_gpro_reltn_hist->parent_entity_id = bgr.parent_entity_id, br_gpro_reltn_hist->
     beg_effective_dt_tm = bgr.beg_effective_dt_tm, br_gpro_reltn_hist->end_effective_dt_tm = bgr
     .end_effective_dt_tm,
     br_gpro_reltn_hist->updt_id = bgr.updt_id, br_gpro_reltn_hist->updt_task = bgr.updt_task,
     br_gpro_reltn_hist->updt_applctx = bgr.updt_applctx,
     br_gpro_reltn_hist->updt_dt_tm = bgr.updt_dt_tm, br_gpro_reltn_hist->updt_cnt = bgr.updt_cnt,
     br_gpro_reltn_hist->aci_exclusion_ind = bgr.aci_excluded_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 023: Problems occurred selecting from BR_GPRO_RELTN table.")
   SET br_new_gpro_reltn_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_new_gpro_reltn_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "ERROR 024: Problems occurred retrieving next sequence value for BR_GPRO_RELTN PK.")
   INSERT  FROM br_gpro_reltn bgr
    SET bgr.br_gpro_reltn_id = br_new_gpro_reltn_id, bgr.orig_br_gpro_reltn_id = br_gpro_reltn_hist->
     br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->br_gpro_id,
     bgr.parent_entity_name = br_gpro_reltn_hist->parent_entity_name, bgr.parent_entity_id =
     br_gpro_reltn_hist->parent_entity_id, bgr.active_ind = 1,
     bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->updt_dt_tm), bgr.updt_id = br_gpro_reltn_hist
     ->updt_id, bgr.updt_task = br_gpro_reltn_hist->updt_task,
     bgr.updt_applctx = br_gpro_reltn_hist->updt_applctx, bgr.updt_cnt = br_gpro_reltn_hist->updt_cnt,
     bgr.beg_effective_dt_tm = cnvtdatetime(br_gpro_reltn_hist->beg_effective_dt_tm),
     bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.aci_excluded_ind =
     br_gpro_reltn_hist->aci_exclusion_ind
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 025: Problems occurred writing history row to the BR_GPRO_RELTN table.")
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.active_ind = 0, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn_id)
     AND bgr.active_ind=1
     AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 026: Problems occurred updating the BR_GPRO_RELTN table.")
 END ;Subroutine
 SUBROUTINE insertgproaddress(current_gpro_index)
   SET address_id = 0.0
   SELECT INTO "nl:"
    z = seq(address_seq,nextval)
    FROM dual
    DETAIL
     address_id = cnvtreal(z)
    WITH nocounter
   ;end select
   INSERT  FROM address addr
    SET addr.address_id = address_id, addr.parent_entity_name = "BR_GPRO", addr.parent_entity_id =
     request->gpros[current_gpro_index].group_id,
     addr.street_addr = trim(request->gpros[current_gpro_index].address.street_addr1), addr
     .street_addr2 = trim(request->gpros[current_gpro_index].address.street_addr2), addr.street_addr3
      = trim(request->gpros[current_gpro_index].address.street_addr3),
     addr.street_addr4 = trim(request->gpros[current_gpro_index].address.street_addr4), addr.city =
     trim(request->gpros[current_gpro_index].address.city), addr.state_cd = request->gpros[
     current_gpro_index].address.state_code_value,
     addr.zipcode = trim(cnvtupper(request->gpros[current_gpro_index].address.zipcode)), addr
     .county_cd = request->gpros[current_gpro_index].address.county_code_value, addr.country_cd =
     request->gpros[current_gpro_index].address.country_code_value,
     addr.contact_name = trim(request->gpros[current_gpro_index].address.contact_name), addr
     .comment_txt = trim(request->gpros[current_gpro_index].address.comment_txt), addr.active_ind = 1,
     addr.active_status_cd = cs48_active_cd, addr.active_status_dt_tm = cnvtdatetime(curdate,curtime3
      ), addr.active_status_prsnl_id = reqinfo->updt_id,
     addr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), addr.end_effective_dt_tm =
     cnvtdatetime("31-DEC-2100"), addr.data_status_cd = cs8_auth_cd,
     addr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), addr.data_status_prsnl_id = reqinfo->
     updt_id, addr.updt_id = reqinfo->updt_id,
     addr.updt_cnt = 0, addr.updt_applctx = reqinfo->updt_applctx, addr.updt_task = reqinfo->
     updt_task,
     addr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 027: Error while inserting Address for GPRO ")
 END ;Subroutine
 SUBROUTINE updategproaddress(current_gpro_index)
  UPDATE  FROM address addr
   SET addr.parent_entity_name = "BR_GPRO", addr.parent_entity_id = request->gpros[current_gpro_index
    ].group_id, addr.street_addr = trim(request->gpros[current_gpro_index].address.street_addr1),
    addr.street_addr2 = trim(request->gpros[current_gpro_index].address.street_addr2), addr
    .street_addr3 = trim(request->gpros[current_gpro_index].address.street_addr3), addr.street_addr4
     = trim(request->gpros[current_gpro_index].address.street_addr4),
    addr.city = trim(request->gpros[current_gpro_index].address.city), addr.state_cd = request->
    gpros[current_gpro_index].address.state_code_value, addr.zipcode = trim(cnvtupper(request->gpros[
      current_gpro_index].address.zipcode)),
    addr.county_cd = request->gpros[current_gpro_index].address.county_code_value, addr.country_cd =
    request->gpros[current_gpro_index].address.country_code_value, addr.contact_name = trim(request->
     gpros[current_gpro_index].address.contact_name),
    addr.comment_txt = trim(request->gpros[current_gpro_index].address.comment_txt), addr.updt_id =
    reqinfo->updt_id, addr.updt_cnt = (addr.updt_cnt+ 1),
    addr.updt_applctx = reqinfo->updt_applctx, addr.updt_task = reqinfo->updt_task, addr.updt_dt_tm
     = cnvtdatetime(curdate,curtime3)
   WHERE (addr.address_id=request->gpros[current_gpro_index].address.address_id)
    AND addr.active_ind=1
   WITH nocounter
  ;end update
  CALL bederrorcheck("ERROR 028: Error while updating Address for GPRO ")
 END ;Subroutine
 SUBROUTINE insertgprophone(current_gpro_index)
   SET phone_id = 0.0
   SELECT INTO "nl:"
    z = seq(phone_seq,nextval)
    FROM dual
    DETAIL
     phone_id = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 029:  Error generating phone id")
   INSERT  FROM phone p
    SET p.phone_id = phone_id, p.parent_entity_name = "BR_GPRO", p.parent_entity_id = request->gpros[
     current_gpro_index].group_id,
     p.phone_type_cd = cs43_business_cd, p.phone_format_cd = request->gpros[current_gpro_index].phone
     .phone_format_code_value, p.phone_num = trim(request->gpros[current_gpro_index].phone.phone_num),
     p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->gpros[current_gpro_index].phone.phone_num
        ))), p.contact = trim(request->gpros[current_gpro_index].phone.contact), p.call_instruction
      = trim(request->gpros[current_gpro_index].phone.call_instruction),
     p.extension = trim(request->gpros[current_gpro_index].phone.extension), p.updt_id = reqinfo->
     updt_id, p.updt_cnt = 0,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.active_ind = 1, p.active_status_cd = cs48_active_cd, p.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     p.data_status_cd = cs8_auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
     .data_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ERROR 030:  Error inserting to phone table")
 END ;Subroutine
 SUBROUTINE updategprophone(current_gpro_index)
  UPDATE  FROM phone p
   SET p.phone_format_cd = request->gpros[current_gpro_index].phone.phone_format_code_value, p
    .phone_num = trim(request->gpros[current_gpro_index].phone.phone_num), p.phone_num_key = trim(
     cnvtupper(cnvtalphanum(request->gpros[current_gpro_index].phone.phone_num))),
    p.contact = trim(request->gpros[current_gpro_index].phone.contact), p.call_instruction = trim(
     request->gpros[current_gpro_index].phone.call_instruction), p.extension = trim(request->gpros[
     current_gpro_index].phone.extension),
    p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
    updt_applctx,
    p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (p.phone_id=request->gpros[current_gpro_index].phone.phone_id)
   WITH nocounter
  ;end update
  CALL bederrorcheck("ERROR 031:  Error updating phone table")
 END ;Subroutine
END GO
