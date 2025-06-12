CREATE PROGRAM afc_add_adv_price:dba
 RECORD requestfromvb(
   1 ext_owner_code = f8
   1 from_price_sched_id = f8
   1 to_price_sched_id = f8
   1 level_ind = i2
   1 flatchange = f8
   1 percentchange = f8
   1 percent_ind = i2
   1 flat_ind = i2
   1 setzero_ind = i2
 )
 SET requestfromvb->ext_owner_code = request->ext_owner_code
 SET requestfromvb->from_price_sched_id = request->from_price_sched_id
 SET requestfromvb->to_price_sched_id = request->to_price_sched_id
 SET requestfromvb->level_ind = request->level_ind
 SET requestfromvb->flatchange = request->flatchange
 SET requestfromvb->percentchange = request->percentchange
 SET requestfromvb->percent_ind = request->percent_ind
 SET requestfromvb->flat_ind = request->flat_ind
 SET requestfromvb->setzero_ind = request->setzero_ind
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
 )
 SET countp = 0
 SELECT
  IF ((requestfromvb->level_ind=1))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE (ext_owner_cd=requestfromvb->ext_owner_code)
     AND ext_parent_reference_id != 0
     AND active_ind=1))
    AND (psi.price_sched_id=requestfromvb->from_price_sched_id)
    AND psi.price > 0
    AND psi.active_ind=1
  ELSEIF ((requestfromvb->level_ind=2))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE (ext_owner_cd=requestfromvb->ext_owner_code)
     AND ext_child_reference_id=0
     AND active_ind=1))
    AND psi.price > 0
    AND (psi.price_sched_id=requestfromvb->from_price_sched_id)
    AND psi.active_ind=1
  ELSEIF ((requestfromvb->level_ind=3))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE (ext_owner_cd=requestfromvb->ext_owner_code)
     AND ext_parent_reference_id != 0
     AND ext_child_reference_id != 0
     AND active_ind=1))
    AND psi.price > 0
    AND (psi.price_sched_id=requestfromvb->from_price_sched_id)
    AND psi.active_ind=1
  ELSEIF ((requestfromvb->level_ind=4))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE ext_parent_reference_id=0
     AND ext_parent_contributor_cd=0
     AND active_ind=1))
    AND (psi.price_sched_id=requestfromvb->to_price_sched_id)
    AND psi.price > 0
    AND psi.active_ind=1
  ELSE
  ENDIF
  DETAIL
   countp = (countp+ 1), stat = alterlist(request->price_sched_items,countp), request->
   price_sched_items[countp].action_type = "ADD",
   request->price_sched_items[countp].bill_item_id = psi.bill_item_id, request->price_sched_items[
   countp].price_sched_id = requestfromvb->to_price_sched_id
   IF ((requestfromvb->flat_ind=1))
    request->price_sched_items[countp].price = (psi.price+ requestfromvb->flatchange)
   ELSE
    request->price_sched_items[countp].price = (psi.price+ (psi.price * requestfromvb->percentchange)
    )
   ENDIF
   request->price_sched_items[countp].charge_level_cd = psi.charge_level_cd, request->
   price_sched_items[countp].detail_charge_ind = psi.detail_charge_ind, request->price_sched_items[
   countp].detail_charge_ind_ind = 1,
   request->price_sched_items[countp].active_ind = 1, request->price_sched_items[countp].
   beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), request->price_sched_items[countp].
   end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59:59")
  WITH nocounter
 ;end select
 SET request->price_sched_items_qual = countp
 EXECUTE afc_ens_price_sched_item
 FREE SET requestfromvb
END GO
