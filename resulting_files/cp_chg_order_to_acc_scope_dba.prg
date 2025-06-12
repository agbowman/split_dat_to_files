CREATE PROGRAM cp_chg_order_to_acc_scope:dba
 SET pre_count = 0
 SET post_count = 0
 SELECT INTO "nl:"
  param
  FROM charting_operations
  WHERE param_type_flag=1
   AND param="3"
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM charting_operations
   SET param = "4"
   WHERE param_type_flag=1
    AND param="3"
  ;end update
  SET post_count = curqual
 ENDIF
 IF (pre_count > 0
  AND pre_count=post_count)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
