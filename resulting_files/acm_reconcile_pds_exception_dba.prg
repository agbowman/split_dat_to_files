CREATE PROGRAM acm_reconcile_pds_exception:dba
 DECLARE loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE loadcodevalue(code_set,cdf_meaning,option_flag)
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
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
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
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE loadcodevalue(code_set,cdf_meaning,option_flag)
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
 IF ((validate(bpostdocsubinc,- (9))=- (9)))
  DECLARE bpostdocsubinc = i2 WITH noconstant(false)
  DECLARE checkprocessexception(dpersonid=f8) = i2
  DECLARE checkandlockprocessexception(dpersonid=f8) = i2
  DECLARE releaselockprocessexception(dpersonid=f8) = i2
  DECLARE triggerpdsretrieve(dpersonid=f8) = i2
  DECLARE addschjob(dvalueid=f8,drefid=f8,svaluename=vc,sdocname=vc) = i2
  DECLARE updatemq(dummyvar=i2) = null
  DECLARE getpdsdefinedorg(dummyvar=i2) = null
  DECLARE processdocuments(lindex=i4,dpersonid=f8,dencntrid=f8,dscheventid=f8,dschid=f8,
   dschactionid=f8) = i2
  DECLARE getflexrules(lmode=i4) = i2
  FREE RECORD my_flex_rules
  RECORD my_flex_rules(
    1 mode = i4
    1 qual_cnt = i4
    1 qual[*]
      2 sch_flex_id = f8
      2 mnemonic = vc
      2 description = vc
      2 flex_type_cd = f8
      2 flex_type_meaning = vc
      2 info_sch_text_id = f8
      2 info_sch_text = vc
      2 text_updt_cnt = i4
      2 updt_cnt = i4
      2 active_ind = i2
      2 candidate_id = f8
      2 token_qual_cnt = i4
      2 token_qual[*]
        3 updt_cnt = i4
        3 seq_nbr = i4
        3 flex_orient_cd = f8
        3 flex_orient_mean = c12
        3 flex_token_cd = f8
        3 flex_token_disp = vc
        3 flex_token_mean = c12
        3 token_type_cd = f8
        3 token_type_meaning = c12
        3 data_type_cd = f8
        3 data_type_meaning = c12
        3 data_source_cd = f8
        3 data_source_meaning = c12
        3 flex_eval_cd = f8
        3 flex_eval_meaning = c12
        3 precedence = i4
        3 dynamic_text = vc
        3 oe_field_id = f8
        3 filter_id = f8
        3 filter_table = vc
        3 oe_field_display = vc
        3 dt_tm_value = dq8
        3 string_value = vc
        3 double_value = f8
        3 parent_table = vc
        3 parent_id = f8
        3 parent_meaning = c12
        3 display_table = vc
        3 display_id = f8
        3 display_meaning = c12
        3 mnemonic = vc
        3 description = vc
        3 font_size = i4
        3 font_name = vc
        3 bold = i4
        3 italic = i4
        3 strikethru = i4
        3 underline = i4
        3 candidate_id = f8
        3 offset_units = i4
        3 offset_units_cd = f8
        3 offset_units_meaning = c12
        3 dynamic_xml_text = gvc
        3 found = i2
        3 udf_double_value = f8
        3 udf_string_value = vc
        3 udf_dt_tm_value = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF ((validate(bdebugme,- (9))=- (9)))
   DECLARE bdebugme = i2 WITH noconstant(false)
  ENDIF
  DECLARE s_queuemsg(s_null_index=i2) = vc
  SUBROUTINE s_queuemsg(s_null_index)
    DECLARE smessage = vc WITH protect, noconstant("<ConfirmReq>")
    SET smessage = build(smessage,"<PDSInfo>")
    SET smessage = build(smessage,"<DomainName>")
    SET smessage = build(smessage,reqdata->domain)
    SET smessage = build(smessage,"</DomainName>")
    SET smessage = build(smessage,"<FromOrganizationId>")
    SET smessage = build(smessage,val_reply->def_org_id)
    SET smessage = build(smessage,"</FromOrganizationId>")
    SET smessage = build(smessage,"<NHSNumber>")
    SET smessage = build(smessage,val_reply->nhs_number)
    SET smessage = build(smessage,"</NHSNumber>")
    SET smessage = build(smessage,"</PDSInfo>")
    SET smessage = build(smessage,"<PostDocInfo>")
    SET smessage = build(smessage,"<PersonId>")
    SET smessage = build(smessage,val_req->person_id)
    SET smessage = build(smessage,"</PersonId>")
    SET smessage = build(smessage,"<EncntrId>")
    IF ((val_req->encntr_id > 0.0))
     SET smessage = build(smessage,val_req->encntr_id)
    ELSE
     SET smessage = build(smessage,"0")
    ENDIF
    SET smessage = build(smessage,"</EncntrId>")
    SET smessage = build(smessage,"<PMPostDocId>")
    SET smessage = build(smessage,pdr_reply->list[lfor].pm_post_doc_ref_id)
    SET smessage = build(smessage,"</PMPostDocId>")
    SET smessage = build(smessage,"<DocObjName>")
    SET smessage = build(smessage,pdr_reply->list[lfor].document_object_name)
    SET smessage = build(smessage,"</DocObjName>")
    SET smessage = build(smessage,"<ActionObjName>")
    SET smessage = build(smessage,pdr_reply->list[lfor].action_object_name)
    SET smessage = build(smessage,"</ActionObjName>")
    SET smessage = build(smessage,"<PrintInd>")
    SET smessage = build(smessage,pdr_reply->list[lfor].batch_print_ind)
    SET smessage = build(smessage,"</PrintInd>")
    SET smessage = build(smessage,"<NumCopies>")
    SET smessage = build(smessage,pdr_reply->list[lfor].copies_nbr)
    SET smessage = build(smessage,"</NumCopies>")
    SET smessage = build(smessage,"<OutputDestCd>")
    IF ((pdr_reply->list[lfor].output_dest_cd > 0.0))
     SET smessage = build(smessage,pdr_reply->list[lfor].output_dest_cd)
    ELSE
     SET smessage = build(smessage,"0")
    ENDIF
    SET smessage = build(smessage,"</OutputDestCd>")
    SET smessage = build(smessage,"</PostDocInfo>")
    SET smessage = build(smessage,"</ConfirmReq>")
    RETURN(smessage)
  END ;Subroutine
  IF ((validate(pm_get_pds_pref_def,- (9))=- (9)))
   DECLARE pm_get_pds_pref_def = i2 WITH constant(0)
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
          SET cr_lcharlen = uar_srvgetstringmax(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname)
           )
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
             SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[
              cr_lcnt].siterator)
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
   DECLARE getpdsorgpref(dorgid=f8,bpdsmsg=i2(ref),bpdsconfirm=i2(ref)) = null
   SUBROUTINE getpdsorgpref(dorgid,bpdsmsg,bpdsconfirm)
     DECLARE bpmprefcreatereq = i2 WITH noconstant(false), private
     DECLARE ltotalpref = i4 WITH noconstant(0), private
     DECLARE ltotalentry = i4 WITH noconstant(0), private
     DECLARE ltotalvalue = i4 WITH noconstant(0), private
     DECLARE svalue = vc WITH noconstant(""), private
     DECLARE sorgid = vc WITH noconstant(""), private
     DECLARE lpos = i2 WITH noconstant(0), private
     SET bpdsmsg = false
     SET bpdsconfirm = false
     SET bpmprefcreatereq = cr_createrequest(0,4299400,"pref_request")
     IF (bpmprefcreatereq != true)
      RETURN(false)
     ENDIF
     SET stat = alterlist(pref_request->pref,1)
     SET stat = alterlist(pref_request->pref[1].contexts,2)
     SET pref_request->pref[1].contexts[1].context = "organization"
     SET sorgid = build(dorgid)
     SET lpos = findstring(".",sorgid,1,1)
     SET pref_request->pref[1].contexts[1].context_id = build(substring(1,lpos,sorgid),"00")
     SET pref_request->pref[1].contexts[2].context = "default"
     SET pref_request->pref[1].contexts[2].context_id = "system"
     SET pref_request->pref[1].section = "workflow"
     SET pref_request->pref[1].section_id = "pds messages"
     SET stat = alterlist(pref_request->pref[1].entries,2)
     SET pref_request->pref[1].entries[1].entry = "pds messaging"
     SET pref_request->pref[1].entries[2].entry = "pds confirm message"
     RECORD pref_reply(
       1 pref[*]
         2 section = vc
         2 section_id = vc
         2 subgroup = vc
         2 entries[*]
           3 pref_exists_ind = i2
           3 entry = vc
           3 values[*]
             4 value = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
     IF ((pref_reply->status_data.status="S"))
      SET ltotalpref = size(pref_reply->pref,5)
      IF (ltotalpref > 0)
       SET ltotalentry = size(pref_reply->pref[1].entries,5)
       IF (ltotalentry > 0)
        FOR (lprefcnt = 1 TO ltotalentry)
         IF ((pref_reply->pref[1].entries[lprefcnt].entry="pds messaging")
          AND (pref_reply->pref[1].entries[lprefcnt].pref_exists_ind=true))
          SET ltotalvalue = size(pref_reply->pref[1].entries[lprefcnt].values,5)
          IF (ltotalvalue > 0)
           IF ((pref_reply->pref[1].entries[lprefcnt].values[1].value="1"))
            SET bpdsmsg = true
           ELSE
            SET bpdsmsg = false
           ENDIF
          ENDIF
         ENDIF
         IF ((pref_reply->pref[1].entries[lprefcnt].entry="pds confirm message")
          AND (pref_reply->pref[1].entries[lprefcnt].pref_exists_ind=true))
          SET ltotalvalue = size(pref_reply->pref[1].entries[lprefcnt].values,5)
          IF (ltotalvalue > 0)
           IF ((pref_reply->pref[1].entries[lprefcnt].values[1].value="1"))
            SET bpdsconfirm = true
           ELSE
            SET bpdsconfirm = false
           ENDIF
          ENDIF
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
     IF ((validate(bdebugme,- (99)) != - (99)))
      IF (bdebugme)
       CALL echorecord(pref_reply)
      ENDIF
     ENDIF
     FREE RECORD pref_request
     FREE RECORD pref_reply
   END ;Subroutine
  ENDIF
  SUBROUTINE checkprocessexception(dpersonid)
    DECLARE dholdcomplete = f8 WITH noconstant(0.0)
    DECLARE dexceptvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,"PDSEXCEPTION"))
    DECLARE dstatusvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INPROCESS"))
    SET stat = uar_get_meaning_by_codeset(254591,"HOLDCOMPLETE",1,dholdcomplete)
    IF (dexceptvalue != 0
     AND dstatusvalue != 0)
     SELECT INTO "nl:"
      FROM pm_post_process ppp
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dexceptvalue
       AND ppp.process_status_cd IN (dstatusvalue, dholdcomplete)
       AND ppp.active_ind=1
      WITH nocounter
     ;end select
     IF (bdebugme)
      CALL echo("***PM Inside CheckProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE checkandlockprocessexception(dpersonid)
    DECLARE dsysretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,
      "SYSRETRIEVE"))
    DECLARE dinretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,
      "INRETRIEVE"))
    DECLARE dinerrorvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INERROR"))
    IF (dsysretrievevalue != 0)
     SELECT INTO "nl:"
      FROM pm_post_process ppp
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dsysretrievevalue
       AND ppp.process_status_cd IN (dinretrievevalue, dinerrorvalue)
       AND ppp.active_ind=1
      WITH nocounter, forupdatewait(ppp)
     ;end select
     IF (bdebugme)
      CALL echo("***PM Inside CheckAndLockProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      CALL releaselockprocessexception(dpersonid)
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE releaselockprocessexception(dpersonid)
    DECLARE dsysretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,
      "SYSRETRIEVE"))
    DECLARE dinretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,
      "INRETRIEVE"))
    DECLARE dinerrorvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INERROR"))
    IF (dsysretrievevalue != 0)
     UPDATE  FROM pm_post_process ppp
      SET ppp.person_id = dpersonid
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dsysretrievevalue
       AND ppp.process_status_cd IN (dinretrievevalue, dinerrorvalue)
       AND ppp.active_ind=1
      WITH nocounter
     ;end update
     COMMIT
     IF (bdebugme)
      CALL echo("***PM Inside ReleaseLockProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE triggerpdsretrieve(dpersonid)
    DECLARE dnhsaliascodeforpdsretrieve = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
    DECLARE pdsret_reqid = i4 WITH constant(115604)
    DECLARE hpdsretmsg = i4 WITH noconstant(0)
    DECLARE hpdsretreq = i4 WITH noconstant(0)
    DECLARE hpdsretrep = i4 WITH noconstant(0)
    DECLARE snhsnumber = vc WITH noconstant("")
    SET hpdsretmsg = uar_srvselectmessage(pdsret_reqid)
    IF (hpdsretmsg=0)
     IF (bdebugme)
      CALL echo("***PM TriggerPDSRetrieve - uar_SrvSelectMessage failed")
     ENDIF
     RETURN(false)
    ENDIF
    SET hpdsretreq = uar_srvcreaterequest(hpdsretmsg)
    IF (hpdsretreq=0)
     IF (bdebugme)
      CALL echo("***PM TriggerPDSRetrieve - uar_SrvCreateRequest failed")
     ENDIF
     RETURN(false)
    ENDIF
    SET hpdsretrep = uar_srvcreatereply(hpdsretmsg)
    IF (hpdsretrep=0)
     IF (bdebugme)
      CALL echo("***PM TriggerPDSRetrieve - uar_SrvCreateReply failed")
     ENDIF
     RETURN(false)
    ENDIF
    IF (dnhsaliascodeforpdsretrieve > 0.0)
     SELECT INTO "nl:"
      pa.person_alias_id
      FROM person_alias pa
      WHERE pa.person_id=dpersonid
       AND pa.active_ind=1
       AND pa.person_alias_type_cd=dnhsaliascodeforpdsretrieve
       AND ((pa.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      DETAIL
       snhsnumber = trim(pa.alias,3)
       IF (bdebugme)
        CALL echo(build("NHS number = ",snhsnumber))
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    SET stat = uar_srvsetdouble(hpdsretreq,"patientId",dpersonid)
    SET stat = uar_srvsetstring(hpdsretreq,"nhsNumber",nullterm(snhsnumber))
    SET iret = uar_srvexecute(hpdsretmsg,hpdsretreq,hpdsretrep)
    IF (bdebugme)
     CALL echo("iRet:")
     CALL echo(iret)
     CASE (iret)
      OF 0:
       CALL echo("***PM TriggerPDSRetrieve - Successful Srv Execute ")
      OF 1:
       CALL echo(
        "***PM TriggerPDSRetrieve - Srv Execute failed - Communication Error - Server may be down")
      OF 2:
       CALL echo(
        "***PM TriggerPDSRetrieve - SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
      OF 3:
       CALL echo("Failed to allocate either the Request or Reply Handle")
     ENDCASE
    ENDIF
    IF (iret != 0)
     RETURN(false)
    ENDIF
    CALL uar_srvdestroymessage(hpdsretmsg)
    CALL uar_srvdestroyinstance(hpdsretreq)
    CALL uar_srvdestroyinstance(hpdsretrep)
    RETURN(true)
  END ;Subroutine
  SUBROUTINE addschjob(dvalueid,drefid,svaluename,sdocname)
    IF (bdebugme)
     CALL echo("***PM Calling Insert on AddSchJob")
    ENDIF
    DECLARE djobstatuscd = f8 WITH protect, constant(uar_get_code_by("MEANING",23062,"PERFORM"))
    INSERT  FROM sch_job
     SET active_ind = 1, active_status_cd = reqdata->active_status_cd, active_status_dt_tm =
      cnvtdatetime(curdate,curtime),
      active_status_prsnl_id = reqinfo->updt_id, beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      display = "ERM_PMPOSTDOC",
      job_class = sdocname, job_key = "ERM_PMPOSTDOC", job_state_cd = 0.0,
      job_status_cd = djobstatuscd, key_entity_id = drefid, key_entity_name = "PM_POST_DOC_REF",
      parent_entity_id = dvalueid, parent_entity_name = svaluename, request_dt_tm = cnvtdatetime(
       curdate,curtime3),
      sch_job_id = seq(sch_action_seq,nextval), updt_applctx = reqinfo->updt_applctx, updt_cnt = 1,
      updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = reqinfo->updt_id, updt_task = reqinfo->
      updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE getpdsdefinedorg(dummyvar)
    DECLARE pdsdeforg_id = f8 WITH constant(uar_get_code_by("MEANING",20790,"PDSDEFORG"))
    DECLARE bpds = i2 WITH noconstant(false)
    DECLARE bpdsconfirmmsg = i2 WITH noconstant(false)
    DECLARE dnhsaliascode = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
    IF (bdebugme)
     CALL echo("***PM GetPDSDefinedOrg, PDSDEFORG value")
     CALL echo(pdsdeforg_id)
    ENDIF
    IF (pdsdeforg_id > 0.0)
     SELECT INTO "nl:"
      cve.code_value
      FROM code_value_extension cve
      WHERE cve.code_value=pdsdeforg_id
       AND cve.field_name="OPTION"
       AND cve.code_set=20790
      DETAIL
       val_reply->def_org_id = cnvtreal(trim(cve.field_value,3))
       IF ((val_reply->def_org_id > 0.0))
        rec_cnt = (rec_cnt+ 1)
       ENDIF
       IF (bdebugme)
        CALL echo(cve.code_value)
       ENDIF
      WITH nocounter
     ;end select
     IF ((val_reply->def_org_id > 0))
      CALL getpdsorgpref(val_reply->def_org_id,bpds,bpdsconfirmmsg)
      CALL echo(build2("*** PDS Pref = ",bpds))
      IF (bpds=true)
       SET rec_cnt = (rec_cnt+ 1)
      ENDIF
      CALL echo(build2("*** PDS Confirm Pref = ",bpdsconfirmmsg))
      IF (bpdsconfirmmsg=true)
       SET rec_cnt = (rec_cnt+ 1)
      ENDIF
     ENDIF
     CALL echo(build2("*** rec_cnt = ",rec_cnt))
     IF (rec_cnt >= 3)
      IF (dnhsaliascode > 0.0)
       SELECT INTO "nl:"
        pa.person_alias_id
        FROM person_alias pa
        WHERE (pa.person_id=val_req->person_id)
         AND pa.active_ind=1
         AND pa.person_alias_type_cd=dnhsaliascode
         AND ((pa.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
         AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        DETAIL
         mq_flag = true, val_reply->nhs_number = trim(pa.alias,3)
         IF (bdebugme)
          CALL echo(build("NHS number = ",val_reply->nhs_number))
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE updatemq(dummyvar)
    DECLARE strqueuename = c20 WITH noconstant("PM.UK.CORRESPONDENCE")
    DECLARE strdatatype = vc WITH noconstant("MQSTR")
    DECLARE ierr = i4 WITH noconstant(0)
    DECLARE ispecific = i4 WITH noconstant(0)
    SET strqueuemsg = s_queuemsg(1)
    SET mq_flag = uar_si_insert_mq(nullterm(strqueuename),nullterm(strqueuemsg),textlen(nullterm(
       strqueuemsg)),nullterm(strdatatype),ierr,
     ispecific)
    IF (bdebugme)
     CALL echo("** Message generated to be inserted to queue **")
     CALL echo(strqueuemsg)
     CALL echo(build("iErr =",ierr))
    ENDIF
    IF (ierr > 0)
     SET mq_flag = false
    ENDIF
    SET mq_handle = 0
    SET mq_status = 0
    CALL uar_syscreatehandle(mq_handle,mq_status)
    IF (mq_handle != 0)
     IF (ierr > 0)
      CALL uar_sysevent(mq_handle,0,spfmtstring,build("***uar_si_insert_mq() error=",ierr))
     ELSE
      CALL uar_sysevent(mq_handle,2,spfmtstring,build("***PM rules insert ",val_req->person_id,
        " to queue"))
     ENDIF
     CALL uar_sysdestroyhandle(mq_handle)
    ENDIF
  END ;Subroutine
  SUBROUTINE processdocuments(lindex,dpersonid,dencntrid,dscheventid,dschid,dschactionid)
    DECLARE dskipdecprint207902cd = f8 WITH protect, constant(uar_get_code_by("MEANING",207902,
      "SKIPDECPRINT"))
    DECLARE bpatientdeceased = i2 WITH protect, noconstant(false)
    DECLARE blank_date = dq8 WITH protect, noconstant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
    IF (dskipdecprint207902cd > 0.0)
     SELECT INTO "nl:"
      p.person_id
      FROM person p
      PLAN (p
       WHERE p.person_id=dpersonid
        AND ((p.deceased_dt_tm+ 0) != null)
        AND ((p.deceased_dt_tm+ 0) > cnvtdatetime(blank_date)))
      DETAIL
       bpatientdeceased = true
      WITH nocounter
     ;end select
     IF (bpatientdeceased=true)
      RETURN(true)
     ENDIF
    ENDIF
    IF (textlen(trim(pdr_reply->list[lindex].document_object_name,3)) > 0)
     IF (bdebugme)
      CALL echo(build2("** Document Object: ",trim(pdr_reply->list[lindex].document_object_name,3)))
     ENDIF
     FREE RECORD pdd_req
     RECORD pdd_req(
       1 mode = i2
       1 pm_post_doc[*]
         2 action_flag = i4
         2 parent_entity_name = c32
         2 parent_entity_id = f8
         2 pm_post_doc_id = f8
         2 pm_post_doc_ref_id = f8
         2 manual_create_ind = i2
         2 print_dt_tm = dq8
         2 create_dt_tm = dq8
         2 schedule_id = f8
         2 sch_action_id = f8
     )
     FREE RECORD pdd_reply
     RECORD pdd_reply(
       1 mode = i2
       1 pm_post_doc[*]
         2 pm_post_doc_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET stat = alterlist(pdd_req->pm_post_doc,1)
     SET pdd_req->pm_post_doc[1].action_flag = 3
     IF (dscheventid > 0)
      SET pdd_req->pm_post_doc[1].parent_entity_name = "SCH_EVENT"
      SET pdd_req->pm_post_doc[1].parent_entity_id = dscheventid
     ELSEIF (dencntrid > 0)
      SET pdd_req->pm_post_doc[1].parent_entity_name = "ENCOUNTER"
      SET pdd_req->pm_post_doc[1].parent_entity_id = dencntrid
     ELSE
      SET pdd_req->pm_post_doc[1].parent_entity_name = "PERSON"
      SET pdd_req->pm_post_doc[1].parent_entity_id = dpersonid
     ENDIF
     SET pdd_req->pm_post_doc[1].schedule_id = dschid
     SET pdd_req->pm_post_doc[1].sch_action_id = dschactionid
     SET pdd_req->pm_post_doc[1].pm_post_doc_ref_id = pdr_reply->list[lindex].pm_post_doc_ref_id
     IF (bdebugme)
      CALL echo("** Calling pm_ens_post_doc **")
     ENDIF
     EXECUTE pm_ens_post_doc  WITH replace("REQUEST","PDD_REQ"), replace("REPLY","PDD_REPLY")
     IF ((pdd_reply->status_data.status != "S"))
      SET reply->status_data.subeventstatus[1].operationname = spfmtstring
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PM_ENS_POST_DOC"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to pm_ens_post_doc failed"
      RETURN(false)
     ENDIF
     IF (bdebugme)
      CALL echo("** pm_ens_post_doc reply **")
      CALL echorecord(pdd_reply)
     ENDIF
    ENDIF
    IF (((textlen(trim(pdr_reply->list[lfor].document_object_name,3)) > 0) OR (textlen(trim(pdr_reply
      ->list[lfor].action_object_name,3)) > 0)) )
     IF ((pdd_reply->pm_post_doc[1].pm_post_doc_id > 0))
      IF (bdebugme)
       CALL echo(build2("** Action Object: ",trim(pdr_reply->list[lindex].action_object_name,3)))
      ENDIF
      FREE RECORD gen_req
      RECORD gen_req(
        1 pm_post_doc_id = f8
        1 person_id = f8
        1 encntr_id = f8
        1 sch_event_id = f8
        1 schedule_id = f8
        1 document_object_name = vc
        1 action_object_name = vc
        1 print_ind = i2
        1 copies_nbr = i4
        1 output_dest_cd = f8
        1 running_from_ops_ind = i2
      )
      FREE RECORD gen_reply
      RECORD gen_reply(
        1 mode = i2
        1 list[*]
          2 pm_post_doc_id = f8
          2 doc_file_dir = vc
          2 doc_file_name = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      SET gen_req->person_id = dpersonid
      SET gen_req->encntr_id = dencntrid
      IF (dscheventid > 0)
       SET gen_req->sch_event_id = dscheventid
      ENDIF
      IF (dschid > 0)
       SET gen_req->schedule_id = dschid
      ENDIF
      IF ((validate(pdd_reply->mode,- (9)) != - (9)))
       SET gen_req->pm_post_doc_id = pdd_reply->pm_post_doc[1].pm_post_doc_id
      ENDIF
      IF (textlen(trim(pdr_reply->list[lindex].document_object_name,3)) > 0)
       SET gen_req->document_object_name = pdr_reply->list[lindex].document_object_name
      ELSE
       SET gen_req->document_object_name = ""
      ENDIF
      IF (textlen(trim(pdr_reply->list[lindex].action_object_name,3)) > 0)
       SET gen_req->action_object_name = pdr_reply->list[lindex].action_object_name
      ELSE
       SET gen_req->action_object_name = ""
      ENDIF
      IF ((pdr_reply->list[lindex].batch_print_ind != true))
       SET gen_req->print_ind = true
       SET gen_req->copies_nbr = pdr_reply->list[lindex].copies_nbr
       IF ((pdr_reply->list[lindex].output_dest_cd > 0))
        SET gen_req->output_dest_cd = pdr_reply->list[lindex].output_dest_cd
       ELSE
        IF ((validate(requestin->request.output_dest_cd,- (99.0)) != - (99.0)))
         SET gen_req->output_dest_cd = requestin->request.output_dest_cd
        ELSE
         IF ((validate(requestin->request.pm_output_dest_cd,- (99.0)) != - (99.0)))
          SET gen_req->output_dest_cd = requestin->request.pm_output_dest_cd
         ENDIF
        ENDIF
       ENDIF
       IF (bdebugme)
        CALL echo(build2("** Output_dest_cd:",gen_req->output_dest_cd))
       ENDIF
      ENDIF
      IF (bdebugme)
       CALL echo("** pm_gen_post_doc request **")
       CALL echorecord(gen_req)
      ENDIF
      EXECUTE pm_gen_post_doc  WITH replace("REQUEST","GEN_REQ"), replace("REPLY","GEN_REPLY")
      IF ((gen_reply->status_data.status != "S"))
       SET reply->status_data.subeventstatus[1].operationname = spfmtstring
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "PM_GEN_POST_DOC"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to pm_gen_post_doc failed"
       RETURN(false)
      ENDIF
      IF (bdebugme)
       CALL echo("** pm_gen_post_doc reply **")
       CALL echorecord(gen_reply)
      ENDIF
      RETURN(true)
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE getflexrules(lmode)
    IF (bdebugme)
     CALL echo("*** GetFlexRules - Start ***")
    ENDIF
    DECLARE bflexdone = i2 WITH noconstant(false)
    DECLARE lflextotal = i4 WITH noconstant(0)
    DECLARE lflextemp = i4 WITH noconstant(0)
    DECLARE lflextemp2 = i4 WITH noconstant(0)
    DECLARE lloop = i4 WITH noconstant(0)
    DECLARE lloop2 = i4 WITH noconstant(0)
    DECLARE lloop3 = i4 WITH noconstant(0)
    DECLARE llistsize = i4 WITH noconstant(0)
    DECLARE llistsize2 = i4 WITH noconstant(0)
    DECLARE lsizecnt = i4 WITH noconstant(0)
    IF ((validate(my_flex_rules->mode,- (99))=- (99)))
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "my_flex_rules structure does not exist"
     RETURN(false)
    ENDIF
    SET llistsize = my_flex_rules->qual_cnt
    IF (llistsize <= 0)
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "lListSize = 0"
     RETURN(false)
    ENDIF
    FREE RECORD sch_flex_by_id_req
    RECORD sch_flex_by_id_req(
      1 call_echo_ind = i2
      1 qual[*]
        2 sch_flex_id = f8
      1 mode = i2
    )
    SET sch_flex_by_id_req->mode = 1
    SET stat = alterlist(sch_flex_by_id_req->qual,llistsize)
    FOR (lloop = 1 TO llistsize)
      SET sch_flex_by_id_req->qual[lloop].sch_flex_id = my_flex_rules->qual[lloop].sch_flex_id
    ENDFOR
    IF (bdebugme)
     CALL echo("*** SCH_FLEX_BY_ID_REQ ***")
     CALL echorecord(sch_flex_by_id_req)
    ENDIF
    EXECUTE sch_get_flex_by_id  WITH replace("REQUEST","SCH_FLEX_BY_ID_REQ"), replace("REPLY",
     "MY_FLEX_RULES")
    IF (bdebugme)
     CALL echo("*** my_flex_rules ***")
     CALL echorecord(my_flex_rules)
    ENDIF
    IF ((my_flex_rules->status_data.status != "S"))
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to sch_get_flex_by_id failed"
     RETURN(false)
    ENDIF
    FOR (lloop = 1 TO llistsize)
      FREE RECORD tempflex
      RECORD tempflex(
        1 list[*]
          2 sch_flex_id = f8
      )
      SET lflextemp = 0
      SET llistsize2 = my_flex_rules->qual[lloop].token_qual_cnt
      FOR (lloop2 = 1 TO llistsize2)
        IF (trim(my_flex_rules->qual[lloop].token_qual[lloop2].flex_token_mean,3)="D_FLEXSTRING")
         SET lflextemp = (lflextemp+ 1)
         SET stat = alterlist(tempflex->list,lflextemp)
         SET tempflex->list[lflextemp].sch_flex_id = my_flex_rules->qual[lloop].token_qual[lloop2].
         parent_id
        ENDIF
      ENDFOR
      SET bflexdone = false
      WHILE (bflexdone != true)
        IF (lflextemp > 0)
         SET lflextotal = lflextemp
         FREE RECORD sch_flex_req
         RECORD sch_flex_req(
           1 call_echo_ind = i2
           1 qual[*]
             2 sch_flex_id = f8
           1 mode = i2
         )
         SET sch_flex_req->mode = 1
         SET stat = alterlist(sch_flex_req->qual,lflextotal)
         FOR (lflextemp = 1 TO lflextotal)
           SET sch_flex_req->qual[lflextemp].sch_flex_id = tempflex->list[lflextemp].sch_flex_id
         ENDFOR
         FREE RECORD sch_flex_reply
         RECORD sch_flex_reply(
           1 qual_cnt = i4
           1 qual[*]
             2 sch_flex_id = f8
             2 mnemonic = vc
             2 description = vc
             2 flex_type_cd = f8
             2 flex_type_meaning = vc
             2 info_sch_text_id = f8
             2 info_sch_text = vc
             2 text_updt_cnt = i4
             2 updt_cnt = i4
             2 active_ind = i2
             2 candidate_id = f8
             2 token_qual_cnt = i4
             2 token_qual[*]
               3 updt_cnt = i4
               3 seq_nbr = i4
               3 flex_orient_cd = f8
               3 flex_orient_mean = c12
               3 flex_token_cd = f8
               3 flex_token_disp = vc
               3 flex_token_mean = c12
               3 token_type_cd = f8
               3 token_type_meaning = c12
               3 data_type_cd = f8
               3 data_type_meaning = c12
               3 data_source_cd = f8
               3 data_source_meaning = c12
               3 flex_eval_cd = f8
               3 flex_eval_meaning = c12
               3 precedence = i4
               3 dynamic_text = vc
               3 oe_field_id = f8
               3 filter_id = f8
               3 filter_table = vc
               3 oe_field_display = vc
               3 dt_tm_value = dq8
               3 string_value = vc
               3 double_value = f8
               3 parent_table = vc
               3 parent_id = f8
               3 parent_meaning = c12
               3 display_table = vc
               3 display_id = f8
               3 display_meaning = c12
               3 mnemonic = vc
               3 description = vc
               3 font_size = i4
               3 font_name = vc
               3 bold = i4
               3 italic = i4
               3 strikethru = i4
               3 underline = i4
               3 candidate_id = f8
               3 offset_units = i4
               3 offset_units_cd = f8
               3 offset_units_meaning = c12
               3 dynamic_xml_text = gvc
               3 found = i2
               3 udf_double_value = f8
               3 udf_string_value = vc
               3 udf_dt_tm_value = dq8
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
         IF (bdebugme)
          CALL echo("*** SCH_FLEX_REQ ***")
          CALL echorecord(sch_flex_req)
         ENDIF
         EXECUTE sch_get_flex_by_id  WITH replace("REQUEST","SCH_FLEX_REQ"), replace("REPLY",
          "SCH_FLEX_REPLY")
         IF (bdebugme)
          CALL echo("*** SCH_FLEX_REPLY ***")
          CALL echorecord(sch_flex_reply)
         ENDIF
         IF ((sch_flex_reply->status_data.status != "S"))
          SET reply->status_data.subeventstatus[1].targetobjectname = "PFMT_PM_RULES_*"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
          SET reply->status_data.subeventstatus[1].targetobjectvalue =
          "Call to sch_get_flex_by_id 2 failed"
          RETURN(false)
         ENDIF
         FREE RECORD tempflex
         RECORD tempflex(
           1 list[*]
             2 sch_flex_id = f8
         )
         SET lflextemp2 = 0
         FOR (lflextemp = 1 TO sch_flex_reply->qual_cnt)
          SET llistsize2 = sch_flex_reply->qual[lflextemp].token_qual_cnt
          IF (llistsize2 > 0)
           FOR (lloop3 = 1 TO llistsize2)
             IF (trim(sch_flex_reply->qual[lflextemp].token_qual[lloop3].flex_token_mean,3)=
             "D_FLEXSTRING")
              SET lflextemp2 = (lflextemp2+ 1)
              SET stat = alterlist(tempflex->list,lflextemp2)
              SET tempflex->list[lflextemp2].sch_flex_id = sch_flex_reply->qual[lflextemp].
              token_qual[lloop3].parent_id
             ENDIF
             SET lloop2 = (my_flex_rules->qual[lloop].token_qual_cnt+ 1)
             SET my_flex_rules->qual[lloop].token_qual_cnt = lloop2
             SET stat = alterlist(my_flex_rules->qual[lloop].token_qual,lloop2)
             SET my_flex_rules->qual[lloop].token_qual[lloop2].flex_token_mean = sch_flex_reply->
             qual[lflextemp].token_qual[lloop3].flex_token_mean
             SET my_flex_rules->qual[lloop].token_qual[lloop2].data_type_meaning = sch_flex_reply->
             qual[lflextemp].token_qual[lloop3].data_type_meaning
             SET my_flex_rules->qual[lloop].token_qual[lloop2].double_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].double_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].string_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].string_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].dt_tm_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].dt_tm_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].filter_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].filter_id
             SET my_flex_rules->qual[lloop].token_qual[lloop2].oe_field_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].oe_field_id
             SET my_flex_rules->qual[lloop].token_qual[lloop2].parent_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].parent_id
           ENDFOR
          ENDIF
         ENDFOR
         SET lflextemp = 0
         IF (lflextemp2 > 0)
          SET lflextemp = lflextemp2
         ELSE
          SET bflexdone = true
         ENDIF
        ELSE
         SET bflexdone = true
        ENDIF
      ENDWHILE
    ENDFOR
    IF (bflexdone)
     IF (bdebugme)
      CALL echo("*** my_flex_rules After Flex String Check ***")
      CALL echorecord(my_flex_rules)
     ENDIF
    ENDIF
    FREE RECORD sch_flex_by_id_req
    FREE RECORD sch_flex_req
    FREE RECORD sch_flex_reply
    FREE RECORD tempflex
    RETURN(true)
  END ;Subroutine
 ENDIF
 DECLARE complete_post_processing(person_id=f8,complete_status=vc(ref)) = null
 DECLARE complete_pds_exception(pds_exception_id=f8,person_id=f8,source_version_number=vc,
  complete_status=vc(ref)) = f8
 DECLARE process_pending_documents(person_id=f8,complete_status=vc(ref)) = f8
 DECLARE update_nhs_status_cd(nhs_status_cd=f8,person_alias_id=f8,complete_status=vc(ref)) = null
 DECLARE ppp_type_cd = f8 WITH protect, constant(loadcodevalue(30700,"PDSEXCEPTION",0))
 DECLARE sys_retrieve_cd = f8 WITH protect, constant(loadcodevalue(30700,"SYSRETRIEVE",0))
 DECLARE proc_stat_cd_complete = f8 WITH protect, constant(loadcodevalue(254591,"COMPLETE",0))
 DECLARE in_retrieve_cd = f8 WITH protect, constant(loadcodevalue(254591,"INRETRIEVE",0))
 DECLARE in_error_cd = f8 WITH protect, constant(loadcodevalue(254591,"INERROR",0))
 DECLARE in_printing_cd = f8 WITH protect, constant(loadcodevalue(254591,"INPRINTING",0))
 DECLARE skip_dec_print_cd = f8 WITH protect, constant(loadcodevalue(207902,"SKIPDECPRINT",1))
 DECLARE temp_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE temp_pds_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE comparison_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE min_sentinel_date = dq8 WITH protect, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 SUBROUTINE complete_post_processing(person_id,complete_status)
   SET complete_status->status = "S"
   IF ((request->person_id=0))
    EXECUTE sch_msgview "ACM_COMPLETE_PDS_EXCEPTION", nullterm(build(
      "***** ACM_COMPLETE_PDS_EXCEPTION - no person_id complete_post_processing stopped")), 1
    RETURN
   ENDIF
   RECORD pds_exceptions(
     1 pds_exception_cnt = i4
     1 pds_exception_list[*]
       2 pds_exception_id = f8
       2 updt_status = i2
   )
   SELECT INTO "nl:"
    FROM pm_post_process ppp
    WHERE ppp.person_id=person_id
     AND ppp.pm_post_process_type_cd=sys_retrieve_cd
     AND ppp.active_ind=1
    HEAD REPORT
     pds_exception_cnt = 0
    DETAIL
     pds_exception_cnt = (pds_exception_cnt+ 1)
     IF (mod(pds_exception_cnt,10)=1)
      stat = alterlist(pds_exceptions->pds_exception_list,(pds_exception_cnt+ 9))
     ENDIF
     pds_exceptions->pds_exception_list[pds_exception_cnt].pds_exception_id = ppp.pm_post_process_id
    FOOT REPORT
     stat = alterlist(pds_exceptions->pds_exception_list,pds_exception_cnt), pds_exceptions->
     pds_exception_cnt = pds_exception_cnt
    WITH nocounter, forupdatewait(ppp)
   ;end select
   IF ((pds_exceptions->pds_exception_cnt > 0))
    UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
      pm_post_process ppp
     SET ppp.process_status_cd = in_printing_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (pds_exceptions->pds_exception_cnt > 0))
      JOIN (ppp
      WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
     WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
    ;end update
    FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
      IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
       SET failed = update_error
       SET table_name = "PM_POST_PROCESS"
       ROLLBACK
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   COMMIT
   CALL process_pending_documents(person_id,complete_status)
   IF ((complete_status->status="F"))
    ROLLBACK
    IF ((pds_exceptions->pds_exception_cnt > 0))
     UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.process_status_cd = in_error_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end update
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = update_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
     COMMIT
    ENDIF
   ELSE
    IF ((pds_exceptions->pds_exception_cnt > 0))
     DELETE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.seq = 1
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end delete
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = delete_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE complete_pds_exception(pds_exception_id,person_id,source_version_number,complete_status)
   SET complete_status->status = "S"
   IF (((person_id > 0
    AND pds_exception_id > 0) OR (person_id=0.0
    AND pds_exception_id=0.0)) )
    SET complete_status->status = "F"
    SET complete_status->operationname =
    "Either the person_id or the pds_exception_id must be populated, not both"
    RETURN
   ENDIF
   FREE RECORD pds_exceptions
   RECORD pds_exceptions(
     1 pds_exception_cnt = i4
     1 pds_exception_list[*]
       2 pds_exception_id = f8
       2 updt_status = i2
   )
   IF (person_id > 0)
    SELECT INTO "nl:"
     FROM pm_post_process ppp
     WHERE ppp.person_id=person_id
      AND ppp.pm_post_process_type_cd=ppp_type_cd
      AND ppp.active_ind=1
     HEAD REPORT
      pds_exception_cnt = 0
     DETAIL
      pds_exception_cnt = (pds_exception_cnt+ 1)
      IF (ppp.comparison_person_id > 0)
       comparison_person_id = ppp.comparison_person_id
      ENDIF
      IF (mod(pds_exception_cnt,10)=1)
       stat = alterlist(pds_exceptions->pds_exception_list,(pds_exception_cnt+ 9))
      ENDIF
      pds_exceptions->pds_exception_list[pds_exception_cnt].pds_exception_id = ppp.pm_post_process_id
     FOOT REPORT
      stat = alterlist(pds_exceptions->pds_exception_list,pds_exception_cnt), pds_exceptions->
      pds_exception_cnt = pds_exception_cnt
     WITH nocounter
    ;end select
   ELSEIF (pds_exception_id > 0)
    SET stat = alterlist(pds_exceptions->pds_exception_list,1)
    SET pds_exceptions->pds_exception_list[1].pds_exception_id = pds_exception_id
    SET pds_exceptions->pds_exception_cnt = 1
    SELECT INTO "nl:"
     FROM pm_post_process ppp
     WHERE ppp.pm_post_process_id=pds_exception_id
      AND ppp.pm_post_process_type_cd=ppp_type_cd
      AND ppp.active_ind=1
     DETAIL
      comparison_person_id = ppp.comparison_person_id
     WITH nocounter
    ;end select
   ENDIF
   SET pm_post_process_updt_status = 0
   SET source_version_number_trim = trim(source_version_number)
   FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
     SET temp_pds_exception_id = pds_exceptions->pds_exception_list[index].pds_exception_id
     IF (source_version_number != null
      AND source_version_number_trim != "")
      UPDATE  FROM pm_post_process ppp
       SET ppp.process_status_cd = proc_stat_cd_complete, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
        reqinfo->updt_task,
        ppp.source_version_number = source_version_number_trim, ppp.comparison_person_id = 0
       WHERE ppp.pm_post_process_id=temp_pds_exception_id
        AND ppp.pm_post_process_type_cd=ppp_type_cd
       WITH status(pm_post_process_updt_status)
      ;end update
     ELSE
      UPDATE  FROM pm_post_process ppp
       SET ppp.process_status_cd = proc_stat_cd_complete, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
        reqinfo->updt_task,
        ppp.comparison_person_id = 0
       WHERE ppp.pm_post_process_id=temp_pds_exception_id
        AND ppp.pm_post_process_type_cd=ppp_type_cd
       WITH status(pm_post_process_updt_status)
      ;end update
     ENDIF
     IF (pm_post_process_updt_status <= 0)
      SET complete_status->status = "Z"
      SET complete_status->operationname = "Unable to update PM_POST_PROCESS"
     ENDIF
     DELETE  FROM address a
      WHERE a.parent_entity_id=temp_pds_exception_id
       AND a.parent_entity_name="PM_POST_PROCESS"
     ;end delete
     DELETE  FROM phone ph
      WHERE ph.parent_entity_id=temp_pds_exception_id
       AND ph.parent_entity_name="PM_POST_PROCESS"
     ;end delete
   ENDFOR
   IF (comparison_person_id > 0)
    DELETE  FROM address a
     WHERE a.parent_entity_id=comparison_person_id
      AND a.parent_entity_name="PERSON"
    ;end delete
    DELETE  FROM phone ph
     WHERE ph.parent_entity_id=comparison_person_id
      AND ph.parent_entity_name="PERSON"
    ;end delete
    FREE RECORD acm_request
    RECORD acm_request(
      1 call_echo_ind = i2
      1 force_updt_ind = i2
      1 transaction_info_qual[*]
        2 transaction_id = f8
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 transaction_reason_cd = f8
        2 transaction_reason = vc
        2 transaction = c4
        2 person_id = f8
        2 person_idx = i4
        2 encntr_id = f8
        2 encntr_idx = i4
      1 person_qual[*]
        2 autopsy_cd = f8
        2 beg_effective_dt_tm = dq8
        2 birth_dt_cd = f8
        2 birth_dt_tm = dq8
        2 cause_of_death = vc
        2 cause_of_death_cd = f8
        2 citizenship_cd = f8
        2 conception_dt_tm = dq8
        2 confid_level_cd = f8
        2 contributor_system_cd = f8
        2 data_status_dt_tm = dq8
        2 deceased_cd = f8
        2 deceased_dt_tm = dq8
        2 deceased_source_cd = f8
        2 end_effective_dt_tm = dq8
        2 ethnic_grp_cd = f8
        2 ft_entity_id = f8
        2 ft_entity_idx = i4
        2 ft_entity_name = vc
        2 language_cd = f8
        2 language_dialect_cd = f8
        2 last_encntr_dt_tm = dq8
        2 marital_type_cd = f8
        2 military_base_location = vc
        2 military_rank_cd = f8
        2 military_service_cd = f8
        2 mother_maiden_name = vc
        2 name_first = vc
        2 name_first_key = vc
        2 name_first_phonetic = vc
        2 name_first_synonym_id = f8
        2 name_first_synonym_idx = i4
        2 name_full_formatted = vc
        2 name_last = vc
        2 name_last_key = vc
        2 name_last_phonetic = vc
        2 name_middle = vc
        2 name_middle_key = vc
        2 name_phonetic = vc
        2 nationality_cd = f8
        2 person_id = f8
        2 person_type_cd = f8
        2 race_cd = f8
        2 religion_cd = f8
        2 sex_age_change_ind = i2
        2 sex_cd = f8
        2 species_cd = f8
        2 vet_military_status_cd = f8
        2 vip_cd = f8
        2 action_flag = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 chg_str = vc
        2 data_status_cd = f8
        2 updt_cnt = i4
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 birth_tz = i4
        2 abs_birth_dt_tm = dq8
        2 birth_prec_flag = i4
        2 age_at_death = i4
        2 age_at_death_unit_cd = f8
        2 age_at_death_prec_mod_flag = i4
        2 deceased_tz = i4
        2 deceased_dt_tm_prec_flag = i4
      1 person_name_qual[*]
        2 beg_effective_dt_tm = dq8
        2 contributor_system_cd = f8
        2 end_effective_dt_tm = dq8
        2 name_degree = vc
        2 name_first = vc
        2 name_first_key = vc
        2 name_format_cd = f8
        2 name_full = vc
        2 name_initials = vc
        2 name_last = vc
        2 name_last_key = vc
        2 name_middle = vc
        2 name_middle_key = vc
        2 name_prefix = vc
        2 name_suffix = vc
        2 name_title = vc
        2 name_type_cd = f8
        2 person_id = f8
        2 person_idx = i4
        2 person_name_id = f8
        2 action_flag = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 chg_str = vc
        2 data_status_cd = f8
        2 updt_cnt = i4
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 source_identifier = vc
        2 name_type_seq = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    IF (validate(add_action)=0)
     DECLARE add_action = i2 WITH constant(1)
     DECLARE chg_action = i2 WITH constant(2)
     DECLARE del_action = i2 WITH constant(3)
     DECLARE act_action = i2 WITH constant(4)
     DECLARE ina_action = i2 WITH constant(5)
    ENDIF
    SELECT INTO "nl:"
     pn.person_name_id
     FROM person_name pn
     WHERE pn.person_id=comparison_person_id
     HEAD REPORT
      name_size = 0
     DETAIL
      name_size = (name_size+ 1)
      IF (mod(name_size,10)=1)
       stat = alterlist(acm_request->person_name_qual,(name_size+ 9))
      ENDIF
      acm_request->person_name_qual[name_size].person_name_id = pn.person_name_id, acm_request->
      person_name_qual[name_size].action_flag = del_action
     FOOT REPORT
      stat = alterlist(acm_request->person_name_qual,name_size)
     WITH nocounter
    ;end select
    EXECUTE acm_write_person_name
    IF ((reply->status_data.status="F"))
     SET complete_status->status = "Z"
     SET complete_status->operationname = "failed executing acm_del_person_name"
    ENDIF
    SET stat = alterlist(acm_request->person_qual,1)
    SET acm_request->person_qual[1].person_id = comparison_person_id
    SET acm_request->person_qual[1].action_flag = del_action
    EXECUTE acm_write_person
    IF ((reply->status_data.status="F"))
     SET complete_status->status = "Z"
     SET complete_status->operationname = "failed executing acm_del_person"
    ENDIF
   ENDIF
   IF (pds_exception_id > 0)
    SELECT INTO "nl:"
     ppp.person_id
     FROM pm_post_process ppp
     WHERE ppp.pm_post_process_id=pds_exception_id
     DETAIL
      temp_person_id = ppp.person_id
     WITH nocounter
    ;end select
    IF (temp_person_id <= 0)
     SET complete_status->status = "F"
     SET complete_status->operationname = "No matching person_id for pds_exception_id"
     RETURN
    ENDIF
   ELSE
    SET temp_person_id = person_id
   ENDIF
   IF ((pds_exceptions->pds_exception_cnt > 0))
    UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
      pm_post_process ppp
     SET ppp.process_status_cd = in_printing_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (pds_exceptions->pds_exception_cnt > 0))
      JOIN (ppp
      WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
     WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
    ;end update
    FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
      IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
       SET failed = update_error
       SET table_name = "PM_POST_PROCESS"
       ROLLBACK
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   COMMIT
   CALL process_pending_documents(temp_person_id,complete_status)
   IF ((complete_status->status="F"))
    ROLLBACK
    IF ((pds_exceptions->pds_exception_cnt > 0))
     UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.process_status_cd = in_error_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end update
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = update_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
     COMMIT
    ENDIF
   ELSE
    IF ((pds_exceptions->pds_exception_cnt > 0))
     DELETE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.seq = 1
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end delete
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = delete_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(temp_person_id)
 END ;Subroutine
 SUBROUTINE process_pending_documents(person_id,complete_status)
   FREE RECORD pdr_reply
   RECORD pdr_reply(
     1 mode = i2
     1 list[*]
       2 pm_post_doc_ref_id = f8
       2 prev_pm_post_doc_ref_id = f8
       2 process_name = vc
       2 sch_flex_id = f8
       2 request_number_cd = f8
       2 action_object_name = vc
       2 document_object_name = vc
       2 document_type_cd = f8
       2 output_dest_cd = f8
       2 copies_nbr = i4
       2 time_based_ops_ind = i2
       2 time_based_object_name = vc
       2 batch_print_ind = i2
       2 mnemonic = vc
       2 organizations[*]
         3 organization_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE encounter_cnt = i4 WITH noconstant(0)
   DECLARE lfor = i4 WITH constant(1)
   DECLARE spfmtstring = vc WITH constant("ACM_COMPLETE_PDS_EXCEPTION")
   DECLARE job_status_cd = f8 WITH noconstant(0.0)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE sch_job_cnt = i4 WITH noconstant(0)
   SET stat = uar_get_meaning_by_codeset(23062,"PERFORM",1,job_status_cd)
   FREE RECORD sch_job_xref
   RECORD sch_job_xref(
     1 sch_jobs[*]
       2 sch_job_id = f8
       2 parent_entity_id = f8
       2 parent_entity_name = c32
       2 pm_post_doc_ref_id = f8
       2 encounter_id = f8
   )
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id
    FROM sch_job sj
    WHERE sj.parent_entity_id=person_id
     AND sj.parent_entity_name="PERSON"
     AND trim(sj.job_key)="ERM_PMPOSTDOC"
     AND ((sj.job_status_cd+ 0)=job_status_cd)
     AND ((sj.active_ind+ 0)=1)
     AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    HEAD REPORT
     sch_job_cnt = 0
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt = (sch_job_cnt+ 1), sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id
    FOOT REPORT
     null
   ;end select
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id
    FROM encounter e,
     sch_job sj
    PLAN (e
     WHERE e.person_id=person_id
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((e.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (sj
     WHERE sj.parent_entity_id=e.encntr_id
      AND sj.parent_entity_name="ENCOUNTER"
      AND trim(sj.job_key)="ERM_PMPOSTDOC"
      AND ((sj.job_status_cd+ 0)=job_status_cd)
      AND ((sj.active_ind+ 0)=1)
      AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3)))
    HEAD REPORT
     null
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt = (sch_job_cnt+ 1), sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id
    FOOT REPORT
     null
   ;end select
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id, sep.encntr_id
    FROM sch_event_patient sep,
     sch_job sj
    PLAN (sep
     WHERE sep.person_id=person_id
      AND ((sep.active_ind+ 0)=1)
      AND sep.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ((sep.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (sj
     WHERE sj.parent_entity_id=sep.sch_event_id
      AND sj.parent_entity_name="SCH_EVENT"
      AND trim(sj.job_key)="ERM_PMPOSTDOC"
      AND ((sj.job_status_cd+ 0)=job_status_cd)
      AND ((sj.active_ind+ 0)=1)
      AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3)))
    HEAD REPORT
     null
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt = (sch_job_cnt+ 1), sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id, sch_job_xref->sch_jobs[sch_job_cnt]
     .encounter_id = sep.encntr_id
    FOOT REPORT
     stat = alterlist(sch_job_xref->sch_jobs,sch_job_cnt)
   ;end select
   DECLARE acm_complete_j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE bcreatereq = i2 WITH noconstant(0)
   DECLARE listcnt = i4 WITH noconstant(0)
   DECLARE bprocessdoc = i2 WITH noconstant(0)
   DECLARE is_patient_deceased = i2 WITH protect, noconstant(false)
   IF (skip_dec_print_cd > 0.0)
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     PLAN (p
      WHERE p.person_id=person_id
       AND ((p.deceased_dt_tm+ 0) != null)
       AND ((p.deceased_dt_tm+ 0) > cnvtdatetime(min_sentinel_date)))
     DETAIL
      is_patient_deceased = true
     WITH nocounter
    ;end select
   ENDIF
   IF (is_patient_deceased=false)
    FOR (acm_complete_j = 1 TO sch_job_cnt)
      FREE RECORD pdr_req
      RECORD pdr_req(
        1 action_flag = i4
        1 pm_post_doc_ref_id = f8
        1 document_type_cd = f8
        1 request_number_cd = f8
      )
      SET pdr_req->action_flag = 0
      SET pdr_req->pm_post_doc_ref_id = sch_job_xref->sch_jobs[acm_complete_j].pm_post_doc_ref_id
      EXECUTE pm_get_post_doc_ref  WITH replace("REQUEST","PDR_REQ"), replace("REPLY","PDR_REPLY")
      IF ((pdr_reply->status_data.status != "S"))
       SET complete_status->operationname = "Failure on call to pm_get_post_doc_ref"
       SET complete_status->status = "F"
       RETURN
      ENDIF
      SET listcnt = size(pdr_reply->list,5)
      IF (listcnt > 0)
       IF ((sch_job_xref->sch_jobs[acm_complete_j].parent_entity_name="PERSON"))
        SET bprocessdoc = processdocuments(1,sch_job_xref->sch_jobs[acm_complete_j].parent_entity_id,
         0.0,0.0,0.0,
         0.0)
       ELSEIF ((sch_job_xref->sch_jobs[acm_complete_j].parent_entity_name="ENCOUNTER"))
        SET bprocessdoc = processdocuments(1,person_id,sch_job_xref->sch_jobs[acm_complete_j].
         parent_entity_id,0.0,0.0,
         0.0)
       ELSE
        SET bprocessdoc = processdocuments(1,person_id,sch_job_xref->sch_jobs[acm_complete_j].
         encounter_id,sch_job_xref->sch_jobs[acm_complete_j].parent_entity_id,0.0,
         0.0)
       ENDIF
       IF (bprocessdoc=false)
        SET complete_status->status = "F"
        RETURN
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (sch_job_cnt > 0)
    DELETE  FROM sch_job sj
     WHERE expand(i,1,sch_job_cnt,sj.sch_job_id,sch_job_xref->sch_jobs[i].sch_job_id)
    ;end delete
   ENDIF
   RETURN(person_id)
 END ;Subroutine
 SUBROUTINE update_nhs_status_cd(nhs_status_cd,person_alias_id,complete_status)
   FREE RECORD person_alias_request
   RECORD person_alias_request(
     1 call_echo_ind = i2
     1 person_alias_qual = i4
     1 esi_ensure_type = c3
     1 mode = i2
     1 person_alias[*]
       2 action_type = c3
       2 new_person = c1
       2 person_alias_id = f8
       2 person_id = f8
       2 pm_hist_tracking_id = f8
       2 transaction_dt_tm = dq8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 alias_pool_cd = f8
       2 person_alias_type_cd = f8
       2 alias = vc
       2 person_alias_sub_type_cd = f8
       2 check_digit = i4
       2 check_digit_method_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 data_status_cd = f8
       2 data_status_dt_tm = dq8
       2 data_status_prsnl_id = f8
       2 contributor_system_cd = f8
       2 visit_seq_nbr = i4
       2 health_card_province = c3
       2 health_card_ver_code = c3
       2 health_card_type = c32
       2 health_card_issue_dt_tm = dq8
       2 health_card_expiry_dt_tm = dq8
       2 updt_cnt = i4
       2 assign_authority_sys_cd = f8
       2 person_alias_status_cd = f8
       2 contributor_system_cd = f8
       2 visit_seq_nbr = i4
       2 health_card_province = c3
       2 health_card_ver_code = c3
       2 health_card_type = c32
       2 health_card_issue_dt_tm = dq8
       2 health_card_expiry_dt_tm = dq8
       2 updt_cnt = i4
       2 assign_authority_sys_cd = dq8
       2 person_alias_status_cd = dq8
   )
   SET person_alias_request->person_alias_qual = 1
   SET stat = alterlist(person_alias_request->person_alias,1)
   SET person_alias_request->person_alias[1].action_type = "UPT"
   SET person_alias_request->person_alias[1].person_alias_id = person_alias_id
   SET person_alias_request->person_alias[1].person_id = 0
   SET person_alias_request->person_alias[1].person_alias_type_cd = 0
   SET person_alias_request->person_alias[1].person_alias_status_cd = nhs_status_cd
   SET person_alias_request->person_alias[1].data_status_cd = reqdata->data_status_cd
   SET person_alias_request->person_alias[1].alias = " "
   SET person_alias_request->person_alias[1].health_card_province = " "
   SET person_alias_request->person_alias[1].health_card_ver_code = " "
   SET person_alias_request->person_alias[1].health_card_type = " "
   FREE RECORD person_alias_reply
   RECORD person_alias_reply(
     1 person_alias_qual = i4
     1 person_alias[*]
       2 person_alias_id = f8
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
   EXECUTE pm_upt_person_alias  WITH replace("REQUEST","PERSON_ALIAS_REQUEST"), replace("REPLY",
    "PERSON_ALIAS_REPLY")
   IF ((person_alias_reply->status_data.status="F"))
    SET complete_status->status = "F"
    SET complete_status->operationname = "Failed updating NHS status code"
    RETURN
   ENDIF
 END ;Subroutine
 IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
  DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
  DECLARE s_next_subeventstatus(s_null=i4) = i4
  DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
  DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
  DECLARE s_log_subeventstatus(s_null=i4) = i4
  DECLARE s_clear_subeventstatus(s_null=i4) = i4
  SUBROUTINE s_next_subeventstatus(s_null)
    DECLARE s_stat = i4 WITH private, noconstant(0)
    DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
    IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
    subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
    targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")))
    )) )) )
     SET stx1 = (stx1+ 1)
     SET s_stat = alter(reply->status_data.subeventstatus,stx1)
    ENDIF
    RETURN(stx1)
  END ;Subroutine
  SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
    DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
    SET reply->status_data.subeventstatus[stx1].operationname = s_oname
    SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
    SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
    SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
    RETURN(stx1)
  END ;Subroutine
  SUBROUTINE s_add_subeventstatus_cclerr(s_null)
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
  SUBROUTINE s_log_subeventstatus(s_null)
    DECLARE wi = i4 WITH protect, noconstant(0)
    DECLARE s_curprog = vc WITH protect, constant(curprog)
    FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
      CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].operationname,
         ",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->status_data.
         subeventstatus[wi].targetobjectname,
         ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
    ENDFOR
  END ;Subroutine
  SUBROUTINE s_clear_subeventstatus(s_null)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationname = ""
    SET reply->status_data.subeventstatus[1].operationstatus = ""
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  END ;Subroutine
  DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
  SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 RECORD acm_reconcile_req(
   1 pds_exception_id = f8
   1 birth_info_keep_local_ind = i2
   1 current_name_keep_local_ind = i2
   1 home_address_keep_local_ind = i2
   1 mailing_address_keep_local_ind = i2
   1 temp_address_keep_local_ind = i2
 )
 FREE RECORD acm_registration_req
 RECORD acm_registration_req(
   1 call_echo_ind = i2
   1 use_req_updt_ind = i2
   1 force_updt_ind = i2
   1 transaction_info_qual[*]
     2 transaction_id = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 transaction_reason_cd = f8
     2 transaction_reason = vc
     2 transaction = c4
     2 person_id = f8
     2 person_idx = i4
     2 encntr_id = f8
     2 encntr_idx = i4
   1 address_qual[*]
     2 address_format_cd = f8
     2 address_id = f8
     2 address_info_status_cd = f8
     2 address_type_cd = f8
     2 address_type_seq = i4
     2 beg_effective_dt_tm = dq8
     2 city = vc
     2 contact_name = vc
     2 contributor_system_cd = f8
     2 country = vc
     2 country_cd = f8
     2 county = vc
     2 county_cd = f8
     2 end_effective_dt_tm = dq8
     2 mail_stop = vc
     2 operation_hours = vc
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 postal_barcode_info = vc
     2 residence_cd = f8
     2 residence_type_cd = f8
     2 state = vc
     2 state_cd = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 zipcode = vc
     2 zip_code_group_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 district_health_cd = f8
     2 primary_care_cd = f8
     2 zipcode_key = vc
     2 comment_txt = vc
     2 source_identifier = vc
     2 postal_identifier = vc
     2 postal_identifier_key = vc
   1 encntr_alias_qual[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 beg_effective_dt_tm = dq8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 contributor_system_cd = f8
     2 encntr_alias_id = f8
     2 encntr_alias_sub_type_cd = f8
     2 encntr_alias_type_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 end_effective_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
   1 encntr_code_value_r_qual[*]
     2 code_set = i4
     2 code_value = f8
     2 contributor_system_cd = f8
     2 encntr_code_value_r_id = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 action_flag = i2
     2 chg_str = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 encntr_domain_qual[*]
     2 beg_effective_dt_tm = dq8
     2 encntr_domain_id = f8
     2 encntr_domain_type_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 end_effective_dt_tm = dq8
     2 loc_bed_cd = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 med_service_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
   1 encntr_financial_qual[*]
     2 bill_type_cd = f8
     2 contributor_system_cd = f8
     2 encntr_financial_id = f8
     2 person_id = f8
     2 person_idx = i4
     2 research_account = vc
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 encntr_info_qual[*]
     2 beg_effective_dt_tm = dq8
     2 chartable_ind = i2
     2 contributor_system_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_info_id = f8
     2 end_effective_dt_tm = dq8
     2 info_sub_type_cd = f8
     2 info_type_cd = f8
     2 internal_seq = i4
     2 long_text_id = f8
     2 long_text_idx = i4
     2 priority_seq = i4
     2 value_cd = f8
     2 value_dt_tm = dq8
     2 value_numeric = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
   1 encntr_loc_hist_qual[*]
     2 activity_dt_tm = dq8
     2 arrive_dt_tm = dq8
     2 arrive_prsnl_id = f8
     2 arrive_prsnl_idx = i4
     2 chart_comment_ind = i2
     2 comment_text = vc
     2 depart_dt_tm = dq8
     2 depart_prsnl_id = f8
     2 depart_prsnl_idx = i4
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_loc_hist_id = f8
     2 encntr_type_cd = f8
     2 location_cd = f8
     2 location_status_cd = f8
     2 location_temp_ind = i2
     2 loc_bed_cd = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 med_service_cd = f8
     2 program_service_cd = f8
     2 specialty_unit_cd = f8
     2 transaction_dt_tm = dq8
     2 transfer_reason_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 encntr_org_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_org_alias = vc
     2 encntr_org_nbr = vc
     2 encntr_org_reltn_cd = f8
     2 encntr_org_reltn_id = f8
     2 encntr_org_reltn_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 free_text_ind = i2
     2 ft_org_name = vc
     2 internal_seq = i4
     2 organization_id = f8
     2 organization_idx = i4
     2 priority_seq = i4
     2 research_account_id = f8
     2 research_account_idx = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
   1 encntr_person_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contact_role_cd = f8
     2 contributor_system_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_person_reltn_id = f8
     2 end_effective_dt_tm = dq8
     2 free_text_cd = f8
     2 ft_rel_person_name = vc
     2 genetic_relationship_ind = i2
     2 internal_seq = i4
     2 living_with_ind = i2
     2 person_reltn_cd = f8
     2 person_reltn_type_cd = f8
     2 priority_seq = i4
     2 related_person_id = f8
     2 related_person_idx = i4
     2 related_person_reltn_cd = f8
     2 visitation_allowed_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
   1 encntr_plan_reltn_qual[*]
     2 assign_benefits_cd = f8
     2 beg_effective_dt_tm = dq8
     2 card_category_cd = f8
     2 contributor_system_cd = f8
     2 coord_benefits_cd = f8
     2 coverage_comments_long_text_id = f8
     2 coverage_comments_long_text_idx = i4
     2 deduct_amt = f8
     2 deduct_met_amt = f8
     2 deduct_met_dt_tm = dq8
     2 denial_reason_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_plan_reltn_id = f8
     2 end_effective_dt_tm = dq8
     2 group_name = vc
     2 group_nbr = vc
     2 health_card_expiry_dt_tm = dq8
     2 health_card_issue_dt_tm = dq8
     2 health_card_nbr = vc
     2 health_card_province = vc
     2 health_card_type = vc
     2 health_card_ver_code = vc
     2 health_plan_id = f8
     2 health_plan_idx = i4
     2 insured_card_name = vc
     2 insur_source_info_cd = f8
     2 ins_card_copied_cd = f8
     2 life_rsv_daily_ded_amt = f8
     2 life_rsv_daily_ded_qual_cd = f8
     2 life_rsv_days = i4
     2 life_rsv_remain_days = i4
     2 member_nbr = vc
     2 member_person_code = vc
     2 military_base_location = vc
     2 military_rank_cd = f8
     2 military_service_cd = f8
     2 military_status_cd = f8
     2 organization_id = f8
     2 organization_idx = i4
     2 orig_priority_seq = i4
     2 person_id = f8
     2 person_idx = i4
     2 person_org_reltn_id = f8
     2 person_org_reltn_idx = i4
     2 person_plan_reltn_id = f8
     2 person_plan_reltn_idx = i4
     2 plan_class_cd = f8
     2 plan_type_cd = f8
     2 policy_nbr = vc
     2 priority_seq = i4
     2 program_status_cd = f8
     2 sponsor_person_org_reltn_id = f8
     2 sponsor_person_org_reltn_idx = i4
     2 subscriber_type_cd = f8
     2 subs_member_nbr = vc
     2 verify_dt_tm = dq8
     2 verify_prsnl_id = f8
     2 verify_prsnl_idx = i4
     2 verify_status_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
   1 encntr_prsnl_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 encntr_prsnl_reltn_id = f8
     2 encntr_prsnl_r_cd = f8
     2 end_effective_dt_tm = dq8
     2 expiration_ind = i2
     2 expire_dt_tm = dq8
     2 free_text_cd = f8
     2 ft_prsnl_name = vc
     2 internal_seq = i4
     2 manual_create_by_id = f8
     2 manual_create_by_idx = i4
     2 manual_create_dt_tm = dq8
     2 manual_create_ind = i2
     2 manual_inact_by_id = f8
     2 manual_inact_by_idx = i4
     2 manual_inact_dt_tm = dq8
     2 manual_inact_ind = i2
     2 notification_cd = f8
     2 priority_seq = i4
     2 prsnl_person_id = f8
     2 prsnl_person_idx = i4
     2 transaction_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
   1 encounter_qual[*]
     2 accomp_by_cd = f8
     2 admit_mode_cd = f8
     2 admit_src_cd = f8
     2 admit_type_cd = f8
     2 admit_with_medication_cd = f8
     2 alc_decomp_dt_tm = dq8
     2 alc_reason_cd = f8
     2 alt_lvl_care_cd = f8
     2 alt_lvl_care_dt_tm = dq8
     2 alt_result_dest_cd = f8
     2 ambulatory_cond_cd = f8
     2 arrive_dt_tm = dq8
     2 bbd_procedure_cd = f8
     2 beg_effective_dt_tm = dq8
     2 chart_complete_dt_tm = dq8
     2 confid_level_cd = f8
     2 contributor_system_cd = f8
     2 courtesy_cd = f8
     2 depart_dt_tm = dq8
     2 diet_type_cd = f8
     2 disch_disposition_cd = f8
     2 disch_dt_tm = dq8
     2 disch_to_loctn_cd = f8
     2 doc_rcvd_dt_tm = dq8
     2 encntr_class_cd = f8
     2 encntr_complete_dt_tm = dq8
     2 encntr_financial_id = f8
     2 encntr_financial_idx = i4
     2 encntr_id = f8
     2 encntr_status_cd = f8
     2 encntr_type_cd = f8
     2 encntr_type_class_cd = f8
     2 end_effective_dt_tm = dq8
     2 est_arrive_dt_tm = dq8
     2 est_depart_dt_tm = dq8
     2 est_length_of_stay = i4
     2 financial_class_cd = f8
     2 guarantor_type_cd = f8
     2 info_given_by = vc
     2 isolation_cd = f8
     2 location_cd = f8
     2 loc_bed_cd = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_temp_cd = f8
     2 med_service_cd = f8
     2 mental_health_cd = f8
     2 mental_health_dt_tm = dq8
     2 organization_id = f8
     2 organization_idx = i4
     2 person_id = f8
     2 person_idx = i4
     2 placement_auth_prsnl_id = f8
     2 placement_auth_prsnl_idx = i4
     2 preadmit_nbr = vc
     2 preadmit_testing_cd = f8
     2 pre_reg_dt_tm = dq8
     2 pre_reg_prsnl_id = f8
     2 pre_reg_prsnl_idx = i4
     2 program_service_cd = f8
     2 readmit_cd = f8
     2 reason_for_visit = vc
     2 referral_rcvd_dt_tm = dq8
     2 referring_comment = vc
     2 refer_facility_cd = f8
     2 region_cd = f8
     2 reg_dt_tm = dq8
     2 reg_prsnl_id = f8
     2 reg_prsnl_idx = i4
     2 result_dest_cd = f8
     2 safekeeping_cd = f8
     2 security_access_cd = f8
     2 service_category_cd = f8
     2 sitter_required_cd = f8
     2 specialty_unit_cd = f8
     2 species_cd = f8
     2 trauma_cd = f8
     2 trauma_dt_tm = dq8
     2 triage_cd = f8
     2 triage_dt_tm = dq8
     2 valuables_cd = f8
     2 vip_cd = f8
     2 visitor_status_cd = f8
     2 zero_balance_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 mental_category_cd = f8
     2 patient_classification_cd = f8
     2 psychiatric_status_cd = f8
     2 inpatient_admit_dt_tm = dq8
   1 health_plan_qual[*]
     2 baby_coverage_cd = f8
     2 beg_effective_dt_tm = dq8
     2 comb_baby_bill_cd = f8
     2 end_effective_dt_tm = dq8
     2 financial_class_cd = f8
     2 ft_entity_id = f8
     2 ft_entity_idx = i4
     2 ft_entity_name = vc
     2 group_name = vc
     2 group_nbr = vc
     2 health_plan_id = f8
     2 pat_bill_pref_flag = i4
     2 plan_class_cd = f8
     2 plan_desc = vc
     2 plan_name = vc
     2 plan_type_cd = f8
     2 policy_nbr = vc
     2 pri_concurrent_ind = i2
     2 product_cd = f8
     2 sec_concurrent_ind = i2
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
   1 person_qual[*]
     2 autopsy_cd = f8
     2 beg_effective_dt_tm = dq8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 cause_of_death = vc
     2 cause_of_death_cd = f8
     2 citizenship_cd = f8
     2 conception_dt_tm = dq8
     2 confid_level_cd = f8
     2 contributor_system_cd = f8
     2 data_status_dt_tm = dq8
     2 deceased_cd = f8
     2 deceased_dt_tm = dq8
     2 deceased_source_cd = f8
     2 end_effective_dt_tm = dq8
     2 ethnic_grp_cd = f8
     2 ft_entity_id = f8
     2 ft_entity_idx = i4
     2 ft_entity_name = vc
     2 language_cd = f8
     2 language_dialect_cd = f8
     2 last_encntr_dt_tm = dq8
     2 marital_type_cd = f8
     2 military_base_location = vc
     2 military_rank_cd = f8
     2 military_service_cd = f8
     2 mother_maiden_name = vc
     2 name_first = vc
     2 name_first_key = vc
     2 name_first_phonetic = vc
     2 name_first_synonym_id = f8
     2 name_first_synonym_idx = i4
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_last_key = vc
     2 name_last_phonetic = vc
     2 name_middle = vc
     2 name_middle_key = vc
     2 name_phonetic = vc
     2 nationality_cd = f8
     2 person_id = f8
     2 person_type_cd = f8
     2 race_cd = f8
     2 religion_cd = f8
     2 sex_age_change_ind = i2
     2 sex_cd = f8
     2 species_cd = f8
     2 vet_military_status_cd = f8
     2 vip_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 birth_tz = i4
     2 abs_birth_dt_tm = dq8
     2 birth_prec_flag = i4
     2 age_at_death = i4
     2 age_at_death_unit_cd = f8
     2 age_at_death_prec_mod_flag = i4
     2 deceased_tz = i4
     2 deceased_dt_tm_prec_flag = i4
   1 person_alias_qual[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 assign_authority_sys_cd = f8
     2 beg_effective_dt_tm = dq8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 health_card_expiry_dt_tm = dq8
     2 health_card_issue_dt_tm = dq8
     2 health_card_province = vc
     2 health_card_type = vc
     2 health_card_ver_code = vc
     2 person_alias_id = f8
     2 person_alias_status_cd = f8
     2 person_alias_sub_type_cd = f8
     2 person_alias_type_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 visit_seq_nbr = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
   1 person_code_value_r_qual[*]
     2 code_set = i4
     2 code_value = f8
     2 contributor_system_cd = f8
     2 person_code_value_r_id = f8
     2 person_id = f8
     2 person_idx = i4
     2 action_flag = i2
     2 chg_str = vc
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 person_name_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 name_degree = vc
     2 name_first = vc
     2 name_first_key = vc
     2 name_format_cd = f8
     2 name_full = vc
     2 name_initials = vc
     2 name_last = vc
     2 name_last_key = vc
     2 name_middle = vc
     2 name_middle_key = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 name_title = vc
     2 name_type_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 person_name_id = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 source_identifier = vc
     2 name_type_seq = i4
   1 person_org_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 empl_contact = vc
     2 empl_contact_title = vc
     2 empl_hire_dt_tm = dq8
     2 empl_occupation_cd = f8
     2 empl_occupation_text = vc
     2 empl_position = vc
     2 empl_retire_dt_tm = dq8
     2 empl_status_cd = f8
     2 empl_term_dt_tm = dq8
     2 empl_title = vc
     2 empl_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 free_text_ind = i2
     2 ft_org_name = vc
     2 internal_seq = i4
     2 organization_id = f8
     2 organization_idx = i4
     2 person_id = f8
     2 person_idx = i4
     2 person_org_alias = vc
     2 person_org_nbr = vc
     2 person_org_reltn_cd = f8
     2 person_org_reltn_id = f8
     2 priority_seq = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 source_identifier = vc
   1 person_patient_qual[*]
     2 adopted_cd = f8
     2 bad_debt_cd = f8
     2 birth_length = f8
     2 birth_length_units_cd = f8
     2 birth_multiple_cd = f8
     2 birth_name = vc
     2 birth_order = i4
     2 birth_weight = f8
     2 callback_consent_cd = f8
     2 church_cd = f8
     2 contact_list_cd = f8
     2 contact_method_cd = f8
     2 contact_time = vc
     2 contributor_system_cd = f8
     2 credit_hrs_taking = i4
     2 cumm_leave_days = i4
     2 current_balance = f8
     2 current_grade = i4
     2 custody_cd = f8
     2 degree_complete_cd = f8
     2 diet_type_cd = f8
     2 disease_alert_cd = f8
     2 family_income = f8
     2 family_size = i4
     2 highest_grade_complete_cd = f8
     2 interp_required_cd = f8
     2 interp_type_cd = f8
     2 last_bill_dt_tm = dq8
     2 last_bind_dt_tm = dq8
     2 last_discharge_dt_tm = dq8
     2 last_event_updt_dt_tm = dq8
     2 last_payment_dt_tm = dq8
     2 last_trauma_dt_tm = dq8
     2 living_arrangement_cd = f8
     2 living_dependency_cd = f8
     2 living_will_cd = f8
     2 microfilm_cd = f8
     2 mother_identifier = vc
     2 mother_identifier_cd = f8
     2 nbr_of_brothers = i4
     2 nbr_of_pregnancies = i4
     2 nbr_of_sisters = i4
     2 organ_donor_cd = f8
     2 parent_marital_status_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 process_alert_cd = f8
     2 smokes_cd = f8
     2 student_cd = f8
     2 tumor_registry_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 baptised_cd = f8
     2 gest_age_at_birth = i4
     2 gest_age_method_cd = f8
     2 written_format_cd = f8
     2 prev_contact_ind = i2
     2 birth_order_cd = f8
     2 source_version_number = vc
     2 source_last_sync_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 source_sync_level_flag = i4
   1 person_person_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contact_role_cd = f8
     2 contributor_system_cd = f8
     2 copy_correspondence_cd = f8
     2 end_effective_dt_tm = dq8
     2 free_text_cd = f8
     2 ft_rel_person_name = vc
     2 genetic_relationship_ind = i2
     2 living_with_ind = i2
     2 person_id = f8
     2 person_idx = i4
     2 person_person_reltn_id = f8
     2 person_reltn_cd = f8
     2 person_reltn_type_cd = f8
     2 priority_seq = i4
     2 related_person_id = f8
     2 related_person_idx = i4
     2 related_person_reltn_cd = f8
     2 visitation_allowed_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 source_identifier = vc
     2 relation_seq = i4
   1 person_plan_reltn_qual[*]
     2 balance_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 card_category_cd = f8
     2 card_issue_nbr = i4
     2 contributor_system_cd = f8
     2 coverage_comments_long_text_id = f8
     2 coverage_comments_long_text_idx = i4
     2 coverage_type_cd = f8
     2 deduct_amt = f8
     2 deduct_met_amt = f8
     2 deduct_met_dt_tm = dq8
     2 denial_reason_cd = f8
     2 end_effective_dt_tm = dq8
     2 fam_deduct_met_amt = f8
     2 fam_deduct_met_dt_tm = dq8
     2 group_name = vc
     2 group_nbr = vc
     2 health_plan_id = f8
     2 health_plan_idx = i4
     2 insured_card_name = vc
     2 life_rsv_daily_ded_amt = f8
     2 life_rsv_daily_ded_qual_cd = f8
     2 life_rsv_days = i4
     2 life_rsv_remain_days = i4
     2 max_out_pckt_amt = f8
     2 max_out_pckt_dt_tm = dq8
     2 member_nbr = vc
     2 member_person_code = vc
     2 organization_id = f8
     2 organization_idx = i4
     2 person_id = f8
     2 person_idx = i4
     2 person_org_reltn_id = f8
     2 person_org_reltn_idx = i4
     2 person_plan_reltn_id = f8
     2 person_plan_r_cd = f8
     2 plan_type_cd = f8
     2 policy_nbr = vc
     2 priority_seq = i4
     2 program_status_cd = f8
     2 signature_on_file_cd = f8
     2 sponsor_person_org_reltn_id = f8
     2 sponsor_person_org_reltn_idx = i4
     2 subscriber_person_id = f8
     2 subscriber_person_idx = i4
     2 verify_dt_tm = dq8
     2 verify_prsnl_id = f8
     2 verify_prsnl_idx = i4
     2 verify_status_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
   1 person_prsnl_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 free_text_cd = f8
     2 ft_prsnl_name = vc
     2 internal_seq = i4
     2 manual_create_by_id = f8
     2 manual_create_by_idx = i4
     2 manual_create_dt_tm = dq8
     2 manual_create_ind = i2
     2 manual_inact_by_id = f8
     2 manual_inact_by_idx = i4
     2 manual_inact_dt_tm = dq8
     2 manual_inact_ind = i2
     2 notification_cd = f8
     2 person_id = f8
     2 person_idx = i4
     2 person_prsnl_reltn_id = f8
     2 person_prsnl_r_cd = f8
     2 priority_seq = i4
     2 prsnl_person_id = f8
     2 prsnl_person_idx = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 source_identifier = vc
   1 phone_qual[*]
     2 beg_effective_dt_tm = dq8
     2 call_instruction = vc
     2 contact = vc
     2 contributor_system_cd = f8
     2 description = vc
     2 end_effective_dt_tm = dq8
     2 extension = vc
     2 long_text_id = f8
     2 long_text_idx = i4
     2 modem_capability_cd = f8
     2 operation_hours = vc
     2 paging_code = vc
     2 parent_entity_id = f8
     2 parent_entity_idx = i4
     2 parent_entity_name = vc
     2 phone_format_cd = f8
     2 phone_id = f8
     2 phone_num = vc
     2 phone_type_cd = f8
     2 phone_type_seq = i4
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 data_status_cd = f8
     2 updt_cnt = i4
     2 contact_method_cd = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 source_identifier = vc
   1 service_category_hist_qual[*]
     2 attend_prsnl_id = f8
     2 attend_prsnl_idx = i4
     2 beg_effective_dt_tm = dq8
     2 encntr_id = f8
     2 encntr_idx = i4
     2 end_effective_dt_tm = dq8
     2 med_service_cd = f8
     2 service_category_cd = f8
     2 svc_cat_hist_id = f8
     2 transaction_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
   1 preprocess_qual[*]
     2 prog_name = vc
   1 postprocess_qual[*]
     2 prog_name = vc
   1 person_rx_plan_coverage_qual[*]
     2 beg_service_dt_tm = dq8
     2 coverage_status_cd = f8
     2 end_service_dt_tm = dq8
     2 person_rx_plan_coverage_id = f8
     2 person_rx_plan_reltn_id = f8
     2 person_rx_plan_reltn_idx = i4
     2 service_type_cd = f8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
     2 service_type_txt = vc
   1 person_rx_plan_reltn_qual[*]
     2 beg_effective_dt_tm = dq8
     2 cardholder_first_name = vc
     2 cardholder_ident = vc
     2 cardholder_last_name = vc
     2 contributor_system_cd = f8
     2 data_build_flag = i4
     2 end_effective_dt_tm = dq8
     2 health_plan_id = f8
     2 health_plan_idx = i4
     2 interchange_id = f8
     2 interchange_idx = i4
     2 interchange_seq = i4
     2 patient_unit_number = vc
     2 person_id = f8
     2 person_idx = i4
     2 person_rx_plan_reltn_id = f8
     2 priority_seq = i4
     2 rx_plan_beg_dt_tm = dq8
     2 rx_plan_end_dt_tm = dq8
     2 trans_dt_tm = dq8
     2 verified_by_id = f8
     2 verified_by_idx = i4
     2 verified_dt_tm = dq8
     2 action_flag = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 chg_str = vc
     2 updt_cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 transaction_info_qual_cnt = i4
   1 transaction_info_qual[*]
     2 transaction_id = f8
     2 pm_hist_tracking_id = f8
     2 person_id = f8
     2 person_idx = i4
     2 encntr_id = f8
     2 encntr_idx = i4
     2 status = i2
   1 address_qual_cnt = i4
   1 address_qual[*]
     2 address_id = f8
     2 status = i2
   1 encntr_alias_qual_cnt = i4
   1 encntr_alias_qual[*]
     2 encntr_alias_id = f8
     2 status = i2
   1 encntr_code_value_r_qual_cnt = i4
   1 encntr_code_value_r_qual[*]
     2 encntr_code_value_r_id = f8
     2 status = i2
   1 encntr_domain_qual_cnt = i4
   1 encntr_domain_qual[*]
     2 encntr_domain_id = f8
     2 status = i2
   1 encntr_financial_qual_cnt = i4
   1 encntr_financial_qual[*]
     2 encntr_financial_id = f8
     2 status = i2
   1 encntr_info_qual_cnt = i4
   1 encntr_info_qual[*]
     2 encntr_info_id = f8
     2 status = i2
   1 encntr_loc_hist_qual_cnt = i4
   1 encntr_loc_hist_qual[*]
     2 encntr_loc_hist_id = f8
     2 status = i2
   1 encntr_org_reltn_qual_cnt = i4
   1 encntr_org_reltn_qual[*]
     2 encntr_org_reltn_id = f8
     2 status = i2
   1 encntr_person_reltn_qual_cnt = i4
   1 encntr_person_reltn_qual[*]
     2 encntr_person_reltn_id = f8
     2 status = i2
   1 encntr_plan_reltn_qual_cnt = i4
   1 encntr_plan_reltn_qual[*]
     2 encntr_plan_reltn_id = f8
     2 status = i2
   1 encntr_prsnl_reltn_qual_cnt = i4
   1 encntr_prsnl_reltn_qual[*]
     2 encntr_prsnl_reltn_id = f8
     2 status = i2
   1 encounter_qual_cnt = i4
   1 encounter_qual[*]
     2 encntr_id = f8
     2 status = i2
   1 health_plan_qual_cnt = i4
   1 health_plan_qual[*]
     2 health_plan_id = f8
     2 status = i2
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 status = i2
   1 person_alias_qual_cnt = i4
   1 person_alias_qual[*]
     2 person_alias_id = f8
     2 status = i2
   1 person_code_value_r_qual_cnt = i4
   1 person_code_value_r_qual[*]
     2 person_code_value_r_id = f8
     2 status = i2
   1 person_name_qual_cnt = i4
   1 person_name_qual[*]
     2 person_name_id = f8
     2 status = i2
   1 person_org_reltn_qual_cnt = i4
   1 person_org_reltn_qual[*]
     2 person_org_reltn_id = f8
     2 status = i2
   1 person_patient_qual_cnt = i4
   1 person_patient_qual[*]
     2 person_id = f8
     2 status = i2
   1 person_person_reltn_qual_cnt = i4
   1 person_person_reltn_qual[*]
     2 person_person_reltn_id = f8
     2 status = i2
   1 person_plan_reltn_qual_cnt = i4
   1 person_plan_reltn_qual[*]
     2 person_plan_reltn_id = f8
     2 status = i2
   1 person_prsnl_reltn_qual_cnt = i4
   1 person_prsnl_reltn_qual[*]
     2 person_prsnl_reltn_id = f8
     2 status = i2
   1 phone_qual_cnt = i4
   1 phone_qual[*]
     2 phone_id = f8
     2 status = i2
   1 service_category_hist_qual_cnt = i4
   1 service_category_hist_qual[*]
     2 svc_cat_hist_id = f8
     2 status = i2
   1 preprocess_qual_cnt = i4
   1 preprocess_qual[*]
     2 status = i2
   1 postprocess_qual_cnt = i4
   1 postprocess_qual[*]
     2 status = i2
   1 p_rx_plan_coverage_qual_cnt = i4
   1 person_rx_plan_coverage_qual[*]
     2 person_rx_plan_coverage_id = f8
     2 status = i2
   1 p_rx_plan_reltn_qual_cnt = i4
   1 person_rx_plan_reltn_qual[*]
     2 person_rx_plan_reltn_id = f8
     2 status = i2
   1 debug_cnt = i4
   1 debug[*]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 error_info[1]
     2 line1 = vc
     2 line2 = vc
     2 line3 = vc
 )
 RECORD get_pds_exception_by_id_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 local_person_data
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 birth_prec_flag = i2
     2 birth_tz = i4
     2 gender_cd = f8
     2 nhs_number = vc
     2 nhs_alias_pool_cd = f8
     2 phone_format_cd = f8
     2 source_version_number = vc
     2 comparison_data
       3 current_name_ind = i2
       3 birth_info_ind = i2
       3 home_address_ind = i2
       3 mailing_address_ind = i2
       3 temp_address_ind = i2
     2 current_name
       3 person_name_id = f8
       3 name_first = vc
       3 name_last = vc
       3 name_prefix = vc
       3 name_suffix = vc
       3 name_middle = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 home_phone
       3 phone_id = f8
       3 phone_number = vc
       3 contact_method_cd = f8
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 home_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 mailing_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 temp_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 pds_person_data
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 birth_prec_flag = i2
     2 birth_tz = i4
     2 source_version_number = vc
     2 current_name
       3 person_name_id = f8
       3 name_first = vc
       3 name_last = vc
       3 name_prefix = vc
       3 name_suffix = vc
       3 name_middle = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 home_phone
       3 phone_id = f8
       3 phone_number = vc
       3 contact_method_cd = f8
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 home_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 mailing_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 temp_address
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 city = vc
       3 county = vc
       3 zipcode = vc
       3 postal_identifier = vc
       3 comment_txt = vc
       3 source_identifier = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 DECLARE process_status_complete = f8 WITH protect, constant(loadcodevalue(254591,"COMPLETE",0))
 DECLARE home_addr_type_cd = f8 WITH protect, constant(loadcodevalue(212,"HOME",0))
 DECLARE home_ph_type_cd = f8 WITH protect, constant(loadcodevalue(43,"HOME",0))
 DECLARE mailing_addr_type_cd = f8 WITH protect, constant(loadcodevalue(212,"MAILING",0))
 DECLARE temp_addr_type_cd = f8 WITH protect, constant(loadcodevalue(212,"TEMPORARY",0))
 DECLARE current_name_type_cd = f8 WITH protect, constant(loadcodevalue(213,"CURRENT",0))
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 SET stat = moverec(request,acm_reconcile_req)
 DECLARE index = i2
 DECLARE action_add = i2 WITH constant(1)
 DECLARE action_chg = i2 WITH constant(2)
 DECLARE local_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE ssn_cd = f8 WITH protect, constant(loadcodevalue(4,"SSN",0))
 DECLARE nhs_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE trace_in_progress = f8 WITH protect, constant(loadcodevalue(29882,"06",0))
 DECLARE keep_any_local_ind = i2 WITH protect, noconstant(false)
 DECLARE chg_str = vc WITH noconstant("")
 DECLARE addresscnt = i4 WITH protect, noconstant(0)
 IF ((((acm_reconcile_req->birth_info_keep_local_ind != 0)) OR ((((acm_reconcile_req->
 current_name_keep_local_ind != 0)) OR ((((acm_reconcile_req->home_address_keep_local_ind != 0)) OR (
 (((acm_reconcile_req->mailing_address_keep_local_ind != 0)) OR ((acm_reconcile_req->
 temp_address_keep_local_ind != 0))) )) )) )) )
  SET keep_any_local_ind = true
 ENDIF
 DECLARE use_any_pds_data = i2 WITH protect, noconstant(false)
 IF ((((acm_reconcile_req->birth_info_keep_local_ind=0)) OR ((((acm_reconcile_req->
 current_name_keep_local_ind=0)) OR ((((acm_reconcile_req->home_address_keep_local_ind=0)) OR ((((
 acm_reconcile_req->mailing_address_keep_local_ind=0)) OR ((acm_reconcile_req->
 temp_address_keep_local_ind=0))) )) )) )) )
  SET use_any_pds_data = true
 ENDIF
 DECLARE use_city = i2 WITH protect, noconstant(false)
 DECLARE nhscityoptcd = f8 WITH protect, constant(loadcodevalue(20790,"NHSCITYOPT",0))
 IF (nhscityoptcd > 0)
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=nhscityoptcd
    AND cve.field_name="OPTION"
    AND cve.code_set=20790
   DETAIL
    IF (trim(cve.field_value,3)="1")
     use_city = true
    ELSE
     use_city = false
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE user_log_type_flag = i2 WITH protect, noconstant(0)
 EXECUTE sacrtl
 SET user_log_type_flag = uar_sacgetuserlogontype()
 FREE RECORD request
 RECORD request(
   1 pds_exception_id = f8
 )
 SET request->pds_exception_id = acm_reconcile_req->pds_exception_id
 EXECUTE acm_get_pds_exception_by_id  WITH replace("REPLY","GET_PDS_EXCEPTION_BY_ID_REPLY")
 IF ((get_pds_exception_by_id_reply->status_data.status="F"))
  SET failed = execute_error
  SET table_name = "GET_PDS_EXCEPTION_BY_ID failed"
  SET reply->status_data.status = get_pds_exception_by_id_reply->status_data.status
  FOR (index = 1 TO size(get_pds_exception_by_id_reply->status_data.subeventstatus,5))
    CALL s_add_subeventstatus(get_pds_exception_by_id_reply->status_data.subeventstatus[index].
     operationname,get_pds_exception_by_id_reply->status_data.subeventstatus[index].operationstatus,
     get_pds_exception_by_id_reply->status_data.subeventstatus[index].targetobjectname,
     get_pds_exception_by_id_reply->status_data.subeventstatus[index].targetobjectvalue)
  ENDFOR
  GO TO exit_script
 ENDIF
 SET local_person_id = get_pds_exception_by_id_reply->local_person_data.person_id
 IF (local_person_id=0)
  SET failed = execute_error
  SET table_name = "GET_PDS_EXCEPTION_BY_ID failed - local person id cannot be 0"
  GO TO exit_script
 ENDIF
 IF (use_any_pds_data)
  SET stat = alterlist(acm_registration_req->person_qual,1)
  SET stat = alterlist(acm_registration_req->transaction_info_qual,1)
  SET acm_registration_req->person_qual[1].person_id = local_person_id
  SET acm_registration_req->force_updt_ind = 1
  SET acm_registration_req->transaction_info_qual[1].person_idx = 1
  SET acm_registration_req->transaction_info_qual[1].transaction = "UMPI"
  SET acm_registration_req->transaction_info_qual[1].transaction_dt_tm = cnvtdatetime(curdate,
   curtime3)
  SET acm_registration_req->transaction_info_qual[1].transaction_reason = "DEMOGRAPHICS COMPARISON"
  IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.birth_info_ind
   AND  NOT (acm_reconcile_req->birth_info_keep_local_ind))
   SET acm_registration_req->person_qual[1].birth_dt_tm = get_pds_exception_by_id_reply->
   pds_person_data.birth_dt_tm
   SET acm_registration_req->person_qual[1].birth_tz = get_pds_exception_by_id_reply->pds_person_data
   .birth_tz
   SET acm_registration_req->person_qual[1].birth_prec_flag = get_pds_exception_by_id_reply->
   pds_person_data.birth_prec_flag
   SET acm_registration_req->person_qual[1].action_flag = action_chg
   SET acm_registration_req->person_qual[1].chg_str = build("BIRTH_DT_TM,BIRTH_TZ,BIRTH_PREC_FLAG,")
  ENDIF
  IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.current_name_ind
   AND  NOT (acm_reconcile_req->current_name_keep_local_ind))
   SET stat = alterlist(acm_registration_req->person_name_qual,1)
   IF ((get_pds_exception_by_id_reply->local_person_data.current_name.person_name_id != 0))
    SET acm_registration_req->person_name_qual[1].person_name_id = get_pds_exception_by_id_reply->
    local_person_data.current_name.person_name_id
    SET acm_registration_req->person_name_qual[1].action_flag = action_chg
    SET acm_registration_req->person_name_qual[1].chg_str = build(
     "NAME_FIRST,NAME_LAST,NAME_PREFIX,PERSON_ID,","NAME_SUFFIX,NAME_MIDDLE,SOURCE_IDENTIFIER,",
     "BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,NAME_TYPE_CD,")
   ELSE
    SET acm_registration_req->person_name_qual[1].action_flag = action_add
   ENDIF
   SET acm_registration_req->person_name_qual[1].person_id = local_person_id
   SET acm_registration_req->person_name_qual[1].person_idx = 1
   SET acm_registration_req->person_name_qual[1].name_type_cd = current_name_type_cd
   SET acm_registration_req->person_name_qual[1].name_first = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_first
   SET acm_registration_req->person_name_qual[1].name_last = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_last
   SET acm_registration_req->person_name_qual[1].name_prefix = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_prefix
   SET acm_registration_req->person_name_qual[1].name_suffix = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_suffix
   SET acm_registration_req->person_name_qual[1].name_middle = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_middle
   SET acm_registration_req->person_name_qual[1].source_identifier = get_pds_exception_by_id_reply->
   pds_person_data.current_name.source_identifier
   SET acm_registration_req->person_name_qual[1].beg_effective_dt_tm = get_pds_exception_by_id_reply
   ->pds_person_data.current_name.beg_effective_dt_tm
   SET acm_registration_req->person_name_qual[1].end_effective_dt_tm = get_pds_exception_by_id_reply
   ->pds_person_data.current_name.end_effective_dt_tm
   SET acm_registration_req->person_qual[1].name_last = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_last
   SET acm_registration_req->person_qual[1].name_first = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_first
   SET acm_registration_req->person_qual[1].name_middle = get_pds_exception_by_id_reply->
   pds_person_data.current_name.name_middle
   SET acm_registration_req->person_qual[1].name_full_formatted = uar_i18nbuildfullformatname(
    nullterm(trim(get_pds_exception_by_id_reply->pds_person_data.current_name.name_first,3)),nullterm
    (trim(get_pds_exception_by_id_reply->pds_person_data.current_name.name_last,3)),nullterm(trim(
      get_pds_exception_by_id_reply->pds_person_data.current_name.name_middle,3)),"","",
    nullterm(trim(get_pds_exception_by_id_reply->pds_person_data.current_name.name_prefix,3)),
    nullterm(trim(get_pds_exception_by_id_reply->pds_person_data.current_name.name_suffix,3)),"","")
   SET acm_registration_req->person_qual[1].action_flag = action_chg
   SET acm_registration_req->person_qual[1].chg_str = build(acm_registration_req->person_qual[1].
    chg_str,"NAME_FIRST,NAME_LAST,NAME_MIDDLE,NAME_FULL_FORMATTED,")
  ENDIF
  IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.home_address_ind
   AND  NOT (acm_reconcile_req->home_address_keep_local_ind))
   SET addresscnt = (addresscnt+ 1)
   SET stat = alterlist(acm_registration_req->address_qual,addresscnt)
   IF ((get_pds_exception_by_id_reply->local_person_data.home_address.address_id != 0))
    SET acm_registration_req->address_qual[addresscnt].address_id = get_pds_exception_by_id_reply->
    local_person_data.home_address.address_id
    SET acm_registration_req->address_qual[addresscnt].action_flag = action_chg
    SET chg_str = build("PARENT_ENTITY_ID,PARENT_ENTITY_NAME,STREET_ADDR,",
     "STREET_ADDR2,STREET_ADDR3,COUNTY,ZIPCODE,","POSTAL_IDENTIFIER,SOURCE_IDENTIFIER,COMMENT_TXT,",
     "BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,ADDRESS_TYPE_CD,")
    IF (use_city)
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"CITY,")
    ELSE
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"STREET_ADDR4,")
    ENDIF
   ELSE
    SET acm_registration_req->address_qual[1].action_flag = action_add
   ENDIF
   SET acm_registration_req->address_qual[addresscnt].parent_entity_id = local_person_id
   SET acm_registration_req->address_qual[addresscnt].parent_entity_idx = 1
   SET acm_registration_req->address_qual[addresscnt].parent_entity_name = "PERSON"
   SET acm_registration_req->address_qual[addresscnt].street_addr = get_pds_exception_by_id_reply->
   pds_person_data.home_address.street_addr
   SET acm_registration_req->address_qual[addresscnt].street_addr2 = get_pds_exception_by_id_reply->
   pds_person_data.home_address.street_addr2
   SET acm_registration_req->address_qual[addresscnt].street_addr3 = get_pds_exception_by_id_reply->
   pds_person_data.home_address.street_addr3
   SET acm_registration_req->address_qual[addresscnt].county = get_pds_exception_by_id_reply->
   pds_person_data.home_address.county
   SET acm_registration_req->address_qual[addresscnt].zipcode = get_pds_exception_by_id_reply->
   pds_person_data.home_address.zipcode
   SET acm_registration_req->address_qual[addresscnt].postal_identifier =
   get_pds_exception_by_id_reply->pds_person_data.home_address.postal_identifier
   SET acm_registration_req->address_qual[addresscnt].comment_txt = get_pds_exception_by_id_reply->
   pds_person_data.home_address.comment_txt
   SET acm_registration_req->address_qual[addresscnt].source_identifier =
   get_pds_exception_by_id_reply->pds_person_data.home_address.source_identifier
   SET acm_registration_req->address_qual[addresscnt].beg_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.home_address.beg_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].end_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.home_address.end_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].address_type_cd = home_addr_type_cd
   IF (use_city)
    SET acm_registration_req->address_qual[addresscnt].city = get_pds_exception_by_id_reply->
    pds_person_data.home_address.city
   ELSE
    SET acm_registration_req->address_qual[addresscnt].street_addr4 = get_pds_exception_by_id_reply->
    pds_person_data.home_address.city
   ENDIF
   SET stat = alterlist(acm_registration_req->phone_qual,1)
   IF ((get_pds_exception_by_id_reply->local_person_data.home_phone.phone_id != 0))
    SET acm_registration_req->phone_qual[1].phone_id = get_pds_exception_by_id_reply->
    local_person_data.home_phone.phone_id
    SET acm_registration_req->phone_qual[1].action_flag = action_chg
    SET acm_registration_req->phone_qual[1].chg_str = build(
     "PARENT_ENTITY_ID,PARENT_ENTITY_NAME,PHONE_NUM,","CONTACT_METHOD_CD,SOURCE_IDENTIFIER,",
     "BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,PHONE_TYPE_CD,")
   ELSE
    SET acm_registration_req->phone_qual[1].action_flag = action_add
   ENDIF
   SET acm_registration_req->phone_qual[1].parent_entity_id = local_person_id
   SET acm_registration_req->phone_qual[1].parent_entity_idx = 1
   SET acm_registration_req->phone_qual[1].parent_entity_name = "PERSON"
   SET acm_registration_req->phone_qual[1].phone_num = get_pds_exception_by_id_reply->pds_person_data
   .home_phone.phone_number
   SET acm_registration_req->phone_qual[1].contact_method_cd = get_pds_exception_by_id_reply->
   pds_person_data.home_phone.contact_method_cd
   SET acm_registration_req->phone_qual[1].source_identifier = get_pds_exception_by_id_reply->
   pds_person_data.home_phone.source_identifier
   SET acm_registration_req->phone_qual[1].beg_effective_dt_tm = get_pds_exception_by_id_reply->
   pds_person_data.home_phone.beg_effective_dt_tm
   SET acm_registration_req->phone_qual[1].end_effective_dt_tm = get_pds_exception_by_id_reply->
   pds_person_data.home_phone.end_effective_dt_tm
   SET acm_registration_req->phone_qual[1].phone_type_cd = home_ph_type_cd
  ENDIF
  IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.mailing_address_ind
   AND  NOT (acm_reconcile_req->mailing_address_keep_local_ind))
   SET addresscnt = (addresscnt+ 1)
   SET stat = alterlist(acm_registration_req->address_qual,addresscnt)
   IF ((get_pds_exception_by_id_reply->local_person_data.mailing_address.address_id=0))
    SET acm_registration_req->address_qual[addresscnt].action_flag = action_add
   ELSE
    SET acm_registration_req->address_qual[addresscnt].address_id = get_pds_exception_by_id_reply->
    local_person_data.mailing_address.address_id
    SET acm_registration_req->address_qual[addresscnt].action_flag = action_chg
    SET chg_str = build("PARENT_ENTITY_ID,PARENT_ENTITY_NAME,STREET_ADDR,",
     "STREET_ADDR2,STREET_ADDR3,COUNTY,ZIPCODE,","POSTAL_IDENTIFIER,SOURCE_IDENTIFIER,COMMENT_TXT,",
     "BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,ADDRESS_TYPE_CD,")
    IF (use_city)
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"CITY,")
    ELSE
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"STREET_ADDR4,")
    ENDIF
   ENDIF
   SET acm_registration_req->address_qual[addresscnt].parent_entity_id = local_person_id
   SET acm_registration_req->address_qual[addresscnt].parent_entity_idx = 1
   SET acm_registration_req->address_qual[addresscnt].parent_entity_name = "PERSON"
   SET acm_registration_req->address_qual[addresscnt].street_addr = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.street_addr
   SET acm_registration_req->address_qual[addresscnt].street_addr2 = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.street_addr2
   SET acm_registration_req->address_qual[addresscnt].street_addr3 = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.street_addr3
   SET acm_registration_req->address_qual[addresscnt].county = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.county
   SET acm_registration_req->address_qual[addresscnt].zipcode = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.zipcode
   SET acm_registration_req->address_qual[addresscnt].postal_identifier =
   get_pds_exception_by_id_reply->pds_person_data.mailing_address.postal_identifier
   SET acm_registration_req->address_qual[addresscnt].comment_txt = get_pds_exception_by_id_reply->
   pds_person_data.mailing_address.comment_txt
   SET acm_registration_req->address_qual[addresscnt].source_identifier =
   get_pds_exception_by_id_reply->pds_person_data.mailing_address.source_identifier
   SET acm_registration_req->address_qual[addresscnt].beg_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.mailing_address.beg_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].end_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.mailing_address.end_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].address_type_cd = mailing_addr_type_cd
   IF (use_city)
    SET acm_registration_req->address_qual[addresscnt].city = get_pds_exception_by_id_reply->
    pds_person_data.mailing_address.city
   ELSE
    SET acm_registration_req->address_qual[addresscnt].street_addr4 = get_pds_exception_by_id_reply->
    pds_person_data.mailing_address.city
   ENDIF
  ENDIF
  IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.temp_address_ind
   AND  NOT (acm_reconcile_req->temp_address_keep_local_ind))
   SET addresscnt = (addresscnt+ 1)
   SET stat = alterlist(acm_registration_req->address_qual,addresscnt)
   IF ((get_pds_exception_by_id_reply->local_person_data.temp_address.address_id=0))
    SET acm_registration_req->address_qual[addresscnt].action_flag = action_add
   ELSE
    SET acm_registration_req->address_qual[addresscnt].address_id = get_pds_exception_by_id_reply->
    local_person_data.temp_address.address_id
    SET acm_registration_req->address_qual[addresscnt].action_flag = action_chg
    SET chg_str = build("PARENT_ENTITY_ID,PARENT_ENTITY_NAME,STREET_ADDR,",
     "STREET_ADDR2,STREET_ADDR3,COUNTY,COMMENT_TXT,","ZIPCODE,POSTAL_IDENTIFIER,SOURCE_IDENTIFIER,",
     "BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,ADDRESS_TYPE_CD,")
    IF (use_city)
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"CITY,")
    ELSE
     SET acm_registration_req->address_qual[addresscnt].chg_str = build(chg_str,"STREET_ADDR4,")
    ENDIF
   ENDIF
   SET acm_registration_req->address_qual[addresscnt].parent_entity_id = local_person_id
   SET acm_registration_req->address_qual[addresscnt].parent_entity_idx = 1
   SET acm_registration_req->address_qual[addresscnt].parent_entity_name = "PERSON"
   SET acm_registration_req->address_qual[addresscnt].street_addr = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.street_addr
   SET acm_registration_req->address_qual[addresscnt].street_addr2 = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.street_addr2
   SET acm_registration_req->address_qual[addresscnt].street_addr3 = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.street_addr3
   SET acm_registration_req->address_qual[addresscnt].county = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.county
   SET acm_registration_req->address_qual[addresscnt].zipcode = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.zipcode
   SET acm_registration_req->address_qual[addresscnt].postal_identifier =
   get_pds_exception_by_id_reply->pds_person_data.temp_address.postal_identifier
   SET acm_registration_req->address_qual[addresscnt].comment_txt = get_pds_exception_by_id_reply->
   pds_person_data.temp_address.comment_txt
   SET acm_registration_req->address_qual[addresscnt].source_identifier =
   get_pds_exception_by_id_reply->pds_person_data.temp_address.source_identifier
   SET acm_registration_req->address_qual[addresscnt].beg_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.temp_address.beg_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].end_effective_dt_tm =
   get_pds_exception_by_id_reply->pds_person_data.temp_address.end_effective_dt_tm
   SET acm_registration_req->address_qual[addresscnt].address_type_cd = temp_addr_type_cd
   IF (use_city)
    SET acm_registration_req->address_qual[addresscnt].city = get_pds_exception_by_id_reply->
    pds_person_data.temp_address.city
   ELSE
    SET acm_registration_req->address_qual[addresscnt].street_addr4 = get_pds_exception_by_id_reply->
    pds_person_data.temp_address.city
   ENDIF
  ENDIF
  EXECUTE acm_registration  WITH replace("REQUEST","ACM_REGISTRATION_REQ")
  DECLARE acm_reg_transaction_id = f8 WITH protect, noconstant(0.0)
  IF ((reply->transaction_info_qual_cnt > 0))
   SET acm_reg_transaction_id = reply->transaction_info_qual[1].transaction_id
  ENDIF
  IF ((reply->status_data.status="F"))
   SET failed = execute_error
   SET table_name = "ACM registration failed"
   GO TO exit_script
  ENDIF
  COMMIT
  FREE RECORD request
  RECORD request(
    1 person_id = f8
  )
  FREE RECORD outbound_reply
  RECORD outbound_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET request->person_id = local_person_id
  EXECUTE acm_send_outbound  WITH replace("REPLY","OUTBOUND_REPLY")
  FREE RECORD outbound_reply
  IF (acm_reg_transaction_id > 0)
   FREE RECORD request
   RECORD request(
     1 transaction_id = f8
   )
   SET request->transaction_id = acm_reg_transaction_id
   EXECUTE acm_post_process_transaction
   IF ((reply->status_data.status="F"))
    CALL s_add_subeventstatus("acm_post_process_transaction","F","acm_reconcile_pds_exception",
     "processing will continue")
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 DECLARE nhsstatuscode = f8 WITH protect, noconstant(0.0)
 DECLARE personaliasid = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE pa.person_id=local_person_id
    AND pa.person_alias_type_cd=ssn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   nhsstatuscode = pa.person_alias_status_cd, personaliasid = pa.person_alias_id
  WITH nocounter
 ;end select
 IF (nhsstatuscode=trace_in_progress)
  FREE RECORD complete_status
  RECORD complete_status(
    1 status = c1
    1 operationname = c25
  )
  IF (keep_any_local_ind)
   SET nhs_status_cd = loadcodevalue(29882,"03",0)
  ELSE
   SET nhs_status_cd = loadcodevalue(29882,"01",0)
  ENDIF
  CALL update_nhs_status_cd(nhs_status_cd,personaliasid,complete_status)
  IF ((complete_status->status="F"))
   SET failed = execute_error
   SET table_name = "update_nhs_status_cd failed"
   SET reply->status_data.status = complete_status->status
   CALL s_add_subeventstatus("acm_reconcile_pds_exception",complete_status->status,complete_status->
    operationname,"update_nhs_status_cd")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (user_log_type_flag=1
  AND keep_any_local_ind)
  EXECUTE acm_send_pds_exception_updt
  IF ((reply->status_data.status="F"))
   SET failed = execute_error
   SET table_name = "acm_send_pds_exception_updt failed"
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD complete_status
 RECORD complete_status(
   1 status = c1
   1 operationname = c25
 )
 CALL complete_pds_exception(0.0,local_person_id,"",complete_status)
 IF ((complete_status->status="F"))
  SET table_name = "complete_pds_exception failed"
  CALL s_add_subeventstatus(complete_status->operationname,"F","complete_pds_exception",
   "complete_pds_exception from acm_reconcile_pds_exception failed: status = F")
  SET failed = execute_error
  GO TO exit_script
 ENDIF
 IF (user_log_type_flag=0
  AND keep_any_local_ind=1)
  FREE RECORD acm_request
  RECORD acm_request(
    1 call_echo_ind = i2
    1 use_req_updt_ind = i2
    1 force_updt_ind = i2
    1 transaction_info_qual[*]
      2 transaction_id = f8
      2 pm_hist_tracking_id = f8
      2 transaction_dt_tm = dq8
      2 transaction_reason_cd = f8
      2 transaction_reason = vc
      2 transaction = c4
      2 person_id = f8
      2 person_idx = i4
      2 encntr_id = f8
      2 encntr_idx = i4
    1 person_patient_qual[*]
      2 adopted_cd = f8
      2 bad_debt_cd = f8
      2 birth_length = f8
      2 birth_length_units_cd = f8
      2 birth_multiple_cd = f8
      2 birth_name = vc
      2 birth_order = i4
      2 birth_weight = f8
      2 callback_consent_cd = f8
      2 church_cd = f8
      2 contact_list_cd = f8
      2 contact_method_cd = f8
      2 contact_time = vc
      2 contributor_system_cd = f8
      2 credit_hrs_taking = i4
      2 cumm_leave_days = i4
      2 current_balance = f8
      2 current_grade = i4
      2 custody_cd = f8
      2 degree_complete_cd = f8
      2 diet_type_cd = f8
      2 disease_alert_cd = f8
      2 family_income = f8
      2 family_size = i4
      2 highest_grade_complete_cd = f8
      2 interp_required_cd = f8
      2 interp_type_cd = f8
      2 last_bill_dt_tm = dq8
      2 last_bind_dt_tm = dq8
      2 last_discharge_dt_tm = dq8
      2 last_event_updt_dt_tm = dq8
      2 last_payment_dt_tm = dq8
      2 last_trauma_dt_tm = dq8
      2 living_arrangement_cd = f8
      2 living_dependency_cd = f8
      2 living_will_cd = f8
      2 microfilm_cd = f8
      2 mother_identifier = vc
      2 mother_identifier_cd = f8
      2 nbr_of_brothers = i4
      2 nbr_of_pregnancies = i4
      2 nbr_of_sisters = i4
      2 organ_donor_cd = f8
      2 parent_marital_status_cd = f8
      2 person_id = f8
      2 person_idx = i4
      2 process_alert_cd = f8
      2 smokes_cd = f8
      2 student_cd = f8
      2 tumor_registry_cd = f8
      2 action_flag = i2
      2 active_ind = i2
      2 active_status_cd = f8
      2 chg_str = vc
      2 data_status_cd = f8
      2 updt_cnt = i4
      2 pm_hist_tracking_id = f8
      2 transaction_dt_tm = dq8
      2 baptised_cd = f8
      2 gest_age_at_birth = i4
      2 gest_age_method_cd = f8
      2 written_format_cd = f8
      2 prev_contact_ind = i2
      2 birth_order_cd = f8
      2 source_version_number = vc
      2 source_last_sync_dt_tm = dq8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 source_sync_level_flag = i4
  )
  IF (validate(add_action)=0)
   DECLARE add_action = i2 WITH constant(1)
   DECLARE chg_action = i2 WITH constant(2)
   DECLARE del_action = i2 WITH constant(3)
   DECLARE act_action = i2 WITH constant(4)
   DECLARE ina_action = i2 WITH constant(5)
   DECLARE acm_hist_ind = i2 WITH constant(0)
  ENDIF
  DECLARE ppupdate = i2 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM person_patient pp
   WHERE pp.person_id=local_person_id
   DETAIL
    ppupdate = 1
   WITH nocounter
  ;end select
  SET stat = alterlist(acm_request->person_patient_qual,1)
  SET acm_request->person_patient_qual[1].person_id = local_person_id
  SET acm_request->person_patient_qual[1].source_version_number = "0"
  IF (ppupdate=1)
   SET acm_request->person_patient_qual[1].chg_str = "SOURCE_VERSION_NUMBER,"
   SET acm_request->person_patient_qual[1].action_flag = chg_action
   SET acm_request->force_updt_ind = 1
  ELSE
   SET acm_request->person_patient_qual[1].action_flag = add_action
  ENDIF
  EXECUTE acm_write_person_patient
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
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
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
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
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
