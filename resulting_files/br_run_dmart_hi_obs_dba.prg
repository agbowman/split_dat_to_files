CREATE PROGRAM br_run_dmart_hi_obs:dba
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
 SET readme_data->message = "Readme failure: Starting Script br_run_dmart_hi_obs."
 EXECUTE dm_dbimport "cer_install:hi_dmart_fltr_cat_mp_vb_wf_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_cat_mp_vb_wf_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_mp_vb_wf_comp.csv", "br_datamart_report_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_fltr_mp_vb_wf_comp.csv", "br_datamart_filter_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_fltr_mp_vb_wf_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_text_mp_vb_wf_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_deflt_mp_vb_wf_comp.csv", "br_datamart_default_config",
 7000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_layout_mp_vb_wf_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_default_mp_vb_wf_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_filter_cat_mp_vb_std_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_cat_mp_vb_std_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_mp_vb_std_comp.csv", "br_datamart_report_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_filter_mp_vb_std_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_filter_mp_vb_std_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_text_mp_vb_std_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_layout_mp_vb_std_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_default_mp_vb_std_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_fltr_cat_mp_vb_obs_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_cat_mp_vb_obs_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_mp_vb_obs_comp.csv", "br_datamart_report_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_fltr_mp_vb_obs_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_fltr_mp_vb_obs_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_text_mp_vb_obs_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_dflt_mp_vb_obs_comp.csv", "br_datamart_std_default_config",
 7000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_layout_mp_vb_obs_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:hi_dmart_rpt_dflt_mp_vb_obs_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  GO TO end_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
"Success: Readme populated the 9 reference tables for the                            Observation Workflow, Observation Summ\
ary and Observation Organizer Components.\
"
#end_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET last_mod = "000"
 SET mod_date = "Aug 16, 2016"
END GO
