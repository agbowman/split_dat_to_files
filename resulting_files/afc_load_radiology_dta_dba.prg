CREATE PROGRAM afc_load_radiology_dta:dba
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i4
   1 updt_id = f8
   1 updt_applctx = i4
   1 updt_task = i4
 )
 SET reqinfo->updt_id = 2208
 SET reqinfo->updt_applctx = 0
 SET reqinfo->updt_task = 951999
 FREE SET request
 RECORD request(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
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
     2 end_effective_dt_tm_ind = i2
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1 = vc
     2 key2 = vc
     2 key3 = vc
     2 key4 = vc
     2 key5 = vc
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE SET orderable
 RECORD orderable(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 ext_parent_reference_id = f8
     2 bill_item_id = f8
     2 ext_description = vc
     2 price_sched_items_qual = i2
     2 price_sched_items[*]
       3 price_sched_id = f8
       3 price_sched_items_id = f8
       3 price = f8
       3 charge_level_cd = f8
       3 detail_charge_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 bill_codes_qual = i2
     2 bill_codes[*]
       3 bill_item_mod_id = f8
       3 bill_item_type_cd = f8
       3 key1 = vc
       3 key2 = vc
       3 key3 = vc
       3 key4 = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 child_item_qual = i2
     2 child_item[*]
       3 bill_item_id = f8
       3 ext_description = vc
 )
 SET radiology = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=106
  DETAIL
   radiology = cv.code_value
  WITH nocounter
 ;end select
 SET bcount = 0
 SET pcount = 0
 SET bmcount = 0
 SET stat = 0
 SELECT INTO "nl:"
  b.ext_parent_reference_id, b.bill_item_id, b.ext_description
  FROM bill_item b
  WHERE b.ext_owner_cd=radiology
   AND b.ext_child_reference_id=0
   AND b.active_ind=1
  ORDER BY b.ext_parent_reference_id
  HEAD b.ext_parent_reference_id
   bcount = (bcount+ 1), orderable->bill_item_qual = bcount, stat = alterlist(orderable->bill_item,
    bcount),
   orderable->bill_item[bcount].ext_parent_reference_id = b.ext_parent_reference_id, orderable->
   bill_item[bcount].bill_item_id = b.bill_item_id, orderable->bill_item[bcount].ext_description = b
   .ext_description
  WITH nocounter
 ;end select
 SET lastidx = 0
 SELECT INTO "nl:"
  p.price_sched_items_id, p.price_sched_id, p.price,
  p.charge_level_cd, p.detail_charge_ind, p.beg_effective_dt_tm
  FROM (dummyt d1  WITH seq = value(orderable->bill_item_qual)),
   price_sched_items p
  PLAN (d1)
   JOIN (p
   WHERE (p.bill_item_id=orderable->bill_item[d1.seq].bill_item_id)
    AND p.active_ind=1)
  DETAIL
   IF (d1.seq != lastidx)
    lastidx = d1.seq, pcount = 0
   ENDIF
   pcount = (pcount+ 1), orderable->bill_item[d1.seq].price_sched_items_qual = pcount, stat =
   alterlist(orderable->bill_item[d1.seq].price_sched_items,pcount),
   orderable->bill_item[d1.seq].price_sched_items[pcount].price_sched_id = p.price_sched_id,
   orderable->bill_item[d1.seq].price_sched_items[pcount].price_sched_items_id = p
   .price_sched_items_id, orderable->bill_item[d1.seq].price_sched_items[pcount].price = p.price,
   orderable->bill_item[d1.seq].price_sched_items[pcount].charge_level_cd = p.charge_level_cd,
   orderable->bill_item[d1.seq].price_sched_items[pcount].detail_charge_ind = p.detail_charge_ind,
   orderable->bill_item[d1.seq].price_sched_items[pcount].beg_effective_dt_tm = p.beg_effective_dt_tm,
   orderable->bill_item[d1.seq].price_sched_items[pcount].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET bill_code = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="BILL CODE"
  DETAIL
   bill_code = cv.code_value
  WITH nocounter
 ;end select
 SET lastidx = 0
 SELECT INTO "nl:"
  bm.bill_item_mod_id, bm.bill_item_type_cd, bm.key1,
  bm.key2, bm.key3, bm.key4,
  bm.beg_effective_dt_tm, bm.end_effective_dt_tm
  FROM (dummyt ordstruct  WITH seq = value(orderable->bill_item_qual)),
   bill_item_modifier bm
  PLAN (ordstruct)
   JOIN (bm
   WHERE (bm.bill_item_id=orderable->bill_item[ordstruct.seq].bill_item_id)
    AND bm.bill_item_type_cd=bill_code
    AND bm.active_ind=1)
  DETAIL
   IF (ordstruct.seq != lastidx)
    lastidx = ordstruct.seq, bmcount = 0
   ENDIF
   bmcount = (bmcount+ 1), orderable->bill_item[ordstruct.seq].bill_codes_qual = bmcount, stat =
   alterlist(orderable->bill_item[ordstruct.seq].bill_codes,bmcount),
   orderable->bill_item[ordstruct.seq].bill_codes[bmcount].bill_item_mod_id = bm.bill_item_mod_id,
   orderable->bill_item[ordstruct.seq].bill_codes[bmcount].bill_item_type_cd = bm.bill_item_type_cd,
   orderable->bill_item[ordstruct.seq].bill_codes[bmcount].key1 = bm.key1,
   orderable->bill_item[ordstruct.seq].bill_codes[bmcount].key2 = bm.key2, orderable->bill_item[
   ordstruct.seq].bill_codes[bmcount].key3 = bm.key3, orderable->bill_item[ordstruct.seq].bill_codes[
   bmcount].key4 = bm.key4,
   orderable->bill_item[ordstruct.seq].bill_codes[bmcount].beg_effective_dt_tm = bm
   .beg_effective_dt_tm, orderable->bill_item[ordstruct.seq].bill_codes[bmcount].end_effective_dt_tm
    = bm.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET lastidx = 0
 SET ccount = 0
 SELECT INTO "nl:"
  b.bill_item_id, b.ext_description
  FROM (dummyt ordstruct  WITH seq = value(orderable->bill_item_qual)),
   bill_item b
  PLAN (ordstruct)
   JOIN (b
   WHERE (b.ext_parent_reference_id=orderable->bill_item[ordstruct.seq].ext_parent_reference_id)
    AND b.ext_child_reference_id > 0
    AND b.active_ind=1)
  DETAIL
   IF (ordstruct.seq != lastidx)
    lastidx = ordstruct.seq, ccount = 0
   ENDIF
   ccount = (ccount+ 1), orderable->bill_item[ordstruct.seq].child_item_qual = ccount, stat =
   alterlist(orderable->bill_item[ordstruct.seq].child_item,ccount),
   orderable->bill_item[ordstruct.seq].child_item[ccount].bill_item_id = b.bill_item_id, orderable->
   bill_item[ordstruct.seq].child_item[ccount].ext_description = b.ext_description
  WITH nocounter
 ;end select
 SET pidx = 0
 SET bmidx = 0
 SET cidx = 0
 IF (( $1=1))
  SELECT
   FROM (dummyt ordstruct  WITH seq = value(orderable->bill_item_qual))
   PLAN (ordstruct)
   DETAIL
    IF ((((orderable->bill_item[ordstruct.seq].price_sched_items_qual > 0)) OR ((orderable->
    bill_item[ordstruct.seq].bill_codes_qual > 0)))
     AND (orderable->bill_item[ordstruct.seq].child_item_qual > 0))
     row + 1, col 01, "Bill Item: ",
     col 15, orderable->bill_item[ordstruct.seq].bill_item_id, col 35,
     orderable->bill_item[ordstruct.seq].ext_parent_reference_id, col 70, orderable->bill_item[
     ordstruct.seq].ext_description,
     row + 1
     IF ((orderable->bill_item[ordstruct.seq].price_sched_items_qual > 0))
      FOR (pidx = 1 TO orderable->bill_item[ordstruct.seq].price_sched_items_qual)
        IF (pidx=1)
         col 01, "Price Sched Items: ", row + 1
        ENDIF
        col 01, orderable->bill_item[ordstruct.seq].price_sched_items[pidx].price_sched_id, col 20,
        orderable->bill_item[ordstruct.seq].price_sched_items[pidx].price, col 40, orderable->
        bill_item[ordstruct.seq].price_sched_items[pidx].charge_level_cd,
        col 60, orderable->bill_item[ordstruct.seq].price_sched_items[pidx].detail_charge_ind, col 80,
        orderable->bill_item[ordstruct.seq].price_sched_items[pidx].beg_effective_dt_tm, col 100,
        orderable->bill_item[ordstruct.seq].price_sched_items[pidx].end_effective_dt_tm,
        row + 1
      ENDFOR
     ENDIF
     IF ((orderable->bill_item[ordstruct.seq].bill_codes_qual > 0))
      FOR (bmidx = 1 TO orderable->bill_item[ordstruct.seq].bill_codes_qual)
        IF (bmidx=1)
         col 01, "Bill Codes:", row + 1
        ENDIF
        col 01, orderable->bill_item[ordstruct.seq].bill_codes[bmidx].bill_item_mod_id, col 20,
        orderable->bill_item[ordstruct.seq].bill_codes[bmidx].bill_item_type_cd, col 40, orderable->
        bill_item[ordstruct.seq].bill_codes[bmidx].key1,
        col 60, orderable->bill_item[ordstruct.seq].bill_codes[bmidx].key2, col 80,
        orderable->bill_item[ordstruct.seq].bill_codes[bmidx].key3, col 100, orderable->bill_item[
        ordstruct.seq].bill_codes[bmidx].key4,
        row + 1
      ENDFOR
     ENDIF
     IF ((orderable->bill_item[ordstruct.seq].child_item_qual > 0))
      FOR (cidx = 1 TO orderable->bill_item[ordstruct.seq].child_item_qual)
        IF (cidx=1)
         col 01, "Child Items:", row + 1
        ENDIF
        col 01, orderable->bill_item[ordstruct.seq].child_item[cidx].bill_item_id, col 20,
        orderable->bill_item[ordstruct.seq].child_item[cidx].ext_description, row + 1
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (( $2=1))
  SET charge_level_detail = 0.0
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13020
    AND cv.cdf_meaning="DETAIL"
   DETAIL
    charge_level_detail = cv.code_value
   WITH nocounter
  ;end select
  SET pidx = 0
  SET bmidx = 0
  SET cidx = 0
  SET pridx = 0
  SET bmridx = 0
  SELECT INTO "nl:"
   FROM (dummyt ordstruct  WITH seq = value(orderable->bill_item_qual))
   PLAN (ordstruct)
   DETAIL
    IF ((((orderable->bill_item[ordstruct.seq].price_sched_items_qual > 0)) OR ((orderable->
    bill_item[ordstruct.seq].bill_codes_qual > 0)))
     AND (orderable->bill_item[ordstruct.seq].child_item_qual > 0))
     IF ((orderable->bill_item[ordstruct.seq].price_sched_items_qual > 0))
      FOR (pidx = 1 TO orderable->bill_item[ordstruct.seq].price_sched_items_qual)
        pridx = (pridx+ 1), request->price_sched_items_qual = pridx, stat = alterlist(request->
         price_sched_items,pridx),
        request->price_sched_items[pridx].action_type = "UPT", request->price_sched_items[pridx].
        price_sched_items_id = orderable->bill_item[ordstruct.seq].price_sched_items[pidx].
        price_sched_items_id, request->price_sched_items[pridx].price_sched_id = orderable->
        bill_item[ordstruct.seq].price_sched_items[pidx].price_sched_id,
        request->price_sched_items[pridx].bill_item_id = orderable->bill_item[ordstruct.seq].
        bill_item_id, request->price_sched_items[pridx].charge_level_cd = charge_level_detail
        FOR (cidx = 1 TO orderable->bill_item[ordstruct.seq].child_item_qual)
          pridx = (pridx+ 1), request->price_sched_items_qual = pridx, stat = alterlist(request->
           price_sched_items,pridx),
          request->price_sched_items[pridx].action_type = "ADD", request->price_sched_items[pridx].
          price_sched_id = orderable->bill_item[ordstruct.seq].price_sched_items[pidx].price_sched_id,
          request->price_sched_items[pridx].bill_item_id = orderable->bill_item[ordstruct.seq].
          child_item[cidx].bill_item_id,
          request->price_sched_items[pridx].price_ind = 1, request->price_sched_items[pridx].price =
          orderable->bill_item[ordstruct.seq].price_sched_items[pidx].price, request->
          price_sched_items[pridx].charge_level_cd = charge_level_detail,
          request->price_sched_items[pridx].detail_charge_ind_ind = 1, request->price_sched_items[
          pridx].detail_charge_ind = 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((orderable->bill_item[ordstruct.seq].bill_codes_qual > 0))
      FOR (bmidx = 1 TO orderable->bill_item[ordstruct.seq].bill_codes_qual)
        bmridx = (bmridx+ 1), request->bill_item_modifier_qual = bmridx, stat = alterlist(request->
         bill_item_modifier,bmridx),
        request->bill_item_modifier[bmridx].action_type = "DEL", request->bill_item_modifier[bmridx].
        bill_item_mod_id = orderable->bill_item[ordstruct.seq].bill_codes[bmidx].bill_item_mod_id
        FOR (cidx = 1 TO orderable->bill_item[ordstruct.seq].child_item_qual)
          bmridx = (bmridx+ 1), request->bill_item_modifier_qual = bmridx, stat = alterlist(request->
           bill_item_modifier,bmridx),
          request->bill_item_modifier[bmridx].action_type = "ADD", request->bill_item_modifier[bmridx
          ].bill_item_id = orderable->bill_item[ordstruct.seq].child_item[cidx].bill_item_id, request
          ->bill_item_modifier[bmridx].bill_item_type_cd = orderable->bill_item[ordstruct.seq].
          bill_codes[bmidx].bill_item_type_cd,
          request->bill_item_modifier[bmridx].key1 = orderable->bill_item[ordstruct.seq].bill_codes[
          bmidx].key1, request->bill_item_modifier[bmridx].key2 = orderable->bill_item[ordstruct.seq]
          .bill_codes[bmidx].key2, request->bill_item_modifier[bmridx].key3 = orderable->bill_item[
          ordstruct.seq].bill_codes[bmidx].key3,
          request->bill_item_modifier[bmridx].key4 = orderable->bill_item[ordstruct.seq].bill_codes[
          bmidx].key4
        ENDFOR
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->price_sched_items_qual > 0))
   FREE SET reply
   EXECUTE afc_ens_price_sched_item
   CALL echo("Commit Ind after afc_ens_price_sched_item: ",0)
   CALL echo(reqinfo->commit_ind)
  ENDIF
  IF ((request->bill_item_modifier_qual > 0))
   FREE SET reply
   EXECUTE afc_ens_bill_item_modifier
   CALL echo("Commit Ind after afc_ens_bill_item_modifier: ",0)
   CALL echo(reqinfo->commit_ind)
  ENDIF
 ENDIF
 FREE SET orderable
END GO
