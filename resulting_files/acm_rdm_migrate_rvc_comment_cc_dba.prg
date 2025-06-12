CREATE PROGRAM acm_rdm_migrate_rvc_comment_cc:dba
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
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_child_c_info_domain_nm = vc WITH protect, noconstant("")
 DECLARE ms_child_c_max_name = vc WITH protect, noconstant("")
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE i18n = i4 WITH protect, constant(uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev))
 DECLARE i18n_auth_applied_to_txt_default = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_AUTH_APPLIED_TO_TXT_DEFAULT","Authorization"))
 DECLARE i18n_auth_applied_to_txt = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_AUTH_APPLIED_TO_TXT","Authorization :"))
 DECLARE i18n_auth_applied_to_txt_ref_nbr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_AUTH_APPLIED_TO_TXT_REF_NBR","Authorization (reference) :"))
 DECLARE i18n_encounter_applied_to_txt_default = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_ENCOUNTER_APPLIED_TO_TXT_DEFAULT","Encounter"))
 DECLARE i18n_encounter = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_ENCOUNTER_APPLIED_TO_TXT","Encounter :"))
 DECLARE i18n_person = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "I18N_PRSN_APPLIED_TO_TXT_DEFAULT","Person"))
 DECLARE migrate_row_cnt = i4 WITH protect, noconstant(0)
 SET ms_child_c_info_domain_nm = "ACM_RDM_MIGRATE_RVC_COMMENT_TO_TIMELINE"
 SET ms_child_c_max_name = "MAX RVC_COMMENT_HIST_ID EVALUATED"
 CALL sbr_get_min_max(mf_min_id,mf_max_id)
 CALL echo("Processing...")
 CALL echo("")
 CALL sbr_add_rvc_comments_to_temp_table_by_range(mf_min_id,mf_max_id)
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 IF (migrate_row_cnt > 0)
  CALL sbr_update_fin_nbrs_for_encntr_comments(mf_min_id,mf_max_id)
  IF (sbr_handle_cc_error(null)=0)
   GO TO exit_program
  ENDIF
  CALL sbr_update_fin_nbrs_for_encntr_auths(mf_min_id,mf_max_id)
  IF (sbr_handle_cc_error(null)=0)
   GO TO exit_program
  ENDIF
  CALL sbr_add_timeline_entries(mf_min_id,mf_max_id)
  IF (sbr_handle_cc_error(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 CALL sbr_truncate_table("temp_rdm_acm_migrate_comment")
 CALL echo("Processing...Completed")
 IF (sbr_upd_id_evaluated(mf_max_id,ms_child_c_info_domain_nm,ms_child_c_max_name)=0)
  GO TO exit_program
 ENDIF
 SUBROUTINE (sbr_add_rvc_comments_to_temp_table_by_range(sbr_min_id=f8,sbr_max_id=f8) =null)
   CALL echo("Start inserting into temp table")
   SET migrate_row_cnt = 0
   INSERT  FROM temp_rdm_acm_migrate_comment t
    (t.rvc_comment_hist_id, t.activity_created_dt_tm, t.activity_created_prsnl_id,
    t.comment_clob, t.parent_entity_id, t.parent_entity_name,
    t.pm_hist_tracking_id, t.applied_to_txt, t.applied_to_cd,
    t.updt_id, t.updt_dt_tm, t.updt_task,
    t.active_status_dt_tm, t.active_status_prsnl_id, t.active_status_cd,
    t.encntr_id)(SELECT
     rch.rvc_comment_hist_id, rch.transaction_dt_tm, rch.updt_id,
     concat(cv.display,": ",rch.comment_text), rch.parent_entity_id, rch.parent_entity_name,
     rch.pm_hist_tracking_id, evaluate(rch.parent_entity_name,"PERSON",i18n_person,"ENCOUNTER",
      i18n_encounter,
      i18n_auth_applied_to_txt), evaluate(rch.parent_entity_name,"PERSON",mf_person_applied_to_cd,
      "ENCOUNTER",mf_encounter_applied_to_cd,
      mf_auth_applied_to_cd),
     rch.updt_id, rch.updt_dt_tm, rch.updt_task,
     rch.active_status_dt_tm, rch.active_status_prsnl_id, rch.active_status_cd,
     0.0
     FROM rvc_comment_hist rch,
      code_value cv
     WHERE rch.rvc_comment_hist_id BETWEEN sbr_min_id AND sbr_max_id
      AND rch.active_ind=1
      AND rch.parent_entity_name IN ("PERSON", "ENCOUNTER", "AUTHORIZATION")
      AND rch.comment_type_class_cd IN (mf_person_class_comment_cd, mf_encntr_class_comment_cd,
     mf_encntr_auth_class_comment_cd)
      AND cv.code_value=rch.comment_type_cd
      AND cv.active_ind=1
      AND rch.rvc_comment_hist_id > 0
      AND rch.parent_entity_id > 0
      AND  NOT ((( EXISTS (
     (SELECT
      rct.rc_timeline_id
      FROM rc_timeline rct
      WHERE rct.parent_entity_id=rch.parent_entity_id
       AND rct.parent_entity_name IN ("PERSON", "ENCOUNTER")
       AND rch.parent_entity_name IN ("PERSON", "ENCOUNTER")
       AND rct.applied_to_cd IN (mf_person_applied_to_cd, mf_encounter_applied_to_cd, 0)
       AND rct.source_reference_ident=cnvtstring(rch.pm_hist_tracking_id)
       AND rct.child_parent_entity_id IN (rch.rvc_comment_hist_id, 0)
       AND rct.solution_cd=mf_registration_solution_cd
       AND rct.activity_type_cd=mf_activity_type_comment_cd
       AND rct.active_ind=1))) OR ( EXISTS (
     (SELECT
      rct.rc_timeline_id
      FROM authorization a,
       encounter e,
       rc_timeline rct
      WHERE a.authorization_id=rch.parent_entity_id
       AND rct.parent_entity_name="ENCOUNTER"
       AND e.encntr_id=a.encntr_id
       AND e.active_ind=1
       AND rct.parent_entity_id=e.encntr_id
       AND rch.parent_entity_name="AUTHORIZATION"
       AND rct.child_parent_entity_id IN (rch.rvc_comment_hist_id, 0)
       AND rct.source_reference_ident=cnvtstring(rch.pm_hist_tracking_id)
       AND rct.solution_cd=mf_registration_solution_cd
       AND rct.activity_type_cd=mf_activity_type_comment_cd
       AND rct.applied_to_cd IN (mf_auth_applied_to_cd, 0)
       AND rct.active_ind=1)))) ))
    WITH nocounter
   ;end insert
   SET migrate_row_cnt = curqual
   CALL echo("Done inserting into temp table")
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (sbr_update_fin_nbrs_for_encntr_comments(sbr_min_id=f8,sbr_max_id=f8) =null)
   CALL echo("Start updating encounter fin number to temp table")
   FREE RECORD t_record
   RECORD t_record(
     1 encounter_cnt = i4
     1 encounters[*]
       2 encntr_id = f8
       2 applied_to_txt = c200
   )
   SELECT INTO "nl:"
    FROM temp_rdm_acm_migrate_comment t,
     encounter e,
     encntr_alias ea
    PLAN (t
     WHERE t.rvc_comment_hist_id BETWEEN sbr_min_id AND sbr_max_id
      AND t.parent_entity_name="ENCOUNTER")
     JOIN (e
     WHERE e.encntr_id=t.parent_entity_id
      AND e.active_ind=1)
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
      AND (ea.active_ind= Outerjoin(1))
      AND (ea.encntr_alias_type_cd= Outerjoin(mf_financial_number_cd))
      AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    HEAD REPORT
     t_record->encounter_cnt = 0
    HEAD e.encntr_id
     t_record->encounter_cnt += 1
     IF (mod(t_record->encounter_cnt,1000)=1)
      stat = alterlist(t_record->encounters,(t_record->encounter_cnt+ 999))
     ENDIF
     t_record->encounters[t_record->encounter_cnt].encntr_id = e.encntr_id
     IF (ea.encntr_id > 0)
      t_record->encounters[t_record->encounter_cnt].applied_to_txt = concat(i18n_encounter," ",
       cnvtalias(ea.alias,ea.alias_pool_cd))
     ELSE
      t_record->encounters[t_record->encounter_cnt].applied_to_txt =
      i18n_encounter_applied_to_txt_default
     ENDIF
    FOOT  e.encntr_id
     null
    FOOT REPORT
     stat = alterlist(t_record->encounters,t_record->encounter_cnt)
    WITH nocounter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   IF ((t_record->encounter_cnt > 0))
    IF (ml_rdb_array_insert_check != 0)
     UPDATE  FROM temp_rdm_acm_migrate_comment t,
       (dummyt d  WITH seq = value(size(t_record->encounters,5)))
      SET t.encntr_id = t_record->encounters[d.seq].encntr_id, t.applied_to_txt = t_record->
       encounters[d.seq].applied_to_txt, t.updt_dt_tm = t.updt_dt_tm,
       t.updt_id = t.updt_id, t.updt_task = t.updt_task
      PLAN (d)
       JOIN (t
       WHERE (t.parent_entity_id=t_record->encounters[d.seq].encntr_id)
        AND t.parent_entity_name="ENCOUNTER")
      WITH nocounter, rdbarrayinsert = 1
     ;end update
    ELSE
     UPDATE  FROM temp_rdm_acm_migrate_comment t,
       (dummyt d  WITH seq = value(size(t_record->encounters,5)))
      SET t.encntr_id = t_record->encounters[d.seq].encntr_id, t.applied_to_txt = t_record->
       encounters[d.seq].applied_to_txt, t.updt_dt_tm = t.updt_dt_tm,
       t.updt_id = t.updt_id, t.updt_task = t.updt_task
      PLAN (d)
       JOIN (t
       WHERE (t.parent_entity_id=t_record->encounters[d.seq].encntr_id)
        AND t.parent_entity_name="ENCOUNTER")
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   CALL echo("Done updating encounter fin number to temp table")
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (sbr_update_fin_nbrs_for_encntr_auths(sbr_min_id=f8,sbr_max_id=f8) =null)
   CALL echo("Start updating authorization text")
   UPDATE  FROM temp_rdm_acm_migrate_comment t
    SET t.encntr_id =
     (SELECT
      max(a.encntr_id)
      FROM authorization a,
       encntr_plan_auth_r epar,
       encntr_plan_reltn epr,
       encounter e
      WHERE a.authorization_id=t.parent_entity_id
       AND epar.authorization_id=a.authorization_id
       AND epr.encntr_plan_reltn_id=epar.encntr_plan_reltn_id
       AND epr.encntr_id=a.encntr_id
       AND e.encntr_id=epr.encntr_id
       AND e.active_ind=1), t.applied_to_txt =
     (SELECT
      evaluate2(
       IF (textlen(trim(a.auth_nbr)) > 0) concat(i18n_auth_applied_to_txt," ",a.auth_nbr)
       ELSEIF (textlen(trim(a.reference_nbr_txt)) > 0) concat(i18n_auth_applied_to_txt_ref_nbr," ",a
         .reference_nbr_txt)
       ELSE i18n_auth_applied_to_txt_default
       ENDIF
       )
      FROM authorization a
      WHERE a.authorization_id=t.parent_entity_id)
    WHERE t.rvc_comment_hist_id BETWEEN sbr_min_id AND sbr_max_id
     AND t.parent_entity_name="AUTHORIZATION"
    WITH nocounter
   ;end update
   CALL echo("Done updating authorization text")
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (sbr_add_timeline_entries(sbr_min_id=f8,sbr_max_id=f8) =null)
   CALL echo("Start inserting into timeline table")
   INSERT  FROM rc_timeline rctl
    (rctl.rc_timeline_id, rctl.comment_clob, rctl.activity_created_dt_tm,
    rctl.activity_created_prsnl_id, rctl.parent_entity_name, rctl.parent_entity_id,
    rctl.activity_type_cd, rctl.solution_cd, rctl.priority_nbr,
    rctl.applied_to_txt, rctl.applied_to_cd, rctl.source_reference_ident,
    rctl.active_ind, rctl.active_status_dt_tm, rctl.active_status_prsnl_id,
    rctl.active_status_cd, rctl.updt_id, rctl.updt_dt_tm,
    rctl.updt_task, rctl.updt_cnt, rctl.child_parent_entity_id)(SELECT
     seq(rc_timeline_seq,nextval), t.comment_clob, t.activity_created_dt_tm,
     t.activity_created_prsnl_id, evaluate(t.parent_entity_name,"PERSON","PERSON","ENCOUNTER"),
     evaluate(t.parent_entity_name,"PERSON",t.parent_entity_id,t.encntr_id),
     mf_activity_type_comment_cd, mf_registration_solution_cd, 1,
     t.applied_to_txt, t.applied_to_cd, cnvtstring(t.pm_hist_tracking_id),
     1, t.active_status_dt_tm, t.active_status_prsnl_id,
     t.active_status_cd, t.updt_id, t.updt_dt_tm,
     t.updt_task, 0, t.rvc_comment_hist_id
     FROM temp_rdm_acm_migrate_comment t
     WHERE t.rvc_comment_hist_id BETWEEN sbr_min_id AND sbr_max_id
      AND t.rvc_comment_hist_id > 0
      AND ((t.parent_entity_name="PERSON"
      AND  EXISTS (
     (SELECT
      p.person_id
      FROM person p
      WHERE p.person_id=t.parent_entity_id
       AND p.active_ind=1))) OR (((t.parent_entity_name="AUTHORIZATION"
      AND t.encntr_id > 0) OR (t.parent_entity_name="ENCOUNTER"
      AND t.encntr_id > 0)) )) )
    WITH nocounter
   ;end insert
   CALL echo("Done inserting into timeline table")
   RETURN(null)
 END ;Subroutine
#exit_program
END GO
