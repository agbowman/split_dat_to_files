CREATE PROGRAM cv_check_enc_access_req
 FREE RECORD cear_request
 RECORD cear_request(
   1 prsnl_id = f8
   1 encounter[*]
     2 encntr_id = f8
     2 person_id = f8
 ) WITH persistscript
 FREE RECORD cear_reply
 RECORD cear_reply(
   1 encounter[*]
     2 encntr_id = f8
     2 access_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
END GO
