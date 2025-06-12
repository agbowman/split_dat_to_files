CREATE PROGRAM aps_get_db_dc_dis_agree:dba
 RECORD reply(
   1 qual[*]
     2 evaluation_term_id = f8
     2 display = vc
     2 description = vc
     2 agreement_cd = f8
     2 agreement_disp = vc
     2 discrepancy_req_ind = i2
     2 reason_req_ind = i2
     2 investigation_req_ind = i2
     2 resolution_req_ind = i2
     2 active_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 SELECT INTO "nl:"
  adet.active_ind
  FROM ap_dc_evaluation_term adet
  WHERE adet.evaluation_term_id > 0
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(reply->qual,x), reply->qual[x].evaluation_term_id = adet
   .evaluation_term_id,
   reply->qual[x].display = adet.display, reply->qual[x].description = adet.description, reply->qual[
   x].agreement_cd = adet.agreement_cd,
   reply->qual[x].discrepancy_req_ind = adet.discrepancy_req_ind, reply->qual[x].reason_req_ind =
   adet.reason_req_ind, reply->qual[x].investigation_req_ind = adet.investigation_req_ind,
   reply->qual[x].resolution_req_ind = adet.resolution_req_ind, reply->qual[x].active_ind = adet
   .active_ind, reply->qual[x].updt_cnt = adet.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "AP_DC_EVALUATION_TERM"
 ENDIF
#exit_script
 IF (failed="F")
  IF (value(size(reply->qual,5))=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
