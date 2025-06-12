CREATE PROGRAM afc_rpt_price_exception:dba
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_owner_cd = f8
     2 owner_desc = vc
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 chrg_sched_desc = vc
     2 key2_id = f8
     2 chrg_pnt_desc = vc
     2 key4_id = f8
     2 chrg_lvl_desc = vc
     2 price_ind = i2
     2 bill_code_ind = i2
     2 charge_point_ind = i2
     2 showparent = i2
 )
 SET prev_bill_item_id = 0.0
 SET charge_point = 0.0
 SET bill_code = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cnt = 0
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET charge_point = code_value
 SET count1 = 0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code = code_value
 SELECT INTO "nl:"
  bim.*, b.*
  FROM bill_item_modifier bim,
   bill_item b
  PLAN (bim
   WHERE bim.active_ind=1
    AND bim.bill_item_type_cd=charge_point)
   JOIN (b
   WHERE bim.bill_item_id=b.bill_item_id
    AND b.active_ind=1)
  ORDER BY b.ext_parent_reference_id, b.ext_child_reference_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = b.bill_item_id
   IF (trim(b.ext_description)=" ")
    billitems->qual[count1].ext_description = "BLANK DESCRIPTION"
   ELSE
    billitems->qual[count1].ext_description = trim(b.ext_description)
   ENDIF
   billitems->qual[count1].ext_owner_cd = b.ext_owner_cd, billitems->qual[count1].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count1].
   ext_child_reference_id = b.ext_child_reference_id,
   billitems->qual[count1].key1_id = bim.key1_id, billitems->qual[count1].key2_id = bim.key2_id,
   billitems->qual[count1].key4_id = bim.key4_id,
   billitems->qual[count1].bill_item_type_cd = bim.bill_item_type_cd, billitems->qual[count1].
   charge_point_ind = 1
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT INTO "nl:"
  psi.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   price_sched_items psi
  PLAN (d1)
   JOIN (psi
   WHERE (psi.bill_item_id=billitems->qual[d1.seq].bill_item_id)
    AND psi.active_ind=1)
  DETAIL
   billitems->qual[d1.seq].price_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual))
  ORDER BY billitems->qual[d1.seq].ext_parent_reference_id, billitems->qual[d1.seq].
   ext_child_reference_id
  DETAIL
   IF ((billitems->qual[d1.seq].ext_child_reference_id=0)
    AND (billitems->qual[d1.seq].price_ind=1))
    FOR (x = (d1.seq+ 1) TO billitems->bill_item_qual)
      IF ((billitems->qual[x].price_ind=0)
       AND (billitems->qual[x].ext_parent_reference_id=billitems->qual[d1.seq].
      ext_parent_reference_id))
       billitems->qual[d1.seq].showparent = 1, x = billitems->bill_item_qual
      ENDIF
    ENDFOR
   ENDIF
   IF ((billitems->qual[d1.seq].price_ind=0))
    billitems->qual[d1.seq].showparent = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  cv1.*, cv2.*, cv3.*,
  cv4.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (d1
   WHERE (billitems->qual[d1.seq].showparent=1))
   JOIN (cv1
   WHERE (billitems->qual[d1.seq].key1_id=cv1.code_value))
   JOIN (cv2
   WHERE (billitems->qual[d1.seq].key2_id=cv2.code_value))
   JOIN (cv3
   WHERE (billitems->qual[d1.seq].key4_id=cv3.code_value))
   JOIN (cv4
   WHERE (billitems->qual[d1.seq].ext_owner_cd=cv4.code_value))
  HEAD PAGE
   CALL center("* * *   P R I C E    E X C E P T I O N   * * *",5,119), row + 2, col 5,
   "Report Name: AFC_RPT_PRICE_EXCEPTION", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Bill Item Long Description",
   col 40, "External Owner", col 67,
   "Chrg Pnt Sched", col 87, "Charge Lvl",
   col 109, "Chrg Pnt", row + 1,
   line = fillstring(125,"="),
   CALL center(line,1,132), row + 1
  DETAIL
   IF ((billitems->qual[d1.seq].showparent=1))
    cnt = (cnt+ 1)
    IF ((billitems->qual[d1.seq].price_ind=0))
     IF ((billitems->qual[d1.seq].ext_child_reference_id=0))
      IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
       row + 1
      ENDIF
      IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
       col 5, billitems->qual[d1.seq].ext_description"###################################", col 40,
       cv4.display
      ENDIF
     ELSEIF ((billitems->qual[d1.seq].ext_parent_reference_id=0))
      IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
       col 10, billitems->qual[d1.seq].ext_description"#################################", col 40,
       cv4.display
      ENDIF
     ELSE
      IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
       col 10, billitems->qual[d1.seq].ext_description"##################################", col 40,
       cv4.display
      ENDIF
     ENDIF
     col 67, cv1.display"################", col 87,
     cv3.display"#################", col 109, cv2.display"################",
     row + 1
    ELSEIF ((billitems->qual[d1.seq].price_ind=1))
     IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
      row + 1
     ENDIF
     IF ((prev_bill_item_id != billitems->qual[d1.seq].bill_item_id))
      col 2, "* ", col 5,
      billitems->qual[d1.seq].ext_description"###################################", col 40, cv4
      .display
     ENDIF
     col 67, cv1.display"##################", col 87,
     cv3.display"##################", col 109, cv2.display"##################",
     row + 1
    ENDIF
   ENDIF
   prev_bill_item_id = billitems->qual[d1.seq].bill_item_id
  FOOT PAGE
   col 117, "PAGE:", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number Of Bill Items With No Prices = ",
   cnt
  WITH nocounter
 ;end select
 FREE SET billitems
END GO
