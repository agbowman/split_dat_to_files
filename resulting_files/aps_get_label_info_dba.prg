CREATE PROGRAM aps_get_label_info:dba
 RECORD reply(
   1 ops_event = vc
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
 )
 RECORD data(
   1 maxlabel = i2
   1 current_dt_tm_string = c8
   1 resrc[1]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 label[*]
       3 worklist_nbr = i4
       3 service_resource_cd = f8
       3 mnemonic = vc
       3 description = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_string = c8
       3 priority_cd = f8
       3 priority_disp = c15
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 case_specimen_tag_disp = c15
       3 case_specimen_tag_seq = i4
       3 cassette_id = f8
       3 cassette_tag_cd = f8
       3 cassette_tag_disp = c15
       3 cassette_tag_seq = i4
       3 cassette_sep_disp = c1
       3 cassette_origin_modifier = c7
       3 slide_id = f8
       3 slide_tag_cd = f8
       3 slide_tag_disp = c15
       3 slide_tag_seq = i4
       3 slide_sep_disp = c1
       3 slide_origin_modifier = c7
       3 spec_blk_sld_tag_disp = c15
       3 spec_blk_tag_disp = c15
       3 blk_sld_tag_disp = c15
       3 prefix_cd = f8
       3 accession_nbr = c21
       3 fmt_accession_nbr = c21
       3 acc_site_pre_yy_nbr = c21
       3 acc_site = c5
       3 acc_pre = c2
       3 acc_yy = c2
       3 acc_yyyy = c4
       3 acc_nbr = c7
       3 case_year = i4
       3 case_number = i4
       3 responsible_pathologist_id = f8
       3 responsible_pathologist_name_full = vc
       3 responsible_pathologist_name_last = vc
       3 responsible_pathologist_initial = c2
       3 responsible_resident_id = f8
       3 responsible_resident_name_full = vc
       3 responsible_resident_name_last = vc
       3 responsible_resident_initial = c2
       3 requesting_physician_id = f8
       3 requesting_physician_name_full = vc
       3 requesting_physician_name_last = vc
       3 case_received_dt_tm = dq8
       3 case_received_dt_tm_string = c8
       3 case_collect_dt_tm = dq8
       3 case_collect_dt_tm_string = c8
       3 mrn_alias = vc
       3 fin_nbr_alias = vc
       3 encntr_id = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 birth_dt_tm_string = c8
       3 deceased_dt_tm = dq8
       3 age = vc
       3 sex_cd = f8
       3 sex_disp = vc
       3 sex_desc = vc
       3 admit_doc_name = vc
       3 admit_doc_name_last = vc
       3 organization_id = f8
       3 loc_bed_cd = f8
       3 loc_bed_disp = c15
       3 loc_building_cd = f8
       3 loc_building_disp = c15
       3 loc_facility_cd = f8
       3 loc_facility_disp = c15
       3 location_cd = f8
       3 location_disp = c15
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = c15
       3 loc_room_cd = f8
       3 loc_room_disp = c15
       3 loc_nurse_room_bed_disp = vc
       3 encntr_type_cd = f8
       3 encntr_type_disp = c15
       3 encntr_type_desc = vc
       3 adequacy_ind = i2
       3 adequacy_string = vc
       3 specimen_cd = f8
       3 specimen_disp = c15
       3 specimen_description = vc
       3 received_fixative_cd = f8
       3 received_fixative_disp = c15
       3 received_fixative_desc = vc
       3 fixative_added_cd = f8
       3 fixative_added_disp = c15
       3 fixative_added_desc = vc
       3 fixative_cd = f8
       3 fixative_disp = c15
       3 fixative_desc = vc
       3 supplemental_tag = c2
       3 pieces = c3
       3 sl_supplemental_tag = c2
       3 stain_task_assay_cd = f8
       3 stain_mnemonic = vc
       3 stain_description = vc
       3 inventory_type = i2
       3 inventory_code = vc
       3 location_code = vc
       3 compartment_code = vc
       3 spec_tracking_loc_disp = vc
       3 compartment_disp = vc
       3 storage_shelf_disp = vc
       3 organization_name = vc
       3 domain = vc
       3 identifier_type = vc
       3 identifier_code = vc
       3 identifier_disp = vc
       3 hopper = vc
       3 cassette_color = vc
       3 generic_field1 = vc
       3 generic_field2 = vc
       3 generic_field3 = vc
 )
 RECORD printer(
   1 output_dest_cd = f8
   1 name = vc
   1 label_program_prefix = vc
   1 label_program = vc
   1 label_x_pos = i4
   1 label_y_pos = i4
   1 device_cd = f8
   1 flatfile = vc
   1 hopper_name = vc
   1 script = vc
 )
 RECORD temp_inventory(
   1 slide_list[*]
     2 id = f8
 )
#script
 RECORD cdinfo(
   1 fail = i2
   1 code = f8
   1 display = c15
   1 description = c50
   1 meaning = c12
   1 display_key = c15
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
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET data->maxlabel = 0
 SET verified_code = 0.0
 SET ordered_code = 0.0
 SET str_task_assay_where = fillstring(1000," ")
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET billing_task_cd = 0.0
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE llocvalindex = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lorderlistcnt = i4 WITH protect, noconstant(0)
 DECLARE ltempinventorycnt = i4 WITH protect, noconstant(0)
 SET code_set = 5801
 SET cdf_meaning = "APBILLING"
 EXECUTE cpm_get_cd_for_cdf
 SET billing_task_cd = code_value
 CALL cr_createrequest(0,200455,"REQ200455")
 IF (textlen(trim(request->batch_selection)) > 0)
  DECLARE text = c100
  DECLARE real = f8
  DECLARE six = i2
  DECLARE pos = i2
  DECLARE startpos2 = i2
  DECLARE len = i4
  DECLARE endstring = c2
  SUBROUTINE get_text(startpos,textstring,delimit)
    SET siz = size(trim(textstring),1)
    SET pos = startpos
    SET endstring = "F"
    WHILE (pos <= siz)
     IF (substring(pos,1,trim(textstring))=delimit)
      IF (pos=siz)
       SET endstring = "T"
      ENDIF
      SET len = (pos - startpos)
      SET text = substring(startpos,len,trim(textstring))
      SET real = cnvtreal(trim(text))
      SET startpos = (pos+ 1)
      SET startpos2 = (pos+ 1)
      SET pos = siz
     ENDIF
     SET pos += 1
    ENDWHILE
  END ;Subroutine
  SET raw_service_resource_str = fillstring(100," ")
  SET raw_task_assay_str = fillstring(100," ")
  SET raw_task_assay_str_cap = fillstring(100," ")
  SET output_dest = fillstring(100," ")
  SET printer_name = fillstring(100," ")
  SET copies = 0
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), raw_service_resource_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    raw_task_assay_str = trim(text), raw_task_assay_str_cap = cnvtupper(raw_task_assay_str),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->beg_acc = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->end_acc = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->worklist_nbr = cnvtint(trim
     (text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->srun_number = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->stask_status = trim(text),
    request->resend_ind = 1,
    CALL get_text(1,request->output_dist,"|"), output_dest = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"), copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  IF (textlen(trim(raw_service_resource_str)) > 0)
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE 221=cv.code_set
     AND raw_service_resource_str=cv.display
    DETAIL
     request->service_resource_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with service_resource id!"
    GO TO end_script
   ENDIF
  ELSE
   SET request->service_resource_cd = 0
  ENDIF
  IF (textlen(trim(raw_task_assay_str)) > 0)
   SELECT INTO "nl:"
    dta.task_assay_cd
    FROM discrete_task_assay dta
    WHERE raw_task_assay_str_cap=dta.mnemonic_key_cap
    DETAIL
     request->task_assay_cd = dta.task_assay_cd, request->task_assay_disp = dta.mnemonic
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=1310
       AND raw_task_assay_str=cv.display)
     DETAIL
      request->task_assay_cd = cv.code_value, request->task_assay_disp = cv.display
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with task_assay id!"
     GO TO end_script
    ENDIF
   ENDIF
  ELSE
   SET request->task_assay_cd = 0
  ENDIF
  SELECT INTO "nl:"
   o.output_dest_cd
   FROM output_dest o
   WHERE output_dest=o.name
   DETAIL
    request->output_dest_cd = o.output_dest_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dest_id!"
   GO TO end_script
  ENDIF
 ENDIF
 IF ((request->task_assay_cd > 0))
  SELECT INTO "nl:"
   FROM ap_processing_grp_r apgr
   WHERE (request->task_assay_cd=apgr.parent_entity_id)
    AND apgr.parent_entity_name="CODE_VALUE"
   ORDER BY apgr.task_assay_cd
   HEAD REPORT
    str_task_assay_where = "pt.task_assay_cd in ("
   DETAIL
    str_task_assay_where = concat(trim(str_task_assay_where),cnvtstring(apgr.task_assay_cd,32,2),", "
     )
   FOOT REPORT
    templen = textlen(trim(str_task_assay_where)), str_task_assay_where = concat(substring(1,(templen
       - 1),trim(str_task_assay_where)),") ")
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET str_task_assay_where = "pt.task_assay_cd = request->task_assay_cd"
  ENDIF
 ELSE
  SET str_task_assay_where = "0 = 0"
 ENDIF
 IF ((request->beg_acc > " ")
  AND (request->end_acc > " "))
  SET accession_where = "pc.accession_nbr between request->beg_acc and request->end_acc"
 ELSE
  SET accession_where = "0 = 0"
 ENDIF
 IF ((request->beg_acc > " ")
  AND (request->end_acc > " "))
  IF ((request->srun_number="R"))
   SET run_number_where = "pt.worklist_nbr+0 = request->worklist_nbr"
  ELSEIF ((request->srun_number="A"))
   SET run_number_where = "0 = 0"
  ELSEIF ((request->srun_number="U"))
   SET run_number_where = "pt.worklist_nbr+0 = request->worklist_nbr"
  ENDIF
  IF ((request->stask_status="V"))
   SET task_status_where = "pt.status_cd+0 = verified_code"
  ELSEIF ((request->stask_status="U"))
   SET task_status_where = "pt.status_cd+0 = ordered_code"
  ELSEIF ((request->stask_status="B"))
   SET task_status_where = "pt.status_cd+0 in (verified_code, ordered_code)"
  ENDIF
 ELSE
  IF ((request->srun_number IN ("R", "U")))
   SET run_number_where = "pt.worklist_nbr = request->worklist_nbr"
   IF ((request->stask_status="V"))
    SET task_status_where = "pt.status_cd+0 = verified_code"
   ELSEIF ((request->stask_status="U"))
    SET task_status_where = "pt.status_cd+0 = ordered_code"
   ELSEIF ((request->stask_status="B"))
    SET task_status_where = "pt.status_cd+0 in (verified_code, ordered_code)"
   ENDIF
  ELSE
   SET run_number_where = "0 = 0"
   IF ((request->stask_status="V"))
    SET task_status_where = "pt.status_cd = verified_code"
   ELSEIF ((request->stask_status="U"))
    SET task_status_where = "pt.status_cd = ordered_code"
   ELSEIF ((request->stask_status="B"))
    SET task_status_where = "pt.status_cd in (verified_code, ordered_code)"
   ENDIF
  ENDIF
 ENDIF
 SET cntr = 0
 SELECT INTO "nl:"
  rg.child_service_resource_cd, service_resource_disp = uar_get_code_display(rg
   .child_service_resource_cd)
  FROM resource_group rg
  PLAN (rg
   WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
    AND rg.active_ind=1
    AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND rg.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY service_resource_disp
  HEAD REPORT
   cntr += 1, data->resrc[1].service_resource_cd = request->service_resource_cd
  DETAIL
   cntr += 1
   IF (cntr > 1)
    stat = alter(data->resrc,cntr)
   ENDIF
   data->resrc[cntr].service_resource_cd = rg.child_service_resource_cd
  WITH nocounter
 ;end select
 IF (cntr=0)
  SET data->resrc[1].service_resource_cd = request->service_resource_cd
 ENDIF
 SELECT INTO "nl:"
  cv.code_set
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning IN ("ORDERED", "VERIFIED")
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   IF (cv.cdf_meaning="ORDERED")
    ordered_code = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="VERIFIED")
    verified_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt += 1
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->beg_acc > " ")
   AND (request->end_acc > " "))
   PLAN (d)
    JOIN (pc
    WHERE parser(accession_where))
    JOIN (pt
    WHERE (data->resrc[d.seq].service_resource_cd=pt.service_resource_cd)
     AND parser(task_status_where)
     AND parser(str_task_assay_where)
     AND parser(run_number_where)
     AND pt.case_id=pc.case_id)
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (ataa
    WHERE pt.task_assay_cd=ataa.task_assay_cd
     AND 1=ataa.print_label_ind)
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (e
    WHERE pc.encntr_id=e.encntr_id)
    JOIN (dta
    WHERE pt.task_assay_cd=dta.task_assay_cd)
    JOIN (cs
    WHERE pt.case_specimen_id=cs.case_specimen_id)
    JOIN (c
    WHERE pt.cassette_id=c.cassette_id)
    JOIN (s
    WHERE pt.slide_id=s.slide_id)
    JOIN (dta2
    WHERE s.stain_task_assay_cd=dta2.task_assay_cd)
  ELSE
   PLAN (d)
    JOIN (pt
    WHERE (data->resrc[d.seq].service_resource_cd=pt.service_resource_cd)
     AND parser(task_status_where)
     AND parser(str_task_assay_where)
     AND parser(run_number_where))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (ataa
    WHERE pt.task_assay_cd=ataa.task_assay_cd
     AND 1=ataa.print_label_ind)
    JOIN (pc
    WHERE pt.case_id=pc.case_id
     AND parser(accession_where))
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (e
    WHERE pc.encntr_id=e.encntr_id)
    JOIN (dta
    WHERE pt.task_assay_cd=dta.task_assay_cd)
    JOIN (cs
    WHERE pt.case_specimen_id=cs.case_specimen_id)
    JOIN (c
    WHERE pt.cassette_id=c.cassette_id)
    JOIN (s
    WHERE pt.slide_id=s.slide_id)
    JOIN (dta2
    WHERE s.stain_task_assay_cd=dta2.task_assay_cd)
  ENDIF
  INTO "nl:"
  d.seq, pc.accession_nbr, fmt_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(
     pc.accession_nbr,1)),""),
  ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0), ncreateblock = evaluate(pt
   .create_inventory_flag,1,1,2,0,
   3,1,4,0,0,
   0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
   3,1,4,0,0,
   0),
  ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
   tag_id), ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2].
   tag_id), ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].
   tag_id)
  FROM (dummyt d  WITH seq = value(cnvtint(size(data->resrc,5)))),
   processing_task pt,
   order_catalog oc,
   profile_task_r ptr,
   ap_task_assay_addl ataa,
   pathology_case pc,
   person p,
   encounter e,
   discrete_task_assay dta,
   case_specimen cs,
   cassette c,
   slide s,
   discrete_task_assay dta2
  ORDER BY d.seq, pc.accession_nbr, ap_tag_spec_idx,
   ncreatespecimen DESC, ap_tag_cass_idx, pt.cassette_id,
   ncreateblock DESC, ap_tag_slide_idx, pt.slide_id,
   ncreateslide DESC
  HEAD REPORT
   lcnt = 0, ltempinventorycnt = 0
  HEAD d.seq
   lcnt = 0
  HEAD pt.slide_id
   IF (pt.slide_id > 0
    AND s.label_create_dt_tm=null)
    IF (ltempinventorycnt > 0)
     lindex = locateval(llocvalindex,1,ltempinventorycnt,pt.slide_id,temp_inventory->slide_list[
      llocvalindex].id)
    ENDIF
    IF (((ltempinventorycnt=0) OR (lindex=0)) )
     ltempinventorycnt += 1
     IF (ltempinventorycnt > size(temp_inventory->slide_list,5))
      stat = alterlist(temp_inventory->slide_list,(ltempinventorycnt+ 9))
     ENDIF
     temp_inventory->slide_list[ltempinventorycnt].id = pt.slide_id
    ENDIF
   ENDIF
  DETAIL
   lcnt += 1
   IF ((lcnt > data->maxlabel))
    data->maxlabel = lcnt
   ENDIF
   stat = alterlist(data->resrc[d.seq].label,lcnt), data->resrc[d.seq].label[lcnt].priority_cd = pt
   .priority_cd, data->resrc[d.seq].label[lcnt].worklist_nbr = pt.worklist_nbr,
   data->resrc[d.seq].label[lcnt].service_resource_cd = pt.service_resource_cd, data->resrc[d.seq].
   label[lcnt].mnemonic = dta.mnemonic, data->resrc[d.seq].label[lcnt].description = dta.description,
   data->resrc[d.seq].label[lcnt].request_dt_tm = pt.request_dt_tm, data->resrc[d.seq].label[lcnt].
   request_dt_tm_string = format(cnvtdatetime(pt.request_dt_tm),"@SHORTDATE"), data->resrc[d.seq].
   label[lcnt].priority_cd = pt.priority_cd,
   data->resrc[d.seq].label[lcnt].case_specimen_id = pt.case_specimen_id, data->resrc[d.seq].label[
   lcnt].case_specimen_tag_cd = pt.case_specimen_tag_id, data->resrc[d.seq].label[lcnt].cassette_id
    = pt.cassette_id,
   data->resrc[d.seq].label[lcnt].cassette_tag_cd = pt.cassette_tag_id, data->resrc[d.seq].label[lcnt
   ].slide_id = pt.slide_id, data->resrc[d.seq].label[lcnt].slide_tag_cd = pt.slide_tag_id,
   data->resrc[d.seq].label[lcnt].accession_nbr = pc.accession_nbr, data->resrc[d.seq].label[lcnt].
   fmt_accession_nbr = fmt_accession_nbr, data->resrc[d.seq].label[lcnt].prefix_cd = pc.prefix_id,
   data->resrc[d.seq].label[lcnt].case_year = pc.case_year, data->resrc[d.seq].label[lcnt].
   case_number = pc.case_number, data->resrc[d.seq].label[lcnt].responsible_pathologist_id = pc
   .responsible_pathologist_id,
   data->resrc[d.seq].label[lcnt].responsible_resident_id = pc.responsible_resident_id, data->resrc[d
   .seq].label[lcnt].requesting_physician_id = pc.requesting_physician_id, data->resrc[d.seq].label[
   lcnt].case_received_dt_tm = pc.case_received_dt_tm,
   data->resrc[d.seq].label[lcnt].case_received_dt_tm_string = format(cnvtdatetime(pc
     .case_received_dt_tm),"@SHORTDATE"), data->resrc[d.seq].label[lcnt].case_collect_dt_tm = pc
   .case_collect_dt_tm, data->resrc[d.seq].label[lcnt].case_collect_dt_tm_string = format(
    cnvtdatetime(pc.case_collect_dt_tm),"@SHORTDATE"),
   data->resrc[d.seq].label[lcnt].name_full_formatted = p.name_full_formatted, data->resrc[d.seq].
   label[lcnt].name_last = p.name_last, data->resrc[d.seq].label[lcnt].birth_dt_tm = cnvtdatetimeutc(
    datetimezone(p.birth_dt_tm,p.birth_tz),1),
   data->resrc[d.seq].label[lcnt].birth_dt_tm_string = format(cnvtdatetime(data->resrc[d.seq].label[
     lcnt].birth_dt_tm),"@SHORTDATE"), data->resrc[d.seq].label[lcnt].deceased_dt_tm = p
   .deceased_dt_tm, data->resrc[d.seq].label[lcnt].sex_cd = p.sex_cd,
   data->resrc[d.seq].label[lcnt].encntr_id = e.encntr_id, data->resrc[d.seq].label[lcnt].
   organization_id = e.organization_id, data->resrc[d.seq].label[lcnt].person_id = pc.person_id,
   data->resrc[d.seq].label[lcnt].loc_bed_cd = e.loc_bed_cd, data->resrc[d.seq].label[lcnt].
   loc_building_cd = e.loc_building_cd, data->resrc[d.seq].label[lcnt].loc_facility_cd = e
   .loc_facility_cd,
   data->resrc[d.seq].label[lcnt].location_cd = e.location_cd, data->resrc[d.seq].label[lcnt].
   loc_nurse_unit_cd = e.loc_nurse_unit_cd, data->resrc[d.seq].label[lcnt].loc_room_cd = e
   .loc_room_cd,
   data->resrc[d.seq].label[lcnt].encntr_type_cd = e.encntr_type_cd, data->resrc[d.seq].label[lcnt].
   adequacy_ind = cs.adequacy_ind, data->resrc[d.seq].label[lcnt].specimen_cd = cs.specimen_cd,
   data->resrc[d.seq].label[lcnt].specimen_description = cs.specimen_description, data->resrc[d.seq].
   label[lcnt].received_fixative_cd = cs.received_fixative_cd, data->resrc[d.seq].label[lcnt].
   fixative_added_cd = cs.fixative_added_cd,
   data->resrc[d.seq].label[lcnt].fixative_cd = c.fixative_cd, data->resrc[d.seq].label[lcnt].
   supplemental_tag = c.supplemental_tag, data->resrc[d.seq].label[lcnt].cassette_origin_modifier = c
   .origin_modifier,
   data->resrc[d.seq].label[lcnt].pieces = c.pieces, data->resrc[d.seq].label[lcnt].
   sl_supplemental_tag = s.supplemental_tag, data->resrc[d.seq].label[lcnt].stain_task_assay_cd = s
   .stain_task_assay_cd,
   data->resrc[d.seq].label[lcnt].slide_origin_modifier = s.origin_modifier, data->resrc[d.seq].
   label[lcnt].stain_mnemonic = dta2.mnemonic, data->resrc[d.seq].label[lcnt].stain_description =
   dta2.description
   IF ((request->resend_ind > 0))
    IF (pt.slide_id > 0.0)
     lindex = locateval(llocvalindex,1,lorderlistcnt,pt.order_id,req200455->order_list[llocvalindex].
      order_id)
     IF (lindex=0)
      lorderlistcnt += 1
      IF (mod(lorderlistcnt,10)=1)
       stat = alterlist(req200455->order_list,(lorderlistcnt+ 9))
      ENDIF
      req200455->order_list[lorderlistcnt].order_id = pt.order_id
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_inventory->slide_list,ltempinventorycnt)
  WITH nocounter, rdbcboreparse
 ;end select
 IF (lorderlistcnt > 0)
  SET stat = alterlist(req200455->order_list,lorderlistcnt)
  SET req200455->resend_ind = request->resend_ind
  EXECUTE aps_send_instrmt_protocol  WITH replace("REQUEST","REQ200455"), replace("REPLY","REP200455"
   )
 ENDIF
 SET data->current_dt_tm_string = format(cnvtdatetime(sysdate),"mm/dd/yy;;d")
 SELECT INTO "nl:"
  o.output_dest_cd, o.name, o.label_prefix,
  o.label_program_name, o.label_xpos, o.label_ypos
  FROM output_dest o
  WHERE (o.output_dest_cd=request->output_dest_cd)
  DETAIL
   printer->output_dest_cd = o.output_dest_cd, printer->name = o.name, printer->label_program_prefix
    = o.label_prefix,
   printer->label_program = o.label_program_name, printer->label_x_pos = o.label_xpos, printer->
   label_y_pos = o.label_ypos,
   printer->device_cd = o.device_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with output_dest table!"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  d.name
  FROM device d
  PLAN (d
   WHERE (printer->device_cd=d.device_cd))
  DETAIL
   printer_name = trim(d.name)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Failure - Error with device table!"
  GO TO end_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "aps_label", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF ( NOT (validate(label_job_data,0)))
  RECORD label_job_data(
    1 fields[*]
      2 name = vc
      2 size = i2
    1 job_directory = vc
    1 job_file_suffix = vc
    1 format_file_name = vc
    1 printer_name = vc
    1 copies = i4
  )
 ENDIF
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 SET field_cnt = 122
 SET stat = alterlist(label_job_data->fields,field_cnt)
 SET label_job_data->fields[1].name = "NBR_OF_LABELS"
 SET label_job_data->fields[2].name = "LABEL_SEQ"
 SET label_job_data->fields[3].name = "CURRENT_DT_TM_STRING"
 SET label_job_data->fields[4].name = "SERVICE_RESOURCE_CD"
 SET label_job_data->fields[5].name = "SERVICE_RESOURCE_DISP"
 SET label_job_data->fields[6].name = "WORKLIST_NBR"
 SET label_job_data->fields[7].name = "MNEMONIC"
 SET label_job_data->fields[8].name = "DESCRIPTION"
 SET label_job_data->fields[9].name = "REQUEST_DT_TM"
 SET label_job_data->fields[10].name = "REQUEST_DT_TM_STRING"
 SET label_job_data->fields[11].name = "PRIORITY_CD"
 SET label_job_data->fields[12].name = "PRIORITY_DISP"
 SET label_job_data->fields[13].name = "CASE_SPECIMEN_ID"
 SET label_job_data->fields[14].name = "CASE_SPECIMEN_TAG_CD"
 SET label_job_data->fields[15].name = "CASE_SPECIMEN_TAG_DISP"
 SET label_job_data->fields[16].name = "CASSETTE_ID"
 SET label_job_data->fields[17].name = "CASSETTE_TAG_CD"
 SET label_job_data->fields[18].name = "CASSETTE_TAG_DISP"
 SET label_job_data->fields[19].name = "CASSETTE_SEP_DISP"
 SET label_job_data->fields[20].name = "CASSETTE_ORIGIN_MODIFIER"
 SET label_job_data->fields[21].name = "SLIDE_ID"
 SET label_job_data->fields[22].name = "SLIDE_TAG_CD"
 SET label_job_data->fields[23].name = "SLIDE_TAG_DISP"
 SET label_job_data->fields[24].name = "SLIDE_SEP_DISP"
 SET label_job_data->fields[25].name = "SLIDE_ORIGIN_MODIFIER"
 SET label_job_data->fields[26].name = "SPEC_BLK_SLD_TAG_DISP"
 SET label_job_data->fields[27].name = "SPEC_BLK_TAG_DISP"
 SET label_job_data->fields[28].name = "BLK_SLD_TAG_DISP"
 SET label_job_data->fields[29].name = "PREFIX_CD"
 SET label_job_data->fields[30].name = "ACCESSION_NBR"
 SET label_job_data->fields[31].name = "FMT_ACCESSION_NBR"
 SET label_job_data->fields[32].name = "ACC_SITE_PRE_YY_NBR"
 SET label_job_data->fields[33].name = "ACC_SITE"
 SET label_job_data->fields[34].name = "ACC_PRE"
 SET label_job_data->fields[35].name = "ACC_YY"
 SET label_job_data->fields[36].name = "ACC_YYYY"
 SET label_job_data->fields[37].name = "ACC_NBR"
 SET label_job_data->fields[38].name = "CASE_YEAR"
 SET label_job_data->fields[39].name = "CASE_NUMBER"
 SET label_job_data->fields[40].name = "RESPONSIBLE_PATHOLOGIST_ID"
 SET label_job_data->fields[41].name = "RESPONSIBLE_PATHOLOGIST_NAME_FULL"
 SET label_job_data->fields[42].name = "RESPONSIBLE_PATHOLOGIST_NAME_LAST"
 SET label_job_data->fields[43].name = "RESPONSIBLE_PATHOLOGIST_INITIAL"
 SET label_job_data->fields[44].name = "RESPONSIBLE_RESIDENT_ID"
 SET label_job_data->fields[45].name = "RESPONSIBLE_RESIDENT_NAME_FULL"
 SET label_job_data->fields[46].name = "RESPONSIBLE_RESIDENT_NAME_LAST"
 SET label_job_data->fields[47].name = "RESPONSIBLE_RESIDENT_INITIAL"
 SET label_job_data->fields[48].name = "REQUESTING_PHYSICIAN_ID"
 SET label_job_data->fields[49].name = "REQUESTING_PHYSICIAN_NAME_FULL"
 SET label_job_data->fields[50].name = "REQUESTING_PHYSICIAN_NAME_LAST"
 SET label_job_data->fields[51].name = "CASE_RECEIVED_DT_TM"
 SET label_job_data->fields[52].name = "CASE_RECEIVED_DT_TM_STRING"
 SET label_job_data->fields[53].name = "CASE_COLLECT_DT_TM"
 SET label_job_data->fields[54].name = "CASE_COLLECT_DT_TM_STRING"
 SET label_job_data->fields[55].name = "MRN_ALIAS"
 SET label_job_data->fields[56].name = "FIN_NBR_ALIAS"
 SET label_job_data->fields[57].name = "ENCNTR_ID"
 SET label_job_data->fields[58].name = "PERSON_ID"
 SET label_job_data->fields[59].name = "NAME_FULL_FORMATTED"
 SET label_job_data->fields[60].name = "NAME_LAST"
 SET label_job_data->fields[61].name = "BIRTH_DT_TM"
 SET label_job_data->fields[62].name = "BIRTH_DT_TM_STRING"
 SET label_job_data->fields[63].name = "DECEASED_DT_TM"
 SET label_job_data->fields[64].name = "AGE"
 SET label_job_data->fields[65].name = "SEX_CD"
 SET label_job_data->fields[66].name = "SEX_DISP"
 SET label_job_data->fields[67].name = "SEX_DESC"
 SET label_job_data->fields[68].name = "ADMIT_DOC_NAME"
 SET label_job_data->fields[69].name = "ADMIT_DOC_NAME_LAST"
 SET label_job_data->fields[70].name = "ORGANIZATION_ID"
 SET label_job_data->fields[71].name = "LOC_BED_CD"
 SET label_job_data->fields[72].name = "LOC_BED_DISP"
 SET label_job_data->fields[73].name = "LOC_BUILDING_CD"
 SET label_job_data->fields[74].name = "LOC_BUILDING_DISP"
 SET label_job_data->fields[75].name = "LOC_FACILITY_CD"
 SET label_job_data->fields[76].name = "LOC_FACILITY_DISP"
 SET label_job_data->fields[77].name = "LOCATION_CD"
 SET label_job_data->fields[78].name = "LOCATION_DISP"
 SET label_job_data->fields[79].name = "LOC_NURSE_UNIT_CD"
 SET label_job_data->fields[80].name = "LOC_NURSE_UNIT_DISP"
 SET label_job_data->fields[81].name = "LOC_ROOM_CD"
 SET label_job_data->fields[82].name = "LOC_ROOM_DISP"
 SET label_job_data->fields[83].name = "LOC_NURSE_ROOM_BED_DISP"
 SET label_job_data->fields[84].name = "ENCNTR_TYPE_CD"
 SET label_job_data->fields[85].name = "ENCNTR_TYPE_DISP"
 SET label_job_data->fields[86].name = "ENCNTR_TYPE_DESC"
 SET label_job_data->fields[87].name = "ADEQUACY_IND"
 SET label_job_data->fields[88].name = "ADEQUACY_STRING"
 SET label_job_data->fields[89].name = "SPECIMEN_CD"
 SET label_job_data->fields[90].name = "SPECIMEN_DISP"
 SET label_job_data->fields[91].name = "SPECIMEN_DESCRIPTION"
 SET label_job_data->fields[92].name = "RECEIVED_FIXATIVE_CD"
 SET label_job_data->fields[93].name = "RECEIVED_FIXATIVE_DISP"
 SET label_job_data->fields[94].name = "RECEIVED_FIXATIVE_DESC"
 SET label_job_data->fields[95].name = "FIXATIVE_ADDED_CD"
 SET label_job_data->fields[96].name = "FIXATIVE_ADDED_DISP"
 SET label_job_data->fields[97].name = "FIXATIVE_ADDED_DESC"
 SET label_job_data->fields[98].name = "FIXATIVE_CD"
 SET label_job_data->fields[99].name = "FIXATIVE_DISP"
 SET label_job_data->fields[100].name = "FIXATIVE_DESC"
 SET label_job_data->fields[101].name = "SUPPLEMENTAL_TAG"
 SET label_job_data->fields[102].name = "PIECES"
 SET label_job_data->fields[103].name = "SL_SUPPLEMENTAL_TAG"
 SET label_job_data->fields[104].name = "STAIN_TASK_ASSAY_CD"
 SET label_job_data->fields[105].name = "STAIN_MNEMONIC"
 SET label_job_data->fields[106].name = "STAIN_DESCRIPTION"
 SET label_job_data->fields[107].name = "INVENTORY_CODE"
 SET label_job_data->fields[108].name = "LOCATION_CODE"
 SET label_job_data->fields[109].name = "COMPARTMENT_CODE"
 SET label_job_data->fields[110].name = "SPEC_TRACKING_LOC_DISP"
 SET label_job_data->fields[111].name = "STORAGE_SHELF_DISP"
 SET label_job_data->fields[112].name = "COMPARTMENT_DISP"
 SET label_job_data->fields[113].name = "ORGANIZATION_NAME"
 SET label_job_data->fields[114].name = "DOMAIN"
 SET label_job_data->fields[115].name = "IDENTIFIER_TYPE"
 SET label_job_data->fields[116].name = "IDENTIFIER_CODE"
 SET label_job_data->fields[117].name = "IDENTIFIER_DISP"
 SET label_job_data->fields[118].name = "HOPPER"
 SET label_job_data->fields[119].name = "CASSETTE_COLOR"
 SET label_job_data->fields[120].name = "GENERIC_FIELD1"
 SET label_job_data->fields[121].name = "GENERIC_FIELD2"
 SET label_job_data->fields[122].name = "GENERIC_FIELD3"
 EXECUTE value(concat(trim(printer->label_program_prefix),trim(printer->label_program))) reply->
 print_status_data.print_filename
 IF (size(printer->flatfile) > 0)
  IF (validate(printer->script)=1)
   IF (size(printer->script) > 0
    AND checkprg(printer->script) > 0)
    EXECUTE value(printer->script)
   ELSE
    EXECUTE aps_label_rule
   ENDIF
  ELSE
   IF (checkprg("APS_LABEL_RULE") > 0)
    EXECUTE aps_label_rule
   ENDIF
  ENDIF
  EXECUTE value(concat("APS_LABEL_JOB_",printer->flatfile))
  IF ((reply->status_data.status="Z"))
   GO TO end_script
  ELSEIF (ltempinventorycnt > 0)
   IF (trim(printer->flatfile)="NICELABEL")
    IF (updatelabelcreateforslide(3)=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ELSE
    IF (updatelabelcreateforslide(1)=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE (updatelabelcreateforslide(nlabelcreatetype=i2) =i2 WITH protect)
   DECLARE lqualcnt = i4 WITH protect, noconstant(0)
   DECLARE nloopcnt = i4 WITH protect, noconstant(0)
   DECLARE batch_size = i4 WITH protect, constant(20)
   DECLARE lpaddedsize = i4 WITH protect, noconstant(0)
   DECLARE lindex = i4 WITH protect, noconstant(0)
   SET nloopcnt = ceil((cnvtreal(ltempinventorycnt)/ batch_size))
   SET lpaddedsize = (nloopcnt * batch_size)
   SET stat = alterlist(temp_inventory->slide_list,lpaddedsize)
   FOR (lindex = (ltempinventorycnt+ 1) TO lpaddedsize)
     SET temp_inventory->slide_list[lindex].id = temp_inventory->slide_list[ltempinventorycnt].id
   ENDFOR
   SELECT INTO "nl:"
    s.slide_id
    FROM slide s,
     (dummyt d  WITH seq = value(nloopcnt))
    PLAN (d)
     JOIN (s
     WHERE expand(lindex,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),s.slide_id,
      temp_inventory->slide_list[lindex].id))
    HEAD REPORT
     lqualcnt = 0
    DETAIL
     lqualcnt += 1
    WITH nocounter, forupdate(s)
   ;end select
   IF (ltempinventorycnt != lqualcnt)
    CALL handle_errors("LOCK","F","TABLE","SLIDE")
    RETURN(0)
   ENDIF
   UPDATE  FROM slide s,
     (dummyt d  WITH seq = value(ltempinventorycnt))
    SET s.label_create_dt_tm =
     IF (s.label_create_dt_tm=null) cnvtdatetime(sysdate)
     ELSE s.label_create_dt_tm
     ENDIF
     , s.label_create_type_flag = nlabelcreatetype, s.updt_id = reqinfo->updt_id,
     s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (d)
     JOIN (s
     WHERE (s.slide_id=temp_inventory->slide_list[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual != ltempinventorycnt)
    CALL handle_errors("UPDATE","F","TABLE","SLIDE")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reqinfo->commit_ind = 0
  SET reply->ops_event = concat(trim(reply->status_data.subeventstatus[1].operationname),trim(reply->
    status_data.subeventstatus[1].operationstatus),trim(reply->status_data.subeventstatus[1].
    targetobjectname),trim(reply->status_data.subeventstatus[1].targetobjectvalue))
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  IF (textlen(trim(request->output_dist)) > 0
   AND (reply->label_job_data.suppress_spool_ind=0))
   CALL echo("spooling")
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer_name) WITH copy =
   value(copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ENDIF
#end_script
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
 FREE RECORD temp_inventory
END GO
