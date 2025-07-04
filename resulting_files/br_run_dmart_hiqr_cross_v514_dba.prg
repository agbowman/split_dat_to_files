CREATE PROGRAM br_run_dmart_hiqr_cross_v514:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script br_run_dmart_hiqr_cross_v514."
 EXECUTE dm_dbimport "cer_install:datamart_cat_hiqr_cross_v514.csv", "br_datamart_category_config",
 5500
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:datamart_report_hiqr_cross_v514.csv", "br_datamart_report_config",
  5500
  IF ((readme_data->status != "F"))
   EXECUTE dm_dbimport "cer_install:datamart_filter_hiqr_cross_v514.csv", "br_datamart_filter_config",
   5500
   IF ((readme_data->status != "F"))
    EXECUTE dm_dbimport "cer_install:datamart_filter_cat_hiqr_cross_v514.csv",
    "br_datamart_filter_cat_config", 5500
    IF ((readme_data->status != "F"))
     EXECUTE dm_dbimport "cer_install:datamart_report_filter_hiqr_cross_v514.csv",
     "br_datamart_rpt_filter_config", 5500
     IF ((readme_data->status != "F"))
      EXECUTE dm_dbimport "cer_install:datamart_default_hiqr_cross_v514.csv",
      "br_datamart_default_config", 5500
      IF ((readme_data->status != "F"))
       EXECUTE dm_dbimport "cer_install:datamart_text_hiqr_cross_v514.csv", "br_datamart_text_config",
       5500
       IF ((readme_data->status != "F"))
        SET readme_data->status = "S"
        SET readme_data->message =
        "Success: Readme populated the 7 reference tables for HIQR Cross v5.14 category"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
