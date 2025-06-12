CREATE PROGRAM dm_schema_run_estimate:dba
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
 EXECUTE FROM 2000_report TO 2999_report_exit
 GO TO 9999_exit_program
 SUBROUTINE kick(k_message)
   CALL echo("***")
   CALL echo(k_message)
   CALL echo("***")
   GO TO 9999_exit_program
 END ;Subroutine
#1000_initialize
 IF (table_missing(0))
  CALL echo("The necessary schema (DM_SCHEMA_LOG and DM_SCHEMA_OP_LOG) doesn't yet exist.")
  GO TO 9999_exit_program
 ENDIF
 SET run_id = 0.0
 SET run_id =  $1
 IF (run_id)
  SELECT INTO "nl:"
   l.run_id
   FROM dm_schema_log l
   WHERE l.run_id=run_id
    AND  EXISTS (
   (SELECT
    o.run_id
    FROM dm_schema_op_log o
    WHERE o.run_id=l.run_id))
   WITH nocounter
  ;end select
  IF ( NOT (curqual))
   CALL kick(
    "This RUN ID is invalid or has no operations in the log.  Please provide a valid RUN ID.")
  ENDIF
 ELSE
  CALL kick("Please provide a valid RUN ID.")
 ENDIF
#1999_initialize_exit
#2000_report
 EXECUTE dm_schema_estimate
#2999_report_exit
#9999_exit_program
END GO
