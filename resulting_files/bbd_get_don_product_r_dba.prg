CREATE PROGRAM bbd_get_don_product_r:dba
 RECORD reply(
   1 donation_product_id = f8
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dp.product_id
  FROM bbd_don_product_r dp
  PLAN (dp
   WHERE (dp.product_id=request->product_id)
    AND (dp.donation_results_id=request->donation_result_id)
    AND dp.active_ind=1)
  DETAIL
   reply->donation_product_id = dp.donation_product_id, reply->updt_cnt = dp.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
