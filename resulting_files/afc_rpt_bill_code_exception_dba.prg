CREATE PROGRAM afc_rpt_bill_code_exception:dba
 RECORD items(
   1 item_qual = i4
   1 qual[*]
     2 bill_item_id = f8
     2 parent_ind = i2
     2 ext_description = vc
     2 ext_owner_cd = f8
     2 owner_desc = vc
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 bill_item_mod_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 chrg_sched_desc = vc
     2 key2_id = f8
     2 chrg_pnt_desc = vc
     2 key4_id = f8
     2 chrg_lvl_desc = vc
     2 charge_point_ind = i2
     2 showparent = i2
     2 bill_code_ind = i2
 )
 SET cnt = 0
 SET prev_bill_item_id = 0.0
 SET prev_ext_parent_reference_id = 0.0
 SET charge_point = 0.0
 SET bill_code = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET charge_point = code_value
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code = code_value
 SET count1 = 0
 SET prev_bill_item_id = 0.0
 SET prev_ext_parent_reference_id = 0.0
 SET showparent = 0
 SELECT INTO "nl:"
  bim.*, b.*
  FROM bill_item_modifier bim,
   bill_item b
  WHERE b.bill_item_id=bim.bill_item_id
   AND b.active_ind=1
   AND bim.bill_item_type_cd=charge_point
   AND bim.active_ind=1
  ORDER BY b.ext_parent_reference_id, b.ext_child_reference_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(items->qual,count1), items->qual[count1].bill_item_id = bim
   .bill_item_id,
   items->qual[count1].ext_description = trim(b.ext_description), items->qual[count1].ext_owner_cd =
   b.ext_owner_cd, items->qual[count1].ext_parent_reference_id = b.ext_parent_reference_id,
   items->qual[count1].ext_child_reference_id = b.ext_child_reference_id, items->qual[count1].
   bill_item_mod_id = bim.bill_item_mod_id, items->qual[count1].key1_id = bim.key1_id,
   items->qual[count1].key2_id = bim.key2_id, items->qual[count1].key4_id = bim.key4_id, items->qual[
   count1].bill_item_type_cd = bim.bill_item_type_cd,
   items->qual[count1].charge_point_ind = 1
  WITH nocounter
 ;end select
 SET items->item_qual = count1
 SELECT INTO "nl:"
  bim.*
  FROM (dummyt d1  WITH seq = value(items->item_qual)),
   bill_item_modifier bim
  PLAN (d1)
   JOIN (bim
   WHERE (bim.bill_item_id=items->qual[d1.seq].bill_item_id)
    AND bim.bill_item_type_cd=bill_code
    AND bim.active_ind=1)
  DETAIL
   items->qual[d1.seq].bill_code_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(items->item_qual))
  DETAIL
   IF ((items->qual[d1.seq].ext_child_reference_id=0)
    AND (items->qual[d1.seq].bill_code_ind=1))
    FOR (x = (d1.seq+ 1) TO items->item_qual)
      IF ((items->qual[x].bill_code_ind=0)
       AND (items->qual[x].ext_parent_reference_id=items->qual[d1.seq].ext_parent_reference_id))
       items->qual[d1.seq].showparent = 1, x = items->item_qual
      ENDIF
    ENDFOR
   ENDIF
   IF ((items->qual[d1.seq].bill_code_ind=0))
    items->qual[d1.seq].showparent = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.*
  FROM (dummyt d1  WITH seq = value(items->item_qual)),
   code_value cv
  PLAN (d1
   WHERE (items->qual[d1.seq].showparent=1))
   JOIN (cv
   WHERE (items->qual[d1.seq].ext_owner_cd=cv.code_value))
  DETAIL
   items->qual[d1.seq].owner_desc = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT
  cv1.*, cv2.*, cv3.*
  FROM (dummyt d1  WITH seq = value(items->item_qual)),
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (d1
   WHERE (items->qual[d1.seq].showparent=1))
   JOIN (cv1
   WHERE (items->qual[d1.seq].key1_id=cv1.code_value))
   JOIN (cv2
   WHERE (items->qual[d1.seq].key2_id=cv2.code_value))
   JOIN (cv3
   WHERE (items->qual[d1.seq].key4_id=cv3.code_value))
  ORDER BY items->qual[d1.seq].ext_parent_reference_id, items->qual[d1.seq].ext_child_reference_id
  HEAD PAGE
   CALL center("* * *   B  I  L  L     C  O  D  E      E  X  C  E  P  T  I  O  N   * * *",5,119), row
    + 2, col 5,
   "Report Name: AFC_RPT_BILL_CODE_EXCEPTION", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Bill Item Long Description",
   col 40, "External Owner", col 67,
   "Chrg Pnt Sched", col 87, "Chrg Lvl",
   col 109, "Chrg Pnt", row + 1,
   line = fillstring(125,"="),
   CALL center(line,1,132), row + 1
  DETAIL
   IF ((items->qual[d1.seq].showparent=1))
    cnt = (cnt+ 1)
    IF ((items->qual[d1.seq].charge_point_ind=1)
     AND (items->qual[d1.seq].bill_code_ind=0))
     IF ((items->qual[d1.seq].ext_child_reference_id=0))
      IF ((prev_bill_item_id != items->qual[d1.seq].bill_item_id))
       row + 1
      ENDIF
      IF ((prev_bill_item_id != items->qual[d1.seq].bill_item_id))
       col 5, items->qual[d1.seq].ext_description"#####################################", col 40,
       items->qual[d1.seq].owner_desc
      ENDIF
     ELSE
      IF ((prev_bill_item_id != items->qual[d1.seq].bill_item_id))
       col 10, items->qual[d1.seq].ext_description"####################################", col 40,
       items->qual[d1.seq].owner_desc
      ENDIF
     ENDIF
     col 67, cv1.display"##################", col 87,
     cv3.display"##################", col 109, cv2.display"###################",
     row + 1
    ELSEIF ((items->qual[d1.seq].charge_point_ind=1)
     AND (items->qual[d1.seq].bill_code_ind=1))
     IF ((prev_bill_item_id != items->qual[d1.seq].bill_item_id))
      row + 1
     ENDIF
     IF ((prev_bill_item_id != items->qual[d1.seq].bill_item_id))
      col 2, "* ", col 5,
      items->qual[d1.seq].ext_description, col 40, items->qual[d1.seq].owner_desc
     ENDIF
     col 67, cv1.display"##################", col 87,
     cv3.display"##################", col 109, cv2.display"##################",
     row + 1
    ENDIF
   ENDIF
   prev_bill_item_id = items->qual[d1.seq].bill_item_id
  FOOT PAGE
   col 117, "PAGE:", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number Of Bill Items Without A Valid Bill Code = ",
   cnt
  WITH nocounter
 ;end select
 FREE SET items
END GO
