CREATE PROGRAM afc_get_bill_code_scheds:dba
 RECORD reply(
   1 bill_code_qual = i2
   1 bill_qual[*]
     2 code_value = f8
     2 cdf_meaning = vc
     2 description = vc
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET bill_code_type_code_set = 14002
 SET stat = alterlist(reply->bill_qual,(count1+ 10))
 SELECT INTO "nl:"
  *
  FROM code_value cv
  WHERE cv.code_set=bill_code_type_code_set
   AND cdf_meaning != "CHARGE POINT"
   AND active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->bill_qual,(count1+ 10))
   ENDIF
   reply->bill_qual[count1].code_value = cv.code_value, reply->bill_qual[count1].cdf_meaning = cv
   .cdf_meaning, reply->bill_qual[count1].description = cv.description,
   reply->bill_qual[count1].display = cv.display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->bill_qual,count1)
 SET reply->bill_code_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
