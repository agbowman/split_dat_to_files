CREATE PROGRAM afc_rad_zero_price:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_task = 951716
 RECORD rad_parent(
   1 rp_qual = i4
   1 rp[*]
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_owner_cd = f8
     2 bill_item_id = f8
 )
 RECORD rad_child(
   1 rc_qual = i4
   1 rc[*]
     2 bill_item_id = f8
     2 price_found = i2
 )
 SET code_value = 0.0
 SET cdf_meaning = "RADIOLOGY"
 SET code_set = 106
 EXECUTE cpm_get_cd_for_cdf
 SET rad_owner = code_value
 SET gen_owner = 272
 CALL echo(gen_owner)
 CALL echo("Selecting Rad Parents...")
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b
  PLAN (b
   WHERE b.ext_owner_cd IN (rad_owner, gen_owner)
    AND b.active_ind=1
    AND b.ext_child_reference_id=0)
  DETAIL
   rad_parent->rp_qual = (rad_parent->rp_qual+ 1), stat = alterlist(rad_parent->rp,rad_parent->
    rp_qual), rad_parent->rp[rad_parent->rp_qual].ext_parent_reference_id = b.ext_parent_reference_id,
   rad_parent->rp[rad_parent->rp_qual].ext_parent_contributor_cd = b.ext_parent_contributor_cd,
   rad_parent->rp[rad_parent->rp_qual].ext_owner_cd = b.ext_owner_cd, rad_parent->rp[rad_parent->
   rp_qual].bill_item_id = b.bill_item_id
  WITH nocounter
 ;end select
 CALL echo("Read: ",0)
 CALL echo(rad_parent->rp_qual,0)
 CALL echo(" rad parent bill_items.")
 CALL echo("Selecting Rad Children...")
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   (dummyt d1  WITH seq = value(rad_parent->rp_qual))
  PLAN (d1
   WHERE (rad_parent->rp[d1.seq].ext_owner_cd=rad_owner))
   JOIN (b
   WHERE (b.ext_parent_reference_id=rad_parent->rp[d1.seq].ext_parent_reference_id)
    AND (b.ext_parent_contributor_cd=rad_parent->rp[d1.seq].ext_parent_contributor_cd)
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
  DETAIL
   rad_child->rc_qual = (rad_child->rc_qual+ 1), stat = alterlist(rad_child->rc,rad_child->rc_qual),
   rad_child->rc[rad_child->rc_qual].bill_item_id = b.bill_item_id
  WITH nocounter
 ;end select
 CALL echo("Read: ",0)
 CALL echo(rad_child->rc_qual,0)
 CALL echo(" rad child bill_items.")
 CALL echo("Adding Gen Addons to child list...")
 SET c_qual = rad_child->rc_qual
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(rad_parent->rp_qual))
  PLAN (d1
   WHERE (rad_parent->rp[d1.seq].ext_owner_cd=gen_owner))
  DETAIL
   c_qual = (c_qual+ 1), rad_child->rc_qual = c_qual, stat = alterlist(rad_child->rc,c_qual),
   rad_child->rc[c_qual].bill_item_id = rad_parent->rp[d1.seq].bill_item_id
  WITH nocounter
 ;end select
 CALL echo("Total Items in child list: ",0)
 CALL echo(rad_child->rc_qual)
 SET ps_id = 12016
 CALL echo("Validating for existing 0 price...")
 SET found_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(rad_child->rc_qual)),
   price_sched_items p
  PLAN (d1)
   JOIN (p
   WHERE (p.bill_item_id=rad_child->rc[d1.seq].bill_item_id)
    AND p.price_sched_id=ps_id
    AND p.active_ind=1)
  DETAIL
   found_cnt = (found_cnt+ 1), rad_child->rc[d1.seq].price_found = 1
  WITH nocounter
 ;end select
 CALL echo(found_cnt,0)
 CALL echo(" prices found")
 FREE SET request
 RECORD request(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
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
 SET request->price_sched_items_qual = rad_child->rc_qual
 SET stat = alterlist(request->price_sched_items,rad_child->rc_qual)
 CALL echo("Populating Request, writing ccluserdir:radzeroprice.dat")
 SET count1 = 0
 SELECT INTO "ccluserdir:radzeroprice.dat"
  FROM (dummyt d1  WITH seq = value(rad_child->rc_qual))
  PLAN (d1
   WHERE (rad_child->rc[d1.seq].price_found != 1))
  DETAIL
   count1 = (count1+ 1), request->price_sched_items[d1.seq].price_sched_id = ps_id, request->
   price_sched_items[d1.seq].bill_item_id = rad_child->rc[d1.seq].bill_item_id,
   request->price_sched_items[d1.seq].price_ind = 1, request->price_sched_items[d1.seq].price = 0,
   request->price_sched_items[d1.seq].detail_charge_ind_ind = 1,
   request->price_sched_items[d1.seq].detail_charge_ind = 1, col 00, d1.seq"#####",
   ".", col 10, request->price_sched_items[d1.seq].price_sched_id"########",
   col 20, request->price_sched_items[d1.seq].bill_item_id, row + 1
  WITH nocounter
 ;end select
 CALL echo("Executing afc_add_price_sched_item TO ADD ",0)
 CALL echo(request->price_sched_items_qual)
 EXECUTE afc_add_price_sched_item
 FREE SET rad_parent
 FREE SET rad_child
END GO
