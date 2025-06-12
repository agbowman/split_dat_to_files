CREATE PROGRAM dm_rdm_upd_saved_docs_entry_cc:dba
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
 DECLARE task_status_pending_cd = f8 WITH protect, noconstant(0.0)
 DECLARE task_status_deleted_cd = f8 WITH protect, noconstant(0.0)
 DECLARE task_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE power_form_entry_cd = f8 WITH protect, noconstant(0.0)
 DECLARE wkfdoccomp_entry_cd = f8 WITH protect, noconstant(0.0)
 DECLARE task_activity_cd_saved_doc = f8 WITH protect, noconstant(0.0)
 DECLARE task_status_bogus_cd = f8 WITH protect, constant(99999.0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=79
    AND cv.cdf_meaning="PENDING")
  DETAIL
   task_status_pending_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=79
    AND cv.cdf_meaning="DELETED")
  DETAIL
   task_status_deleted_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6026
    AND cv.cdf_meaning="ENDORSE")
  DETAIL
   task_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=29520
    AND cv.cdf_meaning="POWERFORMS")
  DETAIL
   power_form_entry_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=29520
    AND cv.cdf_meaning="WKFDOCCOMP")
  DETAIL
   wkfdoccomp_entry_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6027
    AND cv.cdf_meaning="SAVED DOC")
  DETAIL
   task_activity_cd_saved_doc = cv.code_value
  WITH nocounter
 ;end select
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 SET ms_child_c_info_domain_nm = "DM_RDM_UPD_SAVED_DOCS_ENTRY_MODE_CODE"
 SET ms_child_c_max_name = "MAX TASK_ACTIVITY_ID EVALUATED"
 CALL sbr_get_min_max(mf_min_id,mf_max_id)
 CALL echo(build("Processing TASK_ACTIVITY_IDs from [",mf_min_id,"] to [",mf_max_id,"]..."))
 CALL echo("")
 INSERT  FROM temp_entrymode_task_activity temp
  (temp.task_id)(SELECT
   ta.task_id
   FROM task_activity ta,
    task_activity_assignment taa,
    person psn,
    encounter encntr,
    clinical_event ce
   WHERE ta.active_ind=1
    AND ta.task_type_cd=task_type_cd
    AND ta.task_status_cd IN (task_status_pending_cd, task_status_bogus_cd)
    AND ta.task_activity_cd=task_activity_cd_saved_doc
    AND ta.task_id BETWEEN mf_min_id AND mf_max_id
    AND taa.task_id=ta.task_id
    AND taa.active_ind=1
    AND taa.task_status_cd IN (task_status_pending_cd, task_status_bogus_cd)
    AND psn.person_id=ta.person_id
    AND psn.active_ind=1
    AND encntr.encntr_id=ta.encntr_id
    AND ((encntr.active_ind=1) OR (ta.encntr_id=0))
    AND encntr.active_ind=1
    AND ((encntr.person_id=ta.person_id) OR (ta.encntr_id=0))
    AND ce.event_id=ta.event_id
    AND ce.entry_mode_cd=power_form_entry_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  WITH nocounter
 ;end insert
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 INSERT  FROM temp_entrymode_task_activity temp
  (temp.task_id)(SELECT
   ta.task_id
   FROM task_activity ta,
    task_activity_assignment taa,
    person psn,
    encounter encntr,
    clinical_event ce
   WHERE ta.active_ind=1
    AND ta.task_type_cd=task_type_cd
    AND ta.task_status_cd IN (task_status_pending_cd, task_status_bogus_cd)
    AND ta.task_activity_cd=task_activity_cd_saved_doc
    AND ta.task_id BETWEEN mf_min_id AND mf_max_id
    AND taa.task_id=ta.task_id
    AND taa.active_ind=1
    AND taa.task_status_cd IN (task_status_pending_cd, task_status_bogus_cd)
    AND psn.person_id=ta.person_id
    AND psn.active_ind=1
    AND encntr.encntr_id=ta.encntr_id
    AND ((encntr.active_ind=1) OR (ta.encntr_id=0))
    AND encntr.active_ind=1
    AND ((encntr.person_id=ta.person_id) OR (ta.encntr_id=0))
    AND ce.event_id=ta.event_id
    AND ce.entry_mode_cd=wkfdoccomp_entry_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  WITH nocounter
 ;end insert
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 UPDATE  FROM task_activity_assignment taa
  SET taa.active_ind = 0, taa.task_status_cd = task_status_deleted_cd, taa.updt_cnt = (taa.updt_cnt+
   1),
   taa.updt_dt_tm = cnvtdatetime(sysdate), taa.updt_id = reqinfo->updt_id, taa.updt_applctx = reqinfo
   ->updt_applctx,
   taa.updt_task = reqinfo->updt_task
  WHERE  EXISTS (
  (SELECT
   temp.task_id
   FROM temp_entrymode_task_activity temp
   WHERE temp.task_id=taa.task_id))
  WITH nocounter
 ;end update
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 UPDATE  FROM task_activity ta
  SET ta.active_ind = 0, ta.task_status_cd = task_status_deleted_cd, ta.updt_cnt = (ta.updt_cnt+ 1),
   ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->updt_id, ta.updt_applctx = reqinfo->
   updt_applctx,
   ta.updt_task = reqinfo->updt_task
  WHERE  EXISTS (
  (SELECT
   temp.task_id
   FROM temp_entrymode_task_activity temp
   WHERE temp.task_id=ta.task_id))
  WITH nocounter
 ;end update
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 CALL echo("Processing...Completed")
 IF (sbr_upd_id_evaluated(mf_max_id,ms_child_c_info_domain_nm,ms_child_c_max_name)=0)
  GO TO exit_program
 ENDIF
#exit_program
END GO
