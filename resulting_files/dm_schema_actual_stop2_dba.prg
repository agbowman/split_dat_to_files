CREATE PROGRAM dm_schema_actual_stop2:dba
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
#1000_initialize
 IF (validate(ddl_log->err_file,"X")="X")
  GO TO 9999_exit_program
 ENDIF
 SET operation_id =  $1
 IF (table_missing(0))
  GO TO write_error
 ENDIF
#1999_initialize_exit
#2000_process
 IF (operation_id=0)
  GO TO write_error
 ENDIF
 SET now = cnvtdatetime(curdate,curtime3)
 SET duration = 0.0
 SELECT INTO "nl:"
  o.begin_dt_tm
  FROM dm_schema_op_log o
  WHERE o.op_id=operation_id
  DETAIL
   duration = (datetimediff(now,o.begin_dt_tm) * 86400.0)
  WITH nocounter
 ;end select
 UPDATE  FROM dm_schema_op_log o
  SET o.end_dt_tm = cnvtdatetime(now), o.status = evaluate(ddl_log->err_code,0,"COMPLETE","ERROR"), o
   .error_msg = evaluate(ddl_log->err_code,0,null,ddl_log->err_str),
   o.act_duration = duration
  WHERE o.op_id=operation_id
  WITH nocounter
 ;end update
 COMMIT
#write_error
 IF ((ddl_log->err_code != 0))
  IF (findstring("ORA-02275",ddl_log->err_str)=0)
   SELECT INTO value(ddl_log->err_file)
    FROM dual
    DETAIL
     ddl_log->cmd_str, row + 1, ddl_log->err_str,
     row + 1, row + 1
    WITH nocounter, format = variable, noheading,
     formfeed = none, maxcol = 512, maxrow = 1,
     append
   ;end select
  ENDIF
 ENDIF
#2999_process_exit
#9999_exit_program
END GO
