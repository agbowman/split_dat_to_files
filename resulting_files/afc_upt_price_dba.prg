CREATE PROGRAM afc_upt_price:dba
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
 SET requestfromvb->units_ind_ind = 0
 SET requestfromvb->beg_effective_dt_tm = request->beg_effective_dt_tm
 SET requestfromvb->end_effective_dt_tm = request->end_effective_dt_tm
 SET requestfromvb->beg_effective_dt_tm2 = request->beg_effective_dt_tm2
 SET requestfromvb->end_effective_dt_tm2 = request->end_effective_dt_tm2
 SET newenddate = datetimeadd(requestfromvb->beg_effective_dt_tm2,- (1))
 SET requestfromvb->report_flg = request->report_flg
 SET requestfromvb->stats_only_ind_ind = 0
 CALL echo(build("from ps id",requestfromvb->from_price_sched_id))
 CALL echo(build("to ps id",requestfromvb->to_price_sched_id))
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
    WHERE (ext_owner_cd=requestfromvb->ext_owner_code)
     AND ext_parent_reference_id=0
     AND ext_parent_contributor_cd=0
     AND active_ind=1))
    AND (psi.price_sched_id=requestfromvb->from_price_sched_id)
    AND psi.active_ind=1
  ELSE
  ENDIF
  DETAIL
   countp = (countp+ 1), stat = alterlist(enspsirequest->price_sched_items,countp), enspsirequest->
   price_sched_items[countp].action_type = "ADD",
   enspsirequest->price_sched_items[countp].bill_item_id = psi.bill_item_id, enspsirequest->
   price_sched_items[countp].price_sched_id = requestfromvb->to_price_sched_id, enspsirequest->
   price_sched_items[countp].price_sched_items_id = psi.price_sched_items_id
   IF ((requestfromvb->flat_ind=1))
    enspsirequest->price_sched_items[countp].price = (psi.price+ requestfromvb->flatchange)
   ELSEIF ((requestfromvb->percent_ind=1))
    enspsirequest->price_sched_items[countp].price = (psi.price+ (psi.price * requestfromvb->
    percentchange))
   ELSE
    enspsirequest->price_sched_items[countp].price = 0
   ENDIF
   enspsirequest->price_sched_items[countp].charge_level_cd = psi.charge_level_cd, enspsirequest->
   price_sched_items[countp].detail_charge_ind_ind = 1, enspsirequest->price_sched_items[countp].
   detail_charge_ind = psi.detail_charge_ind,
   enspsirequest->price_sched_items[countp].active_ind_ind = 1, enspsirequest->price_sched_items[
   countp].active_ind = 1, enspsirequest->price_sched_items[countp].beg_effective_dt_tm =
   requestfromvb->beg_effective_dt_tm,
   enspsirequest->price_sched_items[countp].end_effective_dt_tm = requestfromvb->end_effective_dt_tm,
   enspsirequest->price_sched_items[countp].units_ind = psi.units_ind, enspsirequest->
   price_sched_items[countp].units_ind_ind = 1,
   enspsirequest->price_sched_items[countp].stats_only_ind = psi.stats_only_ind, enspsirequest->
   price_sched_items[countp].stats_only_ind_ind = 1
  WITH nocounter
 ;end select
 SET enspsirequest->price_sched_items_qual = countp
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
 EXECUTE afc_add_price_sched_item  WITH replace(request,enspsirequest)
 FREE SET requestfromvb
END GO
