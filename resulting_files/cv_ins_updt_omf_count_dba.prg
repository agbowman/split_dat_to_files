CREATE PROGRAM cv_ins_updt_omf_count:dba
 RECORD cnt_rec(
   1 cnt_list[*]
     2 count_id = i4
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 count = i4
 )
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
 SET failure = "F"
 SET cnt = 0
 SET alpha_cd = 0.0
 SET number_cd = 0.0
 SET date_cd = 0.0
 SET string_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=25290
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ALPHA":
     alpha_cd = cv.code_value
    OF "NUMERIC":
     number_cd = cv.code_value
    OF "DATE":
     date_cd = cv.code_value
    OF "STRING":
     string_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cx.event_cd, cer.event_id, cr.nomenclature_id,
  cx.xref_id, cr.response_internal_name, cc.count_id,
  ccr.logical_symbol, ccr.result_val, cr.field_type
  FROM cv_xref cx,
   cv_response cr,
   ce_coded_result cer,
   cv_count cc,
   cv_count_response ccr,
   (dummyt d  WITH seq = value(size(register->rec,5)))
  PLAN (d)
   JOIN (cx
   WHERE (cx.event_cd=register->rec[d.seq].event_cd))
   JOIN (cer
   WHERE (cer.event_id=register->rec[d.seq].event_id))
   JOIN (cr
   WHERE cr.xref_id=cx.xref_id
    AND ((cx.field_type_cd=alpha_cd
    AND cr.nomenclature_id=cer.nomenclature_id
    AND cr.nomenclature_id > 0) OR (cx.field_type_cd=number_cd)) )
   JOIN (ccr
   WHERE cr.response_internal_name=ccr.response_internal_name
    AND ((cx.field_type_cd=number_cd
    AND ((ccr.logical_symbol=">"
    AND (register->rec[d.seq].result_val > ccr.result_val)) OR (ccr.logical_symbol="<"
    AND (register->rec[d.seq].result_val < ccr.result_val))) ) OR (cx.field_type_cd=alpha_cd
    AND ccr.logical_symbol=" ")) )
   JOIN (cc
   WHERE cc.count_id=ccr.count_id)
  ORDER BY cc.count_id
  HEAD cc.count_id
   cnt = (cnt+ 1), stat = alterlist(cnt_rec->cnt_list,cnt)
  DETAIL
   cnt_rec->cnt_list[cnt].count = (cnt_rec->cnt_list[cnt].count+ 1), cnt_rec->cnt_list[cnt].count_id
    = cc.count_id, cnt_rec->cnt_list[cnt].parent_entity_name = cc.parent_entity_name,
   cnt_rec->cnt_list[cnt].parent_entity_id = register->cv_case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("No match found, failed in selecting cv_ins_updt_omf_count")
  GO TO exit_script
 ENDIF
 SET t_count = 0
 SET t_count = size(cnt_rec->cnt_list,5)
 DELETE  FROM cv_count_data ccd,
   (dummyt d  WITH seq = value(t_count))
  SET ccd.seq = 1
  PLAN (d)
   JOIN (ccd
   WHERE (ccd.count_id=cnt_rec->cnt_list[d.seq].count_id)
    AND (ccd.parent_entity_id=cnt_rec->cnt_list[d.seq].parent_entity_id)
    AND trim(ccd.parent_entity_name)=trim(cnt_rec->cnt_list[d.seq].parent_entity_name))
  WITH nocounter
 ;end delete
 INSERT  FROM cv_count_data ccd,
   (dummyt d  WITH seq = value(t_count))
  SET ccd.count_data_id = cnvtint(seq(card_vas_seq,nextval)), ccd.count_id = cnt_rec->cnt_list[d.seq]
   .count_id, ccd.parent_entity_id = cnt_rec->cnt_list[d.seq].parent_entity_id,
   ccd.parent_entity_name = cnt_rec->cnt_list[d.seq].parent_entity_name, ccd.count = cnt_rec->
   cnt_list[d.seq].count, ccd.active_ind = 1,
   ccd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccd.active_status_cd = reqdata->
   active_status_cd, ccd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ccd.end_effective_dt_tm = cnvtdatetime(null_date), ccd.data_status_cd = reqdata->data_status_cd,
   ccd.data_status_prsnl_id = reqinfo->updt_id,
   ccd.active_status_prsnl_id = reqinfo->updt_id, ccd.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), ccd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ccd.updt_task = reqinfo->updt_task, ccd.updt_applctx = reqinfo->updt_applctx, ccd.updt_cnt = 0,
   ccd.updt_id = reqinfo->updt_id
  PLAN (d)
   JOIN (ccd)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failed in insert cv_count_data table")
 ENDIF
#exit_script
 IF (failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
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
END GO
