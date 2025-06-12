CREATE PROGRAM afc_add_mrp_from_procure:dba
 RECORD billitems(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
     2 cost_adj_flex_id = f8
     2 min_charge_amt = f8
     2 cost_basis_amt = f8
     2 cost_adj_amt = f8
     2 adj_type_flag = i2
     2 price = f8
     2 price_sched_qual = i4
     2 price_sched[*]
       3 price_sched_id = f8
       3 cost_adj_amt = f8
       3 tax = f8
 )
 RECORD temppricesched(
   1 price_sched_qual = i4
   1 price_sched[*]
     2 price_sched_id = f8
 )
 RECORD request_item_price(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 allowable = f8
     2 percent_revenue = i4
     2 interval_template_cd = f8
     2 charge_level_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 exclusive_ind_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind = i2
     2 stats_only_ind_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE dcostadjamt = f8
 DECLARE iret = i4
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 DECLARE count1 = i4
 DECLARE 14175_mrp = f8
 SET cdf_meaning = "MRP"
 SET code_set = 14175
 SET count = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,count,14175_mrp)
 SET billitemcnt = 0
 SELECT DISTINCT INTO "nl:"
  bi.*, ilc.*
  FROM cost_adj_flex caf,
   item_class_node_r icnr,
   bill_item bi,
   item_location_cost ilc
  PLAN (caf
   WHERE (caf.cost_adj_sched_id=request->cost_adj_sched_id))
   JOIN (icnr
   WHERE icnr.class_node_id=caf.parent_entity_id)
   JOIN (bi
   WHERE bi.ext_parent_reference_id=icnr.item_id)
   JOIN (ilc
   WHERE ilc.item_id=icnr.item_id
    AND ilc.location_cd=0
    AND ilc.cost_type_cd=14175_mrp)
  DETAIL
   billitemcnt = (billitemcnt+ 1), billitems->bill_item_qual = billitemcnt, stat = alterlist(
    billitems->bill_item,billitemcnt),
   billitems->bill_item[billitemcnt].bill_item_id = bi.bill_item_id, billitems->bill_item[billitemcnt
   ].cost_adj_flex_id = caf.cost_adj_flex_id, billitems->bill_item[billitemcnt].min_charge_amt = caf
   .min_charge_amt,
   billitems->bill_item[billitemcnt].cost_basis_amt = ilc.cost
  WITH nocounter
 ;end select
 SET xmrp = 0
 FOR (xmrp = 1 TO billitems->bill_item_qual)
   UPDATE  FROM bill_item bi
    SET bi.cost_basis_amt = billitems->bill_item[xmrp].cost_basis_amt
    WHERE (bi.bill_item_id=billitems->bill_item[xmrp].bill_item_id)
   ;end update
 ENDFOR
 SET xmrp = 0
 SET costadjcnt = 0
 FOR (costadjcnt = 1 TO billitems->bill_item_qual)
   SELECT INTO "nl:"
    FROM cost_adj ca
    WHERE (ca.cost_adj_flex_id=billitems->bill_item[costadjcnt].cost_adj_flex_id)
     AND (ca.lower_threshold <= billitems->bill_item[costadjcnt].cost_basis_amt)
     AND (ca.upper_threshold >= billitems->bill_item[costadjcnt].cost_basis_amt)
    DETAIL
     billitems->bill_item[costadjcnt].adj_type_flag = ca.adjustment_type_flag, billitems->bill_item[
     costadjcnt].cost_adj_amt = ca.adjustment_amt
    WITH nocounter
   ;end select
 ENDFOR
 IF ((request->price_sched_id > 0))
  SET priceschedcnt = 0
  SELECT INTO "nl:"
   FROM price_schedule_adj psa
   WHERE (psa.cost_adj_sched_id=request->cost_adj_sched_id)
    AND (psa.price_sched_id=request->price_sched_id)
   DETAIL
    priceschedcnt = (priceschedcnt+ 1), temppricesched->price_sched_qual = priceschedcnt, stat =
    alterlist(temppricesched->price_sched,priceschedcnt),
    temppricesched->price_sched[priceschedcnt].price_sched_id = psa.price_sched_id
   WITH nocounter
  ;end select
 ELSE
  SET priceschedcnt = 0
  SELECT INTO "nl:"
   FROM price_schedule_adj psa
   WHERE (psa.cost_adj_sched_id=request->cost_adj_sched_id)
   DETAIL
    priceschedcnt = (priceschedcnt+ 1), temppricesched->price_sched_qual = priceschedcnt, stat =
    alterlist(temppricesched->price_sched,priceschedcnt),
    temppricesched->price_sched[priceschedcnt].price_sched_id = psa.price_sched_id
   WITH nocounter
  ;end select
 ENDIF
 SET x = 0
 FOR (x = 1 TO billitems->bill_item_qual)
  SET billitems->bill_item[x].price_sched_qual = temppricesched->price_sched_qual
  FOR (z = 1 TO temppricesched->price_sched_qual)
   SET stat = alterlist(billitems->bill_item[x].price_sched,z)
   SET billitems->bill_item[x].price_sched[z].price_sched_id = temppricesched->price_sched[z].
   price_sched_id
  ENDFOR
 ENDFOR
 CALL echorecord(billitems)
 SET pscnt = 0
 SET bicnt = 0
 FOR (bicnt = 1 TO billitems->bill_item_qual)
   FOR (pscnt = 1 TO billitems->bill_item[bicnt].price_sched_qual)
     SET found_one = 0
     SELECT INTO "nl:"
      FROM price_sched_items psi
      WHERE (psi.price_sched_id=billitems->bill_item[bicnt].price_sched[pscnt].price_sched_id)
       AND (psi.bill_item_id=billitems->bill_item[bicnt].bill_item_id)
       AND psi.active_ind=1
       AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      DETAIL
       found_one = 1, billitems->bill_item[bicnt].price_sched[pscnt].tax = psi.tax
      WITH nocounter
     ;end select
     SET billitems->bill_item[bicnt].price = calculateprice(billitems->bill_item[bicnt].
      cost_basis_amt,billitems->bill_item[bicnt].cost_adj_amt,billitems->bill_item[bicnt].
      price_sched[pscnt].tax,billitems->bill_item[bicnt].adj_type_flag)
     SET billitems->bill_item[bicnt].price_sched[pscnt].cost_adj_amt = dcostadjamt
     CALL echorecord(billitems)
     IF (found_one=1)
      UPDATE  FROM price_sched_items psi
       SET psi.cost_adj_amt = dcostadjamt, psi.price = billitems->bill_item[bicnt].price, psi
        .updt_cnt = (psi.updt_cnt+ 1),
        psi.updt_dt_tm = cnvtdatetime(curdate,curtime3), psi.updt_id = reqinfo->updt_id, psi
        .updt_applctx = reqinfo->updt_applctx,
        psi.updt_task = reqinfo->updt_task
       WHERE (psi.price_sched_id=billitems->bill_item[bicnt].price_sched[pscnt].price_sched_id)
        AND (psi.bill_item_id=billitems->bill_item[bicnt].bill_item_id)
       WITH nocounter
      ;end update
      SET reqinfo->commit_ind = true
     ELSE
      SET stat = alterlist(request_item_price->price_sched_items,1)
      SET request_item_price->price_sched_items_qual = 1
      SET request_item_price->price_sched_items[1].action_type = "ADD"
      SET request_item_price->price_sched_items[1].price_sched_id = billitems->bill_item[bicnt].
      price_sched[pscnt].price_sched_id
      SET request_item_price->price_sched_items[1].bill_item_id = billitems->bill_item[bicnt].
      bill_item_id
      SET request_item_price->price_sched_items[1].price_sched_items_id = 0.0
      SET request_item_price->price_sched_items[1].price_ind = 1
      SET request_item_price->price_sched_items[1].price = billitems->bill_item[bicnt].price
      SET request_item_price->price_sched_items[1].cost_adj_amt = dcostadjamt
      SET request_item_price->price_sched_items[1].interval_template_cd = 0.0
      SET request_item_price->price_sched_items[1].detail_charge_ind_ind = 0
      SET request_item_price->price_sched_items[1].detail_charge_ind = 1
      SET request_item_price->price_sched_items[1].units_ind_ind = 0
      SET request_item_price->price_sched_items[1].units_ind = 0
      SET action_begin = 1
      SET action_end = 1
      CALL echorecord(billitems)
      EXECUTE afc_add_price_sched_item  WITH replace("REQUEST",request_item_price), replace("REPLY",
       reply_item_price)
     ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE calculateprice(dcostbasis,dadjamt,dtaxamt,iadjtype)
   DECLARE dprice = f8
   DECLARE sadjtype = vc
   CALL echo("in Calculate Price")
   SET dprice = 0.0
   IF (iadjtype=0)
    SET sadjtype = "Amount"
   ELSE
    SET sadjtype = "Percent"
   ENDIF
   CALL echo(build("Adjustment Amt: ",dadjamt))
   CALL echo(build("Adjustment Type: ",sadjtype))
   SET dcostadjamt = 0.0
   IF (iadjtype=1)
    SET dcostadjamt = (dcostbasis * ((dadjamt * 1)/ 100))
   ELSE
    SET dcostadjamt = dadjamt
   ENDIF
   SET dcostadjamt = round(dcostadjamt,2)
   CALL echo(build("Cost Adj Amt: ",dcostadjamt))
   SET dprice = ((dcostbasis+ dcostadjamt)+ dtaxamt)
   CALL echo(build("Price is: ",dprice))
   RETURN(dprice)
 END ;Subroutine
END GO
