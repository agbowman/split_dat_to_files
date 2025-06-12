CREATE PROGRAM aps_add_case_proc_tasks:dba
 RECORD reply(
   1 proc_qual[1]
     2 processing_task_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 slide_id = f8
     2 create_inventory_flag = i2
     2 case_specimen_tag_cd = f8
     2 cassette_tag_cd = f8
     2 slide_tag_cd = f8
     2 universal_service_ident = vc
     2 placer_field_1 = vc
     2 suplmtl_serv_info_txt = vc
     2 stain_universal_service_ident = vc
     2 stain_placer_field_1 = vc
     2 stain_suplmtl_serv_info_txt = vc
     2 stain_proc_task_id = f8
     2 task_assay_cd = f8
     2 task_assay_disp = vc
   1 updt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 label_job_data
     2 job_directory = vc
     2 job_filename = vc
     2 job_dir_and_filename = vc
     2 job_content = gvc
     2 suppress_spool_ind = i2
     2 line_template = vc
   1 proc_chg_qual[*]
     2 processing_task_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 slide_id = f8
     2 create_inventory_flag = i2
     2 case_specimen_tag_cd = f8
     2 cassette_tag_cd = f8
     2 slide_tag_cd = f8
     2 universal_service_ident = vc
     2 placer_field_1 = vc
     2 suplmtl_serv_info_txt = vc
     2 stain_universal_service_ident = vc
     2 stain_placer_field_1 = vc
     2 stain_suplmtl_serv_info_txt = vc
     2 stain_proc_task_id = f8
     2 task_assay_cd = f8
     2 task_assay_disp = vc
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
 CALL cr_createrequest(0,200456,"REQ200456")
 CALL cr_createrequest(1,200456,"REP200456")
 RECORD temp_specimens(
   1 qual[*]
     2 case_specimen_id = f8
     2 case_specimen_order_id = f8
     2 case_specimen_status_cd = f8
     2 updt_cnt = i4
     2 gross_ind = i2
     2 curr_order_id = f8
     2 curr_updt_cnt = i4
     2 updt_applctx = f8
 )
 RECORD temp_processing(
   1 lnewcomment = i4
   1 lupdatedcomment = i4
   1 lremovedcomment = i4
   1 qual[*]
     2 processing_task_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 slide_id = f8
     2 create_inventory_flag = i2
     2 task_assay_cd = f8
     2 catalog_cd = f8
     2 order_id = f8
     2 service_resource_cd = f8
     2 priority_cd = f8
     2 lt_updt_cnt = i4
     2 comment_flag = i2
     2 comments_long_text_id = f8
     2 comment = vc
     2 case_specimen_tag_cd = f8
     2 cassette_tag_cd = f8
     2 slide_tag_cd = f8
     2 cancel_cd = f8
     2 updt_cnt = i4
     2 no_charge_ind = i2
     2 research_account_id = f8
     2 curr_order_id = f8
     2 curr_updt_cnt = i4
     2 updt_applctx = f8
     2 stain_proc_task_id = f8
 )
 RECORD temp_cassette(
   1 qual[*]
     2 cassette_id = f8
     2 case_specimen_id = f8
     2 cassette_tag_cd = f8
     2 task_assay_cd = f8
     2 fixative_cd = f8
     2 origin_modifier = c7
     2 pieces = c3
     2 updt_cnt = i4
     2 curr_updt_cnt = i4
 )
 RECORD temp_slide(
   1 qual[*]
     2 slide_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 task_assay_cd = f8
     2 stain_task_assay_cd = f8
     2 tag_cd = f8
     2 origin_modifier = c7
     2 updt_cnt = i4
     2 curr_updt_cnt = i4
 )
 RECORD order_comment(
   1 qual[*]
     2 processing_task_id = f8
 )
 RECORD temp_index(
   1 qual[*]
     2 id = f8
 )
 RECORD temp_digital_slide(
   1 qual[*]
     2 digital_slide_id = f8
 )
 RECORD inventory(
   1 list[*]
     2 content_table_name = vc
     2 content_table_id = f8
   1 del_qual_cnt = i4
 )
#script
 DECLARE label_cnt = i4 WITH protect, noconstant(0)
 DECLARE nitem = i4 WITH protect, noconstant(0)
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET cass_cnt = 0
 SET slide_cnt = 0
 SET task_cnt = 0
 SET nbr_specimens = cnvtint(size(request->spec_qual,5))
 SET temp_proc_cnt = 0
 SET temp_slide_cnt = 0
 SET temp_cass_cnt = 0
 SET nbr_s_t = 0
 SET nbr_s_s = 0
 SET nbr_s_s_t = 0
 SET nbr_s_c = 0
 SET nbr_s_c_t = 0
 SET nbr_s_c_s = 0
 SET nbr_s_c_s_t = 0
 SET nbr_items = 0
 SET cnt = 0
 SET temp_specimen_cnt = 0
 SET x = 0
 SET num_of_mod_comments = 0
 SET num_of_removed_comments = 0
 SET num_of_new_comments = 0
 SET upd_gross_ind = 0
 SET nbr_spec_to_gross = 0
 DECLARE cur_cass_id = f8 WITH protect, noconstant(0.0)
 DECLARE cur_slide_id = f8 WITH protect, noconstant(0.0)
 DECLARE ordered_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cancelled_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE invnty_cnt = i4 WITH protect, noconstant(0)
 DECLARE chg_cnt = i4 WITH protect, noconstant(0)
 DECLARE interface_flag = i2 WITH protect, noconstant(0)
 DECLARE tracking_service_resource_cd = f8 WITH protect, noconstant(0.0)
 DECLARE batch_size = i4 WITH noconstant(20)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE lvindex = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE padded_size = i4 WITH noconstant(0)
 DECLARE temp_index_cnt = i4 WITH noconstant(0)
 SET stat = alterlist(temp_specimens->qual,10)
 SET stat = alterlist(temp_processing->qual,10)
 SET stat = alterlist(temp_slide->qual,10)
 SET stat = alterlist(temp_cassette->qual,10)
 SET reply->updt_id = reqinfo->updt_id
 SET stat = uar_get_meaning_by_codeset(1305,"ORDERED",1,ordered_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancelled_status_cd)
 IF (ordered_status_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - ORDERED"
  GO TO exit_script
 ENDIF
 IF (processing_status_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - PROCESSING"
  GO TO exit_script
 ENDIF
 IF (verified_status_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - VERIFIED"
  GO TO exit_script
 ENDIF
 IF (cancelled_status_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - CANCEL"
  GO TO exit_script
 ENDIF
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 SELECT INTO "nl:"
  ap.interface_flag, ap.service_resource_cd
  FROM pathology_case pc,
   ap_prefix ap
  PLAN (pc
   WHERE (pc.case_id=request->case_id))
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id)
  DETAIL
   interface_flag = ap.interface_flag, tracking_service_resource_cd = ap.tracking_service_resource_cd
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO nbr_specimens)
   IF ((request->spec_qual[cnt].case_comment_long_text_id=0)
    AND textlen(trim(request->spec_qual[cnt].case_comment)) > 0)
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      num_of_new_comments += 1, request->spec_qual[cnt].case_comment_long_text_id = seq_nbr, request
      ->spec_qual[cnt].case_comment_new = "Y"
     WITH format, counter
    ;end select
   ELSE
    IF ((request->spec_qual[cnt].case_comment_long_text_id > 0))
     IF (textlen(trim(request->spec_qual[cnt].case_comment)) > 0)
      SET num_of_mod_comments += 1
     ELSE
      SET num_of_removed_comments += 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (cnt = 1 TO nbr_specimens)
  IF ((request->spec_qual[cnt].add_ind="Y"))
   IF ((request->spec_qual[cnt].case_specimen_status_cd > 0))
    SET upd_gross_ind = 1
    SET temp_specimen_cnt += 1
    IF (mod(temp_specimen_cnt,10)=1
     AND temp_specimen_cnt != 1)
     SET stat = alterlist(temp_specimens->qual,(temp_specimen_cnt+ 9))
    ENDIF
    SET temp_specimens->qual[temp_specimen_cnt].case_specimen_id = request->spec_qual[cnt].
    case_specimen_id
    SET temp_specimens->qual[temp_specimen_cnt].case_specimen_status_cd = request->spec_qual[cnt].
    case_specimen_status_cd
    SET temp_specimens->qual[temp_specimen_cnt].updt_cnt = request->spec_qual[cnt].
    case_specimen_updt_cnt
    SET temp_specimens->qual[temp_specimen_cnt].case_specimen_order_id = request->spec_qual[cnt].
    case_specimen_order_id
   ELSE
    SET upd_gross_ind = 0
   ENDIF
   SET nbr_s_t = cnvtint(size(request->spec_qual[cnt].task_add_qual,5))
   IF (nbr_s_t > 0)
    FOR (task_cnt = 1 TO nbr_s_t)
      SET temp_proc_cnt += 1
      IF (mod(temp_proc_cnt,10)=1
       AND temp_proc_cnt != 1)
       SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
      ENDIF
      SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
      case_specimen_id
      SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
      SET temp_processing->qual[temp_proc_cnt].slide_id = 0
      SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
      case_specimen_tag_cd
      SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
      SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
      SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
      task_add_qual[task_cnt].create_inventory_flag
      SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].task_add_qual[
      task_cnt].task_assay_cd
      SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].task_add_qual[
      task_cnt].catalog_cd
      SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
      task_add_qual[task_cnt].service_resource_cd
      SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].task_add_qual[
      task_cnt].priority_cd
      SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].task_add_qual[
      task_cnt].comment
      SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
      task_add_qual[task_cnt].comments_long_text_id
      SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].task_add_qual[
      task_cnt].lt_updt_cnt
      SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
      SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].task_add_qual[
      task_cnt].no_charge_ind
      SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
      task_add_qual[task_cnt].research_account_id
      IF ((request->spec_qual[cnt].task_add_qual[task_cnt].task_type_flag != 0)
       AND upd_gross_ind=1)
       SET temp_specimens->qual[temp_specimen_cnt].gross_ind = 1
      ENDIF
    ENDFOR
   ENDIF
   SET nbr_s_s = cnvtint(size(request->spec_qual[cnt].slide_add_qual,5))
   IF (nbr_s_s > 0)
    FOR (slide_cnt = 1 TO nbr_s_s)
      IF ((request->spec_qual[cnt].slide_add_qual[slide_cnt].slide_id=0))
       SET temp_slide_cnt += 1
       IF (mod(temp_slide_cnt,10)=1
        AND temp_slide_cnt != 1)
        SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 9))
       ENDIF
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         cur_slide_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        GO TO seq_failed
       ENDIF
       SET temp_slide->qual[temp_slide_cnt].slide_id = cur_slide_id
       SET temp_slide->qual[temp_slide_cnt].case_specimen_id = request->spec_qual[cnt].
       case_specimen_id
       SET temp_slide->qual[temp_slide_cnt].cassette_id = 0
       SET temp_slide->qual[temp_slide_cnt].task_assay_cd = request->spec_qual[cnt].slide_add_qual[
       slide_cnt].task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = request->spec_qual[cnt].
       slide_add_qual[slide_cnt].stain_task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].tag_cd = request->spec_qual[cnt].slide_add_qual[slide_cnt
       ].tag_cd
       SET temp_slide->qual[temp_slide_cnt].origin_modifier = request->spec_qual[cnt].slide_add_qual[
       slide_cnt].origin_modifier
      ELSE
       SET cur_slide_id = request->spec_qual[cnt].slide_add_qual[slide_cnt].slide_id
      ENDIF
      SET nbr_s_s_t = cnvtint(size(request->spec_qual[cnt].slide_add_qual[slide_cnt].task_qual,5))
      IF (nbr_s_s_t > 0)
       FOR (task_cnt = 1 TO nbr_s_s_t)
         SET temp_proc_cnt += 1
         IF (mod(temp_proc_cnt,10)=1
          AND temp_proc_cnt != 1)
          SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
         ENDIF
         SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
         case_specimen_id
         SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
         SET temp_processing->qual[temp_proc_cnt].slide_id = cur_slide_id
         SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
         case_specimen_tag_cd
         SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
         SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].tag_cd
         SET temp_processing->qual[temp_proc_cnt].stain_proc_task_id = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].stain_proc_task_id
         SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].create_inventory_flag
         SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].task_assay_cd
         SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].catalog_cd
         SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].service_resource_cd
         SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].priority_cd
         SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].slide_add_qual[
         slide_cnt].task_qual[task_cnt].comment
         SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].comments_long_text_id
         SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].lt_updt_cnt
         SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
         SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].no_charge_ind
         SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
         slide_add_qual[slide_cnt].task_qual[task_cnt].research_account_id
         IF ((request->spec_qual[cnt].slide_add_qual[slide_cnt].task_qual[task_cnt].task_type_flag
          != 0)
          AND upd_gross_ind=1)
          SET temp_specimens->qual[temp_specimen_cnt].gross_ind = 1
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   SET nbr_s_c = cnvtint(size(request->spec_qual[cnt].cassette_add_qual,5))
   IF (nbr_s_c > 0)
    FOR (cass_cnt = 1 TO nbr_s_c)
      IF ((request->spec_qual[cnt].cassette_add_qual[cass_cnt].cassette_id=0))
       SET temp_cass_cnt += 1
       IF (mod(temp_cass_cnt,10)=1
        AND temp_cass_cnt != 1)
        SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 9))
       ENDIF
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         cur_cass_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        GO TO seq_failed
       ENDIF
       SET temp_cassette->qual[temp_cass_cnt].cassette_id = cur_cass_id
       SET temp_cassette->qual[temp_cass_cnt].case_specimen_id = request->spec_qual[cnt].
       case_specimen_id
       SET temp_cassette->qual[temp_cass_cnt].cassette_tag_cd = request->spec_qual[cnt].
       cassette_add_qual[cass_cnt].cassette_tag_cd
       SET temp_cassette->qual[temp_cass_cnt].fixative_cd = request->spec_qual[cnt].
       cassette_add_qual[cass_cnt].fixative_cd
       SET temp_cassette->qual[temp_cass_cnt].task_assay_cd = request->spec_qual[cnt].
       cassette_add_qual[cass_cnt].task_assay_cd
       SET temp_cassette->qual[temp_cass_cnt].origin_modifier = request->spec_qual[cnt].
       cassette_add_qual[cass_cnt].origin_modifier
       SET temp_cassette->qual[temp_cass_cnt].pieces = request->spec_qual[cnt].cassette_add_qual[
       cass_cnt].pieces
      ELSE
       SET cur_cass_id = request->spec_qual[cnt].cassette_add_qual[cass_cnt].cassette_id
      ENDIF
      SET nbr_s_c_t = cnvtint(size(request->spec_qual[cnt].cassette_add_qual[cass_cnt].task_qual,5))
      IF (nbr_s_c_t > 0)
       FOR (task_cnt = 1 TO nbr_s_c_t)
         SET temp_proc_cnt += 1
         IF (mod(temp_proc_cnt,10)=1
          AND temp_proc_cnt != 1)
          SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
         ENDIF
         SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
         case_specimen_id
         SET temp_processing->qual[temp_proc_cnt].cassette_id = cur_cass_id
         SET temp_processing->qual[temp_proc_cnt].slide_id = 0
         SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
         case_specimen_tag_cd
         SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].cassette_tag_cd
         SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
         SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].create_inventory_flag
         SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].task_assay_cd
         SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].catalog_cd
         SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].service_resource_cd
         SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].priority_cd
         SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].comment
         SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].comments_long_text_id
         SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].lt_updt_cnt
         SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
         SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].no_charge_ind
         SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
         cassette_add_qual[cass_cnt].task_qual[task_cnt].research_account_id
         IF ((request->spec_qual[cnt].cassette_add_qual[cass_cnt].task_qual[task_cnt].task_type_flag
          != 0)
          AND upd_gross_ind=1)
          SET temp_specimens->qual[temp_specimen_cnt].gross_ind = 1
         ENDIF
       ENDFOR
      ENDIF
      SET nbr_s_c_s = cnvtint(size(request->spec_qual[cnt].cassette_add_qual[cass_cnt].slide_qual,5))
      IF (nbr_s_c_s > 0)
       FOR (slide_cnt = 1 TO nbr_s_c_s)
         IF ((request->spec_qual[cnt].cassette_add_qual[cass_cnt].slide_qual[slide_cnt].slide_id=0))
          SET temp_slide_cnt += 1
          IF (mod(temp_slide_cnt,10)=1
           AND temp_slide_cnt != 1)
           SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 9))
          ENDIF
          SELECT INTO "nl:"
           seq_nbr = seq(pathnet_seq,nextval)
           FROM dual
           DETAIL
            cur_slide_id = seq_nbr
           WITH format, nocounter
          ;end select
          IF (curqual=0)
           GO TO seq_failed
          ENDIF
          SET temp_slide->qual[temp_slide_cnt].slide_id = cur_slide_id
          SET temp_slide->qual[temp_slide_cnt].case_specimen_id = 0
          SET temp_slide->qual[temp_slide_cnt].cassette_id = cur_cass_id
          SET temp_slide->qual[temp_slide_cnt].task_assay_cd = request->spec_qual[cnt].
          cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_assay_cd
          SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = request->spec_qual[cnt].
          cassette_add_qual[cass_cnt].slide_qual[slide_cnt].stain_task_assay_cd
          SET temp_slide->qual[temp_slide_cnt].tag_cd = request->spec_qual[cnt].cassette_add_qual[
          cass_cnt].slide_qual[slide_cnt].tag_cd
          SET temp_slide->qual[temp_slide_cnt].origin_modifier = request->spec_qual[cnt].
          cassette_add_qual[cass_cnt].slide_qual[slide_cnt].origin_modifier
         ELSE
          SET cur_slide_id = request->spec_qual[cnt].cassette_add_qual[cass_cnt].slide_qual[slide_cnt
          ].slide_id
         ENDIF
         SET nbr_s_c_s_t = cnvtint(size(request->spec_qual[cnt].cassette_add_qual[cass_cnt].
           slide_qual[slide_cnt].task_qual,5))
         IF (nbr_s_c_s_t > 0)
          FOR (task_cnt = 1 TO nbr_s_c_s_t)
            SET temp_proc_cnt += 1
            IF (mod(temp_proc_cnt,10)=1
             AND temp_proc_cnt != 1)
             SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
            ENDIF
            SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
            case_specimen_id
            SET temp_processing->qual[temp_proc_cnt].cassette_id = cur_cass_id
            SET temp_processing->qual[temp_proc_cnt].slide_id = cur_slide_id
            SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
            case_specimen_tag_cd
            SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].cassette_tag_cd
            SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].tag_cd
            SET temp_processing->qual[temp_proc_cnt].stain_proc_task_id = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].stain_proc_task_id
            SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
            create_inventory_flag
            SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].task_assay_cd
            SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].catalog_cd
            SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].service_resource_cd
            SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].priority_cd
            SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].comment
            SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
            comments_long_text_id
            SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].lt_updt_cnt
            SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
            SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].no_charge_ind
            SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
            cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].research_account_id
            IF ((request->spec_qual[cnt].cassette_add_qual[cass_cnt].slide_qual[slide_cnt].task_qual[
            task_cnt].task_type_flag != 0)
             AND upd_gross_ind=1)
             SET temp_specimens->qual[temp_specimen_cnt].gross_ind = 1
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  IF (upd_gross_ind=1)
   IF ((temp_specimens->qual[temp_specimen_cnt].gross_ind=1))
    SET nbr_spec_to_gross += 1
   ENDIF
  ENDIF
 ENDFOR
 IF (temp_cass_cnt > 0)
  INSERT  FROM cassette c,
    (dummyt d  WITH seq = value(temp_cass_cnt))
   SET c.cassette_id = temp_cassette->qual[d.seq].cassette_id, c.case_specimen_id = temp_cassette->
    qual[d.seq].case_specimen_id, c.cassette_tag_id = temp_cassette->qual[d.seq].cassette_tag_cd,
    c.task_assay_cd = temp_cassette->qual[d.seq].task_assay_cd, c.fixative_cd = temp_cassette->qual[d
    .seq].fixative_cd, c.origin_modifier = temp_cassette->qual[d.seq].origin_modifier,
    c.pieces = temp_cassette->qual[d.seq].pieces, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id =
    reqinfo->updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (c)
   WITH nocounter
  ;end insert
  IF (curqual != temp_cass_cnt)
   GO TO insert_cassette_failed
  ENDIF
 ENDIF
 IF (temp_slide_cnt > 0)
  INSERT  FROM slide s,
    (dummyt d  WITH seq = value(temp_slide_cnt))
   SET s.slide_id = temp_slide->qual[d.seq].slide_id, s.case_specimen_id = temp_slide->qual[d.seq].
    case_specimen_id, s.cassette_id = temp_slide->qual[d.seq].cassette_id,
    s.task_assay_cd = temp_slide->qual[d.seq].task_assay_cd, s.stain_task_assay_cd = temp_slide->
    qual[d.seq].stain_task_assay_cd, s.tag_id = temp_slide->qual[d.seq].tag_cd,
    s.origin_modifier = temp_slide->qual[d.seq].origin_modifier, s.updt_dt_tm = cnvtdatetime(sysdate),
    s.updt_id = reqinfo->updt_id,
    s.updt_task = reqinfo->updt_task, s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (s)
   WITH nocounter
  ;end insert
  IF (curqual != temp_slide_cnt)
   GO TO insert_slide_failed
  ENDIF
 ENDIF
 SET stat = initrec(req200456)
 SET stat = initrec(rep200456)
 IF (temp_proc_cnt > 0)
  SET stat = alter(reply->proc_qual,temp_proc_cnt)
  FOR (x = 1 TO temp_proc_cnt)
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      temp_processing->qual[x].processing_task_id = seq_nbr, reply->proc_qual[x].processing_task_id
       = seq_nbr
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO seq_failed
    ENDIF
    SET reply->proc_qual[x].case_specimen_id = temp_processing->qual[x].case_specimen_id
    SET reply->proc_qual[x].case_specimen_tag_cd = temp_processing->qual[x].case_specimen_tag_cd
    SET reply->proc_qual[x].cassette_id = temp_processing->qual[x].cassette_id
    SET reply->proc_qual[x].cassette_tag_cd = temp_processing->qual[x].cassette_tag_cd
    SET reply->proc_qual[x].create_inventory_flag = temp_processing->qual[x].create_inventory_flag
    SET reply->proc_qual[x].slide_id = temp_processing->qual[x].slide_id
    SET reply->proc_qual[x].slide_tag_cd = temp_processing->qual[x].slide_tag_cd
    SET reply->proc_qual[x].task_assay_cd = temp_processing->qual[x].task_assay_cd
    SET reply->proc_qual[x].stain_proc_task_id = temp_processing->qual[x].stain_proc_task_id
    IF (interface_flag > 0
     AND tracking_service_resource_cd > 0)
     IF ((temp_processing->qual[x].slide_id > 0.0))
      SET chg_cnt += 1
      SET stat = alterlist(req200456->qual2,chg_cnt)
      SET req200456->qual2[chg_cnt].processing_task_id = temp_processing->qual[x].processing_task_id
      SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
      IF ((temp_processing->qual[x].stain_proc_task_id > 0.0))
       SET chg_cnt += 1
       SET stat = alterlist(req200456->qual2,chg_cnt)
       SET req200456->qual2[chg_cnt].processing_task_id = temp_processing->qual[x].stain_proc_task_id
       SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  FOR (loop = 1 TO temp_proc_cnt)
    IF (textlen(trim(temp_processing->qual[loop].comment)) > 0
     AND (temp_processing->qual[loop].comments_long_text_id=0))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp_processing->qual[loop].comments_long_text_id = seq_nbr, temp_processing->qual[loop].
       comment_flag = 1, temp_processing->lnewcomment += 1
      WITH format, counter
     ;end select
    ENDIF
  ENDFOR
  IF (temp_proc_cnt > 0)
   INSERT  FROM long_text lt,
     (dummyt d  WITH seq = value(temp_proc_cnt))
    SET lt.long_text_id = temp_processing->qual[d.seq].comments_long_text_id, lt.long_text =
     temp_processing->qual[d.seq].comment, lt.parent_entity_id = temp_processing->qual[d.seq].
     processing_task_id,
     lt.parent_entity_name = "PROCESSING_TASK", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate
      ),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d
     WHERE (temp_processing->qual[d.seq].comment_flag=1))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF ((curqual != temp_processing->lnewcomment))
    GO TO insert_long_text_failed
   ENDIF
   SET temp_processing->lnewcomment = 0
  ENDIF
  INSERT  FROM processing_task pt,
    (dummyt d  WITH seq = value(temp_proc_cnt))
   SET pt.processing_task_id = temp_processing->qual[d.seq].processing_task_id, pt.case_id = request
    ->case_id, pt.case_specimen_id = temp_processing->qual[d.seq].case_specimen_id,
    pt.case_specimen_tag_id = temp_processing->qual[d.seq].case_specimen_tag_cd, pt.cassette_id =
    temp_processing->qual[d.seq].cassette_id, pt.cassette_tag_id = temp_processing->qual[d.seq].
    cassette_tag_cd,
    pt.slide_id = temp_processing->qual[d.seq].slide_id, pt.slide_tag_id = temp_processing->qual[d
    .seq].slide_tag_cd, pt.create_inventory_flag = temp_processing->qual[d.seq].create_inventory_flag,
    pt.task_assay_cd = temp_processing->qual[d.seq].task_assay_cd, pt.service_resource_cd =
    temp_processing->qual[d.seq].service_resource_cd, pt.priority_cd = temp_processing->qual[d.seq].
    priority_cd,
    pt.no_charge_ind = temp_processing->qual[d.seq].no_charge_ind, pt.research_account_id =
    temp_processing->qual[d.seq].research_account_id, pt.comments_long_text_id = temp_processing->
    qual[d.seq].comments_long_text_id,
    pt.request_dt_tm = cnvtdatetime(sysdate), pt.request_prsnl_id = reqinfo->updt_id, pt.status_cd =
    ordered_status_cd,
    pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm = cnvtdatetime(sysdate), pt.updt_dt_tm =
    cnvtdatetime(sysdate),
    pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->updt_task, pt.updt_cnt = 0,
    pt.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pt)
   WITH nocounter
  ;end insert
  IF (curqual != temp_proc_cnt)
   GO TO insert_processing_task_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(temp_proc_cnt))
   SET aoe.parent_id = temp_processing->qual[d.seq].processing_task_id, aoe.action_flag = 4, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (temp_processing->qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=4)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != temp_proc_cnt)
   GO TO insert_ops_exception_failed
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(temp_proc_cnt))
    SET aoed.action_flag = 4, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = temp_processing->qual[d.seq].processing_task_id, aoed.sequence = 1, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (temp_processing->qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=4)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != temp_proc_cnt)
    GO TO insert_ops_exception_detail_failed
   ENDIF
  ENDIF
  IF (temp_proc_cnt > 0)
   IF (interface_flag > 0
    AND tracking_service_resource_cd > 0)
    SET req200456->sending_instr_ind = 0
    EXECUTE aps_get_task_instr_protocols  WITH replace("REQUEST","REQ200456"), replace("REPLY",
     "REP200456")
    IF ((rep200456->status_data.status="F"))
     SET errmsg = "Execute failed."
     CALL errorhandler("EXECUTE","F","aps_get_task_instr_protocols",errmsg)
     SET failed = "T"
     GO TO interface_failed
    ENDIF
    IF (size(rep200456->qual,5) > 0)
     FOR (chg_cnt = 1 TO size(rep200456->qual,5))
       FOR (x = 1 TO temp_proc_cnt)
        IF ((rep200456->qual[chg_cnt].processing_task_id=reply->proc_qual[x].processing_task_id)
         AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
         SET reply->proc_qual[x].universal_service_ident = rep200456->qual[chg_cnt].
         universal_service_ident
         SET reply->proc_qual[x].placer_field_1 = rep200456->qual[chg_cnt].placer_field_1
         SET reply->proc_qual[x].suplmtl_serv_info_txt = rep200456->qual[chg_cnt].
         suplmtl_serv_info_txt
        ENDIF
        IF ((reply->proc_qual[x].stain_proc_task_id > 0)
         AND (rep200456->qual[chg_cnt].processing_task_id=reply->proc_qual[x].stain_proc_task_id)
         AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
         SET reply->proc_qual[x].stain_universal_service_ident = rep200456->qual[chg_cnt].
         universal_service_ident
         SET reply->proc_qual[x].stain_placer_field_1 = rep200456->qual[chg_cnt].placer_field_1
         SET reply->proc_qual[x].stain_suplmtl_serv_info_txt = rep200456->qual[chg_cnt].
         suplmtl_serv_info_txt
        ENDIF
       ENDFOR
     ENDFOR
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->output_dest_cd > 0.0))
  IF ( NOT (validate(req200408,0)))
   RECORD req200408(
     1 output_dest_cd = f8
     1 qual[*]
       2 processing_task_id = f8
     1 resend_ind = i2
   )
  ENDIF
  IF ( NOT (validate(rep200408,0)))
   RECORD rep200408(
     1 print_status_data
       2 print_directory = c19
       2 print_filename = c40
       2 print_dir_and_filename = c60
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  FOR (nitem = 1 TO temp_proc_cnt)
    IF ((temp_processing->qual[nitem].create_inventory_flag IN (1, 3)))
     SET label_cnt += 1
     SET stat = alterlist(req200408->qual,label_cnt)
     SET req200408->qual[label_cnt].processing_task_id = temp_processing->qual[nitem].
     processing_task_id
    ENDIF
  ENDFOR
 ENDIF
 IF (temp_specimen_cnt > 0)
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(temp_specimen_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_specimens->qual,padded_size)
  FOR (idx = (temp_specimen_cnt+ 1) TO padded_size)
   SET temp_specimens->qual[idx].case_specimen_id = temp_specimens->qual[temp_specimen_cnt].
   case_specimen_id
   SET temp_specimens->qual[idx].gross_ind = temp_specimens->qual[temp_specimen_cnt].gross_ind
  ENDFOR
  SELECT INTO "nl:"
   pt.case_specimen_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (pt
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),pt.case_specimen_id,
     temp_specimens->qual[idx].case_specimen_id)
     AND pt.create_inventory_flag=4)
   HEAD REPORT
    nbr_items = 0
   DETAIL
    lvindex = ((d.seq - 1) * batch_size)
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),minval((d.seq * batch_size),temp_specimen_cnt),
      pt.case_specimen_id,temp_specimens->qual[idx].case_specimen_id)) > 0)
      nbr_items += 1, temp_specimens->qual[lvindex].curr_order_id = pt.order_id, temp_specimens->
      qual[lvindex].curr_updt_cnt = pt.updt_cnt,
      temp_specimens->qual[lvindex].updt_applctx = pt.updt_applctx
    ENDWHILE
   WITH nocounter, forupdate(pt)
  ;end select
  IF (nbr_items != temp_specimen_cnt)
   GO TO lock_processing_task_failed
  ENDIF
  FOR (nbr_items = 1 TO temp_specimen_cnt)
    IF ((temp_specimens->qual[nbr_items].updt_cnt != temp_specimens->qual[nbr_items].curr_updt_cnt))
     IF ((((temp_specimens->qual[nbr_items].case_specimen_order_id=temp_specimens->qual[nbr_items].
     curr_order_id)) OR ((temp_specimens->qual[nbr_items].curr_order_id=0)))
      AND (reqinfo->updt_applctx != temp_specimens->qual[nbr_items].updt_applctx))
      GO TO lock_processing_task_failed
     ENDIF
    ENDIF
  ENDFOR
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(loop_cnt))
   SET pt.status_cd = processing_status_cd, pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm =
    cnvtdatetime(sysdate),
    pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->
    updt_task,
    pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),pt.case_specimen_id,
     temp_specimens->qual[idx].case_specimen_id,
     1,temp_specimens->qual[idx].gross_ind)
     AND pt.create_inventory_flag=4)
   WITH nocounter
  ;end update
  IF (curqual != nbr_spec_to_gross)
   GO TO update_processing_task_failed
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_specimen_cnt))
   PLAN (d
    WHERE (temp_specimens->qual[d.seq].gross_ind=1))
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),nbr_specimens,temp_specimens->qual[d.seq].
      case_specimen_id,request->spec_qual[idx].case_specimen_id)) > 0)
      request->spec_qual[lvindex].case_specimen_updt_cnt = (temp_specimens->qual[d.seq].curr_updt_cnt
      + 1)
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 FREE SET temp_specimens
 IF (nbr_specimens > 0)
  SET batch_size = determineexpandsize(nbr_specimens,40)
  SET loop_cnt = ceil((cnvtreal(nbr_specimens)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(request->spec_qual,padded_size)
  FOR (idx = (nbr_specimens+ 1) TO padded_size)
   SET request->spec_qual[idx].case_specimen_id = request->spec_qual[nbr_specimens].case_specimen_id
   SET request->spec_qual[idx].case_specimen_order_id = request->spec_qual[nbr_specimens].
   case_specimen_order_id
  ENDFOR
  SELECT INTO "nl:"
   FROM processing_task pt,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1)
    JOIN (pt
    WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),pt.case_specimen_id,
     request->spec_qual[idx].case_specimen_id,
     0.0,request->spec_qual[idx].case_specimen_order_id)
     AND pt.create_inventory_flag=4)
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),nbr_specimens,pt.case_specimen_id,request->
      spec_qual[idx].case_specimen_id,
      0.0,request->spec_qual[idx].case_specimen_order_id)) > 0)
      request->spec_qual[lvindex].case_specimen_updt_cnt = pt.updt_cnt
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(request->spec_qual,nbr_specimens)
 ENDIF
 SET temp_proc_cnt = 0
 SET temp_slide_cnt = 0
 SET temp_cass_cnt = 0
 SET stat = alterlist(temp_processing->qual,temp_proc_cnt)
 SET stat = alterlist(temp_slide->qual,temp_slide_cnt)
 SET stat = alterlist(temp_cassette->qual,temp_cass_cnt)
 SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 10))
 SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 10))
 SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 10))
 FOR (cnt = 1 TO nbr_specimens)
   IF ((request->spec_qual[cnt].chg_ind="Y"))
    SET nbr_s_t = cnvtint(size(request->spec_qual[cnt].task_chg_qual,5))
    IF (nbr_s_t > 0)
     FOR (task_cnt = 1 TO nbr_s_t)
       SET temp_proc_cnt += 1
       IF (mod(temp_proc_cnt,10)=1
        AND temp_proc_cnt != 1)
        SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
       ENDIF
       SET temp_processing->qual[temp_proc_cnt].processing_task_id = request->spec_qual[cnt].
       task_chg_qual[task_cnt].processing_task_id
       SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
       case_specimen_id
       SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
       SET temp_processing->qual[temp_proc_cnt].slide_id = 0
       SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
       case_specimen_tag_cd
       SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
       SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
       SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
       task_chg_qual[task_cnt].create_inventory_flag
       SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
       task_chg_qual[task_cnt].task_assay_cd
       SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
       task_chg_qual[task_cnt].service_resource_cd
       SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].task_chg_qual[
       task_cnt].priority_cd
       SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].task_chg_qual[
       task_cnt].comment
       SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
       task_chg_qual[task_cnt].comments_long_text_id
       SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].task_chg_qual[
       task_cnt].lt_updt_cnt
       SET temp_processing->qual[temp_proc_cnt].order_id = request->spec_qual[cnt].task_chg_qual[
       task_cnt].order_id
       SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].task_chg_qual[
       task_cnt].catalog_cd
       SET temp_processing->qual[temp_proc_cnt].updt_cnt = request->spec_qual[cnt].task_chg_qual[
       task_cnt].updt_cnt
       SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
       SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
       task_chg_qual[task_cnt].no_charge_ind
       SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
       task_chg_qual[task_cnt].research_account_id
     ENDFOR
    ENDIF
    SET nbr_s_s = cnvtint(size(request->spec_qual[cnt].slide_chg_qual,5))
    IF (nbr_s_s > 0)
     FOR (slide_cnt = 1 TO nbr_s_s)
       SET temp_slide_cnt += 1
       IF (mod(temp_slide_cnt,10)=1
        AND temp_slide_cnt != 1)
        SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 9))
       ENDIF
       SET cur_slide_id = request->spec_qual[cnt].slide_chg_qual[slide_cnt].slide_id
       SET temp_slide->qual[temp_slide_cnt].slide_id = cur_slide_id
       SET temp_slide->qual[temp_slide_cnt].case_specimen_id = request->spec_qual[cnt].
       case_specimen_id
       SET temp_slide->qual[temp_slide_cnt].cassette_id = 0
       SET temp_slide->qual[temp_slide_cnt].task_assay_cd = request->spec_qual[cnt].slide_chg_qual[
       slide_cnt].task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = request->spec_qual[cnt].
       slide_chg_qual[slide_cnt].stain_task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].tag_cd = request->spec_qual[cnt].slide_chg_qual[slide_cnt
       ].tag_cd
       SET temp_slide->qual[temp_slide_cnt].origin_modifier = request->spec_qual[cnt].slide_chg_qual[
       slide_cnt].origin_modifier
       SET temp_slide->qual[temp_slide_cnt].updt_cnt = request->spec_qual[cnt].slide_chg_qual[
       slide_cnt].updt_cnt
       SET nbr_s_s_t = cnvtint(size(request->spec_qual[cnt].slide_chg_qual[slide_cnt].task_qual,5))
       IF (nbr_s_s_t > 0)
        FOR (task_cnt = 1 TO nbr_s_s_t)
          SET temp_proc_cnt += 1
          IF (mod(temp_proc_cnt,10)=1
           AND temp_proc_cnt != 1)
           SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
          ENDIF
          SET temp_processing->qual[temp_proc_cnt].processing_task_id = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].processing_task_id
          SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
          case_specimen_id
          SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
          SET temp_processing->qual[temp_proc_cnt].slide_id = cur_slide_id
          SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
          case_specimen_tag_cd
          SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
          SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].tag_cd
          SET temp_processing->qual[temp_proc_cnt].stain_proc_task_id = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].stain_proc_task_id
          SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].create_inventory_flag
          SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].task_assay_cd
          SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].service_resource_cd
          SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].priority_cd
          SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].slide_chg_qual[
          slide_cnt].task_qual[task_cnt].comment
          SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].comments_long_text_id
          SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].lt_updt_cnt
          SET temp_processing->qual[temp_proc_cnt].order_id = request->spec_qual[cnt].slide_chg_qual[
          slide_cnt].task_qual[task_cnt].order_id
          SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].catalog_cd
          SET temp_processing->qual[temp_proc_cnt].updt_cnt = request->spec_qual[cnt].slide_chg_qual[
          slide_cnt].task_qual[task_cnt].updt_cnt
          SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
          SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].no_charge_ind
          SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
          slide_chg_qual[slide_cnt].task_qual[task_cnt].research_account_id
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    SET nbr_s_c = cnvtint(size(request->spec_qual[cnt].cassette_chg_qual,5))
    IF (nbr_s_c > 0)
     FOR (cass_cnt = 1 TO nbr_s_c)
       SET temp_cass_cnt += 1
       IF (mod(temp_cass_cnt,10)=1
        AND temp_cass_cnt != 1)
        SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 9))
       ENDIF
       SET cur_cass_id = request->spec_qual[cnt].cassette_chg_qual[cass_cnt].cassette_id
       SET temp_cassette->qual[temp_cass_cnt].cassette_id = cur_cass_id
       SET temp_cassette->qual[temp_cass_cnt].case_specimen_id = request->spec_qual[cnt].
       case_specimen_id
       SET temp_cassette->qual[temp_cass_cnt].cassette_tag_cd = request->spec_qual[cnt].
       cassette_chg_qual[cass_cnt].cassette_tag_cd
       SET temp_cassette->qual[temp_cass_cnt].fixative_cd = request->spec_qual[cnt].
       cassette_chg_qual[cass_cnt].fixative_cd
       SET temp_cassette->qual[temp_cass_cnt].task_assay_cd = request->spec_qual[cnt].
       cassette_chg_qual[cass_cnt].task_assay_cd
       SET temp_cassette->qual[temp_cass_cnt].origin_modifier = request->spec_qual[cnt].
       cassette_chg_qual[cass_cnt].origin_modifier
       SET temp_cassette->qual[temp_cass_cnt].pieces = request->spec_qual[cnt].cassette_chg_qual[
       cass_cnt].pieces
       SET temp_cassette->qual[temp_cass_cnt].updt_cnt = request->spec_qual[cnt].cassette_chg_qual[
       cass_cnt].updt_cnt
       SET nbr_s_c_t = cnvtint(size(request->spec_qual[cnt].cassette_chg_qual[cass_cnt].task_qual,5))
       IF (nbr_s_c_t > 0)
        FOR (task_cnt = 1 TO nbr_s_c_t)
          SET temp_proc_cnt += 1
          IF (mod(temp_proc_cnt,10)=1
           AND temp_proc_cnt != 1)
           SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
          ENDIF
          SET temp_processing->qual[temp_proc_cnt].processing_task_id = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].processing_task_id
          SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
          case_specimen_id
          SET temp_processing->qual[temp_proc_cnt].cassette_id = cur_cass_id
          SET temp_processing->qual[temp_proc_cnt].slide_id = 0
          SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
          case_specimen_tag_cd
          SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].cassette_tag_cd
          SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
          SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].create_inventory_flag
          SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].task_assay_cd
          SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].service_resource_cd
          SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].priority_cd
          SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].comment
          SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].comments_long_text_id
          SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].lt_updt_cnt
          SET temp_processing->qual[temp_proc_cnt].order_id = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].order_id
          SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].catalog_cd
          SET temp_processing->qual[temp_proc_cnt].updt_cnt = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].updt_cnt
          SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
          SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].no_charge_ind
          SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].task_qual[task_cnt].research_account_id
        ENDFOR
       ENDIF
       SET nbr_s_c_s = cnvtint(size(request->spec_qual[cnt].cassette_chg_qual[cass_cnt].slide_qual,5)
        )
       IF (nbr_s_c_s > 0)
        FOR (slide_cnt = 1 TO nbr_s_c_s)
          SET temp_slide_cnt += 1
          IF (mod(temp_slide_cnt,10)=1
           AND temp_slide_cnt != 1)
           SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 9))
          ENDIF
          SET cur_slide_id = request->spec_qual[cnt].cassette_chg_qual[cass_cnt].slide_qual[slide_cnt
          ].slide_id
          SET temp_slide->qual[temp_slide_cnt].slide_id = cur_slide_id
          SET temp_slide->qual[temp_slide_cnt].case_specimen_id = 0
          SET temp_slide->qual[temp_slide_cnt].cassette_id = cur_cass_id
          SET temp_slide->qual[temp_slide_cnt].task_assay_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_assay_cd
          SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].stain_task_assay_cd
          SET temp_slide->qual[temp_slide_cnt].tag_cd = request->spec_qual[cnt].cassette_chg_qual[
          cass_cnt].slide_qual[slide_cnt].tag_cd
          SET temp_slide->qual[temp_slide_cnt].origin_modifier = request->spec_qual[cnt].
          cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].origin_modifier
          SET temp_slide->qual[temp_slide_cnt].updt_cnt = request->spec_qual[cnt].cassette_chg_qual[
          cass_cnt].slide_qual[slide_cnt].updt_cnt
          SET nbr_s_c_s_t = cnvtint(size(request->spec_qual[cnt].cassette_chg_qual[cass_cnt].
            slide_qual[slide_cnt].task_qual,5))
          IF (nbr_s_c_s_t > 0)
           FOR (task_cnt = 1 TO nbr_s_c_s_t)
             SET temp_proc_cnt += 1
             IF (mod(temp_proc_cnt,10)=1
              AND temp_proc_cnt != 1)
              SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
             ENDIF
             SET temp_processing->qual[temp_proc_cnt].processing_task_id = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].processing_task_id
             SET temp_processing->qual[temp_proc_cnt].case_specimen_id = request->spec_qual[cnt].
             case_specimen_id
             SET temp_processing->qual[temp_proc_cnt].cassette_id = cur_cass_id
             SET temp_processing->qual[temp_proc_cnt].slide_id = cur_slide_id
             SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = request->spec_qual[cnt].
             case_specimen_tag_cd
             SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].cassette_tag_cd
             SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].tag_cd
             SET temp_processing->qual[temp_proc_cnt].stain_proc_task_id = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].stain_proc_task_id
             SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = request->spec_qual[cnt]
             .cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
             create_inventory_flag
             SET temp_processing->qual[temp_proc_cnt].task_assay_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].task_assay_cd
             SET temp_processing->qual[temp_proc_cnt].service_resource_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
             service_resource_cd
             SET temp_processing->qual[temp_proc_cnt].priority_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].priority_cd
             SET temp_processing->qual[temp_proc_cnt].comment = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].comment
             SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt]
             .cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
             comments_long_text_id
             SET temp_processing->qual[temp_proc_cnt].lt_updt_cnt = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].lt_updt_cnt
             SET temp_processing->qual[temp_proc_cnt].order_id = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].order_id
             SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].catalog_cd
             SET temp_processing->qual[temp_proc_cnt].updt_cnt = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].updt_cnt
             SET temp_processing->qual[temp_proc_cnt].comment_flag = 0
             SET temp_processing->qual[temp_proc_cnt].no_charge_ind = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].no_charge_ind
             SET temp_processing->qual[temp_proc_cnt].research_account_id = request->spec_qual[cnt].
             cassette_chg_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].
             research_account_id
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF (temp_proc_cnt > 0)
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(temp_proc_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_processing->qual,padded_size)
  FOR (idx = (temp_proc_cnt+ 1) TO padded_size)
    SET temp_processing->qual[idx].processing_task_id = temp_processing->qual[temp_proc_cnt].
    processing_task_id
  ENDFOR
  SELECT INTO "nl:"
   pt.processing_task_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (pt
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),pt.processing_task_id,
     temp_processing->qual[idx].processing_task_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    lvindex = ((d.seq - 1) * batch_size)
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),minval((d.seq * batch_size),temp_proc_cnt),pt
      .processing_task_id,temp_processing->qual[idx].processing_task_id)) > 0)
      nbr_items += 1, temp_processing->qual[lvindex].curr_updt_cnt = pt.updt_cnt, temp_processing->
      qual[lvindex].curr_order_id = pt.order_id,
      temp_processing->qual[lvindex].updt_applctx = pt.updt_applctx
    ENDWHILE
   WITH nocounter, forupdate(pt)
  ;end select
  SET stat = alterlist(temp_processing->qual,temp_proc_cnt)
  IF (nbr_items != temp_proc_cnt)
   GO TO lock_processing_task_failed
  ENDIF
  FOR (nbr_items = 1 TO temp_proc_cnt)
    IF ((temp_processing->qual[nbr_items].updt_cnt != temp_processing->qual[nbr_items].curr_updt_cnt)
    )
     IF ((((temp_processing->qual[nbr_items].order_id=temp_processing->qual[nbr_items].curr_order_id)
     ) OR ((temp_processing->qual[nbr_items].curr_order_id=0)))
      AND (reqinfo->updt_applctx != temp_processing->qual[nbr_items].updt_applctx))
      GO TO lock_processing_task_failed
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (temp_slide_cnt > 0)
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(temp_slide_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_slide->qual,padded_size)
  FOR (idx = (temp_slide_cnt+ 1) TO padded_size)
    SET temp_slide->qual[idx].slide_id = temp_slide->qual[temp_slide_cnt].slide_id
  ENDFOR
  SELECT INTO "nl:"
   s.slide_id
   FROM slide s,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (s
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),s.slide_id,temp_slide->
     qual[idx].slide_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    lvindex = ((d.seq - 1) * batch_size)
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),minval((d.seq * batch_size),temp_slide_cnt),s
      .slide_id,temp_slide->qual[idx].slide_id)) > 0)
     nbr_items += 1,temp_slide->qual[lvindex].curr_updt_cnt = s.updt_cnt
    ENDWHILE
   WITH nocounter, forupdate(s)
  ;end select
  SET stat = alterlist(temp_slide->qual,temp_slide_cnt)
  IF (nbr_items != temp_slide_cnt)
   GO TO lock_slide_failed
  ENDIF
  FOR (nbr_items = 1 TO temp_slide_cnt)
    IF ((temp_slide->qual[nbr_items].updt_cnt != temp_slide->qual[nbr_items].curr_updt_cnt))
     GO TO lock_slide_failed2
    ENDIF
  ENDFOR
 ENDIF
 IF (temp_cass_cnt > 0)
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(temp_cass_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_cassette->qual,padded_size)
  FOR (idx = (temp_cass_cnt+ 1) TO padded_size)
    SET temp_cassette->qual[idx].cassette_id = temp_cassette->qual[temp_cass_cnt].cassette_id
  ENDFOR
  SELECT INTO "nl:"
   c.cassette_id
   FROM cassette c,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (c
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),c.cassette_id,temp_cassette
     ->qual[idx].cassette_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    lvindex = ((d.seq - 1) * batch_size)
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),minval((d.seq * batch_size),temp_cass_cnt),c
      .cassette_id,temp_cassette->qual[idx].cassette_id)) > 0)
     nbr_items += 1,temp_cassette->qual[lvindex].curr_updt_cnt = c.updt_cnt
    ENDWHILE
   WITH nocounter, forupdate(c)
  ;end select
  SET stat = alterlist(temp_cassette->qual,temp_cass_cnt)
  IF (nbr_items != temp_cass_cnt)
   GO TO lock_cassette_failed
  ENDIF
  FOR (nbr_items = 1 TO temp_cass_cnt)
    IF ((temp_cassette->qual[nbr_items].updt_cnt != temp_cassette->qual[nbr_items].curr_updt_cnt))
     GO TO lock_cassette_failed
    ENDIF
  ENDFOR
 ENDIF
 IF (temp_cass_cnt > 0)
  UPDATE  FROM cassette c,
    (dummyt d  WITH seq = value(temp_cass_cnt))
   SET c.fixative_cd = temp_cassette->qual[d.seq].fixative_cd, c.origin_modifier = temp_cassette->
    qual[d.seq].origin_modifier, c.pieces = temp_cassette->qual[d.seq].pieces,
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
    updt_task,
    c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1)
   PLAN (d)
    JOIN (c
    WHERE (c.cassette_id=temp_cassette->qual[d.seq].cassette_id))
   WITH nocounter
  ;end update
  IF (curqual != temp_cass_cnt)
   GO TO update_cassette_failed
  ENDIF
 ENDIF
 IF (temp_slide_cnt > 0)
  UPDATE  FROM slide s,
    (dummyt d  WITH seq = value(temp_slide_cnt))
   SET s.stain_task_assay_cd = temp_slide->qual[d.seq].stain_task_assay_cd, s.origin_modifier =
    temp_slide->qual[d.seq].origin_modifier, s.updt_dt_tm = cnvtdatetime(sysdate),
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx,
    s.updt_cnt = (s.updt_cnt+ 1)
   PLAN (d)
    JOIN (s
    WHERE (s.slide_id=temp_slide->qual[d.seq].slide_id))
   WITH nocounter
  ;end update
  IF (curqual != temp_slide_cnt)
   GO TO update_slide_failed
  ENDIF
 ENDIF
 IF (temp_proc_cnt > 0)
  FOR (loop = 1 TO temp_proc_cnt)
    IF (textlen(trim(temp_processing->qual[loop].comment)) > 0
     AND (temp_processing->qual[loop].comments_long_text_id=0))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp_processing->qual[loop].comments_long_text_id = seq_nbr, temp_processing->qual[loop].
       comment_flag = 1, temp_processing->lnewcomment += 1
      WITH format, counter
     ;end select
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_proc_cnt))
   DETAIL
    IF ((temp_processing->qual[d.seq].comments_long_text_id > 0)
     AND textlen(trim(temp_processing->qual[d.seq].comment))=0)
     temp_processing->qual[d.seq].comment_flag = 2, temp_processing->lremovedcomment += 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_proc_cnt))
   DETAIL
    IF ((temp_processing->qual[d.seq].comments_long_text_id > 0)
     AND (temp_processing->qual[d.seq].comment_flag=0))
     temp_processing->lupdatedcomment += 1
    ENDIF
   WITH nocounter
  ;end select
  IF ((temp_processing->lnewcomment > 0))
   INSERT  FROM long_text lt,
     (dummyt d  WITH seq = value(temp_proc_cnt))
    SET lt.long_text_id = temp_processing->qual[d.seq].comments_long_text_id, lt.long_text =
     temp_processing->qual[d.seq].comment, lt.parent_entity_id = temp_processing->qual[d.seq].
     processing_task_id,
     lt.parent_entity_name = "PROCESSING_TASK", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate
      ),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d
     WHERE (temp_processing->qual[d.seq].comment_flag=1))
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF ((curqual != temp_processing->lnewcomment))
    GO TO insert_long_text_failed
   ENDIF
   SET temp_processing->lnewcomment = 0
  ENDIF
  IF ((temp_processing->lupdatedcomment > 0))
   SET batch_size = determineexpandsize(temp_proc_cnt,40)
   SET loop_cnt = ceil((cnvtreal(temp_proc_cnt)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_processing->qual,padded_size)
   FOR (idx = (temp_proc_cnt+ 1) TO padded_size)
     SET temp_processing->qual[idx].comments_long_text_id = temp_processing->qual[temp_proc_cnt].
     comments_long_text_id
     SET temp_processing->qual[idx].lt_updt_cnt = temp_processing->qual[temp_proc_cnt].lt_updt_cnt
     SET temp_processing->qual[idx].comment_flag = temp_processing->qual[temp_proc_cnt].comment_flag
   ENDFOR
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d)
     JOIN (lt
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),lt.long_text_id,
      temp_processing->qual[idx].comments_long_text_id,
      lt.updt_cnt,temp_processing->qual[idx].lt_updt_cnt,0,temp_processing->qual[idx].comment_flag)
      AND lt.long_text_id > 0)
    HEAD REPORT
     nbr_items = 0
    DETAIL
     nbr_items += 1
    WITH nocounter, forupdate(lt)
   ;end select
   SET stat = alterlist(temp_processing->qual,temp_proc_cnt)
   IF ((nbr_items != temp_processing->lupdatedcomment))
    GO TO lock_long_text_failed
   ENDIF
   UPDATE  FROM long_text lt,
     (dummyt d  WITH seq = value(temp_proc_cnt))
    SET lt.long_text = trim(temp_processing->qual[d.seq].comment), lt.updt_dt_tm = cnvtdatetime(
      sysdate), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
     .updt_cnt+ 1)
    PLAN (d
     WHERE (temp_processing->qual[d.seq].comments_long_text_id > 0)
      AND (temp_processing->qual[d.seq].comment_flag=0))
     JOIN (lt
     WHERE (lt.long_text_id=temp_processing->qual[d.seq].comments_long_text_id)
      AND (lt.updt_cnt=temp_processing->qual[d.seq].lt_updt_cnt))
    WITH nocounter
   ;end update
   IF ((curqual != temp_processing->lupdatedcomment))
    GO TO update_long_text_failed
   ENDIF
   SET temp_processing->lupdatedcomment = 0
  ENDIF
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(temp_proc_cnt))
   SET pt.service_resource_cd =
    IF ((((temp_processing->qual[d.seq].order_id != 0)) OR ((temp_processing->qual[d.seq].
    service_resource_cd != 0))) ) temp_processing->qual[d.seq].service_resource_cd
    ELSE pt.service_resource_cd
    ENDIF
    , pt.priority_cd = temp_processing->qual[d.seq].priority_cd, pt.no_charge_ind = temp_processing->
    qual[d.seq].no_charge_ind,
    pt.research_account_id = temp_processing->qual[d.seq].research_account_id, pt
    .comments_long_text_id =
    IF ((temp_processing->qual[d.seq].comment_flag=2)) 0
    ELSE temp_processing->qual[d.seq].comments_long_text_id
    ENDIF
    , pt.updt_dt_tm = cnvtdatetime(sysdate),
    pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->
    updt_applctx,
    pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=temp_processing->qual[d.seq].processing_task_id))
   WITH nocounter
  ;end update
  IF (curqual != temp_proc_cnt)
   GO TO update_processing_task_failed
  ENDIF
  IF (interface_flag > 0
   AND tracking_service_resource_cd > 0)
   SET stat = alterlist(reply->proc_chg_qual,temp_proc_cnt)
   SET stat = initrec(req200456)
   SET stat = initrec(rep200456)
   FOR (x = 1 TO temp_proc_cnt)
     SET reply->proc_chg_qual[x].processing_task_id = temp_processing->qual[x].processing_task_id
     SET reply->proc_chg_qual[x].case_specimen_id = temp_processing->qual[x].case_specimen_id
     SET reply->proc_chg_qual[x].case_specimen_tag_cd = temp_processing->qual[x].case_specimen_tag_cd
     SET reply->proc_chg_qual[x].cassette_id = temp_processing->qual[x].cassette_id
     SET reply->proc_chg_qual[x].cassette_tag_cd = temp_processing->qual[x].cassette_tag_cd
     SET reply->proc_chg_qual[x].create_inventory_flag = temp_processing->qual[x].
     create_inventory_flag
     SET reply->proc_chg_qual[x].slide_id = temp_processing->qual[x].slide_id
     SET reply->proc_chg_qual[x].slide_tag_cd = temp_processing->qual[x].slide_tag_cd
     SET reply->proc_chg_qual[x].task_assay_cd = temp_processing->qual[x].task_assay_cd
     SET reply->proc_chg_qual[x].stain_proc_task_id = temp_processing->qual[x].stain_proc_task_id
     IF ((temp_processing->qual[x].slide_id > 0.0))
      SET chg_cnt += 1
      SET stat = alterlist(req200456->qual2,chg_cnt)
      SET req200456->qual2[chg_cnt].processing_task_id = temp_processing->qual[x].processing_task_id
      SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
      IF ((temp_processing->qual[x].stain_proc_task_id > 0.0))
       SET chg_cnt += 1
       SET stat = alterlist(req200456->qual2,chg_cnt)
       SET req200456->qual2[chg_cnt].processing_task_id = temp_processing->qual[x].stain_proc_task_id
       SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
      ENDIF
     ENDIF
   ENDFOR
   SET req200456->sending_instr_ind = 0
   EXECUTE aps_get_task_instr_protocols  WITH replace("REQUEST","REQ200456"), replace("REPLY",
    "REP200456")
   IF ((rep200456->status_data.status="F"))
    SET errmsg = "Execute failed."
    CALL errorhandler("EXECUTE","F","aps_get_task_instr_protocols",errmsg)
    SET failed = "T"
    GO TO interface_failed
   ENDIF
   IF (size(rep200456->qual,5) > 0)
    FOR (chg_cnt = 1 TO size(rep200456->qual,5))
      FOR (x = 1 TO temp_proc_cnt)
       IF ((rep200456->qual[chg_cnt].processing_task_id=reply->proc_chg_qual[x].processing_task_id)
        AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
        SET reply->proc_chg_qual[x].universal_service_ident = rep200456->qual[chg_cnt].
        universal_service_ident
        SET reply->proc_chg_qual[x].placer_field_1 = rep200456->qual[chg_cnt].placer_field_1
        SET reply->proc_chg_qual[x].suplmtl_serv_info_txt = rep200456->qual[chg_cnt].
        suplmtl_serv_info_txt
       ENDIF
       IF ((reply->proc_chg_qual[x].stain_proc_task_id > 0)
        AND (rep200456->qual[chg_cnt].processing_task_id=reply->proc_chg_qual[x].stain_proc_task_id)
        AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
        SET reply->proc_chg_qual[x].stain_universal_service_ident = rep200456->qual[chg_cnt].
        universal_service_ident
        SET reply->proc_chg_qual[x].stain_placer_field_1 = rep200456->qual[chg_cnt].placer_field_1
        SET reply->proc_chg_qual[x].stain_suplmtl_serv_info_txt = rep200456->qual[chg_cnt].
        suplmtl_serv_info_txt
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
  ENDIF
  CALL deletelongtextrows(0)
 ENDIF
 SET temp_proc_cnt = 0
 SET temp_slide_cnt = 0
 SET temp_cass_cnt = 0
 SET stat = alterlist(temp_processing->qual,temp_proc_cnt)
 SET stat = alterlist(temp_slide->qual,temp_slide_cnt)
 SET stat = alterlist(temp_cassette->qual,temp_cass_cnt)
 SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 10))
 SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 10))
 SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 10))
 FOR (cnt = 1 TO nbr_specimens)
   IF ((request->spec_qual[cnt].del_ind="Y"))
    SET nbr_items = cnvtint(size(request->spec_qual[cnt].task_del_qual,5))
    IF (nbr_items > 0)
     FOR (task_cnt = 1 TO nbr_items)
       SET temp_proc_cnt += 1
       IF (mod(temp_proc_cnt,10)=1
        AND temp_proc_cnt != 1)
        SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 9))
       ENDIF
       SET temp_processing->qual[temp_proc_cnt].processing_task_id = request->spec_qual[cnt].
       task_del_qual[task_cnt].processing_task_id
       SET temp_processing->qual[temp_proc_cnt].updt_cnt = request->spec_qual[cnt].task_del_qual[
       task_cnt].updt_cnt
       SET temp_processing->qual[temp_proc_cnt].cancel_cd = request->spec_qual[cnt].task_del_qual[
       task_cnt].cancel_cd
       SET temp_processing->qual[temp_proc_cnt].order_id = request->spec_qual[cnt].task_del_qual[
       task_cnt].order_id
       SET temp_processing->qual[temp_proc_cnt].catalog_cd = request->spec_qual[cnt].task_del_qual[
       task_cnt].catalog_cd
       IF ((request->spec_qual[cnt].task_del_qual[task_cnt].comments_long_text_id > 0))
        SET temp_processing->lremovedcomment += 1
        SET temp_processing->qual[temp_proc_cnt].comment_flag = 2
        SET temp_processing->qual[temp_proc_cnt].comments_long_text_id = request->spec_qual[cnt].
        task_del_qual[task_cnt].comments_long_text_id
       ENDIF
     ENDFOR
    ENDIF
    SET nbr_items = cnvtint(size(request->spec_qual[cnt].slide_del_qual,5))
    IF (nbr_items > 0)
     FOR (slide_cnt = 1 TO nbr_items)
       SET temp_slide_cnt += 1
       IF (mod(temp_slide_cnt,10)=1
        AND temp_slide_cnt != 1)
        SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 9))
       ENDIF
       SET temp_slide->qual[temp_slide_cnt].slide_id = request->spec_qual[cnt].slide_del_qual[
       slide_cnt].slide_id
       SET invnty_cnt += 1
       SET stat = alterlist(inventory->list,invnty_cnt)
       SET inventory->list[invnty_cnt].content_table_name = "SLIDE"
       SET inventory->list[invnty_cnt].content_table_id = temp_slide->qual[temp_slide_cnt].slide_id
     ENDFOR
    ENDIF
    SET nbr_items = cnvtint(size(request->spec_qual[cnt].cassette_del_qual,5))
    IF (nbr_items > 0)
     FOR (cass_cnt = 1 TO nbr_items)
       SET temp_cass_cnt += 1
       IF (mod(temp_cass_cnt,10)=1
        AND temp_cass_cnt != 1)
        SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 9))
       ENDIF
       SET temp_cassette->qual[temp_cass_cnt].cassette_id = request->spec_qual[cnt].
       cassette_del_qual[cass_cnt].cassette_id
       SET invnty_cnt += 1
       SET stat = alterlist(inventory->list,invnty_cnt)
       SET inventory->list[invnty_cnt].content_table_name = "CASSETTE"
       SET inventory->list[invnty_cnt].content_table_id = temp_cassette->qual[temp_cass_cnt].
       cassette_id
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET inventory->del_qual_cnt = invnty_cnt
 IF ((inventory->del_qual_cnt > 0))
  EXECUTE scs_del_storage_content  WITH replace("REQUEST","INVENTORY"), replace("REPLY","REPLY")
  IF ((reply->status_data.status="F"))
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD inventory
 SET reply->status_data.status = "F"
 IF (temp_proc_cnt > 0)
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(temp_proc_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_processing->qual,padded_size)
  FOR (idx = (temp_proc_cnt+ 1) TO padded_size)
    SET temp_processing->qual[idx].processing_task_id = temp_processing->qual[temp_proc_cnt].
    processing_task_id
  ENDFOR
  SELECT INTO "nl:"
   pt.processing_task_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (pt
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),pt.processing_task_id,
     temp_processing->qual[idx].processing_task_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    lvindex = ((d.seq - 1) * batch_size)
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),minval((d.seq * batch_size),temp_proc_cnt),pt
      .processing_task_id,temp_processing->qual[idx].processing_task_id)) > 0)
      nbr_items += 1, temp_processing->qual[lvindex].curr_updt_cnt = pt.updt_cnt, temp_processing->
      qual[lvindex].curr_order_id = pt.order_id,
      temp_processing->qual[lvindex].updt_applctx = pt.updt_applctx
    ENDWHILE
   WITH nocounter, forupdate(pt)
  ;end select
  SET stat = alterlist(temp_processing->qual,temp_proc_cnt)
  IF (nbr_items != temp_proc_cnt)
   GO TO lock_processing_task_failed
  ENDIF
  FOR (nbr_items = 1 TO temp_proc_cnt)
    IF ((temp_processing->qual[nbr_items].updt_cnt != temp_processing->qual[nbr_items].curr_updt_cnt)
    )
     IF ((((temp_processing->qual[nbr_items].order_id=temp_processing->qual[nbr_items].curr_order_id)
     ) OR ((temp_processing->qual[nbr_items].curr_order_id=0)))
      AND (reqinfo->updt_applctx != temp_processing->qual[nbr_items].updt_applctx))
      GO TO lock_processing_task_failed
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (temp_proc_cnt > 0)
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(temp_proc_cnt))
   SET pt.cassette_id = 0, pt.slide_id = 0, pt.status_cd = cancelled_status_cd,
    pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm = cnvtdatetime(sysdate), pt.cancel_cd =
    temp_processing->qual[d.seq].cancel_cd,
    pt.cancel_prsnl_id = reqinfo->updt_id, pt.cancel_dt_tm = cnvtdatetime(sysdate), pt
    .comments_long_text_id = 0,
    pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->
    updt_task,
    pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=temp_processing->qual[d.seq].processing_task_id))
   WITH nocounter
  ;end update
  IF (curqual != temp_proc_cnt)
   GO TO update_processing_task_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(temp_proc_cnt))
   SET aoe.parent_id = temp_processing->qual[d.seq].processing_task_id, aoe.action_flag = 7, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (temp_processing->qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=7)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != temp_proc_cnt)
   GO TO insert_ops_exception_failed
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(temp_proc_cnt))
    SET aoed.action_flag = 7, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = temp_processing->qual[d.seq].processing_task_id, aoed.sequence = 1, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (temp_processing->qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=7)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != temp_proc_cnt)
    GO TO insert_ops_exception_detail_failed
   ENDIF
  ENDIF
  CALL deletelongtextrows(0)
 ENDIF
 IF (temp_slide_cnt > 0)
  SELECT INTO "nl:"
   ads.ap_digital_slide_id
   FROM ap_digital_slide ads,
    (dummyt d  WITH seq = value(temp_slide_cnt))
   PLAN (d)
    JOIN (ads
    WHERE (ads.slide_id=temp_slide->qual[d.seq].slide_id)
     AND  NOT (ads.slide_id IN (0, null)))
   HEAD REPORT
    stat = alterlist(temp_digital_slide->qual,10), cnt = 0
   DETAIL
    cnt += 1
    IF (cnt > size(temp_digital_slide->qual,5))
     stat = alterlist(temp_digital_slide->qual,(cnt+ 9))
    ENDIF
    temp_digital_slide->qual[cnt].digital_slide_id = ads.ap_digital_slide_id
   FOOT REPORT
    stat = alterlist(temp_digital_slide->qual,cnt)
   WITH nocounter
  ;end select
  IF (size(temp_digital_slide->qual,5) > 0)
   DELETE  FROM ap_digital_slide_info adsi,
     (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
    SET adsi.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
    PLAN (d)
     JOIN (adsi
     WHERE (adsi.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
    WITH nocounter
   ;end delete
   DELETE  FROM ap_digital_slide ads,
     (dummyt d  WITH seq = size(temp_digital_slide->qual,5))
    SET ads.ap_digital_slide_id = temp_digital_slide->qual[d.seq].digital_slide_id
    PLAN (d)
     JOIN (ads
     WHERE (ads.ap_digital_slide_id=temp_digital_slide->qual[d.seq].digital_slide_id))
    WITH nocounter
   ;end delete
  ENDIF
  DELETE  FROM slide s,
    (dummyt d  WITH seq = value(temp_slide_cnt))
   SET s.slide_id = temp_slide->qual[d.seq].slide_id
   PLAN (d)
    JOIN (s
    WHERE (s.slide_id=temp_slide->qual[d.seq].slide_id)
     AND  NOT (s.slide_id IN (0, null)))
   WITH nocounter
  ;end delete
  IF (curqual != temp_slide_cnt)
   GO TO delete_slide_failed
  ENDIF
 ENDIF
 IF (temp_cass_cnt > 0)
  DELETE  FROM cassette c,
    (dummyt d  WITH seq = value(temp_cass_cnt))
   SET c.cassette_id = temp_cassette->qual[d.seq].cassette_id
   PLAN (d)
    JOIN (c
    WHERE (c.cassette_id=temp_cassette->qual[d.seq].cassette_id)
     AND  NOT (c.cassette_id IN (0, null)))
   WITH nocounter
  ;end delete
  IF (curqual != temp_cass_cnt)
   GO TO delete_cassette_failed
  ENDIF
 ENDIF
 IF (num_of_removed_comments > 0)
  SET temp_index_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbr_specimens))
   WHERE (request->spec_qual[d.seq].case_comment_long_text_id > 0)
    AND textlen(trim(request->spec_qual[d.seq].case_comment))=0
    AND (request->spec_qual[d.seq].case_comment_new != "Y")
   HEAD REPORT
    stat = alterlist(temp_index->qual,nbr_specimens)
   DETAIL
    temp_index_cnt += 1, temp_index->qual[temp_index_cnt].id = d.seq
   FOOT REPORT
    stat = alterlist(temp_index->qual,temp_index_cnt)
   WITH nocounter
  ;end select
  IF (temp_index_cnt > 0)
   SET batch_size = determineexpandsize(temp_index_cnt,40)
   SET loop_cnt = ceil((cnvtreal(temp_index_cnt)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_index->qual,padded_size)
   FOR (idx = (temp_index_cnt+ 1) TO padded_size)
     SET temp_index->qual[idx].id = temp_index->qual[temp_index_cnt].id
   ENDFOR
   SELECT INTO "nl:"
    pt.processing_task_id
    FROM processing_task pt,
     (dummyt d1  WITH seq = value(loop_cnt))
    PLAN (d1)
     JOIN (pt
     WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),pt.case_specimen_id,
      request->spec_qual[temp_index->qual[idx].id].case_specimen_id,
      pt.updt_cnt,request->spec_qual[temp_index->qual[idx].id].case_specimen_updt_cnt)
      AND pt.create_inventory_flag=4)
    HEAD REPORT
     nbr_items = 0
    DETAIL
     nbr_items += 1
    WITH nocounter, forupdate(lt)
   ;end select
   IF (nbr_items != num_of_removed_comments)
    GO TO lock_processing_task_failed
   ENDIF
   UPDATE  FROM processing_task pt,
     (dummyt d1  WITH seq = value(loop_cnt))
    SET pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo
     ->updt_task,
     pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1), pt
     .comments_long_text_id = 0
    PLAN (d1)
     JOIN (pt
     WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),pt.case_specimen_id,
      request->spec_qual[temp_index->qual[idx].id].case_specimen_id,
      pt.updt_cnt,request->spec_qual[temp_index->qual[idx].id].case_specimen_updt_cnt)
      AND pt.create_inventory_flag=4)
    WITH nocounter
   ;end update
   SET stat = alterlist(temp_index->qual,temp_index_cnt)
   IF (curqual != num_of_removed_comments)
    GO TO update_processing_task_failed
   ENDIF
   DELETE  FROM long_text lt,
     (dummyt d1  WITH seq = value(temp_index_cnt))
    SET lt.long_text_id = request->spec_qual[temp_index->qual[d1.seq].id].case_comment_long_text_id
    PLAN (d1)
     JOIN (lt
     WHERE (lt.long_text_id=request->spec_qual[temp_index->qual[d1.seq].id].case_comment_long_text_id
     ))
    WITH nocounter
   ;end delete
   IF (curqual != num_of_removed_comments)
    GO TO delete_long_text_failed
   ENDIF
  ENDIF
 ENDIF
 IF (num_of_mod_comments > 0)
  SET temp_index_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbr_specimens))
   WHERE (request->spec_qual[d.seq].case_comment_long_text_id > 0)
    AND textlen(trim(request->spec_qual[d.seq].case_comment)) > 0
    AND (request->spec_qual[d.seq].case_comment_new != "Y")
   HEAD REPORT
    stat = alterlist(temp_index->qual,nbr_specimens)
   DETAIL
    temp_index_cnt += 1, temp_index->qual[temp_index_cnt].id = d.seq
   FOOT REPORT
    stat = alterlist(temp_index->qual,temp_index_cnt)
   WITH nocounter
  ;end select
  IF (temp_index_cnt > 0)
   SET batch_size = determineexpandsize(temp_index_cnt,40)
   SET loop_cnt = ceil((cnvtreal(temp_index_cnt)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_index->qual,padded_size)
   FOR (idx = (temp_index_cnt+ 1) TO padded_size)
     SET temp_index->qual[idx].id = temp_index->qual[temp_index_cnt].id
   ENDFOR
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d)
     JOIN (lt
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),lt.long_text_id,request->
      spec_qual[temp_index->qual[idx].id].case_comment_long_text_id,
      lt.updt_cnt,request->spec_qual[temp_index->qual[idx].id].case_lt_updt_cnt))
    HEAD REPORT
     nbr_items = 0
    DETAIL
     nbr_items += 1
    WITH nocounter, forupdate(lt)
   ;end select
   IF (nbr_items != num_of_mod_comments)
    GO TO lock_long_text_failed
   ENDIF
   SET stat = alterlist(temp_index->qual,temp_index_cnt)
   UPDATE  FROM long_text lt,
     (dummyt d1  WITH seq = value(temp_index_cnt))
    SET lt.long_text = trim(request->spec_qual[temp_index->qual[d1.seq].id].case_comment), lt
     .updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
     .updt_cnt+ 1)
    PLAN (d1)
     JOIN (lt
     WHERE (lt.long_text_id=request->spec_qual[temp_index->qual[d1.seq].id].case_comment_long_text_id
     )
      AND (lt.updt_cnt=request->spec_qual[temp_index->qual[d1.seq].id].case_lt_updt_cnt))
    WITH nocounter
   ;end update
   IF (curqual != num_of_mod_comments)
    GO TO update_long_text_failed
   ENDIF
  ENDIF
 ENDIF
 IF (num_of_new_comments > 0)
  CALL loadordercommentqual(0)
  INSERT  FROM long_text lt,
    (dummyt d1  WITH seq = value(nbr_specimens))
   SET lt.long_text_id = request->spec_qual[d1.seq].case_comment_long_text_id, lt.long_text = request
    ->spec_qual[d1.seq].case_comment, lt.parent_entity_id = order_comment->qual[d1.seq].
    processing_task_id,
    lt.parent_entity_name = "PROCESSING_TASK", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id
   PLAN (d1
    WHERE (request->spec_qual[d1.seq].case_comment_long_text_id > 0)
     AND (request->spec_qual[d1.seq].case_comment_new="Y"))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET batch_size = determineexpandsize(nbr_specimens,20)
  SET loop_cnt = ceil((cnvtreal(nbr_specimens)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(request->spec_qual,padded_size)
  SET stat = alterlist(order_comment->qual,padded_size)
  FOR (idx = (nbr_specimens+ 1) TO padded_size)
    SET request->spec_qual[idx].case_specimen_id = request->spec_qual[nbr_specimens].case_specimen_id
    SET request->spec_qual[idx].case_specimen_updt_cnt = request->spec_qual[nbr_specimens].
    case_specimen_updt_cnt
    SET request->spec_qual[idx].case_comment_new = request->spec_qual[nbr_specimens].case_comment_new
    SET order_comment->qual[idx].processing_task_id = order_comment->qual[nbr_specimens].
    processing_task_id
  ENDFOR
  SELECT INTO "nl:"
   pt.processing_task_id
   FROM processing_task pt,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1)
    JOIN (pt
    WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),pt.processing_task_id,
     order_comment->qual[idx].processing_task_id,
     pt.case_specimen_id,request->spec_qual[idx].case_specimen_id,pt.updt_cnt,request->spec_qual[idx]
     .case_specimen_updt_cnt,"Y",
     request->spec_qual[idx].case_comment_new)
     AND pt.create_inventory_flag=4)
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items += 1
   WITH nocounter, forupdate(pt)
  ;end select
  SET stat = alterlist(request->spec_qual,nbr_specimens)
  SET stat = alterlist(order_comment->qual,nbr_specimens)
  IF (nbr_items != num_of_new_comments)
   GO TO lock_specimen_failed
  ENDIF
  UPDATE  FROM processing_task pt,
    (dummyt d1  WITH seq = value(nbr_specimens))
   SET pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->
    updt_task,
    pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1), pt.comments_long_text_id
     = request->spec_qual[d1.seq].case_comment_long_text_id
   PLAN (d1
    WHERE (request->spec_qual[d1.seq].case_comment_new="Y"))
    JOIN (pt
    WHERE (pt.processing_task_id=order_comment->qual[d1.seq].processing_task_id)
     AND (pt.updt_cnt=request->spec_qual[d1.seq].case_specimen_updt_cnt)
     AND (pt.case_specimen_id=request->spec_qual[d1.seq].case_specimen_id)
     AND pt.create_inventory_flag=4)
   WITH nocounter
  ;end update
  IF (curqual != num_of_new_comments)
   GO TO update_processing_task_failed
  ENDIF
 ENDIF
 IF (label_cnt > 0)
  SET req200408->output_dest_cd = request->output_dest_cd
  EXECUTE aps_get_label_info_by_task  WITH replace("REQUEST","REQ200408"), replace("REPLY",reply)
 ENDIF
 GO TO exit_script
 SUBROUTINE deletelongtextrows(dummyvar)
   IF ((temp_processing->lremovedcomment > 0))
    DELETE  FROM long_text lt,
      (dummyt d  WITH seq = value(temp_proc_cnt))
     SET lt.long_text_id = temp_processing->qual[d.seq].comments_long_text_id
     PLAN (d
      WHERE (temp_processing->qual[d.seq].comment_flag=2))
      JOIN (lt
      WHERE (lt.long_text_id=temp_processing->qual[d.seq].comments_long_text_id))
     WITH nocounter
    ;end delete
    IF ((curqual != temp_processing->lremovedcomment))
     GO TO delete_long_text_failed
    ENDIF
    SET temp_processing->lremovedcomment = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercommentqual(dummyvar)
   SET stat = alterlist(order_comment->qual,nbr_specimens)
   SET batch_size = 20
   SET loop_cnt = ceil((cnvtreal(nbr_specimens)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(request->spec_qual,padded_size)
   FOR (idx = (nbr_specimens+ 1) TO padded_size)
     SET request->spec_qual[idx].case_specimen_id = request->spec_qual[nbr_specimens].
     case_specimen_id
   ENDFOR
   SELECT INTO "nl:"
    pt.processing_task_id
    FROM processing_task pt,
     (dummyt d1  WITH seq = value(loop_cnt))
    PLAN (d1)
     JOIN (pt
     WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),pt.case_specimen_id,
      request->spec_qual[idx].case_specimen_id)
      AND pt.create_inventory_flag=4)
    DETAIL
     lvindex = 0
     WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),nbr_specimens,pt.case_specimen_id,request->
       spec_qual[idx].case_specimen_id)) > 0)
       order_comment->qual[lvindex].processing_task_id = pt.processing_task_id
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(request->spec_qual,nbr_specimens)
 END ;Subroutine
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 SET failed = "T"
 GO TO exit_script
#insert_cassette_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE"
 SET failed = "T"
 GO TO exit_script
#lock_cassette_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE"
 SET failed = "T"
 GO TO exit_script
#update_cassette_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE"
 SET failed = "T"
 GO TO exit_script
#delete_cassette_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE"
 SET failed = "T"
 GO TO exit_script
#insert_slide_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE"
 SET failed = "T"
 GO TO exit_script
#lock_slide_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE"
 SET failed = "T"
 GO TO exit_script
#lock_slide_failed2
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE2"
 SET failed = "T"
 GO TO exit_script
#update_slide_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE"
 SET failed = "T"
 GO TO exit_script
#delete_slide_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE"
 SET failed = "T"
 GO TO exit_script
#insert_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lock_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#update_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#delete_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#insert_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#lock_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#update_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
 SET failed = "T"
 GO TO exit_script
#interface_failed
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_detail_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE SET temp_specimens
 FREE SET temp_processing
 FREE SET temp_cassette
 FREE SET temp_slide
 FREE SET order_comment
 FREE SET temp_index
 FREE SET inventory
 FREE SET req200456
 FREE SET rep200456
END GO
