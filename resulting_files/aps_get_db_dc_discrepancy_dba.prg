CREATE PROGRAM aps_get_db_dc_discrepancy:dba
 RECORD reply(
   1 qual[*]
     2 discrepancy_term_id = f8
     2 display = vc
     2 description = vc
     2 discrepancy_cd = f8
     2 discrepancy_disp = vc
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
  addt.active_ind
  FROM ap_dc_discrepancy_term addt
  WHERE addt.discrepancy_term_id > 0
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(reply->qual,x), reply->qual[x].discrepancy_term_id = addt
   .discrepancy_term_id,
   reply->qual[x].display = addt.display, reply->qual[x].description = addt.description, reply->qual[
   x].discrepancy_cd = addt.discrepancy_cd,
   reply->qual[x].active_ind = addt.active_ind, reply->qual[x].updt_cnt = addt.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "AP_DC_DISCREPANCY_TERM"
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
