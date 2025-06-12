CREATE PROGRAM aps_get_folder_roles:dba
 RECORD reply(
   1 folder_role_qual[*]
     2 role_id = f8
     2 role_name = c40
     2 permission_bitmap = i4
     2 updt_cnt = i4
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
 SELECT INTO mine
  afr.role_id, afr.role_name
  FROM ap_folder_role afr
  PLAN (afr
   WHERE afr.role_id != 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->folder_role_qual,(cnt+ 9))
   ENDIF
   reply->folder_role_qual[cnt].role_id = afr.role_id, reply->folder_role_qual[cnt].role_name = afr
   .role_name, reply->folder_role_qual[cnt].permission_bitmap = afr.permission_bitmap,
   reply->folder_role_qual[cnt].updt_cnt = afr.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->folder_role_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ROLE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
