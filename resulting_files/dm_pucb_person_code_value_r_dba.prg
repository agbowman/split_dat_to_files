CREATE PROGRAM dm_pucb_person_code_value_r:dba
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
 DECLARE l_race_codeset = i4 WITH constant(282), private
 DECLARE l_ethnic_codeset = i4 WITH constant(27), private
 DECLARE l_disease_alert_codeset = i4 WITH constant(19349), private
 DECLARE l_process_alert_codeset = i4 WITH constant(19350), private
 DECLARE d_race_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",l_race_codeset,"MULTIPLE")),
 private
 DECLARE d_ethnic_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",l_ethnic_codeset,
   "MULTIPLE")), private
 DECLARE d_disease_alert_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",
   l_disease_alert_codeset,"MULTISELECT")), private
 DECLARE d_process_alert_multiple_cv = f8 WITH constant(uar_get_code_by("MEANING",
   l_process_alert_codeset,"MULTISELECT")), private
 IF ( NOT (validate(bpcvrrowscalculated)))
  DECLARE bpcvrrowscalculated = i2 WITH noconstant(false), protect
 ENDIF
 DECLARE irecordqualcnt = i4 WITH noconstant(0), protect
 DECLARE icount = i4 WITH noconstant(0), protect
 DECLARE ipersoncodevaluerfound = i2 WITH noconstant(false), protect
 DECLARE irchildrensize = i4 WITH noconstant(0), protect
 DECLARE syncpersoncvrtable(null) = null
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_CODE_VALUE_R"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_PERSON_CODE_VALUE_R"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(cust_ucb_dummy)
  CALL syncpersoncvrtable(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
  CALL syncpersoncvrtable(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  SET request->error_message = build("Unrecognized combine action code found: ",rchildren->qual1[
   det_cnt].combine_action_cd)
  GO TO exit_sub
 ENDIF
 IF ( NOT (bpcvrrowscalculated))
  SET irchildrensize = size(rchildren->qual1,5)
  FOR (icount = 1 TO irchildrensize)
   IF ((rchildren->qual1[icount].entity_name="PERSON_CODE_VALUE_R"))
    SET ipersoncodevaluerfound = true
   ENDIF
   IF (icount < irchildrensize
    AND ipersoncodevaluerfound=true
    AND (rchildren->qual1[(icount+ 1)].entity_name != "PERSON_CODE_VALUE_R"))
    SET irecordqualcnt = icount
    SET bpcvrrowscalculated = true
    GO TO syncpersontable
   ENDIF
  ENDFOR
 ENDIF
#syncpersontable
 IF (det_cnt=irecordqualcnt)
  CALL syncpersontbl(l_race_codeset,d_race_multiple_cv,l_ethnic_codeset,d_ethnic_multiple_cv)
  CALL syncpersonpatienttbl(l_disease_alert_codeset,d_disease_alert_multiple_cv,
   l_process_alert_codeset,d_process_alert_multiple_cv)
 ENDIF
#exit_sub
 SUBROUTINE cust_ucb_add(dummy)
  DELETE  FROM person_code_value_r pcv
   WHERE (pcv.person_code_value_r_id=rchildren->qual1[det_cnt].entity_id)
   WITH nocounter
  ;end delete
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
  UPDATE  FROM person_code_value_r pcv
   SET pcv.updt_id = reqinfo->updt_id, pcv.updt_dt_tm = cnvtdatetime(sysdate), pcv.updt_applctx =
    reqinfo->updt_applctx,
    pcv.updt_cnt = (pcv.updt_cnt+ 1), pcv.updt_task = reqinfo->updt_task, pcv.person_id = request->
    xxx_uncombine[ucb_cnt].to_xxx_id
   WHERE (pcv.person_code_value_r_id=rchildren->qual1[det_cnt].entity_id)
   WITH nocounter
  ;end update
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE (syncpersontbl(lracecodeset=i4,dracemultiplecv=f8,lethniccodeset=i4,dethnicmultiplecv=f8
  ) =null)
   DECLARE lracecount = i4 WITH noconstant(0), protect
   DECLARE lethnicgrpcount = i4 WITH noconstant(0), protect
   DECLARE lpersoncounter = i4 WITH noconstant(0), protect
   DECLARE lpersonindex = i4 WITH noconstant(0), protect
   DECLARE lindex = i4 WITH noconstant(0), protect
   FREE RECORD temprec
   RECORD temprec(
     1 person[*]
       2 person_id = f8
       2 race_cd = f8
       2 ethnic_grp_cd = f8
       2 update_race_ind = i2
       2 update_ethnic_grp_ind = i2
       2 pm_hist_tracking_id = f8
       2 contributor_system_cd = f8
   ) WITH protect
   SET stat = alterlist(temprec->person,2)
   SET temprec->person[1].person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
   SET temprec->person[2].person_id = request->xxx_uncombine[ucb_cnt].from_xxx_id
   SELECT INTO "nl:"
    FROM person p,
     (left JOIN person_code_value_r pcvr ON p.person_id=pcvr.person_id
      AND pcvr.code_set IN (lethniccodeset, lracecodeset)
      AND pcvr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pcvr.active_ind=1)
    PLAN (p
     WHERE expand(lpersoncounter,1,size(temprec->person,5),p.person_id,temprec->person[lpersoncounter
      ].person_id))
     JOIN (pcvr)
    ORDER BY p.person_id, pcvr.code_set
    HEAD p.person_id
     lethnicgrpcount = 0, lracecount = 0, lpersonindex = locateval(lindex,1,size(temprec->person,5),p
      .person_id,temprec->person[lindex].person_id),
     temprec->person[lpersonindex].ethnic_grp_cd = 0.0, temprec->person[lpersonindex].
     update_ethnic_grp_ind = true, temprec->person[lpersonindex].race_cd = 0.0,
     temprec->person[lpersonindex].update_race_ind = true
    DETAIL
     IF (dethnicmultiplecv > 0.0
      AND pcvr.code_set=lethniccodeset)
      lethnicgrpcount += 1,
      CALL echo(build("lEthnicGrpCount =",lethnicgrpcount))
      IF (lethnicgrpcount=1)
       IF (p.ethnic_grp_cd != pcvr.code_value)
        temprec->person[lpersonindex].ethnic_grp_cd = pcvr.code_value, temprec->person[lpersonindex].
        update_ethnic_grp_ind = true
       ELSE
        temprec->person[lpersonindex].ethnic_grp_cd = pcvr.code_value, temprec->person[lpersonindex].
        update_ethnic_grp_ind = false
       ENDIF
      ELSE
       IF (p.ethnic_grp_cd != dethnicmultiplecv)
        temprec->person[lpersonindex].ethnic_grp_cd = dethnicmultiplecv, temprec->person[lpersonindex
        ].update_ethnic_grp_ind = true
       ELSE
        temprec->person[lpersonindex].ethnic_grp_cd = 0.0, temprec->person[lpersonindex].
        update_ethnic_grp_ind = false
       ENDIF
      ENDIF
     ELSEIF (dethnicmultiplecv < 0.0
      AND pcvr.code_set=lethniccodeset)
      temprec->person[lpersonindex].update_ethnic_grp_ind = false
     ENDIF
     IF (dracemultiplecv > 0.0
      AND pcvr.code_set=lracecodeset)
      lracecount += 1,
      CALL echo(build("lRaceCount =",lracecount))
      IF (lracecount=1)
       IF (p.race_cd != pcvr.code_value)
        temprec->person[lpersonindex].race_cd = pcvr.code_value, temprec->person[lpersonindex].
        update_race_ind = true
       ELSE
        temprec->person[lpersonindex].race_cd = pcvr.code_value, temprec->person[lpersonindex].
        update_race_ind = false
       ENDIF
      ELSE
       IF (p.race_cd != dracemultiplecv)
        temprec->person[lpersonindex].race_cd = dracemultiplecv, temprec->person[lpersonindex].
        update_race_ind = true
       ELSE
        temprec->person[lpersonindex].race_cd = 0.0, temprec->person[lpersonindex].update_race_ind =
        false
       ENDIF
      ENDIF
     ELSEIF (dracemultiplecv < 0.0
      AND pcvr.code_set=lracecodeset)
      temprec->person[lpersonindex].update_race_ind = false
     ENDIF
    WITH nocounter
   ;end select
   IF ((((temprec->person[1].update_race_ind=true)) OR ((temprec->person[1].update_ethnic_grp_ind=
   true))) )
    CALL echo(build("Person1 - bUpdateToPersonInd = TRUE"))
    UPDATE  FROM person p
     SET p.ethnic_grp_cd = evaluate2(
       IF ((temprec->person[1].update_ethnic_grp_ind=true)) temprec->person[1].ethnic_grp_cd
       ELSE p.ethnic_grp_cd
       ENDIF
       ), p.race_cd = evaluate2(
       IF ((temprec->person[1].update_race_ind=true)) temprec->person[1].race_cd
       ELSE p.race_cd
       ENDIF
       ), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
      updt_task,
      p.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (p.person_id=temprec->person[1].person_id)
    ;end update
    SET stat = enspersonhistoryrow(temprec->person[1].person_id,temprec->person[1].
     pm_hist_tracking_id,0.0,temprec->person[1].contributor_system_cd,"UCB",
     curprog)
   ENDIF
   IF ((((temprec->person[2].update_race_ind=true)) OR ((temprec->person[2].update_ethnic_grp_ind=
   true))) )
    CALL echo(build("Person2 - bUpdateToPersonInd = TRUE"))
    UPDATE  FROM person p
     SET p.ethnic_grp_cd = evaluate2(
       IF ((temprec->person[2].update_ethnic_grp_ind=true)) temprec->person[2].ethnic_grp_cd
       ELSE p.ethnic_grp_cd
       ENDIF
       ), p.race_cd = evaluate2(
       IF ((temprec->person[2].update_race_ind=true)) temprec->person[2].race_cd
       ELSE p.race_cd
       ENDIF
       ), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
      updt_task,
      p.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (p.person_id=temprec->person[2].person_id)
    ;end update
    SET stat = enspersonhistoryrow(temprec->person[2].person_id,temprec->person[2].
     pm_hist_tracking_id,0.0,temprec->person[2].contributor_system_cd,"UCB",
     curprog)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE syncpersoncvrtable(null)
  IF ((rchildren->qual1[det_cnt].prev_end_eff_dt_tm > 0))
   UPDATE  FROM person_code_value_r p
    SET p.active_ind = rchildren->qual1[det_cnt].prev_active_ind, p.active_status_cd = rchildren->
     qual1[det_cnt].prev_active_status_cd, p.end_effective_dt_tm = cnvtdatetime(rchildren->qual1[
      det_cnt].prev_end_eff_dt_tm)
    WHERE (p.person_code_value_r_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ENDIF
  RETURN
 END ;Subroutine
 SUBROUTINE (syncpersonpatienttbl(ldiseasealertcodeset=i4,ddiseasealertmultiplecv=f8,
  lprocessalertcodeset=i4,dprocessalertmultiplecv=f8) =null)
   DECLARE ldiseasealertcount = i4 WITH noconstant(0), protect
   DECLARE lprocessalertcount = i4 WITH noconstant(0), protect
   DECLARE lpersoncounter = i4 WITH noconstant(0), protect
   DECLARE lpersonindex = i4 WITH noconstant(0), protect
   DECLARE lindex = i4 WITH noconstant(0), protect
   FREE RECORD temprec
   RECORD temprec(
     1 person[*]
       2 person_id = f8
       2 disease_alert_cd = f8
       2 process_alert_cd = f8
       2 update_disease_alert = i2
       2 update_process_alert = i2
   ) WITH protect
   SET stat = alterlist(temprec->person,2)
   SET temprec->person[1].person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
   SET temprec->person[2].person_id = request->xxx_uncombine[ucb_cnt].from_xxx_id
   SELECT INTO "nl:"
    FROM person_patient pp,
     (left JOIN person_code_value_r pcvr ON pp.person_id=pcvr.person_id
      AND pcvr.code_set IN (ldiseasealertcodeset, lprocessalertcodeset)
      AND pcvr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pcvr.active_ind=1)
    PLAN (pp
     WHERE expand(lpersoncounter,1,size(temprec->person,5),pp.person_id,temprec->person[
      lpersoncounter].person_id))
     JOIN (pcvr)
    ORDER BY pp.person_id, pcvr.code_set
    HEAD pp.person_id
     ldiseasealertcount = 0, lprocessalertcount = 0, lpersonindex = locateval(lindex,1,size(temprec->
       person,5),pp.person_id,temprec->person[lindex].person_id),
     temprec->person[lpersonindex].disease_alert_cd = 0.0, temprec->person[lpersonindex].
     update_disease_alert = true, temprec->person[lpersonindex].process_alert_cd = 0.0,
     temprec->person[lpersonindex].update_process_alert = true
    DETAIL
     IF (ddiseasealertmultiplecv > 0.0
      AND pcvr.code_set=ldiseasealertcodeset)
      ldiseasealertcount += 1
      IF (ldiseasealertcount=1)
       IF (pp.disease_alert_cd != pcvr.code_value)
        temprec->person[lpersonindex].disease_alert_cd = pcvr.code_value, temprec->person[
        lpersonindex].update_disease_alert = true
       ELSE
        temprec->person[lpersonindex].disease_alert_cd = pcvr.code_value, temprec->person[
        lpersonindex].update_disease_alert = false
       ENDIF
      ELSE
       IF (pp.disease_alert_cd != ddiseasealertmultiplecv)
        temprec->person[lpersonindex].disease_alert_cd = ddiseasealertmultiplecv, temprec->person[
        lpersonindex].update_disease_alert = true
       ELSE
        temprec->person[lpersonindex].disease_alert_cd = 0.0, temprec->person[lpersonindex].
        update_disease_alert = false
       ENDIF
      ENDIF
     ELSEIF (ddiseasealertmultiplecv < 0.0
      AND pcvr.code_set=ldiseasealertcodeset)
      temprec->person[lpersonindex].update_disease_alert = false
     ENDIF
     IF (dprocessalertmultiplecv > 0.0
      AND pcvr.code_set=lprocessalertcodeset)
      lprocessalertcount += 1
      IF (lprocessalertcount=1)
       IF (pp.process_alert_cd != pcvr.code_value)
        temprec->person[lpersonindex].process_alert_cd = pcvr.code_value, temprec->person[
        lpersonindex].update_process_alert = true
       ELSE
        temprec->person[lpersonindex].process_alert_cd = pcvr.code_value, temprec->person[
        lpersonindex].update_process_alert = false
       ENDIF
      ELSE
       IF (pp.process_alert_cd != dprocessalertmultiplecv)
        temprec->person[lpersonindex].process_alert_cd = dprocessalertmultiplecv, temprec->person[
        lpersonindex].update_process_alert = true
       ELSE
        temprec->person[lpersonindex].process_alert_cd = 0.0, temprec->person[lpersonindex].
        update_process_alert = false
       ENDIF
      ENDIF
     ELSEIF (dprocessalertmultiplecv < 0.0
      AND pcvr.code_set=lprocessalertcodeset)
      temprec->person[lpersonindex].update_process_alert = false
     ENDIF
    WITH nocounter
   ;end select
   IF ((((temprec->person[1].update_disease_alert=true)) OR ((temprec->person[1].update_process_alert
   =true))) )
    UPDATE  FROM person_patient pp
     SET pp.disease_alert_cd = evaluate2(
       IF ((temprec->person[1].update_disease_alert=true)) temprec->person[1].disease_alert_cd
       ELSE pp.disease_alert_cd
       ENDIF
       ), pp.process_alert_cd = evaluate2(
       IF ((temprec->person[1].update_process_alert=true)) temprec->person[1].process_alert_cd
       ELSE pp.process_alert_cd
       ENDIF
       ), pp.updt_cnt = (pp.updt_cnt+ 1),
      pp.updt_id = reqinfo->updt_id, pp.updt_applctx = reqinfo->updt_applctx, pp.updt_task = reqinfo
      ->updt_task,
      pp.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (pp.person_id=temprec->person[1].person_id)
    ;end update
   ENDIF
   IF ((((temprec->person[2].update_disease_alert=true)) OR ((temprec->person[2].update_process_alert
   =true))) )
    UPDATE  FROM person_patient pp
     SET pp.disease_alert_cd = evaluate2(
       IF ((temprec->person[2].update_disease_alert=true)) temprec->person[2].disease_alert_cd
       ELSE pp.disease_alert_cd
       ENDIF
       ), pp.process_alert_cd = evaluate2(
       IF ((temprec->person[2].update_process_alert=true)) temprec->person[2].process_alert_cd
       ELSE pp.process_alert_cd
       ENDIF
       ), pp.updt_cnt = (pp.updt_cnt+ 1),
      pp.updt_id = reqinfo->updt_id, pp.updt_applctx = reqinfo->updt_applctx, pp.updt_task = reqinfo
      ->updt_task,
      pp.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (pp.person_id=temprec->person[2].person_id)
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE (cust_ucb_del(null) =null)
  UPDATE  FROM person_code_value_r p
   SET p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_applctx = reqinfo->
    updt_applctx,
    p.updt_cnt = (updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.active_ind = rchildren->qual1[
    det_cnt].prev_active_ind,
    p.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd, p.active_status_dt_tm =
    cnvtdatetime(sysdate), p.active_status_prsnl_id = reqinfo->updt_id
   WHERE (p.person_code_value_r_id=rchildren->qual1[det_cnt].entity_id)
   WITH nocounter
  ;end update
  SET activity_updt_cnt += 1
 END ;Subroutine
END GO
