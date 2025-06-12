CREATE PROGRAM cv_get_date_range:dba
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
 DECLARE sts_special_ind = i2
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH protect, noconstant("T")
 DECLARE from_name = vc WITH protect, noconstant("FROM")
 DECLARE to_name = vc WITH protect, noconstant("TO")
 DECLARE translated_val = vc WITH protect, noconstant("TRANSLATE")
 DECLARE cvnet_date_cs = i4 WITH protect, constant(25832)
 DECLARE omf_date_cs = i4 WITH protect, constant(14729)
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE arr_size = i4 WITH protect, constant(size(request->date_range,5))
 IF (arr_size <= 0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->date_range,arr_size)
 IF ( NOT (validate(cur_yr,0)))
  DECLARE cur_yr = i4 WITH protect
 ENDIF
 IF (validate(season,"NOTDEFINED") != "NOTDEFINED")
  CALL echo("Season is defined!")
 ELSE
  DECLARE season = c1 WITH protect, noconstant(" ")
 ENDIF
 SET cur_yr = getcuryr(request->date_range[1].code_value)
 SET season = getseason(request->date_range[1].code_value)
 CALL echo(build("CUR_YR:",cur_yr))
 CALL echo(build("SEASON:",season))
 IF (season != " ")
  SET sts_special_ind = 1
  DECLARE cur_yr_str = c4
  IF (cur_yr=0)
   SET cur_yr = year(curdate)
  ENDIF
  SET cur_yr_str = cnvtstring(cur_yr)
  SET hrv_range1 = trim(cnvtstring((cur_yr - 2)),3)
  SET hrv_range2 = trim(cnvtstring((cur_yr - 1)),3)
  CASE (season)
   OF "S":
    SET request->date_range[1].from_date_str = build("cnvtdatetime('01-JAN-",hrv_range1,"')")
    SET request->date_range[1].to_date_str = build("cnvtdatetime('31-DEC-",hrv_range2,"')")
   OF "F":
    SET request->date_range[1].from_date_str = build("cnvtdatetime('01-JUL-",hrv_range1,"')")
    SET request->date_range[1].to_date_str = build("cnvtdatetime('30-JUN-",cur_yr_str,"')")
  ENDCASE
 ENDIF
 IF (sts_special_ind=0)
  SELECT INTO "nl:"
   FROM omf_relative_dates ord
   PLAN (ord
    WHERE expand(idx,1,arr_size,ord.relative_date_cd,request->date_range[idx].code_value))
   DETAIL
    num = locateval(idx,1,arr_size,ord.relative_date_cd,request->date_range[idx].code_value), request
    ->date_range[num].to_date_str = ord.to_date_str, request->date_range[num].from_date_str = ord
    .from_date_str
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failure in selecting code_value & omf_relative_dates!")
  ENDIF
  SELECT INTO "nl:"
   FROM code_value_extension cve
   PLAN (cve
    WHERE expand(idx,1,arr_size,cve.code_value,request->date_range[idx].code_value)
     AND cve.field_name IN (from_name, to_name, translated_val)
     AND cve.code_set=cvnet_date_cs)
   DETAIL
    num = locateval(idx,1,arr_size,cve.code_value,request->date_range[idx].code_value)
    CASE (cve.field_name)
     OF from_name:
      request->date_range[num].from_date_str = build("cnvtdatetime('",cve.field_value,"')")
     OF to_name:
      request->date_range[num].to_date_str = build("cnvtdatetime('",cve.field_value,"')")
     OF translated_val:
      reply->date_range[num].translated_val = cve.field_value
    ENDCASE
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failure in selecting code_value & code_value_extension!")
  ENDIF
 ENDIF
 FOR (i = 1 TO arr_size)
  SELECT INTO "nl:"
   to_date = parser(request->date_range[i].to_date_str), from_date = parser(request->date_range[i].
    from_date_str)
   FROM dual t
   DETAIL
    reply->date_range[i].to_date = to_date, reply->date_range[i].from_date = from_date, reply->
    date_range[i].to_date_str = request->date_range[i].to_date_str,
    reply->date_range[i].from_date_str = request->date_range[i].from_date_str
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failure in selecting dual t!")
  ENDIF
 ENDFOR
 SET failure = "F"
#exit_script
 IF (failure="T")
  SET reply->status_data.subeventstatus[1].operationname = "get_date_range"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_date_range"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_get_date_range"
  SET reply->status_data.status = "Z"
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
 DECLARE cv_get_date_range_vrsn = vc WITH private, constant("MOD 003 02/22/06 BM9013")
END GO
