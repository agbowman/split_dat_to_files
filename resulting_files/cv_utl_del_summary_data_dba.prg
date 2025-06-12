CREATE PROGRAM cv_utl_del_summary_data:dba
 PROMPT
  "Please enter cv_case_id from the case you want to delete = " = " "
 DECLARE input_case_id = f8 WITH protect, noconstant(cnvtreal( $1))
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
 DECLARE sfailure = c1 WITH protect, noconstant("T")
 IF ( NOT (validate(reply)))
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
 IF (input_case_id <= 0.0)
  CALL cv_log_message("Invalid cv_case_id!")
  GO TO exit_script
 ENDIF
 FREE RECORD del_rec
 RECORD del_rec(
   1 max_case_field_cnt = i4
   1 max_case_file_row_cnt = i4
   1 del_dataset[*]
     2 dataset_r_id = f8
     2 case_field[*]
       3 case_field_id = f8
     2 case_file_row[*]
       3 cv_case_file_row_id = f8
   1 del_proc[*]
     2 procedure_id = f8
   1 del_les[*]
     2 lesion_id = f8
   1 del_dev[*]
     2 device_id = f8
 )
 FREE RECORD case_field_flat_rec
 RECORD case_field_flat_rec(
   1 list[*]
     2 case_field_id = f8
     2 cflist_idx = i4
     2 dslist_idx = i4
 )
 FREE RECORD case_file_row_flat_rec
 RECORD case_file_row_flat_rec(
   1 list[*]
     2 case_file_row_id = f8
     2 cfrlist_idx = i4
     2 dslist_idx = i4
 )
 DECLARE batch_size = i4 WITH protect, constant(40)
 DECLARE idx = i4 WITH protect
 DECLARE num1 = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE del_proc_size = i4 WITH protect
 DECLARE del_les_size = i4 WITH protect
 DECLARE del_dev_size = i4 WITH protect
 DECLARE del_dataset_size = i4 WITH protect
 SELECT INTO "NL:"
  FROM cv_case cc
  WHERE cc.cv_case_id=input_case_id
  WITH nocounter, forupdatewait(cc)
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_procedure cp
  WHERE cp.cv_case_id=input_case_id
  HEAD REPORT
   del_pro_cnt = 0
  DETAIL
   del_pro_cnt = (del_pro_cnt+ 1), stat = alterlist(del_rec->del_proc,del_pro_cnt), del_rec->
   del_proc[del_pro_cnt].procedure_id = cp.procedure_id
  FOOT REPORT
   del_proc_size = del_pro_cnt
  WITH nocounter, forupdatewait(cp)
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No procedure associates with this case!")
 ENDIF
 IF (del_proc_size > 0)
  SELECT
   IF (del_proc_size=1)
    WHERE (cl.procedure_id=del_rec->del_proc[1].procedure_id)
     AND cl.lesion_id != 0.0
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_lesion cl
   WHERE expand(idx,1,del_proc_size,cl.procedure_id,del_rec->del_proc[idx].procedure_id)
    AND cl.lesion_id != 0.0
   HEAD REPORT
    del_les_cnt = 0
   DETAIL
    del_les_cnt = (del_les_cnt+ 1), stat = alterlist(del_rec->del_les,del_les_cnt), del_rec->del_les[
    del_les_cnt].lesion_id = cl.lesion_id
   FOOT REPORT
    del_les_size = del_les_cnt
   WITH nocounter, forupdatewait(cl)
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion associates with this case or procedure!")
  ENDIF
  IF (del_les_size > 0)
   SELECT
    IF (del_les_size=1)
     WHERE (cdev.lesion_id=del_rec->del_les[1].lesion_id)
      AND cdev.device_id != 0.0
      AND cdev.cv_case_id=0.0
    ELSE
    ENDIF
    INTO "nl:"
    FROM cv_device cdev
    WHERE expand(idx,1,del_les_size,cdev.lesion_id,del_rec->del_les[idx].lesion_id)
     AND cdev.device_id != 0.0
     AND cdev.cv_case_id=0.0
    HEAD REPORT
     del_dev_cnt = 0
    DETAIL
     del_dev_cnt = (del_dev_cnt+ 1), stat = alterlist(del_rec->del_dev,del_dev_cnt), del_rec->
     del_dev[del_dev_cnt].device_id = cdev.device_id
    FOOT REPORT
     del_dev_size = del_dev_cnt
    WITH nocounter, forupdatewait(cdev)
   ;end select
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_current_default(0)
    CALL cv_log_message("No IC device associates with this lesion or procedure!")
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM cv_device cdev
  WHERE cdev.cv_case_id=input_case_id
   AND cdev.lesion_id=0.0
   AND cdev.device_id != 0.0
  HEAD REPORT
   del_dev_cnt = del_dev_size
  DETAIL
   del_dev_cnt = (del_dev_cnt+ 1), stat = alterlist(del_rec->del_dev,del_dev_cnt), del_rec->del_dev[
   del_dev_cnt].device_id = cdev.device_id
  FOOT REPORT
   del_dev_size = del_dev_cnt
  WITH nocounter, forupdatewait(cdev)
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No closure device associates with this case!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_case_dataset_r ccdr
  WHERE ccdr.cv_case_id=input_case_id
  HEAD REPORT
   del_ds_cnt = 0
  DETAIL
   del_ds_cnt = (del_ds_cnt+ 1), stat = alterlist(del_rec->del_dataset,del_ds_cnt), del_rec->
   del_dataset[del_ds_cnt].dataset_r_id = ccdr.case_dataset_r_id
  FOOT REPORT
   del_dataset_size = del_ds_cnt
  WITH nocounter, forupdatewait(ccdr)
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No dataset associates with this case or procedure!")
 ENDIF
 SELECT
  IF (del_dataset_size=1)
   WHERE (ccf.case_dataset_r_id=del_rec->del_dataset[1].dataset_r_id)
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_case_field ccf
  WHERE expand(idx,1,del_dataset_size,ccf.case_dataset_r_id,del_rec->del_dataset[idx].dataset_r_id)
  HEAD REPORT
   cnt = 0, num1 = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (del_dataset_size=1)
    index = 1
   ELSE
    index = locateval(num1,1,del_dataset_size,ccf.case_dataset_r_id,del_rec->del_dataset[num1].
     dataset_r_id)
   ENDIF
   stat = alterlist(del_rec->del_dataset[index].case_field,cnt), stat = alterlist(case_field_flat_rec
    ->list,cnt), del_rec->del_dataset[index].case_field[cnt].case_field_id = ccf.case_field_id,
   case_field_flat_rec->list[cnt].case_field_id = ccf.case_field_id, case_field_flat_rec->list[cnt].
   cflist_idx = cnt, case_field_flat_rec->list[cnt].dslist_idx = index
  FOOT REPORT
   IF ((del_rec->max_case_field_cnt < cnt))
    del_rec->max_case_field_cnt = cnt
   ENDIF
  WITH nocounter, forupdatewait(ccf)
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No cv_case_field data for the dataset_r_id data!")
 ENDIF
 SELECT
  IF (del_dataset_size=1)
   WHERE (ccfr.case_dataset_r_id=del_rec->del_dataset[1].dataset_r_id)
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_case_file_row ccfr
  WHERE expand(idx,1,del_dataset_size,ccfr.case_dataset_r_id,del_rec->del_dataset[idx].dataset_r_id)
  HEAD REPORT
   cnt = 0, num1 = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (del_dataset_size=1)
    index = 1
   ELSE
    index = locateval(num1,1,del_dataset_size,ccfr.case_dataset_r_id,del_rec->del_dataset[num1].
     dataset_r_id)
   ENDIF
   stat = alterlist(del_rec->del_dataset[index].case_file_row,cnt), stat = alterlist(
    case_file_row_flat_rec->list,cnt), del_rec->del_dataset[index].case_file_row[cnt].
   cv_case_file_row_id = ccfr.cv_case_file_row_id,
   case_file_row_flat_rec->list[cnt].case_file_row_id = ccfr.cv_case_file_row_id,
   case_file_row_flat_rec->list[cnt].cfrlist_idx = cnt, case_file_row_flat_rec->list[cnt].dslist_idx
    = index
  FOOT REPORT
   IF ((del_rec->max_case_file_row_cnt < cnt))
    del_rec->max_case_file_row_cnt = cnt
   ENDIF
  WITH nocounter, forupdatewait(ccfr)
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No cv_case_file_row data for the dataset_r_id data!")
 ENDIF
 CALL echorecord(del_rec,"home:delrec.txt")
 IF (del_dev_size > 0)
  SELECT
   IF (del_dev_size=1)
    WHERE (cdad.device_id=del_rec->del_dev[1].device_id)
     AND cdad.dev_abstr_data_id != 0.0
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_dev_abstr_data cdad
   WHERE expand(idx,1,del_dev_size,cdad.device_id,del_rec->del_dev[idx].device_id)
    AND cdad.dev_abstr_data_id != 0.0
   WITH nocounter, forupdatewait(cdad)
  ;end select
  IF (curqual=0)
   CALL cv_log_message("No device abstract fields found for this case")
  ELSE
   IF (del_dev_size=1)
    DELETE  FROM cv_dev_abstr_data cdad
     WHERE (cdad.device_id=del_rec->del_dev[1].device_id)
      AND cdad.dev_abstr_data_id != 0.0
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM cv_dev_abstr_data cdad
     WHERE expand(idx,1,del_dev_size,cdad.device_id,del_rec->del_dev[idx].device_id)
      AND cdad.dev_abstr_data_id != 0.0
     WITH nocounter
    ;end delete
   ENDIF
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_message("No device abstract fields were deleted for this case")
   ENDIF
  ENDIF
  IF (del_dev_size=1)
   DELETE  FROM cv_device cdev
    WHERE (cdev.device_id=del_rec->del_dev[1].device_id)
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM cv_device cdev
    WHERE expand(idx,1,del_dev_size,cdev.device_id,del_rec->del_dev[idx].device_id)
    WITH nocounter
   ;end delete
  ENDIF
  IF (curqual=0)
   CALL cv_log_message("No device fields were deleted for this case")
  ENDIF
 ENDIF
 IF (del_les_size > 0)
  SELECT
   IF (del_les_size=1)
    WHERE (clad.lesion_id=del_rec->del_les[1].lesion_id)
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_les_abstr_data clad
   WHERE expand(idx,1,del_les_size,clad.lesion_id,del_rec->del_les[idx].lesion_id)
   WITH nocounter, forupdatewait(clad)
  ;end select
  IF (curqual=0)
   CALL cv_log_message("No lesion abstract fields were found with this case or procedure!")
  ELSE
   IF (del_les_size=1)
    DELETE  FROM cv_les_abstr_data clad
     WHERE (clad.lesion_id=del_rec->del_les[1].lesion_id)
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM cv_les_abstr_data clad
     WHERE expand(idx,1,del_les_size,clad.lesion_id,del_rec->del_les[idx].lesion_id)
     WITH nocounter
    ;end delete
   ENDIF
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_current_default(0)
    CALL cv_log_message("No lesion abstract fields were deleted with this case or procedure!")
   ENDIF
  ENDIF
  IF (del_les_size=1)
   DELETE  FROM cv_lesion cl
    WHERE (cl.lesion_id=del_rec->del_les[1].lesion_id)
     AND cl.lesion_id != 0.0
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM cv_lesion cl
    WHERE expand(idx,1,del_les_size,cl.lesion_id,del_rec->del_les[idx].lesion_id)
     AND cl.lesion_id != 0.0
    WITH nocounter
   ;end delete
  ENDIF
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion fields were deleted with this case or procedure!")
  ENDIF
 ENDIF
 IF (del_proc_size > 0)
  SELECT
   IF (del_proc_size=1)
    WHERE (cpad.procedure_id=del_rec->del_proc[1].procedure_id)
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_proc_abstr_data cpad
   WHERE expand(idx,1,del_proc_size,cpad.procedure_id,del_rec->del_proc[idx].procedure_id)
   WITH nocounter, forupdatewait(cpad)
  ;end select
  IF (curqual=0)
   CALL cv_log_message(concat("No procedure abstract fields were found with ",
     " this case or procedure!"))
  ELSE
   IF (del_proc_size=1)
    DELETE  FROM cv_proc_abstr_data cpad
     WHERE (cpad.procedure_id=del_rec->del_proc[1].procedure_id)
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM cv_proc_abstr_data cpad
     WHERE expand(idx,1,del_proc_size,cpad.procedure_id,del_rec->del_proc[idx].procedure_id)
     WITH nocounter
    ;end delete
   ENDIF
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_current_default(0)
    CALL cv_log_message(concat("No procedure abstract fields were deleted ",
      " with this case or procedure!"))
   ENDIF
  ENDIF
  IF (del_proc_size=1)
   DELETE  FROM cv_procedure cp
    WHERE (cp.procedure_id=del_rec->del_proc[1].procedure_id)
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM cv_procedure cp
    WHERE expand(idx,1,del_proc_size,cp.procedure_id,del_rec->del_proc[idx].procedure_id)
    WITH nocounter
   ;end delete
  ENDIF
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No procedure fields were deleted with this case!")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM cv_case_abstr_data ccad
  WHERE ccad.cv_case_id=input_case_id
  WITH nocounter, forupdatewait(ccad)
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No cv case abstract fields were found with this case!")
 ELSE
  DELETE  FROM cv_case_abstr_data ccad
   WHERE ccad.cv_case_id=input_case_id
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv case abstract fields were deleted with this case!")
  ENDIF
 ENDIF
 IF (del_dataset_size > 0
  AND (del_rec->max_case_field_cnt > 0))
  SET cur_list_size = size(case_field_flat_rec->list,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(case_field_flat_rec->list,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET case_field_flat_rec->list[idx].case_field_id = case_field_flat_rec->list[cur_list_size].
    case_field_id
  ENDFOR
  DELETE  FROM cv_case_field ccf,
    (dummyt d  WITH seq = value(loop_cnt))
   SET ccf.seq = 1
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ccf
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ccf.case_field_id,case_field_flat_rec->list[
     idx].case_field_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_field records were deleted for this case!")
  ENDIF
 ENDIF
 IF (del_dataset_size > 0
  AND (del_rec->max_case_file_row_cnt > 0))
  DELETE  FROM cv_case_file_row ccfr
   WHERE expand(idx,1,size(case_file_row_flat_rec->list,5),ccfr.cv_case_file_row_id,
    case_file_row_flat_rec->list[idx].case_file_row_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_case_file_row records were deleted for this case!")
  ENDIF
 ENDIF
 IF (currdbname != "DTEST")
  CALL echo("Deleting From LONG_TEXT")
  IF (del_dataset_size > 0
   AND (del_rec->max_case_field_cnt > 0))
   SET nstart = 1
   SELECT INTO "nl:"
    FROM long_text lt,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.parent_entity_id,case_field_flat_rec->
      list[idx].case_field_id)
      AND lt.parent_entity_name="CV_CASE_FIELD")
    WITH nocounter, forupdatewait(lt)
   ;end select
   IF (curqual=0)
    CALL cv_log_message(concat("No long_text records associated with ",
      " cv_case_field records were found from this case!"))
   ENDIF
   SET nstart = 1
   DELETE  FROM long_text lt,
     (dummyt d  WITH seq = value(loop_cnt))
    SET lt.seq = 1
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.parent_entity_id,case_field_flat_rec->
      list[idx].case_field_id)
      AND lt.parent_entity_name="CV_CASE_FIELD")
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_current_default(0)
    CALL cv_log_message(concat("No long_text records associated with ",
      " cv_case_field records were deleted from this case!"))
   ENDIF
  ENDIF
  IF (del_dataset_size > 0
   AND (del_rec->max_case_file_row_cnt > 0))
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE expand(idx,1,size(case_file_row_flat_rec->list,5),lt.parent_entity_id,
     case_file_row_flat_rec->list[idx].case_file_row_id)
     AND lt.parent_entity_name="CV_CASE_FILE_ROW"
    WITH nocounter, forupdatewait(lt)
   ;end select
   IF (curqual=0)
    CALL cv_log_message(concat("No long_text records associated with ",
      " cv_case_file_row records were found from this case!"))
   ENDIF
   DELETE  FROM long_text lt
    WHERE expand(idx,1,size(case_file_row_flat_rec->list,5),lt.parent_entity_id,
     case_file_row_flat_rec->list[idx].case_file_row_id)
     AND lt.parent_entity_name="CV_CASE_FILE_ROW"
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET cv_log_level = cv_log_debug
    CALL cv_log_current_default(0)
    CALL cv_log_message(concat("No long_text records associated with ",
      " cv_case_file_row records were deleted from this case!"))
   ENDIF
  ENDIF
 ELSE
  CALL echo("CURRDBNAME=DTEST ...  Skipped LONG_TEXT deletes")
 ENDIF
 DELETE  FROM cv_case_dataset_r ccdr
  WHERE ccdr.cv_case_id=input_case_id
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No cv case dataset fields were deleted with this case!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_count_data ccd
  WHERE ccd.parent_entity_id=input_case_id
   AND ccd.parent_entity_name IN ("CV_CASE", "CV_PROCEDURE", "CV_LESION")
  WITH nocounter, forupdatewait(ccd)
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No cv_count_data records were found with this case!")
 ELSE
  DELETE  FROM cv_count_data ccd
   WHERE ccd.parent_entity_id=input_case_id
    AND ccd.parent_entity_name IN ("CV_CASE", "CV_PROCEDURE", "CV_LESION")
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET cv_log_level = cv_log_debug
   CALL cv_log_current_default(0)
   CALL cv_log_message("No cv_count_data records were deleted with this case!")
  ENDIF
 ENDIF
 DELETE  FROM cv_case cc
  WHERE cc.cv_case_id=input_case_id
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_debug
  CALL cv_log_current_default(0)
  CALL cv_log_message("No case field was deleted with this case!")
 ENDIF
 SET sfailure = "F"
#exit_script
 IF (sfailure="T")
  SET reply->status_data.status = "F"
  ROLLBACK
  CALL cv_log_message("Check cv_case_id in cv_case table and try again!")
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
  CALL cv_log_message(concat("The records associated with the case are ",
    " successfully removed and command is committed!"))
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
 DECLARE cv_utl_del_summary_data_vrsn = vc WITH private, constant("MOD 007 05/05/06 BM9013")
END GO
