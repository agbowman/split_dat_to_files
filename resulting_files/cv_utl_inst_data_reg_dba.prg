CREATE PROGRAM cv_utl_inst_data_reg:dba
 PROMPT
  "Install ACC02?(Y/N) [N]" = "N",
  "Update CDF Meanings for ACC?(Y/N) [N]" = "N",
  "Install STS241?(Y/N) [N]" = "N",
  "Update CDF Meanings for STS?(Y/N) [N]" = "N",
  "Install STS Algorithm?(Y/N) [N]" = "N",
  "ACC Form Name?[ACC v3]" = "ACC v3",
  "STS Form Name?[Society of Thoracic Surgeons 2.52]" = "Society of Thoracic Surgeons 2.52",
  "Install ACC03?(Y/N) [N]" = "N",
  "Install STS03?(Y/N) [N]" = "N"
 DECLARE cv_install_acc02 = c1 WITH protect, constant(cnvtupper( $1))
 DECLARE cv_install_acc02_cdf = c1 WITH protect, constant(cnvtupper( $2))
 DECLARE cv_install_sts241 = c1 WITH protect, constant(cnvtupper( $3))
 DECLARE cv_install_sts241_cdf = c1 WITH protect, constant(cnvtupper( $4))
 DECLARE cv_install_alg = c1 WITH protect, constant(cnvtupper( $5))
 DECLARE cv_ins_acc_form_name = vc WITH protect, constant( $6)
 DECLARE cv_ins_sts_form_name = vc WITH protect, constant( $7)
 DECLARE cv_install_acc03 = c1 WITH protect, constant(cnvtupper( $8))
 DECLARE cv_install_sts03 = c1 WITH protect, constant(cnvtupper( $9))
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE failure = c1 WITH protect, noconstant("T")
 DECLARE accv3_ind = i2 WITH protect
 IF (cv_install_acc02="Y")
  IF (cv_install_acc02_cdf="Y")
   CALL echo("*** Installing ACC DTA CDF Meanings ***")
   EXECUTE dm_readme_import "accv2_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
   0
  ENDIF
  CALL echo("*** Installing ACC 2.0c ***")
  EXECUTE dm_readme_import "accv2_dataset.csv", "cv_import_dataset", 10000,
  0
  EXECUTE dm_readme_import "accv2_files.csv", "cv_import_dataset_files", 10000,
  0
  EXECUTE dm_readme_import "accv2_validation.csv", "cv_import_xref_validation", 10000,
  0
  EXECUTE cv_add_acc_err_warning_msg
  EXECUTE cv_utl_upd_form_ref_id "ACC02", cv_ins_acc_form_name
  EXECUTE dm_readme_import "cv_omf_acc_indicator.csv", "cv_ins_updt_cv_omf_filter", 10000,
  0
 ENDIF
 IF (cv_install_acc03="Y")
  CALL echo("*** Installing ACC 3.0 ***")
  SET accv3_ind = 1
  EXECUTE dm_dbimport "cer_install:accv3_dataset.csv", "cv_import_dataset", 1000,
  0
  EXECUTE dm_dbimport "cer_install:accv3_files.csv", "cv_import_dataset_files", 1000,
  0
  EXECUTE dm_dbimport "cer_install:accv3_validation.csv", "cv_import_xref_validation", 1000,
  0
  EXECUTE cv_add_acc_err_warning_msg
  EXECUTE cv_utl_upd_form_ref_id "ACC03", "ACC v3 Admission Form", "ADMIT"
  EXECUTE cv_utl_upd_form_ref_id "ACC03", "ACC v3 Cath Lab Visit Form", "LABVISIT"
  EXECUTE dm_dbimport "cer_install:accv3_ref_text.csv", "cv_import_ref_text", 1000,
  0
  EXECUTE cv_upd_display_grid "ACC v3 Lesion/Devices", "LESION", "ACC v3 Lesion Data",
  "Y"
 ENDIF
 IF (cv_install_sts241="Y")
  IF (cv_install_sts241_cdf="Y")
   CALL echo("*** Installing STS DTA CDF Meanings ***")
   EXECUTE dm_readme_import "dcp_658255_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
   0
  ENDIF
  CALL echo("*** Installing STS 2.41 ***")
  EXECUTE dm_readme_import "sts02_dataset.csv", "cv_import_dataset", 10000,
  0
  EXECUTE dm_readme_import "sts02_files.csv", "cv_import_dataset_files", 10000,
  0
  EXECUTE dm_readme_import "sts02_validation.csv", "cv_import_xref_validation", 10000,
  0
  EXECUTE cv_utl_sts241_ins_warning
  EXECUTE cv_utl_upd_form_ref_id "STS02", cv_ins_sts_form_name
  EXECUTE dm_readme_import "cv_omf_sts_indicator.csv", "cv_ins_updt_cv_omf_filter", 10000,
  0
 ENDIF
 IF (((cv_install_sts03="Y") OR (cv_install_alg="Y")) )
  EXECUTE dm_readme_import "cv_operator.csv", "cv_import_operator", 1000,
  0
 ENDIF
 IF (cv_install_sts03="Y")
  CALL echo("*** Installing STS 2.52 ***")
  EXECUTE dm_readme_import "sts03_dataset.csv", "cv_import_dataset", 2000,
  0
  EXECUTE dm_readme_import "sts03_files.csv", "cv_import_dataset_files", 2000,
  0
  EXECUTE dm_readme_import "sts03_validation.csv", "cv_import_xref_validation", 2000,
  0
  EXECUTE cv_utl_sts252_ins_warning
  EXECUTE cv_utl_upd_form_ref_id "STS03", cv_ins_sts_form_name
  EXECUTE dm_readme_import "cv_sts252_algorithm.csv", "cv_import_algorithm", 2000,
  0
  EXECUTE dm_readme_import "sts03_ref_text.csv", "cv_import_ref_text", 1000,
  0
 ENDIF
 IF (cv_install_alg="Y")
  CALL echo("*** Installing STS 2.41 Algorithm***")
  EXECUTE dm_readme_import "cv_algorithm.csv", "cv_import_algorithm", 10000,
  0
  EXECUTE dm_readme_import "cv_sts241_algorithm.csv", "cv_import_algorithm", 10000,
  0
 ENDIF
 EXECUTE cv_utl_add_dm_prefs
 EXECUTE cv_utl_upd_dm_prefs_ssn "ACC02", "SSN-REPLACE", "1"
 EXECUTE cv_utl_upd_dm_prefs_notify "STS02", "DISCERN_NOTIFY", "HARVEST",
 "0"
 SELECT INTO "nl:"
  d.device_id
  FROM cv_device d
  WHERE d.device_id=0.0
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM cv_device cd
   SET cd.device_id = 0.0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  dad.dev_abstr_data_id
  FROM cv_dev_abstr_data dad
  WHERE dad.dev_abstr_data_id=0.0
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM cv_dev_abstr_data cdad
   SET cdad.dev_abstr_data_id = 0.0
   WITH nocounter
  ;end insert
 ENDIF
 CALL echo("*****************************************************************")
 CALL echo("Please cycle the CPM Process, CPM Code Cache Manager, ")
 CALL echo("CPM Script Async 002, CPM Script, and the Clinical Events Servers.")
 CALL echo("*****************************************************************")
 SET failure = "F"
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
 DECLARE cv_utl_inst_data_reg_vrsn = vc WITH private, constant("MOD 008 BM9013 05/31/06")
END GO
