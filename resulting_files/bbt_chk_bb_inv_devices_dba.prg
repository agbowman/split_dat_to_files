CREATE PROGRAM bbt_chk_bb_inv_devices:dba
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
  WHERE  NOT (bbd.device_id IN (0.0, null))
  DETAIL
   bbd_cnt = (bbd_cnt+ 1)
  WITH nocounter
 ;end select
 IF (bbd_cnt > 0)
  SELECT INTO "NL:"
   *
   FROM bb_inv_device bd
   WHERE  NOT (bd.bb_inv_device_id IN (0.0, null))
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
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
