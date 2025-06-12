CREATE PROGRAM bbt_get_modify_prod:dba
 RECORD reply(
   1 qual[*]
     2 new_product_cd = f8
     2 new_product_disp = c40
     2 new_product_desc = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET prod_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  m.active_ind, p.active_ind, p.new_product_cd
  FROM modify_option m,
   new_product p
  WHERE m.option_id=p.option_id
   AND m.active_ind=1
   AND p.active_ind=1
  HEAD REPORT
   err_cnt = 0, prod_cnt = 0
  DETAIL
   prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->qual,prod_cnt), reply->qual[prod_cnt].
   new_product_cd = p.new_product_cd
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "MODIFY_OPTION AND NEW_PRODUCT"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return modify products"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
