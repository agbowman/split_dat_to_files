CREATE PROGRAM bbt_get_cd_for_cdf:dba
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.cdf_meaning=cdf_meaning
   AND c.active_ind=1
  HEAD REPORT
   code_value = c.code_value
  WITH nocounter
 ;end select
END GO
