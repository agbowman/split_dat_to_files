CREATE PROGRAM dcp_chk_pip_col_grps:dba
 SET status = 0
 SELECT INTO "nl:"
  FROM code_value_group cvg
  WHERE cvg.code_set=25511
  WITH counter
 ;end select
 IF (curqual != 8)
  CALL echo("Problem detected in section/column grouping")
  SET status = bor(status,1)
 ENDIF
 SET cdf_meaning = "DEMOGFLD"
 SET code_set = 25511
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value=0)
  CALL echo("Failed to find code_value for DEMOGFLD in codeset 25511")
  SET status = bor(status,2)
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_group cvg
  WHERE cvg.parent_code_value=code_value
   AND cvg.code_set=6023
  WITH counter
 ;end select
 IF (curqual != 20)
  SET status = bor(status,4)
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "PIP column groups have been built correctly."
 EXECUTE dm_readme_status
 COMMIT
END GO
