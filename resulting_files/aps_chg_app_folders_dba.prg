CREATE PROGRAM aps_chg_app_folders:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET nbr_folders = cnvtint(size(request->qual,5))
 SET old_app_folder_id = 0.0
 SET new_app_folder_id = 0.0
 SELECT INTO "nl:"
  aaf.app_folder_id
  FROM ap_app_folders aaf
  WHERE (aaf.application_number=request->application_number)
   AND (aaf.user_id=request->user_id)
  DETAIL
   old_app_folder_id = aaf.app_folder_id
  WITH nocounter
 ;end select
 IF (old_app_folder_id != 0.0)
  DELETE  FROM ap_app_folder_details aafd
   WHERE aafd.app_folder_id=old_app_folder_id
   WITH nocounter
  ;end delete
  DELETE  FROM ap_app_folders aaf
   WHERE aaf.app_folder_id=old_app_folder_id
   WITH nocounter
  ;end delete
 ENDIF
 IF (nbr_folders > 0)
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_app_folder_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
  INSERT  FROM ap_app_folders aaf
   SET aaf.app_folder_id = new_app_folder_id, aaf.application_number = request->application_number,
    aaf.user_id = request->user_id,
    aaf.updt_dt_tm = cnvtdatetime(curdate,curtime3), aaf.updt_id = reqinfo->updt_id, aaf.updt_task =
    reqinfo->updt_task,
    aaf.updt_cnt = 0, aaf.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO insert_aaf_failed
  ENDIF
  INSERT  FROM ap_app_folder_details aafd,
    (dummyt d  WITH seq = value(nbr_folders))
   SET aafd.app_folder_id = new_app_folder_id, aafd.folder_id = request->qual[d.seq].folder_id, aafd
    .access_cnt = request->qual[d.seq].access_cnt,
    aafd.updt_dt_tm = cnvtdatetime(curdate,curtime3), aafd.updt_id = reqinfo->updt_id, aafd.updt_task
     = reqinfo->updt_task,
    aafd.updt_cnt = 0, aafd.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (aafd
    WHERE 1=1)
   WITH nocounter
  ;end insert
  IF (curqual != nbr_folders)
   GO TO insert_aafd_failed
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "DUAL"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "New Sequence"
 SET failed = "T"
 GO TO exit_script
#insert_aaf_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_APP_FOLDERS"
 SET failed = "T"
 GO TO exit_script
#insert_aafd_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_APP_FOLDER_DETAILS"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
