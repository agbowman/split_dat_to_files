CREATE PROGRAM dba_create_v500_db10
 SET message = window
 SET env_id = request->environment_id
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET target_os = request->target_os
 SET dbname = request->database_name
 SET max_g = 0
 SET max_m = 0
 SELECT INTO "nl:"
  *
  FROM dm_env_files
  WHERE environment_id=cnvtint(env_id)
   AND file_type="SYSTEM"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET exit_message = "ERROR: No system data file found found in admin for this environment! Exit..."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM dm_env_db_config
  WHERE environment_id=cnvtint(env_id)
   AND parm_type="SYSTEM"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET exit_message =
  "ERROR: No system init.ora parameters found in admin for this environment! Exit..."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM dm_env_redo_logs
  WHERE environment_id=cnvtint(env_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET exit_message = "ERROR: no redo log entries found in admin for this environment! Exit..."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  group_num = max(a.group_number), member_num = max(a.member_number)
  FROM dm_env_redo_logs a
  WHERE a.environment_id=cnvtint(env_id)
  DETAIL
   max_g = group_num, max_m = member_num
  WITH nocounter
 ;end select
 CALL clear(23,05,73)
 CALL text(23,05,"Generate database creation script...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL vms_gen_db_creation_script(1)
  CALL clear(23,05,74)
 ELSEIF (target_os="AIX")
  CALL aix_gen_db_creation_script(1)
  CALL clear(23,05,74)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 SUBROUTINE vms_gen_db_creation_script(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET ora_db = concat(trim(dbdisk),":[",trim(dbstr),".DB_",trim(dbname),
    "]")
   SET dirstr = concat(":[",trim(dbstr),".DB_",trim(dbname),"]")
   SET logical ddd value(dbdir)
   SELECT INTO concat("ddd:","CREATE_",trim(dbname),".SQL")
    a.file_name, a.disk_name, a.file_size,
    a.tablespace_name
    FROM dm_env_files a
    WHERE a.environment_id=cnvtint(env_id)
     AND a.file_type="SYSTEM"
    HEAD PAGE
     col 0, "remark  Oracle database creation script", row + 1
     IF ((dm_env_import_request->base_oracle_version="8"))
      col 0, "spool ora_instance:create_",
      CALL print(trim(dbname)),
      ".log", row + 1
     ELSE
      col 0, "spool ora_db:create_",
      CALL print(trim(dbname)),
      ".log", row + 1
     ENDIF
     col 0, "set echo on", row + 2,
     col 0, "remark - This will take some time, please wait.", row + 2,
     col 0, "connect / as sysdba", row + 1,
     col 0, "startup nomount", row + 1,
     col 0, "create database ",
     CALL print(trim(dbname)),
     row + 1
    DETAIL
     col 5, "datafile '",
     CALL print(trim(a.disk_name)),
     CALL print(trim(dirstr)),
     CALL print(trim(a.file_name)), "' size ",
     CALL print(trim(format(a.file_size,";l"))), " reuse"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->target_undo_ind=1))
    SELECT INTO concat("ddd:","CREATE_",trim(dbname),".SQL")
     a.file_name, a.file_size, a.tablespace_name
     FROM dm_env_files a
     WHERE a.environment_id=env_id
      AND a.file_type IN ("TEMP", "UNDO")
     ORDER BY a.file_type DESC
     HEAD REPORT
      col 7, "  extent management local"
     DETAIL
      row + 1
      CASE (a.file_type)
       OF "UNDO":
        col 5,"undo tablespace ",
        CALL print(cnvtlower(trim(a.tablespace_name)))row + 1,col 7,"datafile '",
        CALL print(trim(a.disk_name))
        CALL print(trim(dirstr))
        CALL print(trim(a.file_name))"' size ",
        CALL print(trim(format(a.file_size,";l")))" reuse"
       OF "TEMP":
        col 5,"default temporary tablespace ",
        CALL print(cnvtlower(trim(a.tablespace_name)))row + 1,col 7,"  tempfile '",
        CALL print(trim(a.disk_name))
        CALL print(trim(dirstr))
        CALL print(trim(a.file_name))"' size ",
        CALL print(trim(format(a.file_size,";l")))" reuse",row + 1,col 7,
        "  extent management local uniform size ",
        IF ((dm_env_import_request->target_database_version_type="PROD"))
         "5M"
        ELSE
         "1M"
        ENDIF
      ENDCASE
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO concat("ddd:","CREATE_",trim(dbname),".SQL")
    a.group_number, a.member_number, a.file_name,
    a.disk_name, a.log_size
    FROM dm_env_redo_logs a
    WHERE a.environment_id=cnvtint(env_id)
    ORDER BY a.group_number, a.member_number
    HEAD REPORT
     col 5, "logfile ", row + 1
    HEAD a.group_number
     col 7, "group ",
     CALL print(trim(format(a.group_number,";l"))),
     "("
    DETAIL
     IF (a.member_number != 1)
      col 15
     ENDIF
     "'",
     CALL print(trim(a.disk_name)),
     CALL print(trim(dirstr)),
     CALL print(trim(a.file_name)), "'"
     IF (a.member_number=max_m)
      ") size ",
      CALL print(trim(format(a.log_size,";l"))), " reuse"
     ENDIF
     IF (((a.group_number < max_g) OR (a.member_number < max_m)) )
      ",", row + 1
     ELSE
      IF (a.group_number < max_g)
       row + 1
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("ddd:","CREATE_",trim(dbname),".SQL")
    a.config_parm, a.value
    FROM dm_env_db_config a
    WHERE a.environment_id=cnvtint(env_id)
     AND a.parm_type="SYSTEM"
     AND a.config_parm != "character set"
    HEAD REPORT
     col 5, "character set ",
     CALL print(trim(dm_env_import_request->character_set)),
     row + 1
    DETAIL
     col 5,
     CALL print(trim(a.config_parm)), "  ",
     CALL print(trim(a.value)), row + 1
    FOOT REPORT
     IF ((dm_env_import_request->base_oracle_version="8"))
      col 5, ";", row + 2,
      col 0, "set termout off", row + 1,
      col 0, "@ora_rdbms_admin:catalog.sql", row + 1,
      col 0, "@ora_rdbms_admin:catproc.sql", row + 1,
      col 0, "@ora_rdbms_admin:catparr.sql", row + 1,
      col 0, "@ora_rdbms_admin:catrep.sql", row + 1
     ELSE
      col 5, ";", row + 2,
      col 0, "spool off", row + 1,
      col 0, "disconnect", row + 1,
      col 0, "exit;", row + 1
     ENDIF
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->base_oracle_version != "8"))
    SELECT INTO concat("ddd:","STARTUP_",trim(dbname),".COM")
     *
     FROM dummyt
     DETAIL
      col 0, "$!-------------------------------------------------------------", row + 1,
      col 0, "$! Startup ORACLE instance ",
      CALL print(cnvtupper(dbname)),
      "1", row + 1, col 0,
      "$!-------------------------------------------------------------", row + 1, col 0,
      "$ ", row + 1, col 0,
      "$@",
      CALL print(ora_db), "ORAUSER_",
      CALL print(cnvtupper(dbname)), ".COM", row + 1,
      col 0, "$ sqlplus /nolog @",
      CALL print(ora_db),
      "STARTUP_",
      CALL print(cnvtupper(dbname)), ".SQL",
      row + 1, col 0, "$exit",
      row + 1
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    SELECT INTO concat("ddd:","STARTUP_",trim(dbname),".SQL")
     *
     FROM dummyt
     DETAIL
      col 0, "connect / as sysdba;", row + 1,
      col 0, "startup;", row + 1,
      col 0, "exit", row + 1
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    SELECT INTO concat("ddd:","SHUTDOWN_",trim(dbname),".COM")
     *
     FROM dummyt
     DETAIL
      col 0, "$!-------------------------------------------------------------", row + 1,
      col 0, "$! Shutdown ORACLE instance ",
      CALL print(cnvtupper(dbname)),
      "1", row + 1, col 0,
      "$!-------------------------------------------------------------", row + 1, col 0,
      "$ ", row + 1, col 0,
      "$@",
      CALL print(ora_db), "ORAUSER_",
      CALL print(cnvtupper(dbname)), ".COM", row + 1,
      col 0, "$ sqlplus /nolog @",
      CALL print(ora_db),
      "SHUTDOWN_",
      CALL print(cnvtupper(dbname)), ".SQL",
      row + 1, col 0, "$exit",
      row + 1
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    SELECT INTO concat("ddd:","SHUTDOWN_",trim(dbname),".SQL")
     *
     FROM dummyt
     DETAIL
      col 0, "connect / as sysdba;", row + 1,
      col 0, "shutdown immediate;", row + 1,
      col 0, "exit", row + 1
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE aix_gen_db_creation_script(x)
   SET cer_mtpt = request->cermtpt
   SET oracle_mtpt = request->orasecmtpt
   SET dba_string = concat(oracle_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SET logical script_dir value(concat(cer_mtpt,"/w_standard/",cnvtlower(dbname),"/dba"))
   SELECT INTO concat("script_dir","/create_db.sql")
    a.file_name, a.file_size
    FROM dm_env_files a
    WHERE environment_id=env_id
     AND file_type="SYSTEM"
    HEAD REPORT
     col 0, "spool ",
     CALL print(dba_string),
     "/create/create_db.log", row + 1, col 0,
     "connect / as sysdba", row + 1, col 0,
     "startup nomount pfile=",
     CALL print(dba_string), "/pfile/init",
     CALL print(cnvtlower(dbname)), "1.ora", row + 1,
     col 0, "create database ",
     CALL print(cnvtlower(dbname))
    DETAIL
     row + 1, col 1, "datafile '/dev/r",
     CALL print(trim(a.file_name)), "' size ",
     CALL print(cnvtstring(a.file_size)),
     " reuse"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->target_undo_ind=1))
    SELECT INTO concat("script_dir","/create_db.sql")
     a.file_name, a.file_size, a.tablespace_name
     FROM dm_env_files a
     WHERE a.environment_id=env_id
      AND a.file_type IN ("TEMP", "UNDO")
     ORDER BY a.file_type DESC
     HEAD REPORT
      col 1, "extent management local"
     DETAIL
      row + 1
      CASE (a.file_type)
       OF "UNDO":
        col 1,"undo tablespace ",
        CALL print(cnvtlower(trim(a.tablespace_name)))row + 1,col 3,"datafile '/dev/r",
        CALL print(trim(a.file_name))"' size ",
        CALL print(cnvtstring(a.file_size))" reuse"
       OF "TEMP":
        col 1,"default temporary tablespace ",
        CALL print(cnvtlower(trim(a.tablespace_name)))row + 1,col 3,"tempfile '/dev/r",
        CALL print(trim(a.file_name))"' size ",
        CALL print(cnvtstring(a.file_size))" reuse",row + 1,col 3,
        "extent management local uniform size ",
        IF ((dm_env_import_request->target_database_version_type="PROD"))
         "5M"
        ELSE
         "1M"
        ENDIF
      ENDCASE
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO concat("script_dir","/create_db.sql")
    a.group_number, a.member_number, a.file_name,
    a.disk_name, a.log_size
    FROM dm_env_redo_logs a
    WHERE a.environment_id=cnvtint(env_id)
    ORDER BY a.group_number, a.member_number
    HEAD REPORT
     col 1, "logfile ", row + 1
    HEAD a.group_number
     col 3, "group ",
     CALL print(trim(format(a.group_number,";l"))),
     "("
    DETAIL
     IF (a.member_number != 1)
      col 11
     ENDIF
     "'/dev/r",
     CALL print(trim(a.file_name)), "'"
     IF (a.member_number=max_m)
      ") size ",
      CALL print(trim(format(a.log_size,";l"))), " reuse"
     ENDIF
     IF (((a.group_number < max_g) OR (a.member_number < max_m)) )
      ",", row + 1
     ELSE
      IF (a.group_number < max_g)
       row + 1
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("script_dir","/create_db.sql")
    a.config_parm, a.value
    FROM dm_env_db_config a
    WHERE a.environment_id=cnvtint(env_id)
     AND a.parm_type="SYSTEM"
     AND a.config_parm != "character set"
    HEAD REPORT
     col 1, "character set ",
     CALL print(trim(dm_env_import_request->character_set)),
     row + 1
    DETAIL
     col 1,
     CALL print(trim(a.config_parm)), "  ",
     CALL print(trim(a.value)), row + 1
    FOOT REPORT
     col 1, ";", row + 1,
     col 0, "set termout off", row + 1,
     col 0, "@$ORACLE_HOME/rdbms/admin/catalog.sql;", row + 1,
     col 0, "@$ORACLE_HOME/rdbms/admin/catproc.sql;", row + 1
     IF ((dm_env_import_request->base_oracle_version="8"))
      col 0, "@$ORACLE_HOME/rdbms/admin/catparr.sql;", row + 1
     ELSE
      col 0, "@$ORACLE_HOME/rdbms/admin/catclust.sql;", row + 1,
      col 0, "@$ORACLE_HOME/rdbms/admin/catblock.sql;", row + 1,
      col 0, "@$ORACLE_HOME/rdbms/admin/catexp7.sql;", row + 1
     ENDIF
     col 0, "@$ORACLE_HOME/rdbms/admin/catrep.sql;", row + 1
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status = "F"
  SET reply->error_message = exit_message
 ELSE
  SET reply->status = "S"
  SET reply->error_message = ""
 ENDIF
END GO
