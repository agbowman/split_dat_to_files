CREATE PROGRAM bed_ens_alias_pool:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 alias_pools[*]
      2 code_value = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 ) WITH protect
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE column_exists(stable,scolumn) = i4
 DECLARE get_next_seq(seq_name=vc) = f8
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE tot_ap = i4
 DECLARE apvar = i4
 DECLARE orgcnt = i4
 DECLARE orgvar = i4
 DECLARE new_alias_pool_code = f8
 DECLARE fin_type_cd = f8
 DECLARE entity_name = vc
 DECLARE entity_type_cd = f8
 DECLARE entity_code_set = i4
 DECLARE cmrn_cd = f8
 DECLARE assigncmrn_cd = f8
 DECLARE assigncmrn_exists = i2
 DECLARE tname = vc
 DECLARE tmnem = vc
 DECLARE found = i2
 DECLARE error_msg = vc
 DECLARE mrn_type_cd = f8
 DECLARE emrn_type_cd = f8
 DECLARE new_cd_value = f8
 DECLARE active = i4
 DECLARE def_alias_method_cd = f8
 DECLARE prg_exists_ind = i2
 DECLARE errorcode = i4
 DECLARE next_seq = f8
 DECLARE seq_string = vc
 DECLARE failed = i2
 DECLARE data_partition_ind = i2 WITH noconstant(0)
 DECLARE error_flag = vc WITH noconstant("N")
 DECLARE auth = f8 WITH noconstant(0.0)
 DECLARE field_found = i2 WITH noconstant(0)
 DECLARE active_cd = f8 WITH noconstant(0.0)
 DECLARE inactive_cd = f8 WITH noconstant(0.0)
 DECLARE req_cnt = i4 WITH public, noconstant(size(request_cv->cd_value_list,5))
 SET reply->status_data.status = "F"
 SET reply_cv->status_data.status = "F"
 SET stat = alterlist(reply_cv->qual,req_cnt)
 SET reply_cv->curqual = req_cnt
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF a IS alias_pool
   SET field_found = validate(a.logical_domain_id)
   FREE RANGE a
   IF (field_found=1)
    SET data_partition_ind = 1
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    ) WITH protect
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    ) WITH protect
    SET acm_get_curr_logical_domain_req->concept = 5
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   auth = cv.code_value
  WITH nocounter
 ;end select
 SET def_alias_method_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14765
    AND c.cdf_meaning="DEFAULT")
  DETAIL
   def_alias_method_cd = c.code_value
  WITH nocounter
 ;end select
 SET fin_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=319
    AND cv.cdf_meaning="FIN NBR"
    AND cv.active_ind=1)
  DETAIL
   fin_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET mrn_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4
    AND cv.cdf_meaning="MRN"
    AND cv.active_ind=1)
  DETAIL
   mrn_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET emrn_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=319
    AND cv.cdf_meaning="MRN"
    AND cv.active_ind=1)
  DETAIL
   emrn_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET cmrn_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4
    AND cv.cdf_meaning="CMRN"
    AND cv.active_ind=1)
  DETAIL
   cmrn_cd = cv.code_value
  WITH nocounter
 ;end select
 SET assigncmrn_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=20790
    AND cv.cdf_meaning="ASSIGNCMRN"
    AND cv.active_ind=1)
  DETAIL
   assigncmrn_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (((active_cd=0.0) OR (((inactive_cd=0.0) OR (def_alias_method_cd=0.0)) )) )
  SET error_flag = "Y"
  SET error_msg = concat("A Cerner defined code value could not be found - ",
   "ACTIVE from 48, INACTIVE from 48, FACILITY from 278, DEFAULT from 14765, ",
   "MRN from 4, FIN NBR from 319, DOCNBR from 320, or PRSNLPRIMID from 320")
  GO TO exit_script
 ENDIF
 SET tot_ap = size(request->alias_pools,5)
 FOR (apvar = 1 TO tot_ap)
   SET entity_type_cd = 0.0
   SET entity_code_set = 0
   SET entity_name = fillstring(25," ")
   IF ((request->alias_pools[apvar].type_code_value > 0.0))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->alias_pools[apvar].type_code_value))
     DETAIL
      entity_type_cd = cv.code_value, entity_code_set = cv.code_set
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error reading code_value for alias pool cd: ",trim(cnvtstring(request->
        alias_pools[apvar].type_code_value)),".")
     GO TO exit_script
    ENDIF
    CASE (entity_code_set)
     OF 4:
      SET entity_name = "PERSON_ALIAS"
     OF 319:
      SET entity_name = "ENCNTR_ALIAS"
     OF 320:
      SET entity_name = "PRSNL_ALIAS"
     OF 334:
      SET entity_name = "ORGANIZATION_ALIAS"
     OF 754:
      SET entity_name = "ORDER_ALIAS"
     OF 4070:
      SET entity_name = "PHM_ID Alias"
     OF 12801:
      SET entity_name = "PowerTrials Alias"
     OF 25711:
      SET entity_name = "Media Alias"
     OF 26881:
      SET entity_name = "SCH_EVENT_ALIAS"
     OF 27121:
      SET entity_name = "HEALTH_PLAN_ALIAS"
     OF 27520:
      SET entity_name = "ProFit Encounter Alias"
     OF 28200:
      SET entity_name = "ProFit Bill Alias"
     OF 4001913:
      SET entity_name = "Medication Claim Alias"
     OF 4002035:
      SET entity_name = "Claim Visit Alias"
     OF 4002262:
      SET entity_name = "ProFit Receipt Alias"
    ENDCASE
   ENDIF
   IF ((request->alias_pools[apvar].action_flag=3))
    SET request_cv->cd_value_list[1].action_flag = 3
    SET request_cv->cd_value_list[1].code_set = 263
    SET request_cv->cd_value_list[1].code_value = request->alias_pools[apvar].code_value
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->alias_pools[apvar].name))
    SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->alias_pools[apvar].
      name))
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status != "S"))
     SET error_flag = "Y"
     SET error_msg = concat("Error inactivating code_value row for alias pool name: ",trim(request->
       alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    UPDATE  FROM alias_pool ap
     SET ap.active_ind = 0, ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_applctx = reqinfo
      ->updt_applctx,
      ap.updt_id = reqinfo->updt_id, ap.updt_cnt = (ap.updt_cnt+ 1), ap.updt_task = reqinfo->
      updt_task
     WHERE (ap.alias_pool_cd=request->alias_pools[apvar].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inactivating alias_pool row for alias pool name: ",trim(request->
       alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    UPDATE  FROM org_alias_pool_reltn oapr
     SET oapr.active_ind = 0, oapr.active_status_cd = inactive_cd, oapr.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_id = reqinfo->updt_id, oapr.updt_cnt = (
      oapr.updt_cnt+ 1),
      oapr.updt_task = reqinfo->updt_task
     WHERE (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
     WITH nocounter
    ;end update
   ENDIF
   SET orgcnt = size(request->alias_pools[apvar].orgs,5)
   SET ii = 1
   FOR (ii = 1 TO orgcnt)
     IF ((request->alias_pools[apvar].orgs[ii].action_flag=3))
      UPDATE  FROM org_alias_pool_reltn oapr
       SET oapr.active_ind = 0, oapr.active_status_cd = inactive_cd, oapr.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_id = reqinfo->updt_id, oapr.updt_cnt = (
        oapr.updt_cnt+ 1),
        oapr.updt_task = reqinfo->updt_task
       WHERE (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
        AND (oapr.organization_id=request->alias_pools[apvar].orgs[ii].id)
        AND oapr.alias_entity_alias_type_cd=entity_type_cd
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
 ENDFOR
 SET apvar = 1
 WHILE (apvar <= tot_ap)
   SET entity_type_cd = 0.0
   SET entity_code_set = 0
   SET entity_name = fillstring(25," ")
   IF ((request->alias_pools[apvar].type_code_value > 0.0))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->alias_pools[apvar].type_code_value))
     DETAIL
      entity_type_cd = cv.code_value, entity_code_set = cv.code_set
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error reading code_value for alias pool cd: ",trim(cnvtstring(request->
        alias_pools[apvar].type_code_value)),".")
     GO TO exit_script
    ENDIF
    CASE (entity_code_set)
     OF 4:
      SET entity_name = "PERSON_ALIAS"
     OF 319:
      SET entity_name = "ENCNTR_ALIAS"
     OF 320:
      SET entity_name = "PRSNL_ALIAS"
     OF 334:
      SET entity_name = "ORGANIZATION_ALIAS"
     OF 754:
      SET entity_name = "ORDER_ALIAS"
     OF 4070:
      SET entity_name = "PHM_ID Alias"
     OF 12801:
      SET entity_name = "PowerTrials Alias"
     OF 25711:
      SET entity_name = "Media Alias"
     OF 26881:
      SET entity_name = "SCH_EVENT_ALIAS"
     OF 27121:
      SET entity_name = "HEALTH_PLAN_ALIAS"
     OF 27520:
      SET entity_name = "ProFit Encounter Alias"
     OF 28200:
      SET entity_name = "ProFit Bill Alias"
     OF 4001913:
      SET entity_name = "Medication Claim Alias"
     OF 4002035:
      SET entity_name = "Claim Visit Alias"
     OF 4002262:
      SET entity_name = "ProFit Receipt Alias"
    ENDCASE
   ENDIF
   IF ((request->alias_pools[apvar].action_flag=1))
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 263
    SET request_cv->cd_value_list[1].display = trim(request->alias_pools[apvar].name)
    SET request_cv->cd_value_list[1].description = trim(request->alias_pools[apvar].name)
    SET request_cv->cd_value_list[1].definition = trim(request->alias_pools[apvar].name)
    SET request_cv->cd_value_list[1].active_ind = 1
    SET new_cd_value = get_next_seq("REFERENCE_SEQ")
    INSERT  FROM code_value cv
     SET cv.active_dt_tm =
      IF ((request_cv->cd_value_list[1].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , cv.active_ind = request_cv->cd_value_list[1].active_ind, cv.active_status_prsnl_id = reqinfo
      ->updt_id,
      cv.active_type_cd =
      IF ((request_cv->cd_value_list[1].active_ind=1)) active_cd
      ELSE inactive_cd
      ENDIF
      , cv.begin_effective_dt_tm =
      IF ((request_cv->cd_value_list[1].begin_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime3)
      ELSE cnvtdatetime(request_cv->cd_value_list[1].begin_effective_dt_tm)
      ENDIF
      , cv.cdf_meaning =
      IF ((request_cv->cd_value_list[1].cdf_meaning='""')) null
      ELSE trim(cnvtupper(substring(1,12,request_cv->cd_value_list[1].cdf_meaning)),3)
      ENDIF
      ,
      cv.code_set = 263, cv.code_value = new_cd_value, cv.collation_seq =
      IF ((request_cv->cd_value_list[1].collation_seq <= 0)) 0
      ELSE request_cv->cd_value_list[1].collation_seq
      ENDIF
      ,
      cv.concept_cki =
      IF ((request_cv->cd_value_list[1].concept_cki='""')) null
      ELSE trim(request_cv->cd_value_list[1].concept_cki,3)
      ENDIF
      , cv.cki =
      IF ((request_cv->cd_value_list[1].cki > " ")) request_cv->cd_value_list[1].cki
      ENDIF
      , cv.data_status_cd = auth,
      cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cv.data_status_prsnl_id = reqinfo->
      updt_id, cv.definition =
      IF ((request_cv->cd_value_list[1].definition='""')) null
      ELSE trim(request_cv->cd_value_list[1].definition,3)
      ENDIF
      ,
      cv.description =
      IF ((request_cv->cd_value_list[1].description='""')) null
      ELSE trim(request_cv->cd_value_list[1].description,3)
      ENDIF
      , cv.display =
      IF ((request_cv->cd_value_list[1].display='""')) null
      ELSE trim(request_cv->cd_value_list[1].display,3)
      ENDIF
      , cv.display_key =
      IF (validate(request_cv->cd_value_list[1].display_key,"") > " ") trim(request_cv->
        cd_value_list[1].display_key)
      ELSE trim(cnvtupper(cnvtalphanum(request_cv->cd_value_list[1].display)))
      ENDIF
      ,
      cv.end_effective_dt_tm =
      IF ((request_cv->cd_value_list[1].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100")
      ELSE cnvtdatetime(request_cv->cd_value_list[1].end_effective_dt_tm)
      ENDIF
      , cv.inactive_dt_tm =
      IF ((request_cv->cd_value_list[1].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , cv.updt_applctx = reqinfo->updt_applctx,
      cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET errorcode = error(errmsg,0)
    IF (errorcode != 0)
     SET reply_cv->qual[1].status = 0
     SET reply_cv->qual[1].error_num = errorcode
     SET reply_cv->error_msg = errmsg
     SET reply_cv->qual[1].code_value = 0.0
     SET reply_cv->status_data.status = "F"
     GO TO exit_script
    ELSE
     SET reply_cv->qual[1].status = curqual
     SET reply_cv->qual[1].error_num = 0
     SET reply_cv->qual[1].error_msg = ""
     SET reply_cv->qual[1].code_value = new_cd_value
     SET reply_cv->status_data.status = "S"
    ENDIF
    IF ((((reply_cv->status_data.status != "S")) OR ((reply_cv->qual[1].code_value <= 0))) )
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting code_value row for alias pool name: ",trim(request->
       alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     cv.cki
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_set=request_cv->cd_value_list[1].code_set)
       AND (cv.code_value=reply_cv->qual[1].code_value)
       AND (reply_cv->qual[1].code_value > 0.0))
     DETAIL
      reply_cv->qual[1].cki = cv.cki
     WITH nocounter
    ;end select
    IF ((reply_cv->status_data.status="F"))
     SET failed = "T"
     GO TO exit_script
    ENDIF
    SET new_alias_pool_code = reply_cv->qual[1].code_value
    IF ((request->alias_pools[apvar].mnemonic > " "))
     INSERT  FROM code_value_extension cve
      SET cve.code_value = new_alias_pool_code, cve.field_name = "MNEMONIC", cve.code_set = 263,
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve
       .updt_id = reqinfo->updt_id,
       cve.field_type = 0, cve.field_value = request->alias_pools[apvar].mnemonic, cve.updt_cnt = 0,
       cve.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding alias pool mnemonic on code set ext 263:",cnvtstring(
        request->alias_pools[apvar].code_value))
      GO TO exit_script
     ENDIF
    ENDIF
    IF (data_partition_ind=1)
     INSERT  FROM alias_pool ap
      SET ap.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, ap.alias_pool_cd
        = new_alias_pool_code, ap.description = request->alias_pools[apvar].name,
       ap.unique_ind = 0, ap.format_mask = request->alias_pools[apvar].format_mask, ap
       .unsecured_char_count = request->alias_pools[apvar].unsecured_char_count,
       ap.security_char = request->alias_pools[apvar].security_char, ap.check_digit_cd = 0.0, ap
       .dup_allowed_flag = request->alias_pools[apvar].duplicate_flag,
       ap.sys_assign_flag = 0, ap.cmb_inactive_ind = 0, ap.alias_method_cd = def_alias_method_cd,
       ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), ap.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), ap.active_ind = 1,
       ap.active_status_cd = active_cd, ap.active_status_dt_tm = cnvtdatetime(curdate,curtime), ap
       .active_status_prsnl_id = reqinfo->updt_id,
       ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_applctx = reqinfo->updt_applctx, ap
       .updt_id = reqinfo->updt_id,
       ap.updt_cnt = 0, ap.updt_task = reqinfo->updt_task, ap.alias_pool_ext_cd = 0.0
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM alias_pool ap
      SET ap.alias_pool_cd = new_alias_pool_code, ap.description = request->alias_pools[apvar].name,
       ap.unique_ind = 0,
       ap.format_mask = request->alias_pools[apvar].format_mask, ap.unsecured_char_count = request->
       alias_pools[apvar].unsecured_char_count, ap.security_char = request->alias_pools[apvar].
       security_char,
       ap.check_digit_cd = 0.0, ap.dup_allowed_flag = request->alias_pools[apvar].duplicate_flag, ap
       .sys_assign_flag = 0,
       ap.cmb_inactive_ind = 0, ap.alias_method_cd = def_alias_method_cd, ap.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime),
       ap.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ap.active_ind = 1, ap
       .active_status_cd = active_cd,
       ap.active_status_dt_tm = cnvtdatetime(curdate,curtime), ap.active_status_prsnl_id = reqinfo->
       updt_id, ap.updt_dt_tm = cnvtdatetime(curdate,curtime),
       ap.updt_applctx = reqinfo->updt_applctx, ap.updt_id = reqinfo->updt_id, ap.updt_cnt = 0,
       ap.updt_task = reqinfo->updt_task, ap.alias_pool_ext_cd = 0.0
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting alias_pool row for alias pool name: ",trim(request->
       alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    SET stat = alterlist(reply->alias_pools,apvar)
    SET reply->alias_pools[apvar].code_value = new_alias_pool_code
    IF (column_exists("ALIAS_POOL","EFFECTIVE_ALIAS_ID"))
     UPDATE  FROM alias_pool ap
      SET ap.effective_alias_ind = 0
      WHERE ap.alias_pool_cd=new_alias_pool_code
      WITH nocounter
     ;end update
    ENDIF
    INSERT  FROM code_value_extension cve
     SET cve.code_value = new_alias_pool_code, cve.code_set = 263, cve.field_name = "ALIASREASSIGN",
      cve.field_type = 1, cve.field_value = "0", cve.updt_applctx = reqinfo->updt_applctx,
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve.updt_id = reqinfo->updt_id, cve.updt_cnt =
      0,
      cve.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting code_value_extension ALIASREASSIGN ",
      "row for alias pool name: ",trim(request->alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    INSERT  FROM code_value_extension cve
     SET cve.code_value = new_alias_pool_code, cve.code_set = 263, cve.field_name = "DUPREALONLY",
      cve.field_type = 1, cve.field_value = "0", cve.updt_applctx = reqinfo->updt_applctx,
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve.updt_id = reqinfo->updt_id, cve.updt_cnt =
      0,
      cve.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting code_value_extension DUPREALONLY ",
      "row for alias pool name: ",trim(request->alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    INSERT  FROM code_value_extension cve
     SET cve.code_value = new_alias_pool_code, cve.code_set = 263, cve.field_name = "DUPACTIVEONLY",
      cve.field_type = 1, cve.field_value = "0", cve.updt_applctx = reqinfo->updt_applctx,
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve.updt_id = reqinfo->updt_id, cve.updt_cnt =
      0,
      cve.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting code_value_extension DUPACTIVEONLY ",
      "row for alias pool name: ",trim(request->alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    IF (entity_type_cd=cmrn_cd
     AND cmrn_cd > 0
     AND assigncmrn_cd > 0)
     SET assigncmrn_exists = 0
     SELECT INTO "nl:"
      FROM code_value_extension cve
      PLAN (cve
       WHERE cve.code_set=20790
        AND cve.code_value=assigncmrn_cd
        AND cve.field_name="OPTION")
      DETAIL
       assigncmrn_exists = 1
      WITH nocounter
     ;end select
     IF (assigncmrn_exists=0)
      INSERT  FROM code_value_extension cve
       SET cve.code_value = assigncmrn_cd, cve.code_set = 20790, cve.field_name = "OPTION",
        cve.field_type = 1, cve.field_value = "1", cve.updt_applctx = reqinfo->updt_applctx,
        cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve.updt_id = reqinfo->updt_id, cve.updt_cnt
         = 0,
        cve.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ELSE
      UPDATE  FROM code_value_extension cve
       SET cve.field_value = "1", cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_applctx = reqinfo->
        updt_applctx,
        cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve.updt_id = reqinfo->updt_id, cve.updt_task
         = reqinfo->updt_task
       WHERE cve.code_value=assigncmrn_cd
        AND cve.code_set=20790
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    INSERT  FROM br_alias_pool_info bapi
     SET bapi.alias_pool_cd = new_alias_pool_code, bapi.fsi_id = request->alias_pools[apvar].fsi_id,
      bapi.alias_pool_type_cd = entity_type_cd,
      bapi.alpha_char_ind = 0, bapi.format_ind = 0, bapi.active_ind = 1,
      bapi.active_status_cd = active_cd, bapi.updt_id = reqinfo->updt_id, bapi.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      bapi.updt_task = reqinfo->updt_task, bapi.updt_cnt = 0, bapi.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting br_alias_pool_info row for alias pool name: ",trim(
       request->alias_pools[apvar].name),".")
     GO TO exit_script
    ENDIF
    SET orgcnt = size(request->alias_pools[apvar].orgs,5)
    IF (orgcnt > 0)
     SET orgvar = 1
     WHILE (orgvar <= orgcnt)
      IF ((request->alias_pools[apvar].orgs[orgvar].action_flag=1))
       INSERT  FROM org_alias_pool_reltn oapr
        SET oapr.organization_id = request->alias_pools[apvar].orgs[orgvar].id, oapr
         .alias_entity_name = entity_name, oapr.alias_entity_alias_type_cd = entity_type_cd,
         oapr.alias_pool_cd = new_alias_pool_code, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm
          = cnvtdatetime(curdate,curtime),
         oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
         updt_applctx,
         oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(
          curdate,curtime), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
         oapr.auto_assign_flag = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error inserting org_alias_pool_reltn row for alias pool: ",trim(
          request->alias_pools[apvar].name),", organization id: ",cnvtstring(request->alias_pools[
          apvar].orgs[orgvar].id),".")
        GO TO exit_script
       ENDIF
      ENDIF
      SET orgvar = (orgvar+ 1)
     ENDWHILE
    ENDIF
   ELSEIF ((request->alias_pools[apvar].action_flag=2))
    SET tname = request->alias_pools[apvar].name
    SET tmnem = request->alias_pools[apvar].mnemonic
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->alias_pools[apvar].code_value))
     DETAIL
      tname = trim(cv.display)
     WITH nocounter
    ;end select
    IF ( NOT (tname=trim(request->alias_pools[apvar].name)))
     UPDATE  FROM code_value cv
      SET cv.display = trim(substring(1,40,request->alias_pools[apvar].name)), cv.description = trim(
        substring(1,60,request->alias_pools[apvar].name)), cv.definition = trim(substring(1,100,
         request->alias_pools[apvar].name)),
       cv.display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->alias_pools[apvar].name))
         )), cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task,
       cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm =
       cnvtdatetime(curdate,curtime)
      WHERE (cv.code_value=request->alias_pools[apvar].code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error updating alias pool name on code set 263:",cnvtstring(request->
        alias_pools[apvar].code_value))
      GO TO exit_script
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM code_value_extension cve
     PLAN (cve
      WHERE (cve.code_value=request->alias_pools[apvar].code_value)
       AND cve.field_name="MNEMONIC")
     DETAIL
      tmnem = trim(cve.field_value)
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM code_value_extension cve
      SET cve.code_value = request->alias_pools[apvar].code_value, cve.field_name = "MNEMONIC", cve
       .code_set = 263,
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(curdate,curtime), cve
       .updt_id = reqinfo->updt_id,
       cve.field_type = 0, cve.field_value = request->alias_pools[apvar].mnemonic, cve.updt_cnt = 0,
       cve.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error adding alias pool mnemonic on code set ext 263:",cnvtstring(
        request->alias_pools[apvar].code_value))
      GO TO exit_script
     ENDIF
    ELSEIF ( NOT (tmnem=trim(request->alias_pools[apvar].mnemonic)))
     UPDATE  FROM code_value_extension cve
      SET cve.field_value = request->alias_pools[apvar].mnemonic, cve.updt_id = reqinfo->updt_id, cve
       .updt_cnt = (cve.updt_cnt+ 1),
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_task = reqinfo->updt_task, cve.updt_dt_tm
        = cnvtdatetime(curdate,curtime)
      WHERE (cve.code_value=request->alias_pools[apvar].code_value)
       AND cve.field_name="MNEMONIC"
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Error updating alias pool mnemonic on cve for pool code: ",cnvtstring(
        request->alias_pools[apvar].code_value))
      GO TO exit_script
     ENDIF
    ENDIF
    UPDATE  FROM alias_pool ap
     SET ap.description = request->alias_pools[apvar].name, ap.dup_allowed_flag = request->
      alias_pools[apvar].duplicate_flag, ap.sys_assign_flag = request->alias_pools[apvar].
      sys_assign_flag,
      ap.format_mask = request->alias_pools[apvar].format_mask, ap.unsecured_char_count = request->
      alias_pools[apvar].unsecured_char_count, ap.security_char = request->alias_pools[apvar].
      security_char,
      ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_applctx = reqinfo->updt_applctx, ap
      .updt_id = reqinfo->updt_id,
      ap.updt_cnt = (ap.updt_cnt+ 1), ap.updt_task = reqinfo->updt_task
     WHERE (ap.alias_pool_cd=request->alias_pools[apvar].code_value)
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating alias pool: ",cnvtstring(request->alias_pools[apvar].
       code_value))
     GO TO exit_script
    ENDIF
    UPDATE  FROM br_alias_pool_info bapi
     SET bapi.fsi_id = request->alias_pools[apvar].fsi_id, bapi.alias_pool_type_cd = request->
      alias_pools[apvar].type_code_value, bapi.updt_id = reqinfo->updt_id,
      bapi.updt_dt_tm = cnvtdatetime(curdate,curtime), bapi.updt_task = reqinfo->updt_task, bapi
      .updt_cnt = (bapi.updt_cnt+ 1),
      bapi.updt_applctx = reqinfo->updt_applctx
     WHERE (bapi.alias_pool_cd=request->alias_pools[apvar].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM br_alias_pool_info bapi
      SET bapi.alias_pool_cd = request->alias_pools[apvar].code_value, bapi.fsi_id = request->
       alias_pools[apvar].fsi_id, bapi.alias_pool_type_cd = request->alias_pools[apvar].
       type_code_value,
       bapi.alpha_char_ind = 0, bapi.format_ind = 0, bapi.active_ind = 1,
       bapi.active_status_cd = active_cd, bapi.updt_id = reqinfo->updt_id, bapi.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       bapi.updt_task = reqinfo->updt_task, bapi.updt_cnt = 0, bapi.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET orgcnt = size(request->alias_pools[apvar].orgs,5)
    SET ii = 1
    FOR (ii = 1 TO orgcnt)
      IF ((request->alias_pools[apvar].orgs[ii].action_flag=1))
       IF ((request->alias_pools[apvar].type_code_value > 0.0))
        INSERT  FROM org_alias_pool_reltn oapr
         SET oapr.organization_id = request->alias_pools[apvar].orgs[ii].id, oapr.alias_entity_name
           = entity_name, oapr.alias_entity_alias_type_cd = entity_type_cd,
          oapr.alias_pool_cd = request->alias_pools[apvar].code_value, oapr.updt_id = reqinfo->
          updt_id, oapr.updt_dt_tm = cnvtdatetime(curdate,curtime),
          oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
          updt_applctx,
          oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm =
          cnvtdatetime(curdate,curtime),
          oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
          oapr.auto_assign_flag = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Error inserting org_alias_pool_reltn row for alias pool: ",trim(
           request->alias_pools[apvar].name),", organization id: ",cnvtstring(request->alias_pools[
           apvar].orgs[ii].id),".")
         GO TO exit_script
        ENDIF
       ELSE
        SET error_flag = "Y"
        SET error_msg = concat("No alias type code present in request for alias pool: ",trim(
          cnvtstring(request->alias_pools[apvar].type_code_value)))
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->alias_pools[apvar].action_flag=0))
    SET orgcnt = size(request->alias_pools[apvar].orgs,5)
    SET ii = 1
    FOR (ii = 1 TO orgcnt)
      IF ((request->alias_pools[apvar].orgs[ii].action_flag=1))
       IF ((request->alias_pools[apvar].type_code_value > 0.0))
        SET found = 0
        SET active = 99
        SELECT INTO "NL:"
         FROM org_alias_pool_reltn oapr
         PLAN (oapr
          WHERE (oapr.organization_id=request->alias_pools[apvar].orgs[ii].id)
           AND (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
           AND oapr.alias_entity_alias_type_cd=entity_type_cd)
         DETAIL
          found = 1, active = oapr.active_ind
         WITH nocounter
        ;end select
        IF (found > 0
         AND active=0)
         UPDATE  FROM org_alias_pool_reltn oapr
          SET oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm = cnvtdatetime(curdate,curtime), oapr
           .updt_task = reqinfo->updt_task,
           oapr.updt_cnt = (oapr.updt_cnt+ 1), oapr.updt_applctx = reqinfo->updt_applctx, oapr
           .active_ind = 1,
           oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime
            ), oapr.active_status_prsnl_id = reqinfo->updt_id,
           oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
          WHERE (oapr.organization_id=request->alias_pools[apvar].orgs[ii].id)
           AND (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
           AND oapr.alias_entity_alias_type_cd=entity_type_cd
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Error reactivating org_alias_pool_reltn row for alias pool: ",trim(
            request->alias_pools[apvar].name),", organization id: ",cnvtstring(request->alias_pools[
            apvar].orgs[ii].id,"."))
          GO TO exit_script
         ENDIF
        ELSEIF (found=0)
         INSERT  FROM org_alias_pool_reltn oapr
          SET oapr.organization_id = request->alias_pools[apvar].orgs[ii].id, oapr.alias_entity_name
            = entity_name, oapr.alias_entity_alias_type_cd = entity_type_cd,
           oapr.alias_pool_cd = request->alias_pools[apvar].code_value, oapr.updt_id = reqinfo->
           updt_id, oapr.updt_dt_tm = cnvtdatetime(curdate,curtime),
           oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
           updt_applctx,
           oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm =
           cnvtdatetime(curdate,curtime),
           oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(
            curdate,curtime), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
           oapr.auto_assign_flag = 0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Error inserting org_alias_pool_reltn row for alias pool: ",trim(
            request->alias_pools[apvar].name),", organization id: ",cnvtstring(request->alias_pools[
            apvar].orgs[ii].id,"."))
          GO TO exit_script
         ENDIF
        ENDIF
       ELSE
        SET error_flag = "Y"
        SET error_msg = concat("No alias type code present in request for alias pool: ",trim(
          cnvtstring(request->alias_pools[apvar].type_code_value)))
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET apvar = (apvar+ 1)
 ENDWHILE
 GO TO exit_script
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=stable
     AND l.attr_name=scolumn
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     ce_flag = 1
    WITH nocounter
   ;end select
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE get_next_seq(seq_name)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = cnvtreal(number)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET reply->error_msg = "Unable to generate a sequence number."
    GO TO exit_script
   ENDIF
   RETURN(next_seq)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat("  >>PROGRAM NAME: BED_ENS_ALIAS_POOLS","  >>ERROR MSG: ",error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
