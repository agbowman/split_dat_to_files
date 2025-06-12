CREATE PROGRAM cv_get_proc_type_sts:dba
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
 DECLARE parse_delimitter = vc WITH protect, noconstant("##")
 DECLARE str_operand = vc WITH protect, constant("OPERAND")
 DECLARE str_cvxref = vc WITH protect, constant("CV_XREF")
 DECLARE str_cvresponse = vc WITH protect, constant("CV_RESPONSE")
 DECLARE str_cvalgorithm = vc WITH protect, constant("CV_ALGORITHM")
 DECLARE str_cvcomponent = vc WITH protect, constant("CV_COMPONENT")
 DECLARE str_evaluation = vc WITH protect, constant("EVALUATION")
 DECLARE str_validation = vc WITH protect, constant("VALIDATION")
 DECLARE str_longtextref = vc WITH protect, constant("LONG_TEXT_REFERENCE")
 DECLARE str_sts_predmort = vc WITH protect, constant("STS_PREDMORT")
 DECLARE cv_type_operand = i4 WITH protect, constant(0)
 DECLARE cv_type_xref = i4 WITH protect, constant(1)
 DECLARE cv_type_response = i4 WITH protect, constant(2)
 DECLARE cv_type_operator = i4 WITH protect, constant(3)
 DECLARE cv_type_component = i4 WITH protect, constant(4)
 DECLARE cv_type_longtext = i4 WITH protect, constant(5)
 DECLARE cv_type_calc_value = i4 WITH protect, constant(6)
 DECLARE cv_date = i4 WITH protect, constant(10)
 DECLARE cv_number = i4 WITH protect, constant(20)
 DECLARE cv_string = i4 WITH protect, constant(30)
 DECLARE cv_component_type_validation = i4 WITH protect, constant(1)
 DECLARE cv_component_type_evaluation = i4 WITH protect, constant(2)
 DECLARE popstack2(result=vc(ref)) = null
 DECLARE get_value(index=i4) = null
 DECLARE gv_retval = vc WITH protect
 DECLARE lstrval = vc WITH protect
 DECLARE mstrval = vc WITH protect
 DECLARE rstrval = vc WITH protect
 DECLARE pushval = vc WITH protect
 DECLARE lnumval = f8 WITH protect
 DECLARE mnumval = f8 WITH protect
 DECLARE rnumval = f8 WITH protect
 DECLARE rdateval = i4 WITH protect
 DECLARE ldateval = i4 WITH protect
 DECLARE do_echo = i2 WITH noconstant(0)
 DECLARE cv_type_pending = i4 WITH constant(- (1))
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE index = i4 WITH protect
 DECLARE iret = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE start = i4 WITH protect
 DECLARE stop = i4 WITH protect
 DECLARE total1 = i4 WITH protect
 DECLARE total2 = i4 WITH protect
 DECLARE t1 = f8 WITH protect
 DECLARE t2 = f8 WITH protect
 DECLARE t3 = f8 WITH protect
 DECLARE cnt1 = i4 WITH protect
 DECLARE cnt2 = i4 WITH protect
 DECLARE cnt_token = i4 WITH protect
 DECLARE loop = i4 WITH protect
 DECLARE cnt_stack = i4 WITH protect
 DECLARE operands_fieldtype = i4 WITH protect
 DECLARE field_type_meaning = vc WITH protect
 DECLARE record_status_cd = f8 WITH noconstant(0.0), protect
 DECLARE result_status_cd = f8 WITH noconstant(0.0), protect
 IF (validate(g_cv_echo_algorithm,0) > 0)
  SET do_echo = 1
 ENDIF
 IF (validate(algcomp,"notdefined") != "notdefined")
  CALL cv_log_message("record algcomp is already defined")
 ELSE
  CALL cv_log_message("record algcomp was not defined")
  RECORD algcomp(
    1 cnt_algorithm = i4
    1 algorithm[*]
      2 algorithm_id = f8
      2 description = vc
      2 validation_id = f8
      2 field_mean = c12
      2 validated_ind = i2
      2 result_val = vc
      2 result_cd = f8
      2 task_assay_cd = f8
      2 event_cd = f8
      2 form_name = vc
      2 form_collating_seq = vc
      2 sect_name = vc
      2 sect_collating_seq = vc
      2 input_name = vc
      2 input_collating_seq = vc
      2 long_text = vc
      2 long_text_id = f8
      2 cnt_component = i4
      2 component[*]
        3 component_id = f8
        3 long_text_id = f8
        3 algorithm_id = f8
        3 mnemonic = vc
        3 mnemonic_key = vc
        3 parent_component_id = f8
        3 source_name = vc
        3 source_id = f8
        3 modifier = f8
        3 long_text = vc
        3 component_type_flag = i2
        3 calc_value = vc
  )
 ENDIF
 IF ((validate(operator,- (1))=- (1)))
  RECORD operator(
    1 operator[*]
      2 operator = vc
      2 nbr_operands = i4
  )
 ENDIF
 IF ((validate(token,- (1))=- (1)))
  RECORD token(
    1 token[*]
      2 token = vc
      2 type = i4
      2 data_idx = i4
      2 cv_response = vc
      2 primary_key = f8
      2 value = vc
    1 description = vc
    1 size = i4
  )
 ENDIF
 IF ((validate(stack,- (1))=- (1)))
  RECORD stack(
    1 stack[*]
      2 token_idx = i4
      2 value = vc
      2 type = i4
    1 size = i4
  )
 ENDIF
 SUBROUTINE calc_components(prm_cc_idx)
   CALL cv_log_message("calc_components")
   DECLARE t_description = vc WITH protect, noconstant(" ")
   DECLARE mnemonic_val = vc WITH protect, noconstant(" ")
   FOR (k = 1 TO size(algcomp->algorithm[prm_cc_idx].component,5))
     IF ((algcomp->algorithm[prm_cc_idx].component[k].source_name=str_longtextref))
      SET stat = alterlist(token->token,0)
      SET stat = alterlist(token->token,token_alloc_size)
      SET token->size = token_alloc_size
      SET cnt_token = 1
      SET token->token[cnt_token].token = algcomp->algorithm[prm_cc_idx].component[k].long_text
      SET token->token[cnt_token].type = cv_type_longtext
      CALL process_tokens(calc_start,cv_component_type_evaluation)
      CALL get_response_values(0)
      CALL get_values_from_cv_hrv_rec(0)
      CALL do_postfix(0)
      IF (cnt_stack != 1)
       CALL cv_log_message("***********************************************")
       CALL cv_log_message(build("Invalid Stack Count. Should be 1:",cnt_stack))
       CALL cv_log_message(build("Algorithm Idx:  ",prm_cc_idx,"    Component_idx:",k))
       CALL cv_log_message(build("Algorithm Name:",algcomp->algorithm[prm_cc_idx].description))
       CALL cv_log_message(build("Mnemonic:",algcomp->algorithm[prm_cc_idx].component[k].mnemonic))
       CALL cv_log_message("***********************************************")
       SET algcomp->algorithm[prm_cc_idx].component[k].calc_value = "-99999.99"
      ELSE
       SET algcomp->algorithm[prm_cc_idx].component[k].calc_value = stack->stack[cnt_stack].value
      ENDIF
      DECLARE echo_ctrl = i2 WITH protect, noconstant(0)
      FOR (calc_cnt = 1 TO size(calc_cmp->component,5))
        IF ((cnvtupper(trim(algcomp->algorithm[prm_cc_idx].description))=calc_cmp->alg_desc))
         IF (cnvtupper(trim(algcomp->algorithm[prm_cc_idx].component[k].mnemonic))=cnvtupper(trim(
           calc_cmp->component[calc_cnt].mnemonic)))
          CALL cv_echo("************* Section Debug Starts ***************")
          CALL cv_log_message(build("Algorithm Name:",algcomp->algorithm[prm_cc_idx].description))
          CALL cv_echo(build("mnemonic: ",algcomp->algorithm[prm_cc_idx].component[k].mnemonic))
          CALL cv_echo(build("value: ",stack->stack[cnt_stack].value))
          SET mnemonic_val = build(mnemonic_val,algcomp->algorithm[prm_cc_idx].component[k].mnemonic,
           " = ",stack->stack[cnt_stack].value)
          IF (echo_ctrl=0)
           CALL cv_echo("dump token into: cer_temp:cv_token_calc.dat")
           CALL echorecord(token,"cer_temp:cv_token_calc.dat")
           CALL cv_echo("dump stack into: cer_temp:cv_stack_calc.dat")
           CALL echorecord(stack,"cer_temp:cv_stack_calc.dat")
           CALL cv_log_message("Dumping algcomp to cer_temp:cv_hrv_rec.dat:")
           CALL echorecord(cv_hrv_rec,"cer_temp:cv_hrv_rec.dat")
           SET echo_ctrl = 1
          ENDIF
          CALL cv_echo("************* Section Debug Ends *****************")
         ENDIF
        ENDIF
      ENDFOR
      IF ((cnvtupper(trim(algcomp->algorithm[prm_cc_idx].description))=calc_cmp->alg_desc))
       SET mnemonic_val = build(mnemonic_val,char(13),char(10),algcomp->algorithm[prm_cc_idx].
        component[k].mnemonic," = ",
        stack->stack[cnt_stack].value)
      ENDIF
     ENDIF
   ENDFOR
   CALL cv_log_message("calc_components end")
   CALL cv_echo("************************ debug *****************************")
   SET t_description = build("Algorithm Name:",algcomp->algorithm[prm_cc_idx].description)
   CALL cv_echo(t_description)
   CALL cv_echo(build("mnemonic_val: ",mnemonic_val))
   CALL cv_echo("************************ debug end *************************")
 END ;Subroutine
 SUBROUTINE set_initial_token(prm_sit_idx,prm_comp_type_flag)
   CALL cv_echo(build("prm_sit_idx:",prm_sit_idx))
   CALL cv_echo(build("prm_comp_type_flag:",prm_comp_type_flag))
   CALL cv_log_message("set_initial_token")
   SET stat = alterlist(token->token,0)
   SET stat = alterlist(token->token,token_alloc_size)
   SET token->size = token_alloc_size
   SET cnt_token = 1
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(algcomp->algorithm[prm_sit_idx].component,5)))
    WHERE (algcomp->algorithm[prm_sit_idx].component[d.seq].component_type_flag=prm_comp_type_flag)
     AND (algcomp->algorithm[prm_sit_idx].component[d.seq].component_id=algcomp->algorithm[
    prm_sit_idx].component[d.seq].parent_component_id)
    DETAIL
     CALL cv_echo(build("Initial token: ",algcomp->algorithm[prm_sit_idx].component[d.seq].long_text)
     ), token->token[cnt_token].token = algcomp->algorithm[prm_sit_idx].component[d.seq].long_text,
     token->token[cnt_token].type = cv_type_longtext
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_echo(build("Failed in set_initial_token at: ",algcomp->algorithm[prm_sit_idx].description
      ))
    CALL cv_log_message(build("long_text:",token->token[cnt_token].token))
   ENDIF
 END ;Subroutine
 SUBROUTINE process_tokens(prm_idx,prm_comp_type_flag)
   SET loop = 0
   DECLARE offset = i4 WITH noconstant(0), private
   DECLARE ret_str = vc WITH protect, noconstant(fillstring(100," "))
   DECLARE parse_string = vc WITH protect
   DECLARE parse_pos = i4 WITH protect
   DECLARE curparsedone = i2 WITH protect
   DECLARE curpos = i4 WITH protect
   CALL cv_log_message(build("process_tokens - algorithm:",algcomp->algorithm[prm_idx].description,
     " type:",prm_comp_type_flag))
   DECLARE added_longtext = i4 WITH noconstant(1)
   DECLARE operator_size = i4 WITH noconstant(0)
   SET operator_size = size(operator->operator,5)
   SET start = 1
   SET stop = 1
   SET total1 = 0
   SET total2 = 0
   SET t3 = curtime3
   WHILE (added_longtext != 0)
     SET added_longtext = 0
     FOR (i = start TO stop)
       IF ((token->token[i].type=cv_type_longtext))
        SET parse_string = trim(token->token[i].token,3)
        SET parse_pos = 1
        IF (do_echo)
         CALL echo(build("Parsing long_text from index:",i))
         CALL echo(token->token[i].token)
        ENDIF
        WHILE ((parse_pos != - (1)))
          SET t1 = curtime3
          SET curparsedone = 0
          SET curpos = findstring(parse_delimitter,parse_string,parse_pos)
          IF (curpos=0)
           SET curpos = (size(parse_string,1)+ 1)
           SET curparsedone = 1
          ENDIF
          SET ret_str = substring(parse_pos,(curpos - parse_pos),parse_string)
          SET parse_pos = (curpos+ size(parse_delimitter,1))
          IF (curparsedone=1)
           SET parse_pos = - (1)
          ENDIF
          SET total1 = (total1+ (curtime3 - t1))
          SET cnt_token = (cnt_token+ 1)
          IF ((cnt_token > token->size))
           SET token->size = (token->size+ token_alloc_size)
           SET stat = alterlist(token->token,token->size)
          ENDIF
          SET token->token[cnt_token].token = trim(cnvtupper(ret_str),3)
          SET token->token[cnt_token].type = cv_type_pending
          FOR (loop = 1 TO operator_size)
            IF ((token->token[cnt_token].token=operator->operator[loop].operator))
             SET token->token[cnt_token].type = cv_type_operator
             SET loop = operator_size
            ENDIF
          ENDFOR
          IF (do_echo)
           CALL echo(concat("New token:",token->token[cnt_token].token,"  Index:",trim(cnvtstring(
               cnt_token)),"  Type:",
             trim(cnvtstring(token->token[cnt_token].type))))
          ENDIF
        ENDWHILE
       ELSE
        SET cnt_token = (cnt_token+ 1)
        IF ((cnt_token > token->size))
         SET token->size = (token->size+ token_alloc_size)
         SET stat = alterlist(token->token,token->size)
        ENDIF
        SET token->token[cnt_token].token = token->token[i].token
        SET token->token[cnt_token].type = token->token[i].type
        SET token->token[cnt_token].primary_key = token->token[i].primary_key
        IF (do_echo)
         CALL echo(concat("Old token: ",token->token[i].token," Index:",trim(cnvtstring(cnt_token)),
           "  From:",
           trim(cnvtstring(i))))
        ENDIF
       ENDIF
     ENDFOR
     SET t2 = curtime3
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value((cnt_token - stop))),
       (dummyt d2  WITH seq = value(size(algcomp->algorithm[prm_idx].component,5)))
      PLAN (d1
       WHERE (token->token[(stop+ d1.seq)].type=cv_type_pending))
       JOIN (d2
       WHERE (algcomp->algorithm[prm_idx].component[d2.seq].mnemonic=token->token[(d1.seq+ stop)].
       token))
      HEAD REPORT
       l_alg_idx = 0, l_memo_found = 0, l_active_alg_found = 0,
       l_tok_idx = 0
      DETAIL
       l_tok_idx = (d1.seq+ stop), l_alg_idx = prm_idx
       CASE (algcomp->algorithm[l_alg_idx].component[d2.seq].source_name)
        OF str_longtextref:
         token->token[l_tok_idx].type = cv_type_longtext,token->token[l_tok_idx].token = algcomp->
         algorithm[l_alg_idx].component[d2.seq].long_text,
         IF (do_echo)
          CALL echo("Found long_text:"),
          CALL echo(token->token[l_tok_idx].token)
         ENDIF
         ,added_longtext = 1
        OF str_cvxref:
         token->token[l_tok_idx].type = cv_type_xref,token->token[l_tok_idx].primary_key = algcomp->
         algorithm[l_alg_idx].component[d2.seq].source_id
        OF str_cvresponse:
         token->token[l_tok_idx].type = cv_type_response,token->token[l_tok_idx].primary_key =
         algcomp->algorithm[l_alg_idx].component[d2.seq].source_id
       ENDCASE
       IF (do_echo)
        CALL echo(concat("Lookup token:",algcomp->algorithm[prm_idx].component[d2.seq].mnemonic,
         "  Type:",trim(cnvtstring(token->token[l_tok_idx].type)),"  Index:",
         trim(cnvtstring(l_tok_idx)),"  Key:",trim(cnvtstring(token->token[l_tok_idx].primary_key))))
       ENDIF
      WITH nocounter
     ;end select
     CALL cv_echo(build("curqual:",curqual))
     IF (curqual=0)
      CALL echorecord(token)
      CALL echorecord(algcomp)
      CALL cv_log_message(concat("cnt_token:",cnvtstring(cnt_token)," stop:",cnvtstring(stop)))
     ENDIF
     FOR (loop = (stop+ 1) TO cnt_token)
       IF ((token->token[loop].type=cv_type_pending))
        IF (do_echo)
         CALL echo(concat("Operand token:",token->token[loop].token,"  Index:",cnvtstring(loop)))
        ENDIF
        SET token->token[loop].type = 0
       ENDIF
     ENDFOR
     SET total2 = (total2+ (curtime3 - t2))
     SET start = (stop+ 1)
     SET stop = cnt_token
     CALL cv_echo(concat("start:",cnvtstring(start)," stop:",cnvtstring(stop)))
   ENDWHILE
   SET stat = alterlist(token->token,cnt_token)
   SET stat = alterlist(token->token,((cnt_token - start)+ 1),0)
   SET cnt_token = size(token->token,5)
   SET token->size = cnt_token
   CALL cv_log_message(build("Parsing Start:",t3))
   CALL cv_log_message(build("Parsing Stop :",curtime3))
   CALL echo(build("Parsing Started:",t3))
   CALL echo(build("Parsing Stopped:",curtime3))
 END ;Subroutine
 SUBROUTINE get_response_values(cv_dummy)
   CALL cv_log_message("get_response_values")
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(token->token,5))),
     cv_response r
    PLAN (d1
     WHERE (token->token[d1.seq].type=cv_type_response))
     JOIN (r
     WHERE (r.response_id=token->token[d1.seq].primary_key))
    DETAIL
     token->token[d1.seq].cv_response = r.a2
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_echo(build("Failed in get_response_values at: ",token->token[1].cv_response))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_values_from_cv_hrv_rec(cv_dummy)
   DECLARE cdf_meaning = vc WITH protect
   DECLARE task_meaning = vc WITH protect
   SET cdf_meaning = fillstring(12," ")
   CALL cv_log_message("get values from cv_hrv_rec")
   CALL cv_log_message("task_assay_means")
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(token->token,5))),
     (dummyt d2  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
    PLAN (d1
     WHERE (token->token[d1.seq].type=cv_type_xref))
     JOIN (d2
     WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d2.seq].xref_id=token->token[d1.seq].primary_key))
    DETAIL
     token->token[d1.seq].data_idx = d2.seq
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_echo(build("Failed in get_dta_values_from_hrv_rec at: ",token->token[1].token))
   ENDIF
 END ;Subroutine
 SUBROUTINE do_postfix(cv_dummy)
   DECLARE value = vc WITH protect
   DECLARE tok_type = i4 WITH protect
   DECLARE op_num = i4 WITH protect
   SET value = fillstring(50," ")
   CALL cv_log_message("do_postfix")
   SET cnt_stack = 0
   SET stat = alterlist(stack->stack,cnt_stack)
   SET stack->size = 0
   SET total1 = 0
   SET cnt1 = 0
   SET cnt2 = 0
   FOR (i = 1 TO size(token->token,5))
    IF ((token->token[i].type != cv_type_operator))
     SET t1 = curtime3
     CALL get_value(i)
     SET total1 = (total1+ (curtime3 - t1))
     SET tok_type = get_fieldtype(i)
     CALL pushstack(gv_retval,tok_type,i)
     IF (do_echo)
      CALL echo(concat("PUSH(",token->token[i].token,") ===>(",gv_retval,")    type=",
        trim(cnvtstring(tok_type))))
     ENDIF
     SET cnt1 = (cnt1+ 1)
    ELSE
     CASE (token->token[i].token)
      OF "+":
       CALL perform_add(i)
       SET op_num = 1
      OF "-":
       CALL perform_subtract(i)
       SET op_num = 2
      OF "*":
       CALL perform_multiply(i)
       SET op_num = 3
      OF "/":
       CALL perform_divide(i)
       SET op_num = 4
      OF "^":
       CALL perform_exponent(i)
       SET op_num = 5
      OF "EXP":
       CALL perform_nl(i)
       SET op_num = 6
      OF "IF":
       CALL perform_if(i)
       SET op_num = 7
      OF "=":
       CALL perform_equal(i)
       SET op_num = 8
      OF "<":
       CALL perform_less_than(i)
       SET op_num = 9
      OF "<=":
       CALL perform_less_than_or_equal(i)
       SET op_num = 10
      OF ">":
       CALL perform_greater_than(i)
       SET op_num = 11
      OF ">=":
       CALL perform_greater_than_or_equal(i)
       SET op_num = 12
      OF "!=":
       CALL perform_not_equal(i)
       SET op_num = 13
      OF "DUP":
       CALL perform_duplicate(i)
       SET op_num = 14
      OF "MIN":
       CALL perform_minimum(i)
       SET op_num = 15
      OF "MAX":
       CALL perform_maximum(i)
       SET op_num = 16
     ENDCASE
     SET cnt2 = (cnt2+ 1)
    ENDIF
    IF (cnt_stack <= 0)
     CALL cv_log_message("STACK EMPTY. ABORTING")
     SET i = size(token->token,5)
    ENDIF
   ENDFOR
   SET stat = alterlist(stack->stack,cnt_stack)
   SET stack->size = cnt_stack
   IF (cnt_stack != 1)
    CALL cv_echo("**********************************************************")
    CALL cv_log_message(build("Invalid Stack Count. Should be 1:",cnt_stack))
    CALL cv_log_message("Dumping token to cer_temp:cv_token.dat:")
    CALL echorecord(token,"cer_temp:cv_token.dat")
    CALL cv_log_message("Dumping Stack to cer_temp:cv_stack.dat:")
    CALL echorecord(stack,"cer_temp:cv_stack.dat")
    CALL cv_log_message("Dumping algcomp to cer_temp:cv_algcomp.dat:")
    CALL echorecord(algcomp,"cer_temp:cv_algcomp.dat")
    CALL cv_echo("**********************************************************")
   ELSE
    CALL cv_echo(concat("stack->stack[1].value=",stack->stack[1].value))
   ENDIF
   CALL cv_log_message(build("cnt1:",cnt1," cnt2:",cnt2))
 END ;Subroutine
 SUBROUTINE popstack2(result)
  SET result = trim(stack->stack[cnt_stack].value,3)
  SET cnt_stack = (cnt_stack - 1)
 END ;Subroutine
 SUBROUTINE pushstack(psvalue,pstype,pstoken)
   SET cnt_stack = (cnt_stack+ 1)
   IF ((cnt_stack > stack->size))
    SET stack->size = (stack->size+ stack_alloc_size)
    SET stat = alterlist(stack->stack,stack->size)
   ENDIF
   SET stack->stack[cnt_stack].token_idx = pstoken
   SET stack->stack[cnt_stack].value = psvalue
   SET stack->stack[cnt_stack].type = pstype
   RETURN(0)
 END ;Subroutine
 SUBROUTINE perform_add(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     SET pushval = format((lnumval+ rnumval),"#################.#######;L;F")
     IF (do_echo)
      CALL echo(concat("+ (",lstrval,",",rstrval,")===>(",
        pushval,")"))
     ENDIF
     CALL pushstack(pushval,cv_number,0)
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, + date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, + string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_subtract(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (get_operands_fieldtype(2))
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     SET pushval = format((lnumval - rnumval),"#################.#######;L;F")
     IF (do_echo)
      CALL echo(concat("- (",lstrval,",",rstrval,")===>(",
        pushval,")"))
     ENDIF
     CALL pushstack(pushval,cv_number,0)
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, - date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, - string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_multiply(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     SET pushval = format((lnumval * rnumval),"#################.#######;L;F")
     IF (do_echo)
      CALL echo(concat("* (",lstrval,",",rstrval,")===>(",
        pushval,")"))
     ENDIF
     CALL pushstack(pushval,cv_number,0)
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, * date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, * string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_divide(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (rnumval != 0)
      SET pushval = format((lnumval/ rnumval),"#################.#######;L;F")
      IF (do_echo)
       CALL echo(concat("/ (",lstrval,",",rstrval,")===>(",
         pushval,")"))
      ENDIF
      CALL pushstack(pushval,cv_number,0)
     ELSE
      CALL cv_log_message(build("Divide by zero, index:",index))
      CALL pushstack("0",cv_number)
     ENDIF
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, / date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, / string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_exponent(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     SET pushval = format((lnumval** rnumval),"#################.#######;L;F")
     IF (do_echo)
      CALL echo(concat("**(",lstrval,",",rstrval,")===>(",
        pushval,")"))
     ENDIF
     CALL pushstack(pushval,cv_number,0)
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, ** date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, ** string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_nl(index)
   SET operands_fieldtype = get_operands_fieldtype(1)
   CALL popstack2(rstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET pushval = format(exp(rnumval),"#################.#######;L;F")
     IF (do_echo)
      CALL echo(concat("EXP(",rstrval,")===>(",pushval,")"))
     ENDIF
     CALL pushstack(pushval,cv_number,0)
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, nl date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, nl string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_if(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(mstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval)
      IF (do_echo)
       CALL echo(concat("IF(",lstrval,",",mstrval,",",
         rstrval,")===>",mstrval))
      ENDIF
      CALL pushstack(mstrval,cv_number,0)
     ELSE
      IF (do_echo)
       CALL echo(concat("IF(",lstrval,",",mstrval,",",
         rstrval,")===>",rstrval))
      ENDIF
      CALL pushstack(rstrval,cv_number,0)
     ENDIF
    OF cv_date:
     CALL cv_log_message(build("Unsupported calculation, if date. Index:",index))
    OF cv_string:
     CALL cv_log_message(build("Unsupported calculation, if string. Index:",index))
   ENDCASE
 END ;Subroutine
 SUBROUTINE perform_equal(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval=rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval=rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval=rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("EQ(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_less_than(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval < rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval < rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval < rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("LT(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_less_than_or_equal(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval <= rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval <= rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval <= rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("LE(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_greater_than(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval > rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval > rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval > rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("GT(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_greater_than_or_equal(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval >= rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval >= rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval >= rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("GE(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_not_equal(index)
   SET pushval = "0"
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   CASE (operands_fieldtype)
    OF cv_number:
     SET rnumval = cnvtreal(rstrval)
     SET lnumval = cnvtreal(lstrval)
     IF (lnumval != rnumval)
      SET pushval = "1"
     ENDIF
    OF cv_date:
     SET rdateval = cnvtdate2(cnvtalphanum(rstrval),"MMDDYYYY")
     SET ldateval = cnvtdate2(cnvtalphanum(lstrval),"MMDDYYYY")
     IF (ldateval != rdateval)
      SET pushval = "1"
     ENDIF
    OF cv_string:
     IF (lstrval != rstrval)
      SET pushval = "1"
     ENDIF
   ENDCASE
   IF (do_echo)
    CALL echo(concat("NE(",lstrval,",",rstrval,")===>(",
      pushval,")    type=",trim(cnvtstring(operands_fieldtype))))
   ENDIF
   CALL pushstack(pushval,cv_number,0)
 END ;Subroutine
 SUBROUTINE perform_duplicate(index)
   SET operands_fieldtype = get_operands_fieldtype(1)
   CALL popstack2(rstrval)
   CALL pushstack(rstrval,operands_fieldtype,0)
   CALL pushstack(rstrval,operands_fieldtype,0)
   IF (do_echo)
    CALL echo(concat("Duplicated:",rstrval," with type ",cnvtstring(operands_fieldtype)))
   ENDIF
 END ;Subroutine
 SUBROUTINE perform_minimum(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   SET rnumval = cnvtreal(rstrval)
   SET lnumval = cnvtreal(lstrval)
   IF (rnumval > lnumval)
    CALL pushstack(lstrval,cv_number,0)
    IF (do_echo)
     CALL echo(build("MIN(",rnumval,",",lnumval,")===>",
       lstrval))
    ENDIF
   ELSE
    CALL pushstack(rstrval,cv_number,0)
    IF (do_echo)
     CALL echo(build("MIN(",rnumval,",",lnumval,")===>",
       rstrval))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE perform_maximum(index)
   SET operands_fieldtype = get_operands_fieldtype(2)
   CALL popstack2(rstrval)
   CALL popstack2(lstrval)
   SET rnumval = cnvtreal(rstrval)
   SET lnumval = cnvtreal(lstrval)
   IF (rnumval < lnumval)
    CALL pushstack(lstrval,cv_number,0)
    IF (do_echo)
     CALL echo(build("MAX(",rnumval,",",lnumval,")===>",
       lstrval))
    ENDIF
   ELSE
    CALL pushstack(rstrval,cv_number,0)
    IF (do_echo)
     CALL echo(build("MAX(",rnumval,",",lnumval,")===>",
       rstrval))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_value(index)
   SET gv_retval = fillstring(50," ")
   CASE (token->token[index].type)
    OF cv_type_xref:
     IF ((token->token[index].data_idx > 0)
      AND (cv_hrv_rec->harvest_rec[1].abstr_data[token->token[index].data_idx].valid_flag > 0))
      SET field_type_meaning = cnvtupper(trim(cv_hrv_rec->harvest_rec[1].abstr_data[token->token[
        index].data_idx].field_type_meaning,3))
      IF (field_type_meaning != "DATE")
       IF (size(trim(cv_hrv_rec->harvest_rec[1].abstr_data[token->token[index].data_idx].
         translated_value,3),1) > 0)
        SET gv_retval = trim(cv_hrv_rec->harvest_rec[1].abstr_data[token->token[index].data_idx].
         translated_value)
       ENDIF
      ELSE
       SET gv_retval = format(cv_hrv_rec->harvest_rec[1].abstr_data[token->token[index].data_idx].
        result_dt_tm,"MMDDYYYY;;D")
      ENDIF
     ENDIF
    OF cv_type_response:
     SET gv_retval = token->token[index].cv_response
    OF cv_type_operand:
     SET gv_retval = token->token[index].token
   ENDCASE
   SET token->token[index].value = gv_retval
 END ;Subroutine
 SUBROUTINE get_fieldtype(index)
   DECLARE fieldtype = i4 WITH protect, noconstant(cv_number)
   IF ((token->token[index].data_idx > 0)
    AND (token->token[index].type=cv_type_xref))
    SET field_type_meaning = trim(cv_hrv_rec->harvest_rec[1].abstr_data[token->token[index].data_idx]
     .field_type_meaning,3)
    IF (field_type_meaning="DATE")
     SET fieldtype = cv_date
    ELSEIF (((field_type_meaning="STRING") OR (field_type_meaning="ALPHA")) )
     SET fieldtype = cv_string
    ENDIF
   ENDIF
   RETURN(fieldtype)
 END ;Subroutine
 SUBROUTINE get_operands_fieldtype(nbr_operands)
   DECLARE j = i4 WITH protect
   SET j = ((cnt_stack - nbr_operands)+ 1)
   DECLARE done_type = i2 WITH protect, noconstant(0)
   DECLARE ft_retval = i4 WITH protect, noconstant(cv_number)
   WHILE (j <= cnt_stack
    AND  NOT (done_type))
    IF ((stack->stack[j].type != cv_number))
     SET ft_retval = stack->stack[j].type
     SET done_type = 1
    ENDIF
    SET j = (j+ 1)
   ENDWHILE
   RETURN(ft_retval)
 END ;Subroutine
 SUBROUTINE get_person_info(cv_dummy)
   CALL cv_log_message("get person username and id")
   SELECT INTO "NL:"
    FROM cv_case c,
     dcp_forms_activity d,
     prsnl p
    PLAN (c
     WHERE (c.cv_case_id=cv_hrv_rec->harvest_rec[1].case_id)
      AND c.form_id != 0.0)
     JOIN (d
     WHERE d.dcp_forms_activity_id=c.form_id)
     JOIN (p
     WHERE p.person_id=d.updt_id)
    DETAIL
     person_username = p.username, person_id = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message(build("Discern Notify UserName not found for cv_case_id:",cv_hrv_rec->
      harvest_rec[1].case_id))
   ELSE
    CALL cv_log_message(build("Discern Notify UserName:",person_username," count:",curqual,
      " person_id:",
      person_id))
   ENDIF
 END ;Subroutine
 SUBROUTINE post_to_clinical_event(cv_dummy)
   CALL cv_log_message("post_to_clinical_event")
   CALL cv_log_message(build("person_id:",cv_hrv_rec->harvest_rec[1].person_id," encounter:",
     cv_hrv_rec->harvest_rec[1].encntr_id))
   CALL get_code_values_from_meanings(0)
   DECLARE msg = vc WITH protect
   DECLARE contributor_system_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(89,"POWERCHART",1,contributor_system_cd)
   IF (contributor_system_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning named POWERCHART under codeset 89 in database.")
    RETURN
   ENDIF
   DECLARE num_format_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(14113,"NUMERIC",1,num_format_cd)
   IF (num_format_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning named NUMERIC under codeset 14113in the database.")
   ENDIF
   DECLARE alpha_format_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(14113,"ALPHA",1,alpha_format_cd)
   IF (alpha_format_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning named ALPHA under codeset 14113in the database.")
   ENDIF
   DECLARE num_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(53,"NUM",1,num_cd)
   IF (num_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - NUM under code_set 53 in the database")
   ENDIF
   DECLARE text_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(53,"TXT",1,text_cd)
   IF (text_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - TXT under code_set 53 in the database")
   ENDIF
   DECLARE modified_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(8,"MODIFIED",1,modified_cd)
   IF (modified_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - MODIFIED under code_set 8 in the database")
   ENDIF
   DECLARE dcpgeneric_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(72,"DCPGENERIC",1,dcpgeneric_cd)
   IF (dcpgeneric_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - DCPGENERIC under code_set 72 in the database")
   ENDIF
   DECLARE event_reltn_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(24,"ROOT",1,event_reltn_cd)
   IF (event_reltn_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - ROOT under code_set 24 in the database")
   ENDIF
   DECLARE action_status_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(103,"COMPLETED",1,action_status_cd)
   IF (action_status_cd <= 0.0)
    SET msg = "There is no cdf_meaning named COMPLETED under codeset 103 in the database."
   ENDIF
   DECLARE action_type_cd_v = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(21,"VERIFY",1,action_type_cd_v)
   IF (action_type_cd_v <= 0.0)
    SET msg = "There is no cdf_meaning named VERIFY under codeset 21 in the database."
   ENDIF
   DECLARE action_type_cd_p = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(21,"PERFORM",1,action_type_cd_p)
   IF (action_type_cd_p <= 0.0)
    SET msg = "There is no cdf_meaning named PERFORM under codeset 21 in the database."
   ENDIF
   DECLARE action_type_cd_m = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(21,"MODIFY",1,action_type_cd_m)
   IF (action_type_cd_m <= 0.0)
    SET msg = "There is no cdf_meaning named MODIFY under codeset 21 in the database."
   ENDIF
   DECLARE grp_cd = f8 WITH protect, noconstant(0.0)
   SET iret = uar_get_meaning_by_codeset(53,"GRP",1,grp_cd)
   IF (grp_cd <= 0.0)
    SET msg = "There is no cdf_meaning named GRP under codeset 53 in the database."
   ENDIF
   SELECT INTO "NL:"
    dfr.description
    FROM name_value_prefs nvr,
     dcp_input_ref dir,
     dcp_section_ref dsr,
     dcp_forms_def dfd,
     dcp_forms_ref dfr,
     dcp_forms_activity dfa,
     cv_case cc
    PLAN (cc
     WHERE (cc.cv_case_id=cv_hrv_rec->harvest_rec[1].case_id))
     JOIN (dfa
     WHERE dfa.dcp_forms_activity_id=cc.form_id
      AND dfa.active_ind=1)
     JOIN (dfr
     WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
      AND dfr.active_ind=1)
     JOIN (dfd
     WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
      AND dfd.active_ind=1)
     JOIN (dsr
     WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
      AND dsr.active_ind=1)
     JOIN (dir
     WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
      AND dir.active_ind=1)
     JOIN (nvr
     WHERE nvr.parent_entity_name="DCP_INPUT_REF"
      AND nvr.parent_entity_id=dir.dcp_input_ref_id
      AND nvr.merge_name="DISCRETE_TASK_ASSAY"
      AND trim(nvr.pvc_name)="discrete_task_assay"
      AND expand(idx,1,size(algcomp->algorithm,5),nvr.merge_id,algcomp->algorithm[idx].task_assay_cd)
      AND nvr.active_ind=1)
    ORDER BY dsr.dcp_section_ref_id, dir.dcp_input_ref_id
    HEAD REPORT
     sec_cnt = 0
    HEAD dsr.dcp_section_ref_id
     input_cnt = 0, sec_cnt = (sec_cnt+ 1)
     IF (mod(sec_cnt,10)=1)
      stat = alterlist(sections->seclist,(sec_cnt+ 9))
     ENDIF
     sections->seclist[sec_cnt].sect_name = trim(dsr.description,3), sections->seclist[sec_cnt].
     sect_collating_seq = format(dsr.dcp_section_ref_id,"##########;P0;F")
    HEAD dir.dcp_input_ref_id
     col 0
    DETAIL
     index = locateval(num,1,size(algcomp->algorithm,5),nvr.merge_id,algcomp->algorithm[num].
      task_assay_cd), algcomp->algorithm[index].form_collating_seq = format(dfd.dcp_forms_ref_id,
      "##########;P0;F"), algcomp->algorithm[index].form_name = trim(dfr.description,3),
     alg_form_name = algcomp->algorithm[index].form_name, alg_form_collating_seq = algcomp->
     algorithm[index].form_collating_seq
    FOOT  dir.dcp_input_ref_id
     input_cnt = (input_cnt+ 1)
     IF (mod(input_cnt,10)=1)
      stat = alterlist(sections->seclist[sec_cnt].inputlist,(input_cnt+ 9))
     ENDIF
     sections->seclist[sec_cnt].inputlist[input_cnt].input_name = trim(dir.description,3), sections->
     seclist[sec_cnt].inputlist[input_cnt].input_collating_seq = format(dir.input_ref_seq,
      "##########;P0;F"), sections->seclist[sec_cnt].inputlist[input_cnt].task_assay_cd = algcomp->
     algorithm[index].task_assay_cd
    FOOT  dsr.dcp_section_ref_id
     stat = alterlist(sections->seclist[sec_cnt].inputlist,input_cnt)
     IF ((input_cnt > sections->max_input))
      sections->max_input = input_cnt
     ENDIF
    FOOT REPORT
     stat = alterlist(sections->seclist,sec_cnt)
     IF ((sec_cnt > sections->max_sec))
      sections->max_sec = sec_cnt
     ENDIF
     CALL cv_log_message(build("form:",algcomp->algorithm[index].input_name))
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sections->max_sec)),
     (dummyt d1  WITH seq = value(sections->max_input)),
     discrete_task_assay dta
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(sections->seclist[d.seq].inputlist,5))
     JOIN (dta
     WHERE (dta.task_assay_cd=sections->seclist[d.seq].inputlist[d1.seq].task_assay_cd))
    DETAIL
     sections->seclist[d.seq].inputlist[d1.seq].event_cd = dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("Failed in getting event_cds!")
   ENDIF
   CALL echorecord(sections,"cer_temp:cv_sections.dat")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(algcomp->algorithm,5))),
     discrete_task_assay dta
    PLAN (d
     WHERE (algcomp->algorithm[d.seq].task_assay_cd > 0.0))
     JOIN (dta
     WHERE (dta.task_assay_cd=algcomp->algorithm[d.seq].task_assay_cd))
    DETAIL
     algcomp->algorithm[d.seq].event_cd = dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_echo("Failed in getting event_cds!")
   ENDIF
   DECLARE peid_grandparent = f8 WITH protect, noconstant(cv_hrv_rec->harvest_rec[1].
    top_parent_event_id)
   DECLARE clinical_event_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    c.event_id
    FROM (dummyt d  WITH seq = value(size(sections->seclist,5))),
     clinical_event c
    PLAN (d)
     JOIN (c
     WHERE c.event_title_text=trim(sections->seclist[d.seq].sect_name,3)
      AND c.parent_event_id=peid_grandparent)
    DETAIL
     sections->seclist[d.seq].peid_parent = c.event_id,
     CALL cv_echo(build("peid_parent: ",c.event_id))
    WITH nocounter
   ;end select
   IF ((sections->max_sec > 0)
    AND (sections->max_input > 0))
    SELECT INTO "nl:"
     ce.event_id
     FROM (dummyt d  WITH seq = value(sections->max_sec)),
      (dummyt d1  WITH seq = value(sections->max_input)),
      clinical_event ce
     PLAN (d)
      JOIN (d1
      WHERE d1.seq <= size(sections->seclist[d.seq].inputlist,5))
      JOIN (ce
      WHERE (ce.parent_event_id=sections->seclist[d.seq].peid_parent)
       AND (ce.event_cd=sections->seclist[d.seq].inputlist[d1.seq].event_cd))
     DETAIL
      sections->seclist[d.seq].inputlist[d1.seq].peid_child = ce.event_id,
      CALL cv_echo(build("peid_child: ",ce.event_id)), clinical_event_id = ce.clinical_event_id
     WITH nocounter
    ;end select
   ENDIF
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    CALL cv_log_message("uar_crm_begin_app failed in post_to_clinical_event")
    RETURN
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    CALL cv_log_message("uar_crm_begin_task failed in post_to_clinical_event")
    IF (happ)
     CALL uar_crmendapp(happ)
     SET happ = 0
    ENDIF
    RETURN
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    CALL cv_log_message("uar_crm_begin_req failed in post_to_clinical_event")
    IF (htask)
     CALL uar_crmendtask(htask)
     SET htask = 0
    ENDIF
    IF (happ)
     CALL uar_crmendapp(happ)
     SET happ = 0
    ENDIF
    RETURN
   ENDIF
   IF ((sections->max_sec > 0)
    AND (sections->max_input > 0))
    SELECT INTO "nl:"
     task_assay = algcomp->algorithm[d2.seq].task_assay_cd
     FROM (dummyt d  WITH seq = value(sections->max_sec)),
      (dummyt d1  WITH seq = value(sections->max_input)),
      (dummyt d2  WITH seq = value(size(algcomp->algorithm,5)))
     PLAN (d)
      JOIN (d1
      WHERE d1.seq <= size(sections->seclist[d.seq].inputlist,5))
      JOIN (d2
      WHERE (algcomp->algorithm[d2.seq].task_assay_cd=sections->seclist[d.seq].inputlist[d1.seq].
      task_assay_cd)
       AND (algcomp->algorithm[d2.seq].event_cd=sections->seclist[d.seq].inputlist[d1.seq].event_cd))
     ORDER BY task_assay
     HEAD task_assay
      IF (size(trim(algcomp->algorithm[d2.seq].result_val,3)) > 0)
       sections->seclist[d.seq].inputlist[d1.seq].result_val = trim(algcomp->algorithm[d2.seq].
        result_val,3)
      ELSE
       sections->seclist[d.seq].inputlist[d1.seq].result_val = "0.0000000"
      ENDIF
     DETAIL
      IF (cnvtreal(trim(algcomp->algorithm[d2.seq].result_val,3)) > cnvtreal(sections->seclist[d.seq]
       .inputlist[d1.seq].result_val))
       sections->seclist[d.seq].inputlist[d1.seq].result_val = trim(algcomp->algorithm[d2.seq].
        result_val,3)
      ENDIF
      CALL cv_echo(build("Final Result_Val: ",sections->seclist[d.seq].inputlist[d1.seq].result_val)),
      CALL cv_echo(build("Final d.seq: ",d.seq)),
      CALL cv_echo(build("Final d1.seq: ",d1.seq)),
      CALL cv_echo("*************************************************")
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_echo("Result_val in record sections not initialized!")
    ENDIF
   ENDIF
   CALL cv_log_message("setup for event ensure")
   CALL cv_echo(build("person_id: ",cv_hrv_rec->harvest_rec[1].person_id))
   CALL cv_echo(build("encntr_id: ",cv_hrv_rec->harvest_rec[1].encntr_id))
   CALL cv_echo(build("contributor_system_cd: ",contributor_system_cd))
   CALL cv_echo(build("event_class_cd: ",grp_cd))
   CALL cv_echo(build("event_cd: ",dcpgeneric_cd))
   CALL cv_echo(build("event_reltn_cd: ",event_reltn_cd))
   CALL cv_echo(build("event_end_dt_tm: ",cnvtdatetime(curdate,curtime3)))
   CALL cv_echo(build("record_status_cd: ",record_status_cd))
   CALL cv_echo(build("result_status_cd: ",modified_cd))
   CALL cv_echo(build("event_title_text: ",alg_form_name))
   CALL cv_echo(build("collating_seq: ",alg_form_collating_seq))
   CALL cv_echo(build("event_id: ",peid_grandparent))
   CALL cv_echo(build("clinical_event_id: ",clinical_event_id))
   CALL cv_echo(build("action_type_cd: ",action_type_cd_v))
   CALL cv_echo(build("action_dt_tm: ",cnvtdatetime(curdate,curtime3)))
   CALL cv_echo(build("action_prsnl_id: ",person_id))
   CALL cv_echo(build("action_status_cd: ",action_status_cd))
   CALL cv_echo(build("child_event_list: ",hcetype))
   CALL cv_echo(build("vent_class_cd: ",num_cd))
   CALL cv_echo(build("action_type_cd: ",action_type_cd_p))
   CALL cv_echo(build("string_result_format_cd: ",num_format_cd))
   CALL cv_echo(build("action_prsnl_id: ",person_id))
   CALL cv_echo(build("action_status_cd: ",action_status_cd))
   CALL cv_echo("dump record into cer_temp:cv_sec_bf_upd.dat")
   CALL echorecord(sections,"cer_temp:cv_sec_bf_upd.dat")
   CALL cv_echo("dump record into cer_temp:cv_algcomp_bf.dat")
   CALL echorecord(algcomp,"cer_temp:cv_algcomp_bf.dat")
   CALL cv_echo("****************************************************")
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstat = uar_srvsetshort(hreq,"ensure_type",2)
   SET hstce = uar_srvgetstruct(hreq,"clin_event")
   SET srvstat = uar_srvsetdouble(hstce,"person_id",cv_hrv_rec->harvest_rec[1].person_id)
   SET srvstat = uar_srvsetdouble(hstce,"encntr_id",cv_hrv_rec->harvest_rec[1].encntr_id)
   SET srvstat = uar_srvsetdouble(hstce,"contributor_system_cd",contributor_system_cd)
   SET srvstat = uar_srvsetdouble(hstce,"event_class_cd",grp_cd)
   SET srvstat = uar_srvsetdouble(hstce,"event_cd",dcpgeneric_cd)
   SET srvstat = uar_srvsetdouble(hstce,"event_reltn_cd",event_reltn_cd)
   SET srvstat = uar_srvsetdate(hstce,"event_end_dt_tm",cnvtdatetime(curdate,curtime3))
   SET srvstat = uar_srvsetdouble(hstce,"record_status_cd",record_status_cd)
   SET srvstat = uar_srvsetdouble(hstce,"result_status_cd",modified_cd)
   SET srvstat = uar_srvsetshort(hstce,"authentic_flag",1)
   SET srvstat = uar_srvsetshort(hstce,"publish_flag",1)
   SET srvstat = uar_srvsetstring(hstce,"event_title_text",nullterm(trim(alg_form_name,3)))
   SET srvstat = uar_srvsetstring(hstce,"collating_seq",nullterm(trim(alg_form_collating_seq,3)))
   SET srvstat = uar_srvsetdouble(hstce,"event_id",peid_grandparent)
   SET srvstat = uar_srvsetdouble(hstce,"parent_event_id",peid_grandparent)
   SET srvstat = uar_srvsetdouble(hstce,"clinical_event_id",clinical_event_id)
   SET hlsep = uar_srvadditem(hstce,"event_prsnl_list")
   SET srvstat = uar_srvsetdouble(hlsep,"action_type_cd",action_type_cd_v)
   SET srvstat = uar_srvsetdate(hlsep,"action_dt_tm",cnvtdatetime(curdate,curtime3))
   SET srvstat = uar_srvsetdouble(hlsep,"action_prsnl_id",person_id)
   SET srvstat = uar_srvsetdouble(hlsep,"action_status_cd",action_status_cd)
   SET hcetype = uar_srvcreatetypefrom(hreq,"clin_event")
   SET hcestruct = uar_srvgetstruct(hreq,"clin_event")
   CALL uar_srvbinditemtype(hcestruct,"child_event_list",hcetype)
   CALL cv_echo(build("sec_sz: ",size(sections->seclist,5)))
   FOR (secidx = 1 TO size(sections->seclist,5))
     CALL cv_echo(build("sect_name: ",sections->seclist[secidx].sect_name))
     CALL cv_echo(build("peid_parent: ",sections->seclist[secidx].peid_parent))
     CALL cv_echo(build("collating_seq: ",sections->seclist[secidx].sect_collating_seq))
     SET hce = uar_srvadditem(hcestruct,"child_event_list")
     CALL uar_srvbinditemtype(hce,"child_event_list",hcetype)
     SET srvstat = uar_srvsetdouble(hce,"person_id",cv_hrv_rec->harvest_rec[1].person_id)
     SET srvstat = uar_srvsetdouble(hce,"encntr_id",cv_hrv_rec->harvest_rec[1].encntr_id)
     SET srvstat = uar_srvsetdouble(hce,"contributor_system_cd",contributor_system_cd)
     SET srvstat = uar_srvsetdouble(hce,"event_class_cd",grp_cd)
     SET srvstat = uar_srvsetdouble(hce,"event_cd",dcpgeneric_cd)
     SET srvstat = uar_srvsetdate(hce,"event_end_dt_tm",cnvtdatetime(curdate,curtime3))
     SET srvstat = uar_srvsetdouble(hce,"record_status_cd",record_status_cd)
     SET srvstat = uar_srvsetdouble(hce,"result_status_cd",modified_cd)
     SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
     SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
     SET srvstat = uar_srvsetstring(hce,"event_title_text",nullterm(trim(sections->seclist[secidx].
        sect_name,3)))
     SET srvstat = uar_srvsetstring(hce,"collating_seq",nullterm(trim(sections->seclist[secidx].
        sect_collating_seq,3)))
     SET srvstat = uar_srvsetdouble(hce,"event_id",sections->seclist[secidx].peid_parent)
     FOR (inputidx = 1 TO size(sections->seclist[secidx].inputlist,5))
       CALL cv_echo(build("Input size: ",size(sections->seclist[secidx].inputlist,5)))
       SET hce2 = uar_srvadditem(hce,"child_event_list")
       CALL uar_srvbinditemtype(hce2,"child_event_list",hcetype)
       CALL cv_echo(build("event_cd: ",sections->seclist[secidx].inputlist[inputidx].event_cd))
       CALL cv_echo(build("task_assay_cd: ",sections->seclist[secidx].inputlist[inputidx].
         task_assay_cd))
       CALL cv_echo(build("peid_child: ",sections->seclist[secidx].inputlist[inputidx].peid_child))
       CALL cv_echo(build("value: ",sections->seclist[secidx].inputlist[inputidx].result_val))
       SET srvstat = uar_srvsetlong(hce2,"view_level",1)
       SET srvstat = uar_srvsetdouble(hce2,"person_id",cv_hrv_rec->harvest_rec[1].person_id)
       SET srvstat = uar_srvsetdouble(hce2,"encntr_id",cv_hrv_rec->harvest_rec[1].encntr_id)
       SET srvstat = uar_srvsetdouble(hce2,"contributor_system_cd",contributor_system_cd)
       SET srvstat = uar_srvsetdouble(hce2,"event_class_cd",num_cd)
       SET srvstat = uar_srvsetdouble(hce2,"event_cd",sections->seclist[secidx].inputlist[inputidx].
        event_cd)
       SET srvstat = uar_srvsetdate(hce2,"event_end_dt_tm",cnvtdatetime(curdate,curtime3))
       SET srvstat = uar_srvsetdouble(hce2,"task_assay_cd",sections->seclist[secidx].inputlist[
        inputidx].task_assay_cd)
       SET srvstat = uar_srvsetdouble(hce2,"record_status_cd",record_status_cd)
       SET srvstat = uar_srvsetdouble(hce2,"result_status_cd",modified_cd)
       SET srvstat = uar_srvsetshort(hce2,"authentic_flag",1)
       SET srvstat = uar_srvsetshort(hce2,"publish_flag",1)
       SET srvstat = uar_srvsetstring(hce2,"event_title_text",nullterm(trim(sections->seclist[secidx]
          .inputlist[inputidx].input_name,3)))
       SET srvstat = uar_srvsetstring(hce2,"collating_seq",trim(sections->seclist[secidx].inputlist[
         inputidx].input_collating_seq,3))
       SET srvstat = uar_srvsetdouble(hce2,"event_id",sections->seclist[secidx].inputlist[inputidx].
        peid_child)
       SET hce3 = uar_srvadditem(hce2,"string_result")
       SET srvstat = uar_srvsetstring(hce3,"string_result_text",nullterm(trim(sections->seclist[
          secidx].inputlist[inputidx].result_val,3)))
       SET srvstat = uar_srvsetdouble(hce3,"string_result_format_cd",num_format_cd)
       SET hce4 = uar_srvadditem(hce2,"event_prsnl_list")
       SET srvstat = uar_srvsetdouble(hce4,"action_type_cd",action_type_cd_p)
       SET srvstat = uar_srvsetdate(hce4,"action_dt_tm",cnvtdatetime(curdate,curtime3))
       SET srvstat = uar_srvsetdouble(hce4,"action_prsnl_id",person_id)
       SET srvstat = uar_srvsetdouble(hce4,"action_status_cd",action_status_cd)
     ENDFOR
   ENDFOR
   SET iret = uar_crmperform(hstep)
   CALL cv_log_message(build("uar_CrmPerform returned:",iret))
   IF (hcetype)
    CALL uar_srvdestroytype(hcetype)
    SET hreq = 0
   ENDIF
   IF (hstep)
    CALL uar_crmendreq(hstep)
    SET hstep = 0
   ENDIF
   IF (htask)
    CALL uar_crmendtask(htask)
    SET htask = 0
   ENDIF
   IF (happ)
    CALL uar_crmendapp(happ)
    SET happ = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE discern_notify(model,result)
   DECLARE pref_name = c25 WITH protect, constant("DISCERN_NOTIFY")
   DECLARE pref_sec = c25 WITH protect, constant("HARVEST")
   DECLARE pref_dom = c25 WITH protect, constant("CVNET")
   DECLARE call_notify = c1 WITH protect, noconstant("F")
   DECLARE discern_message = vc WITH protect
   SELECT INTO "nl:"
    FROM dm_prefs dp
    PLAN (dp
     WHERE dp.pref_section=pref_sec
      AND dp.pref_name=pref_name
      AND dp.pref_domain=pref_dom)
    DETAIL
     IF (dp.pref_nbr=0)
      call_notify = "T"
     ENDIF
    WITH nocounter
   ;end select
   CALL cv_echo(build("Call discern notify is set to: ",call_notify))
   IF (call_notify="T")
    GO TO exit_script
   ENDIF
   IF (person_id=0.0)
    CALL cv_log_message("Discern notification not sent, person_id is 0")
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
    WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PLNAME")
    DETAIL
     name_last = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
    WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PFNAME")
    DETAIL
     name_first = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
    WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].field_type_meaning="PMNAME")
    DETAIL
     name_middle = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
    WHERE (cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].task_assay_mean IN ("ST01SURGDT",
    "ST03SURGDT"))
    DETAIL
     surg_dt = cv_hrv_rec->harvest_rec[1].abstr_data[d.seq].result_val
    WITH nocounter
   ;end select
   SET discern_message = concat(model,char(13),char(10))
   SET discern_message = concat(discern_message,trim(result,3),char(13),char(10))
   SET discern_message = concat(discern_message,"Patient: ",name_last,", ",name_first,
    " ",name_middle,char(13),char(10))
   SET discern_message = concat(discern_message,"Date of Surgery: ",surg_dt,char(13),char(10))
   SET discern_message = concat(discern_message,"Chart Time: ",format(cv_hrv_rec->harvest_rec[1].
     case_dt_tm,"@LONGDATETIME"))
   CALL cv_log_message(build("discern_notify:",discern_message))
   EXECUTE eks_send_notify value(person_username), "REPLY", "STS Evaluation",
   value(discern_message), "100"
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_code_values_from_meanings(cv_dummy)
   SET record_status_cd = 0.0
   SET iret = uar_get_meaning_by_codeset(48,"ACTIVE",1,record_status_cd)
   IF (record_status_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning named ACTIVE under codeset 48 in database.")
    RETURN
   ENDIF
   SET result_status_cd = 0.0
   SET iret = uar_get_meaning_by_codeset(8,"AUTH",1,result_status_cd)
   IF (result_status_cd <= 0.0)
    CALL cv_log_message("There is no cdf_meaning - AUTH under code_set 8 in the database")
   ENDIF
 END ;Subroutine
 SUBROUTINE post_to_cv_case_abstr_data(cv_dummy)
   CALL cv_log_message("post_to_cv_case_abstr_data - start")
   SET result_status_cd = 0.0
   SET record_status_cd = 0.0
   CALL get_code_values_from_meanings(0)
   DECLARE alg_sz = i4 WITH protect, noconstant(size(algcomp->algorithm,5))
   CALL cv_echo(build("algcomp_size: ",alg_sz))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(algcomp->algorithm,5))),
     discrete_task_assay dta
    PLAN (d1
     WHERE (algcomp->algorithm[d1.seq].task_assay_cd > 0.0))
     JOIN (dta
     WHERE (dta.task_assay_cd=algcomp->algorithm[d1.seq].task_assay_cd))
    DETAIL
     algcomp->algorithm[d1.seq].event_cd = dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_echo("Failed in getting event_cds for algorithm!")
   ENDIF
   DELETE  FROM cv_case_abstr_data ccad,
     (dummyt d  WITH seq = value(alg_sz))
    SET ccad.seq = 1
    PLAN (d
     WHERE (algcomp->algorithm[d.seq].event_cd > 0.0)
      AND (cv_hrv_rec->harvest_rec[1].case_id > 0.0))
     JOIN (ccad
     WHERE (ccad.event_cd=algcomp->algorithm[d.seq].event_cd)
      AND (ccad.cv_case_id=cv_hrv_rec->harvest_rec[1].case_id))
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL cv_log_message("No predicted fields were deleted with this case!")
   ENDIF
   IF (alg_sz > 0)
    CALL cv_echo("Starts insertion to cv_case_abstr_data table!")
    CALL cv_echo("dump cer_temp:cv_algcomp_bf_ins_abstr.dat")
    CALL echorecord(algcomp,"cer_temp:cv_algcomp_bf_ins_abstr.dat")
    CALL cv_echo(build("case_id: ",cv_hrv_rec->harvest_rec[1].case_id))
    INSERT  FROM cv_case_abstr_data ccad,
      (dummyt d  WITH seq = value(alg_sz))
     SET ccad.case_abstr_data_id = seq(card_vas_seq,nextval), ccad.cv_case_id = cv_hrv_rec->
      harvest_rec[1].case_id, ccad.event_cd = algcomp->algorithm[d.seq].event_cd,
      ccad.nomenclature_id = 0.0, ccad.result_id = 0.0, ccad.event_id = 0.0,
      ccad.result_val = trim(algcomp->algorithm[d.seq].result_val,3), ccad.result_cd = algcomp->
      algorithm[d.seq].result_cd, ccad.active_ind = 1,
      ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd =
      record_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = result_status_cd,
      ccad.data_status_prsnl_id = person_id,
      ccad.active_status_prsnl_id = person_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,curtime3
       ), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ccad.updt_task = 0, ccad.updt_app = 0, ccad.updt_applctx = 0,
      ccad.updt_cnt = 0, ccad.updt_req = 0, ccad.updt_id = person_id
     PLAN (d
      WHERE (algcomp->algorithm[d.seq].event_cd > 0.0)
       AND trim(algcomp->algorithm[d.seq].result_val,3) != " ")
      JOIN (ccad)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET cv_log_level = cv_log_debug
     CALL cv_log_message("Failure inserting PRM in cv_case_abstr_data table")
    ENDIF
    CALL echorecord(cv_hrv_rec,"CER_TEMP:cv_hrv_rec_bef_clean.dat")
    SELECT INTO "nl:"
     FROM (dummyt t  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
     PLAN (t
      WHERE trim(cv_hrv_rec->harvest_rec[1].abstr_data[t.seq].task_assay_mean) IN ("ST01PREDMORT",
      "ST02PREDRENF", "ST02PREDREOP", "ST02PREDSTRO", "ST02PREDVENT",
      "ST02PRED14D", "ST02PRED6D", "ST02PREDDEEP", "ST02PREDMM"))
     DETAIL
      cv_hrv_rec->harvest_rec[1].abstr_data[t.seq].translated_value = " ", cv_hrv_rec->harvest_rec[1]
      .abstr_data[t.seq].result_val = " "
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_echo("CV_HRV_REC IN ALGORITHM IS NOT CLEAN UP!")
    ENDIF
    CALL echorecord(cv_hrv_rec,"CER_TEMP:cv_hrv_rec_post_clean.dat")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(algcomp->algorithm,5))),
      (dummyt d1  WITH seq = value(size(cv_hrv_rec->harvest_rec[1].abstr_data,5)))
     PLAN (d
      WHERE (algcomp->algorithm[d.seq].event_cd > 0.0))
      JOIN (d1
      WHERE (algcomp->algorithm[d.seq].event_cd=cv_hrv_rec->harvest_rec[1].abstr_data[d1.seq].
      event_cd))
     DETAIL
      IF (size(trim(algcomp->algorithm[d.seq].result_val)) > 0)
       cv_hrv_rec->harvest_rec[1].abstr_data[d1.seq].result_val = trim(algcomp->algorithm[d.seq].
        result_val,3), cv_hrv_rec->harvest_rec[1].abstr_data[d1.seq].translated_value = trim(algcomp
        ->algorithm[d.seq].result_val,3), cv_hrv_rec->harvest_rec[1].abstr_data[d1.seq].valid_flag =
       1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_echo("CV_HRV_REC IN ALGORITHM IS NOT UPDATED!")
    ENDIF
    CALL echorecord(cv_hrv_rec,"CER_TEMP:cv_hrv_rec_post_upd.dat")
   ENDIF
   CALL cv_log_message("post_to_cv_case_abstr_data - end")
 END ;Subroutine
 DECLARE cv_get_case_date_ec(dataset_id=f8) = f8
 DECLARE cv_get_code_by_dataset(dataset_id=f8,short_name=vc) = f8
 DECLARE cv_get_code_by(string_type=vc,code_set=i4,value=vc) = f8
 DECLARE l_case_date = vc WITH protect
 DECLARE l_case_date_dta = f8 WITH protect, noconstant(- (1.0))
 DECLARE l_case_date_ec = f8 WITH protect, noconstant(- (1.0))
 DECLARE get_code_ret = f8 WITH protect, noconstant(- (1.0))
 DECLARE dataset_prefix = vc WITH protect
 SUBROUTINE cv_get_case_date_ec(dataset_id_param)
   SET l_case_date = " "
   SET l_case_date_dta = - (1.0)
   SET l_case_date_ec = - (1.0)
   SELECT INTO "nl:"
    d.case_date_mean
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     l_case_date = d.case_date_mean
    WITH nocounter
   ;end select
   IF (size(trim(l_case_date)) > 0)
    SET l_case_date_dta = cv_get_code_by("MEANING",14003,nullterm(l_case_date))
    IF (l_case_date_dta > 0.0)
     SELECT INTO "nl:"
      dta.event_cd
      FROM discrete_task_assay dta
      WHERE dta.task_assay_cd=l_case_date_dta
      DETAIL
       l_case_date_ec = dta.event_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(l_case_date_ec)
 END ;Subroutine
 SUBROUTINE cv_get_code_by_dataset(dataset_id_param,short_name)
   SET dataset_prefix = " "
   SET get_code_ret = - (1.0)
   SELECT INTO "nl:"
    d.dataset_internal_name
    FROM cv_dataset d
    WHERE d.dataset_id=dataset_id_param
    DETAIL
     CASE (d.dataset_internal_name)
      OF "STS02":
       dataset_prefix = "ST02"
      ELSE
       dataset_prefix = d.dataset_internal_name
     ENDCASE
    WITH nocounter
   ;end select
   CALL echo(build("dataset_prefix:",dataset_prefix))
   IF (size(trim(dataset_prefix)) > 0)
    SELECT INTO "nl:"
     x.event_cd
     FROM cv_xref x
     WHERE x.xref_internal_name=concat(trim(dataset_prefix),"_",short_name)
     DETAIL
      get_code_ret = x.event_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("get_code_ret:",get_code_ret))
   RETURN(get_code_ret)
 END ;Subroutine
 SUBROUTINE cv_get_code_by(string_type,code_set_param,value)
   SET get_code_ret = uar_get_code_by(nullterm(string_type),code_set_param,nullterm(trim(value)))
   IF (get_code_ret <= 0.0)
    CALL echo(concat("Failed uar_get_code_by(",string_type,",",trim(cnvtstring(code_set_param)),",",
      value,")"))
    SELECT
     IF (string_type="MEANING")
      WHERE cv.code_set=code_set_param
       AND cv.cdf_meaning=value
     ELSEIF (string_type="DISPLAYKEY")
      WHERE cv.code_set=code_set_param
       AND cv.display_key=value
     ELSEIF (string_type="DISPLAY")
      WHERE cv.code_set=code_set_param
       AND cv.display=value
     ELSEIF (string_type="DESCRIPTION")
      WHERE cv.code_set=code_set_param
       AND cv.description=value
     ELSE
      WHERE cv.code_value=0.0
     ENDIF
     INTO "nl:"
     FROM code_value cv
     DETAIL
      get_code_ret = cv.code_value
     WITH nocounter
    ;end select
    CALL echo(concat("code_value lookup result =",cnvtstring(get_code_ret)))
   ENDIF
   RETURN(get_code_ret)
 END ;Subroutine
 DECLARE cnt_stack = i4 WITH protect
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE proc_type_cd = f8 WITH protect
 DECLARE cnt_token = i4 WITH protect
 DECLARE person_id = f8 WITH protect
 DECLARE person_username = vc WITH protect
 DECLARE token_alloc_size = i4 WITH protect, constant(500)
 DECLARE stack_alloc_size = i4 WITH protect, constant(100)
 DECLARE proc_type_cs = i4 WITH protect, constant(315571)
 DECLARE meaning_str = c7 WITH protect, constant("MEANING")
 CALL cv_log_message("Get Procedure Type algorithm")
 SELECT INTO "NL:"
  a.algorithm_id
  FROM cv_dataset d,
   cv_algorithm a,
   cv_component c,
   long_text_reference lc
  PLAN (d
   WHERE d.dataset_internal_name="STS*"
    AND (d.dataset_id=cv_hrv_rec->dataset_id)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE a.dataset_id=d.dataset_id
    AND a.description="STS*"
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.algorithm_id=a.algorithm_id
    AND c.active_ind=1
    AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (lc
   WHERE lc.long_text_id=c.long_text_id)
  ORDER BY a.algorithm_id
  HEAD REPORT
   cnt_algorithm = 0, done = "N"
  HEAD a.algorithm_id
   cnt_algorithm = (cnt_algorithm+ 1)
   IF (cnt_algorithm > size(algcomp->algorithm,5))
    stat = alterlist(algcomp->algorithm,(cnt_algorithm+ 9))
   ENDIF
   cnt_component = 0, algcomp->algorithm[cnt_algorithm].algorithm_id = a.algorithm_id, algcomp->
   algorithm[cnt_algorithm].validation_id = a.validation_alg_id,
   algcomp->algorithm[cnt_algorithm].description = cnvtupper(a.description), algcomp->algorithm[
   cnt_algorithm].task_assay_cd = a.result_dta_cd
  DETAIL
   cnt_component = (cnt_component+ 1)
   IF (cnt_component > size(algcomp->algorithm[cnt_algorithm].component,5))
    stat = alterlist(algcomp->algorithm[cnt_algorithm].component,(cnt_component+ 9))
   ENDIF
   algcomp->algorithm[cnt_algorithm].component[cnt_component].component_id = c.component_id, algcomp
   ->algorithm[cnt_algorithm].component[cnt_component].long_text_id = c.long_text_id, algcomp->
   algorithm[cnt_algorithm].component[cnt_component].algorithm_id = c.algorithm_id,
   algcomp->algorithm[cnt_algorithm].component[cnt_component].mnemonic = trim(cnvtupper(c.mnemonic),3
    ), algcomp->algorithm[cnt_algorithm].component[cnt_component].mnemonic_key = c.mnemonic_key,
   algcomp->algorithm[cnt_algorithm].component[cnt_component].parent_component_id = c
   .parent_component_id,
   algcomp->algorithm[cnt_algorithm].component[cnt_component].source_name = c.source_name, algcomp->
   algorithm[cnt_algorithm].component[cnt_component].source_id = c.source_id, algcomp->algorithm[
   cnt_algorithm].component[cnt_component].modifier = c.modifier,
   algcomp->algorithm[cnt_algorithm].component[cnt_component].long_text = lc.long_text, algcomp->
   algorithm[cnt_algorithm].component[cnt_component].component_type_flag = c.component_type_flag
   IF (c.modifier != 0
    AND c.modifier != 1)
    algcomp->algorithm[cnt_algorithm].component[cnt_component].long_text = build(lc.long_text,
     parse_delimitter,c.modifier,parse_delimitter,"*")
   ENDIF
  FOOT  a.algorithm_id
   stat = alterlist(algcomp->algorithm[cnt_algorithm].component,cnt_component), algcomp->algorithm[
   cnt_algorithm].cnt_component = cnt_component
  FOOT REPORT
   stat = alterlist(algcomp->algorithm,cnt_algorithm), algcomp->cnt_algorithm = cnt_algorithm
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Couldn't find dataset or algorithm.")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("dump algorithm record")
 EXECUTE cv_log_struct  WITH replace(request,algcomp)
 CALL cv_log_message("get operators")
 SELECT INTO "NL:"
  FROM cv_operator o
  WHERE o.operator_id > 0.0
  HEAD REPORT
   cnt_operator = 0
  DETAIL
   cnt_operator = (cnt_operator+ 1)
   IF (cnt_operator > size(operator->operator,5))
    stat = alterlist(operator->operator,(cnt_operator+ 9))
   ENDIF
   operator->operator[cnt_operator].operator = trim(o.operator,3), operator->operator[cnt_operator].
   nbr_operands = o.nbr_operands
  FOOT REPORT
   stat = alterlist(operator->operator,cnt_operator)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Couldn't find any operators.")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("dump operator record")
 EXECUTE cv_log_struct  WITH replace(request,operator)
 CALL cv_log_message("process validations")
 IF ((((algcomp->algorithm[1].validation_id=algcomp->algorithm[1].algorithm_id)) OR ((algcomp->
 algorithm[1].validation_id=0))) )
  SET token->description = algcomp->algorithm[1].description
  SET algcomp->algorithm[1].validated_ind = 1
  CALL echo("*******************************************")
  CALL cv_log_message(build("validating:",algcomp->algorithm[1].description))
  CALL echo("*******************************************")
  CALL set_initial_token(1,cv_component_type_evaluation)
  CALL process_tokens(1,cv_component_type_evaluation)
  CALL get_response_values(0)
  CALL get_values_from_cv_hrv_rec(0)
  CALL do_postfix(0)
  CALL cv_log_message("dump token")
  EXECUTE cv_log_struct  WITH replace(request,token)
  CALL cv_log_message("dump stack")
  EXECUTE cv_log_struct  WITH replace(request,stack)
  IF (cnvtreal(stack->stack[1].value) != 0)
   CALL cv_log_message(build("validation succeeded for:",algcomp->algorithm[1].description," RESULT:",
     stack->stack[cnt_stack].value))
   SET algcomp->algorithm[1].result_val = stack->stack[cnt_stack].value
   CALL cv_log_message("***********************************************")
   CALL cv_log_message(build("validation succeeded for:",algcomp->algorithm[1].description))
   CALL cv_log_message("***********************************************")
  ELSE
   CALL cv_log_message("***********************************************")
   CALL cv_log_message(build("validation failed for:",algcomp->algorithm[1].description))
   CALL cv_log_message("***********************************************")
  ENDIF
 ENDIF
 CALL echo(build("result_val:",cnvtint(algcomp->algorithm[1].result_val)))
 DECLARE result_nbr_str = vc WITH protect
 SET result_nbr_str = cnvtstring(cnvtint(algcomp->algorithm[1].result_val))
 DECLARE res_val = vc WITH public, noconstant("")
 SET res_val = evaluate(cnvtint(algcomp->algorithm[1].result_val),0,"OTHER",1,"MVR",
  2,"AVR",3,"AVR_MVR",4,
  "CABONLY",5,"MVR_CAB",6,"AVR_CAB",
  7,"OTHER","OTHER")
 SET algcomp->algorithm[1].result_cd = cv_get_code_by("MEANING",proc_type_cs,res_val)
 SET algcomp->algorithm[1].result_val = uar_get_code_display(algcomp->algorithm[1].result_cd)
 CALL echo(res_val)
 CALL post_to_cv_case_abstr_data(0)
 DECLARE loop = i4 WITH protect
 FOR (loop = 1 TO size(cv_hrv_rec->harvest_rec[1].abstr_data,5))
   IF ((cv_hrv_rec->harvest_rec[1].abstr_data[loop].event_cd=algcomp->algorithm[1].event_cd))
    SET cv_hrv_rec->harvest_rec[1].abstr_data[loop].translated_value = result_nbr_str
    SET loop = size(cv_hrv_rec->harvest_rec[1].abstr_data,5)
   ENDIF
 ENDFOR
#exit_script
 FREE RECORD algcomp
 FREE RECORD operator
 FREE RECORD token
 FREE RECORD stack
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
 DECLARE cv_get_proc_type_sts_version = vc WITH private, constant("MOD 005 BM9013 09/27/05")
END GO
