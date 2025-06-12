CREATE PROGRAM dba_exec_db_ver:dba
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
   1 qual[10]
     2 buffer = c132
 )
 SET reply->status_data.status = "F"
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
 FREE DEFINE rtl
 DEFINE rtl concat(trim(file_name))
 SET bilang = 0
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  WHERE r.line != "       "
  DETAIL
   bilang = (bilang+ 1)
   IF (mod(bilang,10)=1
    AND bilang != 1)
    stat = alter(rec1->qual,(bilang+ 9))
   ENDIF
   rec1->qual[bilang].buffer = r.line
  WITH nocounter
 ;end select
 IF (bilang=0)
  SET faillure_mode = 1
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "PERFORM"
  SET reply->subeventstatus[1].targetobjectname = "EXEC"
  SET reply->subeventstatus[1].targetobjectvalue = "DB_VERSION"
  GO TO endprogram
 ELSE
  FOR (num = 1 TO bilang)
   SET my_size = size(rec1->qual,5)
   CALL parser(rec1->qual[num].buffer)
  ENDFOR
 ENDIF
 IF (cursys="AIX")
  SET dclcom = concat("rm ccluserdir:",trim(file_name),".dat")
 ELSE
  SET dclcom = concat("delete ccluserdir:",trim(file_name),".dat;*")
 ENDIF
 SET len = size(trim(dclcom))
 SET status2 = 0
 CALL dcl(dclcom,len,status2)
 SET stats = alter(rec1->qual,1)
 SET reply->status_data.status = "S"
END GO
