CREATE PROGRAM cv_import_algorithm:dba
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
 IF (validate(reply) != 1)
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
 IF (validate(add_algorithm_request) != 1)
  RECORD add_algorithm_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 algorithm_id = f8
      2 dataset_id = f8
      2 description = vc
      2 data_status_cd = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 result_dta_cd = f8
      2 validation_alg_id = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 SET add_algorithm_request->call_echo_ind = 1
 IF (validate(add_algorithm_reply) != 1)
  RECORD add_algorithm_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 algorithm_id = f8
      2 status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(chg_algorithm_request) != 1)
  RECORD chg_algorithm_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 algorithm_id = f8
      2 dataset_id = f8
      2 description = vc
      2 updt_cnt = i4
      2 result_dta_cd = f8
      2 validation_alg_id = f8
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 SET chg_algorithm_request->call_echo_ind = 1
 IF (validate(chg_algorithm_reply) != 1)
  RECORD chg_algorithm_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(add_long_text_refe_request) != 1)
  RECORD add_long_text_refe_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 long_text_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 long_text = vc
      2 allow_partial_ind = i2
  )
 ENDIF
 SET add_long_text_refe_request->call_echo_ind = 1
 IF (validate(add_long_text_refe_reply) != 1)
  RECORD add_long_text_refe_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 long_text_id = f8
      2 status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(add_component_request) != 1)
  RECORD add_component_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 active_ind = i2
      2 active_status_cd = f8
      2 component_type_flag = i2
      2 component_id = f8
      2 long_text_id = f8
      2 algorithm_id = f8
      2 mnemonic = vc
      2 parent_component_id = f8
      2 source_name = c30
      2 source_id = f8
      2 modifier = f8
      2 data_status_cd = f8
      2 allow_partial_ind = i2
  )
 ENDIF
 SET add_component_request->call_echo_ind = 1
 IF (validate(add_component_reply) != 1)
  RECORD add_component_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 component_id = f8
      2 status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(chg_component_request,0)))
  RECORD chg_component_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 updt_cnt = i4
      2 component_type_flag = i2
      2 component_id = f8
      2 long_text_id = f8
      2 algorithm_id = f8
      2 mnemonic = vc
      2 parent_component_id = f8
      2 source_name = c30
      2 source_id = f8
      2 modifier = f8
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(chg_component_reply,0)))
  RECORD chg_component_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF (validate(tokens) != 1)
  RECORD tokens(
    1 qual[*]
      2 token = vc
      2 type = i4
      2 parent = i4
      2 entity_id = f8
      2 algorithm_id = f8
      2 primary_key = f8
  )
 ENDIF
 DECLARE cv_log_my_files = i2 WITH protect, noconstant(1)
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
 DECLARE curparsedone = i2 WITH protect
 DECLARE curpos = i4 WITH protect
 DECLARE param_pos = i4 WITH protect
 DECLARE cv_parse_data(param_sep=vc(ref),param_string=vc(ref),param_pos=i4(ref)) = vc
 SUBROUTINE cv_parse_data(param_sep,param_string,param_pos)
   SET curparsedone = 0
   SET curpos = findstring(param_sep,param_string,param_pos)
   IF (curpos=0)
    SET curpos = (size(param_string,1)+ 1)
    SET curparsedone = 1
   ENDIF
   IF (param_pos=0)
    SET param_pos = 1
   ENDIF
   SET retval = substring(param_pos,(curpos - param_pos),param_string)
   SET param_pos = (curpos+ size(param_sep,1))
   IF (curparsedone=1)
    SET param_pos = - (1)
   ENDIF
   RETURN(retval)
 END ;Subroutine
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE data_set_id = f8 WITH protect
 DECLARE cnt_algorithm = i4 WITH protect
 DECLARE cnt_component = i4 WITH protect
 DECLARE cnt_long_text_ref = i4 WITH protect
 DECLARE parse_string = vc WITH protect
 DECLARE parse_pos = i4 WITH protect
 DECLARE tokensize = i4 WITH protect
 DECLARE ret_str = vc WITH protect
 DECLARE num_alg = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE cdf_meaning = vc WITH protect, noconstant(fillstring(12," "))
 CALL cv_log_message("dump requestin")
 EXECUTE cv_log_struct  WITH replace(request,requestin)
 CALL cv_log_message("get dataset_id")
 SET data_set_id = 0.0
 SELECT INTO "NL:"
  FROM cv_dataset cd
  WHERE (cd.dataset_internal_name=requestin->list_0[1].datasetname)
  DETAIL
   data_set_id = cd.dataset_id,
   CALL cv_log_message(cd.display_name)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_DATASET"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "requestin->list_0[1].DataSetName"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 DELETE  FROM cv_component cc
  WHERE cc.algorithm_id IN (
  (SELECT
   ca.algorithm_id
   FROM cv_algorithm ca
   WHERE ca.dataset_id=data_set_id))
  WITH nocounter
 ;end delete
 COMMIT
 DELETE  FROM cv_algorithm ca
  WHERE ca.dataset_id=data_set_id
  WITH nocounter
 ;end delete
 COMMIT
 IF (currdbname != "DTEST")
  DELETE  FROM long_text_reference ltr
   WHERE ltr.parent_entity_name="CV_COMPONENT"
    AND ltr.parent_entity_id=data_set_id
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 CALL cv_log_message("insert into cv_algorithm")
 SET cnt_algorithm = 0
 SET num_alg = 0
 SET code_value = 0.0
 SET code_set = 14003
 IF (validate(dta_means) != 1)
  RECORD dta_means(
    1 qual[*]
      2 mean = vc
  )
 ENDIF
 DECLARE model = c50 WITH protect
 SELECT INTO "nl:"
  model = requestin->list_0[d.seq].model
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  WHERE (requestin->list_0[d.seq].parent=requestin->list_0[d.seq].description)
  ORDER BY model, d.seq
  HEAD model
   cnt_algorithm = (cnt_algorithm+ 1)
   IF (mod(cnt_algorithm,10)=1)
    stat = alterlist(add_algorithm_request->qual,(cnt_algorithm+ 9)), stat = alterlist(dta_means->
     qual,(cnt_algorithm+ 9))
   ENDIF
   add_algorithm_request->qual[cnt_algorithm].dataset_id = data_set_id, add_algorithm_request->qual[
   cnt_algorithm].description = trim(requestin->list_0[d.seq].model,3), add_algorithm_request->qual[
   cnt_algorithm].active_ind = 1,
   dta_means->qual[cnt_algorithm].mean = trim(requestin->list_0[d.seq].result_dta_cdf_meaning)
  DETAIL
   col 0
  FOOT REPORT
   stat = alterlist(add_algorithm_request->qual,cnt_algorithm), stat = alterlist(dta_means->qual,
    cnt_algorithm), num_alg = cnt_algorithm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DUMMYT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Top Level Algorithms"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (cnt_algorithm = 1 TO num_alg)
   SET cdf_meaning = dta_means->qual[cnt_algorithm].mean
   SET code_value = 0.0
   EXECUTE cpm_get_cd_for_cdf
   SET add_algorithm_request->qual[cnt_algorithm].result_dta_cd = code_value
   IF (code_value <= 0.0)
    CALL echo(build("There is no cdf_meaning -",dta_means->qual[cnt_algorithm].mean,
      "-under code_set 14003 in the database"))
   ENDIF
 ENDFOR
 EXECUTE cv_add_algorithm  WITH replace(request,add_algorithm_request)
 CALL cv_log_message("update cv_algorithm with validation_alg_id")
 SET stat = alterlist(chg_algorithm_request->qual,size(add_algorithm_request->qual,5))
 SET cnt_algorithm = 0
 SELECT INTO "nl:"
  model = requestin->list_0[d1.seq].model
  FROM (dummyt d1  WITH seq = value(size(requestin->list_0,5))),
   (dummyt d3  WITH seq = value(size(add_algorithm_request->qual,5)))
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].parent=requestin->list_0[d1.seq].description))
   JOIN (d3
   WHERE (add_algorithm_request->qual[d3.seq].description=requestin->list_0[d1.seq].
   validation_alg_model))
  ORDER BY model, d1.seq
  HEAD model
   cnt_algorithm = (cnt_algorithm+ 1), chg_algorithm_request->qual[cnt_algorithm].algorithm_id =
   add_algorithm_request->qual[cnt_algorithm].algorithm_id, chg_algorithm_request->qual[cnt_algorithm
   ].dataset_id = add_algorithm_request->qual[cnt_algorithm].dataset_id,
   chg_algorithm_request->qual[cnt_algorithm].description = add_algorithm_request->qual[cnt_algorithm
   ].description, chg_algorithm_request->qual[cnt_algorithm].result_dta_cd = add_algorithm_request->
   qual[cnt_algorithm].result_dta_cd, chg_algorithm_request->qual[cnt_algorithm].force_updt_ind = 1,
   chg_algorithm_request->qual[cnt_algorithm].allow_partial_ind = 1, chg_algorithm_request->qual[
   cnt_algorithm].validation_alg_id = add_algorithm_reply->qual[d3.seq].algorithm_id
  DETAIL
   col 0
  WITH nocounter
 ;end select
 CALL echorecord(chg_algorithm_request,"cer_temp:cv_chg_algorithm_request.dat")
 EXECUTE cv_chg_algorithm  WITH replace(request,chg_algorithm_request)
 CALL cv_log_message("dump chg_algorithm_request")
 CALL cv_log_message("get components and set algorithm_id")
 SET cnt_algorithm = 0
 SET cnt_component = 0
 IF (validate(add_reqin_xref) != 1)
  RECORD add_reqin_xref(
    1 add_struct[*]
      2 reqin_idx = i4
  )
 ENDIF
 SELECT INTO "nl:"
  model = requestin->list_0[d.seq].model, reqin_seq = d.seq
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  ORDER BY model, d.seq
  HEAD model
   cnt_algorithm = (cnt_algorithm+ 1)
  DETAIL
   cnt_component = (cnt_component+ 1)
   IF (mod(cnt_component,10)=1)
    stat = alterlist(add_component_request->qual,(cnt_component+ 9)), stat = alterlist(add_reqin_xref
     ->add_struct,(cnt_component+ 9))
   ENDIF
   add_reqin_xref->add_struct[cnt_component].reqin_idx = reqin_seq, add_component_request->qual[
   cnt_component].algorithm_id = add_algorithm_reply->qual[cnt_algorithm].algorithm_id,
   add_component_request->qual[cnt_component].mnemonic = requestin->list_0[d.seq].description,
   add_component_request->qual[cnt_component].modifier = cnvtreal(requestin->list_0[d.seq].
    coefficient), add_component_request->qual[cnt_component].active_ind = 1
   IF (trim(requestin->list_0[d.seq].type,3)=str_evaluation)
    add_component_request->qual[cnt_component].component_type_flag = cv_component_type_evaluation
   ELSE
    add_component_request->qual[cnt_component].component_type_flag = cv_component_type_validation
   ENDIF
   IF (size(trim(requestin->list_0[d.seq].postfix,3),1) != 0)
    add_component_request->qual[cnt_component].source_name = str_longtextref
   ELSE
    add_component_request->qual[cnt_component].source_name = str_operand
   ENDIF
  FOOT REPORT
   stat = alterlist(add_component_request->qual,cnt_component), stat = alterlist(add_reqin_xref->
    add_struct,cnt_component)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DUMMYT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Components"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("dump add_component_request")
 EXECUTE cv_log_struct  WITH replace(request,add_component_request)
 CALL cv_log_message("insert into long_text_reference")
 SET cnt_algorithm = 0
 SET cnt_component = 0
 SET cnt_long_text_ref = 0
 SELECT INTO "nl:"
  model = requestin->list_0[d.seq].model
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  ORDER BY model, d.seq
  HEAD REPORT
   stat = alterlist(add_long_text_refe_request->qual,10)
  DETAIL
   cnt_long_text_ref = (cnt_long_text_ref+ 1)
   IF (mod(cnt_long_text_ref,10)=1
    AND cnt_long_text_ref != 1)
    stat = alterlist(add_long_text_refe_request->qual,(cnt_long_text_ref+ 9))
   ENDIF
   cnt_component = (cnt_component+ 1), add_long_text_refe_request->qual[cnt_long_text_ref].
   parent_entity_name = str_cvcomponent, add_long_text_refe_request->qual[cnt_long_text_ref].
   parent_entity_id = data_set_id,
   add_long_text_refe_request->qual[cnt_long_text_ref].long_text = requestin->list_0[d.seq].postfix,
   add_long_text_refe_request->qual[cnt_long_text_ref].active_ind = 1
  FOOT REPORT
   stat = alterlist(add_long_text_refe_request->qual,cnt_long_text_ref)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DUMMYT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT_REFERENCE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 EXECUTE sch_add_long_text_refe  WITH replace(request,add_long_text_refe_request)
 CALL cv_log_message("update cv_algorithm and cv_component with long_text_id")
 SET cnt_component = 0
 SET cnt_long_text_ref = 0
 SELECT INTO "nl:"
  model = requestin->list_0[d.seq].model
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
  ORDER BY model, d.seq
  DETAIL
   cnt_long_text_ref = (cnt_long_text_ref+ 1), cnt_component = (cnt_component+ 1),
   add_component_request->qual[cnt_component].long_text_id = add_long_text_refe_reply->qual[
   cnt_long_text_ref].long_text_id
  FOOT REPORT
   stat = alterlist(add_algorithm_request->qual,cnt_algorithm)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DUMMYT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update cv_algorithm and cv_component"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 EXECUTE cv_add_component  WITH replace(request,add_component_request)
 CALL cv_log_message("dump add_component_request")
 EXECUTE cv_log_struct  WITH replace(request,add_component_request)
 CALL cv_log_message("dump add_component_reply")
 EXECUTE cv_log_struct  WITH replace(request,add_component_reply)
 CALL cv_log_message("update cv_component with parent_component_id")
 CALL echorecord(add_component_request,"cer_temp:cv_add_component_request.dat")
 SET stat = alterlist(chg_component_request->qual,size(requestin->list_0,5))
 DECLARE req_cnt = i4 WITH protect, noconstant(0)
 DECLARE comp_cnt = i4 WITH protect, noconstant(0)
 FOR (req_cnt = 1 TO size(requestin->list_0,5))
   SET chg_component_request->qual[req_cnt].component_id = add_component_request->qual[req_cnt].
   component_id
   SET chg_component_request->qual[req_cnt].allow_partial_ind = 1
   SET chg_component_request->qual[req_cnt].force_updt_ind = 1
   SET chg_component_request->qual[req_cnt].long_text_id = add_component_request->qual[req_cnt].
   long_text_id
   SET chg_component_request->qual[req_cnt].algorithm_id = add_component_request->qual[req_cnt].
   algorithm_id
   SET chg_component_request->qual[req_cnt].mnemonic = add_component_request->qual[req_cnt].mnemonic
   SET chg_component_request->qual[req_cnt].source_name = add_component_request->qual[req_cnt].
   source_name
   SET chg_component_request->qual[req_cnt].source_id = add_component_request->qual[req_cnt].
   source_id
   SET chg_component_request->qual[req_cnt].modifier = add_component_request->qual[req_cnt].modifier
   SET chg_component_request->qual[req_cnt].component_type_flag = add_component_request->qual[req_cnt
   ].component_type_flag
   FOR (comp_cnt = 1 TO size(add_component_request->qual,5))
     IF ((requestin->list_0[add_reqin_xref->add_struct[req_cnt].reqin_idx].parent=
     add_component_request->qual[comp_cnt].mnemonic))
      SET chg_component_request->qual[req_cnt].parent_component_id = add_component_request->qual[
      comp_cnt].component_id
      SET comp_cnt = size(add_component_request->qual,5)
     ENDIF
   ENDFOR
 ENDFOR
 CALL echorecord(chg_component_request,"cer_temp:cv_chg_component_request.dat")
 EXECUTE cv_chg_component  WITH replace(request,chg_component_request)
 CALL cv_log_message("dump chg_component_request")
 EXECUTE cv_log_struct  WITH replace(request,chg_component_request)
 CALL cv_log_message("dump chg_component_reply")
 EXECUTE cv_log_struct  WITH replace(request,chg_component_reply)
 CALL cv_log_message("get postfix tokens")
 SELECT INTO "nl:"
  model = requestin->list_0[d.seq].model
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
  ORDER BY model, d.seq
  HEAD REPORT
   tokensize = 0, cnt_component = 0, cnt_algorithm = 0
  HEAD model
   cnt_algorithm = (cnt_algorithm+ 1), algorithm_id = add_algorithm_reply->qual[cnt_algorithm].
   algorithm_id
  DETAIL
   cnt_component = (cnt_component+ 1), parse_pos = 0, parse_string = requestin->list_0[d.seq].postfix,
   ret_str = fillstring(1000," ")
   WHILE ((parse_pos != - (1)))
     ret_str = cv_parse_data(parse_delimitter,parse_string,parse_pos), found = 0, j = 1
     WHILE (j <= size(tokens->qual,5)
      AND found=0)
      IF (cnvtupper(trim(tokens->qual[j].token,3))=cnvtupper(trim(ret_str,3))
       AND (tokens->qual[j].algorithm_id=algorithm_id))
       found = 1
      ENDIF
      ,j = (j+ 1)
     ENDWHILE
     IF (found=0)
      tokensize = (tokensize+ 1), stat = alterlist(tokens->qual,tokensize), tokens->qual[tokensize].
      token = ret_str,
      tokens->qual[tokensize].parent = d.seq, tokens->qual[tokensize].algorithm_id = algorithm_id,
      tokens->qual[tokensize].entity_id = chg_component_request->qual[cnt_component].
      parent_component_id
     ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request_in"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "postfix"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("get token types")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(tokens->qual,5))),
   cv_xref x
  PLAN (d)
   JOIN (x
   WHERE x.xref_internal_name=trim(tokens->qual[d.seq].token,3))
  DETAIL
   tokens->qual[d.seq].type = cv_type_xref, tokens->qual[d.seq].primary_key = x.xref_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "xref_internal_name"
  SET reply->status_data.status = "Z"
  CALL echorecord(tokens,"cer_temp:cv_alg_imp_tokens.dat")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM cv_response r,
   (dummyt d  WITH seq = value(size(tokens->qual,5)))
  PLAN (d
   WHERE (tokens->qual[d.seq].type=0))
   JOIN (r
   WHERE r.response_internal_name=trim(tokens->qual[d.seq].token,3))
  DETAIL
   tokens->qual[d.seq].type = cv_type_response, tokens->qual[d.seq].primary_key = r.response_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_RESPONSE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "response_internal_name"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(tokens->qual,5))),
   cv_operator o
  PLAN (d)
   JOIN (o
   WHERE cnvtupper(trim(tokens->qual[d.seq].token,3))=cnvtupper(trim(o.operator,3)))
  DETAIL
   tokens->qual[d.seq].type = cv_type_operator
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_OPERATOR"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "operator"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(size(tokens->qual,5))),
   (dummyt d2  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (d2
   WHERE trim(tokens->qual[d1.seq].token,3)=trim(requestin->list_0[d2.seq].description,3))
  DETAIL
   tokens->qual[d1.seq].type = cv_type_component
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "tokens"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "description"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("dump tokens")
 EXECUTE cv_log_struct  WITH replace(request,tokens)
 IF (validate(operands) != 1)
  RECORD operands(
    1 qual[*]
      2 parent = i4
      2 token = vc
      2 description = vc
      2 model = vc
  )
 ENDIF
 DECLARE operands_cnt = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  parent = tokens->qual[d1.seq].parent
  FROM (dummyt d1  WITH seq = value(size(tokens->qual,5)))
  WHERE (tokens->qual[d1.seq].type=0)
  ORDER BY parent
  DETAIL
   IF (cnvtreal(tokens->qual[d1.seq].token)=0.0
    AND (tokens->qual[d1.seq].token != "0"))
    operands_cnt = (operands_cnt+ 1), stat = alterlist(operands->qual,operands_cnt), operands->qual[
    operands_cnt].token = tokens->qual[d1.seq].token,
    operands->qual[operands_cnt].parent = tokens->qual[d1.seq].parent, operands->qual[operands_cnt].
    model = requestin->list_0[tokens->qual[d1.seq].parent].model, operands->qual[operands_cnt].
    description = requestin->list_0[tokens->qual[d1.seq].parent].description
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(tokens,"cer_temp:cv_import_algorithm_tokens.dat")
 CALL echorecord(operands,"cer_temp:cv_import_algorithm_operands.dat")
 CALL cv_log_message("insert tokens into add_component_request")
 SET cnt_component = 0
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(size(requestin->list_0,5))),
   (dummyt d2  WITH seq = value(size(tokens->qual,5)))
  PLAN (d1)
   JOIN (d2
   WHERE (tokens->qual[d2.seq].parent=d1.seq)
    AND (((tokens->qual[d2.seq].type=cv_type_xref)) OR ((tokens->qual[d2.seq].type=cv_type_response)
   )) )
  HEAD REPORT
   stat = alterlist(add_component_request->qual,0)
  DETAIL
   cnt_component = (cnt_component+ 1)
   IF (mod(cnt_component,10)=1)
    stat = alterlist(add_component_request->qual,(cnt_component+ 9))
   ENDIF
   IF (size(tokens->qual[d2.seq].token) > 50)
    CALL cv_log_message(concat("Token too large for mnemonic field:",tokens->qual[d2.seq].token,":")),
    add_component_request->qual[cnt_component].mnemonic = trim(substring(1,50,tokens->qual[d2.seq].
      token))
   ELSE
    add_component_request->qual[cnt_component].mnemonic = tokens->qual[d2.seq].token
   ENDIF
   add_component_request->qual[cnt_component].parent_component_id = tokens->qual[d2.seq].entity_id,
   add_component_request->qual[cnt_component].long_text_id = 0.0, add_component_request->qual[
   cnt_component].algorithm_id = tokens->qual[d2.seq].algorithm_id,
   add_component_request->qual[cnt_component].source_id = tokens->qual[d2.seq].primary_key,
   add_component_request->qual[cnt_component].modifier = 1, add_component_request->qual[cnt_component
   ].active_ind = 1
   IF ((tokens->qual[d2.seq].type=cv_type_xref))
    add_component_request->qual[cnt_component].source_name = str_cvxref
   ELSEIF ((tokens->qual[d2.seq].type=cv_type_response))
    add_component_request->qual[cnt_component].source_name = str_cvresponse
   ENDIF
  FOOT REPORT
   stat = alterlist(add_component_request->qual,cnt_component)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "tokens"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_xref, cv_response"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL cv_log_message("insert into cv_component")
 EXECUTE cv_add_component  WITH replace(request,add_component_request)
 CALL cv_log_message("dump add_component_request")
 EXECUTE cv_log_struct  WITH replace(request,add_component_request)
#exit_script
 CALL cv_log_message(build("exit script. failure:",failure))
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
 DECLARE cv_import_algorithm_vrsn = vc WITH private, constant("MOD 014 BM9013 05/26/06")
END GO
