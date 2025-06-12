CREATE PROGRAM afc_rpt_bill_item_references:dba
 PAINT
 CALL text(2,10,"Press (Shift + F5) For a List of External Owners...")
 CALL text(4,10,"External Owner :")
 SET help =
 SELECT INTO "nl:"
  cv.code_value"#################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(4,30,"9(17);CDS;",0)
 SET ext_owner_code = cnvtreal(curaccept)
 CALL text(6,10,"Loading...")
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 child_bill_item_id = f8
     2 child_description = vc
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 price_sched_id = f8
     2 price = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key4_id = f8
     2 key6 = vc
     2 key7 = vc
     2 ext_owner_cd = f8
     2 parent_ind = i2
     2 child_ind = i2
     2 default_ind = i2
     2 order_ind = i2
     2 item_with_child = i2
     2 billcodediff = i2
     2 pricediff1 = i2
     2 pricediff2 = i2
     2 parent_status = i2
     2 default_status = i2
 )
 SET prev_order_ind = 0
 SET count1 = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET task_assay_code = 0.0
 SET code_set = 13016
 SET cdf_meaning = "TASK ASSAY"
 EXECUTE cpm_get_cd_for_cdf
 SET task_assay_code = code_value
 SET charge_point_code = 0.0
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET charge_point_code = code_value
 SET bill_code_code = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code_code = code_value
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE b.ext_owner_cd=ext_owner_code
   AND b.ext_child_reference_id=0
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = b.bill_item_id
   IF (trim(b.ext_short_desc)=" ")
    billitems->qual[count1].ext_description = "BLANK"
   ELSE
    billitems->qual[count1].ext_description = trim(b.ext_short_desc)
   ENDIF
   billitems->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[
   count1].ext_child_reference_id = b.ext_child_reference_id, billitems->qual[count1].ext_owner_cd =
   b.ext_owner_cd,
   billitems->qual[count1].parent_ind = 1, billitems->qual[count1].order_ind = 5
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT INTO "nl:"
  psi.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   price_sched_items psi
  PLAN (d1
   WHERE (billitems->qual[d1.seq].parent_ind=1))
   JOIN (psi
   WHERE psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND (billitems->qual[d1.seq].bill_item_id=psi.bill_item_id)
    AND psi.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = psi.bill_item_id,
   billitems->qual[count1].ext_description = billitems->qual[d1.seq].ext_description, billitems->
   qual[count1].ext_parent_reference_id = billitems->qual[d1.seq].ext_parent_reference_id, billitems
   ->qual[count1].price_sched_id = psi.price_sched_id,
   billitems->qual[count1].price = psi.price, billitems->qual[count1].parent_ind = 11, billitems->
   qual[count1].order_ind = 6
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT INTO "nl:"
  bim.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item_modifier bim
  PLAN (d1
   WHERE (billitems->qual[d1.seq].parent_ind=1))
   JOIN (bim
   WHERE (billitems->qual[d1.seq].bill_item_id=bim.bill_item_id)
    AND ((bim.bill_item_type_cd=charge_point_code) OR (bim.bill_item_type_cd=bill_code_code
    AND bim.active_ind=1)) )
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = bim.bill_item_id,
   billitems->qual[count1].ext_description = billitems->qual[d1.seq].ext_description, billitems->
   qual[count1].ext_parent_reference_id = billitems->qual[d1.seq].ext_parent_reference_id
   IF (((bim.bill_item_type_cd=charge_point_code) OR (bim.bill_item_type_cd=bill_code_code)) )
    billitems->qual[count1].bill_item_type_cd = bim.bill_item_type_cd
    IF (bim.bill_item_type_cd=charge_point_code)
     billitems->qual[count1].key1_id = bim.key1_id, billitems->qual[count1].key2_id = bim.key2_id,
     billitems->qual[count1].key4_id = bim.key4_id,
     billitems->qual[count1].order_ind = 8
    ELSEIF (bim.bill_item_type_cd=bill_code_code)
     billitems->qual[count1].key1_id = bim.key1_id, billitems->qual[count1].key6 = bim.key6,
     billitems->qual[count1].key7 = bim.key7,
     billitems->qual[count1].order_ind = 7
    ENDIF
   ENDIF
   billitems->qual[count1].parent_ind = 12
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   bill_item b
  PLAN (d1
   WHERE (billitems->qual[d1.seq].parent_ind > 1))
   JOIN (b
   WHERE (billitems->qual[d1.seq].ext_parent_reference_id=b.ext_parent_reference_id)
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   child_bill_item_id = b.bill_item_id,
   billitems->qual[count1].child_description = trim(b.ext_short_desc), billitems->qual[count1].
   bill_item_id = billitems->qual[d1.seq].bill_item_id, billitems->qual[count1].ext_description =
   billitems->qual[d1.seq].ext_description,
   billitems->qual[count1].ext_parent_reference_id = billitems->qual[d1.seq].ext_parent_reference_id,
   billitems->qual[count1].ext_child_reference_id = billitems->qual[d1.seq].ext_child_reference_id,
   billitems->qual[count1].price_sched_id = billitems->qual[d1.seq].price_sched_id,
   billitems->qual[count1].price = billitems->qual[d1.seq].price, billitems->qual[count1].
   bill_item_type_cd = billitems->qual[d1.seq].bill_item_type_cd, billitems->qual[count1].key1_id =
   billitems->qual[d1.seq].key1_id,
   billitems->qual[count1].key2_id = billitems->qual[d1.seq].key2_id, billitems->qual[count1].key4_id
    = billitems->qual[d1.seq].key4_id, billitems->qual[count1].key6 = billitems->qual[d1.seq].key6,
   billitems->qual[count1].key7 = billitems->qual[d1.seq].key7, billitems->qual[count1].order_ind =
   billitems->qual[d1.seq].order_ind, billitems->qual[count1].parent_ind = billitems->qual[d1.seq].
   parent_ind,
   billitems->qual[count1].parent_status = 1
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 RECORD childitems(
   1 child_item_qual = i4
   1 qual1[*]
     2 child_bill_item_id = f8
     2 bill_item_id = f8
     2 child_description = vc
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_owner_cd = f8
     2 price_sched_id = f8
     2 price = f8
     2 price_sched_desc = vc
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key4_id = f8
     2 key6 = vc
     2 key7 = vc
     2 order_ind = i2
     2 child_default = i2
     2 child_default_psi = i2
     2 child_default_bim = i2
 )
 SET count2 = 0
 SELECT INTO "nl"
  b.*
  FROM bill_item b
  WHERE b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id != 0
   AND b.ext_owner_cd=ext_owner_code
   AND b.ext_child_contributor_cd=task_assay_code
   AND b.active_ind=1
  DETAIL
   count2 = (count2+ 1), stat = alterlist(childitems->qual1,count2), childitems->qual1[count2].
   child_bill_item_id = b.bill_item_id,
   childitems->qual1[count2].child_description = trim(b.ext_short_desc), childitems->qual1[count2].
   ext_parent_reference_id = b.ext_parent_reference_id, childitems->qual1[count2].
   ext_child_reference_id = b.ext_child_reference_id,
   childitems->qual1[count2].ext_owner_cd = b.ext_owner_cd
  WITH nocounter
 ;end select
 SET childitems->child_item_qual = count2
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(childitems->child_item_qual)),
   bill_item b
  PLAN (d1)
   JOIN (b
   WHERE (childitems->qual1[d1.seq].ext_child_reference_id=b.ext_child_reference_id)
    AND b.ext_parent_reference_id=0
    AND b.active_ind=1)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(childitems->qual1,count2), childitems->qual1[count2].
   child_bill_item_id = childitems->qual1[d1.seq].child_bill_item_id,
   childitems->qual1[count2].child_description = childitems->qual1[d1.seq].child_description,
   childitems->qual1[count2].bill_item_id = b.bill_item_id
   IF (trim(b.ext_short_desc)=" ")
    childitems->qual1[count2].ext_description = "BLANK"
   ELSE
    childitems->qual1[count2].ext_description = trim(b.ext_short_desc)
   ENDIF
   childitems->qual1[count2].ext_parent_reference_id = b.ext_parent_reference_id, childitems->qual1[
   count2].ext_child_reference_id = b.ext_child_reference_id, childitems->qual1[count2].ext_owner_cd
    = b.ext_owner_cd,
   childitems->qual1[count2].child_default = 1
  WITH nocounter
 ;end select
 SET childitems->child_item_qual = count2
 SELECT INTO "nl:"
  psi.*
  FROM (dummyt d1  WITH seq = value(childitems->child_item_qual)),
   price_sched_items psi
  PLAN (d1
   WHERE (childitems->qual1[d1.seq].child_default=1))
   JOIN (psi
   WHERE (childitems->qual1[d1.seq].bill_item_id=psi.bill_item_id)
    AND psi.active_ind=1)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(childitems->qual1,count2), childitems->qual1[count2].
   child_bill_item_id = childitems->qual1[d1.seq].child_bill_item_id,
   childitems->qual1[count2].bill_item_id = psi.bill_item_id, childitems->qual1[count2].
   child_description = childitems->qual1[d1.seq].child_description, childitems->qual1[count2].
   ext_description = childitems->qual1[d1.seq].ext_description,
   childitems->qual1[count2].ext_parent_reference_id = childitems->qual1[d1.seq].
   ext_parent_reference_id, childitems->qual1[count2].ext_child_reference_id = childitems->qual1[d1
   .seq].ext_child_reference_id, childitems->qual1[count2].ext_owner_cd = childitems->qual1[d1.seq].
   ext_owner_cd,
   childitems->qual1[count2].price_sched_id = psi.price_sched_id, childitems->qual1[count2].price =
   psi.price, childitems->qual1[count2].order_ind = 2,
   childitems->qual1[count2].child_default_psi = 1
  WITH nocounter
 ;end select
 SET childitems->child_item_qual = count2
 SELECT INTO "nl:"
  bim.*
  FROM (dummyt d1  WITH seq = value(childitems->child_item_qual)),
   bill_item_modifier bim
  PLAN (d1
   WHERE (childitems->qual1[d1.seq].child_default=1))
   JOIN (bim
   WHERE (childitems->qual1[d1.seq].bill_item_id=bim.bill_item_id)
    AND bim.active_ind=1)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(childitems->qual1,count2), childitems->qual1[count2].
   child_bill_item_id = childitems->qual1[d1.seq].child_bill_item_id,
   childitems->qual1[count2].bill_item_id = bim.bill_item_id, childitems->qual1[count2].
   child_description = childitems->qual1[d1.seq].child_description, childitems->qual1[count2].
   ext_description = childitems->qual1[d1.seq].ext_description,
   childitems->qual1[count2].ext_parent_reference_id = childitems->qual1[d1.seq].
   ext_parent_reference_id, childitems->qual1[count2].ext_child_reference_id = childitems->qual1[d1
   .seq].ext_child_reference_id, childitems->qual1[count2].ext_owner_cd = childitems->qual1[d1.seq].
   ext_owner_cd,
   childitems->qual1[count2].bill_item_type_cd = bim.bill_item_type_cd
   IF (bim.bill_item_type_cd=bill_code_code)
    childitems->qual1[count2].order_ind = 3
   ELSEIF (bim.bill_item_type_cd=charge_point_code)
    childitems->qual1[count2].order_ind = 4
   ENDIF
   childitems->qual1[count2].key1_id = bim.key1_id, childitems->qual1[count2].key2_id = bim.key2_id,
   childitems->qual1[count2].key4_id = bim.key4_id,
   childitems->qual1[count2].key6 = trim(bim.key6), childitems->qual1[count2].key7 = trim(bim.key7),
   childitems->qual1[count2].child_default_bim = 1
  WITH nocounter
 ;end select
 SET childitems->child_item_qual = count2
 SET pricecnt = 0
 SET billcodecnt = 0
 SET rowdiff = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(childitems->child_item_qual))
  WHERE (((childitems->qual1[d1.seq].child_default_psi=1)) OR ((childitems->qual1[d1.seq].
  child_default_bim=1)))
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   child_bill_item_id = childitems->qual1[d1.seq].child_bill_item_id,
   billitems->qual[count1].child_description = childitems->qual1[d1.seq].child_description, billitems
   ->qual[count1].bill_item_id = childitems->qual1[d1.seq].bill_item_id, billitems->qual[count1].
   ext_description = childitems->qual1[d1.seq].ext_description,
   billitems->qual[count1].ext_parent_reference_id = childitems->qual1[d1.seq].
   ext_parent_reference_id, billitems->qual[count1].ext_child_reference_id = childitems->qual1[d1.seq
   ].ext_child_reference_id, billitems->qual[count1].price_sched_id = childitems->qual1[d1.seq].
   price_sched_id,
   billitems->qual[count1].price = childitems->qual1[d1.seq].price, billitems->qual[count1].
   bill_item_type_cd = childitems->qual1[d1.seq].bill_item_type_cd, billitems->qual[count1].key1_id
    = childitems->qual1[d1.seq].key1_id,
   billitems->qual[count1].key2_id = childitems->qual1[d1.seq].key2_id, billitems->qual[count1].
   key4_id = childitems->qual1[d1.seq].key4_id, billitems->qual[count1].key6 = childitems->qual1[d1
   .seq].key6,
   billitems->qual[count1].key7 = childitems->qual1[d1.seq].key7, billitems->qual[count1].order_ind
    = childitems->qual1[d1.seq].order_ind, billitems->qual[count1].default_status = 1
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SET prev_child_bill_item_id = 0.0
 SET prev_order_ind = 0
 SET prev_bill_item_id = 0.0
 SET prev_default_status = 0
 SELECT
  cv1.*, cv2.*, cv3.*,
  p.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   code_value cv1,
   code_value cv2,
   code_value cv3,
   price_sched p
  PLAN (d1
   WHERE (((billitems->qual[d1.seq].parent_status=1)) OR ((billitems->qual[d1.seq].default_status=1)
   )) )
   JOIN (cv1
   WHERE (cv1.code_value=billitems->qual[d1.seq].key1_id))
   JOIN (cv2
   WHERE (cv2.code_value=billitems->qual[d1.seq].key2_id))
   JOIN (cv3
   WHERE (cv3.code_value=billitems->qual[d1.seq].key4_id))
   JOIN (p
   WHERE (p.price_sched_id=billitems->qual[d1.seq].price_sched_id))
  ORDER BY billitems->qual[d1.seq].child_bill_item_id, billitems->qual[d1.seq].order_ind
  HEAD PAGE
   CALL center("* * * B I L L    I T E M    R E F E R E N C E S    R E P O R T * * *",5,129), row + 2,
   col 5,
   "Report Name: AFC_RPT_BILL_ITEM_REFERENCES", row + 1, col 5,
   "Date: ", col + 1, curdate"MM/DD/YY;;D",
   col + 2, "Time: ", col + 1,
   curtime"HH:MM;;M", row + 1, col 5,
   "Child", col 25, "Default/Parent",
   row + 1, line = fillstring(129,"="), col 1,
   line, row + 1
  DETAIL
   IF (prev_order_ind != 0
    AND (prev_child_bill_item_id != billitems->qual[d1.seq].child_bill_item_id))
    row + 1
   ENDIF
   IF ((prev_child_bill_item_id != billitems->qual[d1.seq].child_bill_item_id))
    col 5, billitems->qual[d1.seq].child_description"##################", col 25,
    billitems->qual[d1.seq].ext_description"##############"
   ENDIF
   IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
    col 25, billitems->qual[d1.seq].ext_description"##############"
   ENDIF
   IF ((billitems->qual[d1.seq].price_sched_id > 0))
    col 40, "Price Sched:", col 60,
    p.price_sched_desc"############", col 80, "Price:",
    col 88, billitems->qual[d1.seq].price"$#####.##"
   ELSEIF ((billitems->qual[d1.seq].bill_item_type_cd=bill_code_code))
    col 40, "Bill Code Sched: ", col 60,
    cv1.display, col 80, "Bill Code:    ",
    col 92, billitems->qual[d1.seq].key6"##########", col 105,
    "Desc: ", col 112, billitems->qual[d1.seq].key7"##################"
   ELSEIF ((billitems->qual[d1.seq].bill_item_type_cd=charge_point_code))
    col 40, "Chrg Pnt Sched: ", col 60,
    cv1.display, col 80, "Chrg Lvl:     ",
    col 95, cv3.display"##########", col 105,
    "Chrg Pnt: ", col 115, cv2.display"##############"
   ENDIF
   prev_child_bill_item_id = billitems->qual[d1.seq].child_bill_item_id, prev_bill_item_id =
   billitems->qual[d1.seq].bill_item_id, prev_order_ind = billitems->qual[d1.seq].order_ind,
   prev_default_status = billitems->qual[d1.seq].default_status, row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number of Bill Items = ",
   count(billitems->qual[d1.seq].child_bill_item_id)
  WITH nocounter
 ;end select
 FREE SET billitems
 FREE SET childitems
END GO
