CREATE PROGRAM cv_get_fld_dataset:dba
 RECORD reply(
   1 dataset_rec_cnt = i2
   1 dataset_rec[*]
     2 display_name = vc
     2 dataset_internal_name = vc
     2 dataset_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET dataset_size = size(reply->dataset_rec,5)
 SET active_ind = 0
 SET active_cd = 0
 SET event_cd = 0
 SET count = 0
 SET dataset_id = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET dataset_rec_cnt = 0
 SELECT INTO "nl:"
  d.dataset_id, d.display_name, d.dataset_internal_name,
  d.active_ind
  FROM cv_dataset d,
   (dummyt t  WITH seq = value(size(reply->dataset_rec,5)))
  PLAN (t)
   JOIN (d
   WHERE d.dataset_id > 0)
  HEAD REPORT
   dataset_rec_cnt = 0, arr = alterlist(reply->dataset_rec,10)
  DETAIL
   dataset_rec_cnt = (dataset_rec_cnt+ 1)
   IF (mod(dataset_rec_cnt,10)=1
    AND dataset_rec_cnt != 1)
    arr_size = alterlist(reply->dataset_rec,(dataset_rec_cnt+ 10))
   ENDIF
   reply->dataset_rec[dataset_rec_cnt].display_name = d.display_name, reply->dataset_rec[
   dataset_rec_cnt].dataset_internal_name = d.dataset_internal_name, reply->dataset_rec[
   dataset_rec_cnt].dataset_id = d.dataset_id,
   reply->dataset_rec[dataset_rec_cnt].active_ind = d.active_ind
  WITH nocounter
 ;end select
 SET arr = alterlist(reply->dataset_rec,dataset_rec_cnt)
 SET reply->dataset_rec_cnt = dataset_rec_cnt
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "get_dataset"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_fld_dataset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_datasetNAME"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
