CREATE PROGRAM delete_favorites:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET deleted = 0
 SET favorites_to_delete = size(request->favorite_list,5)
 IF (favorites_to_delete=0
  AND (request->personnel_id=0)
  AND (request->personnel_group_id=0))
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "(Personnel ID or Personnel Gruop ID) OR Favorite_List need to be set."
  GO TO exit_script
 ELSEIF ((request->personnel_id > 0)
  AND (request->personnel_group_id > 0))
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Both Personnel ID and Prsnl_Group_Id cannot be set."
  GO TO exit_script
 ENDIF
 IF ((request->personnel_id > 0))
  IF ((request->favorite_type_cd > 0))
   DELETE  FROM messaging_favorites mf
    WHERE (mf.prsnl_id=request->personnel_id)
     AND (mf.favorite_type_cd=request->favorite_type_cd)
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM messaging_favorites mf
    WHERE (mf.prsnl_id=request->personnel_id)
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF ((request->personnel_group_id > 0))
  IF ((request->favorite_type_cd > 0))
   DELETE  FROM messaging_favorites mf
    WHERE (mf.prsnl_group_id=request->personnel_group_id)
     AND (mf.favorite_type_cd=request->favorite_type_cd)
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM messaging_favorites mf
    WHERE (mf.prsnl_group_id=request->personnel_group_id)
    WITH nocounter
   ;end delete
  ENDIF
 ELSE
  DECLARE expand_knt = i4 WITH noconstant(0)
  DELETE  FROM messaging_favorites mf
   WHERE expand(expand_knt,1,favorites_to_delete,mf.favorite_id,request->favorite_list[expand_knt].
    favorite_id)
   WITH nocounter
  ;end delete
 ENDIF
#status
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No favorites existed with criteria."
 ENDIF
 DECLARE ms_error_msg = vc WITH protect, noconstant("")
 IF (error(ms_error_msg,1) != 0)
  SET reply->status_data.subeventstatus[1].operationname = "Delete Favorites"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Run time error"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ms_error_msg
 ENDIF
#exit_script
END GO
