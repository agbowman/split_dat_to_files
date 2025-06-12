CREATE PROGRAM atr_del_req_proc:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_delete = size(request->qual,5)
 DELETE  FROM request_processing r,
   (dummyt d  WITH seq = value(number_to_delete))
  SET r.seq = 1
  PLAN (d)
   JOIN (r
   WHERE (r.request_number=request->request_number)
    AND (r.sequence=request->qual[d.seq].sequence))
  WITH ncounter
 ;end delete
 IF (curqual=number_to_delete)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
