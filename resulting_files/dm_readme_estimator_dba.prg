CREATE PROGRAM dm_readme_estimator:dba
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
 IF ( NOT (validate(rb_data,0)))
  FREE SET rb_data
  RECORD rb_data(
    1 in_house = i2
    1 batch_dt_tm = dq8
    1 env_id = f8
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
    1 readme[*]
      2 id = i4
      2 instance = i4
      2 name = vc
      2 description = vc
      2 ocd = i4
      2 driver_table = vc
      2 driver_count = i4
      2 estimated_time = f8
      2 skip = i2
      2 execution = vc
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 IF (validate(dm2_rr_misc->dm2_toolset_usage," ")=" "
  AND validate(dm2_rr_misc->dm2_toolset_usage,"1")="1")
  FREE RECORD dm2_rr_misc
  RECORD dm2_rr_misc(
    1 dm2_toolset_usage = vc
    1 readme_errors_ind = i2
    1 env_id = f8
    1 batch_dt_tm = dq8
    1 process_type = c2
    1 package_number = i4
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
  )
  SET dm2_rr_misc->dm2_toolset_usage = "NOT_SET"
  SET dm2_rr_misc->readme_errors_ind = 0
  SET dm2_rr_misc->env_id = 0.0
  SET dm2_rr_misc->batch_dt_tm = cnvtdatetimeutc("01-JAN-1800")
  SET dm2_rr_misc->process_type = ""
  SET dm2_rr_misc->package_number = 0
  SET dm2_rr_misc->execution = "NOT_SET"
  SET dm2_rr_misc->low_proj_name = ""
  SET dm2_rr_misc->high_proj_name = ""
 ENDIF
 IF ((validate(dm2_rr_spcchk->readme_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spcchk->readme_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spcchk
  RECORD dm2_rr_spcchk(
    1 space_needed = i2
    1 preup_space_needed = i2
    1 readme_cnt = i4
    1 readme_list[*]
      2 readme_id = f8
      2 spcchk_readme_id = f8
      2 script = vc
      2 tbl_cnt = i4
      2 tbl_list[*]
        3 table_name = vc
        3 large_data_loaded = i2
        3 insert_row_cnt = f8
        3 col_updt_cnt = i4
        3 col_updt[*]
          4 update_row_cnt = f8
          4 column_name = vc
  )
  SET dm2_rr_spcchk->readme_cnt = 0
  SET dm2_rr_spcchk->preup_space_needed = 0
  SET dm2_rr_spcchk->space_needed = 0
 ENDIF
 IF ((validate(dm2_rr_spc_needs->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spc_needs->tbl_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spc_needs
  RECORD dm2_rr_spc_needs(
    1 space_needed = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 skip_ind = i2
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 col_updt_cnt = i4
      2 col_updt[*]
        3 update_row_cnt = f8
        3 column_name = vc
      2 tgt_idx = i4
      2 cur_idx = i4
      2 space_needed = f8
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tgt_idx = i4
        3 cur_idx = i4
        3 space_needed = f8
  )
  SET dm2_rr_spc_needs->tbl_cnt = 0
 ENDIF
 IF (validate(drr_readmes_to_run->readme_cnt,0)=0
  AND validate(drr_readmes_to_run->readme_cnt,1)=1)
  FREE RECORD drr_readmes_to_run
  RECORD drr_readmes_to_run(
    1 readme_cnt = i4
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 name = vc
      2 description = c50
      2 ocd = i4
      2 execution = vc
      2 execution_order = vc
      2 category = vc
      2 driver_table = vc
      2 execution_time = f8
      2 status = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 skip = i2
      2 driver_count = i4
      2 estimated_time = f8
      2 spchk_readme_cnt = i4
      2 spchk_readme[*]
        3 readme_id = f8
        3 instance = i4
        3 ocd = i4
        3 execution = vc
        3 script = vc
        3 skip = i2
    1 timer_readme_cnt = i4
    1 timer_readme[*]
      2 parent_readme_id = f8
      2 readme_id = f8
      2 instance = i4
      2 ocd = i4
      2 execution = vc
      2 script = vc
      2 skip = i2
    1 inactive_cnt = i4
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ((validate(dm2_rr_defined,- (1))=- (1))
  AND (validate(dm2_rr_defined,- (2))=- (2)))
  DECLARE dm2_rr_defined = i2 WITH public, constant(1)
  DECLARE dm2_rr_error = i2 WITH public, constant(0)
  DECLARE dm2_rr_warning = i2 WITH public, constant(1)
  DECLARE dm2_rr_info = i2 WITH public, constant(2)
  DECLARE dm2_rr_readme = vc WITH public, constant("README")
  DECLARE dm2_rr_dbimport = vc WITH public, constant("DBIMPORT")
  DECLARE dm2_rr_oracle = vc WITH public, constant("ORACLE")
  DECLARE dm2_rr_oracle_ref = vc WITH public, constant("ORACLEREF")
  DECLARE dm2_rr_ccl_dbimport = vc WITH public, constant("CCLDBIMPORT")
  DECLARE dm2_rr_tbl_import = vc WITH public, constant("TABLEIMPORT")
  DECLARE dm2_rr_readme_rback = vc WITH public, constant("README:RBACK")
  DECLARE dm2_rr_running = vc WITH public, constant("RUNNING")
  DECLARE dm2_rr_done = vc WITH public, constant("SUCCESS")
  DECLARE dm2_rr_failed = vc WITH public, constant("FAILED")
  DECLARE dm2_rr_reset = vc WITH public, constant("RESET")
  DECLARE dm2_rr_pre_schema_up = vc WITH public, constant("PREUP")
  DECLARE dm2_rr_post_schema_up = vc WITH public, constant("POSTUP")
  DECLARE dm2_rr_post_schema_up2 = vc WITH public, constant("POSTUP2")
  DECLARE dm2_rr_pre_cycle = vc WITH public, constant("PRECYCLE")
  DECLARE dm2_rr_pre_schema_down = vc WITH public, constant("PREDOWN")
  DECLARE dm2_rr_post_schema_down = vc WITH public, constant("POSTDOWN")
  DECLARE dm2_rr_uptime = vc WITH public, constant("UP")
  DECLARE dm2_rr_timer = vc WITH public, constant("RDMTIMER")
 ENDIF
 IF (validate(drr_killed_appl->appl_cnt,1)=1
  AND validate(drr_killed_appl->appl_cnt,2)=2)
  FREE RECORD drr_killed_appl
  RECORD drr_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET drr_killed_appl->appl_cnt = 0
 ENDIF
 DECLARE dm2_rr_toolset_usage(null) = i2
 DECLARE dm2_rr_clean_stranded_readmes(drcsr_env_id=f8) = i2
 DECLARE drr_load_readmes_to_run(null) = i2
 DECLARE drr_load_space_chk_readmes(dlscr_execution=vc,dlscr_spcchk_flag=i2(ref)) = i2
 DECLARE drr_load_timing_readmes(null) = i2
 DECLARE drr_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 SUBROUTINE dm2_rr_toolset_usage(null)
   DECLARE drtu_found_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_rr_misc->dm2_toolset_usage != "NOT_SET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (dm2_table_and_ccldef_exists("DM_INFO",drtu_found_ind)=0)
    RETURN(0)
   ENDIF
   IF (drtu_found_ind=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for DM_README_TOOLSET row."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_README_TOOLSET"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm2_rr_misc->dm2_toolset_usage = "N"
   ELSEIF (curqual=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rr_clean_stranded_readmes(drcsr_env_id)
   DECLARE rcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rcsr_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE rcsr_error_msg = vc WITH protect, noconstant(" ")
   DECLARE rcsr_load_ind = i2 WITH protect, noconstant(1)
   DECLARE rcsr_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rcsr_appl_rs
   RECORD rcsr_appl_rs(
     1 rcsr_appl_cnt = i4
     1 rcsr_appl[*]
       2 rcsr_appl_id = vc
       2 rcsr_validity = vc
   )
   SET dm_err->eproc = "Get distinct application ids."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    l.appl_ident
    FROM dm_ocd_log l
    WHERE l.environment_id=drcsr_env_id
     AND l.project_type=dm2_rr_readme
     AND ((l.status=dm2_rr_running) OR (l.status=null))
    HEAD REPORT
     rcsr_cnt = 0
    DETAIL
     rcsr_cnt = (rcsr_cnt+ 1)
     IF (mod(rcsr_cnt,10)=1)
      stat = alterlist(rcsr_appl_rs->rcsr_appl,(rcsr_cnt+ 9))
     ENDIF
     IF (isnumeric(l.appl_ident)=0)
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "INVALID"
     ELSE
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "VALID"
     ENDIF
     rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id = l.appl_ident
    FOOT REPORT
     rcsr_appl_rs->rcsr_appl_cnt = rcsr_cnt, stat = alterlist(rcsr_appl_rs->rcsr_appl,rcsr_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((rcsr_appl_rs->rcsr_appl_cnt > 0))
    SET rcsr_cnt = 0
    FOR (rcsr_cnt = 1 TO rcsr_appl_rs->rcsr_appl_cnt)
      IF ((rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity="INVALID"))
       SET rcsr_error_msg = "Session executing readme is no longer active"
       SET dm_err->eproc = "Update stranded readme process to failed."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_ocd_log l
        SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(l
           .start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
        WHERE l.environment_id=drcsr_env_id
         AND l.project_type=dm2_rr_readme
         AND ((l.status=dm2_rr_running) OR (l.status = null))
         AND ((l.appl_ident = null) OR ((l.appl_ident=rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
        ))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       CASE (dm2_get_appl_status(value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)))
        OF "I":
         SET dm_err->eproc = "Update inactive readme process to failed."
         SET rcsr_fmt_appl_id = rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id
         IF (drr_alert_killed_appl(rcsr_load_ind,rcsr_fmt_appl_id,rcsr_kill_ind)=0)
          RETURN(0)
         ENDIF
         SET rcsr_load_ind = 0
         IF (rcsr_kill_ind=1)
          SET rcsr_error_msg = dir_kill_clause
         ELSE
          SET rcsr_error_msg = "Session executing readme is no longer active."
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL disp_msg(" ",dm_err->logfile,0)
         ENDIF
         UPDATE  FROM dm_ocd_log l
          SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(
             l.start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
          WHERE l.environment_id=drcsr_env_id
           AND l.appl_ident=value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
           AND l.project_type=dm2_rr_readme
           AND ((l.status=dm2_rr_running) OR (l.status = null))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ELSE
          COMMIT
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Application Id ",rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 0))
          CALL echo("Error Detected in dm2_get_appl_status")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No application IDs associated with stranded readmes **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_readmes_to_run(null)
   DECLARE dlrr_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drr_readmes_on_pkg
   RECORD drr_readmes_on_pkg(
     1 cnt = i4
     1 qual[*]
       2 readme_id = f8
       2 instance = i4
       2 ocd = f8
       2 skip = i2
       2 run_once_ind = i2
       2 name = vc
       2 description = c50
       2 execution = vc
       2 category = vc
       2 driver_table = vc
       2 execution_time = f8
       2 skip = i2
       2 driver_count = i4
       2 estimated_time = f8
   )
   IF ((drr_readmes_to_run->readme_cnt > 0))
    SET drr_readmes_to_run->readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->readme,0)
   ENDIF
   IF ((drr_readmes_to_run->inactive_cnt > 0))
    SET drr_readmes_to_run->inactive_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->inactive,0)
   ENDIF
   IF ( NOT ((dm2_rr_misc->process_type IN ("PI", "IH", "MM"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->env_id=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment ID."
    SET dm_err->emsg = "Invalid environment_id."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->process_type="PI"))
    IF ((dm2_rr_misc->package_number=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating package number."
     SET dm_err->emsg =
     "Package number or batch number was 0.  Cannot process readmes for package install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ( NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
    "PREDOWN", "POSTDOWN", "UP"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating process type."
     SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="IH")
    AND ((cnvtint(dm2_rr_misc->low_proj_name) < 0) OR (cnvtint(dm2_rr_misc->high_proj_name) <= 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating inhouse project range."
    SET dm_err->emsg = "Invalid project range.  Cannot process inhouse readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ((dm2_rr_misc->process_type="MM")
    AND  NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "PREDOWN", "POSTDOWN",
   "UP"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET rdm_cnt = 0
   SET inactive_cnt = 0
   IF ((dm2_rr_misc->process_type="PI"))
    SET dm_err->eproc = "Gathering list of readmes on plan..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_readme o
     WHERE (o.ocd=dm2_rr_misc->package_number)
     ORDER BY o.readme_id
     DETAIL
      rdm_cnt = (rdm_cnt+ 1)
      IF (mod(rdm_cnt,100)=1)
       stat = alterlist(drr_readmes_on_pkg->qual,(rdm_cnt+ 99))
      ENDIF
      drr_readmes_on_pkg->qual[rdm_cnt].readme_id = o.readme_id, drr_readmes_on_pkg->qual[rdm_cnt].
      name = trim(cnvtstring(o.readme_id),3), drr_readmes_on_pkg->qual[rdm_cnt].ocd = o.ocd,
      drr_readmes_on_pkg->qual[rdm_cnt].instance = o.instance
     FOOT REPORT
      stat = alterlist(drr_readmes_on_pkg->qual,rdm_cnt), drr_readmes_on_pkg->cnt = rdm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((drr_readmes_on_pkg->cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (r
      WHERE r.owner=currdbuser
       AND (r.readme_id=drr_readmes_on_pkg->qual[d.seq].readme_id)
       AND (r.instance > drr_readmes_on_pkg->qual[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id)
       AND  NOT (a.inst_mode IN ("PREVIEW", "BATCHPREVIEW")))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       CALL echo(concat("Instance ",build(r.instance)," from ",build(o.ocd)," for readme ",
        build(o.readme_id)," will be skipped due to being inactive on highest instance.")),
       drr_readmes_on_pkg->qual[d.seq].skip = 1
      ELSE
       CALL echo(concat("Replacing Instance ",build(drr_readmes_on_pkg->qual[d.seq].instance),
        " with instance ",build(r.instance)," from ",
        build(o.ocd)," for readme ",build(o.readme_id))), drr_readmes_on_pkg->qual[d.seq].instance =
       r.instance, drr_readmes_on_pkg->qual[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Marking completed readmes as SKIPPED."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND (l.ocd=drr_readmes_on_pkg->qual[d.seq].ocd)
       AND l.status=dm2_rr_done
       AND l.active_ind=1)
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Loading readme metadata."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_readme r,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0))
      JOIN (r
      WHERE (drr_readmes_on_pkg->qual[d.seq].readme_id=r.readme_id)
       AND (drr_readmes_on_pkg->qual[d.seq].instance=r.instance)
       AND r.owner=currdbuser)
     ORDER BY r.readme_id
     HEAD r.readme_id
      drr_readmes_on_pkg->qual[d.seq].readme_id = r.readme_id, drr_readmes_on_pkg->qual[d.seq].
      instance = r.instance, drr_readmes_on_pkg->qual[d.seq].name = trim(cnvtstring(r.readme_id),3),
      drr_readmes_on_pkg->qual[d.seq].execution = cnvtupper(trim(r.execution,3)), drr_readmes_on_pkg
      ->qual[d.seq].description = r.description, drr_readmes_on_pkg->qual[d.seq].driver_table =
      cnvtupper(trim(r.driver_table,3)),
      drr_readmes_on_pkg->qual[d.seq].execution_time = r.execution_time, drr_readmes_on_pkg->qual[d
      .seq].run_once_ind = r.run_once_ind, drr_readmes_on_pkg->qual[d.seq].estimated_time = 0,
      drr_readmes_on_pkg->qual[d.seq].driver_count = 0, drr_readmes_on_pkg->qual[d.seq].skip =
      evaluate(r.active_ind,0,1,0)
      IF ((drr_readmes_on_pkg->qual[d.seq].skip=1))
       CALL echo(concat("Skipping inactive readme ",build(r.readme_id)," instance ",build(r.instance)
        ))
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Skipping RUN ONCE Readmes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0)
       AND (drr_readmes_on_pkg->qual[d.seq].run_once_ind=1))
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND l.status=dm2_rr_done
       AND l.active_ind=1
       AND (l.project_instance=drr_readmes_on_pkg->qual[d.seq].instance))
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_on_pkg)
    ENDIF
    SET rdm_cnt = 0
    FOR (dlrr_cnt = 1 TO drr_readmes_on_pkg->cnt)
      IF ((((dm2_rr_misc->execution != "ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution=dm2_rr_misc->execution)) OR ((dm2_rr_misc->
      execution="ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution IN ("PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
      "PREDOWN",
      "POSTDOWN", "UP")))) )
       IF ((drr_readmes_on_pkg->qual[dlrr_cnt].skip=1)
        AND (drr_readmes_on_pkg->qual[dlrr_cnt].run_once_ind=1))
        CALL echo(concat("Skip run once readme:",drr_readmes_on_pkg->qual[dlrr_cnt].name))
       ELSE
        SET rdm_cnt = (rdm_cnt+ 1)
        SET stat = alterlist(drr_readmes_to_run->readme,rdm_cnt)
        SET drr_readmes_to_run->readme[rdm_cnt].readme_id = drr_readmes_on_pkg->qual[dlrr_cnt].
        readme_id
        SET drr_readmes_to_run->readme[rdm_cnt].instance = drr_readmes_on_pkg->qual[dlrr_cnt].
        instance
        SET drr_readmes_to_run->readme[rdm_cnt].name = drr_readmes_on_pkg->qual[dlrr_cnt].name
        SET drr_readmes_to_run->readme[rdm_cnt].execution = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution
        SET drr_readmes_to_run->readme[rdm_cnt].description = drr_readmes_on_pkg->qual[dlrr_cnt].
        description
        SET drr_readmes_to_run->readme[rdm_cnt].ocd = drr_readmes_on_pkg->qual[dlrr_cnt].ocd
        SET drr_readmes_to_run->readme[rdm_cnt].driver_table = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_table
        SET drr_readmes_to_run->readme[rdm_cnt].execution_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution_time
        SET drr_readmes_to_run->readme[rdm_cnt].estimated_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        estimated_time
        SET drr_readmes_to_run->readme[rdm_cnt].driver_count = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_count
        SET drr_readmes_to_run->readme[rdm_cnt].skip = drr_readmes_on_pkg->qual[dlrr_cnt].skip
        SET drr_readmes_to_run->readme_cnt = rdm_cnt
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_to_run)
    ENDIF
    IF ((drr_readmes_to_run->readme_cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET rdm_cnt = 0
    FOR (rdm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
      IF ((drr_readmes_to_run->readme[rdm_cnt].skip=0))
       CALL echo(concat("Readme ",build(drr_readmes_to_run->readme[rdm_cnt].readme_id)," will run."))
      ENDIF
    ENDFOR
   ELSEIF ((dm2_rr_misc->process_type="IH"))
    SET dm_err->eproc = "Getting list of readmes for inhouse processing."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     r.readme_id
     FROM dm_project_status_env s,
      dm_readme r
     PLAN (s
      WHERE (s.environment_id=dm2_rr_misc->env_id)
       AND s.proj_type=dm2_rr_readme
       AND cnvtint(s.proj_name) > 0
       AND s.proj_name BETWEEN dm2_rr_misc->low_proj_name AND dm2_rr_misc->high_proj_name
       AND s.dm_status = null)
      JOIN (r
      WHERE r.readme_id=cnvtint(s.proj_name)
       AND r.instance=s.source_set_instance
       AND r.owner=currdbuser)
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind)
       rdm_cnt = (rdm_cnt+ 1)
       IF (mod(rdm_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
       ENDIF
       drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
       rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
         .readme_id),3),
       drr_readmes_to_run->readme[rdm_cnt].execution = cnvtupper(trim(r.execution,3)),
       drr_readmes_to_run->readme[rdm_cnt].description = trim(r.description,3), drr_readmes_to_run->
       readme[rdm_cnt].driver_table = cnvtupper(trim(r.driver_table,3)),
       drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
       readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       IF ((drr_readmes_to_run->readme[rdm_cnt].execution IN ("PRESPCHK", "POSTSPCHK", "RDMTIMER")))
        drr_readmes_to_run->readme[rdm_cnt].skip = 1
       ENDIF
      ELSE
       inactive_cnt = (inactive_cnt+ 1)
       IF (mod(inactive_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->inactive,(inactive_cnt+ 9))
       ENDIF
       drr_readmes_to_run->inactive[inactive_cnt].name = trim(cnvtstring(r.readme_id),3),
       drr_readmes_to_run->inactive[inactive_cnt].instance = r.instance
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_readmes_to_run->inactive,inactive_cnt), stat = alterlist(
       drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt,
      drr_readmes_to_run->inactive_cnt = inactive_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="MM"))
    SET dm_err->eproc = "Gathering list of readmes to run..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (validate(doc->source_ocd_cnt,- (1)) > 0)
     SELECT INTO "nl:"
      FROM dm_ocd_readme o,
       dm_readme r,
       (dummyt d  WITH seq = value(doc->source_ocd_cnt))
      PLAN (d)
       JOIN (o
       WHERE (o.ocd=doc->qual[d.seq].ocd_nbr))
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        l.project_name
        FROM dm_ocd_log l,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (l.environment_id=dm2_rr_misc->env_id)
         AND l.project_type=dm2_rr_readme
         AND l.ocd > 0
         AND l.project_name=trim(cnvtstring(x.readme_id),3)
         AND l.project_instance >= r.instance
         AND l.status=dm2_rr_done
         AND l.active_ind=1))))
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD REPORT
       row + 0
      HEAD r.readme_id
       IF (r.active_ind=1
        AND (r.execution=dm2_rr_misc->execution))
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
          .readme_id),3),
        drr_readmes_to_run->readme[rdm_cnt].description = r.description, drr_readmes_to_run->readme[
        rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].driver_table = cnvtupper(trim(r
          .driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Marking completed readmes as SKIPPED."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      l.status
      FROM dm_ocd_log l,
       (dummyt d  WITH seq = value(rdm_cnt))
      PLAN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND (l.project_name=drr_readmes_to_run->readme[d.seq].name)
        AND (l.ocd=drr_readmes_to_run->readme[d.seq].ocd)
        AND l.status=dm2_rr_done
        AND l.active_ind=1)
      DETAIL
       drr_readmes_to_run->readme[d.seq].skip = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
       cnvtdatetime(curdate,curtime)), end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,
        curtime))
      FROM dm_alpha_features_env a,
       dm_ocd_readme o,
       dm_readme r,
       dm_ocd_log l,
       dummyt d
      PLAN (a
       WHERE (a.environment_id=dm2_rr_misc->env_id)
        AND a.curr_migration_ind=1)
       JOIN (o
       WHERE o.ocd=a.alpha_feature_nbr)
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        m.project_name
        FROM dm_ocd_log m,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (m.environment_id=dm2_rr_misc->env_id)
         AND m.project_type=dm2_rr_readme
         AND m.project_name=trim(cnvtstring(x.readme_id),3)
         AND m.status=dm2_rr_done
         AND m.ocd != o.ocd))))
       JOIN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND trim(cnvtstring(r.readme_id),3)=l.project_name
        AND l.ocd=o.ocd
        AND l.project_instance=r.instance)
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD r.readme_id
       IF (r.active_ind=1)
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].description = trim(r
         .description),
        drr_readmes_to_run->readme[rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].
        execution = cnvtupper(trim(r.execution,3)), drr_readmes_to_run->readme[rdm_cnt].driver_table
         = cnvtupper(trim(r.driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].status = status, drr_readmes_to_run->readme[rdm_cnt].start_dt_tm =
        start_dt_tm,
        drr_readmes_to_run->readme[rdm_cnt].end_dt_tm = end_dt_tm, drr_readmes_to_run->readme[rdm_cnt
        ].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter, outerjoin = d
     ;end select
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_space_chk_readmes(dlscr_execution,dlscr_spcchk_flag)
   DECLARE dlscr_dyn_where = vc WITH protect, noconstant("")
   IF (dlscr_execution="ALL")
    SET dlscr_dyn_where = "r.execution in ('PRESPCHK', 'POSTSPCHK')"
   ELSE
    SET dlscr_dyn_where = concat('r.execution = "',trim(dlscr_execution),'"')
   ENDIF
   SET dm_err->eproc = "Find readmes that require space check."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_readme r,
     dm_ocd_readme o,
     dm_alpha_features_env a,
     (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    PLAN (d
     WHERE (drr_readmes_to_run->readme[d.seq].skip=0))
     JOIN (r
     WHERE (r.parent_readme_id=drr_readmes_to_run->readme[d.seq].readme_id)
      AND parser(dlscr_dyn_where)
      AND r.owner=currdbuser)
     JOIN (o
     WHERE o.readme_id=r.readme_id
      AND o.ocd > 0
      AND o.instance=r.instance)
     JOIN (a
     WHERE a.alpha_feature_nbr=o.ocd
      AND (a.environment_id=dm2_rr_misc->env_id))
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD r.readme_id
     IF (r.active_ind=1)
      dlscr_spcchk_flag = 1, drr_readmes_to_run->readme[d.seq].spchk_readme_cnt = (drr_readmes_to_run
      ->readme[d.seq].spchk_readme_cnt+ 1), stat = alterlist(drr_readmes_to_run->readme[d.seq].
       spchk_readme,drr_readmes_to_run->readme[d.seq].spchk_readme_cnt),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].instance = r.instance, drr_readmes_to_run->
      readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].ocd = o.ocd,
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].execution = r.execution, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].script = cnvtupper(r.script),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].skip = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_timing_readmes(null)
   SET dm_err->eproc = "Gathering timing readme data"
   CALL disp_msg("",dm_err->logfile,0)
   SET timer_cnt = 0
   IF ((drr_readmes_to_run->timer_readme_cnt > 0))
    SET drr_readmes_to_run->timer_readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->timer_readme,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme o,
     dm_readme r
    PLAN (o
     WHERE (o.ocd=dm2_rr_misc->package_number))
     JOIN (r
     WHERE r.owner=currdbuser
      AND r.readme_id=o.readme_id
      AND r.instance=o.instance
      AND r.execution="RDMTIMER")
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD REPORT
     row + 0
    HEAD r.readme_id
     IF (r.active_ind=1)
      timer_cnt = (timer_cnt+ 1)
      IF (mod(timer_cnt,10)=1)
       stat = alterlist(drr_readmes_to_run->timer_readme,(timer_cnt+ 9))
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].readme_id = r.readme_id
      IF (r.parent_readme_id > 0)
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = r.parent_readme_id
      ELSE
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = 0
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].instance = r.instance, drr_readmes_to_run->
      timer_readme[timer_cnt].ocd = o.ocd, drr_readmes_to_run->timer_readme[timer_cnt].execution = r
      .execution,
      drr_readmes_to_run->timer_readme[timer_cnt].script = cnvtupper(r.script), drr_readmes_to_run->
      timer_readme[timer_cnt].skip = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_readmes_to_run->timer_readme,timer_cnt), drr_readmes_to_run->
     timer_readme_cnt = timer_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find highest instance of timing readmes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drr_readmes_to_run->timer_readme_cnt=0))
    SET dm_err->eproc = "No Category 8 readmes found to run."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt))
     PLAN (d)
      JOIN (r
      WHERE (r.readme_id=drr_readmes_to_run->timer_readme[d.seq].readme_id)
       AND (r.instance > drr_readmes_to_run->timer_readme[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       drr_readmes_to_run->timer_readme[d.seq].skip = 1
      ELSE
       drr_readmes_to_run->timer_readme[d.seq].instance = r.instance, drr_readmes_to_run->
       timer_readme[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Update skip flag on timing readmes"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt)),
      (dummyt d2  WITH seq = value(drr_readmes_to_run->readme_cnt))
     PLAN (d
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id > 0))
      JOIN (d2
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id=drr_readmes_to_run->readme[d2
      .seq].readme_id))
     DETAIL
      drr_readmes_to_run->timer_readme[d.seq].skip = drr_readmes_to_run->readme[d2.seq].skip
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      drr_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       drr_killed_appl->appl_cnt += 1
       IF (mod(drr_killed_appl->appl_cnt,10)=1)
        stat = alterlist(drr_killed_appl->appl,(drr_killed_appl->appl_cnt+ 9))
       ENDIF
       drr_killed_appl->appl[drr_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_killed_appl->appl,drr_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,drr_killed_appl->appl_cnt,daka_fmt_appl_id,
     drr_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dir_sea_sch_files(directory=vc,file_prefix=vc,schema_date=vc(ref)) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_get_suffixed_tablename(tbl_name=vc) = i2
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_toolset_usage(null) = i2
 DECLARE dir_get_obsolete_objects(null) = i2
 DECLARE dir_find_data_file(dfdf_file_found=i2(ref)) = i2
 DECLARE dir_dm2_tables_tspace_assign(null) = i2
 DECLARE dir_get_debug_trace_data(null) = i2
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
 DECLARE dir_get_storage_type(dgst_db_link=vc) = i2
 DECLARE dir_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE dir_get_ddl_gen_retry(dgr_retry_ceiling=i2(ref)) = i2
 DECLARE dir_load_users_pwds(dlup_user_pwd=vc) = i2
 DECLARE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution=i2(ref),dcdosa_install_mode=vc) = i2
 DECLARE dir_check_for_package(dcfp_valid_ind=i2(ref),dcfp_env_id=f8(ref)) = i2
 DECLARE dir_get_dg_data(dgdd_assign_dg_ind=i2,dgdd_dg_override=vc,dgdd_dg_out=vc(ref)) = i2
 DECLARE dir_submit_jobs(dsj_plan_id=f8,dsj_install_mode=vc,dsj_user=vc,dsj_pword=vc,dsj_cnnct_str=vc,
  dsj_queue_name=vc,dsj_background_ind=i2) = i2
 DECLARE dir_get_adm_appl_status(dgaps_dblink=vc,dgaps_audsid=vc,dgaps_status=vc(ref)) = i2
 DECLARE dir_upd_adm_upgrade_info(null) = i2
 DECLARE dir_get_custom_constraints(null) = i2
 DECLARE dir_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 DECLARE dir_get_admin_db_link(dgadl_report_fail_ind=i2,dgadl_admin_db_link=vc(ref),dgadl_fail_ind=i2
  (ref)) = i2
 IF (validate(dm2_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_rdbms_version
  RECORD dm2_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
 ENDIF
 DECLARE dm2_get_rdbms_version() = i2
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT
    IF (currdbver < 19)
     FROM (
      (
      (SELECT
       orcl_version = t1.version
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC80")))
      t)
    ELSE
     FROM (
      (
      (SELECT
       orcl_version = t1.version_full
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC160")))
      t)
    ENDIF
    INTO "nl:"
    DETAIL
     dm2_rdbms_version->version = t.orcl_version
    WITH nocounter
   ;end select
   IF (check_error("Getting product component version")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Product component version not found."
    SET dm_err->eproc = "Getting product component version"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   WHILE (dgrv_loop=0)
     SET dgrv_level = (dgrv_level+ 1)
     SET dgrv_prev_loc = dgrv_loc
     SET dgrv_loc = 0
     SET dgrv_loc = findstring(".",dm2_rdbms_version->version,(dgrv_prev_loc+ 1),0)
     IF (((dgrv_loc > 0) OR (dgrv_loc=0
      AND dgrv_level > 1)) )
      IF (dgrv_loc=0
       AND dgrv_level > 1)
       SET dgrv_len = (textlen(dm2_rdbms_version->version) - dgrv_prev_loc)
       SET dgrv_loop = 1
      ELSE
       SET dgrv_len = ((dgrv_loc - dgrv_prev_loc) - 1)
      ENDIF
      CASE (dgrv_level)
       OF 1:
        SET dm2_rdbms_version->level1 = cnvtint(substring(1,dgrv_len,dm2_rdbms_version->version))
       OF 2:
        SET dm2_rdbms_version->level2 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 3:
        SET dm2_rdbms_version->level3 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 4:
        SET dm2_rdbms_version->level4 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 5:
        SET dm2_rdbms_version->level5 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       ELSE
        SET dgrv_loop = 1
      ENDCASE
     ELSE
      IF (dgrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET dgrv_loop = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
    1 lob_securefile_ind = vc
    1 lob_retention = vc
    1 lob_maxsize = vc
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
    1 add_nn_col_nobf_ind = vc
    1 create_index_invisible = vc
    1 use_initprm_assign_dg_ind = vc
    1 assign_dg_override = vc
    1 degree_of_parallel_max = vc
    1 degree_of_parallel = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
  SET dm2_db_options->table_monitoring = "NOT_SET"
  SET dm2_db_options->table_monitoring_maxretry = "NOT_SET"
  SET dm2_db_options->db_optimizer_category = "NOT_SET"
  SET dm2_db_options->dbstats_gather_method = "NOT_SET"
  SET dm2_db_options->cbf_maxrangegroups = "NOT_SET"
  SET dm2_db_options->resource_busy_maxretry = "NOT_SET"
  SET dm2_db_options->dbstats_chk_rpt = "NOT_SET"
  SET dm2_db_options->readme_space_calc = "NOT_SET"
  SET dm2_db_options->recompile_after_alter_tbl = "NOT_SET"
  SET dm2_db_options->add_nn_col_nobf_ind = "NOT_SET"
  SET dm2_db_options->create_index_invisible = "NOT_SET"
  SET dm2_db_options->lob_securefile_ind = "NOT_SET"
  SET dm2_db_options->lob_retention = "NOT_SET"
  SET dm2_db_options->lob_maxsize = "NOT_SET"
  SET dm2_db_options->use_initprm_assign_dg_ind = "NOT_SET"
  SET dm2_db_options->assign_dg_override = "NOT_SET"
  SET dm2_db_options->degree_of_parallel_max = "NOT_SET"
  SET dm2_db_options->degree_of_parallel = "NOT_SET"
 ENDIF
 IF (validate(dm2_table->full_table_name," ")=" ")
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF ((validate(dm2_install_rec->snapshot_dt_tm,- (1))=- (1)))
  FREE RECORD dm2_install_rec
  RECORD dm2_install_rec(
    1 snapshot_dt_tm = f8
  )
 ENDIF
 IF (validate(dir_install_misc->ddl_failed_ind,1)=1
  AND validate(dir_install_misc->ddl_failed_ind,2)=2)
  FREE RECORD dir_install_misc
  RECORD dir_install_misc(
    1 ddl_failed_ind = i2
  )
  SET dir_install_misc->ddl_failed_ind = 0
 ENDIF
 IF ((validate(dir_silmode_requested_ind,- (1))=- (1))
  AND (validate(dir_silmode_requested_ind,- (2))=- (2)))
  DECLARE dir_silmode_requested_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dir_silmode->cnt,1)=1
  AND validate(dir_silmode->cnt,2)=2)
  FREE RECORD dir_silmode
  RECORD dir_silmode(
    1 cnt = i4
    1 qual[*]
      2 name = vc
      2 filename = vc
  )
  SET dir_silmode->cnt = 0
 ENDIF
 IF (validate(dir_batch_queue,"X")="X"
  AND validate(dir_batch_queue,"Y")="Y")
  DECLARE dir_batch_queue = vc WITH public, constant(cnvtlower(build("INSTALL$",logical("environment"
      ))))
 ENDIF
 IF (validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,1.0)=1.0
  AND validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,2.0)=2.0)
  FREE RECORD dm_ocd_setup_admin_data
  RECORD dm_ocd_setup_admin_data(
    1 dm_ocd_setup_admin_date = dq8
    1 dm2_create_system_defs = dq8
    1 dm2_set_adm_cbo = f8
  )
 ENDIF
 IF ((validate(dir_obsolete_objects->tbl_cnt,- (2))=- (2))
  AND (validate(dir_obsolete_objects->tbl_cnt,- (1))=- (1)))
  FREE RECORD dir_obsolete_objects
  RECORD dir_obsolete_objects(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
    1 ind_cnt = i4
    1 ind[*]
      2 index_name = vc
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(dir_dropped_objects->obj_cnt,- (1))=- (1))
  AND (validate(dir_dropped_objects->obj_cnt,- (2))=- (2)))
  FREE RECORD dir_dropped_objects
  RECORD dir_dropped_objects(
    1 obj_cnt = i4
    1 rpt_drp_obj_ind = i2
    1 obj[*]
      2 table_name = vc
      2 name = vc
      2 type = vc
      2 reason = vc
  )
 ENDIF
 IF ((validate(dir_env_maint_rs->src_env_id,- (1))=- (1))
  AND (validate(dir_env_maint_rs->src_env_id,- (2))=- (2)))
  FREE RECORD dir_env_maint_rs
  RECORD dir_env_maint_rs(
    1 src_env_id = f8
    1 tgt_env_id = f8
    1 tgt_hist_fnd = i2
    1 process = vc
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
  SET dir_env_maint_rs->process = "DM2NOTSET"
 ENDIF
 IF (validate(dir_tools_tspaces->data_tspace,"X")="X"
  AND validate(dir_tools_tspaces->data_tspace,"Y")="Y")
  FREE RECORD dir_tools_tspaces
  RECORD dir_tools_tspaces(
    1 data_tspace = vc
    1 index_tspace = vc
    1 lob_tspace = vc
  )
  SET dir_tools_tspaces->data_tspace = "NONE"
  SET dir_tools_tspaces->index_tspace = "NONE"
  SET dir_tools_tspaces->lob_tspace = "NONE"
 ENDIF
 IF (validate(dir_managed_ddl->setup_complete,1)=1
  AND validate(dir_managed_ddl->setup_complete,2)=2)
  FREE RECORD dir_managed_ddl
  RECORD dir_managed_ddl(
    1 setup_complete = i2
    1 managed_ddl_ind = i2
    1 oraversion = vc
    1 priority_cnt = i4
    1 priorities[*]
      2 priority = i4
    1 table_cnt = i4
    1 tables[*]
      2 table_name = vc
  )
  SET dir_managed_ddl->setup_complete = 0
  SET dir_managed_ddl->managed_ddl_ind = 0
  SET dir_managed_ddl->oraversion = "DM2NOTSET"
  SET dir_managed_ddl->priority_cnt = 0
  SET dir_managed_ddl->table_cnt = 0
 ENDIF
 IF (validate(dir_ui_misc->dm_process_event_id,1)=1
  AND validate(dir_ui_misc->dm_process_event_id,2)=2)
  FREE RECORD dir_ui_misc
  RECORD dir_ui_misc(
    1 dm_process_event_id = f8
    1 parent_script_name = vc
    1 background_ind = i2
    1 install_status = i2
    1 auto_install_ind = i2
    1 tspace_dg = vc
    1 debug_level = i4
    1 trace_flag = i2
  )
 ENDIF
 IF (validate(dir_storage_misc->src_storage_type,"x")="x"
  AND validate(dir_storage_misc->src_storage_type,"y")="y")
  FREE RECORD dir_storage_misc
  RECORD dir_storage_misc(
    1 src_storage_type = vc
    1 tgt_storage_type = vc
    1 cur_storage_type = vc
  )
  SET dir_storage_misc->src_storage_type = "DM2NOTSET"
  SET dir_storage_misc->tgt_storage_type = "DM2NOTSET"
  SET dir_storage_misc->cur_storage_type = "DM2NOTSET"
 ENDIF
 IF (validate(dir_db_users_pwds->cnt,1)=1
  AND validate(dir_db_users_pwds->cnt,2)=2)
  FREE RECORD dir_db_users_pwds
  RECORD dir_db_users_pwds(
    1 cnt = i4
    1 qual[*]
      2 user = vc
      2 pwd = vc
  )
  SET dir_db_users_pwds->cnt = 0
 ENDIF
 IF (validate(dir_custom_constraints->con_cnt,1)=1
  AND validate(dir_custom_constraints->con_cnt,2)=2)
  FREE RECORD dir_custom_constraints
  RECORD dir_custom_constraints(
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
  SET dir_custom_constraints->con_cnt = 0
 ENDIF
 IF (validate(dir_killed_appl->appl_cnt,1)=1
  AND validate(dir_killed_appl->appl_cnt,2)=2)
  FREE RECORD dir_killed_appl
  RECORD dir_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET dir_killed_appl->appl_cnt = 0
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 IF (validate(dir_kill_clause,"z")="z"
  AND validate(dir_kill_clause,"y")="y")
  DECLARE dir_kill_clause = vc WITH public, constant(
   "Session was killed by V500.DM2MONPKG.KILL_IF_BLOCKING procedure.")
 ENDIF
 SUBROUTINE dir_dm2_tables_tspace_assign(null)
   IF ((dir_tools_tspaces->data_tspace != "NONE")
    AND (dir_tools_tspaces->index_tspace != "NONE")
    AND (dir_tools_tspaces->lob_tspace != "NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc =
    "Determining data_tspace from dm2_user_tables for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tables for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("D_TOOLKIT", "D_SYS_MGMT", "D_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc =
    "Determining index_tspace from dm2_user_indexes for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_indexes for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("I_TOOLKIT", "I_SYS_MGMT", "I_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->lob_tspace="NONE"))
    SET dir_tools_tspaces->lob_tspace = dir_tools_tspaces->data_tspace
    SET dm_err->eproc = "Determining lob_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("L_SYS_MGMT", "L_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->lob_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_debug_trace_data(null)
   SET dir_ui_misc->debug_level = 0
   SET dir_ui_misc->trace_flag = 0
   SET dm_err->eproc = "Query for debug flag/level"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="DEBUG_FLAG"
    DETAIL
     dir_ui_misc->debug_level = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Query for trace status"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="TRACE_FLAG"
    DETAIL
     IF (i.info_char="ON")
      dir_ui_misc->trace_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_obsolete_objects(null)
   SET dm_err->eproc = "Selecting obsolete tables and indexes from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_OBJECT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->tbl_cnt = 0, stat = alterlist(dir_obsolete_objects->tbl,
      dir_obsolete_objects->tbl_cnt), dir_obsolete_objects->ind_cnt = 0,
     stat = alterlist(dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    DETAIL
     CASE (build(di.info_char))
      OF "TABLE":
       dir_obsolete_objects->tbl_cnt = (dir_obsolete_objects->tbl_cnt+ 1),
       IF (mod(dir_obsolete_objects->tbl_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->tbl,(dir_obsolete_objects->tbl_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->tbl[dir_obsolete_objects->tbl_cnt].table_name = di.info_name
      OF "INDEX":
       dir_obsolete_objects->ind_cnt = (dir_obsolete_objects->ind_cnt+ 1),
       IF (mod(dir_obsolete_objects->ind_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->ind,(dir_obsolete_objects->ind_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->ind[dir_obsolete_objects->ind_cnt].index_name = di.info_name
     ENDCASE
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->tbl,dir_obsolete_objects->tbl_cnt), stat = alterlist(
      dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting obsolete constraints from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_CONSTRAINT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->con_cnt = 0, stat = alterlist(dir_obsolete_objects->con,
      dir_obsolete_objects->con_cnt)
    DETAIL
     dir_obsolete_objects->con_cnt = (dir_obsolete_objects->con_cnt+ 1)
     IF (mod(dir_obsolete_objects->con_cnt,10)=1)
      stat = alterlist(dir_obsolete_objects->con,(dir_obsolete_objects->con_cnt+ 9))
     ENDIF
     dir_obsolete_objects->con[dir_obsolete_objects->con_cnt].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->con,dir_obsolete_objects->con_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_obsolete_objects)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_src_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_ddl_token_replacement(ddtr_text_str)
   DECLARE ddtr_pword = vc WITH protect, noconstant("NONE")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Before token replacement",ddtr_text_str))
   ENDIF
   IF (currdbuser="CDBA")
    IF ( NOT ((dm2_install_schema->cdba_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->cdba_p_word
    ENDIF
   ELSE
    IF ( NOT ((dm2_install_schema->v500_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->v500_p_word
    ENDIF
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL1%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL2%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL3%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC%",dm2_install_schema->cer_install,0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC2%",dm2_install_schema->ccluserdir,0)
   IF ((dm2_install_schema->servername != "NONE"))
    SET ddtr_text_str = replace(ddtr_text_str,"%SNAME%",dm2_install_schema->servername,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%UNAME%",trim(currdbuser),0)
   IF (ddtr_pword != "NONE")
    SET ddtr_text_str = replace(ddtr_text_str,"%PWD%",ddtr_pword,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DBASE%",trim(validate(currdbname," ")),0)
   IF ( NOT ((dm2_install_schema->src_v500_p_word="NONE")))
    SET ddtr_text_str = replace(ddtr_text_str,"%SRCPWD%",dm2_install_schema->src_v500_p_word,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("After token replacement",ddtr_text_str))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((ccs_appl_id=dm2_install_schema->appl_id))
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm2_install_rec->snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(dm2_install_rec->snapshot_dt_tm,
        "mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = dm2_install_schema->appl_id,
      di.info_date = cnvtdatetime(dm2_install_rec->snapshot_dt_tm), di.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), di.updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_row_count(rrc_table_name,rrc_row_cnt)
   DECLARE rrc_local_row_cnt = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Retrieving row count for table ",trim(rrc_table_name),".")
   SELECT INTO "nl:"
    FROM dm_user_tables_actual_stats t
    WHERE t.table_name=rrc_table_name
    DETAIL
     rrc_local_row_cnt = t.num_rows
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET rrc_row_cnt = 0.0
   ELSE
    SET rrc_row_cnt = rrc_local_row_cnt
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = dm2_sys_misc->cur_db_os ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF ((dm2_install_schema->process_option="DDL GEN"))
    SET dm2_install_schema->schema_prefix = ""
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSEIF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option IN (
   "DDL GEN", "INHOUSE")))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF ((dm2_install_schema->schema_prefix="dm2a"))
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),"_t.csv"))=0)
     SET dm_err->emsg = concat("CSV Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "CSV Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ELSE
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
     SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name="DM_INFO"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND checkdic("DM_INFO","T",0)=2)
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Defaulting to DM2 toolset")
   ENDIF
   RETURN(dtu_use_dm2_toolset)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
    IF (cnvtupper(gas_appl_id)="-15301")
     RETURN(gas_active_status)
    ENDIF
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     SELECT INTO "nl:"
      FROM v$session s
      WHERE s.audsid=cnvtint(gas_appl_id)
      WITH nocounter
     ;end select
     IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(gas_error_status)
     ENDIF
     IF (curqual > 0)
      RETURN(gas_active_status)
     ELSE
      RETURN(gas_inactive_status)
     ENDIF
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE','DM_SEQ') ")
   RETURN(in_clause)
 END ;Subroutine
 SUBROUTINE dir_add_silmode_entry(entry_name,entry_filename)
   SET dir_silmode->cnt = (dir_silmode->cnt+ 1)
   SET stat = alterlist(dir_silmode->qual,dir_silmode->cnt)
   SET dir_silmode->qual[dir_silmode->cnt].name = entry_name
   SET dir_silmode->qual[dir_silmode->cnt].filename = entry_filename
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   DECLARE dcsa_load_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsa_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
     AND ddol.op_type != "*(REMOTE)*"
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        IF (dir_alert_killed_appl(dcsa_load_ind,dcsa_fmt_appl_id,dcsa_kill_ind)=0)
         RETURN(0)
        ENDIF
        SET dcsa_load_ind = 0
        IF (dcsa_kill_ind=1)
         SET dcsa_error_msg = dir_kill_clause
        ELSE
         SET dcsa_error_msg = concat("Application ID ",trim(dcsa_fmt_appl_id)," is no longer active."
          )
        ENDIF
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg =
          "IMPORT operation set to ERROR since session executing no longer exists.", ddol.end_dt_tm
           = cnvtdatetime(curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status="RUNNING"
          AND ddol.op_type="IMPORT*"
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN (null, "RUNNING")
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dir_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      dir_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       dir_killed_appl->appl_cnt += 1
       IF (mod(dir_killed_appl->appl_cnt,10)=1)
        stat = alterlist(dir_killed_appl->appl,(dir_killed_appl->appl_cnt+ 9))
       ENDIF
       dir_killed_appl->appl[dir_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_killed_appl->appl,dir_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,dir_killed_appl->appl_cnt,daka_fmt_appl_id,
     dir_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF ((dm2_sys_misc->cur_os != "AXP"))
    RETURN(1)
   ENDIF
   IF (((dsbq_queue_name=" ") OR (dsbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_env_name = logical("environment")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Environment Name = ",dsbq_env_name))
   ENDIF
   IF (((dsbq_env_name=" ") OR (dsbq_env_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment name."
    SET dm_err->emsg = "Invalid environment name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("lreg -getp environment\",dsbq_env_name,
    " LocalUserName ;show symbol LREG_RESULT")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dsbq_cmd))
    CALL echo("*")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,'LREG_RESULT = "',"",0)
   SET dm_err->errtext = replace(dm_err->errtext,'"',"",1)
   IF (findstring("%DCL-W-UNDSYM",dm_err->errtext) > 0)
    SET dsbq_domain_user = " "
   ELSE
    SET dsbq_domain_user = trim(dm_err->errtext,3)
   ENDIF
   IF (dsbq_domain_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Retreiving domain user from registry."
    SET dm_err->emsg = "Unable to retrieive domain user from registry."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(curuser) != cnvtupper(dsbq_domain_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Making sure current user is the domain user."
    SET dm_err->emsg = "Current user is not the domain user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("sho queue /full ",dsbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dsbq_queue_fnd = 0
   ELSEIF (findstring(cnvtlower(dsbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dsbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dsbq_queue_fnd = 1
   ENDIF
   IF (dsbq_queue_fnd=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dsbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dsbq_cmd = concat("init/queue/batch/start/job_limit=20 ",dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_sea_sch_files(directory,file_prefix,schema_date)
   DECLARE dgns_dcl_find = vc WITH protect, noconstant("")
   DECLARE dgns_err_str = vc WITH protect, noconstant("")
   SET schema_date = "01-JAN-1800"
   IF ( NOT (file_prefix IN ("dm2a", "dm2o", "dm2c")))
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "file_prefix must be IN ('dm2a', 'dm2o', 'dm2c')"
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"%%%2*")
    ELSE
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"*")
    ENDIF
    SET dgns_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"???3????_*")
    ELSE
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"*")
    ENDIF
    SET dgns_err_str = "file not found"
   ELSE
    IF (file_prefix="dm2a")
     IF ((dm2_sys_misc->cur_os="LNX"))
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???4* | wc -w")
     ELSE
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
     ENDIF
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     IF (file_prefix="dm2a")
      IF ((dm2_sys_misc->cur_os="LNX"))
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???4* ")
      ELSE
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
      ENDIF
     ELSE
      SET dgns_dcl_find = concat("ls - ",build(directory),"/",file_prefix,"* ")
     ENDIF
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dgns_dcl_find)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FREE DEFINE rtl
    FREE SET file_loc
    SET logical file_loc value(dm_err->errfile)
    DEFINE rtl "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      compare_date = cnvtdate("01011800"), stripped_date = cnvtdate("01011800")
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       starting_pos = findstring(cnvtupper(file_prefix),r.line)
      ELSE
       starting_pos = findstring(file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_list_of_files(dglf_prefix)
   DECLARE dglf_str = vc WITH protect
   SET dm_err->eproc = "Getting help list of schema files to select from."
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglf_str = concat("dir/version=1/columns=1 cer_install:",dglf_prefix,"*_h.dat ")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dglf_str = concat("dir ",dm2_install_schema->cer_install,"\",dglf_prefix,"*_h.dat /B")
   ELSE
    SET dglf_str = concat('find $cer_install -name "',dglf_prefix,'*_h.dat" -print')
   ENDIF
   IF (dm2_push_dcl(value(dglf_str))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_find_data_file(dfdf_file_found)
   DECLARE dtd_data_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Finding data files"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    DETAIL
     dtd_data_file = ddf.file_name
    WITH maxqual(ddf,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dfdf_file_found = findfile(dtd_data_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file found ind =",dfdf_file_found))
    CALL echo(build("file name =",dtd_data_file))
   ENDIF
   IF (dfdf_file_found=0)
    SET dm_err->eproc = "Datafile not visible at operating system level"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_managed_ddl_setup(dmds_runid)
   DECLARE dmds_rowcnt = f8 WITH protect, noconstant(0.0)
   DECLARE dmds_ndx = i4 WITH protect, noconstant(0)
   DECLARE dmds_priority = i4 WITH protect, noconstant(0)
   SET dir_managed_ddl->setup_complete = 0
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if Managed DDL oracle version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MANAGED_DDL_ORAVER"
    DETAIL
     IF (d.info_name=build(dm2_rdbms_version->level1,".",dm2_rdbms_version->level2,".",
      dm2_rdbms_version->level3,
      ".",dm2_rdbms_version->level4))
      dir_managed_ddl->oraversion = d.info_name, dir_managed_ddl->managed_ddl_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_managed_ddl->managed_ddl_ind=1))
    SET dm_err->eproc = "Check for row_cnt override for Managed DDL"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MANAGED_DDL_ROWCNT"
     DETAIL
      dmds_rowcnt = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dmds_rowcnt > 0.0)
     SET dm_err->eproc = concat("Managed DDL Rowcnt Override: ",build(dmds_rowcnt))
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dmds_rowcnt = 10000
    ENDIF
    SET dm_err->eproc = "Load Managed DDL Priorities"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d,
      dm_dba_tables_actual_stats t
     WHERE d.run_id=dmds_runid
      AND d.op_type IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="DM2_MANAGED_DDL_OP_TYPE"))
      AND d.table_name != "DM*"
      AND d.table_name=t.table_name
      AND t.num_rows > dmds_rowcnt
      AND (( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="DM2_MIXED_TABLE-EXPORT-REFERENCE"
       AND di.info_name=d.table_name))) OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE dtd.reference_ind=0
       AND dtd.table_name=d.table_name))))
      AND ((d.status != "COMPLETE") OR (d.status = null))
     ORDER BY d.priority, d.table_name
     HEAD d.priority
      dmds_ndx = 0, dmds_priority = d.priority
      IF ((dir_managed_ddl->priority_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->priority_cnt,dmds_priority,dir_managed_ddl->
        priorities[dmds_ndx].priority)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->priority_cnt = (dir_managed_ddl->priority_cnt+ 1)
       IF (mod(dir_managed_ddl->priority_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->priorities,(dir_managed_ddl->priority_cnt+ 99))
       ENDIF
       dir_managed_ddl->priorities[dir_managed_ddl->priority_cnt].priority = d.priority
      ENDIF
     HEAD d.table_name
      dmds_ndx = 0
      IF ((dir_managed_ddl->table_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->table_cnt,d.table_name,dir_managed_ddl->
        tables[dmds_ndx].table_name)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->table_cnt = (dir_managed_ddl->table_cnt+ 1)
       IF (mod(dir_managed_ddl->table_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->tables,(dir_managed_ddl->table_cnt+ 99))
       ENDIF
       dir_managed_ddl->tables[dir_managed_ddl->table_cnt].table_name = d.table_name
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_managed_ddl->tables,dir_managed_ddl->table_cnt), stat = alterlist(
       dir_managed_ddl->priorities,dir_managed_ddl->priority_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dir_managed_ddl->managed_ddl_ind = 0
    ENDIF
   ENDIF
   SET dir_managed_ddl->setup_complete = 1
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_managed_ddl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_perform_wait_interval(null)
   DECLARE dpwi_pause_interval = i4 WITH protect, noconstant(1)
   SET dm_err->eproc = "Obtain pause interval"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INSTALL_PKG"
     AND d.info_name="PAUSE_INTERVAL"
    DETAIL
     dpwi_pause_interval = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Pausing for ",build(dpwi_pause_interval)," minutes.")
   CALL disp_msg("",dm_err->logfile,0)
   CALL pause((dpwi_pause_interval * 60))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_storage_type(dgst_db_link)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dir_storage_misc->cur_storage_type = "AXP"
    SET dir_storage_misc->tgt_storage_type = "AXP"
    SET dir_storage_misc->src_storage_type = "AXP"
   ELSE
    IF (dgst_db_link > " "
     AND dgst_db_link != "DM2NOTSET")
     SET dm_err->eproc = "Determine source storage type from dba_data_files"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (parser(concat("dba_data_files@",dgst_db_link)) ddf)
      WHERE ddf.tablespace_name="SYSTEM"
       AND ddf.file_name=patstring("/dev/*")
      DETAIL
       dir_storage_misc->src_storage_type = "RAW"
      WITH nocounter, maxqual = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dir_storage_misc->src_storage_type = "ASM"
     ENDIF
    ENDIF
    SET dm_err->eproc = "Determine target storage type from dba_data_files"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE ddf.tablespace_name="SYSTEM"
     DETAIL
      IF (ddf.file_name=patstring("/dev/*"))
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ELSEIF (ddf.file_name=patstring("+*"))
       dir_storage_misc->cur_storage_type = "ASM", dir_storage_misc->tgt_storage_type = "ASM"
      ELSE
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ENDIF
     WITH nocounter, maxqual = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   IF (validate(dm2_tgt_storage_type,"XXX") IN ("RAW", "ASM"))
    SET dir_storage_misc->cur_storage_type = dm2_tgt_storage_type
    SET dir_storage_misc->tgt_storage_type = dm2_tgt_storage_type
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution,dcdosa_install_mode)
   DECLARE dcdosa_compare_date = vc WITH protect, noconstant("")
   DECLARE dcdosa_cer_install = vc WITH protect, noconstant("")
   DECLARE dcdosa_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm_ocd_setup_admin_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_dm2_create_system_defs_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm2_set_adm_cbo_date = dq8 WITH protect, noconstant(0.0)
   SET dcdosa_requires_execution = 0
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Admin Setup Bypassed - Database must be on Oracle to perform Admin setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "AXP", "LNX", "WIN"))))
    SET dm_err->eproc =
    "Admin Setup Bypassed - o/s must be HPX, AIX, VMS, LNX or WIN to perform Admin Setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT (dcdosa_install_mode IN ("UPTIME", "BATCHUP", "PREVIEW", "BATCHPREVIEW", "EXPRESS",
   "BATCHEXPRESS")))
    SET dm_err->eproc = "Checking install mode"
    SET dm_err->eproc = concat("Admin Setup Bypassed - Install mode needs to be ",
     " UPTIME, BATCHUP, PREVIEW, BATCHPREVIEW, EXPRESS or BATCHEXPRESS to perform Admin Setup.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("clinical database version : ",dm2_rdbms_version->level1))
   ENDIF
   SET dm_err->eproc = "Selecting dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    HEAD REPORT
     dcdosa_dm_info_schema_date = 0, dcdosa_dm_info_dm_ocd_setup_admin_date = 0.0,
     dcdosa_dm_info_dm2_create_system_defs_date = 0.0,
     dcdosa_dm_info_dm2_set_adm_cbo_date = 0.0
    DETAIL
     CASE (di.info_name)
      OF "SCHEMA_DATE":
       dcdosa_dm_info_schema_date = cnvtdate2(di.info_char,"DD-MMM-YYYY")
      OF "DM_OCD_SETUP_ADMIN_DATE":
       dcdosa_dm_info_dm_ocd_setup_admin_date = cnvtdatetime(di.info_char)
      OF "DM2_CREATE_SYSTEM_DEFS_DATE":
       dcdosa_dm_info_dm2_create_system_defs_date = cnvtdatetime(di.info_char)
      OF "DM2_SET_ADM_CBO_DATE":
       dcdosa_dm_info_dm2_set_adm_cbo_date = cnvtdatetime(di.info_char)
     ENDCASE
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding newest schema file."
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdosa_cer_install = cnvtlower(trim(logical("cer_install"),3))
   IF (dcfr_sea_csv_files(dcdosa_cer_install,"dm2a",dcdosa_compare_date)=0)
    RETURN(0)
   ELSE
    IF (dcdosa_compare_date="01-JAN-1800")
     SET dm_err->eproc = "Searching for Schema files."
     SET dm_err->emsg = "No schema files present in cer_install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dcdosa_schema_date = cnvtdate2(dcdosa_compare_date,"DD-MMM-YYYY")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("dcdosa_dm_info_schema_date:",dcdosa_dm_info_schema_date))
    CALL echo(build("dcdosa_schema_date:",dcdosa_schema_date))
    CALL echo(build("dcdosa_dm_info_dm_ocd_setup_admin_date:",dcdosa_dm_info_dm_ocd_setup_admin_date)
     )
    CALL echo(build("dm_ocd_setup_admin_data->dm_ocd_setup_admin_date:",dm_ocd_setup_admin_data->
      dm_ocd_setup_admin_date))
    CALL echo(build("dcdosa_dm_info_dm2_create_system_defs_date:",
      dcdosa_dm_info_dm2_create_system_defs_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_create_system_defs:",dm_ocd_setup_admin_data->
      dm2_create_system_defs))
    CALL echo(build("dcdosa_dm_info_dm2_set_adm_cbo_date:",dcdosa_dm_info_dm2_set_adm_cbo_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_set_adm_cbo:",dm_ocd_setup_admin_data->
      dm2_set_adm_cbo))
   ENDIF
   IF ((dm2_rdbms_version->level1 < 11))
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR ((
    dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs)))
    )) )
     SET dcdosa_requires_execution = 1
     RETURN(1)
    ENDIF
   ELSE
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR (
    (((dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs))
     OR ((dcdosa_dm_info_dm2_set_adm_cbo_date < dm_ocd_setup_admin_data->dm2_set_adm_cbo))) )) )) )
     SET dcdosa_requires_execution = 1
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_for_package(dcfp_valid_ind,dcfp_env_id)
   SET dcfp_valid_ind = 0
   SET dcfp_env_id = 0.0
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypassing check for package history.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Find environment id."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name="DM_ENV_ID"
    DETAIL
     dcfp_env_id = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = build("Look for package history for environment id :",dcfp_env_id)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.environment_id=dcfp_env_id
    WITH nocounter, maxqual(l,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
   ELSE
    SET dcfp_valid_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_dg_data(dgdd_assign_dg_ind,dgdd_dg_override,dgdd_dg_out)
   DECLARE dgdd_dskgrp_name = vc WITH protect, noconstant("")
   DECLARE dgdd_dskgrp_state = vc WITH protect, noconstant("")
   DECLARE dgdd_chck = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = "Get diskgroup information"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgdd_dg_out = "NOT_SET"
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Use initprm assign dg ind->",dgdd_assign_dg_ind))
    CALL echo(build("Diskgroup override->",dgdd_dg_override))
   ENDIF
   IF (dgdd_dg_override != "NOT_SET")
    SET dm_err->eproc = "Query for state of disk group "
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dg_override
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dg_override
     SET dgdd_chck = 0
    ENDIF
   ENDIF
   IF (dgdd_assign_dg_ind=1
    AND dgdd_chck=1)
    SET dm_err->eproc = "Query for disk group using db_create_file_dest"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$parameter v
     WHERE v.name="db_create_file_dest"
     DETAIL
      dgdd_dskgrp_name = cnvtupper(v.value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring("+",dgdd_dskgrp_name,1,0) > 0)
     SET dgdd_dskgrp_name = trim(replace(dgdd_dskgrp_name,"+","",1),3)
    ENDIF
    SET dm_err->eproc = "Query to validate diskgroup"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dskgrp_name
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dskgrp_name
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Determined diskgroup->",dgdd_dg_out))
   ENDIF
   IF (dgdd_dg_out != "NOT_SET")
    SET dir_ui_misc->tspace_dg = dgdd_dg_out
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_submit_jobs(dsj_plan_id,dsj_install_mode,dsj_user,dsj_pword,dsj_cnnct_str,
  dsj_queue_name,dsj_background_ind)
   DECLARE dsj_wait_time_minutes = i2 WITH protect, noconstant(15)
   DECLARE dsj_wait_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE dsj_wait_for_start = i2 WITH protect, noconstant(0)
   FREE RECORD dsj_request
   RECORD dsj_request(
     1 plan_id = f8
     1 install_mode = vc
   )
   FREE RECORD dsj_reply
   RECORD dsj_reply(
     1 install_status = vc
     1 event = vc
     1 install_mode_ret = vc
     1 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET dsj_request->plan_id = dsj_plan_id
   SET dsj_request->install_mode = "CURRENT"
   SET dsj_wait_timestamp = cnvtdatetime(curdate,curtime3)
   SET dm_err->eproc = "Get the status of auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_auto_install_status  WITH replace("REQUEST",dsj_request), replace("REPLY",dsj_reply)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    IF ((dsj_reply->install_status="EXECUTING"))
     SET dm_err->eproc = "Checking the status of the auto install process"
     SET dm_err->emsg = concat("Active package install running for ",dsj_reply->install_mode_ret)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "submit the package install to background"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_package_install,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_install_mode="*ABG")
    SET dsj_install_mode = replace(dsj_install_mode,"ABG","",2)
   ENDIF
   SET dm_err->eproc = "Waiting for background installation process to begin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Check for wait time override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_SUBMIT_TIME_WAIT"
     AND d.info_name="MINUTES"
    DETAIL
     dsj_wait_time_minutes = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dsj_wait_for_start = 1
   WHILE (dsj_wait_for_start=1)
     IF (drr_cleanup_dm_info_runners(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Wait for install to begin execution."
     SELECT INTO "nl:"
      FROM dm_process dp,
       dm_process_event dpe,
       dm_process_event_dtl dped1,
       dm_process_event_dtl dped2
      PLAN (dpe
       WHERE dpe.install_plan_id=dsj_plan_id
        AND dpe.begin_dt_tm >= cnvtdatetime(dsj_wait_timestamp))
       JOIN (dp
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution)
       JOIN (dped1
       WHERE dpe.dm_process_event_id=dped1.dm_process_event_id
        AND dped1.detail_type="INSTALL_MODE"
        AND dped1.detail_text=dsj_install_mode)
       JOIN (dped2
       WHERE dped1.dm_process_event_id=dped2.dm_process_event_id
        AND dped2.detail_type="UNATTENDED_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dsj_wait_for_start = 0
     ENDIF
     IF (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dsj_wait_timestamp)),4) > dsj_wait_time_minutes
      AND dsj_wait_for_start=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Wait time expired. Unable to detect background install process."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     CALL pause(5)
   ENDWHILE
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_install_monitor,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_background_ind=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,concat("The ",dsj_install_mode,
      " Installation is now submitted as a background process."))
    CALL text(3,1,"This session/connection is no longer required.")
    CALL text(5,1,"Notification emails about Installation events will be sent as they occur.")
    CALL text(8,1,concat("To monitor, stop or pause the execution of the background ",
      dsj_install_mode," Installation process,"))
    CALL text(9,1,"you can execute the following in CCL:")
    CALL text(11,1,"ccl> dm2_install_plan_menu go ")
    CALL text(13,3,"Enter 'C' to continue.")
    CALL accept(13,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = concat("Check if ",dcp_table_name," table is involved in a hard parse event.")
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",trim(dcp_owner),
      ".",dcp_table_name,". SQL_ID = ",
      trim(d.sql_id),", Session_Id:",trim(cnvtstring(d.session_id)),", Serial#: ",trim(cnvtstring(d
        .session_serial#)),
      ".")
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_ddl_gen_retry(dgr_retry_ceiling)
   DECLARE dgr_di_exists = i2 WITH protect, noconstant(0)
   SET dgr_retry_ceiling = 10
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgr_di_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgr_di_exists=1)
    SET dm_err->eproc = "Check for retry ceiling override."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_DDL_GEN"
      AND d.info_name="RETRY CEILING"
     DETAIL
      dgr_retry_ceiling = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgr_retry_ceiling <= 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Retry ceiling is invalid (must be greater than zero)."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_users_pwds(dlup_users_for_pwd)
   DECLARE dlup_user = vc WITH protect, noconstant("")
   DECLARE dlup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dlup_num = i4 WITH protect, noconstant(1)
   DECLARE dlup_idx = i2 WITH protect, noconstant(0)
   DECLARE dlup_choice = vc WITH protect, noconstant("")
   IF (size(dlup_users_for_pwd)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Loading users into record structure for password prompt."
    SET dm_err->emsg = "No user specified."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading users into record structure for password prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dlup_user != dlup_notfnd)
     SET dlup_user = piece(dlup_users_for_pwd,",",dlup_num,dlup_notfnd)
     SET dlup_num = (dlup_num+ 1)
     IF (dlup_user != dlup_notfnd)
      SET dlup_idx = locateval(dlup_idx,1,dir_db_users_pwds->cnt,dlup_user,dir_db_users_pwds->qual[
       dlup_idx].user)
      IF (dlup_idx=0)
       SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
       SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = dlup_user
       CALL clear(1,1)
       CALL text(6,2,concat("Please enter password for user ",dir_db_users_pwds->qual[
         dir_db_users_pwds->cnt].user,": "))
       CALL text(10,1,"Enter 'C' to continue or 'Q' to exit process. (C or Q): ")
       CALL accept(6,50,"P(30);C"," "
        WHERE  NOT (curaccept=" "))
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = build(curaccept)
       CALL accept(10,60,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       SET dlup_choice = curaccept
       IF (dlup_choice="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "User quit process.  "
        SET dm_err->eproc = "Prompting for database user password."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_db_users_pwds)
   ENDIF
   IF ((dir_db_users_pwds->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user/password list."
    SET dm_err->emsg = "Database user/password not loaded into memory."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_adm_appl_status(dgaps_dblink,dgaps_audsid,dgaps_status)
   SET dgaps_status = "ACTIVE"
   IF (cnvtupper(dgaps_audsid)="-15301")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (value(concat("GV$SESSION@",dgaps_dblink)) s)
    WHERE s.audsid=cnvtint(dgaps_audsid)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dir_get_adm_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (value(concat("V$SESSION@",dgaps_dblink)) s)
     WHERE s.audsid=cnvtint(dgaps_audsid)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dir_get_adm_appl_status")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgaps_status = "INACTIVE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_upd_adm_upgrade_info(null)
   DECLARE duaui_schema_date = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Deleting from dm_info for dm_ocd_setup_admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (dcfr_sea_csv_files(cnvtlower(trim(logical("cer_install"),3)),"dm2a",duaui_schema_date)=0)
    RETURN(0)
   ELSE
    IF (duaui_schema_date="01-JAN-1800")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Schema Date: ",duaui_schema_date))
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting schema_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "SCHEMA_DATE", di.info_char =
     duaui_schema_date,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm_ocd_setup_admin_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM_OCD_SETUP_ADMIN_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_create_system_defs_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_CREATE_SYSTEM_DEFS_DATE",
     di.info_char = format(dm_ocd_setup_admin_data->dm2_create_system_defs,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_set_adm_cbo_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_SET_ADM_CBO_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm2_set_adm_cbo,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_custom_constraints(null)
   DECLARE dgcc_constraint_index = i2 WITH protect, noconstant(0)
   SET dir_custom_constraints->con_cnt = 0
   SET stat = initrec(dir_custom_constraints)
   SET dm_err->eproc = "Retrieving custom constraints"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_CONSTRAINTS"
    DETAIL
     dgcc_constraint_index = (dgcc_constraint_index+ 1)
     IF (mod(dgcc_constraint_index,10)=1)
      stat = alterlist(dir_custom_constraints->con,(dgcc_constraint_index+ 9))
     ENDIF
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_custom_constraints->con,dgcc_constraint_index), dir_custom_constraints->
     con_cnt = dgcc_constraint_index
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcc_constraint_index=0)
    SET stat = alterlist(dir_custom_constraints->con,2)
    SET dir_custom_constraints->con[1].constraint_name = "CUCIM_ACQUIRED_STUDY"
    SET dir_custom_constraints->con[2].constraint_name = "CUCIM_SERIES"
    SET dir_custom_constraints->con_cnt = 2
   ELSE
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_ACQUIRED_STUDY",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_ACQUIRED_STUDY"
    ENDIF
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_SERIES",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_SERIES"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_admin_db_link(dgadl_report_fail_ind,dgadl_admin_db_link,dgadl_fail_ind)
   DECLARE dgadl_admin_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgadl_admin_link_match = i2 WITH protect, noconstant(0)
   SET dgadl_fail_ind = 0
   SET dm_err->eproc = "Obtain Admin database link name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
    DETAIL
     dgadl_admin_db_link = de.admin_dbase_link_name, dgadl_admin_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(dgadl_admin_db_link)=0)
    SET dgadl_fail_ind = 1
    IF (dgadl_report_fail_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Admin database link is not valued in DM_ENVIRONMENT.admin_dbase_link_name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgadl_fail_ind=0)
    SET dm_err->eproc = "Validate Admin database link name"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (parser(concat("cdba.dm_environment@",dgadl_admin_db_link)) de)
     WHERE de.environment_id=dgadl_admin_env_id
     DETAIL
      IF (cnvtupper(dgadl_admin_db_link)=cnvtupper(de.admin_dbase_link_name))
       dgadl_admin_link_match = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgadl_admin_link_match=0)
     SET dgadl_fail_ind = 1
     IF (dgadl_report_fail_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Admin database link does not exist in database or is causing data inconsistency when used."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE re_kick(k_message)
  SELECT
   d.seq
   FROM dummyt d
   DETAIL
    "Readme Estimator", row + 1, "================",
    row + 1, k_message, row + 1
   WITH nocounter
  ;end select
  GO TO 9999_exit_program
 END ;Subroutine
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_report TO 2999_report_exit
 GO TO 9999_exit_program
#1000_initialize
 FREE SET re_data
 RECORD re_data(
   1 readme[*]
     2 readme_id = f8
     2 instance = i4
     2 description = c50
     2 ocd = i4
     2 execution = vc
     2 category = vc
     2 driver_table = vc
     2 execution_time = f8
     2 status = vc
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 skip = i2
 )
 SET re_i = 0
 SET re_count = 0
 SET re_driver = 0
 SET re_rows = 0
 SET re_seconds = 0.0
 SET re_ocd = 0
 IF (validate(rm_estimator_ocd,0))
  SET re_ocd = rm_estimator_ocd
 ENDIF
 SET re_format = "DD.HH:MM:SS;3;z"
 IF (dm2_rr_toolset_usage(null)=0)
  CALL echo("*")
  CALL echo("*")
  CALL echo("*")
  CALL echo(dm_err->asterisk_line)
  CALL echo("*")
  CALL echo(concat("Component Name:  ",curprog))
  CALL echo("*")
  CALL echo(concat("Process Description:  ",dm_err->eproc))
  CALL echo("*")
  CALL echo(concat("Error Message:  ",trim(dm_err->emsg)))
  CALL echo("*")
  IF ((dm_err->user_action != "NONE"))
   CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
   CALL echo("*")
  ENDIF
  CALL echo(dm_err->asterisk_line)
  CALL echo("*")
  CALL echo("*")
  CALL echo("*")
  GO TO 9999_exit_program
 ENDIF
 IF ((dm2_rr_misc->dm2_toolset_usage="Y"))
  EXECUTE dm2_readme_estimator re_ocd
  GO TO 9999_exit_program
 ENDIF
 IF ( NOT (validate(rm_defined,0)))
  SET rm_defined = 1
  SET rm_error = 0
  SET rm_warning = 1
  SET rm_info = 2
  SET rm_debug = 4
  SET rm_readme = "README"
  SET rm_dbimport = "DBIMPORT"
  SET rm_ccl = "CCL"
  SET rm_oracle = "ORACLE"
  SET rm_oracle_ref = "ORACLEREF"
  SET rm_ccl_dbimport = "CCLDBIMPORT"
  SET rm_tbl_import = "TABLEIMPORT"
  SET rm_running = "RUNNING"
  SET rm_done = "SUCCESS"
  SET rm_failed = "FAILED"
  SET rm_reset = "RESET"
  SET rm_pre_schema_up = "PREUP"
  SET rm_post_schema_up = "POSTUP"
  SET rm_pre_schema_down = "PREDOWN"
  SET rm_post_schema_down = "POSTDOWN"
  SET rm_uptime = "UP"
  SET rm_temp_id = 0.0
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    rm_temp_id = i.info_number
   WITH nocounter
  ;end select
  IF ( NOT (rm_temp_id))
   CALL rm_log(rm_error,"No environment ID found on the DM_INFO table for this environment.")
  ENDIF
  SET rm_env_id = rm_temp_id
  FREE SET rm_temp_id
 ENDIF
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
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 SUBROUTINE rm_log(l_level,l_message)
   IF (size(trim(l_message,3)))
    CALL echo("********************************************************************************")
    CASE (l_level)
     OF rm_error:
      CALL echo(concat("ERROR: ",l_message))
     OF rm_warning:
      CALL echo(concat("WARNING: ",l_message))
     ELSE
      CALL echo(l_message)
    ENDCASE
    CALL echo("********************************************************************************")
    IF (l_level=rm_error)
     ROLLBACK
     GO TO 9999_exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rm_row_count(rc_table)
   SET rc_count = 0
   SET rc_date = 0.0
   SET rc_so_exists = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name="SPACE_OBJECTS"
    DETAIL
     rc_so_exists = 1
    WITH nocounter
   ;end select
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     FROM dba_synonyms s
     WHERE s.synonym_name="SPACE_OBJECTS"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET rc_so_exists = 0
    ENDIF
   ENDIF
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     o.row_count
     FROM ref_report_log l,
      ref_report_parms_log p,
      ref_instance_id i,
      space_objects o
     PLAN (l
      WHERE l.report_cd=1
       AND l.end_date IS NOT null)
      JOIN (p
      WHERE p.report_seq=l.report_seq
       AND p.parm_cd=1)
      JOIN (i
      WHERE i.environment_id=rm_env_id
       AND cnvtstring(i.instance_cd)=p.parm_value)
      JOIN (o
      WHERE o.segment_name=rc_table
       AND o.report_seq=l.report_seq)
     ORDER BY l.begin_date
     DETAIL
      rc_count = o.row_count, rc_date = cnvtdatetime(l.end_date)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables t
    WHERE t.table_name=rc_table
    DETAIL
     IF (cnvtdatetime(t.last_analyzed) > rc_date)
      rc_count = t.num_rows
     ENDIF
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
#1999_initialize_exit
#2000_report
 SET re_count = 0
 SET not_dup = 0
 SET dup = 0
 SET dre_i = 0
 IF (re_ocd)
  SELECT INTO "nl:"
   r.readme_id
   FROM dm_ocd_readme o,
    dm_readme r
   PLAN (o
    WHERE o.ocd=re_ocd)
    JOIN (r
    WHERE r.readme_id=o.readme_id
     AND r.execution IN (rm_pre_schema_up, rm_post_schema_up, rm_pre_schema_down, rm_post_schema_down,
    rm_uptime)
     AND r.instance=o.instance
     AND r.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     l.project_name
     FROM dm_ocd_log l
     WHERE l.environment_id=rm_env_id
      AND l.project_type=rm_readme
      AND l.project_name=trim(cnvtstring(r.readme_id),3)
      AND l.ocd=o.ocd
      AND l.status=rm_done)))
     AND  NOT ( EXISTS (
    (SELECT
     l.project_name
     FROM dm_ocd_log l,
      dm_readme x
     WHERE x.readme_id=r.readme_id
      AND x.run_once_ind=1
      AND l.environment_id=rm_env_id
      AND l.project_type=rm_readme
      AND l.ocd > 0
      AND l.project_name=trim(cnvtstring(x.readme_id),3)
      AND l.project_instance=o.instance
      AND l.status=rm_done))))
   ORDER BY r.readme_id
   DETAIL
    re_count = (re_count+ 1), stat = alterlist(re_data->readme,re_count), re_data->readme[re_count].
    readme_id = r.readme_id,
    re_data->readme[re_count].instance = r.instance, re_data->readme[re_count].description = trim(r
     .description), re_data->readme[re_count].ocd = o.ocd,
    re_data->readme[re_count].execution = cnvtupper(trim(r.execution,3)), re_data->readme[re_count].
    driver_table = cnvtupper(trim(r.driver_table,3)), re_data->readme[re_count].execution_time = r
    .execution_time
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   r.readme_id
   FROM dm_readme r,
    dm_ocd_readme o,
    dm_alpha_features_env a,
    (dummyt d  WITH seq = value(re_count))
   PLAN (d)
    JOIN (r
    WHERE (r.readme_id=re_data->readme[d.seq].readme_id)
     AND (r.instance > re_data->readme[d.seq].instance))
    JOIN (o
    WHERE o.readme_id=r.readme_id
     AND o.ocd > 0
     AND o.instance=r.instance)
    JOIN (a
    WHERE a.alpha_feature_nbr=o.ocd
     AND a.environment_id=rm_env_id)
   ORDER BY r.readme_id, r.instance DESC
   HEAD r.readme_id
    IF (r.active_ind=0)
     re_data->readme[d.seq].skip = 1
    ELSE
     re_data->readme[d.seq].instance = r.instance, re_data->readme[d.seq].ocd = o.ocd, re_data->
     readme[d.seq].description = r.description,
     re_data->readme[d.seq].driver_table = cnvtupper(trim(r.driver_table,3)), re_data->readme[d.seq].
     execution_time = r.execution_time, re_data->readme[d.seq].skip = 0
    ENDIF
   FOOT  r.readme_id
    row + 0
   WITH nocounter
  ;end select
  IF (re_count)
   SELECT INTO "nl:"
    FROM dm_ocd_log l,
     (dummyt d  WITH seq = value(re_count))
    PLAN (d)
     JOIN (l
     WHERE l.environment_id=rm_env_id
      AND l.project_type=rm_readme
      AND l.project_name=trim(cnvtstring(re_data->readme[d.seq].readme_id),3)
      AND (l.ocd=re_data->readme[d.seq].ocd)
      AND l.status=rm_done
      AND l.active_ind=1)
    DETAIL
     re_data->readme[d.seq].skip = 1
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   r.readme_id, status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
    cnvtdatetime(curdate,curtime)),
   end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,curtime))
   FROM dm_alpha_features_env a,
    dm_ocd_readme o,
    dm_readme r,
    dm_ocd_log l,
    dummyt d
   PLAN (a
    WHERE a.environment_id=rm_env_id
     AND a.curr_migration_ind=1)
    JOIN (o
    WHERE o.ocd=a.alpha_feature_nbr)
    JOIN (r
    WHERE r.readme_id=o.readme_id
     AND r.execution IN (rm_pre_schema_up, rm_post_schema_up, rm_pre_schema_down, rm_post_schema_down,
    rm_uptime)
     AND r.instance=o.instance
     AND  NOT ( EXISTS (
    (SELECT
     m.project_name
     FROM dm_ocd_log m,
      dm_readme x
     WHERE x.readme_id=r.readme_id
      AND x.run_once_ind=1
      AND m.environment_id=rm_env_id
      AND m.project_type=rm_readme
      AND m.project_name=trim(cnvtstring(x.readme_id),3)
      AND m.status=rm_done
      AND m.ocd != o.ocd))))
    JOIN (d)
    JOIN (l
    WHERE l.environment_id=rm_env_id
     AND l.project_type=rm_readme
     AND trim(cnvtstring(r.readme_id),3)=l.project_name
     AND l.ocd=o.ocd
     AND l.project_instance=r.instance)
   ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
   HEAD r.readme_id
    IF (r.active_ind=1)
     re_count = (re_count+ 1), stat = alterlist(re_data->readme,re_count), re_data->readme[re_count].
     readme_id = r.readme_id,
     re_data->readme[re_count].instance = r.instance, re_data->readme[re_count].description = trim(r
      .description), re_data->readme[re_count].ocd = o.ocd,
     re_data->readme[re_count].execution = cnvtupper(trim(r.execution,3)), re_data->readme[re_count].
     driver_table = cnvtupper(trim(r.driver_table,3)), re_data->readme[re_count].execution_time = r
     .execution_time,
     re_data->readme[re_count].status = status, re_data->readme[re_count].start_dt_tm = start_dt_tm,
     re_data->readme[re_count].end_dt_tm = end_dt_tm,
     row + 1
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF ( NOT (re_count))
  CALL re_kick("No readmes found.")
 ENDIF
 FOR (re_i = 1 TO re_count)
   CASE (re_data->readme[re_i].execution)
    OF rm_pre_schema_up:
     SET re_data->readme[re_i].category = "01"
    OF rm_post_schema_up:
     SET re_data->readme[re_i].category = "02"
    OF rm_pre_schema_down:
     SET re_data->readme[re_i].category = "03"
    OF rm_post_schema_down:
     SET re_data->readme[re_i].category = "04"
    OF rm_uptime:
     SET re_data->readme[re_i].category = "05"
    ELSE
     SET re_data->readme[re_i].category = "99"
   ENDCASE
   SET re_seconds = re_data->readme[re_i].execution_time
   IF (size(trim(re_data->readme[re_i].driver_table,3)))
    SET re_driver = rm_row_count(re_data->readme[re_i].driver_table)
    SET re_rows = 0
    SET re_seconds = 0
    IF (re_driver)
     SELECT INTO "nl:"
      l.driver_count
      FROM dm_ocd_log l
      WHERE l.project_type=rm_readme
       AND l.project_name=trim(cnvtstring(re_data->readme[re_i].readme_id),3)
       AND (l.project_instance=re_data->readme[re_i].instance)
       AND l.status=rm_done
       AND l.start_dt_tm IS NOT null
       AND l.end_dt_tm IS NOT null
      DETAIL
       IF (l.driver_count)
        re_rows = (re_rows+ l.driver_count), re_seconds = (re_seconds+ datetimediff(l.end_dt_tm,l
         .start_dt_tm,5))
       ENDIF
      WITH nocounter
     ;end select
     IF (re_rows)
      SET re_seconds = ((re_seconds/ re_rows) * re_driver)
     ELSE
      SET re_seconds = (re_data->readme[re_i].execution_time * re_driver)
     ENDIF
    ENDIF
   ENDIF
   SET re_data->readme[re_i].execution_time = (re_seconds/ ((24.0 * 60.0) * 60.0))
 ENDFOR
 SELECT
  category = re_data->readme[d.seq].category
  FROM (dummyt d  WITH seq = value(re_count))
  PLAN (d
   WHERE (re_data->readme[d.seq].skip != 1))
  ORDER BY category, re_data->readme[d.seq].ocd, re_data->readme[d.seq].description
  HEAD REPORT
   CALL print("Readme Execution Time Estimation Report"), row + 1,
   CALL print("======================================="),
   row + 2, report_total = 0.0, rpt_estimate_total = 0.0,
   rpt_actual_total = 0.0, actual_secs = 0, actual_time = 0.0,
   dre_readme_found = 0
  HEAD category
   CALL print(concat("Category: ",re_data->readme[d.seq].execution)), row + 2, col 2,
   "Readme ID", col 14, "Description",
   col 74, "Estimate time"
   IF (re_ocd=0)
    col 90, "Actual time", col 105,
    "Status"
   ENDIF
   row + 1, col 2, "_________",
   col 14, "___________", col 74,
   "_____________"
   IF (re_ocd=0)
    col 90, "___________", col 105,
    "______"
   ENDIF
   row + 1, category_total = 0.0, cat_estimate_total = 0.0,
   cat_actual_total = 0.0
  DETAIL
   dre_readme_found = 1,
   CALL center(trim(cnvtstring(re_data->readme[d.seq].readme_id),3),2,11), col 14,
   CALL print(re_data->readme[d.seq].description), col 74
   IF (re_data->readme[d.seq].execution_time)
    CALL print(trim(format(re_data->readme[d.seq].execution_time,re_format),3))
   ELSE
    CALL print("* Unknown *")
   ENDIF
   IF (re_ocd=0)
    col 90
    IF ((re_data->readme[d.seq].status IN ("SUCCESS", "FAILED")))
     actual_secs = datetimediff(re_data->readme[d.seq].end_dt_tm,re_data->readme[d.seq].start_dt_tm,5
      ), actual_time = (actual_secs/ ((24.0 * 60.0) * 60.0)),
     CALL print(trim(format(actual_time,re_format),3))
    ELSEIF ((re_data->readme[d.seq].status IN ("NOT RUN", "RUNNING")))
     actual_time = 0.0,
     CALL print("              ")
    ENDIF
    col 105,
    CALL print(trim(re_data->readme[d.seq].status,3))
   ENDIF
   row + 1
   IF (re_ocd)
    category_total = (category_total+ re_data->readme[d.seq].execution_time)
   ELSE
    cat_estimate_total = (cat_estimate_total+ re_data->readme[d.seq].execution_time),
    cat_actual_total = (cat_actual_total+ actual_time)
   ENDIF
  FOOT  category
   row + 1, col 74,
   CALL print("----------")
   IF (re_ocd=0)
    col 90,
    CALL print("----------")
   ENDIF
   row + 1, col 67
   IF (re_ocd)
    CALL print(concat("Total: ",trim(format(category_total,re_format),3))), report_total = (
    report_total+ category_total)
   ELSE
    CALL print(concat("Total: ",trim(format(cat_estimate_total,re_format),3))), col 90,
    CALL print(trim(format(cat_actual_total,re_format),3)),
    rpt_estimate_total = (rpt_estimate_total+ cat_estimate_total), rpt_actual_total = (
    rpt_actual_total+ cat_actual_total)
   ENDIF
   row + 1
  FOOT REPORT
   IF (dre_readme_found)
    row + 1, col 74,
    CALL print("==========")
    IF (re_ocd=0)
     col 90,
     CALL print("==========")
    ENDIF
    row + 1, col 61
    IF (re_ocd)
     CALL print(concat("Grand Total: ",trim(format(report_total,re_format),3)))
    ELSE
     CALL print(concat("Grand Total: ",trim(format(rpt_estimate_total,re_format),3))), col 90,
     CALL print(trim(format(rpt_actual_total,re_format),3))
    ENDIF
   ELSE
    CALL print("No readmes found.")
   ENDIF
  WITH nocounter, nullreport
 ;end select
#2999_report_exit
#9999_exit_program
END GO
