CREATE PROGRAM bbd_get_valid_bag_type:dba
 RECORD reply(
   1 bag_type_cd = f8
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
 SET reply->bag_type_cd = 0.0
 SELECT INTO "nl:"
  r.bag_type_cd
  FROM bbd_donation_results r,
   bbd_don_product_r p
  PLAN (p
   WHERE (p.product_id=request->product_id)
    AND p.active_ind=1)
   JOIN (r
   WHERE r.donation_result_id=p.donation_results_id
    AND r.active_ind=1)
  HEAD REPORT
   reply->bag_type_cd = r.bag_type_cd
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
