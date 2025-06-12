CREATE PROGRAM aps_chg_order_retry_threshold:dba
 SET message = window
 SET width = 132
 SET order_retry_threshold = 0
 CALL order_display_screen(1,1,24,80)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="ORDER RETRY THRESHOLD"
  DETAIL
   order_retry_threshold = di.info_number
  WITH nocounter
 ;end select
#order_retry_threshold
 SET accept = change
 SET home = off
 CALL clear(04,55,33)
 IF (order_retry_threshold > 0)
  CALL text(04,55,cnvtstring(order_retry_threshold))
 ELSE
  CALL text(04,55,"10")
 ENDIF
 CALL accept(04,55,"99")
 IF (curaccept > 0)
  SET order_retry_threshold = curaccept
  GO TO threshold_correct
 ELSE
  GO TO order_retry_threshold
 ENDIF
#threshold_correct
 SET accept = change
 SET home = off
 CALL clear(09,18,62)
 CALL accept(09,18,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(09,18,62)
 IF (curaccept="Y")
  GO TO upd_dm_info_table
 ELSEIF (curaccept="N")
  GO TO order_retry_threshold
 ELSE
  GO TO threshold_correct
 ENDIF
#upd_dm_info_table
 SET home = off
 CALL clear(24,1,80)
 CALL video(ib)
 CALL text(24,01,"*** Updating DM Info Table ***")
 CALL video(n)
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="ORDER RETRY THRESHOLD"
 ;end delete
 INSERT  FROM dm_info
  SET info_domain = "ANATOMIC PATHOLOGY", info_name = "ORDER RETRY THRESHOLD", info_number =
   order_retry_threshold,
   updt_id = 0, updt_task = 0, updt_cnt = 0,
   updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 COMMIT
 CALL clear(24,01,80)
 CALL text(24,01,"*** Updated DM Info Table ***")
 GO TO end_program
 SUBROUTINE order_display_screen(is1_beg_row,is1_beg_col,is1_nbr_rows,is1_nbr_cols)
   IF (is1_beg_row=1
    AND is1_beg_col=1)
    SET accept = video(n)
    CALL video(n)
    CALL clear(1,1)
    CALL video(i)
    CALL box(01,01,23,80)
    CALL line(03,01,80,"XH")
    CALL text(02,03,"PathNet Anatomic Pathology - Order Retry Threshold")
    CALL text(04,03,"How many times do you wish to retry a failed order?")
    CALL text(06,03," Note: This is the number of times that an order will be retried from")
    CALL text(07,03," operations.")
    CALL text(09,03,"Correct? (Y/N)")
    CALL text(22,67,"(PF3 to exit)")
   ENDIF
 END ;Subroutine
 SUBROUTINE order_clear_screen(is7_beg_row,is7_end_row,is7_beg_col,is7_length)
   FOR (x = is7_beg_row TO is7_end_row)
     CALL clear(x,is7_beg_col,is7_length)
   ENDFOR
 END ;Subroutine
#end_program
END GO
