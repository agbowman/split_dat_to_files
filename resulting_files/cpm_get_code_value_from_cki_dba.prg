CREATE PROGRAM cpm_get_code_value_from_cki:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE index = i2 WITH noconstant(0)
 DECLARE somefailed = i2 WITH noconstant(0)
 DECLARE sometranslated = i2 WITH noconstant(0)
 DECLARE tempcv = f8
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,value(size(request->qual,5)))
 FOR (index = 1 TO value(size(request->qual,5)))
   SET tempcv = uar_get_code_by_cki(nullterm(request->qual[index].cki))
   SET reply->qual[index].code_value = tempcv
   IF (tempcv=0)
    SET somefailed = 1
   ELSE
    SET sometranslated = 1
   ENDIF
 ENDFOR
 IF (somefailed)
  IF (sometranslated)
   SET reply->status_data.status = "P"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
