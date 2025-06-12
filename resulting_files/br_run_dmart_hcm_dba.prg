CREATE PROGRAM br_run_dmart_hcm:dba
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
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script br_run_dmart_hcm."
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_fltr_cat_mp_vb_wf_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_cat_mp_vb_wf_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_mp_vb_wf_comp.csv", "br_datamart_report_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_fltr_mp_vb_wf_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_fltr_mp_vb_wf_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_txt_mp_vb_wf_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_deflt_mp_vb_wf_comp.csv", "br_datamart_default_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_lyt_mp_vb_wf_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_deflt_mp_vb_wf_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_fltr_cat_mp_vb_std_org_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_cat_mp_vb_std_org_comp.csv",
 "br_datamart_category_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_mp_vb_std_org_comp.csv", "br_datamart_report_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_fltr_mp_vb_std_org_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_fltr_mp_vb_std_org_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_text_mp_vb_std_org_comp.csv", "br_datamart_text_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_dflt_mp_vb_std_org_comp.csv",
 "br_datamart_std_default_config", 7000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_layout_mp_vb_std_org_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_dflt_mp_vb_std_org_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_fltr_cat_mp_vb_std_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_cat_mp_vb_std_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_mp_vb_std_comp.csv", "br_datamart_report_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_fltr_mp_vb_std_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_fltr_mp_vb_std_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_text_mp_vb_std_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_layout_mp_vb_std_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_dflt_mp_vb_std_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_filter_cat_mp_vb_wf_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_cat_mp_vb_wf_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_mp_vb_wf_comp.csv", "br_datamart_report_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_filter_mp_vb_wf_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_filter_mp_vb_wf_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_text_mp_vb_wf_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_deflt_mp_vb_wf_comp.csv", "br_datamart_default_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_layout_mp_vb_wf_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:hcm_dmart_rpt_default_mp_vb_wf_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_fltr_cat_mp_vb_std_comp.csv",
 "br_datamart_filter_cat_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_cat_mp_vb_std_comp.csv", "br_datamart_category_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_mp_vb_std_comp.csv", "br_datamart_report_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_fltr_mp_vb_std_comp.csv", "br_datamart_filter_config",
 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_fltr_mp_vb_std_comp.csv",
 "br_datamart_rpt_filter_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_txt_mp_vb_std_comp.csv", "br_datamart_text_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_lyt_mp_vb_std_comp.csv",
 "br_datamart_rpt_layout_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 EXECUTE dm_dbimport "cer_install:ce_dtamrt_rpt_deflt_mp_vb_std_comp.csv",
 "br_datamart_rpt_default_config", 5000
 IF ((readme_data->status="F"))
  SET fail_flag = 1
  GO TO endscript
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme populated the 9 reference tables for the HealtheCare Components."
#endscript
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
