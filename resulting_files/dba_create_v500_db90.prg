CREATE PROGRAM dba_create_v500_db90
 SET message = window
 SET env_id = request->environment_id
 SET dbname = request->database_name
 SET target_os = request->target_os
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 IF (target_os="AIX")
  CALL text(23,5,concat("Generate EXPORT and alias definitions script for ",cnvtlower(dbname),"..."))
  CALL pause(3)
  CALL aix_create_script(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE aix_create_script(x)
   SET cer_mtpt = request->cermtpt
   SET oracle_mtpt = request->orasecmtpt
   SET ora_pri_mtpt = request->oraprimtpt
   SET dba_string = concat(oracle_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SET scrpt_dir = concat(cer_mtpt,"/w_standard/",cnvtlower(dbname),"/dba")
   SET oracle_ver = request->oracleversion
   SET logical dba2 value(dba_string)
   SELECT INTO concat("dba2","/orauser_",cnvtlower(dbname),".ksh")
    *
    FROM dummyt
    DETAIL
     col 0, "if [[ `echo $0 | grep orauser | wc -l` -ne 0 ]]", row + 1,
     col 0, "then", row + 1,
     col 0, '     echo " "', row + 1,
     col 0, '     echo "  To set environment, source script with dot space [. ]"', row + 1,
     col 0, '     echo "  Usage should be: \c"', row + 1,
     col 0, "     if [[ -z $PS1 ]]", row + 1,
     col 0, "     then", row + 1,
     col 0, '             echo "$. $0"', row + 1,
     col 0, "     else", row + 1,
     col 0, '             echo "$PS1. $0"', row + 1,
     col 0, "     fi", row + 1,
     col 0, '     echo " "', row + 1,
     col 0, "     exit 1", row + 1,
     col 0, "else", row + 1,
     col 0, "     export ORA_DB=",
     CALL print(cnvtlower(dbname)),
     row + 1, col 0, "     export ORACLE_SID=",
     CALL print(cnvtlower(dbname)), "1", row + 1,
     col 0, "     export ORACLE_OWNER=oracle", row + 1,
     col 0, "     export ORACLE_HOME=",
     CALL print(ora_pri_mtpt),
     "/oracle/product/",
     CALL print(oracle_ver), row + 1,
     col 0, "     export ORA_RDBMS=$ORACLE_HOME/rdbms/admin", row + 1,
     col 0, "     export ORA_INSTALL=$ORACLE_HOME/orainst", row + 1,
     col 0, "     export TNS_ADMIN=$ORACLE_HOME/network/admin", row + 1,
     col 0, "     export ORA_ADMIN=",
     CALL print(oracle_mtpt),
     "/oracle/admin/",
     CALL print(cnvtlower(dbname)), row + 1,
     col 0, "     export ORA_ALERT=$ORA_ADMIN/bdump/",
     CALL print(cnvtlower(dbname)),
     "1", row + 1, col 0,
     "     export ORA_DUMP=$ORA_ADMIN/udump/",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, "     export ORA_ARCH=$ORA_ADMIN/arch",
     row + 1, col 0, "     export ORA_PFILE=$ORA_ADMIN/pfile",
     row + 1, col 0, "     alias sqlplus=$ORACLE_HOME/bin/sqlplus",
     row + 1, col 0, "     alias exp=$ORACLE_HOME/bin/exp",
     row + 1, col 0, "     alias imp=$ORACLE_HOME/bin/imp",
     row + 1, col 0, "     alias oerr=$ORACLE_HOME/bin/oerr",
     row + 1, col 0, "     alias lsnrctl=$ORACLE_HOME/bin/lsnrctl",
     row + 1, col 0, "     alias orapwd=$ORACLE_HOME/bin/orapwd",
     row + 1, col 0, "     alias dbfsize=$ORACLE_HOME/bin/dbfsize",
     row + 1, col 0, "fi"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("dba2","/start_",cnvtlower(dbname),"1.ksh")
    *
    FROM dummyt
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "#-------------------------------------------------------------", row + 1,
     col 0, "# Startup ORACLE instance ",
     CALL print(cnvtlower(dbname)),
     "1", row + 1, col 0,
     "#-------------------------------------------------------------", row + 1, col 0,
     " ", row + 1, col 0,
     "# Set up the necessary variables.", row + 1, col 0,
     "export ORACLE_HOME=",
     CALL print(ora_pri_mtpt), "/oracle/product/",
     CALL print(oracle_ver), row + 1, col 0,
     "export ORACLE_SID=",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, " ",
     row + 1, col 0, "$ORACLE_HOME/bin/sqlplus /nolog <<!",
     row + 1, col 0, "connect / as sysdba",
     row + 1, col 0, "startup",
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("dba2","/shutdown_",cnvtlower(dbname),"1.ksh")
    *
    FROM dummyt
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "#-------------------------------------------------------------", row + 1,
     col 0, "# Shutdown ORACLE instance ",
     CALL print(cnvtlower(dbname)),
     "1", row + 1, col 0,
     "#-------------------------------------------------------------", row + 1, col 0,
     " ", row + 1, col 0,
     "# Set up the necessary variables.", row + 1, col 0,
     "export ORACLE_HOME=",
     CALL print(ora_pri_mtpt), "/oracle/product/",
     CALL print(oracle_ver), row + 1, col 0,
     "export ORACLE_SID=",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 0, " ",
     row + 1, col 0, "$ORACLE_HOME/bin/sqlplus /nolog <<!",
     row + 1, col 0, "connect / as sysdba",
     row + 1, col 0, "shutdown immediate",
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dclstr90_1 = concat("chmod 754 ",dba_string,"/*.*")
   SET len90_1 = size(dclstr90_1)
   SET status90_1 = 0
   CALL dcl(dclstr90_1,len90_1,status90_1)
   SET dclstr90_2 = concat("chown oracle.dba ",dba_string,"/*.*")
   SET len90_2 = size(dclstr90_2)
   SET status90_2 = 0
   CALL dcl(dclstr90_2,len90_2,status90_2)
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
