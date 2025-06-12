CREATE PROGRAM cv_get_acc_password:dba
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
    1 qual[*]
      2 dataset_id = f8
      2 display = vc
      2 part_nbr = vc
      2 password = vc
      2 mindataset = c1
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cs_alias_pool = i4 WITH protect, constant(263)
 DECLARE ds_int_name = vc WITH protect, constant("ACC03")
 DECLARE pref_sec_pwd = vc WITH protect, constant("EXPORT_PASSWORD")
 DECLARE pref_domain_cv = vc WITH protect, constant("CVNET")
 DECLARE pref_sec_minds = vc WITH protect, constant("MINIMUM_DATA_SET")
 DECLARE failure = c1 WITH protect, noconstant("T")
 DECLARE pn_cnt = i4 WITH protect
 DECLARE ds_cnt = i4 WITH protect
 DECLARE aliaspool_cv = f8 WITH protect
 DECLARE alias_pool_mn = vc WITH protect
 DECLARE ds_id = f8 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE idx = i4 WITH protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cd.alias_pool_mean
  FROM cv_dataset cd
  WHERE cd.dataset_internal_name=ds_int_name
   AND cd.active_ind=1
  HEAD REPORT
   ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1), alias_pool_mn = cd.alias_pool_mean, ds_id = cd.dataset_id
  WITH nocounter
 ;end select
 CALL cv_check_err("SELECT","F","CV_DATASET")
 IF (curqual=0)
  CALL zerorowsfound("Failure in selecting cv_dataset table!")
 ENDIF
 IF (ds_cnt > 1)
  CALL cv_log_message("More than one ACCv3 dataset found!")
  GO TO exit_script
 ENDIF
 SET aliaspool_cv = uar_get_code_by("MEANING",cs_alias_pool,nullterm(alias_pool_mn))
 IF (aliaspool_cv < 1)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.cdf_meaning=alias_pool_mn
    AND cv.code_set=cs_alias_pool
    AND cv.active_ind=1
   DETAIL
    aliaspool_cv = cv.code_value
   WITH nocounter
  ;end select
  CALL cv_check_err("SELECT","F","CODE_VALUE")
 ENDIF
 IF (aliaspool_cv < 1)
  CALL scriptfailure("Can't find alias pool value for ACC dataset. Can't continue!")
 ENDIF
 SELECT INTO "nl"
  alias_nbr = cnvtint(oa.alias)
  FROM dm_prefs dp,
   organization_alias oa,
   organization o
  PLAN (dp
   WHERE dp.pref_domain=pref_domain_cv
    AND dp.pref_section=pref_sec_pwd)
   JOIN (oa
   WHERE oa.alias_pool_cd=aliaspool_cv
    AND oa.active_ind=1
    AND oa.alias=cnvtstring(dp.pref_nbr))
   JOIN (o
   WHERE o.organization_id=oa.organization_id
    AND o.active_ind=1)
  HEAD REPORT
   oa_cnt = 0
  DETAIL
   IF (alias_nbr > 0)
    oa_cnt = (oa_cnt+ 1)
    IF (mod(oa_cnt,10)=1)
     stat = alterlist(reply->qual,(oa_cnt+ 9))
    ENDIF
    reply->qual[oa_cnt].display = trim(o.org_name), reply->qual[oa_cnt].dataset_id = ds_id, reply->
    qual[oa_cnt].part_nbr = trim(oa.alias),
    reply->qual[oa_cnt].password = trim(dp.pref_str)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,oa_cnt)
  WITH nocounter
 ;end select
 CALL cv_check_err("SELECT","F","ORGANIZATION_ALIAS")
 IF (curqual=0)
  CALL zerorowsfound("No records in Org Alias Pool for Org ID!")
 ENDIF
 SELECT
  IF (size(reply->qual,5)=1)
   WHERE dp.pref_domain=pref_domain_cv
    AND dp.pref_section=pref_sec_minds
    AND dp.pref_str IN ("Y", "N")
    AND (dp.pref_name=reply->qual[1].part_nbr)
  ELSE
  ENDIF
  INTO "nl:"
  FROM dm_prefs dp
  WHERE dp.pref_domain=pref_domain_cv
   AND dp.pref_section=pref_sec_minds
   AND dp.pref_str IN ("Y", "N")
   AND expand(idx,1,size(reply->qual,5),dp.pref_name,reply->qual[idx].part_nbr)
  DETAIL
   IF (size(reply->qual,5)=1)
    num = 1
   ELSE
    num = locateval(idx,1,size(reply->qual,5),dp.pref_name,reply->qual[idx].part_nbr)
   ENDIF
   reply->qual[num].mindataset = trim(dp.pref_str)
  WITH nocounter
 ;end select
 CALL cv_check_err("SELECT","F","DM_PREFS")
 IF (curqual=0)
  CALL zerorowsfound("No minimum dataset indicator in dm_prefs!")
 ENDIF
 DECLARE zerorowsfound(message=cv) = null
 SUBROUTINE zerorowsfound(message)
   CALL cv_log_message(message)
   SET reply->status_data.status = "Z"
   GO TO exit_script
 END ;Subroutine
 SET failure = "F"
 SET reply->status_data.status = "S"
#exit_script
 DECLARE cv_get_acc_password_vrsn = vc WITH private, constant("MOD 002 02/26/06 BM9013")
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
