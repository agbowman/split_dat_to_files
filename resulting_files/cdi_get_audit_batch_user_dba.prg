CREATE PROGRAM cdi_get_audit_batch_user:dba
 RECORD reply(
   1 batchclasses[*]
     2 cdi_ac_batchclass_id = f8
     2 batchclass_name = vc
     2 organization_id = f8
   1 users[*]
     2 cdi_ac_user_id = f8
     2 ac_username = vc
     2 organization_id = f8
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
 SET count = 0
 SELECT INTO "NL:"
  FROM cdi_ac_batchclass b
  WHERE b.cdi_ac_batchclass_id != 0
   AND b.auditing_ind > 0
  ORDER BY b.batchclass_name
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->batchclasses,(count+ 10))
   ENDIF
   reply->batchclasses[count].cdi_ac_batchclass_id = b.cdi_ac_batchclass_id, reply->batchclasses[
   count].batchclass_name = b.batchclass_name, reply->batchclasses[count].organization_id = b
   .organization_id
  FOOT REPORT
   stat = alterlist(reply->batchclasses,count)
 ;end select
 SET count = 0
 SELECT INTO "NL:"
  FROM cdi_ac_user u
  WHERE u.cdi_ac_user_id != 0
   AND u.auditing_ind > 0
  ORDER BY u.ac_username
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->users,(count+ 10))
   ENDIF
   reply->users[count].cdi_ac_user_id = u.cdi_ac_user_id, reply->users[count].ac_username = u
   .ac_username, reply->users[count].organization_id = u.organization_id
  FOOT REPORT
   stat = alterlist(reply->users,count)
 ;end select
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
