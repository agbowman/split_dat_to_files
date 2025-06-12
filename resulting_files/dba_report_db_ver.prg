CREATE PROGRAM dba_report_db_ver
 PAINT
 SET old_dbver = request->old_dbver
 SET fname = build("db_ver_report_",old_dbver)
 SELECT INTO trim(fname)
  m.db_version, m.core_size, m.description
  FROM dm_size_db_version m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"-"), row + 1, row + 1,
   col 45, "SUMMARY REPORT FOR DB VERSION  :", col + 1,
   old_dbver";l", row + 1, col 45,
   "***********************************", row + 1, row + 1,
   row + 1, row + 1, col 0,
   "Version", col 20, "Core Size",
   col 40, "Description", row + 1,
   col 0, line_dunder, row + 1
  DETAIL
   col 0, m.db_version"########", col 20,
   m.core_size"###########", col 40,
   CALL print(trim(m.description))
  WITH nocounter, noformfeed, maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  m.config_parm, m.parm_type, m.value
  FROM dm_size_db_config m
  WHERE m.db_version=old_dbver
  ORDER BY m.parm_type, m.config_parm
  HEAD REPORT
   line_dunder = fillstring(131,"-"), row + 1, row + 1,
   col 45, "*** CONFIGURATION PARAMETERS ***", row + 1,
   row + 1
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
   " PARAMETERS.", row + 1, col 0,
   line_dunder, row + 1
  DETAIL
   col 0,
   CALL print(trim(m.config_parm)), col 50,
   " = ",
   CALL print(trim(m.value)), row + 1
  FOOT  m.parm_type
   row + 1
  WITH nocounter, append, noformfeed,
   maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  m.tablespace_name, m.file_name, m.file_size,
  m.ts_type
  FROM dm_size_db_ts m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"-"), row + 1, row + 1,
   col 50, "*** TABLESPACES *** ", row + 1,
   row + 1, col 0, "Tablespace name",
   col 30, "File size", col 50,
   "Tablespace Type", row + 1, col 0,
   line_dunder, row + 1
  DETAIL
   col 0,
   CALL print(trim(m.tablespace_name)), col 30,
   m.file_size"############", col 50,
   CALL print(trim(m.ts_type)),
   row + 1
  WITH nocounter, append, noformfeed,
   maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  m.cntl_file_num, m.file_name, m.file_size
  FROM dm_size_db_cntl_files m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"-"), row + 1, row + 1,
   col 50, "*** CONTROL FILES ***", row + 1,
   row + 1, col 0, "No. Control Files",
   col 20, "File name", col 70,
   "File Size", row + 1, col 0,
   line_dunder, row + 1
  DETAIL
   col 0, m.cntl_file_num, col 20,
   CALL print(trim(m.file_name)), col 70, m.file_size";l",
   row + 1
  WITH nocounter, noformfeed, append,
   maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  m.groups_num, m.members_num, m.file_name,
  m.log_size
  FROM dm_size_db_redo_logs m
  WHERE m.db_version=old_dbver
  HEAD REPORT
   line_dunder = fillstring(131,"-"), row + 1, row + 1,
   col 50, "*** REDO LOGS ***", row + 1,
   row + 1, col 0, "Group(s)",
   col 11, "Member(s)", col 21,
   "File Name", col 74, "Log size",
   row + 1, col 0, line_dunder,
   row + 1
  DETAIL
   col 0, m.groups_num"#########", col 10,
   m.members_num"##########", col 21,
   CALL print(trim(m.file_name)),
   col 70, m.log_size"############", row + 1
  WITH nocounter, noformfeed, append,
   maxrow = 1
 ;end select
 SELECT INTO trim(fname)
  m.rollback_seg_name, m.tablespace_name, m.initial_extent,
  m.next_extent, m.min_extents, m.max_extents,
  m.optimal
  FROM dm_size_db_rollback_segs m
  WHERE m.db_version=old_dbver
  ORDER BY m.tablespace_name, m.rollback_seg_name
  HEAD REPORT
   line_under = fillstring(131,"-"), row + 1, row + 1,
   col 45, "*** ROLLBACK SEGMENTS ***", row + 1,
   row + 1
  HEAD m.tablespace_name
   col 0, "Tablespace_name: ",
   CALL print(trim(m.tablespace_name)),
   row + 1, col 0, "Segment Name",
   col 30, "Initial Ext.", col 46,
   "Next Ext.", col 61, "Min Ext.",
   col 76, "Max Ext.", col 81,
   "Optimal", row + 1, col 0,
   line_under, row + 1
  DETAIL
   col 0,
   CALL print(trim(m.rollback_seg_name)), col 30,
   m.initial_extent"############", col 46, m.next_extent"############",
   col 61, m.min_extents"########", col 76,
   m.max_extents"########", col 81, m.optimal"############",
   row + 1
  FOOT  m.tablespace_name
   row + 1
  WITH nocounter, noformfeed, append,
   maxrow = 1
 ;end select
 CALL text(23,1,"Report Available in ccluserdir:")
 SET str = concat(trim(fname),".dat")
 CALL text(23,32,str)
 CALL pause(2)
#endprogram
END GO
