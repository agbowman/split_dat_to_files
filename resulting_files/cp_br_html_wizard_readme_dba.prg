CREATE PROGRAM cp_br_html_wizard_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting cp_br_html_wizard_readme.prg script"
 FREE RECORD br_parameters_request
 RECORD br_parameters_request(
   1 step_means[*]
     2 step_mean = vc
     2 param_list[*]
       3 parameter_name = vc
       3 parameter_value = vc
       3 parameter_seq = i2
 ) WITH protect
 SET stat = alterlist(br_parameters_request->step_means,1)
 SET br_parameters_request->step_means[1].step_mean = "CMN_CARE_PTHWYS_BLD_TOOL"
 SET stat = alterlist(br_parameters_request->step_means[1].param_list,3)
 SET br_parameters_request->step_means[1].param_list[1].parameter_name = "CONTENT_SOURCE_TYPE"
 SET br_parameters_request->step_means[1].param_list[1].parameter_value = "CCL_SCRIPT"
 SET br_parameters_request->step_means[1].param_list[2].parameter_name = "CONTENT_SOURCE"
 SET br_parameters_request->step_means[1].param_list[2].parameter_value = "cp_build_tool_driver"
 SET br_parameters_request->step_means[1].param_list[3].parameter_name = "REPORT_PARAM"
 SET br_parameters_request->step_means[1].param_list[3].parameter_value = "^MINE^"
 SET br_parameters_request->step_means[1].param_list[3].parameter_seq = 0
 EXECUTE br_wizard_parameters_config  WITH replace("REQUEST",br_parameters_request)
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD br_parameters_request
END GO
