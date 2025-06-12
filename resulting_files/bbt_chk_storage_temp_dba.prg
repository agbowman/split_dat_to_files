CREATE PROGRAM bbt_chk_storage_temp:dba
 RECORD pc_rec(
   1 pc[*]
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 storage_temp_cd = f8
 )
 SET request->setup_proc[1].success_ind = 0
 SET request->setup_proc[1].error_msg = ""
 SET stat = alterlist(pc_rec->pc,10)
 SET pc_cnt = 0
 SELECT INTO "nl:"
  pc.product_category
  FROM product_category pc
  WHERE pc.storage_temp_cd > 0
  DETAIL
   pc_cnt = (pc_cnt+ 1)
   IF (mod(pc_cnt,10)=1
    AND pc_cnt != 1)
    stat = alterlist(pc_rec->pc,(pc_cnt+ 9))
   ENDIF
   pc_rec->pc[pc_cnt].product_class_cd = pc.product_class_cd, pc_rec->pc[pc_cnt].product_cat_cd = pc
   .product_cat_cd, pc_rec->pc[pc_cnt].storage_temp_cd = pc.storage_temp_cd
  WITH nocounter
 ;end select
 FOR (pc = 1 TO pc_cnt)
   SET found_ind = 0
   SET same_ind = 1
   SELECT INTO "nl:"
    pi.storage_temp_cd
    FROM product_index pi
    WHERE (pi.product_class_cd=pc_rec->pc[pc].product_class_cd)
     AND (pi.product_cat_cd=pc_rec->pc[pc].product_cat_cd)
    DETAIL
     found_ind = 1
     IF ((pi.storage_temp_cd != pc_rec->pc[pc].storage_temp_cd))
      same_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0
    AND found_ind=1
    AND same_ind=0)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "FAILURE"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = "SUCCESS"
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
 CALL echo(build("pc_cnt     = ",pc_cnt))
 CALL echo(build("success_ind     = ",request->setup_proc[1].success_ind))
 CALL echo(build("error_msg     = ",request->setup_proc[1].error_msg))
END GO
