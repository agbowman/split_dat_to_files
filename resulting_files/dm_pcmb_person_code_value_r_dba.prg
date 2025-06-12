CREATE PROGRAM dm_pcmb_person_code_value_r:dba
 CALL echo("****dm_pcmb_person_code_value_r.prg - 826602****")
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
 CALL echo("*****pm_ens_person_flex_hist.inc - 618057*****")
 CALL echo("*****pm_ens_person_flex_hist.inc - 770068*****")
 IF ((validate(error_cd,- (99))=- (99)))
  DECLARE error_cd = i4 WITH noconstant(0), privateprotect
 ENDIF
 IF (validate(errmsg,"ZZZ")="ZZZ")
  DECLARE errmsg = vc WITH noconstant(""), protect
 ENDIF
 SUBROUTINE (enspersonhistoryrow(dpersonid=f8,dpmhisttrackingid=f8(ref),dttrans=f8,
  dcontributorsystemcd=f8(ref),stransactiontypetext=vc(value,"UNKN"),stransactionreasontext=vc(value,
   "UNKNOWN")) =i2)
   DECLARE dpersonflexhistid = f8 WITH noconstant(0.0), protect
   DECLARE ddelpersonflexhistid = f8 WITH noconstant(0.0), protect
   IF (validate(m_dpmenshisttrackingrowdefinded)=false)
    DECLARE m_dpmenshisttrackingrowdefinded = i2 WITH constant(true)
    SUBROUTINE (ens_pmtrackinghistrow(person_id=f8,encntr_id=f8,contributor_system_cd=f8,
     transaction_dt_tm=f8,stransactiontypetext=vc(value,"UNKN"),stransactionreasontext=vc(value,
      "UNKNOWN")) =f8)
      FREE RECORD hist_tracking_req
      RECORD hist_tracking_req(
        1 action_flag = i2
        1 conv_task_number = i4
        1 transaction_dt_tm = dq8
        1 pm_hist_tracking_id = f8
        1 person_id = f8
        1 encntr_id = f8
        1 contributor_system_cd = f8
        1 transaction_reason_cd = f8
        1 transaction_reason_txt = c100
        1 transaction_type_txt = c4
        1 hl7_event = c10
        1 facility_org_id = f8
      )
      SET hist_tracking_req->action_flag = 3
      SET hist_tracking_req->pm_hist_tracking_id = 0.0
      SET hist_tracking_req->person_id = person_id
      SET hist_tracking_req->encntr_id = encntr_id
      SET hist_tracking_req->conv_task_number = 0
      SET hist_tracking_req->contributor_system_cd = contributor_system_cd
      SET hist_tracking_req->transaction_dt_tm = transaction_dt_tm
      SET hist_tracking_req->transaction_reason_cd = 0.0
      SET hist_tracking_req->transaction_reason_txt = stransactionreasontext
      SET hist_tracking_req->transaction_type_txt = stransactiontypetext
      IF ((validate(hist_tracking_reply->pm_hist_tracking_id,- (99))=- (99)))
       RECORD hist_tracking_reply(
         1 pm_hist_tracking_id = f8
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
      ENDIF
      EXECUTE pm_ens_hist_tracking  WITH replace("REQUEST","HIST_TRACKING_REQ"), replace("REPLY",
       "HIST_TRACKING_REPLY")
      IF ((hist_tracking_reply->status_data.status != "S"))
       RETURN(0.0)
      ELSE
       RETURN(hist_tracking_reply->pm_hist_tracking_id)
      ENDIF
    END ;Subroutine
   ENDIF
   IF ((validate(bpmgenerateidsubinclude,- (9))=- (9)))
    DECLARE bpmgenerateidsubinclude = i2 WITH noconstant(true)
    IF (validate(serrmsg,"ZZZ")="ZZZ")
     DECLARE serrmsg = vc WITH noconstant(""), protect
    ENDIF
    IF ((validate(lerror,- (99))=- (99)))
     DECLARE lerror = i4 WITH noconstant(0), protect
     SET lerror = error(serrmsg,1)
    ENDIF
    SUBROUTINE (generateidbysequencename(ssequencename=vc) =f8)
      DECLARE dnewid = f8 WITH noconstant(0.0), protect
      SET ssequencename = cnvtupper(trim(ssequencename,3))
      SELECT INTO "nl:"
       tempid = seq(parser(ssequencename),nextval)
       FROM dual
       DETAIL
        dnewid = cnvtreal(tempid)
       WITH format, nocounter
      ;end select
      SET lerror = error(serrmsg,0)
      IF (lerror > 0
       AND curqual=0)
       RETURN(0.0)
      ELSE
       RETURN(dnewid)
      ENDIF
    END ;Subroutine
   ENDIF
   IF (dttrans <= 0.0)
    SET dttrans = cnvtdatetime(sysdate)
   ENDIF
   IF (dpmhisttrackingid=0.0)
    IF (dcontributorsystemcd < 0.0)
     SET dcontributorsystemcd = 0.0
    ENDIF
    SET dpmhisttrackingid = ens_pmtrackinghistrow(dpersonid,0.0,dcontributorsystemcd,dttrans,
     stransactiontypetext,
     stransactionreasontext)
    SET error_cd = error(errmsg,0)
    IF (((error_cd > 0) OR (dpmhisttrackingid <= 0.0)) )
     RETURN(false)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM person_flex_hist pfh
     WHERE pfh.person_id=dpersonid
      AND pfh.pm_hist_tracking_id=dpmhisttrackingid
     DETAIL
      ddelpersonflexhistid = pfh.person_flex_hist_id
     WITH nocounter
    ;end select
   ENDIF
   SET dpersonflexhistid = generateidbysequencename("PERSON_SEQ")
   INSERT  FROM person_flex_hist h
    (h.person_flex_hist_id, h.pm_hist_tracking_id, h.tracking_bit,
    h.change_bit, h.transaction_dt_tm, h.abs_birth_dt_tm,
    h.active_ind, h.active_status_cd, h.active_status_dt_tm,
    h.active_status_prsnl_id, h.age_at_death, h.age_at_death_prec_mod_flag,
    h.age_at_death_unit_cd, h.archive_env_id, h.archive_status_cd,
    h.archive_status_dt_tm, h.autopsy_cd, h.beg_effective_dt_tm,
    h.birth_dt_cd, h.birth_dt_tm, h.birth_prec_flag,
    h.birth_tz, h.cause_of_death, h.cause_of_death_cd,
    h.citizenship_cd, h.conception_dt_tm, h.confid_level_cd,
    h.contributor_system_cd, h.create_dt_tm, h.create_prsnl_id,
    h.data_status_cd, h.data_status_dt_tm, h.data_status_prsnl_id,
    h.deceased_cd, h.deceased_dt_tm, h.deceased_dt_tm_prec_flag,
    h.deceased_id_method_cd, h.deceased_source_cd, h.deceased_tz,
    h.end_effective_dt_tm, h.ethnic_grp_cd, h.ft_entity_id,
    h.ft_entity_name, h.language_cd, h.language_dialect_cd,
    h.last_accessed_dt_tm, h.last_encntr_dt_tm, h.logical_domain_id,
    h.marital_type_cd, h.military_base_location, h.military_rank_cd,
    h.military_service_cd, h.mother_maiden_name, h.name_first,
    h.name_first_key, h.name_first_key_a_nls, h.name_first_key_nls,
    h.name_first_phonetic, h.name_first_synonym_id, h.name_full_formatted,
    h.name_last, h.name_last_key, h.name_last_key_a_nls,
    h.name_last_key_nls, h.name_last_phonetic, h.name_middle,
    h.name_middle_key, h.name_middle_key_a_nls, h.name_middle_key_nls,
    h.name_phonetic, h.nationality_cd, h.next_restore_dt_tm,
    h.person_id, h.person_type_cd, h.purge_option_cd,
    h.race_cd, h.religion_cd, h.sex_age_change_ind,
    h.sex_cd, h.species_cd, h.updt_applctx,
    h.updt_cnt, h.updt_dt_tm, h.updt_id,
    h.updt_task, h.vet_military_status_cd, h.vip_cd,
    h.emancipation_dt_tm, h.deceased_notify_source_cd, h.person_status_cd,
    h.resident_cd, h.personal_pronoun_cd, h.personal_pronoun_other_txt)(SELECT
     dpersonflexhistid, dpmhisttrackingid, 0,
     0, cnvtdatetime(dttrans), p.abs_birth_dt_tm,
     p.active_ind, p.active_status_cd, p.active_status_dt_tm,
     p.active_status_prsnl_id, p.age_at_death, p.age_at_death_prec_mod_flag,
     p.age_at_death_unit_cd, p.archive_env_id, p.archive_status_cd,
     p.archive_status_dt_tm, p.autopsy_cd, p.beg_effective_dt_tm,
     p.birth_dt_cd, p.birth_dt_tm, p.birth_prec_flag,
     p.birth_tz, p.cause_of_death, p.cause_of_death_cd,
     p.citizenship_cd, p.conception_dt_tm, p.confid_level_cd,
     p.contributor_system_cd, p.create_dt_tm, p.create_prsnl_id,
     p.data_status_cd, p.data_status_dt_tm, p.data_status_prsnl_id,
     p.deceased_cd, p.deceased_dt_tm, p.deceased_dt_tm_prec_flag,
     p.deceased_id_method_cd, p.deceased_source_cd, p.deceased_tz,
     p.end_effective_dt_tm, p.ethnic_grp_cd, p.ft_entity_id,
     p.ft_entity_name, p.language_cd, p.language_dialect_cd,
     p.last_accessed_dt_tm, p.last_encntr_dt_tm, p.logical_domain_id,
     p.marital_type_cd, p.military_base_location, p.military_rank_cd,
     p.military_service_cd, p.mother_maiden_name, p.name_first,
     p.name_first_key, p.name_first_key_a_nls, p.name_first_key_nls,
     p.name_first_phonetic, p.name_first_synonym_id, p.name_full_formatted,
     p.name_last, p.name_last_key, p.name_last_key_a_nls,
     p.name_last_key_nls, p.name_last_phonetic, p.name_middle,
     p.name_middle_key, p.name_middle_key_a_nls, p.name_middle_key_nls,
     p.name_phonetic, p.nationality_cd, p.next_restore_dt_tm,
     p.person_id, p.person_type_cd, p.purge_option_cd,
     p.race_cd, p.religion_cd, p.sex_age_change_ind,
     p.sex_cd, p.species_cd, p.updt_applctx,
     p.updt_cnt, p.updt_dt_tm, p.updt_id,
     p.updt_task, p.vet_military_status_cd, p.vip_cd,
     p.emancipation_dt_tm, p.deceased_notify_source_cd, p.person_status_cd,
     p.resident_cd, p.personal_pronoun_cd, p.personal_pronoun_other_txt
     FROM person p
     WHERE p.person_id=dpersonid)
    WITH nocounter
   ;end insert
   SET error_cd = error(errmsg,0)
   IF (((curqual <= 0) OR (error_cd > 0)) )
    RETURN(false)
   ENDIF
   IF (ddelpersonflexhistid > 0.0)
    DELETE  FROM person_flex_hist pfh
     WHERE pfh.person_flex_hist_id=ddelpersonflexhistid
     WITH nocounter
    ;end delete
    SET error_cd = error(errmsg,0)
    IF (((curqual <= 0) OR (error_cd > 0)) )
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 IF (validate(dm_cmb_cust_cols->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols2->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols2->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols2(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0)
  FREE RECORD dm_err
  RECORD dm_err(
    1 logfile = vc
    1 debug_flag = i2
    1 ecode = i4
    1 emsg = c132
    1 eproc = vc
    1 err_ind = i2
    1 user_action = vc
    1 asterisk_line = c80
    1 tempstr = vc
    1 errfile = vc
    1 errtext = vc
    1 unique_fname = vc
    1 disp_msg_emsg = vc
    1 disp_dcl_err_ind = i2
  )
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 CALL echo("*****dm_cmb_pm_hist_routines.inc - 565951****")
 DECLARE dm_cmb_detect_pm_hist(null) = i4
 SUBROUTINE dm_cmb_detect_pm_hist(null)
   RETURN(1)
 END ;Subroutine
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_pk_id = f8
     2 from_code_value = f8
     2 from_code_set = i4
     2 active_ind = i4
     2 active_status_cd = f8
   1 pm_hist_tracking_id = f8
   1 contributor_system_cd = f8
   1 to_rec[*]
     2 to_pk_id = f8
     2 to_code_value = f8
     2 to_code_set = i4
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE l_race_codeset = i4 WITH constant(282), protect
 DECLARE l_ethnic_codeset = i4 WITH constant(27), protect
 DECLARE l_disease_alert_codeset = i4 WITH constant(19349), private
 DECLARE l_process_alert_codeset = i4 WITH constant(19350), private
 DECLARE d_race_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",l_race_codeset,"MULTIPLE")),
 protect
 DECLARE d_ethnic_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",l_ethnic_codeset,
   "MULTIPLE")), protect
 DECLARE bethnicrowpresent = i2 WITH noconstant(false), protect
 DECLARE bracerowpresent = i2 WITH noconstant(false), protect
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 SET v_cust_count1 = 0
 SET v_cust_loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_CODE_VALUE_R"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PERSON_CODE_VALUE_R"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_prog
 ENDIF
 CALL findactivenonmultiplecvrrows(d_race_multiple_cv,d_ethnic_multiple_cv,l_race_codeset,
  l_ethnic_codeset,request->xxx_combine[icombine].to_xxx_id)
 SELECT INTO "nl:"
  FROM person_code_value_r frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND  NOT ( EXISTS (
  (SELECT
   tu.code_value
   FROM person_code_value_r tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.code_value=frm.code_value)))
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_pk_id = frm.person_code_value_r_id, rreclist->from_rec[
   v_cust_count1].from_code_value = frm.code_value, rreclist->from_rec[v_cust_count1].from_code_set
    = frm.code_set,
   rreclist->from_rec[v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].
   active_status_cd = frm.active_status_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count1)
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM person_code_value_r tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_pk_id = tu.person_code_value_r_id, rreclist->to_rec[
    v_cust_count2].to_code_value = tu.code_value, rreclist->to_rec[v_cust_count2].to_code_set = tu
    .code_set,
    rreclist->to_rec[v_cust_count2].active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].
    active_status_cd = tu.active_status_cd
   WITH forupdatewait(tu)
  ;end select
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_ethnic_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_race_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_disease_alert_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_process_alert_codeset)
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
   IF ((rev_cmb_request->reverse_ind=1))
    IF (((d_race_multiple_cv <= 0.0) OR (d_ethnic_multiple_cv <= 0.0)) )
     CALL revcombineraceethnicityrows(v_cust_loopcount,v_cust_count2)
    ENDIF
   ENDIF
   IF ( NOT (bethnicrowpresent=true
    AND d_ethnic_multiple_cv < 0.0
    AND (l_ethnic_codeset=rreclist->from_rec[v_cust_loopcount].from_code_set))
    AND  NOT (bracerowpresent=true
    AND d_race_multiple_cv < 0.0
    AND (l_race_codeset=rreclist->from_rec[v_cust_loopcount].from_code_set)))
    IF (add_to(rreclist->from_rec[v_cust_loopcount].from_pk_id,request->xxx_combine[icombine].
     to_xxx_id)=0)
     GO TO end_prog
    ENDIF
   ENDIF
  ENDFOR
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_ethnic_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_race_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_disease_alert_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_process_alert_codeset)
  CALL syncpersontbl(l_race_codeset,d_race_multiple_cv,l_ethnic_codeset,d_ethnic_multiple_cv)
 ELSE
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_ethnic_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_race_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_disease_alert_codeset)
  CALL gatherpreviouscvrvalues(request->xxx_combine[icombine].from_xxx_id,l_process_alert_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_ethnic_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_race_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_disease_alert_codeset)
  CALL inactivatepcvrrows(request->xxx_combine[icombine].from_xxx_id,l_process_alert_codeset)
  CALL syncpersontbl(l_race_codeset,d_race_multiple_cv,l_ethnic_codeset,d_ethnic_multiple_cv)
 ENDIF
 SUBROUTINE add_to(s_at_from_pcvr_id,s_at_to_person_id)
   DECLARE v_new_pcvr_id = f8
   DECLARE v_new_pcvrh_id = f8
   DECLARE at_acv_size = i4
   DECLARE at_where_size = i4
   SET v_new_pcvr_id = 0.0
   SET v_new_pcvrh_id = 0.0
   SET at_acv_size = 0
   SET at_where_size = 0
   CALL echo("add person_code_value_r")
   SELECT INTO "nl:"
    y = seq(person_seq,nextval)
    FROM dual
    DETAIL
     v_new_pcvr_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 2))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(s_at_to_person_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "PERSON_CODE_VALUE_R_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(v_new_pcvr_id)
   ELSE
    FOR (ppcv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[ppcv_loop].col_name)
       OF "PERSON_ID":
        SET dm_cmb_cust_cols->add_col_val[ppcv_loop].col_value = build(s_at_to_person_id)
       OF "PERSON_CODE_VALUE_R_ID":
        SET dm_cmb_cust_cols->add_col_val[ppcv_loop].col_value = build(v_new_pcvr_id)
      ENDCASE
    ENDFOR
   ENDIF
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "PERSON_CODE_VALUE_R"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "PERSON_CODE_VALUE_R"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "PERSON_CODE_VALUE_R_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_pcvr_id)
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_new_pcvr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_CODE_VALUE_R"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET v_at_hist_ind = dm_cmb_detect_pm_hist(null)
   IF (v_at_hist_ind=1)
    SELECT INTO "nl:"
     y = seq(person_seq,nextval)
     FROM dual
     DETAIL
      v_new_pcvrh_id = cnvtreal(y)
     WITH nocounter
    ;end select
    SET at_acv_size = size(dm_cmb_cust_cols2->add_col_val,5)
    IF (at_acv_size=0)
     SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,(at_acv_size+ 4))
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 1)].col_name = "PERSON_CODE_VALUE_R_H_ID"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 1)].col_value = build(v_new_pcvrh_id)
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 2)].col_name = "ACTIVE_IND"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 2)].col_value = "1"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 3)].col_name = "BEG_EFFECTIVE_DT_TM"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 3)].col_value =
     "cnvtdatetime(curdate,curtime3)"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 4)].col_name = "END_EFFECTIVE_DT_TM"
     SET dm_cmb_cust_cols2->add_col_val[(at_acv_size+ 4)].col_value = 'cnvtdatetime("31-DEC-2100")'
    ELSE
     FOR (ppcvr_loop = 1 TO at_acv_size)
       CASE (dm_cmb_cust_cols2->add_col_val[ppcvr_loop].col_name)
        OF "PERSON_CODE_VALUE_R_H_ID":
         SET dm_cmb_cust_cols2->add_col_val[ppcvr_loop].col_value = build(v_new_pcvrh_id)
        OF "ACTIVE_IND":
         SET dm_cmb_cust_cols2->add_col_val[ppcvr_loop].col_value = "1"
        OF "BEG_EFFECTIVE_DT_TM":
         SET dm_cmb_cust_cols2->add_col_val[ppcvr_loop].col_value = "cnvtdatetime(curdate,curtime3)"
        OF "END_EFFECTIVE_DT_TM":
         SET dm_cmb_cust_cols2->add_col_val[ppcvr_loop].col_value = 'cnvtdatetime("31-DEC-2100")'
       ENDCASE
     ENDFOR
    ENDIF
    SET at_acv_size = size(dm_cmb_cust_cols2->where_col_val,5)
    SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
    SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PERSON_CODE_VALUE_R_ID"
    SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(v_new_pcvr_id)
    IF (size(dm_cmb_cust_cols2->col,5)=0)
     SET dm_cmb_cust_cols2->tbl_name = "PERSON_CODE_VALUE_R_HIST"
     SET dm_cmb_cust_cols2->sub_select_from_tbl = "PERSON_CODE_VALUE_R"
     EXECUTE dm_cmb_get_pm_hist_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     EXECUTE dm_cmb_get_common_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF ((rreclist->pm_hist_tracking_id > 0))
      SET dcipht_request->pm_hist_tracking_id = rreclist->pm_hist_tracking_id
      SET dcipht_request->encntr_id = 0.0
      SET dcipht_request->person_id = request->xxx_combine[icombine].to_xxx_id
      SET dcipht_request->transaction_reason_txt = "DM_PCMB_PERSON_CODE_VALUE_R"
      SET dcipht_request->transaction_type_txt = "CMB"
      EXECUTE dm_cmb_ins_pm_hist_tracking
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
      SET rreclist->pm_hist_tracking_id = 0.0
     ENDIF
    ENDIF
    EXECUTE dm_cmb_ins_cust_row  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = v_new_pcvrh_id
    SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_CODE_VALUE_R_HIST"
    SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   ELSEIF (v_at_hist_ind=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (syncpersontbl(lracecodeset=i4,dracemultiplecv=f8,lethniccodeset=i4,dethnicmultiplecv=f8
  ) =null)
   DECLARE bupdatetopersonraceind = i2 WITH noconstant(false), protect
   DECLARE bupdatetopersonethnicind = i2 WITH noconstant(false), protect
   DECLARE dnewracecv = f8 WITH noconstant(0.0), protect
   DECLARE dnewethnicgrpcv = f8 WITH noconstant(0.0), protect
   DECLARE lracecount = i4 WITH noconstant(0), protect
   DECLARE lethnicgrpcount = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM person p,
     person_code_value_r pcvr
    PLAN (p
     WHERE (p.person_id=request->xxx_combine[icombine].to_xxx_id))
     JOIN (pcvr
     WHERE pcvr.person_id=p.person_id
      AND pcvr.code_set IN (lethniccodeset, lracecodeset)
      AND pcvr.active_ind=1
      AND pcvr.beg_effective_dt_tm <= cnvtdatetime(sysdate))
    ORDER BY pcvr.code_set
    DETAIL
     IF (dethnicmultiplecv > 0.0
      AND pcvr.code_set=lethniccodeset)
      lethnicgrpcount += 1,
      CALL echo(build("lEthnicGrpCount =",lethnicgrpcount))
      IF (lethnicgrpcount=1)
       IF (p.ethnic_grp_cd != pcvr.code_value)
        dnewethnicgrpcv = pcvr.code_value, bupdatetopersonethnicind = true
       ENDIF
      ELSE
       IF (p.ethnic_grp_cd != dethnicmultiplecv)
        dnewethnicgrpcv = dethnicmultiplecv, bupdatetopersonethnicind = true
       ELSE
        bupdatetopersonethnicind = false, dnewethnicgrpcv = 0.0
       ENDIF
      ENDIF
     ELSEIF (dethnicmultiplecv <= 0.0
      AND pcvr.code_set=lethniccodeset
      AND p.ethnic_grp_cd <= 0.0)
      dnewethnicgrpcv = pcvr.code_value, bupdatetopersonethnicind = true
     ENDIF
     IF (dracemultiplecv > 0.0
      AND pcvr.code_set=lracecodeset)
      lracecount += 1,
      CALL echo(build("lRaceCount =",lracecount))
      IF (lracecount=1)
       IF (p.race_cd != pcvr.code_value)
        dnewracecv = pcvr.code_value, bupdatetopersonraceind = true
       ENDIF
      ELSE
       IF (p.race_cd != dracemultiplecv)
        dnewracecv = dracemultiplecv, bupdatetopersonraceind = true
       ELSE
        bupdatetopersonraceind = false, dnewracecv = 0.0
       ENDIF
      ENDIF
     ELSEIF (dracemultiplecv <= 0.0
      AND pcvr.code_set=lracecodeset
      AND p.race_cd <= 0.0)
      dnewracecv = pcvr.code_value, bupdatetopersonraceind = true
     ENDIF
    WITH nocounter
   ;end select
   IF (((bupdatetopersonraceind=true) OR (bupdatetopersonethnicind=true)) )
    CALL echo(build("bUpdateToPersonRaceInd = TRUE"))
    CALL echo(build("bUpdateToPersonEthnicInd = TRUE"))
    UPDATE  FROM person p
     SET p.ethnic_grp_cd = evaluate2(
       IF (bupdatetopersonethnicind=true) dnewethnicgrpcv
       ELSE p.ethnic_grp_cd
       ENDIF
       ), p.race_cd = evaluate2(
       IF (bupdatetopersonraceind=true) dnewracecv
       ELSE p.race_cd
       ENDIF
       ), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
      updt_task,
      p.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (p.person_id=request->xxx_combine[icombine].to_xxx_id)
    ;end update
    SET stat = enspersonhistoryrow(request->xxx_combine[icombine].to_xxx_id,rreclist->
     pm_hist_tracking_id,0.0,rreclist->contributor_system_cd,"CMB",
     curprog)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (findactivenonmultiplecvrrows(dracemultiplecv=f8,dethnicmultiplecv=f8,lracecodeset=i4,
  lethniccodeset=i4,dtopersonid=f8) =null)
   IF (((dracemultiplecv <= 0.0) OR (dethnicmultiplecv <= 0.0)) )
    SELECT DISTINCT INTO "nl:"
     FROM person_code_value_r pcvr
     WHERE pcvr.person_id=dtopersonid
      AND pcvr.active_ind=1
      AND pcvr.code_set IN (lracecodeset, lethniccodeset)
     DETAIL
      IF (pcvr.code_set=lracecodeset
       AND dracemultiplecv <= 0.0)
       bracerowpresent = true
      ENDIF
      IF (pcvr.code_set=lethniccodeset
       AND dethnicmultiplecv <= 0.0)
       bethnicrowpresent = true
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (gatherpreviouscvrvalues(dfrompersonid=f8,lcodeset=i4) =null)
   IF (dfrompersonid > 0.0)
    SELECT INTO "nl"
     FROM person_code_value_r pcvr
     WHERE pcvr.person_id=dfrompersonid
      AND pcvr.code_set=lcodeset
      AND pcvr.active_ind=1
     DETAIL
      icombinedet += 1, stat = alterlist(request->xxx_combine_det,icombinedet), request->
      xxx_combine_det[icombinedet].combine_action_cd = upt,
      request->xxx_combine_det[icombinedet].entity_id = pcvr.person_code_value_r_id, request->
      xxx_combine_det[icombinedet].entity_name = "PERSON_CODE_VALUE_R", request->xxx_combine_det[
      icombinedet].attribute_name = "PERSON_CODE_VALUE_R_ID",
      request->xxx_combine_det[icombinedet].prev_active_ind = pcvr.active_ind, request->
      xxx_combine_det[icombinedet].prev_active_status_cd = pcvr.active_status_cd, request->
      xxx_combine_det[icombinedet].prev_end_eff_dt_tm = pcvr.end_effective_dt_tm
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivatepcvrrows(dfrompersonid=f8,lcodeset=i4) =null)
   IF (dfrompersonid > 0.0)
    UPDATE  FROM person_code_value_r pcvr
     SET pcvr.active_ind = false, pcvr.active_status_cd = combinedaway, pcvr.end_effective_dt_tm =
      cnvtdatetime(sysdate),
      pcvr.updt_cnt = (pcvr.updt_cnt+ 1), pcvr.updt_id = reqinfo->updt_id, pcvr.updt_applctx =
      reqinfo->updt_applctx,
      pcvr.updt_task = reqinfo->updt_task, pcvr.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE pcvr.person_id=dfrompersonid
      AND pcvr.code_set=lcodeset
      AND pcvr.active_ind=1
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE (del_to(s_df_pk_id=f8,s_df_prev_act_ind=i4,s_df_prev_act_status=f8) =i2)
   UPDATE  FROM person_code_value_r tu
    SET tu.active_ind = false, tu.active_status_cd = combinedaway, tu.updt_cnt = (tu.updt_cnt+ 1),
     tu.updt_id = reqinfo->updt_id, tu.updt_applctx = reqinfo->updt_applctx, tu.updt_task = reqinfo->
     updt_task,
     tu.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE tu.person_code_value_r_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_CODE_VALUE_R"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) =i2)
   UPDATE  FROM person_code_value_r frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.person_code_value_r_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_CODE_VALUE_R"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (revcombineraceethnicityrows(v_cust_loopcount=i4,v_cust_count2=i4) =null)
   DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
   DECLARE to_id_present = i4 WITH protect, noconstant(0)
   FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
    IF ((((l_race_codeset=rreclist->from_rec[v_cust_loopcount].from_code_set)
     AND (l_race_codeset=rreclist->to_rec[v_cust_loopcount2].to_code_set)
     AND d_race_multiple_cv <= 0.0) OR ((l_ethnic_codeset=rreclist->from_rec[v_cust_loopcount].
    from_code_set)
     AND (l_ethnic_codeset=rreclist->to_rec[v_cust_loopcount2].to_code_set)
     AND d_ethnic_multiple_cv <= 0.0)) )
     SET to_id_present = 1
    ENDIF
    IF (to_id_present=1)
     IF (del_to(rreclist->to_rec[v_cust_loopcount2].to_pk_id,rreclist->to_rec[v_cust_loopcount2].
      active_ind,rreclist->to_rec[v_cust_loopcount2].active_status_cd)=0)
      GO TO end_prog
     ENDIF
     SET to_id_present = 0
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_pk_id,request->xxx_combine[icombine].
      to_xxx_id)=0)
      GO TO end_prog
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
#end_prog
 FREE SET rreclist
END GO
