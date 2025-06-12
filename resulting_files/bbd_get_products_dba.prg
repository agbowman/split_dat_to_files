CREATE PROGRAM bbd_get_products:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET cd_val = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1606
   AND c.cdf_meaning="BLOOD"
   AND c.active_ind=1
  DETAIL
   cd_val = c.code_value
  WITH counter
 ;end select
 SELECT INTO "nl:"
  p.product_cd, c.display
  FROM product_index p,
   code_value c
  PLAN (p
   WHERE p.product_class_cd=cd_val
    AND p.active_ind=1)
   JOIN (c
   WHERE p.product_cd=c.code_value)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].code_value = p
   .product_cd,
   reply->qual[count].display = c.display
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
