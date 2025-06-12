CREATE PROGRAM cv_add_summary_calc_data:dba
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
 IF ( NOT (validate(add_calc_reply,0)))
  RECORD add_calc_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(cv_calc_rec,0)))
  RECORD cv_calc_rec(
    1 case_id = f8
    1 encntr_id = f8
    1 max_case_abs = i4
    1 max_pro = i4
    1 max_pro_abs = i4
    1 max_les = i4
    1 max_les_abs = i4
    1 case_ins_ind = i2
    1 proc_ins_ind = i2
    1 les_ins_ind = i2
    1 case_ab_cnt = i2
    1 case_abstr_data[*]
      2 case_abstr_id = f8
      2 case_id = f8
      2 event_cd = f8
      2 nomenclature_id = f8
      2 result_val = vc
      2 task_assay_cd = f8
      2 task_assay_meaning = c12
    1 proc_data[*]
      2 procedure_id = f8
      2 case_id = f8
      2 les_attempted = i2
      2 les_dilated = i2
      2 del_ind = i2
      2 proc_abstr_data[*]
        3 procedure_id = f8
        3 cpad_cnt = i2
        3 event_cd = f8
        3 nomenclature_id = f8
        3 proc_abstr_id = f8
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
      2 lesion[*]
        3 lesion_id = f8
        3 procedure_id = f8
        3 dev_cnt = i2
        3 del_ind = i2
        3 les_abstr_data[*]
          4 lesion_abstr_id = f8
          4 event_cd = f8
          4 lesion_id = f8
          4 nomenclature_id = f8
          4 result_val = vc
          4 task_assay_cd = f8
          4 task_assay_meaning = c12
  )
  DECLARE cdf_accv2_num_pci = c12 WITH protect, constant("AC02ANOPCI")
  DECLARE cdf_accv2_mult_pci = c12 WITH protect, constant("AC02AMULT")
  DECLARE cdf_accv2_proc_num = c12 WITH protect, constant("AC02VPROCNUM")
  DECLARE cdf_accv2_cathpci = c12 WITH protect, constant("AC02VCATHPCI")
  DECLARE cdf_accv2_proc_type = c12 WITH protect, constant("AC02VPROCTYP")
  DECLARE cdf_accv2_les_attemped = c12 WITH protect, constant("AC02PATT")
  DECLARE cdf_accv2_les_dilated = c12 WITH protect, constant("AC02PSUCC")
  DECLARE cdf_accv2_proc_results = c12 WITH protect, constant("AC02PREST")
  DECLARE cdf_accv2_les_segment = c12 WITH protect, constant("AC02LSEGT")
  DECLARE cdf_accv2_gw_mean = c12 WITH protect, constant("AC02LGUIDE")
  DECLARE cdf_accv2_pre_stn = c12 WITH protect, constant("AC02LPRSTN")
  DECLARE cdf_accv2_pos_stn = c12 WITH protect, constant("AC02LPSSTN")
  DECLARE cdf_accv2_timi_fl = c12 WITH protect, constant("AC02LPSTIMI")
  DECLARE cdf_lesion_id_num = c12 WITH protect, constant("AC02LLSNO")
  DECLARE xref_internal_name = vc WITH protect, constant("ACC02_LSEGT")
  DECLARE response_int_blank_name = vc WITH protect, constant("ACC02_LSEGT_<BLANK>")
  DECLARE response_proc_resu_suc = vc WITH protect, constant("ACC02_PREST_SUCCESSFUL")
  DECLARE response_proc_resu_psuc = vc WITH protect, constant("ACC02_PREST_PARTIALLY_SUCCESSFUL")
  DECLARE response_proc_resu_usuc = vc WITH protect, constant("ACC02_PREST_UNSUCCESSFUL")
  DECLARE response_post_suc_timi = vc WITH protect, constant(
   "ACC02_LPSTIMI_COMPLETE_AND_BRISK_FLOW_COMPLETE_PERFUSION")
  DECLARE response_gw_suc_pass = vc WITH protect, constant("ACC02_LGUIDE_SUCCESSFUL")
  DECLARE sub_cdf_meaning = c12
 ENDIF
 DECLARE add_calc_failed = c1 WITH protect, noconstant("F")
 INSERT  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(cv_calc_rec->case_abstr_data,5)))
  SET ccad.case_abstr_data_id = seq(card_vas_seq,nextval), ccad.cv_case_id = cv_calc_rec->
   case_abstr_data[d.seq].case_id, ccad.event_cd = cv_calc_rec->case_abstr_data[d.seq].event_cd,
   ccad.nomenclature_id = cv_calc_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_val =
   cv_calc_rec->case_abstr_data[d.seq].result_val, ccad.active_ind = 1,
   ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
   active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
   ccad.data_status_prsnl_id = reqinfo->updt_id,
   ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
   reqinfo->updt_applctx,
   ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE cnvtupper(trim(cv_calc_rec->case_abstr_data[d.seq].task_assay_meaning)) IN (
   cdf_accv2_num_pci, cdf_accv2_mult_pci, cdf_accv2_proc_num))
   JOIN (ccad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in insert cv_case_abstr_data for encounter level calc data!")
 ELSE
  CALL cv_log_message("Success in insert cv_case_abstr_data for encntr calc data!")
 ENDIF
 INSERT  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(cv_calc_rec->max_case_abs))
  SET ccad.case_abstr_data_id = seq(card_vas_seq,nextval), ccad.cv_case_id = cv_calc_rec->case_id,
   ccad.event_cd = cv_calc_rec->case_abstr_data[d.seq].event_cd,
   ccad.nomenclature_id = cv_calc_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_val =
   cv_calc_rec->case_abstr_data[d.seq].result_val, ccad.active_ind = 1,
   ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
   active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
   ccad.data_status_prsnl_id = reqinfo->updt_id,
   ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
   reqinfo->updt_applctx,
   ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE trim(cv_calc_rec->case_abstr_data[d.seq].task_assay_meaning)=cdf_accv2_cathpci)
   JOIN (ccad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in insert cv_case_abstr_data for case level cath/pci data!")
 ELSE
  CALL cv_log_message("Success in insert cv_case_abstr_data for case level cath/pci data!")
 ENDIF
 INSERT  FROM cv_proc_abstr_data cpad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
  SET cpad.proc_abstr_data_id = seq(card_vas_seq,nextval), cpad.procedure_id = cv_calc_rec->
   proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id, cpad.event_cd = cv_calc_rec->proc_data[d1
   .seq].proc_abstr_data[d2.seq].event_cd,
   cpad.nomenclature_id = cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].nomenclature_id,
   cpad.result_val = cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_val, cpad
   .active_ind = 1,
   cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
   active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->data_status_cd,
   cpad.data_status_prsnl_id = reqinfo->updt_id,
   cpad.active_status_prsnl_id = reqinfo->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
   reqinfo->updt_applctx,
   cpad.updt_cnt = 0, cpad.updt_req = reqinfo->updt_req, cpad.updt_id = reqinfo->updt_id
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
   JOIN (cpad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in insert cv_proc_abstr_data for calc data!")
 ELSE
  CALL cv_log_message("Success in insert cv_proc_abstr_data for calc data!")
 ENDIF
 INSERT  FROM cv_les_abstr_data clad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_les)),
   (dummyt d3  WITH seq = value(cv_calc_rec->max_les_abs))
  SET clad.les_abstr_data_id = seq(card_vas_seq,nextval), clad.lesion_id = cv_calc_rec->proc_data[d1
   .seq].lesion[d2.seq].les_abstr_data[d3.seq].lesion_id, clad.event_cd = cv_calc_rec->proc_data[d1
   .seq].lesion[d2.seq].les_abstr_data[d3.seq].event_cd,
   clad.nomenclature_id = cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].
   nomenclature_id, clad.result_val = cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3
   .seq].result_val, clad.active_ind = 1,
   clad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clad.active_status_cd = reqdata->
   active_status_cd, clad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   clad.end_effective_dt_tm = cnvtdatetime(null_date), clad.data_status_cd = reqdata->data_status_cd,
   clad.data_status_prsnl_id = reqinfo->updt_id,
   clad.active_status_prsnl_id = reqinfo->updt_id, clad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), clad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   clad.updt_task = reqinfo->updt_task, clad.updt_app = reqinfo->updt_app, clad.updt_applctx =
   reqinfo->updt_applctx,
   clad.updt_cnt = 0, clad.updt_req = reqinfo->updt_req, clad.updt_id = reqinfo->updt_id
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
   JOIN (d3
   WHERE d3.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5))
   JOIN (clad)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in insert cv_les_abstr_data for calc data!")
 ELSE
  CALL cv_log_message("Success in insert cv_les_abstr_data for calc data!")
 ENDIF
#exit_script
 IF (add_calc_failed="T")
  SET add_calc_reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL cv_log_message(build("Rollback at: ",curprog))
 ELSE
  SET add_calc_reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
  CALL cv_log_message(build("Committed at: ",curprog))
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
 DECLARE cv_add_summary_calc_data = vc WITH private, constant("MOD 002 BM9013 05/23/06")
END GO
