CREATE PROGRAM aps_recover_single_order:dba
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 order_id = f8
   1 ord_srv_error_msg = vc
   1 ord_srv_spec_error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c255 WITH protect, noconstant("")
 DECLARE nbegannewappind = i2 WITH protect, noconstant(0)
 DECLARE nbadordercnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE horder = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE lretrythreshold = i4 WITH protect, noconstant(10)
 DECLARE nretrythresholdmet = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM report_task rt
  PLAN (rt
   WHERE (rt.report_id=request->parent_id)
    AND rt.order_id > 0)
  DETAIL
   reply->order_id = rt.order_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  CALL populate_subeventstatus_msg("SELECT","S","REPORT_TASK","Order ID found on Report Task",
   log_level_debug)
  GO TO exit_script_2
 ENDIF
 IF ((request->synch_after_partial=1))
  CALL populate_subeventstatus_msg("SELECT","F","REPORT_TASK","No order id after partial success",
   log_level_info)
  GO TO exit_script_2
 ENDIF
 RECORD requestin(
   1 request
     2 dummy = i4
   1 reply
     2 qual[*]
       3 exception_type = i2
       3 parent_id = f8
       3 active_ind = i2
     2 status_data
       3 status = c1
       3 subeventstatus[1]
         4 operationname = c25
         4 operationstatus = c1
         4 targetobjectname = c25
         4 targetobjectvalue = vc
 )
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
    SET dq_parser_rec->buffer_count += 1
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
     SET dq_parser_rec->plan_count += 1
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
   SET dq_parser_rec->set_count += 1
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
    SET dq_parser_rec->table_count += 1
    CALL dq_add_line(dqat_str)
  END ;Subroutine
  SUBROUTINE dq_add_with(dqaw_control_option)
   IF ((dq_parser_rec->with_count > 0))
    CALL dq_add_line(concat(",",dqaw_control_option))
   ELSE
    CALL dq_add_line(concat("with ",dqaw_control_option))
   ENDIF
   SET dq_parser_rec->with_count += 1
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
    IF (checkprg("PM_DQ_EXECUTE_PARSER") > 0)
     EXECUTE pm_dq_execute_parser  WITH replace("TEMP_DQ_PARSER_REC","DQ_PARSER_REC")
     IF (dqe_reset=1)
      SET stat = initrec(dq_parser_rec)
     ENDIF
    ELSE
     DECLARE dqe_i = i4 WITH private, noconstant(0)
     FOR (dqe_i = 1 TO dq_parser_rec->buffer_count)
       CALL parser(dq_parser_rec->buffer[dqe_i].line,1)
     ENDFOR
     IF (dqe_reset=1)
      CALL dq_reset_query(1)
     ENDIF
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
  FREE RECORD cr_stack
  RECORD cr_stack(
    1 list[10]
      2 hinst = i4
      2 siterator = i4
  )
  SUBROUTINE (cr_createrequest(mode=i2,req_id=i4,req_name=vc) =i2)
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
         SET cr_llevel += 1
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
         SET cr_llevel += 1
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
    IF (mode=1)
     CALL dq_add_line("1  status_data")
     CALL dq_add_line("2  status  = c1")
     CALL dq_add_line("2  subeventstatus[1]")
     CALL dq_add_line("3  operationname = c15")
     CALL dq_add_line("3  operationstatus = c1")
     CALL dq_add_line("3  targetobjectname = c15")
     CALL dq_add_line("3  targetobjectvalue = vc")
    ENDIF
    CALL dq_add_line(")  with persistscript")
    CALL dq_end_query(null)
    CALL dq_execute(null)
    IF (cr_hinst)
     CALL uar_srvdestroyinstance(cr_hinst)
     SET cr_hinst = 0
    ENDIF
    RETURN(true)
  END ;Subroutine
  SUBROUTINE (cr_popstack(dummyvar=i2) =null)
   SET cr_lcnt -= 1
   SET cr_llevel -= 1
  END ;Subroutine
  SUBROUTINE (cr_pushstack(hval=i4,lval=i4) =null)
    SET cr_lcnt += 1
    IF (mod(cr_lcnt,10)=1
     AND cr_lcnt != 1)
     SET stat = alterlist(cr_stack->list,(cr_lcnt+ 9))
    ENDIF
    SET cr_stack->list[cr_lcnt].hinst = hval
    SET cr_stack->list[cr_lcnt].siterator = lval
  END ;Subroutine
 ENDIF
 CALL cr_createrequest(0,560201,"replyout")
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="ANATOMIC PATHOLOGY"
    AND di.info_name="ORDER RETRY THRESHOLD")
  DETAIL
   lretrythreshold = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ap_ops_exception aoe
  PLAN (aoe
   WHERE (aoe.parent_id=request->parent_id)
    AND aoe.action_flag=3)
  DETAIL
   IF (((aoe.active_ind=1) OR (datetimediff(cnvtdatetime(sysdate),aoe.updt_dt_tm,3) > 1.0))
    AND aoe.updt_cnt < lretrythreshold)
    cnt += 1, stat = alterlist(requestin->reply.qual,cnt), requestin->reply.qual[cnt].parent_id = aoe
    .parent_id,
    requestin->reply.qual[cnt].exception_type = aoe.action_flag, requestin->reply.qual[cnt].
    active_ind = aoe.active_ind
   ELSEIF (aoe.updt_cnt >= lretrythreshold)
    nretrythresholdmet = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (nretrythresholdmet=1)
  SET reply->ord_srv_error_msg = "The requested order has hit the order retry threshold."
  SET reply->ord_srv_spec_error_msg = concat("The order has already been retried at least ",trim(
    cnvtstring(lretrythreshold))," ;times. ","It was not reattempted.")
  CALL populate_subeventstatus_msg("SELECT","F","AP_OPS_EXCEPTION",
   "Retry threshold met for requested order",log_level_audit)
  GO TO exit_script_2
 ENDIF
 IF (curqual=0)
  INSERT  FROM ap_ops_exception aoe
   SET aoe.parent_id = request->parent_id, aoe.action_flag = 3, aoe.active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET stat = alterlist(requestin->reply.qual,1)
  SET cnt = 1
  SET requestin->reply.qual[cnt].parent_id = request->parent_id
  SET requestin->reply.qual[cnt].exception_type = 3
  SET requestin->reply.qual[cnt].active_ind = 1
  SET nerrcode = error(serrmsg,0)
  IF (nerrcode != 0)
   CALL populate_subeventstatus_msg("INSERT","F","AP_OPS_EXCEPTION",
    "Could not insert ops exception row",log_level_audit)
   GO TO exit_script_2
  ENDIF
  CALL populate_subeventstatus_msg("INSERT","S","AP_OPS_EXCEPTION","Ops exception row inserted",
   log_level_debug)
 ELSE
  IF (size(requestin->reply.qual,5)=0)
   SET reply->status_data.status = "P"
   GO TO exit_script_2
  ENDIF
  IF ((requestin->reply.qual[1].active_ind=0))
   SET nerrcode = error(serrmsg,0)
   IF (nerrcode != 0)
    GO TO exit_script_2
   ENDIF
   SELECT INTO "nl:"
    FROM ap_ops_exception aoe
    PLAN (aoe
     WHERE (aoe.parent_id=request->parent_id)
      AND aoe.action_flag=3)
    WITH forupdate(aoe), nocounter
   ;end select
   SET nerrcode = error(serrmsg,1)
   IF (nerrcode != 0)
    CALL populate_subeventstatus_msg("LOCK","F","AP_OPS_EXCEPTION",
     "Could not lock ops exception row.",log_level_audit)
    SET reply->status_data.status = "P"
    GO TO exit_script_2
   ENDIF
   UPDATE  FROM ap_ops_exception aoe
    SET aoe.active_ind = 1
    PLAN (aoe
     WHERE (aoe.parent_id=request->parent_id)
      AND aoe.action_flag=3)
    WITH nocounter
   ;end update
   SET nerrcode = error(serrmsg,0)
   IF (nerrcode != 0)
    CALL populate_subeventstatus_msg("UPDATE","F","AP_OPS_EXCEPTION",
     "Could not update ops exception row.",log_level_audit)
    GO TO exit_script_2
   ENDIF
   CALL populate_subeventstatus_msg("UPDATE","S","AP_OPS_EXCEPTION","Ops exception row updated",
    log_level_debug)
  ENDIF
 ENDIF
 SET requestin->reply.status_data.status = "S"
 EXECUTE pfmt_p200386
 EXECUTE pfmt_aps_ops_exception
 IF ((reqinfo->commit_ind=1))
  CALL populate_subeventstatus_msg("EXECUTE","S","PFMT_APS_OPS_EXCEPTION",
   "Order server request data retrieved",log_level_debug)
  SET happ = uar_crmgetapphandle()
  IF (happ=0)
   CALL populate_subeventstatus_msg("UAR","P","CrmGetAppHandle","Could not get app handle",
    log_level_info)
   SET stat = uar_crmbeginapp(reqinfo->updt_app,happ)
   IF (stat > 0)
    CALL populate_subeventstatus_msg("UAR","F","CrmBeginApp",build("Begin App(",reqinfo->updt_app,
      ")  failed:",stat),log_level_audit)
    GO TO exit_script
   ELSE
    SET nbegannewappind = 1
   ENDIF
  ENDIF
  SET stat = uar_crmbegintask(happ,200013,htask)
  IF (stat > 0)
   CALL populate_subeventstatus_msg("UAR","F","CrmBeginTask",build("Begin Task 200013 failed:",stat),
    log_level_audit)
   GO TO exit_script
  ENDIF
  SET stat = uar_crmbeginreq(htask,"",560201,hstep)
  IF (stat > 0)
   CALL populate_subeventstatus_msg("UAR","F","CrmBeginReq",build("Begin Request 560201 failed:",stat
     ),log_level_audit)
   GO TO exit_script
  ENDIF
  SET hrequest = uar_crmgetrequest(hstep)
  SET stat = uar_srvsetshort(hrequest,"passingEncntrInfoInd",replyout->passingencntrinfoind)
  SET stat = uar_srvsetdouble(hrequest,"encntrFinancialId",replyout->encntrfinancialid)
  SET stat = uar_srvsetdouble(hrequest,"locationCd",replyout->locationcd)
  SET stat = uar_srvsetdouble(hrequest,"locFacilityCd",replyout->locfacilitycd)
  SET stat = uar_srvsetdouble(hrequest,"locNurseUnitCd",replyout->locnurseunitcd)
  SET stat = uar_srvsetdouble(hrequest,"locRoomCd",replyout->locroomcd)
  SET stat = uar_srvsetdouble(hrequest,"locBedCd",replyout->locbedcd)
  SET stat = uar_srvsetdouble(hrequest,"personId",replyout->personid)
  SET stat = uar_srvsetdouble(hrequest,"encntrId",replyout->encntrid)
  SET stat = uar_srvsetshort(hrequest,"commitGroupInd",replyout->commitgroupind)
  FOR (cnt = 1 TO size(replyout->orderlist,5))
    SET horder = uar_srvadditem(hrequest,"orderList")
    SET stat = uar_srvsetdouble(horder,"actionTypeCd",replyout->orderlist[cnt].actiontypecd)
    SET stat = uar_srvsetdouble(horder,"communicationTypeCd",replyout->orderlist[cnt].
     communicationtypecd)
    SET stat = uar_srvsetdouble(horder,"orderId",replyout->orderlist[cnt].orderid)
    SET stat = uar_srvsetlong(horder,"lastUpdtCnt",replyout->orderlist[cnt].lastupdtcnt)
    SET stat = uar_srvsetdouble(horder,"deptStatusCd",replyout->orderlist[cnt].deptstatuscd)
    SET stat = uar_srvsetdouble(horder,"orderProviderId",replyout->orderlist[cnt].orderproviderid)
    SET stat = uar_srvsetdate(horder,"orderDtTm",cnvtdatetime(replyout->orderlist[cnt].orderdttm))
    SET stat = uar_srvsetdouble(horder,"oeFormatId",replyout->orderlist[cnt].oeformatid)
    SET stat = uar_srvsetdouble(horder,"catalogTypeCd",replyout->orderlist[cnt].catalogtypecd)
    SET stat = uar_srvsetstring(horder,"accessionNbr",nullterm(trim(replyout->orderlist[cnt].
       accessionnbr)))
    SET stat = uar_srvsetdouble(horder,"accessionId",replyout->orderlist[cnt].accessionid)
    SET stat = uar_srvsetdouble(horder,"catalogCd",replyout->orderlist[cnt].catalogcd)
    SET stat = uar_srvsetdouble(horder,"synonymId",replyout->orderlist[cnt].synonymid)
    SET stat = uar_srvsetstring(horder,"orderMnemonic",nullterm(trim(replyout->orderlist[cnt].
       ordermnemonic)))
    SET stat = uar_srvsetshort(horder,"noChargeInd",replyout->orderlist[cnt].nochargeind)
    SET stat = uar_srvsetshort(horder,"passingOrcInfoInd",replyout->orderlist[cnt].passingorcinfoind)
    SET stat = uar_srvsetstring(horder,"primaryMnemonic",nullterm(trim(replyout->orderlist[cnt].
       primarymnemonic)))
    SET stat = uar_srvsetstring(horder,"deptDisplayName",nullterm(trim(replyout->orderlist[cnt].
       deptdisplayname)))
    SET stat = uar_srvsetdouble(horder,"activityTypeCd",replyout->orderlist[cnt].activitytypecd)
    SET stat = uar_srvsetdouble(horder,"activitySubtypeCd",replyout->orderlist[cnt].activitysubtypecd
     )
    SET stat = uar_srvsetshort(horder,"contOrderMethodFlag",replyout->orderlist[cnt].
     contordermethodflag)
    SET stat = uar_srvsetshort(horder,"completeUponOrderInd",replyout->orderlist[cnt].
     completeuponorderind)
    SET stat = uar_srvsetshort(horder,"orderReviewInd",replyout->orderlist[cnt].orderreviewind)
    SET stat = uar_srvsetshort(horder,"printReqInd",replyout->orderlist[cnt].printreqind)
    SET stat = uar_srvsetdouble(horder,"requisitionFormatCd",replyout->orderlist[cnt].
     requisitionformatcd)
    SET stat = uar_srvsetdouble(horder,"requisitionRoutingCd",replyout->orderlist[cnt].
     requisitionroutingcd)
    SET stat = uar_srvsetlong(horder,"resourceRouteLevel",replyout->orderlist[cnt].resourceroutelevel
     )
    SET stat = uar_srvsetshort(horder,"consentFormInd",replyout->orderlist[cnt].consentformind)
    SET stat = uar_srvsetdouble(horder,"consentFormFormatCd",replyout->orderlist[cnt].
     consentformformatcd)
    SET stat = uar_srvsetdouble(horder,"consentFormRoutingCd",replyout->orderlist[cnt].
     consentformroutingcd)
    SET stat = uar_srvsetshort(horder,"deptDupCheckInd",replyout->orderlist[cnt].deptdupcheckind)
    SET stat = uar_srvsetshort(horder,"abnReviewInd",replyout->orderlist[cnt].abnreviewind)
    SET stat = uar_srvsetdouble(horder,"reviewHierarchyId",replyout->orderlist[cnt].reviewhierarchyid
     )
    SET stat = uar_srvsetdouble(horder,"deptStatusCd",replyout->orderlist[cnt].deptstatuscd)
    SET stat = uar_srvsetlong(horder,"refTextMask",replyout->orderlist[cnt].reftextmask)
    SET stat = uar_srvsetshort(horder,"dupCheckingInd",replyout->orderlist[cnt].dupcheckingind)
    SET stat = uar_srvsetshort(horder,"orderableTypeFlag",replyout->orderlist[cnt].orderabletypeflag)
    FOR (i = 1 TO size(replyout->orderlist[cnt].detaillist,5))
      SET hitem = uar_srvadditem(horder,"detailList")
      SET stat = uar_srvsetdouble(hitem,"oeFieldId",replyout->orderlist[cnt].detaillist[i].oefieldid)
      SET stat = uar_srvsetdouble(hitem,"oeFieldValue",replyout->orderlist[cnt].detaillist[i].
       oefieldvalue)
      SET stat = uar_srvsetstring(hitem,"oeFieldDisplayValue",nullterm(trim(replyout->orderlist[cnt].
         detaillist[i].oefielddisplayvalue)))
      SET stat = uar_srvsetdate(hitem,"oeFieldDtTmValue",cnvtdatetime(replyout->orderlist[cnt].
        detaillist[i].oefielddttmvalue))
      SET stat = uar_srvsetstring(hitem,"oeFieldMeaning",nullterm(trim(replyout->orderlist[cnt].
         detaillist[i].oefieldmeaning)))
      SET stat = uar_srvsetdouble(hitem,"oeFieldMeaningId",replyout->orderlist[cnt].detaillist[i].
       oefieldmeaningid)
      SET stat = uar_srvsetshort(hitem,"valueRequiredInd",replyout->orderlist[cnt].detaillist[i].
       valuerequiredind)
      SET stat = uar_srvsetlong(hitem,"groupSeq",replyout->orderlist[cnt].detaillist[i].groupseq)
      SET stat = uar_srvsetlong(hitem,"fieldSeq",replyout->orderlist[cnt].detaillist[i].fieldseq)
      SET stat = uar_srvsetshort(hitem,"modifiedInd",replyout->orderlist[cnt].detaillist[i].
       modifiedind)
    ENDFOR
    FOR (i = 1 TO size(replyout->orderlist[cnt].misclist,5))
      SET hitem = uar_srvadditem(horder,"miscList")
      SET stat = uar_srvsetstring(hitem,"fieldMeaning",nullterm(trim(replyout->orderlist[cnt].
         misclist[i].fieldmeaning)))
      SET stat = uar_srvsetdouble(hitem,"fieldMeaningId",replyout->orderlist[cnt].misclist[i].
       fieldmeaningid)
      SET stat = uar_srvsetdouble(hitem,"fieldValue",replyout->orderlist[cnt].misclist[i].fieldvalue)
      SET stat = uar_srvsetstring(hitem,"fieldDisplayValue",nullterm(trim(replyout->orderlist[cnt].
         misclist[i].fielddisplayvalue)))
      SET stat = uar_srvsetdate(hitem,"fieldDtTmValue",cnvtdatetime(replyout->orderlist[cnt].
        misclist[i].fielddttmvalue))
      SET stat = uar_srvsetshort(hitem,"modifiedInd",replyout->orderlist[cnt].misclist[i].modifiedind
       )
    ENDFOR
    FOR (i = 1 TO size(replyout->orderlist[cnt].resourcelist,5))
     SET hitem = uar_srvadditem(horder,"resourceList")
     SET stat = uar_srvsetdouble(hitem,"serviceResourceCd",replyout->orderlist[cnt].resourcelist[i].
      serviceresourcecd)
    ENDFOR
  ENDFOR
  SET stat = uar_crmperform(hstep)
  IF (stat > 0)
   CALL populate_subeventstatus_msg("UAR","F","CrmPerform",build("Perform failed:",stat),
    log_level_audit)
   GO TO exit_script
  ENDIF
  SET hreply = uar_crmgetreply(hstep)
  SET nbadordercnt = uar_srvgetshort(hreply,"badOrderCnt")
  SET horder = uar_srvgetitem(hreply,"orderList",0)
  IF (nbadordercnt=0)
   SET orders->qual[1].failed_ind = 0
   SET reply->order_id = uar_srvgetdouble(horder,"orderId")
   SET reply->status_data.status = "S"
  ELSE
   SET reply->ord_srv_error_msg = uar_srvgetstringptr(horder,"errorStr")
   SET reply->ord_srv_spec_error_msg = uar_srvgetstringptr(horder,"specificErrorStr")
   CALL populate_subeventstatus_msg("RECOVER","F","ORDER SERVER","Attempted recovery failed",
    log_level_audit)
  ENDIF
 ENDIF
#exit_script
 EXECUTE pfmt_e200386
 IF (hstep > 0)
  CALL uar_crmendreq(hstep)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ > 0)
  IF (nbegannewappind=1)
   CALL uar_crmendapp(happ)
  ENDIF
 ENDIF
#exit_script_2
 CALL error_message(1)
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE SET requestin
 FREE SET replyout
END GO
