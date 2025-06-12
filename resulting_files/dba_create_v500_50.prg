CREATE PROGRAM dba_create_v500_50
 SET message = window
 SET string = logical("dba")
 SET dba_admin = concat(trim(string),"/admin")
 SET env_id = request->environment_id
 SET dbname = request->database_name
 SET target_os = request->target_os
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET node = request->node
 SET dbsid = concat(cnvtlower(dbname),"1")
 SET alias = dbsid
 SET port = "1521"
 DECLARE unix_whval = vc WITH noconstant("aixrs6000")
 IF (validate(cursys2,"AIX")="HPX")
  SET unix_whval = "hpuxia64"
 ENDIF
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL text(23,05,concat("Generate shell script to create database: ","v500_create_",dbname,".com"))
  CALL pause(3)
  IF ((dm_env_import_request->base_oracle_version="8"))
   CALL vms_create_script(1)
  ELSE
   CALL vms_create_script920(1)
  ENDIF
 ELSEIF (target_os="AIX")
  CALL text(23,5,concat("Generate shell script to create database: ","v500_crt_db_",cnvtlower(dbname),
    ".ksh"))
  CALL pause(3)
  CALL aix_create_script(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE vms_create_script(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET archivedisk = request->archive_disk
   SET nodename = request->node
   SET logical ddd "sys$login"
   SELECT INTO concat("ddd:","v500_create_",dbname,".com")
    *
    FROM dummyt
    DETAIL
     col 0, '$ write sys$output "Initializing ',
     CALL print(cnvtupper(trim(dbname))),
     ' database..."', row + 1, col 0,
     "$ @",
     CALL print(cnvtupper(trim(dbdir))), "orauser_",
     CALL print(cnvtupper(trim(dbname))), row + 1, col 0,
     "$ @ora_rdbms:ora_find_sid r ",
     CALL print(cnvtupper(trim(nodename))), " ",
     CALL print(cnvtupper(trim(dbname))), " ",
     CALL print(cnvtupper(trim(dbname))),
     "1", row + 1, col 0,
     '$ if ora_rdbms_success .nes. "Y"', row + 1, col 0,
     '$ then write sys$output "Unable to register database instance."', row + 1, col 0,
     "$      exit", row + 1, col 0,
     "$ endif", row + 1, col 0,
     "$ @ora_network:create_orasrv_beq - ", row + 1, col 0,
     "   ",
     CALL print(cnvtupper(trim(dbdir))), " ",
     CALL print(cnvtupper(trim(dbname))), "1 ",
     CALL print(cnvtupper(trim(dbname))),
     row + 1, col 0, "$ set def ",
     CALL print(trim(dbdir)), row + 1, col 0,
     "$ @",
     CALL print(cnvtupper(trim(dbdir))), "create_",
     CALL print(cnvtupper(trim(dbname))), row + 1, col 0,
     '$ inst_name = f$trnlnm("ora_sid")', row + 1, col 0,
     "$ @ora_rdbms:ora_find_sid f ", '"',
     CALL print(cnvtupper(trim(nodename))),
     '" "',
     CALL print(cnvtupper(trim(dbname))), '"',
     row + 1, col 0, '$ if inst_name .eqs. ""  .or. inst_name .nes. ora_rdbms_success',
     row + 1, col 0, '$ then write sys$output "ORA_SID is currently incorrect."',
     row + 1, col 0, '$      write sys$output "Please verify the database was created ',
     'successfully."', row + 1, col 0,
     '$      write sys$output "ORA_SID should match instance name."', row + 1, col 0,
     "$ endif", row + 1, col 0,
     "$ set message/nofac/noid/nosev/notext", row + 1, col 0,
     "$ @dba_root:[admin]dba_chk_instance ",
     CALL print("'"), "inst_name",
     row + 1, col 0, "$ sts = $status",
     row + 1, col 0, "$ set message/fac/id/sev/text",
     row + 1, col 0, "$ if sts .ne. 1",
     row + 1, col 0, '$ then write sys$output "Database not started."',
     row + 1, col 0, '$      write sys$output "Please verify the database',
     ' was created successfully."', row + 1, col 0,
     "$      goto exit_script", row + 1, col 0,
     "$ endif", row + 1, col 0,
     '$ write sys$output "',
     CALL print(dbname), ' database shell has been created successfully."',
     row + 1, col 0,
     '$ write sys$output "Creating MISC, TEMP, and ROLLBACK tablespaces, and ROLLBACK segments."',
     row + 1, col 0, '$ write sys$output "Creating database user accounts."',
     row + 1, col 0, "$ sqlplus -s system/manager @sys$login:V500_CRT_",
     CALL print(trim(dbname)), "_61.SQL", row + 1,
     col 0, "$ sqlplus -s system/manager @sys$login:V500_CRT_",
     CALL print(trim(dbname)),
     "_71.SQL", row + 1, col 0,
     "$ svrmgrl", row + 1, col 0,
     "connect internal", row + 1, col 0,
     "alter tablespace temp temporary;", row + 1, col 0,
     "alter user sys temporary tablespace temp;", row + 1, col 0,
     "alter user system temporary tablespace temp;", row + 1, col 0,
     "disconnect;", row + 1, col 0,
     "exit;", row + 1, col 0,
     '$ write sys$output "shutting down database..."', row + 1, col 0,
     "$ svrmgrl", row + 1, col 0,
     "spool sys$login:create_",
     CALL print(cnvtupper(trim(dbname))), "_sql_01.log",
     row + 1, col 0, "connect internal",
     row + 1, col 0, "shutdown immediate",
     row + 1, col 0, "disconnect",
     row + 1, col 0, "exit",
     row + 1, col 0, "! Uncomment ROLLBACK_SEGMENTS parameter in ORA_DB:INIT.ORA;",
     row + 1, col 0, '$ edit = "edit"',
     row + 1, col 0, "$ edit/edt/command=sys$input/output=ora_db:init.ora ora_db:init.ora;",
     row + 1, col 0, "substitute/#rollback_segments/rollback_segments/whole/notype",
     row + 1, col 0, "exit",
     row + 1, col 0, "$exit_script:",
     row + 1, col 0, "$ svrmgrl",
     row + 1, col 0, "spool sys$login:create_database_sql_03.log",
     row + 1, col 0, "connect internal",
     row + 1, col 0, "startup",
     row + 1, col 0, "disconnect",
     row + 1, col 0, "exit",
     row + 1, col 0, '$ write sys$output "Update Cerner Registry and SQLNET..."',
     row + 1, col 0, "$ @sys$login:v500_crt_",
     CALL print(nullterm(dbname)), "_81.com", row + 1,
     col 0, "$ set noon", row + 1,
     col 0, "$ exit"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   CALL clear(23,05,78)
 END ;Subroutine
 SUBROUTINE vms_create_script920(x)
   CALL clear(23,05,78)
 END ;Subroutine
 SUBROUTINE aix_create_script(x)
   SET cer_mtpt = request->cermtpt
   SET oracle_mtpt = request->orasecmtpt
   SET ora_pri_mtpt = request->oraprimtpt
   SET dba_string = concat(oracle_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SET scrpt_dir = concat(cer_mtpt,"/w_standard/",cnvtlower(dbname),"/dba")
   SET oracle_ver = request->oracleversion
   SET wh_dba = "/cerner/w_standard/rev007_008/dba"
   SET logical dba value(scrpt_dir)
   DECLARE dba50_str = vc WITH protect, noconstant("")
   SELECT INTO concat("dba","/orauser_",cnvtlower(dbname),".def")
    *
    FROM dummyt
    DETAIL
     col 0, "export CerFsMtPt=",
     CALL print(cer_mtpt),
     row + 1, col 0, "export OraSecFsMtPt=",
     CALL print(oracle_mtpt), row + 1, col 0,
     "export OraPriFsMtPt=",
     CALL print(ora_pri_mtpt), row + 1,
     col 0, "export WareHouse=",
     CALL print(cnvtlower(dbname)),
     row + 1, col 0, "export DbName=",
     CALL print(cnvtlower(dbname)), row + 1, col 0,
     "export ORACLE_SID=",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, "export ORACLE_OWNER=oracle",
     row + 1, col 0, "export ORACLE_HOME=",
     CALL print(request->oracle_home), row + 1, col 0,
     "export PATH=$PATH:$ORACLE_HOME/bin", row + 1, col 0,
     "export ORA_LINKS=",
     CALL print(oracle_mtpt), "/oralink/",
     CALL print(cnvtlower(dbname)), row + 1, col 0,
     "export ORA_ADMIN=",
     CALL print(oracle_mtpt), "/oracle/admin/",
     CALL print(cnvtlower(dbname)), row + 1
     IF (validate(cursys2,"AIX")="AIX")
      col 0, "export DBA=$ORACLE_ADMIN/pfile", row + 1
     ENDIF
     dba50_str = concat("export dba=$CerFsMtPt/w_standard/$WareHouse/",unix_whval), col 0, dba50_str,
     row + 1, dba50_str = concat("export LIBPATH=/usr/lib:$CerFsMtPt/w_standard/$WareHouse/",
      unix_whval), col 0,
     dba50_str, row + 1, col 0,
     "export cer_install=",
     CALL print(request->cer_install), row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("/tmp/","v500_crt_db_",cnvtlower(dbname),".ksh")
    *
    FROM dummyt
    HEAD REPORT
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "if [[ `whoami`  != ",
     CALL print('"'),
     "oracle",
     CALL print('"'), " ]]",
     row + 1, col 0, "then",
     row + 1, col 0, "    echo ",
     CALL print('"'), "you must be oracle to execute this ", "script.",
     CALL print('"'), row + 1, col 0,
     "    echo ",
     CALL print('"'), "Exiting script...",
     CALL print('"'), row + 1, col 0,
     "    exit 1", row + 1, col 0,
     "fi", row + 1
    DETAIL
     col 0, ". ",
     CALL print(scrpt_dir),
     "/orauser_",
     CALL print(cnvtlower(dbname)), ".def",
     row + 1, col 0, "echo ",
     CALL print('"'), "Beginning create database process.  This will take several minutes....",
     CALL print('"'),
     row + 1
     IF ((dm_env_import_request->base_oracle_version="8"))
      col 0, "$ORACLE_HOME/bin/svrmgrl <<!", row + 1,
      col 0, row + 1, col 0,
      "connect internal", row + 1
     ELSE
      col 0, "$ORACLE_HOME/bin/sqlplus /nolog <<!", row + 1,
      col 0, row + 1, col 0,
      "connect / as sysdba", row + 1
     ENDIF
     col 0, row + 1, col 0,
     "@",
     CALL print(scrpt_dir), "/create_db.sql",
     row + 1, col 0, row + 1,
     col 0, "spool ",
     CALL print(concat(dba_string,"/create/create_db_objects.log")),
     row + 1, col 0, row + 1,
     col 0, "set termout on", row + 1
     IF ((dm_env_import_request->target_undo_ind=0))
      col 0, "create rollback segment r0 tablespace system", row + 1,
      col 0, "storage(initial 16k next 16k minextents 2 maxextents 20);", row + 1,
      col 0, row + 1, col 0,
      "alter rollback segment r0 online;", row + 1, col 0,
      row + 1, col 0, "@",
      CALL print(scrpt_dir), "/create_rbs.sql", row + 1
     ENDIF
     col 0, row + 1, col 0,
     "@",
     CALL print(scrpt_dir), "/create_temp.sql",
     row + 1, col 0, row + 1
     IF ((dm_env_import_request->target_undo_ind=0))
      col 0, "alter rollback segment r0 offline;", row + 1,
      col 0, row + 1, col 0,
      "alter tablespace temp temporary;", row + 1, col 0,
      row + 1
     ENDIF
     col 0, "alter user sys temporary tablespace temp;", row + 1,
     col 0, row + 1, col 0,
     "alter user system temporary tablespace temp;", row + 1, col 0,
     row + 1
     IF ((dm_env_import_request->base_oracle_version_int >= 10))
      col 0, "EXECUTE DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB')", row + 1,
      row + 1
     ENDIF
     col 0, "connect system/manager", row + 1,
     col 0, row + 1, col 0,
     "@",
     CALL print(scrpt_dir), "/create_users2.sql",
     row + 1, col 0, row + 1,
     col 0, "spool off", row + 1,
     col 0, "set termout off", row + 1,
     col 0, "@$ORACLE_HOME/sqlplus/admin/pupbld.sql", row + 1,
     col 0, row + 1, col 0,
     "set termout on", row + 1, col 0,
     "disconnect", row + 1, col 0,
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1, col 0, "ln -s ",
     CALL print(dba_string), "/pfile/init",
     CALL print(cnvtlower(dbname)),
     "1.ora ", "$ORACLE_HOME/dbs/init",
     CALL print(cnvtlower(dbname)),
     "1.ora", row + 1, col 0,
     "$cer_install/dm2_updatetns.ksh -a ",
     CALL print(alias), " -n ",
     CALL print(node), " -p 1521 -s ",
     CALL print(dbsid),
     " -h ",
     CALL print(request->oracle_home), " -m A"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1, maxcol = 200
   ;end select
   SET dclstr50_1 = concat("chmod 766 /tmp/v500_crt_db_",cnvtlower(dbname),".ksh")
   SET len50_1 = size(dclstr50_1)
   SET status50_1 = 0
   CALL dcl(dclstr50_1,len50_1,status50_1)
   SET dclstr50_2 = concat("chown oracle /tmp/v500_crt_db_",cnvtlower(dbname),".ksh")
   SET len50_2 = size(dclstr50_2)
   SET status50_2 = 0
   CALL dcl(dclstr50_2,len50_2,status50_2)
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
