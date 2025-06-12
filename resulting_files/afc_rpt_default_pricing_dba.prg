CREATE PROGRAM afc_rpt_default_pricing:dba
 PAINT
 SET lastbillitemid = 0
 SET lastpriceschedid = 0
 SET lastbillitemmodid = 0
 SET mycount = 0
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET count4 = 0
 CALL clear(1,1)
 CALL text(1,1,"Processing...")
 SET code_value = 0.0
 SET chargepoints = 0.0
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET chargepoints = code_value
 SET code_value = 0.0
 SET billcodes = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET billcodes = code_value
 SELECT
  b.bill_item_id, bm.bill_item_type_cd, bm.key1_id,
  bm.key2_id, bm.key4_id, bm.key6,
  p.price_sched_desc, pi.price_sched_items_id, bm.bill_item_mod_id,
  b.ext_description, cv.display, cv2.display,
  cv3.display
  FROM bill_item b,
   bill_item_modifier bm,
   price_sched p,
   price_sched_items pi,
   dummyt d1,
   code_value cv,
   code_value cv2,
   code_value cv3,
   dummyt d2
  PLAN (b
   WHERE b.ext_parent_reference_id=0
    AND b.ext_parent_contributor_cd=0
    AND b.ext_child_reference_id != 0
    AND b.ext_child_contributor_cd != 0
    AND b.active_ind=1)
   JOIN (pi
   WHERE pi.bill_item_id=b.bill_item_id
    AND pi.active_ind=1)
   JOIN (p
   WHERE p.price_sched_id=pi.price_sched_id)
   JOIN (d1)
   JOIN (bm
   WHERE bm.bill_item_id=b.bill_item_id
    AND bm.bill_item_type_cd IN (chargepoints, billcodes)
    AND bm.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=bm.key1_id)
   JOIN (d2)
   JOIN (cv2
   WHERE cv2.code_value=bm.key2_id
    AND bm.bill_item_type_cd=chargepoints)
   JOIN (cv3
   WHERE cv3.code_value=bm.key4_id)
  ORDER BY b.bill_item_id, bm.bill_item_type_cd
  HEAD REPORT
   mycount = 0
  HEAD PAGE
   row + 1, row + 1,
   CALL center("* * *  D E F A U L T   P R I C I N G   R E P O R T * * *",1,129),
   row + 2, col 1, "Report Name: AFC_RPT_DEFAULT_PRICING",
   row + 1, col 1, curdate"MM/DD/YY;;D",
   col + 1, curtime"HH:MM;;M", row + 1,
   col 01, "Bill Item Description", col 25,
   "Price Sched", col 42, "Bill Code Sched",
   col 60, "Bill Code", col 80,
   "Chrg Pnt Sched", col 105, "Chrg Pnt",
   col 120, "Chrg Lvl", row + 1,
   dashline = fillstring(130,"="), dashline, row + 1
  HEAD b.bill_item_id
   row + 1, billitemmodid1 = 0, billitemmodid2 = 0,
   pricescheditemid = 0, count2 = 0, count3 = 0,
   count4 = 0, col 01, b.ext_description"###############"
  DETAIL
   IF (pi.price_sched_items_id > 0)
    IF (pricescheditemid != pi.price_sched_items_id)
     col 25, p.price_sched_desc"##########"
    ENDIF
    pricescheditemid = pi.price_sched_items_id
   ENDIF
   IF (bm.bill_item_mod_id > 0)
    IF (bm.bill_item_type_cd=billcodes)
     IF (billitemmodid1 != bm.bill_item_mod_id)
      col 42, cv.display"##########"
     ENDIF
     IF (billitemmodid1 != bm.bill_item_mod_id)
      col 60, bm.key6"############"
     ENDIF
     billitemmodid1 = bm.bill_item_mod_id
    ELSE
     IF (billitemmodid2 != bm.bill_item_mod_id)
      col 80, cv.display"#################", col 105,
      cv2.display"############", col 120, cv3.display"##########"
     ENDIF
     billitemmodid2 = bm.bill_item_mod_id
    ENDIF
   ENDIF
   row + 1
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 FREE SET billitem
END GO
