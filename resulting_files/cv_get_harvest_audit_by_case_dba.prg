CREATE PROGRAM cv_get_harvest_audit_by_case:dba
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
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply  is already defined !")
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
 DECLARE sfailed = c1 WITH private, noconstant("F")
 DECLARE max_field_rec = i4 WITH public, noconstant(0)
 DECLARE cv_device_str = c9 WITH public, constant("; Device ")
 DECLARE cv_lesion_str = c7 WITH public, constant("Lesion ")
 SELECT INTO "nl:"
  case_id = ccdr.cv_case_id
  FROM (dummyt d  WITH seq = value(size(request->case_ids,5))),
   cv_case cc,
   cv_case_dataset_r ccdr,
   cv_case_field ccf,
   person p,
   cv_xref cx
  PLAN (d)
   JOIN (cc
   WHERE (cc.cv_case_id=request->case_ids[d.seq].cv_case_id))
   JOIN (ccdr
   WHERE cc.cv_case_id=ccdr.cv_case_id)
   JOIN (p
   WHERE p.person_id=cc.person_id)
   JOIN (ccf
   WHERE ccf.case_dataset_r_id=ccdr.case_dataset_r_id)
   JOIN (cx
   WHERE cx.xref_id=ccf.xref_id)
  ORDER BY case_id
  HEAD REPORT
   ccnt = 0
  HEAD case_id
   fcnt = 0, ccnt = (ccnt+ 1)
   IF (mod(ccnt,10)=1)
    stat = alterlist(reply->caserec,(ccnt+ 9))
   ENDIF
   reply->caserec[ccnt].case_id = ccdr.cv_case_id, reply->caserec[ccnt].status_cd = ccdr.status_cd,
   reply->caserec[ccnt].error_msg = ccdr.error_msg,
   reply->caserec[ccnt].person_id = cc.person_id, reply->caserec[ccnt].encntr_id = cc.encntr_id,
   reply->caserec[ccnt].name_full_formatted = p.name_full_formatted,
   reply->caserec[ccnt].form_id = cc.form_id, reply->caserec[ccnt].chart_dt_tm = cc.chart_dt_tm
  DETAIL
   fcnt = (fcnt+ 1)
   IF (mod(fcnt,10)=1)
    stat = alterlist(reply->caserec[ccnt].fieldrec,(fcnt+ 9))
   ENDIF
   reply->caserec[ccnt].fieldrec[fcnt].field_name = cx.registry_field_name, reply->caserec[ccnt].
   fieldrec[fcnt].long_text_id = ccf.long_text_id, reply->caserec[ccnt].fieldrec[fcnt].status_cd =
   ccf.status_cd,
   reply->caserec[ccnt].fieldrec[fcnt].case_field_id = ccf.case_field_id, reply->caserec[ccnt].
   fieldrec[fcnt].translated_val = ccf.translated_val, reply->caserec[ccnt].fieldrec[fcnt].field_val
    = ccf.result_val,
   reply->caserec[ccnt].fieldrec[fcnt].dev_idx = ccf.dev_idx, reply->caserec[ccnt].fieldrec[fcnt].
   lesion_idx = ccf.lesion_idx
   IF (ccf.dev_idx > 0)
    reply->caserec[ccnt].fieldrec[fcnt].field_name = build(cv_device_str,ccf.dev_idx,": ",reply->
     caserec[ccnt].fieldrec[fcnt].field_name)
   ENDIF
   IF (ccf.lesion_idx > 0)
    reply->caserec[ccnt].fieldrec[fcnt].field_name = build(cv_lesion_str,ccf.lesion_idx,": ",reply->
     caserec[ccnt].fieldrec[fcnt].field_name)
   ENDIF
  FOOT  case_id
   stat = alterlist(reply->caserec[ccnt].fieldrec,fcnt)
   IF (max_field_rec < fcnt)
    max_field_rec = fcnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->caserec,ccnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM (dummyt d1  WITH seq = value(size(reply->caserec,5))),
   (dummyt d2  WITH seq = value(max_field_rec)),
   long_text lt
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->caserec[d1.seq].fieldrec,5)
    AND (reply->caserec[d1.seq].fieldrec[d2.seq].long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->caserec[d1.seq].fieldrec[d2.seq].long_text_id))
  DETAIL
   reply->caserec[d1.seq].fieldrec[d2.seq].error_msg = lt.long_text
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET sfailed = "T"
  GO TO get_data_failure
 ENDIF
 GO TO exit_script
#get_data_failure
 IF (sfailed="T")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Get Data"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV Case Field"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed in getting data!"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  SET reply->status_data.status = "F"
  CALL echo("*************")
  CALL echo("Reply Failed!")
  CALL echo("*************")
 ELSE
  SET reply->status_data.status = "S"
  CALL echo("*************")
  CALL echo("Reply Success!")
  CALL echo("*************")
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
