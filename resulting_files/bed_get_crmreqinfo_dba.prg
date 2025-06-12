CREATE PROGRAM bed_get_crmreqinfo:dba
 RECORD reply(
   1 br_client_id = f8
   1 br_user_id = f8
   1 br_user_position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET reply->br_client_id = crmreqinfo->user_organization_id
 SET reply->br_user_id = crmreqinfo->user_id
 SET reply->br_user_position_cd = crmreqinfo->user_position_cd
 SELECT INTO "ccluserdir:crmreqinfo.log"
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   "BR_CLIENT_ID: ", crmreqinfo->user_organization_id, row + 1,
   "USER ID: ", crmreqinfo->user_id, row + 1,
   "USER POSITION_CD: ", crmreqinfo->user_position_cd, row + 1
  WITH nocounter
 ;end select
#exit_program
 CALL echorecord(reply)
END GO
