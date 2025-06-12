CREATE PROGRAM cp_get_batch_names:dba
 RECORD reply(
   1 qual[1]
     2 charting_operations_id = f8
     2 batch_name = vc
     2 active_ind = i2
     2 logical_domain_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.charting_operations_id
  FROM charting_operations c
  WHERE c.active_ind=1
  ORDER BY c.charting_operations_id
  HEAD REPORT
   count1 = 0, batch_active_ind = 0
  HEAD c.charting_operations_id
   count1 = (count1+ 1), stat = alter(reply->qual,count1), reply->qual[count1].charting_operations_id
    = c.charting_operations_id,
   reply->qual[count1].batch_name = c.batch_name
  DETAIL
   IF (c.active_ind=1)
    batch_active_ind = 1
   ENDIF
  FOOT  c.charting_operations_id
   reply->qual[count1].active_ind = batch_active_ind, reply->qual[count1].logical_domain_id = c
   .logical_domain_id, batch_active_ind = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
