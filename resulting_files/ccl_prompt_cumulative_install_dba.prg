CREATE PROGRAM ccl_prompt_cumulative_install:dba
 DECLARE importform(strimport=vc) = null
 DECLARE checkimportversion(nversion=i4) = i2
 DECLARE errormsg = vc WITH public
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
 IF (((curcclrev < 7.8) OR ((((validate(currevminor2,- (1))=- (1))) OR (curcclrev=7.8
  AND currevminor2 < 14)) )) )
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success: CCL version 7.8.5 or later required"
  CALL echorecord(readme_data)
  EXECUTE dm_readme_status
  RETURN
 ENDIF
 SET strdir = "cer_install"
 SET readme_data->status = "F"
 SET errorcount = 0
 CALL importform("dpl_sys_default_template.dat")
 CALL importform("ccl_dlg_get_person_info.dat")
 CALL importform("ccl_dlg_getperson.dat")
 CALL importform("ccl_dlg_ds_utility.dat")
 CALL importform("ccl_dlg_get_pers_by_fullname.dat")
 DELETE  FROM ccl_prompt_programs
  WHERE program_name="CCL_DS_GETLOCHIERARCHY_TEST"
  WITH nocounter
 ;end delete
 EXECUTE ccl_prompt_ins_datasrc "ccl_ds_getlochierarchy", 0, "Location Hierarchy",
 "Tree control data source for patient locations", 0
 CALL importform("cclprot.dat")
 CALL importform("cclglos.dat")
 CALL importform("prompthelp.dat")
 CALL importform("eks_monitor.dat")
 CALL importform("ccl_prompt_audit.dat")
 CALL importform("ccl_dlg_get_person_info.dat")
 CALL importform("eks_chk_event_orderable.dat")
 CALL importform("ccl_prompt_pck14577_test.dat")
 CALL importform("prompthelp_dataset.dat")
 CALL importform("prompthelp_tn20040902.dat")
 CALL importform("prompthelp_tn20040903.dat")
 CALL importform("prompthelp_tn20050101.dat")
 CALL importform("eks_action_template_count.dat")
 CALL importform("eks_dlg_audit.dat")
 CALL importform("eks_get_notify_messages.dat")
 CALL importform("eks_perf_audit.dat")
 CALL importform("eks_rpt_ekm_events.dat")
 CALL importform("eks_rpt_ekmby_template.dat")
 CALL importform("eks_rpt_expired_ekms.dat")
 CALL importform("eks_rpt_modules.dat")
 CALL importform("eks_rpt_templates.dat")
 CALL importform("eks_system_audit.dat")
 CALL importform("eks_get_notify_prefs.dat")
 CALL importform("eks_notify_query.dat")
 CALL importform("ccl_ord_reports.dat")
 CALL importform("ccl_dcp_reports.dat")
 CALL importform("discern_menu_dcp_report_driver.dat")
 CALL importform("cclsrvhelp.dat")
 CALL importform("ccl_get_hostnames.dat")
 CALL importform("ccl_get_rtlfiles.dat")
 CALL importform("ccl_tablecons.dat")
 CALL importform("ccl_sqlplan.dat")
 CALL importform("ccl_prompt_rtlfiles.dat")
 CALL importform("ccl_scripterr.dat")
 IF (errorcount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "discern standard form installation completed with no errors"
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE importform(strimport)
   IF (errorcount > 0)
    RETURN
   ENDIF
   IF (cursys="AXP")
    SET strimportname = concat(trim(logical(strdir)),cnvtlower(trim(strimport)))
   ELSE
    SET strimportname = concat(trim(logical(strdir)),"/",cnvtlower(trim(strimport)))
   ENDIF
   IF (findfile(nullterm(strimportname))=0)
    SET errorcount = (errorcount+ 1)
    SET readme_data->message = concat("%CCL-F-CCL_PROMPT_CUMULATIVE_INSTALL FILE NOT FOUND '",trim(
      strimportname),"'")
   ELSE
    CALL echo(strimportname)
    SET errorflag = 0
    EXECUTE ccl_prompt_importform nullterm(strimportname)
    IF (errorflag != 0)
     SET errorcount = (errorcount+ 1)
     SET readme_data->message = substring(1,255,concat(strimport,errormsg))
    ENDIF
   ENDIF
 END ;Subroutine
END GO
