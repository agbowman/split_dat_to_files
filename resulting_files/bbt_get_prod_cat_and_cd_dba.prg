CREATE PROGRAM bbt_get_prod_cat_and_cd:dba
 RECORD reply(
   1 product_cat_cd = f8
   1 product_class_cd = f8
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
  pi.*
  FROM product_index pi
  WHERE (pi.product_cd=request->product_cd)
  DETAIL
   reply->product_cat_cd = pi.product_cat_cd, reply->product_class_cd = pi.product_class_cd
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
