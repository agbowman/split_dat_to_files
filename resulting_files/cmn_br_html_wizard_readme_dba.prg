CREATE PROGRAM cmn_br_html_wizard_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting cmn_br_html_wizard_readme.prg script"
 FREE RECORD br_parameters_request
 RECORD br_parameters_request(
   1 step_means[*]
     2 step_mean = vc
     2 param_list[*]
       3 parameter_name = vc
       3 parameter_value = vc
       3 parameter_seq = i2
 ) WITH protect
 SET stat = alterlist(br_parameters_request->step_means,9)
 SET br_parameters_request->step_means[1].step_mean = "CMN_MYEXP_MP_GROUP_MANAGER"
 SET stat = alterlist(br_parameters_request->step_means[1].param_list,3)
 SET br_parameters_request->step_means[1].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[1].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[1].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[1].param_list[2].parameter_value = "pex_mp_mpages_list_mgmt"
 SET br_parameters_request->step_means[1].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[1].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[2].step_mean = "CMN_MYEXP_MP_DEF_MANAGER"
 SET stat = alterlist(br_parameters_request->step_means[2].param_list,3)
 SET br_parameters_request->step_means[2].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[2].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[2].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[2].param_list[2].parameter_value = "pex_mp_mpages_mgmt"
 SET br_parameters_request->step_means[2].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[2].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[3].step_mean = "CMN_MYEXP_ADMIN_CONSOLE"
 SET stat = alterlist(br_parameters_request->step_means[3].param_list,5)
 SET br_parameters_request->step_means[3].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[3].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[3].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[3].param_list[2].parameter_value =
 "pex_mp_myview_admin_driver"
 SET br_parameters_request->step_means[3].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[3].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[3].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[3].param_list[4].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[3].param_list[4].parameter_value = "$usr_personid$"
 SET br_parameters_request->step_means[3].param_list[4].parameter_seq = 1
 SET br_parameters_request->step_means[3].param_list[5].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[3].param_list[5].parameter_value = "$usr_positioncd$"
 SET br_parameters_request->step_means[3].param_list[5].parameter_seq = 2
 SET br_parameters_request->step_means[4].step_mean = "CMN_MYEXP_SPECIALTY_MANAGER"
 SET stat = alterlist(br_parameters_request->step_means[4].param_list,3)
 SET br_parameters_request->step_means[4].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[4].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[4].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[4].param_list[2].parameter_value = "pex_default_mpage_driver"
 SET br_parameters_request->step_means[4].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[4].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[4].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[5].step_mean = "CMN_POSITION_COMPARISON"
 SET stat = alterlist(br_parameters_request->step_means[5].param_list,3)
 SET br_parameters_request->step_means[5].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[5].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[5].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[5].param_list[2].parameter_value = "pex_mp_pos_comp_page1"
 SET br_parameters_request->step_means[5].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[5].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[5].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[6].step_mean = "CMN_MP_MPAGE_EXPORT"
 SET stat = alterlist(br_parameters_request->step_means[6].param_list,3)
 SET br_parameters_request->step_means[6].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[6].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[6].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[6].param_list[2].parameter_value = "pex_mp_export_mpages"
 SET br_parameters_request->step_means[6].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[6].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[6].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[7].step_mean = "CMN_MP_MPAGE_IMPORT"
 SET stat = alterlist(br_parameters_request->step_means[7].param_list,3)
 SET br_parameters_request->step_means[7].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[7].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[7].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[7].param_list[2].parameter_value = "pex_mp_import_mpages"
 SET br_parameters_request->step_means[7].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[7].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[7].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[8].step_mean = "CMN_APP_SETTING_MANAGER"
 SET stat = alterlist(br_parameters_request->step_means[8].param_list,3)
 SET br_parameters_request->step_means[8].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[8].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[8].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[8].param_list[2].parameter_value = "pex_mp_set_man_driver"
 SET br_parameters_request->step_means[8].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[8].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[8].param_list[3].parameter_seq = 0
 SET br_parameters_request->step_means[9].step_mean = "CMN_MP_CNFG_SWAP"
 SET stat = alterlist(br_parameters_request->step_means[9].param_list,3)
 SET br_parameters_request->step_means[9].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[9].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[9].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[9].param_list[2].parameter_value = "pex_mp_cnfg_swap"
 SET br_parameters_request->step_means[9].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[9].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[9].param_list[3].parameter_seq = 0
 EXECUTE br_wizard_parameters_config  WITH replace("REQUEST",br_parameters_request)
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD br_parameters_request
END GO
