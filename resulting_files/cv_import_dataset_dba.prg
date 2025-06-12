CREATE PROGRAM cv_import_dataset:dba
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
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
 IF (validate(reply->status_data.status)=0)
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL cv_log_message("reply already defined!")
 ENDIF
 FREE RECORD request_dataset
 RECORD request_dataset(
   1 dataset_rec
     2 dataset_internal_name = vc
     2 display_name = vc
     2 dataset_id = f8
     2 validationscript = vc
     2 aliaspoolmean = vc
     2 casedatemean = vc
     2 transaction = i2
 )
 FREE RECORD request_xref
 RECORD request_xref(
   1 cv_xref_rec[*]
     2 dataset_id = f8
     2 dataset_index = i2
     2 xref_internal_name = vc
     2 registry_field_name = vc
     2 cern_source_table_name = c30
     2 cern_source_field_name = c30
     2 event_type_cd = f8
     2 sub_event_type_cd = f8
     2 group_type_cd = f8
     2 event_type_mean = vc
     2 sub_event_type_mean = vc
     2 group_type_mean = vc
     2 cdf_meaning = vc
     2 xref_id = f8
     2 transaction = i2
     2 field_type_cd = f8
     2 field_type_mean = vc
     2 reqdflag = i2
     2 display_fld_ind = i2
     2 collect_start_dt_tm = dq8
     2 collect_stop_dt_tm = dq8
     2 audit_flag = i2
     2 element_nbr = i4
 )
 FREE RECORD request_response
 RECORD request_response(
   1 response_rec[*]
     2 field_type = c1
     2 response_internal_name = vc
     2 a1 = vc
     2 a2 = vc
     2 a3 = vc
     2 a4 = vc
     2 a5 = vc
     2 xref_id = f8
     2 xref_index = i2
     2 response_id = f8
     2 transaction = i2
 )
 FREE RECORD reply_dataset
 RECORD reply_dataset(
   1 dataset_rec[*]
     2 dataset_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE element_nbr_ind = i4 WITH protect
 DECLARE collect_ind = i4 WITH protect
 DECLARE audit_ind = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE xref_chg_cnt = i4 WITH protect
 DECLARE response_chg_cnt = i4 WITH protect
 IF (validate(requestin->list_0[1].effective_dt_tm)=0)
  SET collect_ind = 0
 ELSE
  SET collect_ind = 1
 ENDIF
 IF (validate(requestin->list_0[1].audit_flag)=0)
  SET audit_ind = 0
 ELSE
  SET audit_ind = 1
  IF (validate(requestin->list_0[1].element_nbr)=0)
   SET element_nbr_ind = 0
  ELSE
   SET element_nbr_ind = 1
  ENDIF
 ENDIF
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE cur_dataset = vc WITH protect, constant(cnvtupper(trim(requestin->list_0[1].datasetname)))
 DECLARE data_set_id = f8 WITH protect
 SELECT INTO "NL:"
  FROM cv_dataset cd
  WHERE (cd.dataset_internal_name=requestin->list_0[1].datasetname)
  DETAIL
   data_set_id = cd.dataset_id
  WITH nocounter
 ;end select
 SET request_dataset->dataset_rec.dataset_internal_name = requestin->list_0[1].datasetname
 SET request_dataset->dataset_rec.display_name = requestin->list_0[1].internalfieldname_xref
 SET request_dataset->dataset_rec.validationscript = requestin->list_0[1].validationscript
 SET request_dataset->dataset_rec.aliaspoolmean = requestin->list_0[1].aliaspoolmean
 SET request_dataset->dataset_rec.casedatemean = requestin->list_0[1].casedatemean
 IF (data_set_id=0.0)
  SET request_dataset->dataset_rec.transaction = cv_trns_add
  EXECUTE cv_add_fld_dataset  WITH replace("REQUEST","REQUEST_DATASET"), replace("REPLY",
   "REPLY_DATASET")
 ELSE
  SET request_dataset->dataset_rec.transaction = cv_trns_chg
  SET request_dataset->dataset_rec.dataset_id = data_set_id
  CALL echorecord(request_dataset,"cer_temp:request_dataset.dat")
  EXECUTE cv_chg_fld_dataset  WITH replace("REQUEST","REQUEST_DATASET"), replace("REPLY",
   "REPLY_DATASET")
 ENDIF
 CALL echorecord(reply_dataset,"cer_temp:reply_dataset.dat")
 DECLARE fld_cnt = i4 WITH protect
 DECLARE response_cnt = i4 WITH protect
 SELECT
  IF (collect_ind=1
   AND element_nbr_ind=1)
   collect_start = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].effective_dt_tm,"MM/DD/YYYY"),0),
   collect_stop = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].expiration_dt_tm,"MM/DD/YYYY"),0),
   internal_field_name_xref = requestin->list_0[d.seq].internalfieldname_xref,
   audit_flag = cnvtint(requestin->list_0[d.seq].audit_flag), element_nbr = cnvtint(requestin->
    list_0[d.seq].element_nbr)
  ELSEIF (collect_ind=1
   AND audit_ind=1)
   collect_start = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].effective_dt_tm,"MM/DD/YYYY"),0),
   collect_stop = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].expiration_dt_tm,"MM/DD/YYYY"),0),
   internal_field_name_xref = requestin->list_0[d.seq].internalfieldname_xref,
   audit_flag = cnvtint(requestin->list_0[d.seq].audit_flag), element_nbr = 0
  ELSEIF (collect_ind=1
   AND audit_ind=0)
   collect_start = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].effective_dt_tm,"MM/DD/YYYY"),0),
   collect_stop = cnvtdatetime(cnvtdate2(requestin->list_0[d.seq].expiration_dt_tm,"MM/DD/YYYY"),0),
   internal_field_name_xref = requestin->list_0[d.seq].internalfieldname_xref,
   audit_flag = 0, element_nbr = 0
  ELSEIF (collect_ind=0
   AND element_nbr_ind=1)
   collect_start = 0.0, collect_stop = 0.0, internal_field_name_xref = requestin->list_0[d.seq].
   internalfieldname_xref,
   audit_flag = cnvtint(requestin->list_0[d.seq].audit_flag), element_nbr = cnvtint(requestin->
    list_0[d.seq].element_nbr)
  ELSEIF (collect_ind=0
   AND audit_ind=1)
   collect_start = 0.0, collect_stop = 0.0, internal_field_name_xref = requestin->list_0[d.seq].
   internalfieldname_xref,
   audit_flag = cnvtint(requestin->list_0[d.seq].audit_flag), element_nbr = 0
  ELSE
   collect_start = 0.0, collect_stop = 0.0, internal_field_name_xref = requestin->list_0[d.seq].
   internalfieldname_xref,
   audit_flag = 0, element_nbr = 0
  ENDIF
  INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 1)
  ORDER BY internal_field_name_xref
  HEAD REPORT
   data_set_cnt = 0, fld_cnt = 0, response_cnt = 0,
   old_internalfieldname_xref = fillstring(100," "), new_internalfieldname_xref = fillstring(100," ")
  HEAD internal_field_name_xref
   fld_cnt = (fld_cnt+ 1)
   IF (mod(fld_cnt,10)=1)
    stat = alterlist(request_xref->cv_xref_rec,(fld_cnt+ 9))
   ENDIF
   request_xref->cv_xref_rec[fld_cnt].dataset_index = data_set_cnt, request_xref->cv_xref_rec[fld_cnt
   ].dataset_id = reply_dataset->dataset_rec[1].dataset_id, request_xref->cv_xref_rec[fld_cnt].
   xref_internal_name = trim(internal_field_name_xref),
   request_xref->cv_xref_rec[fld_cnt].registry_field_name = requestin->list_0[d.seq].
   registryfieldname, request_xref->cv_xref_rec[fld_cnt].cern_source_table_name = requestin->list_0[d
   .seq].cernsourcetablename, request_xref->cv_xref_rec[fld_cnt].cern_source_field_name = requestin->
   list_0[d.seq].cernsourcefieldname,
   request_xref->cv_xref_rec[fld_cnt].event_type_mean = requestin->list_0[d.seq].eventtype,
   request_xref->cv_xref_rec[fld_cnt].sub_event_type_mean = requestin->list_0[d.seq].subeventtype,
   request_xref->cv_xref_rec[fld_cnt].group_type_mean = requestin->list_0[d.seq].grouptype,
   request_xref->cv_xref_rec[fld_cnt].cdf_meaning = requestin->list_0[d.seq].cdf_meaning,
   request_xref->cv_xref_rec[fld_cnt].transaction = cv_trns_add, request_xref->cv_xref_rec[fld_cnt].
   field_type_mean = requestin->list_0[d.seq].fieldtypemean,
   request_xref->cv_xref_rec[fld_cnt].reqdflag = cnvtint(requestin->list_0[d.seq].reqdflag),
   request_xref->cv_xref_rec[fld_cnt].display_fld_ind = cnvtint(requestin->list_0[d.seq].
    displayfldind), request_xref->cv_xref_rec[fld_cnt].collect_start_dt_tm = collect_start,
   request_xref->cv_xref_rec[fld_cnt].collect_stop_dt_tm = collect_stop, request_xref->cv_xref_rec[
   fld_cnt].audit_flag = audit_flag, request_xref->cv_xref_rec[fld_cnt].element_nbr = element_nbr
  DETAIL
   response_cnt = (response_cnt+ 1)
   IF (mod(response_cnt,10)=1)
    stat = alterlist(request_response->response_rec,(response_cnt+ 9))
   ENDIF
   request_response->response_rec[response_cnt].response_internal_name = requestin->list_0[d.seq].
   internalfieldname_res, request_response->response_rec[response_cnt].a1 = requestin->list_0[d.seq].
   a1, request_response->response_rec[response_cnt].a2 = requestin->list_0[d.seq].a2,
   request_response->response_rec[response_cnt].a3 = requestin->list_0[d.seq].a3, request_response->
   response_rec[response_cnt].a4 = requestin->list_0[d.seq].a4, request_response->response_rec[
   response_cnt].a5 = requestin->list_0[d.seq].a5,
   request_response->response_rec[response_cnt].transaction = cv_trns_add, request_response->
   response_rec[response_cnt].xref_index = fld_cnt
  FOOT REPORT
   stat = alterlist(request_xref->cv_xref_rec,fld_cnt), stat = alterlist(request_response->
    response_rec,response_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(request_xref,"cer_temp:cv_xref_rec.dat")
 IF (curqual=0)
  SET failure = "T"
  GO TO exit_script
 ELSE
  CALL cv_log_message("After Reading the requestin into request_xref Record")
  EXECUTE cv_log_struct  WITH replace("REQUEST","REQUEST_XREF")
  CALL cv_log_message("After Reading the requestin into request_response Record")
  CALL cv_log_message(build("Response_cnt: ",response_cnt))
  EXECUTE cv_log_struct  WITH replace("REQUEST","REQUEST_RESPONSE")
 ENDIF
 SET cur_list_size = size(request_xref->cv_xref_rec,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request_xref->cv_xref_rec,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET request_xref->cv_xref_rec[idx].field_type_mean = request_xref->cv_xref_rec[cur_list_size].
   field_type_mean
   SET request_xref->cv_xref_rec[idx].group_type_mean = request_xref->cv_xref_rec[cur_list_size].
   group_type_mean
   SET request_xref->cv_xref_rec[idx].xref_internal_name = request_xref->cv_xref_rec[cur_list_size].
   xref_internal_name
   SET request_xref->cv_xref_rec[idx].event_type_mean = request_xref->cv_xref_rec[cur_list_size].
   event_type_mean
   SET request_xref->cv_xref_rec[idx].sub_event_type_mean = request_xref->cv_xref_rec[cur_list_size].
   sub_event_type_mean
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,request_xref->cv_xref_rec[idx].
    field_type_mean)
    AND cv.code_set=25290
    AND cv.active_ind=1)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].
    field_type_mean)
   WHILE (index != 0)
    request_xref->cv_xref_rec[index].field_type_cd = cv.code_value,index = locateval(num1,(index+ 1),
     cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].field_type_mean)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_xref cx
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cx
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cx.xref_internal_name,request_xref->
    cv_xref_rec[idx].xref_internal_name)
    AND cx.xref_id != 0.0)
  HEAD REPORT
   num1 = 0, xref_chg_cnt = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cx.xref_internal_name,request_xref->cv_xref_rec[num1].
    xref_internal_name)
   IF ((request_xref->cv_xref_rec[index].dataset_id=cx.dataset_id))
    request_xref->cv_xref_rec[index].xref_id = cx.xref_id, request_xref->cv_xref_rec[index].
    transaction = cv_trns_chg, xref_chg_cnt = (xref_chg_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD reply_xref
 RECORD reply_xref(
   1 return_rec[*]
     2 xref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,request_xref->cv_xref_rec[idx].
    group_type_mean)
    AND cv.code_set=22310
    AND cv.active_ind=1)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].
    group_type_mean)
   WHILE (index != 0)
    request_xref->cv_xref_rec[index].group_type_cd = cv.code_value,index = locateval(num1,(index+ 1),
     cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].group_type_mean)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,request_xref->cv_xref_rec[idx].
    event_type_mean)
    AND cv.code_set=22309
    AND cv.active_ind=1)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].
    event_type_mean)
   WHILE (index != 0)
    request_xref->cv_xref_rec[index].event_type_cd = cv.code_value,index = locateval(num1,(index+ 1),
     cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].event_type_mean)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   code_value cv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cv
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.cdf_meaning,request_xref->cv_xref_rec[idx].
    sub_event_type_mean)
    AND cv.code_set=22309
    AND cv.active_ind=1)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].
    sub_event_type_mean)
   WHILE (index != 0)
    request_xref->cv_xref_rec[index].sub_event_type_cd = cv.code_value,index = locateval(num1,(index
     + 1),cur_list_size,cv.cdf_meaning,request_xref->cv_xref_rec[num1].sub_event_type_mean)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(request_xref->cv_xref_rec,cur_list_size)
 IF (xref_chg_cnt < fld_cnt)
  EXECUTE cv_add_fld_xref  WITH replace("REQUEST","REQUEST_XREF"), replace("REPLY","REPLY_XREF")
 ENDIF
 IF (xref_chg_cnt > 0)
  EXECUTE cv_chg_fld_xref  WITH replace("REQUEST","REQUEST_XREF"), replace("REPLY","REPLY_XREF")
 ENDIF
 FOR (idx = 1 TO size(request_response->response_rec,5))
   SET request_response->response_rec[idx].xref_id = reply_xref->return_rec[request_response->
   response_rec[idx].xref_index].xref_id
 ENDFOR
 SET cur_list_size = size(request_response->response_rec,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request_response->response_rec,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET request_response->response_rec[idx].response_internal_name = request_response->response_rec[
   cur_list_size].response_internal_name
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_response cr
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cr
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cr.response_internal_name,request_response->
    response_rec[idx].response_internal_name))
  HEAD REPORT
   num1 = 0, response_chg_cnt = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cr.response_internal_name,request_response->response_rec[
    num1].response_internal_name)
   IF ((request_response->response_rec[index].xref_id=cr.xref_id))
    request_response->response_rec[index].response_id = cr.response_id, request_response->
    response_rec[index].transaction = cv_trns_chg, response_chg_cnt = (response_chg_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(request_response->response_rec,cur_list_size)
 IF (response_chg_cnt < response_cnt)
  EXECUTE cv_add_fld_response  WITH replace("REQUEST","REQUEST_RESPONSE")
 ENDIF
 IF (response_chg_cnt > 0)
  EXECUTE cv_chg_fld_response  WITH replace("REQUEST","REQUEST_RESPONSE")
 ENDIF
 COMMIT
 EXECUTE cv_utl_synch_ds_fieldtype
 EXECUTE cv_updt_response_with_nomen
 COMMIT
 IF (cur_dataset="STS")
  EXECUTE cv_utl_add_sts_header
 ENDIF
#exit_script
 IF (failure="T")
  SET reply->status_data.status = "F"
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
 DECLARE cv_import_dataset_vrsn = vc WITH private, constant("MOD 011 - BM9013 - 07/18/2006")
END GO
