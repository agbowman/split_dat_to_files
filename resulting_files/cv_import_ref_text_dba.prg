CREATE PROGRAM cv_import_ref_text:dba
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
 IF (validate(ref_text_request) != 1)
  RECORD ref_text_request(
    1 ref_text_reltn_id = f8
    1 ref_text_id = f8
    1 long_blob_id = f8
    1 text_type_cd = f8
    1 parent_entity_name = c40
    1 parent_entity_id = f8
    1 long_blob = vc
    1 ref_text_mask = i4
    1 prep_info_flag = i2
  )
 ENDIF
 IF (validate(ref_text_list) != 1)
  RECORD ref_text_list(
    1 qual[*]
      2 task_assay_cd = f8
      2 cdf_meaning = vc
      2 text_exists = c1
      2 long_blob = vc
      2 long_blob_id = f8
      2 ref_text_id = f8
      2 ref_text_reltn_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
    1 ref_text_reltn_id = f8
    1 ref_text_id = f8
    1 long_blob_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE text_type_chart_guide_cd = f8 WITH protect
 DECLARE forcount = i4 WITH protect
 DECLARE reftext_dta = f8 WITH protect
 DECLARE cnt1 = i4 WITH protect
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE stat = i4 WITH protect
 DECLARE ref_text_codeset = i4 WITH protect, constant(6009)
 DECLARE dta_codeset = i4 WITH protect, constant(14003)
 DECLARE idx = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(10)
 DECLARE nstart = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 SET cur_list_size = size(requestin->list_0,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(requestin->list_0,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET requestin->list_0[idx].cdf_meaning = requestin->list_0[cur_list_size].cdf_meaning
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,requestin->list_0[idx].
    cdf_meaning)
    AND cv.code_set=dta_codeset
    AND cv.active_ind=1)
  HEAD REPORT
   num1 = 0, cnt1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,requestin->list_0[num1].cdf_meaning)
   WHILE (index != 0)
     cnt1 = (cnt1+ 1), stat = alterlist(ref_text_list->qual,cnt1), ref_text_list->qual[cnt1].
     task_assay_cd = cv.code_value,
     ref_text_list->qual[cnt1].cdf_meaning = cv.cdf_meaning, ref_text_list->qual[cnt1].long_blob =
     requestin->list_0[index].reference_text, ref_text_list->qual[cnt1].text_exists = "F",
     index = locateval(num1,(index+ 1),cur_list_size,cv.cdf_meaning,requestin->list_0[num1].
      cdf_meaning)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(requestin->list_0,cur_list_size)
 IF (size(ref_text_list->qual,5) < 1)
  CALL cv_log_message("No items found in ref text import. Leaving script")
  SET failure = "Z"
  GO TO exit_script
 ENDIF
 SET text_type_chart_guide_cd = uar_get_code_by("MEANING",ref_text_codeset,"CHART GUIDE")
 IF (text_type_chart_guide_cd < 1.0)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=ref_text_codeset
    AND cv.cdf_meaning="CHART GUIDE"
    AND cv.active_ind=1
   DETAIL
    text_type_chart_guide_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL cv_check_err("SELECT","F","CODE_VALUE")
 ENDIF
 IF (text_type_chart_guide_cd < 1.0)
  CALL cv_log_message("Can't find code_value for CHART GUIDE!")
 ENDIF
 SELECT INTO "nl:"
  rtr.parent_entity_id, rtr.text_type_cd, rt.refr_text_id,
  rtr.ref_text_reltn_id, lb.long_blob_id
  FROM (dummyt d  WITH seq = value(size(ref_text_list->qual,5))),
   ref_text_reltn rtr,
   ref_text rt,
   long_blob lb
  PLAN (d
   WHERE (ref_text_list->qual[d.seq].task_assay_cd > 0.0))
   JOIN (rtr
   WHERE (rtr.parent_entity_id=ref_text_list->qual[d.seq].task_assay_cd)
    AND rtr.parent_entity_name="DISCRETE_TASK_ASSAY"
    AND rtr.text_type_cd=text_type_chart_guide_cd
    AND rtr.active_ind=1)
   JOIN (rt
   WHERE rt.refr_text_id=rtr.refr_text_id
    AND trim(rt.text_entity_name)="LONG_BLOB"
    AND rt.text_type_cd=text_type_chart_guide_cd
    AND rt.active_ind=1)
   JOIN (lb
   WHERE lb.long_blob_id=rt.text_entity_id
    AND lb.parent_entity_name="REF_TEXT"
    AND ((lb.parent_entity_id+ 0)=rt.refr_text_id)
    AND lb.active_ind=1)
  DETAIL
   ref_text_list->qual[d.seq].text_exists = "T", ref_text_list->qual[d.seq].ref_text_id = rt
   .refr_text_id, ref_text_list->qual[d.seq].ref_text_reltn_id = rtr.ref_text_reltn_id,
   ref_text_list->qual[d.seq].long_blob_id = lb.long_blob_id
  WITH nocounter
 ;end select
 CALL cv_check_err("SELECT","F","REF_TEXT_RELTN")
 IF (curqual=0)
  CALL cv_log_message("No previous reference texts in database. Continuing...")
 ENDIF
 SET forcount = 0
 FOR (forcount = 1 TO size(ref_text_list->qual,5))
   IF ((ref_text_list->qual[forcount].text_exists="T"))
    SET ref_text_request->ref_text_reltn_id = ref_text_list->qual[forcount].ref_text_reltn_id
    SET ref_text_request->ref_text_id = ref_text_list->qual[forcount].ref_text_id
    SET ref_text_request->long_blob_id = ref_text_list->qual[forcount].long_blob_id
   ELSE
    SET ref_text_request->ref_text_reltn_id = 0.0
    SET ref_text_request->ref_text_id = 0.0
    SET ref_text_request->long_blob_id = 0.0
   ENDIF
   SET ref_text_request->text_type_cd = text_type_chart_guide_cd
   SET ref_text_request->parent_entity_name = "DISCRETE_TASK_ASSAY"
   SET ref_text_request->parent_entity_id = ref_text_list->qual[forcount].task_assay_cd
   SET ref_text_request->long_blob = ref_text_list->qual[forcount].long_blob
   SET ref_text_request->ref_text_mask = 0
   SET ref_text_request->prep_info_flag = 0
   EXECUTE dcp_upd_ref_text  WITH replace("REQUEST","REF_TEXT_REQUEST")
   SET modify = nopredeclare
   IF ((reply->status_data.status="S"))
    CALL cv_log_message(concat("Insert of ref_text for ",ref_text_list->qual[forcount].cdf_meaning,
      " was successful."))
    CALL cv_log_message(concat("Ref_text_reltn_id=",cnvtstring(reply->ref_text_reltn_id),
      " Ref_text_id=",cnvtstring(reply->ref_text_id)," Long_blob_id=",
      cnvtstring(reply->long_blob_id)))
   ELSE
    CALL cv_log_message(concat("Insert of ref_text for ",ref_text_list->qual[forcount].cdf_meaning,
      " failed."))
    CALL cv_log_message(concat(reply->status_data.subeventstatus[1].operationname," failed on ",reply
      ->status_data.subeventstatus[1].targetobjectname," : ",reply->status_data.subeventstatus[1].
      targetobjectvalue))
   ENDIF
 ENDFOR
#exit_script
 FREE RECORD ref_text_list
 FREE RECORD ref_text_request
 IF (failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSEIF (failure="Z")
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
 DECLARE cv_import_ref_text_vrsn = vc WITH private, constant("MOD 002 BM9013 05/30/06")
END GO
