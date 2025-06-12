CREATE PROGRAM afc_maintain_pricescheds:dba
 PAINT
 SET width = 140
 SET modify = system
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = i2
   1 updt_applctx = i4
   1 updt_task = i4
   1 updt_dt_tm = dq8
 )
 SET reqinfo->updt_id = 1100
 SET reqinfo->updt_applctx = 951100
 SET reqinfo->updt_task = 951100
 SET reqinfo->updt_dt_tm = cnvtdatetime(curdate,curtime)
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
     2 units_ind = i2
     2 units_ind_ind = i2
 )
 SET new_price_sched_id = 0
#menu
 CALL text(1,45,"***  Price Schedule Maintennance  ***")
 CALL text(3,10,"Press <Shift+F5> for a list of Choices:")
 CALL text(5,10,"1) Create list of Tiers with Price Sched Id of ZERO")
 CALL text(6,10,"2) Choose New Price Sched Id to Use")
 CALL text(7,10,"3) Fix Price Sched Items")
 CALL text(8,10,"4) Inactivate Price Sched Id of ZERO")
 CALL text(10,10,"5) Exit")
 CALL text(12,10,"Choose 1 of the following :")
 CALL accept(12,38,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   GO TO create_list
  OF 2:
   GO TO select_pricesched
  OF 3:
   GO TO fix_pricesched
  OF 4:
   GO TO inactivate_pricesched
  OF 5:
   GO TO the_end
 ENDCASE
 GO TO menu
#create_list
 SELECT DISTINCT
  c2.display
  FROM tier_matrix t,
   code_value c,
   code_value c2
  PLAN (c
   WHERE c.code_set IN (13036)
    AND c.cdf_meaning="PRICESCHED"
    AND c.active_ind=1)
   JOIN (t
   WHERE t.tier_cell_type_cd=c.code_value
    AND t.tier_cell_value=0
    AND t.active_ind=1
    AND t.end_effective_dt_tm > cnvtdate(curdate)
    AND t.beg_effective_dt_tm < t.end_effective_dt_tm)
   JOIN (c2
   WHERE c2.code_value=t.tier_group_cd
    AND c2.active_ind=1)
  WITH nocounter
 ;end select
 GO TO menu
#select_pricesched
 SET help =
 SELECT INTO "nl:"
  p.price_sched_id, p.price_sched_desc
  FROM price_sched p
  WHERE p.active_ind=1
   AND p.pharm_ind=0
  WITH nocounter
 ;end select
 CALL accept(6,50,"A(12);CU;",0)
 SET new_price_sched_id = cnvtint(curaccept)
 GO TO menu
#fix_pricesched
 SET count2 = 0
 SELECT INTO "nl:"
  p.*
  FROM price_sched_items p
  WHERE p.price_sched_id=0
   AND p.active_ind=1
  DETAIL
   count2 = (count2+ 1),
   CALL echo(build("Count: ",count2)), stat = alterlist(request->price_sched_items,count2),
   request->price_sched_items[count2].action_type = "UPT", request->price_sched_items[count2].
   bill_item_id = p.bill_item_id, request->price_sched_items[count2].price_sched_items_id = p
   .price_sched_items_id,
   request->price_sched_items[count2].price_sched_id = new_price_sched_id, request->
   price_sched_items[count2].percent_revenue = 0, request->price_sched_items[count2].price = p.price,
   request->price_sched_items[count2].charge_level_cd = p.charge_level_cd, request->
   price_sched_items[count2].detail_charge_ind_ind = 1, request->price_sched_items[count2].
   detail_charge_ind = p.detail_charge_ind,
   request->price_sched_items[count2].active_ind_ind = 1, request->price_sched_items[count2].
   active_ind = 1, request->price_sched_items[count2].beg_effective_dt_tm = p.beg_effective_dt_tm,
   request->price_sched_items[count2].end_effective_dt_tm = p.end_effective_dt_tm, request->
   price_sched_items[count2].units_ind_ind = 1, request->price_sched_items[count2].units_ind = p
   .units_ind,
   request->price_sched_items[count2].updt_id = reqinfo->updt_id, request->price_sched_items[count2].
   updt_applctx = reqinfo->updt_applctx, request->price_sched_items[count2].updt_task = reqinfo->
   updt_task,
   request->price_sched_items[count2].updt_dt_tm = reqinfo->updt_dt_tm
  WITH nocounter
 ;end select
 SET request->price_sched_items_qual = count2
 CALL text(14,10,"Processing..")
 SELECT
  action_type = request->price_sched_items[d1.seq].action_type, psid = request->price_sched_items[d1
  .seq].price_sched_id, psiid = request->price_sched_items[d1.seq].price_sched_items_id
  FROM (dummyt d1  WITH seq = value(size(request->price_sched_items,5)))
  WITH nocounter
 ;end select
 CALL echo("Executing afc_ens_price_sched_item...")
 EXECUTE afc_ens_price_sched_item
 CALL clear(14,10)
 GO TO menu
#inactivate_pricesched
 CALL text(19,10,"Processing ...")
 UPDATE  FROM price_sched p
  SET p.active_ind = 0
  WHERE p.price_sched_id=0
 ;end update
 CALL clear(19,10)
 GO TO menu
#the_end
END GO
