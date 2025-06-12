CREATE PROGRAM dba_create_v500_00
 SET message = noinformation
 SET trace = nocost
 SET message = window
 SET env_id = request->environment_id
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET target_os = request->target_os
 SET dbname = trim(request->database_name)
 SET reply->status = "F"
 CALL text(23,05,"Checking SID...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL vms_check_sid(1)
 ELSEIF (target_os="AIX")
  CALL aix_check_sid(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL text(23,05,"Please confirm the above information before continuing.")
 CALL text(24,05,"Continue(Y/N)?")
 CALL accept(24,20,"X;CU","Y")
 IF (cnvtupper(curaccept) != "Y")
  SET failed = "T"
  SET exit_message = "Please re-execute dm_env_import with the necessary modifications. Exit..."
  GO TO exit_script
 ELSE
  SET row_num = 10
  WHILE (row_num <= 21)
   CALL clear(row_num,5,74)
   SET row_num = (row_num+ 1)
  ENDWHILE
  CALL clear(23,05,74)
  CALL clear(24,05,74)
  CALL display_info(1)
  CALL text(23,05,"Is the above information correct(Y/N)?")
  CALL accept(23,45,"X;CU","Y")
  IF (cnvtupper(curaccept) != "Y")
   SET failed = "T"
   SET exit_message = "Please go to dm_env_maint to make necessary modification. Exit..."
   GO TO exit_script
  ENDIF
 ENDIF
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 SUBROUTINE vms_check_sid(x)
   SET dbdisk = request->database_disk
   SET dbstr = request->root_dir_name
   IF ((dm_env_import_request->base_oracle_version="8"))
    SET t_position = 0
    SET sid_found = "F"
    SET t_node = request->node
    FREE DEFINE rtl
    DEFINE rtl "ora_rdbms:ora_rdbms_sids.dat"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      t_position = 0, sid_found = "F"
     DETAIL
      t_position = findstring(concat(trim(t_node)," ",trim(dbname)," "),r.line)
      IF (t_position > 0)
       sid_found = "T"
      ENDIF
     WITH nocounter
    ;end select
    FREE DEFINE rtl
    CALL clear(23,05,74)
    IF (sid_found="T")
     SET exit_message = concat("Database ",trim(dbname)," already exists on node ",trim(t_node),
      ". Exit...")
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ELSE
    DECLARE file_spec = vc
    SET dbfiles_found = 0
    SELECT INTO "nl:"
     FROM dm_env_files def
     WHERE (def.environment_id=request->environment_id)
      AND def.file_type IN ("ROLLBACK", "TEMP", "SYSTEM", "DEFAULT", "UNDO")
     DETAIL
      file_spec = build(request->rdb_directory,def.file_name)
      IF (findfile(file_spec) > 0)
       dbfiles_found = 1
      ENDIF
     WITH nocounter
    ;end select
    CALL clear(23,05,74)
    IF (dbfiles_found=1)
     SET exit_message = concat("Database files already exist for ",trim(dbname),"  on node ",trim(
       t_node),". Exiting...")
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL clear(10,02,74)
   CALL clear(11,02,74)
   CALL clear(12,02,74)
   CALL clear(13,02,74)
   CALL text(7,02,"Database will be created on the following disks and directories:")
   CALL text(8,02,concat("dbroot:  ",request->rdb_directory))
   CALL text(9,02,concat("archive: ",request->arc_directory))
   CALL text(10,02,concat("trace:   ",dbdisk,":[",dbstr,".DB_",
     dbname,".TRACE]"))
   CALL text(12,02,"Database will be created using the following rdbms:")
   CALL text(13,02,concat("rdbms version:        ",request->rdbms_ver))
   CALL text(14,02,concat("rdbms code directory: ",request->vms_ora_root))
   CALL clear(23,02,74)
   CALL clear(24,02,74)
 END ;Subroutine
 SUBROUTINE aix_check_sid(x)
   SET oracle_mtpt = request->orasecmtpt
   SET ora_pri_mtpt = request->oraprimtpt
   SET oracle_version = request->oracleversion
   SET position = 0
   SET sid_found = "F"
   SET t_node = fillstring(40," ")
   CALL text(10,05,"Database will be created on the following directories:")
   CALL text(12,05,concat("database directory: ",oracle_mtpt,"/oralink/",cnvtlower(dbname)))
   CALL text(13,05,concat("admin file:         ",oracle_mtpt,"/oracle/admin/",cnvtlower(dbname)))
   CALL text(14,05,concat("archive dest:       ",oracle_mtpt,"/oracle/admin/",cnvtlower(dbname),
     "/arch"))
 END ;Subroutine
 SUBROUTINE display_info(x)
   CALL screen_0(1)
   SET info_array[10] = fillstring(70," ")
   SET row_returned = 0
   SELECT INTO "nl:"
    info = concat(trim(cnvtupper(d.tablespace_name)),":",trim(d.file_name)," on ",trim(d.disk_name))
    FROM dm_env_files d
    WHERE d.environment_id=env_id
     AND d.file_type IN ("SYSTEM", "TEMP", "TEMPORARY", "ROLLBACK", "MISC",
    "DEFAULT", "OTHER", "UNDO", "SYSAUX")
    ORDER BY d.file_type
    HEAD REPORT
     info_array[10] = fillstring(70," "), row_returned = 0,
     CALL text(6,2,"Disk assignments are: ")
    DETAIL
     row_returned = (row_returned+ 1), info_array[row_returned] = info
    WITH nocounter
   ;end select
   SET row_cnt = 1
   SET cntx = 8
   WHILE (row_cnt <= row_returned)
     CALL text(cntx,2,trim(info_array[row_cnt]))
     SET cntx = (cntx+ 1)
     SET row_cnt = (row_cnt+ 1)
   ENDWHILE
   SET info_array[10] = fillstring(70," ")
   SET row_returned = 0
   SELECT INTO "nl:"
    info = concat("CONTROL",trim(cnvtstring(d.cntl_file_num)),":",trim(d.file_name)," on ",
     trim(d.disk_name))
    FROM dm_env_control_files d
    WHERE d.environment_id=env_id
    ORDER BY d.cntl_file_num
    HEAD REPORT
     info_array[10] = fillstring(70," "), row_returned = 0
    DETAIL
     row_returned = (row_returned+ 1), info_array[row_returned] = info
    WITH nocounter
   ;end select
   SET row_cnt = 1
   WHILE (row_cnt <= row_returned)
     CALL text(cntx,2,trim(info_array[row_cnt]))
     SET cntx = (cntx+ 1)
     SET row_cnt = (row_cnt+ 1)
   ENDWHILE
   SET info_array1[12] = fillstring(70," ")
   SET row_returned = 0
   SELECT INTO "nl:"
    info = concat("REDO",trim(cnvtstring(d.group_number)),trim(cnvtstring(d.member_number)),":",trim(
      d.file_name),
     " on ",trim(d.disk_name))
    FROM dm_env_redo_logs d
    WHERE d.environment_id=env_id
    ORDER BY d.group_number, d.member_number
    HEAD REPORT
     info_array1[12] = fillstring(70," "), row_returned = 0
    DETAIL
     row_returned = (row_returned+ 1), info_array1[row_returned] = info
    WITH nocounter
   ;end select
   SET row_cnt = 1
   SET cntx = 8
   WHILE (row_cnt <= row_returned)
     CALL text(cntx,43,trim(info_array1[row_cnt]))
     SET cntx = (cntx+ 1)
     SET row_cnt = (row_cnt+ 1)
   ENDWHILE
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
