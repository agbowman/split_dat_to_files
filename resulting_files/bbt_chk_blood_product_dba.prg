CREATE PROGRAM bbt_chk_blood_product:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET failed = "F"
 SET bp_cnt = 0
 SET tbp_cnt = 0
 SELECT INTO "NL:"
  bp.supplier_prefix_cd
  FROM blood_product bp
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET request->setup_proc[1].success_ind = 0
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  *
  FROM temp_blood_product bp
  DETAIL
   tbp_cnt = (tbp_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET tbp_cnt = 0
 ENDIF
 SELECT INTO "NL:"
  *
  FROM blood_product bp
  DETAIL
   bp_cnt = (bp_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bp_cnt = 0
 ENDIF
 IF (tbp_cnt=bp_cnt)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
