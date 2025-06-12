CREATE PROGRAM cv_get_all_dataset_part_nbr:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD internal(
   1 max_part_cnt = i4
   1 max_dataset_cnt = i4
   1 pools[*]
     2 alias_pool_mean = vc
     2 alias_pool_cd = f8
     2 datasets[*]
       3 dataset_id = f8
     2 parts[*]
       3 participant_nbr = vc
       3 display = vc
       3 type = i2
 )
 DECLARE cs_alias_pool = i4 WITH noconstant(263), protect
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE part_type_organization = i2 WITH constant(1)
 DECLARE part_type_prsnl = i2 WITH constant(2)
 DECLARE pool_cnt = i4
 DECLARE part_cnt = i4
 SELECT DISTINCT INTO "nl:"
  cd.alias_pool_mean, pool_cd = uar_get_code_by("MEANING",cs_alias_pool,cd.alias_pool_mean), cdr
  .participant_nbr
  FROM cv_dataset cd,
   cv_case_dataset_r cdr
  PLAN (cd
   WHERE cd.dataset_id > 0)
   JOIN (cdr
   WHERE cdr.dataset_id=cd.dataset_id)
  ORDER BY cd.alias_pool_mean, cdr.participant_nbr
  HEAD REPORT
   pool_cnt = 0
  HEAD cd.alias_pool_mean
   pool_cnt = (pool_cnt+ 1), part_cnt = 0, stat = alterlist(internal->pools,pool_cnt),
   internal->pools[pool_cnt].alias_pool_mean = cd.alias_pool_mean, internal->pools[pool_cnt].
   alias_pool_cd = pool_cd
  DETAIL
   part_cnt = (part_cnt+ 1), stat = alterlist(internal->pools[pool_cnt].parts,part_cnt), internal->
   pools[pool_cnt].parts[part_cnt].participant_nbr = cdr.participant_nbr
  FOOT  cd.alias_pool_mean
   IF ((internal->max_part_cnt < part_cnt))
    internal->max_part_cnt = part_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No participants found")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cd.dataset_id
  FROM (dummyt d1  WITH seq = pool_cnt),
   cv_dataset cd
  PLAN (d1
   WHERE (internal->pools[d1.seq].alias_pool_cd > 0))
   JOIN (cd
   WHERE (cd.alias_pool_mean=internal->pools[d1.seq].alias_pool_mean))
  ORDER BY d1.seq
  HEAD d1.seq
   dataset_cnt = 0
  DETAIL
   dataset_cnt = (dataset_cnt+ 1), stat = alterlist(internal->pools[d1.seq].datasets,dataset_cnt),
   internal->pools[d1.seq].datasets[dataset_cnt].dataset_id = cd.dataset_id
  FOOT  d1.seq
   IF ((dataset_cnt > internal->max_dataset_cnt))
    internal->max_dataset_cnt = dataset_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  disp = o.org_name
  FROM (dummyt d1  WITH seq = pool_cnt),
   (dummyt d2  WITH seq = internal->max_part_cnt),
   organization_alias oa,
   organization o
  PLAN (d1)
   JOIN (d2
   WHERE (internal->pools[d1.seq].alias_pool_cd > 0)
    AND d2.seq <= size(internal->pools[d1.seq].parts,5)
    AND (internal->pools[d1.seq].parts[d2.seq].type=0))
   JOIN (oa
   WHERE (oa.alias=internal->pools[d1.seq].parts[d2.seq].participant_nbr)
    AND (oa.alias_pool_cd=internal->pools[d1.seq].alias_pool_cd))
   JOIN (o
   WHERE o.organization_id=oa.organization_id)
  DETAIL
   internal->pools[d1.seq].parts[d2.seq].type = part_type_organization, internal->pools[d1.seq].
   parts[d2.seq].display = concat(trim(disp)," (",internal->pools[d1.seq].parts[d2.seq].
    participant_nbr,")")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  disp = p.name_full_formatted
  FROM (dummyt d1  WITH seq = pool_cnt),
   (dummyt d2  WITH seq = internal->max_part_cnt),
   prsnl_alias pa,
   person p
  PLAN (d1)
   JOIN (d2
   WHERE (internal->pools[d1.seq].alias_pool_cd > 0)
    AND d2.seq <= size(internal->pools[d1.seq].parts,5)
    AND (internal->pools[d1.seq].parts[d2.seq].type=0))
   JOIN (pa
   WHERE (pa.alias=internal->pools[d1.seq].parts[d2.seq].participant_nbr)
    AND (pa.alias_pool_cd=internal->pools[d1.seq].alias_pool_cd))
   JOIN (p
   WHERE p.person_id=pa.person_id)
  DETAIL
   internal->pools[d1.seq].parts[d2.seq].type = part_type_prsnl, internal->pools[d1.seq].parts[d2.seq
   ].display = concat(trim(disp)," (",internal->pools[d1.seq].parts[d2.seq].participant_nbr,")")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = pool_cnt),
   (dummyt d2  WITH seq = internal->max_part_cnt),
   (dummyt d3  WITH seq = internal->max_dataset_cnt)
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal->pools[d1.seq].parts,5))
   JOIN (d3
   WHERE d3.seq <= size(internal->pools[d1.seq].datasets,5))
  HEAD REPORT
   reply_cnt = 0
  DETAIL
   reply_cnt = (reply_cnt+ 1), stat = alterlist(reply->qual,reply_cnt), reply->qual[reply_cnt].
   dataset_id = internal->pools[d1.seq].datasets[d3.seq].dataset_id
   IF (size(trim(internal->pools[d1.seq].parts[d2.seq].display))=0)
    reply->qual[reply_cnt].display = internal->pools[d1.seq].parts[d2.seq].participant_nbr
   ELSE
    reply->qual[reply_cnt].display = internal->pools[d1.seq].parts[d2.seq].display
   ENDIF
   reply->qual[reply_cnt].part_nbr = internal->pools[d1.seq].parts[d2.seq].participant_nbr
  WITH nocounter
 ;end select
#exit_script
 IF (failure="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "get_participant_nbr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_all_dataset_part_nbr"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_get_all_participant_nbr"
  SET reply->status_data.status = "Z"
  CALL cv_log_message("No Participant Number was found!!")
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
