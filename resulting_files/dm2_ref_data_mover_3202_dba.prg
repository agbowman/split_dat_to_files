CREATE PROGRAM dm2_ref_data_mover_3202:dba
 FREE RECORD dyn_ui_search
 RECORD dyn_ui_search(
   1 qual[*]
     2 pk_value = f8
     2 other = vc
 )
 IF (validate(drdm_sequence->qual[1].seq_val,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(ui_query_rec->table_name,"NONE")="NONE")
  FREE RECORD ui_query_rec
  RECORD ui_query_rec(
    1 table_name = vc
    1 dom = vc
    1 usage = vc
    1 qual[*]
      2 qtype = vc
      2 where_clause = vc
      2 cqual[*]
        3 query_idx = i2
      2 other_pk_col[*]
        3 col_name = vc
  )
  FREE RECORD ui_query_eval_rec
  RECORD ui_query_eval_rec(
    1 qual[*]
      2 root_entity_attr = f8
      2 additional_attr = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
  )
 ENDIF
 DECLARE find_p_e_col(sbr_p_e_name=vc,sbr_p_e_col=i4) = vc
 DECLARE dm_translate(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc) = vc
 DECLARE dm_trans2(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc,sbr_src_ind=i2) = vc
 DECLARE dm_trans3(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=f8,sbr_src_ind=i2,sbr_pe_tbl_name=vc)
  = vc
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE add_rs_values(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = i4
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 SUBROUTINE query_target(qt_temp_tbl_cnt,qt_perm_col_cnt)
   DECLARE sbr_active_value = i2
   DECLARE sbr_effective_date = f8
   DECLARE sbr_end_effective_date = f8
   DECLARE sbr_returned_value = f8
   DECLARE sbr_cur_date = f8
   DECLARE sbr_rec_size = i4
   DECLARE sbr_null_beg_ind = i2
   DECLARE sbr_null_end_ind = i2
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET drdm_return_var = 0
   IF ((dm2_ref_data_doc->tbl_qual[qt_temp_tbl_cnt].merge_delete_ind=1))
    RETURN(- (3))
   ELSE
    SET dm_err->eproc = "Query Target"
    CALL echo("")
    CALL echo("")
    CALL echo("*******************QUERY TARGET***************************")
    CALL echo("")
    CALL echo("")
    SET sbr_rec_size = 1
    SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
    SET ui_query_rec->table_name = sbr_table_name
    SET ui_query_rec->usage = ""
    SET ui_query_rec->dom = "TO"
    SET ui_query_rec->qual[sbr_rec_size].qtype = "UIONLY"
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1))
     SET sbr_rec_size = (sbr_rec_size+ 1)
     SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
     SET sbr_active_value = cnvtreal(get_value(sbr_table_name,"ACTIVE_IND","FROM"))
     IF (sbr_active_value=1)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "ACTIVE"
     ELSE
      SET ui_query_rec->qual[sbr_rec_size].qtype = "INACTIVE"
     ENDIF
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
     SET sbr_null_beg_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      beg_col_name)
     SET sbr_null_end_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      end_col_name)
     IF (((sbr_null_beg_ind=1) OR (sbr_null_end_ind=1)) )
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 0
     ELSE
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      CALL parser(concat("set sbr_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name," go "),1)
      CALL parser(concat("set sbr_end_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name," go "),1)
      IF (sbr_effective_date <= sbr_cur_date
       AND sbr_end_effective_date >= sbr_cur_date)
       SET ui_query_rec->qual[sbr_rec_size].qtype = "EFFECTIVE"
      ELSE
       SET ui_query_rec->qual[sbr_rec_size].qtype = "END_EFFECTIVE"
      ENDIF
     ENDIF
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "COMBO"
      SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].cqual,2)
      SET ui_query_rec->qual[sbr_rec_size].cqual[1].query_idx = 2
      SET ui_query_rec->qual[sbr_rec_size].cqual[2].query_idx = 3
     ENDIF
    ENDIF
    SET sbr_returned_value = exec_ui_query(qt_temp_tbl_cnt,qt_perm_col_cnt)
    SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].other_pk_col,0)
    RETURN(sbr_returned_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_ui_query(exec_tbl_cnt,exec_perm_col_cnt)
   DECLARE sbr_while_loop = i2
   DECLARE sbr_done_select = i2
   DECLARE sbr_loop = i2
   DECLARE sbr_other_loop = i2
   DECLARE query_cnt = i4
   DECLARE sbr_eff_date = f8
   DECLARE sbr_end_eff_date = f8
   DECLARE sbr_cur_date = f8
   DECLARE query_return = f8
   DECLARE rs_tab_prefix = vc
   DECLARE sbr_domain = vc
   DECLARE add_ndx = i4
   DECLARE ndx_loop = i4
   DECLARE add_col_name = vc
   DECLARE add_d_type = vc
   DECLARE euq_ord_col = vc
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET euq_ord_col = ""
   FOR (sbr_loop = 1 TO size(ui_query_eval_rec->qual,5))
     SET ui_query_eval_rec->qual[sbr_loop].additional_attr = ""
   ENDFOR
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      ELSE
       SET drdm_parser->statement[1].frag = "select into 'NL:' "
      ENDIF
      SET drdm_parser->statement[2].frag = concat(" from ",value(ui_query_rec->table_name)," dc ",
       " where ")
      SET drdm_parser_cnt = 3
      FOR (drdm_loop_cnt = 1 TO exec_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].unique_ident_ind=1))
         SET no_unique_ident = 1
         IF (drdm_parser_cnt > 3)
          SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ENDIF
         SET drdm_col_name = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].
         column_name
         SET drdm_from_con = concat(rs_tab_prefix,"->",sbr_domain,"_values.",drdm_col_name)
         IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_null=1))
          IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type IN ("DQ8",
          "F8", "I4", "I2")))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = NULL")
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
            " = null or ",drdm_col_name," = ' ')")
          ENDIF
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSEIF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_space=1))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
           " = ' ' or ",drdm_col_name," = null)")
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSE
          CASE (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type)
           OF "DQ8":
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
             " =  cnvtdatetime(",drdm_from_con,")")
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ELSE
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
             drdm_from_con)
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          ENDCASE
         ENDIF
        ENDIF
      ENDFOR
      IF (no_unique_ident=0)
       SET insert_update_reason = "There were no unique_ident_ind's for log_id "
       SET no_insert_update = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].
        custom_script,": There were no unique_ident_ind's")
       RETURN(- (2))
      ENDIF
      SET sbr_current_date = cnvtdatetime(curdate,curtime3)
      CASE (ui_query_rec->qual[sbr_loop].qtype)
       OF "UIONLY":
       OF patstring("ORDER*",0):
        SET ui_query_rec->qual[sbr_loop].where_clause = ""
       OF "ACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 1"
       OF "INACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 0"
       OF "EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,"<=  cnvtdatetime(sbr_cur_date) AND dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,">= cnvtdatetime(sbr_cur_date)")
       OF "END_EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,">=  cnvtdatetime(sbr_cur_date) OR dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,"<= cnvtdatetime(sbr_cur_date)")
       OF "COMBO":
        FOR (sbr_other_loop = 1 TO size(ui_query_rec->qual[sbr_loop].cqual,5))
          SET ui_query_rec->qual[sbr_loop].where_clause = concat(ui_query_rec->qual[sbr_loop].
           where_clause,ui_query_rec->qual[ui_query_rec->qual[sbr_loop].cqual[sbr_other_loop].
           query_idx].where_clause)
        ENDFOR
      ENDCASE
      IF ((ui_query_rec->qual[sbr_loop].where_clause != ""))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(ui_query_rec->qual[sbr_loop].
        where_clause)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF ((ui_query_rec->qual[sbr_loop].qtype="ORDER:*"))
       SET euq_ord_col = substring((findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)+ 1),(size(
         ui_query_rec->qual[sbr_loop].qtype) - findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)
        ),ui_query_rec->qual[sbr_loop].qtype)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ORDER BY dc.",euq_ord_col)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" head report",
       " stat = alterlist(ui_query_eval_rec->qual, 10)"," query_cnt = 0")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" detail query_cnt = query_cnt + 1 ")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "if (mod(query_cnt,10) = 1 and query_cnt != 1)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt + 9)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" endif")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
        "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF (size(ui_query_rec->qual[sbr_loop].other_pk_col,5) > 0)
       IF ((ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name != ""))
        SET add_col_name = ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name
        SET add_ndx = locateval(ndx_loop,1,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_cnt,
         add_col_name,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[ndx_loop].column_name)
        IF (add_ndx > 0)
         SET add_d_type = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[add_ndx].data_type
         IF ( NOT (add_d_type IN ("VC", "C*")))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = cnvtstring(dc.",add_col_name,")")
         ELSE
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = dc.",add_col_name)
         ENDIF
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" foot report",
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt)"," with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET query_return = - (1)
       SET sbr_done_select = 1
      ELSEIF ((query_return != - (1)))
       SET query_return = evaluate_exec_ui_query(query_cnt,exec_tbl_cnt,exec_perm_col_cnt)
      ENDIF
      IF ((((query_return=- (3))) OR (query_return >= 0)) )
       SET sbr_done_select = 1
      ELSE
       SET sbr_loop = (sbr_loop+ 1)
      ENDIF
     ENDIF
   ENDWHILE
   IF ((query_return=- (2))
    AND (ui_query_rec->usage != "VERSION"))
    SET insert_update_reason = "Multiple values returned with unique indicator query for log_id "
    SET no_insert_update = 1
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV06"
    SET drdm_mini_loop_status = "NOMV06"
    ROLLBACK
    CALL orphan_child_tab(sbr_table_name,"NOMV06")
    COMMIT
   ENDIF
   RETURN(query_return)
 END ;Subroutine
 SUBROUTINE evaluate_exec_ui_query(sbr_current_qual,eval_tbl_cnt,eval_perm_col_cnt)
   DECLARE sbr_eval_loop = i4
   DECLARE sbr_trans_val = vc
   DECLARE sbr_table_name = vc
   DECLARE sbr_root_entity_attr_val = f8
   DECLARE sbr_not_translated_count = i4
   DECLARE sbr_value_pos = i4
   DECLARE sbr_temp_pk_value = f8
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET sbr_eval_loop = 1
   SET sbr_not_translated_count = 0
   IF (sbr_current_qual=0)
    RETURN(- (3))
   ELSEIF (sbr_current_qual=1)
    IF ((((ui_query_rec->usage="VERSION")
     AND sbr_temp_pk_value != 0) OR ((ui_query_rec->usage != "VERSION"))) )
     SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
     SET select_merge_translate_rec->type = "TO"
     SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_trans_val="No Trans")
      SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
      RETURN(sbr_root_entity_attr_val)
     ELSE
      IF ((ui_query_rec->usage="VERSION"))
       SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
       RETURN(sbr_root_entity_attr_val)
      ELSE
       RETURN(- (3))
      ENDIF
     ENDIF
    ELSE
     SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
     RETURN(sbr_root_entity_attr_val)
    ENDIF
   ELSE
    IF ((ui_query_rec->usage="VERSION"))
     RETURN(- (2))
    ELSE
     FOR (sbr_eval_loop = 1 TO sbr_current_qual)
       SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
       SET select_merge_translate_rec->type = "TO"
       SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
       IF (sbr_trans_val="No Trans")
        SET sbr_not_translated_count = (sbr_not_translated_count+ 1)
        SET sbr_val_pos = sbr_eval_loop
       ENDIF
     ENDFOR
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_not_translated_count=0)
      RETURN(- (3))
     ELSEIF (sbr_not_translated_count=1)
      SET current_qual = ui_query_eval_rec->qual[sbr_val_pos].root_entity_attr
      RETURN(current_qual)
     ELSE
      RETURN(- (2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_update_row(iur_temp_tbl_cnt,iur_perm_col_cnt)
   DECLARE first_where = i2
   DECLARE active_in = i2
   DECLARE drdm_col_name = vc
   DECLARE drdm_table_name = vc
   DECLARE p_tab_ind = i2
   DECLARE sbr_data_type = vc
   DECLARE no_update_ind = i2
   DECLARE non_key_ind = i2
   DECLARE pk_cnt = i4
   DECLARE iur_tgt_pk_where = vc
   DECLARE iur_del_loop = i4
   DECLARE iur_del_ind = i2
   DECLARE iur_child_loop = i4
   DECLARE iur_child_pk_cnt = i4
   DECLARE src_pk_where = vc
   DECLARE iur_tbl_alias = vc
   SET iur_del_ind = 0
   SET drdm_table_name = concat("RS_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)
   SET dm_err->eproc = concat("Inserting or Updating Row ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   CALL echo("")
   CALL echo("")
   CALL echo("*******************INSERTING OR UPDATING ROW******************")
   CALL echo("")
   CALL echo("")
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1)
    AND (drdm_chg->log[drdm_log_loop].md_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," in (select ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          SET iur_child_pk_cnt = (iur_child_pk_cnt+ 1)
          IF (iur_child_pk_cnt=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" c.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].table_name," c where ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1)
         )
          IF (iur_del_ind=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
            "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
            column_name,
            "))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
            suffix,"->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop]
            .column_name,
            ")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = 1
         ENDIF
       ENDFOR
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
           tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = ") with nocounter go"
       IF (iur_del_ind=1
        AND iur_child_pk_cnt=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
     SET iur_child_pk_cnt = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," = ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          IF (iur_del_ind >= 1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,"))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,notrim(rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = (iur_del_ind+ 1)
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = " with nocounter go"
       IF (iur_del_ind=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   IF (nodelete_ind=1)
    RETURN(1)
   ENDIF
   SET p_tab_ind = 0
   SET first_where = 0
   SET no_update_ind = 0
   SET short_string = ""
   SET drdm_parser->statement[1].frag = concat("select into 'NL:' from ",value(dm2_ref_data_doc->
     tbl_qual[iur_temp_tbl_cnt].table_name)," dc where ")
   SET drdm_parser_cnt = 2
   IF ((((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))) )
    SET pk_cnt = 0
    FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
       SET pk_cnt = (pk_cnt+ 1)
       SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
       data_type
       SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
        column_name)
       SET drdm_from_con = concat(drdm_table_name,"->To_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where," and ")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
        AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
        IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
          " = null or dc.",drdm_col_name," = ' ')")
        ENDIF
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF (sbr_data_type="DQ8")
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
         " = cnvtdatetime(",drdm_from_con,")")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
         " = null or dc.",drdm_col_name," = ' ')")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSE
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
         drdm_from_con)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ELSE
       SET non_key_ind = 1
      ENDIF
    ENDFOR
    IF (pk_cnt=0)
     SET nodelete_ind = 1
     SET dm_err->emsg = "The table has no primary_key information, check to see if it is mergeable."
    ELSE
     SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
     CALL parse_statements(drdm_parser_cnt)
    ENDIF
   ENDIF
   IF (curqual > 0
    AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].insert_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as insert only, so this row will not be updated.",3)
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table",
       3)
      SET nodelete_ind = 1
      SET drdm_mini_loop_status = "NOMV99"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON4859"))
       IF (non_key_ind=1)
        SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].table_name,"  dc set ")
        SET drdm_parser_cnt = 2
        FOR (update_loop = 1 TO iur_perm_col_cnt)
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].db_data_type !=
          "*LOB"))
           IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].pk_ind=0))
            IF (drdm_parser_cnt > 2)
             SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
             SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
            ENDIF
            SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].
            column_name
            SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
            IF (drdm_col_name="ACTIVE_IND")
             IF (drdm_active_ind_merge=0)
              CALL parser(concat("set active_in = ",drdm_table_name,"->from_values.active_ind go"),1)
              IF (((active_in=0) OR ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[
              update_loop].exception_flg=8))) )
               IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
                AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y")
               )
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
               ELSE
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = active_in"
               ENDIF
              ELSE
               IF (((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt - pk_cnt)=1))
                SET no_update_ind = 1
               ELSE
                IF (drdm_parser_cnt=2)
                 SET drdm_parser_cnt = (drdm_parser_cnt - 1)
                ELSE
                 SET drdm_parser_cnt = (drdm_parser_cnt - 2)
                ENDIF
               ENDIF
              ENDIF
             ELSE
              IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
               AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
               SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
              ELSE
               SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.ACTIVE_IND = ",
                drdm_from_con)
              ENDIF
             ENDIF
            ELSEIF (drdm_col_name="UPDT_TASK")
             SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
            ELSEIF (drdm_col_name="UPDT_DT_TM")
             SET drdm_parser->statement[drdm_parser_cnt].frag =
             " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
            ELSEIF (drdm_col_name="UPDT_CNT")
             SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = dc.UPDT_CNT + 1"
            ELSE
             IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
              AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = null")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].data_type=
             "DQ8"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = cnvtdatetime(",drdm_from_con,")")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_space=
             1))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '"
               )
             ELSE
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
               drdm_from_con)
             ENDIF
            ENDIF
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ENDIF
          ENDIF
        ENDFOR
        IF (no_update_ind=0)
         SET drdm_parser->statement[drdm_parser_cnt].frag = " where "
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = iur_tgt_pk_where
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
        SET current_merges = (current_merges+ 1)
        SET child_merge_audit->num[current_merges].action = "UPDATE"
        SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt
        ].table_name
       ENDIF
       SET ins_ind = 0
      ELSE
       SET p_tab_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ins_ind = 1
    SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," dc set ")
    SET drdm_parser_cnt = 2
    FOR (insert_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB")
      )
       SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].
       column_name
       SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF (drdm_col_name="UPDT_TASK")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
       ELSEIF (drdm_col_name="UPDT_DT_TM")
        SET drdm_parser->statement[drdm_parser_cnt].frag =
        " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
       ELSEIF (drdm_col_name="UPDT_CNT")
        SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = 0"
       ELSE
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_null=1)
         AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].nullable="Y"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null ")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
          " = cnvtdatetime(",drdm_from_con,")")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_space=1))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
          drdm_from_con)
        ENDIF
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
    ENDFOR
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "INSERT"
    SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
    table_name
   ENDIF
   SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
   IF (p_tab_ind=0
    AND no_update_ind=0)
    IF (ins_ind=0
     AND non_key_ind=0)
     CALL echo("No update will be done on this table because there are no non-key columns")
    ELSE
     CALL parse_statements(drdm_parser_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))
      SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
       iur_temp_tbl_cnt].table_name," dc set ")
      SET drdm_parser_cnt = 2
      FOR (insert_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type="*LOB"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name," = (select ")
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ",dm2_rdds_get_tbl_alias(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix),".",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name)
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_get_rdds_tname(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name)," ",dm2_rdds_get_tbl_alias(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," where ")
      SET iur_tbl_alias = concat(" ",dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].suffix))
      SET src_pk_where = " "
      SET pk_cnt = 0
      SET iur_perm_col_cnt = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt
      FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
         SET pk_cnt = (pk_cnt+ 1)
         SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
         data_type
         SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop
          ].column_name)
         SET drdm_from_con = concat(drdm_table_name,"->from_values.",drdm_col_name)
         IF (pk_cnt > 1)
          SET iur_tgt_pk_where = concat(src_pk_where," and ")
         ENDIF
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
          IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
           SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = null")
          ELSE
           SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
            " = null or ",iur_tbl_alias,".",drdm_col_name," = ' ')")
          ENDIF
         ELSEIF (sbr_data_type="DQ8")
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = cnvtdatetime(",
           drdm_from_con,")")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
          SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
           iur_tbl_alias,".",drdm_col_name," = ' ')")
         ELSE
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = ",
           drdm_from_con)
         ENDIF
        ENDIF
      ENDFOR
      IF (pk_cnt=0)
       SET nodelete_ind = 1
       SET dm_err->emsg =
       "The table has no primary_key information, check to see if it is mergeable."
       RETURN(1)
      ENDIF
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(src_pk_where,")")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" where ",iur_tgt_pk_where,
       " with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
     ENDIF
    ENDIF
   ENDIF
   FREE SET first_where
   FREE SET p_tab_ind
   FREE SET active_in
   FREE SET drdm_table_name
   IF (nodelete_ind=1)
    IF ((dm_err->ecode=288))
     SET drdm_mini_loop_status = "NOMV02"
     CALL merge_audit("FAILREASON","The row recieved a constraint violation when merged into target",
      1)
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV02")
     COMMIT
    ELSEIF ((dm_err->ecode=284))
     IF (findstring("ORA-20500:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV01"
      CALL merge_audit("FAILREASON","The row is related to a person that has been combined away",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV01")
      COMMIT
     ENDIF
     IF (findstring("ORA-20100:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV08"
      CALL merge_audit("FAILREASON","The row is trying to update the default row in target",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
      COMMIT
     ENDIF
    ENDIF
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
    SET drdm_chg->log[drdm_log_loop].reprocess_ind = 0
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_translate(sbr_tbl_name,sbr_col_name,sbr_from_val)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   SET to_val = "NOXLAT"
   SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
    index_var].table_name)
   SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[index_var].column_name)
   SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
    col_qual[dt_temp_col_cnt].root_entity_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE dm_trans2(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
     index_var].table_name)
    SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
     dt_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].exception_flg=1))
     RETURN(sbr_from_val)
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
     "", " ")))
      SET to_val = "BADLOG"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name =
       "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
       col_qual[dt_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val != "No Trans"
       AND findstring(".0",to_val)=0)
       SET to_val = concat(to_val,".0")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
   ENDIF
   SET dt_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[index_var]
    .table_name)
   IF ((dm2_ref_data_doc->tbl_qual[dt_root_tbl_cnt].mergeable_ind=0))
    SET to_val = "NOMV04"
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_seq_name = vc
   DECLARE smt_seq_num = f8
   DECLARE smt_cur_table = i4
   DECLARE smt_seq_loop = i4
   DECLARE smt_seq_val = i4
   DECLARE smt_xlat_env_tgt_id = f8
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
    tbl_qual[smt_loop].table_name)
   IF (smt_tbl_pos=0)
    SET smt_cur_table = temp_tbl_cnt
    SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
    SET temp_tbl_cnt = smt_cur_table
   ENDIF
   IF (smt_tbl_pos=0)
    RETURN(sbr_return_val)
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].skip_seqmatch_ind != 1))
    IF (sbr_t_name="REF_TEXT_RELTN")
     SET smt_seq_name = "REFERENCE_SEQ"
    ELSE
     FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
        SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
       ENDIF
     ENDFOR
    ENDIF
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found",3)
     RETURN(sbr_return_val)
    ENDIF
    SET smt_seq_val = locateval(smt_seq_loop,1,size(drdm_sequence->qual,5),smt_seq_name,drdm_sequence
     ->qual[smt_seq_loop].seq_name)
    IF (smt_seq_val=0)
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=smt_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
         cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
        AND d.info_name=smt_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       smt_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     IF (((curqual=0) OR ((smt_seq_num=- (1)))) )
      SET smt_cur_table = temp_tbl_cnt
      EXECUTE dm2_find_sequence_match smt_seq_name, dm2_ref_data_doc->env_source_id
      SET temp_tbl_cnt = smt_cur_table
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       SET dm_err->err_ind = 1
       SET drdm_error_ind = 1
       RETURN(sbr_return_val)
      ENDIF
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=smt_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
          cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
         AND d.info_name=smt_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        smt_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
      ENDIF
      IF (curqual=0)
       SET drdm_error_out_ind = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = "A sequence match could not be found in DM_INFO"
       CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
       RETURN("No Trans")
      ENDIF
     ENDIF
     SET stat = alterlist(drdm_sequence->qual,(size(drdm_sequence->qual,5)+ 1))
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_name = smt_seq_name
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_val = smt_seq_num
    ELSE
     SET smt_seq_num = drdm_sequence->qual[smt_seq_val].seq_val
    ENDIF
   ELSE
    SET smt_seq_num = 0
   ENDIF
   IF (cnvtreal(sbr_f_value) <= smt_seq_num)
    RETURN(sbr_f_value)
   ELSE
    SELECT
     IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSE
     ENDIF
     INTO "NL:"
     FROM dm_merge_translate dm
     DETAIL
      IF ((select_merge_translate_rec->type="TO"))
       sbr_return_val = cnvtstring(dm.from_value)
      ELSE
       sbr_return_val = cnvtstring(dm.to_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (sbr_return_val="No Trans"
     AND (global_mover_rec->loop_back_ind=1))
     SET source_table_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SELECT
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSE
      ENDIF
      INTO "NL:"
      FROM (parser(source_table_name) dm)
      DETAIL
       IF ((select_merge_translate_rec->type != "TO"))
        sbr_return_val = cnvtstring(dm.from_value)
       ELSE
        sbr_return_val = cnvtstring(dm.to_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (sbr_return_val != "No Trans")
    CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,3)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = "Updating DM_CHG_LOG Table drdm_chg->log[drdm_log_loop].log_id"
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET dcl_rec_parse->qual[1].parse_stmts = concat("select into 'nl:' from ",sbr_tname_flex)
   SET dcl_rec_parse->qual[2].parse_stmts = " d where log_id = drdm_chg->log[drdm_log_loop].log_id"
   SET dcl_rec_parse->qual[3].parse_stmts = " detail update_cnt = d.updt_cnt with nocounter go"
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
   ENDIF
   SET stat = alterlist(dcl_rec_parse->qual,0)
   SET stat = alterlist(dcl_rec_parse->qual,8)
   IF ((((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt)) OR (sbr_log_type="REFCHG")) )
    IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
     SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
    ELSE
     SET sbr_flex_pos = drdm_log_loop
    ENDIF
    SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex,
     " d1, (dummyt d with seq = size(drdm_pair_info->qual)) ")
    SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
    SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[4].parse_stmts = concat(
      " d1.updt_dt_tm = cnvtlookahead(sbr_look_ahead, cnvtdatetime(curdate,curtime3)),")
    ELSE
     SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
    ENDIF
    SET dcl_rec_parse->qual[5].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 plan d where",
     " drdm_pair_info->qual[d.seq].log_id > 0 ")
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" join d1 where d1.log_id = ",
     " drdm_pair_info->qual[d.seq].log_id")
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES'"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = concat(" and d1.updt_cnt = ",
      " drdm_pair_info->qual[d.seq].updt_cnt")
    ENDIF
    SET dcl_rec_parse->qual[8].parse_stmts = " with nocounter go"
    EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not process log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop
       ].log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    CALL merge_audit("FAILREASON",nodelete_msg,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    WHERE dmt.to_value=sbr_to
     AND concat(dmt.table_name,"")=sbr_table
     AND (dmt.env_source_id=dm2_ref_data_doc->env_source_id)
     AND dmt.env_target_id=imt_xlat_env_tgt_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = drdm_chg->log[drdm_log_loop
      ].status_flg, dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=0)
     IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.from_value = sbr_from,
        d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
        d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     COMMIT
    ENDIF
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE find_p_e_col(sbr_p_e_name,sbr_p_e_col)
   DECLARE p_e_name = vc
   DECLARE r_e_name = vc
   DECLARE p_e_col = vc
   DECLARE tbl_loop = i4
   DECLARE kickout = i4
   DECLARE p_e_tbl_pos = i4
   DECLARE p_e_col_pos = i4
   DECLARE p_e_where_str = vc
   DECLARE pk_pos = i4
   DECLARE temp_name = vc
   DECLARE mult_cnt = i4
   DECLARE pk_num = i4
   DECLARE good_pk = i4
   DECLARE pk_name = vc
   DECLARE id_ind = i2
   DECLARE info_alias = vc
   DECLARE i_domain = vc
   DECLARE i_name = vc
   DECLARE p_e_dummy_cnt = i4
   DECLARE temp_r_e_name = vc
   SET p_e_name = "INVALIDTABLE"
   SET r_e_name = sbr_p_e_name
   SET info_alias = ""
   SET id_ind = 0
   SET pk_num = 0
   SET pk_name = ""
   SET good_pk = 0
   WHILE (p_e_name != r_e_name)
     SET p_e_name = r_e_name
     SET r_e_name = "INVALIDTABLE"
     SET pk_pos = 0
     SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[tbl_loop]
      .tbl_name)
     IF (pk_pos=0)
      SELECT INTO "NL:"
       FROM dtable d
       WHERE d.table_name=p_e_name
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
       SET i_name = concat(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_p_e_col].
        parent_entity_col,":",p_e_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="RDDS_PE_ABBREVIATIONS"
         AND d.info_name=p_e_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=i_domain
         AND d.info_name=i_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       IF (info_alias="")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
        CALL echo("Parent_entity_col could not be found")
       ELSE
        SET p_e_name = info_alias
        SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[
         tbl_loop].tbl_name)
        IF (pk_pos=0)
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
         CALL echo("Parent_entity_col could not be found")
        ENDIF
       ENDIF
      ELSE
       CALL echo(concat("The following table is activity: ",p_e_name))
       SET p_e_name = "INVALIDTABLE"
       SET r_e_name = p_e_name
      ENDIF
     ENDIF
     IF (pk_pos != 0)
      IF ((dguc_reply->dtd_hold[tbl_loop].pk_cnt > 1))
       FOR (mult_cnt = 1 TO dguc_reply->dtd_hold[tbl_loop].pk_cnt)
         IF ((((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID")) OR ((((dguc_reply->
         dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*CD")) OR ((dguc_reply->dtd_hold[tbl_loop].
         pk_hold[mult_cnt].pk_name="CODE_VALUE"))) )) )
          IF ((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID"))
           SET id_ind = 1
          ENDIF
          SET pk_num = (pk_num+ 1)
          SET good_pk = mult_cnt
         ENDIF
       ENDFOR
       IF (pk_num > 1)
        IF (id_ind=1)
         CALL echo("This Parent_Entity Table has more than a single Primary Key")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
        ENDIF
       ELSE
        SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
       ENDIF
      ELSE
       SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[1].pk_name
      ENDIF
      IF (p_e_name != "INVALIDTABLE")
       SET p_e_col = pk_name
       SET p_e_tbl_pos = 0
       SET p_e_tbl_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_cnt,p_e_name,dm2_ref_data_doc->
        tbl_qual[tbl_loop].table_name)
       IF (p_e_tbl_pos=0)
        SET p_e_dummy_cnt = temp_tbl_cnt
        SET p_e_tbl_pos = fill_rs("TABLE",p_e_name)
        SET temp_tbl_cnt = p_e_dummy_cnt
        IF (p_e_tbl_pos=0)
         CALL echo("Information not found for table level meta-data")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET temp_r_e_name = r_e_name
         FOR (p_e_dummy_cnt = 1 TO dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].column_name=p_e_col))
            SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].
            root_entity_name
           ENDIF
         ENDFOR
         IF (temp_r_e_name=r_e_name)
          CALL echo("Information not found for table level meta-data")
          SET p_e_name = "INVALIDTABLE"
          SET r_e_name = p_e_name
         ENDIF
        ENDIF
       ENDIF
       IF (p_e_tbl_pos != 0)
        SET p_e_col_pos = 0
        SET p_e_col_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt,
         p_e_col,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[tbl_loop].column_name)
        IF (p_e_col_pos=0)
         CALL echo("Information not found in dm_columns_doc for column")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_col_pos].
         root_entity_name
        ENDIF
       ENDIF
       SET kickout = (kickout+ 1)
       IF (kickout=5)
        CALL echo("Searched through 5 Parent_entity_columns")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF (p_e_name="INVALIDTABLE")
    ROLLBACK
    SET drdm_mini_loop_status = "NOMV99"
    CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV99")
    COMMIT
   ENDIF
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt=0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET drdm_error_out_ind = 1
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = text, dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET drdm_error_out_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = text, dm.table_name = ma_table_name, dm.dm_chg_log_audit_id = ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET drdm_error_out_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   DECLARE missing_cnt = i4
   DECLARE source_tab_name = vc
   DECLARE insert_log_type = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET source_tab_name = dm2_get_rdds_tname(sbr_table_name)
   SET except_log_type = "NOXLAT"
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
     IF (sbr_table_name="DCP_FORMS_REF")
      CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
     ELSEIF (sbr_table_name="DCP_SECTION_REF")
      CALL parser(" where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",
       0)
     ELSE
      CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
     ENDIF
     CALL parser(" with nocounter go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF (curqual=0)
       SET except_log_type = "ORPHAN"
       INSERT  FROM (parser(except_tab) d)
        SET d.log_type = "ORPHAN", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
         d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET nodelete_ind = 1
        SET no_insert_update = 1
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
     ENDIF
     SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
     IF (missing_cnt > 0)
      IF (except_log_type="ORPHAN")
       SET missing_xlats->qual[missing_cnt].orphan_ind = 1
       SET missing_xlats->qual[missing_cnt].processed_ind = 1
      ELSE
       SET missing_xlats->qual[missing_cnt].orphan_ind = 0
       SET missing_xlats->qual[missing_cnt].processed_ind = 0
      ENDIF
     ENDIF
     RETURN(except_log_type)
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER", "NOMV*"))
      RETURN(except_log_type)
     ELSE
      CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
      IF (sbr_table_name="DCP_FORMS_REF")
       CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
      ELSEIF (sbr_table_name="DCP_SECTION_REF")
       CALL parser(
        " where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",0)
      ELSE
       CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
      ENDIF
      CALL parser(" with nocounter go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
      ELSE
       IF (curqual=0)
        UPDATE  FROM (parser(except_tab) d)
         SET d.log_type = "ORPHAN"
         WHERE d.table_name=sbr_table_name
          AND d.from_value=sbr_value
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET nodelete_ind = 1
         SET no_insert_update = 1
         SET drdm_error_out_ind = 1
         SET dm_err->err_ind = 0
        ENDIF
        RETURN("ORPHAN")
       ELSE
        SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
        IF (missing_cnt > 0)
         SET missing_xlats->qual[missing_cnt].processed_ind = 0
         SET missing_xlats->qual[missing_cnt].orphan_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(except_log_type)
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     INSERT  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
       d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ELSEIF (except_log_type != "OLDVER")
     UPDATE  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER"
      WHERE d.table_name=sbr_table_name
       AND d.column_name=sbr_column_name
       AND d.from_value=sbr_value
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   DELETE  FROM (parser(except_tab) d)
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
    SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
     dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
    IF (oct_tab_cnt=0)
     SET dm_err->err_msg = "The table name could not be found in the meta-data record structure"
     SET nodelete_ind = 1
    ENDIF
   ELSE
    SET oct_tab_cnt = temp_tbl_cnt
   ENDIF
   SET oct_col_cnt = 0
   FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
     IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
     sbr_table_name))
      SET oct_col_cnt = oct_tab_loop
     ENDIF
   ENDFOR
   IF (oct_col_cnt=0)
    RETURN(0)
   ENDIF
   CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
     "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
     " go "),1)
   SET oct_excptn_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     DETAIL
      oct_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end select
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual=0)
    INSERT  FROM (parser(oct_excptn_tab) d)
     SET d.table_name = sbr_table_name, d.column_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].
      col_qual[oct_col_cnt].column_name, d.target_env_id = dm2_ref_data_doc->env_target_id,
      d.from_value = oct_pk_value, d.log_type = sbr_log_type
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    UPDATE  FROM (parser(oct_excptn_tab) d)
     SET d.log_type = sbr_log_type
     WHERE d.table_name=sbr_table_name
      AND d.column_name=oct_col_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_except_tab = vc
   DECLARE inx_log_type = vc
   DECLARE inx_col_name = vc
   SET inx_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     DETAIL
      inx_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end select
    SET inx_col_name = sbr_column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    RETURN(1)
   ENDIF
   IF (curqual=0)
    IF (sbr_orphan_ind=1)
     SET inx_log_type = "ORPHAN"
    ELSE
     SET inx_log_type = "NOXLAT"
    ENDIF
    INSERT  FROM (parser(inx_except_tab) d)
     SET d.log_type = inx_log_type, d.table_name = sbr_table_name, d.column_name = sbr_column_name,
      d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE arv_loop = i4
   DECLARE arv_cnt = i4
   DECLARE arv_found = i2
   SET arv_cnt = size(missing_xlats->qual,5)
   SET arv_found = 0
   FOR (arv_loop = 1 TO arv_cnt)
     IF ((missing_xlats->qual[arv_loop].table_name=sbr_table_name)
      AND (missing_xlats->qual[arv_loop].column_name=sbr_column_name)
      AND (missing_xlats->qual[arv_loop].missing_value=sbr_value))
      SET arv_found = 1
     ENDIF
   ENDFOR
   IF (arv_found=0)
    SET arv_cnt = (arv_cnt+ 1)
    SET stat = alterlist(missing_xlats->qual,arv_cnt)
    SET missing_xlats->qual[arv_cnt].table_name = sbr_table_name
    SET missing_xlats->qual[arv_cnt].column_name = sbr_column_name
    SET missing_xlats->qual[arv_cnt].missing_value = sbr_value
    RETURN(arv_cnt)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_trans3(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind,sbr_pe_tbl_name)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt3_temp_tbl_cnt = i4
   DECLARE dt3_temp_col_cnt = i4
   DECLARE dt3_from_con = vc
   DECLARE dt3_domain = vc
   DECLARE dt3_name = vc
   DECLARE dt3_find = i4
   DECLARE dt3_pk_column = vc
   DECLARE dt3_pk_tab_name = vc
   DECLARE dt3_root_tbl_cnt = i4
   IF (sbr_from_val=0)
    RETURN("0")
   ENDIF
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt3_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->
     tbl_qual[index_var].table_name)
    SET dt3_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->
     tbl_qual[dt3_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].exception_flg=1))
     RETURN(cnvtstring(sbr_from_val))
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
      IN ("", " ")))
      IF (sbr_pe_tbl_name != ""
       AND sbr_pe_tbl_name != " ")
       SET dt3_pk_tab_name = find_p_e_col(sbr_pe_tbl_name,dt3_temp_col_cnt)
      ELSE
       SET dt3_pk_tab_name = "INVALIDTABLE"
       SET dt3_domain = concat("RDDS_PE_ABBREV:",sbr_tbl_name)
       SET dt3_name = concat(sbr_col_name,":",dt3_pk_tab_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=dt3_domain
         AND d.info_name=dt3_name
        DETAIL
         dt3_pk_tab_name = d.info_char
        WITH nocounter
       ;end select
      ENDIF
      IF (dt3_pk_tab_name != "")
       IF (dt3_pk_tab_name != "INVALIDTABLE")
        IF (dt3_pk_tab_name="PERSON")
         SET dt3_pk_tab_name = "PRSNL"
        ENDIF
        SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dt3_pk_tab_name)
       ENDIF
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dt3_pk_tab_name,dm2_ref_data_doc->
        tbl_qual[index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET dt3_find = locateval(dt3_find,1,size(dm2_ref_data_doc->tbl_qual,5),dt3_pk_tab_name,
         dm2_ref_data_doc->tbl_qual[dt3_find].table_name)
        FOR (dt3_i = 1 TO size(dm2_ref_data_doc->tbl_qual[dt3_find].col_qual,5))
          IF ((dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].pk_ind=1)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name=dm2_ref_data_doc->
          tbl_qual[dt3_find].col_qual[dt3_i].root_entity_attr)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].root_entity_name=
          dm2_ref_data_doc->tbl_qual[dt3_find].table_name))
           SET dt3_pk_column = dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name
          ENDIF
        ENDFOR
        SET to_val = report_missing(dt3_pk_tab_name,dt3_pk_column,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
        = "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dm2_ref_data_doc->tbl_qual[
       dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
        dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[
        index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_attr,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = cnvtstring(sbr_from_val)
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_error_ind = i2
   DECLARE tpc_col_loop = i4
   DECLARE tpc_col_pos = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_f8_var = f8
   DECLARE tpc_i4_var = i4
   DECLARE tpc_vc_var = vc
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_main_proc = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   SET tpc_pk_where_vc = tpc_pk_where
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_PARM")
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       " = ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   IF (((size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5) != 1) OR ((pk_where_parm->qual[
   tpc_pktbl_cnt].col_qual[1].col_name != tpc_col_name))) )
    SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
    SET tpc_row_cnt = 0
    CALL parser("select into 'NL:' ",0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     IF (tpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(tpc_tbl_loop)," = nullind(",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,")"),0)
    ENDFOR
    CALL parser(concat("from ",tpc_src_tab_name," ",tpc_suffix," ",
      tpc_pk_where_vc,
      " detail  tpc_row_cnt = tpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, tpc_row_cnt) "),0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name," = ",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name),0)
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(tpc_tbl_loop)),0)
    ENDFOR
    CALL parser("with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
    IF (tpc_row_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    SET tpc_row_cnt = 1
    SET stat = alterlist(cust_cs_rows->qual,1)
    CALL parser(concat("set cust_cs_rows->qual[1].",tpc_col_name," = tpc_value go"),0)
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET tpc_main_proc = dm2_get_rdds_tname("PROC_REFCHG_INS_LOG")
    SET tpc_proc_name = dm2_get_rdds_tname(tpc_proc_name)
    FOR (tpc_row_loop = 1 TO tpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("RDB ASIS(^ BEGIN ",tpc_main_proc,"('",
       tpc_table_name,"',^)")
      SET drdm_parser->statement[2].frag = concat(" ASIS (^",tpc_proc_name,"('INS/UPD'^)")
      SET drdm_parser_cnt = 3
      FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
        CALL parser(concat("set tpc_col_nullind = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
          qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (tpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , NULL ^)")
         SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
          col_qual,5))].frag = concat("ASIS (^ , NULL ^)")
        ELSE
         SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_f8_var,15),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_f8_var,15),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ ,to_date('",format(
            tpc_f8_var,"DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ ,to_date('",format(tpc_f8_var,
            "DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set tpc_i4_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_i4_var),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_i4_var),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type="C*"))
          CALL parser(concat("declare tpc_c_var = C",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
            col_qual[tpc_col_pos].data_length," go"),1)
          CALL parser(concat("set tpc_c_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->qual[
            tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
         ELSE
          CALL parser(concat("set tpc_vc_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET tpc_vc_var = replace_carrot_symbol(tpc_vc_var)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ASIS (^), dbms_utility.get_hash_value(^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^",tpc_proc_name,
       "('INS/UPD'^)")
      SET drdm_parser_cnt = ((drdm_parser_cnt+ 1)+ size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5
       ))
      SET drdm_parser->statement[drdm_parser_cnt].frag = "ASIS (^),0,1073741824.0), ^)"
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'REFCHG',0,",cnvtstring(
        reqinfo->updt_id,15),",",cnvtstring(reqinfo->updt_task),",",
       cnvtstring(reqinfo->updt_applctx),", ^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'",tpc_context,"',",
       cnvtstring(dm2_ref_data_doc->env_target_id,15),"); END; ^) GO")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET tpc_error_ind = 1
       SET tpc_row_loop = tpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(tpc_error_ind)
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_row_cnt = 0
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   CALL parser("select into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    IF (fpc_tbl_loop > 1)
     CALL parser(" , ",0)
    ENDIF
    CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pk_where,
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),0)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = cust_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_f8_var,15),
           " , ",cnvtstring(fpc_f8_var,15))
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS'),","to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),
           "','DD-MON-YYYY HH24:MI:SS')")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET fpc_vc_var = replace(fpc_vc_var,"'","''",0)
          SET fpc_vc_var = concat("'",fpc_vc_var,"'")
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 IF ((validate(dcr_max_stack_size,- (1))=- (1))
  AND (validate(dcr_max_stack_size,- (2))=- (2)))
  DECLARE dcr_max_stack_size = i4 WITH protect, constant(30)
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0
  AND validate(dm_err->ecode,722)=722)
  FREE RECORD dm_err
  IF (currev >= 8)
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = vc
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ELSE
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = c132
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ENDIF
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 IF (validate(dm2_sys_misc->cur_os,"X")="X"
  AND validate(dm2_sys_misc->cur_os,"Y")="Y")
  FREE RECORD dm2_sys_misc
  RECORD dm2_sys_misc(
    1 cur_os = vc
    1 cur_db_os = vc
  )
  SET dm2_sys_misc->cur_os = validate(cursys2,cursys)
  SET dm2_sys_misc->cur_db_os = validate(currdbsys,cursys)
  IF (size(dm2_sys_misc->cur_db_os) != 3)
   SET dm2_sys_misc->cur_db_os = substring(1,(findstring(":",dm2_sys_misc->cur_db_os,1,1) - 1),
    dm2_sys_misc->cur_db_os)
  ENDIF
 ENDIF
 IF (validate(dm2_install_schema->process_option," ")=" "
  AND validate(dm2_install_schema->process_option,"NOTTHERE")="NOTTHERE")
  FREE RECORD dm2_install_schema
  RECORD dm2_install_schema(
    1 process_option = vc
    1 file_prefix = vc
    1 schema_loc = vc
    1 schema_prefix = vc
    1 target_dbase_name = vc
    1 dbase_name = vc
    1 u_name = vc
    1 p_word = vc
    1 connect_str = vc
    1 v500_p_word = vc
    1 v500_connect_str = vc
    1 cdba_p_word = vc
    1 cdba_connect_str = vc
    1 run_id = i4
    1 menu_driver = vc
    1 oragen3_ignore_dm_columns_doc = i2
    1 last_checkpoint = vc
    1 gen_id = i4
    1 restart_method = i2
    1 appl_id = vc
    1 hostname = vc
    1 ccluserdir = vc
    1 cer_install = vc
    1 servername = vc
    1 frmt_servername = vc
    1 default_fg_name = vc
    1 curprog = vc
    1 adl_username = vc
    1 tgt_sch_cleanup = i2
    1 special_ih_process = i2
    1 dbase_type = vc
    1 data_to_move = c30
    1 percent_tspace = i4
    1 src_dbase_name = vc
    1 src_v500_p_word = vc
    1 src_v500_connect_str = vc
    1 logfile_prefix = vc
    1 src_run_id = f8
    1 src_op_id = f8
    1 target_env_name = vc
    1 dm2_updt_task_value = i2
  )
  SET dm2_install_schema->process_option = "NONE"
  SET dm2_install_schema->file_prefix = "NONE"
  SET dm2_install_schema->schema_loc = "NONE"
  SET dm2_install_schema->schema_prefix = "NONE"
  SET dm2_install_schema->target_dbase_name = "NONE"
  SET dm2_install_schema->dbase_name = "NONE"
  SET dm2_install_schema->u_name = "NONE"
  SET dm2_install_schema->p_word = "NONE"
  SET dm2_install_schema->connect_str = "NONE"
  SET dm2_install_schema->v500_p_word = "NONE"
  SET dm2_install_schema->v500_connect_str = "NONE"
  SET dm2_install_schema->cdba_p_word = "NONE"
  SET dm2_install_schema->cdba_connect_str = "NONE"
  SET dm2_install_schema->run_id = 0
  SET dm2_install_schema->menu_driver = "NONE"
  SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
  SET dm2_install_schema->last_checkpoint = "NONE"
  SET dm2_install_schema->gen_id = 0
  SET dm2_install_schema->restart_method = 0
  SET dm2_install_schema->appl_id = "NONE"
  SET dm2_install_schema->hostname = "NONE"
  SET dm2_install_schema->servername = "NONE"
  SET dm2_install_schema->default_fg_name = "NONE"
  SET dm2_install_schema->curprog = "NONE"
  SET dm2_install_schema->adl_username = "NONE"
  SET dm2_install_schema->tgt_sch_cleanup = 0
  SET dm2_install_schema->special_ih_process = 0
  SET dm2_install_schema->dbase_type = "NONE"
  SET dm2_install_schema->data_to_move = "NONE"
  SET dm2_install_schema->percent_tspace = 0
  SET dm2_install_schema->src_dbase_name = "NONE"
  SET dm2_install_schema->src_v500_p_word = "NONE"
  SET dm2_install_schema->src_v500_connect_str = "NONE"
  SET dm2_install_schema->logfile_prefix = "NONE"
  SET dm2_install_schema->src_run_id = 0
  SET dm2_install_schema->src_op_id = 0
  SET dm2_install_schema->target_env_name = "NONE"
  SET dm2_install_schema->dm2_updt_task_value = 15301
  IF ((dm2_sys_misc->cur_os="WIN"))
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ELSE
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ENDIF
 ENDIF
 IF (validate(inhouse_misc->inhouse_domain,- (1)) < 0
  AND validate(inhouse_misc->inhouse_domain,722)=722)
  FREE RECORD inhouse_misc
  RECORD inhouse_misc(
    1 inhouse_domain = i2
    1 fk_err_ind = i2
    1 nonfk_err_ind = i2
    1 fk_parent_table = vc
    1 tablespace_err_code = f8
    1 foreignkey_err_code = f8
  )
  SET inhouse_misc->inhouse_domain = - (1)
  SET inhouse_misc->fk_err_ind = 0
  SET inhouse_misc->nonfk_err_ind = 0
  SET inhouse_misc->fk_parent_table = ""
  SET inhouse_misc->tablespace_err_code = 93
  SET inhouse_misc->foreignkey_err_code = 94
 ENDIF
 IF (validate(program_stack_rs->cnt,1)=1
  AND validate(program_stack_rs->cnt,2)=2)
  FREE RECORD program_stack_rs
  RECORD program_stack_rs(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
  SET stat = alterlist(program_stack_rs->qual,dcr_max_stack_size)
 ENDIF
 DECLARE dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) = i2
 DECLARE dm2_push_dcl(sbr_dpdstr=vc) = i2
 DECLARE get_unique_file(sbr_fprefix=vc,sbr_fext=vc) = i2
 DECLARE parse_errfile(sbr_errfile=vc) = i2
 DECLARE check_error(sbr_ceprocess=vc) = i2
 DECLARE disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) = null
 DECLARE init_logfile(sbr_logfile=vc,sbr_header_msg=vc) = i2
 DECLARE check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) = i2
 DECLARE final_disp_msg(sbr_log_prefix=vc) = null
 DECLARE dm2_set_autocommit(sbr_dsa_flag=i2) = i2
 DECLARE dm2_prg_maint(sbr_maint_type=vc) = i2
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_table_exists(dte_table_name=vc) = c1
 DECLARE dm2_table_and_ccldef_exists(dtace_table_name=vc,dtace_found_ind=i2(ref)) = i2
 DECLARE dm2_table_column_exists(dtce_owner=vc,dtce_table_name=vc,dtce_column_name=vc,
  dtce_col_chk_ind=i2,dtce_coldef_chk_ind=i2,
  dtce_ccldef_mode=i2,dtce_col_fnd_ind=i2(ref),dtce_coldef_fnd_ind=i2(ref),dtce_data_type=vc(ref)) =
 i2
 DECLARE dm2_disp_file(ddf_fname=vc,ddf_desc=vc) = i2
 DECLARE dm2_get_program_stack(null) = vc
 SUBROUTINE dm2_push_cmd(sbr_dpcstr,sbr_cmd_end)
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_cmd executing: ",sbr_dpcstr))
    CALL echo("*")
   ENDIF
   CALL parser(sbr_dpcstr,1)
   SET dm_err->tempstr = concat(dm_err->tempstr," ",sbr_dpcstr)
   IF (sbr_cmd_end=1)
    IF ((dm_err->err_ind=0))
     IF (check_error(concat("dm2_push_cmd executing: ",dm_err->tempstr))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->tempstr = " "
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->tempstr = " "
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_dcl(sbr_dpdstr)
   DECLARE dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE newstr = vc WITH protect
   DECLARE strloc = i4 WITH protect, noconstant(0)
   DECLARE temp_file = vc WITH protect, noconstant(" ")
   DECLARE str2 = vc WITH protect, noconstant(" ")
   DECLARE posx = i4 WITH protect, noconstant(0)
   DECLARE sql_warn_ind = i2 WITH protect, noconstant(0)
   DECLARE dpd_disp_dcl_err_ind = i2 WITH protect, noconstant(1)
   IF ((validate(dm_err->disp_dcl_err_ind,- (1))=- (1))
    AND (validate(dm_err->disp_dcl_err_ind,- (2))=- (2)))
    SET dpd_disp_dcl_err_ind = 1
   ELSE
    SET dpd_disp_dcl_err_ind = dm_err->disp_dcl_err_ind
    SET dm_err->disp_dcl_err_ind = 1
   ENDIF
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AXP")))
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET temp_file = build(substring((strloc+ 1),((strlength - strloc) - 4),sbr_dpdstr))
     ELSE
      SET temp_file = build(substring((strloc+ 1),(strlength - strloc),sbr_dpdstr))
     ENDIF
     SET newstr = sbr_dpdstr
    ELSE
     SET newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (dm2_sys_misc->cur_os)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
      ELSE
       IF ((dm2_sys_misc->cur_os != "AXP"))
        SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
       ENDIF
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     IF (dpd_disp_dcl_err_ind=1)
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",newstr)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     ELSE
      IF ((dm_err->debug_flag > 1))
       CALL echo("Call dcl failed- error handling done by calling script")
      ENDIF
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("PARSING THROUGH - ",dm_err->errfile))
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_unique_file(sbr_fprefix,sbr_fext)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   WHILE (fini=0)
     IF ((((validate(systimestamp,- (999.00))=- (999.00))
      AND validate(systimestamp,999.00)=999.00) OR (validate(dm2_bypass_unique_file,- (1))=1)) )
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
     ELSEIF ((validate(systimestamp,- (999.00)) != - (999.00))
      AND validate(systimestamp,999.00) != 999.00
      AND (validate(dm2_bypass_unique_file,- (1))=- (1))
      AND (validate(dm2_bypass_unique_file,- (2))=- (2)))
      SET unique_tempstr = format(systimestamp,"hhmmsscccccc;;q")
     ENDIF
     SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
     IF (findfile(fname)=0)
      SET fini = 1
     ENDIF
   ENDWHILE
   IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",sbr_fext
     ))=1)
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(dm_err->user_action)
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(guf_return_val)
 END ;Subroutine
 SUBROUTINE parse_errfile(sbr_errfile)
   SET dm_err->errtext = " "
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(sbr_errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm_err->errtext = build(dm_err->errtext,r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE disp_msg(sbr_demsg,sbr_dlogfile,sbr_derr_ind)
   DECLARE dm_txt = c132 WITH protect
   DECLARE dm_ecode = i4 WITH protect
   DECLARE dm_emsg = c132 WITH protect
   DECLARE dm_full_emsg = vc WITH protect
   DECLARE dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET dm_full_emsg = sbr_demsg
   ENDIF
   SET dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(dm_full_emsg)
   SET dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND sbr_derr_ind IN (0, 1, 10))
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;3;m"
      IF (sbr_derr_ind=1)
       row + 1, "* Component Name:  ", curprog,
       row + 1, "* Process Description:  "
      ENDIF
      dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, dm_txt
        IF (end_pos > dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
          eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,
           dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
           user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET dm_ecode = error(dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET dm_ecode = 1
    SET dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (dm_ecode > 0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_full_emsg)))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSEIF (sbr_derr_ind IN (0, 20))
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(dm_err->eproc)
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE init_logfile(sbr_logfile,sbr_header_msg)
   DECLARE init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != "")
    SELECT INTO value(sbr_logfile)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;;m", row + 1, sbr_header_msg,
      row + 1, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
    IF (check_error(concat("Creating log file ",trim(sbr_logfile)))=1)
     SET init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET init_return_val = 0
   ENDIF
   IF (init_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   RETURN(init_return_val)
 END ;Subroutine
 SUBROUTINE check_logfile(sbr_lprefix,sbr_lext,sbr_hmsg)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 9))
     SET trace = echoprogsub
     IF (((currev > 8) OR (currev=8
      AND currevminor >= 1)) )
      SET trace = echosub
     ENDIF
    ENDIF
    IF (get_unique_file(sbr_lprefix,sbr_lext)=0)
     RETURN(0)
    ENDIF
    SET dm_err->logfile = dm_err->unique_fname
    IF (init_logfile(dm_err->logfile,sbr_hmsg)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_prg_maint("BEGIN")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE final_disp_msg(sbr_log_prefix)
   DECLARE plength = i2
   SET plength = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,plength,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_set_autocommit(sbr_dsa_flag)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_prg_maint(sbr_maint_type)
   IF ( NOT (cnvtupper(trim(sbr_maint_type,3)) IN ("BEGIN", "END")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid maintenance type"
    SET dm_err->eproc = "Performing program maintenance"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("********************************************************")
    CALL echo("* CCL current resource usage statistics                *")
    CALL echo("********************************************************")
    CALL trace(7)
   ENDIF
   IF (cnvtupper(trim(sbr_maint_type,3))="BEGIN")
    IF ((program_stack_rs->cnt < dcr_max_stack_size))
     SET program_stack_rs->cnt = (program_stack_rs->cnt+ 1)
     SET program_stack_rs->qual[program_stack_rs->cnt].name = curprog
    ENDIF
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    FOR (i = 0 TO (program_stack_rs->cnt - 1))
      IF ((program_stack_rs->qual[(program_stack_rs->cnt - i)].name=curprog))
       FOR (j = (program_stack_rs->cnt - i) TO program_stack_rs->cnt)
         SET program_stack_rs->qual[j].name = ""
       ENDFOR
       SET program_stack_rs->cnt = ((program_stack_rs->cnt - i) - 1)
       SET i = program_stack_rs->cnt
      ENDIF
    ENDFOR
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm2_get_program_stack(null))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_inhouse_domain(null)
   DECLARE dsid_tbl_ind = c1 WITH protect, noconstant(" ")
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET dm_err->eproc = "Inhouse Domain Detected."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET inhouse_misc->inhouse_domain = 1
    RETURN(1)
   ENDIF
   IF ((inhouse_misc->inhouse_domain=- (1)))
    SET dm_err->eproc = "Determining whether table dm_info exists"
    SET dsid_tbl_ind = dm2_table_exists("DM_INFO")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dsid_tbl_ind="F")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="INHOUSE DOMAIN"
      WITH nocounter
     ;end select
     IF (check_error("Determine if process running in an in-house domain")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (curqual=1)
      SET inhouse_misc->inhouse_domain = 1
     ELSE
      SET inhouse_misc->inhouse_domain = 0
     ENDIF
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_table_exists(dte_table_name)
  SELECT INTO "nl:"
   FROM dm2_dba_tab_columns dutc
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual > 0
    AND checkdic(cnvtupper(dte_table_name),"T",0)=2)
    RETURN("F")
   ELSE
    RETURN("N")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SET dtace_found_ind = 0
   SELECT INTO "nl:"
    FROM dba_tab_cols dtc
    WHERE dtc.table_name=trim(cnvtupper(dtace_table_name))
     AND dtc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual > 0
     AND checkdic(cnvtupper(dtace_table_name),"T",0)=2)
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_table_column_exists(dtce_owner,dtce_table_name,dtce_column_name,dtce_col_chk_ind,
  dtce_coldef_chk_ind,dtce_ccldef_mode,dtce_col_fnd_ind,dtce_coldef_fnd_ind,dtce_data_type)
   DECLARE dtce_type = vc WITH protect, noconstant("")
   DECLARE dtce_len = i4 WITH protect, noconstant(0)
   SET dtce_col_fnd_ind = 0
   SET dtce_coldef_fnd_ind = 0
   SET dtce_data_type = ""
   IF (dtce_col_chk_ind=1)
    SELECT INTO "nl:"
     FROM dba_tab_cols dtc
     WHERE dtc.owner=trim(dtce_owner)
      AND dtc.table_name=trim(dtce_table_name)
      AND dtc.column_name=trim(dtce_column_name)
     WITH nocounter
    ;end select
    IF (check_error(concat("Checking if ",trim(dtce_owner),".",trim(dtce_table_name),".",
      trim(dtce_column_name)," exists"))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual > 0)
      SET dtce_col_fnd_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (dtce_coldef_chk_ind=1)
    IF (checkdic(cnvtupper(concat(dtce_table_name,".",dtce_column_name)),"A",0)=2)
     SET dtce_coldef_fnd_ind = 1
     IF (dtce_ccldef_mode=2)
      IF (((currev=8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81401)) OR (currev > 8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 90201))) )
       CALL parser(concat(" set dtce_data_type = reflect(",dtce_table_name,".",dtce_column_name,
         ",1) go "),1)
       CALL parser(concat(" free range ",dtce_table_name," go "),1)
       SET dtce_len = cnvtint(cnvtalphanum(dtce_data_type,1))
       SET dtce_type = cnvtalphanum(dtce_data_type,2)
       IF (textlen(dtce_type)=2)
        SET dtce_type = substring(2,2,dtce_type)
       ENDIF
       SET dtce_data_type = concat(dtce_type,trim(cnvtstring(dtce_len)))
      ELSE
       SELECT INTO "nl:"
        FROM dtable t,
         dtableattr ta,
         dtableattrl tl
        WHERE t.table_name=cnvtupper(dtce_table_name)
         AND t.table_name=ta.table_name
         AND tl.attr_name=cnvtupper(dtce_column_name)
         AND tl.structtype="F"
         AND btest(tl.stat,11)=0
        DETAIL
         dtce_data_type = concat(tl.type,trim(cnvtstring(tl.len)))
        WITH nocounter
       ;end select
       IF (check_error(concat("Retrieving",trim(dtce_table_name),".",trim(dtce_column_name),
         " data type"))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_disp_file(ddf_fname,ddf_desc)
   DECLARE ddf_row = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="WIN"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL video(n)
    SET ddf_row = 3
    CALL box(1,1,5,132)
    CALL text(ddf_row,48,"***  REPORT GENERATED  ***")
    SET ddf_row = (ddf_row+ 4)
    CALL text(ddf_row,2,"The following report was generated in CCLUSERDIR... ")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,5,concat("File Name:   ",trim(ddf_fname)))
    SET ddf_row = (ddf_row+ 1)
    CALL text(ddf_row,5,concat("Description: ",trim(ddf_desc)))
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Review report in CCLUSERDIR before continuing.")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Enter 'C' to continue or 'Q' to quit:  ")
    CALL accept(ddf_row,41,"A;cu","C"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="Q")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->emsg = "User elected to quit from report prompt."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
   ELSE
    SET dm_err->eproc = concat("Displaying ",ddf_desc)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    FREE SET file_loc
    SET logical file_loc value(ddf_fname)
    FREE DEFINE rtl2
    DEFINE rtl2 "file_loc"
    SELECT INTO mine
     t.line
     FROM rtl2t t
     HEAD REPORT
      col 30,
      CALL print(ddf_desc), row + 1
     DETAIL
      col 0, t.line, row + 1
     FOOT REPORT
      row + 0
     WITH nocounter, maxcol = 5000
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET file_loc
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_program_stack(null)
   DECLARE stack = vc WITH protect, noconstant("PROGRAM STACK:")
   FOR (i = 1 TO (program_stack_rs->cnt - 1))
     SET stack = build(stack,program_stack_rs->qual[i].name,"->")
   ENDFOR
   IF (program_stack_rs->cnt)
    RETURN(build(stack,program_stack_rs->qual[program_stack_rs->cnt].name))
   ELSE
    RETURN(stack)
   ENDIF
 END ;Subroutine
 DECLARE get_target_location_cd(loc_code=f8) = f8 WITH public
 DECLARE get_target_resource_cd(rec_code=f8) = f8 WITH public
 DECLARE get_target_task_ref_cd(tr_code=f8) = f8 WITH public
 DECLARE get_target_event_cd(tr_code=f8) = f8 WITH public
 DECLARE get_target_image_class_cd(imc_code=f8) = f8 WITH public
 DECLARE get_target_catalog_cd(source_cat_code=f8) = f8 WITH public
 DECLARE get_target_pchart_comp_cd(pchart_code=f8) = f8 WITH public
 DECLARE get_target_dta(dta_code=f8) = f8 WITH public
 DECLARE get_target_oefields(oe_code=f8) = f8 WITH public
 DECLARE get_value(sbr_table=vc,sbr_column=vc,sbr_origin=vc) = vc WITH public
 DECLARE get_nullind(sbr_table=vc,sbr_column=vc) = i2 WITH public
 DECLARE put_value(sbr_table=vc,sbr_column=vc,sbr_value=vc) = null
 DECLARE get_translates(sbr_table=vc) = null
 DECLARE is_translated(sbr_table=vc,sbr_column=vc) = i2
 DECLARE get_seq(sbr_table=vc,sbr_column=vc) = f8
 DECLARE get_col_pos(sbr_table=vc,sbr_column=vc) = i4
 DECLARE get_primary_key(sbr_table=vc) = vc WITH public
 DECLARE check_ui_exist(sbr_table_name=vc) = i2
 DECLARE check_sec_trans(sbr_table_name=vc,sbr_col_name=vc) = null
 DECLARE evaluate_rpt_missing(erm_missing_val=vc) = null
 DECLARE get_err_val(null) = i4
 DECLARE sbr_err_val = i4
 DECLARE inc_prelink = vc
 DECLARE inc_postlink = vc
 FREE RECORD rdds_exception
 RECORD rdds_exception(
   1 qual[*]
     2 tab_col_name = vc
     2 tru_tab_name = vc
     2 tru_col_name = vc
 )
 SUBROUTINE get_target_location_cd(loc_cd)
   DECLARE ui_loc_cd = vc
   DECLARE ui_cnt = i4
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   DECLARE mult_cnt = i4
   DECLARE mult_loop = i4
   DECLARE trans_ref = vc
   DECLARE par_cdf = vc
   DECLARE alt_par_cdf = vc
   DECLARE unknown_ind = i2
   DECLARE second_try_ind = i2
   DECLARE mult_loop = i4
   DECLARE sbr_any_trans = i2
   DECLARE new_cv_ind = i2
   DECLARE gtl_cur_dt_tm = f8
   DECLARE gtl_beg_dt_tm = f8
   DECLARE gtl_end_dt_tm = f8
   DECLARE gtl_addl_cnt = i4
   DECLARE gtl_done_ind = i2
   DECLARE gtl_spec_q_ind = i2
   DECLARE gtl_loop = i4
   DECLARE gtl_eval_ret = f8
   DECLARE gtl_nopar_trans = i2
   SET gtl_spec_quer_ind = 0
   SET gtl_nopar_trans = 0
   FREE RECORD target_query
   RECORD target_query(
     1 from_clause = vc
     1 plan_stmts[*]
       2 p_clause = vc
     1 join1_stmts[*]
       2 j1_clause = vc
     1 join2_stmts[*]
       2 j2_clause = vc
     1 detail_stmts[*]
       2 d_clause = vc
     1 addl_stmts[*]
       2 a_clause = vc
   )
   FREE RECORD mult_loc
   RECORD mult_loc(
     1 qual[*]
       2 src_cd1 = f8
       2 src_cd2 = f8
       2 trans_ind1 = i2
       2 trans_ind2 = i2
       2 tgt_cd1 = f8
       2 tgt_cd2 = f8
       2 tgt_val = vc
       2 tgt_cnt = i4
       2 sec_try = i2
   )
   SET to_active = 0
   SET to_par = 0
   SET ui_cnt = 0
   SET source_parent_ind = 0
   SET unknown_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(target_query->addl_stmts,1)
   SET target_query->addl_stmts[1].a_clause = " and cv2.active_ind = cv.active_ind "
   IF (get_nullind("CODE_VALUE","BEGIN_EFFECTIVE_DT_TM")=0
    AND get_nullind("CODE_VALUE","END_EFFECTIVE_DT_TM")=0)
    SET stat = alterlist(target_query->addl_stmts,3)
    SET gtl_cur_dt_tm = cnvtdatetime(curdate,curtime3)
    SET gtl_beg_dt_tm = rs_0619->from_values.begin_effective_dt_tm
    SET gtl_end_dt_tm = rs_0619->from_values.end_effective_dt_tm
    IF (gtl_beg_dt_tm < gtl_cur_dt_tm
     AND gtl_end_dt_tm > gtl_cur_dt_tm)
     SET target_query->addl_stmts[2].a_clause = concat(
      " and cv.begin_effective_dt_tm < cnvtdatetime(gtl_cur_dt_Tm) ",
      " and cv.end_effective_dt_tm > cnvtdatetime(gtl_cur_dt_tm) ")
     SET target_query->addl_stmts[3].a_clause = concat(
      " and cv.begin_effective_dt_tm < cnvtdatetime(gtl_cur_dt_Tm) ",
      " and cv.end_effective_dt_tm > cnvtdatetime(gtl_cur_dt_tm) and cv2.active_ind = cv.active_ind "
      )
    ELSE
     SET target_query->addl_stmts[2].a_clause = concat(
      " and (cv.begin_effective_dt_tm > cnvtdatetime(gtl_cur_dt_Tm) ",
      " or cv.end_effective_dt_tm < cnvtdatetime(gtl_cur_dt_tm)) ")
     SET target_query->addl_stmts[3].a_clause = concat(
      " and (cv.begin_effective_dt_tm > cnvtdatetime(gtl_cur_dt_Tm) ",
      " or cv.end_effective_dt_tm < cnvtdatetime(gtl_cur_dt_tm)) and cv2.active_ind = cv.active_ind "
      )
    ENDIF
   ENDIF
   CASE (rs_0619->from_values.cdf_meaning)
    OF "NURSEUNIT":
    OF "AMBULATORY":
     SET gt_lgselect = dm2_get_rdds_tname("NURSE_UNIT")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(concat(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_building_cd ",
       " mult_loc->qual[mult_cnt].src_cd2 = l.loc_facility_cd "),0)
     CALL parser(" with nocounter go",1)
    OF "ROOM":
     SET gt_lgselect = dm2_get_rdds_tname("ROOM")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_nurse_unit_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "BED":
     SET gt_lgselect = dm2_get_rdds_tname("BED")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_room_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "FACILITY":
    OF "ACTASGNROOT":
    OF "APPTROOT":
    OF "BBOWNERROOT":
    OF "COLLROOT":
    OF "CSLOGIN":
    OF "CSTRACK":
    OF "FOLLOWUPAMB":
    OF "HIMROOT":
    OF "HIS":
    OF "INVGRP":
    OF "INVVIEW":
    OF "LAB":
    OF "MMGRPROOT":
    OF "PATLISTROOT":
    OF "PLREMOTE":
    OF "PTTRACKROOT":
    OF "PTTRACKVIEW":
    OF "ROUNDSROOT":
    OF "RXLOCGROUP":
    OF "SPECCOLLROOT":
    OF "SPECTRKROOT":
    OF "SRVAREA":
    OF "STORAGERACK":
    OF "STORAGEROOT":
    OF "STORTRKROOT":
    OF "TRANSPORT":
    OF "TSKGRPROOT":
    OF "SHFTASGNROOT":
     CALL echo("No source work needs to be done for this CDF_Meaning")
     SET mult_cnt = 1
     SET stat = alterlist(mult_loc->qual,mult_cnt)
    ELSE
     IF ((rs_0619->from_values.cdf_meaning IN ("ANCILSURG", "APPTLOC", "HIM", "PHARM", "RAD")))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="BBINVAREA"))
      SET par_cdf = "BBOWNERROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="BUILDING"))
      SET par_cdf = "FACILITY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning IN ("CHECKOUT", "WAITROOM")))
      SET par_cdf = "AMBULATORY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="COLLRTE"))
      SET par_cdf = "COLLRUN"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="COLLRUN"))
      SET par_cdf = "COLLROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="INVLOC"))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = "ANCILSURG"
     ELSEIF ((rs_0619->from_values.cdf_meaning="INVLOCATOR"))
      SET par_cdf = "INVLOC"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="PTTRACK"))
      SET par_cdf = "PTTRACKROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="STORAGESHELF"))
      SET par_cdf = "STORAGEUNIT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="STORAGEUNIT"))
      SET par_cdf = "STORAGEROOT"
      SET alt_par_cdf = ""
     ELSE
      SET par_cdf = ""
      SET alt_par_cdf = ""
      SET unknown_ind = 1
     ENDIF
     SET gt_lgselect = dm2_get_rdds_tname("LOCATION_GROUP")
     CALL parser("select into 'nl:' from ",0)
     IF (par_cdf="")
      CALL parser(concat(gt_lgselect," l "),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
     ELSE
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
      CALL parser(" join c where l.parent_loc_cd = c.code_value and c.cdf_meaning = par_cdf",0)
     ENDIF
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(
      " mult_loc->qual[mult_cnt].src_cd1=l.parent_loc_cd mult_loc->qual[mult_cnt].src_cd2=l.root_loc_cd",
      0)
     CALL parser(" with nocounter go",1)
     IF (mult_cnt=0
      AND alt_par_cdf != "")
      CALL parser("select into 'nl:' from ",0)
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
      CALL parser(" join c where l.parent_loc_cd = c.code_value and c.cdf_meaning = alt_par_cdf",0)
      CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
      CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.parent_loc_cd ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd2 = l.root_loc_cd with nocounter go",1)
     ENDIF
   ENDCASE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (mult_cnt=0)
    IF (unknown_ind=0)
     RETURN(- (17))
    ENDIF
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
    IF ((mult_loc->qual[mult_loop].src_cd1 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd1),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd1 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind1 = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",mult_loc->qual[mult_loop].src_cd1)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd1 = 0
     SET mult_loc->qual[mult_loop].trans_ind1 = 1
    ENDIF
    IF ((mult_loc->qual[mult_loop].src_cd2 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd2),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd2 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind2 = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",mult_loc->qual[mult_loop].src_cd2)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd2 = 0
     SET mult_loc->qual[mult_loop].trans_ind2 = 1
    ENDIF
   ENDFOR
   FOR (mult_loop = 1 TO mult_cnt)
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      SET sbr_any_trans = 1
     ENDIF
   ENDFOR
   IF (sbr_any_trans=0)
    RETURN(- (1))
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
     SET ui_cnt = 0
     SET ui_loc_cd = ""
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      CASE (rs_0619->from_values.cdf_meaning)
       OF "NURSEUNIT":
       OF "AMBULATORY":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, nurse_unit l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,2)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value = l.location_cd and l.loc_building_cd = mult_loc->qual[mult_loop].tgt_cd1"
        SET target_query->join2_stmts[2].j2_clause =
        " and l.loc_facility_cd = mult_loc->qual[mult_loop].tgt_cd2"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "ROOM":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, room l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,3)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and (cv.description = cv2.description  or "
        SET target_query->join1_stmts[3].j1_clause =
        " (cv.description = null and cv2.description = null)) and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,1)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value=l.location_cd and l.loc_nurse_unit_cd=mult_loc->qual[mult_loop].tgt_cd1"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "BED":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, bed l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,1)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value = l.location_cd and l.loc_room_cd=mult_loc->qual[mult_loop].tgt_cd1"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "FACILITY":
       OF "CSTRACK":
       OF "CSLOGIN":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
         " cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,3)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and (cv2.description = cv.description "
        SET target_query->join1_stmts[3].j1_clause =
        " or (cv2.description = null and cv.description = null)) and cv.code_set = 220 "
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "ACTASGNROOT":
       OF "APPTROOT":
       OF "BBOWNERROOT":
       OF "COLLROOT":
       OF "FOLLOWUPAMB":
       OF "HIMROOT":
       OF "HIS":
       OF "INVGRP":
       OF "INVVIEW":
       OF "LAB":
       OF "MMGRPROOT":
       OF "PATLISTROOT":
       OF "PLREMOTE":
       OF "PTTRACKROOT":
       OF "PTTRACKVIEW":
       OF "ROUNDSROOT":
       OF "RXLOCGROUP":
       OF "SPECCOLLROOT":
       OF "SPECTRKROOT":
       OF "STORAGEROOT":
       OF "STORTRKROOT":
       OF "SRVAREA":
       OF "STORAGERACK":
       OF "TSKGRPROOT":
       OF "TRANSPORT":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
         " cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       ELSE
        IF (unknown_ind=1
         AND (mult_loc->qual[mult_loop].tgt_cd1=0))
         SET gtl_spec_q_ind = 1
         SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
          " cv2 ")
         SET stat = alterlist(target_query->plan_stmts,1)
         SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
         SET stat = alterlist(target_query->join1_stmts,2)
         SET target_query->join1_stmts[1].j1_clause =
         " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
         SET target_query->join1_stmts[2].j1_clause =
         " and cv2.cdf_meaning = cv.cdf_meaning and cv2.description = cv.description and cv.code_set = 220 "
         SET stat = alterlist(target_query->detail_stmts,2)
         SET target_query->detail_stmts[1].d_clause =
         " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
         SET target_query->detail_stmts[2].d_clause =
         " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
        ELSE
         SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
          " cv2, location_group l ")
         SET stat = alterlist(target_query->plan_stmts,1)
         SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
         SET stat = alterlist(target_query->join1_stmts,2)
         SET target_query->join1_stmts[1].j1_clause =
         " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
         SET target_query->join1_stmts[2].j1_clause =
         " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
         SET stat = alterlist(target_query->join2_stmts,2)
         SET target_query->join2_stmts[1].j2_clause =
         " join l where l.child_loc_cd=cv.code_value and l.parent_loc_cd=mult_loc->qual[mult_loop].tgt_cd1"
         SET target_query->join2_stmts[2].j2_clause =
         " and l.root_loc_cd = mult_loc->qual[mult_loop].tgt_cd2"
         SET stat = alterlist(target_query->detail_stmts,2)
         SET target_query->detail_stmts[1].d_clause =
         " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
         SET target_query->detail_stmts[2].d_clause =
         " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
         SET gtl_addl_cnt = 0
         SET ui_cnt = 0
         SET stat = alterlist(ui_query_eval_rec->qual,0)
         CALL parser(target_query->from_clause,0)
         FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
           CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
           CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
           CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
           CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
         ENDFOR
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN(- (20))
         ENDIF
         IF (((size(ui_query_eval_rec->qual,5) > 0) OR (mult_loop=mult_cnt)) )
          SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
          IF ((gtl_eval_ret=- (3)))
           RETURN(0)
          ELSEIF (gtl_eval_ret > 0)
           RETURN(gtl_eval_ret)
          ELSEIF ((gtl_eval_ret=- (2)))
           IF (gtl_addl_cnt=size(target_query->addl_stmts,5))
            RETURN(- (19))
           ELSE
            SET gtl_addl_cnt = (gtl_addl_cnt+ 1)
            SET ui_cnt = 0
            SET stat = alterlist(ui_query_eval_rec->qual,0)
            CALL parser(target_query->from_clause,0)
            FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
              CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
            ENDFOR
            FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
              CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
            ENDFOR
            IF (gtl_addl_cnt > 0)
             CALL parser(target_query->addl_stmts[gtl_addl_cnt].a_clause,0)
            ENDIF
            FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
              CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
            ENDFOR
            FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
              CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
            ENDFOR
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             SET dm_err->err_ind = 0
             SET nodelete_ind = 1
             RETURN(- (20))
            ENDIF
            IF (((size(ui_query_eval_rec->qual,5) > 0) OR (mult_loop=mult_cnt)) )
             SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
             IF ((gtl_eval_ret=- (3)))
              RETURN(0)
             ELSEIF (gtl_eval_ret > 0)
              RETURN(gtl_eval_ret)
             ELSEIF ((gtl_eval_ret=- (2)))
              RETURN(- (19))
             ELSE
              RETURN(- (20))
             ENDIF
            ENDIF
           ENDIF
          ELSE
           RETURN(- (20))
          ENDIF
         ENDIF
        ENDIF
      ENDCASE
      SET mult_loc->qual[mult_loop].tgt_cnt = ui_cnt
      SET mult_loc->qual[mult_loop].tgt_val = ui_loc_cd
     ELSE
      SET gtl_nopar_trans = 1
     ENDIF
   ENDFOR
   IF (gtl_spec_q_ind=1)
    SET mult_loop = 1
    SET gtl_done_ind = 0
    SET gtl_addl_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    WHILE (gtl_done_ind=0)
      SET ui_cnt = 0
      SET stat = alterlist(ui_query_eval_rec->qual,0)
      CALL parser(target_query->from_clause,0)
      FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
        CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
      ENDFOR
      FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
        CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
      ENDFOR
      IF (gtl_addl_cnt > 0)
       CALL parser(target_query->addl_stmts[gtl_addl_cnt].a_clause,0)
      ENDIF
      FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
        CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
      ENDFOR
      FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
        CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
      ENDFOR
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
       RETURN(- (20))
      ENDIF
      SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
      IF (gtl_addl_cnt=size(target_query->addl_stmts,5))
       SET gtl_done_ind = 1
      ELSE
       IF ((gtl_eval_ret=- (2)))
        SET gtl_addl_cnt = (gtl_addl_cnt+ 1)
       ELSE
        SET gtl_done_ind = 1
       ENDIF
      ENDIF
    ENDWHILE
    IF ((gtl_eval_ret=- (3)))
     RETURN(0)
    ELSEIF (gtl_eval_ret > 0)
     RETURN(gtl_eval_ret)
    ELSE
     RETURN(- (19))
    ENDIF
   ELSE
    IF (gtl_nopar_trans=1)
     RETURN(- (1))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_catalog_cd(source_cat_code)
   DECLARE ui_cat_cd = f8
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("ORDER_CATALOG")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_cat_cnt = 0
   SELECT INTO "NL:"
    oct.catalog_cd
    FROM order_catalog oct,
     (parser(gt_select) oc)
    PLAN (oc
     WHERE oc.catalog_cd=source_cat_code)
     JOIN (oct
     WHERE oc.primary_mnemonic=oct.primary_mnemonic)
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
     ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = oct.catalog_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_cat_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_cat_cd=- (2)))
    SET ui_cat_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "NL:"
     oct.catalog_cd
     FROM order_catalog oct,
      (parser(gt_select) oc)
     PLAN (oc
      WHERE oc.catalog_cd=source_cat_code)
      JOIN (oct
      WHERE oc.primary_mnemonic=oct.primary_mnemonic
       AND oct.active_ind=oc.active_ind)
     DETAIL
      ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
      ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = oct.catalog_cd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cat_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cat_cd=- (2)))
     RETURN(- (3))
    ELSEIF ((ui_cat_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cat_cd)
    ENDIF
   ELSEIF ((ui_cat_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_cat_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_event_cd(tr_code)
   DECLARE ui_es_cd = f8
   DECLARE ui_es_cnt = i4
   DECLARE gt_select = vc
   DECLARE cv_select = vc
   SET ui_es_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("V500_EVENT_CODE")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_es_cnt = 0
   SELECT INTO "NL:"
    es.event_cd
    FROM v500_event_code es,
     (parser(gt_select) es1)
    PLAN (es1
     WHERE es1.event_cd=tr_code)
     JOIN (es
     WHERE ((es1.event_cd_disp=es.event_cd_disp) OR (es1.event_cd_disp=null
      AND es.event_cd_disp=null))
      AND ((es1.event_cd_descr=es.event_cd_descr) OR (es1.event_cd_descr=null
      AND es.event_cd_descr=null))
      AND ((es1.event_set_name=es.event_set_name) OR (es1.event_set_name=null
      AND es.event_set_name=null)) )
    DETAIL
     ui_es_cnt = (ui_es_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_es_cnt),
     ui_query_eval_rec->qual[ui_es_cnt].root_entity_attr = es.event_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_es_cd = evaluate_exec_ui_query(ui_es_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_es_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_es_cd=- (2)))
    SET ui_es_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "NL:"
     es.event_cd
     FROM v500_event_code es,
      (parser(gt_select) es1),
      code_value cv,
      (parser(cv_select) cv1)
     PLAN (cv1
      WHERE cv1.code_value=tr_code)
      JOIN (es1
      WHERE es1.event_cd=cv1.code_value)
      JOIN (es
      WHERE ((es1.event_cd_disp=es.event_cd_disp) OR (es1.event_cd_disp=null
       AND es.event_cd_disp=null))
       AND ((es1.event_cd_descr=es.event_cd_descr) OR (es1.event_cd_descr=null
       AND es.event_cd_descr=null))
       AND ((es1.event_set_name=es.event_set_name) OR (es1.event_set_name=null
       AND es.event_set_name=null)) )
      JOIN (cv
      WHERE cv.code_value=es.event_cd
       AND cv.active_ind=cv1.active_ind)
     DETAIL
      ui_es_cnt = (ui_es_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_es_cnt),
      ui_query_eval_rec->qual[ui_es_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_es_cd = evaluate_exec_ui_query(ui_es_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_es_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_es_cd=- (2)))
     RETURN(- (18))
    ELSEIF ((ui_es_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_es_cd)
    ENDIF
   ELSEIF ((ui_es_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_es_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_pchart_comp_cd(pchart_code)
   DECLARE ui_cat_cd = f8
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_cat_cnt = 0
   SELECT INTO "nl:"
    c.code_value
    FROM (parser(gt_select) cv),
     code_value c
    PLAN (cv
     WHERE cv.code_value=pchart_code)
     JOIN (c
     WHERE cv.definition=c.definition
      AND cv.cdf_meaning=c.cdf_meaning)
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
     ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = c.code_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_cat_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_cat_cd=- (2)))
    SET ui_cat_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "nl:"
     c.code_value
     FROM (parser(gt_select) cv),
      code_value c
     PLAN (cv
      WHERE cv.code_value=pchart_code)
      JOIN (c
      WHERE cv.definition=c.definition
       AND cv.cdf_meaning=c.cdf_meaning
       AND cv.active_ind=c.active_ind)
     DETAIL
      ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
      ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cat_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cat_cd=- (2)))
     RETURN(- (4))
    ELSEIF ((ui_cat_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cat_cd)
    ENDIF
   ELSEIF ((ui_cat_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_cat_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_resource_cd(rec_cd)
   DECLARE ui_rec_cd = f8
   DECLARE ui_rec_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   DECLARE res_ins_ind = i2
   DECLARE res_mult_ind = i2
   FREE RECORD res_cd
   RECORD res_cd(
     1 qual[*]
       2 from_val = f8
       2 to_val = f8
       2 trans_ind = i2
       2 active_ind = i2
   )
   DECLARE res_rs_loop = i4
   DECLARE sbr_ret_value = vc
   DECLARE par_res_cnt = i4
   SET res_mult_ind = 0
   SET res_ins_ind = 0
   SET to_active = 0
   SET ui_rec_cd = 0
   SET to_par = 0
   SET ui_rec_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET gt_lgselect = dm2_get_rdds_tname("RESOURCE_GROUP")
   CALL parser("select into 'nl:' from ",0)
   CALL parser(concat(gt_lgselect," r"),0)
   CALL parser(" where r.child_service_resource_cd = rec_cd",0)
   CALL parser(" detail to_active = r.active_ind source_parent_ind = 1 with nocounter go",1)
   IF (curqual > 0)
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",gt_lgselect," r"),0)
    CALL parser("where r.child_service_resource_cd = rec_cd",0)
    CALL parser(" detail par_res_cnt = par_res_cnt + 1 stat=alterlist(res_cd->qual,par_res_cnt) ",0)
    CALL parser(" res_cd->qual[par_res_cnt].from_val=r.parent_service_resource_cd ",0)
    CALL parser(" res_cd->qual[par_res_cnt].active_ind = r.active_ind with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    FOR (res_rs_loop = 1 TO par_res_cnt)
     SET sbr_ret_value = select_merge_translate(cnvtstring(res_cd->qual[res_rs_loop].from_val),
      "CODE_VALUE")
     IF (sbr_ret_value != "No Trans")
      SET res_cd->qual[res_rs_loop].to_val = cnvtreal(sbr_ret_value)
      SET res_cd->qual[res_rs_loop].trans_ind = 1
      SET cv_parent_ind = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",res_cd->qual[res_rs_loop].from_val)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (source_parent_ind=1)
    IF (cv_parent_ind=0)
     RETURN(- (5))
    ELSE
     FOR (res_rs_loop = 1 TO par_res_cnt)
       IF ((res_cd->qual[res_rs_loop].trans_ind=1))
        SET stat = alterlist(ui_query_eval_rec->qual,0)
        SET ui_rec_cnt = 0
        SELECT INTO "NL:"
         FROM code_value cv,
          resource_group rg,
          (parser(gt_select) cv2)
         PLAN (cv2
          WHERE cv2.code_value=rec_cd
           AND cv2.code_set=221)
          JOIN (cv
          WHERE cv2.display_key=cv.display_key
           AND cv2.cdf_meaning=cv.cdf_meaning
           AND cv.code_set=221)
          JOIN (rg
          WHERE rg.child_service_resource_cd=cv.code_value
           AND (rg.parent_service_resource_cd=res_cd->qual[res_rs_loop].to_val))
         DETAIL
          ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
          ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN(- (20))
        ENDIF
        SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
        IF ((ui_rec_cd=- (1)))
         RETURN(- (20))
        ELSEIF ((ui_rec_cd=- (2)))
         SET ui_rec_cnt = 0
         SET stat = alterlist(ui_query_eval_rec->qual,0)
         SELECT INTO "NL:"
          FROM code_value cv,
           resource_group rg,
           (parser(gt_select) cv2)
          PLAN (cv2
           WHERE cv2.code_value=rec_cd
            AND cv2.code_set=221)
           JOIN (cv
           WHERE cv2.display_key=cv.display_key
            AND cv2.cdf_meaning=cv.cdf_meaning
            AND cv.code_set=221)
           JOIN (rg
           WHERE rg.child_service_resource_cd=cv.code_value
            AND (rg.parent_service_resource_cd=res_cd->qual[res_rs_loop].to_val)
            AND (rg.active_ind=res_cd->qual[res_rs_loop].active_ind))
          DETAIL
           ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
           ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN(- (20))
         ENDIF
         SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
         IF ((ui_rec_cd=- (1)))
          RETURN(- (20))
         ELSEIF ((ui_rec_cd=- (2))
          AND res_rs_loop=par_res_cnt)
          RETURN(- (6))
         ELSEIF ((ui_rec_cd=- (2))
          AND res_rs_loop != par_res_cnt)
          SET res_mult_ind = 1
         ELSEIF ((ui_rec_cd=- (3))
          AND res_rs_loop=par_res_cnt)
          RETURN(0)
         ELSEIF ((ui_rec_cd=- (3))
          AND res_rs_loop != par_res_cnt)
          SET res_ins_ind = 1
         ELSE
          RETURN(ui_rec_cd)
         ENDIF
        ELSEIF ((ui_rec_cd=- (3))
         AND res_rs_loop=par_res_cnt)
         RETURN(0)
        ELSEIF ((ui_rec_cd=- (3))
         AND res_rs_loop != par_res_cnt)
         SET res_ins_ind = 1
        ELSE
         RETURN(ui_rec_cd)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_rec_cnt = 0
    SELECT INTO "NL:"
     FROM code_value cv,
      (parser(gt_select) cv2)
     PLAN (cv2
      WHERE cv2.code_value=rec_cd
       AND cv2.code_set=221)
      JOIN (cv
      WHERE cv2.display_key=cv.display_key
       AND cv2.cdf_meaning=cv.cdf_meaning
       AND cv.code_set=221
       AND  NOT (cv.code_value IN (
      (SELECT
       r.child_service_resource_cd
       FROM resource_group r
       WHERE r.child_service_resource_cd=cv.code_value))))
     DETAIL
      ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
      ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_rec_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_rec_cd=- (2)))
     SET ui_rec_cnt = 0
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SELECT INTO "NL:"
      FROM code_value cv,
       (parser(gt_select) cv2)
      PLAN (cv2
       WHERE cv2.code_value=rec_cd
        AND cv2.code_set=221)
       JOIN (cv
       WHERE cv2.display_key=cv.display_key
        AND cv2.cdf_meaning=cv.cdf_meaning
        AND cv.code_set=221
        AND cv.active_ind=cv2.active_ind
        AND  NOT (cv.code_value IN (
       (SELECT
        r.child_service_resource_cd
        FROM resource_group r
        WHERE r.child_service_resource_cd=cv.code_value))))
      DETAIL
       ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
       ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_rec_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_rec_cd=- (2)))
      RETURN(- (6))
     ELSEIF ((ui_rec_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_rec_cd)
     ENDIF
    ELSEIF ((ui_rec_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_rec_cd)
    ENDIF
   ENDIF
   IF (res_mult_ind=1)
    RETURN(- (6))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_target_image_class_cd(imc_cd)
   DECLARE ui_imc_cd = f8
   DECLARE ui_imc_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE lib_cd = f8
   DECLARE par_cd = f8
   DECLARE no_par_ind = i2
   DECLARE lib_trans_ind = i2
   DECLARE par_trans_ind = i2
   DECLARE to_lib = f8
   DECLARE to_par = f8
   DECLARE vc_lib = vc
   DECLARE vc_par = vc
   SET par_trans_ind = 0
   SET lib_trans_ind = 0
   SET no_par_ind = 0
   SET par_cd = 0
   SET lib_cd = 0
   SET ui_imc_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET gt_lgselect = dm2_get_rdds_tname("IMAGE_CLASS_TYPE")
   CALL parser(concat("select into 'nl:' from ",gt_lgselect," i where i.image_class_type_cd = imc_cd"
     ),0)
   CALL parser(
    "detail lib_cd = i.lib_group_cd par_cd = i.parent_image_class_type_cd with nocounter go",1)
   IF (par_cd=imc_cd)
    SET no_par_ind = 1
    SET par_trans_ind = 1
   ENDIF
   SET vc_lib = select_merge_translate(cnvtstring(lib_cd),"CODE_VALUE")
   IF (vc_lib != "No Trans")
    SET to_lib = cnvtreal(vc_lib)
    SET lib_trans_ind = 1
   ELSE
    SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",lib_cd)
    IF (rpt_missing="ORPHAN")
     RETURN(- (21))
    ENDIF
    IF (rpt_missing="NOMV*")
     RETURN(- (22))
    ENDIF
   ENDIF
   IF (no_par_ind=0)
    SET vc_par = select_merge_translate(cnvtstring(par_cd),"CODE_VALUE")
    IF (vc_par != "No Trans")
     SET to_par = cnvtreal(vc_par)
     SET par_trans_ind = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",par_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ENDIF
   IF (lib_trans_ind=1)
    IF (par_trans_ind=1)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_imc_cnt = 0
     SELECT INTO "NL:"
      FROM code_value cv,
       (parser(gt_select) cv2)
      PLAN (cv2
       WHERE cv2.code_set=5503
        AND cv2.code_value=imc_cd)
       JOIN (cv
       WHERE cv.description=cv2.description
        AND cv.display_key=cv2.display_key
        AND cv.code_set=5503
        AND  EXISTS (
       (SELECT
        "x"
        FROM image_class_type ic
        WHERE ic.image_class_type_cd=cv.code_value
         AND ic.parent_image_class_type_cd=evaluate(no_par_ind,0,to_par,1,ic.image_class_type_cd)
         AND ic.lib_group_cd=to_lib)))
      DETAIL
       ui_imc_cnt = (ui_imc_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_imc_cnt),
       ui_query_eval_rec->qual[ui_imc_cnt].root_entity_attr = cv.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
    ELSE
     RETURN(- (7))
    ENDIF
   ELSE
    RETURN(- (8))
   ENDIF
   SET ui_imc_cd = evaluate_exec_ui_query(ui_imc_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_imc_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_imc_cd=- (2)))
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_imc_cnt = 0
    SELECT INTO "NL:"
     FROM code_value cv,
      (parser(gt_select) cv2)
     PLAN (cv2
      WHERE cv2.code_set=5503
       AND cv2.code_value=imc_cd)
      JOIN (cv
      WHERE cv.description=cv2.description
       AND cv.display_key=cv2.display_key
       AND cv.code_set=5503
       AND cv.active_ind=cv2.active_ind
       AND  EXISTS (
      (SELECT
       "x"
       FROM image_class_type ic
       WHERE ic.image_class_type_cd=cv.code_value
        AND ic.parent_image_class_type_cd=evaluate(no_par_ind,0,to_par,1,ic.image_class_type_cd)
        AND ic.lib_group_cd=to_lib)))
     DETAIL
      ui_imc_cnt = (ui_imc_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_imc_cnt),
      ui_query_eval_rec->qual[ui_imc_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_imc_cd = evaluate_exec_ui_query(ui_imc_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_imc_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_imc_cd=- (2)))
     RETURN(- (9))
    ELSEIF ((ui_imc_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_imc_cd)
    ENDIF
   ELSEIF ((ui_imc_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_imc_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_task_ref_cd(sbr_code)
   DECLARE ui_tr_cd = f8
   DECLARE ui_tr_cnt = i4
   DECLARE s_tr_gr_cd = f8
   DECLARE as_cd_cnt = i4
   DECLARE tr_gr_cd = f8
   DECLARE sbr_ret_val = vc
   SET ui_tr_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    cv.code_value
    FROM (parser(gt_select) cv)
    WHERE cv.code_set=16370
     AND (cv.display=rs_0619->from_values.definition)
    DETAIL
     ui_tr_cnt = (ui_tr_cnt+ 1), s_tr_gr_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (ui_tr_cnt=1)
    SET sbr_ret_val = select_merge_translate(cnvtstring(s_tr_gr_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET tr_gr_cd = cnvtreal(sbr_ret_val)
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",s_tr_gr_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
     SET ui_tr_cnt = 0
    ENDIF
   ENDIF
   IF (ui_tr_cnt=0)
    RETURN(- (10))
   ELSEIF (ui_tr_cnt=1)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET as_cd_cnt = 0
    SELECT INTO "NL:"
     FROM track_reference tr
     WHERE tr.tracking_group_cd=tr_gr_cd
      AND (tr.description=rs_0619->from_values.description)
     DETAIL
      as_cd_cnt = (as_cd_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,as_cd_cnt),
      ui_query_eval_rec->qual[as_cd_cnt].root_entity_attr = tr.assoc_code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_tr_cd = evaluate_exec_ui_query(as_cd_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_tr_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_tr_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET as_cd_cnt = 0
     SELECT INTO "NL:"
      FROM track_reference tr
      WHERE tr.tracking_group_cd=tr_gr_cd
       AND (tr.description=rs_0619->from_values.description)
       AND (tr.active_ind=rs_0619->from_values.active_ind)
      DETAIL
       as_cd_cnt = (as_cd_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,as_cd_cnt),
       ui_query_eval_rec->qual[as_cd_cnt].root_entity_attr = tr.assoc_code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_tr_cd = evaluate_exec_ui_query(as_cd_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_tr_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_tr_cd=- (2)))
      RETURN(- (12))
     ELSEIF ((ui_tr_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_tr_cd)
     ENDIF
    ELSEIF ((ui_tr_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_tr_cd)
    ENDIF
   ELSE
    RETURN(- (11))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_dta(source_dta_code)
   DECLARE ui_dta_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = f8
   DECLARE src_act_cd = f8
   DECLARE src_act_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_act_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET dta_select = dm2_get_rdds_tname("DISCRETE_TASK_ASSAY")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    dta.activity_type_cd
    FROM (parser(dta_select) dta)
    WHERE dta.task_assay_cd=source_dta_code
    DETAIL
     src_act_cd = dta.activity_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (src_act_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_act_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_dta_cd = cnvtreal(sbr_ret_val)
     SET src_act_cnt = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",src_act_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ELSE
    SET ui_dta_cd = 0
    SET src_act_cnt = 1
   ENDIF
   IF (src_act_cnt > 0)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_cv_cnt = 0
    SELECT INTO "NL:"
     FROM code_value c,
      discrete_task_assay dta,
      (parser(cv_select) cv1)
     PLAN (cv1
      WHERE cv1.code_value=source_dta_code)
      JOIN (c
      WHERE c.display_key=cv1.display_key
       AND c.display=cv1.display
       AND c.code_set=cv1.code_set)
      JOIN (dta
      WHERE dta.task_assay_cd=c.code_value
       AND dta.activity_type_cd=ui_dta_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
      ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cv_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cv_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_cv_cnt = 0
     SELECT INTO "NL:"
      FROM code_value c,
       discrete_task_assay dta,
       (parser(cv_select) cv1)
      PLAN (cv1
       WHERE cv1.code_value=source_dta_code)
       JOIN (c
       WHERE c.display_key=cv1.display_key
        AND c.display=cv1.display
        AND c.code_set=cv1.code_set
        AND c.active_ind=cv1.active_ind)
       JOIN (dta
       WHERE dta.task_assay_cd=c.code_value
        AND dta.activity_type_cd=ui_dta_cd)
      DETAIL
       ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
       ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_cv_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_cv_cd=- (2)))
      RETURN(- (14))
     ELSEIF ((ui_cv_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_cv_cd)
     ENDIF
    ELSEIF ((ui_cv_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cv_cd)
    ENDIF
   ELSE
    RETURN(- (13))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_oefields(source_oe_code)
   DECLARE ui_oe_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = f8
   DECLARE src_cat_cd = f8
   DECLARE src_cat_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_cat_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET oe_select = dm2_get_rdds_tname("ORDER_ENTRY_FIELDS")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    oe.catalog_type_cd
    FROM (parser(oe_select) oe)
    WHERE oe.oe_field_id=source_oe_code
    DETAIL
     src_cat_cd = oe.catalog_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (src_cat_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_cat_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_oe_cd = cnvtreal(sbr_ret_val)
     SET src_cat_cnt = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",src_cat_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ELSE
    SET ui_oe_cd = 0
    SET src_cat_cnt = 1
   ENDIF
   IF (src_cat_cnt > 0)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_cv_cnt = 0
    SELECT INTO "NL:"
     FROM code_value c,
      order_entry_fields oe,
      (parser(cv_select) c1)
     PLAN (c1
      WHERE c1.code_value=source_oe_code)
      JOIN (c
      WHERE c.display_key=c1.display_key
       AND c.code_set=c1.code_set)
      JOIN (oe
      WHERE oe.oe_field_id=c.code_value
       AND oe.catalog_type_cd=ui_oe_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
      ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cv_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cv_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_cv_cnt = 0
     SELECT INTO "NL:"
      FROM code_value c,
       order_entry_fields oe,
       (parser(cv_select) c1)
      PLAN (c1
       WHERE c1.code_value=source_oe_code)
       JOIN (c
       WHERE c.display_key=c1.display_key
        AND c.code_set=c1.code_set
        AND c.active_ind=c1.active_ind)
       JOIN (oe
       WHERE oe.oe_field_id=c.code_value
        AND oe.catalog_type_cd=ui_oe_cd)
      DETAIL
       ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
       ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_cv_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_cv_cd=- (2)))
      RETURN(- (16))
     ELSEIF ((ui_cv_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_cv_cd)
     ENDIF
    ELSEIF ((ui_cv_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cv_cd)
    ENDIF
   ELSE
    RETURN(- (15))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_value(sbr_table,sbr_column,sbr_origin)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = vc
   DECLARE dyn_origin = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": The column",sbr_column,
     " doesn't exist.")
    RETURN("NO_COLUMN")
   ENDIF
   IF (cnvtupper(sbr_origin)="FROM")
    SET dyn_origin = "FROM"
   ELSEIF (cnvtupper(sbr_origin)="TO")
    SET dyn_origin = "TO"
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": Invalid origin passed in.")
    RETURN("INVALID_ORIGIN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
    OF "DQ8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "I4":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "F8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    ELSE
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET dyn_origin
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE get_nullind(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = i2
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,
     ": The column passed in to the GET_NULLIND sub isn't valid.")
    RETURN(- (1))
   ENDIF
   SET sbr_return = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].check_null
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE put_value(sbr_table,sbr_column,sbr_value)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   IF (sbr_value="")
    SET sbr_value = "0"
   ENDIF
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " doesn't exist on this table.")
    RETURN("NO_COLUMN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated = 1
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
    OF "DQ8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "I4":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "F8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = cnvtreal(sbr_value) go"),1)
    ELSE
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
 END ;Subroutine
 SUBROUTINE is_translated(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_trans_ind = i2
   DECLARE sbr_err_msg = vc
   DECLARE sbr_rpt_orphan_ind = i2
   DECLARE skip_for_orphan_ind = i2
   SET sbr_trans_ind = 1
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_table," is not a valid table name.")
    SET sbr_trans_ind = 0
   ELSE
    IF (sbr_column="ALL")
     SET sbr_rpt_orphan_ind = 0
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
         SET skip_for_orphan_ind = 0
         DECLARE it_col_value = vc
         DECLARE it_fnd = i4
         DECLARE it_srch = i4
         DECLARE it_parent_col = vc
         DECLARE it_i_domain = vc
         DECLARE it_i_name = vc
         DECLARE it_data_type = vc
         DECLARE it_col_pos = i4
         DECLARE it_mult_cnt = i4
         DECLARE it_table = vc
         DECLARE it_column = vc
         DECLARE it_from = f8
         DECLARE it_missing = vc
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_loop].parent_entity_col != ""))
          SET it_fnd = locateval(it_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[it_srch].tab_col_name)
          IF (it_fnd > 0)
           IF ((rdds_exception->qual[it_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[it_fnd].tru_col_name="INVALID"))
            SET it_table = ""
            SET it_column = ""
            SET it_from = 0
           ELSE
            SET it_table = rdds_exception->qual[it_fnd].tru_tab_name
            SET it_column = rdds_exception->qual[it_fnd].tru_col_name
            CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET it_col_value = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
            parent_entity_col)
           CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
           SET it_col_pos = locateval(it_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
            it_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_srch].column_name)
           IF (it_col_pos > 0)
            SET it_data_type = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_col_pos].
             data_type)
            IF (it_data_type IN ("VC", "C*"))
             SET it_fnd = 0
             SET it_fnd = locateval(it_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
              it_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_srch].column_name)
             IF (it_fnd != 0)
              CALL parser(concat("set it_parent_col = cnvtupper(RS_",dm2_ref_data_doc->tbl_qual[
                sbr_tbl_cnt].suffix,"->from_values.",it_col_value,") go"),1)
              IF (it_parent_col != ""
               AND it_parent_col != " ")
               SET it_parent_col = find_p_e_col(it_parent_col,sbr_loop)
              ELSE
               SET it_i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
                table_name)
               SET it_i_name = concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
                column_name,":",it_parent_col)
               SELECT INTO "NL:"
                FROM dm_info d
                WHERE d.info_domain=it_i_domain
                 AND d.info_name=it_i_name
                DETAIL
                 it_parent_col = d.info_char
                WITH nocounter
               ;end select
              ENDIF
             ENDIF
            ENDIF
           ENDIF
           IF (it_parent_col != "INVALIDTABLE"
            AND it_parent_col != "")
            SET it_table = it_parent_col
            SET it_fnd = locateval(it_srch,1,dguc_reply->rs_tbl_cnt,it_table,dguc_reply->dtd_hold[
             it_srch].tbl_name)
            IF (it_fnd != 0)
             IF ((dguc_reply->dtd_hold[it_fnd].pk_cnt >= 1))
              SET it_srch = 0
              FOR (it_mult_cnt = 1 TO dguc_reply->dtd_hold[it_fnd].pk_cnt)
                IF ((((dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*ID")) OR ((((
                dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*CD")) OR ((dguc_reply->
                dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="CODE_VALUE"))) )) )
                 IF ((((dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*ID")) OR ((
                 dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="CODE_VALUE"))) )
                  SET it_column = dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name
                  SET it_srch = (it_srch+ 1)
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             IF (it_srch > 1)
              SET it_column = ""
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name != ""))
          SET it_fnd = locateval(it_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[it_srch].tab_col_name)
          IF (it_fnd > 0)
           IF ((rdds_exception->qual[it_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[it_fnd].tru_col_name="INVALID"))
            SET it_table = ""
            SET it_column = ""
            SET it_from = 0
           ELSE
            SET it_table = rdds_exception->qual[it_fnd].tru_tab_name
            SET it_column = rdds_exception->qual[it_fnd].tru_col_name
            CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET it_table = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name
           SET it_column = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_attr
           CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
          ENDIF
         ENDIF
         SET it_missing = ""
         IF (it_table != ""
          AND it_from != 0
          AND (((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name !=
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name)) OR ((((dm2_ref_data_doc->tbl_qual[
         sbr_tbl_cnt].col_qual[sbr_loop].root_entity_attr != dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
         col_qual[sbr_loop].column_name)) OR ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         sbr_loop].pk_ind != 1))) )) )
          SET it_srch = locateval(it_mult_cnt,1,size(dm2_ref_data_doc->tbl_qual,5),it_table,
           dm2_ref_data_doc->tbl_qual[it_mult_cnt].table_name)
          IF (it_srch=0)
           SET it_mult_cnt = temp_tbl_cnt
           SET it_srch = fill_rs("TABLE",it_table)
           SET temp_tbl_cnt = it_mult_cnt
          ENDIF
          IF ((((dm2_ref_data_doc->tbl_qual[it_srch].mergeable_ind=0)) OR ((dm2_ref_data_doc->
          tbl_qual[it_srch].reference_ind=0)
           AND  NOT ((dm2_ref_data_doc->tbl_qual[it_srch].table_name IN ("ACCESSION", "ADDRESS",
          "PHONE", "PERSON", "PERSON_NAME",
          "PERSON_ALIAS", "DCP_ENTITY_RELTN", "LONG_TEXT", "LONG_BLOB", "ACCOUNT",
          "AT_ACCT_RELTN"))))) )
           SET drdm_mini_loop_status = "NOMV04"
           SET it_missing = "NOMV04"
           CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name,"NOMV04","",0.0)
          ELSE
           SET it_missing = report_missing(trim(it_table),trim(it_column),it_from)
          ENDIF
         ENDIF
         IF (it_missing="ORPHAN")
          IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].defining_attribute_ind=1))
           SET sbr_rpt_orphan_ind = 1
           SET drdm_no_trans_ind = 1
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat(it_missing," - ",dm2_ref_data_doc->tbl_qual[
            sbr_tbl_cnt].col_qual[sbr_loop].column_name)
           SET sbr_err_msg = concat(it_missing," - ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
            col_qual[sbr_loop].column_name)
           SET sbr_loop = sbr_col_cnt
          ELSE
           SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated = 1
           CALL parser(concat("set rs_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,"->to_values.",
             dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name," = 0 go"),1)
           SET skip_for_orphan_ind = 1
          ENDIF
         ELSEIF (it_missing="OLDVER")
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = it_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSEIF (it_missing="NOMV*")
          SET drdm_no_trans_ind = 1
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = it_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSE
          SET drdm_no_trans_ind = 1
          IF (get_err_val(null)=0)
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat("This log_id ",
            "wasn't translated because not all columns were translated.")
          ENDIF
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
         ENDIF
         IF (skip_for_orphan_ind=0)
          CALL echo("")
          CALL echo("")
          CALL echo(sbr_err_msg)
          CALL echo("")
          CALL echo("")
          CALL merge_audit("FAILREASON",sbr_err_msg,2)
          IF (drdm_error_out_ind=1)
           ROLLBACK
          ENDIF
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
       FREE SET it_col_value
       FREE SET it_fnd
       FREE SET it_srch
       FREE SET it_parent_col
       FREE SET it_i_domain
       FREE SET it_i_name
       FREE SET it_data_type
       FREE SET it_col_pos
       FREE SET it_mult_cnt
       FREE SET it_table
       FREE SET it_column
       FREE SET it_from
       FREE SET it_missing
     ENDFOR
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].exception_flg=9)
        AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
        SET drdm_no_trans_ind = 1
        SET dm2_ref_data_reply->error_ind = 1
        SET dm2_ref_data_reply->error_msg = concat("This log_id ",
         "wasn't translated because not all columns were translated.")
        SET sbr_err_msg = concat("This log_id ",
         "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
         sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
        SET sbr_trans_ind = 0
       ENDIF
     ENDFOR
    ELSEIF (sbr_column="UNIQUE")
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].unique_ident_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
         IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = concat("This log_id ",
           "wasn't translated because of the ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
           sbr_loop].column_name," column.")
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
      sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
     IF (sbr_col_cnt=0)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = concat(sbr_column," is not on the ",sbr_table," table.")
      SET sbr_trans_ind = 0
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated=0))
       SET sbr_trans_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   RETURN(sbr_trans_ind)
 END ;Subroutine
 SUBROUTINE get_seq(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_ret_val = f8
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name != ""))
    CALL parser("select into 'nl:' y = seq(",0)
    CALL parser(concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name,
      ", nextval) from dual detail sbr_ret_val = y with nocounter go"),1)
    SET new_seq_ind = 1
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " does not have a valid sequence")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   FREE SET sbr_error_name
   RETURN(sbr_ret_val)
 END ;Subroutine
 SUBROUTINE get_col_pos(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_col_cnt)
 END ;Subroutine
 SUBROUTINE get_primary_key(sbr_table)
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_return = vc
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   SET sbr_return = ""
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN("")
   ENDIF
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[d.seq].column_name=dm2_ref_data_doc->
     tbl_qual[sbr_tbl_cnt].col_qual[d.seq].root_entity_attr)
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
     .col_qual[d.seq].root_entity_name))
      sbr_return = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[d.seq].column_name
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE check_ui_exist(sbr_table_name)
   DECLARE sbr_return = i2
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_col_cnt = i4
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN(0)
   ENDIF
   SET sbr_return = 0
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].unique_ident_ind=1))
      sbr_return = 1
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE evaluate_rpt_missing(erm_missing_val)
   IF (erm_missing_val IN ("ORPHAN", "OLDVER", "BADLOG", "NOMV*"))
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = erm_missing_val
   ENDIF
 END ;Subroutine
 SUBROUTINE get_err_val(null)
  FOR (sbr_cust_loop = 1 TO drdm_log_types->cnt)
    IF ((dm2_ref_data_reply->error_msg=patstring(drdm_log_types->qual[sbr_cust_loop].type))
     AND sbr_err_val=0)
     SET sbr_err_val = sbr_cust_loop
    ENDIF
  ENDFOR
  RETURN(sbr_err_val)
 END ;Subroutine
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dir_sea_sch_files(directory=vc,file_prefix=vc,schema_date=vc(ref)) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_get_suffixed_tablename(tbl_name=vc) = i2
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_toolset_usage(null) = i2
 DECLARE dir_get_obsolete_objects(null) = i2
 DECLARE dir_find_data_file(dfdf_file_found=i2(ref)) = i2
 DECLARE dir_dm2_tables_tspace_assign(null) = i2
 DECLARE dir_get_debug_trace_data(null) = i2
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
 DECLARE dir_get_storage_type(dgst_db_link=vc) = i2
 DECLARE dir_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE dir_get_ddl_gen_retry(dgr_retry_ceiling=i2(ref)) = i2
 DECLARE dir_load_users_pwds(dlup_user_pwd=vc) = i2
 DECLARE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution=i2(ref),dcdosa_install_mode=vc) = i2
 DECLARE dir_check_for_package(dcfp_valid_ind=i2(ref),dcfp_env_id=f8(ref)) = i2
 DECLARE dir_get_dg_data(dgdd_assign_dg_ind=i2,dgdd_dg_override=vc,dgdd_dg_out=vc(ref)) = i2
 DECLARE dir_submit_jobs(dsj_plan_id=f8,dsj_install_mode=vc,dsj_user=vc,dsj_pword=vc,dsj_cnnct_str=vc,
  dsj_queue_name=vc,dsj_background_ind=i2) = i2
 DECLARE dir_get_adm_appl_status(dgaps_dblink=vc,dgaps_audsid=vc,dgaps_status=vc(ref)) = i2
 DECLARE dir_upd_adm_upgrade_info(null) = i2
 DECLARE dir_get_custom_constraints(null) = i2
 DECLARE dir_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 DECLARE dir_get_admin_db_link(dgadl_report_fail_ind=i2,dgadl_admin_db_link=vc(ref),dgadl_fail_ind=i2
  (ref)) = i2
 IF (validate(dm2_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_rdbms_version
  RECORD dm2_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
 ENDIF
 DECLARE dm2_get_rdbms_version() = i2
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT
    IF (currdbver < 19)
     FROM (
      (
      (SELECT
       orcl_version = t1.version
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC80")))
      t)
    ELSE
     FROM (
      (
      (SELECT
       orcl_version = t1.version_full
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC160")))
      t)
    ENDIF
    INTO "nl:"
    DETAIL
     dm2_rdbms_version->version = t.orcl_version
    WITH nocounter
   ;end select
   IF (check_error("Getting product component version")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Product component version not found."
    SET dm_err->eproc = "Getting product component version"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   WHILE (dgrv_loop=0)
     SET dgrv_level = (dgrv_level+ 1)
     SET dgrv_prev_loc = dgrv_loc
     SET dgrv_loc = 0
     SET dgrv_loc = findstring(".",dm2_rdbms_version->version,(dgrv_prev_loc+ 1),0)
     IF (((dgrv_loc > 0) OR (dgrv_loc=0
      AND dgrv_level > 1)) )
      IF (dgrv_loc=0
       AND dgrv_level > 1)
       SET dgrv_len = (textlen(dm2_rdbms_version->version) - dgrv_prev_loc)
       SET dgrv_loop = 1
      ELSE
       SET dgrv_len = ((dgrv_loc - dgrv_prev_loc) - 1)
      ENDIF
      CASE (dgrv_level)
       OF 1:
        SET dm2_rdbms_version->level1 = cnvtint(substring(1,dgrv_len,dm2_rdbms_version->version))
       OF 2:
        SET dm2_rdbms_version->level2 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 3:
        SET dm2_rdbms_version->level3 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 4:
        SET dm2_rdbms_version->level4 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 5:
        SET dm2_rdbms_version->level5 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       ELSE
        SET dgrv_loop = 1
      ENDCASE
     ELSE
      IF (dgrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET dgrv_loop = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
    1 lob_securefile_ind = vc
    1 lob_retention = vc
    1 lob_maxsize = vc
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
    1 add_nn_col_nobf_ind = vc
    1 create_index_invisible = vc
    1 use_initprm_assign_dg_ind = vc
    1 assign_dg_override = vc
    1 degree_of_parallel_max = vc
    1 degree_of_parallel = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
  SET dm2_db_options->table_monitoring = "NOT_SET"
  SET dm2_db_options->table_monitoring_maxretry = "NOT_SET"
  SET dm2_db_options->db_optimizer_category = "NOT_SET"
  SET dm2_db_options->dbstats_gather_method = "NOT_SET"
  SET dm2_db_options->cbf_maxrangegroups = "NOT_SET"
  SET dm2_db_options->resource_busy_maxretry = "NOT_SET"
  SET dm2_db_options->dbstats_chk_rpt = "NOT_SET"
  SET dm2_db_options->readme_space_calc = "NOT_SET"
  SET dm2_db_options->recompile_after_alter_tbl = "NOT_SET"
  SET dm2_db_options->add_nn_col_nobf_ind = "NOT_SET"
  SET dm2_db_options->create_index_invisible = "NOT_SET"
  SET dm2_db_options->lob_securefile_ind = "NOT_SET"
  SET dm2_db_options->lob_retention = "NOT_SET"
  SET dm2_db_options->lob_maxsize = "NOT_SET"
  SET dm2_db_options->use_initprm_assign_dg_ind = "NOT_SET"
  SET dm2_db_options->assign_dg_override = "NOT_SET"
  SET dm2_db_options->degree_of_parallel_max = "NOT_SET"
  SET dm2_db_options->degree_of_parallel = "NOT_SET"
 ENDIF
 IF (validate(dm2_table->full_table_name," ")=" ")
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF ((validate(dm2_install_rec->snapshot_dt_tm,- (1))=- (1)))
  FREE RECORD dm2_install_rec
  RECORD dm2_install_rec(
    1 snapshot_dt_tm = f8
  )
 ENDIF
 IF (validate(dir_install_misc->ddl_failed_ind,1)=1
  AND validate(dir_install_misc->ddl_failed_ind,2)=2)
  FREE RECORD dir_install_misc
  RECORD dir_install_misc(
    1 ddl_failed_ind = i2
  )
  SET dir_install_misc->ddl_failed_ind = 0
 ENDIF
 IF ((validate(dir_silmode_requested_ind,- (1))=- (1))
  AND (validate(dir_silmode_requested_ind,- (2))=- (2)))
  DECLARE dir_silmode_requested_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dir_silmode->cnt,1)=1
  AND validate(dir_silmode->cnt,2)=2)
  FREE RECORD dir_silmode
  RECORD dir_silmode(
    1 cnt = i4
    1 qual[*]
      2 name = vc
      2 filename = vc
  )
  SET dir_silmode->cnt = 0
 ENDIF
 IF (validate(dir_batch_queue,"X")="X"
  AND validate(dir_batch_queue,"Y")="Y")
  DECLARE dir_batch_queue = vc WITH public, constant(cnvtlower(build("INSTALL$",logical("environment"
      ))))
 ENDIF
 IF (validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,1.0)=1.0
  AND validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,2.0)=2.0)
  FREE RECORD dm_ocd_setup_admin_data
  RECORD dm_ocd_setup_admin_data(
    1 dm_ocd_setup_admin_date = dq8
    1 dm2_create_system_defs = dq8
    1 dm2_set_adm_cbo = f8
  )
 ENDIF
 IF ((validate(dir_obsolete_objects->tbl_cnt,- (2))=- (2))
  AND (validate(dir_obsolete_objects->tbl_cnt,- (1))=- (1)))
  FREE RECORD dir_obsolete_objects
  RECORD dir_obsolete_objects(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
    1 ind_cnt = i4
    1 ind[*]
      2 index_name = vc
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(dir_dropped_objects->obj_cnt,- (1))=- (1))
  AND (validate(dir_dropped_objects->obj_cnt,- (2))=- (2)))
  FREE RECORD dir_dropped_objects
  RECORD dir_dropped_objects(
    1 obj_cnt = i4
    1 rpt_drp_obj_ind = i2
    1 obj[*]
      2 table_name = vc
      2 name = vc
      2 type = vc
      2 reason = vc
  )
 ENDIF
 IF ((validate(dir_env_maint_rs->src_env_id,- (1))=- (1))
  AND (validate(dir_env_maint_rs->src_env_id,- (2))=- (2)))
  FREE RECORD dir_env_maint_rs
  RECORD dir_env_maint_rs(
    1 src_env_id = f8
    1 tgt_env_id = f8
    1 tgt_hist_fnd = i2
    1 process = vc
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
  SET dir_env_maint_rs->process = "DM2NOTSET"
 ENDIF
 IF (validate(dir_tools_tspaces->data_tspace,"X")="X"
  AND validate(dir_tools_tspaces->data_tspace,"Y")="Y")
  FREE RECORD dir_tools_tspaces
  RECORD dir_tools_tspaces(
    1 data_tspace = vc
    1 index_tspace = vc
    1 lob_tspace = vc
  )
  SET dir_tools_tspaces->data_tspace = "NONE"
  SET dir_tools_tspaces->index_tspace = "NONE"
  SET dir_tools_tspaces->lob_tspace = "NONE"
 ENDIF
 IF (validate(dir_managed_ddl->setup_complete,1)=1
  AND validate(dir_managed_ddl->setup_complete,2)=2)
  FREE RECORD dir_managed_ddl
  RECORD dir_managed_ddl(
    1 setup_complete = i2
    1 managed_ddl_ind = i2
    1 oraversion = vc
    1 priority_cnt = i4
    1 priorities[*]
      2 priority = i4
    1 table_cnt = i4
    1 tables[*]
      2 table_name = vc
  )
  SET dir_managed_ddl->setup_complete = 0
  SET dir_managed_ddl->managed_ddl_ind = 0
  SET dir_managed_ddl->oraversion = "DM2NOTSET"
  SET dir_managed_ddl->priority_cnt = 0
  SET dir_managed_ddl->table_cnt = 0
 ENDIF
 IF (validate(dir_ui_misc->dm_process_event_id,1)=1
  AND validate(dir_ui_misc->dm_process_event_id,2)=2)
  FREE RECORD dir_ui_misc
  RECORD dir_ui_misc(
    1 dm_process_event_id = f8
    1 parent_script_name = vc
    1 background_ind = i2
    1 install_status = i2
    1 auto_install_ind = i2
    1 tspace_dg = vc
    1 debug_level = i4
    1 trace_flag = i2
  )
 ENDIF
 IF (validate(dir_storage_misc->src_storage_type,"x")="x"
  AND validate(dir_storage_misc->src_storage_type,"y")="y")
  FREE RECORD dir_storage_misc
  RECORD dir_storage_misc(
    1 src_storage_type = vc
    1 tgt_storage_type = vc
    1 cur_storage_type = vc
  )
  SET dir_storage_misc->src_storage_type = "DM2NOTSET"
  SET dir_storage_misc->tgt_storage_type = "DM2NOTSET"
  SET dir_storage_misc->cur_storage_type = "DM2NOTSET"
 ENDIF
 IF (validate(dir_db_users_pwds->cnt,1)=1
  AND validate(dir_db_users_pwds->cnt,2)=2)
  FREE RECORD dir_db_users_pwds
  RECORD dir_db_users_pwds(
    1 cnt = i4
    1 qual[*]
      2 user = vc
      2 pwd = vc
  )
  SET dir_db_users_pwds->cnt = 0
 ENDIF
 IF (validate(dir_custom_constraints->con_cnt,1)=1
  AND validate(dir_custom_constraints->con_cnt,2)=2)
  FREE RECORD dir_custom_constraints
  RECORD dir_custom_constraints(
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
  SET dir_custom_constraints->con_cnt = 0
 ENDIF
 IF (validate(dir_killed_appl->appl_cnt,1)=1
  AND validate(dir_killed_appl->appl_cnt,2)=2)
  FREE RECORD dir_killed_appl
  RECORD dir_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET dir_killed_appl->appl_cnt = 0
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 IF (validate(dir_kill_clause,"z")="z"
  AND validate(dir_kill_clause,"y")="y")
  DECLARE dir_kill_clause = vc WITH public, constant(
   "Session was killed by V500.DM2MONPKG.KILL_IF_BLOCKING procedure.")
 ENDIF
 SUBROUTINE dir_dm2_tables_tspace_assign(null)
   IF ((dir_tools_tspaces->data_tspace != "NONE")
    AND (dir_tools_tspaces->index_tspace != "NONE")
    AND (dir_tools_tspaces->lob_tspace != "NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc =
    "Determining data_tspace from dm2_user_tables for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tables for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("D_TOOLKIT", "D_SYS_MGMT", "D_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc =
    "Determining index_tspace from dm2_user_indexes for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_indexes for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("I_TOOLKIT", "I_SYS_MGMT", "I_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->lob_tspace="NONE"))
    SET dir_tools_tspaces->lob_tspace = dir_tools_tspaces->data_tspace
    SET dm_err->eproc = "Determining lob_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("L_SYS_MGMT", "L_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->lob_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_debug_trace_data(null)
   SET dir_ui_misc->debug_level = 0
   SET dir_ui_misc->trace_flag = 0
   SET dm_err->eproc = "Query for debug flag/level"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="DEBUG_FLAG"
    DETAIL
     dir_ui_misc->debug_level = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Query for trace status"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="TRACE_FLAG"
    DETAIL
     IF (i.info_char="ON")
      dir_ui_misc->trace_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_obsolete_objects(null)
   SET dm_err->eproc = "Selecting obsolete tables and indexes from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_OBJECT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->tbl_cnt = 0, stat = alterlist(dir_obsolete_objects->tbl,
      dir_obsolete_objects->tbl_cnt), dir_obsolete_objects->ind_cnt = 0,
     stat = alterlist(dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    DETAIL
     CASE (build(di.info_char))
      OF "TABLE":
       dir_obsolete_objects->tbl_cnt = (dir_obsolete_objects->tbl_cnt+ 1),
       IF (mod(dir_obsolete_objects->tbl_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->tbl,(dir_obsolete_objects->tbl_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->tbl[dir_obsolete_objects->tbl_cnt].table_name = di.info_name
      OF "INDEX":
       dir_obsolete_objects->ind_cnt = (dir_obsolete_objects->ind_cnt+ 1),
       IF (mod(dir_obsolete_objects->ind_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->ind,(dir_obsolete_objects->ind_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->ind[dir_obsolete_objects->ind_cnt].index_name = di.info_name
     ENDCASE
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->tbl,dir_obsolete_objects->tbl_cnt), stat = alterlist(
      dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting obsolete constraints from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_CONSTRAINT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->con_cnt = 0, stat = alterlist(dir_obsolete_objects->con,
      dir_obsolete_objects->con_cnt)
    DETAIL
     dir_obsolete_objects->con_cnt = (dir_obsolete_objects->con_cnt+ 1)
     IF (mod(dir_obsolete_objects->con_cnt,10)=1)
      stat = alterlist(dir_obsolete_objects->con,(dir_obsolete_objects->con_cnt+ 9))
     ENDIF
     dir_obsolete_objects->con[dir_obsolete_objects->con_cnt].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->con,dir_obsolete_objects->con_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_obsolete_objects)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_src_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_ddl_token_replacement(ddtr_text_str)
   DECLARE ddtr_pword = vc WITH protect, noconstant("NONE")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Before token replacement",ddtr_text_str))
   ENDIF
   IF (currdbuser="CDBA")
    IF ( NOT ((dm2_install_schema->cdba_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->cdba_p_word
    ENDIF
   ELSE
    IF ( NOT ((dm2_install_schema->v500_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->v500_p_word
    ENDIF
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL1%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL2%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL3%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC%",dm2_install_schema->cer_install,0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC2%",dm2_install_schema->ccluserdir,0)
   IF ((dm2_install_schema->servername != "NONE"))
    SET ddtr_text_str = replace(ddtr_text_str,"%SNAME%",dm2_install_schema->servername,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%UNAME%",trim(currdbuser),0)
   IF (ddtr_pword != "NONE")
    SET ddtr_text_str = replace(ddtr_text_str,"%PWD%",ddtr_pword,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DBASE%",trim(validate(currdbname," ")),0)
   IF ( NOT ((dm2_install_schema->src_v500_p_word="NONE")))
    SET ddtr_text_str = replace(ddtr_text_str,"%SRCPWD%",dm2_install_schema->src_v500_p_word,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("After token replacement",ddtr_text_str))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((ccs_appl_id=dm2_install_schema->appl_id))
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm2_install_rec->snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(dm2_install_rec->snapshot_dt_tm,
        "mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = dm2_install_schema->appl_id,
      di.info_date = cnvtdatetime(dm2_install_rec->snapshot_dt_tm), di.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), di.updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_row_count(rrc_table_name,rrc_row_cnt)
   DECLARE rrc_local_row_cnt = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Retrieving row count for table ",trim(rrc_table_name),".")
   SELECT INTO "nl:"
    FROM dm_user_tables_actual_stats t
    WHERE t.table_name=rrc_table_name
    DETAIL
     rrc_local_row_cnt = t.num_rows
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET rrc_row_cnt = 0.0
   ELSE
    SET rrc_row_cnt = rrc_local_row_cnt
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = dm2_sys_misc->cur_db_os ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF ((dm2_install_schema->process_option="DDL GEN"))
    SET dm2_install_schema->schema_prefix = ""
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSEIF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option IN (
   "DDL GEN", "INHOUSE")))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF ((dm2_install_schema->schema_prefix="dm2a"))
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),"_t.csv"))=0)
     SET dm_err->emsg = concat("CSV Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "CSV Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ELSE
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
     SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name="DM_INFO"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND checkdic("DM_INFO","T",0)=2)
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Defaulting to DM2 toolset")
   ENDIF
   RETURN(dtu_use_dm2_toolset)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
    IF (cnvtupper(gas_appl_id)="-15301")
     RETURN(gas_active_status)
    ENDIF
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     SELECT INTO "nl:"
      FROM v$session s
      WHERE s.audsid=cnvtint(gas_appl_id)
      WITH nocounter
     ;end select
     IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(gas_error_status)
     ENDIF
     IF (curqual > 0)
      RETURN(gas_active_status)
     ELSE
      RETURN(gas_inactive_status)
     ENDIF
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE','DM_SEQ') ")
   RETURN(in_clause)
 END ;Subroutine
 SUBROUTINE dir_add_silmode_entry(entry_name,entry_filename)
   SET dir_silmode->cnt = (dir_silmode->cnt+ 1)
   SET stat = alterlist(dir_silmode->qual,dir_silmode->cnt)
   SET dir_silmode->qual[dir_silmode->cnt].name = entry_name
   SET dir_silmode->qual[dir_silmode->cnt].filename = entry_filename
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   DECLARE dcsa_load_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsa_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
     AND ddol.op_type != "*(REMOTE)*"
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        IF (dir_alert_killed_appl(dcsa_load_ind,dcsa_fmt_appl_id,dcsa_kill_ind)=0)
         RETURN(0)
        ENDIF
        SET dcsa_load_ind = 0
        IF (dcsa_kill_ind=1)
         SET dcsa_error_msg = dir_kill_clause
        ELSE
         SET dcsa_error_msg = concat("Application ID ",trim(dcsa_fmt_appl_id)," is no longer active."
          )
        ENDIF
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg =
          "IMPORT operation set to ERROR since session executing no longer exists.", ddol.end_dt_tm
           = cnvtdatetime(curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status="RUNNING"
          AND ddol.op_type="IMPORT*"
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN (null, "RUNNING")
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dir_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      dir_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       dir_killed_appl->appl_cnt += 1
       IF (mod(dir_killed_appl->appl_cnt,10)=1)
        stat = alterlist(dir_killed_appl->appl,(dir_killed_appl->appl_cnt+ 9))
       ENDIF
       dir_killed_appl->appl[dir_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_killed_appl->appl,dir_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,dir_killed_appl->appl_cnt,daka_fmt_appl_id,
     dir_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF ((dm2_sys_misc->cur_os != "AXP"))
    RETURN(1)
   ENDIF
   IF (((dsbq_queue_name=" ") OR (dsbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_env_name = logical("environment")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Environment Name = ",dsbq_env_name))
   ENDIF
   IF (((dsbq_env_name=" ") OR (dsbq_env_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment name."
    SET dm_err->emsg = "Invalid environment name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("lreg -getp environment\",dsbq_env_name,
    " LocalUserName ;show symbol LREG_RESULT")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dsbq_cmd))
    CALL echo("*")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,'LREG_RESULT = "',"",0)
   SET dm_err->errtext = replace(dm_err->errtext,'"',"",1)
   IF (findstring("%DCL-W-UNDSYM",dm_err->errtext) > 0)
    SET dsbq_domain_user = " "
   ELSE
    SET dsbq_domain_user = trim(dm_err->errtext,3)
   ENDIF
   IF (dsbq_domain_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Retreiving domain user from registry."
    SET dm_err->emsg = "Unable to retrieive domain user from registry."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(curuser) != cnvtupper(dsbq_domain_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Making sure current user is the domain user."
    SET dm_err->emsg = "Current user is not the domain user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("sho queue /full ",dsbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dsbq_queue_fnd = 0
   ELSEIF (findstring(cnvtlower(dsbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dsbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dsbq_queue_fnd = 1
   ENDIF
   IF (dsbq_queue_fnd=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dsbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dsbq_cmd = concat("init/queue/batch/start/job_limit=20 ",dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_sea_sch_files(directory,file_prefix,schema_date)
   DECLARE dgns_dcl_find = vc WITH protect, noconstant("")
   DECLARE dgns_err_str = vc WITH protect, noconstant("")
   SET schema_date = "01-JAN-1800"
   IF ( NOT (file_prefix IN ("dm2a", "dm2o", "dm2c")))
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "file_prefix must be IN ('dm2a', 'dm2o', 'dm2c')"
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"%%%2*")
    ELSE
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"*")
    ENDIF
    SET dgns_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"???3????_*")
    ELSE
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"*")
    ENDIF
    SET dgns_err_str = "file not found"
   ELSE
    IF (file_prefix="dm2a")
     IF ((dm2_sys_misc->cur_os="LNX"))
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???4* | wc -w")
     ELSE
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
     ENDIF
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     IF (file_prefix="dm2a")
      IF ((dm2_sys_misc->cur_os="LNX"))
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???4* ")
      ELSE
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
      ENDIF
     ELSE
      SET dgns_dcl_find = concat("ls - ",build(directory),"/",file_prefix,"* ")
     ENDIF
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dgns_dcl_find)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FREE DEFINE rtl
    FREE SET file_loc
    SET logical file_loc value(dm_err->errfile)
    DEFINE rtl "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      compare_date = cnvtdate("01011800"), stripped_date = cnvtdate("01011800")
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       starting_pos = findstring(cnvtupper(file_prefix),r.line)
      ELSE
       starting_pos = findstring(file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_list_of_files(dglf_prefix)
   DECLARE dglf_str = vc WITH protect
   SET dm_err->eproc = "Getting help list of schema files to select from."
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglf_str = concat("dir/version=1/columns=1 cer_install:",dglf_prefix,"*_h.dat ")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dglf_str = concat("dir ",dm2_install_schema->cer_install,"\",dglf_prefix,"*_h.dat /B")
   ELSE
    SET dglf_str = concat('find $cer_install -name "',dglf_prefix,'*_h.dat" -print')
   ENDIF
   IF (dm2_push_dcl(value(dglf_str))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_find_data_file(dfdf_file_found)
   DECLARE dtd_data_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Finding data files"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    DETAIL
     dtd_data_file = ddf.file_name
    WITH maxqual(ddf,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dfdf_file_found = findfile(dtd_data_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file found ind =",dfdf_file_found))
    CALL echo(build("file name =",dtd_data_file))
   ENDIF
   IF (dfdf_file_found=0)
    SET dm_err->eproc = "Datafile not visible at operating system level"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_managed_ddl_setup(dmds_runid)
   DECLARE dmds_rowcnt = f8 WITH protect, noconstant(0.0)
   DECLARE dmds_ndx = i4 WITH protect, noconstant(0)
   DECLARE dmds_priority = i4 WITH protect, noconstant(0)
   SET dir_managed_ddl->setup_complete = 0
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if Managed DDL oracle version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MANAGED_DDL_ORAVER"
    DETAIL
     IF (d.info_name=build(dm2_rdbms_version->level1,".",dm2_rdbms_version->level2,".",
      dm2_rdbms_version->level3,
      ".",dm2_rdbms_version->level4))
      dir_managed_ddl->oraversion = d.info_name, dir_managed_ddl->managed_ddl_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_managed_ddl->managed_ddl_ind=1))
    SET dm_err->eproc = "Check for row_cnt override for Managed DDL"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MANAGED_DDL_ROWCNT"
     DETAIL
      dmds_rowcnt = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dmds_rowcnt > 0.0)
     SET dm_err->eproc = concat("Managed DDL Rowcnt Override: ",build(dmds_rowcnt))
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dmds_rowcnt = 10000
    ENDIF
    SET dm_err->eproc = "Load Managed DDL Priorities"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d,
      dm_dba_tables_actual_stats t
     WHERE d.run_id=dmds_runid
      AND d.op_type IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="DM2_MANAGED_DDL_OP_TYPE"))
      AND d.table_name != "DM*"
      AND d.table_name=t.table_name
      AND t.num_rows > dmds_rowcnt
      AND (( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="DM2_MIXED_TABLE-EXPORT-REFERENCE"
       AND di.info_name=d.table_name))) OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE dtd.reference_ind=0
       AND dtd.table_name=d.table_name))))
      AND ((d.status != "COMPLETE") OR (d.status = null))
     ORDER BY d.priority, d.table_name
     HEAD d.priority
      dmds_ndx = 0, dmds_priority = d.priority
      IF ((dir_managed_ddl->priority_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->priority_cnt,dmds_priority,dir_managed_ddl->
        priorities[dmds_ndx].priority)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->priority_cnt = (dir_managed_ddl->priority_cnt+ 1)
       IF (mod(dir_managed_ddl->priority_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->priorities,(dir_managed_ddl->priority_cnt+ 99))
       ENDIF
       dir_managed_ddl->priorities[dir_managed_ddl->priority_cnt].priority = d.priority
      ENDIF
     HEAD d.table_name
      dmds_ndx = 0
      IF ((dir_managed_ddl->table_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->table_cnt,d.table_name,dir_managed_ddl->
        tables[dmds_ndx].table_name)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->table_cnt = (dir_managed_ddl->table_cnt+ 1)
       IF (mod(dir_managed_ddl->table_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->tables,(dir_managed_ddl->table_cnt+ 99))
       ENDIF
       dir_managed_ddl->tables[dir_managed_ddl->table_cnt].table_name = d.table_name
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_managed_ddl->tables,dir_managed_ddl->table_cnt), stat = alterlist(
       dir_managed_ddl->priorities,dir_managed_ddl->priority_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dir_managed_ddl->managed_ddl_ind = 0
    ENDIF
   ENDIF
   SET dir_managed_ddl->setup_complete = 1
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_managed_ddl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_perform_wait_interval(null)
   DECLARE dpwi_pause_interval = i4 WITH protect, noconstant(1)
   SET dm_err->eproc = "Obtain pause interval"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INSTALL_PKG"
     AND d.info_name="PAUSE_INTERVAL"
    DETAIL
     dpwi_pause_interval = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Pausing for ",build(dpwi_pause_interval)," minutes.")
   CALL disp_msg("",dm_err->logfile,0)
   CALL pause((dpwi_pause_interval * 60))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_storage_type(dgst_db_link)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dir_storage_misc->cur_storage_type = "AXP"
    SET dir_storage_misc->tgt_storage_type = "AXP"
    SET dir_storage_misc->src_storage_type = "AXP"
   ELSE
    IF (dgst_db_link > " "
     AND dgst_db_link != "DM2NOTSET")
     SET dm_err->eproc = "Determine source storage type from dba_data_files"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (parser(concat("dba_data_files@",dgst_db_link)) ddf)
      WHERE ddf.tablespace_name="SYSTEM"
       AND ddf.file_name=patstring("/dev/*")
      DETAIL
       dir_storage_misc->src_storage_type = "RAW"
      WITH nocounter, maxqual = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dir_storage_misc->src_storage_type = "ASM"
     ENDIF
    ENDIF
    SET dm_err->eproc = "Determine target storage type from dba_data_files"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE ddf.tablespace_name="SYSTEM"
     DETAIL
      IF (ddf.file_name=patstring("/dev/*"))
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ELSEIF (ddf.file_name=patstring("+*"))
       dir_storage_misc->cur_storage_type = "ASM", dir_storage_misc->tgt_storage_type = "ASM"
      ELSE
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ENDIF
     WITH nocounter, maxqual = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   IF (validate(dm2_tgt_storage_type,"XXX") IN ("RAW", "ASM"))
    SET dir_storage_misc->cur_storage_type = dm2_tgt_storage_type
    SET dir_storage_misc->tgt_storage_type = dm2_tgt_storage_type
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution,dcdosa_install_mode)
   DECLARE dcdosa_compare_date = vc WITH protect, noconstant("")
   DECLARE dcdosa_cer_install = vc WITH protect, noconstant("")
   DECLARE dcdosa_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm_ocd_setup_admin_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_dm2_create_system_defs_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm2_set_adm_cbo_date = dq8 WITH protect, noconstant(0.0)
   SET dcdosa_requires_execution = 0
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Admin Setup Bypassed - Database must be on Oracle to perform Admin setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "AXP", "LNX", "WIN"))))
    SET dm_err->eproc =
    "Admin Setup Bypassed - o/s must be HPX, AIX, VMS, LNX or WIN to perform Admin Setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT (dcdosa_install_mode IN ("UPTIME", "BATCHUP", "PREVIEW", "BATCHPREVIEW", "EXPRESS",
   "BATCHEXPRESS")))
    SET dm_err->eproc = "Checking install mode"
    SET dm_err->eproc = concat("Admin Setup Bypassed - Install mode needs to be ",
     " UPTIME, BATCHUP, PREVIEW, BATCHPREVIEW, EXPRESS or BATCHEXPRESS to perform Admin Setup.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("clinical database version : ",dm2_rdbms_version->level1))
   ENDIF
   SET dm_err->eproc = "Selecting dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    HEAD REPORT
     dcdosa_dm_info_schema_date = 0, dcdosa_dm_info_dm_ocd_setup_admin_date = 0.0,
     dcdosa_dm_info_dm2_create_system_defs_date = 0.0,
     dcdosa_dm_info_dm2_set_adm_cbo_date = 0.0
    DETAIL
     CASE (di.info_name)
      OF "SCHEMA_DATE":
       dcdosa_dm_info_schema_date = cnvtdate2(di.info_char,"DD-MMM-YYYY")
      OF "DM_OCD_SETUP_ADMIN_DATE":
       dcdosa_dm_info_dm_ocd_setup_admin_date = cnvtdatetime(di.info_char)
      OF "DM2_CREATE_SYSTEM_DEFS_DATE":
       dcdosa_dm_info_dm2_create_system_defs_date = cnvtdatetime(di.info_char)
      OF "DM2_SET_ADM_CBO_DATE":
       dcdosa_dm_info_dm2_set_adm_cbo_date = cnvtdatetime(di.info_char)
     ENDCASE
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding newest schema file."
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdosa_cer_install = cnvtlower(trim(logical("cer_install"),3))
   IF (dcfr_sea_csv_files(dcdosa_cer_install,"dm2a",dcdosa_compare_date)=0)
    RETURN(0)
   ELSE
    IF (dcdosa_compare_date="01-JAN-1800")
     SET dm_err->eproc = "Searching for Schema files."
     SET dm_err->emsg = "No schema files present in cer_install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dcdosa_schema_date = cnvtdate2(dcdosa_compare_date,"DD-MMM-YYYY")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("dcdosa_dm_info_schema_date:",dcdosa_dm_info_schema_date))
    CALL echo(build("dcdosa_schema_date:",dcdosa_schema_date))
    CALL echo(build("dcdosa_dm_info_dm_ocd_setup_admin_date:",dcdosa_dm_info_dm_ocd_setup_admin_date)
     )
    CALL echo(build("dm_ocd_setup_admin_data->dm_ocd_setup_admin_date:",dm_ocd_setup_admin_data->
      dm_ocd_setup_admin_date))
    CALL echo(build("dcdosa_dm_info_dm2_create_system_defs_date:",
      dcdosa_dm_info_dm2_create_system_defs_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_create_system_defs:",dm_ocd_setup_admin_data->
      dm2_create_system_defs))
    CALL echo(build("dcdosa_dm_info_dm2_set_adm_cbo_date:",dcdosa_dm_info_dm2_set_adm_cbo_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_set_adm_cbo:",dm_ocd_setup_admin_data->
      dm2_set_adm_cbo))
   ENDIF
   IF ((dm2_rdbms_version->level1 < 11))
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR ((
    dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs)))
    )) )
     SET dcdosa_requires_execution = 1
     RETURN(1)
    ENDIF
   ELSE
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR (
    (((dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs))
     OR ((dcdosa_dm_info_dm2_set_adm_cbo_date < dm_ocd_setup_admin_data->dm2_set_adm_cbo))) )) )) )
     SET dcdosa_requires_execution = 1
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_for_package(dcfp_valid_ind,dcfp_env_id)
   SET dcfp_valid_ind = 0
   SET dcfp_env_id = 0.0
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypassing check for package history.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Find environment id."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name="DM_ENV_ID"
    DETAIL
     dcfp_env_id = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = build("Look for package history for environment id :",dcfp_env_id)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.environment_id=dcfp_env_id
    WITH nocounter, maxqual(l,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
   ELSE
    SET dcfp_valid_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_dg_data(dgdd_assign_dg_ind,dgdd_dg_override,dgdd_dg_out)
   DECLARE dgdd_dskgrp_name = vc WITH protect, noconstant("")
   DECLARE dgdd_dskgrp_state = vc WITH protect, noconstant("")
   DECLARE dgdd_chck = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = "Get diskgroup information"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgdd_dg_out = "NOT_SET"
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Use initprm assign dg ind->",dgdd_assign_dg_ind))
    CALL echo(build("Diskgroup override->",dgdd_dg_override))
   ENDIF
   IF (dgdd_dg_override != "NOT_SET")
    SET dm_err->eproc = "Query for state of disk group "
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dg_override
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dg_override
     SET dgdd_chck = 0
    ENDIF
   ENDIF
   IF (dgdd_assign_dg_ind=1
    AND dgdd_chck=1)
    SET dm_err->eproc = "Query for disk group using db_create_file_dest"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$parameter v
     WHERE v.name="db_create_file_dest"
     DETAIL
      dgdd_dskgrp_name = cnvtupper(v.value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring("+",dgdd_dskgrp_name,1,0) > 0)
     SET dgdd_dskgrp_name = trim(replace(dgdd_dskgrp_name,"+","",1),3)
    ENDIF
    SET dm_err->eproc = "Query to validate diskgroup"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dskgrp_name
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dskgrp_name
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Determined diskgroup->",dgdd_dg_out))
   ENDIF
   IF (dgdd_dg_out != "NOT_SET")
    SET dir_ui_misc->tspace_dg = dgdd_dg_out
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_submit_jobs(dsj_plan_id,dsj_install_mode,dsj_user,dsj_pword,dsj_cnnct_str,
  dsj_queue_name,dsj_background_ind)
   DECLARE dsj_wait_time_minutes = i2 WITH protect, noconstant(15)
   DECLARE dsj_wait_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE dsj_wait_for_start = i2 WITH protect, noconstant(0)
   FREE RECORD dsj_request
   RECORD dsj_request(
     1 plan_id = f8
     1 install_mode = vc
   )
   FREE RECORD dsj_reply
   RECORD dsj_reply(
     1 install_status = vc
     1 event = vc
     1 install_mode_ret = vc
     1 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET dsj_request->plan_id = dsj_plan_id
   SET dsj_request->install_mode = "CURRENT"
   SET dsj_wait_timestamp = cnvtdatetime(curdate,curtime3)
   SET dm_err->eproc = "Get the status of auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_auto_install_status  WITH replace("REQUEST",dsj_request), replace("REPLY",dsj_reply)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    IF ((dsj_reply->install_status="EXECUTING"))
     SET dm_err->eproc = "Checking the status of the auto install process"
     SET dm_err->emsg = concat("Active package install running for ",dsj_reply->install_mode_ret)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "submit the package install to background"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_package_install,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_install_mode="*ABG")
    SET dsj_install_mode = replace(dsj_install_mode,"ABG","",2)
   ENDIF
   SET dm_err->eproc = "Waiting for background installation process to begin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Check for wait time override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_SUBMIT_TIME_WAIT"
     AND d.info_name="MINUTES"
    DETAIL
     dsj_wait_time_minutes = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dsj_wait_for_start = 1
   WHILE (dsj_wait_for_start=1)
     IF (drr_cleanup_dm_info_runners(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Wait for install to begin execution."
     SELECT INTO "nl:"
      FROM dm_process dp,
       dm_process_event dpe,
       dm_process_event_dtl dped1,
       dm_process_event_dtl dped2
      PLAN (dpe
       WHERE dpe.install_plan_id=dsj_plan_id
        AND dpe.begin_dt_tm >= cnvtdatetime(dsj_wait_timestamp))
       JOIN (dp
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution)
       JOIN (dped1
       WHERE dpe.dm_process_event_id=dped1.dm_process_event_id
        AND dped1.detail_type="INSTALL_MODE"
        AND dped1.detail_text=dsj_install_mode)
       JOIN (dped2
       WHERE dped1.dm_process_event_id=dped2.dm_process_event_id
        AND dped2.detail_type="UNATTENDED_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dsj_wait_for_start = 0
     ENDIF
     IF (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dsj_wait_timestamp)),4) > dsj_wait_time_minutes
      AND dsj_wait_for_start=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Wait time expired. Unable to detect background install process."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     CALL pause(5)
   ENDWHILE
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_install_monitor,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_background_ind=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,concat("The ",dsj_install_mode,
      " Installation is now submitted as a background process."))
    CALL text(3,1,"This session/connection is no longer required.")
    CALL text(5,1,"Notification emails about Installation events will be sent as they occur.")
    CALL text(8,1,concat("To monitor, stop or pause the execution of the background ",
      dsj_install_mode," Installation process,"))
    CALL text(9,1,"you can execute the following in CCL:")
    CALL text(11,1,"ccl> dm2_install_plan_menu go ")
    CALL text(13,3,"Enter 'C' to continue.")
    CALL accept(13,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = concat("Check if ",dcp_table_name," table is involved in a hard parse event.")
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",trim(dcp_owner),
      ".",dcp_table_name,". SQL_ID = ",
      trim(d.sql_id),", Session_Id:",trim(cnvtstring(d.session_id)),", Serial#: ",trim(cnvtstring(d
        .session_serial#)),
      ".")
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_ddl_gen_retry(dgr_retry_ceiling)
   DECLARE dgr_di_exists = i2 WITH protect, noconstant(0)
   SET dgr_retry_ceiling = 10
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgr_di_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgr_di_exists=1)
    SET dm_err->eproc = "Check for retry ceiling override."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_DDL_GEN"
      AND d.info_name="RETRY CEILING"
     DETAIL
      dgr_retry_ceiling = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgr_retry_ceiling <= 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Retry ceiling is invalid (must be greater than zero)."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_users_pwds(dlup_users_for_pwd)
   DECLARE dlup_user = vc WITH protect, noconstant("")
   DECLARE dlup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dlup_num = i4 WITH protect, noconstant(1)
   DECLARE dlup_idx = i2 WITH protect, noconstant(0)
   DECLARE dlup_choice = vc WITH protect, noconstant("")
   IF (size(dlup_users_for_pwd)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Loading users into record structure for password prompt."
    SET dm_err->emsg = "No user specified."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading users into record structure for password prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dlup_user != dlup_notfnd)
     SET dlup_user = piece(dlup_users_for_pwd,",",dlup_num,dlup_notfnd)
     SET dlup_num = (dlup_num+ 1)
     IF (dlup_user != dlup_notfnd)
      SET dlup_idx = locateval(dlup_idx,1,dir_db_users_pwds->cnt,dlup_user,dir_db_users_pwds->qual[
       dlup_idx].user)
      IF (dlup_idx=0)
       SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
       SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = dlup_user
       CALL clear(1,1)
       CALL text(6,2,concat("Please enter password for user ",dir_db_users_pwds->qual[
         dir_db_users_pwds->cnt].user,": "))
       CALL text(10,1,"Enter 'C' to continue or 'Q' to exit process. (C or Q): ")
       CALL accept(6,50,"P(30);C"," "
        WHERE  NOT (curaccept=" "))
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = build(curaccept)
       CALL accept(10,60,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       SET dlup_choice = curaccept
       IF (dlup_choice="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "User quit process.  "
        SET dm_err->eproc = "Prompting for database user password."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_db_users_pwds)
   ENDIF
   IF ((dir_db_users_pwds->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user/password list."
    SET dm_err->emsg = "Database user/password not loaded into memory."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_adm_appl_status(dgaps_dblink,dgaps_audsid,dgaps_status)
   SET dgaps_status = "ACTIVE"
   IF (cnvtupper(dgaps_audsid)="-15301")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (value(concat("GV$SESSION@",dgaps_dblink)) s)
    WHERE s.audsid=cnvtint(dgaps_audsid)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dir_get_adm_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (value(concat("V$SESSION@",dgaps_dblink)) s)
     WHERE s.audsid=cnvtint(dgaps_audsid)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dir_get_adm_appl_status")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgaps_status = "INACTIVE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_upd_adm_upgrade_info(null)
   DECLARE duaui_schema_date = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Deleting from dm_info for dm_ocd_setup_admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (dcfr_sea_csv_files(cnvtlower(trim(logical("cer_install"),3)),"dm2a",duaui_schema_date)=0)
    RETURN(0)
   ELSE
    IF (duaui_schema_date="01-JAN-1800")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Schema Date: ",duaui_schema_date))
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting schema_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "SCHEMA_DATE", di.info_char =
     duaui_schema_date,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm_ocd_setup_admin_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM_OCD_SETUP_ADMIN_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_create_system_defs_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_CREATE_SYSTEM_DEFS_DATE",
     di.info_char = format(dm_ocd_setup_admin_data->dm2_create_system_defs,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_set_adm_cbo_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_SET_ADM_CBO_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm2_set_adm_cbo,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_custom_constraints(null)
   DECLARE dgcc_constraint_index = i2 WITH protect, noconstant(0)
   SET dir_custom_constraints->con_cnt = 0
   SET stat = initrec(dir_custom_constraints)
   SET dm_err->eproc = "Retrieving custom constraints"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_CONSTRAINTS"
    DETAIL
     dgcc_constraint_index = (dgcc_constraint_index+ 1)
     IF (mod(dgcc_constraint_index,10)=1)
      stat = alterlist(dir_custom_constraints->con,(dgcc_constraint_index+ 9))
     ENDIF
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_custom_constraints->con,dgcc_constraint_index), dir_custom_constraints->
     con_cnt = dgcc_constraint_index
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcc_constraint_index=0)
    SET stat = alterlist(dir_custom_constraints->con,2)
    SET dir_custom_constraints->con[1].constraint_name = "CUCIM_ACQUIRED_STUDY"
    SET dir_custom_constraints->con[2].constraint_name = "CUCIM_SERIES"
    SET dir_custom_constraints->con_cnt = 2
   ELSE
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_ACQUIRED_STUDY",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_ACQUIRED_STUDY"
    ENDIF
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_SERIES",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_SERIES"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_admin_db_link(dgadl_report_fail_ind,dgadl_admin_db_link,dgadl_fail_ind)
   DECLARE dgadl_admin_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgadl_admin_link_match = i2 WITH protect, noconstant(0)
   SET dgadl_fail_ind = 0
   SET dm_err->eproc = "Obtain Admin database link name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
    DETAIL
     dgadl_admin_db_link = de.admin_dbase_link_name, dgadl_admin_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(dgadl_admin_db_link)=0)
    SET dgadl_fail_ind = 1
    IF (dgadl_report_fail_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Admin database link is not valued in DM_ENVIRONMENT.admin_dbase_link_name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgadl_fail_ind=0)
    SET dm_err->eproc = "Validate Admin database link name"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (parser(concat("cdba.dm_environment@",dgadl_admin_db_link)) de)
     WHERE de.environment_id=dgadl_admin_env_id
     DETAIL
      IF (cnvtupper(dgadl_admin_db_link)=cnvtupper(de.admin_dbase_link_name))
       dgadl_admin_link_match = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgadl_admin_link_match=0)
     SET dgadl_fail_ind = 1
     IF (dgadl_report_fail_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Admin database link does not exist in database or is causing data inconsistency when used."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE fill_rs(type=vc,info=vc) = i4 WITH public
 DECLARE dm2_rdds_get_tbl_col_info(sbr_gtci_tname=vc) = i2 WITH public
 DECLARE dm2_rdds_init_drcs_rec(null) = null
 DECLARE dm2_rdds_col_add(sbr_tbl_idx=i4,sbr_col_idx=i4) = i2
 DECLARE dm2_rdds_col_extend(sbr_tbl_idx=i4,sbr_col_idx=i4) = i2
 DECLARE dm2_rdds_col_compare(srb_tbl_idx=i4) = i2
 DECLARE fill_ccl_data_info(cdi_tbl_cnt=i4) = i2
 DECLARE dm2_rdds_get_tgt_id(s_gmti_tgt_rs=vc(ref)) = i2
 IF (validate(perm_tbl_cnt,- (1)) < 0)
  DECLARE perm_tbl_cnt = i4
  DECLARE temp_tbl_cnt = i4
  DECLARE perm_cs_cnt = i4
  DECLARE temp_cs_cnt = i4
  RECORD dm2_ref_data_doc(
    1 pre_link_name = vc
    1 post_link_name = vc
    1 mock_target_id = f8
    1 env_source_id = f8
    1 env_target_id = f8
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 mergeable_ind = i2
      2 reference_ind = i2
      2 version_ind = i2
      2 version_type = vc
      2 merge_ui_query = vc
      2 merge_ui_query_ni = i4
      2 suffix = vc
      2 merge_delete_ind = i2
      2 delete_select_ind = i2
      2 skip_seqmatch_ind = i2
      2 custom_script = vc
      2 insert_only_ind = i2
      2 update_only_ind = i2
      2 active_ind_ind = i2
      2 effective_col_ind = i2
      2 beg_col_name = vc
      2 end_col_name = vc
      2 lob_process_type = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
        3 unique_ident_ind = i4
        3 exception_flg = i4
        3 constant_value = vc
        3 parent_entity_col = vc
        3 sequence_name = vc
        3 root_entity_name = vc
        3 root_entity_attr = vc
        3 merge_delete_ind = i2
        3 data_type = vc
        3 data_length = vc
        3 binary_long_ind = i2
        3 pk_ind = i2
        3 code_set = i4
        3 nullable = c1
        3 check_null = i2
        3 check_space = i2
        3 translated = i2
        3 idcd_ind = i2
        3 in_tgt_flag = i2
        3 data_default = vc
        3 db_data_type = vc
        3 db_data_length = i4
        3 data_default_ni = i2
        3 db_data_type_tgt = vc
        3 defining_attribute_ind = i2
        3 version_nbr_child_ind = i2
        3 parent_table = vc
        3 parent_pk_col = vc
        3 parent_vers_col = vc
        3 child_fk_col = vc
      2 parent_flag = i4
      2 child_flag = i4
      2 parent_qual[*]
        3 child_name = vc
        3 parent_id_col = vc
        3 parent_tab_col = vc
        3 in_src_ind = i2
    1 cs_cnt = i4
    1 cs_qual[*]
      2 code_set = i4
      2 merge_ui_query = vc
      2 merge_ui_query_ni = i2
      2 cdf_meaning_dup_ind = i2
      2 display_dup_ind = i2
      2 display_key_dup_ind = i2
      2 active_ind_dup_ind = i2
      2 definition_dup_ind = i2
  )
  FREE RECORD global_mover_rec
  RECORD global_mover_rec(
    1 refchg_buffer = i4
    1 loop_back_ind = i2
    1 one_pass_ind = i2
    1 qual[*]
      2 pattern_cki = vc
  )
  SET dm2_ref_data_doc->env_target_id = - (1)
  SET dm2_ref_data_doc->env_source_id = - (1)
  SET dm2_ref_data_doc->mock_target_id = - (1)
  FREE RECORD missing_xlats
  RECORD missing_xlats(
    1 qual[*]
      2 table_name = vc
      2 column_name = vc
      2 missing_value = f8
      2 processed_ind = i2
      2 orphan_ind = i2
  )
  FREE RECORD pk_where_parm
  RECORD pk_where_parm(
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 col_name = vc
  )
  FREE RECORD filter_parm
  RECORD filter_parm(
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 col_name = vc
  )
 ENDIF
 IF ((validate(dm2_rdds_curdb_schema->col_cnt,- (1))=- (1)))
  FREE RECORD dm2_rdds_curdb_schema
  RECORD dm2_rdds_curdb_schema(
    1 same_count = i4
    1 ccl_same_cnt = i4
    1 ddl_exist_flag = c1
    1 appl_id = vc
    1 table_name = vc
    1 col_cnt = i4
    1 col[*]
      2 column_name = vc
      2 data_type = vc
      2 data_length = f8
  )
  SET dm2_rdds_curdb_schema->appl_id = "NOT SET"
 ENDIF
 SUBROUTINE fill_rs(type,info)
   DECLARE column_loop = i4
   DECLARE src_tab_name = vc
   DECLARE alg_code = f8
   DECLARE fr_di_appl_id = vc
   DECLARE fr_cur_appl_id = vc
   DECLARE drm_ioru_only = f8
   DECLARE drm_ioru_meaning = vc
   DECLARE fr_loop = i4
   SET fr_di_appl_id = "NOT SET"
   SET fr_cur_appl_id = "NOT SET"
   IF (type="TABLE")
    IF (dm2_rdds_get_tbl_col_info(info)=0)
     SET dm_err->err_ind = 0
     SET dm_err->eproc = "Determining if schema snapshot concurrency row should be removed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     SET fr_cur_appl_id = currdbhandle
     SELECT INTO "nl:"
      di.info_char
      FROM dm_info di
      WHERE di.info_domain="DM2 INSTALL PROCESS"
       AND di.info_name="CONCURRENCY CHECKPOINT"
      DETAIL
       fr_di_appl_id = di.info_char
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     SET dm_err->eproc = concat("dm_info appl_id=",fr_di_appl_id)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     SET dm_err->eproc = concat("current process appl_id=",fr_cur_appl_id)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     IF (fr_di_appl_id=fr_cur_appl_id
      AND fr_cur_appl_id != "NOT SET")
      SET dm_err->eproc =
      "Removing schema snapshot concurrency row since it was inserted by this process"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
      SET dm_err->err_ind = 0
      CALL check_concurrent_snapshot("D")
     ENDIF
     SET dm_err->err_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->eproc = "Retrieving schema information"
     SET dm_err->emsg = "Error occurred. Please refer to previous messages in logfile."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     di.info_char
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name=concat("MERGE SCRIPT:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].custom_script = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET drm_ioru_only = 0
    SET drm_ioru_only = uar_get_code_by("DISPLAY",4000220,nullterm(dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].table_name))
    IF (drm_ioru_only > 0)
     SET drm_ioru_meaning = uar_get_code_meaning(drm_ioru_only)
     IF (drm_ioru_meaning="NONE")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 0
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 0
     ELSEIF (drm_ioru_meaning="INSERT_ONLY")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 1
     ELSEIF (drm_ioru_meaning="UPDATE_ONLY")
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 1
     ENDIF
    ELSE
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind = 0
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].update_only_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain="RDDS SKIP SEQMATCH"
      AND di.info_name=info
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=1)
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind = 1
    ELSE
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind = 0
    ENDIF
    SET alg_code = 0
    SET alg_code = uar_get_code_by("DISPLAY",255351,nullterm(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt]
      .table_name))
    IF (alg_code > 0)
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type = uar_get_code_meaning(alg_code)
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type="NONE"))
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 0
     ELSE
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 1
     ENDIF
    ELSEIF ((alg_code=- (2)))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Error returned from Versiong Alg UAR."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF ((alg_code=- (1)))
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)),
      dm_info i
     PLAN (d
      WHERE (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].idcd_ind=0))
      JOIN (i
      WHERE i.info_domain=concat("RDDS TRANS COLUMN:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
       table_name)
       AND (i.info_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name))
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].idcd_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET tbl_loop = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,info,dguc_reply->dtd_hold[tbl_loop].
     tbl_name)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5)),
      (dummyt d2  WITH seq = dguc_reply->dtd_hold[tbl_loop].pk_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (dguc_reply->dtd_hold[tbl_loop].pk_hold[d2.seq].pk_name=dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[d.seq].column_name))
     DETAIL
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].pk_ind = 1
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     PLAN (d)
     DETAIL
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="ACTIVE_IND"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind = 1
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN (
      "BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM", "BEG_EFFECTIVE_UTC_DT_TM",
      "BEG_EFF_DT_TM",
      "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM")))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name = dm2_ref_data_doc->tbl_qual[
       temp_tbl_cnt].col_qual[d.seq].column_name
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN (
      "END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM",
      "CNTRCT_EFF_DT_TM")))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name = dm2_ref_data_doc->tbl_qual[
       temp_tbl_cnt].col_qual[d.seq].column_name
      ENDIF
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].db_data_type="*LOB"))
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].db_data_type_tgt="*LOB"))
        dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].lob_process_type = "LOB_LOB"
       ELSE
        dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].lob_process_type = "LOB_LONG"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name != "")
     AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name != ""))
     SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 1
    ENDIF
    FOR (fr_loop = 1 TO dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].exception_flg=9))
       SELECT INTO "NL:"
        FROM dm_refchg_version_r d
        WHERE (child_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
         AND (child_vers_col=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].column_name)
        DETAIL
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].version_nbr_child_ind = 1,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_table = d.parent_table,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_pk_col = d.parent_id_col,
         dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].parent_vers_col = d
         .parent_vers_col, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].child_fk_col =
         d.child_id_col
        WITH nocounter
       ;end select
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fr_loop].version_nbr_child_ind=0)
        AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind=0))
        SET dm_err->err_ind = 1
        SET drdm_error_out_ind = 1
        SET dm_err->eproc = "Retrieving schema information"
        SET dm_err->emsg = "A parent version_nbr column was found on a table that isn't versioned"
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
    SET drdm_return_var = temp_tbl_cnt
   ELSE
    SET dm_err->eproc = "Filling code set info into RS"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM code_value_set cvs
     WHERE cvs.code_set=cnvtint(info)
     DETAIL
      perm_cs_cnt = (perm_cs_cnt+ 1), temp_cs_cnt = perm_cs_cnt, stat = alterlist(dm2_ref_data_doc->
       cs_qual,temp_cs_cnt),
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].code_set = cvs.code_set, dm2_ref_data_doc->cs_qual[
      temp_cs_cnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, dm2_ref_data_doc->cs_qual[
      temp_cs_cnt].display_dup_ind = cvs.display_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].display_key_dup_ind = cvs.display_key_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].active_ind_dup_ind = cvs.active_ind_dup_ind,
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].definition_dup_ind = cvs.definition_dup_ind
     FOOT REPORT
      dm2_ref_data_doc->cs_cnt = temp_cs_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=0)
     CALL disp_msg("No code_set qualified from dm_code_set",dm_err->logfile,0)
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM dm_code_set dcs
     WHERE code_set=cnvtint(info)
     DETAIL
      dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query = dcs.merge_ui_query
      IF (dcs.merge_ui_query=null)
       dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 1
      ELSE
       dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm2_ref_data_doc->cs_qual[temp_cs_cnt].merge_ui_query_ni = 1
    ENDIF
    SET drdm_return_var = temp_cs_cnt
   ENDIF
   RETURN(drdm_return_var)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_col_info(sbr_gtci_tname)
   DECLARE fr_tab_name = vc
   SET dm_err->eproc = concat("Loading table level info into memory for table ",sbr_gtci_tname)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((validate(oragen3_ignore_dm_columns_doc,- (1))=- (1)))
    DECLARE oragen3_ignore_dm_columns_doc = i2
   ENDIF
   DECLARE src_tab_name = vc
   DECLARE rgtci_cnt = i4 WITH noconstant(0)
   DECLARE col_qual_cnt = i4 WITH noconstant(0)
   DECLARE rms_len_idx = i4 WITH noconstant(0)
   SET src_tab_name = dm2_get_rdds_tname("USER_TAB_COLUMNS")
   SET fr_tab_name = dm2_get_rdds_tname("dm_rdds_tbl_doc")
   SELECT INTO "NL:"
    FROM dm_rdds_tbl_doc drt,
     (parser(fr_tab_name) drs)
    PLAN (drs
     WHERE drs.table_name=sbr_gtci_tname)
     JOIN (drt
     WHERE drt.table_name=drs.table_name)
    DETAIL
     temp_tbl_cnt = (perm_tbl_cnt+ 1), perm_tbl_cnt = (perm_tbl_cnt+ 1), stat = alterlist(
      dm2_ref_data_doc->tbl_qual,value((size(dm2_ref_data_doc->tbl_qual,5)+ 1))),
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name = drs.table_name
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name IN ("ACCESSION", "ADDRESS", "PHONE",
     "PERSON", "PERSON_NAME",
     "PERSON_ALIAS", "DCP_ENTITY_RELTN", "LONG_TEXT", "LONG_BLOB", "ACCOUNT",
     "AT_ACCT_RELTN")))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = 1, dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].reference_ind = 1
     ELSEIF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = drs.mergeable_ind, dm2_ref_data_doc->
      tbl_qual[temp_tbl_cnt].reference_ind = drs.reference_ind
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind = drt.mergeable_ind, dm2_ref_data_doc->
      tbl_qual[temp_tbl_cnt].reference_ind = drt.reference_ind
     ENDIF
     IF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind = drs.merge_delete_ind
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind = drt.merge_delete_ind
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix = drs.table_suffix, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].merge_ui_query = drs.merge_ui_query
     IF (drs.merge_ui_query=null)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_ui_query_ni = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_ui_query_ni = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_ref_data_doc->tbl_qual,temp_tbl_cnt), dm2_ref_data_doc->tbl_cnt =
     temp_tbl_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     CALL disp_msg(concat("No table qualified for table",sbr_gtci_tname," in table level meta-data"),
      dm_err->logfile,1)
    ENDIF
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Loading column level info into memory for table ",sbr_gtci_tname)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET fr_tab_name = dm2_get_rdds_tname("DM_RDDS_COL_DOC")
   SELECT INTO "NL:"
    udd = nullind(utc.data_default)
    FROM dm_rdds_col_doc drt,
     (parser(src_tab_name) utc),
     (parser(fr_tab_name) drs)
    PLAN (drs
     WHERE drs.table_name=sbr_gtci_tname)
     JOIN (drt
     WHERE drt.table_name=sbr_gtci_tname
      AND drt.column_name=drs.column_name)
     JOIN (utc
     WHERE utc.table_name=sbr_gtci_tname
      AND utc.column_name=drt.column_name)
    DETAIL
     col_qual_cnt = (col_qual_cnt+ 1)
     IF (mod(col_qual_cnt,10)=1)
      stat = alterlist(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,(col_qual_cnt+ 9))
     ENDIF
     IF (drs.override_instance <= drt.override_instance)
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].column_name = drs.column_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].unique_ident_ind = drs
      .unique_ident_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      exception_flg = drs.exception_flg,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].constant_value = drs
      .constant_value, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      parent_entity_col = cnvtupper(drs.parent_entity_col), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].sequence_name = drs.sequence_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].root_entity_name = cnvtupper(
       drs.root_entity_name), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      root_entity_attr = cnvtupper(drs.root_entity_attr), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].code_set = drs.code_set,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].merge_delete_ind = drs
      .merge_delete_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      defining_attribute_ind = drs.defining_attribute_ind
      IF (drs.column_name IN ("*_ID", "*_CD", "CODE_VALUE"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 1
      ELSE
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 0
      ENDIF
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].column_name = drt.column_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].unique_ident_ind = drt
      .unique_ident_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      exception_flg = drt.exception_flg,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].constant_value = drt
      .constant_value, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      parent_entity_col = cnvtupper(drt.parent_entity_col), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].sequence_name = drt.sequence_name,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].root_entity_name = cnvtupper(
       drt.root_entity_name), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      root_entity_attr = cnvtupper(drt.root_entity_attr), dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      col_qual[col_qual_cnt].code_set = drt.code_set,
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].merge_delete_ind = drt
      .merge_delete_ind, dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].
      defining_attribute_ind = drt.defining_attribute_ind
      IF (drt.column_name IN ("*_ID", "*_CD", "CODE_VALUE"))
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 1
      ELSE
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].idcd_ind = 0
      ENDIF
     ENDIF
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_type = utc.data_type,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].db_data_length = utc.data_length,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].nullable = utc.nullable,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].check_null = 0, dm2_ref_data_doc
     ->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].translated = 0, dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].col_qual[col_qual_cnt].data_default = utc.data_default,
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = udd
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni=0))
      IF (((cnvtupper(utc.data_default)="NULL") OR (((utc.data_default=" ") OR (((utc.data_default=""
      ) OR (((utc.data_default="''") OR (utc.data_default='""')) )) )) )) )
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].data_default_ni = 1
      ENDIF
     ENDIF
     IF (utc.data_type IN ("BLOB", "LONG RAW", "CLOB", "LONG"))
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].binary_long_ind = 1
     ELSE
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[col_qual_cnt].binary_long_ind = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,col_qual_cnt),
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt = col_qual_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     CALL disp_msg(concat("No columns qualified from column level meta-data query for table ",
       sbr_gtci_tname),dm_err->logfile,1)
    ENDIF
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_rec->mode="OS"))
    IF (fill_ccl_data_info(temp_tbl_cnt)=0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_curdb_schema->same_count != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
    SET dm_err->eproc = "Schema differences exist between target and source domains"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Checking for inhouse domain"
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_set_inhouse_domain(null)=0)
     RETURN(0)
    ENDIF
    IF ((inhouse_misc->inhouse_domain=1))
     SET dm_err->emsg = concat(
      "Running in an inhouse domain, can not perform needed schema changes on ",sbr_gtci_tname)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    SET dm2_install_schema->appl_id = currdbhandle
    IF (check_concurrent_snapshot("I")=0)
     RETURN(0)
    ENDIF
    IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->same_count=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->eproc =
     "No schema differences exist between target and source domains inside the concurrency window"
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL check_concurrent_snapshot("D")
     RETURN(1)
    ENDIF
    SET dm2_rdds_curdb_schema->ddl_exist_flag = dm2_table_exists("DM2_DDL_OPS_LOG")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Getting ready to make the schema changes"
    FOR (rcc_lp = 1 TO dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag != 1))
       SET dm_err->eproc = concat("Schema diff found for ",sbr_gtci_tname,".",dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name)
       CALL disp_msg("",dm_err->logfile,0)
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].db_data_type IN ("LONG",
       "LONG RAW", "CLOB", "BLOB")))
        SET dm_err->emsg = "The missing column has LONG, LONG RAW, CLOB, or BLOB data type"
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF ((dm2_rdds_curdb_schema->ddl_exist_flag="F")
        AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=0))
        SET dm_err->eproc = "Checking if another process is getting ready to make the same change"
        CALL disp_msg("",dm_err->logfile,0)
        SET dm2_rdds_curdb_schema->appl_id = "NOT SET"
        SELECT INTO "nl:"
         d.*
         FROM dm2_ddl_ops_log d
         WHERE (d.table_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
          AND (d.obj_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name)
          AND d.op_type="ADD COLUMN"
         DETAIL
          dm2_rdds_curdb_schema->appl_id = d.appl_id
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((dm2_rdds_curdb_schema->appl_id != "NOT SET"))
         IF (dm2_get_appl_status(dm2_rdds_curdb_schema->appl_id) != "I")
          IF ((dm_err->err_ind=0))
           SET dm_err->eproc = concat("Another process is getting ready to add column ",
            dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].column_name," to ",
            dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
           SET dm_err->user_action = "Please restart this process"
           SET dm_err->err_ind = 1
           CALL disp_msg("",dm_err->logfile,0)
          ENDIF
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = "No other process is getting ready to make the same change"
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=0))
        IF (dm2_rdds_col_add(temp_tbl_cnt,rcc_lp)=0)
         RETURN(0)
        ENDIF
        IF (drm_log_sch_chg("RDDS SCHEMA MAINTENANCE:ADD COLUMN",build(dm2_ref_data_doc->tbl_qual[
          temp_tbl_cnt].table_name,".",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].
          column_name),concat("TYPE= ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].
          db_data_type,"; DEFAULT=",substring(1,200,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
           col_qual[rcc_lp].data_default)))=0)
         RETURN(0)
        ENDIF
       ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].in_tgt_flag=2))
        IF (dm2_rdds_col_extend(temp_tbl_cnt,rcc_lp)=0)
         RETURN(0)
        ENDIF
        IF (drm_log_sch_chg(build("RDDS SCHEMA MAINTENANCE:EXTEND DATA LENGTH (",dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[rcc_lp].db_data_length,")"),build(dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].table_name,".",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[
          rcc_lp].column_name),concat("TYPE= ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[
          rcc_lp].db_data_type))=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    SET oragen3_ignore_dm_columns_doc = 1
    EXECUTE oragen3 dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dm2_rdds_col_compare(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->same_count != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->emsg = "Column differences still exist after one pass of changes was made"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (check_concurrent_snapshot("D")=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (fill_ccl_data_info(temp_tbl_cnt)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_rdds_curdb_schema->ccl_same_cnt != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
    SET oragen3_ignore_dm_columns_doc = 1
    EXECUTE oragen3 dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (fill_ccl_data_info(temp_tbl_cnt)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdds_curdb_schema->ccl_same_cnt != dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Cannot find all columns for table ",dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].table_name," in CCL dictionary after performing oragen3")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_extend(sbr_tbl_idx,sbr_col_idx)
   SET dm_err->eproc = concat("Extend length for ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
    ".",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," to ",
    cnvtstring(dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length))
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
     " modify (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,"(",cnvtstring(
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length),")) go"),1)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_add(sbr_tbl_idx,sbr_col_idx)
   SET dm_err->eproc = concat("Add column ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[
    sbr_col_idx].column_name," for table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drm_bb_trg_cnt = i4
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type IN ("CHAR",
   "VARCHAR", "VARCHAR2", "CHARACTER", "RAW")))
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " add (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,"(",cnvtstring(
       dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_length),")) go"),1)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " add (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].db_data_type,") go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name IN ("BED", "BILL_ITEM")))
    SET drm_bb_trg_cnt = 0
    SELECT DISTINCT INTO "nl:"
     u.table_name
     FROM user_triggers u
     WHERE (u.table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
      AND u.trigger_name="REFCHG*"
     DETAIL
      drm_bb_trg_cnt = (drm_bb_trg_cnt+ 1)
     WITH nocounter
    ;end select
    IF (drm_bb_trg_cnt > 0)
     SET dguc_request->what_tables = dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name
     EXECUTE dm2_add_chg_log_triggers dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name, "REFCHG"
     IF (check_error("Failed to generate RDDS trigger for table BED and BILL_ITEM") != 0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].data_default_ni=0))
    IF (dm2_push_cmd(concat("rdb alter table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
      " modify (",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].column_name," ",
      " default ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[sbr_col_idx].data_default,") go"),
     1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_init_drcs_rec(null)
   SET dm2_rdds_curdb_schema->table_name = ""
   SET dm2_rdds_curdb_schema->col_cnt = 0
   SET stat = alterlist(dm2_rdds_curdb_schema->col,0)
   SET dm2_rdds_curdb_schema->same_count = 0
 END ;Subroutine
 SUBROUTINE dm2_rdds_col_compare(sbr_tbl_idx)
   DECLARE rcc_tbl_cnt = i4 WITH noconstant(0)
   SET dm_err->eproc = concat("Compare the schema for table ",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx]
    .table_name)
   CALL dm2_rdds_init_drcs_rec(null)
   SELECT INTO "nl:"
    FROM dm2_user_tab_columns utc
    WHERE (utc.table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name)
    DETAIL
     rcc_tbl_cnt = (rcc_tbl_cnt+ 1)
     IF (mod(rcc_tbl_cnt,50)=1)
      stat = alterlist(dm2_rdds_curdb_schema->col,(rcc_tbl_cnt+ 49))
     ENDIF
     dm2_rdds_curdb_schema->col[rcc_tbl_cnt].column_name = utc.column_name, dm2_rdds_curdb_schema->
     col[rcc_tbl_cnt].data_type = utc.data_type, dm2_rdds_curdb_schema->col[rcc_tbl_cnt].data_length
      = utc.data_length
    FOOT REPORT
     stat = alterlist(dm2_rdds_curdb_schema->col,rcc_tbl_cnt), dm2_rdds_curdb_schema->col_cnt =
     rcc_tbl_cnt, dm2_rdds_curdb_schema->table_name = utc.table_name
    WITH nocounter
   ;end select
   IF (check_error("Populating the target schema")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dm2_rdds_curdb_schema->col_cnt)),
     (dummyt dt  WITH seq = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt))
    PLAN (dt)
     JOIN (d
     WHERE (dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].column_name=
     dm2_rdds_curdb_schema->col[d.seq].column_name))
    DETAIL
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].in_tgt_flag = 1
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_type IN ("CHAR", "VARCHAR",
     "VARCHAR2", "RAW", "CHARACTER"))
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_length >
     dm2_rdds_curdb_schema->col[d.seq].data_length))
      dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].in_tgt_flag = 2
     ELSE
      dm2_rdds_curdb_schema->same_count = (dm2_rdds_curdb_schema->same_count+ 1)
     ENDIF
     dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[dt.seq].db_data_type_tgt =
     dm2_rdds_curdb_schema->col[d.seq].data_type
    WITH nocounter
   ;end select
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("dm2_rdds_curdb_schema->same_count=",dm2_rdds_curdb_schema->same_count,
     "; source col_cnt=",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt,"; currdb col_cnt=",
     dm2_rdds_curdb_schema->col_cnt)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = concat("Table name:",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].table_name,
     "; column changes needed:")
    FOR (df_lp = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[df_lp].in_tgt_flag=0))
       SET dm_err->eproc = concat(dm_err->eproc,"Add column:",dm2_ref_data_doc->tbl_qual[sbr_tbl_idx]
        .col_qual[df_lp].column_name,";")
      ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_idx].col_qual[df_lp].in_tgt_flag=2))
       SET dm_err->eproc = concat(dm_err->eproc,"Extend column:",dm2_ref_data_doc->tbl_qual[
        sbr_tbl_idx].col_qual[df_lp].column_name,";")
      ENDIF
    ENDFOR
    SET dm_err->eproc = concat(dm_err->eproc,"***End column changes")
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (check_error("Comparing the schema differences between target and source")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drm_log_sch_chg(sbr_lsc_domain,sbr_lsc_info_name,sbr_lsc_info_char)
   SET dm_err->eproc = "Log schema change to dm_info"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=sbr_lsc_domain
     AND d.info_name=sbr_lsc_info_name
     AND d.info_char=sbr_lsc_info_char
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = sbr_lsc_domain, d.info_name = sbr_lsc_info_name, d.info_char =
      sbr_lsc_info_char,
      d.updt_cnt = 0, d.updt_dt_tm = sysdate
     WITH noconter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE fill_ccl_data_info(cdi_tbl_cnt)
   SET dm_err->eproc = "Gather column info from CCL dictionary"
   SET dm2_rdds_curdb_schema->ccl_same_cnt = 0
   SELECT INTO "NL:"
    build(l.type,l.len), l.*, utc.data_type
    FROM dtableattr a,
     dtableattrl l,
     user_tab_columns utc
    PLAN (a
     WHERE (a.table_name=dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].table_name))
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
     JOIN (utc
     WHERE utc.table_name=a.table_name
      AND utc.column_name=l.attr_name)
    DETAIL
     sbr_cdi_idx = 0, sbr_cdi_idx = locateval(sbr_cdi_idx,1,dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].
      col_cnt,l.attr_name,dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].column_name)
     IF (sbr_cdi_idx > 0)
      dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_length = cnvtstring(l.len)
      IF (l.type="F")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "F8"
      ELSEIF (l.type="I")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "I4"
      ELSEIF (l.type="C")
       IF (utc.data_type="CHAR")
        dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = build(l.type,l.len)
       ELSE
        dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "VC"
       ENDIF
      ELSEIF (l.type="Q")
       dm2_ref_data_doc->tbl_qual[cdi_tbl_cnt].col_qual[sbr_cdi_idx].data_type = "DQ8"
      ENDIF
      dm2_rdds_curdb_schema->ccl_same_cnt = (dm2_rdds_curdb_schema->ccl_same_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tgt_id(s_gmti_tgt_rs)
   SET dm_err->eproc = "GET TARGET ENVIRONMENT ID"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drgmti_return_val = i2
   SET drgmti_return_val = 1
   IF ((s_gmti_tgt_rs->env_target_id=- (1)))
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      s_gmti_tgt_rs->env_target_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drgmti_return_val = 0
     RETURN(drgmti_return_val)
    ELSEIF (curqual=0)
     SET drgmti_return_val = 0
     SET dm_err->emsg = "INVALID TARGET ENV_ID OF ZERO FOUND"
     SET dm_err->user_action = "PLEASE RUN DM_SET_ENV_ID"
     RETURN(drgmti_return_val)
    ENDIF
   ENDIF
   IF ((s_gmti_tgt_rs->mock_target_id=- (1)))
    SELECT INTO "NL:"
     d.info_number
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="RDDS_MOCK_ENV_ID"
     DETAIL
      s_gmti_tgt_rs->mock_target_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drgmti_return_val = 0
     RETURN(drgmti_return_val)
    ENDIF
    IF (curqual=0)
     SET s_gmti_tgt_rs->mock_target_id = s_gmti_tgt_rs->env_target_id
    ENDIF
   ENDIF
   RETURN(drgmti_return_val)
 END ;Subroutine
 DECLARE ref_num = i4
 DECLARE inst_num = i4
 DECLARE active_num = i4
 DECLARE index_var = i4
 DECLARE inst_val = f8
 DECLARE ref_val = f8
 DECLARE from_id = f8
 DECLARE new_id = f8
 DECLARE cur_dt_tm = f8
 DECLARE ins_upd = i2
 DECLARE active_ind = i2
 DECLARE ref_vc = vc
 DECLARE src_str = vc
 DECLARE inactivate_ind = i2
 DECLARE cust_tab_name = vc
 DECLARE inst_vc = vc
 DECLARE inst_to_vc = vc
 DECLARE ref_ui_cnt = i4
 DECLARE ref_tbl_cnt = i4
 DECLARE dfr_imt_check = i2
 DECLARE cust_beg_eff_ind = i2
 FREE RECORD forms_def
 RECORD forms_def(
   1 qual[*]
     2 def_id = f8
 )
 SET nvp_commit_ind = 0
 SET inactivate_ind = 1
 SET ref_tbl_cnt = temp_tbl_cnt
 SET cust_tab_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
 SET src_str = dm2_get_rdds_tname(cust_tab_name)
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SET active_ind = cnvtint(get_value(cust_tab_name,"ACTIVE_IND","FROM"))
 SET ref_vc = get_value(cust_tab_name,"DCP_FORMS_REF_ID","FROM")
 SET inst_vc = get_value(cust_tab_name,"DCP_FORM_INSTANCE_ID","FROM")
 IF ((dm2_ref_data_reply->error_ind=1))
  GO TO exit_3202
 ENDIF
 IF (active_ind=0)
  SELECT INTO "nl:"
   FROM (parser(src_str) d)
   WHERE d.dcp_forms_ref_id=cnvtreal(ref_vc)
    AND d.active_ind=1
   DETAIL
    inactivate_ind = 0
   WITH nocounter
  ;end select
  IF (error(dm2_ref_data_reply->error_msg,0) > 0)
   SET dm2_ref_data_reply->error_ind = 1
   GO TO exit_3202
  ENDIF
  IF (inactivate_ind=1)
   CALL put_value(cust_tab_name,"ACTIVE_IND",cnvtstring(1))
  ENDIF
 ELSE
  SET inactivate_ind = 0
 ENDIF
 SET active_num = locateval(index_var,1,perm_col_cnt,"ACTIVE_IND",dm2_ref_data_doc->tbl_qual[
  temp_tbl_cnt].col_qual[index_var].column_name)
 SET ref_num = locateval(index_var,1,perm_col_cnt,"DCP_FORMS_REF_ID",dm2_ref_data_doc->tbl_qual[
  temp_tbl_cnt].col_qual[index_var].column_name)
 SET inst_num = locateval(index_var,1,perm_col_cnt,"DCP_FORM_INSTANCE_ID",dm2_ref_data_doc->tbl_qual[
  temp_tbl_cnt].col_qual[index_var].column_name)
 CALL echo("")
 CALL echo("")
 CALL echo("*******************TRANSLATE COLUMNS***********************")
 CALL echo("")
 CALL echo("")
 IF (inactivate_ind=0
  AND active_ind=1)
  SET inst_to_vc = select_merge_translate(inst_vc,"DCP_FORMS_REF")
  IF (inst_to_vc="No Trans")
   SET inst_val = get_seq(cust_tab_name,"DCP_FORM_INSTANCE_ID")
   IF (inst_val > 0)
    CALL put_value(cust_tab_name,"DCP_FORM_INSTANCE_ID",cnvtstring(inst_val))
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "NEWSEQ"
    SET child_merge_audit->num[current_merges].text = "DCP_FORMS_REF   DCP_FORM_INSTANCE_ID"
   ELSE
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    GO TO exit_3202
   ENDIF
   SET from_id = cnvtreal(get_value(cust_tab_name,"DCP_FORM_INSTANCE_ID","FROM"))
   IF ((dm2_ref_data_reply->error_ind=1))
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    GO TO exit_3202
   ELSE
    SET dfr_imt_check = insert_merge_translate(from_id,inst_val,"DCP_FORMS_REF")
    IF (dfr_imt_check=1)
     GO TO exit_3202
    ENDIF
   ENDIF
  ELSE
   SET inst_val = cnvtreal(inst_to_vc)
   SET cust_beg_eff_ind = 1
  ENDIF
 ELSEIF (inactivate_ind=0
  AND active_ind=0)
  SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[inst_num].translated = 1
  SET dm2_ref_data_reply->error_ind = 1
  SET dm2_ref_data_reply->error_msg = "OLDVER"
  CALL version_exception(cust_tab_name,"",cnvtreal(rs_3202->from_values.dcp_form_instance_id))
 ELSE
  SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[inst_num].translated = 1
 ENDIF
 IF (((active_ind=1) OR (inactivate_ind=1)) )
  SET temp_col_cnt = get_col_pos(cust_tab_name,"DCP_FORM_INSTANCE_ID")
  IF ((dm2_ref_data_reply->error_ind=1))
   SET stat = alterlist(dm2_ref_data_reply->qual,0)
   GO TO exit_3202
  ENDIF
  IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[ref_num].translated=0))
   SET ref_val = 0
   SET ref_ui_cnt = 0
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SELECT INTO "NL:"
    FROM dcp_forms_ref d
    WHERE (d.description=rs_3202->to_values.description)
     AND d.active_ind=1
    DETAIL
     ref_ui_cnt = (ref_ui_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ref_ui_cnt),
     ui_query_eval_rec->qual[ref_ui_cnt].root_entity_attr = d.dcp_forms_ref_id
    WITH nocounter
   ;end select
   SET ref_val = evaluate_exec_ui_query(ref_ui_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ref_val=- (3)))
    IF (inactivate_ind=1)
     CALL echo("DM2_REF_DATA_MOVER_3202:The inactive form doesn't exist in target")
     CALL merge_audit("FAILREASON","The inactive form doesn't exist in target",2)
     SET drdm_no_trans_ind = 1
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "OLDVER"
     IF (drdm_error_out_ind=1)
      ROLLBACK
      SET stat = alterlist(dm2_ref_data_reply->qual,0)
      GO TO exit_3202
     ENDIF
     SET stat = alterlist(dm2_ref_data_reply->qual,0)
     GO TO exit_3202
    ELSE
     SET ref_val = get_seq(cust_tab_name,"DCP_FORMS_REF_ID")
     IF (ref_val > 0)
      CALL put_value(cust_tab_name,"DCP_FORMS_REF_ID",cnvtstring(ref_val))
      SET current_merges = (current_merges+ 1)
      SET child_merge_audit->num[current_merges].action = "NEWSEQ"
      SET child_merge_audit->num[current_merges].text = "DCP_FORMS_REF   DCP_FORMS_REF_ID"
     ELSE
      SET stat = alterlist(dm2_ref_data_reply->qual,0)
      GO TO exit_3202
     ENDIF
    ENDIF
   ELSEIF ((ref_val=- (2)))
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "Multiple DPC_FORMS_REF_ID values returned w/ the UI"
    GO TO exit_3202
   ELSE
    CALL put_value(cust_tab_name,"DCP_FORMS_REF_ID",cnvtstring(ref_val))
   ENDIF
   SET from_id = cnvtreal(get_value(cust_tab_name,"DCP_FORMS_REF_ID","FROM"))
   IF ((dm2_ref_data_reply->error_ind=1))
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    GO TO exit_3202
   ELSE
    SET dfr_imt_check = insert_merge_translate(from_id,ref_val,"DCP_FORMS_REF")
    IF (dfr_imt_check=1)
     GO TO exit_3202
    ENDIF
   ENDIF
  ENDIF
  IF (cust_beg_eff_ind=1)
   SELECT INTO "nl:"
    FROM dcp_forms_ref dfr
    WHERE dfr.dcp_form_instance_id=inst_val
     AND dfr.active_ind=1
    DETAIL
     cur_dt_tm = cnvtdatetime(dfr.beg_effective_dt_tm)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV99"
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    CALL merge_audit("FAILREASON",
     "A dual maintenance change to a DCP_FORMS_REF row was not merged into SOURCE",1)
    GO TO exit_3202
   ENDIF
  ENDIF
  SET rs_3202->to_values.beg_effective_dt_tm = cur_dt_tm
  IF ((dm2_ref_data_reply->error_ind=1))
   SET stat = alterlist(dm2_ref_data_reply->qual,0)
   GO TO exit_3202
  ENDIF
  CALL echo(build("P COLUMN = ",curmem))
  SET idcd_check = 0
  CALL echo("")
  CALL echo("")
  CALL echo("***************CHECKING ID AND CD COLUMNS******************")
  CALL echo("")
  CALL echo("")
  IF (inactivate_ind=1)
   CALL put_value(cust_tab_name,"DCP_FORM_INSTANCE_ID","0")
  ENDIF
  SET idcd_check = is_translated("DCP_FORMS_REF","ALL")
  IF (drdm_error_out_ind=1)
   SET stat = alterlist(dm2_ref_data_reply->qual,0)
   GO TO exit_3202
  ENDIF
  IF (idcd_check=1)
   IF ((dm2_ref_data_reply->error_ind=1))
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    GO TO exit_3202
   ENDIF
   SET from_id = cnvtreal(get_value(cust_tab_name,"DCP_FORMS_REF_ID","FROM"))
   IF (cust_beg_eff_ind != 1)
    UPDATE  FROM dcp_forms_ref d
     SET d.active_ind = 0, d.end_effective_dt_tm = cnvtdatetime(cur_dt_tm)
     WHERE (d.dcp_forms_ref_id=rs_3202->to_values.dcp_forms_ref_id)
      AND d.active_ind=1
     WITH nocounter
    ;end update
   ENDIF
   IF (error(dm2_ref_data_reply->error_msg,0) > 0)
    SET dm2_ref_data_reply->error_ind = 1
    SET stat = alterlist(dm2_ref_data_reply->qual,0)
    GO TO exit_3202
   ENDIF
   IF (inactivate_ind=0)
    SET ins_upd = insert_update_row(temp_tbl_cnt,perm_col_cnt)
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "OLDVER"
    CALL version_exception(cust_tab_name,"",cnvtreal(rs_3202->from_values.dcp_form_instance_id))
   ENDIF
   CALL echo(build("p Insert = ",curmem))
  ELSE
   SET current_merges = 0
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
  ENDIF
 ENDIF
#exit_3202
END GO
