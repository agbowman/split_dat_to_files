CREATE PROGRAM bbd_get_drawn_dt_tm:dba
 RECORD reply(
   1 drawn_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SELECT INTO "nl:"
  bp.drawn_dt_tm
  FROM blood_product bp
  WHERE (bp.product_id=request->product_id)
   AND bp.active_ind=1
  DETAIL
   reply->drawn_dt_tm = bp.drawn_dt_tm
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
