CREATE PROGRAM afc_get_prsnl_alias:dba
 RECORD reply(
   1 prsnl_id = f8
   1 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM prsnl_alias pa,
   prsnl p
  PLAN (pa
   WHERE (pa.alias=request->alias)
    AND pa.active_ind=1)
   JOIN (p
   WHERE p.person_id=pa.person_id)
  DETAIL
   reply->prsnl_id = p.person_id, reply->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL_ALIAS"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
