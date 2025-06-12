CREATE PROGRAM bbd_get_ship_assays_prod:dba
 RECORD reply(
   1 assayqual[*]
     2 accept_pos_prod_id = f8
     2 accept_pos_test_id = f8
     2 product_cd = f8
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
 SET reply->status_data.status = "F"
 SET assaycount = 0
 SELECT INTO "nl:"
  p.*
  FROM accept_pos_prod_r p
  PLAN (p
   WHERE (p.accept_pos_test_id=request->accept_pos_test_id)
    AND p.active_ind=1)
  DETAIL
   IF (p.accept_pos_prod_id > 0)
    assaycount = (assaycount+ 1), stat = alterlist(reply->assayqual,assaycount), reply->assayqual[
    assaycount].accept_pos_prod_id = p.accept_pos_prod_id,
    reply->assayqual[assaycount].accept_pos_test_id = p.accept_pos_test_id, reply->assayqual[
    assaycount].product_cd = p.product_cd, reply->assayqual[assaycount].active_ind = p.active_ind,
    reply->assayqual[assaycount].updt_cnt = p.updt_cnt
   ENDIF
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
