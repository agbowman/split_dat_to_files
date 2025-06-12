CREATE PROGRAM cdi_get_ac_users:dba
 RECORD reply(
   1 users[*]
     2 cdi_ac_user_id = f8
     2 ac_username = vc
     2 auditing_ind = i2
     2 organization_id = f8
     2 updt_cnt = i4
     2 mill_username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_ac_user u
  WHERE u.cdi_ac_user_id != 0
  ORDER BY u.ac_username
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->users,(count+ 10))
   ENDIF
   reply->users[count].cdi_ac_user_id = u.cdi_ac_user_id, reply->users[count].ac_username = u
   .ac_username, reply->users[count].auditing_ind = u.auditing_ind,
   reply->users[count].organization_id = u.organization_id, reply->users[count].updt_cnt = u.updt_cnt,
   reply->users[count].mill_username = u.mill_username
  FOOT REPORT
   stat = alterlist(reply->users,count)
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
