CREATE PROGRAM bbt_chk_product_barcode_id:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET pb_cnt = 0
 SET pbi_cnt = 0
 SELECT INTO "NL:"
  pb.product_cd
  FROM product_barcode pb
  WHERE pb.product_cd > 0
  DETAIL
   pb_cnt = (pb_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  pb.product_barcode_id
  FROM product_barcode pb
  WHERE pb.product_barcode_id > 0
  DETAIL
   pbi_cnt = (pbi_cnt+ 1)
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (pbi_cnt != pb_cnt)) )
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Found null or zero column(s) for product_barcode_id on PRODUCT_BARCODE table"
  GO TO exit_script
 ENDIF
 SET request->setup_proc[1].success_ind = 1
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
