CREATE PROGRAM bed_get_psn_orglist
 FREE SET reply
 RECORD reply(
   1 orgs[*]
     2 id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET numrows = size(request->facilities,5)
 IF (numrows=0)
  SET error_flag = "Y"
  SET reply->error_msg = "No facilities passed"
 ENDIF
 SET stat = alterlist(reply->orgs,numrows)
 SELECT INTO "NL:"
  FROM location l,
   (dummyt d  WITH seq = numrows)
  PLAN (d)
   JOIN (l
   WHERE (l.location_cd=request->facilities[d.seq].code_value))
  DETAIL
   reply->orgs[d.seq].id = l.organization_id
  WITH nocounter
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
