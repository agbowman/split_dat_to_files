CREATE PROGRAM bbt_get_pool_desc:dba
 RECORD reply(
   1 qual[*]
     2 option_id = f8
     2 description = c40
     2 active_ind = i2
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
 SET pool_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.option_id, p.description, p.new_product_cd
  FROM pool_option p
  WHERE p.option_id > 0
  HEAD REPORT
   err_cnt = 0, pool_cnt = 0
  DETAIL
   pool_cnt = (pool_cnt+ 1), stat = alterlist(reply->qual,pool_cnt), reply->qual[pool_cnt].option_id
    = p.option_id,
   reply->qual[pool_cnt].description = p.description, reply->qual[pool_cnt].active_ind = p.active_ind,
   reply->qual[pool_cnt].new_product_cd = p.new_product_cd
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "pool option"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return pooling options"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
