CREATE PROGRAM dm_search_tbl_names:dba
 RECORD reply(
   1 qual[50]
     2 table_name = c30
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
 SET tbl_name = concat(request->search_string,"*")
 SELECT INTO "nl:"
  ut.table_name
  FROM user_tables ut
  WHERE table_name=patstring(tbl_name)
  ORDER BY ut.table_name
  HEAD REPORT
   count1 = 0
  HEAD ut.table_name
   count1 = (count1+ 1)
   IF (count1 > qual_cnt)
    stat = alter(reply->qual,(count1+ 10)), qual_cnt = (qual_cnt+ 10)
   ENDIF
   reply->qual[count1].table_name = ut.table_name
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
