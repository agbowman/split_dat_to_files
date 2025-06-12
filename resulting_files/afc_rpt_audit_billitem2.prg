CREATE PROGRAM afc_rpt_audit_billitem2
 SET count = 0
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE (b.ext_owner_cd=request->ext_owner_code)
   AND b.active_ind=1
   AND b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id=0
   AND b.careset_ind=null
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = trim(b.ext_description),
   billitems->qual[count].parent_bill_item_id = b.bill_item_id, billitems->qual[count].bill_item_id
    = b.bill_item_id, billitems->qual[count].ext_description = trim(b.ext_description),
   billitems->qual[count].ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count]
   .ext_parent_contributor_cd = b.ext_parent_contributor_cd, billitems->qual[count].
   ext_child_reference_id = b.ext_child_reference_id,
   billitems->qual[count].ext_owner_cd = b.ext_owner_cd, billitems->qual[count].parent_ind = 1,
   billitems->qual[count].status = "P",
   billitems->qual[count].notcareset = 1
   IF ((request->level_ind=1))
    billitems->qual[count].pc_only = 0
   ELSE
    billitems->qual[count].pc_only = 1
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].pc_only=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_parent_reference_id=b.ext_parent_reference_id)
    AND (billitems->qual[d1.seq].ext_parent_contributor_cd=b.ext_parent_contributor_cd)
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_bill_item_id = billitems->qual[d1.seq].parent_bill_item_id,
   billitems->qual[count].parent_description = billitems->qual[d1.seq].parent_description, billitems
   ->qual[count].child_bill_item_id = b.bill_item_id, billitems->qual[count].bill_item_id = b
   .bill_item_id,
   billitems->qual[count].ext_description = trim(b.ext_description), billitems->qual[count].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count].ext_child_reference_id
    = b.ext_child_reference_id,
   billitems->qual[count].ext_owner_cd = b.ext_owner_cd, billitems->qual[count].child_ind = 1,
   billitems->qual[count].status = "C",
   billitems->qual[count].notcareset = 1
   IF ((request->level_ind=3))
    billitems->qual[count].pd_only = 1
   ELSE
    billitems->qual[count].pd_only = 0
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].child_ind=1)
    AND (billitems->qual[d1.seq].pd_only=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_child_reference_id=b.ext_child_reference_id)
    AND b.ext_parent_reference_id=0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_bill_item_id = billitems->qual[d1.seq].parent_bill_item_id,
   billitems->qual[count].parent_description = billitems->qual[d1.seq].parent_description, billitems
   ->qual[count].child_bill_item_id = billitems->qual[d1.seq].child_bill_item_id, billitems->qual[
   count].bill_item_id = b.bill_item_id,
   billitems->qual[count].ext_description = trim(b.ext_description), billitems->qual[count].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count].ext_child_reference_id
    = b.ext_child_reference_id,
   billitems->qual[count].ext_owner_cd = b.ext_owner_cd, billitems->qual[count].default_ind = 1,
   billitems->qual[count].status = "D",
   billitems->qual[count].notcareset = 1
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE (b.ext_owner_cd=request->ext_owner_code)
   AND b.active_ind=1
   AND b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id=0
   AND b.careset_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = trim(b.ext_description),
   billitems->qual[count].careset_id = b.bill_item_id, billitems->qual[count].bill_item_id = b
   .bill_item_id, billitems->qual[count].ext_description = trim(b.ext_description),
   billitems->qual[count].ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count]
   .ext_parent_contributor_cd = b.ext_parent_contributor_cd, billitems->qual[count].
   ext_child_reference_id = b.ext_child_reference_id,
   billitems->qual[count].ext_owner_cd = b.ext_owner_cd, billitems->qual[count].careset_ind = 1,
   billitems->qual[count].status = "CS"
   IF ((request->level_ind=1))
    billitems->qual[count].cpc_only = 0
   ELSE
    billitems->qual[count].cpc_only = 1
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].careset_ind=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_parent_reference_id=b.ext_parent_reference_id)
    AND (billitems->qual[d1.seq].ext_parent_contributor_cd=b.ext_parent_contributor_cd)
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = billitems->qual[d1.seq].parent_description,
   billitems->qual[count].careset_id = billitems->qual[d1.seq].careset_id, billitems->qual[count].
   careset_unit_id = b.bill_item_id, billitems->qual[count].bill_item_id = b.bill_item_id,
   billitems->qual[count].ext_description = trim(b.ext_description), billitems->qual[count].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count].ext_child_reference_id
    = b.ext_child_reference_id,
   billitems->qual[count].ext_owner_cd = b.ext_owner_cd, billitems->qual[count].careset_unit_ind = 1,
   billitems->qual[count].status = "CSU"
   IF ((request->level_ind=1))
    billitems->qual[count].cpc_only = 0
   ELSE
    billitems->qual[count].cpc_only = 1
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].careset_unit_ind=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_child_reference_id=b.ext_parent_reference_id)
    AND b.ext_child_reference_id=0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = billitems->qual[d1.seq].parent_description,
   billitems->qual[count].careset_id = billitems->qual[d1.seq].careset_id, billitems->qual[count].
   careset_unit_id = billitems->qual[d1.seq].careset_unit_id, billitems->qual[count].
   parent_bill_item_id = b.bill_item_id,
   billitems->qual[count].bill_item_id = b.bill_item_id, billitems->qual[count].ext_description =
   trim(b.ext_description), billitems->qual[count].ext_parent_reference_id = b
   .ext_parent_reference_id,
   billitems->qual[count].ext_child_reference_id = b.ext_child_reference_id, billitems->qual[count].
   ext_owner_cd = b.ext_owner_cd, billitems->qual[count].cs_parent_ind = 1,
   billitems->qual[count].status = "CSP"
   IF ((request->level_ind=1))
    billitems->qual[count].pc_only = 0
   ELSE
    billitems->qual[count].pc_only = 1
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].cs_parent_ind=1)
    AND (billitems->qual[d1.seq].cpc_only=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_parent_reference_id=b.ext_parent_reference_id)
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = billitems->qual[d1.seq].parent_description,
   billitems->qual[count].careset_id = billitems->qual[d1.seq].careset_id, billitems->qual[count].
   careset_unit_id = billitems->qual[d1.seq].careset_unit_id, billitems->qual[count].
   parent_bill_item_id = billitems->qual[d1.seq].parent_bill_item_id,
   billitems->qual[count].child_bill_item_id = b.bill_item_id, billitems->qual[count].bill_item_id =
   b.bill_item_id, billitems->qual[count].ext_description = trim(b.ext_description),
   billitems->qual[count].ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count]
   .ext_child_reference_id = b.ext_child_reference_id, billitems->qual[count].ext_owner_cd = b
   .ext_owner_cd,
   billitems->qual[count].cs_child_ind = 1, billitems->qual[count].status = "CSC"
   IF ((request->level_ind=3))
    billitems->qual[count].cpd_only = 0
   ELSE
    billitems->qual[count].cpd_only = 1
   ENDIF
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].cs_child_ind=1)
    AND (billitems->qual[d1.seq].cpd_only=1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_child_reference_id=b.ext_child_reference_id)
    AND b.ext_parent_reference_id=0
    AND b.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(billitems->qual,count), billitems->qual[count].
   parent_description = billitems->qual[d1.seq].parent_description,
   billitems->qual[count].careset_id = billitems->qual[d1.seq].careset_id, billitems->qual[count].
   careset_unit_id = billitems->qual[d1.seq].careset_unit_id, billitems->qual[count].
   parent_bill_item_id = billitems->qual[d1.seq].parent_bill_item_id,
   billitems->qual[count].child_bill_item_id = billitems->qual[d1.seq].child_bill_item_id, billitems
   ->qual[count].bill_item_id = b.bill_item_id, billitems->qual[count].ext_description = trim(b
    .ext_description),
   billitems->qual[count].ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count]
   .ext_child_reference_id = b.ext_child_reference_id, billitems->qual[count].ext_owner_cd = b
   .ext_owner_cd,
   billitems->qual[count].cs_default_ind = 1, billitems->qual[count].status = "CSD"
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count
 SET countb = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  ORDER BY billitems->qual[d1.seq].careset_id, billitems->qual[d1.seq].careset_unit_id, billitems->
   qual[d1.seq].parent_bill_item_id,
   billitems->qual[d1.seq].child_bill_item_id, billitems->qual[d1.seq].ext_parent_reference_id DESC,
   billitems->qual[d1.seq].ext_child_reference_id
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->bill_item,countb), reply->bill_item[countb].
   parent_description = billitems->qual[d1.seq].parent_description,
   reply->bill_item[countb].bill_item_id = billitems->qual[d1.seq].bill_item_id, reply->bill_item[
   countb].ext_parent_reference_id = billitems->qual[d1.seq].ext_parent_reference_id, reply->
   bill_item[countb].ext_child_reference_id = billitems->qual[d1.seq].ext_child_reference_id,
   reply->bill_item[countb].ext_description = billitems->qual[d1.seq].ext_description, reply->
   bill_item[countb].status = billitems->qual[d1.seq].status, reply->bill_item[countb].order_seq =
   countb
  WITH nocounter
 ;end select
 SET reply->bill_item_qual = count
 SET countb = 0
 SELECT INTO "nl:"
  bim.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item_modifier bim
  PLAN (d1
   WHERE (billitems->qual[d1.seq].notcareset != 1))
   JOIN (bim
   WHERE (bim.bill_item_id=billitems->qual[d1.seq].bill_item_id)
    AND bim.active_ind=1
    AND  $1)
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->bill_item_mod,countb), reply->bill_item_mod[countb].
   bill_item_id = bim.bill_item_id,
   reply->bill_item_mod[countb].bill_item_type_cd = bim.bill_item_type_cd, reply->bill_item_mod[
   countb].bill_item_mod_id = bim.bill_item_mod_id, reply->bill_item_mod[countb].key1_id = bim
   .key1_id,
   reply->bill_item_mod[countb].key2_id = bim.key2_id, reply->bill_item_mod[countb].key4_id = bim
   .key4_id, reply->bill_item_mod[countb].key6 = bim.key6,
   reply->bill_item_mod[countb].key7 = bim.key7, reply->bill_item_mod[countb].active_ind = bim
   .active_ind, reply->bill_item_mod[countb].beg_effective_dt_tm = bim.beg_effective_dt_tm,
   reply->bill_item_mod[countb].end_effective_dt_tm = bim.end_effective_dt_tm
  WITH nocounter, orahint("index(b XIE1BILL_ITEM_MODIFIER)")
 ;end select
 SET reply->bill_item_mod_qual = countb
 SELECT
  IF ((request->level_ind=1))INTO "nl:"
   bim.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    bill_item_modifier bim
   PLAN (d1
    WHERE (billitems->qual[d1.seq].parent_ind=1))
    JOIN (bim
    WHERE (bim.bill_item_id=billitems->qual[d1.seq].bill_item_id)
     AND bim.active_ind=1
     AND  $1)
  ELSEIF ((request->level_ind=2))INTO "nl:"
   bim.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    bill_item_modifier bim
   PLAN (d1
    WHERE (((billitems->qual[d1.seq].parent_ind=1)) OR ((billitems->qual[d1.seq].child_ind=1))) )
    JOIN (bim
    WHERE (bim.bill_item_id=billitems->qual[d1.seq].bill_item_id)
     AND bim.active_ind=1
     AND  $1)
  ELSEIF ((request->level_ind=3))INTO "nl:"
   bim.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    bill_item_modifier bim
   PLAN (d1
    WHERE (((billitems->qual[d1.seq].parent_ind=1)) OR ((((billitems->qual[d1.seq].child_ind=1)) OR (
    (billitems->qual[d1.seq].default_ind=1))) )) )
    JOIN (bim
    WHERE bim.active_ind=1
     AND  $1
     AND (billitems->qual[d1.seq].bill_item_id=bim.bill_item_id))
  ELSE
  ENDIF
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->bill_item_mod,countb), reply->bill_item_mod[countb].
   bill_item_id = bim.bill_item_id,
   reply->bill_item_mod[countb].bill_item_type_cd = bim.bill_item_type_cd, reply->bill_item_mod[
   countb].bill_item_mod_id = bim.bill_item_mod_id, reply->bill_item_mod[countb].key1_id = bim
   .key1_id,
   reply->bill_item_mod[countb].key2_id = bim.key2_id, reply->bill_item_mod[countb].key4_id = bim
   .key4_id, reply->bill_item_mod[countb].key6 = bim.key6,
   reply->bill_item_mod[countb].key7 = bim.key7, reply->bill_item_mod[countb].active_ind = bim
   .active_ind, reply->bill_item_mod[countb].beg_effective_dt_tm = bim.beg_effective_dt_tm,
   reply->bill_item_mod[countb].end_effective_dt_tm = bim.end_effective_dt_tm
  WITH nocounter, orahint("index(b XIE1BILL_ITEM_MODIFIER)")
 ;end select
 SET reply->bill_item_mod_qual = countb
 SELECT INTO "nl:"
  psi.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   price_sched_items psi
  PLAN (d1
   WHERE (billitems->qual[d1.seq].notcareset != 1))
   JOIN (psi
   WHERE (psi.bill_item_id=billitems->qual[d1.seq].bill_item_id)
    AND  $2
    AND cnvtdatetime(curdate,curtime3) >= psi.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= psi.end_effective_dt_tm
    AND psi.active_ind=1)
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->price_sched,countb), reply->price_sched[countb].
   bill_item_id = psi.bill_item_id,
   reply->price_sched[countb].price_sched_id = psi.price_sched_id, reply->price_sched[countb].
   price_sched_items_id = psi.price_sched_items_id, reply->price_sched[countb].price = psi.price,
   reply->price_sched[countb].active_ind = psi.active_ind, reply->price_sched[countb].
   beg_effective_dt_tm = psi.beg_effective_dt_tm, reply->price_sched[countb].end_effective_dt_tm =
   psi.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET reply->price_sched_qual = countb
 SELECT
  IF ((request->level_ind=1))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE (ext_owner_cd=request->ext_owner_code)
     AND ext_child_reference_id=0
     AND active_ind=1))
    AND  $2
    AND cnvtdatetime(curdate,curtime3) >= psi.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= psi.end_effective_dt_tm
    AND psi.active_ind=1
  ELSEIF ((request->level_ind=2))INTO "nl:"
   psi.*
   FROM price_sched_items psi
   WHERE psi.bill_item_id IN (
   (SELECT
    bill_item_id
    FROM bill_item
    WHERE (ext_owner_cd=request->ext_owner_code)
     AND ext_parent_reference_id != 0
     AND active_ind=1))
    AND  $2
    AND cnvtdatetime(curdate,curtime3) >= psi.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= psi.end_effective_dt_tm
    AND psi.active_ind=1
  ELSEIF ((request->level_ind=3))INTO "nl:"
   psi.*
   FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
    price_sched_items psi
   PLAN (d1
    WHERE (((billitems->qual[d1.seq].parent_ind=1)) OR ((((billitems->qual[d1.seq].child_ind=1)) OR (
    (billitems->qual[d1.seq].default_ind=1))) )) )
    JOIN (psi
    WHERE psi.active_ind=1
     AND  $2
     AND cnvtdatetime(curdate,curtime3) >= psi.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= psi.end_effective_dt_tm
     AND (billitems->qual[d1.seq].bill_item_id=psi.bill_item_id))
  ELSE
  ENDIF
  DETAIL
   countb = (countb+ 1), stat = alterlist(reply->price_sched,countb), reply->price_sched[countb].
   bill_item_id = psi.bill_item_id,
   reply->price_sched[countb].price_sched_id = psi.price_sched_id, reply->price_sched[countb].
   price_sched_items_id = psi.price_sched_items_id, reply->price_sched[countb].price = psi.price,
   reply->price_sched[countb].active_ind = psi.active_ind, reply->price_sched[countb].
   beg_effective_dt_tm = psi.beg_effective_dt_tm, reply->price_sched[countb].end_effective_dt_tm =
   psi.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET reply->price_sched_qual = countb
 SET stat = alterlist(reply->bill_item,count)
 IF (curqual != 0)
  SET reply->bill_item_qual = count
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET billitems
END GO
