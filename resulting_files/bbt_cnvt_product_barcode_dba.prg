CREATE PROGRAM bbt_cnvt_product_barcode:dba
 RECORD pb_rec(
   1 pb[*]
     2 product_barcode_id = f8
     2 product_barcode = c15
     2 product_cd = f8
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 )
 SET failed = "F"
 SET pb_cnt = 0
 SET new_product_barcode_seq = 0.0
 DELETE  FROM product_barcode
  WHERE product_barcode="               "
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  pb.product_barcode_id, pb.product_barcode, pb.product_cd,
  pb.product_cat_cd, pb.product_class_cd, pb.active_ind,
  pb.active_status_cd, pb.active_status_dt_tm, pb.active_status_prsnl_id,
  pb.updt_cnt, pb.updt_dt_tm, pb.updt_id,
  pb.updt_task, pb.updt_applctx
  FROM product_barcode pb
  ORDER BY pb.product_barcode, pb.active_ind, pb.updt_cnt
  HEAD REPORT
   stat = alterlist(pb_rec->pb,100)
  HEAD pb.product_barcode
   IF (trim(pb.product_barcode) > ""
    AND pb.active_ind=1)
    pb_cnt = (pb_cnt+ 1)
    IF (mod(pb_cnt,100)=1
     AND pb_cnt != 1)
     stat = alterlist(pb_rec->pb,(pb_cnt+ 99))
    ENDIF
    pb_rec->pb[pb_cnt].product_barcode_id = pb.product_barcode_id, pb_rec->pb[pb_cnt].product_barcode
     = pb.product_barcode, pb_rec->pb[pb_cnt].product_cd = pb.product_cd,
    pb_rec->pb[pb_cnt].product_cat_cd = pb.product_cat_cd, pb_rec->pb[pb_cnt].product_class_cd = pb
    .product_class_cd, pb_rec->pb[pb_cnt].active_ind = pb.active_ind,
    pb_rec->pb[pb_cnt].active_status_cd = pb.active_status_cd, pb_rec->pb[pb_cnt].active_status_dt_tm
     = cnvtdatetime(pb.active_status_dt_tm), pb_rec->pb[pb_cnt].active_status_prsnl_id = pb
    .active_status_prsnl_id,
    pb_rec->pb[pb_cnt].updt_cnt = pb.updt_cnt, pb_rec->pb[pb_cnt].updt_dt_tm = cnvtdatetime(pb
     .updt_dt_tm), pb_rec->pb[pb_cnt].updt_id = pb.updt_id,
    pb_rec->pb[pb_cnt].updt_task = pb.updt_task, pb_rec->pb[pb_cnt].updt_applctx = pb.updt_applctx
   ENDIF
  FOOT REPORT
   stat = alterlist(pb_rec->pb,pb_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 IF (pb_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (pb = 1 TO pb_cnt)
   IF ((pb_rec->pb[pb].product_barcode_id > 0))
    SET pb_cnt = pb_cnt
   ELSE
    SET new_product_barcode_seq = 0.0
    SET new_product_barcode_seq = next_pathnet_seq(0)
    SET pb_rec->pb[pb].product_barcode_id = new_product_barcode_seq
   ENDIF
 ENDFOR
 DELETE  FROM product_barcode pb
  WHERE ((trim(pb.product_barcode) > "") OR (trim(pb.product_barcode) <= ""))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET failed = "T"
  GO TO commit_rollback
 ENDIF
 FOR (pb = 1 TO pb_cnt)
  INSERT  FROM product_barcode pb
   SET pb.product_barcode_id = pb_rec->pb[pb].product_barcode_id, product_barcode = pb_rec->pb[pb].
    product_barcode, product_cd = pb_rec->pb[pb].product_cd,
    product_cat_cd = pb_rec->pb[pb].product_cat_cd, product_class_cd = pb_rec->pb[pb].
    product_class_cd, active_ind = pb_rec->pb[pb].active_ind,
    active_status_cd = pb_rec->pb[pb].active_status_cd, active_status_dt_tm = cnvtdatetime(pb_rec->
     pb[pb].active_status_dt_tm), active_status_prsnl_id = pb_rec->pb[pb].active_status_prsnl_id,
    updt_cnt = pb_rec->pb[pb].updt_cnt, updt_dt_tm = cnvtdatetime(pb_rec->pb[pb].updt_dt_tm), updt_id
     = pb_rec->pb[pb].updt_id,
    updt_task = pb_rec->pb[pb].updt_task, updt_applctx = pb_rec->pb[pb].updt_applctx
   WITH counter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO commit_rollback
  ENDIF
 ENDFOR
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
#commit_rollback
 IF (failed="F")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#exit_script
END GO
