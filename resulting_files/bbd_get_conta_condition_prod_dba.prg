CREATE PROGRAM bbd_get_conta_condition_prod:dba
 RECORD reply(
   1 qual[*]
     2 contnr_type_prod_id = f8
     2 product_cd = f8
     2 quantity = i4
     2 updt_cnt = i4
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
 SELECT INTO "nl:"
  c.*
  FROM contnr_type_prod_r c
  WHERE (c.container_condition_id=request->container_condition_id)
   AND c.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].contnr_type_prod_id =
   c.contnr_type_prod_id,
   reply->qual[count].product_cd = c.product_cd, reply->qual[count].quantity = c.quantity, reply->
   qual[count].updt_cnt = c.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
