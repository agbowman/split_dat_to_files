CREATE PROGRAM dcp_get_predefined_names:dba
 RECORD reply(
   1 qual_cnt = i2
   1 qual[*]
     2 predefined_prefs_id = f8
     2 predefined_type_meaning = c12
     2 name = c32
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SELECT INTO "nl:"
  pp.name
  FROM predefined_prefs pp
  WHERE pp.active_ind=1
   AND pp.name != " "
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].predefined_prefs_id = pp.predefined_prefs_id, reply->qual[count1].
   predefined_type_meaning = pp.predefined_type_meaning, reply->qual[count1].name = pp.name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,count1)
 SET reply->qual_cnt = count1
END GO
