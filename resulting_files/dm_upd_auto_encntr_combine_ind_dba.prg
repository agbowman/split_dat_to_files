CREATE PROGRAM dm_upd_auto_encntr_combine_ind:dba
 PROMPT
  "Please enter 1 to enable or 0 to disable auto encounter combine (default = 1) " = "1"
 SET new_auto_encntr_combine_ind =  $1
 IF (new_auto_encntr_combine_ind IN ("0", "1"))
  UPDATE  FROM code_cdf_ext cce
   SET cce.field_value = new_auto_encntr_combine_ind, cce.updt_cnt = (cce.updt_cnt+ 1), cce
    .updt_dt_tm = cnvtdatetime(sysdate)
   WHERE cce.code_set=327
    AND cce.cdf_meaning="ENCNTRCMB"
    AND cce.field_name="AUTO_ENCNTR_COMBINE_IND"
   WITH nocounter
  ;end update
  IF (new_auto_encntr_combine_ind="1")
   CALL echo("Auto_encntr_combine_ind has been enabled.")
  ELSE
   CALL echo("Auto_encntr_combine_ind has been disabled.")
  ENDIF
 ELSE
  CALL echo("You must enter 0 or 1.  Please run the program again and reenter.")
 ENDIF
 COMMIT
END GO
