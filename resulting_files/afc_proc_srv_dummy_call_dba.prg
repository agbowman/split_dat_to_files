CREATE PROGRAM afc_proc_srv_dummy_call:dba
 RECORD reply(
   1 file_name = vc
   1 page_count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[3]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
