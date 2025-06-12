CREATE PROGRAM dba_delete_db_ver:dba
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
 SELECT INTO concat(trim(file_name))
  *
  FROM dummyt
  DETAIL
   col 0, "RDB DELETE FROM  DM_SIZE_DB_CONFIG", row + 1,
   col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))),
   " go", row + 2, col 0,
   "RDB DELETE FROM DM_SIZE_DB_TS", row + 1, col 5,
   "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go",
   row + 2, col 0, "RDB DELETE FROM DM_SIZE_DB_CNTL_FILES",
   row + 1, col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go", row + 2,
   col 0, "RDB DELETE FROM DM_SIZE_DB_REDO_LOGS", row + 1,
   col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))),
   " go", row + 2, col 0,
   "RDB DELETE FROM DM_SIZE_DB_ROLLBACK_SEGS", row + 1, col 5,
   "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go",
   row + 2, col 0, "RDB DELETE FROM DM_SIZE_DB_VERSION",
   row + 1, col 5, "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go", row + 2,
   col 0, "commit go", row + 2
  WITH nocounter
 ;end select
END GO
