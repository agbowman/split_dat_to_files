CREATE PROGRAM bb_act_unlock_products:dba
 RECORD reply(
   1 products[*]
     2 product_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD lockstatus(
   1 statuslist[*]
     2 status = i4
 )
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET product_cnt = size(request->products,5)
 SET stat = alterlist(lockstatus->statuslist,product_cnt)
 IF (product_cnt > 0)
  UPDATE  FROM product p,
    (dummyt d  WITH seq = value(product_cnt))
   SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (p
    WHERE (p.product_id=request->products[d.seq].product_id)
     AND (p.updt_cnt=request->products[d.seq].updt_cnt)
     AND p.locked_ind=1)
   WITH nocounter, status(lockstatus->statuslist[d.seq].status)
  ;end update
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_unlock_products.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Update into product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   *
   FROM (dummyt d  WITH seq = value(size(lockstatus->statuslist,5)))
   PLAN (d
    WHERE (lockstatus->statuslist[d.seq].status=0))
   HEAD REPORT
    prod_cnt = 0
   DETAIL
    prod_cnt += 1, stat = alterlist(reply->products,(prod_cnt+ 1)), reply->products[prod_cnt].
    product_id = request->products[d.seq].product_id
   FOOT REPORT
    stat = alterlist(reply->products,prod_cnt)
   WITH nocounter
  ;end select
  SET serror_check = error(serrormsg,0)
  IF (serror_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bb_act_lock_products.prg"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "select from product"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status != "F"))
  SET reqinfo->commit_ind = 1
  IF (size(request->products,5)=size(reply->products,5))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
