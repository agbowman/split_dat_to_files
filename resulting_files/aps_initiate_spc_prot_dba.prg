CREATE PROGRAM aps_initiate_spc_prot:dba
 RECORD reply(
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
   1 label_job_data
     2 job_directory = vc
     2 job_filename = vc
     2 job_dir_and_filename = vc
     2 job_content = gvc
     2 suppress_spool_ind = i2
     2 line_template = vc
   1 inventory_data
     2 resp_pathologist_id = f8
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 task_qual[*]
         4 processing_task_id = f8
         4 task_assay_cd = f8
         4 catalog_cd = f8
         4 create_inventory_flag = i2
         4 priority_cd = f8
         4 priority_disp = c40
         4 t_no_charge_ind = i2
         4 request_dt_tm = dq8
         4 task_type_flag = i2
       3 slide_qual[*]
         4 slide_id = f8
         4 task_assay_cd = f8
         4 stain_task_assay_cd = f8
         4 tag_cd = f8
         4 tag_sequence = i4
         4 task_qual[*]
           5 processing_task_id = f8
           5 task_assay_cd = f8
           5 catalog_cd = f8
           5 create_inventory_flag = i2
           5 priority_cd = f8
           5 priority_disp = c40
           5 t_no_charge_ind = i2
           5 request_dt_tm = dq8
           5 task_type_flag = i2
           5 catalog_type_cd = f8
           5 universal_service_ident = vc
           5 placer_field_1 = vc
           5 suplmtl_serv_info_txt = vc
         4 tag_disp = c7
         4 stain_task_assay_disp = vc
       3 cassette_qual[*]
         4 cassette_id = f8
         4 cassette_tag_cd = f8
         4 tag_sequence = i4
         4 task_assay_cd = f8
         4 fixative_cd = f8
         4 pieces = c3
         4 task_qual[*]
           5 processing_task_id = f8
           5 task_assay_cd = f8
           5 catalog_cd = f8
           5 create_inventory_flag = i2
           5 priority_cd = f8
           5 priority_disp = c40
           5 t_no_charge_ind = i2
           5 request_dt_tm = dq8
           5 task_type_flag = i2
         4 slide_qual[*]
           5 slide_id = f8
           5 task_assay_cd = f8
           5 stain_task_assay_cd = f8
           5 tag_cd = f8
           5 tag_sequence = i4
           5 task_qual[*]
             6 processing_task_id = f8
             6 task_assay_cd = f8
             6 catalog_cd = f8
             6 create_inventory_flag = i2
             6 priority_cd = f8
             6 priority_disp = c40
             6 t_no_charge_ind = i2
             6 request_dt_tm = dq8
             6 task_type_flag = i2
             6 catalog_type_cd = f8
             6 universal_service_ident = vc
             6 placer_field_1 = vc
             6 suplmtl_serv_info_txt = vc
           5 tag_disp = c7
           5 stain_task_assay_disp = vc
         4 cassette_tag_disp = c7
       3 specimen_cd = f8
     2 cassette_separator = c1
     2 slide_separator = c1
   1 person_id = f8
   1 encntr_id = f8
   1 encntr_nurse_unit_cd = f8
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE error_cnt = i2 WITH protect, noconstant(0)
 DECLARE process_orders = i2 WITH protect, noconstant(0)
 DECLARE spec_cnt = i4 WITH protect, noconstant(0)
 DECLARE label_cnt = i4 WITH protect, noconstant(0)
 DECLARE proc_activity_subtype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bill_activity_subtype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cassette_tag_group_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cassette_tag_separator = c1 WITH protect, noconstant("")
 DECLARE slide_tag_group_cd = f8 WITH protect, noconstant(0.0)
 DECLARE slide_tag_separator = c1 WITH protect, noconstant("")
 DECLARE interface_flag = i2 WITH protect, noconstant(0)
 DECLARE tracking_service_resource_cd = f8 WITH protect, noconstant(0.0)
 SUBROUTINE (handle_errors(op_name=vc,op_status=vc,tar_name=vc,tar_value=vc) =null WITH protect)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
 RECORD protocol(
   1 prefix_cd = f8
   1 pathologist_id = f8
   1 max_task_cnt = i2
   1 spec[*]
     2 specimen_cd = f8
     2 case_specimen_id = f8
     2 fixative_cd = f8
     2 priority_cd = f8
     2 priority_disp = c40
     2 protocol_id = f8
     2 task[*]
       3 catalog_cd = f8
       3 task_assay_cd = f8
       3 begin_section = i4
       3 begin_level = i4
       3 create_inventory_flag = i4
       3 stain_ind = i2
       3 t_no_charge_ind = i2
       3 task_type_flag = i2
       3 catalog_type_cd = f8
 )
 SELECT INTO "nl:"
  ap.prefix_id
  FROM pathology_case pc,
   ap_prefix ap,
   ap_prefix_tag_group_r aptg
  PLAN (pc
   WHERE (request->case_id=pc.case_id))
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id
    AND ap.initiate_protocol_ind=1)
   JOIN (aptg
   WHERE ap.prefix_id=aptg.prefix_id
    AND aptg.tag_type_flag IN (2, 3))
  HEAD REPORT
   protocol->prefix_cd = ap.prefix_id, protocol->pathologist_id = pc.responsible_pathologist_id,
   interface_flag = ap.interface_flag,
   tracking_service_resource_cd = ap.tracking_service_resource_cd
  DETAIL
   IF (aptg.tag_type_flag=2)
    cassette_tag_group_cd = aptg.tag_group_id, cassette_tag_separator = aptg.tag_separator
   ELSEIF (aptg.tag_type_flag=3)
    slide_tag_group_cd = aptg.tag_group_id, slide_tag_separator = aptg.tag_separator
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  CALL handle_errors("SELECT","Z","TABLE","PATHOLOGY_CASE")
  GO TO exit_script
 ENDIF
 SET spec_cnt = size(request->spec_qual,5)
 SET stat = alterlist(protocol->spec,spec_cnt)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(spec_cnt))
  PLAN (d
   WHERE (request->spec_qual[d.seq].case_specimen_id != 0.0))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1, protocol->spec[cnt].case_specimen_id = request->spec_qual[d.seq].case_specimen_id,
   protocol->spec[cnt].specimen_cd = request->spec_qual[d.seq].specimen_cd,
   protocol->spec[cnt].fixative_cd = request->spec_qual[d.seq].received_fixative_cd, protocol->spec[
   cnt].priority_cd = request->spec_qual[d.seq].priority_cd, protocol->spec[cnt].priority_disp =
   request->spec_qual[d.seq].priority_disp,
   protocol->spec[cnt].protocol_id = 0.0
  FOOT REPORT
   IF (cnt < spec_cnt)
    stat = alterlist(protocol->spec,cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(protocol->spec,5)=0)
  SET reqinfo->commit_ind = 0
  CALL handle_errors("GET","F","PROTOCOL","SPEC")
  GO TO exit_script
 ENDIF
 EXECUTE aps_load_specimen_protocol
 IF ((protocol->max_task_cnt=0))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  CALL handle_errors("GET","Z","PROTOCOL","MAX_TASK_CNT")
  GO TO exit_script
 ENDIF
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,proc_activity_subtype_cd)
 CALL echo(build("proc_activity_subtype_cd = ",proc_activity_subtype_cd))
 IF (proc_activity_subtype_cd=0)
  SET reqinfo->commit_ind = 0
  CALL handle_errors("UAR","F","5801","APPROCESS")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,bill_activity_subtype_cd)
 CALL echo(build("bill_activity_subtype_cd = ",bill_activity_subtype_cd))
 IF (bill_activity_subtype_cd=0)
  SET reqinfo->commit_ind = 0
  CALL handle_errors("UAR","F","5801","APBILLING")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, d2.seq, oc.catalog_cd
  FROM (dummyt d1  WITH seq = value(size(protocol->spec,5))),
   (dummyt d2  WITH seq = value(protocol->max_task_cnt)),
   profile_task_r ptr,
   order_catalog oc
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(protocol->spec[d1.seq].task,5)
    AND (protocol->spec[d1.seq].task[d2.seq].catalog_cd=0.0))
   JOIN (ptr
   WHERE (protocol->spec[d1.seq].task[d2.seq].task_assay_cd=ptr.task_assay_cd)
    AND 1=ptr.active_ind
    AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (oc
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND oc.activity_subtype_cd IN (proc_activity_subtype_cd, bill_activity_subtype_cd)
    AND 1=oc.active_ind)
  DETAIL
   protocol->spec[d1.seq].task[d2.seq].catalog_cd = oc.catalog_cd, protocol->spec[d1.seq].task[d2.seq
   ].catalog_type_cd = oc.catalog_type_cd,
   CALL echo(build("protocol->spec[",d1.seq,"].task[",d2.seq,"].catalog_cd = ",
    protocol->spec[d1.seq].task[d2.seq].catalog_cd))
  WITH nocounter
 ;end select
 RECORD inventory(
   1 inventory_data
     2 resp_pathologist_id = f8
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 task_qual[*]
         4 processing_task_id = f8
         4 task_assay_cd = f8
         4 catalog_cd = f8
         4 create_inventory_flag = i2
         4 priority_cd = f8
         4 priority_disp = c40
         4 t_no_charge_ind = i2
         4 request_dt_tm = dq8
         4 task_type_flag = i2
       3 slide_qual[*]
         4 slide_id = f8
         4 task_assay_cd = f8
         4 stain_task_assay_cd = f8
         4 tag_cd = f8
         4 tag_sequence = i4
         4 task_qual[*]
           5 processing_task_id = f8
           5 task_assay_cd = f8
           5 catalog_cd = f8
           5 create_inventory_flag = i2
           5 priority_cd = f8
           5 priority_disp = c40
           5 t_no_charge_ind = i2
           5 request_dt_tm = dq8
           5 task_type_flag = i2
           5 catalog_type_cd = f8
           5 universal_service_ident = vc
           5 placer_field_1 = vc
           5 suplmtl_serv_info_txt = vc
         4 tag_disp = c7
         4 stain_task_assay_disp = vc
       3 cassette_qual[*]
         4 cassette_id = f8
         4 cassette_tag_cd = f8
         4 tag_sequence = i4
         4 task_assay_cd = f8
         4 fixative_cd = f8
         4 pieces = c3
         4 task_qual[*]
           5 processing_task_id = f8
           5 task_assay_cd = f8
           5 catalog_cd = f8
           5 create_inventory_flag = i2
           5 priority_cd = f8
           5 priority_disp = c40
           5 t_no_charge_ind = i2
           5 request_dt_tm = dq8
           5 task_type_flag = i2
         4 slide_qual[*]
           5 slide_id = f8
           5 task_assay_cd = f8
           5 stain_task_assay_cd = f8
           5 tag_cd = f8
           5 tag_sequence = i4
           5 task_qual[*]
             6 processing_task_id = f8
             6 task_assay_cd = f8
             6 catalog_cd = f8
             6 create_inventory_flag = i2
             6 priority_cd = f8
             6 priority_disp = c40
             6 t_no_charge_ind = i2
             6 request_dt_tm = dq8
             6 task_type_flag = i2
             6 catalog_type_cd = f8
             6 universal_service_ident = vc
             6 placer_field_1 = vc
             6 suplmtl_serv_info_txt = vc
           5 tag_disp = c7
           5 stain_task_assay_disp = vc
         4 cassette_tag_disp = c7
       3 specimen_cd = f8
     2 cassette_separator = c1
     2 slide_separator = c1
   1 person_id = f8
   1 encntr_id = f8
   1 encntr_nurse_unit_cd = f8
 )
 SET max_sc_cnt = 0
 SET max_ss_cnt = 0
 SET max_scs_cnt = 0
 SET inventory->resp_pathologist_id = protocol->pathologist_id
 SET inventory->cassette_separator = cassette_tag_separator
 SET inventory->slide_separator = slide_tag_separator
 SELECT INTO "nl:"
  d.seq, d2.seq, create_inventory = protocol->spec[d.seq].task[d2.seq].create_inventory_flag,
  ncreateblock = evaluate(protocol->spec[d.seq].task[d2.seq].create_inventory_flag,1,1,2,0,
   3,1,0,0), ncreateslide = evaluate(protocol->spec[d.seq].task[d2.seq].create_inventory_flag,1,0,2,1,
   3,1,0,0), begin_section = protocol->spec[d.seq].task[d2.seq].begin_section,
  begin_level = protocol->spec[d.seq].task[d2.seq].begin_level
  FROM (dummyt d  WITH seq = value(size(protocol->spec,5))),
   (dummyt d2  WITH seq = value(protocol->max_task_cnt))
  PLAN (d
   WHERE maxrec(d2,size(protocol->spec[d.seq].task,5)))
   JOIN (d2)
  ORDER BY d.seq, begin_section, ncreateblock DESC,
   begin_level, ncreateslide DESC, d2.seq
  HEAD REPORT
   s_cnt = 0, max_sc_cnt = 0, max_ss_cnt = 0,
   max_scs_cnt = 0
  HEAD d.seq
   sc_cnt = 0, ss_cnt = 0, scs_cnt = 0,
   t_cnt = 0, s_cnt += 1, stat = alterlist(inventory->spec_qual,s_cnt)
   FOR (x = 1 TO size(request->spec_qual,5))
     IF ((protocol->spec[d.seq].case_specimen_id=request->spec_qual[x].case_specimen_id))
      inventory->spec_qual[s_cnt].case_specimen_tag_cd = request->spec_qual[x].specimen_tag_cd, x =
      size(request->spec_qual,5)
     ENDIF
   ENDFOR
   inventory->spec_qual[s_cnt].case_specimen_id = protocol->spec[d.seq].case_specimen_id, inventory->
   spec_qual[s_cnt].specimen_cd = protocol->spec[d.seq].specimen_cd
  DETAIL
   CASE (protocol->spec[d.seq].task[d2.seq].create_inventory_flag)
    OF 1:
     CALL echo("create block")sc_cnt = protocol->spec[d.seq].task[d2.seq].begin_section,
     IF (sc_cnt > max_sc_cnt)
      max_sc_cnt = sc_cnt
     ENDIF
     ,stat = alterlist(inventory->spec_qual[s_cnt].cassette_qual,sc_cnt),inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd,inventory
     ->spec_qual[s_cnt].cassette_qual[sc_cnt].pieces = "1",
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].fixative_cd = protocol->spec[d.seq].
     fixative_cd,inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].tag_sequence = sc_cnt
    OF 2:
     IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0))
      CALL echo("create specimen slide"), ss_cnt = protocol->spec[d.seq].task[d2.seq].begin_level
      IF (ss_cnt > max_ss_cnt)
       max_ss_cnt = ss_cnt
      ENDIF
      stat = alterlist(inventory->spec_qual[s_cnt].slide_qual,ss_cnt), inventory->spec_qual[s_cnt].
      slide_qual[ss_cnt].task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd, inventory
      ->spec_qual[s_cnt].slide_qual[ss_cnt].tag_sequence = ss_cnt
      IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
       inventory->spec_qual[s_cnt].slide_qual[ss_cnt].stain_task_assay_cd = protocol->spec[d.seq].
       task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].slide_qual[ss_cnt].
       stain_task_assay_disp = uar_get_code_display(inventory->spec_qual[s_cnt].slide_qual[ss_cnt].
        stain_task_assay_cd)
      ENDIF
     ELSEIF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0))
      CALL echo("create cassette slide"), scs_cnt = protocol->spec[d.seq].task[d2.seq].begin_level
      IF (scs_cnt > max_scs_cnt)
       max_scs_cnt = scs_cnt
      ENDIF
      stat = alterlist(inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual,scs_cnt),
      inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_assay_cd = protocol
      ->spec[d.seq].task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].
      slide_qual[scs_cnt].tag_sequence = scs_cnt
      IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
       inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd =
       protocol->spec[d.seq].task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].cassette_qual[
       sc_cnt].slide_qual[scs_cnt].stain_task_assay_disp = uar_get_code_display(inventory->spec_qual[
        s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd)
      ENDIF
     ENDIF
    OF 3:
     CALL echo("create cassette & slide")sc_cnt = protocol->spec[d.seq].task[d2.seq].begin_section,
     IF (sc_cnt > max_sc_cnt)
      max_sc_cnt = sc_cnt
     ENDIF
     ,stat = alterlist(inventory->spec_qual[s_cnt].cassette_qual,sc_cnt),inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd,inventory
     ->spec_qual[s_cnt].cassette_qual[sc_cnt].tag_sequence = sc_cnt,
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].pieces = "1",inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].fixative_cd = protocol->spec[d.seq].fixative_cd,scs_cnt = protocol->spec[d
     .seq].task[d2.seq].begin_level,
     IF (scs_cnt > max_scs_cnt)
      max_scs_cnt = scs_cnt
     ENDIF
     ,stat = alterlist(inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual,scs_cnt),
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_assay_cd = protocol->
     spec[d.seq].task[d2.seq].task_assay_cd,inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].
     slide_qual[scs_cnt].tag_sequence = scs_cnt,
     IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
      inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd =
      protocol->spec[d.seq].task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].cassette_qual[
      sc_cnt].slide_qual[scs_cnt].stain_task_assay_disp = uar_get_code_display(inventory->spec_qual[
       s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd)
     ENDIF
   ENDCASE
   CALL echo(build("protocol->spec[d.seq].task[d2.seq].begin_section = ",protocol->spec[d.seq].task[
    d2.seq].begin_section)),
   CALL echo(build("protocol->spec[d.seq].task[d2.seq].begin_level = ",protocol->spec[d.seq].task[d2
    .seq].begin_level))
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level=0))
    CALL echo("specimen task"), t_cnt = (size(inventory->spec_qual[s_cnt].task_qual,5)+ 1), stat =
    alterlist(inventory->spec_qual[s_cnt].task_qual,t_cnt),
    inventory->spec_qual[s_cnt].task_qual[t_cnt].catalog_cd = protocol->spec[d.seq].task[d2.seq].
    catalog_cd, inventory->spec_qual[s_cnt].task_qual[t_cnt].task_assay_cd = protocol->spec[d.seq].
    task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].task_qual[t_cnt].create_inventory_flag =
    protocol->spec[d.seq].task[d2.seq].create_inventory_flag,
    inventory->spec_qual[s_cnt].task_qual[t_cnt].t_no_charge_ind = protocol->spec[d.seq].task[d2.seq]
    .t_no_charge_ind, inventory->spec_qual[s_cnt].task_qual[t_cnt].priority_cd = protocol->spec[d.seq
    ].priority_cd, inventory->spec_qual[s_cnt].task_qual[t_cnt].priority_disp = protocol->spec[d.seq]
    .priority_disp,
    inventory->spec_qual[s_cnt].task_qual[t_cnt].request_dt_tm = cnvtdatetime(sysdate), inventory->
    spec_qual[s_cnt].task_qual[t_cnt].task_type_flag = protocol->spec[d.seq].task[d2.seq].
    task_type_flag
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section=0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level > 0))
    CALL echo("specimen/slide task"), t_cnt = (size(inventory->spec_qual[s_cnt].slide_qual[ss_cnt].
     task_qual,5)+ 1), stat = alterlist(inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual,
     t_cnt),
    inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].catalog_cd = protocol->spec[d.seq
    ].task[d2.seq].catalog_cd, inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].
    catalog_type_cd = protocol->spec[d.seq].task[d2.seq].catalog_type_cd, inventory->spec_qual[s_cnt]
    .slide_qual[ss_cnt].task_qual[t_cnt].task_assay_cd = protocol->spec[d.seq].task[d2.seq].
    task_assay_cd,
    inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].create_inventory_flag = protocol
    ->spec[d.seq].task[d2.seq].create_inventory_flag, inventory->spec_qual[s_cnt].slide_qual[ss_cnt].
    task_qual[t_cnt].t_no_charge_ind = protocol->spec[d.seq].task[d2.seq].t_no_charge_ind, inventory
    ->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].priority_cd = protocol->spec[d.seq].
    priority_cd,
    inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].priority_disp = protocol->spec[d
    .seq].priority_disp, inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[t_cnt].
    request_dt_tm = cnvtdatetime(sysdate), inventory->spec_qual[s_cnt].slide_qual[ss_cnt].task_qual[
    t_cnt].task_type_flag = protocol->spec[d.seq].task[d2.seq].task_type_flag
    IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
     inventory->spec_qual[s_cnt].slide_qual[ss_cnt].stain_task_assay_cd = protocol->spec[d.seq].task[
     d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].slide_qual[ss_cnt].stain_task_assay_disp =
     uar_get_code_display(inventory->spec_qual[s_cnt].slide_qual[ss_cnt].stain_task_assay_cd)
    ENDIF
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level=0))
    IF ((protocol->spec[d.seq].task[d2.seq].begin_section=sc_cnt))
     CALL echo("cassette task"), t_cnt = (size(inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].
      task_qual,5)+ 1), stat = alterlist(inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual,
      t_cnt),
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual[t_cnt].catalog_cd = protocol->spec[d
     .seq].task[d2.seq].catalog_cd, inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual[t_cnt
     ].task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].task_qual[t_cnt].create_inventory_flag = protocol->spec[d.seq].task[d2.seq
     ].create_inventory_flag,
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual[t_cnt].t_no_charge_ind = protocol->
     spec[d.seq].task[d2.seq].t_no_charge_ind, inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].
     task_qual[t_cnt].priority_cd = protocol->spec[d.seq].priority_cd, inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].task_qual[t_cnt].priority_disp = protocol->spec[d.seq].priority_disp,
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual[t_cnt].request_dt_tm = cnvtdatetime(
      sysdate), inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].task_qual[t_cnt].task_type_flag =
     protocol->spec[d.seq].task[d2.seq].task_type_flag
    ENDIF
   ENDIF
   IF ((protocol->spec[d.seq].task[d2.seq].begin_section > 0)
    AND (protocol->spec[d.seq].task[d2.seq].begin_level > 0))
    CALL echo("slide task"), t_cnt = (size(inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].
     slide_qual[scs_cnt].task_qual,5)+ 1), stat = alterlist(inventory->spec_qual[s_cnt].
     cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual,t_cnt),
    inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].catalog_cd
     = protocol->spec[d.seq].task[d2.seq].catalog_cd, inventory->spec_qual[s_cnt].cassette_qual[
    sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].catalog_type_cd = protocol->spec[d.seq].task[d2.seq]
    .catalog_type_cd, inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].
    task_qual[t_cnt].task_assay_cd = protocol->spec[d.seq].task[d2.seq].task_assay_cd,
    inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].
    create_inventory_flag = protocol->spec[d.seq].task[d2.seq].create_inventory_flag, inventory->
    spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].t_no_charge_ind =
    protocol->spec[d.seq].task[d2.seq].t_no_charge_ind, inventory->spec_qual[s_cnt].cassette_qual[
    sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].priority_cd = protocol->spec[d.seq].priority_cd,
    inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].
    priority_disp = protocol->spec[d.seq].priority_disp, inventory->spec_qual[s_cnt].cassette_qual[
    sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].request_dt_tm = cnvtdatetime(sysdate), inventory->
    spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].task_qual[t_cnt].task_type_flag =
    protocol->spec[d.seq].task[d2.seq].task_type_flag
    IF ((protocol->spec[d.seq].task[d2.seq].stain_ind=1))
     inventory->spec_qual[s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd =
     protocol->spec[d.seq].task[d2.seq].task_assay_cd, inventory->spec_qual[s_cnt].cassette_qual[
     sc_cnt].slide_qual[scs_cnt].stain_task_assay_disp = uar_get_code_display(inventory->spec_qual[
      s_cnt].cassette_qual[sc_cnt].slide_qual[scs_cnt].stain_task_assay_cd)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (size(inventory->spec_qual,5)=0)
  SET reqinfo->commit_ind = 0
  CALL handle_errors("GET","F","INVENTORY","SPEC_QUAL")
  GO TO exit_script
 ENDIF
 IF (max_ss_cnt > 0)
  SELECT INTO "nl:"
   d.seq, d1.seq
   FROM (dummyt d  WITH seq = value(size(inventory->spec_qual,5))),
    (dummyt d1  WITH seq = value(max_ss_cnt)),
    ap_tag at
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(inventory->spec_qual[d.seq].slide_qual,5))
    JOIN (at
    WHERE slide_tag_group_cd=at.tag_group_id
     AND (inventory->spec_qual[d.seq].slide_qual[d1.seq].tag_sequence=at.tag_sequence)
     AND 1=at.active_ind)
   DETAIL
    inventory->spec_qual[d.seq].slide_qual[d1.seq].tag_cd = at.tag_id, inventory->spec_qual[d.seq].
    slide_qual[d1.seq].tag_disp = at.tag_disp
   WITH nocounter
  ;end select
 ENDIF
 IF (max_sc_cnt > 0)
  SELECT INTO "nl:"
   d.seq, d1.seq
   FROM (dummyt d  WITH seq = value(size(inventory->spec_qual,5))),
    (dummyt d1  WITH seq = value(max_sc_cnt)),
    ap_tag at
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(inventory->spec_qual[d.seq].cassette_qual,5))
    JOIN (at
    WHERE cassette_tag_group_cd=at.tag_group_id
     AND (inventory->spec_qual[d.seq].cassette_qual[d1.seq].tag_sequence=at.tag_sequence)
     AND 1=at.active_ind)
   DETAIL
    inventory->spec_qual[d.seq].cassette_qual[d1.seq].cassette_tag_cd = at.tag_id, inventory->
    spec_qual[d.seq].cassette_qual[d1.seq].cassette_tag_disp = at.tag_disp
   WITH nocounter
  ;end select
 ENDIF
 IF (max_sc_cnt > 0
  AND max_scs_cnt > 0)
  SELECT INTO "nl:"
   d.seq, d1.seq, d2.seq
   FROM (dummyt d  WITH seq = value(size(inventory->spec_qual,5))),
    (dummyt d1  WITH seq = value(max_sc_cnt)),
    (dummyt d2  WITH seq = value(max_scs_cnt)),
    ap_tag at
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(inventory->spec_qual[d.seq].cassette_qual,5))
    JOIN (d2
    WHERE d2.seq <= size(inventory->spec_qual[d.seq].cassette_qual[d1.seq].slide_qual,5))
    JOIN (at
    WHERE slide_tag_group_cd=at.tag_group_id
     AND (inventory->spec_qual[d.seq].cassette_qual[d1.seq].slide_qual[d2.seq].tag_sequence=at
    .tag_sequence)
     AND 1=at.active_ind)
   DETAIL
    inventory->spec_qual[d.seq].cassette_qual[d1.seq].slide_qual[d2.seq].tag_cd = at.tag_id,
    inventory->spec_qual[d.seq].cassette_qual[d1.seq].slide_qual[d2.seq].tag_disp = at.tag_disp
   WITH nocounter
  ;end select
 ENDIF
 RECORD temp_processing(
   1 qual[*]
     2 processing_task_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 slide_id = f8
     2 create_inventory_flag = i2
     2 task_assay_cd = f8
     2 catalog_cd = f8
     2 priority_cd = f8
     2 case_specimen_tag_cd = f8
     2 cassette_tag_cd = f8
     2 slide_tag_cd = f8
     2 t_no_charge_ind = i2
     2 request_dt_tm = dq8
 )
 RECORD temp_cassette(
   1 qual[*]
     2 cassette_id = f8
     2 case_specimen_id = f8
     2 cassette_tag_cd = f8
     2 task_assay_cd = f8
     2 fixative_cd = f8
     2 pieces = c3
 )
 RECORD temp_slide(
   1 qual[*]
     2 slide_id = f8
     2 case_specimen_id = f8
     2 cassette_id = f8
     2 task_assay_cd = f8
     2 stain_task_assay_cd = f8
     2 tag_cd = f8
 )
 SET cass_cnt = 0
 SET slide_cnt = 0
 SET task_cnt = 0
 SET nbr_specimens = cnvtint(size(inventory->spec_qual,5))
 SET nbr_cassettes = 0
 SET nbr_slides = 0
 SET nbr_tasks = 0
 SET temp_proc_cnt = 0
 SET temp_slide_cnt = 0
 SET temp_cass_cnt = 0
 SET cur_spec_status_cd = 0.0
 SET cnt = 0
 DECLARE ordered_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(1305,"ORDERED",1,ordered_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_status_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
 IF (((ordered_status_cd=0) OR (((verified_status_cd=0) OR (processing_status_cd=0)) )) )
  SET reqinfo->commit_ind = 0
  CALL handle_errors("UAR","F","1305","ORDERED, PROCESSING, VERIFIED")
  GO TO exit_script
 ENDIF
 SET x = 1
#cont_loop
 FOR (cnt = x TO nbr_specimens)
   SET stat = alterlist(temp_cassette->qual,0)
   SET stat = alterlist(temp_slide->qual,0)
   SET stat = alterlist(temp_processing->qual,0)
   SET stat = alterlist(temp_cassette->qual,5)
   SET stat = alterlist(temp_slide->qual,5)
   SET stat = alterlist(temp_processing->qual,5)
   SET temp_proc_cnt = 0
   SET temp_slide_cnt = 0
   SET temp_cass_cnt = 0
   SET temp_charge_cnt = 0
   SET nbr_tasks = cnvtint(size(inventory->spec_qual[cnt].task_qual,5))
   FOR (task_cnt = 1 TO nbr_tasks)
     SET temp_proc_cnt += 1
     IF (mod(temp_proc_cnt,5)=1
      AND temp_proc_cnt != 1)
      SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 4))
     ENDIF
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       temp_processing->qual[temp_proc_cnt].processing_task_id = seq_nbr, inventory->spec_qual[cnt].
       task_qual[task_cnt].processing_task_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      CALL echo("ERROR adding specimen task")
      CALL handle_errors("SEQ","F","NEXTVAL","ADDING SPECIMEN TASK")
      GO TO inventory_failed
     ENDIF
     SET temp_processing->qual[temp_proc_cnt].case_specimen_id = inventory->spec_qual[cnt].
     case_specimen_id
     SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
     SET temp_processing->qual[temp_proc_cnt].slide_id = 0
     SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = inventory->spec_qual[cnt].
     case_specimen_tag_cd
     SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
     SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
     SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = inventory->spec_qual[cnt].
     task_qual[task_cnt].create_inventory_flag
     SET temp_processing->qual[temp_proc_cnt].task_assay_cd = inventory->spec_qual[cnt].task_qual[
     task_cnt].task_assay_cd
     SET temp_processing->qual[temp_proc_cnt].t_no_charge_ind = inventory->spec_qual[cnt].task_qual[
     task_cnt].t_no_charge_ind
     SET temp_processing->qual[temp_proc_cnt].catalog_cd = inventory->spec_qual[cnt].task_qual[
     task_cnt].catalog_cd
     SET temp_processing->qual[temp_proc_cnt].priority_cd = inventory->spec_qual[cnt].task_qual[
     task_cnt].priority_cd
     SET temp_processing->qual[temp_proc_cnt].request_dt_tm = inventory->spec_qual[cnt].task_qual[
     task_cnt].request_dt_tm
     IF ((inventory->spec_qual[cnt].task_qual[task_cnt].task_type_flag=0))
      SET temp_charge_cnt += 1
     ENDIF
   ENDFOR
   SET nbr_slides = cnvtint(size(inventory->spec_qual[cnt].slide_qual,5))
   FOR (slide_cnt = 1 TO nbr_slides)
     SET temp_slide_cnt += 1
     IF (mod(temp_slide_cnt,5)=1
      AND temp_slide_cnt != 1)
      SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 4))
     ENDIF
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       temp_slide->qual[temp_slide_cnt].slide_id = seq_nbr, inventory->spec_qual[cnt].slide_qual[
       slide_cnt].slide_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      CALL echo("ERROR adding specimen slide inventory")
      CALL handle_errors("SEQ","F","NEXTVAL","ADDING SPECIMEN SLIDE INVENTORY")
      GO TO inventory_failed
     ENDIF
     SET temp_slide->qual[temp_slide_cnt].case_specimen_id = inventory->spec_qual[cnt].
     case_specimen_id
     SET temp_slide->qual[temp_slide_cnt].cassette_id = 0
     SET temp_slide->qual[temp_slide_cnt].task_assay_cd = inventory->spec_qual[cnt].slide_qual[
     slide_cnt].task_assay_cd
     SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = inventory->spec_qual[cnt].slide_qual[
     slide_cnt].stain_task_assay_cd
     SET temp_slide->qual[temp_slide_cnt].tag_cd = inventory->spec_qual[cnt].slide_qual[slide_cnt].
     tag_cd
     SET nbr_tasks = cnvtint(size(inventory->spec_qual[cnt].slide_qual[slide_cnt].task_qual,5))
     FOR (task_cnt = 1 TO nbr_tasks)
       SET temp_proc_cnt += 1
       IF (mod(temp_proc_cnt,5)=1
        AND temp_proc_cnt != 1)
        SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 4))
       ENDIF
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         temp_processing->qual[temp_proc_cnt].processing_task_id = seq_nbr, inventory->spec_qual[cnt]
         .slide_qual[slide_cnt].task_qual[task_cnt].processing_task_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        CALL echo("adding specimen slide task")
        CALL handle_errors("SEQ","F","NEXTVAL","ADDING SPECIMEN SLIDE TASK")
        GO TO inventory_failed
       ENDIF
       SET temp_processing->qual[temp_proc_cnt].case_specimen_id = inventory->spec_qual[cnt].
       case_specimen_id
       SET temp_processing->qual[temp_proc_cnt].cassette_id = 0
       SET temp_processing->qual[temp_proc_cnt].slide_id = temp_slide->qual[temp_slide_cnt].slide_id
       SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = inventory->spec_qual[cnt].
       case_specimen_tag_cd
       SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = 0
       SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = inventory->spec_qual[cnt].slide_qual[
       slide_cnt].tag_cd
       SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = inventory->spec_qual[cnt].
       slide_qual[slide_cnt].task_qual[task_cnt].create_inventory_flag
       SET temp_processing->qual[temp_proc_cnt].task_assay_cd = inventory->spec_qual[cnt].slide_qual[
       slide_cnt].task_qual[task_cnt].task_assay_cd
       SET temp_processing->qual[temp_proc_cnt].t_no_charge_ind = inventory->spec_qual[cnt].
       slide_qual[slide_cnt].task_qual[task_cnt].t_no_charge_ind
       SET temp_processing->qual[temp_proc_cnt].catalog_cd = inventory->spec_qual[cnt].slide_qual[
       slide_cnt].task_qual[task_cnt].catalog_cd
       SET temp_processing->qual[temp_proc_cnt].priority_cd = inventory->spec_qual[cnt].slide_qual[
       slide_cnt].task_qual[task_cnt].priority_cd
       SET temp_processing->qual[temp_proc_cnt].request_dt_tm = inventory->spec_qual[cnt].slide_qual[
       slide_cnt].task_qual[task_cnt].request_dt_tm
       IF ((inventory->spec_qual[cnt].slide_qual[slide_cnt].task_qual[task_cnt].task_type_flag=0))
        SET temp_charge_cnt += 1
       ENDIF
     ENDFOR
   ENDFOR
   SET nbr_cassettes = cnvtint(size(inventory->spec_qual[cnt].cassette_qual,5))
   FOR (cass_cnt = 1 TO nbr_cassettes)
     SET temp_cass_cnt += 1
     IF (mod(temp_cass_cnt,5)=1
      AND temp_cass_cnt != 1)
      SET stat = alterlist(temp_cassette->qual,(temp_cass_cnt+ 4))
     ENDIF
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       temp_cassette->qual[temp_cass_cnt].cassette_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      CALL echo("ERROR adding cassette inventory")
      CALL handle_errors("SEQ","F","NEXTVAL","ADDING CASSSETTE INVENTORY")
      GO TO inventory_failed
     ENDIF
     SET inventory->spec_qual[cnt].cassette_qual[cass_cnt].cassette_id = temp_cassette->qual[
     temp_cass_cnt].cassette_id
     SET temp_cassette->qual[temp_cass_cnt].case_specimen_id = inventory->spec_qual[cnt].
     case_specimen_id
     SET temp_cassette->qual[temp_cass_cnt].cassette_tag_cd = inventory->spec_qual[cnt].
     cassette_qual[cass_cnt].cassette_tag_cd
     SET temp_cassette->qual[temp_cass_cnt].fixative_cd = inventory->spec_qual[cnt].cassette_qual[
     cass_cnt].fixative_cd
     SET temp_cassette->qual[temp_cass_cnt].task_assay_cd = inventory->spec_qual[cnt].cassette_qual[
     cass_cnt].task_assay_cd
     SET temp_cassette->qual[temp_cass_cnt].pieces = inventory->spec_qual[cnt].cassette_qual[cass_cnt
     ].pieces
     SET nbr_tasks = cnvtint(size(inventory->spec_qual[cnt].cassette_qual[cass_cnt].task_qual,5))
     FOR (task_cnt = 1 TO nbr_tasks)
       SET temp_proc_cnt += 1
       IF (mod(temp_proc_cnt,5)=1
        AND temp_proc_cnt != 1)
        SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 4))
       ENDIF
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         temp_processing->qual[temp_proc_cnt].processing_task_id = seq_nbr, inventory->spec_qual[cnt]
         .cassette_qual[cass_cnt].task_qual[task_cnt].processing_task_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        CALL echo("ERROR adding cassette task")
        CALL handle_errors("SEQ","F","NEXTVAL","ADDING CASSETTE TASK")
        GO TO inventory_failed
       ENDIF
       SET temp_processing->qual[temp_proc_cnt].case_specimen_id = inventory->spec_qual[cnt].
       case_specimen_id
       SET temp_processing->qual[temp_proc_cnt].cassette_id = temp_cassette->qual[temp_cass_cnt].
       cassette_id
       SET temp_processing->qual[temp_proc_cnt].slide_id = 0
       SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = inventory->spec_qual[cnt].
       case_specimen_tag_cd
       SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].cassette_tag_cd
       SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = 0
       SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].task_qual[task_cnt].create_inventory_flag
       SET temp_processing->qual[temp_proc_cnt].task_assay_cd = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].task_qual[task_cnt].task_assay_cd
       SET temp_processing->qual[temp_proc_cnt].t_no_charge_ind = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].task_qual[task_cnt].t_no_charge_ind
       SET temp_processing->qual[temp_proc_cnt].catalog_cd = inventory->spec_qual[cnt].cassette_qual[
       cass_cnt].task_qual[task_cnt].catalog_cd
       SET temp_processing->qual[temp_proc_cnt].priority_cd = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].task_qual[task_cnt].priority_cd
       SET temp_processing->qual[temp_proc_cnt].request_dt_tm = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].task_qual[task_cnt].request_dt_tm
       IF ((inventory->spec_qual[cnt].cassette_qual[cass_cnt].task_qual[task_cnt].task_type_flag=0))
        SET temp_charge_cnt += 1
       ENDIF
     ENDFOR
     SET nbr_slides = cnvtint(size(inventory->spec_qual[cnt].cassette_qual[cass_cnt].slide_qual,5))
     FOR (slide_cnt = 1 TO nbr_slides)
       SET temp_slide_cnt += 1
       IF (mod(temp_slide_cnt,5)=1
        AND temp_slide_cnt != 1)
        SET stat = alterlist(temp_slide->qual,(temp_slide_cnt+ 4))
       ENDIF
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         temp_slide->qual[temp_slide_cnt].slide_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        CALL echo("ERROR adding cassette slide inventory")
        CALL handle_errors("SEQ","F","NEXTVAL","ADDING CASSETTE SLIDE INVENTORY")
        GO TO inventory_failed
       ENDIF
       SET inventory->spec_qual[cnt].cassette_qual[cass_cnt].slide_qual[slide_cnt].slide_id =
       temp_slide->qual[temp_slide_cnt].slide_id
       SET temp_slide->qual[temp_slide_cnt].case_specimen_id = 0
       SET temp_slide->qual[temp_slide_cnt].cassette_id = temp_cassette->qual[temp_cass_cnt].
       cassette_id
       SET temp_slide->qual[temp_slide_cnt].task_assay_cd = inventory->spec_qual[cnt].cassette_qual[
       cass_cnt].slide_qual[slide_cnt].task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].stain_task_assay_cd = inventory->spec_qual[cnt].
       cassette_qual[cass_cnt].slide_qual[slide_cnt].stain_task_assay_cd
       SET temp_slide->qual[temp_slide_cnt].tag_cd = inventory->spec_qual[cnt].cassette_qual[cass_cnt
       ].slide_qual[slide_cnt].tag_cd
       SET nbr_tasks = cnvtint(size(inventory->spec_qual[cnt].cassette_qual[cass_cnt].slide_qual[
         slide_cnt].task_qual,5))
       FOR (task_cnt = 1 TO nbr_tasks)
         SET temp_proc_cnt += 1
         IF (mod(temp_proc_cnt,5)=1
          AND temp_proc_cnt != 1)
          SET stat = alterlist(temp_processing->qual,(temp_proc_cnt+ 4))
         ENDIF
         SELECT INTO "nl:"
          seq_nbr = seq(pathnet_seq,nextval)
          FROM dual
          DETAIL
           temp_processing->qual[temp_proc_cnt].processing_task_id = seq_nbr, inventory->spec_qual[
           cnt].cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].processing_task_id
            = seq_nbr
          WITH format, nocounter
         ;end select
         IF (curqual=0)
          CALL echo("ERROR adding cassette slide task")
          CALL handle_errors("SEQ","F","NEXTVAL","ADDING CASSETTE SLIDE TASK")
          GO TO inventory_failed
         ENDIF
         SET temp_processing->qual[temp_proc_cnt].case_specimen_id = inventory->spec_qual[cnt].
         case_specimen_id
         SET temp_processing->qual[temp_proc_cnt].cassette_id = temp_cassette->qual[temp_cass_cnt].
         cassette_id
         SET temp_processing->qual[temp_proc_cnt].slide_id = temp_slide->qual[temp_slide_cnt].
         slide_id
         SET temp_processing->qual[temp_proc_cnt].case_specimen_tag_cd = inventory->spec_qual[cnt].
         case_specimen_tag_cd
         SET temp_processing->qual[temp_proc_cnt].cassette_tag_cd = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].cassette_tag_cd
         SET temp_processing->qual[temp_proc_cnt].slide_tag_cd = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].tag_cd
         SET temp_processing->qual[temp_proc_cnt].create_inventory_flag = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].create_inventory_flag
         SET temp_processing->qual[temp_proc_cnt].task_assay_cd = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].task_assay_cd
         SET temp_processing->qual[temp_proc_cnt].t_no_charge_ind = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].t_no_charge_ind
         SET temp_processing->qual[temp_proc_cnt].catalog_cd = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].catalog_cd
         SET temp_processing->qual[temp_proc_cnt].priority_cd = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].priority_cd
         SET temp_processing->qual[temp_proc_cnt].request_dt_tm = inventory->spec_qual[cnt].
         cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[task_cnt].request_dt_tm
         IF ((inventory->spec_qual[cnt].cassette_qual[cass_cnt].slide_qual[slide_cnt].task_qual[
         task_cnt].task_type_flag=0))
          SET temp_charge_cnt += 1
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    pt.case_specimen_id
    FROM processing_task pt
    WHERE (pt.case_specimen_id=inventory->spec_qual[cnt].case_specimen_id)
     AND pt.create_inventory_flag=4
    HEAD REPORT
     cur_spec_status_cd = 0.0
    DETAIL
     cur_spec_status_cd = pt.status_cd
    WITH nocounter, forupdate(pt)
   ;end select
   IF (curqual=0)
    CALL echo("ERROR selecting case_spec processing_task")
    CALL handle_errors("SELECT","F","TABLE","PROCESSING_TASK")
    GO TO inventory_failed
   ELSEIF (cur_spec_status_cd != ordered_status_cd)
    SET x += 1
    GO TO cont_loop
   ENDIF
   IF (temp_proc_cnt != temp_charge_cnt)
    UPDATE  FROM processing_task pt
     SET pt.status_cd = processing_status_cd, pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm
       = cnvtdatetime(sysdate),
      pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->
      updt_task,
      pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
     WHERE (pt.case_specimen_id=inventory->spec_qual[cnt].case_specimen_id)
      AND pt.create_inventory_flag=4
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL echo("ERROR updating case_spec processing_task")
     CALL handle_errors("UPDATE","F","TABLE","PROCESSING_TASK")
     GO TO inventory_failed
    ENDIF
   ENDIF
   IF (temp_cass_cnt > 0)
    INSERT  FROM cassette c,
      (dummyt d  WITH seq = value(temp_cass_cnt))
     SET c.cassette_id = temp_cassette->qual[d.seq].cassette_id, c.case_specimen_id = temp_cassette->
      qual[d.seq].case_specimen_id, c.cassette_tag_id = temp_cassette->qual[d.seq].cassette_tag_cd,
      c.task_assay_cd = temp_cassette->qual[d.seq].task_assay_cd, c.fixative_cd = temp_cassette->
      qual[d.seq].fixative_cd, c.pieces = temp_cassette->qual[d.seq].pieces,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task,
      c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (c)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("ERROR inserting cassettes")
     CALL handle_errors("INSERT","F","TABLE","CASSETTE")
     GO TO inventory_failed
    ENDIF
   ENDIF
   IF (temp_slide_cnt > 0)
    INSERT  FROM slide s,
      (dummyt d  WITH seq = value(temp_slide_cnt))
     SET s.slide_id = temp_slide->qual[d.seq].slide_id, s.case_specimen_id = temp_slide->qual[d.seq].
      case_specimen_id, s.cassette_id = temp_slide->qual[d.seq].cassette_id,
      s.task_assay_cd = temp_slide->qual[d.seq].task_assay_cd, s.stain_task_assay_cd = temp_slide->
      qual[d.seq].stain_task_assay_cd, s.tag_id = temp_slide->qual[d.seq].tag_cd,
      s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
      updt_task,
      s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (s)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("ERROR inserting slides")
     CALL handle_errors("INSERT","F","TABLE","SLIDE")
     GO TO inventory_failed
    ENDIF
   ENDIF
   IF (temp_proc_cnt > 0)
    INSERT  FROM processing_task pt,
      (dummyt d  WITH seq = value(temp_proc_cnt))
     SET pt.processing_task_id = temp_processing->qual[d.seq].processing_task_id, pt.case_id =
      request->case_id, pt.case_specimen_id = temp_processing->qual[d.seq].case_specimen_id,
      pt.case_specimen_tag_id = temp_processing->qual[d.seq].case_specimen_tag_cd, pt.cassette_id =
      temp_processing->qual[d.seq].cassette_id, pt.cassette_tag_id = temp_processing->qual[d.seq].
      cassette_tag_cd,
      pt.slide_id = temp_processing->qual[d.seq].slide_id, pt.slide_tag_id = temp_processing->qual[d
      .seq].slide_tag_cd, pt.create_inventory_flag = temp_processing->qual[d.seq].
      create_inventory_flag,
      pt.task_assay_cd = temp_processing->qual[d.seq].task_assay_cd, pt.priority_cd = temp_processing
      ->qual[d.seq].priority_cd, pt.request_dt_tm = cnvtdatetime(temp_processing->qual[d.seq].
       request_dt_tm),
      pt.request_prsnl_id = reqinfo->updt_id, pt.status_cd = ordered_status_cd, pt.status_prsnl_id =
      reqinfo->updt_id,
      pt.status_dt_tm = cnvtdatetime(sysdate), pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id =
      reqinfo->updt_id,
      pt.updt_task = reqinfo->updt_task, pt.updt_cnt = 0, pt.updt_applctx = reqinfo->updt_applctx,
      pt.no_charge_ind = temp_processing->qual[d.seq].t_no_charge_ind
     PLAN (d)
      JOIN (pt)
     WITH nocounter
    ;end insert
    IF (curqual != temp_proc_cnt)
     CALL echo("ERROR inserting processing_tasks")
     CALL handle_errors("INSERT","F","TABLE","PROCESSING_TASK")
     GO TO inventory_failed
    ENDIF
    INSERT  FROM ap_ops_exception aoe,
      (dummyt d  WITH seq = value(temp_proc_cnt))
     SET aoe.parent_id = temp_processing->qual[d.seq].processing_task_id, aoe.action_flag = 4, aoe
      .active_ind = 1,
      aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
       = reqinfo->updt_task,
      aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
     PLAN (d)
      JOIN (aoe
      WHERE (temp_processing->qual[d.seq].processing_task_id=aoe.parent_id)
       AND aoe.action_flag=4)
     WITH nocounter, outerjoin = d, dontexist
    ;end insert
    IF (curqual != temp_proc_cnt)
     CALL echo("ERROR inserting ap_ops_exception")
     CALL handle_errors("INSERT","F","TABLE","AP_OPS_EXCEPTION")
     GO TO inventory_failed
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
      CALL echo("ERROR inserting ap_ops_exception_detail")
      CALL handle_errors("INSERT","F","TABLE","AP_OPS_EXCEPTION_DETAIL")
      GO TO inventory_failed
     ENDIF
    ENDIF
   ENDIF
   SET process_orders = 1
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
 ENDFOR
 IF (interface_flag > 0
  AND tracking_service_resource_cd > 0)
  DECLARE spc_cnt = i4 WITH protect
  DECLARE spc_sld_cnt = i4 WITH protect
  DECLARE spc_sld_tsk = i4 WITH protect
  DECLARE cas_cnt = i4 WITH protect
  DECLARE sld_cnt = i4 WITH protect
  DECLARE sld_tsk = i4 WITH protect
  DECLARE chg_cnt = i4 WITH protect
  DECLARE cnt = i4 WITH protect
  FOR (cnt = 1 TO size(inventory->inventory_data,5))
    FOR (spc_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual,5))
     FOR (spc_sld_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual,5))
       FOR (spc_sld_tsk = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual[
        spc_sld_cnt].task_qual,5))
         SET chg_cnt += 1
         SET stat = alterlist(req200456->qual2,chg_cnt)
         SET req200456->qual2[chg_cnt].processing_task_id = inventory->inventory_data[cnt].spec_qual[
         spc_cnt].slide_qual[spc_sld_cnt].task_qual[spc_sld_tsk].processing_task_id
         SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
       ENDFOR
     ENDFOR
     FOR (cas_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual,5))
       FOR (sld_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[
        cas_cnt].slide_qual,5))
         FOR (sld_tsk = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[
          cas_cnt].slide_qual[sld_cnt].task_qual,5))
           SET chg_cnt += 1
           SET stat = alterlist(req200456->qual2,chg_cnt)
           SET req200456->qual2[chg_cnt].processing_task_id = inventory->inventory_data[cnt].
           spec_qual[spc_cnt].cassette_qual[cas_cnt].slide_qual[sld_cnt].task_qual[sld_tsk].
           processing_task_id
           SET req200456->qual2[chg_cnt].service_resource_cd = tracking_service_resource_cd
         ENDFOR
       ENDFOR
     ENDFOR
    ENDFOR
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
   FOR (cnt = 1 TO size(inventory->inventory_data,5))
     FOR (spc_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual,5))
      FOR (spc_sld_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual,5))
        FOR (spc_sld_tsk = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual[
         spc_sld_cnt].task_qual,5))
          FOR (chg_cnt = 1 TO size(rep200456->qual,5))
            IF ((rep200456->qual[chg_cnt].processing_task_id=inventory->inventory_data[cnt].
            spec_qual[spc_cnt].slide_qual[spc_sld_cnt].task_qual[spc_sld_tsk].processing_task_id)
             AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
             SET inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual[spc_sld_cnt].task_qual[
             spc_sld_tsk].universal_service_ident = rep200456->qual[chg_cnt].universal_service_ident
             SET inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual[spc_sld_cnt].task_qual[
             spc_sld_tsk].placer_field_1 = rep200456->qual[chg_cnt].placer_field_1
             SET inventory->inventory_data[cnt].spec_qual[spc_cnt].slide_qual[spc_sld_cnt].task_qual[
             spc_sld_tsk].suplmtl_serv_info_txt = rep200456->qual[chg_cnt].suplmtl_serv_info_txt
            ENDIF
          ENDFOR
        ENDFOR
      ENDFOR
      FOR (cas_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual,5))
        FOR (sld_cnt = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[
         cas_cnt].slide_qual,5))
          FOR (sld_tsk = 1 TO size(inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[
           cas_cnt].slide_qual[sld_cnt].task_qual,5))
            FOR (chg_cnt = 1 TO size(rep200456->qual,5))
              IF ((rep200456->qual[chg_cnt].processing_task_id=inventory->inventory_data[cnt].
              spec_qual[spc_cnt].cassette_qual[cas_cnt].slide_qual[sld_cnt].task_qual[sld_tsk].
              processing_task_id)
               AND (rep200456->qual[chg_cnt].service_resource_cd=tracking_service_resource_cd))
               SET inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[cas_cnt].
               slide_qual[sld_cnt].task_qual[sld_tsk].universal_service_ident = rep200456->qual[
               chg_cnt].universal_service_ident
               SET inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[cas_cnt].
               slide_qual[sld_cnt].task_qual[sld_tsk].placer_field_1 = rep200456->qual[chg_cnt].
               placer_field_1
               SET inventory->inventory_data[cnt].spec_qual[spc_cnt].cassette_qual[cas_cnt].
               slide_qual[sld_cnt].task_qual[sld_tsk].suplmtl_serv_info_txt = rep200456->qual[chg_cnt
               ].suplmtl_serv_info_txt
              ENDIF
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
     ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF (process_orders=1)
  IF (label_cnt > 0)
   SET req200408->output_dest_cd = request->output_dest_cd
   EXECUTE aps_get_label_info_by_task  WITH replace("REQUEST",req200408), replace("REPLY",reply)
  ENDIF
  IF (size(inventory->spec_qual,5)=0)
   CALL echo("commit_ind = 0")
   SET reqinfo->commit_ind = 0
   CALL handle_errors("GET","F","INVENTORY","SPEC_QUAL")
   GO TO exit_script
  ENDIF
  SET reply->resp_pathologist_id = inventory->resp_pathologist_id
  SET reply->cassette_separator = inventory->cassette_separator
  SET reply->slide_separator = inventory->slide_separator
  SET stat = moverec(inventory->spec_qual,reply->spec_qual)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#interface_failed
 SET reqinfo->commit_ind = 0
 GO TO exit_script
#inventory_failed
 SET reqinfo->commit_ind = 0
 GO TO exit_script
#exit_script
 FREE SET req200456
 FREE SET rep200456
END GO
