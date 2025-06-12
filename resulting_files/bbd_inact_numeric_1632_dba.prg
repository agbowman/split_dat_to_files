CREATE PROGRAM bbd_inact_numeric_1632:dba
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning="NUMERIC"
   AND c.code_set=1632
   AND c.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM code_value c
   SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.inactive_dt_tm =
    cnvtdatetime(curdate,curtime3),
    c.updt_cnt = (c.updt_cnt+ 1)
   WHERE c.cdf_meaning="NUMERIC"
    AND c.code_set=1632
    AND c.active_ind=1
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
#exit_script
END GO
