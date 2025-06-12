CREATE PROGRAM cpm_get_code_value:dba
 SELECT INTO "nl:"
  c.code_value, c.code_set, c.cdf_meaning
  FROM code_value c
  WHERE (c.code_set= $1)
   AND (c.cdf_meaning= $2)
  HEAD REPORT
   code_value = c.code_value
  WITH nocounter
 ;end select
END GO
