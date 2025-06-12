CREATE PROGRAM cv_chg_dt_tm_format:dba
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
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 IF ( NOT (validate(seconds_ec,0)))
  RECORD seconds_ec(
    1 list[*]
      2 cdf_meaning = vc
      2 dta = f8
  )
 ENDIF
 IF ( NOT (validate(seconds,0)))
  RECORD seconds(
    1 st_list[*]
      2 proc_abstr_data_id = f8
      2 result_dt_tm = dq8
      2 result_val = vc
      2 second_val = i2
    1 bl_list[*]
      2 proc_abstr_data_id = f8
      2 result_dt_tm = dq8
      2 result_val = vc
      2 second_val = i2
  )
 ENDIF
 DECLARE stat = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 SET stat = alterlist(seconds_ec->list,4)
 SET seconds_ec->list[1].cdf_meaning = "AC02PDOST"
 SET seconds_ec->list[2].cdf_meaning = "AC02PDOSTSC"
 SET seconds_ec->list[3].cdf_meaning = "AC02PDOBSD"
 SET seconds_ec->list[4].cdf_meaning = "AC02PDOBSDSC"
 DECLARE st_el_cdf = c12 WITH protect, constant("AC02PDOST")
 DECLARE st_el_sc_cdf = c12 WITH protect, constant("AC02PDOSTSC")
 DECLARE bl_dt_cdf = c12 WITH protect, constant("AC02PDOBSD")
 DECLARE bl_dt_sc_cdf = c12 WITH protect, constant("AC02PDOBSDSC")
 DECLARE st_el_ec = f8 WITH protect, noconstant(0.0)
 DECLARE st_el_sc_ec = f8 WITH protect, noconstant(0.0)
 DECLARE bl_dt_ec = f8 WITH protect, noconstant(0.0)
 DECLARE bl_dt_sc_ec = f8 WITH protect, noconstant(0.0)
 DECLARE cs_dta = i4 WITH protect, constant(14003)
 FOR (cnt = 1 TO size(seconds_ec->list,5))
   SET seconds_ec->list[i].dta = cv_get_code_by("MEANING",cs_dta,seconds_ec->list[i].cdf_meaning)
 ENDFOR
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE expand(idx,1,size(seconds_ec->list,5),dta.task_assay_cd,seconds_ec->list[idx].dta)
  DETAIL
   index = locateval(num,1,size(seconds_ec->list,5),dta.task_assay_cd,seconds_ec->list[idx].dta)
   CASE (seconds_ec->list[index].cdf_meaning)
    OF "AC02PDOST":
     st_el_ec = dta.event_cd
    OF "AC02PDOSTSC":
     st_el_sc_ec = dta.event_cd
    OF "AC02PDOBSD":
     bl_dt_ec = dta.event_cd
    OF "AC02PDOBSDSC":
     bl_dt_sc_ec = dta.event_cd
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("No time in second event_cd found!")
 ENDIF
 SET stat = alterlist(seconds->st_list,1)
 SET stat = alterlist(seconds->bl_list,1)
 SELECT INTO "nl:"
  capd.procedure_id
  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(cv_omf_rec->proc_data,5)))
  PLAN (d)
   JOIN (cpad
   WHERE (cpad.procedure_id=cv_omf_rec->proc_data[d.seq].procedure_id)
    AND cpad.procedure_id != 0.0
    AND cpad.event_cd IN (st_el_ec, st_el_sc_ec, bl_dt_ec, bl_dt_sc_ec))
  DETAIL
   CASE (cpad.event_cd)
    OF st_el_ec:
     seconds->st_list[1].proc_abstr_data_id = cpad.proc_abstr_data_id,seconds->st_list[1].
     result_dt_tm = cpad.result_dt_tm
    OF st_el_sc_ec:
     seconds->st_list[1].second_val = cnvtint(cpad.result_val)
    OF bl_dt_ec:
     seconds->bl_list[1].proc_abstr_data_id = cpad.proc_abstr_data_id,seconds->bl_list[1].
     result_dt_tm = cpad.result_dt_tm
    OF bl_dt_sc_ec:
     seconds->bl_list[1].second_val = cnvtint(cpad.result_val)
   ENDCASE
  FOOT REPORT
   seconds->st_list[1].result_dt_tm = cnvtdatetime(cnvtdate(seconds->st_list[1].result_dt_tm),
    cnvttime(seconds->st_list[1].result_dt_tm)), seconds->st_list[1].result_dt_tm = (seconds->
   st_list[1].result_dt_tm+ (10000000 * seconds->st_list[1].second_val)), seconds->st_list[1].
   result_val = format(seconds->st_list[1].result_dt_tm,"@SHORTDATETIME"),
   seconds->bl_list[1].result_dt_tm = cnvtdatetime(cnvtdate(seconds->bl_list[1].result_dt_tm),
    cnvttime(seconds->bl_list[1].result_dt_tm)), seconds->bl_list[1].result_dt_tm = (seconds->
   bl_list[1].result_dt_tm+ (10000000 * seconds->bl_list[1].second_val)), seconds->bl_list[1].
   result_val = format(seconds->bl_list[1].result_dt_tm,"@SHORTDATETIME")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("No proc_abstr associated with this procedure, program continue!")
 ENDIF
 UPDATE  FROM cv_proc_abstr_data cpad
  SET cpad.result_val = seconds->st_list[1].result_val, cpad.result_dt_tm = cnvtdatetime(seconds->
    st_list[1].result_dt_tm), cpad.active_ind = 1,
   cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
   active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->data_status_cd,
   cpad.data_status_prsnl_id = reqinfo->updt_id,
   cpad.active_status_prsnl_id = reqinfo->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
   reqinfo->updt_applctx,
   cpad.updt_cnt = (cpad.updt_cnt+ 1), cpad.updt_req = reqinfo->updt_req, cpad.updt_id = reqinfo->
   updt_id
  WHERE (seconds->st_list[1].proc_abstr_data_id=cpad.proc_abstr_data_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("Failed in update cv_proc_abstr_data table for ST!")
 ENDIF
 UPDATE  FROM cv_proc_abstr_data cpad
  SET cpad.result_val = seconds->bl_list[1].result_val, cpad.result_dt_tm = cnvtdatetime(seconds->
    bl_list[1].result_dt_tm), cpad.active_ind = 1,
   cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
   active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->data_status_cd,
   cpad.data_status_prsnl_id = reqinfo->updt_id,
   cpad.active_status_prsnl_id = reqinfo->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
   reqinfo->updt_applctx,
   cpad.updt_cnt = (cpad.updt_cnt+ 1), cpad.updt_req = reqinfo->updt_req, cpad.updt_id = reqinfo->
   updt_id
  WHERE (seconds->bl_list[1].proc_abstr_data_id=cpad.proc_abstr_data_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET cv_log_level = cv_log_info
  CALL cv_log_message("Failed in update cv_proc_abstr_data table for BL!")
 ENDIF
 CALL echorecord(seconds,"cer_temp:cv_seconds")
 CALL echorecord(seconds)
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 COMMIT
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
 DECLARE cv_chg_dt_tm_format_vrsn = vc WITH private, constant("MOD 00? BM9013 05/23/06")
END GO
