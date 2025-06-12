CREATE PROGRAM cpm_get_code_sets:dba
 RECORD reply(
   1 codeset[500]
     2 code_set = i4
     2 display = c40
     2 description = c60
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
 SELECT INTO "nl:"
  c.code_set, c.display, c.description
  FROM code_value_set c
  WHERE c.code_set > 0
  ORDER BY c.code_set
  HEAD REPORT
   count1 = 0
  HEAD c.code_set
   count1 = (count1+ 1)
   IF (count1 > 500)
    IF (mod(count1,50)=1)
     stat = alter(reply->codeset,(count1+ 50))
    ENDIF
   ENDIF
   reply->codeset[count1].code_set = c.code_set, reply->codeset[count1].display = c.display, reply->
   codeset[count1].description = c.description
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->codeset,count1)
END GO
