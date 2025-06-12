CREATE PROGRAM cpm_get_cd_for_disp:dba
 SET code_display = cnvtupper(trim(code_display))
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.display_key=code_display
  HEAD REPORT
   code_value = c.code_value
  WITH nocounter
 ;end select
END GO
