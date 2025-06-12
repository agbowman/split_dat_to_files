CREATE PROGRAM bbt_get_product_type:dba
 RECORD reply(
   1 qual[10]
     2 product_cd = f8
     2 product_display = c40
     2 derivative_ind = i2
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
  pr.product_cd, p.product_class_cd, c.display,
  c2.cdf_meaning
  FROM product_category p,
   (dummyt d1  WITH seq = 1),
   code_value c2,
   (dummyt d2  WITH seq = 1),
   product_index pr,
   (dummyt d3  WITH seq = 1),
   code_value c
  PLAN (c
   WHERE c.code_set=1604
    AND c.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr
   WHERE c.code_value=pr.product_cd)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (p
   WHERE p.product_class_cd=pr.product_class_cd
    AND p.product_cat_cd=pr.product_cat_cd
    AND p.valid_aborh_compat_ind=1)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (c2
   WHERE c2.code_set=1606
    AND c2.code_value=pr.product_class_cd)
  ORDER BY c.display_key
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].product_cd = pr.product_cd, reply->qual[count1].product_display = c.display
   IF (c2.cdf_meaning="DERIVATIVE")
    reply->qual[count1].derivative_ind = 1
   ELSE
    reply->qual[count1].derivative_ind = 0
   ENDIF
  WITH counter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
