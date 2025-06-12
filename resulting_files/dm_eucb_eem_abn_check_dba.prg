CREATE PROGRAM dm_eucb_eem_abn_check:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH private, noconstant("")
 ENDIF
 SET last_mod = "435254"
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "EEM_ABN_CHECK"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_EEM_ABN_CHECK"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 99
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE cust_ucb_dummy = i2 WITH public, noconstant(0)
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
  CALL cust_ucb_eff(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 DECLARE cloudabnpref = i2 WITH protect, noconstant(0)
 DECLARE prefflag = i2 WITH protect, noconstant(0)
 DECLARE preffound = i2 WITH protect, noconstant(0)
 DECLARE m_logical_domain_id = f8 WITH protect, noconstant(- (1.0))
 DECLARE prefflagdouble = f8 WITH protect, noconstant(0.0)
 DECLARE s_pref_type_cd = f8 WITH noconstant(0.0)
 DECLARE getlogicaldomainpref(dummy) = i4
 DECLARE s_logicaldomain_pref_cd = f8 WITH protect, noconstant(0.0)
 DECLARE s_logicaldomain_pref_value = f8 WITH protect, noconstant(- (1.0))
 DECLARE s_logicaldomain_pref = i4 WITH protect, noconstant(0)
 DECLARE s_logical_domain_id = f8 WITH protect, noconstant(0.0)
 SUBROUTINE getlogicaldomainpref(dummy)
   IF (s_logicaldomain_pref_cd <= 0.0)
    SET s_logicaldomain_pref_cd = loadcodevalue(23010,"LOGICALDMN",0)
   ENDIF
   IF (s_logicaldomain_pref_value < 0)
    SET s_logicaldomain_pref_value = 0
    SELECT INTO "nl:"
     a.pref_id
     FROM sch_pref a
     PLAN (a
      WHERE a.pref_type_cd=s_logicaldomain_pref_cd
       AND a.parent_table="SYSTEM"
       AND a.parent_id=0
       AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     DETAIL
      s_logicaldomain_pref_value = a.pref_value
     WITH nocounter
    ;end select
   ENDIF
   IF (s_logicaldomain_pref_value > 0)
    SET s_logicaldomain_pref = 1
   ENDIF
   RETURN(s_logicaldomain_pref)
 END ;Subroutine
 SUBROUTINE getlogicaldomainid(dummy)
   SET s_logical_domain_id = 0
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
   EXECUTE acm_get_curr_logical_domain
   IF ((acm_get_curr_logical_domain_rep->status_block.status_ind=true))
    SET s_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
   ELSE
    GO TO exit_script
   ENDIF
   RETURN(s_logical_domain_id)
 END ;Subroutine
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 SUBROUTINE (getprefbylogicaldomain(s_pref_type_meaning=vc) =i2)
   SET s_pref_type_cd = uar_get_code_by("MEANING",23010,s_pref_type_meaning)
   SET preffound = 0
   SET prefflag = 0
   SET m_logical_domain_id = getlogicaldomainid(0)
   SELECT INTO "nl:"
    a.updt_cnt
    FROM sch_pref a
    PLAN (a
     WHERE a.pref_type_cd=s_pref_type_cd
      AND ((a.parent_table="LOGICAL_DOMAIN"
      AND a.parent_id=m_logical_domain_id) OR (a.parent_table="SYSTEM"))
      AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     IF (preffound=0)
      prefflagdouble = a.pref_value, prefflag = cnvtint(prefflagdouble)
     ENDIF
     IF (a.parent_table="LOGICAL_DOMAIN")
      preffound = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(prefflag)
 END ;Subroutine
 SUBROUTINE (getdoubleprefbylogicaldomain(spreftypemeaning=vc) =f8)
   DECLARE dprefvaluecd = f8 WITH protect, noconstant(0.0)
   DECLARE dlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SET spreftypemeaning = trim(spreftypemeaning,3)
   IF (textlen(spreftypemeaning)=0)
    RETURN(0.0)
   ENDIF
   SET dlogicaldomainid = getlogicaldomainid(0)
   SELECT INTO "nl:"
    a.pref_value
    FROM sch_pref a
    WHERE a.parent_id=dlogicaldomainid
     AND a.parent_table="LOGICAL_DOMAIN"
     AND a.pref_type_meaning=spreftypemeaning
     AND a.data_type_meaning="DOUBLE"
     AND a.active_ind=1
     AND a.pref_value > 0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    DETAIL
     dprefvaluecd = a.pref_value
    WITH nocounter
   ;end select
   IF (dprefvaluecd <= 0.0)
    SELECT INTO "nl:"
     a.pref_value
     FROM sch_pref a
     WHERE a.parent_id=0.0
      AND a.parent_table="SYSTEM"
      AND a.pref_type_meaning=spreftypemeaning
      AND a.data_type_meaning="DOUBLE"
      AND a.active_ind=1
      AND a.pref_value > 0
      AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      dprefvaluecd = a.pref_value
     WITH nocounter
    ;end select
   ENDIF
   RETURN(dprefvaluecd)
 END ;Subroutine
 SUBROUTINE (getstringprefbylogicaldomain(spreftypemeaning=vc) =vc)
   DECLARE sprefstring = vc WITH protect, noconstant("")
   DECLARE dlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SET spreftypemeaning = trim(spreftypemeaning,3)
   IF (textlen(spreftypemeaning)=0)
    RETURN("")
   ENDIF
   SET dlogicaldomainid = getlogicaldomainid(0)
   SELECT INTO "nl:"
    a.pref_string
    FROM sch_pref a
    WHERE a.parent_id=dlogicaldomainid
     AND a.parent_table="LOGICAL_DOMAIN"
     AND a.pref_type_meaning=spreftypemeaning
     AND a.data_type_meaning="STRING"
     AND a.active_ind=1
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    DETAIL
     sprefstring = a.pref_string
    WITH nocounter
   ;end select
   IF (size(trim(sprefstring))=0)
    SELECT INTO "nl:"
     a.pref_string
     FROM sch_pref a
     WHERE a.parent_id=0.0
      AND a.parent_table="SYSTEM"
      AND a.pref_type_meaning=spreftypemeaning
      AND a.data_type_meaning="STRING"
      AND a.active_ind=1
      AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      sprefstring = a.pref_string
     WITH nocounter
    ;end select
   ENDIF
   RETURN(sprefstring)
 END ;Subroutine
 SET cloudabnpref = getprefbylogicaldomain("CLOUDABN")
 IF (cloudabnpref > 0)
  IF ( NOT (validate(updt_encounter_abn_status_request,0)))
   RECORD updt_encounter_abn_status_req(
     1 call_echo_ind = i2
     1 encntr_id = f8
   )
  ENDIF
  IF ( NOT (validate(updt_encounter_abn_status_reply,0)))
   RECORD updt_encounter_abn_status_rep(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET updt_encounter_abn_status_req->encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
  EXECUTE eem_updt_encounter_abn_status  WITH replace("REQUEST","UPDT_ENCOUNTER_ABN_STATUS_REQ"),
  replace("REPLY","UPDT_ENCOUNTER_ABN_STATUS_REP")
  SET updt_encounter_abn_status_req->encntr_id = request->xxx_uncombine[ucb_cnt].from_xxx_id
  EXECUTE eem_updt_encounter_abn_status  WITH replace("REQUEST","UPDT_ENCOUNTER_ABN_STATUS_REQ"),
  replace("REPLY","UPDT_ENCOUNTER_ABN_STATUS_REP")
 ENDIF
 SUBROUTINE cust_ucb_add(dummy)
   SET cust_add_buff = fillstring(500," ")
   SET cust_add_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set active_ind = FALSE, ","active_status_cd = reqdata->inactive_status_cd, ",
    "active_status_prsnl_id = reqinfo->updt_id, ",
    "updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ","updt_cnt = updt_cnt + 1, ",
    "updt_task = reqinfo->updt_task ",
    "where ",trim(rchildren->qual1[det_cnt].primary_key_attr),
    " = rChildren->QUAL1[det_cnt]->ENTITY_ID "," with nocounter go ")
   CALL parser(cust_add_buff)
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del(dummy)
   SET cust_del_buff = fillstring(1000," ")
   SET cust_del_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",trim(rchildren->qual1[det_cnt].
     attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID, ",
    "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, ",
    "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD, ",
    "active_status_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "active_status_prsnl_id = reqinfo->updt_id ","where ",trim(rchildren->qual1[det_cnt].
     primary_key_attr),
    " = rChildren->QUAL1[det_cnt]->ENTITY_ID ","with nocounter go ")
   CALL parser(cust_del_buff)
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   SET cust_upt_buff = fillstring(500," ")
   SET cust_upt_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",trim(rchildren->qual1[det_cnt].
     attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID ","where ",
    trim(rchildren->qual1[det_cnt].attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID ",
    " and ",trim(rchildren->qual1[det_cnt].primary_key_attr),
    " = rChildren->QUAL1[det_cnt]->ENTITY_ID ",
    "with nocounter go ")
   CALL parser(cust_upt_buff)
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_eff(dummy)
   SET cust_eff_buff = fillstring(500," ")
   SET cust_eff_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",trim(rchildren->qual1[det_cnt].
     attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID, ","end_effective_dt_tm ",
    " = cnvtdatetime(rChildren->QUAL1[det_cnt]->PREV_END_EFF_DT_TM) "," where ",trim(rchildren->
     qual1[det_cnt].attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID "," and ",
    trim(rchildren->qual1[det_cnt].primary_key_attr)," = rChildren->QUAL1[det_cnt]->ENTITY_ID ",
    " with nocounter go ")
   CALL parser(cust_eff_buff)
   IF (curqual=0)
    SET ucb_failed = eff_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
#exit_script
END GO
