CREATE PROGRAM dcp_upd_med_order_type_cd:dba
 SET readme_data->message = build(
  "PVReadMe 1113 BEGIN:dcp_upd_med_order_type_cd: update code set 18309 from data in 16389.")
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM code_value c
  SET c.definition = "IVSOLUTIONS"
  WHERE c.code_set=18309
   AND ((c.cdf_meaning="IV") OR (c.cdf_meaning="TPN"))
  WITH check
 ;end update
 UPDATE  FROM code_value
  SET definition = "MEDICATIONS"
  WHERE code_set=18309
   AND definition != "IVSOLUTIONS"
  WITH check
 ;end update
 SET readme_data->status = "S"
 SET readme_data->message = build("PVReadMe 1113 FINISHED: update successfull.")
 EXECUTE dm_readme_status
 COMMIT
END GO
