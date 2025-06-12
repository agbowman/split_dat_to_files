CREATE PROGRAM dba_view_db_ver
 IF (validate(reply->status_data.status,"/")="/")
  FREE SET reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationstatus = c1
        3 operationname = c15
        3 targetobjectname = c15
        3 targetobjectvalue = c50
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ((validate(request->old_dbver,- (1))=- (1)))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "OLD_DBVER"
  GO TO endprogram
 ELSE
  IF ((request->old_dbver < 1))
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "OLD_DBVER"
   GO TO endprogram
  ELSE
   SET old_dbver = request->old_dbver
  ENDIF
 ENDIF
 IF (validate(request->file_name,"/")="/")
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "FILE_NAME"
  GO TO endprogram
 ELSE
  IF ((request->file_name=""))
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "FILE_NAME"
   GO TO endprogram
  ELSE
   SET file_name = request->file_name
  ENDIF
 ENDIF
#start
 CALL video(r)
 CALL clear(1,1)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,10,"***   V 5 0 0    D B V E R S I O N    V I E W    M E N U   ***")
 CALL clear(3,2,78)
 CALL video(n)
 CALL text(05,05,"1.   DM_SIZE_DB_VERSION.")
 CALL text(06,05,"2.   DM_SIZE_DB_CONFIG.")
 CALL text(07,05,"3.   DM_SIZE_DB_TS.")
 CALL text(08,05,"4.   DM_SIZE_DB_CNTL_FILES.")
 CALL text(09,05,"5.   DM_SIZE_DB_REDO_LOGS.")
 CALL text(10,05,"6.   DM_SIZE_DB_ROLLBACK_SEGS.")
 CALL text(11,05,"99.  Return to Main Menu.")
 CALL text(16,05,"Your Selection? ")
 CALL accept(16,50,"99")
 SET selection = cnvtint(curaccept)
 CASE (selection)
  OF 1:
   GO TO version
  OF 2:
   GO TO config
  OF 3:
   GO TO ts
  OF 4:
   GO TO cntl_files
  OF 5:
   GO TO redo_logs
  OF 6:
   GO TO rollback_segs
  OF 99:
   GO TO endprogram
  ELSE
   CALL text(16,05,"Not a legal choice.")
   GO TO start
 ENDCASE
#version
 SELECT
  m.db_version, m.core_size, m.updt_dt_tm,
  m.description, m.updt_applctx, m.updt_cnt,
  m.updt_id, m.updt_task
  FROM dm_size_db_version m
  HEAD REPORT
   line_dunder = fillstring(131,"="), col 0, "Version",
   col 8, "Core Size", col 21,
   "Updated", col 32, "Description",
   col 102, "Ctx", col 106,
   "Count", col 114, "ID",
   col 118, "Task", row + 1,
   col 0, line_dunder, row + 1
  DETAIL
   col 0, m.db_version"#######", col 8,
   m.core_size"#########", col 19, m.updt_dt_tm"MM/DD/YYYY;3;D",
   col 32,
   CALL print(trim(m.description)), col 100,
   m.updt_applctx"#####", col 106, m.updt_cnt"#####",
   col 111, m.updt_id"#####", col 117,
   m.updt_task"#####", row + 1
  WITH nocounter
 ;end select
 GO TO start
#config
 SELECT
  m.config_parm, m.parm_type, m.value,
  m.updt_applctx, m.updt_dt_tm, m.updt_cnt,
  m.updt_id, m.updt_task
  FROM dm_size_db_config m
  WHERE m.db_version=old_dbver
  ORDER BY m.parm_type, m.config_parm
  HEAD REPORT
   line_dunder = fillstring(131,"="), col 20, "Table name : DM_SIZE_DB_CONFIG",
   row + 1, col 20, "DB Version : ",
   CALL print(trim(format(old_dbver,";l"))), row + 2
  HEAD m.parm_type
   IF (((trim(m.parm_type)="1") OR (((trim(m.parm_type)="2") OR (trim(m.parm_type)="3")) )) )
    IF (trim(m.parm_type)="1")
     parm_string = "INIT.ORA (Boolean)  "
    ENDIF
    IF (trim(m.parm_type)="2")
     parm_string = "INIT.ORA (Character)"
    ENDIF
    IF (trim(m.parm_type)="3")
     parm_string = "INIT.ORA (Numeric)  "
    ENDIF
   ELSE
    parm_string = "SYSTEM"
   ENDIF
   col 0, "Type: ", parm_string,
   " PARAMETERS.", col 85, "Updated",
   col 102, "Ctx", col 106,
   "Count", col 114, "ID",
   col 118, "Task", row + 1,
   col 0, line_dunder, row + 1
  DETAIL
   col 0,
   CALL print(trim(m.config_parm)), col 32,
   " = ",
   CALL print(trim(m.value)), col 85,
   m.updt_dt_tm"MM/DD/YYYY;3;D", col 100, m.updt_applctx"#####",
   col 106, m.updt_cnt"#####", col 111,
   m.updt_id"#####", col 117, m.updt_task"#####",
   row + 1
  FOOT  m.parm_type
   row + 1
  WITH nocounter
 ;end select
 GO TO start
#ts
 SELECT
  m.tablespace_name, m.file_name, m.file_size,
  m.ts_type, m.updt_applctx, m.updt_dt_tm,
  m.updt_cnt, m.updt_id, m.updt_task
  FROM dm_size_db_ts m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"="), col 20, "Table name : DM_SIZE_DB_TS",
   row + 1, col 20, "DB Version : ",
   CALL print(trim(format(old_dbver,";l"))), row + 1, col 20,
   "Note: Column 0 indicates tablespace type", row + 1, col 20,
   "      where D - default, R - rollback, S - system, T - temp,", "O - other", row + 2,
   col 0, "0", col 2,
   "Tablespace name", col 21, "File size",
   col 34, "Updated", col 55,
   "File name", col 102, "Ctx",
   col 106, "Count", col 114,
   "ID", col 118, "Task",
   row + 1, col 0, line_dunder,
   row + 1
  DETAIL
   col 0,
   CALL print(trim(substring(1,1,m.ts_type))), col 2,
   CALL print(trim(m.tablespace_name)), col 18, m.file_size"############",
   col 31, m.updt_dt_tm"MM/DD/YYYY;3;D", col 43,
   CALL print(trim(m.file_name)), col 100, m.updt_applctx"#####",
   col 106, m.updt_cnt"#####", col 111,
   m.updt_id"#####", col 117, m.updt_task"#####",
   row + 1
  WITH nocounter
 ;end select
 GO TO start
#cntl_files
 SELECT
  m.cntl_file_num, m.file_name, m.file_size,
  m.updt_applctx, m.updt_dt_tm, m.updt_cnt,
  m.updt_id, m.updt_task
  FROM dm_size_db_cntl_files m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"="), col 20, "Table name : DM_SIZE_DB_CNTL_FILES",
   row + 1, col 20, "DB Version : ",
   CALL print(trim(format(old_dbver,";l"))), row + 1, col 0,
   "Amount", col 15, "File name",
   col 70, "File Size", col 85,
   "Updated", col 100, "Ctx",
   col 109, "Count", col 117,
   "ID", col 125, "Task",
   row + 1, col 0, line_dunder,
   row + 1
  DETAIL
   col 0, m.cntl_file_num, col 15,
   CALL print(trim(m.file_name)), col 70, m.file_size";l",
   col 85, m.updt_dt_tm"MM/DD/YYYY;3;D", col 100,
   m.updt_applctx"#####", col 109, m.updt_cnt"#####",
   col 117, m.updt_id"#####", col 125,
   m.updt_task"####", row + 1
  WITH nocounter
 ;end select
 GO TO start
#redo_logs
 SELECT
  m.groups_num, m.members_num, m.file_name,
  m.log_size, m.updt_applctx, m.updt_dt_tm,
  m.updt_cnt, m.updt_id, m.updt_task
  FROM dm_size_db_redo_logs m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"="), col 20, "Table name : DM_SIZE_DB_REDO_LOGS",
   row + 1, col 20, "DB Version : ",
   CALL print(trim(format(old_dbver,";l"))), row + 1, col 1,
   "Group(s)", col 11, "Member(s)",
   col 21, "File Name", col 74,
   "Log size", col 88, "Updated",
   col 102, "Ctx", col 106,
   "Count", col 114, "ID",
   col 118, "Task", row + 1,
   col 0, line_dunder, row + 1
  DETAIL
   col 0, m.groups_num"#########", col 10,
   m.members_num"##########", col 21,
   CALL print(trim(m.file_name)),
   col 70, m.log_size"############", col 85,
   m.updt_dt_tm"MM/DD/YYYY;3;D", col 100, m.updt_applctx"#####",
   col 106, m.updt_cnt"#####", col 111,
   m.updt_id"#####", col 117, m.updt_task"#####",
   row + 1
  WITH nocounter
 ;end select
 GO TO start
#rollback_segs
 SELECT
  m.rollback_seg_name, m.tablespace_name, m.initial_extent,
  m.next_extent, m.min_extents, m.max_extents,
  m.optimal, m.updt_applctx, m.updt_dt_tm,
  m.updt_cnt, m.updt_id, m.updt_task
  FROM dm_size_db_rollback_segs m
  WHERE m.db_version=old_dbver
  ORDER BY m.tablespace_name, m.rollback_seg_name
  HEAD REPORT
   line_under = fillstring(131,"-"), col 20, "Table name : DM_SIZE_DB_ROLLBACK_SEGS",
   row + 1, col 20, "DB Version : ",
   CALL print(trim(format(old_dbver,";l"))), row + 1
  HEAD m.tablespace_name
   col 0, "Tablespace_name: ",
   CALL print(trim(m.tablespace_name)),
   row + 1, col 0, "Segment Name",
   col 30, "Initial Ext.", col 46,
   "Next Ext.", col 55, "Min Ext.",
   col 64, "Max Ext.", col 77,
   "Optimal", col 88, "Updated",
   col 102, "Ctx", col 106,
   "Count", col 114, "ID",
   col 118, "Task", row + 1,
   col 0, line_under, row + 1
  DETAIL
   col 0,
   CALL print(trim(m.rollback_seg_name)), col 30,
   m.initial_extent"############", col 43, m.next_extent"############",
   col 55, m.min_extents"########", col 64,
   m.max_extents"########", col 72, m.optimal"############",
   col 85, m.updt_dt_tm"MM/DD/YYYY;3;D", col 100,
   m.updt_applctx"#####", col 106, m.updt_cnt"#####",
   col 111, m.updt_id"#####", col 117,
   m.updt_task"#####", row + 1
  FOOT  m.tablespace_name
   row + 1
  WITH nocounter
 ;end select
 GO TO start
#endprogram
END GO
