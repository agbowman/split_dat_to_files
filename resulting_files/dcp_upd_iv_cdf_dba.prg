CREATE PROGRAM dcp_upd_iv_cdf:dba
 SET readme_data->message = build(
  "PVReadMe 1100 BEGIN::dcp_upd_iv_cdf:Upd Disp from IVS to IV in cs 69")
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM code_value
  SET cdf_meaning = "IV"
  WHERE display="IVS"
   AND code_set=93
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 IF (curqual > 0)
  SET readme_data->message = build("PVReadMe 1100 FINISHED:",curqual,"rows upd in cs 69")
 ELSE
  SET readme_data->message = build("PVReadMe 1100 FINISHED: Zero rows qualified for update.")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
