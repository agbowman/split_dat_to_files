CREATE PROGRAM bhs_check_charges:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE tsk_load_task_info_for_afc
 COMMIT
 SELECT INTO  $1
  FROM dummyt
  HEAD REPORT
   col 10, "tsk_load_task_info_for_afc completed", row + 1
  WITH nocounter
 ;end select
END GO
