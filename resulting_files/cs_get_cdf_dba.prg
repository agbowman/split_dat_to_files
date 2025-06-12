CREATE PROGRAM cs_get_cdf:dba
 RECORD reply(
   1 qual[1]
     2 cdf_meaning = c12
     2 display = c40
     2 definition = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  c.display, c.definition, c.cdf_meaning
  FROM common_data_foundation c
  WHERE (c.code_set=request->code_set)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].display = c.display, reply->qual[count1].definition = c.definition, reply->
   qual[count1].cdf_meaning = c.cdf_meaning,
   reply->qual[count1].updt_cnt = c.updt_cnt
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
