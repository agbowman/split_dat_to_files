CREATE PROGRAM afc_rpt_noexist_task_assay:dba
 RECORD taskassay(
   1 task_assay_qual = i4
   1 qual[*]
     2 task_assay_cd = f8
     2 description = vc
     2 activity_type_cd = f8
     2 exist_ind = i2
 )
 SET count2 = 0
 SELECT INTO "nl:"
  dta.*
  FROM discrete_task_assay dta
  WHERE dta.active_ind=1
  DETAIL
   count2 = (count2+ 1), stat = alterlist(taskassay->qual,count2), taskassay->qual[count2].
   task_assay_cd = dta.task_assay_cd
   IF (trim(dta.description)=" ")
    taskassay->qual[count2].description = "BLANK DESCRIPTION"
   ELSE
    taskassay->qual[count2].description = trim(dta.description)
   ENDIF
   taskassay->qual[count2].activity_type_cd = dta.activity_type_cd
  WITH nocounter
 ;end select
 SET taskassay->task_assay_qual = count2
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(taskassay->task_assay_qual)),
   bill_item b
  PLAN (d1)
   JOIN (b
   WHERE (b.ext_child_reference_id=taskassay->qual[d1.seq].task_assay_cd)
    AND b.active_ind=1
    AND b.ext_parent_reference_id != 0)
  DETAIL
   taskassay->qual[d1.seq].exist_ind = 1
  WITH nocounter
 ;end select
 SELECT
  cv.*
  FROM (dummyt d1  WITH seq = value(taskassay->task_assay_qual)),
   code_value cv
  PLAN (d1
   WHERE (taskassay->qual[d1.seq].exist_ind=0))
   JOIN (cv
   WHERE (cv.code_value=taskassay->qual[d1.seq].activity_type_cd))
  HEAD PAGE
   CALL center("* * *   T A S K    A S S A Y    D O N ' T    E X I S T    R E P O R T  * * *",1,129),
   row + 2, col 5,
   "Report Name: AFC_RPT_NOEXIST_ORDER_CATALOG", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Discrete Task Assay Description",
   col 65, "Task Assay Code", col 85,
   "Activity Type Code", row + 1, line = fillstring(129,"="),
   col 1, line, row + 1
  DETAIL
   col 5, taskassay->qual[d1.seq].description, col 65,
   taskassay->qual[d1.seq].task_assay_cd, col 85, cv.display,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Discrete Task Assay That Do Not Exist In Bill Item Table = ",
   count(taskassay->qual[d1.seq].task_assay_cd)
  WITH nocounter
 ;end select
 FREE SET taskassay
END GO
