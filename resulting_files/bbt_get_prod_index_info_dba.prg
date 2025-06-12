CREATE PROGRAM bbt_get_prod_index_info:dba
 RECORD reply(
   1 qual[*]
     2 derivative_ind = i2
     2 product_cd = f8
     2 product_disp = c40
     2 product_cat_cd = f8
     2 product_cat_disp = c40
     2 product_class_cd = f8
     2 product_class_disp = c40
     2 autologous_ind = i2
     2 directed_ind = i2
     2 synonym_id = f8
     2 storage_temp_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  p.product_cd, product_disp = uar_get_code_display(p.product_cd), p.product_class_cd,
  product_class_disp = uar_get_code_display(p.product_class_cd), product_class_mean =
  uar_get_code_meaning(p.product_class_cd), p.product_cat_cd,
  product_cat_disp = uar_get_code_display(p.product_cat_cd), p.autologous_ind, p.directed_ind,
  p.synonym_id
  FROM product_index p
  PLAN (p
   WHERE p.active_ind=1)
  ORDER BY product_class_disp, product_disp
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   IF (product_class_mean="DERIVATIVE")
    reply->qual[count1].derivative_ind = 1
   ELSE
    reply->qual[count1].derivative_ind = 0
   ENDIF
   reply->qual[count1].product_cd = p.product_cd, reply->qual[count1].product_cat_cd = p
   .product_cat_cd, reply->qual[count1].product_class_cd = p.product_class_cd,
   reply->qual[count1].autologous_ind = p.autologous_ind, reply->qual[count1].directed_ind = p
   .directed_ind, reply->qual[count1].synonym_id = p.synonym_id,
   reply->qual[count1].storage_temp_cd = p.storage_temp_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
