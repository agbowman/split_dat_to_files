CREATE PROGRAM bbt_get_prod_by_barcode:dba
 RECORD reply(
   1 product_cd = f8
   1 product_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.product_cd
  FROM product_barcode p
  WHERE (p.product_barcode=request->product_barcode)
   AND p.active_ind=1
  DETAIL
   reply->product_cd = p.product_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product_barcode"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to find product for barcode specified"
  SET reply->status_data.status = "Z"
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
