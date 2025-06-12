CREATE PROGRAM create_encntr_mrns:dba
 SET message = noinformation
 SET trace = nocost
 IF (validate(last_mod,"NO_MOD")="NO_MOD")
  DECLARE last_mod = c6 WITH private, noconstant("")
 ENDIF
 SET last_mod = "548192"
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
 CALL echo("*****pm_create_hist_id.inc - 477739****")
 CALL echo("*****pm_create_hist_id.inc - 581128****")
 IF ((validate(bpm_create_hist_id,- (9))=- (9)))
  DECLARE bpm_create_hist_id = i2 WITH constant(true)
  DECLARE bhistoryoption = i2 WITH noconstant(false)
  DECLARE dhistid = f8 WITH noconstant(0.0)
  DECLARE history_cd = f8 WITH noconstant(0.0)
  DECLARE bcheckedhist = i2 WITH noconstant(false)
  SUBROUTINE (pm_checkhistory(itemp=i2) =null)
    IF (bhistoryoption != true
     AND bcheckedhist != true)
     SET bhistoryoption = true
     SET bcheckedhist = true
    ENDIF
  END ;Subroutine
  SUBROUTINE (pm_createid(hist_script=vc,hist_action=vc) =i2)
    FREE RECORD hist_tracking_req
    RECORD hist_tracking_req(
      1 action_flag = i2
      1 conv_task_number = i4
      1 transaction_dt_tm = dq8
      1 pm_hist_tracking_id = f8
      1 person_id = f8
      1 encntr_id = f8
      1 contributor_system_cd = f8
      1 transaction_reason_cd = f8
      1 transaction_reason_txt = c100
      1 transaction_type_txt = c4
      1 hl7_event = c10
      1 facility_org_id = f8
    )
    SET hist_tracking_req->action_flag = 3
    SET hist_tracking_req->pm_hist_tracking_id = 0.0
    SET hist_tracking_req->conv_task_number = 0
    SET hist_tracking_req->contributor_system_cd = 0.0
    SET hist_tracking_req->transaction_dt_tm = cnvtdatetime(sysdate)
    SET hist_tracking_req->transaction_reason_cd = 0.0
    SET hist_tracking_req->transaction_reason_txt = trim(hist_script,3)
    SET hist_tracking_req->transaction_type_txt = trim(hist_action,3)
    IF ((validate(hist_tracking_reply->pm_hist_tracking_id,- (99))=- (99)))
     RECORD hist_tracking_reply(
       1 pm_hist_tracking_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
    ENDIF
    EXECUTE pm_ens_hist_tracking  WITH replace("REQUEST","HIST_TRACKING_REQ"), replace("REPLY",
     "HIST_TRACKING_REPLY")
    IF ((hist_tracking_reply->status_data.status != "S"))
     RETURN(false)
    ELSE
     SET dhistid = hist_tracking_reply->pm_hist_tracking_id
     RETURN(true)
    ENDIF
  END ;Subroutine
 ENDIF
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_clean_alias_pools TO 2999_clean_alias_pools_exit
 EXECUTE FROM 3000_build_mrns TO 3999_build_mrns_exit
 GO TO 9999_exit_program
 SUBROUTINE log_error(log_error_message)
   SET log_handle = 0
   SET log_status = 0
   CALL uar_syscreatehandle(log_handle,log_status)
   IF (log_handle != 0)
    CALL uar_sysevent(log_handle,0,"PM_GEN_MRNS",nullterm(log_error_message))
    CALL uar_sysdestroyhandle(log_handle)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_message(log_message_message)
   SET log_handle = 0
   SET log_status = 0
   CALL uar_syscreatehandle(log_handle,log_status)
   IF (log_handle != 0)
    CALL uar_sysevent(log_handle,2,"PM_GEN_MRNS",nullterm(log_message_message))
    CALL uar_sysdestroyhandle(log_handle)
   ENDIF
 END ;Subroutine
#1000_initialize
 CALL log_message("Initializing.")
 DECLARE bcreatereq = i2 WITH noconstant(false)
 DECLARE bcreateid = i2 WITH noconstant(false)
 DECLARE person_alias_type_cd = f8 WITH noconstant(0.0)
 DECLARE encntr_alias_type_cd = f8 WITH noconstant(0.0)
 DECLARE active_status_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,person_alias_type_cd)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,encntr_alias_type_cd)
 SET active_status_cd = reqdata->active_status_cd
 IF (person_alias_type_cd <= 0.0)
  CALL log_error("No code value meaning MRN on codeset 4.")
  GO TO 9999_exit_program
 ENDIF
 IF (encntr_alias_type_cd <= 0.0)
  CALL log_error("No code value meaning MRN on codeset 319.")
  GO TO 9999_exit_program
 ENDIF
 IF (active_status_cd <= 0.0)
  CALL log_error("No code value meaning ACTIVE on codeset 48.")
  GO TO 9999_exit_program
 ENDIF
#1999_initialize_exit
#2000_clean_alias_pools
 CALL log_message("Starting the alias pool cleaning process.")
 FREE SET orgs
 RECORD orgs(
   1 org[*]
     2 org_id = f8
     2 alias_pool_cd = f8
     2 auto_assign_flag = i2
 )
 SET org_count = 0
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o,
   org_alias_pool_reltn p
  PLAN (p
   WHERE p.alias_entity_name="PERSON_ALIAS"
    AND p.alias_entity_alias_type_cd=person_alias_type_cd
    AND ((p.active_ind+ 0)=1)
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
    AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
    AND ((p.alias_pool_cd+ 0) > 0.0)
    AND ((p.organization_id+ 0) > 0.0))
   JOIN (o
   WHERE o.organization_id=p.organization_id)
  DETAIL
   org_count += 1, stat = alterlist(orgs->org,org_count), orgs->org[org_count].org_id = p
   .organization_id,
   orgs->org[org_count].alias_pool_cd = p.alias_pool_cd, orgs->org[org_count].auto_assign_flag = p
   .auto_assign_flag
  WITH nocounter
 ;end select
 SET correction_count = 0
 FOR (i = 1 TO org_count)
   SET org_id = orgs->org[i].org_id
   SET alias_pool_cd = orgs->org[i].alias_pool_cd
   SET auto_assign_flag = orgs->org[i].auto_assign_flag
   SET pool_count = 0
   SET good_pool_count = 0
   SELECT INTO "nl:"
    p.alias_pool_cd
    FROM org_alias_pool_reltn p
    WHERE p.organization_id=org_id
     AND p.alias_entity_name="ENCNTR_ALIAS"
     AND p.alias_entity_alias_type_cd=encntr_alias_type_cd
    DETAIL
     pool_count += 1
     IF (p.alias_pool_cd=alias_pool_cd)
      good_pool_count += 1
     ENDIF
    WITH nocounter
   ;end select
   IF (((pool_count > 1) OR (good_pool_count != 1)) )
    DELETE  FROM org_alias_pool_reltn p
     WHERE p.organization_id=org_id
      AND p.alias_entity_name="ENCNTR_ALIAS"
      AND p.alias_entity_alias_type_cd=encntr_alias_type_cd
     WITH nocounter
    ;end delete
    INSERT  FROM org_alias_pool_reltn p
     SET p.organization_id = org_id, p.alias_entity_name = "ENCNTR_ALIAS", p
      .alias_entity_alias_type_cd = encntr_alias_type_cd,
      p.alias_pool_cd = alias_pool_cd, p.updt_id = 0, p.updt_dt_tm = cnvtdatetime(sysdate),
      p.updt_task = 0, p.updt_cnt = 0, p.updt_applctx = 0,
      p.active_ind = 1, p.active_status_cd = active_status_cd, p.active_status_dt_tm = cnvtdatetime(
       sysdate),
      p.active_status_prsnl_id = 0, p.beg_effective_dt_tm = cnvtdatetime(sysdate), p
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      p.auto_assign_flag = auto_assign_flag
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET correction_count += 1
    ENDIF
    COMMIT
   ENDIF
 ENDFOR
 CALL log_message("Finished with the alias pool cleaning process.")
 CALL log_message(concat(trim(cnvtstring(correction_count))," pools corrected."))
#2999_clean_alias_pools_exit
#3000_build_mrns
 CALL log_message("Starting the MRN build process.")
 FREE SET encounters
 RECORD encounters(
   1 encounter[*]
     2 encntr_id = f8
 )
 SET encounter_count = 0
 SET incomplete_count = 0
 SET no_pool_count = 0
 SET no_mrn_count = 0
 SET correction_count = 0
 SET alias_pool_cd = 0.0
 SET prev_org_id = 0.0
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e
  WHERE e.encntr_id > 0
   AND e.active_ind=1
   AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   encounter_count += 1, stat = alterlist(encounters->encounter,encounter_count), encounters->
   encounter[encounter_count].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 SET start_time = cnvtdatetime(sysdate)
 FOR (i = 1 TO encounter_count)
   SET encntr_id = encounters->encounter[i].encntr_id
   SET person_id = 0.0
   SET org_id = 0.0
   SET contributor_system_cd = 0.0
   SET data_status_cd = 0.0
   SELECT INTO "nl:"
    e.person_id
    FROM encounter e
    WHERE e.encntr_id=encntr_id
    DETAIL
     person_id = e.person_id, org_id = e.organization_id, contributor_system_cd = e
     .contributor_system_cd,
     data_status_cd = e.data_status_cd
    WITH nocounter
   ;end select
   IF (person_id > 0.0
    AND org_id > 0.0)
    IF (org_id != prev_org_id)
     SET prev_org_id = org_id
     SET alias_pool_cd = 0.0
     SELECT INTO "nl:"
      p.alias_pool_cd
      FROM org_alias_pool_reltn p
      WHERE p.organization_id=org_id
       AND p.alias_entity_name="ENCNTR_ALIAS"
       AND p.alias_entity_alias_type_cd=encntr_alias_type_cd
      DETAIL
       alias_pool_cd = p.alias_pool_cd
      WITH nocounter
     ;end select
    ENDIF
    IF (alias_pool_cd > 0.0)
     SET mrn_count = 0
     SET check_digit = 0
     SET check_digit_method_cd = 0.0
     FREE SET aliases
     RECORD aliases(
       1 person_alias = vc
       1 encntr_alias = vc
     )
     SELECT INTO "nl:"
      a.alias
      FROM person_alias a
      WHERE a.person_id=person_id
       AND ((a.alias_pool_cd+ 0)=alias_pool_cd)
       AND ((a.active_ind+ 0)=1)
       AND ((a.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
       AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
      DETAIL
       mrn_count += 1, check_digit = a.check_digit, check_digit_method_cd = a.check_digit_method_cd,
       aliases->person_alias = a.alias
      WITH nocounter
     ;end select
     IF (mrn_count=1)
      SET mrn_count = 0
      SELECT INTO "nl:"
       a.alias
       FROM encntr_alias a
       WHERE a.encntr_id=encntr_id
        AND ((a.alias_pool_cd+ 0)=alias_pool_cd)
        AND ((a.active_ind+ 0)=1)
        AND ((a.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
       DETAIL
        mrn_count += 1, aliases->encntr_alias = a.alias
       WITH nocounter
      ;end select
      SET build = 0
      IF (mrn_count=1)
       IF ((aliases->person_alias != aliases->encntr_alias))
        SET build = 1
       ENDIF
      ELSE
       SET build = 1
      ENDIF
      IF (build=1)
       IF (mrn_count > 0)
        FREE RECORD dalias
        RECORD dalias(
          1 list[*]
            2 id = f8
        )
        SET stat = alterlist(dalias->list,5)
        SET cnt = 0
        SELECT INTO "nl:"
         FROM encntr_alias a
         WHERE a.encntr_id=encntr_id
          AND ((a.encntr_alias_type_cd+ 0)=encntr_alias_type_cd)
         DETAIL
          cnt += 1
          IF (mod(cnt,5)=1)
           stat = alterlist(dalias->list,(cnt+ 4))
          ENDIF
          dalias->list[cnt].id = a.encntr_alias_id
         WITH nocounter
        ;end select
        IF (cnt > 0)
         SET stat = alterlist(dalias->list,cnt)
         IF (dhistid <= 0)
          SET bcreateid = pm_createid("CREATE_ENCNTR_MRNS","UPT")
          IF (bcreateid != true)
           CALL log_message("Unable to create pm_hist_tracking_id")
           GO TO 9999_exit_program
          ENDIF
         ENDIF
         SET bcreatereq = cr_createrequest(0,101302,"encntr_alias_req")
         IF (bcreatereq != true)
          CALL log_message("Unable to create request for pm_upt_encntr_alias.prg")
          GO TO 9999_exit_program
         ENDIF
         SET stat = alterlist(encntr_alias_req->encntr_alias,cnt)
         SET encntr_alias_req->encntr_alias_qual = cnt
         FOR (x = 1 TO cnt)
           SET encntr_alias_req->encntr_alias[x].encntr_alias_id = dalias->list[x].id
           SET encntr_alias_req->encntr_alias[x].active_ind = 0
           SET encntr_alias_req->encntr_alias[x].active_ind_ind = true
           SET encntr_alias_req->encntr_alias[x].active_status_cd = reqdata->inactive_status_cd
           SET encntr_alias_req->encntr_alias[x].alias = " "
           IF ((validate(encntr_alias_req->encntr_alias[x].pm_hist_tracking_id,- (99)) != - (99)))
            SET encntr_alias_req->encntr_alias[x].pm_hist_tracking_id = dhistid
           ENDIF
         ENDFOR
         FREE RECORD encntr_alias_reply
         RECORD encntr_alias_reply(
           1 encntr_alias_qual = i4
           1 encntr_alias[*]
             2 encntr_alias_id = f8
             2 pm_hist_tracking_id = f8
             2 assign_authority_sys_ind = i2
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
         EXECUTE pm_upt_encntr_alias  WITH replace("REQUEST","ENCNTR_ALIAS_REQ"), replace("REPLY",
          "ENCNTR_ALIAS_REPLY")
         IF ((encntr_alias_reply->status_data.status != "S"))
          CALL log_message("Unable to update encntr_alias table.")
          GO TO 9999_exit_program
         ENDIF
        ENDIF
       ENDIF
       IF (dhistid <= 0)
        SET bcreateid = pm_createid("CREATE_ENCNTR_MRNS","UPT")
        IF (bcreateid != true)
         CALL log_message("Unable to create pm_hist_tracking_id")
         GO TO 9999_exit_program
        ENDIF
       ENDIF
       SET bcreatereq = cr_createrequest(0,101302,"encntr_alias_req")
       IF (bcreatereq != true)
        CALL log_message("Unable to create request for pm_add_encntr_alias.prg")
        GO TO 9999_exit_program
       ENDIF
       SET stat = alterlist(encntr_alias_req->encntr_alias,1)
       SET encntr_alias_req->encntr_alias_qual = 1
       SET encntr_alias_req->encntr_alias[1].encntr_alias_id = 0.0
       SET encntr_alias_req->encntr_alias[1].encntr_id = encntr_id
       SET encntr_alias_req->encntr_alias[1].alias_pool_cd = alias_pool_cd
       SET encntr_alias_req->encntr_alias[1].encntr_alias_type_cd = encntr_alias_type_cd
       SET encntr_alias_req->encntr_alias[1].alias = aliases->person_alias
       SET encntr_alias_req->encntr_alias[1].check_digit = check_digit
       SET encntr_alias_req->encntr_alias[1].check_digit_method_cd = check_digit_method_cd
       SET encntr_alias_req->encntr_alias[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
       SET encntr_alias_req->encntr_alias[1].end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00")
       SET encntr_alias_req->encntr_alias[1].data_status_cd = data_status_cd
       SET encntr_alias_req->encntr_alias[1].contributor_system_cd = contributor_system_cd
       IF ((validate(encntr_alias_req->encntr_alias[1].pm_hist_tracking_id,- (99)) != - (99)))
        SET encntr_alias_req->encntr_alias[1].pm_hist_tracking_id = dhistid
       ENDIF
       FREE RECORD encntr_alias_reply
       RECORD encntr_alias_reply(
         1 encntr_alias_qual = i4
         1 encntr_alias[*]
           2 encntr_alias_id = f8
           2 pm_hist_tracking_id = f8
           2 assign_authority_sys_ind = i2
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
       EXECUTE pm_add_encntr_alias  WITH replace("REQUEST","ENCNTR_ALIAS_REQ"), replace("REPLY",
        "ENCNTR_ALIAS_REPLY")
       IF ((encntr_alias_reply->status_data.status != "S"))
        CALL log_message("Unable to insert into encntr_alias table.")
        GO TO 9999_exit_program
       ENDIF
       SET correction_count += 1
       COMMIT
      ENDIF
     ELSE
      SET no_mrn_count += 1
     ENDIF
    ELSE
     SET no_pool_count += 1
    ENDIF
   ELSE
    SET incomplete_count += 1
   ENDIF
   IF (mod(i,100)=0)
    CALL log_message(concat(trim(cnvtstring(i))," out of ",trim(cnvtstring(encounter_count)),
      " encounters processed."))
   ENDIF
 ENDFOR
 SET stop_time = cnvtdatetime(sysdate)
 CALL log_message("Finished with the MRN build process.")
 CALL log_message(concat(trim(cnvtstring(incomplete_count))," encounter(s) had insufficient data."))
 CALL log_message(concat(trim(cnvtstring(no_pool_count))," encounter(s) had no alias pool."))
 CALL log_message(concat(trim(cnvtstring(no_mrn_count))," encounter(s) had no MRN or duplicate MRNs."
   ))
 CALL log_message(concat(trim(cnvtstring(correction_count))," encounter(s) were succesfully cleaned."
   ))
 SET total_seconds = (datetimediff(stop_time,start_time) * ((24 * 60) * 60))
 SET encounters_per_minute = ((encounter_count/ total_seconds) * 60)
 CALL log_message(concat(trim(cnvtstring(encounters_per_minute))," encounters processed per minute.")
  )
#3999_build_mrns_exit
#9999_exit_program
 COMMIT
END GO
