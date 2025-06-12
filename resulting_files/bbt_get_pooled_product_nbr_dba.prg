CREATE PROGRAM bbt_get_pooled_product_nbr:dba
 RECORD reply(
   1 product_nbr = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD recpool(
   1 syear = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET pool_option_nbr_id = 0.0
 SET pool_prefix = fillstring(10," ")
 SET pool_nbr = 0
 SET pool_nbr_leading_zeros = fillstring(5," ")
 SET len_pool_nbr = cnvtint(0)
 SET pool_nbr_zero_cnt = cnvtint(0)
 SELECT INTO "nl:"
  po.product_nbr_prefix, pp.pool_option_nbr_id, pp.year,
  pp.pool_nbr
  FROM pool_option po,
   pooled_product pp
  PLAN (po
   WHERE (po.option_id=request->option_id)
    AND po.active_ind=1)
   JOIN (pp
   WHERE pp.pool_option_id=po.option_id
    AND pp.active_ind=1)
  DETAIL
   pool_prefix = po.product_nbr_prefix, pool_option_nbr_id = pp.pool_option_nbr_id
   IF (pp.year < 10)
    recpool->syear = build("0",pp.year)
   ELSE
    recpool->syear = cnvtstring(pp.year)
   ENDIF
   pool_nbr = pp.pool_nbr
  WITH nocounter
 ;end select
 IF (pool_option_nbr_id != 0)
  SELECT INTO "nl:"
   pp.pool_option_nbr_id
   FROM pooled_product pp
   PLAN (pp
    WHERE (pp.pool_option_id=request->option_id)
     AND pp.active_ind=1
     AND pp.pool_option_nbr_id=pool_option_nbr_id)
   WITH nocounter, forupdate(pp)
  ;end select
 ENDIF
 IF (((curqual=0) OR (pool_option_nbr_id=0)) )
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get last-used pool_nbr"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_pooled_product_nbr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not get last-used pool_nbr for option_id=",request->option_id)
 ELSE
  SET pool_nbr = (pool_nbr+ 1)
  UPDATE  FROM pooled_product pp
   SET pp.pool_nbr = pool_nbr, pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pp.updt_task = reqinfo->updt_task, pp.updt_id = reqinfo->updt_id, pp.updt_applctx = reqinfo->
    updt_applctx
   WHERE pp.pool_option_nbr_id=pool_option_nbr_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "update pool_nbr"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_pooled_product_nbr"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
    "pool_nbr on pooled_product table could not be updated for option_id=",request->option_id)
  ELSE
   SET len_pool_nbr = cnvtint(size(trim(cnvtstring(pool_nbr)),1))
   SET pool_nbr_zero_cnt = cnvtint((5 - len_pool_nbr))
   SET pool_nbr_leading_zeros = fillstring(5," ")
   FOR (x = 1 TO pool_nbr_zero_cnt)
     SET pool_nbr_leading_zeros = concat(trim(pool_nbr_leading_zeros),"0")
   ENDFOR
   CALL echo(build("pool_nbr_leading_zeros:",pool_nbr_leading_zeros))
   SET reply->product_nbr = build(trim(pool_prefix),recpool->syear,trim(pool_nbr_leading_zeros),
    cnvtstring(pool_nbr))
   SET reply->status_data.status = "S"
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "update pool_nbr"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_pooled_product_nbr"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ENDIF
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build("pool_nbr:",pool_nbr))
 CALL echo(build("recPool->sYear:",recpool->syear))
 CALL echo(build("pool_prefix:",pool_prefix))
 CALL echo("      ")
 CALL echo(build("reply->product_nbr:",reply->product_nbr))
 CALL echo("      ")
 CALL echo(build("status_data->status =",reply->status_data.status))
 FOR (x = 1 TO count1)
   CALL echo(reply->status_data.subeventstatus[count1].operationname)
   CALL echo(reply->status_data.subeventstatus[count1].operationstatus)
   CALL echo(reply->status_data.subeventstatus[count1].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[count1].targetobjectvalue)
 ENDFOR
END GO
