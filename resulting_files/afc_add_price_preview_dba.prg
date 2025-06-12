CREATE PROGRAM afc_add_price_preview:dba
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
 SET requestfromvb->units_ind_ind = request->units_ind_ind
 SET requestfromvb->beg_effective_dt_tm = request->beg_effective_dt_tm
 SET requestfromvb->end_effective_dt_tm = request->end_effective_dt_tm
 SET requestfromvb->beg_effective_dt_tm2 = request->beg_effective_dt_tm2
 SET requestfromvb->end_effective_dt_tm2 = request->end_effective_dt_tm2
 SET newenddate = datetimeadd(requestfromvb->beg_effective_dt_tm2,- (1))
 SET requestfromvb->report_flg = request->report_flg
 SET requestfromvb->roundingdirection_ind = request->roundingdirection_ind
 SET requestfromvb->roundingamount_ind = request->roundingamount_ind
 RECORD enspsirequest(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = vc
     2 ext_description = c100
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
 )
 RECORD reply(
   1 nbr_lines = i4
   1 list[*]
     2 line = c132
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
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind
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
     enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].
     ext_description, enspsirequest->price_sched_items[countp].price_sched_id = requestfromvb->
     to_price_sched_id,
     enspsirequest->price_sched_items[countp].percent_revenue = 0, enspsirequest->price_sched_items[
     countp].price = 0, enspsirequest->price_sched_items[countp].charge_level_cd = billitems->qual[d1
     .seq].charge_level_cd,
     enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
     price_sched_items[countp].detail_charge_ind = 1, enspsirequest->price_sched_items[countp].
     active_ind = 1,
     enspsirequest->price_sched_items[countp].beg_effective_dt_tm = cnvtdatetime(requestfromvb->
      beg_effective_dt_tm), enspsirequest->price_sched_items[countp].end_effective_dt_tm =
     cnvtdatetime(requestfromvb->end_effective_dt_tm2), enspsirequest->price_sched_items[countp].
     units_ind = billitems->qual[d1.seq].units_ind,
     enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
    WITH nocounter
   ;end select
   SET enspsirequest->price_sched_items_qual = countp
   CALL echo(build("Price Sched Items updated with 0 price :",enspsirequest->price_sched_items_qual))
  ENDIF
 ENDIF
 IF ((requestfromvb->percent_ind=1))
  SELECT INTO "nl:"
   psi.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    price_sched_items psi
   PLAN (d1)
    JOIN (psi
    WHERE cnvtdatetime(requestfromvb->beg_effective_dt_tm) >= psi.beg_effective_dt_tm
     AND cnvtdatetime(requestfromvb->end_effective_dt_tm2) <= psi.end_effective_dt_tm
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
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind
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
    billitems->qual[d1.seq].updt_ind = 1, billitems->qual[d1.seq].units_ind = psi.units_ind
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
    enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].
    ext_description, enspsirequest->price_sched_items[countp].price_sched_id = requestfromvb->
    to_price_sched_id,
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
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
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
   enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].ext_description,
   enspsirequest->price_sched_items[countp].price_sched_items_id = billitems->qual[d1.seq].
   price_sched_items_id,
   enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq].price_sched_id,
   enspsirequest->price_sched_items[countp].percent_revenue = 0, enspsirequest->price_sched_items[
   countp].price = billitems->qual[d1.seq].price,
   enspsirequest->price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
   enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
   price_sched_items[countp].detail_charge_ind = billitems->qual[d1.seq].detail_charge_ind,
   enspsirequest->price_sched_items[countp].active_ind_ind = 1, enspsirequest->price_sched_items[
   countp].active_ind = 0, enspsirequest->price_sched_items[countp].beg_effective_dt_tm = billitems->
   qual[d1.seq].beg_effective_dt_tm,
   enspsirequest->price_sched_items[countp].end_effective_dt_tm = billitems->qual[d1.seq].
   end_effective_dt_tm, enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].
   units_ind, enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
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
    enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].
    ext_description, enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq
    ].price_sched_id,
    enspsirequest->price_sched_items[countp].percent_revenue = 0, enspsirequest->price_sched_items[
    countp].price = billitems->qual[d1.seq].price, enspsirequest->price_sched_items[countp].
    charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
    enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
    price_sched_items[countp].detail_charge_ind = 1, enspsirequest->price_sched_items[countp].
    active_ind = 1,
    enspsirequest->price_sched_items[countp].beg_effective_dt_tm = billitems->qual[d1.seq].
    beg_effective_dt_tm
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
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
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
    enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].
    ext_description, enspsirequest->price_sched_items[countp].price_sched_id = billitems->qual[d1.seq
    ].price_sched_id,
    enspsirequest->price_sched_items[countp].percent_revenue = 0, enspsirequest->price_sched_items[
    countp].price = billitems->qual[d1.seq].price, enspsirequest->price_sched_items[countp].
    charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
    enspsirequest->price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->
    price_sched_items[countp].detail_charge_ind = 1, enspsirequest->price_sched_items[countp].
    active_ind = 1,
    enspsirequest->price_sched_items[countp].beg_effective_dt_tm = billitems->qual[d1.seq].
    beg_effective_dt_tm
    IF ((cnvtdatetime(requestfromvb->beg_effective_dt_tm)=billitems->qual[d1.seq].beg_effective_dt_tm
    ))
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->
      beg_effective_dt_tm2)
    ELSE
     enspsirequest->price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(newenddate)
    ENDIF
    enspsirequest->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind,
    enspsirequest->price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
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
   enspsirequest->price_sched_items[countp].ext_description = billitems->qual[d1.seq].ext_description,
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
     IF ((requestfromvb->roundingamount_ind=1))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,0)
     ELSEIF ((requestfromvb->roundingamount_ind=2))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,1)
     ELSEIF ((requestfromvb->roundingamount_ind=3))
      enspsirequest->price_sched_items[countp].price = round(enspsirequest->price_sched_items[countp]
       .price,2)
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
    ELSE
     enspsirequest->price_sched_items[countp].price = enspsirequest->price_sched_items[countp].price
    ENDIF
   ELSE
    enspsirequest->price_sched_items[countp].price = 0
   ENDIF
   request->price_sched_items[countp].charge_level_cd = billitems->qual[d1.seq].charge_level_cd,
   request->price_sched_items[countp].detail_charge_ind_ind = 1, request->price_sched_items[countp].
   detail_charge_ind = 1,
   request->price_sched_items[countp].active_ind = 1, request->price_sched_items[countp].
   beg_effective_dt_tm = cnvtdatetime(requestfromvb->beg_effective_dt_tm), request->
   price_sched_items[countp].end_effective_dt_tm = cnvtdatetime(requestfromvb->end_effective_dt_tm2),
   request->price_sched_items[countp].units_ind = billitems->qual[d1.seq].units_ind, request->
   price_sched_items[countp].units_ind_ind = requestfromvb->units_ind_ind
  WITH nocounter
 ;end select
 SET request->price_sched_items_qual = countp
 CALL echo(build("New price sched items added with new dates and prices: ",request->
   price_sched_items_qual))
 SET file = "ccluserdir:afc_psi_changes.txt"
 SET nbr_lines = 0
 SELECT INTO value(file)
  FROM (dummyt d1  WITH seq = value(request->price_sched_items_qual))
  ORDER BY request->price_sched_items[d1.seq].bill_item_id
  HEAD REPORT
   line = fillstring(130,"="), col 0, "CS Batch Build - Price Maintennance Preview",
   col 100, curdate"MMM-DD-YYYY;;D", col 112,
   curtime"HH:MM:SS;;M", row + 1, col 0,
   line, row + 1, col 0,
   "Bill Item", row + 1, col 10,
   "Action", col 18, "Price Sched Id",
   col 40, "Price", col 50,
   "Beg Effect Date", col 72, "End Effect Date",
   col 90, "DCInd", col 100,
   "AInd", row + 1, col 0,
   line, row + 1
  DETAIL
   col 0, request->price_sched_items[d1.seq].ext_description"###################", row + 1,
   col 10, request->price_sched_items[d1.seq].action_type, col 17,
   request->price_sched_items[d1.seq].price_sched_id"##########", col 38, request->price_sched_items[
   d1.seq].price"$######.##",
   col 51, request->price_sched_items[d1.seq].beg_effective_dt_tm"MM/DD/YY HH:MM:SS;;D", col 71,
   request->price_sched_items[d1.seq].end_effective_dt_tm"MM/DD/YY HH:MM:SS;;D", col 92, request->
   price_sched_items[d1.seq].detail_charge_ind"#",
   col 103, request->price_sched_items[d1.seq].active_ind"#", row + 1
  WITH nocounter
 ;end select
 CALL echo(build("Outfile is: ",file))
 FREE DEFINE rtl
 DEFINE rtl concat(file)
 SELECT INTO "NL:"
  log = r.line
  FROM rtlt r
  DETAIL
   nbr_lines = (nbr_lines+ 1), stat = alterlist(reply->list,nbr_lines), reply->list[nbr_lines].line
    = r.line
  WITH nocounter
 ;end select
 SET reply->nbr_lines = nbr_lines
 CALL echo(build("Nbr of Lines: ",reply->nbr_lines))
 FREE SET requestfromvb
 FREE SET billitems
END GO
