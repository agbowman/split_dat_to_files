CREATE PROGRAM afc_rdm_upt_generic_addonbitem:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script afc_rdm_upt_generic_addonbitem.prg..."
 FREE RECORD logicaldomain
 RECORD logicaldomain(
   1 logicaldomains[*]
     2 logicaldomainid = f8
 )
 FREE RECORD addonbillitems
 RECORD addonbillitems(
   1 billitems[*]
     2 billitemid = f8
     2 newbillitemid = f8
     2 extparentreferenceid = f8
     2 extparentcontributorcd = f8
     2 extchildreferenceid = f8
     2 extchildcontributorcd = f8
     2 extdescription = vc
     2 extshortdescription = vc
     2 extownercd = f8
     2 parentqualcd = f8
     2 chargepointcd = f8
     2 workloadind = i2
     2 activeind = i2
     2 activestatuscd = f8
     2 activestatusprnslid = f8
     2 extparententityname = vc
     2 extchildentityname = vc
     2 miscind = i2
     2 statsonlyind = i2
     2 childseq = i4
     2 logicaldomainid = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD addonbillitemmods
 RECORD addonbillitemmods(
   1 billitemmods[*]
     2 billitemmodid = f8
     2 newbillitemmodid = f8
     2 billitemid = f8
     2 newbillitemid = f8
 )
 FREE RECORD pricescheditems
 RECORD pricescheditems(
   1 billitemids[*]
     2 billitemid = f8
     2 newbillitemid = f8
     2 pricescheditemid = f8
     2 newpricescheditemid = f8
 )
 FREE RECORD parentbillitemmods
 RECORD parentbillitemmods(
   1 billitemmods[*]
     2 billitemmodid = f8
     2 newbillitemmodid = f8
     2 billitemid = f8
     2 newbillitemid = f8
     2 billitemtypecd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key6 = vc
     2 bim1int = f8
     2 activeind = i2
     2 activestatuscd = f8
     2 activestatusprnslid = f8
     2 key1entityname = vc
     2 key2entityname = vc
     2 logicaldomainid = f8
     2 logicaldomainenabledind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 DECLARE updateaddonbillitem(plogicaldomainid=f8) = null
 DECLARE updateaddonbillitemmodifier(plogicaldomainid=f8) = null
 DECLARE addbillitem(plogicaldomainid=f8) = f8
 DECLARE addbillitemmodifier(plogicaldomainid=f8) = null
 DECLARE addaddonbillitemmodifier(plogicaldomainid=f8) = null
 DECLARE addaddonbillitempricesched(dummyvar=i2) = null
 DECLARE updatenonsharedbillitem(dummyvar=i2) = null
 DECLARE errmsg = vc WITH protect
 DECLARE cntlogicaldomain = i4 WITH protect, noconstant(0)
 DECLARE cntbillitem = i4 WITH protect, noconstant(0)
 DECLARE cntbillitemmod = i4 WITH protect, noconstant(0)
 DECLARE cntpricesched = i4 WITH protect, noconstant(0)
 DECLARE cs106_generic_addon_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM logical_domain
  WHERE logical_domain_id > 0.0
   AND ((active_ind+ 0)=true)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to check if LogicalDomain is in Use:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = build("Success: LogicalDomain Not in Use")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM logical_domain l
  WHERE l.logical_domain_id >= 0.0
   AND ((l.active_ind+ 0)=true)
  ORDER BY l.logical_domain_id
  DETAIL
   cntlogicaldomain = (cntlogicaldomain+ 1), stat = alterlist(logicaldomain->logicaldomains,
    cntlogicaldomain), logicaldomain->logicaldomains[cntlogicaldomain].logicaldomainid = l
   .logical_domain_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to get active logical domains:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = build("Success: No Logical Domain Found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="AFC ADD GEN"
   AND ((cv.active_ind+ 0)=1)
  DETAIL
   cs106_generic_addon_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to get the code value for AFC ADD GEN from Code Set 106:",
   errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bill_item b,
   bill_item_modifier bim
  PLAN (b
   WHERE b.bill_item_id > 0.0
    AND b.ext_owner_cd=cs106_generic_addon_cd
    AND b.ext_parent_reference_id > 0.0
    AND ((b.active_ind+ 0)=true)
    AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (bim
   WHERE bim.bill_item_id=outerjoin(b.bill_item_id)
    AND ((bim.active_ind+ 0)=outerjoin(true))
    AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND bim.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY b.bill_item_id
  HEAD b.bill_item_id
   cntbillitem = (cntbillitem+ 1), stat = alterlist(addonbillitems->billitems,cntbillitem),
   addonbillitems->billitems[cntbillitem].activeind = b.active_ind,
   addonbillitems->billitems[cntbillitem].activestatuscd = b.active_status_cd, addonbillitems->
   billitems[cntbillitem].activestatusprnslid = b.active_status_prsnl_id, addonbillitems->billitems[
   cntbillitem].billitemid = b.bill_item_id,
   addonbillitems->billitems[cntbillitem].chargepointcd = b.charge_point_cd, addonbillitems->
   billitems[cntbillitem].childseq = b.child_seq, addonbillitems->billitems[cntbillitem].
   extchildcontributorcd = b.ext_child_contributor_cd,
   addonbillitems->billitems[cntbillitem].extchildentityname = b.ext_child_entity_name,
   addonbillitems->billitems[cntbillitem].extchildreferenceid = b.ext_child_reference_id,
   addonbillitems->billitems[cntbillitem].extdescription = b.ext_description,
   addonbillitems->billitems[cntbillitem].extownercd = b.ext_owner_cd, addonbillitems->billitems[
   cntbillitem].extparentcontributorcd = b.ext_parent_contributor_cd, addonbillitems->billitems[
   cntbillitem].extparententityname = b.ext_parent_entity_name,
   addonbillitems->billitems[cntbillitem].extparentreferenceid = b.ext_parent_reference_id,
   addonbillitems->billitems[cntbillitem].extshortdescription = b.ext_short_desc, addonbillitems->
   billitems[cntbillitem].miscind = b.misc_ind,
   addonbillitems->billitems[cntbillitem].parentqualcd = b.parent_qual_cd, addonbillitems->billitems[
   cntbillitem].statsonlyind = b.stats_only_ind, addonbillitems->billitems[cntbillitem].workloadind
    = b.workload_only_ind,
   addonbillitems->billitems[cntbillitem].billitemid = b.bill_item_id, addonbillitems->billitems[
   cntbillitem].beg_effective_dt_tm = b.beg_effective_dt_tm, addonbillitems->billitems[cntbillitem].
   end_effective_dt_tm = b.end_effective_dt_tm
  DETAIL
   IF (bim.bill_item_mod_id > 0.0)
    cntbillitemmod = (cntbillitemmod+ 1), stat = alterlist(addonbillitemmods->billitemmods,
     cntbillitemmod), addonbillitemmods->billitemmods[cntbillitemmod].billitemid = bim.bill_item_id,
    addonbillitemmods->billitemmods[cntbillitemmod].billitemmodid = bim.bill_item_mod_id
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build(
   "Failed to get Generic Add-On Billitem and it's Modifier information:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = build("Success: No Generic Addon BillItems Found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bill_item b,
   price_sched_items p
  PLAN (b
   WHERE b.bill_item_id > 0.0
    AND b.ext_owner_cd=cs106_generic_addon_cd
    AND b.ext_parent_reference_id > 0.0
    AND ((b.active_ind+ 0)=true)
    AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.bill_item_id=b.bill_item_id
    AND p.price_sched_items_id > 0.0
    AND ((p.active_ind+ 0)=true)
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD p.price_sched_items_id
   cntpricesched = (cntpricesched+ 1), stat = alterlist(pricescheditems->billitemids,cntpricesched),
   pricescheditems->billitemids[cntpricesched].billitemid = p.bill_item_id,
   pricescheditems->billitemids[cntpricesched].pricescheditemid = p.price_sched_items_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to get generic add-on bill item price sched items:",errmsg
   )
  GO TO exit_script
 ENDIF
 SET cntbillitemmod = 0
 SELECT INTO "nl:"
  FROM bill_item b,
   bill_item_modifier bim,
   bill_item b1
  PLAN (b
   WHERE b.bill_item_id > 0.0
    AND b.ext_owner_cd=cs106_generic_addon_cd
    AND b.ext_parent_reference_id > 0.0
    AND ((b.active_ind+ 0)=true)
    AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (bim
   WHERE bim.key1_id=b.bill_item_id
    AND bim.bill_item_mod_id > 0.0
    AND bim.key2_id=cs106_generic_addon_cd
    AND ((bim.active_ind+ 0)=true)
    AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (b1
   WHERE b1.bill_item_id=bim.bill_item_id
    AND ((b1.active_ind+ 0)=true)
    AND b1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD bim.bill_item_mod_id
   cntbillitemmod = (cntbillitemmod+ 1), stat = alterlist(parentbillitemmods->billitemmods,
    cntbillitemmod), parentbillitemmods->billitemmods[cntbillitemmod].activeind = bim.active_ind,
   parentbillitemmods->billitemmods[cntbillitemmod].activestatuscd = bim.active_status_cd,
   parentbillitemmods->billitemmods[cntbillitemmod].activestatusprnslid = bim.active_status_prsnl_id,
   parentbillitemmods->billitemmods[cntbillitemmod].billitemid = bim.bill_item_id,
   parentbillitemmods->billitemmods[cntbillitemmod].billitemmodid = bim.bill_item_mod_id,
   parentbillitemmods->billitemmods[cntbillitemmod].billitemtypecd = bim.bill_item_type_cd,
   parentbillitemmods->billitemmods[cntbillitemmod].bim1int = bim.bim1_int,
   parentbillitemmods->billitemmods[cntbillitemmod].key1_id = bim.key1_id, parentbillitemmods->
   billitemmods[cntbillitemmod].key2_id = bim.key2_id, parentbillitemmods->billitemmods[
   cntbillitemmod].key1entityname = bim.key1_entity_name,
   parentbillitemmods->billitemmods[cntbillitemmod].key2entityname = bim.key2_entity_name,
   parentbillitemmods->billitemmods[cntbillitemmod].key6 = bim.key6, parentbillitemmods->
   billitemmods[cntbillitemmod].beg_effective_dt_tm = bim.beg_effective_dt_tm,
   parentbillitemmods->billitemmods[cntbillitemmod].end_effective_dt_tm = bim.end_effective_dt_tm,
   parentbillitemmods->billitemmods[cntbillitemmod].logicaldomainenabledind = b1
   .logical_domain_enabled_ind, parentbillitemmods->billitemmods[cntbillitemmod].logicaldomainid = b1
   .logical_domain_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to get BillItems which has Addon as it's modifier:",errmsg
   )
  GO TO exit_script
 ENDIF
 IF (size(logicaldomain->logicaldomains,5) > 0)
  IF (size(addonbillitems->billitems,5) > 0)
   CALL updateaddonbillitem(logicaldomain->logicaldomains[1].logicaldomainid)
   CALL updateaddonbillitemmodifier(logicaldomain->logicaldomains[1].logicaldomainid)
   FOR (cntlogicaldomain = 2 TO size(logicaldomain->logicaldomains,5))
     CALL addbillitem(logicaldomain->logicaldomains[cntlogicaldomain].logicaldomainid)
     CALL addbillitemmodifier(logicaldomain->logicaldomains[cntlogicaldomain].logicaldomainid)
     CALL addaddonbillitemmodifier(logicaldomain->logicaldomains[cntlogicaldomain].logicaldomainid)
     CALL addaddonbillitempricesched(0)
   ENDFOR
   CALL updatenonsharedbillitem(1)
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 COMMIT
 GO TO exit_script
 SUBROUTINE updateaddonbillitem(plogicaldomainid)
   UPDATE  FROM bill_item bi,
     (dummyt dt  WITH seq = value(size(addonbillitems->billitems,5)))
    SET bi.logical_domain_id = plogicaldomainid, bi.logical_domain_enabled_ind = true, bi
     .updt_applctx = reqinfo->updt_applctx,
     bi.updt_cnt = (bi.updt_cnt+ 1), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id =
     reqinfo->updt_id,
     bi.updt_task = reqinfo->updt_task
    PLAN (dt)
     JOIN (bi
     WHERE (bi.bill_item_id=addonbillitems->billitems[dt.seq].billitemid))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update Addon BillItem: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (size(addonbillitemmods->billitemmods,5) > 0)
    UPDATE  FROM bill_item_modifier bim,
      (dummyt dt  WITH seq = value(size(addonbillitemmods->billitemmods,5)))
     SET bim.key3_id = plogicaldomainid, bim.updt_applctx = reqinfo->updt_applctx, bim.updt_cnt = (
      bim.updt_cnt+ 1),
      bim.updt_dt_tm = cnvtdatetime(curdate,curtime3), bim.updt_id = reqinfo->updt_id, bim.updt_task
       = reqinfo->updt_task
     PLAN (dt)
      JOIN (bim
      WHERE (bim.bill_item_mod_id=addonbillitemmods->billitemmods[dt.seq].billitemmodid))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update Addon BillItem Modifier: ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updateaddonbillitemmodifier(plogicaldomainid)
   IF (size(parentbillitemmods->billitemmods,5) > 0)
    UPDATE  FROM bill_item_modifier bim,
      (dummyt dt  WITH seq = value(size(parentbillitemmods->billitemmods,5)))
     SET bim.key3_id = plogicaldomainid, bim.updt_applctx = reqinfo->updt_applctx, bim.updt_cnt = (
      bim.updt_cnt+ 1),
      bim.updt_dt_tm = cnvtdatetime(curdate,curtime3), bim.updt_id = reqinfo->updt_id, bim.updt_task
       = reqinfo->updt_task
     PLAN (dt
      WHERE (parentbillitemmods->billitemmods[dt.seq].logicaldomainenabledind=false))
      JOIN (bim
      WHERE (bim.bill_item_mod_id=parentbillitemmods->billitemmods[dt.seq].billitemmodid))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update BillItem Modifier: ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addbillitem(plogicaldomainid)
   DECLARE reqidx = i4 WITH protect, noconstant(0)
   FOR (reqidx = 1 TO size(addonbillitems->billitems,5))
     SELECT INTO "nl:"
      nextseqnum = seq(bill_item_seq,nextval)"#################;rp0"
      FROM dual
      DETAIL
       addonbillitems->billitems[reqidx].newbillitemid = cnvtreal(nextseqnum)
      WITH format
     ;end select
     IF (((error(errmsg,0) > 0) OR (((curqual=0) OR ((addonbillitems->billitems[reqidx].newbillitemid
      <= 0.0))) )) )
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat(
       "Readme Failed - Unable to create new primary key (BillitemId)",errmsg)
      GO TO exit_script
     ENDIF
     IF (size(addonbillitemmods->billitemmods,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(addonbillitemmods->billitemmods,5)))
       WHERE (addonbillitemmods->billitemmods[d1.seq].billitemid=addonbillitems->billitems[reqidx].
       billitemid)
       DETAIL
        addonbillitemmods->billitemmods[d1.seq].newbillitemid = addonbillitems->billitems[reqidx].
        newbillitemid
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat(
        "Failed to update new Addon BillItemId in addOnBillItemMods structure: ",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (size(pricescheditems->billitemids,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(pricescheditems->billitemids,5)))
       WHERE (pricescheditems->billitemids[d1.seq].billitemid=addonbillitems->billitems[reqidx].
       billitemid)
       DETAIL
        pricescheditems->billitemids[d1.seq].newbillitemid = addonbillitems->billitems[reqidx].
        newbillitemid
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat(
        "Failed to update new Addon BillItemId in PriceSchedItems structure: ",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (size(parentbillitemmods->billitemmods,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(parentbillitemmods->billitemmods,5)))
       WHERE (parentbillitemmods->billitemmods[d1.seq].key1_id=addonbillitems->billitems[reqidx].
       billitemid)
       DETAIL
        IF ((parentbillitemmods->billitemmods[d1.seq].logicaldomainenabledind=false))
         parentbillitemmods->billitemmods[d1.seq].newbillitemid = addonbillitems->billitems[reqidx].
         newbillitemid
        ELSEIF ((parentbillitemmods->billitemmods[d1.seq].logicaldomainid=plogicaldomainid))
         parentbillitemmods->billitemmods[d1.seq].key1_id = addonbillitems->billitems[reqidx].
         newbillitemid
        ENDIF
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       ROLLBACK
       SET readme_data->status = "F"
       SET readme_data->message = concat(
        "Failed to update new Addon BillItemId in BillitemModifier structure: ",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM bill_item b,
     (dummyt dt  WITH seq = value(size(addonbillitems->billitems,5)))
    SET b.bill_item_id = addonbillitems->billitems[dt.seq].newbillitemid, b.ext_parent_reference_id
      = addonbillitems->billitems[dt.seq].newbillitemid, b.ext_parent_contributor_cd = addonbillitems
     ->billitems[dt.seq].extparentcontributorcd,
     b.ext_child_reference_id = addonbillitems->billitems[dt.seq].extchildreferenceid, b
     .ext_child_contributor_cd = addonbillitems->billitems[dt.seq].extchildcontributorcd, b
     .ext_description = addonbillitems->billitems[dt.seq].extdescription,
     b.ext_short_desc = addonbillitems->billitems[dt.seq].extshortdescription, b.ext_owner_cd =
     addonbillitems->billitems[dt.seq].extownercd, b.parent_qual_cd = addonbillitems->billitems[dt
     .seq].parentqualcd,
     b.charge_point_cd = addonbillitems->billitems[dt.seq].chargepointcd, b.workload_only_ind =
     addonbillitems->billitems[dt.seq].workloadind, b.active_ind = addonbillitems->billitems[dt.seq].
     activeind,
     b.active_status_cd = addonbillitems->billitems[dt.seq].activestatuscd, b.active_status_prsnl_id
      = addonbillitems->billitems[dt.seq].activestatusprnslid, b.ext_parent_entity_name =
     addonbillitems->billitems[dt.seq].extparententityname,
     b.ext_child_entity_name = addonbillitems->billitems[dt.seq].extchildentityname, b.misc_ind =
     addonbillitems->billitems[dt.seq].miscind, b.stats_only_ind = addonbillitems->billitems[dt.seq].
     statsonlyind,
     b.child_seq = addonbillitems->billitems[dt.seq].childseq, b.logical_domain_id = plogicaldomainid,
     b.logical_domain_enabled_ind = 1,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx, b.beg_effective_dt_tm = cnvtdatetime(
      addonbillitems->billitems[dt.seq].beg_effective_dt_tm),
     b.end_effective_dt_tm = cnvtdatetime(addonbillitems->billitems[dt.seq].end_effective_dt_tm), b
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (dt)
     JOIN (b)
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to create new billitem: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE addbillitemmodifier(plogicaldomainid)
   DECLARE reqidx = i4 WITH protect, noconstant(0)
   FOR (reqidx = 1 TO size(parentbillitemmods->billitemmods,5))
    SELECT INTO "nl:"
     nextseqnum = seq(bill_item_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      parentbillitemmods->billitemmods[reqidx].newbillitemmodid = cnvtreal(nextseqnum)
     WITH format
    ;end select
    IF (((error(errmsg,0) > 0) OR (((curqual=0) OR ((parentbillitemmods->billitemmods[reqidx].
    newbillitemmodid <= 0.0))) )) )
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat(
      "Readme Failed - Unable to create new primary key (BillitemModId)",errmsg)
     GO TO exit_script
    ENDIF
   ENDFOR
   IF (size(parentbillitemmods->billitemmods,5) > 0)
    INSERT  FROM bill_item_modifier bim,
      (dummyt dt  WITH seq = value(size(parentbillitemmods->billitemmods,5)))
     SET bim.bill_item_mod_id = parentbillitemmods->billitemmods[dt.seq].newbillitemmodid, bim
      .bill_item_id = parentbillitemmods->billitemmods[dt.seq].billitemid, bim.bill_item_type_cd =
      parentbillitemmods->billitemmods[dt.seq].billitemtypecd,
      bim.key1_id = parentbillitemmods->billitemmods[dt.seq].newbillitemid, bim.key2_id =
      parentbillitemmods->billitemmods[dt.seq].key2_id, bim.key3_id = plogicaldomainid,
      bim.key6 = parentbillitemmods->billitemmods[dt.seq].key6, bim.bim1_int = parentbillitemmods->
      billitemmods[dt.seq].bim1int, bim.active_ind = parentbillitemmods->billitemmods[dt.seq].
      activeind,
      bim.active_status_cd = parentbillitemmods->billitemmods[dt.seq].activestatuscd, bim
      .active_status_prsnl_id = parentbillitemmods->billitemmods[dt.seq].activestatusprnslid, bim
      .key1_entity_name = parentbillitemmods->billitemmods[dt.seq].key1entityname,
      bim.key2_entity_name = parentbillitemmods->billitemmods[dt.seq].key2entityname, bim.updt_dt_tm
       = cnvtdatetime(curdate,curtime3), bim.updt_id = reqinfo->updt_id,
      bim.updt_task = reqinfo->updt_task, bim.updt_cnt = 0, bim.updt_applctx = reqinfo->updt_applctx,
      bim.beg_effective_dt_tm = cnvtdatetime(parentbillitemmods->billitemmods[dt.seq].
       beg_effective_dt_tm), bim.end_effective_dt_tm = cnvtdatetime(parentbillitemmods->billitemmods[
       dt.seq].end_effective_dt_tm), bim.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (dt
      WHERE (parentbillitemmods->billitemmods[dt.seq].logicaldomainenabledind=false))
      JOIN (bim)
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to create new BillItem Modifier: ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addaddonbillitemmodifier(plogicaldomainid)
  DECLARE reqidx = i4 WITH protect, noconstant(0)
  FOR (reqidx = 1 TO size(addonbillitemmods->billitemmods,5))
    SELECT INTO "nl:"
     nextseqnum = seq(bill_item_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      addonbillitemmods->billitemmods[reqidx].newbillitemmodid = cnvtreal(nextseqnum)
     WITH format
    ;end select
    IF (((error(errmsg,0) > 0) OR (((curqual=0) OR ((addonbillitemmods->billitemmods[reqidx].
    newbillitemmodid <= 0.0))) )) )
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat(
      "Readme Failed - Unable to create new primary key (BillitemModId)",errmsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM bill_item_modifier
     (active_ind, active_status_cd, active_status_dt_tm,
     active_status_prsnl_id, beg_effective_dt_tm, bill_item_id,
     bill_item_mod_id, bill_item_type_cd, bim_ind,
     bim1_ind, bim1_int, bim1_nbr,
     bim2_int, end_effective_dt_tm, key1,
     key1_entity_name, key1_id, key10,
     key11, key11_id, key12,
     key12_id, key13, key13_id,
     key14, key14_id, key15,
     key15_id, key2, key2_id,
     key2_entity_name, key3, key3_id,
     key3_entity_name, key4, key4_id,
     key4_entity_name, key5, key5_id,
     key5_entity_name, key6, key7,
     key8, key9, updt_dt_tm,
     updt_id, updt_task, updt_applctx)(SELECT
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, beg_effective_dt_tm, addonbillitemmods->billitemmods[reqidx].
      newbillitemid,
      addonbillitemmods->billitemmods[reqidx].newbillitemmodid, bill_item_type_cd, bim_ind,
      bim1_ind, bim1_int, bim1_nbr,
      bim2_int, end_effective_dt_tm, key1,
      key1_entity_name, key1_id, key10,
      key11, key11_id, key12,
      key12_id, key13, key13_id,
      key14, key14_id, key15,
      key15_id, key2, key2_id,
      key2_entity_name, key3, plogicaldomainid,
      key3_entity_name, key4, key4_id,
      key4_entity_name, key5, key5_id,
      key5_entity_name, key6, key7,
      key8, key9, updt_dt_tm,
      updt_id, updt_task, updt_applctx
      FROM bill_item_modifier
      WHERE (bill_item_mod_id=addonbillitemmods->billitemmods[reqidx].billitemmodid)
      WITH nocounter)
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to create new BillItem Modifier: ",errmsg)
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addaddonbillitempricesched(dummyvar)
  DECLARE reqidx = i4 WITH protect, noconstant(0)
  FOR (reqidx = 1 TO size(pricescheditems->billitemids,5))
    SELECT INTO "nl:"
     nextseqnum = seq(price_sched_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      pricescheditems->billitemids[reqidx].newpricescheditemid = cnvtreal(nextseqnum)
     WITH format
    ;end select
    IF (((error(errmsg,0) > 0) OR (((curqual=0) OR ((pricescheditems->billitemids[reqidx].
    newpricescheditemid <= 0.0))) )) )
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat(
      "Readme Failed - Unable to create new primary key (PriceSchedItemId)",errmsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM price_sched_items
     (active_ind, active_status_cd, active_status_dt_tm,
     active_status_prsnl_id, allowable, beg_effective_dt_tm,
     bill_item_id, billing_discount_priority_seq, capitation_ind,
     charge_level_cd, cost_adj_amt, detail_charge_ind,
     end_effective_dt_tm, exclusive_ind, interval_template_cd,
     percent_revenue, price, price_sched_id,
     price_sched_items_id, referral_req_ind, stats_only_ind,
     tax, units_ind, updt_applctx,
     updt_dt_tm, updt_id, updt_task)(SELECT
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, allowable, beg_effective_dt_tm,
      pricescheditems->billitemids[reqidx].newbillitemid, billing_discount_priority_seq,
      capitation_ind,
      charge_level_cd, cost_adj_amt, detail_charge_ind,
      end_effective_dt_tm, exclusive_ind, interval_template_cd,
      percent_revenue, price, price_sched_id,
      pricescheditems->billitemids[reqidx].newpricescheditemid, referral_req_ind, stats_only_ind,
      tax, units_ind, updt_applctx,
      updt_dt_tm, updt_id, updt_task
      FROM price_sched_items
      WHERE (price_sched_items_id=pricescheditems->billitemids[reqidx].pricescheditemid)
      WITH nocounter)
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to create new BillItem Modifier: ",errmsg)
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE updatenonsharedbillitem(dummyvar)
   IF (size(parentbillitemmods->billitemmods,5) > 0)
    UPDATE  FROM bill_item_modifier bim,
      (dummyt dt  WITH seq = value(size(parentbillitemmods->billitemmods,5)))
     SET bim.key3_id = parentbillitemmods->billitemmods[dt.seq].logicaldomainid, bim.key1_id =
      parentbillitemmods->billitemmods[dt.seq].key1_id, bim.updt_applctx = reqinfo->updt_applctx,
      bim.updt_cnt = (bim.updt_cnt+ 1), bim.updt_dt_tm = cnvtdatetime(curdate,curtime3), bim.updt_id
       = reqinfo->updt_id,
      bim.updt_task = reqinfo->updt_task
     PLAN (dt
      WHERE (parentbillitemmods->billitemmods[dt.seq].logicaldomainenabledind=true))
      JOIN (bim
      WHERE (bim.bill_item_mod_id=parentbillitemmods->billitemmods[dt.seq].billitemmodid))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update nonshared :Addon BillItem Modifier: ",errmsg
      )
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo("end")
 FREE RECORD logicaldomain
 FREE RECORD addonbillitems
 FREE RECORD addonbillitemmods
 FREE RECORD pricescheditems
 FREE RECORD parentbillitems
 FREE RECORD parentbillitemmods
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
