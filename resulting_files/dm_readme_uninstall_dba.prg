CREATE PROGRAM dm_readme_uninstall:dba
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
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_uninstall TO 2000_uninstall_exit
 GO TO 9999_exit_program
#1000_initialize
 SET ru_ocd = cnvtint( $1)
#1999_initialize_exit
#2000_uninstall
 DELETE  FROM dm_ocd_log l
  WHERE l.environment_id=rm_env_id
   AND l.project_type=rm_readme
   AND l.ocd=ru_ocd
  WITH nocounter
 ;end delete
 COMMIT
 SET reply->status_data.status = "S"
#2000_uninstall_exit
#9999_exit_program
END GO
