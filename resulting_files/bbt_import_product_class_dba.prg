CREATE PROGRAM bbt_import_product_class:dba
 RECORD status_data(
   1 active_ind = i2
   1 active_dt_tm = dq8
   1 inactive_dt_tm = dq8
 )
 SET max_list = size(requestin->list_0,5)
 SET x = 1
#start_loop
 IF (x > max_list)
  GO TO exit_script
 ENDIF
 FOR (x = x TO max_list)
   SET success = 0
   SET cdf_meaning = fillstring(12," ")
   SET code_value = 0.0
   SET code_display = fillstring(40," ")
   SET code_set = 1606
   SELECT INTO "nl:"
    FROM code_value c
    WHERE (c.cdf_meaning=requestin->list_0[x].meaning)
     AND c.code_set=1606
    DETAIL
     code_value = c.code_value, code_display = c.display
    WITH counter
   ;end select
   IF (curqual=0)
    GO TO next_item
   ENDIF
   IF (code_value > 0)
    INSERT  FROM product_class p
     SET p.product_class_cd = code_value, p.description = code_display, p.active_ind = 1,
      p.updt_id = 0057, p.updt_task = 0057, p.updt_applctx = 0057,
      p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET success = 0
     GO TO next_item
    ENDIF
    COMMIT
   ELSE
    SET success = 0
    GO TO next_item
   ENDIF
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
END GO
