CREATE PROGRAM bed_get_res_dup_res_list:dba
 FREE SET reply
 RECORD reply(
   1 dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_resource_list s
  PLAN (s
   WHERE s.mnemonic_key=trim(cnvtupper(request->mnemonic)))
  DETAIL
   reply->dup_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
