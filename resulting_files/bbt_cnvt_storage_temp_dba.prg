CREATE PROGRAM bbt_cnvt_storage_temp:dba
 RECORD pc_rec(
   1 pc[*]
     2 product_class_cd = f8
     2 product_cat_cd = f8
     2 storage_temp_cd = f8
 )
 RECORD reply(
   1 status_data = c1
     2 status = c1
     2 subevventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
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
 IF (curqual > 0)
  UPDATE  FROM product_index pi,
    (dummyt d_pc  WITH seq = value(pc_cnt))
   SET pi.storage_temp_cd = pc_rec->pc[d_pc.seq].storage_temp_cd
   PLAN (d_pc)
    JOIN (pi
    WHERE (pi.product_class_cd=pc_rec->pc[d_pc.seq].product_class_cd)
     AND (pi.product_cat_cd=pc_rec->pc[d_pc.seq].product_cat_cd))
   WITH nocounter
  ;end update
 ENDIF
END GO
