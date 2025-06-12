CREATE PROGRAM cv_utl_imp_cases:dba
 PROMPT
  "FileName:(CER_TEMP:CV_CASES.CSV): " = "CER_TEMP:CV_CASES.CSV"
 SET cv_utl_imp_file_name =  $1
 CALL echo(build("File Name: ",cv_utl_imp_file_name))
 EXECUTE cv_add_dataset_data
END GO
