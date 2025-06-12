CREATE PROGRAM dm_ocd_schema_runner:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 SET more_ddl = 1
 WHILE (more_ddl)
   SET sr_data->rowid = ""
   SELECT INTO "nl:"
    l.rowid
    FROM dm_ocd_log l
    WHERE (l.environment_id=sr_data->env_id)
     AND l.project_type="SCHEMA DDL"
     AND findstring("2.dat",l.project_name) > 0
     AND l.ocd BETWEEN sr_data->low_ocd AND sr_data->high_ocd
     AND l.status = null
    ORDER BY l.estimated_time
    DETAIL
     sr_data->rowid = l.rowid, sr_data->file = l.project_name
    WITH nocounter, forupdatewait(l)
   ;end select
   IF (curqual)
    CALL dsr_execute_ddl(sr_data->file)
   ELSE
    SELECT INTO "nl:"
     l.rowid
     FROM dm_ocd_log l
     WHERE (l.environment_id=sr_data->env_id)
      AND l.project_type="SCHEMA DDL"
      AND findstring("2d.dat",l.project_name) > 0
      AND findstring("dmsteps_2d.dat",l.project_name)=0
      AND l.ocd BETWEEN sr_data->low_ocd AND sr_data->high_ocd
      AND l.status = null
      AND sqlpassthru(
      "not exists ( select u.project_name from dm_ocd_log u where u.environment_id = l.environment_id"
      )
      AND sqlpassthru(" u.project_type = l.project_type and u.ocd = l.ocd")
      AND sqlpassthru(" u.project_name = replace(l.project_name,'2d.dat','2.dat')")
      AND sqlpassthru(" u.status = 'RUNNING' )")
     ORDER BY l.estimated_time
     DETAIL
      sr_data->rowid = l.rowid, sr_data->file = l.project_name
     WITH nocounter, forupdatewait(l)
    ;end select
    IF (curqual)
     CALL dsr_execute_ddl(sr_data->file)
    ELSE
     SELECT INTO "nl:"
      l.rowid
      FROM dm_ocd_log l
      WHERE (l.environment_id=sr_data->env_id)
       AND l.project_type="SCHEMA DDL"
       AND findstring("dmsteps_2d.dat",l.project_name) > 0
       AND l.ocd BETWEEN sr_data->low_ocd AND sr_data->high_ocd
       AND l.status = null
       AND sqlpassthru(
       "not exists ( select u.project_name from dm_ocd_log u where u.environment_id = l.environment_id"
       )
       AND sqlpassthru(" u.project_type = l.project_type and u.ocd = l.ocd")
       AND sqlpassthru(" u.status = 'RUNNING' )")
      DETAIL
       sr_data->rowid = l.rowid, sr_data->file = l.project_name
      WITH nocounter, maxqual(l,1), forupdatewait(l)
     ;end select
     IF (curqual)
      CALL dsr_execute_ddl(sr_data->file)
     ELSE
      SET more_ddl = 0
     ENDIF
    ENDIF
   ENDIF
 ENDWHILE
 GO TO 9999_exit_program
 SUBROUTINE dsr_execute_ddl(ded_ddl_file)
   SET sr_data->log_file = ded_ddl_file
   IF (findstring("2.dat",ded_ddl_file) > 0)
    SET sr_data->log_file = replace(ded_ddl_file,"2.dat","4.dat",2)
   ELSEIF (findstring("2d.dat",ded_ddl_file) > 0)
    SET sr_data->log_file = replace(ded_ddl_file,"2d.dat","4d.dat",2)
   ELSE
    SET sr_data->log_file = replace(ded_ddl_file,".dat",".log",2)
   ENDIF
   CALL echo(build("Starting file:",ded_ddl_file))
   IF (dos_debug=1)
    CALL trace(7)
   ENDIF
   CALL compile(ded_ddl_file,sr_data->log_file)
   CALL echo(build("Finished file:",ded_ddl_file))
   IF (dos_debug=1)
    CALL trace(7)
   ENDIF
 END ;Subroutine
 SUBROUTINE sr_mark(m_rowid,m_status,m_done)
  IF (m_done)
   UPDATE  FROM dm_ocd_log l
    SET l.status = m_status, l.end_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE l.rowid=m_rowid
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM dm_ocd_log l
    SET l.status = m_status, l.start_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE l.rowid=m_rowid
    WITH nocounter
   ;end update
  ENDIF
  COMMIT
 END ;Subroutine
#1000_initialize
 FREE RECORD sr_data
 RECORD sr_data(
   1 low_ocd = i4
   1 high_ocd = i4
   1 env_id = f8
   1 rowid = vc
   1 file = vc
   1 log_file = vc
 )
 IF (validate(runner_ocd,0))
  SET sr_data->low_ocd = runner_ocd
  SET sr_data->high_ocd = runner_ocd
 ELSE
  SET sr_data->high_ocd = 999999
 ENDIF
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
   AND i.info_number > 0.0
  DETAIL
   sr_data->env_id = i.info_number
  WITH nocounter
 ;end select
 SET dos_debug = 0
 IF (validate(dm2_debug_flag,- (1)) > 0)
  SET dos_debug = 1
 ENDIF
#1999_initialize_exit
#9999_exit_program
END GO
