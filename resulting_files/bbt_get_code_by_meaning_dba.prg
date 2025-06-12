CREATE PROGRAM bbt_get_code_by_meaning:dba
 RECORD reply(
   1 replyqual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 code_set = i4
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET number_to_get = size(request->qual,5)
 DECLARE code_value = f8
 DECLARE cdf_meaning_tmp = c12
 DECLARE code_display = c60
 SET code_value = 0.0
 SET cdf_meaning = "            "
 SET count = 0
 SET stat = alterlist(reply->replyqual,number_to_get)
 FOR (x = 1 TO number_to_get)
   SET cdf_meaning = request->qual[x].cdf_meaning
   SET code_value = get_code_value(request->qual[x].code_set,cdf_meaning)
   SET code_display = uar_get_code_display(code_value)
   SET reply->replyqual[x].code_value = code_value
   SET reply->replyqual[x].cdf_meaning = cdf_meaning
   SET reply->replyqual[x].code_set = request->qual[x].code_set
   SET reply->replyqual[x].display = code_display
 ENDFOR
 IF (code_value=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
