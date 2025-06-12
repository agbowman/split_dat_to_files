CREATE PROGRAM clip_ops_iqh_reminder:dba
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 RECORD t_parse_param(
   1 qual_cnt = i4
   1 qual[*]
     2 name = vc
     2 value = vc
 )
 SUBROUTINE (s_init_parse(s_source=vc,s_beg_marker=vc,s_end_marker=vc,s_delimiter=vc,s_delimiter2=vc,
  s_error_flag=i2) =i4)
   SET t_parse_param->qual_cnt = 0
   DECLARE t_beg = i4 WITH private, noconstant(0)
   DECLARE t_end = i4 WITH private, noconstant(0)
   DECLARE t_size = i4 WITH private, noconstant(0)
   DECLARE t_string = vc WITH protect, noconstant(trim(s_source,3))
   DECLARE t_param = vc WITH protect, noconstant(" ")
   IF (t_string <= " ")
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("ERROR-->s_init_parse (Input source string is empty. CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_init_parse (Input source string is empty. CURPROG [",curprog,"]"))
    ENDCASE
    RETURN(t_parse_param->qual_cnt)
   ENDIF
   SET t_beg = findstring(s_beg_marker,t_string,1,0)
   SET t_end = findstring(s_end_marker,t_string,1,1)
   IF (((t_beg=0) OR (((t_end=0) OR (((t_end - t_beg) < 2))) )) )
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("ERROR-->s_init_parse (Invalid marker for input string: ",s_source,
       " CURPROG [",curprog,"]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_init_parse (Invalid marker for input string: ",s_source," CURPROG [",
        curprog,"]"))
    ENDCASE
    RETURN(t_parse_param->qual_cnt)
   ENDIF
   SET t_string = concat(substring((t_beg+ 1),((t_end - t_beg) - 1),t_string),s_delimiter)
   SET t_beg = 1
   SET t_size = size(t_string)
   WHILE (t_beg <= t_size)
     SET t_end = findstring(s_delimiter,t_string,t_beg,0)
     SET t_param = substring(t_beg,(t_end - t_beg),t_string)
     CALL s_parse_param(t_param,s_delimiter2)
     SET t_beg = (t_end+ 1)
   ENDWHILE
   SET stat = alterlist(t_parse_param->qual,t_parse_param->qual_cnt)
   RETURN(t_parse_param->qual_cnt)
 END ;Subroutine
 SUBROUTINE (s_parse_param(s_param=vc,s_delimiter3=vc) =i4)
   DECLARE t_pos = i4 WITH private, noconstant(findstring(s_delimiter3,s_param,1,0))
   SET t_parse_param->qual_cnt += 1
   IF (mod(t_parse_param->qual_cnt,10)=1)
    SET stat = alterlist(t_parse_param->qual,(t_parse_param->qual_cnt+ 9))
   ENDIF
   IF (t_pos > 0)
    SET t_parse_param->qual[t_parse_param->qual_cnt].name = trim(substring(1,(t_pos - 1),s_param),3)
    SET t_parse_param->qual[t_parse_param->qual_cnt].value = trim(substring((t_pos+ 1),(size(s_param)
       - t_pos),s_param),3)
   ELSE
    SET t_parse_param->qual[t_parse_param->qual_cnt].value = trim(s_param,3)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_get_value_by_name(s_input_name=vc,s_error_flag=i2) =vc)
   DECLARE t_retvalue = vc WITH protect, noconstant(" ")
   DECLARE t_found = i2 WITH protect, noconstant(0)
   FOR (index = 1 TO t_parse_param->qual_cnt)
     IF ((t_parse_param->qual[index].name=s_input_name))
      SET t_retvalue = t_parse_param->qual[index].value
      SET index = (t_parse_param->qual_cnt+ 1)
      SET t_found = 1
     ENDIF
   ENDFOR
   IF (t_found=0)
    CASE (s_error_flag)
     OF 0:
      SET table_name = build("WARNING-->s_get_value_by_name (No value found for a param name: ",
       s_input_name," CURPROG [",curprog,"]")
      CALL echo(table_name)
      SET failed = attribute_error
      GO TO exit_script
     OF 1:
      CALL echo(build("WARNING-->s_get_value_by_name (No value found for a param name: ",s_input_name,
        " CURPROG [",curprog,"]"))
    ENDCASE
   ENDIF
   RETURN(t_retvalue)
 END ;Subroutine
 SUBROUTINE (s_get_value_by_index(s_input_index=i4,s_error_flag=i2) =vc)
   IF ((s_input_index <= t_parse_param->qual_cnt)
    AND s_input_index > 0)
    RETURN(t_parse_param->qual[s_input_index].value)
   ENDIF
   CASE (s_error_flag)
    OF 0:
     SET table_name = build("ERROR-->s_get_value_by_index (Out of bound index: ",s_input_index,
      " CURPROG [",curprog,"]")
     CALL echo(table_name)
     SET failed = attribute_error
     GO TO exit_script
    OF 1:
     CALL echo(build("ERROR-->s_get_value_by_index (Out of bound index: ",s_input_index," CURPROG [",
       curprog,"]"))
   ENDCASE
   RETURN("")
 END ;Subroutine
 SUBROUTINE (s_get_param_count(s_null=i2) =i4)
   RETURN(t_parse_param->qual_cnt)
 END ;Subroutine
 SUBROUTINE (s_find_wp_template_rtf(s_template_type_cd=f8,s_short_desc=vc,option_flag=i2) =vc)
   DECLARE s_string = vc WITH protect, noconstant(" ")
   DECLARE s_template_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    l.long_text_id
    FROM wp_template wt,
     long_text l
    PLAN (wt
     WHERE wt.template_type_cd=s_template_type_cd
      AND wt.short_desc=s_short_desc
      AND wt.active_ind=1)
     JOIN (l
     WHERE l.parent_entity_name="WP_TEMPLATE_TEXT"
      AND l.parent_entity_id=wt.template_id
      AND l.active_ind=1)
    DETAIL
     s_template_id = wt.template_id, s_string = trim(l.long_text)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',
       s_short_desc,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',s_short_desc,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',s_short_desc,
      '"',",",option_flag,") TEMPLATE_ID [",s_template_id,
      "]"))
   ENDIF
   RETURN(s_string)
 END ;Subroutine
 SUBROUTINE (s_find_wp_template_plain(s_template_type_cd=f8,s_short_desc=vc,option_flag=i2) =vc)
   DECLARE s_plain = c32000 WITH protect, noconstant(fillstring(32000," "))
   DECLARE s_template_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    l.long_text_id
    FROM wp_template wt,
     long_text l
    PLAN (wt
     WHERE wt.template_type_cd=s_template_type_cd
      AND wt.short_desc=s_short_desc
      AND wt.active_ind=1)
     JOIN (l
     WHERE l.parent_entity_name="WP_TEMPLATE_TEXT"
      AND l.parent_entity_id=wt.template_id
      AND l.active_ind=1)
    DETAIL
     s_template_id = wt.template_id, stat = uar_rtf2(l.long_text,size(trim(l.long_text)),s_plain,
      32000,0,
      0)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',
       s_short_desc,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',s_short_desc,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->s_find_wp_template_rtf (",s_template_type_cd,",",'"',s_short_desc,
      '"',",",option_flag,") TEMPLATE_ID [",s_template_id,
      "]"))
   ENDIF
   RETURN(s_plain)
 END ;Subroutine
 SUBROUTINE (s_uar_crmbeginapp(s_app=i4,s_option=i4) =i4)
   DECLARE s_happ = i4 WITH protect, noconstant(0)
   DECLARE my_stat = i2 WITH protect, noconstant(0)
   SET my_stat = uar_crmbeginapp(s_app,s_happ)
   IF (my_stat)
    CASE (s_option)
     OF 0:
      SET table_name = build("ERROR-->s_uar_crmbeginapp (",s_app,",",s_option,") returned [",
       my_stat,"]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_uar_crmbeginapp (",s_app,",",s_option,") returned [",
        my_stat,"]"))
    ENDCASE
   ENDIF
   RETURN(s_happ)
 END ;Subroutine
 SUBROUTINE (s_uar_crmbegintask(s_happ=i4,s_task=i4,s_option=i4) =i4)
   DECLARE s_htask = i4 WITH protect, noconstant(0)
   DECLARE my_stat = i2 WITH protect, noconstant(0)
   SET my_stat = uar_crmbegintask(s_happ,s_task,s_htask)
   IF (my_stat)
    CASE (s_option)
     OF 0:
      SET table_name = build("ERROR-->s_uar_crmbegintask (",s_happ,",",s_task,",",
       s_option,") returned [",my_stat,"]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_uar_crmbegintask (",s_happ,",",s_task,",",
        s_option,") returned [",my_stat,"]"))
    ENDCASE
   ENDIF
   RETURN(s_htask)
 END ;Subroutine
 SUBROUTINE (s_uar_crmbeginreq(s_htask=i4,s_param=i4,s_req=i4,s_option=i4) =i4)
   DECLARE s_hstep = i4 WITH protect, noconstant(0)
   DECLARE my_stat = i2 WITH protect, noconstant(0)
   SET my_stat = uar_crmbeginreq(s_htask,s_param,s_req,s_hstep)
   IF (my_stat)
    CASE (s_option)
     OF 0:
      SET table_name = build("ERROR-->s_uar_crmbeginreq (",s_htask,",",s_param,",",
       s_req,",",s_option,") returned [",my_stat,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("ERROR-->s_uar_crmbeginreq (",s_htask,",",s_param,",",
        s_req,",",s_option,") returned [",my_stat,
        "]"))
    ENDCASE
   ENDIF
   RETURN(s_hstep)
 END ;Subroutine
 SUBROUTINE (s_uar_crmperform(s_hstep=i4,s_option=i4) =i4)
   IF (s_hstep > 0)
    DECLARE my_stat = i2 WITH protect, noconstant(0)
    SET my_stat = uar_crmperform(s_hstep)
    IF (my_stat)
     CASE (s_option)
      OF 0:
       SET table_name = build("ERROR-->s_uar_crmperform (",s_hstep,",",s_option,") returned [",
        my_stat,"]")
       CALL echo(table_name)
       SET failed = uar_error
       GO TO exit_script
      OF 1:
       CALL echo(build("ERROR-->s_uar_crmperform (",s_hstep,",",s_option,") returned [",
         my_stat,"]"))
     ENDCASE
    ENDIF
    RETURN(my_stat)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmperformas(s_hstep=i4,s_option=i4,s_service=vc) =i4)
   IF (s_hstep > 0)
    DECLARE my_stat = i2 WITH protect, noconstant(0)
    SET my_stat = uar_crmperformas(s_hstep,s_service)
    IF (my_stat)
     CASE (s_option)
      OF 0:
       SET table_name = build("ERROR-->s_uar_crmperformas (",s_hstep,",",s_option,") returned [",
        my_stat,"]")
       CALL echo(table_name)
       SET failed = uar_error
       GO TO exit_script
      OF 1:
       CALL echo(build("ERROR-->s_uar_crmperformas (",s_hstep,",",s_option,") returned [",
         my_stat,"]"))
     ENDCASE
    ENDIF
    RETURN(my_stat)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmgetrequest(s_hstep=i4,s_option=i4) =i4)
   IF (s_hstep > 0)
    DECLARE s_hrequest = i4 WITH protect, noconstant(0)
    SET s_hrequest = uar_crmgetrequest(s_hstep)
    IF (s_hrequest=0)
     CASE (s_option)
      OF 0:
       SET table_name = build("ERROR-->s_uar_crmgetrequest (",s_hstep,",",s_option,") returned [",
        s_hrequest,"]")
       CALL echo(table_name)
       SET failed = uar_error
       GO TO exit_script
      OF 1:
       CALL echo(build("ERROR-->s_uar_crmgetrequest (",s_hstep,",",s_option,") returned [",
         s_hrequest,"]"))
     ENDCASE
    ENDIF
    RETURN(s_hrequest)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmgetreply(s_hstep=i4,s_option=i4) =i4)
   IF (s_hstep > 0)
    DECLARE s_hreply = i4 WITH protect, noconstant(0)
    SET s_hreply = uar_crmgetreply(s_hstep)
    IF (s_hreply=0)
     CASE (s_option)
      OF 0:
       SET table_name = build("ERROR-->s_uar_crmgetreply (",s_hstep,",",s_option,") returned [",
        s_hreply,"]")
       CALL echo(table_name)
       SET failed = uar_error
       GO TO exit_script
      OF 1:
       CALL echo(build("ERROR-->s_uar_crmgetreply (",s_hstep,",",s_option,") returned [",
         s_hreply,"]"))
     ENDCASE
    ENDIF
    RETURN(s_hreply)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmendreq(s_hstep=i4(ref)) =null)
   IF (s_hstep > 0)
    DECLARE my_stat = i2 WITH protect, noconstant(0)
    SET my_stat = uar_crmendreq(s_hstep)
    SET s_hstep = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmendtask(s_htask=i4(ref)) =null)
   IF (s_htask > 0)
    DECLARE my_stat = i2 WITH protect, noconstant(0)
    SET my_stat = uar_crmendtask(s_htask)
    SET s_htask = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_crmendapp(s_happ=i4(ref)) =null)
   IF (s_happ > 0)
    DECLARE my_stat = i2 WITH protect, noconstant(0)
    SET my_stat = uar_crmendapp(s_happ)
    SET s_happ = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE (s_uar_echo_object(s_hobject=i4) =null)
   IF (s_hobject > 0)
    CALL uar_oen_dump_object(s_hobject)
   ENDIF
 END ;Subroutine
 SUBROUTINE (makeoauthcall(httprequest=vc(ref),httpreply=vc(ref),oauthtype=i2(value,0)) =i2 WITH
  protect)
   DECLARE oauthsuccessind = i2 WITH private, noconstant(0)
   SET oauthsuccessind = populateoauthheader(oauthtype,httprequest->logical_domain_id,httpreply)
   DECLARE soauthheader = vc WITH private, constant(httpreply->o_auth.header)
   IF (oauthsuccessind=0)
    RETURN(- (1))
   ENDIF
   EXECUTE srvuri
   DECLARE huri = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrequestbuffer = i4 WITH private, noconstant(0)
   DECLARE hresponsebuffer = i4 WITH private, noconstant(0)
   DECLARE hprop = i4 WITH private, noconstant(0)
   DECLARE hoauthprop = i4 WITH private, noconstant(0)
   DECLARE hresp = i4 WITH private, noconstant(0)
   DECLARE hrespprops = i4 WITH private, noconstant(0)
   DECLARE responsestatus = i4 WITH private, noconstant(0)
   DECLARE actual = i4 WITH private, noconstant(0)
   DECLARE lpos = i4 WITH private, noconstant(0)
   DECLARE respbuffersize = i4 WITH private, noconstant(0)
   DECLARE respbuffer = c524288 WITH private
   DECLARE read_buffer_size = i4 WITH private, constant(524288)
   DECLARE respstatuscode = c50 WITH private
   DECLARE respstatusdescription = c50 WITH private
   SET huri = uar_srv_geturiparts(value(httprequest->uri))
   SET hreq = uar_srv_createwebrequest(huri)
   SET hprop = uar_srv_createproplist()
   SET hoauthprop = uar_srv_createproplist()
   SET hrequestbuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
    0)
   SET stat = uar_srv_setbufferpos(hrequestbuffer,0,0,lpos)
   SET stat = uar_srv_setpropstring(hprop,"method",nullterm(httprequest->method))
   IF (size(httprequest->request_body_json) > 0)
    SET stat = uar_srv_writebuffer(hrequestbuffer,httprequest->request_body_json,size(httprequest->
      request_body_json),actual)
   ENDIF
   SET stat = uar_srv_setpropstring(hprop,"accept","*/*")
   SET stat = uar_srv_setpropstring(hprop,"contenttype","application/json")
   SET stat = uar_srv_setpropstring(hoauthprop,"Authorization",nullterm(soauthheader))
   SET stat = uar_srv_setprophandle(hprop,"customHeaders",hoauthprop,1)
   SET stat = uar_srv_setprophandle(hprop,"reqBuffer",hrequestbuffer,1)
   SET stat = uar_srv_setwebrequestprops(hreq,hprop)
   SET hresponsebuffer = uar_srv_creatememorybuffer(3,0,0,0,0,
    0)
   SET hresp = uar_srv_getwebresponse(hreq,hresponsebuffer)
   SET hrespprops = uar_srv_getwebresponseprops(hresp)
   SET stat = uar_srv_getpropstring(hrespprops,"statusCode",respstatuscode,50)
   SET stat = uar_srv_getpropstring(hrespprops,"statusDesc",respstatusdescription,50)
   SET stat = uar_srv_getmemorybuffersize(hresponsebuffer,respbuffersize)
   SET stat = uar_srv_setbufferpos(hresponsebuffer,0,0,lpos)
   SET stat = uar_srv_readbuffer(hresponsebuffer,respbuffer,read_buffer_size,actual)
   SET httpreply->response_body = respbuffer
   SET httpreply->status_code = respstatuscode
   SET httpreply->status_description = respstatusdescription
   SET responsestatus = uar_srv_closehandle(huri)
   SET responsestatus = uar_srv_closehandle(hreq)
   SET responsestatus = uar_srv_closehandle(hrequestbuffer)
   SET responsestatus = uar_srv_closehandle(hresponsebuffer)
   SET responsestatus = uar_srv_closehandle(hprop)
   SET responsestatus = uar_srv_closehandle(hoauthprop)
   SET responsestatus = uar_srv_closehandle(hrespprops)
   SET responsestatus = uar_srv_closehandle(hresp)
   RETURN(hresp)
 END ;Subroutine
 SUBROUTINE (populateoauthheader(oauthtype=i2(value,0),logicaldomainid=f8(value,0),httpreply=vc(ref)
  ) =i2 WITH protect)
   DECLARE requestnumber = i4 WITH private, noconstant(0.0)
   IF (oauthtype=1)
    SET requestnumber = 99999132
   ELSE
    SET requestnumber = 99999131
   ENDIF
   DECLARE oauth_message = i4 WITH private, constant(uar_srvselectmessage(requestnumber))
   DECLARE oauth_request = i4 WITH private, constant(uar_srvcreaterequest(oauth_message))
   DECLARE oauth_response = i4 WITH private, constant(uar_srvcreatereply(oauth_message))
   DECLARE sauth = vc WITH private, noconstant("")
   IF (oauthtype=1)
    IF (logicaldomainid=0.0)
     SET sauth = build2("urn:uuid:c91c8fb6-e48e-4307-8f05-b45e87fb007a")
    ELSE
     SET sauth = build2("urn:cerner:mid:logical_domain:",nullterm(cnvtlower(curdomain)),":",trim(
       cnvtstring(logicaldomainid,16),3))
    ENDIF
    CALL echo(sauth)
    SET stat = uar_srvsetstring(oauth_request,"business_relationship_name",nullterm(sauth))
   ENDIF
   DECLARE hoauthstatus = i4 WITH private, noconstant(0)
   DECLARE successind = i2 WITH private, noconstant(0)
   SET stat = uar_srvexecute(oauth_message,oauth_request,oauth_response)
   SET hoauthstatus = uar_srvgetstruct(oauth_response,"status")
   SET successind = uar_srvgetshort(hoauthstatus,"success_ind")
   SET httpreply->o_auth.status_data.success_ind = successind
   IF (successind=0)
    SET httpreply->o_auth.status_data.error_code = uar_srvgetstringptr(hoauthstatus,"error_code")
    SET hdiagnostictext = uar_srvgetstruct(hoauthstatus,"diagnostic_text")
    SET ilinecnt = uar_srvgetitemcount(hdiagnostictext,"lines")
    SET stat = alterlist(httpreply->o_auth.status_data.diagnostic_text.lines,ilinecnt)
    FOR (x = 1 TO ilinecnt)
     SET hline = uar_srvgetitem(hdiagnostictext,"lines",x)
     SET httpreply->o_auth.status_data.diagnostic_text.lines[x].line = uar_srvgetstringptr(hline,
      "line")
    ENDFOR
   ENDIF
   DECLARE ccldate = dq8 WITH private, noconstant(0)
   DECLARE epochdatestart = f8 WITH private, noconstant(0.0)
   DECLARE epochdatecurrent = f8 WITH private, noconstant(0.0)
   DECLARE epochdate = i4 WITH private, noconstant(0)
   SET ccldate = cnvtdatetime(sysdate)
   SET epochdatestart = (cnvtdatetime("01-JAN-1970")/ 10000000)
   SET epochdatecurrent = (ccldate/ 10000000)
   SET epochdate = (epochdatecurrent - epochdatestart)
   DECLARE oauthresponse = i4 WITH private, noconstant(0)
   DECLARE oauthtoken = vc WITH private, noconstant("")
   DECLARE oauthtokensecret = vc WITH private, noconstant("")
   DECLARE oauthconsumerkey = vc WITH private, noconstant("")
   DECLARE oauthaccessorsecret = vc WITH private, noconstant("")
   DECLARE oauthnonce = vc WITH private, noconstant("")
   DECLARE oauthtimestamp = vc WITH private, noconstant("")
   DECLARE oauthsignature = vc WITH private, noconstant("")
   DECLARE oauthheader = vc WITH private, noconstant("")
   DECLARE oauth_version = vc WITH private, constant("1.0")
   DECLARE oauth_signature_method = vc WITH private, constant("PLAINTEXT")
   SET oauthresponse = uar_srvgetstruct(oauth_response,"oauth_access_token")
   SET oauthtoken = uar_srvgetstringptr(oauthresponse,"oauth_token")
   SET oauthtokensecret = uar_srvgetstringptr(oauthresponse,"oauth_token_secret")
   SET oauthconsumerkey = uar_srvgetstringptr(oauthresponse,"oauth_consumer_key")
   SET oauthaccessorsecret = uar_srvgetstringptr(oauthresponse,"oauth_accessor_secret")
   SET oauthnonce = uar_srvgetstringptr(oauthresponse,"oauth_nonce")
   SET oauthtimestamp = trim(cnvtstring(epochdate),3)
   SET oauthnonce = trim(format((epochdatecurrent * epochdatestart),build(fillstring(31,"#"),";T(1)")
     ),3)
   SET oauthsignature = concat(oauthaccessorsecret,"%26",oauthtokensecret)
   SET oauthheader = concat('OAuth oauth_token="',oauthtoken,'", oauth_version="',oauth_version,
    '", oauth_consumer_key="',
    oauthconsumerkey,'", oauth_signature_method="',oauth_signature_method,'", oauth_signature="',
    oauthsignature,
    '", oauth_timestamp="',oauthtimestamp,'", oauth_nonce="',oauthnonce,'"')
   SET httpreply->o_auth.header = oauthheader
   RETURN(successind)
 END ;Subroutine
 FREE RECORD rdat
 RECORD rdat(
   1 log_ind = i2
   1 from_id = f8
   1 subject = vc
   1 adv_reminder = i4
   1 appt_type_cds[*]
     2 cd = f8
   1 appt_loc_cds[*]
     2 cd = f8
   1 appt_provider_ids[*]
     2 id = f8
 )
 FREE RECORD t_record
 RECORD t_record(
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 name = vc
     2 alias = vc
     2 sch_event_id = f8
     2 beg_dt_tm = dq8
     2 appt_type_cd = f8
     2 appt_location_cd = f8
     2 clip_activation_url = vc
     2 clip_activation_stat = i2
 )
 FREE RECORD tmp_qual_provider
 RECORD tmp_qual_provider(
   1 tmp_qual_cnt = i4
   1 tmp_qual[*]
     2 sch_event_id = f8
     2 appt_type_cd = f8
 )
 FREE RECORD rlog
 RECORD rlog(
   1 file_name = vc
   1 ops_job_last_run = vc
   1 messages[*]
     2 text = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = i4 WITH public, noconstant(false)
 DECLARE table_name = vc WITH public, noconstant(curprog)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE hprsnl = i4 WITH public, noconstant(0)
 DECLARE appid = i4 WITH protect, constant(3202004)
 DECLARE taskid = i4 WITH protect, constant(3202004)
 DECLARE nloccnt = i4 WITH noconstant(0)
 DECLARE ntypecnt = i4 WITH noconstant(0)
 DECLARE nprovidercnt = i4 WITH noconstant(0)
 DECLARE loc_cd = vc WITH protect
 DECLARE type_cd = vc WITH protect
 DECLARE provider_person_id = vc WITH protect
 DECLARE t_ops_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE t_batch_selection = vc WITH protect, noconstant(" ")
 DECLARE t_full_batch_selection = vc WITH protect, noconstant(" ")
 DECLARE t_date = vc WITH protect, noconstant(" ")
 DECLARE t_beg_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE t_end_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE t_dt_ops_last_run = dq8 WITH protect, noconstant(null)
 DECLARE t_messaging_cd = f8 WITH protect, constant(loadcodevalue(4,"MESSAGING",0))
 DECLARE t_status_complete_cd = f8 WITH protect, constant(loadcodevalue(460,"COMPLETE",0))
 DECLARE nlogmsgcnt = i4 WITH protect, noconstant(0)
 DECLARE t_log_ind = i2 WITH protect, noconstant(1)
 DECLARE errormsg = vc WITH protect, noconstant(" ")
 DECLARE script_begin_dt_tm = dq8 WITH private, constant(cnvtdatetime(sysdate))
 DECLARE logical_domain_id = i4 WITH protect, noconstant(0)
 DECLARE opsrequestnumber = i4 WITH protect, constant(651986)
 DECLARE dummy = i4 WITH protect, constant(0)
 DECLARE findopsjobdatebyschema(dummy) = null WITH protect
 DECLARE findopsjobdatebyserver(dummy) = null WITH protect
 SUBROUTINE findopsjobdatebyschema(dummy)
   SELECT INTO "nl:"
    FROM ops_job_step ojs,
     ops_task ot,
     ops_schedule_task ost
    PLAN (ojs
     WHERE ojs.request_number=opsrequestnumber
      AND cnvtlower(replace(ojs.batch_selection," ",""))=cnvtlower(replace(concat(curprog,
        t_batch_selection)," ",""))
      AND ojs.active_ind=1
      AND ojs.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ojs.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ot
     WHERE ot.ops_job_id=ojs.ops_job_id
      AND ot.active_ind=1
      AND ot.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ot.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ost
     WHERE ost.ops_task_id=ot.ops_task_id
      AND ost.status_cd=t_status_complete_cd
      AND ost.active_ind=1
      AND ost.end_effective_dt_tm < cnvtdatetime(sysdate))
    ORDER BY ost.end_effective_dt_tm DESC
    HEAD REPORT
     t_dt_ops_last_run = cnvtdatetime(ost.beg_effective_dt_tm)
    WITH nocounter, check, rdbrange
   ;end select
 END ;Subroutine
 SUBROUTINE findopsjobdatebyserver(dummy)
   FREE RECORD requestin
   RECORD requestin(
     1 active_ind = i2
   )
   SET requestin->active_ind = 1
   DECLARE ctrlgrpcnt = i4 WITH protect, noconstant(0)
   DECLARE requestjobsid = i4 WITH protect, constant(4115)
   DECLARE requestjobgroupsid = i4 WITH protect, constant(4120)
   SET stat = tdbexecute(appid,taskid,requestjobsid,"REC",requestin,
    "REC",replyout)
   IF (stat != 0)
    SET errormsg = build("Call to ops agent service 4115 returned error: ",stat)
    CALL addlogmessage(errormsg)
    RETURN
   ELSEIF ((replyout->status_data="F"))
    SET errormsg = build("Transaction 4115 failed: ",replyout->status_data.sub_status.error_code,",",
     replyout->status_data.sub_status.specific_code)
    CALL addlogmessage(errormsg)
    RETURN
   ENDIF
   FREE RECORD controlgrouplist
   RECORD controlgrouplist(
     1 qual[*]
       2 controlgroup = f8
   )
   FOR (x = 1 TO size(replyout->job_list,5))
     FOR (y = 1 TO size(replyout->job_list[x].daily_job.step_list,5))
       IF ((replyout->job_list[x].daily_job.step_list[y].request_number=opsrequestnumber)
        AND cnvtlower(replace(replyout->job_list[x].daily_job.step_list[y].batch_selection," ",""))=
       t_full_batch_selection)
        SET ctrlgrpcnt += 1
        IF (mod(ctrlgrpcnt,10)=1)
         SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
        ENDIF
        SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_list[x].daily_job.
        control_group_id
       ENDIF
     ENDFOR
     FOR (y = 1 TO size(replyout->job_list[x].one_time_job.step_list,5))
       IF ((replyout->job_list[x].one_time_job.step_list[y].request_number=opsrequestnumber)
        AND cnvtlower(replace(replyout->job_list[x].one_time_job.step_list[y].batch_selection," ","")
        )=t_full_batch_selection)
        SET ctrlgrpcnt += 1
        IF (mod(ctrlgrpcnt,10)=1)
         SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
        ENDIF
        SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_list[x].one_time_job.
        control_group_id
       ENDIF
     ENDFOR
     FOR (y = 1 TO size(replyout->job_list[x].weekly_job.step_list,5))
       IF ((replyout->job_list[x].weekly_job.step_list[y].request_number=opsrequestnumber)
        AND cnvtlower(replace(replyout->job_list[x].weekly_job.step_list[y].batch_selection," ",""))=
       t_full_batch_selection)
        SET ctrlgrpcnt += 1
        IF (mod(ctrlgrpcnt,10)=1)
         SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
        ENDIF
        SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_list[x].weekly_job.
        control_group_id
       ENDIF
     ENDFOR
     FOR (y = 1 TO size(replyout->job_list[x].day_of_month_job.step_list,5))
       IF ((replyout->job_list[x].day_of_month_job.step_list[y].request_number=opsrequestnumber)
        AND cnvtlower(replace(replyout->job_list[x].day_of_month_job.step_list[y].batch_selection," ",
         ""))=t_full_batch_selection)
        SET ctrlgrpcnt += 1
        IF (mod(ctrlgrpcnt,10)=1)
         SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
        ENDIF
        SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_list[x].day_of_month_job.
        control_group_id
       ENDIF
     ENDFOR
     FOR (y = 1 TO size(replyout->job_list[x].week_of_month_job.step_list,5))
       IF ((replyout->job_list[x].week_of_month_job.step_list[y].request_number=opsrequestnumber)
        AND cnvtlower(replace(replyout->job_list[x].week_of_month_job.step_list[y].batch_selection,
         " ",""))=t_full_batch_selection)
        SET ctrlgrpcnt += 1
        IF (mod(ctrlgrpcnt,10)=1)
         SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
        ENDIF
        SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_list[x].week_of_month_job
        .control_group_id
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(controlgrouplist->qual,ctrlgrpcnt)
   IF (size(controlgrouplist->qual,5) <= 0)
    FREE RECORD replyout
    SET stat = tdbexecute(appid,taskid,requestjobgroupsid,"REC",requestin,
     "REC",replyout)
    IF (stat != 0)
     SET errormsg = build("Call to ops agent service 4120 returned error: ",stat)
     CALL addlogmessage(errormsg)
     RETURN
    ELSEIF ((replyout->status_data="F"))
     SET errormsg = build("Transaction 4120 failed: ",replyout->status_data.sub_status.error_code,",",
      replyout->status_data.sub_status.specific_code)
     CALL addlogmessage(errormsg)
     RETURN
    ENDIF
    FOR (x = 1 TO size(replyout->job_group_list,5))
      FOR (y = 1 TO size(replyout->job_group_list[x].daily_job_group.job_list,5))
        FOR (z = 1 TO size(replyout->job_group_list[x].daily_job_group.job_list[y].step_list,5))
          IF ((replyout->job_group_list[x].daily_job_group.job_list[y].step_list[z].request_number=
          opsrequestnumber)
           AND cnvtlower(replace(replyout->job_group_list[x].daily_job_group.job_list[y].step_list[z]
            .batch_selection," ",""))=t_full_batch_selection)
           SET ctrlgrpcnt += 1
           IF (mod(ctrlgrpcnt,10)=1)
            SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
           ENDIF
           SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_group_list[x].
           daily_job_group.control_group_id
          ENDIF
        ENDFOR
      ENDFOR
      FOR (y = 1 TO size(replyout->job_group_list[x].one_time_job_group.job_list,5))
        FOR (z = 1 TO size(replyout->job_group_list[x].one_time_job_group.job_list[y].step_list,5))
          IF ((replyout->job_group_list[x].one_time_job_group.job_list[y].step_list[z].request_number
          =opsrequestnumber)
           AND cnvtlower(replace(replyout->job_group_list[x].one_time_job_group.job_list[y].
            step_list[z].batch_selection," ",""))=t_full_batch_selection)
           SET ctrlgrpcnt += 1
           IF (mod(ctrlgrpcnt,10)=1)
            SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
           ENDIF
           SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_group_list[x].
           one_time_job_group.control_group_id
          ENDIF
        ENDFOR
      ENDFOR
      FOR (y = 1 TO size(replyout->job_group_list[x].weekly_job_group.job_list,5))
        FOR (z = 1 TO size(replyout->job_group_list[x].weekly_job_group.job_list[y].step_list,5))
          IF ((replyout->job_group_list[x].weekly_job_group.job_list[y].step_list[z].request_number=
          opsrequestnumber)
           AND cnvtlower(replace(replyout->job_group_list[x].weekly_job_group.job_list[y].step_list[z
            ].batch_selection," ",""))=t_full_batch_selection)
           SET ctrlgrpcnt += 1
           IF (mod(ctrlgrpcnt,10)=1)
            SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
           ENDIF
           SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_group_list[x].
           weekly_job_group.control_group_id
          ENDIF
        ENDFOR
      ENDFOR
      FOR (y = 1 TO size(replyout->job_group_list[x].day_of_month_job_group.job_list,5))
        FOR (z = 1 TO size(replyout->job_group_list[x].day_of_month_job_group.job_list[y].step_list,5
         ))
          IF ((replyout->job_group_list[x].day_of_month_job_group.job_list[y].step_list[z].
          request_number=opsrequestnumber)
           AND cnvtlower(replace(replyout->job_group_list[x].day_of_month_job_group.job_list[y].
            step_list[z].batch_selection," ",""))=t_full_batch_selection)
           SET ctrlgrpcnt += 1
           IF (mod(ctrlgrpcnt,10)=1)
            SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
           ENDIF
           SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_group_list[x].
           day_of_month_job_group.control_group_id
          ENDIF
        ENDFOR
      ENDFOR
      FOR (y = 1 TO size(replyout->job_group_list[x].week_of_month_job_group.job_list,5))
        FOR (z = 1 TO size(replyout->job_group_list[x].week_of_month_job_group.job_list[y].step_list,
         5))
          IF ((replyout->job_group_list[x].week_of_month_job_group.job_list[y].step_list[z].
          request_number=opsrequestnumber)
           AND cnvtlower(replace(replyout->job_group_list[x].week_of_month_job_group.job_list[y].
            step_list[z].batch_selection," ",""))=t_full_batch_selection)
           SET ctrlgrpcnt += 1
           IF (mod(ctrlgrpcnt,10)=1)
            SET stat = alterlist(controlgrouplist->qual,(ctrlgrpcnt+ 9))
           ENDIF
           SET controlgrouplist->qual[ctrlgrpcnt].controlgroup = replyout->job_group_list[x].
           week_of_month_job_group.control_group_id
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
    SET stat = alterlist(controlgrouplist->qual,ctrlgrpcnt)
   ENDIF
   IF (size(controlgrouplist->qual,5) <= 0)
    SET errormsg = "No control group for ops job found."
    CALL addlogmessage(errormsg)
   ELSE
    IF (t_log_ind=1)
     CALL echorecord(controlgrouplist)
    ENDIF
    FREE RECORD replyout
    FREE RECORD requestin
    RECORD requestin(
      1 start_date_time = dq8
      1 end_date_time = dq8
    )
    SET requestin->start_date_time = datetimeadd(t_ops_dt_tm,- (3))
    SET requestin->end_date_time = t_ops_dt_tm
    DECLARE getschstaterequestid = i4 WITH protect, constant(4146)
    SET stat = tdbexecute(appid,taskid,getschstaterequestid,"REC",requestin,
     "REC",replyout)
    IF (stat != 0)
     SET errormsg = build("Call to ops agent service 4146 returned error: ",stat)
     CALL addlogmessage(errormsg)
     RETURN
    ELSEIF ((replyout->status_data="F"))
     SET errormsg = build("Transaction 4146 failed: ",replyout->status_data.sub_status.error_code,",",
      replyout->status_data.sub_status.specific_code)
     CALL addlogmessage(errormsg)
     RETURN
    ENDIF
    DECLARE t_record_index = i4 WITH private, noconstant(0)
    DECLARE locate_val_index = i4 WITH private, noconstant(0)
    FOR (x = 1 TO size(replyout->scheduled_control_group_list,5))
     SET t_record_index = locateval(locate_val_index,0,size(controlgrouplist->qual,5),replyout->
      scheduled_control_group_list[x].control_group_id,controlgrouplist->qual[locate_val_index].
      controlgroup)
     IF ((replyout->scheduled_control_group_list[x].control_group_id=controlgrouplist->qual[
     t_record_index].controlgroup))
      FOR (y = 1 TO size(replyout->scheduled_control_group_list[x].scheduled_job_list,5))
        FOR (z = 1 TO size(replyout->scheduled_control_group_list[x].scheduled_job_list[y].
         scheduled_step_list,5))
          IF ((replyout->scheduled_control_group_list[x].scheduled_job_list[y].scheduled_step_list[z]
          .request_number=opsrequestnumber)
           AND cnvtlower(replace(replyout->scheduled_control_group_list[x].scheduled_job_list[y].
            scheduled_step_list[z].batch_selection," ",""))=t_full_batch_selection
           AND (replyout->scheduled_control_group_list[x].scheduled_job_list[y].scheduled_step_list[z
          ].status_cd=t_status_complete_cd))
           IF ((replyout->scheduled_control_group_list[x].scheduled_job_list[y].scheduled_step_list[z
           ].end_date_time > t_dt_ops_last_run))
            SET t_dt_ops_last_run = replyout->scheduled_control_group_list[x].scheduled_job_list[y].
            scheduled_step_list[z].end_date_time
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
      FOR (a = 1 TO size(replyout->scheduled_control_group_list[x].scheduled_job_group_list,5))
        FOR (b = 1 TO size(replyout->scheduled_control_group_list[x].scheduled_job_group_list[a].
         scheduled_job_list,5))
          FOR (c = 1 TO size(replyout->scheduled_control_group_list[x].scheduled_job_group_list[a].
           scheduled_job_list[b].scheduled_step_list,5))
            IF ((replyout->scheduled_control_group_list[x].scheduled_job_group_list[a].
            scheduled_job_list[b].scheduled_step_list.request_number=opsrequestnumber)
             AND cnvtlower(replace(replyout->scheduled_control_group_list[x].
              scheduled_job_group_list[a].scheduled_job_list[b].scheduled_step_list.batch_selection,
              " ",""))=t_full_batch_selection
             AND (replyout->scheduled_control_group_list[x].scheduled_job_group_list[a].
            scheduled_job_list[b].scheduled_step_list[c].status_cd=t_status_complete_cd))
             IF ((replyout->scheduled_control_group_list[x].scheduled_job_group_list[a].
             scheduled_job_list[b].scheduled_step_list[c].end_date_time > t_dt_ops_last_run))
              SET t_dt_ops_last_run = replyout->scheduled_control_group_list[x].
              scheduled_job_group_list[a].scheduled_job_list[b].scheduled_step_list[c].end_date_time
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (populateactivationlink(person_id=f8,sch_event_id=f8,appt_location_cd=f8,appt_type_cd=f8
  ) =null WITH protect)
   FREE RECORD portalhttpreq
   RECORD portalhttpreq(
     1 method = vc
     1 request_body_json = vc
     1 uri = vc
     1 logical_domain_id = f8
   ) WITH protect
   FREE RECORD portalhttpresp
   RECORD portalhttpresp(
     1 o_auth
       2 header = vc
       2 status_data
         3 success_ind = i2
         3 error_code = c5
         3 diagnostic_text
           4 lines[*]
             5 line = vc
     1 response_body = vc
     1 status_code = c50
     1 status_description = vc
   ) WITH protect
   FREE RECORD millennium_appointment
   RECORD millennium_appointment(
     1 person_id = vc
     1 appointment_id = vc
     1 location_id = vc
     1 appointment_type_id = vc
   ) WITH private
   SET millennium_appointment->person_id = build(cnvtlong(person_id))
   SET millennium_appointment->appointment_id = build(cnvtlong(sch_event_id))
   SET millennium_appointment->location_id = build(cnvtlong(appt_location_cd))
   SET millennium_appointment->appointment_type_id = build(cnvtlong(appt_type_cd))
   DECLARE convert_props_to_lowercase = i2 WITH private, constant(2)
   DECLARE portal_activation_url = vc WITH private, constant(build(t_url,
     "/api/clipboards/activations/"))
   SET portalhttpreq->method = "post"
   SET portalhttpreq->request_body_json = cnvtrectojson(millennium_appointment,
    convert_props_to_lowercase)
   SET portalhttpreq->uri = portal_activation_url
   SET portalhttpreq->logical_domain_id = logical_domain_id
   IF (t_log_ind=1)
    CALL echo(build("Portal request json : ",portalhttpreq->request_body_json))
   ENDIF
   SET stat = makeoauthcall(portalhttpreq,portalhttpresp,1)
   IF (t_log_ind=1)
    CALL echorecord(portalhttpresp)
   ENDIF
   DECLARE t_record_index = i4 WITH private, noconstant(0)
   DECLARE locate_val_index = i4 WITH private, noconstant(0)
   SET t_record_index = locateval(locate_val_index,0,size(t_record->person_qual,5),sch_event_id,
    t_record->person_qual[locate_val_index].sch_event_id)
   IF ((stat=- (1)))
    SET table_name = build2("Failed to retrieve Oauth token for person ",t_record->person_qual[
     t_record_index].person_id)
    CALL addlogmessage(build2("The portal activation http call failed with an oauth error.",
      " Request : ",portalhttpreq->request_body_json," Response : ",portalhttpresp->response_body,
      " Status code: ",portalhttpresp->status_code," Status description : ",portalhttpresp->
      status_description," Oauth error code from 99999132: ",
      portalhttpresp->o_auth.status_data.error_code))
    FOR (x = 0 TO (size(portalhttpresp->o_auth.status_data.diagnostic_text.lines,5) - 1))
      CALL addlogmessage(build2("Oauth diagnostic text :",portalhttpresp->o_auth.status_data.
        diagnostic_text.lines[x].line))
    ENDFOR
    SET failed = true
    GO TO exit_script
   ENDIF
   IF (((stat=0) OR (((findstring("503",portalhttpresp->status_code)=1) OR (((findstring("401",
    portalhttpresp->status_code)=1) OR (findstring("403",portalhttpresp->status_code)=1)) )) )) )
    SET table_name = build2("Failed to retrieve Portal Activation URL for patient ",t_record->
     person_qual[t_record_index].person_id)
    CALL addlogmessage(build2(
      "The portal activation http call failed with http or major server error."," Request : ",
      portalhttpreq->request_body_json," Response : ",portalhttpresp->response_body,
      " Status code: ",portalhttpresp->status_code," Status description :",portalhttpresp->
      status_description))
    SET failed = true
    GO TO exit_script
   ENDIF
   IF (findstring("200",portalhttpresp->status_code)=0
    AND findstring("201",portalhttpresp->status_code)=0)
    SET table_name = build2("Failed to retrieve Portal Activation URL for patient ",t_record->
     person_qual[t_record_index].person_id)
    CALL addlogmessage(build2("The portal activation http call failed."," Request : ",portalhttpreq->
      request_body_json," Response : ",portalhttpresp->response_body,
      " Status code : ",portalhttpresp->status_code," Status description :",portalhttpresp->
      status_description))
    SET t_record->person_qual[t_record_index].clip_activation_stat = 0
    RETURN
   ELSE
    SET t_record->person_qual[t_record_index].clip_activation_stat = 1
   ENDIF
   DECLARE portal_activation_link_prop = vc WITH private, constant(cnvtupper(build(
      "https://api.iqhealth.com/rels/clipboard-portal-website")))
   DECLARE portalactivationlink = vc WITH private, noconstant("")
   SET stat = cnvtjsontorec(build('{"PORTAL_ACTIVATION":',portalhttpresp->response_body,"}"))
   SET portalactivationlink = parser(build('PORTAL_ACTIVATION->_LINKS->"',portal_activation_link_prop,
     '"'))
   SET t_record->person_qual[t_record_index].clip_activation_url = portalactivationlink
   IF (t_log_ind=1)
    CALL echo(build2("Portal activation link : ",portalactivationlink))
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (populatemodernhealthelifeactivationlink(person_id=f8,sch_event_id=f8,appt_location_cd=f8,
  appt_type_cd=f8,beg_dt_tm=dq8) =null WITH protect)
   FREE RECORD portalhttpreq
   RECORD portalhttpreq(
     1 method = vc
     1 request_body_json = vc
     1 uri = vc
     1 logical_domain_id = f8
   ) WITH protect
   FREE RECORD portalhttpresp
   RECORD portalhttpresp(
     1 o_auth
       2 header = vc
       2 status_data
         3 success_ind = i2
         3 error_code = c5
         3 diagnostic_text
           4 lines[*]
             5 line = vc
     1 response_body = vc
     1 status_code = c50
     1 status_description = vc
   ) WITH protect
   FREE RECORD appointment_clipboard
   RECORD appointment_clipboard(
     1 event_type = vc
     1 location_id = vc
     1 appointment_event
       2 id = vc
       2 appointment_at = dq8
       2 appointment_type_id = vc
     1 created_by_id = vc
   ) WITH private
   SET appointment_clipboard->event_type = "APPOINTMENT"
   SET appointment_clipboard->location_id = build(cnvtlong(appt_location_cd))
   SET appointment_clipboard->appointment_event.id = build(cnvtlong(sch_event_id))
   SET appointment_clipboard->appointment_event.appointment_at = beg_dt_tm
   SET appointment_clipboard->appointment_event.appointment_type_id = build(cnvtlong(appt_type_cd))
   SET appointment_clipboard->created_by_id = "CLIPBOARDAPPTOPSJOB"
   DECLARE convert_props_to_camelcase = i2 WITH private, constant(9)
   DECLARE portal_activation_url = vc WITH private, constant(build(t_healtheintent_url,
     "/consumer-engagement/v1/patients/",cnvtlong(person_id),"/clipboard-events"))
   SET portalhttpreq->method = "post"
   SET portalhttpreq->request_body_json = cnvtrectojson(appointment_clipboard,
    convert_props_to_camelcase)
   SET portalhttpreq->uri = portal_activation_url
   SET portalhttpreq->logical_domain_id = logical_domain_id
   IF (t_log_ind=1)
    CALL echo(build("Modern Healthelife Portal request json : ",portalhttpreq->request_body_json))
   ENDIF
   SET stat = makeoauthcall(portalhttpreq,portalhttpresp,1)
   IF (t_log_ind=1)
    CALL echorecord(portalhttpresp)
   ENDIF
   DECLARE t_record_index = i4 WITH private, noconstant(0)
   DECLARE locate_val_index = i4 WITH private, noconstant(0)
   SET t_record_index = locateval(locate_val_index,0,size(t_record->person_qual,5),sch_event_id,
    t_record->person_qual[locate_val_index].sch_event_id)
   IF ((stat=- (1)))
    SET table_name = build2("Failed to retrieve Modern Healthelife Oauth token for person ",t_record
     ->person_qual[t_record_index].person_id)
    CALL addlogmessage(build2(
      "The Modern Healthelife portal activation http call failed with an oauth error."," Request : ",
      portalhttpreq->request_body_json," Response : ",portalhttpresp->response_body,
      " Status code: ",portalhttpresp->status_code," Status description : ",portalhttpresp->
      status_description," Oauth error code from 99999132: ",
      portalhttpresp->o_auth.status_data.error_code))
    FOR (x = 0 TO (size(portalhttpresp->o_auth.status_data.diagnostic_text.lines,5) - 1))
      CALL addlogmessage(build2("Modern Healthelife Oauth diagnostic text :",portalhttpresp->o_auth.
        status_data.diagnostic_text.lines[x].line))
    ENDFOR
    SET failed = true
    GO TO exit_script
   ENDIF
   IF (((stat=0) OR (((findstring("503",portalhttpresp->status_code)=1) OR (((findstring("401",
    portalhttpresp->status_code)=1) OR (findstring("403",portalhttpresp->status_code)=1)) )) )) )
    SET table_name = build2(
     "Failed to retrieve Modern Healthelife Portal Activation URL for patient ",t_record->
     person_qual[t_record_index].person_id)
    CALL addlogmessage(build2(
      "The Modern Healthelife portal activation http call failed with http or major server error.",
      " Request : ",portalhttpreq->request_body_json," Response : ",portalhttpresp->response_body,
      " Status code: ",portalhttpresp->status_code," Status description :",portalhttpresp->
      status_description))
    SET failed = true
    GO TO exit_script
   ENDIF
   IF (findstring("200",portalhttpresp->status_code)=0
    AND findstring("201",portalhttpresp->status_code)=0)
    SET table_name = build2(
     "Failed to retrieve Modern Healthelife Portal Activation URL for patient ",t_record->
     person_qual[t_record_index].person_id)
    CALL addlogmessage(build2("The portal activation http call failed."," Request : ",portalhttpreq->
      request_body_json," Response : ",portalhttpresp->response_body,
      " Status code : ",portalhttpresp->status_code," Status description :",portalhttpresp->
      status_description))
    SET t_record->person_qual[t_record_index].clip_activation_stat = 0
    RETURN
   ELSE
    SET t_record->person_qual[t_record_index].clip_activation_stat = 1
   ENDIF
   DECLARE portalactivationlink = vc WITH private, noconstant("")
   SET stat = cnvtjsontorec(build('{"PORTAL_ACTIVATION":',portalhttpresp->response_body,"}"))
   SET portalactivationlink = build(parser(build("PORTAL_ACTIVATION->CLIPBOARDSBASEURL")),parser(
     build("PORTAL_ACTIVATION->CLIPBOARDS->LINK")))
   SET t_record->person_qual[t_record_index].clip_activation_url = portalactivationlink
   IF (t_log_ind=1)
    CALL echo(build2("Modern Healthelife Portal activation link : ",portalactivationlink))
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE addlogmessage(msg)
   SET nlogmsgcnt += 1
   SET stat = alterlist(rlog->messages,nlogmsgcnt)
   SET rlog->messages[nlogmsgcnt].text = msg
   IF (t_log_ind=1)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SET t_ops_dt_tm = cnvtdatetime( $2)
 IF (t_ops_dt_tm <= 0)
  SET t_ops_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 SET t_batch_selection =  $3
 IF (t_batch_selection > " ")
  SET t_init = s_init_parse(t_batch_selection,"[","]",";","=",
   0)
 ELSE
  SET errormsg = build("Parameters not found.")
  SET failed = attribute_error
  SET table_name = errormsg
  CALL addlogmessage(errormsg)
  GO TO exit_script
 ENDIF
 SET t_full_batch_selection = cnvtlower(replace(concat(curprog,t_batch_selection)," ",""))
 DECLARE stemplatefile = vc
 DECLARE t_file = vc WITH protect, noconstant(s_get_value_by_name("CONFIG",1))
 DECLARE sdatfile = vc WITH protect, constant(trim(t_file,3))
 IF (size(t_file) <= 1)
  SET errormsg = build("CONFIG paremeter not specified")
  SET failed = attribute_error
  SET table_name = errormsg
  CALL addlogmessage(errormsg)
  GO TO exit_script
 ENDIF
 SET rlog->file_name = sdatfile
 DECLARE idatfileexists = i2 WITH protect, constant(findfile(sdatfile))
 DECLARE validconfig = i2 WITH protect, noconstant(1)
 IF (idatfileexists=0)
  SET errormsg = build(sdatfile," file does not exist")
  SET failed = not_found
  SET table_name = errormsg
  CALL addlogmessage(errormsg)
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 sdatfile
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  DETAIL
   sline = trim(r.line,3)
   IF (size(sline) > 0)
    iparamcnt = 0, sfield = trim(piece(sline,"=",1,""),3), sparams = trim(piece(sline,"=",2,""),3)
    CASE (sfield)
     OF "MSGTEMPLATE":
      stemplatefile = trim(sparams,3)
     OF "LOCATION":
      loc_cd = "",
      WHILE (loc_cd != "Not Found")
        iparamcnt += 1, loc_cd = trim(piece(sparams,",",iparamcnt,"Not Found"),3)
        IF (loc_cd != "Not Found"
         AND size(loc_cd,1) > 0)
         nloccnt += 1, stat = alterlist(rdat->appt_loc_cds,nloccnt), rdat->appt_loc_cds[nloccnt].cd
          = cnvtreal(loc_cd)
        ENDIF
      ENDWHILE
     OF "APPOINTMENTTYPES":
      type_cd = "",
      WHILE (type_cd != "Not Found")
        iparamcnt += 1, type_cd = trim(piece(sparams,",",iparamcnt,"Not Found"),3)
        IF (type_cd != "Not Found"
         AND size(type_cd,1) > 0)
         ntypecnt += 1, stat = alterlist(rdat->appt_type_cds,ntypecnt), rdat->appt_type_cds[ntypecnt]
         .cd = cnvtreal(type_cd)
        ENDIF
      ENDWHILE
     OF "SUBJECT":
      rdat->subject = trim(sparams,3)
     OF "FROMID":
      rdat->from_id = cnvtreal(sparams)
     OF "DAYSADVANCE":
      rdat->adv_reminder = cnvtint(sparams)
     OF "LOGMSG":
      rdat->log_ind = cnvtint(sparams),t_log_ind = rdat->log_ind
     OF "PROVIDERS":
      provider_person_id = "",
      WHILE (provider_person_id != "Not Found")
        iparamcnt += 1, provider_person_id = trim(piece(sparams,",",iparamcnt,"Not Found"),3)
        IF (provider_person_id != "Not Found"
         AND size(provider_person_id,1) > 0)
         nprovidercnt += 1, stat = alterlist(rdat->appt_provider_ids,nprovidercnt), rdat->
         appt_provider_ids[nprovidercnt].id = cnvtreal(provider_person_id)
        ENDIF
      ENDWHILE
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(rdat)
 IF (ntypecnt <= 0)
  SET errormsg = build("No appointment types configured!")
  SET failed = not_found
  SET table_name = errormsg
  SET validconfig = 0
  CALL addlogmessage(errommsg)
 ENDIF
 IF (nloccnt <= 0)
  SET errormsg = build("No locations configured!")
  SET failed = not_found
  SET table_name = errormsg
  SET validconfig = 0
  CALL addlogmessage(errormsg)
 ENDIF
 IF (size(stemplatefile,1) <= 0)
  SET errormsg = build("No messaging template found!")
  SET failed = not_found
  SET table_name = errormsg
  SET validconfig = 0
  CALL addlogmessage(errormsg)
 ENDIF
 DECLARE t_text = vgc WITH protect
 IF (findfile(stemplatefile))
  FREE DEFINE rtl3
  DEFINE rtl3 stemplatefile
  SELECT INTO "nl:"
   r.line
   FROM rtl3t r
   DETAIL
    row + 1, t_text = concat(t_text,r.line)
   WITH maxrow = 1, maxcol = 8000, format = variable
  ;end select
 ELSE
  SET errormsg = build(stemplatefile," template file does not exist!")
  SET table_name = errormsg
  SET failed = not_found
  SET validconfig = 0
  CALL addlogmessage(errormsg)
 ENDIF
 SELECT INTO "nl:"
  o.logical_domain_id
  FROM location l,
   organization o
  PLAN (l
   WHERE (l.location_cd=rdat->appt_loc_cds[1].cd)
    AND l.active_ind > 0)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.active_ind > 0)
  DETAIL
   logical_domain_id = o.logical_domain_id
  WITH nocounter
 ;end select
 IF (t_log_ind=1)
  CALL echo(build("The logical domain is : ",logical_domain_id))
 ENDIF
 DECLARE t_url = vc WITH protect, noconstant("")
 DECLARE t_healtheintent_url = vc WITH protect, noconstant("")
 DECLARE patient_portal_url = vc WITH protect, constant("PATIENT PORTAL URL")
 DECLARE healthe_intent_url = vc WITH protect, constant("HEALTHE INTENT URL")
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain IN (patient_portal_url, healthe_intent_url)
   AND d.info_domain_id=logical_domain_id
  DETAIL
   IF (d.info_domain=healthe_intent_url)
    t_healtheintent_url = d.info_name
   ELSEIF (d.info_domain=patient_portal_url)
    t_url = d.info_name
   ENDIF
  WITH nocounter
 ;end select
 IF (t_log_ind=1)
  CALL echo(build2("The portal base url is : ",t_url))
  CALL echo(build2("The Healthe intent portal base url is : ",t_healtheintent_url))
 ENDIF
 IF (size(t_url,1) < 1
  AND size(t_healtheintent_url,1) < 1)
  SET errormsg = build("No portal url configured in dm_info!")
  SET table_name = errormsg
  SET failed = select_error
  SET validconfig = 0
  CALL addlogmessage(errormsg)
 ENDIF
 IF (validconfig=0)
  GO TO exit_script
 ENDIF
 DECLARE t_from = f8 WITH protect, noconstant(rdat->from_id)
 DECLARE t_subject = vc WITH protect, noconstant(rdat->subject)
 DECLARE t_adv_reminder = i4 WITH protect, noconstant(rdat->adv_reminder)
 DECLARE type_idx = i4 WITH protect, noconstant(0)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 IF (t_from < 1)
  SET t_from = reqinfo->updt_id
 ENDIF
 IF (t_subject <= " ")
  SET t_subject = "Clipboard Reminder"
 ENDIF
 IF (t_adv_reminder < 1)
  SET t_adv_reminder = 1
 ENDIF
 SET t_beg_dt_tm = datetimeadd(datetimefind(t_ops_dt_tm,"D","B","B"),t_adv_reminder)
 SET t_end_dt_tm = datetimeadd(datetimefind(t_ops_dt_tm,"D","E","E"),t_adv_reminder)
 DECLARE requestopsversionid = i4 WITH protect, constant(4249)
 DECLARE hreply = i4 WITH public, noconstant(0)
 DECLARE hmsg = i4 WITH public, noconstant(0)
 DECLARE fopsversion = f8 WITH protect, noconstant(0)
 DECLARE buseschema = i2 WITH protect, noconstant(false)
 SET stat = uar_crmbeginapp(appid,happ)
 IF (stat != 0)
  SET errormsg = build("get_ops_version: Call to uar_CrmBeginApp returned error: ",stat)
  CALL addlogmessage(errormsg)
  SET buseschema = true
  GO TO use_schema
 ENDIF
 SET stat = uar_crmbegintask(happ,taskid,htask)
 IF (stat != 0)
  SET errormsg = build("get_ops_version: Call to uar_CrmBeginTask returned error: ",stat)
  CALL addlogmessage(errormsg)
  SET buseschema = true
  GO TO use_schema
 ENDIF
 SET stat = uar_crmbeginreq(htask,"",requestopsversionid,hstep)
 IF (stat != 0)
  SET errormsg = build("get_ops_version: Call to uar_CrmBeginReq returned error: ",stat)
  CALL addlogmessage(errormsg)
  SET buseschema = true
  GO TO use_schema
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 IF (hrequest <= 0)
  SET errormsg = "get_ops_version: Call to uar_CrmGetRequest returned error."
  CALL addlogmessage(errormsg)
  SET buseschema = true
  GO TO use_schema
 ENDIF
 SET stat = uar_crmperform(hstep)
 IF (stat != 0)
  SET errormsg = build("get_ops_version: Call to uar_CrmPerform returned error: ",stat)
  CALL addlogmessage(errormsg)
  SET buseschema = true
  GO TO use_schema
 ELSE
  SET hreply = uar_crmgetreply(hstep)
  SET hrepstatus = uar_srvgetstruct(hreply,"status_data")
  SET status = uar_srvgetstringptr(hrepstatus,"status")
  IF (status="S")
   SET fopsversion = uar_srvgetdouble(hreply,"version")
   CALL addlogmessage(build("Ops Version: ",fopsversion))
   IF (fopsversion >= 2)
    CALL findopsjobdatebyserver(null)
   ELSE
    CALL findopsjobdatebyschema(null)
   ENDIF
  ELSE
   SET errormsg = build("get_ops_version: Call to uar_CrmGetReply returned error: ",status)
   CALL addlogmessage(errormsg)
   SET buseschema = true
   GO TO use_schema
  ENDIF
 ENDIF
#use_schema
 IF (buseschema=true)
  CALL findopsjobdatebyschema(null)
 ENDIF
 IF (t_dt_ops_last_run=null)
  CALL addlogmessage("Defaulting ops job last run date")
  SET t_dt_ops_last_run = datetimeadd(cnvtdatetime(sysdate),- (1))
 ENDIF
 CALL echo(build("last run date: ",format(t_dt_ops_last_run,"MM/DD/YYYY HH:mm:ss;;D")))
 IF (t_dt_ops_last_run != null)
  SET rlog->ops_job_last_run = format(t_dt_ops_last_run,"@SHORTDATETIME")
 ENDIF
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE tmp_provider_id = f8 WITH protect
 SELECT DISTINCT INTO "nl:"
  a.person_id, a.sch_event_id, a.role_meaning,
  se.appt_type_cd
  FROM sch_appt a,
   sch_event se
  PLAN (a
   WHERE ((a.beg_dt_tm >= cnvtdatetime(t_beg_dt_tm)
    AND a.beg_dt_tm <= cnvtdatetime(t_end_dt_tm)) OR (a.beg_dt_tm < cnvtdatetime(t_beg_dt_tm)
    AND a.beg_dt_tm > cnvtdatetime(t_ops_dt_tm)
    AND a.updt_dt_tm > cnvtdatetime(t_dt_ops_last_run)
    AND a.updt_dt_tm <= cnvtdatetime(t_ops_dt_tm)))
    AND a.sch_event_id > 0
    AND a.time_type_flag=1
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.state_meaning IN ("SCHEDULED", "CONFIRMED")
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND a.active_ind=1
    AND expand(loc_idx,1,nloccnt,a.appt_location_cd,rdat->appt_loc_cds[loc_idx].cd))
   JOIN (se
   WHERE a.sch_event_id=se.sch_event_id
    AND expand(type_idx,1,ntypecnt,se.appt_type_cd,rdat->appt_type_cds[type_idx].cd))
  ORDER BY a.sch_event_id, a.role_meaning
  HEAD a.sch_event_id
   IF (nprovidercnt > 0)
    IF (a.role_meaning != "PATIENT"
     AND locateval(locate_idx,1,nprovidercnt,a.person_id,rdat->appt_provider_ids[locate_idx].id) > 0)
     tmp_qual_provider->tmp_qual_cnt += 1
     IF (mod(tmp_qual_provider->tmp_qual_cnt,10)=1)
      stat = alterlist(tmp_qual_provider->tmp_qual,(tmp_qual_provider->tmp_qual_cnt+ 9))
     ENDIF
     tmp_qual_provider->tmp_qual[tmp_qual_provider->tmp_qual_cnt].sch_event_id = a.sch_event_id,
     tmp_qual_provider->tmp_qual[tmp_qual_provider->tmp_qual_cnt].appt_type_cd = se.appt_type_cd
    ENDIF
   ELSE
    tmp_qual_provider->tmp_qual_cnt += 1
    IF (mod(tmp_qual_provider->tmp_qual_cnt,10)=1)
     stat = alterlist(tmp_qual_provider->tmp_qual,(tmp_qual_provider->tmp_qual_cnt+ 9))
    ENDIF
    tmp_qual_provider->tmp_qual[tmp_qual_provider->tmp_qual_cnt].sch_event_id = a.sch_event_id,
    tmp_qual_provider->tmp_qual[tmp_qual_provider->tmp_qual_cnt].appt_type_cd = se.appt_type_cd
   ENDIF
  FOOT REPORT
   IF (mod(tmp_qual_provider->tmp_qual_cnt,10) != 0)
    stat = alterlist(tmp_qual_provider->tmp_qual,tmp_qual_provider->tmp_qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(tmp_qual_provider)
 DECLARE sch_event_idx = i4 WITH protect, noconstant(0)
 DECLARE sch_event_id_idx = i4 WITH protect, noconstant(0)
 SELECT DISTINCT INTO "nl:"
  a.person_id, a.sch_event_id, a.role_meaning,
  a.beg_dt_tm, a.appt_location_cd
  FROM sch_appt a,
   person_alias pa,
   person p
  PLAN (a
   WHERE expand(sch_event_idx,1,tmp_qual_provider->tmp_qual_cnt,a.sch_event_id,tmp_qual_provider->
    tmp_qual[sch_event_idx].sch_event_id)
    AND a.role_meaning="PATIENT"
    AND a.state_meaning IN ("SCHEDULED", "CONFIRMED"))
   JOIN (pa
   WHERE pa.person_id=a.person_id
    AND pa.person_alias_type_cd=t_messaging_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=pa.person_id)
  ORDER BY a.sch_event_id
  HEAD REPORT
   t_record->person_qual_cnt = 0
  HEAD a.sch_event_id
   t_record->person_qual_cnt += 1
   IF (mod(t_record->person_qual_cnt,1000)=1)
    stat = alterlist(t_record->person_qual,(t_record->person_qual_cnt+ 999))
   ENDIF
   t_record->person_qual[t_record->person_qual_cnt].person_id = a.person_id, t_record->person_qual[
   t_record->person_qual_cnt].name = concat(trim(p.name_first)," ",trim(p.name_last)), t_record->
   person_qual[t_record->person_qual_cnt].alias = pa.alias,
   t_record->person_qual[t_record->person_qual_cnt].sch_event_id = a.sch_event_id, t_record->
   person_qual[t_record->person_qual_cnt].beg_dt_tm = a.beg_dt_tm, t_record->person_qual[t_record->
   person_qual_cnt].appt_location_cd = a.appt_location_cd,
   sch_event_id_idx = locateval(locate_idx,1,tmp_qual_provider->tmp_qual_cnt,a.sch_event_id,
    tmp_qual_provider->tmp_qual[locate_idx].sch_event_id), t_record->person_qual[t_record->
   person_qual_cnt].appt_type_cd = tmp_qual_provider->tmp_qual[sch_event_id_idx].appt_type_cd
  FOOT REPORT
   IF (mod(t_record->person_qual_cnt,1000) != 0)
    stat = alterlist(t_record->person_qual,t_record->person_qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF ((t_record->person_qual_cnt < 1))
  CALL addlogmessage("No persons qualified.")
  GO TO exit_script
 ENDIF
 DECLARE existing_clip = vc WITH protect
 DECLARE clip_exists = i2 WITH protect, noconstant(0)
 DECLARE replace_all_occurances = i2 WITH protect, constant(0)
 DECLARE t_template = vgc WITH protect
 FOR (ix = 1 TO t_record->person_qual_cnt)
   IF (size(t_healtheintent_url,1) > 1)
    CALL populatemodernhealthelifeactivationlink(t_record->person_qual[ix].person_id,t_record->
     person_qual[ix].sch_event_id,t_record->person_qual[ix].appt_location_cd,t_record->person_qual[ix
     ].appt_type_cd,t_record->person_qual[ix].beg_dt_tm)
   ELSEIF (size(t_url,1) > 1)
    CALL populateactivationlink(t_record->person_qual[ix].person_id,t_record->person_qual[ix].
     sch_event_id,t_record->person_qual[ix].appt_location_cd,t_record->person_qual[ix].appt_type_cd)
   ENDIF
 ENDFOR
 IF (t_log_ind=1)
  CALL echorecord(t_record)
 ENDIF
 SET happ = s_uar_crmbeginapp(967100,0)
 SET htask = s_uar_crmbegintask(happ,967100,0)
 SET hstep = s_uar_crmbeginreq(htask,0,967503,0)
 SET hrequest = s_uar_crmgetrequest(hstep,0)
 SET t_template = t_text
 FOR (ix = 1 TO t_record->person_qual_cnt)
   SET clip_exists = 0
   SELECT INTO "nl:"
    FROM ext_data_info edi,
     dms_media_xref dmx,
     sch_appt sa
    PLAN (sa
     WHERE (sa.sch_event_id=t_record->person_qual[ix].sch_event_id)
      AND sa.active_ind=1)
     JOIN (dmx
     WHERE dmx.parent_entity_id=sa.sch_event_id
      AND dmx.parent_entity_name="SCH_EVENT")
     JOIN (edi
     WHERE (edi.person_id=t_record->person_qual[ix].person_id)
      AND edi.source_reference_id=dmx.dms_media_identifier_id
      AND edi.source_reference_name="DMS_MEDIA_IDENTIFIER")
    HEAD REPORT
     clip_exists = 1
    WITH nocounter
   ;end select
   IF (clip_exists=0
    AND (t_record->person_qual[ix].clip_activation_stat=1))
    SET t_template = t_text
    SET t_date = concat(trim(format(t_record->person_qual[ix].beg_dt_tm,cclfmt->weekdayname),3),", ",
     trim(format(t_record->person_qual[ix].beg_dt_tm,cclfmt->longdate),3))
    SET t_template = replace(t_template,"{\*\clipboard apptdatetime}",t_date,0)
    SET t_template = replace(t_template,"{\*\clipboard url}",t_record->person_qual[ix].
     clip_activation_url,replace_all_occurances)
    SET htask = uar_srvadditem(hrequest,"message_list")
    SET stat = uar_srvsetdouble(htask,"person_id",t_record->person_qual[ix].person_id)
    SET stat = uar_srvsetstring(htask,"task_type_meaning","PHONE MSG")
    SET stat = uar_srvsetstring(htask,"task_activity_meaning","COMP PERS")
    SET stat = uar_srvsetstring(htask,"msg_subject",nullterm(t_subject))
    SET stat = uar_srvsetasis(htask,"msg_text",t_template,size(t_template,1))
    SET stat = uar_srvsetdouble(htask,"msg_sender_prsnl_id",t_from)
    SET hprsnl = uar_srvadditem(htask,"assign_person_list")
    SET stat = uar_srvsetdouble(hprsnl,"assign_person_id",t_record->person_qual[ix].person_id)
    IF (t_log_ind=1)
     CALL s_uar_echo_object(hrequest)
    ENDIF
    SET stat = s_uar_crmperform(hstep,1)
    IF (stat != 0)
     SET errormsg = build("Call to messaging service 967503 returned error: ",stat)
     SET table_name = errormsg
     SET failed = uar_error
     CALL addlogmessage(errormsg)
     GO TO exit_script
    ENDIF
    CALL uar_srvremoveitem(htask,nullterm("assign_person_list"),0)
    CALL uar_srvremoveitem(hrequest,nullterm("message_list"),0)
   ENDIF
 ENDFOR
 CALL s_uar_crmendreq(hstep)
#exit_script
 CALL addlogmessage(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),
    script_begin_dt_tm,5)))
 DECLARE log_file = vc WITH private, constant(build("cer_log:clip_ops_iqh_reminder",format(
    cnvtdatetime(curdate,curtime),"YYYYMMDDhhmmss;;d"),".dat"))
 IF (hstep > 0)
  CALL s_uar_crmendreq(hstep)
 ENDIF
 CALL s_uar_crmendtask(htask)
 CALL s_uar_crmendapp(happ)
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = false
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF version_insert_error:
     CALL s_add_subeventstatus("VERSION_INSERT","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF version_delete_error:
     CALL s_add_subeventstatus("VERSION_DELETE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCL_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
 IF (t_log_ind=1)
  CALL echorecord(rlog)
 ENDIF
 CALL echoxml(reply,log_file,1)
 CALL echoxml(rlog,log_file,1)
END GO
