CREATE PROGRAM cpm_get_cd_for_cdf2:dba
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.cdf_meaning=cnvtupper(cdf_meaning)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   code_value = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET code_value = 0
 ENDIF
END GO
