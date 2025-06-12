CREATE PROGRAM afc_get_bill_item_batch:dba
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 ext_owner_cd = f8
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 careset_ind = i2
   1 price_sched_qual = i4
   1 price_sched[*]
     2 bill_item_id = f8
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 price_sched_items_id = f8
     2 price = f8
     2 active_ind = i2
     2 charge_level_cd = f8
     2 current_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 bill_item_mod_qual = i4
   1 bill_item_mod[*]
     2 bill_item_id = f8
     2 bill_item_mod_id = f8
     2 bill_item_type_cd = f8
     2 sched = f8
     2 charge_point = f8
     2 key3_id = f8
     2 charge_level_cd = f8
     2 key5_id = f8
     2 bill_code_type_cd = f8
     2 bill_code = vc
     2 priority = f8
     2 description = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 current_ind = i2
     2 updt_cnt = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET charge_point_schedule = 0.0
 SET bill_code_schedule = 0.0
 SET add_on_owner_code = 0.0
 SET count1 = 0
 SET curqual1 = 0
 SET price_sched_count = 0
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET charge_point_schedule = code_value
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code_schedule = code_value
 SET code_set = 106
 SET cdf_meaning = "AFC ADD SPEC"
 EXECUTE cpm_get_cd_for_cdf
 SET add_on_owner_code = code_value
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_cat = code_value
 IF ((request->price_sched_count > 0))
  SET priceschedid = fillstring(200," ")
  SET priceschedid = "p1.price_sched_id in ("
  SET i = 0
  FOR (i = 1 TO request->price_sched_count)
    IF (i=1)
     SET priceschedid = build(priceschedid,cnvtstring(request->price_sched_chosen[1].price_sched_id))
    ELSE
     SET priceschedid = build(priceschedid,concat(",",cnvtstring(request->price_sched_chosen[i].
        price_sched_id)))
    ENDIF
  ENDFOR
  SET priceschedid = build(priceschedid,")")
  SET priceschedid = trim(priceschedid)
 ENDIF
 EXECUTE afc_get_bill_item_batch2 parser(
  IF ((request->ext_owner_cd > 0)) "b.ext_owner_cd = request->ext_owner_cd"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->ext_parent_reference_id > 0))
   "b.ext_parent_reference_id = request->ext_parent_reference_id"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->ext_child_reference_id > 0))
   "b.ext_child_reference_id = request->ext_child_reference_id"
  ELSE "0 = 0"
  ENDIF
  ),
 parser(
  IF ((request->price_sched_count > 0)) priceschedid
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->ext_parent_contributor_cd > 0))
   "b.ext_parent_contributor_cd = request->ext_parent_contributor_cd"
  ELSE "0 = 0"
  ENDIF
  )
END GO
