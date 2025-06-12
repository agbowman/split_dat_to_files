CREATE PROGRAM dm_schema_estimate_op_log:dba
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
 SUBROUTINE next_id(ni_dummy)
   SET ni_id = 0.0
   SELECT INTO "nl:"
    temp_id = seq(dm_seq,nextval)
    FROM dual
    DETAIL
     ni_id = temp_id
    WITH nocounter
   ;end select
   RETURN(ni_id)
 END ;Subroutine
 SUBROUTINE per_row(pr_operation)
   IF (((findstring("ADD NOT NULL CONSTRAINT",pr_operation)) OR (((findstring(
    "ADD FOREIGN KEY CONSTRAINT",pr_operation)) OR (((findstring("ADD PRIMARY KEY CONSTRAINT",
    pr_operation)) OR (((findstring("CREATE INDEX",pr_operation)) OR (((findstring(
    "CREATE UNIQUE INDEX",pr_operation)) OR (((findstring("DROP INDEX",pr_operation)) OR (findstring(
    "POPULATE DEFAULT VALUE",pr_operation))) )) )) )) )) )) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#1000_initialize
 IF (table_missing(0))
  GO TO 9999_exit_program
 ENDIF
 FREE SET eol_data
 RECORD eol_data(
   1 tablespace_name = vc
   1 rows = i4
 )
#1999_initialize_exit
#2000_process
 IF (dm_schema_log->op_id)
  IF (size(trim(dm_schema_log->file_name,3)))
   SELECT INTO value(dm_schema_log->file_name)
    FROM dual
    DETAIL
     row + 1,
     CALL print(concat("dm_schema_actual_stop ",trim(cnvtstring(dm_schema_log->op_id),3)," go")), row
      + 2
    WITH nocounter, maxcol = 150, maxrow = 2,
     format = variable, noformfeed, append
   ;end select
  ENDIF
  SET dm_schema_log->op_id = 0
  GO TO 9999_exit_program
 ENDIF
 IF (per_row(dm_schema_log->operation))
  SET eol_data->rows = row_count(dm_schema_log->table_name)
 ELSE
  SET eol_data->rows = 1
 ENDIF
 SET duration = 0.0
 IF (eol_data->rows)
  SET eol_data->tablespace_name = ""
  SELECT INTO "nl:"
   t.tablespace_name
   FROM user_tables t
   WHERE (t.table_name=dm_schema_log->table_name)
   DETAIL
    CASE (dm_schema_log->operation)
     OF "ADD COLUMN":
      eol_data->tablespace_name = t.tablespace_name
     OF "ADD DEFAULT VALUE":
      eol_data->tablespace_name = t.tablespace_name
     OF "COALESCE TABLESPACE":
      eol_data->tablespace_name = t.tablespace_name
     OF "CREATE TABLE":
      eol_data->tablespace_name = t.tablespace_name
     OF "MODIFY COLUMN DATA TYPE":
      eol_data->tablespace_name = t.tablespace_name
     OF "POPULATE DEFAULT VALUE":
      eol_data->tablespace_name = t.tablespace_name
     ELSE
      eol_data->tablespace_name = concat("I_",substring(3,28,t.tablespace_name))
    ENDCASE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain=concat("SCHEMA BENCHMARK ",dm_schema_log->operation)
    AND (i.info_name=eol_data->tablespace_name)
    AND i.info_number > 0.0
   DETAIL
    duration = ((eol_data->rows * i.info_number)/ ((24.0 * 60.0) * 60.0))
   WITH nocounter
  ;end select
  IF ( NOT (curqual))
   SELECT INTO "nl:"
    i.info_number
    FROM dm_info i
    WHERE i.info_domain=concat("SCHEMA BENCHMARK ",dm_schema_log->operation)
     AND i.info_name="DEFAULT"
     AND i.info_number > 0.0
    DETAIL
     duration = ((eol_data->rows * i.info_number)/ ((24.0 * 60.0) * 60.0))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET dm_schema_log->op_id = next_id(0)
 INSERT  FROM dm_schema_op_log o
  SET o.op_id = dm_schema_log->op_id, o.run_id = dm_schema_log->run_id, o.begin_dt_tm = null,
   o.end_dt_tm = null, o.est_duration = duration, o.act_duration = null,
   o.op_type = dm_schema_log->operation, o.table_name = dm_schema_log->table_name, o.row_cnt =
   eol_data->rows,
   o.obj_name = dm_schema_log->object_name, o.filename = dm_schema_log->file_name, o.status =
   "PENDING"
  WITH nocounter
 ;end insert
 IF ( NOT (curqual))
  CALL echo("ERROR: Unable to create new DM_SCHEMA_OP_LOG row.")
  SET dm_schema_log->op_id = 0
  GO TO 9999_exit_program
 ENDIF
 COMMIT
 IF (size(trim(dm_schema_log->file_name,3)))
  SELECT INTO value(dm_schema_log->file_name)
   FROM dual
   DETAIL
    row + 1,
    CALL print(concat("dm_schema_actual_start ",trim(cnvtstring(dm_schema_log->op_id),3)," go")), row
     + 2
   WITH nocounter, maxcol = 150, maxrow = 2,
    format = variable, noformfeed, append
  ;end select
 ENDIF
#2999_process_exit
#9999_exit_program
END GO
