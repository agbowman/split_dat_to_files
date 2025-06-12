CREATE PROGRAM afc_rpt_notupt:dba
 SELECT
  desc = trim(cv.display), cv.code_set, parent_cont = substring(0,10,trim(cv3.display)),
  child_cont = substring(0,10,trim(cv2.display)), b.bill_item_id, b.ext_parent_reference_id,
  b.ext_parent_contributor_cd, b.ext_child_reference_id, b.ext_child_contributor_cd,
  item_desc = substring(0,50,b.ext_description), o.catalog_type_cd, cat_code = concat("ACT_CD: ",
   substring(0,20,cv4.display))
  FROM code_value cv,
   bill_item b,
   code_value cv2,
   code_value cv3,
   order_catalog o,
   code_value cv4
  PLAN (b
   WHERE  NOT (b.updt_id IN (1111, 2222, 3333))
    AND (b.ext_parent_contributor_cd=
   (SELECT
    a.code_value
    FROM code_value a
    WHERE a.code_set=13016
     AND a.cdf_meaning="ORD CAT"))
    AND b.active_ind=1
    AND b.ext_owner_cd IN (
   (SELECT
    a.code_value
    FROM code_value a
    WHERE a.code_set=106
     AND a.cdf_meaning IN ("GLB", "MICROBIOLOGY", "BB", "BB PRODUCT"))))
   JOIN (cv
   WHERE cv.code_value=b.ext_owner_cd)
   JOIN (cv2
   WHERE cv2.code_value=b.ext_child_contributor_cd)
   JOIN (cv3
   WHERE cv3.code_value=b.ext_parent_contributor_cd)
   JOIN (o
   WHERE o.catalog_cd=b.ext_parent_reference_id)
   JOIN (cv4
   WHERE cv4.code_value=o.activity_type_cd)
  ORDER BY cv.code_value, b.ext_parent_reference_id, b.ext_child_reference_id
  HEAD REPORT
   page_no = 0
  HEAD PAGE
   page_no = (page_no+ 1), col 01, "PAGE: ",
   col 07, page_no, row + 1
  HEAD desc
   row + 1, col 01, desc,
   row + 1, col 01, "-------------------------------"
  DETAIL
   row + 1, col 05, b.ext_parent_reference_id,
   col 20, b.ext_parent_contributor_cd, col 35,
   parent_cont, col 50, b.ext_child_reference_id,
   col 65, b.ext_child_contributor_cd, col 70,
   child_cont, col 85, cat_code,
   row + 1, col 05, item_desc,
   row + 1
 ;end select
END GO
