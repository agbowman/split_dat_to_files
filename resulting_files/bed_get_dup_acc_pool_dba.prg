CREATE PROGRAM bed_get_dup_acc_pool:dba
 FREE SET reply
 RECORD reply(
   1 accession_assignment_pool_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->accession_assignment_pool_id = 0.0
 SELECT INTO "nl:"
  FROM accession_assign_pool a
  WHERE trim(cnvtupper(a.description))=trim(cnvtupper(request->accession_pool_description))
  DETAIL
   reply->accession_assignment_pool_id = a.accession_assignment_pool_id
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
