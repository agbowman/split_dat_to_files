CREATE PROGRAM dba_create_v500_db60
 SET message = window
 FREE SET ts_data
 RECORD ts_data(
   1 tname = vc
   1 dname = vc
   1 fname = vc
   1 fsize = i4
 )
 FREE SET rb_data
 RECORD rb_data(
   1 tname = vc
   1 rname = vc
   1 init_ext = i4
   1 next_ext = i4
   1 min_ext = i4
   1 max_ext = i4
   1 opt = i4
 )
 SET env_id = request->environment_id
 SET dbname = request->database_name
 SET target_os = request->target_os
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 CALL clear(23,05,73)
 CALL text(23,05,"Generate script to create tablespaces...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  IF ((dm_env_import_request->base_oracle_version="8"))
   CALL vms_gen_temp_rb(1)
  ELSE
   CALL vms_gen_temp_rb920(1)
  ENDIF
 ELSEIF (target_os="AIX")
  CALL aix_gen_temp_rb(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE vms_gen_temp_rb(x)
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET dbdisk = request->database_disk
   SET ora_db = concat(trim(dbdisk),":[",trim(dbstr),".DB_",trim(dbname),
    "]")
   SET dirstr = concat(":[",trim(dbstr),".DB_",trim(dbname),"]")
   SET logical ddd "sys$login"
   SELECT INTO concat("ddd:","v500_crt_",dbname,"_61.sql")
    tname = trim(d.tablespace_name), dname = trim(d.disk_name), fname = trim(d.file_name),
    fsize = d.file_size
    FROM dm_env_files d
    WHERE d.environment_id=cnvtint(env_id)
     AND d.file_type IN ("DEFAULT", "TEMP", "MISC", "ROLLBACK", "OTHER")
    DETAIL
     ts_data->tname = trim(tname), ts_data->dname = trim(dname), ts_data->fname = trim(fname),
     ts_data->fsize = cnvtint(fsize), col 0, "create tablespace ",
     CALL print(cnvtupper(ts_data->tname)), row + 1, col 0,
     "datafile ",
     CALL print("'"),
     CALL print(cnvtupper(ts_data->dname)),
     CALL print(cnvtupper(dirstr)),
     CALL print(cnvtupper(ts_data->fname)),
     CALL print("'"),
     " size ",
     CALL print(cnvtstring(ts_data->fsize)), row + 1
     IF (d.file_type IN ("DEFAULT", "MISC", "TEMP"))
      col 0, "default storage(", row + 1,
      col 0, "        initial     1M", row + 1,
      col 0, "        next        1M", row + 1,
      col 0, "        pctincrease 0);", row + 2
     ELSE
      col 0, "default storage(", row + 1,
      col 0, "        initial     16k", row + 1,
      col 0, "        next        16k", row + 1,
      col 0, "        pctincrease 0);", row + 2
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("ddd:","v500_crt_",dbname,"_61.sql")
    rname = trim(d.rollback_seg_name), tname = trim(d.tablespace_name), i_ext = d.initial_extent,
    n_ext = d.next_extent, min_ext = d.min_extents, max_ext = d.max_extents,
    opt = d.optimal
    FROM dm_env_rollback_segments d
    WHERE d.environment_id=cnvtint(env_id)
    DETAIL
     rb_data->rname = trim(rname), rb_data->tname = trim(tname), rb_data->init_ext = cnvtint(i_ext),
     rb_data->next_ext = cnvtint(n_ext), rb_data->min_ext = cnvtint(min_ext), rb_data->max_ext =
     cnvtint(max_ext),
     rb_data->opt = cnvtint(opt), col 0, "create rollback segment ",
     CALL print(cnvtupper(rb_data->rname)), row + 1, col 0,
     "tablespace ",
     CALL print(cnvtupper(rb_data->tname)), row + 1,
     col 0, "storage(", row + 1,
     col 0, "       initial "
     IF ((rb_data->init_ext=0))
      CALL print("40k ")
     ELSE
      CALL print(cnvtstring(rb_data->init_ext))
     ENDIF
     row + 1, col 0, "       next "
     IF ((rb_data->next_ext=0))
      CALL print("40k ")
     ELSE
      CALL print(cnvtstring(rb_data->next_ext))
     ENDIF
     row + 1, col 0, "       minextents "
     IF ((rb_data->min_ext=0))
      CALL print("1 ")
     ELSE
      CALL print(cnvtstring(rb_data->min_ext))
     ENDIF
     row + 1, col 0, "       maxextents "
     IF ((rb_data->max_ext=0))
      CALL print("1 ")
     ELSE
      CALL print(cnvtstring(rb_data->max_ext))
     ENDIF
     row + 1
     IF ((rb_data->opt != 0))
      col 0, "       optimal ",
      CALL print(cnvtstring(rb_data->opt)),
      row + 1
     ENDIF
     col 0, ");", row + 2,
     col 0, "alter rollback segment ",
     CALL print(rb_data->rname),
     " online;", row + 1
    FOOT REPORT
     col 0, "exit;"
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE vms_gen_temp_rb920(x)
   SET dbstr = trim(request->root_dir_name)
   SET dbdir = trim(request->rdb_directory)
   SET dbdisk = trim(request->database_disk)
   SET logical ddd value(dbdir)
   SELECT INTO concat("ddd:","postcreate_",dbname,".sql")
    tname = trim(d.tablespace_name), dname = trim(d.disk_name), fname = trim(d.file_name),
    fsize = d.file_size, d.file_type
    FROM dm_env_files d
    WHERE d.environment_id=cnvtint(env_id)
     AND d.file_type IN ("DEFAULT", "TEMP", "MISC", "ROLLBACK", "OTHER",
    "UNDO")
    HEAD REPORT
     col 0, "connect / as sysdba ", row + 2,
     col 0, "set termout off", row + 1,
     col 0, "@ora_root:[rdbms.admin]catalog.sql", row + 1,
     col 0, "@ora_root:[rdbms.admin]catproc.sql", row + 1,
     col 0, "@ora_root:[rdbms.admin]catexp7.sql", row + 1,
     col 0, "@ora_root:[rdbms.admin]catblock.sql", row + 1,
     col 0, "@ora_root:[rdbms.admin]catrep.sql", row + 1,
     col 0, "set termout on", row + 2,
     col 0, "spool ora_db:postcreate_",
     CALL print(trim(dbname)),
     ".log", row + 2
    DETAIL
     IF ((((dm_env_import_request->target_undo_ind=1)
      AND  NOT (d.file_type IN ("ROLLBACK", "TEMP", "UNDO"))) OR ((dm_env_import_request->
     target_undo_ind=0)
      AND d.file_type != "UNDO")) )
      row + 1, ts_data->tname = trim(tname), ts_data->dname = trim(dname),
      ts_data->fname = trim(fname), ts_data->fsize = cnvtint(fsize), col 0,
      "create tablespace ",
      CALL print(cnvtupper(ts_data->tname)), row + 1,
      col 2, "datafile '",
      CALL print(cnvtupper(dbdir)),
      CALL print(cnvtupper(ts_data->fname)), "'", " size ",
      CALL print(trim(cnvtstring(d.file_size))), row + 1
      IF ((dm_env_import_request->target_extent_management="LOCALLY MANAGED"))
       col 2, "autoextend off ", row + 1,
       col 2, "extent management local autoallocate ", row + 1,
       col 2, "segment space management auto; ", row + 1
      ELSE
       col 2, "default storage(", row + 1
       IF ((dm_env_import_request->target_database_version_type="PROD")
        AND d.file_type="TEMP")
        col 2, "        initial     5M", row + 1,
        col 2, "        next        5M", row + 1
       ELSE
        col 2, "        initial     1M", row + 1,
        col 2, "        next        1M", row + 1
       ENDIF
       col 2, "        pctincrease 0)", row + 1,
       col 2, "extent management dictionary;", row + 1
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF ((dm_env_import_request->target_undo_ind=0))
    SELECT INTO concat("ddd:","postcreate_",dbname,".sql")
     rname = trim(d.rollback_seg_name), tname = trim(d.tablespace_name), i_ext = d.initial_extent,
     n_ext = d.next_extent, min_ext = d.min_extents, max_ext = d.max_extents,
     opt = d.optimal
     FROM dm_env_rollback_segments d
     WHERE d.environment_id=cnvtint(env_id)
     DETAIL
      row + 1, rb_data->rname = trim(rname), rb_data->tname = trim(tname),
      rb_data->init_ext = cnvtint(i_ext), rb_data->next_ext = cnvtint(n_ext), rb_data->min_ext =
      cnvtint(min_ext),
      rb_data->max_ext = cnvtint(max_ext), rb_data->opt = cnvtint(opt), col 0,
      "create rollback segment ",
      CALL print(cnvtupper(rb_data->rname)), row + 1,
      col 0, "tablespace ",
      CALL print(cnvtupper(rb_data->tname)),
      row + 1, col 0, "storage(",
      row + 1, col 0, "       initial "
      IF ((rb_data->init_ext=0))
       CALL print("40k ")
      ELSE
       CALL print(cnvtstring(rb_data->init_ext))
      ENDIF
      row + 1, col 0, "       next "
      IF ((rb_data->next_ext=0))
       CALL print("40k ")
      ELSE
       CALL print(cnvtstring(rb_data->next_ext))
      ENDIF
      row + 1, col 0, "       minextents "
      IF ((rb_data->min_ext=0))
       CALL print("1 ")
      ELSE
       CALL print(cnvtstring(rb_data->min_ext))
      ENDIF
      row + 1, col 0, "       maxextents "
      IF ((rb_data->max_ext=0))
       CALL print("1 ")
      ELSE
       CALL print(cnvtstring(rb_data->max_ext))
      ENDIF
      row + 1
      IF ((rb_data->opt != 0))
       col 0, "       optimal ",
       CALL print(cnvtstring(rb_data->opt)),
       row + 1
      ENDIF
      col 0, ");", row + 2,
      col 0, "alter rollback segment ",
      CALL print(rb_data->rname),
      " online;", row + 1
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO concat("ddd:","postcreate_",dbname,".sql")
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
     col 0, " ", row + 1,
     col 0, "connect system/manager; ", row + 1,
     col 0, " ", row + 1,
     new_user = fillstring(20," "), old_user = fillstring(20," ")
    DETAIL
     new_user = b.user_name
     IF (new_user != old_user)
      col 0, "create user ",
      CALL print(trim(b.user_name)),
      " identified by ",
      CALL print(cnvtupper(b.user_name)), row + 1,
      col 2, "default tablespace ",
      CALL print(trim(b.default_tablespace)),
      row + 1, col 2, "temporary tablespace ",
      CALL print(trim(b.temporary_tablespace)), ";", row + 1
      IF (b.user_name="V500")
       col 0, "GRANT ALTER ANY INDEX TO V500;", row + 1,
       col 0, "GRANT ALTER ANY PROCEDURE TO V500;", row + 1,
       col 0, "GRANT ALTER ANY TABLE TO V500;", row + 1,
       col 0, "GRANT ALTER ANY TRIGGER TO V500;", row + 1,
       col 0, "GRANT ALTER TABLESPACE TO V500;", row + 1,
       col 0, "GRANT ANALYZE ANY TO V500;", row + 1,
       col 0, "GRANT CREATE ANY INDEX TO V500;", row + 1,
       col 0, "GRANT CREATE ANY PROCEDURE TO V500;", row + 1,
       col 0, "GRANT CREATE ANY SEQUENCE TO V500;", row + 1,
       col 0, "GRANT CREATE ANY SYNONYM TO V500;", row + 1,
       col 0, "GRANT CREATE ANY TABLE TO V500;", row + 1,
       col 0, "GRANT CREATE ANY TRIGGER TO V500;", row + 1,
       col 0, "GRANT CREATE ANY VIEW TO V500;", row + 1,
       col 0, "GRANT CREATE PUBLIC SYNONYM TO V500;", row + 1,
       col 0, "GRANT CREATE SESSION TO V500;", row + 1,
       col 0, "GRANT DELETE ANY TABLE TO V500;", row + 1,
       col 0, "GRANT DROP ANY INDEX TO V500;", row + 1,
       col 0, "GRANT DROP ANY PROCEDURE TO V500;", row + 1,
       col 0, "GRANT DROP ANY SEQUENCE TO V500;", row + 1,
       col 0, "GRANT DROP ANY SYNONYM TO V500;", row + 1,
       col 0, "GRANT DROP ANY TABLE TO V500;", row + 1,
       col 0, "GRANT DROP ANY TRIGGER TO V500;", row + 1,
       col 0, "GRANT DROP PUBLIC SYNONYM TO V500;", row + 1,
       col 0, "GRANT EXECUTE ANY PROCEDURE TO V500;", row + 1,
       col 0, "GRANT INSERT ANY TABLE TO V500;", row + 1,
       col 0, "GRANT LOCK ANY TABLE TO V500;", row + 1,
       col 0, "GRANT SELECT ANY TABLE TO V500;", row + 1,
       col 0, "GRANT UNLIMITED TABLESPACE TO V500;", row + 1,
       col 0, "GRANT UPDATE ANY TABLE TO V500;", row + 1
      ENDIF
     ENDIF
     col 0, "grant ",
     CALL print(trim(c.priviledge)),
     " to ",
     CALL print(trim(b.user_name)), ";",
     row + 1, old_user = b.user_name
    FOOT REPORT
     col 0, " ", row + 1,
     col 0, "spool off", row + 1,
     col 0, " ", row + 1,
     col 0, "set termout off", row + 1,
     col 0, " ", row + 1,
     col 0, "@ora_root:[rdbms.admin]catdbsyn.sql;", row + 1,
     col 0, "@ora_root:[sqlplus.admin]pupbld.sql;", row + 1,
     col 0, " ", row + 1,
     col 0, "connect system/manager; ", row + 1,
     col 0, "@ora_root:[sqlplus.admin.help]hlpbld.sql helpus.sql;", row + 1,
     col 0, " ", row + 1,
     col 0, "connect v500/v500;", row + 1,
     col 0, "@ora_root:[rdbms.admin]catdbsyn.sql;", row + 1,
     col 0, "set termout on ", row + 1,
     col 0, " ", row + 1,
     col 0, "connect / as sysdba;", row + 2
     IF ((dm_env_import_request->target_undo_ind=0))
      col 0, " alter tablespace temp temporary;", row + 1
     ENDIF
     col 0, " alter user sys temporary tablespace temp;", row + 1,
     col 0, " alter user system temporary tablespace temp;", row + 1,
     col 0, " disconnect;", row + 1,
     col 0, " exit;", row + 1
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE aix_gen_temp_rb(x)
   SET cer_mtpt = request->cermtpt
   SET oracle_mtpt = request->orasecmtpt
   SET dba_string = concat(oracle_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SET logical script_dir value(concat(cer_mtpt,"/w_standard/",cnvtlower(dbname),"/dba"))
   SELECT INTO concat("script_dir","/create_rbs.sql")
    a.file_name, a.file_size, a.tablespace_name
    FROM dm_env_files a
    WHERE environment_id=env_id
     AND file_type="ROLLBACK"
    DETAIL
     col 0, "create tablespace ",
     CALL print(trim(a.tablespace_name)),
     row + 1, col 0, "datafile '/dev/r",
     CALL print(trim(a.file_name)), "'", " size ",
     CALL print(cnvtstring(a.file_size)), " reuse", row + 1,
     col 0, "default storage ", row + 1,
     col 0, "  (initial        1048576", row + 1,
     col 0, "   next           1048576", row + 1,
     col 0, "   pctincrease    0)", row + 1,
     col 0, "   extent management dictionary;", row + 1,
     col 0, row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("script_dir","/create_rbs.sql")
    a.rollback_seg_name, a.tablespace_name, a.initial_extent,
    a.next_extent, a.min_extents, a.max_extents,
    a.optimal
    FROM dm_env_rollback_segments a
    WHERE environment_id=env_id
    DETAIL
     col 0, "create rollback segment ",
     CALL print(trim(a.rollback_seg_name)),
     " tablespace ",
     CALL print(trim(a.tablespace_name)), row + 1,
     col 0, "  storage(initial     ",
     CALL print(cnvtstring(a.initial_extent)),
     row + 1, col 0, "          next        ",
     CALL print(cnvtstring(a.next_extent)), row + 1, col 0,
     "          minextents  ",
     CALL print(cnvtstring(a.min_extents)), row + 1,
     col 0, "          maxextents  ",
     CALL print(cnvtstring(a.max_extents)),
     row + 1, col 0, "          optimal     ",
     CALL print(cnvtstring(a.optimal)), ");", row + 1,
     col 0, row + 1, col 0,
     "alter rollback segment ",
     CALL print(trim(a.rollback_seg_name)), " online;",
     row + 1, col 0, row + 1
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("script_dir","/create_temp.sql")
    a.file_name, a.file_size, a.tablespace_name
    FROM dm_env_files a
    WHERE environment_id=env_id
     AND a.file_type IN ("DEFAULT", "MISC", "TEMP", "OTHER")
    DETAIL
     IF ((((dm_env_import_request->target_undo_ind=1)
      AND a.file_type != "TEMP") OR ((dm_env_import_request->target_undo_ind=0))) )
      col 0, "create tablespace ",
      CALL print(trim(a.tablespace_name)),
      row + 1, col 0, "datafile '/dev/r",
      CALL print(trim(a.file_name)), "'", " size ",
      CALL print(cnvtstring(a.file_size)), " reuse", row + 1
      IF ((dm_env_import_request->target_extent_management="LOCALLY MANAGED"))
       col 0, "autoextend off ", row + 1,
       col 0, "extent management local autoallocate ", row + 1,
       col 0, "segment space management auto; ", row + 1
      ELSE
       col 0, "default storage(", row + 1
       IF ((dm_env_import_request->target_database_version_type="PROD")
        AND a.file_type="TEMP")
        col 0, "  initial       5M", row + 1,
        col 0, "  next          5M", row + 1
       ELSE
        col 0, "  initial       1M", row + 1,
        col 0, "  next          1M", row + 1
       ENDIF
       col 0, "  minextents     1", row + 1,
       col 0, "  maxextents     unlimited", row + 1,
       col 0, "  pctincrease    0)", row + 1,
       col 0, "  extent management dictionary;", col 0,
       row + 1, col 0, row + 1,
       col 0, row + 1
      ENDIF
     ENDIF
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
