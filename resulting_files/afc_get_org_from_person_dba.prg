CREATE PROGRAM afc_get_org_from_person:dba
 RECORD reply(
   1 organization[*]
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (person_id=request->person_id)
   AND (encntr_id=request->encntr_id)
  DETAIL
   stat = alterlist(reply->organization,1), reply->organization[1].organization_id = e
   .organization_id,
   CALL echo(build("organization_id: ",reply->organization[1].organization_id))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ENCOUNTER"
 ENDIF
END GO
