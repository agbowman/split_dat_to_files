CREATE PROGRAM cs_srv_get_bill_items
 DECLARE cs_srv_get_bill_items_version = vc WITH private, noconstant("CHARGSRV-12566.016")
 CALL echo(concat("CS_SRV_GET_BILL_ITEMS - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
 DECLARE bi_cnt = i2
 DECLARE bim_cnt = i2
 DECLARE psi_cnt = i2
 DECLARE int_cnt = i2
 DECLARE locval = i2
 DECLARE expval = i2
 DECLARE msstat = f8 WITH protect, noconstant(0.0)
 DECLARE noncoveredvalue = f8 WITH protect, noconstant(validate(g_cs13019->noncovered,- (0.0000001)))
 SUBROUTINE (setkey7field(dummyvar=vc) =null)
   IF (bim.bill_item_type_cd=noncoveredvalue)
    IF (validate(reply->bill_items[d1.seq].bill_mods[bim_cnt].key7_ext))
     SET reply->bill_items[d1.seq].bill_mods[bim_cnt].key7_ext = bim.key7
    ELSE
     SET reply->bill_items[d1.seq].bill_mods[bim_cnt].key7 = bim.key7
    ENDIF
   ELSE
    SET reply->bill_items[d1.seq].bill_mods[bim_cnt].key7 = bim.key7
   ENDIF
 END ;Subroutine
 SET bi_cnt = 0
 IF ((reply->load_cache=1))
  CALL echorecord(g_srvproperties)
  SELECT INTO "nl:"
   b.bill_item_id
   FROM bill_item b
   WHERE b.num_hits > 0
    AND b.active_ind=1
   ORDER BY b.num_hits DESC
   HEAD REPORT
    bi_cnt = 0
   DETAIL
    bi_cnt += 1
    IF (mod(bi_cnt,100)=1)
     stat = alterlist(reply->bill_items,(bi_cnt+ 100))
    ENDIF
    reply->bill_items[bi_cnt].bill_item_id = b.bill_item_id
   FOOT REPORT
    stat = alterlist(reply->bill_items,bi_cnt)
   WITH maxrec = value(g_srvproperties->billcachesize)
  ;end select
 ELSE
  SET bi_cnt = size(reply->bill_items,5)
 ENDIF
 IF (bi_cnt > 0)
  CALL echo("Read bill items, charge points, bill codes, coverage schedules and addons")
  SELECT
   IF ((validate(reply->process_type_cd,0.0)=g_cs13029->nocommit))
    FROM (dummyt d1  WITH seq = value(bi_cnt)),
     bill_item bi,
     bill_item_modifier bim,
     dummyt d
    PLAN (d1)
     JOIN (bi
     WHERE (reply->bill_items[d1.seq].bill_item_id > 0)
      AND (bi.bill_item_id=reply->bill_items[d1.seq].bill_item_id)
      AND bi.active_ind IN (0, 1)
      AND (((bi.logical_domain_id=reply->bill_items[d1.seq].logical_domain_id)
      AND bi.logical_domain_enabled_ind=true) OR (bi.logical_domain_enabled_ind=false)) )
     JOIN (d)
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point, g_cs13019->bill_code,
     noncoveredvalue)
      AND bim.active_ind=1)
   ELSE
    FROM (dummyt d1  WITH seq = value(bi_cnt)),
     bill_item bi,
     bill_item_modifier bim,
     dummyt d
    PLAN (d1)
     JOIN (bi
     WHERE (reply->bill_items[d1.seq].bill_item_id > 0)
      AND (bi.bill_item_id=reply->bill_items[d1.seq].bill_item_id)
      AND bi.active_ind=1
      AND (((bi.logical_domain_id=reply->bill_items[d1.seq].logical_domain_id)
      AND bi.logical_domain_enabled_ind=true) OR (bi.logical_domain_enabled_ind=false)) )
     JOIN (d)
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point, g_cs13019->bill_code,
     noncoveredvalue)
      AND bim.active_ind=1)
   ENDIF
   INTO "nl:"
   HEAD d1.seq
    bim_cnt = 0, reply->bill_items[d1.seq].bill_item_id = bi.bill_item_id, reply->bill_items[d1.seq].
    parent_ref_id = bi.ext_parent_reference_id,
    reply->bill_items[d1.seq].parent_ref_cd = bi.ext_parent_contributor_cd, reply->bill_items[d1.seq]
    .child_ref_id = bi.ext_child_reference_id, reply->bill_items[d1.seq].child_ref_cd = bi
    .ext_child_contributor_cd,
    reply->bill_items[d1.seq].description = bi.ext_description, reply->bill_items[d1.seq].owner_cd =
    bi.ext_owner_cd, msstat = assign(validate(reply->bill_items[d1.seq].sub_owner_cd,0.0),bi
     .ext_sub_owner_cd),
    reply->bill_items[d1.seq].workload_only_ind = bi.workload_only_ind, reply->bill_items[d1.seq].
    parent_qual_ind = bi.parent_qual_cd, reply->bill_items[d1.seq].stats_only_ind = bi.stats_only_ind,
    msstat = assign(validate(reply->bill_items[d1.seq].logical_domain_id,0.0),bi.logical_domain_id),
    msstat = assign(validate(reply->bill_items[d1.seq].logical_domain_enabled_ind,0.0),bi
     .logical_domain_enabled_ind)
   DETAIL
    IF (bim.bill_item_type_cd > 0)
     bim_cnt += 1
     IF (mod(bim_cnt,10)=1)
      stat = alterlist(reply->bill_items[d1.seq].bill_mods,(bim_cnt+ 10))
     ENDIF
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd, reply->
     bill_items[d1.seq].bill_mods[bim_cnt].key1_id = bim.key1_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key2_id = bim.key2_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key3_id = bim.key3_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key4_id = bim.key4_id, reply->bill_items[d1.seq].bill_mods[bim_cnt].key5_id
      = bim.key5_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key6 = bim.key6,
     CALL setkey7field("NULL"), reply->bill_items[d1.seq].bill_mods[bim_cnt].key12_id = bim.key12_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key14_id = bim.key14_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key15_id = bim.key15_id, reply->bill_items[d1.seq].bill_mods[bim_cnt].
     bim1_int = bim.bim1_int,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bim2_int = bim.bim2_int, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].bim_ind = bim.bim_ind, reply->bill_items[d1.seq].bill_mods[bim_cnt].bim1_ind
      = bim.bim1_ind,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bim1_nbr = bim.bim1_nbr, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].beg_effective_dt_tm = bim.beg_effective_dt_tm, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].end_effective_dt_tm = bim.end_effective_dt_tm
    ENDIF
   FOOT  d1.seq
    stat = alterlist(reply->bill_items[d1.seq].bill_mods,bim_cnt)
   WITH outerjoin = d, nocounter
  ;end select
  CALL echo("Read bill items, charge points, bill codes, coverage schedules and addons")
  SELECT
   IF ((validate(reply->process_type_cd,0.0)=g_cs13029->nocommit))
    FROM (dummyt d1  WITH seq = value(bi_cnt)),
     bill_item bi,
     bill_item_modifier bim,
     dummyt d
    PLAN (d1)
     JOIN (bi
     WHERE (reply->bill_items[d1.seq].bill_item_id <= 0)
      AND (bi.ext_parent_reference_id=reply->bill_items[d1.seq].parent_ref_id)
      AND (bi.ext_parent_contributor_cd=reply->bill_items[d1.seq].parent_ref_cd)
      AND ((bi.ext_child_reference_id+ 0)=reply->bill_items[d1.seq].child_ref_id)
      AND (bi.ext_child_contributor_cd=reply->bill_items[d1.seq].child_ref_cd)
      AND bi.active_ind IN (0, 1)
      AND (((bi.logical_domain_id=reply->bill_items[d1.seq].logical_domain_id)
      AND bi.logical_domain_enabled_ind=true) OR (bi.logical_domain_enabled_ind=false)) )
     JOIN (d)
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point, g_cs13019->bill_code,
     noncoveredvalue)
      AND bim.active_ind=1)
   ELSE
    FROM (dummyt d1  WITH seq = value(bi_cnt)),
     bill_item bi,
     bill_item_modifier bim,
     dummyt d
    PLAN (d1)
     JOIN (bi
     WHERE (reply->bill_items[d1.seq].bill_item_id <= 0)
      AND (bi.ext_parent_reference_id=reply->bill_items[d1.seq].parent_ref_id)
      AND (bi.ext_parent_contributor_cd=reply->bill_items[d1.seq].parent_ref_cd)
      AND ((bi.ext_child_reference_id+ 0)=reply->bill_items[d1.seq].child_ref_id)
      AND (bi.ext_child_contributor_cd=reply->bill_items[d1.seq].child_ref_cd)
      AND bi.active_ind=1
      AND (((bi.logical_domain_id=reply->bill_items[d1.seq].logical_domain_id)
      AND bi.logical_domain_enabled_ind=true) OR (bi.logical_domain_enabled_ind=false)) )
     JOIN (d)
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND bim.bill_item_type_cd IN (g_cs13019->add_on, g_cs13019->charge_point, g_cs13019->bill_code,
     noncoveredvalue)
      AND bim.active_ind=1)
   ENDIF
   INTO "nl:"
   HEAD d1.seq
    bim_cnt = 0, reply->bill_items[d1.seq].bill_item_id = bi.bill_item_id, reply->bill_items[d1.seq].
    parent_ref_id = bi.ext_parent_reference_id,
    reply->bill_items[d1.seq].parent_ref_cd = bi.ext_parent_contributor_cd, reply->bill_items[d1.seq]
    .child_ref_id = bi.ext_child_reference_id, reply->bill_items[d1.seq].child_ref_cd = bi
    .ext_child_contributor_cd,
    reply->bill_items[d1.seq].description = bi.ext_description, reply->bill_items[d1.seq].owner_cd =
    bi.ext_owner_cd, msstat = assign(validate(reply->bill_items[d1.seq].sub_owner_cd,0.0),bi
     .ext_sub_owner_cd),
    reply->bill_items[d1.seq].workload_only_ind = bi.workload_only_ind, reply->bill_items[d1.seq].
    parent_qual_ind = bi.parent_qual_cd, reply->bill_items[d1.seq].stats_only_ind = bi.stats_only_ind,
    msstat = assign(validate(reply->bill_items[d1.seq].logical_domain_id,0.0),bi.logical_domain_id),
    msstat = assign(validate(reply->bill_items[d1.seq].logical_domain_enabled_ind,0.0),bi
     .logical_domain_enabled_ind)
   DETAIL
    IF (bim.bill_item_type_cd > 0)
     bim_cnt += 1
     IF (mod(bim_cnt,10)=1)
      stat = alterlist(reply->bill_items[d1.seq].bill_mods,(bim_cnt+ 10))
     ENDIF
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd, reply->
     bill_items[d1.seq].bill_mods[bim_cnt].key1_id = bim.key1_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key2_id = bim.key2_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key3_id = bim.key3_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key4_id = bim.key4_id, reply->bill_items[d1.seq].bill_mods[bim_cnt].key5_id
      = bim.key5_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key6 = bim.key6,
     CALL setkey7field("NULL"), reply->bill_items[d1.seq].bill_mods[bim_cnt].key12_id = bim.key12_id,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].key14_id = bim.key14_id, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].key15_id = bim.key15_id, reply->bill_items[d1.seq].bill_mods[bim_cnt].
     bim1_int = bim.bim1_int,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bim2_int = bim.bim2_int, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].bim_ind = bim.bim_ind, reply->bill_items[d1.seq].bill_mods[bim_cnt].bim1_ind
      = bim.bim1_ind,
     reply->bill_items[d1.seq].bill_mods[bim_cnt].bim1_nbr = bim.bim1_nbr, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].beg_effective_dt_tm = bim.beg_effective_dt_tm, reply->bill_items[d1.seq].
     bill_mods[bim_cnt].end_effective_dt_tm = bim.end_effective_dt_tm
    ENDIF
   FOOT  d1.seq
    stat = alterlist(reply->bill_items[d1.seq].bill_mods,bim_cnt)
   WITH outerjoin = d, nocounter
  ;end select
  IF (bi_cnt > 0)
   DECLARE child_cnt = i2
   CALL echo("Look up child bill items")
   SELECT
    IF ((validate(reply->process_type_cd,0.0)=g_cs13029->nocommit))
     bill_item_id = reply->bill_items[d.seq].bill_item_id, b.bill_item_id, b.ext_parent_reference_id,
     b.ext_parent_contributor_cd, b.ext_child_reference_id, b.ext_child_contributor_cd
     FROM bill_item b,
      (dummyt d  WITH seq = value(bi_cnt))
     PLAN (d
      WHERE (reply->bill_items[d.seq].parent_ref_id > 0)
       AND (reply->bill_items[d.seq].parent_ref_cd > 0)
       AND (reply->bill_items[d.seq].child_ref_id=0)
       AND (reply->bill_items[d.seq].child_ref_cd=0)
       AND (reply->bill_items[d.seq].bill_item_id > 0))
      JOIN (b
      WHERE (b.ext_parent_reference_id=reply->bill_items[d.seq].parent_ref_id)
       AND (b.ext_parent_contributor_cd=reply->bill_items[d.seq].parent_ref_cd)
       AND b.ext_child_reference_id > 0
       AND b.ext_child_contributor_cd > 0
       AND b.active_ind IN (0, 1)
       AND (((b.logical_domain_id=reply->bill_items[d.seq].logical_domain_id)
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ELSE
     bill_item_id = reply->bill_items[d.seq].bill_item_id, b.bill_item_id, b.ext_parent_reference_id,
     b.ext_parent_contributor_cd, b.ext_child_reference_id, b.ext_child_contributor_cd
     FROM bill_item b,
      (dummyt d  WITH seq = value(bi_cnt))
     PLAN (d
      WHERE (reply->bill_items[d.seq].parent_ref_id > 0)
       AND (reply->bill_items[d.seq].parent_ref_cd > 0)
       AND (reply->bill_items[d.seq].child_ref_id=0)
       AND (reply->bill_items[d.seq].child_ref_cd=0)
       AND (reply->bill_items[d.seq].bill_item_id > 0))
      JOIN (b
      WHERE (b.ext_parent_reference_id=reply->bill_items[d.seq].parent_ref_id)
       AND (b.ext_parent_contributor_cd=reply->bill_items[d.seq].parent_ref_cd)
       AND b.ext_child_reference_id > 0
       AND b.ext_child_contributor_cd > 0
       AND b.active_ind=1
       AND (((b.logical_domain_id=reply->bill_items[d.seq].logical_domain_id)
       AND b.logical_domain_enabled_ind=true) OR (b.logical_domain_enabled_ind=false)) )
    ENDIF
    INTO "nl:"
    HEAD d.seq
     child_cnt = 0
    DETAIL
     child_cnt += 1
     IF (mod(child_cnt,10)=1)
      stat = alterlist(reply->bill_items[d.seq].child_items,(child_cnt+ 10))
     ENDIF
     reply->bill_items[d.seq].child_items[child_cnt].bill_item_id = b.bill_item_id, reply->
     bill_items[d.seq].child_items[child_cnt].parent_id = b.ext_parent_reference_id, reply->
     bill_items[d.seq].child_items[child_cnt].parent_cd = b.ext_parent_contributor_cd,
     reply->bill_items[d.seq].child_items[child_cnt].child_id = b.ext_child_reference_id, reply->
     bill_items[d.seq].child_items[child_cnt].child_cd = b.ext_child_contributor_cd
    FOOT  d.seq
     stat = alterlist(reply->bill_items[d.seq].child_items,child_cnt)
    WITH nocounter
   ;end select
   IF ((g_srvproperties->workloadind=1))
    CALL echo("Read workload items")
    SELECT INTO "nl:"
     bill_item_id = reply->bill_items[d.seq].bill_item_id
     FROM bill_item_modifier bim,
      (dummyt d  WITH seq = value(bi_cnt)),
      workload_code wc,
      dummyt d1
     PLAN (d)
      JOIN (bim
      WHERE (bim.bill_item_id=reply->bill_items[d.seq].bill_item_id)
       AND (bim.bill_item_type_cd=g_cs13019->workload)
       AND bim.active_ind=1)
      JOIN (d1)
      JOIN (wc
      WHERE wc.workload_code_id=bim.key3_id
       AND wc.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      bim_cnt = size(reply->bill_items[d.seq].bill_mods,5)
     DETAIL
      IF (bim.bill_item_type_cd > 0)
       bim_cnt += 1, stat = alterlist(reply->bill_items[d.seq].bill_mods,bim_cnt), reply->bill_items[
       d.seq].bill_mods[bim_cnt].bill_item_type_cd = bim.bill_item_type_cd,
       reply->bill_items[d.seq].bill_mods[bim_cnt].key1_id = bim.key1_id, reply->bill_items[d.seq].
       bill_mods[bim_cnt].key2_id = bim.key2_id, reply->bill_items[d.seq].bill_mods[bim_cnt].key3_id
        = bim.key3_id,
       reply->bill_items[d.seq].bill_mods[bim_cnt].key4_id = bim.key4_id, reply->bill_items[d.seq].
       bill_mods[bim_cnt].key6 = bim.key6, reply->bill_items[d.seq].bill_mods[bim_cnt].key7 = bim
       .key7,
       reply->bill_items[d.seq].bill_mods[bim_cnt].key12_id = bim.key12_id, reply->bill_items[d.seq].
       bill_mods[bim_cnt].key14_id = bim.key14_id, reply->bill_items[d.seq].bill_mods[bim_cnt].
       key15_id = bim.key15_id,
       reply->bill_items[d.seq].bill_mods[bim_cnt].bim1_int = bim.bim1_int, reply->bill_items[d.seq].
       bill_mods[bim_cnt].bim2_int =
       IF ((bim.bim2_int=- (1))
        AND wc.workload_code_id > 0) wc.multiplier
       ELSE bim.bim2_int
       ENDIF
       , reply->bill_items[d.seq].bill_mods[bim_cnt].bim_ind = bim.bim_ind,
       reply->bill_items[d.seq].bill_mods[bim_cnt].bim1_ind = bim.bim1_ind, reply->bill_items[d.seq].
       bill_mods[bim_cnt].bim1_nbr =
       IF ((bim.bim1_nbr=- (1))
        AND wc.workload_code_id > 0) wc.units
       ELSE bim.bim1_nbr
       ENDIF
       , reply->bill_items[d.seq].bill_mods[bim_cnt].beg_effective_dt_tm = wc.beg_effective_dt_tm,
       reply->bill_items[d.seq].bill_mods[bim_cnt].end_effective_dt_tm = wc.end_effective_dt_tm
      ENDIF
     WITH outerjoin = d1, nocounter
    ;end select
   ENDIF
   CALL echo("Read price information")
   SELECT INTO "nl:"
    bill_item_id = reply->bill_items[d.seq].bill_item_id
    FROM price_sched_items psi,
     (dummyt d  WITH seq = value(bi_cnt)),
     item_interval_table iit,
     interval_table it,
     dummyt d1,
     bill_item_modifier bim,
     dummyt d2
    PLAN (d
     WHERE (reply->bill_items[d.seq].bill_item_id > 0))
     JOIN (psi
     WHERE (psi.bill_item_id=reply->bill_items[d.seq].bill_item_id)
      AND psi.price_sched_id > 0
      AND psi.active_ind=1
      AND psi.beg_effective_dt_tm < psi.end_effective_dt_tm)
     JOIN (d1)
     JOIN (iit
     WHERE iit.interval_template_cd=psi.interval_template_cd
      AND iit.parent_entity_id=psi.price_sched_items_id
      AND iit.parent_entity_name="PRICE_SCHED_ITEMS"
      AND iit.active_ind=1)
     JOIN (it
     WHERE it.interval_id=iit.interval_id)
     JOIN (d2)
     JOIN (bim
     WHERE bim.bill_item_id=psi.bill_item_id
      AND (bim.bill_item_type_cd=g_cs13019->intervalcode)
      AND bim.key2_id=iit.item_interval_id)
    ORDER BY d.seq, psi.bill_item_id, psi.price_sched_items_id,
     psi.interval_template_cd, it.beg_value
    HEAD d.seq
     psi_cnt = 0
    HEAD psi.price_sched_items_id
     int_cnt = 0
     IF (psi.price_sched_items_id > 0)
      psi_cnt += 1, stat = alterlist(reply->bill_items[d.seq].prices,psi_cnt), reply->bill_items[d
      .seq].prices[psi_cnt].price_sched_id = psi.price_sched_id,
      reply->bill_items[d.seq].prices[psi_cnt].price = psi.price, reply->bill_items[d.seq].prices[
      psi_cnt].detail_charge_ind = psi.detail_charge_ind, reply->bill_items[d.seq].prices[psi_cnt].
      units_ind = psi.units_ind,
      reply->bill_items[d.seq].prices[psi_cnt].interval_template_cd = psi.interval_template_cd, reply
      ->bill_items[d.seq].prices[psi_cnt].beg_effective_dt_tm = psi.beg_effective_dt_tm, reply->
      bill_items[d.seq].prices[psi_cnt].end_effective_dt_tm = psi.end_effective_dt_tm,
      reply->bill_items[d.seq].prices[psi_cnt].stats_only_ind = psi.stats_only_ind
     ENDIF
    HEAD iit.item_interval_id
     bim_cnt = 0
     IF (psi.price_sched_items_id > 0
      AND iit.parent_entity_id > 0)
      int_cnt += 1, stat = alterlist(reply->bill_items[d.seq].prices[psi_cnt].intervals,int_cnt),
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].item_interval_id = iit
      .item_interval_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].beg_value = it.beg_value, reply->
      bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].end_value = it.end_value, reply->
      bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].price = iit.price,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].unit_type_cd = it.unit_type_cd,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].calc_type_cd = it.calc_type_cd,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].units = iit.units
     ENDIF
    DETAIL
     IF (psi.price_sched_items_id > 0
      AND iit.parent_entity_id > 0
      AND bim.bill_item_mod_id > 0)
      bim_cnt += 1, stat = alterlist(reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods,
       bim_cnt), reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].
      bill_item_type_cd = bim.bill_item_type_cd,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key1_id = bim.key1_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key2_id = bim.key2_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key3_id = bim.key3_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key4_id = bim.key4_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key5_id = bim.key5_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key6 = bim.key6,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key7 = bim.key7,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key12_id = bim
      .key12_id, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key14_id
       = bim.key14_id,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].key15_id = bim
      .key15_id, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].bim1_int
       = bim.bim1_int, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].
      bim2_int = bim.bim2_int,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].bim_ind = bim.bim_ind,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].bim1_ind = bim
      .bim1_ind, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].bim1_nbr
       = bim.bim1_nbr,
      reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[bim_cnt].beg_effective_dt_tm
       = bim.beg_effective_dt_tm, reply->bill_items[d.seq].prices[psi_cnt].intervals[int_cnt].mods[
      bim_cnt].end_effective_dt_tm = bim.end_effective_dt_tm
     ENDIF
    WITH outerjoin = d1, outerjoin = d2, nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
