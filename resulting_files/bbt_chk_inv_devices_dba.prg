CREATE PROGRAM bbt_chk_inv_devices:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET failed = "F"
 SET bd_cnt = 0
 SET bbd_cnt = 0
 SELECT INTO "NL:"
  *
  FROM bb_device bbd
  DETAIL
   bbd_cnt = (bbd_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bbd_cnt = 0
 ENDIF
 SELECT INTO "NL:"
  *
  FROM bb_inv_device bd
  DETAIL
   bd_cnt = (bd_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bd_cnt = 0
 ENDIF
 IF (bbd_cnt=bd_cnt)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
