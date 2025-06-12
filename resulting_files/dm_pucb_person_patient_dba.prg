CREATE PROGRAM dm_pucb_person_patient:dba
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
 DECLARE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to) = i2
 DECLARE cmb_read_col_value(rv_col_name) = i2
 DECLARE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,
  svf_to) = i2
 DECLARE cmb_read_column_value(rvf_tbl_name,rvf_pk_value,rvf_rv_col_name) = i2
 RECORD cmb_det_value(
   1 table_name = vc
   1 column_name = vc
   1 column_type = vc
   1 from_value = vc
   1 to_value = vc
 )
 SUBROUTINE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to)
  SET sv_return = cmb_save_column_value(rcmblist->custom[maincount3].table_name,sv_pk_value,
   sv_col_name,"",sv_from,
   sv_to)
  RETURN(sv_return)
 END ;Subroutine
 SUBROUTINE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,svf_to
  )
   IF (((svf_tbl_name="") OR (svf_tbl_name=" ")) )
    SET svf_tbl_name = rcmblist->custom[maincount3].table_name
   ENDIF
   INSERT  FROM combine_det_value
    SET combine_det_value_id = seq(combine_seq,nextval), combine_id = request->xxx_combine[icombine].
     xxx_combine_id, combine_parent = evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
      "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
      "COMBINE"),
     parent_entity = request->parent_table, entity_name = cnvtupper(svf_tbl_name), entity_id =
     svf_pk_value,
     column_name = cnvtupper(svf_col_name), column_type = evaluate(svf_col_type,"",null,svf_col_type),
     from_value = svf_from,
     to_value = evaluate(svf_to,"",null,svf_to), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(
      sysdate)
    WITH nocounter
   ;end insert
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE cmb_read_col_value(rv_col_name)
  SET rv_return = cmb_read_column_value(rchildren->qual1[det_cnt].entity_name,rchildren->qual1[
   det_cnt].entity_id,rv_col_name)
  RETURN(rv_return)
 END ;Subroutine
 SUBROUTINE cmb_read_column_value(rv_tbl_name,rv_pk_value,rv_col_name)
   SET cmb_det_value->table_name = ""
   SET cmb_det_value->column_name = ""
   SET cmb_det_value->from_value = ""
   SET cmb_det_value->to_value = ""
   IF (((rv_tbl_name="") OR (rv_tbl_name=" ")) )
    SET rv_tbl_name = rchildren->qual1[det_cnt].entity_name
   ENDIF
   IF (rv_pk_value=0)
    SET rv_pk_value = rchildren->qual1[det_cnt].entity_id
   ENDIF
   SELECT INTO "nl:"
    v.column_name, v.from_value, v.to_value
    FROM combine_det_value v
    WHERE (v.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND v.combine_parent=evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
     "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
     "COMBINE")
     AND (v.parent_entity=request->parent_table)
     AND v.entity_name=cnvtupper(rv_tbl_name)
     AND v.entity_id=rv_pk_value
     AND v.column_name=cnvtupper(rv_col_name)
    DETAIL
     cmb_det_value->table_name = v.entity_name, cmb_det_value->column_name = v.column_name,
     cmb_det_value->column_type = v.column_type,
     cmb_det_value->from_value = v.from_value, cmb_det_value->to_value = v.to_value
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 CALL echo("*****pm_default_birth_sex.inc - 626109*****")
 DECLARE getlogicaldomainid(null) = f8
 SUBROUTINE (getprefbylogicaldomain(spreftypemeaning=vc) =i2)
   DECLARE bpreffound = i2 WITH protect, noconstant(false)
   DECLARE bprefflag = i2 WITH protect, noconstant(false)
   DECLARE dlogicaldomainid = f8 WITH protect, noconstant(- (1.0))
   SET dlogicaldomainid = getlogicaldomainid(0)
   IF (dlogicaldomainid < 0.0)
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM sch_pref sp
    PLAN (sp
     WHERE sp.pref_type_meaning=spreftypemeaning
      AND ((sp.parent_table="LOGICAL_DOMAIN"
      AND sp.parent_id=dlogicaldomainid) OR (sp.parent_table="SYSTEM"))
      AND sp.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     IF (bpreffound=false)
      bprefflag = cnvtint(sp.pref_value)
      IF (sp.parent_table="LOGICAL_DOMAIN")
       bpreffound = true
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   RETURN(bprefflag)
 END ;Subroutine
 SUBROUTINE getlogicaldomainid(null)
   DECLARE dlogicaldomainid = f8 WITH protect, noconstant(- (1.0))
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
    SET dlogicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
   ENDIF
   RETURN(dlogicaldomainid)
 END ;Subroutine
 DECLARE s_ld_level_info_name = vc WITH constant("DEFAULT_BIRTH_SEX_LOGICAL_DOMAIN"), protect
 DECLARE s_domain_level_info_name = vc WITH constant("DEFAULT_BIRTH_SEX"), protect
 DECLARE s_info_domain = vc WITH constant("PERSON_MANAGEMENT"), protect
 DECLARE d_logical_domain_id = f8 WITH constant(getlogicaldomainid(null)), protect
 DECLARE i_defaulting_birth_sex_on = f8 WITH constant(1.0), protect
 DECLARE getdefaultbirthsexconfig(null) = i2
 SUBROUTINE getdefaultbirthsexconfig(null)
   DECLARE bdefaultbirthsex = i2 WITH noconstant(false), protect
   DECLARE blogicaldomainrowfound = i2 WITH noconstant(false), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=s_info_domain
     AND ((di.info_name=s_domain_level_info_name) OR (di.info_name=s_ld_level_info_name
     AND di.info_domain_id=d_logical_domain_id))
    DETAIL
     IF (di.info_name=s_ld_level_info_name
      AND di.info_domain_id=d_logical_domain_id)
      bdefaultbirthsex = false, blogicaldomainrowfound = true
      IF (di.info_number=i_defaulting_birth_sex_on)
       bdefaultbirthsex = true
      ENDIF
     ELSEIF (di.info_name=s_domain_level_info_name
      AND blogicaldomainrowfound=false)
      IF (di.info_number=i_defaulting_birth_sex_on)
       bdefaultbirthsex = true
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   RETURN(bdefaultbirthsex)
 END ;Subroutine
 IF ( NOT (validate(sch_log_message,0)))
  DECLARE s_log_handle = i4 WITH protect, noconstant(0)
  DECLARE s_log_status = i4 WITH protect, noconstant(0)
  DECLARE s_message = vc WITH protect, noconstant("")
  SUBROUTINE (sch_log_message(l_event=vc,l_script_name=vc,l_message=vc,l_loglevel=i2) =null)
    IF ((l_loglevel > - (1))
     AND textlen(trim(l_message,3)) > 0)
     SET s_message = build("script::",l_script_name,", message::",l_message)
     CALL uar_syscreatehandle(s_log_handle,s_log_status)
     IF (s_log_handle != 0)
      CALL uar_sysevent(s_log_handle,l_loglevel,nullterm(l_event),nullterm(s_message))
      CALL uar_sysdestroyhandle(s_log_handle)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 SUBROUTINE (getmappedsexcode(lchildcodeset=i4,dsexcode=f8) =f8)
   DECLARE dmappedsexcd = f8 WITH noconstant(0.0), protect
   DECLARE ssexcodemeaning = vc WITH noconstant(trim(uar_get_code_meaning(dsexcode),7)), private
   IF (dsexcode > 0.0
    AND lchildcodeset > 0)
    IF (((ssexcodemeaning="FEMALE") OR (ssexcodemeaning="MALE")) )
     SET dmappedsexcd = uar_get_code_by("MEANING",lchildcodeset,ssexcodemeaning)
    ELSE
     SELECT INTO "nl:"
      FROM code_value_group cvg
      WHERE cvg.parent_code_value=dsexcode
       AND cvg.code_set=lchildcodeset
       AND cvg.child_code_value > 0.0
      DETAIL
       dmappedsexcd = cvg.child_code_value
      FOOT REPORT
       IF (count(cvg.child_code_value) > 1)
        CALL sch_log_message("PM_CVG_ERROR","PM_SEX_MAPPING.INC",concat(
         "Multiple values are mapped for codeset ",cnvtstring(lchildcodeset)," & Code value ",
         cnvtstring(dsexcode)),0), dmappedsexcd = 0.0
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(dmappedsexcd)
 END ;Subroutine
 SUBROUTINE (mapadminsextobirthsexdefault(dadminsexcd=f8) =f8)
   RETURN(getmappedsexcode(56,dadminsexcd))
 END ;Subroutine
 SUBROUTINE (mapbirthsextoadminsexdefault(dbirthsexcd=f8) =f8)
   RETURN(getmappedsexcode(57,dbirthsexcd))
 END ;Subroutine
 SUBROUTINE (setdefaultbirthsexcode(dpersonid=f8,dbirthsexcd=f8(ref)) =i2)
   DECLARE dadminsexcd = f8 WITH noconstant(0.0), protect
   DECLARE d_person_type_real = f8 WITH constant(uar_get_code_by("MEANING",302,"PERSON")), protect
   IF (dpersonid > 0
    AND dbirthsexcd <= 0
    AND getdefaultbirthsexconfig(null))
    SELECT INTO "nl:"
     FROM person p
     WHERE p.person_id=dpersonid
      AND p.person_type_cd=d_person_type_real
     DETAIL
      dadminsexcd = p.sex_cd
     WITH nocounter
    ;end select
    IF (dadminsexcd > 0.0)
     SET dbirthsexcd = mapadminsextobirthsexdefault(dadminsexcd)
    ENDIF
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (ensuredefaultbirthsexcode(dpersonid=f8,dpersontype=f8,doldadminsexcd=f8,dnewadminsexcd=
  f8,dpmhisttrackingid=f8(ref),dttrans=dq8,dcontributorsystemcd=f8) =i2)
   DECLARE dbirthsexcd = f8 WITH noconstant(0.0), protect
   DECLARE d_person_type_real = f8 WITH constant(uar_get_code_by("MEANING",302,"PERSON")), protect
   DECLARE ltempbirthsexactionbeginvalue = i4 WITH noconstant(0), protect
   DECLARE ltempbirthsexactionendvalue = i4 WITH noconstant(0), protect
   DECLARE bbirthsexactionbeginexists = i2 WITH noconstant(false), protect
   DECLARE bbirthsexactionendexists = i2 WITH noconstant(false), protect
   IF ( NOT (validate(errmsg)))
    DECLARE errmsg = vc WITH protect, noconstant(" ")
   ENDIF
   IF ( NOT (validate(error_cd)))
    DECLARE error_cd = i4 WITH protect, noconstant(0)
   ENDIF
   IF (dpersonid > 0.0)
    IF (dpersontype=d_person_type_real
     AND dnewadminsexcd > 0.0
     AND doldadminsexcd != dnewadminsexcd
     AND getdefaultbirthsexconfig(null))
     SELECT INTO "nl:"
      FROM person_patient pp
      WHERE pp.person_id=dpersonid
      DETAIL
       dbirthsexcd = pp.birth_sex_cd
      WITH nocounter
     ;end select
     IF (dbirthsexcd <= 0.0
      AND curqual > 0)
      SET dbirthsexcd = mapadminsextobirthsexdefault(dnewadminsexcd)
      IF (dbirthsexcd > 0.0)
       FREE RECORD person_patient_req
       RECORD person_patient_req(
         1 person_patient_qual = i4
         1 esi_ensure_type = c3
         1 mode = i2
         1 person_patient[*]
           2 action_type = c3
           2 new_person = c1
           2 person_id = f8
           2 pm_hist_tracking_id = f8
           2 transaction_dt_tm = dq8
           2 active_ind_ind = i2
           2 active_ind = i2
           2 active_status_cd = f8
           2 active_status_dt_tm = dq8
           2 active_status_prsnl_id = f8
           2 beg_effective_dt_tm = dq8
           2 end_effective_dt_tm = dq8
           2 adopted_cd = f8
           2 bad_debt_cd = f8
           2 baptised_cd = f8
           2 birth_multiple_cd = f8
           2 birth_order_ind = i2
           2 birth_order = i4
           2 birth_length_ind = i4
           2 birth_length = f8
           2 birth_length_units_cd = f8
           2 birth_name = c100
           2 birth_weight_ind = i4
           2 birth_weight = f8
           2 birth_weight_units_cd = f8
           2 church_cd = f8
           2 credit_hrs_taking_ind = i2
           2 credit_hrs_taking = i4
           2 cumm_leave_days_ind = i2
           2 cumm_leave_days = i4
           2 current_balance_ind = i4
           2 current_balance = f8
           2 current_grade_ind = i2
           2 current_grade = i4
           2 custody_cd = f8
           2 degree_complete_cd = f8
           2 diet_type_cd = f8
           2 family_income_ind = i4
           2 family_income = f8
           2 family_size_ind = i2
           2 family_size = i4
           2 highest_grade_complete_cd = f8
           2 immun_on_file_cd = f8
           2 interp_required_cd = f8
           2 interp_type_cd = f8
           2 microfilm_cd = f8
           2 nbr_of_brothers_ind = i2
           2 nbr_of_brothers = i4
           2 nbr_of_sisters_ind = i2
           2 nbr_of_sisters = i4
           2 organ_donor_cd = f8
           2 parent_marital_status_cd = f8
           2 smokes_cd = f8
           2 tumor_registry_cd = f8
           2 last_bill_dt_tm = dq8
           2 last_bind_dt_tm = dq8
           2 last_discharge_dt_tm = dq8
           2 last_event_updt_dt_tm = dq8
           2 last_payment_dt_tm = dq8
           2 last_atd_activity_dt_tm = dq8
           2 data_status_cd = f8
           2 data_status_dt_tm = dq8
           2 data_status_prsnl_id = f8
           2 contributor_system_cd = f8
           2 student_cd = f8
           2 living_dependency_cd = f8
           2 living_arrangement_cd = f8
           2 living_will_cd = f8
           2 nbr_of_pregnancies_ind = i2
           2 nbr_of_pregnancies = i4
           2 last_trauma_dt_tm = dq8
           2 mother_identifier = c100
           2 mother_identifier_cd = f8
           2 disease_alert_cd = f8
           2 disease_alert_list_ind = i2
           2 disease_alert[*]
             3 value_cd = f8
           2 process_alert_cd = f8
           2 process_alert_list_ind = i2
           2 process_alert[*]
             3 value_cd = f8
           2 updt_cnt = i4
           2 contact_list_cd = f8
           2 gest_age_at_birth = i4
           2 gest_age_method_cd = f8
           2 contact_method_cd = f8
           2 contact_time = c255
           2 callback_consent_cd = f8
           2 written_format_cd = f8
           2 birth_order_cd = f8
           2 prev_contact_ind = i2
           2 source_version_number = vc
           2 source_last_sync_dt_tm = dq8
           2 iqh_participant_cd = f8
           2 source_sync_level_flag = i2
           2 health_info_access_offered_cd = f8
           2 birth_sex_cd = f8
           2 health_app_access_offered_cd = f8
           2 financial_risk_level_cd = f8
           2 demog_verify_dt_tm = dq8
       )
       FREE RECORD person_patient_reply
       RECORD person_patient_reply(
         1 person_patient_qual = i4
         1 person_patient[*]
           2 person_id = f8
           2 pm_hist_tracking_id = f8
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
       SET person_patient_req->person_patient_qual = 1
       SET stat = alterlist(person_patient_req->person_patient,1)
       SET person_patient_req->person_patient[1].person_id = dpersonid
       SET person_patient_req->person_patient[1].pm_hist_tracking_id = dpmhisttrackingid
       SET person_patient_req->person_patient[1].transaction_dt_tm = dttrans
       SET person_patient_req->person_patient[1].contributor_system_cd = dcontributorsystemcd
       SET person_patient_req->person_patient[1].birth_sex_cd = dbirthsexcd
       IF (validate(action_begin))
        SET ltempbirthsexactionbeginvalue = action_begin
        SET action_begin = 1
        SET bbirthsexactionbeginexists = true
       ENDIF
       IF (validate(action_end))
        SET ltempbirthsexactionendvalue = action_end
        SET action_end = 1
        SET bbirthsexactionendexists = true
       ENDIF
       EXECUTE pm_upt_person_patient  WITH replace(request,person_patient_req), replace(reply,
        person_patient_reply)
       IF (bbirthsexactionbeginexists=true)
        SET action_begin = ltempbirthsexactionbeginvalue
       ENDIF
       IF (bbirthsexactionendexists=true)
        SET action_end = ltempbirthsexactionendvalue
       ENDIF
       IF ((person_patient_reply->status_data.status="S"))
        SET dpmhisttrackingid = person_patient_reply->person_patient[1].pm_hist_tracking_id
       ELSE
        CALL sch_log_message("PM_UPT_ERROR","PM_DEFAULT_BIRTH_SEX.INC",concat(
          "Call to pm_upt_person_patient failed with person details:"," person_id = ",cnvtstring(
           dpersonid)," previous sex_cd = ",cnvtstring(doldadminsexcd),
          " new sex_cd = ",cnvtstring(dnewadminsexcd)," birth_sex_cd = ",cnvtstring(dbirthsexcd)),0)
        CALL sch_log_message("PM_UPT_ERROR_CONT","PM_DEFAULT_BIRTH_SEX.INC",concat(
          "Call to pm_upt_person_patient failed with transaction details:"," pm_hist_tracking_id = ",
          cnvtstring(dpmhisttrackingid)," transaction_dt_tm = ",cnvtstring(dttrans),
          " contributor_system_cd = ",cnvtstring(dcontributorsystemcd)),0)
        RETURN(false)
       ENDIF
      ENDIF
     ENDIF
     SET error_cd = error(errmsg,0)
     IF (error_cd > 0)
      CALL sch_log_message("PM_ERROR","PM_DEFAULT_BIRTH_SEX.INC",errmsg,0)
      RETURN(false)
     ENDIF
    ENDIF
   ELSE
    CALL sch_log_message("INVALID_CALL","PM_DEFAULT_BIRTH_SEX.INC",concat(
      "Invalid call made to PM_DEFAULT_BIRTH_SEX.INC with person_id: ",cnvtstring(dpersonid)),0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE dppp_cdv_cnt = i4 WITH protect, noconstant(0)
 DECLARE dppp_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE dppp_cdv_stmt = vc WITH protect, noconstant("")
 DECLARE dppp_to_col_list = vc WITH protect, noconstant("")
 DECLARE dppp_frm_col_list = vc WITH protect, noconstant("")
 DECLARE dppp_val = vc WITH protect, noconstant("")
 DECLARE dppp_idx = i4 WITH protect, noconstant(0)
 DECLARE lfndoldfldspp = i4 WITH protect, noconstant(0)
 DECLARE lidxoldfldspp = i4 WITH protect, noconstant(0)
 FREE RECORD drpp_ucbcolumns
 RECORD drpp_ucbcolumns(
   1 pers_pat[*]
     2 column_name = vc
     2 column_type = vc
     2 to_value = vc
     2 null_ind = i2
     2 trailing_spaces_count = i4
 )
 FREE RECORD dppp_excl
 RECORD dppp_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 FREE RECORD dppp_chkcols
 RECORD dppp_chkcols(
   1 cnt = i4
   1 qual[*]
     2 col_name = vc
     2 exists_ind = i2
 )
 SET dppp_chkcols->cnt = 2
 SET stat = alterlist(dppp_chkcols->qual,dppp_chkcols->cnt)
 SET dppp_chkcols->qual[1].col_name = "BEG_EFFECTIVE_DT_TM"
 SET dppp_chkcols->qual[2].col_name = "END_EFFECTIVE_DT_TM"
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_PATIENT"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "dm_pucb_person_patient"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  cdv.column_name
  FROM combine_det_value cdv
  WHERE (cdv.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
   AND cdv.entity_name="PERSON_PATIENT"
   AND (cdv.parent_entity=request->parent_table)
  DETAIL
   lfndoldfldspp = 0, lidxoldfldspp = 0, lfndoldfldspp = locateval(lidxoldfldspp,1,dppp_chkcols->cnt,
    cdv.column_name,dppp_chkcols->qual[lidxoldfldspp].col_name)
   IF (lfndoldfldspp > 0)
    dppp_chkcols->qual[lfndoldfldspp].exists_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dppp_chkcols->cnt += 1
  SET stat = alterlist(dppp_chkcols->qual,dppp_chkcols->cnt)
  SET dppp_chkcols->qual[dppp_chkcols->cnt].col_name = "LAST_UTC_TS"
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dppp_chkcols->cnt)),
    user_tab_cols utc
   PLAN (d
    WHERE (dppp_chkcols->qual[d.seq].exists_ind=0))
    JOIN (utc
    WHERE utc.table_name="PERSON_PATIENT"
     AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR ((utc.column_name=dppp_chkcols
    ->qual[d.seq].col_name))) )) )
   HEAD REPORT
    dppp_excl->excl_cnt = 0
   DETAIL
    dppp_excl->excl_cnt += 1, stat = alterlist(dppp_excl->qual,dppp_excl->excl_cnt), dppp_excl->qual[
    dppp_excl->excl_cnt].column_name = utc.column_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dtable t,
    dtableattr a,
    dtableattrl l
   WHERE t.table_name="PERSON_PATIENT"
    AND t.table_name=a.table_name
    AND l.structtype="F"
    AND btest(l.stat,11)=0
    AND  NOT (l.attr_name IN ("PERSON_ID", "UPDT*"))
    AND  NOT (expand(dppp_idx,1,dppp_excl->excl_cnt,l.attr_name,dppp_excl->qual[dppp_idx].column_name
    ))
   ORDER BY l.attr_name
   DETAIL
    dppp_col_cnt += 1, stat = alterlist(drpp_ucbcolumns->pers_pat,dppp_col_cnt)
    IF (dppp_col_cnt > 1
     AND l.attr_name != "PERSON_ID")
     dppp_to_col_list = concat(dppp_to_col_list,",FRM.",l.attr_name), dppp_frm_col_list = concat(
      dppp_frm_col_list,",CDV.",l.attr_name)
    ELSEIF (l.attr_name != "PERSON_ID")
     dppp_to_col_list = concat("FRM.",l.attr_name), dppp_frm_col_list = concat("CDV.",l.attr_name)
    ENDIF
    drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_name = l.attr_name
    IF (l.type="F")
     drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_type = "F8"
    ELSEIF (l.type="I")
     drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_type = "I4"
    ELSEIF (l.type="C")
     IF (btest(l.stat,13))
      drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_type = "VC"
     ELSE
      drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_type = build(l.type,l.len)
     ENDIF
    ELSEIF (l.type="Q")
     drpp_ucbcolumns->pers_pat[dppp_col_cnt].column_type = "DQ8"
    ENDIF
   WITH nocounter
  ;end select
  FOR (dppp_cdv_cols = 1 TO size(drpp_ucbcolumns->pers_pat,5))
   CALL cmb_read_column_value("PERSON_PATIENT",request->xxx_uncombine[ucb_cnt].from_xxx_id,
    drpp_ucbcolumns->pers_pat[dppp_cdv_cols].column_name)
   IF (trim(drpp_ucbcolumns->pers_pat[dppp_cdv_cols].column_name,3)="BIRTH_SEX_CD")
    SET drpp_ucbcolumns->pers_pat[dppp_cdv_cols].to_value = determinebirthsexvalue(cmb_det_value->
     to_value,request->xxx_uncombine[ucb_cnt].from_xxx_id)
   ELSE
    IF (nullval(cmb_det_value->to_value,"!NL!")="!NL!")
     SET drpp_ucbcolumns->pers_pat[dppp_cdv_cols].to_value = ""
    ELSE
     SET drpp_ucbcolumns->pers_pat[dppp_cdv_cols].to_value = cmb_det_value->to_value
    ENDIF
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(drpp_ucbcolumns->pers_pat,5))),
    user_tab_columns utc
   PLAN (d)
    JOIN (utc
    WHERE utc.table_name="PERSON_PATIENT"
     AND (utc.column_name=drpp_ucbcolumns->pers_pat[d.seq].column_name))
   DETAIL
    IF (nullval(drpp_ucbcolumns->pers_pat[d.seq].to_value,"")="")
     drpp_ucbcolumns->pers_pat[d.seq].to_value = utc.data_default
    ENDIF
   WITH nocounter
  ;end select
  SET dppp_cdv_stmt = concat("UPDATE into person_patient FRM "," SET (",dppp_to_col_list,
   ",UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM, ","UPDT_ID, UPDT_TASK) (",
   "SELECT ")
  FOR (dppp_i = 1 TO size(drpp_ucbcolumns->pers_pat,5))
   IF ((drpp_ucbcolumns->pers_pat[dppp_i].to_value=""))
    SET dppp_val = "NULL"
   ELSE
    IF ((drpp_ucbcolumns->pers_pat[dppp_i].column_type="DQ8"))
     SET dppp_val = concat("cnvtdatetime('",drpp_ucbcolumns->pers_pat[dppp_i].to_value,"')")
    ELSEIF ((drpp_ucbcolumns->pers_pat[dppp_i].column_type="*C*"))
     SET dppp_val = concat("'",drpp_ucbcolumns->pers_pat[dppp_i].to_value,"'")
    ELSE
     SET dppp_val = drpp_ucbcolumns->pers_pat[dppp_i].to_value
    ENDIF
   ENDIF
   IF (dppp_i=1)
    SET dppp_cdv_stmt = concat(dppp_cdv_stmt," ",dppp_val)
   ELSE
    SET dppp_cdv_stmt = concat(dppp_cdv_stmt,",",dppp_val)
   ENDIF
  ENDFOR
  SET dppp_cdv_stmt = concat(dppp_cdv_stmt," ,reqinfo->updt_applctx, FRM.updt_cnt + 1, ",
   "cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task "," FROM dual)",
   " WHERE FRM.person_id = ",
   trim(cnvtstring(request->xxx_uncombine[ucb_cnt].from_xxx_id)),".0 WITH NOCOUNTER go")
  CALL parser(dppp_cdv_stmt,1)
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(0)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(0)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 CALL set_scn_null(0)
 SUBROUTINE (cust_ucb_add(dummy=i2) =null)
   UPDATE  FROM person_patient p
    SET p.active_ind = false, p.active_status_cd = reqdata->inactive_status_cd, p
     .active_status_prsnl_id = reqinfo->updt_id,
     p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_applctx = reqinfo->
     updt_applctx,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task
    WHERE (p.person_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE (cust_ucb_del2(dummy=i2) =null)
   UPDATE  FROM person_patient pp
    SET pp.updt_id = reqinfo->updt_id, pp.updt_dt_tm = cnvtdatetime(sysdate), pp.updt_applctx =
     reqinfo->updt_applctx,
     pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_task = reqinfo->updt_task, pp.active_ind = rchildren->
     qual1[det_cnt].prev_active_ind,
     pp.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd, pp.active_status_dt_tm =
     cnvtdatetime(sysdate), pp.active_status_prsnl_id = reqinfo->updt_id
    WHERE (pp.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = "PERSON_PATIENT"
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE set_scn_null(dummy)
  UPDATE  FROM person_patient p
   SET p.source_version_number = null
   WHERE p.person_id IN (request->xxx_uncombine[ucb_cnt].from_xxx_id, request->xxx_uncombine[ucb_cnt]
   .to_xxx_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   GO TO exit_sub
  ENDIF
 END ;Subroutine
 SUBROUTINE (determinebirthsexvalue(sbirthsexvalue=vc,dpersonid=f8) =vc)
   DECLARE dbirthsexcd = f8 WITH noconstant(0.0), protect
   IF ( NOT (nullval(sbirthsexvalue,"!NL!")="!NL!"))
    SET dbirthsexcd = cnvtreal(sbirthsexvalue)
   ENDIF
   CALL setdefaultbirthsexcode(dpersonid,dbirthsexcd)
   RETURN(trim(cnvtstring(dbirthsexcd),3))
 END ;Subroutine
#exit_sub
END GO
