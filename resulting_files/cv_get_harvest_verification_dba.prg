CREATE PROGRAM cv_get_harvest_verification:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
  )
 ENDIF
 IF ( NOT (validate(report_rec,0)))
  RECORD report_rec(
    1 dataset_id = f8
    1 period[*]
      2 from_date = dq8
      2 to_date = dq8
      2 cnt_data[*]
        3 display_seq = i4
        3 case_type = vc
        3 case_type_flag = i4
        3 rec_cnt = i4
        3 xref_id = f8
  )
 ENDIF
 IF ( NOT (validate(date_range,0)))
  RECORD date_range(
    1 rec[*]
      2 from_date = dq8
      2 to_date = dq8
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL echo("Reply doesn't contain status block.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE verify_fail = c1 WITH protect, noconstant("F")
 DECLARE status_cd_str = vc WITH protect, noconstant(" ")
 DECLARE facility_str = vc WITH protect, noconstant(" ")
 DECLARE part_nbr_str = vc WITH protect, noconstant(" ")
 DECLARE cv_status_set = i4 WITH protect, constant(25973)
 DECLARE status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cab_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE mvr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE avr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE tvr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE pvr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE ocard_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE oncard_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE mort_dc_id = f8 WITH protect, noconstant(0.0)
 DECLARE mort_30_id = f8 WITH protect, noconstant(0.0)
 DECLARE cab_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE mvr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE avr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE tvr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE pvr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE ocard_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE oncard_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE mort_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE ccf_date_idx = i4 WITH protect, noconstant(0)
 DECLARE cab_trans_val = i4 WITH protect, noconstant(0)
 DECLARE mvr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE avr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE tvr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE pvr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE oth_card = i4 WITH protect, noconstant(0)
 DECLARE oth_non_card = i4 WITH protect, noconstant(0)
 DECLARE death_trans_val = i4 WITH protect, noconstant(0)
 DECLARE death_trans_235 = i4 WITH protect, noconstant(0)
 DECLARE done = i4 WITH protect, noconstant(0)
 DECLARE cab_only = i2 WITH protect, noconstant(0)
 DECLARE mvr_only = i2 WITH protect, noconstant(0)
 DECLARE avr_only = i2 WITH protect, noconstant(0)
 DECLARE mvr_cab = i2 WITH protect, noconstant(0)
 DECLARE avr_cab = i2 WITH protect, noconstant(0)
 DECLARE other = i2 WITH protect, noconstant(0)
 DECLARE nbr_death = i2 WITH protect, noconstant(0)
 DECLARE tot_nbr = i2 WITH protect, noconstant(0)
 DECLARE case_date_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE sts01_dataset = f8 WITH protect, noconstant(0.0)
 DECLARE sts02_dataset = f8 WITH protect, noconstant(0.0)
 DECLARE v_sts_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE v_export_flag = i2 WITH protect, noconstant(0)
 DECLARE carlva_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carvsd_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carasd_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carbati_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carcong_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carlasr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE cartrma_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carcrtx_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carpace_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE caraicd_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carothr_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE carlva_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carvsd_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carasd_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carbati_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carsvr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carcong_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carlasr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE cartrma_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carcrtx_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carpace_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE caraicd_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carothr_ref2_id = f8 WITH protect, noconstant(0.0)
 DECLARE carlva_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carvsd_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carasd_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carbati_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carsvr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carcong_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carlasr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE cartrma_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carcrtx_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carpace_trans_val = i4 WITH protect, noconstant(0)
 DECLARE caraicd_trans_val = i4 WITH protect, noconstant(0)
 DECLARE carothr_trans_val = i4 WITH protect, noconstant(0)
 DECLARE rec_size = i4 WITH protect
 DECLARE column_nbr = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE cv_dataset_str = vc WITH protect, noconstant
 SET v_export_flag = getcvcontrol(request->dataset_id,"CV_FLAG_CTRL_ACC_OR_STS_ETC")
 IF (v_export_flag=1)
  CALL echo("ACC data, no verification required. Exit!")
  SET verify_fail = "T"
  GO TO exit_script
 ELSE
  SET v_sts_dataset_id = request->dataset_id
 ENDIF
 IF (v_sts_dataset_id > 0.0)
  DECLARE export_both_sts_flag = i2 WITH protect, noconstant(0)
  SET export_both_sts_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS_FLAG")
  DECLARE export_both_sts2_flag = i2 WITH protect, noconstant(0)
  SET export_both_sts2_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS2_FLAG")
  SELECT
   IF (((export_both_sts_flag=1) OR (export_both_sts2_flag=1)) )
    WHERE cd.dataset_internal_name="STS*"
   ELSE
   ENDIF
   INTO "nl:"
   FROM cv_dataset cd
   WHERE (cd.dataset_id=request->dataset_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cd.dataset_internal_name="STS")
     sts01_dataset = cd.dataset_id
    ELSE
     sts02_dataset = cd.dataset_id
    ENDIF
    cnt = (cnt+ 1)
    IF (cnt=1)
     cv_dataset_str = concat("ccdr.dataset_id in (",cnvtstring(cd.dataset_id,14,1))
    ELSE
     cv_dataset_str = concat(cv_dataset_str,",",trim(cnvtstring(cd.dataset_id,14,1)))
    ENDIF
   FOOT REPORT
    cv_dataset_str = concat(cv_dataset_str,")")
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("No STS/STS02 dataset in cv_dataset, Exit!")
   GO TO exit_script
  ELSE
   CALL echo(build("cv_dataset_str: ",cv_dataset_str))
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM cv_dataset ccdr
  WHERE parser(cv_dataset_str)
  DETAIL
   IF (trim(ccdr.case_date_mean,3) != " ")
    case_date_mean = ccdr.case_date_mean
   ENDIF
  WITH nocounter
 ;end select
 DECLARE surg_dt_ec = f8 WITH protect
 SET surg_dt_ec = geteventcd(case_date_mean)
 DECLARE cab_ec = f8 WITH protect
 SET cab_ec = geteventcd("ST01OPCAB")
 DECLARE mvr_ec = f8 WITH protect
 SET mvr_ec = geteventcd("ST01OPMITRAL")
 DECLARE avr_ec = f8 WITH protect
 SET avr_ec = geteventcd("ST01OPAORTIC")
 DECLARE tvr_ec = f8 WITH protect
 SET tvr_ec = geteventcd("ST01OPTRICUS")
 DECLARE pvr_ec = f8 WITH protect
 SET pvr_ec = geteventcd("ST01OPPULM")
 DECLARE ocard_ec = f8 WITH protect
 SET ocard_ec = geteventcd("ST01OPOCARD")
 DECLARE oncard_ec = f8 WITH protect
 SET oncard_ec = geteventcd("ST01OPONCARD")
 DECLARE mort_ec = f8 WITH protect
 SET mort_ec = geteventcd("ST02MORTALTY")
 DECLARE mort_dc_ec = f8 WITH protect
 SET mort_dc_ec = geteventcd("ST01MTDCSTAT")
 DECLARE mort_30_ec = f8 WITH protect
 SET mort_30_ec = geteventcd("ST01MT30STAT")
 DECLARE carlva_ec = f8 WITH protect
 SET carlva_ec = geteventcd("ST01OCARLVA")
 DECLARE carvsd_ec = f8 WITH protect
 SET carvsd_ec = geteventcd("ST01OCARVSD")
 DECLARE carasd_ec = f8 WITH protect
 SET carasd_ec = geteventcd("ST01OCARASD")
 DECLARE carbati_ec = f8 WITH protect
 SET carbati_ec = geteventcd("ST01OCARBATI")
 DECLARE carsvr_ec = f8 WITH protect
 SET carsvr_ec = geteventcd("ST02OCARSVR")
 DECLARE carcong_ec = f8 WITH protect
 SET carcong_ec = geteventcd("ST01OCARCONG")
 DECLARE carlasr_ec = f8 WITH protect
 SET carlasr_ec = geteventcd("ST01OCARLASR")
 DECLARE cartrma_ec = f8 WITH protect
 SET cartrma_ec = geteventcd("ST01OCARTRMA")
 DECLARE carcrtx_ec = f8 WITH protect
 SET carcrtx_ec = geteventcd("ST01OCARCRTX")
 DECLARE carpace_ec = f8 WITH protect
 SET carpace_ec = geteventcd("ST01OCARPACE")
 DECLARE caraicd_ec = f8 WITH protect
 SET caraicd_ec = geteventcd("ST01OCARAICD")
 DECLARE carothr_ec = f8 WITH protect
 SET carothr_ec = geteventcd("ST01OCAROTHR")
 CALL echo(build("SURG_DT_EC: ",surg_dt_ec))
 CALL echo(build("CAB_EC: ",cab_ec))
 CALL echo(build("MVR_EC: ",mvr_ec))
 CALL echo(build("AVR_EC: ",avr_ec))
 CALL echo(build("TVR_EC: ",tvr_ec))
 CALL echo(build("PVR_EC: ",pvr_ec))
 CALL echo(build("OCARD_EC: ",ocard_ec))
 CALL echo(build("ONCARD_EC: ",oncard_ec))
 CALL echo(build("MORT_EC: ",mort_ec))
 CALL echo(build("MORT_DC_EC: ",mort_dc_ec))
 CALL echo(build("MORT_30_EC: ",mort_30_ec))
 CALL echo(build("CARLVA_EC: ",carlva_ec))
 CALL echo(build("CARVSD_EC: ",carvsd_ec))
 CALL echo(build("CARASD_EC: ",carasd_ec))
 CALL echo(build("CARBATI_EC: ",carbati_ec))
 CALL echo(build("CARSVR_EC: ",carsvr_ec))
 CALL echo(build("CARCONG_EC: ",carcong_ec))
 CALL echo(build("CARLASR_EC: ",carlasr_ec))
 CALL echo(build("CARTRMA_EC: ",cartrma_ec))
 CALL echo(build("CARCRTX_EC: ",carcrtx_ec))
 CALL echo(build("CARPACE_EC: ",carpace_ec))
 CALL echo(build("CARAICD_EC: ",caraicd_ec))
 CALL echo(build("CAROTHR_EC: ",carothr_ec))
 DECLARE status_mean = c12 WITH protect, noconstant("HARVNOERROR")
 SET status_cd = uar_get_code_by("MEANING",cv_status_set,status_mean)
 SET status_cd_str = "0=0"
 IF ((request->status_type_ind > 0))
  SET status_cd_str = "ccdr.status_cd = status_cd"
 ENDIF
 SET part_nbr_str = "0=0"
 IF (size(trim(request->part_nbr,3)) > 1)
  SET part_nbr_str = "ccdr.participant_nbr = request->part_nbr"
 ENDIF
 SET facility_str = "0=0"
 IF ((request->loc_facility_cd > 0))
  SET facility_str = "c.hospital_cd = request->loc_facility_cd"
 ENDIF
 IF ( NOT (validate(cur_yr,0)))
  DECLARE cur_yr = i4 WITH protect
  SET cur_yr = 0
 ENDIF
 IF (validate(season,"NOTDEFINED") != "NOTDEFINED")
  CALL echo("Season is defined!")
 ELSE
  DECLARE season = c1 WITH protect
  SET season = " "
 ENDIF
 IF ((request->date_cd > 0))
  SET cur_yr = getcuryr(request->date_cd)
  SET season = getseason(request->date_cd)
  CALL echo(build("CUR_YR:",cur_yr))
  CALL echo(build("SEASON:",season))
 ENDIF
 IF (season != " ")
  IF (cur_yr=0)
   SET cur_yr = cnvtint(format(curdate,"YYYY;;D"))
  ENDIF
  DECLARE cur_yr_str = c4 WITH protect, noconstant(cnvtstring(cur_yr))
  SET hrv_range1 = trim(cnvtstring((cur_yr - 2)),3)
  SET hrv_range2 = trim(cnvtstring((cur_yr - 1)),3)
  CASE (season)
   OF "S":
    SET column_nbr = 2
    SET range_stat = alterlist(date_range->rec,2)
    SET date_range->rec[1].from_date = cnvtdatetime(concat("01-JAN-",hrv_range1))
    SET date_range->rec[1].to_date = cnvtdatetime(concat("31-DEC-",hrv_range1))
    SET date_range->rec[2].from_date = cnvtdatetime(concat("01-JAN-",hrv_range2))
    SET date_range->rec[2].to_date = cnvtdatetime(concat("31-DEC-",hrv_range2))
    SET request->start_dt = cnvtdatetime(concat("01-JAN-",hrv_range1))
    SET request->stop_dt = cnvtdatetime(concat("31-DEC-",hrv_range2))
   OF "F":
    SET column_nbr = 3
    SET range_stat = alterlist(date_range->rec,3)
    SET date_range->rec[1].from_date = cnvtdatetime(concat("01-JUL-",hrv_range1))
    SET date_range->rec[1].to_date = cnvtdatetime(concat("31-DEC-",hrv_range1))
    SET date_range->rec[2].from_date = cnvtdatetime(concat("01-JAN-",hrv_range2))
    SET date_range->rec[2].to_date = cnvtdatetime(concat("31-DEC-",hrv_range2))
    SET date_range->rec[3].from_date = cnvtdatetime(concat("01-JAN-",cur_yr_str))
    SET date_range->rec[3].to_date = cnvtdatetime(concat("30-JUN-",cur_yr_str))
    SET request->start_dt = cnvtdatetime(concat("01-JUL-",hrv_range1))
    SET request->stop_dt = cnvtdatetime(concat("30-JUN-",cur_yr_str))
   ELSE
    CALL echo("Only spring and fall are valid season for STS dataset!")
    GO TO exit_script
  ENDCASE
 ELSE
  SET column_nbr = 1
 ENDIF
 SET rec_size = 8
 FOR (i = 1 TO column_nbr)
   SET stat = alterlist(report_rec->period,i)
   IF (column_nbr=1)
    SET report_rec->period[i].from_date = request->start_dt
    SET report_rec->period[i].to_date = request->stop_dt
   ELSE
    SET report_rec->period[i].from_date = date_range->rec[i].from_date
    SET report_rec->period[i].to_date = date_range->rec[i].to_date
   ENDIF
   FOR (j = 1 TO rec_size)
     SET stat = alterlist(report_rec->period[i].cnt_data,j)
     SET report_rec->period[i].cnt_data[j].display_seq = j
     CASE (j)
      OF 1:
       SET report_rec->period[i].cnt_data[j].case_type = "CAB"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 1
       SET cab_only = j
      OF 2:
       SET report_rec->period[i].cnt_data[j].case_type = "MVR"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 2
       SET mvr_only = j
      OF 3:
       SET report_rec->period[i].cnt_data[j].case_type = "AVR"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 4
       SET avr_only = j
      OF 4:
       SET report_rec->period[i].cnt_data[j].case_type = "MVR+CAB"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 3
       SET mvr_cab = j
      OF 5:
       SET report_rec->period[i].cnt_data[j].case_type = "AVR+CAB"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 5
       SET avr_cab = j
      OF 6:
       SET report_rec->period[i].cnt_data[j].case_type = "Other"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 6
       SET other = j
      OF 7:
       SET report_rec->period[i].cnt_data[j].case_type = "Number of Deaths"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 7
       SET nbr_death = j
      OF 8:
       SET report_rec->period[i].cnt_data[j].case_type = "Total Number of Records"
       SET report_rec->period[i].cnt_data[j].case_type_flag = 8
       SET tot_nbr = j
     ENDCASE
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  cx.xref_id
  FROM cv_dataset ccdr,
   cv_xref cx
  PLAN (ccdr
   WHERE parser(cv_dataset_str))
   JOIN (cx
   WHERE cx.dataset_id=ccdr.dataset_id
    AND cx.event_cd IN (cab_ec, mvr_ec, avr_ec, tvr_ec, pvr_ec,
   ocard_ec, oncard_ec, mort_ec, mort_dc_ec, mort_30_ec,
   carlva_ec, carvsd_ec, carasd_ec, carbati_ec, carsvr_ec,
   carcong_ec, carlasr_ec, cartrma_ec, carcrtx_ec, carpace_ec,
   caraicd_ec, carothr_ec))
  DETAIL
   IF (cx.dataset_id=sts01_dataset)
    CASE (cx.event_cd)
     OF cab_ec:
      cab_ref_id = cx.xref_id
     OF mvr_ec:
      mvr_ref_id = cx.xref_id
     OF avr_ec:
      avr_ref_id = cx.xref_id
     OF tvr_ec:
      tvr_ref_id = cx.xref_id
     OF pvr_ec:
      pvr_ref_id = cx.xref_id
     OF ocard_ec:
      ocard_ref_id = cx.xref_id
     OF oncard_ec:
      oncard_ref_id = cx.xref_id
     OF mort_dc_ec:
      mort_dc_id = cx.xref_id
     OF mort_30_ec:
      mort_30_id = cx.xref_id
     OF carlva_ec:
      carlva_ref_id = cx.xref_id
     OF carvsd_ec:
      carvsd_ref_id = cx.xref_id
     OF carasd_ec:
      carasd_ref_id = cx.xref_id
     OF carbati_ec:
      carbati_ref_id = cx.xref_id
     OF carcong_ec:
      carcong_ref_id = cx.xref_id
     OF carlasr_ec:
      carlasr_ref_id = cx.xref_id
     OF cartrma_ec:
      cartrma_ref_id = cx.xref_id
     OF carcrtx_ec:
      carcrtx_ref_id = cx.xref_id
     OF carpace_ec:
      carpace_ref_id = cx.xref_id
     OF caraicd_ec:
      caraicd_ref_id = cx.xref_id
     OF carothr_ec:
      carothr_ref_id = cx.xref_id
     ELSE
      CALL echo("invalid event_cd")
    ENDCASE
   ELSEIF (cx.dataset_id=sts02_dataset)
    CASE (cx.event_cd)
     OF cab_ec:
      cab_ref2_id = cx.xref_id
     OF mvr_ec:
      mvr_ref2_id = cx.xref_id
     OF avr_ec:
      avr_ref2_id = cx.xref_id
     OF tvr_ec:
      tvr_ref2_id = cx.xref_id
     OF pvr_ec:
      pvr_ref2_id = cx.xref_id
     OF ocard_ec:
      ocard_ref2_id = cx.xref_id
     OF oncard_ec:
      oncard_ref2_id = cx.xref_id
     OF mort_ec:
      mort_ref_id = cx.xref_id
     OF carlva_ec:
      carlva_ref2_id = cx.xref_id
     OF carvsd_ec:
      carvsd_ref2_id = cx.xref_id
     OF carasd_ec:
      carasd_ref2_id = cx.xref_id
     OF carbati_ec:
      carbati_ref2_id = cx.xref_id
     OF carsvr_ec:
      carsvr_re2f_id = cx.xref_id
     OF carcong_ec:
      carcong_ref2_id = cx.xref_id
     OF carlasr_ec:
      carlasr_ref2_id = cx.xref_id
     OF cartrma_ec:
      cartrma_ref2_id = cx.xref_id
     OF carcrtx_ec:
      carcrtx_ref2_id = cx.xref_id
     OF carpace_ec:
      carpace_ref2_id = cx.xref_id
     OF caraicd_ec:
      caraicd_ref2_id = cx.xref_id
     OF carothr_ec:
      carothr_ref2_id = cx.xref_id
     ELSE
      CALL echo("invalid event_cd")
    ENDCASE
   ELSE
    CALL echo("Invalid dataset_id")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Xref_IDs not found!")
  SET verify_fail = "T"
  GO TO exit_script
 ENDIF
 CALL echo("Execute STS Verification!")
 CALL echo(build("start date: ",format(request->start_dt,"mm/dd/yyyy;;d")))
 CALL echo(build("stop date: ",format(request->stop_dt,"mm/dd/yyyy;;d")))
 CALL echo(build("facility_str:",facility_str))
 CALL echo(build("cv_dataset_str: ",cv_dataset_str))
 CALL echo(build("status_cd_str:",status_cd_str))
 CALL echo(build("part_nbr_str: ",part_nbr_str))
 CALL echo(build("column_nbr: ",column_nbr))
 CALL echo(build("CAB_REF_ID: ",cab_ref_id))
 CALL echo(build("MVR_REF_ID: ",mvr_ref_id))
 CALL echo(build("AVR_REF_ID: ",avr_ref_id))
 CALL echo(build("MORT_REF_ID: ",mort_ref_id))
 SELECT INTO "nl:"
  ccf.xref_id
  FROM cv_case c,
   cv_case_abstr_data ccad,
   cv_case_dataset_r ccdr,
   cv_case_field ccf,
   (dummyt d  WITH seq = value(column_nbr))
  PLAN (d)
   JOIN (ccdr
   WHERE parser(status_cd_str)
    AND parser(part_nbr_str)
    AND parser(cv_dataset_str))
   JOIN (c
   WHERE c.cv_case_id=ccdr.cv_case_id
    AND parser(facility_str))
   JOIN (ccad
   WHERE ccad.cv_case_id=c.cv_case_id
    AND ccad.event_cd=surg_dt_ec
    AND ccad.result_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
    cnvtdate(request->stop_dt),235959))
   JOIN (ccf
   WHERE ccf.case_dataset_r_id=ccdr.case_dataset_r_id
    AND ccf.xref_id IN (cab_ref_id, mvr_ref_id, avr_ref_id, tvr_ref_id, pvr_ref_id,
   ocard_ref_id, oncard_ref_id, mort_dc_id, mort_30_id, cab_ref2_id,
   mvr_ref2_id, avr_ref2_id, tvr_ref2_id, pvr_ref2_id, ocard_ref2_id,
   oncard_ref2_id, mort_ref_id, carlva_ref_id, carvsd_ref_id, carasd_ref_id,
   carbati_ref_id, carcong_ref_id, carlasr_ref_id, cartrma_ref_id, carpace_ref_id,
   caraicd_ref_id, carothr_ref_id, carlva_ref2_id, carvsd_ref2_id, carasd_ref2_id,
   carbati_ref2_id, carsvr_ref2_id, carcong_ref2_id, carlasr_ref2_id, cartrma_ref2_id,
   carpace_ref2_id, caraicd_ref2_id, carothr_ref2_id))
  ORDER BY c.cv_case_id
  HEAD c.cv_case_id
   done = 0, ccf_date_idx = 0, cab_trans_val = 0,
   mvr_trans_val = 0, avr_trans_val = 0, tvr_trans_val = 0,
   pvr_trans_val = 0, oth_card = 0, oth_non_card = 0,
   death_trans_val = 0, death_trans_235 = 0, carlva_trans_val = 0,
   carvsd_trans_val = 0, carasd_trans_val = 0, carbati_trans_val = 0,
   carsvr_trans_val = 0, carcong_trans_val = 0, carlasr_trans_val = 0,
   cartrma_trans_val = 0, carcrtx_trans_val = 0, carpace_trans_val = 0,
   caraicd_trans_val = 0, carothr_trans_val = 0
   FOR (range_idx = 1 TO size(report_rec->period,5))
     IF (ccad.result_dt_tm BETWEEN cnvtdatetime(cnvtdate(report_rec->period[range_idx].from_date),0)
      AND cnvtdatetime(cnvtdate(report_rec->period[range_idx].to_date),235959))
      ccf_date_idx = range_idx
     ENDIF
   ENDFOR
  DETAIL
   CASE (ccf.xref_id)
    OF cab_ref_id:
     cab_trans_val = cnvtint(ccf.translated_val)
    OF mvr_ref_id:
     mvr_trans_val = cnvtint(ccf.translated_val)
    OF avr_ref_id:
     avr_trans_val = cnvtint(ccf.translated_val)
    OF tvr_ref_id:
     tvr_trans_val = cnvtint(ccf.translated_val)
    OF pvr_ref_id:
     pvr_trans_val = cnvtint(ccf.translated_val)
    OF ocard_ref_id:
     oth_card = cnvtint(ccf.translated_val)
    OF oncard_ref_id:
     oth_non_card = cnvtint(ccf.translated_val)
    OF cab_ref2_id:
     cab_trans_val = cnvtint(ccf.translated_val)
    OF mvr_ref2_id:
     mvr_trans_val = cnvtint(ccf.translated_val)
    OF avr_ref2_id:
     avr_trans_val = cnvtint(ccf.translated_val)
    OF tvr_ref2_id:
     tvr_trans_val = cnvtint(ccf.translated_val)
    OF pvr_ref2_id:
     pvr_trans_val = cnvtint(ccf.translated_val)
    OF ocard_ref2_id:
     oth_card = cnvtint(ccf.translated_val)
    OF oncard_ref2_id:
     oth_non_card = cnvtint(ccf.translated_val)
    OF mort_ref_id:
     death_trans_val = cnvtint(ccf.translated_val)
    OF carlva_ref_id:
     carlva_trans_val = cnvtint(ccf.translated_val)
    OF carvsd_ref_id:
     carvsd_trans_val = cnvtint(ccf.translated_val)
    OF carasd_ref_id:
     carasd_trans_val = cnvtint(ccf.translated_val)
    OF carbati_ref_id:
     carbati_trans_val = cnvtint(ccf.translated_val)
    OF carcong_ref_id:
     carcong_trans_val = cnvtint(ccf.translated_val)
    OF carlasr_ref_id:
     carlasr_trans_val = cnvtint(ccf.translated_val)
    OF cartrma_ref_id:
     cartrma_trans_val = cnvtint(ccf.translated_val)
    OF carcrtx_ref_id:
     carcrtx_trans_val = cnvtint(ccf.translated_val)
    OF carpace_ref_id:
     carpace_trans_val = cnvtint(ccf.translated_val)
    OF caraicd_ref_id:
     caraicd_trans_val = cnvtint(ccf.translated_val)
    OF carothr_ref_id:
     carothr_trans_val = cnvtint(ccf.translated_val)
    OF carlva_ref2_id:
     carlva_trans_val = cnvtint(ccf.translated_val)
    OF carvsd_ref2_id:
     carvsd_trans_val = cnvtint(ccf.translated_val)
    OF carasd_ref2_id:
     carasd_trans_val = cnvtint(ccf.translated_val)
    OF carbati_ref2_id:
     carbati_trans_val = cnvtint(ccf.translated_val)
    OF carsvr_ref2_id:
     carsvr_trans_val = cnvtint(ccf.translated_val)
    OF carcong_ref2_id:
     carcong_trans_val = cnvtint(ccf.translated_val)
    OF carlasr_ref2_id:
     carlasr_trans_val = cnvtint(ccf.translated_val)
    OF cartrma_ref2_id:
     cartrma_trans_val = cnvtint(ccf.translated_val)
    OF carcrtx_ref2_id:
     carcrtx_trans_val = cnvtint(ccf.translated_val)
    OF carpace_ref2_id:
     carpace_trans_val = cnvtint(ccf.translated_val)
    OF caraicd_ref2_id:
     caraicd_trans_val = cnvtint(ccf.translated_val)
    OF carothr_ref2_id:
     carothr_trans_val = cnvtint(ccf.translated_val)
   ENDCASE
   IF (((ccf.xref_id=mort_dc_id) OR (ccf.xref_id=mort_30_id)) )
    IF (cnvtint(ccf.translated_val)=2
     AND done=0)
     done = 1, death_trans_235 = cnvtint(ccf.translated_val)
    ENDIF
   ENDIF
  FOOT  c.cv_case_id
   IF (cab_trans_val=1
    AND mvr_trans_val <= 1
    AND avr_trans_val <= 1
    AND tvr_trans_val <= 1
    AND pvr_trans_val <= 1
    AND oth_non_card IN (0, 2)
    AND carlva_trans_val IN (0, 2)
    AND carvsd_trans_val IN (0, 2)
    AND carasd_trans_val IN (0, 2)
    AND carbati_trans_val IN (0, 2)
    AND carsvr_trans_val IN (0, 2)
    AND carcong_trans_val IN (0, 2)
    AND carlasr_trans_val IN (0, 2)
    AND cartrma_trans_val IN (0, 2)
    AND carcrtx_trans_val IN (0, 2)
    AND caraicd_trans_val IN (0, 2)
    AND carothr_trans_val IN (0, 2))
    report_rec->period[ccf_date_idx].cnt_data[cab_only].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[cab_only].rec_cnt+ 1)
   ELSEIF (((cab_trans_val=2) OR (cab_trans_val=0))
    AND mvr_trans_val=3
    AND avr_trans_val <= 1
    AND tvr_trans_val <= 1
    AND pvr_trans_val <= 1
    AND oth_non_card IN (0, 2)
    AND carlva_trans_val IN (0, 2)
    AND carvsd_trans_val IN (0, 2)
    AND carasd_trans_val IN (0, 2)
    AND carbati_trans_val IN (0, 2)
    AND carsvr_trans_val IN (0, 2)
    AND carcong_trans_val IN (0, 2)
    AND carlasr_trans_val IN (0, 2)
    AND cartrma_trans_val IN (0, 2)
    AND carcrtx_trans_val IN (0, 2)
    AND caraicd_trans_val IN (0, 2)
    AND carothr_trans_val IN (0, 2))
    report_rec->period[ccf_date_idx].cnt_data[mvr_only].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[mvr_only].rec_cnt+ 1)
   ELSEIF (((cab_trans_val=2) OR (cab_trans_val=0))
    AND mvr_trans_val <= 1
    AND avr_trans_val=2
    AND tvr_trans_val <= 1
    AND pvr_trans_val <= 1
    AND oth_non_card IN (0, 2)
    AND carlva_trans_val IN (0, 2)
    AND carvsd_trans_val IN (0, 2)
    AND carasd_trans_val IN (0, 2)
    AND carbati_trans_val IN (0, 2)
    AND carsvr_trans_val IN (0, 2)
    AND carcong_trans_val IN (0, 2)
    AND carlasr_trans_val IN (0, 2)
    AND cartrma_trans_val IN (0, 2)
    AND carcrtx_trans_val IN (0, 2)
    AND caraicd_trans_val IN (0, 2)
    AND carothr_trans_val IN (0, 2))
    report_rec->period[ccf_date_idx].cnt_data[avr_only].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[avr_only].rec_cnt+ 1)
   ELSEIF (cab_trans_val=1
    AND mvr_trans_val=3
    AND avr_trans_val <= 1
    AND tvr_trans_val <= 1
    AND pvr_trans_val <= 1
    AND oth_non_card IN (0, 2)
    AND carlva_trans_val IN (0, 2)
    AND carvsd_trans_val IN (0, 2)
    AND carasd_trans_val IN (0, 2)
    AND carbati_trans_val IN (0, 2)
    AND carsvr_trans_val IN (0, 2)
    AND carcong_trans_val IN (0, 2)
    AND carlasr_trans_val IN (0, 2)
    AND cartrma_trans_val IN (0, 2)
    AND carcrtx_trans_val IN (0, 2)
    AND caraicd_trans_val IN (0, 2)
    AND carothr_trans_val IN (0, 2))
    report_rec->period[ccf_date_idx].cnt_data[mvr_cab].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[mvr_cab].rec_cnt+ 1)
   ELSEIF (cab_trans_val=1
    AND mvr_trans_val <= 1
    AND avr_trans_val=2
    AND tvr_trans_val <= 1
    AND pvr_trans_val <= 1
    AND oth_non_card IN (0, 2)
    AND carlva_trans_val IN (0, 2)
    AND carvsd_trans_val IN (0, 2)
    AND carasd_trans_val IN (0, 2)
    AND carbati_trans_val IN (0, 2)
    AND carsvr_trans_val IN (0, 2)
    AND carcong_trans_val IN (0, 2)
    AND carlasr_trans_val IN (0, 2)
    AND cartrma_trans_val IN (0, 2)
    AND carcrtx_trans_val IN (0, 2)
    AND caraicd_trans_val IN (0, 2)
    AND carothr_trans_val IN (0, 2))
    report_rec->period[ccf_date_idx].cnt_data[avr_cab].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[avr_cab].rec_cnt+ 1)
   ELSE
    report_rec->period[ccf_date_idx].cnt_data[other].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[other].rec_cnt+ 1)
   ENDIF
   IF (death_trans_val=1
    AND ccdr.dataset_id=sts02_dataset)
    report_rec->period[ccf_date_idx].cnt_data[nbr_death].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[nbr_death].rec_cnt+ 1)
   ENDIF
   IF (death_trans_235=2
    AND ccdr.dataset_id=sts01_dataset)
    report_rec->period[ccf_date_idx].cnt_data[nbr_death].rec_cnt = (report_rec->period[ccf_date_idx].
    cnt_data[nbr_death].rec_cnt+ 1)
   ENDIF
   report_rec->period[ccf_date_idx].cnt_data[tot_nbr].rec_cnt = (report_rec->period[ccf_date_idx].
   cnt_data[tot_nbr].rec_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No matched cases found for verification!")
  SET verify_fail = "T"
  GO TO exit_script
 ENDIF
 DECLARE new_file_seq = i4 WITH protect, noconstant((size(reply->files,5)+ 1))
 SET stat = alterlist(reply->files,new_file_seq)
 SET reply->files[new_file_seq].filename = concat(request->part_nbr,"adt_verify.dat")
 DECLARE saved_file_path = vc WITH protect, noconstant(concat("cer_temp:",reply->files[new_file_seq].
   filename))
 DECLARE blank = c25 WITH protect, constant(fillstring(25," "))
 DECLARE blank0 = c21 WITH protect, constant(fillstring(21," "))
 DECLARE blank1 = c23 WITH protect, constant(fillstring(23," "))
 DECLARE blank2 = c12 WITH protect, constant(fillstring(12," "))
 DECLARE blank3 = c5 WITH protect, constant(fillstring(5," "))
 DECLARE from_date_str = vc WITH protect, noconstant(" ")
 DECLARE to_date_str = vc WITH protect, noconstant(" ")
 DECLARE last_line = i4 WITH protect, noconstant(1)
 DECLARE cur_size = i2 WITH protect
 DECLARE rec_str = vc WITH protect
 FOR (i = 1 TO size(report_rec->period,5))
   SET from_date_str = trim(format(cnvtdatetime(report_rec->period[i].from_date),"@LONGDATE"),3)
   SET to_date_str = trim(format(cnvtdatetime(report_rec->period[i].to_date),"@LONGDATE"),3)
   SET rec_size = size(report_rec->period[i].cnt_data,5)
   SET cur_size = size(reply->files[new_file_seq].info_line,5)
   SET stat = alterlist(reply->files[new_file_seq].info_line,((rec_size+ cur_size)+ 1))
   SET reply->files[new_file_seq].info_line[last_line].new_line = concat("Type of Procedure","    ",
    "# of Records(",from_date_str,"-",
    to_date_str,")")
   FOR (j = 1 TO rec_size)
     SET last_line = (last_line+ 1)
     SET rec_str = cnvtstring(report_rec->period[i].cnt_data[j].rec_cnt)
     CASE (j)
      OF 1:
      OF 2:
      OF 3:
       SET reply->files[new_file_seq].info_line[last_line].new_line = concat(report_rec->period[i].
        cnt_data[j].case_type,blank,rec_str)
      OF 4:
      OF 5:
       SET reply->files[new_file_seq].info_line[last_line].new_line = concat(report_rec->period[i].
        cnt_data[j].case_type,blank0,rec_str)
      OF 6:
       SET reply->files[new_file_seq].info_line[last_line].new_line = concat(report_rec->period[i].
        cnt_data[j].case_type,blank1,rec_str)
      OF 7:
       SET reply->files[new_file_seq].info_line[last_line].new_line = concat(report_rec->period[i].
        cnt_data[j].case_type,blank2,rec_str)
      OF 8:
       SET reply->files[new_file_seq].info_line[last_line].new_line = concat(report_rec->period[i].
        cnt_data[j].case_type,blank3,rec_str)
     ENDCASE
   ENDFOR
   SET last_line = (last_line+ 1)
 ENDFOR
 CALL echorecord(reply,saved_file_path)
#exit_script
 IF (verify_fail="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("***********************************************")
  CALL echo(build("File save at directory-> ",saved_file_path))
  CALL echo("***********************************************")
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
 DECLARE cv_get_harvest_verification_vrsn = vc WITH private, constant("MOD 005 BM9013 05/19/06")
END GO
