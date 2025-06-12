CREATE PROGRAM ctp_mcm_stnd_subs:dba
 IF (validate(ctp_mcm_data)=0)
  RECORD ctp_mcm_data(
    1 begin_date = dq8
    1 end_date = dq8
    1 domain = c255
    1 program_execute_dt_tm = dq8
    1 cur_logical_domain_id = f8
    1 debug_ind = i2
    1 err_ind = i2
  ) WITH protect, persistscript
 ENDIF
 IF (validate(colmap)=0)
  RECORD colmap(
    1 cnt = i4
    1 data[*]
      2 field = vc
      2 col = i4
  ) WITH protect, persistscript
 ELSE
  SET stat = initrec(colmap)
 ENDIF
 IF (validate(msgdef)=0)
  RECORD msgdef(
    1 cnt = i4
    1 list[*]
      2 enum = i4
      2 msg = vc
      2 col_cnt = i4
      2 col[*]
        3 val = i4
  ) WITH protect, persistscript
 ELSE
  SET stat = initrec(msgdef)
 ENDIF
 IF (validate(ctp_mcm_log->cnt)=0)
  RECORD ctp_mcm_log(
    1 cnt = i4
    1 results[*]
      2 full_msg = vc
      2 msg_cnt = i4
      2 msg[*]
        3 txt = vc
      2 entity_id = f8
      2 entity_name = vc
  ) WITH protect, persistscript
 ELSE
  SET stat = initrec(ctp_mcm_log)
 ENDIF
 IF ( NOT (validate(import::log->cnt)))
  RECORD IMPORT::log(
    1 cnt = i4
    1 list[*]
      2 full_msg = vc
      2 msg_cnt = i4
      2 msg[*]
        3 txt = vc
      2 full_cell = vc
      2 cell_cnt = i4
      2 cell[*]
        3 cellref = vc
      2 success_ind = i2
      2 skip_ind = i2
    1 layout_error = i2
  ) WITH protect, persistscript
 ELSE
  SET stat = initrec(IMPORT::log)
 ENDIF
 IF ( NOT (validate(grid->row_cnt)))
  RECORD grid(
    1 row_cnt = i4
    1 row[*]
      2 col_cnt = i4
      2 col[*]
        3 txt = vc
  ) WITH persistscript, protect
 ELSE
  SET stat = initrec(grid)
 ENDIF
 IF ( NOT (validate(RUN::import)))
  RECORD RUN::import(
    1 run_dt_tm = dq8
    1 file_name = vc
    1 script_name = vc
    1 log_file = vc
    1 logical = vc
    1 batch_size = i4
    1 rows_processed = i4
    1 rows_with_errors = i4
    1 error = i2
    1 run_upload = i2
  ) WITH persistscript, protect
 ENDIF
 IF ( NOT (validate(RUN::tracking)))
  RECORD RUN::tracking(
    1 automationid = i4
    1 last_ccl_revisor = vc
    1 last_ccl_revision_dt_tm = dq8
    1 sequence_id = f8
    1 client_mnemonic = vc
    1 username = vc
    1 ld_mnemonic = vc
    1 logical_domain_id = f8
    1 production_ind = i2
    1 associateid = vc
    1 last_macro_revisor = vc
    1 last_macro_revision_dt_tm = dq8
    1 note = vc
    1 run_script = vc
  ) WITH persistscript, protect
 ENDIF
 IF ( NOT (validate(tracking_reply->status_data)))
  RECORD tracking_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript, protect
 ENDIF
 IF (validate(CTPDYN::output))
  SET ctpdyn::output->status = "F"
 ENDIF
 DECLARE ctp_mcm_stnd_subs_mod = i4 WITH constant(3), protect, persistscript
 DECLARE ver_err_msg = vc WITH noconstant(" "), protect
 DECLARE ctp_mcm_with_expand_val = i4 WITH constant(2), protect, persistscript
 DECLARE ctp_mcm_separator = c1 WITH constant(char(32)), protect, persistscript
 DECLARE ctp_mcm_pip_delim = c1 WITH constant(char(124)), protect, persistscript
 DECLARE tab = c1 WITH constant(char(9)), protect, persistscript
 DECLARE csv_row = i4 WITH protect, noconstant(0), persistscript
 DECLARE enum_cnt = i4 WITH protect, noconstant(0), persistscript
 DECLARE piece_cnt = i4 WITH protect, noconstant(1), persistscript
 DECLARE errmapparse = vc WITH protect, noconstant(" "), persistscript
 DECLARE IMP::not_found = vc WITH protect, constant("NOT_FOUND"), persistscript
 DECLARE RUN::upload_noerr_mode = i1 WITH protect, constant(2), persistscript
 DECLARE RUN::upload_err_mode = i1 WITH protect, constant(3), persistscript
 DECLARE RUN::chk_in_import = i1 WITH protect, constant(- (1)), persistscript
 IF ( NOT (validate(RUN::debug_on)))
  DECLARE RUN::debug_on = i2 WITH protect, noconstant(0), persistscript
 ENDIF
 IF ( NOT (validate(error_status)))
  DECLARE error_status = i2 WITH protect, noconstant(0), persistscript
 ENDIF
 DECLARE IMPORT::cnt = i4 WITH protect, noconstant(0), persistscript
 DECLARE IMPORT::i = i4 WITH protect, noconstant(0), persistscript
 DECLARE IMPORT::pos = i4 WITH protect, noconstant(0), persistscript
 DECLARE IMPORT::debug_on = i2 WITH protect, noconstant(0), persistscript
 DECLARE inserttracking(null) = i2 WITH copy, protect
 DECLARE updatetracking(null) = i2 WITH copy, protect
 DECLARE ctp_mcm_runtrackingdata(null) = null WITH protect, copy
 IF ( NOT (validate(ctp_run_prg_print_status)))
  EXECUTE NULL ;noop
 ENDIF
 DECLARE ctp_setupreadme(null) = i2 WITH copy, protect
 DECLARE ctp_mcm_check_eol_field(null) = i2 WITH protect, copy
 DECLARE ctp_mcm_purge_old_logs(null) = null WITH protect, copy
 SUBROUTINE ctp_mcm_purge_old_logs(null)
   DECLARE dclcom = vc WITH noconstant("")
   DECLARE dclstatus = i2 WITH noconstant(1)
   CALL echo(concat('>>> Purging all files like "',trim(cnvtlower(curprog),3),'*log"'))
   SET dclcom = concat("rm ",trim(logical("ccluserdir"),3),"/",trim(cnvtlower(curprog),3),"*log",
    " -f")
   CALL dcl(dclcom,textlen(dclcom),dclstatus)
 END ;Subroutine
 SUBROUTINE (ctp_mcm_log_error(log_row_num=i4,log_err_message_text=vc) =null WITH protect, copy)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   IF (locateval(expand_cnt,1,size(ctp_mcm_log->results[log_row_num].msg,5),log_err_message_text,
    ctp_mcm_log->results[log_row_num].msg[expand_cnt].txt)=0)
    SET ctp_mcm_log->cnt += 1
    SET i = size(ctp_mcm_log->results[log_row_num].msg,5)
    SET i += 1
    SET stat = alterlist(ctp_mcm_log->results[log_row_num].msg,i)
    SET ctp_mcm_log->results[log_row_num].msg[i].txt = trim(log_err_message_text,3)
    SET ctp_mcm_log->results[log_row_num].msg_cnt = i
    SET ctp_mcm_log->cnt += 1
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkcsvcolumnforblanks(check_index=i4,requestin_field=vc) =null WITH protect,
  copy)
   DECLARE errmessage = vc WITH constant(concat(trim(requestin_field,3)," cannot be blank")), protect
   DECLARE requestin_field_full = vc WITH noconstant(concat("requestin->list_0[check_index].",trim(
      requestin_field,3))), protect
   DECLARE requestin_field_value = vc WITH noconstant(" ")
   DECLARE requestin_field_size = i4 WITH noconstant(0), protect
   SET requestin_field_value = parser(requestin_field_full)
   SET requestin_field_size = size(trim(requestin_field_value,3))
   IF (requestin_field_size=0)
    CALL ctp_mcm_log_error(check_index,errmessage)
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkcsvcolumnforinvalidcodevaluebyuar(requestin_field=vc,check_code_field=vc,
  check_code_set=i4) =null WITH protect, copy)
   DECLARE check_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(requestin_field,3),
     " does not exist in cache for codeset ",trim(cnvtstring(check_code_set),3))), protect
   DECLARE requestin_field_full = vc WITH noconstant(concat("requestin->list_0[check_index].",trim(
      requestin_field,3))), protect
   DECLARE requestin_field_value = vc WITH noconstant(" "), protect
   DECLARE requestin_domain_code_value = f8 WITH noconstant(0.0), protect
   DECLARE requestin_field_size = i4 WITH noconstant(0), protect
   FOR (check_index = 1 TO size(requestin->list_0,5))
     SET requestin_field_value = parser(requestin_field_full)
     SET requestin_field_size = size(trim(requestin_field_value,3))
     IF (requestin_field_size > 0)
      SET requestin_domain_code_value = uar_get_code_by(trim(check_code_field,3),check_code_set,trim(
        requestin_field_value,3))
      IF (requestin_domain_code_value <= 0)
       CALL ctp_mcm_log_error(check_index,errmessage)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkbetamustexistifalphaexists(alphacol=vc,betacol=vc) =null WITH protect, copy
  )
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," must also have ",trim(betacol,3),
     " defined")), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(alphacol,3))), protect
   DECLARE requestin_field_full_beta = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(betacol,3))), protect
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
     IF (size(trim(parser(requestin_field_full_alpha),3)) > 0
      AND size(trim(parser(requestin_field_full_beta),3))=0)
      CALL ctp_mcm_log_error(requestin_index,errmessage)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkalphaisnumeric(checkindex=i4,alphacol=vc) =null WITH protect, copy)
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," is not numeric")), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat("requestin->list_0[checkindex].",
     trim(alphacol,3))), protect
   IF (size(trim(parser(requestin_field_full_alpha),3)) > 0)
    IF (isnumeric(parser(requestin_field_full_alpha))=0)
     CALL ctp_mcm_log_error(checkindex,errmessage)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkalphacolduplicates(alphacol=vc) =null WITH protect, copy)
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," is a duplicate")), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat("requestin->list_0[d1.seq].",trim(
      alphacol,3))), protect
   DECLARE requestin_locateval_full_alpha = vc WITH noconstant(concat("requestin->list_0[index].",
     trim(alphacol,3))), protect
   SELECT INTO "nl:"
    parsedcol = substring(1,1000,parser(requestin_field_full_alpha))
    FROM (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
    PLAN (d1
     WHERE size(trim(parser(requestin_field_full_alpha),3)) > 0)
    ORDER BY parsedcol
    HEAD parsedcol
     cnt = 0
    DETAIL
     cnt += 1
    FOOT  parsedcol
     index = 0
     IF (cnt > 1)
      pos = locateval(index,1,size(requestin->list_0,5),trim(parsedcol,3),trim(parser(
         requestin_locateval_full_alpha),3))
      WHILE (pos > 0)
       CALL ctp_mcm_log_error(pos,errmessage),pos = locateval(index,(pos+ 1),size(requestin->list_0,5
         ),trim(parsedcol,3),trim(parser(requestin_locateval_full_alpha),3))
      ENDWHILE
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkalphacollength(check_index=i4,alphacol=vc,alphasize=i4) =null WITH protect,
  copy)
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," is not less than or equal to ",
     cnvtstring(alphasize))), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat("requestin->list_0[check_index].",
     trim(alphacol,3))), protect
   IF (size(trim(parser(requestin_field_full_alpha),3)) > alphasize)
    CALL ctp_mcm_log_error(check_index,errmessage)
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkcsvcolinvalidcodevaluebycodeset(check_index=i4,alphacol=vc,check_code_set=
  i4) =null WITH protect, copy)
   DECLARE found_code_value_set = i4 WITH noconstant(0.0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," Code Value not found in cache")),
   protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat("requestin->list_0[check_index].",
     trim(alphacol,3))), protect
   SET found_code_value_set = uar_get_code_set(cnvtreal(parser(requestin_field_full_alpha)))
   IF (cnvtreal(parser(requestin_field_full_alpha)) > 0)
    IF (found_code_value_set != check_code_set)
     CALL ctp_mcm_log_error(check_index,errmessage)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE ctp_mcm_check_eol_field(null)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE err_found = i2 WITH noconstant(0), protect
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
     IF ((requestin->list_0[requestin_index].eol != "EOL"))
      SET err_found = 1
      CALL ctp_mcm_log_error(requestin_index,"End of Line Not Found! Import Prevented!")
     ENDIF
   ENDFOR
   RETURN(err_found)
 END ;Subroutine
 DECLARE ctp_mcm_loadlogicaldomainid(null) = null WITH protect, copy
 SUBROUTINE ctp_mcm_loadlogicaldomainid(null)
   SELECT INTO "nl:"
    FROM prsnl pl
    WHERE (pl.person_id=reqinfo->updt_id)
    DETAIL
     ctp_mcm_data->cur_logical_domain_id = pl.logical_domain_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (ctp_mcm_validaterequestinfield(requestin_field=vc) =null WITH protect, copy)
   DECLARE err_found = i2 WITH noconstant(0), protect
   DECLARE requestin_index = i4 WITH noconstant(1), protect
   DECLARE requestin_field_full = vc WITH noconstant(concat("requestin->list_0[requestin_index].",
     trim(requestin_field,3))), protect
   DECLARE err_message_full = vc WITH protect, noconstant(concat('Program Aborted: Requestin Field "',
     trim(requestin_field,3),'" not found. ')), protect
   SET err_found = validate(parser(requestin_field_full))
   IF (err_found=0)
    CALL cclexception(131301,"E",err_message_full)
    RETURN(err_found)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkalphadatetimeformat(checkindex=i4,alphacol=vc) =null WITH protect, copy)
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," is not a valid date/time format")),
   protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(alphacol,3))), protect
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
     IF (validdateformat(substring(1,11,parser(requestin_field_full_alpha)))=false)
      CALL ctp_mcm_log_error(requestin_index,errmessage)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (validdateformat(date_str=vc) =i2 WITH protect, copy)
   DECLARE date_format_yyyy = vc WITH protect, noconstant(" ")
   DECLARE date_format_yy = vc WITH protect, noconstant(" ")
   DECLARE date_str_11 = c11 WITH protect, noconstant(date_str)
   IF (size(trim(date_str,3)) BETWEEN 8 AND 11
    AND cnvtdatetime(date_str_11) > 0)
    SET date_format_yyyy = format(cnvtdatetime(date_str_11),"DD-MMM-YYYY;;d")
    SET date_format_yy = format(cnvtdatetime(date_str_11),"DD-MMM-YY;;d")
    IF (substring(1,1,date_format_yyyy)="0")
     SET date_format_yyyy = trim(substring(2,textlen(date_format_yyyy),date_format_yyyy))
    ENDIF
    IF (substring(1,1,date_format_yy)="0")
     SET date_format_yy = trim(substring(2,textlen(date_format_yy),date_format_yy))
    ENDIF
    IF (((format(cnvtdatetime(date_str_11),"DD-MMM-YYYY;;d")=cnvtupper(trim(date_str,3))) OR (((
    format(cnvtdatetime(date_str_11),"DD-MMM-YY;;d")=cnvtupper(trim(date_str,3))) OR (((
    date_format_yyyy=cnvtupper(trim(date_str,3))) OR (date_format_yy=cnvtupper(trim(date_str,3))))
    )) )) )
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE ctp_mcm_create_log_file(null) = null WITH protect, copy
 SUBROUTINE ctp_mcm_create_log_file(null)
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   DECLARE requestin_index = i4 WITH protect, noconstant(0)
   DECLARE log_msg_index = i4 WITH protect, noconstant(0)
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
    IF ((ctp_mcm_log->results[requestin_index].msg_cnt=0))
     IF (size(trim(ctp_mcm_log->results[requestin_index].full_msg))=0)
      SET ctp_mcm_log->results[requestin_index].full_msg = "Success"
     ELSE
      SET ctp_mcm_log->results[requestin_index].full_msg = build("Success|",ctp_mcm_log->results[
       requestin_index].full_msg)
     ENDIF
    ELSE
     FOR (log_msg_index = 1 TO ctp_mcm_log->results[requestin_index].msg_cnt)
       IF (log_msg_index=1)
        SET ctp_mcm_log->results[requestin_index].full_msg = ctp_mcm_log->results[requestin_index].
        msg[log_msg_index].txt
       ELSE
        SET ctp_mcm_log->results[requestin_index].full_msg = build(ctp_mcm_log->results[
         requestin_index].full_msg,"|",ctp_mcm_log->results[requestin_index].msg[log_msg_index].txt)
       ENDIF
     ENDFOR
     SET run::import->rows_with_errors += 1
    ENDIF
    SET run::import->rows_processed += 1
   ENDFOR
 END ;Subroutine
 DECLARE ctp_create_log_file(null) = null WITH protect, copy
 SUBROUTINE ctp_create_log_file(null)
   DECLARE csv_row = i4 WITH noconstant(0), protect
   DECLARE index = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   CALL echo(">>>BEGIN LOG FILE")
   FOR (csv_row = 1 TO size(requestin->list_0,5))
    SET run::import->rows_processed += 1
    IF ((import::log->list[csv_row].msg_cnt > 0))
     SET run::import->rows_with_errors += 1
     FOR (index = 1 TO import::log->list[csv_row].msg_cnt)
       IF (index=1)
        SET import::log->list[csv_row].full_msg = import::log->list[csv_row].msg[index].txt
       ELSE
        SET import::log->list[csv_row].full_msg = build(import::log->list[csv_row].full_msg,"|",
         import::log->list[csv_row].msg[index].txt)
       ENDIF
     ENDFOR
     FOR (idx = 1 TO import::log->list[csv_row].cell_cnt)
       IF (idx=1)
        SET import::log->list[csv_row].full_cell = import::log->list[csv_row].cell[idx].cellref
       ELSE
        SET import::log->list[csv_row].full_cell = build(import::log->list[csv_row].full_cell,"|",
         import::log->list[csv_row].cell[idx].cellref)
       ENDIF
     ENDFOR
    ELSEIF ((import::log->layout_error=true))
     SET import::log->list[csv_row].full_msg = " "
    ELSEIF ((run::import->run_upload=false))
     IF (size(trim(import::log->list[csv_row].full_msg))=0)
      SET import::log->list[csv_row].full_msg = "Audited Successfully"
     ELSE
      SET import::log->list[csv_row].full_msg = build("Audited Successfully|",import::log->list[
       csv_row].full_msg)
     ENDIF
    ELSEIF ((import::log->list[csv_row].skip_ind=true))
     SET import::log->list[csv_row].full_msg = "Skipped"
    ELSE
     IF ((import::log->list[csv_row].success_ind=true))
      IF (size(trim(import::log->list[csv_row].full_msg))=0)
       SET import::log->list[csv_row].full_msg = "Uploaded Successfully"
      ELSE
       SET import::log->list[csv_row].full_msg = build("Uploaded Successfully|",import::log->list[
        csv_row].full_msg)
      ENDIF
     ELSE
      SET import::log->list[csv_row].full_msg = build("Skipped due to unexpected error|",import::log
       ->list[csv_row].full_msg)
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkbetamustnotexistifalphanotexists(alphacol=vc,betacol=vc) =null WITH protect,
  copy)
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(betacol,3)," should not exist without ",trim(
      alphacol,3))), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(alphacol,3))), protect
   DECLARE requestin_field_full_beta = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(betacol,3))), protect
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
     IF (size(trim(parser(requestin_field_full_alpha),3))=0
      AND size(trim(parser(requestin_field_full_beta),3)) > 0)
      CALL ctp_mcm_log_error(requestin_index,errmessage)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE ctp_mcm_runtrackingdata(null)
   IF (validate(requestin->list_0[1].associateid))
    IF (size(trim(run::tracking->associateid,3))=0)
     SET run::tracking->associateid = trim(requestin->list_0[1].associateid,3)
    ENDIF
   ENDIF
   IF (validate(requestin->list_0[1].last_macro_revisor))
    IF (size(trim(run::tracking->last_macro_revisor,3))=0)
     SET run::tracking->last_macro_revisor = trim(requestin->list_0[1].last_macro_revisor,3)
    ENDIF
   ENDIF
   IF (validate(requestin->list_0[1].last_macro_revision_dt_tm))
    IF ((run::tracking->last_macro_revision_dt_tm=0))
     SET run::tracking->last_macro_revision_dt_tm = cnvtdatetime(trim(requestin->list_0[1].
       last_macro_revision_dt_tm,3))
    ENDIF
   ENDIF
   IF (validate(requestin->list_0[1].note))
    IF (size(trim(run::tracking->note,3))=0)
     SET run::tracking->note = trim(requestin->list_0[1].note,3)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_updt_requestin_to_cv_display(code_value_string=vc) =vc WITH protect, copy)
   IF (cnvtreal(code_value_string) > 0)
    RETURN(uar_get_code_display(cnvtreal(code_value_string)))
   ELSE
    RETURN(code_value_string)
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_mcm_checkdatetimecomparealphamustbegreaterthanequaltobeta(alphacol=vc,betacol=vc) =
  null WITH protect, copy)
   DECLARE requestin_index = i4 WITH noconstant(0), protect
   DECLARE errmessage = vc WITH constant(concat(trim(alphacol,3)," must be greater than ",trim(
      betacol,3))), protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(alphacol,3))), protect
   DECLARE requestin_field_full_beta = vc WITH noconstant(concat(
     "requestin->list_0[requestin_index].",trim(betacol,3))), protect
   FOR (requestin_index = 1 TO size(requestin->list_0,5))
     IF (size(trim(parser(requestin_field_full_alpha),3)) > 0
      AND size(trim(parser(requestin_field_full_beta),3)) > 0
      AND cnvtdatetime(trim(parser(requestin_field_full_alpha),3)) < cnvtdatetime(trim(parser(
        requestin_field_full_beta))))
      CALL ctp_mcm_log_error(requestin_index,errmessage)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (load_code_value_display(display_name=vc,code_value_name=vc,code_value_mean_name=vc,
  code_set=i4,special_qualifier=vc) =null WITH copy, protect)
   DECLARE special_qualifier_text = vc WITH noconstant("1 = 1"), protect
   IF (size(trim(special_qualifier,3)) > 0)
    SET special_qualifier_text = trim(special_qualifier,3)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=code_set
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(special_qualifier_text))
    ORDER BY cv.display
    HEAD REPORT
     grid->row[1].col[cur_col].txt = display_name, grid->row[1].col[(cur_col+ 1)].txt =
     code_value_name
     IF (size(trim(code_value_mean_name,3)) > 0)
      grid->row[1].col[(cur_col+ 2)].txt = code_value_mean_name, grid->row[1].col[(cur_col+ 3)].txt
       = "|"
     ELSE
      grid->row[1].col[(cur_col+ 2)].txt = "|"
     ENDIF
     cnt = 1
    DETAIL
     cnt += 1
     IF ((cnt > grid->row_cnt)
      AND mod(cnt,1000)=1)
      stat = alterlist(grid->row,(cnt+ 999))
     ENDIF
     IF ((grid->row[cnt].col_cnt=0))
      stat = alterlist(grid->row[cnt].col,max_columns), grid->row[cnt].col_cnt = max_columns
     ENDIF
     CALL addvaluetxt(cnt,cur_col,cv.display),
     CALL addvaluereal(cnt,(cur_col+ 1),cv.code_value)
     IF (size(trim(code_value_mean_name,3)) > 0)
      CALL addvaluetxt(cnt,(cur_col+ 2),cv.cdf_meaning)
     ENDIF
    FOOT REPORT
     IF ((cnt > grid->row_cnt))
      grid->row_cnt = cnt
     ENDIF
     qual_last_row = cnt
     IF (size(trim(code_value_mean_name,3)) > 0)
      cur_col += 4
     ELSE
      cur_col += 3
     ENDIF
    WITH nocounter, nullreport, expand = value(ctp_mcm_with_expand_val)
   ;end select
 END ;Subroutine
 SUBROUTINE (ctp_mcm_forceincodevalue(forcedisplay=vc,forcecodevalue=vc,forcecodemean=vc,
  negstartcolnum=i4) =null WITH copy, protect)
   DECLARE cnt = i4 WITH noconstant(0)
   SET cnt = qual_last_row
   IF ((cnt > grid->row_cnt)
    AND mod(cnt,1000)=1)
    SET stat = alterlist(grid->row,(cnt+ 999))
   ENDIF
   IF ((grid->row[cnt].col_cnt=0))
    SET stat = alterlist(grid->row[cnt].col,max_columns)
    SET grid->row[cnt].col_cnt = max_columns
   ENDIF
   CALL addvaluetxt(cnt,(cur_col+ negstartcolnum),forcedisplay)
   CALL addvaluetxt(cnt,((cur_col+ negstartcolnum)+ 1),forcecodevalue)
   IF (size(trim(forcecodemean,3)) > 0)
    CALL addvaluetxt(cnt,((cur_col+ negstartcolnum)+ 2),forcecodemean)
   ENDIF
   IF ((cnt > grid->row_cnt))
    SET grid->row_cnt = cnt
   ENDIF
   SET qual_last_row += 1
 END ;Subroutine
 SUBROUTINE (ctp_mcm_print_queryprg_results(max_col_cnt=i4,printer=vc) =null WITH copy, protect)
   DECLARE parser_cmd = vc WITH noconstant(" "), protect
   DECLARE index = i4 WITH noconstant, protect
   IF (validate(CTPDYN::output))
    SET modify = filestream
    CALL delimitedoutput(printer,tab)
   ELSE
    CALL parser(concat("select into '",printer,"'"))
    FOR (index = 1 TO max_col_cnt)
      SET parser_cmd = build(parser_cmd,enq,"col",index,
       " = trim(substring(1,255,grid->row[d1.seq].col[",
       index,"].txt))")
    ENDFOR
    SET parser_cmd = trim(parser_cmd,2)
    SET parser_cmd = replace(parser_cmd,enq,",")
    CALL parser(parser_cmd)
    CALL parser("from (dummyt d1 with seq = value(grid->row_cnt))")
    CALL parser("with format, noheading, separator = ' ' go")
   ENDIF
 END ;Subroutine
 SUBROUTINE (addvaluetxt(r=i4,c=i4,txt=vc) =null WITH copy, protect)
   IF (((check(txt) != txt) OR (substring(1,1,txt) IN ('"', "'"))) )
    SET grid->row[r].col[c].txt = concat("***SpecCharRmvd ",check(txt))
   ELSE
    SET grid->row[r].col[c].txt = txt
   ENDIF
 END ;Subroutine
 SUBROUTINE (addvaluereal(r=i4,c=i4,real=f8) =null WITH copy, protect)
   SET grid->row[r].col[c].txt = cnvtstring(real,17,2)
 END ;Subroutine
 SUBROUTINE (addvalueint(r=i4,c=i4,int=i4) =null WITH copy, protect)
   SET grid->row[r].col[c].txt = cnvtstring(int,17)
 END ;Subroutine
 SUBROUTINE (ctp_mcm_cclio_queryprg_results(printer=vc) =null WITH copy, protect)
   SET modify = filestream
   RECORD file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   DECLARE sep = c1 WITH protect, constant(char(9))
   DECLARE q = c1 WITH protect, constant('"')
   DECLARE r = i4 WITH protect, noconstant(0)
   DECLARE c = i4 WITH protect, noconstant(0)
   DECLARE line = vc WITH protect, noconstant(" ")
   DECLARE parser_cmd = vc WITH protect, noconstant(" ")
   IF ( NOT (validate(enq)))
    DECLARE enq = vc WITH protect, constant(char(5))
   ENDIF
   SET file->file_name = value(printer)
   SET file->file_buf = "a+"
   SET stat = cclio("OPEN",file)
   IF (stat=1)
    FOR (r = 1 TO grid->row_cnt)
      SET line = " "
      FOR (c = 1 TO size(grid->row[r].col,5))
        IF (findstring(",",grid->row[r].col[c].txt) > 0)
         SET line = build(line,enq,q,check(grid->row[r].col[c].txt),q)
        ELSE
         SET line = build(line,enq,check(grid->row[r].col[c].txt))
        ENDIF
      ENDFOR
      SET line = trim(line)
      SET line = substring(2,(size(line) - 1),line)
      IF (size(line) > 0)
       SET line = replace(line,enq,sep)
       SET file->file_buf = build(line,char(10))
       SET stat = cclio("WRITE",file)
       IF (stat=0)
        CALL cclexception(900,"E","CCLIO:Could not write to the file!")
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL cclexception(900,"E","CCLIO:Could not open file!")
   ENDIF
   SET stat = cclio("CLOSE",file)
 END ;Subroutine
 SUBROUTINE inserttracking(null)
   DECLARE error_status = i1 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    nextseqnum = seq(aar_report_seq,nextval)
    FROM dual d
    DETAIL
     run::tracking->sequence_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="CLIENT MNEMONIC"
    HEAD REPORT
     run::tracking->client_mnemonic = di.info_char
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info di,
     dm_environment de
    PLAN (di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID")
     JOIN (de
     WHERE de.environment_id=di.info_number)
    HEAD REPORT
     run::tracking->production_ind = de.production_ind
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl p,
     logical_domain ld
    PLAN (p
     WHERE (p.person_id=reqinfo->updt_id))
     JOIN (ld
     WHERE ld.logical_domain_id=p.logical_domain_id)
    HEAD REPORT
     run::tracking->username = p.username, run::tracking->ld_mnemonic = ld.mnemonic, run::tracking->
     logical_domain_id = ld.logical_domain_id
    WITH nocounter
   ;end select
   INSERT  FROM ctp_auto_tracking
    SET ctp_auto_tracking_id = run::tracking->sequence_id, automationid = run::tracking->automationid,
     run_script = evaluate2(
      IF (validate(run::tracking->run_script)=0) curprog
      ELSE run::tracking->run_script
      ENDIF
      ),
     import_script = run::import->script_name, start_dt_tm = cnvtdatetime(run::import->run_dt_tm),
     batch_size = run::import->batch_size,
     import_file = run::import->file_name, log_file = concat(run::import->logical,run::import->
      log_file), client_mnemonic = run::tracking->client_mnemonic,
     logical_domain_mnemonic = run::tracking->ld_mnemonic, logical_domain_id = run::tracking->
     logical_domain_id, domain = curdomain,
     node = curnode, production_ind = run::tracking->production_ind, server = curserver,
     active_ind = true, username = run::tracking->username, user_id = reqinfo->updt_id,
     last_ccl_revisor = run::tracking->last_ccl_revisor, last_ccl_revision_dt_tm = cnvtdatetime(run::
      tracking->last_ccl_revision_dt_tm), client_node_name = reqinfo->client_node_name,
     updt_dt_tm = cnvtdatetime(sysdate), updt_id = reqinfo->updt_id, updt_app = reqinfo->updt_app,
     updt_task = reqinfo->updt_task, updt_req = reqinfo->updt_req, updt_applctx = reqinfo->
     updt_applctx
    WHERE (run::tracking->sequence_id > 0)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_status = insert_tracking_err
   ELSE
    SET error_status = success
    COMMIT
   ENDIF
   RETURN(error_status)
 END ;Subroutine
 SUBROUTINE updatetracking(null)
   DECLARE error_status = i1 WITH protect, noconstant(0)
   UPDATE  FROM ctp_auto_tracking
    SET end_dt_tm = cnvtdatetime(sysdate), rows_processed = run::import->rows_processed, rows_built
      = (run::import->rows_processed - run::import->rows_with_errors),
     rows_with_errors = run::import->rows_with_errors, associateid = run::tracking->associateid,
     last_macro_revisor = run::tracking->last_macro_revisor,
     last_macro_revision_dt_tm = cnvtdatetime(run::tracking->last_macro_revision_dt_tm), note = run::
     tracking->note, updt_dt_tm = cnvtdatetime(sysdate),
     updt_cnt = (updt_cnt+ 1)
    WHERE (ctp_auto_tracking_id=run::tracking->sequence_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_status = update_tracking_err
   ELSE
    SET error_status = success
    COMMIT
   ENDIF
   RETURN(error_status)
 END ;Subroutine
 SUBROUTINE (ctp_run_prg_validate_prompts_tracking_and_dbimport(c_file_name=vc,c_import_script=vc,
  c_batchsize=i4) =null WITH copy, protect)
   SET modify = filestream
   IF ( NOT (RUN::debug_on)
    AND  NOT (validate(CTPDYN::output)))
    IF (checkdic("CTP_AUTO_TRACKING_TABLE","P",0)=false)
     SET error_status = table_def_prg_err
     GO TO status_message
    ENDIF
    EXECUTE ctp_auto_tracking_table:dba 1 WITH replace("REPLY",tracking_reply)
    IF ((tracking_reply->status_data.status="F"))
     IF ((tracking_reply->status_data.subeventstatus[1].operationname="VERSION_MISMATCH"))
      SET error_status = version_error
      GO TO status_message
     ELSEIF ((tracking_reply->status_data.subeventstatus[1].operationname="GROUP_SEC_ERROR"))
      SET error_status = group_sec_error
      GO TO status_message
     ELSE
      SET error_status = table_def_error
      GO TO status_message
     ENDIF
    ENDIF
   ENDIF
   IF (findfile(trim(c_file_name,3)))
    SET run::import->file_name = trim(c_file_name,3)
   ELSE
    SET error_status = file_not_found
    GO TO status_message
   ENDIF
   IF (checkprg(trim(cnvtupper(c_import_script),3)))
    SET run::import->script_name = trim(cnvtupper(c_import_script),3)
   ELSE
    SET error_status = object_not_found
    GO TO status_message
   ENDIF
   IF (cnvtint(c_batchsize) BETWEEN 1 AND max_batch_size)
    SET run::import->batch_size = cnvtint(c_batchsize)
   ELSE
    SET run::import->batch_size = max_batch_size
   ENDIF
   SET run::import->run_dt_tm = cnvtdatetime(sysdate)
   SET run::import->logical = "ccluserdir:"
   SET run::import->log_file = cnvtlower(build(trim(c_import_script,3),"_",format(curdate,
      "YYYYMMDD;;d"),"_",format(curtime3,"HHMMSSCC;3;m"),
     ".log"))
   IF ( NOT (RUN::debug_on)
    AND  NOT (validate(CTPDYN::output)))
    SET error_status = inserttracking(null)
    IF (error_status != success)
     GO TO status_message
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_run_prg_print_status(c_file_name=vc,c_import_script=vc,upload_wiki_page=vc,printer=
  vc) =null WITH copy, protect)
   IF (error_status != success)
    SET run::import->error = true
   ENDIF
   SELECT INTO value(printer)
    FROM dummyt d
    HEAD REPORT
     col 0, row 0
     IF (error_status=table_def_prg_err)
      "Please compile the CTP_AUTO_TRACKING_TABLE program.", row + 2,
      "Please see the following link for additional information.",
      row + 1, "https://wiki.ucern.com/x/HbmCUg", tab,
      "(Tracking Table)"
     ELSEIF (error_status=version_error)
      "Please compile the latest versions of both the import program, and the CTP_AUTO_TRACKING_TABLE program.",
      row + 2, "Please see the following links for additional information.",
      row + 1, upload_wiki_page, tab,
      "(Automation Execution Guide)", row + 1, "https://wiki.ucern.com/x/X7mCUg",
      tab, "(Technical Support Page)"
     ELSEIF (error_status=group_sec_error)
      "Must have group 0 access to update/modify the CTP_AUTO_TRACKING table."
     ELSEIF (error_status=table_def_error)
      "Error creating table CTP_AUTO_TRACKING."
     ELSEIF (error_status=file_not_found)
      "File ",
      CALL print(trim(c_file_name,3)), " could not be found."
     ELSEIF (error_status=object_not_found)
      "Object ",
      CALL print(trim(c_import_script,3)), " could not be found."
     ELSEIF (error_status=insert_tracking_err)
      "Could not insert into CTP_AUTO_TRACKING."
     ELSEIF ((readme_data->status="F"))
      run::import->error = true, readme_data->message
     ELSEIF ( NOT (findfile(build(run::import->logical,run::import->log_file))))
      run::import->error = true, "The log file was not created."
     ELSE
      col 0, "NODE: ", tab,
      curnode, row + 2, col 0,
      "Rows Processed: ", tab,
      CALL print(cnvtstring(run::import->rows_processed)),
      row + 1, col 0, "Rows With Errors:",
      tab,
      CALL print(cnvtstring(run::import->rows_with_errors)), row + 2,
      col 0, "A log file was written to ",
      CALL print(cnvtupper(run::import->logical)),
      " with the file name of:", row + 1, col 0,
      run::import->log_file, row + 2, col 0,
      "Execution Date/Time:", tab,
      CALL print(format(run::import->run_dt_tm,";;q"))
      IF (error_status=update_tracking_err)
       row + 2, col 0, "****ERROR: Could not update CTP_AUTO_TRACKING****"
      ENDIF
     ENDIF
    WITH maxcol = 500, format = variable
   ;end select
   IF (validate(CTPDYN::output))
    CALL CTPDYN::finalizerunimport(printer,run::import->error,run::import->logical,run::import->
     log_file)
   ENDIF
 END ;Subroutine
 SUBROUTINE ctp_setupreadme(null)
   IF (validate(readme_data)=0)
    FREE SET readme_data
    RECORD readme_data(
      1 ocd = i4
      1 readme_id = f8
      1 instance = i4
      1 readme_type = vc
      1 description = vc
      1 script = vc
      1 check_script = vc
      1 data_file = vc
      1 par_file = vc
      1 blocks = i4
      1 log_rowid = vc
      1 status = vc
      1 message = c255
      1 options = vc
      1 driver = vc
      1 batch_dt_tm = dq8
    ) WITH persistscript, protect
   ENDIF
 END ;Subroutine
 SUBROUTINE (delimitedoutput(output=vc,delim=vc) =null WITH copy, protect)
   RECORD file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   DECLARE cr = c1 WITH protect, constant(char(13))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE q = c1 WITH protect, constant('"')
   DECLARE r = i4 WITH protect, noconstant(0)
   DECLARE c = i4 WITH protect, noconstant(0)
   DECLARE line = vc WITH protect, noconstant(" ")
   SET file->file_name = output
   SET file->file_buf = "a+"
   SET stat = cclio("OPEN",file)
   IF (stat=1)
    FOR (r = 1 TO grid->row_cnt)
      SET line = " "
      FOR (c = 1 TO size(grid->row[r].col,5))
        IF (findstring(",",grid->row[r].col[c].txt) > 0)
         IF (c=1)
          SET line = build(q,grid->row[r].col[c].txt,q)
         ELSE
          SET line = build(line,enq,q,grid->row[r].col[c].txt,q)
         ENDIF
        ELSE
         IF (c=1)
          SET line = grid->row[r].col[c].txt
         ELSE
          SET line = build(line,enq,grid->row[r].col[c].txt)
         ENDIF
        ENDIF
      ENDFOR
      SET line = trim(line)
      IF (size(line) > 0)
       SET line = replace(line,enq,delim)
       SET file->file_buf = build(line,cr,lf)
       SET stat = cclio("WRITE",file)
       IF (stat=0)
        CALL cclexception(900,"E","CCLIO:Could not write to the file!")
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL cclexception(900,"E","CCLIO:Could not open file!")
   ENDIF
   SET stat = cclio("CLOSE",file)
 END ;Subroutine
 SUBROUTINE (ctp_mcm_cclio_auditprg_results(printer=vc) =null WITH copy, protect)
   RECORD file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   SET modify = filestream
   DECLARE tab = c1 WITH protect, constant(char(9))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE q = c1 WITH protect, constant('"')
   DECLARE clean_txt = vc WITH protect, noconstant(" ")
   DECLARE line = vc WITH protect, noconstant(" ")
   DECLARE index = i4 WITH protect, noconstant(0)
   SET file->file_name = value(printer)
   SET file->file_buf = "w"
   SET stat = cclio("OPEN",file)
   IF (stat=1)
    FOR (r = 1 TO grid->row_cnt)
      SET line = " "
      FOR (c = 1 TO grid->row[r].col_cnt)
       SET clean_txt = checkreplace(grid->row[r].col[c].txt,q)
       IF (((findstring(",",clean_txt) > 0) OR (findstring(q,clean_txt) > 0)) )
        IF (c=1)
         SET line = build(q,clean_txt,q)
        ELSE
         SET line = build(line,tab,q,clean_txt,q)
        ENDIF
       ELSE
        IF (c=1)
         SET line = clean_txt
        ELSE
         SET line = build(line,tab,clean_txt)
        ENDIF
       ENDIF
      ENDFOR
      SET file->file_buf = concat(trim(line),lf)
      SET stat = cclio("WRITE",file)
      IF (stat=0)
       CALL cclexception(900,"E","CCLIO:Could not write to the file!")
      ENDIF
    ENDFOR
   ELSE
    CALL cclexception(900,"E","CCLIO:Could not open file!")
   ENDIF
   SET stat = cclio("CLOSE",file)
   IF (validate(CTPDYN::output))
    CALL CTPDYN::finalizeimportextract(printer,ctp_mcm_data->err_ind)
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkreplace(txt=vc,qualifier=vc) =vc WITH copy, protect)
   DECLARE return_val = vc WITH protect, noconstant(txt)
   SET return_val = replace(return_val,qualifier,fillstring(2,qualifier),0)
   IF (check(return_val) != return_val)
    SET return_val = concat("***SpecCharRmvd ",check(return_val))
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (ctp_mcm_determinecodevaluebypromptstring(prompt_value=vc,code_set=i4,code_set_mnemonic=
  vc,printer=vc) =null WITH protect, copy)
   DECLARE valid_prompt_err_message = vc WITH noconstant(" "), protect
   DECLARE valid_prompt_input = i2 WITH noconstant(0), protect
   DECLARE search_code_value = f8 WITH noconstant(0.0), protect
   IF (size(trim(prompt_value,3)) > 0)
    IF (isnumeric(prompt_value) != 0)
     IF (uar_get_code_set(cnvtreal(prompt_value))=code_set)
      SET search_code_value = cnvtreal(prompt_value)
      SET valid_prompt_input = 1
     ELSE
      SET valid_prompt_err_message = concat("Please enter a valid code value from code set ",trim(
        cnvtstring(code_set),3),"!")
     ENDIF
    ELSE
     IF (value(uar_get_code_by("Display",code_set,trim(prompt_value,3))) > 0)
      SET search_code_value = value(uar_get_code_by("Display",code_set,trim(prompt_value,3)))
      SET valid_prompt_input = 1
     ELSE
      SET valid_prompt_err_message = concat("Please enter a valid code display from code set ",trim(
        cnvtstring(code_set),3),"!")
     ENDIF
    ENDIF
   ELSE
    SET valid_prompt_err_message = concat("Please enter a value for ",trim(code_set_mnemonic,3),"!")
   ENDIF
   IF (valid_prompt_input=0)
    SELECT INTO value(printer)
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=code_set
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
     ORDER BY cnvtupper(cv.display)
     HEAD REPORT
      col 0, valid_prompt_err_message, row + 1,
      row + 1, col 0, "Possible values:",
      row + 1
     DETAIL
      col 0, cv.display, col 45,
      cv.code_value, row + 1
     WITH nocounter, format, separator = " "
    ;end select
    SET ctp_mcm_data->err_ind = 1
   ENDIF
   RETURN(search_code_value)
 END ;Subroutine
 SUBROUTINE (ctp_checkcclrev(version_threshold=vc,errmsg=vc(ref)) =i2 WITH protect, copy)
   DECLARE delimiter = vc WITH constant("."), protect
   DECLARE return_val = i2 WITH noconstant(0), protect
   DECLARE error_message = vc WITH noconstant(" "), protect
   DECLARE major_rev = f8 WITH noconstant(0), protect
   SET major_rev = cnvtreal(piece(version_threshold,delimiter,1,"0"))
   DECLARE minor_rev = f8 WITH noconstant(0), protect
   SET minor_rev = cnvtreal(piece(version_threshold,delimiter,2,"0"))
   DECLARE minor_rev2 = f8 WITH noconstant(0), protect
   SET minor_rev2 = cnvtreal(piece(version_threshold,delimiter,3,"0"))
   DECLARE currentrevisiontext = vc WITH noconstant(" "), protect
   SET currentrevisiontext = build(currev,".",currevminor)
   IF (validate(currevminor2))
    SET currentrevisiontext = build(currentrevisiontext,".",currevminor2)
   ELSE
    SET currentrevisiontext = build(currentrevisiontext,".","00")
   ENDIF
   SET error_message = trim(concat("This program requires a minimum of CCL Revision ",trim(
      version_threshold,3),"; current revision is ",trim(currentrevisiontext,3),". ",
     "Please refer to https://wiki.ucern.com/x/X7mCUg for support."))
   IF (cnvtint(currev) > cnvtint(major_rev))
    SET return_val = 1
   ELSEIF (cnvtint(currev)=cnvtint(major_rev))
    IF (cnvtint(currevminor) > cnvtint(minor_rev))
     SET return_val = 1
    ELSEIF (cnvtint(currevminor)=cnvtint(minor_rev))
     IF (cnvtint(validate(currevminor2,0)) >= cnvtint(minor_rev2))
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   IF (return_val=0)
    SET errmsg = error_message
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (ctp_add_new_swap(swapin=vc,swapout=vc) =null WITH protect, copy)
   SET swap_list_index = size(swap_list->list,5)
   SET swap_list_index += 1
   SET stat = alterlist(swap_list->list,swap_list_index)
   SET swap_list->list[swap_list_index].inboundval = swapin
   SET swap_list->list[swap_list_index].outboundval = swapout
 END ;Subroutine
 SUBROUTINE (ctp_sub_value_swap(checkindex=i4,alphacol=vc) =null WITH protect, copy)
   RECORD swap_list(
     1 list[*]
       2 inboundval = vc
       2 outboundval = vc
   ) WITH protect
   DECLARE requestin_field_full_alpha = vc WITH noconstant(concat("requestin->list_0[checkindex].",
     trim(alphacol,3))), protect
   DECLARE temp_text = vc WITH noconstant(parser(requestin_field_full_alpha)), protect
   CALL ctp_add_new_swap("{ctpchar34}",char(34))
   IF (size(trim(check(temp_text),3)) > 0)
    FOR (swap_list_index = 1 TO size(swap_list->list,5))
      SET temp_text = replace(temp_text,value(swap_list->list[swap_list_index].inboundval),value(
        swap_list->list[swap_list_index].outboundval))
    ENDFOR
   ENDIF
   SET parser(requestin_field_full_alpha) = temp_text
 END ;Subroutine
 SUBROUTINE (load_code_value_description(description_name=vc,code_value_name=vc,code_value_mean_name=
  vc,code_set=i4,special_qualifier=vc) =null WITH copy, protect)
   DECLARE special_qualifier_text = vc WITH noconstant("1 = 1"), protect
   IF (size(trim(special_qualifier,3)) > 0)
    SET special_qualifier_text = trim(special_qualifier,3)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=code_set
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(special_qualifier_text))
    ORDER BY cv.display
    HEAD REPORT
     grid->row[1].col[cur_col].txt = description_name, grid->row[1].col[(cur_col+ 1)].txt =
     code_value_name
     IF (size(trim(code_value_mean_name,3)) > 0)
      grid->row[1].col[(cur_col+ 2)].txt = code_value_mean_name, grid->row[1].col[(cur_col+ 3)].txt
       = "|"
     ELSE
      grid->row[1].col[(cur_col+ 2)].txt = "|"
     ENDIF
     cnt = 1
    DETAIL
     cnt += 1
     IF ((cnt > grid->row_cnt)
      AND mod(cnt,1000)=1)
      stat = alterlist(grid->row,(cnt+ 999))
     ENDIF
     IF ((grid->row[cnt].col_cnt=0))
      stat = alterlist(grid->row[cnt].col,max_columns), grid->row[cnt].col_cnt = max_columns
     ENDIF
     CALL addvaluetxt(cnt,cur_col,cv.description),
     CALL addvaluereal(cnt,(cur_col+ 1),cv.code_value)
     IF (size(trim(code_value_mean_name,3)) > 0)
      CALL addvaluetxt(cnt,(cur_col+ 2),cv.cdf_meaning)
     ENDIF
    FOOT REPORT
     IF ((cnt > grid->row_cnt))
      grid->row_cnt = cnt
     ENDIF
     qual_last_row = cnt
     IF (size(trim(code_value_mean_name,3)) > 0)
      cur_col += 4
     ELSE
      cur_col += 3
     ENDIF
    WITH nocounter, nullreport, expand = value(ctp_mcm_with_expand_val)
   ;end select
 END ;Subroutine
 SUBROUTINE (addcolumnheaderaudit(c=i4(ref),txt=vc) =null WITH copy, protect)
  SET c += 1
  SET grid->row[1].col[c].txt = txt
 END ;Subroutine
 SUBROUTINE (addvaluetxtaudit(r=i4,c=i4(ref),txt=vc) =null WITH copy, protect)
  SET c += 1
  SET grid->row[r].col[c].txt = txt
 END ;Subroutine
 SUBROUTINE (addvaluerealaudit(r=i4,c=i4(ref),real=f8) =null WITH copy, protect)
  SET c += 1
  SET grid->row[r].col[c].txt = cnvtstring(real,17,2)
 END ;Subroutine
 SUBROUTINE (addvalueintaudit(r=i4,c=i4(ref),int=i4) =null WITH copy, protect)
  SET c += 1
  SET grid->row[r].col[c].txt = cnvtstring(int,17)
 END ;Subroutine
 SUBROUTINE (ctp_mcm_cnvtage_from_min(minutes=f8) =vc WITH copy, protect)
   DECLARE display_days = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!2934"))), protect
   DECLARE display_hours = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!2933"))), protect
   DECLARE display_minutes = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!3725"))), protect
   DECLARE display_months = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!2936"))), protect
   DECLARE display_seconds = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!8025"))), protect
   DECLARE display_weeks = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!2935"))), protect
   DECLARE display_years = vc WITH constant(uar_get_code_display(uar_get_code_by_cki(
      "CKI.CODEVALUE!2937"))), protect
   DECLARE cnvt_result = f8 WITH noconstant(0.0), protect
   DECLARE cnvt_display = vc WITH noconstant(" "), protect
   DECLARE return_val = vc WITH noconstant(" "), protect
   IF (minutes=0)
    SET cnvt_result = (minutes * 0)
    SET cnvt_display = display_minutes
   ELSEIF (minutes < 1)
    SET cnvt_result = (minutes * 60)
    SET cnvt_display = display_seconds
   ELSEIF (minutes < 60)
    SET cnvt_result = (minutes * 1)
    SET cnvt_display = display_minutes
   ELSEIF (minutes < 1440)
    SET cnvt_result = (minutes/ 60)
    SET cnvt_display = display_hours
   ELSEIF (minutes < 10080)
    SET cnvt_result = (minutes/ 1440)
    SET cnvt_display = display_days
   ELSEIF (minutes < 43800)
    SET cnvt_result = (minutes/ 10080)
    SET cnvt_display = display_weeks
   ELSEIF (minutes < 525600)
    SET cnvt_result = (minutes/ 43800)
    SET cnvt_display = display_months
   ELSE
    SET cnvt_result = (minutes/ 525600)
    SET cnvt_display = display_years
   ENDIF
   SET return_val = concat(trim(cnvtstring(cnvt_result),3)," ",trim(cnvt_display,3))
   RETURN(trim(return_val,3))
 END ;Subroutine
 SUBROUTINE (IMP::errormsg(r=i4,enum_name=i4,addl_msg=vc(value," ")) =null WITH protect, copy)
   DECLARE msg_cnt = i4 WITH protect, noconstant(import::log->list[r].msg_cnt)
   DECLARE enumpos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET enumpos = locatevalsort(index,1,msgdef->cnt,enum_name,msgdef->list[index].enum)
   IF (enumpos > 0)
    SET msg_cnt += 1
    SET import::log->list[r].msg_cnt = msg_cnt
    SET stat = alterlist(import::log->list[r].msg,msg_cnt)
    SET import::log->list[r].msg[msg_cnt].txt = msgdef->list[enumpos].msg
    IF (textlen(trim(addl_msg)) != 0)
     SET import::log->list[r].msg[msg_cnt].txt = build(import::log->list[r].msg[msg_cnt].txt,"::",
      addl_msg)
    ENDIF
    FOR (index = 1 TO msgdef->list[enumpos].col_cnt)
      CALL IMP::errorcellref(r,msgdef->list[enumpos].col[index].val)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (IMP::errorcellref(r=i4,c=i4) =null WITH protect, copy)
   DECLARE cell_cnt = i4 WITH protect, noconstant(import::log->list[r].cell_cnt)
   SET cell_cnt += 1
   SET import::log->list[r].cell_cnt = cell_cnt
   SET stat = alterlist(import::log->list[r].cell,cell_cnt)
   SET import::log->list[r].cell[cell_cnt].cellref = build(r,",",c)
 END ;Subroutine
 SUBROUTINE (definemsg(enum_cnt=i4(ref),enum_name=vc,error_msg=vc,columns=vc) =null WITH protect,
  copy)
   DECLARE enumpos = i4 WITH protect, noconstant(0)
   DECLARE colpos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(parser(enum_name))))
    SET enum_cnt += 1
    CALL parser(build2("declare ",enum_name," = i4 with persistScript, constant(",enum_cnt,") go"))
    SET enumpos = locatevalsort(index,1,msgdef->cnt,enum_cnt,msgdef->list[index].enum)
    IF (enumpos <= 0)
     SET enumpos = abs(enumpos)
     SET msgdef->cnt += 1
     SET stat = alterlist(msgdef->list,msgdef->cnt,enumpos)
     SET enumpos += 1
     SET msgdef->list[enumpos].enum = enum_cnt
     SET msgdef->list[enumpos].msg = error_msg
     SET piece_cnt = 1
     SET column = piece(columns,"|",piece_cnt,IMP::not_found,3)
     WHILE ((column != IMP::not_found))
       IF (column != "ALL")
        SET col_cnt += 1
        SET stat = alterlist(msgdef->list[enumpos].col,col_cnt)
        SET colpos = locateval(index,1,colmap->cnt,column,colmap->data[index].field)
        IF (colpos > 0)
         SET msgdef->list[enumpos].col[col_cnt].val = colmap->data[colpos].col
        ENDIF
        SET piece_cnt += 1
        SET column = piece(columns,"|",piece_cnt,IMP::not_found,3)
       ELSE
        SET col_cnt = (colmap->cnt - 1)
        SET stat = alterlist(msgdef->list[enumpos].col,col_cnt)
        FOR (index = 1 TO col_cnt)
          SET msgdef->list[enumpos].col[index].val = colmap->data[index].col
        ENDFOR
        SET column = IMP::not_found
       ENDIF
     ENDWHILE
     SET msgdef->list[enumpos].col_cnt = col_cnt
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_checknotblank(index=i4,stringvalue=vc(ref),err_enum_name=i4) =i2 WITH protect, copy)
   DECLARE truthstate = i2 WITH protect, noconstant(0)
   IF (size(trim(stringvalue,3)) > 0)
    SET truthstate = 1
   ELSE
    CALL IMP::errormsg(index,err_enum_name)
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_checkincodeset(index=i4,stringvalue=vc(ref),codeset=i4,err_enum_name=i4,
  uar_get_code_by_flex=vc(value," ")) =i2 WITH protect, copy)
   DECLARE truthstate = i2 WITH protect, noconstant(0)
   DECLARE flex_type = vc WITH protect, noconstant("DISPLAY")
   IF (size(trim(uar_get_code_by_flex,3)) > 0)
    SET flex_type = cnvtupper(uar_get_code_by_flex)
   ENDIF
   IF (size(trim(stringvalue,3)) > 0)
    IF (uar_get_code_set(cnvtreal(stringvalue)) <= 0
     AND uar_get_code_by(flex_type,codeset,stringvalue) <= 0)
     CALL IMP::errormsg(index,err_enum_name)
    ELSE
     SET truthstate = 1
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_checkcharlength(index=i4,stringvalue=vc(ref),char_length=i4,err_enum_name=i4) =i2
  WITH protect, copy)
   DECLARE truthstate = i2 WITH protect, noconstant(0)
   IF (size(trim(stringvalue,3)) > 0)
    IF (size(trim(stringvalue,3)) > char_length)
     CALL IMP::errormsg(index,err_enum_name)
    ELSE
     SET truthstate = 1
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_checkisnumeric(index=i4,stringvalue=vc(ref),err_enum_name=i4) =i2 WITH protect, copy
  )
   DECLARE truthstate = i2 WITH protect, noconstant(0)
   IF (size(trim(stringvalue,3)) > 0)
    IF ( NOT (isnumeric(stringvalue)))
     CALL IMP::errormsg(index,err_enum_name)
    ELSE
     SET truthstate = 1
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_checkisdatetime(index=i4,stringvalue=vc(ref),err_enum_name=i4) =i2 WITH protect,
  copy)
   DECLARE truthstate = i2 WITH protect, noconstant(0)
   DECLARE standard_date = vc WITH protect, constant("DD-MMM-YYYY HH:MM:SS;;D")
   IF (size(trim(stringvalue,3)) > 0)
    SET stringvalue = cnvtupper(stringvalue)
    IF (stringvalue=format(cnvtdatetime(stringvalue),standard_date))
     SET truthstate = 1
    ELSE
     IF (validdateformat(stringvalue))
      SET truthstate = 1
     ELSE
      CALL IMP::errormsg(index,err_enum_name)
     ENDIF
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_run_prg_validate_prompts_uploadmode(i_uploadmode=i4,i_runupload=i4(ref)) =null WITH
  copy, protect)
   IF ((i_uploadmode=RUN::upload_err_mode))
    SET i_runupload = true
   ELSEIF ((i_uploadmode=RUN::upload_noerr_mode))
    SET i_runupload = RUN::chk_in_import
   ELSE
    SET i_runupload = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (ctp_checkrunuploadstate(runuploadflag=i2(ref)) =i2 WITH protect, copy)
   DECLARE truth_state = i2 WITH protect, noconstant(0)
   IF ((runuploadflag=RUN::chk_in_import))
    SELECT INTO "nl:"
     import::log->list[d1.seq].msg_cnt
     FROM (dummyt d1  WITH seq = value(size(import::log->list,5)))
     PLAN (d1
      WHERE (import::log->list[d1.seq].msg_cnt=0))
     WITH nocounter
    ;end select
    IF (curqual=size(requestin->list_0,5))
     SET runuploadflag = true
    ELSE
     SET runuploadflag = false
    ENDIF
   ENDIF
   SET truth_state = runuploadflag
   RETURN(truth_state)
 END ;Subroutine
 SUBROUTINE (ctp_dependency_checkexists(index=i4,sourcestring=vc(ref),targetstring=vc(ref),
  err_enum_name=i4,onlyifuppersourcevalueisin=vc(value," ")) =i2 WITH protect, copy)
   DECLARE truthstate = i2 WITH protect, noconstant(1)
   DECLARE flexstring = vc WITH protect, noconstant("1 = 1")
   IF (size(trim(onlyifuppersourcevalueisin,3)) > 0)
    SET flexstring = concat('cnvtupper("',sourcestring,'")'," in (",onlyifuppersourcevalueisin,
     ")")
   ENDIF
   IF (size(trim(sourcestring,3)) > 0
    AND parser(flexstring))
    IF (size(trim(targetstring,3))=0)
     CALL IMP::errormsg(index,err_enum_name)
     SET truthstate = 0
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_requirement_checkexists(index=i4,targetstring=vc(ref),sourcestring=vc(ref),
  err_enum_name=i4,onlyifuppersourcevalueisin=vc) =i2 WITH protect, copy)
   DECLARE truthstate = i2 WITH protect, noconstant(1)
   DECLARE flexstring = vc WITH protect, noconstant("1 = 1")
   IF (size(trim(onlyifuppersourcevalueisin,3)) > 0)
    SET flexstring = concat('cnvtupper("',sourcestring,'")'," in (",onlyifuppersourcevalueisin,
     ")")
   ENDIF
   IF (size(trim(targetstring,3)) > 0)
    IF (size(trim(sourcestring,3)) > 0
     AND parser(flexstring))
     CALL IMP::errormsg(index,err_enum_name)
     SET truthstate = 0
    ENDIF
   ENDIF
   RETURN(truthstate)
 END ;Subroutine
 SUBROUTINE (ctp_char_swap(stringvalue=vc(ref),revertmode=i4(value,0)) =null WITH protect, copy)
   RECORD swap_list(
     1 list[*]
       2 inboundval = vc
       2 outboundval = vc
   ) WITH protect
   DECLARE add_new_swap(swapin=vc,swapout=vc) = null WITH protect
   DECLARE temp_text = vc WITH noconstant(stringvalue), protect
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE prefix = vc WITH protect, constant("{ctpchar")
   DECLARE suffix = vc WITH protect, constant("}")
   DECLARE swap_list_index = i4 WITH protect, noconstant(0)
   FOR (i = 0 TO 31)
     IF ( NOT (revertmode))
      CALL ctp_add_new_swap(build(prefix,i,suffix),char(i))
     ELSE
      CALL ctp_add_new_swap(char(i),build(prefix,i,suffix))
     ENDIF
   ENDFOR
   FOR (i = 128 TO 255)
     IF ( NOT (revertmode))
      CALL ctp_add_new_swap(build(prefix,i,suffix),char(i))
     ELSE
      CALL ctp_add_new_swap(char(i),build(prefix,i,suffix))
     ENDIF
   ENDFOR
   IF ( NOT (revertmode))
    CALL ctp_add_new_swap(build(prefix,34,suffix),char(34))
   ELSE
    CALL ctp_add_new_swap(char(34),build(prefix,34,suffix))
   ENDIF
   IF (revertmode)
    CALL ctp_add_new_swap(build(prefix,13,suffix,prefix,10,
      suffix),build(prefix,10,suffix))
   ENDIF
   IF (size(trim(check(temp_text),3)) > 0)
    FOR (swap_list_index = 1 TO size(swap_list->list,5))
      SET temp_text = replace(temp_text,value(swap_list->list[swap_list_index].inboundval),value(
        swap_list->list[swap_list_index].outboundval))
    ENDFOR
   ENDIF
   SET stringvalue = temp_text
 END ;Subroutine
 SET last_mod =
 "019 08/12/20 MM020843 Adjust ctp_create_log_file to not overwrite full msg during catch-all for troubleshooting"
END GO
