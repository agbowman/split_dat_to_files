CREATE PROGRAM cv_utl_del_orphans:dba
 PROMPT
  "Delete found orphans(Y/N)[N]" = "N"
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
 DECLARE set_compute_hash_value(key_value=f8) = null
 DECLARE set_find(set_name=vc(ref),key_value=f8) = null
 DECLARE set_insert(set_name=vc(ref),key_value=f8) = null
 DECLARE set_add_to_list(set_name=vc(ref),list_name=vc(ref)) = null
 DECLARE set_insert_list(set_name=vc(ref),list_name=vc(ref)) = null
 DECLARE set_filter_to_list(set_name=vc(ref),filter_name=vc(ref),list_name=vc(ref)) = null
 DECLARE set_clear(set_name=vc(ref),new_size=i4) = null
 DECLARE set_key_found = i2
 DECLARE set_hash_value = i4
 SUBROUTINE set_compute_hash_value(key_value)
   SET set_hash_value = cnvtint(key_value)
 END ;Subroutine
 SUBROUTINE set_find(set_name,key_value)
   DECLARE bucket = i4 WITH noconstant(0), private
   DECLARE index = i4 WITH noconstant(0), private
   CALL set_compute_hash_value(key_value)
   SET bucket = (1+ mod(set_hash_value,size(set_name->array,5)))
   SET set_key_found = 0
   FOR (index = 1 TO value(size(set_name->array[bucket].list,5)))
     IF ((set_name->array[bucket].list[index].val=key_value))
      SET set_key_found = 1
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE set_insert(set_name,key_value)
   DECLARE bucket = i4 WITH noconstant(0), private
   DECLARE index = i4 WITH noconstant(0), private
   CALL set_compute_hash_value(key_value)
   SET bucket = (1+ mod(set_hash_value,size(set_name->array,5)))
   SET set_key_found = 0
   FOR (index = 1 TO value(size(set_name->array[bucket].list,5)))
     IF ((set_name->array[bucket].list[index].val=key_value))
      SET set_key_found = 1
      RETURN
     ENDIF
   ENDFOR
   SET index = (1+ size(set_name->array[bucket].list,5))
   SET stat = alterlist(set_name->array[bucket].list,index)
   SET set_name->array[bucket].list[index].val = key_value
   SET set_name->size = (set_name->size+ 1)
 END ;Subroutine
 SUBROUTINE set_add_to_list(set_name,list_name)
   DECLARE bucket = i4 WITH noconstant(0), private
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE list_index = i4 WITH noconstant(0), private
   SET list_index = size(list_name->qual,5)
   SET stat = alterlist(list_name->qual,value((list_index+ set_name->size)))
   FOR (bucket = 1 TO size(set_name->array,5))
     FOR (index = 1 TO value(size(set_name->array[bucket].list,5)))
      SET list_index = (list_index+ 1)
      SET list_name->qual[list_index].val = set_name->array[bucket].list[index].val
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE set_insert_list(set_name,list_name)
  DECLARE list_index = i4 WITH noconstant(0), private
  FOR (list_index = 1 TO size(list_name->qual,5))
    CALL set_insert(set_name,list_name->qual[list_index].val)
  ENDFOR
 END ;Subroutine
 SUBROUTINE set_filter_to_list(set_name,filter_name,list_name)
   DECLARE bucket = i4 WITH noconstant(0), private
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE list_index = i4 WITH noconstant(0), private
   DECLARE test_val = f8
   SET list_index = size(list_name->qual,5)
   FOR (bucket = 1 TO size(set_name->array,5))
     FOR (index = 1 TO size(set_name->array[bucket].list,5))
       SET test_val = set_name->array[bucket].list[index].val
       CALL set_find(filter_name,test_val)
       IF ( NOT (set_key_found))
        SET list_index = (list_index+ 1)
        IF (list_index > size(list_name->qual,5))
         SET stat = alterlist(list_name->qual,(list_index+ 9))
        ENDIF
        SET list_name->qual[list_index].val = set_name->array[bucket].list[index].val
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(list_name->qual,list_index)
 END ;Subroutine
 SUBROUTINE set_clear(set_name,new_size)
   SET stat = alterlist(set_name->array,0)
   SET set_name->size = 0
   SET stat = alterlist(set_name->array,new_size)
 END ;Subroutine
 DECLARE find_orphans(parent_table=vc,child_table=vc,parent_key=vc,child_fk=vc,child_key=vc,
  list_name=vc,ele_name=vc,zeros_ind=i2) = null WITH protect
 DECLARE find_orphans_cv(parent_key=vc,child_key=vc) = null WITH protect
 DECLARE delete_list_cv(key_name=vc) = null WITH protect
 DECLARE delete_list(table_name=vc,list_name=vc,ele_name=vc) = null WITH protect
 DECLARE get_size(list_name=vc) = i4 WITH protect
 DECLARE add_children(child_table=vc,child_key=vc,child_fk=vc,parent_list_name=vc,parent_ele_name=vc,
  child_list_name=vc,child_ele_name=vc) = null WITH protect
 DECLARE add_children_cv(parent_root=vc,child_root=vc) = null WITH protect
 DECLARE make_cv_table_name(root=vc) = vc WITH protect
 RECORD reply(
   1 cv_case_abstr_data[*]
     2 case_abstr_data_id = f8
   1 cv_xref_validation[*]
     2 xref_validation_id = f8
   1 cv_procedure[*]
     2 procedure_id = f8
   1 cv_lesion[*]
     2 lesion_id = f8
   1 cv_device[*]
     2 device_id = f8
   1 cv_proc_abstr_data[*]
     2 proc_abstr_data_id = f8
   1 cv_les_abstr_data[*]
     2 les_abstr_data_id = f8
   1 cv_dev_abstr_data[*]
     2 dev_abstr_data_id = f8
   1 cv_case_field[*]
     2 case_field_id = f8
   1 cv_case_file_row[*]
     2 cv_case_file_row_id = f8
   1 cv_case_dataset_r[*]
     2 case_dataset_r_id = f8
   1 long_text[*]
     2 long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE field_cnt = i4 WITH noconstant(0), protect
 DECLARE field_idx = i4 WITH noconstant(0), protect
 CALL find_orphans_cv("cv_case","case_dataset_r")
 CALL find_orphans_cv("cv_case","case_abstr_data")
 CALL find_orphans_cv("cv_case","procedure")
 CALL find_orphans_cv("case_dataset_r","case_field")
 CALL find_orphans_cv("case_dataset_r","cv_case_file_row")
 CALL find_orphans_cv("procedure","lesion")
 CALL find_orphans_cv("procedure","proc_abstr_data")
 CALL find_orphans_cv("lesion","les_abstr_data")
 CALL find_orphans_cv("device","dev_abstr_data")
 SELECT INTO "nl:"
  FROM cv_device d
  WHERE (( NOT ( EXISTS (
  (SELECT INTO "nl:"
   cv_case_id
   FROM cv_case
   WHERE cv_case_id=d.cv_case_id)))) OR ((( NOT ( EXISTS (
  (SELECT INTO "nl:"
   lesion_id
   FROM cv_lesion
   WHERE lesion_id=d.lesion_id)))) OR (d.device_id > 0.0
   AND d.cv_case_id=0.0
   AND d.lesion_id=0.0)) ))
  HEAD REPORT
   device_cnt = 0
  DETAIL
   device_cnt = (device_cnt+ 1), stat = alterlist(reply->cv_device,device_cnt), reply->cv_device[
   device_cnt].device_id = d.device_id
  WITH nocounter
 ;end select
 CALL add_children_cv("case_dataset_r","case_field")
 CALL add_children_cv("case_dataset_r","cv_case_file_row")
 CALL add_children_cv("procedure","lesion")
 CALL add_children_cv("procedure","proc_abstr_data")
 CALL add_children_cv("lesion","device")
 CALL add_children_cv("lesion","les_abstr_data")
 CALL add_children_cv("device","dev_abstr_data")
 SET field_cnt = size(reply->cv_case_field,5)
 IF (field_cnt > 0)
  SELECT INTO "nl:"
   FROM cv_case_field cf
   WHERE expand(field_idx,1,field_cnt,cf.case_field_id,reply->cv_case_field[field_idx].case_field_id)
    AND cf.long_text_id > 0
   HEAD REPORT
    long_text_cnt = size(reply->long_text,5)
   DETAIL
    long_text_cnt = (long_text_cnt+ 1), stat = alterlist(reply->long_text,long_text_cnt), reply->
    long_text[long_text_cnt].long_text_id = cf.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 SET field_cnt = size(reply->cv_case_file_row,5)
 IF (field_cnt > 0)
  SELECT INTO "nl:"
   FROM cv_case_file_row cfr
   WHERE expand(field_idx,1,field_cnt,cfr.cv_case_file_row_id,reply->cv_case_file_row[field_idx].
    cv_case_file_row_id)
    AND cfr.long_text_id > 0
   HEAD REPORT
    long_text_cnt = size(reply->long_text,5)
   DETAIL
    long_text_cnt = (long_text_cnt+ 1), stat = alterlist(reply->long_text,long_text_cnt), reply->
    long_text[long_text_cnt].long_text_id = cfr.long_text_id
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
 IF (( $1="Y"))
  CALL delete_list("long_text","reply->long_text","long_text_id")
  CALL delete_list_cv("case_field")
  CALL delete_list_cv("dev_abstr_data")
  CALL delete_list_cv("les_abstr_data")
  CALL delete_list_cv("proc_abstr_data")
  CALL delete_list_cv("case_abstr_data")
  CALL delete_list_cv("device")
  CALL delete_list_cv("lesion")
  CALL delete_list_cv("procedure")
  CALL delete_list_cv("cv_case_file_row")
  CALL delete_list_cv("case_dataset_r")
  CALL echo("Type 'commit go' to commit these deletes")
 ELSE
  CALL cv_log_message("Deletes not performed")
 ENDIF
 SUBROUTINE find_orphans_cv(parent_key_root,child_key_root)
   DECLARE p_table = vc WITH protect
   DECLARE c_table = vc WITH protect
   DECLARE p_key = vc WITH protect
   DECLARE c_key = vc WITH protect
   SET p_key = concat(parent_key_root,"_id")
   SET c_key = concat(child_key_root,"_id")
   SET p_table = make_cv_table_name(parent_key_root)
   SET c_table = make_cv_table_name(child_key_root)
   CALL find_orphans(p_table,c_table,p_key,p_key,c_key,
    concat("reply->",trim(c_table)),c_key,1)
 END ;Subroutine
 SUBROUTINE find_orphans(parent_table,child_table,parent_key,child_fk,child_key,list_name,ele_name,
  zeros_ind)
   DECLARE o_cnt = i4 WITH noconstant(0), private
   DECLARE loop = i4 WITH noconstant(0), private
   FREE SET parser_buffer
   SET parser_buffer[10] = fillstring(132," ")
   SET parser_buffer[1] = concat("select into 'nl:' from ",trim(child_table)," c where not exists ")
   SET parser_buffer[2] = concat("(select p.",trim(parent_key,3)," from ",trim(parent_table)," p")
   SET parser_buffer[3] = concat("where p.",trim(parent_key,3)," = c.",trim(child_fk,3),")")
   IF (zeros_ind=1)
    SET parser_buffer[4] = concat("or c.",trim(child_fk)," = 0 and c.",trim(child_key)," > 0")
   ELSE
    SET parser_buffer[4] = " "
   ENDIF
   SET parser_buffer[5] = concat("head report o_cnt = size(",trim(list_name),",5)")
   SET parser_buffer[6] = "detail o_cnt = o_cnt + 1"
   SET parser_buffer[7] = concat("stat = alterlist(",trim(list_name),",o_cnt)")
   SET parser_buffer[8] = concat(trim(list_name),"[o_cnt].",trim(ele_name))
   SET parser_buffer[9] = concat(" = c.",trim(child_key))
   SET parser_buffer[10] = "with nocounter go"
   FOR (loop = 1 TO 10)
     CALL parser(parser_buffer[loop])
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_children_cv(parent_root,child_root)
   DECLARE c_table = vc WITH protect
   DECLARE p_table = vc WITH protect
   SET c_table = make_cv_table_name(child_root)
   SET p_table = make_cv_table_name(parent_root)
   CALL add_children(c_table,concat(child_root,"_id"),concat(parent_root,"_id"),concat("reply->",
     p_table),concat(parent_root,"_id"),
    concat("reply->",c_table),concat(child_root,"_id"))
 END ;Subroutine
 SUBROUTINE add_children(child_table,child_key,child_fk,parent_list_name,parent_ele_name,
  child_list_name,child_ele_name)
   DECLARE parent_size = i4 WITH noconstant(0), protect
   DECLARE child_size = i4 WITH noconstant(0), protect
   DECLARE expand_idx = i4 WITH noconstant(0), protect
   DECLARE child_size_base = i4 WITH noconstant(0), protect
   SET parent_size = get_size(parent_list_name)
   IF (parent_size <= 0)
    CALL echo(concat("List empty: ",parent_list_name))
    RETURN
   ELSE
    CALL echo(concat("Adding children of ",parent_list_name," to ",child_list_name))
   ENDIF
   SET child_size = get_size(child_list_name)
   SET child_size_base = child_size
   FREE SET parser_buffer
   SET parser_buffer[6] = fillstring(132," ")
   SET parser_buffer[1] = concat("select into 'nl:' from ",trim(child_table)," c")
   SET parser_buffer[2] = concat("where expand(expand_idx,1,parent_size,",trim(child_fk),",",trim(
     parent_list_name),"[expand_idx].",
    trim(parent_ele_name),")")
   SET parser_buffer[3] = "detail child_size = child_size + 1"
   SET parser_buffer[4] = concat("stat = alterlist(",trim(child_list_name),",child_size)")
   SET parser_buffer[5] = concat(trim(child_list_name),"[child_size].",trim(child_ele_name)," = c.",
    trim(child_key))
   SET parser_buffer[6] = "with nocounter go"
   FOR (loop = 1 TO 6)
     CALL parser(parser_buffer[loop])
   ENDFOR
 END ;Subroutine
 SUBROUTINE delete_list_cv(root_name)
   DECLARE table_name = vc WITH protect
   SET table_name = make_cv_table_name(root_name)
   CALL delete_list(table_name,build("reply->",table_name),build(root_name,"_id"))
 END ;Subroutine
 SUBROUTINE delete_list(table_name,list_name,ele_name)
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE loop = i4 WITH noconstant(0), private
   DECLARE list_size = i4 WITH noconstant(0), protect
   SET list_size = get_size(list_name)
   IF (list_size <= 0)
    CALL echo(concat("Nothing to delete from: ",list_name))
    RETURN
   ELSE
    CALL echo(concat("Deleting from: ",table_name))
   ENDIF
   FREE SET parser_buffer
   SET parser_buffer[3] = fillstring(132," ")
   SET parser_buffer[1] = concat("delete from ",trim(table_name))
   SET parser_buffer[2] = concat("where expand(expand_idx,1,list_size,",trim(ele_name),",",trim(
     list_name),"[expand_idx].",
    trim(ele_name),")")
   SET parser_buffer[3] = concat("and ",trim(ele_name)," > 0 go")
   FOR (loop = 1 TO 3)
     CALL parser(parser_buffer[loop])
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_size(list_name)
   DECLARE list_size = i4 WITH noconstant(0), protect
   DECLARE parser_get_size = vc WITH private
   SET parser_get_size = concat("set list_size = size(",trim(list_name),",5) go")
   CALL parser(parser_get_size)
   RETURN(list_size)
 END ;Subroutine
 SUBROUTINE make_cv_table_name(root)
   IF (cnvtupper(substring(1,3,root))="CV_")
    RETURN(root)
   ELSE
    RETURN(concat("cv_",trim(root)))
   ENDIF
 END ;Subroutine
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
