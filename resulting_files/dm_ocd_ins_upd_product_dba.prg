CREATE PROGRAM dm_ocd_ins_upd_product:dba
 SET cntx = 0
 SET i = 0
 SET upd_cnt = 0
 SET ins_cnt = 0
 SET blocks_to_read = 100
 SET log_file_name = "DM_OCD_INS_UPD_PRODUCT.LOG"
 SET maxcolsize = 132
 SET header_str = fillstring(80,"*")
 SET cntx = size(requestin->list_0,5)
 FOR (i = 1 TO cntx)
   UPDATE  FROM dm_alpha_features daf
    SET daf.rev_number = 99.01, daf.product_area_number = cnvtint(requestin->list_0[i].
      product_area_number), daf.product_area_name = requestin->list_0[i].product_area_name
    WHERE daf.alpha_feature_nbr=cnvtint(requestin->list_0[i].ocd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_alpha_features daf
     SET daf.alpha_feature_nbr = cnvtint(requestin->list_0[i].ocd), daf.rev_number = 99.01, daf
      .product_area_number = cnvtint(requestin->list_0[i].product_area_number),
      daf.product_area_name = requestin->list_0[i].product_area_name
     WITH nocounter
    ;end insert
    SET ins_cnt = (ins_cnt+ 1)
   ELSE
    SET upd_cnt = (upd_cnt+ 1)
   ENDIF
   COMMIT
 ENDFOR
 SELECT INTO value(log_file_name)
  FROM dual
  DETAIL
   row + 1, header_str, row + 1,
   "Total lines read: ", cntx, row + 1,
   "Update Count    : ", upd_cnt, row + 1,
   "Insert Count    : ", ins_cnt
  FOOT REPORT
   IF (cntx < blocks_to_read)
    row + 1, row + 1, "********** LOAD COMPLETE ****************",
    row + 1
   ENDIF
  WITH nocounter, maxcol = value(maxcolsize), append
 ;end select
#end_program
END GO
