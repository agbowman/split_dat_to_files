CREATE PROGRAM db_build_db_ver:dba
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
 IF ((validate(request->new_dbver,- (1))=- (1)))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "NEW_DBVER"
  GO TO endprogram
 ELSE
  IF ((request->new_dbver < 1))
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "NEW_DBVER"
   GO TO endprogram
  ELSE
   SET new_dbver = request->new_dbver
  ENDIF
 ENDIF
 IF (validate(request->new_desc,"/")="/")
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "NEW_DESC"
  GO TO endprogram
 ELSE
  IF ((request->new_desc=""))
   SET reply->subeventstatus[1].operationstatus = "F"
   SET reply->subeventstatus[1].operationname = "VALUATE"
   SET reply->subeventstatus[1].targetobjectname = "FIELD"
   SET reply->subeventstatus[1].targetobjectvalue = "NEW_DESC"
   GO TO endprogram
  ELSE
   SET new_desc = request->new_desc
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
 SELECT INTO concat(trim(file_name))
  d.*
  FROM dummyt d
  DETAIL
   col 0, "RDB INSERT INTO DM_SIZE_DB_VERSION", row + 1,
   col 5, "select ",
   CALL print(trim(format(new_dbver,";l"))),
   ",",
   CALL print(concat("'",trim(new_desc),"'")), ",core_size, 0,sysdate, 0,0,0 ",
   row + 1, col 5, "from dm_size_db_version",
   row + 1, col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go", row + 2,
   col 0, "RDB INSERT INTO DM_SIZE_DB_CONFIG", row + 1,
   col 5, "select ",
   CALL print(trim(format(new_dbver,";l"))),
   ",config_parm,parm_type,value,0,sysdate,0,0,0 ", row + 1, col 5,
   "from dm_size_db_config", row + 1, col 5,
   "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go",
   row + 2, col 0, "RDB INSERT INTO DM_SIZE_DB_TS",
   row + 1, col 5, "select ",
   CALL print(trim(format(new_dbver,";l"))),
   ",tablespace_name,file_name,file_size,ts_type,0,sysdate,0,0,0 ", row + 1,
   col 5, "from dm_size_db_ts", row + 1,
   col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))),
   " go", row + 2, col 0,
   "RDB INSERT INTO DM_SIZE_DB_CNTL_FILES", row + 1, col 5,
   "select ",
   CALL print(trim(format(new_dbver,";l"))), ",cntl_file_num,file_name,0,sysdate,0,0,0,file_size ",
   row + 1, col 5, "from dm_size_db_cntl_files",
   row + 1, col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go", row + 2,
   col 0, "RDB INSERT INTO DM_SIZE_DB_REDO_LOGS", row + 1,
   col 5, "select ",
   CALL print(trim(format(new_dbver,";l"))),
   ",groups_num,members_num,file_name,log_size,0,sysdate,0,0,0 ", row + 1, col 5,
   "from dm_size_db_redo_logs", row + 1, col 5,
   "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go",
   row + 2, col 0, "RDB INSERT INTO DM_SIZE_DB_ROLLBACK_SEGS",
   row + 1, col 5, "select ",
   CALL print(trim(format(new_dbver,";l"))), ",rollback_seg_name,tablespace_name,initial_extent,",
   row + 1,
   col 5, "next_extent,min_extents,max_extents,optimal,0,sysdate,0,0,0 ", row + 1,
   col 5, "from dm_size_db_rollback_segs", row + 1,
   col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))),
   " go", row + 2
  WITH nocounter
 ;end select
END GO
