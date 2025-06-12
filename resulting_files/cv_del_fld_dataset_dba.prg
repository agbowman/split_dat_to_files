CREATE PROGRAM cv_del_fld_dataset:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 DELETE  FROM cv_xref ref
  WHERE (ref.dataset_id=request->dataset_rec.dataset_id)
   AND ref.active_ind=1
  WITH nocounter
 ;end delete
 DELETE  FROM cv_dataset data
  WHERE (data.dataset_id=request->dataset_rec.dataset_id)
   AND data.active_ind=1
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "del_dataset"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "cv_del_dataset"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_dataset"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
