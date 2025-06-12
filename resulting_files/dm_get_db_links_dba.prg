CREATE PROGRAM dm_get_db_links:dba
 RECORD reply(
   1 qual[50]
     2 db_link = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET qual_cnt = 50
 SELECT INTO "nl:"
  adl.db_link
  FROM all_db_links adl
  WHERE adl.owner="PUBLIC"
  ORDER BY adl.db_link
  HEAD REPORT
   count1 = 0
  HEAD adl.db_link
   count1 = (count1+ 1)
   IF (count1 > qual_cnt)
    stat = alter(reply->qual,(count1+ 10)), qual_cnt = (qual_cnt+ 10)
   ENDIF
   reply->qual[count1].db_link = adl.db_link
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
