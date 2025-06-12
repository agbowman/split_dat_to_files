CREATE PROGRAM cv_import_dataset_files:dba
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
 SET cv_log_event = "CV_IMPORT_DATASET_FILES"
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD internal
 RECORD internal(
   1 max_field_idx = i4
   1 file[*]
     2 file_id = f8
     2 dataset_id = f8
     2 delimiter = vc
     2 name = vc
     2 file_nbr = i4
     2 extension = vc
     2 format_string = vc
     2 table_name = vc
     2 column_name = vc
     2 transaction = i2
     2 field[*]
       3 xref_field_id = f8
       3 xref_id = f8
       3 dataset_id = f8
       3 file_id = f8
       3 position = i4
       3 length = i4
       3 field_format = vc
       3 start = i4
       3 display_name = vc
       3 transaction = i2
 )
 FREE RECORD request_dsfile
 RECORD request_dsfile(
   1 file[*]
     2 file_id = f8
     2 dataset_id = f8
     2 delimiter = vc
     2 name = vc
     2 file_nbr = i4
     2 extension = vc
     2 format_string = vc
     2 table_name = vc
     2 column_name = vc
     2 transaction = i2
 )
 FREE RECORD request_xv
 RECORD request_xv(
   1 field[*]
     2 xref_field_id = f8
     2 file_id = f8
     2 dataset_id = f8
     2 xref_id = f8
     2 position = i4
     2 length = i4
     2 field_format = vc
     2 start = i4
     2 display_name = vc
     2 transaction = i2
 )
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE file_nbr = i4 WITH protect
 DECLARE dataset_name = vc WITH protect
 DECLARE updt_cnt = i4 WITH protect
 DECLARE ds_chg_cnt = i4 WITH protect
 DECLARE dsfile_num = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE field_idx = i4 WITH protect
 DECLARE field_num = i4 WITH protect
 SELECT INTO "nl:"
  file_number = cnvtint(requestin->list_0[d1.seq].file_nbr), field_position = cnvtint(requestin->
   list_0[d1.seq].position)
  FROM cv_dataset ds,
   cv_xref x,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].dataset_name > " "))
   JOIN (ds
   WHERE (ds.dataset_internal_name=requestin->list_0[d1.seq].dataset_name))
   JOIN (x
   WHERE ((x.dataset_id=ds.dataset_id
    AND (x.xref_internal_name=requestin->list_0[d1.seq].field_internal_name)) OR (x.xref_id=0.0
    AND (requestin->list_0[d1.seq].field_internal_name <= " "))) )
  ORDER BY ds.dataset_internal_name, file_number, field_position
  HEAD REPORT
   file_idx = 0
  HEAD ds.dataset_internal_name
   col 0
  HEAD file_number
   file_idx = (file_idx+ 1), field_idx = 0, stat = alterlist(internal->file,file_idx),
   internal->file[file_idx].dataset_id = ds.dataset_id, internal->file[file_idx].delimiter =
   requestin->list_0[d1.seq].delimiter, internal->file[file_idx].name = requestin->list_0[d1.seq].
   file_name,
   internal->file[file_idx].file_nbr = cnvtint(requestin->list_0[d1.seq].file_nbr), internal->file[
   file_idx].extension = requestin->list_0[d1.seq].file_extension, internal->file[file_idx].
   format_string = requestin->list_0[d1.seq].file_name_format,
   internal->file[file_idx].table_name = requestin->list_0[d1.seq].table_name, internal->file[
   file_idx].column_name = requestin->list_0[d1.seq].column_name, internal->file[file_idx].
   transaction = cv_trns_add
  HEAD field_position
   field_idx = (field_idx+ 1), stat = alterlist(internal->file[file_idx].field,field_idx), internal->
   file[file_idx].field[field_idx].file_id = internal->file[file_idx].file_id,
   internal->file[file_idx].field[field_idx].xref_id = x.xref_id, internal->file[file_idx].field[
   field_idx].position = cnvtint(requestin->list_0[d1.seq].position), internal->file[file_idx].field[
   field_idx].length = cnvtint(requestin->list_0[d1.seq].length),
   internal->file[file_idx].field[field_idx].start = cnvtint(requestin->list_0[d1.seq].start),
   internal->file[file_idx].field[field_idx].dataset_id = ds.dataset_id, internal->file[file_idx].
   field[field_idx].field_format = requestin->list_0[d1.seq].field_format,
   internal->file[file_idx].field[field_idx].display_name = requestin->list_0[d1.seq].display_name,
   internal->file[file_idx].field[field_idx].transaction = cv_trns_add
  DETAIL
   dataset_name = ds.dataset_internal_name
  FOOT  file_number
   IF ((field_idx > internal->max_field_idx))
    internal->max_field_idx = field_idx
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("curqual zero in the dummy read")
  SET reply->status_data.status = "F"
  SET failure = "T"
  GO TO exit_script
 ENDIF
 CALL echorecord(internal,"cer_temp:cv_ds_int.dat")
 CALL echorecord(requestin,"cer_Temp:cv_DSFILErequestin.dat")
 SET ds_chg_cnt = 0
 SELECT INTO "nl:"
  FROM cv_dataset_file t,
   (dummyt d1  WITH seq = value(size(internal->file,5)))
  PLAN (d1)
   JOIN (t
   WHERE (t.name=internal->file[d1.seq].name)
    AND (t.extension=internal->file[d1.seq].extension)
    AND (t.dataset_id=internal->file[d1.seq].dataset_id))
  HEAD REPORT
   ds_chg_cnt = 0
  DETAIL
   ds_chg_cnt = (ds_chg_cnt+ 1), internal->file[d1.seq].file_id = t.file_id, internal->file[d1.seq].
   transaction = cv_trns_chg
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cv_xref_field t,
   (dummyt d1  WITH seq = value(size(internal->file,5))),
   (dummyt d2  WITH seq = value(internal->max_field_idx))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal->file[d1.seq].field,5))
   JOIN (t
   WHERE (t.display_name=internal->file[d1.seq].field[d2.seq].display_name)
    AND (t.file_id=internal->file[d1.seq].file_id)
    AND (t.dataset_id=internal->file[d1.seq].field[d2.seq].dataset_id))
  DETAIL
   ds_chg_cnt = (ds_chg_cnt+ 1), internal->file[d1.seq].field[d2.seq].xref_field_id = t.xref_field_id,
   internal->file[d1.seq].field[d2.seq].file_id = internal->file[d1.seq].file_id,
   internal->file[d1.seq].field[d2.seq].transaction = cv_trns_chg
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(internal->file,5))
  IF ((internal->file[x].transaction=cv_trns_add))
   SELECT INTO "nl:"
    nextseqnum = seq(card_vas_seq,nextval)
    FROM dual
    DETAIL
     internal->file[x].file_id = nextseqnum
    WITH format
   ;end select
  ENDIF
  FOR (y = 1 TO size(internal->file[x].field,5))
    IF ((internal->file[x].field[y].transaction=cv_trns_add))
     SELECT INTO "nl:"
      nextseqnum = seq(card_vas_seq,nextval)
      FROM dual
      DETAIL
       internal->file[x].field[y].xref_field_id = nextseqnum
      WITH format
     ;end select
    ENDIF
  ENDFOR
 ENDFOR
 CALL cv_log_message(build(size(internal->file,5),":Number of files to be inserted"))
 FOR (ifileidx = 1 TO size(internal->file,5))
   CALL cv_log_message(build("File:",ifileidx," Fields:",size(internal->file[ifileidx].field,5)))
 ENDFOR
 CALL echorecord(internal,"cer_temp:cv_dsfile_intal.dat")
 INSERT  FROM cv_dataset_file t,
   (dummyt d1  WITH seq = value(size(internal->file,5)))
  SET t.file_id = internal->file[d1.seq].file_id, t.delimiter = internal->file[d1.seq].delimiter, t
   .name = internal->file[d1.seq].name,
   t.file_nbr = internal->file[d1.seq].file_nbr, t.extension = internal->file[d1.seq].extension, t
   .format_string = internal->file[d1.seq].format_string,
   t.table_name = internal->file[d1.seq].table_name, t.column_name = internal->file[d1.seq].
   column_name, t.dataset_id = internal->file[d1.seq].dataset_id,
   t.active_ind = 1, t.active_status_cd = reqdata->active_status_cd, t.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   t.active_status_prsnl_id = reqinfo->updt_id, t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
    ), t.updt_app = reqinfo->updt_app,
   t.updt_req = reqinfo->updt_req, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0,
   t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d1
   WHERE (internal->file[d1.seq].transaction=cv_trns_add))
   JOIN (t)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("No records are inserted into table cv_dataset_file")
 ELSE
  CALL cv_log_message("records are inserted into table cv_xref_field")
  COMMIT
 ENDIF
 INSERT  FROM cv_xref_field t,
   (dummyt d1  WITH seq = value(size(internal->file,5))),
   (dummyt d2  WITH seq = value(internal->max_field_idx))
  SET t.xref_field_id = internal->file[d1.seq].field[d2.seq].xref_field_id, t.file_id = internal->
   file[d1.seq].file_id, t.position = internal->file[d1.seq].field[d2.seq].position,
   t.length = internal->file[d1.seq].field[d2.seq].length, t.format = internal->file[d1.seq].field[d2
   .seq].field_format, t.start_pos = internal->file[d1.seq].field[d2.seq].start,
   t.xref_id = internal->file[d1.seq].field[d2.seq].xref_id, t.dataset_id = internal->file[d1.seq].
   dataset_id, t.display_name = substring(1,40,internal->file[d1.seq].field[d2.seq].display_name),
   t.active_ind = 1, t.active_status_cd = reqdata->active_status_cd, t.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   t.active_status_prsnl_id = reqinfo->updt_id, t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
    ), t.updt_app = reqinfo->updt_app,
   t.updt_req = reqinfo->updt_req, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0,
   t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal->file[d1.seq].field,5)
    AND (internal->file[d1.seq].field[d2.seq].transaction=cv_trns_add))
   JOIN (t)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL cv_log_message("No records are inserted into table cv_xref_field")
 ELSE
  CALL cv_log_message("records are inserted into table cv_xref_field")
  COMMIT
 ENDIF
 SET dsfile_num = size(internal->file,5)
 SET stat = alterlist(request_dsfile->file,dsfile_num)
 SET field_idx = 0
 FOR (x = 1 TO dsfile_num)
   SET request_dsfile->file[x].file_id = internal->file[x].file_id
   SET request_dsfile->file[x].dataset_id = internal->file[x].dataset_id
   SET request_dsfile->file[x].delimiter = internal->file[x].delimiter
   SET request_dsfile->file[x].name = internal->file[x].name
   SET request_dsfile->file[x].file_nbr = internal->file[x].file_nbr
   SET request_dsfile->file[x].extension = internal->file[x].extension
   SET request_dsfile->file[x].format_string = internal->file[x].format_string
   SET request_dsfile->file[x].table_name = internal->file[x].table_name
   SET request_dsfile->file[x].column_name = internal->file[x].column_name
   SET request_dsfile->file[x].transaction = internal->file[x].transaction
   SET field_num = size(internal->file[x].field,5)
   FOR (y = 1 TO field_num)
     SET field_idx = (field_idx+ 1)
     SET stat = alterlist(request_xv->field,field_idx)
     SET request_xv->field[field_idx].xref_field_id = internal->file[x].field[y].xref_field_id
     SET request_xv->field[field_idx].file_id = internal->file[x].field[y].file_id
     SET request_xv->field[field_idx].dataset_id = internal->file[x].field[y].dataset_id
     SET request_xv->field[field_idx].xref_id = internal->file[x].field[y].xref_id
     SET request_xv->field[field_idx].position = internal->file[x].field[y].position
     SET request_xv->field[field_idx].length = internal->file[x].field[y].length
     SET request_xv->field[field_idx].field_format = internal->file[x].field[y].field_format
     SET request_xv->field[field_idx].start = internal->file[x].field[y].start
     SET request_xv->field[field_idx].display_name = internal->file[x].field[y].display_name
     SET request_xv->field[field_idx].transaction = internal->file[x].field[y].transaction
   ENDFOR
 ENDFOR
 CALL echorecord(request_dsfile,"cer_Temp:cv_request_dsfile.dat")
 CALL echorecord(request_xv,"cer_Temp:cv_request_xv.dat")
 EXECUTE cv_chg_fld_dsfiles  WITH replace(request,request_dsfile)
 EXECUTE cv_chg_fld_xreffld  WITH replace(request,request_xv)
#exit_script
 IF (failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  IF (dataset_name="ACC02"
   AND updt_cnt=0)
   EXECUTE cv_utl_add_acc_header
   SET updt_cnt = (updt_cnt+ 1)
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
 DECLARE cv_import_dataset_files_vrsn = vc WITH private, constant("006 BM9013 05/23/2007")
END GO
