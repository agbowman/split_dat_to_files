CREATE PROGRAM bbt_get_prod_for_bill:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_disp = c40
     2 active_ind = i2
     2 product_class_cd = f8
     2 product_class_mean = c12
     2 autologous_ind = i2
     2 directed_ind = i2
     2 auto_bill_item_cd = f8
     2 auto_bill_item_disp = c40
     2 dir_bill_item_cd = f8
     2 dir_bill_item_disp = c40
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
  FROM product_index p
  HEAD REPORT
   err_cnt = 0, qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1), stat = alterlist(reply->qual,qual_cnt), reply->qual[qual_cnt].product_cd
    = p.product_cd,
   reply->qual[qual_cnt].active_ind = p.active_ind, reply->qual[qual_cnt].product_class_cd = p
   .product_class_cd, reply->qual[qual_cnt].autologous_ind = p.autologous_ind,
   reply->qual[qual_cnt].directed_ind = p.directed_ind, reply->qual[qual_cnt].auto_bill_item_cd = p
   .auto_bill_item_cd, reply->qual[qual_cnt].dir_bill_item_cd = p.dir_bill_item_cd
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product index"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return product index table"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
