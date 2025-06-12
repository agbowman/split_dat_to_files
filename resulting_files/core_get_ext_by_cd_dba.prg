CREATE PROGRAM core_get_ext_by_cd:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = vc
     2 field_type = i4
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET list_cnt = size(request->qual,5)
 SET count1 = 0
 SET max_ext = 1
 DECLARE num = i4
 SELECT INTO "nl:"
  e.code_value
  FROM code_value_extension e
  WHERE expand(num,1,size(request->qual,5),e.code_value,request->qual[num].code_value)
   AND e.field_name > " "
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].code_value = e.code_value, reply->qual[count1].field_name = e.field_name,
   reply->qual[count1].field_type = e.field_type,
   reply->qual[count1].field_value = e.field_value
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
