CREATE PROGRAM dba_mod4_db_ver:dba
 RECORD rec1(
   1 fsize = i4
   1 num_grp = i4
   1 num_mem = i4
 )
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
 CALL text(2,20,"***   V 5 0 0    M O D I F Y    D B V E R S I O N   ***")
 CALL text(3,20,"****   R E D O    L O G S    P A R A M E T E R S   ****")
 CALL video(n)
 CALL text(07,05,"Enter file size         : ")
 CALL text(08,05,"Enter number of group(s): ")
 CALL text(09,05,"Enter number of member(s): ")
 SELECT INTO "nl:"
  d.log_size, d.groups_num, d.members_num
  FROM dm_size_db_redo_logs d
  WHERE d.db_version=old_dbver
  DETAIL
   rec1->fsize = d.log_size, rec1->num_grp = d.groups_num, rec1->num_mem = d.members_num
  WITH nocounter
 ;end select
 CALL accept(07,32,"9(11)",rec1->fsize
  WHERE curaccept > 0)
 SET rec1->fsize = curaccept
 CALL accept(08,32,"9(5)",rec1->num_grp
  WHERE curaccept > 1.9)
 SET rec1->num_grp = curaccept
 CALL accept(09,32,"9(6)",rec1->num_mem
  WHERE curaccept > 0)
 SET rec1->num_mem = curaccept
 SELECT INTO concat(file_name)
  *
  FROM dummyt
  DETAIL
   col 0, "RDB UPDATE DM_SIZE_DB_REDO_LOGS ", row + 1,
   col 5, "set log_size =  ",
   CALL print(rec1->fsize),
   ",", row + 1, col 5,
   "    groups_num = ",
   CALL print(rec1->num_grp), ",",
   row + 1, col 5, "    members_num = ",
   CALL print(rec1->num_mem), row + 1, col 5,
   "where db_version = ",
   CALL print(trim(format(old_dbver,";l"))), row + 1,
   col 5, " go", row + 2,
   col 0, "commit go", row + 2
  WITH nocounter
 ;end select
END GO
