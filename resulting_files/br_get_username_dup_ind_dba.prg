CREATE PROGRAM br_get_username_dup_ind:dba
 FREE SET reply
 RECORD reply(
   01 dup_ind = i2
   01 br_prsnl_id = f8
   01 name_full_formatted = vc
   01 name_first = vc
   01 name_last = vc
   01 email = vc
   01 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE cnvtupper(bp.username)=cnvtupper(request->username))
  DETAIL
   reply->dup_ind = 1, reply->br_prsnl_id = bp.br_prsnl_id, reply->name_full_formatted = bp
   .name_full_formatted,
   reply->name_last = bp.name_last, reply->name_first = bp.name_first, reply->email = bp.email,
   reply->active_ind = bp.active_ind
  WITH nocounter, skipbedrock = 1
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
