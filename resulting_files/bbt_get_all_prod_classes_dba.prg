CREATE PROGRAM bbt_get_all_prod_classes:dba
 RECORD reply(
   1 qual[10]
     2 product_class_cd = f8
     2 product_class_disp = c40
     2 product_class_desc = vc
     2 product_class_mean = c12
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
 SELECT INTO "nl:"
  FROM product_class p
  WHERE active_ind=1
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].product_class_cd = p.product_class_cd
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "read"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "product_class"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
