CREATE PROGRAM br_run_dmart_clnicl_trials_wf:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_dmart_clinical_trials_wf> script"
 EXECUTE dm_dbimport "cer_install:datamart_ct_cat_mp_vb_wf_comp.csv", "br_datamart_std_cat_config",
 5000
 IF ((readme_data->status != "F"))
  EXECUTE dm_dbimport "cer_install:datamart_ct_report_mp_vb_wf_comp.csv",
  "br_datamart_std_report_config", 5000
  IF ((readme_data->status != "F"))
   EXECUTE dm_dbimport "cer_install:datamart_ct_filter_mp_vb_wf_comp.csv",
   "br_datamart_std_filter_config", 5000
   IF ((readme_data->status != "F"))
    EXECUTE dm_dbimport "cer_install:datamart_ct_filter_cat_mp_vb_wf_comp.csv",
    "br_datamart_std_ftr_cat_config", 5000
    IF ((readme_data->status != "F"))
     EXECUTE dm_dbimport "cer_install:datamart_ct_report_filter_mp_vb_wf_comp.csv",
     "br_datamart_std_rpt_fltr_conf", 5000
     IF ((readme_data->status != "F"))
      EXECUTE dm_dbimport "cer_install:datamart_ct_default_mp_vb_wf_comp.csv",
      "br_datamart_std_default_config", 7000
      IF ((readme_data->status != "F"))
       EXECUTE dm_dbimport "cer_install:datamart_ct_text_mp_vb_wf_comp.csv",
       "br_datamart_std_text_config", 5000
       IF ((readme_data->status != "F"))
        EXECUTE dm_dbimport "cer_install:datamart_ct_rpt_default_mp_vb_wf_comp.csv",
        "br_datamart_std_rpt_def_conf", 5000
        IF ((readme_data->status != "F"))
         EXECUTE dm_dbimport "cer_install:datamart_ct_rpt_layout_mp_vb_wf_comp.csv",
         "br_datamart_rpt_layout_config", 5000
         IF ((readme_data->status != "F"))
          SET readme_data->status = "S"
          SET readme_data->message =
          "Success: Readme populated the 9 ref. tables for Clinical Trials WF"
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
