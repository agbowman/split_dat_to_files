CREATE PROGRAM cv_del_fld_response:dba
 SET cv_trns_add = 1
 SET cv_trns_chg = 2
 SET cv_trns_del = 3
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET record_exists = "F"
 SET reply->status_data.status = "F"
 DELETE  FROM cv_response resp,
   (dummyt t  WITH seq = value(size(request->response_rec,5)))
  SET resp.seq = 1
  PLAN (t)
   JOIN (resp
   WHERE (resp.response_id=request->response_rec[d.seq].response_id))
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->active_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->active_ind = 0
 ENDIF
END GO
