CREATE PROGRAM dcp_upd_multipat_entity:dba
 SET xref_added = 0
 SET col_cont_added = 0
 SET total = 0
 UPDATE  FROM tl_multipatient_xref
  SET parent_entity_name = "TL_MASTER_TAB_SET"
  WHERE multipatient_ind=2
  WITH nocounter
 ;end update
 SET count = curqual
 UPDATE  FROM tl_multipatient_xref
  SET parent_entity_name = "CODE_VALUE"
  WHERE multipatient_ind=1
  WITH nocounter
 ;end update
 SET count = (count+ curqual)
 UPDATE  FROM tl_multipatient_xref
  SET parent_entity_name = "PRSNL"
  WHERE multipatient_ind=0
  WITH nocounter
 ;end update
 SET count = (count+ curqual)
 SET xref = count
 SET readme_data->message = build("PVReadMe 1110: ",count,"updates to tl_multipatient_xref.")
 EXECUTE dm_readme_status
 COMMIT
 SET count = 0
 UPDATE  FROM tl_multpat_col_content
  SET parent_entity_name = "TL_MASTER_TAB_SET"
  WHERE multipatient_ind=2
  WITH nocounter
 ;end update
 SET count = curqual
 UPDATE  FROM tl_multpat_col_content
  SET parent_entity_name = "CODE_VALUE"
  WHERE multipatient_ind=1
  WITH nocounter
 ;end update
 SET count = (count+ curqual)
 UPDATE  FROM tl_multpat_col_content
  SET parent_entity_name = "PRSNL"
  WHERE multipatient_ind=0
  WITH nocounter
 ;end update
 SET count = (count+ curqual)
 SET col_cont = count
 SET readme_data->message = build("PVReadMe 1110: ",count,"updates to tl_multpat_col_content.")
 EXECUTE dm_readme_status
 COMMIT
 SET total = (col_cont+ xref)
 IF (total > 0)
  SET readme_data->message = build("PVReadMe 1110: ",total,"rows successfully updated.")
 ELSE
  SET readme_data->message = build("PVReadMe 1110: No updates needed.")
 ENDIF
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
 COMMIT
END GO
