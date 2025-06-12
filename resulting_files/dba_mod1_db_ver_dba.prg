CREATE PROGRAM dba_mod1_db_ver:dba
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
 RECORD rec1(
   1 qual[100]
     2 config_parm = c80
     2 value = c80
     2 c_parm = i4
     2 parm_type = c30
 )
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
 SET bilang = 1
#getinfo
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,18,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,12,"- V 5 0 0    D B V E R S I O N    S U B R O U T I N E -")
 CALL clear(3,2,78)
 CALL text(03,12,"      I N I T / S Y S T E M    P A R A M E T E R S     ")
 CALL video(n)
 CALL text(05,05,"NOTE:  Hit <enter> on question below will indicate that this")
 CALL text(06,05,"       subroutine is completed...")
 CALL text(09,05,"Enter configuration parameter .i.e. db_block_buffers: ")
 CALL text(11,05,"Enter value for parameter .i.e. 1000: ")
#parm_input
 CALL clear(23,1)
 CALL text(23,1,"Help available on <HLP> key ")
 SET help =
 SELECT INTO "nl:"
  v.name";l"
  FROM v$parameter v
  ORDER BY v.name
  WITH nocounter
 ;end select
 CALL accept(10,05,"p(63);chl","ceryfl")
 SET help = off
 SET validate = off
 IF (curaccept="ceryfl")
  SET bilang = (bilang - 1)
  GO TO justcont
 ELSE
  SET rec1->qual[bilang].config_parm = cnvtlower(curaccept)
 ENDIF
 SET count_parm = 0
 SELECT INTO "nl:"
  cnt_name = count(v.name)
  FROM v$parameter v
  WHERE (v.name=rec1->qual[bilang].config_parm)
  DETAIL
   count_parm = cnt_name
  WITH nocounter
 ;end select
 IF (count_parm != 1)
  CALL clear(23,1)
  CALL text(23,1,"Invalid parameter !!!")
  CALL pause(3)
  GO TO parm_input
 ENDIF
 SET rec1->qual[bilang].c_parm = 0
 SELECT INTO "nl:"
  cnt_parm = count(d.config_parm)
  FROM dm_size_db_config d
  WHERE d.config_parm=cnvtlower(rec1->qual[bilang].config_parm)
   AND d.db_version=old_dbver
  DETAIL
   rec1->qual[bilang].c_parm = cnt_parm
  WITH nocounter
 ;end select
#value_input
 IF ((rec1->qual[bilang].c_parm=1))
  SELECT INTO "nl:"
   d.value
   FROM dm_size_db_config d
   WHERE d.config_parm=cnvtlower(rec1->qual[bilang].config_parm)
   DETAIL
    rec1->qual[bilang].value = cnvtlower(d.value)
   WITH nocounter
  ;end select
  IF ((rec1->qual[bilang].config_parm != "control_files"))
   CALL accept(12,05,"P(70);cl",rec1->qual[bilang].value)
  ENDIF
 ELSE
  CALL accept(12,05,"P(70);cl"
   WHERE curaccept != " ")
 ENDIF
 IF (trim(cnvtlower(rec1->qual[bilang].config_parm))="control_files")
  CALL text(12,05,substring(1,65,rec1->qual[bilang].value))
  CALL text(13,05,substring(66,65,rec1->qual[bilang].value))
  CALL text(23,1,"Parameter cannot be edited.")
  CALL pause(3)
  GO TO getinfo
 ENDIF
 SELECT INTO "nl:"
  v.type, v.name
  FROM v$parameter v
  WHERE (v.name=rec1->qual[bilang].config_parm)
  DETAIL
   rec1->qual[bilang].parm_type = cnvtstring(v.type)
  WITH nocounter
 ;end select
 SET rec1->qual[bilang].value = curaccept
 SET err = "N"
 EXECUTE validate_value
 IF (err="Y")
  GO TO value_input
 ENDIF
 CALL clear(23,1)
 SET bilang = (bilang+ 1)
 GO TO getinfo
#justcont
 SELECT INTO concat(file_name)
  *
  FROM dummyt
  DETAIL
   FOR (cnt = 1 TO bilang)
     IF ((rec1->qual[cnt].c_parm=1))
      col 0, "RDB UPDATE DM_SIZE_DB_CONFIG", row + 1,
      col 5, "set value = ",
      CALL print(concat("'",trim(cnvtlower(rec1->qual[cnt].value)),"'")),
      row + 1, col 5, "where db_version = ",
      CALL print(trim(format(old_dbver,";l"))), row + 1, col 5,
      "and config_parm = ",
      CALL print(concat("'",trim(cnvtlower(rec1->qual[cnt].config_parm)),"'")), " go",
      row + 2
     ELSE
      col 0, "RDB INSERT INTO DM_SIZE_DB_CONFIG VALUES(", row + 1,
      col 5,
      CALL print(trim(format(old_dbver,";l"))), col 20,
      CALL print(concat(",'",trim(cnvtlower(rec1->qual[cnt].config_parm)))), "',", row + 1,
      col 5,
      CALL print(trim(rec1->qual[cnt].parm_type)), row + 1,
      col 5,
      CALL print(concat(",'",trim(cnvtlower(rec1->qual[cnt].value)),"',")), row + 1,
      col 5, "0,sysdate,0,0,0) go ", row + 2
     ENDIF
   ENDFOR
   col 0, "commit go", row + 2
  WITH nocounter
 ;end select
END GO
