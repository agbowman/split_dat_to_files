CREATE PROGRAM dcp_get_pip_cdf_meaning:dba
 RECORD reply(
   1 qual[*]
     2 display = vc
     2 definition = vc
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.code_set
  FROM common_data_foundation c
  WHERE (c.code_set=request->code_set)
  ORDER BY c.display
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].display = c.display, reply->qual[count1].definition = c.definition, reply->
   qual[count1].cdf_meaning = c.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
