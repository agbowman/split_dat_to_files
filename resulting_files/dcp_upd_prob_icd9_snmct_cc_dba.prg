CREATE PROGRAM dcp_upd_prob_icd9_snmct_cc:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ((validate(mn_num_children,- (1))=- (1)))
  DECLARE mn_num_children = i4 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(mn_num_tabs,- (2))=- (2)))
  DECLARE mn_num_tabs = i2 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(dm2_rdm_parallel_debug_ind,- (1))=- (1)))
  DECLARE dm2_rdm_parallel_debug_ind = i2 WITH protect, noconstant(0)
 ELSEIF (dm2_rdm_parallel_debug_ind=1)
  CALL echo("*** Debugging mode for parallel readmes has been enabled ***")
  DECLARE debug_spaceline = c255 WITH protect, noconstant("")
  SET debug_spaceline = fillstring(255," ")
 ENDIF
 SUBROUTINE (sbr_insert_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_insert_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM dm_info di
    SET di.info_domain = ps_domain, di.info_name = ps_name, di.info_number = 0,
     di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to insert range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_update_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_update_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   UPDATE  FROM dm_info di
    SET di.info_number = 0, di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WHERE di.info_domain=ps_domain
     AND di.info_name=ps_name
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_delete_dm_info(ps_domain=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_delete_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DELETE  FROM dm_info
    WHERE info_domain=ps_domain
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from the DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_wipe_ranges(ms_info_domain_nm=vc,ms_child_prefix=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_wipe_ranges()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:  ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Prefix: ",ms_child_prefix))
   DECLARE temp_range = vc WITH protect, noconstant("min:0:max:0")
   DECLARE temp_range_name = vc WITH protect, noconstant("")
   IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
    CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
    RETURN(0)
   ENDIF
   FOR (range_idx = 1 TO mn_num_children)
    SET temp_range_name = concat(ms_child_prefix," ",cnvtstring(range_idx))
    IF (sbr_insert_dm_info(ms_info_domain_nm,temp_range_name,temp_range)=0)
     CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
     RETURN(0)
    ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_count_children(ms_info_domain_nm=vc) =i4)
   CALL sbr_parallel_debug_echo("Entering sbr_count_children()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ms_info_domain_nm))
   DECLARE mn_count = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_char="SUCCESS"
    DETAIL
     mn_count += 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select from info_table for success row: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_count_children() return: -1")
    RETURN(- (1))
   ENDIF
   CALL sbr_parallel_debug_echo(concat("sbr_count_children() return: ",build(mn_count)))
   RETURN(mn_count)
 END ;Subroutine
 SUBROUTINE (sbr_parallel_debug_echo(ms_msg=vc) =null)
   IF (dm2_rdm_parallel_debug_ind=1)
    IF (findstring("() return:",ms_msg) > 0)
     SET mn_num_tabs = maxval(0,(mn_num_tabs - 1))
    ENDIF
    CALL echo(concat(substring(1,(mn_num_tabs * 2),debug_spaceline),trim(ms_msg,1)))
    IF (ms_msg=patstring("Entering*?"))
     SET mn_num_tabs += 1
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE sbr_handle_cc_error(null) = i2
 IF ((validate(mf_runtime,- (1))=- (1)))
  DECLARE mf_runtime = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF ((validate(dq_starttime,- (1))=- (1)))
  DECLARE dq_starttime = dq8 WITH protect
 ENDIF
 IF ((validate(mf_min_batch_tm,- (2))=- (2)))
  DECLARE mf_min_batch_tm = f8 WITH protect, noconstant(- (1.0))
  DECLARE mf_max_batch_tm = f8 WITH protect, noconstant(- (1.0))
 ENDIF
 SUBROUTINE (sbr_get_min_max(mf_min_range_id=f8(ref),mf_max_range_id=f8(ref)) =null)
   CALL sbr_parallel_debug_echo("Entering sbr_get_min_max()")
   SET mf_min_range_id =  $1
   SET mf_max_range_id =  $2
   CALL echo(concat("MIN: ",cnvtstring(mf_min_range_id)))
   CALL echo(concat("MAX: ",cnvtstring(mf_max_range_id)))
   CALL sbr_parallel_debug_echo("sbr_get_min_max() return: <No return value>")
 END ;Subroutine
 SUBROUTINE sbr_handle_cc_error(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   IF (error(errmsg,0) != 0)
    IF (((findstring("ORA-01555",errmsg) != 0) OR (((findstring("ORA-01650",errmsg) != 0) OR (((
    findstring("ORA-01562",errmsg) != 0) OR (((findstring("ORA-30036",errmsg) != 0) OR (((findstring(
     "ORA-30027",errmsg) != 0) OR (findstring("ORA-01581",errmsg) != 0)) )) )) )) )) )
     ROLLBACK
     SET mn_rollback_seg_failed = 1
     CALL echo("Trapped rollback segment error; restructuring readme...")
     SET readme_data->status = "F"
     SET readme_data->message = concat("Trapped rollback error: ",errmsg)
     RETURN(0)
    ELSEIF (findstring("ORA-00060",errmsg) != 0)
     ROLLBACK
     SET mn_deadlock_ind = 1
     CALL echo("Detected deadlock error")
     SET readme_data->status = "F"
     SET readme_data->message = concat("Trapped deadlock error: ",errmsg)
     RETURN(0)
    ENDIF
    CALL echo("Processing failed...")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during CC readme execution: ",errmsg)
    SET mn_child_failed = 1
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_upd_id_evaluated(mf_max_id=f8,ms_info_domain_nm=vc,ms_max_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_upd_id_evaluated()")
   CALL sbr_parallel_debug_echo(concat("Maximum ID:        ",cnvtstring(mf_max_id)))
   CALL sbr_parallel_debug_echo(concat("Domain Name:       ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",ms_max_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET mf_runtime = datetimediff(cnvtdatetime(sysdate),dq_starttime,5)
   CALL sbr_parallel_debug_echo(concat("Runtime: ",cnvtstring(mf_runtime)))
   UPDATE  FROM dm_info di
    SET di.info_number = mf_max_id, di.info_date = cnvtdatetime(sysdate), di.updt_cnt = (di.updt_cnt
     + 1),
     di.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_name=concat(ms_max_name," ",cnvtstring(mf_readme_num))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update SUCCESS row on DM_INFO: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 0")
    RETURN(0)
   ELSE
    CALL sbr_parallel_debug_echo("Committing SUCCESS row update.")
    COMMIT
   ENDIF
   IF (mf_min_batch_tm >= 0.0)
    CALL sbr_parallel_debug_echo("Minimum runtime previously set; using smallest value")
    SET mf_min_batch_tm = minval(mf_min_batch_tm,mf_runtime)
   ELSE
    CALL sbr_parallel_debug_echo("Minimum runtime not previously set; using current runtime")
    SET mf_min_batch_tm = mf_runtime
   ENDIF
   SET mf_max_batch_tm = maxval(mf_max_batch_tm,mf_runtime)
   CALL sbr_parallel_debug_echo(concat("Minimum runtime: ",cnvtstring(mf_min_batch_tm)))
   CALL sbr_parallel_debug_echo(concat("Maximum runtime: ",cnvtstring(mf_max_batch_tm)))
   UPDATE  FROM dm_parallel_readme_stats dprs
    SET dprs.total_elapsed_tm = (dprs.total_elapsed_tm+ mf_runtime), dprs.min_batch_tm =
     mf_min_batch_tm, dprs.max_batch_tm = mf_max_batch_tm,
     dprs.last_batch_tm = mf_runtime, dprs.std_dvtn_square = ((dprs.total_elapsed_tm** 2)+ (
     mf_runtime** 2)), dprs.updt_dt_tm = cnvtdatetime(sysdate),
     dprs.updt_cnt = (dprs.updt_cnt+ 1), dprs.updt_id = reqinfo->updt_id, dprs.updt_applctx = reqinfo
     ->updt_applctx,
     dprs.updt_task = reqinfo->updt_task
    WHERE dprs.readme_id=mf_readme_num
     AND dprs.range_name=concat(ms_max_name," ",cnvtstring(mf_readme_num))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error updating statistics row: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 0")
    RETURN(0)
   ELSE
    CALL sbr_parallel_debug_echo("Committing stats row update.")
    COMMIT
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 1")
   RETURN(1)
 END ;Subroutine
 DECLARE parent_script_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT")
 DECLARE range_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT RANGE")
 DECLARE child_c_script_name = vc WITH protect, constant("dcp_upd_prob_icd9_snmct_cc")
 DECLARE max_person_id_eval = vc WITH protect, constant("MAX PERSON_ID EVALUATED")
 DECLARE range_name_p2 = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT CAT5 RANGE")
 DECLARE max_num_children = i4 WITH protect, constant(5)
 DECLARE batch_size_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT BATCH SIZE")
 DECLARE oracle_hint_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT ORAHINT")
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_child_c_info_domain_nm = vc WITH protect, noconstant("")
 DECLARE ms_child_c_max_name = vc WITH protect, noconstant("")
 SET ms_child_c_info_domain_nm = parent_script_name
 SET ms_child_c_max_name = max_person_id_eval
 CALL sbr_get_min_max(mf_min_id,mf_max_id)
 CALL echo("Processing...")
 CALL echo(concat("From ",cnvtstring(mf_min_id)," to ",cnvtstring(mf_max_id)))
 FREE RECORD person_qual
 RECORD person_qual(
   1 persons[*]
     2 person_id = f8
 )
 DECLARE uuid = vc WITH protect, noconstant("")
 DECLARE iid = f8 WITH protect, noconstant(0.0)
 DECLARE personidx = i4 WITH protect, noconstant(0)
 DECLARE personcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM problem p
  WHERE p.person_id BETWEEN mf_min_id AND mf_max_id
   AND p.person_id > 0
   AND p.problem_id > 0
   AND p.problem_type_flag IN (0, 1)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ELSEIF (curqual=0)
  CALL echo(concat("SKIPPING:::",cnvtstring(mf_min_id),"|",cnvtstring(mf_max_id)))
  GO TO exit_program
 ENDIF
 CALL echo("Checking for problems that qualify...")
 CALL echo(build("userOraHint in CC: ",userorahint))
 INSERT  FROM temp_prob_icd9_snmct
  (person_id, problem_instance_id, dest_nomenclature_id,
  new_problem_instance_id)(SELECT
   p.person_id, p.problem_instance_id, n2.nomenclature_id,
   iid = seq(problem_seq,nextval)
   FROM nomenclature n,
    problem p,
    nomenclature n2
   WHERE n.source_vocabulary_cd IN (dicd9)
    AND ((p.originating_nomenclature_id > 0.0
    AND p.originating_nomenclature_id=n.nomenclature_id) OR (p.originating_nomenclature_id <= 0.0
    AND p.nomenclature_id > 0.0
    AND p.nomenclature_id=n.nomenclature_id))
    AND p.person_id BETWEEN mf_min_id AND mf_max_id
    AND p.person_id > 0
    AND p.problem_id > 0
    AND p.problem_type_flag IN (0, 1)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND n2.source_vocabulary_cd=dsnmct
    AND  NOT (trim(n2.cmti,3) IN (null, ""))
    AND  NOT (trim(n2.concept_cki,3) IN (null, ""))
    AND n2.source_string_keycap=n.source_string_keycap
    AND n2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND n2.end_effective_dt_tm >= cnvtdatetime(sysdate)
   WITH nocounter, orahintcbo(value(userorahint)))
  WITH nocounter
 ;end insert
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 DECLARE tempcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  temp = count(*)
  FROM temp_prob_icd9_snmct
  DETAIL
   tempcnt = temp
  WITH nocounter
 ;end select
 IF (tempcnt=0)
  CALL echo("No rows qualified. Leaving...")
  GO TO exit_program
 ENDIF
 CALL echo("Remove possible duplicates from temp table...")
 DELETE  FROM temp_prob_icd9_snmct
  WHERE problem_instance_id IN (
  (SELECT
   temp.problem_instance_id
   FROM temp_prob_icd9_snmct temp
   GROUP BY temp.problem_instance_id
   HAVING count(temp.problem_instance_id) > 1))
 ;end delete
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 CALL echo("Generating unique id's...")
 DECLARE temp_cnt = i4 WITH noconstant(1)
 WHILE (temp_cnt > 0)
   SET uuid = uar_createuuid(0)
   UPDATE  FROM temp_prob_icd9_snmct temp
    SET temp.new_problem_instance_uuid = uuid
    WHERE temp.new_problem_instance_uuid=null
    WITH maxqual(temp,1)
   ;end update
   SET temp_cnt = curqual
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
 ENDWHILE
 CALL echo("Update record structure with qualifying persons")
 SELECT DISTINCT INTO "nl:"
  temp.person_id
  FROM temp_prob_icd9_snmct temp
  HEAD REPORT
   personcnt = 0
  DETAIL
   personcnt += 1
   IF (mod(personcnt,100)=1)
    stat = alterlist(person_qual->persons,(personcnt+ 99))
   ENDIF
   person_qual->persons[personcnt].person_id = temp.person_id
  FOOT REPORT
   stat = alterlist(person_qual->persons,personcnt)
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 IF (checkprg("DM2_SET_CONTEXT") > 0)
  EXECUTE dm2_set_context "FIRE_CMB_TRG", "NO"
 ENDIF
 SET personidx = 1
 SET personcnt = size(person_qual->persons,5)
 CALL echo(concat("Starting insert/update loop for ",cnvtstring(personcnt)," people"))
 FOR (personidx = 1 TO personcnt)
   INSERT  FROM problem
    (active_ind, actual_resolution_dt_tm, annotated_display,
    beg_effective_tz, cancel_reason_cd, certainty_cd,
    classification_cd, cond_type_flag, confirmation_status_cd,
    contributor_system_cd, course_cd, del_ind,
    estimated_resolution_dt_tm, family_aware_cd, laterality_cd,
    life_cycle_dt_cd, life_cycle_dt_flag, life_cycle_dt_tm,
    life_cycle_status_cd, life_cycle_tz, nomenclature_id,
    onset_dt_cd, onset_dt_flag, onset_dt_tm,
    onset_tz, organization_id, persistence_cd,
    person_aware_cd, person_aware_prognosis_cd, person_id,
    probability, problem_ftdesc, problem_id,
    problem_type_flag, problem_uuid, prognosis_cd,
    qualifier_cd, ranking_cd, sensitivity,
    severity_cd, severity_class_cd, severity_ftdesc,
    show_in_pm_history_ind, status_updt_dt_tm, status_updt_flag,
    status_updt_precision_cd, active_status_cd, active_status_dt_tm,
    active_status_prsnl_id, beg_effective_dt_tm, data_status_cd,
    data_status_dt_tm, data_status_prsnl_id, end_effective_dt_tm,
    originating_nomenclature_id, problem_instance_id, problem_instance_uuid,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     p.active_ind, p.actual_resolution_dt_tm, p.annotated_display,
     p.beg_effective_tz, p.cancel_reason_cd, p.certainty_cd,
     p.classification_cd, p.cond_type_flag, p.confirmation_status_cd,
     p.contributor_system_cd, p.course_cd, p.del_ind,
     p.estimated_resolution_dt_tm, p.family_aware_cd, p.laterality_cd,
     p.life_cycle_dt_cd, p.life_cycle_dt_flag, p.life_cycle_dt_tm,
     p.life_cycle_status_cd, p.life_cycle_tz, p.nomenclature_id,
     p.onset_dt_cd, p.onset_dt_flag, p.onset_dt_tm,
     p.onset_tz, p.organization_id, p.persistence_cd,
     p.person_aware_cd, p.person_aware_prognosis_cd, p.person_id,
     p.probability, p.problem_ftdesc, p.problem_id,
     p.problem_type_flag, p.problem_uuid, p.prognosis_cd,
     p.qualifier_cd, p.ranking_cd, p.sensitivity,
     p.severity_cd, p.severity_class_cd, p.severity_ftdesc,
     p.show_in_pm_history_ind, p.status_updt_dt_tm, p.status_updt_flag,
     p.status_updt_precision_cd, active_status_cd = dactive, active_status_dt_tm = cnvtdatetime(
      sysdate),
     active_status_prsnl_id = systemuserid, beg_effective_dt_tm = cnvtdatetime(sysdate),
     data_status_cd = dauth,
     data_status_dt_tm = cnvtdatetime(sysdate), data_status_prsnl_id = systemuserid,
     end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     originating_nomenclature_id = temp.dest_nomenclature_id, problem_instance_id = temp
     .new_problem_instance_id, problem_instance_uuid = temp.new_problem_instance_uuid,
     updt_applctx = mf_readme_num, updt_cnt = 0, updt_dt_tm = cnvtdatetime(sysdate),
     updt_id = systemuserid, updt_task = reqinfo->updt_task
     FROM temp_prob_icd9_snmct temp,
      problem p
     WHERE (temp.person_id=person_qual->persons[personidx].person_id)
      AND p.problem_instance_id=temp.problem_instance_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    ROLLBACK
    GO TO exit_program
   ENDIF
   CALL echo("Inactivating old active problem instance rows...")
   UPDATE  FROM problem p
    SET p.active_ind = 0, p.active_status_cd = dinactive, p.active_status_dt_tm = cnvtdatetime(
      sysdate),
     p.active_status_prsnl_id = systemuserid, p.end_effective_dt_tm = cnvtdatetime(sysdate), p
     .updt_applctx = mf_readme_num,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = systemuserid,
     p.updt_task = reqinfo->updt_task
    WHERE p.problem_instance_id IN (
    (SELECT
     temp.problem_instance_id
     FROM temp_prob_icd9_snmct temp
     WHERE (temp.person_id=person_qual->persons[personidx].person_id)))
   ;end update
   IF (sbr_handle_cc_error(null)=0)
    ROLLBACK
    GO TO exit_program
   ENDIF
 ENDFOR
 CALL echo("Processing...Completed")
 IF (sbr_upd_id_evaluated(mf_max_id,ms_child_c_info_domain_nm,ms_child_c_max_name)=0)
  GO TO exit_program
 ENDIF
 CALL sbr_truncate_table("TEMP_PROB_ICD9_SNMCT")
#exit_program
 IF (checkprg("DM2_SET_CONTEXT") > 0)
  EXECUTE dm2_set_context "FIRE_CMB_TRG", "YES"
 ENDIF
END GO
