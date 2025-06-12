CREATE PROGRAM bbt_get_auto_dir_types:dba
 RECORD reply(
   1 qual[10]
     2 product_cd = f8
     2 product_cd_disp = c40
     2 red_cell_product_ind = i2
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
 SET hold_code_value = 0.0
 SELECT INTO "nl:"
  pi.product_cd, pi.directed_ind, pi.autologous_ind,
  pc.red_cell_product_ind
  FROM product_index pi,
   product_category pc
  PLAN (pi
   WHERE pi.active_ind=1
    AND ((pi.directed_ind=1) OR (pi.autologous_ind=1)) )
   JOIN (pc
   WHERE pc.active_ind=1
    AND pi.product_cat_cd=pc.product_cat_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].product_cd = pi.product_cd, reply->qual[count1].red_cell_product_ind = pc
   .red_cell_product_ind
  WITH counter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
