CREATE PROGRAM dm_schema_op_log:dba
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
#1000_initialize
 IF (table_missing(0))
  GO TO 9999_exit_program
 ENDIF
 SET dm_schema_log->run_id = 0
#1999_initialize_exit
#2000_process
 IF (dm_schema_log->ocd)
  SELECT INTO "nl:"
   l.run_id
   FROM dm_schema_log l
   WHERE (l.ocd=dm_schema_log->ocd)
   DETAIL
    dm_schema_log->run_id = l.run_id
   WITH nocounter
  ;end select
  IF ((dm_schema_log->run_id > 0))
   DELETE  FROM dm_schema_op_log o
    WHERE (o.run_id=dm_schema_log->run_id)
     AND o.end_dt_tm = null
     AND o.op_id > 0
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF (dm_schema_log->schema_date)
  SELECT
   IF (dis_utc_ind)
    WHERE l.schema_date=cnvtdatetimeutc(dm_schema_log->schema_date)
   ELSE
    WHERE l.schema_date=cnvtdatetime(dm_schema_log->schema_date)
   ENDIF
   INTO "nl:"
   l.run_id
   FROM dm_schema_log l
   DETAIL
    dm_schema_log->run_id = l.run_id
   WITH nocounter
  ;end select
  IF ((dm_schema_log->run_id > 0))
   DELETE  FROM dm_schema_op_log o
    WHERE (o.run_id=dm_schema_log->run_id)
     AND o.end_dt_tm = null
     AND o.op_id > 0
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF ( NOT (dm_schema_log->run_id))
  SET dm_schema_log->run_id = next_id(0)
  IF (dis_utc_ind)
   INSERT  FROM dm_schema_log l
    SET l.run_id = dm_schema_log->run_id, l.gen_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd =
     dm_schema_log->ocd,
     l.schema_date = cnvtdatetimeutc(dm_schema_log->schema_date)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM dm_schema_log l
    SET l.run_id = dm_schema_log->run_id, l.gen_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd =
     dm_schema_log->ocd,
     l.schema_date = cnvtdatetime(dm_schema_log->schema_date)
    WITH nocounter
   ;end insert
  ENDIF
  IF ( NOT (curqual))
   CALL echo("ERROR: Unable to create new DM_SCHEMA_LOG row.")
   GO TO 9999_exit_program
  ENDIF
 ELSE
  UPDATE  FROM dm_schema_log l
   SET l.gen_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (l.run_id=dm_schema_log->run_id)
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
#2999_process_exit
#9999_exit_program
END GO
