CREATE PROGRAM dm_ecmb_eem_abn_check:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "EEM_ABN_CHECK"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_EEM_ABN_CHECK"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 99
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM eem_abn_check frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.abn_check_id, rreclist->from_rec[v_cust_count1].
   active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd = frm
   .active_status_cd
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM eem_abn_check tu
   WHERE (tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.abn_check_id, rreclist->to_rec[v_cust_count2].
    active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    CALL upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id)
  ENDFOR
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
   SET updt_encounter_abn_status_req->encntr_id = request->xxx_combine[icombine].to_xxx_id
   EXECUTE eem_updt_encounter_abn_status  WITH replace("REQUEST","UPDT_ENCOUNTER_ABN_STATUS_REQ"),
   replace("REPLY","UPDT_ENCOUNTER_ABN_STATUS_REP")
  ENDIF
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM eem_abn_check frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.encntr_id =
     s_uf_to_fk_id
    WHERE frm.abn_check_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "EEM_ABN_CHECK"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
#exit_script
 FREE SET rreclist
END GO
