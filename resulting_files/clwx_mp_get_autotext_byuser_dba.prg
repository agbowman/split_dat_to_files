CREATE PROGRAM clwx_mp_get_autotext_byuser:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "User ID:" = 0.0
  WITH outdev, uid
 FREE RECORD record_data
 RECORD record_data(
   1 prsnl_id = f8
   1 json_size = vc
   1 phrase_cnt = i4
   1 phrases[*]
     2 note_phrase_id = f8
     2 abbreviation = vc
     2 description = vc
     2 sort_dt_tm = dq8
     2 updt_dt_tm = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF ((validate(dq_parser_rec->buffer_count,- (99))=- (99)))
  CALL echo("*****inside pm_dynamic_query include file *****")
  FREE RECORD dq_parser_rec
  RECORD dq_parser_rec(
    1 buffer_count = i2
    1 plan_count = i2
    1 set_count = i2
    1 table_count = i2
    1 with_count = i2
    1 buffer[*]
      2 line = vc
  )
  SET dq_parser_rec->buffer_count = 0
  SET dq_parser_rec->plan_count = 0
  SET dq_parser_rec->set_count = 0
  SET dq_parser_rec->table_count = 0
  SET dq_parser_rec->with_count = 0
  DECLARE dq_add_detail(dqad_dummy) = null
  DECLARE dq_add_footer(dqaf_target) = null
  DECLARE dq_add_header(dqah_target) = null
  DECLARE dq_add_line(dqal_line) = null
  DECLARE dq_get_line(dqgl_idx) = vc
  DECLARE dq_upt_line(dqul_idx,dqul_line) = null
  DECLARE dq_add_planjoin(dqap_range) = null
  DECLARE dq_add_set(dqas_to,dqas_from) = null
  DECLARE dq_add_table(dqat_table_name,dqat_table_alias) = null
  DECLARE dq_add_with(dqaw_control_option) = null
  DECLARE dq_begin_insert(dqbi_dummy) = null
  DECLARE dq_begin_select(dqbs_distinct_ind,dqbs_output_device) = null
  DECLARE dq_begin_update(dqbu_dummy) = null
  DECLARE dq_echo_query(dqeq_level) = null
  DECLARE dq_end_query(dqes_dummy) = null
  DECLARE dq_execute(dqe_reset) = null
  DECLARE dq_reset_query(dqrb_dummy) = null
  SUBROUTINE dq_add_detail(dqad_dummy)
    CALL dq_add_line("detail")
  END ;Subroutine
  SUBROUTINE dq_add_footer(dqaf_target)
    IF (size(trim(dqaf_target),1) > 0)
     CALL dq_add_line(concat("foot ",dqaf_target))
    ELSE
     CALL dq_add_line("foot report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_header(dqah_target)
    IF (size(trim(dqah_target),1) > 0)
     CALL dq_add_line(concat("head ",dqah_target))
    ELSE
     CALL dq_add_line("head report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_line(dqal_line)
    SET dq_parser_rec->buffer_count = (dq_parser_rec->buffer_count+ 1)
    IF (mod(dq_parser_rec->buffer_count,10)=1)
     SET stat = alterlist(dq_parser_rec->buffer,(dq_parser_rec->buffer_count+ 9))
    ENDIF
    SET dq_parser_rec->buffer[dq_parser_rec->buffer_count].line = trim(dqal_line,3)
  END ;Subroutine
  SUBROUTINE dq_get_line(dqgl_idx)
    IF (dqgl_idx > 0
     AND dqgl_idx <= size(dq_parser_rec->buffer,5))
     RETURN(dq_parser_rec->buffer[dqgl_idx].line)
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_upt_line(dqul_idx,dqul_line)
    IF (dqul_idx > 0
     AND dqul_idx <= size(dq_parser_rec->buffer,5))
     SET dq_parser_rec->buffer[dqul_idx].line = dqul_line
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_planjoin(dqap_range)
    DECLARE dqap_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->plan_count > 0))
     SET dqap_str = "join"
    ELSE
     SET dqap_str = "plan"
    ENDIF
    IF (size(trim(dqap_range),1) > 0)
     CALL dq_add_line(concat(dqap_str," ",dqap_range," where"))
     SET dq_parser_rec->plan_count = (dq_parser_rec->plan_count+ 1)
    ELSE
     CALL dq_add_line("where ")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_set(dqas_to,dqas_from)
   IF ((dq_parser_rec->set_count > 0))
    CALL dq_add_line(concat(",",dqas_to," = ",dqas_from))
   ELSE
    CALL dq_add_line(concat("set ",dqas_to," = ",dqas_from))
   ENDIF
   SET dq_parser_rec->set_count = (dq_parser_rec->set_count+ 1)
  END ;Subroutine
  SUBROUTINE dq_add_table(dqat_table_name,dqat_table_alias)
    DECLARE dqat_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->table_count > 0))
     SET dqat_str = concat(" , ",dqat_table_name)
    ELSE
     SET dqat_str = concat(" from ",dqat_table_name)
    ENDIF
    IF (size(trim(dqat_table_alias),1) > 0)
     SET dqat_str = concat(dqat_str," ",dqat_table_alias)
    ENDIF
    SET dq_parser_rec->table_count = (dq_parser_rec->table_count+ 1)
    CALL dq_add_line(dqat_str)
  END ;Subroutine
  SUBROUTINE dq_add_with(dqaw_control_option)
   IF ((dq_parser_rec->with_count > 0))
    CALL dq_add_line(concat(",",dqaw_control_option))
   ELSE
    CALL dq_add_line(concat("with ",dqaw_control_option))
   ENDIF
   SET dq_parser_rec->with_count = (dq_parser_rec->with_count+ 1)
  END ;Subroutine
  SUBROUTINE dq_begin_insert(dqbi_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("insert")
  END ;Subroutine
  SUBROUTINE dq_begin_select(dqbs_distinct_ind,dqbs_output_device)
    DECLARE dqbs_str = vc WITH noconstant(" ")
    CALL dq_reset_query(1)
    IF (dqbs_distinct_ind=0)
     SET dqbs_str = "select"
    ELSE
     SET dqbs_str = "select distinct"
    ENDIF
    IF (size(trim(dqbs_output_device),1) > 0)
     SET dqbs_str = concat(dqbs_str," into ",dqbs_output_device)
    ENDIF
    CALL dq_add_line(dqbs_str)
  END ;Subroutine
  SUBROUTINE dq_begin_update(dqbu_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("update")
  END ;Subroutine
  SUBROUTINE dq_echo_query(dqeq_level)
    DECLARE dqeq_i = i4 WITH private, noconstant(0)
    DECLARE dqeq_j = i4 WITH private, noconstant(0)
    IF (dqeq_level=1)
     CALL echo("-------------------------------------------------------------------")
     CALL echo("Parser Buffer Echo:")
     CALL echo("-------------------------------------------------------------------")
     FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
       CALL echo(dq_parser_rec->buffer[dqeq_i].line)
     ENDFOR
     CALL echo("-------------------------------------------------------------------")
    ELSEIF (dqeq_level=2)
     IF (validate(reply->debug[1].line,"-9") != "-9")
      SET dqeq_j = size(reply->debug,5)
      SET stat = alterlist(reply->debug,((dqeq_j+ size(dq_parser_rec->buffer,5))+ 4))
      SET reply->debug[(dqeq_j+ 1)].line =
      "-------------------------------------------------------------------"
      SET reply->debug[(dqeq_j+ 2)].line = "Parser Buffer Echo:"
      SET reply->debug[(dqeq_j+ 3)].line =
      "-------------------------------------------------------------------"
      FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
        SET reply->debug[((dqeq_j+ dqeq_i)+ 3)].line = dq_parser_rec->buffer[dqeq_i].line
      ENDFOR
      SET reply->debug[((dqeq_j+ dq_parser_rec->buffer_count)+ 4)].line =
      "-------------------------------------------------------------------"
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_end_query(dqes_dummy)
   CALL dq_add_line(" go")
   SET stat = alterlist(dq_parser_rec->buffer,dq_parser_rec->buffer_count)
  END ;Subroutine
  SUBROUTINE dq_execute(dqe_reset)
    DECLARE dqe_i = i4 WITH private, noconstant(0)
    FOR (dqe_i = 1 TO dq_parser_rec->buffer_count)
      CALL parser(dq_parser_rec->buffer[dqe_i].line,1)
    ENDFOR
    IF (dqe_reset=1)
     CALL dq_reset_query(1)
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_reset_query(dqrb_dummy)
    SET stat = alterlist(dq_parser_rec->buffer,0)
    SET dq_parser_rec->buffer_count = 0
    SET dq_parser_rec->plan_count = 0
    SET dq_parser_rec->set_count = 0
    SET dq_parser_rec->table_count = 0
    SET dq_parser_rec->with_count = 0
  END ;Subroutine
 ENDIF
 IF ((validate(pm_create_req_def,- (9))=- (9)))
  DECLARE pm_create_req_def = i2 WITH constant(0)
  DECLARE cr_hmsg = i4 WITH noconstant(0)
  DECLARE cr_hmsgtype = i4 WITH noconstant(0)
  DECLARE cr_hinst = i4 WITH noconstant(0)
  DECLARE cr_hitem = i4 WITH noconstant(0)
  DECLARE cr_llevel = i4 WITH noconstant(0)
  DECLARE cr_lcnt = i4 WITH noconstant(0)
  DECLARE cr_lcharlen = i4 WITH noconstant(0)
  DECLARE cr_siterator = i4 WITH noconstant(0)
  DECLARE cr_lfieldtype = i4 WITH noconstant(0)
  DECLARE cr_sfieldname = vc WITH noconstant(" ")
  DECLARE cr_blist = i2 WITH noconstant(false)
  DECLARE cr_bfound = i2 WITH noconstant(false)
  DECLARE cr_esrvstring = i4 WITH constant(1)
  DECLARE cr_esrvshort = i4 WITH constant(2)
  DECLARE cr_esrvlong = i4 WITH constant(3)
  DECLARE cr_esrvdouble = i4 WITH constant(6)
  DECLARE cr_esrvasis = i4 WITH constant(7)
  DECLARE cr_esrvlist = i4 WITH constant(8)
  DECLARE cr_esrvstruct = i4 WITH constant(9)
  DECLARE cr_esrvuchar = i4 WITH constant(10)
  DECLARE cr_esrvulong = i4 WITH constant(12)
  DECLARE cr_esrvdate = i4 WITH constant(13)
  DECLARE cr_createrequest(mode=i2,req_id=i4,req_name=vc) = i2
  DECLARE cr_popstack(dummyvar=i2) = null
  DECLARE cr_pushstack(hval=i4,sval=i4) = null
  FREE RECORD cr_stack
  RECORD cr_stack(
    1 list[10]
      2 hinst = i4
      2 siterator = i4
  )
  SUBROUTINE cr_createrequest(mode,req_id,req_name)
    SET cr_llevel = 1
    CALL dq_reset_query(null)
    CALL dq_add_line(concat("free record ",req_name," go"))
    CALL dq_add_line(concat("record ",req_name))
    CALL dq_add_line("(")
    SET cr_hmsg = uar_srvselectmessage(req_id)
    IF (cr_hmsg != 0)
     IF (mode=0)
      SET cr_hinst = uar_srvcreaterequest(cr_hmsg)
     ELSE
      SET cr_hinst = uar_srvcreatereply(cr_hmsg)
     ENDIF
    ELSE
     SET reply->status_data.operationname = "INVALID_hMsg"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
     RETURN(false)
    ENDIF
    IF (cr_hinst > 0)
     SET cr_sfieldname = uar_srvfirstfield(cr_hinst,cr_siterator)
     SET cr_sfieldname = trim(cr_sfieldname,3)
     CALL cr_pushstack(cr_hinst,cr_siterator)
    ELSE
     SET reply->status_data.operationname = "INVALID_hInst"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
     IF (cr_hinst)
      CALL uar_srvdestroyinstance(cr_hinst)
      SET cr_hinst = 0
     ENDIF
     RETURN(false)
    ENDIF
    WHILE (textlen(cr_sfieldname) > 0)
      SET cr_lfieldtype = uar_srvgettype(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
      CASE (cr_lfieldtype)
       OF cr_esrvstruct:
        SET cr_hitem = 0
        SET cr_hitem = uar_srvgetstruct(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_hitem > 0)
         SET cr_siterator = 0
         CALL cr_pushstack(cr_hitem,cr_siterator)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname))
         SET cr_llevel = (cr_llevel+ 1)
         SET cr_blist = true
        ELSE
         SET reply->status_data.operationname = "INVALID_hItem"
         SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
         IF (cr_hinst)
          CALL uar_srvdestroyinstance(cr_hinst)
          SET cr_hinst = 0
         ENDIF
         RETURN(false)
        ENDIF
       OF cr_esrvlist:
        SET cr_hitem = 0
        SET cr_hitem = uar_srvadditem(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_hitem > 0)
         SET cr_siterator = 0
         CALL cr_pushstack(cr_hitem,cr_siterator)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname,"[*]"))
         SET cr_llevel = (cr_llevel+ 1)
         SET cr_blist = true
        ELSE
         SET reply->status_data.operationname = "INVALID_hInst"
         SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
         IF (cr_hinst)
          CALL uar_srvdestroyinstance(cr_hinst)
          SET cr_hinst = 0
         ENDIF
         RETURN(false)
        ENDIF
       OF cr_esrvstring:
        SET cr_lcharlen = uar_srvgetstringmax(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_lcharlen > 0)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c",cnvtstring(
            cr_lcharlen)))
        ELSE
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = vc"))
        ENDIF
       OF cr_esrvuchar:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c1"))
       OF cr_esrvshort:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i2"))
       OF cr_esrvlong:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i4"))
       OF cr_esrvulong:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = ui4"))
       OF cr_esrvdouble:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = f8"))
       OF cr_esrvdate:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = dq8"))
       OF cr_esrvasis:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = gvc"))
       ELSE
        SET reply->status_data.operationname = "INVALID_SrvType"
        SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
        IF (cr_hinst)
         CALL uar_srvdestroyinstance(cr_hinst)
         SET cr_hinst = 0
        ENDIF
        RETURN(false)
      ENDCASE
      SET cr_sfieldname = ""
      IF (cr_blist)
       SET cr_sfieldname = uar_srvfirstfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
        siterator)
       SET cr_sfieldname = trim(cr_sfieldname,3)
       SET cr_blist = false
      ELSE
       SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
        siterator)
       SET cr_sfieldname = trim(cr_sfieldname,3)
       IF (textlen(cr_sfieldname) <= 0)
        SET cr_bfound = false
        WHILE (cr_bfound != true)
          CALL cr_popstack(null)
          IF ((cr_stack->list[cr_lcnt].hinst > 0)
           AND cr_lcnt > 0)
           SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt]
            .siterator)
           SET cr_sfieldname = trim(cr_sfieldname,3)
          ELSE
           SET cr_bfound = true
          ENDIF
          IF (textlen(cr_sfieldname) > 0)
           SET cr_bfound = true
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
    ENDWHILE
    CALL dq_add_line(")  with persistscript")
    CALL dq_end_query(null)
    CALL dq_execute(null)
    IF (cr_hinst)
     CALL uar_srvdestroyinstance(cr_hinst)
     SET cr_hinst = 0
    ENDIF
    RETURN(true)
  END ;Subroutine
  SUBROUTINE cr_popstack(dummyvar)
   SET cr_lcnt = (cr_lcnt - 1)
   SET cr_llevel = (cr_llevel - 1)
  END ;Subroutine
  SUBROUTINE cr_pushstack(hval,lval)
    SET cr_lcnt = (cr_lcnt+ 1)
    IF (mod(cr_lcnt,10)=1
     AND cr_lcnt != 1)
     SET stat = alterlist(cr_stack->list,(cr_lcnt+ 9))
    ENDIF
    SET cr_stack->list[cr_lcnt].hinst = hval
    SET cr_stack->list[cr_lcnt].siterator = lval
  END ;Subroutine
 ENDIF
 SET log_program_name = "CLWX_MP_GET_AUTOTEXT_BYUSER"
 IF ((validate(debug_ind,- (99))=- (99)))
  DECLARE debug_ind = i2 WITH protect, noconstant(false)
 ENDIF
 DECLARE current_date_time_autouser = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE autotextget_reqid = i4 WITH public, constant(969551)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->prsnl_id =  $UID
 CALL getuserautotextusingservice(null)
 SET modify maxvarlen 30000000
 SET record_data->json_size = cnvtstring(size(cnvtrectojson(record_data)))
 SET _memory_reply_string = cnvtrectojson(record_data)
 IF (debug_ind=true)
  CALL echorecord(record_data)
  CALL echo(_memory_reply_string)
 ENDIF
 SUBROUTINE getuserautotextusingservice(dummy)
   CALL log_message("In GetUserAutoTextUsingService",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   CALL cr_createrequest(0,autotextget_reqid,"autotext_request")
   RECORD autotext_reply(
     1 phrases[*]
       2 note_phrase_id = f8
       2 prsnl_id = f8
       2 abbreviation = vc
       2 description = vc
       2 updt_dt_tm = dq8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF (validate(autotext_request->user_id))
    SET autotext_request->retrieve_system_phrases_ind = 0
    SET autotext_request->retrieve_user_phrases_ind = 1
    SET autotext_request->user_id =  $UID
    IF (debug_ind=true)
     CALL echorecord(autotext_request)
    ENDIF
    SET stat = tdbexecute(3202004,3202004,autotextget_reqid,"REC",autotext_request,
     "REC",autotext_reply)
    IF ((autotext_reply->status_data.status="F"))
     SET record_data->status_data.status = "F"
    ELSE
     SET record_data->status_data.status = "S"
     IF (debug_ind=true)
      CALL echorecord(autotext_reply)
     ENDIF
     SET autotext_cnt = size(autotext_reply->phrases,5)
     SET record_data->phrase_cnt = autotext_cnt
     SELECT INTO "nl:"
      abbreviation = autotext_reply->phrases[d.seq].abbreviation
      FROM (dummyt d  WITH seq = record_data->phrase_cnt)
      PLAN (d
       WHERE (record_data->phrase_cnt > 0))
      ORDER BY abbreviation
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt = (cnt+ 1)
       IF (mod(cnt,100)=1)
        stat = alterlist(record_data->phrases,(cnt+ 99))
       ENDIF
       record_data->phrases[cnt].note_phrase_id = autotext_reply->phrases[d.seq].note_phrase_id,
       record_data->phrases[cnt].abbreviation = autotext_reply->phrases[d.seq].abbreviation,
       record_data->phrases[cnt].description = autotext_reply->phrases[d.seq].description,
       record_data->phrases[cnt].sort_dt_tm = autotext_reply->phrases[d.seq].updt_dt_tm, record_data
       ->phrases[cnt].updt_dt_tm = build(replace(datetimezoneformat(cnvtdatetime(autotext_reply->
           phrases[d.seq].updt_dt_tm),datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef),
         " ","T",1),"Z")
      FOOT REPORT
       stat = alterlist(record_data->phrases,cnt)
      WITH nocounter
     ;end select
    ENDIF
   ELSE
    SET record_data->status_data.status = "S"
    CALL getuserautotextusingccl(null)
   ENDIF
   CALL log_message(build("Exit GetUserAutoTextUsingService, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getuserautotextusingccl(dummy)
   CALL log_message("In GetUserAutoTextUsingCCL",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SELECT INTO "nl;"
    FROM note_phrase np
    PLAN (np
     WHERE (np.prsnl_id= $UID))
    ORDER BY np.abbreviation
    HEAD REPORT
     nt_phrase_cnt = 0
    DETAIL
     nt_phrase_cnt = (nt_phrase_cnt+ 1)
     IF (mod(nt_phrase_cnt,100)=1)
      stat = alterlist(record_data->phrases,(nt_phrase_cnt+ 99))
     ENDIF
     record_data->phrases[nt_phrase_cnt].note_phrase_id = np.note_phrase_id, record_data->phrases[
     nt_phrase_cnt].abbreviation = trim(replace(np.abbreviation,concat(char(13),char(10)),"; ",0)),
     record_data->phrases[nt_phrase_cnt].description = trim(replace(np.abb_description,concat(char(13
         ),char(10)),"; ",0)),
     record_data->phrases[nt_phrase_cnt].sort_dt_tm = np.updt_dt_tm, record_data->phrases[
     nt_phrase_cnt].updt_dt_tm = build(replace(datetimezoneformat(cnvtdatetime(np.updt_dt_tm),
        datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
    FOOT REPORT
     stat = alterlist(record_data->phrases,nt_phrase_cnt), record_data->phrase_cnt = nt_phrase_cnt
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetUserAutoTextUsingCCL, Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
    current_date_time_autouser,5)),log_level_debug)
 FREE RECORD record_data
END GO
