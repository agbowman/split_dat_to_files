CREATE PROGRAM acm_chgw_pds_exception:dba
 IF (validate(reply,"-999")="-999")
  RECORD reply(
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
    1 address_qual_cnt = i4
    1 address_qual[*]
      2 address_id = f8
      2 status = i2
    1 phone_qual_cnt = i4
    1 phone_qual[*]
      2 phone_id = f8
      2 status = i2
    1 person_qual_cnt = i4
    1 person_qual[*]
      2 person_id = f8
      2 status = i2
    1 person_name_qual_cnt = i4
    1 person_name_qual[*]
      2 person_name_id = f8
      2 status = i2
  )
 ENDIF
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
      2 pft_ruleset_grouping = i2
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
    DECLARE dprimaryssnaliaspoolcd = f8 WITH noconstant(0)
    DECLARE dnhscontributorsystem = f8 WITH constant(uar_get_code_by("MEANING",89,"NHS"))
    IF (dnhsaliascodeforpdsretrieve > 0.0
     AND dnhscontributorsystem > 0.0)
     SELECT INTO "nl:"
      FROM esi_alias_trans eat
      WHERE eat.contributor_system_cd=dnhscontributorsystem
       AND eat.alias_entity_alias_type_cd=dnhsaliascodeforpdsretrieve
       AND eat.esi_assign_auth="2.16.840.1.113883.2.1.4.1"
       AND eat.active_ind=1
      DETAIL
       dprimaryssnaliaspoolcd = eat.alias_pool_cd
      WITH nocounter
     ;end select
     IF (dnhsaliascodeforpdsretrieve > 0.0)
      SELECT INTO "nl:"
       pa.person_alias_id
       FROM person_patient pp,
        person_alias pa
       PLAN (pp
        WHERE pp.person_id=dpersonid
         AND pp.active_ind=1
         AND cnvtint(trim(pp.source_version_number,3)) > 0)
        JOIN (pa
        WHERE pa.person_id=pp.person_id
         AND pa.active_ind=1
         AND pa.person_alias_type_cd=dnhsaliascodeforpdsretrieve
         AND pa.alias_pool_cd=dprimaryssnaliaspoolcd
         AND ((pa.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
         AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       DETAIL
        snhsnumber = trim(pa.alias,3)
        IF (bdebugme)
         CALL echo(build("NHS number = ",snhsnumber))
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (textlen(trim(snhsnumber,3)) > 0)
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
    ENDIF
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
             2 pft_ruleset_grouping = i2
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
 DECLARE name_size = i4 WITH private, noconstant(size(request->person_name,5))
 DECLARE phone_size = i4 WITH private, noconstant(size(request->phone,5))
 DECLARE address_size = i4 WITH private, noconstant(size(request->address,5))
 DECLARE comparisonpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE inprocess_code = f8 WITH protect, constant(loadcodevalue(254591,"INPROCESS",0))
 DECLARE pdsexception_code = f8 WITH protect, constant(loadcodevalue(30700,"PDSEXCEPTION",0))
 DECLARE active_code = f8 WITH protect, constant(loadcodevalue(48,"ACTIVE",0))
 DECLARE add_action = i2 WITH constant(1)
 DECLARE chg_action = i2 WITH constant(2)
 DECLARE del_action = i2 WITH constant(3)
 DECLARE act_action = i2 WITH constant(4)
 DECLARE ina_action = i2 WITH constant(5)
 DECLARE acm_hist_ind = i2 WITH constant(0)
 DECLARE ssn_cd = f8 WITH protect, constant(loadcodevalue(4,"SSN",0))
 DECLARE nhs_status_cd = f8 WITH protect, constant(loadcodevalue(29882,"06",0))
 SET failed = false
 SET table_name = curprog
 IF ((request->pds_exception_id <= 0))
  SET failed = true
  SET table_name = "Must pass in pds_exception_id"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pm_post_process ppp
  SET ppp.pm_post_process_type_cd = pdsexception_code, ppp.process_status_cd = inprocess_code, ppp
   .pm_post_process_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (ppp.pm_post_process_id=request->pds_exception_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = update_error
  SET table_name = "PM_POST_PROCESS row does not exist"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pm_post_process ppp
  PLAN (ppp
   WHERE (ppp.pm_post_process_id=request->pds_exception_id))
  DETAIL
   comparisonpersonid = ppp.comparison_person_id
  WITH nocounter
 ;end select
 IF (comparisonpersonid > 0)
  DELETE  FROM address a
   WHERE a.parent_entity_id=comparisonpersonid
    AND a.parent_entity_name="PERSON"
  ;end delete
  DELETE  FROM phone ph
   WHERE ph.parent_entity_id=comparisonpersonid
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
  SELECT INTO "nl:"
   pn.person_name_id
   FROM person_name pn
   WHERE pn.person_id=comparisonpersonid
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
  SET stat = alterlist(acm_request->person_qual,1)
  SET acm_request->person_qual[1].person_id = comparisonpersonid
  SET acm_request->person_qual[1].action_flag = del_action
  EXECUTE acm_write_person
 ENDIF
 FREE RECORD acm_request
 RECORD acm_request(
   1 call_echo_ind = i2
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
     2 phone_num_key = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(acm_request->person_qual,1)
 SET acm_request->person_qual[1].action_flag = add_action
 SET acm_request->person_qual[1].ft_entity_name = "PM_POST_PROCESS"
 SET acm_request->person_qual[1].ft_entity_id = request->pds_exception_id
 IF ((request->person.birth_date.birth_dt_tm > 0))
  SET acm_request->person_qual[1].birth_dt_tm = request->person.birth_date.birth_dt_tm
  SET acm_request->person_qual[1].birth_prec_flag = request->person.birth_date.birth_prec_flag
  SET acm_request->person_qual[1].birth_tz = request->person.birth_date.birth_tz
 ENDIF
 EXECUTE acm_write_person
 IF ((reply->status_data.status="F"))
  SET failed = execute_error
  SET table_name = "Failed executing acm_write_person"
  GO TO exit_script
 ENDIF
 IF (name_size > 0)
  SET stat = alterlist(acm_request->person_name_qual,name_size)
  FOR (index = 1 TO name_size)
    SET acm_request->person_name_qual[index].name_type_cd = request->person_name[index].name_type_cd
    SET acm_request->person_name_qual[index].name_type_seq = request->person_name[index].
    name_type_seq
    SET acm_request->person_name_qual[index].name_first = request->person_name[index].name_first
    SET acm_request->person_name_qual[index].name_middle = request->person_name[index].name_middle
    SET acm_request->person_name_qual[index].name_last = request->person_name[index].name_last
    SET acm_request->person_name_qual[index].name_prefix = request->person_name[index].name_prefix
    SET acm_request->person_name_qual[index].name_suffix = request->person_name[index].name_suffix
    SET acm_request->person_name_qual[index].source_identifier = request->person_name[index].
    source_identifier
    SET acm_request->person_name_qual[index].beg_effective_dt_tm = request->person_name[index].
    beg_effective_dt_tm
    SET acm_request->person_name_qual[index].end_effective_dt_tm = request->person_name[index].
    end_effective_dt_tm
    SET acm_request->person_name_qual[index].person_id = reply->person_qual[1].person_id
    SET acm_request->person_name_qual[index].action_flag = add_action
  ENDFOR
  EXECUTE acm_write_person_name
  IF ((reply->status_data.status="F"))
   SET failed = execute_error
   SET table_name = "Failed executing acm_write_person_name"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (address_size > 0)
  SET stat = alterlist(acm_request->address_qual,address_size)
  FOR (index = 1 TO address_size)
    SET acm_request->address_qual[index].address_type_cd = request->address[index].address_type_cd
    SET acm_request->address_qual[index].address_type_seq = request->address[index].address_type_seq
    SET acm_request->address_qual[index].street_addr = request->address[index].street_addr
    SET acm_request->address_qual[index].street_addr2 = request->address[index].street_addr2
    SET acm_request->address_qual[index].street_addr3 = request->address[index].street_addr3
    SET acm_request->address_qual[index].street_addr4 = request->address[index].street_addr4
    SET acm_request->address_qual[index].city = request->address[index].city
    SET acm_request->address_qual[index].county = request->address[index].county
    SET acm_request->address_qual[index].zipcode = request->address[index].zipcode
    SET acm_request->address_qual[index].postal_identifier = request->address[index].
    postal_identifier
    SET acm_request->address_qual[index].comment_txt = request->address[index].comment_txt
    SET acm_request->address_qual[index].source_identifier = request->address[index].
    source_identifier
    SET acm_request->address_qual[index].beg_effective_dt_tm = request->address[index].
    beg_effective_dt_tm
    SET acm_request->address_qual[index].end_effective_dt_tm = request->address[index].
    end_effective_dt_tm
    SET acm_request->address_qual[index].action_flag = add_action
    SET acm_request->address_qual[index].parent_entity_name = "PERSON"
    SET acm_request->address_qual[index].parent_entity_id = reply->person_qual[1].person_id
  ENDFOR
  EXECUTE acm_write_address
  IF ((reply->status_data.status="F"))
   SET failed = execute_error
   SET table_name = "Failed executing acm_write_address"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (phone_size > 0)
  SET stat = alterlist(acm_request->phone_qual,phone_size)
  FOR (index = 1 TO phone_size)
    SET acm_request->phone_qual[index].phone_type_cd = request->phone[index].phone_type_cd
    SET acm_request->phone_qual[index].phone_type_seq = request->phone[index].phone_type_seq
    SET acm_request->phone_qual[index].phone_num = request->phone[index].phone_number
    SET acm_request->phone_qual[index].contact_method_cd = request->phone[index].contact_method_cd
    SET acm_request->phone_qual[index].source_identifier = request->phone[index].source_identifier
    SET acm_request->phone_qual[index].beg_effective_dt_tm = request->phone[index].
    beg_effective_dt_tm
    SET acm_request->phone_qual[index].end_effective_dt_tm = request->phone[index].
    end_effective_dt_tm
    SET acm_request->phone_qual[index].action_flag = add_action
    SET acm_request->phone_qual[index].parent_entity_name = "PERSON"
    SET acm_request->phone_qual[index].parent_entity_id = reply->person_qual[1].person_id
  ENDFOR
  EXECUTE acm_write_phone
  IF ((reply->status_data.status="F"))
   SET failed = execute_error
   SET table_name = "Failed executing acm_write_phone"
   GO TO exit_script
  ENDIF
 ENDIF
 UPDATE  FROM pm_post_process ppp
  SET ppp.comparison_person_id = reply->person_qual[1].person_id, ppp.source_version_number = request
   ->source_version_number, ppp.updt_cnt = (ppp.updt_cnt+ 1),
   ppp.updt_dt_tm = cnvtdatetime(curdate,curtime3), ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx
    = reqinfo->updt_applctx,
   ppp.updt_task = reqinfo->updt_task
  WHERE (ppp.person_id=request->person_id)
   AND ppp.process_status_cd=inprocess_code
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = update_error
  SET table_name = "PM_POST_PROCESS row does not exist"
  GO TO exit_script
 ENDIF
 SET daliasreltnid = 0.0
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=ssn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   daliasreltnid = pa.person_alias_id
  WITH nocounter
 ;end select
 FREE RECORD complete_status
 RECORD complete_status(
   1 status = c1
   1 operationname = c25
 )
 CALL update_nhs_status_cd(nhs_status_cd,daliasreltnid,complete_status)
 IF ((complete_status->status="F"))
  SET reply->status_data.status = "W"
  SET reqinfo->commit_ind = true
  GO TO end_script
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
#end_script
END GO
