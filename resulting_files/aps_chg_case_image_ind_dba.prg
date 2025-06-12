CREATE PROGRAM aps_chg_case_image_ind:dba
#script
 SET failed = "F"
 SET orig_updt_cnt = 0
 SELECT INTO "nl:"
  pc.case_id
  FROM pathology_case pc
  WHERE (pc.case_id=request->case_id)
  DETAIL
   orig_updt_cnt = pc.updt_cnt
  WITH nocounter, forupdate(pc)
 ;end select
 IF (curqual=0)
  GO TO lock_case_failed
 ENDIF
 IF ((request->updt_cnt != orig_updt_cnt))
  GO TO update_cnt_changed
 ENDIF
 UPDATE  FROM pathology_case pc
  SET pc.blob_bitmap = request->blob_bitmap, pc.dataset_uid = request->dataset_uid, pc.updt_cnt = (pc
   .updt_cnt+ 1)
  WHERE (pc.case_id=request->case_id)
   AND pc.case_id != 0
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO update_failed
 ENDIF
 GO TO exit_script
#update_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#update_cnt_changed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE_CNT_CHANGED"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#lock_case_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
