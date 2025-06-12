CREATE PROGRAM aps_get_app_folders:dba
 RECORD reply(
   1 qual[*]
     2 folder_id = f8
     2 access_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET folder_cnt = 0
 SELECT INTO "nl:"
  aaf.app_folder_id, aafd.access_cnt, folder_exists = decode(aaf.seq,"Y","N")
  FROM ap_app_folders aaf,
   ap_app_folder_details aafd
  PLAN (aaf
   WHERE (aaf.application_number=request->application_number)
    AND (aaf.user_id=request->user_id))
   JOIN (aafd
   WHERE aafd.app_folder_id=aaf.app_folder_id)
  ORDER BY aafd.access_cnt
  HEAD REPORT
   folder_cnt = 0
  DETAIL
   IF (folder_exists="Y")
    folder_cnt = (folder_cnt+ 1)
    IF (mod(folder_cnt,10)=1)
     stat = alterlist(reply->qual,(folder_cnt+ 9))
    ENDIF
    reply->qual[folder_cnt].folder_id = aafd.folder_id, reply->qual[folder_cnt].access_cnt = aafd
    .access_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,folder_cnt)
  WITH nocounter
 ;end select
 IF (folder_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
