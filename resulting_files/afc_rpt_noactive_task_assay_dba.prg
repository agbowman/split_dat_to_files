CREATE PROGRAM afc_rpt_noactive_task_assay:dba
 SET task_assay_code = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0
 SET code_set = 13016
 SET cdf_meaning = "TASK ASSAY"
 EXECUTE cpm_get_cd_for_cdf
 SET task_assay_code = code_value
 SELECT
  b.*, cv1.*
  FROM bill_item b,
   code_value cv1
  PLAN (b
   WHERE b.ext_parent_reference_id != 0
    AND b.ext_child_contributor_cd != task_assay_code
    AND b.ext_child_reference_id != 0
    AND b.active_ind=1)
   JOIN (cv1
   WHERE b.ext_owner_cd=cv1.code_value)
  HEAD PAGE
   CALL center("* * *   N O    A C T I V E    T A S K    A S S A Y    R E P O R T  * * *",1,129), row
    + 2, col 5,
   "Report Name: AFC_RPT_NOACTIVE_TASK_ASSAY", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Bill Item Long Description",
   col 65, "Bill Item Id", col 85,
   "External Owner", row + 1, line = fillstring(129,"="),
   col 1, line, row + 1
  DETAIL
   IF (b.careset_ind=1)
    col 2, "* "
   ENDIF
   col 5, b.ext_description"###############################################", col 65,
   b.bill_item_id, col 85, cv1.display,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number of Bill Items That Do Not Exist In Discrete_Task_Assay Table = ",
   count(b.bill_item_id)
  WITH nocounter
 ;end select
END GO
