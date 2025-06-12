CREATE PROGRAM aps_chk_dup_folder:dba
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
 SET cnt = 0
 IF ((request->parent_folder_id=0.0))
  SELECT INTO "nl:"
   af.folder_id, af.folder_name
   FROM ap_folder af
   PLAN (af
    WHERE af.folder_id=af.parent_folder_id
     AND af.folder_name_key=cnvtupper(request->folder_name)
     AND (af.public_ind=request->public_ind)
     AND (((request->public_ind=1)) OR ((af.create_prsnl_id=request->create_prsnl_id))) )
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   af.folder_id, af.folder_name
   FROM ap_folder af
   PLAN (af
    WHERE (af.parent_folder_id=request->parent_folder_id)
     AND af.folder_name_key=cnvtupper(request->folder_name)
     AND af.folder_id != af.parent_folder_id)
   DETAIL
    reply->duplicate_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
