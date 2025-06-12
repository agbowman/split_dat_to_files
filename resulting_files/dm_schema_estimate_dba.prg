CREATE PROGRAM dm_schema_estimate:dba
 PAINT
 SET width = 132
 IF ( NOT (validate(dm_schema_log,0)))
  FREE SET dm_schema_log
  RECORD dm_schema_log(
    1 env_id = f8
    1 run_id = f8
    1 ocd = i4
    1 schema_date = dq8
    1 operation = vc
    1 file_name = vc
    1 table_name = vc
    1 object_name = vc
    1 column_name = vc
    1 op_id = f8
    1 options = vc
  )
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    dm_schema_log->env_id = i.info_number
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE row_count(rc_table)
   SET rc_count = 0
   SELECT INTO "nl:"
    o.row_count
    FROM ref_report_log l,
     ref_report_parms_log p,
     space_objects o,
     ref_instance_id i
    PLAN (l
     WHERE l.report_cd=1
      AND l.end_date IS NOT null)
     JOIN (p
     WHERE (p.report_seq=(l.report_seq+ 0))
      AND p.parm_cd=1)
     JOIN (i
     WHERE (i.environment_id=dm_schema_log->env_id)
      AND cnvtstring(i.instance_cd)=p.parm_value)
     JOIN (o
     WHERE o.segment_name=rc_table
      AND ((o.report_seq+ 0)=l.report_seq))
    ORDER BY l.begin_date
    DETAIL
     rc_count = o.row_count
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
 SUBROUTINE table_missing(tm_dummy)
   SET tm_flag = 1
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name="DM_SCHEMA_LOG"
    DETAIL
     tm_flag = 0
    WITH nocounter
   ;end select
   RETURN(tm_flag)
 END ;Subroutine
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_process TO 2999_process_exit
 GO TO 9999_exit_program
 SUBROUTINE message(m_text)
  CALL text(24,2,m_text)
  CALL accept(24,(size(m_text)+ 3),"P;E"," ")
 END ;Subroutine
#1000_initialize
 IF (table_missing(0))
  SET message = nowindow
  CALL echo("The necessary schema (DM_SCHEMA_LOG and DM_SCHEMA_OP_LOG) doesn't yet exist.")
  GO TO 9999_exit_program
 ENDIF
 IF (validate(run_id,0.0))
  SET details_prompt = 0
 ELSE
  SET details_prompt = 1
  SET run_id = 0.0
 ENDIF
 FREE RECORD ora_version
 RECORD ora_version(
   1 ora_complete_version = vc
 )
 SELECT INTO "nl:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   ora_version->ora_complete_version = p.version
  WITH nocounter
 ;end select
 IF (substring(1,5,ora_version->ora_complete_version) >= "8.1.7")
  SET max_op_count = 20
 ELSE
  SET max_op_count = 14
 ENDIF
 SET defaults_missing = 0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="SCHEMA BENCHMARK*"
   AND i.info_name="DEFAULT"
   AND  EXISTS (
  (SELECT
   l.run_id
   FROM dm_schema_log l
   WHERE l.run_id > 0))
  WITH nocounter
 ;end select
 IF (curqual < max_op_count)
  SET defaults_missing = 1
 ENDIF
 IF (defaults_missing)
  SET save_run_id = run_id
  EXECUTE dm_schema_benchmark
  FREE SET runs
  RECORD runs(
    1 run[*]
      2 run_id = f8
  )
  SET se_i = 0
  SELECT INTO "nl:"
   l.run_id
   FROM dm_schema_log l
   WHERE l.run_id > 0
   DETAIL
    se_i = (se_i+ 1), stat = alterlist(runs->run,se_i), runs->run[se_i].run_id = l.run_id
   WITH nocounter
  ;end select
  FOR (se_i = 1 TO size(runs->run,5))
    EXECUTE dm_schema_recalc_estimate
  ENDFOR
  SET run_id = save_run_id
 ENDIF
 SET cdetails = 0
 SET ctotals = 1
 SET cformat = "DD.HH:MM:SS.CC;3;z"
 SET level = 0
 SET actuals = 0
 SET downtime_exists = 1
 FREE SET work
 RECORD work(
   1 text = vc
 )
#1999_initialize_exit
#2000_process
 CALL clear(1,1)
 CALL box(1,1,3,132)
 CALL text(2,3,"S C H E M A   T I M E   E S T I M A T E S")
 CALL text(5,3,"Enter the RUN ID (help available):")
 SET help =
 SELECT INTO "nl:"
  run_id = cnvtint(l.run_id)";l", l.ocd";l", l.gen_dt_tm"DD-MMM-YYYY HH:MM;;D",
  l.schema_date"DD-MMM-YYYY;;D"
  FROM dm_schema_log l
  WHERE l.run_id > 0
   AND  EXISTS (
  (SELECT
   o.run_id
   FROM dm_schema_op_log o
   WHERE o.run_id=l.run_id))
  WITH nocounter
 ;end select
 WHILE ( NOT (run_id))
  CALL accept(5,38,"9(11)")
  SELECT INTO "nl:"
   l.run_id
   FROM dm_schema_log l
   WHERE l.run_id=curaccept
    AND  EXISTS (
   (SELECT
    o.run_id
    FROM dm_schema_op_log o
    WHERE o.run_id=l.run_id))
   DETAIL
    run_id = curaccept
   WITH nocounter
  ;end select
 ENDWHILE
 SET help = off
 CALL text(5,38,format(run_id,";l"))
 IF (details_prompt)
  CALL text(7,3,"Display operation details or totals only (D/T)?:")
  CALL accept(7,52,"P;CU","D"
   WHERE curaccept IN ("D", "T"))
  CASE (curaccept)
   OF "D":
    SET level = cdetails
   OF "T":
    SET level = ctotals
  ENDCASE
 ELSE
  SET level = cdetails
 ENDIF
 FREE SET logs
 RECORD logs(
   1 log[*]
     2 table_name = vc
     2 operation = vc
     2 est_duration = f8
     2 act_duration = f8
     2 file_name = c30
     2 sort_key = vc
     2 uptime = i2
     2 actuals = i2
     2 rows = vc
 )
 SET log_count = 0
 SELECT INTO "nl:"
  o.table_name
  FROM dm_schema_op_log o,
   dm_schema_log l
  PLAN (l
   WHERE l.run_id=run_id)
   JOIN (o
   WHERE o.run_id=l.run_id
    AND ((o.status IN ("COMPLETE", "RUNNING", null)) OR (o.status="ERROR"
    AND  NOT ( EXISTS (
   (SELECT
    d.run_id
    FROM dm_schema_op_log d
    WHERE o.run_id=d.run_id
     AND o.table_name=d.table_name
     AND o.filename=d.filename
     AND o.op_type=d.op_type
     AND o.obj_name=d.obj_name
     AND d.status="COMPLETE"
     AND o.begin_dt_tm != null
     AND o.begin_dt_tm < d.begin_dt_tm))))) )
  DETAIL
   log_count = (log_count+ 1), stat = alterlist(logs->log,log_count), logs->log[log_count].table_name
    = o.table_name,
   logs->log[log_count].operation = o.op_type, logs->log[log_count].est_duration = o.est_duration,
   logs->log[log_count].act_duration = o.act_duration,
   logs->log[log_count].file_name = cnvtupper(o.filename)
   IF (((findstring("ADD NOT NULL CONSTRAINT",o.op_type)) OR (((findstring(
    "ADD FOREIGN KEY CONSTRAINT",o.op_type)) OR (((findstring("ADD PRIMARY KEY CONSTRAINT",o.op_type)
   ) OR (((findstring("CREATE INDEX",o.op_type)) OR (((findstring("CREATE UNIQUE INDEX",o.op_type))
    OR (((findstring("DROP INDEX",o.op_type)) OR (((findstring("POPULATE DEFAULT VALUE",o.op_type))
    OR (((findstring("CREATE INDEX ONLINE",o.op_type)) OR (((findstring("CREATE UNIQUE INDEX ONLINE",
    o.op_type)) OR (((findstring("ADD NOT NULL CONSTRAINT NOVALIDATE",o.op_type)) OR (findstring(
    "ENABLE NOT NULL CONSTRAINT",o.op_type))) )) )) )) )) )) )) )) )) )) )
    logs->log[log_count].rows = trim(format(o.row_cnt,";,"),3)
   ENDIF
   IF (findstring("D.",logs->log[log_count].file_name))
    logs->log[log_count].sort_key = "A"
   ELSE
    logs->log[log_count].sort_key = "B", logs->log[log_count].uptime = 1
    IF (substring(1,7,logs->log[log_count].file_name)="FIX_OCD")
     downtime_exists = 0
    ENDIF
   ENDIF
   logs->log[log_count].sort_key = concat(logs->log[log_count].sort_key,logs->log[log_count].
    file_name), logs->log[log_count].sort_key = concat(logs->log[log_count].sort_key,format(o
     .act_duration,cformat)), logs->log[log_count].sort_key = concat(logs->log[log_count].sort_key,
    logs->log[log_count].operation)
   IF (o.begin_dt_tm
    AND o.end_dt_tm >= o.begin_dt_tm)
    logs->log[log_count].actuals = 1
   ELSE
    logs->log[log_count].actuals = 0
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD estimates
 RECORD estimates(
   1 estimate[*]
     2 file_name = vc
     2 uncomp_est_total = f8
     2 comp_est_total = f8
     2 act_total = f8
     2 uptime = i2
     2 summ_uncomp_est_total = f8
     2 summ_comp_est_total = f8
     2 summ_act_total = f8
     2 actuals = i2
 )
 SET estimate_count = 0
 SET summ_uncomp_est_total = 0.0
 SET summ_comp_est_total = 0.0
 SET summ_act_total = 0.0
 SET previous_uptime = - (1)
 SELECT INTO "nl:"
  exec = logs->log[d.seq].uptime, file_name = logs->log[d.seq].file_name
  FROM (dummyt d  WITH seq = value(log_count))
  PLAN (d)
  ORDER BY logs->log[d.seq].sort_key
  HEAD file_name
   estimate_count = (estimate_count+ 1), stat = alterlist(estimates->estimate,estimate_count),
   estimates->estimate[estimate_count].file_name = logs->log[d.seq].file_name,
   estimates->estimate[estimate_count].uptime = logs->log[d.seq].uptime
  DETAIL
   IF ((logs->log[d.seq].uptime != previous_uptime))
    summ_uncomp_est_total = 0.0, summ_comp_est_total = 0.0, summ_act_total = 0.0,
    previous_uptime = logs->log[d.seq].uptime
   ENDIF
   estimates->estimate[estimate_count].actuals = logs->log[d.seq].actuals
   IF (estimates->estimate[estimate_count].actuals)
    estimates->estimate[estimate_count].comp_est_total = (estimates->estimate[estimate_count].
    comp_est_total+ logs->log[d.seq].est_duration)
   ELSE
    estimates->estimate[estimate_count].uncomp_est_total = (estimates->estimate[estimate_count].
    uncomp_est_total+ logs->log[d.seq].est_duration)
   ENDIF
   estimates->estimate[estimate_count].act_total = (estimates->estimate[estimate_count].act_total+
   logs->log[d.seq].act_duration)
   IF (estimates->estimate[estimate_count].actuals)
    summ_comp_est_total = (summ_comp_est_total+ logs->log[d.seq].est_duration)
   ELSE
    summ_uncomp_est_total = (summ_uncomp_est_total+ logs->log[d.seq].est_duration)
   ENDIF
   summ_act_total = (summ_act_total+ logs->log[d.seq].act_duration), estimates->estimate[
   estimate_count].summ_uncomp_est_total = summ_uncomp_est_total, estimates->estimate[estimate_count]
   .summ_comp_est_total = summ_comp_est_total,
   estimates->estimate[estimate_count].summ_act_total = summ_act_total
  WITH nocounter
 ;end select
 SET exec_uncomp_est_total = 0.0
 SET exec_comp_est_total = 0.0
 SET exec_act_total = 0.0
 SET file_uncomp_est_total = 0.0
 SET file_comp_est_total = 0.0
 SET file_act_total = 0.0
 SELECT
  exec = logs->log[d.seq].uptime, file_name = logs->log[d.seq].file_name
  FROM (dummyt d  WITH seq = value(log_count))
  PLAN (d)
  ORDER BY logs->log[d.seq].sort_key
  HEAD REPORT
   SUBROUTINE duration(d_value,d_skip)
     IF (((d_value) OR (d_skip)) )
      d_hun = mod(ceil((d_value * 100.0)),100), work->text = concat(trim(format((d_value/ 86400.0),
         "DD.HH:MM:SS;3;Z"),3),".",format(d_hun,"##;P0")),
      CALL print(work->text)
     ENDIF
   END ;Subroutine report
   ,
   CALL center("*** SCHEMA OPERATION TIME ESTIMATE REPORT ***",1,130), row + 2,
   previous_uptime = - (1)
   IF ( NOT (details_prompt))
    FOR (se_i = 1 TO estimate_count)
      IF ((estimates->estimate[se_i].uptime != previous_uptime))
       IF (previous_uptime >= 0)
        row + 2
       ENDIF
       previous_uptime = estimates->estimate[se_i].uptime
       IF (estimates->estimate[se_i].uptime)
        IF (downtime_exists)
         " UPTIME SCHEMA SUMMARY", row + 2
        ELSE
         " UPTIME AND DOWNTIME SCHEMA SUMMARY", row + 2
        ENDIF
       ELSE
        " DOWNTIME SCHEMA SUMMARY", row + 2
       ENDIF
       col 2, "File", col 40,
       "Estimated Uncompleted Ops", col 70, "Estimated Completed Ops",
       col 95, "Actual", row + 1,
       col 2, "-----", col 40,
       "---------------", col 70, "---------------",
       col 95, "---------------", row + 1
      ENDIF
      CALL print(concat("  ",estimates->estimate[se_i].file_name)), col 40,
      CALL duration(estimates->estimate[se_i].uncomp_est_total,1),
      col 70,
      CALL duration(estimates->estimate[se_i].comp_est_total,1), col 95,
      CALL duration(estimates->estimate[se_i].act_total,estimates->estimate[se_i].actuals), row + 1,
      se_flag = 0
      IF (se_i >= estimate_count)
       se_flag = 1
      ELSE
       IF ((estimates->estimate[se_i].uptime != estimates->estimate[(se_i+ 1)].uptime))
        se_flag = 1
       ENDIF
      ENDIF
      IF (se_flag)
       col 40, "---------------", col 70,
       "---------------", col 95, "---------------",
       row + 1
       IF (estimates->estimate[se_i].uptime)
        IF (downtime_exists)
         "  Total Uptime"
        ENDIF
       ELSE
        "  Total Downtime"
       ENDIF
       col 40,
       CALL duration(estimates->estimate[se_i].summ_uncomp_est_total,1), col 70,
       CALL duration(estimates->estimate[se_i].summ_comp_est_total,1), col 95,
       CALL duration(estimates->estimate[se_i].summ_act_total,estimates->estimate[se_i].actuals)
      ENDIF
    ENDFOR
    row + 2
   ENDIF
  HEAD exec
   IF (logs->log[d.seq].uptime)
    IF (downtime_exists)
     " UPTIME SCHEMA DETAILS"
    ELSE
     " UPTIME AND DOWNTIME SCHEMA DETAILS"
    ENDIF
   ELSE
    " DOWNTIME SCHEMA DETAILS"
   ENDIF
   row + 2, exec_uncomp_est_total = 0.0, exec_comp_est_total = 0.0,
   exec_act_total = 0.0, exec_actuals = 0
  HEAD file_name
   CALL print(concat("    Filename: ",trim(logs->log[d.seq].file_name,3))), row + 2
   IF (level=cdetails)
    "     Table                          Operation                   Estimated       Actual          Rows",
    row + 1,
    "     -----                          ---------                   ---------       ------          ----"
   ELSE
    "                                                                Estimated       Actual", row + 1,
    "                                                                ---------       ------"
   ENDIF
   file_uncomp_est_total = 0.0, file_comp_est_total = 0.0, file_act_total = 0.0,
   file_actuals = 0
  DETAIL
   exec_act_total = (exec_act_total+ logs->log[d.seq].act_duration), exec_actuals = logs->log[d.seq].
   actuals
   IF (exec_actuals)
    exec_comp_est_total = (exec_comp_est_total+ logs->log[d.seq].est_duration)
   ELSE
    exec_uncomp_est_total = (exec_uncomp_est_total+ logs->log[d.seq].est_duration)
   ENDIF
   file_act_total = (file_act_total+ logs->log[d.seq].act_duration), file_actuals = logs->log[d.seq].
   actuals
   IF (file_actuals)
    file_comp_est_total = (file_comp_est_total+ logs->log[d.seq].est_duration)
   ELSE
    file_uncomp_est_total = (file_uncomp_est_total+ logs->log[d.seq].est_duration)
   ENDIF
   IF (level=cdetails)
    row + 1, col 05
    IF (size(trim(logs->log[d.seq].table_name,3)))
     logs->log[d.seq].table_name
    ELSE
     "<NONE>"
    ENDIF
    col 36, logs->log[d.seq].operation, col 64,
    CALL duration(logs->log[d.seq].est_duration,1), col 80,
    CALL duration(logs->log[d.seq].act_duration,logs->log[d.seq].actuals),
    col 96, logs->log[d.seq].rows
   ENDIF
  FOOT  file_name
   IF (level=cdetails)
    row + 2, "                                                                ---------       ------",
    row + 1
   ELSE
    row + 1
   ENDIF
   col 5, "Completed Operations total :", col 64,
   CALL duration(file_comp_est_total,1), col 80,
   CALL duration(file_act_total,file_actuals),
   row + 1, col 5, "Uncompleted Operations total :",
   col 64,
   CALL duration(file_uncomp_est_total,1), row + 2
  FOOT  exec
   row + 1, "                                                                =========       ======",
   row + 1,
   col 5, "Completed Operations Total :", col 64,
   CALL duration(exec_comp_est_total,1), col 80,
   CALL duration(exec_act_total,exec_actuals),
   row + 1, col 5, "Uncompleted Operations Total :",
   col 64,
   CALL duration(exec_uncomp_est_total,1), row + 2
  FOOT REPORT
   row + 2,
   CALL center("*** END OF REPORT ***",1,130)
  WITH nocounter, noformfeed
 ;end select
#2999_process_exit
#9999_exit_program
 CALL clear(1,1)
END GO
