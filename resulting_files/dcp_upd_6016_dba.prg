CREATE PROGRAM dcp_upd_6016:dba
 UPDATE  FROM code_value
  SET active_ind = 0
  WHERE cdf_meaning IN ("ALERTLEVEL", "ATTEND", "CONSULT", "ADMIT")
   AND code_set=6016
  WITH nocounter
 ;end update
 UPDATE  FROM code_value
  SET display = "Show Order Catalog Folder"
  WHERE cdf_meaning="SHOWORDCAT"
   AND code_set=6016
  WITH nocounter
 ;end update
 UPDATE  FROM code_value
  SET display = "Order Inquiry"
  WHERE cdf_meaning="VIEWORDER"
   AND code_set=6016
  WITH nocounter
 ;end update
 UPDATE  FROM code_value
  SET display = "Nurse Review"
  WHERE cdf_meaning="NURSEREVIEW"
   AND code_set=6016
  WITH nocounter
 ;end update
 UPDATE  FROM code_value
  SET display = "Rx Verification"
  WHERE cdf_meaning="RXVERIFY"
   AND code_set=6016
  WITH nocounter
 ;end update
 UPDATE  FROM code_value
  SET display = "Result Inquiry"
  WHERE cdf_meaning="VIEWRSLTS"
   AND code_set=6016
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 SET readme_data->message = build("PVReadMe 1122: Updates Successfull.")
 EXECUTE dm_readme_status
 COMMIT
END GO
