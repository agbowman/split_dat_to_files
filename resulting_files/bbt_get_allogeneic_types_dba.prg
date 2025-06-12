CREATE PROGRAM bbt_get_allogeneic_types:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_cd_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  pi.product_cd, pi.directed_ind, pi.autologous_ind,
  pc.red_cell_product_ind
  FROM product_index pi,
   product_category pc
  PLAN (pi
   WHERE pi.active_ind=1
    AND pi.allow_dispense_ind=1)
   JOIN (pc
   WHERE pc.active_ind=1
    AND pi.product_cat_cd=pc.product_cat_cd
    AND (pc.red_cell_product_ind=request->red_cell_product_ind))
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].product_cd = pi.product_cd
  WITH counter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
