CREATE PROGRAM dm_purge_data_child_dpo:dba
 DECLARE dpdcd_err_code = i4 WITH protect, noconstant(0)
 DECLARE dpdcd_err_msg = vc WITH protect, noconstant(" ")
 DECLARE dpdcd_i18var = vc WITH protect, noconstant(" ")
 DECLARE dpdcd_original_module = vc WITH protect, noconstant("")
 DECLARE dpdcd_original_action = vc WITH protect, noconstant("")
 DECLARE iown = vc WITH protect, noconstant
 DECLARE itab = vc WITH protect, noconstant
 DECLARE icq = vc WITH protect, noconstant
 DECLARE ifs = f8 WITH protect, noconstant
 DECLARE imr = f8 WITH protect, noconstant
 DECLARE ia = f8 WITH protect, noconstant
 DECLARE itn = i4 WITH protect, noconstant
 DECLARE ddtto_total_deleted = f8 WITH protect, noconstant(0.0)
 DECLARE ddtto_delete_seconds = f8 WITH protect, noconstant(0.0)
 DECLARE ddtto_fetch_seconds = f8 WITH protect, noconstant(0.0)
 DECLARE ddtto_forall_delete(dfd_owner=vc,dfd_table_name=vc,dfd_cursor_query=vc,dfd_fetch_size=f8,
  dfd_max_rows_to_purge=f8,
  dfd_audit_mode=f8,dfd_template_nbr=i4,dfd_tot_deleted=f8,dfd_del_seconds=f8,dfd_fetch_seconds=f8)
  = null WITH sql = "dm_purge_objects.forall_delete"
 DECLARE dpdcd_perform_logging(null) = i2
 IF (validate(request->debug_mode,"Z") != "Z")
  SET trace = rdbdebug
  SET trace = rdbbind
  SET trace = rdbbind2
 ENDIF
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF (dpd_modact_allowed_ind)
  SELECT INTO "nl:"
   vs.module, vs.action
   FROM v$session vs
   WHERE vs.audsid=cnvtreal(currdbhandle)
   HEAD REPORT
    dpdcd_original_module = vs.module, dpdcd_original_action = vs.action
   WITH nocounter, format
  ;end select
  CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat(
    "CHROWIDDPO:",cnvtstring(v_log_id)))
 ENDIF
 CALL parser(concat("execute ",trim(jobs->data[job_ndx].program_str,3)," go"))
 IF ((dpo_reply->status_data.status="F"))
  IF (dpdcd_perform_logging(null)=0)
   CALL echo("dpdcd: There were logging errors")
   CALL echorecord(dpo_reply)
  ENDIF
  GO TO exit_program
 ENDIF
 IF (dpd_modact_allowed_ind)
  CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CHDPO:",
    cnvtstring(v_log_id)))
 ENDIF
 SET v_info_char = concat(jobs->data[job_ndx].program_str," completed - ",format(cnvtdatetime(curdate,
    curtime3),";;q"))
 UPDATE  FROM dm_info di
  SET di.info_char = concat(di.info_char,v_info_char)
  WHERE di.info_domain="DM PURGE INFO"
   AND di.info_name=dpd_info_name
   AND di.info_number=dpd_run_id
  WITH nocounter
 ;end update
 SET dpdcd_err_code = error(dpdcd_err_msg,1)
 IF (dpdcd_err_code > 0)
  SET dpo_reply->err_code = dpdcd_err_code
  SET dpo_reply->status_data.status = "F"
  SET dpdcd_i18var = uar_i18nbuildmessage(i18nhandle,"dm_info1","%1","s",dpdcd_err_msg)
  SET dpo_reply->err_msg = dpdcd_i18var
  IF (dpdcd_perform_logging(null)=0)
   CALL echo("dpdcd: There were logging errors")
   CALL echorecord(dpo_reply)
  ENDIF
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET ia = b_request->purge_flag
 SET iown = dpo_reply->owner_name
 SET itab = dpo_reply->table_name
 SET icq = dpo_reply->cursor_query
 SET ifs = dpo_reply->fetch_size
 SET imr = b_request->max_rows
 SET itn = jobs->data[job_ndx].template_nbr
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo(build("iown:",iown))
  CALL echo(build("itab:",itab))
  CALL echo(build("icq:",icq))
  CALL echo(build("ifs:",ifs))
  CALL echo(build("imr:",imr))
  CALL echo(build("ia:",ia))
 ENDIF
 IF (dpd_modact_allowed_ind)
  CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CHDELDPO:",
    cnvtstring(v_log_id)))
 ENDIF
 CALL ddtto_forall_delete(iown,itab,icq,ifs,imr,
  ia,itn,ddtto_total_deleted,ddtto_delete_seconds,ddtto_fetch_seconds)
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo(build("ddtto_total_deleted:",ddtto_total_deleted))
  CALL echo(build("ddtto_delete_seconds:",ddtto_delete_seconds))
 ENDIF
 SET dpdcd_err_code = error(dpdcd_err_msg,1)
 IF (dpdcd_err_code > 0)
  SET dpo_reply->err_code = dpdcd_err_code
  SET dpo_reply->status_data.status = "F"
  SET dpdcd_i18var = uar_i18nbuildmessage(i18nhandle,"foralldelete","%1","s",dpdcd_err_msg)
  SET dpo_reply->err_msg = dpdcd_i18var
  IF (dpdcd_perform_logging(null)=0)
   CALL echo("dpdcd: There were logging errors")
   CALL echorecord(dpo_reply)
  ENDIF
  GO TO exit_program
 ENDIF
 SET dpo_reply->rows_deleted = ddtto_total_deleted
 SET dpo_reply->delete_time = round((ddtto_delete_seconds/ 60),2)
 SET dpo_reply->fetch_time = round((ddtto_fetch_seconds/ 60),2)
 SET dpo_reply->status_data.status = "S"
 IF (dpdcd_perform_logging(null)=0)
  CALL echo("dpdcd: There were logging errors")
 ENDIF
 GO TO exit_program
 SUBROUTINE dpdcd_perform_logging(null)
   IF (dpd_modact_allowed_ind)
    CALL set_module(concat("DMPURGE:",cnvtstring(jobs->data[job_ndx].template_nbr)),concat("CHDPO:",
      cnvtstring(v_log_id)))
   ENDIF
   IF ((dpo_reply->err_code=0)
    AND (dpo_reply->rows_deleted >= b_request->max_rows))
    SET dpdcd_i18var = concat(
     "There are additional rows remaining that can be purged, but not all of the requested rows ",
     "could be purged at this time.  No errors have occurred.  You may want to schedule additional ",
     "purge jobs in order to purge these remaining rows.")
    SET dpdcd_i18var = uar_i18ngetmessage(i18nhandle,"rowsleftkey",dpdcd_i18var)
    SET dpo_reply->err_msg = dpdcd_i18var
   ENDIF
   INSERT  FROM dm_purge_job_log jl
    SET jl.log_id = v_log_id, jl.job_id = jobs->data[job_ndx].job_id, jl.purge_flag = jobs->data[
     job_ndx].purge_flag,
     jl.start_dt_tm = cnvtdatetime(v_start_date), jl.end_dt_tm = cnvtdatetime(curdate,curtime3), jl
     .parent_table = dpo_reply->table_name,
     jl.parent_rows = dpo_reply->rows_deleted, jl.child_rows = 0, jl.err_msg = dpo_reply->err_msg,
     jl.err_code = dpo_reply->err_code, jl.updt_dt_tm = cnvtdatetime(curdate,curtime3), jl.updt_task
      = reqinfo->updt_task,
     jl.updt_cnt = 0, jl.updt_id = reqinfo->updt_id, jl.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   COMMIT
   INSERT  FROM dm_purge_job_log_timing jlt
    SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt.value_key =
     v_logging_rowid_key,
     jlt.value_nbr = dpo_reply->fetch_time, jlt.updt_applctx = reqinfo->updt_applctx, jlt.updt_cnt =
     0,
     jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   COMMIT
   IF ((jobs->data[job_ndx].purge_flag != c_audit))
    INSERT  FROM dm_purge_job_log_tab jlt
     SET jlt.log_id = v_log_id, jlt.table_name = dpo_reply->table_name, jlt.purge_flag = jobs->data[
      job_ndx].purge_flag,
      jlt.job_id = jobs->data[job_ndx].job_id, jlt.num_rows = dpo_reply->rows_deleted, jlt.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      jlt.updt_task = reqinfo->updt_task, jlt.updt_cnt = 0, jlt.updt_id = reqinfo->updt_id,
      jlt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    COMMIT
    INSERT  FROM dm_purge_job_log_timing jlt
     SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt.value_key
       = concat(v_logging_purge_prefix,dpo_reply->table_name),
      jlt.value_nbr = dpo_reply->delete_time, jlt.updt_applctx = reqinfo->updt_applctx, jlt.updt_cnt
       = 0,
      jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt.updt_task
       = reqinfo->updt_task
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF ((dpo_reply->err_code != 0))
    UPDATE  FROM dm_purge_job pj
     SET pj.last_run_dt_tm = cnvtdatetime(v_start_date), pj.last_run_status_flag = c_sf_failed
     WHERE (pj.job_id=jobs->data[job_ndx].job_id)
    ;end update
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF (dpd_modact_allowed_ind)
  CALL set_module(dpdcd_original_module,dpdcd_original_action)
 ENDIF
END GO
