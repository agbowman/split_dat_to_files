CREATE PROGRAM cv_get_harvest_audit:dba
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
 IF (validate(context,"NotDefined") != "NotDefined")
  CALL cv_log_message("Context is already defined!")
 ELSE
  RECORD context(
    1 context_ind = i4
    1 start_id = f8
    1 maxqual = i4
  )
 ENDIF
 IF (validate(reply,"NotDefined") != "NotDefined")
  CALL cv_log_message("Reply is already defined!")
 ELSE
  RECORD reply(
    1 caserec[*]
      2 case_id = f8
      2 error_msg = vc
      2 status_cd = f8
      2 status_disp = vc
      2 status_mean = vc
      2 chart_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 name_full_formatted = vc
      2 form_id = f8
      2 form_ref_id = f8
      2 record_id = f8
      2 fieldrec[*]
        3 field_name = vc
        3 field_val = vc
        3 error_msg = vc
        3 status_cd = f8
        3 status_disp = vc
        3 status_mean = vc
        3 translated_val = vc
        3 case_field_id = f8
        3 long_text_id = f8
        3 dev_idx = i2
        3 lesion_idx = i2
        3 form_idx = i2
      2 sub_case[*]
        3 case_id = f8
        3 form_type_mean = vc
        3 form_id = f8
        3 form_ref_id = f8
    1 files[*]
      2 filename = vc
      2 info_line[*]
        3 new_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 max_sub_case_cnt = i4
    1 case_ids[*]
      2 cv_case_id = f8
  )
 ENDIF
 FREE RECORD mds
 RECORD mds(
   1 caserec[*]
     2 use_mds = i2
 )
 DECLARE max_status_cd(code1=f8,code2=f8) = f8
 IF (validate(cv_status_cds)=0)
  DECLARE max_status_loc1 = i4 WITH protect
  DECLARE max_status_loc2 = i4 WITH protect
  DECLARE max_status_idx = i4 WITH protect
  RECORD cv_status_cds(
    1 qual[5]
      2 status_cd = f8
  )
  SET cv_status_cds->qual[1].status_cd = uar_get_code_by("MEANING",25973,"NOERROR")
  SET cv_status_cds->qual[2].status_cd = uar_get_code_by("MEANING",25973,"HARVNOERROR")
  SET cv_status_cds->qual[3].status_cd = uar_get_code_by("MEANING",25973,"WARNING")
  SET cv_status_cds->qual[4].status_cd = uar_get_code_by("MEANING",25973,"REPORTWARN")
  SET cv_status_cds->qual[5].status_cd = uar_get_code_by("MEANING",25973,"ERROR")
  IF ((((cv_status_cds->qual[1].status_cd=0.0)) OR ((((cv_status_cds->qual[2].status_cd=0.0)) OR ((((
  cv_status_cds->qual[3].status_cd=0.0)) OR ((((cv_status_cds->qual[4].status_cd=0.0)) OR ((
  cv_status_cds->qual[5].status_cd=0.0))) )) )) )) )
   EXECUTE cv_log_struct  WITH replace("REQUEST","CV_STATUS_CDS")
   CALL cv_log_message("FAILURE IN LOOKUP ON CV_STATUS_CDS")
  ENDIF
 ENDIF
 SUBROUTINE max_status_cd(code1,code2)
   SET max_status_loc1 = locateval(max_status_idx,1,5,code1,cv_status_cds->qual[max_status_idx].
    status_cd)
   SET max_status_loc2 = locateval(max_status_idx,1,5,code2,cv_status_cds->qual[max_status_idx].
    status_cd)
   IF (((max_status_loc1=0) OR (max_status_loc2=0)) )
    RETURN(0.0)
   ELSEIF (max_status_loc1 > max_status_loc2)
    RETURN(cv_status_cds->qual[max_status_loc1].status_cd)
   ELSE
    RETURN(cv_status_cds->qual[max_status_loc2].status_cd)
   ENDIF
 END ;Subroutine
 DECLARE cnt = i2 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE surgproc_flag = i1 WITH constant(1), public
 DECLARE admit_flag = i1 WITH constant(2), public
 DECLARE disch_flag = i1 WITH constant(3), public
 DECLARE datecd_flag = i1 WITH constant(4), public
 DECLARE non_mds_status_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25973,
   "HARVNOERROR"))
 DECLARE non_mds_text_id = f8 WITH noconstant(0.0), protect
 DECLARE pci_proc_no = i4 WITH constant(2), protect
 DECLARE omit_normal_data_ind = i2 WITH noconstant(0), protect
 DECLARE noerrorcd = f8 WITH noconstant(0.0), protect
 IF (validate(request->omit_normal_data_ind))
  SET omit_normal_data_ind = request->omit_normal_data_ind
 ENDIF
 DECLARE setmds(null) = null WITH private
 IF ((request->date_cd > 0))
  IF (validate(request_date,"notdefined") != "notdefined")
   CALL cv_log_message("request_date is already defined !")
  ELSE
   RECORD request_date(
     1 date_range[*]
       2 code_value = f8
       2 date_meaning = c12
       2 date_display = vc
       2 from_date_str = vc
       2 to_date_str = vc
       2 from_date = dq8
       2 to_date = dq8
   )
  ENDIF
  IF (validate(reply_date,"notdefined") != "notdefined")
   CALL cv_log_message("reply_date is already defined !")
  ELSE
   RECORD reply_date(
     1 date_range[*]
       2 to_date_str = vc
       2 from_date_str = vc
       2 to_date = dq8
       2 from_date = dq8
       2 translated_val = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET stat = alterlist(request_date->date_range,1)
  SET request_date->date_range[1].code_value = request->date_cd
  EXECUTE cv_get_date_range  WITH replace("REQUEST","REQUEST_DATE"), replace("REPLY","REPLY_DATE")
  SET request->start_dt = reply_date->date_range[1].from_date
  SET request->stop_dt = reply_date->date_range[1].to_date
  CALL echo("Finished with dates")
 ENDIF
 DECLARE context_ind = i2 WITH protect, noconstant(0)
 DECLARE maxqualrows = i4 WITH protect, noconstant(0)
 DECLARE start_id = f8 WITH protect, noconstant(0.0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE case_cnt = i4 WITH protect, noconstant(0)
 DECLARE sfailed = c1 WITH protect, noconstant("F")
 DECLARE sts_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE acc_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE acc_sts_flag = i2 WITH protect, noconstant(0)
 DECLARE registry_version = i2 WITH protect, noconstant(0)
 DECLARE max_field_rec = i4 WITH protect, noconstant(0)
 DECLARE part_nbr_str = vc WITH protect, noconstant(" ")
 DECLARE cv_icdevice_str = vc WITH protect, constant("ICD=")
 DECLARE cv_clsdevice_str = vc WITH protect, constant("CLS=")
 DECLARE cv_lesion_str = c7 WITH protect, constant("LES=")
 DECLARE cv_proc_str = vc WITH protect, constant("PROC=")
 DECLARE cv_dataset_str = vc WITH protect, noconstant("-99999999")
 DECLARE admit_form_mean = vc WITH protect, noconstant("ADMIT")
 DECLARE labvisit_form_mean = vc WITH protect, noconstant("LABVISIT")
 DECLARE minimum_age = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect
 DECLARE idx2 = i4 WITH protect
 DECLARE idx3 = i4 WITH protect
 DECLARE idx4 = i4 WITH protect
 DECLARE num = i4 WITH protect
 CALL echorecord(request,"cer_temp:cv_audit_req.txt")
 SET acc_sts_flag = getcvcontrol(request->dataset_id,"CV_FLAG_CTRL_ACC_OR_STS_ETC")
 SET registry_version = getcvcontrol(request->dataset_id,"REGISTRY_VERSION")
 CALL echo(build("acc_sts_flag=",acc_sts_flag))
 IF (acc_sts_flag=1)
  SET minimum_age = 18
  SET acc_dataset_id = request->dataset_id
 ELSEIF (acc_sts_flag=2)
  SET minimum_age = 20
  SET sts_dataset_id = request->dataset_id
 ELSE
  CALL cv_log_message("CV_FLAG_CTRL_ACC_OR_STS_ETC was missing or invalid")
  GO TO exit_script
 ENDIF
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET context_ind = 1
  SET start_id = context->start_id
  SET maxqualrows = context->maxqual
  CALL echo("There is context!")
 ELSE
  SET start_id = 0.0
  SET maxqualrows = request->maxqual
  CALL echo("No context!")
  IF (validate(context->context_ind,0) != 0)
   RECORD context(
     1 context_ind = i4
     1 start_id = f8
     1 maxqual = i4
   )
  ENDIF
 ENDIF
 DECLARE person_cnt = i4 WITH noconstant(0), protect
 DECLARE person_idx = i4 WITH noconstant(0), protect
 DECLARE part_idx = i4 WITH noconstant(0), protect
 DECLARE dup_flg = i2 WITH noconstant(0), protect
 DECLARE alias_pool_cs = i4 WITH constant(263), protect
 DECLARE alias_pool_mean_prefix = c6 WITH constant("STSPID"), protect
 DECLARE plist_cnt = i4 WITH noconstant(0), protect
 DECLARE plist_idx = i4 WITH noconstant(0), protect
 DECLARE temp_id = f8 WITH noconstant(0.0), protect
 DECLARE patient_cnt = i4 WITH noconstant(0), protect
 SET person_cnt = size(request->person,5)
 SET patient_cnt = size(request->patient,5)
 IF ( NOT (validate(plist)))
  RECORD plist(
    1 qual[*]
      2 person_id = f8
  )
 ENDIF
 IF ( NOT (validate(encntr_list)))
  RECORD encntr_list(
    1 qual[*]
      2 encntr_id = f8
  )
 ENDIF
 IF (patient_cnt > 0)
  IF (acc_sts_flag=2)
   SELECT INTO "nl:"
    pa.person_id
    FROM code_value cv,
     person_alias pa
    PLAN (pa
     WHERE expand(idx,1,size(request->patient,5),pa.alias,request->patient[idx].patient_id))
     JOIN (cv
     WHERE cv.code_value=pa.alias_pool_cd
      AND cv.code_set=263
      AND cv.cdf_meaning=patstring(concat(alias_pool_mean_prefix,"*"))
      AND cv.active_ind=1)
    DETAIL
     CALL echo(build("Found alias:",pa.alias,", for person_id=",pa.person_id)), plist_cnt = (
     plist_cnt+ 1), stat = alterlist(plist->qual,plist_cnt),
     plist->qual[plist_cnt].person_id = pa.person_id
    WITH nocounter
   ;end select
  ELSE
   FOR (person_idx = 1 TO patient_cnt)
    SET temp_id = cnvtreal(request->patient[person_idx].patient_id)
    IF (temp_id > 0.0)
     SET plist_cnt = (plist_cnt+ 1)
     SET stat = alterlist(plist->qual,plist_cnt)
     SET plist->qual[plist_cnt].person_id = temp_id
    ENDIF
   ENDFOR
  ENDIF
  IF (plist_cnt > 0)
   FOR (plist_idx = 1 TO plist_cnt)
     SET dup_flg = 0
     FOR (person_idx = 1 TO person_cnt)
       IF ((request->person[person_idx].person_id=plist->qual[plist_idx].person_id))
        SET dup_flg = 1
        SET person_idx = person_cnt
       ENDIF
     ENDFOR
     IF (dup_flg=0)
      CALL echo(build("Inserting person",plist->qual[plist_idx].person_id))
      SET person_cnt = (person_cnt+ 1)
      SET stat = alterlist(request->person,person_cnt)
      SET request->person[person_cnt].person_id = plist->qual[plist_idx].person_id
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (sts_dataset_id > 0.0)
  DECLARE export_both_sts_flag = i2 WITH protect, noconstant(0)
  DECLARE export_both_sts2_flag = i2 WITH protect, noconstant(0)
  DECLARE export_both_sts3_flag = i2 WITH protect, noconstant(0)
  SET export_both_sts_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS_FLAG")
  SET export_both_sts2_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS2_FLAG")
  SELECT
   IF (((export_both_sts_flag=1) OR (((export_both_sts2_flag=1) OR (validate(g_export_file_type_ind,0
    )=2)) )) )
    WHERE cd.dataset_internal_name="STS*"
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_dataset cd
   WHERE (cd.dataset_id=request->dataset_id)
   HEAD REPORT
    dataset_holder = 0.0
   DETAIL
    dataset_holder = cd.dataset_id, cv_dataset_str = concat(cv_dataset_str,",",trim(cnvtstring(
       dataset_holder)))
   FOOT REPORT
    cv_dataset_str = concat("ccdr.dataset_id in (",cv_dataset_str,")")
   WITH nocounter
  ;end select
  CALL echo(build("cv_dataset_str: ",cv_dataset_str))
 ENDIF
 DECLARE req_ccdr_str = vc
 DECLARE req_cc_str = vc
 DECLARE req_ccf_str = vc
 DECLARE req_ccad_str = vc
 SET req_ccdr_str = "0=0"
 SET req_cc_str = "0=0"
 SET req_ccf_str = "0=0"
 SET req_ccad_str = "0=0"
 DECLARE req_dataset_id = vc
 IF ((request->dataset_id > 0.0))
  SET req_dataset_id = concat("ccdr.dataset_id = ",trim(cnvtstring(request->dataset_id)))
 ENDIF
 SET req_ccdr_str = concat(req_dataset_id)
 IF (trim(req_ccdr_str,3)="and")
  SET req_ccdr_str = "0=0"
 ENDIF
 DECLARE req_part_nbr = vc
 DECLARE req_part_nbr_str = vc
 IF (size(request->part_nbr,5) <= 0)
  SET req_part_nbr = ""
  SET req_part_nbr_str = "0=0"
 ELSE
  SET req_part_nbr_str = "0=0"
  FOR (cnt = 1 TO size(request->part_nbr,5))
    IF (cnt=1
     AND trim(request->part_nbr[cnt].part_nbr,3)="")
     SET req_part_nbr = ""
    ELSE
     SET req_part_nbr = concat(req_part_nbr,'"',request->part_nbr[cnt].part_nbr,'",')
    ENDIF
  ENDFOR
  IF (req_part_nbr != "")
   SET req_part_nbr = replace(req_part_nbr,",","",2)
   SET req_part_nbr_str = concat("ccdr.participant_nbr in ","(",req_part_nbr,")")
   SET req_ccdr_str = concat(req_ccdr_str," and ",req_part_nbr_str)
   IF (trim(req_ccdr_str,3)="and")
    SET req_ccdr_str = "0=0"
   ENDIF
  ENDIF
 ENDIF
 DECLARE req_status_cd = vc
 DECLARE req_status_cd_str = vc
 IF (((size(request->status,5) <= 0) OR (acc_sts_flag=1)) )
  SET req_status_cd = ""
 ELSE
  SET req_status_cd_str = "0=0"
  FOR (cnt = 1 TO size(request->status,5))
    IF (cnt=1
     AND (request->status[cnt].status_cd=0))
     SET req_status_cd = ""
    ELSE
     SET req_status_cd = concat(req_status_cd,trim(cnvtstring(request->status[cnt].status_cd)),",")
    ENDIF
  ENDFOR
  IF (req_status_cd != "")
   SET req_status_cd = replace(req_status_cd,",","",2)
   SET req_status_cd_str = concat("ccdr.status_cd in ","(",req_status_cd,")")
   SET req_ccdr_str = concat(req_ccdr_str," and ",req_status_cd_str)
   IF (trim(req_ccdr_str,3)="and")
    SET req_ccdr_str = "0=0"
   ENDIF
  ENDIF
 ENDIF
 DECLARE proc_type_cnt = i4 WITH noconstant(0), protect
 DECLARE proc_type_idx = i4 WITH noconstant(0), protect
 DECLARE req_proc_type_str = vc WITH protect
 DECLARE sts_proc_type_ec = f8 WITH noconstant, protect
 SET proc_type_cnt = size(request->proc_type,5)
 IF (sts_dataset_id > 0.0
  AND proc_type_cnt > 0)
  SET sts_proc_type_ec = cv_get_code_by_dataset(sts_dataset_id,"PROCTYPE")
  IF (sts_proc_type_ec > 0.0)
   SET req_proc_type_str = build("(ccad3.cv_case_id = cc.cv_case_id and ccad3.event_cd = ",
    sts_proc_type_ec," and expand(proc_type_idx,1,",proc_type_cnt,
    ",ccad3.result_cd,request->proc_type[proc_type_idx].proc_type_cd))")
  ELSE
   CALL cv_log_message("FAILED in lookup of PROCTYPE event_cd through xref. Exiting")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET req_proc_type_str = "ccad3.case_abstr_data_id = 0.0"
 ENDIF
 DECLARE req_person_id = vc
 DECLARE req_person_id_str = vc
 IF (size(request->person,5) <= 0)
  SET req_person_id = ""
 ELSE
  SET req_person_id_str = "0=0"
  FOR (cnt = 1 TO size(request->person,5))
    IF (cnt=1
     AND (request->person[cnt].person_id=0))
     SET req_person_id = ""
    ELSE
     SET req_person_id = concat(req_person_id,trim(cnvtstring(request->person[cnt].person_id)),",")
    ENDIF
  ENDFOR
  IF (req_person_id != "")
   SET req_person_id = replace(req_person_id,",","",2)
   SET req_person_id_str = concat("cc.person_id in ","(",req_person_id,")")
   SET req_cc_str = concat(req_cc_str," and ",req_person_id_str)
   IF (trim(req_cc_str,3)="and")
    SET req_cc_str = "0=0"
   ENDIF
  ENDIF
 ENDIF
 DECLARE req_loc_facility_cd = vc
 DECLARE req_loc_facility_cd_str = vc
 IF (size(request->loc_facility,5) <= 0)
  SET req_loc_facility_cd = ""
 ELSE
  SET req_loc_facility_cd_str = "0=0"
  FOR (cnt = 1 TO size(request->loc_facility,5))
    IF (cnt=1
     AND (request->loc_facility[cnt].loc_facility_cd=0))
     SET req_loc_facility_cd = ""
    ELSE
     SET req_loc_facility_cd = concat(req_loc_facility_cd,trim(cnvtstring(request->loc_facility[cnt].
        loc_facility_cd)),",")
    ENDIF
  ENDFOR
  IF (req_loc_facility_cd != "")
   SET req_loc_facility_cd = replace(req_loc_facility_cd,",","",2)
   SET req_loc_facility_cd_str = concat("cc.hospital_cd in ","(",req_loc_facility_cd,")")
   SET req_cc_str = concat(req_cc_str," and ",req_loc_facility_cd_str)
   IF (trim(req_cc_str,3)="and")
    SET req_cc_str = "0=0"
   ENDIF
  ENDIF
 ENDIF
 DECLARE sts_surg_ec = f8
 DECLARE personnel_cnt = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 DECLARE req_personnel_str = vc WITH protect
 SET personnel_cnt = size(request->personnel,5)
 IF (personnel_cnt > 0
  AND sts_dataset_id > 0.0)
  SET sts_surg_ec = cv_get_code_by_dataset(sts_dataset_id,"SURGEON")
  IF (sts_surg_ec > 0.0)
   SET req_personnel_str = build("(ccad2.cv_case_id = cc.cv_case_id and ccad2.event_cd = ",
    sts_surg_ec," and expand(prsnl_idx,1,",personnel_cnt,
    ",ccad2.result_id,request->personnel[prsnl_idx].person_id))")
  ELSE
   CALL cv_log_message("FAILED in lookup of SURGEON event_cd through xref. Exiting.")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET req_personnel_str = "ccad2.case_abstr_data_id = 0.0"
 ENDIF
 DECLARE encntr_id_str = vc
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE encntr_idx = i4 WITH noconstant(0)
 IF (validate(request->encounter[1].encounter_id))
  SET encntr_cnt = size(request->encounter,5)
  SET encntr_id_str = build("expand(encntr_idx,1,",encntr_cnt,",cc.encntr_id,",
   "request->encounter[encntr_idx].encntr_id)")
 ELSE
  SET encntr_id_str = "1=0"
 ENDIF
 DECLARE cv_case_id_str = vc
 DECLARE cv_case_cnt = i4 WITH noconstant(0)
 DECLARE cv_case_idx = i4 WITH noconstant(0)
 IF (validate(request->case_ids[1].cv_case_id))
  SET cv_case_cnt = size(request->case_ids,5)
  SET cv_case_id_str = build("expand(cv_case_idx,1,",cv_case_cnt,",cc.cv_case_id,",
   "request->case_ids[cv_case_idx].cv_case_id)")
 ELSE
  SET cv_case_id_str = "1=0"
 ENDIF
 DECLARE req_record_id = vc
 DECLARE req_record_id_str = vc
 DECLARE record_cnt = i4 WITH noconstant(0)
 SET record_cnt = size(request->records,5)
 IF (record_cnt <= 0)
  SET req_record_id = ""
 ELSE
  SET req_record_id_str = "0=0"
  FOR (cnt = 1 TO size(request->records,5))
    IF (cnt=1
     AND (request->records[cnt].record_id=0))
     SET req_record_id = ""
    ELSE
     SET req_record_id = concat(req_record_id,trim(cnvtstring(request->records[cnt].record_id)),",")
    ENDIF
  ENDFOR
  IF (req_record_id != "")
   SET req_record_id = replace(req_record_id,",","",2)
   SET req_record_id_str = concat("ccdr.registry_nbr in ","(",req_record_id,")")
   SET req_ccdr_str = concat(req_ccdr_str," and ",req_record_id_str)
   IF (trim(req_ccdr_str,3)="and")
    SET req_ccdr_str = "0=0"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->maxqual=0))
  SET request->maxqual = 10000
 ENDIF
 DECLARE start_id_str = vc WITH public, noconstant(" ")
 IF (context_ind=1)
  SET start_id_str = " cc.encntr_id > start_id and cc.cv_case_id > 0.0"
 ELSE
  SET start_id_str = " cc.encntr_id >= start_id and cc.cv_case_id > 0.0"
 ENDIF
 FREE RECORD null_disch
 RECORD null_disch(
   1 qual[*]
     2 encntr_id = f8
     2 following_encntr_ind = i2
 )
 FREE RECORD post_null_disch
 RECORD post_null_disch(
   1 qual[*]
     2 encntr_id = f8
 )
 DECLARE null_disch_cnt = i4 WITH noconstant(0)
 DECLARE null_disch_idx = i4 WITH noconstant(0)
 DECLARE post_null_disch_cnt = i4 WITH noconstant(0)
 DECLARE post_null_disch_idx = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  c.encntr_id, c2.encntr_id
  FROM cv_case c,
   cv_case c2,
   cv_case_dataset_r cdr,
   cv_case_dataset_r cdr2
  PLAN (c
   WHERE c.pat_disch_dt_tm=null
    AND c.pat_adm_dt_tm != null)
   JOIN (c2
   WHERE c2.person_id=c.person_id
    AND c2.encntr_id != c.encntr_id
    AND ((c2.pat_adm_dt_tm != null
    AND c2.pat_adm_dt_tm > c.pat_adm_dt_tm) OR (c2.pat_adm_dt_tm=null
    AND c2.pat_disch_dt_tm != null
    AND c2.pat_disch_dt_tm > c.pat_adm_dt_tm)) )
   JOIN (cdr
   WHERE cdr.cv_case_id=c.cv_case_id
    AND (cdr.dataset_id=request->dataset_id))
   JOIN (cdr2
   WHERE cdr2.cv_case_id=c2.cv_case_id
    AND (cdr2.dataset_id=request->dataset_id))
  ORDER BY c.encntr_id, c2.encntr_id
  HEAD REPORT
   null_disch_cnt = 0, post_null_disch_cnt = 0
  HEAD c.encntr_id
   has_following_encntr_ind = 0
  DETAIL
   first_following_date = cnvtdatetime(curdate,0),
   CALL echo(first_following_date)
   IF (post_null_disch_cnt=0)
    add_enc_ind = 1
   ELSEIF (locateval(post_null_disch_idx,1,post_null_disch_cnt,c2.encntr_id,post_null_disch->qual[
    post_null_disch_idx].encntr_id)=0)
    add_enc_ind = 1
   ELSE
    add_enc_ind = 0
   ENDIF
   IF (add_enc_ind=1)
    post_null_disch_cnt = (post_null_disch_cnt+ 1), stat = alterlist(post_null_disch->qual,
     post_null_disch_cnt), post_null_disch->qual[post_null_disch_cnt].encntr_id = c2.encntr_id,
    CALL cv_log_message(build("Encntr_id:",c2.encntr_id,": follows null disch_dt on encntr_id:",c
     .encntr_id))
   ENDIF
   IF (c2.pat_adm_dt_tm != null
    AND c2.pat_adm_dt_tm < cnvtdatetime(first_following_date))
    first_following_date = c2.pat_adm_dt_tm, has_following_encntr_ind = 1
   ELSEIF (c2.pat_adm_dt_tm=null
    AND c2.pat_disch_dt_tm < cnvtdatetime(first_following_date))
    first_following_date = c2.pat_disch_dt_tm, has_following_encntr_ind = 1
   ENDIF
  FOOT  c.encntr_id
   CALL echo(build("encntr_id = ",c.encntr_id,", date=",format(first_following_date,"@SHORTDATE")))
   IF (first_following_date BETWEEN request->start_dt AND request->stop_dt)
    null_disch_cnt = (null_disch_cnt+ 1), stat = alterlist(null_disch->qual,null_disch_cnt),
    null_disch->qual[null_disch_cnt].encntr_id = c.encntr_id,
    CALL echo("Added encntr_id to null_disch"), null_disch->qual[null_disch_cnt].following_encntr_ind
     = has_following_encntr_ind
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(null_disch)
 DECLARE cc_where_str = vc WITH protect
 IF ((((request->dateflag=0)) OR ((request->dateflag=datecd_flag))) )
  IF (acc_sts_flag=2)
   SET request->dateflag = surgproc_flag
  ELSE
   SET request->dateflag = disch_flag
  ENDIF
 ENDIF
 IF ((request->dateflag=admit_flag))
  SET cc_where_str = concat(" cc.pat_adm_dt_tm between ",
   "CNVTDATETIME(cnvtdate(request->start_dt),0 ) ",
   "and CNVTDATETIME(cnvtdate(request->stop_dt),235959)")
 ELSEIF ((request->dateflag=disch_flag))
  SET cc_where_str = concat(" (cc.pat_disch_dt_tm between ",
   "CNVTDATETIME(cnvtdate(request->start_dt),0 ) ",
   " and CNVTDATETIME(cnvtdate(request->stop_dt),235959))",
   " or (cc.pat_adm_dt_tm = NULL and cc.pat_disch_dt_tm = NULL)")
  IF (null_disch_cnt > 0)
   SET cc_where_str = concat(cc_where_str," or expand(null_disch_idx,1,null_disch_cnt,",
    "cc.encntr_id,null_disch->qual[null_disch_idx].encntr_id)")
  ENDIF
 ELSEIF ((request->dateflag=surgproc_flag))
  SET cc_where_str = concat(" cc.case_dt_tm between ","CNVTDATETIME(cnvtdate(request->start_dt),0 ) ",
   "and CNVTDATETIME(cnvtdate(request->stop_dt),235959)")
 ELSEIF ((request->dateflag=- (1)))
  SET cc_where_str = "0=0"
 ENDIF
 DECLARE g_reportwarn_status_cd = f8 WITH noconstant(0.0)
 DECLARE g_error_status_cd = f8 WITH noconstant(0.0)
 DECLARE too_many_admits_msg = vc WITH constant(
  "ERROR : More than 1 Admission Form found for this encounter")
 DECLARE no_admits_msg = vc WITH constant("ERROR : No Admission Form found for this encounter")
 DECLARE no_labvisits_msg = vc WITH constant("ERROR: No Cath Lab Visit Form found for this encounter"
  )
 DECLARE post_null_disch_msg = vc WITH constant("ERROR: Follows encounter with no discharge date")
 DECLARE has_null_disch_msg = vc WITH constant("ERROR: Null discharge date with later encounter")
 DECLARE too_young_msg = vc WITH constant(
  "WARNING: Patient age is below the harvest threshold, case will not harvest")
 SET g_error_status_cd = uar_get_code_by("MEANING",25973,"ERROR")
 SET g_reportwarn_status_cd = uar_get_code_by("MEANING",25973,"REPORTWARN")
 CALL echo(format(request->start_dt,"mm/dd/yyyy;;d"))
 CALL echo(format(request->stop_dt,"mm/dd/yyyy;;d"))
 CALL echo(build("req_personnel_str: ",req_personnel_str))
 CALL echo(build("req_proc_type_str: ",req_proc_type_str))
 CALL echo(build("cc_where_str: ",cc_where_str))
 CALL echo(build("req_ccdr_str:",req_ccdr_str))
 CALL echo(build("req_cc_str:",req_cc_str))
 CALL echo(build("start_id_str: ",start_id_str))
 CALL echo(build("request->maxqual: ",request->maxqual))
 CALL echo(build("start_id",start_id))
 CALL cv_log_message("case selection starts!")
 SELECT
  IF (((cv_case_cnt > 0) OR (encntr_cnt > 0)) )
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    person p
   PLAN (cc
    WHERE ((parser(encntr_id_str)) OR (parser(cv_case_id_str)))
     AND cc.cv_case_id > 0.0)
    JOIN (ccdr
    WHERE ccdr.cv_case_id=cc.cv_case_id
     AND ccdr.active_ind=1
     AND parser(req_ccdr_str))
    JOIN (p
    WHERE p.person_id=cc.person_id)
  ELSEIF (((personnel_cnt > 0) OR (proc_type_cnt > 0)) )
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_abstr_data ccad2,
    cv_case_abstr_data ccad3,
    person p
   PLAN (cc
    WHERE parser(cc_where_str)
     AND parser(start_id_str)
     AND parser(req_cc_str)
     AND cc.cv_case_id > 0.0)
    JOIN (ccdr
    WHERE ccdr.cv_case_id=cc.cv_case_id
     AND ccdr.active_ind=1
     AND parser(req_ccdr_str))
    JOIN (ccad2
    WHERE parser(req_personnel_str))
    JOIN (ccad3
    WHERE parser(req_proc_type_str))
    JOIN (p
    WHERE p.person_id=cc.person_id)
  ELSE
  ENDIF
  INTO "nl:"
  form_type_mean = uar_get_code_meaning(cc.form_type_cd), cc.cv_case_id, null_age = nullind(cc.age)
  FROM cv_case cc,
   cv_case_dataset_r ccdr,
   person p
  PLAN (cc
   WHERE parser(cc_where_str)
    AND parser(start_id_str)
    AND parser(req_cc_str)
    AND cc.cv_case_id > 0.0)
   JOIN (ccdr
   WHERE ccdr.cv_case_id=cc.cv_case_id
    AND ccdr.active_ind=1
    AND parser(req_ccdr_str))
   JOIN (p
   WHERE p.person_id=cc.person_id)
  ORDER BY cc.encntr_id, form_type_mean, cc.case_dt_tm,
   cc.form_id
  HEAD REPORT
   case_cnt = 0, l_status_cd_cnt = size(request->status,5), l_status_cd_idx = 0
  HEAD cc.encntr_id
   forms_this_encntr = 0, patient_too_young = 0
   IF (locateval(post_null_disch_idx,1,post_null_disch_cnt,cc.encntr_id,post_null_disch->qual[
    post_null_disch_idx].encntr_id) > 0)
    post_null_disch_ind = 1
   ELSE
    post_null_disch_ind = 0
   ENDIF
   IF (null_disch_cnt > 0)
    null_disch_pos = locateval(null_disch_idx,1,null_disch_cnt,cc.encntr_id,null_disch->qual[
     null_disch_idx].encntr_id)
    IF (null_disch_pos > 0
     AND (null_disch->qual[null_disch_pos].following_encntr_ind=1))
     has_following_encntr_ind = 1
    ELSE
     has_following_encntr_ind = 0
    ENDIF
   ENDIF
  DETAIL
   CALL echo(build("case_id = ",cc.cv_case_id,",   encntr_id = ",cc.encntr_id)), forms_this_encntr =
   (forms_this_encntr+ 1)
   IF (((forms_this_encntr=1) OR (size(trim(form_type_mean))=0)) )
    case_cnt = (case_cnt+ 1), stat = alterlist(reply->caserec,case_cnt), reply->caserec[case_cnt].
    case_id = cc.cv_case_id,
    reply->caserec[case_cnt].status_cd = ccdr.status_cd, reply->caserec[case_cnt].error_msg = ccdr
    .error_msg, reply->caserec[case_cnt].person_id = cc.person_id,
    reply->caserec[case_cnt].encntr_id = cc.encntr_id, reply->caserec[case_cnt].name_full_formatted
     = p.name_full_formatted, reply->caserec[case_cnt].form_id = cc.form_id,
    reply->caserec[case_cnt].chart_dt_tm = cc.chart_dt_tm, reply->caserec[case_cnt].record_id = ccdr
    .case_dataset_r_id
    IF (case_cnt=maxqualrows)
     context->context_ind = (context->context_ind+ 1), context->start_id = cc.encntr_id, context->
     maxqual = maxqualrows
    ENDIF
    sub_case_cnt = 1, stat = alterlist(reply->caserec[case_cnt].sub_case,sub_case_cnt), reply->
    caserec[case_cnt].sub_case[sub_case_cnt].case_id = cc.cv_case_id,
    reply->caserec[case_cnt].sub_case[sub_case_cnt].form_type_mean = form_type_mean, reply->caserec[
    case_cnt].sub_case[sub_case_cnt].form_id = cc.form_id
    IF ((reply->max_sub_case_cnt < sub_case_cnt))
     reply->max_sub_case_cnt = sub_case_cnt
    ENDIF
    IF (form_type_mean=labvisit_form_mean)
     reply->caserec[case_cnt].status_cd = max_status_cd(reply->caserec[case_cnt].status_cd,
      g_error_status_cd), reply->caserec[case_cnt].error_msg = concat(no_admits_msg,":::",reply->
      caserec[case_cnt].error_msg)
    ELSEIF (null_age=0
     AND cc.age < minimum_age)
     patient_too_young = 1
    ENDIF
   ELSEIF (form_type_mean=admit_form_mean)
    reply->caserec[case_cnt].status_cd = max_status_cd(reply->caserec[case_cnt].status_cd,
     g_error_status_cd), reply->caserec[case_cnt].error_msg = concat(too_many_admits_msg,":::",reply
     ->caserec[case_cnt].error_msg),
    CALL cv_log_message(build("Extra admit form_id=",cc.cv_case_id))
   ELSE
    sub_case_cnt = (sub_case_cnt+ 1), stat = alterlist(reply->caserec[case_cnt].sub_case,sub_case_cnt
     ), reply->caserec[case_cnt].sub_case[sub_case_cnt].case_id = cc.cv_case_id,
    reply->caserec[case_cnt].sub_case[sub_case_cnt].form_type_mean = form_type_mean, reply->caserec[
    case_cnt].sub_case[sub_case_cnt].form_id = cc.form_id, reply->caserec[case_cnt].status_cd =
    max_status_cd(reply->caserec[case_cnt].status_cd,ccdr.status_cd)
    IF ((reply->max_sub_case_cnt < sub_case_cnt))
     reply->max_sub_case_cnt = sub_case_cnt
    ENDIF
   ENDIF
  FOOT  cc.encntr_id
   IF (sub_case_cnt=1
    AND (reply->caserec[case_cnt].sub_case[1].form_type_mean=admit_form_mean))
    reply->caserec[case_cnt].status_cd = max_status_cd(reply->caserec[case_cnt].status_cd,
     g_error_status_cd), reply->caserec[case_cnt].error_msg = concat(no_labvisits_msg,":::",reply->
     caserec[case_cnt].error_msg)
   ENDIF
   IF (patient_too_young=1)
    IF ((reply->caserec[case_cnt].status_cd > 0.0))
     reply->caserec[case_cnt].status_cd = g_reportwarn_status_cd
    ENDIF
    reply->caserec[case_cnt].error_msg = concat(too_young_msg,":::",reply->caserec[case_cnt].
     error_msg)
   ENDIF
   IF (post_null_disch_ind=1)
    reply->caserec[case_cnt].status_cd = max_status_cd(reply->caserec[case_cnt].status_cd,
     g_error_status_cd), reply->caserec[case_cnt].error_msg = concat(post_null_disch_msg,":::",reply
     ->caserec[case_cnt].error_msg),
    CALL cv_log_message(build("Encounter follows admit with null discharge encntr_id=",cc.encntr_id))
   ENDIF
   IF (has_following_encntr_ind=1)
    reply->caserec[case_cnt].status_cd = max_status_cd(reply->caserec[case_cnt].status_cd,
     g_error_status_cd), reply->caserec[case_cnt].error_msg = concat(has_null_disch_msg,":::",reply->
     caserec[case_cnt].error_msg),
    CALL cv_log_message(build("Encounter with null discharge encntr_id=",cc.encntr_id,
     ", has following admit"))
   ENDIF
   IF ((reply->caserec[case_cnt].status_cd=0.0))
    reply->caserec[case_cnt].error_msg = "Validation Incomplete"
   ENDIF
   IF (l_status_cd_cnt > 0
    AND locateval(l_status_cd_idx,1,l_status_cd_cnt,reply->caserec[case_cnt].status_cd,request->
    status[l_status_cd_idx].status_cd)=0)
    CALL cv_log_message(build("Dropping case because status_cd not in list for encntr_id=",cc
     .encntr_id)), case_cnt = (case_cnt - 1), stat = alterlist(reply->caserec,case_cnt)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->caserec,case_cnt)
  WITH nocounter, maxrec = value(request->maxqual)
 ;end select
 IF (curqual=0)
  CALL echo("No cases matched the filtering condition, exit!")
  SET sfailed = "T"
  GO TO exit_script
 ENDIF
 IF (case_cnt < maxqualrows)
  CALL cv_log_message("********************************")
  CALL cv_log_message(build("Last_count: ",case_cnt))
  CALL cv_log_message("No more records!")
  CALL cv_log_message("********************************")
 ENDIF
 SET stat = alterlist(mds->caserec,size(reply->caserec,5))
 CALL setmds(null)
 CALL echorecord(context)
 CALL echorecord(reply)
 IF (size(reply->caserec,5) > 0)
  SELECT
   IF (omit_normal_data_ind=1)
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(reply->caserec[d.seq].sub_case,5)
      AND (reply->caserec[d.seq].sub_case[d1.seq].case_id > 0.0))
     JOIN (ccdr
     WHERE (ccdr.cv_case_id=reply->caserec[d.seq].sub_case[d1.seq].case_id)
      AND ccdr.active_ind=1
      AND parser(req_part_nbr_str))
     JOIN (ccf
     WHERE ccf.case_dataset_r_id=ccdr.case_dataset_r_id
      AND ccf.long_text_id > 0.0)
     JOIN (cx
     WHERE cx.xref_id=ccf.xref_id)
   ELSE
   ENDIF
   INTO "nl:"
   case_id = ccdr.cv_case_id
   FROM (dummyt d  WITH seq = value(size(reply->caserec,5))),
    (dummyt d1  WITH seq = value(reply->max_sub_case_cnt)),
    cv_case_dataset_r ccdr,
    cv_case_field ccf,
    cv_xref cx
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(reply->caserec[d.seq].sub_case,5)
     AND (reply->caserec[d.seq].sub_case[d1.seq].case_id > 0.0))
    JOIN (ccdr
    WHERE (ccdr.cv_case_id=reply->caserec[d.seq].sub_case[d1.seq].case_id)
     AND ccdr.active_ind=1
     AND parser(req_part_nbr_str))
    JOIN (ccf
    WHERE ccf.case_dataset_r_id=ccdr.case_dataset_r_id)
    JOIN (cx
    WHERE cx.xref_id=ccf.xref_id)
   ORDER BY d.seq, d1.seq
   HEAD d.seq
    fcnt = 0, labvisit_cnt = 0
   HEAD d1.seq
    IF ((reply->caserec[d.seq].sub_case[d1.seq].form_type_mean=labvisit_form_mean))
     labvisit_cnt = (labvisit_cnt+ 1), is_labvisit_ind = 1
    ELSE
     is_labvisit_ind = 0
    ENDIF
   DETAIL
    IF ((((mds->caserec[d.seq].use_mds != 1)) OR (((cx.audit_flag != 1) OR (ccf.status_cd=
    g_error_status_cd)) )) )
     fcnt = (fcnt+ 1)
     IF (fcnt > size(reply->caserec[d.seq].fieldrec,5))
      stat = alterlist(reply->caserec[d.seq].fieldrec,(fcnt+ 9))
     ENDIF
     reply->caserec[d.seq].fieldrec[fcnt].field_name = cx.registry_field_name, reply->caserec[d.seq].
     fieldrec[fcnt].long_text_id = ccf.long_text_id, reply->caserec[d.seq].fieldrec[fcnt].status_cd
      = ccf.status_cd,
     reply->caserec[d.seq].fieldrec[fcnt].case_field_id = ccf.case_field_id, reply->caserec[d.seq].
     fieldrec[fcnt].translated_val = ccf.translated_val, reply->caserec[d.seq].fieldrec[fcnt].
     field_val = ccf.result_val,
     reply->caserec[d.seq].fieldrec[fcnt].dev_idx = ccf.dev_idx, reply->caserec[d.seq].fieldrec[fcnt]
     .lesion_idx = ccf.lesion_idx, reply->caserec[d.seq].fieldrec[fcnt].form_idx = d1.seq
     IF (ccf.dev_idx > 0)
      IF (ccf.lesion_idx=0)
       reply->caserec[d.seq].fieldrec[fcnt].field_name = build(cv_clsdevice_str,ccf.dev_idx,": ",
        reply->caserec[d.seq].fieldrec[fcnt].field_name)
      ELSE
       reply->caserec[d.seq].fieldrec[fcnt].field_name = build(cv_icdevice_str,ccf.dev_idx,": ",reply
        ->caserec[d.seq].fieldrec[fcnt].field_name)
      ENDIF
     ENDIF
     IF (ccf.lesion_idx > 0)
      reply->caserec[d.seq].fieldrec[fcnt].field_name = build(cv_lesion_str,ccf.lesion_idx,": ",reply
       ->caserec[d.seq].fieldrec[fcnt].field_name)
     ENDIF
     IF (is_labvisit_ind=1)
      reply->caserec[d.seq].fieldrec[fcnt].field_name = build(cv_proc_str,labvisit_cnt,":",reply->
       caserec[d.seq].fieldrec[fcnt].field_name)
     ENDIF
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->caserec[d.seq].fieldrec,fcnt)
    IF (max_field_rec < fcnt)
     max_field_rec = fcnt
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(reply->caserec,5))),
    (dummyt d2  WITH seq = value(max_field_rec)),
    long_text lt
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(reply->caserec[d1.seq].fieldrec,5)
     AND (reply->caserec[d1.seq].fieldrec[d2.seq].long_text_id > 0.0))
    JOIN (lt
    WHERE (lt.long_text_id=reply->caserec[d1.seq].fieldrec[d2.seq].long_text_id))
   DETAIL
    reply->caserec[d1.seq].fieldrec[d2.seq].error_msg = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 IF ((context->context_ind=0))
  FREE RECORD context
 ENDIF
 SUBROUTINE setmds(null)
   DECLARE pci_proc_xref_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM cv_xref x
    WHERE x.xref_internal_name="ACC03_PCIPROC"
     AND (x.dataset_id=request->dataset_id)
    DETAIL
     pci_proc_xref_id = x.xref_id
    WITH nocounter
   ;end select
   CALL echo(concat("pciproc_xref_id = ",cnvtstring(pci_proc_xref_id)))
   IF (pci_proc_xref_id=0.0)
    CALL cv_log_message("No PCIPROC xref found for this dataset")
    RETURN
   ENDIF
   FREE RECORD parts
   RECORD parts(
     1 part[*]
       2 nbr = vc
   )
   DECLARE case_idx = i4 WITH noconstant(0), protect
   DECLARE part_idx = i4 WITH noconstant(0), protect
   DECLARE part_cnt = i4 WITH noconstant(0), protect
   DECLARE no_pci_translated_val = vc WITH constant("2"), protect
   IF (size(reply->caserec,5)=0)
    CALL echo("No cases found, skipping MDS check")
    RETURN
   ENDIF
   SELECT DISTINCT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain="CVNET"
     AND dp.pref_section="MINIMUM_DATA_SET"
     AND dp.pref_str="Y"
    HEAD REPORT
     part_cnt = 0
    DETAIL
     part_cnt = (part_cnt+ 1), stat = alterlist(parts->part,part_cnt), parts->part[part_cnt].nbr =
     cnvtstring(dp.pref_nbr)
    WITH nocounter
   ;end select
   IF (size(parts->part,5)=0)
    CALL cv_log_message("No participants selecting MDS")
    RETURN
   ENDIF
   CALL echorecord(parts)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->caserec,5))),
     (dummyt d1  WITH seq = value(reply->max_sub_case_cnt)),
     cv_case_dataset_r cdr,
     cv_case_field cf
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(reply->caserec[d.seq].sub_case,5)
      AND (reply->caserec[d.seq].sub_case[d1.seq].form_type_mean=labvisit_form_mean))
     JOIN (cdr
     WHERE (cdr.cv_case_id=reply->caserec[d.seq].sub_case[d1.seq].case_id)
      AND expand(part_idx,1,part_cnt,cdr.participant_nbr,parts->part[part_idx].nbr))
     JOIN (cf
     WHERE cf.case_dataset_r_id=cdr.case_dataset_r_id
      AND cf.xref_id=pci_proc_xref_id
      AND cf.translated_val=no_pci_translated_val)
    ORDER BY d.seq, d1.seq
    HEAD d.seq
     l_non_pci_cnt = 0
    HEAD d1.seq
     l_non_pci_cnt = (l_non_pci_cnt+ 1)
    DETAIL
     CALL echo("Detail"), col 0
    FOOT  d.seq
     IF (((l_non_pci_cnt+ 1)=size(reply->caserec[d.seq].sub_case,5)))
      mds->caserec[d.seq].use_mds = 1,
      CALL echo(build("MDS applies to encounter_id=",reply->caserec[d.seq].encntr_id))
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (sfailed="T")
  SET reply->status_data.status = "F"
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "cv_get_harvest_audit"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_case_field"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed in getting data!"
 ELSE
  SET reply->status_data.status = "S"
  IF (validate(reply->files,"-1") != "-1")
   SET stat = alterlist(reply->files,0)
  ENDIF
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
 DECLARE cv_get_harvest_audit_version = vc WITH private, constant("MOD 039 BM9013 04/17/06")
END GO
