CREATE PROGRAM dba_mod3_db_ver:dba
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
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,12,"-  V 5 0 0    D B V E R S I O N    S U B R O U T I N E  -")
 CALL clear(3,2,78)
 CALL text(03,12,"     C O N T R O L    F I L E S    P A R A M E T E R")
 CALL video(n)
 CALL text(6,05,"Enter the number of control files: ")
 CALL text(8,05,"Enter file name : ")
 CALL text(11,05,"Enter file size : ")
 SET num = 0
 SET fname = fillstring(252," ")
 SET fsize = 0
 SELECT INTO "nl:"
  FROM dm_size_db_cntl_files d
  PLAN (d
   WHERE d.db_version=old_dbver)
  DETAIL
   num = d.cntl_file_num, fname = d.file_name, fsize = d.file_size
  WITH nocounter
 ;end select
 CALL accept(6,40,"99999",num
  WHERE curaccept > 0)
 SET num = curaccept
 CALL accept(9,10,"P(60);cu",fname)
 SET fname = curaccept
 CALL accept(11,40,"9999999999",fsize)
 SET fsize = curaccept
 SET p_value = fillstring(100," ")
 SET ind = 0
 SET sub_name = "ora_control"
 FOR (ind = 1 TO num)
   IF (ind=1)
    SET p_value = build(sub_name,ind)
   ELSE
    SET p_value = concat(trim(p_value),",")
    SET p_value = concat(trim(p_value),build(sub_name,ind))
   ENDIF
 ENDFOR
 SELECT INTO concat(file_name)
  *
  FROM dummyt
  DETAIL
   col 0, "RDB UPDATE DM_SIZE_DB_CNTL_FILES", row + 1,
   col 5, "set file_name = '",
   CALL print(trim(fname)),
   "'", row + 1, col 5,
   ",file_size = ",
   CALL print(fsize), row + 1,
   col 5, ",cntl_file_num = ",
   CALL print(num),
   " where ", row + 1, col 5,
   "db_version = ",
   CALL print(trim(format(old_dbver,";l"))), " go",
   row + 2, col 5, "RDB UPDATE DM_SIZE_DB_CONFIG ",
   row + 1, col 5, "set value = '(",
   CALL print(concat(trim(p_value),")'")), row + 1, col 5,
   " where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), row + 1,
   col 5, "and config_parm = 'control_files' go ", row + 2,
   col 0, "commit go", row + 2
  WITH nocounter
 ;end select
END GO
