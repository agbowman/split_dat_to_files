CREATE PROGRAM cs_get_csdisplay:dba
 RECORD reply(
   1 display = c40
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
 SET reply->display = " "
 SELECT INTO "nl:"
  c.display
  FROM code_value_set c
  WHERE (c.code_set=request->code_set)
  DETAIL
   reply->display = c.display
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
