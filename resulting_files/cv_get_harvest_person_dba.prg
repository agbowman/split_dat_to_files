CREATE PROGRAM cv_get_harvest_person:dba
 PROMPT
  "Person_id=" = "",
  "Dataset_id=" = ""
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
 DECLARE harvest_person_id = f8 WITH noconstant(0.0), protect
 DECLARE harvest_dataset_id = f8 WITH noconstant(0.0), protect
 DECLARE encntr_cnt = i4 WITH noconstant(0), protect
 SET harvest_person_id = cnvtreal( $1)
 SET harvest_dataset_id = cnvtreal( $2)
 IF (harvest_person_id <= 0.0)
  CALL cv_log_message(build("ERROR: Invalid harvest_person_id=",harvest_person_id))
  GO TO exit_script
 ELSEIF (harvest_dataset_id <= 0.0)
  CALL cv_log_message(build("ERROR: Invalid harvest_dataset_id=",harvest_dataset_id))
  GO TO exit_script
 ENDIF
 FREE RECORD hrv_encntr
 RECORD hrv_encntr(
   1 qual[*]
     2 encntr_id = f8
 )
 FREE RECORD tmp_encntr
 RECORD tmp_encntr(
   1 qual[*]
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM cv_case cc,
   cv_case_dataset_r ccdr
  PLAN (cc
   WHERE cc.person_id=harvest_person_id)
   JOIN (ccdr
   WHERE ccdr.cv_case_id=cc.cv_case_id
    AND ccdr.dataset_id=harvest_dataset_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(tmp_encntr->qual,cnt), tmp_encntr->qual[cnt].encntr_id = cc
   .encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  WHERE expand(idx,1,size(tmp_encntr->qual,5),e.encntr_id,tmp_encntr->qual[idx].encntr_id)
  HEAD REPORT
   encntr_cnt = 0
  DETAIL
   encntr_cnt = (encntr_cnt+ 1), stat = alterlist(hrv_encntr->qual,encntr_cnt), hrv_encntr->qual[
   encntr_cnt].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 FREE RECORD tmp_encntr
 CALL echorecord(hrv_encntr)
 IF (encntr_cnt=0)
  CALL cv_log_message(build("No encounters found for person=",harvest_person_id,", and dataset=",
    harvest_dataset_id))
 ENDIF
 FOR (n = 1 TO encntr_cnt)
   FREE RECORD cv_hrv_rec
   RECORD cv_hrv_rec(
     1 max_proc_data = i4
     1 max_lesion = i4
     1 max_closdev = i4
     1 max_icdev = i4
     1 max_abstr_data = i4
     1 max_num_files = i4
     1 max_file_rows = i4
     1 dataset_id = f8
     1 validation_script = vc
     1 harvest_display = vc
     1 admit_form_idx = i4
     1 harvest_rec[*]
       2 dataset_id = f8
       2 case_id = f8
       2 person_id = f8
       2 encntr_id = f8
       2 loc_facility_cd = f8
       2 start_dt = dq8
       2 stop_dt = dq8
       2 ops_date = dq8
       2 batch_selection = vc
       2 output_dest = vc
       2 case_dataset_r_id = f8
       2 organization_id = f8
       2 disch_dt_tm = dq8
       2 admit_dt_tm = dq8
       2 birth_dt_tm = dq8
       2 case_dt_tm = dq8
       2 participant_nbr = vc
       2 case_display = vc
       2 valid_flag = i2
       2 error_msg = vc
       2 status_cd = f8
       2 top_parent_event_id = f8
       2 case_abstr_data[*]
         3 nbr_filled_fields = i4
         3 abstr_data_idx = i4
       2 proc_data[*]
         3 case_id = f8
         3 proc_id = f8
         3 event_type_cd = f8
         3 event_type_display = vc
         3 proc_physician_id = f8
         3 proc_start_dt_tm = dq8
         3 proc_end_dt_tm = dq8
         3 cur_dev_num = i4
         3 proc_abstr_data[*]
           4 abstr_data_idx = i4
           4 nbr_filled_fields = i4
         3 lesion[*]
           4 procedure_id = f8
           4 lesion_id = f8
           4 lesion_display = vc
           4 les_abstr_data[*]
             5 abstr_data_idx = i4
             5 nbr_filled_fields = i4
           4 exist_dev_idx[*]
             5 dev_idx = i4
           4 icdevice[*]
             5 procedure_id = f8
             5 device_id = f8
             5 device_display = vc
             5 icd_abstr_data[*]
               6 abstr_data_idx = i4
               6 nbr_filled_fields = i4
             5 exist_dev_idx[*]
               6 dev_idx = i4
       2 closuredevice[*]
         3 device_id = f8
         3 device_display = vc
         3 cd_abstr_data[*]
           4 abstr_data_idx = i4
           4 nbr_filled_fields = i4
         3 exist_dev_idx[*]
           4 dev_idx = i4
       2 abstr_data[*]
         3 xref_id = f8
         3 abstr_data_id = f8
         3 abstr_data_name = vc
         3 case_id = f8
         3 procedure_id = f8
         3 lesion_id = f8
         3 field_type_cd = f8
         3 field_type_meaning = c12
         3 display_field_ind = i2
         3 event_cd = f8
         3 nomenclature_id = f8
         3 result_val = vc
         3 result_id = f8
         3 result_source = vc
         3 result_dt_tm = dq8
         3 task_assay_cd = f8
         3 task_assay_mean = c12
         3 normal_high = f8
         3 normal_low = f8
         3 required_flag = i4
         3 valid_flag = i4
         3 translated_value = vc
         3 error_msg = vc
         3 err_status = i2
         3 status_cd = f8
         3 abstr_type_flag = i4
         3 abstr_idx = i4
         3 proc_data_idx = i4
         3 lesion_data_idx = i4
         3 dev_idx = i4
         3 case_field_id = f8
         3 long_text_id = f8
         3 device_id = f8
         3 collect_start_dt_tm = dq8
         3 collect_stop_dt_tm = dq8
       2 files[*]
         3 dataset_file_id = f8
         3 file_row[*]
           4 case_file_row_id = f8
           4 line = vc
           4 long_text_id = f8
           4 err_status = i2
       2 registry_nbr = f8
       2 form_id = f8
       2 form_type_mean = vc
     1 files[*]
       2 dataset_file_id = f8
       2 file_row[*]
         3 line = vc
         3 long_text_id = f8
         3 err_status = i2
     1 dataset_internal_name = vc
   )
   SET stat = alterlist(cv_hrv_rec->harvest_rec,1)
   SET cv_hrv_rec->harvest_rec[1].encntr_id = hrv_encntr->qual[n].encntr_id
   SET cv_hrv_rec->harvest_rec[1].dataset_id = harvest_dataset_id
   CALL cv_log_message(build("Harvesting encounter:",cv_hrv_rec->harvest_rec[1].encntr_id))
   EXECUTE cv_get_harvest
 ENDFOR
#exit_script
 DECLARE cv_get_harvest_person = vc WITH protect, constant("001 BM9013 02/22/06")
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
