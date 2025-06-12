CREATE PROGRAM afc_upt_price_for_bill_item:dba
 SET afc_upt_price_for_bill_item = "004"
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD upt_price_sched(
   1 bill_items[*]
     2 bill_item_id = f8
     2 cost_basis_amt = f8
     2 tax = f8
     2 tax_applied_ind = i2
     2 price = f8
     2 price_sched_items_id = f8
     2 cost_adj_amt = f8
 )
 DECLARE lcount = i4 WITH noconstant(0)
 DECLARE lcount2 = i4 WITH noconstant(0)
 DECLARE mdpercentage = f8 WITH noconstant(0.0)
 DECLARE failure = i2 WITH constant(0)
 DECLARE success = i2 WITH constant(1)
 DECLARE update_cnt_err = i2 WITH constant(2)
 DECLARE gen_nbr_err = i2 WITH constant(3)
 DECLARE insert_err = i2 WITH constant(4)
 DECLARE update_err = i2 WITH constant(5)
 DECLARE inactivate_err = i2 WITH constant(6)
 DECLARE lock_err = i2 WITH constant(7)
 DECLARE zero_recs = i2 WITH constant(8)
 DECLARE updatepricesched(_null) = i2
 DECLARE updatebillitem(_null) = i2
 DECLARE calculateprice(dtax=f8,dmarkup=f8,dcostbasis=f8) = f8
 DECLARE calculatetax(dpercent=f8,dcostbasis=f8) = f8
 SET reply->status_data.status = "F"
 SET mdpercentage = (request->tax_percent * 0.01)
 IF ((request->tax_upt_ind=1))
  SELECT INTO "nl:"
   FROM bill_item bi,
    price_sched_items psi,
    price_sched ps
   PLAN (bi
    WHERE bi.tax_ind > 0
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND bi.active_ind=1)
    JOIN (psi
    WHERE psi.bill_item_id=bi.bill_item_id
     AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1)
   ORDER BY psi.bill_item_id
   DETAIL
    lcount = (lcount+ 1), stat = alterlist(upt_price_sched->bill_items,lcount), upt_price_sched->
    bill_items[lcount].bill_item_id = bi.bill_item_id,
    upt_price_sched->bill_items[lcount].cost_basis_amt = bi.cost_basis_amt, upt_price_sched->
    bill_items[lcount].tax_applied_ind = 1, upt_price_sched->bill_items[lcount].price_sched_items_id
     = psi.price_sched_items_id,
    upt_price_sched->bill_items[lcount].tax = round(psi.tax,2), upt_price_sched->bill_items[lcount].
    price = psi.price, upt_price_sched->bill_items[lcount].cost_adj_amt = psi.cost_adj_amt
   WITH nocounter
  ;end select
  IF (size(request->bill_items,5) > 0)
   IF (size(upt_price_sched->bill_items,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(request->bill_items,5))),
      (dummyt d2  WITH seq = value(size(upt_price_sched->bill_items,5)))
     PLAN (d1)
      JOIN (d2
      WHERE (upt_price_sched->bill_items[d2.seq].bill_item_id=request->bill_items[d1.seq].
      bill_item_id))
     DETAIL
      CALL echo("updating old information"), upt_price_sched->bill_items[d2.seq].tax_applied_ind =
      request->bill_items[d1.seq].tax_applied_ind, request->bill_items[d1.seq].found_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(request->bill_items,5))),
     bill_item bi,
     price_sched_items psi,
     price_sched ps
    PLAN (d1
     WHERE (request->bill_items[d1.seq].found_ind=0))
     JOIN (bi
     WHERE (bi.bill_item_id=request->bill_items[d1.seq].bill_item_id)
      AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND bi.active_ind=1)
     JOIN (psi
     WHERE psi.bill_item_id=bi.bill_item_id
      AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND psi.active_ind=1)
     JOIN (ps
     WHERE ps.price_sched_id=psi.price_sched_id
      AND ps.active_ind=1)
    DETAIL
     CALL echo("found new information"), lcount = (lcount+ 1), stat = alterlist(upt_price_sched->
      bill_items,lcount),
     upt_price_sched->bill_items[lcount].bill_item_id = bi.bill_item_id, upt_price_sched->bill_items[
     lcount].cost_basis_amt = bi.cost_basis_amt, upt_price_sched->bill_items[lcount].tax_applied_ind
      = request->bill_items[d1.seq].tax_applied_ind,
     upt_price_sched->bill_items[lcount].tax = round(psi.tax,2), upt_price_sched->bill_items[lcount].
     price = psi.price, upt_price_sched->bill_items[lcount].price_sched_items_id = psi
     .price_sched_items_id,
     upt_price_sched->bill_items[lcount].cost_adj_amt = psi.cost_adj_amt
    WITH nocounter
   ;end select
  ENDIF
  FOR (lcount = 1 TO size(upt_price_sched->bill_items,5))
   IF ((upt_price_sched->bill_items[lcount].tax_applied_ind=1))
    SET upt_price_sched->bill_items[lcount].tax = calculatetax(mdpercentage,upt_price_sched->
     bill_items[lcount].cost_basis_amt)
   ELSE
    SET upt_price_sched->bill_items[lcount].tax = 0
   ENDIF
   SET upt_price_sched->bill_items[lcount].price = calculateprice(upt_price_sched->bill_items[lcount]
    .tax,upt_price_sched->bill_items[lcount].cost_adj_amt,upt_price_sched->bill_items[lcount].
    cost_basis_amt)
  ENDFOR
  CALL echorecord(upt_price_sched)
  SET nstat = updatepricesched(null)
  IF (nstat != success)
   SET reqinfo->commit_ind = false
   GO TO exit_script
  ENDIF
  SET nstat = updatebillitem(null)
  IF (nstat != success)
   SET reqinfo->commit_ind = false
   GO TO exit_script
  ENDIF
 ELSEIF ((request->tax_upt_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(request->bill_items,5))),
    bill_item bi,
    price_sched_items psi,
    price_sched ps
   PLAN (d1)
    JOIN (bi
    WHERE (bi.bill_item_id=request->bill_items[d1.seq].bill_item_id)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND bi.active_ind=1)
    JOIN (psi
    WHERE psi.bill_item_id=bi.bill_item_id
     AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND psi.active_ind=1)
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1)
   DETAIL
    lcount = (lcount+ 1), stat = alterlist(upt_price_sched->bill_items,lcount), upt_price_sched->
    bill_items[lcount].bill_item_id = bi.bill_item_id,
    upt_price_sched->bill_items[lcount].cost_basis_amt = bi.cost_basis_amt, upt_price_sched->
    bill_items[lcount].tax_applied_ind = request->bill_items[d1.seq].tax_applied_ind, upt_price_sched
    ->bill_items[lcount].tax = round(psi.tax,2),
    upt_price_sched->bill_items[lcount].price = psi.price, upt_price_sched->bill_items[lcount].
    price_sched_items_id = psi.price_sched_items_id, upt_price_sched->bill_items[lcount].cost_adj_amt
     = psi.cost_adj_amt
   WITH nocounter
  ;end select
  FOR (lcount = 1 TO size(upt_price_sched->bill_items,5))
   IF ((upt_price_sched->bill_items[lcount].tax_applied_ind=1))
    SET upt_price_sched->bill_items[lcount].tax = calculatetax(mdpercentage,upt_price_sched->
     bill_items[lcount].cost_basis_amt)
   ELSE
    SET upt_price_sched->bill_items[lcount].tax = 0
   ENDIF
   SET upt_price_sched->bill_items[lcount].price = calculateprice(upt_price_sched->bill_items[lcount]
    .tax,upt_price_sched->bill_items[lcount].cost_adj_amt,upt_price_sched->bill_items[lcount].
    cost_basis_amt)
  ENDFOR
  CALL echorecord(upt_price_sched)
  SET nstat = updatepricesched(null)
  IF (nstat != success)
   SET reqinfo->commit_ind = false
   GO TO exit_script
  ENDIF
  SET nstat = updatebillitem(null)
  IF (nstat != success)
   SET reqinfo->commit_ind = false
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(request->bill_items,5))),
    bill_item bi,
    price_sched_items psi,
    price_sched ps
   PLAN (d1)
    JOIN (bi
    WHERE (bi.bill_item_id=request->bill_items[d1.seq].bill_item_id)
     AND bi.tax_ind=1
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND bi.active_ind=1)
    JOIN (psi
    WHERE psi.bill_item_id=bi.bill_item_id
     AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND psi.active_ind=1)
    JOIN (ps
    WHERE ps.price_sched_id=psi.price_sched_id
     AND ps.active_ind=1)
   DETAIL
    lcount = (lcount+ 1), stat = alterlist(upt_price_sched->bill_items,lcount), upt_price_sched->
    bill_items[lcount].bill_item_id = bi.bill_item_id,
    upt_price_sched->bill_items[lcount].cost_basis_amt = bi.cost_basis_amt, upt_price_sched->
    bill_items[lcount].tax_applied_ind = request->bill_items[d1.seq].tax_applied_ind, upt_price_sched
    ->bill_items[lcount].price = psi.price,
    upt_price_sched->bill_items[lcount].price_sched_items_id = psi.price_sched_items_id,
    upt_price_sched->bill_items[lcount].cost_adj_amt = psi.cost_adj_amt
   WITH nocounter
  ;end select
  IF (curqual > 0)
   FOR (lcount = 1 TO size(upt_price_sched->bill_items,5))
    SET upt_price_sched->bill_items[lcount].tax = 0
    SET upt_price_sched->bill_items[lcount].price = calculateprice(upt_price_sched->bill_items[lcount
     ].tax,upt_price_sched->bill_items[lcount].cost_adj_amt,upt_price_sched->bill_items[lcount].
     cost_basis_amt)
   ENDFOR
   SET nstat = updatepricesched(null)
   IF (nstat != success)
    SET reqinfo->commit_ind = false
    GO TO exit_script
   ENDIF
   SET nstat = updatebillitem(null)
   IF (nstat != success)
    SET reqinfo->commit_ind = false
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE calculatetax(dpercent,dcostbasis)
   DECLARE dtax = f8
   CALL echo("in Calculate tax")
   SET dtax = 0.0
   CALL echo(build("percent:",dpercent))
   SET dtax = (dpercent * dcostbasis)
   SET dtax = round(dtax,2)
   CALL echo(build("Tax:",dtax))
   RETURN(dtax)
 END ;Subroutine
 SUBROUTINE calculateprice(dtax,dmarkup,dcostbasis)
   DECLARE dprice = f8
   SET dprice = 0.0
   SET dprice = ((dtax+ dmarkup)+ dcostbasis)
   SET dprice = round(dprice,2)
   RETURN(dprice)
 END ;Subroutine
 SUBROUTINE updatepricesched(null)
   SELECT INTO "nl:"
    FROM price_sched_items psi,
     (dummyt d1  WITH seq = value(size(upt_price_sched->bill_items,5)))
    PLAN (d1)
     JOIN (psi
     WHERE (psi.price_sched_items_id=upt_price_sched->bill_items[d1.seq].price_sched_items_id))
    WITH forupdate(br)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    RETURN(lock_err)
   ENDIF
   UPDATE  FROM price_sched_items psi,
     (dummyt d1  WITH seq = value(size(upt_price_sched->bill_items,5)))
    SET psi.price = upt_price_sched->bill_items[d1.seq].price, psi.cost_adj_amt = upt_price_sched->
     bill_items[d1.seq].cost_adj_amt, psi.tax = upt_price_sched->bill_items[d1.seq].tax,
     psi.updt_cnt = (psi.updt_cnt+ 1), psi.updt_dt_tm = cnvtdatetime(curdate,curtime3), psi.updt_id
      = reqinfo->updt_id,
     psi.updt_applctx = reqinfo->updt_applctx, psi.updt_task = reqinfo->updt_task
    PLAN (d1)
     JOIN (psi
     WHERE (psi.price_sched_items_id=upt_price_sched->bill_items[d1.seq].price_sched_items_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    RETURN(update_err)
   ENDIF
   SET reqinfo->commit_ind = true
   RETURN(success)
 END ;Subroutine
 SUBROUTINE updatebillitem(null)
   SELECT INTO "nl:"
    FROM bill_item bi,
     (dummyt d1  WITH seq = value(size(upt_price_sched->bill_items,5)))
    PLAN (d1)
     JOIN (bi
     WHERE (bi.bill_item_id=upt_price_sched->bill_items[d1.seq].bill_item_id))
    WITH forupdate(br)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    RETURN(lock_err)
   ENDIF
   UPDATE  FROM bill_item bi,
     (dummyt d1  WITH seq = value(size(upt_price_sched->bill_items,5)))
    SET bi.tax_ind = upt_price_sched->bill_items[d1.seq].tax_applied_ind, bi.updt_cnt = (bi.updt_cnt
     + 1), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bi.updt_id = reqinfo->updt_id, bi.updt_applctx = reqinfo->updt_applctx, bi.updt_task = reqinfo->
     updt_task
    PLAN (d1)
     JOIN (bi
     WHERE (bi.bill_item_id=upt_price_sched->bill_items[d1.seq].bill_item_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    RETURN(update_err)
   ENDIF
   SET reqinfo->commit_ind = true
   RETURN(success)
 END ;Subroutine
#exit_script
END GO
