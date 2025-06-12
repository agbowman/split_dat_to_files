CREATE PROGRAM bbt_chk_product_class:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET rec_cnt = 0
 SET cd_cnt = 0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1606
   AND c.active_ind=1
  DETAIL
   cd_cnt = (cd_cnt+ 1)
  WITH nocounter
 ;end select
 IF (cd_cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found for codeset 1606"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  p.product_class_cd
  FROM product_class p
  WHERE p.product_class_cd > 0
  DETAIL
   rec_cnt = (rec_cnt+ 1)
  WITH nocounter
 ;end select
 IF (rec_cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found on PRODUCT_CLASS table"
  GO TO exit_script
 ENDIF
 SET request->setup_proc[1].success_ind = 1
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
