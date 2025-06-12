CREATE PROGRAM br_run_dmart_oph_flex:dba
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
 SET readme_data->message = "Readme failure: Starting Script br_run_dmart_oph_flex."
 EXECUTE dm_dbimport "cer_install:datamart_cat_mp_flex_wf.csv", "br_datamart_category_config", 5000
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:datamart_report_mp_flex_wf.csv", "br_datamart_report_config", 5000
  IF ((readme_data->status != "F"))
   EXECUTE dm_dbimport "cer_install:datamart_filter_mp_flex_wf.csv", "br_datamart_filter_config",
   5000
   IF ((readme_data->status != "F"))
    EXECUTE dm_dbimport "cer_install:datamart_filter_cat_mp_flex_wf.csv",
    "br_datamart_filter_cat_config", 5000
    IF ((readme_data->status != "F"))
     EXECUTE dm_dbimport "cer_install:datamart_report_filter_mp_flex_wf.csv",
     "br_datamart_rpt_filter_config", 5000
     IF ((readme_data->status != "F"))
      EXECUTE dm_dbimport "cer_install:datamart_default_mp_flex_wf.csv", "br_datamart_default_config",
      7000
      IF ((readme_data->status != "F"))
       EXECUTE dm_dbimport "cer_install:datamart_text_mp_flex_wf.csv", "br_datamart_text_config",
       5000
       IF ((readme_data->status != "F"))
        EXECUTE dm_dbimport "cer_install:datamart_rpt_default_mp_flex_wf.csv",
        "br_datamart_rpt_default_config", 5000
        IF ((readme_data->status != "F"))
         EXECUTE dm_dbimport "cer_install:datamart_report_layout_mp_flex_wf.csv",
         "br_datamart_rpt_layout_config", 5000
         IF ((readme_data->status != "F"))
          SET readme_data->status = "S"
          SET readme_data->message =
          "Success: Readme populated the reference tables for Ophthalmology Flex Component"
         ENDIF
        ENDIF
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
