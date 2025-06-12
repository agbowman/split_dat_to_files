CREATE PROGRAM cv_import_alphas:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET oef_error = "F"
 SET oef_error_type = 0
 SET oefid1 = 0
 RECORD temp_act(
   1 qual[*]
     2 activity_type_cd = f8
     2 task_assay_cd = f8
 )
 RECORD request(
   1 qual[*]
     2 nomenclature_id = f8
     2 reference_range_factor_id = f8
     2 sequence = i4
     2 use_units_ind = i2
     2 result_process_cd = f8
     2 default_ind = i2
     2 active_ind = i2
     2 description = vc
     2 reference_ind = i2
     2 multi_alpha_sort_order = i4
     2 result_value = f8
 )
 SET cv_log_file_name = "cer_temp:cv_import_alphas.dat"
 SET stat = alterlist(temp_act->qual,size(requestin->list_0,5))
 SET stat = alterlist(request->qual,size(requestin->list_0,5))
 SET act_type_cd = 0.0
 SELECT INTO "nl:"
  t.*
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.display_key="DIAGNOSTICCARDIOLOGY")
  DETAIL
   act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL cv_log_message(build("The activity_type is :",act_type_cd))
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (dta
   WHERE dta.mnemonic_key_cap=trim(cnvtupper(requestin->list_0[d.seq].dta_mnemonic))
    AND dta.activity_type_cd=act_type_cd)
   JOIN (rrf
   WHERE rrf.task_assay_cd=dta.task_assay_cd)
  ORDER BY d.seq, rrf.task_assay_cd
  HEAD REPORT
   cnt = 0
  HEAD rrf.task_assay_cd
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), request->qual[d.seq].reference_range_factor_id = rrf.reference_range_factor_id,
   request->qual[d.seq].sequence = cnt,
   request->qual[d.seq].use_units_ind = cnvtint(requestin->list_0[d.seq].use_units_ind), request->
   qual[d.seq].default_ind = cnvtint(requestin->list_0[d.seq].default_ind), request->qual[d.seq].
   active_ind = 1,
   request->qual[d.seq].description = trim(requestin->list_0[d.seq].mnemonic), request->qual[d.seq].
   reference_ind = cnvtint(requestin->list_0[d.seq].reference_ind), request->qual[d.seq].
   multi_alpha_sort_order = cnvtint(requestin->list_0[d.seq].multi_alpha_sort_order),
   request->qual[d.seq].result_value = cnvtreal(requestin->list_0[d.seq].result_value)
  WITH nocounter
 ;end select
 CALL cv_log_message(build("The qual is :",curqual))
 SET alpha_cd = 0.0
 SET source_vocab_cd = 0.0
 SELECT INTO "nl:"
  t.*
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=401
    AND cv.cdf_meaning="ALPHA RESPON")
  DETAIL
   alpha_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.*
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=400
    AND cv.cdf_meaning="PTCARE")
  DETAIL
   source_vocab_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL cv_log_message(build("The alpha_cd is :",alpha_cd))
 CALL cv_log_message(build("The source_vocab_cd is :",source_vocab_cd))
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (n
   WHERE n.principle_type_cd=alpha_cd
    AND n.source_vocabulary_cd=source_vocab_cd
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND trim(n.mnemonic)=trim(requestin->list_0[d.seq].mnemonic))
  DETAIL
   request->qual[d.seq].nomenclature_id = n.nomenclature_id
  WITH nocounter
 ;end select
 CALL cv_log_message(build("The qual is :",curqual))
 CALL echo("Adding Alphas!")
 CALL echorecord(request,"cer_temp:cv_alpha_log.txt")
 CALL echorecord(requestin,"cer_temp:cv_alpha_in.txt")
 EXECUTE orc_add_alpha_responses
 COMMIT
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
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
END GO
