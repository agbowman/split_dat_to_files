CREATE PROGRAM dcp_get_ord_sel:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH private, noconstant("")
 ENDIF
 SET last_mod = "435254"
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
 CALL echorecord(request)
 RECORD reply(
   1 high_char_search_complete = i2
   1 get_list[*]
     2 mnemonic = vc
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 oe_format_id = f8
     2 rx_mask = i4
     2 multiple_ord_sent_ind = i2
     2 order_sentence_id = f8
     2 orderable_type_flag = i2
     2 dcp_clin_cat_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE is_wildcard_ind_on = i2 WITH noconstant(false)
 DECLARE dcontainssrchcd = f8 WITH public, constant(loadcodevalue(207902,"CONTAINSSRCH",1))
 DECLARE search_string = vc WITH protect, noconstant(
  "ocs.mnemonic_key_cap between start_str and end_str")
 DECLARE result = i2 WITH protect, noconstant(- (1))
 DECLARE trim_upper_seed = vc WITH protect, noconstant("")
 DECLARE is_def_wild_card_on = i2 WITH noconstant(false)
 DECLARE ddefwildcardcd = f8 WITH public, constant(loadcodevalue(207902,"DEFWILDCARD",1))
 SET count1 = 0
 SET reply->high_char_search_complete = 0
 SET done = 0
 SET reply->status_data.status = "F"
 SET start_str = fillstring(100," ")
 SET end_str = fillstring(100," ")
 SET high_str = fillstring(31," ")
 SET low_str = fillstring(31," ")
 SET next_char = fillstring(5," ")
 SET low_char = fillstring(5," ")
 SET high_char = fillstring(5," ")
 SET first_char = fillstring(3," ")
 SET cats_to_get = cnvtint(size(request->cat_list,5))
 SET mnems_to_get = cnvtint(size(request->mnem_list,5))
 SET filter_rx_mask = 0
 SET filter_orc = 0
 IF (dcontainssrchcd > 0.0)
  SET is_wildcard_ind_on = true
 ENDIF
 IF (ddefwildcardcd > 0.0)
  SET is_def_wild_card_on = true
 ENDIF
 IF ((request->rx_mask > 0))
  SET filter_rx_mask = 1
 ENDIF
 IF ((request->virtual_view_offset > 0)
  AND (request->virtual_view_offset < 101))
  SET filter_orc = 1
 ENDIF
 SET start_str = cnvtupper(request->seed)
 SET start_char = cnvtupper(substring(1,1,request->seed))
 SET phandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highalnum(phandle,high_str,size(high_str))
 CALL uar_i18nalphabet_lowalnum(phandle,low_str,size(low_str))
 SET high_char = cnvtupper(substring(1,1,high_str))
 SET low_char = cnvtupper(substring(1,1,low_str))
 IF (((start_char=" ") OR (start_char=null)) )
  SET start_char = low_char
  SET start_str = low_char
 ENDIF
 SET start_str = concat(start_str,low_str)
 SET end_str = concat(start_char,high_str)
 IF (is_wildcard_ind_on=true)
  SET trim_upper_seed = trim(cnvtupper(request->seed),3)
  IF (is_def_wild_card_on=true)
   SET search_string = "ocs.mnemonic_key_cap = patstring(concat('*',trim_upper_seed, '*'))"
  ELSE
   SET result = findstring("*",trim_upper_seed,1,0)
   IF (result=0)
    SET result = findstring("?",trim_upper_seed,1,0)
   ENDIF
   IF (result > 0)
    SET search_string = "ocs.mnemonic_key_cap = patstring(concat(trim_upper_seed, '*'))"
   ENDIF
  ENDIF
 ENDIF
 CALL uar_i18nalphabet_nextdalnum(phandle,start_char,size(start_char),next_char,size(next_char))
 WHILE (done != 1)
   CALL dq_reset_query(null)
   CALL dq_add_line("select")
   CALL dq_add_line(' into "nl:"')
   CALL dq_add_line(" ocs.mnemonic_key_cap")
   IF (cats_to_get > 0
    AND mnems_to_get > 0)
    CALL dq_add_line(" from (dummyt d with seq = value (cats_to_get)),")
    CALL dq_add_line(" (dummyt d2 with seq = value (mnems_to_get)),")
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" code_value_group cvg,")
    ENDIF
    CALL dq_add_line(" order_catalog_synonym ocs")
    CALL dq_add_line(" plan d")
    CALL dq_add_line(" join d2")
    CALL dq_add_line(" join ocs where parser(search_string)")
    CALL dq_add_line(" and ocs.dcp_clin_cat_cd = request->cat_list[d.seq]->dcp_clin_cat_cd")
    CALL dq_add_line(" and ocs.mnemonic_type_cd = request->mnem_list[d2.seq]->mnemonic_type_cd")
    CALL dq_add_line(" and ocs.active_ind = 1")
    CALL dq_add_line(" and ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11)")
    CALL dq_add_line(" and (ocs.hide_flag = 0 or ocs.hide_flag = NULL)")
    CALL dq_add_line(" and (filter_rx_mask = 0 or ocs.rx_mask > 0)")
    CALL dq_add_line(
     ' and (filter_orc = 0 or (substring (request->virtual_view_offset, 1,  ocs.virtual_view) = "1"))'
     )
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" join  cvg")
     CALL dq_add_line(" where cvg.child_code_value = ocs.catalog_cd")
     CALL dq_add_line(" and cvg.parent_code_value + 0= request->filter_code_value")
    ENDIF
    CALL dq_add_line(" order by ocs.mnemonic_key_cap")
   ELSEIF (cats_to_get > 0
    AND mnems_to_get=0)
    CALL dq_add_line(" from (dummyt d with seq = value (cats_to_get)),")
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" code_value_group cvg,")
    ENDIF
    CALL dq_add_line(" order_catalog_synonym ocs")
    CALL dq_add_line(" plan d")
    CALL dq_add_line(" join ocs where parser(search_string)")
    CALL dq_add_line(" and ocs.dcp_clin_cat_cd = request->cat_list[d.seq]->dcp_clin_cat_cd")
    CALL dq_add_line(" and ocs.active_ind = 1")
    CALL dq_add_line(" and ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11)")
    CALL dq_add_line(" and (ocs.hide_flag = 0 or ocs.hide_flag = NULL)")
    CALL dq_add_line(" and (filter_rx_mask = 0 or ocs.rx_mask > 0)")
    CALL dq_add_line(
     ' and (filter_orc = 0 or (substring (request->virtual_view_offset, 1,  ocs.virtual_view) = "1"))'
     )
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" join  cvg")
     CALL dq_add_line(" where cvg.child_code_value = ocs.catalog_cd")
     CALL dq_add_line(" and cvg.parent_code_value + 0 = request->filter_code_value")
    ENDIF
    CALL dq_add_line("order by ocs.mnemonic_key_cap")
   ELSEIF (cats_to_get=0
    AND mnems_to_get > 0)
    CALL dq_add_line(" from (dummyt d with seq = value (mnems_to_get)),")
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" code_value_group cvg,")
    ENDIF
    CALL dq_add_line(" order_catalog_synonym ocs")
    CALL dq_add_line(" plan d")
    CALL dq_add_line(" join ocs where parser(search_string)")
    CALL dq_add_line(" and ocs.mnemonic_type_cd = request->mnem_list[d.seq]->mnemonic_type_cd")
    CALL dq_add_line(" and ocs.active_ind = 1")
    CALL dq_add_line(" and ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11)")
    CALL dq_add_line(" and (ocs.hide_flag = 0 or ocs.hide_flag = NULL)")
    CALL dq_add_line(" and (filter_rx_mask = 0 or ocs.rx_mask > 0)")
    CALL dq_add_line(
     ' and (filter_orc = 0 or (substring (request->virtual_view_offset, 1,  ocs.virtual_view) = "1"))'
     )
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" join  cvg")
     CALL dq_add_line(" where cvg.child_code_value = ocs.catalog_cd")
     CALL dq_add_line(" and cvg.parent_code_value + 0 = request->filter_code_value")
    ENDIF
    CALL dq_add_line(" order by ocs.mnemonic_key_cap")
   ELSE
    CALL dq_add_line(" from")
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" code_value_group cvg,")
    ENDIF
    CALL dq_add_line(" order_catalog_synonym ocs")
    CALL dq_add_line(" where parser(search_string)")
    CALL dq_add_line(" and ocs.active_ind = 1")
    CALL dq_add_line(" and (ocs.hide_flag = 0 or ocs.hide_flag = NULL)")
    CALL dq_add_line("  and (filter_rx_mask = 0 or ocs.rx_mask > 0)")
    CALL dq_add_line(
     ' and (filter_orc = 0 or (substring (request->virtual_view_offset, 1,  ocs.virtual_view) = "1"))'
     )
    IF ((request->filter_code_value > 0.00))
     CALL dq_add_line(" and cvg.child_code_value = ocs.catalog_cd")
     CALL dq_add_line(" and cvg.parent_code_value + 0 = request->filter_code_value")
    ENDIF
    CALL dq_add_line(" order by ocs.mnemonic_key_cap")
   ENDIF
   CALL dq_add_line(" head report")
   CALL dq_add_line(" col + 0")
   CALL dq_add_line(" detail")
   CALL dq_add_line(" if (filter_rx_mask = 0 or (band (ocs.rx_mask, request->rx_mask) > 0))")
   CALL dq_add_line(" count1 = count1 + 1")
   CALL dq_add_line(" if (count1 > size(reply->get_list, 5))")
   CALL dq_add_line(" stat = alterlist(reply->get_list, count1+10)")
   CALL dq_add_line(" endif")
   CALL dq_add_line(" reply->get_list[count1]->mnemonic = ocs.mnemonic")
   CALL dq_add_line(" reply->get_list[count1]->synonym_id = ocs.synonym_id")
   CALL dq_add_line(" reply->get_list[count1]->catalog_cd = ocs.catalog_cd")
   CALL dq_add_line(" reply->get_list[count1]->catalog_type_cd = ocs.catalog_type_cd")
   CALL dq_add_line(" reply->get_list[count1]->activity_type_cd = ocs.activity_type_cd")
   CALL dq_add_line(" reply->get_list[count1]->oe_format_id = ocs.oe_format_id")
   CALL dq_add_line(" reply->get_list[count1]->rx_mask = ocs.rx_mask")
   CALL dq_add_line(" reply->get_list[count1]->multiple_ord_sent_ind = ocs.multiple_ord_sent_ind")
   CALL dq_add_line(" reply->get_list[count1]->order_sentence_id = ocs.order_sentence_id")
   CALL dq_add_line(" reply->get_list[count1]->orderable_type_flag = ocs.orderable_type_flag")
   CALL dq_add_line(" reply->get_list[count1]->dcp_clin_cat_cd = ocs.dcp_clin_cat_cd")
   CALL dq_add_line(" reply->get_list[count1]->ref_text_mask = ocs.ref_text_mask")
   CALL dq_add_line(" reply->get_list[count1]->cki = ocs.cki")
   CALL dq_add_line(" endif")
   CALL dq_add_line(" foot report")
   CALL dq_add_line(" stat = alterlist(reply->get_list, count1)")
   CALL dq_add_line(" with check")
   CALL dq_end_query(null)
   CALL dq_execute(null)
   IF ((count1 < request->count))
    CALL echo(build("next_char: ",next_char))
    IF (uar_i18nalphabet_compchar(phandle,high_char,size(high_char),start_char,size(start_char))=0)
     SET done = 1
     SET reply->high_char_search_complete = 1
    ELSE
     IF (cnvtupper(substring(1,1,request->seed))=start_char
      AND size(reply->get_list,5) > 0)
      SET done = 1
     ENDIF
     SET start_char = next_char
     CALL uar_i18nalphabet_nextdalnum(phandle,start_char,size(start_char),next_char,size(next_char))
     IF (start_char="")
      SET done = 1
     ENDIF
    ENDIF
    SET start_str = start_char
    SET end_str = concat(start_char,high_str)
   ELSE
    SET done = 1
   ENDIF
 ENDWHILE
 CALL uar_i18nalphabet_end(phandle)
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("START_str: ",start_str))
 CALL echo(build("END_str: ",end_str))
 FOR (i = 1 TO count1)
   CALL echo(build("mnemonic: ",reply->get_list[i].mnemonic))
   CALL echo(build("dcccType: ",reply->get_list[i].dcp_clin_cat_cd))
   CALL echo(build("rxmask: ",reply->get_list[i].rx_mask))
   CALL echo(build("refText:",reply->get_list[i].ref_text_mask))
   CALL echo(build("synonym_id:",reply->get_list[i].synonym_id))
 ENDFOR
 CALL echo(build("count1: ",count1))
 CALL echo(build("count: ",request->count))
 CALL echo(build("filterorc: ",filter_orc))
#exit_script
END GO
