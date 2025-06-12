CREATE PROGRAM afc_add_price:dba
 CALL echorecord(request,"ccluserdir:price_req.dat")
 RECORD requestfromvb(
   1 report_flg = i2
   1 ext_owner_code = f8
   1 from_price_sched_id = f8
   1 to_price_sched_id = f8
   1 level_ind = i2
   1 flatchange = f8
   1 percentchange = f8
   1 percent_ind = i2
   1 flat_ind = i2
   1 setzero_ind = i2
   1 units_ind_ind = i2
   1 beg_effective_dt_tm = dq8
   1 beg_effective_dt_tm2 = dq8
   1 end_effective_dt_tm = dq8
   1 end_effective_dt_tm2 = dq8
   1 roundingdirection_ind = i2
   1 roundingamount_ind = i2
   1 stats_only_ind_ind = i2
 )
 SET requestfromvb->ext_owner_code = request->ext_owner_code
 SET requestfromvb->from_price_sched_id = request->from_price_sched_id
 SET requestfromvb->to_price_sched_id = request->to_price_sched_id
 SET requestfromvb->level_ind = request->level_ind
 SET requestfromvb->flatchange = request->flatchange
 SET requestfromvb->percentchange = (request->percentchange/ 100)
 SET requestfromvb->percent_ind = request->percent_ind
 SET requestfromvb->flat_ind = request->flat_ind
 SET requestfromvb->setzero_ind = request->setzero_ind
 SET requestfromvb->units_ind_ind = 1
 SET requestfromvb->beg_effective_dt_tm = request->beg_effective_dt_tm
 SET requestfromvb->end_effective_dt_tm = request->end_effective_dt_tm
 SET requestfromvb->beg_effective_dt_tm2 = request->beg_effective_dt_tm2
 SET requestfromvb->end_effective_dt_tm2 = request->end_effective_dt_tm2
 SET newenddate = datetimeadd(requestfromvb->beg_effective_dt_tm2,- (1))
 SET requestfromvb->report_flg = request->report_flg
 SET requestfromvb->roundingdirection_ind = request->roundingdirection_ind
 SET requestfromvb->roundingamount_ind = request->roundingamount_ind
 SET requestfromvb->stats_only_ind_ind = 1
 SET hold_amount = 0.0
 FREE SET request
 RECORD request(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 ext_description = c100
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
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind = i2
     2 stats_only_ind_ind = i2
 )
 RECORD enspsirequest(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = vc
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
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
     2 end_effective_dt_tm_ind = i2
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind = i2
     2 stats_only_ind_ind = i2
 )
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 action_type = c3
     2 bill_item_id = f8
     2 ext_description = c100
     2 price_sched_id = f8
     2 price_sched_items_id = f8
     2 price = f8
     2 charge_level_cd = f8
     2 detail_charge_ind = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_ind = i2
     2 units_ind = i2
     2 stats_only_ind = i2
 )
 SET countp = 0
 SET countb = 0
 SELECT
  IF ((requestfromvb->level_ind=1))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_code)
    AND b.ext_parent_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=2))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_code)
    AND b.ext_child_reference_id=0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=3))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_code)
    AND b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1
  ELSEIF ((requestfromvb->level_ind=4))INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_owner_cd=requestfromvb->ext_owner_code)
    AND b.ext_parent_reference_id=0
    AND b.ext_parent_contributor_cd=0
    AND b.active_ind=1
  ELSE
  ENDIF
  DETAIL
   countb = (countb+ 1), stat = alterlist(billitems->qual,countb), billitems->qual[countb].
   bill_item_id = b.bill_item_id,
   billitems->qual[countb].ext_description = b.ext_description
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = countb
 CALL echo(build("Bill Items Qual is: ",billitems->bill_item_qual))
 IF ((requestfromvb->flat_ind=1))
  SELECT INTO "nl:"
   psi.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    price_sched_items psi
   PLAN (d1)
    JOIN (psi
    WHERE psi.beg_effective_dt_tm <= cnvtdatetime(requestfromvb->beg_effective_dt_tm)
     AND psi.end_effective_dt_tm >= cnvtdatetime(requestfromvb->end_effective_dt_tm2)
     AND (psi.price_sched_id=requestfromvb->to_price_sched_id)
     AND psi.active_ind=1
     AND (psi.bill_item_id=billitems->qual[d1.seq].bill_item_id))
   DETAIL
    CALL echo(psi.price_sched_items_id), billitems->qual[d1.seq].bill_item_id = psi.bill_item_id,
    billitems->qual[d1.seq].price_sched_id = psi.price_sched_id,
    billitems->qual[d1.seq].price_sched_items_id = psi.price_sched_items_id, billitems->qual[d1.seq].
    price = psi.price, billitems->qual[d1.seq].charge_level_cd = psi.charge_level_cd,
    billitems->qual[d1.seq].detail_charge_ind = psi.detail_charge_ind, billitems->qual[d1.seq].
    beg_effective_dt_tm = psi.beg_effective_dt_tm, billitems->qual[d1.seq].end_effective_dt_tm = psi
    .end_effective_dt_tm,
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind,
    billitems->qual[d1.seq].stats_only_ind = psi.stats_only_ind
   WITH nocounter
  ;end select
  IF ((requestfromvb->setzero_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
    WHERE (billitems->qual[d1.seq].updt_ind=0)
    DETAIL
     countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
     price_sched_items[countp].action_type = "ADD",
     enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
     enspsirequest->price_sched_items[countp].price_sched_id = requestfromvb->to_price_sched_id,
     enspsirequest->price_sched_items[countp].percent_revenue = 0,
     enspsirequest->price_sched_items[countp].price = 0, enspsirequest->price_sched_items[countp].
     charge_level_cd = billitems->qual[d1.seq].charge_level_cd, enspsirequest->price_sched_items[
     countp].detail_charge_ind_ind = 1,
     enspsirequest->price_sched_items[countp].detail_charge_ind = 1, enspsirequest->
     price_sched_items[countp].active_ind = 1, enspsirequest->price_sched_items[countp].
     beg_effective_dt_tm = cnvtdatetime(requestfromvb->beg_effective_dt_tm),
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->
      end_effective_dt_tm2), enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1
     .seq].units_ind, enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->
     units_ind_ind,
     enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
     enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
    WITH nocounter
   ;end select
   SET enspsirequest->price_sched_items_qual = countp
   CALL echo(build("Price Sched Items updated with 0 price :",enspsirequest->price_sched_items_qual))
  ENDIF
 ENDIF
 IF ((requestfromvb->percent_ind=1))
  CALL echo("***********INSIDE IF***********")
  SELECT INTO "nl:"
   psi.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    price_sched_items psi
   PLAN (d1)
    JOIN (psi
    WHERE cnvtdatetime(requestfromvb->beg_effective_dt_tm) >= psi.beg_effective_dt_tm
     AND (psi.price_sched_id=requestfromvb->to_price_sched_id)
     AND psi.active_ind=1
     AND (psi.bill_item_id=billitems->qual[d1.seq].bill_item_id))
   DETAIL
    CALL echo(psi.price_sched_items_id), billitems->qual[d1.seq].bill_item_id = psi.bill_item_id,
    billitems->qual[d1.seq].price_sched_id = psi.price_sched_id,
    billitems->qual[d1.seq].price_sched_items_id = psi.price_sched_items_id, billitems->qual[d1.seq].
    price = psi.price, billitems->qual[d1.seq].charge_level_cd = psi.charge_level_cd,
    billitems->qual[d1.seq].detail_charge_ind = psi.detail_charge_ind, billitems->qual[d1.seq].
    beg_effective_dt_tm = psi.beg_effective_dt_tm, billitems->qual[d1.seq].end_effective_dt_tm = psi
    .end_effective_dt_tm,
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind,
    billitems->qual[d1.seq].stats_only_ind = psi.stats_only_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((requestfromvb->setzero_ind=1))
  SELECT INTO "nl:"
   psi.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    price_sched_items psi
   PLAN (d1)
    JOIN (psi
    WHERE psi.beg_effective_dt_tm <= cnvtdatetime(requestfromvb->beg_effective_dt_tm)
     AND psi.end_effective_dt_tm >= cnvtdatetime(requestfromvb->end_effective_dt_tm2)
     AND (psi.price_sched_id=requestfromvb->to_price_sched_id)
     AND psi.active_ind=1
     AND (psi.bill_item_id=billitems->qual[d1.seq].bill_item_id))
   DETAIL
    CALL echo(psi.price_sched_items_id), billitems->qual[d1.seq].bill_item_id = psi.bill_item_id,
    billitems->qual[d1.seq].price_sched_id = psi.price_sched_id,
    billitems->qual[d1.seq].price_sched_items_id = psi.price_sched_items_id, billitems->qual[d1.seq].
    price = psi.price, billitems->qual[d1.seq].charge_level_cd = psi.charge_level_cd,
    billitems->qual[d1.seq].detail_charge_ind = psi.detail_charge_ind, billitems->qual[d1.seq].
    beg_effective_dt_tm = psi.beg_effective_dt_tm, billitems->qual[d1.seq].end_effective_dt_tm = psi
    .end_effective_dt_tm,
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind,
    billitems->qual[d1.seq].stats_only_ind = psi.stats_only_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((requestfromvb->flat_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
   WHERE (billitems->qual[d1.seq].updt_ind=0)
   DETAIL
    countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
    price_sched_items[countp].action_type = "ADD",
    enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
    enspsirequest->price_sched_items[countp].price_sched_id = requestfromvb->to_price_sched_id,
    enspsirequest->price_sched_items[countp].percent_revenue = 0
    IF ((requestfromvb->roundingamount_ind=1))
     enspsirequest->price_sched_items[countp].price = round(requestfromvb->flatchange,0)
    ELSEIF ((requestfromvb->roundingamount_ind=2))
     enspsirequest->price_sched_items[countp].price = round(requestfromvb->flatchange,1)
    ELSEIF ((requestfromvb->roundingamount_ind=3))
     enspsirequest->price_sched_items[countp].price = round(requestfromvb->flatchange,2)
    ELSE
     enspsirequest->price_sched_items[countp].price = requestfromvb->flatchange
    ENDIF
    enspsirequest->price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].
    charge_level_cd, enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1,
    enspsirequest->price_sched_items[countp].detail_charge_ind = 1,
    enspsirequest->price_sched_items[countp].active_ind = 1, enspsirequest->price_sched_items[countp]
    .beg_effective_dt_tm = cnvtdatetime(requestfromvb->beg_effective_dt_tm), enspsirequest->
    price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->end_effective_dt_tm2),
    enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
   WITH nocounter
  ;end select
  SET enspsirequest->price_sched_items_qual = countp
  CALL echo(build("Quals added that did not have an existing price sched item: ",enspsirequest->
    price_sched_items_qual))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  WHERE (billitems->qual[d1.seq].updt_ind=1)
  DETAIL
   countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
   price_sched_items[countp].action_type = "UPT",
   enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
   enspsirequest->price_sched_items[countp].price_sched_items_id = billitems->qual[d1.seq].
   price_sched_items_id, enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1
   .seq].price_sched_id,
   enspsirequest->price_sched_items[countp].percent_revenue = 0, enspsirequest->price_sched_items[
   countp].price = billitems->qual[d1.seq].price, enspsirequest->price_sched_items[countp].
   charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
   enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
   price_sched_items[countp].detail_charge_ind = billitems->qual[d1.seq].detail_charge_ind,
   enspsirequest->price_sched_items[countp].active_ind_ind = 1,
   enspsirequest->price_sched_items[countp].active_ind = 0, enspsirequest->price_sched_items[countp].
   beg_effective_dt_tm = billitems->qual[d1.seq].beg_effective_dt_tm, enspsirequest->
   price_sched_items[countp].end_effective_dt_tm = billitems->qual[d1.seq].end_effective_dt_tm,
   enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
   enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind,
   enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
   enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
  WITH nocounter
 ;end select
 SET enspsirequest->price_sched_items_qual = countp
 CALL echo(build("Old price sched items updated: ",enspsirequest->price_sched_items_qual))
 IF ((requestfromvb->flat_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
   WHERE (billitems->qual[d1.seq].updt_ind=1)
   DETAIL
    countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
    price_sched_items[countp].action_type = "ADD",
    enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
    enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq].price_sched_id,
    enspsirequest->price_sched_items[countp].percent_revenue = 0,
    enspsirequest->price_sched_items[countp].price = billitems->qual[d1.seq].price, enspsirequest->
    price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
    enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1,
    enspsirequest->price_sched_items[countp].detail_charge_ind = 1, enspsirequest->price_sched_items[
    countp].active_ind = 1, enspsirequest->price_sched_items[countp].beg_effective_dt_tm = billitems
    ->qual[d1.seq].beg_effective_dt_tm
    IF ((cnvtdatetime(requestfromvb->beg_effective_dt_tm) >= billitems->qual[d1.seq].
    beg_effective_dt_tm)
     AND (cnvtdatetime(requestfromvb->end_effective_dt_tm) <= billitems->qual[d1.seq].
    end_effective_dt_tm))
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(newenddate)
    ELSEIF ((cnvtdatetime(requestfromvb->beg_effective_dt_tm) >= billitems->qual[d1.seq].
    beg_effective_dt_tm)
     AND (cnvtdatetime(requestfromvb->end_effective_dt_tm) >= billitems->qual[d1.seq].
    end_effective_dt_tm))
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(newenddate)
    ENDIF
    enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
   WITH nocounter
  ;end select
  SET enspsirequest->price_sched_items_qual = countp
  CALL echo(build("New price sched items added with original prices: ",enspsirequest->
    price_sched_items_qual))
 ENDIF
 IF ((requestfromvb->percent_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
   WHERE (billitems->qual[d1.seq].updt_ind=1)
   DETAIL
    countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
    price_sched_items[countp].action_type = "ADD",
    enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
    enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq].price_sched_id,
    enspsirequest->price_sched_items[countp].percent_revenue = 0,
    enspsirequest->price_sched_items[countp].price = billitems->qual[d1.seq].price, enspsirequest->
    price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
    enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1,
    enspsirequest->price_sched_items[countp].detail_charge_ind = 1, enspsirequest->price_sched_items[
    countp].active_ind = 1, enspsirequest->price_sched_items[countp].beg_effective_dt_tm = billitems
    ->qual[d1.seq].beg_effective_dt_tm
    IF ((cnvtdatetime(requestfromvb->beg_effective_dt_tm)=billitems->qual[d1.seq].beg_effective_dt_tm
    ))
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->
      beg_effective_dt_tm2)
    ELSE
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(newenddate)
    ENDIF
    enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
    enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
   WITH nocounter
  ;end select
  SET enspsirequest->price_sched_items_qual = countp
  CALL echo(build("New price sched items added with original prices: ",enspsirequest->
    price_sched_items_qual))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  WHERE (billitems->qual[d1.seq].updt_ind=1)
  DETAIL
   countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
   price_sched_items[countp].action_type = "ADD",
   enspsirequest->price_sched_items[countp].bill_item_id = billitems->qual[d1.seq].bill_item_id,
   enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq].price_sched_id,
   enspsirequest->price_sched_items[countp].percent_revenue = 0
   IF ((requestfromvb->flat_ind=1))
    enspsirequest->price_sched_items[countp].price = (billitems->qual[d1.seq].price+ requestfromvb->
    flatchange)
    IF ((requestfromvb->roundingamount_ind=1))
     enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp].
      price,0)
    ELSEIF ((requestfromvb->roundingamount_ind=2))
     enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp].
      price,1)
    ELSEIF ((requestfromvb->roundingamount_ind=3))
     enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp].
      price,2)
    ELSE
     enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
    ENDIF
   ELSEIF ((requestfromvb->percent_ind=1))
    enspsirequest->price_sched_items[countp].price = (billitems->qual[d1.seq].price+ (billitems->
    qual[d1.seq].price * requestfromvb->percentchange))
    IF ((requestfromvb->roundingdirection_ind=1))
     hold_amount = enspsirequest->price_sched_items[countp].price,
     CALL echo(""),
     CALL echo(build("a) hold_amount: ",hold_amount))
     IF ((requestfromvb->roundingamount_ind=1))
      CALL echo(build("b) round(hold_amount): ",round(hold_amount,0)))
      IF (hold_amount > round(hold_amount,0))
       hold_amount = (hold_amount+ 1),
       CALL echo(build("c) hold_amount: ",hold_amount))
      ENDIF
      enspsirequest->price_sched_items[countp].price = round(hold_amount,0),
      CALL echo(build("d) price: ",enspsirequest->price_sched_items[countp].price))
     ELSEIF ((requestfromvb->roundingamount_ind=2))
      CALL echo(build("b) round(hold_amount): ",round(hold_amount,1)))
      IF (hold_amount > round(hold_amount,1))
       hold_amount = (hold_amount+ 0.10),
       CALL echo(build("c) hold_amount: ",hold_amount))
      ENDIF
      enspsirequest->price_sched_items[countp].price = round(hold_amount,1),
      CALL echo(build("d) price: ",enspsirequest->price_sched_items[countp].price))
     ELSEIF ((requestfromvb->roundingamount_ind=3))
      CALL echo(build("b) round(hold_amount): ",round(hold_amount,2)))
      IF (hold_amount > round(hold_amount,2))
       hold_amount = (hold_amount+ 0.01),
       CALL echo(build("c) hold_amount: ",hold_amount))
      ENDIF
      enspsirequest->price_sched_items[countp].price = round(hold_amount,2),
      CALL echo(build("d) price: ",enspsirequest->price_sched_items[countp].price))
     ELSE
      enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
     ENDIF
    ELSEIF ((requestfromvb->roundingdirection_ind=2))
     IF ((requestfromvb->roundingamount_ind=1))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,- (0))
     ELSEIF ((requestfromvb->roundingamount_ind=2))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,- (1))
     ELSEIF ((requestfromvb->roundingamount_ind=3))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,- (2))
     ELSE
      enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
     ENDIF
    ELSEIF ((requestfromvb->roundingdirection_ind=3))
     hold_amount = enspsirequest->price_sched_items[countp].price,
     CALL echo(""),
     CALL echo(build("a) hold_amount: ",hold_amount))
     IF ((requestfromvb->roundingamount_ind=1))
      CALL echo(build("b) round(hold_amount + 0.000001): ",round((hold_amount+ 0.000001),0))),
      enspsirequest->price_sched_items[countp].price = round((hold_amount+ 0.000001),0),
      CALL echo(build("d) price: ",enspsirequest->price_sched_items[countp].price))
     ELSEIF ((requestfromvb->roundingamount_ind=2))
      enspsirequest->price_sched_items[countp].price = round((hold_amount+ 0.000001),1)
     ELSEIF ((requestfromvb->roundingamount_ind=3))
      enspsirequest->price_sched_items[countp].price = round((hold_amount+ 0.000001),2)
     ELSE
      enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
     ENDIF
    ELSE
     enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
    ENDIF
   ELSE
    enspsirequest->price_sched_items[countp].price = 0
   ENDIF
   enspsirequest->price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
   enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
   price_sched_items[countp].detail_charge_ind = 1,
   enspsirequest->price_sched_items[countp].active_ind = 1, enspsirequest->price_sched_items[countp].
   beg_effective_dt_tm = cnvtdatetime(requestfromvb->beg_effective_dt_tm), enspsirequest->
   price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->end_effective_dt_tm2),
   enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
   enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind,
   enspsirequest->price_sched_items[countp].stats_only_ind = billitems->qual[d1.seq].stats_only_ind,
   enspsirequest->price_sched_items[countp].stats_only_ind_ind = requestfromvb->stats_only_ind_ind
  WITH nocounter
 ;end select
 SET enspsirequest->price_sched_items_qual = countp
 CALL echo(build("New price sched items added with new dates and prices: ",enspsirequest->
   price_sched_items_qual))
 IF ((requestfromvb->report_flg=8))
  SELECT
   FROM (dummyt d1  WITH seq = value(enspsirequest->price_sched_items_qual))
   ORDER BY enspsirequest->price_sched_items[d1.seq].bill_item_id, enspsirequest->price_sched_items[
    d1.seq].action_type DESC
   DETAIL
    col 0, enspsirequest->price_sched_items[d1.seq].action_type, col 5,
    enspsirequest->price_sched_items[d1.seq].bill_item_id, col 20, enspsirequest->price_sched_items[
    d1.seq].price_sched_id,
    col 35, enspsirequest->price_sched_items[d1.seq].price, col 65,
    enspsirequest->price_sched_items[d1.seq].beg_effective_dt_tm"MM/DD/YY HH:MM:SS;;D", col 95,
    enspsirequest->price_sched_items[d1.seq].end_effective_dt_tm"MM/DD/YY HH:MM:SS;;D",
    col 120, enspsirequest->price_sched_items[d1.seq].price_sched_items_id"#########", row + 1
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(request->price_sched_items,0)
 FOR (x = 1 TO enspsirequest->price_sched_items_qual)
   SET stat = alterlist(request->price_sched_items,x)
   SET request->price_sched_items_qual = enspsirequest->price_sched_items_qual
   SET request->price_sched_items[x].action_type = enspsirequest->price_sched_items[x].action_type
   SET request->price_sched_items[x].price_sched_id = enspsirequest->price_sched_items[x].
   price_sched_id
   SET request->price_sched_items[x].bill_item_id = enspsirequest->price_sched_items[x].bill_item_id
   SET request->price_sched_items[x].price_sched_items_id = enspsirequest->price_sched_items[x].
   price_sched_items_id
   SET request->price_sched_items[x].price = enspsirequest->price_sched_items[x].price
   SET request->price_sched_items[x].price_ind = enspsirequest->price_sched_items[x].price_ind
   SET request->price_sched_items[x].percent_revenue = enspsirequest->price_sched_items[x].
   percent_revenue
   SET request->price_sched_items[x].charge_level_cd = enspsirequest->price_sched_items[x].
   charge_level_cd
   SET request->price_sched_items[x].interval_template_cd = enspsirequest->price_sched_items[x].
   interval_template_cd
   SET request->price_sched_items[x].detail_charge_ind_ind = enspsirequest->price_sched_items[x].
   detail_charge_ind_ind
   SET request->price_sched_items[x].detail_charge_ind = enspsirequest->price_sched_items[x].
   detail_charge_ind
   SET request->price_sched_items[x].active_ind_ind = enspsirequest->price_sched_items[x].
   active_ind_ind
   SET request->price_sched_items[x].active_ind = enspsirequest->price_sched_items[x].active_ind
   SET request->price_sched_items[x].active_status_cd = enspsirequest->price_sched_items[x].
   active_status_cd
   SET request->price_sched_items[x].active_status_dt_tm = enspsirequest->price_sched_items[x].
   active_status_dt_tm
   SET request->price_sched_items[x].active_status_prsnl_id = enspsirequest->price_sched_items[x].
   active_status_prsnl_id
   SET request->price_sched_items[x].beg_effective_dt_tm = enspsirequest->price_sched_items[x].
   beg_effective_dt_tm
   SET request->price_sched_items[x].end_effective_dt_tm = enspsirequest->price_sched_items[x].
   end_effective_dt_tm
   SET request->price_sched_items[x].end_effective_dt_tm_ind = enspsirequest->price_sched_items[x].
   end_effective_dt_tm_ind
   SET request->price_sched_items[x].updt_cnt = enspsirequest->price_sched_items[x].updt_cnt
   SET request->price_sched_items[x].units_ind = enspsirequest->price_sched_items[x].units_ind
   SET request->price_sched_items[x].units_ind_ind = enspsirequest->price_sched_items[x].
   units_ind_ind
   SET request->price_sched_items[x].stats_only_ind = enspsirequest->price_sched_items[x].
   stats_only_ind
   SET request->price_sched_items[x].stats_only_ind_ind = enspsirequest->price_sched_items[x].
   stats_only_ind_ind
 ENDFOR
 CALL echo(concat("The size of the request is: ",cnvtstring(size(enspsirequest->
     price_sched_items_qual,1))))
 SET addflag = 0
 SET uptflag = 0
 FOR (bbx = 1 TO size(enspsirequest->price_sched_items_qual,5))
   CALL echo("*******************INSIDE ENS_PRICE_SCHED_ITEM FOR LOOP**************************")
   CALL echo(concat("count: ",cnvtstring(bbx)))
   SET action_begin = bbx
   SET action_end = bbx
   EXECUTE afc_ens_price_sched_item
   CALL echo("WHERE ARE WE???")
   CALL echo(concat("count: ",cnvtstring(bbx)))
 ENDFOR
 FREE SET requestfromvb
 FREE SET billitems
END GO
