CREATE PROGRAM dm_schema_recalc_estimate:dba
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
 SUBROUTINE per_row(pr_operation)
   IF (((findstring("ADD NOT NULL CONSTRAINT",pr_operation)) OR (((findstring(
    "ADD FOREIGN KEY CONSTRAINT",pr_operation)) OR (((findstring("ADD PRIMARY KEY CONSTRAINT",
    pr_operation)) OR (((findstring("CREATE INDEX",pr_operation)) OR (((findstring(
    "CREATE UNIQUE INDEX",pr_operation)) OR (((findstring("DROP INDEX",pr_operation)) OR (((
   findstring("POPULATE DEFAULT VALUE",pr_operation)) OR (((findstring("CREATE INDEX ONLINE",
    pr_operation)) OR (((findstring("CREATE UNIQUE INDEX ONLINE",pr_operation)) OR (((findstring(
    "ADD NOT NULL CONSTRAINT NOVALIDATE",pr_operation)) OR (findstring("ENABLE NOT NULL CONSTRAINT",
    pr_operation))) )) )) )) )) )) )) )) )) )) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#1000_initialize
 IF (table_missing(0))
  GO TO 9999_exit_program
 ENDIF
 SET dsr_run_id = 0.0
 IF (validate(runs->run[1].run_id,0))
  SET dsr_run_id = runs->run[se_i].run_id
 ELSE
  CALL text(2,1,
   "Please choose the run_id for the ocd or schema_date you installed from the help window.")
  SET help =
  SELECT DISTINCT INTO "nl:"
   d.run_id, d.ocd, d.schema_date
   FROM dm_schema_log d,
    dm_schema_op_log o
   PLAN (d)
    JOIN (o
    WHERE o.run_id=d.run_id)
   ORDER BY d.ocd DESC, d.schema_date DESC
   WITH nocounter
  ;end select
  CALL accept(2,100,"P(20);CSF")
  SET help = off
  SET dsr_run_id = cnvtreal(curaccept)
 ENDIF
#1999_initialize_exit
#2000_process
 CALL text(24,1,"RECALCULATING SCHEMA ESTIMATES, PLEASE WAIT......")
 FREE SET operations
 RECORD operations(
   1 operation[*]
     2 op_id = f8
     2 op_type = vc
     2 table_name = vc
     2 tablespace_name = vc
     2 rows = i4
     2 duration = f8
 )
 SET operation_count = 0
 SELECT INTO "nl:"
  o.op_id
  FROM dm_schema_op_log o
  WHERE o.run_id=dsr_run_id
  DETAIL
   operation_count = (operation_count+ 1), stat = alterlist(operations->operation,operation_count),
   operations->operation[operation_count].op_id = o.op_id,
   operations->operation[operation_count].op_type = o.op_type, operations->operation[operation_count]
   .table_name = cnvtupper(trim(o.table_name,3))
  WITH nocounter
 ;end select
 IF ( NOT (operation_count))
  CALL echo("No operations found for the given run ID.")
  GO TO 9999_exit_program
 ENDIF
 FOR (i = 1 TO operation_count)
   IF (per_row(operations->operation[i].op_type))
    SET operations->operation[i].rows = row_count(operations->operation[i].table_name)
   ELSE
    SET operations->operation[i].rows = 1
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  t.tablespace_name
  FROM user_tables t,
   (dummyt d  WITH seq = value(operation_count))
  PLAN (d
   WHERE (operations->operation[d.seq].table_name > " "))
   JOIN (t
   WHERE (t.table_name=operations->operation[d.seq].table_name))
  DETAIL
   CASE (operations->operation[d.seq].op_type)
    OF "ADD COLUMN":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    OF "ADD DEFAULT VALUE":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    OF "COALESCE TABLESPACE":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    OF "CREATE TABLE":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    OF "MODIFY COLUMN DATA TYPE":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    OF "POPULATE DEFAULT VALUE":
     operations->operation[d.seq].tablespace_name = t.tablespace_name
    ELSE
     operations->operation[d.seq].tablespace_name = concat("I_",substring(3,28,t.tablespace_name))
   ENDCASE
  WITH nocounter
 ;end select
 FOR (i = 1 TO operation_count)
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain=concat("SCHEMA BENCHMARK ",operations->operation[i].op_type)
    AND (i.info_name=operations->operation[i].tablespace_name)
    AND i.info_number > 0.0
   DETAIL
    operations->operation[i].duration = (operations->operation[i].rows * i.info_number)
   WITH nocounter
  ;end select
  IF ( NOT (curqual))
   SELECT INTO "nl:"
    i.info_number
    FROM dm_info i
    WHERE i.info_domain=concat("SCHEMA BENCHMARK ",operations->operation[i].op_type)
     AND i.info_name="DEFAULT"
     AND i.info_number > 0.0
    DETAIL
     operations->operation[i].duration = (operations->operation[i].rows * i.info_number)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 UPDATE  FROM dm_schema_op_log o,
   (dummyt d  WITH seq = value(operation_count))
  SET o.est_duration = operations->operation[d.seq].duration, o.row_cnt = operations->operation[d.seq
   ].rows
  PLAN (d)
   JOIN (o
   WHERE (o.op_id=operations->operation[d.seq].op_id))
  WITH nocounter
 ;end update
 COMMIT
 CALL echo("All estimates recalculated.")
#2999_process_exit
#9999_exit_program
END GO
