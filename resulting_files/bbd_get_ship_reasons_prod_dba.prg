CREATE PROGRAM bbd_get_ship_reasons_prod:dba
 RECORD reply(
   1 reasonqual[*]
     2 accept_quar_prod_id = f8
     2 accept_quar_reason_id = f8
     2 product_cd = f8
     2 active_ind = i2
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
 SET reasoncount = 0
 SELECT INTO "nl:"
  p.*
  FROM accept_quar_prod_r p
  PLAN (p
   WHERE (p.accept_quar_reason_id=request->accept_quar_reason_id)
    AND p.active_ind=1)
  DETAIL
   IF (p.accept_quar_prod_id > 0)
    reasoncount = (reasoncount+ 1), stat = alterlist(reply->reasonqual,reasoncount), reply->
    reasonqual[reasoncount].accept_quar_prod_id = p.accept_quar_prod_id,
    reply->reasonqual[reasoncount].accept_quar_reason_id = p.accept_quar_reason_id, reply->
    reasonqual[reasoncount].product_cd = p.product_cd, reply->reasonqual[reasoncount].active_ind = p
    .active_ind,
    reply->reasonqual[reasoncount].updt_cnt = p.updt_cnt
   ENDIF
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
