CREATE PROGRAM dba_replace:dba
 SET reply->status_data.status = "F"
 IF ( NOT (file1 > ""))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "FILE1"
  GO TO endprogram
 ELSE
  FREE DEFINE rtl
  DEFINE rtl file1
 ENDIF
 IF ( NOT (file2 > ""))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "FILE2"
  GO TO endprogram
 ENDIF
 IF ( NOT (str1 > ""))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "STR1"
  GO TO endprogram
 ELSE
  SET str1 = trim(str1)
 ENDIF
 IF ( NOT (str2 > ""))
  SET reply->subeventstatus[1].operationstatus = "F"
  SET reply->subeventstatus[1].operationname = "CONTAIN"
  SET reply->subeventstatus[1].targetobjectname = "FIELD"
  SET reply->subeventstatus[1].targetobjectvalue = "STR2"
  GO TO endprogram
 ELSE
  SET str2 = trim(str2)
 ENDIF
 SELECT INTO value(file2)
  r.line
  FROM rtlt r
  HEAD REPORT
   temp_len = size(trim(str1))
  DETAIL
   IF (findstring(trim(str1),r.line) != 0)
    first_str = substring(1,findstring(trim(str1),r.line),r.line), first_strlen = size(trim(first_str
      )), first_str = substring(1,(findstring(trim(str1),r.line) - 1),r.line),
    sec_str = substring((findstring(trim(str1),r.line)+ temp_len),132,r.line)
    IF (findstring(trim(str1),sec_str)=0)
     col 0,
     CALL print(trim(first_str))
     IF (substring((first_strlen - 1),1,first_str)=" ")
      " "
     ENDIF
     CALL print(trim(str2)),
     CALL print(trim(sec_str)), row + 1
    ELSE
     sec_str1 = substring(1,findstring(trim(str1),sec_str),sec_str), sec_strlen = size(trim(sec_str1)
      ), sec_str1 = substring(1,(findstring(trim(str1),sec_str) - 1),sec_str),
     third_str = substring((findstring(trim(str1),sec_str)+ temp_len),130,sec_str), col 0,
     CALL print(trim(first_str))
     IF (substring((first_strlen - 1),1,first_str)=" ")
      " "
     ENDIF
     CALL print(trim(str2)),
     CALL print(trim(sec_str1))
     IF (substring((sec_strlen - 1),1,sec_str)=" ")
      " "
     ENDIF
     CALL print(trim(str2)),
     CALL print(trim(third_str)), row + 1
    ENDIF
   ELSE
    col 0, r.line, row + 1
   ENDIF
  WITH nocounter, maxrow = 1, noformfeed,
   maxcol = 150
 ;end select
 SET reply->status_data.status = "S"
END GO
