CREATE PROGRAM bbt_chk_inv_device_r:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET failed = "F"
 SET request->setup_proc[1].success_ind = 1
 SET invarea_cd = 0.0
 SET locn_cd = 0.0
 SET srvres_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(17396,"BBPATLOCN",1,locn_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBINVAREA",1,invarea_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBSRVRESRC",1,srvres_cd)
 SELECT INTO "nl:"
  bdr.device_r_type_cd
  FROM bb_inv_device_r bdr
  WHERE  NOT (bdr.bb_inv_device_r_id IN (0.0, null))
  DETAIL
   IF (bdr.device_r_type_cd != invarea_cd)
    IF (bdr.device_r_type_cd != locn_cd)
     IF (bdr.device_r_type_cd != srvres_cd)
      request->setup_proc[1].success_ind = 0
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
