CREATE PROGRAM ccl_menu_insert_rrd_check:dba
 SET success_ind = 0
 SET error_msg = ""
 SET nbr = 0
 SET menu_id = 99.9
 SELECT
  e.menu_id
  FROM explorer_menu e
  DETAIL
   nbr = (nbr+ 1), menu_id = e.menu_id
  WITH check, nocounter, noforms
 ;end select
 IF (((nbr > 1) OR (nbr=1
  AND  NOT (menu_id IN (0, 99.9)))) )
  SET success_ind = 1
  SET error_msg = ""
  SET request->setup_proc[1].success_ind = success_ind
  SET request->setup_proc[1].error_msg = error_msg
 ELSE
  SET success_ind = 0
  SET error_msg = "no items exist in the table"
  SET request->setup_proc[1].success_ind = success_ind
  SET request->setup_proc[1].error_msg = error_msg
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
