CREATE PROGRAM afc_modify_all_price:dba
 RECORD requestfromvb(
   1 price_sched_id = f8
   1 flatchange = f8
   1 percentchange = f8
   1 percent_ind = i2
   1 flat_ind = i2
 )
 SET requestfromvb->price_sched_id = request->price_sched_id
 SET requestfromvb->flatchange = request->flatchange
 SET requestfromvb->percentchange = request->percentchange
 SET requestfromvb->percent_ind = request->percent_ind
 SET requestfromvb->flat_ind = request->flat_ind
 FREE SET request
 RECORD request(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price = f8
     2 price_ind = i2
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_task = f8
 )
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 action_type = c3
     2 bill_item_id = f8
     2 price_sched_id = f8
     2 price_sched_items_id = f8
     2 price = f8
     2 charge_level_cd = f8
     2 detail_charge_ind = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET count = 0
 SELECT INTO "nl:"
  FROM price_sched_items psi
  WHERE (psi.price_sched_id=requestfromvb->price_sched_id)
   AND cnvtdatetime(curdate,curtime3) >= psi.beg_effective_dt_tm
   AND cnvtdatetime(curdate,curtime3) <= psi.end_effective_dt_tm
   AND psi.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].bill_item_id
    = psi.bill_item_id,
   billitems->qual[count].price_sched_id = psi.price_sched_id, billitems->qual[count].
   price_sched_items_id = psi.price_sched_items_id, billitems->qual[count].price = psi.price,
   billitems->qual[count].charge_level_cd = 0, billitems->qual[count].beg_effective_dt_tm = psi
   .beg_effective_dt_tm, billitems->qual[count].end_effective_dt_tm = psi.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  DETAIL
   billitems->qual[d1.seq].action_type = "UPT", billitems->qual[d1.seq].end_effective_dt_tm =
   cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  WHERE (billitems->qual[d1.seq].action_type="UPT")
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].action_type =
   "ADD",
   billitems->qual[count].bill_item_id = billitems->qual[d1.seq].bill_item_id, billitems->qual[count]
   .price_sched_id = billitems->qual[d1.seq].price_sched_id
   IF ((requestfromvb->flat_ind=1))
    billitems->qual[count].price = (billitems->qual[d1.seq].price+ requestfromvb->flatchange)
   ELSE
    billitems->qual[count].price = (billitems->qual[d1.seq].price+ (billitems->qual[d1.seq].price *
    requestfromvb->percentchange))
   ENDIF
   billitems->qual[count].charge_level_cd = billitems->qual[d1.seq].charge_level_cd, billitems->qual[
   count].detail_charge_ind = 1, billitems->qual[count].beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3),
   billitems->qual[count].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00:00")
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SET countp = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  DETAIL
   countp = (countp+ 1), stat = alterlist(request->price_sched_items,countp), request->
   price_sched_items[countp].action_type = billitems->qual[d1.seq].action_type,
   request->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id, request->
   price_sched_items[countp].price_sched_id = billitems->qual[d1.seq].price_sched_id, request->
   price_sched_items[countp].percent_revenue = 0
   IF ((billitems->qual[d1.seq].action_type="UPT"))
    request->price_sched_items[countp].price_sched_items_id = billitems->qual[d1.seq].
    price_sched_items_id
   ENDIF
   request->price_sched_items[countp].price = billitems->qual[d1.seq].price, request->
   price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd, request->
   price_sched_items[countp].detail_charge_ind = billitems->qual[d1.seq].detail_charge_ind,
   request->price_sched_items[countp].detail_charge_ind_ind = 1, request->price_sched_items[countp].
   active_ind = 1, request->price_sched_items[countp].beg_effective_dt_tm = billitems->qual[d1.seq].
   beg_effective_dt_tm,
   request->price_sched_items[countp].end_effective_dt_tm = billitems->qual[d1.seq].
   end_effective_dt_tm
  WITH nocounter
 ;end select
 SET request->price_sched_items_qual = countp
 EXECUTE afc_ens_price_sched_item
 COMMIT
END GO
