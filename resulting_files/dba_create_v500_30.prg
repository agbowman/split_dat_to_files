CREATE PROGRAM dba_create_v500_30
 SET message = window
 SET env_id = request->environment_id
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET target_os = request->target_os
 SET dbname = request->database_name
 SET dbsid = concat(dbname,"1")
 DECLARE dcv3_file_type = vc WITH public, noconstant(" ")
 DECLARE devicepath = vc WITH protect, noconstant("")
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL clear(23,05,73)
  CALL text(23,05,"Copy and modify command file template...")
  CALL pause(3)
  IF ((dm_env_import_request->base_oracle_version="8"))
   CALL vms_copy_template_816(1)
  ELSE
   CALL vms_copy_template_920(1)
  ENDIF
 ELSEIF (target_os="AIX")
  CALL text(23,05,"Generate script to create raw devices...")
  CALL pause(3)
  CALL aix_crt_raw_device(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 SUBROUTINE vms_copy_template_816(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET nodename = request->node
   SET orarootdir = request->vms_ora_root
   SET logical ddd "sys$login"
   SET logical dbdir_lgcl value(dbdir)
   SELECT INTO concat("ddd:","DCL_31.COM")
    *
    FROM dummyt
    DETAIL
     col 0, "$ copy dba_root:[admin]dbc_create_xxxx_816.com -", row + 1,
     " ",
     CALL print(trim(dbdir)), "create_",
     CALL print(trim(dbname)), ".com", row + 1,
     col 0, "$ copy dba_root:[admin]dbc_orauser_xxxx_816.com -", row + 1,
     " ",
     CALL print(trim(dbdir)), "orauser_",
     CALL print(trim(dbname)), ".com", row + 1,
     col 0, "$ copy dba_root:[admin]dbc_startup_xxxx_816.com -", row + 1,
     " ",
     CALL print(trim(dbdir)), "startup_",
     CALL print(trim(dbname)), ".com", row + 1,
     col 0, "$ copy dba_root:[admin]dbc_startup_xxxx_816.sql -", row + 1,
     " ",
     CALL print(trim(dbdir)), "startup_",
     CALL print(trim(dbname)), ".sql", row + 1,
     col 0, "$ copy dba_root:[admin]dbc_ora_db_xxxx.com -", row + 1,
     " ",
     CALL print(trim(dbdir)), "ora_db_",
     CALL print(trim(dbname)), ".com", row + 1,
     col 0, "$ copy dba_root:[admin]dbc_wwww_xxxx1_init.ora -", row + 1,
     " ",
     CALL print(trim(dbdir)),
     CALL print(trim(nodename)),
     "_",
     CALL print(trim(dbname)), "1_init.ora",
     row + 1, col 0, "$ copy dba_root:[admin]dbc_shutdown_xxxx.com -",
     row + 1, " ",
     CALL print(trim(dbdir)),
     "shutdown_",
     CALL print(trim(dbname)), ".com",
     row + 1, col 0, "$ copy dba_root:[admin]dbc_shutdown_xxxx.sql -",
     row + 1, " ",
     CALL print(trim(dbdir)),
     "shutdown_",
     CALL print(trim(dbname)), ".sql",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "dddd" "',
     CALL print(trim(dbstr)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.com",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "wwww" "',
     CALL print(trim(nodename)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.ora",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx" "',
     CALL print(trim(dbname)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.com",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx" "',
     CALL print(trim(dbname)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.ora",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx" "',
     CALL print(trim(dbname)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.sql",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "yyyy" "',
     CALL print(trim(dbdisk)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.com",
     row + 1, col 0, '$ @dba_root:[admin]dba_dcl_replaces "zzzz" "',
     CALL print(trim(orarootdir)), '" y -', row + 1,
     " ",
     CALL print(trim(dbdir)), "*.com",
     row + 1, col 0, "$ purge ",
     CALL print(trim(dbdir)), "*.*"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dclstr30_1 = concat("@","ddd:","DCL_31.COM")
   SET len30_1 = size(dclstr30_1)
   SET status30_1 = 0
   CALL dcl(dclstr30_1,len30_1,status30_1)
   CALL clear(23,05,73)
   SELECT INTO concat("dbdir_lgcl:","ora_db_",trim(dbname),".com")
    num = d.cntl_file_num, dname = d.disk_name, fname = d.file_name
    FROM dm_env_control_files d
    WHERE environment_id=env_id
    ORDER BY num
    DETAIL
     col 0, "$  define/nolog/job ORA_CONTROL",
     CALL print(trim(cnvtstring(num))),
     " ",
     CALL print(trim(dname)), ":[",
     CALL print(trim(dbstr)), ".DB_",
     CALL print(trim(dbname)),
     "]",
     CALL print(trim(fname)), row + 1,
     col 0, '$ if (f$trnlnm("ORA_CONTROL',
     CALL print(trim(cnvtstring(num))),
     '","LNM$PROCESS_TABLE") .nes. "") then - ', row + 1, col 0,
     "      deassign/process ora_control",
     CALL print(trim(cnvtstring(num))), row + 1
    FOOT REPORT
     col 0, "$ exit", row + 1
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE vms_copy_template_920(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET nodename = request->node
   SET orarootdir = request->vms_ora_root
   SET logical ddd "sys$login"
   SET logical dbdir_lgcl value(dbdir)
   SELECT INTO concat("dbdir_lgcl:","copy_template.com")
    *
    FROM dummyt
    DETAIL
     col 0, "$ copy dba_root:[admin]dba_create_xxxx_920.com -", row + 1,
     " ",
     CALL print(trim(dbdir)), "v500_create_",
     CALL print(trim(dbname)), ".com", row + 1,
     col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx_dbdisk" "',
     CALL print(trim(dbdisk)),
     '" y -', row + 1, " ",
     CALL print(trim(dbdir)), "v500_create_*.com", row + 1,
     col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx_nodename" "',
     CALL print(trim(nodename)),
     '" y -', row + 1, " ",
     CALL print(trim(dbdir)), "v500_create_*.com", row + 1,
     col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx_dbname" "',
     CALL print(trim(dbname)),
     '" y -', row + 1, " ",
     CALL print(trim(dbdir)), "v500_create_*.com", row + 1,
     col 0, '$ @dba_root:[admin]dba_dcl_replaces "xxxx_envname" "',
     CALL print(trim(env_name)),
     '" y -', row + 1, " ",
     CALL print(trim(dbdir)), "v500_create_*.com", row + 1,
     col 0, "$ purge ",
     CALL print(trim(dbdir)),
     "*.*", row + 1, col 0,
     "$ copy ",
     CALL print(trim(dbdir)), "v500_create_",
     CALL print(trim(dbname)), ".com sys$login", row + 1,
     col 0, "$ exit"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET vctcom = concat("@",dbdir,"copy_template.com")
   SET len = size(trim(vctcom))
   SET status = 0
   CALL dcl(vctcom,len,status)
 END ;Subroutine
 SUBROUTINE aix_crt_raw_device(x)
   SET ora_mtpt = request->orasecmtpt
   SET cer_mtpt = request->cermtpt
   SET redo_cnt = 0
   IF ((dm_env_import_request->target_undo_ind=1))
    SET dcv3_file_type = "UNDO"
   ELSE
    SET dcv3_file_type = "ROLLBACK"
   ENDIF
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_redo_logs
    WHERE environment_id=env_id
    DETAIL
     redo_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (redo_cnt=0)
    SET failed = "T"
    SET exit_message = "ERROR: no REDO LOG file defined in Admin. Exit..."
    GO TO exit_script
   ENDIF
   SET system_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type="SYSTEM"
    DETAIL
     system_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (system_cnt=0)
    SET failed = "T"
    SET exit_message = "ERROR: no SYSTEM file defined in Admin. Exit..."
    GO TO exit_script
   ENDIF
   SET rollback_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type=dcv3_file_type
    DETAIL
     rollback_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (rollback_cnt=0)
    SET failed = "T"
    SET exit_message = concat("ERROR: ",dcv3_file_type," file(s) are NOT defined in Admin. Exit...")
    GO TO exit_script
   ENDIF
   SET temp_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type="TEMP"
    DETAIL
     temp_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (temp_cnt=0)
    SET failed = "T"
    SET exit_message = "ERROR: no TEMP file defined in Admin. Exit..."
    GO TO exit_script
   ENDIF
   SET default_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type="DEFAULT"
    DETAIL
     default_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET misc_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type="MISC"
    DETAIL
     misc_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET other_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_files
    WHERE environment_id=env_id
     AND file_type="OTHER"
    DETAIL
     other_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET sysaux_cnt = 0
   IF ((dm_env_import_request->base_oracle_version_int >= 10))
    SELECT INTO "nl:"
     t_cnt = count(*)
     FROM dm_env_files
     WHERE environment_id=env_id
      AND file_type="SYSAUX"
     DETAIL
      sysaux_cnt = t_cnt
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxrow = 1
    ;end select
    IF (sysaux_cnt=0)
     SET failed = "T"
     SET exit_message = "ERROR: no SYSAUX file define in Admin for 10G database.  Exiting..."
     GO TO exit_script
    ENDIF
   ENDIF
   SET control_cnt = 0
   SELECT INTO "nl:"
    t_cnt = count(*)
    FROM dm_env_control_files
    WHERE environment_id=env_id
    DETAIL
     control_cnt = t_cnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (control_cnt=0)
    SET failed = "T"
    SET exit_message = "ERROR: no CONTROL file defined in Admin. Exit..."
    GO TO exit_script
   ENDIF
   SET t_type = fillstring(30," ")
   SET t_size = 0
   SET cnt = 1
   SELECT INTO concat("/tmp/","v500_create_",cnvtlower(dbname),".ksh")
    a.file_name, a.disk_name, a.file_size,
    a.file_type, b.volume_group, b.partition_size
    FROM dm_env_files a,
     dm_disk_farm b
    WHERE a.environment_id=env_id
     AND a.file_type IN ("SYSTEM", "ROLLBACK", "TEMP", "DEFAULT", "MISC",
    "OTHER", "UNDO", "SYSAUX")
     AND a.disk_name=b.disk_name
    ORDER BY a.file_type
    HEAD REPORT
     col 1, "#!/usr/bin/ksh", row + 1,
     col 1, "if [[ `whoami`  != ",
     CALL print('"'),
     "root",
     CALL print('"'), " ]]",
     row + 1, col 1, "then",
     row + 1, col 1, "    echo ",
     CALL print('"'), "you must be root to execute this script.",
     CALL print('"'),
     row + 1, col 1, "    echo ",
     CALL print('"'), "Exiting script...",
     CALL print('"'),
     row + 1, col 1, "    exit 1",
     row + 1, col 1, "fi",
     row + 1, col 1, "export returned_status=0",
     col 1, row + 1, col 1,
     " echo ",
     CALL print('"'), "*** Creating raw devices for the database shell..... ",
     CALL print('"'), row + 1
    DETAIL
     IF (a.file_type != t_type)
      t_type = a.file_type, cnt = 1
     ENDIF
     t_size = ceil(((a.file_size+ (1024 * 1024))/ ((b.partition_size * 1024) * 1024)))
     IF (trim(a.file_type)="SYSTEM")
      file_cnt = system_cnt
     ELSEIF (trim(a.file_type) IN ("ROLLBACK", "UNDO"))
      file_cnt = rollback_cnt
     ELSEIF (trim(a.file_type)="TEMP")
      file_cnt = temp_cnt
     ELSEIF (trim(a.file_type)="DEFAULT")
      file_cnt = default_cnt
     ELSEIF (trim(a.file_type)="OTHER")
      file_cnt = other_cnt
     ELSEIF (trim(a.file_type)="SYSAUX")
      file_cnt = sysaux_cnt
     ELSE
      file_cnt = misc_cnt
     ENDIF
     IF (cnt <= file_cnt)
      col 0, "#Making raw logical volume for tablespace: ",
      CALL print(trim(a.tablespace_name)),
      row + 1
      IF (validate(cursys2,"AIX")="HPX")
       devicepath = concat(trim(a.disk_name),"/"), col 1, "lvcreate -l '",
       CALL print(trim(cnvtstring(t_size))), "' -n ",
       CALL print(trim(a.file_name)),
       " ",
       CALL print(trim(a.disk_name))
      ELSE
       devicepath = "/dev/"
       IF ((dm_env_import_request->base_oracle_version_int >= 10))
        col 1, "mklv -y '",
        CALL print(trim(a.file_name)),
        "' -t 'raw' -T O "
       ELSE
        col 1, "mklv -y '",
        CALL print(trim(a.file_name)),
        "' -t 'raw' "
       ENDIF
       CALL print(nullterm(trim(cnvtlower(b.volume_group)))), " ",
       CALL print(nullterm(trim(cnvtstring(t_size)))),
       " ",
       CALL print(trim(a.disk_name))
      ENDIF
      row + 1, col 1, "if [ $? != 0 ] ",
      row + 1, col 1, "then",
      row + 1, col 1, "  echo ",
      CALL print('"'), "create logical volume failed...",
      CALL print('"'),
      row + 1, col 1, "  export returned_status=1",
      row + 1, col 1, "else",
      row + 1, col 1, "  chmod 600 ",
      CALL print(devicepath), "r",
      CALL print(trim(a.file_name)),
      row + 1, col 1, "  chown oracle:dba ",
      CALL print(devicepath), "r",
      CALL print(trim(a.file_name)),
      row + 1, col 1, "  chmod 600 ",
      CALL print(devicepath),
      CALL print(trim(a.file_name)), row + 1,
      col 1, "  chown oracle:dba ",
      CALL print(devicepath),
      CALL print(trim(a.file_name)), row + 1, col 1,
      "fi", row + 1, col 1,
      row + 1, cnt = (cnt+ 1)
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET t_size = 0
   SET cnt = 1
   DECLARE temp_vgname = vc WITH public, noconstant(" ")
   SELECT INTO concat("/tmp/","v500_create_",cnvtlower(dbname),".ksh")
    a.file_name, a.disk_name, a.file_size,
    b.volume_group, b.partition_size
    FROM dm_env_control_files a,
     dm_disk_farm b
    WHERE a.environment_id=env_id
     AND a.disk_name=b.disk_name
    DETAIL
     t_size = ceil(((a.file_size+ (1024 * 1024))/ ((b.partition_size * 1024) * 1024)))
     IF (cnt <= control_cnt)
      col 0, "#Making raw logical volume for Control File # ",
      CALL print(trim(cnvtstring(cnt))),
      row + 1, temp_vgname = cnvtlower(trim(b.volume_group))
      IF (validate(cursys2,"AIX")="HPX")
       devicepath = concat(trim(a.disk_name),"/"), col 1, "lvcreate -l '",
       CALL print(trim(cnvtstring(t_size))), "' -n ",
       CALL print(trim(a.file_name)),
       " ",
       CALL print(trim(a.disk_name))
      ELSE
       devicepath = "/dev/"
       IF ((dm_env_import_request->base_oracle_version_int >= 10))
        col 1, "mklv -y '",
        CALL print(trim(a.file_name)),
        "' -t 'raw' -T O "
       ELSE
        col 1, "mklv -y '",
        CALL print(trim(a.file_name)),
        "' -t 'raw' "
       ENDIF
       CALL print(temp_vgname), " ",
       CALL print(trim(cnvtstring(t_size))),
       " ",
       CALL print(trim(a.disk_name))
      ENDIF
      row + 1, col 1, "if [ $? != 0 ] ",
      row + 1, col 1, "then",
      row + 1, col 1, " echo ",
      CALL print('"'), "create logical volume failed...",
      CALL print('"'),
      row + 1, col 1, " export returned_status=1",
      row + 1, col 1, "else",
      row + 1, col 1, "  chmod 600 ",
      CALL print(devicepath), "r",
      CALL print(trim(a.file_name)),
      row + 1, col 1, "  chown oracle:dba ",
      CALL print(devicepath), "r",
      CALL print(trim(a.file_name)),
      row + 1, col 1, "  chmod 600 ",
      CALL print(devicepath),
      CALL print(trim(a.file_name)), row + 1,
      col 1, "  chown oracle:dba ",
      CALL print(devicepath),
      CALL print(trim(a.file_name)), row + 1, col 1,
      "fi", row + 1, col 1,
      row + 1, cnt = (cnt+ 1)
     ENDIF
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   SET t_size = 0
   SELECT INTO concat("/tmp/","v500_create_",cnvtlower(dbname),".ksh")
    a.file_name, a.disk_name, a.log_size,
    a.group_number, a.member_number, b.volume_group,
    b.partition_size
    FROM dm_env_redo_logs a,
     dm_disk_farm b
    WHERE a.environment_id=env_id
     AND a.disk_name=b.disk_name
    DETAIL
     t_size = ceil(((a.log_size+ (1024 * 1024))/ ((b.partition_size * 1024) * 1024))), col 0,
     "#Making raw logical volumes for Redo Logs... ",
     row + 1, temp_vgname = cnvtlower(trim(b.volume_group))
     IF (validate(cursys2,"AIX")="HPX")
      devicepath = concat(trim(a.disk_name),"/"), col 1, "lvcreate -l '",
      CALL print(trim(cnvtstring(t_size))), "' -n ",
      CALL print(trim(a.file_name)),
      " ",
      CALL print(trim(a.disk_name))
     ELSE
      devicepath = "/dev/"
      IF ((dm_env_import_request->base_oracle_version_int >= 10))
       col 1, "mklv -y '",
       CALL print(trim(a.file_name)),
       "' -t 'raw' -T O "
      ELSE
       col 1, "mklv -y '",
       CALL print(trim(a.file_name)),
       "' -t 'raw' "
      ENDIF
      CALL print(temp_vgname), " ",
      CALL print(trim(cnvtstring(t_size))),
      " ",
      CALL print(trim(a.disk_name))
     ENDIF
     row + 1, col 1, "if [ $? != 0 ] ",
     row + 1, col 1, "then",
     row + 1, col 1, " echo ",
     CALL print('"'), "create logical volume failed...",
     CALL print('"'),
     row + 1, col 1, " export returned_status=1",
     row + 1, col 1, "else",
     row + 1, col 1, "  chmod 600 ",
     CALL print(devicepath), "r",
     CALL print(trim(a.file_name)),
     row + 1, col 1, "  chown oracle:dba ",
     CALL print(devicepath), "r",
     CALL print(trim(a.file_name)),
     row + 1, col 1, "  chmod 600 ",
     CALL print(devicepath),
     CALL print(trim(a.file_name)), row + 1,
     col 1, "  chown oracle:dba ",
     CALL print(devicepath),
     CALL print(trim(a.file_name)), row + 1, col 1,
     "fi", row + 1, col 1,
     row + 1
    FOOT REPORT
     col 1, "if [ $returned_status != 0 ]", row + 1,
     col 1, "then", row + 1,
     col 1, "  echo ",
     CALL print('"'),
     "Create logical volume failed...",
     CALL print('"'), row + 1,
     col 1, "else", row + 1
     IF (validate(cursys2,"AIX")="HPX")
      col 1, "  su - oracle -c ",
      CALL print('"'),
      ". /tmp/v500_crt_db_",
      CALL print(cnvtlower(dbname)), ".ksh",
      CALL print('"')
     ELSE
      col 1, "  su - oracle ",
      CALL print('"'),
      "-c . /tmp/v500_crt_db_",
      CALL print(cnvtlower(dbname)), ".ksh",
      CALL print('"')
     ENDIF
     row + 1, col 1, 'echo "Update Cerner Registry ..."',
     row + 1, col 1, ". /tmp/v500_crt_",
     CALL print(cnvtlower(dbname)), "_81.ksh", row + 1,
     col 1, "fi"
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   SET dclstr30_5 = concat("chmod 766 /tmp/","v500_create_",cnvtlower(dbname),".ksh")
   SET len30_5 = size(dclstr30_5)
   SET status30_5 = 0
   CALL dcl(dclstr30_5,len30_5,status30_5)
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
