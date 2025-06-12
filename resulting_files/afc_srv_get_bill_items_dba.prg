CREATE PROGRAM afc_srv_get_bill_items:dba
 CALL echo(concat("AFC_SRV_GET_BILL_ITEMS - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime,
    " - HH:MM:SS;;S")))
 RECORD reply(
   1 bi_count = i2
   1 bill_items[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 ext_owner_cd = f8
     2 parent_qual_cd = f8
     2 stats_only_ind = i2
     2 bim_count = i2
     2 psi_count = i2
     2 modifiers[*]
       3 bill_item_mod_id = f8
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 key2_id = f8
       3 key3_id = f8
       3 key4_id = f8
       3 key6 = vc
       3 key7 = vc
       3 key5_id = f8
       3 key11_id = f8
       3 key12_id = f8
       3 key13_id = f8
       3 key14_id = f8
       3 key15_id = f8
       3 bim1_int = i2
       3 bim2_int = i2
       3 bim1_nbr = f8
       3 bim1_ind = i2
       3 bim_ind = i2
     2 prices[*]
       3 price_sched_items_id = f8
       3 price_sched_id = f8
       3 price = f8
       3 detail_charge_ind = i2
       3 units_ind = i2
       3 interval_template_cd = f8
       3 int_count = i2
       3 intervals[*]
         4 item_interval_id = f8
         4 interval_id = f8
         4 template_cd = f8
         4 parent_entity_id = f8
         4 units = i4
         4 price = f8
         4 beg_value = f8
         4 end_value = f8
         4 unit_type_cd = f8
         4 calc_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
 )
 RECORD g_cs13019(
   1 add_on = f8
   1 charge_point = f8
   1 bill_code = f8
   1 workload = f8
 )
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ADD ON")
    g_cs13019->add_on = cv.code_value
   ELSEIF (cv.cdf_meaning="CHARGE POINT")
    g_cs13019->charge_point = cv.code_value
   ELSEIF (cv.cdf_meaning="BILL CODE")
    g_cs13019->bill_code = cv.code_value
   ELSEIF (cv.cdf_meaning="WORKLOAD")
    g_cs13019->workload = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE bi_cnt = i2
 DECLARE bim_cnt = i2
 SET bi_cnt = 0
 SELECT
  IF ((request->call_type=1))
   PLAN (bi
    WHERE (bi.bill_item_id=request->bill_item_id)
     AND bi.active_ind=1)
    JOIN (d)
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point)
     AND bim.active_ind=1)
  ELSE
   PLAN (bi
    WHERE bi.active_ind=1
     AND (((bi.ext_parent_reference_id=request->parent_id)
     AND (bi.ext_parent_contributor_cd=request->parent_cd)
     AND bi.ext_parent_reference_id > 0
     AND bi.ext_parent_contributor_cd > 0) OR (bi.ext_parent_reference_id=0
     AND bi.ext_parent_contributor_cd=0
     AND (bi.ext_child_reference_id=request->child_id)
     AND (bi.ext_child_contributor_cd=request->child_cd))) )
    JOIN (d)
    JOIN (bim
    WHERE bim.bill_item_id=bi.bill_item_id
     AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point)
     AND bim.active_ind=1)
  ENDIF
  INTO "nl:"
  bi.bill_item_id, bi.ext_parent_reference_id, bi.ext_parent_contributor_cd,
  bi.ext_child_reference_id, bi.ext_child_contributor_cd, bi.ext_description,
  bi.ext_owner_cd, bi.parent_qual_cd, bi.stats_only_ind,
  bim.bill_item_mod_id, bim.bill_item_type_cd, bim.key1_id,
  bim.key2_id, bim.key3_id, bim.key4_id,
  bim.key6, bim.key7, bim.key12_id,
  bim.key14_id, bim.key15_id, bim.bim1_int,
  bim.bim2_int, bim.bim_ind, bim.bim1_ind,
  bim.bim1_nbr
  FROM bill_item bi,
   bill_item_modifier bim,
   dummyt d
  PLAN (bi
   WHERE (((request->bill_item_id > 0)
    AND (bi.bill_item_id=request->bill_item_id)) OR ((request->bill_item_id <= 0)
    AND (((bi.ext_parent_reference_id=request->parent_id)
    AND (bi.ext_parent_contributor_cd=request->parent_cd)
    AND bi.ext_parent_reference_id > 0
    AND bi.ext_parent_contributor_cd > 0) OR (bi.ext_parent_reference_id=0
    AND bi.ext_parent_contributor_cd=0
    AND (bi.ext_child_reference_id=request->child_id)
    AND (bi.ext_child_contributor_cd=request->child_cd)))
    AND bi.active_ind=1)) )
   JOIN (d)
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point)
    AND bim.active_ind=1)
  HEAD bi.bill_item_id
   bim_cnt = 0, bi_cnt += 1, stat = alterlist(reply->bill_items,bi_cnt),
   reply->bi_count = bi_cnt, reply->bill_items[bi_cnt].bill_item_id = bi.bill_item_id, reply->
   bill_items[bi_cnt].ext_parent_reference_id = bi.ext_parent_reference_id,
   reply->bill_items[bi_cnt].ext_parent_contributor_cd = bi.ext_parent_contributor_cd, reply->
   bill_items[bi_cnt].ext_child_reference_id = bi.ext_child_reference_id, reply->bill_items[bi_cnt].
   ext_child_contributor_cd = bi.ext_child_contributor_cd,
   reply->bill_items[bi_cnt].ext_description = bi.ext_description, reply->bill_items[bi_cnt].
   ext_owner_cd = bi.ext_owner_cd, reply->bill_items[bi_cnt].parent_qual_cd = bi.parent_qual_cd,
   reply->bill_items[bi_cnt].stats_only_ind = bi.stats_only_ind
  DETAIL
   IF (bim.bill_item_type_cd > 0)
    bim_cnt += 1, stat = alterlist(reply->bill_items[bi_cnt].modifiers,bim_cnt), reply->bill_items[
    bi_cnt].bim_count = bim_cnt,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].bill_item_mod_id = bim.bill_item_mod_id, reply->
    bill_items[bi_cnt].modifiers[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd, reply->
    bill_items[bi_cnt].modifiers[bim_cnt].key1_id = bim.key1_id,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].key2_id = bim.key2_id, reply->bill_items[bi_cnt].
    modifiers[bim_cnt].key3_id = bim.key3_id, reply->bill_items[bi_cnt].modifiers[bim_cnt].key4_id =
    bim.key4_id,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].key6 = bim.key6, reply->bill_items[bi_cnt].
    modifiers[bim_cnt].key7 = bim.key7, reply->bill_items[bi_cnt].modifiers[bim_cnt].key12_id = bim
    .key12_id,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].key14_id = bim.key14_id, reply->bill_items[bi_cnt].
    modifiers[bim_cnt].key15_id = bim.key15_id, reply->bill_items[bi_cnt].modifiers[bim_cnt].bim1_int
     = bim.bim1_int,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].bim2_int = bim.bim2_int, reply->bill_items[bi_cnt].
    modifiers[bim_cnt].bim_ind = bim.bim_ind, reply->bill_items[bi_cnt].modifiers[bim_cnt].bim1_ind
     = bim.bim1_ind,
    reply->bill_items[bi_cnt].modifiers[bim_cnt].bim1_nbr = bim.bim1_nbr
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (bi_cnt > 0)
  SELECT INTO "nl:"
   bill_item_id = reply->bill_items[d.seq].bill_item_id, bim.bill_item_mod_id, bim.bill_item_type_cd,
   bim.key1_id, bim.key2_id, bim.key3_id,
   bim.key4_id, bim.key6, bim.key7,
   bim.key12_id, bim.key14_id, bim.key15_id,
   bim.bim1_int, bim.bim2_int, bim.bim_ind,
   bim.bim1_ind, bim.bim1_nbr
   FROM bill_item_modifier bim,
    (dummyt d  WITH seq = value(size(reply->bill_items,5)))
   PLAN (d)
    JOIN (bim
    WHERE (bim.bill_item_id=reply->bill_items[d.seq].bill_item_id)
     AND (bim.bill_item_type_cd=g_cs13019->bill_code)
     AND bim.active_ind=1)
   HEAD bill_item_id
    bim_cnt = size(reply->bill_items[d.seq].modifiers,5)
   DETAIL
    IF (bim.bill_item_type_cd > 0)
     bim_cnt += 1, stat = alterlist(reply->bill_items[d.seq].modifiers,bim_cnt), reply->bill_items[d
     .seq].bim_count = bim_cnt,
     reply->bill_items[d.seq].modifiers[bim_cnt].bill_item_mod_id = bim.bill_item_mod_id, reply->
     bill_items[d.seq].modifiers[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd, reply->
     bill_items[d.seq].modifiers[bim_cnt].key1_id = bim.key1_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key2_id = bim.key2_id, reply->bill_items[d.seq].
     modifiers[bim_cnt].key3_id = bim.key3_id, reply->bill_items[d.seq].modifiers[bim_cnt].key4_id =
     bim.key4_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key6 = bim.key6, reply->bill_items[d.seq].modifiers[
     bim_cnt].key7 = bim.key7, reply->bill_items[d.seq].modifiers[bim_cnt].key12_id = bim.key12_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key14_id = bim.key14_id, reply->bill_items[d.seq].
     modifiers[bim_cnt].key15_id = bim.key15_id, reply->bill_items[d.seq].modifiers[bim_cnt].bim1_int
      = bim.bim1_int,
     reply->bill_items[d.seq].modifiers[bim_cnt].bim2_int = bim.bim2_int, reply->bill_items[d.seq].
     modifiers[bim_cnt].bim_ind = bim.bim_ind, reply->bill_items[d.seq].modifiers[bim_cnt].bim1_ind
      = bim.bim1_ind,
     reply->bill_items[d.seq].modifiers[bim_cnt].bim1_nbr = bim.bim1_nbr
    ENDIF
   WITH outerjoin = d1, nocounter
  ;end select
  SELECT INTO "nl:"
   bill_item_id = reply->bill_items[d.seq].bill_item_id, bim.bill_item_mod_id, bim.bill_item_type_cd,
   bim.key1_id, bim.key2_id, bim.key3_id,
   bim.key4_id, bim.key6, bim.key7,
   bim.key12_id, bim.key14_id, bim.key15_id,
   bim.bim1_int, bim.bim2_int, bim.bim_ind,
   bim.bim1_ind, bim.bim1_nbr, wc.workload_code_id,
   wc.multiplier, wc.units
   FROM bill_item_modifier bim,
    (dummyt d  WITH seq = value(size(reply->bill_items,5))),
    workload_code wc,
    dummyt d1
   PLAN (d)
    JOIN (bim
    WHERE (bim.bill_item_id=reply->bill_items[d.seq].bill_item_id)
     AND (bim.bill_item_type_cd=g_cs13019->workload)
     AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
     AND bim.active_ind=1)
    JOIN (d1)
    JOIN (wc
    WHERE wc.workload_code_id=bim.key3_id
     AND wc.active_ind=1)
   HEAD bill_item_id
    bim_cnt = size(reply->bill_items[d.seq].modifiers,5)
   DETAIL
    IF (bim.bill_item_type_cd > 0)
     bim_cnt += 1, stat = alterlist(reply->bill_items[d.seq].modifiers,bim_cnt), reply->bill_items[d
     .seq].bim_count = bim_cnt,
     reply->bill_items[d.seq].modifiers[bim_cnt].bill_item_mod_id = bim.bill_item_mod_id, reply->
     bill_items[d.seq].modifiers[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd, reply->
     bill_items[d.seq].modifiers[bim_cnt].key1_id = bim.key1_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key2_id = bim.key2_id, reply->bill_items[d.seq].
     modifiers[bim_cnt].key3_id = bim.key3_id, reply->bill_items[d.seq].modifiers[bim_cnt].key4_id =
     bim.key4_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key6 = bim.key6, reply->bill_items[d.seq].modifiers[
     bim_cnt].key7 = bim.key7, reply->bill_items[d.seq].modifiers[bim_cnt].key12_id = bim.key12_id,
     reply->bill_items[d.seq].modifiers[bim_cnt].key14_id = bim.key14_id, reply->bill_items[d.seq].
     modifiers[bim_cnt].key15_id = bim.key15_id, reply->bill_items[d.seq].modifiers[bim_cnt].bim1_int
      = bim.bim1_int,
     reply->bill_items[d.seq].modifiers[bim_cnt].bim2_int =
     IF ((bim.bim2_int=- (1))
      AND wc.workload_code_id > 0) wc.multiplier
     ELSE bim.bim2_int
     ENDIF
     , reply->bill_items[d.seq].modifiers[bim_cnt].bim_ind = bim.bim_ind, reply->bill_items[d.seq].
     modifiers[bim_cnt].bim1_ind = bim.bim1_ind,
     reply->bill_items[d.seq].modifiers[bim_cnt].bim1_nbr =
     IF ((bim.bim1_nbr=- (1))
      AND wc.workload_code_id > 0) wc.units
     ELSE bim.bim1_nbr
     ENDIF
    ENDIF
   WITH outerjoin = d1, nocounter
  ;end select
  DECLARE psi_cnt = i2
  DECLARE int_cnt = i2
  SET psi_cnt = 0
  SET int_cnt = 0
  SELECT INTO "nl:"
   bill_item_id = reply->bill_items[d.seq].bill_item_id, psi.price_sched_items_id, psi.price_sched_id,
   psi.price, psi.detail_charge_ind, psi.units_ind,
   psi.interval_template_cd, it.beg_value, it.end_value,
   it.unit_type_cd, it.calc_type_cd, iit.price,
   iit.units, iit.interval_template_cd, iit.item_interval_id,
   iit.interval_id, iit.parent_entity_id
   FROM price_sched_items psi,
    (dummyt d  WITH seq = value(size(reply->bill_items,5))),
    item_interval_table iit,
    interval_table it,
    dummyt d1
   PLAN (d)
    JOIN (psi
    WHERE (psi.bill_item_id=reply->bill_items[d.seq].bill_item_id)
     AND psi.price_sched_id > 0
     AND psi.active_ind=1
     AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    JOIN (d1)
    JOIN (iit
    WHERE iit.interval_template_cd=psi.interval_template_cd
     AND iit.parent_entity_id=psi.price_sched_items_id
     AND iit.parent_entity_name="PRICE_SCHED_ITEMS"
     AND iit.active_ind=1)
    JOIN (it
    WHERE it.interval_id=iit.interval_id)
   HEAD bill_item_id
    psi_cnt = 0
   HEAD psi.price_sched_id
    int_cnt = 0, psi_cnt += 1, stat = alterlist(reply->bill_items[d.seq].prices,psi_cnt),
    reply->bill_items[d.seq].psi_count = psi_cnt, reply->bill_items[d.seq].prices[psi_cnt].
    price_sched_items_id = psi.price_sched_items_id, reply->bill_items[d.seq].prices[psi_cnt].
    price_sched_id = psi.price_sched_id,
    reply->bill_items[d.seq].prices[psi_cnt].price = psi.price, reply->bill_items[d.seq].prices[
    psi_cnt].detail_charge_ind = psi.detail_charge_ind, reply->bill_items[d.seq].prices[psi_cnt].
    units_ind = psi.units_ind,
    reply->bill_items[d.seq].prices[psi_cnt].interval_template_cd = psi.interval_template_cd
   DETAIL
    IF (iit.parent_entity_id > 0)
     int_cnt += 1, stat = alterlist(reply->bill_items[d.seq].prices[psi_cnt].intervals,int_cnt),
     reply->bill_items[d.seq].prices[psi_cnt].int_count = int_cnt,
     reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].item_interval_id = iit
     .item_interval_id, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].interval_id = iit
     .interval_id, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].parent_entity_id = iit
     .parent_entity_id,
     reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].template_cd = iit
     .interval_template_cd, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].beg_value =
     it.beg_value, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].end_value = it
     .end_value,
     reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].price = iit.price, reply->
     bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].unit_type_cd = it.unit_type_cd, reply->
     bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].calc_type_cd = it.calc_type_cd,
     reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].units = iit.units
    ENDIF
   WITH outerjoin = d1, nocounter
  ;end select
 ENDIF
END GO
