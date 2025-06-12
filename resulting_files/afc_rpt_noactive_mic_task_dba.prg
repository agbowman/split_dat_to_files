CREATE PROGRAM afc_rpt_noactive_mic_task:dba
 SET mic_task_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = "MIC TASK"
 EXECUTE cpm_get_cd_for_cdf
 SET mic_task_code = code_value
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 bill_item_id = f8
     2 ext_owner_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_description = vc
     2 ext_parent_contributor_cd = f8
     2 ext_child_contributore_cd = f8
     2 careset_ind = i2
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.*
  FROM bill_item b
  WHERE b.ext_parent_contributor_cd != mic_task_code
   AND b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id=0
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->qual,count1), billitems->qual[count1].
   bill_item_id = b.bill_item_id,
   billitems->qual[count1].ext_owner_cd = b.ext_owner_cd, billitems->qual[count1].
   ext_parent_reference_id = b.ext_parent_reference_id, billitems->qual[count1].
   ext_child_reference_id = b.ext_child_reference_id
   IF (trim(b.ext_description)=" ")
    billitems->qual[count1].ext_description = "BLANK DESCRIPTION"
   ELSE
    billitems->qual[count1].ext_description = b.ext_description
   ENDIF
   billitems->qual[count1].careset_ind = b.careset_ind
  WITH nocounter
 ;end select
 SET billitems->bill_item_qual = count1
 SELECT
  cv.*
  FROM (dummyt d1  WITH seq = value(billitems->bill_item_qual)),
   code_value cv
  PLAN (d1)
   JOIN (cv
   WHERE (cv.code_value=billitems->qual[d1.seq].ext_owner_cd))
  HEAD PAGE
   CALL center("* * *   N O    A C T I V E    M I C R O    T A S K    R E P O R T  * * *",1,129), row
    + 2, col 5,
   "Report Name: AFC_RPT_NOACTIVE_MIC_TASK", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Bill Item Long Description",
   col 65, "Bill Item Id", col 85,
   "External Owner", row + 1, line = fillstring(129,"="),
   col 1, line, row + 1
  DETAIL
   IF ((billitems->qual[d1.seq].careset_ind=1))
    col 2, "* "
   ENDIF
   col 5, billitems->qual[d1.seq].ext_description"###############################################",
   col 65,
   billitems->qual[d1.seq].bill_item_id, col 85, cv.display,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Number of Bill Items That Do Not Exist In Mic_Task Table = ",
   count(billitems->qual[d1.seq].bill_item_id)
  WITH outerjoin = d1, nocounter
 ;end select
 FREE SET billitems
END GO
