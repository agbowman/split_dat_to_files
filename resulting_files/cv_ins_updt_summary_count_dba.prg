CREATE PROGRAM cv_ins_updt_summary_count:dba
 IF ((validate(count_data,- (1))=- (1)))
  RECORD count_data(
    1 cv_case_id = f8
    1 rec[*]
      2 xref_id = f8
      2 event_id = f8
      2 event_cd = f8
      2 result_val = vc
      2 field_type_cd = f8
  )
 ENDIF
 IF ((validate(sel_rec,- (1))=- (1)))
  RECORD sel_rec(
    1 sel_proc_cnt = i4
    1 sel_les_cnt = i4
    1 sel_proc[*]
      2 procedure_id = f8
    1 sel_les[*]
      2 lesion_id = f8
  )
 ENDIF
 IF ((validate(cnt_rec,- (1))=- (1)))
  RECORD cnt_rec(
    1 cnt_list[*]
      2 count_id = i4
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 count = i4
  )
 ENDIF
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
 DECLARE idx = i4 WITH protect
 DECLARE cnt_failed = c1 WITH protect, noconstant("F")
 DECLARE cnt = i4 WITH protect
 DECLARE sel_cnt = i4 WITH protect
 DECLARE alpha_cd = f8 WITH protect
 DECLARE number_cd = f8 WITH protect
 DECLARE date_cd = f8 WITH protect
 DECLARE string_cd = f8 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE cur_list_size = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE nstart = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE sel_les_cnt = i4 WITH protect
 IF ((cv_omf_rec->case_id > 0.0))
  SET count_data->cv_case_id = cv_omf_rec->case_id
 ELSE
  GO TO exit_script
 ENDIF
 SET sel_cnt = 0
 SELECT INTO "nl:"
  FROM cv_case_abstr_data ccad
  WHERE (ccad.cv_case_id=count_data->cv_case_id)
  DETAIL
   sel_cnt = (sel_cnt+ 1), stat = alterlist(count_data->rec,sel_cnt), count_data->rec[sel_cnt].
   event_id = ccad.event_id,
   count_data->rec[sel_cnt].event_cd = ccad.event_cd, count_data->rec[sel_cnt].result_val = ccad
   .result_val
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No case abstract data associates with this case!")
 ENDIF
 SELECT INTO "nl:"
  proc_id = cp.procedure_id
  FROM cv_procedure cp
  WHERE (cp.cv_case_id=count_data->cv_case_id)
  HEAD REPORT
   sel_pro_cnt = 0
  DETAIL
   sel_pro_cnt = (sel_pro_cnt+ 1), stat = alterlist(sel_rec->sel_proc,sel_pro_cnt), sel_rec->
   sel_proc[sel_pro_cnt].procedure_id = proc_id,
   sel_rec->sel_proc_cnt = sel_pro_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No procedure associates with this case!")
 ELSE
  SET cur_list_size = sel_rec->sel_proc_cnt
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(sel_rec->sel_proc,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET sel_rec->sel_proc[idx].procedure_id = sel_rec->sel_proc[cur_list_size].procedure_id
  ENDFOR
  SELECT
   IF ((sel_rec->sel_proc_cnt=1))
    FROM cv_proc_abstr_data cpad
    WHERE (cpad.procedure_id=sel_rec->sel_proc[1].procedure_id)
   ELSE
   ENDIF
   INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    cv_proc_abstr_data cpad
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cpad
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cpad.procedure_id,sel_rec->sel_proc[idx].
     procedure_id))
   DETAIL
    sel_cnt = (sel_cnt+ 1), stat = alterlist(count_data->rec,sel_cnt), count_data->rec[sel_cnt].
    event_id = cpad.event_id,
    count_data->rec[sel_cnt].event_cd = cpad.event_cd, count_data->rec[sel_cnt].result_val = cpad
    .result_val
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No procedure abstract data associates with this case!")
  ENDIF
  SET nstart = 1
  SET sel_les_cnt = 0
  SELECT
   IF ((sel_rec->sel_proc_cnt=1))
    FROM cv_lesion cl
    WHERE (cl.procedure_id=sel_rec->sel_proc[1].procedure_id)
     AND cl.lesion_id != 0.0
   ELSE
   ENDIF
   INTO "nl:"
   cl.lesion_id
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    cv_lesion cl
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cl
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cl.procedure_id,sel_rec->sel_proc[idx].
     procedure_id)
     AND cl.lesion_id != 0.0)
   DETAIL
    sel_les_cnt = (sel_les_cnt+ 1), stat = alterlist(sel_rec->sel_les,sel_les_cnt), sel_rec->sel_les[
    sel_les_cnt].lesion_id = cl.lesion_id,
    sel_rec->sel_les_cnt = sel_les_cnt
   WITH nocounter
  ;end select
  SET stat = alterlist(sel_rec->sel_proc,cur_list_size)
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("No lesion associates with this case or procedure!")
  ELSE
   SET cur_list_size = sel_rec->sel_les_cnt
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(sel_rec->sel_les,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET sel_rec->sel_les[idx].lesion_id = sel_rec->sel_les[cur_list_size].lesion_id
   ENDFOR
   SELECT
    IF ((sel_rec->sel_les_cnt=1))
     FROM cv_les_abstr_data clad
     WHERE (clad.lesion_id=sel_rec->sel_les[1].lesion_id)
    ELSE
    ENDIF
    INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     cv_les_abstr_data clad
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (clad
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),clad.lesion_id,sel_rec->sel_les[idx].
      lesion_id))
    DETAIL
     sel_cnt = (sel_cnt+ 1), stat = alterlist(count_data->rec,sel_cnt), count_data->rec[sel_cnt].
     event_id = clad.event_id,
     count_data->rec[sel_cnt].event_cd = clad.event_cd, count_data->rec[sel_cnt].result_val = clad
     .result_val
    WITH nocounter
   ;end select
   SET stat = alterlist(sel_rec->sel_les,cur_list_size)
   IF (curqual=0)
    SET cv_log_level = cv_log_audit
    CALL cv_log_current_default(0)
    CALL cv_log_message("No lesion abstract data associates with this case!")
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ref.xref_id
  FROM cv_xref ref,
   (dummyt t  WITH seq = value(size(count_data->rec,5)))
  PLAN (t
   WHERE (count_data->rec[t.seq].event_cd > 0.0))
   JOIN (ref
   WHERE (ref.event_cd=count_data->rec[t.seq].event_cd))
  DETAIL
   count_data->rec[t.seq].xref_id = ref.xref_id, count_data->rec[t.seq].field_type_cd = ref
   .field_type_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No xref_id associates with this evnet_cd in cv_xref table!")
 ENDIF
 DECLARE iret = i4 WITH protect
 DECLARE cvct = i4 WITH protect, constant(1)
 DECLARE codeset = i4 WITH protect, constant(25290)
 DECLARE meaning_alpha = c12 WITH protect, noconstant("ALPHA")
 DECLARE meaning_number = c12 WITH protect, noconstant("NUMERIC")
 DECLARE meaning_date = c12 WITH protect, noconstant("DATE")
 DECLARE meaning_string = c12 WITH protect, noconstant("STRING")
 SET iret = uar_get_meaning_by_codeset(codeset,meaning_alpha,cvct,alpha_cd)
 SET iret = uar_get_meaning_by_codeset(codeset,meaning_number,cvct,number_cd)
 SET iret = uar_get_meaning_by_codeset(codeset,meaning_date,cvct,date_cd)
 SET iret = uar_get_meaning_by_codeset(codeset,meaning_string,cvct,string_cd)
 SELECT INTO "nl:"
  cer.event_id, cr.nomenclature_id, cr.response_internal_name,
  cc.count_id, ccr.logical_symbol, ccr.result_val,
  cr.field_type
  FROM cv_response cr,
   ce_coded_result cer,
   cv_count cc,
   cv_count_response ccr,
   (dummyt d  WITH seq = value(size(count_data->rec,5)))
  PLAN (d)
   JOIN (cer
   WHERE (cer.event_id=count_data->rec[d.seq].event_id))
   JOIN (cr
   WHERE (cr.xref_id=count_data->rec[d.seq].xref_id)
    AND (((count_data->rec[d.seq].field_type_cd=alpha_cd)
    AND cr.nomenclature_id=cer.nomenclature_id
    AND cr.nomenclature_id > 0.0) OR ((count_data->rec[d.seq].field_type_cd=number_cd))) )
   JOIN (ccr
   WHERE ccr.response_internal_name=cr.response_internal_name
    AND (((count_data->rec[d.seq].field_type_cd=number_cd)
    AND ((ccr.logical_symbol=">"
    AND (ccr.result_val < count_data->rec[d.seq].result_val)) OR (ccr.logical_symbol="<"
    AND (ccr.result_val > count_data->rec[d.seq].result_val))) ) OR ((count_data->rec[d.seq].
   field_type_cd=alpha_cd)
    AND ccr.logical_symbol <= " ")) )
   JOIN (cc
   WHERE cc.count_id=ccr.count_id)
  ORDER BY cc.count_id
  HEAD cc.count_id
   cnt = (cnt+ 1), stat = alterlist(cnt_rec->cnt_list,cnt)
  DETAIL
   cnt_rec->cnt_list[cnt].count = (cnt_rec->cnt_list[cnt].count+ 1), cnt_rec->cnt_list[cnt].count_id
    = cc.count_id, cnt_rec->cnt_list[cnt].parent_entity_name = cc.parent_entity_name,
   cnt_rec->cnt_list[cnt].parent_entity_id = count_data->cv_case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cnt_failed = "T"
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in getting count value, program continue!")
  GO TO exit_script
 ENDIF
 DECLARE t_count = i4 WITH protect, constant(size(cnt_rec->cnt_list,5))
 IF (t_count < 1)
  SET cnt_failed = "T"
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in delete and insert cv_count_data table")
  GO TO exit_script
 ENDIF
 DELETE  FROM cv_count_data ccd,
   (dummyt d  WITH seq = value(t_count))
  SET ccd.seq = 1
  PLAN (d)
   JOIN (ccd
   WHERE (ccd.count_id=cnt_rec->cnt_list[d.seq].count_id)
    AND (ccd.parent_entity_id=cnt_rec->cnt_list[d.seq].parent_entity_id)
    AND ccd.parent_entity_name=trim(cnt_rec->cnt_list[d.seq].parent_entity_name))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in deleting cv_count_data table")
 ENDIF
 INSERT  FROM cv_count_data ccd,
   (dummyt d  WITH seq = value(t_count))
  SET ccd.count_data_id = seq(card_vas_seq,nextval), ccd.count_id = cnt_rec->cnt_list[d.seq].count_id,
   ccd.parent_entity_id = cnt_rec->cnt_list[d.seq].parent_entity_id,
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
  SET cnt_failed = "T"
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in insert cv_count_data table")
 ENDIF
#exit_script
 IF (cnt_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
  CALL cv_log_message(build("Committed at: ",curprog))
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
 DECLARE cv_ins_updt_summary_count_vrsn = vc WITH private, constant("MOD 003 03/23/06 BM9013")
END GO
