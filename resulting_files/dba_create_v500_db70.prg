CREATE PROGRAM dba_create_v500_db70
 SET message = window
 SET env_id = request->environment_id
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET dbname = request->database_name
 SET target_os = request->target_os
 CALL text(23,05,"Generate script to create user ...")
 CALL pause(2)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL vms_gen_dba_script(1)
 ELSEIF (target_os="AIX")
  CALL aix_gen_dba_script(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE vms_gen_dba_script(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET ora_db = concat(trim(dbdisk),":[",trim(dbstr),".DB_",trim(dbname),
    "]")
   SET dirstr = concat(":[",trim(dbstr),".DB_",trim(dbname),"]")
   SET logical ddd "sys$login"
   SELECT INTO concat("ddd:","v500_crt_",dbname,"_71.sql")
    b.user_name, b.temporary_tablespace, b.default_tablespace,
    c.priviledge
    FROM dm_env_user b,
     dm_env_user_privledges e,
     dm_env_priviledges c
    WHERE b.user_name=e.user_name
     AND e.priviledge_id=c.priviledge_id
    ORDER BY b.user_name
    HEAD REPORT
     col 0, "set termout off", row + 1,
     col 0, "@ora_root:[sqlplus.demo]pupbld", row + 1,
     col 0, "set termout on", row + 1,
     new_user = fillstring(20," "), old_user = fillstring(20," ")
    DETAIL
     new_user = b.user_name
     IF (new_user != old_user)
      col 0, "create user ",
      CALL print(trim(b.user_name)),
      " identified by ",
      CALL print(cnvtupper(b.user_name)), row + 1,
      col 0, "default tablespace ",
      CALL print(trim(b.default_tablespace)),
      row + 1, col 0, "temporary tablespace ",
      CALL print(trim(b.temporary_tablespace)), ";", row + 1
      IF (b.user_name="V500")
       col 0, " GRANT ALTER ANY INDEX TO V500;", row + 1,
       col 0, " GRANT ALTER ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TABLE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT ALTER TABLESPACE TO V500;", row + 1,
       col 0, " GRANT ANALYZE ANY TO V500;", row + 1,
       col 0, " GRANT CREATE ANY INDEX TO V500;", row + 1,
       col 0, " GRANT CREATE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT CREATE ANY VIEW TO V500;", row + 1,
       col 0, " GRANT CREATE PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE SESSION TO V500;", row + 1,
       col 0, " GRANT DELETE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY INDEX TO V500;", row + 1,
       col 0, " GRANT DROP ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT DROP ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT DROP PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT EXECUTE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT INSERT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT LOCK ANY TABLE TO V500;", row + 1,
       col 0, " GRANT SELECT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT UNLIMITED TABLESPACE TO V500;", row + 1,
       col 0, " GRANT UPDATE ANY TABLE TO V500;", row + 1
      ENDIF
     ENDIF
     col 0, "grant ",
     CALL print(trim(c.priviledge)),
     " to ",
     CALL print(trim(b.user_name)), ";",
     row + 1, old_user = b.user_name
    FOOT REPORT
     col 0, "exit", row + 1,
     col 0, "exit"
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE aix_gen_dba_script(x)
   SELECT INTO concat("/tmp/",cnvtlower(dbname),"_users_script.sql")
    b.user_name, b.temporary_tablespace, b.default_tablespace,
    c.priviledge
    FROM dm_env_user b,
     dm_env_user_privledges e,
     dm_env_priviledges c
    WHERE b.user_name=e.user_name
     AND e.priviledge_id=c.priviledge_id
    ORDER BY b.user_name
    HEAD REPORT
     col 0, "set termout on", row + 1,
     new_user = fillstring(20," "), old_user = fillstring(20," ")
    DETAIL
     new_user = b.user_name
     IF (new_user != old_user)
      col 0, "create user ",
      CALL print(trim(b.user_name)),
      " identified by ",
      CALL print(cnvtupper(b.user_name)), row + 1,
      col 0, "default tablespace ",
      CALL print(trim(b.default_tablespace)),
      row + 1, col 0, "temporary tablespace ",
      CALL print(trim(b.temporary_tablespace)), ";", row + 1
      IF (b.user_name="V500")
       col 0, " GRANT ALTER ANY INDEX TO V500;", row + 1,
       col 0, " GRANT ALTER ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TABLE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT ALTER TABLESPACE TO V500;", row + 1,
       col 0, " GRANT ANALYZE ANY TO V500;", row + 1,
       col 0, " GRANT CREATE ANY INDEX TO V500;", row + 1,
       col 0, " GRANT CREATE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT CREATE ANY VIEW TO V500;", row + 1,
       col 0, " GRANT CREATE PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE SESSION TO V500;", row + 1,
       col 0, " GRANT DELETE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY INDEX TO V500;", row + 1,
       col 0, " GRANT DROP ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT DROP ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT DROP PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT EXECUTE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT INSERT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT LOCK ANY TABLE TO V500;", row + 1,
       col 0, " GRANT SELECT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT UNLIMITED TABLESPACE TO V500;", row + 1,
       col 0, " GRANT UPDATE ANY TABLE TO V500;", row + 1
      ENDIF
     ENDIF
     col 0, "grant ",
     CALL print(trim(c.priviledge)),
     " to ",
     CALL print(trim(b.user_name)), ";",
     row + 1, old_user = b.user_name
    FOOT REPORT
     col 0, "set termout off", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("/tmp/",cnvtlower(dbname),"_users_script2.sql")
    b.user_name, b.temporary_tablespace, b.default_tablespace,
    c.priviledge
    FROM dm_env_user b,
     dm_env_user_privledges e,
     dm_env_priviledges c
    WHERE b.user_name=e.user_name
     AND e.priviledge_id=c.priviledge_id
     AND c.priviledge_id IN (1, 2, 28)
    ORDER BY b.user_name
    HEAD REPORT
     col 0, "set termout on", row + 1,
     new_user = fillstring(20," "), old_user = fillstring(20," ")
    DETAIL
     new_user = b.user_name
     IF (new_user != old_user)
      col 0, "create user ",
      CALL print(trim(b.user_name)),
      " identified by ",
      CALL print(cnvtupper(b.user_name)), row + 1,
      col 0, "default tablespace ",
      CALL print(trim(b.default_tablespace)),
      row + 1, col 0, "temporary tablespace ",
      CALL print(trim(b.temporary_tablespace)), ";", row + 1
      IF (b.user_name="V500")
       col 0, " GRANT ALTER ANY INDEX TO V500;", row + 1,
       col 0, " GRANT ALTER ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TABLE TO V500;", row + 1,
       col 0, " GRANT ALTER ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT ALTER TABLESPACE TO V500;", row + 1,
       col 0, " GRANT ANALYZE ANY TO V500;", row + 1,
       col 0, " GRANT CREATE ANY INDEX TO V500;", row + 1,
       col 0, " GRANT CREATE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT CREATE ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT CREATE ANY VIEW TO V500;", row + 1,
       col 0, " GRANT CREATE PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT CREATE SESSION TO V500;", row + 1,
       col 0, " GRANT DELETE ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY INDEX TO V500;", row + 1,
       col 0, " GRANT DROP ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SEQUENCE TO V500;", row + 1,
       col 0, " GRANT DROP ANY SYNONYM TO V500;", row + 1,
       col 0, " GRANT DROP ANY TABLE TO V500;", row + 1,
       col 0, " GRANT DROP ANY TRIGGER TO V500;", row + 1,
       col 0, " GRANT DROP PUBLIC SYNONYM TO V500;", row + 1,
       col 0, " GRANT EXECUTE ANY PROCEDURE TO V500;", row + 1,
       col 0, " GRANT INSERT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT LOCK ANY TABLE TO V500;", row + 1,
       col 0, " GRANT SELECT ANY TABLE TO V500;", row + 1,
       col 0, " GRANT UNLIMITED TABLESPACE TO V500;", row + 1,
       col 0, " GRANT UPDATE ANY TABLE TO V500;", row + 1
      ENDIF
     ENDIF
     col 0, "grant ",
     CALL print(trim(c.priviledge)),
     " to ",
     CALL print(trim(b.user_name)), ";",
     row + 1, old_user = b.user_name
    FOOT REPORT
     col 0, "set termout off", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("/tmp/",cnvtlower(dbname),"_users_script3.sql")
    b.user_name, b.temporary_tablespace, b.default_tablespace,
    c.priviledge
    FROM dm_env_user b,
     dm_env_user_privledges e,
     dm_env_priviledges c
    WHERE b.user_name=e.user_name
     AND e.priviledge_id=c.priviledge_id
     AND  NOT (c.priviledge_id IN (1, 2, 28))
    ORDER BY b.user_name
    HEAD REPORT
     col 0, "set termout on", row + 1,
     new_user = fillstring(20," "), old_user = fillstring(20," ")
    DETAIL
     col 0, "grant ",
     CALL print(trim(c.priviledge)),
     " to ",
     CALL print(trim(b.user_name)), ";",
     row + 1
     IF (b.user_name="V500")
      col 0, " GRANT ALTER ANY INDEX TO V500;", row + 1,
      col 0, " GRANT ALTER ANY PROCEDURE TO V500;", row + 1,
      col 0, " GRANT ALTER ANY TABLE TO V500;", row + 1,
      col 0, " GRANT ALTER ANY TRIGGER TO V500;", row + 1,
      col 0, " GRANT ALTER TABLESPACE TO V500;", row + 1,
      col 0, " GRANT ANALYZE ANY TO V500;", row + 1,
      col 0, " GRANT CREATE ANY INDEX TO V500;", row + 1,
      col 0, " GRANT CREATE ANY PROCEDURE TO V500;", row + 1,
      col 0, " GRANT CREATE ANY SEQUENCE TO V500;", row + 1,
      col 0, " GRANT CREATE ANY SYNONYM TO V500;", row + 1,
      col 0, " GRANT CREATE ANY TABLE TO V500;", row + 1,
      col 0, " GRANT CREATE ANY TRIGGER TO V500;", row + 1,
      col 0, " GRANT CREATE ANY VIEW TO V500;", row + 1,
      col 0, " GRANT CREATE PUBLIC SYNONYM TO V500;", row + 1,
      col 0, " GRANT CREATE SESSION TO V500;", row + 1,
      col 0, " GRANT DELETE ANY TABLE TO V500;", row + 1,
      col 0, " GRANT DROP ANY INDEX TO V500;", row + 1,
      col 0, " GRANT DROP ANY PROCEDURE TO V500;", row + 1,
      col 0, " GRANT DROP ANY SEQUENCE TO V500;", row + 1,
      col 0, " GRANT DROP ANY SYNONYM TO V500;", row + 1,
      col 0, " GRANT DROP ANY TABLE TO V500;", row + 1,
      col 0, " GRANT DROP ANY TRIGGER TO V500;", row + 1,
      col 0, " GRANT DROP PUBLIC SYNONYM TO V500;", row + 1,
      col 0, " GRANT EXECUTE ANY PROCEDURE TO V500;", row + 1,
      col 0, " GRANT INSERT ANY TABLE TO V500;", row + 1,
      col 0, " GRANT LOCK ANY TABLE TO V500;", row + 1,
      col 0, " GRANT SELECT ANY TABLE TO V500;", row + 1,
      col 0, " GRANT UNLIMITED TABLESPACE TO V500;", row + 1,
      col 0, " GRANT UPDATE ANY TABLE TO V500;", row + 1
     ENDIF
    FOOT REPORT
     col 0, "set termout off", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
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
