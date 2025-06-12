CREATE PROGRAM dba_create_v500_db20
 SET message = window
 SET env_id = request->environment_id
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET target_os = request->target_os
 SET dbname = request->database_name
 SET rollback_cnt = 0
 SELECT INTO "nl:"
  *
  FROM dm_env_db_config
  WHERE environment_id=env_id
   AND parm_type != "SYSTEM"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET exit_message = "ERROR: No init.ora values found in Admin for this environment. Exit..."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cnt = count(*)
  FROM dm_env_rollback_segments
  WHERE environment_id=env_id
  DETAIL
   rollback_cnt = cnt
  WITH nocounter, format = stream, noheading,
   formfeed = none, maxrow = 1
 ;end select
 CALL clear(23,05,73)
 CALL text(23,05,"Generate init file(s)...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  IF ((dm_env_import_request->base_oracle_version="8"))
   CALL vms_gen_init(1)
  ELSE
   CALL vms_gen_init920(1)
  ENDIF
 ELSEIF (target_os="AIX")
  CALL aix_gen_init(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 SUBROUTINE vms_gen_init(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET arcdir = request->arc_directory
   SET logical ddd value(dbdir)
   SELECT INTO concat("ddd:","init.ora")
    parm = trim(config_parm), val = trim(value)
    FROM dm_env_db_config
    WHERE environment_id=env_id
     AND parm_type != "SYSTEM"
    DETAIL
     col 0
     IF (cnvtupper(trim(parm))="ROLLBACK_SEGMENTS")
      "#",
      CALL print(trim(parm))
     ELSE
      CALL print(trim(parm))
     ENDIF
     CALL print(" = ")
     IF (cnvtupper(trim(parm))="DB_NAME")
      CALL print(trim(dbname))
     ELSEIF (cnvtupper(trim(parm))="LOG_ARCHIVE_DEST")
      CALL print(trim(arcdir))
     ELSE
      CALL print(trim(val))
     ENDIF
     row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE vms_gen_init920(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET arcdir = request->arc_directory
   SET logical ddd value(dbdir)
   SET dbdirx = replace(dbdir,"]","",2)
   SELECT INTO concat("ora_root:[dbs]","sid_",trim(dbname),"1.properties")
    d.cntl_file_num, d.disk_name, d.file_name
    FROM dm_env_control_files d
    WHERE d.environment_id=env_id
    ORDER BY d.cntl_file_num
    HEAD REPORT
     col 0, "#-------------------------------------------------------------------------------", row
      + 1,
     col 0, "#  Database properties for instance SID=",
     CALL print(trim(dbname)),
     "1", row + 1, col 0,
     "#  Add any additional logical names you want defined", row + 1, col 0,
     "#  when executing: @<ORACLE_HOME>orauser ",
     CALL print(trim(dbname)), "1",
     row + 1, col 0, "#  DO NOT USE QUOTES!",
     row + 1, col 0,
     "#-------------------------------------------------------------------------------",
     row + 1, col 0, "NODE               = ",
     CALL print(trim(request->node)), row + 1, col 0,
     "ORA_LOCAL_DATABASE = ",
     CALL print(trim(dbname)), row + 1,
     col 0, "ORA_DB             = ",
     CALL print(trim(dbdir)),
     row + 1, col 0, "ORA_INSTANCE       = ",
     CALL print(trim(dbdir)), row + 1, col 0,
     "ORA_DUMP           = ",
     CALL print(trim(dbdirx)), ".TRACE]",
     row + 1, col 0, "ORA_SNAP_CONTROL   = ",
     CALL print(trim(dbdir)), "SNAPCF_.F", row + 1,
     col 0, "ORA_ARCHIVE        = ",
     CALL print(trim(arcdir))
    DETAIL
     row + 1, col 0, "ORA_CONTROL",
     CALL print(trim(build(d.cntl_file_num))), "      = ",
     CALL print(trim(dbdir)),
     CALL print(trim(d.file_name))
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("ora_root:[dbs]","init",trim(dbname),".ora")
    parm = trim(config_parm), val = trim(value)
    FROM dm_env_db_config
    WHERE environment_id=env_id
     AND parm_type != "SYSTEM"
     AND  NOT (trim(cnvtupper(config_parm)) IN ("ROLLBACK_SEGMENTS", "THREAD", "INSTANCE_NUMBER"))
    ORDER BY config_parm
    HEAD REPORT
     col 0, "#-------------------------------------------------------------------------------", row
      + 1,
     col 0, "#  Init.ora parameters for database = ",
     CALL print(trim(dbname)),
     row + 1, col 0,
     "#-------------------------------------------------------------------------------",
     row + 1
    DETAIL
     col 0, writeit = 1
     CASE (parm)
      OF "rollback_segments":
       IF ((dm_env_import_request->target_undo_ind=1))
        writeit = 0
       ENDIF
      OF "db_block_buffers":
       IF ((dm_env_import_request->base_oracle_version != "8"))
        writeit = 0
       ENDIF
     ENDCASE
     IF (writeit=1)
      CALL print(trim(parm)),
      CALL print(" = ")
      IF (cnvtupper(trim(parm))="DB_NAME")
       CALL print(trim(dbname))
      ELSE
       CALL print(trim(val))
      ENDIF
      row + 1
     ENDIF
    FOOT REPORT
     col 0, "log_archive_dest = ORA_ARCHIVE"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->target_undo_ind=1))
    SELECT INTO concat("ora_root:[dbs]","init",trim(dbname),".ora")
     FROM dm_env_files a
     WHERE a.file_type="UNDO"
     DETAIL
      col 0, "undo_management = auto", row + 1,
      col 0, "undo_tablespace = ",
      CALL print(cnvtlower(a.tablespace_name)),
      row + 1, col 0, "undo_retention = 900"
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO concat("ora_root:[dbs]","init",trim(dbname),"1.ora")
    parm = trim(config_parm), val = trim(value)
    FROM dm_env_db_config
    WHERE environment_id=env_id
     AND parm_type != "SYSTEM"
     AND trim(cnvtupper(config_parm)) IN ("ROLLBACK_SEGMENTS", "THREAD", "INSTANCE_NUMBER")
    ORDER BY config_parm
    HEAD REPORT
     col 0, "#-------------------------------------------------------------------------------", row
      + 1,
     col 0, "#  Instance parameters for SID = ",
     CALL print(trim(dbname)),
     "1", row + 1, col 0,
     "#-------------------------------------------------------------------------------", row + 1, col
      0,
     "IFILE= ORA_ROOT:[DBS]INIT",
     CALL print(trim(dbname)), ".ORA",
     row + 1
    DETAIL
     col 0, writeit = 1
     CASE (parm)
      OF "rollback_segments":
       IF ((dm_env_import_request->target_undo_ind=1))
        writeit = 0
       ENDIF
      OF "db_block_buffers":
       IF ((dm_env_import_request->base_oracle_version != "8"))
        writeit = 0
       ENDIF
     ENDCASE
     IF (writeit=1)
      col 0,
      CALL print(trim(parm)),
      CALL print(" = "),
      CALL print(trim(val)), row + 1
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE aix_gen_init(x)
   SET cer_mtpt = request->cermtpt
   SET oracle_mtpt = request->orasecmtpt
   SET dba_string = concat(oracle_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SET logical init_dir value(concat(dba_string,"/pfile"))
   SELECT INTO concat("init_dir","/init",cnvtlower(dbname),"1.ora")
    parm = trim(config_parm), val = trim(value)
    FROM dm_env_db_config
    WHERE environment_id=env_id
     AND parm_type != "SYSTEM"
     AND  NOT (config_parm IN ("db_name", "control_files", "log_archive_dest", "global_names",
    "compatible",
    "log_files", "db_block_size", "db_files"))
    ORDER BY config_parm
    HEAD REPORT
     col 0, "ifile = ",
     CALL print(dba_string),
     "/pfile/config",
     CALL print(cnvtlower(dbname)), ".ora",
     row + 1
    DETAIL
     writeit = 1
     CASE (parm)
      OF "rollback_segments":
       IF ((dm_env_import_request->target_undo_ind=1))
        writeit = 0
       ENDIF
      OF "db_block_buffers":
       IF ((dm_env_import_request->base_oracle_version != "8"))
        writeit = 0
       ENDIF
     ENDCASE
     IF (writeit=1)
      col 0,
      CALL print(trim(parm)),
      CALL print(" = "),
      CALL print(trim(val)), row + 1
     ENDIF
    FOOT REPORT
     col 0, "background_dump_dest = ",
     CALL print(dba_string),
     "/bdump/",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, "core_dump_dest = ",
     CALL print(dba_string), "/cdump/",
     CALL print(cnvtlower(dbname)),
     "1", row + 1, col 0,
     "user_dump_dest = ",
     CALL print(dba_string), "/udump/",
     CALL print(cnvtlower(dbname)), "1", row + 1,
     col 0, "audit_file_dest = ",
     CALL print(dba_string),
     "/udump/",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, "log_archive_dest = ",
     CALL print(dba_string), "/arch", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->target_undo_ind=1))
    SELECT INTO concat("init_dir","/init",cnvtlower(dbname),"1.ora")
     FROM dm_env_files a
     WHERE a.file_type="UNDO"
     DETAIL
      col 0, "undo_management = auto", row + 1,
      col 0, "undo_tablespace = ",
      CALL print(cnvtlower(a.tablespace_name)),
      row + 1, col 0, "undo_retention = 900"
     WITH nocounter, format = stream, append,
      noheading, formfeed = none, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO concat("init_dir","/config",cnvtlower(dbname),".ora")
    a.cntl_file_num, a.file_name
    FROM dm_env_control_files a
    WHERE environment_id=env_id
    HEAD REPORT
     col 0, "db_name = ",
     CALL print(cnvtlower(dbname)),
     row + 1, col 0, "control_files =("
    DETAIL
     IF (a.cntl_file_num=1)
      "/dev/r",
      CALL print(trim(a.file_name))
     ELSE
      col 0, "                /dev/r",
      CALL print(trim(a.file_name))
     ENDIF
     row + 1
    FOOT REPORT
     col 0, "               )", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("init_dir","/config",cnvtlower(dbname),".ora")
    parm = trim(config_parm), val = trim(value)
    FROM dm_env_db_config
    WHERE environment_id=env_id
     AND parm_type != "SYSTEM"
     AND config_parm IN ("global_names", "compatible", "log_files", "db_block_size", "db_files")
    ORDER BY config_parm
    DETAIL
     col 0,
     CALL print(trim(parm)),
     CALL print(" = "),
     CALL print(trim(val)), row + 1
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
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
