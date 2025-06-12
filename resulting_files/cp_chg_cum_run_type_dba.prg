CREATE PROGRAM cp_chg_cum_run_type:dba
 SET failed = "F"
 SET pre_count = 0
 SET post_count = 0
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "CUMULATIVE"
  WHERE c.cdf_meaning="CUM"
   AND c.code_set=14119
 ;end update
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  param
  FROM charting_operations
  WHERE param_type_flag=5
   AND param="CUM"
 ;end select
 SET pre_count = curqual
 IF (pre_count > 0)
  UPDATE  FROM charting_operations
   SET param = "CUMULATIVE"
   WHERE param_type_flag=5
    AND param="CUM"
  ;end update
  SET post_count = curqual
 ENDIF
#exit_script
 IF (((pre_count=0) OR (pre_count > 0
  AND pre_count=post_count))
  AND failed="F")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
