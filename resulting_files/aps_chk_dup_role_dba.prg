CREATE PROGRAM aps_chk_dup_role:dba
 RECORD reply(
   1 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->permission_bitmap=0))
  SELECT INTO "nl:"
   afr.role_id, afr.role_name
   FROM ap_folder_role afr
   PLAN (afr
    WHERE (afr.role_name=request->role_name))
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   afr.role_id, afr.role_name
   FROM ap_folder_role afr
   PLAN (afr
    WHERE (afr.permission_bitmap=request->permission_bitmap))
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
