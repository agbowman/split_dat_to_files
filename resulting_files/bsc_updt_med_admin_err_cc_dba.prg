CREATE PROGRAM bsc_updt_med_admin_err_cc:dba
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
 SET ms_child_c_info_domain_nm = "UPDATE ADMIN ERR - ERROR_ID"
 SET ms_child_c_max_name = "MAX ADMIN ERROR_ID EVALUATED"
 CALL sbr_get_min_max(mf_min_id,mf_max_id)
 CALL echo(concat("MIN: ",cnvtstring(mf_min_id)))
 CALL echo(concat("MAX: ",cnvtstring(mf_max_id)))
 CALL echo("Processing...")
 CALL echo("Updating the MED_ADMIN_MED_ERROR table")
 CALL parser(
  "rdb asis(^update  /*+  CERNER_README<BSC_UPDT_MED_ADMIN_ERR_C:Q1> */ med_admin_med_error mame^)")
 CALL parser("asis(^ set (mame.template_order_id, mame.needs_verify_flag, mame.verified_prsnl_id,^)")
 CALL parser(
  "asis(^ mame.verification_dt_tm,mame.verification_tz, mame.updt_task, mame.updt_dt_tm ) = ^)")
 CALL parser("asis(^ (select ^)")
 CALL parser("asis(^ m.template_order_id,^)")
 CALL parser(
  "asis(^ nvl(decode(oa.needs_verify_ind, 2, 1, 1, oa.needs_verify_ind, 0, oa.needs_verify_ind,^)")
 CALL parser(
  "asis(^ med_admin_event_orv_val_1(m.template_order_id, m.action_seq,m.event_dt_tm,oa.needs_verify_ind, 'FLAG')),0.0),^)"
  )
 CALL parser("asis(^ nvl(decode(oa.needs_verify_ind, 0, oa.action_personnel_id, 1, 0, 4, 0,^)")
 CALL parser(
  "asis(^ med_admin_event_orv_val_1(m.template_order_id, m.action_seq,m.event_dt_tm,oa.needs_verify_ind, 'PRSNL')),0.0),^)"
  )
 CALL parser("asis(^ nvl(decode(oa.needs_verify_ind, 0, oa.action_dt_tm, 1, NULL,  4, NULL,^)")
 CALL parser(
  "asis(^ med_admin_event_orv_date_1(m.template_order_id, m.action_seq,m.event_dt_tm,oa.needs_verify_ind, 'DATE')),NULL),^)"
  )
 CALL parser("asis(^ nvl(decode(oa.needs_verify_ind, 0, oa.action_tz, 1, 0, 4, 0,^)")
 CALL parser(
  "asis(^ med_admin_event_orv_val_1(m.template_order_id, m.action_seq,m.event_dt_tm,oa.needs_verify_ind, 'TZONE')),0.0),^)"
  )
 CALL parser(concat("asis(^  ",cnvtstring(reqinfo->updt_task),",^)"))
 CALL parser("asis(^        sysdate^)")
 CALL parser("asis(^ from order_action oa, ^)")
 CALL parser("asis(^ ((select mame.med_admin_med_error_id as med_admin_med_error_id,^)")
 CALL parser(
  "asis(^ decode(o.template_order_id,0.0,o.order_id,o.template_order_id) as template_order_id,^)")
 CALL parser("asis(^ mame.action_sequence as action_seq,^)")
 CALL parser("asis(^ mame.admin_dt_tm as event_dt_tm ^)")
 CALL parser("asis(^ from med_admin_med_error mame, orders o^)")
 CALL parser("asis(^ where mame.template_order_id = 0.0^)")
 CALL parser("asis(^ and mame.order_id > 0.0^)")
 CALL parser("asis(^ and o.order_id = mame.order_id) )m^)")
 CALL parser("asis(^ where oa.order_id (+)= m.template_order_id^)")
 CALL parser("asis(^ and oa.action_sequence (+)= m.action_seq^)")
 CALL parser("asis(^ and m.med_admin_med_error_id = mame.med_admin_med_error_id)^)")
 CALL parser("asis(^ where mame.med_admin_med_error_id in (select m2.med_admin_med_error_id ^)")
 CALL parser("asis(^ from order_action oa2, ^)")
 CALL parser("asis(^ ((select mame2.med_admin_med_error_id as med_admin_med_error_id,^)")
 CALL parser("asis(^ decode(o2.template_order_id,0.0,o2.order_id,^)")
 CALL parser("asis(^ o2.template_order_id) as   template_order_id,^)")
 CALL parser("asis(^ mame2.action_sequence as action_seq^)")
 CALL parser("asis(^ from med_admin_med_error mame2, orders o2^)")
 CALL parser(concat("asis(^ where mame2.med_admin_med_error_id >=",cnvtstring(mf_min_id),"^)"))
 CALL parser(concat("asis(^ and mame2.med_admin_med_error_id <=",cnvtstring(mf_max_id),"^)"))
 CALL parser("asis(^ and mame2.template_order_id = 0.0^)")
 CALL parser("asis(^	and mame2.order_id != 0.0^)")
 CALL parser("asis(^ and o2.order_id = mame2.order_id) )m2^)")
 CALL parser("asis(^ where oa2.order_id(+) = m2.template_order_id^)")
 CALL parser("asis(^ and oa2.action_sequence(+) = m2.action_seq)^) go")
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 CALL echo("Processing...Completed")
 IF (sbr_upd_id_evaluated(mf_max_id,ms_child_c_info_domain_nm,ms_child_c_max_name)=0)
  GO TO exit_program
 ENDIF
#exit_program
END GO
