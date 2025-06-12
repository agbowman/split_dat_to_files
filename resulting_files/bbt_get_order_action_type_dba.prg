CREATE PROGRAM bbt_get_order_action_type:dba
 RECORD reply(
   1 action_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6003
   AND c.cdf_meaning="ORDER"
  DETAIL
   reply->action_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "6003"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to retrieve action type"
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
