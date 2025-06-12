CREATE PROGRAM afc_rpt_diff_owner_code:dba
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_owner_cd = f8
     2 catalog_cd = f8
     2 activity_type_cd = f8
     2 description = vc
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.*, o.*
  FROM bill_item b,
   order_catalog o
  WHERE b.ext_child_reference_id=0
   AND b.ext_parent_reference_id=o.catalog_cd
   AND b.ext_owner_cd != o.activity_type_cd
   AND b.active_ind=1
   AND o.active_ind=1
  ORDER BY b.ext_description
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = b.bill_item_id,
   billitems->qual[count1].ext_description = trim(b.ext_description), billitems->qual[count1].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count1].
   ext_parent_contributor_cd = b.ext_parent_contributor_cd,
   billitems->qual[count1].ext_child_reference_id = b.ext_child_reference_id, billitems->qual[count1]
   .ext_child_contributor_cd = b.ext_child_contributor_cd, billitems->qual[count1].ext_owner_cd = b
   .ext_owner_cd,
   billitems->qual[count1].catalog_cd = o.catalog_cd, billitems->qual[count1].activity_type_cd = o
   .activity_type_cd, billitems->qual[count1].description = trim(o.description)
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT
  cv1.*, cv2.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   code_value cv1,
   code_value cv2
  PLAN (d1)
   JOIN (cv1
   WHERE (billitems->qual[d1.seq].ext_owner_cd=cv1.code_value))
   JOIN (cv2
   WHERE (billitems->qual[d1.seq].activity_type_cd=cv2.code_value))
  HEAD PAGE
   CALL center(" * * *   D I F F E R E N T   O W N E R   C O D E   R E P O R T   * * * ",5,129), row
    + 2, col 5,
   "Report Name: AFC_RPT_DIFF_OWNER_CODE", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Order Catalog Description",
   col 60, "External Owner Code", col 85,
   "Activity Type Code", line = fillstring(129,"="), row + 1,
   col 1, line, row + 1
  DETAIL
   col 5, billitems->qual[d1.seq].description, col 60,
   cv1.display, col 85, cv2.display,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number of Bill Items = ",
   count(billitems->qual[d1.seq].bill_item_id)
  WITH nocounter
 ;end select
 FREE SET billitems
END GO
