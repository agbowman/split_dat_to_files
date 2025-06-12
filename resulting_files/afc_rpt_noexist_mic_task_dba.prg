CREATE PROGRAM afc_rpt_noexist_mic_task:dba
 RECORD mictask(
   1 mic_task_qual = i4
   1 qual[*]
     2 task_assay_cd = f8
     2 full_name = vc
     2 mnemonic = vc
     2 exist_ind = i2
 )
 SET count2 = 0
 SELECT INTO "nl:"
  mt.*
  FROM mic_task mt
  WHERE mt.active_ind=1
  DETAIL
   count2 = (count2+ 1), stat = alterlist(mictask->qual,count2), mictask->qual[count2].task_assay_cd
    = mt.task_assay_cd,
   mictask->qual[count2].mnemonic = mt.mnemonic
   IF (trim(mt.full_name)=" ")
    mictask->qual[count2].full_name = "BLANK DESCRIPTION"
   ELSE
    mictask->qual[count2].full_name = trim(mt.full_name)
   ENDIF
  WITH nocounter
 ;end select
 SET mictask->mic_task_qual = count2
 SELECT INTO "nl:"
  b.*
  FROM (dummyt d1  WITH seq = value(mictask->mic_task_qual)),
   bill_item b
  PLAN (d1)
   JOIN (b
   WHERE (b.ext_parent_reference_id=mictask->qual[d1.seq].task_assay_cd)
    AND b.active_ind=1
    AND b.ext_child_reference_id=0)
  DETAIL
   mictask->qual[d1.seq].exist_ind = 1
  WITH nocounter
 ;end select
 SELECT
  FROM (dummyt d1  WITH seq = value(mictask->mic_task_qual))
  PLAN (d1
   WHERE (mictask->qual[d1.seq].exist_ind=0))
  HEAD PAGE
   CALL center("* * *   M I C R O    T A S K     D O N ' T    E X I S T    R E P O R T  * * *",1,129),
   row + 2, col 5,
   "Report Name: AFC_RPT_NOEXIST_MIC_TASK", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Micro Task Description",
   col 65, "Micro Task Code", col 85,
   "Mnemonic", row + 1, line = fillstring(129,"="),
   col 1, line, row + 1
  DETAIL
   col 5, mictask->qual[d1.seq].full_name, col 65,
   mictask->qual[d1.seq].task_assay_cd, col 85, mictask->qual[d1.seq].mnemonic,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Total Discrete Task That Do Not Exist In Bill Item Table = ",
   count(mictask->qual[d1.seq].task_assay_cd)
  WITH nocounter
 ;end select
 FREE SET mictask
END GO
