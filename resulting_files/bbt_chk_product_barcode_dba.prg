CREATE PROGRAM bbt_chk_product_barcode:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET failed = "F"
 SELECT INTO "NL:"
  pb.product_barcode_id
  FROM product_barcode pb
  WITH nocounter
 ;end select
 IF (failed="F")
  SET request->setup_proc[1].success_ind = 1
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
