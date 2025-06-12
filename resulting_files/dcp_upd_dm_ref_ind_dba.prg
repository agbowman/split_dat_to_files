CREATE PROGRAM dcp_upd_dm_ref_ind:dba
 SET readme_data->message = build(
  "PVReadMe 1121 BEGIN:dcp_upd_dm_ref_ind:Upd reference_ind fld on dm_tables_doc")
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM dm_tables_doc
  SET reference_ind = 1
  WHERE ((table_name="LOGICAL_GROUPING") OR (table_name="LOG_GROUP_ENTRY"))
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 SET readme_data->message = build("PVReadMe 1121 FINISHED:Update Successfull.")
 EXECUTE dm_readme_status
 COMMIT
END GO
