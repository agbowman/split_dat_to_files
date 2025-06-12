CREATE PROGRAM dcp_chg_allergy_dll_name:dba
 UPDATE  FROM name_value_prefs n
  SET n.pvc_value = "CPSUIALLERGY"
  WHERE n.pvc_value="PVALLERGY"
 ;end update
 SET readme_data->status = "S"
 IF (curqual > 0)
  SET readme_data->message = build("PVReadMe 1115: DLL name successfully updated.")
 ELSE
  SET readme_data->message = build("PVReadMe 1115: No update needed.")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
