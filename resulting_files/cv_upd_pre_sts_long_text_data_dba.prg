CREATE PROGRAM cv_upd_pre_sts_long_text_data:dba
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
 DECLARE geteventcd(prmmeaning=vc) = f8
 DECLARE getcvcontrol(paramdatasetid=f8,paramuniquestring=vc) = i4
 DECLARE getseason(paramdatecd=f8) = c1
 DECLARE getcuryr(paramdatecd=f8) = i4
 DECLARE fmt_mean = c12 WITH protect
 DECLARE iret = i2 WITH protect
 DECLARE the_dta = f8 WITH protect
 DECLARE return_ec = f8 WITH protect
 DECLARE return_nbr = i4 WITH protect
 DECLARE fall_mean = c12 WITH protect
 DECLARE spring_mean = c12 WITH protect
 DECLARE fall_cd = f8 WITH protect
 DECLARE spring_cd = f8 WITH protect
 DECLARE fall_any_mean = c12 WITH protect
 DECLARE spring_any_mean = c12 WITH protect
 DECLARE fall_any_cd = f8 WITH protect
 DECLARE spring_any_cd = f8 WITH protect
 DECLARE cv_date_set = i4 WITH protect
 DECLARE retseason = c1 WITH protect
 DECLARE century19 = i2 WITH protect
 DECLARE century20 = i2 WITH protect
 DECLARE ret_yr = i4 WITH protect
 SUBROUTINE geteventcd(prmmeaning)
   IF (size(trim(prmmeaning)) > 12)
    CALL echo(build("String too long to be CDF meaning:",prmmeaning))
    RETURN(0.0)
   ENDIF
   SET fmt_mean = trim(prmmeaning)
   SET the_dta = 0.0
   SET return_ec = 0.0
   SET the_dta = uar_get_code_by("MEANING",14003,nullterm(fmt_mean))
   IF (the_dta=0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.cdf_meaning=fmt_mean
      AND cv.active_ind=1
     DETAIL
      the_dta = cv.code_value
     WITH nocounter, maxqual(cv,1)
    ;end select
   ENDIF
   IF (the_dta=0.0)
    CALL echo(build("Could not locate CDF meaning in CS 14003:",fmt_mean))
    RETURN(0.0)
   ENDIF
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.task_assay_cd=the_dta
    DETAIL
     return_ec = dta.event_cd
    WITH nocounter
   ;end select
   RETURN(return_ec)
 END ;Subroutine
 SUBROUTINE getcvcontrol(paramdatasetid,paramuniquestring)
   SET return_nbr = 0
   SELECT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain IN ("CVNET", "CVNet")
     AND dp.parent_entity_id=paramdatasetid
     AND dp.parent_entity_name="CV_DATASET"
     AND cnvtupper(trim(dp.pref_section,3))=cnvtupper(trim(paramuniquestring,3))
    DETAIL
     return_nbr = dp.pref_nbr
    WITH nocounter
   ;end select
   RETURN(return_nbr)
 END ;Subroutine
 SUBROUTINE getseason(paramdatecd)
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (spring_any_cd=paramdatecd)) )
    SET retseason = "S"
   ENDIF
   IF (((fall_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET retseason = "F"
   ENDIF
   RETURN(retseason)
 END ;Subroutine
 SUBROUTINE getcuryr(paramdatecd)
   SET century19 = 0
   SET century20 = 0
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (fall_cd=paramdatecd)) )
    SET ret_yr = 0
   ENDIF
   IF (((spring_any_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET paramdatedisp = uar_get_code_display(paramdatecd)
    SET century19 = findstring("19",trim(paramdatedisp,3))
    SET century20 = findstring("20",trim(paramdatedisp,3))
    IF (century19 > 0)
     SET ret_yr = cnvtint(substring(century19,4,trim(paramdatedisp,3)))
    ELSEIF (century20 > 0)
     SET ret_yr = cnvtint(substring(century20,4,trim(paramdatedisp,3)))
    ELSE
     SET ret_yr = 0
    ENDIF
   ENDIF
   RETURN(ret_yr)
 END ;Subroutine
 DECLARE ctrl_cnt = i4 WITH protect, noconstant(0)
 DECLARE ctrl_idx = i4 WITH protect, noconstant(0)
 DECLARE upp_sts_failed = c1 WITH protect, noconstant("T")
 DECLARE done_upd = vc WITH protect, constant("DONE_CV_UPD_STS_LONG_TEXT_REC")
 DECLARE upd_sts_script = vc WITH protect, constant("CV_UPD_PRE_STS_LONG_TEXT_DATA")
 DECLARE sts_dataset = vc WITH protect, constant("STS")
 DECLARE cvnet_data = vc WITH protect, constant("CVNET")
 DECLARE cv_ds_name = vc WITH protect, constant("CV_DATASET")
 DECLARE cv_case_file_row = vc WITH protect, constant("CV_CASE_FILE_ROW")
 DECLARE upd_sts_long_text = i2 WITH protect, noconstant(0)
 DECLARE cv_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE dataset_internal_name = vc WITH protect, noconstant("STS")
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name=dataset_internal_name
  DETAIL
   cv_dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No such dataset in cv_dataset table!")
  GO TO exit_script
 ENDIF
 SET upd_sts_long_text = getcvcontrol(cv_dataset_id,done_upd)
 IF (upd_sts_long_text != 0)
  CALL cv_log_message("STS Long_text records were already updated, exit!")
  GO TO exit_script
 ENDIF
 IF (validate(cv_action,"notdefined") != "notdefined")
  CALL echo("cv_action record is already defined!")
 ELSE
  RECORD cv_action(
    1 action_list[*]
      2 pref_name = vc
      2 pref_section = vc
      2 pref_str = vc
      2 pref_id = f8
      2 pref_ind = i2
      2 pref_nbr = i2
      2 dataset_id = f8
  )
 ENDIF
 SET stat = alterlist(cv_action->action_list,1)
 SET cv_action->action_list[1].pref_name = sts_dataset
 SET cv_action->action_list[1].pref_section = done_upd
 SET cv_action->action_list[1].pref_str = upd_sts_script
 SET cv_action->action_list[1].pref_nbr = 0
 IF (validate(request,"notdefined") != "notdefined")
  CALL echo("Request Record is already defined!")
 ELSE
  RECORD request(
    1 application_nbr = i4
    1 parent_entity_id = f8
    1 parent_entity_name = c32
    1 person_id = f8
    1 pref_cd = f8
    1 pref_domain = vc
    1 pref_dt_tm = dq8
    1 pref_id = f8
    1 pref_name = vc
    1 pref_nbr = i4
    1 pref_section = vc
    1 pref_str = vc
    1 reference_ind = i2
  )
 ENDIF
 IF (validate(upd_data_rec,"notdefined") != "notdefined")
  CALL echo("Upd_Data_Rec Record is already defined!")
 ELSE
  RECORD upd_data_rec(
    1 max_case_file_row_cnt = i4
    1 dataset[*]
      2 dataset_r_id = f8
      2 case_file_row[*]
        3 cv_case_file_row_id = f8
        3 long_text = vc
  )
 ENDIF
 SET ctrl_cnt = size(cv_action->action_list,5)
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   (dummyt d1  WITH seq = value(ctrl_cnt))
  PLAN (d1)
   JOIN (dp
   WHERE dp.pref_domain=cvnet_data
    AND (dp.pref_section=cv_action->action_list[idx].pref_section)
    AND (dp.pref_name=cv_action->action_list[idx].pref_name))
  DETAIL
   cv_action->action_list[d1.seq].pref_ind = 1, cv_action->action_list[d1.seq].pref_id = dp.pref_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Previous records were sent for updating!")
 ELSE
  CALL echo("New records were sent for insertion!")
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE expand(idx,1,ctrl_cnt,cd.dataset_internal_name,cv_action->action_list[idx].pref_name)
  DETAIL
   num = locateval(idx,1,ctrl_cnt,cd.dataset_internal_name,cv_action->action_list[idx].pref_name),
   cv_action->action_list[num].dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Dataset is not in cv_dataset table, exit!")
  GO TO exit_script
 ENDIF
 CALL echorecord(cv_action)
 FOR (ctrl_idx = 1 TO ctrl_cnt)
   SET request->application_nbr = 4100522
   SET request->parent_entity_id = cv_action->action_list[ctrl_idx].dataset_id
   SET request->parent_entity_name = cv_ds_name
   SET request->pref_domain = cvnet_data
   SET request->pref_id = cv_action->action_list[ctrl_idx].pref_id
   SET request->pref_name = cv_action->action_list[ctrl_idx].pref_name
   SET request->pref_section = cv_action->action_list[ctrl_idx].pref_section
   SET request->pref_str = cv_action->action_list[ctrl_idx].pref_str
   SET request->pref_nbr = cv_action->action_list[ctrl_idx].pref_nbr
   SET request->pref_dt_tm = cnvtdatetime(curdate,curtime3)
   SET request->reference_ind = 1
   IF ((cv_action->action_list[ctrl_idx].pref_ind=0))
    EXECUTE dm_ins_dm_prefs
   ELSE
    EXECUTE dm_upd_dm_prefs
   ENDIF
 ENDFOR
 COMMIT
 SELECT INTO "nl:"
  FROM cv_case_dataset_r ccdr
  WHERE ccdr.dataset_id=cv_dataset_id
  HEAD REPORT
   upd_ds_cnt = 0
  DETAIL
   upd_ds_cnt = (upd_ds_cnt+ 1), stat = alterlist(upd_data_rec->dataset,upd_ds_cnt), upd_data_rec->
   dataset[upd_ds_cnt].dataset_r_id = ccdr.case_dataset_r_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No dataset associates with this case or procedure!")
 ENDIF
 FREE RECORD flat_ds_rec
 RECORD flat_ds_rec(
   1 list[*]
     2 ds_idx = i4
     2 case_file_row_idx = i4
     2 case_file_row_id = f8
 )
 SELECT INTO "nl:"
  FROM cv_case_file_row ccfr
  WHERE expand(idx,1,size(upd_data_rec->dataset,5),ccfr.case_dataset_r_id,upd_data_rec->dataset[idx].
   dataset_r_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   num = locateval(idx,1,size(upd_data_rec->dataset,5),ccfr.case_dataset_r_id,upd_data_rec->dataset[
    idx].dataset_r_id), cnt = (cnt+ 1), stat = alterlist(upd_data_rec->dataset[num].case_file_row,cnt
    ),
   stat = alterlist(flat_ds_rec->list,cnt), upd_data_rec->dataset[num].case_file_row[cnt].
   cv_case_file_row_id = ccfr.cv_case_file_row_id, flat_ds_rec->list[cnt].ds_idx = num,
   flat_ds_rec->list[cnt].case_file_row_idx = cnt, flat_ds_rec->list[cnt].case_file_row_id = ccfr
   .cv_case_file_row_id
  FOOT REPORT
   IF ((upd_data_rec->max_case_file_row_cnt < cnt))
    upd_data_rec->max_case_file_row_cnt = cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No cv_case_file_row data for the dataset_r_id data!")
 ENDIF
 SET lt_updt_cnt = 0
 SELECT INTO "nl:"
  FROM long_text lt
  WHERE expand(idx,1,size(flat_ds_rec->list,5),lt.parent_entity_id,flat_ds_rec->list[idx].
   case_file_row_id)
   AND lt.parent_entity_name=cv_case_file_row
  DETAIL
   num = locateval(idx,1,size(flat_ds_rec->list,5),lt.parent_entity_id,flat_ds_rec->list[idx].
    case_file_row_id), lt_updt_cnt = (lt_updt_cnt+ 1), upd_data_rec->dataset[flat_ds_rec->list[num].
   ds_idx].case_file_row[flat_ds_rec->list[num].case_file_row_idx].long_text = build(trim(lt
     .long_text,3),"|||||||||||||||||||||||||||||||||||")
  WITH nocounter, forupdate(lt)
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No long_text records associated with cv_case_file_row records were selected!")
 ENDIF
 CALL echorecord(upd_data_rec)
 UPDATE  FROM long_text lt,
   (dummyt d  WITH seq = value(size(flat_ds_rec->list,5)))
  SET lt.long_text = upd_data_rec->dataset[flat_ds_rec->list[d.seq].ds_idx].case_file_row[flat_ds_rec
   ->list[d.seq].case_file_row_idx].long_text
  PLAN (d
   WHERE (upd_data_rec->dataset[flat_ds_rec->list[d.seq].ds_idx].case_file_row[flat_ds_rec->list[d
   .seq].case_file_row_idx].cv_case_file_row_id != 0.0))
   JOIN (lt
   WHERE (lt.parent_entity_id=upd_data_rec->dataset[flat_ds_rec->list[d.seq].ds_idx].case_file_row[
   flat_ds_rec->list[d.seq].case_file_row_idx].cv_case_file_row_id)
    AND lt.parent_entity_name=cv_case_file_row)
  WITH nocounter
 ;end update
 IF (curqual != lt_updt_cnt)
  CALL cv_log_message("No long_text records associated with cv_case_file_row records were updated!")
 ENDIF
 SET upp_sts_failed = "F"
#exit_script
 IF (upp_sts_failed="T")
  CALL echo("No Update Performed!")
  ROLLBACK
 ELSE
  CALL echo("Update Committed!")
  UPDATE  FROM dm_prefs dp
   SET dp.pref_nbr = 1
   WHERE dp.pref_domain=cvnet_data
    AND dp.pref_section=done_upd
    AND dp.parent_entity_name=cv_ds_name
    AND dp.parent_entity_id=cv_dataset_id
   WITH nocounter
  ;end update
  COMMIT
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
 DECLARE cv_upd_pre_sts_long_text_data_vrsn = vc WITH private, constant("MOD 004 BM9013 02/24/06")
END GO
